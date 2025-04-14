module("WorldMapHUD", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local PathColors={
    PathBlue = Color(0,1,1,1),
    PathRed = Color(1,0,0,1),
    PathGreen = Color(0,1,0,1),
    PathWhite = Color(1,1,1,1),
    PathYellow = Color(1,0.92,0.016,1),
    PathViolet = Color(0.5,0,0.5,1),
}

local Switch_MapHUDInfo4Luas_CFG_Debug =
"0,".. --SceneEntryType_None = 0,
"1,".. --SceneEntryType_Home = 1,
"0,".. --SceneEntryType_Monster = 2,
"0,".. --SceneEntryType_ResFood = 3,
"0,".. --SceneEntryType_ResIron = 4,
"0,".. --SceneEntryType_ResOil = 5,
"0,".. --SceneEntryType_ResElec = 6,
"0,".. --SceneEntryType_Barrack = 7,
"0,".. --SceneEntryType_Occupy = 8,
"0,".. --SceneEntryType_ActMonster = 9,
"0,".. --SceneEntryType_GuildBuild = 10,
"0,".. --SceneEntryType_GuildTrainField = 11,
"0,".. --SceneEntryType_SiegeMonster = 12,
"0,".. --SceneEntryType_Fort = 13,
"0,".. --SceneEntryType_Govt = 14,
"0,".. --SceneEntryType_Turret = 15,
"0,".. --SceneEntryType_EliteMonster = 16,
"0,".. --SceneEntryType_Stronghold = 17,
"0,".. --SceneEntryType_Fortress = 18,
"0,".. --SceneEntryType_MobaGate = 19,
"0,".. --SceneEntryType_MobaCenter = 20,
"0,".. --SceneEntryType_MobaFort = 21,
"0,".. --SceneEntryType_MobaArsenal = 22,
"0,".. --SceneEntryType_MobaInstitute = 23,
"0,".. --SceneEntryType_MobaTransPlat = 24,
"0,".. --SceneEntryType_MobaSmallBuild = 25,
"0" --SceneEntryType_WorldCity = 26,

local Switch_PathHUDInfo4Luas_CFG_Debug = 
"0,0;".. --TeamMoveType_None = 0,
"1,0;".. --TeamMoveType_ResTake = 1,
"2,0;".. --TeamMoveType_MineTake = 2,
"3,0;".. --TeamMoveType_TrainField = 3,
"4,0;".. --TeamMoveType_Garrison = 4,
"5,0;".. --TeamMoveType_GatherCall = 5,
"6,0;".. --TeamMoveType_GatherRespond = 6,
"7,1;".. --TeamMoveType_AttackMonster = 7,
"8,0;".. --TeamMoveType_AttackPlayer = 8,
"9,0;".. --TeamMoveType_ReconPlayer = 9,
"10,0;".. --TeamMoveType_ReconMonster = 10,
"11,0;".. --TeamMoveType_Camp = 11,
"12,0;".. --TeamMoveType_Occupy = 12,
"13,0;".. --TeamMoveType_ResTransport = 13,
"14,0;".. --TeamMoveType_GuildBuildCreate = 14,
"15,0;".. --TeamMoveType_MonsterSiege = 15,
"16,0;".. --TeamMoveType_AttackFort = 16,
"17,0;".. --TeamMoveType_AttackCenterBuild = 17,
"18,0;".. --TeamMoveType_GarrisonCenterBuild = 18,
"19,0;".. --TeamMoveType_Nemesis = 19,
"20,0;".. --TeamMoveType_Prisoner = 20,
"21,0;".. --TeamMoveType_ClimbPvP = 21,
"22,0;".. --TeamMoveType_GuildCompensate = 22,
"23,0;".. --TeamMoveType_MobaAtkBuild = 23,
"24,0;".. --TeamMoveType_MobaGarrisonBuild = 24,
"25,0;".. --TeamMoveType_ArenaPvP = 25,
"26,0;".. --TeamMoveType_AttackWorldCity = 26,
"100,0" --TeamMoveType_ChapterPvP = 100

local Switch_MapHUDInfo4Luas_CFG = 
"0,".. --SceneEntryType_None = 0,
"0,".. --SceneEntryType_Home = 1,
"0,".. --SceneEntryType_Monster = 2,
"0,".. --SceneEntryType_ResFood = 3,
"0,".. --SceneEntryType_ResIron = 4,
"0,".. --SceneEntryType_ResOil = 5,
"0,".. --SceneEntryType_ResElec = 6,
"0,".. --SceneEntryType_Barrack = 7,
"0,".. --SceneEntryType_Occupy = 8,
"0,".. --SceneEntryType_ActMonster = 9,
"0,".. --SceneEntryType_GuildBuild = 10,
"0,".. --SceneEntryType_GuildTrainField = 11,
"0,".. --SceneEntryType_SiegeMonster = 12,
"0,".. --SceneEntryType_Fort = 13,
"0,".. --SceneEntryType_Govt = 14,
"0,".. --SceneEntryType_Turret = 15,
"0,".. --SceneEntryType_EliteMonster = 16,
"0,".. --SceneEntryType_Stronghold = 17,
"0,".. --SceneEntryType_Fortress = 18,
"0,".. --SceneEntryType_MobaGate = 19,
"0,".. --SceneEntryType_MobaCenter = 20,
"0,".. --SceneEntryType_MobaFort = 21,
"0,".. --SceneEntryType_MobaArsenal = 22,
"0,".. --SceneEntryType_MobaInstitute = 23,
"0,".. --SceneEntryType_MobaTransPlat = 24,
"0,".. --SceneEntryType_MobaSmallBuild = 25,
"0" --SceneEntryType_WorldCity = 26,

local Switch_PathHUDInfo4Luas_CFG = 
"0,0;".. --TeamMoveType_None = 0,
"1,0;".. --TeamMoveType_ResTake = 1,
"2,0;".. --TeamMoveType_MineTake = 2,
"3,0;".. --TeamMoveType_TrainField = 3,
"4,0;".. --TeamMoveType_Garrison = 4,
"5,0;".. --TeamMoveType_GatherCall = 5,
"6,0;".. --TeamMoveType_GatherRespond = 6,
"7,0;".. --TeamMoveType_AttackMonster = 7,
"8,0;".. --TeamMoveType_AttackPlayer = 8,
"9,0;".. --TeamMoveType_ReconPlayer = 9,
"10,0;".. --TeamMoveType_ReconMonster = 10,
"11,0;".. --TeamMoveType_Camp = 11,
"12,0;".. --TeamMoveType_Occupy = 12,
"13,0;".. --TeamMoveType_ResTransport = 13,
"14,0;".. --TeamMoveType_GuildBuildCreate = 14,
"15,0;".. --TeamMoveType_MonsterSiege = 15,
"16,0;".. --TeamMoveType_AttackFort = 16,
"17,0;".. --TeamMoveType_AttackCenterBuild = 17,
"18,0;".. --TeamMoveType_GarrisonCenterBuild = 18,
"19,0;".. --TeamMoveType_Nemesis = 19,
"20,0;".. --TeamMoveType_Prisoner = 20,
"21,0;".. --TeamMoveType_ClimbPvP = 21,
"22,0;".. --TeamMoveType_GuildCompensate = 22,
"23,0;".. --TeamMoveType_MobaAtkBuild = 23,
"24,0;".. --TeamMoveType_MobaGarrisonBuild = 24,
"25,0;".. --TeamMoveType_ArenaPvP = 25,
"26,0;".. --TeamMoveType_AttackWorldCity = 26,
"100,0" --TeamMoveType_ChapterPvP = 100

function EnableHotFixedDebug()
    return false
end

local function ActiveHotFixedDebug()
    return false
end

function GetSwitch_MapHUDInfo4Luas()
    if EnableHotFixedDebug() then
        return Switch_MapHUDInfo4Luas_CFG_Debug
    else
        return Switch_MapHUDInfo4Luas_CFG
    end
    
end

function GetSwitch_PathHUDInfo4Luas()
    if EnableHotFixedDebug() then
        return Switch_PathHUDInfo4Luas_CFG_Debug
    else
        return Switch_PathHUDInfo4Luas_CFG
    end 
end

local function SetHUDInfoInternalDebug(worldHUDMgr,tileMsg)
    if not ActiveHotFixedDebug() then
        return
    end
    if tileMsg.data.entryType == Common_pb.SceneEntryType_Home then
        local guildtitle = 174  
        if guildtitle ~= 0 then
            worldHUDMgr:ShowWidget(6);
            worldHUDMgr:SetWidgetText(6, "wedwerqwerfwerqwe")--TextMgr:GetText(TableMgr:GetGlobalData(guildtitle).value));
        else
            worldHUDMgr:HideWidget(6);
        end
    end
