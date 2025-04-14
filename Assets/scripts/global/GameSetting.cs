using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System;

using Serclimax;

public class GameSetting
{
    public delegate void NoticeSaveOptionsCallBake();

#if UNITY_EDITOR
    public static int DefaultQualityLevel = 2;
#elif UNITY_ANDROID
    public static int DefaultQualityLevel = 0;
#elif UNITY_IPHONE
    public static int DefaultQualityLevel = 0;
#endif

    static GameSetting s_instance = null;
	public static GameSetting instance
	{
		get
		{
			if (s_instance == null)
			{
				s_instance = new GameSetting();
			}
			return s_instance;
		}	
	}

	public enum ESavingType
	{
		ePlayerData = 0,		
		eOptions,
        eBattle,
        eGuide,
		eCount,
	}

	public class OptionData
	{
		public string		mExeVersion;
		public string		mResVersion;
		public int			mGameSpeedLevel;
        public bool         mSoundSetting = true;
		public bool         mMusicSetting = true;
        public int          mQualityLevel = 1;
        public string       mLanguage;
	};

	private static readonly string[] SaveFileNames = new string[(int)ESavingType.eCount]
	{
		"/player.bin",
		"/options.bin",
        "/battle.bin",
        "/guide.bin",
	};

	private OptionData	mOptionData = new OptionData();
	public OptionData option
	{
		get
		{
			return mOptionData;
		}
        set
        {
            mOptionData = value;
        }
	}

    public NoticeSaveOptionsCallBake NoticeSaveOptions = null;

	private bool[] mHasRecord = new bool[(int)ESavingType.eCount];

	private Dictionary<string, string>		mSavingData = new Dictionary<string, string> ();


	public void SetSavingData(ESavingType _eType, string _data, bool _saveDisk = true)
	{
		string param = SaveFileNames [(int)_eType];

		if (mSavingData.ContainsKey (param)) 
		{
			mSavingData[param] = _data;	
		}
		else
		{
			mSavingData.Add(param, _data);
		}
		if (_saveDisk)
		{
			try
			{
				string sFilePath = PlatformUtils.SAVE_PATH + param;

				FileStream fs = new FileStream(sFilePath, FileMode.Create);
				BinaryWriter bw = new BinaryWriter(fs, Encoding.Unicode);

				bw.Write(GetSavingData(_eType));	

				fs.Flush();
				fs.Close();
				bw.Close();

			}
			catch (IOException exception)
			{
				DebugUtils.Log(exception.Message);
			}
		}
	}

	public string GetSavingData(ESavingType _eType)
	{
		string param = SaveFileNames [(int)_eType];
		
		if (mSavingData.ContainsKey (param)) 
		{
			return mSavingData[param];	
		}
		else
		{
			return string.Empty;
		}
	}
	
	public bool Init()
	{
		bool bRet = false;

		for (int i = (int)ESavingType.ePlayerData; i < (int)ESavingType.eCount; i ++) 
		{
			mHasRecord[i] = false;	
		}

		LoadAll();

		if (!HasRecord (ESavingType.eOptions)) 
		{
            
			mOptionData.mExeVersion = GameVersion.EXE;
			mOptionData.mResVersion = GameVersion.RES;
			mOptionData.mGameSpeedLevel = 0;
			mOptionData.mMusicSetting = true;
			mOptionData.mSoundSetting = true;
            mOptionData.mQualityLevel = DefaultQualityLevel;
            mOptionData.mLanguage = WSdkManager.instance.GetSystemLanguage().ToString();

			SaveOption();
            
			bRet = true;
		}
		else
		{
			Dictionary<string, object> param = OurMiniJSON.Json.Deserialize(GetSavingData(ESavingType.eOptions)) as Dictionary<string, object>;
			if (param.ContainsKey("exe"))
			{
				mOptionData.mExeVersion = (string)param["exe"];
			}

			if (param.ContainsKey("res"))
			{
				mOptionData.mResVersion = (string)param["res"];
			}

			if (param.ContainsKey("gamespeed"))
			{
				mOptionData.mGameSpeedLevel = int.Parse((string)param["gamespeed"]);
			}

            if(param.ContainsKey("sound"))
            {
                mOptionData.mSoundSetting = bool.Parse((string)param["sound"]);
            }
            else
            {
                mOptionData.mSoundSetting = true;
            }

            if(param.ContainsKey("music"))
            {
                mOptionData.mMusicSetting = bool.Parse((string)param["music"]);
            }
            else
            {
                mOptionData.mMusicSetting = true;
            }

            if(param.ContainsKey("quality"))
            {
                mOptionData.mQualityLevel = int.Parse((string)param["quality"]);
            }
            else
            {
                mOptionData.mQualityLevel = DefaultQualityLevel;
            }

            if(param.ContainsKey("language"))
            {
                mOptionData.mLanguage = (string)param["language"];
            }
			
			//check save version and local version
			if (string.IsNullOrEmpty(mOptionData.mExeVersion) || float.Parse(mOptionData.mExeVersion) != float.Parse(GameVersion.EXE))
			{
				//update the version number
				mOptionData.mExeVersion = GameVersion.EXE;
				mOptionData.mResVersion = GameVersion.RES;
				SaveOption();

				bRet = true;
			}
		}

        LoadLoginInfo();

        return bRet;
	}

