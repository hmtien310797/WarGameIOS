module("HeroInfoNew", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local DEFAULT_TAB = 1
local DEFAULT_TAB_ILLUSTRATION = 3
local NUM_PASSIVE_SKILLS = 6
local TEXTURE_NAMES_BY_QUALITY = { [1] = "card_white_bg",
                                   [2] = "card_green_bg",
                                   [3] = "card_bule_bg",
                                   [4] = "card_purple_bg",
                                   [5] = "card_orange_bg", }
local BUTTON_REPEAT_DELAY = 0.5
local BUTTON_REPEAT_INTERVAL = 0.1
local FX_PASSIVESKILLS = { LEVEL_UP = 1 , UNLOCK = 2 }
local FX_EXPBAR = { INCREASE_EXP = 1 , LEVEL_MAX = 2 }

local ui
local enableChaneView
local currentTab
local currentGeneral

function EnableChangeView(enable)
	enableChaneView = enable
end

function IsInViewport()
    return ui ~= nil
end

function IsIllustration()
    return currentGeneral.heroInfo.uid == 0
end

local function UpdateGeneralTableData()
    local heroInfo = currentGeneral.heroInfo

    currentGeneral.heroData = TableMgr:GetHeroData(heroInfo.baseid)
    currentGeneral.heroGradeUpData = TableMgr:GetHeroGradeUpDataByHeroIdGrade(heroInfo.baseid, heroInfo.heroGrade)
    currentGeneral.heroRule = TableMgr:GetRulesDataByStarGrade(heroInfo.star, heroInfo.grade)

    currentGeneral.pveSkillData = TableMgr:GetGodSkillDataByIdLevel(heroInfo.skill.godSkill.id, heroInfo.skill.godSkill.level)
    currentGeneral.pvpSkillData = TableMgr:GetGeneralPvpSkillData(heroInfo)
    
    currentGeneral.passiveSkillDatas = {}
    for stringID in string.gsplit(currentGeneral.heroData.showpassiveskill, ";") do
        local skillId = tonumber(stringID)
        if skillId ~= 0 then
            table.insert(currentGeneral.passiveSkillDatas, TableMgr:GetPassiveSkillData(skillId))
        else
            table.insert(currentGeneral.passiveSkillDatas, skillId)
        end
    end

    currentGeneral.badgeMaterials = {}
    for s in string.gsplit(currentGeneral.heroGradeUpData.needItem, ";") do
        local badgeMaterial = {}

        local ints = table.map(string.split(s, ":"), tonumber)

        local itemBaseID = tonumber(ints[1])
        badgeMaterial.itemData = TableMgr:GetItemData(itemBaseID)
        badgeMaterial.itemConvertData = TableMgr:GetItemConvertData(itemBaseID)
        badgeMaterial.numNeeded = tonumber(ints[2])

        table.insert(currentGeneral.badgeMaterials, badgeMaterial)
    end
end

local function SetCurrentGeneral(heroInfo)
    currentGeneral.heroInfo = heroInfo
    UpdateGeneralTableData()
end

local function SetCurrentTab(tab)
    currentTab = tab
end

local function UpdateGeneralLevel()
    local heroLevel = currentGeneral.heroInfo.level

    ui.left.summary.level.text = heroLevel

    local uiTab1 = ui.right.tabs[1]
    uiTab1.levelUp.currentLevel.text = "Lv." .. heroLevel
end

local function UpdateGeneralExp()
    local heroInfo = currentGeneral.heroInfo

    local uiTab1 = ui.right.tabs[1]

    if heroInfo.level < 80 then
        local requiredExp_currentLevel = (heroInfo.level - 1 > 0 and TableMgr:GetHeroExpData(heroInfo.level - 1).exp or 0)
        local requiredExp = TableMgr:GetHeroExpData(heroInfo.level).exp - requiredExp_currentLevel
        local currentExp = heroInfo.exp - requiredExp_currentLevel

        uiTab1.levelUp.expBar.value = currentExp / requiredExp
        uiTab1.levelUp.currentExp.text = string.make_fraction(currentExp, requiredExp)
    else
        uiTab1.levelUp.expBar.value = 1
        uiTab1.levelUp.currentExp.text = ""
    end
end

local function UpdateGeneralStar()
    local heroInfo = currentGeneral.heroInfo

    local star = heroInfo.star
    local smallStar = heroInfo.grade

    UIUtil.UpdateStarDisplay(ui.left.stars, star, smallStar)
    UIUtil.UpdateStarDisplay(ui.right.tabs[2].top.stars, star, smallStar)
end

local function UpdateGeneralGrade()
    local heroGrade = currentGeneral.heroInfo.heroGrade

    local uiTab1 = ui.right.tabs[1]

    uiTab1.gradeUp.badge.icon.spriteName = "advanced_" .. heroGrade

    uiTab1.gradeUp.tips_levelRequirement.text = System.String.Format(TextMgr:GetText("badgeInfo_need_level"), currentGeneral.heroGradeUpData.unlockLevel)
end

local function UpdateGeneralAttributes()
    local heroInfo = currentGeneral.heroInfo
    local heroData = currentGeneral.heroData

    local attributes = GeneralData.GetAttributes(heroInfo)[0]

    ui.left.summary.power.text = math.floor(GeneralData.GetPower(currentGeneral.heroInfo))
    ui.left.summary.soldierObject:SetActive(Global.IsOutSea())
    ui.left.summary.soldier.text = attributes[1102]

    for attributeIndex = 1, 4 do
        ui.left.basicAttributes[attributeIndex].text = string.format("%.1f", attributes[Global.GetAttributeLongID(heroData["additionArmy" .. attributeIndex], heroData["additionAttr" .. attributeIndex])])
    end

    local uiTab2 = ui.right.tabs[2]

    if heroInfo.star < 6 then
        local heroInfo_afterStarUp = GeneralData.Duplicate(heroInfo)

        if heroInfo.grade + 1 > heroInfo.star then
            heroInfo_afterStarUp.star = heroInfo.star + 1
            heroInfo_afterStarUp.grade = 1
        else
            heroInfo_afterStarUp.star = heroInfo.star
            heroInfo_afterStarUp.grade = heroInfo.grade + 1
        end

        local attributes_afterStarUp = GeneralData.GetAttributes(heroInfo_afterStarUp)[0]

        for i, uiAttribute in ipairs(uiTab2.bottom.attributeList.attributes) do
            if i == 1 then
                uiAttribute.currentValue.text = currentGeneral.heroRule.maxlevel
                uiAttribute.nextValue.text = TableMgr:GetRulesDataByStarGrade(heroInfo_afterStarUp.star, heroInfo_afterStarUp.grade).maxlevel
            else
                local attributeIndex = tonumber(uiAttribute.gameObject.name)

                local attributeType = heroData["additionAttr" .. attributeIndex]
                local attributeID = Global.GetAttributeLongID(heroData["additionArmy" .. attributeIndex], attributeType)

                uiAttribute.currentValue.text = Global.GetHeroAttrValueString(attributeType, attributes[attributeID])
                uiAttribute.nextValue.text = Global.GetHeroAttrValueString(attributeType, attributes_afterStarUp[attributeID])
            end
        end

        local isNotIllustration = heroInfo.uid ~= 0
        uiTab2.top.btn_starUp.isEnabled = isNotIllustration
        uiTab2.top.btn_universalShard.isEnabled = isNotIllustration
    else
        for i, uiAttribute in ipairs(uiTab2.bottom.attributeList.attributes) do
            if i == 1 then
                uiAttribute.currentValue.text = currentGeneral.heroRule.maxlevel
                uiAttribute.nextValue.text = "MAX"
            else
                local attributeIndex = tonumber(uiAttribute.gameObject.name)

                local attributeType = heroData["additionAttr" .. attributeIndex]
                local attributeID = Global.GetAttributeLongID(heroData["additionArmy" .. attributeIndex], attributeType)

                uiAttribute.currentValue.text = Global.GetHeroAttrValueString(attributeType, attributes[attributeID])
                uiAttribute.nextValue.text = "MAX"
            end
        end

        uiTab2.top.btn_starUp.isEnabled = false
    end
end

local function UpdateGeneralPassiveSkills()
    local heroInfo = currentGeneral.heroInfo
    for i, passiveSkillData in ipairs(currentGeneral.passiveSkillDatas) do
        local uiPassiveSkill = ui.left.passiveSkills[i]
        uiPassiveSkill.gameObject:SetActive(passiveSkillData ~= 0)
        if passiveSkillData ~= 0 then
            if i > heroInfo.star then
                uiPassiveSkill.lock:SetActive(true)
                uiPassiveSkill.frame.color = Color.gray
                uiPassiveSkill.icon.color = Color.gray
            else
                uiPassiveSkill.lock:SetActive(false)
                uiPassiveSkill.frame.color = Color.white
                uiPassiveSkill.icon.color = Color.white
            end
            uiPassiveSkill.name.text = TextMgr:GetText(passiveSkillData.SkillName)
            uiPassiveSkill.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", passiveSkillData.SkillIcon)
            local skillQuality = 1

            local skillMsg
            for __, vv in ipairs(heroInfo.skill.passiveSkill) do
                if vv.id == passiveSkillData.id then
                    skillMsg = vv
                    break
                end
            end

            if heroInfo.uid ~= 0 and skillMsg ~= nil then
                local skillLevel = skillMsg.level
                local levelUpId = passiveSkillData.SkillLvlupType * 1000 + skillLevel
                local levelUpData = tableData_tPassiveskillLevelUp.data[levelUpId]
                skillQuality = levelUpData.SkillQuality
                uiPassiveSkill.levelBgObject.gameObject:SetActive(true)
                uiPassiveSkill.levelLabel.text = System.String.Format(TextMgr:GetText(Text.Level_ui), skillLevel)
            else
                uiPassiveSkill.levelBgObject.gameObject:SetActive(false)
            end

            uiPassiveSkill.frame.spriteName = "bg_skill_" .. skillQuality
            UIUtil.SetClickCallback(uiPassiveSkill.frame.gameObject, function(go)
                if i > heroInfo.star or heroInfo.uid == 0 then
                    if go == ui.tipObject then
                        ui.tipObject = nil
                    else
                        ui.tipObject = go
                        Tooltip.ShowPassiveSkill(heroInfo, i)
                    end
                else
                    HeroSkillLevelup.Show(heroInfo.uid, i)
                end
                for j, passiveSkillData in ipairs(currentGeneral.passiveSkillDatas) do
                    local uiPassiveSkill = ui.left.passiveSkills[j]
                    uiPassiveSkill.selectObject:SetActive(j <= heroInfo.star and j == i)
                end
            end)
        end
    end
    ui.left.passiveSkills.grid.repositionNow = true
end

function UnselectPassiveSkill()
    if ui == nil then
        return
    end

    local heroInfo = currentGeneral.heroInfo
    for j, passiveSkillData in ipairs(currentGeneral.passiveSkillDatas) do
        local uiPassiveSkill = ui.left.passiveSkills[j]
        uiPassiveSkill.selectObject:SetActive(j <= heroInfo.star and j == i)
    end
end

local function UpdateGeneralPvpSkill()
    local heroLevel = currentGeneral.heroInfo.level
    local skillData = currentGeneral.pvpSkillData

    local uiSkill = ui.right.tabs[3].pvp

    UIUtil.UpdateStarDisplay(uiSkill.stars, skillData.level, 1)

    local growValueList = table.map(string.split(skillData.skillvalue, ","), tonumber)

    local growValue1 = math.abs(growValueList[1] * heroLevel * heroLevel + growValueList[2] * heroLevel + growValueList[3]) 
    if growValue1 ~= 0 then
        growValue1 = string.make_percent(100 * growValue1);
    else
        growValue1 = "0%"
    end
    local growValue2 = 0
    if #growValueList == 6 then
        growValue2 = math.abs(growValueList[4] * heroLevel * heroLevel + growValueList[5] * heroLevel + growValueList[6]) 
    end


    uiSkill.description.text = System.String.Format(TextMgr:GetText(skillData.longDescription),growValue1,growValue2 )

    if skillData.level < 6 then
        local skillData_nextLevel = TableMgr:GetPvpSkillDataByIdLevel(skillData.SLGskillId, skillData.level + 1)

        local growValueList_nextLevel = table.map(string.split(skillData_nextLevel.skillvalue, ","), tonumber)
        local growValuenextLevel1 = math.abs(growValueList_nextLevel[1] * heroLevel * heroLevel + growValueList_nextLevel[2] * heroLevel + growValueList_nextLevel[3]) 
        if growValuenextLevel1 ~= 0 then
            growValuenextLevel1 = string.make_percent(100 * growValuenextLevel1);
        else
            growValuenextLevel1 = "0%"
        end
        local growValuenextLevel2 = 0
        if #growValueList_nextLevel == 6 then
            growValuenextLevel2 = math.abs(growValueList_nextLevel[4] * heroLevel * heroLevel + growValueList_nextLevel[5] * heroLevel + growValueList_nextLevel[6]) 
        end 

        uiSkill.details.label.text = System.String.Format(TextMgr:GetText(skillData_nextLevel.longDescription), growValuenextLevel1,growValuenextLevel2)
        
        uiSkill.btn_detail:SetActive(true)
    else
        uiSkill.btn_detail:SetActive(false)
    end
end

local function UpdateGeneralPveSkill()
    local heroLevel = currentGeneral.heroInfo.level
    local skillData = currentGeneral.pveSkillData

    local uiSkill = ui.right.tabs[3].pve

    UIUtil.UpdateStarDisplay(uiSkill.stars, skillData.level, 0)

    local value
    if skillData.growValue ~= "NA" then
        local growValueList = table.map(string.split(skillData.growValue, ";"), tonumber)

        value = growValueList[1] * heroLevel * heroLevel + growValueList[2] * heroLevel + growValueList[3]
        value = math.floor(math.abs(value))
    end

    uiSkill.description.text = System.String.Format(TextMgr:GetText(skillData.longDescription), skillData.radius, value, skillData.duration, skillData.cost, skillData.cooldown)

    if skillData.level < 6 then
        local skillData_nextLevel = TableMgr:GetGodSkillDataByIdLevel(skillData.skillId, skillData.level + 1)

        local value_nextLevel
        if skillData_nextLevel.growValue ~= "NA" then
            local growValueList = table.map(string.split(skillData_nextLevel.growValue, ";"), tonumber)

            value_nextLevel = growValueList[1] * heroLevel * heroLevel + growValueList[2] * heroLevel + growValueList[3]
            value_nextLevel = math.floor(math.abs(value_nextLevel))
        end

        uiSkill.details.label.text = System.String.Format(TextMgr:GetText(skillData_nextLevel.longDescription), skillData_nextLevel.radius, value_nextLevel, skillData_nextLevel.duration, skillData_nextLevel.cost, skillData_nextLevel.cooldown)
        
        uiSkill.btn_detail:SetActive(true)
    else
        uiSkill.btn_detail:SetActive(false)
    end
end

local function UpdateGeneralBadgeMaterials()
    local heroInfo = currentGeneral.heroInfo

    local uiTab1 = ui.right.tabs[1]
    local uiItems = uiTab1.gradeUp.items
    for i, uiItem in ipairs(uiItems) do
        local badgeMaterial = currentGeneral.badgeMaterials[i]

        local itemData = badgeMaterial.itemData
        local itemConvertData = badgeMaterial.itemConvertData
        
        uiItem.num = ItemListData.GetItemCountByBaseId(itemData.id)

        uiItem.frame.spriteName = "medal_level_" .. itemData.quality
        uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)

        if heroInfo.uid == 0 then
            uiItem.lock:SetActive(true)
            uiItem.tips_max.gameObject:SetActive(false)
            uiItem.label.gameObject:SetActive(false)
            uiItem.btn_add.gameObject:SetActive(false)
            uiItem.notice:SetActive(false)
        else
            uiItem.lock:SetActive(false)

            if currentGeneral.heroGradeUpData.badgeGrade ~= 0 then
                uiItem.tips_max.gameObject:SetActive(false)

                local numNeeded = badgeMaterial.numNeeded
                if numNeeded > 1 then
                    uiItem.label.gameObject:SetActive(true)
                    uiItem.label.text = string.make_fraction(uiItem.num, numNeeded)
                else
                    uiItem.label.gameObject:SetActive(false)
                end

                if uiItem.num < numNeeded then
                    uiItem.btn_add.gameObject:SetActive(true)

                    local neededItems = string.msplit(itemConvertData.NeedItem, ";", ":")

                    if #neededItems > 0 then
                        local hasEnoughItems = true
                        for _, neededItem in ipairs(neededItems) do
                            if ItemListData.GetItemCountByBaseId(tonumber(neededItem[1])) < tonumber(neededItem[2]) then
                                hasEnoughItems = false
                                break
                            end
                        end

                        uiItem.btn_add.icon.spriteName = hasEnoughItems and "plus_green" or "plus_yellow"
                        uiItem.notice:SetActive(hasEnoughItems)
                    else
                        uiItem.notice:SetActive(false)
                    end
                else
                    uiItem.btn_add.gameObject:SetActive(false)
                    uiItem.notice:SetActive(false)
                end
            else
                uiItem.tips_max.gameObject:SetActive(true)
                uiItem.label.gameObject:SetActive(false)
                uiItem.btn_add.gameObject:SetActive(false)
                uiItem.notice:SetActive(false)
            end
        end
    end
