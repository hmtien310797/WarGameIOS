module("store", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local Format = System.String.Format

local _ui, UpdateUI, UpdateTop, UpdateCenter, UpdateItem

local hasUncollectedDailyVipExp = false

local history
local historyConfigs
local shopItems = {}
local lockedItems = {}

local timedGiftPack = {}
local newTimedGiftPacks = {}
local globalLimitPacks = {}

local giftPacksWithCountdown = {}

local lastUpdateTime = 0

local minEndTime
local paycurrency = 0

------ CONSTANTS ------
local NUM_GOOD_TYPE = 7
local DO_HIDE = { [ShopMsg_pb.IAPGoodType_WeekCard] = true, 
				  [ShopMsg_pb.IAPGoodType_MonthCard] = true,
				  [ShopMsg_pb.IAPGoodType_HeroCard] = true,  }
-----------------------

local function LockItem(id)
	table.insert(lockedItems, id)
end

local function IsItemLocked(id)
	for _, _id in ipairs(lockedItems) do
		if _id == id then
			return true
		end
	end

	return false
end

local function UnlockItem(id)
	for i = #lockedItems, 1, -1 do
		if id == lockedItems[i] then
			table.remove(lockedItems, i)
		end
	end
end

function HasNewItem()
	-- Global.LogDebug(_M, "HasNewItem")
	if history == nil then
		return false
	end
	for tab, tabHistory in pairs(history) do
		for index, hasNotice in pairs(tabHistory) do
			if hasNotice then
				return true
			end
		end
	end

	return false
end

function HasNotice()
	-- Global.LogDebug(_M, "HasNotice")

	return hasUncollectedDailyVipExp or HasNewItem()
end

function HasNewTimedGiftPack()
	-- Global.LogDebug(_M, "HasNewTimedGiftPack")

	return #newTimedGiftPacks ~= 0
end

function ShowNewTimedGiftPack()
	-- Global.LogDebug(_M, "ShowNewTimedGiftPack")

	TimedBag.Show(newTimedGiftPacks)
end

function ClearNewTimedGiftPack()
	-- Global.LogDebug(_M, "ClearNewTimedGiftPack")

	newTimedGiftPacks = {}
end

local function RemoveNewTimedGiftPack(goodInfo)
	-- Global.LogDebug(_M, "RemoveNewTimedGiftPack", goodInfo)

	for i = #newTimedGiftPacks, 1, -1 do
		if newTimedGiftPacks[i].index == goodInfo.index then
			table.remove(newTimedGiftPacks, i)
		end
	end
end

local function ReadHistoryConfigBit(zeroBasedIndex)
	-- Global.LogDebug(_M, "ReadHistoryConfigBit", zeroBasedIndex)

	return historyConfigs and bit.band(bit.rshift(historyConfigs[tostring(math.ceil(zeroBasedIndex / 32))] or 0, zeroBasedIndex % 32), 1) or 1
end

local function SetHistoryConfigBit(zeroBasedIndex, bitNumber)
	-- Global.LogDebug(_M, "SetHistoryConfigBit", zeroBasedIndex, bitNumber)

	if historyConfigs == nil then
		historyConfigs = {}
	end

	local index_config = tostring(math.ceil(zeroBasedIndex / 32))
	if historyConfigs[index_config] == nil then
		historyConfigs[index_config] = 0
	end

	if bitNumber == 0 then
		if ReadHistoryConfigBit(zeroBasedIndex) == 1 then
			historyConfigs[index_config] = historyConfigs[index_config] - bit.lshift(1, zeroBasedIndex % 32)
		end
	elseif bitNumber == 1 then
		historyConfigs[index_config] = bit.bor(historyConfigs[index_config], bit.lshift(1, zeroBasedIndex % 32))
	end
end

local function MakeItemHistory(tab, index, hasNotice)
	-- Global.LogDebug(_M, "MakeItemHistory", tab, index, hasNotice)

	if history[tab] == nil then
		history[tab] = {}
	end

	if hasNotice == nil then
		history[tab][index] = ReadHistoryConfigBit(index - 1) == 0
	else
		history[tab][index] = hasNotice
	end
end

local function GetItemHistory(tab, index)
	-- Global.LogDebug(_M, "GetItemHistory", tab, index)

	if history[tab] == nil then
		return nil
	end

	return history[tab][index]
end

local function SetItemHistory(tab, index, hasNotice)
	-- Global.LogDebug(_M, "SetItemHistory", tab, index, hasNotice)

	if GetItemHistory(tab, index) == nil then
		MakeItemHistory(tab, index, hasNotice)
	else
		history[tab][index] = hasNotice
	end

	SetHistoryConfigBit(index - 1, hasNotice and 0 or 1)
end

local function LoadHistory(goodInfos)
	-- Global.LogDebug(_M, "LoadHistory", goodInfos)

	history = {}
	historyConfigs = ConfigData.GetCashShopConfig()

	local isFirstTime = historyConfigs == nil
	for _, goodInfo in ipairs(goodInfos) do
		if goodInfo.priceType == 0 then
			if isFirstTime or goodInfo.tab == 7 then
				MakeItemHistory(goodInfo.tab, goodInfo.index, false)
				SetHistoryConfigBit(goodInfo.index - 1, 1)
			else
				MakeItemHistory(goodInfo.tab, goodInfo.index)
			end
		end
	end
end

local function UpdateHistory(goodInfos)
	-- Global.LogDebug(_M, "UpdateHistory", goodInfos)

	if historyConfigs == nil then
		LoadHistory(goodInfos)
	else
		for _, goodInfo in ipairs(goodInfos) do
			if goodInfo.priceType == 0 then
				local tab = goodInfo.tab
				local index = goodInfo.index

				if GetItemHistory(tab, index) == nil then
					MakeItemHistory(tab, index)
				end
			end
		end
	end
end

local function SaveHistory()
	-- Global.LogDebug(_M, "SaveHistory")

	-- local config = {}
	-- for tab, tabHistory in pairs(history) do
	-- 	for index, hasNotice in pairs(tabHistory) do
	-- 		local zeroBasedIndex = index - 1
	-- 		if config[math.ceil(zeroBasedIndex / 32)] == nil then
	-- 			config[math.ceil(zeroBasedIndex / 32)] = 0
	-- 		end

	-- 		if not hasNotice then
	-- 			config[math.ceil(zeroBasedIndex / 32)] = bit.bor(config[math.ceil(zeroBasedIndex / 32)], bit.lshift(1, zeroBasedIndex % 32))
	-- 		end
	-- 	end
	-- end

	ConfigData.SetCashShopConfig(historyConfigs)
end

local function AddTimedGiftPack(goodInfo)
	-- Global.LogDebug(_M, "AddTimedGiftPack", goodInfo)

	for _, giftPackInfo in ipairs(timedGiftPack) do
		if giftPackInfo.index == goodInfo.index then
			return false
		end
	end

	table.insert(timedGiftPack, goodInfo)
	return true
end

local function SetTimedGiftPack(goodInfos)
	-- Global.LogDebug(_M, "SetTimedGiftPack", goodInfos)

	for _, goodInfo in ipairs(goodInfos) do
		if goodInfo.type == ShopMsg_pb.IAPGoodType_GiftTimeLimit then
			if AddTimedGiftPack(goodInfo) then
				table.insert(newTimedGiftPacks, goodInfo)
			end
		end
	end
end

local function RemoveGiftPackWithCountdown(goodInfo)
	for i = #giftPacksWithCountdown, 1, -1 do
		if giftPacksWithCountdown[i].id == goodInfo.id then
			table.remove(giftPacksWithCountdown, i)
		end
	end
end

local function AddGiftPackWithCountdown(goodInfo)
	table.insert(giftPacksWithCountdown, goodInfo)
	SetItemHistory(goodInfo.tab, goodInfo.index, true)

	if not minEndTime or goodInfo.endTime < minEndTime then
		minEndTime = goodInfo.endTime
	end
end

local function SetGiftPacksWithCountdown(goodInfos)
	local now = Serclimax.GameTime.GetSecTime()
	for _, goodInfo in ipairs(goodInfos) do
		if goodInfo.endTime ~= 0 then
			local isNew = true
			for _, giftPackWithCountdown in pairs(giftPacksWithCountdown) do
				if giftPackWithCountdown.id == goodInfo.id then
					isNew = false
					break
				end
			end

			if isNew then
				AddGiftPackWithCountdown(goodInfo)
			end
		end
	end
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

local function SetGlobalLimitPack(goodInfos)
	for _ , goodInfo in ipairs(goodInfos) do
		if goodInfo.globalLimit > 0 then
			globalLimitPacks[goodInfo.id] = goodInfo
		end
	end
end

local function AddDepth(go, add)
	local widgets = go:GetComponentsInChildren(typeof(UIWidget))
	for i = 0, widgets.Length - 1 do
		widgets[i].depth = widgets[i].depth + add
	end
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		local param = param:split("_")
		if param[1] == "item" then
			local itemdata = TableMgr:GetItemData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			else
			    if itemTipTarget == go then
			        Tooltip.HideItemTip()
			    else
			        itemTipTarget = go
			        Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			    end
			end
		else
			local itemdata = TableMgr:GetHeroData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		        end
		    end
		end
	else
		Tooltip.HideItemTip()
	end
end

local function CloseSelf()
	Global.CloseUI(_M)
end

local function OnUICameraClick()
	Tooltip.HideItemTip()
end

function Awake()
	if _ui == nil then
		_ui = {}
	end

	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/btn_close").gameObject
	
	_ui.typebtnsroot = transform:Find("Container/bg_frane/bg_edge/TabBtnRoot"):GetComponent("UIGrid")
	_ui.typebtns = {}
	for i = 1, NUM_GOOD_TYPE do
		_ui.typebtns[i] = transform:Find(Format("Container/bg_frane/bg_edge/TabBtnRoot/button{0}", i)).gameObject
		_ui.typebtns[i]:GetComponent("UIToggle").value = false
	end

	_ui.rootRight = transform:Find("Container/bg_frane/bg_edge/content").gameObject
	
	_ui.giftName = transform:Find("Container/bg_frane/bg_edge/content/mid_right/top/name"):GetComponent("UILabel")
	_ui.vipCondition = transform:Find("Container/bg_frane/bg_edge/content/mid_right/top/vip"):GetComponent("UILabel")
	_ui.giftTextures = {}
	_ui.giftTextures[1] = transform:Find("Container/bg_frane/bg_edge/content/bag_icon"):GetComponent("UITexture")
	_ui.giftTextures[2] = transform:Find("Container/bg_frane/bg_edge/content/mid_right/Texture"):GetComponent("UITexture")
	
	_ui.giftInfo = transform:Find("Container/bg_frane/bg_edge/content/mid_right/Texture/Label"):GetComponent("UILabel")
	
	_ui.totleGold = transform:Find("Container/bg_frane/bg_edge/content/mid_right/Container01/number"):GetComponent("UILabel")
	_ui.timeLabel = transform:Find("Container/bg_frane/bg_edge/content/mid_right/Container02/number"):GetComponent("UILabel")
	
	_ui.btn_buy = transform:Find("Container/bg_frane/bg_edge/content/mid_right/button").gameObject
	_ui.priceLabel = transform:Find("Container/bg_frane/bg_edge/content/mid_right/button/Label"):GetComponent("UILabel")
	_ui.discount = transform:Find("Container/bg_frane/bg_edge/content/mid_right/discount"):GetComponent("UILabel")
	_ui.textvip = transform:Find("Container/bg_frane/bg_edge/content/mid_right/text_vip"):GetComponent("UILabel")
	
	_ui.limitLabel = transform:Find("Container/bg_frane/bg_edge/content/text_purchase/Label"):GetComponent("UILabel")
	
	_ui.ScrollTop = transform:Find("Container/bg_frane/bg_edge/content/Scroll View_top"):GetComponent("UIScrollView")
	_ui.GridTop = transform:Find("Container/bg_frane/bg_edge/content/Scroll View_top/Grid"):GetComponent("UIGrid")
	_ui.goods = transform:Find("Container/bg_frane/bg_edge/content/Scroll View_top/Grid/goods")
	_ui.goods.transform.parent = transform
	
	_ui.ScrollCenter = transform:Find("Container/bg_frane/bg_edge/content/Scroll View"):GetComponent("UIScrollView")
	_ui.GridCenter = transform:Find("Container/bg_frane/bg_edge/content/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.row = transform:Find("Container/bg_frane/bg_edge/content/Scroll View/Grid/Row")
	_ui.row.transform.parent = transform
	_ui.goldnum = transform:Find("Container/bg_frane/bg_edge/content/gold/Label"):GetComponent("UILabel")
	
	_ui.itemPrefab = ResourceLibrary.GetUIPrefab("CommonItem/Item_CommonNew_store")
	_ui.heroPrefab = ResourceLibrary.GetUIPrefab("CommonItem/hero_store")
	
	_ui.none = transform:Find("Container/bg_frane/bg_edge/none").gameObject
	_ui.has = transform:Find("Container/bg_frane/bg_edge/content").gameObject

	_ui.tip_dailyVipExpCollected = transform:Find("Container/bg_frane/bg_edge/VIP/button_gou").gameObject
	_ui.btnCollectDailyVipExp = transform:Find("Container/bg_frane/bg_edge/VIP/button").gameObject
	_ui.dailyVipExp = transform:Find("Container/bg_frane/bg_edge/VIP"):GetComponent("UILabel")
	SetClickCallback(_ui.btnCollectDailyVipExp, function()
		-- VipExp.Show(function()
			-- local request = VipMsg_pb.MsgObtainVipExpRequest()
			-- Global.Request(Category_pb.Vip, VipMsg_pb.VipTypeId.MsgObtainVipExpRequest, request, VipMsg_pb.MsgObtainVipExpResponse, function(msg)
			-- 	if msg.code == ReturnCode_pb.Code_OK then
			-- 		local logininfo = VipData.GetLoginInfo()
			-- 		local itemData = TableMgr:GetItemData(15)
			-- 		local itemIcon = ResourceLibrary:GetIcon("Item/", itemData.icon)
			-- 		FloatText.Show(TextUtil.GetItemName(itemData) .. "x" .. logininfo.todayObtain, Color.green, itemIcon)
					
			-- 		MainData.UpdateVip(msg.vipInfo)

			-- 		VipData.UpdateDailyVipExpInfo()
			-- 		hasUncollectedDailyVipExp = false
			-- 		_ui.btnCollectDailyVipExp:SetActive(false)
			-- 		_ui.tip_dailyVipExpCollected:SetActive(true)
			-- 		UpdateVipExpNotice()
			-- 		MainCityUI.UpdateCashShopNotice()
			-- 	else
			-- 		Global.ShowError(msg.code)
			-- 	end
			-- end)
		
			VipData.CollectDailyVipExp(function()
				UpdateVipExpNotice()
				MainCityUI.UpdateCashShopNotice()
				GUIMgr:SendDataReport("efun", "vip_15exp")
			end)
		-- end)
	end)
	-- _ui.btnCollectDailyVipExp:SetActive(hasUncollectedDailyVipExp)
	-- transform:Find("Container/bg_frane/bg_edge/VIP/button_gou").gameObject:SetActive(not hasUncollectedDailyVipExp)

	_ui.notice = {}
	_ui.notice.dailyVipExp = transform:Find("Container/bg_frane/bg_edge/VIP/button/red").gameObject
	
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	
	-- AddDelegate(UICamera, "onPress", OnUICameraPress)
	UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)
end

local function UpdateCountDown(now)
	if now == nil then
		now = Serclimax.GameTime.GetSecTime()
	end

	if minEndTime and minEndTime < now then
		minEndTime = nil
	end
	
	-- 限时礼包
	for i = #timedGiftPack, 1, -1 do
		local goodInfo = timedGiftPack[i]
		if _ui ~= nil and _ui.items ~= nil then
			local uiItemTab = _ui.items[goodInfo.index]
			if uiItemTab ~= nil then
				local text_leftTime = Global.GetLeftCooldownTextLong(goodInfo.endTime)
		    	uiItemTab:Find("countdown/time"):GetComponent("UILabel").text = text_leftTime
		    	uiItemTab:Find("selected effect/countdown/time"):GetComponent("UILabel").text = text_leftTime
		    end
		end

		if now >= goodInfo.endTime then
			table.remove(timedGiftPack, i)
			RemoveNewTimedGiftPack(goodInfo)
			RemoveGiftPackWithCountdown(goodInfo)

			if _ui then
				Show(_ui.tab, _ui.index)
			end
		elseif not minEndTime or goodInfo.endTime < minEndTime then
			minEndTime = goodInfo.endTime
		end
	end

	for i, goodInfo in pairs(giftPacksWithCountdown) do
		if goodInfo.type ~= ShopMsg_pb.IAPGoodType_GiftTimeLimit then
			if _ui and _ui.items then
				local uiItemTab = _ui.items[goodInfo.index]
				if uiItemTab ~= nil then
					local text_leftTime = Global.GetLeftCooldownTextLong(goodInfo.endTime)
			    	uiItemTab:Find("countdown/time"):GetComponent("UILabel").text = text_leftTime
			    	uiItemTab:Find("selected effect/countdown/time"):GetComponent("UILabel").text = text_leftTime
			    end
			end

			if now >= goodInfo.endTime then
				SetItemHistory(goodInfo.tab, goodInfo.index, false)
				RemoveGiftPackWithCountdown(goodInfo)

				if _ui then
					Show(_ui.tab, _ui.index)
				end
			elseif not minEndTime or goodInfo.endTime < minEndTime then
				minEndTime = goodInfo.endTime
			end
		end
	end

	MainCityUI.UpdateCashShopCountDown(minEndTime)
end

local function ShopInfoRequest(callback, type)
	local req = ShopMsg_pb.MsgIAPGoodInfoRequest()
	req.type = type or 0
	LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPGoodInfoRequest, req:SerializeToString(), function (typeId, data)
        local msg = ShopMsg_pb.MsgIAPGoodInfoResponse()
        msg:ParseFromString(data)

        UpdateHistory(msg.goodInfos)
        SetTimedGiftPack(msg.goodInfos)
        SetGiftPacksWithCountdown(msg.goodInfos)

        if callback ~= nil then
        	callback(msg)
    	end
    end, true)
