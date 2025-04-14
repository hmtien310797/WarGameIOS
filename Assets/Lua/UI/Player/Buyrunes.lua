module("Buyrunes", package.seeall)
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
    _ui.btn_close = transform:Find("bg_frane/bg_top/btn_close").gameObject
    _ui.texture = transform:Find("bg_frane/Texture"):GetComponent("UITexture")
    _ui.name = transform:Find("bg_frane/Texture/name"):GetComponent("UILabel")
    _ui.num = transform:Find("bg_frane/Texture/number"):GetComponent("UILabel")
    _ui.grid = transform:Find("bg_frane/info/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.g_item = transform:Find("bg_frane/info/text2")
    _ui.fenjieeffect = transform:Find("bg_frane/Texture/fenjie").gameObject

    _ui.btn1 = transform:Find("bg_frane/button1").gameObject
    _ui.btn1_num = transform:Find("bg_frane/button1/gold/Label (1)"):GetComponent("UILabel")

    _ui.btn2 = transform:Find("bg_frane/2buttons").gameObject
    _ui.btn2_1 = transform:Find("bg_frane/2buttons/button1").gameObject
    _ui.btn2_1_num = transform:Find("bg_frane/2buttons/button1/gold/Label (1)"):GetComponent("UILabel")
    _ui.btn2_2 = transform:Find("bg_frane/2buttons/button2").gameObject
    _ui.btn2_2_num = transform:Find("bg_frane/2buttons/button2/gold/Label (1)"):GetComponent("UILabel")
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    RuneData.SetAttributeList(_ui.id, _ui.grid, _ui.g_item)
    _ui.btn1_num.text = _ui.runeData.NeedMaterial.num
    _ui.btn2_1_num.text = _ui.runeData.NeedMaterial.num
    _ui.btn2_2_num.text = _ui.runeData.Recycling.num
    SetClickCallback(_ui.btn1, function()
        Sellitem.Show(_ui.id)
    end)
    SetClickCallback(_ui.btn2_1, function()
        Sellitem.Show(_ui.id)
    end)
    SetClickCallback(_ui.btn2_2, function()
        if _ui.runenum > 0 then
            if _ui.runeData.Level <= 3 then
                RuneData.RequestDecomposeRune(table.remove(_ui.tabRunes.uidlist[_ui.id]))
            else
                MessageBox.Show(TextMgr:GetText("ui_rune_33"), function()
                    RuneData.RequestDecomposeRune(table.remove(_ui.tabRunes.uidlist[_ui.id]))
                end, function() end)
            end
        else
            MessageBox.Show(TextMgr:GetText("ui_rune_34"))
        end
    end)
    _ui.texture.mainTexture = ResourceLibrary:GetIcon("item/" , _ui.itemData.icon)
    _ui.name.text = TextMgr:GetText(_ui.itemData.name)
    UpdateList()
end

UpdateList = function()
    RuneData.GetUnwearedRunes(0)
    _ui.runenum = RuneData.GetUnwearedRuneCount(_ui.id)
    _ui.num.text = String.Format(TextMgr:GetText("ui_worldmap_70"), _ui.runenum)
    _ui.btn1:SetActive(_ui.runenum == 0)
    _ui.btn2:SetActive(_ui.runenum > 0)
end

function Show(id, tabRunes)
    _ui = {}
    _ui.id = id
    _ui.itemData = TableMgr:GetItemData(id)
    _ui.runeData = RuneData.GetRuneTableData(id)
    _ui.tabRunes = tabRunes
    Global.OpenUI(_M)
end

function SetData(tabRunes)
    if _ui ~= nil then
        _ui.tabRunes = tabRunes
        UpdateList()
    end
end

function Close()
    _ui = nil
end