using UnityEngine;
using System.Collections;
using System.Collections.Generic;

using ProtoMsg;
using System;
using System.Text;

public class GameStateLogin : GameState
{
    public static readonly int RANDOM_TIMES = 3;

    public enum EInitState
    {
        eIdel = 0,
        eCheckSDK,
        eCheckConfig,
        eAccountLogin,
        eConnectServerRandom,
        eVerifyAccount,
        eVerifyAccountOK,
        eRequestServerList,
        eRequestServerListOK,
        eCheckEXEUpdate,
        eCheckUpdate,
        eSelectZone,
        eConnectGameServer,
        eGameVerifyAccount,
        eGetGameSave,
        eGetGameData,
        ePreloadGameResource,
        eEnterNormalGame,
        eEnterTeachBattle,
        eSelectCountry,
        eCount,
    }

    private EInitState mState = EInitState.eCount;
    private EInitState mNextState = EInitState.eCount;
    public EInitState state
    {
        get
        {
            return mState;
        }
        set
        {
            OnStateChange(value);
        }
    }
    private int mLSIndex = -1;
    private int mConnectLSTimes = 0;
    private List<int> mIgnoreList = new List<int>();
    private string mGameServerIp;
    private uint mGameServerPort;

    private int mFinishCount = 0;
    private int mFinishStep = 0;
    private float mWaitResponseMsgTime = 0;

    private DtoAreaInfo mAreaData = null;

    private string resVersion;
    private string resUrl;

    private LuaBehaviour loginScreen = null;

    private static GameStateLogin instance;

    private bool checkexeover = false;

    private GameStateLogin() { }

