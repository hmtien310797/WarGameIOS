module("ActivityRace", package.seeall)

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
local timer = 0

local tableDataList
local dataIndexList

local AscSortFunc1 = function(v1, v2)
    local week1 = tonumber(string.split(v1.week, ";")[1])
    local week2 = tonumber(string.split(v2.week, ";")[1])
    if week1 == week2 then
        if v1.prepare == v2.prepare then
            return v1.completeType < v2.completeType
        else
            return v1.prepare < v2.prepare
        end
    else
        return week1 < week2
    end
end

local AscSortFunc2 = function(v1, v2)
    local week1 = tonumber(string.split(v1.week, ";")[1])
    local week2 = tonumber(string.split(v2.week, ";")[1])
    if week1 == week2 then
        if v1.prepare == v2.prepare then
            return v1.completeType > v2.completeType
        else
            return v1.prepare < v2.prepare
        end
    else
        return week1 < week2
    end
end

local function LoadTableData()
    if tableDataList == nil then
        tableDataList = {{}, {}}
        dataIndexList = {{}, {}}
        for _, v in pairs(tableData_tStatisticsList.data) do
            table.insert(tableDataList[v.completeType], v)
        end

        for _, v in ipairs(tableDataList) do
            table.sort(v, AscSortFunc2)
        end

        for i, v in ipairs(tableDataList) do
            for ii, vv in ipairs(v) do
                dataIndexList[i][vv.id] = ii
            end
        end
    end
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function UpdateTime()
    local serverTime = Serclimax.GameTime.GetSecTime()
    for i = 1, 6 do
        local race = _ui.raceList[i]
        if i <= 2 then
            if race.startTime > serverTime then
                race.timeLabel.text = Global.GetLeftCooldownTextLong(race.startTime)
                race.stateLabel.text = TextMgr:GetText(Text.ActivityAll_25)
            else
                race.timeLabel.text = Global.GetLeftCooldownTextLong(race.endTime)
                race.stateLabel.text = TextMgr:GetText(Text.union_train6)
            end
        else
            race.timeLabel.text = Global.GetLeftCooldownTextLong(race.startTime)
        end
    end
end

local function LoadRaceObject(race, raceTransform)
    race.bgTexture = raceTransform:Find("base"):GetComponent("UITexture")
    race.titleLabel = raceTransform:Find("title"):GetComponent("UILabel")
    race.nameLabel = raceTransform:Find("activity"):GetComponent("UILabel")
    race.stateLabel = raceTransform:Find("state"):GetComponent("UILabel")
    race.timeLabel = raceTransform:Find("time"):GetComponent("UILabel")
    race.noUnionObject = raceTransform:Find("union").gameObject
    race.noticeObject = raceTransform:Find("red").gameObject
    race.outlineSprite = raceTransform:Find("kuang"):GetComponent("UISprite")
    race.decorateSprite1 = raceTransform:Find("top_left"):GetComponent("UISprite")
    race.decorateSprite2 = raceTransform:Find("top_left/top_right"):GetComponent("UISprite")
end

local function LoadRace(race, raceMsg, raceData, raceIndex)
    race.msg = raceMsg
    race.data = raceData
    race.titleLabel.text = TextMgr:GetText(raceData.completeType == 1 and Text.Armrace_1 or Text.Armrace_2)
    race.nameLabel.text = TextMgr:GetText(raceData.name)
    race.bgTexture.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", raceData.background)
    if raceIndex ~= 7 then
        if raceData.completeType == 1 then
            race.outlineSprite.spriteName = "race_shine1"
            race.decorateSprite1.spriteName = "race_red"
            race.decorateSprite2.spriteName = "race_red"
        else
            race.outlineSprite.spriteName = "race_shine2"
            race.decorateSprite1.spriteName = "race_yellow"
            race.decorateSprite2.spriteName = "race_yellow"
        end
    end
end

function LoadUI()
    LoadTableData()
    local hasUnion = UnionInfoData.HasUnion()
    local currentListMsg = RaceData.GetData().currentActId
    table.sort(currentListMsg, function(v1, v2)
        return tableData_tStatisticsList.data[v1].completeType < tableData_tStatisticsList.data[v2].completeType
    end)
    dataList = {}

    local lastDataList = {}
    for i, v in ipairs(currentListMsg) do
        for j = 1, 5 do
            local dataIndex = dataIndexList[i][v] + j
            if dataIndex > #tableDataList[i] then
                dataIndex = dataIndex % #tableDataList[i]
            end
            table.insert(dataList, tableDataList[i][dataIndex])
            if i == 2 then
                break
            end
        end
        local dataIndex = dataIndexList[i][v] - 1
        if dataIndex == 0 then
            dataIndex = #tableDataList
        end
        table.insert(lastDataList, tableDataList[i][dataIndex])
    end

    table.sort(dataList, AscSortFunc2)
    table.sort(lastDataList, AscSortFunc1)
    table.insert(dataList, 5, lastDataList[2])

    for i = 2, 1, -1 do
        table.insert(dataList, 1, tableData_tStatisticsList.data[currentListMsg[i]])
    end

    for i = 1, 7 do
        local race = _ui.raceList[i]
        local raceData = dataList[i]
        local raceMsg = RaceData.GetRaceDataByActId(raceData.id)
        LoadRace(race, raceMsg, raceData, i)
        race.week = tonumber(string.split(raceData.week, ";")[1])
        if i == 1 then
            race.startTime = raceMsg.startTime
        else
            local race1 = _ui.raceList[1]
            local diffWeek = race.week - race1.week
            if diffWeek < 0 then
                diffWeek = race.week + 7 - race1.week
            end
            race.startTime = race1.startTime + diffWeek * 86400 + (raceData.begin - race1.data.begin) * 60
        end
        race.endTime = race.startTime + (raceData._end - raceData.begin) * 60
        local completeType = raceData.completeType
        race.noUnionObject.gameObject:SetActive(completeType == 2 and not hasUnion)
        race.noticeObject:SetActive(i <= 2 and RaceData.HasNoticeByType(i))
        _ui.raceList[i] = race
        if i > 2 then
            race.stateLabel.text = TextMgr:GetText(i == 7 and Text.ui_zone13 or Text.Armrace_5)
        end
        race.timeLabel.gameObject:SetActive(i ~= 7)
        SetClickCallback(race.bgTexture.gameObject, function(go)
            if completeType == 2 and not hasUnion then
                JoinUnion.Show()
            else
                ArmRaceInfo.Show(i, race)
            end
        end)
    end
    UpdateTime()
end

function Awake()
    local closeButton = transform:Find("Container/background/close btn")
    closeButton.gameObject:SetActive(true)
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, function()
        CloseAll()
        ActivityAll.Hide()
    end)
    _ui = {}
    _ui.listTransform = transform:Find("Container/Scroll View/Grid")
    _ui.listGrid = _ui.listTransform:GetComponent("UIGrid")
    _ui.racePrefab = _ui.listTransform:GetChild(0).gameObject
    _ui.raceList = {}
    for i = 1, 7 do
        local raceTransform = _ui.listTransform:GetChild(i - 1)
        local race = {}
        LoadRaceObject(race, raceTransform)
        _ui.raceList[i] = race
    end
    RaceData.AddListener(LoadUI)
    UnionInfoData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function LateUpdate()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end

function Start()
    RaceData.NotifyUIOpened()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    RaceData.RemoveListener(LoadUI)
    UnionInfoData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show()
    RaceData.RequestData(false)
    Global.OpenUI(_M)
    LoadUI()
end
