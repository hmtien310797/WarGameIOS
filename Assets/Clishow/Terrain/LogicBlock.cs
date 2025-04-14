using System;
using System.Collections.Generic;
using UnityEngine;

public enum LogicBlockType
{
    LBT_OBSTACLE_L = 0x0001,
    LBT_OBSTACLE_H = 0x0002,
}

public class LogicBlockSet
{
    public enum BlockShowMode
    {
        BSM_Normal,
        BSM_Show_Border,
        BSM_Show_Debug_Border,
    }

    private Chunk mChunk;
    private WorldData mWorld;
    private LogicBlockMap mMap;
    private LogicBlockWorldMap mWorldMap;

    private int mWCount;
    private int mHCount;
    public static Vec2Int curHidePoint = new Vec2Int();
    private static Color mDefaultBorderColor = Color.white;
    private Vec2Int tmp = new Vec2Int();
    private Vec2Int tmpClear = new Vec2Int();
    private Vector3 tmpVec3 = Vector3.zero;


    private TerrainBorderMarkerBox mMarkerBox;
    public TerrainBorderMarkerBox MarkerBox { get { return mMarkerBox; } }
    public LogicBlockSet(Chunk chunk, WorldData world)
    {
        mWorld = world;
        mChunk = chunk;
        mMap = mWorld.LBlockMap;
        mWorldMap = mWorld.WBlockMap;
        mWCount = (int)(mChunk.MeshRect.Width / mMap.BlockSize);
        mHCount = (int)(mChunk.MeshRect.Height / mMap.BlockSize);
    }

    public void WorldPos2LocalPos(ref Vec2Int wpos)
    {
        Vec2Int wmin = mMap.WorldPos2WLogicPos((Vector3)mChunk.MeshRect.MinPoint + Vector3.one * mMap.BlockSize * 0.5f, mWorld);//
        wpos.x = wpos.x - wmin.x;
        wpos.y = wpos.y - wmin.y;
        if (wpos.x > mWCount)
            wpos.x = -1;
        if (wpos.y > mHCount)
            wpos.y = -1;
    }

    public void HideSpriteForBuild()
    {
        Vec2Int wmin = mMap.WorldPos2WLogicPos((Vector3)mChunk.MeshRect.MinPoint + Vector3.one * mMap.BlockSize * 0.5f, mWorld);
        Vec2Int lmin = mMap.WorldPos2LogicPos((Vector3)mChunk.MeshRect.MinPoint + Vector3.one * mMap.BlockSize * 0.5f, mWorld);
        int lx, ly, index;
        for (int x = 0; x < mWCount; x++)
        {
            for (int y = 0; y < mHCount; y++)
            {
                tmpClear.x = x + wmin.x;
                tmpClear.y = y + wmin.y;
                int type = mWorldMap.GetBuild(ref tmpClear);
                if (type > 0)
                {
                    lx = x + lmin.x;
                    ly = y + lmin.y;
                    index = mMap.LogicPos2Index(lx, ly);
                    mChunk.SpriteChunk.HideSprite(index);
                }
            }
        }
    }

    Vec2Int GetWLocalPos(Vec2Int wpos)
    {
        //将带负的转换到 0-512
        Vec2Int w;
        w.x = wpos.x % mWorld.LogicServerSizeX;
        if (w.x < 0)
            w.x = mWorld.LogicServerSizeX + w.x;
        w.y = wpos.y % mWorld.LogicServerSizeY;
        if (w.y < 0)
        {
            w.y = mWorld.LogicServerSizeY + w.y;
        }
        return w;
    }

