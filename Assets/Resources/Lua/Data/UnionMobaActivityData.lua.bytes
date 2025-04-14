module("UnionMobaActivityData", package.seeall)

local eventListener = EventListener()
local GameTime = Serclimax.GameTime

local TableMgr = Global.GTableMgr

local isNew = false
local data

local timeEventListener = EventListener()

function AddTimeListener(listener)
    timeEventListener:AddListener(listener)
end

function RemoveTimeListener(listener)
    timeEventListener:RemoveListener(listener)
end

local function NotifyTimeListener(status, time)
    timeEventListener:NotifyListener(status, time)
end

local function CheckReward()
    if data == nil then
        return false
    end
    return #data.roundreward.items > 0 or #data.roundreward.heros > 0 or #data.roundreward.armys > 0
end

local timeCoroutine
local function TimeCountDown()
    local timer = 0
    local status = 0
    if data.status == 0 then
        timer = data.starttime
    elseif data.status == 1 then
        timer = data.matchtime
        if not data.guildapply and UnionInfoData.IsUnionLeader() then
            status = 1
        end
    elseif data.status == 2 then
        timer = data.battletime
        local canReward = data.round > 1 and not data.isRoundReward and data.roundself > 1 and CheckReward()
        if canReward then
            status = 4
        elseif data.guildapply and UnionMobaActivityData.GetData().pair.starttime > 0 and UnionInfoData.IsUnionLeader() and (data.pair.winner == 0) then
            status = 2
        end
    elseif data.status == 3 then
        timer = data.battletime + tonumber(tableData_tGuildMobaGlobal.data[5].Value)
        if data.guildapply and UnionMobaActivityData.GetData().pair.starttime > 0 then
            status = 3
        end
    elseif data.status == 4 then
        timer = data.overtime
        if (data.round > 1 and not data.isRoundReward and UnionInfoData.HasUnion() and CheckReward()) or ((#data.assignreward.items > 0 or #data.assignreward.heros > 0 or #data.assignreward.armys > 0) and UnionInfoData.IsUnionLeader() and #data.assignRewardIds < tonumber(tableData_tGuildMobaGlobal.data[113].Value)) then
            status = 4
        end
    end
    NotifyTimeListener(status, timer)
    timer = timer - Serclimax.GameTime.GetSecTime() + 1

    if timeCoroutine ~= nil then
        coroutine.stop(timeCoroutine)
    end
    if timer > 0 then
        timeCoroutine = coroutine.start(function()
            print(timer)
            coroutine.wait(timer)
            RequestData(true)
        end)
    end
end

function GetData()
    return data
end

function SetData(_data)
    Global.DumpMessage(_data, "D:/ddddd.lua")
    data = _data
    TimeCountDown()
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function NotifyAvailable()
	isNew = true
end

function NotifyUIOpened()
	if isNew then
		isNew = false
		NotifyListener()
	end
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function RequestData(unlockScreen)
    local req = GuildMobaMsg_pb.GuildMobaInfoRequest()
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaInfoRequest, req, GuildMobaMsg_pb.GuildMobaInfoResponse, function(msg)
        SetData(msg)
        NotifyListener()
    end, unlockScreen)
end

function RequestGuildApply(timeflag)
    local req = GuildMobaMsg_pb.GuildMobaGuildApplyRequest()
    req.timeflag = timeflag
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGuildApplyRequest, req, GuildMobaMsg_pb.GuildMobaGuildApplyResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if data ~= nil then
                data.guildapply = true
            end
            NotifyListener()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestConfirmTeam(idlist)
    local req = GuildMobaMsg_pb.GuildMobaConfirmTeamRequest()
    for i, v in ipairs(idlist) do
        req.charids:append(v)
    end
    Global.DumpMessage(req, "D:/ddddd.lua")
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaConfirmTeamRequest, req, GuildMobaMsg_pb.GuildMobaConfirmTeamResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            RequestData(true)
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function HasNotice()
    if isNew then
        return true
    end
    
    return false
end

function CheckSelect(id)
    for i, v in ipairs(data.pair.teamA.memberids) do
        if id == v then
            return true
        end
    end
    for i, v in ipairs(data.pair.teamB.memberids) do
        if id == v then
            return true
        end
    end
    return false
end

local mobaEnterInfo
local mobaUserResult

function GetMobaEnterInfo()
    return mobaEnterInfo
end

local mobaEnterMsg
function GetMobaEnterMsg()
    return mobaEnterMsg
end

function RequestMobaEnter(callback)
    RequestEnterMap(callback, false, false)
end

function RequestEnterMap(callback, unlockScreen, shieldnotice)
    local req = GuildMobaMsg_pb.GuildMobaEnterMapRequest()
    req.shieldnotice = shieldnotice
	Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaEnterMapRequest, req, GuildMobaMsg_pb.GuildMobaEnterMapResponse, function(msg)
        mobaEnterMsg = msg
        mobaEnterInfo = msg.info
        mobaUserResult = nil
		if msg.code == ReturnCode_pb.Code_OK then
			if callback ~= nil then
                callback()
            end
        elseif msg.code == ReturnCode_pb.Code_GuildMoba_ShieldNotice then
            MessageBox.Show(Global.GTextMgr:GetText("Code_GuildMoba_ShieldNotice"), function()
                RequestEnterMap(callback, unlockScreen, true)
            end,function() end)
		else
			Global.ShowError(msg.code)
		end
	end, unlockScreen == nil and true or unlockScreen)
   
