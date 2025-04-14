module("HeroListNew", package.seeall)

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

local ui
local currentTab

local allGenerals
local allGeneralsByBaseID
local ownedGenerals
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		if not Tooltip.IsItemTipActive() then
			itemTipTarget = go
			Tooltip.ShowItemTip({BaseData = param} , "equipTips")
		else
			if itemTipTarget == go then
				Tooltip.HideItemTip()
			else
				itemTipTarget = go
				Tooltip.ShowItemTip({BaseData = param} , "equipTips")
			end
		end
		go:SendMessage("OnClick")
	else
		Tooltip.HideItemTip()
	end
end

function IsInViewport()
    return ui ~= nil
end

local function SetCurrentTab(tab)
    currentTab = tab
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

	if heroTransform:Find("rarity_icon") ~= nil then 
		hero.rarity = heroTransform:Find("rarity_icon"):GetComponent("UISprite")
		hero.rarity.gameObject:SetActive(true)
	end 
	
	
	
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

    if hero.levelLabel ~= nil then
        hero.levelLabel.text = msg.level
    end

    local star = isIllustrateList and 0 or msg.star
    SetNumber(hero.starList, star)
    if hero.starSprite ~= nil then
        hero.starSprite.width = star * hero.starHeight
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

    if hero.troopsLabel ~= nil then
        hero.troopsLabel.text = GeneralData.GetAttributes(msg, 1102)[2] -- HeroListData.GetTroops(msg, data)
    end
end

function GetPreviousGeneral(heroInfo)
    local isIllustration = heroInfo.uid == 0
    local generals = isIllustration and allGenerals or ownedGenerals
    for i, general in ipairs(generals) do
        if general.heroInfo.baseid == heroInfo.baseid then
            local previousGeneral = generals[i - 1]

            if previousGeneral then
                if isIllustration then
                    return previousGeneral.defaultHeroInfo
                else
                    return previousGeneral.heroInfo.uid ~= 0 and previousGeneral.heroInfo or nil
                end
            else
                return nil
            end
        end
    end
end

function GetNextGeneral(heroInfo)
    local isIllustration = heroInfo.uid == 0
    local generals = isIllustration and allGenerals or ownedGenerals
    for i, general in ipairs(heroInfo.uid == 0 and allGenerals or ownedGenerals) do
        if general.heroInfo.baseid == heroInfo.baseid then
            local nextGeneral = generals[i + 1]

            if nextGeneral then
                if isIllustration then
                    return nextGeneral.defaultHeroInfo
                else
                    return nextGeneral.heroInfo.uid ~= 0 and nextGeneral.heroInfo or nil
                end
            else
                return nil
            end
        end
    end

    return nil
end

function UpdateGeneralLevel(uiGeneral, heroInfo)
    uiGeneral.level.text = heroInfo.level
end

function UpdateGeneralStar(uiGeneral, heroInfo)
    uiGeneral.stars.width = heroInfo.star * 30
end

function UpdateGeneralBadgeIcon(uiGeneral, heroInfo)
    uiGeneral.Badge.icon.spriteName = "advanced_" .. heroInfo.heroGrade
end

function SetGeneralNotice(uiGeneral, hasNotice)
    uiGeneral.notice:SetActive(hasNotice)
end

