module("Welfare_Template1Data", package.seeall)
local rechargeData
local eventListener = EventListener()

----- Events --------------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

local function BroadcastEventOnDataChange(...)
    EventDispatcher.Broadcast(eventOnDataChange, ...)
end
---------------------------------------------------------------

function GetData()
    return rechargeData
end

local function UpdateAccumulateRechargeData(data, index)
	if data ~= nil then
		for i, v in ipairs(data.accumRewardInfos) do
			if v.index == index then
				v.status = ActivityMsg_pb.RewardStatus_HasTaken
			end
		end
	end
end

local function UpdateDailyData(data, index)
	if data ~= nil then
		for i, v in ipairs(data.dailyRewardInfos) do
			if v.index == index then
				v.status = ActivityMsg_pb.RewardStatus_HasTaken
			end
		end
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

function RequestAccumulateRecharge(callback)
    local req = ActivityMsg_pb.MsgAccumulateRechargeInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgAccumulateRechargeInfoRequest, req, ActivityMsg_pb.MsgAccumulateRechargeInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            rechargeData.AccumulateRecharge = msg      
            NotifyListener()
            if callback~= nil then
                callback()
            end
            local refreshid = ActivityData.GetActivityIdByTemplete(305)
            WelfareData.UpdateUncollectedRewards(refreshid)
			WelfareAll.RefreshTab()
            BroadcastEventOnDataChange(refreshid)
        end
    end, true)
end

function RequestDailyConsume(callback)
    local req = ActivityMsg_pb.MsgDailyConsumeInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgDailyConsumeInfoRequest, req, ActivityMsg_pb.MsgDailyConsumeInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            rechargeData.DailyConsume = msg         
            NotifyListener()
            if callback~= nil then
                callback()
            end
            local refreshid = ActivityData.GetActivityIdByTemplete(306)
            WelfareData.UpdateUncollectedRewards(refreshid)
			WelfareAll.RefreshTab()
            BroadcastEventOnDataChange(refreshid)
        end
    end, true)
end

function RequestAccumulateConsume(callback)
	local req = ActivityMsg_pb.MsgAccumulateConsumeInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgAccumulateConsumeInfoRequest, req, ActivityMsg_pb.MsgAccumulateConsumeInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            rechargeData.AccumulateConsume = msg         
            NotifyListener()
        	if callback ~= nil then
        		callback()
            end
            local refreshid = ActivityData.GetActivityIdByTemplete(309)
            WelfareData.UpdateUncollectedRewards(refreshid)
			WelfareAll.RefreshTab()
			MainCityUI.UpdateWelfareNotice()
            BroadcastEventOnDataChange(refreshid)
        end
    end, true)
end


function RequestDailyRecharge(callback)
    local req = ActivityMsg_pb.MsgDailyRechargeInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgDailyRechargeInfoRequest, req, ActivityMsg_pb.MsgDailyRechargeInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            rechargeData.DailyRecharge = msg           
            NotifyListener()
            if callback~= nil then
                callback()
            end
            local refreshid = ActivityData.GetActivityIdByTemplete(307)
            WelfareData.UpdateUncollectedRewards(refreshid)
			WelfareAll.RefreshTab()
            BroadcastEventOnDataChange(refreshid)
        end
    end, true)
end

function RequestData()    
    if rechargeData==nil then
        rechargeData = {}
    end
    RequestAccumulateRecharge()
    RequestDailyConsume()
    RequestDailyRecharge()
    RequestAccumulateConsume()
end

function TakeAccumulateRechargeReward(index, callback)
	local req = ActivityMsg_pb.MsgTakeAccumulateRechargeRewardRequest()
	req.index = index
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeAccumulateRechargeRewardRequest, req, ActivityMsg_pb.MsgTakeAccumulateRechargeRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateAccumulateRechargeData(rechargeData.AccumulateRecharge, msg.index)
            MainCityUI.UpdateRewardData(msg.fresh)
        	ItemListShowNew.SetTittle(Global.GTextMgr:GetText("getitem_hint"))
            ItemListShowNew.SetItemShow(msg)
            Global.GGUIMgr:CreateMenu("ItemListShowNew" , false)
            local refreshid = ActivityData.GetActivityIdByTemplete(305)
            BroadcastEventOnDataChange(refreshid)
            WelfareData.UpdateUncollectedRewards(refreshid)
			WelfareAll.RefreshTab()
        	if callback ~= nil then
        		callback()
        	end
        end
    end, false)
