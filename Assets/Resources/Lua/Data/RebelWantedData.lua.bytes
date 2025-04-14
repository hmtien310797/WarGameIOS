module("RebelWantedData", package.seeall)

local rebelWantedData
local maxLevelEliminated = 0
local unlockedLevel = 1

local eventListener = EventListener()

local isNew = false

local TableMgr = Global.GTableMgr

function GetData()
    return rebelWantedData
end

function GetSweetLeftCount()
	return rebelWantedData.leftSweepCount
end

function GetSweetTotalCount()
	return rebelWantedData.totalSweepCount
end

function SetData(data)
    rebelWantedData = data
end

function GetUnlockConditionForLevel(level)
    return level - 1
end

function GetUnlockedLevel()
    return math.min(unlockedLevel, rebelWantedData.monsterMaxLevel)
end

function IsLevelUnlocked(level)
    return level > rebelWantedData.monsterMaxLevel or level <= unlockedLevel
end

local function CalculateLevelInfo()
    for _, v in ipairs(rebelWantedData.atkInfos) do
        if v.level <= rebelWantedData.monsterMaxLevel then
            maxLevelEliminated = math.max(maxLevelEliminated, v.level)
        end
    end

    unlockedLevel = math.max(unlockedLevel, maxLevelEliminated + 1)

    return maxLevelEliminated
end

local function NotifyListener()
    CalculateLevelInfo()

    eventListener:NotifyListener()
end

function NotifyAvailable()
    isNew = true
end

function NotifyUIOpened()
    if isNew then
        isNew = false
        MainCityUI.UpdateActivityAllNotice(3001)
    end
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function RequestData(callback)
    local req = MapMsg_pb.MonsterInfoRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MonsterInfoRequest, req, MapMsg_pb.MonsterInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            NotifyListener()

            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function GetRebelData(level)
    for _, v in ipairs(rebelWantedData.atkInfos) do
        if v.level == level then
            return v
        end
    end

    return nil
end

function HasRebelData(level)
    return GetRebelData(level) ~= nil
end

function GetMinRewardLevel()
    local level = rebelWantedData.monsterMaxLevel
    for _, v in ipairs(rebelWantedData.atkInfos) do
        if v.level <= rebelWantedData.monsterMaxLevel and not v.isRewarded and v.level < level then
            level = v.level
        end
    end

    return level
end

function GetMaxLevel()
    return maxLevelEliminated
end

function UpdateRebelData(data)
    for i, v in ipairs(rebelWantedData.atkInfos) do
        if v.level == data.level then
            rebelWantedData.atkInfos[i] = data
            NotifyListener()
            break
        end
    end
end

function HasNotice()
    if isNew then
        return true
    end

    for _, v in ipairs(rebelWantedData.atkInfos) do
        if v.level <= rebelWantedData.monsterMaxLevel and not v.isRewarded then
            return true
        end
    end

    return false
end
