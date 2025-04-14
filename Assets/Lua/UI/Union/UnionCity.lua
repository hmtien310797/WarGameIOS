module("UnionCity", package.seeall)
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

----- CONSTANTS --------------------------------------------
local MAX_NUM_GOVERNMENT = 1
local MAX_NUM_FORTRESS = tableData_tUnionNum.data[24].num
local MAX_NUM_STRONGHOLD = tableData_tUnionNum.data[23].num
------------------------------------------------------------

local _ui

local function UpdateSummary()

    local counts = UnionCityData.GetOccupiedBuildingCounts()
    if UnionCityData.GetStrongholdLimit() ~= nil then
        MAX_NUM_STRONGHOLD = UnionCityData.GetStrongholdLimit()
    end

    if UnionCityData.GetFortressLimit() ~= nil then
        MAX_NUM_FORTRESS = UnionCityData.GetFortressLimit();
    end

    _ui.summary.government.text = Format(TextMgr:GetText("un_gov_num"), counts[Common_pb.SceneEntryType_Govt], MAX_NUM_GOVERNMENT)
    _ui.summary.fort.text = Format(TextMgr:GetText("un_fort_num"), counts[Common_pb.SceneEntryType_Fortress], MAX_NUM_FORTRESS)
    _ui.summary.stronghold.text = Format(TextMgr:GetText("un_stronghold_num"), counts[Common_pb.SceneEntryType_Stronghold], MAX_NUM_STRONGHOLD)

    _ui.none:SetActive(counts.all == 0)

    _ui.buildingList.scrollView.enabled = counts.all > 8
    _ui.buildingList.grid.repositionNow = true

    _ui.buildingList.counts = counts
end

local function UpdateCountdown(uiBuilding)
    uiBuilding.countdown.text = Format(TextMgr:GetText("Union_city1"), Global.SecondToTimeLong(uiBuilding.guildCityInfo.canTakeTime - _ui.lastUpdateTime))
end

local function UpdateClaimButton(uiBuilding)
    if _ui.lastUpdateTime == nil then
        _ui.lastUpdateTime = GameTime.GetSecTime()
    end
    if uiBuilding.guildCityInfo ~= nil and uiBuilding.guildCityInfo.canTakeTime > _ui.lastUpdateTime then
        uiBuilding.btn_claim:SetActive(false)
        uiBuilding.requirement.gameObject:SetActive(false)
        uiBuilding.btn_disabled:SetActive(true)
        
        UpdateCountdown(uiBuilding)
    else
        uiBuilding.requirement.gameObject:SetActive(true)
        uiBuilding.btn_claim:SetActive(true)
        uiBuilding.btn_disabled:SetActive(false)
    end
end

