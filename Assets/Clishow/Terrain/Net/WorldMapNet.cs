using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using ProtoMsg;
using Serclimax;
using System.Threading;

public class WorldMapNet
{
    public static int ServerBlockSize = 16;
    public static int ServerBlockTotalCount = 22;//352/16 = 22
    //public Dictionary<int, SEntryData> sEntryData = new Dictionary<int, SEntryData>();
    public MapData mapData = new MapData();
    public BorderData borderData = new BorderData();
    public PathData pathData = new PathData();

    bool mapDataRealy = false;
    bool borderDataRealy = false;
    bool pathDataRealy = false;

    public int mapVersion = 0;
    public int pathVersion = 0;
    public byte[] mapBytes;
    byte[] borderBytes;
    public byte[] pathBytes;

    PosISceneEntrysInfoRequest msgPosISceneEntrysInfoRequest;
    SceneMapGuildFieldRequest msgSceneMapGuildFieldRequest;
    SceneMapPathInfoV2Request msgSceneMapPathInfoRequest;

    public PosISceneEntrysInfoResponse msgPosISceneEntrysInfoResponse;
    public SceneMapGuildFieldResponse msgSceneMapGuildFieldResponse;
    SceneMapPathInfoV2Response msgSceneMapPathInfoResponse;

    SceneMapEventPush sceneMapEventPush;
    private INetHelp mMobaHelp;
    //Thread threadMap = null;

    List<int> mapCache = new List<int>();
    List<int> borderCache = new List<int>();
    List<int> pathCache = new List<int>();

    Dictionary<int, List<SEntryPathInfo>> tmpPath = new Dictionary<int, List<SEntryPathInfo>>();

    int planCount = 100;

    public void ClearAllCache()
    {
        mapData.ClearAllCache();
        borderData.ClearAllCache();
        pathData.ClearAllCache();
        mapCache.Clear();
        borderCache.Clear();
        pathCache.Clear();
        tmpPath.Clear();
        world.WorldInfo.WBlockMap.ClearBuild();
        world.WorldInfo.WBlockMap.ClearEffect();
    }

    World world;
    public void Init(World w)
    {
        world = w;
        mapData.Init(w);
        borderData.Init(w);
        if (world.MobaMode != WorldMode.Normal)
        {
            switch (world.MobaMode)
            {
                case WorldMode.Moba:
                    mMobaHelp = new WorldMapNet4MobaHelp();
                    mMobaHelp.Init(this, MapMsgDispose, PathMsgDispose);
                    return;
                case WorldMode.GuildMoba:
                    mMobaHelp = new WorldMapNet4GuildMobaHelp();
                    mMobaHelp.Init(this, MapMsgDispose, PathMsgDispose);
                    return;
            }
        }        
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        NetworkManager.instance.RegisterPushMsgCallback((uint)MsgCategory.Map, (uint)MapTypeId.Map.SceneMapEventPush, (id, type, data) =>
        {
            List<int> pushMap = new List<int>();
            List<int> pushBorder = new List<int>();
            List<int> pushPath = new List<int>();
            int posi;
            sceneMapEventPush = NetworkManager.instance.Decode<SceneMapEventPush>(data);
            for (int i = 0; i < sceneMapEventPush.data.Count; i++)
            {
                posi = (int)sceneMapEventPush.data[i].posi;
                if ((sceneMapEventPush.data[i].freshtype & (uint)MapFreshType.MapFreshType_Se) != 0)
                {
                    if (mapCache.Contains((int)sceneMapEventPush.data[i].posi))
                    {
                        pushMap.Add(posi);
                        mapData.ClearCache(posi);
                    }
                }
                if ((sceneMapEventPush.data[i].freshtype & (uint)MapFreshType.MapFreshType_GuildField) != 0)
                {
                    int x = posi % ServerBlockTotalCount * 2;
                    int y = posi / ServerBlockTotalCount * 2;
                    int posindex = y * (ServerBlockTotalCount * 2) + x;
                    if (borderCache.Contains(posindex))
                    {
                        for (int bx = x; bx < (x + 2); bx++)
                        {
                            for (int by = y; by < (y + 2); by++)
                            {
                                int pi = by * (ServerBlockTotalCount * 2) + bx;
                                pushBorder.Add(pi);
                                borderData.ClearCache(pi);
                            }
                        }
                    }
                }
                if ((sceneMapEventPush.data[i].freshtype & (uint)MapFreshType.MapFreshType_Path) != 0)
                {
                    if (pathCache.Contains((int)sceneMapEventPush.data[i].posi))
                    {
                        pushPath.Add(posi);
                        if (tmpPath.ContainsKey(posi))
                            tmpPath[posi].Clear();
                    }
                }
            }
            if (pushMap.Count > 0)
            {
                RequestMapData(WorldMapMgr.Instance.CenterPos, pushMap);
            }
            if (pushBorder.Count > 0)
            {
                RequestBorderData(WorldMapMgr.Instance.CenterPos, pushBorder);
            }
            if (pushPath.Count > 0)
            {
                RequestPathData(WorldMapMgr.Instance.CenterPos, pushPath);
            }
            //WorldMapMgr.Instance.RequestAll();
        });
    }

    public void MapMsgDispose(byte[] data)
    {
        mapBytes = data;
        if (WorldMapMgr.instance.onUpdateMapData != null)
        {
            WorldMapMgr.instance.onUpdateMapData(mapBytes);
        }

        if (mapVersion > 100000000)
            mapVersion = 0;
        else
            mapVersion++;
        if (world.MobaMode == WorldMode.Normal)
            ThreadMapData();
        else
            mMobaHelp.SetMapData(mapBytes, mapData, world);
    }

