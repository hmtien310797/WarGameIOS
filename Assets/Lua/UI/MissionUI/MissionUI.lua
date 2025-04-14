module("MissionUI", package.seeall)
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

local type2List = 
{
    [1] = "recommend",
    [2] = "base",
    [3] = "battle",
    [4] = "military",
    [5] = "explore",
    [6] = "general",
    [7] = "other",
    [8] = "complete",
}

local chestTextList = 
{
    "s",
    "s",
    "m",
    "m",
    "b",
    "b",
}

local _ui
local timer = 0

function ShowCompleted(rewardMsg, targetGameObject)
    Global.ShowReward(rewardMsg, targetGameObject)
end

function Hide()
    Global.CloseUI(_M)
end

local function WorldMapJump(jumpFunc)
    if GUIMgr:IsMenuOpen("WorldMap") then
        MainCityUI.HideWorldMap(true, function()
            jumpFunc()
        end, true)
    else
        jumpFunc()
    end
end

function GetMissionJumpFunction(missionMsg, missionData)
    local conditionType = missionData.conditionType
    local paramList = string.split(missionData.param, ":")
    local missionId = missionData.id
    if missionId == tonumber(tableData_tGlobal.data[109].value) then
        return function()
            local monsterLevel = tonumber(paramList[1])
            WorldMapData.RequestCreateMonster(monsterLevel, function(monsterPos)
                MainCityUI.ShowWorldMap(monsterPos.x, monsterPos.y, true, function()
                end)
            end)
        end
    elseif conditionType == 1 or conditionType == 18 or conditionType == 85 then
        return function()
            local buildingId = tonumber(paramList[1])
            local buildingLevel = tonumber(paramList[2])
            WorldMapJump(function()
                maincity.SetTargetBuild(buildingId, true, buildingLevel)
            end)
        end
    elseif conditionType == 2 then
        local battleId = tonumber(paramList[2])
        local chapterId = tonumber(paramList[1])
        if chapterId > 1000 then
            return function()
                SandSelect.Show(5)
            end
        else
            return function()
                local reasonText = ChapterInfoUI.CheckShow(battleId)
                if reasonText ~= nil then
                    ChapterSelectUI.ShowExploringChapter()
                end
            end
        end
    elseif conditionType == 3 or conditionType == 14 or conditionType == 69 then
        local soldierId = tonumber(paramList[1])
        local soldierData = Barrack.GetAramInfo(soldierId, 1)
        local buildingId = soldierData.BarrackId
        return function()
            WorldMapJump(function()
                Barrack.Show(buildingId)
            end)
        end
    elseif conditionType == 88 then
        local soldierId = tonumber(paramList[1])
        local soldierData = Barrack.GetAramInfo(soldierId, 1)
        local buildingId = soldierData.BarrackId
        return function()
            if maincity.GetBuildingByID(buildingId) ~= nil then
                WorldMapJump(function()
                    Barrack.Show(buildingId)
                end)
            else
                maincity.SetTargetBuild(buildingId, true, nil, true)
            end
        end
    elseif conditionType == 4 then
        return function()
            WorldMapJump(function()
                maincity.SetTargetBuild(6, true, nil, true)
            end)
        end
    elseif conditionType == 6 then
        return nil
    elseif conditionType == 7
        or conditionType == 8
        or conditionType == 11
        or conditionType == 12
        or conditionType == 35
        or conditionType == 55
        or conditionType == 75
        or conditionType == 76 then
        return function()
            HeroList.Show()
        end
    elseif conditionType == 9 then
        return function()
            ChapterSelectUI.ShowExploringChapter()
        end
    elseif conditionType == 10 or conditionType == 19 or conditionType == 74 or conditionType == 57 then
        return function()
            WorldMapJump(function()
                maincity.SetTargetBuild(7, true)
                coroutine.start(function()
                    coroutine.wait(0.5)
                    MilitarySchool.Show()
                end)
            end)
        end
    elseif conditionType == 13 then
        return function()
            FirstChangeName.Show()
        end
    elseif conditionType == 15 then
        local blockId = tonumber(missionData.param)
        return function()
            WorldMapJump(function()
                maincity.SetTargetBlock(blockId)
            end)
        end
    elseif conditionType == 16 then
        return function()
            ActivityEntrance.Show()
        end
    elseif conditionType == 17 or conditionType == 98 then
        return function()
            WorldMapJump(function()
                local technologyId = tonumber(paramList[1])
                Laboratory.OpenTech(technologyId)
            end)
        end
    elseif conditionType == 20 or conditionType == 53 then
        return function()
            MainCityUI.ShowWorldMap(nil, nil, true, function()
                MapSearch.Show(1)
            end)
        end
    elseif conditionType == 26 then
        return function()
            local monsterLevel = tonumber(paramList[1])
            local basePos = MapInfoData.GetData().mypos
            local posIndex = WorldMap.MapCoordToPosIndex(basePos.x, basePos.y)
            WorldMapData.RequestAndSearchData(posIndex, function(data)
                for i, v in ipairs(data) do
                    for __, vv in ipairs(v.entrys) do
                        if vv.data.entryType == Common_pb.SceneEntryType_Monster then
                            if vv.monster.level == monsterLevel then
                                local pos = vv.data.pos
                                MainCityUI.ShowWorldMap(pos.x, pos.y, true, function()
                                    WorldMap.ShowTileInfo(pos.x, pos.y)
                                end)
                                return
                            end
                        end
                    end
                end
                FloatText.Show(TextMgr:GetText(Text.mission_ui1))
                MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
                end)
            end)
        end
    elseif conditionType == 27 then
        return function()
            local resType = tonumber(paramList[1])
            local basePos = MapInfoData.GetData().mypos
            local posIndex = WorldMap.MapCoordToPosIndex(basePos.x, basePos.y)
            WorldMapData.RequestAndSearchData(posIndex, function(data)
                for i, v in ipairs(data) do
                    for __, vv in ipairs(v.entrys) do
                        if vv.data.entryType == resType and vv.res.owner == 0 then
                            local pos = vv.data.pos
                            MainCityUI.ShowWorldMap(pos.x, pos.y, true, function()
                                WorldMap.ShowTileInfo(pos.x, pos.y)
                            end)
                            return
                        end
                    end
                end
                FloatText.Show(TextMgr:GetText(Text.mission_ui2))
                MainCityUI.ShowWorldMap(basePos.x, basePos.y, true)
            end)
        end
    elseif conditionType == 21 then
        return function()
            SlgBag.Show(1)
        end
    elseif conditionType == 5 or conditionType >= 22 and conditionType <= 25
        or conditionType == 33 or conditionType == 51 or conditionType == 81
        or conditionType == 82 or conditionType == 83 or conditionType == 84
        or conditionType == 100 then
        return function()
            local basePos = MapInfoData.GetData().mypos
            MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
            end)
        end
    elseif conditionType == 28 then
        return function()
            JoinUnion.Show()
        end
    elseif conditionType == 29 then
        return function()
            WorldMapJump(function()
                maincity.SetTargetBuild(1, false, nil, true)
            end)
        end
    elseif conditionType == 30 then
        return function()
            if UnionInfoData.HasUnion() then
                UnionHelp.Show()
            else
                JoinUnion.Show()
            end
        end
    elseif conditionType == 31 then
        return function()
            local actionType = tonumber(paramList[1])
            if actionType == 1 then
                MissionUI.Show(3)
            else
                if UnionInfoData.HasUnion() then
                    MissionUI.Show(4)
                else
                    JoinUnion.Show()
                end
            end
        end
    elseif conditionType == 36 then
        return function()
            MissionUI.Show(3)
        end
    elseif conditionType == 32 or conditionType == 45 then
        return function()
            local barrack = maincity.GetEmptyBarrack()
            if barrack ~= nil then
                local barrackData = barrack.data
                if barrackData ~= nil then
                    Barrack.Show(barrackData.type)
                end
            end
        end
    elseif conditionType == 37 then
        return function()
            WorldMapJump(function()
                maincity.SetTargetBuild(3, false, nil, true)
            end)
        end
    elseif conditionType == 54 then
        return function()
            ActivityAll.Show("ActivityRace")
        end
    elseif conditionType == 56 or conditionType == 90 then
        return function()
            WorldMapJump(function()
                Laboratory.Show()
            end)
        end
    elseif conditionType == 58 then
        return function()
            HeroAppointUI.Show()
        end
    elseif conditionType == 70 then
        return function()
            if UnionInfoData.HasUnion() then
                local basePos = MapInfoData.GetData().mypos
                MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
                end)
            else
                JoinUnion.Show()
            end
        end
    elseif conditionType == 77 or conditionType == 86 then
        return function()
            if UnionInfoData.HasUnion() then
                UnionInfo.Show()
            else
                JoinUnion.Show()
            end
        end
    elseif conditionType == 49 then
        return function()
            if UnionInfoData.HasUnion() then
                Union_donate.Show()
            else
                JoinUnion.Show()
            end
        end
    elseif conditionType == 79 then
        return function()
            if tonumber(paramList[1]) == 1 then
                ChapterSelectUI.ShowExploringChapter()
            elseif tonumber(paramList[1]) == 2 then
                local basePos = MapInfoData.GetData().mypos
                MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
                end)
            end
        end
    elseif conditionType == 92 then
        return function()
            MainCityUI.ShowWorldMap(nil, nil, true, function()
                MapSearch.Show(2)
            end)
        end
    elseif conditionType == 97 then
        return function()
            ShareUnion.Show(function()
                local req = ClientMsg_pb.MsgShareFacebookRequest()
                req.shareType = 1
                Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgShareFacebookRequest, req, ClientMsg_pb.MsgShareFacebookResponse, function(msg)

                end, true)
            end)
        end
    elseif conditionType == 103 then
        local buildingId = 8
        return function()
            if maincity.GetBuildingByID(buildingId) ~= nil then
                WorldMapJump(function()
                    Entrance.Show()
                end)
            else
                maincity.SetTargetBuild(buildingId, true, nil, true)
            end
        end
    elseif conditionType == 104 or conditionType == 114 then
        return function()
            BattleRank.Show(false)
        end
    elseif conditionType == 105 or conditionType == 112 or conditionType == 113 then
        return function()
            Climb.Show()
        end
    elseif conditionType == 106 then
        return function()
            Rune.Show(3)
        end
    elseif conditionType == 107 or conditionType == 108 then
        return function()
            Barrack_SoldierEquip.Show(1001)
        end
    else
        return function()
        end
    end
