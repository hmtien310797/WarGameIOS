module("RebelArmyAttackData", package.seeall)
local TableMgr = Global.GTableMgr
local siegeNumber = -1
local reward

local isNew = false

local SiegeMonsterInfo

function GetSiegeMonsterInfo()
	return SiegeMonsterInfo
end

function NotifyAvailable()
	isNew = true
end

function NotifyUIOpened()
	if isNew then
		isNew = false
		MainCityUI.UpdateActivityAllNotice(107)
	end
end

function HasNotice()
	return isNew
end

function GetRewardData(_siegeNumber)
	if siegeNumber ~= _siegeNumber then
		siegeNumber = _siegeNumber
		reward = {}
		local mr = TableMgr:GetActivitySiegeMonsterReward(siegeNumber == 0 and 1 or siegeNumber)
		for i = 1, #mr do
			reward[i] = mr[i]
			reward[i].awardlist = {}
			local award = TableMgr:GetDropShowData(reward[i].awardShow)
			for ii = 1, #award do
				reward[i].awardlist[ii] = award[ii]
			end
		end
	end
	return reward
end

function GetMaxWave(_siegeNumber)
	return TableMgr:GetActivitySiegeMonsterMaxWave(_siegeNumber == 0 and 1 or _siegeNumber)
end

function GetPersonRankReward()
	local reward = {}
	local mr = TableMgr:GetActivitySiegeMonsterRankRewardByType(1)
	for i = 1, #mr do
		reward[i] = mr[i]
		reward[i].awardlist = {}
		local award = TableMgr:GetDropShowData(reward[i].awardShow)
		for ii = 1, #award do
			reward[i].awardlist[ii] = award[ii]
		end
	end
	return reward
end

function GetUnionRankReward()
	local reward = {}
	local mr = TableMgr:GetActivitySiegeMonsterRankRewardByType(2)
	for i = 1, #mr do
		reward[i] = mr[i]
		reward[i].awardlist = {}
		local award = TableMgr:GetDropShowData(reward[i].awardShow)
		for ii = 1, #award do
			reward[i].awardlist[ii] = award[ii]
		end
	end
	return reward
end

function RequestSiegeMonsterSearch(callback)
	local req = MapMsg_pb.MsgSiegeMonsterSearchRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSiegeMonsterSearchRequest, req, MapMsg_pb.MsgSiegeMonsterSearchResponse, function(msg)
        if callback ~= nil then
            callback(msg)
        end
    end, false)
end

function RequestSiegeMonsterInfo(callback)
	local req = MapMsg_pb.MsgSiegeMonsterInfoRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSiegeMonsterInfoRequest, req, MapMsg_pb.MsgSiegeMonsterInfoResponse, function(msg)
		SiegeMonsterInfo = msg
        if callback ~= nil then
            callback(msg)
        end
    end, true)
end

function RequestSiegeMonsterStart(uid, callback)
	local req = MapMsg_pb.MsgSiegeMonsterStartRequest()
	req.uid = uid
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSiegeMonsterStartRequest, req, MapMsg_pb.MsgSiegeMonsterStartResponse, function(msg)
        if callback ~= nil then
            callback(msg)
        end
    end, false)
end

function RequestSiegeMonsterUserRankList(callback)
	local req = MapMsg_pb.MsgSiegeMonsterUserRankListRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSiegeMonsterUserRankListRequest, req, MapMsg_pb.MsgSiegeMonsterUserRankListResponse, function(msg)
        if callback ~= nil then
            callback(msg)
        end
    end, false)
end

function RequestSiegeMonsterGuildRankList(callback)
	local req = MapMsg_pb.MsgSiegeMonsterGuildRankListRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSiegeMonsterGuildRankListRequest, req, MapMsg_pb.MsgSiegeMonsterGuildRankListResponse, function(msg)
        if callback ~= nil then
            callback(msg)
        end
    end, false)
end

function RequestSiegeMonsterRankList(_type, callback)
	if _type == 1 then
		RequestSiegeMonsterUserRankList(callback)
	else
		RequestSiegeMonsterGuildRankList(callback)
	end
end

function RequestSiegeMonsterScoreInfo(callback)
	local req = MapMsg_pb.MsgSiegeMonsterScoreInfoRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSiegeMonsterScoreInfoRequest, req, MapMsg_pb.MsgSiegeMonsterScoreInfoResponse, function(msg)
        if callback ~= nil then
            callback(msg)
        end
    end, false)
end
