using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using LuaInterface;

public class GUIMgr : MonoBehaviour
{
    private Dictionary<string, string> menuList;

    private Transform mUiRoot = null;
    private Transform mUiTopRoot = null;

    public delegate void OnMenuCreate(string menuName);

    public OnMenuCreate onMenuCreate;

    public delegate void OnMenuOpen(string menuName);

    public OnMenuCreate onMenuOpen;

    public delegate void OnMenuClose(string menuName);

    public OnMenuClose onMenuClose;

    public delegate void OnTutorialTriggered(string menuName);

    public OnTutorialTriggered onTutorialTriggered;

    public delegate void OnSocialCallback(string data);

    public OnSocialCallback onSocialCallback;


    public delegate void OnCheckChatMsgCallback(int success , string resContent);

    public OnCheckChatMsgCallback onCheckChatMsgCallback;

    public bool kickOff = false;

    public string targetLanguage;

    public Transform UIRoot
    {
        get
        {
            if (mUiRoot == null)
            {
                GameObject obj = GameObject.Find("UI Root");
                if (obj)
                {
                    mUiRoot = obj.transform;
                }
            }
            return mUiRoot;
        }
    }

    public Transform UITopRoot
    {
        get
        {
            if (mUiTopRoot == null)
            {
                GameObject obj = GameObject.Find("UI Top Root");
                if (obj)
                {
                    mUiTopRoot = obj.transform;
                }
            }
            return mUiTopRoot;
        }
    }
    private static GUIMgr instance;

    private Dictionary<string, LuaBehaviour> _dicBehaviour = new Dictionary<string, LuaBehaviour>();

    private GameObject luaConsole;

    public Clishow.CsPostEffect PostEffect = null;

    private string mPostEffectMenu = null;

    private List<string> mIgnoreEffectMenus = new List<string> { "InGameUI", "MainCityUI", "Tutorial", "WorldMap", "PVP_SLG", "TileInfo", "PathInfo", "ResBar" };
    private Dictionary<string, bool> mActiceMenuDic = new Dictionary<string, bool>();

    private Dictionary<string, GameObject> mUIPools = new Dictionary<string, GameObject>();

    //缓存的界面需要将界面上uisound组件关闭。不然会错误的播放音效
    private List<string> mApplyPoolUINames = new List<string> { "BattleMove", "Mail" };

    private Transform mSelfTrf = null;
    private Transform _selfTrf
    {
        get
        {
            if (mSelfTrf == null)
                mSelfTrf = this.transform;
            return mSelfTrf;
        }
    }
    public bool PushUIPool(string name, GameObject obj)
    {
        if (!mApplyPoolUINames.Contains(name))
            return false;
        if (!mUIPools.ContainsKey(name))
        {
            mUIPools.Add(name, obj);
        }

        if (obj.transform.parent != _selfTrf)
        {
            BindTrf(obj.transform, _selfTrf);
            obj.SetActive(false);

            if (obj.transform.GetComponent<UISound>() != null)
            {
                obj.transform.GetComponent<UISound>().enabled = true;
            }
        }

        return true;
    }

    private void BindTrf(Transform trf, Transform parent)
    {
        if (trf == null)
            return;
        trf.parent = parent;
        if (parent == null)
        {
            return;
        }
        trf.localPosition = Vector3.zero;
        trf.localRotation = Quaternion.identity;
        trf.localScale = Vector3.one;
    }

    private bool PopUIPool(string name, out GameObject obj)
    {
        obj = null;
        if (!mApplyPoolUINames.Contains(name))
            return false;

        if (!mUIPools.TryGetValue(name, out obj))
        {
            GameObject prefab = GetPrefabFromMenu(name);
            if (prefab != null)
            {
                obj = GameObject.Instantiate(prefab);
                obj.name = name;
                mUIPools.Add(name, obj);
            }
        }
        return true;
    }

    private void CachePool(string name)
    {
        GameObject obj = null;
        if (PopUIPool(name, out obj))
        {
            PushUIPool(name, obj);
        }
    }
    