end

function GetMobaUserResult()
    return mobaUserResult
end

function SetMobaUserResult(msg)
    Global.DumpMessage(msg, "d:/ddddd.lua")
    if Global.GetMobaMode() == 2 then
        mobaUserResult = msg
        UnionMoba_Winlose.Show()
        --GuildWarMain.ShowMobaBattleResult(mobaUserResult)
    end
end

function isMobaOver()
    return mobaUserResult ~= nil
end


function GetMobaLeftTime()
    local serverTime = Serclimax.GameTime.GetSecTime()
	if mobaEnterMsg ~= nil then 
		-- print("GetMobaLeftTime overtime ",mobaEnterMsg.overTime,Serclimax.GameTime.SecondToStringYMDLocal(mobaEnterMsg.overTime),serverTime,Serclimax.GameTime.SecondToStringYMDLocal(serverTime))
		return mobaEnterMsg.overTime - serverTime
	end 
	return 1
end

function RequestMobaGlobalChampion(callback, errorcallback)
    local req = GuildMobaMsg_pb.GuildMobaGlobalChampionRequest()
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGlobalChampionRequest, req, GuildMobaMsg_pb.GuildMobaGlobalChampionResponse, function(msg)
        Global.DumpMessage(msg, "d:/ddddd.lua")
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback(msg)
            end
            NotifyListener()
        else
            if errorcallback ~= nil then
                errorcallback()
            end
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestMobaGetReward(round,callback)
    local req = GuildMobaMsg_pb.GuildMobaGetRewardRequest()
    req.round = round
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetRewardRequest, req, GuildMobaMsg_pb.GuildMobaGetRewardResponse, function(msg)
        Global.DumpMessage(msg, "d:/ddddd.lua")
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
			Global.ShowReward(msg.reward)
            RequestData(true)
            if callback ~= nil then
                callback(msg)
            end
            NotifyListener()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function CheckRewarded(id)
    for i, v in ipairs(data.assignRewardIds) do
        if id == v then
            return true
        end
    end
    return false
end

function RequestAssignReward(idlist)
    local req = GuildMobaMsg_pb.GuildMobaAssignRewardRequest()
    for i, v in ipairs(idlist) do
        if not CheckRewarded(v) then
            req.charids:append(v)
        end
    end
    if #req.charids == 0 then
        return
    end
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaAssignRewardRequest, req, GuildMobaMsg_pb.GuildMobaAssignRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            RequestData(true)
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestBattleResult(sceneid,callback)
    local req = GuildMobaMsg_pb.GuildMobaBattleResultRequest()
    req.sceneid = sceneid
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaBattleResultRequest, req, GuildMobaMsg_pb.GuildMobaBattleResultResponse, function(msg)
        Global.DumpMessage(msg, "d:/ddddd.lua")
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
                callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end