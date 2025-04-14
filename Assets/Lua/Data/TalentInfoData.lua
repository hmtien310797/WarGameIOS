module("TalentInfoData", package.seeall)
local talentInfoData
local eventListener = EventListener()

local talentKeyValueData, totallevel, maxindex

local function MakeKeyValueData()
	talentKeyValueData = {}
	totallevel = 0
	totallevels = {}
	for i, v in ipairs(talentInfoData.talentInfos) do
		talentKeyValueData[v.index] = {}
		talentKeyValueData[v.index].remainderPoint = v.remainderPoint
		talentKeyValueData[v.index].infos = {}
		for ii, vv in ipairs(v.infos) do
			if vv.id ~= nil and vv.level ~= nil then
				talentKeyValueData[v.index].infos[vv.id] = vv.level
				if totallevels[v.index] == nil then
					totallevels[v.index] = 0
				end
				totallevels[v.index] = totallevels[v.index] + vv.level
			end
		end
	end
	for i, v in ipairs(totallevels) do
		if totallevel < v then
			totallevel = v
			maxindex = i
		end
	end
end

function GetTotalLevel()
	return totallevel
end

function GetMaxLevel()
	local num = GetTotalLevel() + GetRemainderPoint(maxindex)
	if num == 0 then
		num = 1
	end
	return num
end

local function NotifyListener()
	MakeKeyValueData()
	--AttributeBonus.CollectBonusInfo()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetCurrentIndexRemainderPoint()
	if talentKeyValueData ~= nil and talentKeyValueData[talentInfoData.useIndex] ~= nil then
		return talentKeyValueData[talentInfoData.useIndex].remainderPoint
	end
	return 0
end

function GetRemainderPoint(index)
	if talentKeyValueData ~= nil and talentKeyValueData[index] ~= nil then
		return talentKeyValueData[index].remainderPoint
	end
	return 0
end

function GetTalentLevelByIndexId(index, id)
	if talentKeyValueData ~= nil and talentKeyValueData[index] ~= nil and talentKeyValueData[index].infos[id] ~= nil then
		return talentKeyValueData[index].infos[id]
	end
	return 0
end

function GetTalentLevelById(id)
	if talentKeyValueData ~= nil and talentKeyValueData[talentInfoData.useIndex] ~= nil and talentKeyValueData[talentInfoData.useIndex].infos[id] ~= nil then
		return talentKeyValueData[talentInfoData.useIndex].infos[id]
	end
	return 0
end

function GetKeyValueData()
	return talentKeyValueData
end

function GetData()
    return talentInfoData
end

function SetData(data)
    talentInfoData = data
end

function RequestData(callback)
    local req = ClientMsg_pb.MsgUserTalentGetRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserTalentGetRequest, req, ClientMsg_pb.MsgUserTalentGetResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetData(msg.info)
            if callback ~= nil then
            	callback()
            end
            NotifyListener()
        end
    end, true)
end

local function UpdateData(msg)
	for i,v in ipairs(talentInfoData.talentInfos) do
		if v.index == msg.index then
			v.remainderPoint = msg.remainderPoint
			for ii,vv in ipairs(v.infos) do
				if vv.id == msg.idInfo.id then
					vv.level = msg.idInfo.level
					return
				end
			end
			table.insert(v.infos, msg.idInfo)
		end
	end
end

function RequestLevelUp(id, number)
	local req = ClientMsg_pb.MsgUserTalentSaveRequest()
	req.index = talentInfoData.useIndex
	req.id = id
	req.number = number
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserTalentSaveRequest, req, ClientMsg_pb.MsgUserTalentSaveResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            UpdateData(msg)
            NotifyListener()
        end
    end, false)
end

local function UpdateOperate(msg)
	if msg.oType == 1 then
		for i,v in ipairs(talentInfoData.talentInfos) do
			if v.index == msg.info.index then
				talentInfoData.talentInfos:remove(i)
				table.insert(talentInfoData.talentInfos, msg.info)
			end
		end
	elseif msg.oType == 2 then
		talentInfoData.useIndex = msg.useIndex
	end
end

function RequestOperate(type, index)
	local req = ClientMsg_pb.MsgUserTalentOperateRequest()
	req.oType = type
	req.index = index
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserTalentOperateRequest, req, ClientMsg_pb.MsgUserTalentOperateResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            UpdateOperate(msg)
            NotifyListener()
            MainCityUI.UpdateRewardData(msg.fresh)
        end
    end, false)
end
