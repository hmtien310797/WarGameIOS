module("GovernmentData", package.seeall)
local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime
local TextMgr = Global.GTextMgr

ColorStr = {
    OfficialName = "[2FE4FF]",
    RebelName = "[FF0000]",
    OfficialAtt = "[00FF00]",
    RebelAtt = "[FF0000]",
    End = "[-]"
}

Official_icon_path = ResourceLibrary.PATH_ICON .. "Government/"

GovernmentPrivilegeList = {
	MapData_pb.GovernmentPrivilege_EditNotice,
	MapData_pb.GovernmentPrivilege_SendZoneMail,
	MapData_pb.GovernmentPrivilege_ManageBomb,
	MapData_pb.GovernmentPrivilege_ManageRevenue,
	MapData_pb.GovernmentPrivilege_OverviewZone,
	MapData_pb.GovernmentPrivilege_ManageTurretStrategy,
	MapData_pb.GovernmentPrivilege_ManageGarrision,
}
GovernmentPrivilegeTxt = {
	[MapData_pb.GovernmentPrivilege_EditNotice] ="GOV_ui49",-- 编辑公告
	[MapData_pb.GovernmentPrivilege_SendZoneMail] = "GOV_ui50",-- 查看战区邮件
	[MapData_pb.GovernmentPrivilege_ManageBomb] = "GOV_ui51",-- 管理核弹
	[MapData_pb.GovernmentPrivilege_ManageRevenue] = "GOV_ui52",-- 管理税收
	[MapData_pb.GovernmentPrivilege_OverviewZone] = "GOV_ui53",-- 查看战区概况
	[MapData_pb.GovernmentPrivilege_ManageTurretStrategy] = "GOV_ui54",-- 管理炮台
	[MapData_pb.GovernmentPrivilege_ManageGarrision] = "GOV_ui42" --管理驻军
}

GovStateActivityID = {2010,2011}

----- Events -------------------------------------------
local eventOnRulingPush = EventDispatcher.CreateEvent()

function OnRulingPush()
	return eventOnRulingPush
end

local function BroadcastEventOnRulingPush(...)
	EventDispatcher.Broadcast(eventOnRulingPush, ...)
end
--------------------------------------------------------

function IsPrivilegeValid(governmentPrivilege,privilege)
	return bit.band(privilege, governmentPrivilege) ~= 0
end

function GetPrivilege(privilege_list)
	local privilege = 0
	for i=1,#privilege_list do 
		if privilege_list[i] then
			privilege = bit.bor(privilege, GovernmentPrivilegeList[i])
		end
	end
	return privilege
end


local governmentData
local turretData
local officialList
local texRateInfo
local govActInfo
local govState = 1

function GetGOVState()
	return govState
end

function GetGOVActInfo()
	return govActInfo
end

local govState_EL = EventListener()

local function NotifyGovStateListener()
    govState_EL:NotifyListener()
end

function AddGovStateListener(listener)
    govState_EL:AddListener(listener)
end

function RemoveGovStateListener(listener)
    govState_EL:RemoveListener(listener)
end

local function NotifyGovState(state)
	if govState == state then
		return
	end
	govState = state
	NotifyGovStateListener()
end

function UpdateGovState()
	if govActInfo == nil then
		NotifyGovState(1)
		return
	end
	print(govActInfo.contendStartTime,govActInfo.contendEndTime,GameTime.GetSecTime(),
	(GameTime.GetSecTime()+1 >= govActInfo.contendStartTime and GameTime.GetSecTime() < govActInfo.contendEndTime)and 2 or 1)
    if GameTime.GetSecTime()+1 >= govActInfo.contendStartTime and GameTime.GetSecTime() < govActInfo.contendEndTime then
        NotifyGovState(2)
	else
		NotifyGovState(1)
	end
end

function UpdateGovActInfo(act_info)
	govActInfo = act_info
	UpdateGovState()
end


function ReqGoveInfoData(callback)
	local req = MapMsg_pb.MsgGovernmentInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentInfoRequest, req, MapMsg_pb.MsgGovernmentInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			governmentData = msg
			UpdateGovActInfo(governmentData.actInfo)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function ReqTurretInfoData(subType,callback)
	local req = MapMsg_pb.MsgTurretInfoRequest()
	req.subType = subType
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretInfoRequest, req, MapMsg_pb.MsgTurretInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if turretData == nil then
				turretData = {}
			end
			turretData[subType] = msg
			UpdateGovActInfo(turretData[subType].actInfo)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function ReqGoveOfficialListData(callback)
	local req = MapMsg_pb.MsgGovernmentOfficialListRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentOfficialListRequest, req, MapMsg_pb.MsgGovernmentOfficialListResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			officialList = msg
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function ReqGoveAppointOfficial(charid, official_id,callback)
	local req = MapMsg_pb.MsgGovernmentAppointOfficialRequest()
	req.charId = charid
	req.officialId = official_id
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentAppointOfficialRequest, req, MapMsg_pb.MsgGovernmentAppointOfficialResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			officialList = msg
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)
		end
	end, false)   