    private void CachePoolAsync()
    {
        StartCoroutine(LoadAsync());
    }
    IEnumerator LoadAsync()
    {
        for(int i=0; i< mApplyPoolUINames.Count;i++)
        {
            string name = mApplyPoolUINames[i];
            GameObject obj = null;
            if (!mUIPools.TryGetValue(name, out obj))
            {
                string prefabName;
                if (menuList.TryGetValue(name, out prefabName))
                {
                    prefabName = "prefabs/" + prefabName;
                    ResourceRequest rq = Resources.LoadAsync<GameObject>(prefabName);
                    yield return rq;

                    if (rq != null)
                    {
                        if (rq.isDone)
                        {
                            obj = rq.asset as GameObject;
                            GameObject ui = GameObject.Instantiate(obj);
                            ui.name = name;
                            PushUIPool(name, ui);
                        }
                    }
                }
            }
        }
    }

    void Awake()
    {
        instance = this;
        Init();
    }

    public static GUIMgr Instance
    {
        get
        {
            return instance;
        }
    }
    public void AddActiveMenu(string menu)
    {
        if (mActiceMenuDic.ContainsKey(menu))
        {
            mActiceMenuDic[menu] = true;
            return;
        }

        mActiceMenuDic.Add(menu, true);
    }

    public void RemoveActiveMenu(string menu)
    {
        if (mActiceMenuDic.ContainsKey(menu))
        {
            mActiceMenuDic.Remove(menu);
        }
    }
    public void GetActiveMenuList()
    {
        string len = "menuCount:" + mActiceMenuDic.Count + "  act menu :";
        foreach (KeyValuePair<string, bool> kv in mActiceMenuDic)
        {
            len += kv.Key + " state :" + kv.Value + " . ";
        }
        Debug.Log(len);
    }
    public void ActiveMainCityUI()
    {
        /*foreach (KeyValuePair<string, bool> kv in mActiceMenuDic)
        {
            if (!kv.Key.Equals("ResBar") && !kv.Key.Equals("Notice_Tips") && !kv.Key.Equals("MainCityUI")
                && !kv.Key.Equals("MessageBox") && !kv.Key.Equals("Waiting"))
                    CloseMenu(kv.Key , 0);
        }*/
        List<LuaBehaviour> list = new List<LuaBehaviour>();
        List<string> nameList = new List<string>();
        int count = 0;
        foreach (string key in _dicBehaviour.Keys)
        {
            if (!key.Equals("ResBar") && !key.Equals("Notice_Tips") && !key.Equals("MainCityUI")
                && !key.Equals("MessageBox") && !key.Equals("Waiting") && !key.Equals("LuaConsole")
                && !key.Equals("WorldMap") && !key.Equals("MobaMain")&& !key.Equals("GuildWarMain"))
            {
                list.Add(_dicBehaviour[key]);
                nameList.Add(key);
                count++;
            }
        }

        for (int i = 0; i < count; i++)
        {
            if (onMenuClose != null)
            {
                onMenuClose(nameList[i]);
            }
            list[i].Close();
        }


        LuaBehaviour maincity = FindMenu("MainCityUI");
        if (maincity != null)
        {
            maincity.gameObject.SetActive(true);
            if (GameSetting.instance.option.mQualityLevel != 0)
            {
                if(PostEffect != null)
                    PostEffect.CloseBlurEffect();
            }
        }
        mPostEffectMenu = null;

    }

    public bool IsInMainCityUI()
    {
        GetActiveMenuList();
        foreach (KeyValuePair<string, bool> kv in mActiceMenuDic)
        {
            if (!kv.Key.Equals("ResBar") && !kv.Key.Equals("Notice_Tips") && !kv.Key.Equals("MainCityUI")
                && !kv.Key.Equals("MessageBox") && !kv.Key.Equals("Waiting") && !kv.Key.Equals("LuaConsole")
                 && !kv.Key.Equals("WorldMap") && !kv.Key.Equals("MobaMain")&& !kv.Key.Equals("GuildWarMain"))
                return false;
        }
        return true;
    }


