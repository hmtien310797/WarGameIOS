module("GuildWarMain", package.seeall)

local ServerBlockSize = 16;
local ServerBlockTotalCount = 22;

local ZOOM_SPEED = 0.01
local MIN_SCALE = 0.6
local MAX_SCALE = 1.0
local DEFAULT_SCALE = 0.6
local MAX_CLOUD_OFFSET = 4000 * 4000

local mapSize = 352
local updateMapTimer = 1
local warning = {}
local promptList
local topBar
local noticeList
local requestChat = false

MassTotlaNum = {
    [1] = 0,
    [2] = 0,
}

PreMassTotalNum = {
    [1] = 0,
    [2] = 0,
}

local moneyTypeList = 
{
    --[Common_pb.MoneyType_Diamond] = 
    --{resourceType = 0, path = "Container/TopBar/bg_gold", labelPath = "bg_msg/num", iconPath = "icon"},
    [Common_pb.MoneyType_Food] = 
    {resourceType = BuildMsg_pb.BuildType_Farmland, path = "Container/TopBar/bg_gold", labelPath = "bg_msg/num", iconPath = "icon"},
    [Common_pb.MoneyType_Iron] = 
    {resourceType = BuildMsg_pb.BuildType_Logging, path = "Container/resourebar/bg_resoure (2)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Oil] = 
    {resourceType = BuildMsg_pb.BuildType_OilField, path = "Container/resourebar/bg_resoure (3)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Elec] = 
    {resourceType = BuildMsg_pb.BuildType_IronOre, path = "Container/resourebar/bg_resoure (4)", labelPath = "num", iconPath = "icon"},
}

local moneyTypeListMain = 
{
    [Common_pb.MoneyType_Diamond] = 
    {resourceType = 0, path = "Container/TopBar/bg_gold", labelPath = "bg_msg/num", iconPath = "icon"},
    [Common_pb.MoneyType_Food] = 
    {resourceType = BuildMsg_pb.BuildType_Farmland, path = "Container/resourebar/bg_resoure (1)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Iron] = 
    {resourceType = BuildMsg_pb.BuildType_Logging, path = "Container/resourebar/bg_resoure (2)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Oil] = 
    {resourceType = BuildMsg_pb.BuildType_OilField, path = "Container/resourebar/bg_resoure (3)", labelPath = "num", iconPath = "icon"},
    [Common_pb.MoneyType_Elec] = 
    {resourceType = BuildMsg_pb.BuildType_IronOre, path = "Container/resourebar/bg_resoure (4)", labelPath = "num", iconPath = "icon"},
}


function HideHeadBar()
	topBar.gameObject:SetActive(false)
end

function ShowHeadBar()
	topBar.gameObject:SetActive(true)
end

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
local smoothness = 0.1
local keepMove = false
local negativeX = false
local negativeY = false

local resourceBar 
local ChatMenu
local chatPreviewOffset
function MobaMinPos()
    return 121,34
end

function MobaSize()
    return 63
end

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

local BattleEndState =
{
    time = 0,
    winteam = 0,
    loseteam = 0,
    State = 0,
    TDX = 0,
    TDY = 0,
    CCX = 0,
    CCY = 0,
    effect = false,
}
local BattleEndInfos={
    [1] = {pos = {x = 3+2,y= 56+2}},
    [2] = {pos = {x = 56+2,y= 3+2}}
}
local BattleEndCfg ={
    CameraMoveTime = 3,
    Speed = 10,
}

local function ClearBattleEndShow()
    BattleEndState.winteam = 0
    BattleEndState.State = 0
    BattleEndState.time = 0
    BattleEndState.TDX = 0
    BattleEndState.TDY = 0
    BattleEndState.CCX = 0
    BattleEndState.CCY = 0
    BattleEndState.effect = false
    BattleEndState.loseteam = 0
end

function ActiveBattleEndShow(winteam)
    if _ui == nil then
        Moba_winlose.Show()
        return 
    end
    BattleEndState.winteam = winteam
    if BattleEndState.winteam == 0 then
        return
    end
    BattleEndState.time = 0
    BattleEndState.State = 1
    BattleEndState.loseteam = 1
    if BattleEndState.winteam == 1 then
        BattleEndState.loseteam = 2
    end    
    if MobaMainData.GetTeamID() ~= BattleEndState.winteam then
        _ui.mapMgr.worldCamera:GetComponent("Animation"):Play("Gray")     
    end  
    transform:Find("Container").gameObject:SetActive(false)
    transform:Find("time").gameObject:SetActive(false)
    local colse_table_value = TableMgr:GetGlobalData(208)
    if colse_table_value ~= nil then
        local colse_table = string.split(colse_table_value.value, ",")
        for i=1,#colse_table do
            if GUIMgr:FindMenu(colse_table[i]) ~= nil then
                GUIMgr:CloseMenu(colse_table[i])
            end 
        end
    end
end

function ShowMobaBattleResult(msg)
    local win = 0
    for i, v in ipairs(msg.userlist.users) do
        if v.charid == MainData.GetCharId() then
            win = v.win
            break
        end
    end
    if win == 0 then
        Moba_winlose.Show()
    else     
        if win > 0 then
            ActiveBattleEndShow(MobaMainData.GetTeamID())
        else
            local winteam = 1
            if MobaMainData.GetTeamID() == 1 then
                winteam = 2
            end    
            ActiveBattleEndShow(winteam)
        end
    end
end

local function IsBattleEndShowTime()
    return BattleEndState.State ~= 0
end

local function easeInCirc( _start,  _end, _value)
    _end =_end - _start;
    return -_end * (Mathf.Sqrt(1 - _value * _value) - 1) + _start;
end

local function to3dPos(int_value)
    return int_value * 16 - 352*0.5 + 8
end

local function UpdateBattleEndEffect()
    if _ui == nil then
        return
    end
    if BattleEndState.State == 1 then
        local offsetx,offsety = MobaMinPos()
        if BattleEndState.time == 0 then
            BattleEndState.TDX = to3dPos(_ui.mapMgr.CenterX +offsetx)
            BattleEndState.TDY = to3dPos(_ui.mapMgr.CenterY +offsety)

            BattleEndState.CCX = to3dPos(BattleEndInfos[BattleEndState.loseteam].pos.x+offsetx)
            BattleEndState.CCY = to3dPos(BattleEndInfos[BattleEndState.loseteam].pos.y+offsety)
        end
        local f = BattleEndState.time/BattleEndCfg.CameraMoveTime
        BattleEndState.time =BattleEndState.time+ GameTime.deltaTime
        if f >=1 then
            f = 1
        end
        local tx = easeInCirc(BattleEndState.TDX,BattleEndState.CCX,f)
        local ty = easeInCirc(BattleEndState.TDY,BattleEndState.CCY,f)
        _ui.mapMgr.worldCamera.transform.position = Vector3(tx,_ui.mapMgr.worldCamera.transform.position.y,ty)
        if f == 1 then
            BattleEndState.State =2
            BattleEndState.time = 0
        end
        return true
    elseif BattleEndState.State == 2 then
        BattleEndState.time =BattleEndState.time+ GameTime.deltaTime
        if BattleEndState.time > 0.5 then
            if not BattleEndState.effect then
                local trf = _ui.mapMgr.transform:Find("MobaBaseEffect")
                trf.localPosition = Vector3(BattleEndState.CCX,0,BattleEndState.CCY)
                trf.gameObject:SetActive(true)
                BattleEndState.effect = true
            end
            if BattleEndState.time > 1.5 then
                Moba_winlose.Show()
                BattleEndState.State = 3
            end        
        end
        return true
    elseif BattleEndState.State == 3 then
        return true
    end
    return false
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
	print( tileMsg.data.entryType)
    local entryType = tileMsg.data.entryType
	
    if entryType == Common_pb.SceneEntryType_Home then
        if tileMsg.home.homelvl == 0 then
            tileMsg.home.homelvl = 1
        end
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
	elseif entryType == Common_pb.SceneEntryType_MobaGate then
		tileData = TableMgr:GetMobaMapBuildingDataByID(tileMsg.mobaBuild.buidingid)
	elseif entryType == Common_pb.SceneEntryType_MobaCenter then
        tileData = TableMgr:GetMobaMapBuildingDataByID(tileMsg.mobaBuild.buidingid)
	elseif entryType == Common_pb.SceneEntryType_MobaArsenal then
		tileData = TableMgr:GetMobaMapBuildingDataByID(tileMsg.mobaBuild.buidingid)
	elseif entryType == Common_pb.SceneEntryType_MobaFort then
		tileData = TableMgr:GetMobaMapBuildingDataByID(tileMsg.mobaBuild.buidingid)
	elseif entryType == Common_pb.SceneEntryType_MobaInstitute then
		tileData = TableMgr:GetMobaMapBuildingDataByID(tileMsg.mobaBuild.buidingid)
	elseif entryType == Common_pb.SceneEntryType_MobaTransPlat then
        tileData = TableMgr:GetMobaMapBuildingDataByID(tileMsg.mobaBuild.buidingid)  
	elseif entryType == Common_pb.SceneEntryType_MobaSmallBuild then
		tileData = TableMgr:GetGuildWarMapBuildingDataByID(tileMsg.mobaBuild.buidingid)  
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
    return WorldMap.GetDistance(mapX1, mapY1, mapX2, mapY2)
end

function GetDistanceToCenter(mapX, mapY)
    local centerMapX, centerMapY = GetCenterMapCoord()

    return GetDistance(centerMapX, centerMapY, mapX, mapY)
end

function GetDistanceToMyBase(mapX, mapY)
    local baseCoord = MobaMainData.GetData().pos
    local baseMapX, baseMapY = baseCoord.x, baseCoord.y    
    if _ui == nil then
        
        return GetDistance(baseMapX, baseMapY, mapX, mapY)
    end
    local tileMsg
    local offset_x,offset_y = MobaMinPos()
    local tileMsgBytes = _ui.mapMgr:TileInfo((mapX+offset_x) % GetServerMapSize(), (mapY+offset_y) % GetServerMapSize())
    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    if tileMsg == nil then 
        return GetDistance(baseMapX, baseMapY, mapX, mapY)
    end
    return GetDistance(baseMapX, baseMapY, tileMsg.data.pos.x-offset_x,tileMsg.data.pos.y-offset_y)
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
	
	if tileData.picture ==nil then 
		return 0
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
    if _ui ~= nil and mapX ~= nil and  mapY ~= nil then
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
    _ui.centerInfo.coordLabel.text = String.Format(TextMgr:GetText(Text.ui_moba_40), centerMapX, centerMapY)
    local baseCoord = {}
    baseCoord.x,baseCoord.y = MobaMinPos()
    if MobaMainData.GetData() ~= nil then
        baseCoord = MobaMainData.GetData().pos
    end

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
    elseif entryType == Common_pb.SceneEntryType_Monster or entryType == Common_pb.SceneEntryType_ActMonster then
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
    elseif entryType == Common_pb.SceneEntryType_Monster or entryType == Common_pb.SceneEntryType_ActMonster then
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
	if _ui.actionList == nil then 
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

local function UpdateMainData(isInWorldMap)
	if _ui == nil then
		return
	end
    local mainData = MainData.GetData()
	_ui.iconPlayer.mainTexture = ResourceLibrary:GetIcon("Icon/head/", mainData.face)
	GOV_Util.SetFaceUI(_ui.MilitaryRank,mainData.militaryRankId)
	
	_ui.headNoticeObject:SetActive(MainData.HasPendingRansom())
    local commanderInfo = MainData.GetCommanderInfo()
    local captured = commanderInfo.captived ~= 0
	_ui.prisonObject:SetActive(captured)
	if ConfigData.GetVipExperienceCard() then
		_ui.labelVip.text = MainData.GetVipLevel()
	else
		if MainData.GetVipValue().viplevelTaste <= MainData.GetVipLevel() then
			_ui.labelVip.text = MainData.GetVipLevel()
		else
			_ui.labelVip.text = MainData.GetVipValue().viplevelTaste
		end		
	end
	
	
	_ui.mainLevel.text = "LV." .. MainData.GetLevel()
	
	local fight = topBar:Find("bg_power/bg_msg/num"):GetComponent("UILabel")
	fight.text = mainData.pkvalue--"111111111"--MainData.GetFight()
	_ui.powervalue = mainData.pkvalue
	-- if level up
	local lastLv = MainData.GetSavedLevel()
	local curLv = MainData.GetLevel()
	--print("l:" .. lastLv .. "cur:" .. curLv)
	if curLv > lastLv then
        PlayerLevelup.SetLevelContent(curLv , lastLv)
		PlayerLevelup.Show()
	end
	
	if isInWorldMap or GUIMgr:IsMenuOpen("WorldMap") then
		_ui.iconEnergy.spriteName = "proactive"
		_ui.labelEnergy.text = string.format("%d/%d", MainData.GetSceneEnergy(), MainData.GetMaxSceneEnergy())
		SetClickCallback(_ui.iconEnergy.gameObject, function()
			_ui.EnergyTipRoot:SetActive(true)
		end)
	else
		_ui.iconEnergy.spriteName = "icon_physical"
		_ui.labelEnergy.text = string.format("%d/%d", MainData.GetEnergy(), MainData.GetMaxEnergy())
		SetClickCallback(_ui.iconEnergy.gameObject, function()
			_ui.EnergyTipRoot:SetActive(true)
		end)
	end
end


local function UpdateClientMainData()
	local mainData = MobaMainData.GetData()
	
	local v = _ui.moneyList[Common_pb.MoneyType_Iron]
	v.label.text = ""
	if mainData~= nil and mainData.data ~= nil then 
		v.label.text = mainData.data.score
	end 
	
--[[	v = _ui.moneyList[Common_pb.MoneyType_Food]
	v.label.text = MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond)

	
	
	local arms = MobaArmyListData.GetData()
	local count =0
	if arms ~= nil then
		for _, v in ipairs(arms) do
			count = count + v.num
		end
	end 
	
	--print("___________",count,MobaBarrackData.GetArmyNum(),MobaActionListData.GetActionArmyTotalNum())
	]]--
	local v = _ui.moneyList[Common_pb.MoneyType_Oil]
	v.label.text = GetTotalArmyNum()
	UpdateMainData(false)
	
end

function GetTotalArmyNum()
	--return --[[Barrack.GetArmyNum() +]] MobaActionListData.GetActionArmyTotalNum()
	return MobaBarrackData.GetArmyNum() + MobaActionListData.GetActionArmyTotalNum()
end

local function UpdateArmyList()
	-- print("UpdateArmyList  ")
	MobaTeamData.RequestData(function(msg)
		UpdateClientMainData()
    end)   
end 

local function UpdateActionList()
  --  print("UpdateActionList  ")
	MobaTeamData.RequestData(function(msg)
		UpdateClientMainData()
    end)    
	
	MobaActionListData.Sort1()
    local actionListMsg = MobaActionListData.GetData()
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
                canAccelerate = true
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
                MainCityUI.ShowMarchingAcceleration(v.uid, accelerateText,true)
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

    actionCountLabel.text = string.format("%d/%d", MobaActionListData.GetValidCount(), MobaActionListData.GetMaxCount())
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

function CheckMobaRange(dx,dy)
    if not Global.IsSlgMobaMode() then
        return true
    end
    local pos = _ui.worldCamera.transform.position
    pos.x  = pos.x +-1*dx + 64
    pos.z = pos.z +-1*dy+ 64
    local nx,ny = WorldPos2WLogicPos(pos)
    local offsetx,offsety = MobaMinPos()
    nx = nx - offsetx
    ny = ny - offsety

    if (nx < -1 or nx > 64) or (ny <-1 or ny > 64) then 
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

    if UpdateBattleEndEffect() then
        return
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
        if not CheckMobaRange(deltaX,deltaX) then
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
    if IsBattleEndShowTime() then
        return
    end
    if _ui.mapBgTransform == nil then
        return
    end
	
    if not CheckCameraRange(delta.x, delta.y) then
        deltaX = 0
        deltaY = 0  
        return          
    end
    if not CheckMobaRange(delta.x, delta.y) then
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

function IsTransPlatActive(mapX,mapY)

	print("IsTransPlatActive ",mapX,mapY)
	
	local tileMsg

    local min_pos_x,min_pos_y = MobaMinPos()
    if not (mapX >= min_pos_x and mapX <= min_pos_x +MobaSize()-1 and mapY >= min_pos_y and mapY <= min_pos_y +MobaSize()-1) then
        return false
    end

    if not _ui.mapMgr:VaildTilePos(mapX % mapSize, mapY % mapSize) then
        return false
    end
    local tileMsgBytes = _ui.mapMgr:TileInfo(mapX % mapSize, mapY % mapSize)

    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    
    if tileMsg ~= nil then
		if tileMsg.data.entryType == Common_pb.SceneEntryType_MobaTransPlat then
            if tileMsg.mobaBuild~=nil and  tileMsg.mobaBuild.rulingTeam == MobaMainData.GetTeamID() then
                return true
            end
        end
	end 

	return false
end 


--传送阵
function IsInActiveTransPlat(x,y)

	print("IsInActiveTransPlat ",x,y)
	local offsetx,offsety = MobaMinPos()
	x = x - offsetx
	y = y - offsety
	print("IsInActiveTransPlat1 ",x,y)
	local items = {7,8}
	
	for i=1,2 do 
		local buildingData = tableData_tMobaBuildingRule.data[items[i]]
		local zones = buildingData.EffectZone:split(",")
		print("______",items[i],buildingData.EffectZone)
		if (x>=tonumber(zones[1]) and x<=tonumber(zones[1])+tonumber(zones[3])) and (y>=tonumber(zones[2]) and y<=tonumber(zones[2])+tonumber(zones[4])) then
			if IsTransPlatActive(tonumber(buildingData.Xcoord)+offsetx,tonumber(buildingData.Ycoord)+offsety) then 
				return true
			end 
		end 
	end 

	return false
end 


function ShowTileInfo(mapX, mapY)
    local tileMsg
    local tileData
    local gid = 0

    SelectTile(mapX, mapY)
    -- tileMsg = _ui.mapMgr:ShowTileInfo(mapX % mapSize, mapY % mapSize)
    -- tileMsg = WorldMapData.GetTileDataByXY(mapX % mapSize, mapY % mapSize)  

    local min_pos_x,min_pos_y = MobaMinPos()
    if not (mapX >= min_pos_x and mapX <= min_pos_x +MobaSize()-1 and mapY >= min_pos_y and mapY <= min_pos_y +MobaSize()-1) then
        return
    end

    --if not _ui.mapMgr:VaildTilePos(mapX % mapSize, mapY % mapSize) then
    --    return
    --end

    local tileMsgBytes = _ui.mapMgr:TileInfo(mapX % mapSize, mapY % mapSize)

    if #tileMsgBytes > 0 then
        tileMsg = MapData_pb.SEntryData()
        tileMsg:ParseFromString(tileMsgBytes)
    end
    
    if tileMsg ~= nil then
		print(tileMsg.data.entryType)
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
    
    if tileMsg ~= nil then
        if tileMsg.mobaBuild ~= nil then
            if tileMsg.mobaBuild.broken then
                return
            end
        end
    end

    -- print(string.format("map coord:X:%d, Y:%d uid:%d gid:%d", mapX, mapY, tileMsg ~= nil and tileMsg.data.uid or 0, gid),tileMsg,gid == 0 or tileMsg ~= nil,
    -- mapX >= 0,mapX < mapSize,mapY >= 0,mapY < mapSize)
    local validGid = false
    validGid = gid == 0 or tileMsg ~= nil
    if validGid and mapX >= 0 and mapX < mapSize and mapY >= 0 and mapY < mapSize then
        --if not IsInGovernmentArea(mapX, mapY) then
            if IsGuildMonster(tileMsg) then
                MobaZoneBuildingData.GetDataWithCallBack(tileMsg.mobaBuild.buidingid,function(zoneData)
                    MapHelp.Open(gid, true, function() MobaTileInfo.Show(tileMsg, tileData, gid, mapX, mapY,zoneData) end, true)
                end,true)
            else
                if tileMsg ~= nil then
                    MobaZoneBuildingData.GetDataWithCallBack(tileMsg.mobaBuild.buidingid,function(zoneData)
                        MapHelp.Open(gid, true, function() MobaTileInfo.Show(tileMsg, tileData, gid, mapX, mapY,zoneData) end, true)
                    end,true)
                else
                    MapHelp.Open(gid, true, function() MobaTileInfo.Show(tileMsg, tileData, gid, mapX, mapY,zoneData) end, true)
                end
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
    if _ui then
	FollowPath(0)
    _ui.mapMgr:GoPos(mapX, mapY)
	end
end

function LookAt(mapX, mapY,use)
	if use then 
		local offsetx,offsety = MobaMinPos()
		mapX = mapX + offsetx
		mapY = mapY + offsety
	end 
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
--[[
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
	]]--
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
            local offset_x,offset_y= MobaMinPos()
            local base_pos = MobaMainData.GetData().pos
            local basePos = {}
            basePos.x = base_pos.x +offset_x
            basePos.y = base_pos.y +offset_y
            LookAt(basePos.x, basePos.y)
            SelectTile(basePos.x, basePos.y)
            _ui.centerInfo.tweenScale.enabled = false
        end,
    true)
    end)
    SetClickCallback(_ui.centerInfo.locateButton.gameObject, function()
        CoordInput.Show(function(mapX, mapY)
            local offsetx,offsety = MobaMinPos()
            mapX = mapX + offsetx
            mapY = mapY + offsety
            LookAt(mapX, mapY)
            SelectTile(mapX, mapY)
        end)
    end)
    SetClickCallback(_ui.searchButton.gameObject, function()
        MapSearch.Show()
    end)
	_ui.centerInfo.transform.gameObject:SetActive(true)
end

local function UpdateCountInfo(callback)
    local renameCount = CountListData.GetRenameCount()
    if renameCount.count == renameCount.countmax then
	    -- GUIMgr:CreateMenu("FirstChangeName",false)
		FirstChangeName.Show(callback)
	elseif callback then
		callback()
    end
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
	
	topBar = transform:Find("Container/TopBar")
	local iconPlayerBtn = transform:Find("Container/TopBar/bg_touxiang"):GetComponent("UIButton")
	
	SetClickCallback(iconPlayerBtn.gameObject, function(go)
	--GUIMgr:CreateMenu("BuildReview", false)
	   	UpdateCountInfo(function()
	   		GUIMgr:CreateMenu("MainInformation", false)
	   	end)
	   --[[local lead = 
	   {
		   name="sb" , 
		   entryBaseData=
		   { 
				pos=
				{
					x=100 , 
					y=100
				}	 
		   }
		}
		UnionGuide.Show(lead , true)]]
    end)

	_ui.power = transform:Find("Container/TopBar/bg_power").gameObject
	_ui.iconPlayer = transform:Find("Container/TopBar/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
	_ui.MilitaryRank = transform:Find("Container/TopBar/bg_touxiang/MilitaryRank")
	_ui.headNoticeObject = transform:Find("Container/TopBar/bg_touxiang/dian").gameObject
	_ui.mainLevel = transform:Find("Container/TopBar/bg_touxiang/level"):GetComponent("UILabel")
	_ui.prisonObject = transform:Find("Container/TopBar/bg_touxiang/inprison").gameObject
	_ui.labelEnergy = transform:Find("Container/TopBar/bg_tili/bg_msg/num"):GetComponent("UILabel")
	_ui.iconEnergy = transform:Find("Container/TopBar/bg_tili/icon"):GetComponent("UISprite")
	_ui.EnergyTipRoot = transform:Find("Container/TopBar/bg_tili/bg").gameObject
	_ui.EnergyTipLabel1 = transform:Find("Container/TopBar/bg_tili/bg/Label (1)"):GetComponent("UILabel")
	_ui.EnergyTipLabel2 = transform:Find("Container/TopBar/bg_tili/bg/Label"):GetComponent("UILabel")
	_ui.labelVip = transform:Find("Container/TopBar/bg_vip/bg_msg/num"):GetComponent("UILabel")
	_ui.talent_fx = transform:Find("Container/TopBar/bg_touxiang/TianFuGlow").gameObject
	
	SetClickCallback(transform:Find("Container/TopBar/bg_tili").gameObject, function(go)
		if GUIMgr:IsMenuOpen("WorldMap") then
			MainCityUI.CheckAndBuySceneEnergy()
		else
        	-- MainCityUI.CheckAndBuyEnergy()
        end
    end)
	SetClickCallback(transform:Find("Container/TopBar/bg_gold").gameObject, function(go)
    	store.Show(7)
    end)

    SetClickCallback(transform:Find("Container/TopBar/bg_vip/bg_msg/num").gameObject, function(go)
		local okCallback = function()
			MessageBox.Clear()
		end
		--MessageBox.Show(TextMgr:GetText("common_ui1"), okCallback)
		VIP.Show()
		--[[
		FunctionListData.IsFunctionUnlocked(5, function(isactive)
			if isactive then
				VIP.Show()
			else
				FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(5)), Color.white)
			end
		end)
		--]]
    end)
	_ui.viptips = transform:Find("Container/TopBar/bg_tips (1)")
	_ui.viptipstext = transform:Find("Container/TopBar/bg_tips (1)/time"):GetComponent("UILabel")
	_ui.vipeffect = transform:Find("Container/TopBar/bg_vip/vip_tiyanka")
	
	 _ui.armyStatusSprite = transform:Find("Container/TopBar/soldier_now"):GetComponent("UISprite")
    _ui.armyStatusEffect = transform:Find("Container/TopBar/soldier_now/tihuan").gameObject
    SetClickCallback(_ui.armyStatusSprite.gameObject, SoldierProduction.Show)

	local moneyList = {}
	for k, v in pairs(moneyTypeListMain) do
        local money = {}
        money.type = v
        local moneyTransform = transform:Find(v.path)
        money.transform = moneyTransform
        money.gameObject = moneyTransform.gameObject
        money.label = moneyTransform:Find(v.labelPath):GetComponent("UILabel")
        money.iconTransform = moneyTransform:Find(v.iconPath)
        if k ~= Common_pb.MoneyType_Diamond then
            money.slider = moneyTransform:Find("bg_bar"):GetComponent("UISlider")
        end
        moneyList[k] = money
        SetClickCallback(money.iconTransform.gameObject, function(go)
            UseResItem(k, function()
            end)
        end)
    end
    _ui.moneyListMain = moneyList

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
        MobaActionList.Show()
    end)
    local previewButton = transform:Find("Container/btn_bigmap"):GetComponent("UIButton")
    SetClickCallback(previewButton.gameObject, function()
        local centerMapX, centerMapY = GetCenterMapCoord()
        MobaWarZoneMap.Show(math.floor(centerMapX / 2), math.floor(centerMapY / 2))
    end)
	
	_ui.buff = {}
	_ui.buff.bg = transform:Find("Container/mass_buff")
	_ui.buff.buffbtn = transform:Find("Container/mass_buff/btn_mass")
	_ui.buff.eff = transform:Find("Container/mass_buff/GameObject")
	_ui.buff.point = transform:Find("Container/mass_buff/btn_mass/dian")
	_ui.buff.pointLabel = transform:Find("Container/mass_buff/btn_mass/dian/Label"):GetComponent("UILabel")
	
	SetClickCallback(_ui.buff.buffbtn.gameObject , function()
		MobaBuffView.Show()
	end)
