module("WorldMap", package.seeall)

local ServerBlockSize = 16;
local ServerBlockTotalCount = 22;

local ZOOM_SPEED = 0.01
local MIN_SCALE = 0.6
local MAX_SCALE = 1.0
local DEFAULT_SCALE = 0.6
local MAX_CLOUD_OFFSET = 4000 * 4000

local mapSize = 352
local updateMapTimer = 1


function GetServerMapSize()
    return mapSize
end

function GetServerBlockSize()
    return ServerBlockSize
end

function GetServerBlockTotalCount()
    return ServerBlockTotalCount
end

TESTGOV = false

local poolConfigList =
{
    -- playerInfo = {"WorldMap_Player_Name", 100},
    -- monsterInfo = {"WorldMap_Monter_Name", 100},
    resourceInfo = {"WorldBubble", 10},
    -- shieldEffect = {"fangyuzhao2", 70},
    -- winEffect = {"bigmapwin", 50},
    -- loseEffect = {"bigmaplose", 30},
    -- pathTexture = {"map_path", 100},
    -- unionmonsterGate = {"unionmonster_gate" , 10},
    -- pveMonsterDone = {"pveMonsterDone" , 10},
    -- unionBuilding = {"Union_BuildName" , 20},
    -- pathName = {"path_name", 100},
    -- unionName = {"union", 100},
}

local tutorialMapX
local tutorialMapY

local governmentData
local restrictData

local WorldMapDistanceFactor
local WorldMapBarrackPicture

local GUIMgr = Global.GGUIMgr
local Controller = Global.GController
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local UIAnimMgr = Global.GUIAnimMgr
local String = System.String
local WorldToLocalPoint = NGUIMath.WorldToLocalPoint
local Screen = UnityEngine.Screen
local isEditor = UnityEngine.Application.isEditor

local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local WorldMapData = WorldMapData

local uiRoot

local _ui

ActivePreview = nil
CheckPreview = nil
local pbuilddata
local oldDumpCount
local currentPosIndex
local currentBorderIndex
local showBorder = true
local bgPressed
local followPathId

local charId
local selfGuildId
local MapBgDragCallback
local mapNet

local ShowActive = UnityEngine.Vector3.one
local HideActive = UnityEngine.Vector3.zero

--滑动阻尼
local deltaX
local deltaY
local smoothness = 0.2
local keepMove = false
local negativeX = false
local negativeY = false


--------------------------------------
--为政府临时加入的表现
--------------------------------------
local Rects ={
                {
                    rect_min_x = 273,
                    rect_min_y = 273,
                    rect_w = 3,
                    rect_h = 3,
                },
                {
                    rect_min_x = 237,
                    rect_min_y = 273,
                    rect_w = 3,
                    rect_h = 3,
                },
                {
                    rect_min_x = 237,
                    rect_min_y = 237,
                    rect_w = 3,
                    rect_h = 3,
                },
                {
                    rect_min_x = 273,
                    rect_min_y = 237,
                    rect_w = 3,
                    rect_h = 3,
                },
                {
                    rect_min_x = 255,
                    rect_min_y = 255,
                    rect_w = 7,
                    rect_h = 7,
                },
            }

local previewEnabled = false

function IsInRect(input_x,input_y)
   for _, v in pairs(Rects) do
        if v.rect_min_x <= input_x and v.rect_min_y <= input_y and v.rect_min_x + v.rect_w -1  >= input_x and v.rect_min_y + v.rect_h-1 >= input_y then
            return true
        end
   end
   return false
end

function InitGovernmentTest()
    _ui.GTRoot = transform:Find("Container/GovernmentInfo")
    _ui.GTCloseBtn = transform:Find("Container/GovernmentInfo/Container/bg_frane/bg_top/btn_close")
    _ui.GTMask = transform:Find("Container/GovernmentInfo/Container")
    _ui.GTRoot.gameObject:SetActive(false)
    SetClickCallback(_ui.GTCloseBtn.gameObject,function()
        _ui.GTRoot.gameObject:SetActive(false)
    end)
    SetClickCallback(_ui.GTMask.gameObject,function()
        _ui.GTRoot.gameObject:SetActive(false)
    end)    
end

function ShowGovernmentTest(input_x,input_y)
    --if not IsInRect(input_x,input_y) then
    --    return false
    --end
    _ui.GTRoot.gameObject:SetActive(true)
    --return true
end
--------------------------------------
--============================================
--------------------------------------

local FORT_WIDTH = 4
local FORT_HEIGHT = 4
local function IsInFortRect(x, y)
    for _, fort in pairs(FortsData.GetFortsData()) do
        local minX = fort.pos.x - (FORT_WIDTH / 2 - 1)
        local minY = fort.pos.y - (FORT_HEIGHT / 2 - 1)

        if x >= minX and x < minX + FORT_WIDTH and y >= minY and y < minY + FORT_HEIGHT then
            return fort.subType
        end
    end

    return 0
end

--------------------------------------
--为要塞临时加入的表现
--------------------------------------

function InitFortTest()
    _ui.FTRoot = transform:Find("Container/FortInfo"):GetComponent("UIPanel")
   
    _ui.FTCloseBtn = transform:Find("Container/FortInfo/Container/bg_frane/bg_top/btn_close")
    _ui.FTMask = transform:Find("Container/FortInfo/Container")
    _ui.FTRoot.gameObject:SetActive(false)
    SetClickCallback(_ui.FTCloseBtn.gameObject,function()
        _ui.FTRoot.gameObject:SetActive(false)
    end)
    SetClickCallback(_ui.FTMask.gameObject,function()
        _ui.FTRoot.gameObject:SetActive(false)
    end)    
end

function ShowFortTest(input_x,input_y)
    if not IsInFortRect(input_x, input_y) then
        return false
    end
    _ui.FTRoot.depth = 20
    _ui.FTRoot.gameObject:SetActive(true)
    return true
end
--------------------------------------
--============================================
-------------------------------------
function GetWorldMapMgr()
    if _ui == nil then
        return nil
    end
    return _ui.mapMgr
end

function GetGovernmentData()
    if governmentData == nil then
        governmentData = TableMgr:GetBasicSurfaceDataByType(1)
    end
    return governmentData
end

function GetRestrictData()
    if restrictData == nil then
        restrictData = TableMgr:GetBasicSurfaceDataByType(100)
    end
    return restrictData
end

function IsInArea(areaData, mapX, mapY)
    return mapX >= areaData.coordX and mapX <= areaData.coordX + areaData.width-1
    and mapY >= areaData.coordX and mapY <= areaData.coordY + areaData.height-1
end

function IsInGovernmentArea(mapX, mapY)
    return IsInArea(GetGovernmentData(), mapX, mapY)
end

function IsInRestrictArea(mapX, mapY)
    return IsInArea(GetRestrictData(), mapX, mapY) and not IsInGovernmentArea(mapX, mapY)
end

local function GetWorldMapDistanceFactor()
    if WorldMapDistanceFactor == nil then
        WorldMapDistanceFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.WorldMapDistanceFactor).value)
    end
    return WorldMapDistanceFactor
end


