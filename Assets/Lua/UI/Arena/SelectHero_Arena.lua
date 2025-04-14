module("SelectHero_Arena", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local AudioMgr = Global.GAudioMgr

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local LoadUI = nil

local function AutoSelect()
    local selectedCount = table.count(_ui.selectedIdList)
    local heroCount = #_ui.heroListMsg
    if selectedCount < math.min(5, heroCount) then
        for i, v in ipairs(_ui.heroListMsg) do
            if not _ui.selectedIdList[v.uid] then
                _ui.selectedIdList[v.uid] = true
            end
            if table.count(_ui.selectedIdList) == 5 then
                break
            end
        end
    else
        _ui.selectedIdList = {}
    end
end

local function LoadSelectList()
    local totalPower = 0
    local selectIndex = 1
    local allAttrList = {}
    for i, v in ipairs(_ui.heroListMsg) do
        if _ui.selectedIdList[v.uid] then
            local heroMsg = v
            local selectHero = _ui.selectList[selectIndex]
            local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
            HeroList.LoadHero(selectHero.hero, heroMsg, heroData)
            selectHero.hero.gameObject:SetActive(true)
            selectIndex = selectIndex + 1
            SetClickCallback(selectHero.bgObject, function(go)
                _ui.selectedIdList[heroMsg.uid] = nil
                LoadUI()
            end)

            local attributes = GeneralData.GetAttributes(heroMsg)[2]
            for k, v in pairs(attributes) do
                if attributeID ~= 1102 or Global.IsOutSea() then
                    if not allAttrList[k] then
                        allAttrList[k] = v
                    else
                        allAttrList[k] = allAttrList[k] + v
                    end
                end
            end
            totalPower = totalPower + GeneralData.GetPower(heroMsg)
        end
    end
    for i = selectIndex, 5 do
        local selectHero = _ui.selectList[i]
        selectHero.hero.gameObject:SetActive(false)
        SetClickCallback(selectHero.bgObject, nil)
    end

    local attrIndex = 1
    for k, v in pairs(allAttrList) do
        if (k < 1004 or k > 1012) and k ~= 33 and k ~= 100000021 and (k ~= 1102 or Global.IsOutSea()) then
            local attrData = TableMgr:GetNeedTextData(k)
            if attrData ~= nil then
                local attrTransform
                if attrIndex > _ui.attrListGrid.transform.childCount then
                    attrTransform = NGUITools.AddChild(_ui.attrListGrid.gameObject, _ui.attrPrefab).transform
                else
                    attrTransform = _ui.attrListGrid.transform:GetChild(attrIndex - 1)
                end

                attrTransform.gameObject:SetActive(true)
                local nameLabel = attrTransform:Find("name"):GetComponent("UILabel")
                local valueLabel = attrTransform:Find("num"):GetComponent("UILabel")
                nameLabel.text = TextMgr:GetText(attrData.unlockedText)
                valueLabel.text = Global.GetHeroAttrValueString(attrData.additionAttr, v)
                valueLabel.color = v > 0 and Color.green or Color.white
                attrIndex = attrIndex + 1
            end
        end
    end
    for i = attrIndex, _ui.attrListGrid.transform.childCount do
        _ui.attrListGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.attrListGrid.repositionNow = true
    _ui.powerLabel.text = math.ceil(totalPower)
end

local function LoadHeroList()
    for i, v in ipairs(_ui.heroListMsg) do
        local listHeroTransform
        if i > _ui.heroListGrid.transform.childCount then
            listHeroTransform = NGUITools.AddChild(_ui.heroListGrid.gameObject, _ui.heroPrefab).transform
            listHeroTransform.name = "listitem_hero_PVP".. i
            if i > 1 and (i - 1) % 6 == 0 then
                _ui.heroListGrid.repositionNow = true
                coroutine.step()
            end
            listHeroTransform:Find("Container/quality3").gameObject:SetActive(false)
            listHeroTransform:Find("Container/quality4").gameObject:SetActive(false)
        else
            listHeroTransform = _ui.heroListGrid.transform:GetChild(i - 1)
        end
        local heroMsg = v
        local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
        local listHero = {}
        local selected = _ui.selectedIdList[heroMsg.uid]
        listHero.selectObject = listHeroTransform:Find("select").gameObject
        local hero = {}
        local heroTransform = listHeroTransform:Find("Container")
        HeroList.LoadHeroObject(hero, heroTransform)
        HeroList.LoadHero(hero, heroMsg, heroData)

        local attributes = GeneralData.GetAttributes(heroMsg)[2]
        local troops = attributes[1102] or 0
        for i = 1, 4 do
            local attrTransform = listHeroTransform:Find("Container/quality" .. i)
            attrTransform.gameObject:SetActive(i == 1 and Global.IsOutSea())
            local attrLabel = attrTransform:Find("num"):GetComponent("UILabel")
            if i == 1 then
                attrLabel.text = "+" .. troops
                attrLabel.color = troops > 0 and Color.green or Color.white
            else
                attrLabel.text = "+0%"
            end
        end

        hero.stateBg.gameObject:SetActive(false)
        for _, v in pairs(hero.stateList) do
            v.gameObject:SetActive(false)
        end
        listHero.selectObject:SetActive(selected)
        listHero.hero = hero
        SetClickCallback(listHeroTransform.gameObject, function(go)
            local heroUid = heroMsg.uid
            if _ui.selectedIdList[heroUid] then
                _ui.selectedIdList[heroUid] = nil
                LoadUI()
            else
                local count = table.count(_ui.selectedIdList)
                local full = count >= 5
                if full then
                    local text = TextMgr:GetText(Text.selectunit_hint114)
                    AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                    FloatText.Show(text, Color.white)
                else
                    print("选择将军: baseid:", heroData.id, "uid:", heroUid)
                    _ui.selectedIdList[heroUid] = true
                    LoadUI()
                end
            end
        end)
    end

    for i = #_ui.heroListMsg + 1, _ui.heroListGrid.transform.childCount do
        _ui.heroListGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.heroListGrid.repositionNow = true
end

function LoadUI()
    coroutine.stop(_ui.loadHeroListCoroutine)
    _ui.loadHeroListCoroutine = coroutine.start(LoadHeroList)
    LoadSelectList()
end

function Awake()
    local closeButton = transform:Find("Container/btn_back")
    closeButton.gameObject:SetActive(true)
    local mask = transform:Find("Container/mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    _ui.powerLabel = transform:Find("Container/bg_skills/bg_skills/title_bg/combat num"):GetComponent("UILabel")
    local heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    local selectList = {}
    for i = 1, 5 do
        local selectTransform = transform:Find("Container/bg_battle skills/bg_selected/hero" .. i)
        local selectHero = {}
        selectHero.transform = selectTransform
        selectHero.bgObject = selectTransform:Find("bg").gameObject
        local hero = {}
        local heroTransform = selectTransform:Find("Container")
        HeroList.LoadHeroObject(hero, heroTransform)
        selectHero.hero = hero
        selectList[i] = selectHero
    end
    _ui.selectList = selectList
    _ui.heroListScrollView = transform:Find("Container/bg_skills/bg_skills/bg2/Scroll View"):GetComponent("UIScrollView")
    _ui.heroListGrid = transform:Find("Container/bg_skills/bg_skills/bg2/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("WorldMap/listitem_hero_PVP")

    transform:Find("Container/bg_right/bg/bg_addition/Scroll View/Grid/bg_soldier (1)").gameObject:SetActive(true)

    _ui.attrListGrid = transform:Find("Container/bg_right/bg/bg_addition/Scroll View/Grid"):GetComponent("UIGrid") 
    _ui.attrPrefab = _ui.attrListGrid.transform:GetChild(0).gameObject
    _ui.autoSelectButton = transform:Find("Container/btn_auto"):GetComponent("UIButton")
    _ui.confirmButton = transform:Find("Container/btn_attack"):GetComponent("UIButton")
    SetClickCallback(_ui.autoSelectButton.gameObject, function()
        AutoSelect()
        LoadUI()
    end)
    SetClickCallback(_ui.confirmButton.gameObject, function()
        _ui.confirmCallback(_ui.selectedIdList)
        CloseAll()
    end)
end

function Start()
    LoadUI()
end

function Close()
    coroutine.stop(_ui.loadHeroListCoroutine)
    _ui = nil
end

function Show(selectedIdList, heroListMsg, confirmCallback)
    Global.OpenUI(_M)
    _ui.selectedIdList = {}
    for k, v in pairs(selectedIdList) do
        _ui.selectedIdList[k] = v
    end
    _ui.confirmCallback = confirmCallback
    _ui.heroListMsg = heroListMsg
end
