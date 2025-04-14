module("Goldstore_template3", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

----- Event ----------------------------------------------------
local eventOnNoticeStatusChange = EventDispatcher.CreateEvent()

function OnNoticeStatusChange()
    return eventOnNoticeStatusChange
end

local function BroadcastEventOnNoticeStatusChange(...)
    EventDispatcher.Broadcast(eventOnNoticeStatusChange, ...)
end
----------------------------------------------------------------

----- Data --------
local items
local platformType
local _msg
local _config
-------------------

----- UI ------------------
local ui
local isInViewport = false
---------------------------

function IsInViewport()
    return isInViewport
end

local function OnUICameraClick(go)
    Tooltip.HideItemTip()
end

function OnDrag()
	--print("sv pos:".. ui.giftPackList.scrollView.transform.localPosition.x)
	if ui.itemList.arrow.gameObject.activeSelf then
		if ui.moveDistence - ui.itemList.scrollview.transform.localPosition.x > 300 then
			ui.itemList.arrow.gameObject:SetActive(false)
		end
	end
end


local function UpdateIapGoodsArrows(count)
	local itemWidth = ui.itemList.grid.cellWidth
	local panelWidth = ui.itemList.scrollview.panel.width
	
	local displayCount = math.ceil(panelWidth / itemWidth) 
	ui.itemList.arrow.gameObject:SetActive(count > displayCount)
	--print(itemWidth , panelWidth , displayCount , count)
end

local function LoadUI()
    if ui == nil then
        ui = {}

        ui.itemList = {}
        ui.itemList.items = {}
        ui.itemList.transform = transform:Find("Container/Scroll View/Grid")
        ui.itemList.gameObject = ui.itemList.transform.gameObject
        ui.itemList.grid = ui.itemList.transform:GetComponent("UIGrid")
        ui.itemList.scrollview = transform:Find("Container/Scroll View"):GetComponent("UIScrollView")
		ui.itemList.scrollview.onDragMove = OnDrag
		ui.itemList.arrow = transform:Find("Container/Panel")
		ui.moveDistence = ui.itemList.scrollview.transform.localPosition.x

        ui.newItem = transform:Find("Container/New Item").gameObject
        ui.newPack = transform:Find("Container/New Gift Pack").gameObject
        ui.coroutinelist = {}

        ui.btn_gift = transform:Find("Container/banner/Gift_free/btn_gift").gameObject
        ui.gift_Texture = ui.btn_gift:GetComponent("UITexture")
        ui.gift_text = transform:Find("Container/banner/Gift_free/btn_gift/Text"):GetComponent("UILabel")
        ui.btn_animator = ui.btn_gift:GetComponent("Animator")
        ui.btn_eff = transform:Find("Container/banner/Gift_free/btn_gift/SFX").gameObject
        ui.btn_bg_eff = transform:Find("Container/banner/Gift_free/Lizidian").gameObject
        ui.btn_collider = ui.btn_gift:GetComponent("BoxCollider")
        ui.gift_red = transform:Find("Container/banner/Gift_free/red").gameObject

        ui.toplabel = transform:Find("Container/banner/Label"):GetComponent("UILabel")
        ui.toplabel.text = TextMgr:GetText("daily_sale_ui1")
        ui.topdesc = transform:Find("Container/banner/tips01"):GetComponent("UILabel")
        ui.topdesc.text = TextMgr:GetText("daily_sale_ui4")
        ui.refreshtime = transform:Find("Container/banner/time (1)"):GetComponent("UILabel")
    end
end

local function UpdatePackItem(item, grid)
    local uiItem = {}

    uiItem.gameObject = NGUITools.AddChild(grid.gameObject, ui.newItem)
    uiItem.transform = uiItem.gameObject.transform

    uiItem.name = uiItem.transform:Find("name"):GetComponent("UILabel")
    uiItem.num = uiItem.transform:Find("num"):GetComponent("UILabel")
    uiItem.icon = uiItem.transform:Find("Texture"):GetComponent("UITexture")
    uiItem.piece = uiItem.transform:Find("Texture/piece"):GetComponent("UISprite")
    uiItem.frame = uiItem.transform:GetComponent("UISprite")

    uiItem.itemLevel = {}
    uiItem.itemLevel.transform = uiItem.transform:Find("bg_mid")
    uiItem.itemLevel.gameObject = uiItem.itemLevel.transform.gameObject
    uiItem.itemLevel.level = uiItem.itemLevel.transform:Find("Label"):GetComponent("UILabel")

    UIUtil.SetClickCallback(uiItem.frame.gameObject, function()
        if ui.tooltip ~= uiItem then
            local itemData = uiItem.itemData
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
        
            ui.tooltip = uiItem
        else
            ui.tooltip = nil
        end
    end)
    local itemData = TableMgr:GetItemData(item.baseid)
    uiItem.item = item
    uiItem.itemData = itemData

    uiItem.name.text = TextUtil.GetItemName(itemData)
    uiItem.num.text = "x" .. item.num
    uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)

    uiItem.piece.gameObject:SetActive(itemData.type == 54)
    uiItem.piece.spriteName = "piece" .. itemData.quality

    uiItem.frame.spriteName = "bg_item" .. itemData.quality

    if itemData.showType == 1 then
        uiItem.itemLevel.gameObject:SetActive(true)
        uiItem.itemLevel.level.text = Global.ExchangeValue2(itemData.itemlevel)
    elseif itemData.showType == 2 then
        uiItem.itemLevel.gameObject:SetActive(true)
        uiItem.itemLevel.level.text = Global.ExchangeValue1(itemData.itemlevel)
    elseif itemData.showType == 3 then
        uiItem.itemLevel.gameObject:SetActive(true)
        uiItem.itemLevel.level.text = Global.ExchangeValue3(itemData.itemlevel)
    else 
        uiItem.itemLevel.gameObject:SetActive(false)
    end
