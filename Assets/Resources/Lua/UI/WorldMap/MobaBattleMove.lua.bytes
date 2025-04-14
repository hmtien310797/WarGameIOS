module("MobaBattleMove", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local interface={
    ["TileInfo"] = MobaTileInfo,
    ["MainData"] = MobaMainData,
    ["SelectHero_PVP"] = MobaSelectHero_PVP,
    ["BarrackData"] = MobaBarrackData,
    ["BattleMoveData"] = MobaBattleMoveData,
    ["ArmySetoutStarRequest"] = MobaMsg_pb.MsgMobaArmySetoutStarRequest,
    ["Category_pb_MoveRequest"] = Category_pb.Moba,
    ["ArmySetoutStarRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaArmySetoutStarRequest,
    ["ArmySetoutStarResponse"] = MobaMsg_pb.MsgMobaArmySetoutStarResponse,
    ["ArmySetoutData"] = MobaArmySetoutData,
    ["ArmyMovePlayer"] = Global.MobaArmyMovePlayer,
    ["ResBar"] = MobaResBar,
    ["BMSelectHero"] = MobaBMSelectHero,
    ["Main"] = MobaMain,
    ["Chat"] = MobaChat,
    ["chanel_Team"] = ChatMsg_pb.chanel_MobaTeam,
    ["Chat_TestSystemJump_01"] = "Chat_TestSystemJump_Moba01",
    ["BuffData"] = MobaBuffData,
    ["GetArmySetoutUIRequest"] = MobaMsg_pb.MsgMobaGetArmySetoutUIRequest,
    ["Category_pb_RequestShow"] = Category_pb.Moba,
    ["GetArmySetoutUIRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaGetArmySetoutUIRequest,
    ["GetArmySetoutUIResponse"] = MobaMsg_pb.MsgMobaGetArmySetoutUIResponse,
    ["ActionListData"] = MobaActionListData,
    ["HeroListData"] = MobaHeroListData,
    ["HeroListData_GetAttributes"] = function(hero_msg) return MobaHeroListData.GetAttributes(hero_msg) end,
	["CalNormalBattleMoveMaxNum"] = function()
        local maxnum = 0
        maxnum = Global.MobaArmyMovePlayer()
        return maxnum
    end,
}

local interface_guild={
    ["TileInfo"] = MobaTileInfo,
    ["MainData"] = MobaMainData,
    ["SelectHero_PVP"] = MobaSelectHero_PVP,--ok
    ["BarrackData"] = MobaBarrackData,--ok
    ["BattleMoveData"] = MobaBattleMoveData,
    ["ArmySetoutStarRequest"] = GuildMobaMsg_pb.GuildMobaArmySetoutStarRequest,
    ["Category_pb_MoveRequest"] = Category_pb.GuildMoba,
    ["ArmySetoutStarRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaArmySetoutStarRequest,
    ["ArmySetoutStarResponse"] = GuildMobaMsg_pb.GuildMobaArmySetoutStarResponse,
    ["ArmySetoutData"] = MobaArmySetoutData,
    ["ArmyMovePlayer"] = function()
        print("--------------------------------------------------------------------------------")
        local base_num = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseSoliderNum)
        maxnum = base_num.value
        local pd = maincity.GetBuildingByID(4)
        if pd ~= nil then
            local pd_data = TableMgr:GetParadeGroundData(pd.data.level)
           maxnum = maxnum + pd_data.addlimit  
        end
	
	    local curLv = MainData.GetData().commanderLeadLevel
	    local data = TableMgr:GetCommandData(curLv)
	    maxnum = maxnum + --[[base_num.value +]] data.SoldierNum
        maxnum = calMaxSoilderNum(maxnum)
        return math.floor(maxnum +0.5)
    end,
    ["ResBar"] = MobaResBar,
    ["BMSelectHero"] = MobaBMSelectHero,
    ["Main"] = GuildWarMain,
    ["Chat"] = MobaChat,
    ["chanel_Team"] = ChatMsg_pb.chanel_MobaTeam,
    ["Chat_TestSystemJump_01"] = "Chat_TestSystemJump_Moba01",
    ["BuffData"] = MobaBuffData,
    ["GetArmySetoutUIRequest"] = GuildMobaMsg_pb.GuildMobaGetArmySetoutUIRequest,
    ["Category_pb_RequestShow"] = Category_pb.GuildMoba,
    ["GetArmySetoutUIRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetArmySetoutUIRequest,
    ["GetArmySetoutUIResponse"] = GuildMobaMsg_pb.GuildMobaGetArmySetoutUIResponse,
    ["ActionListData"] = MobaActionListData,
    ["HeroListData"] = MobaHeroListData,
    ["HeroListData_GetAttributes"] = function(hero_msg) return MobaHeroListData.GetAttributes(hero_msg)[2] end,
	["CalNormalBattleMoveMaxNum"] =function()
        local maxnum = 0
        local base_num = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseSoliderNum)
        maxnum = base_num.value
        local pd = maincity.GetBuildingByID(4)
        if pd ~= nil then
            local pd_data = TableMgr:GetParadeGroundData(pd.data.level)
           maxnum = maxnum + pd_data.addlimit  
        end
        
	    local curLv = MainData.GetData().commanderLeadLevel
	    local data = TableMgr:GetCommandData(curLv)
        maxnum = maxnum + --[[base_num.value +]] data.SoldierNum

--[[
        print("BaseSoliderNum",TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseSoliderNum).value,
        "ParadeGround", TableMgr:GetParadeGroundData(pd.data.level).addlimit,
        "commanderLeadLevel",TableMgr:GetCommandData(curLv).SoldierNum)
--]] 

        maxnum = calMaxSoilderNum(maxnum)
        --print("-------------------------------------calMaxSoilderNum-",maxnum)
        return math.floor(maxnum +0.5)
    end,
}

local function GetInterface(interface_name)
    if Global.GetMobaMode() == 1 then
        return interface[interface_name]
    elseif Global.GetMobaMode() == 2 then
        return interface_guild[interface_name]
    end
    
end


local selectSoldier
local BattleUI

local BattleLeftInfos

local BattleLeftSortInfos

local CurArchive

local ArmyNumber

local MaxSoilderNumber

local QuickTime = 0

local SelectHero

local userWaring

local formationSmall

local targatFormationData

local selfFormation
local filtFormation

local targetFormation

local SuccessCallBack

local cancelCallback

local FixedMaxSoilderNumber

local MassTime

local hascheckedshield
local pathType
local entry
local curUid
local curCharName
local curPx
local curPy
local curPx2
local curPy2
local Dis
local CurSelectArchive = nil
local NeedSaveArchive = false

local BattleFight

local BattleFightBase

RefrushFight = nil
GetMoveCost = nil
RefreshHeroAdd = nil
local SetLeftInfo
local timecost 
local heroAdd = {}

local sweepCount

CalNormalBattleMoveMaxNum = nil
local calWeight
local entryType 
----- Constants -----------------------------------------------------------------
local QUICK_SELECT_UNLOCK_MISSION_ID = 1804

local EXPEDIATION_TIMEOUT = tonumber(TableMgr:GetGlobalData(111).value) * 60
local HAS_EXPEDIATION_TIMEOUT =
{
    [Common_pb.TeamMoveType_ResTake]              = true,          -- 资源采集
    [Common_pb.TeamMoveType_MineTake]             = true,          -- 超级矿采集
    [Common_pb.TeamMoveType_TrainField]           = true,          -- 训练场
    [Common_pb.TeamMoveType_Garrison]             = true,          -- 驻防
    [Common_pb.TeamMoveType_GatherCall]           = true,          -- 发起集结
    [Common_pb.TeamMoveType_GatherRespond]        = true,          -- 响应集结
    [Common_pb.TeamMoveType_AttackMonster]        = true,          -- 攻击怪
    [Common_pb.TeamMoveType_AttackPlayer]         = true,          -- 攻击玩家
    [Common_pb.TeamMoveType_ReconPlayer]          = true,          -- 侦查玩家
    [Common_pb.TeamMoveType_ReconMonster]         = true,          -- 侦查怪
    [Common_pb.TeamMoveType_Camp]                 = true,          -- 扎营
    [Common_pb.TeamMoveType_Occupy]               = true,          -- 占领
    [Common_pb.TeamMoveType_ResTransport]         = true,          -- 资源运输
    [Common_pb.TeamMoveType_GuildBuildCreate]     = true,          -- 联盟建筑
    [Common_pb.TeamMoveType_MonsterSiege]         = true,          -- 怪物攻城
    [Common_pb.TeamMoveType_AttackFort]           = true,          -- 攻击要塞
    [Common_pb.TeamMoveType_AttackCenterBuild]    = true,          -- 攻击中央建筑
    [Common_pb.TeamMoveType_GarrisonCenterBuild]  = true,          -- 驻防中央建筑
}

local POWER_SAFE_RATIO = tonumber(TableMgr:GetGlobalData(115).value)
---------------------------------------------------------------------------------

local BMCalResult = {}

local BMCalculationType =
{
    CalMaxSoldierFunc = 1,
    CalWeightFunc = 2,
    CalGatherFunc = 3,
    CalMoveTimeFunc = 4,
    CalOccupyTimeFunc = 5,
}

local BMCalculationFunc = 
{
    [1] = function()
        local result = {}  
        result.normal  =  math.floor(GetInterface("CalNormalBattleMoveMaxNum")())
        result.final = result.normal 
        if FixedMaxSoilderNumber ~= nil then
            result.final = math.floor(math.min(result.normal, FixedMaxSoilderNumber))       
        end
        MaxSoilderNumber = result.final
        return result
    end,
    [2] = function()
        local result = {}
        result.final = 0
        table.foreach(BattleLeftInfos,function(_, v)
            if v.num ~= 0 then
                result.final = result.final + calWeight(v.num * (v.base_weight + AttributeBonus.GetAttribute(v.type_id, 33)), v.bonusArmyType, v.type_id)
            end
        end)  
        return result
    end, 
    [3] = function()
        local result = {}
        result.final = 0
        if pathType == Common_pb.TeamMoveType_ResTake or pathType == Common_pb.TeamMoveType_MineTake then
            local tile = GetInterface("TileInfo").GetTileMsg()
            if tile == nil then
                return result
            end
            local tileData = WorldMap.GetTileData(tile)
            if pathType == Common_pb.TeamMoveType_ResTake then
                result.final = ResView.GetSpeedByType(tileData.type,tile.res.level)
            elseif pathType == Common_pb.TeamMoveType_MineTake then
                local buildingMsg = tile.guildbuild
                local speed = 0
                if buildingMsg.extraSpeed ~= nil then
                    speed = buildingMsg.extraSpeed
                end
                result.final = ResView.GetSpeedByType(tileData.resourceType)*(1+speed)
            end
        end
        return result        
    end,         
    [4] = function()
        local result = {}
        result.final = 0   
        local speed = 0
        table.foreach(BattleLeftInfos,function(i,v) 
            if v.num ~= 0 then
                if speed <= 0 then
                    speed = v.speed + AttributeBonus.GetAttribute(v.type_id, 34)
                else
                    if v.speed < speed then
                        speed = v.speed + AttributeBonus.GetAttribute(v.type_id, 34)
                    end
                end
            end
        end)   
        if speed <= 0 then
            return result
        end  
       
        local mypos =   GetInterface("MainData").GetPos()-- MapInfoData.GetData().mypos
        local factor = 1
        --if WorldMap.IsInRestrictArea(mypos.x,mypos.y) or WorldMap.IsInRestrictArea(curPx,curPy) then
        --    factor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RestrictAreaSpeedFactor).value)
        --end
        result.final = Dis / GetMoveCost(speed,pathType)
        print("DisDisDisDisDisDisDisDisDisDisDisDisDisDis",Dis,"speed",speed)
		local mbs = Dis / speed
        result.final  = result.final * factor
        return result
    end,   
    [5] = function()
        local result = {}
        result.final = 0         
        local num = 0
        table.foreach(BattleLeftInfos,function(_,v) 
            if v.num ~= 0 then
                num = num + v.num*v.fight_point
            end
        end)   
        local min_time = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyMinTime).value)
        local max_time = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyMaxTime).value)
        local enmey_factor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyEnemyTimeFactor).value)

        local factor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyTimeFactor).value)

        if not WorldBorderData.IsEnemyBorder(curPx, curPy) then
            enmey_factor = 1
        end

        local base_time = math.max(min_time,max_time -num/factor )
        --print(min_time,max_time,num,factor,num/factor,base_time,enmey_factor)
        local bonus = AttributeBonus.GetBonusInfos()
        result.final = base_time * enmey_factor / (1 + (bonus[1094] ~= nil and bonus[1094] or 0) * 0.01)
					/( 1 + (bonus[1098] ~= nil and bonus[1098] or 0) * 0.01)
        result.final = math.floor(result.final )
        return result
    end,   
}


