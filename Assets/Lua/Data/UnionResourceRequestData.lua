module("UnionResourceRequestData", package.seeall)
local unionResReqData
local eventListener = EventListener()

function GetData()
    return unionResReqData
end

function SetData(data)
    unionResReqData = data
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

function UpdateData(data)
    SetData(data)
    NotifyListener()
end

function RequestData(callback)
    local req = GuildMsg_pb.MsgGuildWareHouseInfoRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildWareHouseInfoRequest, req, GuildMsg_pb.MsgGuildWareHouseInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
        else
			UpdateData(msg)
			if callback ~= nil then
				callback()
			end
        end
    end)
end

function HasNotice()
    return UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_ManageRes) and (unionResReqData ~= nil and #unionResReqData.resApplyInfos > 0)
end


