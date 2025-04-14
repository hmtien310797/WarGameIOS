module("Tutorial", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local SetPressCallback = UIUtil.SetPressCallback
local GameTime = Serclimax.GameTime
local DebugPrint

local enable = true

local debug = false
local debugId = 0

local tutorialUI
tutorialList = nil
local currentPointerBg = nil
local currentHideModule
local targetUIElement = nil
local currentCheckVisibleFunc
local fingerTimer
local closeTimer
local currentTutorial
local zeroPos
local handLerpTime = 0
local handLerpScale = 1 / 0.8
local auto
local autoTimer

local CheckTrigger

function SetDebugId(id)
    debugId = tonumber(id)
end

function SetDebug(flag)
    debug = flag
end

function SetAuto(a)
    auto = a
end

function IsAuto()
    return auto
end

local function AutoClickCamera()
    coroutine.start(function()
        WaitForRealSeconds(autoDelay)
        UICamera.onClick:DynamicInvoke(nil)
    end)
end

local function IsAlwaysTrigger(data)
    local moduleId = data.moduleId
    local firstData = tutorialList[moduleId][1].data

    if not firstData.alwaysTrigger then
        if debugId == data.id then
            DebugPrint("校验反复触发失败, alwaysTrigger字段为false, id:", data.id)
        end
        return false
    end

    local levelId = tonumber(firstData.conditionParam) or 0
    local missionId = firstData.mission

    if levelId == 0 and missionId == 0 then
        if debugId == data.id then
            DebugPrint("校验反复触发失败, 任务id和关卡id都为0, id:", data.id)
        end
        return false
    end

    local conditionType = firstData.conditionType
    if levelId ~= 0 and conditionType ~= 2 then
        if debugId == data.id then
            DebugPrint("校验反复触发失败, 条件类型不为2, id:", data.id)
        end
        return false
    end

    if levelId ~= 0 and ChapterListData.HasLevelExplored(levelId) then
        if debugId == data.id then
            DebugPrint("校验反复触发失败, 对应关卡已完成, id:", data.id)
        end
        return false
    end

    if missionId ~= 0 and firstData.missionState ~= 0  then
        if debugId == data.id then
            DebugPrint("校验反复触发失败, 任务状态不为0, id:", data.id)
        end
        return false
    end

    if missionId ~= 0 and MissionListData.GetMissionData(missionId) == nil then
        if debugId == data.id then
            DebugPrint("校验反复触发失败, 目前没有对应的任务, id:", data.id)
        end
        return false
    end

    return true
end

local function CheckMaskDelay(maskDelay)
    if maskDelay > 0 then
        Global.ShowTopMask(maskDelay)
    end
end

function Hide(maskDelay)
    if currentHideModule ~= nil then
        currentHideModule.gameObject:SetActive(true)
    end
    for i, v in pairs(tutorialUI.avatar) do
        v.bg.gameObject:SetActive(false)
    end
    Global.CloseUI(_M)
    currentTutorial = nil
    CheckMaskDelay(maskDelay)
end

local function Save()
    local tutorialConfig = ConfigData.GetTutorialConfig()
    for k, v in pairs(tutorialList) do
        if v.finished and v.needSave then
            table.insert(tutorialConfig, k)
        end
    end
    tutorialConfig = table.unique(tutorialConfig)
    ConfigData.SetTutorialConfig(tutorialConfig)
end

function PrintAll()
    local tutorialConfig = ConfigData.GetTutorialConfig()
    for _, v in ipairs(tutorialConfig) do
        DebugPrint(v)
    end
end

function UnFinish(moduleId)
    local tutorialConfig = ConfigData.GetTutorialConfig()
    for i, v in ipairs(tutorialConfig) do
        if v == moduleId then
            tutorialConfig[i] = nil
            break
        end
    end
    ConfigData.SetTutorialConfig(tutorialConfig)
end

function Dump(id)
    for k, v in pairs(tutorialList) do
        for __, vv in ipairs(v) do
            if id == nil or id == vv.data.id then
                DebugPrint(string.format("id:%d, triggered:%s, data triggerType:%d, data trigger param:%s", vv.data.id, vv.triggered, vv.data.triggerType, vv.data.triggerParam))
            end
        end
    end
end

local TriggerTutorial
local function CheckNextTutorial(tutorial)
    local data = tutorial.data
    local moduleId = data.moduleId
    local moduleSubId = data.moduleSubId

    local nextTutorial = tutorialList[moduleId][moduleSubId + 1]
    if nextTutorial ~= nil and nextTutorial.data.triggerType == 0 then
        local maskDelay = data.maskDelay
        CheckMaskDelay(maskDelay)
        TriggerTutorial(nextTutorial)
    end
end

function FinishModule(moduleId)
    if tutorialList[moduleId] ~= nil then
        tutorialList[moduleId].finished = true
        Save()
    end
end

function SendReport(moduleId, moduleSubId)
    --send data report-----------------------
    GUIMgr:SendDataReport("tutorial", "" .. moduleId, "completed", "0")
    -----------------------------------------
    local req = ClientMsg_pb.MsgGameGuideRequest()
    req.guideId = moduleId * 1000 + moduleSubId
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGameGuideRequest, req, ClientMsg_pb.MsgGameGuideResponse, function(msg)
    end, true)
