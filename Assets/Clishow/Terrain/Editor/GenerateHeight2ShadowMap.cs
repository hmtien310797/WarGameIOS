using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

public class SaveImage
{
    static public void ChangeImage2ReadAndWrite(string name, string dir)
    {
        string dirPath = Application.dataPath + "/" + dir;
        if (!Directory.Exists(dirPath))
            return;
        Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/" + dir + "/" + name + ".png");
        TextureUtils.ChangeTextureSettings(texture, true, false, FilterMode.Bilinear, TextureImporterFormat.DXT5, TextureImporterType.Default, true, 1024);
    }

    static public void SavePNG(Texture2D texture, string name, string dir)
    {
        if (texture == null) return;

        byte[] data = texture.EncodeToPNG();
        string dirPath = Application.dataPath + "/" + dir;
        if (!Directory.Exists(dirPath))
        {
            Directory.CreateDirectory(dirPath);
        }

        FileStream file = File.Open(dirPath + "/" + name + @".png", FileMode.OpenOrCreate);
        BinaryWriter binary = new BinaryWriter(file);
        binary.Write(data);
        file.Close();
    }

    static public void SaveJPG(Texture2D texture, string name, string dir)
    {
        if (texture == null) return;

        byte[] data = texture.EncodeToJPG();
        string dirPath = Application.dataPath + "/" + dir;
        if (!Directory.Exists(dirPath))
        {
            Directory.CreateDirectory(dirPath);
        }

        FileStream file = File.Open(dirPath + "/" + name + @".jpg", FileMode.OpenOrCreate);
        BinaryWriter binary = new BinaryWriter(file);
        binary.Write(data);
        file.Close();
    }
}

public static class SavePath
{
    public static string ExprotDir = "T2H";
}

public class GenerateHeight2ShadowMap : EditorWindow
{
    private Texture2D heightMap;
    private Vector3 lightDir;
    private float shadowStrenght;
    private float heightOffset1;
    private float heightOffset2;
    private int shadowBlur;
    private int heightBlur;

    //[MenuItem("Tools/生成阴影图通过高度图")]
    public static GenerateHeight2ShadowMap Init()
    {
        GenerateHeight2ShadowMap window = (GenerateHeight2ShadowMap)EditorWindow.GetWindow(typeof(GenerateHeight2ShadowMap));
        window.Show();
        return window;
    }

    public static void BlurTexture(RenderTexture texture, int downSample, int size, int interations)
    {
        float widthMod = 1.0f / (1.0f * (1 << downSample));

        Material material = new Material(Shader.Find("Hidden/FastBlur"));
        material.SetVector("_Parameter", new Vector4(size * widthMod, -size * widthMod, 0.0f, 0.0f));
        texture.filterMode = FilterMode.Bilinear;


        int rtW = texture.width >> downSample;
        int rtH = texture.height >> downSample;

        // downsample
        RenderTexture rt = RenderTexture.GetTemporary(rtW, rtH, 0, texture.format);
        rt.filterMode = FilterMode.Bilinear;

        Graphics.Blit(texture, rt, material, 0);

        for (int i = 0; i < interations; i++)
        {
            float iterationOffs = (i * 1.0f);
            material.SetVector("_Parameter", new Vector4(size * widthMod + iterationOffs, -size * widthMod - iterationOffs, 0.0f, 0.0f));

            // vertical blur
            RenderTexture rt2 = RenderTexture.GetTemporary(rtW, rtH, 0, texture.format);
            rt2.filterMode = FilterMode.Bilinear;

            Graphics.Blit(rt, rt2, material, 1);
            rt.Release();
            rt = rt2;

            // horizontal blur
            rt2 = RenderTexture.GetTemporary(rtW, rtH, 0, texture.format);
            rt2.filterMode = FilterMode.Bilinear;

            Graphics.Blit(rt, rt2, material, 2);
            rt.Release();
            rt = rt2;
        }

        GameObject.DestroyImmediate(material);

        Graphics.Blit(rt, texture);
        rt.Release();
    }

    static Texture2D ImportShadow2Height(Texture2D sm, Texture2D hm)
    {
        Texture2D shmap = new Texture2D(hm.width, hm.height, TextureFormat.RGB24, false);
        Color[] sm_cols = sm.GetPixels();
        Color[] hm_cols = hm.GetPixels();
        Color[] sh_cols = new Color[sm_cols.Length];
        for (int i = 0, imax = sm_cols.Length; i < imax; i++)
        {
            Color c = Color.white;
            c.r = hm_cols[i].r;
            c.g = sm_cols[i].r;
            sh_cols[i] = c;
        }
        shmap.SetPixels(sh_cols);
        shmap.Apply();
        return shmap;
    }

