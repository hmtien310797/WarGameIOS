module("HeroCard_reward", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local TAB_ACTIVITY_ID = { "3004,3011,9000", 7000, 3008, 3010, 3012 }

local ui
local currentTab

----- Events ---------------------------------------------------
local eventOnNoticeStatusChange = EventDispatcher.CreateEvent()

function OnNoticeStatusChange(config)
    return eventOnNoticeStatusChange
end

function OnAvailabilityChange(config)
    return ActivityData.OnAvailabilityChange()
end

local function BroadcastEventOnNoticeStatusChange(...)
    EventDispatcher.Broadcast(eventOnNoticeStatusChange, ...)
end

EventDispatcher.Bind(MonthCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, BroadcastEventOnNoticeStatusChange)
EventDispatcher.Bind(HeroCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, BroadcastEventOnNoticeStatusChange)
EventDispatcher.Bind(UnionCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, BroadcastEventOnNoticeStatusChange)
EventDispatcher.Bind(NewbieCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, BroadcastEventOnNoticeStatusChange)
----------------------------------------------------------------

function IsInViewport()
    return ui ~= nil
end

local function SetCurrentTab(tab)
    currentTab = tab
end

local function GetCardSubType(cardInfo, tab)
    if tab == 1 then
        return cardInfo.goodInfo.type
    else
        return cardInfo.goodInfo.subType
    end
end

local function AddCountdown(uiLabel, timeStamp, GetNewTimeStamp)
    if not ui.countdowns[uiLabel] then
        ui.countdowns[uiLabel] = {}
    end

    ui.countdowns[uiLabel].timeStamp = timeStamp
    ui.countdowns[uiLabel].GetNewTimeStamp = GetNewTimeStamp
end

local function RemoveCountdown(uiLabel)
    ui.countdowns[uiLabel] = nil
end

local function DecodeItem(str)
	local items = {}
	--local strTable = string.msplit(cardInfo.giftStr , "," , "-" , ";" , ":")
	local str1 = string.split(str , ",")
	for i1=1 , #str1 do
		local str2 = string.split(str1[i1] , "-")
		local pri = tonumber(str2[1])
		local str3 = string.split(str2[2] , ";")
		local it = {}
		for i3=1 , #str3 do
			local str4 = string.split(str3[i3] , ":")
			it[tonumber(str4[1])] = tonumber(str4[2])
		end
		--items[pri] = it
		table.insert(items , {privlig = pri , items = it})
	end
	
	--[[table.sort(items , function(v1, v2)
	
	end)]]
	
	return items
end

local ShowRewards = function(hero, item, army, grid)
    while grid.transform.childCount > 0 do
        UnityEngine.GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
    end
    if hero then
        for i, v in ipairs(hero) do
            local heroData = TableMgr:GetHeroData(v.baseid)
            local hero = NGUITools.AddChild(grid.gameObject, ui.hero.gameObject).transform
            hero.localScale = Vector3(0.6, 0.6, 1) * 0.9
            hero:Find("level text").gameObject:SetActive(false)
            hero:Find("name text").gameObject:SetActive(false)
            hero:Find("bg_skill").gameObject:SetActive(false)
            hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
            hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
            local star = hero:Find("star"):GetComponent("UISprite")
            if star ~= nil then
                star.width = v.star * star.height
            end
            UIUtil.SetClickCallback(hero:Find("head icon").gameObject,function(go)
                if go ~= ui.tooltip then
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)}) 
                    ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    ui.tooltip = nil
                end
            end)
        end
    end
    if item then
        for _, item in ipairs(item) do
            local obj = UIUtil.AddItemToGrid(grid.gameObject, item)
            UIUtil.SetClickCallback(obj.gameObject,function(go)
                if go ~= ui.tooltip then
                    local itemData = TableMgr:GetItemData(item.baseid)
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
                    ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    ui.tooltip = nil
                end
            end)
        end
    end
    if army then
        for i, v in ipairs(army) do
            print(v.baseid, v.level)
            local soldierData = TableMgr:GetBarrackData(v.baseid, v.level)
            local itemprefab = NGUITools.AddChild(grid.gameObject, ui.item.gameObject).transform
            itemprefab.gameObject:SetActive(true)
            itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + v.level)
            itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
            itemprefab:Find("have"):GetComponent("UILabel").text = v.num
            itemprefab:Find("num").gameObject:SetActive(false)
            UIUtil.SetClickCallback(itemprefab.gameObject,function(go)
                if go ~= ui.tooltip then
                    Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)}) 
                    ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    ui.tooltip = nil
                end
            end)
        end
    end
    grid.repositionNow = true
end

