using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;

public class UITextureChangeTool : Editor
{
    static string APPLICATION_PATH = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf('/') + 1);

    [MenuItem("Assets/UI贴图RGBA分离/创建Alpha通道分离的ATLAS")]
    public static void ChangeTextures()
    {
        UnityEngine.Object[] arr = Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.TopLevel);
        string selectedPath = APPLICATION_PATH + AssetDatabase.GetAssetPath(arr[0]);
        ChangeTextures(selectedPath);
    }

    public static void ChangeTextures(string selectedPath, bool bTip = true)
    {
        List<GameObject> atlass = new List<GameObject>();
        GetAssets(selectedPath, atlass);
        float total = atlass.Count;
        float current = 0;
        for (int i = 0; i < atlass.Count; i++)
        {
            current++;
            EditorUtility.DisplayProgressBar("RGBA分离工具", string.Format("总共{0}个Atlas，正在处理第{1}个...", total, current), current / total);
            Material spriteMaterial = atlass[i].GetComponent<UIAtlas>().spriteMaterial;
            if (spriteMaterial.shader.name.Contains("Particles/"))
            {
                continue;
            }
            string name = atlass[i].gameObject.name;
            string path = AssetDatabase.GetAssetPath(atlass[i]);
            path = path.Substring(0, path.LastIndexOf('/') + 1);
            string sourcePath = path + name + ".png";

            TextureImporter ti = AssetImporter.GetAtPath(sourcePath) as TextureImporter;
            ti.isReadable = true;
            AssetDatabase.ImportAsset(sourcePath, ImportAssetOptions.ImportRecursive);

            Texture2D source = AssetDatabase.LoadAssetAtPath<Texture2D>(sourcePath);
            Color[] colors = source.GetPixels();

            Texture2D rgbT = new Texture2D(source.width, source.height, TextureFormat.RGB24, false);
            rgbT.SetPixels(colors);
            rgbT.Apply();
            string rgbPath = path + name + "_rgb.png";
            File.WriteAllBytes(rgbPath, rgbT.EncodeToPNG());
            AssetDatabase.ImportAsset(rgbPath, ImportAssetOptions.ImportRecursive);

            ti = AssetImporter.GetAtPath(rgbPath) as TextureImporter;
            ti.mipmapEnabled = false;
            ti.isReadable = true;
            AssetDatabase.ImportAsset(rgbPath, ImportAssetOptions.ImportRecursive);

            Texture2D alphaT = new Texture2D(source.width, source.height, TextureFormat.RGB24, false);
            Color[] alphas = new Color[colors.Length];
            for (int j = 0; j < colors.Length; j++)
            {
                alphas[j].r = colors[j].a;
                alphas[j].g = colors[j].a;
                alphas[j].b = colors[j].a;
            }
            alphaT.SetPixels(alphas);
            alphaT.Apply();
            string alphaPath = path + name + "_a.png";
            File.WriteAllBytes(alphaPath, alphaT.EncodeToPNG());
            AssetDatabase.ImportAsset(alphaPath, ImportAssetOptions.ImportRecursive);

            ti = AssetImporter.GetAtPath(alphaPath) as TextureImporter;
            ti.mipmapEnabled = false;
            ti.isReadable = true;
            AssetDatabase.ImportAsset(alphaPath, ImportAssetOptions.ImportRecursive);
            
            spriteMaterial.shader = Shader.Find("Unlit/Transparent Colored ETC1");
            spriteMaterial.SetTexture("_MainTex", AssetDatabase.LoadAssetAtPath<Texture>(rgbPath));
            spriteMaterial.SetTexture("_MainTex_A", AssetDatabase.LoadAssetAtPath<Texture>(alphaPath));
        }
        EditorUtility.ClearProgressBar();
        if (bTip)
        {
            EditorUtility.DisplayDialog("提示", "已处理完成目录下所有Atlas图片~XD", "确定");
        }
    }

    [MenuItem("Assets/UI贴图RGBA分离/恢复初始状态")]
    public static void Recover()
    {
        UnityEngine.Object[] arr = Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.TopLevel);
        string selectedPath = APPLICATION_PATH + AssetDatabase.GetAssetPath(arr[0]);
        Recover(selectedPath);
    }

    public static void Recover(string selectedPath, bool bTip = true)
    {
        List<GameObject> atlass = new List<GameObject>();
        GetAssets(selectedPath, atlass);
        for (int i = 0; i < atlass.Count; i++)
        {
            Material spriteMaterial = atlass[i].GetComponent<UIAtlas>().spriteMaterial;
            if (spriteMaterial.shader.name.Contains("Particles/"))
            {
                continue;
            }
            string name = atlass[i].gameObject.name;
            string path = AssetDatabase.GetAssetPath(atlass[i]);
            path = path.Substring(0, path.LastIndexOf('/') + 1);
            string sourcePath = path + name + ".png";
            spriteMaterial.shader = Shader.Find("Unlit/Transparent Colored");
            spriteMaterial.SetTexture("_MainTex", AssetDatabase.LoadAssetAtPath<Texture>(sourcePath));
            string rgbPath = path + name + "_rgb.png";
            string alphaPath = path + name + "_a.png";
            //File.Delete(rgbPath);
            //File.Delete(alphaPath);

            AssetDatabase.DeleteAsset(rgbPath);
            AssetDatabase.DeleteAsset(alphaPath);
        }
        if (bTip)
        {
            EditorUtility.DisplayDialog("提示", "已恢复NGUI标准贴图", "确定");
        }        
    }

    static void GetAssets(string pathname, List<GameObject> assets)
    {
        string[] subFiles = Directory.GetFiles(pathname);
        foreach (string subFile in subFiles)
        {
            UIAtlas t = AssetDatabase.LoadAssetAtPath<UIAtlas>(subFile.Replace(APPLICATION_PATH, ""));
            if (t)
            {
                if (!t.name.Contains("fonts") && t != null)
                {
                    assets.Add(t.gameObject);
                }
            }
        }

        string[] subDirs = Directory.GetDirectories(pathname);
        foreach (string subDir in subDirs)
        {
            GetAssets(subDir, assets);
        }
    }

    [MenuItem("Tools/ClearPlayerPrefs")]
    static void ClearPlayerPrefs()
    {
        PlayerPrefs.DeleteAll();
        PlayerPrefs.Save();
    }
}

