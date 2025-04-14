module("ExchangeTableData", package.seeall)
local exchangeTableData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return exchangeTableData
end

function SetData(data)
    exchangeTableData = data
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
    local req = ActivityMsg_pb.MsgExchangeTableRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgExchangeTableRequest, req, ActivityMsg_pb.MsgExchangeTableResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
        end
    end, not lockScreen)
end
