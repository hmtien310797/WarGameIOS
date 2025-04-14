module("GiftPackData", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

----- Events -------------------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()
local eventOnHistoryStatusChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

function OnHistoryStatusChange()
    return eventOnHistoryStatusChange
end

local function BroadcastEventOnDataChange(...)
    EventDispatcher.Broadcast(eventOnDataChange, ...)
end

local function BroadcastEventOnHistoryStatusChange(...)
    EventDispatcher.Broadcast(eventOnHistoryStatusChange, ...)
end
--------------------------------------------------------------------
local exchangelist = {["0.15"] = "1", ["0.49"] = "3", ["0.99"] = "6", ["4.99"] = "30", ["9.99"] = "68", ["19.99"] = "128", ["49.99"] = "328", ["99.99"] = "648"}

function ExchangePrice(iapGoodInfo)
    if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_quick or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_qihu then
        for i, v in pairs(exchangelist) do
            if tonumber(iapGoodInfo.price) == tonumber(i) then
                iapGoodInfo.price = v
            end
        end
    end
end

function Exchange(price)
    if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_quick or
       GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_qihu then
        for i, v in pairs(exchangelist) do
            if tonumber(price) == tonumber(i) then
                price = v
            end
        end
    end
    return price
end
----- Data -------------------------------------------------------------------------------------------------------------
local availableGoods
local availableGoodsByTab
local availableGoodsByConfigIndex
local availableGoodsCounts
local availability

local historyStatus

local limitedGoods
local unshownLimitedGoods

local zerogift = {}

function GetZeroGift()
    return zerogift
end

function IsZeroGiftRed()
    local hasred = false
    for i, v in ipairs(zerogift) do
        if not v.hasBuy then
            hasred = true
        end
    end
    return hasred
end

function GetAvailableGoodsByID(id)
    if id then
        return availableGoods[id]
    end

    return availableGoods
end

function GetAvailableGoodsByTab(tab)
    if tab then
        return availableGoodsByTab[tab]
    end

    return availableGoodsByTab
end

function HasAvailableGoods(tab)
    if tab then
        return availableGoodsCounts[tab] and availableGoodsCounts[tab] ~= 0 or false
    else
        for tab, _ in pairs(availableGoodsByTab) do
            if HasAvailableGoods(tab) then
                return true
            end
        end

        return false
    end
end

function IsGiftPackAvailable(id)
    return availableGoods[id] ~= nil
end

function GetAvailableGoodsCount(tab)
    if tab then
        return availableGoodsCounts[tab] or 0
    end

    return availableGoodsCounts
end

function HasNewGoods(tab)
    if tab then
        for _, isNew in pairs(historyStatus[tab] or {}) do
            if isNew then
                return true
            end
        end
    else
        for tab, _ in pairs(historyStatus) do
            if HasNewGoods(tab) then
                return true
            end
        end
    end

    return false
end

function IsNew(iapGoodsInfo)
    local tab = iapGoodsInfo.tab
    local id = iapGoodsInfo.id

    if historyStatus[tab][id] ~= nil then
        return historyStatus[tab][id]
    end

    return ConfigData.GetGiftPackHistory(iapGoodsInfo)
end

function HasLimitedGoods()
    return limitedGoods:Count() > 0
end

function GetLimitedGoods()
    return limitedGoods.data
end 

local function SetAvailability(iapGoodsInfo, isAvailable)
    local index = iapGoodsInfo.index
    local configIndex = ConfigData.GetGiftPackConfigIndex(iapGoodsInfo)

    if not availability[configIndex] then
        availability[configIndex] = 0
    end

    availability[configIndex] = bit.write(availability[configIndex], isAvailable and 1 or 0, index)
end

function SetHistoryStatus(iapGoodsInfo, isNew)
    local tab = iapGoodsInfo.tab
    local id = iapGoodsInfo.id

    if historyStatus[tab][id] ~= isNew then
        local bool_isNew_old = historyStatus[tab][id] or false

        historyStatus[tab][id] = isNew

        local bool_isNew_new = isNew or false

        ConfigData.SetGiftPackHistory(iapGoodsInfo, bool_isNew_new)

        if bool_isNew_new ~= bool_isNew_old then
            BroadcastEventOnHistoryStatusChange(iapGoodsInfo, bool_isNew_new)
        end
    end
end

local function AddLimitedGoods(iapGoodsInfo)
    local tab = iapGoodsInfo.tab
    local id = iapGoodsInfo.id
    ExchangePrice(iapGoodsInfo)
    limitedGoods:Insert(iapGoodsInfo)
    unshownLimitedGoods:Insert(iapGoodsInfo)

    availableGoodsCounts.limited = availableGoodsCounts.limited + 1
end

local function RemoveLimitedGoods(iapGoodsInfo)
    local tab = iapGoodsInfo.tab
    local id = iapGoodsInfo.id

    limitedGoods:RemoveFirst(function(iapGoodsInfo)
        return iapGoodsInfo.id == id
    end)
    
    unshownLimitedGoods:RemoveFirst(function(iapGoodsInfo)
        return iapGoodsInfo.id == id
    end)

    availableGoodsCounts.limited = availableGoodsCounts.limited - 1
end

local function AddData(iapGoodsInfo)
    ExchangePrice(iapGoodsInfo)
    local id = iapGoodsInfo.id
    local tab = iapGoodsInfo.tab
    local index = iapGoodsInfo.index
    local configIndex = ConfigData.GetGiftPackConfigIndex(iapGoodsInfo)

    if not availableGoodsByTab[tab] then
        availableGoodsByTab[tab] = {}
        availableGoodsCounts[tab] = 0
        historyStatus[tab] = {}
    end

    if not availableGoodsByConfigIndex[configIndex] then
        availableGoodsByConfigIndex[configIndex] = {}
    end

    availableGoods[id] = iapGoodsInfo
    availableGoodsByTab[tab][id] = iapGoodsInfo
    availableGoodsByConfigIndex[configIndex][index] = iapGoodsInfo
    availableGoodsCounts[tab] = availableGoodsCounts[tab] + 1
    availableGoodsCounts.all = availableGoodsCounts.all + 1

    SetAvailability(iapGoodsInfo, true)
    
    if iapGoodsInfo.endTime ~= 0 then
        AddLimitedGoods(iapGoodsInfo)
        SetHistoryStatus(iapGoodsInfo, true)
    else
        SetHistoryStatus(iapGoodsInfo, ConfigData.GetGiftPackHistory(iapGoodsInfo))
    end

    BroadcastEventOnDataChange(iapGoodsInfo, 1)
end

local function UpdateData(iapGoodsInfo)
    availableGoods[iapGoodsInfo.id].endTime = iapGoodsInfo.endTime
    availableGoods[iapGoodsInfo.id].count.count = iapGoodsInfo.count.count

    BroadcastEventOnDataChange(iapGoodsInfo, 0)
end

local function UpdateIapGoodsInfo(iapGoodsInfo)
    local id = iapGoodsInfo.id
    local tab = iapGoodsInfo.tab
    local index = iapGoodsInfo.index
    local configIndex = ConfigData.GetGiftPackConfigIndex(iapGoodsInfo)
    if not availableGoodsByTab[tab] or not availableGoodsByConfigIndex[configIndex] then
        AddData(iapGoodsInfo)
        return
    end
    availableGoods[id] = iapGoodsInfo
    availableGoodsByTab[tab][id] = iapGoodsInfo
    availableGoodsByConfigIndex[configIndex][index] = iapGoodsInfo

    BroadcastEventOnDataChange(iapGoodsInfo, 0)
end

local function RemoveData(iapGoodsInfo)
    local id = iapGoodsInfo.id
    local tab = iapGoodsInfo.tab
    local index = iapGoodsInfo.index
    local configIndex = ConfigData.GetGiftPackConfigIndex(iapGoodsInfo)

    availableGoods[id] = nil
    availableGoodsByTab[tab][id] = nil
    availableGoodsByConfigIndex[configIndex][index] = nil
    availableGoodsCounts[tab] = availableGoodsCounts[tab] - 1
    availableGoodsCounts.all = availableGoodsCounts.all - 1

    SetAvailability(iapGoodsInfo, false)
    SetHistoryStatus(iapGoodsInfo, nil)

    if iapGoodsInfo.endTime ~= 0 then
        RemoveLimitedGoods(iapGoodsInfo)
    end

    BroadcastEventOnDataChange(iapGoodsInfo, -1)
end

function GetGlobalLimitPack()
	local packs = {}
	for _ , v in pairs(globalLimitPacks) do
		if v then
			table.insert(packs , v)
		end
	end
	
	return packs
end

function GetGlobalLimitPack()
	local packs = {}
	for _ , v in pairs(availableGoods) do
		if v and v.globalLimit > 0 then
			table.insert(packs , v)
		end
	end
	return packs
end

local function SetData(msg, type, updateid)
    local configs = TableMgr:GetGiftpackTabConfig()

    local shouldNotBeRemoved = {}
    zerogift = {}

    for _, iapGoodsInfo in ipairs(msg.goodInfos) do
        if (iapGoodsInfo.type == 2 or iapGoodsInfo.type == 6) and configs[iapGoodsInfo.tab] then
            local id = iapGoodsInfo.id
            local index = iapGoodsInfo.index
            local configIndex = ConfigData.GetGiftPackConfigIndex(iapGoodsInfo)

            local memorizedData = availableGoods[id]
            if not memorizedData then
                AddData(iapGoodsInfo)
            elseif memorizedData.endTime ~= iapGoodsInfo.endTime or (memorizedData.count and memorizedData.count.count ~= iapGoodsInfo.count.count) then
                UpdateData(iapGoodsInfo)
            else
                UpdateIapGoodsInfo(iapGoodsInfo)
            end

			
            if not shouldNotBeRemoved[configIndex] then
                shouldNotBeRemoved[configIndex] = 0
            end

            shouldNotBeRemoved[configIndex] = bit.write(shouldNotBeRemoved[configIndex], 1, index)
        end

        if iapGoodsInfo.type == ShopMsg_pb.IAPGoodType_ZeroBuy then
            table.insert(zerogift, iapGoodsInfo)
        end
    end

    for configIndex, int_isAvailable in pairs(availability) do
        local int_shouldNotBeRemoved = shouldNotBeRemoved[configIndex]
        if not int_shouldNotBeRemoved then
            for _, iapGoodsInfo in pairs(availableGoodsByConfigIndex[configIndex]) do
                if type == 0 or iapGoodsInfo.type == type then
                    RemoveData(iapGoodsInfo)
                end
            end
        elseif int_isAvailable ~= int_shouldNotBeRemoved then
            local int_shouldBeRemoved = bit.band(int_isAvailable, bit.bnot(int_shouldNotBeRemoved))
            for index, iapGoodsInfo in pairs(availableGoodsByConfigIndex[configIndex]) do
                if (type == 0 or iapGoodsInfo.type == type) and bit.read(int_shouldBeRemoved, index % 32) ~= 0 then
                    RemoveData(iapGoodsInfo)
                end
            end
        end
    end

    if updateid then
        for configIndex, int_isAvailable in pairs(availableGoodsByConfigIndex) do
            for _, iapGoodsInfo in pairs(availableGoodsByConfigIndex[configIndex]) do
                if iapGoodsInfo.id == updateid and iapGoodsInfo.type == 6 then
                    RemoveData(iapGoodsInfo)
                end
            end
        end
    end
end

local function ResetData()
    availableGoods = {}
    availableGoodsByTab = {}
    availableGoodsByConfigIndex = {}
    availableGoodsCounts = {}
    availability = {}

    historyStatus = {}

    limitedGoods = SortedList(nil, function(iapGoodsInfo1, iapGoodsInfo2)
        if iapGoodsInfo1.id == iapGoodsInfo2.id then
            return 0
        else
            return iapGoodsInfo1.endTime < iapGoodsInfo2.endTime and -1 or 1
        end
    end)

    unshownLimitedGoods = SortedList(nil, function(iapGoodsInfo1, iapGoodsInfo2)
        if iapGoodsInfo1.id == iapGoodsInfo2.id then
            return 0
        else
            return iapGoodsInfo1.order < iapGoodsInfo2.order and -1 or 1
        end
    end)

    availableGoodsCounts.limited = 0
    availableGoodsCounts.all = 0
end
------------------------------------------------------------------------------------------------------------------------

----- Popup Window ------------------------------------------------------------------------------------------------------
--[[
如需添加新的限时礼包弹窗，请在要添加的模板的.lua文件中调用 RegisterPopupWindow 方法注册该弹窗

    *Show(iapGoodInfo)              用于显示模板UI
                                    @params [iapGoodInfo] Common_pb.IAPGoodInfo类

    *Hide()                         用于隐藏模板UI

*必须实现
    
（具体实现可参考 Goldstore_template1.lua）
]]

local popupWindows = {}
local currentPopupWindow

local function SetCurrentPopupWindow(id)
    currentPopupWindow = id
end

function RegisterPopupWindow(id, module)
    if popupWindows[id] then
        Global.LogError(_M, "RegisterPopupWindow", string.format("%s 不能注册为已注册的弹窗 (%d)，请更换弹窗ID", module._NAME, id))
    else
        if not module.Show then
            Global.LogError(_M, "RegisterPopupWindow", string.format("%s 必须实现 Show(iapGoodInfo) 方法", module._NAME))
        end

        if not module.Hide then
            Global.LogError(_M, "RegisterPopupWindow", string.format("%s 必须实现 Hide() 方法", module._NAME))
        else
            local HideCurrentPopupWindow = module.Hide
            module.Hide = function()
                -- while not unshownLimitedGoods:IsEmpty() do
                --     local iapGoodsInfo = unshownLimitedGoods:RemoveFirst()
                --     local config = TableMgr:GetGiftpackPopupConfig(iapGoodsInfo.id)

                --     if config then
                --         local popupWindow = config.popupWindow

                --         if popupWindow ~= currentPopupWindow then
                --             HideCurrentPopupWindow()
                --             SetCurrentPopupWindow(popupWindow)
                --         end

                --         popupWindows[popupWindow].Show(iapGoodsInfo)
                --         return
                --     end
                -- end

                while not unshownLimitedGoods:IsEmpty() do
                    local iapGoodsInfo = unshownLimitedGoods:RemoveFirst()
                    local goodID = iapGoodsInfo.id

                    local config = TableMgr:GetGiftpackPopupConfig(goodID)

                    if config and ConfigData.GetLimitedGiftPack(goodID) ~= iapGoodsInfo.endTime then
                        ConfigData.SetLimitedGiftPack(iapGoodsInfo)

                        local popupWindow = config.popupWindow

                        if popupWindow ~= currentPopupWindow then
                            HideCurrentPopupWindow()
                            SetCurrentPopupWindow(popupWindow)
                        end
                        
                        popupWindows[popupWindow].Show(iapGoodsInfo)

                        return
                    end
                end

                HideCurrentPopupWindow()
                SetCurrentPopupWindow(nil)
            end
        end

        popupWindows[id] = module
    end
end
--------------------------------------------------------------------------------------------------------------------

local isRequesting = false
function RequestData(type, callback, updateid)
    if not isRequesting then
        local request = ShopMsg_pb.MsgIAPGoodInfoRequest()
        request.type = type or 0

        isRequesting = true
        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPGoodInfoRequest, request, ShopMsg_pb.MsgIAPGoodInfoResponse, function(msg)
            isRequesting = false
            --Global.DumpMessage(msg, "d:/ddddd.lua")
            if msg.code == ReturnCode_pb.Code_OK then
                SetData(msg, request.type, updateid)
            end

            if callback then
                callback(msg)
            end
            
            MainCityUI.SetShopEnabled(true)
        end, true)
    end
