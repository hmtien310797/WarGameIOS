module("BuildingData", package.seeall)

local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime
local HeroListData = HeroListData

local eventListener = EventListener()
local buildingData

function GetData()
    return buildingData
end

function SetData(data)
    buildingData = data
end

function RequestData(callback)
	local req = BuildMsg_pb.MsgBuildListRequest()
	--LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgBuildListRequest, req:SerializeToString(), function(typeId, data)
	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgBuildListRequest, req, BuildMsg_pb.MsgBuildListResponse, function(msg)
		SetData(msg)
		if callback ~= nil then
			callback(msg)
		end
	end, true)
end

function GetCommandCenterData()
	for _, v in ipairs(buildingData.buildList) do
		if v.type == 1 then
			return v
		end
	end
end

function UpdateHomeFailTime(msg)
	buildingData.mapHomeFailTime = msg.mapHomeFailTime
end

function GetBuildingDataById(buildingId)
	for _, v in ipairs(buildingData.buildList) do
		if v.type == buildingId then
			return v
		end
	end

	return nil
end

function HasBuildingDataById(buildingId)
    return GetBuildingDataById(buildingId) ~= nil
end

function GetBuildingDataByUid(buildingUid)
	for _, v in ipairs(buildingData.buildList) do
		if v.uid == buildingUid then
			return v
		end
	end

	return nil
end

function HasBuildingDataByUid(buildingUid)
    return GetBuildingDataById(buildingUid) ~= nil
end

function GetBuildingDataByIdLevel(buildingId, buildingLevel)
	for _, v in ipairs(buildingData.buildList) do
		if v.type == buildingId and v.level == buildingLevel then
			return v
		end
	end

	return nil
end

function HasBuildingDataByIdLevel(buildingId, buildingLevel)
    return GetBuildingDataByIdLevel(buildingId, buildingLevel) ~= nil
end

function GetLevelGreaterBuildingDataById(buildingId, buildingLevel)
	for _, v in ipairs(buildingData.buildList) do
		if v.type == buildingId and v.level >= buildingLevel then
			return v
		end
	end

	return nil
end

function HasLevelGreaterBuildingDataById(buildingId, buildingLevel)
    return GetLevelGreaterBuildingDataById(buildingId, buildingLevel) ~= nil
end

function GetBuildingHeroAttrByData(data)
    local attrValue1 = 0
    local attrValue2 = 0
    local attrValue3 = 0
    
    local heroListData = HeroListData.GetData()
    for _, v in ipairs(heroListData) do
        if v.appointInfo.buildType == data.id then
            local heroData = TableMgr:GetHeroData(v.baseid)
            local heroPower = HeroListData.GetPower(v, heroData)
            attrValue1 = attrValue1 + HeroListData.GetPowerCoef(heroPower) * data.value1
            attrValue2 = attrValue2 + HeroListData.GetPowerCoef(heroPower) * data.value2
            attrValue3 = attrValue3 + HeroListData.GetPowerCoef(heroPower) * data.value3
        end
    end

    if attrValue1 > 0 then
        return data, attrValue1, attrValue2, attrValue3
    end

    return nil
end

function GetBuildingHeroAttrById(buildingId)
    local data = TableMgr:GetBuildingData(buildingId)
    return GetBuildingHeroAttrByData(data)
end

function GetAppointedHeroMsg(buildingId, index)
    local heroListData = GeneralData.GetGenerals()
    for _, v in ipairs(heroListData) do
        if v.appointInfo.buildType == buildingId and v.appointInfo.index == index then
            return v
        end
    end

    return nil
end

function HasAppointedHeroByIndex(buildingId, index)
    return GetAppointedHeroMsg(buildingId, index) ~= nil
end

function NeedAppointHeroByIndex(data, index)
    if HeroAppointUI.IsUnlockByBuildingData(data, index) then
        if not HasAppointedHeroByIndex(data.id, index) then
            return true
        end
    end

    return false
end

function HasAppointedHero(buildingId)
    for i = 1, 2 do
        if HasAppointedHeroByIndex(buildingId, i) then
            return true
        end
    end

    return false
end

function NeedAppointHero(data)
    if data.appointType == 0 then
        return false
    end

    if not GeneralData.HasNonAppointedGeneral() then
        return false
    end

    for i = 1, 2 do
        if NeedAppointHeroByIndex(data, i) then
            return true
        end
    end

    return false
end
