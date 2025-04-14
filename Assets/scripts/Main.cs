using UnityEngine;
using System.Collections;
using LuaInterface;
using System.Collections.Generic;
using System;
using ProtoMsg;

public class Reload : MonoBehaviour
{
    public void Start()
    {
        StartCoroutine(Load());
    }

    public IEnumerator Load()
    {
        yield return null;
        gameObject.AddComponent<Main>();
        yield return new WaitForSeconds(1f); ;
        GameObject wait = GameObject.Find("Waiting");
        if (wait != null)
        {
            GameObject.Destroy(wait);
        }

        GameObject.DestroyObject(this, 1f);
    }

 

}
public class Main : MonoBehaviour
{
    private string BuglyAppIDForiOS = "22281eb7bf";//默认为095mzyw的id
    private string BuglyAppIDForAndroid = "900022932";

    private static Main instance;

    private StateMachine<GameState> gameStateMachine;

    private int mFixWidth = 0;
    private long mAppPauseTime = 0;
    private int mAppPauseConfigTime = 0;
    private int mEnableExceptionReturnLogin = 0;
    private int mApplicationPause = 0;
    private int mApplicationFocus = 0;

    public int FixWidth
    {
        get
        {
            return mFixWidth;
        }
    }

    public static GameObject objMain = null;

    private int mFixHeight = 0;
    public int FixHeight
    {
        get
        {
            return mFixHeight;
        }
    }

    private Serclimax.ScTableMgr tableMgr;
    public Serclimax.ScTableMgr TableMgr
    {
        get
        {
            return tableMgr;
        }
    }

    private WorldBlockInfo worldBlockInfo;
    private string mCurBlockName;
    private string mTargetBlockName;

    public WorldBlockInfo WorldBlockInfo
    {
        get
        {
            ReloadWorldBlockInfo();
            return worldBlockInfo;
        }
    }

    public int GetBlockInfo(int x, int y)
    {
        return WorldBlockInfo[x, y] & 0x7f;
    }

    public bool isOccupied(WorldObjectType type ,int x, int y)
    {
        switch (type)
        {
            case WorldObjectType.ALL:
                return WorldBlockInfo[x, y] > 0;
            case WorldObjectType.TERRAIN:
                return (WorldBlockInfo[x, y] & 0x7f) > 0;
            case WorldObjectType.BIOME:
                return ((WorldBlockInfo[x, y] >> 7) & 0x7f) > 0;
            default:
                return false;
        }
    }

    void OnApplicationQuit()
    {
        GUIMgr.Instance.SendDataReport("mango", "3");
        Debug.Log("OnApplicationQuit");
        NetworkManager.instance.Close();
        LuaFunction showFunc = LuaClient.GetMainState().GetFunction("ExitGame");
        if (showFunc != null)
        {
            showFunc.Call();
            showFunc.Dispose();
        }
    }

    Vector2 getLowLevelResolution(float _w, float _h)
    {
        if (_w >= 1920 && _h >= 1080)
            return new Vector2(1920f, 1080f);
        else if (_w >= 1280 && _h >= 720)
            return new Vector2(1280, 720);
        else
            return new Vector2(960, 640);
    }

    void ResetResolution(bool _init)
    {
        if (GameSetting.instance.option.mQualityLevel == 2)
            return;

        if (_init)
        {
            float realW = (float)Screen.currentResolution.width;
            float realH = (float)Screen.currentResolution.height;

            Vector2 nextResolution = getLowLevelResolution(realW, realH);

            float width = nextResolution.x;
            float height = nextResolution.y;

            if (realW / width > realH / height)
            {
                mFixHeight = (int)height;
                mFixWidth = (int)(realW / (realH / height));
            }
            else
            {
                mFixWidth = (int)width;
                mFixHeight = (int)(realH / (realW / width));
            }
        }

        Screen.SetResolution(mFixWidth, mFixHeight, true);
    }

    public bool isEditor = false;
    public bool sendErroReport = false;
    void Awake()
    {
        instance = this;
        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDist || GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)
        {
            Destroy(GameObject.Find("Reporter"));
        }
       
