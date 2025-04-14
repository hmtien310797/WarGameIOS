using UnityEngine;
using ProtoMsg;
using System.Collections;

public class WorldHUDCacheBlock
{
    private WorldHUD _hud;
    public WorldHUD hud
    {
        get
        {
            return _hud;
        }

        set
        {
            _hud = value;
        }
    }

    private WorldHUDCacheBlock _next;
    public WorldHUDCacheBlock next
    {
        get
        {
            return _next;
        }

        set
        {
            _next = value;
        }
    }

    private WorldHUDCacheBlock _prev;
    public WorldHUDCacheBlock prev
    {
        get
        {
            return _prev;
        }

        set
        {
            _prev = value;
        }
    }

    public WorldHUDCacheBlock(WorldHUD hud)
    {
        _hud = hud;

        _next = null;
        _prev = null;
    }

    public static WorldHUDCacheBlock operator ++(WorldHUDCacheBlock cacheBlock)
    {
        cacheBlock = cacheBlock.next;

        return cacheBlock;
    }

    public static WorldHUDCacheBlock operator --(WorldHUDCacheBlock cacheBlock)
    {
        cacheBlock = cacheBlock.prev;

        return cacheBlock;
    }
}

public class WorldHUDCacheSet
{
    private int _associativity;
    public int associativity
    {
        get
        {
            return _associativity;
        }
    }

    private int _count;
    public int count
    {
        get
        {
            return _count;
        }

        set
        {
            _count = value;
        }
    }

    private Stack _gc;
    public Stack gc
    {
        get
        {
            return _gc;
        }
    }

    private WorldHUDCacheBlock _mruBlock;
    private WorldHUDCacheBlock mruBlock
    {
        get
        {
            return _mruBlock;
        }

        set
        {
            if (_mruBlock == value)
                return;

            WorldHUDCacheBlock prevBlock = value.prev;
            WorldHUDCacheBlock nextBlock = value.next;

            if (lruBlock == value)
                lruBlock = prevBlock;

            if (prevBlock != null)
                prevBlock.next = nextBlock;

            if (nextBlock != null)
                nextBlock.prev = prevBlock;

            value.next = mruBlock;
            value.prev = null;

            if (_mruBlock != null)
                _mruBlock.prev = value;

            _mruBlock = value;
        }
    }

    private WorldHUDCacheBlock _lruBlock;
    private WorldHUDCacheBlock lruBlock
    {
        get
        {
            return _lruBlock;
        }

        set
        {
            _lruBlock = value;
        }
    }

    public WorldHUDCacheSet(int associativity, Stack gc)
    {
        _associativity = associativity;
        _gc = gc;

        _mruBlock = null;
        _lruBlock = null;
    }

    public void Push(WorldHUD hud)
    {
        WorldHUDCacheBlock cacheBlock = null;

        if (count == associativity)
        {
            lruBlock.hud.Hide();

            gc.Push(lruBlock.hud);

            cacheBlock = lruBlock;
            cacheBlock.hud = hud;
        }
        else
        {
            cacheBlock = new WorldHUDCacheBlock(hud);
            count++;
        }

        mruBlock = cacheBlock;

        if (lruBlock == null)
            lruBlock = cacheBlock;

        cacheBlock.hud.Show();

        for (cacheBlock++; cacheBlock != null; cacheBlock++)
            cacheBlock.hud.Hide();
    }

    public WorldHUD Query(int id)
    {
        WorldHUD result = null;
        for (WorldHUDCacheBlock cacheBlock = mruBlock; cacheBlock != null; cacheBlock++)
        {
            WorldHUD hud = cacheBlock.hud;
            if (hud.id == id)
            {
                WorldHUDCacheBlock temp = cacheBlock.prev;
                mruBlock = cacheBlock;

                if (temp != null)
                    cacheBlock = temp;

                hud.Show();
                result = hud;
            }
            else
                hud.Hide();
        }

        return result;
    }
}

public class WorldHUDCache
{
    [SerializeField]
    private int _size;
    public int size
    {
        get
        {
            return _size;
        }
    }

    private WorldHUDCacheSet[,] _memory;
    private WorldHUDCacheSet[,] memory
    {
        get
        {
            return _memory;
        }
    }

    private Stack _gc;
    private Stack gc
    {
        get
        {
            return _gc;
        }
    }

    public WorldHUDCache(int size, int associativity, int numPreloadedPrefabs = 128)
    {
        _size = size;
        _gc = new Stack();

        _memory = new WorldHUDCacheSet[size, size];
        for (int x = 0; x < size; x++)
            for (int y = 0; y < size; y++)
                _memory[x, y] = new WorldHUDCacheSet(associativity, gc);

        for (int n = 0; n < numPreloadedPrefabs; n++)
        {
            WorldHUD hud = Object.Instantiate(WorldMapMgr.Instance.world.WorldInfo.worldMapHUD[(int)WorldHUDType.TERRITORY]);
            hud.Hide();
            hud.transform.parent = WorldMapMgr.Instance.world.TerritoryHUD.transform;
            gc.Push(hud);
        }
    }

    public void Push(int x, int y, WorldHUD hud)
    {
        hud.id = WorldHUDMgr.PositionToId(x, y, hud.type);

        memory[x % size, y % size].Push(hud);
    }

    public WorldHUD GetReusableHUD()
    {
        return gc.Count == 0 ? null : (WorldHUD)gc.Pop();
    }

    public WorldHUD Query(int x, int y, WorldHUDType type)
    {
        return memory[x % size, y % size].Query(WorldHUDMgr.PositionToId(x, y, type));
    }
}

public class WorldHUDMgr : MonoBehaviour
{
    public bool faceToCamera = false;
    public bool showOnClick = false;
    public bool support_lua_Fortress = true;
    public bool support_lua_Government = true;
    public bool support_lua_Turret = true;


    private WorldHUD hud;
    private object data;

    [SerializeField]
    private WorldHUDType type = WorldHUDType.DEFAULT;

    private static readonly Color COLOR_BLUE = new Color(0x93 / 255f, 0xcc / 255f, 0xff / 255f);
    private static readonly string FORMAT_PLAYERNAME_WITH_GUILDBANNER = "[{0}]{1}";

    public void Initialize(WorldHUDType type)
    {
        hud = Instantiate(WorldMapMgr.Instance.world.WorldInfo.worldMapHUD[(int)type]);
    }

    public void Initialize(string prefab)
    {
        hud = Instantiate(ResourceLibrary.GetUIPrefab("WorldMapHUD/" + prefab).GetComponent<WorldHUD>());
    }

    public void Refresh(WorldHUDType type, object data)
    {
        if (this.type == type)
            this.data = data;
    }

