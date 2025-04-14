module("TimedBag", package.seeall)
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

local giftPack
local platformType

local ui

local isInViewport = false

------- CONSTANTS -------
local MAX_ITEM_SHOW = 6
-------------------------

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

function IsInViewport()
	return isInViewport
end

local function CloseSelf()
	--if #newGiftPacks ~= 0 then
		Redraw()
	--else
	--	Global.CloseUI(_M)
	--end
end

local function LoadUI()
	if isInViewport and ui == nil then
		ui = {}
		ui.gameObject = transform.gameObject
		ui.itemList = {}
		ui.mask = transform:Find("mask").gameObject
		ui.container = transform:Find("container")
		-- Buttons
		UIUtil.SetClickCallback(transform:Find("container/btn_close").gameObject, function()
			CloseSelf()
		end)
		ui.btnlabel = transform:Find("container/btn_purchase/price"):GetComponent("UILabel")
		ui.btn_go = transform:Find("container/btn_purchase").gameObject

		-- Textures
		ui.icon = transform:Find("container/icon"):GetComponent("UITexture")
		ui.background = transform:Find("container/art/background"):GetComponent("UITexture")

		-- Labels
		ui.name = transform:Find("container/name"):GetComponent("UILabel")
		ui.description = transform:Find("container/description"):GetComponent("UILabel")
		ui.countdown = transform:Find("container/countdown"):GetComponent("UILabel")
		ui.discount = transform:Find("container/discount/text"):GetComponent("UILabel")
		ui.originalPrice = transform:Find("container/bg_yuanjia/num"):GetComponent("UILabel")
		ui.price = transform:Find("container/bg_xianjia/num"):GetComponent("UILabel")
		ui.displayprice = transform:Find("container/bg2/bg_price/bg/num"):GetComponent("UILabel")
		ui.needPay = transform:Find("container/bg2/bg_xianjia/num"):GetComponent("UILabel")

		-- Grids
		ui.itemList.transform = transform:Find("container/items/Scroll View/grid")
		ui.itemList.gameObject = ui.itemList.transform.gameObject
		ui.itemList.grid = ui.itemList.transform:GetComponent("UIGrid")
	end
end

local function SetUI()
	if isInViewport then
		-- Bottons
		if giftPack.canTake then
			ui.btnlabel.text = TextMgr:GetText("mail_ui12")
			UIUtil.SetClickCallback(ui.btn_go, function()
				WelfareData.RequestTakeTriggerBagReward(giftPack.type, giftPack.param, function()
					Redraw(true)
				end)
			end)
			ui.countdown.gameObject:SetActive(false)
		else
			ui.btnlabel.text = TextMgr:GetText("recharge_ui1")
			UIUtil.SetClickCallback(ui.btn_go, function()
				store.Show()--StartPay(giftPack, TextMgr:GetText(giftPack.name))
			end)
			ui.countdown.gameObject:SetActive(true)
		end

		-- Textures
		ui.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", giftPack.icon)
		ui.background.mainTexture = ResourceLibrary:GetIcon("Background/", giftPack.mod)

		-- Labels
		ui.name.text = TextMgr:GetText(giftPack.name)
		ui.description.text = TextMgr:GetText(giftPack.desc)
		ui.displayprice.text = giftPack.bagPrice
		giftPack.needPay = GiftPackData.Exchange(giftPack.needPay)
		ui.needPay.text = giftPack.needPay
		--ui.discount.text = System.String.Format(TextMgr:GetText("ui_discount"), giftPack.discount)

		--[[if platformType == LoginMsg_pb.AccType_adr_huawei then
			ui.price.text = table.concat({"SGD$", giftPack.price})
			ui.originalPrice.text = table.concat({"US$", math.floor(giftPack.price * giftPack.discount / 100)})
		elseif platformType == LoginMsg_pb.AccType_adr_tmgp then
			ui.price.text = table.concat({"RMB￥", giftPack.price})
			ui.originalPrice.text = table.concat({"US$", math.floor(giftPack.price * giftPack.discount / 100)})
		else
			ui.price.text = table.concat({"US$", giftPack.price})
			ui.originalPrice.text = table.concat({"US$", math.floor(giftPack.price * giftPack.discount / 100)})
		end--]]

		-- Grids
		local numItems = 0
		--[[if giftPack.itemBuy.item.item ~= nil and #giftPack.itemBuy.item.item > 0 then
			numItems = 1
			UIUtil.AddItemToGrid(ui.itemList.gameObject, giftPack.itemBuy.item.item[1])
		end--]]

		for _, item in ipairs(giftPack.rewardInfo.items) do
			if item.id ~= 15 then
				local itemobj = UIUtil.AddItemToGrid(ui.itemList.gameObject, item)
				SetParameter(itemobj.gameObject, "item_" .. item.id)
				numItems = numItems + 1
			end
		end
		ui.itemList.grid:Reposition()
		--ui.itemList.transform.localScale = Vector3(0.9, 0.9, 1) - Vector3(0.15, 0.15, 0) * math.max(0, numItems - 5)

		-- Countdown
		if not giftPack.canTake and Serclimax.GameTime.GetSecTime() < giftPack.endTime then
			ui.countdown.text = Global.GetLeftCooldownTextLong(giftPack.endTime)
			CountDown.Instance:Add(_M._NAME, giftPack.endTime, function(text)
				ui.countdown.text = text

				if text == "00:00:00" then
					CountDown.Instance:Remove(_M._NAME)
					Global.CloseUI(_M)
				end
			end)
		end
	end
