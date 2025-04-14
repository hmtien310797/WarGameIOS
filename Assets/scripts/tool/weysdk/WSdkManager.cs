using UnityEngine;
using System.Collections;
using System.Collections.Generic;

using ProtoMsg;
using Serclimax;
using System;

#if UNITY_IPHONE
using System.Runtime.InteropServices;
#endif

public class WSdkManager
{
    public delegate void OnLoginDelegate();
    public OnLoginDelegate onLoginDelegate;
    public bool isRecharging;

    public enum ELoginType
    {
        eLogin_Normal = 0,
        eLogin_QQ,
        eLogin_WX,
        eLogin_GameCenter,
        eLogin_GooglePlay,
        eLogin_Facebook,
        eLogin_Efun,
        eLogin_PPGame,
		eLogin_MZYW,
        eLogin_OPGame,
    }
    
    public enum ERetCode
    {
        eCode_None = 0,
        eCode_Succ,
        eCode_Fail,
        eCode_Cancel,
        eCode_Error,
        eCode_QQ_NotInstall,
        eCode_QQ_NotSupportApi,
        eCode_WX_NotInstall,
        eCode_WX_NotSupportApi,
        eCode_WX_UserDeny,
        eCode_TokenInvalid,
        eCode_NotRegisterRealName,
    }

    public enum ESocialType
    {
        eType_Weixin = 0,
        eType_Weibo,
        eType_Facebook,
    }

    public enum ESocialScene
    {
        eScene_Session = 0,
        eScene_Timeline
    }

    private string mUid = "";
    public string uid
    {
        get
        {
            return mUid;
        }
        set
        {
            mUid = value;
        }
    }

    private string mUName = "";

    public int charId { get; internal set; }

    public string uname
    {
        get
        {
            return mUName;
        }
        set
        {
            mUName = value;
        }
    }

    private string mSession = "";
    public string session
    {
        get
        {
            return mSession;
        }
        set
        {
            mSession = value;
        }
    }

    private string mKeyUrl = "";
    public string keyurl
    {
        get
        {
            return mKeyUrl;
        }
        set
        {
            mKeyUrl = value;
        }
    }

    //for tmgp is pf
    private string mSalt = "";
    public string salt
    {
        get
        {
            return mSalt;
        }
        set
        {
            mSalt = value;
        }
    }

    //for tmgp is pf_key
    private string mSignature = "";
    public string signature
    {
        get
        {
            return mSignature;
        }
        set
        {
            mSignature = value;
        }
    }

    private string mTimeStamp = "";
    public string timestamp
    {
        get
        {
            return mTimeStamp;
        }
        set
        {
            mTimeStamp = value;
        }
    }

    private string mDeviceToken = "";
    public string devicetoken
    {
        get
        {
            return mDeviceToken;
        }
        set
        {
            mDeviceToken = value;
        }
    }

    private string mOsVersion;

    public string osVersion
    {
        get { return mOsVersion; }
        set { mOsVersion = value; }
    }

    private string m_model;

    public string model
    {
        get { return m_model; }
        set { m_model = value; }
    }


    private Dictionary<string, int> mZoneIdList = new Dictionary<string, int>();

    public Dictionary<string, int> zoneIdList
    {
        get { return mZoneIdList; }
        set { mZoneIdList = value; }
    }

    private int mZoneId = 0;
    public int zoneId
    {
        get { return mZoneId; }
        set { mZoneId = value; }
    }

    private string mZoneName = "";
    public string zoneName
    {
        get { return mZoneName; }
        set { mZoneName = value; }
    }

    private int mLoginType = 0;
    public int loginType
    {
        get { return mLoginType; }
        set { mLoginType = value; }
    }

    private uint mLoginId = 0;
    public uint loginId
    {
        get { return mLoginId; }
        set { mLoginId = value; }
    }

    private ulong mLoginPassword = 0;
    public ulong loginPassword
    {
        get { return mLoginPassword; }
        set { mLoginPassword = value; }
    }

    private int mReconnectKey = 0;
    public int reconnectKey
    {
        get { return mReconnectKey; }
        set { mReconnectKey = value; }
    }

    private string mProductId;
    public string ProductId
    {
        get { return mProductId; }
        set { mProductId = value; }
    }


    private static WSdkManager sInstance;
    public static WSdkManager instance
    {
        get
        {
            if (sInstance == null)
            {
                sInstance = new WSdkManager();
                sInstance.Init();
            }
            return sInstance;
        }
    }

    private ERetCode mRechargeCode;
    private string mRechargeMsg;
    private ERetCode mResultCode;
    public ERetCode ResultCode
    {
        get
        {
            return mResultCode;
        }
        set
        {
            mResultCode = value;
        }
    }

    private AccType mPlatform;
    public AccType platform
    {
        get
        {
            return mPlatform;
        }
    }

