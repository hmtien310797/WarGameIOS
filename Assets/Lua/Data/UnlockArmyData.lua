module("UnlockArmyData", package.seeall)
local unlockArmyData
local armyList
local eventListener = EventListener()
local TableMgr = Global.GTableMgr

local function NotifyListener(unlockedList)
    eventListener:NotifyListener(unlockedList)
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
    return unlockArmyData
end

function SetData(data)
    unlockArmyData = data
    local typeList = {}
    for _, v in ipairs(unlockArmyData) do
        local armyData = TableMgr:GetUnitData(v) 
        if typeList[armyData._unitArmyType] == nil or typeList[armyData._unitArmyType]._unitArmyLevel < armyData._unitArmyLevel then
            typeList[armyData._unitArmyType] = armyData
        end
    end
    local oldArmyList = armyList
    armyList = {}
    for _, v in pairs(typeList) do
        table.insert(armyList, v.id)
    end
    table.sort(armyList)

    local unlockedList = {}
    if oldArmyList ~= nil then
        for _, v in ipairs(armyList) do
            local inOldList = false
            for __, vv in ipairs(oldArmyList) do
                if vv == v then
                    inOldList = true
                    break
                end
            end
            if not inOldList then
                table.insert(unlockedList, v)
            end
        end
    end
    NotifyListener(unlockedList)
	
	return unlockedList
end

function GetArmyList()
    return armyList
end

function RequestData(callback)
    local req = HeroMsg_pb.MsgUserUnlockArmyRequest();
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgUserUnlockArmyRequest, req, HeroMsg_pb.MsgUserUnlockArmyResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            local unlocklist = SetData(msg.army)
			if callback ~= nil then
				callback(unlocklist)
			end
        end
    end, true)
end


function HasArmy(uid)
    for _, v in ipairs(unlockArmyData) do
        if v == uid then
            return true
        end
    end
    return false
end

function GetMaxLevelArmyByUid(uid)
    local newUid = nil
    local oldArmyData = TableMgr:GetUnitData(uid)
    local oldLevel = oldArmyData._unitArmyLevel
    local oldType = oldArmyData._unitArmyType
    for _, v in ipairs(unlockArmyData) do
        local armyData = TableMgr:GetUnitData(v) 
        if armyData._unitArmyType == oldType and armyData._unitArmyLevel >= oldLevel then
            newUid = v
        end
    end
    return newUid
end

function GetMaxLevelArmyArray()
    local base_id = {}
    local max_id = {}
    local r = {}
	if unlockArmyData ~= nil then
    for _, v in ipairs(unlockArmyData) do
        local armyData = TableMgr:GetUnitData(v) 
        if armyData._unitArmyLevel > 0 then
        	if r[armyData._unitArmyType] == nil then
	            r[armyData._unitArmyType] = {}
	        end
	        if armyData._unitArmyLevel == 1 then
	            r[armyData._unitArmyType].b = v
	            r[armyData._unitArmyType].m = v
	        else
	            if r[armyData._unitArmyType].m < v then
	                r[armyData._unitArmyType].m = v
	            end
	        end
	    end
    end
    for _, v in ipairs(r) do
        table.insert(base_id,v.b)
        table.insert(max_id,v.m)
    end
	end
    return base_id,max_id
end

function GetMaxLevelArmyByType(type)
    local newUid = nil
    local oldLevel = -1
    for _, v in ipairs(unlockArmyData) do
        local armyData = TableMgr:GetUnitData(v) 
        if armyData._unitArmyType == type and armyData._unitArmyLevel >= oldLevel then
            newUid = v
        end
    end
    return newUid
end


local PveArmyPowerFactor
function GetArmyTopPower(armyCount , heroCount)
	if PveArmyPowerFactor == nil then
        PveArmyPowerFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveArmyPowerFactor).value)
    end
	
	local heroTopPower = 0
	local armyTopPower = 0
	local bonusinfo = nil
	
	local armyTable = {}
	heroTopPower = SelectHero.GetTopHeroPower(heroCount)

	SelectArmy.SetPveMonsterBattle(true , heroCount)
	local ignore = {"EquipData", "TalentInfo"}
	bonusinfo = AttributeBonus.CollectBonusInfo(ignore)
	for _, v in ipairs(unlockArmyData) do
		--local maxLevelarmy = UnlockArmyData.GetMaxLevelArmyByUid(v)
		local unitData = TableMgr:GetUnitData(v)
		if unitData._unitArmyType ~= 101 and  unitData._unitArmyType ~= 102 then
			local barrackInfo = Barrack.GetAramInfo(unitData._unitArmyType , unitData._unitArmyLevel)
			local afterPower = AttributeBonus.CalBattlePointNew(barrackInfo)
			local power = math.floor(afterPower * PveArmyPowerFactor + 0.5)
			
			--print(unitData._unitArmyType , power)
			table.insert(armyTable , power)
		end
    end
	
	table.sort(armyTable , function(v1, v2)
		return v1 > v2
	end)
	
	
	for i=1 , #(armyTable) , 1 do
		--print(armyTable[i])
		if i <= armyCount then
			armyTopPower = armyTopPower + armyTable[i]
		end
	end
	
	return armyTopPower , heroTopPower
end
