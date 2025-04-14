module("WallHero", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
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
local unlockSkillTextList

local LoadHero = HeroList.LoadHero
local LoadHeroObject = HeroList.LoadHeroObject

local selectedList

local heroPrefab
local myList

local btnBack
local btnConfirm
local teamType

local _ui


OnCloseCB = nil


local function ConfirmClickCallback(go)
    Global.CloseUI(_M)
   -- SelectArmy.Show(teamType)
    local req = HeroMsg_pb.MsgSetArmyTeamRequest()
    req.data.team:add()
    req.data.team[1] = TeamData.GetDataByTeamType(teamType)
	
	print("teamType:" .. teamType)
	for _ ,v in ipairs(TeamData.GetDataByTeamType(teamType).memHero) do
		print("uid:" .. v.uid)
	end
	
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmyTeamRequest, req, HeroMsg_pb.MsgSetArmyTeamResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			print("code:" .. msg.code)
        end
    end)
end

local function GetDefenseHero(hlist)

	local defentHero = {}
	local defentArmy = hlist
	local setoutHero = SetoutData.GetSetoutHero()
	
	
	for _ , v in ipairs(defentArmy) do

		local defent = true
		for _ , vv in pairs(setoutHero) do
			if v.msg.uid == vv then
				defent = false
			end
		end
		
		if defent then
			table.insert(defentHero , v)
		end
	end
	return defentHero
	
end


local function LoadSelectList()
    local heroIndex = 1
	local mList = GetDefenseHero(myList)
    for i, v in ipairs(mList) do
        if TeamData.IsHeroSelectedByUid(teamType, v.msg.uid) then
            local hero = selectedList[heroIndex].hero
            LoadHero(hero, v.msg, v.data)
            hero.icon.gameObject:SetActive(true)
			
            local skillData = TableMgr:GetGeneralPvpSkillData(v.msg)
            local skill = selectedList[heroIndex].skill
            skill.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
            skill.bg.gameObject:SetActive(true)

            heroIndex = heroIndex + 1
        end
    end
    _ui.powerLabel.text = math.floor(TeamData.GetTeamPower(teamType))
    local heroSlot = ChapterListData.GetHeroSlot()
    for i = heroIndex, 5 do
        local hero = selectedList[i].hero
        hero.msg = nil
        hero.icon.gameObject:SetActive(false)
        local locked = i > heroSlot
        hero.lock.gameObject:SetActive(locked)
        hero.plus.gameObject:SetActive(not locked)
        local skill = selectedList[i].skill
        skill.bg.gameObject:SetActive(false)
    end
end


function ReloadSelectList()
	LoadSelectList()
end

local LoadMyList
function LoadUI()
    TeamData.NormalizeData()
    LoadMyList()
    LoadSelectList()
end