local BMInfoType =
{
    T_MaxSoldier = 1,
    T_Weight = 2,
    T_Gather = 3,
    T_MoveTime=4,
    T_OccupyTime=5,
}

local BMInfoStringIDs=
{
    "battlemove_ui3",
    "battlemove_ui4",
    "BattleMove_collect",
    "BattleMove_move",
    "BattleMove_occupy",
}

local BMInfoTips=
{
    {tips = "BattleMove_soldier_tips",title = "BattleMove_soldier_title"},--出征上限
    {tips = "BattleMove_weight_tips",title ="BattleMove_weight_title"},-- 负重
    {tips = "BattleMove_collect_tips",title ="BattleMove_collect_title"},-- 采集时间
    {tips = "BattleMove_move_tips",title ="BattleMove_move_title"},-- 行军时间
    {tips = "BattleMove_occupy_tips",title ="BattleMove_occupy_title"},-- 占领时间
}

local BMInfoStrColor =
{
    "[FFFFFFFF]", -- 白色
    "[FBFF00FF]", -- 黃色
    "[00FF1E]", -- 綠色
    "[-]",-- end
}


local BMPathShowInfoTypes ={
	[Common_pb.TeamMoveType_ResTake] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime,BMInfoType.T_Gather,BMInfoType.T_Weight},           --资源采集
	[Common_pb.TeamMoveType_MineTake] ={BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime,BMInfoType.T_Gather,BMInfoType.T_Weight},			--超级矿采集
	[Common_pb.TeamMoveType_TrainField] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--训练场
	[Common_pb.TeamMoveType_Garrison] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},			--驻防
	[Common_pb.TeamMoveType_GatherCall] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--发起集结
	[Common_pb.TeamMoveType_GatherRespond] ={BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--响应集结
	[Common_pb.TeamMoveType_AttackMonster] ={BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--攻击怪
	[Common_pb.TeamMoveType_AttackPlayer] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--攻击玩家
	[Common_pb.TeamMoveType_ReconPlayer] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--侦查玩家
	[Common_pb.TeamMoveType_ReconMonster] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--侦查怪
	[Common_pb.TeamMoveType_Camp] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},			--扎营
    [Common_pb.TeamMoveType_Occupy] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime,BMInfoType.T_OccupyTime},			--占领
	[Common_pb.TeamMoveType_ResTransport] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--资源运输
	[Common_pb.TeamMoveType_GuildBuildCreate] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},	--联盟建筑
	[Common_pb.TeamMoveType_MonsterSiege]	= {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},	--怪物攻城
	[Common_pb.TeamMoveType_AttackFort] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--攻击要塞
	[Common_pb.TeamMoveType_AttackCenterBuild] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--攻击政府
	[Common_pb.TeamMoveType_GarrisonCenterBuild] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},  	--驻防政
}

local BMPathChangeColorTypes ={
	[Common_pb.TeamMoveType_ResTake] = {BMInfoType.T_Gather,BMInfoType.T_Weight},           --资源采集
	[Common_pb.TeamMoveType_MineTake] ={BMInfoType.T_Gather,BMInfoType.T_Weight},			--超级矿采集
	[Common_pb.TeamMoveType_TrainField] = {BMInfoType.T_MoveTime},		--训练场
	[Common_pb.TeamMoveType_Garrison] = {BMInfoType.T_MoveTime},			--驻防
	[Common_pb.TeamMoveType_GatherCall] = {BMInfoType.T_MaxSoldier},		--发起集结
	[Common_pb.TeamMoveType_GatherRespond] ={BMInfoType.T_MaxSoldier},		--响应集结
	[Common_pb.TeamMoveType_AttackMonster] ={BMInfoType.T_MoveTime},		--攻击怪
	[Common_pb.TeamMoveType_AttackPlayer] = {BMInfoType.T_MaxSoldier},		--攻击玩家
	[Common_pb.TeamMoveType_ReconPlayer] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--侦查玩家
	[Common_pb.TeamMoveType_ReconMonster] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--侦查怪
	[Common_pb.TeamMoveType_Camp] = {BMInfoType.T_MoveTime},			--扎营
    [Common_pb.TeamMoveType_Occupy] = {BMInfoType.T_OccupyTime},			--占领
	[Common_pb.TeamMoveType_ResTransport] = {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},		--资源运输
	[Common_pb.TeamMoveType_GuildBuildCreate] = {BMInfoType.T_MaxSoldier},	--联盟建筑
	[Common_pb.TeamMoveType_MonsterSiege]	= {BMInfoType.T_MaxSoldier,BMInfoType.T_MoveTime},	--怪物攻城
	[Common_pb.TeamMoveType_AttackFort] = {BMInfoType.T_MoveTime},		--攻击要塞
	[Common_pb.TeamMoveType_AttackCenterBuild] = {BMInfoType.T_MoveTime},		--攻击政府
	[Common_pb.TeamMoveType_GarrisonCenterBuild] = {BMInfoType.T_MoveTime},  	--驻防政
}

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if BattleUI == nil then
        return
    end
    if go ~= BattleUI.tipObject then
        BattleUI.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function CloneFormation(formation)
	local clone = {}
	for i=1 , #formation , 1 do
		clone[i] = formation[i]
	end
	return clone
end

local function FormationDefilter(filt_formation , self_formation)
	local resFormation = {}
	for i=1 , #self_formation , 1 do
		local s_f = self_formation[i]
		if s_f > 0 then
			local kf = 0
			for k = 1 , #filt_formation , 1 do
				local f_f = filt_formation[k]
				if f_f == s_f then
					kf = k
				end
			end
			if kf <= 0 then
				for fi=1 , #filt_formation , 1 do
					if filt_formation[fi] == 0 then
						filt_formation[fi] = self_formation[i]
						break
					end
				end
				
			end
		end
	end
end

local function KeepVaildFormation(formation)
    local Barrackids = {[21] = false,[22] = false,[23] = false,[24] = false,}

    for i=1,#formation do
        if Barrackids[formation[i]] ~= nil then
            Barrackids[formation[i]] = true
        end
    end

    table.foreach(Barrackids,function(b,v) 
        if not v then
            for i=1,#formation do
                if formation[i] == 0 then
                    formation[i] = b
                    break
                end
            end
        end
    end)
    return formation
end

local function ShowSoldierDetail()
	--print("校场带兵量：" , CalNormalBattleMoveMaxNum())
	--print("校场带兵量：" , CalNormalBattleMoveMaxNum())
	BattleUI.soldieView.gameObject:SetActive(true)
	
	--[[local ignore = {"BattleMove", "SelectArmy"}
    AttributeBonus.CollectBonusInfo(ignore)
	
	local maxnum = 0
    local base_num = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseSoliderNum)
    maxnum = base_num.value
    local pd = maincity.GetBuildingByID(4)
    if pd ~= nil then
        local pd_data = TableMgr:GetParadeGroundData(pd.data.level)
        maxnum = maxnum + pd_data.addlimit  
    end
	
    maxnum = calMaxSoilderNum(maxnum)
	BattleUI.soldieView:Find("back/Label4"):GetComponent("UILabel").text = maxnum--95874
	
	
	local curLv = MainData.GetData().commanderLeadLevel
	local data = TableMgr:GetCommandData(curLv)
	maxnum = data.SoldierNum
	maxnum = calMaxSoilderNum(maxnum)
	BattleUI.soldieView:Find("back/Label2"):GetComponent("UILabel").text = maxnum]]
	
	--校场基础带兵量
	local maxnumParagound = 0
	local base_num = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseSoliderNum)
    maxnumParagound = base_num.value
	local pd = maincity.GetBuildingByID(4)
    if pd ~= nil then
        local pd_data = TableMgr:GetParadeGroundData(pd.data.level)
        maxnumParagound = maxnumParagound + pd_data.addlimit  
    end
	BattleUI.soldieView:Find("back/Label4"):GetComponent("UILabel").text = maxnumParagound
	
	--指挥官基础带兵量
	local maxnumCommander = 0
	local curLv = MainData.GetData().commanderLeadLevel
	local data = TableMgr:GetCommandData(curLv)
	maxnumCommander = data.SoldierNum
	BattleUI.soldieView:Find("back/Label2"):GetComponent("UILabel").text = maxnumCommander
	
	--加成带兵量
	BattleUI.soldieView:Find("back/Label6"):GetComponent("UILabel").text = math.max(0, BMCalResult.HadHeroResult[1].final - maxnumCommander - maxnumParagound)
	
    return maxnum
	
end

--BattleLeftSortInfos[soldier_data.Grade*100+soldier_data.SoldierId] = info
local function FormationFilter(formation)
    --先将BattleLeftSortInfos按兵营id合并
    local formation_map = {}
    
    for i=1,#formation do
        if formation[i] ~= 0 and formation[i]>=20 and formation[i] <=30 then
            formation_map[formation[i]] = i
        end
    end
    local leftinfo = {}
	for k , v in pairs(BattleLeftSortInfos) do
        local soldierData = TableMgr:GetBarrackData(k - v.level * 100, v.level)
		if leftinfo[soldierData.BarrackId] == nil then
			leftinfo[soldierData.BarrackId] = {num = v.num , level = v.level}
		else
			local num = leftinfo[soldierData.BarrackId].num
			leftinfo[soldierData.BarrackId].num = num + v.num
        end
        if formation_map[soldierData.BarrackId] == nil then
            for i=1,#formation do
                if formation[i] == 0 then
                    formation[i] = soldierData.BarrackId
                    break
                end
            end
        end
	end
	
	for i=1 , #formation , 1 do
		if formation[i] > 0 then
			local active = false
			for k , v in pairs(leftinfo) do
				if formation[i] == k then
					active = true
					if v.num == 0 then
						formation[i] = 0
					end
				end
			end
			
			if not active then
				formation[i] = 0
			end
		end
	end
end

local function LoadBMInfoItem(trf)
    local item = {}
    item.label = trf:GetComponent("UILabel")
    item.bones_label = trf:Find("Label/general_num"):GetComponent("UILabel")
    item.bones_labelTrf = trf:Find("Label")
    item.tips = trf:Find("icon")
    item.jiantou =  trf:Find("jiantou")
    return item
end

local function ChangeColor(index)
    local bmi = BMPathChangeColorTypes[pathType]
    if bmi == nil then
        return false
    end
    local result = false
    table.foreach(bmi,function(i,v)
        if v == index then
            result = true
        end
    end) 
    return result
end

