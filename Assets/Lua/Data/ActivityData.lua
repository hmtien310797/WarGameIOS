module("ActivityData", package.seeall)
local BattleMsg_pb = require("BattleMsg_pb")
local ClientMsg_pb = require("ClientMsg_pb")
local Common_pb = require("Common_pb")

local TableMgr = Global.GTableMgr

local eventListener = EventListener()

local configs = {}
local timeConfigs

local ActivityListData

local ActivityDataTables

local ActivityListRed

local TESTMODE = false

local isRequesting = false

----- Events --------------------------------------------------
local eventOnAvailabilityChange = EventDispatcher.CreateEvent()

function OnAvailabilityChange()
    return eventOnAvailabilityChange
end

local function BroadcastEventOnAvailabilityChange(...)
    EventDispatcher.Broadcast(eventOnAvailabilityChange, ...)
end
---------------------------------------------------------------

function GetListData()
    return ActivityListData
end

function GetRedList()
    return ActivityListRed
end

function GetActivityData(activity_id)
    if ActivityDataTables == nil then
        return nil 
    end
    return ActivityDataTables[activity_id]
end

function SetActivityDataTime(activity_id,time)
    local data = GetActivityData(activity_id)
    if data ~= nil then
        data.battleTime = time
        print(data.battleTime , time)
    end
end

function SetListData(list)
    ActivityListData = list
end

function UpdateListData(data)
    for i= 1,#(ActivityListData) do 
        if ActivityListData[i].activityId == data.activityId then
            ActivityListData[i].leftCount = data.leftCount
            ActivityListData[i].countMax = data.countMax
            break
        end
    end
    
end

function SetActivityData(id,data)
    if ActivityDataTables == nil then
        ActivityDataTables={}
    end
    ActivityDataTables[id] = data
end

function IsActivityAvailable(id)
    local config = configs[id]
    return config and config.isAvailable or false
end

function isBattleFieldActivityAvailable(id)
    local config = configs[id]
    return config and config.isAvailable or false
end

function RequestBattleFieldActivityConfigs(callback)
    RequestListData(function()
        if callback ~= nil then
            -- local count = MakeBattleFieldActivityConfigs()
            -- callback(battleFieldActivityConfigs, count)
            callback(ActivityListData)
        end
    end)
end

function RequestWelfares(callback)
    RequestListData(function()
        if callback ~= nil then
            -- local count = MakeWelfareConfigs()
            -- callback(welfareConfigs, count)
            callback(ActivityListData)
        end
    end)
end

function GetActivityConfig(id)
    if id then
        return configs[id]
    end
    
    return configs
end

function GetBattleFieldActivityConfigs(id)
    if id == nil then
        local battleFieldActivityConfigs = {}
        for id, config in pairs(configs) do
            local templete = config.templete
            if templete >= 200 and templete < 300 then
                battleFieldActivityConfigs[id] = config
            end
        end

        return battleFieldActivityConfigs
    end

    return configs[id]
end

function GetWelfareConfigs(id)
    if id == nil then
        local welfareConfigs = {}
        for id, config in pairs(configs) do
            local templete = config.templete
            if templete >= 300 and templete < 400 then
                welfareConfigs[id] = config
            end
        end

        return welfareConfigs
    end

    return configs[id]
end

