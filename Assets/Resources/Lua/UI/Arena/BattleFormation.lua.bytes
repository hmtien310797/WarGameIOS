module("BattleFormation", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function AutoSelect(reset)
    if _ui.totalTroops ~= _ui.maxTroops and _ui.maxTroops ~= 0 then
        local totalValue = 0
        local maxGrade = -1
        local totalTroops = _ui.totalTroops
        for i, v in ipairs(_ui.soldierList) do
            if v.data == nil then
                break
            end
            if v.data.Grade > maxGrade then
                maxGrade = v.data.Grade
            end
            totalValue = totalValue + v.countSlider.value
            v.sliderValue = v.countSlider.value
            v.countLabel.text = 0
            v.countSlider.value = 0
        end

        if totalTroops == 0 then
            local maxSoldierCount = 0
            local maxGradeSoldier
            for i, v in ipairs(_ui.soldierList) do
                if v.data == nil then
                    break
                end
                if v.data.Grade == maxGrade then
                    if maxGradeSoldier == nil then
                        maxGradeSoldier = v
                    end
                    maxSoldierCount = maxSoldierCount + 1
                end
            end
            local value = math.floor(_ui.maxTroops / maxSoldierCount)
            totalTroops = 0
            for i, v in ipairs(_ui.soldierList) do
                if v.data == nil then
                    break
                end
                if v.data.Grade == maxGrade and v ~= maxGradeSoldier then
                    v.countSlider.value = value / _ui.maxTroops
                    v.countLabel.text = value
                    totalTroops = totalTroops + value
                end
            end
            value = _ui.maxTroops - totalTroops
            maxGradeSoldier.countSlider.value = value / _ui.maxTroops
            maxGradeSoldier.countLabel.text = value
        else
            totalTroops = 0
            for i, v in ipairs(_ui.soldierList) do
                if v.data == nil then
                    break
                end
                v.countSlider.value = v.sliderValue / totalValue
                totalTroops = totalTroops + tonumber(v.countLabel.text)
            end
            if _ui.soldierList[1].data ~= nil then
                _ui.soldierList[1].countLabel.text = tonumber(_ui.soldierList[1].countLabel.text) + _ui.totalTroops - totalTroops
            end
        end
    elseif reset then
        for i, v in ipairs(_ui.soldierList) do
            if v.data ~= nil then
                v.countSlider.value = 0
            end
        end
    end
end

local function GetMaxLeftTroops(maxTroops, soldier)
    local maxLeftTroops = maxTroops
    for _, v in ipairs(_ui.soldierList) do
        if v ~= soldier and v.data ~= nil then
            maxLeftTroops = maxLeftTroops - tonumber(v.countLabel.text)
        end
    end

    return maxLeftTroops
end

local function UpdateTroopsPower()
    local totalPower = _ui.totalHeroPower
    local totalTroops = 0
    for _, v in ipairs(_ui.soldierList) do
        if v.data == nil then
            break
        end
        local troops = tonumber(v.countLabel.text)
        totalTroops = totalTroops + troops
        totalPower = totalPower + troops * AttributeBonus.CalBattlePointNew(Barrack.GetAramInfo(v.data.SoldierId, v.data.Grade))
    end
    _ui.totalPower = totalPower
    _ui.totalTroops = totalTroops
    _ui.troopsLabel.text = Format(TextMgr:GetText(Text.battlemove_ui3), "[FFFFFFFF]", totalTroops, "[FFFFFFFF]", _ui.maxTroops)
    _ui.powerLabel.text = Format(TextMgr:GetText(Text.HeroAppoint_combat), math.ceil(totalPower))
end

local ignore = {"BattleMove", "SelectArmy",
"MobaBuffData","MobaHeroListData","MobaTechData","MobaBattleMove"}
local function RecollectBonus()
    AttributeBonus.CollectBonusInfo(ignore)
end

local function LoadUI(reset)
    if reset then
        local arenaInfoMsg = ArenaInfoData.GetData().arenaInfo
        _ui.arenaInfoMsg = arenaInfoMsg
        _ui.heroListMsg = GeneralData.GetSortedGenerals(_ui.suggestionRule.sortingConfig)
        _ui.selectedIdList = {}
        for _, v in ipairs(arenaInfoMsg.army.hero) do
            _ui.selectedIdList[v] = true
        end
        _ui.armyFormList = Common_pb.ArmyFormList()
        local form = arenaInfoMsg.formation.form
        if #form == 0 then
            for i = 1, 4 do
                _ui.armyFormList.form:append(20 + i)
            end
            _ui.armyFormList.form:append(0)
            _ui.armyFormList.form:append(0)
        else
            for _, v in ipairs(form) do
                _ui.armyFormList.form:append(v)
            end
        end
        _ui.formationSmall:SetLeftFormation(_ui.armyFormList.form)
        _ui.formationSmall:Awake(1)

        local paradeGroundTroops = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseSoliderNum).value)
        local paradeGroundBuilding = maincity.GetBuildingByID(4)
        if paradeGroundBuilding ~= nil then
            paradeGroundTroops = paradeGroundTroops + tableData_tParadeGround.data[paradeGroundBuilding.data.level].addlimit  
        end
        _ui.paradeGroundTroops = paradeGroundTroops
        _ui.paradeGroundTroopsLabel.text = paradeGroundTroops

        local commanderLevel = MainData.GetData().commanderLeadLevel
        local data = TableMgr:GetCommandData(commanderLevel)
        local commanderTroops = data.SoldierNum
        _ui.commanderTroops = commanderTroops
        _ui.commanderTroopsLabel.text = commanderTroops

        RecollectBonus()
    end

    local params = {}
    params.base = _ui.paradeGroundTroops + _ui.commanderTroops
    _ui.maxTroops =  math.floor(AttributeBonus.CallBonusFunc(30, params))
    _ui.bonusTroopLabel.text = _ui.maxTroops - _ui.paradeGroundTroops - _ui.commanderTroops

    _ui.totalHeroPower = 0
    local heroIndex = 1
    for i, v in ipairs(_ui.heroListMsg) do
        if _ui.selectedIdList[v.uid] then
            _ui.totalHeroPower = _ui.totalHeroPower + GeneralData.GetPower(v)
            local hero = _ui.heroList[heroIndex]
            local heroData = TableMgr:GetHeroData(v.baseid) 
            HeroList.LoadHero(hero, v, heroData)
            hero.icon.gameObject:SetActive(true)
            heroIndex = heroIndex + 1
        end
    end

    for i = heroIndex, 5 do
        local hero = _ui.heroList[i]
        hero.icon.gameObject:SetActive(false)
    end

    local soldierIndex = 1
    for i = 1, 4 do
        local soldierData
        local data = TableMgr:GetBarrackData(1000 + i, 1)
        if maincity.HasBuildingByID(data.BarrackId) then
            soldierData = data
        end

        for j = 4, 2, -1 do
            local data = TableMgr:GetBarrackData(1000 + i, j)
            local tech = Laboratory.GetTech(tonumber(data.Science))
            if tech ~= nil and tech.Info.level >= data.ScienceLevel then
                soldierData = data
                break
            end
        end

        if soldierData ~= nil then
            local soldier = _ui.soldierList[soldierIndex]
            soldier.data = soldierData
            soldier.gameObject:SetActive(true)
            soldier.iconTexture.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soldierData.SoldierIcon)
            soldier.nameLabel.text = TextMgr:GetText(soldierData.SoldierName)
            EventDelegate.Set(soldier.countSlider.onChange, EventDelegate.Callback(function(go)
                local maxLeftTroops = GetMaxLeftTroops(_ui.maxTroops, soldier)
                soldier.countSlider.value = math.min(soldier.countSlider.value, maxLeftTroops / _ui.maxTroops)
                soldier.percentLabel.text = string.format("%.1f%%", soldier.countSlider.value * 100)
                local troops = math.min(maxLeftTroops, math.ceil(_ui.maxTroops * soldier.countSlider.value))
                soldier.countLabel.text = troops
                UpdateTroopsPower()
            end))
            SetClickCallback(soldier.inputObject, function(go)
                local maxLeftTroops = GetMaxLeftTroops(_ui.maxTroops, soldier)
                NumberInput.Show(soldier.countLabel.text, 0, maxLeftTroops, function(number)
                    soldier.countSlider.value = number / _ui.maxTroops
                    soldier.countLabel.text = number
                    UpdateTroopsPower()
                end)
            end)
            if reset then
                local troops = 0
                for _, v in ipairs(_ui.arenaInfoMsg.army.army) do
                    if v.armyId == soldierData.SoldierId then
                        troops = v.num
                        break
                    end
                end
                soldier.countSlider.value = troops / _ui.maxTroops
                soldier.countLabel.text = troops
            end

            soldierIndex = soldierIndex + 1
        end
    end

    for i = soldierIndex, 4 do
        _ui.soldierList[i].gameObject:SetActive(false)
    end
    UpdateTroopsPower()