end

function ReqDeposeOfficial(charid,callback)
	local req = MapMsg_pb.MsgGovernmentDeposeOfficialRequest()
	req.charId = charid
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentDeposeOfficialRequest, req, MapMsg_pb.MsgGovernmentDeposeOfficialResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			officialList = msg
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)
		end
	end, false)   
end	

function ReqEditOfficialPrivilege(charid,privileges,callback)
	local req = MapMsg_pb.MsgGovernmentEditOfficialPrivilegeRequest()
	req.charId = charid
	req.privilege = GetPrivilege(privileges)
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentEditOfficialPrivilegeRequest, req, MapMsg_pb.MsgGovernmentEditOfficialPrivilegeResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if callback ~= nil then
				callback(req.privilege)
			end
		else
			Global.ShowError(msg.code)
		end
	end, false)   
end

function ReqGovTaxRate(callback)
	local req = MapMsg_pb.MsgGetGovTaxRateRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGetGovTaxRateRequest, req, MapMsg_pb.MsgGetGovTaxRateResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			texRateInfo = msg
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function ReqSetGovTaxRate(ratelist,callback)
	local req = MapMsg_pb.MsgSetGovTaxRateRequest()

	for i=1,#ratelist do
		local data = req.data:add()
		data.user.officialId = ratelist[i].officialId
		data.rate = ratelist[i].rate
	end
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSetGovTaxRateRequest, req, MapMsg_pb.MsgSetGovTaxRateResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			texRateInfo = msg
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end


function GetGovActInfo()
	return govActInfo
end

function GetGovernmentData()
	return governmentData
end

function GetTurretData(subType)
	if turretData == nil then
		return nil 
	end
	return turretData[subType]
end

function GetOfficialList()
	return officialList
end

function GetTexRateInfo()
	return texRateInfo
end

function GetGOVRulerGuildID()
	return governmentData.archonInfo.guildId
end

function GetGOVRulerGuildName()
	return governmentData.archonInfo.guildName
end

function GetGOVRulerGuildBanner()
	return governmentData.archonInfo.guildBanner
end

function GetGOVRulerGuildBadge()
	return governmentData.archonInfo.guildBadge
end

function GetGOVContendStartTime()
	return GetGOVActInfo().contendStartTime
end

function GetGOVContendEndTime()
	return GetGOVActInfo().contendEndTime
end

function GetTurretRulerGuildID(subType)
	return turretData[subType].rulingInfo.guildId
end

function GetTurretRulerGuildName(subType)
	return turretData[subType].rulingInfo.guildName
end

function GetTurretRulerGuildBanner(subType)
	return turretData[subType].rulingInfo.guildBanner
end

function GetTurretRulerGuildBadge(subType)
	return turretData[subType].rulingInfo.guildBadge
end

function SetGoveNotice(notice)
	if governmentData == nil then
		return
	end
	governmentData.notice = notice
end

function GetGOVGrade(officialId)
	local officialData = TableMgr:GetGoveOfficialData()
	if officialData[officialId] == nil then
		return -1
	end
	return officialData[officialId].grade
end

function GetSelfGOVGrade()
	return GetGOVGrade(MainData.GetOfficialId())
end

function GetGovAppointGrade(officialId)
	
	local officialData = TableMgr:GetGoveOfficialData()
	if officialData[officialId] == nil then
		return nil
	end
	local appointGrade = {}
	local ag_str = officialData[officialId].appointGrade
	if ag_str == "NA" then
		return appointGrade
	end
	local t = string.split(ag_str,';')
	for i = 1,#(t) do
		appointGrade[tonumber(t[i])] = 1
	end
	
	return appointGrade
end

function EnableEditOfficial(target_charid,target_officialId)
	if MainData.GetCharId() == target_charid then
		return false
	end
	--local self_off = GetSelfGOVGrade()
	local target_off = GetGOVGrade(target_officialId)
	local self_ag = GetGovAppointGrade(MainData.GetOfficialId())
	--local target_ag = GetGovAppointGrade(target_officialId)
	if self_ag == nil then
		return false
	end
	if target_officialId == 0 then
		if MainData.GetOfficialId() == 1 or MainData.GetOfficialId() == 2 then
			return true
		end
	end
	if self_ag[target_off] ~= nil then
		return true
	end
	return false
end


local turretSanction_EL = EventListener()

local function NotifyTurretSanctionListener()
    turretSanction_EL:NotifyListener()
end

function AddTurretSanctionListener(listener)
    turretSanction_EL:AddListener(listener)
end

