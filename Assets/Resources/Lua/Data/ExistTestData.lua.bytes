module("ExistTestData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local eventListener = EventListener()
local lastStatus

local sendcount
local sendcountmax

function SetStatus(status)
    lastStatus = status
end

function GetStatus()
    return lastStatus
end

local function NotifyListener(type)
    eventListener:NotifyListener(type)
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

local noticeEventListener = EventListener()
local function NotifyNotice()
    noticeEventListener:NotifyListener()
end

function AddNoticeListener(listener)
    noticeEventListener:AddListener(listener)
end

function RemoveNoticeListener(listener)
    noticeEventListener:RemoveListener(listener)
end

local lastData = {}
local changelist = {}
local startrank = {}
local survivalUserRankList

local function UpdateData(msg, rankType)
    if #msg.rankList > 0 then
        for i = #survivalUserRankList[rankType].rankList + 1, msg.rankList[1].rank - 1 do
            local rank = survivalUserRankList[rankType].rankList:add()
            rank:MergeFrom(survivalUserRankList[rankType].rankList[1])
            rank.rank = i
        end
        for i, v in ipairs(msg.rankList) do
            local isnew = true
            for j, k in ipairs(survivalUserRankList[rankType].rankList) do
                if v.rank == k.rank then
                    k:MergeFrom(v)
                    isnew = false
                end
            end
            if isnew then
                local rank = survivalUserRankList[rankType].rankList:add()
                rank:MergeFrom(v)
            end
        end
        table.sort(survivalUserRankList[rankType].rankList, function(a, b)
            return a.rank < b.rank
        end)
    end
end

local function SetData(msg)
    if survivalUserRankList == nil then
        survivalUserRankList = {}
    end
    if lastData.res == nil then
        lastData.res = {}
    end
    for i, v in ipairs(msg.rewardShow.items) do
        if lastData.res[v.id] ~= nil then
            if lastData.res[v.id] ~= v.num then
                changelist[1] = true
                NotifyNotice()
            end
        end
        lastData.res[v.id] = v.num
    end
    if msg.rankType == 1 then
        if msg.myRank.rank > 0 then
            if lastData.myRank ~= nil then
                if lastData.myRank ~= msg.myRank.rank then
                    changelist[2] = true
                    NotifyNotice()
                end
            end
            lastData.myRank = msg.myRank.rank
        end
        if msg.myRank.score > 0 then
            if lastData.score ~= nil then
                if lastData.score ~= msg.myRank.score then
                    changelist[3] = true
                    NotifyNotice()
                end
            end
            lastData.score = msg.myRank.score
        end
    end
    if survivalUserRankList[msg.rankType] == nil then
        survivalUserRankList[msg.rankType] = msg
        startrank[msg.rankType] = msg.rankList[1] ~= nil and msg.rankList[1].rank or 0
    else
        survivalUserRankList[msg.rankType].myRank:MergeFrom(msg.myRank)
        UpdateData(msg, msg.rankType)
        for i, v in ipairs(msg.rewardShow.items) do
            for j, k in ipairs(survivalUserRankList[msg.rankType].rewardShow.items) do
                if k.id == v.id then
                    k.num = v.num
                end
            end
        end
        startrank[msg.rankType] = survivalUserRankList[msg.rankType].rankList[1] ~= nil and survivalUserRankList[msg.rankType].rankList[1].rank or 0
    end
    NotifyListener(msg.rankType)
end

function GetStartRank(type)
    return startrank[type]
end

function GetChangeList()
    return changelist
end

function ResetChangeList()
    changelist = {}
end

function GetSurvivalUserRankList(type)
    if survivalUserRankList == nil then
        return nil
    end
    return survivalUserRankList[type]
end

local closeListener = EventListener()
local function NotifyCloseListener()
    closeListener:NotifyListener()
end

function AddCloseListener(listener)
    closeListener:AddListener(listener)
end

function RemoveListener(listener)
    closeListener:RemoveListener(listener)
end

local function CheckChange()
    local timer = 0
    local co = coroutine.start(function()
        while true do
            timer = timer + Time.deltaTime
            if timer >= 300 then
                timer = timer - 300
                if ActivityData.GetExistTestActivity() ~= nil then
                    RequestSurvivalUserRankList()
                else
                    coroutine.stop(co)
                end
            end
            coroutine.step()
        end
    end)
end

function CheckSurvivalUserRankList(callback)
    if survivalUserRankList == nil then
        SurvivalUserRankListRequest(1, 1)
        SurvivalUserRankListRequest(2, 1)
        data = ActivityData.GetExistTestActivity()
        if data ~= nil then
            CountDown.Instance:Add("ExistTest", data.endTime, function(t)
                if data.endTime <= Serclimax.GameTime.GetSecTime() then
                    NotifyCloseListener()
                end
            end)
            CheckChange()
        end
        RequestSendFlowerData()
        if callback ~= nil then
            callback()
        end
    end
end

function RequestSurvivalUserRankList()
    SurvivalUserRankListRequest(1, 1)
    SurvivalUserRankListRequest(2, 1)
end

function RequestSendFlowerData()
    local req = ClientMsg_pb.MsgCountInfoRequest()
    req.id:add()
    local countId = req.id[1]
    countId.id = Common_pb.CountInfoType_SendFlower
    countId.subid = 1
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCountInfoRequest, req, ClientMsg_pb.MsgCountInfoResponse, function(msg)
        sendcount = msg.count[1].count
        sendcountmax = msg.count[1].countmax
        NotifyListener()
    end, true)