end

function FirstSelect()
    _ui.selectedIdList = {}
    for i, v in ipairs(_ui.heroListMsg) do
        if not _ui.selectedIdList[v.uid] then
            _ui.selectedIdList[v.uid] = true
        end
        if table.count(_ui.selectedIdList) == 5 then
            break
        end
    end
    local soldierCount = 0
    for i, v in ipairs(_ui.soldierList) do
        if v.data == nil then
            break
        end
        soldierCount = soldierCount + 1
    end

    local totalTroops = 0
    for i, v in ipairs(_ui.soldierList) do
        if v.data == nil then
            break
        end
        local troops = 0
        if i ~= soldierCount then
            troops = math.floor(_ui.maxTroops / soldierCount)
            totalTroops = totalTroops + troops
        else
            troops = _ui.maxTroops - totalTroops
        end
        v.countSlider.value = troops / _ui.maxTroops
        v.countLabel.text = troops
    end

    LoadUI()
end

local function ReloadUI()
    LoadUI(true)
end

local function LoadHeroObject(hero, heroTransform)
    if heroTransform == nil then
        return
    end
    hero.transform = heroTransform
    hero.gameObject = heroTransform.gameObject
    hero.lock = heroTransform:Find("bg/lock")
    hero.unlock = heroTransform:Find("unlock")
    hero.mask = heroTransform:Find("select")
    hero.icon = heroTransform:Find("head icon"):GetComponent("UITexture")
    hero.btn = heroTransform:Find("head icon"):GetComponent("UIButton")
    hero.btnTip = heroTransform:Find("bg_skill")
    hero.bgObject = heroTransform:Find("bg").gameObject
    hero.boxCollider = heroTransform:Find("bg"):GetComponent("BoxCollider")
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
    hero.levelLabel = heroTransform:Find("head icon/level text"):GetComponent("UILabel")
    hero.starList = {}
    for i = 1, 6 do
        hero.starList[i] = heroTransform:Find("head icon/star/star"..i)
    end
