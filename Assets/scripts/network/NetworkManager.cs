using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Security.Cryptography;
using ProtoBuf;
using ProtoMsg;
using System;

public class NetworkManager
{
    const float DEFAULT_SEND_WAIT_TIME = 0.1f;
    const float DEFAULT_TIMEOUT_TIME = 30.0f;
    const float DEFAULT_HEARTBEAT_TIME = 300.0f;

    const int DEFAULT_COMPRESS_SIZE = 8192;

    static NetworkManager sInstance;

    public static NetworkManager instance
    {
        get
        {
            if (sInstance == null)
            {
                sInstance = new NetworkManager();
            }
            return sInstance;
        }
    }

    public enum EState
    {
        eState_Idel = 0,
        eState_Try_Connecting,
        eState_Connected,
        eState_Login,
        eState_Normal,
        eState_ResendLostMsg,
        eState_AutoReconnect,
        eState_Reconnect,
        eState_Reconnecting,
        eState_Reconnected,
        eState_Reconnect_Send,
        eState_Error,
    }

    public delegate void CallbackFunc(byte[] data);

    public struct ResponseCallback
    {
        public CallbackFunc pFunc;
    };

    public delegate void PushCallbackFunc(uint _category_id, uint _type_id, byte[] data);
    public struct PushResponseCallback
    {
        public PushCallbackFunc pFunc;
    };

    public struct ResponseCallbackLua
    {
        public LuaNetwork.CallbackFunc pFunc;
    }

    public class simple_msg_info
    {
        public uint category_id;
        public uint type_id;
        public uint seq;
        public float time;
        public MessagePackage pack;

        public simple_msg_info(uint _category_id, uint _type_id, uint _seq, MessagePackage _pack)
        {
            category_id = _category_id;
            type_id = _type_id;
            seq = _seq;
            time = 0;
            pack = _pack;
        }
    }

    //server address and port
    private string m_sServer;
    private string m_sPort;

    //send wait time
    private float m_fSendDelayTime = 0;
    private float m_fConnectTime = -1;
    private int m_iReconnectCount = 0;

    //msg stack
    private List<simple_msg_info> m_lMsgStack = new List<simple_msg_info>();
    private uint m_iMsgSequence = 0;

    //Main Socket
    private CSocket m_MainSocket = null;
    private int m_iPackageSize = 0;
    private int m_iPaddingSize = 0;
    private bool m_bCompressed = false;

    //network state
    private EState m_eState;

    private List<uint> mListLockScreen = new List<uint>();

    //auto reconnect
    private bool m_bEnableAutoConnect = false;
    public bool EnableAutoConnect
    {
        get { return m_bEnableAutoConnect; }
        set { m_bEnableAutoConnect = value; }
    }


    //send package
    private List<MessagePackage> m_lSendPackage = null;

    //response map
    Dictionary<uint, ResponseCallback> m_dRespMap = new Dictionary<uint, ResponseCallback>();
    Dictionary<uint, Dictionary<uint, PushResponseCallback>> m_dPushRespMap = new Dictionary<uint, Dictionary<uint, PushResponseCallback>>();

    //response map for Lua
    Dictionary<uint, ResponseCallbackLua> m_dRespMapLua = new Dictionary<uint, ResponseCallbackLua>();

    Dictionary<uint, Dictionary<uint, ResponseCallbackLua>> m_dPushRespMapLua = new Dictionary<uint, Dictionary<uint, ResponseCallbackLua>>();

    public int GetMsgStackCount()
    {
        if (m_lMsgStack != null)
        {
            return m_lMsgStack.Count;
        }

        return 0;
    }

    public int resMapCount()
    {
        return m_dRespMapLua.Count;
    }
    static public Dictionary<ProtoMsg.MsgCategory, Type> _msgMap = null;// new Dictionary<MsgCategory, Type>();
    static public Dictionary<ProtoMsg.MsgCategory, Type> MsgMap
    {
        get
        {
            if (_msgMap == null)
            {
                _msgMap = new Dictionary<MsgCategory, Type>();
                _msgMap.Add(ProtoMsg.MsgCategory.Login, typeof(ProtoMsg.LoginTypeId.Login));
                _msgMap.Add(ProtoMsg.MsgCategory.Client, typeof(ProtoMsg.ClientTypeId.Client));
                _msgMap.Add(ProtoMsg.MsgCategory.Item, typeof(ProtoMsg.ItemTypeId.Item));
                _msgMap.Add(ProtoMsg.MsgCategory.Shop, typeof(ProtoMsg.ShopTypeId.Shop));
                //_msgMap.Add(ProtoMsg.MsgCategory.Chat, typeof(ProtoMsg.ChatTypeId.Chat));
                //_msgMap.Add(ProtoMsg.MsgCategory.Mail, typeof(ProtoMsg.MailTypeId.Mail));
                //_msgMap.Add(ProtoMsg.MsgCategory.Vip, typeof(ProtoMsg.VipInfo));
                _msgMap.Add(ProtoMsg.MsgCategory.Activity, typeof(ProtoMsg.ActivityTypeId.Activity));
                _msgMap.Add(ProtoMsg.MsgCategory.Battle, typeof(ProtoMsg.BattleTypeId.Battle));
                _msgMap.Add(ProtoMsg.MsgCategory.PvP, typeof(ProtoMsg.PvPTypeId.PvP));
                _msgMap.Add(ProtoMsg.MsgCategory.Build, typeof(ProtoMsg.BuildTypeId.Build));
                _msgMap.Add(ProtoMsg.MsgCategory.Hero, typeof(ProtoMsg.HeroTypeId.Hero));
                //_msgMap.Add(ProtoMsg.MsgCategory.Guild, typeof(ProtoMsg.GuildTypeId.Guild));
                _msgMap.Add(ProtoMsg.MsgCategory.Map, typeof(ProtoMsg.MapTypeId.Map));
            }
            return _msgMap;
        }
    }

    float m_fHeartTime = 0;
    bool m_MultiLogin = false;