end


local function UpdateUI(id)
    if id == nil then
		local goodCount = 0
        for id, _ in kpairs(items) do
            UpdateUI(id)
			goodCount = goodCount + 1
        end
		UpdateIapGoodsArrows(goodCount)
        ui.itemList.grid:Reposition()
        ui.itemList.scrollview:ResetPosition()
    else
        local item = items[id]

        local uiItem = ui.itemList.items[id]
        if uiItem == nil then
            uiItem = {}
            uiItem.gameObject = NGUITools.AddChild(ui.itemList.gameObject, ui.newPack)
            uiItem.transform = uiItem.gameObject.transform
            uiItem.gameObject.name = item.order
            uiItem.name = uiItem.transform:Find("Top/Name"):GetComponent("UILabel")
            uiItem.price = uiItem.transform:Find("Buy Button/Text"):GetComponent("UILabel")
            uiItem.oriprice = uiItem.transform:Find("Original Price/Gold/Num"):GetComponent("UILabel")
            uiItem.discount = uiItem.transform:Find("Discount/Num"):GetComponent("UILabel")
        
            UIUtil.SetClickCallback(uiItem.transform:Find("Buy Button").gameObject, function()
                store.StartPay(item, TextMgr:GetText(item.name))
            end)

            ui.itemList.items[id] = uiItem
            uiItem.name.text = TextMgr:GetText(item.name)
            uiItem.oriprice.text = item.showPrice
            uiItem.discount.text = item.discount .. "%"

            if platformType == LoginMsg_pb.AccType_adr_huawei then
                uiItem.price.text = "SGD$" .. item.price
            elseif platformType == LoginMsg_pb.AccType_adr_tmgp or
            Global.IsIosMuzhi() or
            platformType == LoginMsg_pb.AccType_adr_muzhi or
            platformType == LoginMsg_pb.AccType_adr_opgame or
            platformType == LoginMsg_pb.AccType_adr_mango or
            platformType == LoginMsg_pb.AccType_adr_official or
            platformType == LoginMsg_pb.AccType_ios_official or
            platformType == LoginMsg_pb.AccType_adr_official_branch or
            platformType == LoginMsg_pb.AccType_adr_quick or
            platformType == LoginMsg_pb.AccType_adr_qihu then
                uiItem.price.text = "RMB￥" .. item.price
            else
                uiItem.price.text = "US$" .. item.price
            end

            uiItem.grid = uiItem.transform:Find("Scroll View/Grid"):GetComponent("UIGrid")

            for i, v in ipairs(item.itemBuy.item.item) do
                UpdatePackItem(v, uiItem.grid)
            end
            for i, v in ipairs(item.itemGift.item.item) do
                UpdatePackItem(v, uiItem.grid)
            end

            uiItem.grid:Reposition()

            uiItem.limit = uiItem.transform:Find("Purchase Limit/Label"):GetComponent("UILabel")

            uiItem.soldout = uiItem.transform:Find("Sold Out Mask").gameObject
            uiItem.countdown = uiItem.transform:Find("Sold Out Mask/bg/time"):GetComponent("UILabel")
            local coro = coroutine.start(function()
                while true do
                    uiItem.countdown.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown())
                    coroutine.wait(1)
                end
            end)
            table.insert(ui.coroutinelist, coro)
        end
        uiItem.limit.text = System.String.Format(TextMgr:GetText("pay_ui14"), item.count.count, item.count.countmax)
        uiItem.soldout:SetActive(item.count.count == 0)
    end
