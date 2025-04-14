using System.Runtime.Remoting.Messaging;
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Collections.Generic;

namespace J3Tech
{
	public class CryptWindowsAssemblyEditor : EditorWindow
	{
		private class Dll
		{
			public bool WillCrypt;
			public string Path;
		}
		private static List<Dll> _dlls;
		private static string _appPath="";
		private static string _managedPath="";
		private static DirectoryInfo _dirInfo;
		private static Texture _logoTexture;
		private static Vector2 _scrollPos=new Vector2(0,0);
	    private static GUIStyle _style;
		private const string Version="2.2.2";
        private const int VersionValue = 221;

	    private static TargetArchitecture _architecture = TargetArchitecture.X86;
        public enum TargetArchitecture
        {
            X86 = 0,
            X64 = 1
        }

        [MenuItem("Tools/J3Tech/CodeEncipher-Windows")]
        static void OpenWindow() 
		{
	        var winrdow = GetWindow<CryptWindowsAssemblyEditor>();
            winrdow.maxSize = _appPath.Length > 0 ? new Vector2(400, 500) : new Vector2(400, 210);
            winrdow.minSize = new Vector2(400, 200);
            winrdow.title = "CodeEncipher";
	    }

	    private void OnEnable()
	    {
            CryptWindows.InitializeDlls();
	    }

	    void OnGUI () 
		{
		    if (_style == null)
		    {
                _style=new GUIStyle(GUI.skin.toggle)
                {
                    normal = {textColor = Color.green},
                    richText = true,
                    active = {textColor = Color.green},
                    onNormal = {textColor = Color.green}
                };
		    }

	        if (_logoTexture == null)
	        {
	            _logoTexture = AssetDatabase.LoadAssetAtPath("Assets/CodeEncipher/Textures/logo.png", typeof (Texture)) as Texture;
	        }

	        GUI.DrawTexture(new Rect(0,10,400,94),_logoTexture);
			GUILayout.Space(104);
            GUILayout.BeginHorizontal();
            GUILayout.Space(10);
            GUILayout.Label("CodeEncipher for Windows");
            GUILayout.FlexibleSpace();
            GUILayout.Label("Version " + Version);
            GUILayout.Space(10);
            GUILayout.EndHorizontal();
			GUILayout.Space(10);

			GUILayout.BeginHorizontal();
            GUILayout.Space(10);
            GUILayout.Label("AppFile(*.exe):", GUILayout.Width(90));
			_appPath=GUILayout.TextField(_appPath,GUILayout.Height(20f));
		    
			if(GUILayout.Button("...",GUILayout.Width(25)))
			{
				_appPath= EditorUtility.OpenFilePanel("AppFile","","exe");
				if(File.Exists(_appPath))
				{
					var filename=Path.GetFileNameWithoutExtension(_appPath);
					var directory=Path.GetDirectoryName(_appPath);
				    if (directory != null) if (filename != null) _managedPath=Path.Combine(directory,filename);
				    _managedPath+="_Data";
					_managedPath=Path.Combine(_managedPath,"Managed");
					_dirInfo=new DirectoryInfo(_managedPath);
					_dlls=new List<Dll>();
					
					try
					{
						foreach(var file in _dirInfo.GetFiles("*.dll"))
						{
							var tempDll=new Dll {WillCrypt = false,Path = file.FullName};
						    _dlls.Add(tempDll);
						}
					}
					catch
					{
						ShowNotification(new GUIContent("Not found Dlls!"));
						_appPath="";
					}
				    maxSize=new Vector2(400f,500f);
				    minSize=new Vector2(400f,350f);
				    Repaint();
				}
				else
				{
			        maxSize=new Vector2(400f,210f);
					minSize=new Vector2(400f,200);
					Repaint();
				}
			}

            GUILayout.Space(10);
			GUILayout.EndHorizontal();
			GUILayout.Space(5);
            GUILayout.BeginHorizontal();
            GUILayout.Space(10);
            GUILayout.Label("Architecture:",GUILayout.Width(90));
            _architecture = (TargetArchitecture)EditorGUILayout.EnumPopup(_architecture);
            GUILayout.Space(10);
            GUILayout.EndHorizontal();
            GUILayout.Space(10);

			if(File.Exists(_appPath))
			{
				if(_dlls!=null)
				{
					GUILayout.Label("Please select assembly:");
					GUILayout.Space(5);
					_scrollPos=GUILayout.BeginScrollView(_scrollPos,true,true);
					foreach(var dll in _dlls)
					{
                        dll.WillCrypt = GUILayout.Toggle(dll.WillCrypt, Path.GetFileName(dll.Path),_style);		    
					}
					GUILayout.EndScrollView(); 
				}
				GUILayout.Space(5);
				GUILayout.BeginHorizontal();
				GUILayout.FlexibleSpace();
				if(GUILayout.Button("Encrypt",GUILayout.Width(300),GUILayout.Height(40)))
				{
                    List<string> dlls = new List<string>();
				    if (_dlls != null && _dlls.Count > 0)
				    {
				        foreach (var dll in _dlls)
				        {
                            if (dll.WillCrypt) dlls.Add(dll.Path);
				        }
				    }
                    ShowNotification(Encrypt(_appPath, dlls.ToArray())
                        ? new GUIContent("Done!")
                        : new GUIContent("Failed!"));
				}
				GUILayout.FlexibleSpace();
				GUILayout.EndHorizontal();
				GUILayout.Space(10);
			}
		}	    

