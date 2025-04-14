module("NotifyInfoData", package.seeall)

local notifyInfoData = {}
local notifyPush = {}
local haveNotifyType = {}

local eventListener = EventListener()

function GetData()
    return notifyInfoData
end

function SetData(data)
    notifyInfoData = data
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

function HaveAcitveNotify(notify)
	if notifyInfoData.data == nil then
		return false
	end
	
	for i=1 , #notifyInfoData.data do
		local notidata = notifyInfoData.data[i]
		if notidata.notify == notify then
			return true
		end
	end
end

function GetNotifyInfo(notify , noties)
	if noties == nil or notifyInfoData.data == nil then
		return
	end
	
	
	for i=1 , #notifyInfoData.data do
		local notidata = notifyInfoData.data[i]
		print(notidata.notify)
		if notidata.notify == notify then
			table.insert(noties , notidata)
		end
	end
end

function ClearNotify(notify)
	if notifyInfoData.data == nil then
		return
	end
	
	for i=1 , #notifyInfoData.data do
		local notidata = notifyInfoData.data[i]
		if notidata.notify == notify then
			notifyInfoData.data[i] = nil
		end
	end
	
end

function ClearNotifyType(notify)
	print(notify)
	for i , v in pairs(haveNotifyType) do
		if v == notify then
			print(v)
			table.remove(haveNotifyType , i)
		end
	end
end

function HaveNotifyType(notify)
	for i , v in pairs(haveNotifyType) do
		if v == notify then
			return true
		end
	end
	return false
end

function SetNotifyTypeData(notifyType)
	haveNotifyType = {}
	for i=1 , #notifyType.notify , 1 do
		local notype = notifyType.notify[i]
		table.insert(haveNotifyType , notype)
	end
end


function OnNotifyPush(notify)
	--notify push
	local addPush = true
	for i , v in pairs(notifyPush) do
		if v == notify then
			addPush = false
		end
	end
	if addPush then
		table.insert(notifyPush , notify)
	end
	
	--notify type
	local addPushType = true
	for i , v in pairs(haveNotifyType) do
		print(v , notify)
		if v == notify then
			print(addPushType)
			addPushType = false
		end
	end
	if addPushType then
		print(#haveNotifyType , notify)
		table.insert(haveNotifyType , notify)
	end
	
	NotifyListener()
end



function HasNotifyPush(notify)
	for i , v in pairs(notifyPush) do
		if v == notify then
			return true
		end
	end
	return false
end

function OnDealNotifyPush(notify)
	for i , v in pairs(notifyPush) do
		if v == notify then
			table.remove(notifyPush , i)
		end
	end
	
	ClearNotifyType(notify)
	NotifyListener()
end

function RequestNotifyInfo(notify , callback)
	local req = ClientMsg_pb.MsgClientNotifyInfoRequest()
	req.notify:append(notify)
	
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgClientNotifyInfoRequest, req, ClientMsg_pb.MsgClientNotifyInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
           SetData(msg)
		   OnDealNotifyPush(notify)
		   if callback ~= nil then
				callback()
		   end
        end
    end, true)
end
		 
function RequestMutiNotifyInfo(notifies , callback)
	local req = ClientMsg_pb.MsgClientNotifyInfoRequest()
	for i , v in pairs(notifies) do
		print(v)
		req.notify:append(v)
	end
	
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgClientNotifyInfoRequest, req, ClientMsg_pb.MsgClientNotifyInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
           SetData(msg)
		   for i , v in pairs (notifies) do
				OnDealNotifyPush(v)
		   end
		   if callback ~= nil then
				callback()
		   end
        end
    end, true)
end

function RequestNotifyTypeInfo(callback)
	local req = ClientMsg_pb.MsgClientNotifyTypeRequest()
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgClientNotifyTypeRequest, req, ClientMsg_pb.MsgClientNotifyTypeResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
           SetNotifyTypeData(msg)
		   if callback ~= nil then
				callback()
		   end
        end
    end, true)
end
