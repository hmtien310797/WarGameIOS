using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;
using Rotorz.ReorderableList;
public class TerrainExport : EditorWindow
{
    public Vector3 lightDir = Vector3.left;
    public float shadowStrenght = 20;
    public float heightOffset1 = 0.005f;
    public float heightOffset2 = 0.01f;
    public int shadowBlur = 4;
    public int heightBlur = 3;
    public Terrain mTerrain;
    public string mName = string.Empty;
    public Mesh ChunkMesh;
    public float ChunkSize = 128;
    public Vector3 CamRotate = Vector3.zero;
    public Vector3 CamHeight = Vector3.zero;
    public float CamFieldOfView;
    public float FogMax = 150;
    public Color FogColor = new Color(218.0f / 255.0f, 218.0f / 255.0f, 218.0f / 255.0f, 1);
    public int MaxSpriteNumInChunk;
    public float LogicBlockSize;
    public Vector2 TerrainLogicBoxRange = Vector2.zero;
    public List<TerrainSpriteMesh> SMeshs = new List<TerrainSpriteMesh>();
    public List<TerrainSpriteMesh> FixedSMeshs = new List<TerrainSpriteMesh>();
    public Texture2D BorderAtlas;
    public int BorderUnitCount;

    public Texture2D WaterBaseTex;
    public float WaterBaseTilingX;
    public float WaterBaseTilingY;

    public Texture2D WaterWaveNoise;
    public float WaterWaveNoiseTilingX;
    public float WaterWaveNoiseTilingY;

    public Cubemap WaterReflectionMap;
    public float WaterHeight;
    public float WaterWaveIndentity;
    public float WaterSpeedX;
    public float WaterSpeedY;

    public float WaterTwistFadeIn;
    public float WaterTwistFadeOut;
    public float WaterTwistFadeInIndentity;
    public float WaterTwistFadeOutIndentity;

    public float WaterIndentity;
    public float WaterSpecularIndentity;

    //public bool TerrainToggle;
    public float TerrainTilingX;
    public float TerrainTilingY;

    public int TL_MaxLineNUm;
    public int TL_point_num;
    public float TL_line_width;
    public float TL_min_dis;
    public float TL_tile_length;
    public float TL_offset_height;
    public float TL_faraway_target_height;
    public Material TL_mat;

    public float GroundHeight;
    public int LogicServerSizeX;
    public int LogicServerSizeY;
    public int CoreAreaSettingMinX;
    public int CoreAreaSettingMinY;
    public int CoreAreaSettingMaxX;
    public int CoreAreaSettingMaxY;

    public Texture2D[] CoreAreaTexs = new Texture2D[8];




    [MenuItem("Tools/Terrain 导出")]
    public static TerrainExport Init()
    {
        TerrainExport window = (TerrainExport)EditorWindow.GetWindow(typeof(TerrainExport));
        window.Show();
        return window;
    }