end

--检查引导是否已经完成
local function CheckFinished(tutorial)
    local data = tutorial.data
    local moduleId = data.moduleId
    local moduleSubId = data.moduleSubId
    local lastSubModule = moduleSubId == #tutorialList[moduleId]
    if lastSubModule then
        if moduleId == 10601 then
            Event.Check(8)
        elseif moduleId == 10905 then
            --Event.Check(13)
        end
    end

    local finished = data.guideEnd == 1 or lastSubModule
    if finished then        
        DebugPrint("完成新手引导模块moduleId:", moduleId)
        SceneStory.ResumeStory("WaitFinishTutorial", moduleId)
        if moduleId == 99999 then
            return
        elseif moduleId == 10000 then
            -- MapMask.Move()
            Tutorial.TriggerModule(10001)
            return
        elseif moduleId == 10001 then
            MapMask.MoveBase()
            return
        elseif moduleId == 10002 then
            MapMask.Attack()
            return
        elseif moduleId == 10003 then
            StoryPicture.Hide()
            return
        elseif moduleId == 10100 then
            Event.Resume(2)
            return
        elseif moduleId == 10200 then
            Event.Resume(3)
            return
        elseif moduleId == 10300 then
            Event.Resume(4)
            return
        elseif moduleId == 10400 then
            Event.Resume(5)
            return
        elseif moduleId == 10500 then
            Event.Resume(6)
            return
        elseif moduleId == 10501 then
            return
        elseif moduleId == 10600 then
            Event.Resume(7)
            return
        elseif moduleId == 10601 then
            Event.Resume(7)
            return
        elseif moduleId == 10700 then
            Event.Resume(8)
            return
        elseif moduleId == 10800 then
            Event.Resume(9)
            return
        elseif moduleId == 10801 then
            StoryPicture.Hide()
            Event.Resume(9)
            return
        elseif moduleId == 10802 then
            StoryPicture.Hide()
            Event.Resume(9)
            return
        elseif moduleId == 10803 then
            StoryPicture.Hide()
            Event.Resume(9)
            return
        elseif moduleId == 10902 then
            Event.Resume(10)
            return
        elseif moduleId == 10907 then
            Event.Resume(14)
            return
        elseif moduleId == 10911 then
            Event.Resume(18)
            return
        elseif moduleId == 10912 then
            Event.Resume(18)
            return
        elseif moduleId > 10912 then
            if moduleId == 10919 then
                Event.Resume(25)
            elseif moduleId == 10925 then
                --Event.Check(33)
            elseif moduleId == 10927 then
                Event.Resume(33)
            elseif moduleId == 10933 then
                Event.Resume(39)
            elseif moduleId == 10943 then
                Event.Resume(46)
            end
            return
        end

        if not IsAlwaysTrigger(data) then
            FinishModule(moduleId)
            SendReport(moduleId, moduleSubId)
        end

        if data.nextModuleId ~= 0 then
            local nextTutorial = tutorialList[data.nextModuleId] ~= nil and tutorialList[data.nextModuleId][1] or nil
            if nextTutorial ~= nil then
                local maskDelay = data.maskDelay
                CheckMaskDelay(maskDelay)
                TriggerTutorial(nextTutorial)
            end
        end
    end
end