    private string _channel;

    public string _Channel
    {
        get { return _channel; }
        set { _channel = value; }
    }


    //only for postprocess
    public static AccType mChannel = AccType.AccType_self_ios;


    public TextManager.LANGUAGE GetSystemLanguage()
    {
        TextManager.LANGUAGE lan = TextManager.LANGUAGE.VN;
#if USE_STEAM
        int la = SteamManager.GetLanguage();
        if (la > 0)
        {
            return (TextManager.LANGUAGE)la;
        }

#endif

        ScGlobalData def_data = Main.Instance.TableMgr.GetTable<ScGlobalData>().GetData(201);
        if (def_data != null)
        {
            int def;
            if (int.TryParse(def_data.value, out def))
            {
                if (def >= 0 || def <= TextManager.LANGUAGE_COUNT - 1)
                {
                    lan = (TextManager.LANGUAGE)def;
                }
            }
        }
        Debug.Log("The default language is: "+lan.ToString());
        TextManager.LANGUAGE syslan;
        if (!TextManager.SysTolocalMap.TryGetValue(Application.systemLanguage, out syslan))
        {
            //���ϵͳ����û���ڱ��������ж���� �򷵻�Ӣ��
            return lan;
        }
        Debug.Log("The System language is: "+Application.systemLanguage.ToString()+"  Identified as: "+syslan.ToString());

        ScGlobalData lan_data = Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.OnLimitsLanguage);
        if (lan_data == null)
        {
            Debug.Log("No open language version was detected, default language was used: "+lan.ToString());
            return lan;
        }
        Debug.Log("open language version: "+lan_data.value);

        string onlimits = lan_data.value;
        if (onlimits != "")
        {
            string[] ls = onlimits.Split(',');
            if (ls != null)
            {
                int l;
                for (int i = 0; i < ls.Length; i++)
                {
                    if (ls[i] != "")
                    {
                        Debug.Log(" Check the open language: "+ls[i]);
                        if (int.TryParse(ls[i], out l))
                        {
                            Debug.Log(" Judging the local language corresponding to the current system language: "+(int)syslan+"=="+i+"?");
                            if ((int)syslan == l)
                            {
                                Debug.Log((int)syslan+"=="+i + " Return to the system language "+syslan.ToString());
                                //�����ǰ��ϵͳ���Զ�Ӧ�ı������� �Ѿ�������ʹ�� 
                                return syslan;
                            }
                        }
                        else
                        {
                            Debug.Log(" Check the open language: "+ls[i]+"  Configuration error");
                        }
                    }
                }
            }
        }

        //if (Application.systemLanguage == SystemLanguage.Chinese ||
        //    Application.systemLanguage == SystemLanguage.ChineseSimplified)
        //{
        //    lan = TextManager.LANGUAGE.CN 

;
        //}
        //else if (Application.systemLanguage == SystemLanguage.ChineseTraditional)
        //{
        //    lan = TextManager.LANGUAGE.TCN;
        //}

        Debug.Log("Return to the default language "+lan.ToString());
        return lan;
    }

    private bool mPlatformInited = false;
    private bool mSubmitRoleInfo = false;
    private string mIdentifier = "";
    private string mTransactionReveipt = "";
    private int mChargeChanelType = 0;
    private int mPayType = 0;
    private string mOrderId = "";
    private string mPlatOrderId = "";
    private string mPrice = "";
    private int mEfunPrice = 0;
    private bool mWaitingResponse = false;
    public void Update()
    {
        if (mWaitingResponse)
        {
            if (mSubmitRoleInfo)
            {
                if (mRechargeCode != ERetCode.eCode_None)
                {
                    if (mRechargeCode == ERetCode.eCode_Cancel)
                    {
                        GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_ui12"), null, null);
                    }
                    else if (mRechargeCode == ERetCode.eCode_Error)
                    {
                        GUIMgr.Instance.MessageBox(mRechargeMsg, null, null);
                    }
                    else if (mRechargeCode == ERetCode.eCode_TokenInvalid)
                    {
                        GameStateLogin.Instance.StateChange2AccountLogin();
                    }
                    else if (mRechargeCode == ERetCode.eCode_Succ)
                    {
                        object[] param = new object[8];
                        param[0] = string.IsNullOrEmpty(mOrderId) ? "" : mOrderId;
                        param[1] = string.IsNullOrEmpty(mTransactionReveipt) ? "" : mTransactionReveipt;
                        param[2] = mChargeChanelType == 0 ? GetChargeChanelType() : mChargeChanelType;
                        param[3] = string.IsNullOrEmpty(mProductId) ? "" : mProductId;
                        param[4] = string.IsNullOrEmpty(mSignature) ? "" : mSignature;
                        param[5] = string.IsNullOrEmpty(mPlatOrderId) ? mOrderId : mPlatOrderId;
                        param[6] = string.IsNullOrEmpty(mIdentifier) ? "" : mIdentifier;
                        param[7] = mPayType;
                        LuaClient.GetMainState().GetFunction("store.Deliver").Call(param);
                        Debug.Log("call Deliver");
                    }

                    if (mRechargeCode != ERetCode.eCode_Succ)
                    {
                        isRecharging = false;
                    }

                    mRechargeCode = ERetCode.eCode_None;
                    mRechargeMsg = "";
                    mWaitingResponse = false;
                }
            }
        }
    }

