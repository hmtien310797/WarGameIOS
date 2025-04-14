module("TenCardDisplay", package.seeall)
local DELAY1 = 0.5 --  多个卡片显示之间的间隔 
local DELAY2 = 0.5 --  确定和再来一次出现的延时
local DELAY3 = 1 --  出现将军碎片时增加的延迟

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local LoadHeroObject = HeroList.LoadHeroObject
local LoadHero = HeroList.LoadHero
local _ui
local showCoroutine
local chestMsg
local rewardMsg

function Hide()
    Global.CloseUI(_M)
end

local function LoadCostUI()
    MilitarySchool.LoadTenCostUI(_ui, chestMsg)
end

local function LoadUI()
    LoadCostUI()
    local itemCount = #(rewardMsg.item.item)
    for i, v in ipairs(_ui.rewardList) do
        v.gameObject:SetActive(false)
        v.hero.newObject:SetActive(false)
    end

    local currentIndex = 1
    if showCoroutine ~= nil then
        coroutine.stop(showCoroutine)
    end
    showCoroutine = coroutine.start(function()
        local hasShard = false
        for i, v in ipairs(_ui.rewardList) do
            local item = v.item
            local hero = v.hero
            v.gameObject:SetActive(true)
            if i <= itemCount then
                local itemMsg = rewardMsg.item.item[i]
                local itemData = TableMgr:GetItemData(itemMsg.baseid)
                if itemMsg.heroToPiece ~= 0 then
                    hasShard = true
                    hero.gameObject:SetActive(true)
                    item.bgObject:SetActive(false)
                    local defaultHeroData = TableMgr:GetHeroData(itemMsg.heroToPiece)
                    local defaultHeroMsg = GeneralData.GetDefaultHeroData(defaultHeroData) -- HeroListData.GetDefaultHeroData(defaultHeroData)
                    LoadHero(hero, defaultHeroMsg, defaultHeroData)
                    hero.newObject:SetActive(false)
                    v.convertTweener:SetOnFinished(EventDelegate.Callback(function()
                        hero.gameObject:SetActive(false)
                        item.bgObject:SetActive(true)
                        if item.pieceEffectObject ~= nil then
                            item.pieceEffectObject:SetActive(true)
                        end
                        OneCardDisplay.LoadRewardItem(item, itemMsg, itemData)
                    end))
                    coroutine.wait(DELAY3)
                else
                    hero.gameObject:SetActive(false)
                    item.bgObject:SetActive(true)
                    OneCardDisplay.LoadRewardItem(item, itemMsg, itemData)
                end
                coroutine.wait(DELAY1)
            else
                local heroMsg = rewardMsg.hero.hero[i - itemCount]
                local heroData = TableMgr:GetHeroData(heroMsg.baseid)
                hero.gameObject:SetActive(true)
                item.bgObject:SetActive(false)
                LoadHero(hero, heroMsg, heroData)
                coroutine.wait(DELAY1)
                if heroData.quality >= 4 then
                    OneCardDisplay.Show(chestMsg, heroMsg, nil, false)
                    while OneCardDisplay.Showing() do
                        coroutine.step()
                    end
                end
            end
        end
        _ui.convertObject:SetActive(hasShard)
        coroutine.wait(DELAY2)
        _ui.againButton.gameObject:SetActive(true)
        _ui.okButton.gameObject:SetActive(true)
    end)

    UIUtil.SetClickCallback(_ui.againButton.gameObject, MilitarySchool.GetRequestFunction(chestMsg.type, true))
end

function Awake()
    _ui = {}
    local rewardList = {}
    for i = 1, 10 do
        local reward = {}
        local rewardTransform = transform:Find(string.format("Container/listitem_hero%d", i))
        reward.convertTweener = rewardTransform:GetComponent("UITweener")

        reward.gameObject = rewardTransform.gameObject
        local hero = {}
        local heroTransform = rewardTransform:Find("Container")
        LoadHeroObject(hero, heroTransform)
        hero.newObject = heroTransform:Find("new").gameObject
        reward.hero = hero

        local item = {}
        local itemBgTransform = rewardTransform:Find("bg_icon")
        local itemTransform = rewardTransform:Find("bg_icon/Item_CommonNew")
        UIUtil.LoadItemObject(item, itemTransform)
        item.pieceEffectObject = rewardTransform:Find("shilianchouzhuanhuan").gameObject

        item.nameLabel = itemBgTransform:Find("name text"):GetComponent("UILabel")

        item.bgObject = itemBgTransform.gameObject
        reward.item = item
        rewardList[i] = reward
    end
    _ui.rewardList = rewardList

    _ui.tenCost = {}
    _ui.tenCost.countLabel = transform:Find("more one/consume num"):GetComponent("UILabel")
    _ui.tenCost.icon = transform:Find("more one/consume num/Texture"):GetComponent("UITexture")
    _ui.againButton = transform:Find("more one")
    _ui.okButton = transform:Find("ok btn")
    _ui.againButton.gameObject:SetActive(false)
    _ui.okButton.gameObject:SetActive(false)
    _ui.convertObject = transform:Find("repeat_tips").gameObject
    UIUtil.SetClickCallback(_ui.okButton.gameObject, Hide)
    LoadUI()
    MoneyListData.AddListener(LoadCostUI)
end

function Close()
    if showCoroutine ~= nil then
        coroutine.stop(showCoroutine)
        showCoroutine = nil
    end
    MoneyListData.RemoveListener(LoadCostUI)
    _ui = nil
end

function Show(_chestMsg, _rewardMsg)
    chestMsg = _chestMsg
    rewardMsg = _rewardMsg
    Global.OpenUI(_M)
end
