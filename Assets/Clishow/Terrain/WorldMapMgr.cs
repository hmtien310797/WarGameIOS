using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using ProtoMsg;
using LuaInterface;

public class WorldMapMgr : MonoBehaviour, IWorldData
{

    public static WorldMapMgr instance;
    public static WorldMapMgr Instance
    {
        get
        {
            return instance;
        }
    }
    public static bool IsDebug = false;
    public World world;
    public World3DCamera worldCamera;

    public bool NoUpdateWorld = true;
    public bool UsedLocalData = false;
    public bool SupportCameraMove = true;
    public bool SupportGuide = false;
    public int InitX;
    public int InitY;
    public int CenterX;
    public int CenterY;
    public int Width = 32;

    public int CharId
    {
        get
        {

            return (int)(double)LuaClient.GetMainState().GetFunction("MainData.GetCharId").Call(null)[0];
        }
        set { }
    }
    public int GuildId
    {
        get
        {
            return (int)(double)LuaClient.GetMainState().GetFunction("UnionInfoData.GetGuildId").Call(null)[0];
        }
        set { }
    }

    //[System.NonSerialized]
    public Vector2 curPos;
    public delegate void MoveEvent();
    public MoveEvent OnMoveEvent;


    public delegate void CenterMoveEvent();
    public CenterMoveEvent OnCenterMoveEvent;

    [LuaByteBufferAttribute]
    public delegate void OnUpdateMapDataCB(byte[] map_data_byte);
    public OnUpdateMapDataCB onUpdateMapData;
    [LuaByteBufferAttribute]
    public delegate void OnUpdatePathDataCB(byte[] path_data_byte);
    public OnUpdatePathDataCB onUpdatePathData;


    public int MobaMinPosX()
    {
        return world.mobaBorderMinPos.x;
    }

    public int MobaMinPosY()
    {
        return world.mobaBorderMinPos.y;
    }

    private int followId;
    public int FollowId() { return followId; }

    int oldIndexs = 0;
    bool isFirst = true;

    public uint RebelPathId;

    public FortRangeMgr RangeMgr;

    //检测是否刷新地形数据
    QuadRect CheckRect;
    public Vec2Int CenterPos;
    Vec2Int OldCenterPos;
    Vec2Int SelectPos;

    Vector3 tmpFollow;

    public void SetSelfInfo(int charid, int guildid)
    {
        //CharId = charid;
        //GuildId = guildid;
    }

    public int ShowRectMinX()
    {
        if (worldCamera == null)
            return 0;
        return (int)worldCamera.CurdRect.MinX;
    }
    public int ShowRectMinY()
    {
        if (worldCamera == null)
            return 0;
        return (int)worldCamera.CurdRect.MinY;
    }
    public int ShowRectMaxX()
    {
        if (worldCamera == null)
            return 0;
        return (int)worldCamera.CurdRect.MaxX;
    }
    public int ShowRectMaxY()
    {
        if (worldCamera == null)
            return 0;
        return (int)worldCamera.CurdRect.MaxY;
    }
    public int CameraRotationY()
    {
        if (world == null)
            return 0;
        return (int)world.WCamera.transform.localEulerAngles.y;
    }

    public void Awake()
    {
        instance = this;
        CheckRect = new QuadRect(0, 0, Width, Width);
    }

    public void GoPos(int x, int y)
    {
        if (world == null || worldCamera == null)
            return;
        if (isFirst)
        {
            isFirst = false;
            InitX = x;
            InitY = y;
            world.Init();
            worldCamera.transform.localPosition = CameraCurPosToWorldPos(InitX, InitY, 0);
            GetData();
        }
        else
        {
            
            Vector3 v = CameraCurPosToWorldPos(x, y, 0);
            worldCamera.transform.localPosition = v;
            world.UpdateWorld(v);
            GetData();
        }
    }

    public void SetSprite(int indexs, int sprites, int effects)
    {
        //world.WorldInfo.WBlockMap.SetBuild(indexs, sprites);
        //world.WorldInfo.WBlockMap.SetEffect(indexs, effects);
    }

    public void ClearSprite()
    {
        //world.WorldInfo.WBlockMap.ClearBuild();
        //world.WorldInfo.WBlockMap.ClearEffect();
    }

    public void UpdateSprite()
    {
        if (world == null)
            return;
        world.worldMapUpdata.UpdateBuild(worldCamera.ViewRect(true));
    }