end

local function RequestTimedGiftPackInfo(callback)
	-- Global.LogDebug(_M, "RequestTimedGiftPackInfo", callback)

	ShopInfoRequest(callback, ShopMsg_pb.IAPGoodType_GiftTimeLimit)
end

function RequestCardInfo(i, callback)
	ShopInfoRequest(function(msg)
		cards[i] = msg.goodInfos[1]
		callback()
	end, i + 2)
end

function UpdateTimedGiftPack()
	-- Global.LogDebug(_M, "UpdateTimedGiftPack")

	NotifyInfoData.OnNotifyPush(ClientMsg_pb.ClientNotifyType_TimedGiftPack)

	RequestTimedGiftPackInfo(function()
		MainCityUI.UpdateCashShopNotice()
		UpdateCountDown()
		ShowNewTimedGiftPack()
	end)
end

function SuccessfullyPurchase(id)
	-- UnlockItem(id)

	if id >= 700 and id < 800 then
		for i = #timedGiftPack, 1, -1 do
			local goodInfo = timedGiftPack[i]
			if goodInfo.id == id then
				table.remove(timedGiftPack, i)
				RemoveNewTimedGiftPack(goodInfo)
			end
		end
	end
	if not MainData.HadRecharged() then
		GUIMgr:SendDataReport("efun", "np")
	end

	if _ui ~= nil then
		Show(_ui.tab, _ui.index)
	end
	Global.GGUIMgr:SendDataReport("efun","Purchase_" .. paycurrency)
	Global.GGUIMgr:SendDataReport("efun","Purchase")
	Global.GGUIMgr:SendDataReport("muzhi","" .. paycurrency)
