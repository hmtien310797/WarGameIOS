module("HeroInfo", package.seeall)

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
local GetHeroAttrValueString = Global.GetHeroAttrValueString
local LoadHero = HeroList.LoadHero
local AudioMgr = Global.GAudioMgr

local isHero
local isPreview
local heroUid
local heroBaseId
local heroMsg
local heroData

local _ui = nil

local baseAdditionList =
{
    {10000, 6},
    {10000, 3},
    {0, 1102},
}

local skillColorList = {"", "", "_b", "_v", "_o"}
function GetSkillSpriteNameByHeroQuality(quality)
    return "btn_skill" .. skillColorList[quality]
end
local pskillColorList = {"", "1", "2", "3", "4"}
function GetPSkillSpriteNameByHeroQuality(quality)
    return "btn_pskill" .. pskillColorList[quality]
end

function IsBaseAddition(needTextData)
    for _, v in ipairs(baseAdditionList) do
        if needTextData.additionArmy == v[1] and needTextData.additionAttr == v[2] then
            return true
        end
    end
    return false
end

function GetBadgeMsg(heroMsg, badgeId)
    for _, v in ipairs(heroMsg.badge) do
        if v.baseid == badgeId then
            return v
        end
    end
end

local function LoadAttrPage()
    _ui.gradeSprite.spriteName = "advanced_"..heroMsg.heroGrade
    local attrList, badgeList = HeroListData.GetAttrBadgeList(heroMsg, heroData)
    local baseAttrIndex = 1
    local additionAttrIndex = 1
    for _, v in kpairs(attrList) do
        local needTextData = v.data
        if IsBaseAddition(needTextData) then
            local attr = _ui.attrPage.baseAttr[baseAttrIndex]
            attr.nameLabel.text = TextMgr:GetText(v.data.unlockedText)
            attr.valueLabel.text = GetHeroAttrValueString(v.data.additionAttr, v.value)
            baseAttrIndex = baseAttrIndex + 1
        else
            local attr = _ui.attrPage.additionAttr[additionAttrIndex]
            attr.nameLabel.text = TextMgr:GetText(v.data.unlockedText)
            attr.valueLabel.text = GetHeroAttrValueString(v.data.additionAttr, v.value)
            attr.nameLabel.gameObject:SetActive(true)
            attr.valueLabel.gameObject:SetActive(true)
            additionAttrIndex = additionAttrIndex + 1
        end
    end
    for i = additionAttrIndex, 4 do
        local attr = _ui.attrPage.additionAttr[i]
        attr.nameLabel.gameObject:SetActive(false)
        attr.valueLabel.gameObject:SetActive(false)
    end

    local canGradeUpgrade = HeroListData.CanGradeUpgrade(heroMsg, badgeList) and isHero
    _ui.gradeButton.isEnabled = canGradeUpgrade
    _ui.canGradeUpgradeEffect:SetActive(canGradeUpgrade)

    HeroList.LoadBadgeList(_ui.attrPage.badgeList, badgeList)
end

function OnUICameraClick4PS(go)
    _ui.skillPage.desRoot.gameObject:SetActive(false)
end

function OnUICameraDragStart4PS(go, delta)
    _ui.skillPage.desRoot.gameObject:SetActive(false)
end

local function AddPSkillItem(pskilldata,itemPrefab,root)
    local item = NGUITools.AddChild(itemPrefab,root)
    item:SetActive(true)
    local namelable = item.transform:Find("Pskill name1"):GetComponent("UILabel")
    namelable.text = TextMgr:GetText(pskilldata.SkillName)
    local deslable = item.transform:Find("pskill des1"):GetComponent("UILabel")
    deslable.text = String.Format(TextMgr:GetText(pskilldata.SkillDes), math.floor((pskilldata.DefaultValue1+( heroMsg.level-1)*pskilldata.GrowValue1)*10)*0.1)
    local icon = item.transform:Find("pskill icon1"):GetComponent("UITexture")
    icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", pskilldata.SkillIcon)
    local bgSprite = item.transform:Find("pskill icon1/Sprite"):GetComponent("UISprite")
    bgSprite.spriteName = GetPSkillSpriteNameByHeroQuality(heroData.quality)
end