function GetTileData(tileMsg)
    local tileData
    local entryType = tileMsg.data.entryType
    if entryType == Common_pb.SceneEntryType_Home then
        tileData = TableMgr:GetBuildCoreDataByLevel(tileMsg.home.homelvl)
        if tileData == nil then
            error(string.format("找不到等级为:%d 的基地数据", tileMsg.home.homelvl))
        end
    elseif entryType == Common_pb.SceneEntryType_Monster then
        tileData = TableMgr:GetMonsterRuleData(tileMsg.monster.level)
        if tileData == nil then
            error(string.format("找不到等级为:%d 的怪物数据", tileMsg.monster.level))
        end
    elseif entryType == Common_pb.SceneEntryType_ActMonster then
        local guildMonster = false
        if tileMsg.monster ~= nil and tileMsg.monster.guildMon.guildMonster ~= nil then
            guildMonster = tileMsg.monster.guildMon.guildMonster
        end

        local pveMonster = false
        if tileMsg.monster ~= nil and tileMsg.monster.digMon ~= nil and tileMsg.monster.digMon.monsterBaseId > 0 then
            pveMonster = true
        end

        if guildMonster then
            tileData = TableMgr:GetUnionMonsterData(tileMsg.monster.level)
        elseif pveMonster then
            tileData = TableMgr:GetPveMonsterData(tileMsg.monster.digMon.monsterBaseId)
        else
            tileData = TableMgr:GetActMonsterRuleData(tileMsg.monster.level)
        end
        if tileData == nil then
            error(string.format("找不到等级为:%d 的怪物数据", tileMsg.monster.level))
        end
    elseif entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
        tileData = TableMgr:GetResourceRuleDataByTypeLevel(entryType, tileMsg.res.level)
        if tileData == nil then
            error(string.format("找不到类型为:%d 等级为%d的资源数据", entryType, tileMsg.res.level))
        end
    elseif entryType == Common_pb.SceneEntryType_Barrack or entryType == Common_pb.SceneEntryType_Occupy then
        tileData = {picture = WorldMapBarrackPicture}
    elseif entryType == Common_pb.SceneEntryType_GuildBuild then
        tileData = TableMgr:GetUnionBuildingData(tileMsg.guildbuild.baseid)
        if tileData == nil then
            error(string.format("找不到id为%d的联盟建筑数据", tileMsg.guildbuild.baseid))
        end
    elseif entryType == Common_pb.SceneEntryType_SiegeMonster then
        tileData = TableMgr:GetMapBuildingDataByID(entryType)
    elseif entryType == Common_pb.SceneEntryType_Fort then
        tileData = TableMgr:GetMapBuildingDataByID(entryType * 100 + tileMsg.fort.subType)
    elseif entryType == Common_pb.SceneEntryType_Govt then
        tileData = TableMgr:GetMapBuildingDataByID(entryType)
    elseif entryType == Common_pb.SceneEntryType_Turret then
        tileData = TableMgr:GetMapBuildingDataByID(entryType * 100 + tileMsg.centerBuild.turret.subType)
    elseif entryType == Common_pb.SceneEntryType_EliteMonster then
        tileData = TableMgr:GetEliteRebelData(tileMsg.elite.type , tileMsg.elite.level)
    elseif entryType == Common_pb.SceneEntryType_Stronghold then
        local stronghold = TableMgr:GetStrongholdRuleByID(tileMsg.centerBuild.stronghold.subtype)
        tileData = TableMgr:GetMapBuildingDataByID(stronghold.BuildId)
    elseif entryType == Common_pb.SceneEntryType_Fortress then
		local fortess = TableMgr:GetFortressRuleByID(tileMsg.centerBuild.fortress.subtype)--fortress
		tileData = TableMgr:GetMapBuildingDataByID(fortess.BuildId)
	elseif entryType == Common_pb.SceneEntryType_WorldCity then
		tileData = TableMgr:GetWorldCityDataByID(tileMsg.worldCity.cityId)
	elseif entryType == Common_pb.SceneEntryType_WorldMonster then
		Global.DumpMessage(tileMsg , "d:/tileMsg.lua")
		 tileData = TableMgr:GetMonsterRuleData(tileMsg.monster.level)
    end
    return tileData
end

function MapCoordToPosIndex(mapX, mapY)
    return math.floor(mapY % mapSize / ServerBlockSize)  * ServerBlockTotalCount + math.floor(mapX % mapSize / ServerBlockSize)
end

function WorldPos2WLogicPos(pos)
    local wposx = pos.x + mapSize*0.5
    local wposy = pos.z + mapSize*0.5
    local x = math.floor(wposx / ServerBlockSize - 0.5)
    local y = math.floor(wposy / ServerBlockSize - 0.5)
    return x,y
end


local function MapCoordToBorderIndex(mapX, mapY)
    return math.floor(mapY % mapSize / 8)  * 64 + math.floor(mapX % mapSize / 8)
end

function MapCoordToDataIndex(mapX, mapY)
    return ((mapY % mapSize) * mapSize + (mapX % mapSize)) + 1
end

function GetCenterMapCoord()
    -- local startX, startY = _ui.mapMgr.StartX, _ui.mapMgr.StartY
    -- local endX, endY = _ui.mapMgr.EndX, _ui.mapMgr.EndY

    return _ui.mapMgr.CenterX,_ui.mapMgr.CenterY
end

function GetDistance(mapX1, mapY1, mapX2, mapY2)
    local diffX = mapX1 - mapX2
    local diffY = mapY1 - mapY2

	local disStr = string.split(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.WorldMapPVPDistanceFactor).value , ",")
	local phDis = math.sqrt(diffX * diffX + diffY * diffY)
	local logDis = tonumber(disStr[1]) * phDis * phDis + tonumber(disStr[2]) * phDis + tonumber(disStr[3])
    return logDis
end

function GetDistanceToCenter(mapX, mapY)
    local centerMapX, centerMapY = GetCenterMapCoord()

    return GetDistance(centerMapX, centerMapY, mapX, mapY)
end

function GetDistanceToMyBase(mapX, mapY, isPvp)
    local baseCoord = MapInfoData.GetData().mypos
    local baseMapX, baseMapY = baseCoord.x, baseCoord.y

    if _ui == nil then
        return GetDistance(baseMapX, baseMapY, mapX, mapY)
    end
    local tileMsg
    local tileMsgBytes = _ui.mapMgr:TileInfo(mapX % GetServerMapSize(), mapY % GetServerMapSize())
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then 
        return GetDistance(baseMapX, baseMapY, mapX, mapY)
    end
    return GetDistance(baseMapX, baseMapY, tileMsg.data.pos.x,tileMsg.data.pos.y)
end

function GetTileGidByMapCoord(mapX, mapY)
    local gid = 0
    gid = Main.Instance:GetBlockInfo(mapX % mapSize, mapY % mapSize)
    return gid
end

local function IsGuildMonster(tileMsg)
    local entryType = Common_pb.SceneEntryType_None
    local guildMonster = false
    if tileMsg ~= nil then
        entryType = tileMsg.data.entryType
        if entryType == Common_pb.SceneEntryType_ActMonster and tileMsg.monster ~= nil and tileMsg.monster.guildMon.guildMonster ~= nil then
            guildMonster = tileMsg.monster.guildMon.guildMonster
        end
    end

    return guildMonster
end

local function IsPveMonster(tileMsg)
    if tileMsg.monster ~= nil and tileMsg.monster.digMon ~= nil and tileMsg.monster.digMon.monsterBaseId > 0 then
        return true
    end

    return false
end

function GetTileGidByMsgData(mapX, mapY, tileMsg, tileData)
    local gid = tonumber(tileData.picture)
    if gid ~= nil then
        return gid
    end

    local gidListX = string.split(tileData.picture, ";")
    if IsGuildMonster(tileMsg) then
        if tileMsg.monster.guildMon.guildMonsterState == 2 then
            gidListX = string.split(tileData.picture2, ";")
        end
    end

    if #gidListX == 1 then
        local pos = tileMsg.data.pos
        local gidListY = string.split(gidListX[1], ",")
        local offsetY = (mapY - pos.y) % mapSize
        return tonumber(gidListY[offsetY + 1])
    else
        local pos = tileMsg.data.pos
        local offsetX = (mapX - pos.x) % mapSize
        local gidListY = string.split(gidListX[offsetX + 1], ",")
        if #gidListY == 1 then
            return tonumber(gidListY[1])
        else
            local offsetY = mapY - pos.y
            return tonumber(gidListY[offsetY + 1])
        end
    end
end

function GetTileName(mapX, mapY)
    local tileGid = GetTileGidByMapCoord(mapX, mapY)
    local artSettingData = TableMgr:GetArtSettingData(tileGid)
    return TextMgr:GetText(artSettingData.name)
end

function SelectTile(mapX, mapY)
    if mapX ~= nil and  mapY ~= nil then
        _ui.mapMgr:SelectTile(mapX, mapY)
    end
end

function SelectCenterTile()
    SelectTile(GetCenterMapCoord())
end

function RequestMapData(lockScreen)
    WorldMapData.RequestData(currentPosIndex, lockScreen)
    WorldBorderData.RequestData(currentBorderIndex, lockScreen)
    PathListData.RequestData(currentPosIndex, lockScreen)
end