--[[
    _ui.borderOpenButton = transform:Find("Container/btn_lingtu_open"):GetComponent("UIButton")
    SetClickCallback(_ui.borderOpenButton.gameObject, function()
        SetShowBorder(false)
    end)

    _ui.borderCloseButton = transform:Find("Container/btn_lingtu_close"):GetComponent("UIButton")
    SetClickCallback(_ui.borderCloseButton.gameObject, function()
        SetShowBorder(true)
    end)
]]--
    local backButton = transform:Find("Container/btn_back"):GetComponent("UIButton")
    SetClickCallback(backButton.gameObject, function()
        MessageBox.Show(TextMgr:GetText("ui_moba_39") , function() 
			MainCityUI.HideWorldMap(true , MainCityUI.WorldMapCloseCallback, true)
		end,function() 
			
		end)
    end)

--[[
    local tragetButton = transform:Find("Container/btn_traget"):GetComponent("UIButton")
    SetClickCallback(tragetButton.gameObject, function()
        Traget_View.Show()
    end)
	]]--

    InitMap()
    --为了大地图热更 
    --mapNet = WorldMapNet(_ui.mapMgr)

    InitCenterInfo()

    -- InitGovernmentTest()

    -- InitFortTest() ok

    WorldMapData.AddListener(UpdateBuilding)
    WorldBorderData.AddListener(UpdateBorder)
    PathListData.AddListener(UpdatePath)
    MobaActionListData.AddListener(UpdateActionList)
	MobaMainData.AddListener(UpdateClientMainData)
	MobaData.AddStateListener(UpdateMobaState)
	MailListData.AddListener(UpdateNotice)
	MobaBuffData.AddListener(UpdateBuffListIcon)
	MobaArmyListData.AddListener(UpdateArmyList)
	GuildMobaChatData.AddListener(PreviewChanelChange)

    oldDumpCount = Global.GetDumpCount()
    Global.SetDumpCount(10)

    AddDelegate(_ui.mapMgr, "OnMoveEvent", MapMoveEvent)
    AddDelegate(_ui.mapMgr, "OnCenterMoveEvent", MapCenterMoveEvent)
	AddDelegate(UICamera, "onClick", OnUICameraClick)
	
    if mapNet ~= nil then
    AddDelegate(_ui.mapMgr, "onUpdateMapData", OnMapDataUpdate)
    AddDelegate(_ui.mapMgr, "onUpdatePathData", OnPathDataUpdate)    
    end

	resourceBar = transform:Find("Container/resourebar")
	moneyList = {}
	for k, v in pairs(moneyTypeList) do
		
		local money = {}
		money.type = v
		local moneyTransform = transform:Find(v.path)
		money.transform = moneyTransform
		money.gameObject = moneyTransform.gameObject
		money.label = moneyTransform:Find(v.labelPath):GetComponent("UILabel")
		money.iconTransform = moneyTransform:Find(v.iconPath)
		if k ~= Common_pb.MoneyType_Diamond then
			-- money.slider = moneyTransform:Find("bg_bar"):GetComponent("UISlider")
		end
		moneyList[k] = money
		SetClickCallback(money.iconTransform.gameObject, function(go)
			--MainCityUI.UseResItem(k, function()
			--end)
		end)
    end
    _ui.moneyList = moneyList
	
	SetClickCallback(_ui.moneyList[Common_pb.MoneyType_Food].iconTransform.gameObject, function(go)
		Goldstore.ShowRechargeTab()
	end)
	
	SetClickCallback(_ui.moneyList[Common_pb.MoneyType_Iron].iconTransform.gameObject, function(go)
		local itemData = TableMgr:GetItemData(101)
	--	if go == _ui.tipObject then
	--		_ui.tipObject = nil
	--	else
			_ui.tipObject = go
			Tooltip.ShowItemTip({name = '', text = TextMgr:GetText("GuildMoba_Coin_Desc")})
	--	end
	end)

	SetClickCallback(_ui.moneyList[Common_pb.MoneyType_Oil].iconTransform.gameObject, function(go)
		-- MobaStore.Show()
	end)

	MoneyListData.AddListener(UpdateMoney)
	
	UpdateMoney()
	
	_ui.lbTime = transform:Find("Container/time/countdown/time"):GetComponent("UILabel")

	
	promptList = {}
	promptList.Grid = transform:Find("Container/bg_hint/Grid"):GetComponent("UIGrid")
	promptList.Mail = promptList.Grid.transform:Find("hint_info/btn_mail"):GetComponent("UIButton")
	SetClickCallback(promptList.Mail.gameObject, function(go)
		MailListData.ClearMailPush()
		Mail.JumpNewTab(true)
		--GUIMgr:CreateMenu("Mail", false)
		Mail.Show()
    end)
	promptList.alertB = transform:Find("Container/bg_hint/Grid/AlertB").gameObject
	promptList.alertR = transform:Find("Container/bg_hint/Grid/AlertR").gameObject
	promptList.fort = transform:Find("Container/bg_hint/Grid/fort").gameObject
	SetClickCallback(promptList.fort.transform:Find("Sprite").gameObject, function(go)
		--ActivityAll.Show("Fort")
		FortressWarinfo.Show()
	end)
	
	promptList.gov = transform:Find("Container/bg_hint/Grid/gov").gameObject
	SetClickCallback(promptList.gov.transform:Find("Sprite").gameObject, function(go)
		GOVWarinfo.Show()
	end)
	
	promptList.battery = transform:Find("Container/bg_hint/Grid/battery").gameObject
	SetClickCallback(promptList.battery.transform:Find("Sprite").gameObject, function(go)
		BatteryAttackinfo.Show()
		promptList.battery:SetActive(false)
	end)

	promptList.stronghold = transform:Find("Container/bg_hint/Grid/stronghold").gameObject
	SetClickCallback(promptList.stronghold.transform:Find("Sprite").gameObject, function(go)
		StrongholdWarinfo.Show()
	end)
	
	promptList.alertBSup = transform:Find("Container/bg_hint/Grid/AlertB_Support").gameObject
	SetClickCallback(promptList.alertBSup.transform:Find("Sprite").gameObject, function(go)
		CompensateList.Show()
	end)

	promptList.mass = transform:Find("Container/mass_info").gameObject
	SetClickCallback(promptList.mass.transform:Find("btn_mass").gameObject, function(go)
		MobaUnionWar.Show()

		--[[if UnionInfoData.HasUnion() then
			UnionWar.Show()
		--	HideCityMenu()
			UnionInfo.OnCloseCB = function()
			--	RemoveMenuTarget()
			end
		end]]--
    end)	
    promptList.chengqiang = transform:Find("Container/bg_hint/Grid/chengqiang").gameObject
    SetClickCallback(promptList.chengqiang, function()
        MobaUnionWar.Show(3)
    end)
    promptList.dabenying = transform:Find("Container/bg_hint/Grid/dabenying").gameObject
    SetClickCallback(promptList.dabenying, function()
        MobaUnionWar.Show(3)
    end)

	_ui.btnTreatment = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_treatment/btn_bag"):GetComponent("UIButton")
	SetClickCallback(_ui.btnTreatment.gameObject, function(go)
		
		local hospitalBuild = maincity.GetBuildingByID(3)
		if hospitalBuild == nil then
			FloatText.Show(TextMgr:GetText("ui_error1") , Color.red)
			
			return
		end
		
		AudioMgr:PlayUISfx("SFX_ui01", 1, false)
		
		local buildData = {}
		buildData.data = {}
		buildData.data.level =1
		buildData.data.uid = 1
		buildData.buildingData = {}
		buildData.buildingData.showType =1
		buildData.buildingData.logicType =1
		
		
		Hospital.SetBuild(buildData)
		GUIMgr:CreateMenu("Hospital", false)
		Hospital.OnCloseCB = function()
			
		end
	end)	
	
	_ui.btnArmy = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_army/btn_army"):GetComponent("UIButton")
	SetClickCallback(_ui.btnArmy.gameObject, function(go)
		MobaParadeGround.Show()
    end)	
    
	_ui.btnReinforcement = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_soldier/btn_army"):GetComponent("UIButton")
	SetClickCallback(_ui.btnReinforcement.gameObject, function(go)
		Reinforcement.Show()
	end)	

	_ui.btnMail = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mail/btn_bag"):GetComponent("UIButton")
	SetClickCallback(_ui.btnMail.gameObject, function(go)
		Mail.ShowGuildMoba()
	end)	
	
