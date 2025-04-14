using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Mono.Xml;
using System.Security;
using System.Threading.Tasks;
using Serclimax;
using UnityEngine.Networking;

public class ConfigFileManager
{
    static readonly float CHECK_WAIT_TIME = 10.0f; //5 sec
    static readonly float CHECK_TIMEOUT = 20.0f; //20sec

    static ConfigFileManager s_pInstance = null;

    public static ConfigFileManager instance
    {
        get
        {
            if (s_pInstance == null)
            {
                s_pInstance = new ConfigFileManager();
            }

            return s_pInstance;
        }
    }

    public readonly string sConfigUrlDev = "http://192.168.8.58:8085/loginlist.xml";
    public readonly string sConfigUrlDist = "http://192.168.8.58:8085/loginlist.xml";
    public readonly string sConfigUrlTest = "http://192.168.8.58:8085/loginlist.xml";


    public readonly string sSaveLoginlist = "loginlist.bin";

    UnityWebRequest m_wRequest = null;
    float m_fTime = -1;
    bool m_bUseLocal = false;

    public class ServerData
    {
        public string mServerIp;
        public string mServerPort;
        public string mServerName;
        public int mServerOrder;
    }

    public class ResourceData
    {
        public string mResourceName;
        public int mVersion;
        public int mFileSize;
        public string mMD5;
    }

    public class ConfigData
    {
        //login server
        public List<ServerData> mListLoginServer = new List<ServerData>();
    }

    public ConfigData m_ConfigData = new ConfigData();

    private void ClearConfigData()
    {
        m_ConfigData.mListLoginServer.Clear();
    }

