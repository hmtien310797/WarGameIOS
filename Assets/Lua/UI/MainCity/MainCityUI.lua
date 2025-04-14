module("MainCityUI", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local UIAnimMgr = Global.GUIAnimMgr
local String = System.String
local WorldToLocalPoint = NGUIMath.WorldToLocalPoint
local Screen = UnityEngine.Screen

local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetDragCallback = UIUtil.SetDragCallback
local SetDragOverCallback = UIUtil.SetDragOverCallback
local SetDragEndCallback = UIUtil.SetDragEndCallback

local SetActiveCallback = UIUtil.SetActiveCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui

local ShowRebelSurroundCoroutine
local ShowWorldMapPreViewCoroutine
local ShowWorldMapCoroutine
local HideWorldMapInternalCoroutine
local bg
local iconPlayerBtn
local labelEnergy
local iconEnergy
local labelVip
local cityMenu
local container
local mainLevel
local chatPreviewOffset


local moneyTypeList = 
{
    [Common_pb.MoneyType_Diamond] = 
    {resourceType = 0, path = "Container/TopBar/bg_gold", labelPath = "bg_msg/num", iconPath = "icon"},
    [Common_pb.MoneyType_Food] = 
    {resourceType = BuildMsg_pb.BuildType_Farmland, path = "Container/resourebar/bg_resoure (1)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Iron] = 
    {resourceType = BuildMsg_pb.BuildType_Logging, path = "Container/resourebar/bg_resoure (2)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Oil] = 
    {resourceType = BuildMsg_pb.BuildType_OilField, path = "Container/resourebar/bg_resoure (3)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Elec] = 
    {resourceType = BuildMsg_pb.BuildType_IronOre, path = "Container/resourebar/bg_resoure (4)", labelPath = "num", iconPath = "icon"},
}

local btnWar
local btnMap
local topBar
local resourceBar
local arrayBar
local buildInfoBar
local onlineReward
local mainBuff

local bottomMenuList
local rightMenuList
local noticeList

--local ui.btnZhankai
local tweenZhankaiBottom
local tweenZhankaiRight
local menuTarget
local menuStep = 0
local cityCamera
local temproryBagTime
local temporyTargetTime = 0
local openedMainMenu

local jumpMenu
local promptList
local recommendedMissionUI
local btn_update

local ChatMenu

local resEffectSize = 5
local resEffectActiveIdx = 1
local resEffects = {}
local iconEffects = {}
local unionHelpUI

local lastMenuPos
local showMenuCallBack

local warning = {}

local canshowmission = true
local hasCityMenu = false
local requestArmyCoseTime
local requestArmyCoseDuration
local requestChat = false

local updataBuffTimer = 0
local raceStartTime = 0
local updateMoneyTimer = 0

CheckAndBuyEnergy = nil

local RequestArmyCost

local isZhankai = false
local hasmission = false
local hadLimitedTime = true

local loginEnter = true
local CheckArmyCostCoroutine
RequestEnergy = nil
local targetRenderer
local pathid

local RESPOOL_SIZE = 50
local reseffectPool = {}
local reseffectActiveCount = 0
local terrain = nil

local conditionalUIQueue = {}

local loginfinish

local uiPopUps = {}

isUnionFunctionUnlocked = false

timeEnterMainCityUI = 0

function RegisterPopUpUI(module)
	table.insert(uiPopUps, module._NAME)
end

function DeregisterPopUpUI(module)
	for i = #uiPopUps, 1, -1 do
		if uiPopUps[i] == module._NAME then
			table.remove(uiPopUps, i)
		end
	end
end

function RecordTimeEnterMainCityUI()
    local topMenu = GUIMgr:GetTopMenuOnRoot()
	if topMenu ~= nil and topMenu.name ~= _M._NAME then
		timeEnterMainCityUI = 0
	elseif timeEnterMainCityUI == 0 then
		timeEnterMainCityUI = Serclimax.GameTime.GetSecTime()
	end

	if topMenu ~= nil and topMenu.name == _M._NAME then
        SoldierUnlock.CheckShow()
    end
end

--vip体验卡
local viptime = 10
local viptips = false

-- 联盟邀请
currentInvite = 0
hasNewAllianceInvite = false
timeToShowRecommendedAlliance = tonumber(TableMgr:GetGlobalData(113).value)
intervalToShowRecommendedAlliance = tonumber(TableMgr:GetGlobalData(112).value)
lastTimeCloseAllianceInvite = 0

local function RefreshUIAllianceInvite()
	if _ui == nil then
		return
	end
	if currentInvite < 0 then -- 联盟推荐
		local recommendedAlliance = AllianceInvitesData.GetRecommendedAlliance()

		_ui.allianceInvite.recommendation.name.text = string.format("[%s]%s", recommendedAlliance.guildBanner, recommendedAlliance.guildName)
	    _ui.allianceInvite.recommendation.slogan.text = recommendedAlliance.guildSlogan ~= "" and recommendedAlliance.guildSlogan or TextMgr:GetText("union_template")
	    UnionBadge.LoadBadgeById(_ui.allianceInvite.badge, recommendedAlliance.guildBadge)

	    _ui.allianceInvite.notice:SetActive(false)
		_ui.allianceInvite.rightArrow:SetActive(false)
		_ui.allianceInvite.leftArrow:SetActive(false)

		_ui.allianceInvite.playerInvite.gameObject:SetActive(false)
		_ui.allianceInvite.recommendation.gameObject:SetActive(true)
	elseif currentInvite == 0 then -- 关闭
		_ui.allianceInvite.playerInvite.gameObject:SetActive(false)
		_ui.allianceInvite.recommendation.gameObject:SetActive(false)
	else -- 联盟邀请
		local pendingInvite = AllianceInvitesData.GetPendingInvite(currentInvite)
		local numPendingInvites = AllianceInvitesData.GetNumPendingInvites()
		local isFit, wrappedInviterName = _ui.allianceInvite.playerNameWrapper:Wrap(pendingInvite.inviterName, nil, _ui.allianceInvite.playerNameWrapper.height)
		isFit = true;
	    _ui.allianceInvite.playerInvite.message.text = System.String.Format(TextMgr:GetText("ui_inviteunion_code5"), isFit and pendingInvite.inviterName or (wrappedInviterName .. "..."), string.format("[%s]%s", pendingInvite.guildBanner, pendingInvite.guildName))
	    UnionBadge.LoadBadgeById(_ui.allianceInvite.badge, pendingInvite.guildBadge)

	    _ui.allianceInvite.count.text = numPendingInvites
	    _ui.allianceInvite.notice:SetActive(numPendingInvites > 1)
	    _ui.allianceInvite.leftArrow:SetActive(currentInvite > 1)
		_ui.allianceInvite.rightArrow:SetActive(currentInvite < numPendingInvites)

		_ui.allianceInvite.playerInvite.gameObject:SetActive(true)
		_ui.allianceInvite.recommendation.gameObject:SetActive(false)
	end

	if currentInvite ~= 0 then
		ToggleUnionFirst(false)
	else
		OpenJoinUnionFirst()
	end
end

function SetCurrentInvite(index)
	if _ui == nil then
		return
	end
	if index == 0 and currentInvite ~= 0 then
		lastTimeCloseAllianceInvite = Serclimax.GameTime.GetSecTime()
		_ui.allianceInvite.gameObject:SetActive(false)
	elseif index ~= 0 and currentInvite == 0 then
		_ui.allianceInvite.gameObject:SetActive(true)
		_ui.allianceInvite.animation:PlayForward(true)
	end

	currentInvite = index
	RefreshUIAllianceInvite()
end

function HideAllianceInvites()
	SetCurrentInvite(0)
end

function CheckPowerRankBtn()
	if _ui == nil then
		return
	end
	FunctionListData.IsFunctionUnlocked(309, function(isactive)
		if _ui == nil then
			return
		end	
		if isactive then
			_ui.PowerRank.gameObject:SetActive(ActivityData.IsActivityAvailable(1032))
		else
			_ui.PowerRank.gameObject:SetActive(false)
		end
	end)
end

--谏言系统
function shuffle(t)
    if type(t)~="table" then
        return
    end
    local l=#t
    local tab={}
    local index=1
    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end

function CheckWorldMap(isworldmap, callback)
	if not isworldmap then
	    if GUIMgr:IsMenuOpen("WorldMap") then
	        MainCityUI.HideWorldMap(true, callback, true)
		else
			if callback ~= nil then
				callback()
			end
	    end
	elseif isworldmap then
	    if not GUIMgr:IsMenuOpen("WorldMap") then
	        MainCityUI.ShowWorldMap(nil, nil, true, callback)
	    else
	        if callback ~= nil then
				callback()
			end
	    end
	end
end

local advice_timer
local advice_checklist
local advice_cdlist = {}
local advice_coroutine
local advice_repeat
local advice_repeated = 0
local advice_lastcheck = 0
local advice_onclick
local advice_curTime

local function InitAdviceData()
	local checklist = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.AdviceList).value:split(";")
	advice_checklist = {}
	for i, v in ipairs(checklist) do
		local checkitem = v:split(":")
		local checker = {}
		checker.id = tonumber(checkitem[1])
		checker.order = tonumber(checkitem[2])
		checker.cd = tonumber(checkitem[3])
		if advice_checklist[checker.order] == nil then
			advice_checklist[checker.order] = {}
		end
		table.insert( advice_checklist[checker.order], checker )
	end
	advice_timer = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.AdviceTimer).value)
	advice_repeat = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.AdviceLimit).value)
	advice_curTime = Serclimax.GameTime.GetSecTime()
end