    public void Update(bool update_fixed = true)
    {
        Vec2Int lmin = mMap.WorldPos2LogicPos((Vector3)mChunk.MeshRect.MinPoint + Vector3.one * mMap.BlockSize * 0.5f, mWorld);//
        Vec2Int wmin = mMap.WorldPos2WLogicPos((Vector3)mChunk.MeshRect.MinPoint + Vector3.one * mMap.BlockSize * 0.5f, mWorld);//
        //int[] tagMap = mMap.TagMaps;
        int lx, ly, index, lindex, wx, wy;
        TerrainSpriteData[][] map = mWorld.SpriteFactory.SpritesMap;
        bool iscenter = mChunk.worldData.CenterChunk == mChunk;
        for (int x = 0; x < mWCount; x++)
        {
            for (int y = 0; y < mHCount; y++)
            {
                lx = x + lmin.x;
                ly = y + lmin.y;
                index = mMap.LogicPos2Index(lx, ly);
                lindex = (mWCount - x - 1) * mHCount + y;
                //mTags[lindex] = tagMap[index];

                wx = x + wmin.x;
                wy = y + wmin.y;
                if (HMMeshTool.isMainServerBorder(ref wx, ref wy, mWorld) && update_fixed)
                {
                    int fixed_border_type = mWorld.GetFixedBorder(wx, wy, mWorld);
                    if (fixed_border_type >= 0)
                    {
                        mChunk.SpriteChunk.AddFixedSprite(fixed_border_type, x + wmin.x, y + wmin.y);
                    }
                }
                else if(iscenter)
                {
                    if (!Main.Instance.isOccupied(WorldObjectType.ALL, wx, wy))
                        if (map[index] != null)
                            for (int i = 0; i < map[index].Length; i++)
                                mChunk.SpriteChunk.AddSprite(map[index][i], mMap, x + wmin.x, y + wmin.y);
                }

            }
        }

    }

    public void Destroy()
    {
        mWorld = null;
        mChunk = null;
        mMap = null;
        mWorldMap = null;
    }

}

public struct Vec2Int
{
    public int x;
    public int y;

    public Vec2Int(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
}

public class LogicBlockWorldMap
{
    private int[] mTerritorys;
    public int[] mBuilds;
    public FastStack<int>[] mEffects;
    public FastPool<FastStack<int>> mEffectPool;
    private int mWidth;
    private int mHeight;
    private int mCount;
    private Color[] mTerrotoryColors;

    public LogicBlockWorldMap(int world_width, int world_height)
    {
        mWidth = world_width;
        mHeight = world_height;
        mCount = world_width * world_height;
        mTerritorys = new int[mCount];
        mBuilds = new int[mCount];
        mEffects = new FastStack<int>[mCount];
        mEffectPool = new FastPool<FastStack<int>>();
        mTerrotoryColors = new Color[] { Color.black };
    }

    public Color GetTerColor(int i)
    {
        int index = (i - 1) % (mTerrotoryColors.Length);
        return mTerrotoryColors[index];
    }

    public void SetTerritory(ref Vec2Int world_l_pos, int t_index)
    {
        int wx = world_l_pos.x % mWidth;
        int wy = world_l_pos.y % mHeight;
        if (wx < 0)
        {
            wx = mWidth + wx;
        }

        if (wy < 0)
        {
            wy = mHeight + wy;
        }
        int i = (mWidth - wx - 1) * mHeight + wy;
        mTerritorys[i] = t_index;
    }

    public void SetBuild(ref Vec2Int world_l_pos, int t_index)
    {
        int wx = world_l_pos.x % mWidth;
        int wy = world_l_pos.y % mHeight;
        if (wx < 0)
        {
            wx = mWidth + wx;
        }

        if (wy < 0)
        {
            wy = mHeight + wy;
        }
        int i = (mWidth - wx - 1) * mHeight + wy;
        mBuilds[i] = t_index;
    }

    public void SetTerritory(int wIndex, int t_index)
    {
        mTerritorys[wIndex] = t_index;
    }


    public void ClearTerritory()
    {
        System.Array.Clear(mTerritorys, 0, mTerritorys.Length);
    }

    public void ClearBuild()
    {
        System.Array.Clear(mBuilds, 0, mBuilds.Length);
    }

    public void ClearEffect()
    {
        System.Array.Clear(mEffects, 0, mEffects.Length);
        mEffectPool.FastClear();
    }

    public void SetBuild(int wIndex, int t_index)
    {
        mBuilds[wIndex] = t_index;
    }
    public void SetEffect(int wIndex, FastStack<int> t_index)
    {
        mEffects[wIndex] = t_index;
    }

    public int GetTerritory(int windex)
    {
        return mTerritorys[windex];
    }

    public int GetBuild(int windex)
    {
        return mBuilds[windex];
    }

    public FastStack<int> GetEffect(int windex)
    {
        return mEffects[windex];
    }

    public int GetTerritory(ref Vec2Int world_l_pos)
    {
        int wx = world_l_pos.x % mWidth;
        int wy = world_l_pos.y % mHeight;
        if (wx < 0)
        {
            wx = mWidth + wx;
        }

        if (wy < 0)
        {
            wy = mHeight + wy;
        }
        int i = (mWidth - wx - 1) * mHeight + wy;
        return mTerritorys[i];
    }

