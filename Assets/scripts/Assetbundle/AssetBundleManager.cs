using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine.Networking;
using Object = UnityEngine.Object;

public class AssetBundleManager : MonoBehaviour, Serclimax.AssetbundleLoader
{
    #region 公开变量
    /// <summary>
    /// 检查更新ing
    /// </summary>
    public event BoolCallback isChecking;
    /// <summary>
    /// 下载百分比
    /// </summary>
    public event FloatCallback onCheckPercent;
    /// <summary>
    /// 已下载/总共资源包数量
    /// </summary>
    public event StringCallback onBundleLoad;
    /// <summary>
    /// 释放资源包延迟时间
    /// </summary>
    public float releaseTime = 0;
    /// <summary>
    /// 需要重新检查更新回调
    /// </summary>
    public event BoolCallback isNeedRecheck;
    public bool needReload = false;
    #endregion

    #region 私有变量
    [Serializable]
    class VersionItem
    {
        public string mName;
        public string mVersion;
        public string mMd5;
        public string mSize;
        public string mNeed;
    }
    private string serverPath = AssetsUtility.SERVERPATH;
    private string version = "";
    private Dictionary<string, object> assetTable;
    /// <summary>
    /// 已读取的缓存资源包（非更新读取）
    /// </summary>
    private Dictionary<string, AssetBundle> bundles;
    /// <summary>
    /// 本地版本
    /// </summary>
    private Dictionary<string, VersionItem> versions;
    /// <summary>
    /// 服务器版本
    /// </summary>
    private Dictionary<string, VersionItem> serverVersions;
    /// <summary>
    /// 需要下载的
    /// </summary>
    private Queue<VersionItem> needDownload;
    /// <summary>
    /// 需要下载总量
    /// </summary>
    private float total;
    /// <summary>
    /// 当前下载的量
    /// </summary>
    private float current;
    /// <summary>
    /// 需要下载大小总量
    /// </summary>
    private string totalSize = "";
    /// <summary>
    /// 释放缓存资源倒计时时钟
    /// </summary>
    private float timer = 0;

    [SerializeField]
    private List<VersionItem> loadatfirst;
    
    [SerializeField]
    private List<VersionItem> loadingame;
    private static AssetBundleManager instance;

    enum AutoState
    {
        IDLE,
        AUTODOWNLOAD,
        END
    }
    private AutoState state;
    #endregion

    public bool ischecking = false;
    public delegate void WWWCallback(UnityWebRequest www);
    public delegate void StringCallback(string msg);
    public delegate void FloatCallback(float value);
    public delegate void BoolCallback(bool value);

    public static AssetBundleManager Instance
    {
        get
        {
            return instance;
        }
    }

    void Awake()
    {
        GetLocalVersions();
        bundles = new Dictionary<string, AssetBundle>();
        serverVersions = new Dictionary<string, VersionItem>();
        loadatfirst = new List<VersionItem>();
        loadingame = new List<VersionItem>();
        assetTable = new Dictionary<string, object>();
        needDownload = new Queue<VersionItem>();
        InitAssetTable();
        instance = this;
    }

    void Start()
    {

    }

    void Update()
    {
        switch (state)
        {
            case AutoState.IDLE:
                if (Main.Instance.IsInMainState() || Main.Instance.IsInBattleState())
                {
                    if (Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork && !ischecking)
                    {
                        state = AutoState.AUTODOWNLOAD;
                        DownLoadRemote();
                    }
                }
                break;
            case AutoState.AUTODOWNLOAD:
                if (Application.internetReachability != NetworkReachability.ReachableViaLocalAreaNetwork && ischecking)
                {
                    state = AutoState.END;
                    StopDownLoad();
                }
                if (!ischecking)
                {
                    state = AutoState.END;
                }
                break;
            case AutoState.END:
            default:
                break;
        }
    }