    public static void GenerateShadowMap(Texture2D hm,
        Vector3 ld,
        float ss,
        float ho1,
        float ho2,
        int hblur,
        int sblur,
        string path)
    {
        if (hm == null)
            return;
        RenderTexture shadowmapRT = RenderTexture.GetTemporary(hm.width, hm.height, 0, RenderTextureFormat.ARGB32);
        Material h2smat = new Material(Shader.Find("wgame/Terrain/Height2Shadow"));
        h2smat.SetTexture("_HeightTex", hm);
        h2smat.SetVector("_LightDir", ld);
        h2smat.SetFloat("_ShadowStrenght", ss);
        h2smat.SetFloat("_HeightOffset1", ho1);
        h2smat.SetFloat("_HeightOffset2", ho2);


        RenderTexture blurhightmapRT = RenderTexture.GetTemporary(hm.width, hm.height, 0, RenderTextureFormat.ARGB32);
        Graphics.Blit(hm, blurhightmapRT);
        if (hblur > 0)
        {
            BlurTexture(blurhightmapRT, 1, 1, hblur);
        }
        Texture2D blurhightmap = new Texture2D(hm.width, hm.height, TextureFormat.ARGB32, false);
        RenderTexture.active = blurhightmapRT;
        blurhightmap.ReadPixels(new Rect(0, 0, blurhightmapRT.width, blurhightmapRT.height), 0, 0);
        blurhightmap.Apply();
        RenderTexture.active = null;
        blurhightmapRT.Release();

        Graphics.Blit(blurhightmap, shadowmapRT, h2smat, 0);
        if (sblur > 0)
        {
            BlurTexture(shadowmapRT, 1, 1, sblur);
        }
        Texture2D shadowmap = new Texture2D(hm.width, hm.height, TextureFormat.RGB24, false);
        RenderTexture.active = shadowmapRT;
        shadowmap.ReadPixels(new Rect(0, 0, shadowmapRT.width, shadowmapRT.height), 0, 0);
        shadowmap.Apply();
        Texture2D shadowHeight = ImportShadow2Height(shadowmap, blurhightmap);
        SaveImage.SavePNG(shadowHeight, hm.name + "_S", path);
        AssetDatabase.Refresh();
        SaveImage.ChangeImage2ReadAndWrite(hm.name + "_S", path);
        AssetDatabase.Refresh();
        RenderTexture.active = null;
        shadowmapRT.Release();
        GameObject.DestroyImmediate(h2smat);
        GameObject.DestroyImmediate(shadowmap);
        GameObject.DestroyImmediate(shadowHeight);
        GameObject.DestroyImmediate(blurhightmap);
    }

    void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        heightMap = (Texture2D)EditorGUILayout.ObjectField("高度图", heightMap, typeof(Texture2D), true);
        lightDir = EditorGUILayout.Vector3Field("光线方向", lightDir);
        shadowStrenght = EditorGUILayout.FloatField("阴影强度", shadowStrenght);
        heightOffset1 = EditorGUILayout.FloatField("阴影偏移量1", heightOffset1);
        heightOffset2 = EditorGUILayout.FloatField("阴影偏移量2", heightOffset2);
        heightBlur = (int)EditorGUILayout.Slider("高度模糊", heightBlur, 0, 16);
        shadowBlur = (int)EditorGUILayout.Slider("阴影模糊", shadowBlur, 0, 16);
        if (GUILayout.Button("生成..."))
        {
            GenerateShadowMap(heightMap, lightDir, shadowStrenght, heightOffset1, heightOffset2, heightBlur, shadowBlur, "H2S");
        }
        EditorGUILayout.EndVertical();
    }
}


public class GenerateColorWaveMesh : EditorWindow
{
    private Mesh mMesh;
    private float mHeight;
    private float mWidth;

    [MenuItem("Tools/生成波动Mesh Color r")]
    public static GenerateColorWaveMesh Init()
    {
        GenerateColorWaveMesh window = (GenerateColorWaveMesh)EditorWindow.GetWindow(typeof(GenerateColorWaveMesh));
        window.Show();
        return window;
    }

    public void GenerateWareMesh()
    {
        Vector3[] vs = mMesh.vertices;

        float min = -1, max = -1;
        for (int i = 0; i < vs.Length; i++)
        {
            Vector3 v = vs[i];
            if (min < 0)
            {
                min = v.y;
            }
            else
            {
                if (v.y < min)
                {
                    min = v.y;
                }
            }

            if (max < 0)
            {
                max = v.y;
            }
            else
            {
                if (v.y > max)
                {
                    max = v.y;
                }
            }
        }

        Color[] cs = new Color[vs.Length];
        for (int i = 0; i < vs.Length; i++)
        {
            Vector3 v = vs[i];
            Color c = Color.black;
            c.r = Mathf.Abs(v.y - min) / Mathf.Abs(max - min);
            cs[i] = c;
        }
        Mesh mesh = new Mesh();
        mesh.vertices = mMesh.vertices;
        mesh.colors = cs;
        mesh.normals = mMesh.normals;
        mesh.triangles = mMesh.triangles;
        mesh.uv = mMesh.uv;

        string path = AssetDatabase.GetAssetPath(mMesh);
        path = path.Substring(0, path.IndexOf('.'));
        path += "_color.asset";
        AssetDatabase.CreateAsset(mesh, path);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        mMesh = (Mesh)EditorGUILayout.ObjectField("Mesh", mMesh, typeof(Mesh), true);

        if (GUILayout.Button("生成..."))
        {
            GenerateWareMesh();
        }
        EditorGUILayout.EndVertical();
    }
}