local function CheckAdviceCondition(checker)
	if _ui == nil then
		return
	end
	if advice_cdlist[checker.id] ~= nil and advice_cdlist[checker.id] > advice_curTime then
		return false
	end
	if checker.id == 1 then
		if Laboratory.CheckAdvice() then
			SetClickCallback(_ui.advice.btn, function()
				CheckWorldMap(false, function()
					Laboratory.Show()
					advice_onclick(checker.id, checker.cd)
				end)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_1")
			return true
		end
	elseif checker.id == 2 then
		local _building = maincity.GetEmptyBarrackOnly()
		if _building ~= nil then
			SetClickCallback(_ui.advice.btn, function()
				CheckWorldMap(false, function()
					Barrack.Show(_building.data.type)
					advice_onclick(checker.id, checker.cd)
				end)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_2")
			return true
		end
	elseif checker.id == 3 then
		if onlineReward.Glow.gameObject.activeInHierarchy then
			SetClickCallback(_ui.advice.btn, function()
				CheckWorldMap(false, function()
					online.Show()
					advice_onclick(checker.id, checker.cd)
				end)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_3")
			return true
		end
	elseif checker.id == 4 then
		if ArmyListData.CanCureArmy() == 1 then
			local _building = maincity.GetHospital()
			if _building ~= nil then
				SetClickCallback(_ui.advice.btn, function()
					CheckWorldMap(false, function()
						Hospital.SetBuild(_building)
						GUIMgr:CreateMenu("Hospital", false)
						advice_onclick(checker.id, checker.cd)
					end)
				end)
				_ui.advice.text.text = TextMgr:GetText("guide_advice_4")
				return true
			end
		end
	elseif checker.id == 5 then
		local n_free, n_count, n_item = MilitarySchool.HaveFreeCount("normal")
		local s_free, s_count, s_item = MilitarySchool.HaveFreeCount("senior")
		if n_free or s_free then
			SetClickCallback(_ui.advice.btn, function()
				CheckWorldMap(false, function()
					MilitarySchool.Show()
					advice_onclick(checker.id, checker.cd)
				end)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_5")
			return true
		end
	elseif checker.id == 6 then
		if not ActionListData.IsFull() then
			SetClickCallback(_ui.advice.btn, function()
				ShowWorldMap(nil, nil, true)
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_6")
			return true
		end
	elseif checker.id == 7 then
		if --[[HeroListData.HasMoreThanQualityCanLevelUp(4)]] GeneralData.HasGeneralCanLevelUp(4) then
			SetClickCallback(_ui.advice.btn, function()
				HeroList.Show()
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_7")
			return true
		end
	elseif checker.id == 8 then
		if --[[HeroListData.HasMoreThanQualityCanStarUpgrade(4)]] GeneralData.HasGeneralCanStarUp(4) then
			SetClickCallback(_ui.advice.btn, function()
				HeroList.Show()
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_8")
			return true
		end
	elseif checker.id == 9 then
		if --[[HeroListData.HasMoreThanQualityBradgeCanUpgrade(4)]] GeneralData.HasGeneralCanGradeUp(4) then
			SetClickCallback(_ui.advice.btn, function()
				HeroList.Show()
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_9")
			return true
		end
	elseif checker.id == 10 then
		if FunctionListData.IsUnlocked(109) and MilitaryActionData.HasFinishedAllAction(1) then
			SetClickCallback(_ui.advice.btn, function()
				MissionUI.Show(3)
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_10")
			return true
		end
	elseif checker.id == 11 then
		if FunctionListData.IsUnlocked(109) and UnionInfoData.HasUnion() and MilitaryActionData.HasFinishedAllAction(2) then
			SetClickCallback(_ui.advice.btn, function()
				MissionUI.Show(4)
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_11")
			return true
		end
	elseif checker.id == 12 then
		if _ui.rebelsurroundEffect2.gameObject.activeInHierarchy then
			SetClickCallback(_ui.advice.btn, function()
				RebelSurroundNew.Show()
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_12")
			return true
		end
	elseif checker.id == 13 then
		if FunctionListData.IsUnlocked(107) and TalentInfoData.GetCurrentIndexRemainderPoint() > 0 then
			SetClickCallback(_ui.advice.btn, function()
				CheckWorldMap(false, function()
					TalentInfo.Show()
					advice_onclick(checker.id, checker.cd)
				end)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_13")
			return true
		end
	elseif checker.id == 14 then
		if FunctionListData.IsUnlocked(115) and MissionListData.HasDailyMissionNotice() then
			SetClickCallback(_ui.advice.btn, function()
				MissionUI.Show(2)
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_14")
			return true
		end
	elseif checker.id == 15 then
		if FunctionListData.IsUnlocked(110) and RaceData.HasNotice() then
			SetClickCallback(_ui.advice.btn, function()
				ActivityAll.Show("ActivityRace")
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_15")
			return true
		end
	elseif checker.id == 16 then
		if FunctionListData.IsUnlocked(129) and ActivityData.isBattleFieldActivityAvailable(2002) then
			SetClickCallback(_ui.advice.btn, function()
				ActivityAll.Show("Panzer")
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_16")
			return true
		end
	elseif checker.id == 17 then
		if FunctionListData.IsUnlocked(129) and ActivityTreasureData.IsActive() then
			SetClickCallback(_ui.advice.btn, function()
				ActivityAll.Show("ActivityTreasure")
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_17")
			return true
		end
	elseif checker.id == 18 then
		local rebelarmyattackdata = RebelArmyAttackData.GetSiegeMonsterInfo()
		if FunctionListData.IsUnlocked(129) and rebelarmyattackdata ~= nil and rebelarmyattackdata.isOpen then
			SetClickCallback(_ui.advice.btn, function()
				ActivityAll.Show("RebelArmyAttack")
				advice_onclick(checker.id, checker.cd)
			end)
			_ui.advice.text.text = TextMgr:GetText("guide_advice_18")
			return true
		end
	elseif checker.id == 19 then
		if FunctionListData.IsUnlocked(135) then
			if MainData.GetEnergy()>= MainData.GetMaxEnergy() then
				SetClickCallback(_ui.advice.btn, function()
					ChapterSelectUI.ShowExploringChapter()
					advice_onclick(checker.id, checker.cd)
				end)
				_ui.advice.text.text = TextMgr:GetText("guide_advice_19")
				return true
			end
		end
	end
	return false
end

local function CheckAdvice()
	if not FunctionListData.IsUnlocked(134) then
		return
	end
	InitAdviceData()
	coroutine.stop(advice_coroutine)
	advice_coroutine = coroutine.start(function()
		coroutine.wait(advice_timer)
		if _ui == nil then
			return
		end
		for i, v in pairs(advice_checklist) do
			for ii, vv in ipairs(shuffle(v)) do
				if CheckAdviceCondition(vv) then
					if advice_lastcheck == vv.id then
						advice_repeated = advice_repeated + 1
						if advice_repeated >= advice_repeat then
							advice_cdlist[vv.id] = advice_curTime + vv.cd
						end
					else
						advice_repeated = 1
					end
					advice_lastcheck = vv.id
					_ui.advice.go:SetActive(true)
					_ui.advice.tween:Play(true, true)
					_ui.advice.typewriter:ResetToBeginning()
					CheckAdvice()
					return
				end
			end
		end
		CheckAdvice()
	end)
end

advice_onclick = function(id, cd)
	if _ui == nil then
		return
	end
	Starwars.RequestGameLog(2, id)
	advice_cdlist[id] = advice_curTime + cd
	_ui.advice.go:SetActive(false)
	CheckAdvice()
end

--建筑队列提示
local queueTips
local queueTipsText
local notifyShowQueueTips
local notifyShowQueueTipsTime
local queueTipsShowTime = 60
local isQueueOpened = false

local timer = 3
local istime = false

MassTotlaNum = {
    [1] = 0,
    [2] = 0,
}

PreMassTotalNum = {
    [1] = 0,
    [2] = 0,
}

function BringForward()
	if _ui == nil then
		return
	end
	GUIMgr:BringForward(gameObject)
end

local cancelUpgradeBuildingListener = EventListener()

function AddCancelUpgradeListener(listener)
    cancelUpgradeBuildingListener:AddListener(listener)
end

function RemoveCancelUpgradeListener(listener)
    cancelUpgradeBuildingListener:RemoveListener(listener)
end

function NotifyCancelUpgradeListener()
	cancelUpgradeBuildingListener:NotifyListener()
end

function GetPreMassTotalNum()
    if PreMassTotalNum == nil then
        PreMassTotalNum =  {
        [1] = 0,
        [2] = 0,}
    end
    return PreMassTotalNum
end

function SetShowMenuCallBack(bcamera, go, callback, step)
	menuTarget = go
	lastMenuPos = go.transform.position
	cityCamera = bcamera
	showMenuCallBack = callback
	menuStep = step and step or 0
end

local cityMenuListener = EventListener()

function AddCityMenuListener(listener)
    cityMenuListener:AddListener(listener)
end

function RemoveCityMenuListener(listener)
    cityMenuListener:RemoveListener(listener)
end

local function NotifyCityMenuListener(landName)
    cityMenuListener:NotifyListener(landName)
end

function SetJumpMenu(menuName)
	jumpMenu = menuName
end

function HideArrayBar()
	arrayBar.gameObject:SetActive(false)
	arrayBarBgQueue.gameObject:SetActive(false)
end

function ShowArrayBar()
	arrayBar.gameObject:SetActive(true)
end

function HideHeadBar()
	topBar.gameObject:SetActive(false)
end

function ShowHeadBar()
	topBar.gameObject:SetActive(true)
end

--建筑科研队列提醒
function QueueOpened(val)
	isQueueOpened = val
end

local canShowQueueTips = false
function UpdateQueueTips()
	local buildingUpgrade = maincity.GetUpgradingBuildList()
	local laboratoryUpgrade = Laboratory.GetCurUpgradeTech()
	if (not canShowQueueTips) or isQueueOpened or (#buildingUpgrade ~= 0 and laboratoryUpgrade ~= nil) then
		HideQueueTips()
	else
		local tips = ""

		if #buildingUpgrade == 0 and laboratoryUpgrade == nil then
			tips = TextMgr:GetText(Text.queue_text_1)
		elseif #buildingUpgrade == 0 then
			tips = TextMgr:GetText(Text.queue_ui1)
		else
			tips = TextMgr:GetText(Text.queue_ui2)
		end

		queueTipsText.text = tips
		ShowQueueTips()
	end
end

function ShowQueueTips()
	if not notifyShowQueueTips then
		notifyShowQueueTips = true
		notifyShowQueueTipsTime = Serclimax.GameTime.GetSecTime()
	end
end

function HideQueueTips()
	if queueTips ~= nil and not queueTips:Equals(nil) then
		queueTips:SetActive(false)
		notifyShowQueueTips = false
	end
end

function HideBattle()
	btnWar.gameObject:SetActive(false)
    RemoveMenuTarget()
end

function ShowBattle()
	btnWar.gameObject:SetActive(FunctionListData.IsUnlocked(135))
end

local function SetMissionActive(missionActive, mission1Active)
	if _ui == nil then
		return
	end
    _ui.mission.gameObject:SetActive(missionActive)
    _ui.mission1.gameObject:SetActive(false)
end

function HideQuickMission()
	recommendedMissionUI.bg.gameObject:SetActive(false)
	canshowmission = false
	HideStoryTips()
end

function ShowQuickMission()
	if hasmission then
		recommendedMissionUI.bg.gameObject:SetActive(true)
	end
	canshowmission = true
	ShowStoryTips()
end

function HideQuickUpGrade()
	recommendedUpGrdadeUI.bg.gameObject:SetActive(false)
	canshowmission = false
	HideStoryTips()
end

function ShowQuickUpGrade()
	if hasmission then
		recommendedUpGrdadeUI.bg.gameObject:SetActive(true)
	end
	canshowmission = true
	ShowStoryTips()
end

function HideStoryTips()
	if _ui == nil then
		return
	end
	_ui.story.go:SetActive(false)
end

function ShowStoryTips()
	if _ui == nil then
		return
	end
	_ui.story.go:SetActive(_ui.storyNeedShow)
end

function HideOnlineReward()
	onlineReward.bg.gameObject:SetActive(false)
end

function ShowOnlineReward()
	FunctionListData.IsFunctionUnlocked(105, function(isactive)
		--if GameObject.Find("WorldMap") == nil then
			onlineReward.bg.gameObject:SetActive(isactive)
			UpdateOnlineRewardIcon()
		--end
	end)
end

local function UpdateUnionHelp()
    local unionHelpCount = UnionHelpData.GetHelpCount()
    unionHelpUI.countLabel.text = unionHelpCount

    local oldActive = unionHelpUI.transform.gameObject.activeSelf
    local newActive = unionHelpCount > 0
    
    if newActive ~= oldActive then
        if newActive then
            unionHelpUI.transform.gameObject:SetActive(newActive)
            UITweener.ResetAllToBegining(unionHelpUI.button.gameObject, true)
        else
            unionHelpUI.effectObject.gameObject:SetActive(false)
            unionHelpUI.effectObject.gameObject:SetActive(true)
            UITweener.PlayAllTweener(unionHelpUI.button.gameObject, true, true, true)
            unionHelpUI.tweenAlpha:SetOnFinished(EventDelegate.Callback(function()
                unionHelpUI.transform.gameObject:SetActive(newActive)
            end))
		end
		_ui.right_grid:Reposition()
    end

	UpdateCompensateState()
    UpdateNotice()
end

local radarlock = false
function RadarListener(type)
	local warningType = RadarData.GetWarningType()
	if type ~= nil then
		if type == 0 then
			radarlock = false
			coroutine.start(function()
				coroutine.step()
				RadarListener()
			end)
		else
			warningType = type
			radarlock = true
		end
	end
	if radarlock and type == nil then
		return
	end
	for i, v in pairs(warning) do
		v.btn:SetActive(false)
		v.kuang:SetActive(false)
	end
	if warningType > 0 then
		warning[warningType].kuang:SetActive(true)
		warning[warningType].btn:SetActive(true)
		if not warning[warningType].music.isPlaying then
			warning[warningType].music:Play()
		end
	    SetClickCallback(warning[warningType].btn, function(go)
	    	GUIMgr:CreateMenu("Marchlist" , false)
	    end)
	end
	coroutine.start(function()
		coroutine.step()
		if promptList == nil then
		    return
        end
		promptList.Grid:Reposition()
	end)
end

function RadarEffectRed(active)
	warning[2].kuang:SetActive(active)
	warning[2].btn:SetActive(active)
	if not warning[2].music.isPlaying then
		warning[2].music:Play()
	end
	coroutine.start(function()
		coroutine.step()
		if promptList == nil then
		    return
        end
		promptList.Grid:Reposition()
	end)
end

function RadarEffectBlue(active)
	warning[1].kuang:SetActive(active)
	warning[1].btn:SetActive(active)
	if not warning[1].music.isPlaying then
		warning[1].music:Play()
	end
	coroutine.start(function()
		coroutine.step()
		if promptList == nil then
		    return
        end
		promptList.Grid:Reposition()
	end)
end

function RadarSoundOff()
	local warningType = RadarData.GetWarningType()
	if warningType > 0 then
		if warning[warningType].music.isPlaying then
			warning[warningType].music:Stop()
		end
	end
	RadarData.SetWarningOff()
end

function OnEnable()
	if RadarData.GetNeedWarning() then
		local warningType = RadarData.GetWarningType()
		if warningType > 0 then
			if not warning[warningType].music.isPlaying then
				warning[warningType].music:Play()
			end
		end
	end
	local size = AssetBundleManager.Instance:GetNeedLoadSize()
	if not System.String.IsNullOrEmpty(size) then
		btn_update:SetActive(true)
	else
		btn_update:SetActive(false)
	end
end

local commonItemBagEventListener = EventListener()
local function NotifyCommonItemBagListener()
    commonItemBagEventListener:NotifyListener()
end

function AddCommonItemBagListener(listener)
    commonItemBagEventListener:AddListener(listener)
end

function RemoveCommonItemBagListener(listener)
    commonItemBagEventListener:RemoveListener(listener)
end
function UpdateRewardData(data)
	-- --vip体验卡
	-- VipData.VipExperience(data)
	ItemListData.SetExpireTime(data.item.expiretime)
    ItemListData.UpdateData(data.item)
    MoneyListData.UpdateData(data.money.money)
	
    MainData.UpdateData(data.maindata)
    -- HeroListData.UpdateData(data.hero)
    GeneralData.UpdateData(data.hero)
	BuffData.UpdateData(data.buff.data)
	NotifyCommonItemBagListener()
	if Global.GetMobaMode() == 1 then
		MobaMainData.UpdateData(data.mobaMainData)
	elseif Global.GetMobaMode() == 2 then
		MobaMainData.UpdateData(data.guildMobaMainData)
	end
	MobaPackageItemData.UpdateData(data.mobaItem)
	MobaHeroListData.UpdateData(data.mobaHero)
	MobaArmyListData.UpdateData(data.mobaArmy)
end

function UpdateMoneyData(data)
	 MoneyListData.UpdateData(data.money.money)
end

function GetBuildingInfoRoot()
	return transform:Find("Container/buildinginfo")
end

function MassHasNotice()
	if MassTotlaNum[1] <= 0 and MassTotlaNum[2] <=0 then
		return false
	end
    return MassTotlaNum[1] ~= GetPreMassTotalNum()[1] or MassTotlaNum[2] ~= GetPreMassTotalNum()[2]
end

local function UpdateShopNotice()
	noticeList.shop.gameObject:SetActive(Goldstore.HasNotice())
end

function UpdateShopCountdown()
	if _ui ~= nil then
		local timeStamp = Goldstore.GetCountdownTime()
		if timeStamp then
			if not _ui.countdown_purchase.gameObject.activeSelf then
				_ui.countdown_purchase.gameObject:SetActive(true)
			end

			_ui.countdown_purchase.time.text = Global.SecondToTimeLong(timeStamp - lastUpdateTime)
		elseif _ui.countdown_purchase.gameObject.activeSelf then
			_ui.countdown_purchase.gameObject:SetActive(false)
		end
	end
end

local function UpdateMenuNotice()
    local hasHeroNotice = GeneralData.HasNotice()
    noticeList.hero.gameObject:SetActive(hasHeroNotice)

	local hasMailNotice = MailListData.HasNotice()
	noticeList.mail.gameObject:SetActive(hasMailNotice)
	if hasMailNotice then
		local hasMailNewNum = MailListData.HasNewNum()
		noticeList.mailnum.text = hasMailNewNum
	end
	FunctionListData.IsFunctionUnlocked(305, function(isactive)
		if noticeList ~= nil then
			if isactive then
				local hasRuneNotice = RuneData.HasRedPoint() or (RuneData.IsFreeDraw() > 0)
				noticeList.rune.gameObject:SetActive(hasRuneNotice)
			else
				noticeList.rune.gameObject:SetActive(false)
			end
		end
	end)
	
	local hasUnionGift = UnionInfoData.HasUnion() and UnionInfoData.GetActiveGiftCount() > 0
	local hasUnionMass = UnionInfoData.HasUnion() and MassHasNotice()
	local hasDonate = UnionDonateData.HasNotice()
	--local hasUnionSpeLog = NotifyInfoData.HaveNotifyType(ClientMsg_pb.ClientNotifyType_GuildLog)
	local hasUnionSpeOcuupy = UnionInfoData.GetUnionContestNum() > 0
	local unionUnlocked = FunctionListData.IsFunctionUnlocked(106) or MissionListData.HasCompletedMission(10310)
	local hasUnionTec = UnionTechData.GetNormalDonateNotice()
    
    local hasUnionNotice = hasUnionGift or hasUnionMass or hasDonate
    or (unionUnlocked and not UnionInfoData.HasUnion())
    --or hasUnionSpeLog 
    or hasUnionSpeOcuupy 
    or (UnionInfoData.HasUnion() and UnionBuildingData.HasNotice())
	--or UnionHelpData.GetHelpCount() > 0
	or UnionMessage.HasRedPoint()
	or UnionCityData.HasUnclaimedRewards()
	or UnionResourceRequestData.HasNotice()

	--[[
	print("[RED_POINT] QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","UnionGift:",hasUnionGift,
		"UnionMass:",hasUnionMass,"UnionTec:",hasUnionTec,"Donate",hasDonate,
		"Unlocked && not HasUnion : ",(unionUnlocked and not UnionInfoData.HasUnion()),
		"UnionSpeOcuupy: ",hasUnionSpeOcuupy,
		"BuildingData:",(UnionInfoData.HasUnion() and UnionBuildingData.HasNotice()),
		"UnionMessage",UnionMessage.HasRedPoint(),
		"UnclaimedRewards",UnionCityData.HasUnclaimedRewards(),
		"ResourceRequest",UnionResourceRequestData.HasNotice()
	)
	]]
	noticeList.union.gameObject:SetActive(hasUnionNotice)
	
    return hasHeroNotice or hasMailNotice or hasUnionNotice or hasRuneNotice
end

function UpdateNotice()
    if noticeList ~= nil then
		noticeList.main.gameObject:SetActive(UpdateMenuNotice() and not isZhankai)
    end	
	CheckRecommendedUpGrdade()
end

function UpdateMissionNotice()
	if _ui == nil then
		return
	end
    local hasMissionNotice = MissionListData.HasNotice() or MissionListData.HasDailyMissionNotice() or (FunctionListData.IsUnlocked(109) and MilitaryActionData.HasNotice())
    _ui.mission.noticeObject:SetActive(hasMissionNotice)
	_ui.mission1.noticeObject:SetActive(hasMissionNotice)
	local militaryActionCount = FunctionListData.IsUnlocked(109) and MilitaryActionData.GetCompletedCount() or 0
	local missCount = MissionListData.GetCompletedMainMissionCount() + MissionListData.GetCompletedChestCount() + militaryActionCount
	noticeList.missionNum.text = missCount

	--右下角任务红点
	if missCount == 0 then
		noticeList.mission.gameObject:SetActive(false)
	else
		noticeList.mission.gameObject:SetActive(true)
	end
end

function UpdateMilitaryRankNotice()
    bottomMenuList.militaryNotice:SetActive(MilitaryRankData.HasNotice())
end

function UpdateCityMapNotice()
    _ui.cityNotice:SetActive(WorldCityData.HasCollectNotice())
end

-- 战场红点
function SetActivityAllNotice(flag)
	if _ui ~= nil and _ui.activityAllNotice ~= nil and not _ui.activityAllNotice:Equals(nil) then
		_ui.activityAllNotice:SetActive(flag or false)
	end
end

function RefreshActivityAllNotice(id)
	SetActivityAllNotice(ActivityAll.HasNotice())
end

function UpdateActivityAllNotice(id)
	ActivityAll.UpdateNotice(id)
	SetActivityAllNotice(ActivityAll.HasNotice())
end

-- 福利红点
function HasWelfareNotice()
	if _ui ~= nil and _ui.welfareIcon.highlight ~= nil and not _ui.welfareIcon.highlight:Equals(nil) then
		return _ui.welfareIcon.highlight.activeSelf
	end

	return false
end

function SetWelfareNotice(flag)
	if _ui ~= nil and _ui.welfareIcon.highlight ~= nil and not _ui.welfareIcon.highlight:Equals(nil) then
		_ui.welfareIcon.highlight:SetActive(flag)
	end
end

function RefreshWelfareNotice(id)
	WelfareAll.RefreshNotice(id)
	SetWelfareNotice(WelfareData.HasNotice())
end

function UpdateWelfareNotice(id)
	WelfareAll.UpdateNotice(id)
	SetWelfareNotice(WelfareData.HasNotice())
end

-- 商城红点
function UpdateCashShopNotice()
	if _ui ~= nil and _ui.red_purchase ~= nil and not _ui.red_purchase:Equals(nil) then
		_ui.red_purchase:SetActive(store.HasNotice())
	end
end

function UpdateCashShopCountDown(endTime)
	if _ui ~= nil and _ui.countdown_purchase ~= nil then
		_ui.countdown_purchase.text = endTime and Global.GetLeftCooldownTextLong(endTime) or ""
	end
end
-----------

function UpdateBattleReward()
	if _ui == nil then
		return
	end
	_ui.battleReward.gameObject:SetActive(SandSelect.HaveBattleReward())
end

 local function ZhankaiClickCallback(go)
 	HideCityMenu()
 	if isZhankai then
 	    ui.btnZhankai.transform:GetComponents(typeof(UITweener))[0]:PlayReverse(false)
 		ui.btnZhankai.transform:GetComponents(typeof(UITweener))[1]:PlayReverse(false)
 	    tweenZhankaiBottom[0]:PlayReverse(false)
 	    tweenZhankaiBottom[1]:PlayForward(false)
 	    tweenZhankaiRight[0]:PlayReverse(false)
 	    tweenZhankaiRight[1]:PlayForward(false)
 	    isZhankai = false
 	else
 		ui.btnZhankai.transform:GetComponents(typeof(UITweener))[0]:PlayForward(false)
 		ui.btnZhankai.transform:GetComponents(typeof(UITweener))[1]:PlayForward(false)
	    tweenZhankaiBottom[0]:PlayForward(false)
 	    tweenZhankaiBottom[1]:PlayReverse(false)
 	    tweenZhankaiRight[0]:PlayForward(false)
 	    tweenZhankaiRight[1]:PlayReverse(false)
 	    isZhankai = true
 	end
 	UpdateNotice()
 end

function Shousuo()
 	--[[if ui.btnZhankai ~= nil and not ui.btnZhankai:Equals(nil) and isZhankai then
-- --		ui.btnZhankai.gameObject:GetComponent("UITweener"):PlayReverse(false)
 	    ui.btnZhankai.transform:GetComponents(typeof(UITweener))[0]:PlayReverse(false)
 		ui.btnZhankai.transform:GetComponents(typeof(UITweener))[1]:PlayReverse(false)		
 	    tweenZhankaiBottom[0]:PlayReverse(false)
 	    tweenZhankaiBottom[1]:PlayForward(false)
 	    tweenZhankaiRight[0]:PlayReverse(false)
 	    tweenZhankaiRight[1]:PlayForward(false)
 	    isZhankai = false
         UpdateNotice()
 	end
	]]
end

function GetZhankai()
	return ui.btnZhankai
end

function GetBottomMenuList()
	return bottomMenuList
end

local function ShowWorldMapPreViewInternal(mapX, mapY, status, callback)
    if terrain == nil then
        terrain = ResourceLibrary:GetWorldTerrainPrefab("3DTerrain_Preview")
        terrain = GameObject.Instantiate(terrain)
    end
    MapMask.Show(mapX, mapY, status, callback)
	-- GUIMgr:BringForward(gameObject)
end

local function UpdateMainData(isInWorldMap)
	if _ui == nil then
		return
	end
    local mainData = MainData.GetData()
	_ui.iconPlayer.mainTexture = ResourceLibrary:GetIcon("Icon/head/", mainData.face)
	GOV_Util.SetFaceUI(_ui.MilitaryRank,mainData.militaryRankId)
	
	_ui.headNoticeObject:SetActive(MainData.HasPendingRansom())
    local commanderInfo = MainData.GetCommanderInfo()
    local captured = commanderInfo.captived ~= 0
	_ui.prisonObject:SetActive(captured)
	if ConfigData.GetVipExperienceCard() then
		labelVip.text = MainData.GetVipLevel()
	else
		if MainData.GetVipValue().viplevelTaste <= MainData.GetVipLevel() then
			labelVip.text = MainData.GetVipLevel()
		else
			labelVip.text = MainData.GetVipValue().viplevelTaste
		end		
	end
	
	
	mainLevel.text = "LV." .. MainData.GetLevel()
	
	local fight = topBar:Find("bg_power/bg_msg/num"):GetComponent("UILabel")
	fight.text = mainData.pkvalue--"111111111"--MainData.GetFight()
	_ui.powervalue = mainData.pkvalue
	-- if level up
	local lastLv = MainData.GetSavedLevel()
	local curLv = MainData.GetLevel()
	--print("l:" .. lastLv .. "cur:" .. curLv)
	if curLv > lastLv then
        PlayerLevelup.SetLevelContent(curLv , lastLv)
		PlayerLevelup.Show()
	end
	
	if isInWorldMap or GUIMgr:IsMenuOpen("WorldMap") then
		iconEnergy.spriteName = "proactive"
		labelEnergy.text = string.format("%d/%d", MainData.GetSceneEnergy(), MainData.GetMaxSceneEnergy())
		SetClickCallback(iconEnergy.gameObject, function()
			_ui.EnergyTipRoot:SetActive(true)
		end)
	else
		iconEnergy.spriteName = "icon_physical"
		labelEnergy.text = string.format("%d/%d", MainData.GetEnergy(), MainData.GetMaxEnergy())
		SetClickCallback(iconEnergy.gameObject, function()
			_ui.EnergyTipRoot:SetActive(true)
		end)
	end
end

local function ShowWorldMapInternal(mapX, mapY,preview_build_data)
    btnMap.gameObject:SetActive(false)
	maincity.Hide()	
	coroutine.step()
	ShowHeadBar()
	coroutine.step()
	UpdateMainData(true)
	coroutine.step()
	LoadingMap.ReadyHide()
	if terrain == nil then
		terrain = Global.Load3DTerrain();
        --terrain = ResourceLibrary:GetWorldTerrainPrefab("3DTerrain")
        terrain = GameObject.Instantiate(terrain)
    end
	WorldMap.Show(mapX, mapY,preview_build_data)
	coroutine.step()
	--添加邮件监听
	MailListData.AddListener(PVP_Rewards.CheckPvpShow)	
	coroutine.step()
	GUIMgr:BringForward(gameObject)
	LoadingMap.Hide()
end
--[[
local function ShowRebelSurroundInternal(mapX,mapY,enterCallback)
    HideMainCityUIBtn()
    --btnMap.gameObject:SetActive(false)
    maincity.Hide()
    if terrain == nil then
        terrain = ResourceLibrary:GetWorldTerrainPrefab("3DTerrain_Local")
        terrain = GameObject.Instantiate(terrain)
    end
    RebelSurround.Show(mapX, mapY,enterCallback)
end
--]]
local function OnCheckPercent(value)
	if _ui == nil then
		return
	end
	update_ui.OnCheckPercent(value)
end

local function OnBundleLoad(value)
	if _ui == nil then
		return
	end
	update_ui.OnBundleLoad(value)
end

function ShowMainCityUIBtn()
    if bg ~= nil then
        bg.gameObject:SetActive(true)
    end
end

function HideMainCityUIBtn()
    if bg ~= nil then
        bg.gameObject:SetActive(false)
    end    
end

function ShowWorldMapPreView(mapX, mapY, status, finishCallback)
	ShowWorldMapPreViewCoroutine = coroutine.start(function()			
		Global.OpenTopUI(update_ui)
		AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent + OnCheckPercent
		AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad + OnBundleLoad
		while AssetBundleManager.Instance.ischecking do
			coroutine.step()
		end
		AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent - OnCheckPercent
		AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad - OnBundleLoad
		Global.CloseUI(update_ui)

		if status ~= 1 then
			LoadingMap.Show(finishCallback)	
			ShowWorldMapPreViewInternal(mapX, mapY, status, function() LoadingMap.ReadyHide() end)
			LoadingMap.Hide()
					
		else 
			ShowWorldMapPreViewInternal(mapX, mapY, status, finishCallback)		
		end
	end)
end
--[[
function ShowRebelSurround(mapX, mapY, playAnim, finishCallback)
	ShowRebelSurroundCoroutine = coroutine.start(function()			
		Global.OpenTopUI(update_ui)
		AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent + OnCheckPercent
		AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad + OnBundleLoad
		while AssetBundleManager.Instance.ischecking do
			coroutine.step()
		end
		AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent - OnCheckPercent
		AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad - OnBundleLoad
		Global.CloseUI(update_ui)
		
		if playAnim then
			LoadingMap.Show(finishCallback)			
			coroutine.step()
		end
		
			ResourceLibrary.GetUIPrefab("RebelSurround/RebelSurround")
			local worldMapIsClose =  terrain == nil
			local rebelSurroundIsClose = RebelSurround.gameObject == nil or RebelSurround.gameObject:Equals(nil)
			if worldMapIsClose then
				if rebelSurroundIsClose then
					ShowRebelSurroundInternal(mapX, mapY, function() LoadingMap.ReadyHide() end)
				else
					LoadingMap.ReadyHide()
				end
			else
				if rebelSurroundIsClose then
					HideWorldMap(playAnim)
					ShowRebelSurroundInternal(mapX, mapY,function() LoadingMap.ReadyHide() end)
				else
					LoadingMap.ReadyHide()
				end
			end
			if playAnim == false then
				if finishCallback ~= nil then
					finishCallback()
				end
			end
		end)

end
--]]

local function ShowWorldMap4Moba(mapX, mapY, playAnim, finishCallback,preview_build_data)

	local moba_mode_name = "";
	local moba_main_entry = nil
	local moba_main_data = nil
	if Global.GetMobaMode() == 1 then
		moba_mode_name = "MobaMain"
		moba_main_entry = MobaMain
		moba_main_data = MobaMainData
	elseif Global.GetMobaMode() == 2 then
		moba_mode_name = "GuildWarMain"
		moba_main_entry = GuildWarMain
		moba_main_data = MobaMainData
	    if MobaMainData.GetData() == nil then
			mapX = 121
			mapY = 34
		end	
	end
	
	if GUIMgr:IsMenuOpen(moba_mode_name) then
		print("-------------------------ShowWorldMap4Moba-IsMenuOpen------------------------")
		if mapX ~= nil and mapY ~= nil then
			if moba_main_entry ~= nil then
				moba_main_entry.LookAt(mapX, mapY,true)
				moba_main_entry.SelectTile(mapX, mapY)
			end
		end
		if finishCallback ~= nil then
			finishCallback()
		end	
		return
	end	
	print("-------------------------ShowWorldMap4Moba-------------------------")
	Global.DisableUI()
	maincity.Hide()	
	LoadingMap.Show()
	Global.RequestEnterMap(function(inited)
		if inited then
		Global.RequestMobaData(function()
			local nullState = GameStateNull.Instance
			Main.Instance:ChangeGameState(nullState,"",function()
				ShowWorldMapCoroutine = coroutine.start(function()
	
					coroutine.step()
	
					UnityEngine.RenderSettings.ambientLight = NGUIMath.HexToColor(0x8B96ACFF)
	
					Global.OpenTopUI(update_ui)
					AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent + OnCheckPercent
					AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad + OnBundleLoad
					while AssetBundleManager.Instance.ischecking do
						coroutine.step()
					end
					AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent - OnCheckPercent
					AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad - OnBundleLoad
					Global.CloseUI(update_ui)
	
					-- ResourceLibrary.GetUIPrefab("WorldMap/WorldMap")
					MainCityUI.HideCityMenu()
					-- MainCityUI.HideHeadBar()
					MainCityUI.HideArrayBar()
					MainCityUI.HideBattle()
					MainCityUI.HideOnlineReward()
					MainCityUI.CloseJionUnionFirst()
					MainCityUI.HideQuickMission()
	
					--coroutine.step()
					coroutine.step()
				
		
					if playAnim then
						coroutine.step()
					end
		
					btnMap.gameObject:SetActive(false)
		
					if playAnim then
						coroutine.step()
					end
		
					LoadingMap.ReadyHide()
				
					if terrain == nil then
						if Global.GetMobaMode() == 1 then
							terrain = Global.Load3DTerrain4Moba();
						elseif Global.GetMobaMode() == 2 then
							terrain = Global.Load3DTerrain4GuildMoba();
						end
						terrain = GameObject.Instantiate(terrain)
					end
					coroutine.wait(1)
					ShowHeadBar()
					if playAnim then
						coroutine.step()
					end
					UpdateMainData(true)
					if playAnim then
						coroutine.step()
					end
					if moba_main_entry ~= nil and moba_main_data ~= nil then
						if moba_main_data.GetData() ~= nil and moba_main_data.GetData().code == 0 and moba_main_data.GetData().sceneId ~= 0 then
							local o_x,o_y = moba_main_entry.MobaMinPos()
							mapX = moba_main_data.GetData().pos.x + o_x
							mapY = moba_main_data.GetData().pos.y + o_y
						end
						
					end
					if moba_main_entry ~= nil then
						print(mapX,mapY)
						moba_main_entry.Show(mapX, mapY,preview_build_data)
					end
					if playAnim then
						coroutine.step()
					end
		
					--添加邮件监听
					MailListData.AddListener(PVP_Rewards.CheckPvpShow)	
					if playAnim then
						coroutine.step()
					end
					GUIMgr:BringForward(gameObject)
					LoadingMap.Hide()
		
					if mapX ~= nil and mapY ~= nil then
						if moba_main_entry ~= nil then
							moba_main_entry.LookAt(mapX, mapY)
							moba_main_entry.SelectTile(mapX, mapY)					
						end
					end
					HideBattle()
					if finishCallback ~= nil then
						finishCallback()
					end
					Global.EnableUI()
				
					MainCityUI.HideQuickMission()
					bg.gameObject:SetActive(false)
				end)
			end)	
		end)
		else
			LoadingMap.ReadyHide()
			maincity.Show()
			LoadingMap.Hide()
		end
	end)

end


function ShowWorldMap(mapX, mapY, playAnim, finishCallback,preview_build_data)    
	print("ShowWorldMap ",mapX,mapY)
	if Global.IsSlgMobaMode() then
		ShowWorldMap4Moba(mapX, mapY, playAnim, finishCallback,preview_build_data)
		return;
	end
	if GUIMgr:IsMenuOpen("WorldMap") then
		if mapX ~= nil and mapY ~= nil then
			WorldMap.LookAt(mapX, mapY)
			WorldMap.SelectTile(mapX, mapY)
		end
		if finishCallback ~= nil then
			finishCallback()
		end	
		return
	end	
	Global.DisableUI()
	maincity.Hide()	
	LoadingMap.Show()
    local nullState = GameStateNull.Instance
	Main.Instance:ChangeGameState(nullState,"",function()
		ShowWorldMapCoroutine = coroutine.start(function()

			coroutine.step()

			UnityEngine.RenderSettings.ambientLight = NGUIMath.HexToColor(0x8B96ACFF)

			Global.OpenTopUI(update_ui)
			AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent + OnCheckPercent
			AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad + OnBundleLoad
			while AssetBundleManager.Instance.ischecking do
				coroutine.step()
			end
			AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent - OnCheckPercent
			AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad - OnBundleLoad
			Global.CloseUI(update_ui)

			-- ResourceLibrary.GetUIPrefab("WorldMap/WorldMap")
			MainCityUI.HideCityMenu()
			-- MainCityUI.HideHeadBar()
			MainCityUI.HideArrayBar()
			MainCityUI.HideBattle()
			MainCityUI.HideOnlineReward()
			MainCityUI.CloseJionUnionFirst()
			MainCityUI.HideQuickMission()

			--coroutine.step()

			
				
			coroutine.step()
			
	
			if playAnim then
				coroutine.step()
			end
	
			btnMap.gameObject:SetActive(false)
	
			if playAnim then
				coroutine.step()
			end
	
			LoadingMap.ReadyHide()
			
			if terrain == nil then
				terrain = Global.Load3DTerrain();
				--terrain = ResourceLibrary:GetWorldTerrainPrefab("3DTerrain")
				terrain = GameObject.Instantiate(terrain)
			end
			coroutine.wait(1)
			ShowHeadBar()
			if playAnim then
				coroutine.step()
			end
			UpdateMainData(true)
			if playAnim then
				coroutine.step()
			end
            if not MapInfoData.HasBase() then
                MapInfoData.RequestData(true , RequestHomeExile)

                while not MapInfoData.HasBase() do
                    coroutine.step()
                end
                if mapX == 0 and mapY == 0 then
                    local pos = MapInfoData.GetMyBasePos()
                    mapX = pos.x
                    mapY = pos.y
                end
            else
                RequestHomeExile()
            end
	
			WorldMap.Show(mapX, mapY,preview_build_data)
			if playAnim then
				coroutine.step()
			end
	
			--添加邮件监听
			MailListData.AddListener(PVP_Rewards.CheckPvpShow)	
			if playAnim then
				coroutine.step()
			end
			GUIMgr:BringForward(gameObject)
			LoadingMap.Hide()
	
			if mapX ~= nil and mapY ~= nil then
				WorldMap.LookAt(mapX, mapY)
				WorldMap.SelectTile(mapX, mapY)
			end
			HideBattle()
			if finishCallback ~= nil then
				finishCallback()
			end
			Global.EnableUI()
			
			MainCityUI.HideQuickMission()
			ActionListData.RequestData()
		end)
	end)	

end




local IgnorMenu = {"WorldMap" , "WarZoneMap" , "SevenDay" , "ThirtyDay"}
function MainCityUIActiveNotify()
	--print( #(IgnorMenu))
	if not NotifyInfoData.HasNotifyPush(ClientMsg_pb.ClientNotifyType_HomeSeBurn) then
		return
	end
	
	if not Main.Instance:IsInMainState() then
		print("not in main state")
		return
	end
		
	--当前UI为MainCityUI时才触发
	for i=1 , #(IgnorMenu) do
		if GUIMgr:FindMenu(IgnorMenu[i]) ~= nil then
			print("ignor:" .. IgnorMenu[i])
			return
		end
	end

	NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeSeBurn , CheckNotiffyHomeBurn)
	print("IS COMING!!!")
end


function MainCityUIJoinUnionNotify(callback)
	local req = GuildMsg_pb.MsgGuildLeaderInfoRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildLeaderInfoRequest, req, GuildMsg_pb.MsgGuildLeaderInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			if msg.isExile then
				return
			end
            if callback ~= nil then
                callback(msg.leaderInfo)
            end
        end
    end, false)
end


function DecodeTest1()
	local data  = Global.GGUIMgr:HexStringToByteArray(function(_data)
		--local msg = MapMsg_pb.SceneMapGuildFieldResponse()
		local msg = ShopMsg_pb.MsgIAPGoodInfoResponse()
	
		msg:ParseFromString(_data)
		Global.DumpMessage(msg , "d:/decodeTest.lua")
	end)
	
	
	--local req = BattleMsg_pb.MsgFreshBattleCountRequest();
	--msg:ParseFromString(data)
	--Global.DumpMessage(msg , "d:/decodeTest.lua")
end

function DecodeTest(data)
	
end


function CheckAndRequestNotfy()
	if GUIMgr:IsInMainCityUI() then
		local juNotifies = {}
		NotifyInfoData.GetNotifyInfo(ClientMsg_pb.ClientNotifyType_JoinGuild , juNotifies)
		
		print("joinguide notify:".. #juNotifies)
		if NotifyInfoData.HasNotifyPush(ClientMsg_pb.ClientNotifyType_JoinGuild) then
			MainCityUIJoinUnionNotify(function(leaderInfo)
				NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_JoinGuild , function()
					NotifyInfoData.ClearNotify(ClientMsg_pb.ClientNotifyType_JoinGuild)
					UnionGuide.Show(leaderInfo , UnionGuide.ShowPage.UnionPage)
					
			print("111111111")
					UnionCardData.RequestData(0)
				end)
			end)
		elseif #juNotifies > 0 then
			MainCityUIJoinUnionNotify(function(leaderInfo)
				NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_JoinGuild , function()
					UnionGuide.Show(leaderInfo , UnionGuide.ShowPage.UnionPage)
					
			print("111111111")
					UnionCardData.RequestData(0)
				end)
			end)
		end

		if store.HasNewTimedGiftPack() then
			store.ShowNewTimedGiftPack()
		end

		-- 限时礼包
		-- local unshownGiftPacks = GiftPackData.GetUnshownLimitedGoods()
		-- if #unshownGiftPacks > 0 then
		-- 	TimedBag.Show(unshownGiftPacks)
		-- end
	else
		print("not in MaincityUI")
	end
end

function RequestJoinUnionNotify()
	--登录时只能先请求notify
	print("request notu")
	NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_JoinGuild , function()
		if not GUIMgr.Instance:IsInMainCityUI() then
			print("not in MainCityUI")
			return
		end
	
		local juNotifies = {}
		NotifyInfoData.GetNotifyInfo(ClientMsg_pb.ClientNotifyType_JoinGuild , juNotifies)
		if #juNotifies > 0 then
			local req = GuildMsg_pb.MsgGuildLeaderInfoRequest()
			Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildLeaderInfoRequest, req, GuildMsg_pb.MsgGuildLeaderInfoResponse, function(msg)
				if msg.code == ReturnCode_pb.Code_OK then
					
			print("111111111")
					UnionCardData.RequestData(0)
					if msg.isExile then
						return
					end
					UnionGuide.Show(msg.leaderInfo , UnionGuide.ShowPage.UnionPage)
				end
			end, false)
		end
	end)
end

function DestroyTerrain()
    if terrain ~= nil then
		GameObject.Destroy(terrain.gameObject)
        terrain = nil
    end 
end

function UpdateRebelSurroundRed()
	if _ui ~= nil then
		_ui.rebelsurroundRed.gameObject:SetActive(RebelSurroundData.GetCanTakeRewardCount() ~= 0 )
	end	
end

--[[
HideWorldMapPreViewInternal = function()
	if destroyTerrain then
        DestroyTerrain()
	end
	maincity.gameObject:SetActive(true)
	MainCityUI.gameObject:SetActive(true)
end
--]]

local function HideRebelSurroundInternal(destroyTerrain)
	UpdateRebelSurroundRed()
    btnMap.gameObject:SetActive(true)
    if destroyTerrain then
		DestroyTerrain()
    end
    RebelSurround.Hide()
    maincity.Show()
end

function WorldMapCloseCallback()
	MainCityUIActiveNotify()
	--OnJoinUnionNotify()
end
--[[
function HideWorldMapPreView(playAnim, finishCallback, destroyTerrain)
	if playAnim then
		LoadingMap.Show(finishCallback)
		HideWorldMapPreViewInternal(destroyTerrain)
		LoadingMap.ReadyHide()
        -- if finishCallback ~= nil then
        --     finishCallback()
        -- end
    else
        HideWorldMapPreViewInternal(destroyTerrain)
        if finishCallback ~= nil then
            finishCallback()
        end
    end
end
--]]

function CloseAllMenu(IgnorMeunList)
	local colse_names = {}
	for i=0, GUIMgr.UIRoot.transform.childCount-1 do
		local name = GUIMgr.UIRoot.transform:GetChild(i).gameObject.name
		if IgnorMeunList == nil or IgnorMeunList[name] == nil then
			table.insert(colse_names,name)
			--GUIMgr:CloseMenu(name)
		end
	end
	for i=0, GUIMgr.UITopRoot.transform.childCount-1 do
		local name = GUIMgr.UITopRoot.transform:GetChild(i).gameObject.name

		if IgnorMeunList == nil or IgnorMeunList[name] == nil then
			table.insert(colse_names,name)
		end
	end	

	for i=1,#colse_names do
		GUIMgr:CloseMenu(colse_names[i])
	end
end


local function RemoveMobaAttrbuteModules()
	local removeList = {"MobaTechData" , "MobaBuffData" , "MobaBattleMove" , "MobaHeroListData"}
	for _ , v in pairs(removeList) do
		if v then
			AttributeBonus.RemoveAttBonusModule(v)
		end
	end			
end

function HideWorldMap(playAnim, finishCallback, destroyTerrain)


    if GUIMgr:IsMenuOpen("WorldMap") then
		LoadingMap.Show()

		local mainState = GameStateMain.Instance
		Main.Instance:ChangeGameState(mainState,"",function()
			HideWorldMapInternalCoroutine = coroutine.start(function()		
				MailListData.RemoveListener(PVP_Rewards.CheckPvpShow)
				btnMap.gameObject:SetActive(true)

				if destroyTerrain then
					DestroyTerrain()
				end
				coroutine.step()
				bg.gameObject:SetActive(true)
				LoadingMap.ReadyHide()
				WorldMap.Hide()
				coroutine.step()
				maincity.Show()
				coroutine.step()
				UpdateMainData()
				LoadingMap.Hide()
				if finishCallback ~= nil then
					finishCallback()
				end
			end)
		end)		
	elseif GUIMgr:IsMenuOpen("MobaMain") then
		CloseAllMenu({["MainCityUI"]=true,["Camera"]=true,["fps"]=true,["FloatTextRoot"]=true,["Mobaconclusion"]=true,
		["Reporter"]=true,["Notice_Tips"]=true,["MessageBox"]=true,["LuaConsole"]=true,["MobaMain"] = true})
		LoadingMap.Show()

		local mainState = GameStateMain.Instance
		Main.Instance:ChangeGameState(mainState,"",function()
			HideWorldMapInternalCoroutine = coroutine.start(function()	
				MobaData.RequestMobaMatchInfo()
				local mainState = GameStateMain.Instance
				local v = Vector2(0, 0)
				RemoveMobaAttrbuteModules()
				MapInfoData.SetMyBasePos(v)
				bg.gameObject:SetActive(true)
				MailListData.RemoveListener(PVP_Rewards.CheckPvpShow)
				btnMap.gameObject:SetActive(true)

				if destroyTerrain then
					DestroyTerrain()
				end
				
				LoadingMap.ReadyHide()
				WorldMap.Hide()
				MobaMain.Hide()
				maincity.Show()
				UpdateMainData()
				LoadingMap.Hide()
				if finishCallback ~= nil then
					finishCallback()
				end				
			end)
		end)
	elseif GUIMgr:IsMenuOpen("GuildWarMain") then
		CloseAllMenu({["MainCityUI"]=true,["Camera"]=true,["fps"]=true,["FloatTextRoot"]=true,["Mobaconclusion"]=true,
		["Reporter"]=true,["Notice_Tips"]=true,["MessageBox"]=true,["LuaConsole"]=true,["GuildWarMain"] = true})
		LoadingMap.Show()
-----------------------------------------
local req = GuildMobaMsg_pb.GuildMobaQuitMapRequest()
Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaQuitMapRequest, req, GuildMobaMsg_pb.GuildMobaQuitMapResponse, function(msg)
	print("GuildMobaQuitMapRequestGuildMobaQuitMapRequest ",msg.code == ReturnCode_pb.Code_OK)
	if msg.code == ReturnCode_pb.Code_OK then
		local mainState = GameStateMain.Instance
		Main.Instance:ChangeGameState(mainState,"",function()
			HideWorldMapInternalCoroutine = coroutine.start(function()	
				MobaData.RequestMobaMatchInfo()
				local mainState = GameStateMain.Instance
				local v = Vector2(0, 0)
				RemoveMobaAttrbuteModules()
				MapInfoData.SetMyBasePos(v)
				bg.gameObject:SetActive(true)
				MailListData.RemoveListener(PVP_Rewards.CheckPvpShow)
				btnMap.gameObject:SetActive(true)
				if destroyTerrain then
					DestroyTerrain()
				end
				
				LoadingMap.ReadyHide()
				WorldMap.Hide()
				GuildWarMain.Hide()
				maincity.Show()
				UpdateMainData()
				LoadingMap.Hide()
				if finishCallback ~= nil then
					finishCallback()
				end				
			end)
		end)
	end
end, true)
-------------------------------------------
    else
        bg.gameObject:SetActive(true)
		MailListData.RemoveListener(PVP_Rewards.CheckPvpShow)
        btnMap.gameObject:SetActive(true)
        if destroyTerrain then
            DestroyTerrain()
        end
        LoadingMap.ReadyHide()
        WorldMap.Hide()
		MobaMain.Hide()
        maincity.Show()
        UpdateMainData()
        LoadingMap.Hide()
        if finishCallback ~= nil then
            finishCallback()
        end
	end
	print("_________________________SetSlgMobaMode false ")
	Global.SetSlgMobaMode(0)
end

function HideRebelSurround(playAnim, finishCallback, destroyTerrain)
	if playAnim then
		LoadingMap.Show(finishCallback)
		HideRebelSurroundInternal(destroyTerrain)
		LoadingMap.ReadyHide()
        -- if finishCallback ~= nil then
        --     finishCallback()
        -- end
    else
        HideRebelSurroundInternal(destroyTerrain)
        if finishCallback ~= nil then
            finishCallback()
        end
    end
end
--]]
function UpdateRebelSurroundEffect()
	FunctionListData.IsFunctionUnlocked(130, function(isactive)
	if _ui == nil then
		return
	end
	if isactive then
		local data = RebelSurroundNewData.GetNemesisInfo()
		if data == nil then
			if _ui.rebelsurroundEffect ~= 0 then
				_ui.rebelsurroundEffect = 0
				_ui.rebelsurroundEffect1.gameObject:SetActive(false)
				_ui.rebelsurroundEffect2.gameObject:SetActive(false)
			end			
			return
		end
		if data.passAll then
			if _ui.rebelsurroundEffect ~= 0 then
				_ui.rebelsurroundEffect = 0
				_ui.rebelsurroundEffect1.gameObject:SetActive(false)
				_ui.rebelsurroundEffect2.gameObject:SetActive(false)
			end			
			return
		end
		if Serclimax.GameTime.GetSecTime() < data.levelInfo.startTime then
			if _ui.rebelsurroundEffect ~= 1 then
				_ui.rebelsurroundEffect = 1
				_ui.rebelsurroundEffect1.gameObject:SetActive(true)
				_ui.rebelsurroundEffect2.gameObject:SetActive(false)
			end

			CountDown.Instance:Add("UpdateRebelSurroundEffect",data.levelInfo.startTime,CountDown.CountDownCallBack(function(t)
				if data.levelInfo.startTime+1 - Serclimax.GameTime.GetSecTime() <= 0 then
					CountDown.Instance:Remove("UpdateRebelSurroundEffect")
					if _ui.rebelsurroundEffect ~= 2 then
						_ui.rebelsurroundEffect = 2
						_ui.rebelsurroundEffect1.gameObject:SetActive(false)
						_ui.rebelsurroundEffect2.gameObject:SetActive(true)
					end
				end			
			end)) 
		else
			if _ui.rebelsurroundEffect ~= 2 then
				_ui.rebelsurroundEffect = 2
				_ui.rebelsurroundEffect1.gameObject:SetActive(false)
				_ui.rebelsurroundEffect2.gameObject:SetActive(true)
			end
		end
	end
end)	
end

local lastSurroundWave = 0
local isLastSurroundArrived = false
local ShowSurroundAdvanceCoroutine
isSurroundAdvanceActive = false
local function ShowSurroundAdvance(data)
	if isSurroundAdvanceActive then
		return
	end
	coroutine.stop(ShowSurroundAdvanceCoroutine)
	ShowSurroundAdvanceCoroutine = coroutine.start(function()
		if transform == nil then
			return
		end
		local topMenu = GUIMgr:GetTopMenuOnRoot()
		while not loginfinish or topMenu == nil or topMenu.name ~= transform.name or #uiPopUps > 0 or currentInvite ~= 0 do
			coroutine.step()
			topMenu = GUIMgr:GetTopMenuOnRoot()
			if topMenu.name == "RebelSurroundNew_advance" then
				return
			end
		end
		isSurroundAdvanceActive = true
		local curtime = Serclimax.GameTime.GetSecTime()
		if data.win then
			isLastSurroundArrived = true
			isSurroundAdvanceActive = false
		elseif lastSurroundWave ~= data.wave and data.pathArriveTime > curtime then
			isLastSurroundArrived = false
			if ConfigData.GetRebelSurroundConfig() == 0 then
				ConfigData.SetRebelSurroundConfig(1)
				local story = {}
				local s = {}
				s.person = "icon_guide"
				s.speak = "tutorial_140"
				table.insert(story, s)
				s = {}
				s.person = "bg_Baruch"
				s.speak = "tutorial_141"
				table.insert(story, s)
				s = {}
				s.person = "icon_guide_male"
				s.speak = "tutorial_142"
				table.insert(story, s)
				s = {}
				s.person = "icon_guide_male"
				s.speak = "tutorial_143"
				table.insert(story, s)
				Story.ShowMultiple(story, function()
					CheckWorldMap(true, function()
						WorldMapMgr.Instance:FollowRebelSurround()
						WorldMap.SetRebelSurroundCallback(RebelSurroundNew_advance.Show)
						isSurroundAdvanceActive = false
					end)
				end)
			else
				RebelSurroundNew_advance.Show()
				isSurroundAdvanceActive = false
			end
		elseif not isLastSurroundArrived and data.pathArriveTime <= curtime then
			isLastSurroundArrived = true
			local bigcollider = NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/BigCollider"))
			RadarListener(2)
			coroutine.wait(2)
			GameObject.DestroyImmediate(bigcollider)
			RadarListener(0)
			if ConfigData.GetRebelSurroundConfig() ~= 2 then
				ConfigData.SetRebelSurroundConfig(2)
				local story = {}
				local s = {}
				s.person = "bg_Baruch"
				s.speak = "tutorial_144"
				table.insert(story, s)
				s = {}
				s.person = "icon_guide"
				s.speak = "tutorial_145"
				table.insert(story, s)
				s = {}
				s.person = "icon_guide"
				s.speak = "tutorial_146"
				table.insert(story, s)
				Story.ShowMultiple(story, function()
					RebelSurroundNew_advance.Show(function()
						if _ui == nil then
							isSurroundAdvanceActive = false
							return
						end
						GrowGuide.Show(_ui.rebelsurround, nil, true)
						isSurroundAdvanceActive = false
					end)
				end)
			else
				RebelSurroundNew_advance.Show()
				isSurroundAdvanceActive = false
			end
		else
			isSurroundAdvanceActive = false
		end
		lastSurroundWave = data.wave
	end)
end

function CheckHotTime()
	local hotBuff = BuffData.GetActiveHotTimeBuff()
	FunctionListData.IsFunctionUnlocked(146, function(isactive)
		if _ui == nil or _ui.hotTime == nil or _ui.hotTime:Equals(nil) then
			return
		end
		_ui.hotTime.gameObject:SetActive(isactive)
		if isactive then
			_ui.hotTime.gameObject:SetActive(hotBuff ~= nil)
			if hotBuff == nil then
				return
			end
			
			local buffBaseData = TableMgr:GetSlgBuffData(hotBuff.buffId)
			_ui.hotTime.spriteName = buffBaseData.icon
			_ui.activityLeftGrid:Reposition()
			_ui.hotTimeLeft = hotBuff.time
		end
	end)
end

function RequestNCheckHotTime()
	BuffData.RequestData(CheckHotTime)
end


function CheckRebelSurroundBtn()
	CountDown.Instance:Remove("UpdateRebelSurroundTime")
	FunctionListData.IsFunctionUnlocked(130, function(isactive)
		if _ui == nil then
			return
		end
		if isactive then
			local data = RebelSurroundNewData.GetNemesisInfo()
			if data == nil then
				return
			end
			if _ui.rebelsurround == nil then
				_ui.rebelsurround = transform:Find("Container/bg_activityleft/Grid/btn_rebelsurround")
			end
			local curtime = Serclimax.GameTime.GetSecTime()
			if data.wave >= data.MaxWave and data.takeReward then
				_ui.rebelsurround.gameObject:SetActive(false)
			else
				if data.pathStartTime > curtime + 2 then
					_ui.rebelsurround.gameObject:SetActive(false)
				else
					_ui.rebelsurround.gameObject:SetActive(true)
					if data.pathArriveTime > curtime then
						_ui.rebelsurroundText.gameObject:SetActive(true)
						CountDown.Instance:Add("UpdateRebelSurroundTime",data.pathArriveTime,CountDown.CountDownCallBack(function(t)
							_ui.rebelsurroundText.text = "[ff0000]" .. t .. "[-]"
						end))
						_ui.rebelsurroundEffect1.gameObject:SetActive(true)
						_ui.rebelsurroundEffect2.gameObject:SetActive(false)
					else
						_ui.rebelsurroundEffect1.gameObject:SetActive(false)
						_ui.rebelsurroundEffect2.gameObject:SetActive(true)
						_ui.rebelsurroundText.text = "[ff0000]" .. TextMgr:GetText("RebelSurround_new_2") .. "[-]"
						if data.win then
							_ui.rebelsurroundText.gameObject:SetActive(false)
						else
							_ui.rebelsurroundText.gameObject:SetActive(true)
						end
					end
					_ui.rebelsurroundRed.gameObject:SetActive(data.win and not data.takeReward)
					ShowSurroundAdvance(data)
				end
			end
			--UpdateRebelSurroundRed()
			--UpdateRebelSurroundEffect()
			if RebelSurroundNewData.IsOver() and FunctionListData.IsUnlocked(307) then
				if UnityEngine.PlayerPrefs.GetInt("city" .. MainData.GetCharId()) ~= 1 then
					SoldierEquipBanner.Show(nil, nil, nil, 11000)
				end
			end
		else
			_ui.rebelsurround.gameObject:SetActive(false)
		end
		_ui.cityWarButton.gameObject:SetActive(RebelSurroundNewData.IsOver() and FunctionListData.IsUnlocked(307))
		_ui.activityLeftGrid:Reposition()
	end)	
end

local function MapClickCallback(go)
	if not FunctionListData.IsUnlocked(135) then
		FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(135)), Color.white)
		return
	end
    if GUIMgr:IsMenuOpen("WorldMap") then
        HideWorldMap(true, true)
    end
    FunctionListData.IsFunctionUnlocked(102, function(isactive)
    	print(isactive)
    	if isactive then
    		SandSelect.Show()
    		HideCityMenu()
            RemoveMenuTarget()
    	else
    		ChapterSelectUI.Show(101)
    	end
    end)
end

function CheckMoneyLock()
	if _ui == nil then
		return
	end
	for k, v in pairs(_ui.moneyList) do
        if k ~= Common_pb.MoneyType_Diamond then
            v.gameObject:SetActive((maincity.IsBuildingUnlockByID(v.type.resourceType)))
        end
    end
end

function UpdateMoney()
	CheckMoneyLock()
	if _ui == nil then
		return
	end
    for k, v in pairs(_ui.moneyList) do
        local currentValue = MoneyListData.GetMoneyByType(k)
        local lastValue = MoneyListData.GetOldMoneyByType(k)
		UIAnimMgr:IncreaseUILabelTextAnim(v.label , lastValue , currentValue)
		
        if k == Common_pb.MoneyType_Diamond then
            v.label.text = currentValue
		else
			local rescapacity = maincity.GetResourceTotalCapacity(v.type.resourceType)
            v.label.text = (currentValue > rescapacity and "[e4bd1aff]" or "[C2BBBBFF]") .. Global.ExchangeValue(currentValue) .. "[-]"
            v.slider.value = currentValue / rescapacity
        end
    end
end

local canShowHeroPoint = false
function CanSHowHeroPoint()
	return canShowHeroPoint
end

function UpdateFirstpurchase()
	if _ui == nil then
		return
	end
	FunctionListData.IsFunctionUnlocked(108, function(isactive)
		if isactive then
			if _ui == nil then
				return
			end
			_ui.firstpurchase:SetActive(MainData.HadRecharged() or MainData.CanTakeRecharged() or MainData.GetRecommendGoodInfo().id > 0)
		end
	end)
	local ln = TextMgr:GetText("Mail_FirstRecharge_Reward_Title")
	local qianbao = 1
	if MainData.HadRecharged() or MainData.CanTakeRecharged() then
	elseif MainData.GetRecommendGoodInfo().id > 0 then
		if MainData.GetRecommendGoodInfo().id == 616 or MainData.GetRecommendGoodInfo().id == 617 then
			qianbao = 2
		elseif MainData.GetRecommendGoodInfo().id == 618 or MainData.GetRecommendGoodInfo().id == 619 or MainData.GetRecommendGoodInfo().id == 620 then
			qianbao = 3
		end
		ln = TextMgr:GetText(MainData.GetRecommendGoodInfo().name)
	else
		_ui.firstpurchase:SetActive(false)
	end
	_ui.firstpurchaseqianbao1:SetActive(qianbao == 1)
	_ui.firstpurchaseqianbao2:SetActive(qianbao == 2)
	_ui.firstpurchaseqianbao3:SetActive(qianbao == 3)
	_ui.firstpurchaseLabel.text = ln
end

local isBattleFieldUnlocked = false
function UpdateBattleFieldIcon()
	if _ui ~= nil and _ui.activityAll ~= nil and not _ui.activityAll:Equals(nil) then
		_ui.activityAll:SetActive(isBattleFieldUnlocked)
	end
end

local function UpdateExistTestRed()
	if _ui == nil then
		return
	end
	if GUIMgr:FindMenu("ExistTest") == nil then
		_ui.existtest_red:SetActive(true)
	end
end

local function UpdateExistTest()
	FunctionListData.IsFunctionUnlocked(300, function(isActive)
		if _ui ~= nil and _ui.btn_existtest ~= nil and not _ui.btn_existtest:Equals(nil) then
			_ui.btn_existtest:SetActive(isActive and ActivityData.GetExistTestActivity() ~= nil and (ActivityData.GetExistTestActivity().endTime > Serclimax.GameTime.GetSecTime()))
			_ui.activityLeftGrid:Reposition()
			if ExistTestData.GetStatus() == nil then
				ExistTestData.SetStatus(isActive)
			elseif ExistTestData.GetStatus() == false and isActive then
				ExistTestData.SetStatus(isActive)
				coroutine.start(function()
					local topMenu = GUIMgr:GetTopMenuOnRoot()
					while topMenu == nil or topMenu.name ~= transform.name or #uiPopUps > 0 or currentInvite ~= 0 do
						coroutine.step()
						topMenu = GUIMgr:GetTopMenuOnRoot()
						if topMenu ~= nil and topMenu.name == "ExistTestNotice" then
							return
						end
					end
					ExistTestNotice.Show()
				end)
			end
		end
	end)
end

local CheckFunctionList = function()
	FunctionListData.IsFunctionUnlocked(105, function(isactive)
		if GameObject.Find("WorldMap") == nil and onlineReward ~= nil and onlineReward.bg ~= nil and not onlineReward.bg:Equals(nil) then
			local rewardMsg = OnlineRewardData.GetData()
			onlineReward.bg.gameObject:SetActive(isactive and rewardMsg ~= nil and rewardMsg.show)
		end
	end)

	FunctionListData.IsFunctionUnlocked(106, function(isActive)
		isUnionFunctionUnlocked = isActive
    end)
	
	FunctionListData.IsFunctionUnlocked(117, function(isactive)
		canShowQueueTips = isactive
	end)
	
	FunctionListData.IsFunctionUnlocked(118, function(isactive)
		local needrefresh = canShowHeroPoint ~= isactive
		canShowHeroPoint = isactive
		if not loginEnter and needrefresh and _ui ~= nil and not _ui.isawake and maincity.isInMainCity() then
			BuildingShowInfoUI.Show()
		end
	end)
	
	FunctionListData.IsFunctionUnlocked(123, function(isactive)
		if isactive then
			UnityEngine.PlayerPrefs.SetInt("Mission10020", 1)
		else
			UnityEngine.PlayerPrefs.SetInt("Mission10020", 0)		
		end
	end)
	
	FunctionListData.IsFunctionUnlocked(129, function(isactive)
		isBattleFieldUnlocked = isactive
		UpdateBattleFieldIcon()
	end)
	
	FunctionListData.IsFunctionUnlocked(131, function(isactive)
		if _ui ~= nil and _ui.dailyActivity ~= nil and not _ui.dailyActivity:Equals(nil) then
			_ui.dailyActivity:SetActive(isactive)
		end
	end)
	
	FunctionListData.IsFunctionUnlocked(132, function(isactive)
		if _ui ~= nil and _ui.welfareIcon ~= nil and _ui.welfareIcon.gameObject ~= nil and not _ui.welfareIcon.gameObject:Equals(nil) then
			_ui.welfareIcon.gameObject:SetActive(isactive)
		end
	end)
	
	FunctionListData.IsFunctionUnlocked(133, function(isactive)
		if _ui ~= nil and _ui.btn_purchase ~= nil and not _ui.btn_purchase:Equals(nil) then
			_ui.btn_purchase:SetActive(false)
		end
	end)
	
	FunctionListData.IsFunctionUnlocked(135, function(isactive)
		if GUIMgr:FindMenu("WorldMap") == nil and btnWar ~= nil and not btnWar:Equals(nil) then
			btnWar.gameObject:SetActive(isactive)
		end
	end)
	--[[ FunctionListData.IsFunctionUnlocked(130, function(isactive)
		if isactive then
			RebelSurroundNewData.RequestNemesisInfo()
		end
	end) ]]
    UpdateFirstpurchase()
	--[[
	FunctionListData.IsFunctionUnlocked(10000, function(isactive)
		if _ui ~= nil and _ui.btn_activity ~= nil and not _ui.btn_activity:Equals(nil) then
			_ui.btn_activity:SetActive(isactive)
		end
	end)
	--]]
	UpdateExistTest()
end

function SetActivityBtn(isshow)
	--[[
	if _ui ~= nil and _ui.btn_activity ~= nil and not _ui.btn_activity:Equals(nil) then
		_ui.btn_activity:SetActive(isshow)
	end
	--]]
end

function SetActivityRedPoint()
	--[[
	if _ui ~= nil and _ui.btn_activity ~= nil and not _ui.btn_activity:Equals(nil) then
		_ui.btn_activity.transform:Find("dian").gameObject:SetActive(true)
	end
	--]]
end

local function RequestJoinUnionReward()
	local req = ClientMsg_pb.MsgUserMissionRewardRequest();
    req.taskid = 10311
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            --Global.ShowError(msg.code)
        else
            AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)

            GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
            MainCityUI.UpdateRewardData(msg.fresh)
            MissionListData.RemoveMission(msg.taskid)
            MissionListData.UpdateList(msg.quest)
            ItemListShowNew.SetTittle(TextMgr:GetText("Join_union_Reward"))
			ItemListShowNew.SetItemShow(msg)
			ItemListShowNew.SetCloseMenuCallback(ShareUnion.Show)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
            -- send data report-----------
            GUIMgr:SendDataReport("umission", "" .. msg.taskid, "completed", "0")
            ------------------------------
        end
    end, true)
end

local function UpdateCountInfo(callback)
    local renameCount = CountListData.GetRenameCount()
    if renameCount.count == renameCount.countmax then
	    -- GUIMgr:CreateMenu("FirstChangeName",false)
		FirstChangeName.Show(callback)
	elseif callback then
		callback()
    end
end

function ToggleUnionFirst(flag)
	if transform == nil then
		return
	end
	local union_first = transform:Find("Container/Grid/union_first")
	if union_first then
		union_first.gameObject:SetActive(currentInvite == 0 and flag)
		_ui.right_grid:Reposition()
	end
end

function OpenJoinUnionFirst()
	if MissionListData.GetMissionData(10311) ~= nil and not MissionListData.HasCompletedMission(10311) then
		ToggleUnionFirst(true)
		if transform == nil then
			return
		end
		local union_first = transform:Find("Container/Grid/union_first")
		if union_first then
			SetClickCallback(transform:Find("Container/Grid/union_first/icon").gameObject, function()
				UpdateCountInfo(function()
					JoinUnion.Show()
				end)
			end)
		end
    elseif MissionListData.HasCompletedMission(10311) then
    	RequestJoinUnionReward()
    else
    	ToggleUnionFirst(false)
    end
end

function CloseJionUnionFirst()
	if transform == nil then
		return
	end
	local union_first = transform:Find("Container/Grid/union_first")
	if union_first then
		union_first.gameObject:SetActive(false)
	end
end

function HasReadStory()
	recommendedMissionUI.chapstoryEffect:SetActive(false)
	recommendedMissionUI.chapstoryRed:SetActive(false)
end

local curStoryChap = 0
function GetCurStoryChap()
	return curStoryChap
end

function CheckRecommendedMission()
    local missionMsg, missionData, storytips, storyfirst = MissionListData.GetRecommendedMissionAndData()
    if missionMsg ~= nil then
    	hasmission = true
        if canshowmission and not hasCityMenu then
        	recommendedMissionUI.bg.gameObject:SetActive(true)
        end
		if missionData.type == ClientMsg_pb.UserMissionType_Chapter then
			if storyfirst == nil or storyfirst.type2 % 1000 == 0 then
				recommendedMissionUI.chapstoryTitle.text = TextUtil.GetMissionTitle(missionData) .. "(" .. missionMsg.value .. "/" .. missionData.number .. ")"
			else
				recommendedMissionUI.chapstoryTitle.text = System.String.Format(TextMgr:GetText("ChapterTaskTitle"), ConfigData.GetStoryConfig(), TextUtil.GetMissionTitle(storyfirst))
			end
        	recommendedMissionUI.chapstoryButton.gameObject:SetActive(true)
        	recommendedMissionUI.jumpButton.gameObject:SetActive(false)
			curStoryChap = math.floor(missionData.type2 / 1000)
        	SetClickCallback(recommendedMissionUI.chapstoryButton.gameObject, function()
        		ActivityGrow.Show(curStoryChap)
        	end)
			recommendedMissionUI.chapstoryEffect:SetActive(storytips)
			recommendedMissionUI.chapstoryRed:SetActive(storytips)
			SetClickCallback(recommendedMissionUI.frameObject, nil)
            SetMissionActive(false, true)
	        recommendedMissionUI.rewardButton.gameObject:SetActive(false)
        else
            SetMissionActive(true, false)
        	recommendedMissionUI.chapstoryButton.gameObject:SetActive(false)
	        recommendedMissionUI.title.text = TextUtil.GetMissionTitle(missionData).." ("..missionMsg.value.."/"..missionData.number..")"
        	recommendedMissionUI.jumpButton.gameObject:SetActive(true)
	        SetClickCallback(recommendedMissionUI.chapstoryBtn, function()
                local missionJumpFunc = MissionUI.GetMissionJumpFunction(missionMsg, missionData)
                if missionJumpFunc ~= nil then
                    local conditionType = missionData.conditionType
                    print(string.format("任务跳转,表格Id:%d, 条件类型:%d", missionData.id, conditionType))
                    missionJumpFunc()
                end
            end)
	        local completed = missionMsg.value >= missionData.number
			recommendedMissionUI.rewardButton.gameObject:SetActive(completed)
			if completed == true then 
				recommendedMissionUI.chapstoryLabel.text = TextMgr:GetText("mission_reward")
			else
				recommendedMissionUI.chapstoryLabel.text = TextMgr:GetText("mission_go")
			end
	        if completed then
	            SetClickCallback(recommendedMissionUI.rewardButton.gameObject, function()
	                local req = ClientMsg_pb.MsgUserMissionRewardRequest()
	                req.taskid = missionMsg.id
	                Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
	                    if msg.code ~= ReturnCode_pb.Code_OK then
	                        Global.FloatError(msg.code)
	                    else
	                        AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)

							GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
	                        UpdateRewardData(msg.fresh)
	                        MissionUI.ShowCompleted(msg.reward, recommendedMissionUI.rewardButton.gameObject)
	                        MissionListData.RemoveMission(msg.taskid)
	                        MissionListData.UpdateList(msg.quest)
							-- send data report-----------
							GUIMgr:SendDataReport("rmission", "" .. msg.taskid, "completed", "0")
							------------------------------
							if tonumber(msg.taskid) == 10260 then
								GUIMgr:SendDataReport("efun", "first_map")
							elseif tonumber(msg.taskid) == 10020 then
								GUIMgr:SendDataReport("efun", "name")
							elseif tonumber(msg.taskid) == 2000204 then
								GUIMgr:SendDataReport("efun", "mission_2_4")
							end
	                    end
	                end, true)
	            end)
	        end
	    end
    else
    	hasmission = false
        recommendedMissionUI.bg.gameObject:SetActive(false)
	end
	if _ui == nil then
		return
	end
	_ui.storyNeedShow = false
    _ui.story.go:SetActive(false)
    if missionData == nil or missionData.type ~= 200 then
    	local nextstory = ConfigData.GetStoryConfig() + 1
    	if nextstory > 0 then
    		local nextmissionData = TableMgr:GetStoryDataByType2(nextstory * 1000)
			if nextmissionData ~= nil and tonumber(nextmissionData.openCondition) > 0 then
				_ui.storyNeedShow = true
				_ui.story.go:SetActive(true)
				_ui.story.title.text = TextMgr:GetText(TableMgr:GetFunctionUnlockText(nextmissionData.openCondition))
				SetClickCallback(_ui.story.go, function()
					ActivityGrow.ExtraGuide(nextmissionData.openCondition)
				end)
    		end
    	end
    end
    OpenJoinUnionFirst()
	CheckFunctionList()
	advice_repeated = 0
	CheckAdvice()
end


function UpdateEnergy(msg)
	if _ui == nil or labelEnergy == nil then
		return
	end
    if msg.energyType == 1 then
        MainData.SetEnergy(msg.energy , true)
        MainData.SetEnergyTime(msg.energytime)
        MainData.SetEnergyInterval(msg.interval)
        if transform ~= nil and not GUIMgr:IsMenuOpen("WorldMap") then
            labelEnergy.text = string.format("%d/%d", msg.energy, MainData.GetMaxEnergy())
        end

        CountDown.Instance:Add("RequestEnergy", 0, function()
            if GameTime.GetSecTime() > MainData.GetNextEnergyTime() then
                CountDown.Instance:Remove("RequestEnergy")
                --print("RequestEnergy....")
                RequestEnergy(1)
            end
        end)
    else
        MainData.SetSceneEnergy(msg.energy , true)
        MainData.SetSceneEnergyTime(msg.energytime)
        MainData.SetSceneEnergyInterval(msg.interval)
        if GUIMgr:IsMenuOpen("WorldMap") then
        	labelEnergy.text = string.format("%d/%d", msg.energy, MainData.GetMaxSceneEnergy())
        end

        CountDown.Instance:Add("RequestSceneEnergy", 0, function()
            if GameTime.GetSecTime() > MainData.GetNextSceneEnergyTime() then
                CountDown.Instance:Remove("RequestSceneEnergy")
                --print("RequestSceneEnergy....")
                RequestEnergy(2)
            end
        end)
    end
end

function RequestEnergy(energyType)
    local req = ClientMsg_pb.MsgCharacterEnergyRequest()
    req.energyType = energyType
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterEnergyRequest, req, ClientMsg_pb.MsgCharacterEnergyResponse, function (msg)
        UpdateEnergy(msg)
    end, true)
end

local function CheckArmyCost(nexttime , curtime)
	--local reqTime = Serclimax.GameTime.GetSecTime()
	wait = nexttime - curtime
	if wait < 0 then
		wait = 5
	else
		wait = wait + 3
	end
	CheckArmyCostCoroutine = coroutine.start(function()
		coroutine.wait(wait)
		local reqTime = Serclimax.GameTime.GetSecTime()
		if reqTime >= nexttime then
			RequestArmyCost()
		end
	end)
end

RequestArmyCost = function()
	--print("requestArmyCost")
	local req = BuildMsg_pb.MsgArmyCostFoodRequest()
	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgArmyCostFoodRequest, req, BuildMsg_pb.MsgArmyCostFoodResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
			CheckArmyCost(Serclimax.GameTime.GetSecTime() + 60)
		else
			maincity.RefreshBuild(msg.build.buildList)
			MoneyListData.UpdateData(msg.fresh.money.money)
			nextReqTime = msg.costfoodTime
			--local reqTime = Serclimax.GameTime.GetSecTime()
			--CheckArmyCost(nextReqTime , reqTime)
			requestArmyCoseTime = nextReqTime
		end
	end , true)
end

function RequestPrivateChat()
	local req = ChatMsg_pb.MsgChatInfoListRequest()
	req.languagecode = GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.chanel = ChatMsg_pb.chanel_private
	
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req, ChatMsg_pb.MsgChatInfoListResponse, function(msg)

		--Global.DumpMessage(msg , "d:/privateChat.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			ChatData.UpdatePrivateNewData(msg.infos , msg.autoTrans , msg.transEnable)
			--ChatData.SetNextTime(msg.reqPeriod)
			--ChatData.SetTranslateEnable(msg.transEnable)
			if callback ~= nil then
				callback()
			end	
		end
	end, true)
end


function RequestChat(chanel , callback)
	
	local req = ChatMsg_pb.MsgChatInfoListRequest()
	req.init = false
	req.languagecode = GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.chanel = chanel == nil and ChatMsg_pb.chanel_None or chanel
	-- req.param = UnionMessage.GetGuildId()

	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req, ChatMsg_pb.MsgChatInfoListResponse, function(msg)
	--LuaNetwork.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req:SerializeToString(), function(typeId, data)
		--local msg = ChatMsg_pb.MsgChatInfoListResponse()
		--
		--Global.DumpMessage(msg , "d:/ChatResponseMAIN.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			ChatData.UpdateNewData(msg.infos, msg.autoTrans , msg.transEnable , true)		
			ChatData.SetNextTime(msg.reqPeriod)
			--ChatData.SetTranslateEnable(msg.transEnable)
			if callback ~= nil then
				callback()
			end	
		end
	end, true)
	
	RequestPrivateChat()
	--RequestGroupChat()
end

function RequestChatInfo()
	requestChat = true
	ChatData.ResetData()
	local req = ChatMsg_pb.MsgChatInfoListRequest()
	req.init = true
	req.languagecode = GUIMgr:GetSystemLanguage() --Global.GTextMgr:GetCurrentLanguageID()
	--Global.DumpMessage(req , "d:/ChatResponseMAIN.lua")
	--print("==============================")
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req, ChatMsg_pb.MsgChatInfoListResponse, function(msg)
	--LuaNetwork.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req:SerializeToString(), function(typeId, data)
		--local msg = ChatMsg_pb.MsgChatInfoListResponse()
		--msg:ParseFromString(data)		
		--print("==============================")
		--Global.DumpMessage(msg , "d:/ChatResponseMAIN.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			ChatData.UpdateNewData(msg.infos, msg.autoTrans , msg.transEnable)
			ChatData.SetNextTime(msg.reqPeriod)
			--ChatData.SetTranslateEnable(msg.transEnable)
			requestChat = false
		end
	end, true)
	
	RequestPrivateChat()
	--RequestGroupChat()
	GroupChatData.RequestChatGroupList()
end

function UpdateBuffListIcon()
	--mainBuff
    local skinInfoMsg = MainData.GetData().skin
    local skinsMsg = skinInfoMsg.skins
	local activeCount = BuffView.GetActiveBuffInBufflist()
    for _, v in ipairs(skinsMsg) do
        if not Skin.IsDefaultSkin(v.id) then
            activeCount = activeCount + 1
            break
        end
    end
	
	if mainBuff ~= nil then
		if activeCount > 1 then
			mainBuff.bg:GetComponent("UISprite").spriteName = "BUFF_open02"
			mainBuff.point.gameObject:SetActive(true)
			mainBuff.pointLabel.text = activeCount
		elseif activeCount == 1 then
			mainBuff.bg:GetComponent("UISprite").spriteName = "BUFF_open02"
			mainBuff.point.gameObject:SetActive(false)
		else
			mainBuff.bg:GetComponent("UISprite").spriteName = "BUFF_close02"
			mainBuff.point.gameObject:SetActive(false)
		end
	end
	
end

function SetChatPreviewRedPoint(flag)
	if transform == nil then
		return 
	end
	if ChatMenu~= nil and ChatMenu.redPoint~= nil and ChatMenu.redPoint.gameObject ~= nil then
		ChatMenu.redPoint.gameObject:SetActive(flag)
	end
	ResBar.SetChatPreviewRedPoint(flag)
end

function PreviewChanelChange(dir, uiChat)
	if ChatMenu == nil then
		return
	end
	
	if not Main.Instance:IsInBattleState() then
		if not uiChat then
			uiChat = ChatMenu
		end

		local curChannel = Global.GetChatEnterChanel()
		if ChatMenu.previewTogKey[curChannel] == nil then
			return
		end
		
		
		local curTog = nil
		if dir == 1 then
			curTog = ChatMenu.previewTogKey[curChannel].last
		elseif dir == 2 then
			curTog =  ChatMenu.previewTogKey[curChannel].next
		else
			curTog = ChatMenu.previewTogKey[curChannel].key
		end

		if curTog == ChatMsg_pb.chanel_guild then
			ChatData.SetUnreadGuildCount(0)
		end

		local hasNotice_privateChanel = not Chat.HasNewPrivateMessageViewed() and ChatData.GetUnreadPrivateCount() > 0
		local hasNotice_guildChanel = ChatData.GetUnreadGuildCount() > 0
		local hasNotice_groupChat = GroupChatData.GetCheckCount() > 0
		SetChatPreviewRedPoint(hasNotice_privateChanel or hasNotice_guildChanel or hasNotice_groupChat)
		
		if curTog ~= nil then
			
			ChatMenu.previewTog[curTog]:Set(true)
			UpdateChatHint(curTog, 2)
			if uiChat ~= ChatMenu then
				uiChat.previewTog[curTog]:Set(true)
				UpdateChatHint(curTog, 2, uiChat)
			end
			Global.SetChatEnterChanel(curTog)
		end
	end
end

function UpdateChatHint(chanel, hintCount, uiChat)
	if not uiChat then
		uiChat = ChatMenu
	end

	local recentChat = ChatData.GetRecentNewChat(chanel ,hintCount)
	uiChat.name1.gameObject:SetActive(recentChat ~= nil and #recentChat > 1)
	uiChat.name2.gameObject:SetActive(recentChat ~= nil and #recentChat > 0)
	if recentChat ~= nil and #recentChat > 0 then
		for i , v in pairs(recentChat) do
			local cmName = nil
			
			if i == 1 then
				cmName = uiChat.name2
			elseif i == 2 then
				cmName = uiChat.name1
			end
			
			if cmName ~= nil and cmName.gameObject ~= nil then
				GOV_Util.SetGovNameUI(cmName:Find("bg_gov"),0,0,true)
				cmName.gameObject:SetActive(true)
				local name = cmName:GetComponent("UILabel")
				if v.type == 4 then
					name.text = ""
				elseif v.gm then
					name.text = "[ff0000][" .. TextMgr:GetText("GM_Name") .."][-]:"
				else
					name.text = "【" .. v.sender.name .."】:"
					GOV_Util.SetGovNameUI(cmName:Find("bg_gov"),v.sender.officialId,v.sender.guildOfficialId,true,v.sender.militaryRankId)
				end
				
				local content = cmName:Find("Label"):GetComponent("UILabel")
				local contentOffset = ""
				if v.type == 3 then
					cmName:Find("Label/Sprite").gameObject:SetActive(true)
					contentOffset = "          "
				else
					cmName:Find("Label/Sprite").gameObject:SetActive(false)
				end
				
				--目前没有翻译功能，所以都显示内容原文2017/8/18
				--[[if v.clientlangcode == Global.GTextMgr:GetCurrentLanguageID() then
					content.text = contentOffset .. v.infotext
				else
					content.text = contentOffset .. v.transtext
				end]]
				
				if v.type == 4 or v.type == 5 or v.type == 2 then
					content.text = contentOffset .. Chat.GetSystemChatInfoContent(v.infotext)
				else
					content.text = contentOffset .. v.infotext
				end
				if v.type == 7 then
					content.text = contentOffset .. TextMgr:GetText(v.infotext)
				end
			end
		end
	end
end

function UseResItem(id, cb)
	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
	local noitem = Global.BagIsNoItem(maincity.GetItemResList(id))
	if noitem then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("player_ui18"), Color.white)
		return
    end
    
	CommonItemBag.SetTittle(TextMgr:GetText("get_resource" .. (tonumber(id) - 2)))
	CommonItemBag.NotUseAutoClose()
	CommonItemBag.SetResType(id)
	CommonItemBag.SetItemList(maincity.GetItemResList(id), 0)
	CommonItemBag.SetUseFunc(maincity.UseResItemFunc)
	if cb ~= nil then
    	CommonItemBag.OnCloseCB = cb
    end

	if CommonItemBag.gameObject ~= nil and not CommonItemBag.gameObject:Equals(nil) then
		CommonItemBag.NeedItemMaxValue(false)
		CommonItemBag.UpdateItem()
		print("get_resource" .. (tonumber(id) - 2))
	else
		GUIMgr:CreateMenu("CommonItemBag" , false)
	end
end

function RequestOnlineReward()
	OnlineRewardData.RequestData()
end


local function CheckUnlockArmy(unlockedList)
   SoldierUnlock.UnlockArmy(unlockedList)
end

function UpdateFreeChest()
    CountDown.Instance:Add("FreeChest", 0, function()
        local hasNotice = ChestListData.HasNotice()
        local building = maincity.GetBuildingByID(7)
		if building ~= nil and building.transitionStruct ~= nil and building.land~= nil and not building.land:Equals(nil) then
			if hasNotice then
				building.transitionStruct:SetSfx("kapaitexiao", "kong/kapai", function()
					MilitarySchool.Show()
				end)
			else
				building.transitionStruct:RemoveSfx()
			end
			--[[
            maincity.SetAwardStatus(building, hasNotice, function()
                MilitarySchool.Show()
			end,TextMgr:GetText("Military_recruit"),"icon_hero")
			]]
        end
    end)
end

function UpdateActivityNotice()
    local hasNotice = SevenDayData.HasNotice() or ThirtyDayData.HasNotice() or MonthCardData.HasNotice()
    local building = maincity.GetBuildingByID(8)
	if building ~= nil then
		--[[
        maincity.SetAwardStatus(building, hasNotice, function()
            ActivityData.RequestRedList(ActivityData.GetListData(),function() 
                ActivityEntrance.Show()
            end)
		end,TextMgr:GetText("mission_reward"),"icon_activity")
		]]
    end
end

function UpdateFortIcon(flag)
	if promptList ~= nil and promptList.fort ~= nil then
		promptList.fort:SetActive(flag)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function UpdateFortState()
	local sh_state = FortressData.IsActive()
	UpdateFortIcon(sh_state)
end

function UpdateGovIcon(flag)
	if promptList ~= nil and promptList.gov ~= nil then
		promptList.gov:SetActive(flag)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function UpdateGovState()
	local gov_state = GovernmentData.GetGOVState()
	if gov_state ~= nil then
		UpdateGovIcon(gov_state == 2)
	end
end

function UpdateStrongholdIcon(flag)
	if promptList ~= nil and promptList.stronghold ~= nil then
		promptList.stronghold:SetActive(flag)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function UpdateStrongholdState()
	local sh_state = StrongholdData.IsActive()
	UpdateStrongholdIcon(sh_state)
end

function UpdateCompensateState()
	promptList.alertBSup.gameObject:SetActive(false)
	local unionMemHelpMsg = UnionHelpData.GetMemberHelpData()
	if promptList ~= nil and promptList.alertBSup ~= nil then
		if unionMemHelpMsg ~= nil and unionMemHelpMsg.compensateInfos ~= nil and #unionMemHelpMsg.compensateInfos > 0 then
			for i=1 , #unionMemHelpMsg.compensateInfos do
				local msgInfo = unionMemHelpMsg.compensateInfos[i]
				if msgInfo.charId == MainData.GetCharId() and msgInfo.endTime > Serclimax.GameTime.GetSecTime() then
					promptList.alertBSup.gameObject:SetActive(true)
					--promptList.Grid:Reposition()
					break
				end
			end
		end
	end
	
	local memSup = 0
	if promptList ~= nil and promptList.support ~= nil then
		if unionMemHelpMsg ~= nil and unionMemHelpMsg.compensateInfos ~= nil and #unionMemHelpMsg.compensateInfos > 0 then
			for i=1 , #unionMemHelpMsg.compensateInfos do
				local msgInfo = unionMemHelpMsg.compensateInfos[i]
				if UnionHelp.NeedShow(msgInfo) and msgInfo.endTime > Serclimax.GameTime.GetSecTime() then
					--promptList.support.gameObject:SetActive(true)
					--promptList.Grid:Reposition()
					--break
					memSup = memSup + 1
				end
			end
		end
	end
	
	promptList.support:SetActive(memSup > 0)
	promptList.support.transform:Find("red dot").gameObject:SetActive(memSup > 0)
	promptList.support.transform:Find("red dot/num"):GetComponent("UILabel").text = memSup
	promptList.Grid:Reposition()
	_ui.right_grid:Reposition()
end

function UpdateMassBtn()
	local open = false
	if MassTotlaNum[1] > 0 or  MassTotlaNum[2] > 0 then
		open = true
	end
print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",open,MassTotlaNum[1],MassTotlaNum[2])
	if promptList ~= nil and promptList.mass ~= nil then
		promptList.mass:SetActive(open)
		coroutine.start(function()
			coroutine.step()
			if promptList == nil then
				return
			end
			promptList.Grid:Reposition()
		end)
	end	
end

function UpdateVipNotice(flag)
	if noticeList ~= nil and noticeList.vip ~= nil and not noticeList.vip:Equals(nil) then
		if flag == nil then
			noticeList.vip:SetActive(VipData.HasUncollectedRewards())
		else
			noticeList.vip:SetActive(flag)
		end
	end
end

function OnTurretHurtNorify()
	if promptList ~= nil and promptList.battery ~= nil and not promptList.battery:Equals(nil) then
		promptList.battery:SetActive(true)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function OnMailNotify(msg)	
	if promptList~= nil and not promptList.Mail.gameObject:Equals(nil) then
		promptList.Mail.transform.parent.gameObject:SetActive(true)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
	MailListData.AddNotifyCount()
	--保存老邮件
	PVP_Rewards.SaveMailListData(MailListData.GetData())
	MailListData.RequestData(msg.type, function()
		-- if GUIMgr.Instance:IsMenuOpen("WorldMap") then
		-- 大地图弹窗
		-- end
	end)
	
	--[[local MailMenu = GUIMgr:FindMenu("Mail")
	if MailMenu ~= nil and MailMenu.gameObject.activeSelf then
        MailListData.RequestData(msg.type)
	else
		MailListData.NeedUpdate(true)
		if promptList~= nil and promptList.Mail.gameObject ~= nil then
			promptList.Mail.transform.parent.gameObject:SetActive(true)
			coroutine.start(function()
			coroutine.step()
			promptList.Grid:Reposition()
		end)
		end
	end]]
end

function UpdateMailIcon(flag)
	if promptList ~= nil and promptList.Mail ~= nil and MailListData.GetMailPushCount()==0 then
		promptList.Mail.transform.parent.gameObject:SetActive(flag)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

local function UpdateMail()
    if MailListData.HaveNewMail() then
		promptList.Mail.transform.parent.gameObject:SetActive(true)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
    end
end

function UpdateTemprotyBagIcon() 
--print("updatyre tempbag")
	local TIcon = transform:Find("Container/btn_temporary")
	if ItemListData.GetExpireTime() > 0 then
		TIcon.gameObject:SetActive(true)
		temporyTargetTime = Serclimax.GameTime.GetSecTime() + ItemListData.GetExpireTime()
		CountDown.Instance:Add("TemprotyBagCountDown",temporyTargetTime, function(t)
			if transform ~= nil then 
				temproryBagTime.text = t
				if t == "00:00:00" then
					CountDown.Instance:Remove("TemprotyBagCountDown")
					temporyTargetTime = 0
					TIcon.gameObject:SetActive(false)
					local req = ItemMsg_pb.MsgPackageItemRequest()
					Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgPackageItemRequest, req, ItemMsg_pb.MsgPackageItemResponse, function(msg)
						ItemListData.UpdateData(msg)
						--ItemListData.UpdateData(msg.expiretime)
						--UpdateRewardData()
					end, true)
					
					--Init()
				end
			end 
		end)
	else
		TIcon.gameObject:SetActive(false)
	end
	
end

function SetShopEnabled(isEnabled)
	if bottomMenuList ~= nil and bottomMenuList.shop ~= nil then
		bottomMenuList.shop.gameObject:GetComponent("BoxCollider").enabled = isEnabled
	end
end

--[[onlineReward = {}
	onlineReward.bg = transform:Find("Container/online_rewards")
	onlineReward.btn = transform:Find("Container/online_rewards"):GetComponent("UIButton")
	onlineReward.time = transform:Find("Container/online_rewards/text"):GetComponent("UILabel")
]]
function UpdateOnlineRewardIcon() 
	local rewardMsg = OnlineRewardData.GetData()
	if rewardMsg == nil then
		return
	end
	
	if not rewardMsg.show then
		onlineReward.bg.gameObject:SetActive(false)
	end
	
	local leftTime = rewardMsg.availableTime - Serclimax.GameTime.GetSecTime()
	onlineReward.Glow.gameObject:SetActive(false)
	CountDown.Instance:Remove("rewardCountDown")
	
	if leftTime > 0 then
		CountDown.Instance:Add("rewardCountDown",rewardMsg.availableTime, function(t)
			if onlineReward.time ~=nil and not onlineReward.time:Equals(nil) then
				onlineReward.time.text = t
				if t == "00:00:00" then
					CountDown.Instance:Remove("rewardCountDown")
					onlineReward.Glow.gameObject:SetActive(true)
					onlineReward.time.text = System.String.Format("[00ff00]{0}[-]" , TextMgr:GetText("online_8"))
				end
			end
		end)
	else
		onlineReward.Glow.gameObject:SetActive(true)
		onlineReward.time.text = System.String.Format("[00ff00]{0}[-]" , TextMgr:GetText("online_8"))
	end
	
end

function UpdateCityMenuPosition()
	if transform ~= nil then
		if cityCamera ~= nil and menuTarget ~= nil and cityMenu.go ~= nil and menuTarget.transform ~= nil then
			local position = cityCamera:WorldToViewportPoint(menuTarget.transform.position)
			if position == nil then
				return
			end
			--if position ~= lastMenuPos then
			if lastMenuPos == nil or (position - lastMenuPos):SqrMagnitude() > 0.1*0.1 then
				lastMenuPos = position
				position = Vector3(position.x * container.width, position.y * container.height, 0)
			else
				if cityMenu.needshow then 
					for i = 0, 1 do
						cityMenu.bgTween[i]:PlayForward(false)
					end
                    NotifyCityMenuListener(maincity.GetCurrentBuildingData().land.name)
					cityMenu.needshow = false
					--if hasmission then
						recommendedMissionUI.bg.gameObject:SetActive(false)
						hasCityMenu = true
					--end
                end
				if showMenuCallBack ~= nil then
					coroutine.start(function()
						coroutine.wait(menuStep)
						if showMenuCallBack ~= nil then
							showMenuCallBack()
							showMenuCallBack = nil
						end
						menuStep = 0
					end)
                end
				position = Vector3(position.x * container.width, position.y * container.height, 0)
			end
		end
	end
end

local afterLoginFuncList
local loginFuncList
function LoginAwardGo()
	if loginFuncList ~= nil and #loginFuncList > 0 then
		table.remove(loginFuncList,1)()
		return
	elseif afterLoginFuncList ~= nil and #afterLoginFuncList > 0 then
		table.remove(afterLoginFuncList,1)()
		return
	end
	loginfinish = true
	local platformType = GUIMgr:GetPlatformType()
	if platformType == LoginMsg_pb.AccType_ios_efun or
		platformType == LoginMsg_pb.AccType_adr_efun or
		platformType == LoginMsg_pb.AccType_ios_india then
		if BuildingData.GetBuildingDataById(1).level >= 5 then
			account.GetAccountBindListRequest(function(bindkey)
				for j, k in ipairs(bindkey) do
					if k.acctype == 5 then
						return
					end
				end
				SoldierEquipBanner.Show(nil, nil, nil, 99999)
			end)
		end
    end
end

function AddAfterLoginAward(callbackfunction)
	if afterLoginFuncList == nil then
		afterLoginFuncList = {}
	end
	table.insert(afterLoginFuncList, callbackfunction)
end

function IsLoginEnter()
	return loginEnter
end

local tutorialobj
function OpenTutorial()
	if tutorialobj ~= nil and not tutorialobj:Equals(nil) then
		tutorialobj:SetActive(true)
		tutorialobj = nil
	end
end

function CheckWeelyShareNotice()
    if MainData.HasWeeklyShare() then
        local serverTime = GameTime.GetSecTime()
        if serverTime - ConfigData.GetLastShareTime() > 3600 * 24 * 7 then
            ConfigData.SetLastShareTime(serverTime)
            ShareCommon.Show(2)
            return true
        end
    end

    return false
end

function CheckLoginAward()
	InitPush()
	GUIMgr:CacheUIPrefab(true)
	UpdateRategame()
	_ui.UpdateActivity()
	if ServerListData.IsAppleReviewing() then
        LoginAwardGo()
        return
    end

	FunctionListData.RequestListData(function()
	    if loginEnter then
	        loginEnter = false
	        loginFuncList = {}
	        --ThirtyDay.SetCloseCallback(LoginAwardGo)
	        --table.insert(loginFuncList, SevenDay.ThirtyDay.CheckLoginShow)
	        --SevenDay.SetCloseCallback(LoginAwardGo)
	        --table.insert(loginFuncList, SevenDay.CheckLoginShow)

			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(108, function(isactive)
					if isactive and tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PayFirstShow).value) == 1 then
						if MainData.HadRecharged() or MainData.CanTakeRecharged() then
							FirstPurchase.SetCloseCallback(LoginAwardGo)
							FirstPurchase.Show()
						elseif MainData.GetRecommendGoodInfo().id > 0 then
							TimedBag_notime.SetCloseCallback(LoginAwardGo)
							TimedBag_notime.Show()
						else
							LoginAwardGo()
						end
					else
						LoginAwardGo()
					end
				end)
			end)
	        
	        -- VipExp.SetCloseCallback(LoginAwardGo)
	        -- table.insert(loginFuncList, VipExp.Show)
			table.insert(loginFuncList, function() VipData.CheckLevelUp(LoginAwardGo) end)
	        --table.insert(loginFuncList, function() ShowCards(true, LoginAwardGo) end)

	        -- 活动开服公告
			table.insert(loginFuncList, function()
				ActivityBulletin.Show(LoginAwardGo)
			end)

			table.insert(loginFuncList, function()
				RebelArmyAttackData.RequestSiegeMonsterInfo(function(msg)
					FunctionListData.IsFunctionUnlocked(122, function(isactive)
						if isactive then
			        		ActivityBanner.SetCloseCallback(LoginAwardGo)
			        		if (msg.isOpen == false and msg.lastStartTime - (120*3600) <= Serclimax.GameTime.GetSecTime()) or msg.isOpen == true then
			        			if tonumber(os.date("%d")) ~= UnityEngine.PlayerPrefs.GetInt("siege") then
									UnityEngine.PlayerPrefs.SetInt("siege",tonumber(os.date("%d")))
								    UnityEngine.PlayerPrefs.Save()
			        				ActivityBanner.Show(msg)
			        			else
			        				LoginAwardGo()
								end
			        			--_ui.btn_activity:SetActive(true)
			        		else
			        			LoginAwardGo()
			        			--_ui.btn_activity:SetActive(false)
			        		end
						else
							LoginAwardGo()
						end
					end)
		        end)
			end)

			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(122, function(isactive)
					if isactive then
						ActivityForecast.Show(LoginAwardGo)
					else
						LoginAwardGo()
					end
				end)
			end)

			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(122, function(isactive)
					if isactive then
						GOVBanner.SetCloseCallback(LoginAwardGo)
						local govstate = GovernmentData.GetGOVState()
						local govActInfo = GovernmentData.GetGOVActInfo()
						if (govstate == 1 and govActInfo.contendStartTime - (48*3600) <= Serclimax.GameTime.GetSecTime()) or govstate == 2 then
							--GOVBanner.Show()
							if tonumber(os.date("%d")) ~= UnityEngine.PlayerPrefs.GetInt("gov") then
								UnityEngine.PlayerPrefs.SetInt("gov",tonumber(os.date("%d")))
								UnityEngine.PlayerPrefs.Save()
								GOVBanner.Show()
							else
								LoginAwardGo()
							end
						else
							LoginAwardGo()
						end
					else
						LoginAwardGo()
					end
				end)
			end)

			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(122, function(isactive)
					print("12222222222222",isactive)
					if isactive then
						PAP_ATK_Banner.SetCloseCallback(LoginAwardGo)
						local slaughter_data = ActiveSlaughterData.GetData()
						if (not slaughter_data.isOpen and slaughter_data.startTime - (48*3600) <= Serclimax.GameTime.GetSecTime()) or slaughter_data.isOpen then
							if tonumber(os.date("%d")) ~= UnityEngine.PlayerPrefs.GetInt("atk") then
								UnityEngine.PlayerPrefs.SetInt("atk",tonumber(os.date("%d")))
								UnityEngine.PlayerPrefs.Save()
								PAP_ATK_Banner.Show()
							else
								LoginAwardGo()
							end
						else
							LoginAwardGo()
						end
					else
						LoginAwardGo()
					end
				end)
			end)		
			
			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(147, function(isActive)
	        		if isActive then
						Offlinerepo.Show(function(isopen)
							if isopen then
							else
								RequestNotifyInfoRequest(nil)
							end
							LoginAwardGo()
						end)
					else
						RequestNotifyInfoRequest(nil)
						LoginAwardGo()
					end
				end)
			end)

			table.insert(loginFuncList, function()
	        	FunctionListData.IsFunctionUnlocked(106, function(isActive)
	        		if isActive then
						AllianceInvitesData.RequestInvites(function(msg)
							if #msg.infos == 0 and UnionInfoData.GetGuildId() == 0 then
								AllianceInvitesData.RequestRecommendedAlliance(function(msg)
									if msg ~= nil then
										SetCurrentInvite(-1)
									end
									LoginAwardGo()
								end)
							else
								LoginAwardGo()
							end
						end)
					else
						LoginAwardGo()
					end
				end)
	        end)

	        --[[table.insert(loginFuncList, function()
	        	FunctionListData.IsFunctionUnlocked(132, function(isActive)
	        		if isActive then
		        		local function checkAndShowWelfareAll()
		        			if SevenDayData.IsFirst() and not SevenDayData.HasTakenReward() then
		        				WelfareAll.Show(3002, LoginAwardGo)
		        			else
		        				LoginAwardGo()
		        			end
		        		end
		        		
		        		if SevenDayData.GetData() then
		        			checkAndShowWelfareAll()
						else
							SevenDayData.RequestData(function(msg)
								if msg.code == ReturnCode_pb.Code_OK then
									checkAndShowWelfareAll()
								else
									LoginAwardGo()
								end
							end)
						end
					else
						LoginAwardGo()
					end
				end)
	        end)]]

			table.insert(loginFuncList, function()
                if not CheckWeelyShareNotice() then
                    LoginAwardGo()
                end
			end)
			
			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(300, function(isActive)
					if isActive then
						ExistTestNotice.Show(LoginAwardGo)
					else
						LoginAwardGo()
					end
				end)
			end)

			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(141, function(isActive)
					if isActive then
						NewRaceBanner.Show(LoginAwardGo)
					else
						LoginAwardGo()
					end
				end)
			end)

			table.insert(loginFuncList, function()
				FunctionListData.IsFunctionUnlocked(122, function(isactive)
					if isactive then
						NewActivityBanner.Show(LoginAwardGo)
					else
						LoginAwardGo()
					end
				end)
			end) --让我保持在最后一个

	        LoginAwardGo()
	    end
	end)
