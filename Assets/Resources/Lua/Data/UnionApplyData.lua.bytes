module("UnionApplyData", package.seeall)
local unionApplyData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return unionApplyData
end

function SetData(data)
    unionApplyData = data
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

function RequestData(callback, lockScreen)
    local req = GuildMsg_pb.MsgApplicantListRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgApplicantListRequest, req, GuildMsg_pb.MsgApplicantListResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
        end
    end, not lockScreen)
end

function GetApplyCount()
    return #unionApplyData.applicants
end

function HasNotice()
    return #unionApplyData.applicants > 0 or #unionApplyData.positionApplicants > 0
end