function RemoveTurretSanctionListener(listener)
    turretSanction_EL:RemoveListener(listener)
end

local turretSanctionData

function ReqTurretSanctionList(subType)
	local req = MapMsg_pb.MsgTurretSanctionListRequest()
	req.subType = subType
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretSanctionListRequest, req, MapMsg_pb.MsgTurretSanctionListResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if turretSanctionData == nil then
				turretSanctionData = {}
			end
			turretSanctionData[subType] = {}
			for i = 1,#msg.guildInfos do 
				turretSanctionData[subType][msg.guildInfos[i].guildId] = msg.guildInfos[i]
			end
			NotifyTurretSanctionListener()
		else
			Global.ShowError(msg.code)
		end
	end, false)  
end

function GetTurretSanctionData(subType)
	if turretSanctionData == nil then
		return nil 
	end
	return turretSanctionData[subType]
end

function IsSanction(subType,guildId)
	if turretSanctionData == nil then
		return false 
	end	
	if turretSanctionData[subType] == nil then
		return false
	end
	if turretSanctionData[subType][guildId] ~= nil then
		return true
	end
	return false
end

function  ReqTurretSanctionGuild(subType,guildInfo,oper,callback)
	local req = MapMsg_pb.MsgTurretSanctionGuildRequest()
	req.subType = subType
	req.guildId = guildInfo.guildId
	req.oper = oper
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretSanctionGuildRequest, req, MapMsg_pb.MsgTurretSanctionGuildResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if oper == 1 then
				turretSanctionData[subType][guildInfo.guildId] = guildInfo
			else
				turretSanctionData[subType][guildInfo.guildId] = nil
			end
			NotifyTurretSanctionListener()
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)
		end
	end, false)
end

local turretEditStrategy_EL = EventListener()

local function NotifyEditStrategyListener()
    turretEditStrategy_EL:NotifyListener()
end

function AddEditStrategyListener(listener)
    turretEditStrategy_EL:AddListener(listener)
end

function RemoveEditStrategyListener(listener)
    turretEditStrategy_EL:RemoveListener(listener)
end

function ReqTurretEditStrategy(subType,strategy,callback)
	local req = MapMsg_pb.MsgTurretEditStrategyRequest()
	req.subType = subType
	req.strategy = strategy
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretEditStrategyRequest, req, MapMsg_pb.MsgTurretEditStrategyResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if turretData ~= nil and turretData[subType] ~= nil then
				turretData[subType].strategy = strategy
			end
			NotifyEditStrategyListener()
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


local govGarrisonData 


function ReqGovGarrisonInfo(callback)
	local req = MapMsg_pb.MsgGovernmentGarrisonInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentGarrisonInfoRequest, req, MapMsg_pb.MsgGovernmentGarrisonInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			govGarrisonData = {}
			govGarrisonData.garrisonCapacity = msg.garrisonCapacity
			govGarrisonData.garrisonNum = msg.garrisonNum
			govGarrisonData.seUid = msg.seUid
			govGarrisonData.garrisonInfos = msg.garrisonInfos
			govGarrisonData.garrisonMap = {}
			if govGarrisonData.garrisonInfos ~= nil then
				for i =1,#govGarrisonData.garrisonInfos do
					local id = govGarrisonData.garrisonInfos[i].garrisonData.pathid..","..govGarrisonData.garrisonInfos[i].garrisonData.charid
					govGarrisonData.garrisonMap[id] = govGarrisonData.garrisonInfos[i]
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

function GetGovGarrisonInfo()
	return govGarrisonData
end

function IsCancelGarrison(target_charid,subType)
	if MainData.GetCharId() == target_charid then
		return true
	end
	local gov_msg = GetGovernmentData()
	local turret_msg =subType == nil and nil or GetTurretData(subType)
	local union = UnionInfoData.GetData()
	local self_guildid = union.guildInfo.guildId	
	local guildId = 0
	local lead_charid = 0
	if turret_msg ~= nil then
		guildId = turret_msg.rulingInfo.guildId
		lead_charid = turret_msg.rulingInfo.charId
	else
		guildId = gov_msg.archonInfo.guildId
		lead_charid =  gov_msg.archonInfo.charId
	end

	--是不是执政盟
	if self_guildid == guildId and self_guildid ~= 0 then
		--判读是不是盟主
		if MainData.GetCharId() == lead_charid then
			return true
		else
			return IsPrivilegeValid(MapData_pb.GovernmentPrivilege_ManageGarrision,MainData.GetGOVPrivilege())
		end
	else
		if MainData.GetCharId() == lead_charid then
			return true
		else
			return false
		end		
	end
end  

local turretGarrisonData 

