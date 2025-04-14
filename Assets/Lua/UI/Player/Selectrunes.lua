module("Selectrunes", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local _ui,UpdateList,UpdatePos,Selected,_Callback,Callback,UpdateUI
local tbl

function Awake()
    _ui = {}
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("options/bg_frane/bg_top/btn_close").gameObject
	_ui.scrollview = transform:Find("options/bg_frane/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("options/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("options/ListInfo")
    _ui.btn_ok = transform:Find("options/bg_frane/btn").gameObject
    tbl = {}
end

local function CloseSelf()
    Global.CloseUI(_M)
end

function Start()
    UpdateUI()
    SetClickCallback(_ui.btn_close,CloseSelf)
--    tbl = nil
    SetClickCallback(_ui.btn_ok,function()
        if _Callback ~= nil then
           _Callback(tbl)
           _Callback = nil
        end
    CloseSelf()
    end)
end

UpdateUI = function()
    UpdateList()
end


function Show(Callback)
    _Callback = Callback
    Global.OpenUI(_M)
end

UpdateList = function()
    for i = 1 , 5 do 
        local item = NGUITools.AddChild(_ui.grid.gameObject,_ui.item.gameObject).transform
        item.gameObject:SetActive(true)
        item:Find("bg/name_zhanli"):GetComponent("UILabel").text = TextMgr:GetText("ui_rune_" .. (35 + i))
        local toggle = item:Find("bg/checkbox"):GetComponent("UIToggle")
        EventDelegate.Add(toggle.onChange,EventDelegate.Callback(function()
            tbl[i] = toggle.value
        end))
    end
    _ui.grid:Reposition()
end


function Close()
    tbl = nil
    _ui = nil
end