local function RefreshBMInfoType(index)
    if index == BMInfoType.T_MaxSoldier then
        local num = 0
        
        table.foreach(BattleLeftInfos,function(_,v) 
            if v.num ~= 0 then
                num = num + v.num
            end
        end)     
        local enabledColor =  ChangeColor(index)
        BattleUI.Info[index].label.text= String.Format( TextMgr:GetText(BMInfoStringIDs[index]),
        (enabledColor and math.floor(num)>=BMCalResult.HadHeroResult[index].final) and BMInfoStrColor[2] or BMInfoStrColor[4],
          math.floor(num),
        (enabledColor) and BMInfoStrColor[2] or BMInfoStrColor[4],
          BMCalResult.HadHeroResult[index].final)
        local bones = ((BMCalResult.HadHeroResult[index].normal - BMCalResult.IgnoreHeroResult[index].normal) / BMCalResult.HadHeroResult[index].normal)*100
        BattleUI.Info[index].bones_label.text = (bones==0 and BMInfoStrColor[4] or BMInfoStrColor[3])..string.format("%.1f%%", bones)..BMInfoStrColor[4]
		
		--国内和国外版本这里都不显示带兵量加成 ysy , yy , wsm (2018.10.10)
        BattleUI.Info[index].jiantou.gameObject:SetActive(false)
        --BattleUI.Info[index].jiantou.gameObject:SetActive(bones~=0)
    end
    if index == BMInfoType.T_Weight then
        local tileMsg = GetInterface("TileInfo").GetTileMsg()
        local resourceLeftCount = 0
        
        if tileMsg ~= nil then
            local tileData = WorldMap.GetTileData(tileMsg)   
            local entryType = tileMsg.data.entryType  
            if entryType == Common_pb.SceneEntryType_GuildBuild then
                local buildingMsg = tileMsg.guildbuild
                resourceLeftCount = math.max(buildingMsg.totalRemaining - buildingMsg.totalSpeed * (GameTime.GetSecTime() - buildingMsg.nowTime), 0)
            else
                local resMsg = tileMsg.res
                local capacity = tileData.capacity
                resourceLeftCount = capacity - resMsg.num 
            end         
        end
        local enabledColor =  ChangeColor(index)
        BattleUI.Info[index].label.text= String.Format( TextMgr:GetText(BMInfoStringIDs[index]),
        (enabledColor and BMCalResult.HadHeroResult[index].final>=resourceLeftCount) and BMInfoStrColor[2] or BMInfoStrColor[4],
        string.format("%d",BMCalResult.HadHeroResult[index].final),resourceLeftCount)
        if BMCalResult.HadHeroResult[index].final == 0 then
            BattleUI.Info[index].bones_label.text = "0%"
            BattleUI.Info[index].jiantou.gameObject:SetActive(false)
        else
            local bones = (BMCalResult.HadHeroResult[index].final - BMCalResult.IgnoreHeroResult[index].final) * 100 / BMCalResult.HadHeroResult[index].final
            BattleUI.Info[index].bones_label.text = (bones==0 and BMInfoStrColor[4] or BMInfoStrColor[3])..string.format("%.1f%%", bones)..BMInfoStrColor[4]
            BattleUI.Info[index].jiantou.gameObject:SetActive(bones~=0)
        end
        
    end
    if index == BMInfoType.T_Gather then
        local tileMsg = GetInterface("TileInfo").GetTileMsg()
        local resourceLeftCount = 0
        if tileMsg ~= nil then
            local tileData = WorldMap.GetTileData(tileMsg)        
            local entryType = tileMsg.data.entryType  
            if entryType == Common_pb.SceneEntryType_GuildBuild then
                local buildingMsg = tileMsg.guildbuild
                resourceLeftCount = math.max(buildingMsg.totalRemaining - buildingMsg.totalSpeed * (GameTime.GetSecTime() - buildingMsg.nowTime), 0)
            else
                local resMsg = tileMsg.res
                local capacity = tileData.capacity
                resourceLeftCount = capacity - resMsg.num 
            end        
        end
        local t = 0
        local it = 0
        if resourceLeftCount > 0 then
            if BMCalResult.IgnoreHeroResult[index].final ~= 0 then
                it = math.min(BMCalResult.HadHeroResult[BMInfoType.T_Weight].final,resourceLeftCount)  /BMCalResult.IgnoreHeroResult[index].final
            end
            if BMCalResult.HadHeroResult[index].final ~= 0 then
                t = math.min(BMCalResult.HadHeroResult[BMInfoType.T_Weight].final,resourceLeftCount)/BMCalResult.HadHeroResult[index].final
            end
        end
        BattleUI.Info[index].label.text= String.Format( TextMgr:GetText(BMInfoStringIDs[index]),Serclimax.GameTime.SecondToString3(t))
        if t == 0 then
            BattleUI.Info[index].bones_label.text ="0%"
            BattleUI.Info[index].jiantou.gameObject:SetActive(false)
        else        
            local bones = (((t - it) / it)*100)
            BattleUI.Info[index].bones_label.text = (bones==0 and BMInfoStrColor[4] or BMInfoStrColor[3])..string.format("%.1f%%", bones)..BMInfoStrColor[4] 
            BattleUI.Info[index].jiantou.gameObject:SetActive(bones~=0)
        end      
    end
    if index == BMInfoType.T_MoveTime then
        local enabledColor =  ChangeColor(index)
        BattleUI.Info[index].label.text= String.Format( TextMgr:GetText(BMInfoStringIDs[index]),
        (enabledColor) and BMInfoStrColor[2] or BMInfoStrColor[4],
        Serclimax.GameTime.SecondToString3(math.floor(BMCalResult.HadHeroResult[index].final)))
        if BMCalResult.HadHeroResult[index].final == 0 then
            BattleUI.Info[index].bones_label.text = "0%"
            BattleUI.Info[index].jiantou.gameObject:SetActive(false)
        else        
            local bones = (((BMCalResult.HadHeroResult[index].final - BMCalResult.IgnoreHeroResult[index].final) / BMCalResult.IgnoreHeroResult[index].final)*100)
            BattleUI.Info[index].bones_label.text = (bones==0 and BMInfoStrColor[4] or BMInfoStrColor[3])..string.format("%.1f%%", bones)..BMInfoStrColor[4]
            BattleUI.Info[index].jiantou.gameObject:SetActive(bones~=0)
        end
    end
    if index == BMInfoType.T_OccupyTime then
        
        BattleUI.Info[index].label.text= String.Format( TextMgr:GetText(BMInfoStringIDs[index]),Serclimax.GameTime.SecondToString3(math.floor(BMCalResult.HadHeroResult[index].final)))
        if BMCalResult.HadHeroResult[index].final == 0 then
            BattleUI.Info[index].bones_label.text = "0%"
            BattleUI.Info[index].jiantou.gameObject:SetActive(false)
        else
            local bones = (((BMCalResult.HadHeroResult[index].final - BMCalResult.IgnoreHeroResult[index].final) / BMCalResult.IgnoreHeroResult[index].final)*100)
            BattleUI.Info[index].bones_label.text = (bones==0 and BMInfoStrColor[4] or BMInfoStrColor[3])..string.format("%.1f%%", bones)..BMInfoStrColor[4]         
            BattleUI.Info[index].jiantou.gameObject:SetActive(bones~=0)
        end
    end        
end

local function GetBMInfos()
    local bmi = BMPathShowInfoTypes[pathType]
    if bmi == nil then
        bmi = BMPathShowInfoTypes[Common_pb.TeamMoveType_AttackMonster]
    end
    return bmi
end

local function LoadBMInfo()
    BattleUI.Info = {}
    local root = transform:Find("Container/bg_frane/bg_info")
    BattleUI.Info[BMInfoType.T_MaxSoldier] = LoadBMInfoItem(root:Find("soldier"))
    BattleUI.Info[BMInfoType.T_Weight] = LoadBMInfoItem(root:Find("weight"))
    BattleUI.Info[BMInfoType.T_Gather] = LoadBMInfoItem(root:Find("collect_time"))
    BattleUI.Info[BMInfoType.T_MoveTime] = LoadBMInfoItem(root:Find("move_time"))
    BattleUI.Info[BMInfoType.T_OccupyTime] = LoadBMInfoItem(root:Find("occupy_time"))
    for i=1,#BMCalculationFunc do
        BattleUI.Info[i].label.gameObject:SetActive(false)
        SetClickCallback(BattleUI.Info[i].tips.gameObject,function(go)
            if go == BattleUI.tipObject then
                BattleUI.tipObject = nil
            else
                BattleUI.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(BMInfoTips[i].title), text = TextMgr:GetText(BMInfoTips[i].tips)}) 
            end
        end)
    end
    table.foreach(GetBMInfos(),function(i,v)
		

            
        BattleUI.Info[v].label.gameObject:SetActive(true)
	
		--国内和国外版本这里都不显示带兵量加成 ysy , yy , wsm (2018.10.10)
		BattleUI.Info[BMInfoType.T_MaxSoldier].bones_labelTrf.gameObject:SetActive(false)
		BattleUI.Info[BMInfoType.T_MaxSoldier].jiantou.gameObject:SetActive(false)
    end) 
	
	local soldierDetail = transform:Find("Container/bg_frane/bg_info/soldie_view")
	soldierDetail.gameObject:SetActive(false)
	SetClickCallback(soldierDetail.gameObject,function(go)
		ShowSoldierDetail()
	end)

end

local function RefreshBMInfo()
    table.foreach(GetBMInfos(),function(i,v)
        RefreshBMInfoType(v)
    end) 
end

function GetSelectHero()
    return SelectHero;
end

function RecordTime(log,isp)
    --[[
    if BattleUI == nil then
        return
    end    
	--local info = debug.getinfo(2,"S")
    local t = (os.clock() - timecost)*1000
    if t>=2 then
       --print(log,t,info.source,info.linedefined)
    end
    print(log, t)
    timecost = os.clock()
    --]]
end

function GetBattleLeftInfos()
    return BattleLeftInfos
end

local function CloseClickCallback(go)
    Hide()
end

local function roundOff(num, n)
    if n > 0 then
       local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
     elseif n == 0 then
         return num
     end
end

calWeight = function(base_weight, bonusArmyType, soldier_id)
    local params = {}
    params.base = base_weight
    if soldier_id ~= nil then
        params.soldier_att_id = Global.GetAttributeLongID(soldier_id, 21)
    end
    params.bonus_army_id = Global.GetAttributeLongID(bonusArmyType, 21)
    params.all_soldier_att_id = Global.GetAttributeLongID(10000, 21)
    return AttributeBonus.CallBonusFunc(2, params)
end

local function calOccupy()
    
end

function calMaxSoilderNum(base)
    local params = {}
    params.base = base

    --[[


    print("params.base:",base,
    "GV(1063):",AttributeBonus.GetValueSGL(1063),
    "GV(1024):",AttributeBonus.GetValueSGL(1024),
    "GV(1102):",AttributeBonus.GetValueSGL(1102),
    "GV(1086):",AttributeBonus.GetValueSGL(1086),
    "((params.base+GV(1063))*(1+GV(1024)*0.01)+GV(1102))*(1+GV(1086)*0.01)",
    ((params.base+AttributeBonus.GetValueSGL(1063))*(1+AttributeBonus.GetValueSGL(1024)*0.01)+AttributeBonus.GetValueSGL(1102))*(1+AttributeBonus.GetValueSGL(1086)*0.01)
    )
    --]]

    return AttributeBonus.CallBonusFunc(30,params)
end

local function AddFightLabel(index)
	local label = ""
	if index == 1 then
		label = TextMgr:GetText("ui_worldmap_84")
	elseif index == 2 then
		label = TextMgr:GetText("ui_worldmap_85")
	elseif index == 3 then
		label = TextMgr:GetText("ui_worldmap_86")
	elseif index == 4 then
		label = TextMgr:GetText("ui_worldmap_87")
	end
	
	return label
end

local function LoadHeroAddFight()
	while BattleUI.heroAddGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(BattleUI.heroAddGrid.transform:GetChild(0).gameObject)
	end
	if pathType == Common_pb.TeamMoveType_ResTake or pathType == Common_pb.TeamMoveType_MineTake then
		for i=1 , 4 , 1 do
			local item = NGUITools.AddChild(BattleUI.heroAddGrid.gameObject ,BattleUI.heroAddGridItem.gameObject)
			item.transform:SetParent(BattleUI.heroAddGrid.transform , false)
			local fight , label = AddFightLabel(i)
			--item.transform:Find("num"):GetComponent("UILabel").text = fight
			item.transform:GetComponent("UILabel").text = AddFightLabel(i)
			BattleUI.heroAdd[i] = item.transform:Find("num"):GetComponent("UILabel")
		end
	else
		for i=1 , 2 , 1 do
			local item = NGUITools.AddChild(BattleUI.heroAddGrid.gameObject ,BattleUI.heroAddGridItem.gameObject)
			item.transform:SetParent(BattleUI.heroAddGrid.transform , false)
			local fight , label = AddFightLabel(i)
			--item.transform:Find("num"):GetComponent("UILabel").text = fight
			item.transform:GetComponent("UILabel").text = AddFightLabel(i)
			BattleUI.heroAdd[i] = item.transform:Find("num"):GetComponent("UILabel")
		end
	end
	BattleUI.heroAddGrid:Reposition()
end