--[[	_ui.btnPersonalInfo = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_player/btn_bag")
	SetClickCallback(_ui.btnPersonalInfo.gameObject, function(go)
		MobaPersonalInfo.Show()
    end)]]--
    
	_ui.btnWar = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_war/btn_bag")
	SetClickCallback(_ui.btnWar.gameObject, function(go)
		MobaUnionWar.Show()
	end)	    
	
	ChatMenu = {}
	ChatMenu.bg = transform:Find("Container/bg_liaotian")
	ChatMenu.chatBtn = transform:Find("Container/bg_liaotian/btn_jiantou")
	ChatMenu.name1 = transform:Find("Container/bg_liaotian/name1")
	ChatMenu.name2 = transform:Find("Container/bg_liaotian/name2")
	ChatMenu.redPoint = transform:Find("Container/bg_liaotian/redpoint")
	ChatMenu.previewTog = {}
	for i=ChatMsg_pb.chanel_GuildMobaWorld , ChatMsg_pb.chanel_GuildMobaTeam , 1 do
		ChatMenu.previewTog[i] = transform:Find("Container/bg_liaotian/pointbar/point" .. i):GetComponent("UIToggle")
	end
	
	ChatMenu.previewTogKey = {}
	--ChatMenu.previewTogKey[ChatMsg_pb.chanel_MobaPrivate] = {}
	--ChatMenu.previewTogKey[ChatMsg_pb.chanel_MobaPrivate].key = ChatMsg_pb.chanel_MobaPrivate
	--ChatMenu.previewTogKey[ChatMsg_pb.chanel_MobaPrivate].last = ChatMsg_pb.chanel_MobaTeam
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_GuildMobaWorld] = {}
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_GuildMobaWorld].key = ChatMsg_pb.chanel_GuildMobaWorld
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_GuildMobaWorld].next = ChatMsg_pb.chanel_GuildMobaTeam
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_GuildMobaTeam] = {}
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_GuildMobaTeam].key = ChatMsg_pb.chanel_GuildMobaTeam
	--ChatMenu.previewTogKey[ChatMsg_pb.chanel_MobaTeam].next = ChatMsg_pb.chanel_MobaPrivate
	ChatMenu.previewTogKey[ChatMsg_pb.chanel_GuildMobaTeam].last = ChatMsg_pb.chanel_GuildMobaWorld
	SetClickCallback(ChatMenu.chatBtn.gameObject, function(go)
		GUIMgr:CreateMenu("GuildMobaChat", false)
	end)
	chatPreviewOffset = 0
	UIUtil.SetDragCallback(ChatMenu.chatBtn.gameObject , function(go , delt)
		chatPreviewOffset = chatPreviewOffset + delt.x
	end)
	UIUtil.SetDragEndCallback(ChatMenu.chatBtn.gameObject , function(go)
		--print(delt.x)
		if chatPreviewOffset < -100 then
			PreviewChanelChange(2)
		end
		
		if chatPreviewOffset > 100 then
			PreviewChanelChange(1)
		end
		chatPreviewOffset = 0
	end)
	
	warning[1] = {}
    warning[1].btn = promptList.alertB
    warning[1].kuang = transform:Find("Container/AlertBkuag").gameObject
    warning[1].music = warning[1].btn.transform:Find("scale/AlertRwave"):GetComponent("AudioSource")
    warning[1].music.playOnAwake = false
    warning[2] = {}
    warning[2].btn = promptList.alertR
    warning[2].kuang = transform:Find("Container/AlertRkuag").gameObject
    warning[2].music = warning[2].btn.transform:Find("scale/AlertRwave"):GetComponent("AudioSource")
	warning[2].music.playOnAwake = false
	
	for i, v in ipairs(warning) do
		if AudioMgr.SfxSwith and v.music.volume == 0 then
			v.music.volume = 0.5
		elseif not AudioMgr.SfxSwith and v.music.volume > 0 then
			v.music.volume = 0
		end
	end
	
	noticeList = {}
    noticeList.mail = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mail/btn_bag/red dot")
    --noticeList.mailnum = transform:Find("Container/bg_zhankai/Panel_left/bg_left/bg_mail/btn_bag/red dot/num"):GetComponent("UILabel")
	
	--[[_ui.buff = transform:Find("Container/bg_buff")
	_ui.buffGrid = transform:Find("Container/bg_buff/Grid"):GetComponent("UIGrid")
	_ui.buffitemPrefab = transform:Find("Container/buff_info")
	]]

	MobaActionListData.RequestData()
	MobaRadarData.AddListener(RadarListener)
    RadarListener()
	MobaPackageItemData.GetDataWithCallBack(function()
	end)
	MobaItemData.GetDataWithCallBack(function()
	end)
	--MobaMainData.RequestData()

	_ui.refreshtime = transform:Find("Container/time/countdown/time"):GetComponent("UILabel")
	_ui.states = {}
	
	
	_ui.red_badge = {}
	_ui.red_badge.borderTexture = transform:Find("Container/time/red/BadgeBG/outline icon"):GetComponent("UITexture")
	_ui.red_badge.colorTexture = transform:Find("Container/time/red/BadgeBG/outline icon/color"):GetComponent("UITexture")
	_ui.red_badge.totemTexture = transform:Find("Container/time/red/BadgeBG/totem icon"):GetComponent("UITexture")
	_ui.red_badge.name = transform:Find("Container/time/red/name"):GetComponent("UILabel")
	_ui.red_badge.value = transform:Find("Container/time/red/Label"):GetComponent("UILabel")
	_ui.red_badge.proceed = transform:Find("Container/time/red/Sprite/proceed"):GetComponent("UISprite")
	
	_ui.blue_badge = {}
	_ui.blue_badge.borderTexture = transform:Find("Container/time/blue/BadgeBG/outline icon"):GetComponent("UITexture")
	_ui.blue_badge.colorTexture = transform:Find("Container/time/blue/BadgeBG/outline icon/color"):GetComponent("UITexture")
	_ui.blue_badge.totemTexture = transform:Find("Container/time/blue/BadgeBG/totem icon"):GetComponent("UITexture")
	_ui.blue_badge.name = transform:Find("Container/time/blue/name"):GetComponent("UILabel")
	_ui.blue_badge.value = transform:Find("Container/time/blue/Label"):GetComponent("UILabel")
	_ui.blue_badge.proceed = transform:Find("Container/time/blue/Sprite/proceed"):GetComponent("UISprite")
	

	_ui.red_badge.value.text = '0'
	_ui.blue_badge.value.text = '0'
	
	Global.DumpMessage(MobaData.GetMobaMatchInfo() , "d:/mobamatchinfo.lua")
	