local function LoadSkillPage()
    local skillMsg = heroMsg.skill.godSkill
    local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
    _ui.skillPage.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
    _ui.skillPage.bgSprite.spriteName = GetSkillSpriteNameByHeroQuality(heroData.quality)
    _ui.skillPage.nameLabel.text = TextMgr:GetText(skillData.name)
    _ui.skillPage.levelLabel.text = String.Format(TextMgr:GetText(Text.hero_skill_lv), skillMsg.level) 
    Global.SetNumber(_ui.skillPage.starList, skillMsg.level)
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
    _ui.skillPage.descriptionList[1].text = String.Format(TextMgr:GetText(skillData.longDescription), arg0, arg1, arg2, arg3, arg4)
    for i = 2, 6 do
        local skillData = TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, i)
        if skillData ~= nil then
            _ui.skillPage.descriptionList[i].gameObject:SetActive(true)
            if skillData.levelDescription ~= "NA" then
                _ui.skillPage.descriptionList[i].text = TextMgr:GetText(skillData.levelDescription)
                if i > skillMsg.level then
                    _ui.skillPage.descriptionList[i].color = Color.gray
                elseif i == skillMsg.level then
                    _ui.skillPage.descriptionList[i].color = Color.green
                else
                    _ui.skillPage.descriptionList[i].color = Color.white
                end
            else
                _ui.skillPage.descriptionList[i].text = ""
            end
        else
            _ui.skillPage.descriptionList[i].gameObject:SetActive(false)
        end
    end

    --被动技能

    _ui.skillPage.desRoot.gameObject:SetActive(false)
    _ui.skillPage.PSkill_None.gameObject:SetActive(false)
    SetClickCallback(_ui.skillPage.desBtn.gameObject, function()
        _ui.skillPage.desRoot.gameObject:SetActive(not _ui.skillPage.desRoot.gameObject.activeSelf)
    end)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)
    _ui.skillPage.desBtn.gameObject:SetActive(not heroData.expCard)

    for i =1, _ui.skillPage.PSkills_Grid.transform.childCount do
        local obj = _ui.skillPage.PSkills_Grid.transform:GetChild(i-1).gameObject
        obj:SetActive(false)
        GameObject.Destroy( obj)
    end

    local spskills = string.split(heroData.showpassiveskill,';')
    local hadps = true
    if spskills ~= nil then
        for i=1,#(spskills) do
            local id = tonumber(spskills[i])
            if id ~= nil then
                hadps = false
                local pskilldata = TableMgr:GetPassiveSkillData(id)
                AddPSkillItem(pskilldata,_ui.skillPage.PSkills_Grid.gameObject,_ui.skillPage.PSkill_Item.gameObject)
            end
        end
        _ui.skillPage.PSkills_Grid.repositionNow = true
        --_ui.skillPage.PSkills_Grid:Reposition()
    end
    _ui.skillPage.PSkill_None.gameObject:SetActive(hadps)
end

local function LoadDescriptionPage()
    --_ui.descriptionPage.descriptionLabel.text = TextMgr:GetText(heroData.biography)
    _ui.descriptionPage.nameLabel.text = TextMgr:GetText(heroData.nameLabel)
    _ui.descriptionPage.bornLabel.text = TextMgr:GetText(heroData.born)
    _ui.descriptionPage.deathLabel.text = TextMgr:GetText(heroData.death)
    _ui.descriptionPage.nationLabel.text = TextMgr:GetText(heroData.allegiance)
    _ui.descriptionPage.rankLabel.text = TextMgr:GetText(heroData.rank)
    _ui.descriptionPage.battleLabel.text = TextMgr:GetText(heroData.battles)
    _ui.descriptionPage.desExpLabel.text = TextMgr:GetText(heroData.biography)

    _ui.moreBtn.gameObject:SetActive(not heroData.expCard)
    _ui.descriptionPage.desSVTrf.gameObject:SetActive(not heroData.expCard)
    _ui.descriptionPage.desExpTrf.gameObject:SetActive(heroData.expCard)

    _ui.descriptionPage.desSVTrf:GetComponent("UIScrollView"):ResetPosition()
end

function LoadHeadPage(headPage, _heroMsg, _heroData)
    LoadHero(headPage, _heroMsg, _heroData)
    headPage.power.gameObject:SetActive(true)
    headPage.powerLabel.text = math.floor(GeneralData.GetPower(_heroMsg)) -- HeroListData.GetPower(_heroMsg, _heroData)
