module("UnionBuilding", package.seeall)
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

local STATE_NONE = 0
local STATE_UNLOCKING = 1
local STATE_UNBUILD = 2
local STATE_BUILDING = 3
local STATE_BUILT = 4

local stateTextList =
{
    [STATE_UNLOCKING] = Text.union_build5,
    [STATE_UNBUILD] = Text.union_build4,
    [STATE_BUILDING] = Text.union_tec33,
    [STATE_BUILT] = Text.union_build3,
}

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function UpdateBuildingTime()
    for i, v in ipairs(_ui.buildingList) do
        if v.state == STATE_UNLOCKING then
            local unionInfoMsg = UnionInfoData.GetData()
            local unionMsg = unionInfoMsg.guildInfo
            local leftSecond = Global.GetLeftCooldownSecond(unionMsg.createTime + v.data.unlockTime)
            if leftSecond > 0 then
                v.timeLabel.text = Global.SecondToTimeLong(leftSecond)
            else
                v.state = STATE_UNBUILD
                v.timeLabel.gameObject:SetActive(false)
                v.stateLabel.text = TextMgr:GetText(stateTextList[v.state])
            end
        elseif v.state == STATE_BUILDING then
            local buildingMsg = v.msg
            if #buildingMsg.armys > 0 then
                local leftSecond = Global.GetLeftCooldownSecond(buildingMsg.completeTime)
                if leftSecond > 0 then
                    v.timeLabel.text = Global.SecondToTimeLong(leftSecond)
                else
                    v.state = STATE_BUILT
                    v.stateLabel.text = TextMgr:GetText(stateTextList[v.state])
                    v.timeLabel.gameObject:SetActive(false)
                end
            end
        end
        if i == _ui.selectedIndex then
            local canCreate = tonumber(UnionInfoData.GetCoin()) >= v.price and v.state ~= STATE_UNLOCKING
            UIUtil.SetBtnEnable(_ui.confirmButton ,"union_button1", "union_button1_un", canCreate)
            UIUtil.SetBtnEnable(_ui.rebuildButton ,"union_button1", "union_button1_un", canCreate)
        end
    end
end

local function ConfirmCallback()
    local building = _ui.buildingList[_ui.selectedIndex]
    local buildingData = building.data
    local buildingType = buildingData.type
    local mapX
    local mapY
    if _ui.mapX ~= nil and _ui.mapY ~= nil then
        mapX = _ui.mapX
        mapY = _ui.mapY
    else
        WorldMap.SetShowBorder(true)
        local basePos = MapInfoData.GetData().mypos
        mapX = basePos.x
        mapY = basePos.y
    end
    if  tonumber(UnionInfoData.GetCoin()) < building.price then
        MessageBox.Show(TextMgr:GetText(Text.union_build7))
        return 
    end

    if building.state == STATE_UNLOCKING then
        FloatText.Show(TextMgr:GetText(Text.union_tec30))
        return
    end

    if WorldMap.IsOpened() then
        WorldMap.CheckPreview()              
        WorldMap.ActivePreview(true, buildingData)
    else
        MainCityUI.ShowWorldMap(mapX, mapY, true, nil, buildingData)
    end
    UnionInfo.CloseAll()
end

local function ShowTip(force)
    local buildingType = _ui.buildingList[_ui.selectedIndex].data.type
    if buildingType == 1 then
        MapHelp.Open(1700, false, nil, nil, force)
    elseif buildingType == 3 then
        MapHelp.Open(1800, false, nil, nil, force)
    elseif buildingType == 4 then
        MapHelp.Open(1900, false, nil, nil, force)
    elseif buildingType == 5 then
        MapHelp.Open(2000, false, nil, nil, force)
    end
end

local function ShowBuildingOnWorldMap()
    local buildingMsg = _ui.buildingList[_ui.selectedIndex].msg
    if buildingMsg ~= nil then
        UnionInfo.CloseAll()
        local pos = buildingMsg.pos
        MainCityUI.ShowWorldMap(pos.x, pos.y, true, nil)
    end
end

