module("MapPreviewData", package.seeall)
local mapPreviewData
local fieldList = {}
local eventListener = EventListener()
local mapSize = 44

local TableMgr = Global.GTableMgr

function GetData()
    return mapPreviewData
end

function PosToDataIndex(pos)
    return pos.y * mapSize + pos.x + 1
end

function XYToDataIndex(x, y)
    return y * mapSize + x + 1
end

function SetData(data)
    mapPreviewData = data
    fieldList = {}

    for i, v in ipairs(data.fields) do
        for __, vv in ipairs(v.posi) do
            fieldList[vv + 1] = {index = i, data = v}
        end
    end
end

function GetPveMonsterPos()
	return mapPreviewData.actMonsterPos
end

function GetGuildlLaderPos()
    return mapPreviewData.guildlLaderPos
end

function GetGuildlMemberPos()
    return mapPreviewData.guildlMemberPos
end

function GetFieldDataByIndex(dataIndex)
    return fieldList[dataIndex]
end

function GetFieldDataByPos(pos)
    return GetFieldDataByIndex(PosToDataIndex(pos))
end

function GetFieldDataByXY(x, y)
    return GetFieldDataByIndex(XYToDataIndex(x, y))
end

function GetGuildIdByXY(x, y)
    local fieldData = GetFieldDataByXY(x, y)
    return fieldData ~= nil and fieldData.data.guildid or 0
end

function IsUnionField(guildId, x, y)
    return GetGuildIdByXY(x, y) == guildId
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

function RequestData(callback)
    local req = MapMsg_pb.SceneMapWorldFieldRequest()

    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapWorldFieldRequest, req, MapMsg_pb.SceneMapWorldFieldResponse, function(msg)
        SetData(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
            NotifyListener()
        end
    end, false)
end
