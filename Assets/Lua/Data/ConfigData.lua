module("ConfigData", package.seeall)

local GameTime = Serclimax.GameTime
local configData
local eventListener = EventListener()
local defaultConfigList =
{
    Tutorial =
    {
    },
    Event = 
    {
    },
    Story =
    {
    },
    SceneStory = 2,

    CashShop = nil,
    giftpackHistory = {},
    limitedGiftPacks = {},

    VipExperienceCard = false,
    GameStateTutorial = false,
    hasSetNationality = false,
    lastShareTime = -1,
}

local configList = {}

local TableMgr = Global.GTableMgr

----- Events ------------------------------------------------------
local eventOnGiftpackHistoryChange = EventDispatcher.CreateEvent()

local function BroadcastEventOnGiftpackHistoryChange()
    EventDispatcher.Broadcast(eventOnGiftpackHistoryChange)
end
-------------------------------------------------------------------

function GetData()
    return configData
end

function SetData(data)
    configData = data
    for _, v in ipairs(configData) do
        configList[v.key] = cjsonSafe.decode(v.value)
    end
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

local function RequestData(callback)
    local req = ClientMsg_pb.MsgGetClientStrRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetClientStrRequest, req, ClientMsg_pb.MsgGetClientStrResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetData(msg.data)

            callback()
        end
    end, true)
end

function SaveData(key, data)
    local req = ClientMsg_pb.MsgSetClientStrRequest()
    req.key = key
    req.value = cjson.encode(data)
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgSetClientStrRequest, req, ClientMsg_pb.MsgSetClientStrResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        end
    end, true)
end

local function GetConfig(key)
    return configList[key] or defaultConfigList[key]
end

local function SetConfig(key, config)
    configList[key] = config
    SaveData(key, config)
end

function GetGameStateTutorial()
    if ServerListData.IsAppleReviewing() then
        return true
    end

    return GetConfig("GameStateTutorial")
end

function SetGameStateTutorial(config)
    SetConfig("GameStateTutorial", config)
end

function GetVipExperienceCard()
    return GetConfig("VipExperienceCard")
end

function SetVipExperienceCard(config)
    SetConfig("VipExperienceCard", config)
end

function GetTutorialConfig()
    return GetConfig("Tutorial")
end

function SetTutorialConfig(config)
    SetConfig("Tutorial", config)
end

function GetEventConfig()
    return GetConfig("Event")
end

function SetEventConfig(config)
    SetConfig("Event", config)
end

function GetSceneStoryConfig()
    return GetConfig("SceneStory")
end

function SetSceneStoryConfig(config)
    SetConfig("SceneStory", config)
end

function GetStoryConfig()
    local complete = tonumber(GetConfig("Story"))
    if complete == nil then
        complete = 0
    end
    return complete
end

function SetStoryConfig(config)
    SetConfig("Story", config)
end

function SetRebelSurroundConfig(config)
    SetConfig("RebelSurround", config)
end

function SetCashShopConfig(config)
    SetConfig("CashShop", config)
end

function GetCashShopConfig()
    return GetConfig("CashShop")
end

function GetLastShareTime()
    return GetConfig("lastShareTime")
end

function SetLastShareTime(lastShareTime)
    SetConfig("lastShareTime", lastShareTime)
end

local doNeedInitialization_giftpackHistory = false

function GetGiftPackConfigIndex(iapGoodsInfo)
    return tostring(math.ceil(iapGoodsInfo.index / 32))
end

function SetGiftPackHistory(iapGoodsInfo, isNew)
    if doNeedInitialization_giftpackHistory or GetGiftPackHistory(iapGoodsInfo) ~= isNew then
        local config = configList.giftpackHistory

        local index = iapGoodsInfo.index
        local configIndex = GetGiftPackConfigIndex(iapGoodsInfo)

        if not config[configIndex] then
            config[configIndex] = 0
        end

        config[configIndex] = bit.write(config[configIndex], isNew and 0 or 1, index % 32)

        BroadcastEventOnGiftpackHistoryChange()
    end
end

function GetGiftPackHistory(iapGoodsInfo)
    local index = iapGoodsInfo.index
    local configIndex = GetGiftPackConfigIndex(iapGoodsInfo)

    return not doNeedInitialization_giftpackHistory and bit.read(configList.giftpackHistory[configIndex] or 0, index % 32) == 0
end

function ResetGiftPackHistory()
    configList.giftpackHistory = {}
    doNeedInitialization_giftpackHistory = true
    BroadcastEventOnGiftpackHistoryChange()
end

function GetRebelSurroundConfig()
	local complete = tonumber(GetConfig("RebelSurround"))
	if complete == nil then
		complete = 0
	end
    return complete
end

function HasTutorialFinished(moduleId)
    local tutorialConfig = GetTutorialConfig()
    for _, v in ipairs(tutorialConfig) do
        if v == moduleId then
            return true
        end
    end
    return false
end

function SetHasSetNationality(config)
    if not HasSetNationality() then
        SetConfig("hasSetNationality", config)
    end
end

function HasSetNationality()
    return GetConfig("hasSetNationality")
end

function SetLimitedGiftPack(iapGoodInfo)
    if not configList.limitedGiftPacks then
        configList.limitedGiftPacks = defaultConfigList.limitedGiftPacks
    end

    local endTime = iapGoodInfo.endTime
    if configList.limitedGiftPacks[tostring(iapGoodInfo.id)] ~= endTime then
        configList.limitedGiftPacks[tostring(iapGoodInfo.id)] = endTime

        SaveData("limitedGiftPacks", configList.limitedGiftPacks)
    end
end

function ResetLimitedGiftPacks() -- ConfigData.ResetLimitedGiftPacks()
    configList.limitedGiftPacks = {}
    SaveData("limitedGiftPacks", configList.limitedGiftPacks)
end

function GetLimitedGiftPack(id)
    return GetConfig("limitedGiftPacks")[tostring(id)] or 0
end

function Initialize()
    RequestData(function()
        if not configList.giftpackHistory then
            ResetGiftPackHistory()
        end

        EventDispatcher.Bind(eventOnGiftpackHistoryChange, _M, EventDispatcher.HANDLER_TYPE.STATIC_DELAYED, function()
            SaveData("giftpackHistory", configList.giftpackHistory)
            doNeedInitialization_giftpackHistory = false
        end)
    end)
end