    public void RequestMapData(Vec2Int centerPos, List<int> index)
    {
        if (world.MobaMode != WorldMode.Normal)
        {
            mMobaHelp.RequestMapData();
            return;
        }
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        centerPos = WToL(centerPos);
        centerPos.x = centerPos.x / ServerBlockSize - 1;
        centerPos.y = centerPos.y / ServerBlockSize - 1;
        int x, y;
        int posi;
        List<int> newMapCache = new List<int>();
        msgPosISceneEntrysInfoRequest = new PosISceneEntrysInfoRequest();
        for (int w = 0; w < 3; w++)
        {
            for (int h = 0; h < 3; h++)
            {
                x = centerPos.x + w;
                y = centerPos.y + h;
                posi = WToL32(y) * ServerBlockTotalCount + WToL32(x);
                msgPosISceneEntrysInfoRequest.viewPosi.Add((uint)posi);
                if (index == null)
                {
                    if (!mapCache.Contains(posi))
                    {
                        msgPosISceneEntrysInfoRequest.posi.Add((uint)posi);
                        newMapCache.Add(posi);
                    }
                    else
                    {
                        newMapCache.Add(posi);
                    }
                    if (w == 0 && h == 0)
                    {
                        msgPosISceneEntrysInfoRequest.center = (uint)posi;
                    }
                }
                else
                {
                    for (int i = 0; i < index.Count; i++)
                    {
                        if (mapCache.Contains(index[i]) && !msgPosISceneEntrysInfoRequest.posi.Contains((uint)index[i]))
                        {
                            msgPosISceneEntrysInfoRequest.posi.Add((uint)index[i]);
                        }
                    }
                }
            }
        }

        if (index == null)
            mapCache = newMapCache;
        //清除多余屏
        List<int> keys = new List<int>(mapData.SEntryData.Keys);
        foreach (int key in keys)
        {
            if (!mapCache.Contains(key))
            {
                mapData.ClearCache(key);
            }
        }
        if (msgPosISceneEntrysInfoRequest.posi.Count <= 0)
        {
            return;
        }
        //string str = "";
        //string str1 = "";
        //for (int i = 0; i < msgPosISceneEntrysInfoRequest.posi.Count; i++)
        //{
        //    str += msgPosISceneEntrysInfoRequest.posi[i].ToString() + ",";
        //}
        //for (int i = 0; i < msgPosISceneEntrysInfoRequest.viewPosi.Count; i++)
        //{
        //    str1 += msgPosISceneEntrysInfoRequest.viewPosi[i].ToString() + ",";
        //}

        //Debug.LogError("发送消息" + msgPosISceneEntrysInfoRequest.center + "请求屏幕" + str + "屏视野" + str1);
        NetworkManager.instance.Request<PosISceneEntrysInfoRequest>((uint)MsgCategory.Map, (uint)MapTypeId.Map.PosISceneEntrysInfoRequest, msgPosISceneEntrysInfoRequest, (data) =>
        {
            if (WorldMapMgr.instance == null)
                return;
            MapMsgDispose(data);
        });
    }

    public void RequestBorderData(Vec2Int centerPos, List<int> index)
    {
        if (world.MobaMode != WorldMode.Normal)
        {
            return;
        }
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        centerPos = WToL(centerPos);
        Vec2Int mapCenterPos = new Vec2Int();
        mapCenterPos.x = centerPos.x / ServerBlockSize * 2;
        mapCenterPos.y = centerPos.y / ServerBlockSize * 2;

        centerPos.x = centerPos.x / (ServerBlockSize / 2);
        centerPos.y = centerPos.y / (ServerBlockSize / 2);
        if ((centerPos.x - mapCenterPos.x) > 0)
            centerPos.x -= 3;
        else
            centerPos.x -= 2;
        if ((centerPos.y - mapCenterPos.y) > 0)
            centerPos.y -= 3;
        else
            centerPos.y -= 2;

        int x, y;
        int posi;
        List<int> newBorderCache = new List<int>();
        msgSceneMapGuildFieldRequest = new SceneMapGuildFieldRequest();

        if (index == null)
        {
            for (int w = 0; w < 6; w++)
            {
                for (int h = 0; h < 6; h++)
                {
                    x = centerPos.x + w;
                    y = centerPos.y + h;
                    posi = WToL64(y) * (ServerBlockTotalCount * 2) + WToL64(x);
                    if (!borderCache.Contains(posi))
                    {
                        msgSceneMapGuildFieldRequest.posi.Add((uint)posi);
                        newBorderCache.Add(posi);
                    }
                    else
                    {
                        newBorderCache.Add(posi);
                    }
                }
            }
        }
        else
        {
            for (int i = 0; i < index.Count; i++)
            {
                if (borderCache.Contains(index[i]))
                {
                    msgSceneMapGuildFieldRequest.posi.Add((uint)index[i]);
                }
            }
        }
        if (index == null)
            borderCache = newBorderCache;
        //清楚多余屏
        List<int> keys = new List<int>(borderData.MapGuildBlock.Keys);
        foreach (int key in keys)
        {
            if (!borderCache.Contains(key))
            {
                borderData.ClearCache(key);
            }
        }
        if (msgSceneMapGuildFieldRequest.posi.Count <= 0)
        {
            return;
        }
        NetworkManager.instance.Request<SceneMapGuildFieldRequest>((uint)MsgCategory.Map, (uint)MapTypeId.Map.SceneMapGuildFieldRequest, msgSceneMapGuildFieldRequest, (data) =>
        {
            if (WorldMapMgr.instance == null)
                return;
            borderBytes = data;
            borderDataRealy = true;
            SetBorderData();
        });
    }

    public void PathMsgDispose(byte[] data)
    {
        pathBytes = data;
        if (WorldMapMgr.instance.onUpdatePathData != null)
        {
            WorldMapMgr.instance.onUpdatePathData(pathBytes);
        }
        if (pathVersion > 100000000)
            pathVersion = 0;
        else
            pathVersion++;
        pathDataRealy = true;
        if (world.MobaMode == WorldMode.Normal)
            SetPathData();
        else
        {
            mMobaHelp.SetPathData(pathBytes, pathData, world);
        }
    }