    public void ToggleLuaConsole()
    {
        if (!FindMenu("LuaConsole"))
        {
            luaConsole = CreateMenu("LuaConsole", true).gameObject;
            luaConsole.transform.localPosition = new Vector3(0, 320, 0);
            luaConsole.gameObject.SetActive(false);
        }
        NGUITools.SetActive(luaConsole, !luaConsole.activeSelf);
        if (luaConsole.activeSelf)
        {
            BringForward(luaConsole.gameObject);
        }
    }

    public void ShowReporter()
    {
        GameObject reporter = GameObject.Find("Reporter");
        if (reporter != null)
        {
            reporter.GetComponent<Reporter>().Show();
        }
    }

    private void ShowGMMenu()
    {
        if (GameEnviroment.NETWORK_ENV != GameEnviroment.EEnviroment.eDist)
        {
            CreateMenu("GM", true);
        }
    }

    void Update()
    {
#if PROFILER
        Profiler.BeginSample("GUIMgr_Update");
#endif
        if (GameEnviroment.NETWORK_ENV != GameEnviroment.EEnviroment.eDist)
        {
            if (Input.GetKeyDown(KeyCode.BackQuote) && !Input.GetKey(KeyCode.LeftShift))
            {
                ToggleLuaConsole();
            }
        }

#if UNITY_EDITOR
        if (Input.GetKeyDown(KeyCode.Mouse1))
        {
            ShowGMMenu();
        }
#endif
        if (GameEnviroment.NETWORK_ENV != GameEnviroment.EEnviroment.eDist)
        {
            if (Input.GetKeyDown(KeyCode.F5))
            {
                var topMenu = GetTopMenuOnRoot();
                if (topMenu != null)
                {
                    LuaFunction reloadUIFunc = LuaClient.GetMainState().GetFunction("ReloadUI");
                    reloadUIFunc.Call(topMenu.name);
                    reloadUIFunc.Dispose();
                }
            }
        }
#if PROFILER
        Profiler.EndSample();
#endif
    }

    void LateUpdate()
    {
        if (Application.isMobilePlatform)
        {
            if (Controller.instance.IsShaking())
            {
                ShowGMMenu();
            }
        }
    }

    public GameObject ReloadUI(string uiPath)
    {
        //string uiName = System.IO.Path.GetFileNameWithoutExtension(uiPath);
        //GameObject uiGo = UIRoot.Find(uiName).gameObject;
        //if (uiGo != null)
        //{
        //    string moduleName = uiGo.GetComponent<LuaBehaviour>().moduleName;
        //    NGUITools.Destroy(uiGo);
        //    //LuaMgr.Instance.ReloadModule(moduleName);
        //}
        //return LoadUI(uiPath);
        return null;
    }

    public void LockScreen()
    {
        if (!FindMenu("Waiting"))
            CreateMenu("Waiting", true);
    }

    public void UnlockScreen()
    {
        CloseMenu("Waiting");
    }

    public void CacheUIPrefab(bool async = false)
    {
        //ResourceLibrary.CacheUIPrefab("WorldMap/BattleMove");
        if(async)
        {
            CachePoolAsync();
        }
        else
        {
            CachePool("BattleMove");
            CachePool("Mail");
        }
    }

    public void InitMenuList()
    {
        menuList = new Dictionary<string, string>();

        var luaMenuList = LuaClient.GetMainState().GetTable("MenuList").ToDictTable();
        foreach (var menu in luaMenuList)
        {
            menuList.Add(menu.Key.ToString(), menu.Value.ToString());
        }
    }

    private GameObject GetPrefabFromMenu(string _menu)
    {

        string prefabName;
        if (menuList.TryGetValue(_menu, out prefabName))
        {
            return ResourceLibrary.GetUIPrefab(prefabName);
        }

        return null;
    }

    static public void NormalizeChildrenPanelDepths(Transform parent)
    {
        UIPanel[] list = parent.GetComponentsInChildren<UIPanel>(true);
        int size = list.Length;

        if (size > 0)
        {
            Array.Sort(list, UIPanel.CompareFunc);

            int start = 0;
            int current = list[0].depth;

            for (int i = 0; i < size; ++i)
            {
                UIPanel p = list[i];

                if (p.depth == current)
                {
                    p.depth = start;
                }
                else
                {
                    current = p.depth;
                    p.depth = ++start;
                }
            }
        }
    }

