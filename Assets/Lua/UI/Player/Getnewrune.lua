module("Getnewrune", package.seeall)
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
local _ui

local function CloseSelf()
    Global.CloseUI(_M)
end

function Close()
    _ui = nil
end

function Awake()
    _ui.btn = transform:Find("options/bg_frane/btn").gameObject
    _ui.texture = transform:Find("options/bg_frane/NEW"):GetComponent("UITexture")
    _ui.name = transform:Find("options/bg_frane/NEW/name"):GetComponent("UILabel")
    _ui.mask = transform:Find("mask").gameObject
    _ui.attrs = {}
    for i = 1, 3 do
        local attr = {}
        attr.name = transform:Find(string.format("options/bg_frane/NEW/text%d", i)):GetComponent("UILabel")
        attr.value = attr.name.transform:Find("number"):GetComponent("UILabel")
        _ui.attrs[i] = attr
    end
end

function Start()
    SetClickCallback(_ui.btn, function()
        if _ui.callback ~= nil then
            _ui.callback()
        end
        CloseSelf()
    end)
    SetClickCallback(_ui.mask,function()
        if _ui.callback ~= nil then
            _ui.callback()
        end
        CloseSelf()
    end)
    _ui.texture.mainTexture = ResourceLibrary:GetIcon("Item/", _ui.data.icon)
    _ui.name.text = TextUtil.GetItemName(_ui.data)
    local index = 0
    for i, v in ipairs(RuneData.GetRuneTableData(_ui.data.id).RuneAttribute) do
        index = i
        _ui.attrs[i].name.text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(v.BonusType, v.Attype))
        _ui.attrs[i].value.text = (v.sign and "+" or "-") .. System.String.Format("{0:F}" , v.Value) .. (Global.IsHeroPercentAttrAddition(v.Attype) and "%" or "")
    end
    for i, v in ipairs(_ui.attrs) do
        v.name.gameObject:SetActive(i <= index)
    end
end

function Show(data, callback)
    _ui = {}
    _ui.data = data
    _ui.callback = callback
    Global.OpenUI(_M)
end