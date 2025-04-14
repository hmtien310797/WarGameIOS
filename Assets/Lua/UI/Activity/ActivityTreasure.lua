module("ActivityTreasure", package.seeall)

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
local LoadUI

local isNew = false

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

local function UpdateListItem(itemObject, itemIndex)
    local treasureMsg = _ui.treasureMsg    
    local rewardMsg = treasureMsg.data[itemIndex]
    if rewardMsg == nil then
        return
    end

    local itemTransform = itemObject.transform
    local nameLabel = itemTransform:Find("bg/name"):GetComponent("UILabel")
    local valueLabel1 = itemTransform:Find("jindu/number1"):GetComponent("UILabel")
    local valueLabel2 = itemTransform:Find("jindu/number1 (1)"):GetComponent("UILabel")
    local rewardButton = itemTransform:Find("btn_reward"):GetComponent("UIButton")
    local disableButton = itemTransform:Find("btn_disabled"):GetComponent("UIButton")
    local disableLabel = itemTransform:Find("btn_disabled/Label"):GetComponent("UILabel")
    local completeObject = itemTransform:Find("complete").gameObject
    local gridTransform = itemTransform:Find("reward/Grid"):GetComponent("UIGrid")
    local descriptionButton = transform:Find("Container/content_4/button_ins"):GetComponent("UIButton")
    SetClickCallback(descriptionButton.gameObject, function()
        RebelGoldInstru.Show()
    end)

    nameLabel.text = String.Format(TextMgr:GetText(Text.ActivityAll_12), rewardMsg.valueMax)
    valueLabel1.text = math.min(rewardMsg.value, rewardMsg.valueMax)
    valueLabel2.text = "/" .. rewardMsg.valueMax
    local color = rewardMsg.value >= rewardMsg.valueMax and Color.white or Color.red
    valueLabel1.gradientTop = color
    valueLabel1.gradientBottom = color

    local rewardIndex = 1
    for v in string.gsplit(rewardMsg.rewardInfo, ";") do
        local itemTable = string.split(v, ":")
        local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
        local itemData = TableMgr:GetItemData(itemId)
        local itemTransform = gridTransform:GetChild(rewardIndex - 1)
        itemTransform.gameObject:SetActive(true)
        local reward = {}
        UIUtil.LoadItemObject(reward, itemTransform)
        UIUtil.LoadItem(reward, itemData, itemCount)
        UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
            end
        end)
        rewardIndex = rewardIndex + 1
    end
    
    for i = rewardIndex,3 do
        local itemTransform = gridTransform:GetChild(rewardIndex - 1)
        itemTransform.gameObject:SetActive(false)
    end

    rewardButton.gameObject:SetActive(rewardMsg.value >= rewardMsg.valueMax and not rewardMsg.rewarded)
    disableButton.gameObject:SetActive(rewardMsg.value < rewardMsg.valueMax or rewardMsg.rewarded)
    disableLabel.text = TextMgr:GetText(rewardMsg.rewarded and Text.SectionRewards_ui5 or Text.mail_ui12)
    completeObject:SetActive(rewardMsg.rewarded)
    SetClickCallback(rewardButton.gameObject, function()
        local req = BattleMsg_pb.MsgBattleMapDigGetRewardRequest()
        req.index = rewardMsg.index
        Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleMapDigGetRewardRequest, req, BattleMsg_pb.MsgBattleMapDigGetRewardResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                ActivityTreasureData.SetRewarded(itemIndex)
                Global.ShowReward(msg.reward)
                MainCityUI.UpdateRewardData(msg.fresh)
            else
                Global.ShowError(msg.code)
            end
        end)
    end)
end

local function UpdateList(go, wrapIndex, realIndex)
    local monsterLevel = -realIndex + 1
    _ui.itemList[wrapIndex + 1] = {monsterLevel, go}
    UpdateListItem(go, monsterLevel)
end

