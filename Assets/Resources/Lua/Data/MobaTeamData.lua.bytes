module("MobaTeamData", package.seeall)
local teamData
local eventListener = EventListener()
local TableMgr = Global.GTableMgr

function GetData()
    return teamData
end

function SetData(data)
    teamData = data
end


function RequestData(cb)
	if Global.GetMobaMode() == 1 then
		local req = MobaMsg_pb.MsgMobaUserArmyUnitsRequest()
		Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaUserArmyUnitsRequest, req, MobaMsg_pb.MsgMobaUserArmyUnitsResponse, function(msg)
			Global.DumpMessage(msg , "d:/mobahe.lua")
			SetData(msg.teamInfo)
			MobaHeroListData.SetData(msg)
			MobaArmyListData.SetData(msg.arms)
			--ActiveHeroData.SetData(msg.actheros)
			MobaArmySetoutData.SetData(msg.setoutNum)
			MobaBarrackData.UpdateArmNumEx(msg)
			if cb ~= nil then
				cb(msg)
			end
		end, true)
	elseif Global.GetMobaMode() == 2 then
		local req = GuildMobaMsg_pb.GuildMobaUserArmyUnitsRequest()
		Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaUserArmyUnitsRequest, req, GuildMobaMsg_pb.GuildMobaUserArmyUnitsResponse, function(msg)
			Global.DumpMessage(msg , "d:/mobahe.lua")
			SetData(msg.teamInfo)
			MobaHeroListData.SetData(msg)
			MobaArmyListData.SetData(msg.arms)
			--ActiveHeroData.SetData(msg.actheros)
			MobaArmySetoutData.SetData(msg.setoutNum)
			MobaBarrackData.UpdateArmNumEx(msg)
			if cb ~= nil then
				cb(msg)
			end
		end, true)
	end 
end

