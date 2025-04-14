module("QQData", package.seeall)

local qqdata

function RequestData(callback)
    local req = ClientMsg_pb.MsgCheckBindQQAccountRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCheckBindQQAccountRequest, req, ClientMsg_pb.MsgCheckBindQQAccountResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            qqdata = msg.qqnumber
            if callback ~= nil then
            	callback(qqdata)
            end
        else
        	qqdata = nil
        	callback(nil)
        end
    end, false)
end

function RequestBind(qq, callback)
    local req = ClientMsg_pb.MsgBindQQAccountRequest()
    req.qqnumber = qq
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgBindQQAccountRequest, req, ClientMsg_pb.MsgBindQQAccountResponse, function(msg)
        callback(msg)
    end, false)
end