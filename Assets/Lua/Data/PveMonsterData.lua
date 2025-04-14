module("PveMonsterData", package.seeall)

local eventListener = EventListener()
local TableMgr = Global.GTableMgr
local pveMonsterData

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
    return pveMonsterData
end

function UpdatePveMonsterData(monsterMsg)
	pveMonsterData = monsterMsg
	NotifyListener()
end

function SetData(data)
    pveMonsterData = data
    NotifyListener()
end

function HasAttackPveMonster(monsterUid)
	if pveMonsterData == nil then
		return false
	end
	
	for i=1 , #pveMonsterData.monster , 1 do
		if pveMonsterData.monster[i] == monsterUid then
			return true
		end
	end
	
	return false
end

function RequestData()
    local req = BattleMsg_pb.MsgBattleMapDigWinMonsterRequest()
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleMapDigWinMonsterRequest, req, BattleMsg_pb.MsgBattleMapDigWinMonsterResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			pveMonsterData = msg.winMonster
		end
	end, true)
end