local function UpdatePath()
    _ui.mapMgr:ClearLine()
    charId = MainData.GetCharId()
    selfGuildId = UnionInfoData.GetGuildId()
    _ui.pathNamePool:Reset()
    local pathListData = PathListData.GetData()
    if pathListData ~= nil then
        for _, vv in ipairs(pathListData) do
            if vv.status == Common_pb.PathMoveStatus_Go or vv.status == Common_pb.PathMoveStatus_Back then
                --只绘制超时不超过1秒的路线
                if vv.starttime + vv.time + 1 > GameTime.GetSecTime() then
                    local color
                    if vv.charid == charId then
                        color = "green"
                    else
                        local guildMsg = vv.ownerguild
                        if selfGuildId ~= 0 and selfGuildId == guildMsg.guildid then
                            color = "blue"
                        else
                            color = "red"
                        end
                    end
                    if vv.charid == charId then
                        color = Color.green
                    else
                        local guildMsg = vv.ownerguild
                        if selfGuildId ~= 0 and selfGuildId == guildMsg.guildid then
                            color = Color.blue
                        else
                            color = Color.red
                        end
                    end
                    local pathStatus = vv.status                        
                    local sourcePos
                    local targetPos
                    if pathStatus == Common_pb.PathMoveStatus_Go then
                        sourcePos = vv.sourcePos
                        targetPos = vv.targetPos
                    elseif pathStatus == Common_pb.PathMoveStatus_Back then
                        sourcePos = vv.targetPos
                        targetPos = vv.sourcePos
                    end
                    local guildMsg = vv.ownerguild
                    local playerName
                    if guildMsg.guildid == 0 then
                        playerName = vv.charname
                    else
                        playerName = string.format("[%s]%s", guildMsg.guildbanner, vv.charname)
                    end
                    local pathType = vv.pathType
                    local pathName, createNew = _ui.pathNamePool:Accquire()
                    local nameTransform = pathName.transform
                    if createNew then
                        nameTransform:SetParent(_ui.pathBgTransform, false)
                        pathName.nameLabel = nameTransform:Find("name"):GetComponent("UILabel")
                    end
                    pathName.nameLabel.text = playerName
                    _ui.mapMgr:AddLine(vv.pathId, sourcePos.x, sourcePos.y, targetPos.x, targetPos.y, color, vv.pathType, vv.status, vv.starttime, vv.time, pathName.transform,
                    function()
                        if (pathType == Common_pb.TeamMoveType_AttackMonster
                            or pathType == Common_pb.TeamMoveType_GatherCall
                            or pathType == Common_pb.TeamMoveType_AttackPlayer)
                            and pathStatus == 1 and _ui.tempEffectList[vv.pathId] == nil then
                            local tileMsg = WorldMapData.GetTileDataByPos(targetPos)
                            if tileMsg == nil then
                                return
                            end
                            if pathType == Common_pb.TeamMoveType_AttackPlayer
                                or pathType == Common_pb.TeamMoveType_GatherCall
                                or pathType == Common_pb.TeamMoveType_GatherRespond then
                                if tileMsg.home.hasShield then
                                    return
                                end
                            end
                            if pathType == Common_pb.TeamMoveType_AttackMonster then
                                _ui.mapMgr:PlayEffect(targetPos.x,targetPos.y,0,5)
                            else
                                _ui.mapMgr:PlayEffect(targetPos.x,targetPos.y,0,5)
                            end
                        end
                    end)
                end
            end 
        end        
    end
    _ui.mapMgr:DrawLine()
    _ui.pathNamePool:Release()
end

local function UpdateCenterInfo(centerMapX, centerMapY)
    _ui.centerInfo.coordLabel.text = String.Format(TextMgr:GetText(Text.ui_worldmap_77), 1, centerMapX, centerMapY)
    local baseCoord = MapInfoData.GetData().mypos

    local baseDistance = GetDistance(centerMapX, centerMapY, baseCoord.x, baseCoord.y) * 0.001
    _ui.centerInfo.distanceLabel.text = string.format("%d km", baseDistance)

    if baseDistance > 2 then
        _ui.centerInfo.arrowTransform.localScale = ShowActive

        local baseDiffPosX = baseCoord.x - centerMapX
        local baseDiffPosY = baseCoord.y - centerMapY

        local angle = math.deg(math.atan2(baseDiffPosY, baseDiffPosX))
        _ui.centerInfo.arrowTransform.localEulerAngles = Vector3(0, 0, angle + _ui.mapMgr:CameraRotationY())
    else
        _ui.centerInfo.arrowTransform.localScale = HideActive
    end
end

local function UpdatePosIndex()
    local centerMapX, centerMapY = GetCenterMapCoord()
    local posIndex = MapCoordToPosIndex(centerMapX, centerMapY)

    if currentPosIndex ~= posIndex then
        currentPosIndex = posIndex
        currentBorderIndex = MapCoordToBorderIndex(centerMapX, centerMapY)
        RequestMapData(false)
    end
end

local function SetTileInfo(tile, mapX, mapY, tileMsg, tileData)
    local guildMsg = tileMsg.ownerguild
    local entryType = tileMsg.data.entryType
    if entryType == Common_pb.SceneEntryType_Home 
        or entryType >= Common_pb.SceneEntryType_ResFood 
        and entryType <= Common_pb.SceneEntryType_ResElec then
        local info, createNew = _ui.poolList.playerInfo:Accquire()
        local infoTransform = info.transform
        if createNew then
            infoTransform:SetParent(_ui.infoBgTransform, false)
            info.nameLabel = infoTransform:Find("bg_name/name"):GetComponent("UILabel")
            info.levelLabel = infoTransform:Find("bg_level/name"):GetComponent("UILabel")
        end
        if isEditor then
            infoTransform.name = string.format("playerInfo(%3d,%3d)", mapX, mapY)
        end
        _ui.mapMgr:OverlayPosition(infoTransform, mapX, mapY)
        local nameLabel = info.nameLabel
        local levelLabel = info.levelLabel

        --设置基地信息
        if entryType == Common_pb.SceneEntryType_Home then
            if guildMsg.guildid == 0 then
                nameLabel.text = tileMsg.home.name
            else
                nameLabel.text = string.format("[%s]%s", guildMsg.guildbanner, tileMsg.home.name)
            end
            --自己基地
            if tileMsg.home.charid == charId then
                nameLabel.color = NGUIMath.HexToColor(0xffffffff)
            else
                --盟友基地
                if selfGuildId ~= 0 and selfGuildId == guildMsg.guildid then
                    nameLabel.color = NGUIMath.HexToColor(0x93cce6ff)
                    --敌人基地
                else
                    nameLabel.color = NGUIMath.HexToColor(0xff0000ff)
                end
            end
            levelLabel.text = tileMsg.home.homelvl
        else
            nameLabel.text = ""
            levelLabel.text = tileMsg.res.level 
        end

        --设置资源信息
        if entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
            local resMsg = tileMsg.res
            local owner = resMsg.owner
            if owner ~= 0 then
                local info, createNew = _ui.poolList.resourceInfo:Accquire()
                local infoTransform = info.transform
                if createNew then
                    infoTransform:SetParent(_ui.infoBgTransform, false)
                    info.bubbleSprite = infoTransform:Find("bg"):GetComponent("UISprite")
                end
                if isEditor then
                    infoTransform.name = string.format("resourceInfo(%3d,%3d)", mapX, mapY)
                end
                local bubbleSprite = info.bubbleSprite
                if owner == charId then
                    bubbleSprite.spriteName = "bg_bubble_green"
                else
                    if selfGuildId ~= 0 and selfGuildId == guildMsg.guildid then
                        bubbleSprite.spriteName = "bg_bubble_yellow"
                    else
                        bubbleSprite.spriteName = "bg_bubble_red"
                    end
                end
                _ui.mapMgr:OverlayPosition(infoTransform, mapX, mapY)   
            end
        end
        --设置野怪信息
    elseif entryType == Common_pb.SceneEntryType_Monster or entryType == Common_pb.SceneEntryType_ActMonster or entryType == Common_pb.SceneEntryType_WorldMonster then
        local pos = tileMsg.data.pos
        if mapX == pos.x and mapY == pos.y then
            local info, createNew = _ui.poolList.monsterInfo:Accquire()
            local infoTransform = info.transform
            if createNew then
                infoTransform:SetParent(_ui.monsterBgTransform, false)
                info.levelLabel = infoTransform:Find("level"):GetComponent("UILabel")
                info.hpSlider = infoTransform:Find("UnitHudRed/hud frame/hp slider"):GetComponent("UISlider")
                info.icon = infoTransform:Find("bg_icon/icon"):GetComponent("UISprite")
            end
            if isEditor then
                infoTransform.name = string.format("monsterInfo(%3d,%3d)", mapX, mapY)
            end
            _ui.mapMgr:OverlayPosition(infoTransform, mapX, mapY)        
            local levelLabel = info.levelLabel
            local hpSlider = info.hpSlider
            local icon = info.icon
            local monsterMsg = tileMsg.monster
            levelLabel.text = String.Format(TextMgr:GetText(Text.Level_ui), monsterMsg.level)
            hpSlider.value = (monsterMsg.numMax - monsterMsg.numDead) / monsterMsg.numMax

            icon.spriteName = "icon_unprotect"

            if IsPveMonster(tileMsg) then
                local hasAttack = PveMonsterData.HasAttackPveMonster(tileMsg.data.uid)
                levelLabel.text = TextMgr:GetText(tileData.name)

                icon.spriteName = "icon_pvpmonster"

                if hasAttack then
                    local info, createNew = _ui.poolList.pveMonsterDone:Accquire()
                    local infoTransform = info.transform
                    if createNew then
                        infoTransform:SetParent(_ui.infoBgTransform, false)
                    end
                    _ui.mapMgr:OverlayPosition(infoTransform, mapX, mapY)             
                end
            end
        end
    elseif entryType == Common_pb.SceneEntryType_GuildBuild then
        local pos = tileMsg.data.pos
        if mapX == pos.x and mapY == pos.y then
            local buildingMsg = tileMsg.guildbuild
            local info, createNew = _ui.poolList.unionBuilding:Accquire()
            local infoTransform = info.transform
            if createNew then
                infoTransform:SetParent(_ui.infoBgTransform, false)
                info.badgeTransform = infoTransform:Find("Container/icon bg")
                info.nameLabel = infoTransform:Find("Container/name"):GetComponent("UILabel")
                info.badge = {}
                UnionBadge.LoadBadgeObject(info.badge, info.badgeTransform)
            end
            if isEditor then
                infoTransform.name = string.format("unionBuildingInfo(%3d,%3d)", mapX, mapY)
            end
            _ui.mapMgr:OverlayPosition(infoTransform, mapX, mapY)           
            local badgeTransform = info.badgeTransform
            local nameLabel = info.nameLabel
            UnionBadge.LoadBadgeById(info.badge, guildMsg.guildbadge)
            local buildingData = TableMgr:GetUnionBuildingData(buildingMsg.baseid)
            local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
            nameLabel.text = name
        end
    end
