module("SelectHero", package.seeall)

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

local _ui

local teamType
local IsRandomBattle
local IsPveMonsterBattle
local pveMonsterBattle
local PveArmyPowerFactor
local curBattleId = 0
local msgInfoId = 0
local levelBaseFight
local IsExistTestMode

function SetCurBattleId(id)
	curBattleId = id
end

function Hide()
    Global.CloseUI(_M)
end

local function BackClickCallback(go)
    Hide()
	
	if IsRandomBattle then
		return
	end
	
	if IsPveMonsterBattle then
		return
	end
    ChapterInfoUI.Show(curBattleId)
end

local function ConfirmClickCallback(go)

	if IsExistTestMode then
		local teamData = TeamData.GetDataByTeamType(teamType)
		local req = ActivityMsg_pb.MsgSurvivalBattleRequest();
		for _, v in ipairs(teamData.memHero) do
			local heroMsg = GeneralData.GetGeneralByUID(v.uid)
			req.herouids:append(heroMsg.uid)
		end     
		Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSurvivalBattleRequest, req, ActivityMsg_pb.MsgSurvivalBattleResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				MessageBox.Show(TextMgr:GetText("activity_content_128"))
			else 
				Hide()
				SelectArmy.SetCurBattleId(curBattleId)
				if not IsRandomBattle and not IsPveMonsterBattle then
					SelectArmy.SetAttackCallback(nil)
				end
				SelectArmy.Show(teamType,IsRandomBattle,pveMonsterBattle)			
			end
		end)		
	else
		Hide()
		SelectArmy.SetCurBattleId(curBattleId)
		if not IsRandomBattle and not IsPveMonsterBattle then
			SelectArmy.SetAttackCallback(nil)
		end
		SelectArmy.Show(teamType,IsRandomBattle,pveMonsterBattle)		
	end
end


local function ShowHeroInfo(heroMsg)
	if heroMsg.uid == msgInfoId then
		msgInfoId = 0
		_ui.attributeList.msgTween:PlayReverse(false)
		return
	end
	msgInfoId = heroMsg.uid
	local heroData = TableMgr:GetHeroData(heroMsg.baseid)
	local heroMsgData = GeneralData.GetGeneralByUID(msgInfoId) -- HeroListData.GetHeroDataByUid(msgInfoId)
	
	for j = 1, 6 do
        local star = transform:Find(string.format("Container/bg_msg/bg/hero/head icon/star/star%d",j))
		star.gameObject:SetActive(false)
    end
		
	--hero skill 
	local skillMsg = heroMsg.skill.godSkill
    local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
	local skillicon = _ui.attributeList.msg:Find("bg/bg_skill/skill icon"):GetComponent("UITexture")
	skillicon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
	local skilliconBox = _ui.attributeList.msg:Find("bg/bg_skill/skill icon/Sprite"):GetComponent("UISprite")
	skilliconBox.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
	local skillname = _ui.attributeList.msg:Find("bg/bg_skill/skill name"):GetComponent("UILabel")
	skillname.text = TextMgr:GetText(skillData.name)
	local skilllevel = _ui.attributeList.msg:Find("bg/bg_skill/skill level"):GetComponent("UILabel")
	skilllevel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg.level) 

	local arg0 = skillData.radius
    local arg1 = nil
    if skillData.growValue ~= "NA" then
        local growValueList = string.split(skillData.growValue, ";")
        arg1 = growValueList[1] * heroMsg.level * heroMsg.level + growValueList[2] * heroMsg.level + growValueList[3]
        arg1 = math.floor(math.abs(arg1))
    end
    local arg2 = skillData.duration
    local arg3 = skillData.cost
    local arg4 = skillData.cooldown
	local skilldes = _ui.attributeList.msg:Find("bg/bg_skill/skill des lv1"):GetComponent("UILabel")
	skilldes.text = String.Format(TextMgr:GetText(skillData.longDescription), arg0, arg1, arg2, arg3, arg4)
	
	--hero info
	local heroicon = _ui.attributeList.msg:Find("bg/hero/head icon"):GetComponent("UITexture")
	heroicon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", heroData.icon)
	
	local heroName = _ui.attributeList.msg:Find("bg/name"):GetComponent("UILabel")
	heroName.text = TextMgr:GetText(heroData.nameLabel)

	local herostar = _ui.attributeList.msg:Find(System.String.Format("bg/hero/head icon/star/star{0}" , heroMsgData.star))
	herostar.gameObject:SetActive(true)
	
	local heroQuality = _ui.attributeList.msg:Find("bg/hero/head icon/outline"):GetComponent("UISprite")
	heroQuality.spriteName = "head"..heroData.quality
	
	local herolevel = _ui.attributeList.msg:Find("bg/hero/head icon/level text"):GetComponent("UILabel")
	herolevel.text = heroMsgData.level
	--hero attr
	-- local attrList = HeroListData.GetAttrList(heroMsg, heroData)

	local effectiveAttributes = {}
	for attributeID, value in pairs(GeneralData.GetAttributes(heroMsg)[2]) do
		local attributeData = TableMgr:GetNeedTextData(attributeID)
		if attributeData then
	        if (attributeData.additionArmy ~= 0 and attributeData.additionAttr < 10) or (attributeData.additionArmy == 0 and attributeData.additionAttr < 1000) then
	        	local effectiveAttribute = {}

	        	effectiveAttribute.attributeData = attributeData
	        	effectiveAttribute.value = value

	            table.insert(effectiveAttributes, effectiveAttribute)
	        end
	    end
	end

	table.sort(effectiveAttributes, function(effectiveAttribute1, effectiveAttribute2)
		return effectiveAttribute1.attributeData.id < effectiveAttribute2.attributeData.id
	end)

	local numEffectiveAttributes = #effectiveAttributes

	local attrTrf = _ui.attributeList.msg:Find("bg/bg_soldier/Grid")
	for i = 1, attrTrf.childCount do
		local attr = attrTrf:GetChild(i - 1)

		if i > numEffectiveAttributes then
			attr:Find("name"):GetComponent("UILabel").text = ""
			attr:Find("num"):GetComponent("UILabel").text = ""
		else
			local effectiveAttribute = effectiveAttributes[i]
			local attributeData = effectiveAttribute.attributeData

            attr:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(attributeData.unlockedText)
            attr:Find("num"):GetComponent("UILabel").text = Global.GetHeroAttrValueString(attributeData.additionAttr, effectiveAttribute.value)
		end
	end
	
	_ui.attributeList.msgTween:PlayForward(false)
