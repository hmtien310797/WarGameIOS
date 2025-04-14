module("WorldBorderData", package.seeall)
local worldBorderData
local borderList = {}
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return worldBorderData
end

local function PosToDataIndex(pos)
    return pos.y * 512 + pos.x + 1
end

local function XYToDataIndex(x, y)
    return y * 512 + x + 1
end

function SetData(data)
    worldBorderData = data
    borderList = {}

    for _, v in ipairs(data.fields) do
        for __, vv in ipairs(v.pos) do
            local dataIndex = PosToDataIndex(vv)
            borderList[dataIndex] = v
        end
    end
end

function GetBorderDataByIndex(dataIndex)
    return borderList[dataIndex]
end

function GetBorderDataByPos(pos)
    return GetBorderDataByIndex(PosToDataIndex(pos))
end

function GetBorderDataByXY(x, y)
    local mgr = WorldMap.GetWorldMapMgr()
    if mgr ~= nil then
        return mgr:GetBorderData():GetBorderDataByXY(x,y)
    end

    return GetBorderDataByIndex(XYToDataIndex(x, y))
end

function GetGuildIdByXY(x, y)
    local mgr = WorldMap.GetWorldMapMgr()
    if mgr ~= nil then
        return  mgr:GetBorderData():GetGuildIdByXY(x,y)
    end

    local borderData = GetBorderDataByXY(x, y)
    return borderData ~= nil and borderData.guildid or 0
end

function IsEnemyBorder(x, y)
    local mgr = WorldMap.GetWorldMapMgr()
    if mgr ~= nil then
        return  mgr:GetBorderData():IsEnemyBorder(x,y,UnionInfoData.GetGuildId())
    end

    local guildId = GetGuildIdByXY(x, y)
    return guildId ~= 0 and guildId ~= UnionInfoData.GetGuildId()
end

function IsSelfBorder(x, y)
    local mgr = WorldMap.GetWorldMapMgr()
    if mgr ~= nil then
        print("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM")
        return  mgr:GetBorderData():IsSelfBorder(x,y,UnionInfoData.GetGuildId())
    end

    local guildId = UnionInfoData.GetGuildId()
    return guildId ~= 0 and guildId == GetGuildIdByXY(x, y)
end

function IsSelfNeighboringBorder(x, y)
    local mgr = WorldMap.GetWorldMapMgr()
    if mgr ~= nil then
        return  mgr:GetBorderData():IsSelfNeighboringBorder(x,y,UnionInfoData.GetGuildId())
    end


    if x > 0 and IsSelfBorder(x - 1, y) then
        return true
    end

    if y > 0 and IsSelfBorder(x, y - 1) then
        return true
    end

    if x < 511 and IsSelfBorder(x + 1, y) then
        return true
    end

    if y < 511 and IsSelfBorder(x, y + 1) then
        return true
    end

    return false
end

function CanCreateBuilding(mapX, mapY, offsetX, offsetY)
    for x = offsetX[1], offsetX[2] do
        for y = offsetY[1], offsetY[2] do
            if not IsSelfBorder(mapX + x, mapY +y) then
                return false
            end
        end
    end

    return true
end

function GetValidBuildingCoord(mapX, mapY, buildingOffset)
    local offsetX = buildingOffset[1]
    local offsetY = buildingOffset[2]
    if CanCreateBuilding(mapX, mapY, offsetX, offsetY) then
        return mapX, mapY
    end

    for x = offsetX[1], offsetX[2] do
        for y = offsetY[1], offsetY[2] do
            local newMapX = mapX - x
            local newMapY = mapY - y
            if CanCreateBuilding(newMapX, newMapY, offsetX, offsetY) then
                return newMapX, newMapY
            end
        end
    end

    return nil, nil
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function RequestData(posIndex, lockScreen)
    local startX = posIndex % 64 - 2
    local startY = math.floor(posIndex / 64) - 2
    local req = MapMsg_pb.SceneMapGuildFieldRequest()

    for x = 0, 5 do
        for y = 0, 5 do
            local posi = ((startY + y) % 64) * 64  + (startX + x) % 64
            req.posi:append(posi)
        end
    end
	
	
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapGuildFieldRequest, req, MapMsg_pb.SceneMapGuildFieldResponse, function(msg)
        SetData(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            NotifyListener()
        end
    end, not lockScreen)
end