    void OnDestroy()
    {
        foreach (var item in bundles)
        {
            if (item.Value != null)
            {
                item.Value.Unload(false);
                Destroy(item.Value);
            }
        }
        bundles = null;
        serverVersions = null;
        loadatfirst = null;
        loadingame = null;
        assetTable = null;
        needDownload = null;
        Resources.UnloadUnusedAssets();
    }

    public void ClearDelegate()
    {
        if (onBundleLoad != null)
        {
            System.Delegate[] dels = onBundleLoad.GetInvocationList();
            for (int i = 0; i < dels.Length; i++)
            {
                onBundleLoad -= dels[i] as StringCallback;
            }
        }
        if (onCheckPercent != null)
        {
            System.Delegate[] dels = onCheckPercent.GetInvocationList();
            for (int i = 0; i < dels.Length; i++)
            {
                onCheckPercent -= dels[i] as FloatCallback;
            }
        }
        if (isChecking != null)
        {
            System.Delegate[] dels = isChecking.GetInvocationList();
            for (int i = 0; i < dels.Length; i++)
            {
                isChecking -= dels[i] as BoolCallback;
            }
        }
    }

    void InitAssetTable()
    {
        string s = null;
        if (AssetsUtility.EasyLoad(AssetsUtility.GetCachePath(), AssetsUtility.ASSETPATHTABLE, false, delegate (Stream stream, string filename)
        {
            s = AssetsUtility.GetStreamedString(stream);
            if (!string.IsNullOrEmpty(s))
            {
                return true;
            }
            return false;
        }))
        {
            assetTable = OurMiniJSON.Json.Deserialize(s) as Dictionary<string, object>;
        }
    }

    /// <summary>
    /// 读取本地版本信息
    /// </summary>
    private void GetLocalVersions()
    {
        if (!AssetsUtility.EasyLoad(AssetsUtility.GetCachePath(), AssetsUtility.ASSETVERSIONS, false, LoadLocalVersionCallback))
        {
            versions = new Dictionary<string, VersionItem>();
            AssetsUtility.EasySave(AssetsUtility.GetCachePath(), AssetsUtility.ASSETVERSIONS, false, SaveVersion);
        }
    }

    public void DeleteAllAssetBundles()
    {
        DeleteAssetBundleFile();
        GameSetting.instance.option.mResVersion = "";
        GameSetting.instance.SaveOption();
        versions.Clear();
        TextManager.Instance.Clear();
        Application.UnloadLevel(0);
        Application.LoadLevel(0);
    }

    private void DeleteAssetBundleFile()
    {
        string path = AssetsUtility.GetCachePath();
        if (Directory.Exists(path))
        {
            Directory.Delete(path, true);
        }
    }

    /// <summary>
    /// 读取本地版本信息回调
    /// </summary>
    /// <param name="stream">读取的stream</param>
    /// <returns></returns>
    private bool LoadLocalVersionCallback(Stream stream, string filename)
    {
        versions = new Dictionary<string, VersionItem>();
        string s = AssetsUtility.GetStreamedString(stream);
        Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(s) as Dictionary<string, object>;
        if (GameEnviroment.NETWORK_ENV != GameEnviroment.EEnviroment.eDebug)
        {
            if (!((string)data["exeVer"]).Equals(GameVersion.EXE) || !((string)data["buildVer"]).Equals(GameVersion.BUILD))
            {
                DeleteAllAssetBundles();
                return false;
            }
        }
        List<object> assets = data["assets"] as List<object>;
        for (int i = 0; i < assets.Count; i++)
        {
            var temp = (Dictionary<string, object>)assets[i];
            versions.Add(temp["name"] as string, new VersionItem() { mName = temp["name"] as string, mVersion = temp["version"] as string, mMd5 = temp["md5"] as string, mSize = temp["size"] as string, mNeed = temp["need"] as string });
        }
        return true;
    }

    public void SetVersion(string _version)
    {
        if (string.IsNullOrEmpty(_version))
            return;
        GameSetting.instance.option.mResVersion = _version;
        GameSetting.instance.SaveOption();
        version = _version + ".";
    }