end

function LoadMissionJump(jumpButton, missionMsg, missionData)
    local completed = missionMsg.value >= missionData.number
    if completed then
        jumpButton.gameObject:SetActive(false)
    else
        local missionJumpFunc = GetMissionJumpFunction(missionMsg, missionData)
        if missionJumpFunc ~= nil then
            jumpButton.gameObject:SetActive(true)
            UIUtil.SetClickCallback(jumpButton.gameObject, function()
                Hide()
                local conditionType = missionData.conditionType
                print(string.format("任务跳转,表格Id:%d, 条件类型:%d", missionData.id, conditionType))
                missionJumpFunc()
            end)
        else
            jumpButton.gameObject:SetActive(false)
        end
    end
end

local function GetRewardRequest(missionMsg)
    return function()
        local req = ClientMsg_pb.MsgUserMissionRewardRequest();
        req.taskid = missionMsg.id
        Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.FloatError(msg.code)
            else
                AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)

                GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
                MainCityUI.UpdateRewardData(msg.fresh)
                if _ui ~= nil and _ui.mainMissionList.selectedMission ~= nil and _ui.mainMissionList.selectedMission.msg.id == missionMsg.id then
                    _ui.mainMissionList.selectedMission = nil
                end
                ShowCompleted(msg.reward)

                MissionListData.RemoveMission(msg.taskid)
                MissionListData.UpdateList(msg.quest)
                -- send data report-----------
                GUIMgr:SendDataReport("umission", "" .. msg.taskid, "completed", "0")
                ------------------------------
            end
        end, true)
    end
