using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using System;
using ProtoMsg;

public class AssetBundlesExporter : EditorWindow
{
    static AssetBundlesExporter window;
    static string RootPath;
    static string mFileDefaultPath;
    static string mFolderDefaultPath;

    static AccType mPlatform = AccType.AccType_self_ios;
    static readonly string BASE_PATH = "assetbundlecomfig/";
    static readonly string DEFAULT_CONFIG = "default";
    static readonly string VERSION_CONFIG = "version";

    static readonly int PART_COUNT = 50;

    static BuildTarget btarget;

    class AssetBundleVersionItem
    {
        public string mName;
        public string mVersion;
        public string mExeVer;
        public string mBuildVer;
        public string mMd5;
        public string mSize;
        public string mNeed;
    }

    class AssetBundleItem
    {
        public List<string> mFolderPath;
        public List<string> mFilePath;
        public AssetsUtility.SuffixType mType;
        public string mName;
        public bool mLocal;
        public bool mNeed;
        public bool mPart;
        public string mVersion;
        public string mExeVer;
        public string mBuildVer;
    }

    class AssetTableInfo
    {
        public string namePath;
        public string assetbundleName;
    }
    static List<AssetTableInfo> assetTable = new List<AssetTableInfo>();

    static AssetsUtility.EPlatform m_CurPlatform;
    static bool mInit = false;

    static List<AssetBundleItem> mAssetBundleList = new List<AssetBundleItem>();
    static List<int> mPartTotalCnt = new List<int>();

    bool mHasAssetTransport = true;
    //List<AssetTransportInfo> mAssetTransportInfoList = new List<AssetTransportInfo>();
    //List<AssetTransportInfoSingleList> mAssetTransportInfoSingleList = new List<AssetTransportInfoSingleList>();
    static List<AssetBundleVersionItem> mAssetbundleVersionList = new List<AssetBundleVersionItem>();
    static List<AssetBundleVersionItem> mAssetbundleCurrentList = new List<AssetBundleVersionItem>();
    static List<string> mNeedVersionList = new List<string>();
    static List<bool> mNeedVersionNeedList = new List<bool>();

    bool mIsExporting = false;
    bool mIsCompressing = false;

    int mRemoveIndex_AssetBundle = -1;
    int mRemoveIndex_FolderIndex = -1;
    int mRemoveIndex_FileIndex = -1;
    int mRemoveIndex_Index_AssetBundle = -1;
    int mRemoveIndex_TransportFileList = -1;
    int mRemoveIndex_TransportFile = -1;
    int mRemoveIndex_TransportFolder = -1;
    int mRemoveIndex_Index_TransportFile = -1;

    static string lastversion = "";

    [MenuItem("Tools/AssetBundle Exporter")]
    static void CreateWindow()
    {
        if (window != null)
        {
            window.Close();
        }
        window = EditorWindow.GetWindow<AssetBundlesExporter>();
        window.titleContent = new GUIContent("Resource Exporter");
        window.minSize = new Vector2(1280, 640);
        Init();
        window.Show();
        window.ShowUtility();
    }