end

function BuyGiftPack(iapGoodsInfo, callback)
    if iapGoodsInfo.priceType == 0 then
        store.StartPay(iapGoodsInfo, TextMgr:GetText(iapGoodsInfo.name))
    else
        local request = ShopMsg_pb.MsgCommonShopBuyPackageRequest()
        print(iapGoodsInfo.id)
        request.goodId = iapGoodsInfo.id
        request.num = 1

        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopBuyPackageRequest, request, ShopMsg_pb.MsgCommonShopBuyPackageResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                VipData.SetGiftData(msg.pkgInfos, msg.vipInfo.viplevel)
                MainData.UpdateVip(msg.vipInfo)

                MainCityUI.UpdateRewardData(msg.fresh)
                if #msg.reward.item.item ~= 0 or #msg.reward.hero.hero ~= 0 then
                    ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                    ItemListShowNew.SetItemShow(msg)

                    GUIMgr:CreateMenu("ItemListShowNew" , false)
                end
                if iapGoodsInfo.type == ShopMsg_pb.IAPGoodType_ZeroBuy then
                    iapGoodsInfo.hasBuy = true
                end
                RequestData()
            elseif msg.code == ReturnCode_pb.Code_DiamondNotEnough then
                Global.ShowNoEnoughMoney()
            else
                Global.FloatError(msg.code, Color.white)
            end

            if callback then
                callback(msg)
            end
        end)
    end