end

local function UpdateTileInfo()
    --[[
    for _, v in pairs(_ui.poolList) do
        v:Reset()
    end
    for x = _ui.mapMgr:ShowRectMinX(), _ui.mapMgr:ShowRectMaxX() do
        for y = _ui.mapMgr:ShowRectMinY(), _ui.mapMgr:ShowRectMaxY() do
                local mapX = x % mapSize
                local mapY = y % mapSize    
                local tileMsg = WorldMapData.GetTileDataByXY(mapX, mapY)
                if tileMsg ~= nil then
                    local tileData = GetTileData(tileMsg)
                    SetTileInfo(tile, mapX, mapY, tileMsg, tileData)
                end
            
                if showBorder and bgPressed then
                    local borderMsg = WorldBorderData.GetBorderDataByXY(mapX, mapY)
                    if borderMsg ~= nil and WorldMapData.GetTileDataByXY(mapX, mapY) == nil then
                        local unionName, createNew = _ui.poolList.unionName:Accquire()
                        local nameTransform = unionName.transform
                        if createNew then
                            nameTransform:SetParent(_ui.unionBgTransform, false)
                            unionName.nameLabel = nameTransform:Find("name"):GetComponent("UILabel")
                            unionName.nameLabel.text = borderMsg.guildbanner
                        end                    
                        _ui.mapMgr:OverlayPosition(nameTransform, mapX, mapY)
                    end
                end
            
        end
    end

    for _, v in pairs(_ui.poolList) do
        v:Release()
    end
    --]]
end

local function GetEffect(tileMsg)
    local entryType = tileMsg.data.entryType
    local monsterMsg = tileMsg.monster
    if entryType == Common_pb.SceneEntryType_Home then
        --设置护盾特效
        if tileMsg.home.hasShield then
            return "fangyuzhao2"
        end

        --被攻击后的受损状态
        if tileMsg.home.status > 0 and tileMsg.home.statusTime > Serclimax.GameTime.GetSecTime() then
            if tileMsg.home.status == 1 then
                return "bigmaplose"
            else
                return "bigmapwin"
            end

        end
    elseif entryType == Common_pb.SceneEntryType_Monster or entryType == Common_pb.SceneEntryType_ActMonster or entryType == Common_pb.SceneEntryType_WorldMonster then
        if IsGuildMonster(tileMsg) then
            if monsterMsg.guildMon.guildMonsterState == 2 then
                return "unionmonster_gate"
            end
        end
    end

    return nil
end

local function UpdateBuilding()
    _ui.mapMgr:ClearSprite()

    for x = _ui.mapMgr.StartX, _ui.mapMgr.EndX do
        for y = _ui.mapMgr.StartY, _ui.mapMgr.EndY do
            local mapX = x % mapSize
            local mapY = y % mapSize    
            local tileMsg = WorldMapData.GetTileDataByXY(mapX, mapY)

            local index = (mapSize - mapX - 1) * mapSize + mapY      
            local effect = 0    
            local gid = 0  
            if tileMsg ~= nil then
                local pos = tileMsg.data.pos
                local tileData = GetTileData(tileMsg)
                gid = GetTileGidByMsgData(mapX, mapY, tileMsg, tileData)                                
                local effectStr = GetEffect(tileMsg)   
                if effectStr == "fangyuzhao2" then
                    effect = effect + 1
                end
                if effectStr == "bigmapwin" then
                    effect = effect + 1 *10
                end    
                if effectStr == "bigmaplose" then
                    effect = effect + 1 *100
                end
                  if effectStr == "unionmonster_gate" then
                    effect = effect + 1 *1000
                end
                _ui.mapMgr:SetSprite(index, gid, effect)
            end            
        end
    end
    --print(_ui.mapMgr.StartX.."/".._ui.mapMgr.StartY.."/".._ui.mapMgr.EndX.."/".._ui.mapMgr.EndY)
    _ui.mapMgr:UpdateSprite()
    --_ui.mapMgr:UpdataTerritory(borderXList, borderYList, borderIndexList)

    UpdatePath()

    UpdateTileInfo()
    
end

local function UpdateBorder()

    _ui.mapMgr:ClearTerrain()
    for x = _ui.mapMgr.StartX, _ui.mapMgr.EndX do
        for y = _ui.mapMgr.StartY, _ui.mapMgr.EndY do
            local mapX = x % mapSize
            local mapY = y % mapSize    

            local index = (mapSize - mapX - 1) * mapSize + mapY
            local borderColorIndex = 0

            if showBorder then
                local borderMsg = WorldBorderData.GetBorderDataByXY(mapX, mapY)
                if borderMsg ~= nil then
                    borderColorIndex = UnionBadge.GetBadgeColorIndex(borderMsg.guildbadge)
                    _ui.mapMgr:SetTerrain(index,  borderColorIndex + bit.lshift(borderMsg.guildbadge, 8))
                end                
            end
        end
    end
    
    _ui.mapMgr:UpdateTerrain()

    UpdatePath()

    UpdateTileInfo()
    
end

function Update3DMap()
    -- UpdateBuilding()
    
    -- UpdateBorder()    
    --  _ui.mapMgr:GetData() 
end

