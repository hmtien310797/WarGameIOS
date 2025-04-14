module("MobaWarZoneMap", package.seeall)
local GUIMgr = Global.GGUIMgr
local Controller = Global.GController
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local UIAnimMgr = Global.GUIAnimMgr
local String = System.String
local WorldToLocalPoint = NGUIMath.WorldToLocalPoint
local Screen = UnityEngine.Screen
local abs = math.abs
local isEditor = UnityEngine.Application.isEditor

local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local math = math
local Mathf = Mathf
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local PosToDataIndex = MapPreviewData.PosToDataIndex
local XYToDataIndex = MapPreviewData.XYToDataIndex
local IsUnionField = MapPreviewData.IsUnionField
local IsNeighboringCoord = Global.IsNeighboringCoord
local MapPool = MapPool

local halfScreenWidth = UnityEngine.Screen.width * 0.5
local halfScreenHeight = UnityEngine.Screen.height * 0.5

local GetCategoryId = MobaMsg.GetCategoryId
local GetReqMsg = MobaMsg.GetReqMsg
local GetTypeId = MobaMsg.GetTypeId
local GetRepMsgPb = MobaMsg.GetRepMsgPb

local mapSize
local tileWidth
local tileHeight

local selectedMapX
local selectedMapY

local uiRoot
local screenWidth
local screenHeight

local oldMapX
local oldMapY
local _ui
local teamInfoMsg
local enterMsg

function Hide()
    Global.CloseUI(_M)
end

local function MapPositionToMapCoord(mapPos)
    local x = mapPos.x / tileWidth
    local y = mapPos.y / tileHeight
    return Mathf.Round(y + x), Mathf.Round(y - x)
end

local function MapCoordToMapPosition(mapX, mapY)
    return Vector3((mapX - mapY) * tileWidth * 0.5, (mapX + mapY) * tileHeight * 0.5)
end

local function ScreenPositionToMapCoord(screenPosition)
    local mapPos = NGUIMath.ScreenToPixels(screenPosition, _ui.mapTransform)
    return MapPositionToMapCoord(mapPos)
end

local function MapToZoneCoord(coord)
    return math.floor(coord / 2)
end

function SelectTile(mapX, mapY)
    selectedMapX, selectedMapY = mapX, mapY
    _ui.tileSelectedWidget.gameObject:SetActive(true)
    _ui.tileSelectedWidget.transform.localPosition = MapCoordToMapPosition(mapX, mapY)
    UITweener.PlayAllTweener(_ui.tileSelectedWidget.gameObject, true, true, false)
    _ui.tileSelectedWidget:GetComponent("UITweener"):SetOnFinished(EventDelegate.Callback(function()
        Hide()
        local minX, minY = MobaMain.MobaMinPos()
        local worldMapX = mapX * 2 + minX
        local worldMapY = mapY * 2 + minY
		if Global.GetMobaMode() ==2 then 
			GuildWarMain.LookAt(worldMapX, worldMapY)
			GuildWarMain.SelectTile(worldMapX, worldMapY)
		else
			MobaMain.LookAt(worldMapX, worldMapY)
			MobaMain.SelectTile(worldMapX, worldMapY)
		end
    end))
end

local function SetMapPosition(x, y)
    x = Mathf.Clamp(x, -(mapSize * tileWidth * 0.5 - screenWidth * 0.5), mapSize * tileWidth * 0.5 - screenWidth * 0.5)
    y = Mathf.Clamp(y, -(mapSize + mapSize - 1) * tileHeight * 0.5 + screenHeight * 0.5 -screenHeight * 0.16 , tileHeight * 0.5 -screenHeight * 0.5)
    _ui.mapTransform.localPosition = Vector3(x, y, 0)
end

local function MapBgDragCallback(go, delta)
    delta = delta * uiRoot.pixelSizeAdjustment

    local mapPosition = _ui.mapTransform.localPosition

    SetMapPosition(mapPosition.x + delta.x, mapPosition.y + delta.y)
end

local function MapBgClickCallback(go)
    local touchPos = UICamera.currentTouch.pos
    local mapX, mapY = ScreenPositionToMapCoord(touchPos)
    if mapX < 0 or mapX >= mapSize or mapY < 0 or mapY >= mapSize then
        return
    end
    SelectTile(mapX, mapY)
