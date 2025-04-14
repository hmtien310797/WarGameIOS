module("GrowGold", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback

local welfare

local ui

local isInViewPort = false

------ Constants ------
local WELFARE_ID = 3001
-----------------------

Refresh = nil

local function LoadData()
	welfare = WelfareData.GetWelfare(WELFARE_ID)
end

local function LoadUI()
	if ui == nil then
		ui = {}

		ui.newItem = {}
		ui.newItem.gameObject = transform:Find("Container/listinfo_item").gameObject
		ui.newItem.number = ui.newItem.gameObject.transform:Find("num"):GetComponent("UILabel")
		ui.newItem.icon = ui.newItem.gameObject.transform:Find("icon"):GetComponent("UITexture")
		
		ui.gameObject = transform:Find("Container/1").gameObject

		ui.gameObject.transform:Find("banner/tips02"):GetComponent("UILabel").text = welfare.goodInfo.showPrice --System.String.Format(TextMgr:GetText("GrowGold_7"), welfare.goodInfo.showPrice)

		ui.btn_help = ui.gameObject.transform:Find("banner/button_ins").gameObject
		UIUtil.SetClickCallback(ui.btn_help, function() -- TODO: btn_help
			FloatText.ShowOn(ui.purchase.btn, TextMgr:GetText("common_ui1"))
		end)

		ui.purchase = {}

		ui.purchase.time = {}
		ui.purchase.time.gameObject = ui.gameObject.transform:Find("banner/time").gameObject
		ui.purchase.time.display = ui.purchase.time.gameObject.transform:Find("number"):GetComponent("UILabel")

		ui.purchase.btn = ui.gameObject.transform:Find("button_buy").gameObject
		
		UIUtil.SetClickCallback(ui.purchase.btn, function()
			WelfareData.Purchase(WELFARE_ID)
		end)
		
		ui.purchase.btn.transform:Find("rmb"):GetComponent("UILabel").text = tostring(GiftPackData.Exchange(welfare.goodInfo.price))
		ui.dollar = ui.purchase.btn.transform:Find("dollar"):GetComponent("UILabel")

		local platformType = GUIMgr:GetPlatformType()
		if platformType == LoginMsg_pb.AccType_adr_tmgp or
		Global.IsIosMuzhi() or
		platformType == LoginMsg_pb.AccType_adr_muzhi or
		platformType == LoginMsg_pb.AccType_adr_opgame or
		platformType == LoginMsg_pb.AccType_adr_mango or
		platformType == LoginMsg_pb.AccType_adr_official or
		platformType == LoginMsg_pb.AccType_ios_official or
		platformType == LoginMsg_pb.AccType_adr_official_branch or
		platformType == LoginMsg_pb.AccType_adr_quick or
		platformType == LoginMsg_pb.AccType_adr_qihu then
			ui.dollar.text = "￥"
		else
			ui.dollar.text = "$"
		end

		ui.stageList = {}

		ui.stageList.gameObject = ui.gameObject.transform:Find("Scroll View/Grid").gameObject
		ui.stageList.grid = ui.stageList.gameObject.transform:GetComponent("UIGrid")
		
		ui.stageList.stages = {}
		
		ui.newReward = {}
		ui.newReward.gameObject = ui.gameObject.transform:Find("listitem_GrowGold").gameObject
		ui.newReward.label = ui.newReward.gameObject.transform:Find("bg/name"):GetComponent("UILabel")

		ui.newReward.statusDisplay = {}

		ui.newReward.statusDisplay[0] = ui.newReward.gameObject.transform:Find("btn_disabled").gameObject
		ui.newReward.statusDisplay[1] = ui.newReward.gameObject.transform:Find("btn_go").gameObject
		ui.newReward.statusDisplay[2] = ui.newReward.gameObject.transform:Find("btn_reward").gameObject
		ui.newReward.statusDisplay[3] = ui.newReward.gameObject.transform:Find("btn_complete").gameObject

		ui.newReward.progression = {}
		ui.newReward.progression.current = ui.newReward.gameObject.transform:Find("jindu/number1"):GetComponent("UILabel")
		ui.newReward.progression.target = ui.newReward.gameObject.transform:Find("jindu/number2"):GetComponent("UILabel")
		
		for _, stage in ipairs(welfare.progress) do
			ui.newReward.label.text = System.String.Format(TextMgr:GetText("GrowGold_1"), stage.needLevel)

			local stageUI = {}
			stageUI.gameObject = NGUITools.AddChild(ui.stageList.gameObject, ui.newReward.gameObject)
			stageUI.transform = stageUI.gameObject.transform
			stageUI.itemList = stageUI.gameObject.transform:Find("reward/Grid").gameObject

			for _, item in ipairs(stage.rewardInfo.items) do
				local itemData = TableMgr:GetItemData(item.id)
				ui.newItem.number.text = TextUtil.GetItemName(itemData) .. " x " .. Global.FormatNumber(item.num)
				ui.newItem.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
			
				NGUITools.AddChild(stageUI.itemList, ui.newItem.gameObject)
			end
			stageUI.itemList.transform:GetComponent("UIGrid"):Reposition()

			stageUI.statusDisplay = {}

			stageUI.statusDisplay[0] = stageUI.transform:Find("btn_disabled").gameObject
			UIUtil.SetClickCallback(stageUI.statusDisplay[0], function()
				FloatText.ShowOn(stageUI.statusDisplay[0], TextMgr:GetText("GrowGold_8"))
			end)

			stageUI.statusDisplay[1] = stageUI.transform:Find("btn_go").gameObject
			UIUtil.SetClickCallback(stageUI.statusDisplay[1], function()
				AudioMgr:PlayUISfx("SFX_ui01", 1, false)
				MainCityUI.HideWorldMap(GUIMgr:IsMenuOpen("WorldMap"), function()
					maincity.SetTargetBuild(1)
					Hide()
					WelfareAll.Hide()
					--local build = maincity.GetBuildingByUID(1)
					--BuildingUpgrade.SetTargetBuilding(build)
					--GUIMgr:CreateMenu("BuildingUpgrade" , false)
				end, true)
			end)

			stageUI.statusDisplay[2] = stageUI.transform:Find("btn_reward").gameObject
			stageUI.statusDisplay[3] = stageUI.transform:Find("btn_complete").gameObject

			stageUI.progression = {}
			stageUI.progression.transform = stageUI.transform:Find("jindu")
			stageUI.progression.gameObject = stageUI.progression.transform.gameObject
			stageUI.progression.current = stageUI.progression.transform:Find("number1"):GetComponent("UILabel")
			stageUI.progression.target = stageUI.progression.transform:Find("number2"):GetComponent("UILabel")

			ui.stageList.stages[stage.id] = stageUI

			stageUI.progression.target.text = string.format("/ %d", stage.needLevel)

			UIUtil.SetClickCallback(stageUI.statusDisplay[2], function()
				WelfareData.CollectReward(WELFARE_ID, stage.id, function()
					stageUI.gameObject.name = tostring(ShopMsg_pb.GrowFundStatus_HasTake * 100 + stage.id)

					for status = 0, 3 do
						stageUI.statusDisplay[status]:SetActive(status == (welfare.hasBuy and stage.status or 0))
					end
					
					ui.stageList.grid:Reposition()
				end)
			end)
		end

		ui.vip = VipWidget(transform:Find("Container/bg_vip"))

		MainData.AddListener(UpdateVip)
	end
end

function UpdateVip()
	ui.vip:Update()
end

local function SetUI()
	if ui == nil then return end

	ui.purchase.btn:SetActive(not welfare.hasBuy)

	if not welfare.hasBuy and welfare.buyEndTime > Serclimax.GameTime.GetSecTime() then
		CountDown.Instance:Add(_M._NAME, welfare.buyEndTime, function(t)
			local leftTime = Global.GetLeftCooldownSecond(welfare.buyEndTime)
			ui.purchase.time.text = Global.SecondToTimeLong(leftTime)

			if leftTime <= 0 then
				ui.purchase.time.gameObject.gameObject:SetActive(false)
				CountDown.Instance:Remove(_M._NAME)
			end
		end)
		ui.purchase.time.gameObject:SetActive(true)
	else
		ui.purchase.time.gameObject:SetActive(false)
	end

	local currentProgression = tostring(BuildingData.GetCommandCenterData().level)

	for _, stage in ipairs(welfare.progress) do
		local stageUI = ui.stageList.stages[stage.id]

		stageUI.gameObject.name = tostring((stage.status >= ShopMsg_pb.GrowFundStatus_HasTake and (ShopMsg_pb.GrowFundStatus_HasTake * 100) or 100) + stage.id)
		
		local currentStatus = welfare.hasBuy and stage.status or 0
		for status = 0, 3 do
			stageUI.statusDisplay[status]:SetActive(status == currentStatus)
		end
		
		local color =  "[ff0000]" 
		if BuildingData.GetCommandCenterData().level >= stage.needLevel then
			color =  "[4ABC1EFF]" 
		end
		stageUI.progression.current.text = color .. math.min(currentProgression, stage.needLevel)

		stageUI.progression.gameObject:SetActive(welfare.hasBuy and stage.status == ShopMsg_pb.GrowFundStatus_CannotTake)
	end
	ui.stageList.grid:Reposition()

	UpdateVip()
end

local function Draw()
	LoadData()
	LoadUI()
	SetUI()
end

Refresh = function()
	LoadData()
	SetUI()
end

function Show()
	if not isInViewPort then
		Global.OpenUI(_M)
	end
end

function Hide()
	if isInViewPort then
		Global.CloseUI(_M)
	end
end

function Start()
	local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, WelfareAll.Hide)
	isInViewPort = true
		
	Draw()
end

function Close()
	isInViewPort = false

	MainData.RemoveListener(UpdateVip)

	CountDown.Instance:Remove(_M._NAME)

	welfare = nil
	currentProgression = nil

	ui = nil
end

----- Template:Goldstore --------------------------
function OnNoticeStatusChange(config)
    return WelfareData.OnAwardStatusChange()
end

function OnAvailabilityChange(config)
    return ActivityData.OnAvailabilityChange()
end

function HasNotice(config)
    return WelfareData.UpdateWelfareProgression(3001)
end

function IsAvailable(config)
    return ActivityData.IsActivityAvailable(3001)
end

--Goldstore.RegisterAsTemplate(4, _M)
---------------------------------------------------
