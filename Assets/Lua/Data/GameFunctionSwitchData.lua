module("GameFunctionSwitchData", package.seeall)

local gsListData = nil
local eventListener = EventListener()

GFSwitch = 
{
	GFSwitch_EliteChapter = 1 , 
	GFSwitch_CDKey = 2 , 
	GFSwitch_GrowpPath = 3 , 
}
function GetData()
    return gsListData
end

function SetData(data)
    gsListData = data
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
    local req = ClientMsg_pb.MsgGameFunctionSwitchRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGameFunctionSwitchRequest, req, ClientMsg_pb.MsgGameFunctionSwitchResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			Global.DumpMessage(msg , "d:/funcSwitch.lua")
            SetData(msg.data)
            NotifyListener()
        end
    end, true)
end

function Switch(gameFunc)
	if  gsListData then
		for i=1 , #gsListData , 1 do
			if gsListData[i].id == gameFunc then
				return gsListData[i].enable == 0
			end
		end
	end
	return false
end