end

local function LoadReward(rewardData, rewardList)
    local itemIndex = 1
    local moneyIndex = 1
    if rewardData ~= nil then
        local hasItemReward = rewardData.item ~= "NA"
        if hasItemReward then
            for v in string.gsplit(rewardData.item, ";") do
                local itemTable = string.split(v, ":")
                local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
                local itemData = TableMgr:GetItemData(itemId)
                local itemTransform
                if rewardList.moneyGrid.transform.childCount < moneyIndex then
                    itemTransform = NGUITools.AddChild(rewardList.moneyGrid.gameObject, _ui.itemRewardPrefab).transform
                    itemTransform.gameObject.name = _ui.itemRewardPrefab.name..moneyIndex
                    itemTransform.localScale = Vector3(0.7,0.7,0.7)
                else
                    itemTransform = rewardList.moneyGrid:GetChild(moneyIndex - 1)
                end
                local item = {}
                UIUtil.LoadItemObject(item, itemTransform)
                UIUtil.LoadItem(item, itemData, itemCount)

                itemTransform.gameObject:SetActive(true)
                UIUtil.SetTooltipCallback(item.gameObject, function(go, show)
                    if show then
                        Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                    else
                        Tooltip.HideItemTip()
                    end
                end)
                moneyIndex = moneyIndex + 1
            end
        end
        --rewardList.itemBg.localScale = Vector3(1, hasItemReward and 1 or 0, 1)

        if rewardData.money ~= "NA" then
            for v in string.gsplit(rewardData.money, ";") do
                local itemTable = string.split(v, ":")
                local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
                if itemId ~= nil and itemCount ~= nil then
                    local itemData = TableMgr:GetItemData(itemId)
                    local itemTransform
                    if rewardList.moneyGrid.transform.childCount < moneyIndex then
                        itemTransform = NGUITools.AddChild(rewardList.moneyGrid.gameObject, _ui.moneyRewardPrefab).transform
                        itemTransform.gameObject.name = _ui.moneyRewardPrefab.name..moneyIndex
                    else
                        itemTransform = rewardList.moneyGrid:GetChild(moneyIndex - 1)
                    end
                    local icon = itemTransform:Find("money icon"):GetComponent("UITexture")
                    icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
                    local countLabel = itemTransform:Find("num"):GetComponent("UILabel")
                    if itemId == 11 then
                        local params = {}
                        params.base = itemCount
                        countLabel.text = "+" .. math.floor(AttributeBonus.CallBonusFunc(50 , params))
                    else
                        countLabel.text = "+" .. itemCount
                    end
                    itemTransform.gameObject:SetActive(true)
                    moneyIndex = moneyIndex + 1
                end
            end
        end
    end

    --for i = itemIndex, rewardList.itemGrid.transform.childCount do
    --    rewardList.itemGrid:GetChild(i - 1).gameObject:SetActive(false)
    --end
    for i = moneyIndex, rewardList.moneyGrid.transform.childCount do
        rewardList.moneyGrid:GetChild(i - 1).gameObject:SetActive(false)
    end

    -- rewardList.itemGrid:Reposition()
    rewardList.moneyGrid:Reposition()
end