end

function CalAttributeBonus()
    local bonusList = {}
    if _ui ~=nil then
        for i, v in ipairs(_ui.heroListMsg) do
            if _ui.selectedIdList[v.uid] then
                local heroMsg = v
                for attributeID, value in pairs(GeneralData.GetAttributes(heroMsg)[2]) do
                    local bonus = {}
                    local armyType = math.floor(attributeID / 10000)
                    bonus.BonusType, bonus.Attype = Global.DecodeAttributeLongID(attributeID)
                    bonus.Value = value
                    table.insert(bonusList, bonus)
                end
            end
        end
    end
    return bonusList
end

function Awake()
    _ui = {}
    _ui.suggestionRule = TableMgr:GetHeroSuggestionRule(0)
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    _ui.formationSmall = BMFormation(transform:Find("Container/bg_frane/Embattle"))

    _ui.saveButton = transform:Find("Container/bg_frane/btn_upgrade"):GetComponent("UIButton")

    local heroList = {}
    for i = 1, 5 do
        local hero = {}
        local heroTransform = transform:Find("Container/bg_frane/bg_right/bg_general/bg_battle skills/bg_selected/hero" .. i)
        LoadHeroObject(hero, heroTransform)
        hero.boxCollider.enabled = true
        hero.lock.gameObject:SetActive(false)
        SetClickCallback(hero.bgObject.gameObject, function(go)
            SelectHero_Arena.Show(_ui.selectedIdList, _ui.heroListMsg, 
            function(selectedIdList)
                _ui.selectedIdList = selectedIdList
                RecollectBonus()
                LoadUI(false)
                AutoSelect(false)
            end)
        end)
        heroList[i] = hero
    end
    _ui.heroList = heroList

    local soldierList = {}
    for i = 1, 4 do
        local soldier = {}
        soldierTransform = transform:Find(string.format("Container/bg_frane/Grid/BattleMoveLeftinfo (%d)", i))
        soldier.transform = soldierTransform
        soldier.gameObject = soldierTransform.gameObject
        soldier.iconTexture = soldierTransform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
        soldier.nameLabel = soldierTransform:Find("bg_list/bg_title/text_name"):GetComponent("UILabel")
        soldier.countSlider = soldierTransform:Find("bg_list/bg_schedule/bg_slider"):GetComponent("UISlider")
        soldier.percentLabel = soldierTransform:Find("bg_list/num"):GetComponent("UILabel")
        soldier.inputObject = soldierTransform:Find("bg_list/bg_food").gameObject
        soldier.countLabel = soldierTransform:Find("bg_list/bg_food/txt_food"):GetComponent("UILabel")
        soldierList[i] = soldier
    end
    _ui.soldierList = soldierList

    _ui.commanderTroopsLabel = transform:Find("soldie_view/back/Label2"):GetComponent("UILabel")
    _ui.paradeGroundTroopsLabel = transform:Find("soldie_view/back/Label4"):GetComponent("UILabel")
    _ui.bonusTroopLabel = transform:Find("soldie_view/back/Label6"):GetComponent("UILabel")

    _ui.troopsLabel = transform:Find("Container/bg_frane/bg_info/soldier"):GetComponent("UILabel")
    _ui.troopsViewObject = transform:Find("Container/bg_frane/bg_info/soldie_view").gameObject
    SetClickCallback(_ui.troopsViewObject, function(go)
        _ui.troopsDetailObject.gameObject:SetActive(true)
    end)
    _ui.troopsDetailObject = transform:Find("soldie_view").gameObject
    SetClickCallback(transform:Find("soldie_view/mask").gameObject, function(go)
        _ui.troopsDetailObject:SetActive(false)
    end)
    _ui.troopsDetailObject:SetActive(false)
    _ui.powerLabel = transform:Find("Container/bg_frane/powerPanel/power/num"):GetComponent("UILabel")

    _ui.autoSelectButton = transform:Find("Container/bg_frane/btn_upgrade_gold"):GetComponent("UIButton")
    SetClickCallback(_ui.autoSelectButton.gameObject, function(go)
        LoadUI(false)
        AutoSelect(true)
    end)
    SetClickCallback(_ui.saveButton.gameObject, function(go)
        if _ui.totalTroops == 0 then
            FloatText.Show(TextMgr:GetText(Text.ui_Arena_15))
            return
        end

        local req = BattleMsg_pb.MsgSetArenaArmySchemeRequest()
        req.pkval = _ui.totalPower
        local formation = _ui.formationSmall:GetSelfFormation()
        for _, v in ipairs(formation) do
            req.formation.form:append(v)
        end

        for k, _ in pairs(_ui.selectedIdList) do
            req.army.hero:append(k)
        end

        for _, v in ipairs(_ui.soldierList) do
            if v.data == nil then
                break
            end
            local army = req.army.army:add()
            army.armyId = v.data.SoldierId
            army.armyLevel = v.data.Grade
            army.num = tonumber(v.countLabel.text)
            for ii, vv in ipairs(formation) do
                if vv == v.data.BarrackId then 
                    army.pos = ii
                    break
                end
            end
        end

        Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgSetArenaArmySchemeRequest, req, BattleMsg_pb.MsgSetArenaArmySchemeResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                FloatText.Show(TextMgr:GetText(Text.ui_Arena_14), Color.green)
                ArenaInfoData.RequestData()
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)

    ArenaInfoData.AddListener(ReloadUI)
end

function Start()
    LoadUI(true)
end

function Close()
    ArenaInfoData.RemoveListener(ReloadUI)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
    AttributeBonus.RegisterAttBonusModule(_M)
end