function LoadMyList()
    local heroListData = GeneralData.GetSortedGenerals("3:100") -- HeroListData.GetData()
    local heroIndex = 1
    for _, v in ipairs(heroListData) do
        local heroData = TableMgr:GetHeroData(v.baseid)
        if not heroData.expCard then
            local heroTransform
            local hero = myList[heroIndex]
            if hero == nil then
                hero = {}
                heroTransform = NGUITools.AddChild(_ui.heroListGrid.gameObject, heroPrefab).transform
                heroTransform.gameObject.name = heroPrefab.name..heroIndex
            else
                heroTransform = _ui.heroListGrid:GetChild(heroIndex - 1)
            end
            LoadHeroObject(hero, heroTransform)
            hero.skillIcon = heroTransform:Find("bg_skill/icon_skill"):GetComponent("UITexture")
            LoadHero(hero, v, heroData)
			
			-- local heroState = HeroListData.GetHeroState(v.uid)
            for _, v in pairs(hero.stateList) do
                v.gameObject:SetActive(false)
            end
			if GeneralData.IsOutForExpediation(v.uid) then -- bit.band(heroState, HeroListData.HeroStateSetout) ~= 0 then
				hero.stateBg.gameObject:SetActive(true)
                hero.stateList.setout.gameObject:SetActive(true)
                TeamData.UnselectHero(teamType, v.uid)
			else
				hero.stateBg.gameObject:SetActive(false)
				hero.mask.gameObject:SetActive(TeamData.IsHeroSelectedByUid(teamType, v.uid))
            end
			
            local skillMsg = v.skill.pvpSkill
            local skillData = TableMgr:GetPvpSkillDataByIdLevel(skillMsg.id, skillMsg.level)
            hero.skillIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
            local skillBg = heroTransform:Find("bg_skill")
            skillBg.gameObject:SetActive(true)

            SetClickCallback(hero.btn.gameObject, function(go)
                local heroUid = v.uid
                local heroBaseId = v.baseid
                local full = TeamData.GetSelectedHeroCount(teamType) >= ChapterListData.GetHeroSlot()
                if TeamData.IsHeroSelectedByUid(teamType, heroUid) then
                    TeamData.UnselectHero(teamType, heroUid)
                    LoadUI()
                else
                    if full then
                        local text = TextMgr:GetText(Text.selectunit_hint114)
                        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        FloatText.Show(text, Color.white)
                    else
                        if TeamData.IsHeroSelectedByBaseId(teamType, heroBaseId) then
                            local text = TextMgr:GetText(Text.team_error_hero_repeat)
                            AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                            FloatText.Show(text, Color.white)
                        elseif GeneralData.IsOutForExpediation(v.uid) then -- bit.band(heroState, HeroListData.HeroStateSetout) ~= 0 then	
							local text = TextMgr:GetText(Text.BattleMove_atk)
                            AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                            FloatText.Show(text, Color.white)
						else
                            TeamData.SelectHero(teamType, heroUid)
                            LoadUI()
                        end
                    end
                end
            end)
           -- hero.mask.gameObject:SetActive(TeamData.IsHeroSelectedByUid(teamType, v.uid))
            myList[heroIndex] = hero

            heroIndex = heroIndex + 1
        end
    end
    for i = heroIndex, math.huge do
        local heroTransform = _ui.heroListGrid:GetChild(i - 1)
        if heroTransform == nil then
            break
        end
        heroTransform.gameObject:SetActive(false)
        myList[i] = nil
    end
    _ui.heroListGrid:Reposition()
end
local function LoadUnlockTextList()
	if unlockSkillTextList == nil then
		unlockSkillTextList = {}
		for i = 1, 5 do
		    local battleId = ChapterListData.GetUnlockHeroSlotBattleId(i)
            if battleId ~= nil then
                local battleData = TableMgr:GetBattleData(battleId)
                if battleData ~= nil then
                    local battleName = TextMgr:GetText(battleData.nameLabel)
                    local msgText = TextMgr:GetText(Text.uint_locked_hint)
                    unlockSkillTextList[i] = System.String.Format(msgText, battleName)
                end
            end
		end
	end
end

function Awake()
	_ui = {}
    LoadUnlockTextList()
    _ui.powerLabel = transform:Find("Container/bg_battle skills/bg_power/num"):GetComponent("UILabel")
    selectedList = {}
    myList = {}
	
    for i = 1, 5 do
        selectedList[i] = {}
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
        SetClickCallback(hero.btn.gameObject, function(go)
            local heroSlot = ChapterListData.GetHeroSlot()
		    if i > heroSlot then
                FloatText.ShowOn(go, unlockSkillTextList[i], Color.white)
            end
            if hero.msg == nil then
                return
            end

            for _, v in ipairs(myList) do
                if v.msg.uid == hero.msg.uid then
                    TeamData.UnselectHero(teamType, v.msg.uid)
                end
            end
            LoadUI()
        end)

        local skill = {}
        skill.bg = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg_skill", i))
        skill.icon = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg_skill/icon_skill", i)):GetComponent("UITexture")
        selectedList[i].skill = skill
    end

    _ui.heroListGrid = transform:Find("Container/bg_skills/bg_skills/bg2/Scroll View/Grid"):GetComponent("UIGrid")

    local btnConfirm = transform:Find("Container/btn_attack"):GetComponent("UIButton")
    SetClickCallback(btnConfirm.gameObject, ConfirmClickCallback)
	
	SetClickCallback(transform:Find("Container").gameObject , function()
		GUIMgr:CloseMenu("WallHero")
	end)
	
    heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_herocard")
	SetoutData.AddListener(ReloadSelectList)
	
    LoadUI()
end

function Show(type)
    teamType = type
    Global.OpenUI(_M)
	
	--TeamData.showHero(teamType)
end

function Close()
	_ui = nil
	SetoutData.RemoveListener(ReloadSelectList)
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
end
