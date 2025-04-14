module("Sellrune", package.seeall)
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
local _ui, UpdateList

local function CloseSelf()
    Global.CloseUI(_M)
end

function Awake()
    _ui.btn_close = transform:Find("Container/bg_frane/top/close btn").gameObject
    _ui.scrollview = transform:Find("Container/bg_frane/bg/Scroll View"):GetComponent("UIScrollView")
    _ui.grid = transform:Find("Container/bg_frane/bg/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.list_myrune = transform:Find("Container/bg_frane/bg/list_myrune")

    _ui.btn_ok = transform:Find("Container/bg_frane/button2").gameObject
    _ui.btn_cancel = transform:Find("Container/bg_frane/button1").gameObject
    _ui.scrollview.panel.depth = _ui.scrollview.panel.depth + 5
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.btn_cancel, CloseSelf)
    SetClickCallback(_ui.btn_ok, function()
        _ui.tabRunes.totalSelect[_ui.level] = 0
        _ui.tabRunes.totalDebris[_ui.level] = 0
        for i, v in ipairs(_ui.tabRunes.items[_ui.level]) do
            if _ui.checklist[i] then
                _ui.tabRunes.totalSelect[_ui.level] = _ui.tabRunes.totalSelect[_ui.level] + v.num
                _ui.tabRunes.totalDebris[_ui.level] = _ui.tabRunes.totalDebris[_ui.level] + (v.tableData.Recycling.num * v.num)
            end
            v.checked = _ui.checklist[i]
        end
        CloseSelf()
    end)
    UpdateList()
    NGUITools.BringForward(gameObject)
end

UpdateList = function()
    _ui.checklist = {}
    for i, v in ipairs(_ui.tabRunes.items[_ui.level]) do
        local itemTransform = NGUITools.AddChild(_ui.grid.gameObject, _ui.list_myrune.gameObject).transform
        itemTransform:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("item/", v.itemData.icon)
        itemTransform:Find("Texture/number"):GetComponent("UILabel").text = v.num
        itemTransform:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(v.itemData.name)
        for ii = 1, 3 do
            local attr = itemTransform:Find(string.format("name/text%d", ii)):GetComponent("UILabel")
            local b = v.tableData.RuneAttribute[ii]
            attr.gameObject:SetActive(b ~= nil)
            if b ~= nil then
                attr.text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(b.BonusType, b.Attype)) .. (b.sign and "+" or "-") .. System.String.Format("{0:F}" , b.Value) .. (Global.IsHeroPercentAttrAddition(b.Attype) and "%" or "")
            end
        end

        local toggle = itemTransform:Find("checkbox"):GetComponent("UIToggle")
        SetClickCallback(toggle.gameObject, function()
            _ui.checklist[i] = toggle.value
        end)
        toggle.value = v.checked ~= false
        _ui.checklist[i] = v.checked ~= false
    end
    _ui.grid:Reposition()
end

function Show(tabRunes, level, callback)
    _ui = {}
    _ui.tabRunes = tabRunes
    _ui.level = level
    _ui.closeCallback = callback
    Global.OpenUI(_M)
end

function Close()
    if _ui.closeCallback ~= nil then
        _ui.closeCallback()
    end
    _ui = nil
end