local function UpdateActionListState()
	if _ui == nil then 
		return 
	end 
    for _, v in ipairs(_ui.actionList) do
        local actionMsg = v.msg
        local arriveTime = actionMsg.starttime + actionMsg.time
        v.slider.value = 1 - Global.GetLeftCooldownMillisecond(arriveTime) / (actionMsg.time * 1000)
        v.timeLabel.text = Global.GetLeftCooldownTextLong(arriveTime)
    end

    local scrollViewPos = _ui.actionScrollView.localPosition.y
    _ui.actionListUpArrow.gameObject:SetActive(#_ui.actionList > 4 and scrollViewPos > 33 * 0.25)
    _ui.actionListDownArrow.gameObject:SetActive(#_ui.actionList > 4 and scrollViewPos < (#_ui.actionList - 4.25) * 33)
end

local function UpdateActionList()
    ActionListData.Sort1()
    local actionListMsg = ActionListData.GetData()
    _ui.actionList = {}
    local actionIndex = 1
    for _, v in ipairs(actionListMsg) do
        local status = v.status
        local pathType = v.pathtype
        if status == Common_pb.PathMoveStatus_Go or status == Common_pb.PathMoveStatus_Back then
            local actionTransform = _ui.actionGrid:GetChild(actionIndex - 1)
            if actionTransform == nil then
                actionTransform = NGUITools.AddChild(_ui.actionGrid.gameObject, _ui.actionPrefab).transform
            end
            local action = {}
            action.msg = v
            action.transform = actionTransform
            action.icon = actionTransform:Find("bg_queue/icon"):GetComponent("UISprite")
            action.slider = actionTransform:Find("bg_queue/bar"):GetComponent("UISlider")
            action.timeLabel = actionTransform:Find("bg_queue/time"):GetComponent("UILabel") 
            action.accelerateButton = actionTransform:Find("bg_queue/btn_speedup"):GetComponent("UIButton")
            action.icon.spriteName = pathType == Common_pb.TeamMoveType_Prisoner and "icon_commanderflight" or "array_s_plane1"
            local canAccelerate = true
            --非路径不能加速
            if status ~= Common_pb.PathMoveStatus_Go and status ~= Common_pb.PathMoveStatus_Back then
                canAccelerate = false
                --集结大飞机不能加速
            elseif status == Common_pb.PathMoveStatus_Go and pathType == Common_pb.TeamMoveType_GatherCall then
                canAccelerate = false
                --指挥官回城不能加速
            elseif pathType == Common_pb.TeamMoveType_Prisoner then
                canAccelerate = false
				--联盟援助不能加速
			elseif pathType == 22 then
                canAccelerate = false
            end

            action.accelerateButton.gameObject:SetActive(canAccelerate)

            SetClickCallback(action.accelerateButton.gameObject, function()
                local statusIcon, statusText, targetName = ActionList.GetActionTargetInfoByMsg(v)
                local targetPos = v.tarpos
                local accelerateText = String.Format(TextMgr:GetText(Text.ui_worldmap_72), statusText, targetName, 1, targetPos.x, targetPos.y)
                MainCityUI.ShowMarchingAcceleration(v.uid, accelerateText)
            end)
            actionTransform.gameObject:SetActive(true)
            _ui.actionList[actionIndex] = action
            actionIndex = actionIndex + 1
        end
    end
    for i = actionIndex, _ui.actionGrid.transform.childCount do
        _ui.actionGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.actionGrid:Reposition()
    local actionCount = #actionListMsg
    local baseLevel = BuildingData.GetCommandCenterData().level
    local coreData = TableMgr:GetBuildCoreDataByLevel(baseLevel)
    AttributeBonus.CollectBonusInfo()
    local Bonus = AttributeBonus.GetBonusInfos()
    actionCountLabel.text = string.format("%d/%d", ActionListData.GetValidCount(), coreData.armyNumber + (Bonus[1088] ~= nil and Bonus[1088] or 0))
    _ui.actionListBg.gameObject:SetActive(actionCount > 0)
    _ui.actionListDetail.gameObject:SetActive(actionIndex > 1)
    _ui.actionListBackground.height = 16 + 32.85 * math.min(4, actionIndex - 1)
    _ui.actionListTips.gameObject:SetActive(false)
    _ui.actionScrollView:GetComponent("UIScrollView"):ResetPosition()
    _ui.actionScrollView:GetComponent("UIScrollView").enabled = actionIndex > 5
    UpdateActionListState()
end

function CheckPostion(x,y)
    local nx = x
    local ny = y
    if x < 0 then
        nx = 1
    end
    if x > 510 then
        nx = 510
    end
    if y < 0 then
        ny = 1
    end
    if y > 510 then
        ny = 510
    end    
    return nx,ny
end

function CheckCameraRange(dx,dy)
    if not previewEnabled then
        return true
    end
    local pos = _ui.worldCamera.transform.position
    pos.x  = pos.x +-1*dx + 64
    pos.z = pos.z +-1*dy+ 64
    local nx,ny = WorldPos2WLogicPos(pos)
    if (nx < 0 or nx > 510) or (ny <2 or ny > 510) then 
        return false
    end
    return true
end

function LateUpdate()
    UpdateActionListState()
    if _ui.mapBgTransform == nil then
        return
    end
    if followPathId ~= 0 then
        UpdateTileInfo()
        local centerMapX, centerMapY = GetCenterMapCoord()
        UpdateCenterInfo(centerMapX, centerMapY)
    end

    if keepMove then
        if negativeX then
            deltaX = deltaX - deltaX * smoothness;
            if deltaX <= 0 then
                keepMove = false
                return
            end
        else
            deltaX = deltaX - deltaX * smoothness;     
            if deltaX >= 0 then
                keepMove = false
                return
            end       
        end
        if negativeY then
            deltaY = deltaY - deltaY * smoothness;  
            if deltaY <= 0 then
                keepMove = false
                return
            end
        else
            deltaY = deltaY - deltaY * smoothness;  
            if deltaY >= 0 then
                keepMove = false
                return
            end     
        end
        if not CheckCameraRange(deltaX,deltaY) then
            keepMove = false
            deltaX = 0
            deltaY = 0  
            return          
        end        
        _ui.mapMgr:CameraMove(deltaX, deltaY)
        
    end
end

function Hide()
    Global.CloseUI(_M)
end

local RebelSurroundCallback = nil
function SetRebelSurroundCallback(callback)
    RebelSurroundCallback = callback
end

local MapBgDragStartCallback = function(go)
    if _ui.mapBgTransform == nil then
        return
    end
    keepMove = false
    if RebelSurroundCallback ~= nil then
        RebelSurroundCallback()
        RebelSurroundCallback = nil
    end
end

MapBgDragCallback = function(go, delta)
    if _ui.mapBgTransform == nil then
        return
    end
    if not CheckCameraRange(delta.x, delta.y) then
        deltaX = 0
        deltaY = 0  
        return          
    end
    _ui.mapMgr:CameraMove(delta.x, delta.y)
    UpdateTileInfo()
    delta = delta * uiRoot.pixelSizeAdjustment
    FollowPath(0)

    deltaX = delta.x
    deltaY = delta.y
end

local MapBgDragEndCallback = function(go)
    if _ui.mapBgTransform == nil then
        return
    end    
    if deltaX == 0 and deltaY == 0 then
        return
    end
    if deltaX >= 0 then
        negativeX = true
    else
        negativeX = false;
    end

    if deltaY >= 0 then
        negativeY = true
    else
        negativeY = false;
    end

    keepMove = true
end

function GetBuildTrf(mapX,mapY)
    if _ui == nil then
        return
    end
    local tileMsg
    local tileMsgBytes = _ui.mapMgr:TileInfo(mapX % mapSize, mapY % mapSize)
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then
        return
    end
    local buildtrf = _ui.mapMgr:GetCacheBuildTrf(tileMsg.data.pos.x% mapSize,tileMsg.data.pos.y% mapSize,0,0)   
    if buildtrf == nil then
       local  entryType = tileMsg.data.entryType
       if entryType == Common_pb.SceneEntryType_Turret then
            local tileData = TableMgr:GetMapBuildingDataByID(Common_pb.SceneEntryType_Turret*100+tileMsg.centerBuild.turret.subType)
            local ShapeData = TableMgr:GetObjectShapeData(tileData.size)
            buildtrf = _ui.mapMgr:GetCacheBuildTrf(tileMsg.data.pos.x% mapSize,tileMsg.data.pos.y% mapSize,ShapeData.xMax ,ShapeData.yMax)   
            --if buildtrf ~= nil then
            --    _ui.mapMgr:PlayEffect(tileMsg.data.pos.x, tileMsg.data.pos.y, 2, 5)
            --end
            return buildtrf,tileMsg
        elseif entryType == Common_pb.SceneEntryType_Govt then
            local tileData = TableMgr:GetMapBuildingDataByID(Common_pb.SceneEntryType_Govt)
            local ShapeData = TableMgr:GetObjectShapeData(tileData.size)
            buildtrf = _ui.mapMgr:GetCacheBuildTrf(tileMsg.data.pos.x% mapSize,tileMsg.data.pos.y% mapSize,ShapeData.xMax,ShapeData.yMax )---  ShapeData.xMin -1 ,ShapeData.yMax - ShapeData.yMin-1 )     
            --if buildtrf ~= nil then
            --    _ui.mapMgr:PlayEffect(tileMsg.data.pos.x, tileMsg.data.pos.y, 2, 5)
            --end      
            return buildtrf,tileMsg             
        end
        
    else
        return buildtrf,tileMsg 
    end
end

function ShowTileInfo(mapX, mapY)
    local tileMsg
    local tileData
    local gid = 0

    SelectTile(mapX, mapY)
    -- tileMsg = _ui.mapMgr:ShowTileInfo(mapX % mapSize, mapY % mapSize)
    -- tileMsg = WorldMapData.GetTileDataByXY(mapX % mapSize, mapY % mapSize)  
    if not _ui.mapMgr:VaildTilePos(mapX % mapSize, mapY % mapSize) then
        return
    end
    local tileMsgBytes = _ui.mapMgr:TileInfo(mapX % mapSize, mapY % mapSize)

    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    
    if tileMsg ~= nil then
        if tileMsg.data.entryType == Common_pb.SceneEntryType_Stronghold then
            if not tileMsg.centerBuild.stronghold.available then
                return
            end
        end

        if tileMsg.data.entryType == Common_pb.SceneEntryType_Fortress then
            if not tileMsg.centerBuild.fortress.available then
                return
            end
        end    
        if tileMsg.data.entryType == Common_pb.SceneEntryType_WorldCity then    
            if Global.ForceUpdateVersion("ui_update_hint4") then
                return
            end
        end
    end
    

    if tileMsg ~= nil then
        tileData = GetTileData(tileMsg)
        gid = GetTileGidByMsgData(mapX, mapY, tileMsg, tileData)
        if gid ~= nil and gid > 1000 then
            gid = gid % 1000
        end
        GetBuildTrf(mapX , mapY )
		
        if tileMsg.data.entryType == Common_pb.SceneEntryType_EliteMonster and mapX >= 0 and mapX < mapSize and mapY >= 0 and mapY < mapSize then
			TileInfo.SetTileMsg(tileMsg)
			EliteRebel.Show(tileMsg, gid, tileData)
            return
        end
    else
        gid = GetTileGidByMapCoord(mapX, mapY)
    end

    local fortSubType = IsInFortRect(mapX, mapY)
    if fortSubType ~= 0 then
        FortInfo.Show(fortSubType,mapX,mapY,tileMsg)
        return
    end
    -- 为政府临时加入的表现
    -- print("SSSSSSSSSSSSSSSSSSSSSSSS ",mapX,mapY);
    --if ShowGovernmentTest(mapX,mapY) then 
    --    return
    --end
    if TESTGOV then
        if IsInGovernmentArea(mapX, mapY) then
            ShowGovernmentTest(mapX,mapY)
            return
        end
    end
    

    -- print(string.format("map coord:X:%d, Y:%d uid:%d gid:%d", mapX, mapY, tileMsg ~= nil and tileMsg.data.uid or 0, gid),tileMsg,gid == 0 or tileMsg ~= nil,
    -- mapX >= 0,mapX < mapSize,mapY >= 0,mapY < mapSize)
    local validGid = false
    validGid = gid == 0 or tileMsg ~= nil
    if validGid and mapX >= 0 and mapX < mapSize and mapY >= 0 and mapY < mapSize then
        --if not IsInGovernmentArea(mapX, mapY) then
            if IsGuildMonster(tileMsg) then
                UnionRadarData.GetDataWithCallBack(function(radarData)

                    MapHelp.Open(gid, true, function() TileInfo.Show(tileMsg, tileData, gid, mapX, mapY) end, true)
                end)
            else
                MapHelp.Open(gid, true, function() TileInfo.Show(tileMsg, tileData, gid, mapX, mapY) end, true)
            end 
        --end
    end
end

function ShowCenterInfo()
    ShowTileInfo(GetCenterMapCoord())
end

local function MapBgClickCallback(go)
    if _ui.mapBgTransform == nil then
        return
    end    
    local touchPos = UICamera.currentTouch.pos
    local btyes =  _ui.mapMgr:MapBgClick(touchPos)
    if #btyes > 0 then
        local pathInfo = MapData_pb.SEntryPathInfo()
        pathInfo:ParseFromString(btyes)
        PathInfo.Show(pathInfo)
    else
        local curPos = _ui.mapMgr.curPos
        local mapX, mapY = math.floor(curPos.x), math.floor(curPos.y)
        if tutorialMapX ~= nil and tutorialMapY ~= nil then
            ShowTileInfo(tutorialMapX, tutorialMapY)
        else
            ShowTileInfo(mapX, mapY)
        end
        tutorialMapX = nil
        tutorialMapY = nil
    end
end

local function SetLookAtCoord(mapX, mapY)
    FollowPath(0)
    _ui.mapMgr:GoPos(mapX, mapY)
end

function LookAt(mapX, mapY)
    SetLookAtCoord(mapX, mapY)
    -- Update3DMap()
end

function TutorialTile(mapX, mapY)
    tutorialMapX = mapX
    tutorialMapY = mapY
    LookAt(mapX, mapY)
end

function FollowPath(pathId)
	if _ui ~= nil and _ui.mapMgr ~= nil then
		_ui.mapMgr:FollowAircraft(pathId)
		followPathId = pathId
	end
end

function SetShowBorder(value)
    showBorder = value
    if _ui ~= nil then
        _ui.borderOpenButton.gameObject:SetActive(showBorder)
        _ui.borderCloseButton.gameObject:SetActive(not showBorder)
        if showBorder then
            _ui.mapMgr:TerritoryShow()
        else
            _ui.mapMgr:TerritoryHide()
        end
    end
end

function IsShowBorder()
    return showBorder
end

local function MapMoveEvent()
    -- UpdatePosIndex()
    -- Update3DMap()   
    -- _ui.WorldMapMgr:GetData() 
end

local function MapCenterMoveEvent()
    local centerMapX, centerMapY = GetCenterMapCoord()
    UpdateCenterInfo(centerMapX, centerMapY)
    -- UpdatePosIndex(centerMapX, centerMapY)
end

local function InitMap()
    _ui.mapBgTransform = transform:Find("Container/map_bg")
    _ui.mapPanel = _ui.mapBgTransform:GetComponent("UIPanel")
    _ui.unionBgTransform = transform:Find("Container/union_bg")
    _ui.monsterBgTransform = transform:Find("Container/monster_bg")
    _ui.infoBgTransform = transform:Find("Container/info_bg")
    _ui.pathBgTransform = transform:Find("Container/path_bg")

    UIUtil.SetDragStartCallback(_ui.mapBgTransform.gameObject, MapBgDragStartCallback)
    UIUtil.SetDragCallback(_ui.mapBgTransform.gameObject, MapBgDragCallback)
    UIUtil.SetDragEndCallback(_ui.mapBgTransform.gameObject, MapBgDragEndCallback)

    UIUtil.SetClickCallback(_ui.mapBgTransform.gameObject, MapBgClickCallback)
    UIUtil.SetPressCallback(_ui.mapBgTransform.gameObject, function(go, isPressed)
        bgPressed = isPressed
        if _ui == nil or _ui.mapMgr == nil then
            return
        end
        _ui.mapMgr:ShowTerritoryName(isPressed)
        -- UpdateTileInfo()
    end)
    screenOriginX = 0
    screenOriginY = 0
end

local function InitCenterInfo()
    _ui.centerInfo = {}
    _ui.centerInfo.transform = transform:Find("Container/bg_coordinate")
    _ui.centerInfo.baseButton = transform:Find("Container/bg_coordinate/btn_coord"):GetComponent("UIButton") 
    _ui.centerInfo.tweenScale = _ui.centerInfo.baseButton.transform:GetComponent("TweenScale")
    _ui.centerInfo.arrowTransform = transform:Find("Container/bg_coordinate/change/bg_arrow")
    _ui.centerInfo.distanceLabel = transform:Find("Container/bg_coordinate/btn_coord/distance"):GetComponent("UILabel")
    _ui.centerInfo.coordLabel = transform:Find("Container/bg_coordinate/change/text_coord"):GetComponent("UILabel")
    _ui.centerInfo.locateButton = transform:Find("Container/bg_coordinate/btn_info"):GetComponent("UIButton")
    _ui.centerInfo.tweenScale.enabled = UnityEngine.PlayerPrefs.GetInt("MapHelp"..1600) == 0 and FunctionListData.IsFunctionUnlocked(123)
    _ui.searchButton = transform:Find("Container/bg_coordinate/search btn"):GetComponent("UIButton")
    SetClickCallback(_ui.centerInfo.baseButton.gameObject, function()
        MapHelp.Open(1600, false, function()
            local basePos = MapInfoData.GetData().mypos
            LookAt(basePos.x, basePos.y)
            SelectTile(basePos.x, basePos.y)
            _ui.centerInfo.tweenScale.enabled = false
        end,
    true)
    end)
    SetClickCallback(_ui.centerInfo.locateButton.gameObject, function()
        CoordInput.Show(function(mapX, mapY)
            LookAt(mapX, mapY)
            SelectTile(mapX, mapY)
        end)
    end)
    SetClickCallback(_ui.searchButton.gameObject, function()
        MapSearch.Show()
    end)
end

local function InitPreview()
    _ui.Container = transform:Find("Container")
    _ui.PreviewContainer = transform:Find("preview_container")
    _ui.PreviewBg = transform:Find("preview_container/preview_bg")
    _ui.PreviewCannel =transform:Find("preview_container/Union_Building/Container/btn_1")
    _ui.PreviewOK =transform:Find("preview_container/Union_Building/Container/btn_2"):GetComponent("UISprite") 
    UIUtil.SetDragCallback(_ui.PreviewBg.gameObject, function(go, delta) 
        local preview = _ui.mapMgr:GetUnionBuildPreview()
        if preview ~= nil then
            _ui.PreviewOK.spriteName = preview:CanBuild() and "btn_1" or "btn_4"
        end
        MapBgDragCallback(go, delta) 
    end)
    SetClickCallback(_ui.PreviewCannel.gameObject, function()
        ActivePreview(false)
    end)
    SetClickCallback(_ui.PreviewOK.gameObject, function()
        if _ui.PreviewOK.spriteName ~= "btn_1" then
            return
        end
        if pbuilddata == nil then
            ActivePreview(false)
            return
        end
        local preview = _ui.mapMgr:GetUnionBuildPreview()
        if preview == nil then
            ActivePreview(false)
            return
        end
        local mapX = preview:CurSelectPosX()
        local mapY = preview:CurSelectPosY()

        local move = UnionBuildingData.HasBuilding(pbuilddata.id)
        local shapeId = pbuilddata.size
        local buildingOffset = WorldMapData.GetBuildingOffset(shapeId)
        local req = MapMsg_pb.MsgCreateGuildBuildingRequest()
        if mapX == nil then
            Global.ShowError(ReturnCode_pb.Code_SceneMap_GuildBuildPosIllegal)
            return
        end

        req.buildId = pbuilddata.id
        req.pos.x = mapX
        req.pos.y = mapY

        Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgCreateGuildBuildingRequest, req, MapMsg_pb.MsgCreateGuildBuildingResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                UnionInfoData.RequestData()
                UnionBuildingData.RequestData()
                MainCityUI.UpdateRewardData(msg.fresh)
                MainCityUI.ShowWorldMap(x, y, false, nil)
                if move then
                    FloatText.Show(TextMgr:GetText(Text.union_build9))
                end
            else
                Global.ShowError(msg.code)
            end
        end, false)
        ActivePreview(false)
    end)
    ActivePreview(false)