    public void RequestPathData(Vec2Int centerPos, List<int> index)
    {
        if (world.MobaMode != WorldMode.Normal)
        {
            mMobaHelp.RequestPathData();
            return;
        }
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        centerPos = WToL(centerPos);
        centerPos.x = centerPos.x / ServerBlockSize - 1;
        centerPos.y = centerPos.y / ServerBlockSize - 1;
        int x, y;
        int posi;
        List<int> newPathCache = new List<int>();
        msgSceneMapPathInfoRequest = new SceneMapPathInfoV2Request();
        if (index == null)
        {
            for (int w = 0; w < 3; w++)
            {
                for (int h = 0; h < 3; h++)
                {
                    x = centerPos.x + w;
                    y = centerPos.y + h;
                    //过滤战区外的飞机线
                    if (x >= 0 && x <= 21 && y >= 0 && y <= 21)
                    {
                        posi = (WToL32(y) * ServerBlockTotalCount + WToL32(x));
                        if (!pathCache.Contains(posi))
                        {
                            msgSceneMapPathInfoRequest.posi.Add((uint)posi);
                            newPathCache.Add(posi);
                        }
                        else
                        {
                            newPathCache.Add(posi);
                        }
                    }
                }
            }
        }
        else
        {
            for (int i = 0; i < index.Count; i++)
            {
                if (pathCache.Contains(index[i]))
                {
                    msgSceneMapPathInfoRequest.posi.Add((uint)index[i]);
                }
            }
        }
        if (index == null)
            pathCache = newPathCache;
        //清楚多余屏
        List<int> keys = new List<int>(tmpPath.Keys);
        foreach (int key in keys)
        {
            if (!pathCache.Contains(key))
            {
                tmpPath.Remove(key);
            }
        }
        if (msgSceneMapPathInfoRequest.posi.Count <= 0)
        {
            return;
        }
        string str = "";
        for (int i = 0; i < msgSceneMapPathInfoRequest.posi.Count; i++)
        {
            str += msgSceneMapPathInfoRequest.posi[i].ToString() + ",";
        }

        NetworkManager.instance.Request<SceneMapPathInfoV2Request>((uint)MsgCategory.Map, (uint)MapTypeId.Map.SceneMapPathInfoV2Request, msgSceneMapPathInfoRequest, (data) =>
        {
            if (WorldMapMgr.instance == null)
                return;
            PathMsgDispose(data);
        });
    }

    void ThreadMapData()
    {
        msgPosISceneEntrysInfoResponse = NetworkManager.instance.Decode<PosISceneEntrysInfoResponse>(mapBytes);
        SetMapData();
    }

    public void UpdataNet()
    {
        //if(WorldMapMgr.instance.UsedLocalData)
        //    return;
        //if (mapDataRealy)
        //{
        //    SetMapData();
        //    return;
        //}
        //if (borderDataRealy)
        //{
        //    SetBorderData();
        //    return;
        //}
        //if (pathDataRealy)
        //{
        //    SetPathData();            
        //    return;
        //}
    }

    void SetMapData()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;