end

function SuccessfullyPurchase(id)
    if isInViewport and items[id] then
        items[id].count.count = items[id].count.count - 1
        UpdateUI(id)
    end
end

local function UpdateTop(cantake)
    UIUtil.SetClickCallback(ui.btn_gift, cantake and function()
        local request = ShopMsg_pb.MsgIAPTakeDailyChestRequest()
        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeDailyChestRequest, request, ShopMsg_pb.MsgIAPTakeDailyChestResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                _msg.canTakeDailyChest = false
                Global.ShowReward(msg.reward)
                MainCityUI.UpdateRewardData(msg.fresh)
                Global.GAudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
                UpdateTop(false)
            end
        end)
    end or function() end)
    ui.gift_Texture.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", cantake and "act_dailysale" or "act_dailysale_hui")
    ui.gift_red:SetActive(cantake)
    ui.gift_text.text = TextMgr:GetText(cantake and "daily_sale_ui3" or "daily_sale_ui2")
    ui.btn_animator.enabled = cantake
    ui.btn_eff:SetActive(cantake)
    ui.btn_collider.enabled = cantake
    ui.btn_bg_eff:SetActive(cantake)
    coroutine.stop(ui.countdowncoroutine)
    ui.countdowncoroutine = coroutine.start(function()
        local timer = Global.GetLeftCooldownSecond(Global.GetFiveOclockCooldown()) + 2
        while true do
            ui.refreshtime.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown())
            if timer <= 0 then
                Show()
            else
                timer = timer - 1
            end
            coroutine.wait(1)
        end
    end)
    BroadcastEventOnNoticeStatusChange()
end

function Show()
    RequestData(function(msg)
        if isInViewport then
            items = {}
            for _, iapGoodInfo in ipairs(msg.goodInfos) do
                GiftPackData.ExchangePrice(iapGoodInfo)
                items[iapGoodInfo.id] = iapGoodInfo
            end
            if ui then
                UpdateUI()
                UpdateTop(msg.canTakeDailyChest)
            end
        end
    end)

    platformType = GUIMgr:GetPlatformType()
    if not isInViewport then
        Global.OpenUI(_M)
    end
end

function HideAll()
    Goldstore.Hide()
end

function Hide()
    if isInViewport then
        Global.CloseUI(_M)
    end
end

function Start()
    isInViewport = true
    UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)
    LoadUI()
end

function Close()
    UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    coroutine.stop(ui.countdowncoroutine)
    isInViewport = false
    for i, v in ipairs(ui.coroutinelist) do
        coroutine.stop(v)
    end
    items = nil
    platformType = nil

    ui = nil
end

function RequestData(callback)
    local request = ShopMsg_pb.MsgIAPGoodInfoRequest()
    request.type = 10
    Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPGoodInfoRequest, request, ShopMsg_pb.MsgIAPGoodInfoResponse, function(msg)
        if callback ~= nil then
            callback(msg)
        end
        _msg = msg
    end)
end

----- Template:Goldstore -------------------------------
function HasNotice(config)
    _config = config
    return _msg.canTakeDailyChest
end

function IsAvailable(config)
    local _config = config
    return #_msg.goodInfos > 0
end

Goldstore.RegisterAsTemplate(7, _M)
--------------------------------------------------------
