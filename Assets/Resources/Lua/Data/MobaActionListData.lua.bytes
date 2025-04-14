module("MobaActionListData", package.seeall)
local actionListData = {}
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function Sort1()
    table.sort(actionListData, function(v1, v2)
        return v1.starttime > v2.starttime
    end)
end

function GetData()
    return actionListData
end

function GetActionData(uid)
    for _, v in ipairs(actionListData) do
        if tonumber(v.uid) == tonumber(uid) then
            return v
        end
    end
end

function GetActionDataByAttachPath(attachPathId)
    for _, v in ipairs(actionListData) do
        if tonumber(v.attachPathId) == tonumber(attachPathId) then
            return v
        end
    end
end

function SetData(data)
    actionListData = data
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
	if Global.GetMobaMode() == 1 then
		local req = MobaMsg_pb.MsgMobaActionListRequest()
		Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaActionListRequest, req, MobaMsg_pb.MsgMobaActionListResponse, function(msg)
			Global.DumpMessage(msg,"D:/22.lua")
			SetData(msg.info)
			if msg.code == ReturnCode_pb.Code_OK then
				NotifyListener()
			end
		end, true)
	elseif Global.GetMobaMode() == 2 then
		local req = GuildMobaMsg_pb.GuildMobaActionListRequest()
		Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaActionListRequest, req, GuildMobaMsg_pb.GuildMobaActionListResponse, function(msg)
			Global.DumpMessage(msg,"D:/22.lua")
			SetData(msg.info)
			if msg.code == ReturnCode_pb.Code_OK then
				NotifyListener()
			end
		end, true)
	end
end

function UpdateData(msg)
    local syncType = msg.synctype
    if syncType == MapMsg_pb.SMT_add then
        for _, v in ipairs(msg.info) do
            actionListData:add()
            actionListData[#actionListData] = v
        end
    elseif syncType == MapMsg_pb.SMT_del then
        for _, v in ipairs(msg.info) do
            for ii, vv in ipairs(actionListData) do
                if vv.uid == v.uid then
                    actionListData:remove(ii)
                    break
                end
            end
        end
    elseif syncType == MapMsg_pb.SMT_update then
        for _, v in ipairs(msg.info) do
            local find = false
            for ii, vv in ipairs(actionListData) do
                if vv.uid == v.uid then
                    actionListData[ii] = v
                    find = true
                    break
                end
            end
            if not find then
                actionListData:add()
                actionListData[#actionListData] = v
            end
        end
    end
    NotifyListener()
end

function GetValidCount()
    local count = 0
    for _, v in ipairs(actionListData) do
		--[[
		俘虏和联盟援助的path不计入行军队列。因为热更不能更新协议文件，所以这里使用22数字代替协议中的枚举类型
		]]
        if v.pathtype ~= Common_pb.TeamMoveType_Prisoner and v.pathtype ~= 22 then
            count = count + 1
        end
    end

    return count
end

function GetMaxCount()
	if Global.GetMobaMode() == 1 then
		local coreData = TableMgr:GetMobaUnitInfoTable()[5]
		local mobaTech = MobaTechData.GetMobaTech()
		
		local numTech = 0
		for ii, vv in pairs(mobaTech) do
			if ii == 1 then
				 local data = TableMgr:GetMobaTech()
				 for i, v in pairs(data) do
					if vv.data ~= nil then 
						if vv.data.level == v.Level and v.TechId ==1 then 
							local str = string.split(v.TechAttribute, ",")
							numTech = tonumber(str[3])
						end 
					end 
				end
			end
		end
		return  tonumber(coreData.Value) + numTech
	else
		local baseLevel = BuildingData.GetCommandCenterData().level
		local coreData = TableMgr:GetBuildCoreDataByLevel(baseLevel)
		AttributeBonus.CollectBonusInfo()
		local Bonus = AttributeBonus.GetBonusInfos()
		local pathCount = coreData.armyNumber + (Bonus[1088] ~= nil and Bonus[1088] or 0)
		return  pathCount 
	end 
end

function GetLeftCount()
    return GetMaxCount() - GetValidCount()
end

function IsFull()
    return GetLeftCount() <= 0
end

function GetCountByPathType(pathType)
    local count = 0
    for _, v in ipairs(actionListData) do
        if v.pathtype == pathType then
            count = count + 1
        end
    end
    return count
end

function HasPathType(pathType)
    return GetCountByPathType(pathType) > 0
end

function IsGatherCalling()
    for _, v in ipairs(actionListData) do
        if v.pathtype == Common_pb.TeamMoveType_GatherCall and v.status ~= Common_pb.PathMoveStatus_Back then
            return true
        end
    end

    return false
end

function GetActionArmyTotalNum()
	local actNum = 0
	for _ , v in ipairs(actionListData) do
		local armys = v.army.army.army
		for _ , va in ipairs(armys) do
			actNum = actNum + va.num - va.deadNum
		end
	end
	return actNum
end