end

local function UpdateGeneralGradeUpLevelRequirement()
    ui.right.tabs[1].gradeUp.tips_levelRequirement.color = currentGeneral.heroInfo.level < currentGeneral.heroGradeUpData.unlockLevel and Color.red or Color.white
end

local function UpdateGeneralShards()
    local uiTab2 = ui.right.tabs[2]
    local ownedShardCount, requiredShardCount = UIUtil.UpdateShardDisplay(uiTab2.top, currentGeneral.heroInfo, currentGeneral.heroData, currentGeneral.heroRule)
    
    local heroInfo = currentGeneral.heroInfo

    local canStarUp = heroInfo.uid ~= 0 and heroInfo.star < 6 and ownedShardCount >= requiredShardCount
    uiTab2.top.btn_starUp.isEnabled = canStarUp
    uiTab2.notice:SetActive(canStarUp)
end

local function UpdateExpItems()
    if not IsIllustration() then
        for _, uiItem in pairs(ui.right.tabs[1].levelUp.expItems) do
            local num = ItemListData.GetItemCountByBaseId(uiItem.itemData.id)

            uiItem.num = num

            if num > 0 then
                uiItem.countLabel.text = num
                uiItem.qualitySprite.color = Color.white
                uiItem.iconTexture.color = Color.white
            else
                uiItem.countLabel.text = ""
                uiItem.qualitySprite.color = Color.gray
                uiItem.iconTexture.color = Color.gray
            end
        end
    else
        for _, uiItem in pairs(ui.right.tabs[1].levelUp.expItems) do
            uiItem.qualitySprite.color = Color.white
            uiItem.iconTexture.color = Color.white
            uiItem.countLabel.text = ""
        end
    end