local function GetUIElement(data)
    local triggerType = data.triggerType
    if triggerType == 2 then
        local menuButton = MainCityUI.GetCityMenuBtnByType(data.uiElement)
        if menuButton ~= nil then
            return menuButton.transform
        end
    elseif triggerType == 5 then
        local unlockButton = MainCityUI.GetBuildingUnlockBtnMatch(data.triggerParam)
        if unlockButton ~= nil then
            return unlockButton.transform
        end
    elseif triggerType == 6 then
        local freeButton = MainCityUI.GetBuildingFreeBtnMatch(data.triggerParam)
        if freeButton ~= nil then
            return freeButton.transform
        end
    elseif triggerType == 7 then
        local resButton = maincity.GetResBtnMatch(data.triggerParam)
        if resButton ~= nil then
            return resButton.transform
        end
    elseif triggerType == 10 then
        local ziyuantian = maincity.GetEmptyZiyuantian()
        if ziyuantian ~= nil then
            return ziyuantian.land
        end
    elseif triggerType == 11 then
        local building = maincity.GetBuildingMatch(data.triggerParam)
        if building ~= nil then
            return building.land
        end
    else
        if data.uiPage == "building" then
            local building = maincity.GetBuildingMatch(data.uiElement)
            if building ~= nil then
                return building.land
            end
        elseif data.uiPage == "free_btn" then
            local freeButton = MainCityUI.GetBuildingFreeBtnMatch(data.uiElement)
            if freeButton ~= nil then
                return freeButton.transform
            end
        else
            local module = _G[data.uiPage]
            if module ~= nil and GUIMgr:IsMenuOpen(data.uiPage) then
                return module.transform:Find(data.uiElement)
            end
        end
    end

    return nil
end

local function LoadUI(tutorial)
    local data = tutorial.data
    if debug then
        DebugPrint("设置引导界面id", data.id)
    end
    currentTutorial = tutorial
    currentTutorial.clickCount = 0
    fingerTimer = 0
    closeTimer = 0
    autoTimer = 0
    currentPointerBg = nil
    currentCheckVisibleFunc = nil
    targetUIElement = nil
    local hideDialog = data.hideDialog
    local maskDelay = data.maskDelay
    currentHideModule = _G[hideDialog]
    canBeReplace = data.replace
    if currentHideModule ~= nil then
        currentHideModule.gameObject:SetActive(false)
    end

    local avatarType = data.avatarType
    local guideType = data.guideType
    local triggerType = data.triggerType
    if debug then
        DebugPrint("avatarType:", avatarType, "guideType:", guideType, "triggerType:", triggerType)
    end
    for i, v in pairs(tutorialUI.avatar) do
        v.bg.gameObject:SetActive(false)
        if i == avatarType then
            if debug then
                if avatarType == 1 then
                    DebugPrint("打开手指指向")
                elseif avatarType == 2 then
                    DebugPrint("打开左边人物对话")
                elseif avatarType == 3 then
                    DebugPrint("打开右边人物对话")
                elseif avatarType == 8 then
                    DebugPrint("打开右边人物对话2")
                elseif avatarType == 4 then
                    DebugPrint("打开左边箭头指向")
                elseif avatarType == 5 then
                    DebugPrint("打开右边箭头指向")
                end
            end
            local pointer = tutorialUI.avatar[avatarType].pointer
            local uiElement = nil
            if pointer ~= nil then
                if triggerType == 2 then
                    local menuButton = MainCityUI.GetCityMenuBtnByType(data.uiElement)
                    if menuButton ~= nil then
                        uiElement = menuButton.transform
                    end
                elseif triggerType == 5 then
                    local unlockButton = MainCityUI.GetBuildingUnlockBtnMatch(data.triggerParam)
                    if unlockButton ~= nil then
                        uiElement = unlockButton.transform
                    end
                elseif triggerType == 6 then
                    local freeButton = MainCityUI.GetBuildingFreeBtnMatch(data.triggerParam)
                    if freeButton ~= nil then
                        uiElement = freeButton.transform
                    end
                elseif triggerType == 7 then
                    local resButton = maincity.GetResBtnMatch(data.triggerParam)
                    if resButton ~= nil then
                        uiElement = resButton.transform
                    end
                elseif triggerType == 10 then
                    local ziyuantian = maincity.GetEmptyZiyuantian()
                    if ziyuantian ~= nil then
                        uiElement = ziyuantian.land
                    end
                elseif triggerType == 11 then
                    local building = maincity.GetBuildingMatch(data.triggerParam)
                    if building ~= nil then
                        uiElement = building.land
                    end
                else
                    if data.uiPage == "building" then
                        local building = maincity.GetBuildingMatch(data.uiElement)
                        if building ~= nil then
                            uiElement = building.land
                        end
                    elseif data.uiPage == "free_btn" then
                        local freeButton = MainCityUI.GetBuildingFreeBtnMatch(data.uiElement)
                        if freeButton ~= nil then
                            uiElement = freeButton.transform
                        end
                    else
                        local module = _G[data.uiPage]
                        if module ~= nil and module.transform ~= nil and not module.transform:Equals(nil) and GUIMgr:IsMenuOpen(data.uiPage) then
                            local checkVisibleFunc = data.checkVisibleFunc
                            currentCheckVisibleFunc = module[checkVisibleFunc]
                            uiElement = module.transform:Find(data.uiElement)
                        else
                            v.bg.gameObject:SetActive(true)
                            v.bg.localPosition = Vector3.zero
                            DebugPrint("找不到引导!!!!!!!!!!!uiPage:    "..data.uiPage)
                        end
                    end
                end
                currentPointerBg = v.bg
                if uiElement ~= nil then
                    targetUIElement = uiElement
                else
                    v.bg.gameObject:SetActive(true)
                    v.bg.localPosition = Vector3.zero
                    DebugPrint(data.uiPage.." 找不到引导!!!!!!!!!!!!!!!uiElement:     "..data.uiElement)
                end
            end

            if avatarType == 1 then
                v.hand.gameObject:SetActive(true)
            elseif avatarType == 2 or avatarType == 3 or avatarType == 8 then
                if debug then
                    DebugPrint("人物对话类型打开背景")
                end
                v.bg.gameObject:SetActive(true)
                if avatarType == 8 then
                    v.iconPicture.mainTexture = ResourceLibrary:GetIcon("Icon/Bg/", data.headIcon)
                    v.nameLabel.text = TextMgr:GetText(data.headname)
                end
            end

            if v.text ~= nil then
                local text = TextMgr:GetText(data.textId)
                text = string.gsub(text, "{playername}", MainData.GetCharName())
                v.text.text = text
                if v.typewriterEffect ~= nil and v.typewriterEffect.isActive then
                    v.typewriterEffect:ResetToBeginning()
                end
            end

            local moduleId = data.moduleId
            local moduleSubId = data.moduleSubId

            --检查是否可以自动触发下一引导
            if guideType == 0 then
                if debug then
                    DebugPrint("对话强指引")
                end
                --强引导打开mask
                tutorialUI.mask.gameObject:SetActive(true)
            elseif guideType == 1 or guideType == 2 then
                if debug then
                    if guideType == 1 then
                        DebugPrint("手指或箭头强指引")
                    else
                        DebugPrint("弱指引(手指或箭头无遮罩)")
                    end
                end
                --强引导打开mask
                tutorialUI.mask.gameObject:SetActive(guideType == 1)

                --弱引导关闭手指
                if v.hand ~= nil then
                    v.hand.gameObject:SetActive(guideType == 1)
                end
            end
        end
    end