function ReqTurretGarrisonInfo(subType,callback)
	local req = MapMsg_pb.MsgTurretGarrisonInfoRequest()
	req.subType = subType
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretGarrisonInfoRequest, req, MapMsg_pb.MsgTurretGarrisonInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if turretGarrisonData == nil then
				turretGarrisonData = {}
			end
			turretGarrisonData[subType] = {}
			turretGarrisonData[subType].garrisonCapacity = msg.garrisonCapacity
			turretGarrisonData[subType].garrisonNum = msg.garrisonNum
			turretGarrisonData[subType].seUid = msg.seUid
			turretGarrisonData[subType].garrisonInfos = msg.garrisonInfos
			turretGarrisonData[subType].garrisonMap = {}
			for i =1,#turretGarrisonData[subType].garrisonInfos do
				local id = turretGarrisonData[subType].garrisonInfos[i].garrisonData.pathid..","
				..turretGarrisonData[subType].garrisonInfos[i].garrisonData.charid
				turretGarrisonData[subType].garrisonMap[id] = turretGarrisonData[subType].garrisonInfos[i]
			end
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)		
		end
	end, false)
end

function GetTurretGarrisonInfo(subType)
	return turretGarrisonData[subType]
end

local govRuling_EL = EventListener()

local function NotifyGovRulingListener()
    govRuling_EL:NotifyListener()
end

function AddGovRulingListener(listener)
    govRuling_EL:AddListener(listener)
end

function RemoveGovRulingListener(listener)
    govRuling_EL:RemoveListener(listener)
end


function OnGovernmentRulingPush(typeId, data)
	local msg = MapMsg_pb.MsgGovernmentRulingPush()
	msg:ParseFromString(data)

	BroadcastEventOnRulingPush(msg)

	UpdateGovActInfo(msg.actInfo)
	if governmentData ~= nil then 
		local union = UnionInfoData.GetData()
		local gov_msg = governmentData
		if (gov_msg.archonInfo.guildId == union.guildInfo.guildId and union.guildInfo.guildId ~= msg.archonInfo.guildId )or
			(gov_msg.archonInfo.guildId ~= union.guildInfo.guildId and union.guildInfo.guildId == msg.archonInfo.guildId )then
			--governmentData = nil
			--officialList = nil
			FloatText.Show(TextMgr:GetText("GOV_ui64") , Color.red)
			gov_msg.archonInfo:MergeFrom(msg.archonInfo)
			NotifyGovRulingListener()
		end
	end
end


local turretRulingMsg
local turretRuling_EL = EventListener()

local function NotifyTurretRulingListener()
    turretRuling_EL:NotifyListener()
end

function AddTurretRulingListener(listener)
    turretRuling_EL:AddListener(listener)
end

function RemoveTurretRulingListener(listener)
    turretRuling_EL:RemoveListener(listener)
end

function CheckTurretInRuling(subType)
	if turretRulingMsg == nil then
		return false
	end
	for i =1,#turretRulingMsg.rulingGuilds do 
		if turretRulingMsg.rulingGuilds.subType == subType then
			return true;
		end
	end
	return false
end

function OnTurretRulingPush(typeId, data)
	local msg = MapMsg_pb.MsgTurretRulingPush()
	msg:ParseFromString(data)
	turretRulingMsg = msg
	for i =1,#msg.rulingGuilds do 
		local new_guildid = msg.rulingGuilds[i].rulingInfo.guildId
		local subType = msg.rulingGuilds[i].subType
		local turret_msg = GetTurretData(subType)
		if turret_msg ~= nil then 
			--print("OnTurretRulingPush   MergeFrom",subType)
			turret_msg.rulingInfo:MergeFrom(msg.rulingGuilds[i].rulingInfo)
			local union = UnionInfoData.GetData()
			if (turret_msg.rulingInfo.guildId == union.guildInfo.guildId and union.guildInfo.guildId ~= new_guildid )or
				(turret_msg.rulingInfo.guildId ~= union.guildInfo.guildId and union.guildInfo.guildId == new_guildid )then
					--turretGarrisonData[subType] = nil
					FloatText.Show(TextMgr:GetText("GOV_ui64") , Color.red)
					NotifyTurretRulingListener()
			end
		end
	end
end

local warLogInfoMsg

function GetWarLogInfoMsg()
	return warLogInfoMsg
end

function ReqWarLogInfo(callback)
	local req = MapMsg_pb.MsgGovernmentWarLogInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentWarLogInfoRequest, req, MapMsg_pb.MsgGovernmentWarLogInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			warLogInfoMsg = msg
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



function ReqTurretHurtLog(pageindex,callback)
	local req = MapMsg_pb.MsgTurretLogInfoRequest()
	req.pageIndex = pageindex
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretLogInfoRequest, req, MapMsg_pb.MsgTurretLogInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if callback ~= nil then
				callback(msg)
			end
		else
			Global.ShowError(msg.code)		
		end
	end, false)
end