end

local function UpdateTips(tab)
    if not tab then
        for tab, _ in ipairs(ui.right.tabs) do
            UpdateTips(tab)
        end
    else
        local uiTab = ui.right.tabs[tab]
        if tab == 1 then
            local heroInfo = currentGeneral.heroInfo
            uiTab.levelUp.tips_maxLevel:SetActive(heroInfo.level >= currentGeneral.heroRule.maxlevel)
            uiTab.levelUp.btn_quickLevelUp.isEnabled = heroInfo.uid ~= 0 and heroInfo.level < currentGeneral.heroRule.maxlevel
        end
    end
end

local function UpdateNotice(tab)
    if not tab then
        for tab, _ in ipairs(ui.right.tabs) do
            UpdateNotice(tab)
        end
    else
        local uiTab = ui.right.tabs[tab]
        if tab == 1 then
            local heroInfo = currentGeneral.heroInfo
            if heroInfo.uid ~= 0 and GeneralData.CanGradeUp(heroInfo, currentGeneral.heroGradeUpData , true) then
                uiTab.gradeUp.fx_upgradable:SetActive(true)
                uiTab.gradeUp.badge.boxCollider.enabled = false
            else
                uiTab.gradeUp.fx_upgradable:SetActive(false)
                uiTab.gradeUp.badge.boxCollider.enabled = true
            end

            uiTab.levelUp.notice:SetActive(false)

            if heroInfo.uid ~= 0 and heroInfo.level < currentGeneral.heroRule.maxlevel then
                for _, uiExpItem in pairs(uiTab.levelUp.expItems) do
                    if uiExpItem.num ~= nil then
                        if uiExpItem.num > 0 then
                            uiTab.levelUp.notice:SetActive(true)
                            break
                        end
                    end
                end
            end
                        
            uiTab.notice:SetActive(uiTab.gradeUp.fx_upgradable.activeSelf or uiTab.levelUp.notice.activeSelf)
            for i, passiveSkillData in ipairs(currentGeneral.passiveSkillDatas) do
                local uiPassiveSkill = ui.left.passiveSkills[i]
                uiPassiveSkill.noticeObject:SetActive(GeneralData.CanPassiveSkillUpgrade(heroInfo, i))
            end
        elseif tab == 4 then
            local had_red = false
            for i, v in ipairs(ui.right.tabs[4].equips) do
                if ( HeroEquipData.IsUnlock(i,currentGeneral.heroInfo)) then

                    had_red = HeroEquipData.IsCanUpgradeByPos(i,currentGeneral.heroInfo)
                    if had_red then
                        break;
                    end
                end
            end
            uiTab.notice:SetActive(had_red)
        end
    end
end

local function UpdateUI()
    UpdateGeneralLevel()
    UpdateGeneralExp()
    UpdateGeneralStar()
    UpdateGeneralGrade()
    HeroUpdateEquip()
    UpdateGeneralAttributes()
    UpdateGeneralPassiveSkills()
    UpdateGeneralPvpSkill()
    UpdateGeneralPveSkill()

    UpdateGeneralBadgeMaterials()
    UpdateGeneralGradeUpLevelRequirement()
    UpdateGeneralShards()

    UpdateTips()
    UpdateNotice()
    
end

local function StopFxOnGeneralBasicAttributes()
    if ui == nil then
        return
    end

    coroutine.stop(ui.fxCoroutines.basicAttributes)
    
    ui.fx.summary.power:SetActive(false)
    ui.fx.summary.soldier:SetActive(false)
    
    for _, fx in pairs(ui.fx.basicAttributes) do
        fx:SetActive(false)
    end
end

local function StopFxOnGeneralPassiveSkills()
    coroutine.stop(ui.fxCoroutines.passiveSkills)

    for _, fx in ipairs(ui.fx.passiveSkills) do
        fx.levelUp:SetActive(false)
        fx.unlock:SetActive(false)
    end
end

local function StopFxOnBadgeMaterials()
    coroutine.stop(ui.fxCoroutines.badgeMaterials)
    
    for _, fx in ipairs(ui.fx.badgeMaterials) do
        fx:SetActive(false)
    end
end

local function StopFxOnExpBar()
    coroutine.stop(ui.fxCoroutines.expBar)
    
    for _, fx in pairs(ui.fx.expBar) do
        fx:SetActive(false)
    end
