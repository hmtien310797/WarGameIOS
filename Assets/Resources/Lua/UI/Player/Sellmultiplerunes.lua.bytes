module("Sellmultiplerunes", package.seeall)
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
local _ui, UpdateItem

local function PlaySfx()
    for i, v in ipairs(_ui.rune_items) do
        if v.selected then
            v.sfx:SetActive(false)
            v.sfx:SetActive(true)
        end
    end
end

function Awake()
    _ui.Close_btn = transform:Find("Container/bg_frane/top/close btn").gameObject
    _ui.decompose_btn = transform:Find("Container/bg_frane/button").gameObject
    _ui.rune_items = {}
    for i = 1, 5 do
        local item = {}
        item.transform = transform:Find(string.format("Container/bg_frane/bg/Grid/%d", i))
        item.collider = item.transform:Find("Texture").gameObject
        item.select = item.transform:Find("Texture/glow").gameObject
        item.info = item.transform:Find("Texture/info").gameObject
        item.number = item.transform:Find("Texture/number"):GetComponent("UILabel")
        item.sfx = item.transform:Find("Texture/rune/sfx_b").gameObject
        item.selected = false
        item.sfx:SetActive(false)
        item.select:SetActive(false)
        SetClickCallback(item.collider, function()
            item.selected = not item.selected
            item.select:SetActive(item.selected)
            UpdateItem()
        end)
        SetClickCallback(item.info, function()
            Sellrune.Show(_ui.tabRunes, i, UpdateItem)
        end)
        _ui.rune_items[i] = item
    end

    _ui.btn_fenjie = transform:Find("Container/bg_frane/button").gameObject
    _ui.btn_number = transform:Find("Container/bg_frane/button/Label/number"):GetComponent("UILabel")
end

local function CloseSelf()
    Global.CloseUI(_M)
end

UpdateItem = function()
    local totalDebris = 0
    for i, v in ipairs(_ui.rune_items) do
        v.number.text = _ui.tabRunes.totalSelect[i] ~= nil and _ui.tabRunes.totalSelect[i] or 0
        v.info:SetActive(_ui.tabRunes.total[i] > 0)
        if v.selected then
            totalDebris = totalDebris + _ui.tabRunes.totalDebris[i]
        end
    end
    _ui.btn_number.text = totalDebris
end

function Start()
    SetClickCallback(_ui.Close_btn,CloseSelf)
    SetClickCallback(_ui.btn_fenjie, function()
        MessageBox.Show(TextMgr:GetText("ui_rune_33"),function()
            local uids = {}
            for i, v in ipairs(_ui.rune_items) do
                if v.selected then
                    for ii, vv in ipairs(_ui.tabRunes.items[i]) do
                        if vv.checked ~= false then
                            for iii, vvv in ipairs(_ui.tabRunes.uidlist[vv.itemData.id]) do
                                table.insert(uids, vvv)
                            end
                        end
                    end
                end
            end
            RuneData.RequestDecomposeRune(uids, function()
                PlaySfx()
            end)
        end,function() end)
    end)
    UpdateItem()
end

function Show(tabRunes)
    _ui = {}
    _ui.tabRunes = tabRunes
    Global.OpenUI(_M)
end

function SetData(tabRunes)
    if _ui ~= nil then
        _ui.tabRunes = tabRunes
        UpdateItem()
    end
end

function Close()
    _ui = nil
end