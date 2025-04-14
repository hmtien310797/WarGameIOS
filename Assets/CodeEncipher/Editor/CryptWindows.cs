using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;
using UnityEditor;

namespace J3Tech
{
    public class CryptWindows
    {
#if UNITY_5
#if UNITY_EDITOR_64
        [DllImport("CryptWindowsX64")]
		public static extern void SetApplicationPath(StringBuilder path);
        [DllImport("CryptWindowsX64")]
		public static extern void AddAssembly(StringBuilder filename);
        [DllImport("CryptWindowsX64")]
		public static extern void ClearAssembly();
        [DllImport("CryptWindowsX64")]
        public static extern int CryptAssembly(int version,int arch);
        [DllImport("CryptWindowsX64")]
		public static extern uint Get_Version();
#else
        [DllImport("CryptWindows")]
		public static extern void SetApplicationPath(StringBuilder path);
        [DllImport("CryptWindows")]
		public static extern void AddAssembly(StringBuilder filename);
        [DllImport("CryptWindows")]
		public static extern void ClearAssembly();
        [DllImport("CryptWindows")]
        public static extern int CryptAssembly(int version,int arch);
        [DllImport("CryptWindows")]
		public static extern uint Get_Version();
#endif
#else
        [DllImport("CodeEncipher/CryptWindows")]
        public static extern void SetApplicationPath(StringBuilder path);
        [DllImport("CodeEncipher/CryptWindows")]
        public static extern void AddAssembly(StringBuilder filename);
        [DllImport("CodeEncipher/CryptWindows")]
        public static extern void ClearAssembly();
        [DllImport("CodeEncipher/CryptWindows")]
        public static extern int CryptAssembly(int version,int arch);
        [DllImport("CodeEncipher/CryptWindows")]
        public static extern uint Get_Version();
#endif
        public static void InitializeDlls()
        {
#if UNITY_5
            PluginImporter pluginImporter = AssetImporter.GetAtPath("Assets/CodeEncipher/Plugin/CryptWindows.dll") as PluginImporter;
            if (pluginImporter != null)
            {
                pluginImporter.SetCompatibleWithEditor(true);
                pluginImporter.SaveAndReimport();
            }
            pluginImporter = AssetImporter.GetAtPath("Assets/CodeEncipher/Plugin/CryptWindowsX64.dll") as PluginImporter;
            if (pluginImporter != null)
            {
                pluginImporter.SetCompatibleWithEditor(true);
                pluginImporter.SaveAndReimport();
            }
#else
            if (!File.Exists(Application.dataPath + @"/Plugins/CodeEncipher/CryptWindows.dll"))
            {
                Utility.CheckDir(Application.dataPath, @"Plugins/CodeEncipher");
                File.Copy(Application.dataPath + @"/CodeEncipher/Plugin/CryptWindows.dll", Application.dataPath + @"/Plugins/CodeEncipher/CryptWindows.dll");
            }
#endif
        }
    }
}