public class CopyTerrain : EditorWindow
{
    public Terrain source;
    public string new_name;
    [MenuItem("Tools/拷贝地形纹理")]
    public static CopyTerrain Init()
    {
        CopyTerrain window = (CopyTerrain)EditorWindow.GetWindow(typeof(CopyTerrain),true,"拷贝地形纹理");
        window.Show();
        return window;
    }

    private void Save(string save_name)
    {
        TerrainData terrainData = new TerrainData();

        terrainData.heightmapResolution = source.terrainData.heightmapResolution;
        terrainData.size = source.terrainData.size;
        terrainData.wavingGrassAmount = source.terrainData.wavingGrassAmount;
        terrainData.wavingGrassSpeed = source.terrainData.wavingGrassSpeed;
        terrainData.wavingGrassStrength = source.terrainData.wavingGrassStrength;
        terrainData.wavingGrassTint = source.terrainData.wavingGrassTint;
        terrainData.detailPrototypes = source.terrainData.detailPrototypes;
        terrainData.treePrototypes = source.terrainData.treePrototypes;
        terrainData.treeInstances = source.terrainData.treeInstances;
        
        terrainData.alphamapResolution = source.terrainData.alphamapResolution;
        terrainData.baseMapResolution = source.terrainData.baseMapResolution;
        terrainData.splatPrototypes = source.terrainData.splatPrototypes;

        float[,,] alphaMap = source.terrainData.GetAlphamaps(0, 0, source.terrainData.alphamapWidth, source.terrainData.alphamapHeight);
        terrainData.SetAlphamaps(0, 0, alphaMap);
        Texture2D[] texs =  source.terrainData.alphamapTextures;



        float[,] heights = source.terrainData.GetHeights(0, 0, source.terrainData.heightmapResolution,source.terrainData.heightmapResolution);
        terrainData.SetHeights(0, 0, heights);

        //GameObject _newTerrainObj = Terrain.CreateTerrainGameObject(terrainData);

        string path = "Assets/TerrainCopy/";
        string dirPath = Application.dataPath + "/TerrainCopy/";
        if (!Directory.Exists(dirPath))
        {
            Directory.CreateDirectory(dirPath);
        }
        
        for(int i =0;i<texs.Length;i++)
        {
            SaveImage.SavePNG(texs[i], i.ToString(), "TerrainCopy/"+save_name);
            AssetDatabase.Refresh();
            SaveImage.ChangeImage2ReadAndWrite(i.ToString(), "TerrainCopy/"+save_name);
            AssetDatabase.Refresh();
        }
        

        AssetDatabase.CreateAsset(terrainData, path + save_name + ".asset");
        //PrefabUtility.CreatePrefab(path + save_name + ".prefab",_newTerrainObj);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    void Load(string save_name)
    {
        string path = "Assets/TerrainCopy/";
        TerrainData targetData = AssetDatabase.LoadAssetAtPath<TerrainData>(path+save_name+".asset");
        source.terrainData.alphamapResolution = targetData.alphamapResolution;
        source.terrainData.baseMapResolution = targetData.baseMapResolution;
        source.terrainData.splatPrototypes = targetData.splatPrototypes;
        float[,,] alphaMap = targetData.GetAlphamaps(0, 0, targetData.alphamapWidth, targetData.alphamapHeight);

        Texture2D[] texs = new Texture2D[2];
        for(int i = 0;i<2;i++)
        {
            string p = path+save_name+"/"+i+".png";
           texs[i] = AssetDatabase.LoadAssetAtPath<Texture2D>(p);
        }

        

        int w = targetData.heightmapResolution;
        int h = targetData.heightmapResolution;

        for (int i = 0; i < w; i++)
        {
            for (int j = 0; j < h; j++)
            {
                int i2 = (int)(i * targetData.alphamapWidth / (w - 1f));
                int j2 = (int)(j * targetData.alphamapHeight / (h - 1f));
                i2 = Mathf.Min(targetData.alphamapWidth - 1, i2);
                j2 = Mathf.Min(targetData.alphamapHeight - 1, j2);
                for(int k = 0;k<targetData.splatPrototypes.Length;k++)
                {
                    if(texs[k/4] != null)
                        alphaMap[j2,i2,k] = texs[k/4].GetPixel(i,j)[k%4];
                }
            }
        }

        source.terrainData.SetAlphamaps(0, 0, alphaMap);
    }

    void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        source = (Terrain)EditorGUILayout.ObjectField("地形Copy目标", source, typeof(Terrain), true);
        new_name = EditorGUILayout.TextField("新的存档名",new_name);
        if (GUILayout.Button("save..."))
        {
            Save(new_name);
        }

        if (GUILayout.Button("Load..."))
        {
            Load(new_name);
        }
        EditorGUILayout.EndVertical();
    }
}