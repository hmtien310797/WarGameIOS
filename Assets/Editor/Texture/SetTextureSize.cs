using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;
using System;

public class SetTextureSize : EditorWindow
{

    public static int CompressQuality = 50;

    public static float halveRate = 0.5f;

	[MenuItem("Tools/Compressed/SetTextureSize")]
    public static void SearchTexture()
    {
        UnityEngine.Object[] objects = Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.Assets); //获取选择文件夹
        for (int i = 0; i < objects.Length; i++)
        {
            string dirPath = AssetDatabase.GetAssetPath(objects[i]).Replace("\\", "/");
            if (!Directory.Exists(dirPath))
            {
                EditorUtility.DisplayDialog("错误", "选择正确文件夹！", "好的");
                continue;
            }
            SetTexture(dirPath);
        }
    }

    private static void SetTexture(string dirPath)
    {
        string[] files = Directory.GetFiles(dirPath, "*.*", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++)
        {
            string filePath = files[i];
            filePath = filePath.Replace("\\", "/");

            if (filePath.EndsWith(".png") || filePath.EndsWith(".jpg") ||  filePath.EndsWith(".tga") || filePath.EndsWith(".psd"))
            {
                //筛选出png和jpg图片
                EditorUtility.DisplayProgressBar("处理中>>>", filePath, (float)i / (float)files.Length);

                TextureImporter textureImporter = AssetImporter.GetAtPath(filePath) as TextureImporter;
                if (textureImporter == null)
                    continue;

                //判断图片有无alpha通道，有默认格式设置成：RGBA16；无默认格式设置成：RGB16
                //textureImporter.textureFormat = TextureImporterFormat.AutomaticTruecolor;
                AssetDatabase.ImportAsset(filePath);

                Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(filePath);
                int textureSize = Math.Max(texture.height, texture.width)/2;

                TextureImporterFormat androidTextureFormat;
                TextureImporterFormat iphoneTextureFormat;
                TextureImporterFormat defaultTextureFormat = TextureImporterFormat.RGB16;

                if (texture.format == TextureFormat.RGB24 || texture.format == TextureFormat.ETC_RGB4 || texture.format == TextureFormat.ETC2_RGB
                    || texture.format == TextureFormat.PVRTC_RGB2 || texture.format == TextureFormat.PVRTC_RGB4)
                {
                    //no alpha
                    //defaultTextureFormat = TextureImporterFormat.RGB16;
                    bool isN = false;
                    for (int x = 1; x < 21; x++)
                    {
                        int pow = (int)Math.Pow(2, x);
                        if (texture.height == pow && texture.width == pow)
                        {
                            isN = true;
                        }
                    }

                    if (isN)
                    {
                        androidTextureFormat = TextureImporterFormat.ETC_RGB4;
                        iphoneTextureFormat = TextureImporterFormat.PVRTC_RGB4;
                    }
                    else
                    {
                        androidTextureFormat = TextureImporterFormat.RGB16;
                        iphoneTextureFormat = TextureImporterFormat.RGB16;
                    }
                }
                else
                {
                    //defaultTextureFormat = TextureImporterFormat.RGBA16;
                    bool isN = false;
                    for (int x = 1; x < 21; x++)
                    {
                        int pow = (int)Math.Pow(2, x);
                        if (texture.height == pow && texture.width == pow)
                        {
                            isN = true;
                        }
                    }
                    if (isN)
                    {
                        androidTextureFormat = TextureImporterFormat.ETC2_RGBA8;
                        iphoneTextureFormat = TextureImporterFormat.PVRTC_RGBA4;
                    }
                    else
                    {
                        androidTextureFormat = TextureImporterFormat.RGBA16;
                        iphoneTextureFormat = TextureImporterFormat.RGBA16;
                    }
                }

                TextureImporterSettings settings = new TextureImporterSettings();
                textureImporter.ReadTextureSettings(settings);
                if (textureImporter.textureType != TextureImporterType.Sprite)
                {
                    textureImporter.textureType = TextureImporterType.Default;
                    settings.mipmapEnabled = false;
                    settings.readable = false;
                    settings.aniso = 0;
                }
                //int defaultMaxTextureSize = settings.maxTextureSize;
                //settings.textureFormat = defaultTextureFormat;
                //settings.maxTextureSize = GetValidSize(textureSize);
                textureImporter.SetPlatformTextureSettings("Standalone", GetValidSize(textureSize), defaultTextureFormat, CompressQuality, false);
                textureImporter.SetPlatformTextureSettings("Android", GetValidSize(textureSize), androidTextureFormat, CompressQuality, false);
                textureImporter.SetPlatformTextureSettings("iPhone", GetValidSize(textureSize), iphoneTextureFormat, CompressQuality, false);
                textureImporter.ReadTextureSettings(settings);
                settings.mipmapEnabled = false;
                settings.readable = false;
                textureImporter.SetTextureSettings(settings);
                AssetDatabase.SaveAssets();
                DoAssetReimport(filePath, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
            }
        }

        EditorUtility.ClearProgressBar();
        EditorUtility.DisplayDialog("成功", "处理完成！", "好的");
    }

    private static int GetValidSize(int size)
    {
        int result = 0;
        if (size <= 48)
        {
            result = 32;
        }
        else if (size <= 96)
        {
            result = 64;
        }
        else if (size <= 192)
        {
            result = 128;
        }
        else if (size <= 384)
        {
            result = 256;
        }
        else if (size <= 768)
        {
            result = 512;
        }
        else if (size <= 1536)
        {
            result = 1024;
        }
        else if (size <= 3072)
        {
            result = 2048;
        }

        return result;
    }

    public static void DoAssetReimport(string path, ImportAssetOptions options)
    {
        try
        {
            AssetDatabase.StartAssetEditing();
            AssetDatabase.ImportAsset(path, options);
        }
        finally
        {
            AssetDatabase.StopAssetEditing();
        }
    }

}
