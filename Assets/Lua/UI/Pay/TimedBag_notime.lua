module("TimedBag_notime", package.seeall)
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

local function YieldClose()
    local now = Serclimax.GameTime.GetSecTime()
	local waittime = 0
	local target_btn = MainCityUI.transform:Find("Container/bg_activity/Grid/firstpurchase")
	if target_btn ~= nil and target_btn.gameObject.activeInHierarchy and not notwait then
		waittime = 1
	end
	local targettime = waittime
	local startpos = transform.position--_ui.container.transform.position
	if waittime > 0 then
		local bigcollider = NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/BigCollider"))
		local closestar = NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/closed"))
		_ui.mask:SetActive(false)
		_ui.closepart.guang:SetActive(true)
		_ui.closepart.scale.enabled = true
		_ui.closepart.alpha.enabled = true
		coroutine.start(function()
			while waittime > 0 do
				waittime = waittime - Serclimax.GameTime.deltaTime
				--[[local caculatetime = (targettime - waittime) / targettime
				if _ui.container ~= nil and not _ui.container:Equals(nil) then
					_ui.container.transform.position = Vector3(Mathf.Lerp(startpos.x, target_btn.position.x, caculatetime), Mathf.Lerp(startpos.y, target_btn.position.y, caculatetime), 0)
					_ui.container.transform.localScale = Vector3.one * (1 - caculatetime * 0.9)
				end]]
				coroutine.step()
			end
			CloseSelf()
			while waittime < 0.5 do
				waittime = waittime + Serclimax.GameTime.deltaTime
				closestar.transform.position = Vector3(Mathf.Lerp(startpos.x, target_btn.position.x, waittime * 2), Mathf.Lerp(startpos.y, target_btn.position.y, waittime * 2), 0)
				coroutine.step()
			end
			GameObject.DestroyImmediate(closestar)
			GameObject.DestroyImmediate(bigcollider)
		end)
	else
		CloseSelf()
	end
end

local function SetBtn()
	local goodInfo = MainData.GetRecommendGoodInfo()
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
        if MainData.GetRecommendGoodInfo().id > 0 then
			Global.OpenUI(_M)
		end
    end)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("container/btn_close").gameObject
	_ui.btn_pay = transform:Find("container/btn_purchase").gameObject
	_ui.grid = transform:Find("container/items/Scroll View/grid"):GetComponent("UIGrid")
	_ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	_ui.price = transform:Find("container/btn_purchase/price"):GetComponent("UILabel")
    _ui.displayprice = transform:Find("container/bg_yuanjia/num"):GetComponent("UILabel")
    _ui.description = transform:Find("container/description"):GetComponent("UILabel")
	_ui.nameLabel = transform:Find("container/name"):GetComponent("UILabel")
	_ui.closepart = {}
	_ui.closepart.guang = transform:Find("container/guang").gameObject
	_ui.closepart.scale = _ui.container:GetComponent("TweenScale")
	_ui.closepart.alpha = _ui.container:GetComponent("TweenAlpha")
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	MainData.AddListener(SetBtn)
end

function Start()
	SetClickCallback(_ui.btn_close, YieldClose)
	SetClickCallback(_ui.container, YieldClose)
	_ui.discount = NGUITools.AddChild(_ui.displayprice.transform.parent.gameObject, ResourceLibrary.GetUIPrefab("Pay/Discount/Discount")).transform:Find("Num"):GetComponent("UILabel")
	_ui.discount.transform.parent.localPosition = Vector3(72, 11, 0)
	_ui.discount.transform.parent.localScale = Vector3(0.8, 0.6, 1)
	_ui.discount.transform.parent.localEulerAngles = Vector3(0, 0, -16)
	
    local giftPack = MainData.GetRecommendGoodInfo()
    local config = TableMgr:GetGiftpackPopupConfig(giftPack.id)
	if config == nil then
		CloseSelf()
		print("配表错了！！！！！！！没找到id：", giftPack.id)
	end
    local modNumber = 1
    local mod = config["mod" .. modNumber]
    while not System.String.IsNullOrEmpty(mod) do
        UIUtil.LoadMOD(transform, mod)

        modNumber = modNumber + 1
        mod = config["mod" .. modNumber]
    end
	SetBtn()
    _ui.nameLabel.text = TextMgr:GetText(giftPack.name)
	_ui.description.text = TextMgr:GetText(giftPack.desc)
	_ui.discount.text = System.String.Format(TextMgr:GetText("ui_discount"), giftPack.discount)
	local numItems = 0
    _ui.displayprice.text = giftPack.showPrice
    for _, item in ipairs(giftPack.itemBuy.item.item) do
		if item.baseid ~= 15 then
			local obj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
			SetParameter(obj.gameObject, "item_" .. item.baseid)
			numItems = numItems + 1
		end
	end
	for _, item in ipairs(giftPack.itemGift.item.item) do
		if item.baseid ~= 15 then
			local obj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
			SetParameter(obj.gameObject, "item_" .. item.baseid)
			numItems = numItems + 1
		end
	end
	_ui.grid:Reposition()
end