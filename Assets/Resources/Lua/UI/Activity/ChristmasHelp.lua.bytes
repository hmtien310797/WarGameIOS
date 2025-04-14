module("ChristmasHelp", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui = nil

function Hide()
    Global.CloseUI(_M)
end

local function LoadUI()
	UIUtil.SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject, Hide)
    
end

function Awake()
    _ui = {}

end

function Start()
    LoadUI()
end


function Show()
    Global.OpenUI(_M)

end

function Close()
    _ui = nil
end

