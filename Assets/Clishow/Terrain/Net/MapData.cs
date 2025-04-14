using UnityEngine;
using System.Collections;
using System;
using ProtoMsg;
using Serclimax;
using System.Collections.Generic;

public class MapData
{
    public struct MobaBuildSpecialEffect
    {
        public int occupy_effect;
        public int repair_effect;
        public int broken_effect;
    }
    static Dictionary<int, MobaBuildSpecialEffect> mobaSpecialEffects = new Dictionary<int, MobaBuildSpecialEffect> {
        { 1,new MobaBuildSpecialEffect(){ occupy_effect = 13,repair_effect=14,broken_effect= 0 } },
        { 2,new MobaBuildSpecialEffect(){ occupy_effect = 21,repair_effect=22,broken_effect= 26  } },
        { 3,new MobaBuildSpecialEffect(){ occupy_effect = 19,repair_effect=20,broken_effect= 25  } },
        { 4,new MobaBuildSpecialEffect(){ occupy_effect = 13,repair_effect=14,broken_effect= 0  } },
        { 5,new MobaBuildSpecialEffect(){ occupy_effect = 17,repair_effect=18,broken_effect= 24  } },
        { 6,new MobaBuildSpecialEffect(){ occupy_effect = 15,repair_effect=16,broken_effect= 23 } },
    };

    public Dictionary<int, Dictionary<int, SEntryData>> SEntryData = new Dictionary<int, Dictionary<int, SEntryData>>();
    World world;
    public void Init(World w)
    {
        world = w;
    }

    public void SetData(int x, int y, SEntryData sEntryData) {
        int serverx = x / WorldMapNet.ServerBlockSize;
        int servery = y / WorldMapNet.ServerBlockSize;
        int index = servery * WorldMapNet.ServerBlockTotalCount + serverx;
        int lindex = y * world.WorldInfo.LogicServerSizeY + x;
        if (SEntryData.ContainsKey(index))
        {          
            SEntryData[index][lindex] = sEntryData;
        }
        else {
            Dictionary<int, SEntryData> data = new Dictionary<int, ProtoMsg.SEntryData>();
            data[lindex] = sEntryData;
            SEntryData[index] = data;
        }
    }

    public SEntryData GetData(int x, int y) {

        int serverx = x / WorldMapNet.ServerBlockSize;
        int servery = y / WorldMapNet.ServerBlockSize;
        int index = servery * WorldMapNet.ServerBlockTotalCount + serverx;
        if (SEntryData.ContainsKey(index))
        {
            int lindex = y * world.WorldInfo.LogicServerSizeY + x;
            Dictionary<int, SEntryData> sEntryDatas = SEntryData[index];
            if (sEntryDatas.ContainsKey(lindex)) {
                return sEntryDatas[lindex];
            }

        }
        return null;
    }

    public void ClearCache(int index)
    {
        if (SEntryData.ContainsKey(index))
        {
            SEntryData[index].Clear();
        }
    }

    public void ClearAllCache()
    {
        SEntryData.Clear();
    }

    private void SimulateEntryData(SEntryData data)
    {
        if (data == null)
            return;
        data.fort = new SEntryFort();
        data.fort.subType = (uint)UnityEngine.Random.Range(1, 6);
        int state = 0;
        int p = UnityEngine.Random.Range(1, 100);
        if (p < 30)
            state = -1;
        else if (p > 30 && p < 60)
            state = 0;
        else
            state = 1;
        switch (state)
        {
            case 0:
                data.fort.startTime = (uint)Serclimax.GameTime.GetSecTime();
                if (UnityEngine.Random.Range(0, 10) <= 5)
                    data.ownerguild = null;
                else
                {
                    data.ownerguild.guildbanner = "AAA";
                    data.ownerguild.guildbadge = 10;
                    data.ownerguild.guildname = "In battle phrase";
                }
                break;
            case 1:
                data.fort.startTime = (uint)Serclimax.GameTime.GetSecTime() + 10000;
                data.ownerguild = null;
                break;
            case -1:
                data.fort.startTime = (uint)Serclimax.GameTime.GetSecTime() - 10000;
                if (UnityEngine.Random.Range(0, 10) <= 5)
                    data.ownerguild = null;
                else
                {
                    data.ownerguild.guildbanner = "BBB";
                    data.ownerguild.guildbadge = 15;
                    data.ownerguild.guildname = "After battle phrase";
                }
                break;
        }

        data.data.entryType = (uint)SceneEntryType.SceneEntryType_Fort;
    }

