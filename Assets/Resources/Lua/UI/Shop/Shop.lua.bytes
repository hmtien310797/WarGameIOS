module("Shop", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local ShopMsg_pb = require("ShopMsg_pb")

local btn_tabs
local btn_close
local _container
local bg_noitem
local txt_hint
local scroll_view
local grid
local shop_info
local shop_item
local itemList
local buyItemId = 0
local buyItemPrice = 0
local buyItemNum = 0
local needup = false
local bagParam

function Awake()
	btn_tabs = {}
	btn_tabs[1] = transform:Find("Container/bg_frane/bg_tab/btn_itemtype_5").gameObject
	btn_tabs[2] = transform:Find("Container/bg_frane/bg_tab/btn_itemtype_4").gameObject
	btn_tabs[3] = transform:Find("Container/bg_frane/bg_tab/btn_itemtype_6").gameObject
	btn_tabs[4] = transform:Find("Container/bg_frane/bg_tab/btn_itemtype_7").gameObject
	btn_tabs[5] = transform:Find("Container/bg_frane/bg_tab/btn_itemtype_8").gameObject
	
	_container = transform:Find("Container").gameObject
	btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	
	bg_noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem").gameObject
	txt_hint = transform:Find("Container/bg_frane/bg_mid/txt_hint").gameObject
	
	scroll_view = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	
	shop_info = transform:Find("shopinfo").gameObject
end

local function MakeShopItem(i,param)
	if param ~= nil then
		grid = param.grid
		shop_info = param.item
	end
	if grid == nil or grid:Equals(nil) then
		return
	end
	local childCount = grid.transform.childCount
	local item = {}
    if i - 1 < childCount then
    	item.go = grid.transform:GetChild(i - 1).gameObject
    else
    	item.go = GameObject.Instantiate(shop_info)
    end
    item.go.transform:SetParent(grid.transform, false)
    item.go.name = i
    item.name = item.go.transform:Find("bg_title/text"):GetComponent("UILabel")
    item.num = item.go.transform:Find("bg_title/num"):GetComponent("UILabel")
    item.icon = item.go.transform:Find("bg_icon/Texture"):GetComponent("UITexture")
    item.iconnum = item.go.transform:Find("bg_icon/num"):GetComponent("UILabel")
    item.quality = item.go.transform:Find("bg_icon"):GetComponent("UISprite")
    item.info = item.go.transform:Find("text"):GetComponent("UILabel")
    item.btn = item.go.transform:Find("btn_use_gold").gameObject
    item.gold = item.go.transform:Find("btn_use_gold/num"):GetComponent("UILabel")
    return item
end

local function MakeShopItemBag(i,param)
	if param ~= nil then
		grid = param.grid
		shop_info = param.item
	end
	if grid == nil or grid:Equals(nil) then
		return
	end
	local childCount = grid.transform.childCount
	local item = {}
    if i - 1 < childCount then
    	item.go = grid.transform:GetChild(i - 1).gameObject
    else
    	item.go = GameObject.Instantiate(shop_info)
    end
    item.go.transform:SetParent(grid.transform, false)
    item.go.name = i
    item.name = item.go.transform:Find("bg_list/text_name"):GetComponent("UILabel")
    item.info = item.go.transform:Find("bg_list/text_name/text_des"):GetComponent("UILabel")
    item.num = item.go.transform:Find("bg_list/txt_num/num"):GetComponent("UILabel")
	item.IconInfo = item.go.transform:Find("bg_list/Item_CommonNew")
	item.background = item.go.transform:Find("bg_list/background"):GetComponent("UISprite")
	
    item.btn = item.go.transform:Find("bg_list/btn_use_gold").gameObject
    item.gold = item.go.transform:Find("bg_list/btn_use_gold/num"):GetComponent("UILabel")
	item.btn.gameObject:SetActive(true)
	
	item.btn_use = item.go.transform:Find("bg_list/btn_use").gameObject
	item.btn_use_continue = item.go.transform:Find("bg_list/btn_use_continue").gameObject
	item.btn_use.gameObject:SetActive(false)
	item.btn_use_continue.gameObject:SetActive(false)
    return item
end
local function RemoveItem(index)
	local childCount = grid.transform.childCount
	for i = index, childCount - 1 do
        GameObject.Destroy(grid.transform:GetChild(i).gameObject)
    end
end

local function ShopInfoRequest(index, callback)
	local req = ShopMsg_pb.MsgCommonShopInfoRequest()
	req.index = index
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopInfoRequest, req, ShopMsg_pb.MsgCommonShopInfoResponse, function(msg)
        callback(msg)
    end, true)