end

function LoadBeforeAttr()
	--get attribute add power
	local ignore = {"SelectArmy", "TalentInfo", "EquipData", "BattleMove"}
	AttributeBonus.CollectBonusInfo(ignore)
end

function LoadBeforePower(armyData)
	local maxUnlockData = UnlockArmyData.GetMaxLevelArmyByUid(armyData.id)
	local maxUnlockLevel = TableMgr:GetUnitData(maxUnlockData)._unitArmyLevel
	
	local barrackInfo = Barrack.GetAramInfo(armyData._unitArmyType , maxUnlockLevel)
	return AttributeBonus.CalBattlePointNew(barrackInfo)
end

function LoadCurAttr()
	local ignore = {"TalentInfo", "EquipData", "BattleMove"}
	AttributeBonus.CollectBonusInfo(ignore)
end

function LoadAttrValue(attrTrf , armyData , isSelect, beforPower)
	attrTrf.gameObject:SetActive(true)
	
	local unitname = attrTrf:Find("name"):GetComponent("UILabel")
	if isSelect then
		unitname.applyGradient = true
		unitname.text = TextUtil.GetUnitName(armyData)
	else
		unitname.applyGradient = false
		unitname.text = "[6c6c6c]" .. TextUtil.GetUnitName(armyData).."[-]"
	end
	
	local maxUnlockData = UnlockArmyData.GetMaxLevelArmyByUid(armyData.id)
	local maxUnlockLevel = TableMgr:GetUnitData(maxUnlockData)._unitArmyLevel
	
	
	--get attribute add power
	-- ignore = {"SelectArmy", "TalentInfo"}
	--AttributeBonus.CollectBonusInfo(ignore)
	local barrackInfo = Barrack.GetAramInfo(armyData._unitArmyType , maxUnlockLevel)
	--local beforPower = AttributeBonus.CalBattlePointNew(barrackInfo)

	--AttributeBonus.CollectBonusInfo("TalentInfo")
	local afterPower = AttributeBonus.CalBattlePointNew(barrackInfo)
	--print(armyData._unitArmyType , maxUnlockLevel , beforPower , afterPower)
	
	local attrPower = attrTrf:Find("num"):GetComponent("UILabel")
	
	local attrUnitLv = attrTrf:Find("icon"):GetComponent("UISprite")
	attrUnitLv.spriteName = "level_" .. maxUnlockLevel
	
	--临时处理，新号进入选择界面没有初始化
	if PveArmyPowerFactor == nil then
		PveArmyPowerFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveArmyPowerFactor).value)
	end

	local attrValue = math.floor((afterPower - beforPower)*PveArmyPowerFactor +0.5)
	if attrValue > 0 then
		attrValue = "+" .. attrValue
	end
	if isSelect then
		attrPower.applyGradient = true
		attrPower.text = attrValue
	else
		attrPower.applyGradient = false
		attrPower.text = "[6c6c6c]" .. attrValue .. "[-]"
	end
	
	