function UpdateGeneral(uiGeneral, heroInfo)
    if heroInfo then
        uiGeneral.heroInfo = heroInfo
    else
        heroInfo = uiGeneral.heroInfo
    end

    local baseID = heroInfo.baseid
    local heroData = TableMgr:GetHeroData(baseID)

    uiGeneral.heroData = heroData

    uiGeneral.gameObject.name = "New Hero" .. baseID

    uiGeneral.name.text = TextMgr:GetText(heroData.nameLabel)
    uiGeneral.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", baseID)
    uiGeneral.background.spriteName = "head" .. heroData.quality

    SetGeneralNotice(uiGeneral, GeneralData.HasNotice4LevelUp(baseID))

    UpdateGeneralLevel(uiGeneral, heroInfo)
    UpdateGeneralStar(uiGeneral, heroInfo)

    local heroRule = TableMgr:GetRulesDataByStarGrade(heroInfo.star, heroInfo.grade)
    
    HeroList.LoadHeroRarity(uiGeneral.rarity,heroData,true)
	
    uiGeneral.hero_get_new.gameObject:SetActive( GeneralData.GetHeroNewState(baseID))

    if GeneralData.HasGeneralByBaseID(baseID) then
        uiGeneral.starup_notice.gameObject:SetActive(GeneralData.CanStarUp(heroInfo, heroData, heroRule))
        uiGeneral.Badge.gameObject:SetActive(true)
        uiGeneral.skills.gameObject:SetActive(true)
        uiGeneral.shards.gameObject:SetActive(false)

        UpdateGeneralBadgeIcon(uiGeneral, heroInfo)
        
        local pvpSkillData = TableMgr:GetGeneralPvpSkillData(heroInfo)
        if pvpSkillData then
            uiGeneral.skills.pvpSkill.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", pvpSkillData.iconId)
        end

        uiGeneral.skills.pveSkill.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", TableMgr:GetGodSkillDataByIdLevel(heroInfo.skill.godSkill.id, heroInfo.skill.godSkill.level).iconId)
    
        uiGeneral.fx_unlock:SetActive(false)
        uiGeneral.lock:SetActive(false)
    else
        
        uiGeneral.Badge.gameObject:SetActive(false)
        uiGeneral.skills.gameObject:SetActive(false)
        uiGeneral.shards.gameObject:SetActive(true)

        ownedShardCount, requiredShardCount = UIUtil.UpdateShardDisplay(uiGeneral.shards, heroInfo, heroData)
        if ownedShardCount < requiredShardCount then
            uiGeneral.lock:SetActive(true)
            uiGeneral.fx_unlock:SetActive(false)
        else
            uiGeneral.lock:SetActive(false)
            uiGeneral.fx_unlock:SetActive(true)
        end
    end

    ui.tabs[1].generalList.generalsByBaseID[baseID] = uiGeneral
end

function AddGeneral(heroInfo)
    local uiTab = ui.tabs[1]

    local uiGeneral = {}

    uiGeneral.gameObject = NGUITools.AddChild(uiTab.generalList.gameObject, uiTab.generalList.newGeneral)
    uiGeneral.transform = uiGeneral.gameObject.transform
    
    uiGeneral.name = uiGeneral.transform:Find("Name"):GetComponent("UILabel")
    uiGeneral.level = uiGeneral.transform:Find("Level"):GetComponent("UILabel")
    uiGeneral.stars = uiGeneral.transform:Find("Stars"):GetComponent("UISprite")
    uiGeneral.icon = uiGeneral.transform:Find("Icon"):GetComponent("UITexture")
    uiGeneral.background = uiGeneral.transform:Find("Background"):GetComponent("UISprite")
    uiGeneral.notice = uiGeneral.transform:Find("Notice").gameObject
    uiGeneral.starup_notice = uiGeneral.transform:Find("srarup_jiantou").gameObject
    uiGeneral.starup_notice.gameObject:SetActive(false)
    uiGeneral.hero_get_new = uiGeneral.transform:Find("heroget_new").gameObject
    uiGeneral.hero_get_new.gameObject:SetActive(false)
	
	if uiGeneral.transform:Find("rarity_icon") ~= nil then 
		uiGeneral.rarity = uiGeneral.transform:Find("rarity_icon"):GetComponent("UISprite")
	end 
	
    uiGeneral.Badge = {}
    uiGeneral.Badge.transform = uiGeneral.transform:Find("Badge")
    uiGeneral.Badge.gameObject = uiGeneral.Badge.transform.gameObject

    uiGeneral.Badge.icon = uiGeneral.Badge.transform:Find("Icon"):GetComponent("UISprite")
    
    uiGeneral.skills = {}
    uiGeneral.skills.transform = uiGeneral.transform:Find("Skills")
    uiGeneral.skills.gameObject = uiGeneral.skills.transform.gameObject

    uiGeneral.skills.pvpSkill = uiGeneral.skills.transform:Find("Pvp/Icon"):GetComponent("UITexture")
    uiGeneral.skills.pveSkill = uiGeneral.skills.transform:Find("Pve/Icon"):GetComponent("UITexture")

    uiGeneral.fx_unlock = uiGeneral.transform:Find("Unlock Fx").gameObject
    uiGeneral.lock = uiGeneral.transform:Find("Lock").gameObject

    uiGeneral.shards = {}
    uiGeneral.shards.transform = uiGeneral.transform:Find("Progress Bar")
    uiGeneral.shards.gameObject = uiGeneral.shards.transform.gameObject

    uiGeneral.shards.progressBar = uiGeneral.shards.transform:GetComponent("UISlider")
    uiGeneral.shards.num = uiGeneral.shards.transform:Find("Label"):GetComponent("UILabel")

    UIUtil.SetClickCallback(uiGeneral.icon.gameObject, function()
        local heroInfo = uiGeneral.heroInfo
        if heroInfo.uid ~= 0 then
            HeroInfoNew.Show(heroInfo)
            SetGeneralNotice(uiGeneral, GeneralData.HasNotice4LevelUp(heroInfo.baseid))
        else
            local heroData = uiGeneral.heroData
            local itemInfo = ItemListData.GetItemDataByBaseId(heroData.chipID)
            if itemInfo and itemInfo.number >= heroData.chipnum then
                local req = HeroMsg_pb.MsgHeroPieceToHeroRequest()
                local card = req.card:add()
                card.uid = itemInfo.uniqueid
                card.num = heroData.chipnum

                Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroPieceToHeroRequest, req, HeroMsg_pb.MsgHeroPieceToHeroResponse, function(msg)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.ShowError(msg.code)
                    else
                        MainCityUI.UpdateRewardData(msg.fresh)
                        if IsInViewport() then
                            HeroUnlock.Show(GeneralData.GetGeneralByBaseID(heroInfo.baseid))
                        end
                    end
                end)
            else
                GatherItemUI.Show(heroData.chipID, heroData.chipnum)
            end
        end
    end)

    table.insert(uiTab.generalList.generals, uiGeneral)

    UpdateGeneral(uiGeneral, heroInfo)