end

local function SetHUDInfoInternal(worldHUDMgr,tileMsg)

end

local function SetExpeditionHUDInfoInLuaInternalDebug(worldHUDMgr,tileMsg)
    if not ActiveHotFixedDebug() then
        return
    end 
    if tileMsg.pathType == Common_pb.TeamMoveType_AttackMonster then
        worldHUDMgr:ShowWidget(0);
        worldHUDMgr:SetWidgetText(0, "Dsdasdasdadasdadwe");
    end 
end

local function SetExpeditionHUDInfoInLuaInternal(worldHUDMgr,tileMsg)
end


local function CreateHUDInfoDebug(worldHUDMgr,tileMsg)
    if not ActiveHotFixedDebug() then
        return
    end 
    if tileMsg.data.entryType >= Common_pb.SceneEntryType_ResFood and tileMsg.data.entryType <= Common_pb.SceneEntryType_ResElec then
        worldHUDMgr:Initialize("ResourceHUD_Debug");
    end 
end

local function DrawHUDInfoDebug(worldHUDMgr,tileMsg)
    if not ActiveHotFixedDebug() then
        return
    end 
    if tileMsg.data.entryType >= Common_pb.SceneEntryType_ResFood and tileMsg.data.entryType <= Common_pb.SceneEntryType_ResElec then
        local res_level = tileMsg.res.level
        local resourceOwnerID = tileMsg.res.owner;
        local ownerGuildID = tileMsg.ownerguild.guildid;
        worldHUDMgr:SetWidgetText(0, res_level);
        worldHUDMgr:DrawBubbleByOwner(1, resourceOwnerID, ownerGuildID);
        worldHUDMgr:InitializeCountdown(2);

        if resourceOwnerID == MainData.GetCharId() then
            worldHUDMgr:ShowWidget(2);
            worldHUDMgr:SetTimerTimeStamp(tileMsg.res.takestarttime + tileMsg.res.taketime);
        else
            worldHUDMgr:HideWidget(2);
            worldHUDMgr:SetTimerTimeStamp(0);
        end
    end 
