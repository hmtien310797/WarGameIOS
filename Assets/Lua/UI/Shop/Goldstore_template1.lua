module("Goldstore_template1", package.seeall)

local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local ui
local currentConfig
local currentTabID

----- Events ---------------------------------------------------
local eventOnAvailabilityChange = EventDispatcher.CreateEvent()

function OnNoticeStatusChange(config)
    return GiftPackData.OnHistoryStatusChange()
end

function OnAvailabilityChange(config)
    return eventOnAvailabilityChange
end

local function BroadcastEventOnAvailabilityChange(...)
    EventDispatcher.Broadcast(eventOnAvailabilityChange, ...)
end

EventDispatcher.Bind(GiftPackData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(iapGoodsInfo, change)
    if change ~= 0 then
        BroadcastEventOnAvailabilityChange()
    end
end)
----------------------------------------------------------------

function IsInViewport()
    return ui ~= nil
end

local function SetCurrentConfig(config)
    currentConfig = config
end

local function SetCurrentTabID(id)
    currentTabID = id
end

local function UpdateGiftPackPurchaseLimit(uiGiftPack)
    local iapGoodsInfo = uiGiftPack.iapGoodsInfo

    if iapGoodsInfo.count and iapGoodsInfo.count.countmax > 0 and iapGoodsInfo.count.count >= 0 then
        uiGiftPack.purchaseLimit.gameObject:SetActive(true)

        if iapGoodsInfo.count.refreshType == Common_pb.LimitRefreshType_Day then
            uiGiftPack.purchaseLimit.label.text = System.String.Format(TextMgr:GetText("pay_ui14"), iapGoodsInfo.count.count, iapGoodsInfo.count.countmax)
        elseif iapGoodsInfo.count.refreshType == Common_pb.LimitRefreshType_Week then
            uiGiftPack.purchaseLimit.label.text = System.String.Format(TextMgr:GetText("pay_ui15"), iapGoodsInfo.count.count, iapGoodsInfo.count.countmax)
        elseif iapGoodsInfo.count.refreshType == Common_pb.LimitRefreshType_Month then
            uiGiftPack.purchaseLimit.label.text = System.String.Format(TextMgr:GetText("pay_ui16"), iapGoodsInfo.count.count, iapGoodsInfo.count.countmax)
        elseif iapGoodsInfo.count.refreshType == Common_pb.LimitRefreshType_Year then
            uiGiftPack.purchaseLimit.label.text = System.String.Format(TextMgr:GetText("pay_ui17"), iapGoodsInfo.count.count, iapGoodsInfo.count.countmax)
        elseif iapGoodsInfo.count.refreshType == Common_pb.LimitRefreshType_Forever then
            uiGiftPack.purchaseLimit.label.text = System.String.Format(TextMgr:GetText("pay_ui3"), iapGoodsInfo.count.count, iapGoodsInfo.count.countmax)
        end

        uiGiftPack.soldOut:SetActive(iapGoodsInfo.count.count == 0)
    elseif iapGoodsInfo.globalLimit > 0 then
		uiGiftPack.purchaseLimit.gameObject:SetActive(true)
		uiGiftPack.purchaseLimit.label.text = System.String.Format(TextMgr:GetText("global_gift_3") ,math.max( 0, iapGoodsInfo.globalLimit - iapGoodsInfo.globalBuy) , iapGoodsInfo.globalLimit )
	else
        uiGiftPack.purchaseLimit.gameObject:SetActive(false)
        uiGiftPack.soldOut:SetActive(false)
    end
end

local function UpdateGiftPackNotice(uiGiftPack)
end

local function UpdateGiftPackCountdown(uiGiftPack)
    if uiGiftPack.iapGoodsInfo then
        uiGiftPack.countdown.time.text = Global.SecondToTimeLong(uiGiftPack.iapGoodsInfo.endTime - ui.lastUpdateTime)
    end
end

