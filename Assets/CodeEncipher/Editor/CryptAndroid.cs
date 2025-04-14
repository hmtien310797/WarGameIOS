using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;
using UnityEditor;

namespace J3Tech
{
	public class CryptAndroid
	{
#if UNITY_5
#if UNITY_EDITOR_64
        [DllImport("CryptAndroidX64", CharSet = CharSet.Unicode)]
        public static extern int StartCryptAndroid(StringBuilder projPath, StringBuilder apkPath, StringBuilder jdkbin, StringBuilder aaptPath, StringBuilder keystorePath, StringBuilder storePass, StringBuilder alias, StringBuilder keyPass,int signalg, int version, int arch);
        [DllImport("CryptAndroidX64", CharSet = CharSet.Unicode)]
		public static extern void AddAssembly(StringBuilder filename);
        [DllImport("CryptAndroidX64", CharSet = CharSet.Unicode)]
		public static extern void ClearAssembly();
        [DllImport("CryptAndroidX64", CharSet = CharSet.Unicode)]
		public static extern uint Get_Version();
#else
        [DllImport("CryptAndroid", CharSet = CharSet.Unicode)]
        public static extern int StartCryptAndroid(StringBuilder projPath, StringBuilder apkPath, StringBuilder jdkbin, StringBuilder aaptPath, StringBuilder keystorePath, StringBuilder storePass, StringBuilder alias, StringBuilder keyPass,int signalg, int version, int arch);
        [DllImport("CryptAndroid", CharSet = CharSet.Unicode)]
		public static extern void AddAssembly(StringBuilder filename);
        [DllImport("CryptAndroid", CharSet = CharSet.Unicode)]
		public static extern void ClearAssembly();
        [DllImport("CryptAndroid", CharSet = CharSet.Unicode)]
		public static extern uint Get_Version();
#endif
#else
        [DllImport("CodeEncipher/CryptAndroid", CharSet = CharSet.Unicode)]
        public static extern int StartCryptAndroid(StringBuilder projPath, StringBuilder apkPath, StringBuilder jdkbin, StringBuilder aaptPath, StringBuilder keystorePath, StringBuilder storePass, StringBuilder alias, StringBuilder keyPass, int signalg, int version, int arch);
        [DllImport("CodeEncipher/CryptAndroid", CharSet = CharSet.Unicode)]
        public static extern void AddAssembly(StringBuilder filename);
        [DllImport("CodeEncipher/CryptAndroid", CharSet = CharSet.Unicode)]
        public static extern void ClearAssembly();
        [DllImport("CodeEncipher/CryptAndroid", CharSet = CharSet.Unicode)]
        public static extern uint Get_Version();
#endif

	    public static void InitializeDlls()
	    {
#if UNITY_5
            PluginImporter pluginImporter = AssetImporter.GetAtPath("Assets/CodeEncipher/Plugin/CryptAndroid.dll") as PluginImporter;
            if (pluginImporter != null)
            {
                pluginImporter.SetCompatibleWithEditor(true);
                pluginImporter.SaveAndReimport();
            }
            pluginImporter = AssetImporter.GetAtPath("Assets/CodeEncipher/Plugin/CryptAndroidX64.dll") as PluginImporter;
            if (pluginImporter != null)
            {
                pluginImporter.SetCompatibleWithEditor(true);
                pluginImporter.SaveAndReimport();
            }
#else
	        if (!File.Exists(Application.dataPath + @"/Plugins/CodeEncipher/CryptAndroid.dll"))
	        {
	            Utility.CheckDir(Application.dataPath, @"Plugins/CodeEncipher");
	            File.Copy(Application.dataPath + @"/CodeEncipher/Plugin/CryptAndroid.dll",
	                Application.dataPath + @"/Plugins/CodeEncipher/CryptAndroid.dll");
	        }
#endif
	    }
	}
}