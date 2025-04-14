module("GatherItemUI", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui
function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    _ui.gatherItem:LoadUI(_ui.itemId, _ui.needCount)
end

function Awake()
    _ui = {}
    local gatherItem = GatherItem()
    gatherItem:LoadObject(transform)
    SetClickCallback(gatherItem.closeButton.gameObject, CloseAll)
    SetClickCallback(transform:Find("mask").gameObject, CloseAll)
    _ui.gatherItem = gatherItem
end

function Close()
    _ui.gatherItem:Close()
    _ui = nil
end

function Show(itemId, needCount)
    print("item id:", itemId)
    Global.OpenUI(_M)
    _ui.itemId = itemId
    _ui.needCount = needCount
    LoadUI()
end