    public void InitializeHUD(WorldHUDType type, int i)
    {
        if (i < 0)
            return;

        if (type == WorldHUDType.BUILDING && this.type == WorldHUDType.DEFAULT)
        {
            if (hud != null)
                return;

            data = WorldMapMgr.Instance.world.worldMapNet.mapData.GetData(i % WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeX, i / WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeY);
            if (data == null)
                return;

            this.type = WorldHUDType.BUILDING;

            uint entryType = ((SEntryData)data).data.entryType;
            if (entryType == (uint)SceneEntryType.SceneEntryType_Home) // 玩家基地
            {
                Initialize(WorldHUDType.BASE);
                SetBaseInfo();
            }
            else
            if (!WorldMapMgr.instance.enable_hot_fixed_debug &&
                (entryType >= (uint)SceneEntryType.SceneEntryType_ResFood && entryType <= (uint)SceneEntryType.SceneEntryType_ResElec)) // 资源田
            {
                Initialize(WorldHUDType.RESOURCE);
                SetResourceInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Monster) // 叛军
            {
                Initialize(WorldHUDType.REBEL_ARMY);
                SetRebelArmyInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_WorldMonster)
            {
                Initialize(WorldHUDType.REBEL_ARMY);
                SetRebelArmyInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_ActMonster)
            {
                SEntryMonster enemy = ((SEntryData)data).monster;
                if (enemy == null)
                    return;

                if (enemy.guildMon != null && enemy.guildMon.guildMonster) // 联盟怪物
                    return;
                else if (enemy.digMon != null && enemy.digMon.monsterBaseId > 0) // 叛军宝藏
                {
                    Initialize(WorldHUDType.REBEL_ARMY_TREASURE);
                    SetRebelArmyTreasureInfo();
                }
                else // 炮车
                {
                    Initialize(WorldHUDType.REBEL_ARMY);
                    SetPanzerInfo();
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_SiegeMonster) // 叛军基地
            {
                Initialize(WorldHUDType.REBEL_ARMY_BASE);
                SetRebelArmyBaseInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Fort) // 叛军要塞
            {
                Initialize(WorldHUDType.REBEL_ARMY_FORTRESS);
                SetRebelArmyFortressInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_GuildBuild) // 联盟建筑
            {
                Initialize(WorldHUDType.ALLIANCE_BUILDING);
                SetAllianceBuildingInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Barrack) // 驻防
            {
                Initialize(WorldHUDType.OCCUPY);
                SetGarrisonInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Occupy) // 占领
            {
                Initialize(WorldHUDType.OCCUPY);
                SetOccupyInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Govt) // 战区政府
            {
                Initialize(WorldHUDType.GOVERNMENT);
                SetGovernmentInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Turret) // 炮塔
            {
                Initialize(WorldHUDType.TURRENT);
                SetTurretInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_EliteMonster) // 精英叛军
            {
                Initialize(WorldHUDType.ELITE_REBEL_ARMY);
                SetEliteRebelArmyInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Stronghold) // 据点
            {
                SEntryData edata = (SEntryData)data;
                StrongholdData stronghold = edata.centerBuild.stronghold;
                if (stronghold != null && stronghold.available)
                {
                    Initialize(WorldHUDType.GOVERNMENT);
                    SetStrongholdInfo(stronghold);
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Fortress) // 新要塞
            {
                SEntryData edata = (SEntryData)data;
                FortressData fortress = edata.centerBuild.fortress;
                if (fortress != null && fortress.available)
                {
                    Initialize(WorldHUDType.GOVERNMENT);
                    SetFortressInfo(fortress);
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_WorldCity) // 新要塞
            {
                SEntryData edata = (SEntryData)data;
                if (edata.worldCity != null)
                {
                    Initialize(WorldHUDType.OCCUPY);
                    SetWorldCity((int)edata.worldCity.cityId);
                }

            }

            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaGate) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    Initialize(WorldHUDType.MOBA_BASE);
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaGateInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaGateInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaCenter) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    Initialize(WorldHUDType.MOBA_BASE);

                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaCenterInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaCenterInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaArsenal) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    Initialize(WorldHUDType.MOBA_BASE);
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaArsenalInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaArsenalInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaFort) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    Initialize(WorldHUDType.MOBA_BASE);
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaFortInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaFortInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaInstitute) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    Initialize(WorldHUDType.MOBA_BASE);
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaInstituteInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaInstituteInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaTransPlat) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    Initialize(WorldHUDType.MOBA_BASE);
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaTransPlatInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaTransPlatInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaSmallBuild) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    Initialize(WorldHUDType.MOBA_BASE);
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaSmallBuildInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaSmallBuildInfo(mobaBuild);
                    }
                }
            }
            else // Lua
            {
                uint x = ((SEntryData)data).data.pos.x;
                uint y = ((SEntryData)data).data.pos.y;
                LuaInterface.LuaFunction f = LuaClient.GetMainState().GetFunction("WorldMapHUD.InitializeHUD");
                if (f != null)
                    f.Call(this, (uint)((SEntryData)data).data.entryType, x, y);
            }


            if (hud)
            {
                Vector3 shift = hud.transform.position;
                hud.transform.parent = gameObject.transform;
                hud.transform.localPosition = shift;
            }

            ParallelToScreen();
        }
        else if (type == WorldHUDType.TERRITORY && (this.type == WorldHUDType.TERRITORY || this.type == WorldHUDType.DEFAULT)) // 领地
        {
            int x = i % WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeX;
            int y = i / WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeY;

            if (WorldMapMgr.Instance.world.TerritoryHUDBuffer.Query(x, y, WorldHUDType.TERRITORY) == null && WorldMapMgr.Instance.world.WorldInfo.WBlockMap.GetBuild((WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeX - 1 - x) * WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeY + y) == 0)
            {
                data = WorldMapMgr.Instance.world.worldMapNet.borderData.GetBorderDataByXY(x, y);
                if (data == null)
                    return;
                hud = WorldMapMgr.Instance.world.TerritoryHUDBuffer.GetReusableHUD();
                if (hud == null)
                    Initialize(WorldHUDType.TERRITORY);

                WorldMapMgr.Instance.world.TerritoryHUDBuffer.Push(x, y, hud);

                SetWidgetText(0, ((MapGuildBlock)data).guildbanner);

                hud.transform.parent = gameObject.transform;
                hud.transform.localPosition = new Vector3((x + 0.5f) * WorldMapMgr.Instance.world.WorldInfo.LogicBlockSize - WorldMapMgr.Instance.world.WorldInfo.HRValue.z, 0, (y + 0.5f) * WorldMapMgr.Instance.world.WorldInfo.LogicBlockSize - WorldMapMgr.Instance.world.WorldInfo.HRValue.z);
                SetHUDInfoInLua();
            }
        }
        else if (type == WorldHUDType.EXPEDITION && this.type == WorldHUDType.DEFAULT) // 飞机
        {
            data = WorldMapMgr.Instance.world.worldMapNet.pathData.GetData(i);
            if (data == null)
                return;
            gameObject.layer = 17;

            this.type = WorldHUDType.EXPEDITION;
            Initialize(WorldHUDType.EXPEDITION);

            SetExpeditionInfo(i);

            Vector3 shift = hud.transform.position;
            hud.transform.parent = gameObject.transform;
            hud.transform.localPosition = shift;

            ParallelToScreen();
        }
    }

    public void RefreshHUD(WorldHUDType type, int i)
    {
        if (i < 0 || this.type != type)
            return;
        if (type == WorldHUDType.BUILDING)
        {
            data = WorldMapMgr.Instance.world.worldMapNet.mapData.GetData(i % WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeX, i / WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeY);
            if (data == null)
                return;
            int x = i % WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeX;
            int y = i / WorldMapMgr.Instance.world.WorldInfo.LogicServerSizeY;
            data = WorldMapMgr.Instance.world.worldMapNet.mapData.GetData(x, y);

            if (hud == null || data == null)
                return;
            uint entryType = ((SEntryData)data).data.entryType;
            if (entryType == (uint)SceneEntryType.SceneEntryType_Home)
                SetBaseInfo();
            else if (!WorldMapMgr.instance.enable_hot_fixed_debug &&
                (entryType >= (uint)SceneEntryType.SceneEntryType_ResFood && entryType <= (uint)SceneEntryType.SceneEntryType_ResElec))
                SetResourceInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Monster)
                SetRebelArmyInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_WorldMonster)
                SetRebelArmyInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_ActMonster)
            {
                SEntryMonster enemy = ((SEntryData)data).monster;
                if (enemy == null)
                    return;

                if (enemy.guildMon != null && enemy.guildMon.guildMonster) // 联盟怪物
                    return;
                else if (enemy.digMon != null && enemy.digMon.monsterBaseId > 0) // 叛军宝藏
                    SetRebelArmyTreasureInfo();
                else // 炮车
                    SetPanzerInfo();
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_SiegeMonster) // 叛军基地
                SetRebelArmyBaseInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Fort) // 叛军要塞
                SetRebelArmyFortressInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_GuildBuild) // 联盟建筑
                SetAllianceBuildingInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Barrack) // 驻防
                SetGarrisonInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Occupy) // 占领
                SetOccupyInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Govt) // 战区政府
                SetGovernmentInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Turret) // 炮台
            {
                SetTurretInfo();
            }

            else if (entryType == (uint)SceneEntryType.SceneEntryType_Stronghold) // 据点
            {
                SEntryData edata = (SEntryData)data;
                StrongholdData stronghold = edata.centerBuild.stronghold;
                if (stronghold != null && stronghold.available)
                {
                    SetStrongholdInfo(stronghold);
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_Fortress) // 新要塞
            {
                SEntryData edata = (SEntryData)data;
                FortressData fortress = edata.centerBuild.fortress;
                if (fortress != null && fortress.available)
                {
                    SetFortressInfo(fortress);
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_WorldCity) // 新要塞
            {
                SEntryData edata = (SEntryData)data;
                if (edata.worldCity != null)
                {
                    SetWorldCity((int)edata.worldCity.cityId);
                }

            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_EliteMonster) // 精英叛军
                SetEliteRebelArmyInfo();
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaGate) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaGateInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaGateInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaCenter) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaCenterInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaCenterInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaArsenal) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaArsenalInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaArsenalInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaFort) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaFortInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaFortInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaInstitute) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaInstituteInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaInstituteInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaTransPlat) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaTransPlatInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaTransPlatInfo(mobaBuild);
                    }
                }
            }
            else if (entryType == (uint)SceneEntryType.SceneEntryType_MobaSmallBuild) // 据点
            {
                SEntryData edata = (SEntryData)data;
                SEntryMobaBuild mobaBuild = edata.mobaBuild;
                if (mobaBuild != null)
                {
                    if (WorldMapMgr.Instance.world.MobaMode == WorldMode.Moba)
                    {
                        SetMobaSmallBuildInfo(mobaBuild);
                    }
                    else if (WorldMapMgr.Instance.world.MobaMode == WorldMode.GuildMoba)
                    {
                        SetGuildMobaSmallBuildInfo(mobaBuild);
                    }
                }
            }
            else // Lua
            {
                LuaInterface.LuaFunction f = LuaClient.GetMainState().GetFunction("WorldMapHUD.RefreshHUD");
                if (f != null)
                    f.Call(this, (uint)((SEntryData)data).data.entryType, ((SEntryData)data).data.pos.x, ((SEntryData)data).data.pos.y);
            }
        }
        else if (type == WorldHUDType.EXPEDITION) // 飞机
        {
            data = WorldMapMgr.Instance.world.worldMapNet.pathData.GetData(i);
            if (data == null)
                return;
            SetExpeditionInfo(i);
        }
        //else if (type == WorldHUDType.TERRITORY)
        //{
        //    MapGuildBlock guild = WorldMapMgr.Instance.world.worldMapNet.borderData.MapGuildBlock[i];
        //    int x = i % 512;
        //    int y = i / 512;

        //    Vector3 shift = hud.transform.position;
        //    hud.transform.parent = this.gameObject.transform;
        //    hud.transform.position = new Vector3(x * WorldMapMgr.Instance.world.WorldInfo.LogicBlockSize + WorldMapMgr.Instance.world.WorldInfo.HRValue.x, 0, y * WorldMapMgr.Instance.world.WorldInfo.LogicBlockSize + WorldMapMgr.Instance.world.WorldInfo.HRValue.z) + shift;
        //}
    }

    public void Show()
    {
        // Vector3 zoom = gameObject.transform.parent.localScale;
        // gameObject.transform.localScale = new Vector3(1 / zoom.x, 1 / zoom.y, 1 / zoom.z);
        gameObject.SetActive(true);
    }

    public void Hide()
    {
        // gameObject.transform.localScale = Vector3.zero;
        gameObject.SetActive(false);
    }

    public void Awake()
    {
        if (showOnClick)
            Hide();
    }

    /**********************
     * API: Widget Setter *
     **********************/

    public void SetWidgetColor(int i, Color color)
    {
        SetWidgetColor(hud[i], color);
    }

    public void SetWidgetColor(WorldHUDWidget widget, Color color)
    {
        widget.color = color;
    }

    public void SetWidgetIcon(int i, Sprite sprite)
    {
        SetWidgetIcon(hud[i], sprite);
    }

    public void SetWidgetIcon(WorldHUDWidget widget, Sprite sprite)
    {
        widget.icon = sprite;
    }

    public void SetWidgetIconType(int i, uint iconType)
    {
        SetWidgetIconType(hud[i], iconType);
    }

    public void SetWidgetIconType(int i, int iconType)
    {
        SetWidgetIconType(hud[i], iconType);
    }

    public void SetWidgetIconType(WorldHUDWidget widget, uint iconType)
    {
        SetWidgetType(widget, (int)iconType);
    }

    public void SetWidgetIconType(WorldHUDWidget widget, int iconType)
    {
        widget.iconType = iconType;
    }

    public void SetWidgetX(int i, float x)
    {
        SetWidgetX(hud[i], x);
    }

    public void SetWidgetX(WorldHUDWidget widget, float x)
    {
        Vector3 currentLocalPosition = widget.localPosition;
        widget.localPosition = new Vector3(x, currentLocalPosition.y, currentLocalPosition.z);
    }

    public void SetWidgetY(int i, float y)
    {
        SetWidgetY(hud[i], y);
    }

    public void SetWidgetY(WorldHUDWidget widget, float y)
    {
        Vector3 currentLocalPosition = widget.localPosition;
        widget.localPosition = new Vector3(currentLocalPosition.x, y, currentLocalPosition.z);
    }

    public void SetWidgetLocalPosition(int i, float x, float y, float z)
    {
        SetWidgetLocalPosition(hud[i], x, y, z);
    }

    public void SetWidgetLocalPosition(WorldHUDWidget widget, float x, float y, float z)
    {
        SetWidgetLocalPosition(widget, new Vector3(x, y, z));
    }

    public void SetWidgetLocalPosition(int i, Vector3 localPosition)
    {
        SetWidgetLocalPosition(hud[i], localPosition);
    }

    public void SetWidgetLocalPosition(WorldHUDWidget widget, Vector3 localPosition)
    {
        widget.transform.localPosition = localPosition;
    }

    public void SetWidgetPercentage(int i, float percentage)
    {
        SetWidgetPercentage(hud[i], percentage);
    }

    public void SetWidgetPercentage(WorldHUDWidget widget, float percentage)
    {
        widget.percentage = percentage;
    }

    public void SetWidgetText(int i, string text)
    {
        SetWidgetText(hud[i], text);
    }

    public void SetWidgetText(int i, uint num)
    {
        SetWidgetText(hud[i], num.ToString());
    }

    public void SetWidgetText(WorldHUDWidget widget, string text)
    {
        widget.text = text;
    }
    public void SetWidgetText(int i, string text, int fontsize)
    {
        SetWidgetText(hud[i], text);
        WorldHUDLabel label = hud[i] as WorldHUDLabel;
        if (label)
        {
            label.SetFontSize(fontsize);
        }
    }

    public void SetWidgetType(int i, int type)
    {
        SetWidgetType(hud[i], type);
    }

    public void SetWidgetType(WorldHUDWidget widget, int type)
    {
        widget.type = type;
    }

    public void SetTimerTimeStamp(uint timeStamp)
    {
        WorldHUDTimer timer = hud.timer;
        if (timer != null)
            timer.timeStamp = timeStamp;
    }

    public void SetTimerUpdateFunction(System.Action<long, uint> updateFunction)
    {
        WorldHUDTimer timer = hud.timer;
        if (timer != null)
            timer.updateFunction = updateFunction;
    }

    public void ClearTimerStamp()
    {
        WorldHUDTimer timer = hud.timer;
        if (timer != null)
            timer.updateFunction = null;
    }

    /**********************
     * API: Widget Getter *
     **********************/

    public float GetWidgetWidth(int i)
    {
        return GetWidgetWidth(hud[i]);
    }

    public float GetWidgetWidth(WorldHUDWidget widget)
    {
        return widget.width;
    }

    /***************
     * Data Getter *
     ***************/

    public static int PositionToId(int x, int y, WorldHUDType type)
    {
        return ((int)type << 24) + (x << 12) + y;
    }

    public static int IdToPosition(Vector2 position, WorldHUDType type)
    {
        return (int)type << 24 + (int)position.x << 12 + (int)position.y;
    }

    public static Vector2 IdToWorldPosition(int id)
    {
        Vector2 position = new Vector2((id >> 12) & 0xfff, id & 0xfff);
        return position;
    }

    public int GetPlayerID()
    {
        return WorldMapMgr.Instance.CharId;
    }

    public int GetPlayerGuildID()
    {
        return WorldMapMgr.Instance.GuildId;
    }

    public ulong GetDataUID()
    {
        switch (type)
        {
            case WorldHUDType.BUILDING:
                return ((SEntryData)data).data.uid;
            default:
                return 0;
        }
    }

    public uint GetDataEntryType()
    {
        switch (type)
        {
            case WorldHUDType.BUILDING:
                return ((SEntryData)data).data.entryType;
            default:
                return 0;
        }
    }

    // Base

    public SEntryHome GetBaseData()
    {
        if (data == null)
            return null;

        switch (type)
        {
            case WorldHUDType.BUILDING:
                return ((SEntryData)data).home;

            default:
                return null;
        }
    }

    public uint GetBaseOwnerID()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.charid;
    }

    public uint GetBaseLevel()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.homelvl;
    }

    public uint GetBaseOfficialID()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.officialId;
    }

    public uint GetBaseGuildOfficialID()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.guildOfficialId;
    }

    public uint GetBaseGuildTitle()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;
        return home.guildtitle;
    }

    public uint GetBaseMilitaryRankId()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.militaryRankId;
    }

    public uint GetBaseGuildID()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.guildId;
    }

    public string GetBaseName()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return "";

        return home.name;
    }

    public uint GetBaseFortBadge()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.fortBadge;
    }

    public uint GetBaseNationality()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return 0;

        return home.nationality;
    }

    public bool HasPrisoner()
    {
        SEntryHome home = GetBaseData();
        if (home == null)
            return false;
        return home.prisoner != null && home.prisoner.info.Count > 0;
    }

    // Resource

    public SEntryResource GetResourceData()
    {
        SEntryResource resource = null;
        switch (type)
        {
            case WorldHUDType.BUILDING:
                resource = ((SEntryData)data).res;
                break;
            default:
                break;
        }

        return resource;
    }

    public uint GetResourceLevel()
    {
        SEntryResource resource = GetResourceData();
        if (resource == null)
            return 0;

        return resource.level;
    }

    public uint GetResourceOwnerID()
    {
        SEntryResource resource = GetResourceData();
        if (resource == null)
            return 0;

        return resource.owner;
    }

    // Owner Guild
    public OwnerGuildInfo GetOwerGuildData()
    {
        if (data == null)
            return null;

        switch (type)
        {
            case WorldHUDType.BUILDING:
                return ((SEntryData)data).ownerguild;
            case WorldHUDType.EXPEDITION:
                return ((SEntryPathInfo)data).ownerguild;
            default:
                return null;
        }
    }

    public uint GetOwnerGuildBadge()
    {
        OwnerGuildInfo guild = GetOwerGuildData();
        if (guild == null)
            return 0;

        return guild.guildbadge;
    }

    string[] moba_rulings = new string[] { "moba_mapzone0", "moba_mapzone1", "moba_mapzone2" };
    public string GetOwnerGuildBanner()
    {
        OwnerGuildInfo guild = GetOwerGuildData();
        if (guild == null)
            return "";
        if (WorldMapMgr.instance.world.MobaMode != WorldMode.Normal)
        {
            return TextManager.Instance.GetText(moba_rulings[guild.guildid]);
        }
        return guild.guildbanner;
    }

    public uint GetOwnerGuildID()
    {
        OwnerGuildInfo guild = GetOwerGuildData();
        if (guild == null)
            return 0;

        return guild.guildid;
    }

    public string GetOwnerGuildName()
    {
        OwnerGuildInfo guild = GetOwerGuildData();
        if (guild == null)
            return "";

        return guild.guildname;
    }

    // Enemy

    public SEntryMonster GetEnemyData()
    {
        if (data == null)
            return null;

        switch (type)
        {
            case WorldHUDType.BUILDING:
                return ((SEntryData)data).monster;
            default:
                return null;
        }
    }

    public float GetEnemyHpPercentage()
    {
        SEntryMonster enemy = GetEnemyData();
        if (enemy == null)
            return -1;

        return (enemy.numMax - enemy.numDead) / (float)enemy.numMax;
    }

    public uint GetEnemyLevel()
    {
        SEntryMonster enemy = GetEnemyData();
        if (enemy == null)
            return 0;

        return enemy.level;
    }

    // Rebel Army Treasure

    public Serclimax.ScPveMonsterData GetRebelArmyTreasureData()
    {
        SEntryMonster enemy = GetEnemyData();
        if (enemy == null || enemy.digMon == null)
            return null;

        return Main.Instance.TableMgr.GetPveMonsterData((int)enemy.digMon.monsterBaseId);
    }

    public string GetRebelArmyTreasureName()
    {
        Serclimax.ScPveMonsterData treasure = GetRebelArmyTreasureData();
        if (treasure == null)
            return "";

        return TextManager.Instance.GetText(treasure.name);
    }

    // Alliance Building

    public SEntryGuildBuild GetAllianceBuildingData()
    {
        if (data == null)
            return null;

        switch (type)
        {
            case WorldHUDType.BUILDING:
                return ((SEntryData)data).guildbuild;
            default:
                return null;
        }
    }

    public uint GetAllianceBuildingID()
    {
        SEntryGuildBuild allianceBuilding = GetAllianceBuildingData();
        if (allianceBuilding == null)
            return 0;

        return allianceBuilding.baseid;
    }

    /**********************
     * API: Widget Drawer *
     **********************/

    public void DrawDukeBadge(int i)
    {
        DrawDukeBadge(hud[i]);
    }

    public void DrawDukeBadge(WorldHUDWidget badge)
    {
        badge.background = null;
        badge.frame = WorldMapMgr.Instance.world.WorldInfo.playerTitleBadge[7];
        badge.icon = null;
    }

    public void DrawRebelArmyFortressBadge(int i)
    {
        DrawRebelArmyFortressBadge(hud[i]);
    }

    public void DrawRebelArmyFortressBadge(WorldHUDWidget badge)
    {
        badge.background = null;
        badge.frame = WorldMapMgr.Instance.world.WorldInfo.playerTitleBadge[6];
        badge.icon = null;
    }

    public void DrawBubbleByOwner(int i, uint ownerID, uint ownerGuildID)
    {
        DrawBubbleByOwner(hud[i], ownerID, ownerGuildID);
    }

    public void DrawBubbleByOwner(WorldHUDWidget bubble, uint ownerID, uint ownerGuildID)
    {
        if (ownerID != 0)
        {
            if (ownerID == WorldMapMgr.Instance.CharId)
                bubble.type = 0;
            else
            {
                if (WorldMapMgr.Instance.GuildId != 0 && ownerGuildID == WorldMapMgr.Instance.GuildId)
                    bubble.type = 1;
                else
                    bubble.type = 2;
            }
        }
        else
            bubble.type = -1;
    }

    public void DrawMobaBaseBubble(int i, uint rulingTeamID)
    {
        DrawMobaBaseBubble(hud[i], rulingTeamID);
    }

    public void DrawMobaBaseBubble(WorldHUDWidget bubble, uint rulingTeamID)
    {
        bubble.type = (int)rulingTeamID;
    }

    public void DrawLabelByOwner(int i, string text, uint ownerID, uint ownerGuildID)
    {
        DrawLabelByOwner(hud[i], text, ownerID, ownerGuildID);
    }

    public void DrawLabelByOwner(WorldHUDWidget label, string text, uint ownerID, uint ownerGuildID)
    {
        label.text = text;

        if (ownerID == WorldMapMgr.Instance.CharId)
            label.color = Color.white;
        else
        {
            if (WorldMapMgr.Instance.GuildId != 0 && ownerGuildID == WorldMapMgr.Instance.GuildId)
                label.color = COLOR_BLUE;
            else
                label.color = Color.red;
        }
    }

    public void DrawAllianceBadge(int i)
    {
        OwnerGuildInfo guild = ((SEntryData)data).ownerguild;
        if (guild == null)
            return;

        DrawAllianceBadge(i, guild.guildbadge);
    }

    public void DrawAllianceBadge(WorldHUDWidget badge)
    {
        OwnerGuildInfo guild = ((SEntryData)data).ownerguild;
        if (guild == null)
            return;

        DrawAllianceBadge(badge, guild.guildbadge);
    }

    public void DrawAllianceBadge(int i, uint guildBadge)
    {
        DrawAllianceBadge(hud[i], guildBadge);
    }

    public void DrawAllianceBadge(WorldHUDWidget badge, uint guildBadge)
    {
        badge.color = NGUIMath.HexToColor(System.Convert.ToUInt32(string.Format("0x{0}ff", Main.Instance.TableMgr.GetUnionBadgeColorData((int)Mathf.Clamp(Mathf.Floor(guildBadge % 10000 / 100), 1, Main.Instance.TableMgr.GetUnionBadgeColorList().Length)).color), 16));
        badge.mask = Resources.Load<Sprite>(string.Format("GuildBadge/{0}_mask", Main.Instance.TableMgr.GetUnionBadgeBorderData((int)Mathf.Clamp(Mathf.Floor(guildBadge / 10000), 1, Main.Instance.TableMgr.GetUnionBadgeBorderList().Length)).icon));
        badge.frame = Resources.Load<Sprite>(string.Format("GuildBadge/{0}", Main.Instance.TableMgr.GetUnionBadgeBorderData((int)Mathf.Clamp(Mathf.Floor(guildBadge / 10000), 1, Main.Instance.TableMgr.GetUnionBadgeBorderList().Length)).icon));
        badge.icon = Resources.Load<Sprite>(string.Format("GuildBadge/{0}", Main.Instance.TableMgr.GetUnionBadgeTotemData((int)Mathf.Clamp(guildBadge % 100, 1, Main.Instance.TableMgr.GetUnionBadgeTotemList().Length)).icon));
    }

    public void DrawHpBar(int i)
    {
        DrawHpBar(hud[i]);
    }

    public void DrawHpBar(WorldHUDWidget hpBar)
    {
        hpBar.percentage = GetEnemyHpPercentage();
    }

    public void DrawGovernmentOfficialBadge(int i, uint officalID)
    {
        DrawGovernmentOfficialBadge(hud[i], officalID);
    }

    public void DrawGuildOfficialBadge(int i, uint officalID)
    {
        DrawGuildOfficialBadge(hud[i], officalID);
    }

    public void DrawGovernmentOfficialBadge(WorldHUDWidget badge, uint officalID)
    {
        SetWidgetIcon(badge, WorldMapMgr.Instance.world.WorldInfo.OfficialTitleBadge[officalID - 1]);
    }

    public void DrawGuildOfficialBadge(WorldHUDWidget badge, uint officalID)
    {
        SetWidgetIcon(badge, WorldMapMgr.Instance.world.WorldInfo.GuildOfficialTitleBadge[officalID - 1]);
    }

    public void DrawBadge(WorldHUDWidget badge, string path, string spritename)
    {
        Sprite sprite = ResourceLibrary.instance.GetSprite(path, spritename);
        SetWidgetIcon(badge, sprite);
    }

    public void DrawNationalFlag(int i, uint nationality)
    {
        DrawNationalFlag(hud[i], nationality);
    }

    public void DrawNationalFlag(WorldHUDWidget flag, uint nationality)
    {
        flag.material = WorldMapMgr.Instance.world.WorldInfo.nationalFlags[nationality];
    }

    public void InitializeCountdown(int i)
    {
        InitializeDefaultTimer(hud[i]);
    }

    public void InitializeDefaultTimer(WorldHUDWidget label)
    {
        WorldHUDTimer timer = hud.timer;
        if (timer != null)//&& timer.updateFunction == null)
            timer.updateFunction = delegate (long now, uint timeStamp)
            {
                int leftTime = (int)(timeStamp - now);

                if (leftTime > 0)
                    SetWidgetText(label, Serclimax.GameTime.SecondToString3(leftTime));
                else
                {
                    SetTimerTimeStamp(0);
                    HideWidget(label);
                }
            };
    }

    /**************************
     * API: Widget Controller *
     **************************/

    public void ParallelToScreen()
    {
        transform.forward = new Vector3(1, -1, 1);
    }

    public void ShowWidget(int i)
    {
        ShowWidget(hud[i]);
    }

    public void ShowWidget(WorldHUDWidget widget)
    {
        widget.Show();
    }

    public void HideWidget(int i)
    {
        HideWidget(hud[i]);
    }

    public void HideWidget(WorldHUDWidget widget)
    {
        widget.Hide();
    }

    /*******************
     * Helper Function *
     *******************/

    private void SetHUDInfoInLua()
    {
        SEntryData entry = data as SEntryData;
        if (entry == null)
            return;
        bool support_lua = (hud.type == WorldHUDType.LUA_BEHAVIOR) ||
            ( WorldMapMgr.instance.EnableMapHUDInfo4Lua((SceneEntryType)((SEntryData)data).data.entryType));
        if (!support_lua)
            return;
        uint x = ((SEntryData)data).data.pos.x;
        uint y = ((SEntryData)data).data.pos.y;
        LuaInterface.LuaFunction f = LuaClient.GetMainState().GetFunction("WorldMapHUD.SetHUDInfo");
        if (f != null)
            f.Call(this, (uint)((SEntryData)data).data.entryType, x, y);
    }

    private void SetExpeditionHUDInfoInLua(int index)
    {
        SEntryPathInfo expedition = (SEntryPathInfo)data;
        if (expedition == null)
            return;
        bool support_lua = (hud.type == WorldHUDType.LUA_BEHAVIOR) ||
            (WorldMapMgr.instance.EnablePathHUDInfo4Lua((TeamMoveType)expedition.pathType));
        if (!support_lua)
            return;
        LuaInterface.LuaFunction f = LuaClient.GetMainState().GetFunction("WorldMapHUD.SetExpeditionHUDInfoInLua");
        if (f != null)
            f.Call(this, index);
    }


    private void SetHUD4_Fortress_Government_TurretInLua()
    {
        uint x = ((SEntryData)data).data.pos.x;
        uint y = ((SEntryData)data).data.pos.y;
        LuaInterface.LuaFunction f = LuaClient.GetMainState().GetFunction("WorldMapHUD.SetHUD4_Fortress_Government_TurretInLua");
        if (f != null)
            f.Call(this, x, y);
    }

    private void SetBaseInfo()
    {
        SetWidgetText(0, GetBaseLevel());
        DrawLabelByOwner(1, GetOwnerGuildID() == 0 ? GetBaseName() : string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER, GetOwnerGuildBanner(), GetBaseName()), GetBaseOwnerID(), GetOwnerGuildID());

        //if (GetBaseFortBadge() != 0)
        //{
        //    SetWidgetX(2, -(GetWidgetWidth(2) + GetWidgetWidth(1)) / 2f);
        //    ShowWidget(2);
        //}
        //else
        //    HideWidget(2);

        if (GetBaseOfficialID() != 0)
        {
            ShowWidget(2);
            DrawGovernmentOfficialBadge(2, GetBaseOfficialID());
            SetWidgetX(2, -(GetWidgetWidth(2) + GetWidgetWidth(1)) / 2f);

            ShowWidget(3);
            SetWidgetText(3, TextManager.Instance.GetText(WorldMapMgr.Instance.world.WorldInfo.OfficialTitleStrID[GetBaseOfficialID() - 1]));
        }
        else if (GetBaseGuildOfficialID() != 0)
        {
            ShowWidget(2);
            DrawGuildOfficialBadge(2, GetBaseGuildOfficialID());
            SetWidgetX(2, -(GetWidgetWidth(2) + GetWidgetWidth(1)) / 2f);

            ShowWidget(3);
            SetWidgetText(3, TextManager.Instance.GetText(WorldMapMgr.Instance.world.WorldInfo.GuildOfficialTitleStrID[GetBaseGuildOfficialID() - 1]));
        }
        else if (GetBaseMilitaryRankId() != 0)
        {
            ShowWidget(2);
            Serclimax.ScMilitaryRankData rankdata = Main.Instance.TableMgr.GetMilitaryRankData((int)GetBaseMilitaryRankId());
            DrawBadge(hud[2], "Icon/WorldMap/MilitaryRank/", rankdata.icon);
            SetWidgetX(2, -(GetWidgetWidth(2) + GetWidgetWidth(1)) / 2f);
            HideWidget(3);
        }
        else
        {
            HideWidget(2);
            HideWidget(3);
        }

        DrawNationalFlag(4, GetBaseNationality());

        if (HasPrisoner())
        {
            ShowWidget(5);

            SEntryHome home = GetBaseData();
            bool hasReward = false;
            foreach (var info in home.prisoner.info)
            {
                foreach (var reward in info.offerReward)
                    if (reward.value > 0)
                    {
                        hasReward = true;
                        break;
                    }

                if (hasReward)
                    break;
            }

            SetWidgetType(5, hasReward ? 1 : 0);
        }
        else
            HideWidget(5);

        uint title_id = GetBaseGuildTitle();

        if (title_id != 0)
        {
            ShowWidget(6);
            string title = Main.Instance.TableMgr.GetGlobalData((int)title_id).value;
            SetWidgetText(6, TextManager.Instance.GetText(title));
        }
        else
            HideWidget(6);

        SetHUDInfoInLua();
    }

    private void SetResourceInfo()
    {
        SetWidgetText(0, GetResourceLevel());

        uint resourceOwnerID = GetResourceOwnerID();
        DrawBubbleByOwner(1, resourceOwnerID, GetOwnerGuildID());

        InitializeCountdown(2);

        if (resourceOwnerID == GetPlayerID())
        {
            ShowWidget(2);

            SEntryResource resource = ((SEntryData)data).res;
            SetTimerTimeStamp(resource.takestarttime + resource.taketime);
        }
        else
        {
            HideWidget(2);

            SetTimerTimeStamp(0);
        }
        SetHUDInfoInLua();
    }

    private void SetRebelArmyInfo()
    {
        DrawHpBar(0);

        uint level = GetEnemyLevel();

        if (level == 999)
        {
            HideWidget(2);

            ShowWidget(3);
            SetWidgetText(3, TextManager.Instance.GetText("rebel_999_name"));
            // SetWidgetColor(3, Color.red);
            SetWidgetY(3, GetEnemyHpPercentage() == 1 ? -12 : -2);
        }
        else if(level == 1000)
        {
            HideWidget(2);

            ShowWidget(3);
            SetWidgetText(3, TextManager.Instance.GetText("map_rebel_1000"));
            // SetWidgetColor(3, Color.red);
            SetWidgetY(3, GetEnemyHpPercentage() == 1 ? -12 : -2);
        }
        else
        {
            ShowWidget(2);
            SetWidgetText(2, level.ToString());

            HideWidget(3);
        }
        SetHUDInfoInLua();
    }

    private void SetRebelArmyTreasureInfo()
    {

        DrawHpBar(0);

        if ((bool)LuaClient.GetMainState().GetFunction("PveMonsterData.HasAttackPveMonster").Call(GetDataUID())[0])
            ShowWidget(2);
        else
            HideWidget(2);

        SetWidgetText(3, GetRebelArmyTreasureName());
        SetHUDInfoInLua();
    }

    private void SetRebelArmyBaseInfo()
    {
        SetHUDInfoInLua();

        return;
    }

    private void SetRebelArmyFortressInfo()
    {


        SEntryFort fort = ((SEntryData)data).fort;
        if (fort == null)
            return;

        SetWidgetText(0, TextManager.Instance.GetText(string.Format("Duke_{0}", 14 + fort.subType)));

        if ((int)(double)LuaClient.GetMainState().GetFunction("FortsData.GetOwnerGuildID").Call(fort.subType)[0] != 0)
        {
            SetWidgetText(1, string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER, (string)LuaClient.GetMainState().GetFunction("FortsData.GetOwnerGuildBanner").Call(fort.subType)[0], (string)LuaClient.GetMainState().GetFunction("FortsData.GetOwnerGuildName").Call(fort.subType)[0]));
            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            DrawAllianceBadge(3, (uint)(double)LuaClient.GetMainState().GetFunction("FortsData.GetOwnerGuildBadge").Call(fort.subType)[0]);
        }
        else if ((int)(double)LuaClient.GetMainState().GetFunction("FortsData.GetOccupyGuildNum").Call(fort.subType)[0] != 0)
        {
            SetWidgetText(1, string.Format("{0}", TextManager.Instance.GetText("Duke_81")));
            SetWidgetColor(1, new Color(1, 1, 1));

            DrawDukeBadge(3);
        }
        else
        {
            SetWidgetText(1, string.Format("{0}", TextManager.Instance.GetText("Fort_ui5")));
            SetWidgetColor(1, new Color(1, 0, 0));

            DrawRebelArmyFortressBadge(3);
        }

        SetTimerTimeStamp((uint)(double)LuaClient.GetMainState().GetFunction("FortsData.GetContendStartTime").Call(null)[0]);

        WorldHUDTimer timer = hud.timer;
        if (timer != null)// && timer.updateFunction == null)
            timer.updateFunction = delegate (long now, uint timeStamp)
            {
                int time = (int)(timeStamp - now);
                int timeSpan_battle = int.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.RebelArmyFortressBattleTime).value);
                int timeSpan_capture = int.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.RebelArmyFortressCaptureTime).value);

                if (!(bool)LuaClient.GetMainState().GetFunction("FortsData.isAvailable").Call(fort.subType)[0])
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("Fort_ui6")));
                else if (time > int.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.RebelArmyFortressWarningTime).value))
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("Fort_ui1")));
                else if (time > 0)
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("Fort_ui2"), Serclimax.GameTime.SecondToString3(time)));
                else if (System.Math.Abs(time) < timeSpan_battle)
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("Fort_ui4"), Serclimax.GameTime.SecondToString3(timeSpan_battle + time)));
                else if (System.Math.Abs(time) < timeSpan_battle + timeSpan_capture)
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("Fort_ui3"), Serclimax.GameTime.SecondToString3(timeSpan_battle + timeSpan_capture + time)));
                else
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("Fort_ui1")));
            };

        SetWidgetX(3, -(GetWidgetWidth(3) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }

    private void SetPanzerInfo()
    {
        SetRebelArmyInfo();
    }

    private void SetAllianceBuildingInfo()
    {
        DrawAllianceBadge(0);
        SetWidgetText(1, string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER, GetOwnerGuildBanner(), TextManager.Instance.GetText(Main.Instance.TableMgr.GetUnionBuildingData((int)GetAllianceBuildingID()).name)));

        SetWidgetX(0, -(GetWidgetWidth(0) + GetWidgetWidth(1)) / 2f);

        InitializeCountdown(2);

        SEntryGuildBuild allianceBuilding = ((SEntryData)data).guildbuild;
        Serclimax.ScUnionBuildingData buildingData = Main.Instance.TableMgr.GetUnionBuildingData((int)(allianceBuilding.baseid));

        if (GetPlayerGuildID() == GetOwnerGuildID())
        {
            int allianceBuildingType = buildingData.type;
            if (allianceBuildingType == 3 && allianceBuilding.isCompleted && allianceBuilding.hasSelfArmy && allianceBuilding.selfSpeed > 0) // 采集联盟超级矿
            {
                ShowWidget(2);

                SetTimerTimeStamp(allianceBuilding.nowTime + allianceBuilding.selfTakeTime);
            }
            else
            {
                HideWidget(2);

                SetTimerTimeStamp(0);
            }
        }
        SetHUDInfoInLua();
    }

    private void SetExpeditionInfo(int index)
    {
        SEntryPathInfo expedition = (SEntryPathInfo)data;

        if (expedition.pathType == (int)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege) // 叛军攻城
            SetWidgetText(1, expedition.charname);
        else if (expedition.pathType == (int)TeamMoveType.TeamMoveType_Nemesis)
            SetWidgetText(1, TextManager.Instance.GetText(expedition.charname));
        else // 部队出征
        {
            GetOwnerGuildBanner();
            string guildbanner = expedition.ownerguild.guildbanner;
            if (WorldMapMgr.instance.world.MobaMode != WorldMode.Normal)
            {
                guildbanner = TextManager.Instance.GetText(moba_rulings[expedition.ownerguild.guildid]);
            }

            DrawLabelByOwner(1, expedition.ownerguild.guildid != 0 ? string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER, guildbanner, expedition.charname) : expedition.charname, expedition.charid, expedition.ownerguild.guildid);

            if (expedition.fortTitle != 0)
            {
                ShowWidget(0);
                SetWidgetText(0, TextManager.Instance.GetText(string.Format("Duke_{0}", expedition.fortTitle)));

                ShowWidget(2);
                SetWidgetIcon(2, WorldMapMgr.Instance.world.WorldInfo.playerTitleBadge[expedition.fortTitle - 1]);
                SetWidgetX(2, -(GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);
            }
            else if (expedition.govtOfficial != 0)
            {
                ShowWidget(0);
                SetWidgetText(0, TextManager.Instance.GetText(WorldMapMgr.Instance.world.WorldInfo.OfficialTitleStrID[expedition.govtOfficial - 1]));

                ShowWidget(2);
                DrawGovernmentOfficialBadge(2, expedition.govtOfficial);
                SetWidgetX(2, -(GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);
            }
            else if (expedition.militaryRankId != 0)
            {
                HideWidget(0);
                ShowWidget(2);
                Serclimax.ScMilitaryRankData rankdata = Main.Instance.TableMgr.GetMilitaryRankData((int)expedition.militaryRankId);//
                DrawBadge(hud[2], "Icon/WorldMap/MilitaryRank/", rankdata.icon);
                SetWidgetX(2, -(GetWidgetWidth(2) + GetWidgetWidth(1)) / 2f);
            }
            else
            {
                HideWidget(0);
                HideWidget(2);
            }
            SetExpeditionHUDInfoInLua(index);
        }
    }

    private void SetGarrisonInfo()
    {

        if (hud)
        {
            HideWidget(0);

            SetTimerTimeStamp(0);
        }
        SetHUDInfoInLua();
    }

    private void SetOccupyInfo()
    {
        SEntryOccupy occupyInfo = ((SEntryData)data).occupy;

        InitializeCountdown(0);

        uint occupyEndTime = occupyInfo.starttime + occupyInfo.totaltime;

        if (occupyInfo.owner == GetPlayerID() && occupyEndTime > Serclimax.GameTime.GetSecTime())
        {
            ShowWidget(0);

            SetTimerTimeStamp(occupyEndTime);
        }
        else
        {
            HideWidget(0);

            SetTimerTimeStamp(0);
        }
        SetHUDInfoInLua();
    }

    static int[] TurretStrategy = new int[] { 31, 33, 32 };
    private void SetTurretInfo()
    {


        TurretData turret = ((SEntryData)data).centerBuild.turret;
        if (turret == null)
            return;

        int subType = (int)turret.subType;
        SetWidgetText(0, string.Format("{0} ({1})", TextManager.Instance.GetText(string.Format("TurretName_{0}", subType)), TextManager.Instance.GetText(string.Format("GOV_ui{0}", TurretStrategy[turret.strategy - 1]))));

        int turretGuildId = (int)(double)LuaClient.GetMainState().GetFunction("GovernmentData.GetTurretRulerGuildID").Call(subType)[0];
        int myGuildId = (int)(double)LuaClient.GetMainState().GetFunction("UnionInfoData.GetGuildId").Call(null)[0];

        if (turretGuildId != 0)
        {
            SetWidgetText(1, string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER, (string)LuaClient.GetMainState().GetFunction("GovernmentData.GetTurretRulerGuildBanner").Call(subType)[0], (string)LuaClient.GetMainState().GetFunction("GovernmentData.GetTurretRulerGuildName").Call(subType)[0]));
            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (turretGuildId != myGuildId)
                SetWidgetColor(1, new Color(1, 0, 0));
            DrawAllianceBadge(3, (uint)(double)LuaClient.GetMainState().GetFunction("GovernmentData.GetTurretRulerGuildBadge").Call(subType)[0]);
        }
        else
        {
            SetWidgetText(1, TextManager.Instance.GetText("Fort_ui5"));
            SetWidgetColor(1, new Color(1, 0, 0));
            DrawRebelArmyFortressBadge(3);
        }

        SetTimerTimeStamp((uint)(double)LuaClient.GetMainState().GetFunction("GovernmentData.GetGOVContendStartTime").Call(null)[0]);

        WorldHUDTimer timer = hud.timer;
        if (timer != null)//&& timer.updateFunction == null)
            timer.updateFunction = delegate (long now, uint timeStamp)
            {
                int timeToStart = (int)(timeStamp - now);

                if (timeToStart > 0)
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui78"), Serclimax.GameTime.SecondToString3(timeToStart)));
                else
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui79"), Serclimax.GameTime.SecondToString3((int)((uint)(double)LuaClient.GetMainState().GetFunction("GovernmentData.GetGOVContendEndTime").Call(null)[0] - now))));
            };

        SetWidgetX(3, -5 - (GetWidgetWidth(3) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
        if (support_lua_Turret)
            SetHUD4_Fortress_Government_TurretInLua();
    }

    private void SetGovernmentInfo()
    {


        GovernmentData government = ((SEntryData)data).centerBuild.government;
        if (government == null)
            return;

        SetWidgetText(0, TextManager.Instance.GetText("GOV_ui7"));
        int govGuildId = (int)(double)LuaClient.GetMainState().GetFunction("GovernmentData.GetGOVRulerGuildID").Call(null)[0];
        int myGuildId = (int)(double)LuaClient.GetMainState().GetFunction("UnionInfoData.GetGuildId").Call(null)[0];
        if (govGuildId != 0)
        {
            SetWidgetText(1, string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER, (string)LuaClient.GetMainState().GetFunction("GovernmentData.GetGOVRulerGuildBanner").Call(null)[0], (string)LuaClient.GetMainState().GetFunction("GovernmentData.GetGOVRulerGuildName").Call(null)[0]));
            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (govGuildId != myGuildId)
                SetWidgetColor(1, new Color(1, 0, 0));
            DrawAllianceBadge(3, (uint)(double)LuaClient.GetMainState().GetFunction("GovernmentData.GetGOVRulerGuildBadge").Call(null)[0]);
        }
        else
        {
            SetWidgetText(1, TextManager.Instance.GetText("Fort_ui5"));
            SetWidgetColor(1, new Color(1, 0, 0));
            DrawRebelArmyFortressBadge(3);
        }

        SetTimerTimeStamp(government.contendStartTime);

        WorldHUDTimer timer = hud.timer;
        if (timer != null)//&& timer.updateFunction == null)
            timer.updateFunction = delegate (long now, uint timeStamp)
            {
                int timeToStart = (int)(timeStamp - now);

                if (timeToStart > 0)
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui78"), Serclimax.GameTime.SecondToString3(timeToStart)));
                else
                    SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui79"), Serclimax.GameTime.SecondToString3((int)(government.contendEndTime - now))));
            };

        SetWidgetX(3, -5 - (GetWidgetWidth(3) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        DrawNationalFlag(4, ((SEntryData)data).centerBuild.nationality);
        SetWidgetLocalPosition(4, -127, 105, 17);
        SetHUDInfoInLua();
        if (support_lua_Government)
            SetHUD4_Fortress_Government_TurretInLua();
    }
    private void SetWorldCity(int cityId)
    {
        Serclimax.ScWorldCityData city = Main.Instance.TableMgr.GetWorldCityData(cityId);
        SetWidgetText(0, TextManager.Instance.GetText(city.name), 40);
        SetHUDInfoInLua();
    }
    private void SetStrongholdInfo(StrongholdData stronghold)
    {
        Serclimax.ScStrongholdRuleData strong_hold = Main.Instance.TableMgr.GetStrongholdRuleByID((int)stronghold.subtype);
        SetWidgetText(0, TextManager.Instance.GetText(strong_hold.name));

        int rulerGuildId = (int)(double)LuaClient.GetMainState().GetFunction("StrongholdData.GetRulerGuildID").Call((int)stronghold.subtype)[0];
        int myGuildId = (int)(double)LuaClient.GetMainState().GetFunction("UnionInfoData.GetGuildId").Call(null)[0];
        if (rulerGuildId != 0)
        {
            SetWidgetText(1, string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER,
                (string)LuaClient.GetMainState().GetFunction("StrongholdData.GetRulerGuildBanner").Call((int)stronghold.subtype)[0],
                (string)LuaClient.GetMainState().GetFunction("StrongholdData.GetRulerGuildName").Call((int)stronghold.subtype)[0]));
            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (rulerGuildId != myGuildId)
                SetWidgetColor(1, new Color(1, 0, 0));
            DrawAllianceBadge(3, (uint)(double)LuaClient.GetMainState().GetFunction("StrongholdData.GetRulerGuildBadge").Call((int)stronghold.subtype)[0]);
        }
        else
        {
            SetWidgetText(1, TextManager.Instance.GetText("Fort_ui5"));
            SetWidgetColor(1, new Color(1, 0, 0));
            DrawRebelArmyFortressBadge(3);
        }

        long end_time = (long)(double)LuaClient.GetMainState().GetFunction("StrongholdData.GetContendEndTime").Call((int)stronghold.subtype)[0];
        long now_t = Serclimax.GameTime.GetSecTime();
        if (now_t > end_time)
        {
            SetWidgetText(2, TextManager.Instance.GetText("war_over"));
            SetWidgetColor(2, new Color(1, 0, 0));
            ClearTimerStamp();
        }
        else
        {
            SetTimerTimeStamp((uint)(double)LuaClient.GetMainState().GetFunction("StrongholdData.GetContendStartTime").Call((int)stronghold.subtype)[0]);

            WorldHUDTimer timer = hud.timer;
            if (timer != null)// && timer.updateFunction == null)
                timer.updateFunction = delegate (long now, uint timeStamp)
                {
                    int timeToStart = (int)(timeStamp - now);

                    if (timeToStart > 0)
                        SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui78"), Serclimax.GameTime.SecondToString3(timeToStart)));
                    else
                        SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui79"),
                            Serclimax.GameTime.SecondToString3((int)((long)(double)LuaClient.GetMainState().GetFunction("StrongholdData.GetContendEndTime").Call((int)stronghold.subtype)[0] - now))));
                };

            SetWidgetColor(2, new Color(1, 1, 1));
        }

        SetWidgetX(3, -5 - (GetWidgetWidth(3) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        DrawNationalFlag(4, ((SEntryData)data).centerBuild.nationality);
        SetWidgetLocalPosition(4, -95, 45, 25);
        SetHUDInfoInLua();
    }

    private void SetFortressInfo(FortressData fortress)
    {


        Serclimax.ScFortressData fortressCfgData = Main.Instance.TableMgr.GetFortressRuleByID((int)fortress.subtype);
        SetWidgetText(0, TextManager.Instance.GetText(fortressCfgData.name));

        int rulerGuildId = (int)(double)LuaClient.GetMainState().GetFunction("FortressData.GetRulerGuildID").Call((int)fortress.subtype)[0];
        int myGuildId = (int)(double)LuaClient.GetMainState().GetFunction("UnionInfoData.GetGuildId").Call(null)[0];
        if (rulerGuildId != 0)
        {
            SetWidgetText(1, string.Format(FORMAT_PLAYERNAME_WITH_GUILDBANNER,
                (string)LuaClient.GetMainState().GetFunction("FortressData.GetRulerGuildBanner").Call((int)fortress.subtype)[0],
                (string)LuaClient.GetMainState().GetFunction("FortressData.GetRulerGuildName").Call((int)fortress.subtype)[0]));
            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (rulerGuildId != myGuildId)
                SetWidgetColor(1, new Color(1, 0, 0));
            DrawAllianceBadge(3, (uint)(double)LuaClient.GetMainState().GetFunction("FortressData.GetRulerGuildBadge").Call((int)fortress.subtype)[0]);
        }
        else
        {
            SetWidgetText(1, TextManager.Instance.GetText("Fort_ui5"));
            SetWidgetColor(1, new Color(1, 0, 0));
            DrawRebelArmyFortressBadge(3);
        }

        long end_time = (long)(double)LuaClient.GetMainState().GetFunction("FortressData.GetContendEndTime").Call((int)fortress.subtype)[0];
        long now_t = Serclimax.GameTime.GetSecTime();
        if (now_t > end_time)
        {
            SetWidgetText(2, TextManager.Instance.GetText("war_over"));
            SetWidgetColor(2, new Color(1, 0, 0));
            ClearTimerStamp();
        }
        else
        {
            SetTimerTimeStamp((uint)(double)LuaClient.GetMainState().GetFunction("FortressData.GetContendStartTime").Call((int)fortress.subtype)[0]);

            WorldHUDTimer timer = hud.timer;
            if (timer != null)// && timer.updateFunction == null)
                timer.updateFunction = delegate (long now, uint timeStamp)
                {
                    int timeToStart = (int)(timeStamp - now);

                    if (timeToStart > 0)
                        SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui78"), Serclimax.GameTime.SecondToString3(timeToStart)));
                    else
                        SetWidgetText(2, string.Format(TextManager.Instance.GetText("GOV_ui79"),
                            Serclimax.GameTime.SecondToString3((int)((long)(double)LuaClient.GetMainState().GetFunction("FortressData.GetContendEndTime").Call((int)fortress.subtype)[0] - now))));
                };

            SetWidgetColor(2, new Color(1, 1, 1));
        }

        SetWidgetX(3, -5 - (GetWidgetWidth(3) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        DrawNationalFlag(4, ((SEntryData)data).centerBuild.nationality);
        SetWidgetLocalPosition(4, -45, 75, 15);
        SetHUDInfoInLua();
        if (support_lua_Fortress)
            SetHUD4_Fortress_Government_TurretInLua();
    }

    private void SetEliteRebelArmyInfo()
    {


        SetWidgetText(1, ((SEntryData)data).elite.level.ToString());
        SetHUDInfoInLua();
    }

    private string[] _Ruling_Strs = new string[] { "moba_mapzone0", "moba_mapzone1", "moba_mapzone2" };

    private void SetMobaCenterInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int ownerTeam = (int)mobaBuild.ownerTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaCenter :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetColor(0, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(0, new Color(1, 0, 0));
        SetWidgetText(1, "");


        long now_t = Serclimax.GameTime.GetSecTime();
        long end_time = mobaBuild.shieldEndTime;
        if (now_t > end_time)
        {
            //if (rulingTeamId == 0)
            //{
            //    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            //}
            //else if (rulingTeamId == myTeamId || (ownerTeam == rulingTeamId))
            //{
            //    if (mobaBuild.garrisons.Count != 0)
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
            //    else
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            //}
            //else
            //{
            //    if (mobaBuild.garrisons.Count != 0)
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
            //    else
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            //}
            if (rulingTeamId == 0)
            {
                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            }
            else if (ownerTeam == myTeamId)
            {
                //我家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }
            else
            {
                //敌方家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }

            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (myTeamId != rulingTeamId)
                SetWidgetColor(1, new Color(1, 0, 0));
            ClearTimerStamp();
        }
        else
        {
            SetTimerTimeStamp((uint)end_time);

            WorldHUDTimer timer = hud.timer;
            if (timer != null)// && timer.updateFunction == null)
                timer.updateFunction = delegate (long now, uint timeStamp)
                {
                    int timeToStart = (int)(timeStamp - now);

                    if (timeToStart > 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_117"), Serclimax.GameTime.SecondToString3(timeToStart)));
                    else
                    {
                        if (rulingTeamId == 0)
                        {
                            SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                        else if (rulingTeamId == myTeamId || (ownerTeam == rulingTeamId))
                        {
                            if (mobaBuild.garrisons.Count != 0)
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                            else
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                        else
                        {
                            if (mobaBuild.garrisons.Count != 0)
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                            else
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                    }
                };

            SetWidgetColor(1, new Color(1, 1, 1));
        }


        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetMobaGateInfo(SEntryMobaBuild mobaBuild)
    {

        if (mobaBuild.broken)
        {
            hud[0].gameObject.SetActive(false);
            hud[1].gameObject.SetActive(false);
            hud[2].gameObject.SetActive(false);
            return;
        }
        else
        {
            hud[0].gameObject.SetActive(true);
            hud[1].gameObject.SetActive(true);
            hud[2].gameObject.SetActive(true);
        }
        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int ownerTeam = (int)mobaBuild.ownerTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaGate :RT-"+ rulingTeamId+":MT-"+myTeamId);//
        SetWidgetColor(0, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(0, new Color(1, 0, 0));
        SetWidgetText(1, "");

        long now_t = Serclimax.GameTime.GetSecTime();
        long end_time = mobaBuild.shieldEndTime;
        if (now_t > end_time)
        {
            if (rulingTeamId == 0)
            {
                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            }
            else if (ownerTeam == myTeamId)
            {
                //我家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }
            else
            {
                //敌方家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }

            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (myTeamId != rulingTeamId)
                SetWidgetColor(1, new Color(1, 0, 0));
            ClearTimerStamp();
        }
        else
        {
            SetTimerTimeStamp((uint)end_time);

            WorldHUDTimer timer = hud.timer;
            if (timer != null)// && timer.updateFunction == null)
                timer.updateFunction = delegate (long now, uint timeStamp)
                {
                    int timeToStart = (int)(timeStamp - now);

                    if (timeToStart > 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_117"), Serclimax.GameTime.SecondToString3(timeToStart)));
                    else
                    {
                        if (rulingTeamId == 0)
                        {
                            SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                        else if (ownerTeam == myTeamId)
                        {
                            //我家
                            if (rulingTeamId == myTeamId)
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                            else
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                        }
                        else
                        {
                            //敌方家
                            if (rulingTeamId == myTeamId)
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                            else
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                        }
                    }
                };

            SetWidgetColor(1, new Color(1, 1, 1));
        }

        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetMobaArsenalInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaArsenal :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetMobaSmallBuildInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaArsenal :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetMobaFortInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaFort :RT-" + rulingTeamId + ":MT-" + myTeamId);// 
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetMobaInstituteInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaInstitute :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetMobaTransPlatInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaTransPlat :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }

    private void SetGuildMobaCenterInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int ownerTeam = (int)mobaBuild.ownerTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaCenter :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetColor(0, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(0, new Color(1, 0, 0));
        SetWidgetText(1, "");


        long now_t = Serclimax.GameTime.GetSecTime();
        long end_time = mobaBuild.shieldEndTime;
        if (now_t > end_time)
        {
            //if (rulingTeamId == 0)
            //{
            //    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            //}
            //else if (rulingTeamId == myTeamId || (ownerTeam == rulingTeamId))
            //{
            //    if (mobaBuild.garrisons.Count != 0)
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
            //    else
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            //}
            //else
            //{
            //    if (mobaBuild.garrisons.Count != 0)
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
            //    else
            //        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            //}
            if (rulingTeamId == 0)
            {
                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            }
            else if (ownerTeam == myTeamId)
            {
                //我家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }
            else
            {
                //敌方家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }

            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (myTeamId != rulingTeamId)
                SetWidgetColor(1, new Color(1, 0, 0));
            ClearTimerStamp();
        }
        else
        {
            SetTimerTimeStamp((uint)end_time);

            WorldHUDTimer timer = hud.timer;
            if (timer != null)// && timer.updateFunction == null)
                timer.updateFunction = delegate (long now, uint timeStamp)
                {
                    int timeToStart = (int)(timeStamp - now);

                    if (timeToStart > 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_117"), Serclimax.GameTime.SecondToString3(timeToStart)));
                    else
                    {
                        if (rulingTeamId == 0)
                        {
                            SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                        else if (rulingTeamId == myTeamId || (ownerTeam == rulingTeamId))
                        {
                            if (mobaBuild.garrisons.Count != 0)
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                            else
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                        else
                        {
                            if (mobaBuild.garrisons.Count != 0)
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                            else
                                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                    }
                };

            SetWidgetColor(1, new Color(1, 1, 1));
        }


        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetGuildMobaGateInfo(SEntryMobaBuild mobaBuild)
    {

        if (mobaBuild.broken)
        {
            hud[0].gameObject.SetActive(false);
            hud[1].gameObject.SetActive(false);
            hud[2].gameObject.SetActive(false);
            return;
        }
        else
        {
            hud[0].gameObject.SetActive(true);
            hud[1].gameObject.SetActive(true);
            hud[2].gameObject.SetActive(true);
        }
        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int ownerTeam = (int)mobaBuild.ownerTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaGate :RT-"+ rulingTeamId+":MT-"+myTeamId);//
        SetWidgetColor(0, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(0, new Color(1, 0, 0));
        SetWidgetText(1, "");

        long now_t = Serclimax.GameTime.GetSecTime();
        long end_time = mobaBuild.shieldEndTime;
        if (now_t > end_time)
        {
            if (rulingTeamId == 0)
            {
                SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
            }
            else if (ownerTeam == myTeamId)
            {
                //我家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }
            else
            {
                //敌方家
                if (rulingTeamId == myTeamId)
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
                else
                {
                    if (mobaBuild.garrisons.Count != 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                    else
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                }
            }

            SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
            if (myTeamId != rulingTeamId)
                SetWidgetColor(1, new Color(1, 0, 0));
            ClearTimerStamp();
        }
        else
        {
            SetTimerTimeStamp((uint)end_time);

            WorldHUDTimer timer = hud.timer;
            if (timer != null)// && timer.updateFunction == null)
                timer.updateFunction = delegate (long now, uint timeStamp)
                {
                    int timeToStart = (int)(timeStamp - now);

                    if (timeToStart > 0)
                        SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_117"), Serclimax.GameTime.SecondToString3(timeToStart)));
                    else
                    {
                        if (rulingTeamId == 0)
                        {
                            SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                        }
                        else if (ownerTeam == myTeamId)
                        {
                            //我家
                            if (rulingTeamId == myTeamId)
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                            else
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                        }
                        else
                        {
                            //敌方家
                            if (rulingTeamId == myTeamId)
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_132"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                            else
                            {
                                if (mobaBuild.garrisons.Count != 0)
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_133"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
                                else
                                    SetWidgetText(1, string.Format(TextManager.Instance.GetText("ui_moba_118")));
                            }
                        }
                    }
                };

            SetWidgetColor(1, new Color(1, 1, 1));
        }

        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetGuildMobaArsenalInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaArsenal :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetGuildMobaSmallBuildInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaArsenal :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetGuildMobaFortInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaFort :RT-" + rulingTeamId + ":MT-" + myTeamId);// 
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetGuildMobaInstituteInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaInstitute :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
    private void SetGuildMobaTransPlatInfo(SEntryMobaBuild mobaBuild)
    {


        int buidingid = (int)mobaBuild.buidingid;
        Serclimax.ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

        int rulingTeamId = (int)mobaBuild.rulingTeam;
        int myTeamId = (int)(double)LuaClient.GetMainState().GetFunction("MobaMainData.GetTeamID").Call(null)[0];

        SetWidgetText(0, TextManager.Instance.GetText(moba_build.name));//"MobaTransPlat :RT-" + rulingTeamId + ":MT-" + myTeamId);//
        SetWidgetText(1, string.Format(TextManager.Instance.GetText("moba_mapzone4"), TextManager.Instance.GetText(_Ruling_Strs[rulingTeamId])));
        SetWidgetColor(1, new Color(0x56 / 255f, 0xC0 / 255f, 1));
        if (myTeamId != rulingTeamId)
            SetWidgetColor(1, new Color(1, 0, 0));
        DrawMobaBaseBubble(2, mobaBuild.rulingTeam);
        SetWidgetX(2, -20 - (GetWidgetWidth(2) + System.Math.Max(GetWidgetWidth(0), GetWidgetWidth(1))) / 2f);

        SetHUDInfoInLua();
    }
}