    public void ClearTerrain()
    {
        //world.WorldInfo.WBlockMap.ClearTerritory();
    }

    public void SetTerrain(int indexs, int colors)
    {
        //world.WorldInfo.WBlockMap.SetTerritory(indexs, colors);
    }

    public void SetSEntryData(byte[] sEntryDataBytes, int x, int y)
    {
        if (world == null)
            return;
        SEntryData sEntryData = NetworkManager.instance.Decode<SEntryData>(sEntryDataBytes);
        sEntryData.ownerguild = new OwnerGuildInfo();
        world.worldMapNet.mapData.SetData(x, y, sEntryData);
        world.worldMapNet.mapData.SetMapData(sEntryData);
        WorldMapMgr.Instance.UpdateSprite();
    }

    public void SetSEntryData(SEntryData _sEntryData)
    {
        if (world == null)
            return;
        int dataIndex = (int)_sEntryData.data.pos.y * world.WorldInfo.LogicServerSizeY + (int)_sEntryData.data.pos.x;
        world.worldMapNet.mapData.SetData((int)_sEntryData.data.pos.x, (int)_sEntryData.data.pos.y, _sEntryData);
        world.worldMapNet.mapData.SetMapData(_sEntryData);
    }

    public SEntryData ShowTileInfo(uint x, uint y)
    {
        if (world == null)
            return null;
        int dataIndex = (int)y * world.WorldInfo.LogicServerSizeY + (int)x;
        return world.worldMapNet.mapData.GetData((int)x, (int)y);
    }

    [LuaByteBufferAttribute]
    public byte[] TileInfo(uint x, uint y)
    {
        if (world == null)
            return new byte[0];
        int dataIndex = (int)y * world.WorldInfo.LogicServerSizeY + (int)x;
        return NetworkManager.instance.Encode<SEntryData>(world.worldMapNet.mapData.GetData((int)x, (int)y));
    }

    [LuaByteBufferAttribute]
    public byte[] GetPathMsg(int index)
    {
        if (world == null)
            return new byte[0];
        return NetworkManager.instance.Encode<SEntryPathInfo>(world.worldMapNet.pathData.GetData(index));
    }

    public bool VaildTilePos(uint x, uint y)
    {
        if (world == null)
            return false;
        int serverx = (int)x / WorldMapNet.ServerBlockSize;
        int servery = (int)y / WorldMapNet.ServerBlockSize;
        int index = servery * WorldMapNet.ServerBlockTotalCount + serverx;
        return world.worldMapNet.mapData.SEntryData.ContainsKey(index);
    }

    byte[] ShowPathInfo(int id)
    {
        if (world == null)
            return new byte[0];
        SEntryPathInfo sEntryPathInfo = null;
        sEntryPathInfo = world.worldMapNet.pathData.GetData(id);
        return NetworkManager.instance.Encode<SEntryPathInfo>(sEntryPathInfo);
    }

    public void UpdateTerrain()
    {
        if (world == null)
            return;
        world.worldMapUpdata.UpdateTerritory(worldCamera.ViewRect(true));
    }

    public void PlayEffect(int x, int y, int id, float time)
    {
        if (world == null)
            return;
        world.worldMapEffect.ShowEffect(x, y, id, time);
    }

    public Transform GetCacheBuildTrf(int x, int y, int sw, int sh)
    {
        if (world == null)
            return null;
        return world.worldMapUpdata.worldMapBuild.GetCacheBuildTrf(x, y, sw, sh);
    }


    public int GetSprite(int x, int y)
    {
        if (world == null)
            return 0;
        int _x = Mathf.Min(world.WorldInfo.LogicServerSizeX, x);
        _x = Mathf.Max(0, _x);
        int _y = Mathf.Min(world.WorldInfo.LogicServerSizeY, y);
        _y = Mathf.Max(0, _y);

        return Main.Instance.WorldBlockInfo[_x, _y] & 0x7f;
        //Vec2Int v = new Vec2Int();
        //v.x = x;
        //v.y = y;
        //world.WorldInfo.LBlockMap.WorldPos2LogicPos(ref v);
        //int index = (world.WorldInfo.LogicWCount - v.x - 1) * world.WorldInfo.LogicHCount + v.y;
        //return world.WorldInfo.LogicTags[index];
    }