        try
        {
            UICamera.onClick = null;
            UICamera.onDoubleClick = null;
            UICamera.onHover = null;
            UICamera.onPress = null;
            UICamera.onSelect = null;
            UICamera.onScroll = null;
            UICamera.onDrag = null;
            UICamera.onDragStart = null;
            UICamera.onDragOver = null;
            UICamera.onDragOut = null;
            UICamera.onDragEnd = null;
            UICamera.onDrop = null;
            UICamera.onKey = null;
            UICamera.onNavigate = null;
            UICamera.onPan = null;
            UICamera.onTooltip = null;
            UICamera.onMouseMove = null;
            UICamera.onClick = null;

            if (NetworkManager.instance != null)
            {
                NetworkManager.instance.Close();
            }
            if (GUIMgr.Instance != null)
                GUIMgr.Instance.CloseAllMenu();
        }
        catch (Exception ex)
        {

        }

        AssetBundleManager abm = gameObject.AddComponent<AssetBundleManager>();
        tableMgr = new Serclimax.ScTableMgr();
        tableMgr.Init(abm);
        
        gameObject.AddComponent<GUIMgr>();
        gameObject.AddComponent<LuaClient>();

        GUIMgr.Instance.InitMenuList();
        //倒计时事件触发器
        gameObject.AddComponent<CountDown>();
        mAppPauseConfigTime = int.Parse(TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.ReloginOnBackground).value);   
        mEnableExceptionReturnLogin = 0;
        if(TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.EnableExceptionReturnLogin) != null)
        {
            mEnableExceptionReturnLogin = int.Parse(TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.EnableExceptionReturnLogin).value);   
        }
        
        //weysdk callback
        if (gameObject.GetComponent<WSdkCallback>() == null)
        {
            gameObject.AddComponent<WSdkCallback>();
        }
        
        //if (sendErroReport)
            Application.logMessageReceived += HandleLog;
#if UNITY_ANDROID
        ResetResolution(true);
#endif
    }

    public void Restart()
    {
        Application.targetFrameRate = 60;
        gameStateMachine = new StateMachine<GameState>(GameStateInit.Instance);
    }

    public void ChangeWorldBlockInfo(string file_name)
    {
        if (mTargetBlockName == file_name)
            return;
        mTargetBlockName = file_name;
    }

    public void ReloadWorldBlockInfo()
    {
        if (string.IsNullOrEmpty(mTargetBlockName))
        {
            if (mCurBlockName == "WorldBlockInfo")
                return;
            if (string.IsNullOrEmpty(mCurBlockName))
                mCurBlockName = "WorldBlockInfo";
            worldBlockInfo = Resources.Load<WorldBlockInfo>(mCurBlockName);
        }
        else
        {
            if (mCurBlockName == mTargetBlockName)
                return;
            worldBlockInfo = Resources.Load<WorldBlockInfo>(mTargetBlockName);
            if (worldBlockInfo != null)
            {
                mCurBlockName = mTargetBlockName;
            }
        }
    }

    void Start()
    {
        
        Application.targetFrameRate = 60;
        gameStateMachine = new StateMachine<GameState>(GameStateInit.Instance);
        ReloadWorldBlockInfo();
        //worldBlockInfo = Resources.Load<WorldBlockInfo>("WorldBlockInfo");
        mAppPauseTime = Serclimax.GameTime.GetSecTime();
        InitBuglySDK();
#if UNITY_EDITOR
        if (isEditor)
        {
            XLevelGenerator lvgenerator = transform.GetComponent<XLevelGenerator>();
            Serclimax.Constants.ENABLE_FAKE_DATA = true;
            Serclimax.Constants.USE_LOCAL_LEVEL_DATA = true;
            GameStateBattle.Instance.BattleId = int.Parse(lvgenerator.leveId);

            Dictionary<string, object> param = new Dictionary<string, object>();
            param["selectedArmyList"] = new List<int>() { 2000001 };
            var bounus = new Dictionary<string, object>();
            bounus["bulletAddition"] = 300;
            bounus["energyAddition"] = 300;
            bounus["bulletRecover"] = 2;
            param["battleBonus"] = bounus;

            /*HeroInfo hero = new HeroInfo();
            hero.baseid = 401;
            hero.exp = 0;
            hero.grade = 5;
            hero.level = 20;
            hero.star = 3;
            hero.heroGrade = 1;
            hero.godSkill = new SkillInfo();
            hero.godSkill.id = 401;
            hero.godSkill.level = 3;
            */
            param["heroInfoDataList"] = new List<byte[]>() { /*NetworkManager.instance.Encode<HeroInfo>(hero)*/};
            
            GameObject rObj = GameObject.Find("XRoot");
            if (rObj != null)
            {
                GameObject.Destroy(rObj);
                //rObj.SetActive(false);
            }

            ChangeGameState(GameStateBattle.Instance, OurMiniJSON.Json.Serialize(param));
        }
#endif
    }

    void Update()
    {
#if UNITY_ANDROID
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (WSdkManager.instance.platform == AccType.AccType_adr_muzhi || WSdkManager.instance.platform == AccType.AccType_adr_mango)
            {
                WSdkManager.instance.Exit();
            }
            else
            {
                LuaFunction showFunc = LuaClient.GetMainState().GetFunction("ExitGame");
                if (showFunc != null)
                {
                    showFunc.Call();
                    showFunc.Dispose();
                }
            }
        }