local function UpdateTime()
    local treasureMsg = _ui.treasureMsg
    local lastFreshTime = treasureMsg.lastFreshTime
    local freshTime = treasureMsg.freshTime
    local endTime = treasureMsg.endTime
    local lifeTime = treasureMsg.lifeTime
    _ui.endTimeLabel.text = Global.GetLeftCooldownTextLong(_ui.treasureMsg.endTime)

    local serverTime = GameTime.GetSecTime()


    --[[
    if serverTime > freshTime then
        _ui.refreshEndObject:SetActive(true)
        _ui.refreshObject:SetActive(false)
        _ui.refreshLabel.text = TextMgr:GetText("Newrebelgold_6")
    else
        _ui.refreshEndObject:SetActive(false)
        _ui.refreshObject:SetActive(true)

        if serverTime > lastFreshTime + lifeTime then
            _ui.refreshLabel.text = TextMgr:GetText(Text.ActivityAll_10)
            _ui.refreshTimeLabel.text = Global.GetLeftCooldownTextLong(freshTime)
        else
            _ui.refreshLabel.text = TextMgr:GetText("Newrebelgold_7")--Text.ActivityAll_14)
            _ui.refreshTimeLabel.text = Global.GetLeftCooldownTextLong(lastFreshTime + lifeTime)
        end
    end
    --]]



    if serverTime > lastFreshTime + lifeTime then
        if serverTime > freshTime then
            _ui.refreshEndObject:SetActive(true)
            _ui.refreshObject:SetActive(false)
            _ui.refreshLabel.text = TextMgr:GetText("Newrebelgold_6")            
        else
            _ui.refreshEndObject:SetActive(false)
            _ui.refreshObject:SetActive(true)              
            _ui.refreshLabel.text = TextMgr:GetText(Text.ActivityAll_10)
            _ui.refreshTimeLabel.text = Global.GetLeftCooldownTextLong(freshTime)            
        end
    else     
        _ui.refreshEndObject:SetActive(false)
        _ui.refreshObject:SetActive(true)
        _ui.refreshLabel.text = TextMgr:GetText("Newrebelgold_7")--Text.ActivityAll_14)
        _ui.refreshTimeLabel.text = Global.GetLeftCooldownTextLong(lastFreshTime + lifeTime)
    end

end

LoadUI = function()
    _ui.treasureMsg = ActivityTreasureData.GetData()
    local treasureMsg = _ui.treasureMsg
    local dataCount = #treasureMsg.data
    _ui.listWrapContent.minIndex = -dataCount + 1
    _ui.listScrollView.disableDragIfFits = dataCount < _ui.listRow

    for k, v in pairs(_ui.itemList) do
        UpdateListItem(v[2], v[1])
    end

    UpdateTime()
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

function Awake()
    local closeButton = transform:Find("Container/background/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, function()
        CloseAll()
        ActivityAll.Hide()
    end)
    _ui = {}
    _ui.refreshTimeLabel = transform:Find("Container/content_4/time_1/number"):GetComponent("UILabel")
    _ui.refreshObject = transform:Find("Container/content_4/time_1").gameObject
    _ui.refreshLabel = _ui.refreshObject.transform:GetComponent("UILabel")
    _ui.refreshEndObject = transform:Find("Container/content_4/time_2").gameObject
    _ui.endTimeLabel = transform:Find("Container/content_4/time_2/number"):GetComponent("UILabel")
    _ui.listPanel = transform:Find("Container/content_4/Scroll View"):GetComponent("UIPanel")
    _ui.listScrollView = transform:Find("Container/content_4/Scroll View"):GetComponent("UIScrollView")
    _ui.listWrapContent = transform:Find("Container/content_4/Scroll View/Grid"):GetComponent("UIWrapContent")
    _ui.listRow = _ui.listWrapContent.transform.childCount
    _ui.listItemHeight = _ui.listWrapContent.itemSize
    _ui.listClipHeight = _ui.listPanel.baseClipRegion.w
    _ui.listWrapContent.onInitializeItem = UpdateList

    _ui.itemList = {}

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    ActivityTreasureData.AddListener(LoadUI)
end

function Start()
    ActivityTreasureData.NotifyUIOpened()
    
    local maxIndex = 1
    local moveCount = maxIndex - 2
    local moveY = _ui.listItemHeight * moveCount
    local treasureMsg = _ui.treasureMsg
    local dataCount = #treasureMsg.data
    moveY = math.min(moveY, _ui.listItemHeight * dataCount - _ui.listClipHeight)
    if moveY > 0 then
        _ui.listScrollView:MoveRelative(Vector3(0, moveY, 0))
        _ui.listScrollView:Scroll(0.01)
    end
end

function Close()
    _ui.listWrapContent.onInitializeItem = nil
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    ActivityTreasureData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show(showCallback)
    ActivityTreasureData.RequestData(true)
    Global.OpenUI(_M)
    LoadUI(true)
end