end

local function CreateHUDInfo(worldHUDMgr,tileMsg)
end

local function DrawHUDInfo(worldHUDMgr,tileMsg)
end

local function GetExpeditionPathColor(tileMsg)
    local color
    if(tileMsg.govtOfficial > 0) then
        local scOfficialData = TableMgr:GetGoveOfficialDataByid(tileMsg.govtOfficial)
        if (scOfficialData.grade == 1) then
            color = PathColors.PathYellow;
            return color 
        end
    end
    if(tileMsg.guildOfficialId > 0) then
        local scOfficialData = tableData_tUnionOfficial.data[tileMsg.guildOfficialId]
        if (scOfficialData.isLord == 1) then
            color = PathColors.PathYellow;
            return color 
        end
    end 

    if (tileMsg.pathType == Common_pb.TeamMoveType_MonsterSiege) then
        color = PathColors.PathWhite; 
        return color 
    end                                     

    if (tileMsg.pathType == Common_pb.TeamMoveType_Nemesis) then
        color = PathColors.PathRed;
        return color
    end

    if (tileMsg.pathType == Common_pb.TeamMoveType_Prisoner) then
        color = PathColors.PathViolet;
        return color
    end

    if (tileMsg.charid == MainData.GetCharId()) then
        color = PathColors.PathGreen;
    else
        local selfGuildId =UnionInfoData.GetGuildId()
        if selfGuildId ~= 0 and selfGuildId == tileMsg.ownerguild.guildid then
            color = PathColors.PathBlue;
        else
            color = PathColors.PathRed;
        end
    end
    return color
