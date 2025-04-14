module("UnionShop", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui
local unionShopInfoMsg
local LoadUI
local BuyShopItemClick
local BuyShopItemClickCallBack

local MoneyIcon 

function SetMoneyIcon(icon)
	MoneyIcon = icon
end

function SetBuyShopItemClickCallBack(callback)
	BuyShopItemClickCallBack = callback
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	
	if go.transform.parent.name == "bg_UnionCoin" then
		local coinData = TableMgr:GetItemData(9)--联盟币
		Tooltip.ShowItemTip({name = TextMgr:GetText(coinData.name), text = TextMgr:GetText(coinData.description)})
		return
	end
	Tooltip.HideItemTip()
end

local function GetSortedList(msg)
	local sortedList = {}
	for i=1 , #msg.itemInfos , 1 do
		table.insert(sortedList , msg.itemInfos[i])
	end
	
	table.sort(sortedList , function(v1 , v2)
		return v1.price > v2.price
	end)
	return sortedList
end

function FreshInfoCallback(ShopInfoMsg)
	local freshType = 1
	if ShopInfoMsg.shopRefreshInfo.maxFreeCount <= ShopInfoMsg.shopRefreshInfo.usedFreeCount then
		freshType = 2
		MessageBox.Show(System.String.Format(TextMgr:GetText("Union_Shop_ui5"),ShopInfoMsg.shopRefreshInfo.nextCostDiamond) , function() RequestFreshShop(freshType) end, function() end)
	else
		RequestFreshShop(freshType)
	end
	
end

function LateUpdate()
	if unionShopInfoMsg == nil then
		return
	end
	local clientRefreshTime = unionShopInfoMsg.shopRefreshInfo.nextRefreshTime + 1
	local leftTimeSec = clientRefreshTime - Serclimax.GameTime.GetSecTime()
	if leftTimeSec > 0 then -- 刷新时间延迟5s
		local countDown = Global.GetLeftCooldownTextLong(unionShopInfoMsg.shopRefreshInfo.nextRefreshTime)
		_ui.freshTime.text = countDown
	else
		unionShopInfoMsg = nil
		local req = GuildMsg_pb.MsgGuildShopInfoRequest()
		Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildShopInfoRequest, req, GuildMsg_pb.MsgGuildShopInfoResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				unionShopInfoMsg = msg
				LoadUI()
			end
		end)
	end
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


local function LoadShopItem(item , itemmsg)
	if item == nil then
		return
	end
	
	local v = itemmsg
	local itemTBData = TableMgr:GetItemData(v.baseId)
	
	--buy Count
	local num = item.transform:Find("bg_title/num"):GetComponent("UILabel")
	num.text = v.maxBuyNum - v.currentBuyNum
	--name
	local name = item.transform:Find("bg_title/text"):GetComponent("UILabel")
	local textColor = Global.GetLabelColorNew(itemTBData.quality)
	name.text = textColor[0] .. TextUtil.GetItemName(itemTBData) .. "[-]"

	--des
	local des = item.transform:Find("text"):GetComponent("UILabel")
	des.text = TextUtil.GetItemDescription(itemTBData)
	
	--quality
	local quabox = item.transform:Find("bg_icon"):GetComponent("UISprite")
	quabox.spriteName = "bg_item" .. itemTBData.quality
	--icon
	local resIcon = item.transform:Find("bg_icon/Texture"):GetComponent("UITexture")
	resIcon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
	--item num
	local num = item.transform:Find("bg_icon/num"):GetComponent("UILabel")
	if itemTBData.showType == 1 then
		num.text = Global.ExchangeValue2(itemTBData.itemlevel)
	elseif itemTBData.showType == 2 then
		num.text = Global.ExchangeValue1(itemTBData.itemlevel)
	elseif itemTBData.showType == 3 then
		num.text = Global.ExchangeValue3(itemTBData.itemlevel)
	else 
		num.gameObject:SetActive(false)
	end
	
	--item price
	local price = item.transform:Find("btn_use_gold/num"):GetComponent("UILabel")
	price.text = v.price
	
	--click
	local buyBtn = item.transform:Find("btn_use_gold"):GetComponent("UIButton")
	local status = false
	if v.currentBuyNum >= v.maxBuyNum then
		--buyBtn.isEnabled = false
		UIUtil.SetBtnEnable(buyBtn ,"btn_blue3", "btn_small_g", false)
	else
		status = true
		UIUtil.SetBtnEnable(buyBtn ,"btn_blue3", "btn_small_g", true)
	end
	
	SetClickCallback(buyBtn.gameObject , function(go)
		_ui.buyItem = buyBtn.gameObject
		BuyShopItemClick(go , v , status)
	end)
	
	