end

function ShowUnshownLimitedGoods()
    if not currentPopupWindow then
        while not unshownLimitedGoods:IsEmpty() do
            local iapGoodsInfo = unshownLimitedGoods:RemoveFirst()
            local goodID = iapGoodsInfo.id

            local config = TableMgr:GetGiftpackPopupConfig(goodID)

            if config and ConfigData.GetLimitedGiftPack(goodID) ~= iapGoodsInfo.endTime then
                ConfigData.SetLimitedGiftPack(iapGoodsInfo)

                local popupWindow = config.popupWindow

                if HideCurrentPopupWindow and popupWindow ~= currentPopupWindow then
                    HideCurrentPopupWindow()
                end

                SetCurrentPopupWindow(popupWindow)
                popupWindows[popupWindow].Show(iapGoodsInfo)

                return
            end
        end

        -- while not unshownLimitedGoods:IsEmpty() do
        --     local iapGoodsInfo = unshownLimitedGoods:RemoveFirst()
        --     local config = TableMgr:GetGiftpackPopupConfig(iapGoodsInfo.id)

        --     if config then
        --         SetCurrentPopupWindow(-1)

        --         NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_TimedGiftPack, function()
        --             if NotifyInfoData.HasNotifyPush(ClientMsg_pb.ClientNotifyType_TimedGiftPack) or NotifyInfoData.HaveAcitveNotify(ClientMsg_pb.ClientNotifyType_TimedGiftPack) then
        --                 local popupWindow = config.popupWindow

        --                 SetCurrentPopupWindow(popupWindow)
        --                 popupWindows[popupWindow].Show(iapGoodsInfo)
        --             else
        --                 SetCurrentPopupWindow(nil)
        --                 unshownLimitedGoods:RemoveAll()
        --             end
        --         end)

        --         return
        --     end
        -- end
    end
