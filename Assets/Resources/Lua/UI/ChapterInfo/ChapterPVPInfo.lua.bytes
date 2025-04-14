module("ChapterPVPInfo", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _ui
local battleId

function Hide()
    Global.CloseUI(_M)
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function LoadUI()
    local totalPower = 0
    local battleData = TableMgr:GetBattleData(battleId)
    local battleMsg = ChapterListData.GetLevelData(battleId)
    local heroIndex = 1
    if battleData.HeroID ~= "" then
        for v in string.gsplit(battleData.HeroID, ";") do
            local paramList = string.split(v, ":")
            local heroId = tonumber(paramList[1])
            local heroLevel = tonumber(paramList[2])
            local heroStarLevel = tonumber(paramList[3])
            local heroData = tableData_tHero.data[tonumber(heroId)] 
            local heroMsg = GeneralData.GetDefaultHeroData(heroData)
            heroMsg.level = heroLevel
            heroMsg.star = heroStarLevel
            totalPower = totalPower + GeneralData.GetPower(heroMsg)

            local hero = _ui.heroList[heroIndex]
            HeroList.LoadHero(hero, heroMsg, heroData)
            SetClickCallback(hero.btn.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
                end
            end)
            hero.gameObject:SetActive(true)

            heroIndex = heroIndex + 1
        end
    end

    for i = heroIndex, #_ui.heroList do
        _ui.heroList[i].gameObject:SetActive(false)
    end

    local soldierIndex = 1
    if battleData.soilder ~= "" then
        for v in string.gsplit(battleData.soilder, ";") do
            local paramList = string.split(v, ":")
            local soldierId = tonumber(paramList[1])
            local soldierLevel = tonumber(paramList[2])
            local soldierCount = tonumber(paramList[3])

            local soldierData = TableMgr:GetBarrackData(soldierId, soldierLevel)
            totalPower = totalPower + soldierData.fight
            local soldier = _ui.soldierList[soldierIndex]
            soldier.iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
            soldier.numberLabel.text = soldierCount
            soldier.gameObject:SetActive(true)
            SetClickCallback(soldier.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
                end
            end)

            soldierIndex = soldierIndex + 1
        end
    end

    for i = soldierIndex, #_ui.soldierList do
        _ui.soldierList[i].gameObject:SetActive(false)
    end

    local rewardList = _ui.rewardList
    local dropId = battleData.firstShowDropId
    local dropShowList = TableMgr:GetDropShowData(dropId)
    local length = #dropShowList
    for i, v in ipairs(rewardList) do
        if i > length then
            v.item.gameObject:SetActive(false)
            v.hero.transform.gameObject:SetActive(false)
        else
            local dropShowData = dropShowList[i]
            local contentType = dropShowData.contentType
            local contentId = dropShowData.contentId
            local item = v.item
            local hero = v.hero
            item.gameObject:SetActive(contentType == 1 or contentType == 4)
            hero.transform.gameObject:SetActive(contentType == 3)
            if contentType == 1 then
                local itemData = TableMgr:GetItemData(contentId)
                UIUtil.LoadItem(item, itemData, dropShowData.contentNumber)
                v.name = TextUtil.GetItemName(itemData)
                v.description = TextUtil.GetItemDescription(itemData)
            elseif contentType == 4 then
				local soldierData = TableMgr:GetBarrackData(contentId, dropShowData.level)
				UIUtil.LoadSoldier(item , soldierData , dropShowData.contentNumber)
				v.name = TextMgr:GetText(soldierData.SoldierName)
                v.description = TextMgr:GetText(soldierData.SoldierDes)
			else
                local heroData = TableMgr:GetHeroData(contentId)
                local heroMsg = Common_pb.HeroInfo() 
                heroMsg.star = dropShowData.star
                heroMsg.level = dropShowData.level
                heroMsg.num = dropShowData.contentNumber
                HeroList.LoadHero(hero, heroMsg, heroData)
                v.name = TextMgr:GetText(heroData.nameLabel)
                v.description = TextMgr:GetText(heroData.description)
            end
            local ShowTooltip = function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = v.name, text = v.description})
                end
            end
            SetClickCallback(item.gameObject, ShowTooltip)
            SetClickCallback(hero.btn.gameObject, ShowTooltip)
        end
    end

    _ui.nameLabel.text = TextMgr:GetText(battleData.nameLabel)
    _ui.powerLabel.text = battleData.fight
    local energyCost = battleData.energyCost
    _ui.energyLabel.text = energyCost
    local energy = MainData.GetEnergy()
    _ui.energyLabel.color = energy >= energyCost and Color.white or Color.red

    SetClickCallback(_ui.attackButton.gameObject, function(go)
        if MainData.GetEnergy() >= energyCost then
            BattleMove.Show4PVE(battleId)
        else
            MainCityUI.CheckAndBuyEnergy(function()
            end)
        end
    end)