end

local function StopFx()
    StopFxOnGeneralBasicAttributes()
    StopFxOnGeneralPassiveSkills()
    StopFxOnBadgeMaterials()
    StopFxOnExpBar()
end

local function PlayFxOnGeneralBasicAttributes()
    StopFxOnGeneralBasicAttributes()

    ui.fxCoroutines.basicAttributes = coroutine.start(function()
        ui.fx.summary.power:SetActive(true)
        coroutine.wait(0.2)

        ui.fx.summary.soldier:SetActive(true)
        coroutine.wait(0.2)

        if not ui.left.basicAttributes.gameObject.activeSelf then
            ui.left.basicAttributes.gameObject:SetActive(true)
            UITweener.PlayAllTweener(ui.left.basicAttributes.gameObject, true, true, false)
        end

        for _, fx in pairs(ui.fx.basicAttributes) do
            fx:SetActive(true)
            coroutine.wait(0.2)
        end
        
        coroutine.wait(1)

        ui.fx.summary.power:SetActive(false)
        ui.fx.summary.soldier:SetActive(false)

        for _, fx in pairs(ui.fx.basicAttributes) do
            fx:SetActive(false)
        end

        ui.fxCoroutines.basicAttributes = nil
    end)
end

local function PlayFxOnGeneralPassiveSkills(type, skillIndex)
    StopFxOnGeneralPassiveSkills(type)

    if type == FX_PASSIVESKILLS.LEVEL_UP then
        ui.fxCoroutines.passiveSkills = coroutine.start(function()
            for i = 1, skillIndex do
                ui.fx.passiveSkills[i].levelUp:SetActive(true)
            end
            
            coroutine.wait(1)

            for i = 1, skillIndex do
                ui.fx.passiveSkills[i].levelUp:SetActive(false)
            end

            ui.fxCoroutines.passiveSkills = nil
        end)
    elseif type == FX_PASSIVESKILLS.UNLOCK then
        ui.fxCoroutines.passiveSkills = coroutine.start(function()
            ui.fx.passiveSkills[skillIndex].unlock:SetActive(true)
            
            coroutine.wait(1)

            ui.fx.passiveSkills[skillIndex].unlock:SetActive(false)

            ui.fxCoroutines.passiveSkills = nil
        end)
    end
end

local function PlayFxOnBadgeMaterials()
    StopFxOnBadgeMaterials()

    ui.fxCoroutines.badgeMaterials = coroutine.start(function()
        for _, fx in ipairs(ui.fx.badgeMaterials) do
            fx:SetActive(true)
        end
        
        coroutine.wait(1)

        for _, fx in ipairs(ui.fx.badgeMaterials) do
            fx:SetActive(false)
        end

        ui.fxCoroutines.badgeMaterials = nil
    end)
end

local function PlayFxOnExpBar(type)
    StopFxOnExpBar()

    ui.fxCoroutines.expBar = coroutine.start(function()
        ui.fx.expBar[type]:SetActive(true)
        
        coroutine.wait(1)

        ui.fx.expBar[type]:SetActive(false)

        ui.fxCoroutines.expBar = nil
    end)
end

local function LoadFx()
    local fxPassiveSkill = transform:Find("Fxs/Fx").gameObject

    for i, uiPassiveSkill in ipairs(ui.left.passiveSkills) do
        local fx = {}

        fx.gameObject = NGUITools.AddChild(uiPassiveSkill.gameObject, fxPassiveSkill)
        fx.transform = fx.gameObject.transform
        fx.levelUp = fx.transform:Find("Level Up").gameObject
        fx.unlock = fx.transform:Find("Unlock").gameObject

        fx.transform.localPosition = Vector3.zero
        fx.transform.localScale = Vector3.one

        ui.fx.passiveSkills[i] = fx
    end
end

local function Redraw()
    local heroInfo = currentGeneral.heroInfo
    local heroData = currentGeneral.heroData

    local isNotIllustrationation = heroInfo.uid ~= 0
    for _, uiTab in ipairs(ui.right.tabs) do
        uiTab.tab:SetActive(isNotIllustrationation)
    end

    ui.left.top.frame.spriteName = "hero_name_bg" .. heroData.quality
    ui.left.top.name.text = TextMgr:GetText(heroData.nameLabel)
    ui.left.top.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", heroData.herotitle)
    ui.left.top.detail.name.text = TextMgr:GetText(heroData.HeroTitleName)
    ui.left.top.detail.description.text = TextMgr:GetText(heroData.HeroTitleDes)
	HeroList.LoadHeroRarity(ui.left.top.rarity,heroData,false)
    
    ui.left.background.mainTexture = ResourceLibrary:GetIcon("Background/", "hero_pz" .. heroData.quality)
    ui.left.figure.mainTexture = ResourceLibrary:GetIcon("Icon/hero_half/", heroData.picture)
    ui.left.blackSpr.spriteName = "bg_hero_right" .. heroData.quality

    ui.left.summary.potential.text = heroData.herogrowth
    
    local pveSkillData = currentGeneral.pveSkillData
    if pveSkillData then
        ui.left.activeSkills.pve.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", pveSkillData.iconId)
    end

    local pvpSkillData = currentGeneral.pvpSkillData
    if pvpSkillData then
        ui.left.activeSkills.pvp.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", pvpSkillData.iconId)
    end

    local pvpSkillData = currentGeneral.pvpSkillData
    local pveSkillData = currentGeneral.pveSkillData

    local uiPvpSkill = ui.right.tabs[3].pvp
    uiPvpSkill.name.text = TextMgr:GetText(pvpSkillData.name)
    uiPvpSkill.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", pvpSkillData.iconId)

    local uiPveSkill = ui.right.tabs[3].pve
    uiPveSkill.name.text = TextMgr:GetText(pveSkillData.name)
    uiPveSkill.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", pveSkillData.iconId)

    StopFx()
    UpdateUI()
end

local function ShowTab(tab)
    if IsIllustration() then
        tab = DEFAULT_TAB_ILLUSTRATION
    end

    if tab ~= currentTab then
        SetCurrentTab(tab)

        local uiTab = ui.right.tabs[tab]
        uiTab.toggle.value = true
        uiTab.gameObject:SetActive(true)
    end
end

function Show(heroInfo, tab , enbChange)
    print("hero uid:", heroInfo.uid, "hero table id:", heroInfo.baseid)

    GeneralData.SetSeenHero(heroInfo)
    if not IsInViewport() then
		EnableChangeView(enbChange)
        SetCurrentTab(tab)

        currentGeneral = {}
        SetCurrentGeneral(heroInfo)

        Global.OpenUI(_M)
    else
		EnableChangeView(enbChange)
        SetCurrentGeneral(heroInfo)
        Redraw()

        if tab and ui.right.tabs[tab] then
            ShowTab(tab)
        end
    end
end


function ShowSpecialHero(heroMsg)
	local heroData = TableMgr:GetHeroData(heroMsg.id)
	if heroData then
		local heroInfo = GeneralData.GetDefaultHeroData(heroData, heroMsg.level, heroMsg.star, 1, 1)
		if heroInfo then
			Show(heroInfo , nil , true)
		end
	end
end

local function HideTooltip()
    local uiTab3 = ui.right.tabs[3]
    uiTab3.pvp.details.gameObject:SetActive(false)
    uiTab3.pve.details.gameObject:SetActive(false)
    Tooltip.HideAttributeTooltip()
    Tooltip.HidePassiveSkill()
    Tooltip.Hide()
end

function Hide()
    Global.CloseUI(_M)
end

local function OnUICameraClick(go)
    HideTooltip()
end

function OnUICameraDragStart(go, delta)
    HideTooltip()
end