local function LoadMainMission()
    for _, v in ipairs(_ui.mainMissionList) do
        v.index = 1
    end
    _ui.mainMissionList.hasNotice = false
    _ui.mainMissionList.hasSelected = _ui.mainMissionList.selectedMission ~= nil
    MissionListData.Sort1()
    local recommendedMission, recommendedData = MissionListData.GetRecommendedMissionAndData()
    local missionListData = MissionListData.GetData()
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        local completed = v.value >= missionData.number
        if missionData.type == 1 then
            local type2 = missionData.type2
            if v == recommendedMission then
                type2 = 1
            elseif completed then
                _ui.mainMissionList.hasNotice = true
                type2 = #type2List
            end

            local list = _ui.mainMissionList[type2]
            local missionTransform
            if list.table.transform.childCount < list.index then
                missionTransform = NGUITools.AddChild(list.table.gameObject, _ui.missionPrefab).transform
                missionTransform.gameObject.name = _ui.missionPrefab.name..list.index
            else
                missionTransform = list.table.transform:GetChild(list.index - 1)
            end
            local mission = {}
            mission.transform = missionTransform
            mission.bg = missionTransform:Find("bg")
            mission.rewardButton = missionTransform:Find("btn"):GetComponent("UIButton")
            mission.jumpButton = missionTransform:Find("btn go"):GetComponent("UIButton")
            mission.title = missionTransform:Find("text"):GetComponent("UILabel")
            mission.selected = missionTransform:Find("selected")
            mission.silder = missionTransform:Find("exp bar"):GetComponent("UISlider")
            mission.countLabel = missionTransform:Find("exp bar/num"):GetComponent("UILabel")
            mission.msg = v
            mission.data = missionData

            mission.title.text = TextUtil.GetMissionTitle(missionData)
            mission.silder.value = v.value / missionData.number
            mission.countLabel.text = string.format("%d/%d", v.value, missionData.number)

            local selectedMission = _ui.mainMissionList.selectedMission
            mission.rewardButton.gameObject:SetActive(completed)
            if completed then
                UIUtil.SetClickCallback(mission.rewardButton.gameObject, GetRewardRequest(v))
            end
            LoadMissionJump(mission.jumpButton, v, missionData)
            missionTransform.gameObject:SetActive(true)

            if not _ui.mainMissionList.hasSelected then
                if _ui.mainMissionList.selectedMission == nil or type2 < _ui.mainMissionList.selectedMission.data.type2 then
                    _ui.mainMissionList.selectedMission = mission
                end
            end

            mission.selected.gameObject:SetActive(false)
            UIUtil.SetClickCallback(mission.bg.gameObject, function(go)
                if _ui ~= nil then
                    _ui.mainMissionList.selectedMission = mission
                    print("选择任务Id:", mission.msg.id)
                    LoadMainMission()
                end
            end)

            local rewardList = _ui.rewardList
            rewardList.moneyGrid = missionTransform:Find("mission  reward/Grid"):GetComponent("UIGrid")
            LoadReward(missionData, rewardList)

            list.index = list.index + 1
        end
    end

    for i, v in ipairs(_ui.mainMissionList) do
        v.bg.gameObject:SetActive(v.index > 1)
        for j = v.index, v.table.transform.childCount do
            v.table.transform:GetChild(j - 1).gameObject:SetActive(false)
        end
        v.table.repositionNow = true
    end

    _ui.mainMissionList.notice.gameObject:SetActive(_ui.mainMissionList.hasNotice)
    if _ui.mainMissionList.selectedMission ~= nil then
        _ui.mainMissionList.selectedMission.selected.gameObject:SetActive(true)
    end
end

local function LoadDailyList()
    local missionIndex = 1
    local missionListData = MissionListData.GetData()
    for i, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        local completed = v.value >= missionData.number
        if missionData.type == 2 then
            if not missionData.chest then
                local missionTransform = nil
                if _ui.dailyGrid.transform.childCount < missionIndex then
                    missionTransform = NGUITools.AddChild(_ui.dailyGrid.gameObject, _ui.dailyPrefab).transform
                    missionTransform.gameObject.name = _ui.dailyPrefab.name .. missionIndex
                    if i > 4 then
                        _ui.dailyGrid.repositionNow = true
                        coroutine.step()
                    end
                else
                    missionTransform = _ui.dailyGrid.transform:GetChild(missionIndex - 1)
                end
                local mission = {}
                mission.transform = missionTransform
                mission.bg = missionTransform:Find("bg")
                mission.icon = missionTransform:Find("bg/Texture"):GetComponent("UITexture")
                mission.jumpButton = missionTransform:Find("btn go"):GetComponent("UIButton")
                mission.jumpButton_label = missionTransform:Find("btn go/Label").gameObject
                mission.jumpButton_label2 = missionTransform:Find("btn go/Label (2)").gameObject
                mission.titleLabel = missionTransform:Find("missionname"):GetComponent("UILabel")
                mission.selected = missionTransform:Find("selected")
                mission.silder = missionTransform:Find("exp bar"):GetComponent("UISlider")
                mission.countLabel = missionTransform:Find("exp bar/num"):GetComponent("UILabel")
                mission.pointLabel = missionTransform:Find("point/pointtext"):GetComponent("UILabel")
                mission.finishedObject = missionTransform:Find("icon_finish").gameObject
                mission.descriptionLabel = missionTransform:Find("desc"):GetComponent("UILabel")

                mission.msg = v
                mission.data = missionData

                mission.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Mission/", missionData.icon)
                mission.titleLabel.text = TextUtil.GetMissionTitle(missionData)
                local missionValue = v.value
                local missionMaxValue = missionData.number
                if missionData.DailyCount > 0 then
                    missionValue = math.floor(v.value / (missionData.number / missionData.DailyCount))
                    missionMaxValue = missionData.DailyCount
                end
                mission.silder.value = missionValue / missionMaxValue
                mission.countLabel.text = string.format("%d/%d", missionValue, missionMaxValue)
                mission.descriptionLabel.text = TextMgr:GetText(missionData.description)

                mission.jumpButton.gameObject:SetActive(not completed and v.id ~= 45 and v.id ~= 39)
                mission.jumpButton_label:SetActive(v.id ~= 77)
                mission.jumpButton_label2:SetActive(v.id == 77)
                local missionJumpFunc = MissionUI.GetMissionJumpFunction(v, missionData)
                if missionJumpFunc ~= nil then
                    UIUtil.SetClickCallback(mission.jumpButton.gameObject, function()
                        Hide()
                        local conditionType = missionData.conditionType
                        print(string.format("任务跳转,表格Id:%d, 条件类型:%d", missionData.id, conditionType))
                        missionJumpFunc()
                    end)
                end
                missionTransform.gameObject:SetActive(true)
                mission.pointLabel.text = Format(TextMgr:GetText(Text.DailyMission_pointadd), missionData.activePoint)
                mission.finishedObject:SetActive(completed)

                missionIndex = missionIndex + 1
            end
        end
    end
    for i = missionIndex, _ui.dailyGrid.transform.childCount do
        _ui.dailyGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.dailyGrid.repositionNow = true