local function LoadItem(uiItem , item)
	local itemData = TableMgr:GetItemData(item.baseid)
	uiItem.item = item
	uiItem.itemData = itemData
	
	uiItem.name.text = TextUtil.GetItemName(itemData)
	uiItem.num.text = "x" .. item.num
	uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
	uiItem.heroInfo.level.gameObject:SetActive(false)
	uiItem.heroInfo.star.gameObject:SetActive(false)
	
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
	
	UIUtil.SetClickCallback(uiItem.frame.gameObject, function()
		if ui.tooltip ~= uiItem then
            local itemData = uiItem.itemData
            if itemData.type==3 and itemData.subtype==5  then 
                BoxDetails.Show(tableData_tOptionalPack.data[itemData.param1].RewardItem)
            else
                BoxDetails.Hide()
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                ui.tooltip = uiItem
            end 
		else
			ui.tooltip = nil
		end
	end)
end

local function LoadHero(uiItem , hero)
	local heroData = TableMgr:GetHeroData(hero.baseid)
	uiItem.item = hero
	uiItem.itemData = heroData
	
	uiItem.name.text = TextMgr:GetText(heroData.nameLabel)
	uiItem.num.text = "x" .. hero.num
	uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", heroData.icon)
	
	uiItem.piece.gameObject:SetActive(false)
	uiItem.frame.spriteName = "bg_item" .. heroData.quality
	uiItem.itemLevel.gameObject:SetActive(false)
	
	uiItem.heroInfo.level.gameObject:SetActive(true)
	uiItem.heroInfo.star.gameObject:SetActive(true)
	uiItem.heroInfo.level.text = hero.level
	uiItem.heroInfo.star.width = Mathf.Clamp( uiItem.heroInfo.star.width , 0 , hero.star * 30)
	
	UIUtil.SetClickCallback(uiItem.frame.gameObject, function()
		if ui.tooltip ~= uiItem then
			local itemData = uiItem.itemData
			--Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
			Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
            BoxDetails.Hide()
			ui.tooltip = uiItem
		else
			ui.tooltip = nil
		end
	end)
	
end

local function LoadArmy(uiItem , army)
	local soldierData = TableMgr:GetBarrackData(army.baseid, army.level)
	uiItem.item = army
	uiItem.itemData = soldierData
	
	uiItem.name.text = TextMgr:GetText(soldierData.SoldierName)
	uiItem.num.text = "x" .. army.num
	uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
	uiItem.heroInfo.level.gameObject:SetActive(false)
	uiItem.heroInfo.star.gameObject:SetActive(false)
	
	uiItem.piece.gameObject:SetActive(false)
	uiItem.frame.spriteName = "bg_item" .. army.level + 1
	
	uiItem.itemLevel.transform.gameObject:SetActive(false)
	
	UIUtil.SetClickCallback(uiItem.frame.gameObject, function()
		if ui.tooltip ~= uiItem then
			local itemData = uiItem.itemData
			Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
            BoxDetails.Hide()
			ui.tooltip = uiItem
		else
			ui.tooltip = nil
		end
	end)
	
end

