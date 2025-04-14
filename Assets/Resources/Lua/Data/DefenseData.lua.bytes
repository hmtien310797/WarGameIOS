module("DefenseData", package.seeall)
local defenseData
local TextMgr = Global.GTextMgr
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return defenseData
end

function SetData(data)
    defenseData = data
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

function RequestData()
    local req = ClientMsg_pb.MsgGetCityGuardRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetCityGuardRequest, req, ClientMsg_pb.MsgGetCityGuardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            NotifyListener()            
        else
            Global.ShowError(msg.code)
        end
    end, true)
end

function UpdateDefenseData(data)
    defenseData.cginfo:MergeFrom(data)
    NotifyListener()            
end

function IsNeedRepair()
    if defenseData.cginfo.fireing then
        return false
    end

    local buildingLevel = maincity.GetBuildingByID(26).data.level
    local maxDefense = tableData_tWallData.data[buildingLevel].WallDefence 

    if defenseData.cginfo.culval >= maxDefense then
        return false
    end

    local repairInterval = tonumber(tableData_tGlobal.data[100220].value)
    local serverTime = Serclimax.GameTime.GetSecTime()
    if serverTime < defenseData.cginfo.lastRepairTime + repairInterval then
        return false
    end

    return true
end