end

local function SortOwnedGenerals()
    table.sort(ownedGenerals, function(general1, general2)
        local heroInfo1 = general1.heroInfo
        local heroInfo2 = general2.heroInfo

        local uid1 = heroInfo1.uid
        local uid2 = heroInfo2.uid

        if uid1 ~= 0 and uid2 ~= 0 then
            return GeneralData.CompareGenerals(heroInfo1, heroInfo2)
        elseif uid1 == 0 and uid2 ~= 0 then
            local heroData1 = general1.heroData
            return ItemListData.GetItemCountByBaseId(heroData1.chipID) >= heroData1.chipnum
        elseif uid1 ~= 0 and uid2 == 0 then
            local heroData2 = general2.heroData
            return ItemListData.GetItemCountByBaseId(heroData2.chipID) < heroData2.chipnum
        else
            local heroData1 = general1.heroData
            local heroData2 = general2.heroData

            local hasEnoughShards1 = ItemListData.GetItemCountByBaseId(heroData1.chipID) >= heroData1.chipnum
            local hasEnoughShards2 = ItemListData.GetItemCountByBaseId(heroData2.chipID) >= heroData2.chipnum

            if hasEnoughShards1 ~= hasEnoughShards2 then
                return hasEnoughShards1
            else
                return GeneralData.CompareGenerals(heroInfo1, heroInfo2)
            end
        end
    end)
end

local UpdateUI1, UpdateUI2,UpdateItem
local function UpdateUI4(data, page)
    local uiTab = ui.tabs[4]
	local childCount = uiTab.listGrid.transform.childCount
    local index = 0
	for i, v in ipairs(data) do
		local item
		if i <= childCount then
			item = uiTab.listGrid.transform:GetChild(i - 1).transform
		else
			item = NGUITools.AddChild(uiTab.listGrid.gameObject, uiTab.itemPrefab.gameObject).transform
        end
		UpdateItem(item, v)
		if page == 2 then
			local temp = {}
			temp.gameObject = item.gameObject
			temp.BaseData = v.BaseData
			table.insert(itemtipslist, temp)
        end
        SetParameter(item.gameObject, v.BaseData)
		index = i
    end

        for i = index, childCount - 1 do
            GameObject.Destroy(uiTab.listGrid.transform:GetChild(i).gameObject)
        end


	uiTab.listGrid:Reposition()
	uiTab.listScrollView:ResetPosition()
end

UpdateUI1 = function()
	curpage = 1
	local equiplist = {}  
    equiplist = HeroEquipData.GetEquipList()
	UpdateUI4(equiplist, 1)