end

function CheckWorldMapClick(data)
    if data.uiPage == "WorldMap" and data.uiElement == "Container/map_bg" then
        WorldMap.ShowCenterInfo()
        return true
    end

    return false
end

function Awake()
    tutorialUI = {}
    tutorialUI.container = transform:Find("Container")
    tutorialUI.mask = transform:Find("Container/mask")
    tutorialUI.waitActive = transform:GetComponent("WaitActive")
    local avatar = {}

    local hand = {}
    hand.bg = transform:Find("Container/hand widget")
    hand.hand = transform:Find("Container/hand widget/hand")
    hand.pointer = transform:Find("Container/hand widget/Sprite")
    hand.hint = transform:Find("Container/hand widget/effect")
    hand.defaultHandPosition = hand.hand.localPosition
    avatar[1] = hand

    local leftPerson = {}
    leftPerson.bg = transform:Find("Container/bg_left person")
    leftPerson.text = transform:Find("Container/bg_left person/bg/text_guide"):GetComponent("UILabel")
    leftPerson.typewriterEffect = leftPerson.text:GetComponent("TypewriterEffect")
    avatar[2] = leftPerson

    local rightPerson = {}
    rightPerson.bg = transform:Find("Container/bg_right person")
    rightPerson.text = transform:Find("Container/bg_right person/bg/text_guide"):GetComponent("UILabel")
    rightPerson.typewriterEffect = rightPerson.text:GetComponent("TypewriterEffect")
    avatar[3] = rightPerson

    local leftArrow = {}
    leftArrow.bg = transform:Find("Container/left arrow")
    leftArrow.text = transform:Find("Container/left arrow/Label"):GetComponent("UILabel")
    leftArrow.pointer = transform:Find("Container/left arrow/Sprite")
    leftArrow.hint = transform:Find("Container/left arrow/effect")
    avatar[4] = leftArrow

    local rightArrow = {}
    rightArrow.bg = transform:Find("Container/right arrow")
    rightArrow.text = transform:Find("Container/right arrow/Label"):GetComponent("UILabel")
    rightArrow.pointer = transform:Find("Container/right arrow/Sprite")
    rightArrow.hint = transform:Find("Container/right arrow/effect")
    avatar[5] = rightArrow

    local rightPerson2 = {}
    rightPerson2.bg = transform:Find("Container/bg_right person2")
    rightPerson2.text = transform:Find("Container/bg_right person2/bg/text_guide"):GetComponent("UILabel")
    rightPerson2.typewriterEffect = rightPerson2.text:GetComponent("TypewriterEffect")
    rightPerson2.iconPicture = transform:Find("Container/bg_right person2/bg/icon_guide"):GetComponent("UITexture")
    rightPerson2.nameLabel = transform:Find("Container/bg_right person2/bg/bg_name/text_name"):GetComponent("UILabel")
    avatar[8] = rightPerson2

    for _, v in pairs(avatar) do
        if v.pointer ~= nil then
            SetClickCallback(v.pointer.gameObject, function()
                if currentTutorial == nil then
                    return
                end

                local tutorial = currentTutorial
                local data = tutorial.data
                local maskDelay = data.maskDelay
                Hide(maskDelay)
                CheckFinished(tutorial)
                CheckNextTutorial(tutorial)
                if not CheckWorldMapClick(data) then
                    local ue = GetUIElement(data)
                    if ue ~= nil then
                        UICamera.Notify(ue.gameObject, "OnClick", nil)
                        UICamera.Notify(ue.gameObject, "OnPress", true)
                        UICamera.Notify(ue.gameObject, "OnPress", false)
                    end
                end
            end)
        end
    end
    SetClickCallback(tutorialUI.mask.gameObject, function()
        if currentTutorial == nil then
            return
        end

        local tutorial = currentTutorial
        tutorial.clickCount = tutorial.clickCount + 1
        local data = tutorial.data
        local maskDelay = data.maskDelay
        local guideType = data.guideType
        local avatarType = data.avatarType
        if (avatarType == 2 or avatarType == 3 or avatarType == 8) and tutorial.clickCount == 1 and tutorialUI.avatar[avatarType].typewriterEffect.isActive then
            tutorialUI.avatar[avatarType].typewriterEffect:Finish()
        else
            if avatarType == 1 or avatarType == 4 or avatarType == 5 then
                local hintObject = tutorialUI.avatar[avatarType].hint.gameObject
                hintObject:SetActive(false)
                hintObject:SetActive(true)
                UITweener.PlayAllTweener(hintObject, true , true , true)
            end

            if guideType == 0 then
                AudioMgr:PlayUISfx("SFX_ui01", 1, false)
                Hide(maskDelay)
                CheckFinished(tutorial)
                CheckNextTutorial(tutorial)
            end
        end
    end)
    tutorialUI.avatar = avatar
