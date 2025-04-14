using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax;

public class WorldMapAircraft
{

    public Vec2Int StartPos;
    public Vec2Int EndPos;
    public World world;
    public int width;
    public int height;
    public int offetHeight;
    public BuildState buildState;

    private SMCInfo[] mCacheBuilds;
    private SMCInfo mTmpSmcInfo;
    private int size;


    public List<Aircraft> Aircrafts = new List<Aircraft>();
    public List<TLine> Tlines = new List<TLine>();

    public void Init(World w)
    {
        world = w;
        buildState = BuildState.Normal;
        size = (int)world.WorldInfo.heighRange.width;
        mCacheBuilds = new SMCInfo[width * height];
        width = WorldMapMgr.Instance.worldCamera.width;
        height = WorldMapMgr.Instance.worldCamera.height;
        offetHeight = WorldMapMgr.Instance.worldCamera.offetHeight;
    }

    public void UpdateAircraft()
    {
        switch (buildState)
        {
            case BuildState.Start:
                buildState = BuildState.Build;
                break;
            case BuildState.Build:
                DrawAircraft();
                break;
            case BuildState.End:
                buildState = BuildState.Normal;
                break;
            default:
                break;
        }
    }

    public void Aircraft()
    {
        bool isHave = false;
        //清除老飞机
        for (int x = Tlines.Count - 1; x >= 0; x--)
        {
            isHave = false;
            for (int i = Aircrafts.Count - 1; i >= 0; i--)
            {
                if (Tlines[x].Trail.AircraftId == Aircrafts[i].sEntryPathInfo.pathId
                    && Tlines[x].Trail.mStatus == Aircrafts[i].sEntryPathInfo.status
                    && Tlines[x].Trail.mTotalTime == Aircrafts[i].sEntryPathInfo.time
                    && Tlines[x].LineColor == Aircrafts[i].color)
                {
                    isHave = true;
                }
            }
            if (!isHave)
            {
                world.WorldInfo.RemoveLine(Tlines[x]);
                Tlines.Remove(Tlines[x]);
            }
        }
        buildState = BuildState.Start;
    }

    public void DrawAircraft()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (Aircrafts.Count <= 0)
        {
            WorldMapMgr.Instance.ClearLine();
            return;
        }

        bool isHave = false;

