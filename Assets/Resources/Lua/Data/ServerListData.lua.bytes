module("ServerListData", package.seeall)
local serverListData = {}
local eventListener = EventListener()
local GameTime = Serclimax.GameTime

local TableMgr = Global.GTableMgr 
function GetData()
    return serverListData
end

function SetData(data)
    serverListData = data
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
    local req = LoginMsg_pb.MsgLoginGetZoneListInfo_CS()
    req.exeVersion = GameVersion.EXE
    req.resVersion = GameVersion.RES
    Global.Request(Category_pb.Login, LoginMsg_pb.LoginTypeId.MsgLoginGetZoneListInfo_CS, req, LoginMsg_pb.MsgLoginGetZoneListInfo_SC, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code , GameStateLogin.Instance:ReLogin())
        else
			SetData(msg)
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function GetCountryZoneData(zoneId)
    for _, v in ipairs(serverListData.areaCountry) do
        for __, vv in ipairs(v.data) do
            for ___, vvv in ipairs(vv.data) do
                if vvv.zone == zoneId then
                    return v, vv, vvv
                end
            end
        end
    end
end

function GetAllZoneData(zoneId)
    local allAreaMsg = serverListData.allAreaInfo
    for i, v in ipairs(allAreaMsg) do
        for ii, vv in ipairs(v.zonelist) do
            if vv.zoneId == zoneId then
                return vv
            end
        end
    end
end

function GetCountryData(countryIndex)
    return serverListData.areaCountry[countryIndex]
end

function HasCountryData(index)
    return GetCountryData(index) ~= nil
end

function GetMyAreaData()
    return serverListData.myAreaInfo
end

function GetAllAreaData()
    return serverListData.allAreaInfo
end

function GetAreaCountryData(areaIndex)
    return serverListData.areaCountry[areaIndex]
end

function GetMyZoneData(zoneId)
    for _, v in ipairs(serverListData.myAreaInfo) do
        for __, vv in ipairs(v.zonelist) do
            if vv.zoneId == zoneId then
                return vv
            end
        end
    end
end

function GetAreaData(zoneId)
    local allAreaMsg = serverListData.allAreaInfo
    for i, v in ipairs(allAreaMsg) do
        for ii, vv in ipairs(v.zonelist) do
            if vv.zoneId == zoneId then
                return v
            end
        end
    end
end

function GetMyZoneIdAtCountry(countryMsg)
    for _, v in ipairs(countryMsg) do
        for __, vv in ipairs(v.zonelist) do
            for ___, vvv in ipairs(countryMsg.data) do
                for ____, vvvv in ipairs(vvv.data) do
                    if vvvv.zone == vv.zoneId then
                        return vv.zoneId
                    end
                end
            end
        end
    end
end

function GetCurrentZoneId()
    return Global.GGameStateLogin:GetZoneId()
end

function GetCurrentZoneName()
    return GetAllZoneData(GetCurrentZoneId()).zoneName
end

function GetCurrentAreaId()
	local currentZoneId = GetCurrentZoneId()
	local areaMsg = GetAreaData(currentZoneId)
    return areaMsg and areaMsg.areaId or 0
end

function IsAppleReviewing()
    return #serverListData.allAreaInfo == 1 and serverListData.allAreaInfo[1].areaName == "review"
end