end

function Awake()
    _ui = {}
    
    _ui.mapMgr = WorldMapMgr.Instance
    _ui.mapMgr.isFirst = true
    _ui.mapMgr:SetSelfInfo(MainData.GetCharId(), UnionInfoData.GetGuildId())
    _ui.worldCamera = _ui.mapMgr.transform:Find("WorldCamera/Main Camera"):GetComponent("Camera")
    _ui.uiCamera = NGUITools.FindCameraForLayer(gameObject.layer)
    if WorldMapBarrackPicture == nil then
        WorldMapBarrackPicture = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.WorldMapBarrackPicture).value)
    end

    uiRoot = GUIMgr.UIRoot:GetComponent("UIRoot")

    _ui.poolList = {}
    for k, v in pairs(poolConfigList) do
        local prefab = ResourceLibrary.GetUIPrefab("WorldMap/".. v[1])
        if  k == "pathName" then
            _ui.pathNamePool = MapPool(prefab, v[2])
        else
            _ui.poolList[k] = MapPool(prefab, v[2])
        end
    end
    _ui.tempEffectList = {}
    bgPressed = false

    if _ui.actionPrefab == nil then
        _ui.actionPrefab = ResourceLibrary.GetUIPrefab("WorldMap/marchinfo")
    end

    _ui.actionListBg = transform:Find("Container/bg_march")
    actionCountLabel = transform:Find("Container/bg_march/btn_march/text"):GetComponent("UILabel")
    actionButton = transform:Find("Container/bg_march/btn_march"):GetComponent("UIButton")
    _ui.actionListDetail = transform:Find("Container/bg_march/detail")
    _ui.actionListBackground = transform:Find("Container/bg_march/detail/background"):GetComponent("UISprite")
    _ui.actionListUpArrow = transform:Find("Container/bg_march/detail/jiantou_up")
    _ui.actionListDownArrow = transform:Find("Container/bg_march/detail/jiantou_down")
    _ui.actionListTips = transform:Find("Container/bg_march/bg_tips")
    _ui.actionScrollView = transform:Find("Container/bg_march/detail/Scroll View")
    _ui.actionGrid = transform:Find("Container/bg_march/detail/Scroll View/Grid"):GetComponent("UIGrid")
    SetClickCallback(actionButton.gameObject, function()
        ActionList.Show()
    end)

    local previewButton = transform:Find("Container/btn_bigmap"):GetComponent("UIButton")
    SetClickCallback(previewButton.gameObject, function()
        MapHelp.Open(700, false, function()
            MapPreviewData.RequestData(function()
                local centerMapX, centerMapY = GetCenterMapCoord()
                WarZoneMap.Show(math.floor(centerMapX / 8), math.floor(centerMapY / 8))
            end)
        end)        
    end)
    _ui.borderOpenButton = transform:Find("Container/btn_lingtu_open"):GetComponent("UIButton")
    SetClickCallback(_ui.borderOpenButton.gameObject, function()
        SetShowBorder(false)
    end)

    _ui.borderCloseButton = transform:Find("Container/btn_lingtu_close"):GetComponent("UIButton")
    SetClickCallback(_ui.borderCloseButton.gameObject, function()
        SetShowBorder(true)
    end)

    local backButton = transform:Find("Container/btn_back"):GetComponent("UIButton")
    SetClickCallback(backButton.gameObject, function()
        MainCityUI.HideWorldMap(true , MainCityUI.WorldMapCloseCallback, true)
    end)

    local tragetButton = transform:Find("Container/btn_traget"):GetComponent("UIButton")
    SetClickCallback(tragetButton.gameObject, function()
        Traget_View.Show()
    end)

    InitMap()
    --为了大地图热更
    --mapNet = WorldMapNet(_ui.mapMgr)

    InitCenterInfo()

    InitPreview()

    InitGovernmentTest()

    InitFortTest()

    WorldMapData.AddListener(UpdateBuilding)
    WorldBorderData.AddListener(UpdateBorder)
    PathListData.AddListener(UpdatePath)
    ActionListData.AddListener(UpdateActionList)
    oldDumpCount = Global.GetDumpCount()
    Global.SetDumpCount(10)

    AddDelegate(_ui.mapMgr, "OnMoveEvent", MapMoveEvent)
    AddDelegate(_ui.mapMgr, "OnCenterMoveEvent", MapCenterMoveEvent)
    if mapNet ~= nil then
    AddDelegate(_ui.mapMgr, "onUpdateMapData", OnMapDataUpdate)
    AddDelegate(_ui.mapMgr, "onUpdatePathData", OnPathDataUpdate)    
    end
	
	if GameObject.Find("3DTerrain(Clone)/WorldCamera/HUD Camera") ~= nil then 
		_ui.hudCamera = GameObject.Find("3DTerrain(Clone)/WorldCamera/HUD Camera").transform:GetComponent("Camera")
	
		local mask = bit.lshift(1,LayerMask.NameToLayer("ui 3d layer"))
		mask = bit.bor(mask,bit.lshift(1,LayerMask.NameToLayer("ui layer")))
		_ui.hudCamera.cullingMask  = mask
	end 
	
	