--[[	
	_ui.btnInfo = transform:Find("Container/bg_time/Texture")
	SetClickCallback(_ui.btnInfo.gameObject, function(go)
		GUIMgr:CreateMenu("MobaPoint" , false)
    end)	]]--
    
    UpdateMassBtn()

    local showMobaTime = function()
        coroutine.stop(_ui.countdowncoroutine)
		_ui.countdowncoroutine = coroutine.start(function()
			-- MobaData.SetMobaState(MobaData.GetMobaState())
			
			local msg = UnionMobaActivityData.GetMobaEnterMsg()
			
			_ui.red_badge.value.text = msg.team1.score
			_ui.blue_badge.value.text = msg.team2.score
			local maxScore = tonumber(TableMgr:GetGuildMobaGlobal(6).Value)
			_ui.red_badge.proceed.fillAmount = msg.team1.score /maxScore 
			_ui.blue_badge.proceed.fillAmount = msg.team2.score /maxScore 
			
			_ui.red_badge.name.text =  "【" .. msg.team1.guildBanner .. "】" ..msg.team1.guildName
			_ui.blue_badge.name.text = "【" .. msg.team2.guildBanner .. "】" ..msg.team2.guildName
			
			UnionBadge.LoadBadgeById(_ui.red_badge, msg.team1.guildBadge)
			UnionBadge.LoadBadgeById(_ui.blue_badge, msg.team2.guildBadge)
			
			local timer = UnionMobaActivityData.GetMobaLeftTime()
			while true do
				timer = UnionMobaActivityData.GetMobaLeftTime()
				_ui.refreshtime.text = Global.SecondToTimeLong(timer)
				if timer <= 0 then
					break
				end

			--[[	
				if GUIMgr:IsMenuOpen("Mobaroleselect") then
					for i=1,4 do 
						_ui.states[i].shanshuo.gameObject:SetActive(false)
						_ui.states[i].shanshuoyici.gameObject:SetActive(false)
						_ui.states[i].btn.spriteName = ""
					end 
				else
					local state = MobaData.GetMobaState(true)
				
					for i=1,4 do 
					  if state >= i then 
						_ui.states[i].btn.spriteName = "icon_stage_done"
						if state == i and MobaData.GetCurState()~=-2 then 
							_ui.states[i].shanshuo.gameObject:SetActive(true)
							_ui.states[i].shanshuoyici.gameObject:SetActive(true)
						end
					  else
						_ui.states[i].btn.spriteName = "icon_stage_null"
					  end
					end 
				end ]]--
				coroutine.wait(1)
			end
		end)	
    end
    if UnionMobaActivityData.GetMobaEnterMsg() ~= nil then
        showMobaTime()
    else
		
        UnionMobaActivityData.RequestEnterMap(nil,false,false)
    end
	
  --  MobaResBar.Init()
   CheckHouseAndDoor()
