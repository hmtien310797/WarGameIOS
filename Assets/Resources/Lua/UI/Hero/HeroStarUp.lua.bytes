module("HeroStarUp", package.seeall)

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

function LoadUI()
    oldHeroData = TableMgr:GetHeroData(oldHeroMsg.baseid)
    newHeroData = TableMgr:GetHeroData(newHeroMsg.baseid)
    HeroInfo.LoadHeadPage(_ui.headPage, newHeroMsg, newHeroData)

    local alist = {}
    alist[1] = HeroListData.GetAttrList(oldHeroMsg, oldHeroData)
    alist[2] = HeroListData.GetAttrList(newHeroMsg, newHeroData)

    local attrIndex = 1
    for k, v in kpairs(alist[2]) do
        local attr = _ui.attrList[attrIndex]
        attr.nameLabel.gameObject:SetActive(true)
        attr.nameLabel.text = TextMgr:GetText(v.data.unlockedText)
        attr.valueLabel[2].text = Global.GetHeroAttrValueString(v.data.additionAttr, v.value)
        attr.valueLabel[2].gameObject:SetActive(true)
        local v1 = alist[1][k]
        attr.valueLabel[1].text = Global.GetHeroAttrValueString(v1.data.additionAttr, v1.value)
        attr.valueLabel[1].gameObject:SetActive(true)

        attrIndex = attrIndex + 1
    end

    for i = attrIndex, HeroListData.MaxAttrCount do
        local attr = _ui.attrList[i]
        attr.nameLabel.gameObject:SetActive(false)
        attr.valueLabel[1].gameObject:SetActive(false)
        attr.valueLabel[2].gameObject:SetActive(false)
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
        _ui.skillUp.bgSprite.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
        _ui.skillUp.nameLabel.text = TextMgr:GetText(skillData.name)
        _ui.skillUp.levelLabel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg.level)
        Global.SetNumber(_ui.skillUp.starList, skillMsg.level)
    end
    if newHeroMsg.skill.godSkill.level ~= oldHeroMsg.skill.godSkill.level then
        coroutine.stop(_ui.skillUpCoroutine)
        _ui.skillUpCoroutine = coroutine.start(function()
            coroutine.wait(EFFECT_DELAY5)
            _ui.skillUp.bg.gameObject:SetActive(true)
            LoadSkill(oldHeroMsg)
            coroutine.wait(EFFECT_DELAY7)
            _ui.skillUp.effect.gameObject:SetActive(true)
            LoadSkill(newHeroMsg)
        end)
    end
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
    _ui = {}
    _ui.heroUI = {}
    _ui.starList = {}
    _ui.nextStarList = {}
    local closeBtn = transform:Find("Container/close btn"):GetComponent("UIButton")
    local okBtn = transform:Find("ok btn"):GetComponent("UIButton")
    SetClickCallback(closeBtn.gameObject, CloseClickCallback)
    SetClickCallback(okBtn.gameObject, CloseClickCallback)

    _ui.headPage = {}
    local headTransform = transform:Find("head widget")
    HeroInfo.LoadHeadPageObject(_ui.headPage, headTransform)
    
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
    for i = 1, HeroListData.MaxAttrCount do
        _ui.attrList[i] = {}
        _ui.attrList[i].nameLabel = transform:Find(string.format("Container/info bg/quality%d", i)):GetComponent("UILabel")
        _ui.attrList[i].valueLabel = {}
        for j = 1, 2 do
            _ui.attrList[i].valueLabel[j] = transform:Find(string.format("Container/info bg/quality%d/lv num%d", i, j)):GetComponent("UILabel")
        end
        local attrEffect = transform:Find(string.format("Container/info bg/quality%d/HeroAUp", i))
        local attrTweener = transform:Find(string.format("Container/info bg/quality%d", i)):GetComponent("UITweener")
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
    _ui.starEffect = transform:Find("NeoStarUp")
    _ui.starEffect.gameObject:SetActive(false)
    LoadUI()
end

function Close()
    coroutine.stop(_ui.skillUpCoroutine)
    _ui = nil
end

function Show(oldMsg, newMsg)
    oldHeroMsg = oldMsg
    newHeroMsg = newMsg
    Global.OpenUI(_M)
end