end

function LoadUI()
    if _ui == nil then
        return
    end
    _ui.pieceButton.gameObject:SetActive(isHero)
    if isHero then
        _ui.headPage.transform.localPosition = Vector3(-257, -42, 0)
        heroMsg = HeroListData.GetHeroDataByUid(heroUid)
        heroData = TableMgr:GetHeroData(heroMsg.baseid)
        _ui.leftBtn.gameObject:SetActive(HeroListData.GetPreviousHeroData(heroMsg.uid) ~= nil)
        _ui.rightBtn.gameObject:SetActive(HeroListData.GetNextHeroData(heroMsg.uid) ~= nil)
        _ui.headPage.starNotice.gameObject:SetActive(HeroListData.IsRecommendStarUp(heroMsg, heroData))
        _ui.headPage.levelNotice.gameObject:SetActive(HeroListData.IsRecommendLevelUp(heroMsg, heroData))

        local rulesData = TableMgr:GetRulesDataByStarGrade(heroMsg.star, heroMsg.grade)
        local itemMsg = ItemListData.GetItemDataByBaseId(heroData.chipID)
        local canStarUp = itemMsg ~= nil and itemMsg.number >= rulesData.num
        UIUtil.SetBtnEnable(_ui.starButton, "btn_2", "btn_4", canStarUp)
        local oldHeroMsg = heroMsg
        SetClickCallback(_ui.starButton.gameObject, function(go)
            if canStarUp then
                local req = HeroMsg_pb.MsgHeroStarUpRequest()
                req.heroUid = heroMsg.uid
                local piece = req.piece:add()
                piece.uid = itemMsg.uniqueid
                piece.num = rulesData.num
                Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroStarUpRequest, req, HeroMsg_pb.MsgHeroStarUpResponse, function(msg)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.ShowError(msg.code)
                    else
                        MainCityUI.UpdateRewardData(msg.fresh)
                        HeroList.LoadUI()
                        HeroInfo.LoadUI()
                        local newHeroMsg = HeroListData.GetHeroDataByUid(heroMsg.uid)
                        HeroStarUp.Show(oldHeroMsg, newHeroMsg)
                    end
                end)
            else
                FloatText.Show(TextMgr:GetText(Text.noMoreHeroPiece))
            end

        end)
        SetClickCallback(_ui.levelButton.gameObject, function(go)
            Hide()
            HeroUpgrade.Show(heroMsg.uid)
        end)
    elseif isPreview then
        _ui.headPage.transform.localPosition = Vector3(-257, -80, 0)
        local hero, heroIndex, isLast = Preview.GetIllustrateHero(heroBaseId)
        heroMsg = hero.msg
        heroData = hero.data

        _ui.leftBtn.gameObject:SetActive(heroIndex ~= 1)
        _ui.rightBtn.gameObject:SetActive(not isLast)
        _ui.headPage.power.gameObject:SetActive(false)
    else
        _ui.headPage.transform.localPosition = Vector3(-257, -80, 0)
        local hero, heroIndex, isLast = HeroList.GetIllustrateHero(heroBaseId)
        heroMsg = hero.msg
        heroData = hero.data

        _ui.leftBtn.gameObject:SetActive(heroIndex ~= 1)
        _ui.rightBtn.gameObject:SetActive(not isLast)
        _ui.headPage.power.gameObject:SetActive(false)
    end

    print("选择英雄，表格Id:", heroMsg.baseid, "uid:", heroMsg.uid)
    LoadHeadPage(_ui.headPage, heroMsg, heroData)
    LoadAttrPage()
    LoadSkillPage()
    LoadDescriptionPage()
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll(ignoreCloseCound)
    if not ignoreCloseCound then
        AudioMgr:PlayUISfx("SFX_UI_interface02_off", 1, false)
    end
    HeroUpgrade.CloseAll()
    BadgeInfo.CloseAll()
    Hide()
end

local function CloseClickCallback(go)
    Hide()
    if not isPreview then
        AudioMgr:PlayUISfx("SFX_UI_interface02_off", 1, false)
        HeroList.Show(isHero and 1 or 2, true)
    else
        Preview.Show()
    end
end