    public bool enableLog = false;

    public int lastSendBytes = 0;

    public int totalSendBytes = 0;

    public int lastReceiveBytes = 0;

    public int totalReceiveBytes = 0;

    public uint lastSeqId = 0;

    public float lastRequestTime = 0;

    public float lastResponseTime = 0;

    public int totalResponseCount = 0;

    public float totalResponseTime = 0;

    public float averageResponseTime = 0;

    public float analogDelay = 0;

    private Queue<string> recentlyRequest = new Queue<string>();

    //AES
    private MsgEncryptKeyData mEncryptKey = null;
    public MsgEncryptKeyData EncryptKey
    {
        get
        {
            return mEncryptKey;
        }
        set
        {
            if (value == null)
            {
                mEncryptKey = null;
            }
            else
            {
                mEncryptKey = DeepClone(value);
            }
        }
    }

    private NetworkManager()
    {
        m_eState = NetworkManager.EState.eState_Idel;
    }

    public CSocket MainSocket
    {
        get
        {
            return m_MainSocket;
        }
    }

    public EState state
    {
        get
        {
            return m_eState;
        }
        set
        {
            m_eState = value;
        }
    }

    public void ResetConnectTime()
    {
        m_fConnectTime = 0;
    }

    public void ConnectServer(string sServer, string sPort)
    {
        m_sServer = sServer;
        m_sPort = sPort;

        if (m_MainSocket == null)
        {
            m_MainSocket = new CSocket();
        }

        m_MainSocket.ConnectSocket(m_sServer, m_sPort);

        Serclimax.DebugUtils.Log("connect ip:" + m_sServer + " port:" + m_sPort);

        if (state != EState.eState_Reconnecting)
        {
            m_fConnectTime = 0;
            state = EState.eState_Try_Connecting;
        }
    }

    public void ResetLog()
    {
        lastSendBytes = 0;

        totalSendBytes = 0;

        lastReceiveBytes = 0;

        totalReceiveBytes = 0;

        lastSeqId = 0;

        lastRequestTime = 0;

        lastResponseTime = 0;

        totalResponseCount = 0;

        totalResponseTime = 0;

        averageResponseTime = 0;
    }

    public void Close()
    {
        if (m_MainSocket != null)
        {
            m_MainSocket.Disconnect();
            m_MainSocket = null;
        }
        if (m_lMsgStack != null)
        {
            m_lMsgStack.Clear();
        }
        if (m_lSendPackage != null)
        {
            m_lSendPackage.Clear();
        }
        if (m_dRespMap != null)
        {
            m_dRespMap.Clear();
        }
        if (m_dRespMapLua != null)
        {
            m_dRespMapLua.Clear();
        }
        if (mListLockScreen.Count != 0)
        {
            mListLockScreen.Clear();
            GUIMgr.Instance.UnlockScreen();
        }

        //sInstance = null;
        m_fSendDelayTime = 0;
        m_eState = EState.eState_Idel;
    }


    public void Reset()
    {
        if (m_MainSocket != null)
        {
            m_MainSocket.Disconnect();
            m_MainSocket = null;
        }
        m_fSendDelayTime = 0;

        foreach (simple_msg_info info in m_lMsgStack)
        {
            info.time = 0;
        }
    }

    public uint Request<T>(uint _category_id, uint _type_id, T cmd, CallbackFunc _func, bool _lockScreen = false) where T : IExtensible
    {
        if (m_eState != NetworkManager.EState.eState_Idel && m_eState != NetworkManager.EState.eState_Reconnect)
        {
            if (m_iMsgSequence == uint.MaxValue)
            {
                m_iMsgSequence = 0;
            }
            m_iMsgSequence++;

            if (m_lSendPackage == null)
            {
                m_lSendPackage = new List<MessagePackage>();
            }

            MessagePackage package = new MessagePackage();
            package.msg = new MsgPackageData();
            package.msg.category_id = _category_id;
            package.msg.type_id = _type_id;
            package.msg.message = Encode(cmd);
            package.msg.seqid = m_iMsgSequence;
            //Serclimax.DebugUtils.LogNetwork("package.seqid : " + package.msg.seqid + ". size: " + package.msg.message.Length);

            m_lSendPackage.Add(package);

            recentlyRequest.Enqueue(String.Format("csharp request category id:{0} type id:{1} seqid:{2}\n", _category_id, _type_id, m_iMsgSequence));
            if (recentlyRequest.Count > 5)
            {
                recentlyRequest.Dequeue();
            }

            //add the rsp/key into the rsp map
            if (_func != null)
            {
                if (!m_dRespMap.ContainsKey(package.msg.seqid))
                {
                    ResponseCallback callback = new ResponseCallback();
                    callback.pFunc = _func;
                    m_dRespMap.Add(package.msg.seqid, callback);
                }
            }

            if (_lockScreen)
            {
                if (mListLockScreen.Count == 0)
                {
                    GUIMgr.Instance.LockScreen();
                }
                if (!mListLockScreen.Contains(package.msg.seqid))
                {
                    mListLockScreen.Add(package.msg.seqid);
                }
            }
            return m_iMsgSequence;
        }
        else
        {
            Serclimax.DebugUtils.LogNetwork("Send Fail! state=" + m_eState.ToString());
            return 0;
        }
    }

