module("ArenaInfoData", package.seeall)
local arenaInfoData
local TextMgr = Global.GTextMgr
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return arenaInfoData
end

function SetData(data)
    arenaInfoData = data
    local hero = arenaInfoData.arenaInfo.army.hero
    for i = #hero, 1, -1 do
        if not GeneralData.HasGeneralByBaseUID(hero[i]) then
            hero:remove(i)
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

function RequestData(unlockScreen, callback)
    local req = BattleMsg_pb.MsgArenaInfoRequest()
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaInfoRequest, req, BattleMsg_pb.MsgArenaInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            NotifyListener()            
            if callback ~= nil then
                callback()
            end
        else
            Global.ShowError(msg.code)
        end
    end, unlockScreen)
end

function HasNotice()
    local arenaInfoMsg = arenaInfoData.arenaInfo
    if arenaInfoMsg.canBattleCnt > 0 then
        return true
    end
    
    if not arenaInfoMsg.dayreward.got and arenaInfoMsg.dayreward.rewardTime ~= 0 then
        return true
    end
    
    for i, v in ipairs(arenaInfoMsg.Reward) do
        if not v.got and arenaInfoMsg.battleCnt >= v.challengeCnt then
            return true
        end
    end

    return false
end