local SEC_PER_DAY = 60 * 60 * 24
local DAY_PER_WEEK = 7
local function MakeTimeConfig(config)
    config.nextStartTime = nil

    local now = Serclimax.GameTime.GetSecTime()
    local nowDate = os.date("*t", now)
    local today = now - (now - 57600) % SEC_PER_DAY

    local serverStartTime = MainData.GetServerStartTime()
    local serverStartDay = serverStartTime - (serverStartTime - 57600) % SEC_PER_DAY
    local serverStartDate = os.date("*t", serverStartTime)

    local creationTime = MainData.GetCreationTime()
    local creationDay = creationTime - (creationTime - 57600) % SEC_PER_DAY
    local creationDate = os.date("*t", creationTime)

    local timeStamp1 = math.max((config.type == 1 and serverStartDay or creationDay) + config.startDay * SEC_PER_DAY, config.gBeginTime - (config.gBeginTime - 57600) % SEC_PER_DAY)
    local date1 = os.date("*t", timeStamp1)
    
    local timeConfig = {}
    timeConfig.globalStartTime = config.gBeginTime
    timeConfig.globalEndTime = config.gEndTime
    timeConfig.cycle = config.cycle * SEC_PER_DAY * DAY_PER_WEEK
    timeConfig.isAlwaysAvailable = config.duration >= 2000000000
    timeConfig.doesOpenWeekly = config.weeklyOpenDay ~= ""
    timeConfig.doesOpenDaily = config.isDailyOpen == 1

    if config.cycle == 0 then -- 不循环
        local startTime = timeStamp1 + config.dailyBeginTime

        if config.weeklyOpenDay ~= "" then -- 根据星期开启
            startTime = startTime + ((date1.wday - 1 - tonumber(config.weeklyOpenDay) + 7) % 7) * SEC_PER_DAY
        end

        timeConfig.startTime = startTime
    else -- 循环
        timeConfig.startTime = {}
        if timeConfig.doesOpenWeekly then -- 根据星期开启
            if timeConfig.doesOpenDaily then -- 每日分别开启
                local startTime
                for s in string.gsplit(config.weeklyOpenDay, ",") do
                    table.insert(timeConfig.startTime, timeStamp1 + ((tonumber(s) - date1.wday + 1 + DAY_PER_WEEK) % DAY_PER_WEEK) * SEC_PER_DAY + config.dailyBeginTime)
                end

                table.sort(timeConfig.startTime, function(time1, time2)
                    return time1 < time2
                end)
            else
                table.insert(timeConfig.startTime, timeStamp1 + ((tonumber(string.split(config.weeklyOpenDay, ",")[1]) - date1.wday + 1 + DAY_PER_WEEK) % DAY_PER_WEEK) * SEC_PER_DAY + config.dailyBeginTime)
            end
        else
            table.insert(timeConfig.startTime, timeStamp1 + config.dailyBeginTime)
        end
    end

    timeConfigs[config.id] = timeConfig
end