local function UpdateBuilding(uiBuilding, guildCityInfo)
    uiBuilding.gameObject:SetActive(true)

    uiBuilding.guildCityInfo = guildCityInfo

    local missionListData = MissionListData.GetData()
    local totalActivePoint = 0
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        local completed = v.value >= missionData.number
        if missionData.type == 2 then
            if not missionData.chest then
                local missionValue = v.value
                local missionMaxValue = missionData.number
                if missionData.DailyCount > 0 then
                    missionValue = math.floor(v.value / (missionData.number / missionData.DailyCount))
                end
                if v.value > 0 then
                    totalActivePoint = totalActivePoint + missionData.activePoint * missionValue
                end
            end
        end
    end


    local sceneEntryType = guildCityInfo.entryType
    local subType = guildCityInfo.subType

    if sceneEntryType == Common_pb.SceneEntryType_Govt then
        local data = TableMgr:GetGlobalData(100218)
        local req =  data and tonumber(data.value) or 0
        uiBuilding.requirement.text =  System.String.Format(TextMgr:GetText("DailyMission_reward"),req)
        uiBuilding.gameObject.name = 1000000 + subType
        uiBuilding.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", TableMgr:GetArtSettingData(600).icon)
        uiBuilding.name.text = TextMgr:GetText("GOV_ui7")

        if totalActivePoint < req then
            uiBuilding.btn_claim_btn.normalSprite = "btn_5"
            uiBuilding.btn_claim_text.text = TextMgr:GetText("mission_go")
            SetClickCallback(uiBuilding.btn_claim, function()
                MissionUI.Show(2)
                UnionInfo.CloseAll()
            end)               
        else
            uiBuilding.btn_claim_btn.normalSprite = "btn_2small"
            uiBuilding.btn_claim_text.text = TextMgr:GetText("mission_reward")
            SetClickCallback(uiBuilding.btn_claim, function()
                local guildCityInfo = uiBuilding.guildCityInfo
                UnionCityData.ClaimRewards(guildCityInfo.entryType, guildCityInfo.subType)
            end)             
        end

        SetClickCallback(uiBuilding.icon.gameObject, function()
            MainCityUI.ShowWorldMap(176, 176, true, nil)
            UnionInfo.CloseAll()
        end)
    elseif sceneEntryType == Common_pb.SceneEntryType_Fortress then
        local data = TableMgr:GetGlobalData(100217)
        local req =  data and tonumber(data.value) or 0
        uiBuilding.requirement.text =  System.String.Format(TextMgr:GetText("DailyMission_reward"),req)
        local fortressData = TableMgr:GetFortressRuleByID(guildCityInfo.subType)

        uiBuilding.gameObject.name = 2000000 + subType
        uiBuilding.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", TableMgr:GetArtSettingData(500).icon)
        uiBuilding.name.text = TextMgr:GetText(fortressData.name)


        if totalActivePoint < req then
            uiBuilding.btn_claim_btn.normalSprite = "btn_5"
            uiBuilding.btn_claim_text.text = TextMgr:GetText("mission_go")
            SetClickCallback(uiBuilding.btn_claim, function()
                MissionUI.Show(2)
                UnionInfo.CloseAll()
            end)               
        else
            uiBuilding.btn_claim_btn.normalSprite = "btn_2small"
            uiBuilding.btn_claim_text.text = TextMgr:GetText("mission_reward")
            SetClickCallback(uiBuilding.btn_claim, function()
                local guildCityInfo = uiBuilding.guildCityInfo
                UnionCityData.ClaimRewards(guildCityInfo.entryType, guildCityInfo.subType)
            end)             
        end


        SetClickCallback(uiBuilding.icon.gameObject, function()
            MainCityUI.ShowWorldMap(fortressData.Xcoord, fortressData.Ycoord, true, nil)
            UnionInfo.CloseAll()
        end)
    elseif sceneEntryType == Common_pb.SceneEntryType_Stronghold then
        local data = TableMgr:GetGlobalData(100216)
        local req =  data and tonumber(data.value) or 0
        uiBuilding.requirement.text =  System.String.Format(TextMgr:GetText("DailyMission_reward"),req)
        local strongHoldData = TableMgr:GetStrongholdRuleByID(subType)

        uiBuilding.gameObject.name = 3000000 + strongHoldData.order * 1000 + subType
        uiBuilding.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", TableMgr:GetArtSettingData(502).icon)
        uiBuilding.name.text = TextMgr:GetText(strongHoldData.name)


        if totalActivePoint < req then
            uiBuilding.btn_claim_btn.normalSprite = "btn_5"
            uiBuilding.btn_claim_text.text = TextMgr:GetText("mission_go")
            SetClickCallback(uiBuilding.btn_claim, function()
                MissionUI.Show(2)
                UnionInfo.CloseAll()
            end)               
        else
            uiBuilding.btn_claim_btn.normalSprite = "btn_2small"
            uiBuilding.btn_claim_text.text = TextMgr:GetText("mission_reward")
            SetClickCallback(uiBuilding.btn_claim, function()
                local guildCityInfo = uiBuilding.guildCityInfo
                UnionCityData.ClaimRewards(guildCityInfo.entryType, guildCityInfo.subType)
            end)             
        end



        SetClickCallback(uiBuilding.icon.gameObject, function()
            MainCityUI.ShowWorldMap(strongHoldData.Xcoord, strongHoldData.Ycoord, true, nil)
            UnionInfo.CloseAll()
        end)

       
    end

    UpdateClaimButton(uiBuilding)

    if not _ui.buildingList.buildingsByType[sceneEntryType] then
        _ui.buildingList.buildingsByType[sceneEntryType] = {}
    end

    _ui.buildingList.buildingsByType[sceneEntryType][subType] = uiBuilding
end

