module("HeroList", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local SetNumber = Global.SetNumber

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local AudioMgr = Global.GAudioMgr

local HeroExpDiscountFactor
local illustrateHeroList
local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll(ignoreCloseCound)
    if not ignoreCloseCound then
        AudioMgr:PlayUISfx("SFX_UI_interface02_off", 1, false)
    end
    HeroInfo.CloseAll()
    Hide()
end

function LoadHeroSmallStarObject(smallStarList, smallStarTransform)
    smallStarList.transform = smallStarTransform
    for i = 2, 5 do
        local starList = {}
        starList.star = smallStarTransform:Find(string.format("star%d", i))
        starList.list = {}
        for j = 1, i - 1 do
            starList.list[j] = starList.star:Find(string.format("frame%d", j)):GetComponent("UIButton")
        end
        smallStarList[i] = starList
    end
end

function LoadHeroSmallStarList(smallStarList, star, grade, heroData, alwaysVisible)
    for i = 2, 5 do
        smallStarList[i].star.gameObject:SetActive(i == star and (grade > 0 or alwaysVisible))
    end
    if star >= 2 and star <= 5 then
        for i, v in ipairs(smallStarList[star].list) do
            v.enabled = i >= grade
        end
    end
end

function LoadHeroRarity(icon,data,isSmall)
	if icon == nil or data ==nil then
		return 
	end 
	local tag =""
	if isSmall == true then 
		tag ="1"
	end 
	if data.Rarity == 6 then 
		icon.spriteName = "sss"..tag
	elseif data.Rarity == 5 then
		icon.spriteName = "s"..tag
	elseif data.Rarity == 4 then
		icon.spriteName = "a"..tag
	elseif data.Rarity == 3 then
		icon.spriteName = "b"..tag
	elseif data.Rarity == 2 then
		icon.spriteName = "c"..tag
	elseif data.Rarity == 1 then
		icon.spriteName = "d"..tag
	end
	
	
end 

function LoadBadgeObjectList(badgeList, badgeBg)
    for i = 1, 6 do
        local badge = {}
        badge.widget = badgeBg:Find(string.format("medal (%d)/", i)):GetComponent("UIWidget")
        badge.effect = badgeBg:Find(string.format("medal (%d)/HuiZhang", i))
        badge.icon = badgeBg:Find(string.format("medal (%d)/medal btn", i)):GetComponent("UITexture")
        badge.btn = badgeBg:Find(string.format("medal (%d)/medal btn", i)):GetComponent("UIButton")
        badge.quality = badgeBg:Find(string.format("medal (%d)/medal btn/outline1", i)):GetComponent("UISprite")
        badge.lock = badgeBg:Find(string.format("medal (%d)/lock", i))
        badge.stateSprite = badgeBg:Find(string.format("medal (%d)/medal btn/state", i)):GetComponent("UISprite")
        badge.notice = badgeBg:Find(string.format("medal (%d)/medal btn/state/red", i))
        badge.max = badgeBg:Find(string.format("medal (%d)/medal btn/max", i))
        badgeList[i] = badge
    end
end

function LoadBadgeList(badgeObjectList, badgeList)
    for i, v in ipairs(badgeList) do
        local badge = badgeObjectList[i]
        badge.icon.mainTexture = ResourceLibrary:GetIcon("Item/", v.data.icon)
        badge.quality.spriteName = "medal_level_"..(v.msg ~= nil and v.msg.quality or 1)
        badge.lock.gameObject:SetActive(v.gradeEnough and not v.msg)
        local stateVisible = not v.maxQuality and v.gradeEnough
        badge.stateSprite.gameObject:SetActive(stateVisible)
        local noticeVisible = false
        if stateVisible then
            if v.gradeEnough and v.levelEnough and v.itemEnough then
                badge.stateSprite.spriteName = "plus_green"
                noticeVisible = true
            elseif not v.itemEnough then
                badge.stateSprite.spriteName = "plus_yellow"
            elseif not v.levelEnough then
                badge.stateSprite.spriteName = "plus_white"
            end
        end
        if badge.notice ~= nil then
            badge.notice.gameObject:SetActive(noticeVisible)
        end
        badge.max.gameObject:SetActive(v.maxQuality)
        badge.widget.alpha = (v.msg  ~= nil and v.gradeEnough) and 0.7 or 1

        badge.msg = v.msg
        badge.data = v.data
        if badge.effect ~= nil then
            badge.effect.gameObject:SetActive(false)
        end
    end
end

function LoadHeroObject(hero, heroTransform)
    if heroTransform == nil then
        return
    end
    hero.transform = heroTransform
    hero.gameObject = heroTransform.gameObject
    hero.lock = heroTransform:Find("lock")
    hero.unlock = heroTransform:Find("unlock")
    hero.mask = heroTransform:Find("select")
    hero.icon = heroTransform:Find("head icon"):GetComponent("UITexture")
    hero.btn = heroTransform:Find("head icon"):GetComponent("UIButton")
    hero.btnTip = heroTransform:Find("bg_skill")
    local countTransform = heroTransform:Find("num")
    if countTransform ~= nil then
        hero.countLabel = countTransform:GetComponent("UILabel")
    end
    hero.qualityList = {}
    for i = 1, 5 do
        hero.qualityList[i] = heroTransform:Find("head icon/outline"..i)
    end
    hero.qualityTransform = heroTransform:Find("head icon/outline")
    if hero.qualityTransform ~= nil then
        hero.qualitySprite = hero.qualityTransform:GetComponent("UISprite")
    end
    local nameTransform = heroTransform:Find("name text")
    if nameTransform ~= nil then
        hero.nameLabel = nameTransform:GetComponent("UILabel")
    end
    hero.levelLabel = heroTransform:Find("level text"):GetComponent("UILabel")
    hero.starList = {}
    for i = 1, 6 do
        hero.starList[i] = heroTransform:Find("star/star"..i)
    end
    hero.starSprite = heroTransform:Find("star"):GetComponent("UISprite")
    if hero.starSprite ~= nil then
        hero.starHeight = hero.starSprite.height
    end

    hero.notice = heroTransform:Find("red dot")
    local skillIconTransform = heroTransform:Find("bg_skill/icon_skill")
    if skillIconTransform ~= nil then
        hero.skillIcon = skillIconTransform:GetComponent("UITexture")
    end

    local stateBg = heroTransform:Find("occupy")

    if stateBg ~= nil then
        hero.stateBg = stateBg
        local stateList = {}
        stateList.setout = stateBg:Find("chuzhan")
        stateList.defense = stateBg:Find("shoucheng")
        stateList.pve = stateBg:Find("changyong")
        stateList.appoint = stateBg:Find("weiren")
        hero.stateList = stateList
    end

    local badgeBg = heroTransform:Find("advanced")
    if badgeBg ~= nil then
        hero.badgeBgObject = badgeBg.gameObject
        hero.gradeSprite = badgeBg:Find("advanced bg/icon"):GetComponent("UISprite")
        local badgeList = {}
        LoadBadgeObjectList(badgeList, badgeBg)
        hero.badgeList = badgeList
    end

    local shardTransform = heroTransform:Find("exp bar")
    if shardTransform ~= nil then
        hero.shardTransform = shardTransform
        hero.shardSlider = shardTransform:GetComponent("UISlider")
        hero.shardLabel = shardTransform:Find("Label"):GetComponent("UILabel")
    end

    return hero
end

function LoadHero(hero, msg, data, isIllustrateList)

    hero.msg = msg
    hero.data = data
    if hero.picture ~= nil then
        hero.picture.mainTexture = ResourceLibrary:GetIcon("Icon/hero_half/", data.picture)
    end
    if hero.icon ~= nil then
        hero.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", data.icon)
    end
    SetNumber(hero.qualityList, data.quality)
    if hero.qualitySprite ~= nil then
        hero.qualitySprite.spriteName = "head"..data.quality
    end
    if hero.nameLabel ~= nil then
        hero.nameLabel.text = TextMgr:GetText(data.nameLabel)
    end
    if hero.gradeSprite ~= nil then
        hero.gradeSprite.spriteName = "advanced_"..msg.heroGrade
    end
	
	LoadHeroRarity(hero.rarity,data,false)
	
    if hero.levelLabel ~= nil then
        hero.levelLabel.text = msg.level
    end
    SetNumber(hero.starList, msg.star)
    if hero.starSprite ~= nil then
        hero.starSprite.width = msg.star * hero.starHeight
    end
    if hero.expBar ~= nil then
        local heroLevel = TableMgr:GetHeroLevelByExp(msg.exp)
        hero.expBar.value = heroLevel - math.floor(heroLevel)
    end
    if hero.countLabel ~= nil and not isIllustrateList then
        if hero.data.expCard then
            hero.countLabel.gameObject:SetActive(true)
            hero.countLabel.text = msg.num
        else
            hero.countLabel.gameObject:SetActive(false)
        end
    end
    if hero.smallStarList ~= nil then
        LoadHeroSmallStarList(hero.smallStarList, msg.star, msg.grade, data, true)
    end
    if hero.skillIcon ~= nil then
        local skillId = 0
        local skillLevel = 1
        local skillMsg
        if msg.skill then -- 区分heroInfo和heroBaseInfo
            skillMsg = msg.skill.godSkill
        end
        if skillMsg ~= nil then
            skillId = skillMsg.id
            skillLevel = skillMsg.level
        else
            skillId = tonumber(TableMgr:GetHeroData(msg.baseid).skillId)
        end
        local skillData = TableMgr:GetGodSkillDataByIdLevel(skillId, skillLevel)
        if skillData ~= nil then
            hero.skillIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
        else
            hero.skillIcon.transform.parent.gameObject:SetActive(false)
        end
    end
    if hero.gradeSprite ~= nil then
        hero.gradeSprite.spriteName = "advanced_"..msg.heroGrade
    end
    if hero.badgeList ~= nil then
        local isHero = msg.uid ~= 0 and not data.expCard
        hero.badgeBgObject:SetActive(isHero)
        if isHero then
            local badgeList = HeroListData.GetBadgeList(msg, data)
            LoadBadgeList(hero.badgeList, badgeList)
        end
    end

    local heroUid = msg.uid
    local shardCount = 0
    local requiredShardCount = 0
    if hero.shardTransform ~= nil then
        if heroUid == 0 then
            requiredShardCount = data.chipnum
        else
            local rulesData = TableMgr:GetRulesDataByStarGrade(msg.star, msg.grade)
            requiredShardCount = rulesData.num
        end
        shardCount = ItemListData.GetItemCountByBaseId(data.chipID)
        hero.shardSlider.value = shardCount / requiredShardCount
        hero.shardLabel.text = string.format("%d/%d", shardCount, requiredShardCount)
    end

    local shardEnough = shardCount >= requiredShardCount
    if hero.lock ~= nil then
        if isIllustrateList then
            hero.lock.gameObject:SetActive(heroUid == 0 --[[ ActiveHeroData.HasHero(data.id)]])
        else
            hero.lock.gameObject:SetActive(heroUid == 0 and not shardEnough)
        end
    end
    if hero.unlock ~= nil then
        hero.unlock.gameObject:SetActive(heroUid == 0 and shardEnough)
    end

    if hero.troopsObject ~= nil then
        hero.troopsObject:SetActive(Global.IsOutSea())
    end
    if hero.troopsLabel ~= nil then
        hero.troopsLabel.text = GeneralData.GetAttributes(msg, 1102)[2]
    end
end

local function UpdateHeroListMsg()
    local dataList = {}
    local heroTable = TableMgr:GetHeroTable()
    for _, v in pairs(heroTable) do
        dataList[v.id] = {v}
    end

    _ui.heroListMsg = {}
    local heroListMsg = HeroListData.GetSortedHeroes()
    for _, v in ipairs(heroListMsg) do
        table.insert(_ui.heroListMsg, v)
        dataList[v.baseid] = nil
    end

    heroListMsg = {}
    for k, v in pairs(dataList) do
        local shardCount = ItemListData.GetItemCountByBaseId(v[1].chipID)
        if shardCount == 0 then
            dataList[k] = nil
        else
            dataList[k][2] = shardCount
            table.insert(heroListMsg, HeroListData.GetDefaultHeroData(v[1]))
        end
    end

    table.sort(heroListMsg, function(v1, v2)
        local data1 = dataList[v1.baseid]
        local data2 = dataList[v2.baseid]

        local heroData1 = data1[1]
        local heroData2 = data2[1]
        local percent1 = data1[2] / heroData1.chipnum
        local percent2 = data2[2] / heroData2.chipnum
        if percent1 == percent2 then
            if heroData1.quality == heroData2.quality then
                return heroData1.id < heroData2.id
            end

            return heroData1.quality > heroData2.quality
        end

        return percent1 > percent2
    end)

    for _, v in ipairs(heroListMsg) do
        local data = dataList[v.baseid]
        if data[2] / data[1].chipnum >= 1 then
            table.insert(_ui.heroListMsg, 1, v)
        else
            table.insert(_ui.heroListMsg, v)
        end
    end
end

local function LoadHeroList()
    UpdateHeroListMsg()
    local heroListMsg = _ui.heroListMsg
    for i, v in ipairs(heroListMsg) do
        local heroTransform
        if i > _ui.heroListTransform.childCount then
            heroTransform = NGUITools.AddChild(_ui.heroListGrid.gameObject, _ui.heroPrefab).transform
            if i > 1 and (i - 1) % 8 == 0 then
                _ui.heroListGrid.repositionNow = true
                coroutine.step()
            end
        else
            heroTransform = _ui.heroListTransform:GetChild(i - 1)
        end
        local heroMsg = v
        local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
        local hero = {}
        LoadHeroObject(hero, heroTransform)
        LoadHero(hero, heroMsg, heroData)
        hero.shardTransform.gameObject:SetActive(heroMsg.uid == 0)
        heroTransform.gameObject.name = _ui.heroPrefab.name..heroMsg.baseid
        local badgeList = HeroListData.GetBadgeList(heroMsg, heroData)
        hero.notice.gameObject:SetActive(HeroListData.HeroHasNotice(heroMsg, heroData, badgeList))
        SetClickCallback(hero.btn.gameObject, function(go)
            if heroMsg.uid ~= 0 then
                CloseAll(true)
                -- HeroInfo.Show(heroMsg.uid, heroMsg.baseid)
                HeroInfoNew.Show(heroMsg)
            else
                local itemMsg = ItemListData.GetItemDataByBaseId(heroData.chipID)
                if itemMsg ~= nil and itemMsg.number >= heroData.chipnum then
                    local req = HeroMsg_pb.MsgHeroPieceToHeroRequest()
                    local card = req.card:add()
                    card.uid = itemMsg.uniqueid
                    card.num = heroData.chipnum
                    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroPieceToHeroRequest, req, HeroMsg_pb.MsgHeroPieceToHeroResponse, function(msg)
                        if msg.code ~= ReturnCode_pb.Code_OK then
                            Global.ShowError(msg.code)
                        else
                            MainCityUI.UpdateRewardData(msg.fresh)
                            if _ui ~= nil then
                                _ui.unlockHeroBaseId = heroMsg.baseid
                                HeroUnlock.Show(HeroListData.GetHeroDataByBaseId(_ui.unlockHeroBaseId))
                                LoadUI()
                            end
                        end
                    end)
                else
                    GatherItemUI.Show(heroData.chipID, heroData.chipnum)
                end
            end
        end)
        heroTransform.gameObject:SetActive(true)
    end

    for i = #heroListMsg + 1, _ui.heroListGrid.transform.childCount do
        _ui.heroListGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.heroListGrid.repositionNow = true