#region callback
    public void OnInitCallback(string _param)
    {
        Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(_param) as Dictionary<string, object>;

        if (!data.ContainsKey("code"))
        {
            DebugUtils.Log("callback format is invalid!");
            return;
        }

        if (data.ContainsKey("no_wexin"))
        {
            PlayerPrefs.SetInt("no_wexin", 1);
        }
        else
        {
            PlayerPrefs.SetInt("no_wexin", 0);
        }

        DebugUtils.Log("OnInitCallback:" + (string)data["code"]);

        mResultCode = (ERetCode)int.Parse((string)data["code"]);
        mPlatformInited = (mResultCode == ERetCode.eCode_Succ);
    }

    public void OnLoginCallback(string _param)
    {
        GUIMgr.Instance.UnlockScreen();
        Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(_param) as Dictionary<string, object>;
        if (data.ContainsKey("devicetoken"))
        {
            devicetoken = (string)data["devicetoken"];
            Debug.Log("devicetoken:" + devicetoken);
        }
        if (data.ContainsKey("_channel"))
        {
            _Channel = (string)data["_channel"];
            DebugUtils.Log("OnLoginCallback channel:" + _Channel);
        }
        if (!data.ContainsKey("code"))
        {
            DebugUtils.Log("callback format is invalid!");
            return;
        }

        DebugUtils.Log("OnLoginCallback:" + (string)data["code"]);
        Debug.Log("LoginCallback:" + data);
        
        ERetCode localcode = (ERetCode)int.Parse((string)data["code"]);
        if (localcode == ERetCode.eCode_Succ)
        {
            uid = (string)data["uid"];
            uname = (string)data["uname"];

            if (data.ContainsKey("session"))
            {
                session = (string)data["session"];
                Debug.Log("session:" + session);
            }

            if (data.ContainsKey("keyurl"))
            {
                keyurl = (string)data["keyurl"];
                Debug.Log("keyurl:" + keyurl);
            }

            if (data.ContainsKey("salt"))
            {
                salt = (string)data["salt"];
                Debug.Log("salt:" + salt);
            }

            if (data.ContainsKey("signature"))
            {
                signature = (string)data["signature"];
                Debug.Log("signature:" + signature);
            }

            if (data.ContainsKey("timestamp"))
            {
                timestamp = (string)data["timestamp"];
                Debug.Log("timestamp:" + timestamp);
            }

            if (data.ContainsKey("devicetoken"))
            {
                devicetoken = (string)data["devicetoken"];
                Debug.Log("devicetoken:" + devicetoken);
            }

            if (data.ContainsKey("logintype"))
            {
                loginType = int.Parse((string)data["logintype"]);
            }
        }
        mResultCode = localcode;
        if (onLoginDelegate != null)
        {
            onLoginDelegate();
        }

        //fix bug: acctoken timeout
        if (!Main.Instance.IsInInitState() && !Main.Instance.IsInLoginState())
        {
            MsgUpdateAccessDataRequest req = new MsgUpdateAccessDataRequest();
            req.acctoken = session;
            req.pf = salt;
            req.pfkey = signature;
            req.payToken = keyurl;

            NetworkManager.instance.Request<MsgUpdateAccessDataRequest>((uint)MsgCategory.Client, (uint)ClientTypeId.Client.MsgUpdateAccessDataRequest, req, null);
        }

    }

    public void OnLogoutCallback(string _param)
    {
        //todo weywang
        //GUIMgr.Instance.MessageBox(TextManager.Instance.GetText(Text.account_logout_hint), logoutMsbOnOk, null);
        if (_param.Equals("efun"))
        {
            Main.Instance.StartCoroutine(logoutProcess());
        }
        else if (_param.Equals("PPGame") || _param.Equals("normal")) {
            Main.Instance.StartCoroutine(logoutPPGameProcess());
        }
    }
    private IEnumerator logoutPPGameProcess()
    {
        GUIMgr.Instance.LockScreen();
        yield return new WaitForSeconds(1);
        logoutPPGameMsbOnOk();
    }
    public void logoutPPGameMsbOnOk()
    {
        GameSetting.OptionData od = GameSetting.instance.option;
        od.mLanguage = GUIMgr.Instance.targetLanguage;
        GameSetting.instance.option = od;
        GameSetting.instance.SaveOption();

        GameSetting.instance.ClearLoginInfo();
        GameSetting.instance.SaveLoginInfo();
        mSubmitRoleInfo = false;
        mResultCode = ERetCode.eCode_None;
        NetworkManager.instance.BackToLogin();
        mSubmitRoleInfo = false;
    }

    private IEnumerator logoutProcess()
    {
        GUIMgr.Instance.LockScreen();
        yield return new WaitForSeconds(1);
        logoutMsbOnOk();
    }

    public void logoutMsbOnOk()
    {
        GameSetting.OptionData od = GameSetting.instance.option;
        od.mLanguage = GUIMgr.Instance.targetLanguage;
        GameSetting.instance.option = od;
        GameSetting.instance.SaveOption();

        GameSetting.instance.ClearLoginInfo();
        GameSetting.instance.SaveLoginInfo();
        Logout();
        NetworkManager.instance.BackToLogin();
        mSubmitRoleInfo = false;
    }

    public void OnInitServerCallback(string _param)
    {
        Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(_param) as Dictionary<string, object>;

        if (!data.ContainsKey("code"))
        {
            DebugUtils.Log("callback format is invalid!");
            return;
        }

        mResultCode = (ERetCode)int.Parse((string)data["code"]);
    }

    public void OnGetInventoryListCallback(string _param)
    {
        LuaBehaviour store = GUIMgr.Instance.FindMenu("store");
        if (store != null)
        {
            store.CallFunc("OnGetInventortList", _param);
        }
    }


    public void OnRechargeCallback(string _param)
    {
        Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(_param) as Dictionary<string, object>;

        if (!data.ContainsKey("code"))
        {
            DebugUtils.Log("callback format is invalid!");
            return;
        }

        DebugUtils.Log("RechargeCallback");
        mResultCode = (ERetCode)int.Parse((string)data["code"]);
        mRechargeCode = mResultCode;
        if (mRechargeCode != ERetCode.eCode_Succ)
        {
            GUIMgr.Instance.UnlockScreen();
        }

        if (data.ContainsKey("price"))
        {
            mEfunPrice = int.Parse((string)data["price"]);
        }

        if (data.ContainsKey("msg"))
        {
            mRechargeMsg = (string)data["msg"];
        }
        else
        {
            mRechargeMsg = "";
        }
        if (data.ContainsKey("identifier"))
        {
            mIdentifier = (string)data["identifier"];
        }
        if (data.ContainsKey("transactionReceipt"))
        {
            mTransactionReveipt = (string)data["transactionReceipt"];
            mWaitingResponse = true;
        }
        if (data.ContainsKey("payType"))
        {
            mPayType = int.Parse((string)data["payType"]);
        }

        if (data.ContainsKey("signature"))
        {
            mSignature = (string)data["signature"];
        }

        if (data.ContainsKey("productid"))
        {
            mProductId = (string)data["productid"];
        }

        if (data.ContainsKey("chargechaneltype"))
        {
            mChargeChanelType = int.Parse((string)data["chargechaneltype"]);
        }

        if (data.ContainsKey("platorderid"))
        {
            if (!string.IsNullOrEmpty((string)data["platorderid"]))
            {
                mPlatOrderId = (string)data["platorderid"];
            }
            DebugUtils.Log("Orderid:" + mPlatOrderId);
        }
    }

    public void OnSocialCallback(string _param)
    {
        Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(_param) as Dictionary<string, object>;
        if (!data.ContainsKey("code"))
        {
            DebugUtils.Log("callback format is invalid!");
            return;
        }
        mResultCode = (ERetCode)int.Parse((string)data["code"]);
        if (mResultCode == ERetCode.eCode_Succ)
        {
            LuaBehaviour ShareUnion = GUIMgr.Instance.FindMenu("ShareUnion");
            if (ShareUnion != null)
            {
                ShareUnion.CallFunc("SocialCallback", null);
            }
        }

        if (GUIMgr.Instance.onSocialCallback != null)
        {
            GUIMgr.Instance.onSocialCallback(_param);
        }
    }

    public void OnSDKErrorCallback(string _param)
    {
        switch (_param)
        {
            case "90001":
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_error_google1"), null, null);
                break;
            case "90002":
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_error_google2"), null, null);
                break;
            case "90003":
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_error_google3"), null, null);
                break;
            case "10001":
                if (GameObject.Find("store") != null)
                {
                    GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_error_pay1"), null, null);
                }
                break;
            case "10002":
                GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("login_error_pay2"), null, null);
                break;
            default:
                break;
        }
    }

    public void OnExitCallback(string _param)
    {
        if (mPlatform == AccType.AccType_adr_mango)
        {
            if (string.IsNullOrEmpty(_param))
            {
                Application.Quit();
            }
            else
            {
                LuaInterface.LuaFunction showFunc = LuaClient.GetMainState().GetFunction("ExitGame");
                if (showFunc != null)
                {
                    showFunc.Call();
                    showFunc.Dispose();
                }
            }
        }
        else if (mPlatform == AccType.AccType_adr_quick || mPlatform == AccType.AccType_adr_qihu)
        {
            if (string.IsNullOrEmpty(_param))
            {
                LuaInterface.LuaFunction showFunc = LuaClient.GetMainState().GetFunction("ShowExit");
                if (showFunc != null)
                {
                    showFunc.Call();
                    showFunc.Dispose();
                }
            }
            else if (_param.Equals("exit"))
            {
                Application.Quit();
            }
        }
        else
        {
            Application.Quit();
        }
    }

    public void OnWakeupCallback(string _param)
    {
        //todo
    }
