module("WorldMapData", package.seeall)
local TableMgr = Global.GTableMgr
local worldMapData
local tileList = {}
local eventListener = EventListener()

--性能测试
local useTestData = false
local testData = MapData_pb.SEntryData()
testData.data.entryType = Common_pb.SceneEntryType_Home 
local home = testData.home
home.homelvl = 10
home.hasShield = true
home.statusTime = os.time() + 99999
home.status = 1
local ownerguild = testData.ownerguild
ownerguild.guildid = 1

local TableMgr = Global.GTableMgr

local buildingOffsetList
local buildingShapeList

function GetBuildingOffset(shapeId)
    if buildingOffsetList == nil then
        buildingOffsetList = {}
        buildingShapeList = {}
        local objectShapeList = TableMgr:GetObjectShapeList()
		for i , v in pairs(objectShapeList) do
			local shapeData = objectShapeList[i]
            local offsetX = {shapeData.xMin, shapeData.xMax}
            local offsetY = {shapeData.yMin, shapeData.yMax}
            buildingOffsetList[shapeData.id] = {[1] = offsetX, [2] = offsetY}
            buildingShapeList[shapeData.id] = string.format("%dx%d", shapeData.xMax - shapeData.xMin + 1, shapeData.yMax - shapeData.yMin + 1)
		end
        --[[for i = 1, objectShapeList.Length do
            local shapeData = objectShapeList[i - 1]
            local offsetX = {shapeData.xMin, shapeData.xMax}
            local offsetY = {shapeData.yMin, shapeData.yMax}
            buildingOffsetList[shapeData.id] = {[1] = offsetX, [2] = offsetY}
            buildingShapeList[shapeData.id] = string.format("%dx%d", shapeData.xMax - shapeData.xMin + 1, shapeData.yMax - shapeData.yMin + 1)
        end]]
    end
    return buildingOffsetList[shapeId]
end

function GetBuildingShape(shapeId)
    if buildingShapeList == nil then
        GetBuildingOffset(shapeId)
    end
    return buildingShapeList[shapeId]
end

function GetData()
    return worldMapData
end

local function PosToDataIndex(pos)
    return pos.y * 512 + pos.x + 1
end

local function XYToDataIndex(x, y)
    return y * 512 + x + 1
end

local function SetTileData(tileData)
    local pos = tileData.data.pos
    local dataIndex = PosToDataIndex(pos)
    tileList[dataIndex] = tileData
    local entryType = tileData.data.entryType
    local blockId = tileData.data.posblockid
    if blockId ~= 0 then
        local buildingOffset = GetBuildingOffset(blockId)
        local offsetX = buildingOffset[1]
        local offsetY = buildingOffset[2]
        for x = offsetX[1], offsetX[2] do
            for y = offsetY[1], offsetY[2] do
                if x ~= 0 or y ~= 0 then
                    tileList[XYToDataIndex(pos.x + x, pos.y + y)] = tileData
                end
            end
        end
    end
end

function SetData(data)
    worldMapData = data
    tileList = {}
    for i, v in ipairs(data) do
        for __, vv in ipairs(v.entrys) do
            SetTileData(vv)
        end
    end
end

function GetTileDataByIndex(dataIndex)
    if useTestData then
        local tileData = MapData_pb.SEntryData()
        tileData:MergeFrom(testData)
        local pos = tileData.data.pos
        pos.x = (dataIndex - 1) % 512
        pos.y = math.floor((dataIndex - 1) / 512)
        testData.home.name = "test"..pos.x..pos.y
        return tileData
    else
        return tileList[dataIndex]
    end
end

function GetTileDataByPos(pos)
    return GetTileDataByIndex(PosToDataIndex(pos))
end

function GetTileDataByXY(x, y)
    return GetTileDataByIndex(XYToDataIndex(x, y))
end

function GetMyBaseTileData()
    local myBasePos = MapInfoData.GetMyBasePos()
    return GetTileDataByPos(myBasePos)
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

function RemoveTileData(pos)
    local dataIndex = PosToDataIndex(pos)
    tileList[dataIndex] = nil
end

function UpdateTileData(tileData)
    SetTileData(tileData)
    -- NotifyListener()
end

function SetMyBaseTileData(tileData)
    -- local myBasePos = MapInfoData.GetMyBasePos()
    --  RemoveTileData(myBasePos)
    MapInfoData.SetMyBasePos(tileData.data.pos)
    --  UpdateTileData(tileData)
    
end

function RequestData(posIndex, lockScreen)
    local startX = posIndex % 32 - 1
    local startY = math.floor(posIndex / 32) - 1
    local req = MapMsg_pb.PosISceneEntrysInfoRequest()

    for x = 0, 2 do
        for y = 0, 2 do
            local posi = ((startY + y) % 32) * 32  + (startX + x) % 32
            req.posi:append(posi)
            if x == 1 and y == 1 then
                req.center = posi
            end
        end
    end
	
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.PosISceneEntrysInfoRequest, req, MapMsg_pb.PosISceneEntrysInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg.entry)
            NotifyListener()
        end
    end, not lockScreen)
end

function RequestAndSearchData(posIndex, searchCallback)
    local startX = posIndex % 32 - 1
    local startY = math.floor(posIndex / 32) - 1
    local req = MapMsg_pb.PosISceneEntrysInfoRequest()

    for x = 0, 2 do
        for y = 0, 2 do
            local posX = startX + x
            local posY = startY + y
            if posX >= 0 and posX < 32 and posY >= 0 and posY < 32 then
                local posi = posY * 32 + posX
                req.posi:append(posi)
            end
            if x == 1 and y == 1 then
                req.center = ((startY + y) % 32) * 32  + (startX + x) % 32
            end
        end
    end
	
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.PosISceneEntrysInfoRequest, req, MapMsg_pb.PosISceneEntrysInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            searchCallback(msg.entry)
        end
    end, false)
end

function RequestCreateMonster(level, callback)
    local req = MapMsg_pb.ClientCreateEntryRequest()
    req.entrytype = Common_pb.SceneEntryType_Monster 
    req.level = level

    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.ClientCreateEntryRequest, req, MapMsg_pb.ClientCreateEntryResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            local entry = msg.entry
            UpdateTileData(entry)
            callback(entry.data.pos)
        else
            print("引导生产野怪错误,指向主基地!!!!!!!!!!!!!!!!!")
            callback(MapInfoData.GetData().mypos)
            Global.ShowError(msg.code)
        end
    end, false)
end

function RequestCreateResource(entryType, num, callback)
    local req = MapMsg_pb.ClientCreateEntryRequest()
    req.level = 1
    req.entrytype = entryType
    req.num = num

    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.ClientCreateEntryRequest, req, MapMsg_pb.ClientCreateEntryResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            local entry = msg.entry
            UpdateTileData(entry)
            callback(entry.data.pos)
        else
            print("引导生产野怪错误,指向主基地!!!!!!!!!!!!!!!!!")
            callback(MapInfoData.GetData().mypos)
            Global.ShowError(msg.code)
        end
    end, false)
end

function RequestSceneEntryInfoFresh(entryUid, mapX, mapY, callback)
	local req = MapMsg_pb.SceneEntryInfoFreshRequest()
	req.entryUid = entryUid
	req.pos.x = mapX
	req.pos.y = mapY
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneEntryInfoFreshRequest, req, MapMsg_pb.SceneEntryInfoFreshResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            callback(msg.entry)
        else
            Global.ShowError(msg.code)
        end
    end, false)
end
