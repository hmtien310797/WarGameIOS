module("FirstPurchase", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui
local closeCallback

local MAX_ITEM_SHOW = 5

function SetCloseCallback(callback)
    closeCallback = callback
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

function CloseSelf()
	if _ui ~= nil then
		Global.CloseUI(_M)
		if closeCallback ~= nil then
	        closeCallback()
	        closeCallback = nil
	    end
	end
end

local function SetBtn()
	if not MainData.HadRecharged() and MainData.CanTakeRecharged() then
		_ui.price.text = TextMgr:GetText("mail_ui12")
		SetClickCallback(_ui.btn_pay, function()
			MainData.TakeFirstRechargeReward(CloseSelf)
			MainData.RequestFirstRechargeInfo(function()
				coroutine.start(function()
					local topMenu = GUIMgr:GetTopMenuOnRoot()
					while topMenu == nil or topMenu.name ~= "MainCityUI" do
						coroutine.step()
						topMenu = GUIMgr:GetTopMenuOnRoot()
						if topMenu.name == "TimedBag_notime" then
							return
						end
					end
					TimedBag_notime.Show()
				end)
			end)
		end)
	else
		local goodInfo = MainData.GetGoodInfo()
		GiftPackData.ExchangePrice(goodInfo)
		local platformType = GUIMgr:GetPlatformType()
		if platformType == LoginMsg_pb.AccType_adr_huawei then
			_ui.price.text = "SGD$" .. goodInfo.price
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
			_ui.price.text = "RMB￥" .. goodInfo.price
		else
			_ui.price.text = "US$" .. goodInfo.price
		end
		SetClickCallback(_ui.btn_pay, function()
			store.StartPay(goodInfo, TextMgr:GetText(goodInfo.name))
		end)
	end
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	MainData.RemoveListener(SetBtn)
end

function Show()
	if _ui ~= nil then
		GUIMgr:BringForward(transform.gameObject)
		SetBtn()
	else
	
		Global.OpenUI(_M)
	end
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("container/bg/close").gameObject
	_ui.btn_pay = transform:Find("container/paynow").gameObject
	_ui.grid = transform:Find("container/Sprite/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	_ui.price = transform:Find("container/paynow/Label"):GetComponent("UILabel")
	_ui.displayprice = transform:Find("container/bg2/bg_price/bg/num"):GetComponent("UILabel")
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	MainData.AddListener(SetBtn)
end

function Start()
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.container, CloseSelf)

	local giftPack = MainData.GetRewardInfo()
	SetBtn()

	local numItems = 0
	--[[if giftPack.itemBuy.item.item ~= nil and #giftPack.itemBuy.item.item > 0 then
		numItems = 1
		UIUtil.AddItemToGrid(_ui.grid.gameObject, giftPack.itemBuy.item.item[1])
	end--]]
	_ui.displayprice.text = MainData.GetDisplayPrice()
	for i, v in ipairs(giftPack.heros) do
		local heroData = TableMgr:GetHeroData(v.id)
		local hero = NGUITools.AddChild(_ui.grid.gameObject, _ui.hero.gameObject).transform
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
		SetParameter(hero:Find("head icon").gameObject, "hero_" .. v.id)
	end
	for _, item in ipairs(giftPack.items) do
		if item.id ~= 15 then
			local obj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
			SetParameter(obj.gameObject, "item_" .. item.id)
			numItems = numItems + 1
		end
	end
	_ui.grid:Reposition()
	
	-- local infos = MainData.GetRewardInfo()
	-- for i, v in ipairs(infos.heros) do
	-- 	local heroData = TableMgr:GetHeroData(v.id)
	-- 	local hero = NGUITools.AddChild(_ui.grid.gameObject, _ui.hero.gameObject).transform
	-- 	hero.localScale = Vector3(0.6, 0.6, 1) * 0.9
	-- 	hero:Find("level text").gameObject:SetActive(false)
	-- 	hero:Find("name text").gameObject:SetActive(false)
	-- 	hero:Find("bg_skill").gameObject:SetActive(false)
	-- 	hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
	-- 	hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
	-- 	local star = hero:Find("star"):GetComponent("UISprite")
	-- 	if star ~= nil then
	--         star.width = v.star * star.height
	--     end
	-- 	SetParameter(hero:Find("head icon").gameObject, "hero_" .. v.id)
	-- end
	-- for i, v in ipairs(infos.items) do
	-- 	local itemdata = TableMgr:GetItemData(v.id)
	-- 	local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
	-- 	item.localScale = Vector3.one * 0.9
	-- 	item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
	-- 	local num_item = item:Find("have")
	-- 	if v.num ~= nil and v.num > 1 then
	-- 		num_item.gameObject:SetActive(true)
	-- 		num_item:GetComponent("UILabel").text = v.num
	-- 	else
	-- 		num_item.gameObject:SetActive(false)
	-- 	end
	-- 	item:GetComponent("UISprite").spriteName = "bg_item" .. itemdata.quality
	-- 	local itemlvTrf = item.transform:Find("num")
	-- 	local itemlv = itemlvTrf:GetComponent("UILabel")
	-- 	itemlvTrf.gameObject:SetActive(true)
	-- 	if itemdata.showType == 1 then
	-- 		itemlv.text = Global.ExchangeValue2(itemdata.itemlevel)
	-- 	elseif itemdata.showType == 2 then
	-- 		itemlv.text = Global.ExchangeValue1(itemdata.itemlevel)
	-- 	elseif itemdata.showType == 3 then
	-- 		itemlv.text = Global.ExchangeValue3(itemdata.itemlevel)
	-- 	else 
	-- 		itemlvTrf.gameObject:SetActive(false)
	-- 	end
	-- 	SetParameter(item.gameObject, "item_" .. v.id)
	-- end
	-- _ui.grid:Reposition()
end

