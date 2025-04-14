module("MilitaryActionData", package.seeall)
local militatryActionData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr
local oldRreshStartTime = nil
local refreshNoticeList = {false, false}

function Sort1()
    table.sort(militatryActionData.tasks, function(v1, v2)
        if v1.status == v2.status then
			--baseid 可能会相同，所以改为以uid排序。by mbs
			return v1.uid < v2.uid
        else
            return v1.status > v2.status
        end
    end)
end

function GetData()
    return militatryActionData
end

function SetData(data)
    militatryActionData = data
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

function UpdateActionData(data)
    for i, v in ipairs(militatryActionData.tasks) do
        if v.uid == data.uid then
            militatryActionData.tasks[i] = data
            NotifyListener()
            break
        end
    end
end

function RequestData(callback)
    local req = ClientMsg_pb.MsgOnlineTaskListRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgOnlineTaskListRequest, req, ClientMsg_pb.MsgOnlineTaskListResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if msg.freshstarttime ~= oldRreshStartTime then
                for i = 1, 2 do
                    local hasNone = false
                    local hasDoing = false
                    for _, v in ipairs(militatryActionData.tasks) do
                        local actionData = TableMgr:GetMilitarytActionData(v.baseid)
                        if actionData.missionType == i then
                            if v.status == ClientMsg_pb.ots_none then
                                hasNone = true
                            end
                            if v.status == ClientMsg_pb.ots_doing then
                                hasDoing = true
                            end
                        end
                    end
                    if hasNone and not hasDoing then
                        refreshNoticeList[i] = true
                    end
                end
                oldRreshStartTime = militatryActionData.freshstarttime
            end
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function GetActionData(uid)
    for _, v in ipairs(militatryActionData.tasks) do
        if v.uid == uid then
            return v
        end
    end
end

function GetActionCount()
    return #militatryActionData.tasks
end

function HasRefreshNoticeByType(missionType)
    for i, v in ipairs(refreshNoticeList) do
        if i == missionType then
            return v
        end
    end
end

function HasRefreshNotice()
    for i = 1, 2 do
        if HasRefreshNoticeByType(i) then
            return true
        end
    end

    return false
end
function CancelRefreshNotice(missionType)
    refreshNoticeList[missionType] = false
    NotifyListener()
end

function HasNotice()
    if HasRefreshNotice() then
        return true
    end

    for _, v in ipairs(militatryActionData.tasks) do
        if v.status == ClientMsg_pb.ots_finish then
            return true
        end
    end
    return false
end

function HasNoticeByType(missionType)
    if HasRefreshNoticeByType(missionType) then
        return true
    end

    for _, v in ipairs(militatryActionData.tasks) do
        local actionData = TableMgr:GetMilitarytActionData(v.baseid)
        if actionData.missionType == missionType and v.status == ClientMsg_pb.ots_finish then
            return true
        end
    end
    return false
end

function HasFinishedAllAction(missionType)
    local hasmissionfree = false
    for _, v in ipairs(militatryActionData.tasks) do
        local actionData = TableMgr:GetMilitarytActionData(v.baseid)
        if actionData.missionType == missionType then
            if v.status == ClientMsg_pb.ots_doing then
                return false
            end
            if v.status == ClientMsg_pb.ots_none then
                hasmissionfree = true
            end
        end
    end
    return hasmissionfree
end

function GetCompletedCount()
    local completedCount = 0
    for _, v in ipairs(militatryActionData.tasks) do
        if v.status == ClientMsg_pb.ots_finish then
            completedCount = completedCount + 1
        end
    end
    return completedCount
end