end

local function SetExpeditionIDDebug(tileMsg)
    if not ActiveHotFixedDebug() then
        return 0, Color(1,1,1,1), false
    end 
    local id = 0
    local color = GetExpeditionPathColor(tileMsg)
    local isEffect = false  
    if tileMsg.pathType == Common_pb.TeamMoveType_ResTransport or
       tileMsg.pathType == Common_pb.TeamMoveType_ResTake or
       tileMsg.pathType == Common_pb.TeamMoveType_MineTake 
      then
        if (tileMsg.govtOfficial == 1) then
            id = 8;
        else
            id = 2;
        end
    end
    return id, color, isEffect 
end

local function SetExpeditionIDInternal(tileMsg)
    local id = 0
    local color = Color(1,1,1,1)
    local isEffect = false 

    return id, color, isEffect 
end

--针对新的协议创建新建筑和UI
function InitializeHUD(worldHUDMgr,entry_type,x,y)
    local map_mgr = WorldMap.GetWorldMapMgr()
    if map_mgr == nil then
        return
    end
    local tileMsg
    local tileMsgBytes = map_mgr:TileInfo(x % WorldMap.GetServerMapSize(), y % WorldMap.GetServerMapSize())
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then 
        return
    end    
    if EnableHotFixedDebug() then
        CreateHUDInfoDebug(worldHUDMgr,tileMsg)
        DrawHUDInfoDebug(worldHUDMgr,tileMsg)
    else
        CreateHUDInfo(worldHUDMgr,tileMsg)
        DrawHUDInfo(worldHUDMgr,tileMsg)
    end
end

--针对新的协议刷新建筑和UI
function RefreshHUD(worldHUDMgr,entry_type,x,y)
    local map_mgr = WorldMap.GetWorldMapMgr()
    if map_mgr == nil then
        return
    end
    local tileMsg
    local tileMsgBytes = map_mgr:TileInfo(x % WorldMap.GetServerMapSize(), y % WorldMap.GetServerMapSize())
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then 
        return
    end    
    if EnableHotFixedDebug() then
        DrawHUDInfoDebug(worldHUDMgr,tileMsg)
    else
        DrawHUDInfo(worldHUDMgr,tileMsg)
    end 
end
--对老协议的建筑UI的修改
function SetHUDInfo(worldHUDMgr,entry_type,x,y)
    
    local map_mgr = WorldMap.GetWorldMapMgr()
    if map_mgr == nil then
        return
    end
    local tileMsg
    local tileMsgBytes = map_mgr:TileInfo(x % WorldMap.GetServerMapSize(), y % WorldMap.GetServerMapSize())
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then 
        return
    end
    if EnableHotFixedDebug() then
        SetHUDInfoInternalDebug(worldHUDMgr,tileMsg)
    else
        SetHUDInfoInternal(worldHUDMgr,tileMsg)
    end
    
