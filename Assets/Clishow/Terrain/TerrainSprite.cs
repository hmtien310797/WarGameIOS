using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax.QuadSpace;
[System.Serializable]
public class TerrainSpriteData
{
    public int posIndex;
    public int count;
    public int localIndex;
    public Vector3 wPos;
    public Color Color;
    public int prototypeIndex;
    public float scale;

    public bool isValid = false;
    [System.NonSerialized]
    public ScQuadRect Rect;
    [System.NonSerialized]
    public int ChunkIndex;

}

public static class TerrainSpriteTool
{
    public static Vector2 GetWorldToUV(WorldData world, Vector3 wpos)
    {
        Vector4 hr = new Vector4(world.heighRange.width, world.heighRange.height, world.heighRange.width * 0.5f, world.heighRange.height * 0.5f);
        Vector2 hr1_5 = new Vector2(hr.z + hr.x, hr.w + hr.y);
        float fw = 1 / world.heighRange.width;
        float xmin = -hr1_5.x;
        float ymin = -hr1_5.y;
        Vector2 uv = Vector2.zero;
        uv.x = (wpos.x - xmin) * fw;
        uv.y = (wpos.z - ymin) * fw;
        uv.x = uv.x - (int)uv.x;
        if (uv.x < 0)
            uv.x += 1;
        uv.y = uv.y - (int)uv.y;
        if (uv.y < 0)
            uv.y += 1;
        return uv;
    }

    public static bool GetWorldToBlendUV(Vector2 uv, int hmw, int hmh, out Vector2 blenduv)
    {
        float blendx = 5.0f / hmw;
        float blendy = 5.0f / hmh;
        bool blend = false;
        blenduv = uv;
        if (uv.x < blendx || 1 - uv.x < blendx)
        {
            blenduv.x = 1.0f - uv.x;
            blend = true;
        }
        if (uv.y < blendy || 1 - uv.y < blendy)
        {
            blenduv.y = 1 - uv.y;
            blend = true;
        }
        return blend;
    }

    public static int GetHeightAndShadowIndex(int hmw, int hmh, Vector2 uv, int poffsetx = 0, int poffsety = 0)
    {
        int px = (int)((1 - uv.x) * hmw) + poffsetx;
        px = px < 0 ? (hmw + px) : px;
        px = px >= hmw ? (px - hmw) + 1 : px;
        int py = (int)((1 - uv.y) * hmh) + poffsety;
        py = py < 0 ? (hmw + py) : py;
        py = py >= hmh ? (py - hmh) + 1 : py;
        int index = (hmw - px - 1) * hmh + py + 1;
        return index;
    }

    public static Color GetHeightAndShadow(Color[] hm_colors, int hmw, int hmh, Vector2 uv, Vector2 buv, bool isblend, int poffsetx = 0, int poffsety = 0)
    {
        int index = GetHeightAndShadowIndex(hmw, hmh, uv, poffsetx, poffsety);
        Color color = Color.black;
        if (isblend)
        {
            int bindex = GetHeightAndShadowIndex(hmw, hmh, buv, poffsetx, poffsety);
            color = hm_colors[index - 1];
            color = Color.Lerp(color, hm_colors[bindex - 1], 0.5f);
        }
        else
        {
            color = hm_colors[index - 1];
        }
        return color;
    }

    public static Color GetHeightAndShadow(Color[] hm_colors, int hmw, int hmh, WorldData world, Vector3 wpos)
    {
        Vector4 hr = new Vector4(world.heighRange.width, world.heighRange.height, world.heighRange.width * 0.5f, world.heighRange.height * 0.5f);
        Vector2 hr1_5 = new Vector2(hr.z + hr.x, hr.w + hr.y);
        float fw = 1 / world.heighRange.width;
        float blendx = 5.0f / hmw;
        float blendy = 5.0f / hmh;
        bool blend = false;
        float uvx, uvy;

        float xmin = -hr1_5.x;
        float ymin = -hr1_5.y;
        uvx = (wpos.x - xmin) * fw;
        uvy = (wpos.z - ymin) * fw;
        Vector2 uv = Vector2.zero;
        uv.x = uvx;
        uv.y = uvy;
        uv.x = uv.x - (int)uv.x;
        if (uv.x < 0)
            uv.x += 1;
        uv.y = uv.y - (int)uv.y;
        if (uv.y < 0)
            uv.y += 1;
        blend = false;
        Vector2 buv = Vector2.zero;
        buv = uv;
        if (uv.x < blendx || 1 - uv.x < blendx)
        {
            buv.x = 1.0f - uv.x;
            blend = true;
        }
        if (uv.y < blendy || 1 - uv.y < blendy)
        {
            buv.y = 1 - uv.y;
            blend = true;
        }

        int px = (int)((1 - uv.x) * hmw);
        int py = (int)((1 - uv.y) * hmh);
        int index = (hmw - px - 1) * hmh + py + 1;
        Color color = Color.black;
        if (blend)
        {
            int bpx = (int)((1 - buv.x) * hmw);
            int bpy = (int)((1 - buv.y) * hmh);
            int bindex = (hmw - bpx - 1) * hmh + bpy + 1;
            color = hm_colors[index - 1];
            color = Color.Lerp(color, hm_colors[bindex - 1], 0.5f);
        }
        else
        {
            color = hm_colors[index - 1];
        }
        return color;
    }

