module("HeroSkillUpNew", package.seeall)

local EFFECT_DELAY5 = 1.9 --技能升级显示延时
local EFFECT_DELAY7 = 0.6 --技能升级显示后再过一段延时播放技能变化特效
local STAR_EFFECT_SCALE = 0.3 --升级特效缩放

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

local LoadHero = HeroList.LoadHero
local LoadHeroObject = HeroList.LoadHeroObject

local SetNumber = Global.SetNumber
local LoadHero = HeroList.LoadHero
local oldHeroMsg
local oldHeroData
local newHeroMsg
local newHeroData

local _ui

function IsInViewport()
    return _ui ~= nil
end


function LoadHeadPage(headPage, _heroMsg, _heroData)
    LoadHero(headPage, _heroMsg, _heroData)
  --  headPage.power.gameObject:SetActive(true)
  --  headPage.powerLabel.text = math.floor(GeneralData.GetPower(_heroMsg)) -- HeroListData.GetPower(_heroMsg, _heroData)
end


function LoadUI()
    oldHeroData = TableMgr:GetHeroData(oldHeroMsg.baseid)
    newHeroData = TableMgr:GetHeroData(newHeroMsg.baseid)

    LoadHeadPage(_ui.headPage, newHeroMsg, newHeroData)

    attributes_beforeStarUp = GeneralData.GetAttributes(oldHeroMsg)[0]
    attributes_current = GeneralData.GetAttributes(newHeroMsg)[0]

    for i = 1, _ui.attrList.transform.childCount do
        if i ~= 2 or (i == 2 and Global.IsOutSea()) then
            local uiAttribute = _ui.attrList[i]

            if i == 1 then
                uiAttribute.valueLabel[1].text = TableMgr:GetRulesDataByStarGrade(oldHeroMsg.star, oldHeroMsg.grade).maxlevel
                uiAttribute.valueLabel[2].text = TableMgr:GetRulesDataByStarGrade(newHeroMsg.star, newHeroMsg.grade).maxlevel
            else
                local attributeIndex = tonumber(uiAttribute.gameObject.name)

                if attributeIndex == 0 then
                    uiAttribute.nameLabel.gameObject:SetActive(false)
                    uiAttribute.valueLabel[1].gameObject:SetActive(false)
                    uiAttribute.valueLabel[2].gameObject:SetActive(false)
                else
                    uiAttribute.nameLabel.gameObject:SetActive(true)
                    uiAttribute.valueLabel[1].gameObject:SetActive(true)
                    uiAttribute.valueLabel[2].gameObject:SetActive(true)

                    local attributeType = oldHeroData["additionAttr" .. attributeIndex]
                    local attributeID = Global.GetAttributeLongID(oldHeroData["additionArmy" .. attributeIndex], attributeType)

                    uiAttribute.valueLabel[1].text = Global.GetHeroAttrValueString(attributeType, attributes_beforeStarUp[attributeID])
                    uiAttribute.valueLabel[2].text = Global.GetHeroAttrValueString(attributeType, attributes_current[attributeID])
                end
            end
        end
    end

    local oldStar = oldHeroMsg.star
    local newStar = newHeroMsg.star

    local oldGrade = oldHeroMsg.grade
    local newGrade = newHeroMsg.grade

    local starUp = newStar ~= oldStar
    local gradeUp = not starUp and newGrade ~= oldGrade
    if starUp then
        newGrade = 0
    end

    SetNumber(_ui.starList, oldStar)
    SetNumber(_ui.starList, newStar)

    _ui.smallStarList.transform.gameObject:SetActive(true)

    HeroList.LoadHeroSmallStarList(_ui.smallStarList, newStar, newGrade, newHeroData, false)

    _ui.starUp.gameObject:SetActive(starUp)
    _ui.gradeUp.gameObject:SetActive(gradeUp)
    _ui.starEffect.gameObject:SetActive(true)
    if starUp then
        _ui.starEffect.localScale = Vector3.one
        NGUIMath.OverlayPosition(_ui.starEffect, _ui.headPage.starList[newStar]:GetChild(newStar - 1))
    else
        _ui.starEffect.localScale = Vector3.one * STAR_EFFECT_SCALE
      --  local smallStar =  _ui.headPage.smallStarList[newStar].list[newGrade - 1].transform
      --  _ui.starEffect.localPosition = _ui.starEffect.parent:InverseTransformPoint(smallStar:TransformPoint(Vector3(11, 0, 0)))
    end

    local function LoadSkill(heroMsg)

        local skillMsg1 = oldHeroMsg.skill.godSkill
        local heroData1 = TableMgr:GetHeroData(oldHeroMsg.baseid)
        local skillData1 = TableMgr:GetGodSkillDataByIdLevel(skillMsg1.id, skillMsg1.level)
		
		local skillMsg2 = newHeroMsg.skill.godSkill
        local heroData2 = TableMgr:GetHeroData(newHeroMsg.baseid)
        local skillData2 = TableMgr:GetGodSkillDataByIdLevel(skillMsg2.id, skillMsg2.level)
		
        _ui.skillUp.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData1.iconId)
        -- _ui.skillUp.bgSprite.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
        _ui.skillUp.nameLabel.text = TextMgr:GetText(skillData1.name)
		
        _ui.skillUp.levelLabel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg2.level)
        SetNumber(_ui.skillUp.starList, skillMsg2.level)
		
		for i = 1, 3 do
			_ui.skillUp.lines[i].title.text = ""
			_ui.skillUp.lines[i].value1.text = ""
			_ui.skillUp.lines[i].value2.text = ""
			_ui.skillUp.lines[i].title.gameObject:SetActive(false)
		end
		
		local godtypes = string.split(skillData2.godshowtype, ",")
		
		local godtype = tonumber(godtypes[1])
		
		_ui.skillUp.lines[1].title.text = TextMgr:GetText("build_ui1")
		_ui.skillUp.lines[1].value1.text = oldHeroMsg.skill.godSkill.level
		_ui.skillUp.lines[1].value2.text = newHeroMsg.skill.godSkill.level
		_ui.skillUp.lines[1].title.gameObject:SetActive(true)
		
		local v1 = godtypes[3]
		local v2 = godtypes[4]
		if tonumber(godtypes[3]) ==0 and tonumber(godtypes[4]) ==0 then 
			if godtype ==1 then 
				v1 = skillData1.cooldown
				v2 = skillData2.cooldown
			elseif godtype ==2 then 
				v1 = skillData1.radius
				v2 = skillData2.radius
			elseif godtype ==3 then 
				v1 = skillData1.duration
				v2 = skillData2.duration
			elseif godtype ==4 then 
				local heroLevel = oldHeroMsg.level
				local value =0
				if skillData1.growValue ~= "NA" then
					local growValueList = table.map(string.split(skillData1.growValue, ";"), tonumber)

					value = growValueList[1] * heroLevel * heroLevel + growValueList[2] * heroLevel + growValueList[3]
					value = math.floor(math.abs(value))
				end
				v1 = value

				heroLevel = newHeroMsg.level
				value =0
				if skillData2.growValue ~= "NA" then
					local growValueList = table.map(string.split(skillData2.growValue, ";"), tonumber)

					value = growValueList[1] * heroLevel * heroLevel + growValueList[2] * heroLevel + growValueList[3]
					value = math.floor(math.abs(value))
				end
				v2 = value
			elseif godtype ==5 then 
				local ex = string.split(skillData1.explodeId, ";")
				v1 = #ex
				ex = string.split(skillData2.explodeId, ";")
				v2 = #ex
			elseif godtype ==6 then 
				
			end 
		end
		
		_ui.skillUp.lines[2].title.text = TextMgr:GetText(godtypes[2])
		_ui.skillUp.lines[2].value1.text = v1
		_ui.skillUp.lines[2].value2.text = v2
		_ui.skillUp.lines[2].title.gameObject:SetActive(true)
    end

    local function LoadPvPSkill(heroMsg)

        local skillMsg1 = oldHeroMsg.skill.pvpSkill
        local heroData1 = TableMgr:GetHeroData(oldHeroMsg.baseid)
        local skillData1 = TableMgr:GetGeneralPvpSkillData(oldHeroMsg)
		
		local skillMsg2 = newHeroMsg.skill.pvpSkill
        local heroData2 = TableMgr:GetHeroData(newHeroMsg.baseid)
        local skillData2 = TableMgr:GetGeneralPvpSkillData(newHeroMsg)
        
		_ui.skillUp_pvp.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData1.iconId)
        -- _ui.skillUp_pvp.bgSprite.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
        _ui.skillUp_pvp.nameLabel.text = TextMgr:GetText(skillData1.name)
        _ui.skillUp_pvp.levelLabel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg1.level)
        SetNumber(_ui.skillUp_pvp.starList, skillMsg2.level)
		
		for i = 1, 3 do
			_ui.skillUp_pvp.lines[i].title.text = ""
			_ui.skillUp_pvp.lines[i].value1.text = ""
			_ui.skillUp_pvp.lines[i].value2.text = ""
			_ui.skillUp_pvp.lines[i].title.gameObject:SetActive(false)
		end
		
		_ui.skillUp_pvp.lines[1].title.text = TextMgr:GetText("build_ui1")
		_ui.skillUp_pvp.lines[1].value1.text = oldHeroMsg.skill.pvpSkill.level
		_ui.skillUp_pvp.lines[1].value2.text = newHeroMsg.skill.pvpSkill.level
		_ui.skillUp_pvp.lines[1].title.gameObject:SetActive(true)
		
		local slgshowtypes = string.split(skillData2.slgshowtype, ";")
		
		local j =1
		
		for i=1,#slgshowtypes do 
			if j+i >#_ui.skillUp_pvp.lines then 
				break
			end 
			
			local slgtypes = string.split(slgshowtypes[i], ",")
			local slgtype = tonumber(slgtypes[1])
			
			local v1 = slgtypes[3]
			local v2 = slgtypes[4]
			if tonumber(slgtypes[3]) ==0 and tonumber(slgtypes[4]) ==0 then 
				if slgtype ==1 then 
					local heroLevel = skillMsg1.level
					local growValueList_pvp = table.map(string.split(skillData1.skillvalue, ","), tonumber)
					v1 = string.make_percent(100 * math.abs(growValueList_pvp[1] * heroLevel * heroLevel + growValueList_pvp[2] * heroLevel + growValueList_pvp[3]))
					
					heroLevel = skillMsg2.level
					growValueList_pvp = table.map(string.split(skillData2.skillvalue, ","), tonumber)
					v2 = string.make_percent(100 * math.abs(growValueList_pvp[1] * heroLevel * heroLevel + growValueList_pvp[2] * heroLevel + growValueList_pvp[3]))
					
				elseif slgtype ==2 then 
					v1 = skillData1.spurtingvalue
					v2 = skillData2.spurtingvalue
					
					local heroLevel = skillMsg1.level
					local growValueList_pvp = table.map(string.split(skillData1.spurtingvalue, ","), tonumber)
					if #growValueList_pvp >2 then 
						v1 = string.make_percent(100 * math.abs(growValueList_pvp[1] * heroLevel * heroLevel + growValueList_pvp[2] * heroLevel + growValueList_pvp[3]))
					else
						v1 = 0
					end 
					
					heroLevel = skillMsg2.level
					growValueList_pvp = table.map(string.split(skillData2.spurtingvalue, ","), tonumber)
					if #growValueList_pvp >2 then 
						v2 = string.make_percent(100 * math.abs(growValueList_pvp[1] * heroLevel * heroLevel + growValueList_pvp[2] * heroLevel + growValueList_pvp[3]))
					else
						v2 = 0
					end 
					
				elseif slgtype ==3 then 
					v1 = tonumber(skillData1.addskill)
					v2 = tonumber(skillData2.addskill)
					
					local data1 = tableData_tSLGSkill.data[v1]
					local data2 = tableData_tSLGSkill.data[v2]
					
					if data1 ~= nil then 
						local heroLevel = data1.level
						local growValueList_nextLevel = table.map(string.split(data1.skillvalue, ","), tonumber)
						v1 = string.make_percent(100 * math.abs(growValueList_nextLevel[1] * heroLevel * heroLevel + growValueList_nextLevel[2] * heroLevel + growValueList_nextLevel[3]))
					end 
					
					if data2 ~= nil then 
						local heroLevel = data2.level
						local growValueList_nextLevel = table.map(string.split(data2.skillvalue, ","), tonumber)
						v2 = string.make_percent(100 * math.abs(growValueList_nextLevel[1] * heroLevel * heroLevel + growValueList_nextLevel[2] * heroLevel + growValueList_nextLevel[3]))
					end 
					
				elseif slgtype ==4 then 
					
					v1 = skillData1.crit
					v2 = skillData2.crit
				end 
			end
			
			_ui.skillUp_pvp.lines[j+i].title.text = TextMgr:GetText(slgtypes[2])
			_ui.skillUp_pvp.lines[j+i].value1.text = v1
			_ui.skillUp_pvp.lines[j+i].value2.text = v2
			_ui.skillUp_pvp.lines[j+i].title.gameObject:SetActive(true)
		end 
    end

    local function LoadPassiveSkill(heroMsg)
        local heroData = TableMgr:GetHeroData(heroMsg.baseid)
        local skillId = tonumber(string.split(heroData.showpassiveskill, ";")[heroMsg.star])
        if skillId ~= 0 then
            _ui.skillUp_passive.bg.gameObject:SetActive(true)
            local skillData = TableMgr:GetPassiveSkillData(skillId)
            _ui.skillUp_passive.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.SkillIcon)
            -- _ui.skillUp_passive.bgSprite.spriteName = "bg_skill_" .. heroData.quality
            _ui.skillUp_passive.nameLabel.text = TextMgr:GetText(skillData.SkillName)
            -- _ui.skillUp_passive.levelLabel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg.level)
            -- SetNumber(_ui.skillUp_passive.starList, skillMsg.level)
			_ui.skillUp_passive.descLabel.text = TextMgr:GetText(skillData.SkillDes)
        else
            _ui.skillUp_passive.bg.gameObject:SetActive(false)
        end
		
    end
	
	coroutine.stop(_ui.autocloseCoroutine)
    _ui.autocloseCoroutine = coroutine.start(function()
        coroutine.wait(5)
        Hide()
    end)
	_ui.skillUp.upLabel:GetComponent("LocalizeEx").enabled = false
	_ui.skillUp_passive.upLabel:GetComponent("LocalizeEx").enabled = false
	_ui.skillUp_pvp.upLabel:GetComponent("LocalizeEx").enabled = false
    coroutine.stop(_ui.skillUpCoroutine)
    _ui.skillUpCoroutine = coroutine.start(function()
     --   coroutine.wait(EFFECT_DELAY5)
        
         if newHeroMsg.skill.godSkill.level ~= oldHeroMsg.skill.godSkill.level then
            _ui.skillUp.bg.gameObject:SetActive(true)
            LoadSkill(oldHeroMsg)
			if starUp then 
				--_ui.skillUp.upLabel.text = TextMgr:GetText("hero_skill_lvup")
				--_ui.skillUp_passive.upLabel.text = TextMgr:GetText("hero_skill_lvup")
				--_ui.skillUp_pvp.upLabel.text = TextMgr:GetText("hero_skill_lvup")
			else
				--_ui.skillUp.upLabel.text = TextMgr:GetText("heronew_22")
				--_ui.skillUp_passive.upLabel.text = TextMgr:GetText("heronew_22")
				--_ui.skillUp_pvp.upLabel.text = TextMgr:GetText("heronew_22")
			end 
         end

        if newHeroMsg.skill.pvpSkill.level ~= oldHeroMsg.skill.pvpSkill.level then
            _ui.skillUp_pvp.bg.gameObject:SetActive(true)
            LoadPvPSkill(oldHeroMsg)
        end

        if starUp then
            LoadPassiveSkill(newHeroMsg)
        end

    --    coroutine.wait(EFFECT_DELAY7)

        if newHeroMsg.skill.godSkill.level ~= oldHeroMsg.skill.godSkill.level then
            _ui.skillUp.effect.gameObject:SetActive(true)
            LoadSkill(newHeroMsg)
        end

        if newHeroMsg.skill.pvpSkill.level ~= oldHeroMsg.skill.pvpSkill.level then
            _ui.skillUp_pvp.effect.gameObject:SetActive(true)
            LoadPvPSkill(newHeroMsg)
        end 
		
		_ui.grid:Reposition()
		
    end)
    -- end
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function CloseClickCallback()
    Hide()