end

function Awake()
    _ui = {}
	SetClickCallback(transform:Find("Container").gameObject, Hide)
    local closeObject = transform:Find("Container/btn_close").gameObject
    _ui.maskObject = transform:Find("Container/mask").gameObject
    SetClickCallback(closeObject, function(go)
        Hide()
    end)
    SetClickCallback(_ui.maskObject, function(go)
        Hide()
    end)
    _ui.heroGridTransform = transform:Find("Container/Container/bg_enemy/bg_hero/Grid")
    local heroList = {}
    for i = 1, 5 do
        local hero = {}
        local heroTransform = _ui.heroGridTransform:Find(string.format("hero (%d)", i))
        HeroList.LoadHeroObject(hero, heroTransform)
        heroList[i] = hero
    end
    _ui.heroList = heroList

    _ui.soldierGridTransform = transform:Find("Container/Container/bg_enemy/bg_enemy/Grid")
    local soldierList = {}
    for i = 1, 4 do
        local soldier = {}
        local soldierTransform = _ui.soldierGridTransform:Find(string.format("btn_enemy (%d)", i))
        soldier.gameObject = soldierTransform.gameObject
        soldier.iconTexture = soldierTransform:Find("enemy"):GetComponent("UITexture")
        soldier.numberLabel = soldierTransform:Find("num"):GetComponent("UILabel")
        soldierList[i] = soldier
    end
    _ui.soldierList = soldierList

    local rewardList = {}
    for i = 1, 5 do
        local reward = {}
        local item = {}
        local itemTransform = transform:Find(string.format("Container/Container/bg_item/bg_item/Item_CommonNew (%d)", i))
        UIUtil.LoadItemObject(item, itemTransform)

        local heroTransform = transform:Find(string.format("Container/Container/bg_item/bg_item/hero (%d)", i))
        local hero = {}
        HeroList.LoadHeroObject(hero, heroTransform)

        reward.item = item
        reward.hero = hero
        rewardList[i] = reward
    end

    _ui.rewardList = rewardList

    _ui.nameLabel = transform:Find("Container/Container/bg_frane/bg_top/title_chapter"):GetComponent("UILabel")
    _ui.powerLabel = transform:Find("Container/Container/bg_power_enemy/icon_power/Text_item"):GetComponent("UILabel")
    _ui.attackButton = transform:Find("Container/Container/btn_attack"):GetComponent("UIButton")
	_ui.playTweenList = transform:Find("Container/Container"):GetComponents(typeof(UIPlayTween))
	_ui.energyLabel = transform:Find("Container/Container/bg_sweep/bg_tili/num_tili"):GetComponent("UILabel")

	if GUIMgr:IsMenuOpen("ChapterSelectUI") then
	    _ui.playTweenList[1]:Play(true)
	    _ui.maskObject:SetActive(false)
    else
	    _ui.playTweenList[0]:Play(true)
	    _ui.maskObject:SetActive(true)
    end

	MainData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Close()
    MainData.RemoveListener(LoadUI)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show(id)
    print("battleId:", id)
    if id ~= nil then
        battleId = id
    end
    Global.OpenUI(_M)
end
