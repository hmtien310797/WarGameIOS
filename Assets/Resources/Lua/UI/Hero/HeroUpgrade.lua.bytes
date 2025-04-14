module("HeroUpgrade", package.seeall)

local BUTTON_REPEAT_DELAY = 0.5 --长按启动延迟
local BUTTON_REPEAT_INTERVAL = 0.1 --长按重复间隔

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
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
local LoadHeroObject = HeroList.LoadHeroObject

local heroUid
local heroMsg
local heroData

local _ui
local oldHeroMsg

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
    HeroLevelUp.CloseAll()
    GatherItemUI.CloseAll()
end

local function CloseClickCallback(go)
    Hide()
    HeroInfo.Show(heroUid, heroMsg.baseid, true)
end

local LoadUI
local function RequestUpgrade(cardList)
    local req = HeroMsg_pb.MsgHeroAddExpRequest()
    req.heroUid = heroMsg.uid
    for k, v in pairs(cardList) do
        local card = req.card:add()
        card.uid = k
        card.num = v
    end
    _ui.requesting = true
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroAddExpRequest, req, HeroMsg_pb.MsgHeroAddExpResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            MainCityUI.UpdateRewardData(msg.fresh)
            if _ui == nil then
                return
            end
            for k, v in pairs(cardList) do
                for __, vv in ipairs(_ui.expItemList) do
                    if vv.msg ~= nil and vv.msg.uniqueid == k then
                        vv.effectObject:SetActive(false)
                        vv.effectObject:SetActive(true)
                        break
                    end
                end
            end
            LoadUI()
            if heroMsg.level ~= oldHeroMsg.level then
                coroutine.stop(_ui.levelUpCoroutine)
                _ui.requestItemUid = nil
                _ui.levelEffectObject:SetActive(false)
                _ui.levelEffectObject:SetActive(true)
                _ui.levelUpCoroutine = coroutine.start(function()
                    coroutine.wait(0.5)
                    if _ui ~= nil then
                        _ui.requesting = false
                    end
                    HeroLevelUp.Show(oldHeroMsg, heroMsg)
                    oldHeroMsg = heroMsg
                    coroutine.wait(0.5)
                end)
            else
                _ui.expEffectObject:SetActive(false)
                _ui.expEffectObject:SetActive(true)
                if _ui ~= nil then
                    _ui.requesting = false
                end
            end
        end
    end, true)
end

LoadUI = function()
    heroMsg = GeneralData.GetGeneralByUID(heroUid) -- HeroListData.GetHeroDataByUid(heroUid)
    heroData = TableMgr:GetHeroData(heroMsg.baseid)

    LoadHero(_ui.hero, heroMsg, heroData)
    _ui.levelLabel.text = heroMsg.level

    local rulesData = TableMgr:GetRulesDataByStarGrade(heroMsg.star, heroMsg.grade)
    local maxLevel = rulesData.maxlevel
    local heroExpData = TableMgr:GetHeroExpData(maxLevel - 1)
    local maxExp = heroExpData.exp
    _ui.maxLevelObject:SetActive(heroMsg.level >= maxLevel)
    local expData = TableMgr:GetHeroExpData(heroMsg.level)
    local preExp = 0
    if heroMsg.level > 1 then
        preExp = TableMgr:GetHeroExpData(heroMsg.level - 1).exp
    end
    local currentExp = heroMsg.exp - preExp
    local levelexp = expData.levelExp
    if heroMsg.star == 6 and heroMsg.level >= maxLevel then
        currentExp = 0
        levelexp = 0
        _ui.hero.expBar.value = 1
    end
    _ui.expLabel.text = string.format("%d/%d", currentExp, levelexp)

    local hasAnyItem = false
    for i, v in ipairs(_ui.expItemList) do
        local itemData = v.data
        local itemMsg = ItemListData.GetItemDataByBaseId(itemData.id)
        UIUtil.LoadHeroItem(v.item, itemData, itemMsg ~= nil and itemMsg.number or 0)
        v.msg = itemMsg
        if itemMsg ~= nil then
            hasAnyItem = true
            v.addObject:SetActive(false)
            SetClickCallback(v.item.iconObject, function(go)
                print("item id:", itemData.id)
                if heroMsg.level < maxLevel then
                    RequestUpgrade({[itemMsg.uniqueid] = 1})
                else
                    AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                    FloatText.Show(TextMgr:GetText(Text.hero_level_limited), Color.white)
                end
            end)

            SetPressCallback(v.item.iconObject, function(go, isPressed)
                if isPressed then
                    _ui.requestTimer = BUTTON_REPEAT_DELAY
                    _ui.requestItemUid = isPressed and itemMsg.uniqueid or nil
                else
                    _ui.requestTimer = 0
                end
            end)
        else
            SetClickCallback(v.item.iconObject, function(go)
                print("item id:", itemData.id)
                GatherItemUI.Show(v.data.id, 1)
            end)
            v.addObject:SetActive(true)
        end
    end
    _ui.upgradeButton.isEnabled = hasAnyItem
    SetClickCallback(_ui.upgradeButton.gameObject, function()
        if _ui.requesting then
            return
        end
        if heroMsg.level < maxLevel then
            local minCardId
            local cardList = {}
            local leftExp = maxExp - heroMsg.exp
            for i = #_ui.expItemList, 1, -1 do
                if leftExp <= 0 then
                    break
                end
                local expItem = _ui.expItemList[i]
                local itemMsg = expItem.msg
                if itemMsg ~= nil then
                    local itemData = expItem.data
                    local cardCount = leftExp / itemData.param1
                    minCardId = itemMsg.uniqueid
                    cardCount = math.min(cardCount, itemMsg.number)
                    cardList[minCardId] = cardCount
                    leftExp = leftExp - itemData.param1 * math.floor(cardCount)
                end
            end
            for kk, vv in pairs(cardList) do
                if kk == minCardId then
                    cardList[kk] = math.ceil(vv)
                else
                    cardList[kk] = math.floor(vv)
                end
            end
            RequestUpgrade(cardList)
        else
            AudioMgr:PlayUISfx("SFX_ui02", 1, false)
            FloatText.Show(TextMgr:GetText(Text.hero_level_limited), Color.white)
        end
    end)
