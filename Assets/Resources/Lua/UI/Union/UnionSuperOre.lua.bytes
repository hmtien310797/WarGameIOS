module("UnionSuperOre", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local GameObject = UnityEngine.GameObject

local _ui
local updateTimer = 0

function Hide()
    Global.CloseUI(_M)
    if GUIMgr:FindMenu("UnionInfo") ~= nil then
    end
end

function CloseAll()
    Hide()
end

local function LoadHeroObject(hero, heroTransform)
    hero.transform = heroTransform
    hero.icon = heroTransform:Find("head icon"):GetComponent("UITexture")
    hero.btn = heroTransform:Find("head icon"):GetComponent("UIButton")
    hero.qualityList = {}
    for i = 1, 5 do
        hero.qualityList[i] = heroTransform:Find("head icon/outline"..i)
    end
    hero.levelLabel = heroTransform:Find("head icon/level text"):GetComponent("UILabel")
    hero.starList = {}
    for i = 1, 6 do
        hero.starList[i] = heroTransform:Find("head icon/star/star"..i)
    end
end

local function LoadHero(hero, msg, data)
    hero.msg = msg
    hero.data = data
    if hero.icon ~= nil then
        hero.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", data.icon)
    end
    Global.SetNumber(hero.qualityList, data.quality)
    if hero.levelLabel ~= nil then
        hero.levelLabel.text = msg.level
    end
    Global.SetNumber(hero.starList, msg.star)
end

local function LoadArmyObject(army, armyTransform)
    army.gameObject = armyTransform.gameObject
    army.bgObject = armyTransform:Find("Sprite").gameObject
    army.nameLabel = armyTransform:Find("Label_01"):GetComponent("UILabel")
    local levelGridTransform = armyTransform:Find("Grid01")
    local levelList = {}
    for i = 1, 4 do
        local level = {}
        local levelTransform = levelGridTransform:GetChild(i - 1)
        level.countLabel = levelTransform:Find("Sprite"..i.."/number"):GetComponent("UILabel")
        levelList[i] = level
    end
    army.levelList = levelList
end

local function LoadTroopObject(troop, troopTransform)
    troop.gameObject = troopTransform.gameObject
    troop.controller = troopTransform:GetComponent("ParadeTableItemController")
    troop.faceTexture = troopTransform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
    troop.faceBg = troopTransform:Find("bg_list/bg_icon").gameObject
    troop.nameLabel = troopTransform:Find("bg_list/bg_icon/bg_text/text_name"):GetComponent("UILabel")
    troop.totalLabel = troopTransform:Find("bg_list/total force/Label"):GetComponent("UILabel")
    troop.stateLabel = troopTransform:Find("bg_list/march_text"):GetComponent("UILabel")
    troop.timeBg = troopTransform:Find("bg_list/bg_exp")
    troop.timeSlider = troopTransform:Find("bg_list/bg_exp/bg/bar"):GetComponent("UISlider")
    troop.timeLabel = troopTransform:Find("bg_list/bg_exp/bg/text"):GetComponent("UILabel")
    troopTransform:Find("bg_list/commander").gameObject:SetActive(false)
    local heroList = {}
    local heroGridTransform = troopTransform:Find("bg_list/Grid")
    troop.heroGrid = heroGridTransform:GetComponent("UIGrid")
    for j = 1, 5 do
        local heroTransform = heroGridTransform:GetChild(j - 1)
        local hero = {}
        LoadHeroObject(hero, heroTransform)
        heroList[j] = hero
    end
    troop.heroList = heroList
    troop.armyGrid = troopTransform:Find("Item_open01/bg_soldier/Sprite#AutoHeight/Grid"):GetComponent("UIGrid")
end

local function StopLoadTroopCoroutine()
    if _ui.loadTroopCoroutine ~= nil then
        coroutine.stop(_ui.loadTroopCoroutine)
        _ui.LoadTroopCoroutine = nil
    end
end

local function LoadTroopList()
    local totalArmyCount = 0
    local buildingMsg = _ui.buildingMsg
    _ui.troopList = {}
    for i, v in ipairs(buildingMsg.armys) do
        local troopTransform
        if i > _ui.troopTableTransform.childCount then
            troopTransform = NGUITools.AddChild(_ui.troopTableTransform.gameObject, _ui.troopPrefab).transform
        else
            troopTransform = _ui.troopTableTransform:GetChild(i - 1)
        end
        local troop = {}
        LoadTroopObject(troop, troopTransform)
        troop.msg = v
        local face = 0
        for _, vv in ipairs(buildingMsg.userBase) do
            if vv.charid == v.charId then
                face = vv.face
                break
            end
        end
        troop.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", face)
        SetClickCallback(troop.faceBg, function()
            OtherInfo.RequestShow(v.charId)
        end)
        troop.nameLabel.text = v.charName
        local hasPath = v.pathid ~= 0
        troop.stateLabel.gameObject:SetActive(hasPath)
        troop.timeBg.gameObject:SetActive(hasPath)
        for ii, vv in ipairs(troop.heroList) do
            local heroMsg = v.army.hero.heros[ii]
            if heroMsg ~= nil then
                local heroData = TableMgr:GetHeroData(heroMsg.baseid)
                vv.icon.gameObject:SetActive(true)
                LoadHero(vv, heroMsg, heroData)
            else
                vv.icon.gameObject:SetActive(false)
            end
        end
        local armyCount = 0

        local armyList = {}
        for __, vv in ipairs(v.army.army.army) do
            if armyList[vv.armyId] == nil then
                armyList[vv.armyId] = {0, 0, 0, 0}
            end
            armyList[vv.armyId][vv.armyLevel] = armyList[vv.armyId][vv.armyLevel] + vv.num
            armyCount = armyCount + vv.num
        end
        totalArmyCount = totalArmyCount + armyCount

        troop.totalLabel.text = armyCount
        local armyIndex = 1
        local armyId, armyData = next(armyList, armyId)
        troop.armyList = {}
        while armyId ~= nil do
            local barrackData = TableMgr:GetBarrackData(armyId, 1)
            local armyTransform
            if armyIndex > troop.armyGrid.transform.childCount then
                armyTransform = NGUITools.AddChild(troop.armyGrid.transform.gameObject, _ui.armyPrefab).transform
            else
                armyTransform = troop.armyGrid.transform:GetChild(armyIndex - 1)
            end
            local army = {}
            LoadArmyObject(army, armyTransform)
            army.nameLabel.text = TextMgr:GetText(barrackData.TabName)
            army.bgObject:SetActive((armyIndex - 1) % 4 == 0)
            for ii, vv in ipairs(army.levelList) do
                vv.countLabel.text = armyData[ii]
            end
            army.gameObject:SetActive(true)
            armyId, armyData = next(armyList, armyId)
            armyIndex = armyIndex + 1
        end
        for j = armyIndex, troop.armyGrid.transform.childCount do
            troop.armyGrid.transform:GetChild(j - 1).gameObject:SetActive(false)
        end
        troop.gameObject:SetActive(true)
        troop.armyGrid:Reposition()
        troop.controller:CalAutoHight()
        _ui.troopList[i] = troop
        _ui.troopTable:Reposition()
        coroutine.step()
    end

    for i = #_ui.troopList + 1, _ui.troopTableTransform.childCount do
        _ui.troopTableTransform:GetChild(i - 1).gameObject:SetActive(false)
    end

    if not buildingMsg.isCompleted then
        _ui.countLabel.text = totalArmyCount
    end
end

local function UpdateTime()
    local buildingMsg = _ui.buildingMsg
    local buildingData = _ui.buildingData
    --采集阶段
    if buildingMsg.isCompleted then
        local timeText = Global.GetLeftCooldownTextLong(buildingMsg.lifeTime)
        _ui.timeLabel1.text = TextMgr:GetText(Text.collectnew_time)
        _ui.timeLabel.text = timeText
        _ui.countLabel.text = math.max(buildingMsg.leftCapacity - buildingMsg.totalSpeed * (GameTime.GetSecTime() - buildingMsg.nowTime), 0)
    else
        _ui.timeLabel1.text = TextMgr:GetText(Text.union_ore8)
        --建造阶段
        if #buildingMsg.armys > 0 then
            local timeText = Global.GetLeftCooldownTextLong(buildingMsg.completeTime)
            _ui.timeLabel.text = timeText
        end
    end
    for _, v in ipairs(_ui.troopList) do
        local armyMsg = v.msg
        if armyMsg.pathid ~= 0 then
            local arriveTime = armyMsg.startTime + armyMsg.takeTime
            local leftCooldownSecond = Global.GetLeftCooldownSecond(arriveTime)
            if leftCooldownSecond > 0 then
                v.timeSlider.value = 1 - Global.GetLeftCooldownMillisecond(arriveTime) / (armyMsg.takeTime * 1000)
                v.timeLabel.text = Global.SecondToTimeLong(leftCooldownSecond)
            else
                v.timeBg.gameObject:SetActive(false)
                v.stateLabel.gameObject:SetActive(false)
                armyMsg.pathid = 0
            end

        end
    end
end

function LoadUI()
    _ui.buildingMsg = UnionBuildingData.GetDataByBaseId(_ui.buildingDataId)
    if _ui.buildingMsg == nil then
        CloseAll()
        FloatText.Show(TextMgr:GetText(Text.union_ore25))
        return
    end
    _ui.buildingData = TableMgr:GetUnionBuildingData(_ui.buildingDataId)
    local buildingMsg = _ui.buildingMsg
    local buildingData = _ui.buildingData
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    local memberMsg = unionInfoMsg.memberInfo
    local pos = buildingMsg.pos
    _ui.icon.mainTexture = ResourceLibrary:GetIcon("Icon/UnionBuilding/", buildingData.icon)
    _ui.nameLabel.text = TextMgr:GetText(buildingData.name)
    _ui.coordLabel.text = String.Format(TextMgr:GetText(Text.ui_worldmap_77), 1, pos.x, pos.y)
    _ui.unionLabel.text = string.format("[%s]%s", unionMsg.banner, unionMsg.name)
    SetClickCallback(_ui.coordLabel.gameObject, function()
        UnionInfo.CloseAll()
        MainCityUI.ShowWorldMap(pos.x, pos.y, true, nil)
    end)

    --采集阶段
    if buildingMsg.isCompleted then
        _ui.tipLabel.text = TextMgr:GetText(Text.union_ore17)
        --自己参与
        if UnionBuildingData.HasSelfArmy(buildingMsg) then
            _ui.bottomLabel.text = TextMgr:GetText(Text.ui_worldmap_38)
            SetClickCallback(_ui.bottomButton.gameObject, function()
                local req = MapMsg_pb.CancelPathRequest()
                req.taruid = buildingMsg.uid
                Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
                    if msg.code == ReturnCode_pb.Code_OK then
                        UnionInfo.CloseAll()
                        local pos = buildingMsg.pos
                        MainCityUI.ShowWorldMap(pos.x, pos.y, true, nil)
                    else
                        Global.ShowError(msg.code)
                    end
                end, true)
            end)
            --自己未参与
        else
            _ui.bottomLabel.text = TextMgr:GetText(Text.union_ore15)
            SetClickCallback(_ui.bottomButton.gameObject, function()
                WorldMapData.RequestSceneEntryInfoFresh(0, pos.x, pos.y, function(tileMsg)
                    TileInfo.SetTileMsg(tileMsg)
                    BattleMove.Show(Common_pb.TeamMoveType_MineTake, buildingMsg.uid, "", pos.x, pos.y, function()
                        UnionInfo.CloseAll()
                        MainCityUI.ShowWorldMap(nil, nil, true, nil)
                    end,
                    nil,
                    nil,
                    function()
                    end)
                end)
            end)
        end
        _ui.timeLabel1.text = TextMgr:GetText(Text.collectnew_time)
        _ui.countLabel1.text = TextMgr:GetText(Text.UnionWareHouse_ui12)
        --建造阶段
    else
        _ui.countLabel1.text = TextMgr:GetText(Text.union_ore23)
        _ui.timeLabel1.text = TextMgr:GetText(Text.union_ore8)
        _ui.tipLabel.text = TextMgr:GetText(Text.union_ore6)
        --自己参与
        if UnionBuildingData.HasSelfArmy(buildingMsg) then
            _ui.bottomLabel.text = TextMgr:GetText(Text.ui_worldmap_38)
            SetClickCallback(_ui.bottomButton.gameObject, function()
                local req = MapMsg_pb.CancelPathRequest()
                req.taruid = buildingMsg.uid
                Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
                    if msg.code == ReturnCode_pb.Code_OK then
                        UnionInfo.CloseAll()
                        local pos = buildingMsg.pos
                        MainCityUI.ShowWorldMap(pos.x, pos.y, true, nil)
                    else
                        Global.ShowError(msg.code)
                    end
                end, true)
            end)
        else
            --自己未参与
            _ui.bottomLabel.text = TextMgr:GetText(Text.union_ore7)
            SetClickCallback(_ui.bottomButton.gameObject, function()
                WorldMapData.RequestSceneEntryInfoFresh(0, pos.x, pos.y, function(tileMsg)
                    TileInfo.SetTileMsg(tileMsg)
                    BattleMove.Show(Common_pb.TeamMoveType_GuildBuildCreate, buildingMsg.uid, "", pos.x, pos.y, function()
                        UnionInfo.CloseAll()
                        MainCityUI.ShowWorldMap(nil, nil, true, nil)
                    end,
                    nil,
                    nil,
                    function()
                    end)
                end)
            end)
        end
        if #buildingMsg.armys == 0 then
            _ui.timeLabel.text = Global.SecondToTimeLong(math.ceil((buildingData.progressBar - buildingMsg.curCreatePro) / buildingData.enableEnergyPerSec))
        end
    end

    StopLoadTroopCoroutine()
    _ui.loadTroopCoroutine = coroutine.start(LoadTroopList)
    UpdateTime()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("background widget/close btn"):GetComponent("UIButton")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    _ui.nameLabel = transform:Find("background widget/titlebg/titel/text"):GetComponent("UILabel")
    _ui.icon = transform:Find("background widget/top/icon"):GetComponent("UITexture")
    _ui.unionLabel = transform:Find("background widget/top/1/Label2"):GetComponent("UILabel")
    _ui.coordLabel = transform:Find("background widget/top/2/coordinate"):GetComponent("UILabel")
    _ui.timeLabel1 = transform:Find("background widget/top/3/Label1"):GetComponent("UILabel")
    _ui.timeLabel = transform:Find("background widget/top/3/Label2"):GetComponent("UILabel")
    _ui.countLabel1 = transform:Find("background widget/top/4/Label1"):GetComponent("UILabel") 
    _ui.countLabel = transform:Find("background widget/top/4/Label2"):GetComponent("UILabel") 
    _ui.tipLabel = transform:Find("background widget/top/Label"):GetComponent("UILabel")
    _ui.bottomButton = transform:Find("background widget/button"):GetComponent("UIButton")
    _ui.bottomLabel = transform:Find("background widget/button/Label"):GetComponent("UILabel")
    _ui.troopScrollView = transform:Find("background widget/mid/Scroll View"):GetComponent("UIScrollView")
    _ui.troopPrefab = transform:Find("ItemInfo").gameObject
    _ui.armyPrefab = transform:Find("soilder_list").gameObject
    local troopTableTransform = transform:Find("background widget/mid/Scroll View/Table")
    _ui.troopTableTransform = troopTableTransform
    _ui.troopTable = troopTableTransform:GetComponent("UITable")
    UnionBuildingData.AddListener(LoadUI)
end

function Close()
    UnionBuildingData.RemoveListener(LoadUI)
    StopLoadTroopCoroutine()
    _ui = nil
    if not GUIMgr.Instance:IsMenuOpen("UnionInfo") then
	end
end

function Update()
    updateTimer = updateTimer - GameTime.realDeltaTime
    if updateTimer > 0 then
        return
    else
        updateTimer = 1
    end
    UpdateTime()
end

function Show(buildingDataId)
    Global.OpenUI(_M)
    _ui.buildingDataId = buildingDataId
    LoadUI()
end
