using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class UITextureChangeToolIos : Editor
{
    static string APPLICATION_PATH = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf('/') + 1);

	[MenuItem("Assets/UI贴图RGBA分离/创建IosAlpha通道分离的ATLAS")]
    public static void ChangeTextures()
    {
        Object[] arr = Selection.GetFiltered(typeof(Object), SelectionMode.TopLevel);
        string selectedPath = APPLICATION_PATH + AssetDatabase.GetAssetPath(arr[0]);
        ChangeTextures(selectedPath);
    }

    public static void ChangeTextures(string selectedPath, bool bTip = true)
    {
        List<GameObject> atlass = new List<GameObject>();
        GetAssets(selectedPath, atlass);
        float total = atlass.Count;
        float current = 0;
        for (int i = 0; i < atlass.Count; i++)
        {
            current++;
            EditorUtility.DisplayProgressBar("RGBA分离工具", string.Format("总共{0}个Atlas，正在处理第{1}个...", total, current), current / total);
            Material spriteMaterial = atlass[i].GetComponent<UIAtlas>().spriteMaterial;
            if (spriteMaterial.shader.name.Contains("Particles/"))
            {
                continue;
            }
            string name = atlass[i].gameObject.name;
            string path = AssetDatabase.GetAssetPath(atlass[i]);
            path = path.Substring(0, path.LastIndexOf('/') + 1);
            string sourcePath = path + name + ".png";

            TextureImporter ti = AssetImporter.GetAtPath(sourcePath) as TextureImporter;
            ti.isReadable = true;
            AssetDatabase.ImportAsset(sourcePath, ImportAssetOptions.ImportRecursive);

            Texture2D source = AssetDatabase.LoadAssetAtPath<Texture2D>(sourcePath);
            Color[] colors = source.GetPixels();
			if (source.width != source.height) {
				continue;
			}
            Texture2D rgbT = new Texture2D(source.width, source.height, TextureFormat.RGB24, false);
            rgbT.SetPixels(colors);
            rgbT.Apply();
            string rgbPath = path + name + "_rgb.png";
            File.WriteAllBytes(rgbPath, rgbT.EncodeToPNG());
            AssetDatabase.ImportAsset(rgbPath, ImportAssetOptions.ImportRecursive);

            ti = AssetImporter.GetAtPath(rgbPath) as TextureImporter;
            ti.mipmapEnabled = false;
			ti.isReadable = false;
			ti.wrapMode = TextureWrapMode.Clamp;
			ti.filterMode = FilterMode.Trilinear;
			ti.SetPlatformTextureSettings ("iPhone", source.width, TextureImporterFormat.PVRTC_RGB4, 50, false);
            AssetDatabase.ImportAsset(rgbPath, ImportAssetOptions.ImportRecursive);

            Texture2D alphaT = new Texture2D(source.width, source.height, TextureFormat.RGB24, false);
            Color[] alphas = new Color[colors.Length];
            for (int j = 0; j < colors.Length; j++)
            {
                alphas[j].r = colors[j].a;
                alphas[j].g = colors[j].a;
                alphas[j].b = colors[j].a;
            }
            alphaT.SetPixels(alphas);
            alphaT.Apply();
            string alphaPath = path + name + "_a.png";
            File.WriteAllBytes(alphaPath, alphaT.EncodeToPNG());
            AssetDatabase.ImportAsset(alphaPath, ImportAssetOptions.ImportRecursive);

            ti = AssetImporter.GetAtPath(alphaPath) as TextureImporter;
            ti.mipmapEnabled = false;
			ti.isReadable = false;
			ti.wrapMode = TextureWrapMode.Clamp;
			ti.filterMode = FilterMode.Trilinear;
			ti.SetPlatformTextureSettings ("iPhone", source.width, TextureImporterFormat.PVRTC_RGB4, 50, false);
            AssetDatabase.ImportAsset(alphaPath, ImportAssetOptions.ImportRecursive);
            
            spriteMaterial.shader = Shader.Find("Unlit/Transparent Colored ETC1");
            spriteMaterial.SetTexture("_MainTex", AssetDatabase.LoadAssetAtPath<Texture>(rgbPath));
            spriteMaterial.SetTexture("_MainTex_A", AssetDatabase.LoadAssetAtPath<Texture>(alphaPath));
        }
        EditorUtility.ClearProgressBar();
        if (bTip)
        {
            EditorUtility.DisplayDialog("提示", "已处理完成目录下所有Atlas图片~XD", "确定");
        }
    }

    public static void Recover()
    {
        Object[] arr = Selection.GetFiltered(typeof(Object), SelectionMode.TopLevel);
        string selectedPath = APPLICATION_PATH + AssetDatabase.GetAssetPath(arr[0]);
        Recover(selectedPath);
    }

    public static void Recover(string selectedPath, bool bTip = true)
    {
        List<GameObject> atlass = new List<GameObject>();
        GetAssets(selectedPath, atlass);
        for (int i = 0; i < atlass.Count; i++)
        {
            Material spriteMaterial = atlass[i].GetComponent<UIAtlas>().spriteMaterial;
            if (spriteMaterial.shader.name.Contains("Particles/"))
            {
                continue;
            }
            string name = atlass[i].gameObject.name;
            string path = AssetDatabase.GetAssetPath(atlass[i]);
            path = path.Substring(0, path.LastIndexOf('/') + 1);
            string sourcePath = path + name + ".png";
            spriteMaterial.shader = Shader.Find("Unlit/Transparent Colored");
            spriteMaterial.SetTexture("_MainTex", AssetDatabase.LoadAssetAtPath<Texture>(sourcePath));
            string rgbPath = path + name + "_rgb.png";
            string alphaPath = path + name + "_a.png";
            //File.Delete(rgbPath);
            //File.Delete(alphaPath);

            AssetDatabase.DeleteAsset(rgbPath);
            AssetDatabase.DeleteAsset(alphaPath);
        }
        if (bTip)
        {
            EditorUtility.DisplayDialog("提示", "已恢复NGUI标准贴图", "确定");
        }        
    }

    static void GetAssets(string pathname, List<GameObject> assets)
    {
        string[] subFiles = Directory.GetFiles(pathname);
        foreach (string subFile in subFiles)
        {
            UIAtlas t = AssetDatabase.LoadAssetAtPath<UIAtlas>(subFile.Replace(APPLICATION_PATH, ""));
            if (t)
            {
                if (!t.name.Contains("fonts") && t != null)
                {
                    assets.Add(t.gameObject);
                }
            }
        }

        string[] subDirs = Directory.GetDirectories(pathname);
        foreach (string subDir in subDirs)
        {
            GetAssets(subDir, assets);
        }
    }

    static void ClearPlayerPrefs()
    {
        PlayerPrefs.DeleteAll();
        PlayerPrefs.Save();
    }
}