local function UpdateCard(uiCard, cardInfo)
    if cardInfo then
        uiCard.cardInfo = cardInfo
    else
        cardInfo = uiCard.cardInfo
    end

    uiCard.gameObject:SetActive(true)

    local iapGoodInfo = cardInfo.goodInfo
    uiCard.gameObject.name = 100000 + iapGoodInfo.order
    GiftPackData.ExchangePrice(iapGoodInfo)
    local tab = uiCard.tab

    if tab == 1 or tab == 2 or tab == 4 then
        if cardInfo.buyed then
            uiCard.hint.gameObject:SetActive(true)
			
            if cardInfo.cantake then
                uiCard.tips.gameObject:SetActive(true)

                uiCard.tips.label.text = TextMgr:GetText("pay_ui9")
                uiCard.btn_claim.button.isEnabled = true
                uiCard.btn_claim.notice:SetActive(true)

                uiCard.hint.label.text = System.String.Format(TextMgr:GetText("card_time_day"), iapGoodInfo.day - cardInfo.day + 1)
                uiCard.btn_claim.label.text = TextMgr:GetText("mail_ui12")
            else
                uiCard.tips.gameObject:SetActive(false)

                uiCard.tips.label.text = TextMgr:GetText("pay_ui7")
                uiCard.btn_claim.button.isEnabled = false
                uiCard.btn_claim.notice:SetActive(false)

                uiCard.hint.label.text = System.String.Format(TextMgr:GetText("card_time_day"), iapGoodInfo.day - cardInfo.day)
                uiCard.btn_claim.label.text = TextMgr:GetText("ui_activity_des6")
            end
        else
            uiCard.hint.gameObject:SetActive(false)
            
            uiCard.tips.label.text = TextMgr:GetText("pay_ui8")
            uiCard.btn_claim.button.isEnabled = true
            uiCard.btn_claim.notice:SetActive(false)

            uiCard.btn_claim.label.text = string.make_price(iapGoodInfo.price)
        end

        if tab == 1 then
            uiCard.icon.mainTexture = ResourceLibrary:GetIcon("Background/", iapGoodInfo.icon)
            uiCard.name.text = TextMgr:GetText(iapGoodInfo.name)
			uiCard.detail.text2.gameObject:SetActive(iapGoodInfo.type ~= ShopMsg_pb.IAPGoodType_LifeLong)
			uiCard.detail.goldSpr.gameObject:SetActive(iapGoodInfo.type ~= ShopMsg_pb.IAPGoodType_LifeLong)
			uiCard.detail.value.gameObject:SetActive(iapGoodInfo.type ~= ShopMsg_pb.IAPGoodType_LifeLong)
			
            if cardInfo.buyed then
                uiCard.value.gameObject:SetActive(true)
                uiCard.tips.gameObject:SetActive(true)
                uiCard.detail.gameObject:SetActive(false)

                uiCard.value.text = cardInfo.item.item.item[1].num

                local timeStamp, GetNewTimeStamp

                if iapGoodInfo.type == ShopMsg_pb.IAPGoodType_LifeLong then
                    uiCard.hint.gameObject:SetActive(false)

                    timeStamp = cardInfo.day
                else
                    GetNewTimeStamp = Global.GetFiveOclockCooldown
                    timeStamp = GetNewTimeStamp()
                end

                if cardInfo.cantake then
                    uiCard.countdown.gameObject:SetActive(false)

                    RemoveCountdown(uiCard.countdown.time)
                else
                    uiCard.countdown.gameObject:SetActive(true)

                    uiCard.countdown.time.text = Global.SecondToTimeLong(timeStamp - ui.lastUpdateTime)

                    AddCountdown(uiCard.countdown.time, timeStamp, GetNewTimeStamp)
                end
            else
                uiCard.value.gameObject:SetActive(false)
                uiCard.tips.gameObject:SetActive(false)
                uiCard.detail.gameObject:SetActive(true)
                uiCard.countdown.gameObject:SetActive(false)
                if iapGoodInfo.order == 300 then
                    uiCard.detail.dailyDetail.text = TextMgr:GetText("Lifelong_card")
                else
                    uiCard.detail.dailyDetail.text = TextMgr:GetText("MonthCard_Desc_Rebates")
                end
                uiCard.detail.dailyAward.text = cardInfo.item.item.item[1].num
                uiCard.detail.value.text = iapGoodInfo.showPrice
                uiCard.detail.description.text = System.String.Format(TextMgr:GetText(iapGoodInfo.desc), iapGoodInfo.itemGift.item.item[1].num)

                RemoveCountdown(uiCard.countdown.time)
            end
        --iapGoodInfo.buff = "3101"
            print("##############################iapGoodInfo.buff",iapGoodInfo.buff)
            local buff = nil
            if iapGoodInfo.buff ~= "" then
                buff = TableMgr:GetSlgBuffData(iapGoodInfo.buff)
            end
            if buff ~= nil then
                if uiCard.buff_root ~= nil then
                    uiCard.buff_root.gameObject:SetActive(true);
                end
                if uiCard.buff_icon ~= nil then
                    uiCard.buff_icon.mainTexture = ResourceLibrary:GetIcon("Item/", buff.icon)
                end
                UIUtil.SetClickCallback(uiCard.buff_root.gameObject, function(go)
                    if go ~= ui.tooltip then
                        Tooltip.ShowItemTip({ name = TextUtil.GetSlgBuffTitle(buff), text = TextUtil.GetSlgBuffDescription(buff) })
                        ui.tooltip = uiCard.buff_root.gameObject
                    else
                        Tooltip.HideItemTip()
                        ui.tooltip = nil
                    end
                end)

            else
                if uiCard.buff_root ~= nil then
                    uiCard.buff_root.gameObject:SetActive(false);
                end
            end


        elseif tab == 2 then
            uiCard.value.text = iapGoodInfo.showPrice

            local awardOnPurchase = iapGoodInfo.itemGift.item.item[1]
            UIUtil.LoadItem(uiCard.awardOnPurchase, TableMgr:GetItemData(awardOnPurchase.baseid), awardOnPurchase.num)

            local dailyAward = cardInfo.gift.item.item[1]
            local itemData_dailyAward = TableMgr:GetItemData(dailyAward.baseid)
            UIUtil.LoadItem(uiCard.dailyAward, itemData_dailyAward, dailyAward.num)

            local heroData = TableMgr:GetHeroData(itemData_dailyAward.param1)
            uiCard.figure.mainTexture = ResourceLibrary:GetIcon("Icon/hero_half/", heroData.picture)
            uiCard.name.text = TextMgr:GetText(heroData.nameLabel)
        end
    elseif tab == 3 then
        uiCard.price.text = iapGoodInfo.showPrice

        if cardInfo.buyed then
            uiCard.get.text = TextMgr:GetText("mission_go")
            uiCard.getText.gameObject:SetActive(true)
            uiCard.showSprice:SetActive(false)
            uiCard.hint.text = System.String.Format(TextMgr:GetText("card_time_day"), iapGoodInfo.day - cardInfo.day + (cardInfo.cantake and 1 or 0))
            uiCard.hint.gameObject:SetActive(true)
			
			uiCard.getText.text = cardInfo.cantake and TextMgr:GetText("pay_ui9") or TextMgr:GetText("pay_ui7")
        else
            uiCard.get.text = string.make_price(iapGoodInfo.price)
            uiCard.getText.gameObject:SetActive(false)
            uiCard.showSprice:SetActive(true)
            uiCard.hint.gameObject:SetActive(false)
        end
		
		uiCard.claimRed.gameObject:SetActive(cardInfo.buyed and cardInfo.cantake)
		
        local awardType = 1
        local uiItemList = uiCard.awardList.awards[awardType].itemList

        --[[local i = 1

        for _, item in ipairs(iapGoodInfo.itemGift.item.item) do
            local uiItems = uiItemList.items

            if i > #uiItems then
                table.insert(uiItems, UIUtil.AddItemToGrid(uiItemList.gameObject, item , function()
					if ui.tooltip ~= uiCard then
						ui.tooltip = uiCard

						local itemData = TableMgr:GetItemData(item.baseid or item.baseid)
						Tooltip.ShowItemTip({ name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData) })
					else
						ui.tooltip = nil
					end
				end))
            else
                UIUtil.LoadItem(uiItems[i], TableMgr:GetItemData(item.baseid), item.num)
            end

            i = i + 1
        end]]
        ShowRewards(iapGoodInfo.itemOther.hero.hero, iapGoodInfo.itemGift.item.item, nil, uiItemList.grid)
		
        awardType = awardType + 1
        uiItemList = uiCard.awardList.awards[awardType].itemList
		print(cardInfo.giftStr)
		
		local childCount = uiItemList.gameObject.transform.childCount
		for l = 1, childCount  do
		  UnityEngine.GameObject.Destroy(uiItemList.gameObject.transform:GetChild(l-1).gameObject)
		end
		
		local items = DecodeItem(cardInfo.giftStr)
		for k, v in ipairs(items) do
			local trfLv = NGUITools.AddChild(uiItemList.gameObject, uiCard.itemLevel.gameObject)
			
			trfLv.name = v.privlig
			local unionPriData = TableMgr:GetUnionPrivilege(v.privlig)
			local lvGrid = trfLv.transform:Find("Grid"):GetComponent("UIGrid")
			
			local lvName = trfLv.transform:Find("text1"):GetComponent("UILabel")
			lvName.text = TextMgr:GetText(unionPriData.name)
			
			trfLv.transform:Find("member_icon"):GetComponent("UISprite").spriteName = string.format("%s%s" , "level_" , v.privlig)
			
			for t , vv in pairs(v.items) do
				UIUtil.AddItemToGrid(lvGrid.gameObject, {baseid=t , num=vv} , function()
					if ui.tooltip ~= uiCard then
						ui.tooltip = uiCard

						local itemData = TableMgr:GetItemData(t)
						Tooltip.ShowItemTip({ name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData) })
					else
						ui.tooltip = nil
					end
				end)
			end
			lvGrid.repositionNow = true
		end
		uiItemList.grid.repositionNow = true
		

       --[[ awardType = awardType + 1
        uiItemList = uiCard.awardList.awards[awardType].itemList
        i = 1

        for _, item in ipairs(cardInfo.gift.item.item) do
            if item.baseid == 0 then
                awardType = awardType + 1
                uiItemList = uiCard.awardList.awards[awardType].itemList
                i = 1
            else
                local uiItems = uiItemList.items

                if i > #uiItems then
                    table.insert(uiItems, UIUtil.AddItemToGrid(uiItemList.gameObject, item))
                else
                   -- UIUtil.LoadItem(uiItems[i], TableMgr:GetItemData(item.baseid), item.num)
                end

                i = i + 1
            end
        end]]
    end

    ui.tabs[tab].cardList.cardsBySubType[GetCardSubType(cardInfo, tab)] = uiCard