	public bool HasRecord(ESavingType eType)
	{
		if (eType < ESavingType.ePlayerData || eType >= ESavingType.eCount) 
		{
			return false;	
		}
		else
		{
			return mHasRecord[(int)eType];
		}
	}

	public void ResetAllData()
	{
		try
		{
			for (int i = (int)ESavingType.ePlayerData; i < (int)ESavingType.eCount; i ++)
			{
				bool fileExist = File.Exists(PlatformUtils.SAVE_PATH + SaveFileNames[i]);
				if (fileExist)
				{
					File.Delete(PlatformUtils.SAVE_PATH + SaveFileNames[i]);
				}
			}
		}
		catch (IOException exception)
		{
			DebugUtils.Log(exception.Message);
		}

		mSavingData.Clear ();

		Init ();
    }

    public void SaveOption()
	{
		Dictionary<string, object> param = new Dictionary<string, object>();
		param["exe"] = mOptionData.mExeVersion;
		param["res"] = mOptionData.mResVersion;
		param["gamespeed"] = mOptionData.mGameSpeedLevel.ToString();
        param["sound"] = mOptionData.mSoundSetting.ToString();
		param["music"] = mOptionData.mMusicSetting.ToString();
        param["quality"] = mOptionData.mQualityLevel.ToString();
        param["language"] = mOptionData.mLanguage;

		SetSavingData(ESavingType.eOptions, OurMiniJSON.Json.Serialize(param), true);
        if(NoticeSaveOptions!=null)
            NoticeSaveOptions();
	}

    public void ClearLoginInfo()
    {
     /*   WSdkManager.instance.loginType = 0;
        WSdkManager.instance.uid = "";
        WSdkManager.instance.session = "";
        WSdkManager.instance.uname = "";
        WSdkManager.instance.keyurl = "";
        WSdkManager.instance.salt = "";
        WSdkManager.instance.signature = ""; */

    }

    public void SaveLoginInfo()
    {
        Dictionary<string, object> param = new Dictionary<string, object>();

        WSdkManager.instance.zoneIdList[WSdkManager.instance.uid] = WSdkManager.instance.zoneId;
        param["zoneidlist"] = OurMiniJSON.Json.Serialize(WSdkManager.instance.zoneIdList);
        param["zoneid"]     = WSdkManager.instance.zoneId.ToString();
        param["logintype"]  = WSdkManager.instance.loginType.ToString();
        param["accountid"]  = WSdkManager.instance.uid;
        param["token"]      = WSdkManager.instance.session;
        param["name"]       = WSdkManager.instance.uname;
        param["keyurl"]     = WSdkManager.instance.keyurl;
        param["salt"]       = WSdkManager.instance.salt;
        param["signature"]  = WSdkManager.instance.signature;

       SetSavingData(ESavingType.ePlayerData, OurMiniJSON.Json.Serialize(param));
    }

