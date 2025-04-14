module("Strategy",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local PlayerPrefs = UnityEngine.PlayerPrefs
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui, baseTable

function Hide()
	Global.CloseUI(_M)
end

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
end

function Show()
    Global.OpenUI(_M)
end

local function UpdateList(index)
    if _ui.curtab == index then
        return
    end
    _ui.texture.mainTexture = ResourceLibrary:GetIcon("Strategy/", baseTable[index].data.Icon)
    _ui.label.text = TextMgr:GetText(baseTable[index].data.Des)
    _ui.scrollView:ResetPosition()
    _ui.curtab = index
end

local function UpdateSelect(index)
    for i, v in pairs(_ui.leftBtns) do
        v.xuanzhong:SetActive(index == i)
        if index == i then
            UpdateList(v.Order)
        end
    end
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/background/close btn").gameObject
    _ui.mask = transform:Find("mask").gameObject

    _ui.left_grid = transform:Find("Container/content/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.left_tab = transform:Find("Container/content/bg_left/Scroll View/Grid/tab1")

    _ui.scrollView = transform:Find("Container/content/bg_right/Scroll View"):GetComponent("UIScrollView")
    _ui.texture = transform:Find("Container/content/bg_right/Scroll View/Texture"):GetComponent("UITexture")
    _ui.label = transform:Find("Container/content/bg_right/Scroll View/Label"):GetComponent("UILabel")

    if baseTable == nil then
        baseTable = {}
        for i, v in kpairs(tableData_tGuidance.data) do
            if baseTable[v.Order] == nil then
                baseTable[v.Order] = {}
                baseTable[v.Order].data = v
                baseTable[v.Order].btn = v.Title
            end
        end
    end
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.mask, CloseSelf)

    local index = 0
    _ui.leftBtns = {}
    for i, v in kpairs(baseTable) do
        local btn = {}
        if index < _ui.left_grid.transform.childCount then
            btn.transform = _ui.left_grid.transform:GetChild(index)
        else
            btn.transform = NGUITools.AddChild(_ui.left_grid.gameObject, _ui.left_tab.gameObject).transform
        end
        index = index + 1
        btn.transform:Find("txt_get"):GetComponent("UILabel").text = TextMgr:GetText(v.btn)
        btn.transform:Find("btn_xuanzhong/txt_get (1)"):GetComponent("UILabel").text = TextMgr:GetText(v.btn)
        btn.redpoint = btn.transform:Find("redpoint").gameObject
        btn.xuanzhong = btn.transform:Find("btn_xuanzhong").gameObject
        btn.Order = i
        SetClickCallback(btn.transform.gameObject, function()
            UpdateSelect(i)
        end)
        _ui.leftBtns[i] = btn
    end
    _ui.left_grid:Reposition()
    UpdateSelect(1)
end