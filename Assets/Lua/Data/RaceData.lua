module("RaceData", package.seeall)
local raceData = {}
local eventListener = EventListener()
local GameTime = Serclimax.GameTime

local TableMgr = Global.GTableMgr

local isNew = false

function GetData()
    return raceData
end

function SetData(data)
    raceData = data
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function NotifyAvailable()
	isNew = true
end

function NotifyUIOpened()
	if isNew then
		isNew = false
		NotifyListener()
	end
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function RequestData(unlockScreen)
    local req = ClientMsg_pb.MsgGetRaceInfoRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetRaceInfoRequest, req, ClientMsg_pb.MsgGetRaceInfoResponse, function(msg)
        SetData(msg)
        NotifyListener()
    end, unlockScreen)
end

function GetRaceDataByActId(actId)
    if raceData ~= nil then
        for i, v in ipairs(raceData.data) do
            if v.actId == actId then
                return v
            end
        end
    end
end

function UpdateRaceData(data)
    if raceData ~= nil then
        for i, v in ipairs(raceData.data) do
            if v.actId == data.actId then
                raceData.data[i] = data
                NotifyListener()
                break
            end
        end
    end
end

function UpdateRaceValue(actId, newValue)
	if raceData ~= nil and raceData.data ~= nil then
		for i, v in ipairs(raceData.data) do
			if v.actId == actId then
				local raceData = tableData_tStatisticsList.data[v.actId]
				local raceType = raceData.completeType
				local rewardData = tableData_tStatisticsReward.data[v.actLevel]

				for j = 1, 3 do
					local value = rewardData["needFight" .. j]
					if newValue >= value and v.value < value then
						RequestData(true)
						break
					end
				end
				v.value = newValue
				NotifyListener()
				break
			end
		end
	end
end

function HasNoticeByType(raceType)
    for i, v in ipairs(raceData.data) do
        if v.actId ~= 0 then
            local raceData = tableData_tStatisticsList.data[v.actId]
            if raceData.completeType == raceType then
                local rewardData = tableData_tStatisticsReward.data[v.actLevel]
                for j = 1, 3 do
                    local value = rewardData["needFight" .. j]
                    if v.value >= value then
                        for __, vv in ipairs(v.reward) do
                            if vv == j then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

function HasNotice()
	if raceData ~= nil and ActivityData.isBattleFieldActivityAvailable(103) then
		if isNew then
			return true
		end

        for i = 1, 2 do
            if HasNoticeByType(i) then
                return true
            end
        end
	end

    return false
end