end

function UpdateMobaState()
	
end 

function UpdateScore(msg)
	local maxScore = tonumber(TableMgr:GetGuildMobaGlobal(6).Value)
	_ui.red_badge.value.text = msg.scoreA
	_ui.blue_badge.value.text = msg.scoreB
	_ui.red_badge.proceed.fillAmount = msg.scoreA /maxScore 
	_ui.blue_badge.proceed.fillAmount = msg.scoreB /maxScore 
end 

local radarlock = false
function RadarListener(type)
	local warningType = MobaRadarData.GetWarningType()
	if type ~= nil then
		if type == 0 then
			radarlock = false
			coroutine.start(function()
				coroutine.step()
				RadarListener()
			end)
		else
			warningType = type
			radarlock = true
		end
	end
	if radarlock and type == nil then
		return
	end
	for i, v in pairs(warning) do
		v.btn:SetActive(false)
		v.kuang:SetActive(false)
	end
	if warningType > 0 then
		warning[warningType].kuang:SetActive(true)
		warning[warningType].btn:SetActive(true)
		if not warning[warningType].music.isPlaying then
			warning[warningType].music:Play()
		end
	    SetClickCallback(warning[warningType].btn, function(go)
	    	GUIMgr:CreateMenu("MobaMarchlist" , false)
	    end)
	end
	coroutine.start(function()
		coroutine.step()
		if promptList == nil then
		    return
        end
		promptList.Grid:Reposition()
	end)
