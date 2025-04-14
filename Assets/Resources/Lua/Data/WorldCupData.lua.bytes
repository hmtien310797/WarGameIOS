module("WorldCupData", package.seeall)
local worldCupData
local betInfoMap
local eventListener = EventListener()
local TableMgr = Global.GTableMgr

function GetData()
    return worldCupData
end

function GetBetInfoMap()
    return betInfoMap
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

local BetEventListener = EventListener()
local function NotifyBetListener()
    BetEventListener:NotifyListener()
end

function AddBetListener(listener)
    BetEventListener:AddListener(listener)
end

function RemoveBetListener(listener)
    BetEventListener:RemoveListener(listener)
end

function RefrushBetInfoMap(betInfo)
	if betInfoMap == nil then
		return
	end
	if betInfoMap[betInfo.matchId] == nil then
		betInfoMap[betInfo.matchId] = {}
	end
	if betInfoMap[betInfo.matchId][betInfo.teamId] == nil then
		betInfoMap[betInfo.matchId][betInfo.teamId] = {}
	end
	betInfoMap[betInfo.matchId][betInfo.teamId] = betInfo
end

function SetData(data,notify)
	worldCupData = data
	betInfoMap = {}
	for i=1,#worldCupData.betInfo do
		RefrushBetInfoMap(worldCupData.betInfo[i])
	end
	if notify then
		NotifyListener()
	end
end


function ReqMsgGuessActGetInfo(cb , notify)
	local req = ActivityMsg_pb.MsgGuessActGetInfoRequest();
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgGuessActGetInfoRequest,req, ActivityMsg_pb.MsgGuessActGetInfoResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
		   SetData(msg , notify)
            if cb ~= nil then
                cb(msg)
            end
        end
    end, true)
end

function ReqMsgGuessActMatchBet(match_id,team_id,bet_value,cb)
	local req = ActivityMsg_pb.MsgGuessActMatchBetRequest();
	print(match_id,team_id,bet_value)
	req.matchId = match_id
	req.teamId = team_id
	req.betValue = bet_value
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgGuessActMatchBetRequest,
	 req, ActivityMsg_pb.MsgGuessActMatchBetResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			for i =1,#msg.betInfo do
				RefrushBetInfoMap(msg.betInfo[i])
			end			
			MainCityUI.UpdateRewardData(msg.fresh)
			NotifyBetListener()
            if cb ~= nil then
                cb(msg)
            end
        end
    end, true)
end