module("DailyActivityHelp", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local _ui

function CloseSelf()
	_ui = nil
	Global.CloseUI(_M)
end

function Awake()
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.text_title = transform:Find("Container/bg_frane/bg_top/title/text (1)"):GetComponent("UILabel")
	_ui.text_info = transform:Find("Container/bg_frane/Scroll View/text"):GetComponent("UILabel")
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	_ui.text_title.text = TextMgr:GetText(_ui.title)
	_ui.text_info.text = TextMgr:GetText(_ui.info)
end

function Show(title, info)
	_ui = {}
	_ui.title = title
	_ui.info = info
	Global.OpenUI(_M)
end