end

function LoadDailyMission()
    _ui.dailyMissionNotice.gameObject:SetActive(MissionListData.HasDailyMissionNotice())
    MissionListData.Sort3()
    coroutine.stop(_ui.loadListCoroutine)
    _ui.loadListCoroutine = coroutine.start(LoadDailyList)
    local missionListData = MissionListData.GetData()
    local totalActivePoint = 0
    local chestList = {}
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
            else
                table.insert(chestList, {missionData, v})
            end
        end
    end

    table.sort(chestList, function(t1, t2)
        return t1[1].number < t2[1].number
    end)
    _ui.activePointLabel.text = totalActivePoint
    _ui.activePointSlider.value = totalActivePoint / chestList[#chestList][1].number

    for i, v in ipairs(_ui.chestList) do
        local missionData = chestList[i][1]
        local missionMsg = chestList[i][2]
        v.activePointLabel.text = missionData.number

        local completed = missionMsg.value >= missionData.number
        local chestText
        if missionMsg.rewarded then
            chestText = "open"
        elseif completed then
            chestText = "done"
        else
            chestText = "null"
        end

        v.iconButton.normalSprite = string.format("icon_starbox_%s_%s_dm", chestTextList[i], chestText)
        local canReward = completed and not missionMsg.rewarded
        v.effect:SetActive(canReward)
        for i = 1, v.tweenerList.Length do
            v.tweenerList[i - 1].enabled = canReward
        end

        SetClickCallback(v.iconButton.gameObject, function()
            if canReward then
                local req = ClientMsg_pb.MsgUserMissionRewardRequest();
                req.taskid = missionMsg.id
                Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.FloatError(msg.code)
                    else
                        AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
                        GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
                        MainCityUI.UpdateRewardData(msg.fresh)
                        ItemListShowNew.Show(msg)
                        MissionListData.SetRewarded(msg.taskid)
                        MissionListData.UpdateList(msg.quest)
                        -- send data report-----------
                        GUIMgr:SendDataReport("umission", "" .. msg.taskid, "completed", "0")
                        if msg.taskid >= 28 and msg.taskid <= 33 then
                            local missionData = TableMgr:GetMissionData(msg.taskid)
                            GUIMgr:SendDataReport("efun", "daily" .. missionData.number)
                        end
                        ------------------------------
                    end
                end, true)
            else
                GrowRewards.Show(missionMsg, missionData)
            end
        end)
    end
end