end

function TakeDailyConsumeReward(index, callback)
	local req = ActivityMsg_pb.MsgTakeDailyConsumeRewardRequest()
	req.index = index
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeDailyConsumeRewardRequest, req, ActivityMsg_pb.MsgTakeDailyConsumeRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateDailyData(rechargeData.DailyConsume, msg.index)
            MainCityUI.UpdateRewardData(msg.fresh)
        	ItemListShowNew.SetTittle(Global.GTextMgr:GetText("getitem_hint"))
            ItemListShowNew.SetItemShow(msg)
            Global.GGUIMgr:CreateMenu("ItemListShowNew" , false)
            local refreshid = ActivityData.GetActivityIdByTemplete(306)
            BroadcastEventOnDataChange(refreshid)
            WelfareData.UpdateUncollectedRewards(refreshid)
			WelfareAll.RefreshTab()
        	if callback ~= nil then
        		callback()
        	end
        end
    end, false)
end

function TakeDailyRechargeReward(index, callback)
	local req = ActivityMsg_pb.MsgTakeDailyRechargeRewardRequest()
	req.index = index
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeDailyRechargeRewardRequest, req, ActivityMsg_pb.MsgTakeDailyRechargeRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateDailyData(rechargeData.DailyRecharge, msg.index)
            MainCityUI.UpdateRewardData(msg.fresh)
        	ItemListShowNew.SetTittle(Global.GTextMgr:GetText("getitem_hint"))
            ItemListShowNew.SetItemShow(msg)
            Global.GGUIMgr:CreateMenu("ItemListShowNew" , false)
            local refreshid = ActivityData.GetActivityIdByTemplete(307)
            BroadcastEventOnDataChange(refreshid)
            WelfareData.UpdateUncollectedRewards(refreshid)
			WelfareAll.RefreshTab()
        	if callback ~= nil then
        		callback()
        	end
        end
    end, false)
end

function TakeAccumulateConsumeReward(index, callback)
	local req = ActivityMsg_pb.MsgTakeAccumulateConsumeRewardRequest()
	req.index = index
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeAccumulateConsumeRewardRequest, req, ActivityMsg_pb.MsgTakeAccumulateConsumeRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateAccumulateRechargeData(rechargeData.AccumulateConsume, msg.index)
            MainCityUI.UpdateRewardData(msg.fresh)
        	ItemListShowNew.SetTittle(Global.GTextMgr:GetText("getitem_hint"))
            ItemListShowNew.SetItemShow(msg)
            Global.GGUIMgr:CreateMenu("ItemListShowNew" , false)

            RequestAccumulateConsume()

        	if callback ~= nil then
        		callback()
        	end
        end
    end, false)
end


function HasTakeAccumulateRechargeReward()
    if rechargeData.AccumulateRecharge == nil then
        return false
    end
    local has = false
    for i,v in ipairs(rechargeData.AccumulateRecharge.accumRewardInfos) do
        if v.status == ActivityMsg_pb.RewardStatus_CanTake then
            has = true
            break
        end
    end  
    return has  
end

function HasTakeAccumulateConsumeReward()
    if rechargeData.AccumulateConsume == nil then
        return false
    end
    local has = false
    for i,v in ipairs(rechargeData.AccumulateConsume.accumRewardInfos) do
        if v.status == ActivityMsg_pb.RewardStatus_CanTake then
            has = true
            break
        end
    end  
    return has  
end

function HasTakeDailyConsumeReward()
    if rechargeData.DailyConsume == nil then
        return false
    end
    local has = false
    for i,v in ipairs(rechargeData.DailyConsume.dailyRewardInfos) do
        if v.status == ActivityMsg_pb.RewardStatus_CanTake then
            has = true
            break
        end
    end  
    return has  
end

function HasTakeDailyRechargeReward()
    if rechargeData.DailyRecharge == nil then
        return false
    end
    local has = false
    for i,v in ipairs(rechargeData.DailyRecharge.dailyRewardInfos) do
        if v.status == ActivityMsg_pb.RewardStatus_CanTake then
            has = true
            break
        end
    end  
    return has  
end

function HasNotice()
    -- return ActivityData.HasActivity(SevenDay) and not HasTakenReward()
end