    // Only Invoke by LuaNetwork. DO NOT invoke this in other methods.
    public uint RequestLua(uint _category_id, uint _type_id, byte[] _data, LuaNetwork.CallbackFunc _func, bool _lockScreen)
    {
        if (m_eState != NetworkManager.EState.eState_Idel && m_eState != NetworkManager.EState.eState_Reconnect)
        {
            if (m_iMsgSequence == uint.MaxValue)
            {
                m_iMsgSequence = 0;
            }
            m_iMsgSequence++;

            if (m_lSendPackage == null)
            {
                m_lSendPackage = new List<MessagePackage>();
            }

            MessagePackage package = new MessagePackage();
            package.msg = new MsgPackageData();
            package.msg.category_id = _category_id;
            package.msg.type_id = _type_id;
            package.msg.message = _data;
            package.msg.seqid = m_iMsgSequence;

            m_lSendPackage.Add(package);

            recentlyRequest.Enqueue(String.Format("lua request category id:{0} type id:{1} seqid:{2}\n", _category_id, _type_id, m_iMsgSequence));
            if (recentlyRequest.Count > 5)
            {
                recentlyRequest.Dequeue();
            }

            //add the rsp/key into the rsp map
            if (_func != null)
            {
                if (!m_dRespMapLua.ContainsKey(package.msg.seqid))
                {
                    ResponseCallbackLua callback = new ResponseCallbackLua();
                    callback.pFunc = _func;
                    m_dRespMapLua.Add(package.msg.seqid, callback);
                }
            }

            if (_lockScreen)
            {
                if (mListLockScreen.Count == 0)
                {
                    GUIMgr.Instance.LockScreen();
                }
                if (!mListLockScreen.Contains(package.msg.seqid))
                {
                    mListLockScreen.Add(package.msg.seqid);
                }
            }

            //Serclimax.DebugUtils.LogNetwork("Lua Send Seqid:" + package.msg.seqid + " Send:" + PackageToString(package));
            return m_iMsgSequence;
        }
        else
        {
            //Serclimax.DebugUtils.LogNetwork("Lua Send Fail! state=" + m_eState.ToString());
            return 0;
        }
    }

    public void RegisterPushMsgCallback(uint _category_id, uint _type_id, PushCallbackFunc _func)
    {
        //add the rsp/key into the rsp map
        Dictionary<uint, PushResponseCallback> mapCallback = null;
        if (!m_dPushRespMap.ContainsKey(_category_id))
        {
            mapCallback = new Dictionary<uint, PushResponseCallback>();
            m_dPushRespMap.Add(_category_id, mapCallback);
        }
        mapCallback = m_dPushRespMap[_category_id];
        if (_func != null)
        {
            if (!mapCallback.ContainsKey(_type_id))
            {
                PushResponseCallback callback = new PushResponseCallback();
                callback.pFunc = _func;
                mapCallback.Add(_type_id, callback);
            }
            else
            {
                PushResponseCallback callback = new PushResponseCallback();
                callback.pFunc = _func;
                mapCallback[_type_id] = callback;
            }
        }
        else
        {
            mapCallback.Remove(_type_id);
        }
    }

    public void RegisterPushMsgCallbackLua(uint _category_id, uint _type_id, LuaNetwork.CallbackFunc _func)
    {
        //add the rsp/key into the rsp map
        Dictionary<uint, ResponseCallbackLua> mapCallback = null;
        if (!m_dPushRespMapLua.ContainsKey(_category_id))
        {
            mapCallback = new Dictionary<uint, ResponseCallbackLua>();
            m_dPushRespMapLua.Add(_category_id, mapCallback);
        }
        else
        {
            mapCallback = m_dPushRespMapLua[_category_id];
        }

        if (_func != null)
        {
            if (!mapCallback.ContainsKey(_type_id))
            {
                ResponseCallbackLua callback = new ResponseCallbackLua();
                callback.pFunc = _func;
                mapCallback.Add(_type_id, callback);
            }
            else
            {
                ResponseCallbackLua callback = new ResponseCallbackLua();
                callback.pFunc = _func;
                mapCallback[_type_id] = callback;
            }
        }
    }

    public void UnRegisterPushMsgCallback(uint _category_id, uint _type_id)
    {
        //remove the rsp/key into the rsp map
        Dictionary<uint, PushResponseCallback> mapCallback = null;
        if (m_dPushRespMap.ContainsKey(_category_id))
        {
            mapCallback = m_dPushRespMap[_category_id];
            if (mapCallback.ContainsKey(_type_id))
            {
                mapCallback.Remove(_type_id);
            }
        }
    }

    void SendReconnectRequest()
    {
        if (m_iMsgSequence == uint.MaxValue)
        {
            m_iMsgSequence = 0;
        }
        m_iMsgSequence++;

        MsgLoginGameVerifyAccount_CS req = new MsgLoginGameVerifyAccount_CS();
        req.isreconn = true;
        req.reconnKey = (uint)WSdkManager.instance.reconnectKey;
        req.accId = WSdkManager.instance.loginId;
        req.accType = (uint)WSdkManager.instance.loginType;
        req.loginPasswd = WSdkManager.instance.loginPassword;
        req.accKey = WSdkManager.instance.uid;
        req.accUserName = WSdkManager.instance.uname;
        req.deviceId = PlatformUtils.GetUniqueIdentifier();
        req.package = WSdkManager.instance.GetPackageName();
        req.acctoken = WSdkManager.instance.session;
        req.pf = WSdkManager.instance.salt;
        req.pfkey = WSdkManager.instance.signature;
        req.payToken = WSdkManager.instance.keyurl;
        req.platType = (uint)WSdkManager.instance.platform;

        Serclimax.DebugUtils.Log("MsgClientReconnectGatewayRequest--key:" + req.reconnKey);

        MessagePackage package = new MessagePackage();
        package.msg = new MsgPackageData();
        package.msg.category_id = (uint)MsgCategory.Login;
        package.msg.type_id = (uint)LoginTypeId.Login.MsgLoginGameVerifyAccount_CS;
        package.msg.message = Encode(req);
        package.msg.seqid = m_iMsgSequence;

        byte[] packageBuf = Encode(package);
        int paddingSize = 0;
        //aes
        if (mEncryptKey != null)
        {
            if (mEncryptKey.encrypt)
            {
                paddingSize = (packageBuf.Length + 15) / 16 * 16 - packageBuf.Length;
                packageBuf = AES.AESEncrypt(packageBuf, mEncryptKey.key, mEncryptKey.iv);
            }
        }

        byte[] headBuf = new byte[PackageHead.SizeOf];
        PackageHead head = new PackageHead();
        head.Flags = PackageHeadFlags.Partial;
        head.MessageLength = (ushort)packageBuf.Length;
        head.EncryptPaddingSize = (byte)paddingSize;
        head.WriteTo(headBuf, 0);

        List<byte> sMsgPack = new List<byte>();
        sMsgPack.AddRange(headBuf);
        sMsgPack.AddRange(packageBuf);

        m_MainSocket.Send(sMsgPack.ToArray(), 0, sMsgPack.Count);


        if (!m_dRespMap.ContainsKey(package.msg.seqid))
        {
            ResponseCallback callback = new ResponseCallback();
            callback.pFunc = OnMsgClientReconnectGatewayRequest;
            m_dRespMap.Add(package.msg.seqid, callback);
        }
    }