        //msgPosISceneEntrysInfoResponse = NetworkManager.instance.Decode<PosISceneEntrysInfoResponse>(mapBytes);
        if (msgPosISceneEntrysInfoResponse == null)
            return;
        if (msgPosISceneEntrysInfoResponse.code == (int)ProtoMsg.RequestCode.Code_OK)
        {
            SEntryData sEntryData;
            //添加新屏
            for (int i = 0; i < msgPosISceneEntrysInfoResponse.entry.Count; i++)
            {
                if (msgPosISceneEntrysInfoResponse.entry[i] == null)
                {
                    continue;
                }
                List<SEntryData> sEntryDatas = msgPosISceneEntrysInfoResponse.entry[i].entrys;
                if (sEntryDatas == null)
                {
                    continue;
                }
                for (int y = 0; y < sEntryDatas.Count; y++)
                {
                    sEntryData = sEntryDatas[y];
                    mapData.SetData((int)sEntryData.data.pos.x, (int)sEntryData.data.pos.y, sEntryDatas[y]);
                    uint blockId = sEntryData.data.posblockid;
                    if (blockId != 0)
                    {
                        ScObjectShapeData shapeData = Main.Instance.TableMgr.GetObjectShapeData((int)blockId);
                        for (int w = shapeData.xMin; w <= shapeData.xMax; w++)
                        {
                            for (int h = shapeData.yMin; h <= shapeData.yMax; h++)
                            {
                                mapData.SetData((WToL512((int)sEntryData.data.pos.x + w)), (WToL512((int)sEntryData.data.pos.y + h)), sEntryData);
                            }
                        }
                    }

                }
            }


            //开始刷新数据
            world.WorldInfo.WBlockMap.ClearBuild();
            world.WorldInfo.WBlockMap.ClearEffect();
            List<int> keys = new List<int>(mapData.SEntryData.Keys);
            foreach (int x in keys)
            {
                List<int> key = new List<int>(mapData.SEntryData[x].Keys);
                foreach (int y in key)
                {
                    //uint blockId = mapData.SEntryData[x][y].data.posblockid;
                    //if (blockId != 0)
                    //{
                    //    ScObjectShapeData shapeData = Main.Instance.TableMgr.GetObjectShapeData((int)blockId);
                    //    for (int w = shapeData.xMin; w <= shapeData.xMax; w++)
                    //    {
                    //        for (int h = shapeData.yMin; h <= shapeData.yMax; h++)
                    //        {
                    //            mapData.SetData((WToL512((int)mapData.SEntryData[x][y].data.pos.x + w)), (WToL512((int)mapData.SEntryData[x][y].data.pos.y + h)), mapData.SEntryData[x][y]);
                    //        }
                    //    }
                    //}
                    //解数据
                    mapData.SetMapData(mapData.SEntryData[x][y]);
                }
            }

            mapDataRealy = false;
            WorldMapMgr.Instance.UpdateSprite();
        }
    }

    void SetBorderData()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        msgSceneMapGuildFieldResponse = NetworkManager.instance.Decode<SceneMapGuildFieldResponse>(borderBytes);
        if (msgSceneMapGuildFieldResponse == null)
            return;

        if (msgSceneMapGuildFieldResponse.code == (int)ProtoMsg.RequestCode.Code_OK)
        {
            MapGuildBlock mapGuildBlock;

            //计算服务器数据转换为屏数
            for (int i = 0; i < msgSceneMapGuildFieldResponse.fields.Count; i++)
            {
                mapGuildBlock = msgSceneMapGuildFieldResponse.fields[i];
                for (int y = 0; y < mapGuildBlock.pos.Count; y++)
                {
                    if (mapGuildBlock.pos[y].x == 21 && mapGuildBlock.pos[y].x == 2)
                    {
                        int a = 0;
                    }
                    MapGuildBlock mgb = new MapGuildBlock();
                    Position pos = new Position();
                    pos.x = mapGuildBlock.pos[y].x;
                    pos.y = mapGuildBlock.pos[y].y;
                    mgb.guildid = mapGuildBlock.guildid;
                    mgb.guildbanner = mapGuildBlock.guildbanner;
                    mgb.guildbadge = mapGuildBlock.guildbadge;
                    mgb.guildname = mapGuildBlock.guildname;
                    mgb.pos.Add(pos);
                    int xScreen = (int)pos.x / (ServerBlockSize / 2);
                    int yScreen = (int)pos.y / (ServerBlockSize / 2);
                    int posi = yScreen * (ServerBlockTotalCount * 2) + xScreen;
                    int lindex = (int)pos.y * world.WorldInfo.LogicServerSizeY + (int)pos.x;
                    if (!borderData.MapGuildBlock.ContainsKey(posi))
                    {
                        Dictionary<int, MapGuildBlock> lists = new Dictionary<int, MapGuildBlock>();
                        lists.Add(lindex, mgb);
                        borderData.MapGuildBlock.Add(posi, lists);
                    }
                    else
                    {
                        borderData.MapGuildBlock[posi][lindex] = mgb;
                    }
                }
            }

            //开始刷新数据
            //borderData.MapGuildBlock.Clear();
            world.WorldInfo.WBlockMap.ClearTerritory();
            foreach (KeyValuePair<int, Dictionary<int, MapGuildBlock>> datas in borderData.MapGuildBlock)
            {
                foreach (KeyValuePair<int, MapGuildBlock> data in datas.Value)
                {
                    mapGuildBlock = data.Value;
                    for (int y = 0; y < mapGuildBlock.pos.Count; y++)
                    {
                        int dataIndex = (int)mapGuildBlock.pos[y].y * world.WorldInfo.LogicServerSizeY + (int)mapGuildBlock.pos[y].x;
                        borderData.SetBorderData((int)mapGuildBlock.pos[y].x, (int)mapGuildBlock.pos[y].y, mapGuildBlock);
                    }
                }
                //borderData.MapGuildBlock[datas.Key] = datas.Value;
            }
            borderDataRealy = false;

            WorldMapMgr.Instance.UpdateTerrain();
        }
    }

    void SetPathData()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        msgSceneMapPathInfoResponse = NetworkManager.instance.Decode<SceneMapPathInfoV2Response>(pathBytes);
        if (msgSceneMapPathInfoResponse == null)
            return;
        if (msgSceneMapPathInfoResponse.code == (int)ProtoMsg.RequestCode.Code_OK)
        {
            SEntryPathInfo sEntryPathInfo;
            //添加数据
            Dictionary<uint, SEntryPathInfo> tmpData = new Dictionary<uint, SEntryPathInfo>();
            for (int i = 0; i < msgSceneMapPathInfoResponse.path.Count; i++)
            {
                tmpData[msgSceneMapPathInfoResponse.path[i].pathId] = msgSceneMapPathInfoResponse.path[i];
            }

            for (int y = 0; y < msgSceneMapPathInfoResponse.data.Count; y++)
            {
                sEntryPathInfo = tmpData[msgSceneMapPathInfoResponse.data[y].pathid];
                for (int f = 0; f < msgSceneMapPathInfoResponse.data[y].posi.Count; f++)
                {
                    if (!tmpPath.ContainsKey((int)msgSceneMapPathInfoResponse.data[y].posi[f]))
                    {
                        List<SEntryPathInfo> datas = new List<SEntryPathInfo>();
                        datas.Add(sEntryPathInfo);
                        tmpPath.Add((int)msgSceneMapPathInfoResponse.data[y].posi[f], datas);
                    }
                    else
                    {
                        tmpPath[(int)msgSceneMapPathInfoResponse.data[y].posi[f]].Add(sEntryPathInfo);
                    }
                }
            }
            pathData.SEntryPathInfo.Clear();

            world.worldMapUpdata.worldMapAircraft.Aircrafts.Clear();
            int charid = WorldMapMgr.instance.CharId;
            //和自己有关的飞机
            foreach (KeyValuePair<int, List<SEntryPathInfo>> datas in tmpPath)
            {
                for (int i = 0; i < datas.Value.Count; i++)
                {
                    sEntryPathInfo = datas.Value[i];
                    if (pathData.SEntryPathInfo.Count > 100)
                        break;
                    if (sEntryPathInfo.charid == charid || sEntryPathInfo.tarcharid == charid)
                    {
                        if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                        {
                            //sEntryPathInfo.charname = (string)LuaClient.GetMainState().GetFunction("MainData.GetCharName").Call(null)[0];
                            if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                            {
                                sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                            }
                            pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                            pathData.SetPathData(sEntryPathInfo);
                            if (sEntryPathInfo.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
                            {
                                WorldMapMgr.Instance.RebelPathId = sEntryPathInfo.pathId;
                            }
                        }
                    }
                }
            }

            //自己联盟的飞机
            int guildid = WorldMapMgr.instance.GuildId;
            foreach (KeyValuePair<int, List<SEntryPathInfo>> datas in tmpPath)
            {
                for (int i = 0; i < datas.Value.Count; i++)
                {
                    sEntryPathInfo = datas.Value[i];
                    if (sEntryPathInfo.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
                        continue;
                    if (pathData.SEntryPathInfo.Count > 100)
                        break;
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.tarGuildId == guildid)
                    {
                        if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                        {
                            if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                            {
                                sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                            }
                            pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                            pathData.SetPathData(sEntryPathInfo);
                        }
                    }
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.ownerguild != null)
                    {
                        if (sEntryPathInfo.ownerguild.guildid == guildid)
                        {
                            if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                            {
                                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                {
                                    sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                }
                                pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                pathData.SetPathData(sEntryPathInfo);
                            }
                        }
                    }
                }
            }

            //其他飞机
            foreach (KeyValuePair<int, List<SEntryPathInfo>> datas in tmpPath)
            {
                for (int i = 0; i < datas.Value.Count; i++)
                {
                    sEntryPathInfo = datas.Value[i];
                    if (sEntryPathInfo.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
                    {
                        continue;
                    }
                    if (pathData.SEntryPathInfo.Count > 100)
                        break;
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.tarGuildId != guildid)
                    {
                        if (sEntryPathInfo.ownerguild != null)
                        {
                            if (sEntryPathInfo.ownerguild.guildid != guildid)
                            {
                                if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                                {
                                    if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                    {
                                        sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                    }
                                    pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                    pathData.SetPathData(sEntryPathInfo);
                                }
                            }
                        }

                        if (sEntryPathInfo.ownerguild == null)
                        {
                            if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                            {
                                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                {
                                    sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                }
                                pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                pathData.SetPathData(sEntryPathInfo);
                            }
                        }
                    }
                }
            }
            pathDataRealy = false;
            WorldMapMgr.Instance.DrawLine();
        }
    }

    Vec2Int WToL(Vec2Int pos)
    {
        Vec2Int l = new Vec2Int();
        //将带负的转换到 0-512
        l.x = pos.x % world.WorldInfo.LogicServerSizeX;
        if ((pos.x / world.WorldInfo.LogicServerSizeX) >= 1)
        {
            l.x = world.WorldInfo.LogicServerSizeX;
        }
        if (l.x < 0)
            l.x = world.WorldInfo.LogicServerSizeX + l.x;
        l.y = pos.y % world.WorldInfo.LogicServerSizeY;
        if ((pos.y / world.WorldInfo.LogicServerSizeY) >= 1)
        {
            l.y = world.WorldInfo.LogicServerSizeY;
        }
        if (l.y < 0)
        {
            l.y = world.WorldInfo.LogicServerSizeY + l.y;
        }
        return l;
    }
    public int WToL512(int x)
    {
        //将带负的转换到 0-32
        int lx = x % world.WorldInfo.LogicServerSizeX;
        if (lx < 0)
            lx = world.WorldInfo.LogicServerSizeX + lx;
        return lx;
    }

    public int WToL32(int x)
    {
        //将带负的转换到 0-32
        int lx = x % ServerBlockTotalCount;
        if (lx < 0)
            lx = ServerBlockTotalCount + lx;
        return lx;
    }

    public int WToL64(int x)
    {
        //将带负的转换到 0-32
        int lx = x % (ServerBlockTotalCount * 2);
        if (lx < 0)
            lx = (ServerBlockTotalCount * 2) + lx;
        return lx;
    }
}
public interface INetHelp
{
    void Init(WorldMapNet w, System.Action<byte[]> entry_call_back, System.Action<byte[]> path_call_back);
    void RequestMapData();
    void SetMapData(byte[] mapBytes, MapData mapData, World world);
    void RequestPathData();
    void SetPathData(byte[] pathBytes, PathData pathData, World world);
}