    public static Color GetHeightAndShadow(Color[] hm_colors, int hmw, int hmh, int px, int py)
    {
        int index = (hmw - px - 1) * hmh + py + 1;
        return hm_colors[index - 1];
    }

    public static TerrainSpriteData CreateSpriteData(TreeInstance tree, Color[] hm_colors, float maxh, int hmw, int hmh, WorldData world, Vector3 wpos)
    {
        TerrainSpriteData data = new TerrainSpriteData();
        //Color hmc = GetHeightAndShadow(hm_colors, hmw, hmh, world, wpos);
        Vector2 uv = GetWorldToUV(world, wpos);
        Vector2 buv;
        bool blend = GetWorldToBlendUV(uv, hmw, hmh, out buv);
        //uv.y = 1 - uv.y;
        //buv.y = 1 - buv.y;
        Color hs_center = GetHeightAndShadow(hm_colors, hmw, hmh, uv, buv, blend);
        Color hs_SX = GetHeightAndShadow(hm_colors, hmw, hmh, uv, buv, blend, 1, 0);
        Color hs_SY = GetHeightAndShadow(hm_colors, hmw, hmh, uv, buv, blend, 0, 1);
        Color hs_SXX = GetHeightAndShadow(hm_colors, hmw, hmh, uv, buv, blend, -1, 0);
        Color hs_SYY = GetHeightAndShadow(hm_colors, hmw, hmh, uv, buv, blend, 0, -1);
        float extraLightning = ((((hs_center.g + hs_SX.g + hs_SY.g + hs_SXX.g + hs_SYY.g) * 0.2f + -0.5f) * 5.0f) + 1f);
        float lightAndShadow = Mathf.Min(1.5f, Mathf.Max(0.6f, extraLightning));
        Color c = new Color(0, 1, 0, 0);
        data.Color += c * lightAndShadow;//(Color)(tree.color)
        wpos.y = hs_center.r * maxh;
        data.wPos = wpos;
        data.prototypeIndex = tree.prototypeIndex;
        data.scale = tree.heightScale;

        return data;
    }

    public static TerrainSpriteFactory CreateSpriteFactory(Terrain tr, Texture2D hm, WorldData world, float v_size)
    {
        TerrainSpriteFactory factory = new TerrainSpriteFactory();
        float tw = tr.terrainData.size.x;
        float th = tr.terrainData.size.y;
        float tl = tr.terrainData.size.z;

        TreeInstance[] trees = tr.terrainData.treeInstances;
        if (trees == null || trees.Length == 0)
            return factory;
        Color[] hm_colors = hm.GetPixels();
        int hmw = hm.width;
        int hmh = hm.height;
        List<TerrainSpriteData> sprites = new List<TerrainSpriteData>();
        Vector3 pos = Vector3.zero;
        Quaternion qAngle = Quaternion.Euler(world.CamRotate);
        Dictionary<int, List<TerrainSpriteData>> mPosMap = new Dictionary<int, List<TerrainSpriteData>>();

        for (int i = 0; i < trees.Length; i++)
        {
            float x = (trees[i].position.x - 0.5f) * tw;
            float y = (1 - trees[i].position.z - 0.5f) * tl;
            pos = new Vector3(x, 0, y);
            {
                TerrainSpriteData data = CreateSpriteData(trees[i], hm_colors, th, hmw, hmh, world, pos);
                pos.x = (trees[i].position.x) * tw;
                pos.z = (1 - trees[i].position.z) * tl;
                data.posIndex = LogicBlockMap.Pos2Index(pos, world.LogicBlockSize, world.LogicWCount, world.LogicHCount);
                if (!mPosMap.ContainsKey(data.posIndex))
                {
                    mPosMap.Add(data.posIndex, new List<TerrainSpriteData>());

                }
                mPosMap[data.posIndex].Add(data);
                for (int j = 0; j < mPosMap[data.posIndex].Count; j++)
                {
                    mPosMap[data.posIndex][j].localIndex = j;
                    mPosMap[data.posIndex][j].count = mPosMap[data.posIndex].Count;
                }
                sprites.Add(data);
            }

        }
        factory.Sprites = sprites.ToArray();
        return factory;
    }
}