    void OnMsgClientReconnectGatewayRequest(byte[] data)
    {
        MsgLoginGameVerifyAccount_SC rsp = Decode<MsgLoginGameVerifyAccount_SC>(data);
        if (rsp.code == (uint)RequestCode.Code_OK)
        {
            WSdkManager.instance.reconnectKey = (int)rsp.reconnKey;
            //resend lost message
            if (resendMessage())
            {
                m_eState = EState.eState_ResendLostMsg;
            }
            else
            {
                m_eState = EState.eState_Normal;
            }
            LuaBehaviour global = GUIMgr.Instance.FindMenu("Global");
            if (global != null)
            {
                global.CallFunc("Reconnect", null);
            }
        }
        else
        {
            //todo  除了禁止登录其他都不展示
            if (rsp.code == (uint)RequestCode.Code_Login_AccountForbid)
            {
                ErrorCodeHandler(rsp.code, BackToLogin);
            }
        }
    }

    public byte[] Encode<T>(T cmd) where T : IExtensible
    {
        MemoryStream stream = new MemoryStream();
        Serializer.Serialize(stream, cmd);

        return stream.ToArray();
    }

    public T Decode<T>(byte[] data) where T : IExtensible
    {
        MemoryStream stream = new MemoryStream(data);
        return Serializer.Deserialize<T>(stream);
    }

    //dabian. use server exported data format. no need to redefine on client again.
    //if server changes varibles name, must change code at client too
    public T DeepClone<T>(T _cmd) where T : IExtensible
    {
        return Serializer.DeepClone<T>(_cmd);
    }

    public void Update()
    {
        if (m_MainSocket == null)
            return;

        m_MainSocket.Update();
        switch (m_eState)
        {
            case EState.eState_Try_Connecting:
                {
                    if (m_MainSocket.state == CSocket.SocketState.StateConnected)
                    {
                        m_fConnectTime = -1;
                        state = EState.eState_Connected;
                    }
                    else if (m_MainSocket.state == CSocket.SocketState.StateShutDown ||
                              m_MainSocket.state == CSocket.SocketState.StateSocketError)
                    {
                        reconnectFail();
                    }
                    else
                    {
                        checkTimeOut(false);
                    }
                }
                break;

            case EState.eState_Connected:
                {
                    m_eState = EState.eState_Normal;
                }
                break;

            case EState.eState_Normal:
            case EState.eState_Login:
            case EState.eState_Reconnect_Send:
            case EState.eState_ResendLostMsg:
                {
                    if (m_MainSocket.state == CSocket.SocketState.StateConnected)
                    {
                        checkRecvPackage();

                        if (m_eState == EState.eState_Reconnect_Send || m_eState == EState.eState_ResendLostMsg)
                        {
                            checkTimeOut(false);
                        }
                        else
                        {
                            checkTimeOut(true);
                        }
                    }
                    else if (m_MainSocket.state == CSocket.SocketState.StateShutDown ||
                             m_MainSocket.state == CSocket.SocketState.StateSocketError)
                    {
                        if (m_eState == EState.eState_Reconnect_Send ||
                            m_eState == EState.eState_ResendLostMsg ||
                            m_MultiLogin)
                        {
                            m_eState = EState.eState_Error;
                        }
                        else
                        {
                            m_eState = EState.eState_AutoReconnect;
                            m_iReconnectCount = 0;
                        }
                    }

                    m_fSendDelayTime += Serclimax.GameTime.realDeltaTime;
                    m_fHeartTime += Serclimax.GameTime.realDeltaTime;
                }
                break;

            case EState.eState_AutoReconnect:
                {
                    if (m_bEnableAutoConnect)
                    {
                        if (m_iReconnectCount == 0)
                        {
                            Reset();
                            ConnectServer(m_sServer, m_sPort);
                            m_eState = EState.eState_Reconnecting;
                            m_iReconnectCount++;
                            m_fConnectTime = 0;
                        }
                        else
                        {
                            reconnectFail();
                        }
                    }
                    else
                    {
                        reconnectFail();
                    }
                }
                break;

            case EState.eState_Reconnecting:
                {
                    if (m_MainSocket.state == CSocket.SocketState.StateConnected)
                    {
                        m_fConnectTime = -1;
                        m_eState = EState.eState_Reconnected;

                    }
                    else if (m_MainSocket.state == CSocket.SocketState.StateSocketError ||
                              m_MainSocket.state == CSocket.SocketState.StateShutDown)
                    {
                        state = EState.eState_Error;
                    }
                    else
                    {
                        checkTimeOut(false);
                    }
                }
                break;

            case EState.eState_Reconnected:
                {
                    //send the reconnect message and resend the lost message
                    m_eState = EState.eState_Reconnect_Send;
                    SendReconnectRequest();
                    m_fConnectTime = -1;
                    m_iReconnectCount = 0;
                }
                break;

            case EState.eState_Error:
                {
                    Close();
                    bool bShowError = true;
                    if (m_MultiLogin || Main.Instance.IsInLoginState())
                    {
                        bShowError = false;
                        /*GameStateLogin stLogin = Main.Instance.CurrentGameState as GameStateLogin;
                        if(stLogin != null)
                        {
                            GUIMgr.Instance.MessageBox(TextManager.Instance.GetText(Text.login_hint7),
                                () => {
                                    GameStateLogin.Instance.state = GameStateLogin.EInitState.eCheckSDK;
                                },
                                null);
                        }*/
                    }
                    if (bShowError)
                    {
                        string hint = "login_hint7";
                        if (GUIMgr.Instance.kickOff)
                        {
                            GUIMgr.Instance.kickOff = false;
                            hint = "login_ui7";
                        }

                        GUIMgr.Instance.MessageBox(TextManager.Instance.GetText(hint), msb_network_error_result_ok, null);
                    }
                    m_eState = EState.eState_Idel;
                }
                break;
        }
    }