public class WorldMapNet4MobaHelp: INetHelp
{

    private MsgMobaSceneEntrysInfoRequest msgMobaSceneEntrysInfoRequest;
    private MsgMobaSceneMapPathsInfoRequest msgMobaSceneMapPathsInfoRequest;

    public MsgMobaSceneEntrysInfoResponse msgMobaSceneEntrysInfoResponse;
    public MsgMobaSceneMapPathsInfoResponse msgMobaSceneMapPathsInfoResponse;

    MsgMobaSceneMapEventPush sceneMapEventPush;
    private System.Action<byte[]> mEntrysInfoMsgCallBack;
    private System.Action<byte[]> mPathsInfoMsgCallBack;

    private WorldMapNet mMapNet;

    private void SetPush()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        NetworkManager.instance.RegisterPushMsgCallback((uint)MsgCategory.Moba, (uint)MobaTypeId.Moba.MsgMobaSceneMapEventPush, (id, type, data) =>
        {
            sceneMapEventPush = NetworkManager.instance.Decode<MsgMobaSceneMapEventPush>(data);
            if ((sceneMapEventPush.freshType & (uint)MapFreshType.MapFreshType_Se) != 0)
            {
                //map
                RequestMapData();
            }
            if ((sceneMapEventPush.freshType & (uint)MapFreshType.MapFreshType_Path) != 0)
            {
                //path
                RequestPathData();
            }
        });
    }

    public void Init(WorldMapNet w, System.Action<byte[]> entry_call_back, System.Action<byte[]> path_call_back)
    {
        if (WorldMapMgr.Instance == null)
            return;
        mMapNet = w;
        mEntrysInfoMsgCallBack = entry_call_back;
        mPathsInfoMsgCallBack = path_call_back;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        SetPush();
    }

    public void RequestMapData()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        if (mEntrysInfoMsgCallBack == null)
            return;
        msgMobaSceneEntrysInfoRequest = new MsgMobaSceneEntrysInfoRequest();
        NetworkManager.instance.Request<MsgMobaSceneEntrysInfoRequest>((uint)MsgCategory.Moba, (uint)MobaTypeId.Moba.MsgMobaSceneEntrysInfoRequest, msgMobaSceneEntrysInfoRequest, (data) =>
        {
            if (WorldMapMgr.instance == null)
                return;
            mEntrysInfoMsgCallBack(data);
        });
    }

    public void SetMapData(byte[] mapBytes,MapData mapData,World world)
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;

        msgMobaSceneEntrysInfoResponse = NetworkManager.instance.Decode<MsgMobaSceneEntrysInfoResponse>(mapBytes);
        if (msgMobaSceneEntrysInfoResponse == null)
            return;
       //Debug.Log("Code ---------------------" + msgMobaSceneEntrysInfoResponse.code);
        if (msgMobaSceneEntrysInfoResponse.code == (int)ProtoMsg.RequestCode.Code_OK)
        {
            SEntryData sEntryData;
            //添加新屏
            List<SEntryData> sEntryDatas = msgMobaSceneEntrysInfoResponse.entrys;
            if (sEntryDatas == null)
            {
                return;
            }
            mapData.ClearAllCache();
            for (int y = 0; y < sEntryDatas.Count; y++)
            {
                sEntryData = sEntryDatas[y];
                
                sEntryData.data.pos.x += (uint)world.mobaBorderMinPos.x;
                sEntryData.data.pos.y += (uint)world.mobaBorderMinPos.y;
                mapData.SetData((int)sEntryData.data.pos.x, (int)sEntryData.data.pos.y, sEntryDatas[y]);
                //Debug.Log("         Build ---------------------" + sEntryData.data.entryType+" -pos:"+( (int)sEntryData.data.pos.x - 121)+","+ ((int)sEntryData.data.pos.y - 34));
                uint blockId = sEntryData.data.posblockid;
                if (blockId != 0)
                {
                    ScObjectShapeData shapeData = Main.Instance.TableMgr.GetObjectShapeData((int)blockId);
                    for (int w = shapeData.xMin; w <= shapeData.xMax; w++)
                    {
                        for (int h = shapeData.yMin; h <= shapeData.yMax; h++)
                        {
                            mapData.SetData((mMapNet.WToL512((int)sEntryData.data.pos.x + w)), (mMapNet.WToL512((int)sEntryData.data.pos.y + h)), sEntryData);
                        }
                    }
                }

            }

            //开始刷新数据
            world.WorldInfo.WBlockMap.ClearBuild();
            world.WorldInfo.WBlockMap.ClearEffect();
            List<int> keys = new List<int>(mapData.SEntryData.Keys);
            foreach (int x in keys)
            {
                List<int> key = new List<int>(mapData.SEntryData[x].Keys);
                foreach (int y in key)
                {
                    //mapData.SEntryData[x][y].data.pos.x += (uint)world.mobaBorderMinPos.x;
                    //mapData.SEntryData[x][y].data.pos.y += (uint)world.mobaBorderMinPos.y;
                    mapData.SetMapData(mapData.SEntryData[x][y]);
                }
            }
            WorldMapMgr.Instance.UpdateSprite();
        }
    }

    public void RequestPathData()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        if (mPathsInfoMsgCallBack == null)
            return;
        msgMobaSceneMapPathsInfoRequest = new MsgMobaSceneMapPathsInfoRequest();
        NetworkManager.instance.Request<MsgMobaSceneMapPathsInfoRequest>((uint)MsgCategory.Moba, (uint)MobaTypeId.Moba.MsgMobaSceneMapPathsInfoRequest, msgMobaSceneMapPathsInfoRequest, (data) =>
        {
            if (WorldMapMgr.instance == null)
                return;
            mPathsInfoMsgCallBack(data);
        });
    }

    public void SetPathData(byte[] pathBytes,PathData pathData,World world)
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        msgMobaSceneMapPathsInfoResponse = NetworkManager.instance.Decode<MsgMobaSceneMapPathsInfoResponse>(pathBytes);
        if (msgMobaSceneMapPathsInfoResponse == null)
            return;
        pathData.ClearAllCache();
        if (msgMobaSceneMapPathsInfoResponse.code == (int)ProtoMsg.RequestCode.Code_OK)
        {
            SEntryPathInfo sEntryPathInfo;
            pathData.SEntryPathInfo.Clear();

            world.worldMapUpdata.worldMapAircraft.Aircrafts.Clear();
            int charid = WorldMapMgr.instance.CharId;
            int guildid = WorldMapMgr.instance.GuildId;
            //和自己有关的飞机
            for (int i = 0; i < msgMobaSceneMapPathsInfoResponse.paths.Count; i++)
            {
                sEntryPathInfo = msgMobaSceneMapPathsInfoResponse.paths[i];
                if (sEntryPathInfo.ownerguild == null)
                    sEntryPathInfo.ownerguild = new OwnerGuildInfo();
                if (pathData.SEntryPathInfo.Count > 100)
                    break;
                sEntryPathInfo.sourcePos.x += (uint)world.mobaBorderMinPos.x;
                sEntryPathInfo.sourcePos.y += (uint)world.mobaBorderMinPos.y;
                sEntryPathInfo.targetPos.x += (uint)world.mobaBorderMinPos.x;
                sEntryPathInfo.targetPos.y += (uint)world.mobaBorderMinPos.y;
                
                if (sEntryPathInfo.charid == charid || sEntryPathInfo.tarcharid == charid)
                {
                    if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                    {
                        //sEntryPathInfo.charname = (string)LuaClient.GetMainState().GetFunction("MainData.GetCharName").Call(null)[0];
                        if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                        {
                            sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                        }
                        pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                        pathData.SetPathData(sEntryPathInfo);
                        if (sEntryPathInfo.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
                        {
                            WorldMapMgr.Instance.RebelPathId = sEntryPathInfo.pathId;
                        }
                    }
                }
                else
                {
                    if (sEntryPathInfo.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
                        continue;
                    if (pathData.SEntryPathInfo.Count > 100)
                        break;
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.tarGuildId == guildid)
                    {
                        if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                        {
                            if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                            {
                                sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                            }
                            pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                            pathData.SetPathData(sEntryPathInfo);
                        }
                    }
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.ownerguild != null)
                    {
                        if (sEntryPathInfo.ownerguild.guildid == guildid)
                        {
                            if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                            {
                                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                {
                                    sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                }
                                pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                pathData.SetPathData(sEntryPathInfo);
                            }
                        }
                    }
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.tarGuildId != guildid)
                    {
                        if (sEntryPathInfo.ownerguild != null)
                        {
                            if (sEntryPathInfo.ownerguild.guildid != guildid)
                            {
                                if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                                {
                                    if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                    {
                                        sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                    }
                                    pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                    pathData.SetPathData(sEntryPathInfo);
                                }
                            }
                        }

                        if (sEntryPathInfo.ownerguild == null)
                        {
                            if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                            {
                                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                {
                                    sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                }
                                pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                pathData.SetPathData(sEntryPathInfo);
                            }
                        }
                    }
                }
            }
            WorldMapMgr.Instance.DrawLine();
        }
    }
}

