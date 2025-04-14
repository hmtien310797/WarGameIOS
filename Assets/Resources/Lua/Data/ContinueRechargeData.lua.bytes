module("ContinueRechargeData", package.seeall)

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
local availableCards = {}

function GetAvailableCard(activityID)
    if activityID then
        return availableCards[activityID]
    end

    return availableCards
end

function IsAvailable(activityID)
    return availableCards[activityID]
end

function HasUnclaimedAward(activityID)
    if not activityID then
        return false
    end
    local availableCard = availableCards[activityID]
    if availableCard == nil then
        return false
    end
    for i, v in kpairs(availableCard) do
        for k, l in pairs(v) do
            if type(l) == "table" and l.status == ActivityMsg_pb.RewardStatus_CanTake then
                return true
            end
        end
    end
    return false
end

function UpdateRechargeStatus()
    for i, v in pairs(availableCards) do
        for k, l in pairs(v) do
            l.hasRecharged = Global.IsTimeInToday(l.lastRechargeTime)
        end
    end
    NotifyListener()
end

local function AddCard(activityID, contRewardInfos)
    local availableCard = {}
    for k, infos in ipairs(contRewardInfos) do
        for i, v in ipairs(infos.perContInfo) do
            if availableCard[v.requestMoney] == nil then
                availableCard[v.requestMoney] = {}
            end
            if availableCard[v.requestMoney][v.needDays] == nil then
                availableCard[v.requestMoney][v.needDays] = {}
            end
            availableCard[v.requestMoney][v.needDays].rewardInfo = v.rewardInfo
            availableCard[v.requestMoney][v.needDays].status = v.status
            availableCard[v.requestMoney][v.needDays].displayPrice = v.displayPrice
        end
        for i, v in ipairs(infos.continueDays) do
            if availableCard[v.needMoney] then
                availableCard[v.needMoney].continueDays = v.continueDays
                availableCard[v.needMoney].needMoney = v.needMoney
                availableCard[v.needMoney].lastRechargeTime = v.lastRechargeTime
                availableCard[v.needMoney].hasRecharged = Global.IsTimeInToday(v.lastRechargeTime)
            end
        end
    end
    availableCards[activityID] = availableCard

    NotifyListener()
end

local function UpdateCard(activityID, contRewardInfos)
    local memorizedData = availableCards[activityID]
    for k, infos in ipairs(contRewardInfos) do
        for i, v in ipairs(infos.perContInfo) do
            if memorizedData[v.requestMoney] == nil then
                memorizedData[v.requestMoney] = {}
            end
            if memorizedData[v.requestMoney][v.needDays] == nil then
                memorizedData[v.requestMoney][v.needDays] = {}
            end
            memorizedData[v.requestMoney][v.needDays].rewardInfo = v.rewardInfo
            memorizedData[v.requestMoney][v.needDays].status = v.status
            memorizedData[v.requestMoney][v.needDays].displayPrice = v.displayPrice
        end
        for i, v in ipairs(infos.continueDays) do
            if memorizedData[v.needMoney] then
                memorizedData[v.needMoney].continueDays = v.continueDays
                memorizedData[v.needMoney].lastRechargeTime = v.lastRechargeTime
                memorizedData[v.needMoney].hasRecharged = Global.IsTimeInToday(v.lastRechargeTime)
            end
        end
    end
    NotifyListener(memorizedData, 0)
end

local function UpdatePerContInfo(perRewardInfo)
    availableCards[perRewardInfo.actId][perRewardInfo.requestMoney][perRewardInfo.needDays].status = perRewardInfo.status
    NotifyListener()
end

local function RemoveCard(activityID)
    local removedData = availableCards[activityID]

    availableCards[activityID] = nil

    NotifyListener(removedData, -1)
end

function SetData(userActivityInfoResponse)
    local shouldNotBeRemoved = {}
    for _, userActivityInfo in ipairs(userActivityInfoResponse.activity) do
        local activityID = userActivityInfo.activityId
        print(activityID)
        local templetID = userActivityInfo.templet
        if templetID == 399 then
            RequestData(activityID)
            shouldNotBeRemoved[activityID] = true
        end
    end

    for activityID, _ in pairs(availableCards) do
        if not shouldNotBeRemoved[activityID] then
            RemoveCard(activityID)
        end
    end
end
-------------------------------------------------------------------

function RequestData(activityID, callback)
    Global.LogDebug(_M, "RequestData", activityID, callback)
    if activityID then
        local request = ActivityMsg_pb.MsgContinuousRechargeInfoRequest()
        request.activityId = activityID

        Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgContinuousRechargeInfoRequest, request, ActivityMsg_pb.MsgContinuousRechargeInfoResponse, function(response)
            if availableCards[activityID] then
                UpdateCard(activityID, response.contRewardInfos)
            else
                AddCard(activityID, response.contRewardInfos)
            end

            if callback then
                callback(response.contRewardInfos)
            end
        end, true)
    end
end

function ClaimAward(activityId, needMoney, needDays, callback)
    local request = ActivityMsg_pb.MsgTakeContinuousRechargeRewardRequest()
    request.activityId = activityId
    request.needMoney = needMoney
    request.needDays = needDays
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeContinuousRechargeRewardRequest, request, ActivityMsg_pb.MsgTakeContinuousRechargeRewardResponse, function(response)
        if response.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(response.fresh)
            Global.ShowReward(response.reward)
            UpdatePerContInfo(response.perRewardInfo)
        else
            Global.ShowError(response.code)
        end

        if callback then
            callback(response)
        end
    end, true)
end