local function RefrushTotalWeight()
    --print(pathType)
    if pathType ==  Common_pb.TeamMoveType_Occupy then
        local num = 0
        table.foreach(BattleLeftInfos,function(_,v) 
            if v.num ~= 0 then
                num = num + v.num*v.fight_point
            end
        end)   
        local min_time = tonumber( TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyMinTime).value)
        local max_time = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyMaxTime).value)
        local enmey_factor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyEnemyTimeFactor).value)

        local factor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OccupyTimeFactor).value)

        if not WorldBorderData.IsEnemyBorder(curPx, curPy) then
            enmey_factor = 1
        end

        local base_time = math.max(min_time,max_time -num/factor )
        --print(min_time,max_time,num,factor,num/factor,base_time,enmey_factor)
        local bonus = AttributeBonus.GetBonusInfos()
        local time = base_time * enmey_factor / (1 + (bonus[1094] ~= nil and bonus[1094] or 0) * 0.01)
					/( 1 + (bonus[1098] ~= nil and bonus[1098] or 0) * 0.01)
        
        --print(TextMgr:GetText("occupy_ui2"),Serclimax.GameTime.SecondToString3(math.floor(time)))
        BattleUI.bg_left.info_right_txt.text = String.Format(TextMgr:GetText("occupy_ui2"),Serclimax.GameTime.SecondToString3(math.floor(time)))
    else
        local num = 0
		local numMbs = 0
        table.foreach(BattleLeftInfos,function(_,v) 
            if v.num ~= 0 then
                num = num + calWeight(v.num*v.base_weight,v.type_id)
				numMbs = numMbs + (v.num*v.base_weight)
            end
        end)  
		--num = math.floor(num)
		--print(String.Format(TextMgr:GetText("battlemove_ui4"),math.floor(num)))
        BattleUI.bg_left.info_right_txt.text = String.Format(TextMgr:GetText("battlemove_ui4"),math.floor(num))
		
		local numbase = 0
		if BattleUI.heroAdd[4] ~= nil then
			numbase = heroAdd[4]
			if numbase == 0 then
				BattleUI.heroAdd[4].text = 0 .."%"
			else
				local resV = 0
				if numMbs ~= 0 then
					resV = math.ceil(((num - numbase)/numMbs)*100)
                end
                --print(string.format("+%.1f%%", resV))
				BattleUI.heroAdd[4].text = string.format("+%.1f%%", resV)
			end
		end
		
		local colRes = 0
		if pathType == Common_pb.TeamMoveType_ResTake or pathType == Common_pb.TeamMoveType_MineTake then
			if BattleUI.heroAdd[3] ~= nil then
				local tile = GetInterface("TileInfo").GetTileMsg()
				if tile == nil then
					return
				end
				local tileData = WorldMap.GetTileData(tile)
				
				
				if pathType == Common_pb.TeamMoveType_ResTake then
					colRes = ResView.GetAddGeneratSpeedByType(tileData.type)
				elseif pathType == Common_pb.TeamMoveType_MineTake then
					colRes = ResView.GetAddGeneratSpeedByType(tileData.resourceType)
				end
				
				--print(colRes , heroAdd[3] , colRes - heroAdd[3] , pathType)
				BattleUI.heroAdd[3].text = (colRes - heroAdd[3])*100 .. "%"
			end
		end
    end
end

function RefrushTotalSoliderNum()
    --[[
    local num = 0
    table.foreach(BattleLeftInfos,function(_,v) 
        if v.num ~= 0 then
            num = num + v.num
        end
    end) 
    BattleUI.bg_left.info_left_txt.text = String.Format(TextMgr:GetText("battlemove_ui3"),math.floor(num),MaxSoilderNumber)
    ]]
    RefrushFight()
    local _num = 0
    table.foreach(BattleLeftInfos,function(_,v) 
        if v.num ~= 0 then
            _num = _num + v.num
        end
    end) 
    if _num > MaxSoilderNumber then
        local num = 0
        local done = false
        for i=4,1,-1 do
            if done then
                break
            end
            for j = 1004,1001,-1 do
                local info = BattleLeftSortInfos[i*100+j]
                if info ~= nil then
                    num = info.num
                    SetLeftInfo(info.unitId,info.num)
                    if num ~= info.num then
                        done = true
                        break
                    end
                end
            end
            RefrushFight()
        end
    end
end

GetMoveCost = function(basespeed,type_id)
    local params = {}
    params.base = basespeed
    if type_id ==  Common_pb.TeamMoveType_ResTake then --资源采集
        return AttributeBonus.CallBonusFunc(32,params)
	elseif type_id ==  Common_pb.TeamMoveType_MineTake then --超级矿采集
        return AttributeBonus.CallBonusFunc(33,params)
    elseif type_id ==  Common_pb.TeamMoveType_GuildBuildCreate then
        return AttributeBonus.CallBonusFunc(33,params)
	elseif type_id ==  Common_pb.TeamMoveType_TrainField  then --训练场
        return AttributeBonus.CallBonusFunc(34,params)
    elseif type_id ==  Common_pb.TeamMoveType_Garrison  then -- 驻防 
        return AttributeBonus.CallBonusFunc(35,params)        
    elseif type_id ==  Common_pb.TeamMoveType_GatherCall  then -- 发起集结
        if Global.GetMobaMode() == 2 then
            return AttributeBonus.CallBonusFunc(60,params)
        else
            return AttributeBonus.CallBonusFunc(56,params)
        end
	elseif type_id ==  Common_pb.TeamMoveType_GatherRespond  then -- 响应集结
        if Global.GetMobaMode() == 2 then
            return AttributeBonus.CallBonusFunc(61,params)
        else
            return AttributeBonus.CallBonusFunc(57,params)
        end 
    elseif type_id ==  Common_pb.TeamMoveType_AttackMonster  then --攻击怪
        return AttributeBonus.CallBonusFunc(52,params)	
	elseif type_id ==  Common_pb.TeamMoveType_AttackPlayer  then --攻击玩家	
        if Global.GetMobaMode() == 2 then
            return AttributeBonus.CallBonusFunc(58,params)
        else
            return AttributeBonus.CallBonusFunc(53,params)
        end        
	elseif type_id ==  Common_pb.TeamMoveType_ReconPlayer  then --侦查玩家	
        if Global.GetMobaMode() == 2 then
            return AttributeBonus.CallBonusFunc(59,params)
        else
            return AttributeBonus.CallBonusFunc(55,params)
        end     
	elseif type_id ==  Common_pb.TeamMoveType_ReconMonster  then --侦查怪
        return AttributeBonus.CallBonusFunc(54,params)	
	elseif type_id ==  Common_pb.TeamMoveType_Camp  then	 --扎营
        return AttributeBonus.CallBonusFunc(42,params)	
	elseif type_id ==  Common_pb.TeamMoveType_Occupy  then --占领
        return AttributeBonus.CallBonusFunc(43,params)	
	elseif type_id ==  Common_pb.TeamMoveType_ResTransport  then --资源运        
        return AttributeBonus.CallBonusFunc(44,params)  
    elseif type_id ==  Common_pb.TeamMoveType_GarrisonCenterBuild  then --中央建筑物  
        return AttributeBonus.CallBonusFunc(35,params)          
    elseif type_id ==  Common_pb.TeamMoveType_AttackCenterBuild  then 
        return AttributeBonus.CallBonusFunc(35,params)     
    elseif type_id ==  Common_pb.TeamMoveType_MobaAtkBuild  then -- 攻击中立建筑物  
        return AttributeBonus.CallBonusFunc(35,params)          
    elseif type_id ==  Common_pb.TeamMoveType_MobaGarrisonBuild  then -- 驻防中立建筑物 
        return AttributeBonus.CallBonusFunc(35,params)               
    else   
        return basespeed
    end
end

local function RefrushMoveTime()
    local t = 0
    table.foreach(BattleLeftInfos,function(i,v) 
        if v.num ~= 0 then
            if t <= 0 then
                t = v.speed
            else
                if v.speed < t then
                 t = v.speed            
                end
            end
        end
    end)   
    if t <= 0 then
        BattleUI.Time.text = Serclimax.GameTime.SecondToString3(0)
		BattleUI.heroAdd[2].text = 0
    else
		
        local mypos = GetInterface("MainData").GetPos()--MapInfoData.GetData().mypos
        local factor = 1
        if WorldMap.IsInRestrictArea(mypos.x,mypos.y) or WorldMap.IsInRestrictArea(curPx,curPy) then
            factor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RestrictAreaSpeedFactor).value)
        end
        
        local _time = Dis / GetMoveCost(t,pathType)
		local mbs = Dis / t
		
        _time  =_time* factor
        --print(time,Dis,t)
        BattleUI.Time.text = Serclimax.GameTime.SecondToString3(_time)
		local timebase = 0
		if BattleUI.heroAdd[2] ~= nil then
			timebase = heroAdd[2]
			local addv = 0
			if _time ~= 0 or timebase ~= 0 then
				addv = (mbs*(1/_time - 1/timebase)) * 100
			end
			BattleUI.heroAdd[2].text = string.format("+%.1f%%", addv / tableData_tGlobal.data[100110].value)
			
			
			--[[local intAddv = math.floor(addv)
			if addv - intAddv > 0.5 then
				addv = math.ceil(addv)
			else
				addv = math.floor(addv)
			end
			
			BattleUI.heroAdd[2].text = addv .. "%" -- 四舍五入]]
		end
    end
end

local function checkNumLimit(soldier_UnitID,num)
    if BattleLeftInfos[soldier_UnitID] == nil then
        return 0
    end
    
    local tnum = 0
    table.foreach(BattleLeftInfos,function(i,v) 
        if v.num ~= 0 and i ~= soldier_UnitID then
            tnum = tnum + v.num
        end
    end)

    if MaxSoilderNumber <= tnum then
        return 0
    end
    
    if MaxSoilderNumber - num >= tnum then
        return num
    end
    
    return MaxSoilderNumber - tnum
end    


function CheckNeedSaveArchive()
    if CurSelectArchive == nil then
        return
    end

    local selectHeroData = GetInterface("SelectHero_PVP") .GetSelectHeroData( nil)

    local needsave = selectHeroData:GetSelectedHeroCount() ~= #CurSelectArchive.generals

    if not needsave then
        for i, uid in ipairs(CurSelectArchive.generals) do
            if not selectHeroData:IsHeroSelectedByUid(uid) then
                needsave = true
                break
            end
        end
    end

    if not needsave then
        for id, num in pairs(CurSelectArchive.armys) do
            local army = BattleLeftInfos[id]
            if num ~= (army and army.num or 0) then
                needsave = true
                break
            end
        end
    end

    if not needsave then
        for id, army in pairs(BattleLeftInfos) do
            if army.num ~= (CurSelectArchive.armys[id] or 0) then
                needsave = true
                break
            end
        end
    end

    NeedSaveArchive = needsave

    if needsave then       
        BattleUI.bg_left.save_sprite.spriteName = "btn_2small"
    else
        BattleUI.bg_left.save_sprite.spriteName = "btn_hui"
    end
end

local function AddLeftInfo(perfab,soldier_data)
    local t = 0    
    
    if soldier_data.Num == 0 then
        return false
    end
    t = soldier_data.Num



    if t <= 0 then
        return false
    end
    if BattleLeftInfos[soldier_data.UnitID] == nil then
        BattleLeftInfos[soldier_data.UnitID] = {}
    end
    local info = BattleLeftInfos[soldier_data.UnitID]
    info.autoRefrush = false
    info.obj = NGUITools.AddChild(BattleUI.bg_left.armys_grid.gameObject,BattleUI.BattleMoveLeftInfo)
    info.obj.name = (5 - soldier_data.Grade)*100 + (1005 - soldier_data.SoldierId)
    info.name_txt = info.obj.transform:Find("bg_list/bg_title/text_name"):GetComponent("UILabel")
    info.name_txt.text = TextMgr:GetText(soldier_data.SoldierName) --.."  LV."..soldier_data.Grade
    info.icon_tex = info.obj.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
    info.icon_tex.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soldier_data.SoldierIcon)
    info.total_num_txt = info.obj.transform:Find("bg_list/num"):GetComponent("UILabel")
    info.total_num_txt.text = t
    info.input_num_gobj = info.obj.transform:Find("bg_list/bg_food").gameObject
    info.input_num_txt = info.obj.transform:Find("bg_list/bg_food/txt_food"):GetComponent("UILabel")

    info.num = 0
    
    info.fight_point = soldier_data.fight
    info.total_num = t
    info.base_weight = soldier_data.Weight*soldier_data.TeamCount
    info.type_id = soldier_data.SoldierId
    info.bonusArmyType = soldier_data.barrackAdd
    info.unitId = soldier_data.UnitID
    info.level = soldier_data.Grade
    info.speed = soldier_data.Speed
    info.first = true
    info.bg_schedule = info.obj.transform:Find("bg_list/bg_schedule")
    info.bg_schedule_climb = info.obj.transform:Find("bg_list/bg_schedule_climb")    

    info.bg_schedule.gameObject:SetActive(true)
    info.bg_schedule_climb.gameObject:SetActive(false)
    info.slider = info.obj.transform:Find("bg_list/bg_schedule/bg_slider"):GetComponent("UISlider")
    SetClickCallback(info.input_num_gobj , function()
        NumberInput.Show(math.floor(info.num), 0, info.total_num, function(number)
            info.autoRefrush = true
            local n = checkNumLimit(soldier_data.UnitID,number)
            info.num = n
            info.slider.value = n/info.total_num
        end)
    end)        



    EventDelegate.Set(info.slider.onChange,EventDelegate.Callback(function()
        local tn = roundOff( info.total_num * info.slider.value,1)
        local n = checkNumLimit(soldier_data.UnitID,tn)
        if tn ~= n then
            info.slider.gameObject:SetActive(false)
            info.slider.value = n/info.total_num
            info.slider.gameObject:SetActive(true)
        end
        info.num = n
        info.input_num_txt.text = info.num
        if info.autoRefrush then
            if not info.first then
                RefrushTotalSoliderNum()
            end
            if info.first then
                info.first = false
            end
            CheckNeedSaveArchive()
        else
            info.autoRefrush = true
        end
    end))
    BattleLeftSortInfos[soldier_data.Grade*100+soldier_data.SoldierId] = info
    return true
