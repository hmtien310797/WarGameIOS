module("Sellitem", package.seeall)
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

function Awake()
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.texture = transform:Find("Container/bg_frane/Texture"):GetComponent("UITexture")
    _ui.name = transform:Find("Container/bg_frane/Texture/txt_name"):GetComponent("UILabel")
    _ui.grid = transform:Find("Container/bg_frane/Texture/Grid"):GetComponent("UIGrid")
    _ui.attrcontent = transform:Find("Container/bg_frane/Texture/text")

    _ui.input = transform:Find("Container/bg_frane/bg_bottom/frame_input").gameObject
    _ui.inputnum = transform:Find("Container/bg_frane/bg_bottom/frame_input/title"):GetComponent("UILabel")
    _ui.inputmax = transform:Find("Container/bg_frane/bg_bottom/frame_input/text_num"):GetComponent("UILabel")
    _ui.slider = transform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/bg_schedule/bg_slider"):GetComponent("UISlider")
    _ui.btn_add = transform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_add").gameObject
    _ui.btn_minus = transform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_minus").gameObject
    _ui.totalnum = transform:Find("Container/bg_frane/total/number"):GetComponent("UILabel")

    _ui.btn_use = transform:Find("Container/bg_frane/btn_use").gameObject
end

local function OnValueChange()
    if _ui ~= nil then
		_ui.curNum = Mathf.Floor(_ui.slider.value * _ui.maxNum + 0.5)
		_ui.curNum = math.min(_ui.curNum, _ui.maxNum)
        _ui.inputnum.text = _ui.curNum
        local total = _ui.runeData.NeedMaterial.num * _ui.curNum
        _ui.totalnum.text = total <= MoneyListData.GetRuneChip() and total or ("[ff0000]" .. total .. "[-]")   
    end
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    _ui.maxNum = 10
    _ui.curNum = 1
    _ui.inputmax.text = "/10"
    _ui.texture.mainTexture = ResourceLibrary:GetIcon("item/" , _ui.itemData.icon)
    _ui.name.text =TextMgr:GetText(_ui.itemData.name)
    RuneData.SetAttributeList(_ui.itemData.id, _ui.grid, _ui.attrcontent)

    EventDelegate.Set(_ui.slider.onChange,EventDelegate.Callback(function(obj,delta)
		OnValueChange()
	end))
    SetClickCallback(_ui.input, function()
        NumberInput.Show(_ui.curNum, 0, _ui.maxNum, function(number)
            _ui.curNum = number
            _ui.slider.value = _ui.curNum/_ui.maxNum
            _ui.inputnum.text = _ui.curNum
        end)
    end)
    SetClickCallback(_ui.btn_add, function()
        _ui.curNum = _ui.curNum + 1
        _ui.curNum = math.min(_ui.curNum, _ui.maxNum)
        _ui.slider.value = _ui.curNum/_ui.maxNum
        _ui.inputnum.text = _ui.curNum
    end)
    SetClickCallback(_ui.btn_minus, function()
        _ui.curNum = _ui.curNum - 1
        _ui.curNum = math.max(_ui.curNum, 0)
        _ui.slider.value = _ui.curNum/_ui.maxNum
        _ui.inputnum.text = _ui.curNum
    end)
    SetClickCallback(_ui.btn_use, function()
        Isdark()
        RuneData.RequestComposeRune(_ui.itemData.id, _ui.curNum, OnValueChange)
    end)
    _ui.slider.value = 0.1
end

function Show(id)
    _ui = {}
    _ui.itemData = TableMgr:GetItemData(id)
    _ui.runeData = RuneData.GetRuneTableData(id)
    Global.OpenUI(_M)
end

function Close()
    _ui = nil
end

function Isdark()
    local total = _ui.runeData.NeedMaterial.num * _ui.curNum
    if MoneyListData.GetRuneChip() < total then
        FloatText.ShowAt(_ui.btn_use.transform.position, TextMgr:GetText("ui_rune_41"), Color.red)
    else 
    return end
end