end

function Show(tutorial)
    Global.OpenTopUI(_M)
    LoadUI(tutorial)
end

function TriggerTutorial(tutorial)
    if ServerListData.IsAppleReviewing() then
        return
    end

    if currentTutorial ~= nil and currentTutorial == tutorial then
        return
    end
    if not enable then
        return
    end

    local data = tutorial.data
    if data.id == debugId then
        --UnityEngine.Debug.Break()
    end
    DebugPrint("触发新手引导 id:", data.id, "moduleId:", data.moduleId)
    tutorial.triggered = true
    Show(tutorial)
    local avatarType = data.avatarType
    if avatarType == 6 then
        local conditionType = data.conditionType
        if conditionType == 4 then
            local monsterLevel = tonumber(data.conditionParam)
            WorldMapData.RequestCreateMonster(monsterLevel, function(pos)
                DebugPrint("设置引导坐标:", pos.x, pos.y)
                WorldMap.TutorialTile(pos.x, pos.y)
                CheckNextTutorial(tutorial)
            end)
        end
    elseif avatarType == 7 then
        local conditionType = data.conditionType
        if conditionType == 5 then
            local conditionList = string.split(data.conditionParam, ",")
            local resourceType = tonumber(conditionList[1])
            local resourceNum = tonumber(conditionList[2])
            WorldMapData.RequestCreateResource(resourceType, resourceNum, function(pos)
                DebugPrint("设置引导坐标:", pos.x, pos.y)
                WorldMap.TutorialTile(pos.x, pos.y)
                CheckNextTutorial(tutorial)
            end)
        end
    end
end

function TriggerModule(moduleId)
    local tutorialModule = tutorialList[moduleId]
    if tutorialModule ~= nil then
        tutorialModule.finished = false
        for _, v in ipairs(tutorialModule) do
            v.triggered = false
        end

        local tutorial = tutorialModule[1]
        if tutorial ~= nil then
            TriggerTutorial(tutorial)
            return true
        end
    end
    return false
end