end

function OnMapDataUpdate(bytes)
    if mapNet ~= nil then
    mapNet:OnMapDataUpdate(bytes)
    end
end

function OnPathDataUpdate(bytes)
    if mapNet ~= nil then
    mapNet:OnPathDataUpdate(bytes)
    end
end

function Close()
    _ui.mapBgTransform = nil  
    previewEnabled = false
    WorldMapData.RemoveListener(UpdateBuilding)
    WorldBorderData.RemoveListener(UpdateBorder)
    PathListData.RemoveListener(UpdatePath)
    ActionListData.RemoveListener(UpdateActionList)
    Global.SetDumpCount(oldDumpCount)
    RemoveDelegate(_ui.mapMgr, "OnMoveEvent", MapMoveEvent)
    RemoveDelegate(_ui.mapMgr, "OnCenterMoveEvent", MapCenterMoveEvent)
    if mapNet ~= nil then
    RemoveDelegate(_ui.mapMgr, "onUpdateMapData", OnMapDataUpdate)
    RemoveDelegate(_ui.mapMgr, "onUpdatePathData", OnPathDataUpdate)      
    end
    mapNet = nil
    
    MainCityUI.DestroyTerrain()
    _ui = nil
    TileInfo.Hide()
    rebel.CloseSelf()
    local req = MapMsg_pb.SceneMapCloseRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapCloseRequest, req, MapMsg_pb.SceneMapCloseResponse, function(msg)
    end, true)