    public int GetBuild(ref Vec2Int world_l_pos)
    {
        int wx = world_l_pos.x % mWidth;
        int wy = world_l_pos.y % mHeight;
        if (wx < 0)
        {
            wx = mWidth + wx;
        }

        if (wy < 0)
        {
            wy = mHeight + wy;
        }
        int i = (mWidth - wx - 1) * mHeight + wy;

        return mBuilds[i];
    }

    public void GetTerrintoryAndNeighbors(ref Vec2Int world_l_pos, ref int[] tIndexs, ref Vec2Int[] neighbor_pos)
    {
        if (tIndexs == null || tIndexs.Length != 9 || neighbor_pos.Length != 8)
            return;

        int wx = world_l_pos.x % mWidth;
        int wy = world_l_pos.y % mHeight;

        int lx = (mWidth - wx - 1) * mHeight;
        int ly = wy;
        int i = lx + ly;
        tIndexs[0] = mTerritorys[i];

        if (tIndexs[0] == 0)
        {
            return;
        }

        int x, y;
        x = lx - -1 * mHeight;
        y = ly;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[1] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[0].x = wx - 1;
            neighbor_pos[0].y = wy;
        }
        else
            tIndexs[1] = -1;

        x = lx - 1 * mHeight;
        y = ly;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[2] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[1].x = wx + 1;
            neighbor_pos[1].y = wy;
        }
        else
            tIndexs[2] = -1;
        x = lx;
        y = ly + 1;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[3] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[2].x = wx;
            neighbor_pos[2].y = wy + 1;
        }

        else
            tIndexs[3] = -1;
        x = lx;
        y = ly - 1;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[4] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[3].x = wx;
            neighbor_pos[3].y = wy - 1;
        }
        else
            tIndexs[4] = -1;
        x = lx - -1 * mHeight;
        y = ly + 1;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[5] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[4].x = wx - 1;
            neighbor_pos[4].y = wy + 1;
        }
        else
            tIndexs[5] = -1;
        x = lx - 1 * mHeight;
        y = ly + 1;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[6] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[5].x = wx + 1;
            neighbor_pos[5].y = wy + 1;
        }
        else
            tIndexs[6] = -1;

        x = lx - -1 * mHeight;
        y = ly - 1;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[7] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[6].x = wx - 1;
            neighbor_pos[6].y = wy - 1;
        }
        else
            tIndexs[7] = -1;

        x = lx - 1 * mHeight;
        y = ly - 1;
        i = x + y;
        if (i >= 0 && i < mCount)
        {
            tIndexs[8] = mTerritorys[i] == tIndexs[0] ? i : -1;
            neighbor_pos[7].x = wx + 1;
            neighbor_pos[7].y = wy - 1;
        }
        else
            tIndexs[8] = -1;
    }

    public void Destroy()
    {
        mTerritorys = null;
        mBuilds = null;
    }
}

public class LogicBlockMap
{
    private float mBlockSize;
    private int mWidthNum;
    private int mHeightNum;

    public float BlockSize { get { return mBlockSize; } }
    public int Width { get { return mWidthNum; } }
    public int Height { get { return mHeightNum; } }

    public LogicBlockMap(float block_size, int width, int height)
    {
        mBlockSize = block_size;
        mWidthNum = width;
        mHeightNum = height;
    }

    public static int Pos2Index(Vector3 wpos, float size, int w, int h)
    {
        int x = Mathf.FloorToInt(wpos.x / size);
        int z = Mathf.FloorToInt(wpos.z / size);

        int lx = x % w;
        int ly = z % h;
        if (x < 0)
        {
            x = w - lx;
        }
        else
            x = lx;

        if (z < 0)
        {
            z = h - ly;
        }
        else
            z = ly;

        return (w - x - 1) * h + z;
    }

    public void WorldPos2LogicPos(ref Vec2Int v2i)
    {
        int lx = v2i.x % mWidthNum;
        int ly = v2i.y % mHeightNum;
        if (lx < 0)
        {
            v2i.x = mWidthNum + lx;
        }
        else
            v2i.x = lx;

        if (ly < 0)
        {
            v2i.y = mHeightNum + ly;
        }
        else
            v2i.y = ly;
    }