local LoadUI
local function LoadList()
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    for i, v in ipairs(_ui.buildingList) do
        v.state = STATE_NONE
        for __, vv in ipairs(v.dataList) do
            if not v.dataList[1].needBuild then
                v.state = STATE_BUILT
            end

            local buildingMsg = UnionBuildingData.GetDataByBaseId(vv.id)
            if buildingMsg ~= nil then
                if vv.type == MapMsg_pb.GuildBuildTypeGuildMine then
                    _ui.selectedResource = vv.resourceType
                    v.data = vv
                end
                v.msg = buildingMsg
                if buildingMsg.isCompleted then
                    v.state = STATE_BUILT
                else
                    v.state = STATE_BUILDING
                    if #buildingMsg.armys == 0 then
                        v.timeLabel.text = Global.SecondToTimeLong(math.ceil((v.data.progressBar - buildingMsg.curCreatePro) / v.data.enableEnergyPerSec))
                    end
                end
            end

            if vv.type ~= MapMsg_pb.GuildBuildTypeGuildMine or vv.resourceType == _ui.selectedResource then
                v.data = vv
            end
        end

        if v.state < STATE_BUILDING then
            local leftSecond = Global.GetLeftCooldownSecond(unionMsg.createTime + v.dataList[1].unlockTime)
            v.timeLabel.text = Global.SecondToTimeLong(leftSecond)
            if leftSecond > 0 then
                v.state = STATE_UNLOCKING
            else
                v.state = STATE_UNBUILD
            end
        end

        local buildingData = v.data
        local buildingState = v.state
        local buildingMsg = v.msg
        if buildingState < STATE_BUILDING or v.msg == nil then
            v.icon.mainTexture = ResourceLibrary:GetIcon("Icon/UnionBuilding/", buildingData.typeIcon)
            v.nameLabel.text = TextMgr:GetText(buildingData.typeName)
        else
            v.icon.mainTexture = ResourceLibrary:GetIcon("Icon/UnionBuilding/", buildingData.icon)
            v.nameLabel.text = TextMgr:GetText(buildingData.name)
        end

        v.stateLabel.text = TextMgr:GetText(stateTextList[buildingState])
        if buildingState == STATE_UNLOCKING or buildingState == STATE_BUILDING then
            v.timeLabel.gameObject:SetActive(true)
        else
            v.timeLabel.gameObject:SetActive(false)
        end

        SetClickCallback(v.button.gameObject, function()
            print("点击联盟建筑Id:", buildingData.id)
            local function selectCallback()
                if _ui.selectedIndex ~= i then
                    _ui.selectedIndex = i
                    LoadUI()
                end
            end

            if buildingState == STATE_UNBUILD or buildingState == STATE_UNLOCKING then
                MapHelp.Open(1000 + buildingData.type * 100, false, selectCallback, true)
            else
                selectCallback()
            end
        end)

        v.selectedObject:SetActive(_ui.selectedIndex == i)
        v.noticeObject:SetActive(buildingData.type == MapMsg_pb.GuildBuildTypeWareHouse and UnionResourceRequestData.HasNotice())
        if i == _ui.selectedIndex then
            v.price = tonumber(string.split(buildingData.resource, ":")[2])
        end
    end
end