class UnUsedPrefabsChecker : EditorWindow
{
    static UnUsedPrefabsChecker window;
    static string APPLICATION_PATH = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf('/') + 1);
    static List<string> IgnorePathList;
    bool inited = false;
    Vector2 scroll;
    List<UnityEngine.Object> unusedObj;

    List<string> unusedPath;

    [MenuItem("Tools/未使用资源比对筛选")]
    static void CheckUnUsedPrefabs()
    {
        if (window != null)
        {
            window.Close();
        }
        window = EditorWindow.GetWindow<UnUsedPrefabsChecker>();
        window.titleContent = new GUIContent("未使用资源比对筛选");
        window.minSize = new Vector2(1280, 640);
        window.Init();
        window.Show();
        window.ShowUtility();
    }

    private void Init()
    {
        IgnorePathList = new List<string>();
        LoadRecords();
        inited = true;
    }

    private class Record
    {
        public string path;
        public int usetimes;
    }

    private static Dictionary<string, Record> records;

    private static void LoadRecords()
    {
        string filepath = "D:/ResourceUsedRecord.csv";
        records = new Dictionary<string, Record>();
        if (!File.Exists(filepath))
        {
            File.Create(filepath);
        }
        else
        {
            string[] alllines = File.ReadAllLines(filepath);
            foreach (var item in alllines)
            {
                string[] strs = item.Split(',');
                records.Add(strs[0], new Record() { path = strs[0], usetimes = int.Parse(strs[1]) });
            }
        }
    }

    static string GetSelectedPath()
    {
        string selectedPath = EditorUtility.OpenFolderPanel("AddFolder", Application.dataPath, "");
        if (selectedPath.Contains("Resources/"))
        {
            return selectedPath.Substring(selectedPath.LastIndexOf("Resources/") + 10);
        }
        else
        {
            return "";
        }
    }

    void OnGUI()
    {
        if (EditorApplication.isCompiling || !inited) return;
        GUILayout.BeginArea(new Rect(0, 0, 1280, 640));
        GUILayout.Space(10);
        GUILayout.BeginHorizontal();
        {
            //if (GUILayout.Button("添加忽略路径", GUILayout.Width(80)))
            //{
            //    string path = GetSelectedPath();
            //    if (!IgnorePathList.Contains(path) && !string.IsNullOrEmpty(path))
            //    {
            //        IgnorePathList.Add(path);
            //    }
            //}
            
            if (GUILayout.Button("进行比对", GUILayout.Width(80)))
            {
                string[] files = Directory.GetFiles(Application.dataPath, "*.*", SearchOption.AllDirectories);
                List<string> fileList = new List<string>(files);
                for (int i = fileList.Count - 1 ; i >= 0; i--)
                {
                    EditorUtility.DisplayProgressBar("进行比对", "比对路径中", (float)(fileList.Count - i) / fileList.Count);
                    if (fileList[i].Contains("Resources\\") && !fileList[i].Contains(".meta"))
                    {
                        string path = fileList[i].Substring(fileList[i].IndexOf("Resources\\") + 10).Replace("\\", "/");
                        path = path.Substring(0, path.LastIndexOf('.'));
                        foreach (var item in records)
                        {
                            if (path.ToLower().Equals(item.Value.path.ToLower()))
                            {
                                fileList.RemoveAt(i);
                            }
                        }
                    }
                    else
                    {
                        fileList.RemoveAt(i);
                    }
                }
                unusedObj = new List<UnityEngine.Object>();
                for (int i = 0; i < fileList.Count; i++)
                {
                    EditorUtility.DisplayProgressBar("进行比对", "查找未引用文件", (float)i / fileList.Count);
                    fileList[i] = fileList[i].Substring(fileList[i].IndexOf("Assets")).Replace("\\", "/");
                    unusedObj.Add(AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(fileList[i]));
                }
                int year = System.DateTime.Now.Year - 2000;
                string sVersion = year.ToString() +
                    System.DateTime.Now.Month.ToString("d2") +
                    System.DateTime.Now.Day.ToString("d2") +
                    System.DateTime.Now.Hour.ToString("d2") +
                    System.DateTime.Now.Minute.ToString("d2");
                string filepath = string.Format("D:/UnUsedResources_{0}.csv", sVersion);
                
                File.WriteAllLines(filepath, fileList.ToArray());
                EditorUtility.ClearProgressBar();
            }
            if (unusedPath == null)
            {
                if (GUILayout.Button("读取未引用资源列表", GUILayout.Width(160)))
                {
                    string filepath = EditorUtility.OpenFilePanel("读取未引用资源列表", "D:/", "*.*");
                    if (!string.IsNullOrEmpty(filepath))
                    {
                        unusedPath = new List<string>(File.ReadAllLines(filepath));
                    }
                }
            }
            else
            {
                if (GUILayout.Button("追加读取未引用资源列表", GUILayout.Width(160)))
                {
                    string filepath = EditorUtility.OpenFilePanel("读取未引用资源列表", "D:/", "*.*");
                    if (!string.IsNullOrEmpty(filepath))
                    {
                        string[] unusedlist = File.ReadAllLines(filepath);
                        string[] lastlist = unusedPath.ToArray();
                        unusedPath.Clear();
                        for (int i = 0; i < unusedlist.Length; i++)
                        {
                            EditorUtility.DisplayProgressBar("进行比对", "查找重复未引用路径", (float)i / unusedlist.Length);
                            for (int j = 0; j < lastlist.Length; j++)
                            {
                                if (unusedlist[i] == lastlist[j])
                                {
                                    unusedPath.Add(unusedlist[i]);
                                }
                            }
                        }
                    }
                    EditorUtility.ClearProgressBar();
                }
                if (GUILayout.Button("加载从未引用的资源", GUILayout.Width(160)))
                {
                    unusedObj = new List<UnityEngine.Object>();
                    for (int i = 0; i < unusedPath.Count; i++)
                    {
                        EditorUtility.DisplayProgressBar("进行比对", "查找未引用文件", (float)i / unusedPath.Count);
                        unusedObj.Add(AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(unusedPath[i]));
                    }
                    EditorUtility.ClearProgressBar();
                }
            }
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(10);
        GUILayout.BeginVertical();
        {
            //GUILayout.Label("忽略列表", GUILayout.Width(250));
            //for (int i = 0; i < IgnorePathList.Count; i++)
            //{
            //    GUILayout.Label(IgnorePathList[i]);
            //}
        }
        GUILayout.EndVertical();

        scroll = GUILayout.BeginScrollView(scroll);
        if (unusedObj != null)
        {
            for (int i = 0; i < unusedObj.Count; i++)
            {
                EditorGUILayout.ObjectField(unusedObj[i], typeof(UnityEngine.Object), false);
            }
        }
        GUILayout.EndScrollView();

        GUILayout.EndArea();
    }

    void OnDestroy()
    {
        IgnorePathList = null;
        unusedObj = null;
    }
}
