using UnityEngine;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Security.Cryptography;
using ComponentAce.Compression.Libs.zlib;

using System.Net.Mail;
using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;

using Serclimax;

public class PlatformUtils
{
#if UNITY_EDITOR
    public static string CustomUID;
#endif

    public static string GetUniqueIdentifier()
    {
#if UNITY_EDITOR
        return CustomUID != null ? CustomUID : SystemInfo.deviceUniqueIdentifier;
#else
        return SystemInfo.deviceUniqueIdentifier;
#endif
    }

    public static int GetPlatformType()
    {
        int type = 0;
#if UNITY_IPHONE
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
            UnityEngine.iOS.DeviceGeneration gen = UnityEngine.iOS.Device.generation;
            type = (int)gen;
        }
#endif
        return type;
    }

    public static string GetDeviceNameByDeviceType(int dtype)
    {
#if UNITY_IPHONE
        switch (dtype)
        {
            case (int)UnityEngine.iOS.DeviceGeneration.iPhone:
                return "iphone";
            case (int)UnityEngine.iOS.DeviceGeneration.iPhone3G:
                return "iphone3g";
            case (int)UnityEngine.iOS.DeviceGeneration.iPhone3GS:
                return "iphone3gs";
            case (int)UnityEngine.iOS.DeviceGeneration.iPhone4:
                return "iphone4";
            case (int)UnityEngine.iOS.DeviceGeneration.iPhone4S:
                return "iphone4s";
            case (int)UnityEngine.iOS.DeviceGeneration.iPhone5:
                return "iphone5";
            case (int)UnityEngine.iOS.DeviceGeneration.iPhoneUnknown:
                return "iphoneunknown";
            case (int)UnityEngine.iOS.DeviceGeneration.iPad1Gen:
                return "ipad1";
            case (int)UnityEngine.iOS.DeviceGeneration.iPad2Gen:
                return "ipad2";
            case (int)UnityEngine.iOS.DeviceGeneration.iPad3Gen:
                return "ipad3";
            case (int)UnityEngine.iOS.DeviceGeneration.iPad4Gen:
                return "ipad4";
            case (int)UnityEngine.iOS.DeviceGeneration.iPadMini1Gen:
                return "ipadmini1";
            case (int)UnityEngine.iOS.DeviceGeneration.iPadUnknown:
                return "ipadunknown";
            case (int)UnityEngine.iOS.DeviceGeneration.iPodTouch1Gen:
                return "ipodtouch1";
            case (int)UnityEngine.iOS.DeviceGeneration.iPodTouch2Gen:
                return "ipodtouch2";
            case (int)UnityEngine.iOS.DeviceGeneration.iPodTouch3Gen:
                return "ipodtouch3";
            case (int)UnityEngine.iOS.DeviceGeneration.iPodTouch4Gen:
                return "ipodtouch4";
            case (int)UnityEngine.iOS.DeviceGeneration.iPodTouch5Gen:
                return "ipodtouch5";
            case (int)UnityEngine.iOS.DeviceGeneration.iPodTouchUnknown:
                return "ipodtouchunknown";
            default:
                return "iosUnknown";
        }
#elif UNITY_ANDROID
        return "android";
#elif UNITY_EDITOR
        return "Unity Editor";
#elif UNITY_STANDALONE_WIN
        Debug.Log("Stand Alone Windows");
#else
        return "unknown";
#endif
    }

    private static string sSavePath = null;

    public static string SAVE_PATH
    {
        get
        {
            if (sSavePath == null)
                sSavePath = GetPath();
            return sSavePath;
        }
    }

    private static string GetPath()
    {
        string pathTemp = string.Empty;

        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
            //string path = Application.dataPath.Substring(0,Application.dataPath.Length - 5);
            //path = path.Substring(0,path.LastIndexOf('/'));

            //pathTemp = path + "/Documents/";
            // for iOS 8 path change
            pathTemp = Application.persistentDataPath;
        }
        else if (Application.platform == RuntimePlatform.Android)
        {
#if UNITY_ANDROID
            string path = Application.persistentDataPath;

            List<string> possiblePath = new List<string>();
            AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            string internalPath = jo.Call<AndroidJavaObject>("getFilesDir").Call<string>("getAbsolutePath");
            DebugUtils.Log("DABIAN: INTERNAL PATH : " + internalPath);

            AndroidJavaClass jcEnv = new AndroidJavaClass("android.os.Environment");
            string externalPath = jcEnv.CallStatic<AndroidJavaObject>("getExternalStorageDirectory").Call<string>("getAbsolutePath");
            DebugUtils.Log("DABIAN: EXTERNAL PATH : " + externalPath);

            //external storage
            if (externalPath != null && externalPath != string.Empty && externalPath != "")
            {
                string packageName = jo.Call<string>("getPackageName");
                possiblePath.Add(externalPath + "/Android/data/" + packageName);
                //possiblePath.Add(externalPath +"/"+packageName);
            }
            for (int i = 0; i < customSDcardPath.Length; i++)
            {
                string packageName = jo.Call<string>("getPackageName");
                possiblePath.Add(customSDcardPath[i] + "/Android/data/" + packageName);
            }

            bool suc = false;
            if (path != null && path != string.Empty && path != "")
            {
                if (Directory.Exists(path))
                {
                    pathTemp = path + "/Saves";
                    if (!Directory.Exists(pathTemp))
                    {
                        suc = TryCreatePath(pathTemp);
                        if (suc)
                        {
                            mAndroidPath = path;
                            return pathTemp;
                        }
                    }
                    else
                    {
                        mAndroidPath = path;
                        return pathTemp;
                    }
                }
            }

            if (!suc)
            {
                for (int i = 0; i < possiblePath.Count; i++)
                {
                    path = possiblePath[i];
                    if (Directory.Exists(path))
                    {
                        pathTemp = path + "/Saves";
                        if (!Directory.Exists(pathTemp))
                        {
                            suc = TryCreatePath(pathTemp);
                            if (suc)
                            {
                                mAndroidPath = path;
                                return pathTemp;
                            }
                        }
                        else
                        {
                            mAndroidPath = path;
                            return pathTemp;
                        }
                    }
                }
            }

            //internal storage
            if (!suc && Directory.Exists(internalPath))
            {
                path = internalPath;
                pathTemp = path + "/Saves";
                if (!Directory.Exists(pathTemp))
                {
                    suc = TryCreatePath(pathTemp);
                    if (suc)
                    {
                        mAndroidPath = path;
                        return pathTemp;
                    }
                }
                else
                {
                    mAndroidPath = path;
                    return pathTemp;
                }
            }
#endif
            mAndroidPath = Application.persistentDataPath;
            pathTemp = mAndroidPath + "/Saves";
        }
        else
        {
            pathTemp = Application.dataPath + "/Saves";
            if ((pathTemp.Length > 0) && (!Directory.Exists(pathTemp)))
            {
                Directory.CreateDirectory(pathTemp);
            }
        }

        return pathTemp;
    }

    static bool mAndroidPathInied = false;
    static string mAndroidPath;
    public static string GetAndroidPath()
    {
        if (!mAndroidPathInied)
        {
            GetPath();
            mAndroidPathInied = true;
            DebugUtils.Log("Android Save Path :" + mAndroidPath);
        }
        return mAndroidPath;
    }