end


function CheckNotiffyHomeBurn(callback)
	if _ui == nil then
		return
	end
	local homeBurnNotifies = {}
	NotifyInfoData.GetNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeSeBurn , homeBurnNotifies)
	if #homeBurnNotifies > 0 then
		local reportid = homeBurnNotifies[1].param[2]
		local win = (homeBurnNotifies[1].param[1] == 1)
		
		_ui.afterAttackAlern.gameObject:SetActive(true)
		
		if homeBurnNotifies[1].param.param[1] == 2 then -- 失败
			_ui.afterAttackAlernContent.text = TextMgr:GetText("PVP_win_maincity")
			_ui.afterAttackAlernPerson.mainTexture = ResourceLibrary:GetIcon("Background/" ,"icon_guide" )
		elseif homeBurnNotifies[1].param.param[1] == 1 then -- 胜利
			_ui.afterAttackAlernContent.text = TextMgr:GetText("PVP_lose_maincity")
			_ui.afterAttackAlernPerson.mainTexture = ResourceLibrary:GetIcon("Background/" ,"icon_guide1" )
		end

		local warLossData = WarLossData.GetData()
		
		SetClickCallback(_ui.afterAttackAlernBtnClose.gameObject , function()
			if callback ~= nil then
				callback()
			end
			_ui.afterAttackAlern.gameObject:SetActive(false)
			if warLossData.score >= warLossData.cost then
				WelfareAll.Show(3015)
			end
		end)
		
		SetClickCallback(_ui.afterAttackAlernBtnRep.gameObject , function()
			if callback ~= nil then
				callback()
			end
			_ui.afterAttackAlern.gameObject:SetActive(false)
			Mail.SetTabSelect(3)--跳转到邮件的“报告”页签
			--GUIMgr:CreateMenu("Mail", false)
			Mail.Show()
			Mail.OnCloseCB = function()
				if warLossData.score >= warLossData.cost then
					WelfareAll.Show(3015)
				end
			end
		end)
		
		SetClickCallback(_ui.afterAttackAlernBtnHeal.gameObject , function()
			if callback ~= nil then
				callback()
			end
			_ui.afterAttackAlern.gameObject:SetActive(false)
			local hospitalBuild = maincity.GetBuildingByID(3)
			if hospitalBuild == nil then
				FloatText.Show(TextMgr:GetText("ui_error1") , Color.red)
				
				return
			end
			Hospital.SetBuild(hospitalBuild)
			GUIMgr:CreateMenu("Hospital", false)
			Hospital.OnCloseCB = function()
				RemoveMenuTarget()
				if warLossData.score >= warLossData.cost then
					WelfareAll.Show(3015)
				end
			end
		end)
	end