end

function RadarEffectRed(active)
	warning[2].kuang:SetActive(active)
	warning[2].btn:SetActive(active)
	if not warning[2].music.isPlaying then
		warning[2].music:Play()
	end
	coroutine.start(function()
		coroutine.step()
		if promptList == nil then
		    return
        end
		promptList.Grid:Reposition()
	end)
end

function RadarEffectBlue(active)
	warning[1].kuang:SetActive(active)
	warning[1].btn:SetActive(active)
	if not warning[1].music.isPlaying then
		warning[1].music:Play()
	end
	coroutine.start(function()
		coroutine.step()
		if promptList == nil then
		    return
        end
		promptList.Grid:Reposition()
	end)
end

function RadarSoundOff()
	local warningType = MobaRadarData.GetWarningType()
	if warningType > 0 then
		if warning[warningType].music.isPlaying then
			warning[warningType].music:Stop()
		end
	end
	MobaRadarData.SetWarningOff()
end

function UpdateFortIcon(flag)
	if promptList ~= nil and promptList.fort ~= nil then
		promptList.fort:SetActive(flag)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function UpdateFortState()
	local sh_state = FortressData.IsActive()
	UpdateFortIcon(sh_state)
end

function UpdateGovIcon(flag)
	if promptList ~= nil and promptList.gov ~= nil then
		promptList.gov:SetActive(flag)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function UpdateGovState()
	local gov_state = GovernmentData.GetGOVState()
	if gov_state ~= nil then
		UpdateGovIcon(gov_state == 2)
	end
end

function UpdateStrongholdIcon(flag)
	if promptList ~= nil and promptList.stronghold ~= nil then
		promptList.stronghold:SetActive(flag)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function UpdateStrongholdState()
	local sh_state = StrongholdData.IsActive()
	UpdateStrongholdIcon(sh_state)
end

function UpdateCompensateState()
	promptList.alertBSup.gameObject:SetActive(false)
	local unionMemHelpMsg = UnionHelpData.GetMemberHelpData()
	if promptList ~= nil and promptList.alertBSup ~= nil then
		if unionMemHelpMsg ~= nil and unionMemHelpMsg.compensateInfos ~= nil and #unionMemHelpMsg.compensateInfos > 0 then
			for i=1 , #unionMemHelpMsg.compensateInfos do
				local msgInfo = unionMemHelpMsg.compensateInfos[i]
				if msgInfo.charId == MainData.GetCharId() and msgInfo.endTime > Serclimax.GameTime.GetSecTime() then
					promptList.alertBSup.gameObject:SetActive(true)
					--promptList.Grid:Reposition()
					break
				end
			end
		end
	end
	
	local memSup = 0
	if promptList ~= nil and promptList.support ~= nil then
		if unionMemHelpMsg ~= nil and unionMemHelpMsg.compensateInfos ~= nil and #unionMemHelpMsg.compensateInfos > 0 then
			for i=1 , #unionMemHelpMsg.compensateInfos do
				local msgInfo = unionMemHelpMsg.compensateInfos[i]
				if UnionHelp.NeedShow(msgInfo) and msgInfo.endTime > Serclimax.GameTime.GetSecTime() then
					--promptList.support.gameObject:SetActive(true)
					--promptList.Grid:Reposition()
					--break
					memSup = memSup + 1
				end
			end
		end
	end
	
	promptList.support:SetActive(memSup > 0)
	promptList.support.transform:Find("red dot").gameObject:SetActive(memSup > 0)
	promptList.support.transform:Find("red dot/num"):GetComponent("UILabel").text = memSup
	promptList.Grid:Reposition()
