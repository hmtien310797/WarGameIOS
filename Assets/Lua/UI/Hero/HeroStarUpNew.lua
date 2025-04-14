module("HeroStarUpNew", package.seeall)

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

local oldHeroMsg
local oldHeroData
local newHeroMsg
local newHeroData

local _ui

function IsInViewport()
    return _ui ~= nil
end

function LoadUI()
    oldHeroData = TableMgr:GetHeroData(oldHeroMsg.baseid)
    newHeroData = TableMgr:GetHeroData(newHeroMsg.baseid)

    HeroInfo.LoadHeadPage(_ui.headPage, newHeroMsg, newHeroData)
	HeroList.LoadHeroRarity(_ui.headPage.rarity,newHeroData,true)
	
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
        local smallStar =  _ui.headPage.smallStarList[newStar].list[newGrade - 1].transform
        _ui.starEffect.localPosition = _ui.starEffect.parent:InverseTransformPoint(smallStar:TransformPoint(Vector3(11, 0, 0)))
    end

    local function LoadSkill(heroMsg)
        local skillMsg = heroMsg.skill.godSkill
        local heroData = TableMgr:GetHeroData(heroMsg.baseid)
        local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
        _ui.skillUp.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
        -- _ui.skillUp.bgSprite.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
        _ui.skillUp.nameLabel.text = TextMgr:GetText(skillData.name)
        _ui.skillUp.levelLabel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg.level)
        SetNumber(_ui.skillUp.starList, skillMsg.level)
    end

    local function LoadPvPSkill(heroMsg)
        local skillMsg = heroMsg.skill.pvpSkill
        local heroData = TableMgr:GetHeroData(heroMsg.baseid)
        local skillData = TableMgr:GetGeneralPvpSkillData(heroMsg)
        _ui.skillUp_pvp.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
        -- _ui.skillUp_pvp.bgSprite.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
        _ui.skillUp_pvp.nameLabel.text = TextMgr:GetText(skillData.name)
        _ui.skillUp_pvp.levelLabel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg.level)
        SetNumber(_ui.skillUp_pvp.starList, skillMsg.level)
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
        else
            _ui.skillUp_passive.bg.gameObject:SetActive(false)
        end
    end

    coroutine.stop(_ui.skillUpCoroutine)
    _ui.skillUpCoroutine = coroutine.start(function()
        coroutine.wait(EFFECT_DELAY5)
        
        if newHeroMsg.skill.godSkill.level ~= oldHeroMsg.skill.godSkill.level then
            _ui.skillUp.bg.gameObject:SetActive(true)
            LoadSkill(oldHeroMsg)
        end

        if newHeroMsg.skill.pvpSkill.level ~= oldHeroMsg.skill.pvpSkill.level then
            _ui.skillUp_pvp.bg.gameObject:SetActive(true)
            LoadPvPSkill(oldHeroMsg)
        end

        if starUp then
            LoadPassiveSkill(newHeroMsg)
        end

        coroutine.wait(EFFECT_DELAY7)

        if newHeroMsg.skill.godSkill.level ~= oldHeroMsg.skill.godSkill.level then
            _ui.skillUp.effect.gameObject:SetActive(true)
            LoadSkill(newHeroMsg)
        end

        if newHeroMsg.skill.pvpSkill.level ~= oldHeroMsg.skill.pvpSkill.level then
            _ui.skillUp_pvp.effect.gameObject:SetActive(true)
            LoadPvPSkill(newHeroMsg)
        end
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

function Awake()
    _ui.starList = {}
    _ui.nextStarList = {}

    local closeBtn = transform:Find("Container/close btn"):GetComponent("UIButton")
    local okBtn = transform:Find("ok btn"):GetComponent("UIButton")

    SetClickCallback(closeBtn.gameObject, CloseClickCallback)
    SetClickCallback(okBtn.gameObject, CloseClickCallback)

    _ui.headPage = {}
    HeroInfo.LoadHeadPageObject(_ui.headPage, transform:Find("head widget"))
    
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

    _ui.skillUp = {}
    _ui.skillUp.bg = transform:Find("skill up widget")
    _ui.skillUp.icon = transform:Find("skill up widget/bg/skill icon"):GetComponent("UITexture")
    _ui.skillUp.bgSprite = transform:Find("skill up widget/bg/skill icon/Sprite"):GetComponent("UISprite")
    _ui.skillUp.nameLabel = transform:Find("skill up widget/bg/skill name"):GetComponent("UILabel")
    _ui.skillUp.levelLabel = transform:Find("skill up widget/bg/skill level"):GetComponent("UILabel")
    _ui.skillUp.effect = transform:Find("skill up widget/bg/skill level/SkillLvUp")
    _ui.skillUp.bg.gameObject:SetActive(false)
    _ui.skillUp.effect.gameObject:SetActive(false)
    _ui.skillUp.starList = {}
    for i = 1, 6 do
        _ui.skillUp.starList[i] = transform:Find(string.format("skill up widget/bg/skill icon/star/%dstars", i))
    end

    _ui.skillUp_pvp = {}
    _ui.skillUp_pvp.bg = transform:Find("skill up widget_pvp")
    _ui.skillUp_pvp.icon = transform:Find("skill up widget_pvp/bg/skill icon"):GetComponent("UITexture")
    _ui.skillUp_pvp.bgSprite = transform:Find("skill up widget_pvp/bg/skill icon/Sprite"):GetComponent("UISprite")
    _ui.skillUp_pvp.nameLabel = transform:Find("skill up widget_pvp/bg/skill name"):GetComponent("UILabel")
    _ui.skillUp_pvp.levelLabel = transform:Find("skill up widget_pvp/bg/skill level"):GetComponent("UILabel")
    _ui.skillUp_pvp.effect = transform:Find("skill up widget_pvp/bg/skill level/SkillLvUp")
    _ui.skillUp_pvp.bg.gameObject:SetActive(false)
    _ui.skillUp_pvp.effect.gameObject:SetActive(false)
    _ui.skillUp_pvp.starList = {}
    for i = 1, 6 do
        _ui.skillUp_pvp.starList[i] = transform:Find(string.format("skill up widget_pvp/bg/skill icon/star/%dstars", i))
    end

    _ui.skillUp_passive = {}
    _ui.skillUp_passive.bg = transform:Find("skill up widget_six")
    _ui.skillUp_passive.icon = transform:Find("skill up widget_six/bg/skill icon"):GetComponent("UITexture")
    _ui.skillUp_passive.bgSprite = transform:Find("skill up widget_six/bg/skill icon/Sprite"):GetComponent("UISprite")
    _ui.skillUp_passive.nameLabel = transform:Find("skill up widget_six/bg/skill name"):GetComponent("UILabel")
    _ui.skillUp_passive.levelLabel = transform:Find("skill up widget_six/bg/skill level"):GetComponent("UILabel")
    _ui.skillUp_passive.effect = transform:Find("skill up widget_six/bg/skill level/SkillLvUp")
    _ui.skillUp_passive.bg.gameObject:SetActive(false)
    _ui.skillUp_passive.effect.gameObject:SetActive(false)
    _ui.skillUp_passive.starList = {}
    for i = 1, 6 do
        _ui.skillUp_passive.starList[i] = transform:Find(string.format("skill up widget_six/bg/skill icon/star/%dstars", i))
    end

    _ui.starEffect = transform:Find("NeoStarUp")
    _ui.starEffect.gameObject:SetActive(false)
    
    LoadUI()
end

function Close()
    if _ui.closeCallback then
        _ui.closeCallback()
    end
    
    coroutine.stop(_ui.skillUpCoroutine)
    _ui = nil
end

function Show(oldMsg, newMsg, closeCallback)
    if not IsInViewport() then
        oldHeroMsg = oldMsg
        newHeroMsg = newMsg

        _ui = {}
        _ui.closeCallback = closeCallback

        Global.OpenUI(_M)
    end
end