    public void SetMapData(SEntryData tileMsg)
    {
        //SimulateEntryData(tileMsg);

        int lindex = (world.WorldInfo.LogicServerSizeX - (int)tileMsg.data.pos.x - 1) * world.WorldInfo.LogicServerSizeX + (int)tileMsg.data.pos.y;

        FastStack<int> effect = world.WorldInfo.WBlockMap.mEffectPool.Claim();

        uint entryType = tileMsg.data.entryType;
        if (entryType == (int)SceneEntryType.SceneEntryType_Home)
        {
            ScBuildingCoreData tileData = Main.Instance.TableMgr.GetBuildCoreDataByLevel(Mathf.Max(1, (int)tileMsg.home.homelvl));
            //建筑
            int buildid;
            int defaultHomeSkin = int.Parse(Main.Instance.TableMgr.GetGlobalData(ScGlobalDataId.DefaultHomeSkin).value);
            if (tileMsg.home.skin == defaultHomeSkin)
            {

                if (tileMsg.home.officialId == 1)
                {
                    buildid = tileData.consulPicture;
                }
                else
                {
                    buildid = tileData.picture;
                }
            }
            else
            {
                object[] objects = LuaClient.GetMainState().GetFunction("Skin.GetSkinGid").Call(tileMsg.home.skin);
                buildid = (int)(double)objects[0];
            }

            world.WorldInfo.WBlockMap.SetBuild(lindex, buildid);
            //特效
            if (tileMsg.home.hasShield)
            {
                //effect = EncodeEffect(effect, 0);
                effect.Add(0);
            }
            //特效
            if (tileMsg.home.status > 0 && tileMsg.home.statusTime > Serclimax.GameTime.GetSecTime())
            {
                if (tileMsg.home.status == 1)
                    //effect = EncodeEffect(effect, 2);
                    effect.Add(2);
                else
                    //effect = EncodeEffect(effect, 1);
                    effect.Add(1);
            }
            if (tileMsg.home.nemesisArround && tileMsg.home.charid == WorldMapMgr.Instance.CharId)
                //effect = EncodeEffect(effect, 9);
                effect.Add(9);
            if (tileMsg.home.hasFortArroundBuff)
                //effect = EncodeEffect(effect, 6);
                effect.Add(6);
            if (tileMsg.home.strongholdAround)
                //effect = EncodeEffect(effect, 12);
                effect.Add(12);

        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_Monster)
        {
            ScMonsterRuleData tileData = Main.Instance.TableMgr.GetMonsterRuleData((int)tileMsg.monster.level);
            //建筑
            world.WorldInfo.WBlockMap.SetBuild(lindex, tileData.picture);
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_WorldMonster)
        {
            ScMonsterRuleData tileData = Main.Instance.TableMgr.GetMonsterRuleData((int)tileMsg.monster.level);
            //建筑
            world.WorldInfo.WBlockMap.SetBuild(lindex, tileData.picture);
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_ActMonster)
        {
            bool guildMonster = false;
            if (tileMsg.monster != null && tileMsg.monster.guildMon != null)
            {
                guildMonster = tileMsg.monster.guildMon.guildMonster;
            }

            bool pveMonster = false;
            if (tileMsg.monster != null && tileMsg.monster.digMon != null && tileMsg.monster.digMon.monsterBaseId > 0)
            {
                pveMonster = true;
            }

            if (guildMonster)
            {
                ScUnionMonster tileData = Main.Instance.TableMgr.GetUnionMonsterData((int)tileMsg.monster.level);

                if (tileMsg.monster.guildMon.guildMonsterState == 2)
                {
                    //特效
                    //effect = EncodeEffect(effect, 3);
                    effect.Add(3);
                    if (int.Parse(tileData.picture2) == 301)
                    {
                        int index = (world.WorldInfo.LogicServerSizeX - (int)tileMsg.data.pos.x - 2) * world.WorldInfo.LogicServerSizeX + (int)tileMsg.data.pos.y;
                        effect.FastClear();
                        effect.Add(8);
                        world.WorldInfo.WBlockMap.SetEffect(index, effect);

                    }
                }
                //建筑
                SetPicture(tileData.mapSize, int.Parse(tileData.picture2), tileMsg.data.pos);
            }
            else if (pveMonster)
            {
                ScPveMonsterData tileData = Main.Instance.TableMgr.GetPveMonsterData((int)tileMsg.monster.digMon.monsterBaseId);
                //建筑
                world.WorldInfo.WBlockMap.SetBuild(lindex, int.Parse(tileData.picture));
            }
            else
            {
                ScActMonsterRule tileData = Main.Instance.TableMgr.GetActMonsterRuleData((int)tileMsg.monster.level);
                //建筑
                world.WorldInfo.WBlockMap.SetBuild(lindex, tileData.picture);
            }


        }
        else if (entryType >= (int)SceneEntryType.SceneEntryType_ResFood && entryType <= (int)SceneEntryType.SceneEntryType_ResElec)
        {
            ScResourceRuleData tileData = Main.Instance.TableMgr.GetResourceRuleDataByTypeLevel((int)entryType, (int)tileMsg.res.level);
            //建筑
            world.WorldInfo.WBlockMap.SetBuild(lindex, tileData.picture);
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_Barrack || entryType == (int)SceneEntryType.SceneEntryType_Occupy)
        {
            int picture = int.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.WorldMapBarrackPicture).value);
            //建筑
            world.WorldInfo.WBlockMap.SetBuild(lindex, picture);
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_GuildBuild)
        {
            ScUnionBuildingData tileData = Main.Instance.TableMgr.GetUnionBuildingData((int)tileMsg.guildbuild.baseid);
            //建筑
            SetPicture(tileData.size, int.Parse(tileData.picture), tileMsg.data.pos);
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_SiegeMonster)
        {
            ScMapBuildingData tileData = Main.Instance.TableMgr.GetMapBuildingDataByID((int)SceneEntryType.SceneEntryType_SiegeMonster);
            //建筑
            SetPicture(tileData.size, int.Parse(tileData.picture), tileMsg.data.pos);

        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_Fort)
        {
            ScMapBuildingData tileData = Main.Instance.TableMgr.GetMapBuildingDataByID((int)((int)SceneEntryType.SceneEntryType_Fort * 100 + tileMsg.fort.subType));
            SetPicture(tileData.size, int.Parse(tileData.picture), tileMsg.data.pos);
            //特效
            ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(tileData.size);
            int x = scObjectShapeData.xMin;
            int y = scObjectShapeData.yMin;
            if (tileMsg.fort.hasShield)
            {
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 4);
                effect.Add(4);
            }
            else
            {
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 5);
                effect.Add(5);
            }
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_Govt)
        {
            ScMapBuildingData tileData = Main.Instance.TableMgr.GetMapBuildingDataByID((int)SceneEntryType.SceneEntryType_Govt);
            SetPicture(tileData.size, int.Parse(tileData.picture), tileMsg.data.pos);
            //特效
            ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(tileData.size);
            int x = scObjectShapeData.xMin;
            int y = scObjectShapeData.yMin;
            if (tileMsg.centerBuild.hasShield)
            {
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 7);
                effect.Add(7);
            }


        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_Turret)
        {
            ScMapBuildingData tileData = Main.Instance.TableMgr.GetMapBuildingDataByID((int)((int)SceneEntryType.SceneEntryType_Turret * 100 + tileMsg.centerBuild.turret.subType));
            SetPicture(tileData.size, int.Parse(tileData.picture), tileMsg.data.pos);

            //特效
            ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(tileData.size);
            int x = scObjectShapeData.xMin;
            int y = scObjectShapeData.yMin;
            if (tileMsg.centerBuild.hasShield)
            {
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 8);
                effect.Add(8);
            }

        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_EliteMonster)
        {
            ScEliteMonsterRuleData tileData = Main.Instance.TableMgr.GetEliteMonsterRuleData((int)tileMsg.elite.type, (int)tileMsg.elite.level);
            //建筑
            SetPicture(tileData.size, tileData.picture, tileMsg.data.pos);
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_Fortress)
        {
            int sh_id = (int)tileMsg.centerBuild.fortress.subtype;
            ScFortressData fortress = Main.Instance.TableMgr.GetFortressRuleByID(sh_id);
            ScMapBuildingData tileData = Main.Instance.TableMgr.GetMapBuildingDataByID(fortress.BuildId);
            if (tileMsg.centerBuild.fortress.available)
            {
                SetPicture(tileData.size, int.Parse(tileData.picture), tileMsg.data.pos);
                ScBasicSurfaceData basicSurface = Main.Instance.TableMgr.GetBasicSurfaceDataByType(fortress.SurfaceType);
                if (WorldMapMgr.instance.RangeMgr != null)
                {
                    WorldMapMgr.instance.RangeMgr.SetRange((int)tileMsg.data.pos.x, (int)tileMsg.data.pos.y, basicSurface.width, basicSurface.height);
                }
            }
            else
            {
                SetPicture(tileData.size, int.Parse(tileData.picture) + 1, tileMsg.data.pos);
            }
            if (tileMsg.centerBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(tileData.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 10);
                effect.Add(10);
            }
            world.WorldInfo.WBlockMap.SetEffect(lindex, effect);
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_Stronghold)
        {
            int sh_id = (int)tileMsg.centerBuild.stronghold.subtype;
            ScStrongholdRuleData strong_hold = Main.Instance.TableMgr.GetStrongholdRuleByID(sh_id);
            ScMapBuildingData tileData = Main.Instance.TableMgr.GetMapBuildingDataByID(strong_hold.BuildId);
            if (tileMsg.centerBuild.stronghold.available)
            {
                SetPicture(tileData.size, int.Parse(tileData.picture), tileMsg.data.pos);
                ScBasicSurfaceData basicSurface = Main.Instance.TableMgr.GetBasicSurfaceDataByType(strong_hold.SurfaceType);
                if (WorldMapMgr.instance.RangeMgr != null)
                {
                    WorldMapMgr.instance.RangeMgr.SetRange((int)tileMsg.data.pos.x, (int)tileMsg.data.pos.y, basicSurface.width, basicSurface.height);
                }
            }
            else
            {
                SetPicture(tileData.size, int.Parse(tileData.picture) + 1, tileMsg.data.pos);
            }

            if (tileMsg.centerBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(tileData.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_WorldCity)
        {
            int sh_id = (int)tileMsg.worldCity.cityId;
           // ScStrongholdRuleData strong_hold = Main.Instance.TableMgr.GetStrongholdRuleByID(sh_id);
            ScWorldCityData tileData = Main.Instance.TableMgr.GetWorldCityData(sh_id);
            SetPicture(tileData.size, tileData.art, tileMsg.data.pos);
        }
        else if (world.MobaMode == WorldMode.Moba && SetMobaBuilid(ref lindex, ref effect, entryType, tileMsg))
        {

        }
        else if (world.MobaMode == WorldMode.GuildMoba && SetGuildMobaBuilid(ref lindex, ref effect, entryType, tileMsg))
        {

        }
        else
        {
            object[] objects = LuaClient.GetMainState().GetFunction("WorldMap.DrawMap").Call((int)tileMsg.data.uid);

            if (objects == null)
                return;

            //effect = EncodeEffect(effect, (int)(double)objects[0]);
            effect.Add((int)(double)objects[0]);
            SetPicture((int)(double)objects[1], (int)(double)objects[2], tileMsg.data.pos);
        }

        world.WorldInfo.WBlockMap.SetEffect(lindex, effect);
    }

    bool SetMobaBuilid(ref int lindex, ref FastStack<int> effect, uint entryType, SEntryData tileMsg)
    {
        if (entryType == (int)SceneEntryType.SceneEntryType_MobaGate)
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;
            ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);
            if (!tileMsg.mobaBuild.broken)
            {
                SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            }
            else
            {
                SetPicture(moba_build.size, moba_build.idle_art, tileMsg.data.pos);
            }

            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }

            if (tileMsg.mobaBuild.broken)
            {
                effect.Add(mobaSpecialEffects[buidingid].broken_effect);
            }
            else if (tileMsg.mobaBuild.rulingTeam != tileMsg.mobaBuild.ownerTeam)
            {
                effect.Add(mobaSpecialEffects[buidingid].occupy_effect);
            }
            else
            {
                if (tileMsg.mobaBuild.garrisons.Count != 0 && tileMsg.mobaBuild.cityguard < tileMsg.mobaBuild.maxcityguard)
                {
                    effect.Add(mobaSpecialEffects[buidingid].repair_effect);
                }
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaCenter)
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(10);
            }


            if (tileMsg.mobaBuild.rulingTeam != tileMsg.mobaBuild.ownerTeam)
            {
                effect.Add(mobaSpecialEffects[buidingid].occupy_effect);
            }
            else
            {
                if (tileMsg.mobaBuild.garrisons.Count != 0 && tileMsg.mobaBuild.cityguard < tileMsg.mobaBuild.maxcityguard)
                {
                    effect.Add(mobaSpecialEffects[buidingid].repair_effect);
                }
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaArsenal)//武器库
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaFort)//堡垒
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaInstitute)//研究所
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaTransPlat)//传送镇
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScMobaBuildingRule moba_build = Main.Instance.TableMgr.GetMobaBuildingRuleData(buidingid);

            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaSmallBuild)//联盟争霸战 小建筑
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        return false;
    }

    bool SetGuildMobaBuilid(ref int lindex, ref FastStack<int> effect, uint entryType, SEntryData tileMsg)
    {
        if (entryType == (int)SceneEntryType.SceneEntryType_MobaCenter)
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(10);
            }


            if (tileMsg.mobaBuild.rulingTeam != tileMsg.mobaBuild.ownerTeam)
            {
                effect.Add(mobaSpecialEffects[buidingid].occupy_effect);
            }
            else
            {
                if (tileMsg.mobaBuild.garrisons.Count != 0 && tileMsg.mobaBuild.cityguard < tileMsg.mobaBuild.maxcityguard)
                {
                    effect.Add(mobaSpecialEffects[buidingid].repair_effect);
                }
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaArsenal)//武器库
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaFort)//堡垒
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaInstitute)//研究所
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaTransPlat)//传送镇
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);

            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        else if (entryType == (int)SceneEntryType.SceneEntryType_MobaSmallBuild)//联盟争霸战 小建筑
        {
            int buidingid = (int)tileMsg.mobaBuild.buidingid;

            ScGuildWarBuildingRule moba_build = Main.Instance.TableMgr.GetGuildWarBuildingRuleData(buidingid);
            SetPicture(moba_build.size, moba_build.art, tileMsg.data.pos);
            if (tileMsg.mobaBuild.hasShield)
            {
                ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(moba_build.size);
                int x = scObjectShapeData.xMin;
                int y = scObjectShapeData.yMin;
                lindex = (world.WorldInfo.LogicServerSizeX - ((int)tileMsg.data.pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)tileMsg.data.pos.y + y);
                //effect = EncodeEffect(effect, 11);
                effect.Add(11);
            }
            return true;
        }
        return false;
    }

    int EncodeEffect(int effect, int count)
    {
        return effect | (1 << count);
    }

    void SetPicture(int size, int picture, Position pos)
    {
        int lindex;
        if (size == 0)
        {
            lindex = (world.WorldInfo.LogicServerSizeX - ((int)pos.x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)pos.y);
            world.WorldInfo.WBlockMap.SetBuild(lindex, picture);
            return;
        }
        ScObjectShapeData scObjectShapeData = Main.Instance.TableMgr.GetObjectShapeData(size);
        if (scObjectShapeData != null)
        {
            int mx = scObjectShapeData.xMax - scObjectShapeData.xMin + 1;
            int my = scObjectShapeData.yMax - scObjectShapeData.yMin + 1;
            int plusx = 0;
            int plusy = 0;
            for (int x = scObjectShapeData.xMin; x <= scObjectShapeData.xMax; x++)
            {
                plusy = 0;
                for (int y = scObjectShapeData.yMin; y <= scObjectShapeData.yMax; y++)
                {
                    lindex = (world.WorldInfo.LogicServerSizeX - ((int)pos.x + x) - 1) * world.WorldInfo.LogicServerSizeX + ((int)pos.y + y);
                    world.WorldInfo.WBlockMap.SetBuild(lindex, EncodeBuildLIndex(mx, my, plusx, plusy, picture));
                    plusy++;
                }
                plusx++;
            }
        }
    }

    public int EncodeBuildLIndex(int x, int y, int px, int py, int picture)
    {
        return picture + py * 10000 + px * 100000 + y * 1000000 + x * 10000000;
    }
}
