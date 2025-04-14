module("FunctionListData", package.seeall)
local TableMgr = Global.GTableMgr
local ClientMsg_pb = require("ClientMsg_pb")

local FunctionListData
local eventListener = EventListener()
local function NotifyListener()
    eventListener:NotifyListener()
end

local callbacklist = {}
local isrequesting = false

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function IsUnlocked(id)
	if FunctionListData ~= nil then
		for i, v in ipairs(FunctionListData) do
			if tonumber(id) == tonumber(v) then
				return true
			end
		end
	end
	return false
end

function IsFunctionUnlocked(id, callback)
	if FunctionListData ~= nil then
		for i, v in ipairs(FunctionListData) do
			if tonumber(id) == tonumber(v) then
				if callback ~= nil then
					callback(true)
				end
				return true
			end
		end
	end
	local cb = {}
	cb.id = id
	cb.callback = callback
	table.insert(callbacklist, cb)
	if not isrequesting then
		isrequesting = true
		RequestListData(function()
			isrequesting = false
			for index, cb in ipairs(callbacklist) do
				local hasreturn = false
				for i, v in ipairs(FunctionListData) do
					if tonumber(cb.id) == tonumber(v) then
						if cb.callback ~= nil then
							cb.callback(true)
							hasreturn = true
						end
					end
				end
				if not hasreturn then
					if cb.callback ~= nil then
						cb.callback(false)
					end
				end
			end
			callbacklist = {}
		end)
	end
	return false
end

function GetListData()
	return FunctionListData
end

function SetListData(list)
    FunctionListData = list
end

function RequestListData(cb)
    if FunctionListData == nil then
        FunctionListData = {}
    end
    local req = ClientMsg_pb.MsgFunctionAvailableRequest();
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgFunctionAvailableRequest, req, ClientMsg_pb.MsgFunctionAvailableResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetListData(msg.type)
            if cb ~= nil then
                cb()
            end
            NotifyListener()
        end
    end, true)
end