#if UNITY_ANDROID
    private static string[] customSDcardPath = new string[]
    {
        "/storage/sdcard1",
        "/storage/sdcard2",
        "/storage/sdcard0",
        "/mnt/sdcard",
        "/mnt/sdcard2",
        "/sdcard",
    };
#endif

    static bool TryCreatePath(string path)
    {
        bool suc = false;
        try
        {
            DirectoryInfo info = Directory.CreateDirectory(path);
            suc = info != null && info.Exists;
            DebugUtils.Log("Android Path Try: " + (suc ? "SUC" : "FAIL") + "! :" + path);
        }
        catch (IOException e)
        {
            DebugUtils.Log(e.Message);
        }
        return suc;
    }

    static public void SendEmail(string elog)
    {
        MailMessage mail = new MailMessage();

        mail.From = new MailAddress("2814316019@qq.com");
        mail.To.Add("2814316019@qq.com");
        mail.Subject = "Test Mail";
        mail.Body = "wgame error report: " + '\n' +
                    "build ver: " + GameVersion.BUILD + " exe ver:" + GameVersion.EXE + '\n' +
                    "deveice:" + GUIMgr.Instance.GetDeviceName() + " systeminfo: " + GUIMgr.Instance.GetSystemInfo() + '\n' + 
                     "error :  " + elog;
        // mail.Attachments.Add(new Attachment(@"D:\video\1.jpg"));

        SmtpClient smtpServer = new SmtpClient("smtp.qq.com");
        smtpServer.Credentials = new System.Net.NetworkCredential("2814316019@qq.com", "uojibtzufguvdefd") as ICredentialsByHost;
        smtpServer.EnableSsl = true;
        ServicePointManager.ServerCertificateValidationCallback =
            delegate (object s, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
            { return true; };


        smtpServer.Send(mail);
        Debug.Log("success");
    }
}

