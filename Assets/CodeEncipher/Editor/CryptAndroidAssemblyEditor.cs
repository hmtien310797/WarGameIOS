using System.Linq;
using System.Security.Cryptography;
using UnityEditor;
using UnityEngine;
using System.IO;
using System;
using System.Text;
using System.Reflection;
using ICSharpCode.SharpZipLib.Zip;

namespace J3Tech
{
    public class CryptAndroidAssemblyEditor : EditorWindow
    {
        private enum UnityVersion
        {
            Unity4 = 46,
            Unity5 = 50,
        }

        private static Texture _logoTexture;
        private const string Version = "2.2.2";
        private const int VersionValue = 221;
        private static string _projPath;

        private static bool _useCustomSetting;
        private static bool _foldout;

        private static GUIStyle _buttonStyle;
        private static string _customJdk;

        private static UnityVersion _customVersion;

        [MenuItem("Tools/J3Tech/CodeEncipher-Android")]
        static void OpenWindow()
        {
            var window = GetWindow<CryptAndroidAssemblyEditor>();
            if (_foldout)
            {
                window.maxSize = new Vector2(400, 276);
                window.minSize = new Vector2(400, 275);
            }
            else
            {
                window.maxSize = new Vector2(400, 211);
                window.minSize = new Vector2(400, 210);
            }
            window.title = "CodeEncipher";
        }

        private static void Init()
        {
            if (string.IsNullOrEmpty(_customJdk))
            {
                _customJdk = AndroidJavaTools.JavaBin;
            }

#if UNITY_4
            _customVersion = UnityVersion.Unity4;
#elif UNITY_5
            _customVersion = UnityVersion.Unity5;
#endif

            CryptAndroid.InitializeDlls();
        }

        void OnEnable()
        {
            Init();
        }

        void OnGUI()
        {
            if (_logoTexture == null)
            {
                _logoTexture = AssetDatabase.LoadAssetAtPath(@"Assets/CodeEncipher/Textures/logo.png", typeof(Texture)) as Texture;
            }
            if (_buttonStyle == null)
            {
                _buttonStyle=new GUIStyle(GUI.skin.button);
                _buttonStyle.fontStyle = FontStyle.Bold; 
            }

            GUI.DrawTexture(new Rect(0, 10, 400, 94), _logoTexture);
            GUILayout.Space(104);
            GUILayout.BeginHorizontal();
            GUILayout.Space(10);
            GUILayout.Label("CodeEncipher for Android");
            GUILayout.FlexibleSpace();
            GUILayout.Label("Version " + Version);
            GUILayout.Space(10);
            GUILayout.EndHorizontal();
            GUILayout.Space(10);

            _foldout = GUIHelper.DrawTitleFoldOut(_foldout, "Custom Settings");
            if (_foldout)
            {
                bool tempBool = EditorGUILayout.BeginToggleGroup("Use Custom Settings", _useCustomSetting);
                if (tempBool && !_useCustomSetting)
                {
                    if (string.IsNullOrEmpty(_customJdk))
                    {
                        _customJdk = AndroidJavaTools.JavaBin;
                    }
                }
                _useCustomSetting = tempBool;
                GUILayout.BeginHorizontal();
                _customJdk = EditorGUILayout.TextField("JDK", _customJdk);
                if (GUILayout.Button("..", GUILayout.Width(20f),GUILayout.Height(13)))
                {
                    string dir = EditorUtility.OpenFolderPanel("JDK", "", "");
                    if (Directory.Exists(dir))
                    {
                        _customJdk = dir;
                    }
                }
                GUILayout.EndHorizontal();
                _customVersion = (UnityVersion)EditorGUILayout.EnumPopup("Unity Version",_customVersion);
                EditorGUILayout.EndToggleGroup();

                GUILayout.Space(5);

                maxSize=new Vector2(400, 276);
                minSize = new Vector2(400, 275);               
            }
            else
            {
                maxSize = new Vector2(400, 211);
                minSize = new Vector2(400, 210);
            }

            //GUILayout.Space(10);

            if (GUILayout.Button("Build & Encrypt", _buttonStyle))
            {
                string appPath = EditorUtility.SaveFilePanel("Building Apk", "", PlayerSettings.productName, "apk");
                if (!string.IsNullOrEmpty(appPath))
                {
                    if (_projPath == null)
                    {
                        _projPath = Application.dataPath;
                        _projPath = _projPath.Remove(_projPath.Length - 6, 6);
                    }
                    Build(appPath,true);
                }
            }
            GUILayout.Space(5);
            if (GUILayout.Button("Encrypt", _buttonStyle))
            {
                if (CryptAndroid.Get_Version() != VersionValue)
                {
                    Debug.LogError("Before import the new version, please exit unity then delete all files of CodeEncipher. Don't forget to delete the dlls in plugins folder.");
                    return;
                }
                if (_projPath == null)
                {
                    _projPath = Application.dataPath;
                    _projPath = _projPath.Remove(_projPath.Length - 6, 6);
                }
                string appPath = EditorUtility.OpenFilePanel("Please select an apk file to encrypt", _projPath, "apk");
                if (!string.IsNullOrEmpty(appPath))
                {
                    Build(appPath, false);
                }
            }

            EditorUtility.ClearProgressBar();
        }