end

function Initialize()
    MainCityUI.SetShopEnabled(false)
    ResetData()
    RequestData(0, function(msg)
        EventDispatcher.Bind(Global.OnTick(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(now)
            if not limitedGoods:IsEmpty() then
                local iapGoodsInfo = limitedGoods:First()
                if iapGoodsInfo.endTime <= now then
                    RemoveData(iapGoodsInfo)
                end
            end
        end)

        store.InitializeData(msg)
        Goldstore_template3.RequestData()
    end)
end

function Test() -- GiftPackData.Test()
    MessageBox.Show("将开始测试，请不要点击鼠标", function()
        coroutine.start(function()
            print("----- RESET DATA -----")
            ResetData()

            coroutine.wait(1)
            print("----- SHOW UI -----")
            isRequesting = true
            Goldstore.Show(0)
            isRequesting = false

            coroutine.wait(3)
            print("----- TEST: REMOVE DATA -----")
            Test_RemoveData()

            coroutine.wait(6)
            print("----- TEST: SET DATA -----")
            Test_SetData()

            coroutine.wait(3)
            print("----- TEST: REQUEST DATA -----")
            RequestData(nil, function()
                MessageBox.Show("测试完成", function() end)
            end)
        end)
    end, function() end)
end

function DumpRequest() -- GiftPackData.DumpRequest()
    RequestData(0, function(msg)
        Global.DumpMessage(msg, "d:/MsgIAPGoodInfoResponse.lua")
    end)
end

function Test_SetData() -- GiftPackData.Test_SetData()
    local msg = {}

    msg.code = ReturnCode_pb.Code_OK
    msg.goodInfos = {}

    local goods1 = {}
    goods1.id = 622
    goods1.type = ShopMsg_pb.IAPGoodType_Gift
    goods1.priceType = 2
    goods1.price = 1000
    goods1.icon = "icon_act_24"
    goods1.backgroud = "icon_act_24"
    goods1.name = "Charge_622_name"
    goods1.topName = "Charge_622_name"
    goods1.recommend = false
    goods1.showPrice = 7540
    goods1.desc = ""
    goods1.subDesc = ""
    goods1.itemBuy = { item = { item = {}, }, }
    goods1.itemGift = { item = { item = {}, }, }
    goods1.endTime = 0
    goods1.count = { id = { id = 0,
                            subid = 0, },
                     count = 0,
                     countmax = 1,
                     refreshType = 0, }
    goods1.order = 49
    goods1.day = ""
    goods1.index = 19
    goods1.channelId = ""
    goods1.productId = ""
    goods1.guildChestId = 0
    goods1.tab = 2
    goods1.topName = ""
    goods1.discount = 1511
    goods1.hasBuy = false
    goods1.vipminlevel = 0
    goods1.vipmaxlevel = 0

    table.insert(msg.goodInfos, goods1)

    local goods2 = {}
    goods2.id = 612
    goods2.type = ShopMsg_pb.IAPGoodType_Gift
    goods2.priceType = 2
    goods2.price = 1000
    goods2.icon = "icon_act_23"
    goods2.backgroud = "icon_act_23"
    goods2.name = "Charge_612_name"
    goods1.topName = "Charge_612_name"
    goods2.recommend = false
    goods2.showPrice = 7520
    goods2.desc = ""
    goods2.subDesc = ""
    goods1.itemBuy = { item = { item = {}, }, }
    goods1.itemGift = { item = { item = {}, }, }
    goods2.endTime = 0
    goods2.count = { id = { id = 0,
                            subid = 0, },
                     count = 0,
                     countmax = 1,
                     refreshType = 0, }
    goods2.order = 50
    goods2.day = ""
    goods2.index = 12
    goods2.channelId = ""
    goods2.productId = ""
    goods2.guildChestId = 0
    goods2.tab = 2
    goods2.topName = ""
    goods2.discount = 1507
    goods2.hasBuy = false
    goods2.vipminlevel = 0
    goods2.vipmaxlevel = 0

    table.insert(msg.goodInfos, goods2)

    SetData(msg)
end

function Test_AddData() -- GiftPackData.Test_AddData()
    local goods1 = {}
    goods1.id = 622
    goods1.type = ShopMsg_pb.IAPGoodType_Gift
    goods1.priceType = 2
    goods1.price = 1000
    goods1.icon = "icon_act_24"
    goods1.backgroud = "icon_act_24"
    goods1.name = "Charge_622_name"
    goods1.topName = "Charge_622_name"
    goods1.recommend = false
    goods1.showPrice = 7540
    goods1.desc = ""
    goods1.subDesc = ""
    goods1.itemBuy = { item = { item = {}, }, }
    goods1.itemGift = { item = { item = {}, }, }
    goods1.endTime = 0
    goods1.count = { id = { id = 0,
                            subid = 0, },
                     count = 0,
                     countmax = 1,
                     refreshType = 0, }
    goods1.order = 49
    goods1.day = ""
    goods1.index = 19
    goods1.channelId = ""
    goods1.productId = ""
    goods1.guildChestId = 0
    goods1.tab = 7
    goods1.topName = ""
    goods1.discount = 1511
    goods1.hasBuy = false
    goods1.vipminlevel = 0
    goods1.vipmaxlevel = 0

    AddData(goods1)
end

function Test_RemoveData()
    Test_AddData()

    local goods1 = {}
    goods1.id = 622
    goods1.type = ShopMsg_pb.IAPGoodType_Gift
    goods1.priceType = 2
    goods1.price = 1000
    goods1.icon = "icon_act_24"
    goods1.backgroud = "icon_act_24"
    goods1.name = "Charge_622_name"
    goods1.topName = "Charge_622_name"
    goods1.recommend = false
    goods1.showPrice = 7540
    goods1.desc = ""
    goods1.subDesc = ""
    goods1.itemBuy = { item = { item = {}, }, }
    goods1.itemGift = { item = { item = {}, }, }
    goods1.endTime = 0
    goods1.count = { id = { id = 0,
                            subid = 0, },
                     count = 0,
                     countmax = 1,
                     refreshType = 0, }
    goods1.order = 49
    goods1.day = ""
    goods1.index = 19
    goods1.channelId = ""
    goods1.productId = ""
    goods1.guildChestId = 0
    goods1.tab = 2
    goods1.topName = ""
    goods1.discount = 1511
    goods1.hasBuy = false
    goods1.vipminlevel = 0
    goods1.vipmaxlevel = 0

    coroutine.start(function()
        coroutine.wait(3)
        RemoveData(goods1)
    end)
end

function Test_LimitedGiftPack() -- GiftPackData.Test_LimitedGiftPack()
    local r = math.random(1000, 10000)

    local goods1 = {}
    goods1.id = r
    goods1.type = ShopMsg_pb.IAPGoodType_GiftTimeLimit
    goods1.priceType = 2
    goods1.price = r
    goods1.icon = "icon_act_22"
    goods1.backgroud = "icon_act_22"
    goods1.name = "Charge_671_name"
    goods1.topName = "Charge_671_name"
    goods1.recommend = false
    goods1.showPrice = r
    goods1.desc = ""
    goods1.subDesc = ""
    goods1.itemBuy = { item = { item = {}, }, }
    goods1.itemGift = { item = { item = {}, }, }
    goods1.endTime = Serclimax.GameTime.GetSecTime() + 15
    goods1.count = { id = { id = 0,
                            subid = 0, },
                     count = 0,
                     countmax = 0,
                     refreshType = 0, }
    goods1.order = 1
    goods1.day = ""
    goods1.index = 58
    goods1.channelId = ""
    goods1.productId = ""
    goods1.guildChestId = 0
    goods1.tab = 1
    goods1.topName = ""
    goods1.discount = 100
    goods1.hasBuy = false
    goods1.vipminlevel = 0
    goods1.vipmaxlevel = 0

    AddData(goods1)
end