#endregion

#region mainapi
    public void Init()
    {
        mPlatform = (AccType)_getChannelFlag();
    }

    public void InitPlatform()
    {
        if (mPlatformInited)
        {
            mResultCode = ERetCode.eCode_Succ;
            return;
        }

        mResultCode = ERetCode.eCode_None;

        Dictionary<string, object> param = new Dictionary<string, object>();
        param["platform"] = "" + (int)mPlatform;

        //////talkingdata param////////////
        param["tdappid"] = "B0941769913E44C18D16EB127A47AB28";
		if (mPlatform == AccType.AccType_adr_googleplay) {
			param ["tdchannel"] = "googleplay";
		} else if (mPlatform == AccType.AccType_adr_huawei) {
			param ["tdappid"] = "CE0339C51B884356B612FD93A67D1670";
			param ["tdchannel"] = "huawei_global";
		} 
        else if (mPlatform == AccType.AccType_adr_taptap ||
                 mPlatform == AccType.AccType_ios_taptap)
        {
            param["tdchannel"] = "taptap";
        }
        else
        {
            param["tdchannel"] = "self";
        }
        ///////////////////////////////////

        //set the param in the AndroidManifest.xml
        _init(OurMiniJSON.Json.Serialize(param));

        if (mPlatform == AccType.AccType_self_ios ||
            mPlatform == AccType.AccType_self_adr ||
            mPlatform == AccType.AccType_adr_taptap ||
            mPlatform == AccType.AccType_ios_taptap)
        {
            DebugUtils.Log("Init Platform Self OK!");
            mResultCode = ERetCode.eCode_Succ;
        }
    }

    public void Login(LoginType _type)
    {
		Debug.Log ("Login::");
        mResultCode = ERetCode.eCode_None;

        if (mPlatform == AccType.AccType_self_ios ||
            mPlatform == AccType.AccType_self_adr ||
            mPlatform == AccType.AccType_adr_taptap ||
            mPlatform == AccType.AccType_ios_taptap)
        {
            mResultCode = ERetCode.eCode_Succ;

            //get the local unique id
            if (string.IsNullOrEmpty(WSdkManager.instance.uid))
            {
                uid = _getLocalUniqueId(Utils.GetMd5Hash(PlatformUtils.GetUniqueIdentifier()));
            }
#if USE_STEAM
            if (SteamManager.Initialized ==false){
                Application.Quit();
            }
#endif
            session = string.Empty;
            return;
        }

        if (mPlatform == AccType.AccType_adr_efun )
        {
            if ((int)_type == 0)
                _type = LoginType.eLoginType_Efun;
        }
		else if (mPlatform == AccType.AccType_ios_efun)
        {
            if ((int)_type == 0)
            {
             //   _type = LoginType.eLoginType_Efun;
            }
        }
        if (mPlatform == AccType.AccType_ios_muzhi2 || mPlatform == AccType.AccType_ios_muzhi || mPlatform == AccType.AccType_adr_muzhi || mPlatform == AccType.AccType_adr_moliyou)
		{
			_type = LoginType.eLoginType_Muzhi;
		}
        if (mPlatform == AccType.AccType_adr_mango)
        {
            _type = LoginType.eLoginType_Mango;
        }
        if (mPlatform == AccType.AccType_adr_opgame)
        {
            _type = LoginType.eLoginType_OPGame;
            session = string.Empty;
        }
        if (mPlatform == AccType.AccType_adr_official || 
            mPlatform == AccType.AccType_ios_official || 
            mPlatform == AccType.AccType_adr_official_branch)
        {
            //_type = LoginType.eLoginType_WX;
            session = string.Empty;
        }
        if (mPlatform == AccType.AccType_adr_quick)
        {
            _type = LoginType.eLoginType_Quick;
            session = string.Empty;
        }
        if (mPlatform == AccType.AccType_adr_qihu)
        {
            _type = LoginType.eLoginType_Qihu;
            session = string.Empty;
        }
        //      if (mPlatform == AccType.AccType_adr_tw_digiSky || mPlatform == AccType.AccType_adr_kr_digiSky) {
        //          _type = LoginType.eLoginType_PPGame;
        //      }

        //      if (mPlatform == AccType.AccType_ios_kr_digiSky || mPlatform == AccType.AccType_ios_tw_digiSky)
        //{
        //	_type = LoginType.eLoginType_PPGame;
        //}
        
        if (_type == LoginType.eLoginType_normal)
        {
            mResultCode = ERetCode.eCode_Succ;
            uid = _getLocalUniqueId(Utils.GetMd5Hash(PlatformUtils.GetUniqueIdentifier()));
            session = string.Empty;
            return;
        }
        else
        {
            if (!string.IsNullOrEmpty(WSdkManager.instance.uid) && !string.IsNullOrEmpty(WSdkManager.instance.session) && mPlatform != AccType.AccType_adr_mango)
            {
                mResultCode = ERetCode.eCode_Succ;
                if (onLoginDelegate != null)
                {
                    onLoginDelegate();
                }
                return;
            }
        }
        GUIMgr.Instance.LockScreen();
        if (_type == LoginType.eLoginType_PPGame)
        {
            LuaClient.GetMainState().GetFunction("PPGameLogin.Show").Call(null);
            GUIMgr.Instance.UnlockScreen();
        }
        _login((int)_type);
    }

    public void ReLogin()
    {
        mResultCode = ERetCode.eCode_None;
        if (mPlatform == AccType.AccType_self_ios ||
            mPlatform == AccType.AccType_self_adr ||
            mPlatform == AccType.AccType_adr_taptap ||
            mPlatform == AccType.AccType_ios_taptap)
        {
            mResultCode = ERetCode.eCode_Succ;
            return;
        }

        _relogin();
    }

    public void Logout()
    {
        mSubmitRoleInfo = false;
        mResultCode = ERetCode.eCode_None;
        _logout();
    }

    public void InitServer(string _zoneId)
    {
        mResultCode = ERetCode.eCode_None;

        if (mPlatform == AccType.AccType_self_ios ||
            mPlatform == AccType.AccType_self_adr ||
            mPlatform == AccType.AccType_adr_taptap ||
            mPlatform == AccType.AccType_ios_taptap)
        {
            mResultCode = ERetCode.eCode_Succ;
        }
        else
        {
            _initServer(_zoneId);
        }
    }

    public string GetPackageName()
    {
        return _getPackageName();
    }

    public string GetSystemInfo()
    {
        return _getSystemInfo();
    }

    public void GetInventoryList(string _desc)
    {
        mWaitingResponse = _getInventoryList(_desc);
    }

    public void SubmitRoleInfo(string roleName, string level, bool full)
    {
        mSubmitRoleInfo = true;

        Dictionary<string, object> param = new Dictionary<string, object>();
        if (full)
        {
            param["full"] = "full";
        }
        param["accid"] = WSdkManager.instance.uid;
        param["logintype"] = "" + WSdkManager.instance.loginType;
        param["rolename"] = roleName;
        param["gameserver"] = WSdkManager.instance.zoneName;
        param["level"] = level;

        _submitRoleInfo(OurMiniJSON.Json.Serialize(param));
    }

    public void Recharge(string _desc, string _orderId, string _price)
    {
        mOrderId = _orderId;
        mPrice = _price;
        isRecharging = true;
        mResultCode = ERetCode.eCode_None;
        mWaitingResponse = _recharge(_desc);
    }

    public void RechargeSucc()
    {
        Dictionary<string, object> param = new Dictionary<string, object>();
        param["orderid"] = mOrderId;
        param["price"] = float.Parse(mPrice);
        _rechargeSucc(OurMiniJSON.Json.Serialize(param));
        isRecharging = false;
    }

    public void Exit()
    {
#if UNITY_IPHONE && !UNITY_EDITOR
			_onExit();
#else
        _exit();
#endif
    }

    public void ReqSocial(ESocialType _type, string _appId)
    {
        Dictionary<string, object> param = new Dictionary<string, object>();
        param["type"] = "" + (int)_type;
        param["id"] = _appId;

        _regSocial(OurMiniJSON.Json.Serialize(param));
    }

    public void SendMessageToSocial(ESocialType _type, ESocialScene _scene, string _title, string _desc, string _imgPath, string _shareUrl)
    {
        mResultCode = ERetCode.eCode_None;
        Dictionary<string, object> param = new Dictionary<string, object>();
        param["type"] = "" + (int)_type;
        param["scene"] = "" + (int)_scene;
        param["title"] = _title;
        param["url"] = _shareUrl;
        param["desc"] = _desc;
        param["imgpath"] = _imgPath;

        _sendMessageToSocial(OurMiniJSON.Json.Serialize(param));
    }

    public string GetDeviceName()
    {
        string device = "unkown";
#if UNITY_EDITOR
        device = "Unity Editor";
#elif UNITY_ANDROID
            device = "Android";
#elif UNITY_IPHONE
          device = "Iphone";  
#elif UNITY_STANDALONE_OSX
        device = "Stand Alone OSX";  
#elif UNITY_STANDALONE_WIN
          device = "Stand Alone Windows";  
#endif
        return device;

    }

    public int GetChargeChanelType()
    {
        ChargeChanelType cct = ChargeChanelType.CCT_google;
        switch (mPlatform)
        {
            case AccType.AccType_self_ios:
                break;
            case AccType.AccType_ios_gamecenter:
                break;
            case AccType.AccType_ios_efun:
                cct = ChargeChanelType.CCT_efun;
                break;
            case AccType.AccType_ios_india:
                cct = ChargeChanelType.CCT_efun;
                break;
            case AccType.AccType_ios_max:
                break;
            case AccType.AccType_self_ios_jb:
                break;
            case AccType.AccType_ios_kr_digiSky:
            case AccType.AccType_ios_tw_digiSky:
                cct = ChargeChanelType.CCT_digisky;
                break;
            case AccType.AccType_ios_muzhi:
            case AccType.AccType_ios_muzhi2:
                cct = ChargeChanelType.CCT_muzhi;
                break;
            case AccType.AccType_ios_jb_max:
                break;
            case AccType.AccType_self_adr:
                break;
            case AccType.AccType_adr_googleplay:
                cct = ChargeChanelType.CCT_google;
                break;
            case AccType.AccType_adr_huawei:
                cct = ChargeChanelType.CCT_huawei;
                break;
            case AccType.AccType_adr_tmgp:
                cct = ChargeChanelType.CCT_tmgp;
                break;
            case AccType.AccType_adr_efun:
                cct = ChargeChanelType.CCT_efun;
                break;
            case AccType.AccType_adr_tw_digiSky:
            case AccType.AccType_adr_kr_digiSky:
                cct = ChargeChanelType.CCT_digisky;
                break;
            case AccType.AccType_adr_kr_onestore:
                cct = ChargeChanelType.CCT_onestore;
                break;
            case AccType.AccType_adr_muzhi:
            case AccType.AccType_adr_moliyou:
                cct = ChargeChanelType.CCT_muzhi;
                break;
            case AccType.AccType_adr_opgame:
                cct = ChargeChanelType.CCT_opgame;
                break;
            case AccType.AccType_adr_mango:
                cct = ChargeChanelType.CCT_mango;
                break;
            case AccType.AccType_adr_qihu:
                cct = ChargeChanelType.CCT_qihu;
                break;
            case AccType.AccType_adr_max:
                break;
            case AccType.AccType_ios_official:
                cct = ChargeChanelType.CCT_apple;
                break;
            default:
                break;
        }
        return (int)cct;
    }

    public string GetIpv6(string mHost, string mPort)
    {
        return _getIpv6(mHost, mPort);
    }

    //data report, using talking data
    //key                   value
    //level                "id":"xxx"
    //                     "result":"begin", "completed" ,"escape" or "failed"
    //mission

    public void SendDataReport(params string[] args)
    {
        if (args.Length < 2)
        {
            DebugUtils.LogError("data report:invalid args!");
            return;
        }

        Dictionary<string, object> param = new Dictionary<string, object>();
        param["key"] = args[0];

        Dictionary<string, object> valueParam = new Dictionary<string, object>();
        if (args[0] == "level" ||
            args[0] == "tutorial" ||
            args[0] == "rmission" ||
            args[0] == "umission")
        {
            if (args.Length != 4)
            {
                DebugUtils.LogError("data report:valid args: key id result star");
                return;
            }

            valueParam["id"] = args[1];
            valueParam["result"] = args[2];
            valueParam["star"] = args[3];
        }
        else if (args[0] == "purchase")
        {
            valueParam["type"] = args[1];
            if (args[1] == "buyitem")
            {
                if (args.Length != 5)
                {
                    DebugUtils.LogError("data report:valid args: key type id num price");
                    return;
                }

                valueParam["id"] = args[2];
                valueParam["num"] = args[3];
                valueParam["price"] = args[4];
            }
            else if (args[1] == "useitem")
            {
                if (args.Length != 4)
                {
                    DebugUtils.LogError("data report:valid args: key type id num");
                    return;
                }

                valueParam["id"] = args[2];
                valueParam["num"] = args[3];
            }
            else if (args[1] == "costgold")
            {
                if (args.Length != 5)
                {
                    DebugUtils.LogError("data report:valid args: key type reason num price");
                    return;
                }

                valueParam["reason"] = args[2];
                valueParam["num"] = args[3];
                valueParam["price"] = args[4];
            }
        }
        else if (args[0] == "reward")
        {
            if (args.Length != 3)
            {
                DebugUtils.LogError("data report:valid args: key reason price");
                return;
            }

            valueParam["reason"] = args[1];
            valueParam["price"] = args[2];
        }
        else if (args[0] == "efun")
        {
            if (args.Length != 2)
            {
                DebugUtils.LogError("data report:valid args: key event");
                return;
            }
            valueParam["event"] = args[1];
            valueParam["roleid"] = (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetCharId").Call(null)[0];
            valueParam["roleName"] = "" + LuaClient.GetMainState().GetFunction("MainData.GetCharName").Call(null)[0];
            valueParam["rolelevel"] = (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetLevel").Call(null)[0];
            valueParam["zoneid"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("ServerListData.GetCurrentZoneId").Call(null)[0];
			valueParam["zoneName"] = "" + LuaClient.GetMainState().GetFunction("ServerListData.GetCurrentZoneName").Call(null)[0];
            if(mPrice != "")
            {
            	valueParam["price"] = float.Parse(mPrice);
        	}
        }
        else if (args[0] == "muzhi")
        {
            if (args.Length > 2)
            {
                DebugUtils.LogError("data report:out of length");
                return;
            }
            valueParam["zoneid"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("ServerListData.GetCurrentZoneId").Call(null)[0];
			valueParam["zoneName"] = "" + LuaClient.GetMainState().GetFunction("ServerListData.GetCurrentZoneName").Call(null)[0];
			valueParam["roleid"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetCharId").Call(null)[0];
			valueParam["roleName"] = "" + LuaClient.GetMainState().GetFunction("MainData.GetCharName").Call(null)[0];
			valueParam["roleLevel"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetLevel").Call(null)[0];
			valueParam["currency"] = args[1];
			valueParam["roleVipLevel"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetVipLevel").Call(null)[0];
        }
        else if (args[0] == "muzhiqq" || args[0] == "officialqq")
        {
            if (args.Length != 2)
            {
                DebugUtils.LogError("data report:valid args: key");
                return;
            }
            valueParam["qqkey"] = args[1];
        }
        else if (args[0] == "mango")
        {
            if (args.Length > 2)
            {
                DebugUtils.LogError("data report:out of length");
                return;
            }
            try
            {
                valueParam["type"] = args[1];
                valueParam["zoneid"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("ServerListData.GetCurrentZoneId").Call(null)[0];
                valueParam["zoneName"] = "" + LuaClient.GetMainState().GetFunction("ServerListData.GetCurrentZoneName").Call(null)[0];
                valueParam["roleid"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetCharId").Call(null)[0];
                valueParam["roleName"] = "" + LuaClient.GetMainState().GetFunction("MainData.GetCharName").Call(null)[0];
                valueParam["roleLevel"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetLevel").Call(null)[0];
                valueParam["roleCreateTime"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetCreationTime").Call(null)[0];
                valueParam["roleVipLevel"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetVipLevel").Call(null)[0];
                valueParam["power"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetFight").Call(null)[0];
                valueParam["currency"] = "" + (int)(double)LuaClient.GetMainState().GetFunction("MoneyListData.GetDiamond").Call(null)[0];
            }
            catch (Exception e)
            {}
        }

        param["value"] = OurMiniJSON.Json.Serialize(valueParam);
        _sendDataReport(OurMiniJSON.Json.Serialize(param));

    }

    public void ExtraFunction(string param)
    {

        _extraFunction(param);
    }
#endregion

    public void _sendDataReport(string _param)
    {

    }

    public void _init(string _param)
    {

    }

    public void _login(int _loginType)
    {

    }

    public void _relogin()
    {

    }

    public void _logout()
    {

    }

    public void _initServer(string _param)
    {

    }

    public string _getPackageName()
    {

        return "wgame";
    }

    public string _getSystemInfo()
    {

        return "pc";
    }

    public int _getChannelFlag()
    {
        return (int)ProtoMsg.AccType.AccType_self_adr;
    }

    public bool _getInventoryList(string _desc)
    {
        return false;
    }


    public bool _recharge(string _desc)
    {
        return false;
    }


    public bool _rechargeSucc(string _param)
    {
        return false;
    }

    public void _submitRoleInfo(string _info)
    {

    }

    public void _exit()
    {

    }
    public void _onExit()
    {

    }
    public void _regSocial(string _param)
    {

    }

    public void _sendMessageToSocial(string _param)
    {
    }

    public string _getLocalUniqueId(string _uuid)
    {
       return Utils.GetMd5Hash(PlatformUtils.GetUniqueIdentifier() + Application.dataPath);
    }

    public void _extraFunction(string _param)
    {
    }

    public string _getIpv6(string _host, string _port)
    {
        return _host + "&&ipv4";
    }

    }
