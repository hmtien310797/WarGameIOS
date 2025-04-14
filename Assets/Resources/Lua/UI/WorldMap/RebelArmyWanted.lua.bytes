module("RebelArmyWanted", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local GetHeroAttrValueString = Global.GetHeroAttrValueString

local _ui
local timer = 0
local maxLevel
local targetLevel

function SetTargetLevel(level)
	targetLevel = level
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function CloseClickCallback(go)
    CloseAll()
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

function LoadRewardList(ui, gridTransform, dropId)
    local dropShowList = TableMgr:GetDropShowData(dropId)
    local dropLength = #dropShowList
    for i = 1, 3 do
        local rewardTransform = gridTransform:GetChild(i - 1)
        if i > dropLength then
            rewardTransform.gameObject:SetActive(false)
        else
            local item = {}
            local itemTransform = rewardTransform:GetChild(0)
            UIUtil.LoadItemObject(item, itemTransform)
            local dropShowData = dropShowList[i]
            local contentType = dropShowData.contentType
            local contentId = dropShowData.contentId
            rewardTransform.gameObject:SetActive(true)
            itemTransform.gameObject:SetActive(contentType == 1)
            if contentType == 1 then
                local itemData = TableMgr:GetItemData(contentId)
                local itemCount = dropShowData.contentNumber
                UIUtil.LoadItem(item, itemData, itemCount)
                UIUtil.SetClickCallback(item.transform.gameObject, function(go)
                    if go == ui.tipObject then
                        ui.tipObject = nil
                    else
                        ui.tipObject = go
                        Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                    end
                end)
            end
        end
    end

    gridTransform.repositionNow = true
end

function Search(monsterLevel)
    local req = MapMsg_pb.SearchMapEntryRequest()
    req.level = monsterLevel
    req.entryType = Common_pb.SceneEntryType_Monster
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SearchMapEntryRequest, req, MapMsg_pb.SearchMapEntryResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            local pos = msg.entrypos
            HeroList.CloseAll()
            ActivityAll.CloseAll()
            MainCityUI.ShowWorldMap(pos.x, pos.y, true, nil)
        else
            Global.ShowError(msg.code)
        end
    end)
end

local LoadUI
local function UpdateRebelItem(rebelObject, monsterLevel)
    local rebelTransform = rebelObject.transform
    rebelTransform.name = monsterLevel
    local monsterData = tableData_tMonsterRule.data[monsterLevel]
    if monsterData == nil then
        return
    end
    local rebelMsg = RebelWantedData.GetRebelData(monsterLevel)
    local completeObject = rebelTransform:Find("complete").gameObject
    local bg = rebelTransform:Find("bg").gameObject
    local bg2 = rebelTransform:Find("bg2").gameObject
    local bg3 = rebelTransform:Find("bg3").gameObject
    local nameLabel = rebelTransform:Find("bg/name"):GetComponent("UILabel")
    local nameLabel2 = rebelTransform:Find("bg2/name"):GetComponent("UILabel")
    local nameLabel3 = rebelTransform:Find("bg3/name"):GetComponent("UILabel")
    local fightLabel = rebelTransform:Find("combat/num"):GetComponent("UILabel")
    local firstLabelObject = rebelTransform:Find("reward/first").gameObject
    local rewardLabelObject = rebelTransform:Find("reward/convention").gameObject
    local gridTransform = rebelTransform:Find("reward/Grid")
    local searchButton = rebelTransform:Find("btn_search"):GetComponent("UIButton")
    local rewardButton = rebelTransform:Find("btn_reward"):GetComponent("UIButton")
    local disableButton = rebelTransform:Find("btn_disabled"):GetComponent("UIButton")
    local unlockTips = rebelTransform:Find("bg/lock_text"):GetComponent("UILabel")

    completeObject:SetActive(rebelMsg ~= nil)
    nameLabel.text = TextMgr:GetText(monsterData.name)
    nameLabel2.text = TextMgr:GetText(monsterData.name)
    nameLabel3.text = TextMgr:GetText(monsterData.name)
    fightLabel.text = monsterData.referenceFight
    local dropId
    if rebelMsg == nil or not rebelMsg.isRewarded then
        dropId = monsterData.firstKillShow
        firstLabelObject:SetActive(true)
        rewardLabelObject:SetActive(false)
    else
        dropId = monsterData.killAwardShow
        firstLabelObject:SetActive(false)
        rewardLabelObject:SetActive(true)
    end

    LoadRewardList(_ui, gridTransform, dropId)

    local isLevelUnlocked = RebelWantedData.IsLevelUnlocked(monsterLevel)
    searchButton.gameObject:SetActive(isLevelUnlocked and (rebelMsg == nil or rebelMsg.isRewarded))
    rewardButton.gameObject:SetActive(isLevelUnlocked and rebelMsg ~= nil and not rebelMsg.isRewarded)
    disableButton.gameObject:SetActive(not isLevelUnlocked)
    
    unlockTips.gameObject:SetActive(not isLevelUnlocked)
    if not isLevelUnlocked then
        unlockTips.text = String.Format(TextMgr:GetText("RebelArmyWanted_ui1"), RebelWantedData.GetUnlockConditionForLevel(monsterLevel))
    end
    
    bg:SetActive(true)
    bg2:SetActive(false)
    bg3:SetActive(false)

    SetClickCallback(searchButton.gameObject, function()
        Search(monsterLevel)
    end)

    SetClickCallback(rewardButton.gameObject, function()
        local req = MapMsg_pb.MonsterStepRewardRequest()
        req.level = monsterLevel
        Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MonsterStepRewardRequest, req, MapMsg_pb.MonsterStepRewardResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                RebelWantedData.UpdateRebelData(msg.monsterInfo)
                LoadUI()
                MainCityUI.UpdateRewardData(msg.fresh)
                Global.ShowReward(msg.reward)
                if monsterLevel == 5 then
                    GUIMgr:SendDataReport("efun", "kill5")
                end
            else
                Global.ShowError(msg.code)
            end
        end)
    end)

    SetClickCallback(disableButton.gameObject, function()
        FloatText.ShowOn(disableButton.gameObject, String.Format(TextMgr:GetText("RebelArmyWanted_ui1"), RebelWantedData.GetUnlockConditionForLevel(monsterLevel), Color.red))
    end)