    public Vec2Int WorldPos2LogicPos(int lx, int ly)
    {
        Vec2Int v2i = new Vec2Int();
        v2i.x = lx % mWidthNum;
        v2i.y = ly % mHeightNum;
        if (lx < 0)
        {
            v2i.x = mWidthNum + v2i.x;
        }

        if (ly < 0)
        {
            v2i.y = mHeightNum + v2i.y;
        }

        return v2i;
    }

    public void WorldPos2LogicPos(Vector3 pos, WorldData world, ref Vec2Int v2i)
    {
        float wposx = pos.x + world.HRValue.z;
        float wposy = pos.z + world.HRValue.w;
        v2i.x = Mathf.FloorToInt(wposx / mBlockSize);
        v2i.y = Mathf.FloorToInt(wposy / mBlockSize);
        int lx = v2i.x % mWidthNum;
        int ly = v2i.y % mHeightNum;
        if (lx < 0)
        {
            v2i.x = mWidthNum + lx;
        }
        else
            v2i.x = lx;

        if (ly < 0)
        {
            v2i.y = mHeightNum + ly;
        }
        else
            v2i.y = ly;
    }

    public Vec2Int WorldPos2LogicPos(Vector3 pos, WorldData world)
    {
        Vec2Int v2i = new Vec2Int();
        float wposx = pos.x + world.HRValue.z;
        float wposy = pos.z + world.HRValue.w;
        v2i.x = Mathf.FloorToInt(wposx / mBlockSize);
        v2i.y = Mathf.FloorToInt(wposy / mBlockSize);
        int lx = v2i.x % mWidthNum;
        int ly = v2i.y % mHeightNum;
        if (lx < 0)
        {
            v2i.x = mWidthNum + lx;
        }
        else
            v2i.x = lx;

        if (ly < 0)
        {
            v2i.y = mHeightNum + ly;
        }
        else
            v2i.y = ly;
        return v2i;
    }

    public Vec2Int WorldPos2WLogicPos(Vector3 pos, WorldData world)
    {
        Vec2Int v2i = new Vec2Int();
        float wposx = pos.x + world.HRValue.z;
        float wposy = pos.z + world.HRValue.w;
        v2i.x = Mathf.FloorToInt(wposx / mBlockSize - 0.5f);
        v2i.y = Mathf.FloorToInt(wposy / mBlockSize - 0.5f);
        return v2i;
    }

    public void WorldPos2WLogicPos(Vector3 pos, WorldData world, ref Vec2Int v2i)
    {
        float wposx = pos.x + world.HRValue.z;
        float wposy = pos.z + world.HRValue.w;
        v2i.x = Mathf.FloorToInt(wposx / mBlockSize - 0.5f);
        v2i.y = Mathf.FloorToInt(wposy / mBlockSize - 0.5f);
    }

    public void WLogicPos2WorldPos(ref Vector3 wpos, ref Vec2Int v2i, WorldData world)
    {
        wpos.x = Mathf.FloorToInt(v2i.x * mBlockSize) - world.HRValue.z;
        wpos.z = Mathf.FloorToInt(v2i.y * mBlockSize) - world.HRValue.z;
        wpos.x += mBlockSize * 0.5f;//0.335f;
        wpos.z += mBlockSize * 0.5f;//0.335f;
    }

    public void WLogicPos2WorldPos(ref Vector3 wpos, int wx, int wy, WorldData world)
    {
        wpos.x = Mathf.FloorToInt(wx * mBlockSize) - world.HRValue.z;
        wpos.z = Mathf.FloorToInt(wy * mBlockSize) - world.HRValue.z;
        wpos.x += mBlockSize * 0.5f;//0.335f;
        wpos.z += mBlockSize * 0.5f;//0.335f;
    }

    public void LogicPos2WScale(int x, int y, ref Vec2Int scale)
    {
        scale.x = x / mWidthNum;
        if (x < 0)
        {
            scale.x -= 1;
        }
        scale.y = y / mHeightNum;
        if (y < 0)
        {
            scale.y -= 1;
        }
    }

    public int LogicPos2Index(int x, int y)
    {
        int lx = x % mWidthNum;
        int ly = y % mHeightNum;
        if (x < 0)
        {
            x = mWidthNum - lx;
        }
        else
            x = lx;

        if (y < 0)
        {
            y = mHeightNum - ly;
        }
        else
            y = ly;
        return (mWidthNum - x - 1) * mHeightNum + y;
    }