end

cards = {}
function BuyCard(i)
	local card = cards[i]
	StartPay(card, TextMgr:GetText(card.name))
end

function ProcessHuawei(_data, huaweiname)
	local map = {}
	map["amount"] = _data.price
	map["applicationID"] = "10790059"
	map["country"] = "SG"
	map["currency"] = "SGD"
	map["productName"] = huaweiname
	map["productDesc"] = map["productName"]
    map["requestId"] = "?"
    map["sdkChannel"] = "4"
    map["siteId"] = "3"
    map["url"] = "http://47.88.84.160:7501/pay/huawei/deliver"
    map["urlver"] = "2"
    map["userID"] = "890086000102036723"
    local key_table = {}
    for key,_ in pairs(map) do
    	table.insert(key_table, key)
    end
    table.sort(key_table)
    local n = 1
    local str = ""
    for _, key in pairs(key_table) do
    	if n ~= 1 then
    		str = str .. "&"
    	end
    	str = str .. key .. "=" .. map[key]
    	n = n + 1
    end
    return str, map
end

function StartPay(_data, huaweiname)
	-- if IsItemLocked(_data.id) then
	--	MessageBox.Show("ITEM LOCKED")
	--	return
	-- end
	paycurrency = "" .. _data.price
	_data.price = GiftPackData.Exchange(_data.price)
	platformType = GUIMgr:GetPlatformType()
	if UnityEngine.Application.isEditor then
		platformType = LoginMsg_pb.AccType_adr_mango
	end

	local chargeChanelType = 0
	local chargeParam = ""
	local mapParam = ""
	if platformType == LoginMsg_pb.AccType_adr_googleplay then
		chargeChanelType = ShopMsg_pb.CCT_google
	elseif platformType == LoginMsg_pb.AccType_adr_huawei then
		chargeChanelType = ShopMsg_pb.CCT_huawei
		chargeParam, mapParam = ProcessHuawei(_data, huaweiname)
	elseif platformType == LoginMsg_pb.AccType_adr_efun then
		chargeChanelType = ShopMsg_pb.CCT_efun
	end

	local req = ShopMsg_pb.MsgIAPOrderIdRequest()
	req.id = _data.id
	req.param = chargeParam
	req.chanel = chargeChanelType
	LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPOrderIdRequest, req:SerializeToString(), function (typeId, data)
        local msg = ShopMsg_pb.MsgIAPOrderIdResponse()
        msg:ParseFromString(data)
        if msg.code == 0 then
			local sendparam = {}
			sendparam["virtualcurrency"] = _data.itemBuy.item.item[1] == nil and 0 or tonumber(_data.itemBuy.item.item[1].num)
        	if platformType == LoginMsg_pb.AccType_adr_googleplay then
        		if InventortList ~= nil then
					sendparam["currency"] = InventortList[_data.productId]["price_amount_micros"]
					sendparam["currencytype"] = InventortList[_data.productId]["price_currency_code"]
				else
					sendparam["currency"] = "" .. _data.price
					sendparam["currencytype"] = "USD"
				end
			elseif platformType == LoginMsg_pb.AccType_adr_huawei then
				mapParam["userName"] = "weywell"
				mapParam["serviceCatalog"] = "X6"
				mapParam["extReserved"] = msg.orderId
				mapParam["requestId"] = msg.requestId
				mapParam["sign"] = msg.generalSign
				sendparam["huawei"] = cjson.encode(mapParam)
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "SGD"
			elseif platformType == LoginMsg_pb.AccType_adr_tmgp then
				if GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug or GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease then
					sendparam["zoneid"] = "1"
				else
					sendparam["zoneid"] = msg.zoneid
				end
				sendparam["isCanChange"] = "0"
				sendparam["currency"] = "" .. (_data.price * 10)
				sendparam["currencytype"] = "RMB"
			elseif platformType == LoginMsg_pb.AccType_adr_efun or platformType == LoginMsg_pb.AccType_ios_india or platformType == LoginMsg_pb.AccType_ios_efun or
				   platformType == LoginMsg_pb.AccType_adr_steam then
				sendparam["zoneid"] = "" .. msg.zoneid
				sendparam["roleid"] = "" .. MainData.GetCharId()
				sendparam["roleName"] = "" .. MainData.GetCharName()
				sendparam["roleLevel"] = "" .. MainData.GetLevel()
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "USD"
			elseif platformType == LoginMsg_pb.AccType_ios_tw_digiSky or platformType == LoginMsg_pb.AccType_ios_kr_digiSky then
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "USD"
			elseif platformType == LoginMsg_pb.AccType_adr_muzhi  or 
				   Global.IsIosMuzhi() or 
				   platformType == LoginMsg_pb.AccType_adr_opgame or 
				   platformType == LoginMsg_pb.AccType_adr_official or
				   platformType == LoginMsg_pb.AccType_ios_official or
				   platformType == LoginMsg_pb.AccType_adr_official_branch then
				sendparam["userid"] = login.GetUID()
				sendparam["zoneid"] = "" .. msg.zoneid
				sendparam["zoneName"] = ServerListData.GetCurrentZoneName()
				sendparam["roleid"] = "" .. MainData.GetCharId()
				sendparam["roleName"] = "" .. MainData.GetCharName()
				sendparam["roleLevel"] = "" .. MainData.GetLevel()
				sendparam["roleVipLevel"] = "" .. MainData.GetVipLevel()
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "RMB"
				sendparam["ratio"] = "" .. math.floor(sendparam["virtualcurrency"] / _data.price)
				sendparam["goods"] = TextMgr:GetText(_data.name)
				sendparam["goodsdesc"] = TextMgr:GetText(_data.desc)
			elseif platformType == LoginMsg_pb.AccType_adr_mango or
				   platformType == LoginMsg_pb.AccType_adr_quick or
				   platformType == LoginMsg_pb.AccType_adr_qihu then
				sendparam["userid"] = login.GetUID()
				sendparam["zoneid"] = "" .. msg.zoneid
				sendparam["zoneName"] = ServerListData.GetCurrentZoneName()
				sendparam["roleid"] = "" .. MainData.GetCharId()
				sendparam["roleName"] = "" .. MainData.GetCharName()
				sendparam["roleLevel"] = "" .. MainData.GetLevel()
				sendparam["roleVipLevel"] = "" .. MainData.GetVipLevel()
				sendparam["roleCreateTime"] = "" .. MainData.GetCreationTime()
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "RMB"
				sendparam["ratio"] = "" .. math.floor(sendparam["virtualcurrency"] / _data.price)
				sendparam["goodsid"] = "" .. _data.id
				sendparam["goods"] = TextMgr:GetText(_data.name)
				sendparam["goodsdesc"] = TextMgr:GetText(_data.desc)
				sendparam["pointname"] = "黄金"
			else
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "USD"
			end
			sendparam["orderid"] = msg.orderId
			sendparam["productid"] = _data.productId
			
			print(cjson.encode(sendparam))
			GUIMgr:LockScreen()
			GUIMgr:Recharge(cjson.encode(sendparam), msg.orderId, sendparam["currency"])
			coroutine.start(function()
				if platformType == LoginMsg_pb.AccType_adr_mango or 
					platformType == LoginMsg_pb.AccType_adr_opgame or
					platformType == LoginMsg_pb.AccType_adr_official or
					platformType == LoginMsg_pb.AccType_ios_official or
					platformType == LoginMsg_pb.AccType_adr_official_branch then
					coroutine.wait(10)
				else
					coroutine.wait(120)
				end
				GUIMgr:UnlockScreen()
			end)
		else
			Global.ShowError(msg.code)
		end
    end, true)
