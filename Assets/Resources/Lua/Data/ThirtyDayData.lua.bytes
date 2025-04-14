module("ThirtyDayData", package.seeall)
local AudioMgr = Global.GAudioMgr
local rewardData
local day
local taken 
local resetDay

local startday
local ndays
local takenDate
local takenDays
local accuReward
local retakeTimes
local retakeCost

local eventListener = EventListener()

local TableMgr = Global.GTableMgr

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
    return rewardData
end

function GetDay()
    return day
end

function SetDay(_day)
    day = _day
end

function GetTaken()
    return taken
end

function SetTaken(_taken)
    taken = _taken
    NotifyListener()
end

function GetResetDay()
    return resetDay
end

function SetData(data)
    rewardData = data
end

function RequestData()
    local req = ActivityMsg_pb.MsgMonthRewardRequest()
    req.nonseries = 1
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgMonthRewardRequest, req, ActivityMsg_pb.MsgMonthRewardResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetData(msg.reward)
            day = msg.day
            taken = msg.taken
            resetDay = msg.resetDay
            ndays = msg.ndays
            SetTakenDate(msg.rewardDate)
            SetAccuReward(msg.accuReward)
            SetAccuRewardGot(msg.accuRewardGot)
            startday = msg.startday
            retakeTimes = msg.retakeTimes
            retakeCost = msg.retakeCost
            NotifyListener()
        end
    end, true)
end

function HasTakenReward()
    return GetTaken()
end

function HasNotice()
    return ActivityData.HasActivity(ThirtyDay) and (not HasTakenReward() or IsAccuRewardCanTake())
end

function GetNdays()
    return ndays
end

function SetNdays(value)
    ndays = value
end

function GetTakenDate()
    return takenDate
end

function SetTakenDate(rewardDate)
    takenDate = {}
    takenDays = 0
    table.sort(rewardDate, function(a, b) return a > b end)
    local isbroken = true
    local nearest
    for i, v in ipairs(rewardDate) do
        takenDate[v] = true
        if isbroken and v >= ndays - 1 then
            isbroken = false
            nearest = v
            takenDays = 1
        else
            if not isbroken then
                if v < nearest - 1 then
                    isbroken = true
                else
                    nearest = v
                    takenDays = takenDays + 1
                end
            end
        end
    end
end

function GetTakenDays()
    return takenDays
end

function GetAccuReward()
    return accuReward
end

function GetStartDay()
    return startday
end

function GetRetakeTimes()
    return retakeTimes
end

function GetRetakeCose()
    return retakeCost
end

function SetAccuReward(_accuReward)
    accuReward = {}
    for i, v in ipairs(_accuReward) do
        accuReward[i] = {}
        accuReward[i].data = v
    end
end

function SetAccuRewardGot(accuRewardGot)
    for i, v in ipairs(accuRewardGot) do
        for k, l in ipairs(accuReward) do
            if l.data.accdays == v then
                l.taked = true
            end
        end
    end
end

function IsAccuRewardCanTake()
    print(111111111)
    for i, v in ipairs(accuReward) do
        if v.data.accdays <= takenDays and not v.taked then
            return true
        end
    end
    return false
end

function RequestBuqian(days)
    local req = ActivityMsg_pb.MsgReTakeMonthRewardRequest()
    req.days = days
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgReTakeMonthRewardRequest, req, ActivityMsg_pb.MsgReTakeMonthRewardResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            if msg.code == ReturnCode_pb.Code_DiamondNotEnough then
                Global.ShowNoEnoughMoney()
            else
                Global.ShowError(msg.code)
            end
        else
            AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
            MainCityUI.UpdateRewardData(msg.freshInfo)
            Global.ShowReward(msg.rewardInfo)
            SetDay(msg.day)
            SetTaken(msg.taken)
            SetTakenDate(msg.rewardDate)
            retakeTimes = msg.retakeTimes
            retakeCost = msg.retakeCost
            NotifyListener()
            MainCityUI.UpdateWelfareNotice(3003)
        end
    end, true)
end

function RequestAccuReward(seq)
    local req = ActivityMsg_pb.MsgAccuRewardGotRequest()
    req.seq = seq
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgAccuRewardGotRequest, req, ActivityMsg_pb.MsgAccuRewardGotResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
            MainCityUI.UpdateRewardData(msg.freshInfo)
            Global.ShowReward(msg.rewardInfo)
            SetAccuRewardGot(msg.accuRewardGot)
            NotifyListener()
            MainCityUI.UpdateWelfareNotice(3003)
        end
    end, true)
end