end

function LoadShopItemBag(itemTransform , itemmsg)
	local itemBg = itemTransform:Find("bg_list/background"):GetComponent("UISprite")
	itemBg.spriteName = "separate_bg3"
	
	local itemTBData = TableMgr:GetItemData(itemmsg.baseId)
	local name = itemTransform:Find("bg_list/text_name"):GetComponent("UILabel")
	name.text = TextUtil.GetItemName(itemTBData)
	local des = itemTransform:Find("bg_list/text_name/text_des"):GetComponent("UILabel")
	des.text = TextUtil.GetItemDescription(itemTBData)
	local num = itemTransform:Find("bg_list/txt_num/num"):GetComponent("UILabel")
	num.text = itemmsg.maxBuyNum - itemmsg.currentBuyNum
	local IconInfo = itemTransform:Find("bg_list/Item_CommonNew")
	local item = {}
	UIUtil.LoadItemObject(item, IconInfo)
	UIUtil.LoadItem(item, itemTBData, nil)

	
	local btn = itemTransform:Find("bg_list/btn_use_gold").gameObject
	btn.gameObject:SetActive(true)
	
	local goldspr = itemTransform:Find("bg_list/btn_use_gold/icon_gold"):GetComponent("UISprite")

	local coin = "union_coin"
	if MoneyIcon then
		coin = MoneyIcon
	else
		coin = "union_coin"
	end
	goldspr.spriteName = coin--TableMgr:GetItemData(9).icon
	
	local price = itemTransform:Find("bg_list/btn_use_gold/num"):GetComponent("UILabel")
	price.text = Global.ExchangeValue(itemmsg.price) --itemmsg.price
	
	local status = false
	if itemmsg.currentBuyNum < itemmsg.maxBuyNum then
		status = true
	end
	
	SetClickCallback(btn.gameObject , function(go)
		--_ui.buyItem = btn.gameObject
		BuyShopItemClick(go , itemmsg , status)
	end)
	
	
	local btn_use = itemTransform:Find("bg_list/btn_use").gameObject
	local btn_use_continue = itemTransform:Find("bg_list/btn_use_continue").gameObject
	btn_use.gameObject:SetActive(false)
	btn_use_continue.gameObject:SetActive(false)
	
	
end

local function LoadUnionShopList()
	while _ui.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.grid.transform:GetChild(0).gameObject)
	end
	_ui.shopItems = {}
	local sortedList = GetSortedList(unionShopInfoMsg)
	for i=1 , #sortedList do
		local info = nil
		local v = sortedList[i]
		info = NGUITools.AddChild(_ui.grid.gameObject , _ui.item.gameObject)
		info.transform:SetParent(_ui.grid.transform , false)
		info.gameObject:SetActive(true)
		LoadShopItem(info , v)
		_ui.shopItems[v.baseId] = info
	end
	_ui.grid:Reposition()
end

function LoadUnionShopListBag(bagParam)
	while bagParam.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(bagParam.grid.transform:GetChild(0).gameObject)
	end
	
	local sortedList = GetSortedList(bagParam.msg)
	if bagParam.shopItem == nil then
		bagParam.shopItem = {}
	end
	for i=1 , #sortedList do
		local info = nil
		local v = sortedList[i]
		info = NGUITools.AddChild(bagParam.grid.gameObject , bagParam.item.gameObject)
		info.transform:SetParent(bagParam.grid.transform , false)
		info.gameObject:SetActive(true)
		--LoadShopItem(info , v)
		LoadShopItemBag(info.transform , v)
		--_ui.shopItems[v.baseId] = info
		bagParam.shopItem[v.baseId] = info
	end
	bagParam.grid:Reposition()
	bagParam.scroll_view:ResetPosition()
end


function RequestFreshShop(bagParam ,callback )
	local req = GuildMsg_pb.MsgRefreshGuildShopRequest()
	req.type = bagParam.freshType
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgRefreshGuildShopRequest, req, GuildMsg_pb.MsgRefreshGuildShopResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			FloatText.Show(TextMgr:GetText("Union_Shop_ui9"),Color.green)
			MainCityUI.UpdateRewardData(msg.fresh)
			--LoadUI()
			bagParam.msg = msg
			if callback ~= nil then
				callback(msg)
			end
			LoadUnionShopListBag(bagParam)
		end
	end)
