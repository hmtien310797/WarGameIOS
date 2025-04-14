module("NewRaceData", package.seeall)
local raceData, raceRank
local eventListener = EventListener()
local GameTime = Serclimax.GameTime

local TableMgr = Global.GTableMgr

local isNew = false
local curActId

function GetData()
    return raceData
end

function GetRank()
    return raceRank
end

function SetData(data)
    raceData = data.userrace
    raceRank = data.userrank
    if curActId == nil then
        curActId = raceData.actId
    else
        if curActId ~= raceData.actId then
            curActId = raceData.actId
            ActivityAll.NotifyActivityUnavailable(111)
        end
    end
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function NotifyAvailable()
	isNew = true
end

function NotifyUIOpened()
	if isNew then
		isNew = false
		NotifyListener()
	end
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function RequestData(unlockScreen)
    local req = ClientMsg_pb.MsgGetMilitaryRaceListRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetMilitaryRaceListRequest, req, ClientMsg_pb.MsgGetMilitaryRaceListResponse, function(msg)
        SetData(msg)
        NotifyListener()
    end, unlockScreen)
end

function GetRaceDataByActId(actId)
    if raceData ~= nil then
        for i, v in ipairs(raceData.dayRace) do
            if v.actId == actId then
                return v
            end
        end
    end
end

local function SetReward(actId, index)
    if raceData ~= nil then
        for i, v in ipairs(raceData.dayRace) do
            if v.actId == actId then
                for ii, vv in ipairs(v.reward) do
                    if vv.index == index then
                        vv.isReward = true
                    end
                end
            end
        end
    end
end

function HasNotice()
    if isNew then
        return true
    end
    if raceData ~= nil then
        for i, v in ipairs(raceData.dayRace) do
            if v.actId == curActId then
                local score = v.score
                for ii, vv in ipairs(v.reward) do
                    if vv. needScore <= score and not vv.isReward then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function RequestGetMilitaryRaceReward(actId, index)
    local req = ClientMsg_pb.MsgGetMilitaryRaceRewardRequest()
    req.actId = actId
    req.index = index
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetMilitaryRaceRewardRequest, req, ClientMsg_pb.MsgGetMilitaryRaceRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetReward(actId, index)
            MainCityUI.UpdateRewardData(msg.fresh)
            Global.ShowReward(msg.reward)
            NotifyListener()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestGetMilitaryRaceRank(callback)
    local req = ClientMsg_pb.MsgGetMilitaryRaceRankRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetMilitaryRaceRankRequest, req, ClientMsg_pb.MsgGetMilitaryRaceRankResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestGetMilitaryRaceTotRank(callback)
    local req = ClientMsg_pb.MsgGetMilitaryRaceTotRankRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetMilitaryRaceTotRankRequest, req, ClientMsg_pb.MsgGetMilitaryRaceTotRankResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestGetMilitaryStrongest(callback)
    local req = ClientMsg_pb.MsgGetMilitaryStrongestRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetMilitaryStrongestRequest, req, ClientMsg_pb.MsgGetMilitaryStrongestResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end