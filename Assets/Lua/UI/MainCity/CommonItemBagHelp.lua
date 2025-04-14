module("CommonItemBagHelp", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local ui

local function LoadUI()
	ui = {}

	UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
		Global.CloseUI(_M)
	end)

	UIUtil.SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton").gameObject, function()
		Global.CloseUI(_M)
	end)
end

local function SetUI()
end

local function Draw()
	LoadUI()
	SetUI()
end

function Show()
	Global.OpenUI(_M)
end

function Start()
	Draw()
end

function Close()
	ui = nil
end
