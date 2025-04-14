module("TimedBag_VIP", package.seeall)
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

local _ui, _goodInfo
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
		end)
	else
		local goodInfo = _goodInfo
		local platformType = GUIMgr:GetPlatformType()
		if platformType == LoginMsg_pb.AccType_adr_huawei then
			_ui.price.text = "SGD$" .. goodInfo.price
		elseif platformType == LoginMsg_pb.AccType_adr_tmgp or
		platformType == LoginMsg_pb.AccType_ios_muzhi or
		platformType == LoginMsg_pb.AccType_ios_muzhi2 or
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
	coroutine.start(function()
        local topMenu = GUIMgr:GetTopMenuOnRoot()
		local isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
		while topMenu == nil or topMenu.name ~= "MainCityUI" or isInGuide do
			coroutine.wait(0.5)
            topMenu = GUIMgr:GetTopMenuOnRoot()
            isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
		end
        MainData.RequestIAPSingleGoodInfo(801, function(goodInfo)
			_goodInfo = goodInfo
			Global.OpenUI(_M)
		end)
    end)
    
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("container/btn_close").gameObject
	_ui.btn_pay = transform:Find("container/btn_purchase").gameObject
	_ui.grid = transform:Find("container/items/grid"):GetComponent("UIGrid")
	_ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	_ui.price = transform:Find("container/btn_purchase/price"):GetComponent("UILabel")
    _ui.displayprice = transform:Find("container/bg_yuanjia/num"):GetComponent("UILabel")
    _ui.description = transform:Find("container/description"):GetComponent("UILabel")
    _ui.nameLabel = transform:Find("container/name"):GetComponent("UILabel")
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	MainData.AddListener(SetBtn)
end

function Start()
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.container, CloseSelf)
	_ui.discount = NGUITools.AddChild(_ui.displayprice.transform.parent.gameObject, ResourceLibrary.GetUIPrefab("Pay/Discount/Discount")).transform:Find("Num"):GetComponent("UILabel")
	_ui.discount.transform.parent.localPosition = Vector3(72, 11, 0)
	_ui.discount.transform.parent.localScale = Vector3(0.8, 0.6, 1)
	_ui.discount.transform.parent.localEulerAngles = Vector3(0, 0, -16)
	local giftPack = _goodInfo
	SetBtn()
    _ui.nameLabel.text = TextMgr:GetText(giftPack.name)
	_ui.description.text = TextMgr:GetText(giftPack.desc)
	_ui.discount.text = System.String.Format(TextMgr:GetText("ui_discount"), giftPack.discount)
	local numItems = 0
	_ui.displayprice.text = giftPack.showPrice
	for _, item in ipairs(giftPack.itemBuy.item.item) do
		local obj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
		SetParameter(obj.gameObject, "item_" .. item.baseid)
		numItems = numItems + 1
	end
	for _, item in ipairs(giftPack.itemGift.item.item) do
		local obj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
		SetParameter(obj.gameObject, "item_" .. item.baseid)
		numItems = numItems + 1
	end
	_ui.grid:Reposition()
end