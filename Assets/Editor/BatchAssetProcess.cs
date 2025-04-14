using UnityEngine;
using UnityEditor;
using System.Collections;


public static class PrefabProcess
{
    static bool UI_Anchor_Process(GameObject obj,string path)
    {
        if(obj.GetComponent<UIPanel>() == null)
            return false;
        GameObject rootGO = (GameObject) PrefabUtility.InstantiatePrefab(obj);
        UIWidget[] widgets = rootGO.GetComponentsInChildren<UIWidget>();
        if(widgets != null)
        {
            for(int i =0,imax = widgets.Length;i<imax;i++)
            {
                UIWidget w = widgets[i];
                if(w.updateAnchors == UIRect.AnchorUpdate.OnUpdate)
                {
                    w.updateAnchors = UIRect.AnchorUpdate.OnEnable;
                }
            }
        }
        PrefabUtility.ReplacePrefab(rootGO,AssetDatabase.LoadAssetAtPath(path,typeof(GameObject)),ReplacePrefabOptions.ConnectToPrefab);
        Editor.DestroyImmediate(rootGO);
        return true;
    }

    public static void Prefab_Process(BAP_CONTEXT.ProcessType ptype, int param, string path)
    {
        if (ptype != BAP_CONTEXT.ProcessType.PT_PREFAB)
            return;
        string name = Clishow.CsFileHelper.GetFileNameAndSuffix(path);
        string new_path = BatchAssetProcess.result_path + name;
        GameObject obj = ProcessUtility.CopyPrefab(name, path, new_path);
        if (obj == null)
            return;
        bool process = false;
        switch (param)
        {
            case 0:
                process = UI_Anchor_Process(obj,new_path);
                break;
        }
        if (process)
        {
        }
        else
        {
            AssetDatabase.DeleteAsset(new_path);
        }
    }
}


public static class TexProcess
{
    public static void Tex_Process(BAP_CONTEXT.ProcessType ptype, int param, string path)
    {
        if (ptype != BAP_CONTEXT.ProcessType.PT_TEX)
            return;
        string name = Clishow.CsFileHelper.GetFileNameAndSuffix(path);
        string new_path = BatchAssetProcess.result_path + name;
        TextureImporter texImporter = ProcessUtility.CopyAsset<TextureImporter>(name, path, new_path);
        if (texImporter == null)
            return;
        bool process = false;
        texImporter.textureType = TextureImporterType.Default;
        //if(texImporter.textureType != TextureImporterType.Advanced)
        //{
        //    AssetDatabase.DeleteAsset(new_path);
        //    return;
        //}
        switch (param)
        {
            case 0:
                process = true;
                texImporter.isReadable = false;
                texImporter.mipmapEnabled = false;
                if (texImporter.alphaIsTransparency)
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 1024, TextureImporterFormat.PVRTC_RGBA4);
                    texImporter.SetPlatformTextureSettings("Android", 1024, TextureImporterFormat.ETC2_RGBA8);
                }
                else
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 1024, TextureImporterFormat.PVRTC_RGB4);
                    texImporter.SetPlatformTextureSettings("Android", 1024, TextureImporterFormat.ETC_RGB4);
                }
                break;
            case 1:
                process = true;
                texImporter.isReadable = false;
                texImporter.mipmapEnabled = false;
                if (texImporter.alphaIsTransparency)
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 512, TextureImporterFormat.PVRTC_RGBA4);
                    texImporter.SetPlatformTextureSettings("Android", 512, TextureImporterFormat.ETC2_RGBA8);
                }
                else
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 512, TextureImporterFormat.PVRTC_RGB4);
                    texImporter.SetPlatformTextureSettings("Android", 512, TextureImporterFormat.ETC_RGB4);
                }
                break;
            case 2:
                process = true;
                texImporter.isReadable = false;
                //texImporter.mipmapEnabled = false;
                if (texImporter.alphaIsTransparency)
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 256, TextureImporterFormat.PVRTC_RGBA2);
                    texImporter.SetPlatformTextureSettings("Android", 256, TextureImporterFormat.ETC2_RGB4_PUNCHTHROUGH_ALPHA);
                }
                else
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 256, TextureImporterFormat.PVRTC_RGB2);
                    texImporter.SetPlatformTextureSettings("Android", 256, TextureImporterFormat.ETC_RGB4);
                }
                break;
            case 3:
                process = true;
                texImporter.isReadable = false;
                //texImporter.mipmapEnabled = false;
                if (texImporter.alphaIsTransparency)
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 128, TextureImporterFormat.PVRTC_RGBA2);
                    texImporter.SetPlatformTextureSettings("Android", 128, TextureImporterFormat.ETC2_RGB4_PUNCHTHROUGH_ALPHA);
                }
                else
                {
                    texImporter.SetPlatformTextureSettings("iPhone", 128, TextureImporterFormat.PVRTC_RGB2);
                    texImporter.SetPlatformTextureSettings("Android", 128, TextureImporterFormat.ETC_RGB4);
                }
                break;
        }
        if (process)
        {
            AssetDatabase.ImportAsset(new_path);
        }
        else
        {
            AssetDatabase.DeleteAsset(new_path);
        }

    }
}