end	

local function LoadAttrList()
	local armyList = UnlockArmyData.GetArmyList()
	local armyIndex = 1
	LoadBeforeAttr()
	local beforPowerList = {}
	for i, v in ipairs(armyList) do
		local armyData = TableMgr:GetUnitData(v)
		if armyData ~= nil and armyData._unitArmyType ~= 101 and armyData._unitArmyType ~= 102 then 
			beforPowerList[v] = LoadBeforePower(armyData)
		end
	end
	LoadCurAttr()
	local attritem = _ui.attributeList.bg:Find("bg/bg_addition/Scroll View/Grid/bg_soldier (1)")
	--local scroll = _ui.attributeList.bg:Find("bg/bg_addition/Scroll View"):GetComponent("UIScrollView")
	local grid = _ui.attributeList.bg:Find("bg/bg_addition/Scroll View/Grid"):GetComponent("UIGrid")
	if _ui.attrList == nil then
		_ui.attrList = {}
	end
    for i, v in ipairs(armyList) do
		local armyData = TableMgr:GetUnitData(v)
		local groupData = TableMgr:GetGroupData(armyData._unitArmyType)
		if groupData ~= nil and armyData ~= nil and armyData._unitArmyType ~= 101 and armyData._unitArmyType ~= 102 then 
			local isArmySelect = TeamData.IsArmySelected(teamType, v)
			local attr
			if _ui.attrList[i] == nil then
				attr = NGUITools.AddChild(grid.gameObject, attritem.gameObject).transform
				_ui.attrList[i] = attr
			else
				attr = _ui.attrList[i]
			end
			--attr:Find("bg_list").gameObject:SetActive(armyIndex % 2 == 0)
			LoadAttrValue(attr , armyData , isArmySelect, beforPowerList[v])
			armyIndex = armyIndex + 1
		end
	end
	grid:Reposition()
	
	--[[local armyIndex = 1
	for i=1 , #armyList , 1  do
		local armyData = TableMgr:GetUnitData(armyList[i])
		if armyData ~= nil and armyData._unitArmyType ~= 101 and armyData._unitArmyType ~= 102 then 
			local attr = _ui.attributeList.bg:Find(string.format("bg/bg_addition/bg_soldier (%d)" , armyIndex))
			LoadAttrValue(attr , armyData)
			armyIndex = armyIndex + 1
		end
	end

	for i, v in ipairs(_ui.myList) do
        local heroMsg = HeroListData.GetHeroDataByUid(v.msg.uid)
		local heroData = TableMgr:GetHeroData(heroMsg.baseid)
		
		local attrList = HeroListData.GetAttrList(heroMsg, heroData)
		for _ , vv in pairs(attrList) do
			--print(vv.data.additionArmy ,vv.data.additionAttr , vv.value)
		end
    end]]
end

local function LoadSelectList()
    local heroIndex = 1
    for i, v in ipairs(_ui.myList) do
        if TeamData.IsHeroSelectedByUid(teamType, v.msg.uid) then
            local hero = _ui.selectedList[heroIndex].hero
            LoadHero(hero, v.msg, v.data)
            hero.icon.gameObject:SetActive(true)
            hero.addObject:SetActive(false)

            local skillMsg = v.msg.skill.godSkill
            local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
            local skill = _ui.selectedList[heroIndex].skill
            skill.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
            skill.bg.gameObject:SetActive(true)

			SetClickCallback(hero.btnTip.gameObject, function(go)
				ShowHeroInfo(v.msg)
			end)
			
            heroIndex = heroIndex + 1
        end
    end
	
	local battleData = TableMgr:GetBattleData(curBattleId)
	local mypower = math.floor(TeamData.GetSelectedHeroPower(teamType))

	
	local targetpower = 0
	if battleData ~= nil then
		targetpower = battleData.fight
	end

	if IsPveMonsterBattle then
		--targetpower = math.floor(pveMonsterBattle.pveMonsterLevelFight)
		targetpower = pveMonsterBattle.pveMonsterLevelFight
	end
	
	if mypower >= targetpower then
		_ui.powerLabel.text = "[00ff00]"..mypower.."[-]"
	else
		_ui.powerLabel.text = "[fff000]"..mypower.."[-]"
	end
	_ui.chapterpower.text = targetpower
	
	
    local heroSlot = ChapterListData.GetHeroSlot()
    local unselectCount = 0
    for i = heroIndex, 5 do
        local hero = _ui.selectedList[i].hero
        hero.msg = nil
        hero.icon.gameObject:SetActive(false)
        local locked = i > heroSlot
        hero.lock.gameObject:SetActive(locked)
        hero.plus.gameObject:SetActive(not locked)
        hero.addObject:SetActive(not locked and unselectCount < _ui.unselectCount)
        unselectCount = unselectCount + 1
        local skill = _ui.selectedList[i].skill
        skill.bg.gameObject:SetActive(false)
    end
