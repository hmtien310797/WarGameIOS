using UnityEngine;
using UnityEditor;
using System.IO;

public class AndroidBuild 
{
    static string[] exportScenes = new string[] { "Assets/scenes/first.unity", "Assets/scenes/main.unity", "Assets/scenes/load_middle.unity" };

    static void CheckStreamingAsset(BuildTarget _target)
    {
		//check the streaming asset
		if (!Directory.Exists(Application.streamingAssetsPath))
		{
			Directory.CreateDirectory(Application.streamingAssetsPath);
		}

		if (_target == BuildTarget.iOS)
		{
			if (Directory.Exists(Application.streamingAssetsPath + "/AssetBundles_iOS"))
			{
				DirectoryInfo dir = new DirectoryInfo(Application.streamingAssetsPath + "/AssetBundles_iOS");
				dir.Delete(true);
			}
			CopyDirectory("./AssetBundles_iOS/", Application.streamingAssetsPath + "/AssetBundles_iOS");
		}
		else if (_target == BuildTarget.Android)
		{
			if (Directory.Exists(Application.streamingAssetsPath + "/AssetBundles_ANDROID"))
			{
				DirectoryInfo dir = new DirectoryInfo(Application.streamingAssetsPath + "/AssetBundles_ANDROID");
				dir.Delete(true);
			}			
			CopyDirectory("./AssetBundles_ANDROID/", Application.streamingAssetsPath + "/AssetBundles_ANDROID");
		}

		System.GC.Collect();
	}