end

function UpdateNewItemNotice(tab)
	if tab == nil then
		for tab, _ in pairs(_ui.tabmsg) do
			UpdateNewItemNotice(tab)
		end
	else
		local flag = false
		for index, hasNotice in pairs(history[tab]) do
			if hasNotice then
				flag = true
			end

			if tab == _ui.tab then
				local uiItem = _ui.items and _ui.items[index]
				if uiItem then
					uiItem:Find("red").gameObject:SetActive(hasNotice)
				end
			end
		end

		_ui.typebtns[tab].transform:Find("red").gameObject:SetActive(flag)
	end
end

function UpdateVipExpNotice()
	local vipLoginInfo = VipData.GetLoginInfo()
	hasUncollectedDailyVipExp = vipLoginInfo.pop
	
	if _ui ~= nil and _ui.notice ~= nil then
		_ui.notice.dailyVipExp:SetActive(hasUncollectedDailyVipExp)
		_ui.btnCollectDailyVipExp:SetActive(hasUncollectedDailyVipExp)
		_ui.tip_dailyVipExpCollected:SetActive(not hasUncollectedDailyVipExp)

		_ui.dailyVipExp.text = System.String.Format(TextMgr:GetText("VIP_ui108"), vipLoginInfo.todayObtain)
	end