end

local function LoadIllustrateDataList()
    if illustrateHeroList == nil then
        illustrateHeroList = {}
        local heroTable = TableMgr:GetHeroTable()
        for _, v in pairs(heroTable) do
            local hero = {}
            hero.data = v
            hero.msg = HeroListData.GetDefaultHeroData(hero.data)
            table.insert(illustrateHeroList, hero)
        end

        table.sort(illustrateHeroList, function(t1, t2)
            if t1.data.quality == t2.data.quality then
                return t1.data.id < t2.data.id
            end
            return t1.data.quality > t2.data.quality
        end)
    end
end

local function LoadIllustrateList()
    for i, v in ipairs(illustrateHeroList) do
    	if v.data.isShow ~= 0 then
	        local heroTransform
	        if i > _ui.illustrateListTransform.childCount then
	            heroTransform = NGUITools.AddChild(_ui.illustrateListGrid.gameObject, _ui.illustratePrefab).transform
	            heroTransform.gameObject.name = _ui.illustratePrefab.name..i
	            if i > 1 and (i - 1) % 12 == 0 then
	                _ui.illustrateListGrid.repositionNow = true
	                coroutine.step()
	            end
	        else
	            heroTransform = _ui.illustrateListTransform:GetChild(i - 1)
	        end

	        local hero = {} 
	        LoadHeroObject(hero, heroTransform)
	        LoadHero(hero, v.msg, v.data, true)
	        hero.nameLabel.gameObject:SetActive(true)
	        SetClickCallback(hero.btn.gameObject, function(go)
	            CloseAll(true)
	            HeroInfo.Show(0, v.data.id)
	        end)
	        hero.levelLabel.gameObject:SetActive(false)
	    end
    end
    _ui.illustrateListGrid.repositionNow = true
