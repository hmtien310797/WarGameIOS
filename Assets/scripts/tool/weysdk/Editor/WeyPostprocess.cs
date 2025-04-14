using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using System.Collections.Generic;
using System.IO;

#if UNITY_IPHONE


//using UnityEditor.iOS.Xcode;
using UnityEditor.iOS.Xcode.Custom;

public static class XcodeProjectMod 
{

    internal static void CopyAndReplaceDirectory(string srcPath, string dstPath)
    {
        if (Directory.Exists(dstPath))
            Directory.Delete(dstPath);
        if (File.Exists(dstPath))
            File.Delete(dstPath);

        Directory.CreateDirectory(dstPath);

        foreach (var file in Directory.GetFiles(srcPath))
            File.Copy(file, Path.Combine(dstPath, Path.GetFileName(file)));

        foreach (var dir in Directory.GetDirectories(srcPath))
            CopyAndReplaceDirectory(dir, Path.Combine(dstPath, Path.GetFileName(dir)));
    }

	static void CopyAndAdd (string pathToBuiltProject, PBXProject proj, string target, string srcPath, string dstPath)
	{
		CopyAndReplaceDirectory (srcPath, Path.Combine (pathToBuiltProject, dstPath));
		proj.AddFileToBuild (target, proj.AddFile (dstPath, dstPath, PBXSourceTree.Source));
	}

    static void CopyAndAddFile(string pathToBuiltProject, PBXProject proj, string target, string srcPath, string dstPath, string fileName)
    {
        string newPath = Path.Combine (pathToBuiltProject, dstPath);

        if (!Directory.Exists(newPath))
            Directory.CreateDirectory(newPath);

        File.Copy(Path.Combine(srcPath, fileName), Path.Combine(newPath, fileName));
        proj.AddFileToBuild (target, proj.AddFile (Path.Combine(dstPath, fileName), Path.Combine(dstPath, fileName), PBXSourceTree.Source));
    }

    static void AddDynamicFrameworks(PBXProject proj, string target)
    {
        const string defaultLocationInProj = "Frameworks";
        const string coreFrameworkName = "LBSDK.framework";

        string relativeCoreFrameworkPath = Path.Combine(defaultLocationInProj, coreFrameworkName);
        proj.AddDynamicFrameworkToProject(target, relativeCoreFrameworkPath);

        proj.SetBuildProperty(target, "LD_RUNPATH_SEARCH_PATHS", "$(inherited) @executable_path/Frameworks");
        Debug.Log("Dynamic Frameworks added to Embedded binaries.");
    }

    static void AddDynamicFrameworksOfficial(PBXProject proj, string target)
    {
        const string defaultLocationInProj = "Frameworks";
        const string coreFrameworkName = "AFNetworking.framework";

        string relativeCoreFrameworkPath = Path.Combine(defaultLocationInProj, coreFrameworkName);
        proj.AddDynamicFrameworkToProject(target, relativeCoreFrameworkPath);
     
        relativeCoreFrameworkPath = Path.Combine(defaultLocationInProj, "YYCache.framework");
        proj.AddDynamicFrameworkToProject(target, relativeCoreFrameworkPath);

        proj.SetBuildProperty(target, "LD_RUNPATH_SEARCH_PATHS", "$(inherited) @executable_path/Frameworks");
        Debug.Log("Dynamic Frameworks added to Embedded binaries.");
    }