end

local function LoadUI()
	for i, v in ipairs(_ui.typebtns) do
		SetClickCallback(v, function()
			--if _ui.tabmsg[i] == nil then
			--	FloatText.Show(TextMgr:GetText("store_10"), Color.white)
			--	_ui.typebtns[_ui.tab]:GetComponent("UIToggle"):Set(true)
			--else
				_ui.tab = i
				_ui.index = 1

				UpdateUI()
			--end
		end)
		v:SetActive(_ui.tabmsg[i] ~= nil)

		if i == _ui.tab then
			v:GetComponent("UIToggle").value = true
		end
	end
	_ui.typebtnsroot:Reposition()

	_ui.topItem = {}
end

UpdateUI = function()
	LoadUI()
	UpdateTop()
	UpdateCenter()
	UpdateVipExpNotice()
	UpdateNewItemNotice()
end

UpdateTop = function()
	_ui.items = {}

	if _ui.tab == 7 then
		_ui.rootRight:SetActive(false)
	else
		_ui.rootRight:SetActive(true)
		if _ui.tabmsg[_ui.tab] == nil then
			for i = 0, _ui.GridTop.transform.childCount - 1 do
				_ui.GridTop.transform:GetChild(i).gameObject:SetActive(false)
			end
			_ui.none:SetActive(true)
			_ui.has:SetActive(false)
		else
			_ui.none:SetActive(false)
			_ui.has:SetActive(true)
			if _ui.index > #_ui.tabmsg[_ui.tab] then
				_ui.index = #_ui.tabmsg[_ui.tab]
			end
			local shownum = 0

			for i, v in ipairs(_ui.tabmsg[_ui.tab]) do
				local goodsItem
			    if i <= _ui.GridTop.transform.childCount then
			    	goodsItem = _ui.GridTop.transform:GetChild(i - 1)
			    else
			    	goodsItem = NGUITools.AddChild(_ui.GridTop.gameObject, _ui.goods.gameObject).transform
			    end
			    goodsItem.gameObject:SetActive(true)
			    goodsItem:Find("name"):GetComponent("UILabel").text = v.topName == "NA" and "" or TextMgr:GetText(v.topName)
			    local icontexture = ResourceLibrary:GetIcon("pay/", v.icon)
			    goodsItem:Find("Texture"):GetComponent("UITexture").mainTexture = icontexture
			    goodsItem:Find("selected effect/Texture"):GetComponent("UITexture").mainTexture = icontexture
			    SetClickCallback(goodsItem.gameObject, function()
			    	_ui.index = i

			    	SetItemHistory(v.tab, v.index, false)

			    	UpdateCenter()
			    	UpdateNewItemNotice(_ui.tab)

			    	MainCityUI.UpdateCashShopNotice()
			    end)

			    if v.type == ShopMsg_pb.IAPGoodType_GiftTimeLimit then
			    	timedGiftPack[v.index] = v
				end

			    -- goodsItem:Find("countdown").gameObject:SetActive(v.type == ShopMsg_pb.IAPGoodType_GiftTimeLimit)
			    -- goodsItem:Find("selected effect/countdown").gameObject:SetActive(v.type == ShopMsg_pb.IAPGoodType_GiftTimeLimit)

			    if v.endTime ~= 0 then
			    	local text_leftTime = Global.GetLeftCooldownTextLong(v.endTime)
			    	goodsItem:Find("countdown/time"):GetComponent("UILabel").text = text_leftTime
			    	goodsItem:Find("selected effect/countdown/time"):GetComponent("UILabel").text = text_leftTime

			    	goodsItem:Find("countdown").gameObject:SetActive(true)
			    	goodsItem:Find("selected effect/countdown").gameObject:SetActive(true)
			    else
			    	goodsItem:Find("countdown").gameObject:SetActive(false)
			    	goodsItem:Find("selected effect/countdown").gameObject:SetActive(false)
				end

				_ui.items[v.index] = goodsItem
			    shownum = i
			end
			_ui.GridTop:Reposition()
			_ui.ScrollTop:ResetPosition()
			_ui.ScrollTop:MoveRelative(Vector3(1,0,0))

			SetItemHistory(_ui.tab, _ui.tabmsg[_ui.tab][_ui.index].index, false)
			MainCityUI.UpdateCashShopNotice()
			
			for i = 1, _ui.GridTop.transform.childCount do
				if i == _ui.index then
			    	_ui.GridTop.transform:GetChild(i - 1).gameObject:GetComponent("UIToggle"):Set(true)
			    end
				if i > shownum then
					_ui.GridTop.transform:GetChild(i - 1).gameObject:SetActive(false)
				end
			end

			coroutine.start(function()
				coroutine.step()
				if _ui == nil then
					return
				end
				for i = 1, _ui.GridTop.transform.childCount do
					if i == _ui.index then
				    	_ui.GridTop.transform:GetChild(i - 1).gameObject:GetComponent("UIToggle"):Set(true)
				    end
				end
			end)
		end
	end
