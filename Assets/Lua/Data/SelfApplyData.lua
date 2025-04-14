module("SelfApplyData", package.seeall)
local selfApplyData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return selfApplyData
end

function SetData(data)
    selfApplyData = data
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
    local req = GuildMsg_pb.MsgMyApplyGuildListRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgMyApplyGuildListRequest, req, GuildMsg_pb.MsgMyApplyGuildListResponse, function(msg)
        SetData(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            NotifyListener()
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function RemoveApply(guildId)
    local applyListMsg = selfApplyData.guildInfos
    for i, v in ipairs(applyListMsg) do
        if v.guildId == guildId then
            applyListMsg:remove(i)
            NotifyListener()
            break
        end
    end
end

function HasApplied(guildId)
    local applyListMsg = selfApplyData.guildInfos
    for i, v in ipairs(applyListMsg) do
        if v.guildId == guildId then
            return true
        end
    end

    return false
end

function ClearApply()
	local applyListMsg = selfApplyData.guildInfos
    for i, v in ipairs(applyListMsg) do
		applyListMsg:remove(i)
	end
end