    public void UpdateCheckSendPackage()
    {
        if (m_MainSocket == null)
            return;

        switch (m_eState)
        {
            case EState.eState_Normal:
            case EState.eState_Login:
            case EState.eState_Reconnect_Send:
            case EState.eState_ResendLostMsg:
                {
                    if (m_MainSocket.state == CSocket.SocketState.StateConnected)
                    {
                        if (m_fSendDelayTime >= DEFAULT_SEND_WAIT_TIME)
                        {
                            m_fSendDelayTime = 0f;
                            sendRequestPackage();
                        }

                        if (m_fHeartTime >= DEFAULT_HEARTBEAT_TIME)
                        {
                            sendHeartbeatRequest();
                            m_fHeartTime = 0;
                        }
                    }

                    m_fSendDelayTime += Serclimax.GameTime.realDeltaTime;
                    m_fHeartTime += Serclimax.GameTime.realDeltaTime;
                }
                break;

            default:
                break;
        }
    }

    void msb_network_error_result_ok()
    {
        if (state == EState.eState_Reconnect_Send ||
            state == EState.eState_Idel)
        {
            BackToLogin();
        }
        else
        {
            state = EState.eState_AutoReconnect;
            m_iReconnectCount = 0;
        }
    }

    private void checkTimeOut(bool bReconnect)
    {
        int timeoutIdx = -1;
        for (int i = 0; i < m_lMsgStack.Count; i++)
        {
            m_lMsgStack[i].time += Serclimax.GameTime.realDeltaTime;
            if (m_lMsgStack[i].time >= DEFAULT_TIMEOUT_TIME)
            {
                timeoutIdx = i;
                break;
            }
        }
        if (timeoutIdx != -1)
        {
            if (bReconnect)
                m_eState = EState.eState_AutoReconnect;
            else
                reconnectFail();
        }
        else
        {
            if (m_fConnectTime != -1)
            {
                m_fConnectTime += Serclimax.GameTime.realDeltaTime;
                if (m_fConnectTime >= DEFAULT_TIMEOUT_TIME)
                {
                    if (bReconnect)
                        m_eState = EState.eState_AutoReconnect;
                    else
                        reconnectFail();
                }
            }
        }
    }