end

local function SetLookAtCoord(mapX, mapY)
    local localPosition = MapCoordToMapPosition(mapX, mapY)
    SetMapPosition(-localPosition.x, -localPosition.y)
end

local function RequestTeamInfo()
    local req = GetReqMsg("MobaSeeTeamInfoRequest")
    Global.Request(GetCategoryId(), GetTypeId("MobaSeeTeamInfoRequest"), req, GetRepMsgPb("MobaSeeTeamInfoResponse"), function(msg)
        teamInfoMsg = msg
    end, true)
end

local function SecondUpdate()
    _ui.timeLabel.text = Global.GetLeftCooldownTextLong(enterMsg.overtime)
    RequestTeamInfo()
    _ui.scoreLabel1.text = System.String.Format(TextMgr:GetText(Text.LuckyRotary_3), teamInfoMsg.team1.score)
    _ui.scoreLabel2.text = System.String.Format(TextMgr:GetText(Text.LuckyRotary_3), teamInfoMsg.team2.score)
end

local function LoadUI()
Global.DumpMessage(_ui.msg , "d:/1.lua")
    for _, v in ipairs(_ui.msg.zeinfo) do
        local buildingId = v.buidingid
        local teamId = v.rulingTeam
        local buildingTransform = _ui.infoBgTransform:Find("building_bg/" ..buildingId)
        local buildingData = TableMgr:GetMobaMapBuildingDataByID(buildingId)
        local charName = v.chiefname
        local charId = v.chiefid
        buildingTransform:Find("Container/bg_name/icon"):GetComponent("UISprite").spriteName = "occupy_" .. teamId
        local iconSprite = buildingTransform:Find("Container/icon_gov"):GetComponent("UISprite")
        local entryType = v.data.entryType
        if entryType == Common_pb.SceneEntryType_MobaGate then
            if v.cityguard == 0 then
                iconSprite.spriteName = "MobaWarZoneMap_walldie"
            else
                iconSprite.spriteName = "MobaWarZoneMap_wall"
            end
            buildingTransform:Find("Container/Label (2)").gameObject:SetActive(v.cityguard ~= 0)
            buildingTransform:Find("Container/bg_name/icon").gameObject:SetActive(v.cityguard ~= 0)
		elseif entryType == Common_pb.SceneEntryType_MobaSmallBuild then
            iconSprite.spriteName = "MobaWarZoneMap_tower"
            buildingTransform:Find("Container/Label (2)").gameObject:SetActive(v.cityguard ~= 0)
            buildingTransform:Find("Container/bg_name/icon").gameObject:SetActive(v.cityguard ~= 0)
        end
        if charId ~= 0 then
            buildingTransform:Find("Container/Label (2)"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(Text.moba_mapzone4), charName)
        else
            buildingTransform:Find("Container/Label (2)"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(Text.moba_mapzone4), TextMgr:GetText("moba_mapzone" .. teamId))
        end
        buildingTransform:Find("Container/bg_name/Label (1)"):GetComponent("UILabel").text = TextMgr:GetText(buildingData.Name)
        local buildingPos = v.data.pos
        local buildingMapX = MapToZoneCoord(buildingPos.x)
        local buildingMapY = MapToZoneCoord(buildingPos.y)
        buildingTransform.localPosition = MapCoordToMapPosition(buildingMapX, buildingMapY)
    end

    for i, v in ipairs(_ui.msg.zminfo) do
        local monsterTransform
        if i > _ui.monsterBgTransform.childCount then
            monsterTransform = NGUITools.AddChild(_ui.monsterBgTransform.gameObject, _ui.monsterPrefab).transform
        else
            monsterTransform = _ui.monsterBgTransform:GetChild(i - 1)
        end
        monsterTransform.gameObject:SetActive(true)
        local monsterPos = v.data.pos
        local monsterMapX = MapToZoneCoord(monsterPos.x)
        local monsterMapY = MapToZoneCoord(monsterPos.y)
        monsterTransform.localPosition = MapCoordToMapPosition(monsterMapX, monsterMapY)
    end

    for i = #_ui.msg.zminfo + 1, _ui.monsterBgTransform.childCount do
        _ui.monsterBgTransform:GetChild(i - 1).gameObject:SetActive(false)
    end

    local basePos = MobaMainData.GetData().pos

    local baseMapX = MapToZoneCoord(basePos.x)
    local baseMapY = MapToZoneCoord(basePos.y)
    _ui.baseTransform.localPosition = MapCoordToMapPosition(baseMapX, baseMapY)
    _ui.timeLabel = transform:Find("Container/Top/time"):GetComponent("UILabel")
    SecondUpdate()