function OnPassiveSkillUpgrade(skillIndex)
    if ui == nil then
        return
    end

    local effectObject = ui.left.passiveSkills[skillIndex].effectObject
    effectObject:SetActive(false)
    effectObject:SetActive(true)
end

function HeroUpdateEquip(need_update)
	for i, v in ipairs(ui.right.tabs[4].equips) do
		local eq = HeroEquipData.GetCurEquipByPos(i,currentGeneral.heroInfo)
		if ( HeroEquipData.IsUnlock(i,currentGeneral.heroInfo)) then
			if eq ~= nil then
				v.quality.spriteName = "bg_item" .. eq.data.quality
				v.Texture.mainTexture = ResourceLibrary:GetIcon("Item/", eq.BaseData.icon)
				v.lock:SetActive(false)
				v.lunkuo:SetActive(false)
				v.effect:SetActive(false)
				v.level:SetActive(false)
				v.level_label.text = eq.BaseData.itemlevel
			else
				v.quality.spriteName = "bg_item_hui"
				v.Texture.mainTexture = nil
				v.lock:SetActive(false)
				v.lunkuo:SetActive(true)
				v.level:SetActive(false)
                local equiplist = HeroEquipData.GetEquipListByPos(i)
                local hasequip = false
				if #equiplist > 0 then
					for i, v in ipairs(equiplist) do
						if v.data.status == 0 and v.data.parent.pos == 0 then
                            hasequip = true
                            break
						end
					end
					v.effect:SetActive(hasequip)
				else
					v.effect:SetActive(false)
                end
			end
			UIUtil.SetClickCallback(v.go, function()
				--EquipChange.Show(i)
                HeroEquipSelectNew.Show(i,currentGeneral.heroInfo,function()
                    HeroUpdateEquip(true)
                    UpdateNotice(4)
                end)
			end)
			v.red:SetActive(HeroEquipData.IsCanUpgradeByPos(i,currentGeneral.heroInfo))
		else
			v.quality.spriteName = "bg_item_hui"
			v.Texture.mainTexture = nil
			v.lock:SetActive(true)
			v.lunkuo:SetActive(false)
			v.level:SetActive(false)
			local text = System.String.Format(TextMgr:GetText("hero_ui1"),HeroEquipData.GetHeroUnlock(i))
			UIUtil.SetClickCallback(v.go, function()
				FloatText.ShowAt(v.go.transform.position,text, Color.white)
			end)
		end
    end
    if need_update then
    UpdateGeneralAttributes()
    end
end