end

--[[
local req = ClientMsg_pb.MsgUserMissionRewardRequest();
        req.taskid = missionMsg.id
        Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
]]
local function ShopBuyRequest(exchangeId, num, callback)
	local req = ShopMsg_pb.MsgCommonShopBuyRequest()
	req.exchangeId = exchangeId
	req.num = num
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopBuyRequest, req, ShopMsg_pb.MsgCommonShopBuyResponse, function(msg)
        callback(msg)
    end, true)
end

local function BuyItemCallBack(num)
	buyItemNum = num
	ShopBuyRequest(buyItemId, num, function(msg)
		if msg.code == 0 then
			MainCityUI.UpdateRewardData(msg.fresh)
			SlgBag.UpdateBagItem(msg.fresh.item.items)
			RefreshItems()
			
			--send data report-----------------------
			GUIMgr:SendDataReport("purchase", "buyitem", "" .. TableMgr:GetItemExchangeData(buyItemId).item, "" .. buyItemNum, "" .. buyItemPrice)
			-----------------------------------------
			FloatText.Show(TextMgr:GetText("login_ui_pay1"), Color.green)
		else
			if msg.code == ReturnCode_pb.Code_DiamondNotEnough then
				local msgText = TextMgr:GetText(Text.common_ui8)
	            local okText = TextMgr:GetText(Text.common_ui10)
	            MessageBox.Show(msgText, function() store.Show(7) end, function() end, okText)
	        else
	        	Global.FloatError(msg.code, Color.white)
			end
		end
	end)
end

local function BuyItemBagCallBack(num)
	buyItemNum = num
	ShopBuyRequest(buyItemId, num, function(msg)
		if msg.code == 0 then
			MainCityUI.UpdateRewardData(msg.fresh)
			SlgBag.UpdateBagItem(msg.fresh.item.items)
			RefreshItemsBag()
			
			--send data report-----------------------
			GUIMgr:SendDataReport("purchase", "buyitem", "" .. TableMgr:GetItemExchangeData(buyItemId).item, "" .. buyItemNum, "" .. buyItemPrice)
			-----------------------------------------
			FloatText.Show(TextMgr:GetText("login_ui_pay1"), Color.green)
		else
			if msg.code == ReturnCode_pb.Code_DiamondNotEnough then
				local msgText = TextMgr:GetText(Text.common_ui8)
	            local okText = TextMgr:GetText(Text.common_ui10)
	            MessageBox.Show(msgText, function() store.Show(7) end, function() end, okText)
	        else
	        	Global.FloatError(msg.code, Color.white)
			end
		end
	end)
end