	    private static bool Encrypt(string targetExe,params string[] dllNames)
	    {
            if (CryptWindows.Get_Version() != VersionValue)
            {
                Debug.LogError("Before import the new version, please exit unity then delete all files of CodeEncipher. Don't forget to delete the dlls in plugins folder.");
                return false;
            }
            CryptWindows.SetApplicationPath(new StringBuilder(targetExe));
            CryptWindows.ClearAssembly();
            foreach (var dll in dllNames)
            {
                CryptWindows.AddAssembly(new StringBuilder(dll));
            }
#if UNITY_4_6 || UNITY_4_7
            const int version = 46;
#elif UNITY_5
            const int version = 50;
#else
            int version = 0;
            Debug.Log("Unity "+Application.unityVersion+" can not be supported!");
            return false;
#endif
            return CryptWindows.CryptAssembly(version,(int)_architecture) == 1;
	    }

        /// <summary>
        /// Encrypt by command line. 
        /// UnityPath -batchmode -quit -projectPath YourProjectPath -executeMethod J3Tech.CryptWindowsAssemblyEditor.CommandBuild TargetExePath architecture DllName1,DllName2.....
        /// For example: "D:/Program Files/Unity/Editor/Unity.exe" -batchmode -quit -projectPath "E:/Project/Test" -executeMethod J3Tech.CryptWindowsAssemblyEditor.CommandBuild E:/Test.exe x86 Assembly-CSharp.dll OtherLib.dll
        /// </summary>
        public static void CommandEncrypt()
        {
            string[] parameters = System.Environment.GetCommandLineArgs();
            _appPath = parameters[7];
            if (parameters[8] == "x86" || parameters[8] == "X86")
            {
                _architecture = TargetArchitecture.X86;
            }
            else
            {
                _architecture = TargetArchitecture.X64;
            }
            var filename = Path.GetFileNameWithoutExtension(_appPath);
            var directory = Path.GetDirectoryName(_appPath);
            if (directory != null) if (filename != null) _managedPath = Path.Combine(directory, filename);
            _managedPath += "_Data";
            _managedPath = Path.Combine(_managedPath, "Managed");
            string[] dlls = new string[parameters.Length - 9];
            for (int n = 0, i = 9, imax = parameters.Length; i < imax; ++i, ++n)
            {
                dlls[n] = Path.Combine(_managedPath, parameters[i]);
            }
            Encrypt(_appPath, dlls);
        }
	}
}