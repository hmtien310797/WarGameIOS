module("UnionLanguage", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local languageId
local isChange
local showAll
local callback

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function GetLanguageText(languageId)
    if languageId == -1 then
        return TextMgr:GetText(Text.all_language)
    end

    return TextMgr:GetText(TableMgr:GetUnionLanguageData(languageId).language)
end

function LoadUI()
    local languageIndex = 1
    if showAll then
        local languageTransform = _ui.grid:GetChild(languageIndex - 1)
        if languageTransform == nil then
            languageTransform = NGUITools.AddChild(_ui.grid.gameObject, _ui.languagePrefab).transform
        end

        local languageLabel = languageTransform:Find("text"):GetComponent("UILabel")
        languageLabel.text = TextMgr:GetText(Text.all_language)
        local checkToggole = languageTransform:Find("Sprite"):GetComponent("UIToggle")
        checkToggole.value = languageId == -1
        EventDelegate.Add(checkToggole.onChange, EventDelegate.Callback(function()
            if checkToggole.value then
                languageId = -1
            end
        end))
        languageIndex = languageIndex + 1
    end

    local languageDataList = TableMgr:GetUnionLanguageList()
	for i, v in pairs(languageDataList) do
		local languageData = languageDataList[i]
        local languageTransform = _ui.grid:GetChild(languageIndex - 1)
        if languageTransform == nil then
            languageTransform = NGUITools.AddChild(_ui.grid.gameObject, _ui.languagePrefab).transform
        end
        local languageLabel = languageTransform:Find("text"):GetComponent("UILabel")
        local languageTexture = languageTransform:Find("Texture"):GetComponent("UITexture")
        local bgObject = languageTransform:Find("bg").gameObject
        languageLabel.text = TextMgr:GetText(languageData.language)
        languageTexture.mainTexture = ResourceLibrary:GetIcon("Icon/setting/", languageData.icon)
        bgObject:SetActive(languageIndex % 2 ~= 0)
        local checkToggole = languageTransform:Find("Sprite"):GetComponent("UIToggle")
        checkToggole.value = languageId == languageData.id
        EventDelegate.Add(checkToggole.onChange, EventDelegate.Callback(function()
            if checkToggole.value then
                languageId = languageData.id
            end
        end))
        languageIndex = languageIndex + 1
	end
    _ui.grid:Reposition()
end

function Awake()
    _ui = {}
    if _ui.languagePrefab == nil then
        _ui.languagePrefab = ResourceLibrary.GetUIPrefab("Union/listitem_language")
    end
    local closeButton = transform:Find("Container/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(mask.gameObject, Hide)
    _ui.grid = transform:Find("bg2/Scroll View/Grid"):GetComponent("UIGrid")
    local okButton = transform:Find("btn ok"):GetComponent("UIButton")
    SetClickCallback(okButton.gameObject, function()
        callback(languageId)
        Hide()
    end)
end

function Close()
    _ui = nil
end

function Show(id, all, cb)
    languageId = id
    showAll = all
    callback = cb
    Global.OpenUI(_M)
    LoadUI()
end