    /// <summary>
    /// 开始检测更新
    /// </summary>
    public void CheckAssets()
    {
        //CheckAssets(AssetsUtility.SERVERPATH);
    }

    /// <summary>
    /// 开始检测更新
    /// </summary>
    /// <param name="serverPath">服务器资源路径</param>
    public void CheckAssets(string _serverPath)
    {
        serverPath = _serverPath + GameVersion.EXE + "/" + GameVersion.BUILD + "/";
        //Debug.LogError("server path: " + serverPath);
        if (isChecking != null)
        {
            isChecking(true);
        }
        ischecking = true;
        if (onBundleLoad != null)
        {
            onBundleLoad(TextManager.Instance.GetText("update_ui1"));
        }
        current = 0;
        total = 0;
        StartCoroutine(LoadAssetList(serverPath + version + AssetsUtility.ASSETVERSIONS, VersionAssetCallback));
        StartCoroutine(LoadAssetList(serverPath + version + AssetsUtility.ASSETPATHTABLE, delegate (UnityWebRequest www)
        {
            if (www.isDone && www.error == null)
            {
                AssetsUtility.EasySave(AssetsUtility.GetCachePath(), AssetsUtility.ASSETPATHTABLE, false, delegate (Stream stream, string filename)
                {
                    stream.Write(www.downloadHandler.data, 0, www.downloadHandler.data.Length);
                    return true;
                });
                string s = www.downloadHandler.text;
                assetTable = OurMiniJSON.Json.Deserialize(s) as Dictionary<string, object>;
            }
        }));
    }

    public string GetNeedLoadSize()
    {
        float size = 0;
        foreach (var item in loadingame)
        {
            size += int.Parse(item.mSize);
        }
        string s = "";
        if (size > 0)
        {
            size /= 1048576;
            s = size.ToString("F2") + "M";
            return s;
        }
        else
        {
            return s;
        }
    }

    public void StopDownLoad() { needDownload.Clear(); }

    public string GetTotalSize()
    {
        return totalSize;
    }

    /// <summary>
    /// 比对本地与服务器版本信息
    /// </summary>
    /// <param name="www">从服务器读取的信息</param>
    private void VersionAssetCallback(UnityWebRequest www)
    {
        if (www.isDone && www.error != null)
        {
            Debug.LogWarning(www.error);
            ischecking = false;
            if (isChecking != null)
            {
                isChecking(false);
            }
            return;
        }
        string s = www.downloadHandler.text;
        AssetsUtility.EasySave(AssetsUtility.GetCachePath(), AssetsUtility.SERVERVERSIONS, false, delegate (Stream stream, string filename)
        {
            byte[] b = System.Text.Encoding.UTF8.GetBytes(s);
            stream.Write(b, 0, b.Length);
            return true;
        });
        MakeDownloadList(s);
        if (loadingame.Count > 0)
        {
            PlayerPrefs.SetString("NeedRemote", "1");
            PlayerPrefs.Save();
        }
        needDownload = new Queue<VersionItem>(loadatfirst);
        StartLoad();
    }

    private void StartLoad()
    {
        //total = needDownload.Count;
        ischecking = true;
        if (needDownload.Count > 0)
        {
            StartCoroutine(LoadAssetBundle(needDownload.Dequeue(), AssetbundleCallback, ManifestCallback));
        }
        else
        {
            ischecking = false;
            if (isChecking != null)
            {
                isChecking(false);
            }
        }
    }

    public void DownLoadRemote()
    {
        needDownload = new Queue<VersionItem>(loadingame);
        StartLoad();
    }

    public void CheckRemote()
    {
        string s = null;
        if (AssetsUtility.EasyLoad(AssetsUtility.GetCachePath(), AssetsUtility.SERVERVERSIONS, false, delegate (Stream stream, string filename)
          {
              s = AssetsUtility.GetStreamedString(stream);
              if (!string.IsNullOrEmpty(s))
              {
                  return true;
              }
              return false;
          }))
        {
            MakeDownloadList(s);
        }
    }

