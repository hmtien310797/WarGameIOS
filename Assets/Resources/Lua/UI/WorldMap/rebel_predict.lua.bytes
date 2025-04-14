module("rebel_predict", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local hasVisited = false

local ui

local isInViewport = false

local INSTRUCTION_DATA = 
{
	title = "Union_Radar_ui30",
	icon = "Background/loading1",
	iconbg = "Background/loading2",
	text = "Union_Radar_ui31",
	infos = {"rebel_1",
			 "rebel_2",
			 "rebel_3",
			 "rebel_4",
			 "rebel_5",
			 "rebel_6",
			 "rebel_10"}
}

function HasVisited()
	return hasVisited or false
end

function NotifyAvailable()
	hasVisited = false
end

local function LoadUI()
	if ui == nil then
		ui = {}
		UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
			ActivityAll.CloseAll()
		end)

		ui.timer = {}
		ui.timer.gameObject = transform:Find("Container/bg_frane/mid/Sprite_time").gameObject
		ui.timer.display = ui.timer.gameObject.transform:Find("time"):GetComponent("UILabel")

		UIUtil.SetClickCallback(transform:Find("Container/bg_frane/mid/rule"):GetComponent("UIButton").gameObject, function()
			instructions.Show(INSTRUCTION_DATA)
		end)

		UIUtil.SetClickCallback(transform:Find("Container/bg_frane/mid/check"):GetComponent("UIButton").gameObject, function()
			rebel_reward.Show()
		end)

		UIUtil.SetClickCallback(transform:Find("Container/bg_frane/mid/record"):GetComponent("UIButton").gameObject, function()
			rebel_history.Show()
		end)
	end
end

local function SetUI()
	local config = ActivityData.GetBattleFieldActivityConfigs(2003)
	if config ~= nil then
		local endTime = config.endTime

		if Global.GetLeftCooldownSecond(endTime) > 0 then
			ui.timer.gameObject:SetActive(true)
			CountDown.Instance:Add(_M._NAME, endTime, function(text)
				ui.timer.display.text = text

				if text == "00:00:00" then
					ui.timer.gameObject:SetActive(false)
					CountDown.Instance:Remove(_M._NAME)
				end
			end)
		else
			ui.timer.gameObject:SetActive(false)
		end
	else
		ui.timer.gameObject:SetActive(false)
	end
end

local function Draw()
	LoadUI()
	SetUI()
end

function Refresh()
	if isInViewport then
		Draw()
	end
end

function Show()
	if not isInViewport then
		Global.OpenUI(_M)
	end
end

function Hide()
	if isInViewport then
		Global.CloseUI(_M)
	end
end

function Start()
	isInViewport = true

	if not hasVisited then
		hasVisited = true
		MainCityUI.UpdateActivityAllNotice(ACTIVITY_ID)
	end

	Draw()
end

function Close()
	isInViewport = false

	CountDown.Instance:Remove(_M._NAME)

	ui = nil
	isInViewport = false
end