end

function UpdateMassBtn()
    if _ui == nil then
        return
    end
	local open = false
	if MassTotlaNum[1] > 0 or  MassTotlaNum[2] > 0 then
		open = true
	end
print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",open,MassTotlaNum[1],MassTotlaNum[2])
	if promptList ~= nil and promptList.mass ~= nil then
		promptList.mass:SetActive(open)
		coroutine.start(function()
			coroutine.step()
			if promptList == nil then
				return
			end
			promptList.Grid:Reposition()
		end)
	end	
end

function UpdateVipNotice(flag)
	if noticeList ~= nil and noticeList.vip ~= nil and not noticeList.vip:Equals(nil) then
		if flag == nil then
			noticeList.vip:SetActive(VipData.HasUncollectedRewards())
		else
			noticeList.vip:SetActive(flag)
		end
	end
end

function OnTurretHurtNorify()
	if promptList ~= nil and promptList.battery ~= nil and not promptList.battery:Equals(nil) then
		promptList.battery:SetActive(true)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
end

function OnMailNotify(msg)	
	if promptList~= nil and not promptList.Mail.gameObject:Equals(nil) then
		promptList.Mail.transform.parent.gameObject:SetActive(true)
		coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
	end
	--MailListData.AddNotifyCount()
	--保存老邮件
	PVP_Rewards.SaveMailListData(MailListData.GetData())
	MailListData.RequestGuildMobaData()
end



local function UpdateMenuNotice()
	local hasMailNotice = MailListData.HasGuildMobaNotice()
	if noticeList then
	print(hasMailNotice)
		noticeList.mail.gameObject:SetActive(hasMailNotice)
		if hasMailNotice then
			--local hasMailNewNum = MailListData.HasNewNum()
			--noticeList.mailnum.text = hasMailNewNum
		end
	end
    return hasMailNotice 
end

function UpdateNotice()
	UpdateMenuNotice()
    --if noticeList ~= nil then
		--noticeList.main.gameObject:SetActive(UpdateMenuNotice())
   -- end	
end


function UpdateBuffListIcon()
    local skinInfoMsg = MainData.GetData().skin
    local skinList = {}
    local skinsMsg = skinInfoMsg.skins
    for _, v in ipairs(skinsMsg) do
        if not Skin.IsDefaultSkin(v.id) then
            table.insert(skinList, {data = tableData_tSkin.data[v.id], msg = v, itemDataList = Skin.GetItemDataList(v.id)})
        end
    end
	local activeCount = MobaBuffData.GetActiveBuffInBufflist()
	if _ui.buff ~= nil then
		if activeCount > 1 then
			_ui.buff.buffbtn:GetComponent("UISprite").spriteName = "BUFF_open02"
			_ui.buff.point.gameObject:SetActive(true)
			_ui.buff.pointLabel.text = activeCount + #skinList
			_ui.buff.eff.gameObject:SetActive(true)
		elseif activeCount == 1 then
			_ui.buff.buffbtn:GetComponent("UISprite").spriteName = "BUFF_open02"
			_ui.buff.point.gameObject:SetActive(false)
			_ui.buff.eff.gameObject:SetActive(true)
		else
			_ui.buff.buffbtn:GetComponent("UISprite").spriteName = "BUFF_close02"
			_ui.buff.point.gameObject:SetActive(false)
			_ui.buff.eff.gameObject:SetActive(false)
		end
	end
	

	--mainBuff
	--[[local bufflist = MobaBuffData.GetData()
	local activeCount = #bufflist
	local childCound = _ui.buffGrid.transform.childCount
	if _ui.buff ~= nil then	
		for i = 1 , activeCount do
			local v = bufflist[i]
			local baseData = TableMgr:GetSlgBuffData(v.buffId)
			local item = nil
			if i <= childCound then
				item = _ui.buffGrid.transform:GetChild(i - 1).transform
				item.gameObject:SetActive(true)
				item:Find("icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", baseData.icon)
			else
				item = NGUITools.AddChild(_ui.buffGrid.gameObject ,_ui.buffitemPrefab.gameObject ).transform
				item:Find("icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", baseData.icon)
			end
			
			SetClickCallback(item.gameObject  , function()
				Tooltip.ShowMobaBuffTips(v.buffId)
			end)
		end
		
		for i = activeCount + 1 , childCound do
			_ui.buffGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
		end
		_ui.buffGrid:Reposition()
		
	end]]
	
end

function CheckMoneyLock()
	if _ui == nil then
		return
	end
	for k, v in pairs(_ui.moneyListMain) do
        if k ~= Common_pb.MoneyType_Diamond then
          --  v.gameObject:SetActive((maincity.IsBuildingUnlockByID(v.type.resourceType)))
        end
    end
end

function CheckHouseAndDoor()
    if _ui == nil then
        return
    end
    local mt = MobaMassTroops()
    mt:RequestBuildInfo(function(msg)
        local state =  mt:GetCenterWarningState(msg,false) and 2 or 0
        state = mt:GetCenterWarningState(msg,true) and 1 or state
        promptList.chengqiang:SetActive(state == 2)
        promptList.dabenying:SetActive(state == 1)
        coroutine.start(function()
			coroutine.step()
            if promptList == nil then
                return
            end
			promptList.Grid:Reposition()
		end)
    end)
end

function UpdateMoney()
	CheckMoneyLock()
	if _ui == nil then
		return
	end
	--[[
	for k, v in pairs(_ui.moneyListMain) do
        local currentValue = MoneyListData.GetMoneyByType(k)
        local lastValue = MoneyListData.GetOldMoneyByType(k)
		UIAnimMgr:IncreaseUILabelTextAnim(v.label , lastValue , currentValue)
		
        if k == Common_pb.MoneyType_Diamond then
            v.label.text = currentValue
		else
			local rescapacity = maincity.GetResourceTotalCapacity(v.type.resourceType)
            v.label.text = (currentValue > rescapacity and "[e4bd1aff]" or "[C2BBBBFF]") .. Global.ExchangeValue(currentValue) .. "[-]"
            v.slider.value = currentValue / rescapacity
        end
    end
	]]--
	

    for k, v in pairs(_ui.moneyList) do
		if k ~= Common_pb.MoneyType_Food and k~=Common_pb.MoneyType_Iron and k~=Common_pb.MoneyType_Oil then
			local currentValue = MoneyListData.GetMoneyByType(k)
			local lastValue = MoneyListData.GetOldMoneyByType(k)
			UIAnimMgr:IncreaseUILabelTextAnim(v.label , lastValue , currentValue)
			
			if k == Common_pb.MoneyType_Diamond then
				v.label.text = currentValue
			else
				local rescapacity = maincity.GetResourceTotalCapacity(v.type.resourceType)
				v.label.text = (currentValue > rescapacity and "[e4bd1aff]" or "[C2BBBBFF]") .. Global.ExchangeValue(currentValue) .. "[-]"
				-- v.slider.value = currentValue / rescapacity
			end
		end
    end
	
	local v = _ui.moneyList[Common_pb.MoneyType_Food]
	v.label.text = MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond)
	
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

function OnUICameraClick(go)
    Tooltip.HideMobaBuffTips()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
	if _ui.EnergyTipRoot.activeInHierarchy then
		_ui.EnergyTipRoot:SetActive(false)
	end
end