    private void MakeDownloadList(string s)
    {
        serverVersions.Clear();
        loadatfirst.Clear();
        loadingame.Clear();
        float tsize = 0;
        Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(s) as Dictionary<string, object>;
        if (data == null)
        {
            return;
        }
        List<object> assets = data["assets"] as List<object>;
        for (int i = 0; i < assets.Count; i++)
        {
            var temp = (Dictionary<string, object>)assets[i];
            serverVersions.Add(temp["name"] as string, new VersionItem() { mName = temp["name"] as string, mVersion = temp["version"] as string, mMd5 = temp["md5"] as string, mSize = temp["size"] as string, mNeed = temp["need"] as string });
        }

        if (versions.Count == 0)
        {
            PlayerPrefs.DeleteKey("NeedRemote");
            PlayerPrefs.Save();
            List<string> snames = new List<string>(serverVersions.Keys);
            for (int i = 0; i < snames.Count; i++)
            {
                if (serverVersions[snames[i]].mNeed == "1")
                {
                    loadatfirst.Add(serverVersions[snames[i]]);
                    tsize += int.Parse(serverVersions[snames[i]].mSize);
                }
                else
                {
                    loadingame.Add(serverVersions[snames[i]]);
                }
            }
        }
        else
        {
            List<string> snames = new List<string>(serverVersions.Keys);
            List<string> lnames = new List<string>(versions.Keys);
            for (int i = lnames.Count - 1; i > 0; --i)
            {
                if (!snames.Contains(lnames[i]))
                {
                    AssetsUtility.EasyDeleteFile(AssetsUtility.GetCachePath(), lnames[i]);
                    lnames.RemoveAt(i);
                }
            }
            for (int i = 0; i < snames.Count; i++)
            {
                if (versions.ContainsKey(snames[i]))
                {
                    if (versions[snames[i]].mMd5 == serverVersions[snames[i]].mMd5)
                    {
                        serverVersions.Remove(snames[i]);
                    }
                    else if (string.IsNullOrEmpty(serverVersions[snames[i]].mMd5))
                    {
                        serverVersions.Remove(snames[i]);
                        versions.Remove(snames[i]);
                        AssetsUtility.EasyDeleteFile(AssetsUtility.GetCachePath(), snames[i]);
                        AssetsUtility.EasyDeleteFile(AssetsUtility.GetCachePath(), snames[i] + ".manifest");
                        AssetsUtility.EasySave(AssetsUtility.GetCachePath(), AssetsUtility.ASSETVERSIONS, false, SaveVersion);
                    }
                    else
                    {
                        if (serverVersions[snames[i]].mNeed == "1")
                        {
                            loadatfirst.Add(serverVersions[snames[i]]);
                            tsize += int.Parse(serverVersions[snames[i]].mSize);
                        }
                        else
                        {
                            loadingame.Add(serverVersions[snames[i]]);
                        }
                        AssetsUtility.EasyDeleteFile(AssetsUtility.GetCachePath(), snames[i]);
                        AssetsUtility.EasyDeleteFile(AssetsUtility.GetCachePath(), snames[i] + ".manifest");
                    }
                }
                else if (serverVersions[snames[i]].mNeed == "1")
                {
                    loadatfirst.Add(serverVersions[snames[i]]);
                    tsize += int.Parse(serverVersions[snames[i]].mSize);
                }
                else
                {
                    loadingame.Add(serverVersions[snames[i]]);
                }
            }
        }
        if (tsize > 0)
        {
            total = tsize;
            tsize /= 1048576;
            totalSize = tsize.ToString("F2") + "M";
        }
    }

