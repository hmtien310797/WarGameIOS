module("ActionListData", package.seeall)
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
        if v.uid == uid then
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

function GetGuildMobaActionData()
	local actData = {}
	if actionListData ~= nil then
		for k , v in ipairs(actionListData) do
			if v.status == Common_pb.PathEntryStatus_GuildMoba then
				table.insert(actData , v)
			end
		end
	end
	return actData
end

function RequestData()
    local req = MapMsg_pb.ActionListRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.ActionListRequest, req, MapMsg_pb.ActionListResponse, function(msg)
        SetData(msg.info)
        if msg.code == ReturnCode_pb.Code_OK then
            NotifyListener()
        end
    end, true)
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
		PathEntryStatus_GuildMoba 跨服战的援助也不占用行军队列
		]]
        if v.pathtype ~= Common_pb.TeamMoveType_Prisoner and v.pathtype ~= 22 and v.status ~= Common_pb.PathEntryStatus_GuildMoba then
            count = count + 1
        end
    end

    return count
end

function GetMaxCount()
    local baseLevel = BuildingData.GetCommandCenterData().level
    local coreData = TableMgr:GetBuildCoreDataByLevel(baseLevel)
    return coreData.armyNumber + (AttributeBonus.CollectBonusInfo()[1088] ~= nil and AttributeBonus.CollectBonusInfo()[1088] or 0)
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
			actNum = actNum + va.num
		end
	end
	return actNum
end