public static class MeshProcess
{
    public static void Mesh_Process(BAP_CONTEXT.ProcessType ptype, int param, string path)
    {
        if (ptype != BAP_CONTEXT.ProcessType.PT_MESH)
            return;
        string name = Clishow.CsFileHelper.GetFileNameAndSuffix(path);
        string new_path = BatchAssetProcess.result_path + name;
        ModelImporter modelimporter = ProcessUtility.CopyAsset<ModelImporter>(name, path, new_path);
        if (modelimporter == null)
            return;
        bool process = false;
        switch (param)
        {
            case 0:
                process = true;
                //modelimporter.globalScale = 1.0f;
                //modelimporter.meshCompression = ModelImporterMeshCompression.Off;
                //modelimporter.animationType = ModelImporterAnimationType.Generic;
                modelimporter.isReadable = false;
                modelimporter.optimizeMesh = true;
                modelimporter.optimizeGameObjects = true;
                modelimporter.importTangents = ModelImporterTangents.None;
                break;
        }
        if (process)
        {
            AssetDatabase.ImportAsset(new_path);
        }
        else
        {
            AssetDatabase.DeleteAsset(new_path);
        }
    }
}

public static class ProcessUtility
{
    public static T CopyAsset<T>(string name, string path, string new_path) where T : AssetImporter
    {
        if(!CopyObject(name,path,new_path))
            return null;
        T importer = AssetImporter.GetAtPath(new_path) as T;
        if (importer == null)
        {
            AssetDatabase.DeleteAsset(new_path);
        }
        return importer;
    }

    public static GameObject CopyPrefab(string name, string path, string new_path)
    {
        if(!CopyObject(name,path,new_path))
            return null;
        GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(new_path);
        if (obj == null)
        {
            AssetDatabase.DeleteAsset(new_path);
        }
        return obj;
    }

    public static bool CopyObject(string name, string path, string new_path)
    {
        string suffix = Clishow.CsFileHelper.GetFileSuffix(path);
        if (suffix.Contains("meta"))
        {
            return false;
        }
        if (!AssetDatabase.CopyAsset(path, new_path))
        {
            Debug.LogError("[Process Failed] asset path:" + path);
            return false;
        }
        return true;
    }

}

public static class BAP_CONTEXT
{
    public enum ProcessType
    {
        PT_PREFAB = 0,
        PT_TEX,
        PT_MESH,
    }
    public readonly static string[] pt_names = new string[]{
        "Prefab","纹理","Mesh"
    };

    public readonly static string[][] ptp_names = new string[][]{
       new string[]{ "UI锚点"},
       new string[]{ "UI 图片","UI 特效","图片","特效"},
       new string[]{ "Tangent"},
    };

    public delegate void ProcessFunc(ProcessType ptype, int param, string path);

    public readonly static ProcessFunc[] funcs = new ProcessFunc[]{
        PrefabProcess.Prefab_Process,
        TexProcess.Tex_Process,
        MeshProcess.Mesh_Process,
    };
}

public class BatchAssetProcess : EditorWindow
{
    public static string work_path = "Assets/_TEMP_BAP_WORK/";
    public static string result_path = "Assets/_TEMP_BAP_RESULT/";
    static int cur_pt = 0;
    static int cur_param = 0;

    [MenuItem("Tools/Batch Asset Process...")]
    static void CreateWindow()
    {
        BatchAssetProcess window = null;
        if (window != null)
        {
            window.Close();
        }
        else
        {
            window = (BatchAssetProcess)EditorWindow.GetWindow(typeof(BatchAssetProcess));
            window.titleContent.text = "Batch Asset Process";
            window.minSize = new Vector2(300, 100);
        }
    }

    void Process()
    {
        Clishow.CsFileHelper.CreateFolder(work_path);
        Clishow.CsFileHelper.DeleteFolder(result_path);
        Clishow.CsFileHelper.CreateFolder(result_path);
        string[] assets = Clishow.CsFileHelper.GetFiles(work_path, System.IO.SearchOption.AllDirectories, "");

        int total = assets.Length;
        for (int i = 0; i < total; i++)
        {
            BAP_CONTEXT.funcs[cur_pt]((BAP_CONTEXT.ProcessType)cur_pt, cur_param, assets[i]);
            EditorUtility.DisplayProgressBar("[BAP]" + BAP_CONTEXT.pt_names[cur_pt] + ":" + BAP_CONTEXT.ptp_names[cur_pt][cur_param] + "...",
                (i + 1) + "/" + total, (i + 1) / total);
        }
        EditorUtility.ClearProgressBar();
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        EditorGUILayout.LabelField("工作路径:" + work_path);
        EditorGUILayout.LabelField("结果路径:" + result_path);

        int select_pt = EditorGUILayout.Popup("处理类型", cur_pt, BAP_CONTEXT.pt_names);
        if (select_pt != cur_pt)
        {
            cur_param = 0;
            cur_pt = select_pt;
        }
        cur_param = EditorGUILayout.Popup("处理模式", cur_param, BAP_CONTEXT.ptp_names[cur_pt]);
        if (GUILayout.Button("开始处理"))
        {
            Process();
        }
        EditorGUILayout.EndVertical();
    }

    void OnInspectorUpdate()
    {
        Repaint();
    }
}