    private void AssetbundleCallback(UnityWebRequest www)
    {
        try
        {
            string bname = www.url.Replace(serverPath, "");
            //bname = bname.Substring(bname.IndexOf(".") + 1);
            string path = AssetsUtility.GetCachePath() +
                          (bname.LastIndexOf("/") > -1 ? bname.Substring(0, bname.LastIndexOf("/") + 1) : "");
            string sname = bname.Substring(bname.LastIndexOf("/") + 1);
            if (AssetsUtility.EasySave(path, sname, false, delegate(Stream stream, string filename)
                {
                    stream.Write(www.downloadHandler.data, 0, www.downloadHandler.data.Length);
                    return true;
                }))
            {
                if (versions.ContainsKey(bname))
                {
                    versions[bname] = serverVersions[bname];
                }
                else
                {
                    versions.Add(bname, serverVersions[bname]);
                }

                AssetsUtility.EasySave(AssetsUtility.GetCachePath(), AssetsUtility.ASSETVERSIONS, false, SaveVersion);
            }

            if (GUIMgr.Instance.FindMenu("login") != null)
            {
                needReload = true;
            }
        }
        catch (KeyNotFoundException e)
        {
            Debug.LogError("Error " +e);
        }
    }

    private void ManifestCallback(UnityWebRequest www)
    {
        string bname = www.url.Replace(serverPath, "");
        bname = bname.Substring(bname.IndexOf(".") + 1);
        string path = AssetsUtility.GetCachePath() + (bname.LastIndexOf("/") > -1 ? bname.Substring(0, bname.LastIndexOf("/") + 1) : "");
        string sname = bname.Substring(bname.LastIndexOf("/") + 1);
        AssetsUtility.EasySave(path, sname, false, delegate (Stream stream, string filename)
        {
            stream.Write(www.downloadHandler.data, 0, www.downloadHandler.data.Length);
            return true;
        });
    }

    private bool SaveVersion(Stream stream, string filename)
    {
        Dictionary<string, object> data = new Dictionary<string, object>();
        data["exeVer"] = GameVersion.EXE;
        data["buildVer"] = GameVersion.BUILD;
        List<Dictionary<string, object>> infos = new List<Dictionary<string, object>>();
        List<string> l = new List<string>(versions.Keys);
        for (int i = 0; i < l.Count; i++)
        {
            Dictionary<string, object> info = new Dictionary<string, object>();
            info["name"] = versions[l[i]].mName;
            info["version"] = versions[l[i]].mVersion;
            info["md5"] = versions[l[i]].mMd5;
            info["size"] = versions[l[i]].mSize;
            info["need"] = versions[l[i]].mNeed;
            infos.Add(info);
        }
        data["assets"] = infos.ToArray();
        byte[] b = System.Text.Encoding.UTF8.GetBytes(OurMiniJSON.Json.Serialize(data));
        stream.Write(b, 0, b.Length);
        return true;
    }

    /// <summary>
    /// 读取本地资源（完整路径版）
    /// </summary>
    /// <typeparam name="T">资源类型</typeparam>
    /// <param name="fullpath">资源完整路径（包名/资源名）</param>
    /// <param name="error">错误信息回调</param>
    /// <returns>返回读取成功的资源</returns>
    public T LoadAsset<T>(string fullpath, StringCallback error = null) where T : Object
    {
        if (assetTable == null)
        {
            return null;
        }
        fullpath = fullpath.ToLower();
        if (assetTable.ContainsKey(fullpath))
        {
            string _path = assetTable[fullpath] as string;
            string _name = fullpath.Substring(fullpath.LastIndexOf("/") + 1);
            if (fullpath.StartsWith("lua/"))
            {
#if UNITY_5
                _name += ".bytes";
#endif
            }
            return LoadAsset<T>(_path, _name, error);
        }
        return null;
    }