end

function Awake()
    _ui = {}
    uiRoot = GUIMgr.UIRoot:GetComponent("UIRoot")
    screenWidth = UnityEngine.Screen.width * uiRoot.pixelSizeAdjustment
    screenHeight = UnityEngine.Screen.height * uiRoot.pixelSizeAdjustment
    _ui.scoreLabel1 = transform:Find("Container/Top/text2"):GetComponent("UILabel")
    _ui.scoreLabel2 = transform:Find("Container/Top/text4"):GetComponent("UILabel")
    _ui.monsterBgTransform = transform:Find("Container/map_bg/map/info_bg/monster_bg")
    _ui.monsterPrefab = _ui.monsterBgTransform:GetChild(0).gameObject
    _ui.infoBgTransform = transform:Find("Container/map_bg/map/info_bg")
    _ui.baseTransform = _ui.infoBgTransform:Find("mypos")
    local backButton = transform:Find("Container/btn_back")
    SetClickCallback(backButton.gameObject, function()
        Hide()
    end)

    local mapBg = transform:Find("Container/map_bg")
    _ui.mapTransform = mapBg:Find("map")

    UIUtil.SetDragCallback(mapBg.gameObject, MapBgDragCallback)
    UIUtil.SetPressCallback(mapBg.gameObject, MapBgPressCallback)
    UIUtil.SetClickCallback(mapBg.gameObject, MapBgClickCallback)

    mapSize = 32
    tileWidth = 42
    tileHeight = 28
    local bgMap = _ui.mapTransform:Find("bg"):GetComponent("TiledMap")
    local bgMapSize = bgMap.mapSize
    for x = 0, bgMapSize - 1 do
        for y = 0, bgMapSize - 1 do
            local sprite = tostring((x + y) % 2 + 1)
            bgMap:SetTile(x, y, sprite, Color.white, true)
        end
    end
    bgMap:MarkAsChanged()

    _ui.tileSelectedWidget = _ui.infoBgTransform:Find("selected"):GetComponent("UIWidget")
    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()
end

function Start()
    LoadUI()
end

function Close()
    _ui.timer:Stop()
    _ui = nil
end

local function RequestBuildingInfo(callback)
    local req = GetReqMsg("MobaGetZoneBuildingInfoRequest")
    Global.Request(GetCategoryId(), GetTypeId("MobaGetZoneBuildingInfoRequest"), req, GetRepMsgPb("MobaGetZoneBuildingInfoResponse"),callback , true)
end

function Refresh()
    RequestBuildingInfo(function(msg)
        if msg.code == 0 and _ui ~= nil then
            _ui.msg = msg
            LoadUI()
        end
    end)
end

function Show(mapX, mapY)
    mapX = mapX or oldMapX
    mapY = mapY or oldMapY
    oldMapX = mapX
    oldMapY = mapY
    if Global.GetMobaMode() == 2 then
        enterMsg={}
        enterMsg.overtime = UnionMobaActivityData.GetMobaEnterMsg().overTime -- UnionMobaActivityData.GetData().matchtime + tonumber(tableData_tGuildMobaGlobal.data[5].Value)
    else
        enterMsg = MobaData.GetMobaEnterInfo()
    end
    
    RequestTeamInfo()
    RequestBuildingInfo(function(msg)
        if msg.code == 0 then
            Global.OpenUI(_M)
            SetLookAtCoord(mapX, mapY)
            _ui.msg = msg
        else
            Global.FloatError(msg.code, Color.white)
        end
    end)
end