end
--对新协议的兵线刷新
function SetExpeditionID(path_type,path_id)
     local map_mgr = WorldMap.GetWorldMapMgr()
     if map_mgr == nil then
        return 0, Color(1,1,1,1), false
     end
     local tileMsg
     local tileMsgBytes = map_mgr:GetPathMsg(path_id)
     if #tileMsgBytes > 0 then
         tileMsg = MapData_pb.SEntryPathInfo()
         tileMsg:ParseFromString(tileMsgBytes)
     end
     if tileMsg == nil then 
        return 0, Color(1,1,1,1), false
     end
     if EnableHotFixedDebug() then
        return SetExpeditionIDDebug(tileMsg)
    else
        return SetExpeditionIDInternal(tileMsg)
    end 
end
--对新老协议的兵线UI的修改
function SetExpeditionHUDInfoInLua(worldHUDMgr,path_id)
    local map_mgr = WorldMap.GetWorldMapMgr()
    if map_mgr == nil then
        return
    end
    local tileMsg
    local tileMsgBytes = map_mgr:GetPathMsg(path_id)
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryPathInfo()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then 
        return
    end
    if EnableHotFixedDebug() then
        SetExpeditionHUDInfoInLuaInternalDebug(worldHUDMgr,tileMsg)
    else
        SetExpeditionHUDInfoInLuaInternal(worldHUDMgr,tileMsg)
    end
end


function SetHUD4_Fortress_Government_TurretInLua(worldHUDMgr,x,y)
    local map_mgr = WorldMap.GetWorldMapMgr()
    if map_mgr == nil then
        return
    end
    local tileMsg
    local tileMsgBytes = map_mgr:TileInfo(x % WorldMap.GetServerMapSize(), y % WorldMap.GetServerMapSize())
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then 
        return
    end
    local display_time = tonumber(TableMgr:GetGlobalData(100180).value)
    local curTime = Serclimax.GameTime.GetSecTime()
    if tileMsg.data.entryType == Common_pb.SceneEntryType_Fortress then
        coroutine.start(function()
            coroutine.step()
            local time = worldHUDMgr.transform:Find("GovernmentHUD(Clone)/label_time")
            local efortress = tileMsg.centerBuild.fortress;
            if time ~= nil then
                local fortress =  FortressData.GetFortressData(efortress.subtype)
                print("F ",fortress.contendStartTime , fortress.firstStartTime,display_time,curTime,fortress.contendStartTime - curTime , display_time)
                if fortress.contendStartTime == fortress.firstStartTime then
                    if fortress.contendStartTime - curTime > display_time then
                        time.gameObject:SetActive(false)
                    end
                end     
            end  
        end)
    elseif tileMsg.data.entryType == Common_pb.SceneEntryType_Turret then
        coroutine.start(function()
            coroutine.step()
            local time = worldHUDMgr.transform:Find("TurrentHUD(Clone)/label_time")
            if time ~= nil then
                local act_info = GovernmentData.GetGovActInfo()
                print("T ",act_info.contendStartTime , act_info.firstStartTime,display_time,curTime,act_info.contendStartTime - curTime , display_time)
                if act_info.contendStartTime == act_info.firstStartTime then
                    if act_info.contendStartTime - curTime > display_time then
                        time.gameObject:SetActive(false)
                    end
                end
            end  
        end)        

    elseif tileMsg.data.entryType == Common_pb.SceneEntryType_Govt then
        coroutine.start(function()
            coroutine.step()
            local time = worldHUDMgr.transform:Find("GovernmentHUD(Clone)/label_time")
            if time ~= nil then
                local act_info = GovernmentData.GetGovActInfo()
                print("G ",act_info.contendStartTime , act_info.firstStartTime,display_time,curTime,act_info.contendStartTime - curTime , display_time)
                if act_info.contendStartTime == act_info.firstStartTime then
                    if act_info.contendStartTime - curTime > display_time then
                        time.gameObject:SetActive(false)
                    end
                end
            end               
        end)        
    end
end