    private void ExprotMat(Terrain tr, string _name)
    {
        Material mat;
        //if (TerrainToggle)
        mat = new Material(Shader.Find("wgame/Terrain/ColorBlendHighMap 16"));
        //else
        //    mat = new Material(Shader.Find("wgame/Terrain/ColorBlendHighMap 8"));
        SplatPrototype[] sps = tr.terrainData.splatPrototypes;
        int max = Mathf.Min(8, sps.Length);
        string path = "Assets/" + SavePath.ExprotDir + "/" + _name;
        Texture2D blend = AssetDatabase.LoadAssetAtPath<Texture2D>(path + "/" + _name + "_B.png");
        Texture2D detailblend = AssetDatabase.LoadAssetAtPath<Texture2D>(path + "/" + _name + "_DB.png");
        Texture2D[] ts = new Texture2D[max];
        mat.SetTexture("_Blend", blend);
        mat.SetTexture("_DetalBlend", detailblend);
        mat.SetFloat("_Displacement", tr.terrainData.size.y + 2);

        Texture2D detail = AssetDatabase.LoadAssetAtPath<Texture2D>(path + "/" + _name + "_D.png");
        mat.SetTexture("_Detal", detail);
        mat.SetTextureScale("_Detal", new Vector2(TerrainTilingX, TerrainTilingY));
        Vector2 size = Vector2.one;
        //for (int i = 0; i < max; i++)
        //{
        //    string ap = AssetDatabase.GetAssetPath(sps[i].texture);
        //    Texture2D t = AssetDatabase.LoadAssetAtPath<Texture2D>(ap);
        //    ts[i] = t;
        //    mat.SetTexture("_Detal" + i.ToString(), t);
        //    size = sps[i].tileSize;
        //    size.x = 1f / (tr.terrainData.heightmapWidth - 1f) * 4 * (tr.terrainData.size.x / size.x);
        //    size.y = 1f / (tr.terrainData.heightmapHeight - 1f) * 4 * (tr.terrainData.size.z / size.y);
        //    mat.SetTextureScale("_Detal" + i, size);
        //    mat.SetTextureOffset("_Detal" + i, sps[i].tileOffset);
        //}
        //size.x = 1f / (tr.terrainData.heightmapWidth - 1f) * 4 * (tr.terrainData.size.x / 20);
        //size.y = 1f / (tr.terrainData.heightmapHeight - 1f) * 4 * (tr.terrainData.size.z / 20);

        string wp = AssetDatabase.GetAssetPath(WaterBaseTex);
        Texture2D wt = AssetDatabase.LoadAssetAtPath<Texture2D>(wp);
        mat.SetTexture("_WaterMainTex", wt);
        mat.SetTextureScale("_WaterMainTex", new Vector2(WaterBaseTilingX, WaterBaseTilingY));

        wp = AssetDatabase.GetAssetPath(WaterWaveNoise);
        wt = AssetDatabase.LoadAssetAtPath<Texture2D>(wp);
        mat.SetTexture("_WaterNoiseTex", wt);
        mat.SetTextureScale("_WaterNoiseTex", new Vector2(WaterWaveNoiseTilingX, WaterWaveNoiseTilingY));

        wp = AssetDatabase.GetAssetPath(WaterReflectionMap);
        Cubemap wcmap = AssetDatabase.LoadAssetAtPath<Cubemap>(wp);
        mat.SetTexture("_Cube", wcmap);

        mat.SetVector("_WaterSetting", new Vector4(WaterHeight, WaterWaveIndentity, WaterSpeedX, WaterSpeedY));
        mat.SetVector("_WaterTwistSetting", new Vector4(WaterTwistFadeIn, WaterTwistFadeOut, WaterTwistFadeInIndentity, WaterTwistFadeOutIndentity));
        mat.SetFloat("_WaterIndentity", WaterIndentity);

        mat.SetFloat("_SpecularIndentity", WaterSpecularIndentity);

        AssetDatabase.CreateAsset(mat, path + "/" + _name + ".mat");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    public struct ColorInfo
    {
        public float colorIndex;
        public float colorFactor;
    }

    public class ColorInfoCom : IComparer<ColorInfo>
    {
        public int Compare(ColorInfo x, ColorInfo y)
        {
            if (x.colorFactor > y.colorFactor)
                return 1;
            return -1;
        }
    }

    private void TerrainExprotHightAndBlendMap(Terrain tr, string _name)
    {
        if (tr == null)
            return;
        int w = tr.terrainData.heightmapResolution;
        int h = tr.terrainData.heightmapResolution;

        float[,] heights = tr.terrainData.GetHeights(0, 0, w, h);
        float[,,] alphasmap = tr.terrainData.GetAlphamaps(0, 0, tr.terrainData.alphamapWidth, tr.terrainData.alphamapHeight);
        Texture2D heightmap = new Texture2D(w, h, TextureFormat.ARGB32, false);
        Texture2D blendmap = new Texture2D(tr.terrainData.alphamapWidth, tr.terrainData.alphamapHeight, TextureFormat.ARGB32, false);
        Texture2D detailblendMap = new Texture2D(tr.terrainData.alphamapWidth, tr.terrainData.alphamapHeight, TextureFormat.ARGB32, false);
        Texture2D[] alphas = tr.terrainData.alphamapTextures;
        for (int t = 0; t < 2; t++)
        {
            for (int i = 0; i < alphas[t].width; i++)
            {
                for (int j = 0; j < alphas[t].height; j++)
                {
                    Color c = alphas[t].GetPixel(i, j);
                    if (t == 0)
                    {
                        blendmap.SetPixel(j, i, c);
                    }
                    if (t == 1)
                    {
                        detailblendMap.SetPixel(j, i, c);
                    }
                }
            }
        }
        //int al = UnityEngine.Mathf.Min(4, alphas.Length);
        //int aw = alphas[0].width;
        //int ah = alphas[0].height;
        //List<float> cf = new List<float>();
        //List<ColorInfo> cinfos = new List<ColorInfo>();
        //ColorInfoCom cicom = new ColorInfoCom();
        //float f = 0;
        //for (int i = 0; i < aw; i++)
        //{
        //    for (int j = 0; j < ah; j++)
        //    {
        //        cinfos.Clear();
        //        f = 0;
        //        for (int t = 0; t < al; t++)
        //        {
        //            Color ci = alphas[t].GetPixel(i, j);

        //            for (int cindex = 0; cindex < 4; cindex++)
        //            {
        //                ColorInfo cinfo = new ColorInfo();
        //                cinfo.colorIndex = ((float)(t * 4 + cindex)) / 16.0f;
        //                cinfo.colorFactor = ci[cindex];
        //                f += ci[cindex];
        //                cinfos.Add(cinfo);
        //            }
        //        }

        //        if (i == 264 && j == 171)
        //        {
        //            Debug.Log("SSSSSS");
        //        }

        //        cinfos.Sort((a, b) =>
        //        {
        //            if (a.colorFactor > b.colorFactor)
        //                return -1;
        //            return 1;
        //        });
        //        Color rc = Color.black;

        //        float total = 0;
        //        for (int cindex = 0; cindex < 2; cindex++)
        //        {
        //            if (cinfos.Count > cindex)
        //            {
        //                total += cinfos[cindex].colorFactor;
        //            }
        //        }

        //        //if (cinfos[1].colorFactor <= 0.001f)
        //        //{
        //        //    ColorInfo ctmp = cinfos[1];
        //        //    ctmp.colorIndex = cinfos[0].colorIndex;
        //        //    cinfos[1] = ctmp;
        //        //}
        //        //if (cinfos[0].colorFactor < 0.75f)
        //        //{
        //        //    rc.r = 0;
        //        //    rc.g = 1;
        //        //}
        //        //else
        //        {
        //            for (int cindex = 0; cindex < 2; cindex++)
        //            {
        //                if (cinfos.Count > cindex)
        //                {
        //                    rc[cindex * 2] = cinfos[cindex].colorIndex;
        //                    rc[cindex * 2 + 1] = (cinfos[cindex].colorFactor / total);
        //                    if (!cf.Contains(cinfos[cindex].colorIndex))
        //                    {
        //                        cf.Add(cinfos[cindex].colorIndex);
        //                    }
        //                }
        //            }

        //        }


        //        blendmap.SetPixel(j, i, rc);

        //        //blendmap.SetPixel(2 * j, 2 * i, rc);
        //        //blendmap.SetPixel(2 * j, 2 * i + 1, rc);
        //        //blendmap.SetPixel(2 * j + 1, 2 * i + 1, rc);
        //        //blendmap.SetPixel(2 * j + 1, 2 * i, rc);
        //    }
        //}
        //string log = "";
        //for (int i = 0; i < cf.Count; i++)
        //{
        //    log += "," + (cf[i] * 16).ToString();
        //}
        //Debug.Log(log);


        for (int i = 0; i < w; i++)
        {
            for (int j = 0; j < h; j++)
            {
                heightmap.SetPixel(i, j, new Color(heights[i, j], 1, 1, 1));
            }
        }
        blendmap.Apply();
        detailblendMap.Apply();
        heightmap.Apply();
        string savepath = SavePath.ExprotDir + "/" + _name;
        SaveImage.SavePNG(heightmap, _name + "_H", savepath);
        SaveImage.SavePNG(blendmap, _name + "_B", savepath);
        SaveImage.SavePNG(detailblendMap, _name + "_DB", savepath);
        AssetDatabase.Refresh();
        SaveImage.ChangeImage2ReadAndWrite(_name + "_H", savepath);
        SaveImage.ChangeImage2ReadAndWrite(_name + "_B", savepath);
        SaveImage.ChangeImage2ReadAndWrite(_name + "_DB", savepath);
        AssetDatabase.Refresh();
        GameObject.DestroyImmediate(heightmap);
        GameObject.DestroyImmediate(blendmap);
        GameObject.DestroyImmediate(detailblendMap);
    }

    private float GetMeshVSize()
    {
        Vector3[] vs = ChunkMesh.vertices;
        float f = Vector3.Distance(vs[1], vs[0]);
        return f * 0.25f;
    }

    private void ExproteWorldData(string _name)
    {
        WorldData world = ScriptableObject.CreateInstance<WorldData>();
        world.ChunkMesh = ChunkMesh;
        world.ChunkSize = ChunkSize;
        float ch = CamHeight.y;
        if (ch == 0)
            ch = mTerrain.terrainData.size.y + 2;
        world.CamOffset = CamHeight;
        world.CamRotate = CamRotate;
        world.CamFieldOfView = CamFieldOfView;
        world.FogColor = FogColor;
        world.FogMaxDis = FogMax;
        string path = "Assets/" + SavePath.ExprotDir + "/" + _name + "/";
        Material mat = AssetDatabase.LoadAssetAtPath<Material>(path + _name + ".mat");
        world.ChunkMat = mat;
        Texture2D shmap = AssetDatabase.LoadAssetAtPath<Texture2D>(path + _name + "_H_S.png");
        world.ChunkMat = mat;
        world.heighRange = new Rect(0, 0, mTerrain.terrainData.size.x, mTerrain.terrainData.size.z);
        float s = GetMeshVSize();
        int p = Mathf.RoundToInt((s / mTerrain.terrainData.size.x) * shmap.width);
        world.PixelOffset = p;
        world.TerrainMaxHeight = mTerrain.terrainData.size.y + 2;

        world.MaxSpriteNumInChunk = MaxSpriteNumInChunk;
        world.LogicBlockSize = LogicBlockSize;
        world.LogicWCount = Mathf.FloorToInt(mTerrain.terrainData.size.x / LogicBlockSize);
        world.LogicHCount = Mathf.FloorToInt(mTerrain.terrainData.size.z / LogicBlockSize);

        //world.LogicTags = LogicBlockTool.GenerateTerrainTags(mTerrain, world, shmap, TerrainLogicBoxRange);
        world.SpriteFactory = TerrainSpriteTool.CreateSpriteFactory(mTerrain, shmap, world, s);

        world.MarkerTypeCount = BorderUnitCount;
        world.BorderMarkerTex = BorderAtlas;

        world.MaxLineNum = TL_MaxLineNUm;
        world.TerrainLineSetting.point_num = TL_point_num;
        world.TerrainLineSetting.line_width = TL_line_width;
        world.TerrainLineSetting.min_dis = TL_min_dis;
        world.TerrainLineSetting.tile_length = TL_tile_length;
        world.TerrainLineSetting.offset_height = TL_offset_height;
        world.TerrainLineSetting.faraway_target_height = TL_faraway_target_height;
        world.TerrainLineSetting.mat = TL_mat;


        world.GroundHeight = GroundHeight;
        world.LogicServerSizeX = LogicServerSizeX;
        world.LogicServerSizeY = LogicServerSizeY;
        world.CoreAreaSetting = new Vector4(CoreAreaSettingMinX, CoreAreaSettingMinY, CoreAreaSettingMaxX, CoreAreaSettingMaxY);

        List<TerrainSpriteMesh> meshs = new List<TerrainSpriteMesh>();
        for (int i = 0; i < SMeshs.Count; i++)
        {
            if (SMeshs[i].mesh != null && SMeshs[i].mat != null)
            {
                //SMeshs[i].mat.SetFloat("_FogLineMax", FogMax);
                //SMeshs[i].mat.SetColor("_FogColor", FogColor);
                meshs.Add(SMeshs[i]);
            }
        }
        world.SpriteFactory.SpriteMeshs = meshs.ToArray();
        world.SpriteFactory.FixedSpriteMeshs = FixedSMeshs.ToArray();
        AssetDatabase.CreateAsset(world, path + _name + "_Data.asset");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
    private void DrawEmpty()
    {
        GUILayout.Label("No items in list.", EditorStyles.miniLabel);
    }
    private TerrainSpriteMesh PendingItemDrawer(Rect position, TerrainSpriteMesh itemValue)
    {
        // Text fields do not like null values!
        if (itemValue == null)
            itemValue = new TerrainSpriteMesh();

        position.height = 25;
        itemValue.mesh = (Mesh)EditorGUI.ObjectField(position, "Mesh", itemValue.mesh, typeof(Mesh), true);
        position.y += 25;
        itemValue.mat = (Material)EditorGUI.ObjectField(position, "mat", itemValue.mat, typeof(Material), true);
        position.y += 25;
        itemValue.size = EditorGUI.FloatField(position, "size", itemValue.size);
        position.y += 25;
        itemValue.castShadow = EditorGUI.Toggle(position, "castShadow", itemValue.castShadow);
        position.y += 25;
        itemValue.maxNumInChunk = EditorGUI.IntField(position, "拥有最多的个数", itemValue.maxNumInChunk);
        position.y += 25;
        itemValue.maxVCount = EditorGUI.IntField(position, "拥有的最大顶点数量", itemValue.maxVCount);
        position.x = position.xMax + 5;
        position.width = 45;
        return itemValue;
    }

    private Vector2 mScrollPos;
    void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        mScrollPos = EditorGUILayout.BeginScrollView(mScrollPos);
        mName = EditorGUILayout.TextField("导出名称", mName);
        mTerrain = (Terrain)EditorGUILayout.ObjectField("地形", mTerrain, typeof(Terrain), true);
        if (mTerrain != null && string.IsNullOrEmpty(mName))
        {
            mName = mTerrain.name;
            if (SMeshs.Count == 0)
            {
                TreePrototype[] trees = mTerrain.terrainData.treePrototypes;
                for (int i = 0; i < trees.Length; i++)
                {
                    TerrainSpriteMesh tm = new TerrainSpriteMesh();
                    MeshFilter mf = trees[i].prefab.GetComponent<MeshFilter>();
                    if (mf == null)
                    {
                        mf = trees[i].prefab.GetComponentInChildren<MeshFilter>();
                    }
                    if (mf != null)
                    {
                        tm.mesh = mf.sharedMesh;
                    }

                    MeshRenderer mr = trees[i].prefab.GetComponent<MeshRenderer>();
                    if (mr == null)
                    {
                        mr = trees[i].prefab.GetComponentInChildren<MeshRenderer>();
                    }
                    if (mr != null)
                    {
                        tm.mat = mr.sharedMaterial;
                    }

                    tm.size = 1;
                    SMeshs.Add(tm);
                }
            }
        }
        ChunkMesh = (Mesh)EditorGUILayout.ObjectField("地形组块 Mesh", ChunkMesh, typeof(Mesh), true);

        ReorderableListGUI.Title("Sprite Meshs");
        EditorGUILayout.LabelField("-----------------地表装饰物表---------------------");
        ReorderableListGUI.ListField(SMeshs, PendingItemDrawer, DrawEmpty, 150);
        EditorGUILayout.LabelField("-----------------固定装饰物表---------------------");
        ReorderableListGUI.ListField(FixedSMeshs, PendingItemDrawer, DrawEmpty, 150);

        ChunkSize = EditorGUILayout.FloatField("地形组块 大小", ChunkSize);
        CamRotate = EditorGUILayout.Vector3Field("地形Camera视角", CamRotate);
        CamHeight = EditorGUILayout.Vector3Field("地形Camera位置", CamHeight);
        CamFieldOfView = EditorGUILayout.FloatField("地形CameraFieldOfView", CamFieldOfView);
        FogMax = EditorGUILayout.FloatField("雾的最大距离", FogMax);
        FogColor = EditorGUILayout.ColorField("雾的颜色", FogColor);

        //heightMap = (Texture2D)EditorGUILayout.ObjectField("高度图", heightMap, typeof(Texture2D), true);
        lightDir = EditorGUILayout.Vector3Field("光线方向", lightDir);
        shadowStrenght = EditorGUILayout.FloatField("阴影强度", shadowStrenght);
        heightOffset1 = EditorGUILayout.FloatField("阴影偏移量1", heightOffset1);
        heightOffset2 = EditorGUILayout.FloatField("阴影偏移量2", heightOffset2);
        heightBlur = (int)EditorGUILayout.Slider("高度模糊", heightBlur, 0, 16);
        shadowBlur = (int)EditorGUILayout.Slider("阴影模糊", shadowBlur, 0, 16);

        MaxSpriteNumInChunk = EditorGUILayout.IntField("chunk内装饰最大数", MaxSpriteNumInChunk);
        LogicBlockSize = EditorGUILayout.FloatField("逻辑层块的大小", LogicBlockSize);
        TerrainLogicBoxRange.x = EditorGUILayout.FloatField("逻辑块地形障碍下限", TerrainLogicBoxRange.x);
        TerrainLogicBoxRange.y = EditorGUILayout.FloatField("逻辑块地形障碍幅度", TerrainLogicBoxRange.y);
        //TerrainToggle = EditorGUILayout.Toggle("地形贴图是否是2的幂", TerrainToggle);
        TerrainTilingX = EditorGUILayout.FloatField("地形贴图Tiling x", TerrainTilingX);
        TerrainTilingY = EditorGUILayout.FloatField("地形贴图Tiling y", TerrainTilingY);


        BorderAtlas = (Texture2D)EditorGUILayout.ObjectField("边界图集", BorderAtlas, typeof(Texture2D), true);
        BorderUnitCount = EditorGUILayout.IntField("边界图集元素总数", BorderUnitCount);

        EditorGUILayout.LabelField("-----------------水面---------------------");
        WaterBaseTex = (Texture2D)EditorGUILayout.ObjectField("水面基础纹理", WaterBaseTex, typeof(Texture2D), true);
        WaterBaseTilingX = EditorGUILayout.FloatField("水面基础纹理Tiling x", WaterBaseTilingX);
        WaterBaseTilingY = EditorGUILayout.FloatField("水面基础纹理Tiling y", WaterBaseTilingY);

        WaterWaveNoise = (Texture2D)EditorGUILayout.ObjectField("水面波纹噪声", WaterWaveNoise, typeof(Texture2D), true);
        WaterWaveNoiseTilingX = EditorGUILayout.FloatField("水面基础纹理Tiling x", WaterWaveNoiseTilingX);
        WaterWaveNoiseTilingY = EditorGUILayout.FloatField("水面基础纹理Tiling y", WaterWaveNoiseTilingY);

        WaterReflectionMap = (Cubemap)EditorGUILayout.ObjectField("水面反射cube map", WaterReflectionMap, typeof(Cubemap), true);
        WaterHeight = EditorGUILayout.FloatField("水面高度", WaterHeight);
        WaterWaveIndentity = EditorGUILayout.FloatField("水面波动幅度", WaterWaveIndentity);
        WaterSpeedX = EditorGUILayout.FloatField("水面沿着X轴移动的速度", WaterSpeedX);
        WaterSpeedY = EditorGUILayout.FloatField("水面沿着y轴移动的速度", WaterSpeedY);
        WaterTwistFadeIn = EditorGUILayout.FloatField("水面扭曲的淡入位置", WaterTwistFadeIn);
        WaterTwistFadeOut = EditorGUILayout.FloatField("水面扭曲的淡出位置", WaterTwistFadeOut);
        WaterTwistFadeInIndentity = EditorGUILayout.FloatField("水面扭曲的淡入强度", WaterTwistFadeInIndentity);
        WaterTwistFadeOutIndentity = EditorGUILayout.FloatField("水面扭曲的淡出强度", WaterTwistFadeOutIndentity);
        WaterIndentity = EditorGUILayout.FloatField("水面透视度", WaterIndentity);
        WaterSpecularIndentity = EditorGUILayout.FloatField("水面高光强度", WaterSpecularIndentity);


        EditorGUILayout.LabelField("-----------------地图上的导航线---------------------");
        TL_MaxLineNUm = EditorGUILayout.IntField("最多显示的导航线数量", TL_MaxLineNUm);
        TL_point_num = EditorGUILayout.IntField("导航线顶点数量", TL_point_num);
        TL_line_width = EditorGUILayout.FloatField("导航线宽", TL_line_width);
        TL_min_dis = EditorGUILayout.FloatField("导航线点之间最小距离", TL_min_dis);
        TL_tile_length = EditorGUILayout.FloatField("导航线纹理的Tile size", TL_tile_length);
        TL_offset_height = EditorGUILayout.FloatField("导航线遇到山峰时的离地高度偏移值", TL_offset_height);
        TL_faraway_target_height = EditorGUILayout.FloatField("超远距离导航线离地高度", TL_faraway_target_height);
        TL_mat = (Material)EditorGUILayout.ObjectField("导航线的材质", TL_mat, typeof(Material), true);

        EditorGUILayout.LabelField("-----------------核心区域---------------------");
        GroundHeight = EditorGUILayout.FloatField("核心区域地标高度", GroundHeight);
        LogicServerSizeX = EditorGUILayout.IntField("服务器上地图的大小X", LogicServerSizeX);
        LogicServerSizeY = EditorGUILayout.IntField("服务器上地图的大小Y", LogicServerSizeY);
        CoreAreaSettingMinX = EditorGUILayout.IntField("核心区域最小下标X", CoreAreaSettingMinX);
        CoreAreaSettingMinY = EditorGUILayout.IntField("核心区域最小下标Y", CoreAreaSettingMinY);
        CoreAreaSettingMaxX = EditorGUILayout.IntField("核心区域最大下标X", CoreAreaSettingMaxX);
        CoreAreaSettingMaxY = EditorGUILayout.IntField("核心区域最大下标Y", CoreAreaSettingMaxY);
        CoreAreaTexs[0] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图1", CoreAreaTexs[0], typeof(Texture2D), true);
        CoreAreaTexs[1] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图2", CoreAreaTexs[1], typeof(Texture2D), true);
        CoreAreaTexs[2] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图3", CoreAreaTexs[2], typeof(Texture2D), true);
        CoreAreaTexs[3] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图4", CoreAreaTexs[3], typeof(Texture2D), true);
        CoreAreaTexs[4] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图5", CoreAreaTexs[4], typeof(Texture2D), true);
        CoreAreaTexs[5] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图6", CoreAreaTexs[5], typeof(Texture2D), true);
        CoreAreaTexs[6] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图7", CoreAreaTexs[6], typeof(Texture2D), true);
        CoreAreaTexs[7] = (Texture2D)EditorGUILayout.ObjectField("核心区地标贴图8", CoreAreaTexs[7], typeof(Texture2D), true);


        if (GUILayout.Button("导出高度图and前4张的纹理混合图..."))
        {
            //生成地图
            BuildTexture();

            TerrainExprotHightAndBlendMap(mTerrain, mName);
            string path = "Assets/" + SavePath.ExprotDir +
                "/" + mName + "/" + mName + "_H.png";
            Texture2D hightmap = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
            if (hightmap != null)
            {
                GenerateHeight2ShadowMap.GenerateShadowMap(hightmap,
                    lightDir,
                    shadowStrenght,
                    heightOffset1,
                    heightOffset2,
                    heightBlur,
                    shadowBlur, SavePath.ExprotDir + "/" + mName);

                ExprotMat(mTerrain, mName);
                ExproteWorldData(mName);
            }
        }
        EditorGUILayout.EndScrollView();
        EditorGUILayout.EndVertical();
    }

    void BuildTexture()
    {
        Texture2D TerrainTarget = new Texture2D(1024, 1024, TextureFormat.RGB24, false);
        //if (!TerrainToggle)
        //{
        //    TerrainTarget = new Texture2D(1024, 512, TextureFormat.RGB24, false);
        //}
        //设置白色
        for (int h = 0; h < TerrainTarget.height; ++h)
        {
            for (int w = 0; w < TerrainTarget.width; ++w)
            {
                Color color = Color.white;
                TerrainTarget.SetPixel(w, h, color);
            }
        }
        TerrainTarget.Apply();
        //Texture2D[] scaleTexture = new Texture2D[terrain.terrainData.splatPrototypes.Length];
        for (int i = 0; i < Mathf.Min(8, mTerrain.terrainData.splatPrototypes.Length); i++)
        {
            Texture2D t = mTerrain.terrainData.splatPrototypes[i].texture;
            //t = ScaleTexture(t, 256, 256);

            int x = 0, y = 3;
            //if (TerrainToggle)
            //{
            if (i != 0 && i >= 4)
            {
                x = i - 4;
                y = 2;
            }
            else
            {
                x = i;
            }
            //}
            //else
            //{
            //    if (i != 0 && i >= 4)
            //    {
            //        x = i - 4;
            //        y = 0;
            //    }
            //    else
            //    {
            //        x = i;
            //        y = 1;
            //    }
            //}


            //取图
            Color32[] color = t.GetPixels32(0);
            //赋给新图
            TerrainTarget.SetPixels32(x * t.width, y * t.height, t.width, t.height, color);

        }
        for (int i = 0; i < 8; i++)
        {
            Texture2D t = CoreAreaTexs[i];
            if (t != null)
            {
                int x = 0, y = 1;
                if (i != 0 && i >= 4)
                {
                    x = i - 4;
                    y = 0;
                }
                else
                {
                    x = i;
                }
                Color32[] color = t.GetPixels32(0);
                TerrainTarget.SetPixels32(x * t.width, y * t.height, t.width, t.height, color);
            }
        }

        //应用
        TerrainTarget.Apply();
        byte[] byt = TerrainTarget.EncodeToPNG();
        string path = "Assets/" + SavePath.ExprotDir +
                "/" + mName + "/" + mName + "_D.png";
        File.WriteAllBytes(path, byt);
        AssetDatabase.Refresh();

        TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
        if (textureImporter != null)
        {
            textureImporter.textureType = TextureImporterType.Default;
            textureImporter.filterMode = FilterMode.Point;
            textureImporter.mipmapEnabled = false;
            textureImporter.isReadable = true;
        }
    }
    Texture2D ScaleTexture(Texture2D source, int targetWidth, int targetHeight)
    {
        Texture2D result = new Texture2D(targetWidth, targetHeight, source.format, false);

        float incX = (1.0f / (float)targetWidth);
        float incY = (1.0f / (float)targetHeight);

        for (int i = 0; i < result.height; ++i)
        {
            for (int j = 0; j < result.width; ++j)
            {
                Color newColor = source.GetPixelBilinear((float)j / (float)result.width, (float)i / (float)result.height);
                result.SetPixel(j, i, newColor);
            }
        }

        result.Apply();
        return result;
    }
}