end

SetLeftInfo = function(soldier_UnitID, num)
    if BattleLeftInfos[soldier_UnitID] == nil then
        return 0
    end

    local info = BattleLeftInfos[soldier_UnitID]
    local n = checkNumLimit(soldier_UnitID, num)
    info.num = math.min(n, info.total_num)
    info.slider.value = n / info.total_num

    return info.num
end

local function ArmySetoutSchemeInfo2Armys(ArmySetoutSchemeInfo)
    local armys = {}
    for i=1,#ArmySetoutSchemeInfo.army do
        local soldier_data = GetInterface("BarrackData").GetAramInfo(ArmySetoutSchemeInfo.army[i].armyId,ArmySetoutSchemeInfo.army[i].armyLevel)
        local new_soldier_data = {}
        new_soldier_data.Grade = soldier_data.Grade
        new_soldier_data.SoldierId= soldier_data.SoldierId
        new_soldier_data.UnitID= soldier_data.UnitID
        new_soldier_data.Speed= soldier_data.Speed
        new_soldier_data.TeamCount= soldier_data.TeamCount
        new_soldier_data.Weight= soldier_data.Weight
        new_soldier_data.fight= soldier_data.fight
        new_soldier_data.SoldierIcon= soldier_data.SoldierIcon
        new_soldier_data.SoldierName= soldier_data.SoldierName
        new_soldier_data.TotalNum = ArmySetoutSchemeInfo.army[i].num
        new_soldier_data.Num= math.max(0,  ArmySetoutSchemeInfo.army[i].num - ArmySetoutSchemeInfo.army[i].deadNum -ArmySetoutSchemeInfo.army[i].injuredNum)
        table.insert(armys,new_soldier_data)
    end
    return armys
end

local function RefrushLeftInfo(ArmySetoutSchemeInfo)
    BattleLeftSortInfos = nil
    if BattleLeftInfos ~= nil then
        table.foreach(BattleLeftInfos,function(_,v) 
            v.obj:SetActive(false)
            v.obj.transform.parent = nil
            GameObject.Destroy(v.obj)
        end)  
    end 
    BattleLeftInfos = {}
    BattleLeftSortInfos = {}

    local armys = GetInterface("BarrackData").GetArmy()

    local count = 0
    table.foreach(armys,function(_,v)
        if AddLeftInfo(BattleUI.BattleMoveLeftInfo,v,false) then
            count = count + 1
        end
    end)
    
    if count ~= 0 then
        BattleUI.bg_left.armys_grid:Reposition()
        BattleUI.bg_left.armys_scrollview:SetDragAmount(0, 0, false) 
        BattleUI.bg_left.noitem_gobj:SetActive(false)
    else
        BattleUI.bg_left.noitem_gobj:SetActive(true)
    end
end

local function ClearLeftInfo()
    table.foreach(BattleLeftInfos, function(id, v)
        v.autoRefrush = false
        SetLeftInfo(id, 0)
    end)
end

local function LoadArchive(archive)
    if BattleLeftInfos == nil then
        return
    end

    -- 清空将军、出征士兵
    ClearLeftInfo()
    GetInterface("SelectHero_PVP").ClearSelectedGenerals()

    -- 读取储存的将军
    GetInterface("SelectHero_PVP").LoadArchive(archive)
    SelectHero:LoadSelectList()

    -- 刷新带兵上限
    AttributeBonus.AddCollectBounsInfo("MobaBattleMove")
    BMCalculationFunc[1]()

    -- 读取储存的出征士兵
    if archive and archive.armys then
        table.foreach(archive.armys, function(id,v)
            if BattleLeftInfos[id] ~= nil then
                BattleLeftInfos[id].autoRefrush = false
                SetLeftInfo(id, v)
            end
        end)
    end
end

function LeftInfoToArchive(index)
    local archive = BMLayoutArchive(index)
    table.foreach(BattleLeftInfos,function(i,v)
        if v.num > 0 then
            SaveArchiveData[i]:AddArmyRecord(v.unitId,v.num)
        end
    end)
    return archive
end

local function SetCurSelectArchive(archive)
    CurSelectArchive = archive
end

local function RefrushUnlockArchives(first)
    if first == nil then
        NeedSaveArchive = false
        BattleUI.bg_left.save_sprite.spriteName = "btn_hui"
        SetClickCallback(BattleUI.bg_left.save_sprite.gameObject,function()
            if not NeedSaveArchive or CurSelectArchive == nil then
                return
            end
            GetInterface("BattleMoveData").SetSaveArchiveData(CurSelectArchive.id, BattleLeftInfos,
            GetInterface("SelectHero_PVP").GetSelectHeroData( nil), function() 
                RefrushUnlockArchives(1)
                BattleUI.bg_left.save_sprite.spriteName = "btn_hui"
            end)
        end)
    end

    for i = 1, 5, 1 do
        if i <= ArmyNumber then
            BattleUI.bg_left.archives[i].locked_gobj:SetActive(false)
			
            local archive = GetInterface("BattleMoveData").GetSaveArchiveData(i)
            if archive ~= nil then
                BattleUI.bg_left.archives[i].btn_sprite.spriteName = "btn_5"
				BattleUI.bg_left.archives[i].insideSpr.spriteName = "battlemove_madeall"
            else
                BattleUI.bg_left.archives[i].btn_sprite.spriteName = "btn_hui"
				BattleUI.bg_left.archives[i].insideSpr.spriteName = "battlemove_made"
            end

            if first == nil then
                SetClickCallback(BattleUI.bg_left.archives[i].btn_sprite.gameObject,function()
                    if CurSelectArchive ~= nil then
                        local previousArchiveButton = BattleUI.bg_left.archives[CurSelectArchive.id]
                        previousArchiveButton.select_sprite:SetActive(false)
                        previousArchiveButton.btn_sprite.spriteName = GetInterface("BattleMoveData").GetSaveArchiveData(CurSelectArchive.id) and "btn_5" or "btn_hui"
						BattleUI.bg_left.archives[i].insideSpr.spriteName = GetInterface("BattleMoveData").GetSaveArchiveData(CurSelectArchive.id) and "battlemove_madeall" or "battlemove_made"
                    end
                   
                    local archive = GetInterface("BattleMoveData").GetSaveArchiveData(i)
                    BattleUI.bg_left.archives[i].select_sprite:SetActive(true)
                    if archive == nil then
                        BattleUI.bg_left.archives[i].btn_sprite.spriteName = "btn_hui"
						BattleUI.bg_left.archives[i].insideSpr.spriteName = "battlemove_made"
                        SetCurSelectArchive(BMLayoutArchive(i))
                        NeedSaveArchive = true
                        BattleUI.bg_left.save_sprite.spriteName = "btn_2small"
                    else
                        NeedSaveArchive = false
                        BattleUI.bg_left.save_sprite.spriteName = "btn_hui"
                        BattleUI.bg_left.archives[i].btn_sprite.spriteName = "btn_5"
						BattleUI.bg_left.archives[i].insideSpr.spriteName = "battlemove_madeall"
                        SetCurSelectArchive(archive)
                        --print(CurSelectArchive:ToString())
                        LoadArchive(CurSelectArchive)   
                        RefrushTotalSoliderNum()
                    end
                end)
            end
        else
            BattleUI.bg_left.archives[i].locked_gobj:SetActive(true)
            BattleUI.bg_left.archives[i].btn_sprite.spriteName = "btn_hui"
			BattleUI.bg_left.archives[i].insideSpr.spriteName = "battlemove_unlock"
        end
    end    
end

local function ClearSelectedSoldiers()
    table.foreach(BattleLeftInfos,function(id,v)
        v.autoRefrush = false
        SetLeftInfo(id,0)
    end)
end


local function EstimateNeededNum(target, min, max, calculate)
    if min == max then
        return min
    end

    local mid = math.floor((min + max) / 2)

    local pivotValue = calculate(mid)
    if pivotValue < target then
        return EstimateNeededNum(target, mid + 1, max, calculate)
    else
        return EstimateNeededNum(target, min, mid, calculate)
    end
end

local function CalculateSoldiersForCollectingResources(leftSoldierNum, leftResourceNum)
     local availableSoldiers = PriorityQueue(4, function(soldierA, soldierB)
        if soldierA.info.base_weight ~= soldierB.info.base_weight then
            return soldierA.info.base_weight > soldierB.info.base_weight
        end

        if soldierA.info.fight_point ~= soldierB.info.fight_point then
            return soldierA.info.fight_point > soldierB.info.fight_point
        end

        return soldierA.uid > soldierB.uid
    end)

    for level = 4, 1, -1 do
        if leftSoldierNum <= 0 or leftResourceNum <= 0 then
            break
        end

        for id = 1004, 1001, -1 do
            local uid = level * 100 + id
            local soldierInfo = BattleLeftSortInfos[uid]
            if soldierInfo then
                local soldier = {}
                soldier.uid = uid
                soldier.info = soldierInfo
                soldier.num = soldierInfo.total_num

                availableSoldiers:Push(soldier)
            end
        end

        while leftSoldierNum > 0 and leftResourceNum > 0 and not availableSoldiers:IsEmpty() do        
            local soldier = availableSoldiers:Pop()
            local neededNum = math.min(soldier.num, leftSoldierNum)

            if (calWeight(neededNum * soldier.info.base_weight, soldier.info.bonusArmyType) > leftResourceNum) then
                neededNum = EstimateNeededNum(leftResourceNum, 0, math.ceil(leftResourceNum / soldier.info.base_weight), function(num)
                    return calWeight(num * soldier.info.base_weight, soldier.info.bonusArmyType)
                end)
            end

            local actual = SetLeftInfo(soldier.info.unitId, neededNum)

            leftSoldierNum = leftSoldierNum - actual
            leftResourceNum = leftResourceNum - calWeight(actual * soldier.info.base_weight, soldier.info.bonusArmyType)
        end
    end
end

local function QuickSelectCallBack()
    local num = 0
    local total_num = 0;
    table.foreach(BattleLeftInfos,function(_,v) 
        if v.num ~= 0 then
            num = num + v.num
        end
        if v.total_num ~= 0 then
            total_num = total_num + v.total_num
        end
    end)   
    local res_type = pathType == Common_pb.TeamMoveType_ResTake or pathType == Common_pb.TeamMoveType_MineTake
    local clear = num >= total_num  or num >= MaxSoilderNumber
    if res_type then
        clear = QuickTime % 2 ~= 0
    end

    if clear then
        ClearSelectedSoldiers()
    else

        ClearSelectedSoldiers()

    --if QuickTime % 2 == 0 then
        if pathType == Common_pb.TeamMoveType_ResTake then
            local tile = GetInterface("TileInfo").GetTileMsg()
            if tile ~= nil then
                CalculateSoldiersForCollectingResources(MaxSoilderNumber, WorldMap.GetTileData(tile).capacity - tile.res.num)
            end
        elseif pathType == Common_pb.TeamMoveType_MineTake then
            local tile = GetInterface("TileInfo").GetTileMsg()
            if tile ~= nil then
                local mine = GetInterface("TileInfo").GetTileMsg().guildbuild
                CalculateSoldiersForCollectingResources(MaxSoilderNumber, mine.totalRemaining - mine.totalSpeed * (GameTime.GetSecTime() - mine.nowTime))
            end
        else
            local availableSoldiers = PriorityQueue(4, function(soldierA, soldierB)
                if soldierA.num ~= soldierB.num then
                    return soldierA.num < soldierB.num
                end

                if soldierA.info.fight_point ~= soldierB.info.fight_point then
                    return soldierA.info.fight_point > soldierB.info.fight_point
                end

                return soldierA.uid > soldierB.uid
            end)

            local leftNum = MaxSoilderNumber
            for level = 4, 1, -1 do
                if leftNum <= 0 then
                    break
                end

                for id = 1004, 1001, -1 do
                    local uid = level * 100 + id
                    local soldierInfo = BattleLeftSortInfos[uid]
                    if soldierInfo then
                        local soldier = {}
                        soldier.uid = uid
                        soldier.info = soldierInfo
                        soldier.num = soldierInfo.total_num

                        availableSoldiers:Push(soldier)
                    end
                end

                while leftNum > 0 and not availableSoldiers:IsEmpty() do
                    local numAvailableSoldier = availableSoldiers:Count();
                    local soldier = availableSoldiers:Pop()
                    local actual = SetLeftInfo(soldier.info.unitId, math.floor(leftNum / numAvailableSoldier))
                    leftNum = leftNum - actual
                end
            end
        end
    end
    
    RefrushTotalSoliderNum()
    QuickTime = QuickTime + 1