public class WorldMapNet4GuildMobaHelp: INetHelp
{

    private GuildMobaSceneEntrysInfoRequest msgMobaSceneEntrysInfoRequest;
    private GuildMobaSceneMapPathsInfoRequest msgMobaSceneMapPathsInfoRequest;

    public GuildMobaSceneEntrysInfoResponse msgMobaSceneEntrysInfoResponse;
    public GuildMobaSceneMapPathsInfoResponse msgMobaSceneMapPathsInfoResponse;

    GuildMobaSceneMapEventPush sceneMapEventPush;
    private System.Action<byte[]> mEntrysInfoMsgCallBack;
    private System.Action<byte[]> mPathsInfoMsgCallBack;

    private WorldMapNet mMapNet;

    private void SetPush()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        NetworkManager.instance.RegisterPushMsgCallback((uint)MsgCategory.GuildMoba, (uint)GuildMobaTypeId.GuildMoba.GuildMobaSceneMapEventPush, (id, type, data) =>
        {
            sceneMapEventPush = NetworkManager.instance.Decode<GuildMobaSceneMapEventPush>(data);
            if ((sceneMapEventPush.freshType & (uint)MapFreshType.MapFreshType_Se) != 0)
            {
                //map
                RequestMapData();
            }
            if ((sceneMapEventPush.freshType & (uint)MapFreshType.MapFreshType_Path) != 0)
            {
                //path
                RequestPathData();
            }
        });
    }

    public void Init(WorldMapNet w, System.Action<byte[]> entry_call_back, System.Action<byte[]> path_call_back)
    {
        if (WorldMapMgr.Instance == null)
            return;
        mMapNet = w;
        mEntrysInfoMsgCallBack = entry_call_back;
        mPathsInfoMsgCallBack = path_call_back;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        SetPush();
    }

    public void RequestMapData()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        if (mEntrysInfoMsgCallBack == null)
            return;
        msgMobaSceneEntrysInfoRequest = new GuildMobaSceneEntrysInfoRequest();
        NetworkManager.instance.Request<GuildMobaSceneEntrysInfoRequest>((uint)MsgCategory.GuildMoba, (uint)GuildMobaTypeId.GuildMoba.GuildMobaSceneEntrysInfoRequest, msgMobaSceneEntrysInfoRequest, (data) =>
        {
            if (WorldMapMgr.instance == null)
                return;
            mEntrysInfoMsgCallBack(data);
        });
    }

    public void SetMapData(byte[] mapBytes, MapData mapData, World world)
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;

        msgMobaSceneEntrysInfoResponse = NetworkManager.instance.Decode<GuildMobaSceneEntrysInfoResponse>(mapBytes);
        if (msgMobaSceneEntrysInfoResponse == null)
            return;
        //Debug.Log("Code ---------------------" + msgMobaSceneEntrysInfoResponse.code);
        if (msgMobaSceneEntrysInfoResponse.code == (int)ProtoMsg.RequestCode.Code_OK)
        {
            SEntryData sEntryData;
            //添加新屏
            List<SEntryData> sEntryDatas = msgMobaSceneEntrysInfoResponse.entrys;
            if (sEntryDatas == null)
            {
                return;
            }
            mapData.ClearAllCache();
            for (int y = 0; y < sEntryDatas.Count; y++)
            {
                sEntryData = sEntryDatas[y];

                sEntryData.data.pos.x += (uint)world.mobaBorderMinPos.x;
                sEntryData.data.pos.y += (uint)world.mobaBorderMinPos.y;
                mapData.SetData((int)sEntryData.data.pos.x, (int)sEntryData.data.pos.y, sEntryDatas[y]);
                //Debug.Log("         Build ---------------------" + sEntryData.data.entryType+" -pos:"+( (int)sEntryData.data.pos.x - 121)+","+ ((int)sEntryData.data.pos.y - 34));
                uint blockId = sEntryData.data.posblockid;
                if (blockId != 0)
                {
                    ScObjectShapeData shapeData = Main.Instance.TableMgr.GetObjectShapeData((int)blockId);
                    for (int w = shapeData.xMin; w <= shapeData.xMax; w++)
                    {
                        for (int h = shapeData.yMin; h <= shapeData.yMax; h++)
                        {
                            mapData.SetData((mMapNet.WToL512((int)sEntryData.data.pos.x + w)), (mMapNet.WToL512((int)sEntryData.data.pos.y + h)), sEntryData);
                        }
                    }
                }

            }

            //开始刷新数据
            world.WorldInfo.WBlockMap.ClearBuild();
            world.WorldInfo.WBlockMap.ClearEffect();
            List<int> keys = new List<int>(mapData.SEntryData.Keys);
            foreach (int x in keys)
            {
                List<int> key = new List<int>(mapData.SEntryData[x].Keys);
                foreach (int y in key)
                {
                    //mapData.SEntryData[x][y].data.pos.x += (uint)world.mobaBorderMinPos.x;
                    //mapData.SEntryData[x][y].data.pos.y += (uint)world.mobaBorderMinPos.y;
                    mapData.SetMapData(mapData.SEntryData[x][y]);
                }
            }
            WorldMapMgr.Instance.UpdateSprite();
        }
        else
        {
            Debug.Log("GuildMobaSceneEntrysInfoResponse Error:" + msgMobaSceneEntrysInfoResponse.code);
        }
    }

    public void RequestPathData()
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        if (mPathsInfoMsgCallBack == null)
            return;
        msgMobaSceneMapPathsInfoRequest = new GuildMobaSceneMapPathsInfoRequest();
        NetworkManager.instance.Request<GuildMobaSceneMapPathsInfoRequest>((uint)MsgCategory.GuildMoba, (uint)GuildMobaTypeId.GuildMoba.GuildMobaSceneMapPathsInfoRequest, msgMobaSceneMapPathsInfoRequest, (data) =>
        {
            if (WorldMapMgr.instance == null)
                return;
            mPathsInfoMsgCallBack(data);
        });
    }

    public void SetPathData(byte[] pathBytes, PathData pathData, World world)
    {
        if (WorldMapMgr.Instance == null)
            return;
        if (WorldMapMgr.instance.UsedLocalData)
            return;
        msgMobaSceneMapPathsInfoResponse = NetworkManager.instance.Decode<GuildMobaSceneMapPathsInfoResponse>(pathBytes);
        if (msgMobaSceneMapPathsInfoResponse == null)
            return;
        pathData.ClearAllCache();
        if (msgMobaSceneMapPathsInfoResponse.code == (int)ProtoMsg.RequestCode.Code_OK)
        {
            SEntryPathInfo sEntryPathInfo;
            pathData.SEntryPathInfo.Clear();

            world.worldMapUpdata.worldMapAircraft.Aircrafts.Clear();
            int charid = WorldMapMgr.instance.CharId;
            int guildid = WorldMapMgr.instance.GuildId;
            //和自己有关的飞机
            for (int i = 0; i < msgMobaSceneMapPathsInfoResponse.paths.Count; i++)
            {
                sEntryPathInfo = msgMobaSceneMapPathsInfoResponse.paths[i];
                if (sEntryPathInfo.ownerguild == null)
                    sEntryPathInfo.ownerguild = new OwnerGuildInfo();
                if (pathData.SEntryPathInfo.Count > 100)
                    break;
                sEntryPathInfo.sourcePos.x += (uint)world.mobaBorderMinPos.x;
                sEntryPathInfo.sourcePos.y += (uint)world.mobaBorderMinPos.y;
                sEntryPathInfo.targetPos.x += (uint)world.mobaBorderMinPos.x;
                sEntryPathInfo.targetPos.y += (uint)world.mobaBorderMinPos.y;

                if (sEntryPathInfo.charid == charid || sEntryPathInfo.tarcharid == charid)
                {
                    if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                    {
                        //sEntryPathInfo.charname = (string)LuaClient.GetMainState().GetFunction("MainData.GetCharName").Call(null)[0];
                        if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                        {
                            sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                        }
                        pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                        pathData.SetPathData(sEntryPathInfo);
                        if (sEntryPathInfo.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
                        {
                            WorldMapMgr.Instance.RebelPathId = sEntryPathInfo.pathId;
                        }
                    }
                }
                else
                {
                    if (sEntryPathInfo.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
                        continue;
                    if (pathData.SEntryPathInfo.Count > 100)
                        break;
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.tarGuildId == guildid)
                    {
                        if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                        {
                            if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                            {
                                sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                            }
                            pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                            pathData.SetPathData(sEntryPathInfo);
                        }
                    }
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.ownerguild != null)
                    {
                        if (sEntryPathInfo.ownerguild.guildid == guildid)
                        {
                            if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                            {
                                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                {
                                    sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                }
                                pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                pathData.SetPathData(sEntryPathInfo);
                            }
                        }
                    }
                    if (sEntryPathInfo.charid != charid && sEntryPathInfo.tarcharid != charid && sEntryPathInfo.tarGuildId != guildid)
                    {
                        if (sEntryPathInfo.ownerguild != null)
                        {
                            if (sEntryPathInfo.ownerguild.guildid != guildid)
                            {
                                if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                                {
                                    if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                    {
                                        sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                    }
                                    pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                    pathData.SetPathData(sEntryPathInfo);
                                }
                            }
                        }

                        if (sEntryPathInfo.ownerguild == null)
                        {
                            if (!pathData.SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
                            {
                                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                                {
                                    sEntryPathInfo.charname = TextManager.Instance.GetText(string.Format("SiegeMonster_{0}", sEntryPathInfo.charname));
                                }
                                pathData.SEntryPathInfo.Add((int)sEntryPathInfo.pathId, sEntryPathInfo);
                                pathData.SetPathData(sEntryPathInfo);
                            }
                        }
                    }
                }
            }
            WorldMapMgr.Instance.DrawLine();
        }
        else
        {
            Debug.Log("GuildMobaSceneMapPathsInfoResponse Error:" + msgMobaSceneMapPathsInfoResponse.code);
        }
    }
}