#endif

#if PROFILER
        Profiler.BeginSample("Main_Update");
#endif
        NetworkManager.instance.Update();

        Controller.instance.UpdateControl();


        if (gameStateMachine != null)
        {
            gameStateMachine.UpdateState();
        }
        else
        {
            Serclimax.DebugUtils.LogError("gamestate is null");
        }

        NetworkManager.instance.UpdateCheckSendPackage();

        WSdkManager.instance.Update();

#if PROFILER
        Profiler.EndSample();
#endif
        LuaClient.GetMainState().LuaGC(LuaInterface.LuaGCOptions.LUA_GCSTEP,10);
    }

    void OnApplicationPause(bool paused)
    {
        Debug.Log("OnApplicationPause:" + paused);
        //先判断是否功能开启
        if (mAppPauseConfigTime > 0)
        {
            if (paused)
            {
                mAppPauseTime = Serclimax.GameTime.GetSecTime();
            }
            else
            {
                long passSec = Serclimax.GameTime.GetSecTime() - mAppPauseTime;
                Debug.Log("passTime:" + passSec + "  lastTimne:" + mAppPauseTime + 
                            " currentTime:" + Serclimax.GameTime.GetSecTime() + 
                            " configTime:" + mAppPauseConfigTime);

                if (mAppPauseTime > 0 && passSec > mAppPauseConfigTime)
                {
                    Debug.Log("==========Application Relogin Because Enter Background For Long Time===========");
                    if (!IsInLoginState())
                    {
                        if (!WSdkManager.instance.isRecharging)
                        {
                            GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("ui_message_reentry"),
                            () =>
                            {
                                NetworkManager.instance.BackToLogin();
                            }, null);
                        }
                    }
                    else
                    {
                        // GameStateLogin.Instance.ReLogin();
                    }
                }
            }
        }
       
#if UNITY_ANDROID
        if (!paused)
            ResetResolution(false);
