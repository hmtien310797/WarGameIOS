module("UnionBuildingData", package.seeall)
local unionBuildingData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr
local hasNotice = false
local checkNotice = true

local buildingDataList
function GetBuildingDataList()
    if buildingDataList == nil then
        buildingDataList = {}
        local dataList = TableMgr:GetUnionBuildingList()
		for i, v in pairs(dataList) do
            local buildingType = v.type
            if buildingDataList[buildingType] == nil then
                buildingDataList[buildingType] = {}
            end
            table.insert(buildingDataList[buildingType], v)
		end
    end

    return buildingDataList
end

function GetData()
    return unionBuildingData
end

function SetData(data)
    unionBuildingData = data
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
    SetData(data)
    NotifyListener()
end

function GetDataByBaseId(baseId)
    if unionBuildingData == nil then
        return nil
    end
    for _, v in ipairs(unionBuildingData.build.build) do
        if v.baseid == baseId then
            return v
        end
    end

    return nil
end

function HasBuilding(baseId)
    return GetDataByBaseId(baseId) ~= nil
end

function HasBuildingByType(buildingType)
    if unionBuildingData == nil then
        return false
    end
    for _, v in ipairs(unionBuildingData.build.build) do
        local buildingData = TableMgr:GetUnionBuildingData(v.baseid)
        if buildingData ~= nil and buildingData.type == buildingType then
            return true
        end
    end

    return false
end

function CheckNotice()
    local dataList = GetBuildingDataList()
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    for k, v in kpairs(dataList) do
        for __, vv in ipairs(v) do
            if v[1].needBuild and not HasBuildingByType(vv.type) then
                local leftSecond = Global.GetLeftCooldownSecond(unionMsg.createTime + v[1].unlockTime)
                if leftSecond <= 0 then
                    hasNotice = true
                    return
                end
            end
        end
    end
end

function RequestData(callback, unlockScreen)
    local req = MapMsg_pb.MsgGuildBuildingRequest()
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGuildBuildingRequest, req, MapMsg_pb.MsgGuildBuildingResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
            if checkNotice then
                checkNotice = false
                CheckNotice()
            end
        end
    end, unlockScreen)
end

function GetDataByUid(uid)
    if unionBuildingData == nil then
        return nil
    end
    for _, v in ipairs(unionBuildingData.build.build) do
        if v.uid == uid then
            return v
        end
    end

    return nil
end

function HasSelfArmy(data)
    local charId = MainData.GetCharId()
    for _, v in ipairs(data.armys) do
        if v.charId == charId then
            return true
        end
    end

    return false
end

function HasBuildingBuilt(baseId, buildingData)
    local buildingData = buildingData or TableMgr:GetUnionBuildingData(baseId) 
	if buildingData == nil then
		return false
	end
	
    if not buildingData.needBuild then
        return true
    end

    local buildingMsg = GetDataByBaseId(baseId)
    if buildingMsg == nil then
        return false
    end

    if buildingMsg.isCompleted then
        return true
    end

    local leftSecond = Global.GetLeftCooldownSecond(buildingMsg.completeTime)
    if  leftSecond <= 0 then
        return true
    end

    return false
end

function SetCheckNotice()
    checkNotice = true
end

function HasNotice()
    return hasNotice and UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_DeclareWar)
end

function CancelNotice()
    if hasNotice then
        hasNotice = false
        NotifyListener()
    end
end