    /// <summary>
    /// 读取本地资源
    /// </summary>
    /// <typeparam name="T">资源类型</typeparam>
    /// <param name="bundleName">资源包名字</param>
    /// <param name="assetName">资源名字</param>
    /// <param name="error">错误信息回调</param>
    /// <returns>返回读取成功的资源</returns>
    public T LoadAsset<T>(string bundleName, string assetName, StringCallback error = null) where T : Object
    {
        bundleName = bundleName.Replace(" ", "");
        AssetBundle ab = LoadAssetBundle(bundleName, error);
        T o = null;
        if (ab == null)
        {
            return null;
        }
        o = ab.LoadAsset<T>(assetName);
        if (o == null)
        {
            if (error != null)
            {
                error(string.Format(TextManager.Instance.GetText("update_ui2"), bundleName, assetName));
            }
        }
        return o;
    }

    public AssetBundle LoadAssetBundle(string bundleName, StringCallback error = null)
    {
        bundleName = bundleName.ToLower();
        AssetBundle ab;
        AssetBundleManifest abm = null;
        if (!bundles.TryGetValue(AssetsUtility.ASSETBUNDLE, out ab))
        {
            ab = LoadMainManifest(error, ab);
        }
        else if (ab == null)
        {
            ab = LoadMainManifest(error, ab);
        }
        if (ab == null)
        {
            if (error != null)
            {
                error(TextManager.Instance.GetText("update_ui3"));
            }
            return null;
        }
        timer = releaseTime;
        abm = ab.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        if (abm != null)
        {
            if (!GetDependencies(bundleName, error, abm))
            {
                return null;
            }
            if (!bundles.TryGetValue(bundleName, out ab))
            {
                bundles[bundleName] = GetLocalAssetbundle(bundleName, error);
                ab = bundles[bundleName];
            }
            if (bundles[bundleName] == null)
            {
                bundles.Remove(bundleName);
            }
        }
        else
        {
            if (error != null)
            {
                error(TextManager.Instance.GetText("update_ui4"));
            }
        }
        return ab;
    }

    private bool GetDependencies(string bundleName, StringCallback error, AssetBundleManifest abm)
    {
        bool loadok = true;
        bundleName = bundleName.Replace(" ", "");
        string[] loadlist = abm.GetDirectDependencies(bundleName);
        for (int i = 0; i < loadlist.Length; i++)
        {
            if (!bundles.ContainsKey(loadlist[i]))
            {
                bundles[loadlist[i]] = GetLocalAssetbundle(loadlist[i], error);
                if (bundles[loadlist[i]] == null)
                {
                    loadok &= false;
                }
                else
                {
                    bundles[loadlist[i]].LoadAllAssets();
                    loadok &= GetDependencies(loadlist[i], error, abm);
                }
            }
        }
        return loadok;
    }

    private AssetBundle LoadMainManifest(StringCallback error, AssetBundle ab)
    {
        bundles[AssetsUtility.ASSETBUNDLE] = GetLocalAssetbundle(AssetsUtility.ASSETBUNDLE + ".unity3d", error);
        if (timer <= 0 && releaseTime > 0)
        {
            timer = releaseTime;
            StartCoroutine(ReleaseAsset());
        }
        ab = bundles[AssetsUtility.ASSETBUNDLE];
        return ab;
    }