#endif
    }

    void OnApplicationFocus(bool focusState)
    {

    }

    void FixedUpdate()
    {
        if (gameStateMachine != null)
        {
            gameStateMachine.FixedUpdateState();
        }
    }

    private void InitLuaState()
    {
    }

    public static Main Instance
    {
        get
        {
            return instance;
        }
    }

    public Serclimax.ScTableMgr GetTableMgr()
    {
        return tableMgr;
    }

    public State<GameState> CurrentGameState
    {
        get
        {
            return gameStateMachine.CurrentState;
        }
    }

    public bool IsBattleState()
    {
        return (gameStateMachine.CurrentState as GameStateBattle) == null;
    }


    public void ChangeGameState(State<GameState> newState, string param,System.Action done = null)
    {
        gameStateMachine.ChangeState(newState, param,done);
    }

    public bool IsInGameState<T>() where T : State<GameState>
    {
        return gameStateMachine.IsInState<T>();
    }

    public bool IsInInitState()
    {
        return IsInGameState<GameStateInit>();
    }

    public bool IsInLoginState()
    {
        return IsInGameState<GameStateLogin>();
    }

    public bool IsInBattleState()
    {
        return IsInGameState<GameStateBattle>();
    }

    public bool IsInMainState()
    {
        return IsInGameState<GameStateMain>();
    }

    public void ToggleEnableNetworkLog()
    {
        NetworkManager.instance.enableLog = !NetworkManager.instance.enableLog;
    }

    public void ResetNetworkLog()
    {
        NetworkManager.instance.ResetLog();
    }

    public void ToggleShowNetworkLog()
    {
        var reportObject = GameObject.Find("Reporter");
        if (reportObject != null)
        {
            reportObject.GetComponent<Reporter>().showNetworkLog = !reportObject.GetComponent<Reporter>().showNetworkLog;
        }
    }

    public void SetNetworkDelay(float delay)
    {
        NetworkManager.instance.analogDelay = delay;
    }

    void OnDestroy()
    {
        //if (sendErroReport)
            Application.logMessageReceived -= HandleLog;
    }
    public void OnGUI1()
    {
        if (GUILayout.Button("clear all", GUILayout.MaxWidth(100)))
        {
            if (NetworkManager.instance != null)
            {
                NetworkManager.instance.Close();
            }

            UIEventListener[] list = GameObject.FindObjectsOfType<UIEventListener>();
            for(int i = 0; i < list.Length; i++)
            {
                list[i].enabled = false;
            }
            UIButton [] list1 = GameObject.FindObjectsOfType<UIButton>();
            for (int i = 0; i < list1.Length; i++)
            {
                list1[i].enabled = false;
            }

            UnityEngine.SceneManagement.SceneManager.LoadScene("Main");
        }
    }

    public void HandleLog(string logString, string stackTrace, LogType logType)
    {

        if (logType == LogType.Error || logType == LogType.Exception)
        {
            if (logType == LogType.Exception && mEnableExceptionReturnLogin > 0)
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("System_Error"),()=>{
                    if (!IsInLoginState())
                    {
                        if (!WSdkManager.instance.isRecharging)
                        {
                             NetworkManager.instance.BackToLogin();
                        }
                    }
                    else
                    {
                        // GameStateLogin.Instance.ReLogin();
                    }
                },null);
                
            //textList.Add("[ff0000]" + logString.Replace("[", "[[c]") + "[-]");
            //if(sendErroReport)
            //    PlatformUtils.SendEmail(logString);
        }
        else
        {
            //textList.Add(logString.Replace("[", "[[c]"));
        }
    }
    
    void InitBuglySDK()
    {
        string[] bId = TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.BuglyConfigId).value.Split(',');
        if(bId.Length >= 2)
        {
            BuglyAppIDForiOS = bId[0];
            BuglyAppIDForAndroid = bId[1];
        }
        // TODO NOT Required. Set the crash reporter type and log to report
        // BuglyAgent.ConfigCrashReporter (1, 2);

        // TODO NOT Required. Enable debug log print, please set false for release version
#if DEBUG
        BuglyAgent.ConfigDebugMode(true);
#else
        BuglyAgent.ConfigDebugMode(false);
#endif

        // TODO NOT Required. Register log callback with 'BuglyAgent.LogCallbackDelegate' to replace the 'Application.RegisterLogCallback(Application.LogCallback)'
        // BuglyAgent.RegisterLogCallback (CallbackDelegate.Instance.OnApplicationLogCallbackHandler);

        // BuglyAgent.ConfigDefault ("Bugly", null, "ronnie", 0);

#if UNITY_IPHONE || UNITY_IOS
        BuglyAgent.InitWithAppId (BuglyAppIDForiOS);
#elif UNITY_ANDROID
        BuglyAgent.InitWithAppId(BuglyAppIDForAndroid);
#endif

        // TODO Required. If you do not need call 'InitWithAppId(string)' to initialize the sdk(may be you has initialized the sdk it associated Android or iOS project),
        // please call this method to enable c# exception handler only.
        BuglyAgent.EnableExceptionHandler();

        // TODO NOT Required. If you need to report extra data with exception, you can set the extra handler
        //        BuglyAgent.SetLogCallbackExtrasHandler (MyLogCallbackExtrasHandler);

        BuglyAgent.PrintLog(LogSeverity.LogInfo, "Init the bugly sdk");
    }
    
  
}
