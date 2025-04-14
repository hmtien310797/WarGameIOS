module("RebelData", package.seeall)
local TableMgr = Global.GTableMgr
local eventListener = EventListener()
local rebelData
local stepReward
local activityInfo

function GetData()
    return rebelData
end

function SetData(data)
    rebelData = data
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

function GetStepReward()
	return stepReward
end

function GetActivityInfo()
	return activityInfo
end

function RequestData(callback)
    local req = MapMsg_pb.ActMonsterInfoRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.ActMonsterInfoRequest, req, MapMsg_pb.ActMonsterInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	SetData(msg)
            NotifyListener()

            if callback ~= nil then
                callback()
            end
        end
    end, false)
end

function RequestSearch(callback)
	local req = MapMsg_pb.SearchActMonsterRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SearchActMonsterRequest, req, MapMsg_pb.SearchActMonsterResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	MainCityUI.UpdateRewardData(msg.fresh)
        	if callback ~= nil then
        		callback(msg.monsDetail)
        	end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestStepReward(callback)
	if stepReward ~= nil then
		if callback ~= nil then
			callback(stepReward)
			return
		end
	end
	local req = MapMsg_pb.ActMonsterStepRewardRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.ActMonsterStepRewardRequest, req, MapMsg_pb.ActMonsterStepRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	stepReward = msg.stepRewards
        	if callback ~= nil then
				callback(stepReward)
			end
        end
    end, true)
end

function RequestActivityInfo()
	activityInfo = {}
	activityInfo.searchSta = TableMgr:GetActMonsterData(DataEnum.ScActMonsterId.ActMonsterSearchSta).value
	activityInfo.actSta = TableMgr:GetActMonsterData(DataEnum.ScActMonsterId.ActMonsterActSta).value
	activityInfo.unionSta = TableMgr:GetActMonsterData(DataEnum.ScActMonsterId.ActMonsterActFriend).value
	activityInfo.massSta = TableMgr:GetActMonsterData(DataEnum.ScActMonsterId.ActMonsterMassSta).value
	activityInfo.headIcon = TableMgr:GetActMonsterData(DataEnum.ScActMonsterId.ActMonsterHeadIcon).value
end