end

function RequestHomeExile()
	NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeExile , function()

		local juNotifies = {}
		NotifyInfoData.GetNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeExile , juNotifies)
		if #juNotifies > 0 then 
			local param = juNotifies[1].param.param[1]
			local paramX = math.floor(param/10000)
			local paramY = math.floor(param%10000)
			local mapPos = System.String.Format(TextMgr:GetText("ui_worldmap_77") , 1 , paramX ,paramY )

			FunctionListData.IsFunctionUnlocked(114, function(active)
				if active then
					MessageBox.Show(System.String.Format(TextMgr:GetText("exile_text") ,  mapPos) , function() 
						--ShowWorldMap(paramX , paramY , true , false)
					end)
				end
			end)
		end
	end)
end
 
function RequestNotifyInfoRequest(menuName , callback)
	--print(menuName)
	if menuName == nil then
		NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeSeBurn , function() CheckNotiffyHomeBurn(callback) end)
	else
		if menuName == "WarZoneMap" then--关闭展区地图是也不响应
			return
		end
		--当前UI为MainCityUI时才触发
		local topMenu = GUIMgr:GetTopMenuOnRoot()
		if topMenu ~= nil and topMenu.name ~= "MainCityUI" then
			return
		end
		if GUIMgr:FindMenu("WarZoneMap") ~= nil then
			return
		end
		
		if GUIMgr:FindMenu("WorldMap") ~= nil then
			return
		end
	
		if menuName == "Waiting" then
			return
		end
		
		if menuName == "SevenDay" or menuName == "ThirtyDay" then
			return
		end
		
		--print("menuName:" .. menuName)
		NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeSeBurn , CheckNotiffyHomeBurn)
		--NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeSeBurn)
		--NotifyInfoData.RequestNotifyInfo()
	end
end


function UpdateTalent()
	if _ui == nil then
		return
	end
	local point = TalentInfoData.GetCurrentIndexRemainderPoint()
	local equipCanUpgrade = EquipData.IsCanUpgrade()
	local talentShow = FunctionListData.IsUnlocked(107) and point > 0
	_ui.talent_fx:SetActive(talentShow or equipCanUpgrade)
	if MainData.IsCommanderCaptured() then
        _ui.talent_fx:SetActive(false)
    end
	
	if not FunctionListData.IsFunctionUnlocked(302) or not FunctionListData.IsFunctionUnlocked(303) then
	
	else
	
		if MilitaryRankData.HasNotice() then
			_ui.talent_fx:SetActive(true)
		end 
		
		if SoldierLevel.CheckLevelUpdate() then 
			_ui.talent_fx:SetActive(true)
		end 
	end
	
	TalentInfo.MakeBaseTable()
end

local function ResetGrid()
	if _ui == nil then
		return
	end
	_ui.activity_grid.repositionNow = true
end

local canUpdateDailyRed = true
function SetDailyActivityRedPoint()
	if canUpdateDailyRed then
		if _ui == nil then
			return
		end
		_ui.dailyActivitydian:SetActive(DailyActivityData.HasRedPoint() or DailyActivityData.HasExchangeRedPoint() or ActivityExchangeData.HasNotice() or ActivityLevelRaceData.HasNotice())
	else
		canUpdateDailyRed = true
	end
end

local guildmobaiconlist = {"act_icon_guildmoba", "icon_choice", "icon_getinto", "icon_reward"}
local guildmobatextlist = {"ui_unionwar_37", "ui_unionwar_38", "ui_moba_10", "RebelArmy_btn_reward"}
function UpdateGuildMobaNotify(status, time)
	print(status, time)
	_ui.guildmoba_root:SetActive(status > 0)
	_ui.guildmoba_icon.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", guildmobaiconlist[status])
	_ui.guildmoba_text.text = TextMgr:GetText(guildmobatextlist[status])
	CountDown.Instance:Add("guildmobatime", time, CountDown.CountDownCallBack(function(t)
		_ui.guildmoba_time.text = t
	end))
	_ui.right_grid:Reposition()
end

lastUpdateTime = 0
function LateUpdate()
	local now = Serclimax.GameTime.GetSecTime()
	
	EventDispatcher.LateUpdate(now)

	if now ~= lastUpdateTime then
		lastUpdateTime = now

		UpdateShopCountdown()

		-- 在主城xxx时间显示???
		if timeEnterMainCityUI ~= 0 then
			if isUnionFunctionUnlocked and currentInvite == 0 then
				if hasNewAllianceInvite then
					SetCurrentInvite(1)
				elseif UnionInfoData.GetGuildId() == 0 and now - timeEnterMainCityUI >= timeToShowRecommendedAlliance and now - lastTimeCloseAllianceInvite >= intervalToShowRecommendedAlliance then
					AllianceInvitesData.RequestRecommendedAlliance(function(msg)
						if msg ~= nil then
							SetCurrentInvite(-1)
						else
							currentInvite = -1
						end
					end)
				end
			end

			if not loginEnter and #loginFuncList == 0 then
				--[[FunctionListData.IsFunctionUnlocked(122, function(isactive)
					if isactive then
						GiftPackData.ShowUnshownLimitedGoods()
					end
				end)]]
				if FunctionListData.IsUnlocked(122) then
					GiftPackData.ShowUnshownLimitedGoods()
				end
			end
		end
	end

	if _ui.EnergyTipRoot.activeInHierarchy then
		if isInWorldMap or GUIMgr:IsMenuOpen("WorldMap") then
			_ui.EnergyTipLabel1.text, _ui.EnergyTipLabel2.text = MainData.GetSceneEnergyCooldownText()
		else
			_ui.EnergyTipLabel1.text, _ui.EnergyTipLabel2.text = MainData.GetEnergyCooldownText()
		end
	end

	if not istime then
		return
	end

	if timer >= 0 then
		timer = timer - Serclimax.GameTime.deltaTime
		if timer < 0 then
			timer = 3
			istime = false
			Tooltip.HideItemTip()
		end
	end
end

function OnUICameraPress(go, press)
	if not press then
		return
	end
	if _ui == nil then
		return
	end
	if UICamera.isOverUI and go ~= _ui.advice.btn then
		_ui.advice.go:SetActive(false)
		CheckAdvice()
	end
	if _ui.EnergyTipRoot.activeInHierarchy then
		_ui.EnergyTipRoot:SetActive(false)
	end
	if go.name == "bg_power" then 
		Tooltip.ShowItemTip({name = String.Format(TextMgr:GetText("maincity_ui14"), _ui.powervalue), text = TextMgr:GetText("maincity_ui13")})
		istime = true
	else
		if istime then
			istime = false
			Tooltip.HideItemTip()
		end
	end
end

function RefreshVipExperienceCard()
	if _ui == nil then
		return
	end
	viptips = true
	local vip = MainData.GetVipValue()
	if vip.viptimeTaste > 0 and MainData.GetVipValue().viplevel < vip.viplevelTaste then
		_ui.viptips.gameObject:SetActive(true)		
		CountDown.Instance:Add("viptipstext", MainData.GetVipValue().viptimeTaste, CountDown.CountDownCallBack(function(t)
			_ui.viptipstext.text = t
		end))		
	end
end

function RefreshVipEffect()
	if _ui == nil then
		return
	end
	local vip = MainData.GetVipValue()
	if vip.viptimeTaste ~= 0 then
		if vip.viptimeTaste > Serclimax.GameTime.GetSecTime() then
			_ui.vipeffect.gameObject:SetActive(true)
		end
	end
end

function GetRebelSurroundBtn()
	if _ui == nil then
		return
	end
	return _ui.rebelsurroundText
end

function StartTeachBattle()
    local teamType = Common_pb.BattleTeamType_Main
    TeamData.UnselectAllHero(teamType)
    TeamData.UnselectAllArmy(teamType)
    TeamData.SelectMaxLevelArmyByType(teamType, 1)
    SelectArmy.StartPVEBattle(90001, Common_pb.BattleTeamType_Main)
end

function UpdateRategame()
	local platformType = GUIMgr:GetPlatformType()
    if not Global.IsOutSea() or
        platformType == LoginMsg_pb.AccType_adr_opgame or
		platformType == LoginMsg_pb.AccType_adr_official or
		platformType == LoginMsg_pb.AccType_ios_official or
		platformType == LoginMsg_pb.AccType_adr_official_branch or
		platformType == LoginMsg_pb.AccType_adr_quick or
		platformType == LoginMsg_pb.AccType_adr_qihu then
		_ui.rategame:SetActive(false)
        return
    end
	_ui.rategame:SetActive(maincity.GetBuildingByID(1).data.level >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RateGame).value) and UnityEngine.PlayerPrefs.GetInt("rategame" .. MainData.GetCharId()) <= 1)
end

local function UpdateWastEffect()
    local burning = DefenseData.GetData().cginfo.fireing
	maincity.ShowWastEffect(burning)
	_ui.extinguishObject:SetActive(burning)
end

function UpdateMobaUI()
	if UnityEngine.PlayerPrefs.GetInt("Moba" .. MainData.GetCharId()) == 1 then
		_ui.moba_root.transform.localScale = Vector3(0,1,1)
		CountDown.Instance:Remove("MobaEntrance")
		return
	end
	if not maincity.HasBuildingByID(8) then
		_ui.moba_root.transform.localScale = Vector3(0,1,1)
		CountDown.Instance:Remove("MobaEntrance")
		return
	end
	local data = MobaData.GetMobaMatchInfo()
	if data ~= nil and data.status > 0 then
        if data.status == 1 then
			if data.userstatus ~= 0 then
				_ui.moba_root.transform.localScale = Vector3(0,1,1)
				CountDown.Instance:Remove("MobaEntrance")
			else
				_ui.moba_root.transform.localScale = Vector3(1,1,1)
				_ui.moba_state.text = TextMgr:GetText("ui_moba_144")
				CountDown.Instance:Add("MobaEntrance", data.time, function(t)
					local now = Serclimax.GameTime.GetSecTime()
					if data.time >= now then
						_ui.moba_time.text = t
					else
						CountDown.Instance:Remove("MobaEntrance")
						MobaData.RequestMobaMatchInfo()
					end
				end)
            end
        elseif data.status == 2 then
			if data.userstatus ~= 1 then
				_ui.moba_root.transform.localScale = Vector3(0,1,1)
				CountDown.Instance:Remove("MobaEntrance")
			else
				_ui.moba_root.transform.localScale = Vector3(1,1,1)
				_ui.moba_state.text = TextMgr:GetText("ui_moba_145")
				CountDown.Instance:Add("MobaEntrance", data.time, function(t)
					local now = Serclimax.GameTime.GetSecTime()
					if data.time >= now then
						_ui.moba_time.text = t
					else
						CountDown.Instance:Remove("MobaEntrance")
						MobaData.RequestMobaMatchInfo()
					end
				end)
            end
        elseif data.status == 3 and (data.userstatus == 2 or data.userstatus == 3) then
			_ui.moba_root.transform.localScale = Vector3(1,1,1)
			_ui.moba_state.text = TextMgr:GetText("ui_moba_146")
				CountDown.Instance:Add("MobaEntrance", data.time, function(t)
					local now = Serclimax.GameTime.GetSecTime()
					if data.time >= now then
						_ui.moba_time.text = t
					else
						CountDown.Instance:Remove("MobaEntrance")
						MobaData.RequestMobaMatchInfo()
					end
				end)
		else
			_ui.moba_root.transform.localScale = Vector3(0,1,1)
			CountDown.Instance:Remove("MobaEntrance")
		end
	else
		_ui.moba_root.transform.localScale = Vector3(0,1,1)
		CountDown.Instance:Remove("MobaEntrance")
    end
end

function UpdateGetStrong()
	FunctionListData.IsFunctionUnlocked(306, function(active)
		if active then
			_ui.getstrong_root:SetActive(UnityEngine.PlayerPrefs.GetInt("GetStrong" .. MainData.GetCharId()) ~= 1)
		else
			_ui.getstrong_root:SetActive(false)
		end
	end)
end

function UpdateReturnActivity()
	if _ui ~= nil then
		_ui.btn_return:SetActive(ReturnRewards.IsInTime())
		_ui.btn_return_dian:SetActive(ReturnRewards.HasUnclaimedAward(33001))
	end
end

function UpdateArmyStatus()
    if _ui == nil then
        return
    end

    local status = Barrack.GetArmyStatus()
    _ui.armyStatusSprite.spriteName = "icon_soldiernow" .. status
   	
    if status ~= _ui.armyStatus then
        _ui.armyStatus = status
        local statusMsg =
        {
            content = "TipsNotice_Union_Desc16",
            priority = 500,
            paras =
            {
                {
                    value = TextMgr:GetText("Review_status_" .. status),
                },
            },
            format = 1,
            title = "",
            tipId = 0,
            tipType = 1,
        } 

        Notice_Tips.ShowTips(statusMsg)
        _ui.armyStatusEffect:SetActive(false)
        _ui.armyStatusEffect:SetActive(true)
        if UnityEngine.PlayerPrefs.GetInt("SoldierProduction", 0) == 0 then
            SoldierProduction.Show()
            UnityEngine.PlayerPrefs.SetInt("SoldierProduction", 1)
            UnityEngine.PlayerPrefs.Save()
        end
    end
end

