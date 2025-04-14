using System;
using System.IO;
using System.Xml.Serialization;
using UnityEditor;
using UnityEngine;
using System.Collections;
using UnityEngine.Networking;

namespace J3Tech
{
    [InitializeOnLoad]
    public class CheckVersion
    {
        public const string Version = "2.2.2";
        public const int VersionValue = 221;
        private const string VersionUrl = "http://j3studio.xyz/UnityPlugins/CodeEncipher/version.xml";
        private const int CheckPeriod = 3;
        private const string DateTimeKey = "CodeEncipherCheckVersionTime";
        
        [InitializeOnLoadMethod]
        static void CheckVersionOnStart()
        {
            long ticks;
            string time = EditorPrefs.GetString(DateTimeKey, "0");
            if (time == "0")
            {
                EditorPrefs.SetString(DateTimeKey, DateTime.Now.Ticks.ToString());
                return;
            }
            ticks = long.Parse(time);
            DateTime date = new DateTime(ticks);
            TimeSpan span=DateTime.Now - date;
            if (span.Days < CheckPeriod && span.Days >= 0)
            {
                return;
            }
            EditorCoroutine.Start(GetVersionInfo());
            EditorPrefs.SetString(DateTimeKey, DateTime.Now.Ticks.ToString());
        }

        private static IEnumerator GetVersionInfo()
        {
            UnityWebRequest www = new UnityWebRequest(VersionUrl);
            www.downloadHandler = new DownloadHandlerBuffer();
            www.SendWebRequest();
            yield return www;
            while (!www.isDone)
            {
                yield return www;
            }
            if (www.downloadedBytes <= 0)
            {
                yield break;
            }
            
            byte[] bytes = www.downloadHandler.data;
            XmlSerializer s = new XmlSerializer(typeof(VersionInfo));
            VersionInfo version;
            try
            {
                version = (VersionInfo)s.Deserialize(new MemoryStream(bytes));
            }
            catch (Exception)
            {
                yield break;
            }
            if (version.VersionNumber != Version)
            {
                UpgradeWindow.Info = version;
                EditorWindow.GetWindow<UpgradeWindow>();
            }
        }
    }

    public class VersionInfo
    {
        public string VersionNumber;
        public string UpdateInfo;
        public string Url;
    }

    public class UpgradeWindow : EditorWindow
    {
        public static VersionInfo Info;
        private static Texture _logoTexture;
        private static GUIStyle _buttonStyle;
        private Vector2 _scrollPos;
        private const string UpgradeWindowTitle = "CodeEncipher";
        private const string LogoPath = @"Assets/CodeEncipher/Textures/logo.png";

        private void OnEnable()
        {
            if (Info == null)
            {
                return;
            }
            titleContent = new GUIContent(UpgradeWindowTitle);
            int w = 400;
            int h = 400;
            position = new Rect(Screen.width - w *0.5f,Screen.height - h * 0.5f,400,400);
            minSize = new Vector2(400,345);
            maxSize = new Vector2(405, 350);
        }

        private void OnGUI()
        {
            if (Info == null)
            {
                Close();
                return;
            }
            if (_logoTexture == null)
            {
                _logoTexture = AssetDatabase.LoadAssetAtPath(LogoPath, typeof(Texture)) as Texture;
            }
            if (_buttonStyle == null)
            {
                _buttonStyle = new GUIStyle(GUI.skin.button);
                _buttonStyle.fontStyle = FontStyle.Bold;
                _buttonStyle.normal.textColor = Color.green;
            }

            GUI.DrawTexture(new Rect(0, 10, 400, 94), _logoTexture);
            GUILayout.Space(114);
            GUILayout.BeginVertical("ShurikenModuleBg",GUILayout.MinHeight(150));
            _scrollPos = GUILayout.BeginScrollView(_scrollPos, false, false);
            GUILayout.Label(Info.UpdateInfo);
            GUILayout.EndScrollView(); 
            GUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("Upgrade",_buttonStyle, GUILayout.Width(300), GUILayout.Height(40)))
            {
                Application.OpenURL(Info.Url);
                Close();
            }
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();
            GUILayout.FlexibleSpace();
        }
    }
}
