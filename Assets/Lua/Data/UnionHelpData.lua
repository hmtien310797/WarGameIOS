module("UnionHelpData", package.seeall)
local unionHelpData
local unionMemberHelpData
local eventListener = EventListener()
local TextMgr = Global.GTextMgr
local TableMgr = Global.GTableMgr



local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function UpdateData(data)
    SetData(data)
    NotifyListener()
end

function GetData()
    return unionHelpData
end

function SetData(data)
    unionHelpData = data
end

function GetMemberHelpData()
	return unionMemberHelpData
end

function SetMemberHelpData(data)
	unionMemberHelpData = data
	NotifyListener()
end

function RequestData(callback)
    local req = GuildMsg_pb.MsgAccelAssistListRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgAccelAssistListRequest, req, GuildMsg_pb.MsgAccelAssistListResponse, function(msg)
        unionHelpData = msg
        NotifyListener()
        if callback ~= nil and type(callback) ~= "userdata" then
            callback()
        end

    end, true)
end

function HasHelp(helpType)
    if not UnionInfoData.HasUnion() then
        return false
    end

    if unionHelpData == nil then
        return false
    end

    local myHelpData = unionHelpData.myAccelAssistInfos
    for _, v in ipairs(myHelpData) do
        if v.type == helpType then			
            return true
        end
    end
    return false
end

function HasBuildHelpWithId(buildid)
	 if not UnionInfoData.HasUnion() then
        return false
    end

    if unionHelpData == nil then
        return false
    end

    local myHelpData = unionHelpData.myAccelAssistInfos
    for _, v in ipairs(myHelpData) do
        if v.type == GuildMsg_pb.AccelAssistType_Build and v.relatedId == buildid then			
            return true
        end
    end
    return false
end

function GetHelpCount()
    if not UnionInfoData.HasUnion() then
        return 0
    end

    if unionHelpData == nil then
        return 0
    end

    return #unionHelpData.accelAssistInfos
end

function HasTechHelp()
    return not HasHelp(GuildMsg_pb.AccelAssistType_Tech) and UnionInfoData.HasUnion()
end

function HasBuildHelp(buildid)
    return not HasBuildHelpWithId(buildid) and UnionInfoData.HasUnion()
end

function RequestHelp(helpType, callback , buildid)
	local req = GuildMsg_pb.MsgSeekAccelAssistRequest()
	req.type = helpType
	if helpType == GuildMsg_pb.AccelAssistType_Build then
		req.relatedId = buildid == nil and 0 or buildid
	end
	
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgSeekAccelAssistRequest, req, GuildMsg_pb.MsgSeekAccelAssistResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
            RequestData(callback)
            FloatText.Show(TextMgr:GetText("union_help_tips"), Color.green)
		else
			Global.ShowError(msg.code)
		end
	end, true)
end

function UpdateMemHelpData(info)
	if unionMemberHelpData ~= nil and unionMemberHelpData.compensateInfos ~= nil then
		for i=1 , #unionMemberHelpData.compensateInfos do
			local lcMsg = unionMemberHelpData.compensateInfos[i]
			if lcMsg.charId == info.charId  and lcMsg.triggerTime == info.triggerTime and lcMsg.endTime == info.endTime then
				unionMemberHelpData.compensateInfos[i] = info
				NotifyListener()
				break
			end
		end
	end
end

function RequestGuildMemHelp()
	local req = GuildMsg_pb.MsgCompensateListRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCompensateListRequest, req, GuildMsg_pb.MsgCompensateListResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			Global.DumpMessage(msg , "d:/MsgCompensateListResponse.lua")
            SetMemberHelpData(msg)
		   -- NotifyListener()
		else
			--Global.ShowError(msg.code)
		end
	end, true)
end

function RequestBuildHelp(buildid , callback)
	RequestHelp(GuildMsg_pb.AccelAssistType_Build, callback , buildid)
end

function RequestTechHelp(callback)
	RequestHelp(GuildMsg_pb.AccelAssistType_Tech, callback)
end

function GetDailyCoinCountData()
    for _, v in ipairs(unionHelpData.guildCoinInfo.count) do
        if v.id.id == Common_pb.CountInfoType_GuildCoin and v.id.subid == Common_pb.CountSubtype_GuildCoin_GiveAccelAssist then
            return v
        end
    end
end