    static void Init()
    {
#if UNITY_IPHONE
		m_CurPlatform = AssetsUtility.EPlatform.eIOS;
        btarget = BuildTarget.iOS;
#elif UNITY_ANDROID || UNITY_EDITOR
        m_CurPlatform = AssetsUtility.EPlatform.eAndroid;
        btarget = BuildTarget.Android;
#else
        m_CurPlatform = AssetsUtility.EPlatform.ePC;
        btarget = BuildTarget.StandaloneWindows;
#endif

        if (!mInit)
        {
            RootPath = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf("/") + 1);
            mFileDefaultPath = Application.dataPath;
            mFolderDefaultPath = Application.dataPath;
            mAssetBundleList.Clear();
            mPartTotalCnt.Clear();
            InitConfigFiles();
            mInit = true;
        }
    }

    static void ExportPlatform()
    {
        string plaFile = Application.dataPath + "/../../autobuild/platform.txt";
        int platform = int.Parse(File.ReadAllText(plaFile));
        mPlatform = (AccType)platform;
        Init();
        Export();
    }

    static void Export()
    {
        ToLuaMenu.ClearLuaFiles();
        ToLuaMenu.CopyLuaFilesToRes();
        ClearAssetBundleNameAndVariant();
        ProcessAssets();
        if (!Directory.Exists(AssetsUtility.GetCachePath()))
        {
            Directory.CreateDirectory(AssetsUtility.GetCachePath());
        }
        if (!Directory.Exists(AssetsUtility.GetOutputPath(mPlatform.ToString())))
        {
            Directory.CreateDirectory(AssetsUtility.GetOutputPath(mPlatform.ToString()));
        }
        BuildPipeline.BuildAssetBundles(AssetsUtility.GetCachePath(), BuildAssetBundleOptions.None, btarget);
        MakeVersion();
    }

    static void MakeVersion()
    {
        int year = System.DateTime.Now.Year - 2000;
        string sVersion = year.ToString() +
            System.DateTime.Now.Month.ToString("d2") +
            System.DateTime.Now.Day.ToString("d2") +
            System.DateTime.Now.Hour.ToString("d2") +
            System.DateTime.Now.Minute.ToString("d2");
        string path = AssetsUtility.GetCachePath();
        string md5 = "";
        mAssetbundleCurrentList.Clear();
        for (int i = 0; i < mNeedVersionList.Count; i++)
        {
            EditorUtility.DisplayProgressBar("Resource Processing", "Generate file MD5", (float)i / mNeedVersionList.Count);
            byte[] b = null;
            if (AssetsUtility.EasyLoad(path, mNeedVersionList[i], false, delegate (Stream stream, string filename)
                {
                    b = new byte[stream.Length];
                    stream.Read(b, 0, b.Length);
                    md5 = AssetsUtility.GetMd5Hash(b);
                    return true;
                }))
            {
                AssetBundleVersionItem item = new AssetBundleVersionItem();
                item.mName = mNeedVersionList[i];
                item.mMd5 = md5;
                item.mVersion = sVersion;
                item.mExeVer = GameVersion.EXE;
                item.mBuildVer = GameVersion.BUILD;
                item.mSize = b.Length.ToString();
                item.mNeed = mNeedVersionNeedList[i] ? "1" : "0";
                mAssetbundleCurrentList.Add(item);
            }
        }
        EditorUtility.ClearProgressBar();
        CompareVersion(sVersion);
    }

    static void CompareVersion(string sVersion)
    {
        List<AssetBundleVersionItem> needRemove = new List<AssetBundleVersionItem>();
        for (int j = mAssetbundleVersionList.Count - 1; j >= 0; j--)
        {
            EditorUtility.DisplayProgressBar("Resource Processing", "Check MD5", (float)j / mAssetbundleVersionList.Count);
            bool isneedremove = true;
            for (int i = mAssetbundleCurrentList.Count - 1; i >= 0; i--)
            {
                if (mAssetbundleCurrentList[i].mName == mAssetbundleVersionList[j].mName)
                {
                    if (mAssetbundleCurrentList[i].mMd5 == mAssetbundleVersionList[j].mMd5)
                    {
                        //if (mAssetbundleCurrentList[i].mExeVer.Equals(mAssetbundleVersionList[j].mExeVer) && mAssetbundleCurrentList[i].mBuildVer.Equals(mAssetbundleVersionList[j].mBuildVer))
                        {
                            mAssetbundleCurrentList.RemoveAt(i);
                        }
                        //else
                        {
                            //mAssetbundleVersionList[j] = mAssetbundleCurrentList[i];
                            //mAssetbundleCurrentList.RemoveAt(i);
                        }
                    }
                    else
                    {
                        needRemove.Add(new AssetBundleVersionItem() { mName = mAssetbundleVersionList[j].mName, mVersion = mAssetbundleVersionList[j].mVersion });
                        mAssetbundleVersionList[j] = mAssetbundleCurrentList[i];
                        mAssetbundleCurrentList.RemoveAt(i);
                    }
                    isneedremove = false;
                }
            }
            if (isneedremove)
            {
                needRemove.Add(new AssetBundleVersionItem() { mName = mAssetbundleVersionList[j].mName, mVersion = mAssetbundleVersionList[j].mVersion });
                mAssetbundleVersionList.RemoveAt(j);
            }
        }
        string path = AssetsUtility.GetOutputPath(mPlatform.ToString()) + "/";
        foreach (var item in needRemove)
        {
            string _p = path + item.mVersion + "." + item.mName;
            if (File.Exists(_p))
            {
                File.Delete(_p);
            }
            _p += ".manifest";
            if (File.Exists(_p))
            {
                File.Delete(_p);
            }
        }
        mAssetbundleVersionList.AddRange(mAssetbundleCurrentList);
        SaveDefault();
        SaveVersion();
        CopyToOutPutPathByVersion(sVersion);
    }

    static void CopyToOutPutPathByVersion(string sVersion)
    {
        string sourcepath = AssetsUtility.GetCachePath();
        string path = AssetsUtility.GetOutputPath(mPlatform.ToString()) + "/";
        Dictionary<string, object> data = new Dictionary<string, object>();
        data["exeVer"] = GameVersion.EXE;
        data["buildVer"] = GameVersion.BUILD;
        List<Dictionary<string, object>> assets = new List<Dictionary<string, object>>();
        float i = 1;
        float total = mAssetbundleVersionList.Count;
        foreach (var item in mAssetbundleVersionList)
        {
            string target = item.mName;
            if (item.mName == AssetsUtility.ASSETBUNDLE)
            {
                target = AssetsUtility.ASSETBUNDLE + ".unity3d";
            }
            EditorUtility.DisplayProgressBar("Resource Processing", "Copy assets to build directory", i / total);
            Dictionary<string, object> asset = new Dictionary<string, object>();
            asset["name"] = target;
            asset["version"] = item.mVersion;
            asset["md5"] = item.mMd5;
            asset["size"] = item.mSize;
            asset["need"] = item.mNeed;
            assets.Add(asset);
            if (File.Exists(path + item.mName))
            {
                File.Delete(path + item.mName);
            }
            File.Copy(sourcepath + item.mName, path + target, true);
            if (File.Exists(path + item.mVersion + ".manifest"))
            {
                File.Delete(path + item.mVersion + ".manifest");
            }
            File.Copy(sourcepath + item.mName + ".manifest", path + target + ".manifest", true);
        }
        data["assets"] = assets.ToArray();
        EditorUtility.ClearProgressBar();
        if (!sVersion.Equals(lastversion))
        {
            if (File.Exists(path + AssetsUtility.ASSETVERSIONS))
            {
                File.Delete(path + AssetsUtility.ASSETVERSIONS);
            }
        }
        AssetsUtility.EasySave(path, AssetsUtility.ASSETVERSIONS, false, delegate (Stream stream, string filename)
        {
            byte[] b = System.Text.Encoding.UTF8.GetBytes(OurMiniJSON.Json.Serialize(data));
            stream.Write(b, 0, b.Length);
            return true;
        });

        SavePathTable(sVersion);

        Directory.Delete(AssetsUtility.GetCachePath(), true);
    }

    static void SavePathTable(string sVersion)
    {
        string path = AssetsUtility.GetOutputPath(mPlatform.ToString()) + "/";
        if (!sVersion.Equals(lastversion))
        {
            if (File.Exists(path + AssetsUtility.ASSETPATHTABLE))
            {
                File.Delete(path + AssetsUtility.ASSETPATHTABLE);
            }
        }
        Dictionary<string, string> data = new Dictionary<string, string>();
        foreach (var item in assetTable)
        {
            item.namePath = item.namePath.ToLower();
            data[item.namePath.Contains(".") ? item.namePath.Substring(0, item.namePath.LastIndexOf(".")) : item.namePath] = item.assetbundleName;
        }
        AssetsUtility.EasySave(path, AssetsUtility.ASSETPATHTABLE, false, delegate (Stream stream, string filename)
        {
            byte[] b = System.Text.Encoding.UTF8.GetBytes(OurMiniJSON.Json.Serialize(data));
            stream.Write(b, 0, b.Length);
            return true;
        });
    }

    static void ProcessAssets()
    {
        mNeedVersionList.Clear();
        mNeedVersionList.Add(AssetsUtility.ASSETBUNDLE);
        mNeedVersionNeedList.Clear();
        mNeedVersionNeedList.Add(true);
        assetTable.Clear();
        int year = System.DateTime.Now.Year - 2000;
        string sVersion = year.ToString() +
            System.DateTime.Now.Month.ToString("d2") +
            System.DateTime.Now.Day.ToString("d2") +
            System.DateTime.Now.Hour.ToString("d2");
        for (int i = 0; i < mAssetBundleList.Count; i++)
        {
            mAssetBundleList[i].mVersion = sVersion;
            mAssetBundleList[i].mExeVer = GameVersion.EXE;
            mAssetBundleList[i].mBuildVer = GameVersion.BUILD;
            string bundlename;
            for (int j = 0; j < mAssetBundleList[i].mFilePath.Count; j++)
            {
                EditorUtility.DisplayProgressBar("Resource Processing", "Set AssetBundle name", (float)j / mAssetBundleList[i].mFilePath.Count);
                AssetImporter ai = AssetImporter.GetAtPath(mAssetBundleList[i].mFilePath[j]);
                if (ai == null)
                {
                    continue;
                }
                if (mAssetBundleList[i].mPart)
                {
                    bundlename = mAssetBundleList[i].mName.Substring(0, mAssetBundleList[i].mName.LastIndexOf(".")) + "@" + mAssetBundleList[i].mFilePath[j].Substring(mAssetBundleList[i].mFilePath[j].LastIndexOf("/") + 1).ToLower() + "@.unity3d";
                    UnityEngine.Object obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(mAssetBundleList[i].mFilePath[j]);
                    UnityEngine.Object[] objs;
                    if (obj)
                    {
                        UnityEngine.Object[] roots = new UnityEngine.Object[] { obj };
                        
                            objs = EditorUtility.CollectDependencies(roots);
                        if (objs != null)
                        {
                            for (int k = 0; k < objs.Length; k++)
                            {
                                string pa = AssetDatabase.GetAssetPath(objs[k]);
                                if (pa != mAssetBundleList[i].mFilePath[j])
                                {
                                    if (pa.EndsWith(".prefab"))
                                    {
                                        AssetImporter aik = AssetImporter.GetAtPath(pa);
                                        if (aik)
                                        {
                                            pa = pa.Replace("/", "_");
                                            pa = pa.Replace(" ", "");
                                            pa += ".unity3d";
                                            pa = pa.ToLower();
                                            aik.SetAssetBundleNameAndVariant(pa, null);
                                            if (!mNeedVersionList.Contains(pa))
                                            {
                                                mNeedVersionList.Add(pa);
                                                mNeedVersionNeedList.Add(mAssetBundleList[i].mNeed);
                                            }
                                        }
                                    } 
                                }
                            }
                        }
                    }
                }
                else
                {
                    bundlename = mAssetBundleList[i].mName;
                }
                bundlename = bundlename.Replace(" ", "");
                
                ai.SetAssetBundleNameAndVariant(bundlename, null);
                assetTable.Add(new AssetTableInfo() { namePath = mAssetBundleList[i].mFilePath[j].Contains("Resources/") ? mAssetBundleList[i].mFilePath[j].Substring(mAssetBundleList[i].mFilePath[j].LastIndexOf("Resources/") + 10) : mAssetBundleList[i].mFilePath[j], assetbundleName = bundlename });

                if (!mNeedVersionList.Contains(bundlename))
                {
                    mNeedVersionList.Add(bundlename);
                    mNeedVersionNeedList.Add(mAssetBundleList[i].mNeed);
                }
            }
            for (int j = 0; j < mAssetBundleList[i].mFolderPath.Count; j++)
            {
                EditorUtility.DisplayProgressBar("Resource Processing", "Set AssetBundle name", (float)j / mAssetBundleList[i].mFolderPath.Count);
                List<AssetImporter> importers = new List<AssetImporter>();
                GetAssetImporterInFolder(RootPath + mAssetBundleList[i].mFolderPath[j], importers, AssetsUtility.GetSuffix(mAssetBundleList[i].mType));
                for (int k = 0; k < importers.Count; k++)
                {
                    if (mAssetBundleList[i].mPart)
                    {
                        bundlename = mAssetBundleList[i].mName.Substring(0, mAssetBundleList[i].mName.LastIndexOf(".")) + "@" + importers[k].assetPath.Substring(importers[k].assetPath.LastIndexOf("/") + 1).ToLower() + "@.unity3d";
                        UnityEngine.Object obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(importers[k].assetPath);
                        UnityEngine.Object[] objs;
                        if (obj)
                        {
                            UnityEngine.Object[] roots = new UnityEngine.Object[] { obj };

                            objs = EditorUtility.CollectDependencies(roots);
                            if (objs != null)
                            {
                                for (int l = 0; l < objs.Length; l++)
                                {
                                    string pa = AssetDatabase.GetAssetPath(objs[l]);
                                    if (pa != importers[k].assetPath)
                                    {
                                        if (pa.EndsWith(".prefab"))
                                        {
                                            AssetImporter aik = AssetImporter.GetAtPath(pa);
                                            if (aik)
                                            {
                                                pa = pa.Replace("/", "_");
                                                pa = pa.Replace(" ", "");
                                                pa += ".unity3d";
                                                pa = pa.ToLower();
                                                aik.SetAssetBundleNameAndVariant(pa, null);
                                                if (!mNeedVersionList.Contains(pa))
                                                {
                                                    mNeedVersionList.Add(pa);
                                                    mNeedVersionNeedList.Add(mAssetBundleList[i].mNeed);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        bundlename = mAssetBundleList[i].mName;
                    }
                    bundlename = bundlename.Replace(" ", "");
                    importers[k].SetAssetBundleNameAndVariant(bundlename, null);
                    assetTable.Add(new AssetTableInfo() { namePath = importers[k].assetPath.Contains("Resources/") ? importers[k].assetPath.Substring(importers[k].assetPath.LastIndexOf("Resources/") + 10) : importers[k].assetPath, assetbundleName = bundlename });

                    if (!mNeedVersionList.Contains(bundlename))
                    {
                        mNeedVersionList.Add(bundlename);
                        mNeedVersionNeedList.Add(mAssetBundleList[i].mNeed);
                    }
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    static void GetAssetImporterInFolder(string pathname, List<AssetImporter> assets, string filter)
    {
        string[] filters = filter.Split(new char[] { '|' });
        string[] subFiles = Directory.GetFiles(pathname);
        foreach (string subFile in subFiles)
        {
            bool canadd = false;
            for (int i = 0; i < filters.Length; i++)
            {
                if (subFile.Contains(filters[i]))
                {
                    canadd = true;
                }
            }
            if (canadd)
            {
                AssetImporter t = AssetImporter.GetAtPath(subFile.Replace(RootPath, ""));
                if (t)
                {
                    assets.Add(t);
                }
            }
        }

        string[] subDirs = Directory.GetDirectories(pathname);
        foreach (string subDir in subDirs)
        {
            GetAssetImporterInFolder(subDir, assets, filter);
        }
    }

    static void ClearAssetBundleNameAndVariant()
    {
        string[] names = AssetDatabase.GetAllAssetBundleNames();
        for (int i = 0; i < names.Length; i++)
        {
            EditorUtility.DisplayProgressBar("Resource Processing", "Clear AssetBundle names", (float)i / names.Length);
            AssetDatabase.RemoveAssetBundleName(names[i], true);
        }
        EditorUtility.ClearProgressBar();
    }

    void ClearAllData()
    {
        mAssetBundleList.Clear();
        mPartTotalCnt.Clear();
        mAssetbundleVersionList.Clear();
        SaveVersion();
        if (Directory.Exists(AssetsUtility.GetOutputPath(mPlatform.ToString()) + "/"))
        {
            Directory.Delete(AssetsUtility.GetOutputPath(mPlatform.ToString()) + "/", true);
        }
    }

    static void InitConfigFiles()
    {
        LoadDefault();
    }

    static void SaveVersion()
    {
        string configFileName = BASE_PATH + mPlatform.ToString() + "/";
        if (!Directory.Exists(configFileName))
        {
            Directory.CreateDirectory(configFileName);
        }
        configFileName += VERSION_CONFIG + "_" + lastversion;
        configFileName += ".xml";

        XmlDocument configXml = new XmlDocument();
        XmlDeclaration dec = configXml.CreateXmlDeclaration("1.0", "utf-8", null);
        configXml.AppendChild(dec);
        XmlElement root = configXml.CreateElement("root");
        configXml.AppendChild(root);
        XmlElement bundlelist = configXml.CreateElement("bundlelist");
        root.AppendChild(bundlelist);
        foreach (var item in mAssetbundleVersionList)
        {
            XmlElement abItemNode = configXml.CreateElement("bundle");
            abItemNode.SetAttribute("name", item.mName);
            abItemNode.SetAttribute("version", item.mVersion);
            abItemNode.SetAttribute("exever", item.mExeVer);
            abItemNode.SetAttribute("buildver", item.mBuildVer);
            abItemNode.SetAttribute("md5", item.mMd5);
            abItemNode.SetAttribute("size", item.mSize);
            abItemNode.SetAttribute("need", item.mNeed);
            bundlelist.AppendChild(abItemNode);
        }
        configXml.Save(configFileName);
    }

    static void LoadDefault()
    {
        string configFileName = BASE_PATH + mPlatform.ToString() + "/";
        if (!Directory.Exists(configFileName))
        {
            Directory.CreateDirectory(configFileName);
        }
        configFileName += DEFAULT_CONFIG;
        configFileName += ".xml";

        if (!File.Exists(configFileName))
        {
            XmlDocument config = new XmlDocument();
            XmlDeclaration dec = config.CreateXmlDeclaration("1.0", "utf-8", null);
            config.AppendChild(dec);
            XmlElement root = config.CreateElement("root");
            config.AppendChild(root);
            config.Save(configFileName);
        }

        mAssetBundleList.Clear();

        XmlDocument configXml = new XmlDocument();
        configXml.Load(configFileName);
        foreach (XmlNode node in configXml.DocumentElement.ChildNodes)
        {
            if (node.Name == "bundlelist")
            {
                lastversion = ((XmlElement)node).GetAttribute("version");
                foreach (XmlNode bundleNode in node.ChildNodes)
                {
                    XmlElement element = (XmlElement)bundleNode;

                    AssetBundleItem item = new AssetBundleItem();
                    item.mType = (AssetsUtility.SuffixType)int.Parse(element.GetAttribute("type"));
                    item.mName = element.GetAttribute("name");
                    item.mLocal = int.Parse(element.GetAttribute("local")) == 1;
                    item.mNeed = int.Parse(element.GetAttribute("need")) == 1;
                    item.mPart = int.Parse(element.GetAttribute("split")) == 1;
                    item.mVersion = element.GetAttribute("version");
                    item.mExeVer = element.GetAttribute("exever");
                    item.mBuildVer = element.GetAttribute("buildver");
                    item.mFolderPath = new List<string>();
                    item.mFilePath = new List<string>();
                    
                    foreach (XmlNode child in bundleNode)
                    {
                        XmlElement childElement = (XmlElement)child;

                        if (child.Name == "folder")
                        {
                            item.mFolderPath.Add(childElement.GetAttribute("path"));
                        }
                        else if (child.Name == "file")
                        {
                            item.mFilePath.Add(childElement.GetAttribute("path"));
                        }
                    }

                    mAssetBundleList.Add(item);
                    mPartTotalCnt.Add(0);
                }
            }
        }
        configXml = null;

        configFileName = BASE_PATH + mPlatform.ToString() + "/";
        if (!Directory.Exists(configFileName))
        {
            Directory.CreateDirectory(configFileName);
        }
        configFileName += VERSION_CONFIG + "_" + lastversion;
        configFileName += ".xml";

        mAssetbundleVersionList.Clear();
        mAssetbundleCurrentList.Clear();
        if (File.Exists(configFileName))
        {
            configXml = new XmlDocument();
            configXml.Load(configFileName);
            foreach (XmlNode node in configXml.DocumentElement.ChildNodes)
            {
                if (node.Name == "bundlelist")
                {
                    foreach (XmlNode bundleNode in node.ChildNodes)
                    {
                        XmlElement element = (XmlElement)bundleNode;
                        AssetBundleVersionItem abvi = new AssetBundleVersionItem();
                        abvi.mName = element.GetAttribute("name");
                        abvi.mVersion = element.GetAttribute("version");
                        abvi.mExeVer = element.GetAttribute("exever");
                        abvi.mBuildVer = element.GetAttribute("buildver");
                        abvi.mMd5 = element.GetAttribute("md5");
                        abvi.mSize = element.GetAttribute("size");
                        abvi.mNeed = element.GetAttribute("need");
                        mAssetbundleVersionList.Add(abvi);
                    }
                }
            }
            configXml = null;
        }
    }

    static void SaveDefault()
    {
        string configFileName = BASE_PATH + mPlatform.ToString() + "/";
        if (!Directory.Exists(configFileName))
        {
            Directory.CreateDirectory(configFileName);
        }
        configFileName += DEFAULT_CONFIG;
        configFileName += ".xml";

        if (!File.Exists(configFileName))
        {
            File.Create(configFileName);
        }
        int year = System.DateTime.Now.Year - 2000;
        lastversion = year.ToString() +
            System.DateTime.Now.Month.ToString("d2") +
            System.DateTime.Now.Day.ToString("d2") +
            System.DateTime.Now.Hour.ToString("d2") +
            System.DateTime.Now.Minute.ToString("d2");

        XmlDocument configXml = new XmlDocument();
        XmlDeclaration dec = configXml.CreateXmlDeclaration("1.0", "utf-8", null);
        configXml.AppendChild(dec);
        XmlElement root = configXml.CreateElement("root");
        configXml.AppendChild(root);
        XmlElement bundlelist = configXml.CreateElement("bundlelist");
        bundlelist.SetAttribute("version", lastversion);
        root.AppendChild(bundlelist);
        foreach (AssetBundleItem abItem in mAssetBundleList)
        {
            XmlElement abItemNode = configXml.CreateElement("bundle");
            abItemNode.SetAttribute("type", ((int)abItem.mType).ToString());
            abItemNode.SetAttribute("name", abItem.mName);
            abItemNode.SetAttribute("version", abItem.mVersion);
            abItemNode.SetAttribute("exever", abItem.mExeVer);
            abItemNode.SetAttribute("buildver", abItem.mBuildVer);
            abItemNode.SetAttribute("local", abItem.mLocal ? "1" : "0");
            abItemNode.SetAttribute("need", abItem.mNeed ? "1" : "0");
            abItemNode.SetAttribute("split", abItem.mPart ? "1" : "0");
            
            foreach (var item in abItem.mFilePath)
            {
                XmlElement abItemFilePath = configXml.CreateElement("file");
                abItemFilePath.SetAttribute("path", item);
                abItemNode.AppendChild(abItemFilePath);
            }
            foreach (var item in abItem.mFolderPath)
            {
                XmlElement abItemFolderPathe = configXml.CreateElement("folder");
                abItemFolderPathe.SetAttribute("path", item);
                abItemNode.AppendChild(abItemFolderPathe);
            }
            bundlelist.AppendChild(abItemNode);
        }
        configXml.Save(configFileName);
    }

    void MoveDirectory(string srcDir, string tgtDir, bool recursive)
    {
        DirectoryInfo source = new DirectoryInfo(srcDir);
        DirectoryInfo target = new DirectoryInfo(tgtDir);

        if (target.FullName.StartsWith(source.FullName, System.StringComparison.InvariantCultureIgnoreCase))
        {
            return;
        }

        if (!source.Exists)
            return;

        if (source.Name.ToLower().Equals(".svn"))
        {
            Debug.Log("svn:" + source.Name);
            return;
        }

        if (!target.Exists)
            target.Create();

        FileInfo[] files = source.GetFiles();
        for (int i = 0; i < files.Length; i++)
        {
            if (files[i].Name.ToLower().Equals(".svn"))
            {
                return;
            }
            string dir = target.FullName + "/" + files[i].Name;
            dir = dir.Substring(0, dir.LastIndexOf("/"));
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
            if (!File.Exists(target.FullName + "/" + files[i].Name))
            {
                File.Move(files[i].FullName, target.FullName + "/" + files[i].Name);
            }
        }

        if (recursive)
        {
            DirectoryInfo[] dirs = source.GetDirectories();
            for (int j = 0; j < dirs.Length; j++)
            {
                MoveDirectory(dirs[j].FullName, target.FullName + "/" + dirs[j].Name, recursive);
            }
        }
    }

    Vector2 mScroll = Vector2.zero;
    Vector2 mScroll2 = Vector2.zero;
    void OnGUI()
    {
        if (EditorApplication.isCompiling || !mInit) return;

        GUILayout.BeginArea(new Rect(0, 0, 1280, 640));
        GUILayout.Space(10);
        GUILayout.BeginHorizontal();
        {
            string platform = "PC";
            if (m_CurPlatform == AssetsUtility.EPlatform.eIOS)
            {
                platform = "IOS";
            }
            else if (m_CurPlatform == AssetsUtility.EPlatform.eAndroid)
            {
                platform = "Android";
            }

            GUIStyle contentStyle = new GUIStyle();
            contentStyle.fontSize = 12;
            contentStyle.normal.textColor = Color.yellow;
            if (platform == "Android")
                contentStyle.normal.textColor = Color.green;

            contentStyle.fontStyle = FontStyle.BoldAndItalic;
            GUILayout.Label("Current Platform is : ", GUILayout.Width(150));
            GUILayout.Label(platform, contentStyle, GUILayout.Width(100));

            GUILayout.Space(20);
            mPlatform = (AccType)EditorGUILayout.EnumPopup(mPlatform, GUILayout.Width(200));

            GUILayout.Space(20);
            if (GUILayout.Button("Clear", GUILayout.Width(80)))
            {
                ClearAllData();
            }

            GUILayout.Space(20);
            if (GUILayout.Button("Load", GUILayout.Width(80)))
            {
                LoadDefault();
            }

            GUILayout.Space(20);
            if (GUILayout.Button("Save", GUILayout.Width(80)))
            {
                SaveDefault();
            }
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(10);
        GUILayout.BeginHorizontal();
        {
            GUILayout.Label("Add and Select the assetbundle files!", GUILayout.Width(250));
            if (GUILayout.Button("Add", GUILayout.Width(80)))
            {
                AssetBundleItem item = new AssetBundleItem();
                item.mFolderPath = new List<string>();
                item.mFilePath = new List<string>();
                item.mType = AssetsUtility.SuffixType.eAll;
                item.mName = "default_" + mAssetBundleList.Count + ".unity3d";
                item.mLocal = false;
                item.mNeed = true;
                item.mPart = false;
                item.mVersion = "";
                item.mExeVer = GameVersion.EXE;
                item.mBuildVer = GameVersion.BUILD;

                mAssetBundleList.Add(item);
                mPartTotalCnt.Add(0);
            }
            GUILayout.Space(100);
            GUILayout.Label("Input resource information from clipboard", GUILayout.Width(150));
            if (GUILayout.Button("Import", GUILayout.Width(80)))
            {
                CopyMemoryProcess();
            }
        }
        GUILayout.EndHorizontal();
        GUILayout.Space(10);

        mScroll = GUILayout.BeginScrollView(mScroll);

        GUILayout.Space(10);
        for (int i = 0; i < mAssetBundleList.Count; i++)
        {
            GUILayout.BeginHorizontal();
            {
                GUILayout.Space(5);
                if (GUILayout.Button("-", GUILayout.Width(25)))
                {
                    mRemoveIndex_AssetBundle = i;
                }

                GUILayout.Space(5);
                mAssetBundleList[i].mType = (AssetsUtility.SuffixType)EditorGUILayout.EnumPopup("", mAssetBundleList[i].mType, GUILayout.Width(70));
                GUILayout.Label(AssetsUtility.GetSuffix(mAssetBundleList[i].mType), GUILayout.Width(150));

                GUILayout.Space(10);
                GUILayout.Label(string.Format("EXE:{0} Build:{1} Time:{2}", mAssetBundleList[i].mExeVer, mAssetBundleList[i].mBuildVer, mAssetBundleList[i].mVersion), GUILayout.Width(250));
                GUILayout.Space(10);
                GUILayout.Label("Name:", GUILayout.Width(50));
                mAssetBundleList[i].mName = GUILayout.TextField(mAssetBundleList[i].mName, GUILayout.Width(150));

                GUILayout.Space(10);
                mAssetBundleList[i].mLocal = GUILayout.Toggle(mAssetBundleList[i].mLocal, "Local Files!", GUILayout.Width(80));

                GUILayout.Space(10);
                mAssetBundleList[i].mNeed = GUILayout.Toggle(mAssetBundleList[i].mNeed, "Need Load First", GUILayout.Width(80));

                GUILayout.Space(10);
                mAssetBundleList[i].mPart = GUILayout.Toggle(mAssetBundleList[i].mPart, "Split Files!", GUILayout.Width(80));
            }
            GUILayout.EndHorizontal();


            for (int j = 0; j < mAssetBundleList[i].mFolderPath.Count; j++)
            {
                GUILayout.BeginHorizontal();
                {
                    GUILayout.Space(80);
                    if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(10)))
                    {
                        mRemoveIndex_FolderIndex = j;
                        mRemoveIndex_Index_AssetBundle = i;
                    }

                    GUILayout.Space(10);
                    if (!mAssetBundleList[i].mPart)
                    {
                        mAssetBundleList[i].mFolderPath[j] = GUILayout.TextField(mAssetBundleList[i].mFolderPath[j], GUILayout.Width(600));
                    }
                    else
                    {
                        GUILayout.TextField(mAssetBundleList[i].mFolderPath[j], GUILayout.Width(600));
                    }
                }
                GUILayout.EndHorizontal();
                GUILayout.Space(5);
            }

            for (int j = 0; j < mAssetBundleList[i].mFilePath.Count; j++)
            {
                GUILayout.BeginHorizontal();
                {
                    GUILayout.Space(80);
                    if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(10)))
                    {
                        mRemoveIndex_FileIndex = j;
                        mRemoveIndex_Index_AssetBundle = i;
                    }

                    GUILayout.Space(10);
                    if (!mAssetBundleList[i].mPart)
                    {
                        mAssetBundleList[i].mFilePath[j] = GUILayout.TextField(mAssetBundleList[i].mFilePath[j], GUILayout.Width(600));
                    }
                    else
                    {
                        GUILayout.TextField(mAssetBundleList[i].mFilePath[j], GUILayout.Width(600));
                    }
                }
                GUILayout.EndHorizontal();
                GUILayout.Space(5);
            }
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("AddFile", GUILayout.Width(120)))
            {
                string _path = EditorUtility.OpenFilePanelWithFilters("AddFile", mFileDefaultPath, AssetsUtility.GetSuffixArray(mAssetBundleList[i].mType));
                mFileDefaultPath = _path.Substring(0, _path.LastIndexOf("/") + 1);
                _path = _path.Replace(RootPath, "");
                if (!string.IsNullOrEmpty(_path))
                {
                    mAssetBundleList[i].mFilePath.Add(_path);
                    mAssetBundleList[i].mFilePath.Sort(delegate (string a, string b) { return a.CompareTo(b); });
                }
            }
            if (GUILayout.Button("AddFolder", GUILayout.Width(120)))
            {
                string _path = EditorUtility.OpenFolderPanel("AddFolder", mFolderDefaultPath, "");
                mFolderDefaultPath = _path;
                _path = _path.Replace(RootPath, "");
                if (!string.IsNullOrEmpty(_path))
                {
                    mAssetBundleList[i].mFolderPath.Add(_path);
                    mAssetBundleList[i].mFolderPath.Sort(delegate (string a, string b) { return a.CompareTo(b); });
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.Label("----------------------------------------------");
            GUILayout.Space(10);
        }

        GUILayout.EndScrollView();

        GUILayout.Space(20);
        GUILayout.BeginHorizontal();
        {
            if (GUILayout.Button("Export", GUILayout.Width(200)))
            {
                Export();
            }
        }
        GUILayout.EndHorizontal();

        if (mHasAssetTransport)
        {
            GUILayout.Space(20);
            GUILayout.BeginHorizontal();

            GUI.color = Color.green;

            if (GUILayout.Button("Remove Resources", GUILayout.Width(400)))
            {
                for (int i = 0; i < mAssetBundleList.Count; i++)
                {
                    if (!mAssetBundleList[i].mLocal)
                    {
                        for (int j = 0; j < mAssetBundleList[i].mFilePath.Count; j++)
                        {
                            File.Delete(mAssetBundleList[i].mFilePath[j]);
                        }
                        for (int j = 0; j < mAssetBundleList[i].mFolderPath.Count; j++)
                        {
                            Directory.Delete(mAssetBundleList[i].mFolderPath[j], true);
                        }
                    }
                }
                AssetDatabase.Refresh();
            }

            GUILayout.EndHorizontal();

            GUI.color = Color.yellow;
            GUILayout.Label("Please remove the resources before building.");
        }

        GUILayout.EndArea();

        if (mRemoveIndex_AssetBundle != -1)
        {
            mAssetBundleList.RemoveAt(mRemoveIndex_AssetBundle);
            mRemoveIndex_AssetBundle = -1;
        }
        if (mRemoveIndex_FolderIndex != -1)
        {
            if (mRemoveIndex_Index_AssetBundle != -1)
            {
                mAssetBundleList[mRemoveIndex_Index_AssetBundle].mFolderPath.RemoveAt(mRemoveIndex_FolderIndex);
            }

            mRemoveIndex_FolderIndex = -1;
        }
        if (mRemoveIndex_FileIndex != -1)
        {
            if (mRemoveIndex_Index_AssetBundle != -1)
            {
                mAssetBundleList[mRemoveIndex_Index_AssetBundle].mFilePath.RemoveAt(mRemoveIndex_FileIndex);
            }

            mRemoveIndex_FileIndex = -1;
        }
    }

    [MenuItem("Tools/ClearRebelHelp")]
    static void ClearRebelHelp()
    {
        PlayerPrefs.DeleteKey("rebelhelp");
        PlayerPrefs.Save();
    }

    [MenuItem("Tools/RemoveAssetsInBundle")]
    static void DeleRes()
    {
#if UNITY_IPHONE
		m_CurPlatform = AssetsUtility.EPlatform.eIOS;
        btarget = BuildTarget.iOS;
#elif UNITY_ANDROID
        m_CurPlatform = AssetsUtility.EPlatform.eAndroid;
        btarget = BuildTarget.Android;
#else
        m_CurPlatform = AssetsUtility.EPlatform.ePC;
        btarget = BuildTarget.StandaloneWindows;
#endif
        LoadDefault();
        for (int i = 0; i < mAssetBundleList.Count; i++)
        {
            if (!mAssetBundleList[i].mLocal)
            {
                for (int j = 0; j < mAssetBundleList[i].mFilePath.Count; j++)
                {
                    File.Delete(mAssetBundleList[i].mFilePath[j]);
                }
                for (int j = 0; j < mAssetBundleList[i].mFolderPath.Count; j++)
                {
                    Directory.Delete(mAssetBundleList[i].mFolderPath[j], true);
                }
            }
        }
        AssetDatabase.Refresh();
    }
    
    static void CopyMemoryProcess()
    {
        string str = EditorGUIUtility.systemCopyBuffer;
        string[] strs = str.Split(new char[] { '\r', '\n' });
        for (int i = 0; i < strs.Length; i++)
        {
            if (strs[i].Length > 0)
            {
                if (strs[i].EndsWith(".cs") ||
                    strs[i].EndsWith(".meta") ||
                    strs[i].EndsWith(".proto") ||
                    strs[i].EndsWith("login.prefab") ||
                    strs[i].EndsWith(".asset") ||
                    (!strs[i].Contains("Assets/") && !strs[i].Contains("/GeneratedLua/")) ||
                    !strs[i].Contains("."))
                {
                    continue;
                }
                else if (strs[i].EndsWith(".bytes"))
                {
                    ProcessPathByPackageName(ReplacePath(strs[i]), "dat");
                }
                else if (strs[i].EndsWith(".lua"))
                {
                    if (strs[i].Contains("Assets/Lua") || strs[i].Contains("/GeneratedLua/"))
                    {
                        if (strs[i].Contains("/tableData/"))
                        {
                            ProcessPathByPackageName(ReplacePath(strs[i]), "lua_dat");
                        }
                        else
                        {
                            ProcessPathByPackageName(ReplacePath(strs[i]), "lua");
                        } 
                    }
                }
                else if (strs[i].Contains("/Resources/"))
                {
                    string packname = GetPackageName(strs[i]);
                    if (packname != "")
                    {
                        ProcessPathByPackageName(ReplacePath(strs[i]), packname); 
                    }
                }
            }
        }
    }
    
    static string GetPackageName(string path)
    {
        string name = "";
        string temp = path.ToLower();
        if (temp.Contains("ui") && temp.Contains("maincity"))
        {
            name = "maincityui_prefab";
        }
        else if (temp.Contains("/resources/level/"))
        {
            temp = temp.Substring(temp.IndexOf("/resources/level/") + 17);
            name = temp.Substring(0, temp.IndexOf("/"));
        }
        else if (temp.EndsWith(".prefab"))
        {
            temp = temp.Substring(0, temp.LastIndexOf("/"));
            int front = temp.LastIndexOf("/") + 1;
            name = temp.Substring(front, temp.Length - front) + "_prefab";
        }
        else if (temp.EndsWith(".png") || temp.EndsWith(".jpg"))
        {
            temp = temp.Substring(0, temp.LastIndexOf("/"));
            string bname = temp.Substring(0, temp.LastIndexOf("/"));
            int front = bname.LastIndexOf("/") + 1;
            name = temp.Substring(front, temp.Length - front) + "_texture";
            name = name.Replace("/", "_");
            name = name.Replace("resources_", "");
        }
        return name;
    }

    static string ReplacePath(string path)
    {
        try
        {
            string front;
            if (path.Contains("/GeneratedLua/"))
            {
                front = path.Substring(0, path.LastIndexOf("/") + 1);
                path = "Assets/Resources/Lua/" + path.Substring(front.Length) + ".bytes";
            }
            else if (path.Contains("/Lua/"))
            {
                front = path.Substring(0, path.LastIndexOf("Lua/"));
                path = "Assets/Resources/" + path.Substring(front.Length) + ".bytes";
            }
            else
            {
                front = path.Substring(0, path.LastIndexOf("Assets/"));
                path = path.Substring(front.Length);
            }
        }
        catch (Exception)
        {
            Debug.Log(path);
        }
        return path;
    }
    
    static void ProcessPathByPackageName(string path, string name)
    {
        AssetBundleItem abi = GetPackage(name);
        for (int i = 0; i < abi.mFilePath.Count; i++)
        {
            if (abi.mFilePath[i].Equals(path))
            {
                return;
            }
        }
        abi.mFilePath.Add(path);
        abi.mFilePath.Sort(delegate (string a, string b) { return a.CompareTo(b); });
    }

    static AssetBundleItem GetPackage(string name)
    {
        name = name.ToLower();
        for (int i = 0; i < mAssetBundleList.Count; i++)
        {
            if (mAssetBundleList[i].mName.Equals(name + ".unity3d"))
            {
                return mAssetBundleList[i];
            }
        }
        return AddPackage(name);
    }

    static AssetBundleItem AddPackage(string name)
    {
        AssetBundleItem item = new AssetBundleItem();
        item.mFolderPath = new List<string>();
        item.mFilePath = new List<string>();
        item.mType = AssetsUtility.SuffixType.eAll;
        item.mName = name + ".unity3d";
        item.mLocal = false;
        item.mNeed = true;
        item.mPart = false;
        item.mVersion = "";
        item.mExeVer = GameVersion.EXE;
        item.mBuildVer = GameVersion.BUILD;

        mAssetBundleList.Add(item);
        return item;
    }
}

public class CollectDependenciesExample : EditorWindow
{
    static GameObject obj = null;
    static UnityEngine.Object[] objs;
    static Vector2 scroll = new Vector2();

    [MenuItem("Example/Collect Dependencies")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        CollectDependenciesExample window = (CollectDependenciesExample)EditorWindow.GetWindow(typeof(CollectDependenciesExample));
        window.Show();
    }

    void OnGUI()
    {
        obj = EditorGUILayout.ObjectField("Find Dependency", obj, typeof(GameObject), false) as GameObject;

        if (obj)
        {
            UnityEngine.Object[] roots = new UnityEngine.Object[] { obj };

            if (GUILayout.Button("Check Dependencies"))
            {
                objs = EditorUtility.CollectDependencies(roots);
                objs = EditorUtility.CollectDependencies(objs);
                objs = EditorUtility.CollectDependencies(objs);
                objs = EditorUtility.CollectDependencies(objs);
            }
            if (objs != null)
            {
                scroll = EditorGUILayout.BeginScrollView(scroll);
                for (int i = 0; i < objs.Length; i++)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField(objs[i].name);
                    EditorGUILayout.LabelField(AssetDatabase.GetAssetPath(objs[i]));
                    EditorGUILayout.EndHorizontal();
                }
                EditorGUILayout.EndScrollView();
            }
        }
        else
            EditorGUILayout.LabelField("Missing:", "Select an object first");
    }

    void OnInspectorUpdate()
    {
        Repaint();
    }
}