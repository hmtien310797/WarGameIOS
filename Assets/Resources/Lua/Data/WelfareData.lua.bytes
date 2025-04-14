module("WelfareData", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local triggerBagList
local triggerBagEventListener = EventListener()

local configs = {}
local welfares = {}

local uncollectedRewards = {}

local hasUncollectedRewards = {}

local isNew = {}

local SORT_BY_NOTICE = true

----- Events --------------------------------------------------
local eventOnAwardStatusChange = EventDispatcher.CreateEvent()

function OnAwardStatusChange()
    return eventOnAwardStatusChange
end

local function BroadcastEventOnAwardStatusChange(...)
    EventDispatcher.Broadcast(eventOnAwardStatusChange, ...)
end
---------------------------------------------------------------

function GetWelfareConfig(id)
	if id ~= nil then
		return configs[id]
	end

	return configs
end

function GetWelfare(id)
	return welfares[id]
end

function GetWelfareNum()
	return #welfares
end

local function IsNew(id)
	if id == nil then
		for id, flag in pairs(isNew) do
			if flag then
				return true
			end
		end

		return false
	end

	return isNew[id] or false
end

function HasNotice(id)
	return HasUncollectedRewards(id) or IsNew(id)
end

function UpdateNotice(id)
	return UpdateUncollectedRewards(id) or IsNew(id)
end

function UpdateUncollectedRewards(id)
	if id == nil then
		for id, config in pairs(configs) do
			UpdateUncollectedRewards(id)
		end

		return hasUncollectedRewards
	end

	local config = configs[id]
	if config == nil or not config.isAvailable then
		return false
	end
	
	if id == 3001 then -- 成长基金
		UpdateWelfareProgression(3001)
		return hasUncollectedRewards[3001]
	elseif id == 3002 then
		hasUncollectedRewards[id] = not SevenDayData.HasTakenReward()
		return hasUncollectedRewards[id]
	elseif id == 3003 then
		hasUncollectedRewards[id] = not ThirtyDayData.HasTakenReward() or ThirtyDayData.IsAccuRewardCanTake()
		return hasUncollectedRewards[id]
	elseif id == 3004 then
		hasUncollectedRewards[id] = not MonthCardData.HasTakenReward()
		return hasUncollectedRewards[id]
	elseif id == ActivityData.GetActivityIdByTemplete(305) then
		hasUncollectedRewards[id] = Welfare_Template1Data.HasTakeAccumulateRechargeReward()
		return hasUncollectedRewards[id]
	elseif id == ActivityData.GetActivityIdByTemplete(306) then
		hasUncollectedRewards[id] = Welfare_Template1Data.HasTakeDailyConsumeReward()
		return hasUncollectedRewards[id]
	elseif id == ActivityData.GetActivityIdByTemplete(307) then
		hasUncollectedRewards[id] = Welfare_Template1Data.HasTakeDailyRechargeReward()
		return hasUncollectedRewards[id]
	elseif id == 5001 then
		hasUncollectedRewards[id] = IsTriggerBagCanTake(1)
		return hasUncollectedRewards[id]
	elseif id == 5002 then
		hasUncollectedRewards[id] = IsTriggerBagCanTake(2)
		return hasUncollectedRewards[id]
	elseif id == 7000 then
		hasUncollectedRewards[id] = HeroCardData.HasUnclaimedAward()
		return hasUncollectedRewards[id]
	elseif id == ActivityData.GetActivityIdByTemplete(309) then
		hasUncollectedRewards[id] = Welfare_Template1Data.HasTakeAccumulateConsumeReward()
		return hasUncollectedRewards[id]
	elseif id == 3013 then
		hasUncollectedRewards[id] = ContinueRechargeData.HasUnclaimedAward(3013)
		return hasUncollectedRewards[id]
	elseif id == 3014 then
		hasUncollectedRewards[id] = ContinueRechargeData.HasUnclaimedAward(3014)
		return hasUncollectedRewards[id]
	elseif id == 3015 then
		hasUncollectedRewards[id] = WarLossData.HasUnclaimedAward()
		return hasUncollectedRewards[id]
	elseif id == LuckyRotaryData.GetActivityId() then
		hasUncollectedRewards[id] = LuckyRotaryData.HasUnclaimedAward()
		return hasUncollectedRewards[id]
	elseif id == ActivityData.GetActivityIdByTemplete(313) then
		hasUncollectedRewards[id] = Welfare_HerogetData.HasUnclaimedAward(id)
		return hasUncollectedRewards[id]
	elseif id == ActivityData.GetActivityIdByTemplete(314) then
		hasUncollectedRewards[id] = Rebate_LuckyRotary.HasUnclaimedAward(id)
		return hasUncollectedRewards[id]
	elseif id == ActivityData.GetActivityIdByTemplete(315) then
		hasUncollectedRewards[id] = ReturnRewards.HasUnclaimedAward(id)
		return hasUncollectedRewards[id]
	end

	print(string.format("[WelfareData.hasUncollectedRewards] No related method (id = %d)", id))
	return false
end

function HasUncollectedRewards(id)
	if id == nil then
		for _, flag in pairs(hasUncollectedRewards) do
			if flag then
				print("活动ID：",_)
				return true
			end
		end

		return false
	end

	local config = configs[id]
	if config == nil or not config.isAvailable then
		return false
	end

	return hasUncollectedRewards[id] or false
end

function UpdateWelfareProgression(id)
	if id == nil then
		for id, config in pairs(configs) do
			if config.isAvailable then
				UpdateWelfareProgression(id)
			end
		end
	elseif id == 3001 then -- 成长基金
		local commandCenterLevel = BuildingData.GetCommandCenterData().level

		local welfare = welfares[3001]
		if welfare ~= nil and welfare.hasBuy then
			local flag = false
			for _, stage in ipairs(welfare.progress) do
				local previousStatus = stage.status
				stage.status = math.max(commandCenterLevel >= stage.needLevel and ShopMsg_pb.GrowFundStatus_CanTake or 1, previousStatus)

				flag = flag or stage.status == ShopMsg_pb.GrowFundStatus_CanTake

				if stage.status ~= previousStatus then
					table.insert(uncollectedRewards, 300100 + stage.id)
				end
			end

			if hasUncollectedRewards[3001] ~= flag then
				hasUncollectedRewards[3001] = flag
				BroadcastEventOnAwardStatusChange(3001, flag)
			end
		end
	else
		print(System.String.Format("[ERROR][WelfareData.hasUncollectedRewards] No related method (id = {0}})", id or "nil"))
	end

	return hasUncollectedRewards[id]
end

function NotifyWelfareAvailable(id)
	if id ~= nil then
		local availableConfig = configs[id]
		if availableConfig ~= nil then
			availableConfig.isAvailable = true
		else
			configs[id] = {isAvailable = true}
		end

		isNew[id] = true
	else
		Global.LogDebug(_M, "NotifyWelfareAvailable", "Invalid id (nil)")
	end
end

function NotifyWelfareUnavailable(id)
	if id ~= nil then
		local unavailableConfig = configs[id]
		if unavailableConfig ~= nil then
			unavailableConfig.isAvailable = false
			WelfareAll.NotifyWelfareUnavailable(id)
		end

		MainCityUI.UpdateWelfareNotice(id)
	else
		Global.LogDebug(_M, "NotifyWelfareUnavailable", "Invalid id (nil)")
	end
end

function NotifyUIOpened(id)
	if isNew[id] then
		isNew[id] = false
		MainCityUI.RefreshWelfareNotice(id)
	end
end

function SetWelfareProgression(welfareID, stageID, status)
	if welfareID == 3001 then -- 成长基金
		local welfare = welfares[3001]
		if welfare.hasBuy then
			for _, stage in ipairs(welfare.progress) do
				if stage.id == stageID then
					local previousStatus

					if stage.status == ShopMsg_pb.GrowFundStatus_CanTake and status == ShopMsg_pb.GrowFundStatus_HasTake then
						for key, id in pairs(uncollectedRewards) do
							if id == 300100 + stageID then
								table.remove(uncollectedRewards, key)
								break
							end
						end
					end

					stage.status = status
					MainCityUI.UpdateWelfareNotice(3001)

					break
				end
			end
		else
			print("[WelfareData.SetWelfareProgression] Welfare has not yet been purchased (id = 3001)")
		end
	end
end

function CollectReward(welfareID, stageID, callback)
	if welfareID == 3001 then
		local req = ShopMsg_pb.MsgTakeGrowFundRewardRequest()
		req.id = stageID
	    Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgTakeGrowFundRewardRequest, req, ShopMsg_pb.MsgTakeGrowFundRewardResponse, function(msg)
	        if msg.code == ReturnCode_pb.Code_OK then
				GUIMgr:SendDataReport("reward", "TakeGrowthFund", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
			
				MainCityUI.UpdateRewardData(msg.fresh)
				
				for i = 1, #msg.reward.item.item do
					local itemData = TableMgr:GetItemData(msg.reward.item.item[i].baseid)
					if itemData ~= nil then
						local nameColor = Global.GetLabelColorNew(itemData.quality)
						local showText = System.String.Format(TextMgr:GetText("online_5"), nameColor[0] .. TextUtil.GetItemName(itemData) .. nameColor[1])
						FloatText.Show(showText, Color.white, ResourceLibrary:GetIcon("Item/", itemData.icon))
						AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
					end
				end

				SetWelfareProgression(welfareID, stageID, ShopMsg_pb.GrowFundStatus_HasTake)
				UpdateWelfareProgression(welfareID)

				if callback ~= nil then
					callback()
				end
			else
				Global.ShowError(msg.code)
	        end
	    end)
	end
end

function Purchase(id)
	local goodInfo = welfares[id].goodInfo
	store.StartPay(goodInfo, TextMgr:GetText(goodInfo.name))
end

function SuccessfullyPurchase(id)
	local welfare = welfares[id]
	if welfare ~= nil then
		welfare.hasBuy = true
		UpdateWelfareProgression(id)
	end
end

local function MakeConfigs(activities)
	local count = 0
    local sortedActivities = {}

    local now = Serclimax.GameTime.GetSecTime()
	configs = {}
    for _, activity in ipairs(activities) do
        local templete = activity.templet
        if templete >= 300 and templete < 400 then
        	if SORT_BY_NOTICE then 
        		if configs[activity.activityId] == nil then
        			configs[activity.activityId] = {isAvailable = now < activity.endTime}
        		else
        			configs[activity.activityId].isAvailable = now < activity.endTime
        		end
        	end

            table.insert(sortedActivities, activity)
            count = count + 1
        end
	end
	
	--插入触发礼包
	if triggerBagList ~= nil then
		for i, v in ipairs(triggerBagList) do
			local activity = {}
			activity.activityId = 5000 + v.type
			activity.endTime = v.endTime
			activity.name = v.name
			activity.icon = v.icon
			activity.templet = 501
			activity.canTake = v.canTake
			activity.order = 10000
			activity.countid = 0
			activity.data = v
			table.insert(activities, activity)
			if SORT_BY_NOTICE then 
				if configs[activity.activityId] == nil then
					configs[activity.activityId] = {isAvailable = activity.canTake and true or (now < activity.endTime)}
				else
					configs[activity.activityId].isAvailable = activity.canTake and true or (now < activity.endTime)
				end
			end
			table.insert(sortedActivities, activity)
            count = count + 1
		end
	end
	--插入触发礼包

    if SORT_BY_NOTICE then
    	UpdateUncollectedRewards()
    end

    table.sort(sortedActivities, function(activity1, activity2)
    	-- if activity1.isOpen ~= activity2.isOpen then
    	-- 	return activity1.isOpen
    	-- end

    	if SORT_BY_NOTICE then
			local hasUncollectedRewards1 = HasUncollectedRewards(activity1.activityId)
			local hasUncollectedRewards2 = HasUncollectedRewards(activity2.activityId)

			if hasUncollectedRewards1 ~= hasUncollectedRewards2 then
				return hasUncollectedRewards1
			end
    	end

        return activity1.order > activity2.order
    end)

    for tab, activity in pairs(sortedActivities) do
        local config = {}
        config.id = activity.activityId
        config.name = activity.name
        config.icon = activity.icon
        config.endTime = activity.endTime
        config.isAvailable = activity.canTake and true or (now < activity.endTime)
		config.Templet = activity.templet
		config.data = activity.data
        config.tab = tab

		configs[config.id] = config
    end

    if not SORT_BY_NOTICE then
    	UpdateUncollectedRewards()
	end

    return count
end

function RequestGrowGoldData(callback)
	local request = ShopMsg_pb.MsgGrowFundInfoRequest()
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgGrowFundInfoRequest, request, ShopMsg_pb.MsgGrowFundInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			local welfare = msg
			welfares[3001] = welfare

			if welfare.hasBuy then
				for _, stage in ipairs(welfare.progress) do
					if stage.status == ShopMsg_pb.GrowFundStatus_CanTake then
						table.insert(uncollectedRewards, 3001 * 100 + stage.id)
					end
				end
			end
		else
			Global.ShowError(msg.code)
		end
	end, true)
