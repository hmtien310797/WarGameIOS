module("UnionInfoData", package.seeall)
local unionInfoData
local unionOccupyCount = 0
local eventListener = EventListener()

local TableMgr = Global.GTableMgr
local RallyTime = 0

----- Events -------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

local function BroadcastEventOnDataChange(...)
    EventDispatcher.Broadcast(eventOnDataChange, ...)
end
--------------------------------------------------------

function GetRallyTime()
    return RallyTime
end

function SetRallyTime(data)
    RallyTime = data
end


function GetData()
    return unionInfoData
end

function SetData(data)
    unionInfoData = data
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

function UpdateUnionGiftCountData(giftCount)
	if unionInfoData ~= nil then
		unionInfoData.miscInfo.availableChestNum = giftCount
		NotifyListener()
	end
end

function GetActiveGiftCount()
	local count = 0
	if unionInfoData ~= nil then
		count = unionInfoData.miscInfo.availableChestNum
	end
	
	local unionCardData = UnionCardData.GetAvailableCard(0)
	if unionCardData and unionCardData.buyed and unionCardData.cantake then
		count = count + 1
	end
	
	
	return count
end

function UpdateData(data)
    local oldData = unionInfoData

    SetData(data)

    NotifyListener()
    BroadcastEventOnDataChange(data, oldData)
end

function RequestData(callback)
    local req = GuildMsg_pb.MsgSeeMyGuildRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgSeeMyGuildRequest, req, GuildMsg_pb.MsgSeeMyGuildResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end


function SetUnionContestNum(num)
	unionOccupyCount = num
	NotifyListener()
end

function RequestOccupyFieldInfo(index , isNotify , callback)
	local req = MapMsg_pb.MsgGuildOccupyInfoRequest()
	req.pageIndex = index
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGuildOccupyInfoRequest, req, MapMsg_pb.MsgGuildOccupyInfoResponse, function(msg)
		if isNotify then
			SetUnionContestNum(msg.contestNum)
		end
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback(msg)
            end
        end
    end, true)
end


function RequestResFieldInfo(enType , index , callback)
	local req = MapMsg_pb.MsgGuildResFieldInfoRequest()
	req.entryType = enType
	req.pageIndex = index
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGuildResFieldInfoRequest, req, MapMsg_pb.MsgGuildResFieldInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback(msg)
            end
        end
    end, false)
end

function GetUnionContestNum()
	return unionOccupyCount
end


function GetGuildId()
    if Global.GetMobaMode() == 1 then
        return MobaMainData.GetTeamID()
    elseif Global.GetMobaMode() == 2 then
        return MobaMainData.GetTeamID()
    end
    return unionInfoData ~= nil and unionInfoData.guildInfo.guildId or 0
end

function HasUnion()
    return unionInfoData ~= nil and unionInfoData.guildInfo.guildId ~= 0
end

function GetGuildBanner()
    return unionInfoData ~= nil and unionInfoData.guildInfo.banner or nil
end

function SetRecruitType(recruitType)
    unionInfoData.guildInfo.recruitType = recruitType
    NotifyListener()
end

function GetPKValueLimit()
    return unionInfoData.guildInfo.pkValueLimit
end

function SetPKValueLimit(pkValueLimit)
    unionInfoData.guildInfo.pkValueLimit = pkValueLimit
    NotifyListener()
end

function Rename(name)
    unionInfoData.guildInfo.name = name
    NotifyListener()
end

function SetBanner(banner)
    unionInfoData.guildInfo.banner = banner
    NotifyListener()
end

function SetBadge(badgeId)
    unionInfoData.guildInfo.badge = badgeId
    NotifyListener()
end

function SetOuterNotice(notice)
    unionInfoData.guildInfo.outerNotice = notice
    NotifyListener()
end

function SetInnerNotice(notice)
    unionInfoData.guildInfo.innerNotice = notice
    NotifyListener()
end

function GetJoinTime()
	if HasUnion() then
		return unionInfoData.memberInfo.joinTime
	end
	return nil
end

function IsNormal()
    return unionInfoData ~= nil and unionInfoData.guildInfo.status == GuildMsg_pb.GuildStatus_Normal
end

function IsDissolving()
    return unionInfoData ~= nil and unionInfoData.guildInfo.status == GuildMsg_pb.GuildStatus_DissolveWarning
end

function IsUnionLeader()
    if not HasUnion() then
        return false
    end
    return unionInfoData.memberInfo.position == GuildMsg_pb.GuildPosition_Leader
end

function HasPrivilege(privilege)
    if not HasUnion() then
        return false
    end
    return (unionInfoData.memberInfo.position == GuildMsg_pb.GuildPosition_Leader) or bit.band(unionInfoData.memberInfo.privilege, privilege) ~= 0
end

function GetResByType(resType)
    if unionInfoData == nil then
        return 0
    end

    for _, v in ipairs(unionInfoData.guildInfo.guildRes.resInfos) do
        if v.resType == resType then
            return v.resNum
        end
    end
    
    return 0
end

function GetFood()
    return GetResByType(GuildMsg_pb.GuildResType_Food)
end

function GetIron()
    return GetResByType(GuildMsg_pb.GuildResType_Iron)
end

function GetOil()
    return GetResByType(GuildMsg_pb.GuildResType_Oil)
end

function GetElec()
    return GetResByType(GuildMsg_pb.GuildResType_Elec)
end

function GetCoin()
    return GetResByType(GuildMsg_pb.GuildResType_GuildCoin)
end

function UpdateRes(guildRes)
    if unionInfoData == nil then
        return
    end

    rawset(unionInfoData.guildInfo, "guildRes", guildRes)

    NotifyListener()
end

function IsLeader(charId)
    if unionInfoData == nil then
        return false
    end

    local charId = charId or MainData.GetCharId()

    return unionInfoData.guildInfo.leaderCharId == charId
end
