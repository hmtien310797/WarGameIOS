module("WarLossData", package.seeall)
local warLossData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return warLossData
end

function SetData(data)
    warLossData = data
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

function UpdateData(data)
    SetData(data)
    NotifyListener()
end

function RequestData(callback, lockScreen)
    local req = ActivityMsg_pb.MsgWarLossGetInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgWarLossGetInfoRequest, req, ActivityMsg_pb.MsgWarLossGetInfoResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
        end
        --WelfareAll.RefreshTab(3015)
        DailyActivityData.ProcessActivity()
    end, not lockScreen)
end

function UpdateScore(score)
    warLossData.score = score
    NotifyListener()
end

function HasUnclaimedAward()
    for i, v in ipairs(warLossData.extraRewards) do
        if v.status == 2 or v.status == 1 and warLossData.drawCount >= v.count then
            return true
        end
    end

    return false
end