end

function GetPveMonsterLevelFight(baseFight)
	local levelBaseFight = baseFight
	local topHeroCount = 5 --最高的5个将军
	local topArmyCount = 4 --最高的4个兵种
	local topArmyPower , heroSortPower
	
	

	topArmyPower , heroSortPower = UnlockArmyData.GetArmyTopPower(topArmyCount,topHeroCount)
	local myTopPower = topArmyPower + heroSortPower
	local levelFight = myTopPower > levelBaseFight * 1.5 and  (myTopPower * 0.75) or levelBaseFight
	
	print("topArmyPower:" .. topArmyPower , "topHeroPower:" .. heroSortPower , "topPower:" .. myTopPower )
	print("baseFight:" .. baseFight , "levelFight:" .. levelFight)
	return levelFight
end

local LoadMyList
function LoadUI()
    -- HeroListData.Sort1()
	if pveMonsterBattle ~= nil and pveMonsterBattle.isPveMonsterBattle then
		if pveMonsterBattle.pveMonsterLevelFight == nil then
			--local levelFight = GetPveMonsterLevelFight(pveMonsterBattle.pveMonsterLevelBaseFight)
			--pveMonsterBattle.pveMonsterLevelFight = levelFight
			pveMonsterBattle.pveMonsterLevelFight = pveMonsterBattle.pveMonsterLevelBaseFight
		end
		IsPveMonsterBattle = pveMonsterBattle.isPveMonsterBattle
	end
	
    TeamData.NormalizeData()
    LoadMyList()
    LoadSelectList()
	LoadAttrList()
	--GetAttrList()
end



function LoadMyList()
    _ui.unselectCount = 0
    local heroListData = GeneralData.GetSortedGenerals() -- HeroListData.GetData()
    local heroIndex = 1
    local full = TeamData.GetSelectedHeroCount(teamType) >= ChapterListData.GetHeroSlot()
    for _, v in ipairs(heroListData) do
        local heroData = TableMgr:GetHeroData(v.baseid) 
        if not heroData.expCard then
            local heroTransform
            local hero = _ui.myList[heroIndex]
            if hero == nil then
                hero = {}
                heroTransform = NGUITools.AddChild(_ui.heroListGrid.gameObject, _ui.heroPrefab).transform
                heroTransform.gameObject.name = _ui.heroPrefab.name..heroIndex
            else
                heroTransform = _ui.heroListGrid:GetChild(heroIndex - 1)
            end
            LoadHeroObject(hero, heroTransform)
			--将军icon改为半身
			hero.icon = nil
			hero.picture = heroTransform:Find("head icon"):GetComponent("UITexture")
            hero.skillIcon = heroTransform:Find("bg_skill/icon_skill"):GetComponent("UITexture")
            hero.addObject = heroTransform:Find("add effect").gameObject
            LoadHero(hero, v, heroData)
            local skillMsg = v.skill.godSkill
            local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
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
                        else
                            TeamData.SelectHero(teamType, heroUid)
                            LoadUI()
                        end
                    end
                end
            end)
			
			SetClickCallback(hero.btnTip.gameObject, function(go)
				ShowHeroInfo(v)
			end)
            if TeamData.IsHeroSelectedByUid(teamType, v.uid) then
                hero.mask.gameObject:SetActive(true)
                hero.addObject:SetActive(false)
            else
                hero.mask.gameObject:SetActive(false)
                hero.addObject:SetActive(not full)
                _ui.unselectCount = _ui.unselectCount + 1
            end

            _ui.myList[heroIndex] = hero

            heroIndex = heroIndex + 1
        end
    end
    for i = heroIndex, math.huge do
        local heroTransform = _ui.heroListGrid:GetChild(i - 1)
        if heroTransform == nil then
            break
        end
        heroTransform.gameObject:SetActive(false)
        _ui.myList[i] = nil
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