    public void OverlayPosition(Transform tf, int x, int y)
    {
        if (world == null)
            return;
        //Vector3 pos = GetCurPosToWorldPos(x, y, 0);
        //Vector3 worldPos = world.WCamera.WorldToViewportPoint(pos);
        //worldPos = UICamera.mainCamera.ViewportToWorldPoint(pos);
        NGUIMath.OverlayPosition(tf, GetCurPosToWorldPos(x, y, 0), world.WCamera, UICamera.mainCamera);
        Vector3 worldPos = tf.localPosition;
        worldPos.z = 0;
        tf.localPosition = worldPos;
    }

    public BorderData GetBorderData()
    {
        if (world == null)
            return null;
        return world.worldMapNet.borderData;
    }

    public TerrainUnionBuildPreview GetUnionBuildPreview()
    {
        if (world == null)
            return null;
        if (!world.Vaild)
            return null;
        return world.UnionBuildPreview;
    }

    [LuaByteBufferAttribute]
    public byte[] MapBgClick(Vector3 touch)
    {
        if (world == null || !world.Vaild)
            return new byte[0];
        Ray ray = Camera.main.ScreenPointToRay(touch);
        float t = 0;
        Vector3 p = world.GetRay2Terrain(ray);
        p.x += world.WorldInfo.LogicBlockSize * 0.5f;
        p.z += world.WorldInfo.LogicBlockSize * 0.5f;
        world.WorldInfo.LBlockMap.WorldPos2WLogicPos(p, world.WorldInfo, ref SelectPos);
        curPos.x = SelectPos.x;
        curPos.y = SelectPos.y;
        byte[] bytes = new byte[0];
        if (world.worldMapNet.pathData.SEntryPathInfo.Count > 0)
        {
            ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                bytes = ShowPathInfo(hit.collider.transform.parent.GetComponent<SMCInfo>().smc_id);
            }
        }
        return bytes;
    }

    public void SelectTile(int x, int y, int multiSizeX, int multiSizeY)
    {
        if (world == null)
            return;
        Vec2Int v = new Vec2Int();
        v.x = x;
        v.y = y;
        world.WorldInfo.ShowSelectionBox(v, multiSizeX, multiSizeY, 1f);
    }

    public void SelectTile(int x, int y)
    {
        if (world == null)
            return;
        Vec2Int v = new Vec2Int();
        v.x = x;
        v.y = y;
        int buildValue = world.WorldInfo.WBlockMap.GetBuild(ref v);
        if (buildValue > 100000)
        {
            int multiSizeX = world.worldMapUpdata.GetNumberPos(buildValue, 7);
            int multiSizeY = world.worldMapUpdata.GetNumberPos(buildValue, 6);
            int mx = world.worldMapUpdata.GetNumberPos(buildValue, 5);
            int my = world.worldMapUpdata.GetNumberPos(buildValue, 4);
            v.x = v.x - mx;
            v.y = v.y - my;
            world.WorldInfo.ShowSelectionBox(v, multiSizeX, multiSizeY, 1f);
        }
        else
        {
            v.x = x;
            v.y = y;
            world.WorldInfo.ShowSelectionBox(v, 1, 1, 1f);
        }
    }

    public Vector3 GetCurPosToWorldPos(int x, int y, float height)
    {
        if (world == null)
            return Vector3.zero;
        Vector3 tmpVec3 = new Vector3();
        tmpVec3.x = Mathf.FloorToInt(x * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.y = height;
        tmpVec3.z = Mathf.FloorToInt(y * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        //tmpVec3 = world.World2TerrainPos(tmpVec3);
        tmpVec3.x += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        tmpVec3.z += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        return tmpVec3;// world.CW.TransformPoint(tmpVec3,BEND_TYPE.Universal);
    }

    public Vector3 CameraCurPosToWorldPos(int x, int y, float height)
    {
        if (world == null)
            return Vector3.zero;
        Vector3 tmpVec3 = new Vector3();
        tmpVec3.x = Mathf.FloorToInt(x * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.y = height;
        tmpVec3.z = Mathf.FloorToInt(y * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        //tmpVec3 = world.World2TerrainPos(tmpVec3);
        tmpVec3.x += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        tmpVec3.z += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        return tmpVec3;
    }

    public void FollowAircraft(int id)
    {
        followId = id;
    }

    public void SetCamera(Vector3 pos)
    {
        if (worldCamera == null)
            return;
        tmpFollow = pos;
        tmpFollow.y = worldCamera.transform.position.y;
        worldCamera.transform.position = tmpFollow;
    }

    public void AddLine(SEntryPathInfo sEntryPathInfo, int startPosX, int startPosY, int endPosX, int endPosY, Color c)
    {
        if (world == null)
            return;
        Aircraft air = new Aircraft();
        air.sEntryPathInfo = sEntryPathInfo;
        air.startPosX = startPosX;
        air.startPosY = startPosY;
        air.endPosX = endPosX;
        air.endPosY = endPosY;
        air.color = c;
        world.worldMapUpdata.worldMapAircraft.Aircrafts.Add(air);
    }

    public void DrawLine()
    {
        if (world == null)
            return;
        world.worldMapUpdata.UpdateAircraft(worldCamera.ViewRect(true));
    }

    public void ClearLine()
    {
        if (world == null)
            return;
        if (world.worldMapUpdata.worldMapAircraft.Tlines.Count <= 0)
        {
            return;
        }
        for (int i = world.worldMapUpdata.worldMapAircraft.Tlines.Count - 1; i >= 0; i--)
        {
            world.WorldInfo.RemoveLine(world.worldMapUpdata.worldMapAircraft.Tlines[i]);
            world.worldMapUpdata.worldMapAircraft.Tlines.RemoveAt(i);
        }
    }

    public void TerritoryShow()
    {
        if (world == null)
            return;
        world.WorldInfo.NeedShowMarkerBox = true;
    }

    public void TerritoryHide()
    {
        if (world == null)
            return;
        world.WorldInfo.NeedShowMarkerBox = false;
    }

    public void ShowTerritoryName(bool ispress)
    {
        if (world == null)
            return;
        if (ispress)
        {
            if (world.WorldInfo.NeedShowMarkerBox)
                world.TerritoryHUD.Show();
        }
        else
            world.TerritoryHUD.Hide();
    }

    private Vector3 tmp = Vector3.zero;
    public void CameraMove(int deltaX, int detltaY)
    {
        if(worldCamera == null)
            return;

        //if (!WorldMapMgr.instance.SupportCameraMove)
        //    return;
        tmp.x = deltaX;
        tmp.z = detltaY;
        //if (world.IsInMobaBorder(ref tmp))
        //    return;
        if (worldCamera != null)
            worldCamera.CameraMove(tmp);
    }

    public void GetData()
    {
        if(world == null)
            return;
        CenterPos = world.WorldInfo.LBlockMap.WorldPos2WLogicPos(worldCamera.transform.localPosition, world.WorldInfo);
        //视角中心点平移到服务器屏中心点但是还是视角位置
        Vec2Int sCenterPos = new Vec2Int();
        sCenterPos.x = CenterPos.x + (WorldMapNet.ServerBlockSize / 2 - (CenterPos.x % world.WorldInfo.LogicServerSizeX) % WorldMapNet.ServerBlockSize);
        sCenterPos.y = CenterPos.y + (WorldMapNet.ServerBlockSize / 2 - (CenterPos.y % world.WorldInfo.LogicServerSizeY) % WorldMapNet.ServerBlockSize);
        CheckRect.SetPos(sCenterPos.x, sCenterPos.y);
        if (OldCenterPos.x != CenterPos.x || OldCenterPos.y != CenterPos.y)
        {
            CenterX = CenterPos.x;
            CenterY = CenterPos.y;
            world.ChangePosToMoba(ref CenterX, ref CenterY);
            //if (OnMoveEvent != null)
            //    OnMoveEvent();
            world.worldMapNet.ClearAllCache();
            RequestData(sCenterPos);
        }
    }

    public Vector2 GetInitPos()
    {
        if(world == null)
            return Vector2.zero;
        return new Vector2(InitX * world.WorldInfo.ChunkSize * 0.5f - world.WorldInfo.HRValue.z,
            InitY * world.WorldInfo.ChunkSize * 0.5f - world.WorldInfo.HRValue.w);
    }

    void Update()
    {
        if(world == null)
            return;
        if (!world.Vaild)
            return;
        CenterPos = world.WorldInfo.LBlockMap.WorldPos2WLogicPos(worldCamera.transform.localPosition, world.WorldInfo);
        if (!WorldData.RectContains(CheckRect, CenterPos.x, CenterPos.y))
        {
            //if (OnMoveEvent != null)
            //    OnMoveEvent();
            //视角中心点平移到服务器屏中心点但是还是视角位置
            Vec2Int sCenterPos = new Vec2Int();
            sCenterPos.x = CenterPos.x + (WorldMapNet.ServerBlockSize / 2 - (CenterPos.x % world.WorldInfo.LogicServerSizeX) % WorldMapNet.ServerBlockSize);
            sCenterPos.y = CenterPos.y + (WorldMapNet.ServerBlockSize / 2 - (CenterPos.y % world.WorldInfo.LogicServerSizeY) % WorldMapNet.ServerBlockSize);
            RequestData(sCenterPos);
            CheckRect.SetPos(sCenterPos.x, sCenterPos.y);
        }
        if (OldCenterPos.x != CenterPos.x || OldCenterPos.y != CenterPos.y)
        {
            CenterX = CenterPos.x;
            CenterY = CenterPos.y;
            world.ChangePosToMoba(ref CenterX, ref CenterY);
            if (OnCenterMoveEvent != null)
                OnCenterMoveEvent();
            OldCenterPos = CenterPos;
        }
        if (SupportGuide)
        {
            GuideManager.instance.update(Time.deltaTime);
        }
    }

    public void RequestData(Vec2Int centerPos)
    {
        if(world == null)
            return;
        if (UsedLocalData)
            return;
        //centerPos.x += 8;
        //centerPos.y += 8;
        world.worldMapNet.RequestMapData(centerPos, null);
        world.worldMapNet.RequestBorderData(centerPos, null);
        world.worldMapNet.RequestPathData(centerPos, null);
    }

    public void RequestAll()
    {
        if(world == null)
            return;
        if (UsedLocalData)
            return;
        CenterPos = world.WorldInfo.LBlockMap.WorldPos2WLogicPos(worldCamera.transform.localPosition, world.WorldInfo);
        //CenterPos.x += 8;
        //CenterPos.y += 8;
        world.worldMapNet.RequestMapData(CenterPos, null);
        world.worldMapNet.RequestBorderData(CenterPos, null);
        world.worldMapNet.RequestPathData(CenterPos, null);
    }

    public void OnDestroy()
    {
        NetworkManager.instance.Request<SceneMapCloseRequest>((uint)MsgCategory.Map, (uint)MapTypeId.Map.SceneMapCloseRequest, null, (data) => { });
        NetworkManager.instance.UnRegisterPushMsgCallback((uint)MsgCategory.Map, (uint)MapTypeId.Map.SceneMapEventPush);
        NetworkManager.instance.UnRegisterPushMsgCallback((uint)MsgCategory.Moba, (uint)MobaTypeId.Moba.MsgMobaSceneMapEventPush);
        world = null;
        worldCamera = null;
        RangeMgr = null;
        instance = null;
        OnCenterMoveEvent = null;
        OnMoveEvent = null;
    }

    public void ShowEffect(int x, int y, int id)
    {
        if(world == null)
            return;
        if (!UsedLocalData)
            return;
        int lindex = (world.WorldInfo.LogicServerSizeX - x - 1) * world.WorldInfo.LogicServerSizeY + y;
        FastStack<int> effect = world.WorldInfo.WBlockMap.mEffectPool.Claim();
        effect.Add(id);
        world.WorldInfo.WBlockMap.SetEffect(lindex, effect);
        //world.worldMapBuildEffect.ShowEffect(x, y, id, index);
    }


    public void HideEffect(int x, int y)
    {
        if(world == null)
            return;
        if (!UsedLocalData)
            return;
        int lindex = (world.WorldInfo.LogicServerSizeX - x - 1) * world.WorldInfo.LogicServerSizeY + y;
        FastStack<int> effect = world.WorldInfo.WBlockMap.mEffectPool.Claim();
        effect.FastClear();
        world.WorldInfo.WBlockMap.SetEffect(lindex, effect);
    }

    public void SetHomeData(int x, int y, string palyerName, int homeLV, string guildBanner = null, int build_id = -1)
    {
        if(world == null)
            return;
        if (!UsedLocalData)
            return;

        //Serclimax.ScBuildingCoreData tileData = Main.Instance.TableMgr.GetBuildCoreDataByLevel(homeLV);
        //world.WorldInfo.WBlockMap.SetBuild(lindex, tileData.picture);
        SEntryData ed = new SEntryData();
        ed.data = new SEntryBaseData();
        ed.data.entryType = (int)ProtoMsg.SceneEntryType.SceneEntryType_Home;
        ed.data.pos = new Position();
        ed.data.pos.x = (uint)x;
        ed.data.pos.y = (uint)y;

        ed.home = new SEntryHome();
        ed.home.name = palyerName;
        if (build_id < 0)
            ed.home.charid = (uint)CharId;
        else
            ed.home.charid = 0;
        ed.home.homelvl = (uint)homeLV;
        ed.ownerguild = new OwnerGuildInfo();
        if (guildBanner != null)
        {
            ed.ownerguild.guildbanner = guildBanner;
            ed.ownerguild.guildid = (uint)GuildId;
        }
        SetSEntryData(ed);
        if (build_id > 0)
        {
            int lindex = (world.WorldInfo.LogicServerSizeX - x - 1) * world.WorldInfo.LogicServerSizeY + y;
            world.WorldInfo.WBlockMap.SetBuild(lindex, build_id);
        }
    }

    public void RemoveHomeData(int x, int y)
    {
        if(world == null)
            return;
        int dataIndex = y * world.WorldInfo.LogicServerSizeY + x;
        world.worldMapNet.mapData.SEntryData[dataIndex] = null;
        int lindex = (world.WorldInfo.LogicServerSizeX - x - 1) * world.WorldInfo.LogicServerSizeY + y;
        world.WorldInfo.WBlockMap.SetBuild(lindex, 0);
    }

    public void ClearPathData()
    {
        world.worldMapNet.pathData.SEntryPathInfo.Clear();
        world.worldMapUpdata.worldMapAircraft.Aircrafts.Clear();
    }

    private Dictionary<string, TLine> mCustomLines = new Dictionary<string, TLine>();
    public void SetCustomLine(string name, int start_x, int start_y, int end_x, int end_y, Color color, float speed)
    {
        if(world == null)
            return;
        RemoveCustomLine(name);
        Vector3 start = Vector3.zero;
        world.WorldInfo.LBlockMap.WLogicPos2WorldPos(ref start, start_x, start_y, world.WorldInfo);
        Vector3 end = Vector3.zero;
        world.WorldInfo.LBlockMap.WLogicPos2WorldPos(ref end, end_x, end_y, world.WorldInfo);
        mCustomLines.Add(name, world.WorldInfo.AddLine(start, end, color, speed));
        world.WorldInfo.ApplyLine();
    }

    public void RemoveCustomLine(string name)
    {
        if(world == null)
            return;
        if (mCustomLines.ContainsKey(name))
        {
            world.WorldInfo.RemoveLine(mCustomLines[name]);
            mCustomLines.Remove(name);
            world.WorldInfo.ApplyLine();
        }
    }
    int pathIdCount = 0;
    //(int)ProtoMsg.SceneEntryType.SceneEntryType_Home  (int)ProtoMsg.SceneEntryType.SceneEntryType_ActMonster
    public void SetPathData(int start_x, int start_y, int end_x, int end_y, string path_name, int target_entry_type, int starttime, int time, string guildBanner = null)
    {
        if(world == null)
            return;
        if (!UsedLocalData)
            return;
        if (pathIdCount > 100000000)
            pathIdCount = 0;
        SEntryPathInfo path = new SEntryPathInfo();
        path.pathId = (uint)++pathIdCount;
        path.ownerguild = new OwnerGuildInfo();
        path.tarEntryType = (uint)target_entry_type;
        path.charid = 0;
        if (target_entry_type == (int)ProtoMsg.SceneEntryType.SceneEntryType_Home)
        {
            path.pathType = (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackPlayer;

        }
        else if (target_entry_type == (int)ProtoMsg.SceneEntryType.SceneEntryType_Monster)
        {
            path.pathType = (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackMonster;
            path.charid = (uint)CharId;
            path.ownerguild.guildbanner = guildBanner;
            path.ownerguild.guildid = (uint)GuildId;
        }
        else
        {
            path.pathType = (int)ProtoMsg.TeamMoveType.TeamMoveType_Camp;
        }
        path.starttime = (uint)starttime;
        path.time = (uint)time;
        path.sourcePos = new Position();
        path.sourcePos.x = (uint)start_x;
        path.sourcePos.y = (uint)start_y;
        path.targetPos = new Position();
        path.targetPos.x = (uint)end_x;
        path.targetPos.y = (uint)end_y;
        path.status = (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go;
        path.charname = path_name;
        world.worldMapNet.pathData.SetData(path);
        world.worldMapNet.pathData.SetPathData(path);
    }

    public void FollowRebelSurround()
    {
        if (RebelPathId > 0)
        {
            FollowAircraft((int)RebelPathId);
        }
    }

    public int MapVersion()
    {
        if(world == null)
            return 0;
        return world.worldMapNet.mapVersion;
    }

    [LuaByteBufferAttribute]
    public byte[] GetMapData()
    {
        if(world == null)
            return new byte[0];
        //return NetworkManager.instance.Encode<PosISceneEntrysInfoResponse>(world.worldMapNet.msgPosISceneEntrysInfoResponseAll);
        return world.worldMapNet.mapBytes;
    }

    public int PathVersion()
    {
        if(world == null)
            return 0;
        return world.worldMapNet.pathVersion;
    }

    [LuaByteBufferAttribute]
    public byte[] GetPathData()
    {
        if(world == null)
            return new byte[0];
        //return NetworkManager.instance.Encode<SceneMapPathInfoV2Response>(world.worldMapNet.msgSceneMapPathInfoResponseAll);
        return world.worldMapNet.pathBytes;
    }

    private List<bool> mSwitch_MapHUDInfo4Luas = null;

    private void InitSwitch_MapHUDInfo4Lua()
    {
        if (mSwitch_MapHUDInfo4Luas != null)
            return;
        string str_list = (string)LuaClient.GetMainState().GetFunction("WorldMapHUD.GetSwitch_MapHUDInfo4Luas").Call(null)[0];
        if (str_list == null)
            return;
        if (String.IsNullOrEmpty(str_list))
            return;
        string[] switch_strs = str_list.Split(',');
        if (switch_strs.Length == 0)
            return;
        mSwitch_MapHUDInfo4Luas = new List<bool>();
        for (int i = 0; i < switch_strs.Length; i++)
        {
            mSwitch_MapHUDInfo4Luas.Add(int.Parse(switch_strs[i]) > 0);
        }
    }

    public bool EnableMapHUDInfo4Lua(SceneEntryType entry_type)
    {
        InitSwitch_MapHUDInfo4Lua();
        if (mSwitch_MapHUDInfo4Luas == null)
            return false;
        int t = (int)entry_type;
        if (t >= mSwitch_MapHUDInfo4Luas.Count)
            return false;
        return mSwitch_MapHUDInfo4Luas[t];
    }

    private Dictionary<int,bool> mSwitch_PathHUDInfo4Luas = null;

    private void InitSwitch_PathHUDInfo4Lua()
    {
        if (mSwitch_PathHUDInfo4Luas != null)
            return;
        string str_list = (string)LuaClient.GetMainState().GetFunction("WorldMapHUD.GetSwitch_PathHUDInfo4Luas").Call(null)[0];
        if (str_list == null)
            return;
        if (String.IsNullOrEmpty(str_list))
            return;
        string[] switch_strs = str_list.Split(';');
        if (switch_strs.Length == 0)
            return;
        mSwitch_PathHUDInfo4Luas = new Dictionary<int, bool>();
        string[] pstr;
        for (int i = 0; i < switch_strs.Length; i++)
        {
            pstr = switch_strs[i].Split(',');

            mSwitch_PathHUDInfo4Luas.Add(int.Parse(pstr[0]),int.Parse(pstr[1]) > 0);
        }
    }

    public bool EnablePathHUDInfo4Lua(TeamMoveType move_type)
    {
        InitSwitch_PathHUDInfo4Lua();
        if (mSwitch_PathHUDInfo4Luas == null)
            return false;
        bool result = false;
        mSwitch_PathHUDInfo4Luas.TryGetValue((int)move_type, out result);
        return result;
    }

    private int mEnableHotFixedDebug = -1;
    public bool enable_hot_fixed_debug
    {
        get
        {
            if (mEnableHotFixedDebug < 0)
            {
               bool debug =  (bool)LuaClient.GetMainState().GetFunction("WorldMapHUD.EnableHotFixedDebug").Call(null)[0];
                mEnableHotFixedDebug = debug ? 1 : 0;
            }
            return mEnableHotFixedDebug > 0;
        }
    }
}
