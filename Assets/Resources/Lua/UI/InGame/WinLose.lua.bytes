module("WinLose", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local NGUITools = NGUITools
local AudioMgr = Global.GAudioMgr
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local gamestateBattle

local showing

local starCount
local star
local winStar

local battleResult
local battleId = 0
local DontRefrushData = false
local PlayBackInfo;
local display_playback = false

local itemTipTarget
local rewardList
local showFinish
local _ui

local showGuide = false 

local playhero
local HeroAddLevelCo = {}

function CanShowGuide()
	return showGuide
end

function SetBattleId(id)
	battleId = id
end

function ForceDontRefrushData()
	DontRefrushData = true;
end

function SetPlayBackInfo(msg,result,callback,show_playback)
	PlayBackInfo = {}
	PlayBackInfo.msg = msg
	PlayBackInfo.callback = callback
	PlayBackInfo.result = result
	display_playback = show_playback
end
local isRandomPVE = false
local isGuildMonsterBattle = false
local isPveMonsterBattle = false

function OpenRandomPVE()
    isRandomPVE = true
end

function OpenGuildMonsterPVE()
	isGuildMonsterBattle = true
end

function OpenPveMonsterPVE()
	isPveMonsterBattle = true
end

function SetBattleRewards(rewards)
	battleResult = rewards
end

function Hide()
	Global.CloseUI(_M)
end

local function UpdateBattleData()
	if DontRefrushData then
		return
	end
    MainCityUI.UpdateRewardData(battleResult.fresh)
	--ChapterListData.UpdateChapterData(battleResult.chapter)
end

local function ClickPVP4PVE_Back()

end

local function ClickPVP4PVE_FailBack()
	Global.ResetCurrentP4PVEMsg()
	if GUIMgr:IsMenuOpen("MainCityUI") then
		Hide()
	else
		coroutine.start(function()
			GUIMgr:CloseAllMenu()
			coroutine.step()
			local mainState = GameStateMain.Instance
			Main.Instance:ChangeGameState(mainState, "",nil)		
		end)	
	end

	--[[
	Global.QuitSLGPVP(function()
		BattlefieldReport.ExeExitCallBack()
	end)]]
end

local function ClickPVP4PVE_Next()
	Global.ResetCurrentP4PVE()
	if GUIMgr:IsMenuOpen("MainCityUI") then
		Hide()
		if GUIMgr:IsMenuOpen("ChapterPVPInfo") then
			ChapterPVPInfo.Hide()
		end
		if GUIMgr:IsMenuOpen("ChapterSelectUI") then
			ChapterSelectUI.LoadChapter()
		end
	else
		coroutine.start(function()
			GUIMgr:CloseAllMenu()
			coroutine.step()
			local mainState = GameStateMain.Instance
			Main.Instance:ChangeGameState(mainState, "",nil)
		end)
	end
	

	--[[
	Global.QuitSLGPVP(function()
		BattlefieldReport.ExeExitCallBack()
	end)]]
end

local function ClickPVP4PVE_Report()
	local curP4pve = Global.GetCurrentP4PVEMsg()
	if curP4pve ~= nil then
		BattlefieldReport.SetBattleResult(curP4pve.result.battleResult , function()
			BattlefieldReport.Hide()
		end , nil , true)
	end
	if not BattlefieldReport.Show() then
		if GUIMgr:IsMenuOpen("MainCityUI") then
			Hide()
		else
			coroutine.start(function()
				GUIMgr:CloseAllMenu()
				coroutine.step()
				local mainState = GameStateMain.Instance
				Main.Instance:ChangeGameState(mainState, "",nil)		
			end)
		end	
		--[[Global.QuitSLGPVP(function()
			BattlefieldReport.ExeExitCallBack()
		end)]]
	end
end

local function ClickPVP4PVE_PlayBack()
	if PlayBackInfo == nil then
		return
	end
	Global.SetCurrentP4PVEMsg(PlayBackInfo.result.chapterlevel , PlayBackInfo.result)
	Global.CheckBattleReportEx(PlayBackInfo.msg ,Mail.MailReportType.MailReport_player,PlayBackInfo.callback)	
	Hide()
	ForceDontRefrushData()
end

--再玩一次按钮
local function RestartPressCallback(go, isPressed)
	if not isPressed then
		gamestateBattle:Restart()
	end
end
--本局数据按钮
local function BattleDataPressCallback(go, isPressed)
	if not isPressed then
	end
end
--退出战斗按钮
local function QuitPressCallback(go, isPressed)
	if not isPressed then
		coroutine.start(function()
			GUIMgr:CloseAllMenu()
			coroutine.step()
			local mainState = GameStateMain.Instance
			Main.Instance:ChangeGameState(mainState, "",nil)
		end)
	end
end

local function QuitFailGenCallback(go, isPressed)
	if not isPressed then
		coroutine.start(function()
			GUIMgr:CloseAllMenu()
			coroutine.step()	
			local mainState = GameStateMain.Instance
			Main.Instance:ChangeGameState(mainState, "",function()
				MainCityUI.SetJumpMenu("MilitarySchool")
			end)			
		end)
	end
end

local function QuitFailDevCallback(go, isPressed)
	if not isPressed then
		coroutine.start(function()
			GUIMgr:CloseAllMenu()
			coroutine.step()
			local mainState = GameStateMain.Instance
			Main.Instance:ChangeGameState(mainState, "",function()
				MainCityUI.SetJumpMenu("HeroList")
			end)
		end)
	end
end

local function QuitFailScienceCallback(go, isPressed)
	if not isPressed then
		coroutine.start(function()
			GUIMgr:CloseAllMenu()
			coroutine.step()
			local mainState = GameStateMain.Instance
			Main.Instance:ChangeGameState(mainState, "",function() 
				MainCityUI.SetJumpMenu("Laboratory")
			end)			
		end)
	end
end

local function OnUICameraPress(go, pressed)
	if not showFinish then
		return
	end

	if not pressed then
		return
	end
	for _,v in pairs(rewardList.data) do
		if go == v.btnGo then
			local rewardName , rewardDescription
			if v.dtype == 0 then
				rewardName = TextUtil.GetItemName(v.tbData)
				rewardDescription = TextUtil.GetItemDescription(v.tbData)
			elseif v.dtype == 1 then
				rewardName = TextUtil.GetItemName(v.tbData)
				rewardDescription = TextUtil.GetItemDescription(v.tbData)
			elseif v.dtype == 2 then
				rewardName = TextMgr:GetText(v.tbData.SoldierName)
				rewardDescription = TextMgr:GetText(v.tbData.SoldierDes)
			end
		
			if not Tooltip.IsItemTipActive() then
				itemTipTarget = go
				Tooltip.ShowItemTip({name = rewardName, text = rewardDescription})
			else
				 if itemTipTarget == go then
					Tooltip.HideItemTip()
				else
					itemTipTarget = go
					Tooltip.ShowItemTip({name = rewardName, text = rewardDescription})
				end
			end
			return
		end
	end
	Tooltip.HideItemTip()
end

local function ProcessPVP4PVE(battleData)
	local curP4pve = Global.GetCurrentP4PVEMsg()
	if curP4pve ~= nil and curP4pve.id == battleId then
		local resultMsg = curP4pve.result.battleResult
		local win = resultMsg.winteam == 1
		print("winnnnnnnnnnnnn",resultMsg.winteam)
		_ui.GameWin.gameObject:SetActive(win)
		_ui.GameLose.gameObject:SetActive(not win)
		
		if win then
			_ui.GameWin:Find("bg").gameObject:SetActive(false)
			_ui.GameWin:Find("bg_pvp").gameObject:SetActive(true)
			if not DontRefrushData then
				GuideMgr:SaveGuideProcess()
				ChapterListData.UpdateChapterData(curP4pve.result.data.chapter)
			end

			--MainCityUI.UpdateRewardData(curP4pve.result.data.fresh)
			local showResultCorount = coroutine.start(function()
				coroutine.wait(2)
				ShowAccount(true)
			end)
		else
			_ui.GameLose:Find("bg/logo_fail_pvp").gameObject:SetActive(true)
			_ui.GameLose:Find("bg/logo_fail").gameObject:SetActive(false)
			_ui.GameLose:Find("bg/bg_mid").gameObject:SetActive(false)
			_ui.GameLose:Find("bg/bg_mid_pvp").gameObject:SetActive(true)
			local btn_backfail = _ui.GameLose:Find("bg/btn_back")
			local btn_nextfail = _ui.GameLose:Find("bg/btn_next")
			local btn_reportfail = _ui.GameLose:Find("bg/btn_report")
			local btn_playback = _ui.GameLose:Find("bg/btn_playback")
			SetClickCallback(btn_nextfail.gameObject , ClickPVP4PVE_Next)
			SetClickCallback(btn_backfail.gameObject , ClickPVP4PVE_FailBack)
			btn_reportfail.gameObject:SetActive(not display_playback)
			SetClickCallback(btn_reportfail.gameObject , ClickPVP4PVE_Report)
			btn_playback.gameObject:SetActive(display_playback)
			SetClickCallback(btn_playback.gameObject , ClickPVP4PVE_PlayBack)
		end
		
		
	end
end

function Start()
	
	itemTipTarget = nil
	rewardList = {}
	showGuide = false
	--print("============================================")
	print("battleId  ",battleId)
	if battleId > 0 then
		local battleData = TableMgr:GetBattleData(battleId)
		print("battleId  ",battleId,battleData.Type)
		if battleData.Type == 2 then
			ProcessPVP4PVE(battleData)
			AudioMgr:PlayMusic("MUSIC_victroy" , 0.2 , false , 1)
			return
		end
	end
	
	InGameUI.Hide()
	local bg_name
	if SceneManager.instance.GameWin then
		_ui.GameWin.gameObject:SetActive(true)
		_ui.GameLose.gameObject:SetActive(false)
		bg_name = _ui.GameWin.gameObject.name
		GuideMgr:SaveGuideProcess()
		
		for i = 1, starCount do
			winStar = transform:Find(string.format("bg_win/bg/logo_win/star (%d)" , i))
			winStar.gameObject:SetActive(true)
			winStar:GetComponent("UITweener"):SetOnFinished(EventDelegate.Callback(function()
				transform:Find(string.format("bg_win/bg/logo_win/Starlizi (%d)" , i)).gameObject:SetActive(true)
				AudioMgr:PlayUISfx("SFX_UI_star01", 5, false)
			end))
		end
		
		if isPveMonsterBattle then
			transform:Find("bg_win/bg/bg").gameObject:SetActive(false)	
		else
			for i, v in ipairs(star) do
				if v then
					transform:Find(string.format("bg_win/bg/bg/bg_star (%d)/icon_star/icon_star" , i)).gameObject:SetActive(true)	
				end
			end
		end
		
		_ui.btnRetreat = transform:Find(string.format("%s/bg/btn_next",bg_name)):GetComponent("UIButton")
		if battleId == 90001 or isGuildMonsterBattle  then
			_ui.btnRetreat.gameObject:SetActive(true)
			SetPressCallback(_ui.btnRetreat.gameObject, QuitPressCallback)
		else
			local showResultCorount = coroutine.start(function()
				coroutine.wait(2)
				ShowAccount()
			end)
		end
		
		if battleId == 90007 and ChapterSelectUI.IsLevelFirst(90007) then
			GUIMgr:SendDataReport("efun", "mission_1_6")
		elseif battleId == 90014 and ChapterSelectUI.IsLevelFirst(90014) then
			GUIMgr:SendDataReport("efun", "mission_1_1")
		elseif battleId == 90013 and ChapterSelectUI.IsLevelFirst(90013) then
			GUIMgr:SendDataReport("efun", "mission_1_3")
		elseif battleId == 90011 and ChapterSelectUI.IsLevelFirst(90011) then
			GUIMgr:SendDataReport("efun", "mission_c1")
		elseif battleId == 10210 and ChapterSelectUI.IsLevelFirst(10210) then
			GUIMgr:SendDataReport("efun", "mission_c2")
		end
		
		AudioMgr:PlayMusic("MUSIC_victroy" , 0.2 , false , 1)
        if isRandomPVE and ActivityStage.GetActivityID() == 5 then
            local battleData = InGameUI.GetBattleData()
            local new_time = battleData.time - InGameUI.leftSecond  
            local pm = ActivityStage.GetPreMission()
            if pm.betterTime ~= nil and pm.betterTime < new_time  then
                ActivityData.SetActivityDataTime(5,new_time)
            end
        end		
	else
		_ui.GameWin.gameObject:SetActive(false)
		_ui.GameLose.gameObject:SetActive(true)
		bg_name = _ui.GameLose.gameObject.name
		
		local failGeneralBtn = transform:Find(string.format("%s/bg/bg_mid/btn_general",bg_name)):GetComponent("UIButton")
		SetPressCallback(failGeneralBtn.gameObject, QuitFailGenCallback)
		local faildevelopBtn = transform:Find(string.format("%s/bg/bg_mid/btn_develop",bg_name)):GetComponent("UIButton")
		SetPressCallback(faildevelopBtn.gameObject, QuitFailDevCallback)
		local failSceinBtn = transform:Find(string.format("%s/bg/bg_mid/btn_science",bg_name)):GetComponent("UIButton")
		SetPressCallback(failSceinBtn.gameObject, QuitFailScienceCallback)
		
		AudioMgr:PlayMusic("MUSIC_defeat" , 0.2 , false , 1)
        if isRandomPVE and ActivityStage.GetActivityID() == 5 then
            local battleData = InGameUI.GetBattleData()
            local better_time_root = transform:Find("bg_fail (1)/bg/time").gameObject
            local better_time = transform:Find("bg_fail (1)/bg/time/time text"):GetComponent("UILabel")
            local bestTImeobj = transform:Find("bg_fail (1)/bg/time/best time bg").gameObject
            bestTImeobj:SetActive(false)
            local new_time = battleData.time - InGameUI.leftSecond  
            local pm = ActivityStage.GetPreMission()
            print(pm.betterTime , new_time)
            if pm.betterTime ~= nil and pm.betterTime < new_time  then
                ActivityData.SetActivityDataTime(5,new_time)
                bestTImeobj:SetActive(true)
            end
            better_time_root:SetActive(true)
            better_time.text = Serclimax.GameTime.SecondToString(new_time)
        end
	end
	
	local battleData = InGameUI.GetBattleData()
	if battleData ~= nil then
		for i = 1, 3 do
			local textMission = transform:Find(string.format("%s/bg/bg/bg_star (%d)/text" ,bg_name, i)):GetComponent("UILabel")
			local starConditionId = battleData["starCondition"..i]
			local starConditionData = TableMgr:GetStarConditionData(starConditionId)
			if starConditionData ~= nil then
				textMission.text = TextMgr:GetText(starConditionData.description)
			end
		end
	end
	
	_ui.btnRetreat = transform:Find(string.format("%s/bg/btn_next",bg_name)):GetComponent("UIButton")
	SetPressCallback(_ui.btnRetreat.gameObject, QuitPressCallback)
	
	
	_ui.btnQuit = transform:Find(string.format("%s/bg/btn_back",bg_name)):GetComponent("UIButton")
	SetPressCallback(_ui.btnQuit.gameObject, RestartPressCallback)
	if isRandomPVE or isGuildMonsterBattle or isPveMonsterBattle then
	    _ui.btnQuit.gameObject:SetActive(false)
	end	

	
	_ui.btnData = transform:Find(string.format("%s/bg/btn_date" , bg_name)):GetComponent("UIButton")
	SetPressCallback(_ui.btnData.gameObject, BattleDataPressCallback)
	
	local AccountBtnRetreat = _ui.GameAccount:Find("bg/btn_next"):GetComponent("UIButton")
	SetPressCallback(AccountBtnRetreat.gameObject, QuitPressCallback)
	
	local AccountBtnQuit = _ui.GameAccount:Find("bg/btn_back"):GetComponent("UIButton")
	SetPressCallback(AccountBtnQuit.gameObject, RestartPressCallback)
	if isRandomPVE or isPveMonsterBattle then
	    AccountBtnQuit.gameObject:SetActive(false)
	end
	
	if Tutorial.IsAuto() then
        QuitPressCallback(false)
    end
end

function Awake()
	_ui = {}
	gamestateBattle = Global.GGameStateBattle
	--TableMgr = SceneManager.instance.gScTableData
	_ui.GameWin = transform:Find("bg_win")
	_ui.GameLose = transform:Find("bg_fail (1)")
	_ui.GameAccount = transform:Find("bg_account")
	_ui.AccountHeroItem = transform:Find("listitem_hero")
	_ui.AccountListHero = transform:Find("listhero")
	
	_ui.heroGrid = _ui.GameAccount:Find("bg/bg_top/Grid"):GetComponent("UIGrid")
	_ui.rewardScrol = _ui.GameAccount:Find("bg/bg_bottom/Scroll View"):GetComponent("UIScrollView")
	_ui.rewardGrid = _ui.GameAccount:Find("bg/bg_bottom/Scroll View/Grid"):GetComponent("UIGrid")
	
	showFinish = false
	HeroAddLevelCo = {}

	AddDelegate(UICamera, "onPress", OnUICameraPress)      
	FunctionListData.RequestListData()
	playhero = true
end

function SetStarCount(count)
	starCount = count
end

function SetStar(s)
    star = s
end

local function UpdateHeroDisplay(herouid)
	if _ui.heroGrid == nil or _ui.heroGrid:Equals(nil) then
		return 
	end
	local heroInfoItem = _ui.heroGrid.transform:Find("hero_" .. herouid)
	if heroInfoItem ~= nil then
		local herolv = heroInfoItem.transform:Find("leveltext"):GetComponent("UILabel")
		herolv.text = tonumber(herolv.text) + 1
		
		local herolvup = heroInfoItem.transform:Find("headicon/txt_lvlpu")
		herolvup.gameObject:SetActive(true)
		
		local herolvupEff = heroInfoItem.transform:Find("GeneralLvUp")
		herolvupEff.gameObject:SetActive(true)
		if playhero then
			playhero = false
			AudioMgr:PlayUISfx("SFX_UI_herolevelup_succeed", 1, false)
		end
	end
end

local function UpdatePlayerExpDisplay()

	local playlevel = _ui.GameAccount:Find("bg/bg_mid/level_text"):GetComponent("UILabel")
	local newLevel = tonumber(playlevel.text) + 1
	if DontRefrushData then
		newLevel = tonumber(playlevel.text)
	end

	local maxLevel = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PlayerMaxLevel).value)
	playlevel.text = newLevel <= maxLevel and newLevel or maxLevel
	
	local playlevelup = _ui.GameAccount:Find("bg/bg_mid/txt_lvlpu"):GetComponent("UILabel")
	playlevelup.gameObject:SetActive(newLevel <= maxLevel)
	
	local levrlupEff = _ui.GameAccount:Find("bg/ExpBarFull")
	levrlupEff.gameObject:SetActive(newLevel <= maxLevel)
	
	PlayerLevelup.SetLevelContent(battleResult.fresh.maindata.level , MainData.GetLevel())
	if not DontRefrushData then
		MainData.UpdateData(battleResult.fresh.maindata)
		PlayerLevelup.Show()
	end
