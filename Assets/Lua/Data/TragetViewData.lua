module("TragetViewData", package.seeall)

local TableMgr = Global.GTableMgr
local eventListener = EventListener()

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

local TragetTypeList

local TragetListMap

local function ExCallBack(callback,param)
    if callback ~= nil then
        callback(param)
    end
end

local function CreateTraget(MapSignInfo)
    local traget = {}
    traget.msg = MapSignInfo
    traget.pos_tag = traget.msg.pos.x..":"..traget.msg.pos.y
    return traget
end

local function AddTraget(traget)
    if traget == nil then
        return 
    end    
    print(traget.pos_tag,traget.msg.type,traget.msg.name)
    if TragetListMap == nil then
        TragetListMap = {}
        TragetTypeList = {}
    end
    if TragetListMap[traget.pos_tag] ~= nil then
        local old_traget = TragetListMap[traget.pos_tag]
        if TragetTypeList[old_traget.msg.type][old_traget.pos_tag] ~= nil then
            TragetTypeList[old_traget.msg.type][old_traget.pos_tag] = nil
        end
    end
    TragetListMap[traget.pos_tag] = traget
    if TragetTypeList[traget.msg.type] == nil then
        TragetTypeList[traget.msg.type] = {}
    end
    TragetTypeList[traget.msg.type][traget.pos_tag] = traget
end

local function RemoveTraget(pos_tag)
    if pos_tag == nil then
        return 
    end
    
    if TragetListMap == nil then
        return
    end
    
    if TragetListMap[pos_tag] == nil then
        return
    end    
    local traget = TragetListMap[pos_tag]
    TragetListMap[traget.pos_tag] = nil 
    if TragetTypeList[traget.msg.type] == nil then
        return 
    end
    TragetTypeList[traget.msg.type][traget.pos_tag] = nil
end


local function SetData(msg)
    TragetListMap = nil
    for i =1,#msg.infos,1 do
        
        local traget = CreateTraget(msg.infos[i])
        AddTraget(traget)
    end
end

function GetTragetMap()
    return TragetListMap
end

function HasTraget(x,y)
    if TragetListMap == nil then
        return false
    end
    return TragetListMap[x..":"..y] ~= nil 
end

function GetTragetTypeList()
    return TragetTypeList
end

function RequestAddTraget(type,name,x,y,callback)
    local req = MapMsg_pb.SceneMapSignAddRequest()
    req.info.type = type
    req.info.name = name
    req.info.pos.x = x
    req.info.pos.y = y
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapSignAddRequest, req, MapMsg_pb.SceneMapSignAddResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            local traget = CreateTraget(msg.info)
            AddTraget(traget)
            NotifyListener()
            ExCallBack(callback,true)
        else
            ExCallBack(callback,false)
            Global.FloatError(msg.code, Color.white)
        end
    end, true)    
end

function RequestDelTraget(x,y,callback)
    local req = MapMsg_pb.SceneMapSignDelRequest()
    req.pos.x = x
    req.pos.y = y
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapSignDelRequest, req, MapMsg_pb.SceneMapSignDelResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            RemoveTraget(x..":"..y)
            NotifyListener()
            ExCallBack(callback,true)
        else
            ExCallBack(callback,false)
            Global.FloatError(msg.code, Color.white)
        end
    end, true)    
end

function RequestListTraget(callback)
    local req = MapMsg_pb.SceneMapSignListRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapSignListRequest, req, MapMsg_pb.SceneMapSignListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            NotifyListener()
            ExCallBack(callback,true)
        else
            ExCallBack(callback,false)
            Global.FloatError(msg.code, Color.white)
        end
    end, true) 
end
