module("SevenDayData", package.seeall)
local rewardData
local isFirst
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return rewardData
end

function SetData(data)
    rewardData = data
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

function RequestData(callback)
    local req = ActivityMsg_pb.MsgSevenRewardRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSevenRewardRequest, req, ActivityMsg_pb.MsgSevenRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg.reward)
            isFirst = msg.first
            NotifyListener()            
        end

        if callback then
            callback()
        end
    end, true)
end

function GetRewardData(day)
    for _, v in ipairs(rewardData) do
        if v.day == day then
            return v
        end
    end
end

function SetRewardTaken(day)
    for i, v in ipairs(rewardData) do
        if v.day == day then
            v.status = ActivityMsg_pb.SevenRewardStatus_Taken
            NotifyListener()
            break
        end
    end
end

function GetUnTakenDay()
    if rewardData ~= nil then
        for i, v in ipairs(rewardData) do
            if v.status == ActivityMsg_pb.SevenRewardStatus_UnTaken then
                return v.day
            end
        end
    end
    return nil
end

function GetLastTakenDay()
    local day = nil
    for i, v in ipairs(rewardData) do
        if v.status == ActivityMsg_pb.SevenRewardStatus_Taken then
            if day == nil or v.day > day then
                day = v.day
            end
        end
    end
    return day
end

function HasTakenReward()
    return GetUnTakenDay() == nil
end

function HasNotice()
    return ActivityData.HasActivity(SevenDay) and not HasTakenReward()
end

function IsFirst()
    return isFirst
end
