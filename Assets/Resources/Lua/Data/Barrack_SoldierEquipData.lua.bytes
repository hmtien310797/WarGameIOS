module("Barrack_SoldierEquipData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local eventListener = EventListener()
local function NotifyListener()
    eventListener:NotifyListener()
end
function AddListener(listener)
    eventListener:AddListener(listener)
end
function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

local dataTable, needShow, caculateCoroutine

function GetData()
    return dataTable
end

function IsNeedShow(soldierid)
    return needShow[soldierid]
end

function Checked(soldierid)
    if soldierid == nil then
        for i = 1001, 1004 do
            needShow[i] = false
        end
    else
        needShow[soldierid] = false
    end
end

function CaculateNeedShow()
    needShow = {}
    for i = 1001, 1004 do
        needShow[i] = false
    end
    local unlocklevel = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.SoldierEquipUnlockLevel).value)
    if maincity.GetBuildingByID(1) == nil or unlocklevel > maincity.GetBuildingByID(1).data.level then
        return
    end
    local pricedata = TableMgr:GetSoldierBaptizeById(1)
    local temp = string.split(pricedata.ItemComsume, ":")
    local itemid, itemnum = tonumber(temp[1]), tonumber(temp[2])
    if ItemListData.GetItemCountByBaseId(itemid) >= itemnum then
        for i = 1001, 1004 do
            if dataTable.data ~= nil and dataTable.data.data ~= nil and #dataTable.data.data.probs > 0 then
                needShow[i] = true
            end
        end
    end

    for i, v in pairs(dataTable) do
        local isneed = true
        for ii, vv in pairs(v) do
            local data = vv
            if data.data ~= nil then
                local nextconsume = TableMgr:GetSoldierStrengthLevelById(data.data.level + 1)
                if nextconsume ~= nil then
                    nextconsume = nextconsume.LevelConsume
                else
                    nextconsume = ""
                end
                local materials = {}
                if nextconsume ~= "" then
                    if string.find(nextconsume ,";") then
                        nextconsume = string.msplit(nextconsume, ";", ":")
                        for i, v in ipairs(nextconsume) do
                            local m = {}
                            m.id = tonumber(v[1])
                            m.num = tonumber(v[2])
                            table.insert(materials, m)
                        end
                    else
                        local ms = string.split(nextconsume, ":")
                        local m = {}
                        m.id = tonumber(ms[1])
                        m.num = tonumber(ms[2])
                        table.insert(materials, m)
                    end
                end
                local isEnough = #materials > 0
                for iii, vvv in ipairs(materials) do
                    if ItemListData.GetItemCountByBaseId(vvv.id) < vvv.num then
                        isEnough = false
                    end
                end
                isneed = isneed and isEnough
            end
        end
        needShow[i] = needShow[i] or isneed
    end
    coroutine.stop(caculateCoroutine)
    caculateCoroutine = coroutine.start(function()
        coroutine.wait(3600)
        CaculateNeedShow()
    end)
end

local function MakeBaseBonus(bonus, ArmyType, AttrType, Value)
	local b = {}
	b.BonusType = ArmyType
	b.Attype =  AttrType
	b.Value = Value
	table.insert(bonus, b)
end

local function MakeBonus(bonus, ArmyType, AttrType, Value)
    if bonus == nil then
        bonus = {}
    end
	MakeBaseBonus(bonus, ArmyType, AttrType, Value)
	--[[local t = string.split(ArmyType,';')  
	for j=1,#(t) do
	    if t[j] ~= nil then
	    	if tonumber(t[j]) ~= 0 or AttrType ~= 0 then
		        local b = {}
		        b.BonusType =tonumber(t[j])
		        b.Attype =  AttrType
		        b.Value =  Value
		        table.insert(bonus, b)
		    end
	    end
    end]]
end