   //public  static int TestInt = 0;
   // public static int TestInt_toggle = UnityEngine.Random.Range(200 , 400);
    private void checkRecvPackage()
    {
        if (m_MainSocket == null)
            return;

        while (m_MainSocket.GetRecvDataSize() > 1)
        {
            if (m_iPackageSize == 0)
            {
                byte[] buf = new byte[4];
                if (m_MainSocket.Recv(buf, 0, 4) == 4)
                {
                    PackageHead head = new PackageHead();
                    head.ReadFrom(buf, 0);

                    m_iPackageSize = head.MessageLength;
                    m_iPaddingSize = (int)head.EncryptPaddingSize;
                    m_bCompressed = ((head.Flags & PackageHeadFlags.Zip) == PackageHeadFlags.Zip);
                }
            }

            if (m_iPackageSize != 0 && m_MainSocket.GetRecvDataSize() >= m_iPackageSize)
            {
                byte[] recvData = new byte[m_iPackageSize];
                m_MainSocket.Recv(recvData, 0, recvData.Length);
                byte[] originRecvData = recvData;

                //AES
                if (mEncryptKey != null)
                {
                    if (mEncryptKey.encrypt)
                    {
                        recvData = AES.AESDecrypt(recvData, mEncryptKey.key, mEncryptKey.iv);
                    }
                }

                MessagePackage package = null;
                try
                {
                    /*
                    TestInt++;
                    Debug.Log("Test: ========= " + TestInt + "  ," + TestInt_toggle);
                    if (enableLog || TestInt == TestInt_toggle)
                    {
                        TestInt = 0;
                        TestInt_toggle = UnityEngine.Random.Range(200, 400);
                        enableLog = false;
                        throw new Exception();
                    }
                    */
                    if (m_iPaddingSize > 0)
                    {
                        byte[] data = new byte[m_iPackageSize - m_iPaddingSize];
                        System.Buffer.BlockCopy(recvData, 0, data, 0, m_iPackageSize - m_iPaddingSize);

                        if (m_bCompressed)
                        {
                            data = Serclimax.CompressUtils.DecompressBytes(data);
                        }

                        package = Decode<MessagePackage>(data);
                    }
                    else
                    {
                        if (m_bCompressed)
                        {
                            recvData = Serclimax.CompressUtils.DecompressBytes(recvData);
                        }

                        package = Decode<MessagePackage>(recvData);
                    }
                }
                catch (Exception e)
                {
                    Debug.LogException(e);

                    StringBuilder sb = new StringBuilder("receive data:");
                    for (int i = 0; i < originRecvData.Length; i++)
                    {
                        sb.Append(originRecvData[i].ToString("X2"));
                    }

                    sb.Append("\nrecently request:\n");
                    foreach (var request in recentlyRequest)
                    {
                        sb.Append(request);
                    }

                    string remainReqLua = "";
                    if (m_lMsgStack != null)
                    {
                        foreach (simple_msg_info req in m_lMsgStack)
                        {
                            remainReqLua = "  reqId : " + req.seq + " cid:" + req.category_id + " tid:" + req.type_id;
                        }
                    }
                    
                    sb.Append("Socket Buff:" + " head:" + m_MainSocket.GetRecvBuffHead() + " tail:" + m_MainSocket.GetRecvBuffTail()
                        + " isRecving:" + m_MainSocket.IsRecving() + " isSending:" + m_MainSocket.IsSending() + " packageSize:" + m_iPackageSize
                        
                        + " remained Request:" + remainReqLua);
                    Debug.LogError(sb);

                    m_eState = NetworkManager.EState.eState_Idel;
                    package = null;
                    Reset();
                    GUIMgr.Instance.MessageBox(TextManager.Instance.GetText("System_NumberError"), BackToLogin, null);

                    return;
                    //GameStateLogin.Instance.StateChange2AccountLogin();
                }

                if (package == null)
                {
                    m_iPackageSize = 0;
                    return;
                }

                if (enableLog)
                {
                    if (package.msg.seqid == lastSeqId)
                    {
                        totalResponseCount++;
                        lastResponseTime = Time.realtimeSinceStartup - lastRequestTime;
                        totalResponseTime += lastResponseTime;
                        averageResponseTime = totalResponseTime / totalResponseCount;
                        Debug.LogWarningFormat("last reponse time:{0:N0}ms", lastResponseTime * 1000);
                    }
                }

                bool success = true;
                //handle push message
                if (package.pushmsg != null)
                {
                    for (int i = 0; i < package.pushmsg.msg.Count; i++)
                    {
                        success = false;
                        if (m_dPushRespMapLua.ContainsKey(package.pushmsg.msg[i].category_id))
                        {
                            Dictionary<uint, ResponseCallbackLua> mapCallback = m_dPushRespMapLua[package.pushmsg.msg[i].category_id];
                            if (mapCallback.ContainsKey(package.msg.type_id))
                            {
                                ResponseCallbackLua callback = mapCallback[package.msg.type_id];
                                LuaNetwork.Response(package.pushmsg.msg[i].seqid, package.pushmsg.msg[i].message, callback.pFunc);

                                Serclimax.DebugUtils.LogNetwork("Recv Lua Push Package:" + PackageToString(package));
                                success = true;
                            }
                        }
                        if (!success && m_dPushRespMap.ContainsKey(package.pushmsg.msg[i].category_id))
                        {
                            Dictionary<uint, PushResponseCallback> mapCallback = m_dPushRespMap[package.pushmsg.msg[i].category_id];
                            if (mapCallback.ContainsKey(package.pushmsg.msg[i].type_id))
                            {
                                PushResponseCallback callback = mapCallback[package.msg.type_id];
                                callback.pFunc(package.pushmsg.msg[i].category_id,
                                               package.pushmsg.msg[i].type_id,
                                               package.pushmsg.msg[i].message);
                            }
                        }
                    }
                }

                if (package.msg.seqid == 0)
                {
                    success = false;
                    if (m_dPushRespMapLua.ContainsKey(package.msg.category_id))
                    {
                        Dictionary<uint, ResponseCallbackLua> mapCallback = m_dPushRespMapLua[package.msg.category_id];
                        if (mapCallback.ContainsKey(package.msg.type_id))
                        {
                            ResponseCallbackLua callback = mapCallback[package.msg.type_id];
                            LuaNetwork.Response(package.msg.seqid, package.msg.message, callback.pFunc);
                            /*Serclimax.DebugUtils.LogNetwork("Recv Lua Push Package:" + 
                                "cid:" + package.msg.category_id + "typeid:" + package.msg.type_id + "  "+  PackageToString(package));*/
                            success = true;
                        }
                    }
                    if (!success && m_dPushRespMap.ContainsKey(package.msg.category_id))
                    {
                        Dictionary<uint, PushResponseCallback> mapCallback = m_dPushRespMap[package.msg.category_id];
                        if (mapCallback.ContainsKey(package.msg.type_id))
                        {
                            PushResponseCallback callback = mapCallback[package.msg.type_id];
                            callback.pFunc(package.msg.category_id,
                                           package.msg.type_id,
                                           package.msg.message);
                        }
                    }
                }

                //handle normal message
                string sLock = mListLockScreen.Contains(package.msg.seqid) ? "true" : "false";
                if (mListLockScreen.Contains(package.msg.seqid))
                {
                    mListLockScreen.Remove(package.msg.seqid);

                    if (mListLockScreen.Count == 0)
                    {
                        GUIMgr.Instance.UnlockScreen();
                    }
                }

                if (m_dRespMapLua.ContainsKey(package.msg.seqid))
                {
                    //Serclimax.DebugUtils.LogNetwork("Lua Recv:" + PackageToString(package));

                    ResponseCallbackLua callback = m_dRespMapLua[package.msg.seqid];
                    if (enableLog)
                    {
                        ProtoMsg.MsgCategory t = (ProtoMsg.MsgCategory)package.msg.category_id;
                        var pmname = Enum.GetName(typeof(ProtoMsg.MsgCategory), t);
                        if (MsgMap.ContainsKey((ProtoMsg.MsgCategory)package.msg.category_id))
                        {
                            //if(t == ProtoMsg.MsgCategory.Chat && item.msg.type_id == (int))
                            var t1 = MsgMap[(ProtoMsg.MsgCategory)package.msg.category_id];
                            var typename = Enum.GetName(t1, package.msg.type_id);


                            Debug.Log("--------RECV categoryId:" + pmname + "  typeId:" + typename + "    isLock:" + sLock);
                        }
                    }

                    try
                    {
                    LuaNetwork.Response(package.msg.seqid, package.msg.message, callback.pFunc);
                    }
                    catch(Exception e)
                    {
                        Debug.LogError("Lua Response Exception : " + e.ToString());
                    }
                    m_dRespMapLua.Remove(package.msg.seqid);
                }
                else if (m_dRespMap.ContainsKey(package.msg.seqid))
                {
                    //Serclimax.DebugUtils.LogNetwork("Recv:" + PackageToString(package));

                    ResponseCallback callback = m_dRespMap[package.msg.seqid];
                    callback.pFunc(package.msg.message);
                    m_dRespMap.Remove(package.msg.seqid);

                    //LuaNetwork.RefreshData(package.refreshInfo);
                }
                //check if the default message

                m_iPackageSize = 0;

                foreach (simple_msg_info it in m_lMsgStack)
                {
                    if (it.seq == package.msg.seqid)
                    {
                        it.pack = null;
                        m_lMsgStack.Remove(it);
                        break;
                    }
                }

                if (m_eState == EState.eState_ResendLostMsg &&
                    m_lMsgStack.Count == 0)
                {
                    m_eState = EState.eState_Normal;
                }

                if (m_MainSocket == null)
                    break;
            }

            if (m_MainSocket.GetRecvDataSize() < m_iPackageSize || m_MainSocket.GetRecvDataSize() == 1 && m_iPackageSize == 0)
                break;
        }
    }