end

UpdateCenter = function()
	if _ui.tab == 7 then
		store_template2.Show(_ui.tabmsg[7])
	else
		store_template2.Hide()
		if _ui.tabmsg[_ui.tab] == nil then
			for i = 1, _ui.GridCenter.transform.childCount do
				_ui.GridCenter.transform:GetChild(i - 1).gameObject:SetActive(false)
			end
		else
			local goodsinfo = _ui.tabmsg[_ui.tab][_ui.index]
			local texture = ResourceLibrary:GetIcon("pay/", goodsinfo.icon)
			for i, v in ipairs(_ui.giftTextures) do
				v.mainTexture = texture
			end
			_ui.giftInfo.gameObject:SetActive(true)
			_ui.giftInfo.text = TextMgr:GetText(goodsinfo.desc)
			_ui.totleGold.text = goodsinfo.showPrice
			_ui.giftName.text = TextMgr:GetText(goodsinfo.name)
			_ui.discount.text = Format(TextMgr:GetText("ui_discount"), goodsinfo.discount)

			local vipLevel , needRecharge = VIP.GetVipInfo()
			_ui.textvip.gameObject:SetActive(needRecharge ~= 0 and vipLevel >= 0 and vipLevel < tableData_tVip.Count - 1)
			_ui.textvip.text = System.String.Format(TextMgr:GetText("vip_ui_recharge"), needRecharge , vipLevel + 1)
			_ui.textvip.gameObject:SetActive(not MainData.IsInTast())
			
			if goodsinfo.vipminlevel > 0 then
				_ui.vipCondition.gameObject:SetActive(true)

				local nowlevel = MainData.GetVipLevel()
				local color = nowlevel < goodsinfo.vipminlevel and "[ff0000]" or "[00ff00]"
				_ui.vipCondition.text = Format(TextMgr:GetText("store_13"), color, goodsinfo.vipminlevel - 1)
			else
				_ui.vipCondition.gameObject:SetActive(false)
			end
			
			if Serclimax.GameTime.GetSecTime() < (goodsinfo.endTime or 0) then
				_ui.timeLabel.transform.parent.gameObject:SetActive(true)

				CountDown.Instance:Remove("GiftPackCountdown")
				CountDown.Instance:Add("GiftPackCountdown", goodsinfo.endTime, function(text)
					if _ui ~= nil and _ui.timeLabel ~= nil and not _ui.timeLabel:Equals(nil) then
		        		_ui.timeLabel.text = text

		        		if text == "00:00:00" then
		        			CountDown.Instance:Remove("GiftPackCountdown")
		        			Show(_ui.tab, _ui.index)
		        		end
		        	else
		        		CountDown.Instance:Remove("GiftPackCountdown")
		        	end
				end)
			else
				_ui.timeLabel.transform.parent.gameObject:SetActive(false)
				CountDown.Instance:Remove("GiftPackCountdown")
			end

			-- if goodsinfo.endTime == nil or goodsinfo.endTime == 0 then
			-- 	_ui.timeLabel.transform.parent.gameObject:SetActive(false)
			-- 	CountDown.Instance:Remove("PaY" .. goodsinfo.id)
			-- else
			-- 	_ui.timeLabel.transform.parent.gameObject:SetActive(true)
			-- 	CountDown.Instance:Add("PaY" .. goodsinfo.id, goodsinfo.endTime,CountDown.CountDownCallBack(function (t)
		 --        	if _ui ~= nil and _ui.timeLabel ~= nil and not _ui.timeLabel:Equals(nil) and then
		 --        		_ui.timeLabel.text = t
		 --        		if t == "00:00:00" then
		 --        			CountDown.Instance:Remove("PaY" .. goodsinfo.id)
		 --        			Show(_ui.tab, _ui.index)
		 --        		end
		 --        	else
		 --        		CountDown.Instance:Remove("PaY" .. goodsinfo.id)
		 --        	end
		 --        end))
			-- end

			if goodsinfo.count == nil or goodsinfo.count.countmax == 0 then
				_ui.limitLabel.transform.parent.gameObject:SetActive(false)
			else
				_ui.limitLabel.transform.parent.gameObject:SetActive(true)
				local str = ""
				if goodsinfo.count.refreshType == Common_pb.LimitRefreshType_Day then
					str = "pay_ui14"
				elseif goodsinfo.count.refreshType == Common_pb.LimitRefreshType_Week then
					str = "pay_ui15"
				elseif goodsinfo.count.refreshType == Common_pb.LimitRefreshType_Month then
					str = "pay_ui16"
				elseif goodsinfo.count.refreshType == Common_pb.LimitRefreshType_Year then
					str = "pay_ui17"
				elseif goodsinfo.count.refreshType == Common_pb.LimitRefreshType_Forever then
					str = "pay_ui3"
				end
				_ui.limitLabel.text = Format(TextMgr:GetText(str), goodsinfo.count.count, goodsinfo.count.countmax)
				if(goodsinfo.count.count < 0) then
					_ui.limitLabel.transform.parent.gameObject:SetActive(false)
				end
			end
			
			if goodsinfo.itemBuy.item.item ~= nil and #goodsinfo.itemBuy.item.item > 0 then
				_ui.goldnum.text = goodsinfo.itemBuy.item.item[1].num
			else
				_ui.goldnum.text = "0"
			end
			
			local rowcount = math.ceil(#goodsinfo.itemGift.item.item / 3)
			for i = 1, rowcount do
				local rowItem
				if i <= _ui.GridCenter.transform.childCount then
			    	rowItem = _ui.GridCenter.transform:GetChild(i - 1)
			    else
			    	rowItem = NGUITools.AddChild(_ui.GridCenter.gameObject, _ui.row.gameObject).transform
			    end
			    rowItem.gameObject:SetActive(true)
			    local goldroot = rowItem:Find("center")
			    local itemroot = rowItem:Find("left")
			    local itemprefab
			    for ii = 1, 3 do
			    	if itemroot.childCount >= ii then
						itemprefab = itemroot:GetChild(ii - 1)
					else
						itemprefab = NGUITools.AddChild(itemroot.gameObject, _ui.itemPrefab.gameObject).transform
					end
					local nowitem = ii + (i - 1) * 3
					if nowitem > #goodsinfo.itemGift.item.item then
						itemprefab.gameObject:SetActive(false)
					else
						itemprefab.gameObject:SetActive(true)
						UpdateItem(itemprefab, goodsinfo.itemGift.item.item[nowitem])
					end
			    end
			    itemroot:GetComponent("UIGrid"):Reposition()
			end
			_ui.GridCenter:Reposition()
			_ui.ScrollCenter:ResetPosition()
			for i = 1, _ui.GridCenter.transform.childCount do
				if i > rowcount then
					_ui.GridCenter.transform:GetChild(i - 1).gameObject:SetActive(false)
				end
			end
			
			if platformType == LoginMsg_pb.AccType_adr_huawei then
				_ui.priceLabel.text = "SGD$" .. goodsinfo.price
			elseif platformType == LoginMsg_pb.AccType_adr_tmgp or
					Global.IsIosMuzhi() or
					platformType == LoginMsg_pb.AccType_adr_muzhi or
					platformType == LoginMsg_pb.AccType_adr_opgame or
					platformType == LoginMsg_pb.AccType_adr_mango or
					platformType == LoginMsg_pb.AccType_adr_official or
					platformType == LoginMsg_pb.AccType_ios_official or
					platformType == LoginMsg_pb.AccType_adr_official_branch then
				_ui.priceLabel.text = "RMB￥" .. goodsinfo.price
			else
				_ui.priceLabel.text = "US$" .. goodsinfo.price
			end
			
			SetClickCallback(_ui.btn_buy, function()
				local nowlevel = MainData.GetVipLevel()
				local canbuy = true
				if (goodsinfo.vipminlevel ~= 0 and nowlevel < goodsinfo.vipminlevel) or
					(goodsinfo.vipmaxlevel ~= 0 and nowlevel > goodsinfo.vipmaxlevel) then
					canbuy = false
				end
				if not canbuy then
					MessageBox.Show(TextMgr:GetText("store_14"),function() return end)
				else
					StartPay(goodsinfo, TextMgr:GetText(goodsinfo.name))
				end				
				
			end)
		end
	end
end

UpdateItem = function(prefab, itemdata)
	prefab.localScale = Vector3(1.2, 1.2, 1)
	local itData = TableMgr:GetItemData(itemdata.baseid)
	local textColor = Global.GetLabelColorNew(itData.quality)
	prefab:Find("name"):GetComponent("UILabel").text = textColor[0] .. TextUtil.GetItemName(itData) .. "[-]"
	prefab:Find("num"):GetComponent("UILabel").text = "x" .. itemdata.num
	prefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itData.icon)
	local piece = prefab:Find("Texture/piece"):GetComponent("UISprite")
	piece.gameObject:SetActive(itData.type == 54)
	piece.spriteName = "piece" .. itData.quality
	prefab:GetComponent("UISprite").spriteName = "bg_item" .. itData.quality
	local itemlvTrf = prefab:Find("bg_mid")
	local itemlv = itemlvTrf:Find("Label"):GetComponent("UILabel")
	itemlvTrf.gameObject:SetActive(true)
	if itData.showType == 1 then
		itemlv.text = Global.ExchangeValue2(itData.itemlevel)
	elseif itData.showType == 2 then
		itemlv.text = Global.ExchangeValue1(itData.itemlevel)
	elseif itData.showType == 3 then
		itemlv.text = Global.ExchangeValue3(itData.itemlevel)
	else 
		itemlvTrf.gameObject:SetActive(false)
	end

    UIUtil.SetClickCallback(prefab.gameObject, function()
        if _ui.tooltip ~= itData then
            _ui.tooltip = itData
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itData), text = TextUtil.GetItemDescription(itData)})
        else
            _ui.tooltip = nil
        end
    end)
