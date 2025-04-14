module("AppointSuccess", package.seeall)

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

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    for i, v in ipairs(_ui.changeAttrList) do
        local attrItemTransform = nil
        if i > _ui.listTable.transform.childCount then
            attrItemTransform = NGUITools.AddChild(_ui.listTable.gameObject, _ui.attrPrefab).transform
        else
            attrItemTransform = _ui.listTable.transform:GetChild(i - 1)
        end
        
        local nameLabel = attrItemTransform:Find("title"):GetComponent("UILabel")
        nameLabel.text = TextMgr:GetText(v.data.name)
        for j = 1, 3 do
            local attrTransform = attrItemTransform:Find("property" .. j)
            
            local attrType = v.typeList[j]
            if attrType == nil then
                attrTransform.gameObject:SetActive(false)
            else
                attrTransform:GetComponent("UILabel").text = attrType.text
                local oldValue = v.oldValueList[j]
                local newValue = v.newValueList[j]
                attrTransform:Find("num  before"):GetComponent("UILabel").text = Global.GetHeroAttrValueString(attrType.type, oldValue)
                local newValueLabel = attrTransform:Find("num after"):GetComponent("UILabel")
                newValueLabel.text = Global.GetHeroAttrValueString(attrType.type, newValue)
                if newValue == oldValue then
                    newValueLabel.color = NGUIMath.HexToColor(0xFFFFFFFFF)
                elseif math.abs(newValue) > math.abs(oldValue) then
                    newValueLabel.color = NGUIMath.HexToColor(0x00FF1EFF)
                else
                    newValueLabel.color = NGUIMath.HexToColor(0xFF0000FF)
                end
                attrTransform:Find("num after/down").gameObject:SetActive(math.abs(newValue) < math.abs(oldValue))
                attrTransform:Find("num after/up").gameObject:SetActive(math.abs(newValue) > math.abs(oldValue))
            end
        end
    end
end

function Awake()
    local confirmButton = transform:Find("btn"):GetComponent("UIButton")
    local mask = transform:Find("mask")
    SetClickCallback(confirmButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    _ui.listTable = transform:Find("Scroll View/Table"):GetComponent("UITable")
    _ui.attrPrefab = transform:Find("Scroll View/Table/property").gameObject
end

function Close()
    _ui = nil
end

function Show(changeAttrList)
    Global.OpenUI(_M)
    _ui.changeAttrList = changeAttrList
    LoadUI()
end
