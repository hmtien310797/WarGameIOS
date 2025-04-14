module("GMLog", package.seeall)

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

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Awake()
    _ui = {}
    _ui.okButton = transform:Find("bg_log/bg/btn_confirm")
    SetClickCallback(_ui.okButton.gameObject, CloseAll)
    _ui.logTextList = transform:Find("bg_log/bg"):GetComponent("UITextList")
end

function Start()
    _ui.logTextList:Clear()
    _ui.logTextList:Add(_ui.log)
end

function Close()
    _ui = nil
end

function Show(log)
    Global.OpenTopUI(_M)
    _ui.log = log
end