        for (int i = Aircrafts.Count - 1; i >= 0; i--)
        {
            //判斷是否是同一個飞机
            isHave = false;
            for (int x = Tlines.Count - 1; x >= 0; x--)
            {
                if (Tlines[x].Trail.AircraftId == Aircrafts[i].sEntryPathInfo.pathId
                    && Tlines[x].Trail.mStatus == Aircrafts[i].sEntryPathInfo.status
                    && Tlines[x].Trail.mTotalTime == Aircrafts[i].sEntryPathInfo.time)
                {
                    isHave = true;
                }
                //if (Tlines[x].Trail.AircraftId == Aircrafts[i].sEntryPathInfo.pathId && (Tlines[x].Trail.mStatus != Aircrafts[i].sEntryPathInfo.status || Tlines[x].Trail.mTotalTime != Aircrafts[i].sEntryPathInfo.time))
                //{
                //    world.WorldInfo.RemoveLine(Tlines[x]);
                //    Tlines.Remove(Tlines[x]);
                //}
            }
            if (isHave)
            {
                //Aircrafts.Remove(Aircrafts[i]);
                continue;
            }
            //判斷是否开启飞机
            //if((int)Serclimax.GameTime.GetSecTime() - Aircrafts[i].startTime < 0)
            //    continue;
            if (Aircrafts[i] == null)
                continue;

            Vector3 StartPos = WorldMapMgr.Instance.GetCurPosToWorldPos(Aircrafts[i].startPosX, Aircrafts[i].startPosY, 12.5f);
            Vector3 EndPos = WorldMapMgr.Instance.GetCurPosToWorldPos(Aircrafts[i].endPosX, Aircrafts[i].endPosY, 12.5f);
            Vec2Int targetPos = new Vec2Int();
            targetPos.x = Aircrafts[i].endPosX;
            targetPos.y = Aircrafts[i].endPosY;
            //StartPos = world.World2TerrainPos(StartPos);
            //EndPos = world.World2TerrainPos(EndPos);
            bool isEffect = false;
            int id = 0;
            //Serclimax.ScMapBuildingData tileData;
            bool isSourcePosSelf = true;
            ProtoMsg.TeamMoveType tmt = (ProtoMsg.TeamMoveType)Aircrafts[i].sEntryPathInfo.pathType;
            if (WorldMapMgr.instance.enable_hot_fixed_debug)
            {
                switch (tmt)
                {
                    case ProtoMsg.TeamMoveType.TeamMoveType_ResTransport:       //资源运输
                    case ProtoMsg.TeamMoveType.TeamMoveType_ResTake:            //资源采集(运输机)
                    case ProtoMsg.TeamMoveType.TeamMoveType_MineTake:           //超级矿采集
                        tmt = ProtoMsg.TeamMoveType.TeamMoveType_None;
                        break;
                }
            }
            switch (tmt)
            {
                case ProtoMsg.TeamMoveType.TeamMoveType_ResTransport:       //资源运输
                case ProtoMsg.TeamMoveType.TeamMoveType_ResTake:            //资源采集(运输机)
                case ProtoMsg.TeamMoveType.TeamMoveType_MineTake:           //超级矿采集
                    if (Aircrafts[i].sEntryPathInfo.govtOfficial == 1)
                        id = 8;
                    else
                        id = 2;
                    break;

                case ProtoMsg.TeamMoveType.TeamMoveType_GatherCall:         //发起集结(去大飞机，回小飞机)
                    if ((ProtoMsg.PathMoveStatus)Aircrafts[i].sEntryPathInfo.status == ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    {
                        id = 1;
                    }
                    else if ((ProtoMsg.PathMoveStatus)Aircrafts[i].sEntryPathInfo.status == ProtoMsg.PathMoveStatus.PathMoveStatus_Back)
                    {
                        if (Aircrafts[i].sEntryPathInfo.govtOfficial == 1)
                            id = 6;
                        else
                            id = 0;
                    }
                    break;
                case ProtoMsg.TeamMoveType.TeamMoveType_TrainField:         //训练场(战斗机)
                case ProtoMsg.TeamMoveType.TeamMoveType_Garrison:           //驻防
                case ProtoMsg.TeamMoveType.TeamMoveType_GatherRespond:      //响应集结
                case ProtoMsg.TeamMoveType.TeamMoveType_AttackMonster:      //攻击怪
                case ProtoMsg.TeamMoveType.TeamMoveType_AttackPlayer:       //攻击玩家
                case ProtoMsg.TeamMoveType.TeamMoveType_Camp:               //扎营
                case ProtoMsg.TeamMoveType.TeamMoveType_Occupy:             //占领      
                    if (Aircrafts[i].sEntryPathInfo.govtOfficial == 1)
                        id = 6;
                    else
                        id = 0;
                    break;
                case ProtoMsg.TeamMoveType.TeamMoveType_ReconPlayer:        //侦查玩家(侦察机)
                case ProtoMsg.TeamMoveType.TeamMoveType_ReconMonster:       //侦查怪物
                    if (Aircrafts[i].sEntryPathInfo.govtOfficial == 1)
                        id = 7;
                    else
                        id = 3;
                    break;
                case ProtoMsg.TeamMoveType.TeamMoveType_Prisoner:             //监狱
                case ProtoMsg.TeamMoveType.TeamMoveType_GuildCompensate:
                    id = 9;
                    break;
                case ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege:    //怪物攻城      
                    isSourcePosSelf = false;
                    switch ((ProtoMsg.PathPlaneType)Aircrafts[i].sEntryPathInfo.planeType)
                    {
                        case ProtoMsg.PathPlaneType.PathPlaneType_SiegeBig:
                            id = 4;
                            break;
                        case ProtoMsg.PathPlaneType.PathPlaneType_SiegeNomal:
                            id = 5;
                            break;
                    }
                    break;
                case ProtoMsg.TeamMoveType.TeamMoveType_GarrisonCenterBuild:    //下面是以前的default
                case ProtoMsg.TeamMoveType.TeamMoveType_GuildBuildCreate:
                case ProtoMsg.TeamMoveType.TeamMoveType_AttackFort:
                case ProtoMsg.TeamMoveType.TeamMoveType_AttackCenterBuild:
                case ProtoMsg.TeamMoveType.TeamMoveType_Nemesis:
                case ProtoMsg.TeamMoveType.TeamMoveType_MobaGarrisonBuild:
                case ProtoMsg.TeamMoveType.TeamMoveType_MobaAtkBuild:
                case ProtoMsg.TeamMoveType.TeamMoveType_AttackWorldCity:
                    if (Aircrafts[i].sEntryPathInfo.govtOfficial == 1)
                        id = 6;
                    break;
                default:
                    Debug.Log("Lua "+(ProtoMsg.TeamMoveType)Aircrafts[i].sEntryPathInfo.pathType);

                    object[] objects = LuaClient.GetMainState().GetFunction("WorldMapHUD.SetExpeditionID").Call((int)Aircrafts[i].sEntryPathInfo.pathType,
                        Aircrafts[i].sEntryPathInfo.pathId);
                    id = (int)(double)objects[0];
                    Aircrafts[i].color = (Color)objects[1];
                    isEffect = (bool)objects[2];
                    if (id == 0)
                    {
                        if (Aircrafts[i].sEntryPathInfo.govtOfficial == 1)
                            id = 6;
                    }
                    break;
            }
            //多格建筑处理中心点
            if (Aircrafts[i].sEntryPathInfo.status == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
            {
                if (Aircrafts[i].sEntryPathInfo.posblockid != 0)
                {
                    ScObjectShapeData shapeData = Main.Instance.TableMgr.GetObjectShapeData((int)Aircrafts[i].sEntryPathInfo.posblockid);
                    int x = shapeData.xMax - shapeData.xMin;
                    int y = shapeData.yMax - shapeData.yMin;
                    if (shapeData.xMin < 0)
                        x = x + shapeData.xMin * 2;
                    if (shapeData.yMin < 0)
                        y = y + shapeData.yMin * 2;
                    if (isSourcePosSelf)
                    {
                        EndPos.x = EndPos.x + (uint)(WorldMapNet.ServerBlockSize * ((x) * 0.5f));
                        EndPos.z = EndPos.z + (uint)(WorldMapNet.ServerBlockSize * ((y) * 0.5f));
                    }
                    else
                    {
                        StartPos.x = StartPos.x + (uint)(WorldMapNet.ServerBlockSize * ((x) * 0.5f));
                        StartPos.z = StartPos.z + (uint)(WorldMapNet.ServerBlockSize * ((y) * 0.5f));
                    }
                }
            }
            else
            {
                if (Aircrafts[i].sEntryPathInfo.posblockid != 0)
                {
                    ScObjectShapeData shapeData = Main.Instance.TableMgr.GetObjectShapeData((int)Aircrafts[i].sEntryPathInfo.posblockid);
                    int x = shapeData.xMax - shapeData.xMin;
                    int y = shapeData.yMax - shapeData.yMin;
                    if (shapeData.xMin < 0)
                        x = x + shapeData.xMin * 2;
                    if (shapeData.yMin < 0)
                        y = y + shapeData.yMin * 2;
                    if (isSourcePosSelf)
                    {
                        StartPos.x = StartPos.x + (uint)(WorldMapNet.ServerBlockSize * ((x) * 0.5f));
                        StartPos.z = StartPos.z + (uint)(WorldMapNet.ServerBlockSize * ((y) * 0.5f));
                    }
                    else
                    {
                        EndPos.x = EndPos.x + (uint)(WorldMapNet.ServerBlockSize * ((x) * 0.5f));
                        EndPos.z = EndPos.z + (uint)(WorldMapNet.ServerBlockSize * ((y) * 0.5f));
                    }
                }
            }
            float speed = ((EndPos - StartPos).magnitude / Mathf.Max(0.1f, Aircrafts[i].sEntryPathInfo.time));
            speed = Mathf.Min(1, speed / 20.0f) * 15;
            TLine t = world.WorldInfo.AddLine((int)Aircrafts[i].sEntryPathInfo.pathId, StartPos, EndPos, targetPos, Aircrafts[i].color, speed, id, (int)Aircrafts[i].sEntryPathInfo.pathType, Aircrafts[i].sEntryPathInfo.status, (int)Aircrafts[i].sEntryPathInfo.tarEntryType, (int)Serclimax.GameTime.GetSecTime(), (int)Aircrafts[i].sEntryPathInfo.starttime, (int)Aircrafts[i].sEntryPathInfo.time, isEffect);
            Tlines.Add(t);
        }

        world.WorldInfo.ApplyLine();
        Aircrafts.Clear();
        buildState = BuildState.End;
    }

    int WToL512(int x)
    {
        //将带负的转换到 0-32
        int lx = x % world.WorldInfo.LogicServerSizeX;
        if (lx < 0)
            lx = world.WorldInfo.LogicServerSizeX + lx;
        return lx;
    }
}

public class Aircraft
{
    public ProtoMsg.SEntryPathInfo sEntryPathInfo;
    public int startPosX;
    public int startPosY;
    public int endPosX;
    public int endPosY;
    public Color color;
}
