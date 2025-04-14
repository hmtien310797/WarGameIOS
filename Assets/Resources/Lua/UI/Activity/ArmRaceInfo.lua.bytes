module("ArmRaceInfo", package.seeall)

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

local chestTextList = 
{
    "s",
    "m",
    "b",
}

function GetActLevelByIdPkValue(rewardId, pkValue)
    for k, v in pairs(tableData_tStatisticsReward.data) do
        if v.rewardId == rewardId then
            if pkValue >= v.minFight and pkValue <= v.maxFight then
                return v.id
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
    local race = _ui.race
    if _ui.raceIndex <= 2 then
        if race.startTime > serverTime then
            _ui.timeLabel.text = Global.GetLeftCooldownTextLong(race.startTime)
            _ui.stateLabel.text = TextMgr:GetText(Text.ActivityAll_25)
        else
            _ui.timeLabel.text = Global.GetLeftCooldownTextLong(race.endTime)
            _ui.stateLabel.text = TextMgr:GetText(Text.union_train6)
        end
    else
        _ui.timeLabel.text = Global.GetLeftCooldownTextLong(race.startTime)
        _ui.stateLabel.text = TextMgr:GetText(raceIndex == 7 and Text.ui_zone13 or Text.Armrace_5)
    end
end

function LoadUI()
    local race = _ui.race
    local raceData = race.data
    local raceMsg = RaceData.GetRaceDataByActId(raceData.id)
    local completeType = raceData.completeType
    _ui.titleLabel.text = TextMgr:GetText(raceData.completeType == 1 and Text.Armrace_1 or Text.Armrace_2)
    _ui.scoreLabel.text = raceMsg ~= nil and raceMsg.value or 0
	
	local activeListData = TableMgr:GetActivityStaticsListData(raceData.id)
	_ui.rankMinimumLabel.text = System.String.Format(TextMgr:GetText("raceinfo_mix"),activeListData.PointMin)
	
    if raceMsg ~= nil then
        local order = raceMsg.order
        if order == 0 or order > 100 then
            _ui.rankLabel.text = System.String.Format(TextMgr:GetText("Armrace_16") , 100)
        else
            local rank = math.ceil(order / 10) * 10
            _ui.rankLabel.text = System.String.Format(TextMgr:GetText("Armrace_15") , rank)
        end
    else
        _ui.rankLabel.text = "--"
    end

    SetClickCallback(_ui.rankButton.gameObject, function(go)
        if completeType == 1 then
            ArmRaceHisInfo.Show(raceData.id)
        else
            ArmRaceHisInfo_union.Show(raceData.id)
        end
    end)

    local ruleGrid = _ui.ruleGrid
    local ruleIndex = 1
    for v in string.gsplit(raceData.rules, ";") do
        local ruleDataId = tonumber(v)
        if ruleDataId ~= nil then
            local ruleData = tableData_tStatisticsRule.data[ruleDataId] 
            local ruleTransform = ruleGrid:GetChild(ruleIndex - 1)
            if ruleTransform ~= nil then
                ruleTransform.gameObject:SetActive(true)
                ruleTransform:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(ruleData.text)
                local pointLabel = ruleTransform:Find("points"):GetComponent("UILabel")
                local point = ruleData.point
                if point > 0 then
                    pointLabel.text = System.String.Format(TextMgr:GetText("Armrace_14") , point)
                    pointLabel.gameObject:SetActive(true)
                else
                    pointLabel.gameObject:SetActive(false)
                end
            end
            ruleIndex = ruleIndex + 1
        end
    end

    for i = ruleIndex, ruleGrid.transform.childCount do
        ruleGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    local actLevel = 1
    local currentScore = 0
    if raceMsg ~= nil then
        actLevel = raceMsg.actLevel
        currentScore = raceMsg.value
    else
        if completeType == 1 then
            local pkValue = MainData.GetData().pkvalue
            actLevel = GetActLevelByIdPkValue(raceData.personal, pkValue)
        else
            actLevel = raceData.personal
        end
    end
    local rewardData = tableData_tStatisticsReward.data[actLevel]
    local maxScore
    local diffScore = 0
    local currentPercent = 0
    for i, v in ipairs(_ui.rewardList) do
        local chest = _ui.chestList[i]
        local dropId = rewardData["show" .. i]
        local dropShowList = TableMgr:GetDropShowData(dropId)
        local dropShowData = dropShowList[1]
        local contentType = dropShowData.contentType
        local contentId = dropShowData.contentId
        if contentType == 1 then
            v.item.gameObject:SetActive(true)
            local itemData = TableMgr:GetItemData(contentId)
            local itemCount = dropShowData.contentNumber
            UIUtil.LoadItem(v.item, itemData, itemCount)
            local requiredScore = rewardData["needFight" .. i]
            if i == 3 then
                maxScore = requiredScore
            end
            if requiredScore > currentScore and diffScore == 0 then
                diffScore = requiredScore - currentScore
                local preRequiredScore = i > 1 and rewardData["needFight" .. (i - 1)] or 0
                currentPercent = (i - 1) / 3 + (currentScore - preRequiredScore) / (requiredScore - preRequiredScore) / 3
            end
            v.scoreLabel.text = requiredScore
            chest.scoreLabel.text = requiredScore
            local hasReward = false
            if raceMsg ~= nil then
                for __, vv in ipairs(raceMsg.reward) do
                    if vv == i then
                        hasReward = true
                        break
                    end
                end
            end
            local completed = currentScore >= requiredScore
            local rewarded = completed and not hasReward
            local chestText
            if rewarded then
                chestText = "open"
            elseif completed then
                chestText = "done"
            else
                chestText = "null"
            end

            chest.button.normalSprite = string.format("icon_starbox_%s_%s", chestTextList[i], chestText)
            local canReward = chestText == "done"
            chest.effect:SetActive(canReward)
            chest.noticeObject:SetActive(canReward)
            for j = 1, chest.tweenerList.Length do
                chest.tweenerList[j - 1].enabled = canReward
            end
            SetClickCallback(chest.button.gameObject, function(go)
                if chestText == "done" then
                    local req = ClientMsg_pb.MsgGetRaceRewardRequest()
                    req.actId = raceData.id
                    req.index = i
                    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetRaceRewardRequest, req, ClientMsg_pb.MsgGetRaceRewardResponse, function(msg)
                        if msg.code == ReturnCode_pb.Code_OK then
                            RaceData.UpdateRaceData(msg.data)
                            MainCityUI.UpdateRewardData(msg.fresh)
                            ItemListShowNew.Show(msg)
                        else
                            Global.ShowError(msg.code)
                        end
                    end)

                end
            end)
            UIUtil.SetClickCallback(v.item.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                end
            end)
        else
            v.item.gameObject:SetActive(false)
        end
    end

    _ui.diffLabel.text = diffScore
    _ui.chestSlider.value = diffScore > 0 and currentPercent or 1
    UpdateTime()
