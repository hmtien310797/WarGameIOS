module("MonthCardData", package.seeall)

-- local rewardData
-- local day
-- local takenSeven
-- local takenMonth 
-- local resetDay

-- local cardsData

local eventListener = EventListener()

-- local TableMgr = Global.GTableMgr

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

-- -- function GetTaken()
-- --     return takenSeven or takenMonth
-- -- end

-- -- function SetTakenSeven(_taken)
-- --     takenSeven = _taken
-- --     NotifyListener()
-- -- end

-- -- function SetTakenMonth(_taken)
-- --     takenMonth = _taken
-- --     NotifyListener()
-- -- end

function GetData()
    return {}
end

function HasNotice()
    return not HasTakenReward()
end

function RequestCard(type, callback)
    RequestData(type, callback)
    -- local req = ShopMsg_pb.MsgIAPTakeCardInfoRequest()
    -- req.id = type
    -- LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeCardInfoRequest, req:SerializeToString(), function (typeId, data)
    --     local msg = ShopMsg_pb.MsgIAPTakeCardInfoResponse()
    --     if cardsData == nil then
    --         cardsData = {}
    --     end
    --     msg:ParseFromString(data) 
    --     if  type == 3 then
    --         cardsData[1] = msg
    --     elseif type == 4 then
    --         cardsData[2] = msg
    --     end
    --     NotifyListener()
    --     if callback ~= nil then
    --         callback()
    --     end
    -- end, false)
end

-- function RequestData()
--     RequestCard(3, nil)
-- 	RequestCard(4, nil)
-- end

-- function SuccessfullyPurchase(id)
--     if id == 300 then
--         RequestCard(3, nil)
--     elseif id == 400 then
--         RequestCard(4, nil)
--     end
-- end

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
    NotifyListener()
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

function HasTakenReward()
    -- -- return not GetTaken()
    -- local has = false
    -- for i, v in ipairs(cardsData) do
    --     if v.code == 0 then
    --         if v.buyed then
    --             if v.cantake then
    --                 has = true
    --             end
    --         end
    --     end
    -- end

    -- return not has

    for _, availableCard in pairs(availableCards) do
        if availableCard.buyed and not availableCard.cantake then
            return true
        end
    end

    return false
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
        local activityID = userActivityInfo.activityId
        print(activityID)
        if activityID == 3004 then
            RequestData(ShopMsg_pb.IAPGoodType_WeekCard)

            shouldNotBeRemoved[ShopMsg_pb.IAPGoodType_WeekCard] = true 
        elseif activityID == 3011 then
            RequestData(ShopMsg_pb.IAPGoodType_MonthCard)
            
            shouldNotBeRemoved[ShopMsg_pb.IAPGoodType_MonthCard] = true
        elseif activityID == 9000 then
            RequestData(ShopMsg_pb.IAPGoodType_LifeLong)

            shouldNotBeRemoved[ShopMsg_pb.IAPGoodType_LifeLong] = true
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
    Global.LogDebug(_M, "RequestData", subType, callback)
    if subType then
        local request = ShopMsg_pb.MsgIAPTakeCardInfoRequest()
        request.id = subType

        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeCardInfoRequest, request, ShopMsg_pb.MsgIAPTakeCardInfoResponse, function(response)
            if response.code == ReturnCode_pb.Code_OK then
                if availableCards[subType] then
                    UpdateCard(subType, response)
                else
                    AddCard(subType, response)
                end
                if callback then
                    callback(response)
                end
            end
        end, true)
    end
end

function ClaimAward(subType, callback)
    if subType == ShopMsg_pb.IAPGoodType_WeekCard then
        local request = ShopMsg_pb.MsgIAPTakeWeekCardRequest()

        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeWeekCardRequest, request, ShopMsg_pb.MsgIAPTakeWeekCardResponse, function(response)
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
    elseif subType == ShopMsg_pb.IAPGoodType_MonthCard then
        local request = ShopMsg_pb.MsgIAPTakeMonthCardRequest()

        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeMonthCardRequest, request, ShopMsg_pb.MsgIAPTakeMonthCardResponse, function(response)
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
    elseif subType == ShopMsg_pb.IAPGoodType_LifeLong then
        local request = ShopMsg_pb.MsgIAPTakeLifeLongCardRequest()

        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeLifeLongCardRequest, request, ShopMsg_pb.MsgIAPTakeLifeLongCardResponse, function(response)
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
end

function SuccessfullyPurchase(id)
    for subType, cardInfo in pairs(availableCards) do
        if cardInfo.goodInfo.id == id then
            RequestData(cardInfo.goodInfo.type)
            return
        end
    end
end

local zeroTimeStamp = Global.GetFiveOclockCooldown()
EventDispatcher.Bind(Global.OnTick(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(now)
    if HasBought(ShopMsg_pb.IAPGoodType_LifeLong) then
        local timeStamp = availableCards[ShopMsg_pb.IAPGoodType_LifeLong].day

        if timeStamp > 0 and now > timeStamp then
            RequestData(ShopMsg_pb.IAPGoodType_LifeLong)
        end
    end
end)