function CheckMission(data, missionMsg)
    local missionId = data.mission
    if missionId == 0 then
        return true
    end

    if missionMsg == nil then
        missionMsg = MissionListData.GetMissionData(missionId)
    end

    if missionMsg == nil then
        if debugId == data.id then
            DebugPrint("引导任务校验失败！任务不存在:id", data.id)
        end
        return false
    end

    local missionData = TableMgr:GetMissionData(missionId)
    if data.missionState == 1 then
        if debugId == data.id then
            if missionMsg.value < missionData.number then
                DebugPrint("引导任务校验失败！任务未完成:id", data.id)
            end
        end
        return missionMsg.value >= missionData.number
    else
        if debugId == data.id then
            if missionMsg.value >= missionData.number then
                DebugPrint("引导任务校验失败！任务已完成:id", data.id)
            end
        end
        return missionMsg.value < missionData.number
    end
end

function CheckPrevTutorial(data)
    local moduleId = data.moduleId
    local moduleSubId = data.moduleSubId
    if moduleSubId ~= 1 then
        local prevTutorial = tutorialList[moduleId][moduleSubId - 1]
        if not prevTutorial.triggered then
            if debugId == data.id then
                DebugPrint("前置任务校验失败！前置引导未触发id:", data.id)
            end
            return false
        end
    end
    local prevModuleId = data.prevModuleId
    if debugId == data.id then
        if prevModuleId ~= 0 and not ConfigData.HasTutorialFinished(prevModuleId) then
            DebugPrint("前置任务校验失败！前置模块未完成:id", data.id)
        end
    end
    return prevModuleId == 0 or ConfigData.HasTutorialFinished(prevModuleId)
end

function CheckCondition(data)
    local conditionType = data.conditionType
    local conditionParam = data.conditionParam
    if conditionType == 0 or conditionType == 4 or conditionType == 5 then
        return true
    elseif conditionType == 1 then
        if conditionParam == "0" then
            return not SceneManager.instance.GameWin
        else
            return SceneManager.instance.GameWin
        end
    elseif conditionType == 2 then
        return ChapterListData.IsLevelExploring(tonumber(conditionParam))
    elseif conditionType == 3 then
        return ChapterListData.HasLevelExplored(tonumber(conditionParam))
    elseif conditionType == 6 then
        return Barrack.GetArmyNum() >= tonumber(conditionParam)
    end
end

function CheckTriggered(tutorial, data)
    if GUIMgr:IsTopMenuOpen(_NAME) then
        if (currentTutorial == nil) or (not currentTutorial.data.replace) then
            if debugId == data.id then
                DebugPrint("引导触发状态校验失败！已经有引导，并且无法被替换id:", data.id)
            end
            return false
        end
    end

    if data.moduleId ~= 99999 and tutorial.triggered and not IsAlwaysTrigger(data) then
        if debugId == data.id then
            DebugPrint("引导触发状态校验失败！已经触发过，并且不是永远触发id:", data.id)
        end
        return false
    end

    local triggerType = data.triggerType
    if triggerType == 1 and data.top then
        local topMenu = GUIMgr:GetTopNotTutorialMenuOnRoot()
        if topMenu == nil or topMenu.name ~= data.triggerParam then
            if debugId == data.id then
                DebugPrint("引导触发状态校验失败！不是最顶端界面id:", data.id)
            end
            return false
        end
    end

    if triggerType == 5 or triggerType == 6 or triggerType == 7 or triggerType == 11 or (triggerType == 0 and data.uiPage == "building") or data.uiPage == "free_btn" then
        local topMenu = GUIMgr:GetTopNotTutorialMenuOnRoot()
        if topMenu == nil or topMenu.name ~= "MainCityUI" then
            if debugId == data.id then
                DebugPrint("引导触发状态校验失败！不是最顶端界面id:", data.id)
            end
            return false
        end
    end
    return true
end

function CheckTriggerTypeParam(data, triggerType, triggerParam)
    if data.triggerType == 0 then
        if debugId == data.id then
            DebugPrint("该引导为自动触发，校验失败:id", data.id)
        end
        return false
    end

    if data.triggerType ~= triggerType then
        if debugId == data.id then
            DebugPrint("触发类型校验失败:id", data.id, "triggerType:", triggerType, "data triggerType:", data.triggerType)
        end
        return false
    end

    if triggerType ~= 2 and triggerType ~= 5 and triggerType ~= 6 and triggerType ~= 7 then
        if data.triggerParam ~= triggerParam then
            if debugId == data.id then
                DebugPrint("触发参数校验失败:id", data.id)
            end
            return false
        end
    else
        if string.match(triggerParam, data.triggerParam) == nil then
            if debugId == data.id then
                DebugPrint("触发参数校验失败:id", data.id, "triggerParam:", triggerParam, "data triggerParam:", data.triggerParam)
            end
            return false
        end
    end

    return true
end

function CheckEvent(data)
    local eventId = data.eventId
    if eventId == 0 or Event.IsActive(eventId) then
        return true
    else
        if debugId == data.id then
            DebugPrint("事件关联校验失败:id", data.id, "eventId:", eventId)
        end
        return false
    end