end

local function StopHeroAddLevelCorountine()
	if HeroAddLevelCo ~= nil then
		for i=1 , #HeroAddLevelCo do
			if HeroAddLevelCo[i] ~= nil then
				coroutine.stop(HeroAddLevelCo[i])
			end
		end
	end
	HeroAddLevelCo = nil
end
 
function Close()
	StopHeroAddLevelCorountine()
	display_playback = false
	UpdateBattleData()
	DontRefrushData = false
	isRandomPVE = false
	isGuildMonsterBattle = false
	isPveMonsterBattle = false
	battleId = 0
	Tooltip.HideItemTip()
	
	_ui = nil
	gamestateBattle = nil
	PlayBackInfo = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function ShowFinishCallBack()
	showFinish = true
end

function ShowAccount(isPvp4Pve)
	local isP4PVE = isPvp4Pve == nil and false or isPvp4Pve
	if isP4PVE then
		local acctBtnBack = _ui.GameAccount:Find("bg/btn_back")
		local acctBtnNext = _ui.GameAccount:Find("bg/btn_next")
		local acctBtnReport = _ui.GameAccount:Find("bg/btn_report")
		local acctBtnPlayBack = _ui.GameAccount:Find("bg/btn_playback")
		local curP4pve = Global.GetCurrentP4PVEMsg()
		local win = false
		if curP4pve ~= nil and curP4pve.id == battleId then
			local resultMsg = curP4pve.result.battleResult
			win = resultMsg.winteam == 1
		end
		acctBtnBack.gameObject:SetActive(not win)
		acctBtnReport.gameObject:SetActive(not display_playback)
		acctBtnPlayBack.gameObject:SetActive(display_playback)
		SetClickCallback(acctBtnBack.gameObject , ClickPVP4PVE_Back)
		SetClickCallback(acctBtnNext.gameObject , ClickPVP4PVE_Next)
		SetClickCallback(acctBtnReport.gameObject , ClickPVP4PVE_Report)
		SetClickCallback(acctBtnPlayBack.gameObject , ClickPVP4PVE_PlayBack)
	end
	
	showGuide = true
	
	_ui.GameAccount.gameObject:SetActive(true)
	local heroFreshInfo = battleResult.fresh.hero.data

    if not isRandomPVE then
		--将领升级
		--local teamType = Common_pb.BattleTeamType_Main
		local myteam = TeamData.GetDataByTeamType(Common_pb.BattleTeamType_Main)
		if isP4PVE then
			local curP4pve = Global.GetCurrentP4PVEMsg()
			local resultMsg = curP4pve.result.data.fresh
			heroFreshInfo = resultMsg.hero.data
			myteam = {memHero={}}
			if heroFreshInfo ~= nil then
				for i=1 , #heroFreshInfo , 1 do
					table.insert(myteam.memHero , heroFreshInfo[i].data)
				end
			end
			
		end
		
		for _, v in ipairs(myteam.memHero) do
			local heroitem = NGUITools.AddChild(_ui.heroGrid.transform.gameObject , _ui.AccountHeroItem.gameObject)
			heroitem.gameObject:SetActive(true)
			heroitem.gameObject.name = "hero_" .. v.uid
			heroitem.transform:SetParent(_ui.heroGrid.transform , false)
			
			local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
			local heroData = TableMgr:GetHeroData(heroMsg.baseid)
			
			local heroicon = heroitem.transform:Find("headicon"):GetComponent("UITexture")
			heroicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
			
			local herolv = heroitem.transform:Find("leveltext"):GetComponent("UILabel")
			herolv.text = heroMsg.level
			
			local herostar = heroitem.transform:Find(System.String.Format("star/star{0}" , heroMsg.star))
			herostar.gameObject:SetActive(true)
			
			local heroQuality = heroitem.transform:Find(System.String.Format("headicon/outline{0}" , heroData.quality))
			heroQuality.gameObject:SetActive(true)
			
			local heroexp = heroitem.transform:Find("bg_exp/exp"):GetComponent("UISlider")
			local heroExpNum = heroitem.transform:Find("bg_exp/txt_exp"):GetComponent("UILabel")
			local heroLevel = TableMgr:GetHeroLevelByExp(heroMsg.exp)
			local heroNewLevel = 0
			for _,vv in ipairs(heroFreshInfo) do
				if v.uid == vv.data.uid then
					heroNewLevel = TableMgr:GetHeroLevelByExp(vv.data.exp)
					
					local heroAddExp = (vv.data.exp - heroMsg.exp)
					if DontRefrushData then
						heroAddExp = 0
					end
					if heroAddExp > 0 then
						heroExpNum.text = "+" .. heroAddExp
					else
						heroExpNum.gameObject:SetActive(false)
					end
					print("uid:" .. vv.data.uid .. "exp:" .. vv.data.exp .. "newlevel：" .. heroNewLevel .. "oldlevel:" .. heroLevel)
				end
			end
			
			local heroAddLevel = heroNewLevel - heroLevel
			if DontRefrushData then
				heroAddLevel = 0
			end	
			--print("heroadd" .. heroAddLevel)
			local heroAddTime = 2000 --ms
			local totalAdd = 0
			if heroAddLevel > 0 then
				local addStep = 0.05--heroAddLevel/heroAddTime
				local startPercent = heroLevel - math.floor(heroLevel)
				local addlevelCo = coroutine.start(function()
					while totalAdd < heroAddLevel do
						startPercent = startPercent + addStep
						totalAdd = totalAdd + addStep
						if math.floor(startPercent) > 0 then
							startPercent = startPercent - math.floor(startPercent)
							UpdateHeroDisplay(v.uid)
						end
						heroexp.value = startPercent
						coroutine.wait(addStep)
					end
				end)
				table.insert(HeroAddLevelCo , addlevelCo)
			end
			
		end
		_ui.heroGrid:Reposition()

	end