local function UpdateGiftPack(uiGiftPack, iapGoodsInfo)
    uiGiftPack.iapGoodsInfo = iapGoodsInfo
    GiftPackData.ExchangePrice(iapGoodsInfo)
    uiGiftPack.gameObject:SetActive(true)
    local sorder = 0
    if iapGoodsInfo.bmsOrder > 0 then
        local size = math.floor(iapGoodsInfo.bmsOrder / 100)
        local mlevel = iapGoodsInfo.bmsOrder % 100
        sorder = math.abs(MainData.GetLevel() - mlevel + ui.sorder_step)
    end
    uiGiftPack.gameObject.name = ((iapGoodsInfo.count.countmax <= 0 or iapGoodsInfo.count.count > 0) and 10000 or 20000) + (sorder * 100) + iapGoodsInfo.order
    
    uiGiftPack.name.text = TextMgr:GetText(iapGoodsInfo.topName)
    uiGiftPack.icon.mainTexture = ResourceLibrary:GetIcon("pay/", iapGoodsInfo.icon)

    uiGiftPack.originalPrice.text = iapGoodsInfo.showPrice

    if iapGoodsInfo.priceType == 0 then
        uiGiftPack.currency.gameObject:SetActive(false)
        uiGiftPack.currency.price.text = string.make_price(iapGoodsInfo.price)

        uiGiftPack.actualPrice.text = ""
    else
        uiGiftPack.currency.gameObject:SetActive(true)
        uiGiftPack.currency.icon.spriteName = UIUtil.GetCurrencySprite(iapGoodsInfo.priceType)
        uiGiftPack.currency.price.text = ""

        uiGiftPack.actualPrice.text = iapGoodsInfo.price
    end

    uiGiftPack.discount.text = System.String.Format(TextMgr:GetText("ui_discount"), iapGoodsInfo.discount)

	
	-------
	local items = {}
    -----支持将军整卡和部队
	if iapGoodsInfo.itemOther.hero ~= nil and iapGoodsInfo.itemOther.hero.hero ~= nil then
		for i, v in ipairs(iapGoodsInfo.itemOther.hero.hero) do
			table.insert(items, {data=v , _type="hero"})
		end
	end
	
	if iapGoodsInfo.itemOther.army ~= nil and iapGoodsInfo.itemOther.army.army ~= nil then
		for i, v in ipairs(iapGoodsInfo.itemOther.army.army) do
			table.insert(items, {data=v , _type="army"})
		end
	end
	
    for i, v in ipairs(iapGoodsInfo.itemBuy.item.item) do
        table.insert(items, {data=v , _type="item"})
    end
    for i, v in ipairs(iapGoodsInfo.itemGift.item.item) do
        table.insert(items, {data=v , _type="item"})
    end
	
    local uiItems = uiGiftPack.itemList.items
    local numItems = #items
    for i = 1, math.max(numItems, #uiItems) do
        if i > numItems then
            uiItems[i].gameObject:SetActive(false)
        else
            if i > #uiItems then
                local uiItem = {}

                uiItem.gameObject = NGUITools.AddChild(uiGiftPack.itemList.gameObject, ui.newItem)
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
				
				uiItem.heroInfo = {}
				uiItem.heroInfo.level = uiItem.transform:Find("level text"):GetComponent("UILabel")
				uiItem.heroInfo.star = uiItem.transform:Find("star"):GetComponent("UISprite")
				
                table.insert(uiItems, uiItem)
            else
                uiItems[i].gameObject:SetActive(true)
            end

            local uiItem = uiItems[i]
            local item = items[i]
			
			if item._type == "item" then
				LoadItem(uiItem , item.data)
			elseif item._type == "hero" then
				LoadHero(uiItem , item.data)
			elseif item._type == "army" then
				LoadArmy(uiItem , item.data)
			end
        end
    end
    uiGiftPack.itemList.grid:Reposition()
    uiGiftPack.itemList.scrollView:ResetPosition()

    if iapGoodsInfo.vipminlevel > 0 then
        uiGiftPack.vipPrerequisite.gameObject:SetActive(true)
        uiGiftPack.vipPrerequisite.text = System.String.Format(TextMgr:GetText("store_13"), VIP.GetVipInfo() < iapGoodsInfo.vipminlevel and "[ff0000]" or "[00ff00]", iapGoodsInfo.vipminlevel - 1)
    else
        uiGiftPack.vipPrerequisite.gameObject:SetActive(false)
    end

    UpdateGiftPackPurchaseLimit(uiGiftPack)
    UpdateGiftPackNotice(uiGiftPack)

    if iapGoodsInfo.endTime > ui.lastUpdateTime then
        uiGiftPack.countdown.gameObject:SetActive(true)

        UpdateGiftPackCountdown(uiGiftPack)

        ConfigData.SetLimitedGiftPack(iapGoodsInfo)
    else
        uiGiftPack.countdown.gameObject:SetActive(false)
    end

    GiftPackData.SetHistoryStatus(iapGoodsInfo, false)

    ui.giftPackList.giftPacksByID[iapGoodsInfo.id] = uiGiftPack
end

local function AddGiftPack(iapGoodsInfo)
    local reuseableUIs = ui.giftPackList.reuseableUIs

    local uiGiftPack
    if reuseableUIs:IsEmpty() then
        uiGiftPack = {}

        uiGiftPack.gameObject = NGUITools.AddChild(ui.giftPackList.gameObject, ui.giftPackList.newGiftpack)
        uiGiftPack.transform = uiGiftPack.gameObject.transform
        
        uiGiftPack.name = uiGiftPack.transform:Find("Top/Name"):GetComponent("UILabel")
        uiGiftPack.icon = uiGiftPack.transform:Find("Icon"):GetComponent("UITexture")

        uiGiftPack.originalPrice = uiGiftPack.transform:Find("Original Price/Gold/Num"):GetComponent("UILabel")
        uiGiftPack.actualPrice = uiGiftPack.transform:Find("Buy Button/Gold/Num"):GetComponent("UILabel")
        uiGiftPack.discount = uiGiftPack.transform:Find("Discount/Num"):GetComponent("UILabel")

        uiGiftPack.currency = {}
        uiGiftPack.currency.transform = uiGiftPack.transform:Find("Buy Button/Gold")
        uiGiftPack.currency.gameObject = uiGiftPack.currency.transform.gameObject
        uiGiftPack.currency.icon = uiGiftPack.currency.transform:GetComponent("UISprite")
        uiGiftPack.currency.price = uiGiftPack.transform:Find("Buy Button/Text"):GetComponent("UILabel")
        uiGiftPack.currency.price.transform.localPosition = Vector3(35, 0, 0)
        
        uiGiftPack.itemList = UIUtil.LoadList(uiGiftPack.transform:Find("Scroll View"))
        uiGiftPack.itemList.items = {}

        uiGiftPack.vipPrerequisite = uiGiftPack.transform:Find("Top/Vip Prerequisite"):GetComponent("UILabel")

        uiGiftPack.purchaseLimit = {}
        uiGiftPack.purchaseLimit.transform = uiGiftPack.transform:Find("Purchase Limit")
        uiGiftPack.purchaseLimit.gameObject = uiGiftPack.purchaseLimit.transform.gameObject
        uiGiftPack.purchaseLimit.label = uiGiftPack.purchaseLimit.transform:Find("Label"):GetComponent("UILabel")

        uiGiftPack.countdown = {}
        uiGiftPack.countdown.transform = uiGiftPack.transform:Find("Countdown")
        uiGiftPack.countdown.gameObject = uiGiftPack.countdown.transform.gameObject
        uiGiftPack.countdown.time = uiGiftPack.countdown.transform:Find("Time"):GetComponent("UILabel")

        uiGiftPack.soldOut = uiGiftPack.transform:Find("Sold Out Mask").gameObject

        UIUtil.SetClickCallback(uiGiftPack.transform:Find("Buy Button").gameObject, function()
            local iapGoodsInfo = uiGiftPack.iapGoodsInfo

            -- if iapGoodsInfo.count.countmax <= 0 or iapGoodsInfo.count.count > 0 then
                -- local vipLevel = MainData.GetVipLevel()

                -- if iapGoodsInfo.vipminlevel ~= 0 and (vipLevel < iapGoodsInfo.vipminlevel or vipLevel > iapGoodsInfo.vipmaxlevel) then
                --     MessageBox.Show(TextMgr:GetText("store_14"))
                -- else
                    MessageBox.ShowConfirmation(iapGoodsInfo.priceType ~= 0, System.String.Format(TextMgr:GetText("purchase_confirmation"), uiGiftPack.actualPrice.text, uiGiftPack.name.text), function()
                        GiftPackData.BuyGiftPack(iapGoodsInfo)
                    end)
                -- end
            -- else
            --     MessageBox.Show("[临时] Sold Out") -- TODO
            -- end
        end)

        table.insert(ui.giftPackList.giftPacks, uiGiftPack)
    else
        uiGiftPack = reuseableUIs:Pop()
    end

    UpdateGiftPack(uiGiftPack, iapGoodsInfo)
end

local function RemoveGiftPack(iapGoodsInfo)
    local uiGiftPacks = ui.giftPackList.giftPacks
    for i = 1, #uiGiftPacks do
        local uiGiftPack = uiGiftPacks[i]
        if uiGiftPack.iapGoodsInfo.id == iapGoodsInfo.id then
            uiGiftPack.gameObject:SetActive(false)
            uiGiftPack.iapGoodsInfo = nil
  
            table.remove(uiGiftPacks, i)
            table.insert(uiGiftPacks, uiGiftPack)

            ui.giftPackList.giftPacksByID[iapGoodsInfo.id] = nil

            ui.giftPackList.reuseableUIs:Push(uiGiftPack)

            return
        end
    end
end

local function SortGiftPacks()
    table.sort(ui.giftPackList.giftPacks, function(uiGiftPackA, uiGiftPackB)
        local iapGoodsInfoA = uiGiftPackA.iapGoodsInfo
        local iapGoodsInfoB = uiGiftPackB.iapGoodsInfo

        if not iapGoodsInfoA or not iapGoodsInfoB then
            return iapGoodsInfoA ~= nil
        end

        local countA = iapGoodsInfoA.count
        local countB = iapGoodsInfoB.count

        local canPurchaseA = countA.countmax <= 0 or countA.count > 0
        local canPurchaseB = countB.countmax <= 0 or countB.count > 0

        if canPurchaseA ~= canPurchaseB then
            return canPurchaseA
        end

        if iapGoodsInfoA.order ~= iapGoodsInfoB.order then
            return iapGoodsInfoA.order < iapGoodsInfoB.order
        end

        return iapGoodsInfoA.id < iapGoodsInfoB.id
    end)

    ui.giftPackList.grid.repositionNow = true
end

local function UpdateIapGoodsArrows(count)
	local itemWidth = ui.giftPackList.grid.cellWidth
	local panelWidth = ui.giftPackList.scrollView.panel.width
	
	local displayCount = math.ceil(panelWidth / itemWidth) 
	ui.giftPackList.arrow.gameObject:SetActive(count > displayCount)
	--print(itemWidth , panelWidth , displayCount , count)
end

local function UpdateGiftPackList(iapGoodsInfos)
    local uiGiftPacks = ui.giftPackList.giftPacks

	ui.giftPackList.reuseableUIs = DataStack()
	
    local reuseableUIs = ui.giftPackList.reuseableUIs
    for i = #uiGiftPacks, 1, -1 do
        local uiGiftPack = uiGiftPacks[i]

        uiGiftPack.gameObject:SetActive(false)
        uiGiftPack.iapGoodsInfo = nil

        reuseableUIs:Push(uiGiftPack)
    end

    if ui.sorder_step == nil then
        local templevel = 0
        for _, iapGoodsInfo in pairs(iapGoodsInfos) do
            local sorder = 0
            if iapGoodsInfo.bmsOrder > 0 then
                local size = math.floor(iapGoodsInfo.bmsOrder / 100)
                local mlevel = iapGoodsInfo.bmsOrder % 100
                if size == 1 and templevel == 0 then
                    templevel = mlevel
                elseif size == 2 and templevel ~= 0 then
                    ui.sorder_step = (mlevel - templevel) / 2
				elseif size == 3 and templevel ~= 0 then
                    ui.sorder_step = (mlevel - templevel) / 2
                end
            end
        end
    end

	local goodCount = 0
    for _, iapGoodsInfo in pairs(iapGoodsInfos) do
        AddGiftPack(iapGoodsInfo)
		goodCount = goodCount + 1
    end

	UpdateIapGoodsArrows(goodCount)
    SortGiftPacks()
end

local function ShowTab(tabID)
    SetCurrentTabID(tabID)

    ui.tabList.tabsByID[tabID].toggle.value = true

    UpdateGiftPackList(GiftPackData.GetAvailableGoodsByTab(tabID))

    ui.giftPackList.scrollView:ResetPosition()
end

local function ShowTabByOrder(order)
    ShowTab(ui.tabList.tabs[1].config.id)
end

local function UpdateTabNotice(uiTab)
    if uiTab then
        uiTab.notice:SetActive(GiftPackData.HasNewGoods(uiTab.config.id))
    else
        for _, uiTab in pairs(ui.tabList.tabsByID) do
            UpdateTabNotice(uiTab)
        end
    end
end

local function UpdateTabCountdown(uiTab)
	if uiTab then
		uiTab.countdown.time.text = Global.SecondToTimeLong(ui.limitedGiftPacks[uiTab.config.id]:First().endTime - ui.lastUpdateTime)
	end
end

local function AddLimitedGiftPack(iapGoodsInfo)
    local tabID = iapGoodsInfo.tab
    local limitedGiftPacks = ui.limitedGiftPacks

    if not limitedGiftPacks[tabID] then
        limitedGiftPacks[tabID] = SortedList(nil, function(iapGoodsInfo1, iapGoodsInfo2)
            if iapGoodsInfo1.id == iapGoodsInfo2.id then
                return 0
            else
                return iapGoodsInfo1.endTime < iapGoodsInfo2.endTime and -1 or 1
            end
        end)
		
		if ui.tabList.tabsByID[tabID] ~= nil then
			ui.tabList.tabsByID[tabID].countdown.gameObject:SetActive(true)
		end
    end

    limitedGiftPacks[tabID]:Insert(iapGoodsInfo)
end

local function RemoveLimitedGiftPack(iapGoodsInfo)
    local tabID = iapGoodsInfo.tab
    local limitedGiftPacks = ui.limitedGiftPacks

    limitedGiftPacks[tabID]:RemoveFirst(function(_iapGoodsInfo)
        return _iapGoodsInfo.id == iapGoodsInfo.id
    end)

    if limitedGiftPacks[tabID]:IsEmpty() then
        limitedGiftPacks[tabID] = nil
        ui.tabList.tabsByID[tabID].countdown.gameObject:SetActive(false)
    end
end

local function UpdateTab(uiTab, config)
    uiTab.config = config

    uiTab.gameObject:SetActive(true)
    uiTab.gameObject.name = 10000 + config.order

    local tabName = TextMgr:GetText(config.name)
    uiTab.name.text = tabName
    uiTab.selected.name.text = tabName

    UpdateTabNotice(uiTab)

    if ui.limitedGiftPacks[config.id] then
        UpdateTabCountdown(uiTab)
        uiTab.countdown.gameObject:SetActive(true)
    else
        uiTab.countdown.gameObject:SetActive(false)
    end

    ui.tabList.tabsByID[config.id] = uiTab
end

local function AddTab(config)
    local reuseableUIs = ui.tabList.reuseableUIs

    local uiTab
    if reuseableUIs:IsEmpty() then
        uiTab = {}

        uiTab.gameObject = NGUITools.AddChild(ui.tabList.gameObject, ui.tabList.newTab)
        uiTab.transform = uiTab.gameObject.transform

        uiTab.name = uiTab.transform:Find("Name"):GetComponent("UILabel")
        uiTab.icon = uiTab.transform:Find("Icon"):GetComponent("UITexture")

        uiTab.selected = {}
        uiTab.selected.transform = uiTab.transform:Find("Selected")
        uiTab.selected.gameObject = uiTab.selected.transform.gameObject
        uiTab.selected.name = uiTab.selected.transform:Find("Name"):GetComponent("UILabel")
        uiTab.selected.icon = uiTab.selected.transform:Find("Icon"):GetComponent("UITexture")

        uiTab.countdown = {}
        uiTab.countdown.transform = uiTab.transform:Find("Countdown")
        uiTab.countdown.gameObject = uiTab.countdown.transform.gameObject
        uiTab.countdown.time = uiTab.countdown.transform:Find("Time"):GetComponent("UILabel")

        uiTab.notice = uiTab.transform:Find("Notice").gameObject
        uiTab.toggle = uiTab.transform:GetComponent("UIToggle")

        UIUtil.SetClickCallback(uiTab.gameObject, function()
            ShowTab(uiTab.config.id)
        end)

        table.insert(ui.tabList.tabs, uiTab)
    else
        uiTab = reuseableUIs:Pop()
    end

    UpdateTab(uiTab, config)
end

local function RemoveTab(tabID)
    local uiTabs = ui.tabList.tabs
    for i = 1, #uiTabs do
        local uiTab = uiTabs[i]
        if uiTab.config and uiTab.config.id == tabID then
            uiTab.gameObject:SetActive(false)
            uiTab.config = nil
  
            table.remove(uiTabs, i)
            table.insert(uiTabs, uiTab)

            ui.tabList.tabsByID[tabID] = nil

            ui.tabList.reuseableUIs:Push(uiTab)

            if currentTabID == tabID then
                ShowTabByOrder(uiTabs[i].config and i or i - 1)
            end

            return
        end
    end
end

local function SortTabs()
    table.sort(ui.tabList.tabs, function(uiTabA, uiTabB)
        local configA = uiTabA.config
        local configB = uiTabB.config

        if not configA or not configB then
            return configA ~= nil
        end

        if configA.order ~= configB.order then
            return configA.order < configB.order
        end

        return configA.id < configB.id
    end)

    ui.tabList.grid.repositionNow = true
end

local function UpdateTabList()
    local uiTabs = ui.tabList.tabs

	ui.tabList.reuseableUIs:Clear()
    for i = #uiTabs, 1, -1 do
        local uiTab = uiTabs[i]

        uiTab.gameObject:SetActive(false)
        uiTab.config = nil

        ui.tabList.reuseableUIs:Push(uiTab)
    end

    ui.tabList.tabsByID = {}
    ui.limitedGiftPacks = {}

    local currentConfigID = currentConfig.id
    for tabID, config in pairs(TableMgr:GetGiftpackTabConfig()) do
        if math.floor(tabID / 100) == currentConfigID then
            if GiftPackData.HasAvailableGoods(tabID) then
                AddTab(config)
            end
        end
    end

    for _, iapGoodsInfo in pairs(GiftPackData.GetLimitedGoods()) do
        if math.floor(iapGoodsInfo.tab / 100) == currentConfig.id then
            AddLimitedGiftPack(iapGoodsInfo)
        end
    end

    for tabID, _ in pairs(ui.limitedGiftPacks) do
        UpdateTabCountdown(ui.tabList.tabsByID[tabID])
    end

    SortTabs()
end

local function Redraw()
    UpdateTabList()
    ui.tabList.scrollView:ResetPosition()

    if currentTabID then
        ShowTab(currentTabID)
    else
        ShowTabByOrder(1)
    end
end

function Show(config, tabID)
    if IsInViewport() then
        if config ~= currentConfig then
            SetCurrentConfig(config)
            SetCurrentTabID(tabID)
            Redraw()
        elseif tabID ~= currentTabID then
            ShowTab(tabID)
        end
    else
        SetCurrentConfig(config)
        SetCurrentTabID(tabID)

        Global.OpenUI(_M)
    end
end

function HideAll()
    Goldstore.Hide()
end

function Hide()
    Global.CloseUI(_M)
end

local function OnUICameraClick(go)
    Tooltip.HideItemTip()
    BoxDetails.Hide()
end


function OnDrag()
	--print("sv pos:".. ui.giftPackList.scrollView.transform.localPosition.x)
	if ui.giftPackList.arrow.gameObject.activeSelf then
		if ui.moveDistence - ui.giftPackList.scrollView.transform.localPosition.x > 300 then
			ui.giftPackList.arrow.gameObject:SetActive(false)
		end
	end
end

function Awake()
    local tabList = UIUtil.LoadList(transform:Find("Container/Top/tab_bg/Scroll View"))
    tabList.newTab = transform:Find("Container/Top/New Tab").gameObject
    tabList.tabsByID = {}
    tabList.tabs = {}
    tabList.tabsWithCountdown = {}
    tabList.reuseableUIs = DataStack()

    local giftPackList = UIUtil.LoadList(transform:Find("Container/Scroll View"))
	giftPackList.scrollView.onDragMove =  OnDrag
	giftPackList.grid =  giftPackList.scrollView.transform:Find("Grid"):GetComponent("UIGrid")
    giftPackList.newGiftpack = transform:Find("Container/New Gift Pack").gameObject
	giftPackList.arrow = transform:Find("Container/Panel")
    giftPackList.giftPacksByID = {}
    giftPackList.giftPacks = {}
    giftPackList.reuseableUIs = DataStack()

    ui = {}

    ui.tabList = tabList
    ui.giftPackList = giftPackList
    ui.newItem = transform:Find("Container/New Item").gameObject
	ui.moveDistence = ui.giftPackList.scrollView.transform.localPosition.x

    ui.tabList.panel:Update()
    ui.giftPackList.panel:Update()

    UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)

    EventDispatcher.Bind(GiftPackData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(iapGoodsInfo, change)
        local tabID = iapGoodsInfo.tab
        if math.floor(tabID / 100) == currentConfig.id then
            if iapGoodsInfo.endTime ~= 0 then
                if change > 0 then
                    AddLimitedGiftPack(iapGoodsInfo)
                elseif change < 0 then
                    RemoveLimitedGiftPack(iapGoodsInfo)
                end
            end

            if not GiftPackData.HasAvailableGoods(tabID) then
                RemoveTab(tabID)
                ui.tabList.grid.repositionNow = true
            else
                if tabID == currentTabID then
                    if change == 0 then
                        UpdateGiftPack(ui.giftPackList.giftPacksByID[iapGoodsInfo.id], iapGoodsInfo)
                        UpdateGiftPackPurchaseLimit(ui.giftPackList.giftPacksByID[iapGoodsInfo.id])
                    elseif change > 0 then
                        AddGiftPack(iapGoodsInfo)
                        SortGiftPacks()
                    else
                        RemoveGiftPack(iapGoodsInfo)
                        ui.giftPackList.grid.repositionNow = true
                        ui.giftPackList.scrollView:MoveRelative(Vector3(1,0,0))
                    end
                else
                    if change > 0 and GiftPackData.GetAvailableGoodsCount(tabID) == 1 then
                        local config = TableMgr:GetGiftpackTabConfig(tabID)
                        if config then
                            AddTab(config)
                            SortTabs()
                        end
                    end
                end
            end
        end
    end)

    EventDispatcher.Bind(GiftPackData.OnHistoryStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(iapGoodsInfo)
        local tabID = iapGoodsInfo.tab

        if math.floor(tabID / 100) == currentConfig.id then
            if tabID == currentTabID then
                local uiGiftPack = ui.giftPackList.giftPacksByID[iapGoodsInfo.id]
                if uiGiftPack then
                    UpdateGiftPackNotice(uiGiftPack)
                end
            end

            UpdateTabNotice(ui.tabList.tabsByID[tabID])
        end
    end)

    GiftPackData.RequestData()
