module("ActivityLevelRaceData", package.seeall)
local levelRaceData = {}
local eventListener = EventListener()
local GameTime = Serclimax.GameTime

local TableMgr = Global.GTableMgr
local requestTimer

local isNew = false
local isActived = false

function NotifyAvailable()
    isNew = true
end

function NotifyUIOpened()
    isActived = false
    if isNew then
        isNew = false
        MainCityUI.UpdateActivityAllNotice(102)
    end
end

function GetData()
    return levelRaceData
end

function SetData(data)
    levelRaceData = data
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

function IsActive()
 
end

function RequestRankDetail(level , cb)
	local req = ActivityMsg_pb.MsgUserUpRankRankListRequest();
	req.level = level
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgUserUpRankRankListRequest, req, ActivityMsg_pb.MsgUserUpRankRankListResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.FloatError(msg.code)
		else
			Global.DumpMessage(msg , "d:/activity.lua")
			if cb then
				cb(msg)
			end
		end
    end, unlockScreen)
end

function RequestData(unlockScreen , cb)
    local req = ActivityMsg_pb.MsgListUserUpRankListRequest();
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgListUserUpRankListRequest, req, ActivityMsg_pb.MsgListUserUpRankListResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.FloatError(msg.code)
		else
			SetData(msg)
			Global.DumpMessage(msg , "d:/activity.lua")
			if cb then
				cb()
			end
		end
    end, unlockScreen)
end

local function UpdateReward(lv)
	if levelRaceData == nil then
		return
	end
	
	for i=1 , #levelRaceData.lvinfo do
		if levelRaceData.lvinfo[i].level == lv then
			levelRaceData.lvinfo[i].got = true
		end
	end
end

function RequestReward(lv , cb)
	local req = ActivityMsg_pb.MsgUserUpRankRewardRequest();
	req.level = lv
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgUserUpRankRewardRequest, req, ActivityMsg_pb.MsgUserUpRankRewardResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.FloatError(msg.code)
		else
			MainCityUI.UpdateRewardData(msg.fresh)
			Global.ShowReward(msg.reward)
			UpdateReward(lv)
			Global.DumpMessage(msg , "d:/activity.lua")
			if cb then
				cb(msg)
			end
		end
	end, true)
end

function SetRewarded(index)
  
end


function GetLocationRank()
	if levelRaceData == nil or levelRaceData.lvinfo == nil then
		return 0
	end 
	
	local baseLv = maincity.GetBuildingLevelByID(1)
	for i=1 , #levelRaceData.lvinfo do
		local rank = levelRaceData.lvinfo[i]
		if (not rank.got) and  (rank.myrank > 0) then
			return i
		end
	end
	
	for i=1 , #levelRaceData.lvinfo do
		local rank = levelRaceData.lvinfo[i]
		if baseLv < rank.level then
			return math.max(i - 1 , 1)
		end
	end
	
	return (#levelRaceData.lvinfo)
end	

function HasNotice()
    if isNew then
        return true
    end
	if levelRaceData == nil or levelRaceData.lvinfo == nil then
		return false
	end
	
	for i=1 , #levelRaceData.lvinfo do
		local rank = levelRaceData.lvinfo[i]
		if (not rank.got) and (rank.myrank > 0) then
			return true
		end
	end
	
    return false
end