end

local function AddCard(tab, cardInfo)
    local uiTab = ui.tabs[tab]

    local uiCard = {}

    uiCard.gameObject = NGUITools.AddChild(uiTab.cardList.gameObject, uiTab.cardList.newCard)
    uiCard.transform = uiCard.gameObject.transform

    if tab == 1 or tab == 2 then
        uiCard.name = uiCard.transform:Find("text_name"):GetComponent("UILabel")

        uiCard.hint = {}
        uiCard.hint.transform = uiCard.transform:Find("hint")
        uiCard.hint.gameObject = uiCard.hint.transform.gameObject
        uiCard.hint.label = uiCard.hint.transform:GetComponent("UILabel")

        uiCard.tips = {}
        uiCard.tips.transform = uiCard.transform:Find("Tips")
        uiCard.tips.gameObject = uiCard.tips.transform.gameObject
        uiCard.tips.label = uiCard.tips.transform:GetComponent("UILabel")

        uiCard.btn_claim = {}
        uiCard.btn_claim.transform = uiCard.transform:Find("btn_get")
        uiCard.btn_claim.gameObject = uiCard.btn_claim.transform.gameObject
        uiCard.btn_claim.button = uiCard.btn_claim.transform:GetComponent("UIButton")
        uiCard.btn_claim.label = uiCard.btn_claim.transform:Find("text"):GetComponent("UILabel")
        uiCard.btn_claim.notice = uiCard.btn_claim.transform:Find("red").gameObject

        if tab == 1 then
            uiCard.icon = uiCard.transform:Find("bg_mid/icon"):GetComponent("UITexture")
            uiCard.value = uiCard.transform:Find("bg_mid/num"):GetComponent("UILabel")
            uiCard.buff_root = uiCard.transform:Find("bg_extra")
            uiCard.buff_icon = uiCard.transform:Find("bg_extra/icon_buff"):GetComponent("UITexture")

            uiCard.countdown = {}
            uiCard.countdown.transform = uiCard.transform:Find("bg_mid/countdown")
            uiCard.countdown.gameObject = uiCard.countdown.transform.gameObject
            uiCard.countdown.time = uiCard.countdown.transform:Find("time"):GetComponent("UILabel")

            uiCard.detail = {}
            uiCard.detail.transform = uiCard.transform:Find("bg_mid/Detail")
            uiCard.detail.gameObject = uiCard.detail.transform.gameObject
            uiCard.detail.dailyDetail = uiCard.detail.transform:Find("text1"):GetComponent("UILabel")
            uiCard.detail.dailyAward = uiCard.detail.transform:Find("Daily Gold"):GetComponent("UILabel")
            uiCard.detail.value = uiCard.detail.transform:Find("Value"):GetComponent("UILabel")
            uiCard.detail.description = uiCard.detail.transform:Find("Description"):GetComponent("UILabel")
            uiCard.detail.text2 = uiCard.detail.transform:Find("text2")
            uiCard.detail.goldSpr = uiCard.detail.transform:Find("gold2")
            UIUtil.SetClickCallback(uiCard.btn_claim.gameObject, function()
                local cardInfo = uiCard.cardInfo
                
                if not cardInfo.buyed then
                    local iapGoodInfo = cardInfo.goodInfo
                    store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
                else
                    MonthCardData.ClaimAward(cardInfo.goodInfo.type)
                end
            end)
        elseif tab == 2 then
            uiCard.figure = uiCard.transform:Find("bg_mid/Texture"):GetComponent("UITexture")
            uiCard.value = uiCard.transform:Find("bg_mid/bg_price/bg/num"):GetComponent("UILabel")

            uiCard.awardOnPurchase = UIUtil.LoadItemObject({}, uiCard.transform:Find("bg_mid/bg_item1/Item_CommonNew"))
            uiCard.dailyAward = UIUtil.LoadItemObject({}, uiCard.transform:Find("bg_mid/bg_item2/Item_CommonNew"))

            UIUtil.SetClickCallback(uiCard.btn_claim.gameObject, function()
                local cardInfo = uiCard.cardInfo
                
                if not cardInfo.buyed then
                    local iapGoodInfo = cardInfo.goodInfo
                    store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
                else
                    HeroCardData.ClaimAward(cardInfo.goodInfo.subType)
                end
            end)

            UIUtil.SetClickCallback(uiCard.awardOnPurchase.gameObject, function()
                if ui.tooltip ~= uiCard then
                    ui.tooltip = uiCard

                    local itemData = TableMgr:GetItemData(uiCard.cardInfo.goodInfo.itemGift.item.item[1].baseid)
                    Tooltip.ShowItemTip({ name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData) })
                else
                    ui.tooltip = nil
                end
            end)

            UIUtil.SetClickCallback(uiCard.dailyAward.gameObject, function()
                if ui.tooltip ~= uiCard then
                    ui.tooltip = uiCard

                    local itemData = TableMgr:GetItemData(uiCard.cardInfo.gift.item.item[1].baseid)
                    Tooltip.ShowItemTip({ name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData) })
                else
                    ui.tooltip = nil
                end
            end)
        end
    elseif tab == 3 then
        uiCard.price = uiCard.transform:Find("bg_price/bg/num"):GetComponent("UILabel")
        uiCard.showSprice = uiCard.transform:Find("bg_price").gameObject
        uiCard.hint = uiCard.transform:Find("hint"):GetComponent("UILabel")
        uiCard.get = uiCard.transform:Find("btn_get/text"):GetComponent("UILabel")
        uiCard.getText = uiCard.transform:Find("text"):GetComponent("UILabel")
        uiCard.btn_claim = uiCard.transform:Find("btn_get"):GetComponent("UIButton")
        uiCard.item = uiCard.transform:Find("Item_CommonNew")
        uiCard.itemLevel = uiCard.transform:Find("bg_level")
		uiCard.claimRed = uiCard.transform:Find("btn_get/red")

        uiCard.awardList = {}
        uiCard.awardList.transform = uiCard.transform:Find("Scroll View")
        uiCard.awardList.gameObject = uiCard.awardList.transform.gameObject
        uiCard.awardList.awards = {}

        local uiAwardOnPurchase = {}
        uiAwardOnPurchase.transform = uiCard.awardList.transform:GetChild(0)
        uiAwardOnPurchase.gameObject = uiAwardOnPurchase.transform.gameObject
        
        uiAwardOnPurchase.itemList = {}
        uiAwardOnPurchase.itemList.transform = uiAwardOnPurchase.transform:Find("Grid")
        uiAwardOnPurchase.itemList.gameObject = uiAwardOnPurchase.itemList.transform.gameObject
        uiAwardOnPurchase.itemList.grid = uiAwardOnPurchase.itemList.transform:GetComponent("UIGrid")
        uiAwardOnPurchase.itemList.items = {}

        table.insert(uiCard.awardList.awards, uiAwardOnPurchase)

        local uiDailyAwards = uiCard.awardList.transform:GetChild(1):Find("Awards")
		uiDailyAwards.itemList = {}
		uiDailyAwards.itemList.transform = uiDailyAwards.transform:Find("Grid")
        uiDailyAwards.itemList.gameObject = uiDailyAwards.itemList.transform.gameObject
        uiDailyAwards.itemList.grid = uiDailyAwards.itemList.transform:GetComponent("UIGrid")
        uiDailyAwards.itemList.items = {}
		
		table.insert(uiCard.awardList.awards, uiDailyAwards)
		
        --[[for i = 0, uiDailyAwards.childCount - 1 do
            local uiDailyAward = {}

            uiDailyAward.transform = uiDailyAwards:GetChild(i)
            uiDailyAward.gameObject = uiDailyAward.transform.gameObject

            uiDailyAward.itemList = {}
            uiDailyAward.itemList.transform = uiDailyAward.transform:Find("Grid")
            uiDailyAward.itemList.gameObject = uiDailyAward.itemList.transform.gameObject
            uiDailyAward.itemList.grid = uiDailyAward.itemList.transform:GetComponent("UIGrid")
            uiDailyAward.itemList.items = {}

            table.insert(uiCard.awardList.awards, uiDailyAward)
        end]]

		
        UIUtil.SetClickCallback(uiCard.btn_claim.gameObject, function()
            local cardInfo = uiCard.cardInfo

            if UnionInfoData.GetGuildId() <= 0 then
                MessageBox.Show(TextMgr:GetText("rank_ui24"))
                return
            end
            
            if not cardInfo.buyed then
                local iapGoodInfo = cardInfo.goodInfo
                store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
            else
                UnionGift.Show()
                -- UnionCardData.ClaimAward()
            end
        end)
    end

    table.insert(uiTab.cardList.cards, uiCard)

    uiCard.tab = tab

    UpdateCard(uiCard, cardInfo)