UpdateGlobalLimitPack = function()
	if _ui then
		local packs = GiftPackData.GetGlobalLimitPack()
		_ui.globalLimit.obj.gameObject:SetActive(#packs > 0)
		_ui.globalLimit.countDown.gameObject:SetActive(false)
		if (#packs > 0) and (packs[1].endTime > 0) then
			if _ui.globalLimit.countDown_time ~= nil then
				CountDown.Instance:Remove(_ui.globalLimit.countDown_time)
			end
			
			local endTime = packs[1].endTime
			_ui.globalLimit.countDown_time = "globalLimitPack"
			_ui.globalLimit.countDown.gameObject:SetActive(true)
			_ui.globalLimit.countDown.text = Global.GetLeftCooldownTextLong(endTime)
			CountDown.Instance:Add(_ui.globalLimit.countDown_time, endTime, function(t)
				if _ui == nil then
					return
				end
				local now = Serclimax.GameTime.GetSecTime()
				if endTime >= now then
					_ui.globalLimit.countDown.text = Global.GetLeftCooldownTextLong(endTime)
					--print(endTime , now , Global.GetLeftCooldownTextLong(endTime))
				else
					local endTime = 0;
					if endTime == 0 then
						--print(endTime)
						CountDown.Instance:Remove(_ui.globalLimit.countDown_time)
						_ui.globalLimit.obj.gameObject:SetActive(false)
					else
						--print(endTime)
						UpdateGlobalLimitPack()
					end
				end
			end)
		end
	end
end

UpdateLimitedTime = function()
    if _ui == nil then
        return
	end	
	if _ui.limitedTime == nil then
		return 
	end
	if GiftPackData.HasAvailableGoods(1001) then
		_ui.limitedTime.obj.gameObject:SetActive(true)
		local iapGoodsInfos = GiftPackData.GetAvailableGoodsByTab(1001)
		local endTime = 0;
		for _, iapGoodsInfo in pairs(iapGoodsInfos) do
			if iapGoodsInfo.endTime ~= nil then
			if endTime == 0 then
				endTime = iapGoodsInfo.endTime
			else
				if endTime > iapGoodsInfo.endTime then
					endTime = iapGoodsInfo.endTime
				end
			end
			end
		end
		if endTime == 0 then
			_ui.limitedTime.obj.gameObject:SetActive(false)
		else
			if _ui.limitedTime.countdown_limitedTime ~= nil then
				CountDown.Instance:Remove(_ui.limitedTime.countdown_limitedTime)
			end
			_ui.limitedTime.countdown_limitedTime = "Limited Time";
			_ui.limitedTime.time.text = Global.GetLeftCooldownTextLong(endTime)
			CountDown.Instance:Add(_ui.limitedTime.countdown_limitedTime, endTime, function(t)
				if _ui == nil then
					return
				end
				local now = Serclimax.GameTime.GetSecTime()
				if endTime >= now then
					_ui.limitedTime.time.text = Global.GetLeftCooldownTextLong(endTime)
				else
					local iapGoodsInfos = GiftPackData.GetAvailableGoodsByTab(1001)
					local endTime = 0;
					for _, iapGoodsInfo in pairs(iapGoodsInfos) do
						if iapGoodsInfo.endTime ~= nil then
						if endTime == 0 then
							endTime = iapGoodsInfo.endTime
						else
							if endTime > iapGoodsInfo.endTime then
								endTime = iapGoodsInfo.endTime
							end
						end
						end
					end
					if endTime == 0 then
						CountDown.Instance:Remove(_ui.limitedTime.countdown_limitedTime)
						_ui.limitedTime.obj.gameObject:SetActive(false)
					else
						UpdateLimitedTime()
					end
				end
			end)
		end
	else
		_ui.limitedTime.obj.gameObject:SetActive(false)
	end
	
end

function Awake()
    if Event.HasAnyEvent() then
        Global.ShowTopMask(2)
    end
	if ConfigData.GetGameStateTutorial() == false then
		StoryPicture.Show(1, function()
			Global.ShowTopMask(5)
			maincity.PlayCameraAnimation("Main_scene")
			maincity.PlayBuildEffect(1, "zhuchegnkaiqi", 3)			
			ConfigData.SetGameStateTutorial(true)
            Event.AddAll()
            coroutine.start(function()
                coroutine.wait(4)
                Event.Check(2)
            end)
            CheckRecommendedMission()
		end)
	end
	if InGameUI.GetExploredLevel() == 90001 then
        Event.Check(2)
	elseif InGameUI.GetExploredLevel() == 90014 then
	    Event.Resume(6)
	elseif InGameUI.GetExploredLevel() == 90015 then
	    Event.Resume(8)
    end
    local exploredLevel = InGameUI.GetExploredLevel()
    if exploredLevel ~= nil then
        SceneStory.ResumeStory("WaitLevel", exploredLevel)
    end
	ResBar.Init()
	_ui = {}
	ui = {}
	_ui.isawake = true
	timer = 3
	istime = false
	bg = transform:Find("Container")
    container = bg:GetComponent("UIWidget")
	local systemInfo = GUIMgr:GetSystemInfo()
	print(systemInfo ,"iPhone10" ,string.match(systemInfo , "iPhone10") )
	--[[if string.match(systemInfo , "iPhone10") ~= nil then
		container:SetAnchor(transform:Find("AnchorTarget_iphoneX"))
	end]]
	
    topBar = transform:Find("Container/TopBar")
	iconPlayerBtn = transform:Find("Container/TopBar/bg_touxiang"):GetComponent("UIButton")
	_ui.activity_grid = transform:Find("Container/bg_activity/Grid"):GetComponent("UIGrid")
	local childCount = _ui.activity_grid.transform.childCount
	for i = 1, childCount do
		SetActiveCallback(_ui.activity_grid.transform:GetChild(i - 1).gameObject, ResetGrid)
	end
	_ui.power = transform:Find("Container/TopBar/bg_power").gameObject
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	_ui.iconPlayer = transform:Find("Container/TopBar/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
	_ui.MilitaryRank = transform:Find("Container/TopBar/bg_touxiang/MilitaryRank")
	_ui.headNoticeObject = transform:Find("Container/TopBar/bg_touxiang/dian").gameObject
	mainLevel = transform:Find("Container/TopBar/bg_touxiang/level"):GetComponent("UILabel")
	_ui.prisonObject = transform:Find("Container/TopBar/bg_touxiang/inprison").gameObject
	labelEnergy = transform:Find("Container/TopBar/bg_tili/bg_msg/num"):GetComponent("UILabel")
	iconEnergy = transform:Find("Container/TopBar/bg_tili/icon"):GetComponent("UISprite")
	_ui.EnergyTipRoot = transform:Find("Container/TopBar/bg_tili/bg").gameObject
	_ui.EnergyTipLabel1 = transform:Find("Container/TopBar/bg_tili/bg/Label (1)"):GetComponent("UILabel")
	_ui.EnergyTipLabel2 = transform:Find("Container/TopBar/bg_tili/bg/Label"):GetComponent("UILabel")
	labelVip = transform:Find("Container/TopBar/bg_vip/bg_msg/num"):GetComponent("UILabel")
	buildInfoBar = transform:Find("Container/buildinginfo")
	_ui.talent_fx = transform:Find("Container/TopBar/bg_touxiang/TianFuGlow").gameObject
	_ui.btn_activity = transform:Find("Container/bg_activity/Grid/bth_activity").gameObject
	_ui.btn_activity:SetActive(false)

	--建筑队列提示
	queueTips = transform:Find("Container/arraybar/bg_tips").gameObject
	queueTipsText = transform:Find("Container/arraybar/bg_tips/text_skill"):GetComponent("UILabel")
	
	_ui.firstpurchase = transform:Find("Container/bg_activity/Grid/firstpurchase").gameObject
	_ui.firstpurchaseEff = transform:Find("Container/bg_activity/Grid/firstpurchase/ui_tongyong").gameObject
	_ui.firstpurchaseLabel = transform:Find("Container/bg_activity/Grid/firstpurchase/Label"):GetComponent("UILabel")
	_ui.firstpurchaseqianbao1 = transform:Find("Container/bg_activity/Grid/firstpurchase/qianbao").gameObject
	_ui.firstpurchaseqianbao2 = transform:Find("Container/bg_activity/Grid/firstpurchase/qianbao02").gameObject
	_ui.firstpurchaseqianbao3 = transform:Find("Container/bg_activity/Grid/firstpurchase/qianbao03").gameObject
	_ui.firstpurchase:SetActive(false)
	SetClickCallback(_ui.firstpurchase, function()
		if MainData.HadRecharged() or MainData.CanTakeRecharged() then
			FirstPurchase.Show()
		elseif MainData.GetRecommendGoodInfo().id > 0 then
			TimedBag_notime.Show()
		end
		_ui.firstpurchase.transform:Find("dian").gameObject:SetActive(false)
	end)
	UpdateFirstpurchase()
	
	_ui.rategame = transform:Find("Container/bg_activity/Grid/rategame").gameObject
	SetClickCallback(_ui.rategame, rategame.Show)
	if not Global.IsOutSea() then
		_ui.rategame:SetActive(false)
    end
	
	SetClickCallback(_ui.btn_activity, function()
		--ActivityNotice.Show()
		--_ui.btn_activity.transform:Find("dian").gameObject:SetActive(false)
		--RebelArmyAttack.Show()
		ActivityAll.Show("RebelArmyAttack")
	end)

	_ui.btn_gonglve = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_gonglve/btn_gonglve").gameObject
	SetClickCallback(_ui.btn_gonglve, Strategy.Show)
	_ui.btn_gonglve.transform.parent.gameObject:SetActive(GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_adr)

	_ui.activityAll = transform:Find("Container/bg_activity/Grid/RebelArmyWanted").gameObject
	_ui.activityAllNotice = transform:Find("Container/bg_activity/Grid/RebelArmyWanted/dian").gameObject
	_ui.activityAll:SetActive(false)
	SetClickCallback(_ui.activityAll, function()
        ActivityAll.Show()
    end)
	
    FunctionListData.IsFunctionUnlocked(129, function(isactive)
    	_ui.activityAll:SetActive(isactive)
    end)

    -- 福利入口
    _ui.welfareIcon = {}
    _ui.welfareIcon.gameObject = transform:Find("Container/bg_activity/Grid/GrowGold").gameObject
	_ui.welfareIcon.highlight = _ui.welfareIcon.gameObject.transform:Find("dian").gameObject
	_ui.welfareIcon.gameObject:SetActive(false)
	FunctionListData.IsFunctionUnlocked(132, function(isactive)
		_ui.welfareIcon.gameObject:SetActive(isactive)
	end)
    SetClickCallback(_ui.welfareIcon.gameObject, function()
    	WelfareAll.Show()
	end)
	

	_ui.PowerRank = {}
    _ui.PowerRank.gameObject = transform:Find("Container/bg_activity/Grid/PowerRank").gameObject
	_ui.PowerRank.highlight = _ui.PowerRank.gameObject.transform:Find("dian").gameObject
	_ui.PowerRank.gameObject:SetActive(false)
	if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("PowerRank_status_today") then
		_ui.PowerRank.highlight:SetActive(false)
	else
		_ui.PowerRank.highlight:SetActive(true)
	end
	CheckPowerRankBtn()
--[[
	FunctionListData.IsFunctionUnlocked(309, function(isactive)
		if isactive then
			_ui.PowerRank.gameObject:SetActive(ActivityData.IsActivityAvailable(1032))
		else
			_ui.PowerRank.gameObject:SetActive(false)
		end
	end)
--]]
	
	SetClickCallback(_ui.PowerRank.gameObject, function()
		_ui.PowerRank.highlight:SetActive(false)
		UnityEngine.PlayerPrefs.SetInt("PowerRank_status_today",tonumber(os.date("%d")))
		UnityEngine.PlayerPrefs.Save()	
		PowerRank.Show()
    end)
    	
    
	_ui.dailyActivity = transform:Find("Container/bg_activity/Grid/DailyActivity").gameObject
	_ui.dailyActivitydian = _ui.dailyActivity.transform:Find("dian").gameObject
	_ui.dailyActivity:SetActive(false)
	FunctionListData.IsFunctionUnlocked(131, function(isactive)
		_ui.dailyActivity:SetActive(isactive)
	end)
	SetClickCallback(_ui.dailyActivity, function()
		if not DailyActivityData.HasRedPoint() and DailyActivityData.HasExchangeRedPoint() then
			canUpdateDailyRed = false
			_ui.dailyActivitydian:SetActive(false)
		end
    	DailyActivity.Show()
    end)
	SetDailyActivityRedPoint()
	
	_ui.right_grid = transform:Find("Container/Grid"):GetComponent("UIGrid")
	_ui.btn_purchase = transform:Find("Container/bg_activity/Grid/purchase").gameObject
	_ui.red_purchase = transform:Find("Container/bg_activity/Grid/purchase/dian").gameObject
	_ui.btn_purchase:SetActive(false)
	_ui.red_purchase:SetActive(false)
	SetClickCallback(_ui.btn_purchase, function()
		store.Show()
	end)
	FunctionListData.IsFunctionUnlocked(133, function(isactive)
		_ui.btn_purchase:SetActive(false)
	end)

	_ui.zeroyuangift = transform:Find("Container/bg_activity/Grid/0YuanGift").gameObject
	_ui.zeroyuangift_red = transform:Find("Container/bg_activity/Grid/0YuanGift/dian").gameObject
	_ui.zeroyuangift_time = transform:Find("Container/bg_activity/Grid/0YuanGift/time"):GetComponent("UILabel")
	_ui.zeroyuangift_effect = transform:Find("Container/bg_activity/Grid/0YuanGift/shengcun").gameObject
	SetClickCallback(_ui.zeroyuangift, function()
		ZeroYuanGift.Show()
		_ui.zeroyuangift_red:SetActive(false)
		_ui.zeroyuangift_effect:SetActive(false)
	end)

	_ui.UpdateActivity = function()
		local zeroyuan = ActivityData.IsActivityAvailable(3016)
		_ui.zeroyuangift:SetActive(zeroyuan)
		if zeroyuan then
			local activity = ActivityData.GetActivityConfig(3016)
			CountDown.Instance:Add("zeroyuan", activity.endTime, CountDown.CountDownCallBack(function(t)
				_ui.zeroyuangift_time.text = t
			end))
			_ui.zeroyuangift_red:SetActive(GiftPackData.IsZeroGiftRed())
			_ui.zeroyuangift_effect:SetActive(GiftPackData.IsZeroGiftRed())
		end
	end

	_ui.countdown_purchase = {}
	_ui.countdown_purchase.transform = transform:Find("Container/btn_shop/Countdown")
	_ui.countdown_purchase.gameObject = _ui.countdown_purchase.transform.gameObject
	_ui.countdown_purchase.time = _ui.countdown_purchase.transform:Find("Time"):GetComponent("UILabel")

	_ui.advice = {}
	_ui.advice.go = transform:Find("Container/btn_advice").gameObject
	_ui.advice.tween = transform:Find("Container/btn_advice/Container"):GetComponent("TweenPosition")
	_ui.advice.btn = transform:Find("Container/btn_advice/Container/bg").gameObject
	_ui.advice.text = transform:Find("Container/btn_advice/Container/text"):GetComponent("UILabel")
	_ui.advice.typewriter = _ui.advice.text.transform:GetComponent("TypewriterEffect")
	_ui.advice.go:SetActive(false)
	
	moneyList = {}
	for k, v in pairs(moneyTypeList) do
        local money = {}
        money.type = v
        local moneyTransform = transform:Find(v.path)
        money.transform = moneyTransform
        money.gameObject = moneyTransform.gameObject
        money.label = moneyTransform:Find(v.labelPath):GetComponent("UILabel")
        money.iconTransform = moneyTransform:Find(v.iconPath)
        if k ~= Common_pb.MoneyType_Diamond then
            money.slider = moneyTransform:Find("bg_bar"):GetComponent("UISlider")
        end
        moneyList[k] = money
        SetClickCallback(money.iconTransform.gameObject, function(go)
            UseResItem(k, function()
            end)
        end)
    end
    _ui.moneyList = moneyList
	
	btnWar = transform:Find("Container/btn_battle"):GetComponent("UIButton")
	btnMap = transform:Find("Container/btn_map"):GetComponent("UIButton")
	btnWar.gameObject:SetActive(FunctionListData.IsUnlocked(135))
	_ui.battleReward = transform:Find("Container/btn_battle/red dot")
	SetClickCallback(btnMap.gameObject, function()
		FunctionListData.IsFunctionUnlocked(101, function(isactive)
			if isactive then
				local basePos = MapInfoData.GetData().mypos
			    ShowWorldMap(basePos.x, basePos.y, true)
			else
				FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(101)), Color.white)
            end
		end)
    end)
	
	_ui.activityLeft = transform:Find("Container/bg_activityleft")
	_ui.activityLeftGrid = transform:Find("Container/bg_activityleft/Grid"):GetComponent("UIGrid")
	_ui.rebelsurround = transform:Find("Container/bg_activityleft/Grid/btn_rebelsurround")
	_ui.rebelsurroundText = transform:Find("Container/bg_activityleft/Grid/btn_rebelsurround/text"):GetComponent("UILabel")
	_ui.rebelsurroundRed = transform:Find("Container/bg_activityleft/Grid/btn_rebelsurround/dian")
	_ui.rebelsurroundEffect1 = transform:Find("Container/bg_activityleft/Grid/btn_rebelsurround/GameObject/panjun01")
	_ui.rebelsurroundEffect2 = transform:Find("Container/bg_activityleft/Grid/btn_rebelsurround/GameObject/panjun02")
	_ui.rebelsurroundEffect = 0
	_ui.cityWarButton = transform:Find("Container/bg_activityleft/Grid/btn_citywar"):GetComponent("UIButton")
	_ui.cityNotice = transform:Find("Container/bg_activityleft/Grid/btn_citywar/dian").gameObject
	SetClickCallback(_ui.rebelsurround.gameObject, function()
		--[[ local posstr = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelSurroundCenter).value
		local pos = string.split(posstr,',')
		ShowRebelSurround(tonumber(pos[1]), tonumber(pos[2]), true, function() 
			Global.GGuideManager:Init()
			local data = RebelSurroundData.GetData()
			if data.curLevel == 1 and data.curWave == 1 and ConfigData.GetRebelSurroundConfig()==0 then
				Global.GGuideManager:StartGuide(RebelSurround.RebelSurroundGuideId[1],nil,function() 
					GrowGuide.Show(RebelSurround.GetUI().fightBtn, nil) 
					
				end)
				ConfigData.SetRebelSurroundConfig(1);
			end
		end) ]]
		RebelSurroundNew.Show()
	end)  

    --_ui.cityWarButton.gameObject:SetActive(RebelSurroundNewData.IsOver())
	SetClickCallback(_ui.cityWarButton.gameObject, function(go)
		if Global.ForceUpdateVersion("ui_update_hint1") then
			return
		end
	    CityMap.Show()
    end)
	CheckRebelSurroundBtn()
	
	_ui.hotTime = transform:Find("Container/bg_activityleft/Grid/btn_hottime"):GetComponent("UISprite")
	_ui.hotTimeLabel = transform:Find("Container/bg_activityleft/Grid/btn_hottime/text"):GetComponent("UILabel")
	SetClickCallback(_ui.hotTime.gameObject, function()
		local hotMsg = BuffData.GetActiveHotTimeBuff()
		HotTime.Show(hotMsg)
	end)
	--CheckHotTime()

	_ui.btn_existtest = transform:Find("Container/bg_activityleft/Grid/btn_existtest").gameObject
	_ui.existtest_red = transform:Find("Container/bg_activityleft/Grid/btn_existtest/dian").gameObject
	SetClickCallback(_ui.btn_existtest, function() ExistTest.Show() _ui.existtest_red:SetActive(false) end)
	_ui.btn_existtest:SetActive(false)

	_ui.moba_root = transform:Find("Container/moba").gameObject
	_ui.moba_btn = transform:Find("Container/moba/btn_moba").gameObject
	_ui.moba_state = transform:Find("Container/moba/btn_moba/Label"):GetComponent("UILabel")
	_ui.moba_time = transform:Find("Container/moba/btn_moba/time"):GetComponent("UILabel")
	SetClickCallback(_ui.moba_btn, function()
		CheckWorldMap(false, Entrance.Show)
	end)
	MobaData.RequestMobaMatchInfo()
	UpdateMobaUI()

	_ui.guildmoba_root = transform:Find("Container/Grid/btn_guildmoba").gameObject
	_ui.guildmoba_icon = _ui.guildmoba_root:GetComponent("UITexture")
	_ui.guildmoba_text = transform:Find("Container/Grid/btn_guildmoba/text"):GetComponent("UILabel")
	_ui.guildmoba_time = transform:Find("Container/Grid/btn_guildmoba/text/time"):GetComponent("UILabel")
	SetClickCallback(_ui.guildmoba_root, function()
		ActivityAll.Show(7)
	end)

	_ui.getstrong_root = transform:Find("Container/btn_strong").gameObject
	_ui.getstrong_btn = transform:Find("Container/btn_strong/icon_strong").gameObject
	SetClickCallback(_ui.getstrong_btn, GetStrong.Show)
	_ui.getstrong_root:SetActive(false)
	UpdateGetStrong()

	_ui.btn_return = transform:Find("Container/bg_activity/Grid/btn_return").gameObject
	_ui.btn_return_dian = transform:Find("Container/bg_activity/Grid/btn_return/dian").gameObject
	SetClickCallback(_ui.btn_return, function()
		WelfareAll.Show(33001)
	end)
	UpdateReturnActivity()

    local testButton = transform:Find("Container/Noticetest").gameObject
    SetClickCallback(testButton, function(go)
        FaceDrawData.RequestData(function()
            NewActivityBanner.Show()
        end)
    end)
    topBar = transform:Find("Container/TopBar")
    resourceBar = transform:Find("Container/resourebar")
    arrayBar = transform:Find("Container/arraybar")
    arrayBarBgQueue = transform:Find("Container/arraybar/bg_queueicon")

	bottomMenuList = {}
	bottomMenuList.union = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_union/btn_union"):GetComponent("UIButton")
	bottomMenuList.general = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_general/btn_general"):GetComponent("UIButton")
	bottomMenuList.mission = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mission/btn_mission"):GetComponent("UIButton")
	bottomMenuList.bag = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_bag/btn_bag"):GetComponent("UIButton")
	bottomMenuList.rune = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_rune/btn_union"):GetComponent("UIButton")
	bottomMenuList.shop = transform:Find("Container/btn_shop"):GetComponent("UIButton")
	bottomMenuList.military = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_military/btn_military"):GetComponent("UIButton")
	bottomMenuList.militaryNotice = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_military/btn_military/red dot").gameObject
	bottomMenuList.rank = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_rank/btn_rank"):GetComponent("UIButton")

	ui.bagRed = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_bag/btn_bag/red dot")
	temproryBagTime = transform:Find("Container/btn_temporary/text"):GetComponent("UILabel")
	
	_ui.growgiftpack = transform:Find("Container/growgiftpack").gameObject
	
	promptList = {}
	promptList.Grid = transform:Find("Container/bg_hint/Grid"):GetComponent("UIGrid")
	promptList.Mail = promptList.Grid.transform:Find("hint_info/btn_mail"):GetComponent("UIButton")
	SetClickCallback(promptList.Mail.gameObject, function(go)
		MailListData.ClearMailPush()
		Mail.JumpNewTab(true)
		--GUIMgr:CreateMenu("Mail", false)
		Mail.Show()
    end)
	promptList.alertB = transform:Find("Container/bg_hint/Grid/AlertB").gameObject
	promptList.alertR = transform:Find("Container/bg_hint/Grid/AlertR").gameObject
	promptList.fort = transform:Find("Container/bg_hint/Grid/fort").gameObject
	SetClickCallback(promptList.fort.transform:Find("Sprite").gameObject, function(go)
		--ActivityAll.Show("Fort")
		FortressWarinfo.Show()
	end)
	
	promptList.gov = transform:Find("Container/bg_hint/Grid/gov").gameObject
	SetClickCallback(promptList.gov.transform:Find("Sprite").gameObject, function(go)
		GOVWarinfo.Show()
	end)
	
	promptList.battery = transform:Find("Container/bg_hint/Grid/battery").gameObject
	SetClickCallback(promptList.battery.transform:Find("Sprite").gameObject, function(go)
		BatteryAttackinfo.Show()
		promptList.battery:SetActive(false)
	end)

	promptList.stronghold = transform:Find("Container/bg_hint/Grid/stronghold").gameObject
	SetClickCallback(promptList.stronghold.transform:Find("Sprite").gameObject, function(go)
		StrongholdWarinfo.Show()
	end)
	
	promptList.alertBSup = transform:Find("Container/bg_hint/Grid/AlertB_Support").gameObject
	SetClickCallback(promptList.alertBSup.transform:Find("Sprite").gameObject, function(go)
		CompensateList.Show()
	end)

	promptList.mass = transform:Find("Container/mass_info").gameObject
	SetClickCallback(promptList.mass.transform:Find("btn_mass").gameObject, function(go)
		if UnionInfoData.HasUnion() then
			UnionWar.Show()
			HideCityMenu()
			UnionInfo.OnCloseCB = function()
				RemoveMenuTarget()
			end
		end
	end)	
	
	promptList.support = transform:Find("Container/Grid/UnionSupport").gameObject
	SetClickCallback(promptList.support.transform:Find("aid btn").gameObject, function(go)
		if UnionInfoData.HasUnion() then
			UnionHelp.Show()
			HideCityMenu()
			UnionInfo.OnCloseCB = function()
				RemoveMenuTarget()
			end
		end
	end)	

	UpdateGovState()
	UpdateFortState()
	UpdateStrongholdState()
	
	SetClickCallback(transform:Find("Container/TopBar/bg_tili").gameObject, function(go)
		if Global.GetMobaMode() ~= 2 then
			if GUIMgr:IsMenuOpen("WorldMap") then
				CheckAndBuySceneEnergy()
			else
				CheckAndBuyEnergy()
			end
		end 
    end)

	SetClickCallback(bottomMenuList.general.gameObject, function(go)
	    HeroList.Show()
	    openedMainMenu = HeroList
    end)
	

    local mission = {}
	mission.transform = transform:Find("Container/bg_quicktask/bg_mission")
	mission.gameObject = mission.transform.gameObject
	mission.buttonObject = mission.transform:Find("btn_mission").gameObject
	mission.noticeObject = mission.transform:Find("btn_mission/red dot").gameObject
	local function ShowMissionUI()
	    local missionToggleIndex = 1
	    if MissionListData.HasNotice() then
	        missionToggleIndex = 1
        elseif FunctionListData.IsFunctionUnlocked(115) and MissionListData.HasDailyMissionNotice() then
            missionToggleIndex = 2
        elseif FunctionListData.IsFunctionUnlocked(109) and MilitaryActionData.HasNoticeByType(1) then
            missionToggleIndex = 3
        elseif FunctionListData.IsFunctionUnlocked(109) and MilitaryActionData.HasNoticeByType(2) then
            missionToggleIndex = 4
        end
	    MissionUI.Show(missionToggleIndex)
    end
	SetClickCallback(mission.buttonObject, function(go)
	    ShowMissionUI()
    end)
    _ui.mission = mission

    local mission1 = {}
	mission1.transform = transform:Find("Container/bg_activity/Grid/bg_mission01")
	mission1.gameObject = mission1.transform.gameObject
	mission1.buttonObject = mission1.transform:Find("btn_mission").gameObject
	mission1.noticeObject = mission1.transform:Find("btn_mission/red dot").gameObject
	SetClickCallback(mission1.buttonObject, function(go)
	    ShowMissionUI()
    end)
	_ui.mission1 = mission1

    local limitedTime = {}
	limitedTime.obj = transform:Find("Container/bg_activity/Grid/LimitedTime")
	if limitedTime.obj ~= nil then
		limitedTime.time = transform:Find("Container/bg_activity/Grid/LimitedTime/time"):GetComponent("UILabel")
		limitedTime.red = transform:Find("Container/bg_activity/Grid/LimitedTime/dian")
		limitedTime.red.gameObject:SetActive(hadLimitedTime)
		SetClickCallback(limitedTime.obj.gameObject, function(go)
			hadLimitedTime = false
			limitedTime.red.gameObject:SetActive(hadLimitedTime)
			if GiftPackData.HasAvailableGoods(1001) then
				Goldstore.Show(10, 1001)
			end
		end)
	else
		limitedTime = nil
	end
	_ui.limitedTime = limitedTime
	UpdateLimitedTime();

	local globalLimit = {}
	globalLimit.obj = transform:Find("Container/bg_activity/Grid/globalpurchase")
	globalLimit.red = transform:Find("Container/bg_activity/Grid/globalpurchase/dian")
	globalLimit.countDown = transform:Find("Container/bg_activity/Grid/globalpurchase/time"):GetComponent("UILabel")
	SetClickCallback(globalLimit.obj.gameObject, function(go)
		globalLimit.red.gameObject:SetActive(false)
		Goldstore.Show(10, 1001)
	end)
	_ui.globalLimit = globalLimit
	UpdateGlobalLimitPack()
	
	
	
	
--	右下角任务按钮
	SetClickCallback(bottomMenuList.mission.gameObject, function(go)
	    ShowMissionUI()
    end)