end

CheckTrigger = function(triggerType, triggerParam)
    for _, v in pairs(tutorialList) do
        for __, vv in ipairs(v) do
            local data = vv.data
            if debugId == data.id then
                DebugPrint(string.format("检测引导触发，id: %d triggered:%s, data triggerType:%d, trigger type:%d, data trigger param:%s, trigger param:%s", data.id, vv.triggered, data.triggerType, triggerType, data.triggerParam, triggerParam))
            end
            if CheckEvent(data) and CheckTriggerTypeParam(data, triggerType, triggerParam) and CheckTriggered(vv, data) and CheckPrevTutorial(data) and CheckMission(data) and CheckCondition(data) then
                TriggerTutorial(vv)
            end
        end
    end
end

function Init()
    if not Global.IsDistVersion() then
        DebugPrint = print
    else
        DebugPrint = function(...)
        end
    end
    tutorialList = {}
    local dataList = TableMgr:GetTutorialDataList()
    local tutorialConfig = ConfigData.GetTutorialConfig()

    --检查模式是否完成
    local function HasFinished(moduleId)
        for _, v in ipairs(tutorialConfig) do
            if v == moduleId then
                return true
            end
        end
        return false
    end

    --加载所有未完成的引导
	for i, v in pairs(dataList) do
        local moduleId = v.moduleId
        --未完成的引导加入引导列表
        if not HasFinished(moduleId) then
            local moduleSubId = v.moduleSubId
            if tutorialList[moduleId] == nil then
                tutorialList[moduleId] = {needSave = v.eventId == 0}
            end
            local tutorial = tutorialList[moduleId]
            local subTutorial = {}
            subTutorial.data = v
            tutorial[moduleSubId] = subTutorial
        end
	end
	
    --设置触发回调
    UIUtil.AddDelegate(GUIMgr, "onMenuCreate", function(menuName)
        if debug then
            DebugPrint("打开界面:", menuName)
        end
        CheckTrigger(1, menuName)
    end)
    UIUtil.AddDelegate(GUIMgr, "onMenuClose", function(menuName)
        if debug then
            DebugPrint("关闭界面:", menuName)
        end
        CheckTrigger(4, menuName)
        if menuName ~= "Tutorial" then
            local topMenu = GUIMgr:GetTopNotTutorialMenuOnRoot()
            if topMenu ~= nil then
                if debug then
                    DebugPrint("打开界面:", topMenu.name)
                end
                CheckTrigger(1, topMenu.name)
            end
        end
    end)
    maincity.AddLocateLandListener(function(landName)
        if debug then
            DebugPrint("定位地块:", landName)
        end
        CheckTrigger(5, landName)
        CheckTrigger(6, landName)
        CheckTrigger(7, landName)
    end)
    MainCityUI.AddCityMenuListener(function(landName)
        if debug then
            DebugPrint("打开地块菜单:", landName)
        end
        CheckTrigger(2, landName)
    end)
    MissionListData.AddListener(function()
        local topMenu = GUIMgr:GetTopNotTutorialMenuOnRoot()
        if topMenu ~= nil then
            if debug then
                DebugPrint("任务状态改变,顶端界面:", topMenu.name)
            end
            CheckTrigger(1, topMenu.name)
        end
    end)
    PlayerLevelup.AddListener(function()
        local currentLevel = tostring(PlayerLevelup.GetCurrentLevel())
        CheckTrigger(8, currentLevel)
    end)
    BuildingLevelup.AddListener(function()
        local baseLevel = tostring(BuildingData.GetCommandCenterData().level)
        CheckTrigger(9, baseLevel)
    end)
    UIUtil.AddDelegate(GUIMgr, "onTutorialTriggered", function(menuName)
        if debug then
            DebugPrint("脚本触发引导:", menuName)
        end
        CheckTrigger(10, menuName)
    end)
end

function Test(id)
    for _, v in pairs(tutorialList) do
        for __, vv in ipairs(v) do
            if vv.data.id == id then
                TriggerTutorial(vv)
                return
            end
        end
    end
end