    public static GameStateLogin Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameStateLogin();
            }

            return instance;
        }
    }

    public int GetZoneId()
    {
        return WSdkManager.instance.zoneId;
    }

    public override void OnEnter(string _param, System.Action done)
    {
        loginScreen = GUIMgr.Instance.CreateMenu("login", true);

        if (loginScreen != null)
        {
            string resVersion = GameSetting.instance.option.mResVersion;
            if (string.IsNullOrEmpty(resVersion))
            {
                resVersion = GameVersion.RES;
            }
            string version = string.Format("App  v{0}.{1}  build{2}", GameVersion.EXE, resVersion, GameVersion.BUILD);
            loginScreen.CallFunc("ShowVersion", version);
        }

        NetworkManager.instance.EnableAutoConnect = false;
        GUIMgr.Instance.UnlockScreen();

        state = EInitState.eCheckConfig;
        if (done != null)
        {
            done();
        }
    }

    public override void OnUpdate()
    {
        if (mNextState != mState)
        {
            mState = mNextState;
            OnPrevStateChange(mNextState);
        }

        if (mState == EInitState.eCheckSDK)
        {
            if (WSdkManager.instance.platform != AccType.AccType_adr_tmgp &&
                WSdkManager.instance.platform != AccType.AccType_adr_kr_digiSky &&
                WSdkManager.instance.platform != AccType.AccType_adr_tw_digiSky &&
                WSdkManager.instance.platform != AccType.AccType_ios_kr_digiSky &&
                WSdkManager.instance.platform != AccType.AccType_ios_tw_digiSky &&
                WSdkManager.instance.platform != AccType.AccType_adr_kr_onestore &&
                WSdkManager.instance.platform != AccType.AccType_adr_official &&
                WSdkManager.instance.platform != AccType.AccType_ios_official &&
                WSdkManager.instance.platform != AccType.AccType_ios_india &&
                WSdkManager.instance.platform != AccType.AccType_ios_efun &&
                WSdkManager.instance.platform != AccType.AccType_adr_official_branch  /*&&
                WSdkManager.instance.platform != AccType.AccType_adr_opgame */)
            {
                state = EInitState.eAccountLogin;
            }
            else
            {
                if (WSdkManager.instance.loginType != 0
                    /*WSdkManager.instance.loginType == (int)WSdkManager.ELoginType.eLogin_QQ ||
                    WSdkManager.instance.loginType == (int)WSdkManager.ELoginType.eLogin_WX*/)
                {
                    state = EInitState.eAccountLogin;
                }
            }
        }
        else if (mState == EInitState.eCheckConfig)
        {
            ConfigFileManager.instance.Update();
            if (ConfigFileManager.instance.CheckConfError() != null)
            {
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                ConfigFileManager.instance.FinishCheckConf();
                state = EInitState.eIdel;
            }
            else if (ConfigFileManager.instance.CheckConfEnd())
            {
                if (!ConfigFileManager.instance.ParseConfData())
                {
                    ConfigFileManager.instance.ParseConfData(true);
                }

                ConfigFileManager.instance.FinishCheckConf();
                if (WSdkManager.instance.platform == AccType.AccType_adr_official ||
                    WSdkManager.instance.platform == AccType.AccType_ios_india ||
                    WSdkManager.instance.platform == AccType.AccType_ios_efun ||
                    WSdkManager.instance.platform == AccType.AccType_adr_official_branch ||
                    WSdkManager.instance.platform == AccType.AccType_ios_official)
                {
                    state = EInitState.eSelectCountry;
                }
                else
                {
                    state = EInitState.eCheckSDK;
                }
            }
        }
        else if (mState == EInitState.eAccountLogin)
        {
            if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_Succ)
            {
                mIgnoreList.Clear();
                mLSIndex = -1;
                state = EInitState.eConnectServerRandom;
            }
            else if (WSdkManager.instance.ResultCode != WSdkManager.ERetCode.eCode_None)
            {
                int lasttype = WSdkManager.instance.loginType;
                GameSetting.instance.LoadLoginInfo();
                if (lasttype == WSdkManager.instance.loginType)
                {
                    WSdkManager.instance.loginType = 0;
                }
                string msg;
                if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_Cancel)
                {
                    msg = TextManager.Instance.GetText("login_ui12");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_Error)
                {
                    msg = TextManager.Instance.GetText("login_ui14");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_NotRegisterRealName)
                {
                    msg = TextManager.Instance.GetText("Login_NotRegisterRealName");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_QQ_NotInstall)
                {
                    msg = TextManager.Instance.GetText("Login_QQ_NotInstall");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_QQ_NotSupportApi)
                {
                    msg = TextManager.Instance.GetText("Login_QQ_NotSupportApi");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_WX_NotInstall)
                {
                    msg = TextManager.Instance.GetText("Login_WX_NotInstall");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_WX_NotSupportApi)
                {
                    msg = TextManager.Instance.GetText("Login_WX_NotSupportApi");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_WX_UserDeny)
                {
                    msg = TextManager.Instance.GetText("Login_UserDeny");
                }
                else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_TokenInvalid)
                {
                    msg = TextManager.Instance.GetText("Login_TokenInvalid");
                }
                else
                {
                    msg = TextManager.Instance.GetText("Code_Login_AccountVerifyError");
                }
                PlayerPrefs.DeleteKey("logintype");
		        PlayerPrefs.Save();
                WSdkManager.instance.ResultCode = WSdkManager.ERetCode.eCode_None;
                //GUIMgr.Instance.MessageBox(msg, account_login_msgbox_on_ok, null);
                account_login_msgbox_on_ok();
            }
        }
        else if (mState == EInitState.eConnectServerRandom)
        {
            if (NetworkManager.instance.state == NetworkManager.EState.eState_Connected)
            {
                state = EInitState.eVerifyAccount;
            }
            else if (NetworkManager.instance.state == NetworkManager.EState.eState_Error)
            {
                if (mConnectLSTimes >= RANDOM_TIMES ||
                    mIgnoreList.Count >= ConfigFileManager.instance.m_ConfigData.mListLoginServer.Count ||
                    mLSIndex != -1)
                {
                    GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                    state = EInitState.eIdel;
                }
                else
                {
                    OnPrevStateChange(EInitState.eConnectServerRandom);
                }
            }
        }
        else if (mState == EInitState.eVerifyAccount ||
                 mState == EInitState.eVerifyAccountOK ||
                 mState == EInitState.eGameVerifyAccount)
        {
            if (NetworkManager.instance.state == NetworkManager.EState.eState_Error ||
                NetworkManager.instance.state == NetworkManager.EState.eState_Idel)
            {
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                state = EInitState.eIdel;
            }
            else if (mState == EInitState.eVerifyAccountOK)
            {
                state = EInitState.eRequestServerList;
            }
        }
        else if (mState == EInitState.eRequestServerList)
        {
            if (NetworkManager.instance.state == NetworkManager.EState.eState_Error ||
                NetworkManager.instance.state == NetworkManager.EState.eState_Idel)
            {
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                state = EInitState.eIdel;
            }
        }
        else if (mState == EInitState.eCheckEXEUpdate)
        {
            if (checkexeover)
            {
                state = EInitState.eCheckUpdate;
            }
        }
        else if (mState == EInitState.eCheckUpdate)
        {
            if (!AssetBundleManager.Instance.ischecking)
            {
                state = EInitState.eSelectZone;
            }
        }
        else if (mState == EInitState.eSelectZone)
        {
            if (NetworkManager.instance.state == NetworkManager.EState.eState_Error ||
                     NetworkManager.instance.state == NetworkManager.EState.eState_Idel)
            {
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                state = EInitState.eIdel;
            }
        }
        else if (mState == EInitState.eConnectGameServer)
        {
            if (NetworkManager.instance.state == NetworkManager.EState.eState_Connected)
            {
                state = EInitState.eGameVerifyAccount;
            }
            else if (NetworkManager.instance.state == NetworkManager.EState.eState_Error ||
                     NetworkManager.instance.state == NetworkManager.EState.eState_Idel)
            {
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                state = EInitState.eIdel;
            }
        }
        else if (mState == EInitState.eGetGameData)
        {
            Debug.Log(NetworkManager.instance.resMapCount());
            if (NetworkManager.instance.resMapCount() == 0)
            {
                state = EInitState.ePreloadGameResource;
            }
            else if (NetworkManager.instance.state == NetworkManager.EState.eState_Error ||
                    NetworkManager.instance.state == NetworkManager.EState.eState_Idel)
            {
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                state = EInitState.eIdel;
            }
            else
            {
                mWaitResponseMsgTime += Serclimax.GameTime.realDeltaTime;
                if(mWaitResponseMsgTime > 20.0f)
                {
                    GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
                    state = EInitState.eIdel;
                }
            }
        }
        else if (mState == EInitState.ePreloadGameResource)
        {
            bool finishedTeachBattle = (bool)loginScreen.CallFunc("HasFinishedTeachBattle", null)[0];
            LuaInterface.LuaFunction isAllLoaded = LuaClient.GetMainState().GetFunction("maincity.IsAllLoaded");
            bool loadedMaincity = (bool)isAllLoaded.Call(null)[0];
            isAllLoaded.Dispose();
            if (!finishedTeachBattle || loadedMaincity)
            {
                state = EInitState.eEnterNormalGame;
            }
        }
        else if (mState == EInitState.eEnterNormalGame)
        {
            bool finishedTeachBattle = (bool)loginScreen.CallFunc("HasFinishedTeachBattle", null)[0];
            if (finishedTeachBattle)
            {
                GetStateMachine().ChangeState(GameStateMain.Instance, null,null);
            }
            else
            {
                state = EInitState.eEnterTeachBattle;
            }
        }
        else if (mState == EInitState.eEnterTeachBattle)
        {
        }
    }

    public override void OnFixedUpdate()
    {
    }

    public override void OnLeave()
    {
        GUIMgr.Instance.CloseMenu("login");
        loginScreen.CallFunc("ShowStarwars", null);
        loginScreen = null;
        ResourceUnload.instance.ReleaseUnusedResource();

    }

    public void StateChange2AccountLogin()
    {
        PlayerPrefs.DeleteKey("logintype");
		PlayerPrefs.Save();
        GUIMgr.Instance.SetLanguage(TextManager.Instance.currentLanguage.ToString());
        if (WSdkManager.instance.platform == AccType.AccType_ios_kr_digiSky || WSdkManager.instance.platform == AccType.AccType_ios_tw_digiSky)
        {
            WSdkManager.instance.logoutPPGameMsbOnOk();
        }
        else if (WSdkManager.instance.platform == AccType.AccType_adr_mango)
        {
            WSdkManager.instance.ExtraFunction("accountlogout");
        }
        else
        {
            WSdkManager.instance.logoutMsbOnOk();
        }
        //GUIMgr.Instance.CloseAllMenu();
        //NetworkManager.instance.Close();
        //Main.Instance.ChangeGameState(GameStateLogin.Instance, null);
    }

    public void SettingAccountLogout(string language)
    {
        PlayerPrefs.DeleteKey("logintype");
		PlayerPrefs.Save();
        GUIMgr.Instance.SetLanguage(language);
        if (WSdkManager.instance.platform == AccType.AccType_adr_efun || WSdkManager.instance.platform == AccType.AccType_adr_mango)
        {
            WSdkManager.instance.ExtraFunction("accountlogout");
        }
        else if (WSdkManager.instance.platform == AccType.AccType_ios_kr_digiSky || WSdkManager.instance.platform == AccType.AccType_ios_tw_digiSky)
        {
            WSdkManager.instance.logoutPPGameMsbOnOk();
        }
        else if (WSdkManager.instance.platform == AccType.AccType_adr_quick || WSdkManager.instance.platform == AccType.AccType_adr_qihu)
        {
            WSdkManager.instance.Logout();
        }
        else
        {
            WSdkManager.instance.logoutMsbOnOk();
        }
    }

    void checkconf_msgbox_on_ok()
    {
        state = EInitState.eCheckConfig;
    }

    void account_login_msgbox_on_ok()
    {
        //OnPrevStateChange(EInitState.eAccountLogin);
        state = EInitState.eCheckSDK;
    }

    void checkconf_msgbox_on_cancel()
    {

    }

    void OnStateChange(EInitState _state)
    {
        mNextState = _state;
    }

    void OnCheckConfig()
    {
        if (loginScreen != null)
        {
            bool hasorder1 = false;
            bool hasorder2 = false;
            string names = "";
            for (int i = 0; i < ConfigFileManager.instance.m_ConfigData.mListLoginServer.Count; i++)
            {
                if ((ConfigFileManager.instance.m_ConfigData.mListLoginServer[i].mServerOrder == 1 && hasorder1) ||
                    (ConfigFileManager.instance.m_ConfigData.mListLoginServer[i].mServerOrder == 2 && hasorder2))
                {
                    continue;
                }
                if (i > 0)
                {
                    names += ";";
                }
                names += ConfigFileManager.instance.m_ConfigData.mListLoginServer[i].mServerName + ";" + ConfigFileManager.instance.m_ConfigData.mListLoginServer[i].mServerOrder;
                hasorder1 = ConfigFileManager.instance.m_ConfigData.mListLoginServer[i].mServerOrder == 1;
                hasorder2 = ConfigFileManager.instance.m_ConfigData.mListLoginServer[i].mServerOrder == 2;
            }
            //names += ";" + index;
            Debug.Log("!!!!!!!!!!!!firstlogin:" + PlayerPrefs.HasKey("firstlogin") + "    countryindex:" + PlayerPrefs.HasKey("countryindex"));
            if (PlayerPrefs.HasKey("firstlogin") && !PlayerPrefs.HasKey("countryindex"))
            {
                loginScreen.CallFunc("SelectCountry", names);
            }
            else
            {
                SelectCounty(PlayerPrefs.HasKey("countryindex") ? PlayerPrefs.GetInt("countryindex") : 1);
            }
        }
    }

    int order = 0;

    public void SelectCounty(int index)
    {
        order = index;
        PlayerPrefs.SetInt("countryindex", index);
        PlayerPrefs.Save();
        state = EInitState.eCheckSDK;
    }

    public void ResetCountry()
    {
        PlayerPrefs.DeleteKey("countryindex");
        mLSIndex = -1;
        state = EInitState.eCheckConfig;
    }

    public void Login(int zoneId, int charId, byte[] AreaData)
    {
        WSdkManager.instance.zoneId = zoneId;
        WSdkManager.instance.charId = charId;
        mAreaData = NetworkManager.instance.Decode<DtoAreaInfo>(AreaData);
        state = EInitState.eCheckEXEUpdate;
        GameSetting.instance.SaveLoginInfo();
    }

    public void EditorLogin(int type, int zoneId, string accKey)
    {
        WSdkManager.instance.loginType = type;
        WSdkManager.instance.zoneId = zoneId;
        WSdkManager.instance.uid = accKey;
        state = EInitState.eAccountLogin;
    }

    public void SDKLogin(int type)
    {
        if (type == -1)
        {
            if (loginScreen != null)
            {
                loginScreen.CallFunc("ResetToStart", null);
            }
            WSdkManager.instance.Logout();
            WSdkManager.instance.loginType = 0;
            WSdkManager.instance.uid = "";
            WSdkManager.instance.session = "";
            OnStateChange(EInitState.eCheckSDK);
            return;
        }
        if (WSdkManager.instance.loginType != type)
        {
            WSdkManager.instance.uid = "";
            WSdkManager.instance.session = "";
        }
        WSdkManager.instance.loginType = type;
        state = EInitState.eAccountLogin;
    }

    public delegate void OnSDKBind(int code, uint acctype, string acckey, string acctoken, string accname, string package, string deviceid, string publickeyurl, string salt, string signature, string timestamp);
    public void SDKBind(int type, OnSDKBind callback)
    {
        WSdkManager.instance.onLoginDelegate = () =>
        {
            if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_Succ)
            {
                callback(
                        (int)WSdkManager.instance.ResultCode,
                        (uint)WSdkManager.instance.loginType,
                        WSdkManager.instance.uid,
                        WSdkManager.instance.session,
                        WSdkManager.instance.uname,
                        WSdkManager.instance.GetPackageName(),
                        PlatformUtils.GetUniqueIdentifier(),
                        WSdkManager.instance.keyurl,
                        WSdkManager.instance.salt,
                        WSdkManager.instance.signature,
                        WSdkManager.instance.timestamp
                        );
            }
            else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_Cancel)
            {
                //GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_ui15"), account_login_msgbox_on_ok, null);
                account_login_msgbox_on_ok();
            }
            else if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_Error)
            {
                //GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_ui14"), account_login_msgbox_on_ok, null);
                account_login_msgbox_on_ok();
            }
            else
            {
                //GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("Code_Login_AccountVerifyError"), account_login_msgbox_on_ok, null);
                account_login_msgbox_on_ok();
            }
            WSdkManager.instance.onLoginDelegate = null;
        };
        WSdkManager.instance.Login((LoginType)type);
    }

    void ShowTip(string tip)
    {
        if (loginScreen != null)
        {
            loginScreen.CallFunc("ShowTip", tip);
        }
    }

    void ShowTipByKey(string tipTextKey)
    {
        ShowTip(TextManager.Instance.GetText(tipTextKey));
    }

    void OnPrevStateChange(EInitState _state)
    {
        if (loginScreen != null && _state > EInitState.eRequestServerListOK)
        {
            loginScreen.CallFunc("SetProgress", ((float)(_state - EInitState.eRequestServerListOK) / (float)(EInitState.eCount - EInitState.eRequestServerListOK)));
        }
        if (_state == EInitState.eIdel)
        {
            ShowTip(String.Empty);
        }
        else if (_state == EInitState.eCheckSDK)
        {
            if (WSdkManager.instance.platform == AccType.AccType_adr_tmgp ||
                WSdkManager.instance.platform == AccType.AccType_adr_official ||
                WSdkManager.instance.platform == AccType.AccType_ios_official ||
                WSdkManager.instance.platform == AccType.AccType_ios_india ||
                 WSdkManager.instance.platform == AccType.AccType_ios_efun ||
                WSdkManager.instance.platform == AccType.AccType_adr_official_branch)
            {
                WSdkManager.instance.ResultCode = WSdkManager.ERetCode.eCode_None;
                if (loginScreen != null)
                {
                    loginScreen.CallFunc("ShowTmgp", null);
                }
            }
            if (WSdkManager.instance.platform == AccType.AccType_adr_efun ||
                WSdkManager.instance.platform == AccType.AccType_adr_muzhi ||
                WSdkManager.instance.platform == AccType.AccType_ios_muzhi ||
                WSdkManager.instance.platform == AccType.AccType_ios_muzhi2 ||
                WSdkManager.instance.platform == AccType.AccType_adr_moliyou ||
                WSdkManager.instance.platform == AccType.AccType_adr_mango ||
                WSdkManager.instance.platform == AccType.AccType_adr_opgame ||
                WSdkManager.instance.platform == AccType.AccType_adr_quick ||
                WSdkManager.instance.platform == AccType.AccType_adr_qihu)
            {
                WSdkManager.instance.ResultCode = WSdkManager.ERetCode.eCode_None;
                if (loginScreen != null)
                {
                    loginScreen.CallFunc("NotShowAccount", null);
                }
            }
            if (WSdkManager.instance.platform == AccType.AccType_adr_kr_digiSky ||
                WSdkManager.instance.platform == AccType.AccType_adr_tw_digiSky ||
                WSdkManager.instance.platform == AccType.AccType_ios_kr_digiSky ||
                WSdkManager.instance.platform == AccType.AccType_ios_tw_digiSky ||
                WSdkManager.instance.platform == AccType.AccType_adr_kr_onestore)
            {
                WSdkManager.instance.loginType = 0;
                WSdkManager.instance.ResultCode = WSdkManager.ERetCode.eCode_None;
                if (loginScreen != null)
                {
                    loginScreen.CallFunc("ShowPPGame", null);
                }
            }
            /*if (WSdkManager.instance.platform == AccType.AccType_adr_opgame)
            {
                WSdkManager.instance.ResultCode = WSdkManager.ERetCode.eCode_None;
                if (loginScreen != null)
                {
                    loginScreen.CallFunc("ShowGWX", null);
                }
            } */
        }
        else if (_state == EInitState.eCheckConfig)
        {
            ShowTipByKey("login_hint2");
            NetworkManager.instance.EncryptKey = null;
            if (loginScreen != null)
            {
                loginScreen.CallFunc("ResetToStart", null);
            }

            ConfigFileManager.instance.StartCheckConf();
            
            mConnectLSTimes = 0;
        }
        else if (_state == EInitState.eSelectCountry)
        {
            OnCheckConfig();
        }
        else if (_state == EInitState.eAccountLogin)
        {
            ShowTipByKey("login_hint1");
            WSdkManager.instance.Login((LoginType)WSdkManager.instance.loginType);
        }
        else if (_state == EInitState.eConnectServerRandom)
        {
            ShowTipByKey("login_hint10");
            int index = mLSIndex;
            List<ConfigFileManager.ServerData> randomList = new List<ConfigFileManager.ServerData>();
            if (mIgnoreList.Count < ConfigFileManager.instance.m_ConfigData.mListLoginServer.Count)
            {
                for (int i = 0; i < ConfigFileManager.instance.m_ConfigData.mListLoginServer.Count; i++)
                {
                    if (order != 0)
                    {
                        if (!mIgnoreList.Contains(i) && ConfigFileManager.instance.m_ConfigData.mListLoginServer[i].mServerOrder == order)
                            randomList.Add(ConfigFileManager.instance.m_ConfigData.mListLoginServer[i]);
                    }
                    else
                    {
                        if (!mIgnoreList.Contains(i))
                            randomList.Add(ConfigFileManager.instance.m_ConfigData.mListLoginServer[i]);
                    }
                }
            }

            index = UnityEngine.Random.Range(0, randomList.Count);
            ConfigFileManager.ServerData data = randomList[index];
            if (data != null)
            {
                NetworkManager.instance.Close();
                NetworkManager.instance.ConnectServer(data.mServerIp, data.mServerPort);
                mConnectLSTimes++;
                mIgnoreList.Add(index);
            }
            else
            {
                Serclimax.DebugUtils.Log("server info is invalid!");
                state = EInitState.eCheckConfig;
            }
        }
        else if (_state == EInitState.eVerifyAccount)
        {
            ShowTipByKey("login_hint11");

            MsgLoginVerifyAccount_ver2_CS req = new MsgLoginVerifyAccount_ver2_CS();
            req.accType = (uint)WSdkManager.instance.loginType;
            req.accUserName = WSdkManager.instance.uname;
            req.accKey = WSdkManager.instance.uid;
            req.accToken = WSdkManager.instance.session;
            req.lastZoneId = (uint)WSdkManager.instance.zoneId;
            req.exeVersion = GameSetting.instance.option.mExeVersion;
            req.resVersion = GameSetting.instance.option.mResVersion;
            req.package = WSdkManager.instance.GetPackageName();
            req.deviceid = PlatformUtils.GetUniqueIdentifier();
            req.platType = (uint)WSdkManager.instance.platform;
            req.timestamp = WSdkManager.instance.timestamp;
            req.signature = WSdkManager.instance.signature;
            req.devicetoken = WSdkManager.instance.devicetoken;
            req.clientLang = (uint)Application.systemLanguage;

            NetworkManager.instance.Request<MsgLoginVerifyAccount_ver2_CS>((uint)MsgCategory.Login, (uint)LoginTypeId.Login.MsgLoginVerifyAccount_ver2_CS, req, onVerifyAccount);
        }
        else if (_state == EInitState.eVerifyAccountOK)
        {
        }
        else if (_state == EInitState.eRequestServerList)
        {
            ShowTipByKey("ui_zone18");
            loginScreen.CallFunc("RequestServerList", null);
        }
        else if (_state == EInitState.eRequestServerListOK)
        {
            if (loginScreen != null)
            {
                var lastZoneInfo = mAreaData.zonelist[0];
                object[] param = new object[8];
                param[0] = lastZoneInfo.zoneId;
                param[1] = WSdkManager.instance.uid;
                param[2] = WSdkManager.instance.loginType;
                param[3] = WSdkManager.instance.uname;

                loginScreen.CallFunc("ShowLogin", param);
            }
        }
        else if (_state == EInitState.eCheckEXEUpdate)
        {
            ShowTipByKey("login_hint2");
            checkexeover = false;
            Debug.Log("!!!!!!!!!!" + mAreaData.updateText + " " + mAreaData.exeUpdateUrl + " " + mAreaData.isExeUpdate);
            if (mAreaData.isExeUpdate)
            {
                var updateVersionShow = LuaClient.GetMainState().GetFunction("UpdateVersion.Show");
                updateVersionShow.Call(mAreaData.updateText, mAreaData.exeUpdateUrl, mAreaData.isExeUpdate);
                updateVersionShow.Dispose();
                mState = EInitState.eIdel;
            }
            else
            {
                if (mAreaData.exeUpdateVer != "")
                {
                    if (float.Parse(GameSetting.instance.option.mExeVersion) < float.Parse(mAreaData.exeUpdateVer))
                    {
                        var updateVersionShow = LuaClient.GetMainState().GetFunction("UpdateVersion.Show");
                        updateVersionShow.Call(mAreaData.updateText, mAreaData.exeUpdateUrl, mAreaData.isExeUpdate);
                        updateVersionShow.Dispose();
                        mState = EInitState.eIdel;
                    }
                    else
                    {
                        checkexeover = true;
                    }
                }
                else
                {
                    checkexeover = true;
                }
            }
        }
        else if (_state == EInitState.eCheckUpdate)
        {
            AssetBundleManager.Instance.CheckAssets();
            AssetBundleManager.Instance.onCheckPercent += (a) =>
            {
                if (loginScreen != null)
                {
                    loginScreen.CallFunc("SetProgress", a);
                    ShowTip(String.Format(TextManager.Instance.GetText("update_ui8"), a, AssetBundleManager.Instance.GetTotalSize()));
                }
            };
            AssetBundleManager.Instance.onBundleLoad += (b) =>
            {
                //ShowTip(b);
            };
            AssetBundleManager.Instance.isChecking += (c) =>
            {
                if (!c)
                {
                    if (AssetBundleManager.Instance.needReload)
                    {
                        TextManager.Instance.Clear();
#if SUPPORT_CHANGE_SCENE
                        ChangeSceneHeldObject.ClearHeldObjects();
                        UnityEngine.SceneManagement.SceneManager.UnloadScene(1);
#endif
                        UnityEngine.SceneManagement.SceneManager.UnloadScene(0);


                        if (NetworkManager.instance != null)
                        {
                            NetworkManager.instance.Close();
                        }

                        UIEventListener[] list = GameObject.FindObjectsOfType<UIEventListener>();
                        for (int i = 0; i < list.Length; i++)
                        {
                            list[i].enabled = false;
                        }
                        UIButton[] list1 = GameObject.FindObjectsOfType<UIButton>();
                        for (int i = 0; i < list1.Length; i++)
                        {
                            list1[i].enabled = false;
                        }
                        UnityEngine.SceneManagement.SceneManager.LoadScene("Main");
                    }
                }
            };
            AssetBundleManager.Instance.SetVersion(resVersion);
            if (!string.IsNullOrEmpty(resUrl))
            {
                AssetBundleManager.Instance.CheckAssets(resUrl);
            }
            //AssetBundleManager.Instance.SetVersion("0");
            //AssetBundleManager.Instance.CheckAssets();
        }
        else if (_state == EInitState.eSelectZone)
        {
            AssetBundleManager.Instance.ClearDelegate();
           // GUIMgr.Instance.CacheUIPrefab();
            ShowTipByKey("login_hint12");
            MsgLoginSelectZone_CS req = new MsgLoginSelectZone_CS();
            req.zoneId = (uint)WSdkManager.instance.zoneId;
            NetworkManager.instance.Request<MsgLoginSelectZone_CS>((uint)MsgCategory.Login, (uint)LoginTypeId.Login.MsgLoginSelectZone_CS, req, onSelectZone);
        }
        else if (_state == EInitState.eConnectGameServer)
        {
            ShowTipByKey("login_hint13");
            NetworkManager.instance.Close();
            NetworkManager.instance.ConnectServer(mGameServerIp, mGameServerPort.ToString());
            NetworkManager.instance.EnableAutoConnect = true;
        }

        else if (_state == EInitState.eGetGameData)
        {
            mWaitResponseMsgTime = 0;
            Debug.Log("getGameData:start wait :" + mWaitResponseMsgTime);
        }
        else if (_state == EInitState.eGameVerifyAccount)
        {
            ShowTipByKey("login_hint14");
            MsgLoginGameVerifyAccount_CS req = new MsgLoginGameVerifyAccount_CS();
            req.accId = WSdkManager.instance.loginId;
            req.accType = (uint)WSdkManager.instance.loginType;
            req.loginPasswd = WSdkManager.instance.loginPassword;
            req.accKey = WSdkManager.instance.uid;
            req.accUserName = WSdkManager.instance.uname;
            req.deviceId = PlatformUtils.GetUniqueIdentifier();
            req.package = WSdkManager.instance.GetPackageName() + (string.IsNullOrEmpty(WSdkManager.instance._Channel) ? "" : "-channel." + WSdkManager.instance._Channel);
            req.acctoken = WSdkManager.instance.session;
            req.pf = WSdkManager.instance.salt;
            req.pfkey = WSdkManager.instance.signature;
            req.payToken = WSdkManager.instance.keyurl;
            req.platType = (uint)WSdkManager.instance.platform;
            req.charId = (uint)WSdkManager.instance.charId;

            NetworkManager.instance.Request<MsgLoginGameVerifyAccount_CS>((uint)MsgCategory.Login, (uint)LoginTypeId.Login.MsgLoginGameVerifyAccount_CS, req, onGameVerifyAccount);
        }
        else if (_state == EInitState.ePreloadGameResource)
        {
            if (loginScreen != null)
            {
                loginScreen.CallFunc("PreloadGameResource", null);
            }
        }
        else if (_state == EInitState.eEnterTeachBattle)
        {
            if (loginScreen != null)
            {
                loginScreen.CallFunc("StartTeachBattle", null);
            }
        }
    }

    void onVerifyAccount(byte[] data)
    {
        MsgLoginVerifyAccount_ver2_SC rsp = NetworkManager.instance.Decode<MsgLoginVerifyAccount_ver2_SC>(data);
        if (rsp.code == (uint)RequestCode.Code_OK)
        {
            WSdkManager.instance.zoneId = (int)rsp.lastAreaInfo.zonelist[0].zoneId;
            WSdkManager.instance.zoneName = rsp.lastAreaInfo.zonelist[0].zoneName;
            state = EInitState.eVerifyAccountOK;
            resVersion = rsp.lastAreaInfo.resVersion;
            resUrl = rsp.lastAreaInfo.resUpdateUrl;
            if (!string.IsNullOrEmpty(resUrl))
            {
                if (resUrl.Contains("Assetbundles_android/"))
                {
                    resUrl.Replace("Assetbundles_android/", "");
                }
#if UNITY_IPHONE
                resUrl += "Assetbundles_ios/";
#endif
#if UNITY_ANDROID
                resUrl += "Assetbundles_android/";
#endif
            }
            mAreaData = rsp.lastAreaInfo;

            if (loginScreen != null)
            {
                loginScreen.CallFunc("StartNotice", rsp.notice, GameVersion.EXE);
            }
        }
        else
        {
            GameSetting.instance.LoadLoginInfo();
            PlayerPrefs.DeleteKey("logintype");
            PlayerPrefs.Save();
            NetworkManager.instance.ErrorCodeHandler(rsp.code, checkconf_msgbox_on_ok , rsp.forbid);
            state = EInitState.eIdel;
        }
    }

    void onSelectZone(byte[] data)
    {
        MsgLoginSelectZone_SC rsp = NetworkManager.instance.Decode<MsgLoginSelectZone_SC>(data);
        if (rsp.code == (uint)RequestCode.Code_OK)
        {
            WSdkManager.instance.loginId = rsp.accId;
            WSdkManager.instance.loginPassword = rsp.loginPasswd;
            NetworkManager.instance.EncryptKey = rsp.encryptKey;
            mGameServerIp = rsp.ip;
            mGameServerPort = rsp.port;

            state = EInitState.eConnectGameServer;
        }
        else
        {
            NetworkManager.instance.ErrorCodeHandler(rsp.code, checkconf_msgbox_on_ok);
            state = EInitState.eIdel;
        }
    }

    void onGameVerifyAccount(byte[] data)
    {
        MsgLoginGameVerifyAccount_SC rsp = NetworkManager.instance.Decode<MsgLoginGameVerifyAccount_SC>(data);
        if (rsp.code == (uint)RequestCode.Code_OK)
        {
            WSdkManager.instance.reconnectKey = (int)rsp.reconnKey;
            if (loginScreen != null)
            {
                loginScreen.CallFunc("RequestData", null);
            }
           
            MsgFreshClientDevicetokenRequest req = new MsgFreshClientDevicetokenRequest();

            req.devicetoken = WSdkManager.instance.devicetoken;
            NetworkManager.instance.Request<MsgFreshClientDevicetokenRequest>((uint)MsgCategory.Client, (uint)ClientTypeId.Client.MsgFreshClientDevicetokenRequest, req, null);

            BuglyAgent.SetUserId(String.Format("{0}#{1}#{2}", WSdkManager.instance.uid, WSdkManager.instance.zoneId, WSdkManager.instance.zoneName));

            state = EInitState.eGetGameData;
        }
        else
        {
            NetworkManager.instance.ErrorCodeHandler(rsp.code, checkconf_msgbox_on_ok , rsp.forbid);
            state = EInitState.eIdel;
        }
    }

    public void CancelUpdateVersion()
    {
        checkexeover = true;
    }

    public void OnRequestServerList()
    {
        if (state == EInitState.eRequestServerList)
        {
            state = EInitState.eRequestServerListOK;
        }
    }

    public void ReLogin()
    {
        GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_hint7"), checkconf_msgbox_on_ok, null);
        state = EInitState.eIdel;
    }
}