    public void Destroy()
    {
    }
}

public class LogicBlockTool
{
    public static float GetTerrainHeight(Vector3 wpos, float w, float h, int hmw, int hmh, float maxh, Color[] hm_colors)
    {
        Vector2 uv = Vector2.zero;
        uv.x = wpos.x / w;
        uv.y = wpos.z / h;
        int px = Mathf.Min(hmw - 1, (int)((1 - uv.x) * hmw));
        int py = Mathf.Min(hmh - 1, (int)((1 - uv.y) * hmh));
        int h_index = (hmw - px - 1) * hmh + py;
        Color hs_center = hm_colors[h_index];
        return hs_center.r * maxh;
    }

    public static int[] GenerateTerrainTags(Terrain tr, WorldData world, Texture2D hm, Vector2 obstacle_range)
    {
        int wc = world.LogicWCount;
        int hc = world.LogicHCount;
        float maxh = tr.terrainData.size.y;
        float block_size = world.LogicBlockSize;
        Color[] hm_colors = hm.GetPixels();
        int hmw = hm.width;
        int hmh = hm.height;
        float w = tr.terrainData.size.x;
        float h = tr.terrainData.size.z;
        //int wc = Mathf.FloorToInt(w/block_size);
        //int hc = Mathf.FloorToInt(h/block_size);
        int[] tags = new int[wc * hc];
        int index = 0;
        for (int x = 0; x < wc; x++)
        {
            for (int y = 0; y < hc; y++)
            {
                index = (wc - x - 1) * hc + y;
                //Vector3 wpos = new Vector3((x * block_size + block_size * 0.5f), 0, (y * block_size + block_size * 0.5f));//
                //Vector2 uv = Vector2.zero;
                //uv.x = wpos.x / w;
                //uv.y = wpos.z / h;
                //int px = (int)((1 - uv.x) * hmw);
                //int py = (int)((1 - uv.y) * hmh);
                //int h_index = (hmw - px - 1) * hmh + py;
                //Color hs_center = hm_colors[h_index];
                //float hh = hs_center.r * maxh;
                //if (hh <= obstacle_range.x)
                //{
                //    tags[index] |= (int)LogicBlockType.LBT_OBSTACLE_L;
                //}
                //else
                //if (hh > obstacle_range.y)
                //    tags[index] |= (int)LogicBlockType.LBT_OBSTACLE_H;
                //else
                //    tags[index] = 0;
                Vector3 cp = new Vector3((x * block_size + block_size * 0.5f), 0, (y * block_size + block_size * 0.5f));
                float ph = GetTerrainHeight(cp, w, h, hmw, hmh, maxh, hm_colors);
                if (ph <= obstacle_range.x)
                {
                    tags[index] |= (int)LogicBlockType.LBT_OBSTACLE_L;
                    continue;
                }

                Vector3 p1 = new Vector3((x * block_size + 0), 0, (y * block_size + 0));
                float ph1 = GetTerrainHeight(p1, w, h, hmw, hmh, maxh, hm_colors);
                Vector3 p2 = new Vector3((x * block_size + 0), 0, (y * block_size + block_size - 1));
                float ph2 = GetTerrainHeight(p2, w, h, hmw, hmh, maxh, hm_colors);
                Vector3 p3 = new Vector3((x * block_size + block_size - 1), 0, (y * block_size + block_size - 1));
                float ph3 = GetTerrainHeight(p3, w, h, hmw, hmh, maxh, hm_colors);
                Vector3 p4 = new Vector3((x * block_size + block_size - 1), 0, (y * block_size + 0));
                float ph4 = GetTerrainHeight(p4, w, h, hmw, hmh, maxh, hm_colors);


                if (Mathf.Abs(ph1 - ph2) > obstacle_range.y ||
                    Mathf.Abs(ph1 - ph3) > obstacle_range.y ||
                    Mathf.Abs(ph1 - ph4) > obstacle_range.y ||
                    Mathf.Abs(ph2 - ph3) > obstacle_range.y ||
                    Mathf.Abs(ph2 - ph4) > obstacle_range.y ||
                    Mathf.Abs(ph3 - ph4) > obstacle_range.y)
                {
                    tags[index] |= (int)LogicBlockType.LBT_OBSTACLE_H;
                    continue;
                }

                tags[index] = 0;
            }
        }
        return tags;
    }
}
