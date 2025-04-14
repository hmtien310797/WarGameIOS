module("MilitaryRankData", package.seeall)
local militaryRankData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return militaryRankData
end

function SetData(data)
    militaryRankData = data
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

function RequestData(callback)
	local req = ClientMsg_pb.MsgMilitaryConditionRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgMilitaryConditionRequest, req, ClientMsg_pb.MsgMilitaryConditionResponse, function(msg)
        militaryRankData = msg
        NotifyListener()
        if callback ~= nil then
            callback()
        end
    end, true)
end

function UpdateCondition(condition)
    local oldConds1 = militaryRankData.conds[1]
    local newConds1 = condition[1]
    if newConds1 ~= nil then
        oldConds1.type = newConds1.type
        oldConds1.value = newConds1.value
        oldConds1.need = newConds1.need
        NotifyListener()
    end
end

function GetConditionMsg(rankId)
	if militaryRankData and militaryRankData.conds then
		for _, v in ipairs(militaryRankData.conds) do
			if v.id == rankId then
				return v
			end
		end
	end
end

function HasNotice()
	if not FunctionListData.IsFunctionUnlocked(302) then 
	    return false
    end

    local rankId = MainData.GetMilitaryRankID()
    local nextRankData = tableData_tMilitaryRank.data[rankId + 1]
    if nextRankData == nil then
        return false
    end
    if nextRankData.LevelupConsume ~= "" then
        for v in string.gsplit(nextRankData.LevelupConsume, ";") do
            local itemIdList = string.split(v, ":")
            local itemId = tonumber(itemIdList[1])
            local itemCount = tonumber(itemIdList[2])

            local hasCount = itemId == 19 and MoneyListData.GetReputation() or ItemListData.GetItemCountByBaseId(itemId)
            if hasCount < itemCount then
                return false
            end
        end
    end
    
    local conditionMsg = GetConditionMsg(rankId + 1)
    if conditionMsg ~= nil and conditionMsg.value < conditionMsg.need then
        return false
    end

    return true
end