end


local function MoveRequest()
    local suggestedPower = GetInterface("TileInfo").GetSuggestedPower()
    local expediationDuration = BMCalResult.HadHeroResult[BMInfoType.T_MoveTime].final
    MessageBox.ShowConfirmation(suggestedPower and math.ceil(BattleFight) < POWER_SAFE_RATIO * suggestedPower * GetInterface("TileInfo").GetHpPercentage(), TextMgr:GetText("ui_pve_fight_warning2"), function()
        MessageBox.ShowConfirmation(HAS_EXPEDIATION_TIMEOUT[pathType] and expediationDuration >= EXPEDIATION_TIMEOUT, String.Format(TextMgr:GetText("ui_maphint_2"), Global.SecondToTimeLong(expediationDuration)), function()
            local req = GetInterface("ArmySetoutStarRequest")()
            req.seUid = curUid
            req.pos.x = curPx
            req.pos.y = curPy
            if Global.GetMobaMode() == 2 then
            if pathType == Common_pb.TeamMoveType_Garrison or pathType == Common_pb.TeamMoveType_GatherRespond then
                req.userwaring = false
            else
                req.userwaring = userWaring
            end
            end
            
            if MassTime ~= nil then
                req.pathWaittime = MassTime
            end
           
            local heroData = GetInterface("SelectHero_PVP").GetSelectHeroData( nil)    
            for i =1,heroData:GetSelectedHeroCount(),1 do
                req.heroScheme.hero:append(heroData.memHero[i])
            end
            table.foreach(BattleLeftInfos,function(_,v)
                if v.num > 0 then
                   local army = req.armyScheme.army:add()
                   army.armyId = v.type_id
                   army.armyLevel = v.level
                   army.num = v.num
               end
            end)
            if not GetInterface("BattleMoveData").isFormationSame(GetInterface("BattleMoveData").GetServerAttackFormation(),selfFormation) then
                for i =1,6,1 do
                    req.formationOnce.form:append(selfFormation[i])
                end
            end

            req.pathType = pathType
			--req.sweepCount = sweepCount
            LuaNetwork.Request(GetInterface("Category_pb_MoveRequest"),GetInterface("ArmySetoutStarRequestTypeID"), req:SerializeToString(), function(typeId, data)
                local msg = GetInterface("ArmySetoutStarResponse")()
                msg:ParseFromString(data)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.ShowError(msg.code)
                    --出战士兵数量不足 
                    if msg.code == 2407 then
                        if transform ~= nil then
                            LoadUI()
                        end
                    end
                    if pathType == Common_pb.TeamMoveType_GatherCall or pathType == Common_pb.TeamMoveType_GatherRespond then
                    else
                        Hide()
                    end            
                else

                    GetInterface("ArmySetoutData").UpdateData(msg.freshArmyNum)
                    GetInterface("BarrackData").UpdateData(msg.freshArmyNum)
                    --MainCityUI.UpdateRewardData(msg.fresh)
                    if SuccessCallBack ~=nil then
                        SuccessCallBack()
                    end   
                    Hide()

                end
            end, false)
        end)
    end)
end

CalNormalBattleMoveMaxNum = function()
    local maxnum = 0

    --local base_num = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseSoliderNum)
    --maxnum = base_num.value
    --local pd = maincity.GetBuildingByID(4)
    --if pd ~= nil then
    --    local pd_data = TableMgr:GetParadeGroundData(pd.data.level)
     --   maxnum = maxnum + pd_data.addlimit  
    --end
	
	--local curLv = MainData.GetData().commanderLeadLevel
	--local data = TableMgr:GetCommandData(curLv)
	--maxnum = maxnum + --[[base_num.value +]] data.SoldierNum
    --maxnum = calMaxSoilderNum(maxnum)

    maxnum = GetInterface("ArmyMovePlayer")()
    return maxnum
end

function Hide()
    Global.CloseUI(_M)
    GetInterface("ResBar").OnMenuClose("MobaBattleMove")
end

function LoadUI()
    SetClickCallback(transform:Find("Container").gameObject,Hide)
    BattleFightBase = -1
    AttributeBonus.RegisterAttBonusModule(_M)
    QuickTime = 0
    

    if Global.GetMobaMode() == 2 then
        SelectHero = GetInterface("BMSelectHero")(transform:Find("Container/bg_frane/bg_right/bg_general"), pathType, nil, false,false)
    else
        SelectHero = GetInterface("BMSelectHero")(transform:Find("Container/bg_frane/bg_right/bg_general"), pathType, nil, false,false)
    end
    
    SelectHero:Awake()
    
    

    formationSmall = BMFormation(transform:Find("Container/bg_frane/bg_right/bg_formation/Embattle"))

    formationSmall:SetLeftFormation(selfFormation)
    formationSmall:SetRightFormationData(targatFormationData)
    formationSmall:Awake()
    MaxSoilderNumber =  math.floor(GetInterface("CalNormalBattleMoveMaxNum")())
    if FixedMaxSoilderNumber ~= nil then
        MaxSoilderNumber = math.floor(math.min(MaxSoilderNumber, FixedMaxSoilderNumber))
    end
	
    BattleUI = {}
    BattleUI.bg_left = {}

    BattleUI.bg_left.icon_touxiang_tex = transform:Find("Container/bg_frane/bg_left/bg_title/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
    BattleUI.bg_left.icon_touxiang_tex.mainTexture = ResourceLibrary:GetIcon("Icon/head/",MainData.GetFace())

    BattleUI.bg_left.top_duilie =  transform:Find("Container/bg_frane/bg_left/bg_title/text_duilie")
    BattleUI.bg_left.top_grid =  transform:Find("Container/bg_frane/bg_left/bg_title/Grid")
    BattleUI.bg_left.top_save =  transform:Find("Container/bg_frane/bg_left/bg_title/btn_save")
    BattleUI.tab = transform:Find("Container/bg_frane/bg_tab")
    BattleUI.tab1 = transform:Find("Container/bg_frane/bg_tab/btn_group1"):GetComponent("UIToggle")
    BattleUI.tab2 = transform:Find("Container/bg_frane/bg_tab/btn_group2"):GetComponent("UIToggle")
    BattleUI.tab2_btn = BattleUI.tab2.gameObject:GetComponent("UIButton")
    BattleUI.tab3 = transform:Find("Container/bg_frane/bg_tab/btn_group3"):GetComponent("UIToggle")
    BattleUI.tab3_btn = BattleUI.tab3.gameObject:GetComponent("UIButton")
    BattleUI.title =  transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    BattleUI.title.text = TextMgr:GetText("battlemove_ui8")
    BattleUI.tab.gameObject:SetActive(false)
    BattleUI.bg_left.top_duilie.gameObject:SetActive(true)
    BattleUI.bg_left.top_grid.gameObject:SetActive(true)
    BattleUI.bg_left.top_save.gameObject:SetActive(true)

    BattleUI.bg_left.NoCommander = transform:Find("Container/bg_frane/bg_left/bg_title/NoCommander")
    BattleUI.bg_left.HaveCommander = transform:Find("Container/bg_frane/bg_left/bg_title/HaveCommander")
    BattleUI.bg_left.checkbox = transform:Find("Container/bg_frane/bg_left/bg_title/checkbox")
    BattleUI.bg_left.checkbox_gou_gobj = transform:Find("Container/bg_frane/bg_left/bg_title/checkbox/gou").gameObject
    BattleUI.bg_left.checkbox_gou = transform:Find("Container/bg_frane/bg_left/bg_title/checkbox").gameObject
    BattleUI.bg_left.checkbox_text = transform:Find("Container/bg_frane/bg_left/bg_title/checkbox/text"):GetComponent("UILabel")

    BattleUI.bg_left.PowerNum = transform:Find("Container/bg_frane/powerPanel/power/num"):GetComponent("UILabel");

    BattleUI.bg_left.PowerNum.color = Color.white
    BattleUI.bg_left.Animator = transform:Find("Container/bg_frane/powerPanel/power"):GetComponent("Animator");
    BattleUI.prisonObject = transform:Find("Container/bg_frane/bg_left/bg_title/checkbox/injail").gameObject
    BattleUI.chaObject = transform:Find("Container/bg_frane/bg_left/bg_title/checkbox/injail/cha").gameObject


    local Commander_apply = false
    if Global.GetMobaMode() == 2 then
        Commander_apply = true
    end
    BattleUI.bg_left.checkbox.gameObject:SetActive(Commander_apply)
    BattleUI.bg_left.HaveCommander.gameObject:SetActive(false)
    BattleUI.bg_left.NoCommander.gameObject:SetActive(false)
 
	SetClickCallback(BattleUI.chaObject, function(go)
	    FloatText.Show(TextMgr:GetText(Text.jail_27))
    end)

    if userWaring then
        BattleUI.bg_left.checkbox_gou_gobj:SetActive(false);
        BattleUI.bg_left.checkbox_gou:GetComponent("UIToggle").enabled = false;
        BattleUI.bg_left.icon_touxiang_tex.color = Color.black
        userWaring = false
        
        if pathType == Common_pb.TeamMoveType_Garrison then --驻防
            BattleUI.bg_left.checkbox_text.color = NGUIMath.HexToColor(0x8C8C8CFF)
        	SetClickCallback(BattleUI.bg_left.checkbox_gou, function ()
	        	FloatText.Show(TextMgr:GetText("assemble_commander_hint1"), Color.white)
	        end)
        elseif pathType == Common_pb.TeamMoveType_GatherRespond then --集结
            BattleUI.bg_left.checkbox_text.color = NGUIMath.HexToColor(0x8C8C8CFF)
	        SetClickCallback(BattleUI.bg_left.checkbox_gou, function ()
	        	FloatText.Show(TextMgr:GetText("assemble_commander_hint"), Color.white)
	        end)
        else --指挥官不在家            
            BattleUI.bg_left.checkbox_text.color = NGUIMath.HexToColor(0x8C8C8CFF)
	    	SetClickCallback(BattleUI.bg_left.checkbox_gou, function ()
	        	FloatText.Show(TextMgr:GetText("assemble_commander_hint2"), Color.white)
	        end)
	    end
    else
        BattleUI.bg_left.checkbox_text.color = NGUIMath.HexToColor(0xFFFFFFFF)
        BattleUI.bg_left.icon_touxiang_tex.color = Color.white
        BattleUI.bg_left.checkbox_gou_gobj:SetActive(true);
        local toggle = BattleUI.bg_left.checkbox_gou:GetComponent("UIToggle")
        toggle.enabled = true;
        BattleUI.bg_left_first = false
        EventDelegate.Set(toggle.onChange,EventDelegate.Callback(function()
            userWaring = toggle.value
            if BattleUI == nil then
                return
            end
            if not BattleUI.bg_left_first then
                RefrushFight()
            end
            if BattleUI.bg_left_first then
                BattleUI.bg_left_first = false
            end

        end))
    end


    
    BattleUI.bg_left.archives ={}
    for i =1,5,1 do
        BattleUI.bg_left.archives[i] = {}
        BattleUI.bg_left.archives[i].btn_sprite = transform:Find("Container/bg_frane/bg_left/bg_title/Grid/btn ("..i..")"):GetComponent("UISprite")
        BattleUI.bg_left.archives[i].btn_sprite:GetComponent("UIButton").enabled = false
        BattleUI.bg_left.archives[i].locked_gobj = transform:Find("Container/bg_frane/bg_left/bg_title/Grid/btn ("..i..")/icon_locked").gameObject
        BattleUI.bg_left.archives[i].btn_sprite.spriteName = "btn_hui"
		BattleUI.bg_left.archives[i].insideSpr = transform:Find("Container/bg_frane/bg_left/bg_title/Grid/btn ("..i..")/Sprite"):GetComponent("UISprite")
        BattleUI.bg_left.archives[i].select_sprite =transform:Find("Container/bg_frane/bg_left/bg_title/Grid/btn ("..i..")/select").gameObject
        BattleUI.bg_left.archives[i].lable = transform:Find("Container/bg_frane/bg_left/bg_title/Grid/btn ("..i..")/text"):GetComponent("UILabel")
        --BattleUI.bg_left.archives[i].lable.text = i
        BattleUI.bg_left.archives[i].select_sprite:SetActive(false)
        BattleUI.bg_left.archives[i].locked_gobj:SetActive(true)
		BattleUI.bg_left.archives[i].insideSpr.spriteName = "battlemove_unlock"
    end
    BattleUI.bg_left.save_sprite = transform:Find("Container/bg_frane/bg_left/bg_title/btn_save"):GetComponent("UISprite")
    BattleUI.bg_left.save_sprite:GetComponent("UIButton").enabled = false
    BattleUI.bg_left.noitem_gobj = transform:Find("Container/bg_frane/bg_left/bg_noitem").gameObject
    BattleUI.bg_left.info_left_txt = transform:Find("Container/bg_frane/bg_left/bg_info/txt_left"):GetComponent("UILabel")
    BattleUI.bg_left.info_right_txt = transform:Find("Container/bg_frane/bg_left/bg_info/txt_right"):GetComponent("UILabel")
    BattleUI.bg_left.armys_scrollview = transform:Find("Container/bg_frane/bg_left/Scroll View"):GetComponent("UIScrollView")
    BattleUI.bg_left.armys_grid = transform:Find("Container/bg_frane/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    BattleUI.BattleMoveLeftInfo = transform:Find("BattleMoveLeftinfo").gameObject
    BattleUI.Time = transform:Find("Container/bg_frane/time/num"):GetComponent("UILabel")
	BattleUI.soldieView = transform:Find("soldie_view")
	SetClickCallback(BattleUI.soldieView:Find("mask").gameObject,function(go)
		if BattleUI.soldieView.gameObject.activeSelf then
			BattleUI.soldieView.gameObject:SetActive(false)
		end
	end)
	
    LoadBMInfo()
	BattleUI.heroAdd = {}
	BattleUI.heroAddGrid = transform:Find("Container/bg_frane/bg_right/hero_text/Grid"):GetComponent("UIGrid")
	BattleUI.heroAddGridItem = transform:Find("list")
    LoadHeroAddFight()	

    RefrushLeftInfo()

    
    
    -- 加载上次出征配置改为quickSelect（在RefrushTotalSoliderNum之后）
    -- LoadArchive(CurArchive) 
    RefrushUnlockArchives()
    RefrushTotalSoliderNum()
        
    QuickSelectCallBack() -- 自动出兵



    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,CloseClickCallback)
    local quick = transform:Find("Container/bg_frane/btn_upgrade_gold")

        
    quick.gameObject:SetActive(true)

    SetClickCallback(quick.gameObject,QuickSelectCallBack)
    SetClickCallback(transform:Find("Container/bg_frane/bg_right/bg_formation/frame").gameObject,function()

			local tileMsg = GetInterface("TileInfo").GetTileMsg()
			local resourceLeftCount = 0
			local form = nil
			if tileMsg ~= nil then
				local tileData = WorldMap.GetTileData(tileMsg)
				if tileMsg.data.entryType == Common_pb.SceneEntryType_Home and tileMsg.home ~= nil then
					form = ReconSaveData.GetSavedForm(string.format("uid:%s" , tileMsg.home.charid))
				elseif tileMsg.data.entryType == Common_pb.SceneEntryType_MobaGate or 
						tileMsg.data.entryType == Common_pb.SceneEntryType_MobaCenter or
						tileMsg.data.entryType == Common_pb.SceneEntryType_MobaFort or
						tileMsg.data.entryType == Common_pb.SceneEntryType_MobaArsenal or
						tileMsg.data.entryType == Common_pb.SceneEntryType_MobaInstitute or
                        tileMsg.data.entryType == Common_pb.SceneEntryType_MobaTransPlat or
                        tileMsg.data.entryType == Common_pb.SceneEntryType_MobaSmallBuild then
							local offx , offy = GetInterface("Main").MobaMinPos()
							local posx = tileMsg.data.pos.x - offx
							local posy = tileMsg.data.pos.y - offy
							print("get formattion: type->" ,tileMsg.data.entryType , " k->" ,string.format("%s_%s" , posx , posy))
							form = ReconSaveData.GetSavedForm(string.format("pos:%s_%s" , posx , posy))
				end
				
				if tileMsg.monster.level > 0 and tileMsg.monster.formation ~= nil and tileMsg.monster.formation.form ~= nil then
					form = tileMsg.monster.formation.form
				end
				
				if tileMsg.centerBuild ~= nil and tileMsg.centerBuild.monster ~= nil and tileMsg.centerBuild.monster.formation > 0 then
					form = TableMgr:GetFormation(tileMsg.centerBuild.monster.formation)
				end
				
				if tileMsg.elite ~= nil and tileMsg.elite.formation > 0 then
					form = TableMgr:GetFormation(tileMsg.elite.formation)
				end
				
				if tileMsg.mobaBuild ~= nil and tileMsg.mobaBuild.monster ~= nil and tileMsg.mobaBuild.monster.formation > 0 then
					form = TableMgr:GetFormation(tileMsg.mobaBuild.monster.formation)
				end
			end
			
	
			Embattle.Show(1,selfFormation,form--[[formationSmall.rightFormation]],function(new_form)
				selfFormation = new_form
				formationSmall:SetLeftFormation(selfFormation)
				formationSmall:Awake()
			end , "BattleMove",false)
		
    end)
    BattleUI.battle = transform:Find("Container/bg_frane/btn_upgrade")
    BattleUI.battle.gameObject:SetActive(true)
    BattleUI.battle_climb = transform:Find("Container/bg_frane/btn_climb_save")
    BattleUI.battle_climb.gameObject:SetActive(false)
    SetClickCallback(BattleUI.battle.gameObject,function()
    	if hascheckedshield then
    		MoveRequest()
    		return
        end
        --发送聊天
        if pathType == Common_pb.TeamMoveType_GatherCall then
			print("11111" , MainData.GetCharName() .."," ..curCharName)
            local send = {}
            send.curChanel = GetInterface("chanel_Team")
            send.spectext = "d:1"..",".. "d:"..curPx .. "," .. "d:"..curPy
            send.content = GetInterface("Chat_TestSystemJump_01")..","..MainData.GetCharName() .."," ..curCharName
            send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
            send.chatType = 4
            GetInterface("Chat").SendContent(send)         
        end
        if (entryType == Common_pb.SceneEntryType_Fortress or pathType == Common_pb.SceneEntryType_Stronghold) and Common_pb.TeamMoveType_AttackCenterBuild then
            MessageBox.Show(TextMgr:GetText("ui_worldmap_104"), 
            function() CheckShield(pathType, entry, MoveRequest) end,
            function() end, TextMgr:GetText("ui_worldmap_102"),
            TextMgr:GetText("common_hint2"))
        else
            CheckShield(pathType, entry, MoveRequest)
        end
    	
    end)

    --RefrushFight()
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)    
end

