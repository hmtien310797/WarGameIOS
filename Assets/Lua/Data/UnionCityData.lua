module("UnionCityData", package.seeall)

local GUIMgr = Global.GGUIMgr
local TextMgr = Global.GTextMgr

local BUILDING_TYPES = { Common_pb.SceneEntryType_Govt,
                         Common_pb.SceneEntryType_Fortress,
                         Common_pb.SceneEntryType_Stronghold, }

----- Events ------------------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()
local eventOnRewardStatusChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

function OnRewardStatusChange()
    return eventOnRewardStatusChange
end

local function BroadcastEventOnDataChange(...)
    EventDispatcher.Broadcast(eventOnDataChange, ...)
end

local function BroadcastEventOnRewardStatusChange(...)
    EventDispatcher.Broadcast(eventOnRewardStatusChange, ...)
end
-------------------------------------------------------------------

----- Data ----------------------------------------------------------------------------
local occupiedBuildings = {}
local occupiedBuildingCounts = {}
local occupationStatus = {}

local rewardStatus = {}
local rewardlessBuildings

local rulingStrongholdLimit
local rulingFortressLimit 

function GetStrongholdLimit()
    return rulingStrongholdLimit
end

function GetFortressLimit()
    return rulingFortressLimit
end

function GetOccupiedBuildings(sceneEntryType, subType)
    if not sceneEntryType then
        return occupiedBuildings
    elseif not subType then
        return occupiedBuildings[sceneEntryType]
    else
        return occupiedBuildings[sceneEntryType][subType]
    end
end

function GetOccupiedBuildingCounts(sceneEntryType)
    if sceneEntryType then
        return occupiedBuildingCounts[sceneEntryType]
    else
        return occupiedBuildingCounts
    end
end

local function GetBuildingUID(guildCityInfo)
    return guildCityInfo.entryType * 10000 + guildCityInfo.subType
end

local function AddRewardlessBuilding(guildCityInfo)
    rewardlessBuildings[GetBuildingUID(guildCityInfo)] = guildCityInfo
end

local function RemoveRewardlessBuilding(guildCityInfo)
    rewardlessBuildings[GetBuildingUID(guildCityInfo)] = nil
end

function GetRewardlessBuildings()
    return rewardlessBuildings
end

local function SetRewardStatus(guildCityInfo, hasUnclaimedReward)
    local sceneEntryType = guildCityInfo.entryType
    local subType = guildCityInfo.subType

    if hasUnclaimedReward ~= HasUnclaimedRewards(sceneEntryType, subType) then
        if hasUnclaimedReward then
            RemoveRewardlessBuilding(guildCityInfo)
        else
            AddRewardlessBuilding(guildCityInfo)
        end

        rewardStatus[sceneEntryType] = bit.write(rewardStatus[sceneEntryType], hasUnclaimedReward and 1 or 0, subType)
        
        BroadcastEventOnRewardStatusChange(guildCityInfo, hasUnclaimedReward)
    end
end

function HasUnclaimedRewards(sceneEntryType, subType)
    if not sceneEntryType then
        for _, int in pairs(rewardStatus) do
            if int ~= 0 then
                return true
            end
        end

        return false
    elseif not subType then
        return rewardStatus[sceneEntryType] ~= 0
    else
        return bit.read(rewardStatus[sceneEntryType], subType) ~= 0
    end
end

local function SetOccupationStatus(sceneEntryType, subType, flag)
    occupationStatus[sceneEntryType] = bit.write(occupationStatus[sceneEntryType], flag and 1 or 0, subType)
end

function IsOccupied(sceneEntryType, subType)
    if not sceneEntryType then
        for _, int in pairs(occupationStatus) do
            if int ~= 0 then
                return true
            end
        end

        return false
    elseif not subType then
        return occupationStatus[sceneEntryType] ~= 0
    else
        return bit.read(occupationStatus[sceneEntryType], subType) ~= 0
    end
end

local function AddData(guildCityInfo)
    local sceneEntryType = guildCityInfo.entryType
    local subType = guildCityInfo.subType

    occupiedBuildings[sceneEntryType][subType] = guildCityInfo
    occupiedBuildingCounts[sceneEntryType] = occupiedBuildingCounts[sceneEntryType] + 1
    occupiedBuildingCounts.all = occupiedBuildingCounts.all + 1

    local hasUnclaimedReward = guildCityInfo.canTakeTime <= Serclimax.GameTime.GetSecTime()
    if not hasUnclaimedReward then
        AddRewardlessBuilding(guildCityInfo)
    end

    SetOccupationStatus(sceneEntryType, subType, true)
    SetRewardStatus(guildCityInfo, hasUnclaimedReward)

    BroadcastEventOnDataChange(guildCityInfo, 1)
end