    private void sendHeartbeatRequest()
    {
        if (m_eState != EState.eState_Normal)
            return;

        if (!EnableAutoConnect)
            return;

        //Serclimax.DebugUtils.LogNetwork("Send:Heartbeat!");

        MsgClientHeartbeatRequest req = new MsgClientHeartbeatRequest();

        MessagePackage package = new MessagePackage();
        package.msg = new MsgPackageData();
        package.msg.category_id = (uint)MsgCategory.Login;
        package.msg.type_id = (uint)LoginTypeId.Login.MsgClientHeartbeatRequest;
        package.msg.message = Encode(req);
        package.msg.seqid = 0;

        byte[] packageBuf = Encode(package);
        int paddingSize = 0;
        //aes
        if (mEncryptKey != null)
        {
            if (mEncryptKey.encrypt)
            {
                paddingSize = (packageBuf.Length + 15) / 16 * 16 - packageBuf.Length;
                packageBuf = AES.AESEncrypt(packageBuf, mEncryptKey.key, mEncryptKey.iv);
            }
        }

        byte[] headBuf = new byte[PackageHead.SizeOf];
        PackageHead head = new PackageHead();
        head.Flags = PackageHeadFlags.Partial;
        head.MessageLength = (ushort)packageBuf.Length;
        head.EncryptPaddingSize = (byte)paddingSize;
        head.WriteTo(headBuf, 0);

        List<byte> sMsgPack = new List<byte>();
        sMsgPack.AddRange(headBuf);
        sMsgPack.AddRange(packageBuf);

        m_MainSocket.Send(sMsgPack.ToArray(), 0, sMsgPack.Count);
    }

    private bool resendMessage()
    {
        if (m_lMsgStack.Count == 0)
            return false;

        List<byte> sMsgPack = new List<byte>();

        for (int i = m_lMsgStack.Count - 1; i >= 0; i--)
        {
            Serclimax.DebugUtils.LogNetwork("Resend lost messge!");
            Serclimax.DebugUtils.LogNetwork("category id:" + m_lMsgStack[i].category_id);
            Serclimax.DebugUtils.LogNetwork("type id:" + m_lMsgStack[i].type_id);
            Serclimax.DebugUtils.LogNetwork("seq id:" + m_lMsgStack[i].seq);

            byte[] packageBuf = Encode(m_lMsgStack[i].pack);
            int paddingSize = 0;
            bool bCompressed = packageBuf.Length <= DEFAULT_COMPRESS_SIZE;
            if (bCompressed)
            {
                packageBuf = Serclimax.CompressUtils.CompressBytes(packageBuf);
            }

            //aes
            if (mEncryptKey != null)
            {
                if (mEncryptKey.encrypt)
                {
                    paddingSize = (packageBuf.Length + 15) / 16 * 16 - packageBuf.Length;
                    packageBuf = AES.AESEncrypt(packageBuf, mEncryptKey.key, mEncryptKey.iv);
                }
            }

            byte[] headBuf = new byte[PackageHead.SizeOf];
            PackageHead head = new PackageHead();
            head.Flags = bCompressed ? PackageHeadFlags.Zip : PackageHeadFlags.Partial;
            head.MessageLength = (ushort)packageBuf.Length;
            head.EncryptPaddingSize = (byte)paddingSize;
            head.WriteTo(headBuf, 0);

            sMsgPack.AddRange(headBuf);
            sMsgPack.AddRange(packageBuf);
        }

        m_MainSocket.Send(sMsgPack.ToArray(), 0, sMsgPack.Count);
        return true;
    }

    private void sendRequestPackage()
    {
        if (m_lSendPackage != null && m_lMsgStack.Count == 0)
        {
            List<byte> sMsgPack = new List<byte>();

            bool bCompressed = false;

            foreach (MessagePackage item in m_lSendPackage)
            {
                byte[] packageBuf = Encode(item);
                int paddingSize = 0;
                bCompressed = packageBuf.Length > DEFAULT_COMPRESS_SIZE;
                if (bCompressed)
                {
                    packageBuf = Serclimax.CompressUtils.CompressBytes(packageBuf);
                }

                //aes
                if (mEncryptKey != null)
                {
                    if (mEncryptKey.encrypt)
                    {
                        paddingSize = (packageBuf.Length + 15) / 16 * 16 - packageBuf.Length;
                        packageBuf = AES.AESEncrypt(packageBuf, mEncryptKey.key, mEncryptKey.iv);
                    }
                }

                byte[] headBuf = new byte[PackageHead.SizeOf];
                PackageHead head = new PackageHead();
                head.Flags = bCompressed ? PackageHeadFlags.Zip : PackageHeadFlags.Partial;
                head.MessageLength = (ushort)packageBuf.Length;
                head.EncryptPaddingSize = (byte)paddingSize;
                head.WriteTo(headBuf, 0);
                sMsgPack.AddRange(headBuf);
                sMsgPack.AddRange(packageBuf);

                if (enableLog)
                {
                    lastSeqId = item.msg.seqid;
                    lastRequestTime = Time.realtimeSinceStartup;

                    ProtoMsg.MsgCategory t = (ProtoMsg.MsgCategory)item.msg.category_id;
                    var pmname = Enum.GetName(typeof(ProtoMsg.MsgCategory), t);
                    if (MsgMap.ContainsKey((ProtoMsg.MsgCategory)item.msg.category_id))
                    {
                        //if(t == ProtoMsg.MsgCategory.Chat && item.msg.type_id == (int))
                        var t1 = MsgMap[(ProtoMsg.MsgCategory)item.msg.category_id];
                        var typename = Enum.GetName(t1, item.msg.type_id);
                        Debug.Log("====SEND categoryId:" + pmname + "  typeId:" + typename);
                    }
                }
            }

            int iRet = m_MainSocket.Send(sMsgPack.ToArray(), 0, sMsgPack.Count);

            if (iRet == sMsgPack.Count)
            {
                foreach (MessagePackage item in m_lSendPackage)
                {
                    if (!CustomPackageFilter(item))
                        m_lMsgStack.Add(new simple_msg_info(item.msg.category_id, item.msg.type_id, item.msg.seqid, item));
                }

                m_lSendPackage.Clear();
                m_lSendPackage = null;
            }
        }
    }

