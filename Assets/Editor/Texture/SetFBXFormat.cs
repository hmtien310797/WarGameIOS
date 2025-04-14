using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;
using System;

public class SetFBXFormat : EditorWindow
{

    public static int CompressQuality = 100;

    public static float halveRate = 0.5f;

    [MenuItem("Tools/Compressed/SetFBXFormat")]
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
			EditorUtility.DisplayProgressBar("处理中>>>", filePath, (float)i / (float)files.Length);
            if (filePath.EndsWith(".FBX"))
            {
				ModelImporter modelImporter = AssetImporter.GetAtPath(filePath) as ModelImporter;
				if (modelImporter == null)
                    continue;
				modelImporter.meshCompression = ModelImporterMeshCompression.High;
				modelImporter.animationCompression = ModelImporterAnimationCompression.KeyframeReductionAndCompression;
                AssetDatabase.SaveAssets();
				AssetDatabase.Refresh ();
                DoAssetReimport(filePath, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
            }

        }

        EditorUtility.ClearProgressBar();
        EditorUtility.DisplayDialog("成功", "处理完成！", "好的");
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