end



BuyShopItemClick = function(go , itemmsg , status)
	if BuyShopItemClickCallBack ~= nil then
		BuyShopItemClickCallBack(go , itemmsg , status)
		return 
	end
	if status == false then
		FloatText.Show(TextMgr:GetText("Union_Shop_ui6"), Color.white)
		return
	end

	local itemParm = {}
	itemParm.baseId = itemmsg.baseId
	itemParm.number = itemmsg.maxBuyNum - itemmsg.currentBuyNum
	itemParm.price = itemmsg.price
	UseItem.InitItemByParams(itemParm)
	UseItem.SetUseCallBack(function(buyNumber)
		local cost = buyNumber * itemmsg.price
		local myGuildCoin = MoneyListData.GetMoneyByType(Common_pb.MoneyType_GuildCoin)
		if cost > myGuildCoin then
			MessageBox.Show(TextMgr:GetText("Union_Shop_ui7") , function() end)
			return
		end
	
		local req = GuildMsg_pb.MsgGuildShopBuyRequest()
		req.num = buyNumber
		req.exchangeId = itemmsg.exchangeId
		Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildShopBuyRequest, req, GuildMsg_pb.MsgGuildShopBuyResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				FloatText.Show(TextMgr:GetText("login_ui_pay1") , Color.green)
				MainCityUI.UpdateRewardData(msg.fresh)
				SlgBag.UpdateBagItem(msg.fresh.item.items)
				--LoadShopItem(_ui.shopItems[msg.itemInfo.baseId] , msg.itemInfo)
				LoadShopItemBag(go.transform.parent.transform.parent.gameObject.transform , msg.itemInfo)
			end
		end)
	end)
	GUIMgr:CreateMenu("UseItem" , false)
	
end

local function RefreshUnionInfo()
	_ui.unionCoin.text = MoneyListData.GetMoneyByType(Common_pb.MoneyType_GuildCoin)
	_ui.freshBtnText.text = (unionShopInfoMsg.shopRefreshInfo.maxFreeCount - unionShopInfoMsg.shopRefreshInfo.usedFreeCount) > 0 and TextMgr:GetText("Union_Shop_ui8") or TextMgr:GetText("military_11")
end

function Awake()
	_ui = {}
	local closeBtn = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject, Hide)
	
	SetClickCallback(transform:Find("mask").gameObject , Hide)
	
	_ui.freshBtn = transform:Find("Container/bg_frane/bg_bottom/btn"):GetComponent("UIButton")
	SetClickCallback(_ui.freshBtn.gameObject, FreshInfoCallback)
	_ui.freshBtnText = transform:Find("Container/bg_frane/bg_bottom/btn/text"):GetComponent("UILabel")
	_ui.shopHint = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	_ui.freshTime = transform:Find("Container/bg_frane/bg_bottom/text/text (1)"):GetComponent("UILabel")
	_ui.scrollView = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("shopinfo")
	_ui.unionCoin = transform:Find("Container/bg_UnionCoin/num"):GetComponent("UILabel")
	
	MoneyListData.AddListener(RefreshUnionInfo)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

LoadUI = function()
	if unionShopInfoMsg == nil then
		return
	end
	
	RefreshUnionInfo()
	LoadUnionShopList()
end


function RequestUnionShopData(bagParam , callback)
	local req = GuildMsg_pb.MsgGuildShopInfoRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildShopInfoRequest, req, GuildMsg_pb.MsgGuildShopInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			bagParam.msg = msg
			if callback ~= nil then
				callback(msg)
			end
			LoadUnionShopListBag(bagParam)
		end
    end)
end

function Show()
	Global.OpenUI(_M)
	local req = GuildMsg_pb.MsgGuildShopInfoRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildShopInfoRequest, req, GuildMsg_pb.MsgGuildShopInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			unionShopInfoMsg = msg
			LoadUI()
		end
    end)
	
end


function Close()
	MoneyIcon = nil
	BuyShopItemClickCallBack = nil
	_ui = nil
	MoneyListData.RemoveListener(RefreshUnionInfo)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end