--	

	SetClickCallback(bottomMenuList.bag.gameObject, function(go)
		--GUIMgr:CreateMenu("SlgBag", false)
		SlgBag.Show(1)
    end)
    
    SetClickCallback(bottomMenuList.shop.gameObject, function(go)
	    --GUIMgr:CreateMenu("Shop", false)
		--SlgBag.Show(2)
		Goldstore.Show()
    end)
	
	SetClickCallback(bottomMenuList.rune.gameObject, function(go)
		FunctionListData.IsFunctionUnlocked(305, function(isactive)
			if isactive then
				Rune.Show()
			else
				FloatText.ShowAt(bottomMenuList.rune.transform.position,TextMgr:GetText("ui_rune_44"), Color.white)
			end
		end)
    end)
    
	
	SetClickCallback(iconPlayerBtn.gameObject, function(go)
	--GUIMgr:CreateMenu("BuildReview", false)
	   	UpdateCountInfo(function()
	   		GUIMgr:CreateMenu("MainInformation", false)
	   	end)
	   --[[local lead = 
	   {
		   name="sb" , 
		   entryBaseData=
		   { 
				pos=
				{
					x=100 , 
					y=100
				}	 
		   }
		}
		UnionGuide.Show(lead , true)]]
    end)

    SetClickCallback(bottomMenuList.union.gameObject, function(go)
    	UpdateCountInfo(function()
	        FunctionListData.IsFunctionUnlocked(106, function(isactive)
	        	if isactive then
	        		if UnionInfoData.HasUnion() then
			            UnionInfo.Show()
			        else
			            JoinUnion.Show()
			        end
				else
					if bottomMenuList.union then
						FloatText.ShowAt(bottomMenuList.union.transform.position,TextMgr:GetText(TableMgr:GetFunctionUnlockText(106)), Color.white)
					end
	        	end
	        end)
	    end)
    end)
    SetClickCallback(bottomMenuList.military.gameObject, function(go)
        if not FunctionListData.IsFunctionUnlocked(302) then
            FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(302)))
            return
        end
        MilitaryRankData.RequestData(function()
            MainInformation.Show(2)
        end)
    end)
	
	SetClickCallback(bottomMenuList.rank.gameObject, function(go)
       rank.Show(1)
    end)
	
	
	local btnTemprory = transform:Find("Container/btn_temporary"):GetComponent("UIButton")
	SetClickCallback(btnTemprory.gameObject, function(go)
		TemporaryBag.SetTargetTime(temporyTargetTime)
	    GUIMgr:CreateMenu("TemporaryBag", false)
    end)
	
	rightMenuList = {}
	rightMenuList.friends = transform:Find("Container/bg_zhankai/Panel_right/bg_right/bg_friends/btn_friends"):GetComponent("UIButton")
	rightMenuList.mail = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mail/btn_mail"):GetComponent("UIButton")
	rightMenuList.options = transform:Find("Container/bg_zhankai/Panel_right/bg_right/bg_setting/btn_setting"):GetComponent("UIButton")
    cityMenu = {}
	cityMenu.go = transform:Find("Container/Menu") 
    cityMenu.bgTween = transform:Find("Container/Menu/bg"):GetComponents(typeof(UITweener))
    cityMenu.grid = transform:Find("Container/Menu/bg/Grid"):GetComponent("UIGrid")
    cityMenu.item = transform:Find("Menuinfo")

    rightMenuListEx = {}
    
	SetClickCallback(rightMenuList.options.gameObject, function(go)
	    setting.Show()
    end)  

    noticeList = {}
    noticeList.main = transform:Find("Container/bg_zhankai/btn_zhankai/red dot")
	noticeList.mission = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mission/btn_mission/red dot") 
	noticeList.missionNum = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mission/btn_mission/red dot/num"):GetComponent("UILabel")
    noticeList.hero = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_general/btn_general/red dot")
    noticeList.mail = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mail/btn_mail/red dot")
    noticeList.mailnum = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mail/btn_mail/red dot/num"):GetComponent("UILabel")
	noticeList.union = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_union/btn_union/red dot")
	noticeList.vip = transform:Find("Container/TopBar/bg_vip/dian").gameObject
	noticeList.shop = transform:Find("Container/btn_shop/red dot")
	noticeList.rune = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_rune/btn_union/red dot")
    
	ui.btnZhankai = transform:Find("Container/bg_zhankai/btn_zhankai"):GetComponent("UIButton")
	tweenZhankaiBottom = transform:Find("Container/bg_zhankai/Panel_left/bg_left"):GetComponents(typeof(UITweener))
	tweenZhankaiRight = transform:Find("Container/bg_zhankai/Panel_right/bg_right"):GetComponents(typeof(UITweener))
	--SetClickCallback(ui.btnZhankai.gameObject, ZhankaiClickCallback)
	SetClickCallback(btnWar.gameObject, MapClickCallback)

	SetClickCallback(rightMenuList.mail.gameObject, function(go)
	    --GUIMgr:CreateMenu("Mail", false)
		Mail.Show()
		--AllianceMatch.Show()
    end)

    recommendedMissionUI = {}
    recommendedMissionUI.bg = transform:Find("Container/bg_quicktask")
    recommendedMissionUI.frameObject = transform:Find("Container/bg_quicktask/frame").gameObject
    recommendedMissionUI.jumpButton = transform:Find("Container/bg_quicktask/btn_go"):GetComponent("UIButton")
    recommendedMissionUI.rewardButton = transform:Find("Container/bg_quicktask/btn_reward"):GetComponent("UIButton")
    recommendedMissionUI.chapstoryButton = transform:Find("Container/bg_quicktask/btn_chapstory"):GetComponent("UIButton")
	recommendedMissionUI.chapstoryEffect = transform:Find("Container/bg_quicktask/btn_chapstory/btn_chapstory/xinfengfaguang").gameObject
	recommendedMissionUI.chapstoryRed = transform:Find("Container/bg_quicktask/btn_chapstory/btn_chapstory/dian").gameObject
	recommendedMissionUI.title = transform:Find("Container/bg_quicktask/btn_go/text"):GetComponent("UILabel")
	recommendedMissionUI.chapstoryTitle = transform:Find("Container/bg_quicktask/btn_chapstory/text"):GetComponent("UILabel")
	recommendedMissionUI.chapstoryBtn = transform:Find("Container/bg_quicktask/btn_go/btn").gameObject
	recommendedMissionUI.chapstoryLabel = transform:Find("Container/bg_quicktask/btn_go/Label"):GetComponent("UILabel")
	
    _ui.story = {}
    _ui.story.go = transform:Find("Container/icon_chapstory").gameObject
    _ui.story.title = transform:Find("Container/icon_chapstory/text"):GetComponent("UILabel")

    unionHelpUI = {}
    unionHelpUI.transform = transform:Find("Container/Grid/aid")
    unionHelpUI.countLabel = transform:Find("Container/Grid/aid/red dot/num"):GetComponent("UILabel")
    unionHelpUI.button = transform:Find("Container/Grid/aid/aid btn"):GetComponent("UIButton")
    unionHelpUI.tweenAlpha = unionHelpUI.button.transform:GetComponent("TweenAlpha")
    unionHelpUI.effectObject = unionHelpUI.button.transform:Find("ui_yuanzhu").gameObject
    SetClickCallback(unionHelpUI.button.gameObject, function()
        local req = GuildMsg_pb.MsgBatchGiveAccelAssistRequest()
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgBatchGiveAccelAssistRequest, req, GuildMsg_pb.MsgBatchGiveAccelAssistResponse, function(msg)
            UnionHelpData.RequestData()
            if msg.code == ReturnCode_pb.Code_OK then
                FloatText.ShowOn(unionHelpUI.button.gameObject, TextMgr:GetText(Text.union_help_friend), Color.green)
                AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
            else
                Global.ShowError(msg.code)
            end
        end)
    end)
	
	SetClickCallback(transform:Find("Container/btn_buff").gameObject , function()
		BuffView.Show()
	end)
	
	mainBuff = {}
	mainBuff.bg = transform:Find("Container/btn_buff")
	mainBuff.point = transform:Find("Container/btn_buff/dian")
	mainBuff.pointLabel = transform:Find("Container/btn_buff/dian/Label"):GetComponent("UILabel")
	
	onlineReward = {}
	onlineReward.bg = transform:Find("Container/online_rewards")
	onlineReward.Glow = transform:Find("Container/online_rewards/btn_shopGlow")
	onlineReward.btn = transform:Find("Container/online_rewards"):GetComponent("UIButton")
	onlineReward.time = transform:Find("Container/online_rewards/text"):GetComponent("UILabel")
	
	_ui.afterAttackAlern = transform:Find("Container/bg_left person/")
	_ui.afterAttackAlernPerson = transform:Find("Container/bg_left person/bg/icon_guide"):GetComponent("UITexture")
	_ui.afterAttackAlernContent = transform:Find("Container/bg_left person/bg/text_guide"):GetComponent("UILabel")
	_ui.afterAttackAlernBtnClose = transform:Find("Container/bg_left person/bg/bg_btn/btn_close"):GetComponent("UIButton")
	--SetClickCallback(_ui.afterAttackAlernBtnClose.gameObject , function()
	--	_ui.afterAttackAlern.gameObject:SetActive(false)
	--end)
	
	_ui.afterAttackAlernBtnRep = transform:Find("Container/bg_left person/bg/bg_btn/btn_zhanbao"):GetComponent("UIButton")
	--SetClickCallback(_ui.afterAttackAlernBtnRep.gameObject , function()
	--	_ui.afterAttackAlern.gameObject:SetActive(false)
	--	Mail.SetTabSelect(3)--跳转到邮件的“报告”页签
	--	Mail.Show()
	--end)
	
	_ui.afterAttackAlernBtnHeal = transform:Find("Container/bg_left person/bg/bg_btn/btn_xiuli"):GetComponent("UIButton")
	--[[SetClickCallback(_ui.afterAttackAlernBtnHeal.gameObject , function()
		_ui.afterAttackAlern.gameObject:SetActive(false)
		local hospitalBuild = maincity.GetBuildingByID(3)
		if hospitalBuild == nil then
			FloatText.Show(TextMgr:GetText("ui_error1") , Color.red)
			
			return
		end
		Hospital.SetBuild(hospitalBuild)
		GUIMgr:CreateMenu("Hospital", false)
		Hospital.OnCloseCB = function()
			RemoveMenuTarget()
		end
	end)]]

	SetClickCallback(onlineReward.btn.gameObject , function()
		online.Show()
		
	end)
	
	onlineReward.bg.gameObject:SetActive(false)
    
	isZhankai = true
	Global.LoadMainCity();
	--GameStateMain:LoadMainCity("maincity")
	MainData.AddListener(UpdateMainData)
	MainData.AddListener(UpdateFirstpurchase)
	MoneyListData.AddListener(UpdateMoney)
	--ItemListData.AddListener(UpdateTemprotyBagIcon)
	MissionListData.AddListener(CheckRecommendedMission)
	--AddCancelUpgradeListener(CheckRecommendedMission)
	ChatData.AddListener(UpdateNotice)
    UnlockArmyData.AddListener(CheckUnlockArmy)	
	ItemListData.AddListener(UpdateNotice)
    MissionListData.AddListener(UpdateNotice)
    MissionListData.AddListener(UpdateMissionNotice)
    RebelWantedData.AddListener(UpdateActivityAllNotice)
	RaceData.AddListener(UpdateActivityAllNotice)
	NewRaceData.AddListener(UpdateActivityAllNotice)
    ActivityTreasureData.AddListener(UpdateActivityAllNotice)
    MilitaryActionData.AddListener(UpdateMissionNotice)
    -- HeroListData.AddListener(UpdateNotice)
	MailListData.AddListener(UpdateNotice)
	ChatData.AddListener(PreviewChanelChange)
	ThirtyDayData.AddListener(UpdateActivityNotice)
	SevenDayData.AddListener(UpdateActivityNotice)
	MonthCardData.AddListener(UpdateActivityNotice)
	UnionInfoData.AddListener(UpdateNotice)
	UnionBuildingData.AddListener(UpdateNotice)
	UnionInfoData.AddListener(UpdateUnionHelp)
	UnionHelpData.AddListener(UpdateUnionHelp)
	OnlineRewardData.AddListener(UpdateOnlineRewardIcon)
	BuffData.AddListener(UpdateBuffListIcon)
	TalentInfoData.AddListener(UpdateTalent)
	EquipData.AddListener(UpdateTalent)
	UnionInfoData.AddListener(UnionTechData.UpdateTech)
	UnionTechData.AddNormalDonateListener(UpdateNotice)
	MilitaryRankData.AddListener(UpdateMilitaryRankNotice)
	WorldCityData.AddListener(UpdateCityMapNotice)
	-- HeroListData.RegistAttributeModel()
	GeneralData.RegistAttributeModel()
	MainData.RegistAttributeModel()
	RuneData.RegistAttributeModel()
	AttributeBonus.RegisterAttBonusModule(_M)
	UnionHelpData.AddListener(MainCityQueue.UpdateQueue)
	NotifyInfoData.AddListener(UpdateNotice)
	MissionListData.AddListener(DailyActivityData.ProcessActivity)
	ActivityData.AddListener(DailyActivityData.ProcessActivity)
	ActivityData.AddListener(_ui.UpdateActivity)
	DailyActivityData.AddListener(SetDailyActivityRedPoint)
	ItemListData.AddListener(SetDailyActivityRedPoint)
	GovernmentData.AddGovStateListener(UpdateGovState)
	FortressData.AddStateListener(UpdateFortState)
	StrongholdData.AddStateListener(UpdateStrongholdState)
	RebelSurroundNewData.AddListener(CheckRebelSurroundBtn)
	ExistTestData.AddCloseListener(UpdateExistTest)
	ExistTestData.AddNoticeListener(UpdateExistTestRed)
	UnionResourceRequestData.AddListener(UpdateNotice)
	DefenseData.AddListener(UpdateWastEffect)
	MobaData.AddListener(UpdateMobaUI)

	EventDispatcher.Bind(UnionCityData.OnRewardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, UpdateNotice)
	EventDispatcher.Bind(Goldstore.OnNoticeStatusChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, UpdateShopNotice)
	EventDispatcher.Bind(GeneralData.OnNoticeStatusChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, UpdateNotice)
	EventDispatcher.Bind(GiftPackData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(iapGoodInfo, change) UpdateGlobalLimitPack() end)

	EventDispatcher.Bind(HeroCardData.OnAwardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function()
        UpdateWelfareNotice(7000)
    end)

	-- BuffData.AddListener(CheckHotTime)
	
	-- ArmyListData.AddListener(UpdateCureBuildingIcon)
	-- UpdateFreeChest()
	
	btn_update = transform:Find("Container/btn_update").gameObject
	local size = AssetBundleManager.Instance:GetNeedLoadSize()
	if not System.String.IsNullOrEmpty(size) then
		btn_update:SetActive(true)
	else
		btn_update:SetActive(false)
	end
	SetClickCallback(btn_update, function(go)
		GUIMgr:CreateMenu("update", false)
	end)
	
	--chat 
	ChatMenu = {}
	ChatMenu.bg = transform:Find("Container/bg_liaotian")
	ChatMenu.chatBtn = transform:Find("Container/bg_liaotian/btn_jiantou"):GetComponent("UIButton")
	ChatMenu.name1 = transform:Find("Container/bg_liaotian/name1")
	ChatMenu.name2 = transform:Find("Container/bg_liaotian/name2")
	ChatMenu.redPoint = transform:Find("Container/bg_liaotian/redpoint")
	ChatMenu.previewTog = {}
	for i=ChatMsg_pb.chanel_private , ChatMsg_pb.chanel_guild , 1 do
		ChatMenu.previewTog[i] = transform:Find("Container/bg_liaotian/pointbar/point" .. i):GetComponent("UIToggle")
	end
	ChatMenu.previewTogKey = {}
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_private] = {}
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_private].key = ChatMsg_pb.chanel_private
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_private].last = ChatMsg_pb.chanel_guild
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_world] = {}
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_world].key = ChatMsg_pb.chanel_world
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_world].next = ChatMsg_pb.chanel_guild
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_guild] = {}
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_guild].key = ChatMsg_pb.chanel_guild
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_guild].next = ChatMsg_pb.chanel_private
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_guild].last = ChatMsg_pb.chanel_world

	SetClickCallback(ChatMenu.chatBtn.gameObject, function(go)
		UpdateCountInfo(function()
			GUIMgr:CreateMenu("Chat", false)
		end)
	end)
	
    AudioMgr.Instance:PlayMusic("MUSIC_maincity_background", 0.2, true, 1)
    SetClickCallback(transform:Find("Container/TopBar/bg_gold").gameObject, function(go)
    	store.Show(7)
    end)

    SetClickCallback(transform:Find("Container/TopBar/bg_vip/bg_msg/num").gameObject, function(go)
		local okCallback = function()
			MessageBox.Clear()
		end
		--MessageBox.Show(TextMgr:GetText("common_ui1"), okCallback)
		VIP.Show()
		--[[
		FunctionListData.IsFunctionUnlocked(5, function(isactive)
			if isactive then
				VIP.Show()
			else
				FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(5)), Color.white)
			end
		end)
		--]]
    end)
    
    warning[1] = {}
    warning[1].btn = promptList.alertB
    warning[1].kuang = transform:Find("Container/AlertBkuag").gameObject
    warning[1].music = warning[1].btn.transform:Find("scale/AlertRwave"):GetComponent("AudioSource")
    warning[1].music.playOnAwake = false
    warning[2] = {}
    warning[2].btn = promptList.alertR
    warning[2].kuang = transform:Find("Container/AlertRkuag").gameObject
    warning[2].music = warning[2].btn.transform:Find("scale/AlertRwave"):GetComponent("AudioSource")
	warning[2].music.playOnAwake = false
	
	for i, v in ipairs(warning) do
		if AudioMgr.SfxSwith and v.music.volume == 0 then
			v.music.volume = 0.5
		elseif not AudioMgr.SfxSwith and v.music.volume > 0 then
			v.music.volume = 0
		end
	end
    
    RadarData.AddListener(RadarListener)
    RadarListener()
    
    if not FunctionListData.IsFunctionUnlocked(100, function(isactive)
    	if not isactive then
    		if not GUIMgr:IsMenuOpen("ChapterSelectUI") then
    			ChapterSelectUI.Show(101)
    		end
    	end
    end) then
    	ChapterSelectUI.Show(101)
    end
    
    Notice_Tips.OpenUI()
    warning[1].kuang.transform:SetParent(Notice_Tips.GetConatiner(), false)
	NGUITools.SetLayer(warning[1].kuang, Notice_Tips.gameObject.layer)
	warning[1].kuang.transform:Find("AlertR1"):GetComponent("UITexture"):SetAnchor(Notice_Tips.GetConatiner().gameObject, 0, 0, 0, 0)
    warning[2].kuang.transform:SetParent(Notice_Tips.GetConatiner(), false)
	NGUITools.SetLayer(warning[2].kuang, Notice_Tips.gameObject.layer)
	warning[2].kuang.transform:Find("AlertR1"):GetComponent("UITexture"):SetAnchor(Notice_Tips.GetConatiner().gameObject, 0, 0, 0, 0)
    
    UpdateTalent()
    
	ActivityData.Initialize(function()
		CheckPowerRankBtn()
		--[[
	FunctionListData.IsFunctionUnlocked(309, function(isactive)
		if isactive then
			_ui.PowerRank.gameObject:SetActive(ActivityData.IsActivityAvailable(1032))
		else
			_ui.PowerRank.gameObject:SetActive(false)
		end
	end)
		--]]
	end)

	FortsData.Initialize()

	MainCityUI.UpdateVipNotice()

	UpdateBattleFieldIcon()

	store.Initialize()
	-- vip体验卡
	_ui.viptips = transform:Find("Container/TopBar/bg_tips (1)")
	_ui.viptipstext = transform:Find("Container/TopBar/bg_tips (1)/time"):GetComponent("UILabel")
	_ui.vipeffect = transform:Find("Container/TopBar/bg_vip/vip_tiyanka")
	if ConfigData.GetVipExperienceCard() == false then
		local vip = MainData.GetVipValue()
		if vip.viptimeTaste ~= 0 and vip.viplevel < vip.viplevelTaste then
			if vip.viptimeTaste > Serclimax.GameTime.GetSecTime() then
				RefreshVipExperienceCard()
			end
		end		
	end	
	RefreshVipEffect()

	if ActivityEntrance.CurShowID > 0 then
        local list = ActivityData.GetListData()
        local data = nil
        for i=1,#(list) do
            if list[i].activityId == ActivityEntrance.CurShowID then
                data = list[i]
                break
            end
        end
        ActivityStage.Show(ActivityEntrance.CurShowID,data.leftCount,data.countMax)
        ActivityEntrance.CurShowID = -1
    elseif SandSelect.GetCompletedChapter() ~= nil then
        SandSelect.Show(SandSelect.GetCompletedChapterType())
    elseif ChapterSelectUI.GetSelectedChapter() ~= nil then
    	local levels = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ReturnLevel).value:split(",")
    	local selectedlevel = ChapterSelectUI.GetSelectedLevel()    
    	local iscontain = false
    	for i, v in ipairs(levels) do
    		if tonumber(v) == selectedlevel then
    			iscontain = true
    		end
    	end
    	if ChapterSelectUI.IsLevelFirst(selectedlevel) and iscontain and FunctionListData.IsFunctionUnlocked(100, nil) then
    		--UpdateCountInfo()
    	else
    		ChapterSelectUI.Show(ChapterSelectUI.GetSelectedChapter())
    	end
    end

    _ui.armyStatusSprite = transform:Find("Container/TopBar/soldier_now"):GetComponent("UISprite")
    _ui.armyStatusEffect = transform:Find("Container/TopBar/soldier_now/tihuan").gameObject
    SetClickCallback(_ui.armyStatusSprite.gameObject, SoldierProduction.Show)

    _ui.allianceInvite = {}
    _ui.allianceInvite.transform = transform:Find("Container/btn_unioninvite/Container")
    _ui.allianceInvite.gameObject = _ui.allianceInvite.transform.gameObject
    _ui.allianceInvite.animation = _ui.allianceInvite.transform:GetComponent("TweenPosition")
    _ui.allianceInvite.playerNameWrapper = transform:Find("Container/btn_unioninvite/playerNameWrapper"):GetComponent("UILabel")
    _ui.allianceInvite.notice = _ui.allianceInvite.transform:Find("notice").gameObject
    _ui.allianceInvite.count = _ui.allianceInvite.transform:Find("notice/Label"):GetComponent("UILabel")
    _ui.allianceInvite.leftArrow = _ui.allianceInvite.transform:Find("bg_arrow_left").gameObject
    _ui.allianceInvite.rightArrow = _ui.allianceInvite.transform:Find("bg_arrow_right").gameObject

    _ui.allianceInvite.recommendation = {}
    _ui.allianceInvite.recommendation.transform = _ui.allianceInvite.transform:Find("recommendation")
    _ui.allianceInvite.recommendation.gameObject = _ui.allianceInvite.recommendation.transform.gameObject
    _ui.allianceInvite.recommendation.name = _ui.allianceInvite.recommendation.transform:Find("name"):GetComponent("UILabel")
    _ui.allianceInvite.recommendation.slogan = _ui.allianceInvite.recommendation.transform:Find("slogan"):GetComponent("UILabel")


	_ui.allianceInvite.playerInvite = {}
	_ui.allianceInvite.playerInvite.transform = _ui.allianceInvite.transform:Find("playerInvite")
	_ui.allianceInvite.playerInvite.gameObject = _ui.allianceInvite.playerInvite.transform.gameObject
    _ui.allianceInvite.playerInvite.message = _ui.allianceInvite.playerInvite.transform:Find("message"):GetComponent("UILabel")

    _ui.allianceInvite.badge = {}
    UnionBadge.LoadBadgeObject(_ui.allianceInvite.badge, _ui.allianceInvite.transform:Find("badge"))

    _ui.extinguishObject = transform:Find("Container/defencenumber_info").gameObject
    _ui.extinguishButton = transform:Find("Container/defencenumber_info/btn_mass"):GetComponent("UIButton")
    SetClickCallback(_ui.extinguishButton.gameObject, function(go)
        DefenceNumber.Show()
    end)
    SetClickCallback(_ui.allianceInvite.transform:Find("background/join btn").gameObject, function()
    	if currentInvite > 0 then
    		local currentAlliance = UnionInfoData.GetData().guildInfo
    		local invite = AllianceInvitesData.GetPendingInvite(currentInvite)
    		MessageBox.ShowConfirmation(currentAlliance.guildId ~= 0, System.String.Format(TextMgr:GetText("ui_inviteunion_code4"), string.format("[%s]%s", currentAlliance.banner, currentAlliance.name), string.format("[%s]%s", invite.guildBanner, invite.guildName)), function()
    			AllianceInvitesData.AcceptInvite(currentInvite)
    		end)
    	elseif currentInvite < 0 then
    		AllianceInvitesData.JoinRecommendedAlliance()
    	end
    end)

    SetClickCallback(_ui.allianceInvite.transform:Find("background/btn_close").gameObject, function()
    	if currentInvite > 0 then
    		AllianceInvitesData.RefuseInvite(currentInvite)
    	elseif currentInvite < 0 then
    		AllianceInvitesData.ClearRecommendedAlliance()
    		SetCurrentInvite(0)
    	end
    end)

    SetClickCallback(_ui.allianceInvite.leftArrow, function()
    	SetCurrentInvite(currentInvite - 1)
    end)

    SetClickCallback(_ui.allianceInvite.rightArrow, function()
    	SetCurrentInvite(currentInvite + 1)
    end)

    SetClickCallback(_ui.allianceInvite.transform:Find("badge/btn_check").gameObject, function()
    	if currentInvite > 0 then
    		UnionPubinfo.RequestShow(AllianceInvitesData.GetPendingInvite(currentInvite).guildId)
    	elseif currentInvite < 0 then
    		UnionPubinfo.RequestShow(AllianceInvitesData.GetRecommendedAlliance().guildId)
    	end
    end)

    EventDispatcher.Bind(AllianceInvitesData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, function()
    	local numPendingInvites = AllianceInvitesData.GetNumPendingInvites()

    	if currentInvite ~= 0 then
    		SetCurrentInvite(math.min(numPendingInvites, currentInvite))
    	end

    	hasNewAllianceInvite = numPendingInvites > 0
    end)

    AddDelegate(GUIMgr, "onMenuCreate", RecordTimeEnterMainCityUI)
	AddDelegate(GUIMgr, "onMenuClose", RecordTimeEnterMainCityUI)
	UnionMobaActivityData.AddTimeListener(UpdateGuildMobaNotify)
	_ui.isawake = false
	CheckFunctionList()
end

function Start()
	if Global.GetMenuBackState() ~= nil then
		local battleBackMenu = Global.GetMenuBackState()
		Global.ClearMenuBackState()
		if battleBackMenu.MainUI == "WorldMap" then
			MainCityUI.ShowWorldMap(battleBackMenu.PosX , battleBackMenu.PosY, false)
		end
	end
	
	resEffects = {}
	iconEffects = {}
	uiGameObjectPressed = false
    AttributeBonus.RegisterAttBonusModule(BuffData)
	Global.InitFileRecorder()
	GroupChatData.GetGroupLastChat()

	RequestChatInfo()
	if UnionInfoData.GetGuildId() ~= 0 then
		UnionMessageData.RequestUnionMessageChatInfo(UnionInfoData.GetGuildId())
	end
	
	RequestEnergy(1)
	RequestEnergy(2)

    UpdateMainData()
    UpdateMoney()
    
    UpdateMail()
    UpdateTemprotyBagIcon()
    CheckRecommendedMission()
	PreviewChanelChange()
   -- UpdateChatHint()
	UpdateBuffListIcon()
    UpdateNotice()
    UpdateShopNotice()
    UpdateShopCountdown()
	UpdateBattleReward()
	UpdateMissionNotice()
    
    UpdateMilitaryRankNotice()
	UpdateCityMapNotice()
    UpdateUnionHelp()
	
	--RequestNotifyInfoRequest(nil)
	RequestJoinUnionNotify()
	RequestOnlineReward()
	UnionHelpData.RequestGuildMemHelp()
	RuneData.RequestRuneInfoData()
	--RequestHomeExile()
	UpdateWastEffect()
	_ui.armyStatus = Barrack.GetArmyStatus()
	UpdateArmyStatus()

    BattleMoveData.RequestSaveArchiveDataFirst()
    --BattleMoveData.GetOrReqUserAttackFormaionFirst()
    --BattleMoveData.GetOrReqUserDefendFormaionFirst()
    --ResourceLibrary.GetUIPrefab("WorldMap/BattleMove");
	

	if jumpMenu ~= nil then
		if jumpMenu == "HeroList" then
			HeroList.Show()
		else
			GUIMgr:CreateMenu(jumpMenu, false)
		end
		jumpMenu = nil
		return
	end
	
	if MailListData.IsNeedUpdate() then
		promptList.Mail.transform.parent.gameObject:SetActive(true)
		coroutine.start(function()
			coroutine.step()
			promptList.Grid:Reposition()
		end)
    end
    --ShowCards(true)
    canshowmission = true
    if GameObject.Find("WorldMap") ~= nil then
    	canshowmission = false
    	onlineReward.bg.gameObject:SetActive(false)
    end
	hasCityMenu = false
	--init armycost timer
    --RequestArmyCost()
	requestArmyCoseTime = Serclimax.GameTime.GetSecTime()
	requestArmyCoseDuration = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RequestArmyCost).value) * 1000
	--[[
	FunctionListData.IsFunctionUnlocked(10000, function(isactive)
		if isactive then
			ActivityNotice.CheckRedPoint(function(needshow)
				if needshow then
					SetActivityRedPoint()
				end
			end)
		end
	end)
	--]]

	UpdateQueueTips()

	if IsLoginEnter then
	    Event.Init()
    end

    if not Event.CheckAll() then
        SoldierUnlock.CheckShow()
    end
	
	
	chatPreviewOffset = 0
	SetDragCallback(ChatMenu.chatBtn.gameObject , function(go , delt)
		chatPreviewOffset = chatPreviewOffset + delt.x
	end)
	SetDragEndCallback(ChatMenu.chatBtn.gameObject , function(go)
		--print(delt.x)
		if chatPreviewOffset < -100 then
			PreviewChanelChange(2)
		end
		
		if chatPreviewOffset > 100 then
			PreviewChanelChange(1)
		end
		chatPreviewOffset = 0
	end)
	UpdateMassBtn()
	ExistTest.IsNeedShow()
	
	ChatData.RequestBlackList();
end

function Update()
	if _ui == nil then
		return
	end
	-- vip体验卡
	if viptips then
		viptime = viptime - Time.deltaTime
		if viptime <=0 then 
			viptips = false
			_ui.viptips.gameObject:SetActive(false)
			CountDown.Instance:Remove("viptipstext")
			viptime = 10
		end
	end

	if ConfigData.GetVipExperienceCard() == false then
		local vip = MainData.GetVipValue()
		if vip.viptimeTaste ~= 0 and vip.viplevel < vip.viplevelTaste then
			if vip.viptimeTaste <= Serclimax.GameTime.GetSecTime() then				
				ConfigData.SetVipExperienceCard(true)
				MainData.UpdateVip(vip)
				VIPLevelup.Show(vip.viplevelTaste, vip.viplevel, 2)				
				vip.viptimeTaste = 0
				vip.viplevelTaste = 0
				_ui.vipeffect.gameObject:SetActive(false)
			end
		end
	end


	if loginEnter then
		if GUIMgr:FindMenu("ChapterSelectUI") == nil then
			local tutorial = GameObject.Find("Tutorial")
			if tutorial ~= nil then
				tutorialobj = tutorial
				tutorial:SetActive(false)
			end
		end
	end
	ResEffectUpdate()
	
	if Serclimax.GameTime.GetSecTime() >= requestArmyCoseTime then
		requestArmyCoseTime = Serclimax.GameTime.GetSecTime() + 10000
		RequestArmyCost()
	end
	
	--buff本地刷新
	local secTime = Serclimax.GameTime.GetSecTime()
	if secTime - updataBuffTimer >= 2 then
		updataBuffTimer = secTime
		BuffData.UpdateBuffTime(updataBuffTimer)
	end

	if secTime - updateMoneyTimer > 10 then
	    updateMoneyTimer = secTime
        local req = ItemMsg_pb.MsgGetMoneyRequest()
        Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgGetMoneyRequest, req, ItemMsg_pb.MsgGetMoneyResponse, function (msg)
            MoneyListData.UpdateData(msg.money.money)
        end, true)
    end
	
	--建筑科研队列提示
	if notifyShowQueueTips and Serclimax.GameTime.GetSecTime() - notifyShowQueueTipsTime > queueTipsShowTime then
		if queueTips ~= nil and not queueTips:Equals(nil) then
			queueTips:SetActive(true)
			notifyShowQueueTips = false
		end
	end
	
	
	--拉取聊天记录
	--[[if Serclimax.GameTime.GetSecTime() >= ChatData.GetNextTime() then
		if not requestChat then 
			requestChat = true
			RequestChat(nil , function() 
				requestChat = false 
			end)
			
		end
	end]]

	for i, v in ipairs(warning) do
		if AudioMgr.SfxSwith and v.music.volume == 0 then
			v.music.volume = 0.5
		elseif not AudioMgr.SfxSwith and v.music.volume > 0 then
			v.music.volume = 0
		end
	end
	
	if _ui.hotTimeLeft ~= nil and _ui.hotTimeLeft > 0 then
		local leftTimeSec = _ui.hotTimeLeft - Serclimax.GameTime.GetSecTime()
		if leftTimeSec >= 0 then
			_ui.hotTimeLabel.text = Global.GetLeftCooldownTextLong(_ui.hotTimeLeft)--Serclimax.GameTime.SecondToString3(leftTimeSec)
		else
			_ui.hotTimeLabel.text = "00:00:00"
			_ui.hotTimeLeft = 0
			--RequestNCheckHotTime()
		end
		
	end
end

function HideUpdateBtn()
	btn_update:SetActive(false)
end

function Close()
	EventDispatcher.UnbindAll(_M)
	CountDown.Instance:Remove("MobaEntrance")
	CountDown.Instance:Remove("Limited Time")
	CountDown.Instance:Remove("zeroyuan")
	RemoveDelegate(GUIMgr, "onMenuCreate", RecordTimeEnterMainCityUI)
	RemoveDelegate(GUIMgr, "onMenuClose", RecordTimeEnterMainCityUI)
	
	coroutine.stop(HideWorldMapInternalCoroutine)
	coroutine.stop(ShowWorldMapCoroutine)
	coroutine.stop(ShowRebelSurroundCoroutine)
	coroutine.stop(ShowWorldMapPreViewCoroutine)
	coroutine.stop(advice_coroutine)
	coroutine.stop(ShowSurroundAdvanceCoroutine)
	print("closeMainCity")
	CountDown.Instance:Remove("UpdateRebelSurroundEffect")
	CountDown.Instance:Remove("UpdateRebelSurroundTime")
	CountDown.Instance:Remove("RequestEnergy")
	CountDown.Instance:Remove("FreeChest")
	ResBar.Close()
	BuildingShowInfoUI.Close()
    noticeList = nil 
	menuTarget = nil
	cityMenu.needshow = false
	HideCityMenu()
	MainData.RemoveListener(UpdateMainData)
	MainData.RemoveListener(UpdateFirstpurchase)
    MoneyListData.RemoveListener(UpdateMoney)
	--ItemListData.RemoveListener(UpdateTemprotyBagIcon)
	MissionListData.RemoveListener(CheckRecommendedMission)
	--RemoveCancelUpgradeListener(CheckRecommendedMission)
	ItemListData.RemoveListener(UpdateNotice)
	MissionListData.RemoveListener(UpdateNotice)
	MissionListData.RemoveListener(UpdateMissionNotice)
    RebelWantedData.RemoveListener(UpdateActivityAllNotice)
	RaceData.RemoveListener(UpdateActivityAllNotice)
	NewRaceData.RemoveListener(UpdateActivityAllNotice)
    ActivityTreasureData.RemoveListener(UpdateActivityAllNotice)
	MilitaryActionData.RemoveListener(UpdateMissionNotice)
	MilitaryRankData.RemoveListener(UpdateMilitaryRankNotice)
	WorldCityData.RemoveListener(UpdateCityMapNotice)
    -- HeroListData.RemoveListener(UpdateNotice)
    MailListData.RemoveListener(UpdateNotice)
    UnlockArmyData.RemoveListener(CheckUnlockArmy)
    MonthCardData.RemoveListener(UpdateActivityNotice)
    RadarData.RemoveListener(RadarListener)
	ChatData.RemoveListener(PreviewChanelChange)
	UnionInfoData.RemoveListener(UpdateNotice)
	UnionBuildingData.RemoveListener(UpdateNotice)
	UnionInfoData.RemoveListener(UpdateUnionHelp)
	UnionHelpData.RemoveListener(UpdateUnionHelp)
	OnlineRewardData.RemoveListener(UpdateOnlineRewardIcon)
	BuffData.RemoveListener(UpdateBuffListIcon)
	TalentInfoData.RemoveListener(UpdateTalent)
	EquipData.RemoveListener(UpdateTalent)
	UnionInfoData.RemoveListener(UnionTechData.UpdateTech)
	UnionHelpData.RemoveListener(MainCityQueue.UpdateQueue)
	NotifyInfoData.RemoveListener(UpdateNotice)
	MissionListData.RemoveListener(DailyActivityData.ProcessActivity)
	ActivityData.RemoveListener(DailyActivityData.ProcessActivity)
	ActivityData.RemoveListener(_ui.UpdateActivity)
	DailyActivityData.RemoveListener(SetDailyActivityRedPoint)
	ItemListData.RemoveListener(SetDailyActivityRedPoint)
	GovernmentData.RemoveGovStateListener(UpdateGovState)
	FortressData.RemoveStateListener(UpdateFortState)
	StrongholdData.RemoveStateListener(UpdateStrongholdState)
	RebelSurroundNewData.RemoveListener(CheckRebelSurroundBtn)
	UnionTechData.RemoveNormalDonateListener(UpdateNotice)
	ExistTestData.RemoveListener(UpdateExistTest)
	ExistTestData.RemoveNoticeListener(UpdateExistTestRed)
	UnionResourceRequestData.RemoveListener(UpdateNotice)
	--UnionHelpData.RemoveListener(UpdateUnionHelp)
	--BuffData.RemoveListener(CheckHotTime)
	DefenseData.RemoveListener(UpdateWastEffect)
	MobaData.RemoveListener(UpdateMobaUI)
	UnionMobaActivityData.RemoveTimeListener(UpdateGuildMobaNotify)
	CountDown.Instance:Remove("guildmobatime")
	
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	--vip体验卡
	CountDown.Instance:Remove("viptipstext")
	SetTargetStopFlash()
	--[[if CheckArmyCostCoroutine ~= nil then
		coroutine.stop(CheckArmyCostCoroutine)
		CheckArmyCostCoroutine = nil
	end]]
	HideWorldMapInternalCoroutine = nil
	ShowRebelSurroundCoroutine = nil
	ShowWorldMapCoroutine = nil
	promptList = nil
	btnWar = nil
	ui.btnZhankai = nil
	labelVip = nil
	labelEnergy = nil
	iconEnergy = nil
	buildInfoBar = nil
	iconPlayerBtn = nil
	btn_update = nil
	arrayBar = nil
	container = nil
	mainLevel = nil
	mainBuff = nil
	bg = nil
	topBar = nil
	temproryBagTime = nil
	resourceBar = nil
	ChatMenu = nil
	_ui = nil
	ui = nil
end

--建造建筑（建筑类型id，地块id，建造类型：“1普通，2金币”，回调（msg））
local function BuildBuilding(typeid, landid, buildtype, callback)
    MissionListData.BlockMsg()
    local req = BuildMsg_pb.MsgConstructBuildRequest()
    req.type = typeid
    req.landid = landid
    req.upgradeType = buildtype
    LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgConstructBuildRequest, req:SerializeToString(), function (typeId, data)
        local msg = BuildMsg_pb.MsgConstructBuildResponse()
        msg:ParseFromString(data)
        callback(msg)
        if typeid == 11 then
            Event.Resume(2)
        elseif typeid == 12 then
            Event.Resume(3)
        elseif typeid == 21 then
            Event.Resume(4)
        end
        SceneStory.ResumeStory("WaitBuilding", typeid)
    end, true)
end

local function GetResObjectFromPool()
	
end

local function GetResEffectFromPool()
	local RESPOOL_SIZE = 50
	local reseffectPool = {}
	local reseffectActiveCount = 0
	
	if #reseffectPool < RESPOOL_SIZE then
		local object = {}
        local gameObject = Instantiate(prefab)
	end
	
end

local function ResEffect(build, target, effName, num)
	local emmitNum = num

	local singAn = 60
	local loopAn = 2
	local durant = 0.5
	--print(target.transform.position.x..","..target.transform.position.y .. "," ..target.transform.position.z)
	
	local timestep = durant / emmitNum
	local stepAn = (singAn * loopAn) / emmitNum
	local angel = singAn * loopAn
	local dir = 1
	
	--local effects = {}
	
	local curStep = -singAn/2
	local angelEmmit = Vector3.up * Quaternion.AngleAxis(curStep, Vector3.forward)
	
	local mainCamera = maincity.GetMainCamera()
	local uiCamera = GUIMgr.UIRoot.transform:Find("Camera"):GetComponent("Camera")
	local effectParent = GameObject.Find("maincity(Clone)/resEffect")
	if effectParent == nil then
		return
	end
	local activeEff = true
	--local cor = coroutine.start(function()
		local tPos = nil
		local tIconEff = target.transform.parent:Find("ZiyuanHuode")
		local effectPrefab = ResourceLibrary.GetUIPrefab("BuildingCommon/" .. effName)
    
--	local resEffectSize = 20
--	local resEffectActiveIdx = 1

		for i=1 , emmitNum do
			local effects = nil
			if #resEffects <= resEffectSize then
				--effects.go = GameObject.Instantiate(effectPrefab)--ResourceLibrary.GetUIInstance("BuildingCommon/" .. effName)
				effects = {}
				effects.go = NGUITools.AddChild(effectParent , effectPrefab)
				effects.go.transform:SetParent(effectParent.transform , false)
				table.insert(resEffects , effects)
			else
				if resEffects[resEffectActiveIdx].life == 0 then
					effects = resEffects[resEffectActiveIdx]
				else
					for i=1 , #resEffects , 1 do
						if resEffects[i].life == 0 then
							effects = resEffects[i]
							resEffectActiveIdx = i
						end
					end
				end
				resEffectActiveIdx = resEffectActiveIdx + 1
				if resEffectActiveIdx > #resEffects then
					resEffectActiveIdx = 1
				end
				
			--print(resEffectActiveIdx , effects.go)
			end
			
			if effects == nil or effects.go == nil then
				return
			end
			
			effects.go:SetActive(true)
			effects.go.transform.position =  build.land.transform.position + Vector3(0 , 5 , 0)
			effects.speed = 40 + math.random(1,40)
			effects.emitdir = angelEmmit
			effects.isboot = true
			effects.target = target
			effects.targetIconEff = tIconEff--target.transform.parent:Find("ZiyuanHuode")
			effects.life = 3.5 
			if tPos == nil then
				tPos = GUIMgr.Instance:UIWorldToGameWorld(target.transform.position, effects.go.transform.position)
			end
			effects.targetPos = tPos--GUIMgr.Instance:UIWorldToGameWorld(target.transform.position, effects.go.transform.position)
			effects.dir = (tPos - effects.go.transform.position).normalized
			
	--		coroutine.wait(timestep)
			
			if dir == 1 then
				curStep = curStep + stepAn
				if curStep >= singAn/2 then
					dir = 2
				end
			else
				curStep = curStep - stepAn
				if curStep <= -singAn/2 then
					dir = 1
				end
			end
			angelEmmit = Vector3.up * Quaternion.AngleAxis(curStep, Vector3.forward)
		end
	--end)
end

function ResEffectTargetUpdate()
	for i, v in pairs(resEffects) do
		if v ~= nil and not v.isboot and v.life > 0 then
			v.targetPos = GUIMgr.Instance:UIWorldToGameWorld(v.target.transform.position, v.go.transform.position)
		end
	end
end

