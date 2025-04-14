module("FortInfoall", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local forts
local config

local status = 0

local ui

local isInViewPort = false

local Draw = nil

local ACTIVITY_ID = ActivityAll.GetActivityIdByName("Fort")

local function UpdateNotice()
	MainCityUI.UpdateActivityAllNotice(ACTIVITY_ID)
end

function HasNotice()
	return isNew
end

function NotifyAvailable()
	isNew = true
end

local function LoadUI()
	if ui == nil then
		ui = {}

		UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
			ActivityAll.Hide()
			Global.CloseUI(_M)
		end)

		UIUtil.SetClickCallback(transform:Find("Container/background/close btn"):GetComponent("UIButton").gameObject, function()
			ActivityAll.Hide()
			Global.CloseUI(_M)
		end)

		ui.fortInfo = {}
		for subType = 1, 6 do
			ui.fortInfo[subType] = {}
			ui.fortInfo[subType].status = transform:Find(string.format("Container/Container%d/text", subType)):GetComponent("UILabel")
			
			--跳转按钮
			UIUtil.SetClickCallback(transform:Find(string.format("Container/Container%d/button04", subType)).gameObject, function()
				MainCityUI.ShowWorldMap(forts[subType].pos.x, forts[subType].pos.y, true, nil)
				ActivityAll.Hide()
				Global.CloseUI(_M)
			end)
		end

		ui.status = transform:Find("Container/bg_time/Label"):GetComponent("UILabel")
		ui.time = transform:Find("Container/bg_time/time"):GetComponent("UILabel")

		UIUtil.SetClickCallback(transform:Find("Container/bg_bottom/button01"):GetComponent("UIButton").gameObject, function()
			FortRule.Show()
		end)
		
		UIUtil.SetClickCallback(transform:Find("Container/bg_bottom/button02"):GetComponent("UIButton").gameObject, function()
			FortOccuRule.Show()
		end)
	end

	if status == 3 then --争夺中
		for i = 1, 6 do
			ui.fortInfo[i].guild = {}
			ui.fortInfo[i].guild[1] = transform:Find(string.format("Container/Container%d/name1", i)):GetComponent("UILabel")
			ui.fortInfo[i].guild[2] = transform:Find(string.format("Container/Container%d/name2", i)):GetComponent("UILabel")
			ui.fortInfo[i].guild[3] = transform:Find(string.format("Container/Container%d/name3", i)):GetComponent("UILabel")
		end
	end
end

local function SetUI()
	if status == 2 then --预告中
		for subType = 1, 6 do
			ui.fortInfo[subType].status.text = TextMgr:GetText(forts[subType].available and "Fort_ui1" or "Fort_ui6")
		end

		ui.status.text = TextMgr:GetText("Duke_30")

		-- 显示倒计时
		CountDown.Instance:Add(_M._NAME, config.contendStartTime, CountDown.CountDownCallBack(function(text)
			ui.time.text = text

			if text == "00:00:00" then
				CountDown.Instance:Remove(_M._NAME)
				status = 3
				Draw()
			end
		end))
	elseif status == 3 then --争夺中
		for subType = 1, 6 do
			local fortInfoUI = ui.fortInfo[subType]
			local fort = forts[subType]

			if fort.available then --要塞开启
				fortInfoUI.status.text = TextMgr:GetText("Duke_53")

				local rankList = fort.contendInfo.rankList
				for rank = 1, math.min(3, table.getn(rankList)) do
					fortInfoUI.guild[rank].text = string.format("[%s]%s", rankList[rank].guildBanner, rankList[rank].guildName)
				end
			else --要塞未开启
				fortInfoUI.status.text = TextMgr:GetText("Fort_ui6")
			end
		end

		ui.status.text = TextMgr:GetText("Duke_54")

		--倒计时
		CountDown.Instance:Add(_M._NAME, config.contendEndTime, CountDown.CountDownCallBack(function(text)
			ui.time.text = text

			if text == "00:00:00" then
				CountDown.Instance:Remove(_M._NAME)
			end
		end))
	end
end

Draw = function()
	LoadUI()
	SetUI()
end

----------
-- APIs --
----------

function Show(callback)
	if not isInViewPort then
		FortsData.RequestFortsData(function(_forts, _config, _status)
			if ActivityAll.IsInViewport() and ActivityAll.GetTabActivityID() == ACTIVITY_ID then
				forts = _forts
				config = _config
				status = _status

				if status >= 2 and status <= 3 then
					Global.OpenUI(_M)

					if callback ~= nil then
						callback()
					end
				else
					Global.ShowError(ReturnCode_pb.Code_SceneMap_ForActStatusInvalid)
					ActivityAll.CloseAll()
				end
			end
		end)

		return true
	end

	print("[FortInfoall.Show] The window is already in the viewport.")
	return false
end

function Hide()
	if isInViewPort then
		Global.CloseUI(_M)
	end
end

function Refresh()
	if isInViewPort then
		FortsData.RequestFortsData(function(_forts, _config, _status)
			forts = _forts
			config = _config
			status = _status

			if status >= 2 and status <= 3 then
				Draw()
			else
				Global.ShowError(ReturnCode_pb.Code_SceneMap_ForActStatusInvalid)
				ActivityAll.CloseAll()
			end
		end)
	end
end

function Start()
	isInViewPort = true

	if isNew then
		isNew = false
		UpdateNotice()
	end

	Draw()
end

function Close()
	isInViewPort = false
	
	CountDown.Instance:Remove(_M._NAME)

	forts = nil
	config = nil
	status = 0

	ui = nil
end