end

local function UpdateNewbie(cardInfo)
    if NewbieCardData.CanShow() then
        ui.tabs[4].btn:SetActive(true)
        ui.tab_grid.repositionNow = true

        if not ui.newbiecard then
            ui.newbiecard = {}
            ui.newbiecard.countdownLabel = transform:Find("Container/Contents/4/banner/time"):GetComponent("UILabel")
            ui.newbiecard.countdownTime = transform:Find("Container/Contents/4/banner/time (1)"):GetComponent("UILabel")
            ui.newbiecard.nameLabel = transform:Find("Container/Contents/4/bg_mid/newbie/text_name"):GetComponent("UILabel")
            ui.newbiecard.daysLabel = transform:Find("Container/Contents/4/bg_mid/newbie/hint"):GetComponent("UILabel")
            ui.newbiecard.showPrice = transform:Find("Container/Contents/4/bg_mid/newbie/bg_mid/bg_price/bg/num"):GetComponent("UILabel")
            ui.newbiecard.tips = transform:Find("Container/Contents/4/bg_mid/newbie/Tips"):GetComponent("UILabel")

            ui.newbiecard.grid1 = transform:Find("Container/Contents/4/bg_mid/newbie/bg_mid/bg_item1/Scroll View/Grid"):GetComponent("UIGrid")
            ui.newbiecard.grid2 = transform:Find("Container/Contents/4/bg_mid/newbie/bg_mid/bg_item2/Scroll View/Grid"):GetComponent("UIGrid")

            ui.newbiecard.btn_get = transform:Find("Container/Contents/4/bg_mid/newbie/btn_get"):GetComponent("UIButton")
            ui.newbiecard.btn_text = transform:Find("Container/Contents/4/bg_mid/newbie/btn_get/text"):GetComponent("UILabel")
            ui.newbiecard.btn_red = transform:Find("Container/Contents/4/bg_mid/newbie/btn_get/red").gameObject

            ui.newbiecard.listitem1 = {}
            ui.newbiecard.listitem2 = {}
        end
        local iapGoodInfo = cardInfo.goodInfo
        GiftPackData.ExchangePrice(iapGoodInfo)
        UIUtil.SetClickCallback(ui.newbiecard.btn_get.gameObject, function()
            if not cardInfo.buyed then
                store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
            else
                NewbieCardData.ClaimAward(iapGoodInfo.type)
            end
        end)
        if cardInfo.buyed then
            ui.newbiecard.daysLabel.gameObject:SetActive(true)
			ui.newbiecard.countdownLabel.gameObject:SetActive(true)
            if cardInfo.cantake then
                ui.newbiecard.btn_get.isEnabled = true
                ui.newbiecard.tips.text = TextMgr:GetText("pay_ui9")
                ui.newbiecard.daysLabel.text = System.String.Format(TextMgr:GetText("card_time_day"), iapGoodInfo.day - cardInfo.day + 1)
            else
                ui.newbiecard.tips.text = TextMgr:GetText("pay_ui7")
                ui.newbiecard.daysLabel.text = System.String.Format(TextMgr:GetText("card_time_day"), iapGoodInfo.day - cardInfo.day)
                ui.newbiecard.btn_get.isEnabled = false
            end
            ui.newbiecard.btn_text.text = TextMgr:GetText("mail_ui12")
            ui.newbiecard.countdownLabel.text = TextMgr:GetText("military_6")
            AddCountdown(ui.newbiecard.countdownTime, Global.GetFiveOclockCooldown(), Global.GetFiveOclockCooldown)
        else
            ui.newbiecard.btn_get.isEnabled = true
            ui.newbiecard.daysLabel.gameObject:SetActive(false)
            ui.newbiecard.countdownLabel.gameObject:SetActive(false)
            ui.newbiecard.tips.text = TextMgr:GetText("pay_ui8")
            ui.newbiecard.btn_text.text = string.make_price(iapGoodInfo.price)
            ui.newbiecard.countdownLabel.text = TextMgr:GetText("newbie_card_ui1")
            ui.newbiecard.countdownTime.text = ""
            --AddCountdown(ui.newbiecard.countdownTime, NewbieCardData.GetNewbieBuyTime(), NewbieCardData.GetNewbieBuyTime)
        end
        
        ui.newbiecard.showPrice.text = iapGoodInfo.showPrice
        ui.newbiecard.nameLabel.text = TextMgr:GetText(iapGoodInfo.name)

        ui.newbiecard.btn_red:SetActive(NewbieCardData.HasUnclaimedAward())


        local iapGoodInfoItems = {}
        for i=1 ,#(iapGoodInfo.itemGift.item.item) do
            table.insert(iapGoodInfoItems, iapGoodInfo.itemGift.item.item[i])
        end
        --iapGoodInfo.buff = "3101"
        print("##############################iapGoodInfo.buff",iapGoodInfo.buff)
        
        if iapGoodInfo.buff ~= "" then
            local buff = TableMgr:GetSlgBuffData(iapGoodInfo.buff)
            if buff ~= nil then
                local item ={}
                item.id = -1
                item.name = buff.title
                item.type = 1
                item.subtype = 1
                item.quality = 1
                item.itemlevel = 1
                item.charLevel = 1
                item.description = buff.description
                item.icon = buff.icon
                item.pileSize = 1000000000
                item.price = ""
                item.canUse = 0
                item.param1 = 0
                item.param2 = 0
                item.param3 = 0
                item.gather = "NA"
                item.gather2 = ""
                item.itemsize = 1000000000
                item.itemuse = ""
                item.showType = 0
                item.quickUse = 0
                item.showSum = 0
                item.showtypename = 0
                item.showtypedes = 0
                item.addCreateMonster = 0
                item.buff_id = iapGoodInfo.buff
                table.insert(iapGoodInfoItems, item)
            end
        end
        local showItems = function(items, grid, uiItems)
            local numItems = #items
            local maxnum = math.max(numItems, #uiItems)
            for i = 1, maxnum do
                if i > numItems then
                    uiItems[i].gameObject:SetActive(false)
                else
                    if i > #uiItems then
                        --local uiItem = UIUtil.AddItemToGrid(grid.gameObject, items[i])
                        local uiItem = UIUtil.LoadItemObject({}, NGUITools.AddChild(grid.gameObject, ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")).transform)
                        if items[i].id ~= nil and items[i].id < 0 then
                            UIUtil.LoadItem(uiItem, items[i], 0)
                        else
                            UIUtil.LoadItem(uiItem, TableMgr:GetItemData(items[i].id or items[i].baseid), items[i].num)
                        end
                        
                        
                        UIUtil.SetClickCallback(uiItem.gameObject, function(go)
                            if go ~= ui.tooltip then
                                local itemData = uiItem.data
                                if itemData.id < 0 then
                                    local buff = TableMgr:GetSlgBuffData(itemData.buff_id)
                                    Tooltip.ShowItemTip({ name = TextUtil.GetSlgBuffTitle(buff), text = TextUtil.GetSlgBuffDescription(buff) })
                                else
                                    Tooltip.ShowItemTip({ name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData) })
                                end
                                ui.tooltip = uiItem.gameObject
                            else
                                Tooltip.HideItemTip()
                                ui.tooltip = nil
                            end
                        end)
        
                        table.insert(uiItems, uiItem)
                    else
                        uiItems[i].gameObject:SetActive(true)
        
                        local item = items[i]
                        if item.id ~= nil and item.id < 0 then
                            UIUtil.LoadItem(uiItems[i], item, 0)
                        else
                            UIUtil.LoadItem(uiItems[i], TableMgr:GetItemData(item.id or item.baseid), item.num)
                        end
                        
                        --UIUtil.LoadItem(uiItems[i], TableMgr:GetItemData(item.baseid), item.num)
                    end
                end
            end
            grid.repositionNow = true
        end

        showItems(iapGoodInfoItems, ui.newbiecard.grid1, ui.newbiecard.listitem1,true)
        showItems(cardInfo.gift.item.item, ui.newbiecard.grid2, ui.newbiecard.listitem2)
    else
        ui.tabs[4].btn:SetActive(false)
        ui.tabs[4].gameObject:SetActive(false)
        ui.tab_grid.repositionNow = true
        if currentTab == 4 then
            ShowTab(1)
        end
    end
end

local function UpdateWar(cardInfo)
    if WarCardData.CanShow() then
        ui.tabs[5].btn:SetActive(true)
        ui.tab_grid.repositionNow = true

        if not ui.warcard then
            ui.warcard = {}
            ui.warcard.countdownLabel = transform:Find("Container/Contents/5/banner/time"):GetComponent("UILabel")
            ui.warcard.countdownTime = transform:Find("Container/Contents/5/banner/time (1)"):GetComponent("UILabel")
            ui.warcard.nameLabel = transform:Find("Container/Contents/5/bg_mid/newbie/text_name"):GetComponent("UILabel")
            ui.warcard.daysLabel = transform:Find("Container/Contents/5/bg_mid/newbie/hint"):GetComponent("UILabel")
            ui.warcard.showPrice = transform:Find("Container/Contents/5/bg_mid/newbie/bg_mid/bg_price/bg/num"):GetComponent("UILabel")
            ui.warcard.tips = transform:Find("Container/Contents/5/bg_mid/newbie/Tips"):GetComponent("UILabel")

            ui.warcard.grid1 = transform:Find("Container/Contents/5/bg_mid/newbie/bg_mid/bg_item1/Scroll View/Grid"):GetComponent("UIGrid")
            ui.warcard.grid2 = transform:Find("Container/Contents/5/bg_mid/newbie/bg_mid/bg_item2/Scroll View/Grid"):GetComponent("UIGrid")

            ui.warcard.btn_get = transform:Find("Container/Contents/5/bg_mid/newbie/btn_get"):GetComponent("UIButton")
            ui.warcard.btn_text = transform:Find("Container/Contents/5/bg_mid/newbie/btn_get/text"):GetComponent("UILabel")
            ui.warcard.btn_red = transform:Find("Container/Contents/5/bg_mid/newbie/btn_get/red").gameObject

        end
        local iapGoodInfo = cardInfo.goodInfo
        GiftPackData.ExchangePrice(iapGoodInfo)
        UIUtil.SetClickCallback(ui.warcard.btn_get.gameObject, function()
            if not cardInfo.buyed then
                store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
            else
                WarCardData.ClaimAward(iapGoodInfo.type)
            end
        end)
        if cardInfo.buyed then
            ui.warcard.daysLabel.gameObject:SetActive(true)
			ui.warcard.countdownLabel.gameObject:SetActive(true)
            if cardInfo.cantake then
                ui.warcard.btn_get.isEnabled = true
                ui.warcard.tips.text = TextMgr:GetText("pay_ui9")
                ui.warcard.daysLabel.text = System.String.Format(TextMgr:GetText("card_time_day"), iapGoodInfo.day - cardInfo.day + 1)
            else
                ui.warcard.tips.text = TextMgr:GetText("pay_ui7")
                ui.warcard.daysLabel.text = System.String.Format(TextMgr:GetText("card_time_day"), iapGoodInfo.day - cardInfo.day)
                ui.warcard.btn_get.isEnabled = false
            end
            ui.warcard.btn_text.text = TextMgr:GetText("mail_ui12")
            ui.warcard.countdownLabel.text = TextMgr:GetText("military_6")
            AddCountdown(ui.warcard.countdownTime, Global.GetFiveOclockCooldown(), Global.GetFiveOclockCooldown)
        else
            ui.warcard.btn_get.isEnabled = true
            ui.warcard.daysLabel.gameObject:SetActive(false)
            ui.warcard.tips.text = TextMgr:GetText("pay_ui8")
            ui.warcard.btn_text.text = string.make_price(iapGoodInfo.price)
            ui.warcard.countdownLabel.text = TextMgr:GetText("newbie_card_ui1")
            ui.warcard.countdownTime.text = ""
            ui.warcard.countdownLabel.gameObject:SetActive(false)
            --AddCountdown(ui.warcard.countdownTime, WarCardData.GetNewbieBuyTime(), WarCardData.GetNewbieBuyTime)
        end
        
        ui.warcard.showPrice.text = iapGoodInfo.showPrice
        ui.warcard.nameLabel.text = TextMgr:GetText(iapGoodInfo.name)

        ui.warcard.btn_red:SetActive(WarCardData.HasUnclaimedAward())

        ShowRewards(iapGoodInfo.itemGift.hero.hero, iapGoodInfo.itemGift.item.item, iapGoodInfo.itemGift.army.army, ui.warcard.grid1)
        --iapGoodInfo.buff = "3101"
        print("##############################iapGoodInfo.buff",iapGoodInfo.buff)
        
        if iapGoodInfo.buff ~= "" then
            local buff = TableMgr:GetSlgBuffData(iapGoodInfo.buff)
            if buff ~= nil then
                local item ={}
                item.id = -1
                item.name = buff.title
                item.type = 1
                item.subtype = 1
                item.quality = 1
                item.itemlevel = 1
                item.charLevel = 1
                item.description = buff.description
                item.icon = buff.icon
                item.pileSize = 1000000000
                item.price = ""
                item.canUse = 0
                item.param1 = 0
                item.param2 = 0
                item.param3 = 0
                item.gather = "NA"
                item.gather2 = ""
                item.itemsize = 1000000000
                item.itemuse = ""
                item.showType = 0
                item.quickUse = 0
                item.showSum = 0
                item.showtypename = 0
                item.showtypedes = 0
                item.addCreateMonster = 0
                item.buff_id = iapGoodInfo.buff

                local uiItem = UIUtil.LoadItemObject({}, NGUITools.AddChild(ui.warcard.grid1.gameObject, ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")).transform)
                UIUtil.LoadItem(uiItem, item, 0)

                UIUtil.SetClickCallback(uiItem.gameObject, function(go)
                    if go ~= ui.tooltip then
                        local itemData = uiItem.data
                        if itemData.id < 0 then
                            local buff = TableMgr:GetSlgBuffData(itemData.buff_id)
                            Tooltip.ShowItemTip({ name = TextUtil.GetSlgBuffTitle(buff), text = TextUtil.GetSlgBuffDescription(buff) })
                        else
                            Tooltip.ShowItemTip({ name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData) })
                        end
                        ui.tooltip = uiItem.gameObject
                    else
                        Tooltip.HideItemTip()
                        ui.tooltip = nil
                    end
                end)      
            end
        end


        local rewards = Global.MakeAward(cardInfo.giftStr)
        ShowRewards(rewards.heros, rewards.items, rewards.armys, ui.warcard.grid2)
    else
        ui.tabs[5].btn:SetActive(false)
        ui.tabs[5].gameObject:SetActive(false)
        ui.tab_grid.repositionNow = true
        if currentTab == 5 then
            ShowTab(1)
        end
    end
end

local function RemoveCard(uiCard)
    local tab = uiCard.tab
    local subType = GetCardSubType(uiCard.cardInfo, tab)

    uiCard.cardInfo = nil
    uiCard.gameObject:SetActive(false)

    ui.tabs[tab].cardList.cardsBySubType[subType] = nil
end

local function SortCards(tab)
    if tab == 4 or tab == 5 then
        return
    end
    local uiTab = ui.tabs[tab]

    table.sort(uiTab.cardList.cards, function(uiCard1, uiCard2)
        local cardInfo1 = uiCard1.cardInfo
        local cardInfo2 = uiCard2.cardInfo

        if cardInfo1 and cardInfo2 then
            local iapGoodInfo1 = cardInfo1.goodInfo
            local iapGoodInfo2 = cardInfo2.goodInfo

            if iapGoodInfo1.order ~= iapGoodInfo2.order then
                return iapGoodInfo1.order < iapGoodInfo2.order
            end

            return iapGoodInfo1.subType < iapGoodInfo2.subType
        else
            return cardInfo1 ~= nil
        end
    end)

    uiTab.cardList.grid.repositionNow = true
end

-- local function AddCountDown()
--     CountDown.Instance:Add(_M._NAME, Global.GetFiveOclockCooldown(), CountDown.CountDownCallBack(function(time)
--         if time == "00:00:00" then
--             AddCountDown()
--         else
--             for _, uiTab in ipairs(ui.tabs) do
--                 local config = uiTab.config
--                 if config and config["refreshtime"] then
--                     uiTab.banner.countdown.text = time
--                 end
--             end
--         end
--     end))
-- end

function UpdateVip()
    ui.vip:Update()
end

local function UpdateTabNotice(tab)
    if tab == 1 then
        ui.tabs[1].notice:SetActive(MonthCardData.HasUnclaimedAward())
    elseif tab == 2 then
        ui.tabs[2].notice:SetActive(HeroCardData.HasUnclaimedAward())
    elseif tab == 3 then
        ui.tabs[3].notice:SetActive(UnionCardData.HasUnclaimedAward())
    elseif tab == 4 then
        ui.tabs[4].notice:SetActive(NewbieCardData.HasUnclaimedAward())
    elseif tab == 5 then
        ui.tabs[5].notice:SetActive(WarCardData.HasUnclaimedAward())
    end
end

local function Redraw(tab)
    print(debug.traceback())
    if tab then
        local uiTab = ui.tabs[tab]

        local config = uiTab.config

        uiTab.banner.title.text = config["title"] and TextMgr:GetText(config["title"]) or ""
        uiTab.banner.description.text = config["des"] and TextMgr:GetText(config["des"]) or ""

        if config["banner"] then
            uiTab.banner.background.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", config["banner"])
        end

        if config["refreshtime"] then
            local timeStamp = Global.GetFiveOclockCooldown()

            uiTab.banner.countdown.text = Global.GetLeftCooldownTextLong(timeStamp) -- System.String.Format(TextMgr:GetText(config["refreshtime"]), time)
        
            AddCountdown(uiTab.banner.countdown, timeStamp, Global.GetFiveOclockCooldown)
        else
            RemoveCountdown(uiTab.banner.countdown)
        end

        if tab == 1 then
            uiTab.cardList.cardsBySubType = {}

            local uiCards = uiTab.cardList.cards

            local i = 1
            for subType, cardInfo in pairs(MonthCardData.GetAvailableCard()) do
                print(subType, cardInfo)
                if i > #uiCards then
                    AddCard(tab, cardInfo)
                else
                    UpdateCard(uiCards[i], cardInfo)
                end

                i = i + 1
            end

            while i <= #uiCards do
                uiCards[i].cardInfo = nil
                uiCards[i].gameObject:SetActive(false)
            end
        elseif tab == 2 then
            uiTab.cardList.cardsBySubType = {}

            local uiCards = uiTab.cardList.cards

            local i = 1
            for subType, cardInfo in pairs(HeroCardData.GetAvailableCard()) do
                if i > #uiCards then
                    AddCard(tab, cardInfo)
                else
                    UpdateCard(uiCards[i], cardInfo)
                end

                i = i + 1
            end

            while i <= #uiCards do
                uiCards[i].cardInfo = nil
                uiCards[i].gameObject:SetActive(false)
            end
        elseif tab == 3 then
            uiTab.cardList.cardsBySubType = {}
            
            local uiCards = uiTab.cardList.cards

            local i = 1
            for subType, cardInfo in pairs(UnionCardData.GetAvailableCard()) do
                if i > #uiCards then
                    AddCard(tab, cardInfo)
                else
                    UpdateCard(uiCards[i], cardInfo)
                end

                i = i + 1
            end

            while i <= #uiCards do
                uiCards[i].cardInfo = nil
                uiCards[i].gameObject:SetActive(false)
            end
        elseif tab == 4 then
            for subType, cardInfo in pairs(NewbieCardData.GetAvailableCard()) do
                UpdateNewbie(cardInfo)
            end
        elseif tab == 5 then
            for subType, cardInfo in pairs(WarCardData.GetAvailableCard()) do
                UpdateWar(cardInfo)
            end
        end

        UpdateTabNotice(tab)

        SortCards(tab)
    else
        for tab, uiTab in ipairs(ui.tabs) do
            print(tab, uiTab, uiTab.config)
            if uiTab.config then
                Redraw(tab)
            end
        end
    end

    -- CountDown.Instance:Remove(_M._NAME)
    -- AddCountDown()
end

function ShowTab(tab)
    if not tab then
        for i, v in ipairs(ui.tabs) do
            if v.btn.activeInHierarchy then
                tab = i
            end
        end
    end

    SetCurrentTab(tab)
    ui.tabs[tab].toggle.value = true
end

function Show(_, tab)
    if not IsInViewport() then
        SetCurrentTab(tab)
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
end

function Awake()
    ui = {}
    ui.tabs = {}
    ui.countdowns = {}

    ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    ui.tab_grid = transform:Find("Container/Tabs/Grid/"):GetComponent("UIGrid")
    for i = 1, transform:Find("Container/Contents").childCount do
        local uiTab = {}

        uiTab.transform = transform:Find("Container/Contents/" .. i)
        uiTab.gameObject = uiTab.transform.gameObject

        uiTab.banner = {}
        uiTab.banner.transform = uiTab.transform:Find("banner")
        uiTab.banner.gameObject = uiTab.banner.transform.gameObject
        uiTab.banner.background = uiTab.banner.transform:GetComponent("UITexture")
        uiTab.banner.title = uiTab.banner.transform:Find("Label"):GetComponent("UILabel")
        uiTab.banner.description = uiTab.banner.transform:Find("tips01"):GetComponent("UILabel")
        uiTab.banner.countdown = uiTab.banner.transform:Find("time (1)"):GetComponent("UILabel")

        uiTab.cardList = {}
        if i < 4 then
            uiTab.cardList.transform = uiTab.transform:Find("bg_mid/Grid")
            uiTab.cardList.gameObject = uiTab.cardList.transform.gameObject
            uiTab.cardList.grid = uiTab.cardList.transform:GetComponent("UIGrid")
            uiTab.cardList.newCard = transform:Find("Container/Cards/" .. i).gameObject
            uiTab.cardList.cards = {}
        end

        uiTab.btn = transform:Find("Container/Tabs/Grid/" .. i).gameObject
        uiTab.notice = transform:Find("Container/Tabs/Grid/" .. i .. "/red").gameObject
        uiTab.toggle = transform:Find("Container/Tabs/Grid/" .. i):GetComponent("UIToggle")
        if i == 1 then
            uiTab.btn:SetActive(UIUtil.GetTableLength(MonthCardData.GetAvailableCard()) > 0)
        elseif i == 2 then
            uiTab.btn:SetActive(UIUtil.GetTableLength(HeroCardData.GetAvailableCard()) > 0)
        elseif i == 3 then
            uiTab.btn:SetActive(UIUtil.GetTableLength(UnionCardData.GetAvailableCard()) > 0)
        end
        table.insert(ui.tabs, uiTab)
        if type(TAB_ACTIVITY_ID[i]) == "number" then
            local activity = ActivityData.GetActivityConfig(TAB_ACTIVITY_ID[i])
            if activity then
                local configid = activity.configid
                if configid == nil or configid == "" or configid == 0 then
                    configid = activity.id
                end
                uiTab.config = TableMgr:GetActivityShowCongfig(configid, activity.templete)
            end
        else
            local ids = string.split(TAB_ACTIVITY_ID[i], ",")
            for k, s in ipairs(ids) do
                local activity = ActivityData.GetActivityConfig(tonumber(s))
                if activity then
                    uiTab.config = TableMgr:GetActivityShowCongfig(3004, 604)
                end
            end
        end
        if i == 4 or i == 5 then
            uiTab.config = {}
        end
    end
    ui.tab_grid.repositionNow = true

    ui.vip = VipWidget(transform:Find("Container/Vip"))

    EventDispatcher.Bind(MonthCardData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo, change)
        if change > 0 then
            AddCard(1, availableCard)
            SortCards(1)
        elseif change < 0 then
            RemoveCard(ui.tabs[1].cardList.cardsBySubType[cardInfo.goodInfo.type])
            SortCards(1)
        end
    end)

    EventDispatcher.Bind(MonthCardData.OnPurchaseStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        UpdateCard(ui.tabs[1].cardList.cardsBySubType[cardInfo.goodInfo.type])
    end)

    EventDispatcher.Bind(MonthCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        local uiCard = ui.tabs[1].cardList.cardsBySubType[cardInfo.goodInfo.type]

        if uiCard then
            UpdateCard(uiCard)

            local iapGoodInfo = cardInfo.goodInfo

            if cardInfo.day == iapGoodInfo.day then
                MessageBox.Show(TextMgr:GetText("pay_ui11"), function()
                    store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
                end, function() end, string.make_price(iapGoodInfo.price))
            end
        end

        UpdateTabNotice(1)
    end)

    EventDispatcher.Bind(HeroCardData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo, change)
        if change > 0 then
            AddCard(2, availableCard)
            SortCards(2)
        elseif change < 0 then
            RemoveCard(ui.tabs[2].cardList.cardsBySubType[cardInfo.goodInfo.subType])
            SortCards(2)
        end
    end)

    EventDispatcher.Bind(HeroCardData.OnPurchaseStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        UpdateCard(ui.tabs[2].cardList.cardsBySubType[cardInfo.goodInfo.subType])
    end)

    EventDispatcher.Bind(HeroCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        local uiCard = ui.tabs[2].cardList.cardsBySubType[cardInfo.goodInfo.subType]

        if uiCard then
            UpdateCard(uiCard)

            local iapGoodInfo = cardInfo.goodInfo

            if cardInfo.day == iapGoodInfo.day then
                MessageBox.Show(TextMgr:GetText("pay_ui11"), function()
                    store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
                end, function() end, string.make_price(iapGoodInfo.price))
            end
        end

        UpdateTabNotice(2)
    end)

    EventDispatcher.Bind(UnionCardData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo, change)
        if change > 0 then
            AddCard(3, availableCard)
            SortCards(3)
        elseif change < 0 then
            RemoveCard(ui.tabs[3].cardList.cardsBySubType[cardInfo.goodInfo.subType])
            SortCards(3)
		else
			 local uiCard = ui.tabs[3].cardList.cardsBySubType[cardInfo.goodInfo.subType]

			if uiCard then
				UpdateCard(uiCard)
				if GUIMgr:FindMenu("UnionInfo") ~= nil then
					UnionInfo.LoadUI()
				end
			end
        end
    end)

    EventDispatcher.Bind(UnionCardData.OnPurchaseStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        UpdateCard(ui.tabs[3].cardList.cardsBySubType[cardInfo.goodInfo.subType])
    end)

    EventDispatcher.Bind(UnionCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        local uiCard = ui.tabs[3].cardList.cardsBySubType[cardInfo.goodInfo.subType]

        if uiCard then
            UpdateCard(uiCard)

            local iapGoodInfo = cardInfo.goodInfo

            if cardInfo.day == iapGoodInfo.day then
                MessageBox.Show(TextMgr:GetText("pay_ui11"), function()
                    store.StartPay(iapGoodInfo, TextMgr:GetText(iapGoodInfo.name))
                end, function() end, string.make_price(iapGoodInfo.price))
            end
        end

        UpdateTabNotice(3)
    end)

    EventDispatcher.Bind(NewbieCardData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo, change)
        UpdateNewbie(cardInfo)
        UpdateTabNotice(4)
    end)

    EventDispatcher.Bind(NewbieCardData.OnPurchaseStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        UpdateNewbie(cardInfo)
        UpdateTabNotice(4)
    end)

    EventDispatcher.Bind(NewbieCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        UpdateNewbie(cardInfo)
        UpdateTabNotice(4)
    end)

    EventDispatcher.Bind(WarCardData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo, change)
        UpdateWar(cardInfo)
        UpdateTabNotice(5)
    end)

    EventDispatcher.Bind(WarCardData.OnPurchaseStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        UpdateWar(cardInfo)
        UpdateTabNotice(5)
    end)

    EventDispatcher.Bind(WarCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo)
        UpdateWar(cardInfo)
        UpdateTabNotice(5)
    end)

    MainData.AddListener(UpdateVip)

    UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)
