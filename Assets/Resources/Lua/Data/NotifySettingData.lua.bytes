module("NotifySettingData", package.seeall)

local GameTime = Serclimax.GameTime
local configData
local currentNotifyLanguage
local eventListener = EventListener()


local configList = {}

local TableMgr = Global.GTableMgr

function GetData()
    return configData
end

function SetData(data)
    configData = data
    for _, v in ipairs(configData) do
		print(v)
        configList[v] = v
    end
end

function UpdateData(key , flag)
	
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

function RequestData()
    local req = ClientMsg_pb.MsgGetNotificationsSettingRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetNotificationsSettingRequest, req, ClientMsg_pb.MsgGetNotificationsSettingResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetData(msg.data.id)
        end
    end, true)
end

function GetConfig(key)
    return configList[key]
end

local function CheckSaveList(saveList)
	local save = false
	for _ , v in ipairs(saveList) do
		print(v , configList[v])
		if configList[v] == nil then
			save = true
			break
		end
	end
	
	return true
end

function SetConfig(saveList , callback)
	if CheckSaveList(saveList) then
		local req = ClientMsg_pb.MsgFreshNotificationsSettingRequest()
		for _ , v in pairs(saveList) do
			print(v)
			req.data.id:append(v)
		end
		Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgFreshNotificationsSettingRequest, req, ClientMsg_pb.MsgFreshNotificationsSettingResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				configList = {}
				SetData(msg.data.id)
				if callback ~= nil then
					callback()
				end
			end
		end, true)
	else
		if callback ~= nil then
			callback()
		end
	end
end

function RequestNoticeLanguage(languageId , callback)
	currentNotifyLanguage = languageId
	local req = ClientMsg_pb.MsgSetNotificationsLangRequest()
	req.lang = currentNotifyLanguage
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgSetNotificationsLangRequest, req, ClientMsg_pb.MsgSetNotificationsLangResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			if callback ~= nil then
				callback()
			end
		end
	end, true)
end
