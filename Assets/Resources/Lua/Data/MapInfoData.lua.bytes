module("MapInfoData", package.seeall)
local mapInfoData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return mapInfoData
end

function SetData(data)
    mapInfoData = data
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

function SetMyBasePos(pos)
    mapInfoData.mypos.x = pos.x
    mapInfoData.mypos.y = pos.y
end

function GetMyBasePos()
    return mapInfoData.mypos
end

function HasBase()
    local pos = mapInfoData.mypos
    return pos.x ~= 0 or pos.y ~= 0
end

function RequestData(createHome , callback)
    local req = MapMsg_pb.SceneBaseInfoRequest()
    req.createHome = createHome or false
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneBaseInfoRequest, req, MapMsg_pb.SceneBaseInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
			if callback ~= nil then
				callback()
				
			end
        end
    end, true)
end

function CheckCreateBase()
    if not HasBase() then
        RequestData(true)
    end
end