local function UpdateNextStartTime(id)
    if id == nil then
        for id, _ in pairs(timeConfigs) do
            UpdateNextStartTime(id)
        end
    else
        local timeConfig = timeConfigs[id]

        local now = Serclimax.GameTime.GetSecTime()

        if timeConfig.isAlwaysAvailable or timeConfig.cycle == 0 then -- 永久、不循环
            local startTime
            if type(timeConfig.startTime) == "table" then
                startTime = timeConfig.startTime[1]
            else
                startTime = timeConfig.startTime
            end
            
            if now < startTime and startTime < timeConfig.globalEndTime then -- 未开启
                timeConfig.nextStartTime = startTime
            end
        else -- 循环
            if timeConfig.doesOpenWeekly and timeConfig.doesOpenDaily then -- 按周每日分别开启
                local earliestStartTime = timeConfig.startTime[1]
                local latestStartTime = timeConfig.startTime[#timeConfig.startTime]

                local differenceTime = now - earliestStartTime

                local nextStartTime
                if differenceTime < 0 then -- 没开启过
                    nextStartTime = earliestStartTime
                else -- 开启过
                    local elapsedTime = math.floor(differenceTime / timeConfig.cycle) * timeConfig.cycle

                    if now >= latestStartTime + elapsedTime then
                        elapsedTime = elapsedTime + timeConfig.cycle
                    end

                    for _, startTime in ipairs(timeConfig.startTime) do
                        local _nextStartTime = startTime + elapsedTime
                        if _nextStartTime > now then
                            nextStartTime = _nextStartTime
                            break
                        end
                    end
                end

                if nextStartTime < timeConfig.globalEndTime then
                    timeConfig.nextStartTime = nextStartTime
                end
            else
                local differenceTime = now - timeConfig.startTime[1]

                local nextStartTime
                if differenceTime < 0 then -- 没开启过
                    nextStartTime = timeConfig.startTime[1]
                else -- 开启过
                    nextStartTime = timeConfig.startTime[1] + math.ceil(differenceTime / timeConfig.cycle) * timeConfig.cycle
                end

                if nextStartTime < timeConfig.globalEndTime then
                    timeConfig.nextStartTime = nextStartTime
                end
            end
        end

        -- if timeConfig.nextStartTime then
        --     timeConfig.nextStartTime = os.date("%Y-%m-%d %H:%M:%S  %w", timeConfig.nextStartTime)
        -- end
    end
end

function MakeTimeConfigs()
    if timeConfigs == nil then
        timeConfigs = {}
        for id, config in pairs(configs) do
            if config.templete ~= 0 then
                MakeTimeConfig(config)
            end
        end

        UpdateNextStartTime()

        Global.DumpTable(timeConfigs)
    end
end

local function MakeConfigs()
    local now = Serclimax.GameTime.GetSecTime()
    for _, activity in ipairs(ActivityListData) do
        if activity.activityId ~= 0 then
            local config = {}
            config.id = activity.activityId
            config.endTime = activity.endTime
            config.isAvailable = now < activity.endTime
            config.templete = activity.templet
            config.configid = activity.configid
                        
            -- config.gBeginTime = Global.StringToSecondTime(activity.activeBeginTime)
            -- config.gEndTime = Global.StringToSecondTime(activity.activeEndTime)
            -- config.weeklyOpenDay = activity.week
            -- config.dailyBeginTime = activity.dayBeginTime
            -- config.type = activity.openType
            -- config.startDay = activity.openDay
            -- config.duration = activity.duration
            -- config.cycle = activity.loop
            -- config.isDailyOpen = activity.checkDayBeginTime

            configs[activity.activityId] = config
        end
    end
end

function GetActivityIdByTemplete(templete)
    for i, v in pairs(configs) do
        if v.templete == templete then
            return v.id
        end
    end
    return 0
end

function RequestListData(cb)
    if ActivityListData == nil then
        ActivityListData = {}
    end
    if not isRequesting then
        isRequesting = true
        local req = BattleMsg_pb.MsgUserActivityInfoRequest();
        Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgUserActivityInfoRequest, req, BattleMsg_pb.MsgUserActivityInfoResponse, function(msg)
            isRequesting = false
            Global.DumpMessage(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.ShowError(msg.code)
            else
            	table.sort(msg.activity, function(a, b) return a.activityId < b.activityId end)
                SetListData(msg.activity)
                RequestRedList(ActivityListData)
                MakeConfigs()
                -- MakeTimeConfigs()
                NotifyActivityAvailable(msg.newIds or {})
                DailyActivityData.ProcessActivity()
				
                MainCityUI.RequestNCheckHotTime()
                if cb ~= nil then
                    cb(msg)
                end
            end
        end, true)
    end
end

function RequestRedList(list_data,cb)
    if ActivityListRed == nil then
        ActivityListRed = {}
    end
    local needReq = false;
    local req = ClientMsg_pb.MsgCountInfoRequest();
    for i=1,#(list_data) do
        if list_data[i].countid ~= 0 then
            local c =req.id:add()
            c.id = list_data[i].countid
            needReq = true;
        end
    end
    if not needReq then 
        if cb ~= nil then
            cb()
        end       
        return
    end
    
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCountInfoRequest, req, ClientMsg_pb.MsgCountInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
           ActivityListRed = msg
            if cb ~= nil then
                cb()
            end
        end
    end, true) 
end

function RequestActivityData(id, cb)
    local req = BattleMsg_pb.MsgUserActivityDetailRequest()
    req.activityId = id
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgUserActivityDetailRequest, req, BattleMsg_pb.MsgUserActivityDetailResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetActivityData(id,msg)
            if cb ~= nil then
                cb()
            end            
        end
    end)
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

function HasActivity(moduleTable)
    for _, v in ipairs(ActivityListData) do
        if string.find(v.actskip, moduleTable._NAME) ~= nil then
            return true
        end
    end
    return false
end