local function LoadInfo()
    local building = _ui.buildingList[_ui.selectedIndex]
    local buildingData = building.data
    local buildingState = building.state
    local buildingMsg = building.msg
    local buildingType = buildingData.type
    _ui.goButton.gameObject:SetActive(buildingType ~= MapMsg_pb.GuildBuildTypeWareHouse)
    _ui.rebuildButton.gameObject:SetActive(buildingType == MapMsg_pb.GuildBuildTypeTrainHouse and buildingState == STATE_BUILT)
    _ui.buttonGrid.repositionNow = true

    _ui.coordLabel.gameObject:SetActive(buildingMsg ~= nil and buildingType ~= MapMsg_pb.GuildBuildTypeWareHouse)
    if buildingMsg ~= nil then
        local pos = buildingMsg.pos
        _ui.coordLabel.text = Format(TextMgr:GetText(Text.ui_worldmap_77), 1, pos.x, pos.y)
    end

    if buildingState== STATE_BUILDING or buildingState == STATE_BUILT then
        _ui.goObject:SetActive(true)
        _ui.confirmObject:SetActive(false)
        _ui.resourceObject:SetActive(false)

        --联盟仓库
        if buildingType == MapMsg_pb.GuildBuildTypeWareHouse then
            _ui.goLabel.text = TextMgr:GetText(Text.mission_go)
            _ui.donateLabel.text = TextMgr:GetText(Text.union_ore13)
            SetClickCallback(_ui.donateButton.gameObject, function()
                UnionWareHouse.Show()
            end)
            --联盟科研中心
        elseif buildingType == MapMsg_pb.GuildBuildTypeTechHouse then
            _ui.goLabel.text = TextMgr:GetText(Text.mission_go)
            _ui.donateLabel.text = TextMgr:GetText(Text.union_tec4)
            SetClickCallback(_ui.donateButton.gameObject, function()
                CloseAll()
                UnionTec.Show()
            end)
            --联盟超级矿
        elseif buildingType == MapMsg_pb.GuildBuildTypeGuildMine then
            _ui.goLabel.text = TextMgr:GetText(Text.mission_go)
            _ui.donateLabel.text = TextMgr:GetText(Text.union_ore13)
            SetClickCallback(_ui.donateButton.gameObject, function()
                CloseAll()
                UnionSuperOre.Show(buildingData.id)
            end)
            --联盟训练场
        elseif buildingType == MapMsg_pb.GuildBuildTypeTrainHouse then
            _ui.goLabel.text = TextMgr:GetText(Text.mission_go)
            --自己参与的
            if UnionBuildingData.HasSelfArmy(buildingMsg) then
                _ui.donateLabel.text = TextMgr:GetText(Text.rebel_16)
                SetClickCallback(_ui.donateButton.gameObject, function()
                    UnionTrain.Show(buildingData.id)
                end)
                --自己未参与的
            else
                _ui.donateLabel.text = TextMgr:GetText(Text.union_train3)
                SetClickCallback(_ui.donateButton.gameObject, function()
                    local pos = buildingMsg.pos
                    BattleMove.Show(Common_pb.TeamMoveType_TrainField, buildingMsg.uid, "", pos.x, pos.y, function()
                        UnionInfo.CloseAll()
                        local basePos = MapInfoData.GetData().mypos
                        MainCityUI.ShowWorldMap(basePos.x, basePos.y, true)
                    end)
                end)
            end
            --联盟雷达
        elseif buildingType == MapMsg_pb.GuildBuildTypeRadar then
            _ui.goLabel.text = TextMgr:GetText(Text.mission_go)
            _ui.donateLabel.text = TextMgr:GetText(Text.union_ore13)
            _ui.tipLabel.text = TextMgr:GetText("Union_Radar_ui20")
            SetClickCallback(_ui.goButton.gameObject, function()
                UnionInfo.CloseAll()
                MainCityUI.ShowWorldMap(buildingMsg.pos.x, buildingMsg.pos.y, true)
            end)
            SetClickCallback(_ui.donateButton.gameObject, function()
                CloseAll()
                UnionRadar.Show()
            end)
        end
        SetClickCallback(_ui.rebuildButton.gameObject, ConfirmCallback)
    else
        _ui.goObject:SetActive(false)
        _ui.confirmObject:SetActive(true)
        _ui.resourceObject:SetActive(buildingType == MapMsg_pb.GuildBuildTypeGuildMine)

        if buildingType == MapMsg_pb.GuildBuildTypeGuildMine then
            for k, v in pairs(_ui.resourceList) do
                v.selectedObject:SetActive(_ui.selectedResource == k)
                SetClickCallback(v.gameObject, function()
                    if _ui.selectedResource ~= k then
                        _ui.selectedResource = k
                        LoadUI()
                    end
                end)
            end
        end
        SetClickCallback(_ui.confirmButton.gameObject, ConfirmCallback)
    end

    _ui.nameLabel.text = TextMgr:GetText(buildingData.name)
    local coin = UnionInfoData.GetCoin()
    local needCoin = tonumber(string.split(buildingData.resource, ":")[2])
    _ui.coinLabel.text = coin 
    _ui.coinLabel.color = coin >= needCoin and Color.white or Color.red
    _ui.needCoinLabel.text = needCoin
    _ui.tipLabel.text = TextMgr:GetText(buildingData.tip)
end

LoadUI = function()
    LoadList()
    LoadInfo()
    UpdateBuildingTime()
    ShowTip(false)
end

