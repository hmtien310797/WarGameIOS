module("OneCardDisplay", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String

local LoadHero = HeroList.LoadHero
local _ui
local showing

function Showing()
    return showing
end

function Hide()
    Global.CloseUI(_M)
    showing = false
end

local function LoadCostUI()
    if _ui ~= nil then
        local chestMsg = _ui.chestMsg
        if chestMsg ~= nil then
            MilitarySchool.LoadOneCostUI(_ui, chestMsg)
        end
    end
end

function LoadRewardObject(reward, rewardTransform)
    reward.blackMask = rewardTransform:Find("mask closebtn")
    reward.maskTransform = rewardTransform:Find("mask")
    local convertTransform = rewardTransform:Find("repeat_tips")
    reward.convertObject = convertTransform.gameObject
    reward.convertTweener = convertTransform:GetComponent("UITweener")
    local hero = {}
    local heroTransform = rewardTransform:Find("head widget")
    hero.transform = heroTransform
    hero.gameObject = heroTransform.gameObject
    hero.nameLabel = heroTransform:Find("name text"):GetComponent("UILabel")
    hero.picture = heroTransform:Find("hero half"):GetComponent("UITexture")
	if heroTransform:Find("rarity_icon") ~= nil then 
		hero.rarity = heroTransform:Find("rarity_icon"):GetComponent("UISprite")
	end 
    hero.qualityList = {}
    for i = 1, 5 do
        hero.qualityList[i] = heroTransform:Find(string.format("hero half/hero_outline%d", i))
    end
    hero.starList = {}
    for i = 1, 6 do
        hero.starList[i] = heroTransform:Find(string.format("star widget/star%d", i))
    end
    hero.troopsObject = heroTransform:Find("hero half/soldier bg").gameObject
    hero.troopsLabel = heroTransform:Find("hero half/soldier bg/num"):GetComponent("UILabel")
    reward.hero = hero
    
    reward.skillGo = rewardTransform:Find("new_right").gameObject
    reward.skillNameLabel = rewardTransform:Find("new_right/skill/mission"):GetComponent("UILabel")
    reward.skillIcon = rewardTransform:Find("new_right/skill/Texture"):GetComponent("UITexture")
    reward.skillBgSprite = rewardTransform:Find("new_right/skill"):GetComponent("UISprite")
    reward.skillStarList = {}
    for i = 1, 6 do
        reward.skillStarList[i] = rewardTransform:Find(string.format("new_right/skill/star/%dstars", i))
    end
    reward.skillDescriptionLabel = rewardTransform:Find("new_right/Label"):GetComponent("UILabel")

    reward.skillGo_pvp = rewardTransform:Find("new_right_pvp").gameObject
    reward.skillNameLabel_pvp = rewardTransform:Find("new_right_pvp/skill/mission"):GetComponent("UILabel")
    reward.skillIcon_pvp = rewardTransform:Find("new_right_pvp/skill/Texture"):GetComponent("UITexture")
    reward.skillBgSprite_pvp = rewardTransform:Find("new_right_pvp/skill"):GetComponent("UISprite")
    reward.skillStarList_pvp = {}
    for i = 1, 6 do
        reward.skillStarList_pvp[i] = rewardTransform:Find(string.format("new_right_pvp/skill/star/%dstars", i))
    end
    reward.skillDescriptionLabel_pvp = rewardTransform:Find("new_right_pvp/Label"):GetComponent("UILabel")
    
    local item = {}
    local itemTransform = rewardTransform:Find("bg_icon/Item_CommonNew") 
    UIUtil.LoadItemObject(item, itemTransform)
    item.nameLabel = rewardTransform:Find("bg_icon/Label"):GetComponent("UILabel")
    item.bgObject = rewardTransform:Find("bg_icon").gameObject

    reward.item = item
end

function LoadRewardHero(reward, heroMsg, heroData)
    LoadHero(reward.hero, heroMsg, heroData)
    HeroList.LoadHeroRarity(reward.hero.rarity,heroData,true)
	local heroLevel = heroMsg.level

    local skillId = tonumber(TableMgr:GetHeroData(heroMsg.baseid).skillId)
    local skillData = TableMgr:GetGodSkillDataByIdLevel(skillId, 1)
    reward.skillNameLabel.text = TextMgr:GetText(skillData.name)
    reward.skillIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
    -- reward.skillBgSprite.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
    Global.SetNumber(reward.skillStarList, 1)

    local arg0 = skillData.radius
    local arg1 = nil
    if skillData.growValue ~= "NA" then
        local growValueList = string.split(skillData.growValue, ";")
        arg1 = growValueList[1] * heroLevel * heroLevel + growValueList[2] * heroLevel + growValueList[3]
        arg1 = math.floor(math.abs(arg1))
    end
    local arg2 = skillData.duration
    local arg3 = skillData.cost
    local arg4 = skillData.cooldown
    reward.skillDescriptionLabel.text = String.Format(TextMgr:GetText(skillData.longDescription), arg0, arg1, arg2, arg3, arg4)

    local pvpSkillData = TableMgr:GetGeneralPvpSkillData(heroMsg)

    reward.skillNameLabel_pvp.text = TextMgr:GetText(pvpSkillData.name)
    reward.skillIcon_pvp.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", pvpSkillData.iconId)
    -- reward.skillBgSprite_pvp.spriteName = HeroInfo.GetSkillSpriteNameByHeroQuality(heroData.quality)
    
    Global.SetNumber(reward.skillStarList_pvp, 1)

    local growValueList_pvp = table.map(string.split(pvpSkillData.skillvalue, ","), tonumber)

    local growValue1 = math.abs(growValueList_pvp[1] * heroLevel * heroLevel + growValueList_pvp[2] * heroLevel + growValueList_pvp[3]) 
    if growValue1 ~= 0 then
        growValue1 = string.make_percent(100 * growValue1);
    else
        growValue1 = "0%"
    end
    local growValue2 = 0
    if #growValueList_pvp == 6 then
        growValue2 = math.abs(growValueList_pvp[4] * heroLevel * heroLevel + growValueList_pvp[5] * heroLevel + growValueList_pvp[6]) 
    end


    reward.skillDescriptionLabel_pvp.text = System.String.Format(TextMgr:GetText(pvpSkillData.longDescription),growValue1,growValue2)
end

function LoadRewardItem(item, itemMsg, itemData)
    UIUtil.LoadItem(item, itemData, itemMsg.num > 1 and itemMsg.num or nil)
end

function LoadReward(reward, heroMsg, itemMsg)
    reward.hero.gameObject:SetActive(heroMsg ~= nil)
    reward.skillGo:SetActive(heroMsg ~= nil)
    reward.skillGo_pvp:SetActive(heroMsg ~= nil)
    reward.item.bgObject:SetActive(itemMsg ~= nil)

    if heroMsg ~= nil then
        reward.hero.gameObject:SetActive(true)
        reward.skillGo:SetActive(true)
        reward.skillGo_pvp:SetActive(true)
        reward.item.bgObject:SetActive(false)
        local heroData = TableMgr:GetHeroData(heroMsg.baseid)
        local defaultHeroMsg = GeneralData.GetDefaultHeroData(heroData) -- HeroListData.GetDefaultHeroData(heroData)
        defaultHeroMsg.baseid = heroMsg.baseid
        defaultHeroMsg.level = heroMsg.level
        defaultHeroMsg.star = heroMsg.star
        defaultHeroMsg.grade = heroMsg.grade
        -- defaultHeroMsg.num = heroMsg.num
        LoadRewardHero(reward, defaultHeroMsg, heroData)
    end

	if itemMsg ~= nil then
        local itemData = TableMgr:GetItemData(itemMsg.baseid)
        if itemMsg.heroToPiece ~= 0 then
            reward.hero.gameObject:SetActive(true)
            reward.skillGo:SetActive(true)
            reward.skillGo_pvp:SetActive(true)
            reward.item.bgObject:SetActive(false)
            reward.convertObject:SetActive(true)
            local defaultHeroData = TableMgr:GetHeroData(itemMsg.heroToPiece)
            local defaultHeroMsg = GeneralData.GetDefaultHeroData(defaultHeroData) -- HeroListData.GetDefaultHeroData(defaultHeroData)
            LoadRewardHero(reward, defaultHeroMsg, defaultHeroData)
            reward.convertTweener:SetOnFinished(EventDelegate.Callback(function()
                reward.hero.gameObject:SetActive(false)
                reward.skillGo:SetActive(false)
                reward.skillGo_pvp:SetActive(false)
                reward.item.bgObject:SetActive(true)
                if reward.item.pieceEffectObject ~= nil then
                    reward.item.pieceEffectObject:SetActive(true)
                end
                LoadRewardItem(reward.item, itemMsg, itemData)
            end))
        else
            reward.hero.gameObject:SetActive(false)
            reward.skillGo:SetActive(false)
            reward.skillGo_pvp:SetActive(false)
            reward.item.bgObject:SetActive(true)
            LoadRewardItem(reward.item, itemMsg, itemData)
        end
	end
end

local function LoadUI()
    local chestMsg = _ui.chestMsg
    local showAgain = _ui.showAgain
    local reward = _ui.reward
    if showAgain and chestMsg ~= nil then
        MilitarySchool.LoadOneCostUI(_ui, chestMsg)
        UIUtil.SetClickCallback(_ui.againButton.gameObject, MilitarySchool.GetRequestFunction(chestMsg.type, false))
    else
        UIUtil.SetClickCallback(reward.maskTransform.gameObject, Hide)
    end
    _ui.okButton.gameObject:SetActive(showAgain)
    _ui.againButton.gameObject:SetActive(showAgain)

    _ui.delayActive.enabled = _ui.showAgain
    _ui.oneCost.countLabel.gameObject:SetActive(showAgain)
    _ui.oneCost.icon.gameObject:SetActive(showAgain)
    LoadReward(reward, _ui.heroMsg, _ui.itemMsg)
    reward.blackMask.gameObject:SetActive(not showAgain)

    showing = not showAgain
end

function Awake()
    _ui = {}
    _ui.delayActive = transform:GetComponent("DelayActive")
    _ui.oneCost = {}
    _ui.oneCost.countLabel = transform:Find("more one/consume num"):GetComponent("UILabel")
    _ui.oneCost.icon = transform:Find("more one/consume num/Texture"):GetComponent("UITexture")

    _ui.againButton = transform:Find("more one")
    _ui.okButton = transform:Find("ok btn")

    UIUtil.SetClickCallback(_ui.okButton.gameObject, Hide)

    local reward = {}
    local rewardTransform = transform:Find("NewHeroShow") 
    LoadRewardObject(reward, rewardTransform)
    reward.item.pieceEffectObject = transform:Find("danchoutexiao").gameObject
    UIUtil.SetClickCallback(reward.blackMask.gameObject, Hide)
    
    _ui.reward = reward
    MoneyListData.AddListener(LoadCostUI)
end

function Close()
    MoneyListData.RemoveListener(LoadCostUI)
    _ui = nil
end

function Show(chestMsg, heroMsg, itemMsg, showAgain)
    Global.OpenUI(_M)
    _ui.chestMsg = chestMsg
    _ui.heroMsg = heroMsg
    _ui.itemMsg = itemMsg
    _ui.showAgain= showAgain
    LoadUI()
end