function CloseAll()
    Hide()
end

function Awake()
end

function Start()
   --SelectHero:Start() 
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)    
    Tooltip.HideItemTip()
    if BattleUI ~= nil then
        BattleUI.bg_left.checkbox_gou:GetComponent("UIToggle").value = false;
        SetClickCallback(BattleUI.bg_left.checkbox_gou, nil)  
    end
      
    if cancelCallback ~= nil then
        cancelCallback()
    end    
    cancelCallback = nil
    --SelectHero:Close()
    FixedMaxSoilderNumber = nil
    MassTime = nil
    BattleFightBase = -1
    BattleUI = nil
    if BattleLeftInfos ~= nil then
        table.foreach(BattleLeftInfos,function(_,v) 
            v.obj:SetActive(false)
            v.obj.transform.parent = nil
            GameObject.Destroy(v.obj)
        end)  
    end
    BattleLeftInfos = nil
	filtFormation = nil
    selfFormation = nil
    targatFormationData = nil
    SuccessCallBack = nil
    SelectHero = nil
    CurSelectArchive = nil
    NeedSaveArchive = false
end

function SetFixedMaxSoilder(num)
    FixedMaxSoilderNumber = num
end

function SetMassTime(time)
    MassTime = time
end

function CheckHospital(pathType,tileMsg,callback)
    --[[
    if pathType == Common_pb.TeamMoveType_AttackMonster or 
    --pathType == Common_pb.TeamMoveType_ResTake or --资源采集
	--pathType == Common_pb.TeamMoveType_MineTake or --超级矿采集
	--pathType == Common_pb.TeamMoveType_TrainField or --训练场
	pathType == Common_pb.TeamMoveType_Garrison or --驻防
	pathType == Common_pb.TeamMoveType_GatherCall or --发起集结
	pathType == Common_pb.TeamMoveType_GatherRespond or --响应集结
	pathType == Common_pb.TeamMoveType_AttackPlayer or --攻击玩家
	--pathType == Common_pb.TeamMoveType_ReconPlayer or --侦查玩家
	--pathType == Common_pb.TeamMoveType_ReconMonster or --侦查怪
	--pathType == Common_pb.TeamMoveType_Camp or --扎营
	--pathType == Common_pb.TeamMoveType_Occupy or --占领
	--pathType == Common_pb.TeamMoveType_ResTransport or --资源运输
	--pathType == Common_pb.TeamMoveType_GuildBuildCreate or --联盟建筑
	--pathType == Common_pb.TeamMoveType_MonsterSiege	or --怪物攻城
	pathType == Common_pb.TeamMoveType_AttackFort or --攻击要塞
	pathType == Common_pb.TeamMoveType_AttackCenterBuild or --攻击中央建筑
	pathType == Common_pb.TeamMoveType_GarrisonCenterBuild  --驻防中央建筑
	--pathType == Common_pb.TeamMoveType_Nemesis or --宿敌
    --pathType == Common_pb.TeamMoveType_Prisoner --俘 
    then
        if tileMsg.data.entryType == Common_pb.SceneEntryType_Monster or
        tileMsg.data.entryType == Common_pb.SceneEntryType_Home or --玩家基地
        tileMsg.data.entryType == Common_pb.SceneEntryType_Monster or --野怪
        --tileMsg.data.entryType == Common_pb.SceneEntryType_ResFood or --矿
        --tileMsg.data.entryType == Common_pb.SceneEntryType_ResIron or --矿
        --tileMsg.data.entryType == Common_pb.SceneEntryType_ResOil or --矿
        --tileMsg.data.entryType == Common_pb.SceneEntryType_ResElec or --矿
        --tileMsg.data.entryType == Common_pb.SceneEntryType_Barrack or --扎营
        --tileMsg.data.entryType == Common_pb.SceneEntryType_Occupy or --占领
        tileMsg.data.entryType == Common_pb.SceneEntryType_ActMonster or --活动野怪
        --tileMsg.data.entryType == Common_pb.SceneEntryType_GuildBuild or --联盟建筑
        --tileMsg.data.entryType == Common_pb.SceneEntryType_GuildTrainField or --联盟训练场
        tileMsg.data.entryType == Common_pb.SceneEntryType_SiegeMonster or --叛军基地(攻城怪物)
        tileMsg.data.entryType == Common_pb.SceneEntryType_Fort or --要塞
        tileMsg.data.entryType == Common_pb.SceneEntryType_Govt or --政府
        tileMsg.data.entryType == Common_pb.SceneEntryType_Turret or --炮台
        tileMsg.data.entryType == Common_pb.SceneEntryType_EliteMonster or --精英怪
        tileMsg.data.entryType == Common_pb.SceneEntryType_Stronghold or --据点
        tileMsg.data.entryType == Common_pb.SceneEntryType_Fortress  --新要
        then
            if Hospital.IsFull() then
                MessageBox.Show(TextMgr:GetText("ui_worldmap_101"),function()
                    callback(true)
                end,
                function()
                    callback(false)
                end,
                TextMgr:GetText("ui_worldmap_102"),
                TextMgr:GetText("ui_worldmap_103"))
                return
            end
        end
    end
    --]]
    callback(true)
end