end

function Start()
end

function Close()
	UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)

	store_template2.Hide()
	SaveHistory()
	-- RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	_ui = nil
	Barrack.Open3DArea()
end

function ShowByID(id)
	if _ui == nil then
		_ui = {}
	end
	_ui.showid = id
	Show()
end

function ShowByIDArray(array)
	if _ui == nil then
		_ui = {}
	end
	_ui.showarray = array
	Show()
end

function Show(tab, index)
	Goldstore.Show()

	return

	-- if tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PayActivity).value) ~= 1 then
	-- 	CloseSelf()
	-- 	return
	-- end
	-- platformType = GUIMgr:GetPlatformType()
	-- if UnityEngine.Application.isEditor then
	-- 	platformType = LoginMsg_pb.AccType_adr_efun
	-- end
	-- if _ui == nil then
	-- 	_ui = {}
	-- end
	-- _ui.tab = tab == nil and 1 or tab
	-- _ui.index = index == nil and 1 or index
	-- Global.OpenUI(_M)
	
	-- if store_template2.IsInViewport() then
	-- 	GUIMgr:BringForward(store_template2.gameObject)
	-- end
	
	-- ShopInfoRequest(function(msg)
	-- 	if msg.code == ReturnCode_pb.Code_OK then
	-- 		table.sort(msg.goodInfos, function(a, b)
	-- 			if a.endTime ~= 0 and b.endTime ~= 0 then
	-- 				return a.endTime < b.endTime
	-- 			elseif a.endTime ~= b.endTime then
	-- 				return a.endTime ~= 0
	-- 			end

	-- 			return a.order > b.order
	-- 		end)
			
	-- 		_ui.msg = msg
	-- 		_ui.tabmsg = {}
	-- 		local arrayindex = 0
	-- 		for i, v in ipairs(_ui.msg.goodInfos) do
	-- 			if v.id ~= 0 and v.priceType == 0 and not DO_HIDE[v.type] then -- 屏蔽非现金物品、周卡月卡
	-- 				if _ui.tabmsg[v.tab] == nil then
	-- 					_ui.tabmsg[v.tab] = {}
	-- 				end
	-- 				table.insert(_ui.tabmsg[v.tab], v)
	-- 				if _ui.showid ~= nil and _ui.showid == v.id then
	-- 					_ui.tab = v.tab
	-- 					_ui.index = #_ui.tabmsg[v.tab]
	-- 					_ui.showid = nil
	-- 				end
	-- 				if _ui.showarray ~= nil then
	-- 					for ii, vv in ipairs(_ui.showarray) do
	-- 						if vv == v.id then
	-- 							if arrayindex == 0 then
	-- 								arrayindex = ii
	-- 								_ui.tab = v.tab
	-- 								_ui.index = #_ui.tabmsg[v.tab]
	-- 							else
	-- 								if arrayindex > ii then
	-- 									arrayindex = ii
	-- 									_ui.tab = v.tab
	-- 									_ui.index = #_ui.tabmsg[v.tab]
	-- 								end
	-- 							end
	-- 						end
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 		_ui.showarray = nil
			
	-- 		local firsttab = next(_ui.tabmsg)
	-- 		if firsttab > _ui.tab then
	-- 			_ui.tab = firsttab
	-- 		end

	-- 		--Global.OpenUI(_M)
			
	-- 		UpdateUI()
	-- 	else
	-- 		Global.ShowError(msg.code)
 --        end
	-- end)