public class TerrainSpriteChunk
{
    private int mCurSpriteCount;
    private TerrainSpriteData[] mSprites = null;
    private Vec2Int[] mOffsetScales = null;
    private int[] mSpriteIndexs = null;

    private int mFixedCurSpriteCount;
    private int[] mFixedSprite = null;
    private Vec2Int[] mFixedOffsetScales = null;
    private Vector3[] mFixedOffsetFloats = null;
    private int[] mFixedOffsetFloatTags = null;
    private int[] mFixedSpriteIndexs = null;

    private int[][] mLogicMap = null;
    private WorldData mWorld;

    private Vector3 mTmp = Vector3.zero;

    public TerrainSpriteChunk(WorldData worldInfo)
    {
        mWorld = worldInfo;
        int count = Mathf.Max(1, Mathf.RoundToInt(mWorld.MaxSpriteNumInChunk * mWorld.world.MeshQuality));
        mSprites = new TerrainSpriteData[count];
        mSpriteIndexs = new int[count];
        mOffsetScales = new Vec2Int[count];

        mFixedSprite = new int[mWorld.MaxSpriteNumInChunk];
        mFixedSpriteIndexs = new int[mWorld.MaxSpriteNumInChunk];
        mFixedOffsetScales = new Vec2Int[mWorld.MaxSpriteNumInChunk];
        mFixedOffsetFloats = new Vector3[mWorld.MaxSpriteNumInChunk];
        mFixedOffsetFloatTags = new int[mWorld.MaxSpriteNumInChunk];

        mLogicMap = new int[mWorld.LogicHCount * mWorld.LogicWCount][];
        mCurSpriteCount = 0;
        mFixedCurSpriteCount = 0;
    }

    public void Reset()
    {
        if (mCurSpriteCount > 0)
        {
            for (int i = 0; i < mCurSpriteCount; i++)
            {
                if (mSprites[i] == null)
                    continue;
                if (mLogicMap[mSprites[i].posIndex] != null)
                {
                    for (int j = 0; j < mSprites[i].count; j++)
                    {
                        mLogicMap[mSprites[i].posIndex][mSprites[i].localIndex] = -1;
                    }
                }
                mWorld.PopSpriteMeshInfo(mSprites[i].prototypeIndex, mSpriteIndexs[i]);
                mSprites[i] = null;
                mSpriteIndexs[i] = -1;
            }
            mCurSpriteCount = 0;
        }
        if (mFixedCurSpriteCount > 0)
        {
            for (int i = 0; i < mFixedCurSpriteCount; i++)
            {
                if (mFixedSprite[i] <= 0)
                    continue;
                mWorld.PopFixedSpriteMeshInfo(mFixedSprite[i] - 1, mFixedSpriteIndexs[i]);
                mFixedSprite[i] = 0;
                mFixedSpriteIndexs[i] = -1;
            }
            mFixedCurSpriteCount = 0;
            System.Array.Clear(mFixedOffsetFloatTags, 0, mFixedOffsetFloatTags.Length);
        }

    }

    public void AddSprite(TerrainSpriteData sprite, LogicBlockMap map, int wx, int wy)
    {
        if (mCurSpriteCount >=  Mathf.Max(1,(int)(mWorld.MaxSpriteNumInChunk * mWorld.world.MeshQuality)))
            return;
        //if (HMMeshTool.isInCoreArea(wx, wy, mWorld))
        //    return;
        mSprites[mCurSpriteCount] = sprite;
        map.LogicPos2WScale(wx, wy, ref mOffsetScales[mCurSpriteCount]);
        mCurSpriteCount++;
    }

    public void AddFixedSprite(int fixed_type, int wx, int wy)
    {
        mFixedSprite[mFixedCurSpriteCount] = fixed_type + 1;
        mFixedOffsetScales[mFixedCurSpriteCount].x = wx;
        mFixedOffsetScales[mFixedCurSpriteCount].y = wy;
        mFixedCurSpriteCount++;
    }