end

local function UpdateList(go, wrapIndex, realIndex)
    local monsterLevel = -realIndex + 1
    _ui.rebelList[wrapIndex + 1] = {monsterLevel, go}
    UpdateRebelItem(go, monsterLevel)
end

LoadUI = function()    
    local dataCount = #tableData_tMonsterRule.data
    local maxShowLevel = RebelWantedData.GetUnlockedLevel() + 1
    _ui.completeAllObject:SetActive(maxLevel == dataCount)
    _ui.listWrapContent.minIndex = -maxShowLevel + 1
    _ui.listWrapContent.numUsableChildren = maxShowLevel
    _ui.listScrollView.disableDragIfFits = maxShowLevel < 4 --_ui.listRow
    for k, v in pairs(_ui.rebelList) do
        UpdateRebelItem(v[2], v[1])
    end
    if _ui.reset then
        _ui.listWrapContent.onInitializeItem = UpdateList
        _ui.listScrollView.gameObject:SetActive(true)
        local moveCount = math.min(RebelWantedData.GetMinRewardLevel(), maxLevel) - 2
        if targetLevel ~= nil then
            moveCount = targetLevel - 2
        end
        -- local minRewardLevel = RebelWantedData.GetMinRewardLevel()
        -- if minRewardLevel ~= 0 and targetLevel == nil then
        --     moveCount = math.min(moveCount, minRewardLevel - 2)
        -- end
        local moveY = _ui.listItemHeight * moveCount
        local maxShowLevel = RebelWantedData.GetUnlockedLevel()
        moveY = math.min(moveY, _ui.listItemHeight * (maxShowLevel + 1) - _ui.listClipHeight)
        if moveY > 0 then
            _ui.listScrollView:MoveRelative(Vector3(0, moveY, 0))
            _ui.listScrollView:Scroll(0.01)
        end
        _ui.reset = false
    end
end

function LateUpdate()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            _ui.timeLabel.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown())
        end
    end
end

function Awake()
    maxLevel = RebelWantedData.GetMaxLevel()
    local closeButton = transform:Find("Container/close btn")
    SetClickCallback(closeButton.gameObject, CloseClickCallback)
    SetClickCallback(transform:Find("mask").gameObject, function()
        CloseClickCallback()
        ActivityAll.Hide()
    end)
    _ui = {}
    _ui.reset = true
    _ui.timeLabel = transform:Find("Container/bg/time/number"):GetComponent("UILabel")
    _ui.completeAllObject = transform:Find("Container/bg/Label/Sprite").gameObject
    _ui.listPanel = transform:Find("Container/bg/Scroll View"):GetComponent("UIPanel")
    _ui.listScrollView = transform:Find("Container/bg/Scroll View"):GetComponent("UIScrollView")
    _ui.listWrapContent = transform:Find("Container/bg/Scroll View/Grid"):GetComponent("UIWrapContent")
    _ui.listRow = _ui.listWrapContent.transform.childCount
    _ui.listItemHeight = _ui.listWrapContent.itemSize
    _ui.listClipHeight = _ui.listPanel.baseClipRegion.w
    -- _ui.listWrapContent.onInitializeItem = UpdateList
    _ui.rebelList = {}
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    RebelWantedData.AddListener(LoadUI)
    RebelWantedData.NotifyUIOpened()
end

function Close()
    _ui.listWrapContent.onInitializeItem = nil
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    RebelWantedData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui = nil
    targetLevel = nil
end

function Show()
    Global.OpenUI(_M)
    RebelWantedData.RequestData()
end
