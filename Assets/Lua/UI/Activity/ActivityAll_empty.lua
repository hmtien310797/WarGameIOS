module("ActivityAll_empty", package.seeall)

local isInViewport = false

local function LoadUI()
	UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
		ActivityAll.CloseAll()
		WelfareAll.Hide()
	end)

	UIUtil.SetClickCallback(transform:Find("Container/background/close btn").gameObject, function()
		ActivityAll.CloseAll()
		WelfareAll.Hide()
	end)
end

local function SetUI()
end

local function Draw()
	LoadUI()
	SetUI()
end

function Hide()
	if isInViewport then
		Global.CloseUI(_M)
	end
end

function Show()
	if not isInViewport then
		Global.OpenUI(_M)
	end
end

function Start()
	isInViewport = true

	Draw()
end

function Close()
	isInViewport = false
end

function Refresh()
    
end
