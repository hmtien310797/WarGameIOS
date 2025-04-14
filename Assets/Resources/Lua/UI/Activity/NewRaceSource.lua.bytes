module("NewRaceSource", package.seeall)

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
local GameObject = UnityEngine.GameObject

local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui.scoreSourceMask = transform:Find("mask").gameObject
    _ui.scoreSourceClose = transform:Find("Container/base/top/close").gameObject

    _ui.scoreSourceGrid = transform:Find("Container/base/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.scoreSourceItem = transform:Find("Container/base/list")
end

local function SetSource()
    local childCount = _ui.scoreSourceGrid.transform.childCount
    for i, v in ipairs(_ui.sourceData) do
        local itemTransform 
        if i - 1 < childCount then
            itemTransform = _ui.scoreSourceGrid.transform:GetChild(i - 1)
        else
            itemTransform = NGUITools.AddChild(_ui.scoreSourceGrid.gameObject, _ui.scoreSourceItem.gameObject).transform
        end
        local ruledata = TableMgr:GetActiveStaticsRuleData(v)
        itemTransform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(ruledata.text)
        itemTransform:Find("number"):GetComponent("UILabel").text = v == "121" and "" or ruledata.point
    end
    for i = #_ui.sourceData, childCount - 1 do
        GameObject.Destroy(_ui.scoreSourceGrid.transform:GetChild(i).gameObject)
    end
    _ui.scoreSourceGrid:Reposition()
end

function Start()
    SetClickCallback(_ui.scoreSourceMask, Hide)
    SetClickCallback(_ui.scoreSourceClose, Hide)
    SetSource()
end

function Close()
    _ui = nil
end

function Show(sourceData)
    _ui = {}
    _ui.sourceData = sourceData
    Global.OpenUI(_M)
end