end

function RequestWelfareConfigs(callback)
	ActivityData.RequestWelfares(function(activities)
		local count = MakeConfigs(activities)

		if callback ~= nil then
			callback(configs, count)
		end
	end)
end

function Initialize()
	configs = ActivityData.GetWelfareConfigs()
	
	MainCityUI.UpdateWelfareNotice()
end

function GetTriggerBagList()
	if triggerBagList == nil then
		triggerBagList = {}
	end
	return triggerBagList
end

function IsTriggerBagCanTake(id)
	if triggerBagList == nil then
		return false
	end
	for i, v in ipairs(triggerBagList) do
		if id == v.type then
			return v.canTake
		end
	end
end

function NotifyTriggerBagListener()
	triggerBagEventListener:NotifyListener()
end

function AddTriggerBagListener(listener)
    triggerBagEventListener:AddListener(listener)
end

function RemoveTriggerBagListener(listener)
    triggerBagEventListener:RemoveListener(listener)
end

function RemoveTriggerBagConfig()
	for i = 5000, 5010 do
		configs[i] = nil
	end
end

function RequestTriggerBagList(callback)
	local request = ActivityMsg_pb.MsgTriggerBagListRequest()
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTriggerBagListRequest, request, ActivityMsg_pb.MsgTriggerBagListResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			triggerBagList = msg.bagInfos
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)
		end
	end, true)
end

function RequestTakeTriggerBagReward(type, param, callback)
	local request = ActivityMsg_pb.MsgTakeTriggerBagRewardRequest()
	request.type = type
	request.param = param
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeTriggerBagRewardRequest, request, ActivityMsg_pb.MsgTakeTriggerBagRewardResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			MainCityUI.UpdateRewardData(msg.fresh)
			Global.ShowReward(msg.reward)
			RemoveTriggerBagConfig()
			RequestTriggerBagList(callback)
		else
			Global.ShowError(msg.code)
		end
	end, true)
end

function UpdateTriggerBag(msg)
	for i, v in ipairs(msg.bagInfos) do
		local inlist = false
		for j, k in ipairs(triggerBagList) do
			if v.type == k.type and v.param == k.param then
				k = v
				inlist = true
			end
		end
		if not inlist then
			table.insert(triggerBagList, v)
		end
	end
	RequestTriggerBagList(function()
		NotifyTriggerBagListener()
		TimedBag.Show()
	end)
end
