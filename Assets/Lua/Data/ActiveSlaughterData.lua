module("ActiveSlaughterData", package.seeall)
local activeSlaughterData
local eventListener = EventListener()
local TableMgr = Global.GTableMgr

function GetData()
    return activeSlaughterData
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


function SetData(data,notify)
    activeSlaughterData = data
	if notify then
		NotifyListener()
	end
end


function ReqMsgSlaughterGetInfo(cb , notify)
	local req = ActivityMsg_pb.MsgSlaughterGetInfoRequest();
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSlaughterGetInfoRequest,req, ActivityMsg_pb.MsgSlaughterGetInfoResponse, function(msg)
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

function MergeFromInfo(info)
	if activeSlaughterData ~= nil then
		activeSlaughterData.selfInfo.score = info.score
		for i = 1,#activeSlaughterData.selfInfo.reward do
			if info.reward[i] ~= nil then
				activeSlaughterData.selfInfo.reward[i].index = info.reward[i].index
				activeSlaughterData.selfInfo.reward[i].needScroe = info.reward[i].needScroe
				activeSlaughterData.selfInfo.reward[i].dropId = info.reward[i].dropId
				activeSlaughterData.selfInfo.reward[i].isReward = info.reward[i].isReward
			end
		end
	end
end

function ReqMsgSlaughterGetReward(index,cb)
	local req = ActivityMsg_pb.MsgSlaughterGetRewardRequest();
	req.index = index
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSlaughterGetRewardRequest,
	 req, ActivityMsg_pb.MsgSlaughterGetRewardResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			--activeSlaughterData.selfInfo:MergeFrom(msg.info)
			MergeFromInfo(msg.info)
            if cb ~= nil then
                cb(msg)
            end
        end
    end, true)
end

function OnMsgSlaughterFreshPush(msg)
	--if activeSlaughterData ~= nil then
	--	print("RRRRRRRRRRRRRRRRRRRRRR,",msg.info,activeSlaughterData.selfInfo)
	--	activeSlaughterData.selfInfo:MergeFrom(msg.info)
	--end
	
	MergeFromInfo(msg.info)
	PVP_ATK_Activity.SetupReward()
end

function ReqMsgSlaughterGetRankInfo(cb)
	local req = ActivityMsg_pb.MsgSlaughterGetRankInfoRequest();
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSlaughterGetRankInfoRequest,
	 req, ActivityMsg_pb.MsgSlaughterGetRankInfoResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
            if cb ~= nil then
                cb(msg)
            end
        end
    end, true)
end

function UserRankListRequest(callback)
	local req = ClientMsg_pb.MsgUserRankListRequest()
	req.rankType = 10
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserRankListRequest, req, ClientMsg_pb.MsgUserRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
            	callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local function GetPVPATKRewards()
	local rewards = {}
    local data = TableMgr:GetPVPATK(101)
    if data == nil then
        return 
	end
	for i=1,100 do
		rewards[i] = {}
		rewards[i].id = i
		rewards[i].rewardType = 1
		rewards[i].order = i
		if i == 1 then
			rewards[i].awardShow = data.show1
		elseif i == 2 then
			rewards[i].awardShow = data.show2
		elseif i == 3 then
			rewards[i].awardShow = data.show3
		elseif i>=4 and i<=10 then
			rewards[i].awardShow = data.show4
		elseif i>=11 and i<=20 then
			rewards[i].awardShow = data.show5
		elseif i>=21 and i<=50 then
			rewards[i].awardShow = data.show6
		elseif i>=51 and i<=100 then
			rewards[i].awardShow = data.show7
		end
	end

	return rewards
end

function GetPersonRankReward()
	local reward = {}
	local mr = GetPVPATKRewards()
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