end

local function Draw()
	LoadUI()
	SetUI()
	GUIMgr:BringForward(ui.gameObject)
end

local function PopUp()
	NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_TimedGiftPack, function()
		if NotifyInfoData.HasNotifyPush(ClientMsg_pb.ClientNotifyType_TimedGiftPack) or NotifyInfoData.HaveAcitveNotify(ClientMsg_pb.ClientNotifyType_TimedGiftPack) then
			ui.gameObject:SetActive(true)
		else
			Global.CloseUI(_M)
		end
	end)
end

local function CheckPopUpCondition()
	if isInViewport and not ui.gameObject.activeSelf then
		local topMenu = GUIMgr:GetTopMenuOnRoot()
		if topMenu and topMenu.name == "MainCityUI" then
			ui.gameObject:SetActive(true)--PopUp()
		end
	end
end

function SuccessfullyPurchase(id)
	if isInViewport then
		if id == giftPack.id then
			CloseSelf()
		end
	end
end

function Redraw(notwait)
	local now = Serclimax.GameTime.GetSecTime()
	local waittime = 0
	local target_btn = MainCityUI.transform:Find("Container/bg_activity/Grid/GrowGold")
	if target_btn ~= nil and target_btn.gameObject.activeInHierarchy and not notwait then
		waittime = 0.5
	end
	local targettime = waittime
	local startpos = ui.container.position
	coroutine.start(function()
		while waittime > 0 do
			ui.mask:SetActive(false)
			waittime = waittime - Serclimax.GameTime.deltaTime
            local caculatetime = (targettime - waittime) / targettime
            if ui.container ~= nil and not ui.container:Equals(nil) then
                ui.container.position = Vector3(Mathf.Lerp(startpos.x, target_btn.position.x, caculatetime), Mathf.Lerp(startpos.y, target_btn.position.y, caculatetime), 0)
                ui.container.localScale = Vector3.one * (1 - caculatetime * 0.9)
            end
			coroutine.step()
		end
		if #newGiftPacks == 0 then
			Global.CloseUI(_M)--CloseSelf()
			return
		end
		giftPack = table.remove(newGiftPacks, 1)
		if now < giftPack.endTime then
			ui.mask:SetActive(true)
			ui.container.position = startpos
			ui.container.localScale = Vector3.one
			NGUITools.DestroyChildren(ui.itemList.transform)
			Draw()
		elseif #newGiftPacks ~= 0 then
			Redraw(notwait)
		end
	end)
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
        if not isInViewport then
			platformType = GUIMgr:GetPlatformType()
	
			local now = Serclimax.GameTime.GetSecTime()
			newGiftPacks = Global.copy_table(WelfareData.GetTriggerBagList())
			if #newGiftPacks ~= 0 then
				giftPack = newGiftPacks[1]
				table.remove(newGiftPacks, 1)
				
				if now < giftPack.endTime then
					Global.OpenUI(_M)
				elseif #newGiftPacks ~= 0 then
					Show()
				end
			end
		else
			newGiftPacks = Global.copy_table(WelfareData.GetTriggerBagList())
			Redraw(true)
		end
    end)
end

function Start()
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	isInViewport = true
	MainCityUI.RegisterPopUpUI(_M)

	Draw()

	ui.gameObject:SetActive(false)
	CheckPopUpCondition()

	EventDispatcher.Bind(Global.OnTick(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, CheckPopUpCondition)
end

function Close()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	EventDispatcher.UnbindAll(_M)

	isInViewport = false
	MainCityUI.DeregisterPopUpUI(_M)

	CountDown.Instance:Remove(_M._NAME)

	store.ClearNewTimedGiftPack()

	giftPack = nil
	platformType = nil

	ui = nil
end

