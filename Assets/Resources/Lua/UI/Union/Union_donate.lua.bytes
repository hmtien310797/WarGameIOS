module("Union_donate", package.seeall)
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

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function UpdateTime()
    local donateMsg = UnionDonateData.GetData().info
    local detailMsg = donateMsg.details
    for i, v in ipairs(detailMsg) do
        local donate = _ui.donateList[i]
        local leftSecond
        donate.cooldownLabel.text, leftSecond = Global.GetLeftCooldownTextLong(v.nextTime)
        donate.donateButton.isEnabled = leftSecond <= 0 and v.count.count > 0
        donate.cooldownLabel.gameObject:SetActive(leftSecond > 0)
    end
end

function LoadUI()
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    local donateMsg = UnionDonateData.GetData().info
    UnionBadge.LoadBadgeById(_ui.badge, unionMsg.badge)
    _ui.nameLabel.text = string.format("[%s]%s", unionMsg.banner, unionMsg.name)
    _ui.leaderLabel.text = unionMsg.leaderName
    for i, v in ipairs(donateMsg.resFreshInfo.resInfos) do
        if v.resType == Common_pb.MoneyType_GuildCoin then
            _ui.guildCoinLabel.text = Global.FormatNumber(v.resNum)
            break
        end
    end

    _ui.selfCoinLabel.text = Global.FormatNumber(MoneyListData.GetGuildCoin())

    local detailMsg = donateMsg.details
    local logListMsg = donateMsg.logs
    local currentStep = donateMsg.contributorNum
    _ui.donateCountLabel.text = currentStep 

    local rewardDataList = string.split(tableData_tGlobal.data[100166].value, ";")
	local typeList = {"s", "s", "m", "m", "b"}
	local statusList = {"null", "done", "open"}
	local diffStep = 0
	local currentPercent = 0
    for i, v in ipairs(donateMsg.stepRewards) do
        local reward = _ui.rewardList[i]
        reward.countLabel.text = v.step
        reward.shineObject:SetActive(v.status == 2)
        reward.rewardButton.normalSprite = string.format("icon_starbox_%s_%s", typeList[i], statusList[v.status])
        
        SetClickCallback(reward.rewardButton.gameObject, function(go)
            local rewardData = string.split(rewardDataList[i], ":")
            SectionRewards_union.Show(tonumber(rewardData[1]), tonumber(rewardData[2]), v.status, v.step)
        end)
        local requiredStep = v.step
        if requiredStep > currentStep and diffStep == 0 then
            diffStep = requiredStep - currentStep
            local preRequiredStep = i > 1 and donateMsg.stepRewards[i - 1].step or 0
            currentPercent = (i - 1) / 5 + (currentStep - preRequiredStep) / (requiredStep - preRequiredStep) / 5
        end
    end
    _ui.rewardSlider.value = diffStep > 0 and currentPercent or 1

    for i, v in ipairs(logListMsg) do
        local logTransform
        if i > _ui.logGrid.transform.childCount then
            logTransform = NGUITools.AddChild(_ui.logGrid.gameObject, _ui.logPrefab).transform
        else
            logTransform = _ui.logGrid.transform:GetChild(i - 1)
        end
        local logMsg = logListMsg[#logListMsg - i + 1]
        logTransform:GetComponent("UILabel").text = Format(TextMgr:GetText(Text.UnionContribute_record), logMsg.charName, TextMgr:GetText(Text["UnionContribute_" .. logMsg.type]))
    end
    _ui.logGrid.repositionNow = true
    _ui.logScrollView:ResetPosition()

    for i, v in ipairs(detailMsg) do
        local donate = _ui.donateList[i]
        donate.countLabel.text = string.format("(%d/%d)", v.count.count, v.count.countmax)
        donate.coinLabel1.text = v.addGuildCoin
        donate.coinLabel2.text = v.guildAddGuildCoin
        donate.costLabel.text = v.costItem.num
        local itemData = tableData_tItem.data[v.costItem.id]
        donate.costIcon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
        
        if v.count.count == 0 then
            local leftSecond = Global.GetLeftCooldownSecond(v.nextTime)
            local timer = Timer.New(UnionDonateData.RequestData, leftSecond, 0)
            timer:Start()
        end
    end
    UpdateTime()
end

function Start()
    LoadUI()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/background widget/close btn")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

	local badge = {}
    local badgeTransform = transform:Find("Container/content 1/info widget/icon bg")
    UnionBadge.LoadBadgeObject(badge, badgeTransform)
    _ui.badge = badge
    _ui.nameLabel = transform:Find("Container/content 1/info widget/union name"):GetComponent("UILabel")
    _ui.leaderLabel = transform:Find("Container/content 1/info widget/leader/leader text"):GetComponent("UILabel")
    _ui.guildCoinLabel = transform:Find("Container/content 1/info widget/capital/combat text"):GetComponent("UILabel")
    _ui.selfCoinLabel = transform:Find("Container/content 1/info widget/unionCoin/people text"):GetComponent("UILabel")
    _ui.donateCountLabel = transform:Find("Container/content 1/people/num"):GetComponent("UILabel")

    _ui.logScrollView = transform:Find("Container/content 1/announcement/Scroll View"):GetComponent("UIScrollView")
    _ui.logGrid = transform:Find("Container/content 1/announcement/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.logPrefab = transform:Find("Container/content 1/announcement/Scroll View/Grid/Label").gameObject

    _ui.rewardSlider = transform:Find("Container/content 1/jindu"):GetComponent("UISlider")
    local rewardList = {}
    for i = 1, 5 do
        local reward = {}
        local rewardTransform = transform:Find("Container/content 1/jindu/" .. i)
        reward.transform = rewardTransform
        reward.rewardButton = rewardTransform:Find("icon"):GetComponent("UIButton")
        reward.noticeObject = rewardTransform:Find("icon/red").gameObject
        reward.shineObject = rewardTransform:Find("icon/ShineItem").gameObject
        reward.countLabel = rewardTransform:Find("Label"):GetComponent("UILabel")
        rewardList[i] = reward
    end
    _ui.rewardList = rewardList

    local donateList = {}
    for i = 1, 3 do
        local donate = {}
        local donateTransform = transform:Find("Container/content 1/donate" .. i)
        donate.transform = donateTransform
        donate.countLabel = donateTransform:Find("bg/Label"):GetComponent("UILabel")
        donate.coinLabel1 = donateTransform:Find("reward1/Label"):GetComponent("UILabel")
        donate.coinLabel2 = donateTransform:Find("reward2/Label"):GetComponent("UILabel")
        donate.donateButton = donateTransform:Find("btn"):GetComponent("UIButton")
        donate.costIcon = donateTransform:Find("btn/icon"):GetComponent("UITexture")
        donate.costLabel = donateTransform:Find("btn/num"):GetComponent("UILabel")
        donate.cooldownLabel = donateTransform:Find("cd time"):GetComponent("UILabel")
        donateList[i] = donate
        SetClickCallback(donate.donateButton.gameObject, function(go)
            local req = GuildMsg_pb.MsgContributeGuildRequest()
            req.type = i
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgContributeGuildRequest, req, GuildMsg_pb.MsgContributeGuildResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    UnionDonateData.UpdateInfoData(msg.info)
                    Global.ShowReward(msg.reward)
                    MainCityUI.UpdateRewardData(msg.fresh)
                else
                    Global.ShowError(msg.code)
                end
            end)
        end)
    end

    _ui.donateList = donateList
	
    UnionDonateData.AddListener(LoadUI)
    MoneyListData.AddListener(LoadUI)
    _ui.timer = Timer.New(UpdateTime, 1, -1)
    _ui.timer:Start()
end

function Close()
    UnionDonateData.RemoveListener(LoadUI)
    MoneyListData.RemoveListener(LoadUI)
    _ui.timer:Stop()
    _ui = nil
end

function Show()
    UnionDonateData.RequestData(function()
        Global.OpenUI(_M)
    end)
end
