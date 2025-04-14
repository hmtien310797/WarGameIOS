using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class LightMapUtility
{
    [MenuItem("Tools/Store Lightmap Information")]
    static void StoreLMInfo()
    {
        if (LightmapSettings.lightmaps.Length == 0)
        {
            Debug.LogError("Bake the lightmap first.");
            return;
        }
        if (Application.isPlaying)
        {
            Debug.LogError("Stop playing first.");
            return;
        }

        Renderer[] objs = GameObject.FindObjectsOfType<Renderer>();
        for (int i=0; i<objs.Length; i++)
        {
            if (objs[i].gameObject.isStatic && objs[i].gameObject.activeInHierarchy)
            {
                LightmapConf lconf = objs[i].GetComponent<LightmapConf>();
                if (lconf == null)
                {
                    lconf = objs[i].gameObject.AddComponent<LightmapConf>();
                }
                lconf.lightmapRenderer = objs[i];
                lconf.lightmapIndex = objs[i].lightmapIndex;
                lconf.lightmapScaleOffset = objs[i].lightmapScaleOffset;
            }
        }
    }

#region ReplaceLightmapTools
    //RenderTexture to png
    static bool SaveRenderTextureToPNG(Texture inputTex, Shader outputShader, string contents, string pngName)
    {
        RenderTexture temp = RenderTexture.GetTemporary(inputTex.width, inputTex.height, 0, RenderTextureFormat.ARGB32);
        Material mat = new Material(outputShader);
        Graphics.Blit(inputTex, temp, mat);
        bool ret = SaveRenderTextureToPNG(temp, contents, pngName);
        RenderTexture.ReleaseTemporary(temp);

        return ret;
    }

    static bool SaveRenderTextureToPNG(RenderTexture rt, string contents, string pngName)
    {
        RenderTexture prev = RenderTexture.active;
        RenderTexture.active = rt;

        Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
        png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        byte[] bytes = png.EncodeToPNG();

        if (!Directory.Exists(contents))
        {
            Directory.CreateDirectory(contents);
        }
        FileStream file = File.Open(contents + "/" + pngName + ".png", FileMode.Create);

        BinaryWriter writer = new BinaryWriter(file);
        writer.Write(bytes);
        file.Close();

        Texture2D.DestroyImmediate(png);
        png = null;

        RenderTexture.active = prev;

        return true;
    }

    [MenuItem("Tools/Lightmap2Png/转换当前场景的Lightmap(LogLuv编码)")]
    static void CreateCurrentSceneLightmap()
    {
        //replace light map texture
        Shader replaceShader = Shader.Find("ReplaceLightmap/OutputLightmap");

        string sceneName = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene().name;
        if (sceneName.Contains(".")) sceneName = sceneName.Remove(0, sceneName.LastIndexOf('.'));
        string contents = "Assets/Art/Models/LevelScene/scene/" + sceneName;
        LightmapData[] lightmaps = LightmapSettings.lightmaps;
        for (int i = 0, iMax = lightmaps.Length; i < iMax; i++)
        {
            Texture f = lightmaps[i].lightmapColor;
            Texture n = lightmaps[i].lightmapDir;
            if (n != null)
            {
                Debug.LogError("有Near类型的Lightmap!");
            }

            if (SaveRenderTextureToPNG(f, replaceShader, contents, "Lightmap_" + i))
            {

                Debug.Log("exr光照图convert to png :" + "<color=yellow>" + contents + "/" + f.name + ".png" + " </color> ");

            }
        }
    }

    [MenuItem("Tools/Lightmap2Png/替换当前场景的Lightmap")]
    static void ReplaceCurrentSceneLightmap()
    {
        //replace light map texture
        LightmapData[] lightmaps = LightmapSettings.lightmaps;
        if (lightmaps.Length == 0)
            return;

        string sceneName = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene().name;
        if (sceneName.Contains(".")) sceneName = sceneName.Remove(0, sceneName.LastIndexOf('.'));

        //string lightmapName = lightmaps[0].lightmapFar.name;

        Renderer[] renderer = GameObject.FindObjectsOfType(typeof(Renderer)) as Renderer[];

        string lightmapPath = "Assets/Art/Models/LevelScene/scene/" + sceneName + "/" + "Lightmap_0" + ".png";

        for (int i = 0, iMax = renderer.Length; i < iMax; i++)
        {
            Renderer rd = renderer[i];
            Material oldMat = rd.sharedMaterial;

            if (oldMat.shader.name.Equals("Legacy Shaders/Diffuse"))
            {
                Shader shader = Shader.Find("ReplaceLightmap/ReplaceDiffuse");
                Texture lightmapTex = AssetDatabase.LoadAssetAtPath(lightmapPath, typeof(Texture)) as Texture;
                rd.sharedMaterial.shader = shader;
                rd.sharedMaterial.SetTexture("_LightmapTex", lightmapTex);
                Debug.Log(i + "修改的材质----" + "<color=red>" + rd.name + " </color> ");
            }
            else if (oldMat.shader.name.Equals("ReplaceLightmap/ReplaceDiffuse"))
            {
                Texture lightmapTex = AssetDatabase.LoadAssetAtPath(lightmapPath, typeof(Texture)) as Texture;
                if (lightmapTex) rd.sharedMaterial.SetTexture("_LightmapTex", lightmapTex);

                Debug.Log(i + "添加贴图----" + "<color=red>" + rd.name + " </color> ");
            }
        }
    }
#endregion
}
