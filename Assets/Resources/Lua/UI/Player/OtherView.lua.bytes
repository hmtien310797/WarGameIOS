module("OtherView", package.seeall)

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

local viewDataList
function GetViewDataList()
    if viewDataList == nil then
        viewDataList = {}
        for _, v in pairs(tableData_tBuildingReview.data) do
            table.insert(viewDataList, v)
        end

        table.sort(viewDataList, function(v1, v2)
            return v1.id < v2.id
        end)
    end

    return viewDataList
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    NGUITools.DestroyChildren(_ui.listGrid.transform)
    local viewMsg = _ui.viewMsg
    local dataList = GetViewDataList()
    local bodyIndex = 0
	for i, v in ipairs(dataList) do
        local otherInfo = v.otherInfo
        if otherInfo ~= "" then
            if otherInfo == "Title" then
                local titleTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.titlePrefab).transform
                titleTransform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(v.revtext)
                bodyIndex = 0
            else
                local bodyTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.bodyPrefab).transform
                bodyTransform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(v.revtext)
                local otherValue = viewMsg[otherInfo] or 0
                bodyTransform:Find("number"):GetComponent("UILabel").text = BuildReview.formatValue(v.valueShow, otherValue)
                bodyTransform:Find("bg_list").gameObject:SetActive(bodyIndex % 2 ~= 0)
                bodyIndex = bodyIndex  + 1
            end
        end
	end
end

function Awake()
    local closeButton = transform:Find("Container/review_frane/review_top/btn_close")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    _ui.titlePrefab = transform:Find("heading_list").gameObject
    _ui.bodyPrefab = transform:Find("message_list").gameObject
    _ui.listGrid = transform:Find("Container/review_frane/Scroll View/Grid"):GetComponent("UIGrid")
end

function Close()
    _ui = nil
end

function Show(viewMsg)
    Global.OpenUI(_M)
    _ui.viewMsg = viewMsg
    LoadUI()
end
