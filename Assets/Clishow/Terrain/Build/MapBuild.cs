using UnityEngine;
using System.Collections;

public class MapBuild {
    
    public World world;
    public int width;
    public int height;

    private SMCInfo[] mCacheBuilds;
    private SMCInfo[] cacheBuilds;
    private SMCInfo mTmpSmcInfo;
    private Vec2Int tmp = new Vec2Int();
    private Vector3 tmpVec3 = Vector3.zero;
    int type;
    public void Init(int w, int h, World wld) {
        world = wld;
        width = w;
        height = h;
        mCacheBuilds = new SMCInfo[width * height];
        cacheBuilds = new SMCInfo[width * height];
    }

    public void ClearView(){
        System.Array.Clear(cacheBuilds, 0, cacheBuilds.Length);
        for (int i = 0; i < mCacheBuilds.Length; i++)
        {
            if (mCacheBuilds[i] != null)
            {
                if (!WorldData.RectContainsGreater(world.worldMapUpdata.CurRect, mCacheBuilds[i].wPosX, mCacheBuilds[i].wPosY))
                {
                    ClearBuildCache(i);
                    
                }
                else
                {
                    int blockX, blockY, index;
                    blockX = mCacheBuilds[i].wPosX - (int)world.worldMapUpdata.CurRect.MinX;
                    blockY = mCacheBuilds[i].wPosY - (int)world.worldMapUpdata.CurRect.MinY;
                    if (blockX < width && blockY < height)
                    {
                        index = (width - blockX - 1) * height + blockY;
                        cacheBuilds[index] = mCacheBuilds[i];
                    }
                    else
                    {
                        ClearBuildCache(i);
                    }
                }
            }
        }
        System.Array.Copy(cacheBuilds, mCacheBuilds, mCacheBuilds.Length);
    }

    public void UpdateBuild(int x, int y, int index, int lindex) {
        type = world.WorldInfo.WBlockMap.GetBuild(lindex);
        if (type > 0)
        {
            if (mCacheBuilds[index] != null)
            {
                if (mCacheBuilds[index].smc_id != type)
                {
                    ClearBuildCache(index);
                    SetBuild(x, y, index, lindex);
                    world.worldMapUpdata.worldMapBuild.updateCounts++;
                    if (world.worldMapUpdata.worldMapBuild.updateCounts >= 5)
                    world.worldMapUpdata.worldMapBuild.isBack = true;
                }
                else
                {
                    //if (WorldMapMgr.Instance.OnUpdateBuildEvent != null)
                    //    WorldMapMgr.Instance.OnUpdateBuildEvent(x, y);

                    //将带负的转换到 0-512
                    int wx = x % world.WorldInfo.LogicServerSizeX;
                    if (wx < 0)
                        wx = world.WorldInfo.LogicServerSizeX + wx;
                    int wy = y % world.WorldInfo.LogicServerSizeY;
                    if (wy < 0)
                    {
                        wy = world.WorldInfo.LogicServerSizeY + wy;
                    }
                    mCacheBuilds[index].HUD.RefreshHUD(WorldHUDType.BUILDING, wy * world.WorldInfo.LogicServerSizeY + wx);
                }

            }
            else
            {
                SetBuild(x, y, index, lindex);
                world.worldMapUpdata.worldMapBuild.updateCounts++;
                if (world.worldMapUpdata.worldMapBuild.updateCounts >= 5)
                world.worldMapUpdata.worldMapBuild.isBack = true;
            }

        }

        if (type == 0)
        {
            ClearBuildCache(index);
        }
    }