    public void AddFixedSprite(int fixed_type, float x, float y, float z)
    {
        mFixedSprite[mFixedCurSpriteCount] = fixed_type + 1;
        mTmp = mFixedOffsetFloats[mFixedCurSpriteCount];
        mTmp.x = x;
        mTmp.y = y;
        mTmp.z = z;
        mFixedOffsetFloats[mFixedCurSpriteCount] = mTmp;
        mFixedOffsetFloatTags[mFixedCurSpriteCount] = 1;
        mFixedCurSpriteCount++;
    }

    public void FillSprite(Chunk chunk)
    {
        int index = 0;
        if (mCurSpriteCount != 0)
        {
            TerrainSpriteData data;
            for (int i = 0; i < mCurSpriteCount; i++)
            {
                data = mSprites[i];
                if (data != null)
                {
                    index = mWorld.PushSpriteMeshInfo(data, mOffsetScales[i]);
                    mSpriteIndexs[i] = index;
                    if (mLogicMap[data.posIndex] == null)
                    {
                        mLogicMap[data.posIndex] = new int[data.count];
                    }
                    mLogicMap[data.posIndex][data.localIndex] = i;
                }
            }
        }

        if (mFixedCurSpriteCount != 0)
        {
            for (int i = 0; i < mFixedCurSpriteCount; i++)
            {
                if (mFixedOffsetFloatTags[i] == 0)
                {
                    index = mWorld.PushFixedSpriteMeshInfo(mFixedSprite[i] - 1, mFixedOffsetScales[i]);
                }
                else
                {
                    mTmp = mFixedOffsetFloats[i];
                    index = mWorld.PushFixedSpriteMeshInfo(mFixedSprite[i] - 1, mTmp.x, mTmp.y, mTmp.z);
                }
                mFixedSpriteIndexs[i] = index;
            }
        }
    }

    public int HideSprite(int posIndex)
    {
        if (mLogicMap[posIndex] != null)
        {
            for (int i = 0; i < mLogicMap[posIndex].Length; i++)
            {
                int j = mLogicMap[posIndex][i];
                if (j < 0 || j >= mSprites.Length)
                    continue;
                if (mSprites[j] != null)
                {
                    mWorld.PopSpriteMeshInfo(mSprites[j].prototypeIndex, mSpriteIndexs[j]);
                }
                mLogicMap[posIndex][i] = -1;
                mSprites[j] = null;
                mSpriteIndexs[j] = -1;
            }
            return posIndex;
        }
        return -1;
    }

    public void Destroy()
    {
        mWorld = null;
        mSprites = null;
        mSpriteIndexs = null;
        mOffsetScales = null;

        mFixedSprite = null;
        mFixedSpriteIndexs = null;
        mFixedOffsetScales = null;

        mLogicMap = null;
        mCurSpriteCount = 0;
        mFixedCurSpriteCount = 0;
    }
}

[System.Serializable]
public class TerrainSpriteMesh
{
    public Mesh mesh;
    public Material mat;
    public float size;
    public bool castShadow;
    public int maxNumInChunk = -1;
    public int maxVCount = -1;
}

[System.Serializable]
public class TerrainSpriteFactory
{
    public TerrainSpriteData[] Sprites;
    public TerrainSpriteMesh[] SpriteMeshs;
    public TerrainSpriteMesh[] FixedSpriteMeshs;


    private WorldData mWorld;
    private bool mInited = false;

    private TerrainSpriteData[][] mSpritesMap;

    public TerrainSpriteData[][] SpritesMap
    {
        get
        {
            return mSpritesMap;
        }
    }

    private int mTotalSprites;

    public void InitEx(WorldData world)
    {
        mWorld = world;
        mTotalSprites = world.LogicWCount * world.LogicHCount;
        mSpritesMap = new TerrainSpriteData[mTotalSprites][];
        TerrainSpriteData data;
        for (int i = 0, imax = Sprites.Length; i < imax; i++)
        {
            data = Sprites[i];
            if (data.posIndex >= mTotalSprites)
                continue;
            if (mSpritesMap[data.posIndex] == null)
                mSpritesMap[data.posIndex] = new TerrainSpriteData[data.count];
            mSpritesMap[data.posIndex][data.localIndex] = data;
        }
        mInited = true;
    }

    public void Clear()
    {
        mWorld = null;
        mTotalSprites = -1;
        mSpritesMap = null;
        mInited = false;
    }
}