local function LoadAction()
    local actionList = _ui.actionList
    MilitaryActionData.Sort1()
    local actionMsg = MilitaryActionData.GetData()

    for _, v in ipairs(actionList) do
        v.index = 1
        v.hasActive = false
        v.hasNotice = false
    end

    _ui.sliderList = {}
    local hasUnion = UnionInfoData.HasUnion()
    local actionListMsg = actionMsg.tasks
    for _, v in ipairs(actionListMsg) do
        if v.status ~= ClientMsg_pb.ots_reward then
            local actionData = TableMgr:GetMilitarytActionData(v.baseid)
            local missionType = actionData.missionType
            if missionType == 1 or hasUnion then
                local list = actionList[missionType]
                if list.selectedUid == nil then
                    list.selectedUid = v.uid
                else
                    local selectedActionMsg = MilitaryActionData.GetActionData(list.selectedUid)
                    if selectedActionMsg == nil or selectedActionMsg.status == ClientMsg_pb.ots_reward then
                        list.selectedUid = v.uid
                    end
                end
                local actionTransform
                if list.index > list.table.transform.childCount then
                    actionTransform = NGUITools.AddChild(list.table.gameObject, _ui.actionPrefab).transform
                else
                    actionTransform = list.table.transform:GetChild(list.index - 1)
                end
                actionTransform:Find("time bar"):GetComponent("UISlider").thumb:GetComponent("UISprite").spriteName = missionType == 1 and "mission_tank" or "mission_flight"

                local rewardList = _ui.rewardList
                rewardList.moneyGrid = actionTransform:Find("mission  reward/Grid"):GetComponent("UIGrid")
                LoadReward(actionData, rewardList)

                actionTransform.gameObject:SetActive(true)
                actionTransform:Find("text1"):GetComponent("UILabel").text = TextMgr:GetText(actionData.missionName)
                local rewardButton = actionTransform:Find("btn")
                rewardButton.gameObject:SetActive(v.status == ClientMsg_pb.ots_finish)
                local goButton = actionTransform:Find("btn go")
                goButton.gameObject:SetActive(v.status == ClientMsg_pb.ots_none)
                local speedButton = actionTransform:Find("btn speed")
                speedButton.gameObject:SetActive(v.status == ClientMsg_pb.ots_doing)

                UIUtil.SetClickCallback(goButton.gameObject, function()
                    local req = ClientMsg_pb.MsgOnlineTaskGetRequest()
                    req.taskid = v.uid
                    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgOnlineTaskGetRequest, req, ClientMsg_pb.MsgOnlineTaskGetResponse, function(msg)
                        if msg.code == ReturnCode_pb.Code_OK then
                            MilitaryActionData.UpdateActionData(msg.task)
                        else
                            Global.ShowError(msg.code)
                        end
                    end, true)
                end)

                UIUtil.SetClickCallback(rewardButton.gameObject, function()
                    local req = ClientMsg_pb.MsgOnlineTaskRewardRequest()
                    req.taskid = v.uid
                    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgOnlineTaskRewardRequest, req, ClientMsg_pb.MsgOnlineTaskRewardResponse, function(msg)
                        if msg.code == ReturnCode_pb.Code_OK then
                            MilitaryActionData.UpdateActionData(msg.task)
                            GUIMgr:SendDataReport("reward", "RewardMilitary:" .. msg.task.uid, "".. MoneyListData.ComputeDiamond(msg.freshInfo.money.money))
                            Global.ShowReward(msg.reward)
                            MainCityUI.UpdateRewardData(msg.freshInfo)
                        else
                            Global.ShowError(msg.code)
                        end
                    end, true)
                end)

                UIUtil.SetClickCallback(speedButton.gameObject, function()
                    CommonItemBag.OnOpenCB = function()
                    end
                    CommonItemBag.OnCloseCB = function() 
                    end	

                    CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
                    CommonItemBag.NotUseAutoClose()
                    CommonItemBag.NotUseFreeFinish()
                    CommonItemBag.NeedItemMaxValue()
                    CommonItemBag.SetItemList(maincity.GetItemExchangeListNoCommon(1), 4)

                    CommonItemBag.SetInitFunc(function()
                        local text = TextMgr:GetText(actionData.missionName)
                        local msg = MilitaryActionData.GetActionData(v.uid)
                        local time = msg.starttime + msg.totoaltime
                        local totalTime = msg.orgtotaltime
                        return text, time, totalTime, nil, nil, nil, 2, nil, 0
                    end)
                    CommonItemBag.OnCloseCB = function()
                    end
                    --使用加速道具 減時間
                    CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
                        print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
                        local itemTBData = TableMgr:GetItemData(useItemId)
                        local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

                        local req = ItemMsg_pb.MsgUseItemSubTimeRequest()
                        if itemdata ~= nil then
                            req.uid = itemdata.uniqueid
                        else
                            req.exchangeId = exItemid
                        end
                        req.num = count
                        req.otaskid = v.uid
                        req.subTimeType = 6
                        Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
                            print("use item code:" .. msg.code)
                            if msg.code == 0 then
                                local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
                                if price == 0 then
                                    GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
                                else
                                    GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
                                end
                                AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)

                                local nameColor = Global.GetLabelColorNew(itemTBData.quality)
                                local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
                                FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
                                AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)

                                MainCityUI.UpdateRewardData(msg.fresh)

                                MilitaryActionData.UpdateActionData(msg.otask)
                                CommonItemBag.UpdateItem()
                                if msg.otask.status == ots_finish then
                                    CommonItemBag.SetInitFunc(nil)
                                    GUIMgr:CloseMenu("CommonItemBag")
                                end
                            else
                                Global.FloatError(msg.code, Color.white)
                            end
                        end, true)
                    end)
                    GUIMgr:CreateMenu("CommonItemBag" , false)
                end)

                local totalTimeLabel = actionTransform:Find("time"):GetComponent("UILabel")
                totalTimeLabel.gameObject:SetActive(v.status == ClientMsg_pb.ots_none)
                local timeSlider = actionTransform:Find("time bar"):GetComponent("UISlider")
                timeSlider.gameObject:SetActive(v.status == ClientMsg_pb.ots_doing or v.status == ClientMsg_pb.ots_finish)
                if v.status == ClientMsg_pb.ots_none then
                    totalTimeLabel.text = Global.SecondToTimeLong(v.orgtotaltime)
                elseif v.status == ClientMsg_pb.ots_doing then
                    list.hasActive = true
                    local endTime = v.starttime + v.totoaltime
                    local leftCooldownSecond = Global.GetLeftCooldownSecond(endTime)
                    if leftCooldownSecond > 0 then
                        table.insert(_ui.sliderList, {timeSlider, v})
                    end
                elseif v.status == ClientMsg_pb.ots_finish then
                    list.hasNotice = true
                    timeSlider.value = 1
                end
                local bg = actionTransform:Find("bg")
                UIUtil.SetClickCallback(bg.gameObject, function()
                    list.selectedUid = v.uid
                    LoadAction()
                end)
                local selected = actionTransform:Find("selected")
                selected.gameObject:SetActive(v.uid == list.selectedUid)

                list.table.repositionNow = true

                list.index = list.index + 1
            end
        end
    end

    for i, v in ipairs(actionList) do
        v.notice.gameObject:SetActive(v.hasNotice or MilitaryActionData.HasRefreshNoticeByType(i))
        if v.hasActive then
            for j = 1, v.index - 1 do
                v.table.transform:GetChild(j - 1):Find("btn go").gameObject:SetActive(false)
            end
        end
        for j = v.index, v.table.transform.childCount do
            v.table.transform:GetChild(j - 1).gameObject:SetActive(false)
        end
    end

    actionList[1].emptyGameObject:SetActive(actionList[1].index == 1)
    actionList[2].emptyGameObject:SetActive(actionList[2].index == 1 and hasUnion)
    actionList[2].tileGameObject:SetActive(hasUnion)
