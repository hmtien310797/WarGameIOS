module("RebelArmy", package.seeall)
local Common_pb = require("Common_pb")
local BattleMsg_pb = require("BattleMsg_pb")
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
local ActivityID
local BattleInfo
local selectedList
local battleParam

function GetCurBattleInfo()
    return BattleInfo
end

local function CloseClickCallback(go)
    --
	local msg = TextMgr:GetText("Union_Radar_ui40")
	local okCallback = function()
		Hide()
	end
	local cancelCallback = function()
		
	end
	MessageBox.Show(msg, okCallback, cancelCallback)
end

local function GetArmys()
	local heros , armys
	for i=1 , #BattleInfo.data.events ,1 do
		if BattleInfo.data.events[i].eventType == 6 then
			heros = BattleInfo.data.events[i].event
		end
	end
	
	for i=1 , #BattleInfo.data.events ,1 do
		if BattleInfo.data.events[i].eventType == 5 then
			armys = BattleInfo.data.events[i].event
		end
	end
	
	return heros , armys
end

function StartBattle(activityId,missionId , startmsg)
	local heros,armys = GetArmys()
	
	--battle config
	local battleState = GameStateBattle.Instance
	battleState.IsPvpBattle = false
	GUIMgr:CloseAllMenu()
	print(BattleInfo.data.chapterlevel)
	battleState:SetGuildMonsterBattleStartResponse(BattleInfo.data.activityid , BattleInfo.data.missionid ,  BattleInfo.data.chapterlevel,startmsg:SerializeToString())
	battleState.BattleId =  BattleInfo.data.chapterlevel
	--armty
	local selectedArmyList = {}
	for i =1,#(armys) do
		table.insert(selectedArmyList,armys[i])
	end
	
	--hero
	local heroInfoDataList = battleState.heroInfoDataList
	heroInfoDataList:Clear()
	for i =1,#(heros) do
		heroInfoDataList:Add(selectedList[i].hero.msg:SerializeToString())
	end
	
	local battleBonus = AttributeBonus.CalBattleBonus(BattleInfo.data.chapterlevel)
	local battleArgs = 
	{
		battleId = BattleInfo.data.chapterlevel,
		loadScreen = "1",
		selectedArmyList = selectedArmyList,
		battleBonus = 
		{
			bulletAddition = battleBonus.SummonEnergy,
			energyAddition = battleBonus.SkillEnergy,
			bulletRecover = battleBonus.SummonEnergyRecovery,
		}         
	}
	--set back menu
	Global.SetMenuBackState("WorldMap" , nil ,battleParam.backPosx , battleParam.backPosy )
	Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
end

function PveMonsterStartBattle(startmsg , clintLevelFinalFight , monsterUid)
	
	--battle config
	local battleState = GameStateBattle.Instance
	battleState:SetPveMonsterBattleStartResponse(monsterUid , startmsg.data.chapterlevel,startmsg:SerializeToString())
	local _battleId = startmsg.data.chapterlevel
	local battleData = TableMgr:GetBattleData(_battleId)
	local unlockArmyId
	local unlockHeroId
	if not ChapterListData.HasLevelExplored(_battleId) and battleData.unlock ~= "NA" then
		local unlockList = string.split(battleData.unlock, ",")
		if unlockList[1] == "1" then
			unlockArmyId = tonumber(unlockList[2])
		elseif unlockList[1] == "2" then
			unlockHeroId = tonumber(unlockList[2])
		end
	end

	
	battleState.IsPvpBattle = false
	GUIMgr:CloseAllMenu()

	battleState.BattleId =  _battleId

	local teamData = TeamData.GetDataByTeamType(Common_pb.BattleTeamType_Main)
	local selectedArmyList = {}
	for _, v in ipairs(teamData.memArmy) do
		table.insert(selectedArmyList, v.uid)
	end

	local heroInfoDataList = battleState.heroInfoDataList
	heroInfoDataList:Clear()
	for _, v in ipairs(teamData.memHero) do
	local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
		heroInfoDataList:Add(heroMsg:SerializeToString())
	end

	if unlockHeroId ~= nil and heroInfoDataList.Count < 5 then
		local heroMsg = Common_pb.HeroInfo()
		heroMsg.uid = 0
		heroMsg.baseid = unlockHeroId
		heroMsg.star = 1
		heroMsg.exp = 0
		heroMsg.grade = 1
		heroMsg.skill.godSkill.id = tonumber(TableMgr:GetHeroData(unlockHeroId).skillId)
		heroMsg.skill.godSkill.level = 1

		heroInfoDataList:Add(heroMsg:SerializeToString())
	end

	AttributeBonus.CollectBonusInfo()
	local battleBonus = AttributeBonus.CalBattleBonus(_battleId)
	local hpcoef = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveMonsterHpCoef).value)
	local attackcoef = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveMonsterAttackCoef).value)
	
	
	levelFinalFight = startmsg.data.attrCoef
	local battleArgs = 
	{
		loadScreen = "1",
		selectedArmyList = selectedArmyList,
		battleBonus = 
		{
			bulletAddition = battleBonus.SummonEnergy,
			energyAddition = battleBonus.SkillEnergy,
			bulletRecover = battleBonus.SummonEnergyRecovery,
			
			attackCoefAddjust = ((levelFinalFight-1)*attackcoef + 1),
			defenceAddjust = 0,
			hpAddjust = ((levelFinalFight-1)*hpcoef + 1)
		}
	}
	print("开始战斗，关卡Id:", _battleId , "关卡敌军hp加成:" .. ((levelFinalFight-1)*hpcoef + 1) , "关卡敌军attack加成:" .. ((levelFinalFight-1)*attackcoef + 1) , "关卡敌军defence加成:0" , 
	"前端调整后战力:" .. clintLevelFinalFight .. "后端调整后战力:" .. levelFinalFight)
	Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