end

function LoadHeadPageObject(headPage, headTransform)
    headPage.transform = headTransform
    headPage.power = headTransform:Find("combat ")
 --   headPage.powerLabel = headTransform:Find("combat /text"):GetComponent("UILabel")
    headPage.icon = headTransform:Find("hero half"):GetComponent("UITexture")
    headPage.qualityList = {}
    for i = 1, 5 do
        headPage.qualityList[i] = headTransform:Find(string.format("hero half/hero_outline%d", i)).gameObject
    end
    headPage.starList = {}
    for i = 1, 6 do
        headPage.starList[i] = headTransform:Find(string.format("star widget/star%d", i))
    end
    headPage.starNotice = headTransform:Find("star widget/star btn/red")
    headPage.nameLabel = headTransform:Find("name text"):GetComponent("UILabel")
    local gradeTransform = headTransform:Find("name text/advanced/icon")
    if gradeTransform ~= nil then
        headPage.gradeSprite = gradeTransform:GetComponent("UISprite")
    end
--    headPage.levelLabel = headTransform:Find("level widget/lv text"):GetComponent("UILabel")
--    headPage.levelNotice = headTransform:Find("level widget/levelUP btn/red")
    headPage.smallStarList = {}
    local smallStarTransform = headTransform:Find("star widget/small star")
    HeroList.LoadHeroSmallStarObject(headPage.smallStarList, smallStarTransform)
