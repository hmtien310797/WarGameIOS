module("FortOccuRule", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local ui

local isInViewport = false

local function LoadUI()
	if ui == nil then
		ui = {}

		UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
			Global.CloseUI(_M)
		end)

		UIUtil.SetClickCallback(transform:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton").gameObject, function()
			Global.CloseUI(_M)
		end)
	end
end

local function SetUI()
end

local function Draw()
	LoadUI()
	SetUI()
end

function Show()
	if not isInViewport then
		Global.OpenUI(_M)
		return true
	end

	print("[FortOccuRule.Show] The window is already in the viewport.")
	return false
end

function Start()
	isInViewport = true

	Draw()
end

function Close()
	isInViewport = false

	ui = nil
end