end

function Start()
    ui.lastUpdateTime = Serclimax.GameTime.GetSecTime()
    
    Redraw()
end

function Update()
    local now = Serclimax.GameTime.GetSecTime()

    if ui.lastUpdateTime ~= now then
        ui.lastUpdateTime = now

        for tabID, list in pairs(ui.limitedGiftPacks) do
            UpdateTabCountdown(ui.tabList.tabsByID[tabID])

            if tabID == currentTabID then
                for _, iapGoodsInfo in ipairs(list.data) do
                    UpdateGiftPackCountdown(ui.giftPackList.giftPacksByID[iapGoodsInfo.id])
                end
            end
        end
    end
end

function Close()
    UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)

    EventDispatcher.UnbindAll(_M)

    ui = nil
    currentConfig = nil
    currentTabID = nil
end

----- Template:Goldstore ------------------------------------------------
function HasNotice(config)
    local configID = config.id
    for tabID, config in pairs(TableMgr:GetGiftpackTabConfig()) do
        if math.floor(tabID / 100) == configID then
            if GiftPackData.HasNewGoods(tabID) then
                return true
            end
        end
    end

    return false
end

function IsAvailable(config)
    local configID = config.id
    for tabID, config in pairs(TableMgr:GetGiftpackTabConfig()) do
        if math.floor(tabID / 100) == configID then
            if GiftPackData.HasAvailableGoods(tabID) then
                return true
            end
        end
    end

    return false
end

function GetCountdownTime(config)
    if config then
        local configID = config.id
        for _, iapGoodsInfo in ipairs(GiftPackData.GetLimitedGoods()) do
            if math.floor(iapGoodsInfo.tab / 100) == configID then
                return iapGoodsInfo.endTime
            end
        end
    else
        local iapGoodsInfo = GiftPackData.GetLimitedGoods()[1]
        return iapGoodsInfo and iapGoodsInfo.endTime
    end
end

Goldstore.RegisterAsTemplate(1, _M)
-------------------------------------------------------------------------
