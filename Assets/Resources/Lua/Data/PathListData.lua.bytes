module("PathListData", package.seeall)
local pathListData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr
local random = math.random

--性能测试
local useTestData = false
local testPathCount = 200

function GetData()
    return pathListData
end

function Sort1()
    local charId = MainData.GetCharId()
    table.sort(pathListData, function(v1, v2)
        if v1.charid == charId and v2.charid ~= charId then
            return true
        elseif v1.charid ~= charId and v2.charid == charId then
            return false
        else
            return v1.pathId < v2.pathId
        end
    end)
end

function SetData(data)
    pathListData = data
    if useTestData and #pathListData > 0 then
        local testPathData = pathListData[1]
        local testSourcePos = testPathData.sourcePos
        local testTargetPos = testPathData.targetPos
        for i = 1, testPathCount do
            local pathData = pathListData:add()
            if random(2) == 1 then
                pathData.charid = MainData.GetCharId()
            else
                pathData.charid = 0
            end
            pathData:MergeFrom(testPathData)
            local sourcePos = pathData.sourcePos
            local targetPos = pathData.targetPos
            sourcePos.x = testSourcePos.x + random(20) - 10
            sourcePos.y = testSourcePos.y + random(10) - 5
            targetPos.x = testSourcePos.x + random(20) - 10
            targetPos.y = testSourcePos.y + random(10) - 5
        end
    end
    Sort1()
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

function GetPathData(pathId)
    for _, v in ipairs(pathListData) do
        if v.pathId == pathId then
            return v
        end
    end
end

function UpdatePathData(pathData)
    local newPath = true
    for i, v in ipairs(pathListData) do
        if v.pathId == pathData.pathId then
            newPath = false
            pathListData[i] = pathData
        end
    end

    if newPath then
        pathListData:add()
        pathListData[#pathListData] = pathData
    end

    NotifyListener()
end

function RequestData(posIndex, lockScreen)
    local startX = posIndex % 32 - 1
    local startY = math.floor(posIndex / 32) - 1
    local req = MapMsg_pb.SceneMapPathInfoRequest()

    for x = 0, 2 do
        for y = 0, 2 do
            local posi = ((startY + y) % 32) * 32  + (startX + x) % 32
            req.posi:append(posi)
        end
    end

    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapPathInfoRequest, req, MapMsg_pb.SceneMapPathInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg.path)
            NotifyListener()
        end
    end, not lockScreen)
end