end

UpdateUI2 = function()
	curpage = 2
    local materiallist = HeroEquipData.GetMaterialList()
    itemtipslist = {}
	UpdateUI4(materiallist, 2)
end

UpdateItem = function(item, data)
	item:GetComponent("UISprite").spriteName = "bg_item" .. data.data.quality
	item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", data.BaseData.icon)
	item:Find("Sprite01").gameObject:SetActive(data.data.parent.pos ~= nil and data.data.parent.pos > 0)
	item:Find("Sprite02").gameObject:SetActive(data.data.status > 0)
	local level = item:Find("level/num"):GetComponent("UILabel")
	if data.BaseData.type == 200 then
		local hasequip, materials, isMax = EquipData.CheckMaterials(data.data.baseid, true)
		local canUpgrade = isMax == nil
		for i, v in ipairs(materials) do
			if v.has < v.need then
				canUpgrade = false
			end
		end
		item:Find("Sprite").gameObject:SetActive(canUpgrade and data.data.status == 0)
		level.text = data.BaseData.itemlevel
		level.transform.parent.gameObject:SetActive(data.BaseData.itemlevel > 0)
	else
		item:Find("Sprite").gameObject:SetActive(false)
		level.transform.parent.gameObject:SetActive(false)
	end
	local num = item:Find("num_item"):GetComponent("UILabel")
	num.text = data.data.number
	num.gameObject:SetActive(data.data.number > 1)
end