end

function Awake()
    _ui = {}
    _ui.requestTimer = 0
    local btnClose = transform:Find("Container/close btn"):GetComponent("UIButton")
    local maskbg = transform:Find("mask")
    SetClickCallback(btnClose.gameObject, CloseClickCallback)
    SetClickCallback(maskbg.gameObject, CloseClickCallback)

    local hero = {}
    hero.bg = transform:Find("Container/update widget/hero")
    hero.icon = transform:Find("Container/update widget/hero/head icon"):GetComponent("UITexture")
    hero.qualityList = {}
    for i = 1, 5 do
        hero.qualityList[i] = transform:Find(string.format("Container/update widget/hero/head icon/outline%d", i)).gameObject
    end
    hero.levelLabel = transform:Find("Container/update widget/hero/level text"):GetComponent("UILabel")
    hero.nameLabel = transform:Find("Container/update widget/hero/name text"):GetComponent("UILabel")
    hero.starList = {}
    for i = 1, 6 do
        hero.starList[i] = transform:Find(string.format("Container/update widget/hero/star/star%d", i))
    end
    hero.expBar = transform:Find("Container/update widget/exp widget/exp bar"):GetComponent("UISlider")
    _ui.hero = hero
    _ui.levelLabel = transform:Find("Container/update widget/exp widget/lv text/lv num1"):GetComponent("UILabel")
    _ui.expLabel = transform:Find("Container/update widget/exp widget/exp bar/exp text"):GetComponent("UILabel")
    _ui.maxLevelObject = transform:Find("Container/update widget/exp widget/lv text/lv num1/max").gameObject
    _ui.expEffectObject = transform:Find("Container/update widget/exp widget/exp bar/shengjiyiban").gameObject
    _ui.levelEffectObject = transform:Find("Container/update widget/exp widget/exp bar/shengjiman").gameObject

    _ui.upgradeButton = transform:Find("Container/update widget/exp widget/strengthen btn"):GetComponent("UIButton")
    _ui.upgradeDark = transform:Find("Container/update widget/exp widget/strengthen btn/hui btn")

    local expGridTransform = transform:Find("Container/update widget/item widget/title text1/Grid")
    local expItemList = {}
    for i = 1, expGridTransform.childCount do
        local expItem = {}
        local expItemTransform = expGridTransform:GetChild(i - 1)
        expItem.transform = expItemTransform
        local item = {}
        local itemTransform = expItemTransform:Find("listitem_hero_item")
        UIUtil.LoadHeroItemObject(item, itemTransform)
        expItem.item = item

        expItem.addObject = expItemTransform:Find("add").gameObject
        local expDataList = TableMgr:GetItemDataListByTypeQuality(55, i)
        expItem.data = expDataList[1]
        expItem.effectObject = expItemTransform:Find("jiangjuntunka").gameObject
        expItemList[i] = expItem
    end
    _ui.expItemList = expItemList
    ItemListData.AddListener(LoadUI)
end

function LateUpdate()
    if _ui.requestTimer > 0 then
        _ui.requestTimer = _ui.requestTimer - GameTime.deltaTime
        if _ui.requestTimer <= 0 then
            local playerExpData = TableMgr:GetPlayerExpData(MainData.GetLevel())
            local maxLevel = playerExpData.heroMaxLevel
            if heroMsg.level < maxLevel then
                _ui.requestTimer = BUTTON_REPEAT_INTERVAL
                if _ui.requestItemUid ~= nil and not _ui.requesting then
                    local itemMsg = ItemListData.GetItemDataByUid(_ui.requestItemUid)
                    if itemMsg ~= nil then
                        RequestUpgrade({[itemMsg.uniqueid] = 1})
                    end
                end
            else
                AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                FloatText.Show(TextMgr:GetText(Text.hero_level_limited), Color.white)
            end
        end
    end
end

function Close()
    ItemListData.RemoveListener(LoadUI)
    coroutine.stop(_ui.levelUpCoroutine)
    _ui = nil
end

function Show(uid)
    heroUid = uid
    Global.OpenUI(_M)
    LoadUI()
    oldHeroMsg = heroMsg
end
