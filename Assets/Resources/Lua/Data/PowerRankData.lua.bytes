module("PowerRankData", package.seeall)
local TextMgr = Global.GTextMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local msg_data

function UpdateData(msg)
	msg_data = msg
end

function GetData()
	for i =1,#msg_data.typeinfo do
		if msg_data.typeinfo[i].type == 5 then
			return msg_data.typeinfo[i]
		end
	end
	return msg_data.typeinfo[1]
end

function RequestData(callback)
	local req = ActivityMsg_pb.MsgGetServerOpenRankListRequest()
	LuaNetwork.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgGetServerOpenRankListRequest, req:SerializeToString(), function(typeId, data)
		local msg = ActivityMsg_pb.MsgGetServerOpenRankListResponse ()
		msg:ParseFromString(data)
		if msg.code == 0 then
			UpdateData(msg)
			if callback ~= nil then
				callback(true)
			end
		else
			if callback ~= nil then
				callback(false)
			end
		end
	end, true)
end


