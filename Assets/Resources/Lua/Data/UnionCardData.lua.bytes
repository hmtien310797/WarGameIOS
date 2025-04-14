module("UnionCardData", package.seeall)

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

function SetUnionCardTaked(taked)
	if availableCards[0] then
		availableCards[0].cantake = taked
		BroadcastEventOnAwardStatusChange(availableCards[0])
	end
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
	memorizedData.buyer = cardInfo.buyer

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
        if userActivityInfo.activityId == 3008 then
            RequestData(0)
            shouldNotBeRemoved[0] = true
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
    --[[if availableCards[subType] then
        UpdateCard(subType, MakeCardInfo(subType))
    else
        AddCard(subType, MakeCardInfo(subType))
    end]]

     local request = ShopMsg_pb.MsgIAPTakeCardInfoRequest()
     request.id = 8
     request.subType = subType
	--Global.DumpMessage(request , "d:/cardInfo.lua")
     Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeCardInfoRequest, request, ShopMsg_pb.MsgIAPTakeCardInfoResponse, function(response)
         if response.code == ReturnCode_pb.Code_OK then
			--Global.DumpMessage(response , "d:/cardInfo.lua")
             if availableCards[subType] then
                 UpdateCard(subType, response)
             else
                 AddCard(subType, response)
             end
         end

         if callback then
             callback(response)
         end
     end, true)
end

function ClaimAward(subType, callback)
    local request = ShopMsg_pb.MsgIAPTakeGuildMonthCardRequest()

    Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeGuildMonthCardRequest, request, ShopMsg_pb.MsgIAPTakeGuildMonthCardResponse, function(response)
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

function MakeCardInfo(subType)
    local iapGoodInfo = {}

    iapGoodInfo.id = 401
    iapGoodInfo.type = ShopMsg_pb.IAPGoodType_GuildMonthCard
    iapGoodInfo.priceType = 0
    iapGoodInfo.price = 648
    iapGoodInfo.icon = "icon_act_20"
    iapGoodInfo.backgroud = "icon_act_20"
    iapGoodInfo.name = "Union_Mcard"
    iapGoodInfo.topName = "Union_Mcard"
    iapGoodInfo.recommend = false
    iapGoodInfo.showPrice = 7540
    iapGoodInfo.desc = "Union_Mcard"
    iapGoodInfo.subDesc = "Union_Mcard"

    iapGoodInfo.itemBuy = { item = { item = { { baseid = 2,
                                                num = 1000, }, }, }, }
    iapGoodInfo.itemGift = { item = { item = { { baseid = 540504,
                                                 num = 2, },
                                               { baseid = 15,
                                                 num = 10000, }, }, }, }

    iapGoodInfo.endTime = 0
    iapGoodInfo.count = { id = { id = 0,
                                 subid = 0, },
                          count = 0,
                          countmax = 1,
                          refreshType = 0, }

    iapGoodInfo.order = 200
    iapGoodInfo.day = 30
    iapGoodInfo.index = 8
    iapGoodInfo.channelId = ""
    iapGoodInfo.productId = ""
    iapGoodInfo.guildChestId = 0
    iapGoodInfo.tab = 0
    iapGoodInfo.topName = ""
    iapGoodInfo.discount = 4000
    iapGoodInfo.hasBuy = false
    iapGoodInfo.vipminlevel = 0
    iapGoodInfo.vipmaxlevel = 0
    iapGoodInfo.subType = subType

    local cardInfo = {}

    cardInfo.code = 0
    cardInfo.day = 1
    cardInfo.item = { item = { item = { { baseid = 540504,
                                          num = 2, },
                                        { baseid = 15,
                                          num = 10000, }, }, }, }
    cardInfo.gift = { item = { item = { { baseid = 2,
                                          num = 200, },
                                        { baseid = 3,
                                          num = 10000, },
                                        { baseid = 540504,
                                          num = 4, },
                                        { baseid = 0 },
                                        { baseid = 2,
                                          num = 180, },
                                        { baseid = 3,
                                          num = 10000, },
                                        { baseid = 540504,
                                          num = 4, },
                                        { baseid = 0 },
                                        { baseid = 2,
                                          num = 120, },
                                        { baseid = 3,
                                          num = 5000, },
                                        { baseid = 540504,
                                          num = 3 },
                                        { baseid = 0 },
                                        { baseid = 2,
                                          num = 80, },
                                        { baseid = 3,
                                          num = 2000, },
                                        { baseid = 540504,
                                          num = 2, },
                                        { baseid = 0 },
                                        { baseid = 2,
                                          num = 50, },
                                        { baseid = 3,
                                          num = 1000, },
                                        { baseid = 540504,
                                          num = 1, }, }, }, }
    cardInfo.buyed = false
    cardInfo.cantake = false
    cardInfo.icon = ""
    cardInfo.goodInfo = iapGoodInfo

    return cardInfo
end

function Test_PurchaseCard(subType) -- UnionCardData.Test_PurchaseCard()
    local cardInfo = MakeCardInfo(subType)

    cardInfo.buyed = true
    cardInfo.cantake = true

    UpdateCard(0, cardInfo)
end

function Test_ClaimAward(subType) -- UnionCardData.Test_ClaimAward()
    if availableCards[subType].buyed then
        local cardInfo = MakeCardInfo(subType)

        cardInfo.buyed = true
        cardInfo.cantake = false

        UpdateCard(0, cardInfo)
    else
        Global.LogDebug(_M, "Test_ClaimAward", "请先购买")
    end
end

function IsAvailable()
    return ActivityData.IsActivityAvailable(3008)
end