local function UpdateData(guildCityInfo)
    occupiedBuildings[guildCityInfo.entryType][guildCityInfo.subType].canTakeTime = guildCityInfo.canTakeTime

    SetRewardStatus(guildCityInfo, guildCityInfo.canTakeTime <= Serclimax.GameTime.GetSecTime())

    BroadcastEventOnDataChange(guildCityInfo, 0)
end

local function RemoveData(guildCityInfo)
    local sceneEntryType = guildCityInfo.entryType
    local subType = guildCityInfo.subType

    SetOccupationStatus(sceneEntryType, subType, false)
    SetRewardStatus(guildCityInfo, false)

    RemoveRewardlessBuilding(guildCityInfo)

    occupiedBuildings[sceneEntryType][subType] = nil
    occupiedBuildingCounts[sceneEntryType] = occupiedBuildingCounts[sceneEntryType] - 1
    occupiedBuildingCounts.all = occupiedBuildingCounts.all - 1

    BroadcastEventOnDataChange(guildCityInfo, -1)
end

local function SetData(msg)
    rulingStrongholdLimit = msg.rulingStrongholdLimit
    rulingFortressLimit = msg.rulingFortressLimit

    local shouldNotBeRemoved = {}
    for _, sceneEntryType in pairs(BUILDING_TYPES) do
        shouldNotBeRemoved[sceneEntryType] = 0
    end

    for _, guildCityInfo in ipairs(msg.infos) do
        local sceneEntryType = guildCityInfo.entryType
        local subType = guildCityInfo.subType

        local memorizedData = occupiedBuildings[sceneEntryType][subType]
        if memorizedData then
            if guildCityInfo.canTakeTime ~= memorizedData.canTakeTime then
                UpdateData(guildCityInfo)
            end
        else
            AddData(guildCityInfo)
        end

        shouldNotBeRemoved[sceneEntryType] = bit.write(shouldNotBeRemoved[sceneEntryType], 1, subType)
    end

    for _, sceneEntryType in pairs(BUILDING_TYPES) do
        if shouldNotBeRemoved[sceneEntryType] ~= occupationStatus[sceneEntryType] then
            local shouldBeRemoved = bit.band(occupationStatus[sceneEntryType], bit.bnot(shouldNotBeRemoved[sceneEntryType]))
            for subType, guildCityInfo in pairs(occupiedBuildings[sceneEntryType]) do
                if bit.read(shouldBeRemoved, subType) ~= 0 then
                    RemoveData(guildCityInfo)
                end
            end
        end
    end
end

local function ResetData()
    occupiedBuildingCounts.all = 0
    
    rewardlessBuildings = {}

    for _, sceneEntryType in pairs(BUILDING_TYPES) do
        occupiedBuildings[sceneEntryType] = {}
        occupiedBuildingCounts[sceneEntryType] = 0
        occupationStatus[sceneEntryType] = 0

        rewardStatus[sceneEntryType] = 0
    end
end
---------------------------------------------------------------------------------------

function RequestData(callback)
    local request = GuildMsg_pb.MsgGuildCityListRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildCityListRequest, request, GuildMsg_pb.MsgGuildCityListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)

            if callback then
                callback(msg)
            end
        elseif callback then
            ResetData()
            callback()
        end
    end, true)
end

function ClaimRewards(sceneEntryType, subType, callbackOnSuccess)
    local request = GuildMsg_pb.MsgGuildTakeCityRewardRequest()
    request.seUid = occupiedBuildings[sceneEntryType][subType].seUid
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildTakeCityRewardRequest, request, GuildMsg_pb.MsgGuildTakeCityRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
            ItemListShowNew.SetItemShow(msg)
            GUIMgr:CreateMenu("ItemListShowNew" , false)

            MainCityUI.UpdateRewardData(msg.fresh)

            UpdateData(msg.info)

            if callbackOnSuccess then
                callbackOnSuccess()
            end
        else
            Global.ShowError(msg.code)
        end
    end, true)
end

