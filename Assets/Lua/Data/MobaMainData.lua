module("MobaMainData", package.seeall)
local interface={
    ["Category_pb_RequestData"] = Category_pb.Moba,
    ["ClientMainDataRequest"]=MobaMsg_pb.MsgMobaClientMainDataRequest,
    ["ClientMainDataRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaClientMainDataRequest,
    ["ClientMainDataResponse"] = MobaMsg_pb.MsgMobaClientMainDataResponse,


    ["Category_pb_ReqGarrisonInfo"] = Category_pb.Moba,
    ["GetBuildGarrisonInfoRequest"]=MobaMsg_pb.MsgMobaGetBuildGarrisonInfoRequest,
    ["GetBuildGarrisonInfoRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaGetBuildGarrisonInfoRequest,
    ["GetBuildGarrisonInfoResponse"] = MobaMsg_pb.MsgMobaGetBuildGarrisonInfoResponse, 

}

local interface_guild={
    ["Category_pb_RequestData"] = Category_pb.GuildMoba,
    ["ClientMainDataRequest"]=GuildMobaMsg_pb.GuildMobaClientMainDataRequest,
    ["ClientMainDataRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaClientMainDataRequest,
    ["ClientMainDataResponse"] = GuildMobaMsg_pb.GuildMobaClientMainDataResponse,


    ["Category_pb_ReqGarrisonInfo"] = Category_pb.GuildMoba,
    ["GetBuildGarrisonInfoRequest"]=GuildMobaMsg_pb.GuildMobaGetBuildGarrisonInfoRequest,
    ["GetBuildGarrisonInfoRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetBuildGarrisonInfoRequest,
    ["GetBuildGarrisonInfoResponse"] = GuildMobaMsg_pb.GuildMobaGetBuildGarrisonInfoResponse, 
}

local function GetInterface(interface_name)
    if Global.GetMobaMode() == 1 then
        return interface[interface_name]
    elseif Global.GetMobaMode() == 2 then
        return interface_guild[interface_name]
    end
end



local mainData
local eventListener = EventListener()
local expireTime

local moba_base_garrison_infos




function GetData()
	return mainData
end

function SetData(data)
    mainData = data
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
	
    if mainData == nil then
		return
	end
	if data == nil or next(data) == nil --[[or #(data) == 0]] then
		return
	end
	
--	print("miandata ,",data.mobaScore,data.maxScore)
    
    if Global.GetMobaMode() == 1 then
        if data.maxScore >0 then 
            mainData.data.mobaScore = data.mobaScore
            mainData.data.maxScore = data.maxScore
        end 
    elseif Global.GetMobaMode() == 2 then
        if data.score >0 then 
            mainData.data.score = data.score
        end 
    end
    NotifyListener()
end


function RequestData(callback)
    local req = GetInterface("ClientMainDataRequest")()
	Global.Request(GetInterface("Category_pb_RequestData"), GetInterface("ClientMainDataRequestTypeID"), req, GetInterface("ClientMainDataResponse"), function(msg)
	   SetData(msg)
		if msg.code == ReturnCode_pb.Code_OK then
            NotifyListener()
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function GetTeamID()
    if mainData ~= nil then
        return mainData.team
    end
    return 0
end

function GetCharId()
    if mainData ~= nil then
        return mainData.charId
    end
    return 0
end

function GetPos()
    if mainData ~= nil then
        return mainData.pos
    end
    return nil
end


function GetGarrisonInfo(build_id)
    if moba_base_garrison_infos == nil then
        return nil
    end
    return moba_base_garrison_infos[build_id]
end

function SetGarrisonInfo(build_id,data)
    if moba_base_garrison_infos == nil then
        moba_base_garrison_infos = {}
    end    

    moba_base_garrison_infos[build_id] = {}
    moba_base_garrison_infos[build_id].garrisonCapacity = data.garrisonCapacity
    moba_base_garrison_infos[build_id].garrisonNum = data.garrisonNum
    moba_base_garrison_infos[build_id].seUid = data.seUid
    moba_base_garrison_infos[build_id].garrisonInfos = data.garrisonInfos
    moba_base_garrison_infos[build_id].garrisonMap = {}
    moba_base_garrison_infos[build_id].roleid = data.roleid
    if moba_base_garrison_infos[build_id].garrisonInfos ~= nil then
        for i =1,#moba_base_garrison_infos[build_id].garrisonInfos do
            local id = moba_base_garrison_infos[build_id].garrisonInfos[i].garrisonData.pathid..","..moba_base_garrison_infos[build_id].garrisonInfos[i].garrisonData.charid
            moba_base_garrison_infos[build_id].garrisonMap[id] = moba_base_garrison_infos[build_id].garrisonInfos[i]
        end
    end
end

function ReqGarrisonInfo(build_id,finish_callback)
    local build_msg = MobaZoneBuildingData.GetData(build_id)
    if build_msg == nil then
        return
    end
    local req = GetInterface("GetBuildGarrisonInfoRequest")()
    req.uid = build_msg.data.uid
    Global.Request(GetInterface("Category_pb_ReqGarrisonInfo"), GetInterface("GetBuildGarrisonInfoRequestTypeID"), req, GetInterface("GetBuildGarrisonInfoResponse"), function(msg)
        SetGarrisonInfo(build_id,msg)
        if finish_callback ~= nil then
            finish_callback()
        end
    end, true)
end

function IsCancelGarrison(target_charid,build_id)
	if GetCharId() == target_charid then
		return true
    end
    local grrison_info = GetGarrisonInfo(build_id)
    return   MobaData.GetRoleID() == grrison_info.roleid --GetCharId() == grrison_info.chiefid or
end 