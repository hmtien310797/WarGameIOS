module("ActivityPveMonsterInfo", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local String = System.String

local _ui

local function CloseSelf()
	Global.CloseUI(_M)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.activeTime = transform:Find("Container/bg_frane/Scroll View/title_time/text_time"):GetComponent("UILabel")
	SetClickCallback(_ui.btn_close, function()
		CloseSelf()
		
	end)
	SetClickCallback(_ui.container, function()
		CloseSelf()
		
	end)
end

function Start()
	local data = TableMgr:GetActiveConditionData(102)
	_ui.activeTime.text =  data.sBegin .. "  -  " .. data.sEnd
end

function Show()
	Global.OpenUI(_M)
end

function Close()
	_ui = nil
end