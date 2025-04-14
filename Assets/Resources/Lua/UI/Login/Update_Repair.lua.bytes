module("Update_Repair", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local _ui

local function CloseSelf()
	Global.CloseUI(_M)
end

function Awake()
	_ui = {}
	
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.btn_ok = transform:Find("Container/bg_frane/btn_ok").gameObject
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.btn_ok, function()
		MessageBox.Show(TextMgr:GetText("Update_Repair_ui3"), function()
			CloseSelf()
			AssetBundleManager.Instance:DeleteAllAssetBundles()
		end, function() end)
	end)
end

function Close()
	_ui = nil
end

function Show()
	Global.OpenTopUI(_M)
end