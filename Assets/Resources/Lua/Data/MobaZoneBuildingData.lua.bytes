module("MobaZoneBuildingData", package.seeall)

local eventListener = EventListener()
local TableMgr = Global.GTableMgr
local zoneBuildingDatas
local curSetDataBuildId

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetCurSetDataBuildId()
	return curSetDataBuildId
end

function GetData(build_id)
	if zoneBuildingDatas == nil then
		return nil
	end
    return zoneBuildingDatas[build_id]
end

function SetData(build_id,data)
	if zoneBuildingDatas == nil then
		zoneBuildingDatas = {}
	end
	curSetDataBuildId = build_id;
	if build_id == 0 then
		for i =1,#data.zeinfo do
			zoneBuildingDatas[data.zeinfo[i].buidingid] = data.zeinfo[i]
		end
	else
		zoneBuildingDatas[build_id] = data.zeinfo[1]
	end
	
    NotifyListener()
end

function GetDataWithCallBack(build_id,cb,force)
	if force or zoneBuildingDatas == nil or zoneBuildingDatas[build_id] == nil then
		if Global.GetMobaMode() == 1 then
			local req = MobaMsg_pb.MsgMobaGetZoneBuildingInfoRequest()
			req.uid = 0
			req.buildingid = build_id
			Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGetZoneBuildingInfoRequest, req, MobaMsg_pb.MsgMobaGetZoneBuildingInfoResponse, function(msg)
				if msg.code ~= ReturnCode_pb.Code_OK then
					Global.ShowError(msg.code)
				else
					Global.DumpMessage(msg)
					SetData(build_id,msg)
					if cb ~= nil then
						cb(zoneBuildingDatas[build_id])
					end
				end
			end, true)
		elseif Global.GetMobaMode() == 2 then
			local req = GuildMobaMsg_pb.GuildMobaGetZoneBuildingInfoRequest()
			req.uid = 0
			req.buildingid = build_id
			Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetZoneBuildingInfoRequest, req, GuildMobaMsg_pb.GuildMobaGetZoneBuildingInfoResponse, function(msg)
				if msg.code ~= ReturnCode_pb.Code_OK then
					Global.ShowError(msg.code)
				else
					Global.DumpMessage(msg)
					SetData(build_id,msg)
					if cb ~= nil then
						cb(zoneBuildingDatas[build_id])
					end
				end
			end, true)
		end
	else
		if cb ~= nil then
			cb(zoneBuildingDatas[build_id])
		end
	end

end

function RequestData()
	if Global.GetMobaMode() == 1 then
		local req = MobaMsg_pb.MsgMobaGetZoneBuildingInfoRequest()
		req.uid = 0
		req.buildingid = 0
		Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGetZoneBuildingInfoRequest, req, MobaMsg_pb.MsgMobaGetZoneBuildingInfoResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				SetData(0,msg)
			end
		end, true)
	elseif Global.GetMobaMode() == 2 then
		
		local req = GuildMobaMsg_pb.GuildMobaGetZoneBuildingInfoRequest()
		req.uid = 0
		req.buildingid = 0
		Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetZoneBuildingInfoRequest, req, GuildMobaMsg_pb.GuildMobaGetZoneBuildingInfoResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				SetData(0,msg)
			end
		end, true)
	end
end



