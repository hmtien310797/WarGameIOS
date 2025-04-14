module("WorldCityData", package.seeall)
local worldCityData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return worldCityData
end

function SetData(data)
    worldCityData = data
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

function UpdateData(cityinfo , notify)
	if worldCityData == nil then
		return
	end
	
	for i=1 , #worldCityData do
		if worldCityData[i].cityId == cityinfo.cityId then
			worldCityData[i] = cityinfo
		end
	end
	
	if notify then
		NotifyListener()
	end
end

function IsUnlock(cityId)
	local city = TableMgr:GetWorldCityDataByID(cityId)
	if not city then
		return nil
	end
	 
	local unlock = false
	local finishFront = false
	local frontCity = WorldCityData.GetCityInfo(city.FrontCity)
	if city.FrontCity == 0 then
		finishFront = true
	else
		if frontCity ~= nil and frontCity.occupied then
			finishFront = true
		end
	end
	
	local rankData = TableMgr:GetMilitaryRankTable()[tonumber(MainData.GetMilitaryRankID())]
	local curMilitaryRankLv = rankData and rankData.RankLevel or 0
	local overMilitaryRank = (curMilitaryRankLv >= city.MilitaryRank)
	local finishRebel = RebelSurroundNewData.IsOver()
	unlock = finishFront and overMilitaryRank and finishRebel
	
	return {unlock = unlock , finishFront = finishFront , overMilitaryRank = overMilitaryRank , finishRebel = finishRebel}
end

function GetCityInfo(cityId)
	local cityinfo 
	if worldCityData == nil then
		return cityinfo 
	end
	
	for i=1 , #worldCityData do
		if worldCityData[i].cityId == cityId then
			cityinfo = worldCityData[i]
		end
	end
	
	return cityinfo
end

function GetWorldCityProcess(cityInfo , cityId)
	--local cityInfo = GetCityInfo(cityId)
	if cityInfo == nil then
		return 0
	end
	
	if cityInfo.occupied then
		return 1
	end
	
	local build_data = TableMgr:GetWorldCityDataByID(cityId)
	local curWave = cityInfo.wave
	local defenceTotal = 0
	local defenceLeft = 0
	local enemStr = string.split(build_data.BattleId , ";")
	for i=1 , #enemStr do
		local battleData = TableMgr:GetBattleFieldData(enemStr[i])
		if battleData then
			local soldierStr = string.msplit(battleData.soldier , ";" , ":")
			for i=1 , #soldierStr do
				local soldierCount = tonumber(soldierStr[i][3])
				defenceTotal = defenceTotal + soldierCount
			end
		end
		
		if i == curWave then
			for k=1 , #cityInfo.monsterArmy.army.army do
				defenceLeft = defenceLeft + cityInfo.monsterArmy.army.army[k].num
			end
			--print("111 msg left " , defenceLeft)
		end

		if i > curWave then
			if battleData then
				local soldierStr = string.msplit(battleData.soldier , ";" , ":")
				for k=1 , #soldierStr do
					local soldierCount = tonumber(soldierStr[k][3])
					defenceLeft = defenceLeft + soldierCount
				end
			end
			--print("22222 config left " , defenceLeft)
		end
	end
	
	--print("3333 result" , defenceTotal , defenceLeft)
	return (defenceTotal - defenceLeft)/defenceTotal
end 

function RequestCityInfo(cityId , callback)
	local req = MapMsg_pb.MsgWorldCityInfoRequest()
	req.cityId = cityId
	Global.DumpMessage(req, "d:/citywar.lua")
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgWorldCityInfoRequest, req, MapMsg_pb.MsgWorldCityInfoResponse, function(msg)
			Global.DumpMessage(msg, "d:/citywar.lua")
		if msg.code == ReturnCode_pb.Code_OK then
			UpdateData(msg.info)
            if callback ~= nil then
            	callback(msg.info)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestData(callback, lockScreen)
    local req = MapMsg_pb.MsgAllWorldCityInfoRequest()
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgAllWorldCityInfoRequest, req, MapMsg_pb.MsgAllWorldCityInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			SetData(msg.infoList)
			NotifyListener()
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function GetApplyCount()
    return #worldCityData.applicants
end

function HasNotice()
    return #worldCityData.applicants > 0 or #worldCityData.positionApplicants > 0
end

function HasCollectNotice()
	if worldCityData == nil then
		return false
	end
    for _, v in ipairs(worldCityData) do
        if v.reputationNum > 0 then
            return true
        end
    end

    return false
end