function NotifyActivityAvailable(newActivityIDs)
    local hasTimedActivity = false
    local hasNewBattleFieldActivity = false
    local hasNewWelfareActivity = false

    for _, id in ipairs(newActivityIDs) do
        print("newActivityIDs", id)
    -- local now = Serclimax.GameTime.GetSecTime()
    -- if timeConfigs ~= nil then
    --     for id, timeConfig in pairs(timeConfigs) do
            local config = configs[id]
            -- if config ~= nil and not config.isAvailable and timeConfig.nextStartTime ~= nil and now == timeConfig.nextStartTime then
            if config ~= nil then    
                config.isAvailable = true

                local templete = config.templete
                
                if templete >= 100 and templete < 200 then
                    hasTimedActivity = true
                    DailyActivityData.NotifyActivityAvailable(id)
                elseif templete >= 200 and templete < 300 then
                    hasNewBattleFieldActivity = true
                    ActivityAll.NotifyActivityAvailable(id)
                elseif templete >= 300 and templete < 400 then
                    hasNewWelfareActivity = true
                    WelfareData.NotifyWelfareAvailable(id)
                end

            end
            -- end
    --     end

        BroadcastEventOnAvailabilityChange(id, true)
    end

    if hasTimedActivity then
        MainCityUI.SetDailyActivityRedPoint()
    end

    if hasNewBattleFieldActivity then
        MainCityUI.UpdateActivityAllNotice()
    end

    if hasNewWelfareActivity then
        MainCityUI.UpdateWelfareNotice()
    end
end

local function NotifyActivityUnavailable(now)
    for id, config in pairs(configs) do
        if config.isAvailable and now >= config.endTime+1 then
            config.isAvailable = false
            local templete = config.templete
            
            if templete >= 200 and templete < 300 then
                ActivityAll.NotifyActivityUnavailable(id)
            elseif templete >= 300 and templete < 400 then
                WelfareData.NotifyWelfareUnavailable(id)
            end

            BroadcastEventOnAvailabilityChange(id, false)
        end
    end
end

local nextUpdateTime = 0
function Initialize(init_call_back)
    RequestListData(function(msg)
        ActivityAll.Initialize()
        WelfareData.Initialize()
        MonthCardData.SetData(msg)
        HeroCardData.SetData(msg)
        UnionCardData.SetData(msg)
        NewbieCardData.SetData(msg)
        WarCardData.SetData(msg)
        ContinueRechargeData.SetData(msg)
        LuckyRotaryData.SetData(msg)
        Welfare_HerogetData.SetData(msg)
        Goldstore.Initialize()
        NewRaceData.RequestData(false)
        Rebate_LuckyRotary.RequestData()
        ReturnRewards.RequestData()
        if Global.ACTIVE_GUILD_MOBA then
            UnionMobaActivityData.RequestData(false)
        end
        if init_call_back ~= nil then
            init_call_back()
        end
    end)

    local now = Serclimax.GameTime.GetSecTime()
    math.randomseed(os.time())
    nextUpdateTime = (now - now % 3600) + 3601 + math.random(0, 60)
    EventDispatcher.Bind(Global.OnTick(), _M, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function(now)
        ActivityAll.UpdateCountdown()
        -- NotifyActivityAvailable()
        if not isRequesting then
            NotifyActivityUnavailable(now)
        end
        if isRequesting then
            math.randomseed(os.time())
            nextUpdateTime = (now - now % 3600) + 3601 + math.random(0, 60)
            return 
        end
        if now >= nextUpdateTime then
            RequestListData(function(msg)
                MonthCardData.SetData(msg)
                HeroCardData.SetData(msg)
                UnionCardData.SetData(msg)
                NewbieCardData.SetData(msg)
                WarCardData.SetData(msg)
                ContinueRechargeData.SetData(msg)
                LuckyRotaryData.SetData(msg)
                Welfare_HerogetData.SetData(msg)
                NewRaceData.RequestData(false)
                Rebate_LuckyRotary.RequestData()
                ReturnRewards.RequestData()
                if Global.ACTIVE_GUILD_MOBA then
                    UnionMobaActivityData.RequestData(false)
                end
				MainData.RequestData()
            end)
            math.randomseed(os.time())
            nextUpdateTime = (now - now % 3600) + 3601 + math.random(0, 60)
        end
        
    end)
end

function GetActivityGlobalBuff()
	for i= 1,#(ActivityListData) do
		local actBaseData = TableMgr:GetActiveConditionData(ActivityListData[i].activityId)
        if actBaseData ~= nil and actBaseData.buff > 0 then
          return actBaseData
        end
    end
	return nil
end

function GetExistTestActivity()
    for i, v in ipairs(ActivityListData) do
        if v.activityId == 5 then
            return v
        end
    end
end

function DumpRequest() -- ActivityData.DumpRequest()
    RequestListData(function(msg)
        Global.DumpMessage(msg, "d:/MsgUserActivityInfoResponse.lua")
    end)
end

