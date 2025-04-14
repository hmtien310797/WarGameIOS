module("MoneyListData", package.seeall)
local moneyListData = {}
local oldMoneyListData = {}
local eventListener = EventListener()

function GetData()
    return moneyListData
end

function SetData(data)
    moneyListData = data
    oldMoneyListData = data
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

local function MergeFrom(oldListData, newListData)
	local notify = false
	if oldListData == nil or newListData == nil then
		return notify
	end
    for _, v in ipairs(newListData) do
        for __, vv in ipairs(oldListData) do
            if vv.type == v.type then
            	-- print("类型：" .. vv.type .. " 老值：" .. vv.value .. " 新值" .. v.value)
				if vv.value ~= v.value then
					notify = true
				end
                vv.value = v.value
                break
            end
        end
    end
	return notify
end

function UpdateData(data)
    MergeFrom(oldMoneyListData, moneyListData)
    if MergeFrom(moneyListData, data) then
		if #data > 0 then
			NotifyListener()
		end
	end
end

--计算黄金变化
function ComputeDiamond(data)
	local new = 0
	for _, v in ipairs(data) do
        if v.type == Common_pb.MoneyType_Diamond then
            new = v.value
        end
    end
	--得出实际减少的黄金数
	if new == 0 then
		return 0
	else
		return (GetDiamond() - new)
	end
end

--获取食物
function GetFood()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_Food then
            return v.value
        end
    end
    return 0
end

--获取钻石
function GetDiamond()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_Diamond then
            return v.value
        end
    end
    return 0
end

--获取石油
function GetOil()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_Oil then
            return v.value
        end
    end
    return 0
end

--获取钢铁
function GetSteel()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_Iron then
            return v.value
        end
    end
    return 0
end

--获取电力
function GetElec()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_Elec then
            return v.value
        end
    end
    return 0
end

--获取联盟币
function GetGuildCoin()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_GuildCoin then
            return v.value
        end
    end
    return 0
end

--获取资源
function GetMoneyByType(type)
    for _, v in ipairs(moneyListData) do
        if v.type == type then
            return v.value
        end
    end
    return 0
end

--获取旧资源
function GetOldMoneyByType(type)
    for _, v in ipairs(oldMoneyListData) do
        if v.type == type then
            return v.value
        end
    end
    return 0
end

function GetKingActive()
	for _, v in ipairs(moneyListData) do
		if v.type == Common_pb.MoneyType_KingActive then
            return v.value
        end
	end
end

--获取声望
function GetReputation()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_Reputation then
            return v.value
        end
    end
    return 0
end

function GetRuneChip()
    for _, v in ipairs(moneyListData) do
        if v.type == Common_pb.MoneyType_RuneChip then
            return v.value
        end
    end
    return 0
end