function CalAttributeBonus()
    local bonus = {}
    if dataTable == nil then 
       return bonus
    end
    for i, v in pairs(dataTable) do
        for ii, vv in pairs(v) do
            if vv.data ~= nil then
                MakeBonus(bonus, vv.baseData.AddArmy, vv.baseData.AddAttr, vv.baseData.BaseValue + (vv.data.level - 1)* vv.baseData.GrowValue * (1 + math.floor(vv.data.level / 10) * tonumber(TableMgr:GetGlobalData(100228).value)))
                if vv.data.probs then
                    for iii, vvv in pairs(vv.data.probs) do
                        if vvv.id ~= nil then
                            local pdata = TableMgr:GetSoldierStrengthAttrById(vvv.id)
                            MakeBonus(bonus, pdata.SoliderId, pdata.Attribute, pdata.AttributeValue * vvv.value)
                        end
                    end
                end
            end
        end
    end
    return bonus
end

function UpdateData(soldierid, pos, board)
    for i, v in pairs(dataTable) do
        if i == soldierid then
            for k, l in pairs(v) do
                if k == pos then
                    local old = l.data
                    l.data = board
                    l.updata = {}
                    if old ~= nil then
                        for ii, vv in ipairs(board.probs) do
                            if old.probs[ii] == nil or old.probs[ii].value < vv.value then
                                l.updata[ii] = 1
                            elseif old.probs[ii].value > vv.value then
                                l.updata[ii] = -1
                            else
                                l.updata[ii] = 0
                            end
                            if old.probs[ii] ~= nil then
                                vv.lock = old.probs[ii].lock
                            end
                        end
                    else
                        for ii, vv in ipairs(board.probs) do
                            l.updata[ii] = 1
                        end
                    end
                end
            end
        end
    end
end

local function MakeDataTable(data)
    dataTable = {}
    for i, v in pairs(TableMgr:GetSoldierStrength()) do
        if dataTable[v.SoldierId] == nil then
            dataTable[v.SoldierId] = {}
        end
        if dataTable[v.SoldierId][v.SoldierPos] == nil then
            dataTable[v.SoldierId][v.SoldierPos] = {}
        end
        local temp = dataTable[v.SoldierId][v.SoldierPos]
        temp.baseData = v
        for ii, vv in pairs(data) do
            if vv.soldierid == v.SoldierId then
                for iii, vvv in pairs(vv.boards) do
                    if vvv.pos == v.SoldierPos then
                        temp.data = vvv
                        temp.updata = {}
                        for iiii, vvvv in ipairs(vvv.probs) do
                            table.insert(temp.updata, 0)
                        end
                    end
                end
            end
        end
    end
    CaculateNeedShow()
end

function RequestArmyEnhanceInfo(callback)
    local req = HeroMsg_pb.MsgArmyEnhanceInfoRequest()
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmyEnhanceInfoRequest, req, HeroMsg_pb.MsgArmyEnhanceInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MakeDataTable(msg.data)
            NotifyListener()
            if callback~= nil then
                callback()
            end
            AttributeBonus.RegisterAttBonusModule(_M)
        else
            CaculateNeedShow()
        end
    end, true)
end

function RequestArmyEnhanceLevelUp(soldierid, pos, callback)
    local req = HeroMsg_pb.MsgArmyEnhanceLevelUpRequest()
    req.soldierid = soldierid
    req.pos = pos
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmyEnhanceLevelUpRequest, req, HeroMsg_pb.MsgArmyEnhanceLevelUpResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateData(soldierid, pos, msg.board)
            MainCityUI.UpdateRewardData(msg.fresh)
            NotifyListener()
            if callback~= nil then
                callback()
            end
            CaculateNeedShow()
        else
            Global.ShowError(msg.code)
        end
    end, true)
end

function RequestArmyEnhanceBaptize(soldierid, pos, lockprob, usemoney, callback)
    local req = HeroMsg_pb.MsgArmyEnhanceBaptizeRequest()
    req.soldierid = soldierid
    req.pos = pos
    for i, v in ipairs(lockprob) do
        req.lockprob:append(v)
    end
    req.usemoney = usemoney
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmyEnhanceBaptizeRequest, req, HeroMsg_pb.MsgArmyEnhanceBaptizeResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateData(soldierid, pos, msg.board)
            MainCityUI.UpdateRewardData(msg.fresh)
            NotifyListener()
            if callback~= nil then
                callback()
            end
            CaculateNeedShow()
        else
            Global.ShowError(msg.code)
        end
    end, true)
end