local function AutoSelectHero()
    local heroListData = GeneralData.GetGenerals() -- HeroListData.GetData()
    for _, v in ipairs(heroListData) do
        if not TeamData.IsHeroSelectedByUid(teamType, v.uid) then
            TeamData.SelectHero(teamType, v.uid)
            break
        end
    end
end

function Awake()
    _ui = {}
    LoadUnlockTextList()
    _ui.powerLabel = transform:Find("Container/bg_right/bg/bg_power/bg/icon_mypower/num"):GetComponent("UILabel")
    _ui.chapterpower_root= transform:Find("Container/bg_right/bg/bg_power/bg/icon_targetpower").gameObject
   -- print(IsRandomBattle)
    if IsRandomBattle ~= nil and IsRandomBattle then
        
        _ui.chapterpower_root:SetActive(false)
    end
	_ui.chapterpower= transform:Find("Container/bg_right/bg/bg_power/bg/icon_targetpower/num"):GetComponent("UILabel")
    _ui.selectedList = {}
    _ui.myList = {}
	_ui.attributeList = {}
	_ui.attributeList.bg = transform:Find("Container/bg_right")
	_ui.attributeList.msg = transform:Find("Container/bg_msg")
	_ui.attributeList.msgTween = transform:Find("Container/bg_msg"):GetComponent("TweenPosition")
	_ui.attributeList.msgClose = transform:Find("Container/bg_msg/bg/btn_close"):GetComponent("UIButton")
	
	SetClickCallback(_ui.attributeList.msgClose.gameObject, function(go)
		_ui.attributeList.msgTween:PlayReverse(false)
	end)
	
    _ui.btnBack = transform:Find("Container/btn_back"):GetComponent("UIButton")
    SetClickCallback(_ui.btnBack.gameObject, BackClickCallback)
    if teamType == Common_pb.BattleTeamType_pvp_1 then
        _ui.btnBack.gameObject:SetActive(false)
    end

    for i = 1, 5 do
        _ui.selectedList[i] = {}
        local hero = {}
        hero.bg = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d", i))
        hero.btn = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg", i)):GetComponent("UIButton")
        hero.icon = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/head icon", i)):GetComponent("UITexture")
        hero.levelLabel = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/head icon/level text", i)):GetComponent("UILabel")
		hero.btnTip = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg_skill", i)):GetComponent("BoxCollider")
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
        hero.addObject = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/add effect", i)).gameObject
        _ui.selectedList[i].hero = hero
        SetClickCallback(hero.btn.gameObject, function(go)
            local heroSlot = ChapterListData.GetHeroSlot()
		    if i > heroSlot then
                FloatText.ShowOn(go, unlockSkillTextList[i], Color.white)
            end
            if hero.msg == nil then
                AutoSelectHero()
            else
                for _, v in ipairs(_ui.myList) do
                    if v.msg.uid == hero.msg.uid then
                        TeamData.UnselectHero(teamType, v.msg.uid)
                    end
                end
            end
            LoadUI()
        end)

        local skill = {}
        skill.bg = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg_skill", i))
        skill.icon = transform:Find(string.format("Container/bg_battle skills/bg_selected/hero%d/bg_skill/icon_skill", i)):GetComponent("UITexture")
        _ui.selectedList[i].skill = skill
    end

    _ui.heroListGrid = transform:Find("Container/bg_skills/bg_skills/bg2/Scroll View/Grid"):GetComponent("UIGrid")

    _ui.btnConfirm = transform:Find("Container/btn_attack"):GetComponent("UIButton")
    SetClickCallback(_ui.btnConfirm.gameObject, ConfirmClickCallback)

    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero_item_card")
	PveArmyPowerFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveArmyPowerFactor).value)
	
	SelectArmy.SetTeamType(Common_pb.BattleTeamType_Main)
	SelectArmy.RegistAttributeModel()
    LoadUI()
end

function Close()
    _ui = nil
end

function Show(type,isRandomBattle , pveMonsterBattleParam,isExistTestMode)
	IsPveMonsterBattle = false
    IsRandomBattle = isRandomBattle
	pveMonsterBattle = pveMonsterBattleParam
	IsExistTestMode = isExistTestMode
    teamType = type
    Global.OpenUI(_M)
end

function GetTopHeroPower(count)
	local topHeroPower = 0
	--HeroListData.GetHeroTopPower(5)
	local HeroTopPower = GeneralData.GetPowerRankingList() -- HeroListData.GetHeroTopPower() 
	for i=1 , #HeroTopPower , 1 do
		if i <= count then
			topHeroPower = topHeroPower + HeroTopPower[i].power
		end
	end
    return topHeroPower
end
