using UnityEngine;
using System.Collections;

public class WorldMapTerritory
{
    World world;
    int width;
    int height;
    int size;
    Vec2Int tmp = new Vec2Int();
    Vec2Int Itmp2 = new Vec2Int();
    Vector3 tmp3 = Vector3.zero;
    public BuildState buildState;
    private static int[] mEmptyBlockBorder = new int[9];
    private static Color mDefaultBorderColor = Color.white;
    int[] mTmpBlockBorder = new int[9];
    int[] mTmpBlockBorderBox = new int[8];
    int[] neighbors = new int[9];
    Vec2Int[] neighborPos = new Vec2Int[8];
    int[] tmpneighbors = new int[9];
    Vec2Int[] tmpneighborPos = new Vec2Int[8];
    Serclimax.ScUnionBadgeColorData[] scUnionBadgeColorData;
    int type;
    private TerrainBorderMarkerBox mMarkerBox;
    public TerrainBorderMarkerBox MarkerBox { get { return mMarkerBox; } }

    public void Init(int w, int h, int s, World wld)
    {
        world = wld;
        width = w;
        size = s;
        height = h;
        scUnionBadgeColorData = Main.Instance.GetTableMgr().GetUnionBadgeColorList();
        mMarkerBox = new TerrainBorderMarkerBox(width, height, world.WorldInfo.LogicBlockSize);
    }

    public void Clears()
    {
        MarkerBox.Clear();
        world.ApplySMC();
    }

    private void RefrushTerritoryBox()
    {
        int x, y, wx, wy, index, blockX, blockY, lindex;
        for (int i = 0; i < width * height; i++)
        {

            blockX = i % width;
            blockY = i / width;
            x = (int)world.worldMapUpdata.CurRect.MinX + blockX;
            y = (int)world.worldMapUpdata.CurRect.MinY + blockY;
            //将带负的转换到 0-512
            wx = x % size;
            if (wx < 0)
                wx = size + wx;
            wy = y % size;
            if (wy < 0)
            {
                wy = size + wy;
            }
            lindex = (size - wx - 1) * size + wy;
            index = (width - blockX - 1) * height + blockY;
            UpdateTerritoryBox(x, y, index, lindex);
            //mapTerritory.UpdateTerritory(x, y, index, lindex);
        }
        world.WorldInfo.BoxDrawer.Apply();
    }


    public void UpdateTerritory()
    {
        switch (buildState)
        {
            case BuildState.Start:
                Clears();                
                buildState = BuildState.Build;
                break;
            case BuildState.Build:
                RefrushTerritoryBox();
                buildState = BuildState.End;
                break;
            case BuildState.End:
                buildState = BuildState.Normal;
                break;
            default:
                break;
        }
    }

    private static readonly int[] _BlockBorderBoxs = new int[]{1,8,7,
                                                               2,  6,
                                                               3,4,5};
    void SetTerritoryBox(int wposx, int wposy, int index, int type, Color c)
    {
        int wx = wposx % world.WorldInfo.LogicServerSizeX;
        if (wx < 0)
            wx = world.WorldInfo.LogicServerSizeX + wx;
        int wy = wposy % world.WorldInfo.LogicServerSizeY;
        if (wy < 0)
        {
            wy = world.WorldInfo.LogicServerSizeY + wy;
        }
        tmp.x = wposx;
        tmp.y = wposy;
        world.WorldInfo.WBlockMap.GetTerrintoryAndNeighbors(ref tmp, ref neighbors, ref neighborPos);
        ExprotBorderBox(ref neighbors, ref mTmpBlockBorderBox);
        int minx = (int)world.worldMapUpdata.CurRect.MinX % world.WorldInfo.LogicServerSizeX;
        int miny = (int)world.worldMapUpdata.CurRect.MinY % world.WorldInfo.LogicServerSizeY;
        tmp.x = wposx % world.WorldInfo.LogicServerSizeX - minx;
        tmp.y = wposy % world.WorldInfo.LogicServerSizeY - miny;
        world.WorldInfo.LBlockMap.WLogicPos2WorldPos(ref tmp3, (int)world.worldMapUpdata.CurRect.MinX, (int)world.worldMapUpdata.CurRect.MinY, world.WorldInfo);
        mMarkerBox.Set(tmp, tmp3, mTmpBlockBorderBox, c);
        WorldMapMgr.Instance.world.TerritoryHUD.InitializeHUD(WorldHUDType.TERRITORY, wy * world.WorldInfo.LogicServerSizeY + wx);
    }

    public void UpdateTerritoryBox(int x, int y, int index, int lindex)
    {
        type = world.WorldInfo.WBlockMap.GetTerritory(lindex);

        if (x < 0 || x > 511 || y < 0 || y > 511)
            return;
        if (type > 0)
        {
            for (int i = 0; i < scUnionBadgeColorData.Length; i++)
            {
                if (scUnionBadgeColorData[i].id == (world.WorldInfo.WBlockMap.GetTerritory(lindex) & 0xff))
                {
                    SetTerritoryBox(x, y, index, type, NGUIText.ParseColor24(scUnionBadgeColorData[i].color2, 0));
                    break;
                }
            }
        }

    }

    void ExprotBorderBox(ref int[] neighbors, ref int[] border)
    {
        if (neighbors[0] == 0)
            return;

        for (int i = 0; i < 8; i++)
        {
            border[i] = 0;
        }

        // 左
        if (neighbors[3] < 0)
        {
            border[0] = 2;
            border[3] = 2;
            border[5] = 2;
        }

        // 右
        if (neighbors[4] < 0)
        {
            border[2] = 6;
            border[4] = 6;
            border[7] = 6;
        }

        // 上
        if (neighbors[1] < 0)
        {
            if (border[0] != 0)
                border[0] = 1;
            else
                border[0] = 8;
            border[1] = 8;
            if (border[2] != 0)
                border[2] = 7;
            else
                border[2] = 8;
        }
        // 下
        if (neighbors[2] < 0)
        {
            if (border[5] != 0)
                border[5] = 3;
            else
                border[5] = 4;
            border[6] = 4;
            if (border[7] != 0)
                border[7] = 5;
            else
                border[7] = 4;
        }

        if (neighbors[3] >= 0 && neighbors[1] >= 0 && neighbors[5] < 0)
        {
            border[0] = 13;
        }
        if (neighbors[3] >= 0 && neighbors[2] >= 0 && neighbors[6] < 0)
        {
            border[5] = 15;
        }
        if (neighbors[4] >= 0 && neighbors[2] >= 0 && neighbors[8] < 0)
        {
            border[7] = 9;
        }
        if (neighbors[4] >= 0 && neighbors[1] >= 0 && neighbors[7] < 0)
        {
            border[2] = 11;
        }
    }
}
