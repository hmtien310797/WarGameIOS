module("OnlineRewardData", package.seeall)
local rewardData
local recommendedGood
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return rewardData
end

function GetRecommendedGood()
    return recommendedGood
end

function SetData(data)
    rewardData = data
end

function UpdateData(data)
    rewardData = data
	eventListener:NotifyListener()
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

function RequestData()
    local req = ActivityMsg_pb.MsgOnlineRewardInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgOnlineRewardInfoRequest, req, ActivityMsg_pb.MsgOnlineRewardInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg.onlineReward)
            recommendedGood = msg.goodInfo
            Global.LogDebug(_M, "RequestData", recommendedGood.id)
            NotifyListener()
        end
    end, true)
end

EventDispatcher.Bind(GiftPackData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(iapGoodInfo, change)
    if recommendedGood then
        if change > 0 then
            RequestData()
        elseif change < 0 and iapGoodInfo.id == recommendedGood.id then
            RequestData()
        end
    end
end)