function Initialize()
    ResetData()

    RequestData(function()
        EventDispatcher.Bind(Global.OnTick(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(now)
            for _, guildCityInfo in pairs(rewardlessBuildings) do
                if guildCityInfo.canTakeTime <= now then
                    SetRewardStatus(guildCityInfo, true)
                end
            end
        end)

        EventDispatcher.Bind(UnionInfoData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(new, old)
            if new.guildInfo.guildId == 0 then
                ResetData()
            else
                RequestData()
            end
        end)

        EventDispatcher.Bind(GovernmentData.OnRulingPush(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(msg)
            local occupiedBuilding = occupiedBuildings[Common_pb.SceneEntryType_Govt][0]
            if occupiedBuilding then
                RemoveData(occupiedBuilding)
            elseif msg.archonInfo.guildId == UnionInfoData.GetGuildId() then
                RequestData()
            end
        end)

        EventDispatcher.Bind(FortressData.OnRulingPush(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(msg)
            local occupiedBuilding = occupiedBuildings[Common_pb.SceneEntryType_Fortress][msg.FortressInfo.subtype]
            if occupiedBuilding then
                RemoveData(occupiedBuilding)
            elseif msg.FortressInfo.rulingInfo.guildId == UnionInfoData.GetGuildId() then
                RequestData()
            end
        end)

        EventDispatcher.Bind(StrongholdData.OnRulingPush(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(msg)
            local occupiedBuilding = occupiedBuildings[Common_pb.SceneEntryType_Stronghold][msg.strongholdInfo.subtype]
            if occupiedBuilding then
                RemoveData(occupiedBuilding)
            elseif msg.strongholdInfo.rulingInfo.guildId == UnionInfoData.GetGuildId() then
                RequestData()
            end
        end)
    end)
end

function Test() -- UnionCityData.Test()
    UnionCity.Show()

    MessageBox.Show("将开始测试，请不要点击鼠标", function()
        coroutine.start(function()
            coroutine.wait(1)

            Test_SetData()

            coroutine.wait(3)

            Test_RemoveData()

            coroutine.wait(6)

            Test_UpdateData()

            coroutine.wait(15)

            RequestData()

            MessageBox.Show("测试完成", function() end)
        end)
    end, UnionCity.CloseAll)
end

function Test_AddData() -- UnionCityData.Test_AddData()
    local guildCityInfo = {}
    guildCityInfo.entryType = Common_pb.SceneEntryType_Stronghold
    guildCityInfo.subType = 10
    guildCityInfo.canTakeTime = Serclimax.GameTime.GetSecTime() + 10

    AddData(guildCityInfo)
end

function Test_UpdateData() -- UnionCityData.Test_UpdateData()
    Test_AddData()

    coroutine.start(function()
        local guildCityInfo = {}
        guildCityInfo.entryType = Common_pb.SceneEntryType_Stronghold
        guildCityInfo.subType = 10
        guildCityInfo.canTakeTime = Serclimax.GameTime.GetSecTime() + 10

        coroutine.wait(3)

        UpdateData(guildCityInfo)
    end)
end

function Test_RemoveData() -- UnionCityData.Test_RemoveData()
    Test_AddData()

    coroutine.start(function()
        coroutine.wait(3)
        RemoveData(occupiedBuildings[Common_pb.SceneEntryType_Stronghold][10])
    end)
end

function Test_SetData() -- UnionCityData.Test_SetData()
    ResetData()

    local now = Serclimax.GameTime.GetSecTime()

    local msg1 = {}
    msg1.code = ReturnCode_pb.Code_OK

    local guildCityInfoS1 = {}
    guildCityInfoS1.entryType = Common_pb.SceneEntryType_Stronghold
    guildCityInfoS1.subType = 1
    guildCityInfoS1.canTakeTime = now + 60

    local guildCityInfoS2 = {}
    guildCityInfoS2.entryType = Common_pb.SceneEntryType_Stronghold
    guildCityInfoS2.subType = 2
    guildCityInfoS2.canTakeTime = now + 120

    local guildCityInfoS3 = {}
    guildCityInfoS3.entryType = Common_pb.SceneEntryType_Stronghold
    guildCityInfoS3.subType = 3
    guildCityInfoS3.canTakeTime = now + 180

    local guildCityInfoF1 = {}
    guildCityInfoF1.entryType = Common_pb.SceneEntryType_Fortress
    guildCityInfoF1.subType = 1
    guildCityInfoF1.canTakeTime = now + 180

    local guildCityInfoG = {}
    guildCityInfoG.entryType = Common_pb.SceneEntryType_Govt
    guildCityInfoG.subType = 0
    guildCityInfoG.canTakeTime = now + 180

    msg1.infos = {}
    table.insert(msg1.infos, guildCityInfoS1)
    table.insert(msg1.infos, guildCityInfoS2)
    table.insert(msg1.infos, guildCityInfoS3)
    table.insert(msg1.infos, guildCityInfoF1)
    table.insert(msg1.infos, guildCityInfoG)

    SetData(msg1)

    local msg2 = {}
    msg2.code = ReturnCode_pb.Code_OK

    local guildCityInfoS2_new = {}
    guildCityInfoS2_new.entryType = Common_pb.SceneEntryType_Stronghold
    guildCityInfoS2_new.subType = 2
    guildCityInfoS2_new.canTakeTime = now + 300

    local guildCityInfoS4 = {}
    guildCityInfoS4.entryType = Common_pb.SceneEntryType_Stronghold
    guildCityInfoS4.subType = 4
    guildCityInfoS4.canTakeTime = now + 240

    msg2.infos = {}
    table.insert(msg2.infos, guildCityInfoS1)
    table.insert(msg2.infos, guildCityInfoS2_new)
    table.insert(msg2.infos, guildCityInfoS4)

    SetData(msg2)
end
