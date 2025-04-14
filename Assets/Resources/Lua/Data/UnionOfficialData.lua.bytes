module("UnionOfficialData", package.seeall)
local unionOfficialData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return unionOfficialData
end

function SetData(data)
    unionOfficialData = data
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
    local req = GuildMsg_pb.MsgGuildAllOfficialListRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildAllOfficialListRequest, req, GuildMsg_pb.MsgGuildAllOfficialListResponse, function(msg)
        SetData(msg.officialList)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function GetDataById(officialId)
    for _, v in ipairs(unionOfficialData.infos) do
        if v.officialId == officialId then
            return v
        end
    end

    return nil
end

function HasAppointed(charId)
    for _, v in ipairs(unionOfficialData.infos) do
        if v.charId == charId then
            return true
        end
    end

    return false
end