function Awake()
    ui = {}

    ui.buttonTimer = 0

    ui.fx = {}
    ui.fxCoroutines = {}
    
    ui.left = {}
    ui.left.transform = transform:Find("Container/Left")
    ui.left.gameObject = ui.left.transform.gameObject

    ui.left.top = {}
    ui.left.top.transform = ui.left.transform:Find("Top")
    ui.left.top.gameObject = ui.left.top.transform.gameObject

    ui.left.top.frame = ui.left.transform:Find("Top"):GetComponent("UISprite")
    ui.left.top.name = ui.left.top.transform:Find("Name"):GetComponent("UILabel")
    ui.left.top.icon = ui.left.top.transform:Find("Icon"):GetComponent("UITexture")
    ui.left.blackSpr = ui.left.transform:Find("Background/black2"):GetComponent("UISprite")
	
	if ui.left.transform:Find("rarity_icon") ~= nil then 
		ui.left.top.rarity = ui.left.transform:Find("rarity_icon"):GetComponent("UISprite")
	end 
	
	
    UIUtil.SetClickCallback(ui.left.top.icon.gameObject, function()
        ui.left.top.detail.gameObject:SetActive(true)
    end)

    ui.left.top.detail = {}
    ui.left.top.detail.transform = ui.left.top.transform:Find("Detail")
    ui.left.top.detail.gameObject = ui.left.top.detail.transform.gameObject
    ui.left.top.detail.name = ui.left.top.detail.transform:Find("Background/Name"):GetComponent("UILabel")
    ui.left.top.detail.description = ui.left.top.detail.transform:Find("Background/Description"):GetComponent("UILabel")

    UIUtil.SetClickCallback(ui.left.top.detail.transform:Find("Mask").gameObject, function()
        ui.left.top.detail.gameObject:SetActive(false)
    end)

    ui.left.stars = UIUtil.LoadStarDisplay(ui.left.transform:Find("Stars"))
    ui.left.background = ui.left.transform:Find("Background"):GetComponent("UITexture")
    ui.left.figure = ui.left.transform:Find("Figure"):GetComponent("UITexture")

    ui.left.summary = {}
    ui.left.summary.transform = ui.left.transform:Find("Summary")
    ui.left.summary.gameObject = ui.left.summary.transform.gameObject

    ui.left.summary.level = ui.left.summary.transform:Find("Level"):GetComponent("UILabel")
    ui.left.summary.power = ui.left.summary.transform:Find("Power/Num"):GetComponent("UILabel")
    ui.left.summary.potential = ui.left.summary.transform:Find("Potential/Label"):GetComponent("UILabel")
    ui.left.summary.soldierObject = ui.left.summary.transform:Find("Soldier").gameObject
    ui.left.summary.soldier = ui.left.summary.transform:Find("Soldier/Label"):GetComponent("UILabel")

    UIUtil.SetClickCallback(ui.left.summary.transform:Find("Potential").gameObject, function(go)
        if go == ui.tipObject then
            ui.tipObject = nil
        else
            ui.tipObject = go
            Tooltip.ShowAttributeTooltip(103)
        end
    end)

    UIUtil.SetClickCallback(ui.left.summary.transform:Find("Soldier").gameObject, function(go)
        if go == ui.tipObject then
            ui.tipObject = nil
        else
            ui.tipObject = go
            Tooltip.ShowAttributeTooltip(1102)
        end
    end)

    ui.fx.summary = {}
    ui.fx.summary.power = ui.left.summary.transform:Find("Power/Fx").gameObject
    ui.fx.summary.soldier = ui.left.summary.transform:Find("Soldier/Fx").gameObject

    ui.left.basicAttributes = {}
    ui.left.basicAttributes.transform = ui.left.transform:Find("Basic Attributes/List")
    ui.left.basicAttributes.gameObject = ui.left.basicAttributes.transform.gameObject

    UIUtil.SetClickCallback(ui.left.basicAttributes.transform:Find("Detail Button").gameObject, function()
        BasicParameters.Show(currentGeneral.heroData)
    end)

    ui.fx.basicAttributes = {}

    for i = 1, 4 do
        ui.left.basicAttributes[i] = ui.left.basicAttributes.transform:Find(i .. "/Num"):GetComponent("UILabel")
        ui.fx.basicAttributes[i] = ui.left.basicAttributes.transform:Find(i .. "/Fx").gameObject
    end

    ui.left.activeSkills = {}
    ui.left.activeSkills.transform = ui.left.transform:Find("Active Skills")
    ui.left.activeSkills.gameObject = ui.left.activeSkills.transform.gameObject

    ui.left.activeSkills.pve = {}
    ui.left.activeSkills.pve.transform = ui.left.activeSkills.transform:Find("Pve")
    ui.left.activeSkills.pve.gameObject = ui.left.activeSkills.pve.transform.gameObject
    ui.left.activeSkills.pve.icon = ui.left.activeSkills.pve.transform:Find("Icon"):GetComponent("UITexture")
    ui.left.activeSkills.pve.frame = ui.left.activeSkills.pve.transform:Find("Frame"):GetComponent("UISprite")

    ui.left.activeSkills.pvp = {}
    ui.left.activeSkills.pvp.transform = ui.left.activeSkills.transform:Find("Pvp")
    ui.left.activeSkills.pvp.gameObject = ui.left.activeSkills.pvp.transform.gameObject
    ui.left.activeSkills.pvp.icon = ui.left.activeSkills.pvp.transform:Find("Icon"):GetComponent("UITexture")
    ui.left.activeSkills.pvp.frame = ui.left.activeSkills.pvp.transform:Find("Frame"):GetComponent("UISprite")

    ui.left.passiveSkills = {}
    ui.left.passiveSkills.transform = ui.left.transform:Find("Passive Skills")
    ui.left.passiveSkills.gameObject = ui.left.passiveSkills.transform.gameObject
    ui.left.passiveSkills.grid = ui.left.passiveSkills.transform:Find("Grid"):GetComponent("UIGrid")

    ui.fx.passiveSkills = {}

    for i = 1, 6 do
        local uiPassiveSkill = {}

        uiPassiveSkill.transform = ui.left.passiveSkills.grid.transform:GetChild(i - 1)
        uiPassiveSkill.gameObject = uiPassiveSkill.transform.gameObject

        uiPassiveSkill.name = uiPassiveSkill.transform:Find("Name"):GetComponent("UILabel")

        local frameTransform = uiPassiveSkill.transform:Find("Frame")
        uiPassiveSkill.frame = frameTransform:GetComponent("UISprite")
        uiPassiveSkill.icon = frameTransform:Find("Icon"):GetComponent("UITexture")
        uiPassiveSkill.lock = uiPassiveSkill.transform:Find("Lock").gameObject
        uiPassiveSkill.levelBgObject = uiPassiveSkill.transform:Find("lv").gameObject
        uiPassiveSkill.levelLabel = uiPassiveSkill.transform:Find("lv/Label"):GetComponent("UILabel")
        uiPassiveSkill.noticeObject = uiPassiveSkill.transform:Find("redpoint").gameObject
        uiPassiveSkill.selectObject = uiPassiveSkill.transform:Find("kuang").gameObject
        uiPassiveSkill.effectObject = uiPassiveSkill.transform:Find("jinengdonghua").gameObject
        
        ui.left.passiveSkills[i] = uiPassiveSkill
    end

    UIUtil.SetClickCallback(ui.left.transform:Find("URL Button").gameObject, function()
        UnityEngine.Application.OpenURL(currentGeneral.heroData.biourl)
    end)

    UIUtil.SetClickCallback(ui.left.activeSkills.gameObject, function()
        ShowTab(3)
    end)

    UIUtil.SetClickCallback(ui.left.stars.gameObject, function()
        ShowTab(2)
    end)

    ui.right = {}
    ui.right.transform = transform:Find("Container/Right")
    ui.right.gameObject = ui.right.transform.gameObject

    local uiTab1 = {}
    uiTab1.transform = ui.right.transform:Find("Content 1")
    uiTab1.gameObject = uiTab1.transform.gameObject

    uiTab1.gradeUp = {}
    uiTab1.gradeUp.transform = uiTab1.transform:Find("Grade Up")
    uiTab1.gradeUp.gameObject = uiTab1.gradeUp.transform.gameObject

    uiTab1.gradeUp.items = {}
    ui.fx.badgeMaterials = {}
    for i = 1, 6 do
        local uiItem = {}

        uiItem.transform = uiTab1.gradeUp.transform:GetChild(i)
        uiItem.gameObject = uiItem.transform.gameObject

        local iconTransform = uiItem.transform:Find("Icon")
        uiItem.icon = iconTransform:GetComponent("UITexture")
        uiItem.frame = iconTransform:Find("Frame"):GetComponent("UISprite")

        uiItem.btn_add = {}
        uiItem.btn_add.transform = iconTransform:Find("Add Button")
        uiItem.btn_add.gameObject = uiItem.btn_add.transform.gameObject
        uiItem.btn_add.icon = uiItem.btn_add.transform:GetComponent("UISprite")
        
        uiItem.tips_max = iconTransform:Find("Max").gameObject
        uiItem.label = iconTransform:Find("Label"):GetComponent("UILabel")
        uiItem.lock = uiItem.transform:Find("Lock").gameObject
        uiItem.notice = uiItem.transform:Find("Notice").gameObject

        ui.fx.badgeMaterials[i] = uiItem.transform:Find("Fx").gameObject

        UIUtil.SetClickCallback(uiItem.icon.gameObject, function()
            if not IsIllustration() then
                local badgeMaterial = currentGeneral.badgeMaterials[i]
                BadgeInfoNew_1.Show(badgeMaterial)
            end
        end)

        uiTab1.gradeUp.items[i] = uiItem
    end

    uiTab1.gradeUp.badge = {}
    uiTab1.gradeUp.badge.transform = uiTab1.gradeUp.transform:Find("Badge/Icon")
    uiTab1.gradeUp.badge.gameObject = uiTab1.gradeUp.badge.transform.gameObject
    uiTab1.gradeUp.badge.icon = uiTab1.gradeUp.badge.transform:GetComponent("UISprite")
    uiTab1.gradeUp.badge.boxCollider = uiTab1.gradeUp.badge.transform:GetComponent("BoxCollider")
    
    uiTab1.gradeUp.tips_levelRequirement = uiTab1.gradeUp.transform:Find("Tips"):GetComponent("UILabel")
    uiTab1.gradeUp.fx_upgradable = uiTab1.gradeUp.transform:Find("Badge/Fx").gameObject

    UIUtil.SetClickCallback(uiTab1.gradeUp.fx_upgradable, function()
        local heroInfo = currentGeneral.heroInfo
		if heroInfo.level < currentGeneral.heroGradeUpData.unlockLevel then
			FloatText.Show(System.String.Format(TextMgr:GetText("badgeInfo_need_level"), currentGeneral.heroGradeUpData.unlockLevel) , Color.red)
			return
		end
		
        local req = HeroMsg_pb.MsgHeroGradeUpRequest()
        req.heroUid = heroInfo.uid
        req.gradeid = heroInfo.heroGrade + 1

        Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroGradeUpRequest, req, HeroMsg_pb.MsgHeroGradeUpResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                MainCityUI.UpdateRewardData(msg.fresh)
            else
                Global.ShowError(msg.code)
            end
        end)
    end)

    uiTab1.levelUp = {}
    uiTab1.levelUp.transform = uiTab1.transform:Find("Level Up")
    uiTab1.levelUp.gameObject = uiTab1.levelUp.transform.gameObject

    uiTab1.levelUp.expItems = {}
    for i = 1, 5 do
        local uiItem = UIUtil.LoadItemObject({}, uiTab1.levelUp.transform:GetChild(i - 1))

        local itemData = TableMgr:GetItemData(tonumber(uiItem.gameObject.name))
        
        uiItem.itemData = itemData

        UIUtil.SetClickCallback(uiItem.gameObject, function()
            local heroInfo = currentGeneral.heroInfo
            if heroInfo.uid ~= 0 then
                if uiItem.num > 0 then
                    if GeneralData.CanLevelUpQuick(heroInfo, currentGeneral.heroRule) then
                        GeneralData.UseExpItems(heroInfo.uid,heroInfo.baseid, { [ItemListData.GetItemDataByBaseId(uiItem.itemData.id).uniqueid] = 1 })
                    else
                        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        FloatText.Show(TextMgr:GetText(Text.hero_level_limited), Color.white)
                    end
                else
                    GatherItemUI.Show(uiItem.itemData.id, 1)
                end
            end
        end)

        UIUtil.SetPressCallback(uiItem.gameObject, function(go, isPressed)
            if isPressed then
                ui.buttonTimer = BUTTON_REPEAT_DELAY
                ui.expItemToUse = uiItem.itemData
            else
                ui.buttonTimer = 0
            end
        end)

        uiTab1.levelUp.expItems[itemData.id] = uiItem
    end

    uiTab1.levelUp.expBar = uiTab1.levelUp.transform:Find("Progress Bar"):GetComponent("UISlider")
    uiTab1.levelUp.currentLevel = uiTab1.levelUp.expBar.transform:Find("Level"):GetComponent("UILabel")
    uiTab1.levelUp.currentExp = uiTab1.levelUp.expBar.transform:Find("Label"):GetComponent("UILabel")
    uiTab1.levelUp.btn_quickLevelUp = uiTab1.levelUp.transform:Find("Level Up Button"):GetComponent("UIButton")
    uiTab1.levelUp.tips_maxLevel = uiTab1.levelUp.transform:Find("Max").gameObject
    uiTab1.levelUp.notice = uiTab1.levelUp.transform:Find("Level Up Button/Notice").gameObject

    ui.fx.expBar = {}
    ui.fx.expBar[FX_EXPBAR.INCREASE_EXP] = uiTab1.levelUp.expBar.transform:Find("Fx1").gameObject
    ui.fx.expBar[FX_EXPBAR.LEVEL_MAX] = uiTab1.levelUp.expBar.transform:Find("Fx2").gameObject

    UIUtil.SetClickCallback(uiTab1.levelUp.btn_quickLevelUp.gameObject, function()
        local heroInfo = currentGeneral.heroInfo
        local maxLevel = currentGeneral.heroRule.maxlevel

        if heroInfo.level < maxLevel then
            local availableExpItems = PriorityQueue(5, function(itemA, itemB)
                return itemA.itemData.quality > itemB.itemData.quality
            end)

            for _, uiItem in pairs(ui.right.tabs[1].levelUp.expItems) do
                if uiItem.num > 0 then
                    availableExpItems:Push(uiItem)
                end
            end

            if availableExpItems:IsEmpty() then
                FloatText.Show(TextMgr:GetText(Text.player_ui18), Color.white)
            else
                local leftExp = TableMgr:GetHeroExpData(maxLevel - 1).exp - heroInfo.exp

                local itemsToUse = {}
                while leftExp > 0 and not availableExpItems:IsEmpty() do
                    local uiItem = availableExpItems:Pop()

                    local itemExp = uiItem.itemData.param1
                    local numToUse = math.min(uiItem.num, math.ceil(leftExp / itemExp))
                    
                    leftExp = leftExp - itemExp * numToUse

                    if availableExpItems:IsEmpty() and leftExp > 0 then
                        if numToUse < uiItem.num then
                            numToUse = numToUse + 1
                            leftExp = leftExp - itemExp
                        end
                    end

                    itemsToUse[ItemListData.GetItemDataByBaseId(uiItem.itemData.id).uniqueid] = numToUse
                end

                GeneralData.UseExpItems(currentGeneral.heroInfo.uid,currentGeneral.heroInfo.baseid, itemsToUse)
            end
        else
            AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            FloatText.Show(TextMgr:GetText(Text.hero_level_limited), Color.white)
        end
    end)

    local uiTab2 = {}
    uiTab2.transform = ui.right.transform:Find("Content 2")
    uiTab2.gameObject = uiTab2.transform.gameObject

    uiTab2.top = {}
    uiTab2.top.transform = uiTab2.transform:Find("Top")
    uiTab2.top.gameObject = uiTab2.top.transform.gameObject
    
    uiTab2.top.stars = UIUtil.LoadStarDisplay(uiTab2.top.transform:Find("Stars"))

    local progressBarTransform = uiTab2.top.transform:Find("Progress Bar")
    uiTab2.top.progressBar = progressBarTransform:GetComponent("UISlider")
    uiTab2.top.num = uiTab2.top.progressBar.transform:Find("Label"):GetComponent("UILabel")
    uiTab2.top.btn_starUp = uiTab2.top.transform:Find("Star Up Button"):GetComponent("UIButton")
    uiTab2.top.btn_universalShard = uiTab2.top.transform:Find("Universal Piece Button"):GetComponent("UIButton")
    
    UIUtil.SetClickCallback(progressBarTransform:Find("Add").gameObject, function()
        GatherItemUI.Show(currentGeneral.heroData.chipID, currentGeneral.heroRule.num)
    end)

    UIUtil.SetClickCallback(progressBarTransform:Find("Icon").gameObject, function()
        if not IsIllustration() then
            UniversalPiece.Show(currentGeneral.heroInfo)
        end
    end)

    UIUtil.SetClickCallback(uiTab2.top.btn_universalShard.gameObject, function()
        UniversalPiece.Show(currentGeneral.heroInfo)
    end)

    UIUtil.SetClickCallback(uiTab2.top.btn_starUp.gameObject, function()
        local heroInfo = currentGeneral.heroInfo
        local heroData = currentGeneral.heroData
        local heroRule = currentGeneral.heroRule

        if GeneralData.CanStarUp(heroInfo, heroData, heroRule) then
            local req = HeroMsg_pb.MsgHeroStarUpRequest()
            req.heroUid = heroInfo.uid

            local itemInfo = ItemListData.GetItemDataByBaseId(heroData.chipID)

            local piece = req.piece:add()
            piece.uid = itemInfo.uniqueid
            piece.num = heroRule.num
            
            local heroInfo_beforeStarUp = GeneralData.Duplicate(heroInfo)
            Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroStarUpRequest, req, HeroMsg_pb.MsgHeroStarUpResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    GeneralData.ClearSeenHero(heroInfo.baseid)
                    MainCityUI.UpdateRewardData(msg.fresh)
                    HeroSkillUpNew.Show(heroInfo_beforeStarUp, currentGeneral.heroInfo, function()
                        PlayFxOnGeneralBasicAttributes()

                        ui.fxCoroutines.starUp = coroutine.start(function()
                            PlayFxOnGeneralBasicAttributes()

                            if currentGeneral.heroInfo.grade == 1 then
                                coroutine.wait(1.4)

                                if IsInViewport() then
                                    PlayFxOnGeneralPassiveSkills(FX_PASSIVESKILLS.UNLOCK, currentGeneral.heroInfo.star)
                                end
                            end
                        end)
                    end)
                else
                    Global.ShowError(msg.code)
                end
            end)
        else
            FloatText.Show(TextMgr:GetText(Text.noMoreHeroPiece))
        end
    end)

    uiTab2.bottom = {}
    uiTab2.bottom.transform = uiTab2.transform:Find("Bottom")
    uiTab2.bottom.gameObject = uiTab2.bottom.transform.gameObject

    uiTab2.bottom.attributeList = {}
    uiTab2.bottom.attributeList.transform = uiTab2.bottom.transform:Find("Attributes")
    uiTab2.bottom.attributeList.gameObject = uiTab2.bottom.attributeList.transform.gameObject

    uiTab2.bottom.attributeList.attributes = {}
    for i = 1, uiTab2.bottom.attributeList.transform.childCount do
        local uiAttribute = {}

        uiAttribute.transform = uiTab2.bottom.attributeList.transform:GetChild(i - 1)
        uiAttribute.gameObject = uiAttribute.transform.gameObject

        uiAttribute.currentValue = uiAttribute.transform:Find("Current"):GetComponent("UILabel")
        uiAttribute.nextValue = uiAttribute.transform:Find("Next"):GetComponent("UILabel")

        table.insert(uiTab2.bottom.attributeList.attributes, uiAttribute)
        if i == 2 then
            uiAttribute.gameObject:SetActive(Global.IsOutSea())
        end
    end

    local uiTab3 = {}
    uiTab3.transform = ui.right.transform:Find("Content 3")
    uiTab3.gameObject = uiTab3.transform.gameObject

    uiTab3.pvp = UIUtil.LoadSkillDisplay(uiTab3.transform:Find("Pvp"))
    uiTab3.pve = UIUtil.LoadSkillDisplay(uiTab3.transform:Find("Pve"))
    UIUtil.SetClickCallback(uiTab3.pvp.btn_detail.gameObject, function(go)
        if go == ui.tipObject then
            ui.tipObject = nil
        else
            ui.tipObject = go
            uiTab3.pvp.details.gameObject:SetActive(true)
        end
    end)
    UIUtil.SetClickCallback(uiTab3.pve.btn_detail.gameObject, function(go)
        if go == ui.tipObject then
            ui.tipObject = nil
        else
            ui.tipObject = go
            uiTab3.pve.details.gameObject:SetActive(true)
        end
    end)

    local uiTab4 = {}

    uiTab4.transform = ui.right.transform:Find("Content 4")
    uiTab4.gameObject = uiTab4.transform.gameObject
	uiTab4.equips = {}
	for i = 1, 6 do
		uiTab4.equips[i] = {}
		uiTab4.equips[i].go = uiTab4.transform:Find(System.String.Format("Container/equip0{0}", i)).gameObject
		uiTab4.equips[i].quality = uiTab4.equips[i].go:GetComponent("UISprite")
		uiTab4.equips[i].Texture = uiTab4.equips[i].go.transform:Find("Texture"):GetComponent("UITexture")
		uiTab4.equips[i].lunkuo = uiTab4.equips[i].go.transform:Find("lunku").gameObject
		uiTab4.equips[i].lock = uiTab4.equips[i].go.transform:Find("lock").gameObject
		uiTab4.equips[i].go:GetComponent("UIButton").enabled = false
		uiTab4.equips[i].effect = uiTab4.equips[i].go.transform:Find("effect").gameObject
		uiTab4.equips[i].level = uiTab4.equips[i].go.transform:Find("level").gameObject
		uiTab4.equips[i].level_label = uiTab4.equips[i].go.transform:Find("level/num"):GetComponent("UILabel")
		uiTab4.equips[i].red = uiTab4.equips[i].go.transform:Find("redpoint").gameObject
	end

    

    ui.right.tabs = { uiTab1, uiTab2, uiTab3,uiTab4 }


    for i = 1, 4 do
        ui.right.tabs[i].toggle = ui.right.transform:Find("Page " .. i):GetComponent("UIToggle")
        ui.right.tabs[i].tab = ui.right.tabs[i].toggle.gameObject

        UIUtil.SetClickCallback(ui.right.tabs[i].tab, function()
            ShowTab(i)
        end)

        ui.right.tabs[i].gameObject:SetActive(false)
        ui.right.tabs[i].toggle.value = false
    end

    uiTab1.notice = ui.right.transform:Find("Page 1/Notice").gameObject
    uiTab2.notice = ui.right.transform:Find("Page 2/Notice").gameObject
    uiTab4.notice = ui.right.transform:Find("Page 4/Notice").gameObject

    HeroUpdateEquip()
    UIUtil.SetClickCallback(transform:Find("Container/Buttons/Close Button").gameObject, Hide)

	local righrButton = transform:Find("Container/Buttons/Right Button").gameObject
	righrButton:SetActive(not enableChaneView)
    UIUtil.SetClickCallback(righrButton, function()
        local heroInfo
        
        if GUIMgr:IsMenuOpen("Preview") then
            local general = Preview.GetNextIllustrateHero(currentGeneral.heroInfo.baseid)
            heroInfo = general and general.msg
        else
            heroInfo = HeroListNew.GetNextGeneral(currentGeneral.heroInfo)
        end

        if heroInfo then
            Show(heroInfo)
        else
            Hide()
        end
    end)

	local leftButton = transform:Find("Container/Buttons/Left Button").gameObject
	leftButton:SetActive(not enableChaneView)
    UIUtil.SetClickCallback(leftButton, function()
        local heroInfo

        if GUIMgr:IsMenuOpen("Preview") then
            local general = Preview.GetPreviousIllustrateHero(currentGeneral.heroInfo.baseid)
            heroInfo = general and general.msg
        else
            heroInfo = HeroListNew.GetPreviousGeneral(currentGeneral.heroInfo)
        end

        if heroInfo then
            Show(heroInfo)
        else
            Hide()
        end
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralLevelChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo, change)
        if heroInfo.uid == currentGeneral.heroInfo.uid then
            UpdateGeneralLevel()
            HeroUpdateEquip()
            UpdateGeneralAttributes()
            UpdateGeneralPvpSkill()
            UpdateGeneralPveSkill()

            UpdateGeneralGradeUpLevelRequirement()

            UpdateTips(1)
            UpdateNotice(1)

            PlayFxOnGeneralBasicAttributes()
            
        end
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralExpChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo)
        if heroInfo.uid == currentGeneral.heroInfo.uid and currentTab == 1 then
            PlayFxOnExpBar(currentGeneral.heroInfo.level == currentGeneral.heroRule.maxlevel and FX_EXPBAR.LEVEL_MAX or FX_EXPBAR.INCREASE_EXP)

            UpdateGeneralExp()
        end
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralStarChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo)
        if heroInfo.uid == currentGeneral.heroInfo.uid then
            UpdateGeneralTableData()

            UpdateGeneralStar()

            UpdateGeneralAttributes()
            UpdateGeneralPassiveSkills()
            UpdateGeneralPvpSkill()
            UpdateGeneralPveSkill()

            UpdateGeneralShards()

            UpdateTips(1)
        end
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralGradeChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo)
        if heroInfo.uid == currentGeneral.heroInfo.uid then
            UpdateGeneralTableData()

            UpdateGeneralGrade()

            UpdateGeneralAttributes()

            UpdateGeneralBadgeMaterials()
            UpdateGeneralGradeUpLevelRequirement()

            UpdateTips(1)
            UpdateNotice(1)

            ui.fxCoroutines.gradeUp = coroutine.start(function()
                PlayFxOnBadgeMaterials()

                coroutine.wait(0.5)

                if IsInViewport() then
                    PlayFxOnGeneralBasicAttributes()
                else
                    ui.fxCoroutines.gradeUp = nil
                    return
                end

                coroutine.wait(1.4)
                
                if IsInViewport() then
                    --PlayFxOnGeneralPassiveSkills(FX_PASSIVESKILLS.LEVEL_UP, currentGeneral.heroInfo.star)
                end
            end)
        end
    end)
	
	EventDispatcher.Bind(GeneralData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo)
		if heroInfo.uid == currentGeneral.heroInfo.uid then
			UpdateGeneralPassiveSkills()
			UpdateGeneralAttributes()
			UpdateNotice(1)
		end
	end)
	

    EventDispatcher.Bind(ItemListData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(itemInfo, change)
        UpdateGeneralBadgeMaterials()
        UpdateGeneralShards()
        UpdateGeneralPassiveSkills()
        if not IsIllustration() then
            UpdateExpItems()
            
            UpdateNotice(1)
        end
    end)

    UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)

    ui.left.background.mainTexture = ResourceLibrary:GetIcon("Background/", "hero_pz" .. currentGeneral.heroData.quality)
end

function LateUpdate()
    if ui.buttonTimer > 0 then
        ui.buttonTimer = ui.buttonTimer - Serclimax.GameTime.deltaTime
        if ui.buttonTimer <= 0 then
            local heroInfo = currentGeneral.heroInfo
            if heroInfo.level < currentGeneral.heroRule.maxlevel then
                ui.buttonTimer = BUTTON_REPEAT_INTERVAL
                local itemInfo = ItemListData.GetItemDataByBaseId(ui.expItemToUse.id)
                if itemInfo then
                    GeneralData.UseExpItems(heroInfo.uid,heroInfo.baseid, { [itemInfo.uniqueid] = 1 })
                end
            else
                AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                FloatText.Show(TextMgr:GetText(Text.hero_level_limited), Color.white)
            end
        end
    end
end

function Start()
    LoadFx()

    UpdateExpItems()

    Redraw()

    if currentTab then
        ShowTab(currentTab)
    else
        ShowTab(DEFAULT_TAB)
    end
end

function Close()
    EventDispatcher.UnbindAll(_M)

    UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)

    StopFx()

    HideTooltip()
    ui = nil
    currentTab = nil
    currentGeneral = nil
end
