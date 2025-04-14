module("BatteryTarget_add", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
local reset
local subType
local searchLanguageId

function Hide()
    Global.CloseUI(_M)
end

local function DisposeTurretRulingPush()
    if GovernmentData.CheckTurretInRuling(subType) then
        FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
        Hide()
    end
end

BatteryTarget_addCB = nil

function LoadSearchPageMsg(msg)
    searchListMsg = msg
    LoadSearchPage(true,BatteryTarget_addCB)
end

function LoadSearchPage(reset,customCallBack)
    local unionList = _ui.searchPage.unionList
    _ui.searchPage.languageLabel.text = UnionLanguage.GetLanguageText(searchLanguageId)
    if searchListMsg ~= nil then
        for i, v in ipairs(searchListMsg.guildInfos) do
            local unionMsg = v
            local union = unionList[i]
            union.gameObject:SetActive(true)
            local hasApplied = SelfApplyData.HasApplied(v.guildId)
            UnionList.LoadUnion(union, unionMsg, hasApplied)
            if customCallBack ~= nil then
                customCallBack(union, unionMsg)
            end
        end
    end
    local index = searchListMsg ~= nil and #searchListMsg.guildInfos + 1 or 1
    for i = index, _ui.searchPage.pageSize do
        unionList[i].gameObject:SetActive(false)
    end
    _ui.searchPage.listGrid:Reposition()
    if reset then
        _ui.searchPage.scrollView:ResetPosition()
    end
end


BatteryTarget_addCB = function (union, unionMsg)
    union.joinButton.gameObject:SetActive(false)
    local sanction = GovernmentData.IsSanction(subType,unionMsg.guildId)
	local mainunion = UnionInfoData.GetData()
    local self_guildid = mainunion.guildInfo.guildId	
    
    if self_guildid == unionMsg.guildId then
        union.applyButton.gameObject:SetActive(false)
        union.cancelButton.gameObject:SetActive(false)        
    else
        union.applyButton.gameObject:SetActive(sanction)
        union.cancelButton.gameObject:SetActive(not sanction)
    end

    SetClickCallback(union.applyButton.gameObject, function()
        GovernmentData.ReqTurretSanctionGuild(subType,unionMsg,2,function()
            LoadSearchPage(false,BatteryTarget_addCB)
        end)
    end)
    SetClickCallback(union.cancelButton.gameObject, function()
        GovernmentData.ReqTurretSanctionGuild(subType,unionMsg,1,function()
            LoadSearchPage(false,BatteryTarget_addCB)
        end)
    end)
    SetClickCallback(union.joinButton.gameObject, nil)
end


LoadUI = function()
    UnionList.SetSearchLanguage(searchLanguageId)
    UnionList.RequestSearch(1,LoadSearchPageMsg)
    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end)      
end

function  Awake()
    if searchLanguageId == nil then
        searchLanguageId = -1
    end

    _ui = {}
    _ui.mask = transform:Find("Container")
    _ui.close = transform:Find("Container/bg_frane/bg_top/btn_close")
    
    _ui.searchPage = {}
    _ui.searchPage.nameInput = transform:Find("Container/bg_frane/bg_top/top/search widget/frame_input"):GetComponent("UIInput")
    _ui.searchPage.languageButton = transform:Find("Container/bg_frane/bg_top/top/search widget/frame_input (1)"):GetComponent("UIButton")
    _ui.searchPage.languageLabel = transform:Find("Container/bg_frane/bg_top/top/search widget/frame_input (1)/title"):GetComponent("UILabel")
    _ui.searchPage.searchButton = transform:Find("Container/bg_frane/bg_top/top/search widget/search btn"):GetComponent("UIButton")
    _ui.searchPage.scrollView = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
    _ui.searchPage.scrollView.onDragFinished = UnionList.SearchDragFinished
    local listGridTransform = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid")
    _ui.searchPage.listGrid = listGridTransform:GetComponent("UIGrid")
    _ui.searchPage.nameInput.defaultText = TextMgr:GetText(Text.click_input)
    _ui.searchPage.unionList = {}
    _ui.searchPage.pageSize = listGridTransform.childCount
    _ui.searchPage.clipHeight = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIPanel").baseClipRegion.w
    UnionList.SetExtraUI(_ui)
    for i = 1, _ui.searchPage.pageSize do
        local union = {}
        local unionTransform = listGridTransform:GetChild(i - 1)
        UnionList.LoadUnionObject(union, unionTransform)
        _ui.searchPage.unionList[i] = union
    end
    

    SetClickCallback(_ui.searchPage.languageButton.gameObject, function()
        UnionLanguage.Show(searchLanguageId, true, function(languageId)
            searchLanguageId = languageId
            _ui.searchPage.languageLabel.text = UnionLanguage.GetLanguageText(searchLanguageId)
        end)
    end)
    SetClickCallback(_ui.searchPage.searchButton.gameObject, function()
        UnionList.SetSearchLanguage(searchLanguageId)
        UnionList.RequestSearch(1,LoadSearchPageMsg)
    end)
    GovernmentData.AddTurretRulingListener(DisposeTurretRulingPush)
    LoadUI()
end

function Show(_subType)    
    reset = true
    subType = _subType
    Global.OpenUI(_M)
end

function Close()   
    GovernmentData.RemoveTurretRulingListener(DisposeTurretRulingPush)
    UnionList.SetExtraUI(nil)
    _ui = nil
end