    IEnumerator ReleaseAsset()
    {
        do
        {
            timer -= Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
        while (timer > 0);
        if (timer <= 0)
        {
            foreach (var item in bundles)
            {
                if (item.Value != null)
                {
                    item.Value.Unload(false);
                    Destroy(item.Value);
                }
            }
            bundles.Clear();
            Debug.Log("释放已加载的Assetbundle");
        }
    }

    private AssetBundle GetLocalAssetbundle(string bundleName, StringCallback error)
    {
        AssetBundle bundle = null;
        string path = AssetsUtility.GetCachePath();
        //Debug.LogError("Path + " + path);
        if (!AssetsUtility.EasyLoad(AssetsUtility.GetCachePath(), bundleName, false, delegate (Stream stream, string filename)
        {
            byte[] b = new byte[stream.Length];
            stream.Read(b, 0, b.Length);
            bundle = AssetBundle.LoadFromMemory(b);
            return bundle != null;
            
        }))
        {
            if (error != null)
            {
                error(string.Format(TextManager.Instance.GetText("update_ui5"), bundleName));
            }
            if (versions.ContainsKey(bundleName))
            {
                versions.Remove(bundleName);
                AssetsUtility.EasySave(AssetsUtility.GetCachePath(), AssetsUtility.ASSETVERSIONS, false, SaveVersion);
            }
            if (serverVersions == null || serverVersions.Count == 0)
            {
                CheckRemote();
            }
            if (serverVersions != null && serverVersions.ContainsKey(bundleName))
            {
                if (!needDownload.Contains(serverVersions[bundleName]))
                {
                    needDownload.Enqueue(serverVersions[bundleName]);
                }
                PlayerPrefs.SetString("NeedRemote", "1");
                PlayerPrefs.Save();
                if (!ischecking)
                {
                    StartLoad();
                    if (isNeedRecheck != null)
                    {
                        isNeedRecheck(true);
                    }
                }
            }
        }
        return bundle;
    }

    IEnumerator LoadAssetBundle(VersionItem versionItem, WWWCallback callback, WWWCallback manifestcallback)
    {
        UnityWebRequest www = new UnityWebRequest(serverPath + versionItem.mName + ".manifest");
        Coroutine c = null;
        yield return www;
        if (www.isDone)
        {
            if (manifestcallback != null)
            {
                manifestcallback(www);
            }
            www.Dispose();
        }
        www = new UnityWebRequest(serverPath + versionItem.mName);
        //current++;
        if (onBundleLoad != null)
        {
            //onBundleLoad(string.Format(TextManager.Instance.GetText("update_ui6"), Mathf.Clamp(current, 0, total), total, totalSize));
        }
        if (onCheckPercent != null)
        {
            c = StartCoroutine(ShowProgress(www, float.Parse(versionItem.mSize)));
        }
        yield return www;
        if (www.isDone)
        {
            string md5 = AssetsUtility.GetMd5Hash(www.downloadHandler.data);
            if (!md5.Equals(versionItem.mMd5))
            {
                if (onBundleLoad != null)
                {
                    //onBundleLoad(string.Format(TextManager.Instance.GetText("update_ui7"), current));
                }
                //current--;
                needDownload.Enqueue(versionItem);
            }
            else
            {
                if (callback != null)
                {
                    callback(www);
                }
                current += int.Parse(versionItem.mSize);
            }
            www.Dispose();
        }
        if (c != null)
        {
            StopCoroutine(c);
        }

        if (needDownload.Count > 0)
        {
            StartCoroutine(LoadAssetBundle(needDownload.Dequeue(), AssetbundleCallback, ManifestCallback));
        }
        else
        {
            CheckRemote();
            if (onCheckPercent != null)
            {
                onCheckPercent(1);
            }
            ischecking = false;
            if (isChecking != null)
            {
                isChecking(false);
            }
            total = 0;
        }
    }

    IEnumerator LoadAssetList(string path, WWWCallback callback)
    {
        UnityWebRequest www = new UnityWebRequest(path);
        www.downloadHandler = new DownloadHandlerBuffer();
        www.SendWebRequest();
        yield return www;
        if (www.isDone)
        {
            if (callback != null)
            {
                callback(www);
            }
        }
        www.Dispose();
    }

    IEnumerator ShowProgress(UnityWebRequest www, float size)
    {
        //float step = (float)1 / total;
        while (www != null && !www.isDone && www.downloadProgress <= 1)
        {
            //onCheckPercent(step * (current - 1 + www.progress));
            onCheckPercent((current + size * www.downloadProgress) / total);
            yield return new WaitForEndOfFrame();
        }
    }

    public T LoadAssetData<T>(string fullpath) where T : Object
    {
        return instance.LoadAsset<T>(fullpath);
    }
}