    public void StartCheckConf()
    {
        string sUrl = null;
        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)
        {
            sUrl = sConfigUrlTest;
        }
        else if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDist)
        {
            sUrl = sConfigUrlDist;
        }
        else
        {
            sUrl = sConfigUrlDev;
        }

        if (WSdkManager.instance.platform == ProtoMsg.AccType.AccType_adr_official ||
            WSdkManager.instance.platform == ProtoMsg.AccType.AccType_adr_official_branch ||
            WSdkManager.instance.platform == ProtoMsg.AccType.AccType_ios_official)
        {
            sUrl = sUrl.Replace("loginlist", "loginlist_new");
        }

        if (m_wRequest == null)
        {
            // m_wRequest = UnityWebRequest.Get(sUrl);
            // var operation = m_wRequest.SendWebRequest();
            // operation.completed += (asyncOp) =>
            // {
            // 	if (m_wRequest.result == UnityWebRequest.Result.Success)
            // 	{
            // 		m_fTime = 0;
            // 		m_bUseLocal = false;
            // 	}
            // 	else
            // 	{
            // 		Debug.LogError("Failed: " + m_wRequest.error);
            // 	}
            // };

            GetRequest(sUrl);
            
            
        }
    }

    private void GetRequest(string sUrl)
    {
        if (string.IsNullOrEmpty(sUrl))
        {
            Debug.LogError("server url is null");
            return;
        }

        m_wRequest = new UnityWebRequest(sUrl, UnityWebRequest.kHttpVerbGET);
        m_wRequest.downloadHandler = new DownloadHandlerBuffer();
        m_wRequest.SendWebRequest().completed += (asyncOp) =>
        {
            if (m_wRequest is not { result: UnityWebRequest.Result.Success })
            {
                Debug.LogError("Error: " + m_wRequest.error);
            }
            else
            {
                Debug.Log("Response sucees ");
                m_fTime = 0;
                m_bUseLocal = false;
            }
        };

    }


    public void Update()
    {
        if (m_fTime >= 0)
        {
            m_fTime += GameTime.realDeltaTime;

            if (m_fTime >= CHECK_TIMEOUT)
            {
                //time out use local file
                m_bUseLocal = true;
                FinishCheckConf(true);
                m_fTime = -1;
            }
            else if (m_fTime >= CHECK_WAIT_TIME)
            {
                m_bUseLocal = true;
                if (!m_bUseLocal)
                {
                    m_bUseLocal = true;
                }
                else if (m_wRequest != null)
                {
                    if (m_wRequest.isDone)
                    {
                        SaveConfDataByWWW(m_wRequest.downloadHandler.text);
                        FinishCheckConf(true);
                        m_fTime = -1;
                    }
                }
            }
        }
    }

    public string CheckConfError()
    {
        if (m_bUseLocal)
        {
            return null;
        }
        else
        {
            if (m_wRequest != null)
            {
                return m_wRequest.error;
            }
            else
            {
                return null;
            }
        }
    }

    public bool CheckConfEnd()
    {
        if (m_bUseLocal)
        {
            return true;
        }
        else
        {
            if (m_wRequest != null)
            {
                return m_wRequest.isDone;
            }
            else
            {
                return false;
            }
        }
    }

    public void FinishCheckConf(bool _forceFinish = false)
    {
        if (!m_bUseLocal || _forceFinish)
        {
            if (m_wRequest != null)
            {
                m_wRequest.Dispose();
                m_wRequest = null;
            }

            //m_bUseLocal = false;
        }
    }

    string getLoginListFileName()
    {
        string fileName = "";
        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug)
        {
            fileName = "loginlist_dev";
        }
        else if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)
        {
            fileName = "loginlist_release";
        }
        else
        {
            fileName = "loginlist_dist";
        }

        return fileName;
    }

    void LoadConfData(string _filename)
    {
        string sSaveFile = PlatformUtils.SAVE_PATH + "/" + _filename + ".bin";
        string param = "";
        try
        {
            FileStream fs = new FileStream(sSaveFile, FileMode.OpenOrCreate);
            BinaryReader br = new BinaryReader(fs, System.Text.Encoding.Unicode);

            param = br.ReadString();

            fs.Flush();
            fs.Close();
            br.Close();
        }
        catch (IOException exception)
        {
            DebugUtils.Log(exception.Message);
        }

        if (param != "")
        {
            Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(param) as Dictionary<string, object>;
            if (data.ContainsKey("loginserver"))
            {
                Dictionary<string, object> server =
                    OurMiniJSON.Json.Deserialize((string)data["loginserver"]) as Dictionary<string, object>;
                foreach (string _key in server.Keys)
                {
                    Dictionary<string, object> serverData =
                        OurMiniJSON.Json.Deserialize((string)server[_key]) as Dictionary<string, object>;
                    ServerData _data = new ServerData();
                    _data.mServerIp = (string)serverData["ip"];
                    _data.mServerPort = (string)serverData["port"];
                    _data.mServerName = (string)serverData["name"];
                    _data.mServerOrder = (int)(long)serverData["index"];
                    m_ConfigData.mListLoginServer.Add(_data);
                }
            }
        }
    }

    void SaveConfDataByWWW(string _xml)
    {
        string fileName = getLoginListFileName();
        string sSaveFile = PlatformUtils.SAVE_PATH + "/" + fileName + ".bin";

        if (File.Exists(sSaveFile))
        {
            File.Delete(sSaveFile);
        }

        parseConfData(_xml);
        SaveConfData(fileName);
    }

    void SaveConfData(string _filename)
    {
        string sSaveFile = PlatformUtils.SAVE_PATH + "/" + _filename + ".bin";

        if (File.Exists(sSaveFile))
        {
            File.Delete(sSaveFile);
        }

        Dictionary<string, object> param = new Dictionary<string, object>();

        Dictionary<string, object> server = new Dictionary<string, object>();
        for (int i = 0; i < m_ConfigData.mListLoginServer.Count; i++)
        {
            Dictionary<string, object> serverData = new Dictionary<string, object>();
            serverData["ip"] = m_ConfigData.mListLoginServer[i].mServerIp;
            serverData["port"] = m_ConfigData.mListLoginServer[i].mServerPort;
            serverData["name"] = m_ConfigData.mListLoginServer[i].mServerName;
            serverData["index"] = m_ConfigData.mListLoginServer[i].mServerOrder;
            server["server:" + i] = OurMiniJSON.Json.Serialize(serverData);
        }

        param["loginserver"] = OurMiniJSON.Json.Serialize(server);

        try
        {
            FileStream fs = new FileStream(sSaveFile, FileMode.OpenOrCreate);
            BinaryWriter bw = new BinaryWriter(fs, System.Text.Encoding.Unicode);

            bw.Write(OurMiniJSON.Json.Serialize(param));

            fs.Flush();
            fs.Close();
            bw.Close();
        }
        catch (IOException exception)
        {
            DebugUtils.Log(exception.Message);
        }
    }

    public bool ParseConfData(bool _forceLocal = false)
    {
        ClearConfigData();

        bool bRet = false;

        string fileName = getLoginListFileName();
        if (m_bUseLocal || _forceLocal)
        {
            string sSaveFile = PlatformUtils.SAVE_PATH + "/" + fileName + ".bin";
            if (File.Exists(sSaveFile))
            {
                LoadConfData(fileName);
                bRet = true;
            }
            else
            {
                TextAsset asset = Resources.Load(fileName) as TextAsset;
                if (asset != null)
                {
                    bRet = parseConfData(asset.text);
                    SaveConfData(fileName);
                }

                if (!bRet)
                {
                    DebugUtils.LogError("invalid client package!");
                }
            }
        }
        else
        {
            if (m_wRequest != null)
            {
                if (m_wRequest.downloadHandler.data.Length <= 0)
                {
                    DebugUtils.Log("Config File is invalid!");
                }
                else
                {
                    bRet = parseConfData(m_wRequest.downloadHandler.text);
                    if (bRet)
                    {
                        SaveConfData(fileName);
                    }
                }
            }
        }

        return bRet;
    }

    bool parseConfData(string _xml)
    {
        bool bRet = true;

        SecurityParser parser = new SecurityParser();
        parser.LoadXml(_xml);
        SecurityElement root = parser.ToXml();

        foreach (SecurityElement node in root.Children)
        {
            if (node.Tag == "loginserver")
            {
                foreach (SecurityElement subNode in node.Children)
                {
                    if (subNode.Tag == "server")
                    {
                        ServerData server = new ServerData();
                        server.mServerIp = subNode.Attribute("ip");
                        server.mServerPort = subNode.Attribute("port");
                        server.mServerName = subNode.Attribute("name");
                        string order = subNode.Attribute("index");
                        server.mServerOrder = string.IsNullOrEmpty(order) ? 0 : int.Parse(order);
                        m_ConfigData.mListLoginServer.Add(server);
                    }
                    else
                    {
                        DebugUtils.Log("Invalid login server data:" + subNode.Tag);
                        bRet = false;
                    }
                }
            }
        }

        return bRet;
    }

    public ServerData GetRandomServerData(int _index)
    {
        if (_index == -1)
        {
            _index = Random.Range(0, m_ConfigData.mListLoginServer.Count);
        }

        return m_ConfigData.mListLoginServer[_index];
    }
}