end

local function LoadUI()
    LoadMainMission()
    LoadDailyMission()
    LoadAction()
end

local function CheckLeaveUnion()
    if not UnionInfoData.HasUnion() then
        if _ui.toggleList[4].value then
            MissionUI.Show(_ui.oldToggleIndex)
        end
    end
end

function Awake()
    _ui = {}
    _ui.mainMissionList = {}
    _ui.mainMissionList.table = transform:Find("Container/bg/mission list/content 1/Scroll View/Table"):GetComponent("UITable")
    for i, v in ipairs(type2List) do
        local list = {}
        list.bg = transform:Find(string.format("Container/bg/mission list/content 1/Scroll View/Table/%s", v))
        list.panel = transform:Find("Container/bg/mission list/content 1/Scroll View"):GetComponent("UIPanel")
        list.table = transform:Find(string.format("Container/bg/mission list/content 1/Scroll View/Table/%s/Table", v)):GetComponent("UITable")
        UIUtil.AddDelegate(list.table, "onReposition", function()
            if _ui then
                _ui.mainMissionList.table:Reposition()
            end
        end)
        _ui.mainMissionList[i] = list
    end

    _ui.mainMissionList.notice = transform:Find("Container/bg/mission list/page1/red dot")

    _ui.toggleList = {}
    for i = 1, 4 do
        local uiToggle = transform:Find(string.format("Container/bg/mission list/page%d", i)):GetComponent("UIToggle")
        EventDelegate.Add(uiToggle.onChange, EventDelegate.Callback(function()
            if _ui ~= nil then
                if uiToggle.value then
                    if i == 3 or i == 4 then
                        if MilitaryActionData.HasRefreshNotice() then
                            MilitaryActionData.CancelRefreshNotice(i - 2)
                        end
                    end
                    if i == 4 then
                        local hasUnion = UnionInfoData.HasUnion()
                        if not hasUnion then
                            JoinUnion.Show(function()
                                if UnionInfoData.HasUnion() then
                                    MissionUI.Show(4)
                                else
                                    MissionUI.Show(_ui.oldToggleIndex)
                                end
                            end)
                        end
                    end
                else
                    if UnionInfoData.HasUnion() or i ~= 4 then
                        _ui.oldToggleIndex = i
                    end
                end
            end
        end))
        _ui.toggleList[i] = uiToggle
    end

    _ui.dailyPrefab = ResourceLibrary.GetUIPrefab("Mission/listitem_dailymission")
    _ui.dailayTimeLabel = transform:Find("Container/bg/mission list/content 2/CountDown/Label"):GetComponent("UILabel")
    _ui.activePointLabel = transform:Find("Container/bg/mission list/content 2/bg_reward/icon_star/num"):GetComponent("UILabel")
    _ui.activePointSlider = transform:Find("Container/bg/mission list/content 2/bg_reward/bg_schedule/bg_slider"):GetComponent("UISlider")
    _ui.dailyMissionNotice = transform:Find("Container/bg/mission list/page2/red dot")
    local chestList = {}
    for i = 1, 6 do
        local chest = {}
        local chestTransform = transform:Find(string.format("Container/bg/mission list/content 2/bg_reward/icon_item%d", i))
        chest.transform = chestTransform
        chest.iconButton = chestTransform:Find("icon"):GetComponent("UIButton")
        chest.activePointLabel = chestTransform:Find("num"):GetComponent("UILabel")
        chest.effect = chestTransform:Find("icon/ShineItem").gameObject
        chest.tweenerList = chest.iconButton.transform:GetComponents(typeof(UITweener))
        chestList[i] = chest
    end
    _ui.chestList = chestList

    _ui.dailyScrollView = transform:Find("Container/bg/mission list/content 2/Scroll View"):GetComponent("UIScrollView")
    _ui.dailyGrid = transform:Find("Container/bg/mission list/content 2/Scroll View/Grid"):GetComponent("UIGrid")



    local closeButton = transform:Find("Container/close btn"):GetComponent("UIButton")
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()Hide()end)
    _ui.missionPrefab = ResourceLibrary.GetUIPrefab("Mission/listitem_mission")
    _ui.itemRewardPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.moneyRewardPrefab = ResourceLibrary.GetUIPrefab("Mission/listitem_money")

    local actionList = {}
    for i = 1, 2 do
        local list = {}
        local pageIndex = i == 1 and 3 or 4
        list.notice = transform:Find(string.format("Container/bg/mission list/page%d/red dot", pageIndex))
        list.tileGameObject = transform:Find(string.format("Container/bg/mission list/content %d/bg titel", pageIndex)).gameObject
        local resetButton = transform:Find(string.format("Container/bg/mission list/content %d/bg titel/btn refurbish", pageIndex))
        UIUtil.SetClickCallback(resetButton.gameObject, function()
            local cost = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId["MilitaryRefrushCost" ..i]).value)

            MessageBox.Show(System.String.Format(TextMgr:GetText("military_12"), cost), function()
                local req = ClientMsg_pb.MsgOnlineTaskResetRequest();
                req.type = i
                Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgOnlineTaskResetRequest, req, ClientMsg_pb.MsgOnlineTaskResetResponse, function(msg)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.ShowError(msg.code)
                    else
                        MainCityUI.UpdateRewardData(msg.freshInfo)
                        MilitaryActionData.RequestData()
                        GUIMgr:SendDataReport("purchase", "costgold", "ResetMilitaryList", "1", "" ..MoneyListData.ComputeDiamond(msg.freshInfo.money.money))
                    end
                end)
            end, 
            function() 

            end)
        end)
        list.panel = transform:Find(string.format("Container/bg/mission list/content %d/Scroll View", pageIndex)):GetComponent("UIPanel")
        list.scrollView = transform:Find(string.format("Container/bg/mission list/content %d/Scroll View", pageIndex)):GetComponent("UIScrollView")
        list.table = transform:Find(string.format("Container/bg/mission list/content %d/Scroll View/Table", pageIndex)):GetComponent("UITable")
        list.emptyGameObject = transform:Find(string.format("Container/bg/mission list/content %d/no one", pageIndex)).gameObject
        list.timeLabel = transform:Find(string.format("Container/bg/mission list/content %d/bg titel/time", pageIndex)):GetComponent("UILabel")
        actionList[i] = list
    end

    _ui.actionList = actionList

    _ui.actionPrefab = ResourceLibrary.GetUIPrefab("Mission/listitem_mission_time")

    _ui.rewardList = {}

    MissionListData.AddListener(LoadMainMission)
    MissionListData.AddListener(LoadDailyMission)
    MilitaryActionData.AddListener(LoadAction)
    UnionInfoData.AddListener(CheckLeaveUnion)

    local page2 = transform:Find("Container/bg/mission list/page2").gameObject
    page2:SetActive(false)
    FunctionListData.IsFunctionUnlocked(115, function(isactive)
        if _ui ~= nil then
            page2:SetActive(isactive)
        end
    end)

    local page3 = transform:Find("Container/bg/mission list/page3").gameObject
    page3:SetActive(false)
    local page4 = transform:Find("Container/bg/mission list/page4").gameObject
    page4:SetActive(false)
    FunctionListData.IsFunctionUnlocked(109, function(isactive)
        if _ui ~= nil then
            page3:SetActive(isactive)
            page4:SetActive(isactive and UnionInfoData.HasUnion())
        end
    end)