    static void SetVersion()
    {
        PlayerSettings.bundleVersion = GameVersion.EXE;
        
        string verFile = Application.dataPath + "/../../autobuild/version.txt";

        Debug.Log("path::" + verFile);

        if (File.Exists(verFile))
        {
            File.Delete(verFile);
        }

        string sEnv = "debug";
        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)
        {
            sEnv = "release";
        }
        else if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDist)
        {
            sEnv = "dist";
        }
        else
        {
            sEnv = "debug";
        }

        FileStream fs = File.OpenWrite(verFile);
        StreamWriter sw = new StreamWriter(fs);
        sw.WriteLine("VERSION_CODE=" + GameVersion.EXE);
        sw.WriteLine("APK_NAME=" + "wgame_" + sEnv + "_");
        sw.WriteLine("BUILD=" + GameVersion.BUILD);
		sw.WriteLine("ENV=" + sEnv);
        sw.Flush();
        sw.Close();
        fs.Close();
    }
    public static void DelectDir(string srcPath)
    {
        try
        {
            DirectoryInfo dir = new DirectoryInfo(srcPath);
            FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //返回目录中所有文件和子目录
            foreach (FileSystemInfo i in fileinfo)
            {
                if (i is DirectoryInfo)            //判断是否文件夹
                {
                    DirectoryInfo subdir = new DirectoryInfo(i.FullName);
                    subdir.Delete(true);          //删除子目录和文件
                }
                else
                {
                    File.Delete(i.FullName);      //删除指定文件
                }
            }
        }
        catch (System.Exception e)
        {
            
        }
    }

    static void CopyDirectory(string srcDir, string tgtDir,bool meta = false)
	{
		DirectoryInfo source = new DirectoryInfo (srcDir);
		DirectoryInfo target = new DirectoryInfo (tgtDir);

		if (target.FullName.StartsWith (source.FullName, System.StringComparison.InvariantCultureIgnoreCase)) 
		{
			return;
		}
		
		if (!source.Exists)
			return;
		
		if (source.Name.ToLower ().Equals (".svn")) 
		{
			return;
		}
		
		if (!target.Exists)
			target.Create ();
		
		FileInfo[] files = source.GetFiles ();
		for (int i = 0; i < files.Length; i ++) 
		{
			if (files[i].Name.ToLower().Equals(".svn"))
			{
				return;
			}

            if (meta)
            {
                if (!files[i].Name.ToLower().Equals(".meta"))
                {
                    File.Copy(files[i].FullName, target.FullName + "/" + files[i].Name, true);
                }
            }
            else
            {
                File.Copy(files[i].FullName, target.FullName + "/" + files[i].Name, true);
            }

		}
		
		DirectoryInfo[] dirs = source.GetDirectories ();
		for (int j = 0; j < dirs.Length; j ++) 
		{
			CopyDirectory(dirs[j].FullName, target.FullName + "/" + dirs[j].Name);
		}
	}

	static string GetBuildPathAndroid()
	{
		string dirPath = Application.dataPath +"/../../AndroidProjectTemp";
		if(!System.IO.Directory.Exists(dirPath)){
			System.IO.Directory.CreateDirectory(dirPath);
		}
		return dirPath;
	}

	static void ExportAndroidProject()
	{
        //set version
        SetVersion();

        ToLuaMenu.ClearLuaFiles();
        ToLuaMenu.CopyLuaFilesToRes();

        BuildTarget target = BuildTarget.Android;
        BuildOptions options = 0;
        options = BuildOptions.AcceptExternalModificationsToPlayer;

        PlayerSettings.Android.useAPKExpansionFiles = GameEnviroment.NeedAndroidObb;


        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug || GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)
        {
            options |= BuildOptions.Development;
        }

        UITextureChangeTool.ChangeTextures(Application.dataPath + "/UI/atlases", false);


        //streaming asset
        CheckStreamingAsset(target);

        string savePath = GetBuildPathAndroid();
        #if UNITY_IPHONE
        PlayerSettings.enableInternalProfiler = true;
        #endif
        string error = BuildPipeline.BuildPlayer(exportScenes, savePath, target, options).ToString();

        Debug.Log("error:" + error);
        UITextureChangeTool.Recover(Application.dataPath + "/UI/atlases", false);
    }

	static string GetBuildPathPC()
	{
		string dirPath = Application.dataPath +"/../../PCProjectTemp/wgame.exe";
		if(!System.IO.Directory.Exists(dirPath)){
			System.IO.Directory.CreateDirectory(dirPath);
		}
		return dirPath;
	}

	static void ExportPCProject()
	{
		BuildTarget target = BuildTarget.StandaloneWindows;
		BuildOptions options = BuildOptions.None;
		string savePath = GetBuildPathPC();
		BuildPipeline.BuildPlayer(exportScenes, savePath, target, options);
	}

	static string GetBuildPathiOS()
	{
		string dirPath = Application.dataPath +"/../../iOSProjectTemp";
		if(!System.IO.Directory.Exists(dirPath)){
			System.IO.Directory.CreateDirectory(dirPath);
		}
		return dirPath;
	}

    public static string plat = "";


	static void ExportiOSProject()
	{
        string[] args = System.Environment.GetCommandLineArgs();
        
        DelectDir(Application.dataPath + "/garbage");
		int i = 0;
		for (i = 0; i < args.Length; i++) 
		{
			if (args [i] == "AndroidBuild.ExportiOSProject") 
			{
				i++;
				break;
			}
		}

		if (i >= args.Length) 
		{
			Serclimax.DebugUtils.Log("ExportiOSProject Error: invalid params");
			return;
		}

        plat = args[i];
        if (args[i] == "self")
        {
            PlayerSettings.iPhoneBundleIdentifier = "com.koudai.kdzz";
            PlayerSettings.iOS.applicationDisplayName = "wgame";
            PlayerSettings.iOS.scriptCallOptimization = ScriptCallOptimizationLevel.SlowAndSafe;
#if UNITY_IPHONE
			PlayerSettings.iOS.appleEnableAutomaticSigning = false;
#endif
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_self_ios;
            AssetDatabase.Refresh();
        }
        else if (args[i] == "taptap")
        {
			PlayerSettings.iPhoneBundleIdentifier = "com.weywell.wgame.testflight";
			PlayerSettings.iOS.applicationDisplayName = "口袋战争";
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_taptap;
        }
		else if (args[i] == "efun")
		{  
			exportScenes = new string[] { "Assets/scenes/main.unity","Assets/scenes/load_middle.unity"};
			PlayerSettings.iPhoneBundleIdentifier = "com.zanky.wegame";
			PlayerSettings.iOS.applicationDisplayName = "War in Pocket";
#if UNITY_IPHONE
            PlayerSettings.iOS.appleEnableAutomaticSigning = false;   
#endif
            CopyDirectory(Application.dataPath + "/texture/splash_efun", Application.dataPath + "/texture/splash");
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_efun;
            AssetDatabase.Refresh();

            
        }
        else if (args[i] == "india")
        {
            exportScenes = new string[] { "Assets/scenes/main.unity", "Assets/scenes/load_middle.unity" };
            PlayerSettings.iPhoneBundleIdentifier = "com.kingfish.koudaiindia";
            PlayerSettings.iOS.applicationDisplayName = "War In Pocket（Elite）";
#if UNITY_IPHONE
            PlayerSettings.iOS.appleEnableAutomaticSigning = false;   
#endif
            CopyDirectory(Application.dataPath + "/texture/splash_efun", Application.dataPath + "/texture/splash");
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_india;
            AssetDatabase.Refresh();


        }
        else if (args[i] == "ppgame_tw")
			
        {
            PlayerSettings.iPhoneBundleIdentifier = "com.digitalsky.wip.sea";
            PlayerSettings.iOS.applicationDisplayName = "我的戰爭";
			WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_tw_digiSky;
			CopyDirectory(Application.dataPath + "/texture/splash_ppgame", Application.dataPath + "/texture/splash");
			AssetDatabase.Refresh ();
        }
        else if (args[i] == "ppgame_kor")
        {
            PlayerSettings.iPhoneBundleIdentifier = "com.digitalsky.wip.kr";
            PlayerSettings.iOS.applicationDisplayName = "워게임:WW2";
			WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_kr_digiSky;
			CopyDirectory(Application.dataPath + "/texture/splash_ppgame", Application.dataPath + "/texture/splash");
			AssetDatabase.Refresh ();
        }
		else if (args[i] == "mzyw")
		{
			PlayerSettings.iPhoneBundleIdentifier = "com.koudai.kdzz";
			PlayerSettings.iOS.applicationDisplayName = "口袋战争";

#if UNITY_IPHONE
            CopyDirectory(Application.dataPath + "/texture/mzyw_icon", Application.dataPath + "/texture/efun_icon", true);

            PlayerSettings.iOS.applicationDisplayName = "战场指挥官";
			PlayerSettings.iOS.appleEnableAutomaticSigning = false;
            string dir = System.IO.Path.GetDirectoryName(Application.dataPath) + "/garbage";
            if (Directory.Exists(dir))
            {
                CopyDirectory(dir, Application.dataPath + "/garbage");
            }
#endif
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_muzhi;
			CopyDirectory(Application.dataPath + "/texture/splash_mz", Application.dataPath + "/texture/splash");
			AssetDatabase.Refresh ();
		}
        else if (args[i] == "official")
        {

			Serclimax.DebugUtils.Log("ExportiOSProject: " + args[i]);

         //   exportScenes = new string[] { "Assets/scenes/main.unity", "Assets/scenes/load_middle.unity" };
            PlayerSettings.iPhoneBundleIdentifier = "com.zanky.koudai";
            PlayerSettings.iOS.applicationDisplayName = "统帅战争";
#if UNITY_IPHONE
            PlayerSettings.iOS.appleEnableAutomaticSigning = false;  
            string dir = System.IO.Path.GetDirectoryName(Application.dataPath) + "/garbage";
            if (Directory.Exists(dir))
            {
                CopyDirectory(dir, Application.dataPath + "/garbage");
            }


#endif
            CopyDirectory(Application.dataPath + "/texture/splash_official", Application.dataPath + "/texture/splash");
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_official;
            AssetDatabase.Refresh();


        }
        else if (args[i] == "mzyw_zhqx")
        {
            PlayerSettings.iPhoneBundleIdentifier = "com.game.zzml";
            PlayerSettings.iOS.applicationDisplayName = "战争命令";
#if UNITY_IPHONE
            PlayerSettings.iOS.appleEnableAutomaticSigning = false;
            CopyDirectory(Application.dataPath + "/texture/mzyw_icon", Application.dataPath + "/texture/mzyw_icon_ml", true);

            string dir = System.IO.Path.GetDirectoryName(Application.dataPath) + "/garbage1";
            if (Directory.Exists(dir))
            {
                CopyDirectory(dir, Application.dataPath + "/garbage");
            }
#endif
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_muzhi;
            CopyDirectory(Application.dataPath + "/texture/splash_mz", Application.dataPath + "/texture/splash");
            AssetDatabase.Refresh();
        }
        else if (args[i] == "mzyw_zhsj")
        {
            PlayerSettings.iPhoneBundleIdentifier = "com.game.zhfx";
            PlayerSettings.iOS.applicationDisplayName = "战火防线";
#if UNITY_IPHONE
			PlayerSettings.iOS.appleEnableAutomaticSigning = false;
            CopyDirectory(Application.dataPath + "/texture/mzyw_icon", Application.dataPath + "/texture/mzyw_icon_fx", true);

            string dir = System.IO.Path.GetDirectoryName(Application.dataPath) + "/garbage2";
            if (Directory.Exists(dir))
            {
                CopyDirectory(dir, Application.dataPath + "/garbage");
            }
#endif
            WSdkManager.mChannel = ProtoMsg.AccType.AccType_ios_muzhi;
            CopyDirectory(Application.dataPath + "/texture/splash_mz", Application.dataPath + "/texture/splash");
            AssetDatabase.Refresh();
        }

        SetVersion();

        ToLuaMenu.ClearLuaFiles();
        ToLuaMenu.CopyLuaFilesToRes();

		BuildTarget target = BuildTarget.iOS;
		BuildOptions options = BuildOptions.None;

		if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug || GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)
		{
			options |= BuildOptions.Development;
		}

		//streaming asset
		CheckStreamingAsset(target);

		string savePath = GetBuildPathiOS();
        string error = BuildPipeline.BuildPlayer(exportScenes, savePath, target, options).ToString();

      //  Debug.Log("error:" + error);
    }
}
