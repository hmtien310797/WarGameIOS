module("UnionRadarData", package.seeall)

local eventListener = EventListener()
local TableMgr = Global.GTableMgr
local unionRadarData

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
    return unionRadarData
end

function UpdateUnionRadarData(monsterMsg)
	if unionRadarData == nil then
		return
	end
	
	for i=1 , #unionRadarData.battle , 1 do
		if unionRadarData.battle[i].id == monsterMsg.id then
			unionRadarData.battle[i] = monsterMsg
		end
	end
	NotifyListener()
end

function GetGuildMonsterGateHp()
	local monster = nil 
	if unionRadarData ~= nil then
		for i=1 , #(unionRadarData.battle) , 1 do
			if unionRadarData.battle[i].uid ~= 0 and unionRadarData.battle[i].hp > 0 then
				monster = unionRadarData.battle[i]
			end
		end
	end
	return monster
end

function GetGuildMonsterGateDestroy()
	if unionRadarData ~= nil then
		for i=1 , #(unionRadarData.battle) , 1 do
			local monsData = unionRadarData.battle[i]
			if monsData.uid ~= 0 and monsData.hp == 0 and not monsData.mapMonsterDead then
				local monter = unionRadarData.battle[i]
				return monter
			end
		end
	end
	return nil
end

function SetData(data)
    
    NotifyListener()
end

function GetDataWithCallBack(cb)
	local req = BattleMsg_pb.MsgBattleGuildMonsterRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleGuildMonsterRequest, req, BattleMsg_pb.MsgBattleGuildMonsterResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			unionRadarData = msg
			if cb ~= nil then
				cb(unionRadarData)
			end
		end
	end)
end

function RequestData()
    local req = BattleMsg_pb.MsgBattleGuildMonsterRequest()
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleGuildMonsterRequest, req, BattleMsg_pb.MsgBattleGuildMonsterResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			unionRadarData = msg
		end
	end)
end



