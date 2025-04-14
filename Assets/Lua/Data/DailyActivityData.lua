module("DailyActivityData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local eventListener = EventListener()
local activitys
local redpoints
local isNew = {}
local hasred = false
local exchangeItems
local kingsRoadBaseData

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetActivitys()
    return activitys
end

function HasNewActivity()
    for _, flag in pairs(isNew) do
        if flag then
            return true
        end
    end

    return false
end

function HasRedPoint()
    return HasNewActivity() or hasred
end

function HasExchangeRedPoint()
    return kingsRoadBaseData ~= nil and kingsRoadBaseData.exchangered
end

function GetRedpoints()
    return redpoints
end

function GetIsNew()
    return isNew
end

function GetKingsRoadBaseData()
    return kingsRoadBaseData
end

local function GetMission(id, missionlist)
	for i, v in pairs(missionlist) do
		if id == v.id then
			return v
		end
	end
	return nil
end

local function MakeKingsRoadBaseData(activity, missionMsgList)
    local missions = TableMgr:GetMissionListByActivity(activity.activityId)
    kingsRoadBaseData = {}
	kingsRoadBaseData.missions = {}
	kingsRoadBaseData.missiontable = {}
    kingsRoadBaseData.redpoints = {}
    kingsRoadBaseData.exchangered = false
	kingsRoadBaseData.curday = 0
	for i, v in ipairs(missions) do
		local type2 = tonumber(v.type2)
		local day = math.floor(type2/100)
		local tab = type2 - day * 100
		if kingsRoadBaseData.missions[day] == nil then
			kingsRoadBaseData.missions[day] = {}
            kingsRoadBaseData.redpoints[day] = {}
		end
		if kingsRoadBaseData.missions[day][tab] == nil then
			kingsRoadBaseData.missions[day][tab] = {}
			kingsRoadBaseData.redpoints[day][tab] = false
		end
		local mission = GetMission(v.id, missionMsgList)
		if mission ~= nil then
			table.insert(kingsRoadBaseData.missions[day][tab], v.id)
			local m = {}
			m.data = v
			m.day = day
			m.tab = tab
			m.mission = mission
			kingsRoadBaseData.missiontable[v.id] = m
			if kingsRoadBaseData.curday == nil or kingsRoadBaseData.curday < day then
				kingsRoadBaseData.curday = day
			end
            kingsRoadBaseData.redpoints[day][tab] = kingsRoadBaseData.redpoints[day][tab] or (not m.mission.rewarded and m.mission.status == 2--[[m.mission.value >= m.data.number]])
            if kingsRoadBaseData.redpoints[day][tab] then
                --kingsRoadBaseData.redpoints[day].red = true
            end
		end
		if kingsRoadBaseData.totalday == nil or kingsRoadBaseData.totalday < day then
			kingsRoadBaseData.totalday = day
		end
	end
    kingsRoadBaseData.totalmissions = #missions
    if activity.state == 2 then
        if exchangeItems ~= nil then
            for i, v in ipairs(exchangeItems) do
                if v.currentBuyNum < v.maxBuyNum and v.price < MoneyListData.GetKingActive() then
                    kingsRoadBaseData.exchangered = true
                end
            end
        end
    end
end

local function UpdateexchangeItems(exchangeId, buied)
	for i, v in ipairs(exchangeItems) do
		if v.exchangeId == exchangeId then
			v.currentBuyNum = buied
		end
	end
end

local function InitActivityList()
    activitys = {}
    for i, v in ipairs(ActivityData.GetListData()) do
        if math.floor(v.templet / 100) == 1 then
            table.insert(activitys, v)
        end
    end
end


local function ProcessRedPoint()
    local missionMsgList = MissionListData.GetData()
    local missionDataList = {}
    redpoints = {}
    hasred = false
    for i,v in pairs(missionMsgList) do
        local m = {}
        m.data = TableMgr:GetMissionData(v.id)
        m.mission = v
        if m.data ~= nil then
            table.insert(missionDataList, m)
        end
    end
    for i,v in ipairs(activitys) do
        redpoints[v.activityId] = false
        for ii,vv in ipairs(missionDataList) do
            if vv.data.ActivityID == v.activityId then
                if not vv.mission.rewarded and vv.mission.status == 2--[[vv.mission.value >= vv.data.number]] then
                    redpoints[v.activityId] = true
                    hasred = true
                end
            end
        end
        if v.templet == 101 then
            if exchangeItems == nil then
                ShopInfoRequest(v.activityId)
            end
            MakeKingsRoadBaseData(v, missionMsgList)
        end
        if v.activityId == DailyActivity_Worldcup.ACTIVITY_ID then
            redpoints[v.activityId] = not DailyActivity_Worldcup.hasVisited
            if not DailyActivity_Worldcup.hasVisited then
                hasred = true
            end
        end
        if v.templet == 112 then
            redpoints[v.activityId] = ActivityExchangeData.HasNotice(v.activityId)
        end
		if v.templet == 113 then
            redpoints[v.activityId] = Christmas.HasNotice(v.activityId)
        end
        if v.templet == 151 then
            redpoints[v.activityId] = not SevenDayData.HasTakenReward()
            hasred = hasred or redpoints[v.activityId]
        end
        if v.templet == 152 then
            redpoints[v.activityId] = not ThirtyDayData.HasTakenReward() or ThirtyDayData.IsAccuRewardCanTake()
            hasred = hasred or redpoints[v.activityId]
        end
        if v.templet == 153 then
            redpoints[v.activityId] = WarLossData.HasUnclaimedAward()
            hasred = hasred or redpoints[v.activityId]
        end
		
		--竞速冲级活动
		if v.activityId == 1401 then
			redpoints[v.activityId] = ActivityLevelRaceData.HasNotice()
		end
    end
end

local function SortActivity()
    table.sort(activitys, function(a, b)
        if redpoints[a.activityId] and not redpoints[b.activityId] then
            return true
        elseif not redpoints[a.activityId] and redpoints[b.activityId] then
            return false
        else
            return a.order > b.order
        end
    end)
end

function HasActivity(id)
    for _, activity in ipairs(activitys) do
        if id == activity.activityId then
            return true
        end
    end

    return false
end

function NotifyActivityAvailable(id)
    isNew[id] = true
end

function NotifyUIOpened(id)
    if isNew[id] then
        isNew[id] = false
        NotifyListener()
    end
end

function ProcessActivity()
    if ActivityData.GetListData() == nil then
        return
    end
    InitActivityList()
    ProcessRedPoint()
    SortActivity()
    MainCityUI.CheckPowerRankBtn()
    NotifyListener()
end

function GetExchangeItems()
    return exchangeItems
end

function ShopInfoRequest(index)
	local req = ShopMsg_pb.MsgCommonShopInfoRequest()
	req.index = index
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopInfoRequest, req, ShopMsg_pb.MsgCommonShopInfoResponse, function(msg)
        exchangeItems = msg.item
        ProcessActivity()
    end, false)
end

function ShopBuyRequest(exchangeId, num)
	local req = ShopMsg_pb.MsgCommonShopBuyRequest()
	req.exchangeId = exchangeId
	req.num = num
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopBuyRequest, req, ShopMsg_pb.MsgCommonShopBuyResponse, function(msg)
        if msg.code == 0 then
            MainCityUI.UpdateRewardData(msg.fresh)
            UpdateexchangeItems(exchangeId, msg.currentBuyNum)
            ProcessActivity()
            Global.ShowReward(msg.reward)
            Global.GAudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, true)
end
