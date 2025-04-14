using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class WorldMapBuild
{

    public Vec2Int StartPos;
    public World world;
    public int width;
    public int height;
    public int offetHeight;
    public BuildState buildState;

    MapBuild mapBuild = new MapBuild();
    MapBuildEffect mapBuildEffect = new MapBuildEffect();

    private int lindex;
    public int size;
    //int[] OldIndex = null; //记录上一次缓存池索引
    int updateCount = 0;
    public int count = 0;
    public int updateCounts = 0;
    public bool isBack = false;

    public void Init(World w)
    {
        width = WorldMapMgr.Instance.worldCamera.ViewWidth;
        height = WorldMapMgr.Instance.worldCamera.ViewHeight;
        offetHeight = WorldMapMgr.Instance.worldCamera.offetHeight;
        world = w;
        buildState = BuildState.Normal;
        size = world.WorldInfo.LogicServerSizeX;//(int)world.WorldInfo.heighRange.width;

        mapBuild.Init(width, height, world);
        mapBuildEffect.Init(world);
    }


    void ClearView()
    {
        StartPos.x = (int)world.worldMapUpdata.CurRect.MinX;
        StartPos.y = (int)world.worldMapUpdata.CurRect.MinY;

        mapBuild.ClearView();
        mapBuildEffect.ClearView();
        updateCount = 0;
        buildState = BuildState.Build;
    }

    public void UpdateBuild()
    {
        switch (buildState)
        {
            case BuildState.Start:
                ClearView();
                world.WorldInfo.HideAllSpriteForBuild(ref WorldMapMgr.Instance.worldCamera.WCurdRect);
                break;
            case BuildState.Build:
                Builds(); 
                break;
            case BuildState.End:
                buildState = BuildState.Normal;
                break;
            default:
                break;
        }
    }

    private Vec2Int BuildStartPos;
    public Transform GetCacheBuildTrf(int x, int y,int sw,int sh)
    {
        int wx, wy;
        wx = x % size;
        if (wx < 0)
            wx = size + wx;
        wy = y % size;
        if (wy < 0)
        {
            wy = size + wy;
        }
        int lx =(wx - (BuildStartPos.x + sw));
        int ly =(wy - (BuildStartPos.y+sh));
        if (lx < 0||ly<0||lx>=width||ly>=height)
            return null;
        int index = (width - lx - 1) * height + ly;
        if(index < 0 || index >= width*height)
            return null;
        return mapBuild.GetCacheBuildTrf(index);
    }

    public SMCInfo GetCacheBuildSMCInfo(int x, int y) {
        int wx, wy;
        wx = x % size;
        if (wx < 0)
            wx = size + wx;
        wy = y % size;
        if (wy < 0)
        {
            wy = size + wy;
        }
        int lx = wx - StartPos.x;
        int ly = wy - StartPos.y;
        if (lx < 0 || ly < 0 || lx >= width || ly >= height)
            return null;
        int index = (width - lx - 1) * height + ly;
        if (index < 0 || index >= width * height)
            return null;
        return mapBuild.GetCacheBuildSMCInfo(index);
    }



    public void Builds()
    {
        isBack = false;
        updateCounts = 0;
        BuildStartPos.x = StartPos.x;
        BuildStartPos.y = StartPos.y;
        for (int i = updateCount; i < width * height; i++)
        {
            int x, y, wx, wy, index, blockX, blockY;
            blockX = i % width;
            blockY = i / width;

            x = StartPos.x + blockX;
            y = StartPos.y + blockY;
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
            mapBuild.UpdateBuild(x, y, index, lindex);
            mapBuildEffect.UpdateBuildEffect(x, y, lindex);

            if (updateCount == (width * height - 1))
            {
                buildState = BuildState.End;
                world.ApplySMC();

                world.WorldInfo.UpdateAllSpritesMesh();
            }
            updateCount++;
            if (isBack)
                break;
        }
    }
}