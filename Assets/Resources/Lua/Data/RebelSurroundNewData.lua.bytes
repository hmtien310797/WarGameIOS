module("RebelSurroundNewData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local GUIMgr = Global.GGUIMgr
local eventListener = EventListener()
local soldierchangeListener = EventListener()

local nemesisinfo

function GetNemesisInfo()
    return nemesisinfo
end

function IsOver()
    return nemesisinfo ~= nil and nemesisinfo.wave >= nemesisinfo.MaxWave and nemesisinfo.takeReward
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

function NotifySoldierChangeListener()
    soldierchangeListener:NotifyListener()
end

function AddSoldierChangeListener(listener)
    soldierchangeListener:AddListener(listener)
end

function RemoveSoldierChangeListener(listener)
    soldierchangeListener:RemoveListener(listener)
end

function RequestNemesisInfo()
    local req = BattleMsg_pb.MsgNemesisInfoRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgNemesisInfoRequest, req, BattleMsg_pb.MsgNemesisInfoResponse, function(msg)
        if msg.code == 0 then
            nemesisinfo = msg
            if nemesisinfo.pathArriveTime > Serclimax.GameTime.GetSecTime() then
                CountDown.Instance:Add("RebelSurroundNewData", nemesisinfo.pathArriveTime, CountDown.CountDownCallBack(function(t)
                    if t == "00:00:00" then
                        RebelSurroundNewData.RequestNemesisInfo()
                        CountDown.Instance:Remove("RebelSurroundNewData")
                    end
                end))
            end
            NotifyListener()
        else
            Global.ShowError(msg.code)
        end
    end, true)
end

function RequestNemesisTakeReward(wave ,callback)
    local req = BattleMsg_pb.MsgNemesisTakeRewardRequest()
    req.wave = wave
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgNemesisTakeRewardRequest, req, BattleMsg_pb.MsgNemesisTakeRewardResponse, function(msg)
        Global.DumpMessage(msg, "d:/ddd.lua")
        if callback ~= nil then
            callback(msg)
        end
    end, false)
end

function RequestMsgNemesisStartBattle()
    local req = BattleMsg_pb.MsgNemesisStartBattleRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgNemesisStartBattleRequest, req, BattleMsg_pb.MsgNemesisStartBattleResponse, function(msg)
    end, false)
end