function ResEffectUpdate()
	local speedEnd = 20
	local speed2Targetstart = 10
	local curTime = Serclimax.GameTime.GetSecTime()
	for i=1, #resEffects do
		local v = resEffects[i]
		if v ~= nil and v.life > 0 then
			if v.isboot then
				if v.speed > speedEnd then
					v.go.transform:Translate(v.emitdir * v.speed * Serclimax.GameTime.deltaTime)
					v.speed = v.speed*(1-Serclimax.GameTime.deltaTime*3)
				else
					v.isboot = false
					v.speed = speed2Targetstart
				end
			else
				local tartPos = v.targetPos--GUIMgr.Instance:UIWorldToGameWorld(v.target.transform.position, v.go.transform.position.z)
				local moveDir = (tartPos - v.go.transform.position).normalized
				if Vector3.Dot(v.dir, moveDir) <= 0 then 
					v.speed = 0
					--GameObject.DestroyImmediate(v.go)
					--table.remove(resEffects , i)
					v.life = 0
					v.go:SetActive(false)
					
					local iconEff = v.targetIconEff
					if iconEff ~= nil and not iconEff.gameObject.activeSelf then
						iconEff.gameObject:SetActive(true)
						local ieff = {}
						ieff.time = curTime
						ieff.iconEff = iconEff
						table.insert(iconEffects , ieff)
					end
				else
					local tartPos = v.targetPos--GUIMgr.Instance:UIWorldToGameWorld(v.target.transform.position, v.go.transform.position.z)
					local moveDir = (tartPos - v.go.transform.position).normalized
					v.go.transform:Translate(moveDir * v.speed * Serclimax.GameTime.deltaTime)
					v.speed = v.speed*(1 + Serclimax.GameTime.deltaTime*3)
					v.dir = moveDir
				end
			
			
				
				--[[local tartPos = v.targetPos--GUIMgr.Instance:UIWorldToGameWorld(v.target.transform.position, v.go.transform.position.z)
				local moveDir = (tartPos - v.go.transform.position).normalized
				v.go.transform:Translate(moveDir * v.speed * Time.deltaTime)
				v.speed = v.speed*(1+Time.deltaTime*3)
				local nextDir = (tartPos - v.go.transform.position).normalized
				if Vector3.Dot(nextDir, moveDir) < 0 then
					v.speed = 0
					GameObject.DestroyImmediate(v.go)
					--resEffects[i] = nil
					table.remove(resEffects , i)
					--resEffects[i] = nil]]
					
					--效果1
					--[[iconEffects[i] = {}
					iconEffects[i].go = ResourceLibrary.GetUIPrefab("BuildingCommon/ZiyuanHuode")
					iconEffects[i].start = Serclimax.GameTime.GetSecTime()
					iconEffects[i].id = ""..build.data.uid .. i
					local iconEffIns = NGUITools.AddChild(target , iconEffects[i].go).transform
					iconEffIns.gameObject:SetActive(true)
					iconEffIns:SetParent(target.transform , false)
					iconEffIns.gameObject.name = ""..build.data.uid .. i
					]]
					
					--[[效果2
					print(target.transform.parent.gameObject.name)
					local iconEff = target.transform.parent:Find("ZiyuanHuode")
					if not iconEff.gameObject.activeSelf then
						iconEff.gameObject:SetActive(true)
					else
						iconEff.gameObject:SetActive(false)
					end
					]]
					
					--效果3
					--[[local iconEff = v.targetIconEff
					if iconEff ~= nil and not iconEff.gameObject.activeSelf then
						iconEff.gameObject:SetActive(true)
						local ieff = {}
						ieff.time = curTime
						ieff.iconEff = iconEff
						table.insert(iconEffects , ieff)
					end
				end]]
			end
			
			--生命周期
			if v.life > 0 then
				v.life = v.life - Serclimax.GameTime.deltaTime
			else
				--GameObject.DestroyImmediate(v.go)
				--resEffects[i] = nil
				--table.remove(resEffects , i)
				v.life = 0
				v.go:SetActive(false)
			end
		end
	end
	
	--效果1
	--[[for k , w in pairs(iconEffects) do
		if Serclimax.GameTime.GetSecTime() > w.start + 1 then
			local unActiveEff = target.transform:Find(tostring(w.id))
			if unActiveEff ~= nil then
				--print("212121212")
				GameObject.DestroyImmediate(unActiveEff.gameObject)
				iconEffects[k] = nil
				--table.Remove(w , k)
			end
		end
	end]]
	
	--效果3
	if iconEffects ~= nil and #iconEffects > 0 then
		for i , v in pairs(iconEffects) do
			if v ~= nil and Serclimax.GameTime.GetSecTime() > v.time + 0.3 then
				if v.iconEff.gameObject.activeSelf then
					v.iconEff.gameObject:SetActive(false)
					iconEffects[i] = nil
				end
			end
		end
	end
end

--点击资源收获
function GetBuildResource(n , _transform)
	local build = nil
	if n == -1 then
		build = maincity.GetCurrentBuildingData()
	else
		build = maincity.GetBuildingByUID(n)
	end
	
	--间隔时间是否达到可收取时长
	if maincity.DisplayResourceNumber(build) ~= 1 then
		return
	end
	
	local iconTrf = transform:Find(System.String.Format("Container/buildinginfo/BuildingShowInfoUI/resBubble_{0}/Pivot/bg" , build.data.uid))
	if build ~= nil then
		if build.buildingData ~= nil then
			if build.buildingData.logicType == 10 then
				local resYield = TableMgr:GetBuildingResourceYield(build.buildingData.id , build.data.level)
				--print(resYield)
				
				--本地显示
				local lastValue = 0
				if build.buildingData.id == 11 then --农田
					lastValue = MoneyListData.GetFood()
				end
				if build.buildingData.id == 12 then --冶炼厂
					lastValue = MoneyListData.GetSteel()
				end
				if build.buildingData.id == 13 then --炼油厂
					lastValue = MoneyListData.GetOil()
				end
				if build.buildingData.id == 14 then --发电站
					lastValue = MoneyListData.GetElec()
				end
				
				
				
				
				local lastGetTime = build.data.gathertime
				local nowTime = GameTime.GetSecTime()
				local curYield = (nowTime - lastGetTime) / 60 * resYield
				--print("local yield : " .. curYield)
				--服务器请求
				local req = BuildMsg_pb.MsgGatherResourceRequest()
				req.uid = build.data.uid
				LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgGatherResourceRequest, req:SerializeToString(), function(typeId, data)
				local msg = BuildMsg_pb.MsgGatherResourceResponse()
				msg:ParseFromString(data)
				if msg.code == 0 then
					UpdateRewardData(msg.fresh)
					maincity.RefreshResourceTime(msg)
					local increase = 0
					local resNum
					if build.buildingData.id == 11 then --农田
						--increase = MoneyListData.GetFood() - lastValue
						resNum = transform:Find(string.format("Container/resourebar/bg_resoure (1)/num"))
					end
					if build.buildingData.id == 12 then --冶炼厂
						--increase = MoneyListData.GetSteel() - lastValue
						resNum = transform:Find(string.format("Container/resourebar/bg_resoure (2)/num"))
						
					end
					if build.buildingData.id == 13 then --炼油厂
						--increase = MoneyListData.GetOil() - lastValue
						resNum = transform:Find(string.format("Container/resourebar/bg_resoure (3)/num"))
					end
					if build.buildingData.id == 14 then --发电站
						--increase = MoneyListData.GetElec() - lastValue
						resNum = transform:Find(string.format("Container/resourebar/bg_resoure (4)/num"))
					end
					
					for _ , v in ipairs(msg.reward.item.item) do
						--print("getres build:" .. build.data.uid .. "increase : " .. increase)
						local itemTBData = TableMgr:GetItemData(v.baseid)
						increase = v.num
						if iconTrf ~= nil then
						    local itemIcon = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
							FloatText.ShowAt(iconTrf.position , "+" .. math.ceil(increase), Color.green , itemIcon)
						end
					end
					
					local scalTween = resNum:GetComponent("TweenScale")
					local colorTween = resNum:GetComponent("TweenColor")
					colorTween.enabled = true
					scalTween.enabled = true
					colorTween:SetOnFinished(EventDelegate.Callback(function ()
						colorTween:ResetToBeginning()
					end))
					scalTween:SetOnFinished(EventDelegate.Callback(function ()
						colorTween:ResetToBeginning()
					end))
					
					local center = maincity.GetBuildingByID(1)
					local showNum = 0
					
					local resName = ""
					local resType
					if build.buildingData.id == 11 then
						resName = "Get1"
						resType = Common_pb.MoneyType_Food
						showNum = TableMgr:GetBuildCoreDataByLevel(center.data.level).resShowNumber1
					elseif build.buildingData.id == 12 then
						resName = "Get2"
						resType = Common_pb.MoneyType_Iron
						showNum = TableMgr:GetBuildCoreDataByLevel(center.data.level).resShowNumber2
					elseif build.buildingData.id == 13 then
						resName = "Get3"
						resType = Common_pb.MoneyType_Oil
						showNum = TableMgr:GetBuildCoreDataByLevel(center.data.level).resShowNumber3
					elseif build.buildingData.id == 14 then
						resName = "Get4"
						resType = Common_pb.MoneyType_Elec
						showNum = TableMgr:GetBuildCoreDataByLevel(center.data.level).resShowNumber4
					end
					
					showNum = math.floor(increase / showNum)
					if showNum == 0 then
						showNum = showNum + 1
					end
					ResEffect(build, moneyList[resType].gameObject, resName, showNum)
					AudioMgr:PlayUISfx("SFX_resources_get", 1, false)
				else
					print("msg erro " .. msg.code)
				end
				end, false)
			end
		end
	end
end

function FlyExp(build)
	--ResEffect(build, _ui.iconPlayer.gameObject, "GetExp", 5)
end

function CleanBuild()
	local build = maincity.GetCurrentBuildingData()
	if build.buildingData ~= nil then
		if build.buildingData.id == 3 then
			if ArmyListData.IsCuring() then
				FloatText.Show(TextMgr:GetText("hospital_ui16") , Color.red)
				return
			end
		end
	
		local req = BuildMsg_pb.MsgCleanBuildRequest()
		req.uid = build.data.uid
		LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgCleanBuildRequest, req:SerializeToString(), function(typeId, data)
		local msg = BuildMsg_pb.MsgCleanBuildResponse()
		msg:ParseFromString(data)
		if msg.code == 0 then
			maincity.RemoveBuild(msg.lands)
			MoneyListData.UpdateData(msg.fresh.money.money)
			maincity.GetBuildingListData()
		else
			print(msg.code)
            Global.FloatError(msg.code, Color.white)
		end
		end, true)
	end
end

local function SetBuildLock(id, btn)
	local islock, lockstr = maincity.IsBuildingUnlockByID(id)
	if not islock then
		btn.textnum.text = ""
		btn.suo:SetActive(true)
		--btn.btn.isEnabled = false
		return lockstr
	end
    local mx = maincity.GetBuildingMaxCount(id)
    local cr = maincity.GetBuildingCount(id)
    btn.textnum.text = cr .. "/" .. mx
    btn.textbg:SetActive(true)
    if cr < mx then
        btn.suo:SetActive(false)
        --btn.btn.isEnabled = true
        return nil
    else
        btn.suo:SetActive(true)
        --btn.btn.isEnabled = false
        return TextMgr:GetText("build_ui32")
    end
end


function UseExItemFuncEx(build,useItemId , exItemid , count)
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
	req.buildId = build.data.uid
	req.subTimeType = 1
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			useItemReward = msg.reward
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white ,ResourceLibrary:GetIcon("Item/", itemTBData.icon))

			maincity.GetBuildingListData(build.data.uid)
			MainCityUI.UpdateRewardData(msg.fresh)
			MainCityQueue.UpdateQueue()
		else
            Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

function UseExItemFunc(useItemId , exItemid , count)
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
	local buildId = maincity.GetUpgradingBuildList()[1].data.uid
	req.buildId = buildId
	req.subTimeType = 1
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			maincity.GetBuildingListData(buildId, function()
				local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
				if price == 0 then
					GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
				else
					GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
				end
				AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
				useItemReward = msg.reward

				local nameColor = Global.GetLabelColorNew(itemTBData.quality)
				local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
				FloatText.Show(showText , Color.white ,ResourceLibrary:GetIcon("Item/", itemTBData.icon))
				MainCityUI.UpdateRewardData(msg.fresh)
				MainCityQueue.UpdateQueue()
			end)
		else
            Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

local function UseExpItem(uItemid ,exItemid, uGold)
	local useGold = false
	if uGold > 0 then
		local myGold = MoneyListData.GetDiamond()
		if myGold < uGold then
			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
			FloatText.Show(TextMgr:GetText("common_ui8") , Color.white)
			return
		end
		useGold = true
	end
	
	local itemParam = {}
	itemParam.itemData = TableMgr:GetItemData(uItemid)
	itemParam.itemBagData = ItemListData.GetItemDataByBaseId(uItemid)
	itemParam.exid = exItemid
	
	if itemParam.itemData ~= nil then
		BuffView.UseItem(itemParam , 1)
	end
	--[[local req = BuildMsg_pb.MsgAccelResouceProductionRequest()
	req.uid = maincity.GetCurrentBuildingData().data.uid
	req.itemid = uItemid
	req.buy = useGold
	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelResouceProductionRequest, req, BuildMsg_pb.MsgAccelResouceProductionResponse, function(msg)
		print("msg code " .. msg.code)
		if msg.code == 0 then
			if useGold then
				GUIMgr:SendDataReport("purchase", "costgold", "" ..itemTBData.id, "1", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
			else
				GUIMgr:SendDataReport("purchase", "useitem", "" ..itemTBData.id, "1")
			end
		
			AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)

			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1] , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
			FloatText.Show(showText , Color.white)
			
			MainCityUI.UpdateRewardData(msg.fresh)
			maincity.UpdateBuildInMsg(msg.build)
			
		end
	end)]]
end

local function UseExpFunc(useItemId , exItemid , count)
	--print("Useuseuse" .. useItemId)
	local build = maincity.GetCurrentBuildingData()
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)
	local exData =TableMgr:GetItemExchangeData(exItemid)
	
	local usegold = 0
	if itemdata == nil or itemdata.number == 0 then
		usegold = exData.price
	end

	
	local buffdata = BuffData.HaveSameBuff(0 , itemTBData.param1)
	if buffdata ~= nil then
		local buffTableData = TableMgr:GetSlgBuffData(buffdata.buffId)
		print("========== buff data :" .. buffdata.uid .. " time :".. buffdata.time .. "build :" .. buffdata.buffMasterId)
		
		local okCallback = function()
			UseExpItem(useItemId ,exItemid ,  usegold)
			CountDown.Instance:Remove("BuffCountDown")
			MessageBox.Clear()
		end
		local cancelCallback = function()
			CountDown.Instance:Remove("BuffCountDown")
			MessageBox.Clear()
		end
		MessageBox.Show(msg, okCallback, cancelCallback)
		local mbox = MessageBox.GetMessageBox()
		if mbox ~= nil then
			CountDown.Instance:Add("BuffCountDown",buffdata.time, function(t)
				mbox.msg.text = System.String.Format(TextMgr:GetText("speedup_ui5") , TextUtil.GetSlgBuffDescription(buffTableData) , t)
				if t == "00:00:00" then
					CountDown.Instance:Remove("BuffCountDown")
				end
			end)
		end
	else
		UseExpItem(useItemId ,exItemid, usegold)
	end
end

function RemoveMenuTarget()
	maincity.ResetCamera()
	menuTarget = nil
	cityCamera = nil
	HideCityMenu()
end

function InitBtnByType(type, isEnabled, btn)
    btn.btn.isEnabled = isEnabled
    local iconid = tostring(type)
    if type == 1 then 
        btn.text.text = TextMgr:GetText("build_ui19") -- "信息" 
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            GUIMgr:CreateMenu("BuildingDetails" , false)
            HideCityMenu()
            BuildingDetails.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end
    if type == 2 then 
        btn.text.text = TextMgr:GetText("build_ui20")--"升级" 
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            GUIMgr:CreateMenu("BuildingUpgrade", false)
            HideCityMenu()
            BuildingUpgrade.OnCloseCB = function()
            	RemoveMenuTarget()
            	BuildingShowInfoUI.Refresh()
            	--RefreshCityMenu()
            end
        end)
    end
    if type == 3 then 
        btn.text.text = TextMgr:GetText("build_ui22")-- "检视" 
        SetClickCallback(btn.btn.gameObject, function (go)
			print(maincity.GetCurrentBuildingData().buildingData.logicType)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            HideCityMenu()
		
			if maincity.GetCurrentBuildingData().buildingData.logicType == 1 then
				BuildReview.OnCloseCB = function()
					RemoveMenuTarget()
				end
				BuildReview.Show()
			elseif maincity.GetCurrentBuildingData().buildingData.logicType == 2 then
				GUIMgr:CreateMenu("WareHouse", false)
				WareHouse.OnCloseCB = function()
					RemoveMenuTarget()
				end
			elseif maincity.GetCurrentBuildingData().buildingData.logicType == 10 then
				local resInfo = {buildId = maincity.GetCurrentBuildingData().buildingData.id, totalYield = 0}
				ResViewDetails.SetResBuildInfo(resInfo)
				GUIMgr:CreateMenu("ResViewDetails", false)
			elseif maincity.GetCurrentBuildingData().buildingData.logicType == 3 then
				ParadeGround.Show()
				ParadeGround.OnCloseCB = function()
					RemoveMenuTarget()
				end
			elseif maincity.GetCurrentBuildingData().buildingData.logicType == 6 then
				GUIMgr:CreateMenu("ResView", false)
				ResView.OnCloseCB = function()
			        MainCityUI.RemoveMenuTarget()
			    end
			end
        end)
    end
	
	if type == 12 then
		 btn.text.text = TextMgr:GetText("wall_ui1")--"守城将军"
		 SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            HideCityMenu()
			WallHero.Show(Common_pb.BattleTeamType_CityDefence)
			WallHero.OnCloseCB = function()
				RemoveMenuTarget()
			end
		end)
	end
	
	if type == 13 then
		btn.text.text = TextMgr:GetText("wall_ui2")--"城防部队"
		SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            HideCityMenu()
			WallInfo.Show()
			WallInfo.OnCloseCB = function()
				RemoveMenuTarget()
			end
		end)
	end
	
    if type == 4 then 
    	iconid = iconid .. string.sub(tostring(maincity.GetCurrentBuildingData().data.type),2)
        btn.text.text = TextMgr:GetText("build_ui23")--"收获"
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            GetBuildResource(-1 , Vector3.zero)
            HideCityMenu()
            RemoveMenuTarget()
        end)
    end
    if type == 5 then 
		-- "治疗" 
		btn.text.text = TextMgr:GetText("build_ui27")
		SetClickCallback(btn.btn.gameObject, function (go)
			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
			HideCityMenu()
			Hospital.SetBuild(maincity.GetCurrentBuildingData())
			GUIMgr:CreateMenu("Hospital", false)
			Hospital.OnCloseCB = function()
				RemoveMenuTarget()
			end
			
			--[[local armyInjured = ArmyListData.GetInjuredData()
			if armyInjured.TreatmentArmyInfo ~= nil and armyInjured.TreatmentArmyInfo.Length > 0 then
				
			else
				GUIMgr:CreateMenu("Hospital", false)
				Hospital.OnCloseCB = function()
					RemoveMenuTarget()
				end
			end]]
			
		end)
    end
    if type == 6 then 
        -- "造兵" 
		btn.text.text = TextMgr:GetText("build_ui26")
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        	FunctionListData.IsFunctionUnlocked(103, function(isactive)
        		if isactive then
        			Barrack.EnterBarrack()
		            HideCityMenu()
		            Barrack.OnCloseCB = function()
		            	RemoveMenuTarget()
		            end
		        else
		        	FloatText.ShowAt(btn.btn.transform.position,TextMgr:GetText(TableMgr:GetFunctionUnlockText(103)), Color.white)
        		end
        	end)
        end)
    end
    if type == 14 then
        -- "制造城防部队" 
		btn.text.text = TextMgr:GetText("build_ui46")
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            Barrack.EnterBarrack()
            HideCityMenu()
            Barrack.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end

    if type == 7 then 
        -- "研究" 
 		btn.text.text = TextMgr:GetText("build_ui25")
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            GUIMgr:CreateMenu("Laboratory",false)
            HideCityMenu()
            Laboratory.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)       
    end
    if type == 8 then 
        -- "点将" 
    end
    if type == 9 then 
    	iconid = iconid .. string.sub(tostring(maincity.GetCurrentBuildingData().data.type),2)
        btn.text.text = TextMgr:GetText("build_ui24") --提速（产量增加）
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            HideCityMenu()
			local build = maincity.GetCurrentBuildingData()
			local buildingData = TableMgr:GetBuildingResourceData(build.buildingData.id , build.data.level)
			if buildingData ~= nil then
				local items = {}
				local str = {}
				str = buildingData.resource_BAccelItem:split(";")
				for i,v in ipairs(str) do
					items[i] = {}
					local itemPar = {}
					itemPar = v:split(":")
					
					items[i].itemid = tonumber(itemPar[1])
					items[i].exid = tonumber(itemPar[2])
				end
				CommonItemBag.SetTittle(TextMgr:GetText("speedup_ui1"))
				CommonItemBag.SetItemList(items, 3)
				CommonItemBag.SetUseFunc(UseExpFunc)
				GUIMgr:CreateMenu("CommonItemBag" , false)
				CommonItemBag.OnCloseCB = function()
                    RemoveMenuTarget()
	            end
			    CommonItemBag.OnOpenCB = function()
				end
				--GUIMgr:CreateMenu("Speedup" , false)
			end
		end)
    end
    if type == 10 then 
        btn.text.text = TextMgr:GetText("build_ui21") --加速（缩短建造时间）
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        	local noitem = Global.BagIsNoItem(maincity.GetItemExchangeList(1))
        	if noitem then
        		FloatText.ShowAt(btn.transform.position, TextMgr:GetText("speedup_ui13"), Color.white)
        		return
        	end
        	CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
        	CommonItemBag.NotUseAutoClose()
        	CommonItemBag.NeedItemMaxValue()
            CommonItemBag.SetItemList(maincity.GetItemExchangeList(1), 1)
			CommonItemBag.SetMsgText("purchase_confirmation2", "b_today")
            local _build = maincity.GetCurrentBuildingData()
            local finish = function(go)
            	local req = BuildMsg_pb.MsgAccelBuildUpdateRequest()
            	req.uid = _build.data.uid
            	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelBuildUpdateRequest, req, BuildMsg_pb.MsgAccelBuildUpdateResponse, function(msg)
            		print("msg.code:" .. msg.code)
            		if msg.code == 0 then
            			AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
						maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
						MoneyListData.UpdateData(msg.fresh.money.money)
						CommonItemBag.SetInitFunc(nil)
						GUIMgr:CloseMenu("CommonItemBag")
						NotifyCancelUpgradeListener()
					else
	                	Global.FloatError(msg.code, Color.white)
            		end
            	end, true)
            end
            local cancelreq = function()
            	local req = BuildMsg_pb.MsgCancelBuildUpdateRequest()
            	req.uid = _build.data.uid
            	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgCancelBuildUpdateRequest, req, BuildMsg_pb.MsgCancelBuildUpdateResponse, function(msg)
            		print("msg.code:" .. msg.code)
            		if msg.code == 0 then
            			AudioMgr:PlayUISfx("SFX_UI_building_levelupcancel", 1, false)
            			maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
						MoneyListData.UpdateData(msg.fresh.money.money)
						CommonItemBag.SetInitFunc(nil)
						GUIMgr:CloseMenu("CommonItemBag")
					else
	                	Global.FloatError(msg.code, Color.white)
            		end
            	end)
            end
            local cancel = function(go)
            	MessageBox.Show(TextMgr:GetText("speedup_ui10"), cancelreq, function() end)
            end
            CommonItemBag.SetInitFunc(function()
            	local _text = String.Format("{0}  LV. {1}", TextMgr:GetText(_build.buildingData.name), _build.data.level + 1)
            	local _time = _build.data.donetime
            	local _totalTime = _build.data.originaltime
            	return _text, _time, _totalTime, finish, cancel, finish, 1, function() UnionHelpData.RequestBuildHelp(_build.data.uid) end, _build.data.createtime, _build.data.uid
            end)
			CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
				UseExItemFuncEx(_build, useItemId, exItemid, count)
			end)
			GUIMgr:CreateMenu("CommonItemBag" , false)
			CommonItemBag.OnCloseCB = function()
                RemoveMenuTarget()
				RefreshCityMenu()
				coroutine.start(function()
					coroutine.wait(0.5)
					maincity.UpdateConstruction()
				end)
	        end
		    CommonItemBag.OnOpenCB = function()
			end
            HideCityMenu()
        end)
    end
    if type == 11 then 
        -- "展示加速信息" 
    end
    if type == 15 then
    	btn.text.text = TextMgr:GetText("build_ui48")
    	SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            GUIMgr:CreateMenu("Marchlist", false)
            HideCityMenu()
            Marchlist.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end
	if type == 16 then
		btn.text.text = TextMgr:GetText("embattle_ui5")
    	SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
			
			BattleMoveData.GetOrReqUserAttackFormaion(function(form)
				local selfFormation = {}
				BattleMoveData.CloneFormation(selfFormation,form)
				Embattle.Show(1,selfFormation,nil,function(new_form)
					--selfFormation = new_form
					--formationSmall:SetLeftFormation(selfFormation)
					--formationSmall:Awake(false)
				end , "ParadeGround")
			end)
		end)
    end
	if type == 17 then
		btn.text.text = TextMgr:GetText("TradeHall_ui4") -- "贸易大厅" 
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            TradeHall.Show()
            HideCityMenu()
            TradeHall.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end
	if type == 18 then
		btn.text.text = TextMgr:GetText("Embassy_ui2") -- "大使馆" 
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            GUIMgr:CreateMenu("Embassy" , false)
            HideCityMenu()
            Embassy.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end
	if type == 19 then
		btn.text.text = TextMgr:GetText("ui_worldmap_28") -- "战争大厅" 
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            --GUIMgr:CreateMenu("Embassy" , false)
            --打开联盟集结菜单
            if UnionInfoData.HasUnion() then
                UnionWar.Show()
                HideCityMenu()
                UnionInfo.OnCloseCB = function()
            	    RemoveMenuTarget()
                end
            else
                MessageBox.Show(TextMgr:GetText("assemble_warning_3"))
            end
        end)
    end
    if type == 20 then
    	btn.text.text = TextMgr:GetText("equip_ui16")--"军备库"
    	SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            Equip.Show()
            HideCityMenu()
            Equip.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end
    if type == 21 then
    	btn.text.text = TextMgr:GetText("equip_ui17")--"装备图鉴/制造"
    	SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            EquipMainNew.Show()
            HideCityMenu()
            EquipMainNew.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end
    if type == 22 then
    	btn.text.text = TextMgr:GetText("ui_barrack_attribute13")--"PVE兵种展示"
    	SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
            Barrack_Soldier.Show()
            HideCityMenu()
            Barrack_Soldier.OnCloseCB = function()
            	RemoveMenuTarget()
            end
        end)
    end

    if type == 23 then
    	btn.text.text = TextMgr:GetText("HeroAppoint_title")--"委任"
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        	FunctionListData.IsFunctionUnlocked(118, function(isactive)
        		if isactive then
        			HideCityMenu()
		            local buildingId = maincity.GetCurrentBuildingData().data.type
		            HeroAppointUI.Show(buildingId)
		            HeroAppointUI.OnCloseCB = function()
		            	RemoveMenuTarget()
		            end
        		else
        			FloatText.ShowAt(btn.btn.transform.position,TextMgr:GetText(TableMgr:GetFunctionUnlockText(118)), Color.white)
        		end
        	end)
        end)
	end
	
	if type == 24 then
		btn.textgold.gameObject:SetActive(true)
		local building = maincity.GetCurrentBuildingData()
		CountDown.Instance:Add("upgradenow",building.data.donetime,CountDown.CountDownCallBack(function(t)
			local gold = Mathf.Ceil(maincity.CaculateGoldForTime(1, math.max(0, building.data.donetime - Serclimax.GameTime.GetSecTime() - maincity.freetime())))
			gold = Mathf.Ceil(gold - 0.5)
			if gold > 0 then
				btn.textgold.text = gold
			else
				btn.textgold.text = TextMgr:GetText("speedup_ui7")
			end
		end))
		btn.text.text = TextMgr:GetText("build_ui9")
		SetClickCallback(btn.btn.gameObject, function(go)
			local beginrequest = function()
				AudioMgr:PlayUISfx("SFX_ui01", 1, false)
				local req = BuildMsg_pb.MsgAccelBuildUpdateRequest()
				req.uid = building.data.uid
				Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelBuildUpdateRequest, req, BuildMsg_pb.MsgAccelBuildUpdateResponse, function(msg)
					if msg.code == 0 then
						CountDown.Instance:Remove("upgradenow")
						AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
						maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
						MainCityUI.UpdateRewardData(msg.fresh)
						MainCityQueue.UpdateQueue()
						HideCityMenu()
						RemoveMenuTarget()
						FloatText.Show(TextMgr:GetText("build_ui39"), Color.green)
					else
						Global.FloatError(msg.code, Color.white)
					end
				end, true)
			end
			local gold = tonumber(btn.textgold.text)
			if gold == nil then
				beginrequest()
				return
			end
			if gold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
				Global.ShowNoEnoughMoney()
				return
			end
			if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
				if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("b_today") then
					MessageBox.SetOkNow()
				else
					MessageBox.SetRemberFunction(function(ishide)
						if ishide then
							UnityEngine.PlayerPrefs.SetInt("b_today",tonumber(os.date("%d")))
							UnityEngine.PlayerPrefs.Save()
						end
					end)
				end
				MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation2"), gold, TextMgr:GetText(building.buildingData.name)), beginrequest, function() end)
			else
				beginrequest()
			end
		end)
	end

	if type == 25 then
		btn.text.text = TextMgr:GetText("jail_13")--"监狱"
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        	JailInfo.Show()
        end)
	end

	if type == 26 then
		btn.text.text = TextMgr:GetText("Climb_ui15")--"演习场"
        SetClickCallback(btn.btn.gameObject, function (go)
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)			
			HideCityMenu()	
			Climb.Show()
			Climb.OnCloseCB = function()
				RemoveMenuTarget()
			end				
        end)
	end	

	if type == 27 then
		btn.text.text = TextMgr:GetText("SoldierEquip_1")--兵种装备强化
		SetClickCallback(btn.btn.gameObject, function (go)
			local unlocklevel = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.SoldierEquipUnlockLevel).value)
			if unlocklevel > maincity.GetBuildingByID(1).data.level then
				FloatText.ShowAt(btn.btn.transform.position, System.String.Format(TextMgr:GetText("SoldierEquip_6"), unlocklevel), Color.white)
				return
			end
        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)			
			HideCityMenu()	
			RemoveMenuTarget()
			Barrack_SoldierEquip.Show(maincity.GetCurrentBuildingData().data.type + 980)
        end)
	end
	if type == 28 then
		btn.text.text = TextMgr:GetText("DefenceNumber_1")--城防值
		SetClickCallback(btn.btn.gameObject, function (go)
		    DefenceNumber.Show()
        end)
	end

	print("=====" , iconid)
    btn.icon.spriteName = "building_menu" .. iconid
    local result
    if type == 100 then
        result = SetBuildLock(11, btn)
        btn.icon.spriteName = "icon_resbuilding1"
        btn.text.text = TextMgr:GetText("Building_11_name")--"建造农田"
        SetClickCallback(btn.btn.gameObject, function (go)
        	if isEnabled then
    			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    		else
    			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
    		end
            if result == nil then
            	BuildBuilding(11, maincity.GetCurrentLandId(), 1, function(msg)
	                if msg.code > 0 then
	                	Global.FloatError(msg.code, Color.white)
	                else
	                	maincity.RefreshBuildingList(msg)
	                end
	            end)
            else
            	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            	FloatText.Show(result, Color.white)
            end
            HideCityMenu()
            RemoveMenuTarget()
        end)
    end
    if type == 101 then
        result = SetBuildLock(12, btn)
        btn.icon.spriteName = "icon_resbuilding2"
        btn.text.text = TextMgr:GetText("Building_12_name")--"建造冶炼厂"
        SetClickCallback(btn.btn.gameObject, function (go)
        	if isEnabled then
    			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    		else
    			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
    		end
            if result == nil then
            	BuildBuilding(12, maincity.GetCurrentLandId(), 1, function(msg)
	                if msg.code > 0 then
	                	Global.FloatError(msg.code, Color.white)
	                else
	                	maincity.RefreshBuildingList(msg)
	                end
	            end)
            else
            	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            	FloatText.Show(result, Color.white)
            end
            HideCityMenu()
            RemoveMenuTarget()
        end)
    end
    if type == 104 then
        result = SetBuildLock(3, btn)
        btn.icon.spriteName = "icon_resbuilding5"
        btn.text.text = TextMgr:GetText("Building_3_name")--"建造医疗所"
        SetClickCallback(btn.btn.gameObject, function (go)
        	if isEnabled then
    			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    		else
    			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
    		end
            if result == nil then
            	BuildBuilding(3, maincity.GetCurrentLandId(), 1, function(msg)
	                if msg.code > 0 then
	                	Global.FloatError(msg.code, Color.white)
	                else
	                	maincity.RefreshBuildingList(msg)
	                end
	            end)
            else
            	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            	FloatText.Show(result, Color.white)
            end
            HideCityMenu()
            RemoveMenuTarget()
        end)
    end
    if type == 105 then
        result = SetBuildLock(5, btn)
        btn.icon.spriteName = "icon_resbuilding6"
        btn.text.text = TextMgr:GetText("Building_5_name")--"建造征召所"
        SetClickCallback(btn.btn.gameObject, function (go)
        	if isEnabled then
    			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    		else
    			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
    		end
            if result == nil then
            	BuildBuilding(5, maincity.GetCurrentLandId(), 1, function(msg)
	                if msg.code > 0 then
	                	Global.FloatError(msg.code, Color.white)
	                else
	                	maincity.RefreshBuildingList(msg)
	                end
	            end)
            else
            	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            	FloatText.Show(result, Color.white)
            end
            HideCityMenu()
            RemoveMenuTarget()
        end)
    end
    if type == 102 then
        result = SetBuildLock(13, btn)
        btn.icon.spriteName = "icon_resbuilding3"
        btn.text.text = TextMgr:GetText("Building_13_name")--"建造炼油厂"
        SetClickCallback(btn.btn.gameObject, function (go)
        	if isEnabled then
    			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    		else
    			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
    		end
            if result == nil then
            	BuildBuilding(13, maincity.GetCurrentLandId(), 1, function(msg)
	                if msg.code > 0 then
	                	Global.FloatError(msg.code, Color.white)
	                else
	                	maincity.RefreshBuildingList(msg)
	                end
	            end)
            else
            	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            	FloatText.Show(result, Color.white)
            end
            HideCityMenu()
            RemoveMenuTarget()
        end)
    end
    if type == 103 then
        result = SetBuildLock(14, btn)
        btn.icon.spriteName = "icon_resbuilding4"
        btn.text.text = TextMgr:GetText("Building_14_name")--"建造发电厂"
        SetClickCallback(btn.btn.gameObject, function (go)
        	if isEnabled then
    			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    		else
    			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
    		end
            if result == nil then
            	BuildBuilding(14, maincity.GetCurrentLandId(), 1, function(msg)
	                if msg.code > 0 then
	                	Global.FloatError(msg.code, Color.white)
	                else
	                	maincity.RefreshBuildingList(msg)
	                end
	            end)
            else
            	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            	FloatText.Show(result, Color.white)
            end
            HideCityMenu()
            RemoveMenuTarget()
        end)
    end
    --[[
    if isEnabled then
    	btn.text.color = btn.btn.defaultColor
    	btn.icon.shader = UnityEngine.Shader.Find("Unlit/Transparent Colored")
    	btn.icon.color = btn.btn.defaultColor
    else
    	btn.text.color = btn.btn.disabledColor
    	btn.icon.shader = UnityEngine.Shader.Find("Unlit/Transparent Colored Gray")
    	btn.icon.color = Color.New(0, 0, 0, 0.7)
    end]]
    if not isEnabled then
    	GameObject.Destroy(btn.go.gameObject)
    end
end