    static public void NormalizeChildrenWidgetDepths(Transform parent)
    {
        NGUITools.NormalizeWidgetDepths(parent.GetComponentsInChildren<UIWidget>(true));
    }

    public void BringForward(GameObject go)
    {
        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug)
        {
            if (go.GetComponent<UIPanel>() == null)
            {
                //Debug.LogError("最顶层ui界面必须不是panel!!!!!!" + go.name);
            }
        }
        int val = NGUITools.AdjustDepth(go, 1000);
        Transform parent = go.transform.parent;
        if (val == 1) NormalizeChildrenPanelDepths(parent);
        else if (val == 2) NormalizeChildrenWidgetDepths(parent);
    }

    public LuaBehaviour CreateMenu(string _menu, bool bTop = false)
    {
        if (!bTop && !mIgnoreEffectMenus.Contains(_menu) && mPostEffectMenu != _menu && (PostEffect != null && !PostEffect.EnableBlurEffect))
        {
            LuaBehaviour result = FindMenu("MainCityUI");
            if (result != null)
            {
                //result.gameObject.SetActive(false);
            }
            if (GameSetting.instance.option.mQualityLevel != 0)
            {
                /*
                 * 界面的模糊效果目前都做在界面的mask上了，所以屏蔽代码实现效果以减少额外的绘制。
                 * 2017-07-14 ysy
                 */
                //PostEffect.OpenBlurEffect(true);
            }
            if (mPostEffectMenu == null)
            {
                mPostEffectMenu = _menu;
                //Debug.Log("OpenMenu" + _menu);
            }
        }


        if (_dicBehaviour.ContainsKey(_menu))
        {
            NGUITools.SetActive(_dicBehaviour[_menu].gameObject, true);
            BringForward(_dicBehaviour[_menu].gameObject);
            AddActiveMenu(_menu);
            if (onMenuCreate != null)
            {
                onMenuCreate(_menu);
            }
            return _dicBehaviour[_menu];
        }

        GameObject obj = null;
        if (PopUIPool(_menu, out obj))
        {
            var parent = bTop ? UITopRoot.gameObject : UIRoot.gameObject;
            BindTrf(obj.transform, parent.transform);
            NGUITools.SetChildLayer(obj.transform, parent.layer);
            obj.name = _menu;
            NGUITools.SetActive(obj, true);
            BringForward(obj);
            LuaBehaviour result = obj.GetComponent<LuaBehaviour>();
            if (result == null)
            {
                result = obj.AddComponent<LuaBehaviour>();
            }

            _dicBehaviour.Add(_menu, result);
            AddActiveMenu(_menu);
            if (onMenuCreate != null)
            {
                onMenuCreate(_menu);
            }
            return result;
        }

        GameObject prefab = GetPrefabFromMenu(_menu);
        if (prefab != null)
        {
            if (GameStateLogin.Instance.state != GameStateLogin.EInitState.eCheckUpdate)
            {
                AssetBundleManager.Instance.ClearDelegate();
            }
            var parent = bTop ? UITopRoot.gameObject : UIRoot.gameObject;
            obj = NGUITools.AddChild(parent, prefab);
            NGUITools.SetChildLayer(obj.transform, parent.layer);
            obj.name = _menu;
            NGUITools.SetActive(obj, true);
            BringForward(obj);
            LuaBehaviour result = obj.GetComponent<LuaBehaviour>();
            if (result == null)
            {
                result = obj.AddComponent<LuaBehaviour>();
            }

            _dicBehaviour.Add(_menu, result);
            AddActiveMenu(_menu);
            if (onMenuCreate != null)
            {
                onMenuCreate(_menu);
            }
            return result;
        }
        else
        {
            LuaBehaviour loading = CreateMenu("update_ui", true);
            AssetBundleManager.Instance.onCheckPercent += (a) =>
            {
                if (loading != null)
                {
                    loading.CallFunc("OnCheckPercent", a);
                }
            };
            AssetBundleManager.Instance.onBundleLoad += (b) =>
            {
                if (loading != null)
                {
                    loading.CallFunc("OnBundleLoad", b);
                }
            };
            AssetBundleManager.Instance.isChecking += (ischecking) =>
            {
                string tempmenu = _menu;
                bool tempbtop = bTop;
                if (!ischecking)
                {
                    AssetBundleManager.Instance.ClearDelegate();
                    CloseMenu("update_ui");
                    CreateMenu(tempmenu, tempbtop);
                }
            };
        }
        return null;
    }

    public LuaBehaviour FindMenu(string _menu)
    {
        if (_dicBehaviour.ContainsKey(_menu))
        {
            return _dicBehaviour[_menu];
        }
        return null;
    }

    public void __Internal_RemoveMenu(LuaBehaviour _behaviour)
    {
        if (_dicBehaviour.ContainsKey(_behaviour.name))
        {
            _dicBehaviour.Remove(_behaviour.name);
        }

        if (!PushUIPool(_behaviour.name, _behaviour.gameObject))
        {
            NGUITools.Destroy(_behaviour.gameObject);
        }

    }

    public void CloseMenu(string _menu)
    {
        CloseMenu(_menu, 0);
    }

    public void CloseMenu(string _menu, float delay)
    {
        LuaBehaviour result = FindMenu(_menu);
        if (result != null)
        {
            RemoveActiveMenu(_menu);
            if (!result.transform.parent.name.Contains("UI Top Root"))
            {
                //Debug.Log("CloseMune" + _menu);
                LuaBehaviour maincity = FindMenu("MainCityUI");
                if (!mIgnoreEffectMenus.Contains(_menu) && mPostEffectMenu == _menu && (PostEffect != null))
                {

                    if (maincity != null)
                    {
                        maincity.gameObject.SetActive(true);
                        maincity.CallFunc("MainCityUIActiveNotify", null);
                        //maincity.CallFunc("OnJoinUnionNotify", null);
                    }
                    if (GameSetting.instance.option.mQualityLevel != 0)
                    {
                        if(PostEffect != null)
                            PostEffect.CloseBlurEffect();
                    }
                    mPostEffectMenu = null;
                }
                else
                {
                    //LuaBehaviour maincity = FindMenu("MainCityUI");
                    //if (maincity != null && !maincity.gameObject.activeSelf)
                    //{
                    //    maincity.gameObject.SetActive(true);
                    //}
                }
                if (maincity != null)
                {
                    maincity.CallFunc("CheckAndRequestNotfy", null);
                }
            }

            result.Close();
            if (result.name == "WorldMap")
            {
                PlaneCamera.Instance.Close();
            }
            if (onMenuClose != null)
            {
                onMenuClose(_menu);
            }
        }
    }

    public void CloseAllMenu()
    {
        List<LuaBehaviour> list = new List<LuaBehaviour>();
        foreach (string key in _dicBehaviour.Keys)
        {
            list.Add(_dicBehaviour[key]);
        }

        for (int i = 0; i < list.Count; i++)
        {
            try
            {
                var menu = list[i].name;
                list[i].Close();
                if (onMenuClose != null)
                {
                    onMenuClose(menu);
                }
            }
            catch (Exception ex)
            {

            }

        }
        mPostEffectMenu = null;
        mActiceMenuDic.Clear();
        LuaClient.GetMainState().LuaGC(LuaGCOptions.LUA_GCCOLLECT);
    }

    private void Init()
    {
        UIRoot.position = new Vector3(1000, 1000, 0);
        UITopRoot.position = new Vector3(1000, 1000, 0);
    }

    public void MessageBox(string msg, Action okCallback, Action cancelCallback, string okText = null, string cancelText = null)
    {
        LuaFunction showFunc = LuaClient.GetMainState().GetFunction("MessageBox.Show");
        if (showFunc != null)
        {
            showFunc.Call(msg, okCallback, cancelCallback, okText, cancelText);
            showFunc.Dispose();
        }
    }

    public void FloatText(string text, Color color)
    {
        LuaFunction showFunc = LuaClient.GetMainState().GetFunction("FloatText.Show");
        if (showFunc != null)
        {
            showFunc.Call(text, color);
            showFunc.Dispose();
        }
    }

    public Vector3 UIWorldToGameWorld(Vector3 uiWorld, Vector3 go)
    {
        // Debug.Log("target wordls : " + uiWorld);
        Vector3 uiScreen = UICamera.mainCamera.WorldToScreenPoint(uiWorld);
        Vector3 uiSpaceGo = Camera.main.WorldToScreenPoint(go);
        uiScreen.z = uiSpaceGo.z;
        // Debug.Log("target uiScreen : " + uiScreen);
        //Vector3 result = uiScreen;
        Vector3 result = Camera.main.ScreenToWorldPoint(uiScreen);

        //Debug.Log("target result woeld : " + result);
        return result;
    }

    public LuaBehaviour GetTopMenuOnRoot()
    {
        LuaBehaviour topMenu = null;
        int topDepth = int.MinValue;

        foreach (var item in _dicBehaviour)
        {
            if (item.Value.transform.IsChildOf(mUiRoot))
            {
                UIPanel panel = item.Value.transform.GetComponent<UIPanel>();
                if (panel.depth > topDepth && item.Value.isActiveAndEnabled)
                {
                    topMenu = item.Value;
                    topDepth = panel.depth;
                }
            }
        }

        return topMenu;
    }

    public LuaBehaviour GetTopNotTutorialMenuOnRoot()
    {
        LuaBehaviour topMenu = null;
        int topDepth = int.MinValue;

        foreach (var item in _dicBehaviour)
        {
            if (item.Value.name != "Tutorial" && item.Value.name != "ResBar" && item.Value.transform.IsChildOf(mUiRoot))
            {
                UIPanel panel = item.Value.transform.GetComponent<UIPanel>();
                if (panel.depth > topDepth && item.Value.isActiveAndEnabled)
                {
                    topMenu = item.Value;
                    topDepth = panel.depth;
                }
            }
        }

        return topMenu;
    }
    public bool IsMainCityUIOpen()
    {
        Transform trf = mUiRoot.Find("MainCityUI");
        return trf != null && trf.gameObject.activeSelf;
    }

    public bool IsMenuOpen(string menu)
    {
        return mUiRoot.Find(menu) != null;
    }

    public bool IsTopMenuOpen(string menu)
    {
        return mUiTopRoot.Find(menu) != null;
    }

    public string GetDeviceName()
    {
        return WSdkManager.instance.GetDeviceName();
    }

    public string GetSystemInfo()
    {
        return WSdkManager.instance.GetSystemInfo();
    }

    public void SubmitRoleInfo(string roleName, string level, bool full)
    {
        WSdkManager.instance.SubmitRoleInfo(roleName, level, full);
    }

    public void Recharge(string param, string orderid, string price)
    {
        WSdkManager.instance.Recharge(param, orderid, price);
    }

    public void RechargeSucc()
    {
        WSdkManager.instance.RechargeSucc();
    }

    public void SendMessageToSocial(int _type, int _scene, string _title, string _desc, string _imgPath, string _shareUrl)
    {
        WSdkManager.instance.SendMessageToSocial((WSdkManager.ESocialType)_type, (WSdkManager.ESocialScene)_scene, _title, _desc, _imgPath, _shareUrl);
    }

    public void GetInventoryList(string param)
    {
        WSdkManager.instance.GetInventoryList(param);
    }

    public int GetPlatformType()
    {
        return (int)WSdkManager.instance.platform;
    }

    public void MakeTokenBroken()
    {
        if (!string.IsNullOrEmpty(WSdkManager.instance.session))
        {
            WSdkManager.instance.session = "fwoiejqweiopdhjqiophi1239172341";
            GameSetting.instance.SaveLoginInfo();
        }
    }

    public void SendDataReport(params string[] args)
    {
        WSdkManager.instance.SendDataReport(args);
    }

    public void EnableDestroyEffect(bool enable)
    {
        if (PostEffect != null)
        {
            if (enable)
                PostEffect.EnableDestroyEffect();
            else
                PostEffect.DisableDestroyEffect();
        }
    }

    public string StringFomat(string text, object[] args)
    {
        string res = System.String.Format(text, args);
        return res;
    }

    public void TriggerOnMenuOpen(string name)
    {
        if (onMenuOpen != null)
        {
            onMenuOpen(name);
        }
    }

    public void SetLanguage(string tag)
    {
        targetLanguage = tag;
    }
    public int GetSystemLanguage()
    {
        //This outputs what language your system is in
        //Debug.Log("This system is in " + Application.systemLanguage);

        //Debug.Log("sdk getlan:" + WSdkManager.instance.GetSystemLanguage());
        return (int)Application.systemLanguage;
    }
    public void GS()
    {
        //This outputs what language your system is in
        //Debug.Log("This system is in " + Application.systemLanguage);

        //Debug.Log("sdk getlan:" + WSdkManager.instance.GetSystemLanguage());
    }
    public string MD5_Encrypt(string str)
    {
        return AssetsUtility.GetMd5Hash(str);
    }
    public string GetResourceSettingPath()
    {
        return Application.dataPath + @"/Resources/Settings/";
    }
    public string GetResourceUserPath()
    {
        return Application.dataPath + @"/Resources/Users/";
    }
    public string GetFileUserPath()
    {
        return Application.persistentDataPath + @"/Resources/Users/";
    }
    public void CreateDirectory(string path , string file)
    {
        if(!System.IO.Directory.Exists(path))
        {
            System.IO.Directory.CreateDirectory(path);
        }

       /* string sfile = path + file + ".txt";
        if (!File.Exists(sfile))
        {
            FileInfo cfile = new FileInfo(sfile);
            StreamWriter sw = file.CreateText();
            string json = JsonMapper.ToJson(_ownBuildingList);
            sw.WriteLine(json);
            sw.Close();
            sw.Dispose();
        }
        else
        {

        }*/

    }

    public void Exit()
    {
        WSdkManager.instance.Exit();
    }

    public void DeleteDirectory(string spath)
    {
        DirectoryInfo directoryInfo = new DirectoryInfo(spath);
        if(directoryInfo.Exists)
            directoryInfo.Delete(true);
    }

   
    public string String2Base(string str)
    {
        //System.Text.Encoding encode = System.Text.Encoding.UTF8;
        byte[] bytedata = System.Text.UTF8Encoding.UTF8.GetBytes(str);
        string strPath = Convert.ToBase64String(bytedata, 0, bytedata.Length);
        return strPath;
    }

    public string Base2String(string baseStr)
    {
        //string strPath = "aHR0cDovLzIwMy44MS4yOS40Njo1NTU3L19iYWlkdS9yaW5ncy9taWRpLzIwMDA3MzgwLTE2Lm1pZA == ";     
        byte[] bpath = Convert.FromBase64String(baseStr);
        baseStr = System.Text.UTF8Encoding.UTF8.GetString(bpath);
        return baseStr;
    }
    

    public void GC()
    {
        Resources.UnloadUnusedAssets();
        LuaClient.GetMainState().Collect();
        System.GC.Collect();
    }

    public void HttpRequest(string url, Dictionary<string, string> headers, string post, OnCheckChatMsgCallback callback)
    {
        StartCoroutine(POST(url, headers , post, callback));
    }
    //POST请求(Form表单传值、效率低、安全 ，)  
    public IEnumerator POST(string url, Dictionary<string, string> headers, string post, OnCheckChatMsgCallback callback)
    {
        byte[] jsbyte = System.Text.Encoding.UTF8.GetBytes(post);
        WWW www = new WWW(url, jsbyte, headers);

        yield return www;

        using (www)
        {
            float jindu = www.progress;
            string mContent = string.Empty;
            if (www.error != null)
            {
                //POST请求失败  
                mContent = "error :" + www.error;
                if (callback != null)
                {
                    callback(1, mContent);
                }
            }
            else
            {
                //POST请求成功  
                mContent = www.text;
                if (callback != null)
                {
                    callback(0, mContent);
                }
            }
        }
    }
}

