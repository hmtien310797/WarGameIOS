module("ActivityArmy", package.seeall)
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

function GetCurBattleInfo()
    return BattleInfo
end

local function CloseClickCallback(go)
    Hide()
   -- ActivityStage.Show(ActivityID)
end

function StartBattle(activityId,missionId)
    local req = BattleMsg_pb.MsgBattleRandomPVEStartRequest()
    req.activityId = activityId -- ActivityID
    req.missionId = missionId --BattleInfo.missionId
    --print(ActivityID,BattleInfo.missionId)
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleRandomPVEStartRequest, req, BattleMsg_pb.MsgBattleRandomPVEStartResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            ActivityData.UpdateListData(msg.actInfo)
            local battleState = GameStateBattle.Instance
            battleState.IsPvpBattle = false
            GUIMgr:CloseAllMenu()
            battleState:SetRandomBattleStartResponse(ActivityID,msg.chapterlevel,msg:SerializeToString())

            battleState.BattleId =  msg.chapterlevel

            local selectedArmyList = {}
            for i =1,#(BattleInfo.army) do
                table.insert(selectedArmyList,BattleInfo.army[i])
            end

            local heroInfoDataList = battleState.heroInfoDataList
            heroInfoDataList:Clear()
            for i =1,#(BattleInfo.hero) do
                heroInfoDataList:Add( selectedList[i].hero.msg:SerializeToString())
            end
            AttributeBonus.CollectBonusInfo("SelectArmy")
            local battleBonus = AttributeBonus.CalBattleBonus(msg.chapterlevel)
            local battleArgs = 
            {
                battleId = msg.chapterlevel,
                loadScreen = "1",
                selectedArmyList = selectedArmyList,
                battleBonus = 
                {
                    bulletAddition = battleBonus.SummonEnergy,
                    energyAddition = battleBonus.SkillEnergy,
                    bulletRecover = battleBonus.SummonEnergyRecovery
                }         
            }
            print("start battle, battleId:",  msg.chapterlevel)
            Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
            ActivityEntrance.CurShowID = ActivityID
        end
    end)
end

local function LoadArmy(army, armyData)
    army.data = armyData
    local groupData = TableMgr:GetGroupData(armyData._unitArmyType)
    army.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", armyData._unitSoldierIcon)
    army.bulletCost.text = groupData._UnitGroupNum * armyData._unitNeedBullet
end

local function LoadUI()
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


    if BattleInfo ~= nil then
        for i =1,#(BattleInfo.hero) do 
            local hero = selectedList[i].hero
            

            local heroData = TableMgr:GetHeroData(BattleInfo.hero[i])
            local msg = Common_pb.HeroInfo()
            msg.baseid = BattleInfo.hero[i]
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

        for i= 1, #(BattleInfo.army) do
            local army = AselectedList[i].army
            local armyData = TableMgr:GetUnitData(BattleInfo.army[i]) 
            army.data = armyData
            LoadArmy(army, armyData)
            army.icon.gameObject:SetActive(true)
            army.bulletCost.gameObject:SetActive(false)
            army.lock.gameObject:SetActive(false)
        end
    end

    SetClickCallback(transform:Find("Container/btn_back").gameObject,CloseClickCallback)
    SetClickCallback(transform:Find("Container/btn_attack").gameObject,function() StartBattle(ActivityID,BattleInfo.missionId) end)
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()

end


function Show(id,battleinfo)
    PreMission = nil
    ActivityID = id
    BattleInfo = battleinfo
    Global.OpenUI(_M)
    LoadUI()
end