    public void LoadLoginInfo()
    {
        if (HasRecord(GameSetting.ESavingType.ePlayerData))
        {
            Dictionary<string, object> param = OurMiniJSON.Json.Deserialize(GetSavingData(ESavingType.ePlayerData)) as Dictionary<string, object>;

            if (param.ContainsKey("zoneidlist"))
            {
                var zoneIdList = OurMiniJSON.Json.Deserialize((string)param["zoneidlist"]) as Dictionary<string, object>;
                foreach (var zondId in zoneIdList)
                {
                    WSdkManager.instance.zoneIdList[zondId.Key] = Convert.ToInt32(zondId.Value);
                }
            }

            if (param.ContainsKey("logintype"))
            {
                WSdkManager.instance.loginType = int.Parse((string)param["logintype"]);
            }
            else
            {
                WSdkManager.instance.loginType = 0;
            }

            if (param.ContainsKey("accountid"))
            {
                WSdkManager.instance.uid = (string)param["accountid"];
            }
            else
            {
                WSdkManager.instance.uid = "";
            }

            WSdkManager.instance.zoneId = 0;
            var uid = WSdkManager.instance.uid;
            if (uid != "" && WSdkManager.instance.zoneIdList.ContainsKey(uid))
            {
                WSdkManager.instance.zoneId = WSdkManager.instance.zoneIdList[uid];
            }

            if (param.ContainsKey("token"))
            {
                WSdkManager.instance.session = (string)param["token"];
            }
            else
            {
                WSdkManager.instance.session = "";
            }

            if (param.ContainsKey("name"))
            {
                WSdkManager.instance.uname = (string)param["name"];
            }
            else
            {
                WSdkManager.instance.uname = "";
            }

            if (param.ContainsKey("keyurl"))
            {
                WSdkManager.instance.keyurl = (string)param["keyurl"];
            }
            else
            {
                WSdkManager.instance.keyurl = "";
            }

            if (param.ContainsKey("salt"))
            {
                WSdkManager.instance.salt = (string)param["salt"];
            }
            else
            {
                WSdkManager.instance.salt = "";
            }

            if (param.ContainsKey("signature"))
            {
                WSdkManager.instance.signature = (string)param["signature"];
            }
            else
            {
                WSdkManager.instance.signature = "";
            }
        }
    }

    public void SaveAll()
	{
		if (!Constants.ENABLE_FAKE_DATA)
			return;

		try
		{
			for (int i = (int)ESavingType.ePlayerData; i < (int)ESavingType.eCount; i ++)
			{
				string sFilePath = PlatformUtils.SAVE_PATH + SaveFileNames[i];

				FileStream fs = new FileStream(sFilePath, FileMode.Create);
				BinaryWriter bw = new BinaryWriter(fs, Encoding.Unicode);

				bw.Write(GetSavingData((ESavingType) i));

				fs.Flush();
				fs.Close();
				bw.Close();

			}
		}
		catch (IOException exception)
		{
			DebugUtils.Log(exception.Message);
		}
	}
	
	void LoadAll()
	{
		try
		{
			for (int i = (int)ESavingType.ePlayerData; i < (int)ESavingType.eCount; i ++)
			{

				bool fileExist = File.Exists(PlatformUtils.SAVE_PATH + SaveFileNames[i]);
				if(!fileExist)
					continue;

				FileStream fs = new FileStream(PlatformUtils.SAVE_PATH + SaveFileNames[i], FileMode.OpenOrCreate);
				BinaryReader br = new BinaryReader(fs, Encoding.Unicode);

				if(fs == null)
					continue;

				long fileLength = fs.Length;
				if(fileLength == 0)
				{
					fs.Flush();
					fs.Close();
					br.Close();
					continue;
				}

				string param = br.ReadString();
				SetSavingData((ESavingType)i, param, false);
				
				fs.Flush();
				fs.Close();
				br.Close();
				
				mHasRecord[i] = true;
			}
		}
		catch (IOException exception)
		{
			DebugUtils.Log(exception.Message);
		}
	}
	
}