public class PPGameLoginTool
{
    private static Byte[] Encrypt(Byte[] Data, Byte[] Key)
    {
        if (Data.Length == 0)
        {
            return Data;
        }
        return ToByteArray(Encrypt(ToUInt32Array(Data, false), ToUInt32Array(Key, false)), false);
    }
    private static Byte[] Decrypt(Byte[] Data, Byte[] Key)
    {
        if (Data.Length == 0)
        {
            return Data;
        }
        return ToByteArray(Decrypt(ToUInt32Array(Data, false), ToUInt32Array(Key, false)), true);
    }

    private static UInt32[] Encrypt(UInt32[] v, UInt32[] k)
    {
        Int32 n = v.Length - 1;
        if (n < 1)
        {
            return v;
        }
        if (k.Length < 4)
        {
            UInt32[] Key = new UInt32[4];
            k.CopyTo(Key, 0);
            k = Key;
        }
        UInt32 z = v[n], y = v[0], delta = 0x9E3779B9, sum = 0, e;
        Int32 p, q = 6 + 52 / (n + 1);
        while (q-- > 0)
        {
            sum = unchecked(sum + delta);
            e = sum >> 2 & 3;
            for (p = 0; p < n; p++)
            {
                y = v[p + 1];
                z = unchecked(v[p] += (z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z));
            }
            y = v[0];
            z = unchecked(v[n] += (z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z));
        }
        return v;
    }
    private static UInt32[] Decrypt(UInt32[] v, UInt32[] k)
    {
        Int32 n = v.Length - 1;
        if (n < 1)
        {
            return v;
        }
        if (k.Length < 4)
        {
            UInt32[] Key = new UInt32[4];
            k.CopyTo(Key, 0);
            k = Key;
        }
        UInt32 z = v[n], y = v[0], delta = 0x9E3779B9, sum, e;
        Int32 p, q = 6 + 52 / (n + 1);
        sum = unchecked((UInt32)(q * delta));
        while (sum != 0)
        {
            e = sum >> 2 & 3;
            for (p = n; p > 0; p--)
            {
                z = v[p - 1];
                y = unchecked(v[p] -= (z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z));
            }
            z = v[n];
            y = unchecked(v[0] -= (z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z));
            sum = unchecked(sum - delta);
        }
        return v;
    }
    private static UInt32[] ToUInt32Array(Byte[] Data, Boolean IncludeLength)
    {
        Int32 n = (((Data.Length & 3) == 0) ? (Data.Length >> 2) : ((Data.Length >> 2) + 1));
        UInt32[] Result;
        if (IncludeLength)
        {
            Result = new UInt32[n + 1];
            Result[n] = (UInt32)Data.Length;
        }
        else
        {
            Result = new UInt32[n];
        }
        n = Data.Length;
        for (Int32 i = 0; i < n; i++)
        {
            Result[i >> 2] |= (UInt32)Data[i] << ((i & 3) << 3);
        }
        return Result;
    }
    private static Byte[] ToByteArray(UInt32[] Data, Boolean IncludeLength)
    {
        Int32 n;
        if (IncludeLength)
        {
            n = (Int32)Data[Data.Length - 1];
        }
        else
        {
            n = Data.Length << 2;
        }
        Byte[] Result = new Byte[n];
        for (Int32 i = 0; i < n; i++)
        {
            Result[i] = (Byte)(Data[i >> 2] >> ((i & 3) << 3));
        }
        return Result;
    }

    public static Dictionary<string,string> GetFormHeaders()
    {
        WWWForm form = new WWWForm();
        Dictionary<string, string> head = form.headers;
        head["Content-Type"] = "application/x-www-form-urlencoded";
        return head;
    }

    public static byte[] GetPostDatas(string beforeInfo, string formbody)
    {
        byte[] key = { Convert.ToByte('1'), Convert.ToByte('2'), Convert.ToByte('3'), Convert.ToByte('4'), Convert.ToByte('5'), Convert.ToByte('6'), Convert.ToByte('7'), Convert.ToByte('8'), Convert.ToByte('9'), Convert.ToByte('0'), 0, 0, 0, 0, 0, 0 };

        List<byte> bytes = new List<byte>();
        bytes.AddRange(System.Text.Encoding.UTF8.GetBytes(beforeInfo));
        bytes.Add(0);
        bytes.AddRange(Encrypt(System.Text.Encoding.UTF8.GetBytes(formbody), key));
        return bytes.ToArray();
    }

    
}