local function AddBuilding(guildCityInfo)
    local reusableUIs = _ui.buildingList.reusableUIs

    local uiBuilding
    if reusableUIs:IsEmpty() then
        uiBuilding = {}

        uiBuilding.gameObject = NGUITools.AddChild(_ui.buildingList.gameObject, _ui.buildingList.newBuilding)
        uiBuilding.transform = uiBuilding.gameObject.transform
        uiBuilding.icon = uiBuilding.transform:Find("icon"):GetComponent("UITexture")
        uiBuilding.name = uiBuilding.transform:Find("name"):GetComponent("UILabel")
        uiBuilding.btn_claim = uiBuilding.transform:Find("btn_claim").gameObject
        uiBuilding.btn_claim_btn = uiBuilding.btn_claim:GetComponent("UIButton")
        uiBuilding.btn_claim_text = uiBuilding.transform:Find("btn_claim/label"):GetComponent("UILabel")
        uiBuilding.btn_disabled = uiBuilding.transform:Find("btn_disabled").gameObject
        uiBuilding.countdown = uiBuilding.transform:Find("btn_disabled/time"):GetComponent("UILabel")
        uiBuilding.requirement = uiBuilding.transform:Find("requirement"):GetComponent("UILabel")

        SetClickCallback(uiBuilding.btn_disabled, function()
            FloatText.ShowOn(uiBuilding.btn_disabled, TextMgr:GetText("ui_activity_des6"), Color.red)
        end)
    else
        uiBuilding = reusableUIs:Pop()
    end

    UpdateBuilding(uiBuilding, guildCityInfo)
end

local function RemoveBuilding(sceneEntryType, subType)
    local uiBuilding = _ui.buildingList.buildingsByType[sceneEntryType][subType]

    uiBuilding.gameObject:SetActive(false)
    uiBuilding.guildCityInfo = nil

    _ui.buildingList.buildingsByType[sceneEntryType][subType] = nil

    _ui.buildingList.reusableUIs:Push(uiBuilding)
end

local function Redraw()
    local reusableUIs = _ui.buildingList.reusableUIs

    for _, uiBuilding in ipairs(_ui.buildingList.buildings) do
        uiBuilding.gameObject:SetActive(false)
        uiBuilding.guildCityInfo = nil

        reusableUIs:Push(uiBuilding)
    end

    _ui.buildingList.buildingsByType = {}

    for sceneEntryType, guildCityInfos in pairs(UnionCityData.GetOccupiedBuildings()) do
        for _, guildCityInfo in pairs(guildCityInfos) do
            AddBuilding(guildCityInfo)
        end
    end

    UpdateSummary()
end

function Show()
    Global.OpenUI(_M)
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Awake()
    _ui = {}
    _ui.lastUpdateTime = GameTime.GetSecTime()
    _ui.summary = {}
    _ui.summary.transform = transform:Find("Container/bg2/info widget")
    _ui.summary.gameObject = _ui.summary.transform.gameObject
    _ui.summary.government = _ui.summary.transform:Find("gov"):GetComponent("UILabel")
    _ui.summary.fort = _ui.summary.transform:Find("fort"):GetComponent("UILabel")
    _ui.summary.stronghold = _ui.summary.transform:Find("stronghold"):GetComponent("UILabel")

    _ui.buildingList = UIUtil.LoadList(transform:Find("Container/bg2/BuildingList"))
    _ui.buildingList.newBuilding = ResourceLibrary.GetUIPrefab("union/Union_city")
    _ui.buildingList.buildings = {}
    _ui.buildingList.reusableUIs = DataStack()

    _ui.none = transform:Find("Container/bg2/no one").gameObject

    SetClickCallback(transform:Find("Container/bg2/btn").gameObject, City_lord.Show)
    SetClickCallback(transform:Find("Container/background widget/close btn").gameObject, CloseAll)
    SetClickCallback(transform:Find("mask").gameObject, CloseAll)

    EventDispatcher.Bind(UnionCityData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(guildCityInfo, change)
        if change == 0 then
            UpdateClaimButton(_ui.buildingList.buildingsByType[guildCityInfo.entryType][guildCityInfo.subType])
        elseif change > 0 then
            AddBuilding(guildCityInfo)
            UpdateSummary()
        else
            RemoveBuilding(guildCityInfo.entryType, guildCityInfo.subType)
            UpdateSummary()
        end
    end)

    EventDispatcher.Bind(UnionCityData.OnRewardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(guildCityInfo, hasUnclaimedReward)
        if _ui.buildingList == nil then
            return
        end
        local uiBuilding = _ui.buildingList.buildingsByType[guildCityInfo.entryType][guildCityInfo.subType]

        if uiBuilding then
            UpdateClaimButton(uiBuilding, guildCityInfo.canTakeTime)
        end
    end)

    UnionCityData.RequestData()
end

function Start()
    
    
    Redraw()
end

function Close()
    EventDispatcher.UnbindAll(_M)

    _ui = nil
end

function Update()
    local now = GameTime.GetSecTime()
    if now ~= _ui.lastUpdateTime then
        _ui.lastUpdateTime = now
        
        local buildingsByType = _ui.buildingList.buildingsByType
        for _, guildCityInfo in pairs(UnionCityData.GetRewardlessBuildings()) do
            UpdateCountdown(buildingsByType[guildCityInfo.entryType][guildCityInfo.subType])
        end
    end
end