    [PostProcessBuild(100)]
    public static void OnPostProcessBuild(BuildTarget buildTarget, string pathToBuiltProject)
    {
        if (buildTarget != BuildTarget.iOS)
        {
            Debug.LogWarning("Target is not iPhone. XCodePostProcess will not run");
            return;
        }

        string fullPath = Path.GetFullPath(pathToBuiltProject);
        string projPath = PBXProject.GetPBXProjectPath(pathToBuiltProject);
        PBXProject proj = new PBXProject();

        proj.ReadFromString(File.ReadAllText(projPath));
        string target = proj.TargetGuidByName("Unity-iPhone");

        //add dep library
        proj.AddFrameworkToProject(target, "Security.framework", false);
        proj.AddFrameworkToProject(target, "CoreTelephony.framework", false);
        proj.AddFrameworkToProject(target, "CoreAudio.framework", false);
        proj.AddFrameworkToProject(target, "AdSupport.framework", false);
        proj.SetBuildProperty(target, "ENABLE_BITCODE", "NO");

        proj.AddFileToBuild(target, proj.AddFile("usr/lib/libstdc++.6.0.9.tbd", "libstdc++.6.0.9.tbd", PBXSourceTree.Sdk));
        proj.AddFileToBuild(target, proj.AddFile("usr/lib/libz.tbd", "libz.tbd", PBXSourceTree.Sdk));


        string srcPath = "";
        string dstPath = "";
        string fileName = "";
        if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_self_ios)
        {


            //bugly

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "BuglyBridge.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/Bugly");

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "libBuglyBridge.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            //srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            //dstPath = "Bugly/Bugly.framework";
            //CopyAndAdd (pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            dstPath = "Frameworks/Bugly.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk.framework";
            dstPath = "Frameworks/weysdk.framework";

        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_taptap)
        {
            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_tap.framework";
            dstPath = "Frameworks/weysdk_tap.framework";
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_efun)
        {
            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_efun.framework";
            dstPath = "Frameworks/weysdk_efun.framework";
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_india)
        {
            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_india.framework";
            dstPath = "Frameworks/weysdk_india.framework";
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_official)
        {
            proj.AddFrameworkToProject(target, "UserNotifications.framework", false);
            proj.AddFrameworkToProject(target, "libsqlite3.0.tbd", false);
            proj.AddFrameworkToProject(target, "libc++.tbd", false);
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            //bugly
            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "BuglyBridge.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/Bugly");

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "libBuglyBridge.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            dstPath = "Frameworks/Bugly.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            //wx
            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "WechatAuthSDK.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/WeChatSDK");


            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "WXApi.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "WXApiObject.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "libWeChatSDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);


            //Libraries
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/eJHv");

            //string target_name = PBXProject.GetUnityTargetName ();

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/AFNetworking.framework";
            dstPath = "Frameworks/AFNetworking.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/YYCache.framework";
            dstPath = "Frameworks/YYCache.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            AddDynamicFrameworksOfficial(proj, target);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/scan_ui.bundle";
            dstPath = "Frameworks/scan_ui.bundle";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/MZYW/iOS/eJHv";
            dstPath = "eJHv";
            fileName = "libXG-SDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_OFFICIAL.framework";
            dstPath = "Frameworks/weysdk_OFFICIAL.framework";
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_kr_digiSky || WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_tw_digiSky)
        {
            proj.AddFrameworkToProject(target, "UserNotifications.framework", false);
            proj.AddFrameworkToProject(target, "libsqlite3.0.tbd", false);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS";
            dstPath = "";
            fileName = "XGPush.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/sanalyze.framework";
            dstPath = "Frameworks/sanalyze.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/AppsFlyerLib.framework";
            dstPath = "Frameworks/AppsFlyerLib.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/FBSDKShareKit.framework";
            dstPath = "Frameworks/FBSDKShareKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/FBSDKCoreKit.framework";
            dstPath = "Frameworks/FBSDKCoreKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/FBSDKLoginKit.framework";
            dstPath = "Frameworks/FBSDKLoginKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/Bolts.framework";
            dstPath = "Frameworks/Bolts.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS";
            dstPath = "";
            fileName = "libXG-SDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            string target_name = PBXProject.GetUnityTargetName();
            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS";
            dstPath = "Unity-iPhone";
            fileName = "kr.entitlements";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "CODE_SIGN_ENTITLEMENTS", target_name + "/kr.entitlements");

            proj.AddFrameworkToProject(target, "StoreKit.framework", false);
            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_PPGame.framework";
            dstPath = "Frameworks/weysdk_PPGame.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);
            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/usersdk_resources.bundle";
            dstPath = "usersdk_resources.bundle";

        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi && AndroidBuild.plat == "mzyw")
        {

            proj.AddFrameworkToProject(target, "UserNotifications.framework", false);
            proj.AddFrameworkToProject(target, "libsqlite3.0.tbd", false);
            proj.AddFrameworkToProject(target, "libc++.tbd", false);
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            //bugly
            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "BuglyBridge.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/Bugly");

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "libBuglyBridge.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            dstPath = "Frameworks/Bugly.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            //Libraries
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/eJHv");

            //string target_name = PBXProject.GetUnityTargetName ();
            srcPath = fullPath + "/../../tools/externalSDK/MZYW/iOS/eJHv";
            dstPath = "eJHv";
            fileName = "kr.entitlements";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "CODE_SIGN_ENTITLEMENTS", "eJHv/kr.entitlements");

            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_MZYW.framework";
            dstPath = "Frameworks/weysdk_MZYW.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            srcPath = fullPath + "/../../tools/weysdk/iOS/out/LBSDK.framework";
            dstPath = "Frameworks/LBSDK.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            srcPath = fullPath + "/../../tools/externalSDK/MZYW/iOS/eJHv";
            dstPath = "eJHv";
            fileName = "libXG-SDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/MZYW/iOS/eJHv";
            dstPath = "eJHv";
            fileName = "libCAMOTESDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/MZYW/iOS/eJHv/CAMOTESDK_resources.bundle";
            dstPath = "eJHv/CAMOTESDK_resources.bundle";
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi && AndroidBuild.plat == "mzyw_zhqx")
        {

            proj.AddFrameworkToProject(target, "UserNotifications.framework", false);
            proj.AddFrameworkToProject(target, "libsqlite3.0.tbd", false);
            proj.AddFrameworkToProject(target, "libc++.tbd", false);
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            //bugly
            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "BuglyBridge.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/Bugly");

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "libBuglyBridge.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            dstPath = "Frameworks/Bugly.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            //Libraries
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/ENISSDK");

            //string target_name = PBXProject.GetUnityTargetName ();
            /*   srcPath = fullPath + "/../../tools/externalSDK/ZHSJ/iOS/SLGSDK";
               dstPath = "SLGSDK";
               fileName = "kr.entitlements";
               CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
               proj.AddBuildProperty(target, "CODE_SIGN_ENTITLEMENTS", "SLGSDK/kr.entitlements"); */

            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_ZHQX.framework";
            dstPath = "Frameworks/weysdk_ZHQX.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            srcPath = fullPath + "/../../tools/weysdk/iOS/out/LBSDK.framework";
            dstPath = "Frameworks/LBSDK.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            srcPath = fullPath + "/../../tools/externalSDK/ZHQX/iOS";
            dstPath = "ENISSDK";
            fileName = "libENISSDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            srcPath = fullPath + "/../../tools/externalSDK/MZYW/iOS/eJHv";
            dstPath = "ENISSDK";
            fileName = "libXG-SDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            //  srcPath = fullPath + "/../../tools/externalSDK/Icon/iOS/zhsj/AppIcon.appiconset";
            //  dstPath = "Unity-iPhone/Images.xcassets/AppIcon.appiconset";
            //  CopyAndReplaceDirectory(srcPath, Path.Combine(pathToBuiltProject, dstPath));

            srcPath = fullPath + "/../../tools/externalSDK/ZHQX/iOS/ENISSDK_resources.bundle";
            dstPath = "ENISSDK/ENISSDK_resources.bundle";

        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi && AndroidBuild.plat == "mzyw_zhsj")
        {

            proj.AddFrameworkToProject(target, "UserNotifications.framework", false);
            proj.AddFrameworkToProject(target, "libsqlite3.0.tbd", false);
            proj.AddFrameworkToProject(target, "libc++.tbd", false);
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");

            //bugly
            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "BuglyBridge.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/Bugly");

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "libBuglyBridge.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            dstPath = "Frameworks/Bugly.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            //Libraries
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/SLGSDK");

            //string target_name = PBXProject.GetUnityTargetName ();
            /*   srcPath = fullPath + "/../../tools/externalSDK/ZHSJ/iOS/SLGSDK";
               dstPath = "SLGSDK";
               fileName = "kr.entitlements";
               CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
               proj.AddBuildProperty(target, "CODE_SIGN_ENTITLEMENTS", "SLGSDK/kr.entitlements"); */

            srcPath = fullPath + "/../../tools/weysdk/iOS/out/weysdk_ZHSJ.framework";
            dstPath = "Frameworks/weysdk_ZHSJ.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            srcPath = fullPath + "/../../tools/weysdk/iOS/out/LBSDK.framework";
            dstPath = "Frameworks/LBSDK.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            srcPath = fullPath + "/../../tools/externalSDK/ZHSJ/iOS/SLGSDK";
            dstPath = "SLGSDK";
            fileName = "libSLGSDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            srcPath = fullPath + "/../../tools/externalSDK/MZYW/iOS/eJHv";
            dstPath = "SLGSDK";
            fileName = "libXG-SDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            //  srcPath = fullPath + "/../../tools/externalSDK/Icon/iOS/zhsj/AppIcon.appiconset";
            //  dstPath = "Unity-iPhone/Images.xcassets/AppIcon.appiconset";
            //  CopyAndReplaceDirectory(srcPath, Path.Combine(pathToBuiltProject, dstPath));

            srcPath = fullPath + "/../../tools/externalSDK/ZHSJ/iOS/SLGSDK/SLGSDK_resources.bundle";
            dstPath = "SLGSDK/SLGSDK_resources.bundle";

        }
        CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

        if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_efun)
        {
            //############# appsflyer ##################
            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/adjust";
         //   dstPath = "EfunSDK/ThirdSDK/adjust";
        //    fileName = "version.txt";
        //    CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

       //     srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/adjust/Adjust-4.12.3/AdjustSdk.framework";
       //     dstPath = "Frameworks/AdjustSdk.framework";
       //     CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/AppsFlyerLib.framework";
            dstPath = "Frameworks/AppsFlyerLib.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            /*	srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerCrossPromotionHelper.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerLinkGenerator.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerShareInviteHelper.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerTracker.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "libAppsFlyerLib.a";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName); */
            //##########################################

            //bugly
            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "BuglyBridge.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/Bugly");

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "libBuglyBridge.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            dstPath = "Frameworks/Bugly.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            //############# facebook ###################
            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook";
            dstPath = "EfunSDK/ThirdSDK/facebook";
            fileName = "version.txt";
            //   CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/Bolts.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/Bolts.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKCoreKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKCoreKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKLoginKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKLoginKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKMessengerShareKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKMessengerShareKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKShareKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKShareKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);
            //##########################################

            //############# firebase ###################
            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase";
            dstPath = "EfunSDK/ThirdSDK/firebase";
            fileName = "GoogleService-Info.plist";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase";
            dstPath = "EfunSDK/ThirdSDK/firebase";
            fileName = "FirebaseSDK_Version.txt";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase";
            dstPath = "EfunSDK/ThirdSDK/firebase";
            fileName = "Firebase.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseAnalytics.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseAnalytics.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCore.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCore.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCoreDiagnostics.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCoreDiagnostics.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseInstanceID.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseInstanceID.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseNanoPB.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseNanoPB.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/GoogleToolboxForMac.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/GoogleToolboxForMac.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/nanopb.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/nanopb.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Common/GTMSessionFetcher.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Common/GTMSessionFetcher.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Common/Protobuf.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Common/Protobuf.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Crashlytics/Crashlytics.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Crashlytics/Crashlytics.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Crashlytics/Fabric.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Crashlytics/Fabric.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Messaging/FirebaseMessaging.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Messaging/FirebaseMessaging.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/EfunSDK";
            dstPath = "EfunSDK/ThirdSDK/firebase/EfunSDK";
            fileName = "EFUNSDK_Firebase_20180315_142003_v1.2.2.a";
       //     CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            //##########################################

        //    srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/EfunSEA";
        //    dstPath = "EfunSDK/EfunSEA";
       //     fileName = "EfunSEA_v3.1.3.a";
       //     CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

       //     srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/EfunPhotos";
       //     dstPath = "EfunSDK/EfunPhotos";
       //     fileName = "EfunPhotos_v1.0.0.a";
      //      CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

     //       srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/EfunResources.bundle";
     //       dstPath = "EfunSDK/EfunResources.bundle";
     //       CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

     //       srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK";
     //       dstPath = "EfunSDK";
     //       fileName = "EfunSDKEntitlements.entitlements";
     //       CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_india)
        {
            //############# appsflyer ##################
        //    srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/adjust";
        //    dstPath = "EfunSDK/ThirdSDK/adjust";
        //    fileName = "version.txt";
        //    CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

       //     srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/adjust/Adjust-4.12.3/AdjustSdk.framework";
       //     dstPath = "Frameworks/AdjustSdk.framework";
       //     CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/PPGAME/iOS/AppsFlyerLib.framework";
            dstPath = "Frameworks/AppsFlyerLib.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            /*	srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerCrossPromotionHelper.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerLinkGenerator.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerShareInviteHelper.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "AppsFlyerTracker.h";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

                srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                dstPath = "EfunSDK/ThirdSDK/appsflyer/AF-iOS-SDK-v4.8.0";
                fileName = "libAppsFlyerLib.a";
                CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName); */
            //##########################################

            //bugly
            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "BuglyBridge.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/Bugly");

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglyBridge/iOS/BuglyBridge";
            dstPath = "Bugly";
            fileName = "libBuglyBridge.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Bugly/BuglySDK/iOS/Bugly.framework";
            dstPath = "Frameworks/Bugly.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);


            //############# facebook ###################
            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook";
            dstPath = "EfunSDK/ThirdSDK/facebook";
            fileName = "version.txt";
            //   CopyAndAddFile (pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/Bolts.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/Bolts.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKCoreKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKCoreKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKLoginKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKLoginKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKMessengerShareKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKMessengerShareKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/facebook/Facebook/FBSDKShareKit.framework";
            dstPath = "EfunSDK/ThirdSDK/facebook/Facebook/FBSDKShareKit.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);
            //##########################################

            //############# firebase ###################
            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase";
            dstPath = "EfunSDK/ThirdSDK/firebase";
            fileName = "GoogleService-Info.plist";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase";
            dstPath = "EfunSDK/ThirdSDK/firebase";
            fileName = "FirebaseSDK_Version.txt";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase";
            dstPath = "EfunSDK/ThirdSDK/firebase";
            fileName = "Firebase.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseAnalytics.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseAnalytics.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCore.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCore.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCoreDiagnostics.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseCoreDiagnostics.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseInstanceID.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseInstanceID.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/FirebaseNanoPB.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/FirebaseNanoPB.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/GoogleToolboxForMac.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/GoogleToolboxForMac.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Analytics/nanopb.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Analytics/nanopb.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Common/GTMSessionFetcher.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Common/GTMSessionFetcher.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Common/Protobuf.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Common/Protobuf.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Crashlytics/Crashlytics.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Crashlytics/Crashlytics.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Crashlytics/Fabric.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Crashlytics/Fabric.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/Messaging/FirebaseMessaging.framework";
            dstPath = "EfunSDK/ThirdSDK/firebase/Messaging/FirebaseMessaging.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/ThirdSDK/firebase/EfunSDK";
            dstPath = "EfunSDK/ThirdSDK/firebase/EfunSDK";
            fileName = "EFUNSDK_Firebase_20180315_142003_v1.2.2.a";
         //   CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            //##########################################

        //    srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/EfunSEA";
        //    dstPath = "EfunSDK/EfunSEA";
        //    fileName = "EfunSEA_v3.1.3.a";
        //    CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

       //     srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/EfunPhotos";
       //     dstPath = "EfunSDK/EfunPhotos";
       //     fileName = "EfunPhotos_v1.0.0.a";
       //     CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

       //     srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK/EfunResources.bundle";
       //     dstPath = "EfunSDK/EfunResources.bundle";
       //     CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

      //      srcPath = fullPath + "/../../tools/externalSDK/Efun/iOS/EfunSDK";
      //      dstPath = "EfunSDK";
      //      fileName = "EfunSDKEntitlements.entitlements";
      //      CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);


            //wx
            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "WechatAuthSDK.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/WeChatSDK");


            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "WXApi.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "WXApiObject.h";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/WeChatSDK1.8.4_NoPay";
            dstPath = "WeChatSDK";
            fileName = "libWeChatSDK.a";
            CopyAndAddFile(pathToBuiltProject, proj, target, srcPath, dstPath, fileName);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/AFNetworking.framework";
            dstPath = "Frameworks/AFNetworking.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/YYCache.framework";
            dstPath = "Frameworks/YYCache.framework";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);
            AddDynamicFrameworksOfficial(proj, target);

            srcPath = fullPath + "/../../tools/externalSDK/Official_iOS/scan_ui.bundle";
            dstPath = "Frameworks/scan_ui.bundle";
            CopyAndAdd(pathToBuiltProject, proj, target, srcPath, dstPath);
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi)
        {
            AddDynamicFrameworks(proj, target);
        }

        XClass UnityAppController = new XClass(fullPath + "/Classes/UnityAppController.mm");

        if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_self_ios)
        {
            proj.AddFrameworkToProject(target, "libc++.tbd", false);

            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk/WSdkPlatformiOS.h>");

            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"100\" appView:_unityView rootController:_rootController];");
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_taptap)
        {
            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_tap/WSdkPlatformiOS.h>");

            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"102\" appView:_unityView rootController:_rootController];");
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_kr_digiSky || WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_tw_digiSky)
        {
            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_PPGame/WSdkPlatformiOS.h>");
            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"104\" appView:_unityView rootController:_rootController];");
            UnityAppController.WriteBelow("fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler\n{",
                "[[WSdkPlatformiOS getInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];");
            UnityAppController.WriteBelow("didFailToRegisterForRemoteNotificationsWithError:(NSError)error\n{",
                "[[WSdkPlatformiOS getInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];");

        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi && AndroidBuild.plat == "mzyw_zhsj")
        {
            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_ZHSJ/WSdkPlatformiOS.h>");

            UnityAppController.WriteBelow("#import <weysdk_ZHSJ/WSdkPlatformiOS.h>",
                "#import <LBSDK/LBInit.h>");

            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"107\" appView:_unityView rootController:_rootController];");
            UnityAppController.WriteBelow("fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler\n{",
                "[[WSdkPlatformiOS getInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];");
            UnityAppController.WriteBelow("didFailToRegisterForRemoteNotificationsWithError:(NSError)error\n{",
                "[[WSdkPlatformiOS getInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];");
            UnityAppController.WriteBelow("::printf(\"-> applicationDidFinishLaunching()\\n\");",
                "[[LBInit sharedInstance] LBSDKShouldInitWithLaunchOptions:launchOptions];");
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_official)
        {

             proj.AddFrameworkToProject(target, "StoreKit.framework", false);


            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_OFFICIAL/WSdkPlatformiOS.h>");



            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"110\" appView:_unityView rootController:_rootController];");
            UnityAppController.WriteBelow("fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler\n{",
                "[[WSdkPlatformiOS getInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];");
            UnityAppController.WriteBelow("didFailToRegisterForRemoteNotificationsWithError:(NSError)error\n{",
                "[[WSdkPlatformiOS getInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];");
   
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi && AndroidBuild.plat == "mzyw_zhqx")
        {
            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_ZHQX/WSdkPlatformiOS.h>");

            UnityAppController.WriteBelow("#import <weysdk_ZHQX/WSdkPlatformiOS.h>",
                "#import <LBSDK/LBInit.h>");

            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"107\" appView:_unityView rootController:_rootController];");
            UnityAppController.WriteBelow("fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler\n{",
                "[[WSdkPlatformiOS getInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];");
            UnityAppController.WriteBelow("didFailToRegisterForRemoteNotificationsWithError:(NSError)error\n{",
                "[[WSdkPlatformiOS getInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];");
            UnityAppController.WriteBelow("::printf(\"-> applicationDidFinishLaunching()\\n\");",
                "[[LBInit sharedInstance] LBSDKShouldInitWithLaunchOptions:launchOptions];");
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi && AndroidBuild.plat == "mzyw")
        {
            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_MZYW/WSdkPlatformiOS.h>");

            UnityAppController.WriteBelow("#import <weysdk_MZYW/WSdkPlatformiOS.h>",
                "#import <LBSDK/LBInit.h>");

            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"107\" appView:_unityView rootController:_rootController];");
            UnityAppController.WriteBelow("fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler\n{",
                "[[WSdkPlatformiOS getInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];");
            UnityAppController.WriteBelow("didFailToRegisterForRemoteNotificationsWithError:(NSError)error\n{",
                "[[WSdkPlatformiOS getInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];");
            UnityAppController.WriteBelow("::printf(\"-> applicationDidFinishLaunching()\\n\");",
                "[[LBInit sharedInstance] LBSDKShouldInitWithLaunchOptions:launchOptions];");
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_efun)
        {
            proj.AddFrameworkToProject(target, "AdSupport.framework", true);
            proj.AddFrameworkToProject(target, "Social.framework", true);
            proj.AddFrameworkToProject(target, "Photos.framework", true);
            proj.AddFrameworkToProject(target, "SafariServices.framework", true);
            proj.AddFrameworkToProject(target, "UserNotifications.framework", true);
            proj.AddFrameworkToProject(target, "GameKit.framework", true);

            proj.AddFrameworkToProject(target, "JavaScriptCore.framework", false);
            proj.AddFrameworkToProject(target, "WebKit.framework", false);
            proj.AddFrameworkToProject(target, "iAd.framework", false);
            proj.AddFrameworkToProject(target, "AssetsLibrary.framework", false);
            proj.AddFrameworkToProject(target, "AddressBook.framework", false);
            proj.AddFrameworkToProject(target, "CoreData.framework", false);
            proj.AddFrameworkToProject(target, "EventKitUI.framework", false);
            proj.AddFrameworkToProject(target, "AVFoundation.framework", false);
            proj.AddFrameworkToProject(target, "MessageUI.framework", false);
            proj.AddFrameworkToProject(target, "EventKit.framework", false);
            proj.AddFrameworkToProject(target, "libz.tbd", false);
            proj.AddFrameworkToProject(target, "libc++.tbd", false);
            proj.AddFrameworkToProject(target, "AudioToolbox.framework", false);
            proj.AddFrameworkToProject(target, "AVFoundation.framework", false);
            proj.AddFrameworkToProject(target, "CoreMotion.framework", false);
            proj.AddFrameworkToProject(target, "Security.framework", false);
            proj.AddFrameworkToProject(target, "Accounts.framework", false);//
            proj.AddFrameworkToProject(target, "CoreTelephony.framework", false);
            proj.AddFrameworkToProject(target, "QuartzCore.framework", false);
            proj.AddFrameworkToProject(target, "StoreKit.framework", false);
            proj.AddFrameworkToProject(target, "ImageIO.framework", false);
            proj.AddFrameworkToProject(target, "MobileCoreServices.framework", false);


            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-lsqlite3.0");
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");
        //    proj.SetBuildProperty(target, "CODE_SIGN_ENTITLEMENTS", "EfunSDK/EfunSDKEntitlements.entitlements");

            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_efun/WSdkPlatformiOS.h>");

            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"103\" appView:_unityView rootController:_rootController];");
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_india)
        {
            proj.AddFrameworkToProject(target, "AdSupport.framework", true);
            proj.AddFrameworkToProject(target, "Social.framework", true);
            proj.AddFrameworkToProject(target, "Photos.framework", true);
            proj.AddFrameworkToProject(target, "SafariServices.framework", true);
            proj.AddFrameworkToProject(target, "UserNotifications.framework", true);
            proj.AddFrameworkToProject(target, "GameKit.framework", true);

            proj.AddFrameworkToProject(target, "JavaScriptCore.framework", false);
            proj.AddFrameworkToProject(target, "WebKit.framework", false);
            proj.AddFrameworkToProject(target, "iAd.framework", false);
            proj.AddFrameworkToProject(target, "AssetsLibrary.framework", false);
            proj.AddFrameworkToProject(target, "AddressBook.framework", false);
            proj.AddFrameworkToProject(target, "CoreData.framework", false);
            proj.AddFrameworkToProject(target, "EventKitUI.framework", false);
            proj.AddFrameworkToProject(target, "AVFoundation.framework", false);
            proj.AddFrameworkToProject(target, "MessageUI.framework", false);
            proj.AddFrameworkToProject(target, "EventKit.framework", false);
            proj.AddFrameworkToProject(target, "libz.tbd", false);
            proj.AddFrameworkToProject(target, "libc++.tbd", false);
            proj.AddFrameworkToProject(target, "AudioToolbox.framework", false);
            proj.AddFrameworkToProject(target, "AVFoundation.framework", false);
            proj.AddFrameworkToProject(target, "CoreMotion.framework", false);
            proj.AddFrameworkToProject(target, "Security.framework", false);
            proj.AddFrameworkToProject(target, "Accounts.framework", false);//
            proj.AddFrameworkToProject(target, "CoreTelephony.framework", false);
            proj.AddFrameworkToProject(target, "QuartzCore.framework", false);
            proj.AddFrameworkToProject(target, "StoreKit.framework", false);
            proj.AddFrameworkToProject(target, "ImageIO.framework", false);
            proj.AddFrameworkToProject(target, "MobileCoreServices.framework", false);


            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-lsqlite3.0");
            proj.AddBuildProperty(target, "OTHER_LDFLAGS", "-ObjC");
         //   proj.SetBuildProperty(target, "CODE_SIGN_ENTITLEMENTS", "EfunSDK/EfunSDKEntitlements.entitlements");

            UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"",
                "#import <weysdk_india/WSdkPlatformiOS.h>");

            UnityAppController.WriteBelow("_unityView\t\t= [self createUnityView];",
                "[[WSdkPlatformiOS getInstance] WSdkInitPlatformSpecial:@\"111\" appView:_unityView rootController:_rootController];");

            UnityAppController.WriteBelow("::printf(\"-> applicationDidEnterBackground()\\n\");\n}",
                 "- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler { return [[WSdkPlatformiOS getInstance]  application: application continueUserActivity:userActivity restorationHandler:restorationHandler];}");
        }
        UnityAppController.WriteBelow("[self preStartUnity];",
                                      "[[WSdkPlatformiOS getInstance] application:application WSdkFinishLaunch:launchOptions];");

        UnityAppController.WriteBelow("UnitySendDeviceToken(deviceToken);",
                                      "[[WSdkPlatformiOS getInstance] WSdkSetPushNotifyDeviceToken:deviceToken];");

        UnityAppController.WriteBelow("didReceiveRemoteNotification:(NSDictionary*)userInfo\n{",
                                      "[[WSdkPlatformiOS getInstance] WSdkProcessPushNotification:userInfo];");

        UnityAppController.WriteBelow("_didResignActive = false;",
                                      "[[WSdkPlatformiOS getInstance] WSdkBecomeActive:application];");

        UnityAppController.WriteBelow("AppController_SendNotificationWithArg(kUnityOnOpenURL, notifData);",
                                      "[[WSdkPlatformiOS getInstance] application:application WSdkHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation];");

        proj.SetBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(inherited)");
        proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/Frameworks");
        if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_efun)
        {
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/facebook/Facebook");
            //	proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/adjust/Adjust-4.12.3");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Common");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Analytics");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Crashlytics");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Messaging");

            //Libraries
        //    proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/EfunSDK/ThirdSDK/adjust/Adjust-4.12.3");
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/EfunSDK/ThirdSDK/firebase/EfunSDK");
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_india)
        {
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/facebook/Facebook");
            //	proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/adjust/Adjust-4.12.3");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Common");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Analytics");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Crashlytics");
            proj.AddBuildProperty(target, "FRAMEWORK_SEARCH_PATHS", "$(PROJECT_DIR)/EfunSDK/ThirdSDK/firebase/Messaging");

            //Libraries
        //    proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/EfunSDK/ThirdSDK/adjust/Adjust-4.12.3");
            proj.AddBuildProperty(target, "LIBRARY_SEARCH_PATHS", "$(SRCROOT)/EfunSDK/ThirdSDK/firebase/EfunSDK");
        }

        //var codesign = Debug.isDebugBuild ? CODE_SIGN_DEVELOPER : CODE_SIGN_DISTRIBUTION;
        //var provision = Debug.isDebugBuild ? PROVISIONING_DEVELOPER : PROVISIONING_DISTRIBUTION;
        //proj.SetBuildProperty (target, "CODE_SIGN_IDENTITY", codesign);
        //proj.SetBuildProperty (target, "PROVISIONING_PROFILE", provision);
        proj.SetBuildProperty(target, "ENABLE_BITCODE", "NO");

        File.WriteAllText(projPath, proj.WriteToString());


        if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_efun)
        {
            //plist
            string pListPath = pathToBuiltProject + "/Info.plist";
            PlistDocument plist = new PlistDocument();
            plist.ReadFromString(File.ReadAllText(pListPath));

            //Get root
            PlistElementDict rootDict = plist.root;

            var UIBackgroundModes = rootDict.CreateArray("UIBackgroundModes");
            UIBackgroundModes.AddString("remote-notification");
            UIBackgroundModes.AddString("fetch");

            //URL schemes
            var urlTypeArray = rootDict.CreateArray("CFBundleURLTypes");
            var urlTypeDict = urlTypeArray.AddDict();
            urlTypeDict.SetString("CFBundleURLName", "");
            var urlScheme = urlTypeDict.CreateArray("CFBundleURLSchemes");
            urlScheme.AddString("fb1345813482183118");
            urlScheme.AddString("sekdzzios");
            urlScheme.AddString("prefs");
            //            urlScheme.AddString("com.googleusercontent.apps.159569805374-q8tr9qk743sgf2rj78lco81l0mbltjab");
            //            urlScheme.AddString("fb1345813482183118");

            //Fabric
            var urlFabricDict = rootDict.CreateDict("Fabric");
            urlFabricDict.SetString("APIKey", "C7a8dmUrDHNHRLFMACn3pgPCt");
            var urlKitsArray = urlFabricDict.CreateArray("Kits");
            var urlKitsDict = urlKitsArray.AddDict();
            var urlKitInfoDict = urlKitsDict.CreateDict("KitInfo");
            urlKitInfoDict.SetString("consumerKey", "C7a8dmUrDHNHRLFMACn3pgPCt");
            urlKitInfoDict.SetString("consumerSecret", "mH3y5CIgTCOCsQXSCUc9812hVR2lwjSOzklRtCKBKMkcBdafKr");
            urlKitsDict.SetString("KitName", "Twitter");

			// Set encryption usage boolean
            string encryptKey = "ITSAppUsesNonExemptEncryption";
            rootDict.SetBoolean(encryptKey, false);

            // remove exit on suspend if it exists.
            string exitsOnSuspendKey = "UIApplicationExitsOnSuspend";
            if (rootDict.values.ContainsKey(exitsOnSuspendKey))
            {
                rootDict.values.Remove(exitsOnSuspendKey);
            }
			
            //fb
            rootDict.SetString("FacebookAppID", "1345813482183118");
            rootDict.SetString("FacebookDisplayName", "war in pocket");

            //            rootDict.SetString("LSApplicationCategoryType", "");
            //            rootDict.SetString("LSRequiresIPhoneOS", "true");
            rootDict.SetString("NSCameraUsageDescription", "The game requires your permission for Camera access");
            rootDict.SetString("NSPhotoLibraryUsageDescription", "The game requires your permission for Album access");
            rootDict.SetString("NSMicrophoneUsageDescription", "The game needs your permission to access the microphone");
			rootDict.SetString("NSLocationWhenInUseUsageDescription", "The game needs your permission to access the geographical location");
            rootDict.SetString("NSPhotoLibraryAddUsageDescription", "The game needs your permission to access album reading and writing");


            var urlQueSchemArray = rootDict.CreateArray("LSApplicationQueriesSchemes");
            urlQueSchemArray.AddString("fun-cp");
            urlQueSchemArray.AddString("fun-pm");
            urlQueSchemArray.AddString("fun-it");
            urlQueSchemArray.AddString("fbapi");
            urlQueSchemArray.AddString("fb-messenger-api");
            urlQueSchemArray.AddString("fbauth2");
            urlQueSchemArray.AddString("fbshareextension");
            urlQueSchemArray.AddString("vk");
            urlQueSchemArray.AddString("vk-share");
            urlQueSchemArray.AddString("vkauthorize");
            urlQueSchemArray.AddString("whatsapp");
            urlQueSchemArray.AddString("line");
            urlQueSchemArray.AddString("instagram");
            urlQueSchemArray.AddString("twitter");
            urlQueSchemArray.AddString("twapios");
            //			urlQueSchemArray.AddString("kakaoxxxxxxxxxxxxx");
            urlQueSchemArray.AddString("kakaokompassauth");
            urlQueSchemArray.AddString("storykompassauth");
            urlQueSchemArray.AddString("kakaolink");
            urlQueSchemArray.AddString("kakaotalk-4.5.0");
            urlQueSchemArray.AddString("kakaostory-2.9.0");

            File.WriteAllText(pListPath, plist.WriteToString());
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_india)
        {
            //plist
            string pListPath = pathToBuiltProject + "/Info.plist";
            PlistDocument plist = new PlistDocument();
            plist.ReadFromString(File.ReadAllText(pListPath));

            //Get root
            PlistElementDict rootDict = plist.root;

            var UIBackgroundModes = rootDict.CreateArray("UIBackgroundModes");
            UIBackgroundModes.AddString("remote-notification");
            UIBackgroundModes.AddString("fetch");

            //URL schemes
            var urlTypeArray = rootDict.CreateArray("CFBundleURLTypes");
            var urlTypeDict = urlTypeArray.AddDict();
            urlTypeDict.SetString("CFBundleURLName", "");
            var urlScheme = urlTypeDict.CreateArray("CFBundleURLSchemes");
            urlScheme.AddString("fb2119003618395064");
            urlScheme.AddString("sekdzzios");
            urlScheme.AddString("prefs");

          
            var cfBundleURLTypesDict = urlTypeArray.AddDict();
            var cfBundleURLSchemes = cfBundleURLTypesDict.CreateArray("CFBundleURLSchemes");
            cfBundleURLTypesDict.SetString("CFBundleURLName", "wechat");
            cfBundleURLSchemes.AddString("wx2b761fa59b12d8d0");


            //            urlScheme.AddString("com.googleusercontent.apps.159569805374-q8tr9qk743sgf2rj78lco81l0mbltjab");
            //            urlScheme.AddString("fb1345813482183118");

            //Fabric
            var urlFabricDict = rootDict.CreateDict("Fabric");
            urlFabricDict.SetString("APIKey", "C7a8dmUrDHNHRLFMACn3pgPCt");
            var urlKitsArray = urlFabricDict.CreateArray("Kits");
            var urlKitsDict = urlKitsArray.AddDict();
            var urlKitInfoDict = urlKitsDict.CreateDict("KitInfo");
            urlKitInfoDict.SetString("consumerKey", "C7a8dmUrDHNHRLFMACn3pgPCt");
            urlKitInfoDict.SetString("consumerSecret", "mH3y5CIgTCOCsQXSCUc9812hVR2lwjSOzklRtCKBKMkcBdafKr");
            urlKitsDict.SetString("KitName", "Twitter");

            // Set encryption usage boolean
            string encryptKey = "ITSAppUsesNonExemptEncryption";
            rootDict.SetBoolean(encryptKey, false);

            // remove exit on suspend if it exists.
            string exitsOnSuspendKey = "UIApplicationExitsOnSuspend";
            if (rootDict.values.ContainsKey(exitsOnSuspendKey))
            {
                rootDict.values.Remove(exitsOnSuspendKey);
            }

            //fb
            rootDict.SetString("FacebookAppID", "2119003618395064");
            rootDict.SetString("FacebookDisplayName", "War In Pocket（Elite）");

            //            rootDict.SetString("LSApplicationCategoryType", "");
            //            rootDict.SetString("LSRequiresIPhoneOS", "true");
            rootDict.SetString("NSCameraUsageDescription", "The game requires your permission for Camera access");
            rootDict.SetString("NSPhotoLibraryUsageDescription", "The game requires your permission for Album access");
            rootDict.SetString("NSMicrophoneUsageDescription", "The game needs your permission to access the microphone");
            rootDict.SetString("NSLocationWhenInUseUsageDescription", "The game needs your permission to access the geographical location");
            rootDict.SetString("NSPhotoLibraryAddUsageDescription", "The game needs your permission to access album reading and writing");


            var urlQueSchemArray = rootDict.CreateArray("LSApplicationQueriesSchemes");


            urlQueSchemArray.AddString("mqqapi");
            urlQueSchemArray.AddString("weixin");
            urlQueSchemArray.AddString("wechat");
            urlQueSchemArray.AddString("weixinULAPI");
            urlQueSchemArray.AddString("fun-cp");
            urlQueSchemArray.AddString("fun-pm");
            urlQueSchemArray.AddString("fun-it");
            urlQueSchemArray.AddString("fbapi");
            urlQueSchemArray.AddString("fb-messenger-api");
            urlQueSchemArray.AddString("fbauth2");
            urlQueSchemArray.AddString("fbshareextension");
            urlQueSchemArray.AddString("vk");
            urlQueSchemArray.AddString("vk-share");
            urlQueSchemArray.AddString("vkauthorize");
            urlQueSchemArray.AddString("whatsapp");
            urlQueSchemArray.AddString("line");
            urlQueSchemArray.AddString("instagram");
            urlQueSchemArray.AddString("twitter");
            urlQueSchemArray.AddString("twapios");
            //			urlQueSchemArray.AddString("kakaoxxxxxxxxxxxxx");
            urlQueSchemArray.AddString("kakaokompassauth");
            urlQueSchemArray.AddString("storykompassauth");
            urlQueSchemArray.AddString("kakaolink");
            urlQueSchemArray.AddString("kakaotalk-4.5.0");
            urlQueSchemArray.AddString("kakaostory-2.9.0");

            File.WriteAllText(pListPath, plist.WriteToString());
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_kr_digiSky || WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_tw_digiSky)
        {
            //plist
            string pListPath = pathToBuiltProject + "/Info.plist";
            PlistDocument plist = new PlistDocument();
            plist.ReadFromString(File.ReadAllText(pListPath));

            //Get root
            PlistElementDict rootDict = plist.root;
            //rootDict.SetString("LoginType", (int)WSdkManager.mLoginChannel);

            rootDict.SetString("CFBundleDevelopmentRegion", "en");
            var UIBackgroundModes = rootDict.CreateArray("UIBackgroundModes");
            UIBackgroundModes.AddString("audio");
            UIBackgroundModes.AddString("remote-notification");

            var lsApplicationqueriesSchemes = rootDict.CreateArray("LSApplicationQueriesSchemes");
            lsApplicationqueriesSchemes.AddString("fbapi");
            lsApplicationqueriesSchemes.AddString("fb-messenger-share-api");
            lsApplicationqueriesSchemes.AddString("fbauth2");
            lsApplicationqueriesSchemes.AddString("fbshareextension");

            var cfBundleURLTypes = rootDict.CreateArray("CFBundleURLTypes");
            var cfBundleURLTypesDict = cfBundleURLTypes.AddDict();
            var cfBundleURLSchemes = cfBundleURLTypesDict.CreateArray("CFBundleURLSchemes");
            if (PlayerSettings.iPhoneBundleIdentifier == "com.digitalsky.wip.sea")
            {
                cfBundleURLSchemes.AddString("fb611020235907606");
                rootDict.SetString("FacebookAppID", "611020235907606");
                rootDict.SetString("FacebookDisplayName", "我的战争");
            }
            else if (PlayerSettings.iPhoneBundleIdentifier == "com.digitalsky.wip.kr")
            {
                cfBundleURLSchemes.AddString("fb559519731085413");
                rootDict.SetString("FacebookAppID", "559519731085413");
                rootDict.SetString("FacebookDisplayName", "나의전쟁");
            }

            File.WriteAllText(pListPath, plist.WriteToString());

            proj.ReadFromString(File.ReadAllText(projPath));
            string[] lines = proj.WriteToString().Split('\n');
            List<string> newLines = new List<string>();
            string line = "";
            for (int i = 0; i < lines.Length; i++)
            {
                line = lines[i];
                newLines.Add(line);
                if (line.IndexOf(proj.TargetGuidByName("Unity-iPhone") + " = {") > -1)
                {
                    //newLines.Add(line);
                    newLines.Add("DevelopmentTeam = C44Z4LV3PN;");
                }
                else if (line.IndexOf("SystemCapabilities = {") > -1)
                {
                    //newLines.Add(line);
                    newLines.Add("com.apple.Push = {");
                    newLines.Add("enabled = 1;");
                    newLines.Add("};");
                    newLines.Add("com.apple.BackgroundModes = {");
                    newLines.Add("enabled = 1;");
                    newLines.Add("};");
                }
            }

            proj.ReadFromString(string.Join("\n", newLines.ToArray()));
            proj.WriteToFile(projPath);
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_muzhi)
        {
            //plist
            string pListPath = pathToBuiltProject + "/Info.plist";
            PlistDocument plist = new PlistDocument();
            plist.ReadFromString(File.ReadAllText(pListPath));

            //Get root
            PlistElementDict rootDict = plist.root;
            //rootDict.SetString("LoginType", (int)WSdkManager.mLoginChannel);
            var LSApplicationQueriesSchemes = rootDict.CreateArray("LSApplicationQueriesSchemes");
            LSApplicationQueriesSchemes.AddString("mqqapi");
            rootDict.SetString("NSMicrophoneUsageDescription", "App需要你的同意，才能访问麦克风");
            rootDict.SetString("NSPhotoLibraryAddUsageDescription", "App需要你的同意，才能访问相册读写");
            rootDict.SetString("NSPhotoLibraryUsageDescription", "App需要你的同意，才能访问相册");
            rootDict.SetString("NSCameraUsageDescription", "App需要你的同意，才能访问相机");
            rootDict.SetString("NSLocationWhenInUseUsageDescription", "App需要你的同意，才能访问地理位置");

            rootDict.SetInteger("LEBIAN_APPID", 67724);
            rootDict.SetString("LEBIAN_META", "LEBIAN_TEST");
            rootDict.SetString("LEBIAN_SECID", "m87ob4lr.c");
            rootDict.SetInteger("LEBIAN_VERCODE", 1);

            var UIBackgroundModes = rootDict.CreateArray("UIBackgroundModes");
            UIBackgroundModes.AddString("remote-notification");
            UIBackgroundModes.AddString("fetch");

            File.WriteAllText(pListPath, plist.WriteToString());
        }
        else if (WSdkManager.mChannel == ProtoMsg.AccType.AccType_ios_official)
        {
            string pListPath = pathToBuiltProject + "/Info.plist";
            PlistDocument plist = new PlistDocument();
            plist.ReadFromString(File.ReadAllText(pListPath));

            //Get root
            PlistElementDict rootDict = plist.root;
            //rootDict.SetString("LoginType", (int)WSdkManager.mLoginChannel);
            var LSApplicationQueriesSchemes = rootDict.CreateArray("LSApplicationQueriesSchemes");
            LSApplicationQueriesSchemes.AddString("mqqapi");
            LSApplicationQueriesSchemes.AddString("weixin");
            LSApplicationQueriesSchemes.AddString("wechat");
            LSApplicationQueriesSchemes.AddString("weixinULAPI");
            // Set encryption usage boolean
            string encryptKey = "ITSAppUsesNonExemptEncryption";
            rootDict.SetBoolean(encryptKey, false);

            // remove exit on suspend if it exists.
            string exitsOnSuspendKey = "UIApplicationExitsOnSuspend";
            if (rootDict.values.ContainsKey(exitsOnSuspendKey))
            {
                rootDict.values.Remove(exitsOnSuspendKey);
            }

            rootDict.SetString("NSMicrophoneUsageDescription", "App需要你的同意，才能访问麦克风");
            rootDict.SetString("NSPhotoLibraryAddUsageDescription", "App需要你的同意，才能访问相册读写");
            rootDict.SetString("NSPhotoLibraryUsageDescription", "App需要你的同意，才能访问相册");
            rootDict.SetString("NSCameraUsageDescription", "App需要你的同意，才能访问相机");
            rootDict.SetString("NSLocationWhenInUseUsageDescription", "App需要你的同意，才能访问地理位置");

            rootDict.SetInteger("LEBIAN_APPID", 67724);
            rootDict.SetString("LEBIAN_META", "LEBIAN_TEST");
            rootDict.SetString("LEBIAN_SECID", "m87ob4lr.c");
            rootDict.SetInteger("LEBIAN_VERCODE", 1);

            var UIBackgroundModes = rootDict.CreateArray("UIBackgroundModes");
            UIBackgroundModes.AddString("remote-notification");
            UIBackgroundModes.AddString("fetch");

            var cfBundleURLTypes = rootDict.CreateArray("CFBundleURLTypes");
            var cfBundleURLTypesDict = cfBundleURLTypes.AddDict();
            var cfBundleURLSchemes = cfBundleURLTypesDict.CreateArray("CFBundleURLSchemes");
			cfBundleURLTypesDict.SetString("CFBundleURLName","wechat");
            cfBundleURLSchemes.AddString("wx2b761fa59b12d8d0");
               



            File.WriteAllText(pListPath, plist.WriteToString());
        }
    }

}
#endif
