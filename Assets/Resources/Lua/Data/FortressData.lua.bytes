module("FortressData", package.seeall)
local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime
local TextMgr = Global.GTextMgr

local fortressData
local fortressActInfo
local fortressState
local openedSubtype = 0

----- Events -------------------------------------------
local eventOnRulingPush = EventDispatcher.CreateEvent()

function OnRulingPush()
	return eventOnRulingPush
end

local function BroadcastEventOnRulingPush(...)
	EventDispatcher.Broadcast(eventOnRulingPush, ...)
end
--------------------------------------------------------

function OpenFortressUI(subtype)
	openedSubtype = subtype
end

function CloseFortressUI(subtype)
	openedSubtype = 0
end

function GetAllFortressData()
	if fortressData == nil then
		fortressData = {}
	end
	return fortressData
end

function HasMyFortress()
    local myGuildId = UnionInfoData.GetGuildId()
    if myGuildId == 0 then
        return false
    end

    for _, v in ipairs(fortressData) do
        local guildId = v.rulingInfo.guildId
        if guildId == myGuildId then
            return true
        end
    end

    return false
end

function GetFortressData(subtype)
	if fortressData == nil then
		fortressData = {}
	end
	return fortressData[subtype];
end

function GetFortressState(subtype)
	if fortressState == nil then
		fortressState = {}
	end
	return fortressState[subtype] 
end

function GetFortressActInfo(subtype)
	if fortressActInfo == nil then
		fortressActInfo = {}
	end
	return fortressActInfo[subtype] 
end

function GetRulerGuildID(subtype)
	return GetFortressData(subtype).rulingInfo.guildId
end
function GetRulerGuildBanner(subtype)
	return GetFortressData(subtype).rulingInfo.guildBanner
end
function GetRulerGuildName(subtype)
	return GetFortressData(subtype).rulingInfo.guildName
end
function GetRulerGuildBadge(subtype)
	return GetFortressData(subtype).rulingInfo.guildBadge
end
function GetRulerGuildLang(subtype)
	return GetFortressData(subtype).rulingInfo.guildLang
end

function GetContendStartTime(subtype)
	return GetFortressData(subtype).contendStartTime
end
function GetContendEndTime(subtype)
	return GetFortressData(subtype).contendEndTime
end

function IsActive()
	if fortressState == nil then
		return false
	end
	for i, v in pairs(fortressState) do
		print(v)
		if v == 2 then
			return true
		end
	end
	return false
end

function GetAllEndTime()
	if fortressData == nil then
		return 0
	end
	local endtime = 0
	for i, v in pairs(fortressData) do
		if v.contendEndTime > endtime then
			endtime = v.contendEndTime
		end
	end
	return endtime
end


local fortressState_EL = EventListener()

local function NotifyStateListener()
    fortressState_EL:NotifyListener()
end

function AddStateListener(listener)
    fortressState_EL:AddListener(listener)
end

function RemoveStateListener(listener)
    fortressState_EL:RemoveListener(listener)
end

local function NotifyState(subtype,state,enable)
	if fortressState == nil then
		fortressState = {}
	end
	if fortressState[subtype] == state then
		return
	end
	fortressState[subtype] = state
	if enable then
		NotifyStateListener(subtype)
	end
end

--1 开始 2 进行 3.结束
function UpdateState(subtype,enable)
	if fortressActInfo[subtype] == nil then
		NotifyState(subtype,1,enable)
		return
	end
	print("UpdateState fortes",fortressActInfo[subtype].contendStartTime,fortressActInfo[subtype].contendEndTime,
	(GameTime.GetSecTime() > fortressActInfo[subtype].contendStartTime and GameTime.GetSecTime() < fortressActInfo[subtype].contendEndTime)and 2 or 1)
    if GameTime.GetSecTime() > fortressActInfo[subtype].contendStartTime and GameTime.GetSecTime() < fortressActInfo[subtype].contendEndTime then
        NotifyState(subtype,2,enable)
	elseif GameTime.GetSecTime() > fortressActInfo[subtype].contendEndTime then
		NotifyState(subtype,3,enable)
	else
		NotifyState(subtype,1,enable)
	end
end

function UpdateActInfo(subtype,contendStartTime,contendEndTime,enable)
	if fortressActInfo == nil then
		fortressActInfo = {}
	end
	fortressActInfo[subtype] = {}
	fortressActInfo[subtype].contendStartTime = contendStartTime
	fortressActInfo[subtype].contendEndTime = contendEndTime
	UpdateState(subtype,enable)
end


function ReqFortressData(subtype,callback)
	local req = MapMsg_pb.MsgFortressInfoRequest()
	req.subType = subtype;
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortressInfoRequest, req, MapMsg_pb.MsgFortressInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if fortressData == nil then
				fortressData = {}
			end

			fortressData[subtype] = msg.fortressInfo
			UpdateActInfo(subtype,fortressData[subtype].contendStartTime,fortressData[subtype].contendEndTime,true)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function ReqAllFortressInfoData(callback)
	local req = MapMsg_pb.MsgAllFortressInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgAllFortressInfoRequest, req, MapMsg_pb.MsgAllFortressInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if fortressData == nil then
				fortressData = {}
			end
			for i=1,#msg.infoList do
				local subtype = msg.infoList[i].subtype
				fortressData[subtype] = msg.infoList[i]
				UpdateActInfo(subtype,fortressData[subtype].contendStartTime,fortressData[subtype].contendEndTime,false)
			end

            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local fortressRuling_EL = EventListener()