end

function Awake()
    local closeButton = transform:Find("Container/background/close btn")
    closeButton.gameObject:SetActive(true)
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui = {}
    _ui.titleLabel = transform:Find("Container/background/title/Label"):GetComponent("UILabel")
    _ui.stateLabel = transform:Find("Container/top/lefttime/Label01"):GetComponent("UILabel")
    _ui.timeLabel = transform:Find("Container/top/lefttime/Label02"):GetComponent("UILabel")
    _ui.scoreLabel = transform:Find("Container/top/points01/lable"):GetComponent("UILabel")
    _ui.diffLabel = transform:Find("Container/top/points02/lable"):GetComponent("UILabel")
    _ui.rankButton = transform:Find("Container/bg2/title/bg3_btn"):GetComponent("UIButton")
    _ui.rankLabel = transform:Find("Container/bg2/mypoints/lable"):GetComponent("UILabel")
    _ui.chestSlider = transform:Find("Container/top/jindu"):GetComponent("UISlider")
	_ui.rankMinimumLabel = transform:Find("Container/top/jindu/Label"):GetComponent("UILabel")

    local chestList = {}
    for i = 1, 3 do
        local chestTransform = transform:Find("Container/top/jindu/" .. i)
        local chest = {}
        chest.transform = chestTransform
        chest.scoreLabel = chestTransform:Find("Label"):GetComponent("UILabel")
        chest.button = chestTransform:Find("icon"):GetComponent("UIButton")
        chest.noticeObject = chestTransform:Find("icon/red").gameObject
        chest.effect = chestTransform:Find("icon/ShineItem").gameObject
        chest.tweenerList = chest.button.transform:GetComponents(typeof(UITweener))
        chestList[i] = chest
    end
    _ui.chestList = chestList

    _ui.ruleGrid = transform:Find("Container/bg1/base/Grid"):GetComponent("UIGrid")

    local itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    local rewardList = {}
    for i = 1, 3 do
        local reward = {}
        local rewardTransform = transform:Find("Container/bg2/base/term" .. i)
        reward.transform = rewardTransform
        reward.scoreLabel = rewardTransform:Find("number"):GetComponent("UILabel")
        reward.chestSprite = rewardTransform:Find("chest"):GetComponent("UISprite")
        local bgTransform = rewardTransform:Find("listinfo_item")
        local itemTransform = NGUITools.AddChild(bgTransform.gameObject, itemPrefab).transform
        local item = {}
        UIUtil.LoadItemObject(item, itemTransform)
        UIUtil.AdjustDepth(item.gameObject, 100)
        reward.item = item
        rewardList[i] = reward
    end
    _ui.rewardList = rewardList
    RaceData.AddListener(LoadUI)
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

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    RaceData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show(raceIndex, race)
    Global.OpenUI(_M)
    _ui.raceIndex = raceIndex
    _ui.race = race
    LoadUI()
end