function ShowCityMenu(bcamera, go)
	menuTarget = go
	lastMenuPos = go.transform.position
	cityCamera = bcamera
    local icons = maincity.GetCurrentBuildingIconList()
    local selectBg = function(i)
    	for n = 1, 6 do
    		cityMenu.go.transform:Find(System.String.Format("bg/bg_bottom ({0})", n)).gameObject:SetActive(false)
    	end
    	cityMenu.go.transform:Find(System.String.Format("bg/bg_bottom ({0})", i)).gameObject:SetActive(true)
    end
    if icons ~= nil then
        if #icons == 0 then
            return
        end
        cityMenu.icondata = icons
        local childCount = cityMenu.grid.transform.childCount
        cityMenu.btn = {}
        for i = 1, #icons do
        	local _go
        	if i - 1 < childCount then
		    	_go = cityMenu.grid.transform:GetChild(i - 1).gameObject
		    else
		    	_go = GameObject.Instantiate(cityMenu.item)
		    	_go.transform:SetParent(cityMenu.grid.transform, false)
		    end
        	cityMenu.btn[i] = {}
        	cityMenu.btn[i].go = _go
        	cityMenu.btn[i].btn = _go.transform:Find("frame"):GetComponent("UIButton")
        	cityMenu.btn[i].icon = _go.transform:Find("frame/icon"):GetComponent("UISprite")
        	cityMenu.btn[i].text = _go.transform:Find("frame/text_name"):GetComponent("UILabel")
        	cityMenu.btn[i].textnum = _go.transform:Find("frame/text_num"):GetComponent("UILabel")
        	cityMenu.btn[i].textbg = _go.transform:Find("frame/text_num/bg").gameObject
			cityMenu.btn[i].suo = _go.transform:Find("frame/bg_suo").gameObject
			cityMenu.btn[i].textgold = _go.transform:Find("frame/text_gold"):GetComponent("UILabel")
			cityMenu.btn[i].textgold.gameObject:SetActive(false)
			cityMenu.btn[i].textnum.text = ""
			cityMenu.btn[i].textbg:SetActive(false)
			cityMenu.btn[i].suo:SetActive(false)
            InitBtnByType(tonumber(icons[i].icon), icons[i].enabled, cityMenu.btn[i])
        end
        for i = #icons, childCount - 1 do
	        GameObject.Destroy(cityMenu.grid.transform:GetChild(i).gameObject)
	    end
        coroutine.start(function()
        	coroutine.step()
        	cityMenu.grid:Reposition()
        	selectBg(cityMenu.grid.transform.childCount)
        end)
        SetTargetFlash(menuTarget)
    else
        FloatText.Show("按钮信息错误", Color.white)
    end
	cityMenu.needshow = true
end

function SetTargetFlash(target)
	if targetRenderer ~= nil then
		SetTargetStopFlash{}
	else
		targetRenderer = {}
	end
	if target.transform.childCount == 0 then
		return
	end
	targetRenderer[#targetRenderer + 1] = {}
	targetRenderer[#targetRenderer].coroutine = coroutine.start(function()
		local renderers = target.transform:GetChild(0):GetComponentsInChildren(typeof(UnityEngine.Renderer))
		targetRenderer[#targetRenderer].renderer = {}
		for i = 0, renderers.Length - 1 do
			if string.find(renderers[i].material.shader.name,"Particles/") == nil and string.find(renderers[i].material.shader.name,"Transparent") == nil and string.find(renderers[i].material.shader.name,"OutLine") == nil then
				targetRenderer[#targetRenderer].renderer[#targetRenderer[#targetRenderer].renderer + 1] = {}
				targetRenderer[#targetRenderer].renderer[#targetRenderer[#targetRenderer].renderer].material = renderers[i].material
				targetRenderer[#targetRenderer].renderer[#targetRenderer[#targetRenderer].renderer].originShader = renderers[i].material.shader.name
				targetRenderer[#targetRenderer].renderer[#targetRenderer[#targetRenderer].renderer].material.shader = UnityEngine.Shader.Find("Castle/ColorMix")
			end
		end
    	local minnum = 0
    	local maxnum = 0.2
    	local forward = false
    	local delta = (maxnum - minnum) / 0.7
    	local currnum = maxnum
    	while true do
    		if forward then
    			currnum = currnum + Time.deltaTime * delta
    			if currnum >= maxnum then
    				forward = false
    			end
    		else
    			currnum = currnum - Time.deltaTime * delta
    			if currnum <= minnum then
    				forward = true
    			end
    		end
    		for i, v in pairs(targetRenderer) do
    			for j, k in pairs(v.renderer) do
    				k.material.color = Color.New(currnum, currnum, currnum, 1)
    			end
    		end
    		coroutine.step()
    	end
    end)
	
end

function SetTargetStopFlash()
	if targetRenderer ~= nil then
		for i, v in pairs(targetRenderer) do
			coroutine.stop(v.coroutine)
			if v.renderer ~= nil then
                for j, k in pairs(v.renderer) do
                    k.material.shader = UnityEngine.Shader.Find(k.originShader)
                    k.material.color = Color.white
                end
            end
		end
	end
	targetRenderer = {}
end

function GetCityMenuBtnByType(_type)
	local icons = cityMenu.icondata
	if icons == nil then
		return nil
	end
	for i = 1, #icons do
		if tonumber(icons[i].icon) == tonumber(_type) then
			return cityMenu.btn[i].btn.gameObject
		end
	end
end

function GetBuildingUnlockBtn(buildingname)
	if maincity.GetBuildingList()[buildingname].unlockui == nil then
		return nil
	end
	return maincity.GetBuildingList()[buildingname].unlockui.transform:Find("icon").gameObject
end

function GetBuildingUnlockBtnMatch(buildingName)
	local buildingList = maincity.GetBuildingList()
	for k, v in pairs(buildingList) do
	    if string.match(k, buildingName) then
	        if v.unlockUI ~= nil and not v.unlockUI:Equals(nil) then
                return v.unlock_collider.gameObject
            end
            if v.unlockLandUI ~= nil and not v.unlockLandUI:Equals(nil) then
            	return v.unlockLand_collider.gameObject
            end
        end
    end
end

function CalAttributeBonus()
	local bonus = {}
	local buildingList = maincity.GetBuildingList()

	table.foreach(buildingList ,function(i,v)
		if v.data ~= nil then
			local updateData = TableMgr:GetBuildUpdateData(v.data.type , v.data.level)
			if updateData.updateDetailArmyType ~= "0" then
			   local b = {}
			   local t = string.split(updateData.updateDetailArmyType,';')  
			   for j=1,#(t) do
				   if t[j] ~= nil and tonumber(t[j]) ~= nil then
						local b = {}
						b.BonusType =tonumber(t[j])
						b.Attype =  updateData.updateDetailAttrType
						b.Value =  updateData.updateDetailValue
						table.insert(bonus,b)
					end
			   end

		   end
	   end
	end)
	return bonus
end

function GetBuildingFreeBtn(buildingname)
	if maincity.GetBuildingList()[buildingname].transition == nil then
		return nil
	end
	return maincity.GetBuildingList()[buildingname].transition.free.transform:Find("bg").gameObject
end

function GetBuildingFreeBtnMatch(buildingName)
	local buildingList = maincity.GetBuildingList()
	for k, v in pairs(buildingList) do
	    if string.match(k, buildingName) then
			if v.transition ~= nil then
				if v.transition.free_collider.enabled then
					return v.transition.free_collider.gameObject
				elseif v.transition.help_collider.enabled then
					return v.transition.help_collider.gameObject
				elseif v.transition.sfx_collider.enabled then
					return v.transition.sfx_collider.gameObject
				end
            end
        end
    end
end

function HideCityMenu()
	CountDown.Instance:Remove("upgradenow")
	if cityMenu == nil then 
		return 
	end 
	cityMenu.needshow = false
	maincity.HideTransitionName()
	for i = 0, 1 do
		if cityMenu.bgTween[i] then
			cityMenu.bgTween[i]:PlayReverse(false)
		end
	end
	hasCityMenu = false
    if hasmission and canshowmission and recommendedMissionUI and recommendedMissionUI.bg and not recommendedMissionUI.bg:Equals(nil) then
		recommendedMissionUI.bg.gameObject:SetActive(true)
	end
	SetTargetStopFlash()
end

function RefreshCityMenu()
	HideCityMenu()
	if cityCamera ~= nil and menuTarget ~= nil then
		ShowCityMenu(cityCamera, menuTarget)
	end
end

local function BuyEnergy()
    local oldEnergy = MainData.GetEnergy()
    local req = ClientMsg_pb.MsgCharacterEnergyBuyRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterEnergyBuyRequest, req, ClientMsg_pb.MsgCharacterEnergyBuyResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			-- send data report-----------
			GUIMgr:SendDataReport("purchase", "costgold", "BuyEnergy", "1", "" ..MoneyListData.ComputeDiamond(msg.money.money))
			------------------------------
		
            MoneyListData.UpdateData(msg.money.money)
            CountListData.SetCount(msg.count)
            MainData.SetEnergy(msg.energy , true)
            MainData.SetEnergyTime(msg.energytime)

            local newEnergy = MainData.GetEnergy()
            local floatText = TextMgr:GetText(Text.tili_ui6)
            AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
            FloatText.Show(String.Format(floatText, newEnergy - oldEnergy), Color.green)
        end
    end, true)
end

local function BuySceneEnergy()
    local oldEnergy = MainData.GetSceneEnergy()
    local req = ClientMsg_pb.MsgCharacterSceneEnergyBuyRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterSceneEnergyBuyRequest, req, ClientMsg_pb.MsgCharacterSceneEnergyBuyResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			-- send data report-----------
			GUIMgr:SendDataReport("purchase", "costgold", "BuySceneEnergy", "1", "" ..MoneyListData.ComputeDiamond(msg.money.money))
			------------------------------
		
            MoneyListData.UpdateData(msg.money.money)
            CountListData.SetCount(msg.count)
            MainData.SetSceneEnergy(msg.energy , true)
            MainData.SetSceneEnergyTime(msg.energytime)

            local newEnergy = MainData.GetSceneEnergy()
            local floatText = TextMgr:GetText(Text.tili_ui6)
            AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
            FloatText.Show(String.Format(floatText, newEnergy - oldEnergy), Color.green)
        end
    end, true)
end

ShowBuyEnergy = function(cb)--showNoEnoughEnergy)
    MainCityUI.UseResItem(25, cb)
end

CheckAndBuyEnergy = function(cb)--showNoEnoughEnergy)
	
    local noEnoughEnergyText = TextMgr:GetText(Text.common_ui9)
    local energyCount = CountListData.GetEnergyCount()
    local leftBuyCount = energyCount.count
    local buyCount = 0
    if leftBuyCount < 0 then
        if MainData.IsMaxVipLevel() then
            local text1 = TextMgr:GetText(Text.tili_ui5)
            MessageBox.Show(text1)
        else
            local msgText = Global.GetErrorText(ReturnCode_pb.Code_LimitNumNotEnough) -- String.Format(text1, price, EachBuyEnergyAmount)..String.Format(text2, leftBuyCount)
            local okText = TextMgr:GetText(Text.common_ui10)
            MessageBox.Show(msgText, function() end, function() end, okText)
        end
    else
        buyCount = tonumber(TableMgr:GetGlobalData(100197).value)
        local msgText = '' -- String.Format(text1, price, EachBuyEnergyAmount)..String.Format(text2, leftBuyCount)
		local gold_list = {}

		local staminaprice_table = TableMgr:GetStaminaPriceTable()
		local i =1
		for _ , v in ipairs(staminaprice_table) do
			gold_list[i] = tonumber(v.price)
			i = i+1
		end
		
		local time = (energyCount.countmax - energyCount.count)+1
		local gold = time > #gold_list and gold_list[#gold_list] or gold_list[time]
		
		local text1 = System.String.Format(TextMgr:GetText("ui_purchasestamina"),buyCount)
        local text2 = String.Format(TextMgr:GetText(Text.tili_ui4),leftBuyCount )
		local text3 = TextMgr:GetText("ui_staminarecover")
		local nextTime = MainData.GetEnergy() >= MainData.GetMaxEnergy() and 0 or MainData.GetNextEnergyTime()
        MessageBox.Show(text1, function()

            local coin = MoneyListData.GetDiamond()
            if coin >= gold then
                BuyEnergy()
            else
                local msgText = TextMgr:GetText(Text.common_ui8)
                local okText = TextMgr:GetText(Text.common_ui10)
                MessageBox.Show(msgText, function() store.Show() end, function() end, okText)
            end
        end, function() end,nil,nil,nil,nil,nil,text2,gold,nextTime,text3)
    end

end

function CheckAndBuySceneEnergy(cb)--showNoEnoughEnergy)

    local noEnoughEnergyText = TextMgr:GetText(Text.common_ui9)
    local energyCount = CountListData.GetSceneEnergyCount()
    local leftBuyCount = energyCount.count
    local buyCount = 0
    if leftBuyCount < 0 then
        if MainData.IsMaxVipLevel() then
            local text1 = TextMgr:GetText(Text.ui_movepoint_1)
            MessageBox.Show(text1)
        else
            local msgText = Global.GetErrorText(ReturnCode_pb.Code_LimitNumNotEnough) -- String.Format(text1, price, EachBuyEnergyAmount)..String.Format(text2, leftBuyCount)
            local okText = TextMgr:GetText(Text.common_ui10)
            MessageBox.Show(msgText, function() end, function() end, okText)
        end
    else
        buyCount = tonumber(TableMgr:GetGlobalData(100199).value)
        local msgText = '' -- String.Format(text1, price, EachBuyEnergyAmount)..String.Format(text2, leftBuyCount)
		local gold_list = {}

		local staminaprice_table = TableMgr:GetStaminaPriceTable()
		local i =1
		for _ , v in ipairs(staminaprice_table) do
			gold_list[i] = tonumber(v.price)
			i = i+1
		end
		
		local time = (energyCount.countmax - energyCount.count)+1
		local gold = time > #gold_list and gold_list[#gold_list] or gold_list[time]

		local text1 = System.String.Format(TextMgr:GetText("ui_purchasemovepoint"),buyCount)
        local text2 = String.Format(TextMgr:GetText(Text.tili_ui4),leftBuyCount )
		local text3 = TextMgr:GetText("ui_movepoints1")
		local nextTime = MainData.GetSceneEnergy() >= MainData.GetMaxSceneEnergy() and 0 or MainData.GetNextSceneEnergyTime()
        MessageBox.Show(text1, function()

            local coin = MoneyListData.GetDiamond()
            if coin >= gold then
                BuySceneEnergy()
            else
                local msgText = TextMgr:GetText(Text.common_ui8)
                local okText = TextMgr:GetText(Text.common_ui10)
                MessageBox.Show(msgText, function() store.Show() end, function() end, okText)
            end
        end, function() end,nil,nil,nil,nil,nil,text2,gold,nextTime,text3)
    end

end


function UpdateItem(msg)
	local freshItems = msg.fresh.item.items
	for _, v in ipairs(freshItems) do
		if v ~= nil then
			local item = nil
			item = ItemListData.GetItemDataByUid(v.data.uniqueid)
			if item ~= nil then
				if v.optype == 3 then
					item.number = 0
				else
					item.number = v.data.number
				end
				SlgBag.UpdateBagItem(v.data.uniqueid)
			end
		end
	end
end

function CloseOpenMainMenu()
    if openedMainMenu ~= nil then
        openedMainMenu.CloseAll()
    end
end

function ShowCards(isLogin, closecallback)
	local cards = {}
	local cardCount = 0
	local cardNames = {}
	cardNames[1] = TextMgr:GetText("pay_ui6")
	cardNames[2] = TextMgr:GetText("pay_ui5")
	local cardDays = {}
	cardDays[1] = "7"
	cardDays[2] = "30"
	local GetReward = function(msg)
		if msg.code == 0 then
			UpdateRewardData(msg.fresh)
			Global.ShowReward(msg.reward)
			ShowCards()
		else
			Global.ShowError(msg.code)
		end
	end
	local callback = function(msg)
		cardCount = cardCount + 1
		cards[cardCount] = msg
		if cardCount == 2 then
			if isLogin then
				if not (cards[1].cantake or cards[2].cantake) then
					if closecallback ~= nil then
						closecallback()
					end
					return
				end
			end
			MonthCardData.SetTakenSeven(cards[1].cantake)
			MonthCardData.SetTakenMonth(cards[2].cantake)
			local cardPage
			if cardPage == nil then
				cardPage = {}
			end
			cardPage.go = GUIMgr.UIRoot.transform:Find("MonthCard")
			if cardPage.go == nil then
				cardPage.go = ResourceLibrary.GetUIInstance("Pay/MonthCard_reward").transform
				cardPage.go.name = "MonthCard"
			end
			cardPage.go.transform:SetParent(GUIMgr.UIRoot.transform, false)
			cardPage.container = cardPage.go.transform:Find("Container") 
			cardPage.btn_close = cardPage.go.transform:Find("Container/bg_frame/bg_top/btn_close")
			SetClickCallback(cardPage.container.gameObject, function() 
				GameObject.Destroy(cardPage.go.gameObject)
				UpdateActivityNotice()
				if closecallback ~= nil then
					closecallback()
				end
			end) 
			SetClickCallback(cardPage.btn_close.gameObject, function() 
				GameObject.Destroy(cardPage.go.gameObject) 
				UpdateActivityNotice()
				if closecallback ~= nil then
					closecallback()
				end
			end) 
			cardPage.grid = cardPage.go.transform:Find("Container/bg_frame/bg_mid/Grid"):GetComponent("UIGrid")
			cardPage.item = cardPage.go.transform:Find("Rewardinfo")
			for i, v in ipairs(cards) do
				if v.code == 0 then
					local _item
					if i - 1 < cardPage.grid.transform.childCount then
						_item = cardPage.grid.transform:GetChild(i - 1).gameObject
					else
						_item = GameObject.Instantiate(cardPage.item)
					end
					_item.transform:SetParent(cardPage.grid.transform, false)
					_item.transform:Find("text_name"):GetComponent("UILabel").text = cardNames[i]
					local hintinfo = _item.transform:Find("text"):GetComponent("UILabel")
					local hint = _item.transform:Find("hint"):GetComponent("UILabel")
					local btn = _item.transform:Find("btn_get"):GetComponent("UIButton")
					btn.disabledColor = Color.white
					btn.disabledSprite = "btn_4"
					local btn_text = btn.transform:Find("text"):GetComponent("UILabel")
					_item.transform:Find("bg_mid/num"):GetComponent("UILabel").text = v.item.item.item[1].num
					_item.transform:Find("bg_mid/icon"):GetComponent("UISprite").spriteName = v.icon
					if v.buyed then
						if v.cantake then
							hintinfo.text = TextMgr:GetText("pay_ui9")
							btn.isEnabled = true
						else
							hintinfo.text = TextMgr:GetText("pay_ui7")
							btn.isEnabled = false
						end
						hint.text = "" .. v.day .. "/" .. cardDays[i]
						btn_text.text = TextMgr:GetText("mail_ui12")
						if i == 1 then
							SetClickCallback(btn.gameObject, function()
								local req = ShopMsg_pb.MsgIAPTakeWeekCardRequest()
								LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeWeekCardRequest, req:SerializeToString(), function (typeId, data)
								    local msg = ShopMsg_pb.MsgIAPTakeWeekCardResponse()
								    msg:ParseFromString(data)  
								    GetReward(msg)
								    if tonumber(v.day) == tonumber(cardDays[i]) then
								    	MessageBox.Show(TextMgr:GetText("pay_ui11"), function() GameObject.Destroy(cardPage.go.gameObject) store.BuyCard(1) end, function() end, TextMgr:GetText("mission_go"))
								    end
								end, false) 
							end)
						else
							SetClickCallback(btn.gameObject, function()
								local req = ShopMsg_pb.MsgIAPTakeMonthCardRequest()
								LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeMonthCardRequest, req:SerializeToString(), function (typeId, data)
								    local msg = ShopMsg_pb.MsgIAPTakeMonthCardResponse()
								    msg:ParseFromString(data)
								    GetReward(msg)
								    if tonumber(v.day) == tonumber(cardDays[i]) then
								    	MessageBox.Show(TextMgr:GetText("pay_ui12"), function() GameObject.Destroy(cardPage.go.gameObject) store.BuyCard(2) end, function() end, TextMgr:GetText("mission_go"))
								    end
								end, true)  
							end)
						end
					else
						hintinfo.text = TextMgr:GetText("pay_ui8")
						hint.text = ""
						btn_text.text = TextMgr:GetText("shop_buy_text")
						SetClickCallback(btn.gameObject, function()
							GameObject.Destroy(cardPage.go.gameObject)
							store.Show(5,1)
						end)
					end
				end
			end		
			NGUITools.AdjustDepth(cardPage.go.gameObject, 1000)	
		end
	end
	local RequestCard = function(type, callback)
		local req = ShopMsg_pb.MsgIAPTakeCardInfoRequest()
		req.id = type
		LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeCardInfoRequest, req:SerializeToString(), function (typeId, data)
		    local msg = ShopMsg_pb.MsgIAPTakeCardInfoResponse()
		    msg:ParseFromString(data)  
		    if callback ~= nil then
		    	callback(msg)
		    end
		end, false)    
	end
	RequestCard(3, callback)
	RequestCard(4, callback)
end

local function UseMarchingItemFunc(useItemId , exItemid , count)
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
	req.subTimeType = 5
	req.pathid = pathid
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			useItemReward = msg.reward
			MainCityUI.UpdateRewardData(msg.fresh)
			CommonItemBag.UpdateItem()
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white  , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
		else
            Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

local function MobaUseMarchingItemFunc(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = MobaPackageItemData.GetItemDataByUid(useItemId)

	local req = MobaMsg_pb.MsgMobaUseItemSubTimeRequest()
	req.pathId = pathid
	req.num = count
	
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
		---req.useGold = 1
	else
		local itemData = MobaItemData.GetItemDataByBaseId(useItemId)
		if  itemData~= nil then 
			req.exchangeId = itemData.exchangeId
		end 
		
		if MobaMainData.GetData().data.mobaScore >= itemData.needScore*count then 
			req.useGold = 0
		else 
			local tip = System.String.Format(TextMgr:GetText(Text.ui_moba_45), itemData.needGold*count)
			req.useGold = 1
			MessageBox.Show(tip, function() 
				Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaUseItemSubTimeRequest, req, MobaMsg_pb.MsgMobaUseItemSubTimeResponse, function(msg)
					print("use item code:" .. msg.code)
					if msg.code == 0 then
						local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
						if price == 0 then
							GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
						else
							GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
						end
						AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
						useItemReward = msg.reward
						MainCityUI.UpdateRewardData(msg.fresh)
						CommonItemBag.UpdateItem()
						MobaMainData.RequestData()
						local nameColor = Global.GetLabelColorNew(itemTBData.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
						FloatText.Show(showText , Color.white  , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
					else
						Global.FloatError(msg.code, Color.white)
					end
				end, true)
			
			end, function() end)
			return 
		end
    end
	
	-- req.subTimeType = 5
	
	print("Useidrrr : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaUseItemSubTimeRequest, req, MobaMsg_pb.MsgMobaUseItemSubTimeResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			useItemReward = msg.reward
			MainCityUI.UpdateRewardData(msg.fresh)
			CommonItemBag.UpdateItem()
			MobaMainData.RequestData()
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white  , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
		else
            Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

local function GuildMobaUseMarchingItemFunc(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	
	local itemdata = TableMgr:GetGuildWarShopDataByID(useItemId)
	
	local req = GuildMobaMsg_pb.GuildMobaUseItemSubTimeRequest()
	req.pathId = pathid
	req.num = count
	-- req.uid = useItemId
	--req.exchangeId = exItemid
	if itemdata ~= nil then
		-- req.uid = itemdata.id
		---req.useGold = 1
		req.exchangeId = itemdata.id
	else
		local itemData = MobaItemData.GetItemDataByBaseId(useItemId)
		if  itemData~= nil then 
			req.exchangeId = itemData.exchangeId
		end 
    end
	
	-- req.subTimeType = 5
	print("Useidrrr : " .. req.uid .. "exid : " .. req.exchangeId .. "count :" .. count)
	Global.Request(Category_pb.GuildMoba,GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaUseItemSubTimeRequest, req, GuildMobaMsg_pb.GuildMobaUseItemSubTimeResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			useItemReward = msg.reward
			MainCityUI.UpdateRewardData(msg.fresh)
			CommonItemBag.UpdateItem()
			MobaMainData.RequestData()
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white  , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
		else
            Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

function ShowMarchingAcceleration(_pathid, timeInfoText)
	local isMoba = false
	
	if GUIMgr:IsMenuOpen("MobaMain") or GUIMgr:IsMenuOpen("GuildWarMain") then
		isMoba = true
	end 
	print("ShowMarchingAcceleration ",isMoba,_pathid)
	if isMoba then 
		
	else 
		local noitem = Global.BagIsNoItem(maincity.GetItemExchangeListNoCommon(9))
		if noitem then
			FloatText.ShowAt(btn.transform.position, TextMgr:GetText("speedup_ui13"), Color.white)
			return
		end
	end 
    pathid = _pathid
    CommonItemBag.SetTittle(TextMgr:GetText("build_ui3"))
    CommonItemBag.NotUseAutoClose()
    CommonItemBag.NeedItemMaxValue()
	
	if isMoba then 
		local items = {}
		
		if Global.GetMobaMode() == 1 then
			items[1] = {}
			items[1].itemid = 31203
			items[1].exid = 1
			items[2] = {}
			items[2].itemid = 31204
			items[2].exid = 1
		elseif Global.GetMobaMode() == 2 then
			items[1] = {}
			items[1].itemid = 31205
			items[1].exid = 1
			items[2] = {}
			items[2].itemid = 31206
			items[2].exid = 1
		end 
		CommonItemBag.SetItemList(items,2)
	else
		CommonItemBag.SetItemList(maincity.GetItemExchangeListNoCommon(9), 2)
	end 
    local _build = maincity.GetCurrentBuildingData()
    CommonItemBag.SetInitFunc(function()
    	local pathdata = nil 
		if isMoba then 
			pathdata =MobaActionListData.GetActionData(_pathid)
			if pathdata == nil then 
				pathdata = MobaActionListData.GetActionDataByAttachPath(_pathid)
			end 
			if pathdata~= nil and tonumber(pathdata.status) == 104 then 
				pathid = pathdata.attachPathId
				if pathdata.status == Common_pb.PathEntryStatus_Gather or pathdata.status == Common_pb.PathMoveStatus_GoWait then
					showTime = true
					local state,startTime,endTime = MassTroops.UpdateTimeMsg(nil, pathdata.gather)
					startTime = math.max(startTime, 0)
					endTime = math.max(endTime, 0)
					pathdata.starttime = startTime
					pathdata.time = endTime - startTime 
				end 
			end
			
		else
			pathdata =ActionListData.GetActionData(pathid)
			
		end 
    	if pathdata == nil then
			return
    	end

    	return timeInfoText, pathdata.starttime + pathdata.time, pathdata.time, nil, nil, nil, nil
    end)
	if Global.GetMobaMode() == 1 then
		CommonItemBag.SetUseFunc(MobaUseMarchingItemFunc)
	elseif Global.GetMobaMode() == 2 then
		CommonItemBag.SetUseFunc(GuildMobaUseMarchingItemFunc)
	else
		CommonItemBag.SetUseFunc(UseMarchingItemFunc)
	end 

	GUIMgr:CreateMenu("CommonItemBag" , false)
	CommonItemBag.OnCloseCB = function()
        RemoveMenuTarget()
	end
	CommonItemBag.OnOpenCB = function()
	end
end


local function UseSceneEnergyFunc(useItemId , exItemid , count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	local req = ItemMsg_pb.MsgUseItemRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
	end
	req.num = count
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end			
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			useItemReward = msg.reward
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1] )
			FloatText.Show(showText , Color.white, ResourceLibrary:GetIcon("Item/", itemTBData.icon))
			
			--maincity.GetBuildingListData()
			MainCityUI.UpdateRewardData(msg.fresh)
			MainCityQueue.UpdateQueue()
		else
            Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

function ShowUseOrBuySceneEnergy(_donothide)
	CommonItemBag.SetTittle(TextMgr:GetText("ui_rebelenergy_2"))
	CommonItemBag.NotUseAutoClose()
    CommonItemBag.NeedItemMaxValue(false)
    CommonItemBag.SetResType(Common_pb.MoneyType_None)
    CommonItemBag.SetItemList(maincity.GetItemExchangeListNoCommon(11), 6)
    CommonItemBag.SetUseFunc(UseSceneEnergyFunc)
	GUIMgr:CreateMenu("CommonItemBag" , false)
	local donothide = _donothide
	CommonItemBag.OnCloseCB = function()
		print(donothide)
		if donothide == nil or donothide ~= true then
        end
        RemoveMenuTarget()
	end
	CommonItemBag.OnOpenCB = function()
	end
end

function CheckSelfShield(callback)
	if BuffData.HasShield() then
		MessageBox.Show(TextMgr:GetText("shield_warning_1"),function()
        	callback(true)
        end, function() end)
	else
		callback(false)
	end
end

function CheckShield(pathType, callback)
	if pathType == Common_pb.TeamMoveType_ResTake or pathType == Common_pb.TeamMoveType_GatherCall or pathType == Common_pb.TeamMoveType_Camp or pathType == Common_pb.TeamMoveType_Occupy or pathType == Common_pb.TeamMoveType_AttackPlayer or pathType == Common_pb.TeamMoveType_ReconPlayer then
		local tile = TileInfo.GetTileMsg()
		local mapX, mapY = TileInfo.GetPos()
		WorldMapData.RequestSceneEntryInfoFresh(tile ~= nil and tile.data.uid or 0, mapX, mapY,function(tileMsg)
			if tileMsg == nil then
				callback(false)
				return
			end
			if tileMsg.data.entryType == Common_pb.SceneEntryType_Home or tileMsg.data.entryType == Common_pb.SceneEntryType_Barrack or tileMsg.data.entryType == Common_pb.SceneEntryType_Occupy then
				if tileMsg.home.hasShield then
					MessageBox.Show(TextMgr:GetText("shield_warning_2"))
					return
				end
				CheckSelfShield(callback)
			elseif tileMsg.data.entryType >= Common_pb.SceneEntryType_ResFood and tileMsg.data.entryType <= Common_pb.SceneEntryType_ResElec then
				if tileMsg.res.owner ~= 0 then
					CheckSelfShield(callback)
				else
					callback(false)
				end
			else
				callback(false)
			end
		end)
	elseif pathType == Common_pb.TeamMoveType_Garrison or pathType == Common_pb.TeamMoveType_GatherRespond then
		CheckSelfShield(callback)
	else
		callback(false)
	end
end

function OnMainCityQueueSimple(isSimple)
	if _ui == nil then
		return
	end
	if _ui.rebelsurround ~= nil and _ui.rebelsurround.gameObject.activeSelf then
		--_ui.rebelsurroundEffect1.gameObject:SetActive(active)
		----_ui.rebelsurroundEffect2.gameObject:SetActive(active)
		if isSimple then
			_ui.rebelsurroundEffect = -1
			--UpdateRebelSurroundEffect()
			CheckRebelSurroundBtn()
		else
			_ui.rebelsurroundEffect1.gameObject:SetActive(false)
			_ui.rebelsurroundEffect2.gameObject:SetActive(false)
		end
	end
	
	if _ui.firstpurchase ~= nil then
		if isSimple then
			_ui.firstpurchase:SetActive(MainData.HadRecharged() or MainData.CanTakeRecharged() or MainData.GetRecommendGoodInfo().id > 0)
			local ln = TextMgr:GetText("Mail_FirstRecharge_Reward_Title")
			local qianbao = 1
			if MainData.HadRecharged() or MainData.CanTakeRecharged() then
			elseif MainData.GetRecommendGoodInfo().id > 0 then
				if MainData.GetRecommendGoodInfo().id == 616 or MainData.GetRecommendGoodInfo().id == 617 then
					qianbao = 2
				elseif MainData.GetRecommendGoodInfo().id == 618 or MainData.GetRecommendGoodInfo().id == 619 or MainData.GetRecommendGoodInfo().id == 620 then
					qianbao = 3
				end
				ln = TextMgr:GetText(MainData.GetRecommendGoodInfo().name)
			else
				_ui.firstpurchase:SetActive(false)
			end
			_ui.firstpurchaseqianbao1:SetActive(qianbao == 1)
			_ui.firstpurchaseqianbao2:SetActive(qianbao == 2)
			_ui.firstpurchaseqianbao3:SetActive(qianbao == 3)
			_ui.firstpurchaseLabel.text = ln
		else
			_ui.firstpurchase.gameObject:SetActive(false)
		end
	end
end

function BagNotice()
	if ui == nil then
		return
	end
	local ItemList = ItemListData.GetBagRedData()
	local count = 0
	for i, v in pairs(ItemList) do
		count = count + 1
		break
	end
	if count > 0 then
		ui.bagRed.gameObject:SetActive(true)
	else
		ui.bagRed.gameObject:SetActive(false)
	end
end

function ItemUse(go, isPressed)
	if not isPressed then
		local params = go.gameObject.name:split("_")
		useItemUid = tonumber(params[2])
		--MsgUseItemRequest
		--MsgUseItemResponse
		--print("use item req : " .. useItemUid)
		local itemData = ItemListData.GetItemDataByUid(useItemUid)
		if itemData == nil then 
			return 
		end 
		local itemTBData = TableMgr:GetItemData(itemData.baseid)
		if itemTBData.itemuse ~= nil and itemTBData.itemuse ~= "" then
			local funstr = System.String.Format("{0}.Use()" , "Item_" .. itemData.baseid--[[itemTBData.itemuse]])
			print("funstr:" .. funstr)
			Global.GetTableFunction(funstr)()
			return
		end
		SlgBag.ItemUseCount(useItemUid , 1)
	end
end


function CheckRecommendedUpGrdade()
	
	if _ui == nil then
		return
	end
	
	SetPressCallback(_ui.growgiftpack, ItemUse)

	local gifts = TableMgr:GetItemDataByType(3 , 4)
	for i , v in pairs(gifts) do
		if tonumber(gifts[i].param3) <= maincity.GetBuildingByID(1).data.level then
			local itemData =  ItemListData.GetItemDataByBaseId(gifts[i].id) 
			local data = TableMgr:GetItemData(gifts[i].id)
			if itemData ~= nil then 
			--if ItemListData.GetItemCountByBaseId(gifts[i].id) > 0 then
				_ui.growgiftpack:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", data.icon)
				 _ui.growgiftpack:SetActive(true)
				 _ui.growgiftpack.name = "growgiftpack" .. "_" .. itemData.uniqueid
				 return
			end 
		end
	end
	_ui.growgiftpack:SetActive(false) 
end 