end

function Test()
    sendcount = 0
end

function GetSendFlowerCount()
    return sendcount, sendcountmax
end

local sharetime = 0
function SetShareTime()
    sharetime = Serclimax.GameTime.GetSecTime() + 300
end

function GetShareTime()
    return sharetime
end

local function CaculateFlower(charId)
    if survivalUserRankList ~= nil and survivalUserRankList[1] ~= nil then
        for i, v in ipairs(survivalUserRankList[1].rankList) do
            if v.charId == charId then
                v.score = v.score + 1
            end
        end
        table.sort(survivalUserRankList[1].rankList, function(a, b)
            return a.score > b.score
        end)
        for i, v in ipairs(survivalUserRankList[1].rankList) do
            v.rank = i
            if survivalUserRankList[1].myRank.charId == charId then
                survivalUserRankList[1].myRank.score = v.score
                survivalUserRankList[1].myRank.rank = v.rank
            end
        end
    end
    NotifyNotice()
end

function SurvivalUserRankListRequest(type, page)
	local req = ActivityMsg_pb.MsgSurvivalUserRankListRequest()
    req.rankType = type
    req.pageIndex = page
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSurvivalUserRankListRequest, req, ActivityMsg_pb.MsgSurvivalUserRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, true)
end

function SurvivalSendFlowerRequest(charId, callback)
	local req = ActivityMsg_pb.MsgSurvivalSendFlowerRequest()
	req.charId = charId
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSurvivalSendFlowerRequest, req, ActivityMsg_pb.MsgSurvivalSendFlowerResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            CaculateFlower(charId)
            coroutine.start(function()
                FloatText.Show(TextMgr:GetText("ExistTest_4"), Color.green, ResourceLibrary:GetIcon("Item/", "item_flower"))
                coroutine.wait(0.3)
                Global.ShowReward(msg.reward)
            end)
            sendcount = sendcount - 1
            if callback ~= nil then
                callback(msg.reward)
            end
        else
            if msg.code == ReturnCode_pb.Code_ItemNotEnough then
                MessageBox.Show(TextMgr:GetText("ExistTest_5"))
            elseif msg.code == ReturnCode_pb.Code_LimitNumNotEnough then
                FloatText.Show(TextMgr:GetText("ExistTest_6"), Color.white)
            else
                Global.FloatError(msg.code, Color.white)
            end
        end
    end, false)
end

function SurvivalSearchUserRankRequest(rankType, charName, charId, callback)
	local req = ActivityMsg_pb.MsgSurvivalSearchUserRankRequest()
    req.rankType = rankType
    req.charName = charName ~= nil and charName or ""
    req.charId = charId ~= nil and charId or 0
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSurvivalSearchUserRankRequest, req, ActivityMsg_pb.MsgSurvivalSearchUserRankResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if #msg.rankList > 0 then
                UpdateData(msg, rankType)
                if callback ~= nil then
                    callback(msg)
                end
            end
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, false)
end

local firstguide
function SetFirstGuide(param)
    firstguide = param
end

function IsFirstGuide()
    return firstguide
end