end

function Deliver(orderId, receipt, channel, productId, signature, platorderid, identifier, paytype)
	-- local goodInfo = shopItems[productId]
	-- if goodInfo.count - 1 <= 0 then
	--	LockItem(productId)
	-- end

	local req = ShopMsg_pb.MsgIAPChargeDeliverRequest()
	req.chanel = channel
    req.orderId = orderId
    req.receipt = receipt
    req.productid = productId
    req.sign = signature
	req.platorderid = platorderid
	req.identifier = identifier
	req.paytype = paytype
    LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPChargeDeliverRequest, req:SerializeToString(), function (typeId, data)
        local msg = ShopMsg_pb.MsgIAPChargeDeliverResponse()
        msg:ParseFromString(data)
        if msg.code == 0 then
			GUIMgr:RechargeSucc()
			--[[
			if MainData.HadRecharged() then
				GUIMgr:SendDataReport("efun", "fr")
			end]]
        	--MessageBox.Show(TextMgr:GetText("login_ui_pay1"))
        	--Show(_ui.tab, _ui.index)
        	--MainData.SetRecharged()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function InitializeData(msg)
	Global.LogDebug(_M, "InitializeData")
	for _, iapGoodInfo in ipairs(msg.goodInfos) do
    	if iapGoodInfo.type == ShopMsg_pb.IAPGoodType_WeekCard then
    		cards[1] = iapGoodInfo
    	elseif iapGoodInfo.type == ShopMsg_pb.IAPGoodType_MonthCard then
    		cards[2] = iapGoodInfo
    	end
    end

    UpdateHistory(msg.goodInfos)
    SetTimedGiftPack(msg.goodInfos)
    SetGiftPacksWithCountdown(msg.goodInfos)
	SetGlobalLimitPack(msg.goodInfos)
end

function Initialize()
	UpdateVipExpNotice()
	MainCityUI.UpdateCashShopNotice()

	CountDown.Instance:Add(_M._NAME, Serclimax.GameTime.GetSecTime() + 200000000, function(t)
		local now = Serclimax.GameTime.GetSecTime()
		
		if lastUpdateTime ~= now then
			lastUpdateTime = now

			if now % 3600 == 0 then -- 每小时数据刷新
				ShopInfoRequest()
			end

			UpdateCountDown(now)			
		end
	end)
end