function LoadHeadPageObject(headPage, headTransform)
    headPage.transform = headTransform
    headPage.power = headTransform:Find("combat ")
    headPage.powerLabel = headTransform:Find("combat /text"):GetComponent("UILabel")
    headPage.picture = headTransform:Find("hero half"):GetComponent("UITexture")
	if headTransform:Find("rarity_icon") ~= nil then 
		headPage.rarity = headTransform:Find("rarity_icon"):GetComponent("UISprite")
	end 
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
    headPage.levelLabel = headTransform:Find("level widget/lv text"):GetComponent("UILabel")
    headPage.levelNotice = headTransform:Find("level widget/levelUP btn/red")
    headPage.smallStarList = {}
    local smallStarTransform = headTransform:Find("star widget/small star")
    HeroList.LoadHeroSmallStarObject(headPage.smallStarList, smallStarTransform)
    headPage.skillIcon = headTransform:Find("bg_skill/icon_skill"):GetComponent("UITexture")
    headPage.skillButton = headTransform:Find("bg_skill")
end

function PlayBadgeEffect(badgeId)
    for _, v in ipairs(_ui.attrPage.badgeList) do
        if v.msg.baseid == badgeId then
            v.effect.gameObject:SetActive(false)
            v.effect.gameObject:SetActive(true)
            break
        end
    end
end

