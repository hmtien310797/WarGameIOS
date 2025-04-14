module("Welfare_HerogetData", package.seeall)

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
    for i, v in pairs(availableCard) do
        if v.status == ActivityMsg_pb.RewardStatus_CanTake then
            return true
        end
    end
    return false
end

local function AddCard(activityID, contRewardInfos)
    availableCards[activityID] = contRewardInfos.infos
    NotifyListener()
end

local function UpdateCard(activityID, contRewardInfos)
    availableCards[activityID] = contRewardInfos.infos
    NotifyListener()
end

local function UpdatePerContInfo(activityID, index)
    for i, v in ipairs(availableCards[activityID]) do
        if v.index == index then
            v.status = ActivityMsg_pb.RewardStatus_HasTaken
        end
    end
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
        local templetID = userActivityInfo.templet
        if templetID == 313 then
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
local isRequesting = false
function RequestData(activityID, callback)
    if isRequesting then
        return
    end
    isRequesting = true
    Global.LogDebug(_M, "RequestData", activityID, callback)
    if activityID then
        local request = ActivityMsg_pb.MsgHeroRecruitInfoRequest()
        Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgHeroRecruitInfoRequest, request, ActivityMsg_pb.MsgHeroRecruitInfoResponse, function(response)
            isRequesting = false
            if availableCards[activityID] then
                UpdateCard(activityID, response.rewardList)
            else
                AddCard(activityID, response.rewardList)
            end

            if callback then
                callback(response.rewardList)
            end
        end, true)
    end
end

function ClaimAward(activityID, index, callback)
    local request = ActivityMsg_pb.MsgTakeHeroRecruitRewardRequest()
    request.index = index
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeHeroRecruitRewardRequest, request, ActivityMsg_pb.MsgTakeHeroRecruitRewardResponse, function(response)
        if response.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(response.fresh)
            Global.ShowReward(response.reward)
            UpdatePerContInfo(activityID, index)
        else
            Global.ShowError(response.code)
        end

        if callback then
            callback(response)
        end
    end, true)
end
