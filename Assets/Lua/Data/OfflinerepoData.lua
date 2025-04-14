module("OfflinerepoData", package.seeall)
local GUIMgr = Global.GGUIMgr
local OfflinerepoData = {}
local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
    return unionMessageData
end

function SetData(data)
    unionMessageData = data
end

function RequestOfflineReport(callback)
    local req = ClientMsg_pb.MsgGetOfflineReportRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetOfflineReportRequest, req, ClientMsg_pb.MsgGetOfflineReportResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            if callback ~= nil then
                callback()
            end
        else
            Global.FloatError(msg.code)
        end
    end, true)
end