function Awake()
    _ui = {}
    _ui.headPage = {}
    _ui.attrPage = {}
    _ui.skillPage = {}
    _ui.descriptionPage = {}
    _ui.toggleList = {}
    for i = 1, 3 do
        local toggle = transform:Find(string.format("Container/bg2/page%d", i)):GetComponent("UIToggle")
        _ui.toggleList[i] = toggle
        EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
            if toggle.value then
                if i ~= 1 then
                    for _, vv in ipairs(_ui.attrPage.badgeList) do
                        vv.effect.gameObject:SetActive(false)
                    end
                end
            end
        end))
    end

    local closeBtn = transform:Find("Container/background widget/close btn"):GetComponent("UIButton")
    local maskbg = transform:Find("mask")
    _ui.leftBtn = transform:Find("Container/background widget/left btn"):GetComponent("UIButton")
    _ui.rightBtn = transform:Find("Container/background widget/right btn"):GetComponent("UIButton")
    SetClickCallback(closeBtn.gameObject, CloseClickCallback)
    SetClickCallback(maskbg.gameObject, CloseClickCallback)

    SetClickCallback(_ui.leftBtn.gameObject, function(go)
        if isHero then
            heroUid = HeroListData.GetPreviousHeroData(heroMsg.uid).uid
        elseif isPreview then
            heroBaseId = Preview.GetPreviousIllustrateHero(heroBaseId).data.id
        else
            heroBaseId = HeroList.GetPreviousIllustrateHero(heroBaseId).data.id
        end
        LoadUI()
    end)

    SetClickCallback(_ui.rightBtn.gameObject, function(go)
        if isHero then
            heroUid = HeroListData.GetNextHeroData(heroMsg.uid).uid
        elseif isPreview then
            heroBaseId = Preview.GetNextIllustrateHero(heroBaseId).data.id
        else
            heroBaseId = HeroList.GetNextIllustrateHero(heroBaseId).data.id
        end
        LoadUI()
    end)

    _ui.gradeUpEffect = transform:Find("Container/bg2/honorup").gameObject
    _ui.gradeUpEffect:SetActive(false)
    _ui.canGradeUpgradeEffect = transform:Find("Container/bg2/content 1/honorloop").gameObject
    _ui.canGradeUpgradeEffect:SetActive(false)

    local headTransform = transform:Find("Container/head widget")
    LoadHeadPageObject(_ui.headPage, headTransform)
    local shardTransform = headTransform:Find("star widget/exp bar")
    _ui.headPage.shardTransform = shardTransform
    _ui.headPage.shardSlider = shardTransform:GetComponent("UISlider")
    _ui.headPage.shardLabel = shardTransform:Find("Label"):GetComponent("UILabel")

    _ui.addButton = headTransform:Find("star widget/exp bar/add btn"):GetComponent("UIButton")
    _ui.starButton = headTransform:Find("star widget/star btn"):GetComponent("UIButton")
    _ui.levelButton = headTransform:Find("level widget/levelUP btn"):GetComponent("UIButton")
    _ui.pieceButton = headTransform:Find("star widget/piece btn"):GetComponent("UIButton")
    _ui.starButton.gameObject:SetActive(isHero)
    _ui.levelButton.gameObject:SetActive(isHero)

    SetClickCallback(_ui.addButton.gameObject, function(go)
        local rulesData = TableMgr:GetRulesDataByStarGrade(heroMsg.star, heroMsg.grade)
        requiredShardCount = rulesData.num
        GatherItemUI.Show(heroData.chipID, requiredShardCount)
    end)

    SetClickCallback(_ui.headPage.skillButton.gameObject, function()
        for i, v in ipairs(_ui.toggleList) do
            v.value = i == 2
        end
    end)

    SetClickCallback(_ui.pieceButton.gameObject, function()
        UniversalPiece.Show(heroMsg)
    end)

    -- 属性
    _ui.attrPage.baseAttr = {}
    for i = 1, 3 do
        _ui.attrPage.baseAttr[i] = {}
        _ui.attrPage.baseAttr[i].nameLabel = transform:Find(string.format("Container/bg2/content 1/title text1/quality%d", i)):GetComponent("UILabel")
        _ui.attrPage.baseAttr[i].valueLabel = transform:Find(string.format("Container/bg2/content 1/title text1/quality%d/num", i)):GetComponent("UILabel")
    end
    _ui.attrPage.additionAttr = {}
    for i = 1, HeroListData.MaxAttrCount - 3 do
        _ui.attrPage.additionAttr[i] = {}
        _ui.attrPage.additionAttr[i].nameLabel = transform:Find(string.format("Container/bg2/content 1/title text2/quality%d", i + 3)):GetComponent("UILabel")
        _ui.attrPage.additionAttr[i].valueLabel = transform:Find(string.format("Container/bg2/content 1/title text2/quality%d/num", i + 3)):GetComponent("UILabel")
    end

    _ui.gradeSprite = transform:Find("Container/bg2/content 1/text bg3/advanced bg/icon"):GetComponent("UISprite")
    _ui.gradeButton = transform:Find("Container/bg2/content 1/text bg3/advanced btn"):GetComponent("UIButton")
    if isHero then
        SetClickCallback(_ui.gradeButton.gameObject, function()
            local req = HeroMsg_pb.MsgHeroGradeUpRequest()
            req.heroUid = heroMsg.uid
            req.gradeid = heroMsg.heroGrade + 1
            _ui.gradeUpEffect:SetActive(false)
            local oldHeroMsg = heroMsg
            Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroGradeUpRequest, req, HeroMsg_pb.MsgHeroGradeUpResponse, function(msg)
                _ui.gradeUpEffect:SetActive(true)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.ShowError(msg.code)
                else
                    MainCityUI.UpdateRewardData(msg.fresh)
                    LoadUI()
                    local newHeroMsg = HeroListData.GetHeroDataByUid(heroMsg.uid)
                    local oldHeroData = TableMgr:GetHeroData(oldHeroMsg.baseid)
                    local newHeroData = TableMgr:GetHeroData(newHeroMsg.baseid)

                    local alist = {}
                    alist[1] = HeroListData.GetAttrList(oldHeroMsg, oldHeroData)
                    alist[2] = HeroListData.GetAttrList(newHeroMsg, newHeroData)

                    coroutine.stop(_ui.gradeUpCoroutine)
                    _ui.gradeUpCoroutine = coroutine.start(function()
                        for k, v in kpairs(alist[2]) do
                            local v1 = alist[1][k]
                            local nameText = TextMgr:GetText(v.data.unlockedText)
                            local valueText = Global.GetHeroAttrValueString(v.data.additionAttr, v.value - v1.value)
                            if _ui == nil then
                                return
                            end
                            FloatText.ShowOn(_ui.gradeButton.gameObject, nameText .. valueText, Color.green)
                            coroutine.wait(0.25)
                        end
                    end)
                end
            end)
        end)
    end
    local badgeList = {}
    local badgeBg = transform:Find("Container/bg2/content 1/medal wtdget")
    HeroList.LoadBadgeObjectList(badgeList, badgeBg)
    _ui.attrPage.badgeList = badgeList
    if isHero then
        for i, v in ipairs(badgeList) do
            SetClickCallback(v.btn.gameObject, function(go)
                CloseAll(true)
                BadgeInfo.Show(heroMsg.uid, i)
            end)
            SetClickCallback(v.lock.gameObject, function(go)
                CloseAll(true)
                BadgeInfo.Show(heroMsg.uid, i)
            end)
        end
    end


    -- 技能
    _ui.skillPage.icon = transform:Find("Container/bg2/content 2/skill icon"):GetComponent("UITexture")
    _ui.skillPage.bgSprite = transform:Find("Container/bg2/content 2/skill icon/Sprite"):GetComponent("UISprite")
    _ui.skillPage.nameLabel = transform:Find("Container/bg2/content 2/skill name"):GetComponent("UILabel")
    _ui.skillPage.levelLabel = transform:Find("Container/bg2/content 2/skill level"):GetComponent("UILabel")
    _ui.skillPage.desRoot = transform:Find("Container/bg2/content 2/effect")
    _ui.skillPage.desBtn = transform:Find("Container/bg2/content 2/skill name/info")
    _ui.skillPage.descriptionList = {}
    _ui.skillPage.starList = {}
    for i = 1, 6 do
        _ui.skillPage.starList[i] = transform:Find(string.format("Container/bg2/content 2/skill icon/star/%dstars", i)) 
    end
    _ui.skillPage.descriptionList[1] = transform:Find(string.format("Container/bg2/content 2/skill des lv1", i)):GetComponent("UILabel")
    for i = 2, 6 do
        _ui.skillPage.descriptionList[i] = transform:Find(string.format("Container/bg2/content 2/effect/skill des lv%d", i)):GetComponent("UILabel")
    end

    --被动技能
    _ui.skillPage.PSkills_Grid = transform:Find("Container/bg2/content 2/Pskills/Grid"):GetComponent("UIGrid")
    _ui.skillPage.PSkill_Item = transform:Find("Container/bg2/content 2/item_Pskill")
    _ui.skillPage.PSkill_None = transform:Find("Container/bg2/content 2/none")

    AddDelegate(UICamera, "onClick", OnUICameraClick4PS)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart4PS)

    -- 简介
    -- _ui.descriptionPage.descriptionLabel = transform:Find("Container/bg2/content 3/Scroll View/content text"):GetComponent("UILabel")
    _ui.descriptionPage.desExpTrf = transform:Find("Container/bg2/content 3/EXP")
    _ui.descriptionPage.desExpLabel = transform:Find("Container/bg2/content 3/EXP"):GetComponent("UILabel")
    _ui.descriptionPage.desSVTrf = transform:Find("Container/bg2/content 3/Scroll View")
    _ui.descriptionPage.nameLabel = transform:Find("Container/bg2/content 3/Scroll View/Grid/name/content"):GetComponent("UILabel")
    _ui.descriptionPage.bornLabel = transform:Find("Container/bg2/content 3/Scroll View/Grid/DOB/content"):GetComponent("UILabel")
    _ui.descriptionPage.deathLabel = transform:Find("Container/bg2/content 3/Scroll View/Grid/death/content"):GetComponent("UILabel")
    _ui.descriptionPage.nationLabel = transform:Find("Container/bg2/content 3/Scroll View/Grid/nation/content"):GetComponent("UILabel")
    _ui.descriptionPage.rankLabel = transform:Find("Container/bg2/content 3/Scroll View/Grid/rank/content"):GetComponent("UILabel")
    _ui.descriptionPage.battleLabel = transform:Find("Container/bg2/content 3/Scroll View/Grid/battle/content"):GetComponent("UILabel")
    _ui.moreBtn = transform:Find("Container/bg2/content 3/more"):GetComponent("UIButton")

    SetClickCallback(_ui.moreBtn.gameObject, function(go)
        UnityEngine.Application.OpenURL(heroData.biourl)
    end)

    HeroListData.AddListener(LoadUI)
    ItemListData.AddListener(LoadUI)
    LoadUI()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick4PS)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart4PS)    
    HeroListData.RemoveListener(LoadUI)
    ItemListData.RemoveListener(LoadUI)
    coroutine.stop(_ui.gradeUpCoroutine)
    _ui = nil
end

function Show(uid, baseId, ignoreOpenSound)
    if not ignoreOpenSound then
        AudioMgr:PlayUISfx("SFX_UI_interface02_on", 1, false)
    end
    heroUid = uid
    heroBaseId = baseId
    local heroData = TableMgr:GetHeroData(baseId)
    isHero = heroUid > 0
    isPreview = heroUid == -1
    Global.OpenUI(_M)
end