function RequestArmyInjuredData()
	local req = HeroMsg_pb.MsgInjureArmyInfoRequest()
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgInjureArmyInfoRequest, req, HeroMsg_pb.MsgInjureArmyInfoResponse, function(msg)
		if msg.code == 0 then
			 ArmyListData.SetInjuredArmyData(msg)
		else
			Global.FloatError(msg.code, Color.white)
			return
		end
	end, true)
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetDataByTeamType(teamType)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            return v
        end
    end

    teamData.team:add().type = teamType
    return teamData.team[#teamData.team]
end

function SetDataByTeamType(teamType, data)
	for i, v in ipairs(teamData.team) do
        if v.type == Common_pb.teamType then
			teamData.team[i] = data
            return 
        end
    end
	teamData.team:add()
	teamData.team[#teamData.team] = data
end

function IsHeroSelectedByUid(teamType, uid)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType or teamType == Common_pb.BattleTeamType_None then
            for __, vv in ipairs(v.memHero) do
                if vv.uid == uid then
                    return true
                end
            end
        end
    end

    return false
end

function IsHeroSelectedByBaseId(teamType, baseId)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType or teamType == Common_pb.BattleTeamType_None  then
            for __, vv in ipairs(v.memHero) do
                local heroMsg = MobaHeroListData.GetGeneralByUID(vv.uid) -- HeroListData.GetHeroDataByUid(vv.uid)
                if heroMsg ~= nil and heroMsg.baseid == baseId then
                    return true
                end
            end
        end
    end

    return false
end

function GetSelectedHeroCount(teamType)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            return #v.memHero
        end
    end

    return 0
end


function showHero(teamType)
	for _, v in ipairs(teamData.team) do
        if v.type == teamType then
			print(#v.memHero)
            for ii, vv in ipairs(v.memHero) do
				local heroMsg = MobaHeroListData.GetGeneralByUID(vv.uid) -- HeroListData.GetHeroDataByUid(vv.uid)
				print(vv.uid,heroMsg.baseId)
			end
        end
    end
end

function SelectHero(teamType, heroUid)
    if IsHeroSelectedByUid(teamType, heroUid) then
        return false
    end

    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            v.memHero:add().uid = heroUid
            return true
        end
    end
    teamData.team:add().type = teamType
    teamData.team[1].memHero:add().uid = heroUid
    return true
end

function UnselectHero(teamType, heroUid)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            for ii, vv in ipairs(v.memHero) do
                if vv.uid == heroUid then
                    v.memHero:remove(ii)
                    break
                end
            end
        end
    end
end

function UnselectAllHero(teamType)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            for i = #v.memHero, 1, -1 do
                v.memHero:remove(i)
            end
        end
    end
end

function GetSelectedHeroPower(teamType)
    local power = 0
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            for __, vv in ipairs(v.memHero) do
                local heroMsg = MobaHeroListData.GetGeneralByUID(vv.uid) -- HeroListData.GetHeroDataByUid(vv.uid)
                local heroData = TableMgr:GetHeroData(heroMsg.baseid)
                power = power + MobaHeroListData.GetPower(heroMsg) -- HeroListData.GetPower(heroMsg, heroData)
            end
        end
    end
    return power
end

function IsArmySelected(teamType, armyUid)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType or teamType == Common_pb.BattleTeamType_None  then
            for __, vv in ipairs(v.memArmy) do
                if vv.uid == armyUid then
                    return true
                end
            end
        end
    end

    return false
end

function GetSelectedArmyCount(teamType)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            return #v.memArmy
        end
    end

    return 0
end

function SelectArmy(teamType, armyUid)
    if IsArmySelected(teamType, armyUid) then
        return false
    end

    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            v.memArmy:add().uid = armyUid
            return true
        end
    end
    teamData.team:add().type = teamType
    teamData.team[1].memArmy:add().uid = armyUid

    return true
end

function SelectMaxLevelArmyByType(teamType, armyType)
    local armyUid = UnlockArmyData.GetMaxLevelArmyByType(armyType)
    return SelectArmy(teamType, armyUid)
end

function UnselectArmy(teamType, armyUid)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            for ii, vv in ipairs(v.memArmy) do
                if vv.uid == armyUid then
                    v.memArmy:remove(ii)
                    break
                end
            end
        end
    end
end

function UnselectAllArmy(teamType)
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            for i = #v.memArmy, 1, -1 do
                v.memArmy:remove(i)
            end
        end
    end
end



local PveArmyPowerFactor
function GetSelectedArmyPower(teamType)
    if PveArmyPowerFactor == nil then
        PveArmyPowerFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveArmyPowerFactor).value)
    end
    local power = 0
	
	--[[
	--兵种战力=兵种查表战力*（该兵种当前攻击/兵种查表攻击）*（该兵种当前生命/兵种查表生命）*（1+兵种当前防御/100）*（1+兵种其他加成之和/100）
	
    for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            for __, vv in ipairs(v.memArmy) do
                --local barrackData = TableMgr:GetBarrackDataByUnitId(vv.uid)
                --local battlePoint = barrackData.fight
				
				local maxLevelarmy = UnlockArmyData.GetMaxLevelArmyByUid(vv.uid)
				local unitData = TableMgr:GetUnitData(maxLevelarmy)
				
				AttributeBonus.CollectBonusInfo()
				local barrackInfo = Barrack.GetAramInfo(unitData._unitArmyType , unitData._unitArmyLevel)
				local afterPower = AttributeBonus.CalBattlePointNew(barrackInfo)
				
                power = power + math.floor(afterPower * PveArmyPowerFactor + 0.5)
            end
        end
    end
	]]
	for _, v in ipairs(teamData.team) do
        if v.type == teamType then
            for __, vv in ipairs(v.memArmy) do
                --local barrackData = TableMgr:GetBarrackDataByUnitId(vv.uid)
                --local battlePoint = barrackData.fight
				local unitData = TableMgr:GetUnitData(vv.uid)
				
				local ignore = {"EquipData", "TalentInfo", "BattleMove"}
				AttributeBonus.CollectBonusInfo(ignore)
				local barrackInfo = Barrack.GetAramInfo(unitData._unitArmyType , unitData._unitArmyLevel)
				local afterPower = AttributeBonus.CalBattlePointNew(barrackInfo)
				
                power = power + math.floor(afterPower * PveArmyPowerFactor + 0.5)
            end
        end
    end
    return power
end

function GetTeamPower(teamType)
    return GetSelectedHeroPower(teamType) + GetSelectedArmyPower(teamType)
end

function NormalizeData()
    for _, v in ipairs(teamData.team) do
        for i = #v.memHero, 1, -1 do
            local heroMsg = MobaHeroListData.GetGeneralByUID(v.memHero[i].uid) -- HeroListData.GetHeroDataByUid(v.memHero[i].uid)
            if heroMsg == nil then
                v.memHero:remove(i)
            else
                local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
                if heroData.expCard then
                    v.memHero:remove(i)
                end
            end
        end

        for i = #v.memHero, 1, -1 do
            for j = i - 1, 1, -1 do
                if v.memHero[i].uid == v.memHero[j].uid then
                    v.memHero:remove(i)
                    break
                end
            end
        end
        
        while #v.memHero > 5 do
            v.memHero:remove(#v.memHero)
        end

        for i = #v.memArmy, 1, -1 do
            local maxLevelArmy = UnlockArmyData.GetMaxLevelArmyByUid(v.memArmy[i].uid)
            if maxLevelArmy ~= nil then
                v.memArmy[i].uid = maxLevelArmy
            else
                v.memArmy:remove(i)
            end
        end

        for i = #v.memArmy, 1, -1 do
            for j = i - 1, 1, -1 do
                if v.memArmy[i].uid == v.memArmy[j].uid then
                    v.memArmy:remove(i)
                    break
                end
            end
        end

        while #v.memArmy > 4 do
            v.memArmy:remove(#v.memArmy)
        end
    end
end

function RequestDefentArmyData()
	if Global.GetMobaMode() == 1 then
		local req = HeroMsg_pb.MsgGetArmyTeamRequest()
		req.teamtype = Common_pb.BattleTeamType_CityDefence
		
		Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmyTeamRequest, req, HeroMsg_pb.MsgGetArmyTeamResponse, function(msg)
			SetDataByTeamType(msg.data)
		end, true)
	elseif Global.GetMobaMode() == 2 then
		local req = GuildMobaMsg_pb.GuildMobaGetArmyTeamRequest()
		req.teamtype = Common_pb.BattleTeamType_CityDefence
		
		Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetArmyTeamRequest, req, GuildMobaMsg_pb.MsgGetArmyTeamResponse, function(msg)
			SetDataByTeamType(msg.data)
		end, true)
		
	end
end	

--message MsgUserArmyUnitsPush  刷新全局
function OnPushSetData(msg)
	-- HeroListData.SetData(msg.heros)
    MobaHeroListData.OnPushSetData(msg)
    MobaArmyListData.SetData(msg.arms)
	MobaArmyListData.SetInjuredArmyData(msg)
	MobaArmySetoutData.UpdateData(msg.setoutNum)
	NotifyListener()
end
