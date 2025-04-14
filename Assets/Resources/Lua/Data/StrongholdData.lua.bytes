module("StrongholdData", package.seeall)
local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime
local TextMgr = Global.GTextMgr


local strongholdData
local strongholdActInfo
local strongholdState
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

function OpenStrongholdUI(subtype)
	openedSubtype = subtype
end

function CloseStrongholdUI(subtype)
	openedSubtype = 0
end

function GetAllStrongholdData()
	if strongholdData == nil then
		strongholdData = {}
	end
	return strongholdData
end

function HasMyStronghold()
    local myGuildId = UnionInfoData.GetGuildId()
    if myGuildId == 0 then
        return false
    end

    for _, v in ipairs(strongholdData) do
        local guildId = v.rulingInfo.guildId
        if guildId == myGuildId then
            return true
        end
    end

    return false
end

function GetStrongholdData(subtype)
	if strongholdData == nil then
		strongholdData = {}
	end
	return strongholdData[subtype];
end

function GetStrongholdState(subtype)
	if strongholdState == nil then
		strongholdState = {}
	end
	return strongholdState[subtype] 
end

function GetStrongholdActInfo(subtype)
	if strongholdActInfo == nil then
		strongholdActInfo = {}
	end
	return strongholdActInfo[subtype] 
end

function GetRulerGuildID(subtype)
	return GetStrongholdData(subtype).rulingInfo.guildId
end
function GetRulerGuildBanner(subtype)
	return GetStrongholdData(subtype).rulingInfo.guildBanner
end
function GetRulerGuildName(subtype)
	return GetStrongholdData(subtype).rulingInfo.guildName
end
function GetRulerGuildBadge(subtype)
	return GetStrongholdData(subtype).rulingInfo.guildBadge
end
function GetRulerGuildLang(subtype)
	return GetStrongholdData(subtype).rulingInfo.guildLang
end

function GetContendStartTime(subtype)
	return GetStrongholdData(subtype).contendStartTime
end
function GetContendEndTime(subtype)
	return GetStrongholdData(subtype).contendEndTime
end

function IsActive()
	print(1111111111)
	if strongholdState == nil then
		return false
	end
	for i, v in pairs(strongholdState) do
		print(v)
		if v == 2 then
			return true
		end
	end
	return false
end

function GetAllEndTime()
	if strongholdData == nil then
		return 0
	end
	local endtime = 0
	for i, v in pairs(strongholdData) do
		if v.contendEndTime > endtime then
			endtime = v.contendEndTime
		end
	end
	return endtime
end

local strongholdState_EL = EventListener()

local function NotifyStateListener()
    strongholdState_EL:NotifyListener()
end

function AddStateListener(listener)
    strongholdState_EL:AddListener(listener)
end

function RemoveStateListener(listener)
    strongholdState_EL:RemoveListener(listener)
end

local function NotifyState(subtype,state,enable)
	if strongholdState == nil then
		strongholdState = {}
	end
	if strongholdState[subtype] == state then
		return
	end
	strongholdState[subtype] = state
	if enable then
		NotifyStateListener(subtype)
	end
end
--1 开始 2 进行 3.结束
function UpdateState(subtype,enable)
	if strongholdActInfo[subtype] == nil then
		NotifyState(subtype,1,enable)
		return
	end
	print("UpdateState stronghold",strongholdActInfo[subtype].contendStartTime,strongholdActInfo[subtype].contendEndTime,
	(GameTime.GetSecTime() > strongholdActInfo[subtype].contendStartTime and GameTime.GetSecTime() < strongholdActInfo[subtype].contendEndTime)and 2 or 1)
    if GameTime.GetSecTime() > strongholdActInfo[subtype].contendStartTime and GameTime.GetSecTime() < strongholdActInfo[subtype].contendEndTime then
        NotifyState(subtype,2,enable)
	elseif GameTime.GetSecTime() > strongholdActInfo[subtype].contendEndTime then
		NotifyState(subtype,3,enable)
	else
		NotifyState(subtype,1,enable)
	end
end

function UpdateActInfo(subtype,contendStartTime,contendEndTime,enable)
	if strongholdActInfo == nil then
		strongholdActInfo = {}
	end
	strongholdActInfo[subtype] = {}
	strongholdActInfo[subtype].contendStartTime = contendStartTime
	strongholdActInfo[subtype].contendEndTime = contendEndTime
	UpdateState(subtype,enable)
end