function Close()
    ClearBattleEndShow()
    _ui.mapBgTransform = nil  
    previewEnabled = false
    WorldMapData.RemoveListener(UpdateBuilding)
    WorldBorderData.RemoveListener(UpdateBorder)
    PathListData.RemoveListener(UpdatePath)
    MobaActionListData.RemoveListener(UpdateActionList)
	MobaMainData.RemoveListener(UpdateClientMainData)
	MailListData.RemoveListener(UpdateNotice)
	MobaData.RemoveStateListener(UpdateMobaState)
	MobaBuffData.RemoveListener(UpdateBuffListIcon)
	MobaArmyListData.RemoveListener(UpdateArmyList)
	GuildMobaChatData.RemoveListener(PreviewChanelChange)
  
	Global.SetDumpCount(oldDumpCount)
    RemoveDelegate(_ui.mapMgr, "OnMoveEvent", MapMoveEvent)
    RemoveDelegate(_ui.mapMgr, "OnCenterMoveEvent", MapCenterMoveEvent)
	RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    if mapNet ~= nil then
    RemoveDelegate(_ui.mapMgr, "onUpdateMapData", OnMapDataUpdate)
    RemoveDelegate(_ui.mapMgr, "onUpdatePathData", OnPathDataUpdate)      
    end
    MailListData.ClearGuildMobaMail()
	coroutine.stop(_ui.countdowncoroutine)
	MobaData.SetMobaState(-1)
    MainCityUI.DestroyTerrain()
	GuildMobaChatData.ResetData()
	mapNet = nil
	noticeList = nil
	ChatMenu = nil
    _ui = nil
    TileInfo.Hide()
    rebel.CloseSelf()
 --   local req = MapMsg_pb.SceneMapCloseRequest()
 --   Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapCloseRequest, req, MapMsg_pb.SceneMapCloseResponse, function(msg)
 --   end, true)
	MoneyListData.RemoveListener(UpdateMoney)
	MobaRadarData.RemoveListener(RadarListener)
	GUIMgr:CloseMenu("MobaTileInfo")
	MobaResBar.Close()
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
            local offset_x,offset_y= MobaMinPos()
            local base_pos = MobaMainData.GetData().pos
            local basePos = {}
            basePos.x = base_pos.x +offset_x
            basePos.y = base_pos.y +offset_y

        SetLookAtCoord(basePos.x == nil and 0 or basePos.x , basePos.y == nil and 0 or basePos.y)
    end
	UpdateNotice()
	UpdateArmyStatus()
	
    UpdateActionList()
	UpdateClientMainData()
	UpdateBuffListIcon()
	PreviewChanelChange()
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

    -- local id = 6
    -- local color = Color(0.5,0.5,0.5,1)
    -- local isEffect = true
    -- return id, color, isEffect 
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

function GetPreMassTotalNum()
    if PreMassTotalNum == nil then
        PreMassTotalNum =  {
        [1] = 0,
        [2] = 0,}
    end
    return PreMassTotalNum
end

function MassHasNotice()
	if MassTotlaNum[1] <= 0 and MassTotlaNum[2] <=0 then
		return false
	end
    return MassTotlaNum[1] ~= GetPreMassTotalNum()[1] or MassTotlaNum[2] ~= GetPreMassTotalNum()[2]
end

function Update()
		--拉取聊天记录
	if (not UnionMobaActivityData.isMobaOver()) and Serclimax.GameTime.GetSecTime() >= GuildMobaChatData.GetNextTime() then
		if not requestChat then 
			requestChat = true
			GuildMobaChatData.RequestChat(nil , function() 
				requestChat = false 
			end)
			
		end
	end
end


function SetChatPreviewRedPoint(flag)
	if transform == nil then
		return 
	end
	if ChatMenu~= nil and ChatMenu.redPoint~= nil and ChatMenu.redPoint.gameObject ~= nil then
		ChatMenu.redPoint.gameObject:SetActive(flag)
	end
	MobaResBar.SetChatPreviewRedPoint(flag)
end

function PreviewChanelChange(dir, uiChat)
	if _ui == nil or ChatMenu == nil then
		return
	end
	
	--if not Main.Instance:IsInBattleState() then
		if not uiChat then
			uiChat = ChatMenu
		end

		local curChannel = Global.GuildMobaGetChatEnterChanel()
		if ChatMenu.previewTogKey[curChannel] == nil then
			return
		end
		
		
		local curTog = nil
		if dir == 1 then
			curTog = ChatMenu.previewTogKey[curChannel].last
		elseif dir == 2 then
			curTog =  ChatMenu.previewTogKey[curChannel].next
		else
			curTog = ChatMenu.previewTogKey[curChannel].key
		end


		local hasNotice_privateChanel = false
		local hasNotice_guildChanel = GuildMobaChatData.GetUnreadGuildCount() > 0
		local hasNotice_groupChat = false
		
		SetChatPreviewRedPoint(hasNotice_privateChanel or hasNotice_guildChanel or hasNotice_groupChat)
		
		if curTog ~= nil then
			
			ChatMenu.previewTog[curTog]:Set(true)
			UpdateChatHint(curTog, 2)
			if uiChat ~= ChatMenu then
				uiChat.previewTog[curTog]:Set(true)
				UpdateChatHint(curTog, 2, uiChat)
			end
			Global.SetGuildMobaChatEnterChanel(curTog)
		end
	--end
end


function UpdateChatHint(chanel, hintCount, uiChat)
	if not uiChat then
		uiChat = ChatMenu
	end

	local recentChat = GuildMobaChatData.GetRecentNewChat(chanel ,hintCount)
	uiChat.name1.gameObject:SetActive(recentChat ~= nil and #recentChat > 1)
	uiChat.name2.gameObject:SetActive(recentChat ~= nil and #recentChat > 0)
	if recentChat ~= nil and #recentChat > 0 then
		for i , v in pairs(recentChat) do
			local cmName = nil
			
			if i == 1 then
				cmName = uiChat.name2
			elseif i == 2 then
				cmName = uiChat.name1
			end
			
			if cmName ~= nil and cmName.gameObject ~= nil then
				--GOV_Util.SetGovNameUI(cmName:Find("bg_gov"),0,0,true)
				cmName.gameObject:SetActive(true)
				
				local name = cmName:GetComponent("UILabel")
				if v.type == 4 then
					name.text = ""
				elseif v.gm then
					name.text = "[ff0000][" .. TextMgr:GetText("GM_Name") .."][-]:"
				else
					name.text = "【" .. v.sender.name .."】:"
					--GOV_Util.SetGovNameUI(cmName:Find("bg_gov"),v.sender.officialId,v.sender.guildOfficialId,true,v.sender.militaryRankId)
					local roleData = TableMgr:GetMobaRoleTablebyID(v.sender.officialId)
					if roleData then
						cmName:Find("bg_gov").gameObject:SetActive(true)
						cmName:Find("bg_gov/gov_icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", roleData.Icon)
					end
				end
				
				local content = cmName:Find("Label"):GetComponent("UILabel")
				local contentOffset = ""
				if v.type == 3 then
					cmName:Find("Label/Sprite").gameObject:SetActive(true)
					contentOffset = "          "
				else
					cmName:Find("Label/Sprite").gameObject:SetActive(false)
				end
				
				--目前没有翻译功能，所以都显示内容原文2017/8/18
				--[[if v.clientlangcode == Global.GTextMgr:GetCurrentLanguageID() then
					content.text = contentOffset .. v.infotext
				else
					content.text = contentOffset .. v.transtext
				end]]
				
				if v.type == 4 or v.type == 5 or v.type == 2 then
					content.text = contentOffset .. Chat.GetSystemChatInfoContent(v.infotext)
				else
					content.text = contentOffset .. v.infotext
				end
				if v.type == 7 then
					content.text = contentOffset .. TextMgr:GetText(v.infotext)
				end
			end
		end
	end
end


function UpdateArmyStatus()
    if _ui == nil then
        return
    end

    local status = Barrack.GetArmyStatus()
    _ui.armyStatusSprite.spriteName = "icon_soldiernow" .. status
   	
    if status ~= _ui.armyStatus then
        _ui.armyStatus = status
        local statusMsg =
        {
            content = "TipsNotice_Union_Desc16",
            priority = 500,
            paras =
            {
                {
                    value = TextMgr:GetText("Review_status_" .. status),
                },
            },
            format = 1,
            title = "",
            tipId = 0,
            tipType = 1,
        } 

        Notice_Tips.ShowTips(statusMsg)
        _ui.armyStatusEffect:SetActive(false)
        _ui.armyStatusEffect:SetActive(true)
        if UnityEngine.PlayerPrefs.GetInt("SoldierProduction", 0) == 0 then
            SoldierProduction.Show()
            UnityEngine.PlayerPrefs.SetInt("SoldierProduction", 1)
            UnityEngine.PlayerPrefs.Save()
        end
    end
end