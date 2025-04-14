module("Fort_predict", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local hasVisited = false

local ui

local isInViewport = false

local ACTIVITY_ID = 2007

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
		
		UIUtil.SetClickCallback(transform:Find("Container/bg_frane/mid/occuRule"):GetComponent("UIButton").gameObject, function()
			FortOccuRule.Show()
		end)

		UIUtil.SetClickCallback(transform:Find("Container/bg_frane/mid/rule"):GetComponent("UIButton").gameObject, function()
			FortRule.Show()
		end)
	end
end

local function SetUI()
	local contendStartTime = FortsData.GetContendStartTime()

	if Global.GetLeftCooldownSecond(contendStartTime) > 0 then
		ui.timer.gameObject:SetActive(true)
		CountDown.Instance:Add(_M._NAME, contendStartTime, function(text)
			ui.timer.display.text = text

			if text == "00:00:00" then
				ui.timer.gameObject:SetActive(false)
				CountDown.Instance:Remove(_M._NAME)
			end
		end)
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
end
