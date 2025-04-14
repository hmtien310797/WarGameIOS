module("Skin_other", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function LoadUI()
    local skinData = tableData_tSkin.data[_ui.skinId]
    local itemData = Skin.GetItemDataList(_ui.skinId)[1]
    if Skin.IsDefaultSkin(_ui.skinId) then
        _ui.skinTexture.mainTexture = Skin.GetDefaultSkinTexture()
    else
        _ui.skinTexture.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
    end
    local attrIndex = 1
    if skinData.SkinAttribute ~= "" then
        for v in string.gsplit(skinData.SkinAttribute, ";") do
            local attrTransform
            if attrIndex > _ui.attrGrid.transform.childCount then
                attrTransform = NGUITools.AddChild(_ui.attrGrid.gameObject, _ui.attrPrefab).transform
            else
                attrTransform = _ui.attrGrid.transform:GetChild(attrIndex - 1)
            end
            local attrList = string.split(v, ",")
            local needData = TableMgr:GetNeedTextDataByAddition(tonumber(attrList[1]), tonumber(attrList[2]))
            attrTransform:GetComponent("UILabel").text = TextMgr:GetText(needData.unlockedText) .. Global.GetHeroAttrValueString(needData.additionAttr, tonumber(attrList[3]))

            attrTransform.gameObject:SetActive(true)
            attrIndex = attrIndex + 1
        end
    end
    for i = attrIndex, _ui.attrGrid.transform.childCount do
        _ui.attrGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.attrGrid.repositionNow = true
    _ui.noneAttrObject:SetActive(attrIndex == 1)
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    _ui.skinTexture = transform:Find("Container/bg_frane/mid/skin_build"):GetComponent("UITexture")
    _ui.attrGrid = transform:Find("Container/bg_frane/mid/left/buff_text/Grid"):GetComponent("UIGrid")
    _ui.attrPrefab = transform:Find("Container/bg_frane/mid/left/buff_text/Grid/textlist_1").gameObject
    _ui.noneAttrObject = transform:Find("Container/bg_frane/mid/left/none").gameObject
end

function Start()
    LoadUI()
end

function Close()
    _ui = nil
end

function Show(skinId)
    Global.OpenUI(_M)
    _ui.skinId = skinId
end
