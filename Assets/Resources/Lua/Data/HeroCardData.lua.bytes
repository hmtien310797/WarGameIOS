module("HeroCardData", package.seeall)

----- Events ---------------------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()
local eventOnPurchaseStatusChange = EventDispatcher.CreateEvent()
local eventOnAwardStatusChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

function OnPurchaseStatusChange()
    return eventOnPurchaseStatusChange
end

function OnAwardStatusChange()
    return eventOnAwardStatusChange
end

local function BroadcastEventOnDataChange(...)
    EventDispatcher.Broadcast(eventOnDataChange, ...)
end

local function BroadcastEventOnPurchaseStatusChange(...)
    EventDispatcher.Broadcast(eventOnPurchaseStatusChange, ...)
end

local function BroadcastEventOnAwardStatusChange(...)
    EventDispatcher.Broadcast(eventOnAwardStatusChange, ...)
end
----------------------------------------------------------------------

----- Data --------------------------------------------------------
local availableCards = {}

function GetAvailableCard(subType)
    if subType then
        return availableCards[subType]
    end

    return availableCards
end

function IsAvailable(subType)
    return availableCards[subType]
end

function HasUnclaimedAward(subType)
    if not subType then
        for _, availableCard in pairs(availableCards) do
            if availableCard.buyed and availableCard.cantake then
                return true
            end
        end

        return false
    else
        local availableCard = availableCards[subType]
        return availableCard and availableCard.buyed and availableCard.cantake
    end
end

function HasBought(subType)
    local availableCard = availableCards[subType]
    return availableCard and availableCard.buyed
end

local function AddCard(subType, cardInfo)
    local availableCard = {}

    availableCards[subType] = cardInfo

    if cardInfo.cantake then
        BroadcastEventOnAwardStatusChange(cardInfo)
    end

    BroadcastEventOnDataChange(cardInfo, 1)
end

local function UpdateCard(subType, cardInfo)
    local memorizedData = availableCards[subType]

    local hasDataChanged = false
    local hasPurchaseStatusChanged = false
    local hasAwardStatusChange = false

    if memorizedData.buyed ~= cardInfo.buyed then
        memorizedData.buyed = cardInfo.buyed
        hasPurchaseStatusChanged = true
        hasDataChanged = true
    end
    
    if memorizedData.cantake ~= cardInfo.cantake then
        memorizedData.cantake = cardInfo.cantake
        hasAwardStatusChange = true
        hasDataChanged = true
    end

    memorizedData.day = cardInfo.day

    if hasPurchaseStatusChanged then
        BroadcastEventOnPurchaseStatusChange(memorizedData)
    end

    if hasAwardStatusChange then
        BroadcastEventOnAwardStatusChange(memorizedData)
    end

    if hasDataChanged then
        BroadcastEventOnDataChange(memorizedData, 0)
    end
end

local function RemoveCard(subType)
    local removedData = availableCards[subType]

    availableCards[subType] = nil

    if removedData.cantake then
        BroadcastEventOnAwardStatusChange(removedData)
    end

    BroadcastEventOnDataChange(removedData, -1)
end

function SetData(userActivityInfoResponse)
    local shouldNotBeRemoved = {}
    for _, userActivityInfo in ipairs(userActivityInfoResponse.activity) do
        if math.floor(userActivityInfo.activityId / 1000) == 7 and math.floor(userActivityInfo.templet / 100) == 7 then
            local subType = userActivityInfo.templet % 100

            RequestData(subType)
            shouldNotBeRemoved[subType] = true
        end
    end

    for subType, _ in pairs(availableCards) do
        if not shouldNotBeRemoved[subType] then
            RemoveCard(subType)
        end
    end
end
-------------------------------------------------------------------

function RequestData(subType, callback)
    local request = ShopMsg_pb.MsgIAPTakeCardInfoRequest()
    request.id = 7
    request.subType = subType

    Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeCardInfoRequest, request, ShopMsg_pb.MsgIAPTakeCardInfoResponse, function(response)
        Global.DumpMessage(response, "d:/wgame/dump/messages/MsgIAPTakeCardInfoResponse.lua")

        if availableCards[subType] then
            UpdateCard(subType, response)
        else
            AddCard(subType, response)
        end

        if callback then
            callback(response)
        end
    end, true)
end

function ClaimAward(subType, callback)
    local request = ShopMsg_pb.MsgIAPTakeHeroCardRequest()
    request.subType = subType

    Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeHeroCardRequest, request, ShopMsg_pb.MsgIAPTakeHeroCardResponse, function(response)
        if response.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(response.fresh)
            Global.ShowReward(response.reward)
            RequestData(subType)
        else
            Global.ShowError(response.code)
        end

        if callback then
            callback(response)
        end
    end, true)
end

function SuccessfullyPurchase(id)
    for subType, cardInfo in pairs(availableCards) do
        if cardInfo.goodInfo.id == id then
            RequestData(cardInfo.goodInfo.subType)
            return
        end
    end
end
