module("MobaBuffData", package.seeall)
local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime

local interface_guild={
    ["category"] = Category_pb.GuildMoba,
    ["buffRequest"] = GuildMobaMsg_pb.GuildMobaBuffListRequest,
    ["buffResponse"] = GuildMobaMsg_pb.GuildMobaBuffListResponse,
    ["requestTypeId"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaBuffListRequest,
}

local interface_moba={
    ["category"] = Category_pb.Moba,
    ["buffRequest"] = MobaMsg_pb.MsgMobaBuffListRequest,
    ["buffResponse"] = MobaMsg_pb.MsgMobaBuffListResponse,
    ["requestTypeId"] = MobaMsg_pb.MobaTypeId.MsgMobaBuffListRequest,
    
}

local function GetInterface(interface_name)
    if Global.GetMobaMode() == 1 then
        return interface_moba[interface_name]
    elseif Global.GetMobaMode() == 2 then
        return interface_guild[interface_name]
	else
		return interface_moba[interface_name]
    end
end

local eventListener = EventListener()
local buffListData

local function NotifyListener()
    eventListener:NotifyListener()
end

function HaveSameBuff(buildid , buffid)
	local addbuffdata = TableMgr:GetSlgBuffData(buffid)
	local curTime = Serclimax.GameTime.GetSecTime()
	if addbuffdata ~= nil and buffListData ~= nil then
		for _ , v in ipairs(buffListData) do
			local buffdata = TableMgr:GetSlgBuffData(v.buffId)
			if buffdata.btype == addbuffdata.btype and v.buffMasterId == buildid and v.time > curTime then
				return v
			end
		end
	end
	return nil
end


function CheckSelfShield(callback)
    if callback ~= nil then
        callback(false)
    end
end


--建筑都同时间只会存在一个buff : dongxiang 10-14
function GetBuildingBuff(buildid)
	if buffListData ~= nil then
		for _ , v in ipairs(buffListData) do
			if v.buffMasterId == buildid then
				return v
			end
		end
	end
	return nil
end

function GetBuff(buildid , buffid)
	if buffListData ~= nil then
		for _ , v in ipairs(buffListData) do
			if v.buffId == buffid and v.buffMasterId == buildid then
				return v
			end
		end
	end
	return nil
end

function GetData()
    return buffListData
end

function SetData(data)
    buffListData = data
	for _ , v in ipairs(buffListData) do
		--print("buff: " .. v.buffId .. "mastid : " .. v.buffMasterId)
	end
end

function GetActiveBuffInBufflist()
	return buffListData and #buffListData or 0
end

function RequestData(cb)
	local req = GetInterface("buffRequest")()
	Global.Request(GetInterface("category"), GetInterface("requestTypeId"), req, GetInterface("buffResponse"), function(msg)
		Global.DumpMessage(msg , "d:/d.lua")
			--Global.DumpMessage(msg , "d:/d.lua")
		--print("result : " ..msg.code)
		for _ ,v in ipairs(msg.buffs.buffs) do
			print("buff: " .. v.buffId .. "build :" .. v.buffMasterId , v.time)
		end
		SetData(msg.buffs.buffs)
		
		if cb ~= nil then
			cb()
		end
	end, true)
end 

function GetActiveHotTimeBuff()
	if buffListData ~= nil then
		for _ , v in ipairs(buffListData or {}) do
			
		--print("--------" , v.buffId , v.time , Serclimax.GameTime.GetSecTime() , v.time > Serclimax.GameTime.GetSecTime())
			local buff = TableMgr:GetSlgBuffData(v.buffId)
			if tonumber(buff.showtype) == 1 and v.time > Serclimax.GameTime.GetSecTime() then
				print("active hotTime:" , v.buffId , Serclimax.GameTime.SecondToStringYMDLocal(v.time) , Serclimax.GameTime.GetSecTime())
				return v
			end
		end
	end
	return nil
end

function RemoveBuffDataByUid(buildid , uid)
	if buffListData ~= nil then
		for i, v in ipairs(buffListData) do
			if v.uid == uid and v.buffMasterId == buildid then
				buffListData:remove(i)
				NotifyListener()
				return
			end
		end
	end
end

function UpdateAndRemoveBuffData(uid)
	local curTime = Serclimax.GameTime.GetSecTime()
	for i, v in ipairs(buffListData) do
        if v.uid == uid and v.time <= curTime then
			print("delete local buff uid:" .. v.uid , ". datalen:" .. #buffListData)
            buffListData:remove(i)
            NotifyListener()
            return
        end
    end
end

function UpdateData(data)
    local dataDirty = false
	local curTime = Serclimax.GameTime.GetSecTime()

	if buffListData ~= nil then
		for i, v in ipairs(buffListData) do
			if v.time <= curTime then
				buffListData:remove(i)
				dataDirty = true
			end
		end
		
		for _, v in ipairs(data) do
			if v.optype == Common_pb.FreshDataType_Add then
				buffListData:add()
				buffListData[#buffListData] = v.data
			elseif v.optype == Common_pb.FreshDataType_Fresh then
				for ii, vv in ipairs(buffListData) do
					if vv.uid == v.data.uid and vv.buffMasterId == v.data.buffMasterId then
						buffListData[ii] = v.data
					end
				end
			elseif v.optype == Common_pb.FreshDataType_Delete then
				for ii, vv in ipairs(buffListData) do
					if vv.uid == v.data.uid and vv.buffMasterId == v.data.buffMasterId then
						buffListData:remove(ii)
					elseif vv.uid == v.data.uid and vv.buffMasterType == 1 then
						buffListData:remove(ii)
					end
				end
			elseif v.optype == Common_pb.FreshDataType_FlagAdd then
			end
		end
		if #data > 0 then
			dataDirty = true
		end

		if dataDirty then
			AttributeBonus.CollectBonusInfo()
			NotifyListener()
		end
	end
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

local SLGBuffBonusTable

local function AddBonus(bouns,paras_str)
    local paras =string.split( paras_str,',')
    if tonumber(paras[1]) == 1 then
        local b = {}
        b.BonusType = tonumber(paras[2])
        b.AttType = tonumber(paras[3])
        b.Value = tonumber(paras[4])
        table.insert(bouns,b)
    end
end

local function InitBuffTable()
    if SLGBuffBonusTable ~= nil then
        return 
    end
    
    SLGBuffBonusTable = {}
	local slgbufftable = TableMgr:GetSlgBuffTable()
	for _ , v in pairs(slgbufftable) do
		local data = v
		SLGBuffBonusTable[data.id] = {}
		SLGBuffBonusTable[data.id].bouns = {}
        local paras =string.split( data.Effect,';')
        for i=1,#paras,1 do
            AddBonus(SLGBuffBonusTable[data.id].bouns,paras[i])
        end
	end
	
	--[[local iter = slgbufftable:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		SLGBuffBonusTable[data.id] = {}
		SLGBuffBonusTable[data.id].bouns = {}
        local paras =string.split( data.Effect,';')
        for i=1,#paras,1 do
            AddBonus(SLGBuffBonusTable[data.id].bouns,paras[i])
        end
    end]]

end

function CalAttributeBonus()
	local bouns = {}
	if buffListData ~= nil then
		InitBuffTable()
		table.foreach(buffListData ,function(i,v) 
			if SLGBuffBonusTable[v.buffId] ~= nil then
			   for i =1,#SLGBuffBonusTable[v.buffId].bouns,1 do
				local b = {}
				b.BonusType = SLGBuffBonusTable[v.buffId].bouns[i].BonusType
				b.Attype =  SLGBuffBonusTable[v.buffId].bouns[i].AttType
				b.Value =  SLGBuffBonusTable[v.buffId].bouns[i].Value
				table.insert(bouns, b)  
			   end
		   end
		end)
	end
    return bouns
end

function HasShield()
	if buffListData ~= nil then
		for _, v in ipairs(buffListData) do
			if v.buffCategory == 2 then
				return true
			end
		end
	end
	return false
end

function HasNewbieShield()
	if buffListData ~= nil then
		for _, v in ipairs(buffListData) do
			if v.buffCategory == 2 and v.buffId == tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.NewbieShieldId).value) then
				return true
			end
		end
	end
	return false
end

function GetBuffByType(typeids)
	for _ , v in ipairs(buffListData) do
		for i=1,#(typeids) do
			if v.buffId == tonumber(typeids[i]) then
				return v
			end
		end
	end
	return nil
end

function GetBuffCountWithSameType(typeids)
	local count = 0
	if buffListData ~= nil then
		local curTime = Serclimax.GameTime.GetSecTime()
		for _ , v in ipairs(buffListData) do
			for i=1,#(typeids) do
				if v.buffId == tonumber(typeids[i]) and v.time > curTime --[[and v.buffMasterType ~= Common_pb.BuffMasterType_Global]] then --需求变更：激活buff计数包括全局buff类型。by maboss 2017.11.22
					count = count + 1
				end
			end
		end
	end
	return count
end

function UpdateBuffTime(curTime)
	if buffListData ~= nil then
		local note = false
		for i, v in ipairs(buffListData) do
			if v.time <= curTime then
				buffListData:remove(i)
				note = true
			end
		end
		
		if note then
			NotifyListener()
		end
	end
end