end

local CreatePreviewBuildData = nil
CreatePreviewBuildData = function()
    --WorldMap.LookAt(mapX, mapY)
    CheckPreview()
    ActivePreview(true,_ui.preview_build_data)
    RemoveDelegate(_ui.mapMgr, "onUpdatePathData", CreatePreviewBuildData)
end

function Show(mapX, mapY,preview_build_data)
    Global.OpenUI(_M)
    currentPosIndex = -1
    FollowPath(0)
    SetShowBorder(showBorder)
    
    if mapX ~= nil and mapY ~= nil then
        SetLookAtCoord(mapX == 0 and 2 or mapX, mapY == 0 and 2 or mapY)
    else
        local basePos = MapInfoData.GetData().mypos
        SetLookAtCoord(basePos.x == nil and 0 or basePos.x , basePos.y == nil and 0 or basePos.y)
    end
    UpdateActionList()
    if preview_build_data ~= nil then
		_ui.preview_build_data = preview_build_data
		AddDelegate(_ui.mapMgr, "onUpdatePathData", CreatePreviewBuildData)        
    end
end

function IsOpened()
    return _ui ~= nil
end

ActivePreview = function(enable,preview_build_data)
    previewEnabled = enable
    pbuilddata = preview_build_data
    if enable then
        MainCityUI.gameObject:SetActive(false)
        _ui.Container.gameObject:SetActive(false)
        _ui.PreviewContainer.gameObject:SetActive(true)
        local preview = _ui.mapMgr:GetUnionBuildPreview()
        if preview ~= nil then
            preview:DisplayPreview(pbuilddata.id -1,UnionInfoData.GetGuildId())
            _ui.PreviewOK.spriteName = preview:CanBuild() and "btn_1" or "btn_4"
        end
    else
        MainCityUI.gameObject:SetActive(true)
        _ui.Container.gameObject:SetActive(true)
        _ui.PreviewContainer.gameObject:SetActive(false)
        local preview = _ui.mapMgr:GetUnionBuildPreview()
        if preview ~= nil then
            preview:Reset()
        end        
    end
end

CheckPreview = function()
    local centerMapX, centerMapY = GetCenterMapCoord()
    local nx,ny = CheckPostion(centerMapX,centerMapY)
    if nx ~= centerMapX or ny ~= centerMapY then
        LookAt(nx,ny)
    end
end

function OnTurretAttackPush(msg)
    local tposx = msg.turretPos.x
    local tposy = msg.turretPos.y
    local trf,tileMsg = WorldMap.GetBuildTrf(tposx,tposy)
    if trf ~= nil then
        effect = trf:Find("Bone001/Bone006/paotaigongji")
        if effect ~= nil then
            effect.gameObject:SetActive(false)
            effect.gameObject:SetActive(true)
        end
    end
    for i=1,#msg.pos do
        local trf1,tileMsg1 = WorldMap.GetBuildTrf(msg.pos[i].x,msg.pos[i].y)
        if trf1 ~= nil then
            local  entryType = tileMsg1.data.entryType
            if entryType == Common_pb.SceneEntryType_Govt then
                local tileData = TableMgr:GetMapBuildingDataByID(Common_pb.SceneEntryType_Govt)
                local ShapeData = TableMgr:GetObjectShapeData(tileData.size)
                buildtrf = _ui.mapMgr:GetCacheBuildTrf(tileMsg1.data.pos.x% mapSize,tileMsg1.data.pos.y% mapSize,ShapeData.xMax,ShapeData.yMax )   
                local mx = math.random (msg.pos[i].x+ShapeData.xMax, msg.pos[i].x+ShapeData.xMin)    
                local my = math.random (msg.pos[i].y+ShapeData.yMax, msg.pos[i].y+ShapeData.yMin)   
                local delay = math.random (10, 15)          
                _ui.mapMgr:PlayEffect(mx, my, 7, 50*100+delay)
            else
                local delay = math.random (10, 15)  
                _ui.mapMgr:PlayEffect(tileMsg1.data.pos.x, tileMsg1.data.pos.y, 6,50*100+delay)
            end
            
        end
    end
end

function DrawPath(id)
    -- local pathVersion = _ui.mapMgr:PathVersion()
    -- if pathVersion ~= _ui.pathVersion then
    --     _ui.pathVersion = pathVersion
    --     _ui.pathData = MapData_pb.SEntryPathInfo()
    --     _ui.pathData:ParseFromString(_ui.mapMgr:GetPathData())
    -- end
    -- local pathData
    -- for i,v in ipairs(_ui.pathData) do
    --     if v.pathId == id then
    --         pathData = v
    --     end
    -- end

     local id = 0
     local color = Color(0.5,0.5,0.5,1)
     local isEffect = true
     return id, color, isEffect 
end

function DrawPathEffect(type, status, x, y)
    -- _ui.mapMgr:PlayEffect(x, y, 4, 5)
end

local mapData

function GetMapData()
    return mapData
end

function DrawMap(id)
    Global.LogDebug(_M, "DrawMap", id)

    -- local mapVersion = _ui.mapMgr:MapVersion()
    -- if mapVersion ~= _ui.mapVersion then       
    --     _ui.mapVersion = mapVersion
    --     _ui.mapData = MapMsg_pb.PosISceneEntrysInfoResponse()
    --     _ui.mapData:ParseFromString(_ui.mapMgr:GetMapData())
    -- end

    -- local dataFound = false
    -- for i, v in ipairs(_ui.mapData.entry) do
    --     for i1,sEntryData in ipairs(v.entrys) do
    --         if sEntryData.data.uid == id then
    --             mapData = sEntryData
    --             dataFound = true
    --             break
    --         end
    --     end

    --     if dataFound then
    --         break
    --     end
    -- end

    -- if dataFound then
    --     local effect = 6
    --     local tileData = TableMgr:GetMonsterRuleData(mapData.monster.level)

    --     return effect, 0, 102
    -- end
end