    private bool CustomPackageFilter(MessagePackage msgPack)
    {
        bool result = false;
        //聊天、拉取金币等定时发送消息不进入等待重发队列，以避免等待阻塞其他消息16.11.29
        //由于聊天服务器和游戏服务器分离，所以所有聊天消息都不应该等待重发，以避免聊天服关闭时，阻塞其他协议的发送 17.12.11
        if (msgPack.msg.category_id == 5/* && msgPack.msg.type_id == 302*/)
            result = true;
        if (msgPack.msg.category_id == 3 && msgPack.msg.type_id == 8)
            result = true;
        return result;
    }

    private void reconnectFail()
    {
        m_fConnectTime = -1;
        m_iReconnectCount = 0;
        m_eState = EState.eState_Error;
    }

    private string PackageToString(MessagePackage _package)
    {
        string result = string.Empty;
        result += " Module:" + (_package.msg.category_id).ToString();
        return result;
    }

    public void ErrorCodeHandler(uint _code, Action _okCallback , uint forbid = 0)
    {
        if (_code >= 10000)
        {
            if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug)
            {
                RequestCode enumCode = (RequestCode)_code;
                GUIMgr.Instance.MessageBox(string.Format("{0}({1}{2})", TextManager.Instance.GetText(enumCode.ToString()), "system error: code=", _code), _okCallback, null);
            }
            else
            {
                GUIMgr.Instance.MessageBox("system error: code=" + _code, _okCallback, null);
            }
        }
        else if(_code == (int)RequestCode.Code_Login_IPForbid || _code == (int)RequestCode.Code_Login_AccountForbid
            || _code == (int)RequestCode.Code_Login_DeviceForbid || _code == (int)RequestCode.Code_Login_RoleForbid)
        {
            RequestCode enumCode = (RequestCode)_code;

            string errorStr = string.Format( TextManager.Instance.GetText(enumCode.ToString()) ,
                                            Serclimax.GameTime.SecondToStringYMDLocal(forbid));
            GUIMgr.Instance.MessageBox(errorStr, _okCallback, null);
        }
        else
        {
            RequestCode enumCode = (RequestCode)_code;
            GUIMgr.Instance.MessageBox(TextManager.Instance.GetText(enumCode.ToString()), _okCallback, null);
        }
    }

    public void BackToLogin()
    {
        //if (!Main.Instance.IsInLoginState())
            {
                Close();
                sInstance = null;
            }
            GUIMgr.Instance.CloseAllMenu();
            GUIMgr.Instance.LockScreen();
        Main.Instance.CurrentGameState.OnLeave(); 
#if SUPPORT_CHANGE_SCENE
        ChangeSceneHeldObject.ClearHeldObjects();
        UnityEngine.SceneManagement.SceneManager.UnloadScene(1);
#endif
           GameObject main = GameObject.Find("Main");
           if(main!=null)
           {
            /*     GameObject.DestroyObject(main.GetComponent<LuaClient>());
                 GameObject.DestroyObject(main.GetComponent<LuaLooper>());
                 GameObject.DestroyObject(main.GetComponent<GUIMgr>());

                 GameObject.DestroyObject(main.GetComponent<AssetBundleManager>());
                 GameObject.DestroyObject(main.GetComponent<CountDown>());
                 GameObject.DestroyObject(main.GetComponent<Main>());
                 */
         //   GameObject.Destroy(main);
             //  LuaClient.Instance = null;
           }

        //   Main.Instance.Restart();
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
      //  Main.lua.Restart();
    }

    //public void RequestSyncTime()
    //{
    //    MsgServerGameTimeRequest req = new MsgServerGameTimeRequest();
    //    req.clientTime = (ulong)Serclimax.GameTime.GetMilSecTime();
    //    NetworkManager.instance.Request<MsgServerGameTimeRequest>((uint)MsgCategory.Login, (uint)LoginTypeId.Login.MsgServerGameTimeRequest,
    //                                                                      req, OnSyncTime);
    //}

    //void OnSyncTime(byte[] data)
    //{
    //    MsgServerGameTimeResponse rsp = NetworkManager.instance.Decode<MsgServerGameTimeResponse>(data);
    //    if (rsp != null)
    //    {
    //        ulong sendClientTime = rsp.clientTime;
    //        ulong serverTime = rsp.serverTime;
    //        //remove delay here to make more accurate
    //        long networkDelayHalf = (Serclimax.GameTime.GetMilSecTime() - (long)sendClientTime) / 2;
    //        Serclimax.GameTime.guessHalfNetworkDelay = (int)networkDelayHalf;
    //        Serclimax.GameTime.SetServerTimeMilSec(serverTime);
    //    }
    //}

    public int GetLockScreenCount()
    {
        return mListLockScreen.Count;
    }
}
