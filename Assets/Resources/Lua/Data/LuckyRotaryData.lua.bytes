module("LuckyRotaryData", package.seeall)

local eventListener = EventListener()

local function NotifyListener()
    MainCityUI.UpdateWelfareNotice()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function HasNotice()
    return not HasTakenReward()
end

----- Data --------------------------------------------------------
local availableCard
local activityId

function GetActivityId()
    return activityId
end

function GetAvailableCard()
    return availableCard
end

function IsAvailable()
    return availableCard
end

function HasUnclaimedAward()
    if availableCard then
        for i, v in ipairs(availableCard.extraRewards) do
            if v.status == ActivityMsg_pb.RewardStatus_CanTake then
                return true
            end
        end
        if availableCard.countInfo.count > 0 then
            return true
        end
    end
    return false
end

function SetData(userActivityInfoResponse)
    local shouldNotBeRemoved = {}
    for _, userActivityInfo in ipairs(userActivityInfoResponse.activity) do
        local templetID = userActivityInfo.templet
        if templetID == 310 then
            activityId = userActivityInfo.activityId
            RequestData()
        end
    end
end
-------------------------------------------------------------------

function RequestData(callback)
    local request = ActivityMsg_pb.MsgLotteryInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgLotteryInfoRequest, request, ActivityMsg_pb.MsgLotteryInfoResponse, function(response)
        availableCard = response
        if callback then
            callback(response)
        end
        NotifyListener()
        MainCityUI.UpdateWelfareNotice(activityId)
    end, true)
end

function DrawRequest(drawType, callback)
    local request = ActivityMsg_pb.MsgLotteryDrawRequest()
    request.drawType = drawType
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgLotteryDrawRequest, request, ActivityMsg_pb.MsgLotteryDrawResponse, function(response)
        if response.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(response.fresh)
            --Global.ShowReward(response.reward)
            availableCard.drawCount = response.drawCount
            availableCard.countInfo:MergeFrom(response.countInfo)
            for i, v in ipairs(availableCard.extraRewards) do
                if v.count <= response.drawCount and v.status == 1 then
                    v.status = 2
                end
            end
            if callback then
                callback(response)
            end
            NotifyListener()
            WelfareAll.RefreshTab(activityId)
        else
            Global.ShowError(response.code)
        end
    end, true)
end

function TakeExtraRewardRequest(count, callback)
    local request = ActivityMsg_pb.MsgLotteryTakeExtraRewardRequest()
    request.count = count
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgLotteryTakeExtraRewardRequest, request, ActivityMsg_pb.MsgLotteryTakeExtraRewardResponse, function(response)
        if response.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(response.fresh)
            Global.ShowReward(response.reward)
            for i, v in ipairs(availableCard.extraRewards) do
                if v.count == response.count then
                    v.status = 3
                end
            end
            if callback then
                callback(response)
            end
            NotifyListener()
            WelfareAll.RefreshTab(activityId)
        else
            Global.ShowError(response.code)
        end
    end, true)
end