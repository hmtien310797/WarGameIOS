module("ArenaShop", package.seeall)
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
local ShopInfoMsg
local LoadUI
local BuyShopItemClick
local BuyShopItemCallBack

local MoneyIcon 

function SetMoneyIcon(icon)
	MoneyIcon = icon
end

function SetBuyShopItemCallBack(callback)
	BuyShopItemCallBack = callback
end

function GetShopInfo()
	return  ShopInfoMsg
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

	local coin = "union_Arenascore"
	if MoneyIcon then
		coin = MoneyIcon
	else
		coin = "union_Arenascore"
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



function LoadArenaShopListBag(bagParam)
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
	local req = BattleMsg_pb.MsgRefreshArenaShopRequest()
	--req.type = freshType
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgRefreshArenaShopRequest, req, BattleMsg_pb.MsgRefreshArenaShopResponse, function(msg)
		Global.DumpMessage(msg,"d:/MsgRefreshArenaShopResponse.lua")
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
			LoadArenaShopListBag(bagParam)
		end
	end)
end

function FreshInfoCallback(bagParam,callback)
	local freshType = 1
	if bagParam.force ~= true then
		freshType = 2
		MessageBox.Show(System.String.Format(TextMgr:GetText("ui_Arena_Shop"),ShopInfoMsg.shopRefreshInfo.nextCostDiamond ) , function() RequestFreshShop(bagParam,callback) end, function() end)
	else
		--RequestFreshShop(bagParam,callback)
	end
	
end

BuyShopItemClick = function(go , itemmsg , status)
	
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
		local myGuildCoin = MoneyListData.GetMoneyByType(Common_pb.MoneyType_ArenaCoin)
		if cost > myGuildCoin then
			MessageBox.Show(TextMgr:GetText("Arena_Shop_ui1") , function() end)
			return
		end
	
		local req = BattleMsg_pb.MsgArenaShopBuyRequest()
		req.num = buyNumber
		req.exchangeId = itemmsg.exchangeId
		Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaShopBuyRequest, req, BattleMsg_pb.MsgArenaShopBuyResponse, function(msg)
			Global.DumpMessage(msg,"d:/MsgArenaArenaBuyResponse.lua")
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				FloatText.Show(TextMgr:GetText("login_ui_pay1") , Color.green)
				MainCityUI.UpdateRewardData(msg.fresh)
				SlgBag.UpdateBagItem(msg.fresh.item.items)
				--LoadShopItem(_ui.shopItems[msg.itemInfo.baseId] , msg.itemInfo)
				--LoadShopItemBag(go.transform.parent.transform.parent.gameObject.transform , msg.itemInfo)
				if BuyShopItemCallBack ~= nil then
					BuyShopItemCallBack()
				end
			end
		end)
	end)
	GUIMgr:CreateMenu("UseItem" , false)
	
end


function RequestShopData(bagParam , callback)
	local req = BattleMsg_pb.MsgArenaShopInfoRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaShopInfoRequest, req, BattleMsg_pb.MsgArenaShopInfoResponse, function(msg)
        Global.DumpMessage(msg,"d:/MsgArenaShopInfoResponse.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			ShopInfoMsg = msg
			bagParam.msg = msg
			if callback ~= nil then
				callback(msg)
			end
			LoadArenaShopListBag(bagParam)
		end
    end)
end