    public void SetBuild(int x, int y, int index, int lindex)
    {
        //将带负的转换到 0-512
        int wx = x % world.WorldInfo.LogicServerSizeX;
        if (wx < 0)
            wx = world.WorldInfo.LogicServerSizeX + wx;
        int wy = y % world.WorldInfo.LogicServerSizeY;
        if (wy < 0)
        {
            wy = world.WorldInfo.LogicServerSizeY + wy;
        }
        int type = world.WorldInfo.WBlockMap.GetBuild(lindex);
        if (type == 0)
            return;
        tmpVec3.x = Mathf.FloorToInt(x * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.y = 0;
        tmpVec3.z = Mathf.FloorToInt(y * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        //tmpVec3 = world.WorldInfo.world.World2TerrainPos(tmpVec3);
        int ic = 0;
        int ip = 0;
        if (type > 0 && type < 10000)
        {
            ic = world.worldMapUpdata.GetNumberPos(type, 3) * 10 + world.worldMapUpdata.GetNumberPos(type, 2);
            ip = world.worldMapUpdata.GetNumberPos(type, 1) * 10 + world.worldMapUpdata.GetNumberPos(type, 0);
            tmpVec3.x += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
            tmpVec3.y = world.Build_Offset_Height;
            tmpVec3.z += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
            mCacheBuilds[index] = world.WorldInfo.world.SMC[ic - 1].Push(ip, tmpVec3, WorldHUDType.BUILDING, wy * world.WorldInfo.LogicServerSizeY + wx);
        }
        else
        {
            ic = world.worldMapUpdata.GetNumberPos(type, 3)*10 + world.worldMapUpdata.GetNumberPos(type, 2);
            ip = world.worldMapUpdata.GetNumberPos(type, 1) * 10 + world.worldMapUpdata.GetNumberPos(type, 0);
            int multiSizeX = world.worldMapUpdata.GetNumberPos(type, 7);
            int multiSizeY = world.worldMapUpdata.GetNumberPos(type, 6);
            int multiX = world.worldMapUpdata.GetNumberPos(type, 5);
            int multiY = world.worldMapUpdata.GetNumberPos(type, 4);
            if (multiX == 0 && multiY == 0)
            {
                tmpVec3.x += world.WorldInfo.LBlockMap.BlockSize * (0.5f + 0.5f * (multiSizeX - 1));
                tmpVec3.y = world.Build_Offset_Height;
                tmpVec3.z += world.WorldInfo.LBlockMap.BlockSize * (0.5f + 0.5f * (multiSizeY - 1));
                
                mCacheBuilds[index] = world.WorldInfo.world.SMC[ic - 1].Push(ip, tmpVec3, WorldHUDType.BUILDING, wy * world.WorldInfo.LogicServerSizeY + wx);
            }
            //else
            //{
            //    mCacheBuilds[index] = new SMCInfo();
            //}
            if (mCacheBuilds[index] != null)
            {
                mCacheBuilds[index].IsMulit = true;
                mCacheBuilds[index].CenterWPos = tmpVec3;
                mCacheBuilds[index].mX = multiX;
                mCacheBuilds[index].mY = multiY;
            }
        }
        if (mCacheBuilds[index] != null)
        {
            mCacheBuilds[index].smc_id = type;
            mCacheBuilds[index].wPosX = x;
            mCacheBuilds[index].wPosY = y;
            //if (WorldMapMgr.Instance.OnUpdateBuildEvent != null)
            //    WorldMapMgr.Instance.OnUpdateBuildEvent(x, y);
        }


    }

    public Transform GetCacheBuildTrf(int lindex)
    {
        mTmpSmcInfo = mCacheBuilds[lindex];
        if (mTmpSmcInfo != null)
        {
            //if (mTmpSmcInfo.mX != 0 && mTmpSmcInfo.mY != 0)
            {
                return mTmpSmcInfo.trf;
            }
            return null;
        }
        return null;
    }

    public SMCInfo GetCacheBuildSMCInfo(int lindex)
    {
        mTmpSmcInfo = mCacheBuilds[lindex];
        if (mTmpSmcInfo != null)
        {
            //if (mTmpSmcInfo.mX != 0 && mTmpSmcInfo.mY != 0)
            {
                return mTmpSmcInfo;
            }
            return null;
        }
        return null;
    }

    public void ClearBuildCache(int lindex)
    {
        mTmpSmcInfo = mCacheBuilds[lindex];
        if (mTmpSmcInfo != null)
        {
            if (mTmpSmcInfo.mX != 0 && mTmpSmcInfo.mY != 0)
            {
                mCacheBuilds[lindex] = null;
                return;
            }
            int ic = world.worldMapUpdata.GetNumberPos(mTmpSmcInfo.smc_id, 3) * 10 + world.worldMapUpdata.GetNumberPos(mTmpSmcInfo.smc_id, 2);
            world.WorldInfo.world.SMC[ic - 1].Pop(mTmpSmcInfo);
        }
        mCacheBuilds[lindex] = null;

    }


    //public void UpdateBuildUIOnMove()
    //{
    //    if (WorldMapMgr.Instance.OnUpdateBuildStart != null)
    //        WorldMapMgr.Instance.OnUpdateBuildStart();

    //    for(int i =0;i<mCacheBuilds.Length;i++)
    //    {
    //        if(mCacheBuilds[i] != null)
    //        {
    //            if (WorldMapMgr.Instance.OnUpdateBuildEvent != null)
    //                WorldMapMgr.Instance.OnUpdateBuildEvent(mCacheBuilds[i].wPosX,mCacheBuilds[i].wPosY);
    //        }
    //    }

    //    if (WorldMapMgr.Instance.OnUpdateBuildEnd != null)
    //        WorldMapMgr.Instance.OnUpdateBuildEnd();
    //}
}
