module("ActivityForecast", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local activities
local currentActivity

local ui
local closeCallback

function IsInViewport()
	return ui ~= nil
end

local function GetCurrentActivity()
	return currentActivity
end

local function UpdateUI()
	ui.title.text = TextMgr:GetText(currentActivity.forecastConfig.title)
	ui.image.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", currentActivity.forecastConfig.image)
	ui.text1.text = TextMgr:GetText(currentActivity.forecastConfig.text1)
	ui.text2.text = TextMgr:GetText(currentActivity.forecastConfig.text2)
	ui.countdown.text = Global.GetLeftCooldownTextLong(currentActivity.endTime)
end

local function ShowNext()
	currentActivity = activities:Pop()
	UpdateUI()
end

local function ShowNextOrHide()
	if activities:IsEmpty() then
		Hide()
	else
		ShowNext()
	end
end

function Hide()
	Global.CloseUI(_M)
end

function Show(_closeCallback)
	activities = PriorityQueue(nil, function(activityA, activityB)
		return activityA.forecastConfig.order < activityB.forecastConfig.order
	end)

	for id, forecastConfig in pairs(tableData_tActivityForecast.data) do
		local activityConfig = ActivityData.GetActivityConfig(id)
		if activityConfig then
			local activity = {}
			activity.endTime = activityConfig.endTime
			activity.forecastConfig = forecastConfig

			activities:Push(activity)
		end
	end

	if not activities:IsEmpty() then
		closeCallback = _closeCallback
		Global.OpenUI(_M)
	elseif _closeCallback then
		activities = nil
		_closeCallback()
	end
end

function Awake()
	ui = {}

	ui.title = transform:Find("container/background/top/title/text"):GetComponent("UILabel")
	ui.image = transform:Find("container/background/middle/image"):GetComponent("UITexture")
	ui.text1 = transform:Find("container/background/bottom/text1"):GetComponent("UILabel")
	ui.text2 = transform:Find("container/background/bottom/text2"):GetComponent("UILabel")
	ui.countdown = transform:Find("container/background/bottom/countdown/text"):GetComponent("UILabel")

	UIUtil.SetClickCallback(transform:Find("container").gameObject, ShowNextOrHide)
	UIUtil.SetClickCallback(transform:Find("mask").gameObject, ShowNextOrHide)
	UIUtil.SetClickCallback(transform:Find("container/background/top/btn_close").gameObject, ShowNextOrHide)
end

function Start()
	ShowNext()

	CountDown.Instance:Add("ActivityForecast", Serclimax.GameTime.GetSecTime() + 86400, function()
		ui.countdown.text = Global.GetLeftCooldownTextLong(GetCurrentActivity().endTime)
		if Serclimax.GameTime.GetSecTime() >= GetCurrentActivity().endTime then
			ShowNextOrHide()
		end
    end)
end

function Close()
	if closeCallback then
		closeCallback()
	end

	CountDown.Instance:Remove("ActivityForecast")

	activities = nil
	currentActivity = nil

	ui = nil
	closeCallback = nil
end
