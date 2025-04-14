module("RebelSurrounddefenceshow",package.seeall)

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
local paradeItemList

function Awake()
    _ui = {}
    _ui.Close = transform:Find("Container/close btn")
    SetClickCallback(_ui.Close.gameObject,function()
        Hide()
    end)    

    _ui.Mask = transform:Find("mask")
    if _ui.Mask ~= nil then
        SetClickCallback(_ui.Mask.gameObject,function()
            Hide()
        end)        
    end     
    _ui.root = transform:Find("Container/Scroll View/ArmyUI_Type_1")
end

function Start()
    paradeItemList = {}
    ParadeGround.SetDefentArmyUI(_ui.root,paradeItemList,nil,true)
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
    _ui = nil
    paradeItemList = nil
end

function Show()
	Global.OpenUI(_M)	
end
