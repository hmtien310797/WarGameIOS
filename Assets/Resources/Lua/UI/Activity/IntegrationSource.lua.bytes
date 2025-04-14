module("IntegrationSource", package.seeall)

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
    local ruleGrid = _ui.ruleGrid
    local ruleIndex = 1
    for v in string.gsplit(_ui.raceData.rules, ";") do
        local ruleDataId = tonumber(v)
        if ruleDataId ~= nil then
            local ruleData = tableData_tStatisticsRule.data[ruleDataId] 
            local ruleTransform = ruleGrid:GetChild(ruleIndex - 1)
            if ruleTransform ~= nil then
                ruleTransform.gameObject:SetActive(true)
                ruleTransform:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(ruleData.text)
                local pointLabel = ruleTransform:Find("points"):GetComponent("UILabel")
                local point = ruleData.point
                if point > 0 then
                    pointLabel.text = System.String.Format(TextMgr:GetText("Armrace_14") , point)
                    pointLabel.gameObject:SetActive(true)
                else
                    pointLabel.gameObject:SetActive(false)
                end
            end
            ruleIndex = ruleIndex + 1
        end
    end

    for i = ruleIndex, ruleGrid.transform.childCount do
        ruleGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
end

function Awake()
    --local closeButton = transform:Find("bg_top/btn_close")
    local mask = transform:Find("mask")
    --SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    
    _ui = {}
    _ui.ruleGrid = transform:Find("bg_frane/bg1/base/Grid"):GetComponent("UIGrid")
end

function Close()
    _ui = nil
end

function Show(raceData)
    Global.OpenUI(_M)
    _ui.raceData = raceData
    LoadUI()
end