local function NotifyFortressRulingListener(subtype)
    fortressRuling_EL:NotifyListener(subtype)
end

function AddFortressRulingListener(listener)
    fortressRuling_EL:AddListener(listener)
end

function RemoveFortressRulingListener(listener)
    fortressRuling_EL:RemoveListener(listener)
end


function OnFortressRulingPush(typeId, data)
	local msg = MapMsg_pb.MsgFortressRulingPush()
	msg:ParseFromString(data)

	BroadcastEventOnRulingPush(msg)

	local subtype = msg.FortressInfo.subtype	
	if fortressData == nil then
		return
	end
	UpdateActInfo(subtype,msg.FortressInfo.contendStartTime,msg.FortressInfo.contendEndTime,true)
	if fortressData[openedSubtype] ~= nil then 
		local union = UnionInfoData.GetData()
		local fortress_msg = fortressData[openedSubtype]
		if (fortress_msg.rulingInfo.guildId == union.guildInfo.guildId and union.guildInfo.guildId ~= msg.FortressInfo.rulingInfo.guildId )or
			(fortress_msg.rulingInfo.guildId ~= union.guildInfo.guildId and union.guildInfo.guildId == msg.FortressInfo.rulingInfo.guildId )then
			--governmentData = nil
			--officialList = nil
			FloatText.Show(TextMgr:GetText("GOV_ui64") , Color.red)
			fortressData[subtype] = msg.FortressInfo
			NotifyFortressRulingListener(subtype)
		else
			fortressData[subtype] = msg.FortressInfo
		end
	else
		fortressData[subtype] = msg.FortressInfo
	end
	
end

local garrisonData 

function ReqGarrisonInfo(subtype,callback)
	local req = MapMsg_pb.MsgFortressGarrisonInfoRequest()
	req.subType = subtype;
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortressGarrisonInfoRequest, req, MapMsg_pb.MsgFortressGarrisonInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if garrisonData == nil then
				garrisonData = {}
			end
			garrisonData[subtype] = {}
			garrisonData[subtype].garrisonCapacity = msg.garrisonCapacity
			garrisonData[subtype].garrisonNum = msg.garrisonNum
			garrisonData[subtype].seUid = msg.seUid
			garrisonData[subtype].garrisonInfos = msg.garrisonInfos
			garrisonData[subtype].garrisonMap = {}
			if garrisonData[subtype].garrisonInfos ~= nil then
				for i =1,#garrisonData[subtype].garrisonInfos do
					local id = garrisonData[subtype].garrisonInfos[i].garrisonData.pathid..","..garrisonData[subtype].garrisonInfos[i].garrisonData.charid
					garrisonData[subtype].garrisonMap[id] = garrisonData[subtype].garrisonInfos[i]
				end
			end
			if callback ~= nil then
				callback()
			end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function GetGarrisonInfo(subtype)
	return garrisonData[subtype]
end

function IsCancelGarrison(target_charid,subType)
	if MainData.GetCharId() == target_charid then
		return true
	end
	local fortress_msg = GetFortressData(subType)
	local union = UnionInfoData.GetData()
	local self_guildid = union.guildInfo.guildId	
	local guildId = fortress_msg.rulingInfo.guildId
	local lead_charid = fortress_msg.rulingInfo.charid


	--是领主或是盟主
	if (self_guildid == guildId and self_guildid ~= 0 and UnionInfoData.IsUnionLeader()) or (MainData.GetCharId() == lead_charid) then
		return true ;
	else
		if MainData.GetCharId() == lead_charid then
			return true
		else
			return false
		end		
	end
end  

local FortressWarLogInfoMsg

function GetFortressWarLogInfoMsg()
	return FortressWarLogInfoMsg
end

function ReqFortressWarLogInfo(callback)
	local req = MapMsg_pb.MsgFortressWarLogInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortressWarLogInfoRequest, req, MapMsg_pb.MsgFortressWarLogInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			FortressWarLogInfoMsg = msg
			table.sort(FortressWarLogInfoMsg.warLogs, function(a, b)
				if a.logId == 40040 and b.logId == 40040 then
					return a.subType < b.subType
				elseif a.logId == 40040 and b.logId ~= 40040 then
					return false
				elseif a.logId ~= 40040 and b.logId == 40040 then
					return true
				elseif GetContendEndTime(a.subType) > GameTime.GetSecTime() and GetContendEndTime(b.subType) > GameTime.GetSecTime() then
					return a.subType < b.subType
				elseif GetContendEndTime(a.subType) > GameTime.GetSecTime() and GetContendEndTime(b.subType) < GameTime.GetSecTime() then
					return true
				elseif GetContendEndTime(a.subType) < GameTime.GetSecTime() and GetContendEndTime(b.subType) > GameTime.GetSecTime() then
					return false
				else
					return a.subType < b.subType
				end
			end)
			if callback ~= nil then
				callback(true)
			end
		else
			Global.ShowError(msg.code)
			if callback ~= nil then
				callback(false)
			end			
		end
	end, false)
end