end

local function LoadArmy(army, armyData)
    army.data = armyData
    local groupData = TableMgr:GetGroupData(armyData._unitArmyType)
    army.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", armyData._unitSoldierIcon)
    army.bulletCost.text = groupData._UnitGroupNum * armyData._unitNeedBullet
end

local function LoadUI(startmsg)
    local select_hero = transform:Find("Container/bg_battle skills/bg_selected")
    selectedList = {}
    for i = 1, 5 do
        selectedList[i] ={}
        local hero = {}
        hero.bg = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d", i))
        hero.btn = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg", i)):GetComponent("UIButton")
        hero.icon = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/head icon", i)):GetComponent("UITexture")
        hero.levelLabel = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/head icon/level text", i)):GetComponent("UILabel")
        hero.qualityList = {}
        for j = 1, 5 do
            hero.qualityList[j] = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/head icon/outline%d", i, j))
        end
        hero.starList = {}
        for j = 1, 6 do
            hero.starList[j] = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/head icon/star/star%d", i, j))
        end
        hero.plus = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg/plus", i))
        hero.lock = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg/lock", i))
        selectedList[i].hero = hero

        local skill = {}
        skill.bg = transform:Find(string.format("Container/bg_battle skills/bg_selected/bg_skills (%d)", i))
        skill.btn = transform:Find(string.format("Container/bg_battle skills/bg_selected/bg_skills (%d)", i)):GetComponent("UIButton")
        skill.icon = transform:Find(string.format("Container/bg_battle skills/bg_selected/bg_skills (%d)/icon_skills", i)):GetComponent("UITexture")
        skill.lock = transform:Find(string.format("Container/bg_battle skills/bg_selected/bg_skills (%d)/locked", i))
        selectedList[i].skill = skill
    end    


    local AselectedList = {}
    for i = 1, 4 do
        AselectedList[i] = {}
        local army = {}
        army.bg = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)", i))
        army.btn = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)", i)):GetComponent("UIButton")
        army.icon = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/icon_weapons", i)):GetComponent("UITexture")
        army.lock = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/locked", i))
        army.bulletIcon = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/Label/icon_danyao", i))
        army.bulletCost = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/Label", i)):GetComponent("UILabel")

        AselectedList[i].army = army
        UIUtil.SetTooltipCallback(army.btn.gameObject, function(go, show)
            if army.data == nil then
                return
            end
            if show then
                Tooltip.ShowArmyTip(army.data._unitArmyType)
            else
                Tooltip.HideArmyTip()
            end
        end)
    end

    if BattleInfo.data ~= nil then
		local heros,armys = GetArmys()
		print(#(heros) , #(armys))
        for i =1,#(heros) do
            local hero = selectedList[i].hero
            

            local heroData = TableMgr:GetHeroData(heros[i])
            local msg = Common_pb.HeroInfo()
            msg.baseid = heros[i]
            msg.level =1 
            msg.star = 1
            msg.grade = 1
            --msg.skill.godSkill = Common_pb.SkillInfo()
            msg.skill.godSkill.level =1
            msg.skill.godSkill.id = tonumber( heroData.skillId)
    
            hero.msg = msg
            HeroList.LoadHero(hero, msg, heroData)
            hero.icon.gameObject:SetActive(true)

            local skillMsg = msg.skill.godSkill
            local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id,skillMsg.level)
            local skill = selectedList[i].skill
            skill.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
            skill.icon.gameObject:SetActive(true)
            skill.lock.gameObject:SetActive(false)
		    UIUtil.SetTooltipCallback(skill.btn.gameObject, function(go, show)
            local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
            if show then
                Tooltip.ShowSkillTip(skillData.id)
            else
                Tooltip.HideSkillTip()
            end
            end)            
        end

        for i= 1, #(armys) do
            local army = AselectedList[i].army
            local armyData = TableMgr:GetUnitData(armys[i]) 
            army.data = armyData
            LoadArmy(army, armyData)
            army.icon.gameObject:SetActive(true)
            army.bulletCost.gameObject:SetActive(false)
            army.lock.gameObject:SetActive(false)
        end
    end

    SetClickCallback(transform:Find("Container/btn_back").gameObject,CloseClickCallback)
    SetClickCallback(transform:Find("Container/btn_attack").gameObject,function() StartBattle(BattleInfo.data.activityid ,BattleInfo.data.missionid , startmsg) end)
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()

end


function Show(battleinfo , param)
    PreMission = nil
    battleParam = param
    BattleInfo = battleinfo
    Global.OpenUI(_M)
    LoadUI(battleinfo)
end
