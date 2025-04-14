module("ExistTestHelp", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local String = System.String
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _ui

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
    _ui = nil
end

function Awake()
    _ui = {}
    _ui.mask = transform:Find("mask").gameObject
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
end

function Start()
    SetClickCallback(_ui.mask, CloseSelf)
    SetClickCallback(_ui.btn_close, CloseSelf)
end

function Show()
    Global.OpenUI(_M)
end