function ReqStrongholdInfoData(subtype,callback)
	local req = MapMsg_pb.MsgStrongholdInfoRequest()
	req.subType = subtype;
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgStrongholdInfoRequest, req, MapMsg_pb.MsgStrongholdInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if strongholdData == nil then
				strongholdData = {}
			end

			strongholdData[subtype] = msg.strongholdInfo
			UpdateActInfo(subtype,strongholdData[subtype].contendStartTime,strongholdData[subtype].contendEndTime,true)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function ReqAllStrongholdInfoData(callback)
	local req = MapMsg_pb.MsgAllStrongholdInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgAllStrongholdInfoRequest, req, MapMsg_pb.MsgAllStrongholdInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if strongholdData == nil then
				strongholdData = {}
			end
			for i=1,#msg.infoList do
				local subtype = msg.infoList[i].subtype
				strongholdData[subtype] = msg.infoList[i]
				UpdateActInfo(subtype,strongholdData[subtype].contendStartTime,strongholdData[subtype].contendEndTime,false)
			end

            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local strongholdRuling_EL = EventListener()

local function NotifyHoldRulingListener(subtype)
    strongholdRuling_EL:NotifyListener(subtype)
end

function AddHoldRulingListener(listener)
    strongholdRuling_EL:AddListener(listener)
end

function RemoveHoldRulingListener(listener)
    strongholdRuling_EL:RemoveListener(listener)
end

function OnStrongholdRulingPush(typeId, data)
	local msg = MapMsg_pb.MsgStrongholdRulingPush()
	msg:ParseFromString(data)

	BroadcastEventOnRulingPush(msg)

	local subtype = msg.strongholdInfo.subtype	
	if strongholdData == nil then
		return
	end

	UpdateActInfo(subtype,msg.strongholdInfo.contendStartTime,msg.strongholdInfo.contendEndTime,true)
	if strongholdData[openedSubtype] ~= nil then 
		local union = UnionInfoData.GetData()
		local stronghold_msg = strongholdData[openedSubtype]
		if (stronghold_msg.rulingInfo.guildId == union.guildInfo.guildId and union.guildInfo.guildId ~= msg.strongholdInfo.rulingInfo.guildId )or
			(stronghold_msg.rulingInfo.guildId ~= union.guildInfo.guildId and union.guildInfo.guildId == msg.strongholdInfo.rulingInfo.guildId )then
			--governmentData = nil
			--officialList = nil
			FloatText.Show(TextMgr:GetText("GOV_ui64") , Color.red)
			strongholdData[subtype] = msg.strongholdInfo
			NotifyHoldRulingListener(subtype)
		else
			strongholdData[subtype] = msg.strongholdInfo
		end
	else
		strongholdData[subtype] = msg.strongholdInfo
	end
	
end

local garrisonData 

function ReqGarrisonInfo(subtype,callback)
	local req = MapMsg_pb.MsgStrongholdGarrisonInfoRequest()
	req.subType = subtype;
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgStrongholdGarrisonInfoRequest, req, MapMsg_pb.MsgStrongholdGarrisonInfoResponse, function(msg)
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
	local stronghold_msg = GetStrongholdData(subType)
	--local turret_msg =subType == nil and nil or GetTurretData(subType)
	local union = UnionInfoData.GetData()
	local self_guildid = union.guildInfo.guildId	
	local guildId = stronghold_msg.rulingInfo.guildId
	local lead_charid = stronghold_msg.rulingInfo.charid


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

local StrongholdWarLogInfoMsg

function GetStrongholdWarLogInfoMsg()
	return StrongholdWarLogInfoMsg
end

function ReqStrongholdWarLogInfo(callback)
	local req = MapMsg_pb.MsgStrongholdWarLogInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgStrongholdWarLogInfoRequest, req, MapMsg_pb.MsgStrongholdWarLogInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			StrongholdWarLogInfoMsg = msg
			table.sort(StrongholdWarLogInfoMsg.warLogs, function(a, b)
				local adata = TableMgr:GetStrongholdRuleByID(a.subType)
				local bdata = TableMgr:GetStrongholdRuleByID(b.subType)
				if a.logId == 30040 and b.logId == 30040 then
					return adata.order < bdata.order
				elseif a.logId == 30040 and b.logId ~= 30040 then
					return false
				elseif a.logId ~= 30040 and b.logId == 30040 then
					return true
				elseif GetContendEndTime(a.subType) > GameTime.GetSecTime() and GetContendEndTime(b.subType) > GameTime.GetSecTime() then
					return adata.order < bdata.order
				elseif GetContendEndTime(a.subType) > GameTime.GetSecTime() and GetContendEndTime(b.subType) < GameTime.GetSecTime() then
					return true
				elseif GetContendEndTime(a.subType) < GameTime.GetSecTime() and GetContendEndTime(b.subType) > GameTime.GetSecTime() then
					return false
				else
					return adata.order < bdata.order
				end
			end)
			--Global.DumpMessage(StrongholdWarLogInfoMsg, "d:/dddd.lua")
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
