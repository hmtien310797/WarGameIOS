module("ActivityExchangeData", package.seeall)
local activityExchangeData
local eventListener = EventListener()
local PlayerPrefs = UnityEngine.PlayerPrefs

local TableMgr = Global.GTableMgr

function GetData()
    return activityExchangeData
end

function SetData(data)
    activityExchangeData = data
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

function RequestData(callback, lockScreen)
    local req = ActivityMsg_pb.MsgExchangeListRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgExchangeListRequest, req, ActivityMsg_pb.MsgExchangeListResponse, function(msg)
        SetData(msg)
        NotifyListener()
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback()
            end
        end
    end, not lockScreen)
end

function GetExchangeMsg(activityId, exchangeId)
    for _, v in ipairs(activityExchangeData.infoLists) do
        if v.activityId == activityId then
            for __, vv in ipairs(v.infos) do
                if vv.baseId == exchangeId then
                    return vv
                end
            end
        end
    end
end

function UpdateExchangeCount(exchangeId, exchangeCount)
    for _, v in ipairs(activityExchangeData.infoLists) do
        for __, vv in ipairs(v.infos) do
            if vv.baseId == exchangeId then
                vv.currentCount = exchangeCount
                NotifyListener()
                return
            end
        end
    end
end

local function CanExchange(exchangeMsg, exchangeData, vipLevel)
    if exchangeMsg.currentCount >= exchangeMsg.maxCount then
        return false
    end

    local itemList = string.split(exchangeData.ExchangeItemID, ";")
    for ii, vv in ipairs(itemList) do
        local itemIdList = string.split(vv, ":")
        local itemId = tonumber(itemIdList[1])
        local itemCount = tonumber(itemIdList[2])
        local hasCount = ItemListData.GetItemCountByBaseId(itemId)
        if hasCount < itemCount then
            return false
        end
    end

    if vipLevel < exchangeData.VIP then
        return false
    end

    return true
end

function HasNotice(activityId)
    local vipLevel = MainData.GetVipLevel()
    for _, v in ipairs(activityExchangeData.infoLists) do
        if ActivityData.IsActivityAvailable(v.activityId) then
            if activityId == nil or v.activityId == activityId then
                for __, vv in ipairs(v.infos) do
                    if PlayerPrefs.GetInt(string.format("ExchangeNotice_%d_%d", v.activityId, vv.baseId), 1) == 1 then
                        local exchangeData = ExchangeTableData.GetData().dataTable[vv.baseId]
                        if CanExchange(vv, exchangeData, vipLevel) then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end