function RefreshItemsBag()
	if bagParam == nil then
		return
	end

	local count = 0
	for i, v in ipairs(itemList) do
		local itemBag = MakeShopItemBag(i , bagParam)
		if itemBag == nil then
			return
		end
		local itData = TableMgr:GetItemData(v.baseId)
		local textColor = Global.GetLabelColorNew(itData.quality)
		local exchangedata = TableMgr:GetItemExchangeData(v.exchangeId)
		local numstr = ""
		if exchangedata ~= nil then
			numstr = (exchangedata.number > 1 and (" x" .. exchangedata.number) or "")
		end
		itemBag.name.text = textColor[0] .. TextUtil.GetItemName(itData) .. "[-]" .. numstr
		itemBag.num.text = ItemListData.GetItemCountByBaseId(v.baseId)
        itemBag.info.text = TextUtil.GetItemDescription(itData)
		itemBag.background.spriteName = "separate_bg"
		
		local item = {}
		UIUtil.LoadItemObject(item, itemBag.IconInfo)
		UIUtil.LoadItem(item, itData)
		
		
        itemBag.gold.text = v.price
        SetClickCallback(itemBag.btn, function(go)
        	buyItemId = v.exchangeId
			buyItemPrice = v.price
        	UseItem.InitShop(v)
			UseItem.SetUseCallBack(BuyItemBagCallBack)
			GUIMgr:CreateMenu("UseItem" , false)
        end)
        count = i
	end
	RemoveItem(count)
	bagParam.grid:Reposition()
	if needup then
		bagParam.scroll_view:ResetPosition()
		needup = false
	end
end

function RefreshItems()
	local count = 0
	for i, v in ipairs(itemList) do
		local item = MakeShopItem(i)
		local itData = TableMgr:GetItemData(v.baseId)
		local textColor = Global.GetLabelColorNew(itData.quality)
		item.name.text = textColor[0] .. TextUtil.GetItemName(itData) .. "[-]"
		item.num.text = ItemListData.GetItemCountByBaseId(v.baseId)
		item.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itData.icon)
		item.quality.spriteName = "bg_item" .. itData.quality
		if itData.showType == 1 then
        	item.iconnum.gameObject:SetActive(true)
        	item.iconnum.text = Global.ExchangeValue2(itData.itemlevel)
        elseif itData.showType == 2 then
        	item.iconnum.gameObject:SetActive(true)
        	item.iconnum.text = Global.ExchangeValue1(itData.itemlevel)
        elseif itData.showType == 3 then
        	item.iconnum.gameObject:SetActive(true)
        	item.iconnum.text = Global.ExchangeValue3(itData.itemlevel)
        else
        	item.iconnum.gameObject:SetActive(false)
        end
        item.info.text = TextUtil.GetItemDescription(itData)
        item.gold.text = v.price
        SetClickCallback(item.btn, function(go)
        	buyItemId = v.exchangeId
			buyItemPrice = v.price
        	UseItem.InitShop(v)
			UseItem.SetUseCallBack(BuyItemCallBack)
			GUIMgr:CreateMenu("UseItem" , false)
        end)
        count = i
	end
	RemoveItem(count)
	grid:Reposition()
	if needup then
		scroll_view:ResetPosition()
		needup = false
	end
end

local function RefreshItemsMsg(msg)
	if msg.code == 0 then
		itemList = msg.item
		table.sort(itemList, function(a, b) return a.orderId < b.orderId end)
		RefreshItems()
	else
		Global.FloatError(msg.code, Color.white)
	end
end

function ShowShopIndex(index , param)
	bagParam = param
	ShopInfoRequest(index, function(msg)
		if bagParam == nil then
			return
		end
		needup = true
		if msg.code == 0 then
			itemList = msg.item
			table.sort(itemList, function(a, b) return a.orderId < b.orderId end)
			--RefreshItems()
		else
			Global.FloatError(msg.code, Color.white)
			return
		end
		RefreshItemsBag()
	end)
end

function Start()
	SetClickCallback(btn_close, function(go)
		GUIMgr:CloseMenu("Shop")
	end)
	SetClickCallback(_container, function(go)
		GUIMgr:CloseMenu("Shop")
	end)
	for i, v in ipairs(btn_tabs) do
		SetClickCallback(v, function(go)
			ShopInfoRequest(i - 1, function(msg)
				needup = true
				RefreshItemsMsg(msg)
			end)
		end)
	end
	needup = true
	ShopInfoRequest(0, function(msg) RefreshItemsMsg(msg) end)
end

function Close()
	btn_tabs = nil
	btn_close = nil
	_container = nil
	bg_noitem = nil
	txt_hint = nil
	scroll_view = nil
	grid = nil
	shop_info = nil
	shop_item = nil
	itemList = nil
	bagParam = nil
end
