module("MobaRadarData", package.seeall)

local RadarData
local DefendForm
local eventListener = EventListener()
local needwarning

local forceWarningType = nil

local function RequestCountDown()
	local _targettime = GetNearestTime()
	if _targettime > 0 then
		CountDown.Instance:Add("RadarCountDown", _targettime, function(t)
	    	if _targettime <= Serclimax.GameTime.GetSecTime() then
	    		RequestData()
	    		CountDown.Instance:Remove("RadarCountDown")
	    	end
	    end)
	else
		CountDown.Instance:Remove("RadarCountDown")
	end
end

local function NotifyListener()
    eventListener:NotifyListener()
    --RequestCountDown()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
	return RadarData
end

function SetData(_data)
	RadarData = _data
end

function GetDefendForm()
	return DefendForm
end

function SetDefendForm(form)
	DefendForm = form
end

function UpdateData(info)
	local isnew = true
	for i, v in ipairs(RadarData) do
		if v.se.pathId == info.se.pathId then
			isnew = false
			v = info
		end
	end
	if isnew then
		RadarData:add()
		RadarData[#RadarData] = info
	end
	NotifyListener()
end

function GetNearestTime()
	local nearesttime = -1
	if RadarData ~= nil and #RadarData > 0 then
		for i, v in ipairs(RadarData) do
			local endtime = v.se.starttime + v.se.time
			if nearesttime == -1 then
				nearesttime = endtime
			end
			if nearesttime > endtime then
				nearesttime = endtime
			end
		end
	end
	return nearesttime
end

function GetWarningType()
	local wtype = 0
	if RadarData ~= nil and #RadarData > 0 then
		for i, v in ipairs(RadarData) do
		    local pathType = v.se.pathType
			if v.se.status == 1 then
				local temptype = (pathType == 4 or pathType == 6 or pathType == 13) and 1 or 0
				temptype = (pathType == 1 or pathType == 5 or pathType == 8 or pathType == 9 or pathType == 11 or pathType == 12 or pathType == 15 or pathType == 22) and 2 or temptype
				if temptype > wtype then
					wtype = temptype
				end
			elseif v.se.status == -1 then
				if pathType == 22 then
					wtype = 1
				end
			end
		end
	end
	if forceWarningType ~= nil then
		return forceWarningType
	end
	return wtype
end

function IsPathToMe()
	return GetWarningType() == 2
end

function SetForceWarningType(_forceWarningType)
	forceWarningType = _forceWarningType
	NotifyListener()
end

function RequestData()
	if Global.GetMobaMode() == 1 then
		local req = MobaMsg_pb.MsgMobaViewPathInfoRequest()
		LuaNetwork.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaViewPathInfoRequest, req:SerializeToString(), function(typeId, data)
			local msg = MobaMsg_pb.MsgMobaViewPathInfoResponse ()
			msg:ParseFromString(data)
			if msg.code == 0 then
				needwarning = true
				SetData(msg.paths)
				--Global.DumpMessage(msg , "d:/MsgViewPathInfoResponse.lua")
				MobaBattleMoveData.GetOrReqUserDefendFormaion(function(form)
					DefendForm = form
				end)
				NotifyListener()
			end
		end, false)
	elseif Global.GetMobaMode() == 2 then
		local req = GuildMobaMsg_pb.GuildMobaViewPathInfoRequest()
		LuaNetwork.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaViewPathInfoRequest, req:SerializeToString(), function(typeId, data)
			local msg = GuildMobaMsg_pb.GuildMobaViewPathInfoResponse ()
			msg:ParseFromString(data)
			if msg.code == 0 then
				needwarning = true
				SetData(msg.paths)
				--Global.DumpMessage(msg , "d:/MsgViewPathInfoResponse.lua")
				MobaBattleMoveData.GetOrReqUserDefendFormaion(function(form)
					DefendForm = form
				end)
				NotifyListener()
			end
		end, false)
	end
end

function SetWarningOff()
	needwarning = false
end

function GetNeedWarning()
	return needwarning
end