        private static void Build(string apkPath, bool prebuild)
        {
            Build(apkPath, prebuild, PlayerSettings.Android.keystorePass, PlayerSettings.Android.keyaliasPass);
        }

        private static void Build(string apkPath, bool prebuild, string keystorePass, string keyaliasPass)
        {
            if (String.IsNullOrEmpty(keystorePass) ||
                String.IsNullOrEmpty(keyaliasPass))
            {
                Debug.LogError("You must set the keystore with passsword !!");
                return;
            }
            if (_projPath == null)
            {
                _projPath = Application.dataPath;
                _projPath = _projPath.Remove(_projPath.Length - 6, 6);
            }

            int arch;
            if (PlayerSettings.Android.targetArchitectures == AndroidArchitecture.ARMv7)
            {
                arch = 0;
            }
            else if (PlayerSettings.Android.targetArchitectures == AndroidArchitecture.X86)
            {
                arch = 1;
            }
            else
            {
                arch = 2;
            }

            PlayerSettings.Android.keystorePass = keystorePass;
            PlayerSettings.Android.keyaliasPass = keyaliasPass;
            if (prebuild)
            {
                string error = null;
                try
                {
                    error =
                        BuildPipeline.BuildPlayer(
                            (from scene in EditorBuildSettings.scenes where scene.enabled select scene.path).ToArray(),
                            apkPath, BuildTarget.Android, BuildOptions.None).ToString();
                }
                catch (Exception exception)
                {
                    Debug.LogError(exception);
                    Utility.Log2File(exception);
                    return;
                }
                if (!String.IsNullOrEmpty(error))
                {
                    Debug.LogError(error);
                    Utility.Log2File(error);
                    return;
                }
            }
            else
            {
                EditorUtility.DisplayProgressBar("Please wait ....","Preprocessing.....",0.2f);
                Utility.CheckDir(_projPath, @"Temp/StagingArea");
                FileStream tempFile = File.Create(_projPath + @"Temp/StagingArea/Package_unaligned.apk");
                byte[] data=File.ReadAllBytes(apkPath);
                tempFile.Write(data,0,data.Length);
                tempFile.Flush();
                tempFile.Seek(0,SeekOrigin.Begin);
                ZipInputStream zipInputStream = new ZipInputStream(tempFile);
                ZipEntry dll = zipInputStream.GetNextEntry();
                int archFlag = -1;
                while (dll != null)
                {
                    if (dll.Name == "assets/bin/Data/Managed/Assembly-CSharp.dll")
                    {
                        byte[] buf = new byte[2048];
                        Utility.CheckDir(_projPath + @"/Temp/StagingArea", "assets/bin/Data/Managed");
                        FileStream fileStream = File.Create(_projPath + @"/Temp/StagingArea/" + dll.Name);
                        while (true)
                        {
                            int len = zipInputStream.Read(buf, 0, buf.Length);
                            if (len > 0)
                            {
                                fileStream.Write(buf, 0, len);
                            }
                            else
                            {
                                break;
                            }
                        }
                        fileStream.Flush();
                        fileStream.Close();
                        break;
                    }
                    else if (dll.Name == "lib/armeabi-v7a/libmain.so")
                    {
                        if (archFlag==-1)
                        {
                            archFlag = 0;
                        }
                        else if (archFlag == 1)
                        {
                            archFlag = 2;
                        }
                    }
                    else if (dll.Name == "lib/x86/libmain.so")
                    {
                        if (archFlag == -1)
                        {
                            archFlag = 1;
                        }
                        else if (archFlag == 0)
                        {
                            archFlag = 2;
                        }
                    }
                    dll = zipInputStream.GetNextEntry();
                }
                tempFile.Close();
                EditorUtility.ClearProgressBar();
                arch = archFlag;
            }

            bool optimized = true;

            try
            {
                Assembly asm = Assembly.LoadFile(EditorApplication.applicationContentsPath + @"/PlaybackEngines/androidplayer/UnityEditor.Android.Extensions.dll");
                Type postProcessAndroidPlayerType = asm.GetType("UnityEditor.Android.PostProcessAndroidPlayer");
                Type androidSdkToolsType = asm.GetType("UnityEditor.Android.AndroidSDKTools");

                System.Object postProcessAndroidPlayerInstance = Activator.CreateInstance(postProcessAndroidPlayerType, true);
                MethodInfo androidSdkToolsGetInstance = androidSdkToolsType.GetMethod("GetInstance");
                System.Object androidSdkToolsInstance = androidSdkToolsGetInstance.Invoke(androidSdkToolsType, new object[] { });

                MethodInfo alignPackage = postProcessAndroidPlayerType.GetMethod("AlignPackage", BindingFlags.NonPublic | BindingFlags.Instance);

                PropertyInfo aapt = androidSdkToolsType.GetProperty("AAPT");
                PropertyInfo zipAlign = androidSdkToolsType.GetProperty("ZIPALIGN");

#if UNITY_4_6 || UNITY_4_7
                const int version = 46;
#elif UNITY_5
                const int version = 50;
#else
                const int version = 0;
                Debug.Log("Unity "+Application.unityVersion+" can not be supported!");
                return;
#endif

                string jdkBinPath = _useCustomSetting ? _customJdk : AndroidJavaTools.JavaBin;
                string aaptPath = aapt.GetValue(androidSdkToolsInstance, new object[] {}) as string;
                if (String.IsNullOrEmpty(jdkBinPath) || !Directory.Exists(jdkBinPath))
                {
                    jdkBinPath = AndroidJavaTools.JavaBin;
                    if (String.IsNullOrEmpty(jdkBinPath) || !Directory.Exists(jdkBinPath))
                    {
                        Debug.LogError("Encrypt failed! The JDK path is not exists!!");
                        Utility.Log2File("Encrypt failed! The JDK path is not exists!!");
                        Utility.Log2File("JDKBIN:" + jdkBinPath);
                        return;
                    }                                      
                }
                if (!File.Exists(aaptPath))
                {
                    Debug.LogError("Encrypt failed! The file " + aaptPath + " is not exists!!");
                    Utility.Log2File("Encrypt failed! The file " + aaptPath + " is not exists!!");
                    return;
                }

                int signalg=KeyStoreUsingDsa(_projPath + @"Temp/StagingArea/Package_unaligned.apk")?1:0;
                int result=CryptAndroid.StartCryptAndroid(
                    new StringBuilder(_projPath),
                    new StringBuilder(_projPath + @"Temp/StagingArea/Package_unaligned.apk"),
                    new StringBuilder(jdkBinPath),
                    new StringBuilder(aaptPath),
                    new StringBuilder(PlayerSettings.Android.keystoreName),
                    new StringBuilder(PlayerSettings.Android.keystorePass),
                    new StringBuilder(PlayerSettings.Android.keyaliasName),
                    new StringBuilder(PlayerSettings.Android.keyaliasPass),
                    signalg,
                    ((_useCustomSetting&&!prebuild)?(int)_customVersion:version),
                    arch);
                if ( result!= 0)
                {
                    Debug.LogError("Encrypt failed! Flag=" + result);
                    Utility.Log2File("Encrypt failed! Flag=" + result);
                    return;
                }
                string zipAlignPath = zipAlign.GetValue(androidSdkToolsInstance, new object[] {}) as string;
                try
                {
                    if (!String.IsNullOrEmpty(zipAlignPath) && File.Exists(zipAlignPath))
                    {
                        FileUtil.DeleteFileOrDirectory(_projPath + @"Temp/StagingArea/Package.apk");
                        alignPackage.Invoke(postProcessAndroidPlayerInstance,
                            new object[] {_projPath + @"Temp/StagingArea"});
                    }
                    else
                    {
                        optimized = false;
                        Debug.LogWarning("Optimize will be ignored !");
                        Utility.Log2File("Optimize will be ignored ! " + zipAlignPath);
                    }
                }
                catch (Exception exception)
                {
                    optimized = false;
                    Debug.LogWarning("Cause exception ! Optimization will be ignored !");
                    Utility.Log2File("Cause exception ! Optimization will be ignored !" + exception);
                }
            }
            catch (Exception exception)
            {
                EditorUtility.ClearProgressBar();
                Debug.LogError("Encrypt failed!!");
                Utility.Log2File("Encrypt failed!!" + exception);
                return;
            }

            FileUtil.ReplaceFile(_projPath + (optimized?@"Temp/StagingArea/Package.apk":@"Temp/StagingArea/Package_unaligned.apk"), apkPath);
            Debug.Log("Encrypt succeed!");
            Utility.Log2File("Encrypt succeed!");
            apkPath = apkPath.Replace("/", @"\");
            System.Diagnostics.Process.Start("explorer.exe", Path.GetDirectoryName(apkPath));
            EditorUtility.ClearProgressBar();
        }

        private static bool KeyStoreUsingDsa(string apk)
        {
            bool result = false;
            FileStream tempFile = File.OpenRead(apk);
            ZipInputStream zipInputStream = new ZipInputStream(tempFile);
            ZipEntry entry = zipInputStream.GetNextEntry();
            while (entry != null)
            {
                if ((entry.Name.EndsWith(".DSA") || entry.Name.EndsWith(".dsa")) && entry.Name.Contains("META-INF"))
                {
                    result = true;
                }
                entry = zipInputStream.GetNextEntry();
            }
            tempFile.Close();
            return result;
        }

        /// <summary>
        /// Build by command line. 
        /// UnityPath -batchmode -quit -projectPath YourProjectPath -executeMethod J3Tech.CryptAndroidAssemblyEditor.CommandBuild ApkPath KeystorePassword AliasPassword
        /// For example: "D:/Program Files/Unity/Editor/Unity.exe" -batchmode -quit -projectPath "E:/Project/Test" -executeMethod J3Tech.CryptAndroidAssemblyEditor.CommandBuild E:/Test.apk 123456 123456
        /// </summary>
        public static void CommandBuild()
        {
            string[] parameters=System.Environment.GetCommandLineArgs();
            Build(parameters[7], true, parameters[8], parameters[9]);
        }

		public static void CommandEncrypt()
		{
			_useCustomSetting = true;
			_customJdk = System.Environment.GetEnvironmentVariable("JAVA_HOME")+"\\bin";
			string[] parameters=System.Environment.GetCommandLineArgs();

            Debug.Log("parameters len:" + parameters.Length);

            for (int i = 0; i < parameters.Length; i++)
            {
                Debug.Log(">>> " + parameters[i]);
            }

            //string version = parameters[10];
            //int versionInt = int.Parse(version);

            //if (versionInt == (int)UnityVersion.Unity4)
            //	_customVersion = UnityVersion.Unity4;
            //else
            _customVersion = UnityVersion.Unity5;

            //Console.WriteLine("custom version: "+ _customVersion.ToString());
            Build(parameters[7], false, parameters[8], parameters[9]);
		}
	}
}
