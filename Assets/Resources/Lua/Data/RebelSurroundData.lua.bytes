module("RebelSurroundData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local GUIMgr = Global.GGUIMgr
local rSurroundData
local rBattleResult
local rUpdateNextWaveDone = false
local rSortrewards
local vaild = false
local done = false


function GetData()
    return rSurroundData
end

function IsVaild()
    return vaild
end

function GetServerDone()
    return done
end

function SortLevelInfo()
    local waveSort = {}
    for i=1,#rSurroundData.levelInfo.waveInfos do
        waveSort[rSurroundData.levelInfo.waveInfos[i].wave] = rSurroundData.levelInfo.waveInfos[i]
    end
    for i=1,#waveSort do
        rSurroundData.levelInfo.waveInfos[i] = waveSort[i]
    end
end

function SetData(data)
    rSurroundData = data
    SortLevelInfo()

    local sort = {}
    for i=1,#rSurroundData.rewards do
        local level = rSurroundData.rewards[i].level
        sort[level] = {}
        sort[level].msg = rSurroundData.rewards[i]
        sort[level].sortWave = {}
        for j =1,#rSurroundData.rewards[i].waveReward do 
            local wave = rSurroundData.rewards[i].waveReward[j].wave
            sort[level].sortWave[wave] = rSurroundData.rewards[i].waveReward[j]
        end
    end
    rSortrewards = sort
end


function GetRewardList()
    return rSortrewards
end

function GetBattleResult()
    return rBattleResult
end

function ClearBattleResult()
    rBattleResult = nil
end

function GetUpdateNextWaveDone()
    return rUpdateNextWaveDone
end

function ResetUpdateNextWaveDone()
    rUpdateNextWaveDone = false
end

function UpdateLevelData(data)
    Global.Check(rSurroundData == nil,"##### rSurroundData = nil,Must be Call RequestData first!!!!")
    --rSurroundData.curLevel = data.curLevel
    --rSurroundData.curWave = data.curWave
    --rSurroundData.levelInfo:MergeFrom( data.levelInfo)
    rSurroundData = data
    SortLevelInfo()
end

function GetCurWaveTotalCount()
    Global.Check(rSurroundData == nil,"##### rSurroundData = nil,Must be Call RequestData first!!!!")
    local tc = 0;
    for i =1,#rSurroundData.levelInfo.waveInfos do
        if rSurroundData.levelInfo.waveInfos[i].type == 1 then --  1迎战 2反击
            tc = tc + 1
        end
    end
    return tc
end

function GetCanTakeRewardCount()
    Global.Check(rSurroundData == nil,"##### rSurroundData = nil,Must be Call RequestData first!!!!")
    if rSortrewards == nil then
        return 0 
    end
    local trc = 0
    for i=1,#rSortrewards do
        trc = trc + GetCanTakeRewardCount4Level(i)  
    end
    return trc
end

function GetCanTakeRewardCount4Level(level)
    local trc = 0
    local rs = rSortrewards[level]
    if rs ~= nil then
        for j =1,#rs.msg.waveReward do
            if rs.sortWave[j].status == 2 then
                trc = trc + 1
            end
        end
        if rs.msg.fastReward.status == 2 then
            trc = trc + 1
        end   
    end
    return trc
end

function RequestData(callback)
	local req = BattleMsg_pb.MsgMonsterSurroundInfoRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgMonsterSurroundInfoRequest, req, BattleMsg_pb.MsgMonsterSurroundInfoResponse, function(msg)
        if msg.code == 0 then
            SetData(msg)
            vaild = true
            if callback ~= nil then
                callback()
            end            
        else
            vaild = false
            if msg.code ~= 6151 then
                Global.ShowError(msg.code)
            else
                done = true
            end
            
            if callback ~= nil then
                callback()
            end       
        end
    end, false)
end

function UpdateToNextWave()
    if rSurroundData.curWave ==  #rSurroundData.levelInfo.waveInfos then
        return false
    end
    rSurroundData.curWave = rSurroundData.curWave + 1
    return true
end

function IsCurWaveMonsterFight()
    if rSurroundData.passAll ~= nil and rSurroundData.passAll then
        return false
    end
    return rSurroundData.levelInfo.waveInfos[rSurroundData.curWave].type == 1
end