function CheckShield(pathType,tileMsg,callback)
    --print("TTTTTTTTTTTTTTTTT",pathType)
    if pathType == Common_pb.TeamMoveType_ResTake or 
    pathType == Common_pb.TeamMoveType_GatherCall or 
    pathType == Common_pb.TeamMoveType_Camp or 
    pathType == Common_pb.TeamMoveType_Occupy or
     pathType == Common_pb.TeamMoveType_AttackPlayer or 
     pathType == Common_pb.TeamMoveType_ReconPlayer or
     pathType == Common_pb.TeamMoveType_AttackCenterBuild or
     pathType == Common_pb.TeamMoveType_GarrisonCenterBuild then
		local tile = GetInterface("TileInfo").GetTileMsg()
		local mapX, mapY = GetInterface("TileInfo").GetPos()
			if tileMsg == nil then
				callback(false)
				return
            end
            if tileMsg.data.entryType == Common_pb.SceneEntryType_Home or 
            tileMsg.data.entryType == Common_pb.SceneEntryType_Barrack or 
            tileMsg.data.entryType == Common_pb.SceneEntryType_Occupy or 
            tileMsg.data.entryType == Common_pb.SceneEntryType_Govt or
            tileMsg.data.entryType == Common_pb.SceneEntryType_Turret  or 
            tileMsg.data.entryType == Common_pb.SceneEntryType_Stronghold or 
            tileMsg.data.entryType == Common_pb.SceneEntryType_Fortress then --or
                --tileMsg.data.entryType == Common_pb.SceneEntryType_EliteMonster
				
				if tileMsg.home.hasShield then
					MessageBox.Show(TextMgr:GetText("shield_warning_2"))
					return
                end
				GetInterface("BuffData").CheckSelfShield(callback) 
			elseif tileMsg.data.entryType >= Common_pb.SceneEntryType_ResFood and tileMsg.data.entryType <= Common_pb.SceneEntryType_ResElec then
				if tileMsg.res.owner ~= 0 then
                    GetInterface("BuffData").CheckSelfShield(callback)                  
				else
					callback(false)
				end
			else
				callback(false)
            end
    elseif pathType == Common_pb.TeamMoveType_Garrison then
        --print("****************",BuffData.HasShield())
		GetInterface("BuffData").CheckSelfShield(callback)
		
    elseif pathType == Common_pb.TeamMoveType_GatherRespond then
        --[[
		WorldMapData.RequestSceneEntryInfoFresh(0, curPx2, curPy2,function(tileMsg)
			if tileMsg == nil then
				callback(false)
				return
			end
			if tileMsg.data.entryType == Common_pb.SceneEntryType_Home or tileMsg.data.entryType == Common_pb.SceneEntryType_Barrack or tileMsg.data.entryType == Common_pb.SceneEntryType_Occupy then
				if tileMsg.home.hasShield then
					MessageBox.Show(TextMgr:GetText("shield_warning_2"))
					return
				end
				MobaBuffData.CheckSelfShield(callback)
			else
				callback(false)
			end
        end)
        --]]
        callback(false)
	else
		callback(false)
	end
end

function RequestShow(pathType)
    local req = GetInterface("GetArmySetoutUIRequest")()
    req.seUid = curUid
    req.pos.x = curPx
    req.pos.y = curPy
    req.pathType = pathType
    Global.Request(GetInterface("Category_pb_RequestShow"), GetInterface("GetArmySetoutUIRequestTypeID"), req, GetInterface("GetArmySetoutUIResponse"), function(msg)
        if msg.code ~= 0 then
            Global.FloatError(msg.code, Color.white)
            return
        end
        entry = msg.entry
        CheckHospital(pathType,msg.entry,function(isOk)
            if not isOk then
                Hide()
                return
            end
        CheckShield(pathType,msg.entry,function(ischecked)
            hascheckedshield = ischecked
            GetInterface("BarrackData").UpdateArmNumEx(msg,msg.freshArmyNum) -- 少了setoutNum 属性
            local form = GetInterface("BattleMoveData").SetUserAttackFormaion(msg.atkArmyForm)
			selfFormation = {}
			GetInterface("BattleMoveData").CloneFormation(selfFormation,form)
			GetInterface("BattleMoveData").SetArchiveData(msg,function(success)
			    Global.OpenUI(_M)
			    if success then
				    local data = GetInterface("BattleMoveData").GetData()
                    userWaring = data.userWaring
				    if pathType == Common_pb.TeamMoveType_Garrison or pathType == Common_pb.TeamMoveType_GatherRespond then
				        userWaring = true
	                end
				    ArmyNumber = data.unlockNum
				    targatFormationData = data.detcInfo
				    LoadUI()
			    else 
			        Hide()
                end						
			end)
        end)
        end)
    end, true)
    Global.DumpAllMessage()
end


function CheckActionList()
    --return false
    ---[[
    if GetInterface("ActionListData").IsFull() then
		MessageBox.Show(TextMgr:GetText("ui_moba_152"))
	  --[[  if MainData.GetVipLevel() < 5 then
            MessageBox.Show(TextMgr:GetText("ui_worldmap_vip4"),function()
                VIP.Show(5)
            end,function()end,TextMgr:GetText("mission_go"),TextMgr:GetText(Text.common_hint2),"btn_free")
        else
            MessageBox.Show(TextMgr:GetText("garrison_ui4"))
        end ]]--
        return false
    else
        return true
    end
    ---]]

end


function Show(moveType, uid, charname, px, py, success, px2, py2, _cancelCallback, type , sweep) -- ,dis,buf,tile
    entryType = type
    timecost = os.clock()
    pathType = moveType
    curUid = uid
    curCharName = charname
    local offset_x,offset_y = GetInterface("Main").MobaMinPos()
    curPx = px - offset_x
    curPy = py - offset_y
    curPx2 = px2
    curPy2 = py2
    cancelCallback = _cancelCallback
    Dis =  GetInterface("Main").GetDistanceToMyBase(curPx, curPy)
    if Dis == nil then
        Dis = 0
    end
	sweepCount = sweep and sweep or 0
    SuccessCallBack = success

    RequestShow(pathType)
    GetInterface("ResBar").OnMenuOpen("MobaBattleMove")
end


function Army2PhalanxType(BarrackId)
    return math.max(0, BarrackId - 20)
end
 
--转换为SLG PVP Player 数据
function ToSPD()
    local player = Serclimax.SLGPVP.ScSLGPlayer()
    player.Formation = {}
    for i =1,6,1 do 
         player.Formation[i] = Army2PhalanxType(selfFormation[i])
    end
   
    local armys = {}
    table.foreach(BattleLeftInfos,function(_,v)
        if v.num > 0 then
            local army = Serclimax.SLGPVP.ScArmy()
            local data = GetInterface("BarrackData").GetAramInfo(v.type_id,v.level)
            army.ID = v.unitId
            army.Count = v.num
            army.Level = v.level
            army.ArmyType = v.type_id
            army.PhalanxType = Army2PhalanxType(data.BarrackId)
            army.HP = data.Hp
            army.Attack = data.Attack
            army.Armor = data.Defend
            army.Penetrate = data.Penetration
            table.insert(armys,army)
        end
    end)
    player.Armys = armys
    print(player:ToLuaString())
end



function CalBlockBuff(bonusList)
    if curPx == nil or curPy ==nil then
        return
    end
    local str = TableMgr:GetGlobalData(169).value
    local types = string.split( str,",")
    for i=1,#types do    
        types[i] = tonumber(types[i])
    end
    local buffids_str = TableMgr:GetBasicSurfaceBuffId(types,curPx,curPy,function(basicSurfaceData)

        local strong_holds = StrongholdData.GetAllStrongholdData()
        if  strong_holds ~= nil then
            table.foreach(strong_holds,function(i,v)
                local sh =  TableMgr:GetStrongholdRuleByID(v.subtype)
                if TableMgr:IsInBasicSurfaceDataRect(basicSurfaceData,sh.Xcoord,sh.Ycoord) then
                    return v.available
                end                
            end)
        end
        local fortresses = FortressData.GetAllFortressData()
        if  fortresses ~= nil then
            table.foreach(fortresses,function(i,v)
                local f =  TableMgr:GetFortressRuleByID(v.subtype)
                if TableMgr:IsInBasicSurfaceDataRect(basicSurfaceData,f.Xcoord,f.Ycoord) then
                    return v.available
                end                       
            end)
        end
        return true
    end)
    if buffids_str == nil or buffids_str == "" then
        return
    end
    local buffids = string.split( buffids_str,";")
    for i=1,#buffids do    
        local buffid = tonumber(buffids[i])
        local buffTableData = TableMgr:GetSlgBuffData(buffid)
        if buffTableData == nil then
            return nil
        end
        local t = string.split(buffTableData.Effect,';')
        for i = 1,#(t) do
            local tt = string.split(t[i],',')
            local bonus = {}
            bonus.Attype = tonumber(tt[3]) 
            bonus.BonusType = tonumber(tt[2])
            bonus.Value = tonumber(tt[4])
            if bonus.BonusType == 0 and bonus.Attype == 0 then
                print(buffTableData.Effect,tt[4])
            end 
            table.insert(bonusList, bonus)       
        end
    end
end


function CalAttributeBonus()
    local bonusList = {}
    local sheroData = GetInterface("SelectHero_PVP").GetSelectHeroData( nil).memHero
    for _, v in ipairs(sheroData) do
        local heroMsg = GetInterface("HeroListData").GetGeneralByUID(v)
        if heroMsg == nil then
            UnityEngine.Debug.LogError("invalid hero id:" .. v)
        else
            for attributeID, value in pairs(GetInterface("HeroListData_GetAttributes")(heroMsg)) do
                local bonus = {}
                local armyType = math.floor(attributeID / 10000)
                bonus.BonusType, bonus.Attype = Global.DecodeAttributeLongID(attributeID)
                if bonus.BonusType == 0 and bonus.Attype == 0 then
                    print(attributeID,value)
                end
                bonus.Value = value
                table.insert(bonusList, bonus)
            end
        end
    end
    CalBlockBuff(bonusList)
    return bonusList
end

function GetBattleFight()
    return BattleFight;
end

RefreshHeroAdd = function()
    local ignore = {"MobaBattleMove"}--, "SelectArmy"}
    if Global.GetMobaMode() == 2 then
        local ignore = {"BattleMove", "TalentInfo", "EquipData", "SelectArmy",
        "MobaBuffData","GeneralData","MobaTechData","MobaBattleMove"}
        AttributeBonus.CollectBonusInfo(ignore)
    else
        AttributeBonus.CollectBonusInfo(ignore,false,"")
    end
    BMCalResult.IgnoreHeroResult = {}
    for i = 1, #BMCalculationFunc do
        BMCalResult.IgnoreHeroResult[i] = BMCalculationFunc[i]()
    end
end



RefrushFight = function()
    --print("----------------------------------------------   RefrushFight")
    BattleFight = 0
    local army = 0
    local hero = 0
	RefreshHeroAdd()

    AttributeBonus.AddCollectBounsInfo("MobaBattleMove")
    if userWaring then
        if Global.GetMobaMode() == 2 then
            AttributeBonus.AddCollectBounsInfo({"TalentInfo", "EquipData"})
        end
    	--AttributeBonus.CollectBonusInfo()
    end

    table.foreach(BattleLeftInfos,function(_,v)
        local data = GetInterface("BarrackData").GetAramInfo(v.type_id,v.level)
        army = army + AttributeBonus.CalBattlePointNew(data)*v.num
        --print(v.type_id,v.level,AttributeBonus.CalBattlePointNew(data))
    end)

    local heroData = GetInterface("SelectHero_PVP").GetSelectHeroData(nil)
    for i =1 , #(heroData.memHero) do
        local heroMsg = GetInterface("HeroListData").GetGeneralByUID(heroData.memHero[i]) -- HeroListData.GetHeroDataByUid(heroData.memHero[i])
        local heroData = TableMgr:GetHeroData(heroMsg.baseid)
        hero = hero + GetInterface("HeroListData").GetPower(heroMsg) -- HeroListData.GetPower(heroMsg, heroData)
    end
    
    BattleFight = army + hero
    if BattleFightBase < 0 then
        BattleFightBase = BattleFight
    else
        if BattleFight > BattleFightBase then
            BattleUI.bg_left.Animator:Play("zhanlidonghuaplus")
            BattleUI.bg_left.PowerNum.color = Color.green
        elseif BattleFight < BattleFightBase then
            BattleUI.bg_left.Animator:Play("zhanlidonghuaminus")
            BattleUI.bg_left.PowerNum.color = Color.red
        else
            --BattleUI.bg_left.PowerNum.color = Color.white
        end
        BattleFightBase = BattleFight
    end
    BattleUI.bg_left.PowerNum.text = math.ceil( BattleFight);
    BMCalResult.HadHeroResult = {}
    for i = 1, #BMCalculationFunc do
        BMCalResult.HadHeroResult[i] = BMCalculationFunc[i]()
    end

    RefreshBMInfo()
end