local function UpdateUI(tab)
    if not tab then
        for tab, _ in ipairs(ui.tabs) do
            UpdateUI(tab)
        end
    else
        coroutine.stop(ui.coroutines[tab])
        if tab == 1 then
            SortOwnedGenerals()

            ui.coroutines[1] = coroutine.start(function()
                coroutine.step()
                local uiTab = ui.tabs[1]

                local numOwnedGenerals = #ownedGenerals
                local uiGenerals = ui.tabs[1].generalList.generals
                for i = 1, math.max(#uiGenerals, numOwnedGenerals) do
                    if i > numOwnedGenerals then
                        uiGenerals[i].gameObject:SetActive(false)
                    else
                        if i > #uiGenerals then
                            AddGeneral(ownedGenerals[i].heroInfo)
                        else
                            UpdateGeneral(uiGenerals[i], ownedGenerals[i].heroInfo)
                        end
                    end
                    
                    if i % 4 == 0 and i >= 8 then
                        uiTab.generalList.grid:Reposition()
                        coroutine.step()
                    end
                end

                uiTab.generalList.grid:Reposition()
            end)
        elseif tab == 2 then
            ui.coroutines[2] = coroutine.start(function()
                local uiTab = ui.tabs[2]

                for i, general in ipairs(allGenerals) do
                    local uiGeneral = LoadHeroObject({}, NGUITools.AddChild(uiTab.generalList.gameObject, uiTab.generalList.newGeneral).transform)

                    LoadHero(uiGeneral, general.heroInfo, general.heroData, true)
                    
					HeroList.LoadHeroRarity(uiGeneral.rarity,general.heroData,true)
                    uiGeneral.nameLabel.gameObject:SetActive(true)
                    uiGeneral.levelLabel.gameObject:SetActive(false)

                    SetClickCallback(uiGeneral.btn.gameObject, function()
                        HeroInfoNew.Show(general.defaultHeroInfo)
                    end)

                    uiTab.generalList.generalsByBaseID[general.heroData.id] = uiGeneral
                    
                    if i % 4 == 0 and i >= 12 then
                        uiTab.generalList.grid:Reposition()
                        coroutine.step()
                    end
                end
                uiTab.generalList.grid:Reposition()
            end)
        elseif tab == 3 then
            ui.coroutines[3] = coroutine.start(function()
                local itemList = {}
                for i, v in ipairs(ItemListData.GetData()) do
                    local itemData = tableData_tItem.data[v.baseid]
                    if itemData.type >= 52 and itemData.type <= 56 then
                        table.insert(itemList, {v, itemData})
                    end
                end

                table.sort(itemList, function(v1, v2)
                    local itemData1 = v1[2]
                    local itemData2 = v2[2]
                    if itemData1.type ~= itemData2.type then
                        return itemData1.type > itemData2.type
                    elseif itemData1.quality ~= itemData2.quality then
                        return itemData1.quality > itemData2.quality
                    else
                        return itemData1.id < itemData2.id
                    end
                end)

                local uiTab = ui.tabs[3]
                local item = {}
                for i, v in ipairs(itemList) do
                    local itemTransform
                    if i > uiTab.listGrid.transform.childCount then
                        itemTransform = NGUITools.AddChild(uiTab.listGrid.gameObject, uiTab.itemPrefab).transform
                    else
                        itemTransform = uiTab.listGrid.transform:GetChild(i - 1)
                    end

                    UIUtil.LoadHeroItemObject(item, itemTransform)
                    UIUtil.LoadHeroItem(item, v[2], v[1].number)
                    SetClickCallback(item.iconObject, function()
                        SellHeroItem.Show(v[1])
                    end)
                    itemTransform.gameObject:SetActive(true)
                    if i % 6 == 0 and i >= 24 then
                        uiTab.listGrid.repositionNow = true
                        coroutine.step()
                    end
                end
                for i = #itemList + 1, uiTab.listGrid.transform.childCount do
                    uiTab.listGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
                end
                uiTab.listGrid.repositionNow = true
            end)
        elseif tab == 4 then
            ui.coroutines[4] = coroutine.start(function()
                UpdateUI2()
                UpdateUI1()
                
            end)
            
        end
    end
end

local function ShowTab(tab)
    SetCurrentTab(tab)
end

function Show(tab, ignoreOpenSound)
    if not ignoreOpenSound then
        AudioMgr:PlayUISfx("SFX_UI_interface02_on", 1, false)
    end
    
    if not IsInViewport() then
        Global.OpenUI(_M)

        SetCurrentTab(tab)
    else
        ShowTab(tab)
    end
end

function Hide(ignoreCloseCound)
    if not ignoreCloseCound then
        AudioMgr:PlayUISfx("SFX_UI_interface02_off", 1, false)
    end

    Global.CloseUI(_M)
end

function Awake()
    local uiTab1 = {}

    uiTab1.transform = transform:Find("background widget/bg2/content 1")
    uiTab1.gameObject = uiTab1.transform.gameObject

    uiTab1.generalList = UIUtil.LoadList(uiTab1.transform:Find("Scroll View"))
    uiTab1.generalList.newGeneral = uiTab1.transform:Find("New Hero").gameObject
    uiTab1.generalList.generals = {}
    uiTab1.generalList.generalsByBaseID = {}

    local uiTab2 = {}

    uiTab2.transform = transform:Find("background widget/bg2/content 2")
    uiTab2.gameObject = uiTab2.transform.gameObject

    uiTab2.generalList = UIUtil.LoadList(uiTab2.transform:Find("Scroll View"))
    uiTab2.generalList.newGeneral = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    uiTab2.generalList.generalsByBaseID = {}

    local uiTab3 = {}

    uiTab3.transform = transform:Find("background widget/bg2/content 3")
    uiTab3.gameObject = uiTab3.transform.gameObject

    uiTab3.listScrollView = uiTab3.transform:Find("Scroll View")
    uiTab3.listGrid = uiTab3.transform:Find("Scroll View/Grid"):GetComponent("UIGrid")
    uiTab3.itemPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero_item")

    uiTab3.tips_empty = uiTab3.transform:Find("no one").gameObject


    local uiTab4 = {}
    uiTab4.transform = transform:Find("background widget/bg2/content 4")
    uiTab4.gameObject = uiTab4.transform.gameObject

    uiTab4.listScrollView = uiTab4.transform:Find("bg/content 1/Scroll View"):GetComponent("UIScrollView")
    uiTab4.listGrid = uiTab4.transform:Find("bg/content 1/Scroll View/Grid"):GetComponent("UIGrid")
    uiTab4.itemPrefab = uiTab4.transform:Find("item_equip")
	uiTab4.page1 = uiTab4.transform:Find("bg/page1"):GetComponent("UIToggle")
	uiTab4.page2 = uiTab4.transform:Find("bg/page2"):GetComponent("UIToggle")

	SetClickCallback(uiTab4.page1.gameObject, UpdateUI1)
	SetClickCallback(uiTab4.page2.gameObject, UpdateUI2)

    UIUtil.SetClickCallback(transform:Find("mask").gameObject, Hide)
    UIUtil.SetClickCallback(transform:Find("background widget/close btn").gameObject, Hide)

    ui = {}
    ui.coroutines = {}
    ui.tabs = { uiTab1, uiTab2, uiTab3,uiTab4 }

    for i = 1, 4 do
        local toggle = transform:Find(string.format("background widget/bg2/page%d", i)):GetComponent("UIToggle")
        ui.tabs[i].toggle = toggle
        if i == 3 or i == 4 then
            EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
				if ui then
                    ui.tabs[i].listGrid:Reposition()
                    if i == 4 then
                        ui.tabs[i].page1:Set(true)
                        ui.tabs[i].page2:Set(false)
                        UpdateUI1()
                    end
				end
            end))
        else
            EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
				if ui then
					ui.tabs[i].generalList.grid:Reposition()
				end
            end))
        end
    end

    EventDispatcher.Bind(GeneralData.OnGeneralLevelChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo)
        UpdateGeneralLevel(ui.tabs[1].generalList.generalsByBaseID[heroInfo.baseid], heroInfo)
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralStarChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo)
        UpdateGeneralStar(ui.tabs[1].generalList.generalsByBaseID[heroInfo.baseid], heroInfo)
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralGradeChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo)
        UpdateGeneralBadgeIcon(ui.tabs[1].generalList.generalsByBaseID[heroInfo.baseid], heroInfo)
    end)

    EventDispatcher.Bind(GeneralData.OnNoticeStatusChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo, hasNotice)
        local uiGeneral = ui.tabs[1].generalList.generalsByBaseID[heroInfo.baseid]
        if uiGeneral then
            SetGeneralNotice(uiGeneral, hasNotice)
        end
    end)

    EventDispatcher.Bind(GeneralData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, function(params)
        for _, args in ipairs(params) do
            if args[2] > 0 then
                local baseID = args[1].baseid
                local general = allGeneralsByBaseID[baseID]

                if not ui.tabs[1].generalList.generalsByBaseID[baseID] then
                    table.insert(ownedGenerals, general)
                end

                LoadHero(ui.tabs[2].generalList.generalsByBaseID[baseID], general.heroInfo, general.heroData, true)
            end
        end
        
        UpdateUI(1)
    end)

    EventDispatcher.Bind(ItemListData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(itemInfo, change)
        UpdateUI(1)

        UpdateUI(3)
    end)