function LateUpdate()
    if auto then
        autoTimer = autoTimer + GameTime.deltaTime
    end

    if currentPointerBg ~= nil then
        local data = currentTutorial.data
        local targetVisible = false
        if targetUIElement == nil or targetUIElement:Equals(nil) then
            targetUIElement = GetUIElement(data)
        end
        if targetUIElement ~= nil and not targetUIElement:Equals(nil) then
            if data.triggerType == 10 or data.triggerType == 11 or (data.triggerType == 0 and data.uiPage == "building") or data.uiPage == "free_btn" then
                NGUIMath.OverlayPosition(currentPointerBg, targetUIElement)
                currentPointerBg.position = Vector3(currentPointerBg.position.x, currentPointerBg.position.y, 0)
            else
                currentPointerBg.position = targetUIElement.position
            end
            targetVisible = targetUIElement.gameObject.activeInHierarchy
        end
        local checkVisible = currentCheckVisibleFunc == nil or currentCheckVisibleFunc()
        local fingerDelay = data.fingerDelay
        if fingerTimer < fingerDelay then
            fingerTimer = fingerTimer + GameTime.deltaTime
        end
        closeTimer = closeTimer + GameTime.deltaTime
        local pointerActive = targetVisible and checkVisible and fingerTimer >= fingerDelay
        if currentPointerBg.gameObject.activeSelf ~= pointerActive then
            currentPointerBg.gameObject:SetActive(pointerActive)
            if pointerActive then
                local avatarType = data.avatarType
                local hand = tutorialUI.avatar[avatarType].hand
                if hand ~= nil then
                    zeroPos = UICamera.currentCamera:ViewportToWorldPoint(Vector3(0.5, 0.5, 0))
                    handLerpTime = 0
                end
            end
        end

        if pointerActive then
            local avatarType = data.avatarType
            local hand = tutorialUI.avatar[avatarType].hand
            if hand ~= nil and handLerpTime < 1 then
                handLerpTime = handLerpTime + GameTime.deltaTime * handLerpScale
                if handLerpTime > 1 then
                    handLerpTime = 1
                end
                local zeroLocalPosition = currentPointerBg:InverseTransformPoint(zeroPos)
                hand.localPosition = Vector3.Lerp(zeroLocalPosition, tutorialUI.avatar[avatarType].defaultHandPosition, handLerpTime)
            end
        end
        --超过5秒箭头或者手指仍然不可见，强制关闭引导，防止卡死
        if closeTimer > 5 and not pointerActive then
            DebugPrint("等待箭头或手指出现超时，强制关闭引导!!!!!!!!!!!")
            Hide(0)
        end
        if auto and autoTimer > -1 then
            if currentPointerBg.gameObject.activeInHierarchy then
                local avatarType = data.avatarType
                local pointer = tutorialUI.avatar[avatarType].pointer
                if pointer ~= nil then
                    UICamera.Notify(pointer.gameObject, "OnClick", nil)
                end
            else
                if not targetUIElement:Equals(nil) then
                    UICamera.Notify(targetUIElement.gameObject, "OnClick", nil)
                    UICamera.Notify(targetUIElement.gameObject, "OnPress", true)
                    UICamera.Notify(targetUIElement.gameObject, "OnPress", false)
                end
            end
        end

    else
        if auto and autoTimer > 2 then
            UICamera.Notify(tutorialUI.mask.gameObject, "OnClick", nil)
            tutorialUI.mask.gameObject:SetActive(true)
        end
    end

    --校验顶端界面
    if currentTutorial ~= nil then
        local tutorialVisible = true
        local data = currentTutorial.data
        local triggerType = data.triggerType
        if GUIMgr:IsTopMenuOpen("LoadingMap") or GUIMgr:IsTopMenuOpen("login") then
            tutorialVisible = false
        elseif data.moduleId == 99999 and (GUIMgr:IsMenuOpen("WorldMap") or not MainCityQueue.IsSimple() or maincity.IsMovingCamera()) then
            tutorialVisible = false
            fingerTimer = 0
        elseif (triggerType == 1 or triggerType == 8 or data.id == 348) and data.top then
            local topMenu = GUIMgr:GetTopNotTutorialMenuOnRoot()
            if topMenu ~= nil and topMenu.name ~= data.uiPage then
                tutorialVisible = false
            end
        elseif triggerType == 5 or triggerType == 6 or triggerType == 7 or triggerType == 11 or (triggerType == 0 and data.uiPage == "building") or data.uiPage == "free_btn" then
            local topMenu = GUIMgr:GetTopNotTutorialMenuOnRoot()
            if topMenu ~= nil and topMenu.name ~= "MainCityUI" then
                tutorialVisible = false
            end
        end
        tutorialUI.container.gameObject:SetActive(tutorialVisible)
    end
end

function FinishAll()
    for _, v in pairs(tutorialList) do
        for __, vv in ipairs(v) do
            vv.triggered = true
        end
        v.finished = true
    end
    Save()
    if GUIMgr:IsTopMenuOpen(_NAME) then
        Hide(0)
    end
end

function IsForcingTutorial()
    if currentTutorial == nil then
        return false
    end
    local data = currentTutorial.data
    return data.guideType == 0 or data.guideType == 1
end
