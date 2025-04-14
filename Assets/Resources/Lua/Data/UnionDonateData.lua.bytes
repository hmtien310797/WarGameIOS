module("UnionDonateData", package.seeall)
local unionDonateData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return unionDonateData
end

function SetData(data)
    unionDonateData = data
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

function RequestData(callback)
    local req = GuildMsg_pb.MsgGuildContributeInfoRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildContributeInfoRequest, req, GuildMsg_pb.MsgGuildContributeInfoResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
        end
    end)
end

function UpdateInfoData(infoData)
    rawset(unionDonateData, "info", infoData)
    UnionInfoData.UpdateRes(unionDonateData.info.resFreshInfo)
    NotifyListener()
end

function UpdateStepRewardData(step)
    for i, v in ipairs(unionDonateData.info.stepRewards) do
        if v.step == step then
            v.status = 3
            NotifyListener()
            break
        end
    end
end

function HasNotice()
    local detailMsg = unionDonateData.info.details[1]
    if detailMsg ~= nil and detailMsg.count.count > 0 and Global.GetLeftCooldownSecond(detailMsg.nextTime) == 0 then
        return true
    end

    for _, v in ipairs(unionDonateData.info.stepRewards) do
        if v.status == 2 then
            return true
        end
    end

    return false
end