function IsCurWavePlayerFight()
    if rSurroundData.passAll ~= nil and rSurroundData.passAll then
        return false
    end    
    return rSurroundData.levelInfo.waveInfos[rSurroundData.curWave].type == 2
end

function RequestSimpleData(callback)
	local req = BattleMsg_pb.MsgMonsterSurroundSimpleInfoRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgMonsterSurroundSimpleInfoRequest, req, BattleMsg_pb.MsgMonsterSurroundSimpleInfoResponse, function(msg)
        if msg.code == 0 then
            UpdateLevelData(msg)
            if callback ~= nil then
                callback()
            end
        else
            Global.ShowError(msg.code)
        end
    end, false) 
end

function RequsetSurroundStartBattle(req ,callback)
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgMonsterSurroundStartBattleRequest, req, BattleMsg_pb.MsgMonsterSurroundStartBattleResponse, function(msg)
        if msg.code == 0 then
            if callback ~= nil then
                callback(true)
            end
        else
            Global.ShowError(msg.code,function()
            if callback ~= nil then
                callback(false)
            end
            end)
        end
    end, false)
end

function GetWinLose(result)
    if result == nil then
        return 0,""
    end
    local type = rSurroundData.levelInfo.waveInfos[result.wave].type
    local title = ""
    local winlose = 1
    if type == 1 then
        if result.battleResult.winteam == 1 then
            winlose = 0
            title = TextMgr:GetText("RebelSurround_36")
        else
            winlose = 1
            title = TextMgr:GetText("RebelSurround_35")
        end
    else
        if result.battleResult.winteam == 1 then
            winlose = 1
            title = TextMgr:GetText("RebelSurround_37")
        else
            winlose = 0
            title = TextMgr:GetText("RebelSurround_38")
        end
    end
    return winlose,title
end

function DisposeBattlePush(msg)
    if rSurroundData == nil then
        return
    end
  
    rBattleResult = msg
    rUpdateNextWaveDone = true;
    if rBattleResult == nil then
        return
    end
    local winlose =  RebelSurroundData.GetWinLose(rBattleResult)
    if winlose == 0 and  rBattleResult.wave <= 3 then
        
        rSurroundData.lastAgainstFailTime = rBattleResult.battleTime
        print("YYYYYYYYYYYYYYYYYYYYYYYYYYYYY",rSurroundData.lastAgainstFailTime)
    end    
    if winlose == 1 and rBattleResult.level == 1 and (rBattleResult.wave == 1 or rBattleResult.wave == 3) then
        GUIMgr:SendDataReport("efun", "nemesis" .. rBattleResult.wave)
    end
    RebelSurround.ShowBattleResult()
    
end

function UpdateWaveReward_TakeState(level,wave)
    if rSurroundData == nil then
        return
    end
    if wave ~= nil then
        if rSortrewards[level].sortWave[wave].status == 2 then
            rSortrewards[level].sortWave[wave].status =3
        end
    else
        if rSortrewards[level].msg.fastReward.status == 2 then
            rSortrewards[level].msg.fastReward.status = 3
        end        
    end
    local t = GetCanTakeRewardCount()
    --vaild = t ~= 0
end

function RequestTakeWaveReward(level,wave,callback)
    local req = BattleMsg_pb.MsgMonsterSurroundTakeWaveRewardRequest()
    req.level = level
    req.wave = wave
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgMonsterSurroundTakeWaveRewardRequest, req, BattleMsg_pb.MsgMonsterSurroundTakeWaveRewardResponse, function(msg)
        if msg.code == 0 then
            UpdateWaveReward_TakeState(level,wave)
            if callback ~= nil then
                callback(true,msg)
            end
        else
            Global.ShowError(msg.code,function()
                if callback ~= nil then
                    callback(false)
                end
            end)
        end
    end, false)
end

function RequestTakeFastReward(level,callback)
    local req = BattleMsg_pb.MsgMonsterSurroundTakeFastRewardRequest()
    req.level = level    
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgMonsterSurroundTakeFastRewardRequest, req, BattleMsg_pb.MsgMonsterSurroundTakeFastRewardResponse, function(msg)
        if msg.code == 0 then
            UpdateWaveReward_TakeState(level)
            if callback ~= nil then
                callback(true,msg)
            end
        else
            Global.ShowError(msg.code,function()
                if callback ~= nil then
                    callback(false)
                end
            end)
        end
    end, false)
end


