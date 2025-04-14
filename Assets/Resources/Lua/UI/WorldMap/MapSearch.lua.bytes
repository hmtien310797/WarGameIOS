module("MapSearch", package.seeall)
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
local PlayerPrefs = UnityEngine.PlayerPrefs

local _ui
local entryTypeIndex

local function SetEntryTypeIndex(typeIndex)
    entryTypeIndex = typeIndex
end

local entryTypeList =
{
    Common_pb.SceneEntryType_Monster,
    Common_pb.SceneEntryType_EliteMonster,
   	Common_pb.SceneEntryType_ResFood,
	Common_pb.SceneEntryType_ResIron,
	Common_pb.SceneEntryType_ResOil,
	Common_pb.SceneEntryType_ResElec,
}

levelList =
{
    1,
    1,
    1,
    1,
    1,
    1,
}

local function SetLevel(levelIndex, level)
    levelList[levelIndex] = level
end

local maxLevelList =
{
    30,
    5,
    6,
    6,
    6,
    6,
}

local searchCallback

function Hide()
    Global.CloseUI(_M)
    MainCityUI.LoginAwardGo()
end

local function LoadLevelUI(setSlider)
    local currentLevel = levelList[entryTypeIndex]
    local maxLevel = maxLevelList[entryTypeIndex]
    _ui.levelLabel1.text = Format(TextMgr:GetText(Text.hero_skill_lv), currentLevel)
    _ui.levelLabel2.text = currentLevel .. "/" .. maxLevel
    if setSlider then
        _ui.slider.numberOfSteps = maxLevel
        _ui.slider.value = (currentLevel - 1) / (maxLevel - 1)
    end
end

function LoadUI()
    _ui.entryList[1].maxLevelLabel.text = Format(TextMgr:GetText(Text.search_enemy_MAX), RebelWantedData.GetUnlockedLevel())
    local baseLevel = BuildingData.GetCommandCenterData().level
    _ui.entryList[2].maxLevelLabel.text = Format(TextMgr:GetText(Text.search_enemy_MAX), TableMgr:GetMaxEliteMonsterLevelByBaseLevel(baseLevel))
    LoadLevelUI(true)
end

local function CancelShare()
    Hide()
end

function TweenClose()
    UITweener.PlayAllTweener(_ui.containerObject, false, false, false)
    if _ui ~= nil then
        _ui.containerObject:GetComponent("UITweener"):SetOnFinished(EventDelegate.Callback(Hide))
    end
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/close btn")
    UIUtil.SetClickCallback(mask.gameObject, TweenClose)
    UIUtil.SetClickCallback(closeButton.gameObject, TweenClose)
    _ui.containerObject = transform:Find("Container").gameObject
    _ui.searchButton = transform:Find("Container/search btn"):GetComponent("UIButton")
    _ui.slider = transform:Find("Container/bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
    _ui.levelLabel1 = transform:Find("Container/bg_train_time/bg_schedule/bg_btn_slider/Label"):GetComponent("UILabel")
    _ui.levelLabel2 = transform:Find("Container/bg_train_time/num bg/text_num"):GetComponent("UILabel")
    _ui.entryList = {}
    _ui.minusButton = transform:Find("Container/bg_train_time/btn_minus"):GetComponent("UIButton")
    _ui.addButton = transform:Find("Container/bg_train_time/btn_add"):GetComponent("UIButton")
    SetClickCallback(_ui.minusButton.gameObject, function(go)
        local currentLevel = levelList[entryTypeIndex]
        if currentLevel > 1 then
            SetLevel(entryTypeIndex, currentLevel - 1)
            LoadLevelUI(true)
        end
    end)
    SetClickCallback(_ui.addButton.gameObject, function(go)
        local currentLevel = levelList[entryTypeIndex]
        local maxLevel = maxLevelList[entryTypeIndex]
        if currentLevel < maxLevel then
            SetLevel(entryTypeIndex, currentLevel + 1)
            LoadLevelUI(true)
        end
    end)
    for i = 1, 6 do
        local entryTransform = transform:Find("Container/item widget/item bg" .. i)
        local entry = {}
        entry.transform = transform
        entry.toggle = entryTransform:GetComponent("UIToggle")
        entry.entryType = entryTypeList[i]
        entry.maxLevelLabel = entryTransform:Find("select/lv text"):GetComponent("UILabel")
        _ui.entryList[i] = entry
        EventDelegate.Set(entry.toggle.onChange, EventDelegate.Callback(function()
            if entry.toggle.value then
                SetEntryTypeIndex(i)
                LoadLevelUI(true)
            end
        end))
    end
    SetClickCallback(_ui.searchButton.gameObject, function(go)
        local req = MapMsg_pb.SearchMapEntryRequest()
        req.entryType = entryTypeList[entryTypeIndex]
        req.level = levelList[entryTypeIndex]
        Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SearchMapEntryRequest, req, MapMsg_pb.SearchMapEntryResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                local pos = msg.entrypos

                if searchCallback then
                    searchCallback()
                end

                TweenClose()
                MainCityUI.ShowWorldMap(pos.x, pos.y, true, nil)
            else
                Global.ShowError(msg.code)
            end
        end)
    end)
    for i, v in ipairs(_ui.entryList) do
        v.toggle.value = entryTypeIndex == i
    end
    EventDelegate.Set(_ui.slider.onChange, EventDelegate.Callback(function(go)
        local maxLevel = maxLevelList[entryTypeIndex]
        local currentLevel = Mathf.Round((maxLevel - 1) * _ui.slider.value) + 1
        SetLevel(entryTypeIndex, currentLevel)
        LoadLevelUI(false)
    end))
end

function Close()
    _ui = nil
    searchCallback = nil
end

function Show(typeIndex, entryLevel, _searchCallback)
    if typeIndex ~= nil then
        SetEntryTypeIndex(typeIndex)
    end

    if entryLevel ~= nil then
        SetLevel(entryTypeIndex, entryLevel)
    end

    if entryTypeIndex == nil then
        entryTypeIndex = 1
        levelList[1] = math.max(RebelWantedData.GetUnlockedLevel() - 1, 1)
    end

    searchCallback = _searchCallback

    Global.OpenUI(_M)
    LoadUI()
end
