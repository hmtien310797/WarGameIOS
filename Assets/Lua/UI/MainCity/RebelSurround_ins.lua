module("RebelSurround_ins",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String


local _ui


function Awake()
    _ui = {}
    _ui.Close = transform:Find("bg_frane/bg_top/btn_close")
    SetClickCallback(_ui.Close.gameObject,function()
        Hide()
    end)  

    _ui.Mask = transform:Find("mask")
    if _ui.Mask ~= nil then
        SetClickCallback(_ui.Mask.gameObject,function()
            Hide()
        end)        
    end
end

function Start()
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
	_ui = nil
end

function Show()
	Global.OpenUI(_M)	
end