end

function GetIllustrateHero(heroId)
    for i, v in ipairs(illustrateHeroList) do
        if v.data.id == heroId then
            return v, i, i == #illustrateHeroList
        end
    end
end

function GetPreviousIllustrateHero(heroId)
    local _, i = GetIllustrateHero(heroId)
    return illustrateHeroList[i - 1]
end

function GetNextIllustrateHero(heroId)
    local _, i = GetIllustrateHero(heroId)
    return illustrateHeroList[i + 1]
end

local function LoadItemList()
    local itemListData = ItemListData.GetData()
    local heroItemList = {}
    for _, v in ipairs(itemListData) do
        local itemData = TableMgr:GetItemData(v.baseid)
        local type = itemData.type
        if type >= 52 and type <= 56 then
            local item = {}
            item.data = itemData
            item.msg = v
            table.insert(heroItemList, item)
        end
    end

    table.sort(heroItemList, function(t1, t2)
        local data1 = t1.data
        local data2 = t2.data
        if data1.type == data2.type then
            if data1.quality == data2.quality then
                return data1.id < data2.id
            end
            return data1.quality > data2.quality
        end
        return data1.type > data2.type
    end)

    local itemIndex = 1
    for i, v in ipairs(heroItemList) do
        local itemData = v.data
        local itemTransform
        if i > _ui.itemListTransform.childCount then
            itemTransform = NGUITools.AddChild(_ui.itemListGrid.gameObject, _ui.itemPrefab).transform
            itemTransform.gameObject.name = _ui.itemPrefab.name..itemIndex
            if i > 1 and (i - 1) % 30 == 0 then
                _ui.itemListGrid.repositionNow = true
                coroutine.step()
            end
        else
            itemTransform = _ui.itemListTransform:GetChild(itemIndex - 1)
        end
        itemTransform.gameObject:SetActive(true)
        local item = {}
        UIUtil.LoadHeroItemObject(item, itemTransform)
        UIUtil.LoadHeroItem(item, itemData, v.msg.number)

        SetClickCallback(item.iconObject, function(go)
            SellHeroItem.Show(v.msg)
        end)

        itemIndex = itemIndex + 1
    end
    _ui.itemListEmpty.gameObject:SetActive(itemIndex == 1)
    for i = itemIndex, _ui.itemListTransform.childCount do
        _ui.itemListTransform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.itemListGrid.repositionNow = true
