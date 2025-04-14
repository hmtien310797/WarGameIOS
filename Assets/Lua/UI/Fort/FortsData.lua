module("FortsData", package.seeall)

local forts = {}
local fortHistory = {}

local config
local status = 0

local isRequesting = {}

function GetFortData(subType)
return nil
	--return forts[subType]
end

function GetFortActConfig()
    return config
end

function GetFortStatus()
    return status
end

function GetFortsData()
	return forts
end

function GetContendStartTime()
	return config and config.contendStartTime or 0
end

function GetOwnerGuildID(subType)
	return forts[subType].occupyInfo and forts[subType].occupyInfo.ownerInfo and forts[subType].occupyInfo.ownerInfo.guildId or 0
end

function GetOwnerGuildBanner(subType)
	return forts[subType].occupyInfo and forts[subType].occupyInfo.ownerInfo and forts[subType].occupyInfo.ownerInfo.guildBanner or ""
end

function GetOwnerGuildName(subType)
	return forts[subType].occupyInfo and forts[subType].occupyInfo.ownerInfo and forts[subType].occupyInfo.ownerInfo.guildName or ""
end

function GetOwnerGuildBadge(subType)
	return forts[subType].occupyInfo and forts[subType].occupyInfo.ownerInfo and forts[subType].occupyInfo.ownerInfo.guildBadge or 0
end

function GetOccupyGuildNum(subType)
	return forts[subType].occupyInfo and forts[subType].occupyInfo.rankList and #forts[subType].occupyInfo.rankList or 0
end

function isAvailable(subType)
	return forts[subType] and forts[subType].available
end

function RequestFortData(subType, callback)
	--[[if not isRequesting.fortData then
		if status == 3 or status == 5 then
			isRequesting.fortData = true

			local request = MapMsg_pb.MsgSingleFortInfoRequest()
			request.subType = subType

			Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSingleFortInfoRequest, request, MapMsg_pb.MsgSingleFortInfoResponse, function(msg)
				isRequesting.fortData = false

				if msg.code == ReturnCode_pb.Code_OK then			
					forts[subType] = msg.info
					config = msg.actConfig
					status = msg.status
					
					if callback then
						callback(forts[subType], config, status)
					end
				else
					Global.ShowError(msg.code)
				end
			end, true)
		elseif callback then
			callback(forts[subType], config, status)
		end
	end]]
end

function RequestFortHistoryData(subType, callback)
	--[[if not isRequesting.fortHistoryData then
		if fortHistory[subType] ~= nil then
			if callback then
				callback(fortHistory[subType])
			end
		else
			isRequesting.fortHistoryData = true

			local request = MapMsg_pb.MsgSingleFortHistoryOwnerRequest()
			request.subType = subType
			Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSingleFortHistoryOwnerRequest, request, MapMsg_pb.MsgSingleFortHistoryOwnerResponse, function(msg)
				isRequesting.fortHistoryData = false

				if msg.code == ReturnCode_pb.Code_OK then
					local reversedOwnerList = {}
					for i = 1, #msg.ownerList do
						reversedOwnerList[i] = table.remove(msg.ownerList)
					end

					fortHistory[subType] = reversedOwnerList
					
					if callback then
						callback(fortHistory[subType])
					end
				else
					Global.ShowError(msg.code)
				end
			end, true)
		end
	end]]
end

function RequestFortsData(callback)
--[[
	if status == 0 or status == 3 or status == 5 then
		local request = MapMsg_pb.MsgFortActInfoRequest()
		Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortActInfoRequest, request, MapMsg_pb.MsgFortActInfoResponse, function(msg)
			if msg.code == ReturnCode_pb.Code_OK then
				forts = {}
				for _, fort in ipairs(msg.infos) do
					forts[fort.subType] = fort
				end

				config = msg.actConfig
				status = msg.status
				
				if callback then
					callback(forts, config, status)
				end
			else
				Global.ShowError(msg.code)
			end
		end, true)
	elseif callback then
		callback(forts, config, status)
	end
	]]
end

local function RefreshFortIcon()
	local now = Serclimax.GameTime.GetSecTime()
	
end

function OnFortStatusUpdate(typeId, package)
	local msg = MapMsg_pb.MsgFortActStatusPush()
	msg:ParseFromString(package)

	if status == 2 then -- 预告 -> 争夺
		status = msg.status
		MainCityUI.UpdateFortIcon(true)
	elseif status == 3 then -- 争夺 -> 占领
		MainCityUI.UpdateFortIcon(false)

		fortHistory = {}
		RequestFortsData(FortInfo.Refresh)
	elseif status == 4 then -- 新一轮
		status = 5
		RequestFortsData(function()
			CountDown.Instance:Remove("FortIcon")
			FortInfo.Refresh()
		end)
	else
		status = msg.status
		FortInfo.Refresh()
	end
end

function Initialize()
	RequestFortsData(function(forts, config, status)
		MainCityUI.UpdateFortIcon(status == 3)
	end)
end