end

function LateUpdate()
    if _ui == nil then
        return
    end
    if _ui.toggleList[3].value or _ui.toggleList[4].value then
        for k, v in pairs(_ui.sliderList) do
            local endTime = v[2].starttime + v[2].totoaltime
            local leftCooldownSecond = Global.GetLeftCooldownSecond(endTime)
            if leftCooldownSecond > 0 then
                v[1].value = 1 - Global.GetLeftCooldownMillisecond(endTime) / (v[2].totoaltime * 1000)
            else
                _ui.sliderList[k] = nil
            end
        end
    end
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            _ui.dailayTimeLabel.text = Format(TextMgr:GetText(Text.DailyMission_CountDown), Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown()))
            local actionMsg = MilitaryActionData.GetData()

            for _, v in ipairs(_ui.actionList) do
                v.timeLabel.text = Global.GetLeftCooldownTextLong(actionMsg.freshstarttime + actionMsg.freshtotaltime)
            end
        end
    end
end

function Close()
    coroutine.stop(_ui.loadListCoroutine)
    MissionListData.RemoveListener(LoadMainMission)
    MissionListData.RemoveListener(LoadDailyMission)
    MilitaryActionData.RemoveListener(LoadAction)
    UnionInfoData.RemoveListener(CheckLeaveUnion)
    _ui = nil
end

function Show(toggleIndex)
    toggleIndex = toggleIndex or 1
    if toggleIndex == 4 and not UnionInfoData.HasUnion() then
        toggleIndex = 1
    end
    Global.OpenUI(_M)
    for i, v in ipairs(_ui.toggleList) do
        v.value = i == toggleIndex
    end
    LoadUI()
end