--    headPage.skillIcon = headTransform:Find("bg_skill/icon_skill"):GetComponent("UITexture")
--    headPage.skillButton = headTransform:Find("bg_skill") 
end


function Awake()
    _ui.starList = {}
    _ui.nextStarList = {}

    local closeBtn = transform:Find("Container/close btn"):GetComponent("UIButton")
    local okBtn = transform:Find("ok btn"):GetComponent("UIButton")

    SetClickCallback(closeBtn.gameObject, CloseClickCallback)
    SetClickCallback(okBtn.gameObject, CloseClickCallback)

    _ui.headPage = {}
    LoadHeadPageObject(_ui.headPage, transform:Find("head widget"))
    
    _ui.starUp = transform:Find("effect 2")
    _ui.gradeUp = transform:Find("effect1")

    for i = 1, 6 do
        _ui.starList[i] = transform:Find(string.format("Container/star widget/star%d", i))
        _ui.nextStarList[i] = transform:Find(string.format("Container/star widget/green star%d", i))
    end

    _ui.smallStarList = {}
    local smallStarTransform = transform:Find("Container/star widget/small star")
    HeroList.LoadHeroSmallStarObject(_ui.smallStarList, smallStarTransform)

    _ui.attrList = {}
    _ui.attrList.transform = transform:Find("Container/info bg")
    for i = 1, _ui.attrList.transform.childCount do
        _ui.attrList[i] = {}
        _ui.attrList[i].transform = _ui.attrList.transform:GetChild(i - 1)
        _ui.attrList[i].gameObject = _ui.attrList[i].transform.gameObject
        _ui.attrList[i].nameLabel = _ui.attrList[i].transform:GetComponent("UILabel")
        _ui.attrList[i].valueLabel = {}
        for j = 1, 2 do
            _ui.attrList[i].valueLabel[j] = _ui.attrList[i].transform:Find(string.format("lv num%d", j)):GetComponent("UILabel")
        end
        local attrEffect = _ui.attrList[i].transform:Find("HeroAUp")
        local attrTweener = _ui.attrList[i].transform:GetComponent("UITweener")
        attrEffect.gameObject:SetActive(false)
        attrTweener:SetOnFinished(EventDelegate.Callback(function()
            attrEffect.gameObject:SetActive(true)
        end))
    end

	_ui.grid = transform:Find("Grid"):GetComponent("UIGrid")
	
    _ui.skillUp = {}
    _ui.skillUp.bg = transform:Find("Grid/skill up widget")
    _ui.skillUp.icon = transform:Find("Grid/skill up widget/bg/skill icon"):GetComponent("UITexture")
    _ui.skillUp.bgSprite = transform:Find("Grid/skill up widget/bg/skill icon/Sprite"):GetComponent("UISprite")
    _ui.skillUp.nameLabel = transform:Find("Grid/skill up widget/bg/skill name"):GetComponent("UILabel")
    _ui.skillUp.levelLabel = transform:Find("Grid/skill up widget/bg/skill level"):GetComponent("UILabel")
	_ui.skillUp.effect = transform:Find("Grid/skill up widget/bg/skill level/SkillLvUp")
	_ui.skillUp.upLabel =  transform:Find("Grid/skill up widget/skill up text"):GetComponent("UILabel")
	
    _ui.skillUp.bg.gameObject:SetActive(false)
    _ui.skillUp.effect.gameObject:SetActive(false)
    _ui.skillUp.starList = {}
    for i = 1, 6 do
        _ui.skillUp.starList[i] = transform:Find(string.format("Grid/skill up widget/bg/skill icon/star/%dstars", i))
    end
	
	_ui.skillUp.lines = {}
    for i = 1, 3 do
        local item = {};
		item.title = transform:Find(string.format("Grid/skill up widget/Container/%d", i-1)):GetComponent("UILabel")
		item.value1 = transform:Find(string.format("Grid/skill up widget/Container/%d/lv num1", i-1)):GetComponent("UILabel")
		item.value2 = transform:Find(string.format("Grid/skill up widget/Container/%d/lv num2", i-1)):GetComponent("UILabel")
		_ui.skillUp.lines[i] = item
    end

	

    _ui.skillUp_pvp = {}
    _ui.skillUp_pvp.bg = transform:Find("Grid/skill up widget_pvp")
    _ui.skillUp_pvp.icon = transform:Find("Grid/skill up widget_pvp/bg/skill icon"):GetComponent("UITexture")
    _ui.skillUp_pvp.bgSprite = transform:Find("Grid/skill up widget_pvp/bg/skill icon/Sprite"):GetComponent("UISprite")
    _ui.skillUp_pvp.nameLabel = transform:Find("Grid/skill up widget_pvp/bg/skill name"):GetComponent("UILabel")
    _ui.skillUp_pvp.levelLabel = transform:Find("Grid/skill up widget_pvp/bg/skill level"):GetComponent("UILabel")
    _ui.skillUp_pvp.effect = transform:Find("Grid/skill up widget_pvp/bg/skill level/SkillLvUp")
	_ui.skillUp_pvp.upLabel =  transform:Find("Grid/skill up widget_pvp/skill up text"):GetComponent("UILabel")
	
    _ui.skillUp_pvp.bg.gameObject:SetActive(false)
    _ui.skillUp_pvp.effect.gameObject:SetActive(false)
    _ui.skillUp_pvp.starList = {}
    for i = 1, 6 do
        _ui.skillUp_pvp.starList[i] = transform:Find(string.format("Grid/skill up widget_pvp/bg/skill icon/star/%dstars", i))
    end
	
	_ui.skillUp_pvp.lines = {}
    for i = 1, 3 do
		local item = {};
        item.title = transform:Find(string.format("Grid/skill up widget_pvp/Container/%d", i-1)):GetComponent("UILabel")
		item.value1 = transform:Find(string.format("Grid/skill up widget_pvp/Container/%d/lv num1", i-1)):GetComponent("UILabel")
		item.value2 = transform:Find(string.format("Grid/skill up widget_pvp/Container/%d/lv num2", i-1)):GetComponent("UILabel")
		_ui.skillUp_pvp.lines[i] = item;
    end
	

    _ui.skillUp_passive = {}
    _ui.skillUp_passive.bg = transform:Find("Grid/skill up widget_six")
    _ui.skillUp_passive.icon = transform:Find("Grid/skill up widget_six/bg/skill icon"):GetComponent("UITexture")
    _ui.skillUp_passive.bgSprite = transform:Find("Grid/skill up widget_six/bg/skill icon/Sprite"):GetComponent("UISprite")
    _ui.skillUp_passive.nameLabel = transform:Find("Grid/skill up widget_six/bg/skill name"):GetComponent("UILabel")
	_ui.skillUp_passive.levelLabel = transform:Find("Grid/skill up widget_six/bg/skill level"):GetComponent("UILabel")
    _ui.skillUp_passive.upLabel =  transform:Find("Grid/skill up widget_six/skill up text"):GetComponent("UILabel")
	_ui.skillUp_passive.descLabel = transform:Find("Grid/skill up widget_six/bg/skilldesc"):GetComponent("UILabel")
	_ui.skillUp_passive.effect = transform:Find("Grid/skill up widget_six/bg/skill level/SkillLvUp")
    _ui.skillUp_passive.bg.gameObject:SetActive(false)
    _ui.skillUp_passive.effect.gameObject:SetActive(false)
    _ui.skillUp_passive.starList = {}
    for i = 1, 6 do
        _ui.skillUp_passive.starList[i] = transform:Find(string.format("Grid/skill up widget/bg/skill icon/star/%dstars", i))
    end
	
    _ui.starEffect = transform:Find("NeoStarUp")
    _ui.starEffect.gameObject:SetActive(false)

    LoadUI()
end

function Close()
    HeroStarUpNew.Show(oldHeroMsg, newHeroMsg, _ui.closeCallback)

	if _ui.closeCallback then
      --  _ui.closeCallback()
    end
    coroutine.stop(_ui.autocloseCoroutine)
    coroutine.stop(_ui.skillUpCoroutine)
	
	
    _ui = nil
end

function Show(oldMsg, newMsg, closeCallback)
	local show = false
	local oldStar = oldMsg.star
    local newStar = newMsg.star

    local starUp = newStar ~= oldStar
	
	if starUp then 
		show = true
	end 
	
	if newMsg.skill.godSkill.level ~= oldMsg.skill.godSkill.level then
        show = true  
    end

    if newMsg.skill.pvpSkill.level ~= oldMsg.skill.pvpSkill.level then
        show = true
    end

    if show == false then 
		HeroStarUpNew.Show(oldMsg, newMsg, closeCallback)
		return 
	end 
	
	
	if not IsInViewport() then
        oldHeroMsg = oldMsg
        newHeroMsg = newMsg

        _ui = {}
        _ui.closeCallback = closeCallback

        Global.OpenUI(_M)
    end
end
