module("CountListData", package.seeall)
local countListData
local eventListener = EventListener()
local expireTime

function GetData()
    return countListData
end

function SetData(data)
    countListData = data
end

function RequestData()
    local req = ClientMsg_pb.MsgCountInfoRequest()
    req.id:add()
    local countId = req.id[1]
    countId.id = Common_pb.CountInfoType_Function
    countId.subid = Common_pb.CountSubtype_Func_BuyEnegy
	req.id:add()
	countId = req.id[2]
    countId.id = 2--Common_pb.CountInfoType_Rename
    countId.subid = 1
	req.id:add()
	countId = req.id[3]
	countId.id = Common_pb.CountInfoType_SweepMonster
    countId.subid = 1

    req.id:add()
	countId = req.id[4]
	countId.id = Common_pb.CountInfoType_Tipoff
    countId.subid = 1
	req.id:add()
	countId = req.id[5]
	countId.id = Common_pb.CountInfoType_RefreshSweepMonster
    countId.subid = 1
	
	req.id:add()
	countId = req.id[6]
	countId.id = Common_pb.CountInfoType_Function
    countId.subid = Common_pb.CountSubtype_Func_BuySceneEnegy

	req.id:add()
	countId = req.id[7]
	countId.id = Common_pb.CountInfoType_BuyClimbCount
    countId.subid = 1
	

    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCountInfoRequest, req, ClientMsg_pb.MsgCountInfoResponse, function(msg)
		SetData(msg.count)
    end, true)
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

function GetEnergyCount()
    for _, v in ipairs(countListData) do
        if v.id.id == Common_pb.CountInfoType_Function and v.id.subid == Common_pb.CountSubtype_Func_BuyEnegy then
            return v
        end
    end
end

function GetSceneEnergyCount()
    for _, v in ipairs(countListData) do
        if v.id.id == Common_pb.CountInfoType_Function and v.id.subid == Common_pb.CountSubtype_Func_BuySceneEnegy then
            return v
        end
    end
end

function GetRenameCount()
	for _, v in ipairs(countListData) do
        if v.id.id == 2--[[Common_pb.CountInfoType_Rename]] and v.id.subid == 1 then
            return v
        end
    end
end

function GetReportCount()
    for _, v in ipairs(countListData) do
        if v.id.id == 26  then
            return v.count
        end
    end
	return 0;
end


function SetCount(count)
	print("id:" .. count.id.id .. "subid : " .. count.id.subid .. "count:" .. count.count)

    for _, v in ipairs(countListData) do
        if v.id.id == count.id.id and v.id.subid == count.id.subid then
            v:MergeFrom(count)
			print("id:" .. count.id.id .. "subid : " .. count.id.subid .. "count:" .. count.count)
        end
    end
end

function GetWorldMapMonsterSweepCount()
	for _, v in ipairs(countListData) do
        if v.id.id == Common_pb.CountInfoType_SweepMonster and v.id.subid == 1 then
            return v
        end
    end
end

function GetRefreshSweepMonsterCount()
	for _, v in ipairs(countListData) do
        if v.id.id == Common_pb.CountInfoType_RefreshSweepMonster and v.id.subid == 1 then
            return v
        end
    end
end

function GetBuyClimbCount()
	for _, v in ipairs(countListData) do
        if v.id.id == Common_pb.CountInfoType_BuyClimbCount and v.id.subid == 1 then
            return v
        end
    end
end