end

function Start()
    Tooltip.HideItemTip()
    ownedGenerals = {}
    for _, general in ipairs(allGenerals) do
        if general.heroInfo.uid == 0 then
            if ItemListData.GetItemCountByBaseId(general.heroData.chipID) > 0 then
                table.insert(ownedGenerals, general)
            end
        else
            table.insert(ownedGenerals, general)
        end
    end

    UpdateUI()
    AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Close()
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    Tooltip.HideItemTip()
    EventDispatcher.UnbindAll(_M)

    for i = 1, 4 do
        coroutine.stop(ui.coroutines[i])
    end

    GeneralData.ClearHeroNewState()
    ui = nil
    ownedGenerals = nil
end

function Initialize()
    allGenerals = {}
    allGeneralsByBaseID = {}
    for _, heroData in pairs(TableMgr:GetHeroTable()) do
        if heroData.isShow ~= 0 then
            local general = {}
            general.heroData = heroData

            if GeneralData.HasGeneralByBaseID(heroData.id) then
                general.heroInfo = GeneralData.GetGeneralByBaseID(heroData.id)
            else
                general.heroInfo = GeneralData.GetDefaultHeroData(heroData)
            end
            
            general.defaultHeroInfo = GeneralData.GetDefaultHeroData(heroData, GeneralData.MAX_LEVEL, GeneralData.MAX_STAR, 1, GeneralData.MAX_GRADE)

            table.insert(allGenerals, general)
            allGeneralsByBaseID[heroData.id] = general
        end
    end

    table.sort(allGenerals, function(general1, general2)
        if general1.heroData.quality ~= general2.heroData.quality then
            return general1.heroData.quality > general2.heroData.quality
        else
            return general1.heroData.id < general2.heroData.id
        end
    end)

    EventDispatcher.Bind(GeneralData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(heroInfo, change)
        if change > 0 then
            allGeneralsByBaseID[heroInfo.baseid].heroInfo = heroInfo
        end
    end)
end
