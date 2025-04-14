module("ActivityTreasureData", package.seeall)
local treasureData = {}
local eventListener = EventListener()
local GameTime = Serclimax.GameTime

local TableMgr = Global.GTableMgr
local requestTimer

local isNew = false
local isActived = false

function NotifyAvailable()
    isNew = true
end

function NotifyUIOpened()
    isActived = false
    if isNew then
        isNew = false
        MainCityUI.UpdateActivityAllNotice(102)
    end
end

function GetData()
    return treasureData
end

function SetData(data)
    treasureData = data
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

function IsActive()
    local serverTime = GameTime.GetSecTime()
    return serverTime <= treasureData.freshTime and serverTime <= treasureData.lastFreshTime + treasureData.lifeTime
end


function RequestData(unlockScreen)
    local req = BattleMsg_pb.MsgBattleMapDigRewardViewRequest()
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleMapDigRewardViewRequest, req, BattleMsg_pb.MsgBattleMapDigRewardViewResponse, function(msg)
        Global.DumpMessage(msg)
        SetData(msg)
        isActived = IsActive()
        NotifyListener()

        if requestTimer ~= nil then
            requestTimer:Stop()
        end

        local serverTime = GameTime.GetSecTime()
        local duration = 0
        if serverTime < msg.freshTime then
            if serverTime > msg.lastFreshTime + msg.lifeTime then
                duration = msg.freshTime - serverTime
            else
                duration = msg.lastFreshTime + msg.lifeTime - serverTime
            end
        end
        if duration > 0 then
            requestTimer = Timer.New(RequestData, duration + 1, 1)
            requestTimer:Start()
        end
    end, unlockScreen)
end

function SetRewarded(index)
    local rewardMsg = treasureData.data[index]
    rewardMsg.rewarded = true
    NotifyListener()
end



function HasNotice()
    if isNew then
        return true
    end

    for _, v in ipairs(treasureData.data) do
        if v.value >= v.valueMax and not v.rewarded then
            return true
        end
    end
    
    if isActived and IsActive() then
        return true
    end

    return false
end