function Start()
    _ui.grid = transform:Find("Container/bg2/content 3/bg_mid/BuildingList/Grid"):GetComponent("UIGrid")
    _ui.buildingPrefab = ResourceLibrary.GetUIPrefab("union/union_buildcommon")
    local buildingList = {}
    local buildingDataList = UnionBuildingData.GetBuildingDataList()
    local buildingIndex = 1
    for k, v in kpairs(buildingDataList) do
        local buildingTransform
        if buildingIndex > _ui.grid.transform.childCount then
            buildingTransform = NGUITools.AddChild(_ui.grid.gameObject, _ui.buildingPrefab).transform
        else
            buildingTransform = _ui.grid.transform:GetChild(buildingIndex - 1)
        end
        local buildingType = v[1].type
        buildingTransform.name = _ui.buildingPrefab.name .. buildingType
        local button = buildingTransform:GetComponent("UIButton")
        local icon = buildingTransform:Find("Texture"):GetComponent("UITexture")
        local nameLabel = buildingTransform:Find("bg_title/text"):GetComponent("UILabel")
        local stateLabel = buildingTransform:Find("text"):GetComponent("UILabel")
        local timeLabel = buildingTransform:Find("time"):GetComponent("UILabel")
        local selectedObject = buildingTransform:Find("select").gameObject
        local noticeObject = buildingTransform:Find("red").gameObject

        local building = {}
        building.button = button
        building.icon = icon
        building.nameLabel = nameLabel
        building.stateLabel = stateLabel
        building.timeLabel = timeLabel
        building.selectedObject = selectedObject
        building.noticeObject = noticeObject
        building.data = v[1]
        building.dataList = v
        buildingList[buildingIndex] = building
        buildingIndex = buildingIndex + 1
    end
    _ui.grid.repositionNow = true

    _ui.buildingList = buildingList

    _ui.goObject = transform:Find("Container/BuildingGo").gameObject
    _ui.confirmObject = transform:Find("Container/BuildingConfirm").gameObject
    _ui.resourceObject = transform:Find("Container/BuildingConfirm/mid").gameObject
    _ui.goButton = transform:Find("Container/BuildingGo/Grid/button"):GetComponent("UIButton")
    _ui.goLabel = transform:Find("Container/BuildingGo/Grid/button/Label"):GetComponent("UILabel")
    _ui.donateButton = transform:Find("Container/BuildingGo/Grid/button (1)"):GetComponent("UIButton")
    _ui.donateLabel = transform:Find("Container/BuildingGo/Grid/button (1)/Label"):GetComponent("UILabel")
    _ui.confirmButton = transform:Find("Container/BuildingConfirm/button"):GetComponent("UIButton")
    _ui.rebuildButton = transform:Find("Container/BuildingGo/rebuild btn"):GetComponent("UIButton")
    _ui.coinLabel = transform:Find("Container/BuildingConfirm/UnionCoin/num"):GetComponent("UILabel")
    _ui.needCoinLabel = transform:Find("Container/BuildingConfirm/UnionCoin/need_num"):GetComponent("UILabel")
    _ui.coordLabel = transform:Find("Container/right/coordinate"):GetComponent("UILabel")
    _ui.nameLabel = transform:Find("Container/right/top/Label"):GetComponent("UILabel")
    _ui.tipButton = transform:Find("Container/right/help btn"):GetComponent("UIButton")
    _ui.tipLabel = transform:Find("Container/right/shuoming"):GetComponent("UILabel")
    _ui.buttonGrid = transform:Find("Container/BuildingGo/Grid"):GetComponent("UIGrid")

    local resourceList = {}
    for i = 3, 6 do
        local resource = {}
        local resourceTransform = transform:Find("Container/BuildingConfirm/mid/" .. i)
        resource.selectedObject = resourceTransform:Find("select").gameObject
        resource.gameObject = resourceTransform.gameObject
        resourceList[i] = resource
    end
    _ui.resourceList = resourceList

    _ui.timer = Timer.New(UpdateBuildingTime, 1, -1)
    _ui.timer:Start()

    SetClickCallback(_ui.tipButton.gameObject, function()
        ShowTip(true)
    end)
    SetClickCallback(_ui.coordLabel.gameObject, ShowBuildingOnWorldMap)
    SetClickCallback(_ui.goButton.gameObject, ShowBuildingOnWorldMap)

    LoadUI()

    UnionBuildingData.AddListener(LoadUI)
    UnionResourceRequestData.AddListener(LoadUI)
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/background widget/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
end

function Close()
    UnionBuildingData.RemoveListener(LoadUI)
    UnionResourceRequestData.RemoveListener(LoadUI)
    _ui.timer:Stop()
    _ui = nil
end

function Show(mapX, mapY)
    UnionBuildingData.RequestData(function()
        Global.OpenUI(_M)
        _ui.mapX = mapX
        _ui.mapY = mapY
        _ui.selectedIndex = 1
        _ui.selectedResource = 3
    end)
end