end

function LoadUI()
    if _ui == nil then
        return
    end
    for i, v in ipairs(_ui.toggleList) do
        if v.value then
            if i == 1 then
                if _ui.loadHeroListCoroutine ~= nil then
                    coroutine.stop(_ui.loadHeroListCoroutine)
                end
                _ui.loadHeroListCoroutine = coroutine.start(LoadHeroList)
            elseif i == 2 then
                if _ui.loadIllustrateCoroutine ~= nil then
                    coroutine.stop(_ui.loadIllustrateCoroutine)
                end
                _ui.loadIllustrateCoroutine = coroutine.start(LoadIllustrateList)
            elseif i == 3 then
                if _ui.loadItemCoroutine ~= nil then
                    coroutine.stop(_ui.loadItemCoroutine)
                end
                _ui.loadItemCoroutine = coroutine.start(LoadItemList)
            end
        end
    end
end

function Awake()
    LoadIllustrateDataList()
    _ui = {}
    if HeroExpDiscountFactor == nil then 
        HeroExpDiscountFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.HeroExpDiscountFactor).value)
    end
    _ui.illustrateList = {}
    local btnClose = transform:Find("background widget/close btn")
    local mask = transform:Find("mask")
    _ui.heroListPanel = transform:Find("background widget/bg2/content 1/Scroll View"):GetComponent("UIPanel")
    _ui.heroListScrollView = transform:Find("background widget/bg2/content 1/Scroll View"):GetComponent("UIScrollView")
    _ui.heroListTransform = transform:Find("background widget/bg2/content 1/Scroll View/Grid")
    _ui.heroListGrid = _ui.heroListTransform:GetComponent("UIGrid")
    _ui.heroPrefab = _ui.heroListTransform:GetChild(0).gameObject
    _ui.heroPrefab:SetActive(false)
    _ui.heroListEmpty = transform:Find("background widget/bg2/content 1/no one")
    _ui.listHeroClipHeight = _ui.heroListPanel.baseClipRegion.w

    _ui.illustrateListTransform = transform:Find("background widget/bg2/content 2/Scroll View/Grid")
    _ui.illustrateListGrid = _ui.illustrateListTransform:GetComponent("UIGrid")

    SetClickCallback(btnClose.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui.illustratePrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    _ui.itemListTransform = transform:Find("background widget/bg2/content 3/Scroll View/Grid")
    _ui.itemListGrid = _ui.itemListTransform:GetComponent("UIGrid")
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero_item")
    _ui.itemListEmpty = transform:Find("background widget/bg2/content 3/no one")

    _ui.heroList = {}
    local toggleList = {}
    for i = 1, 3 do
        local toggle = transform:Find(string.format("background widget/bg2/page%d", i)):GetComponent("UIToggle")
        toggleList[i] = toggle
        EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
            if _ui ~= nil then
                if toggle.value then
                    LoadUI()
                end
            end
        end))
    end

    _ui.toggleList = toggleList

    HeroListData.AddListener(LoadUI)
    ItemListData.AddListener(LoadUI)
end

function Close()
    HeroListData.RemoveListener(LoadUI)
    ItemListData.RemoveListener(LoadUI)
    if _ui.loadHeroListCoroutine ~= nil then
        coroutine.stop(_ui.loadHeroListCoroutine)
    end

    if _ui.loadIllustrateCoroutine ~= nil then
        coroutine.stop(_ui.loadIllustrateCoroutine)
    end

    if _ui.loadItemCoroutine ~= nil then
        coroutine.stop(_ui.loadItemCoroutine)
    end
    _ui = nil
end

function Show(toggleIndex, ignoreOpenSound)
    HeroListNew.Show(toggleIndex, ignoreOpenSound)
    -- if not ignoreOpenSound then
    --     AudioMgr:PlayUISfx("SFX_UI_interface02_on", 1, false)
    -- end
    -- Global.OpenUI(_M)
    -- if toggleIndex ~= nil then
    --     for i, v in ipairs(_ui.toggleList) do
    --         v.value = i == toggleIndex
    --     end
    -- end
end