----获得奖励物品

	rewardList = {}
	rewardList.data = {}    
	rewardList.grid = _ui.rewardGrid	
	rewardList.scrollview = _ui.rewardScrol
	
	local showInfo = {}
	showInfo.msg = battleResult
	showInfo.ItemInfo = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")--AccountRewardItem
	showInfo.HeroIndo = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")--_ui.AccountListHero
	
	rewardList.data = UIUtil.FormatItemList(showInfo)
	local itemShowCor = UIUtil.UIListItemShow(rewardList , 4 , ShowFinishCallBack)
	table.insert(HeroAddLevelCo , itemShowCor)
	
	if not isRandomPVE then		
		if battleResult.reward.item.item == nil or (#battleResult.reward.item.item) == 0 then
			local itemBottom = _ui.GameAccount:Find("bg/bg_bottom")
			itemBottom.gameObject:SetActive(false)
		end 
	else
		if battleResult.fresh.item.items == nil or (#battleResult.fresh.item.items) == 0 then
			local itemBottom = _ui.GameAccount:Find("bg/bg_bottom")
			itemBottom.gameObject:SetActive(false)
		end 
	end
	--玩家信息
	local pLevel = MainData.GetLevel()
	local expData = TableMgr:GetPlayerExpData(pLevel)
	local playlevel = _ui.GameAccount:Find("bg/bg_mid/level_text"):GetComponent("UILabel")
	playlevel.text = pLevel
	--玩家经验值
	local mData = battleResult.fresh.maindata
	local playExpAdd = _ui.GameAccount:Find("bg/bg_mid/exp_text"):GetComponent("UILabel")
	local texp = TableMgr:GetPlayerLvupExp(mData.level , mData.exp , MainData.GetLevel() , MainData.GetExp())
	--print(texp ,MainData.GetLevel() , MainData.GetExp() ,mData.level , mData.exp )
	playExpAdd.text = "+" .. (mData.level > 0 and TableMgr:GetPlayerLvupExp(mData.level , mData.exp , MainData.GetLevel() , MainData.GetExp()) or 0)--curExp - lastExp
	if isP4PVE then
		local curP4pve = Global.GetCurrentP4PVEMsg()
		Global.DumpMessage(curP4pve.result , "d:/P4PVEMsg.lua")
		if curP4pve ~= nil and curP4pve.id == battleId then
			playExpAdd.text = "+" .. curP4pve.result.data.exp
			mData = curP4pve.result.data.fresh.maindata
			Global.DumpMessage(mData,"d:/curP4pve.lua")
		end
	end
	if DontRefrushData then
		playExpAdd.text = "+0"
	end
	
	--玩家经验条
	local lastPlayerLeveExp = TableMgr:GetPlayerExpData(MainData.GetLevel()).playerExp
	local lastPlayExp = MainData.GetLevel() + (MainData.GetExp() / lastPlayerLeveExp)
	
	--print(mData.level , TableMgr:GetPlayerExpData(mData.level).playerExp , lastPlayerLeveExp)
	local curPlayLevelExp = mData.level > 0 and TableMgr:GetPlayerExpData(mData.level).playerExp or lastPlayerLeveExp
	local curPlayExp = mData.level > 0 and (mData.level + (mData.exp / curPlayLevelExp)) or lastPlayExp
	
	--print("lastPlayExp:" .. lastPlayExp .. " curPlayExp:" .. curPlayExp)
	
	local playExpSlide = _ui.GameAccount:Find("bg/bg_mid/bg_exp/exp"):GetComponent("UISlider")
	local playAddLevel = curPlayExp - lastPlayExp
	local startPercent = lastPlayExp - math.floor(lastPlayExp)
	local heroAddTime = 20 --ms
	if mData.level > 0 and not isP4PVE then
		local playerExpCo = UIUtil.UIAnimSlider(startPercent , playAddLevel , heroAddTime , playExpSlide ,
		function()
			if MainData.GetExp() <= curPlayLevelExp then
				UpdatePlayerExpDisplay()
			end			
		end)
		table.insert(HeroAddLevelCo , playerExpCo)
	else
		playExpSlide.value = startPercent
	end
	AudioMgr:PlayUISfx("SFX_UI_progressbar_up01", 1, false)
	--[[
	local playAddLevel = curPlayExp - lastPlayExp
	local heroAddTime = 20 --ms
	local totalExpAdd = 0
	if playAddLevel > 0 then
		local addStep = playAddLevel/heroAddTime
		local startPercent = lastPlayExp - math.floor(lastPlayExp)
		local PlayerAddLevelCo = coroutine.start(function()
			while totalExpAdd < playAddLevel do
				playExpSlide.value = startPercent
				coroutine.wait(addStep)
				startPercent = startPercent + addStep
				if math.floor(startPercent) > 0 then
					startPercent = startPercent - math.floor(startPercent)
					UpdatePlayerExpDisplay()
				end
				totalExpAdd = totalExpAdd + addStep
			end
		end)
	end
	--]]
	--playExpSlide.value = MainData.GetExp() / expData.playerExp
end

function Show()
    Global.OpenUI(_M)
end