end

function Start()
    ui.lastUpdateTime = Serclimax.GameTime.GetSecTime()

    UpdateVip()
    Redraw()

    ShowTab(currentTab)
end

function Update()
    local now = Serclimax.GameTime.GetSecTime()
    if now ~= ui.lastUpdateTime then
        ui.lastUpdateTime = now

        for uiLabel, countdown in pairs(ui.countdowns) do
            local timeStamp = countdown.timeStamp

            if timeStamp < now then
                if countdown.GetNewTimeStamp then
                    timeStamp = countdown.GetNewTimeStamp()
                    countdown.timeStamp = timeStamp

                    uiLabel.text = Global.SecondToTimeLong(timeStamp - now)
                else
                    uiLabel.text = ""

                    RemoveCountdown(uiLabel)
                end
            else
                uiLabel.text = Global.SecondToTimeLong(timeStamp - now)
            end
        end
    end
end

function Close()
    EventDispatcher.UnbindAll(_M)

    MainData.RemoveListener(UpdateVip)

    UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)

    -- CountDown.Instance:Remove(_M._NAME)

    ui = nil
    currentTab = nil
end

----- Template:Goldstore --------------------------------------------------------
function HasNotice(config)
    return MonthCardData.HasUnclaimedAward() or HeroCardData.HasUnclaimedAward() or UnionCardData.HasUnclaimedAward() or NewbieCardData.HasUnclaimedAward() or WarCardData.HasUnclaimedAward()
end

function IsAvailable(config)
    for _, activityID in ipairs(TAB_ACTIVITY_ID) do
        if ActivityData.IsActivityAvailable(activityID) then
            return true
        end
    end

    return false
end

Goldstore.RegisterAsTemplate(3, _M)
---------------------------------------------------------------------------------
