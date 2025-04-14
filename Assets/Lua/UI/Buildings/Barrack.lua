module("Barrack",package.seeall)

local Category_pb = require("Category_pb")
local BuildMsg_pb = require("HeroMsg_pb")

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local SetClickCallback = UIUtil.SetClickCallback
local SetPressCallback = UIUtil.SetPressCallback
local SetDragCallback = UIUtil.SetDragCallback

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local BarrackState -- BarrackID  BarrackLevel ScienceInfos Training  

local BarrackUI

local BarrackInfos

local BarrackInfosMap

local BarrackBuildData

local RequestState

local SetupSoldierMode

local ClearTraningTag

local SetupSoldierAttributes, SetupOneSoldierAttribute

local CurBuild

local setoutNum
local setoutHero
local defMaxNum
local needFloatText
local roundOff

local isOpen
local showmodelcoroutine

local isDestroy = true
OnCloseCB = nil

function IsOpen()
	return isOpen;
end

function GetTrainTimeDefence(basetime,type_id)
    local params = {}
    params.base = basetime
    params.soldier_att_id = type_id*10000+22
	
	local _, statusArgs = GetArmyStatus()
    return AttributeBonus.CallBonusFunc(48,params)*(1+statusArgs[4])
end

function GetTrainTime(basetime,type_id)
    --添加对战争堡垒的特殊时间支持
    if type_id == 101 or type_id == 102 then
        return GetTrainTimeDefence(basetime,type_id)
    end
    local params = {}
    params.base = basetime
    params.barrack_bonu_id = 0
    if type_id == 1001 then 
         params.barrack_bonu_id = 1043
         params.barrack_add = 10001 * 10000 + 22
    elseif type_id == 1002 then
         params.barrack_bonu_id = 1044
         params.barrack_add = 10002 * 10000 + 22
    elseif type_id == 1003 then 
         params.barrack_bonu_id = 1045
         params.barrack_add = 10003 * 10000 + 22
    elseif type_id == 1004 then    
         params.barrack_bonu_id = 1046
         params.barrack_add = 10004 * 10000 + 22
    end
    params.soldier_att_id = type_id * 10000 + 22
    params.all_soldier_att_id = 10000 * 10000 + 22
    
    local builds = maincity.GetBuildingList()
    local speed = 0;
    for _, v in pairs(builds) do
		if v.data ~= nil and v.data.type == 5 then
          local callup = TableMgr:GetCallUpData(v.data.level) 
          speed = speed + callup.speed
	    end
    end
    --print(speed)
    params.TSpeed = speed
	--print(speed, AttributeBonus.CallBonusFunc(14,params))
	local _, statusArgs = GetArmyStatus()
    return AttributeBonus.CallBonusFunc(14,params)*(1+statusArgs[4])
end

function GetResourceForTraining()
	local tab = BarrackState.CurTab
	local grade = BarrackState.CurGrade
	local num = BarrackState.TrainSelNum

	local ResFood = (BarrackInfos[tab][grade].Res[3] == nil and 0 or BarrackInfos[tab][grade].Res[3])*num*BarrackInfos[tab][grade].TeamCount
	local ResIron = (BarrackInfos[tab][grade].Res[4] == nil and 0 or BarrackInfos[tab][grade].Res[4])*num*BarrackInfos[tab][grade].TeamCount
	local ResOil = (BarrackInfos[tab][grade].Res[5] == nil and 0 or BarrackInfos[tab][grade].Res[5])*num*BarrackInfos[tab][grade].TeamCount
	local ResElectric = (BarrackInfos[tab][grade].Res[6] == nil and 0 or BarrackInfos[tab][grade].Res[6])*num*BarrackInfos[tab][grade].TeamCount

	local ResourceNeeded = {}
    ResourceNeeded.ResFood = math.floor(GetTrainCost(ResFood,BarrackInfos[tab][grade].SoldierId,grade))
    ResourceNeeded.ResIron = math.floor(GetTrainCost(ResIron,BarrackInfos[tab][grade].SoldierId,grade))
    ResourceNeeded.ResOil = math.floor(GetTrainCost(ResOil,BarrackInfos[tab][grade].SoldierId,grade))
    ResourceNeeded.ResElectric = math.floor(GetTrainCost(ResElectric,BarrackInfos[tab][grade].SoldierId,grade))

    return ResourceNeeded
end

function GetFoodCost(basetime,type_id)
    local params = {}
    params.base = basetime
    params.barrack_bonu_id = 0
    if type_id == 1001 then 
         params.barrack_bonu_id = 1058
    elseif type_id == 1002 then
         params.barrack_bonu_id = 1059
    elseif type_id == 1003 then 
         params.barrack_bonu_id = 1060
    elseif type_id == 1004 then    
         params.barrack_bonu_id = 1061
    end
    params.soldier_att_id = type_id*10000+25
    params.all_soldier_att_id = 10000 * 10000 + 25
    local _, statusArgs = GetArmyStatus()
    return AttributeBonus.CallBonusFunc(29,params) * (1 + statusArgs[3])
end

function GetTrainCostDefence(basetime,type_id,level)
    local params = {}
    params.base = basetime
    params.soldier_att_id = type_id*10000+26
	local _, statusArgs = GetArmyStatus()
    return AttributeBonus.CallBonusFunc(49,params)* (1 + statusArgs[2])
end

function GetTrainCost(basetime,type_id,level)
    --添加对战争堡垒的特殊开销支持
    if type_id == 101 or type_id == 102 then
        return GetTrainCostDefence(basetime,type_id,level)
    end

    local params = {}
    params.base = basetime
    params.barrack_bonu_id = 0
    if type_id == 1001 then 
         params.barrack_bonu_id = 10001 * 10000 + 26  --1064+level
    elseif type_id == 1002 then
         params.barrack_bonu_id = 10002 * 10000 + 26  --1068+level
    elseif type_id == 1003 then 
         params.barrack_bonu_id = 10003 * 10000 + 26  --1072+level
    elseif type_id == 1004 then    
         params.barrack_bonu_id = 10004 * 10000 + 26  --1076+level
     end
    params.soldier_att_id = type_id*10000+26
    params.all_soldier_att_id = 10000 * 10000 + 26
    local _, statusArgs = GetArmyStatus()
    return AttributeBonus.CallBonusFunc(31,params) * (1 + statusArgs[2])
end




function GetWeightCost(base,type_id,global)
    local params = {}
    params.base = base
    params.soldier_att_id = type_id*10000+21
    params.all_soldier_att_id = 10000 * 10000 + 21
    return AttributeBonus.CallBonusFunc(2,params,global)
end

function GetTrainSpeed(buildid)
	local info = nil
	local result = 0
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			local soldier = Barrack.GetAramInfo(iType , iLevel)
			if soldier ~= nil and soldier.BarrackId  == buildid then
				info = soldier
				break
			end
		end
	end
	for iType = 101, 102 do
		for iLevel = 1 , 4 do
			local soldier = Barrack.GetAramInfo(iType , iLevel)
			if soldier ~= nil and soldier.BarrackId  == buildid then
				info = soldier
				break
			end
		end
	end
	if info ~= nil then
		result = 1 / GetTrainTime(1,info.SoldierId) - 1
	else
		result = 0
	end
	
	return result
end

function GetArmyRealNum(baseid,level)
	if BarrackInfosMap[baseid] == nil or BarrackInfosMap[baseid][level] == nil then
		return 0
	end
	if setoutNum ~= nil and setoutNum[baseid]~= nil and setoutNum[baseid][level] ~= nil then
		return BarrackInfosMap[baseid][level].Num + setoutNum[baseid][level]
	else
		return BarrackInfosMap[baseid][level].Num
	end

end

function GetAramInfo(baseid,level)
	if BarrackInfosMap[baseid] == nil or BarrackInfosMap[baseid][level] == nil then
		return nil
	end
    return BarrackInfosMap[baseid][level]
end

function GetRealArmy()
	local allArmy = {}
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			local soldier_data = GetAramInfo(iType , iLevel)
			if soldier_data ~= nil then
				local rs = {}
				rs.Num = GetArmyRealNum(iType,iLevel)				
				rs.UnitID = soldier_data.UnitID
				rs.SoldierId = soldier_data.SoldierId
				rs.Grade = soldier_data.Grade
				rs.SoldierName = soldier_data.SoldierName
				rs.SoldierIcon = soldier_data.SoldierIcon
				rs.fight = soldier_data.fight
				rs.Weight = soldier_data.Weight
				rs.TeamCount = soldier_data.TeamCount
				rs.Speed = soldier_data.Speed
				if rs.Num > 0 then
					table.insert(allArmy,rs)
				end
			end
		end
	end
	return allArmy
end

function GetRealArmyNum()
	local totalnum = 0
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			totalnum = totalnum + GetArmyRealNum(iType,iLevel)
		end
	end
	return totalnum
end

local armyStatusArgsList
function GetArmyStatus()
    if armyStatusArgsList == nil then
        armyStatusArgsList = {}
		local value = tableData_tGlobal.data[100231].value
        for v in string.gsplit(value, ";") do
            local args = string.split(v, ":")
            table.insert(armyStatusArgsList, 1, {tonumber(args[1]) * 0.0001, tonumber(args[2]) * 0.0001, tonumber(args[3]) * 0.0001,tonumber(args[4]) * 0.0001})
        end
    end

    local armyNum = Barrack.GetRealArmyNum() + GetTrainningArmyNum()
    local maxNum = ParadeGround.GetArmyMaxNum()
    for i, v in ipairs(armyStatusArgsList) do
        if armyNum >= maxNum * v[1] then
            return #armyStatusArgsList - i + 1, v
        end
    end
end

function GetArmy()
	local allArmy = {}
	local totalnum = 0
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			local soldier = GetAramInfo(iType , iLevel)
			if soldier ~= nil and soldier.Num > 0 then
				table.insert(allArmy,soldier)
				totalnum = totalnum + soldier.Num
			end
		end
	end
	return allArmy
end

function GetArmyNum()
	local totalnum = 0
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			local soldier = GetAramInfo(iType , iLevel)
			if soldier ~= nil and soldier.Num > 0 then
				totalnum = totalnum + soldier.Num
			end
		end
	end
	return totalnum
end

function GetTrainningArmyNum()
	local num = 0
	table.foreach(BarrackInfosMap,function(i,soldierid)
		table.foreach(soldierid,function(k,data)
			num = num + data.TmpTrainNum
		end)
	end)
	return num
end

function GetDefConstruct()
	local allConstruct = {}
	for iType = 101 , 102 do
		for iLevel = 1 , 4 do
			local cons = GetAramInfo(iType , iLevel)
			if cons ~= nil and cons.Num > 0 then
				table.insert(allConstruct,cons)
			end
		end
	end
	return allConstruct
end

function GetDefTotalNum()
	local num = 0
	for iType = 101 , 102 do
		for iLevel = 1 , 4 do
			local cons = GetAramInfo(iType , iLevel)
			if cons ~= nil and cons.Num > 0 then
				num = num + cons.Num
			end
		end
	end
	return num
end

function GetTrainInfo(buildId)
    for _,soldierid in pairs(BarrackInfosMap) do
        for __,data in pairs(soldierid) do
            if data.BarrackId == buildId then
                if data.TimeSec > Serclimax.GameTime.GetSecTime() then
                    return data
                end
            end  
        end
    end
    return nil
end



local function InitCfgInfo()
    if BarrackInfosMap == nil then
        BarrackInfosMap = {}
	    local barrack_table = TableMgr:GetBarrackTable()
		for _ , v in pairs(barrack_table) do
			local data = v
	        if BarrackInfosMap[data.SoldierId] == nil then
				BarrackInfosMap[data.SoldierId] = {}
			end
			BarrackInfosMap[data.SoldierId][data.Grade] = data	
			BarrackInfosMap[data.SoldierId][data.Grade].Res = {}
			BarrackInfosMap[data.SoldierId][data.Grade].Training = false
			BarrackInfosMap[data.SoldierId][data.Grade].Num = 0
			BarrackInfosMap[data.SoldierId][data.Grade].TmpTrainNum = 0
			BarrackInfosMap[data.SoldierId][data.Grade].TimeSec = 0
			BarrackInfosMap[data.SoldierId][data.Grade].TotalTime = 0
			local t = string.split(data.NeedItem,';')
			--table.foreach(t, function(i,v) print(i,v) end )
			for i = 1,#(t) do
				local tt = string.split(t[i],':')
				--print(tonumber(tt[1]).."  "..tonumber(tt[2]))
				BarrackInfosMap[data.SoldierId][data.Grade].Res[tonumber(tt[1])] = tonumber(tt[2])
            end

			BarrackInfosMap[data.SoldierId][data.Grade].Num = 0
			
			Barrack_Soldier.SetUpTable(data)
		end
		
	    --[[local iter = barrack_table:GetEnumerator()
	    while iter:MoveNext() do
	        local data = iter.Current.Value
	        if BarrackInfosMap[data.SoldierId] == nil then
				BarrackInfosMap[data.SoldierId] = {}
			end
			BarrackInfosMap[data.SoldierId][data.Grade] = data	
			BarrackInfosMap[data.SoldierId][data.Grade].Res = {}
			BarrackInfosMap[data.SoldierId][data.Grade].Training = false
			BarrackInfosMap[data.SoldierId][data.Grade].Num = 0
			BarrackInfosMap[data.SoldierId][data.Grade].TmpTrainNum = 0
			BarrackInfosMap[data.SoldierId][data.Grade].TimeSec = 0
			BarrackInfosMap[data.SoldierId][data.Grade].TotalTime = 0
			local t = string.split(data.NeedItem,';')
			--table.foreach(t, function(i,v) print(i,v) end )
			for i = 1,#(t) do
				local tt = string.split(t[i],':')
				--print(tonumber(tt[1]).."  "..tonumber(tt[2]))
				BarrackInfosMap[data.SoldierId][data.Grade].Res[tonumber(tt[1])] = tonumber(tt[2])
            end

			BarrackInfosMap[data.SoldierId][data.Grade].Num = 0
			
			Barrack_Soldier.SetUpTable(data)
	    end]]
    end
    
    if BarrackState == nil then
        return
    end

	BarrackInfos = {}
	table.foreach(BarrackInfosMap,function(i,soldierid)
		table.foreach(soldierid,function(k,data)
			if data.BarrackId == BarrackState.BarrackID then
				if BarrackInfos[data.SoldierTab] == nil then
					BarrackInfos[data.SoldierTab] = {}
					BarrackInfos[data.SoldierTab].MinGrade = 1
					BarrackInfos[data.SoldierTab].Unlock = false
	            end
	            BarrackInfos[data.SoldierTab][data.Grade] = data

	            if not BarrackInfos[data.SoldierTab].Unlock and data.Grade == 1 then
	                if UnlockArmyData.HasArmy(data.UnitID) then
	                    BarrackInfos[data.SoldierTab].Unlock =true
	                end
	            end
				if data.BarrackLevel<=BarrackState.BarrackLevel then
					if data.Science == "NA" then
						if BarrackInfos[data.SoldierTab].MinGrade < data.Grade then
							BarrackInfos[data.SoldierTab].MinGrade = data.Grade
						end
					else 
					    local tech = Laboratory.GetTech(tonumber(data.Science))
					    if tech ~= nil and 
						    tech.Info.level >= data.ScienceLevel and 
						    BarrackInfos[data.SoldierTab].MinGrade < data.Grade then
							BarrackInfos[data.SoldierTab].MinGrade = data.Grade
						end
					end
	            end
			end
		end)
	end)


end

function GetBarrackInfosMap()
	InitCfgInfo()
	return BarrackInfosMap
end

function GetBarrackModle(_soldierid)	
	local barrackid = _soldierid - 980
	InitCfgInfo()
	BarrackInfos = {}
	table.foreach(BarrackInfosMap,function(i,soldierid)
		table.foreach(soldierid,function(k,data)
			if data.BarrackId == barrackid then
				if BarrackInfos[data.SoldierTab] == nil then
					BarrackInfos[data.SoldierTab] = {}
					BarrackInfos[data.SoldierTab].MinGrade = 1
					BarrackInfos[data.SoldierTab].Unlock = false
	            end
	            BarrackInfos[data.SoldierTab][data.Grade] = data

	            if not BarrackInfos[data.SoldierTab].Unlock and data.Grade == 1 then
	                if UnlockArmyData.HasArmy(data.UnitID) then
	                    BarrackInfos[data.SoldierTab].Unlock =true
	                end
	            end
					if data.Science == "NA" then
						if BarrackInfos[data.SoldierTab].MinGrade < data.Grade then
							BarrackInfos[data.SoldierTab].MinGrade = data.Grade
						end
					else 
					    local tech = Laboratory.GetTech(tonumber(data.Science))
					    if tech ~= nil and 
						    tech.Info.level >= data.ScienceLevel and 
						    BarrackInfos[data.SoldierTab].MinGrade < data.Grade then
							BarrackInfos[data.SoldierTab].MinGrade = data.Grade
						end
					end
			end
		end)
	end)
	local unit_data = TableMgr:GetUnitData(BarrackInfos[1][BarrackInfos[1].MinGrade].UnitID)
	return ResourceLibrary:GetUnitInstance4UI(unit_data._unitPrefab), TextMgr:GetText(BarrackInfos[1][BarrackInfos[1].MinGrade].SoldierName)
end

function GetSetoutHero()
	return setoutHero
end

function UpdateArmNumEx(msg,exsetoutnum)
	if msg.arms == nil then
		return
    end
    setoutNum = nil
	setoutHero = nil
	local setoutlist = exsetoutnum
	if setoutlist == nil then
	    setoutlist = msg.setoutNum
	end
    if setoutlist ~= nil then
        setoutNum = {}
		setoutHero = {}
        for i = 1,#(setoutlist.army) do
            if setoutNum[setoutlist.army[i].baseid] == nil then
                setoutNum[setoutlist.army[i].baseid] = {}
            end
            setoutNum[setoutlist.army[i].baseid][setoutlist.army[i].level] = setoutlist.army[i].num
           -- print(msg.setoutNum.army[i].baseid,msg.setoutNum.army[i].level,setoutNum[msg.setoutNum.army[i].baseid][msg.setoutNum.army[i].level])
        end

		SetoutData.SetData(setoutlist)
    end

	for i = 1,#(msg.arms) do
		if BarrackInfosMap[msg.arms[i].baseid] ~= nil and BarrackInfosMap[msg.arms[i].baseid][msg.arms[i].level] ~= nil then
			BarrackInfosMap[msg.arms[i].baseid][msg.arms[i].level].Num = msg.arms[i].num
			RefrushSetout4ArmyNum(msg.arms[i])
			--print(msg.arms[i].baseid.." "..msg.arms[i].level.." "..msg.arms[i].num.." "..BarrackInfos[msg.arms[i].baseid][msg.arms[i].level].Num)
        end
    end
    ShowParadeGroundArmy()
end

function RefrushSetout4ArmyNum(arms)
    if setoutNum ~= nil and  arms ~= nil then
        if BarrackInfosMap[arms.baseid] ~= nil and 
            BarrackInfosMap[arms.baseid][arms.level] ~= nil and
            setoutNum[arms.baseid] ~= nil and
            setoutNum[arms.baseid][arms.level] ~= nil then
               -- print(arms.baseid,arms.level,setoutNum[arms.baseid][arms.level],"old num", BarrackInfosMap[arms.baseid][arms.level].Num,"new",BarrackInfosMap[arms.baseid][arms.level].Num - setoutNum[arms.baseid][arms.level])
                BarrackInfosMap[arms.baseid][arms.level].Num = BarrackInfosMap[arms.baseid][arms.level].Num - setoutNum[arms.baseid][arms.level]
            end
    end   
end

function UpdateArmyStatus()
	if isOpen then
	    transform:Find("Container/bg_frane/soldier_icon"):GetComponent("UISprite").spriteName = "icon_soldiernow" .. Barrack.GetArmyStatus() 
    end
end

local function UpdateArmNum(msg)
	if msg.code == 0 then
	    UpdateArmNumEx(msg)
		if RequestState.CallBack ~= nil then
			RequestState.CallBack(msg)
        end
	else
		if msg.code == 100021 then 
			FloatText.Show(TextMgr:GetText("army_max_ui4"), Color.red)--"已超过造兵上限，请升级校场以提升造兵上限" 
		else
			Global.ShowError(msg.code)
		end 
	end
	MainCityUI.UpdateArmyStatus()
	UpdateArmyStatus()
end



function RequestArmNum(callback)
    --local info = debug.getinfo(2,"S")
    --print("^^^^^^^^^^^^^^^^RequestArmNum",info.source,info.linedefined)
	RequestState = {}
	RequestState.State = "RequestArmNum"
	RequestState.CallBack = callback	
	local req = HeroMsg_pb.MsgUserArmyUnitsRequest()
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgUserArmyUnitsRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgUserArmyUnitsResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgUserArmyUnitsRequest, req,HeroMsg_pb.MsgUserArmyUnitsResponse,function(msg)
		UpdateArmNum(msg)
	end, true)
end

function RefreshArmNum(msg)
	if msg.code == 0 then
		if msg.fresh.arms ~= nil then
			for i=1,#(msg.fresh.arms.data) do
				local arm =	msg.fresh.arms.data[i].data
				if BarrackInfosMap[arm.baseid] ~= nil and BarrackInfosMap[arm.baseid][arm.level] ~= nil then
					BarrackInfosMap[arm.baseid][arm.level].Num = arm.num
					RefrushSetout4ArmyNum(arm)
					--ShowParadeGroundArmy()
                end
            end
        end
        if BarrackUI ~= nil then
		    ClearTraningTag()
		    SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)	    
	    end
	    CountDown.Instance:Remove("BarrackTraining")
	else
    end
	MainCityUI.UpdateArmyStatus()
	UpdateArmyStatus()
end

local function UpdateAccelArmyTrain(msg)
	if msg.code == 0 then
		MainCityUI.UpdateRewardData(msg.fresh)
		RefreshArmNum(msg)
		ClearTraningTag()	
		if RequestState.CallBack ~= nil then
			RequestState.CallBack(msg)
		end			
	else
		Global.ShowError(msg.code)
    end
end

function RequestAccelArmyTrainEx(barrackinfo,curbuild,callback)
	local req = HeroMsg_pb.MsgAccelArmyTrainRequest()
	req.buildUid = curbuild.data.uid
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgAccelArmyTrainRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgAccelArmyTrainResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgAccelArmyTrainRequest, req,HeroMsg_pb.MsgAccelArmyTrainResponse,function(msg)	
		maincity.RemoveBuildCountDown(curbuild)	
	    if msg.code == 0 then
			--send data report-----------------------------------
			GUIMgr:SendDataReport("purchase", "costgold", "AccelArmyTrain:" ..barrackinfo.UnitID, "1", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
			-----------------------------------------------------
		    --MainCityUI.UpdateRewardData(msg.fresh)
		    RefreshArmNum(msg)
		    if callback ~= nil then
		        callback(msg)
		    end
	    else
		    Global.ShowError(msg.code)
        end		
	end, true)	
end

local function RequestAccelArmyTrain(callback)
	RequestState = {}
	RequestState.State = "RequestAccelArmyTrain"
	RequestState.CallBack = callback	
	local req = HeroMsg_pb.MsgAccelArmyTrainRequest()
	req.buildUid = BarrackState.BarrackUID
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgAccelArmyTrainRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgAccelArmyTrainResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgAccelArmyTrainRequest, req,HeroMsg_pb.MsgAccelArmyTrainResponse,function(msg)	
		if msg.code == 0 then
			--send data report-----------------------------------
			if BarrackState ~= nil then
				GUIMgr:SendDataReport("purchase", "costgold", "AccelArmyTrain:" ..BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].UnitID, "1", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
			end
				-----------------------------------------------------
		end
		UpdateAccelArmyTrain(msg)
		maincity.RemoveBuildCountDown(CurBuild)		
	end, true)	
end

local function UpdateTrainInfo(msg)
	if msg.code == 0 then
		if msg.train == nil then
			ClearTraningTag()
			return
		end
		
		for i = 1,#(msg.train) do
		    BarrackInfosMap[msg.train[i].army.baseid][msg.train[i].army.level].TimeSec = msg.train[i].endtime
		    BarrackInfosMap[msg.train[i].army.baseid][msg.train[i].army.level].TotalTime = msg.train[i].originaltime
            BarrackInfosMap[msg.train[i].army.baseid][msg.train[i].army.level].TmpTrainNum =  msg.train[i].army.num
            --BarrackInfosMap[msg.train[i].army.baseid][msg.train[i].army.level].Training = true; 
			if BarrackState ~= nil  and msg.train[i].buildUid == BarrackState.BarrackUID then
			    BarrackState.CurTrainingTab = BarrackInfosMap[msg.train[i].army.baseid][msg.train[i].army.level].SoldierTab
				BarrackState.CurTrainingGrade = BarrackInfosMap[msg.train[i].army.baseid][msg.train[i].army.level].Grade
                BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TotalTime = msg.train[i].originaltime
				BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TimeSec = msg.train[i].endtime
				BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].Training = true;
				BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TmpTrainNum = msg.train[i].army.num
				BarrackState.Training = true
			end
		end		
	else
		Global.ShowError(msg.code)
	end
end

local function RequestTrainInfo(build_id,callback,param)
	local req = HeroMsg_pb.MsgGetArmyTrainInfoRequest()
	req.buildUid:append(build_id)
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmyTrainInfoRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgGetArmyTrainInfoResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmyTrainInfoRequest, req,HeroMsg_pb.MsgGetArmyTrainInfoResponse,function(msg)	
		if callback ~= nil then
			callback(msg,param)
		end
		--UpdateTrainInfo(msg)
	end, true)	
end

local function UpdateTrainInfo4Building(msg,build)
	if msg.code == 0 then
		if msg.train == nil then
			return
		end
		for i = 1,#(msg.train) do
			--table.foreach(msg.train[i],function(i,v) print(i,v) end)
			if msg.train[i].buildUid == build.data.uid then 
				--print(msg.train[i].buildUid,msg.train[i].endtime, msg.train[i].endtime-GameTime.GetSecTime())
				maincity.SetBuildCountDown(build,msg.train[i].endtime,function(t)
				    --print("SSSSSSSSSSSSSSSSSSSS",t)
					if t == "00:00:00" then
						maincity.RefreshBuildingTransition(build)
						MainCityQueue.UpdateQueue()
						--RequestArmNum()
						RefreshArmNum(msg)
					end					
				end , "time_icon9")
            end
		end		
	else
		Global.ShowError(msg.code)
	end	
end

function RequsetBarrackTrainInfo(build)
    RequestTrainInfo(build.data.uid,UpdateTrainInfo4Building,build)
	--local builds = maincity.GetBuildingList()
	--for _, v in pairs(builds) do
	--	if v.data ~= nil and v.data.type >= 21 and  v.data.type <= 24 then
	--		RequestTrainInfo(v.data.uid,UpdateTrainInfo4Building,v)
	--end
    --end
end



local function UpdateCancelArmyTrain(msg)
	if msg.code == 0 then
		MainCityUI.UpdateRewardData(msg.fresh)
		RefreshArmNum(msg)
		ClearTraningTag()
		maincity.RemoveBuildCountDown(CurBuild)
		if RequestState.CallBack ~= nil then
			RequestState.CallBack(msg)
		end			
	else
		Global.ShowError(msg.code)
	end
end

function RequestCancelArmyTrainEx(build,callback)
	local req = HeroMsg_pb.MsgCancelArmyTrainRequest()
	req.buildUid = build.data.uid
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgCancelArmyTrainRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgCancelArmyTrainResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgCancelArmyTrainRequest, req,HeroMsg_pb.MsgCancelArmyTrainResponse,function(msg)	
	if msg.code == 0 then
		MainCityUI.UpdateRewardData(msg.fresh)
		RefreshArmNum(msg)
		maincity.RemoveBuildCountDown(build)
		if callback ~= nil then
			callback(msg)
		end			
	else
		Global.ShowError(msg.code)
    end
	end, true)	
end

local function RequestCancelArmyTrain(callback)
	RequestState = {}
	RequestState.State = "RequestCancelArmyTrain"
	RequestState.CallBack = callback	
	local req = HeroMsg_pb.MsgCancelArmyTrainRequest()
	req.buildUid = BarrackState.BarrackUID
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgCancelArmyTrainRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgCancelArmyTrainResponse()
	--	msg:ParseFromString(data)
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgCancelArmyTrainRequest, req,HeroMsg_pb.MsgCancelArmyTrainResponse,function(msg)
		UpdateCancelArmyTrain(msg)
	end, true)		
end

local function SetupTrain(tab,grade)
	if BarrackUI == nil then
		return
	end	
	if BarrackUI.SoldierTrain.Schedule.Root == nil or BarrackUI.SoldierTrain.Schedule.Root:Equals(nil) then
		return
	end
	if BarrackUI.SoldierTrain.Training.Root == nil or BarrackUI.SoldierTrain.Training.Root:Equals(nil) then
		return
	end			
	local num = math.floor(BarrackState.TrainSelNum)
	local traininggrde = 0
	for i = 1, 4 do
		if BarrackInfos[tab][i].Training then
			traininggrde = i
		end
	end
	BarrackUI.DownInfo.Title.text = TextMgr:GetText(BarrackInfos[tab][grade].SoldierName)
	if traininggrde > 0 then
		grade = traininggrde
	end
	if BarrackState.CurTrainingTab ~= 0 then
		tab = BarrackState.CurTrainingTab
	end
	if BarrackInfos[tab][grade].Training then
		BarrackUI.SoldierTrain.Schedule.Root:SetActive(false)
		BarrackUI.SoldierTrain.Training.Root:SetActive(true)
		if BarrackUI.SoldierTrain.Training.DescribeTxt == nil then
			BarrackUI.SoldierTrain.Training.DescribeTxt = BarrackUI.SoldierTrain.Training.Describe.text
		end
		
		BarrackUI.SoldierTrain.Training.Describe.text = String.Format(TextMgr:GetText("ui_barrack_training1"), "[" .. TextMgr:GetText(BarrackInfos[tab][grade].SoldierName) .. "] x" .. BarrackInfos[tab][grade].TmpTrainNum .. " ")--String.Format(BarrackUI.SoldierTrain.Training.DescribeTxt,TextMgr:GetText(BarrackInfos[tab][grade].SoldierName))
		--print(math.max(1,  math.floor(SpeedUpprice.GetPrice(2,BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime() ))))
		--local time = math.floor(BarrackState.TrainSelNum*BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TrainTime*BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TeamCount)
		local time = math.max(0, BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime())
		--print(SpeedUpprice.GetPrice(2,time ))
		BarrackUI.SoldierTrain.Training.UogradeGoldBtnNum.text = math.max(1,  math.floor(SpeedUpprice.GetPrice(2,time )+0.5))
		BarrackUI.SoldierTrain.Training.Time.text = GameTime.SecondToString3(BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime())
		BarrackUI.SoldierTrain.Training.TimeSlider.value = (BarrackInfos[tab][grade].TotalTime - (BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime())) / BarrackInfos[tab][grade].TotalTime
		CountDown.Instance:Add("BarrackTraining",BarrackInfos[tab][grade].TimeSec,CountDown.CountDownCallBack(function(t)
			if BarrackUI == nil then
				CountDown.Instance:Remove("BarrackTraining")
				return
			end
			BarrackUI.SoldierTrain.Training.Time.text  = t
			BarrackUI.SoldierTrain.Training.TimeSlider.value = (BarrackInfos[tab][grade].TotalTime - (BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime())) / BarrackInfos[tab][grade].TotalTime
			--print(BarrackInfos[tab][grade].TimeSec, GameTime.GetSecTime(),BarrackInfos[tab][grade].TimeSec+1 - GameTime.GetSecTime())
			if BarrackInfos[tab][grade].TimeSec+1 - GameTime.GetSecTime() <= 0 then
				BarrackInfos[tab][grade].Training = false
				RequestArmNum(function(msg) 
						if BarrackUI == nil then
							CountDown.Instance:Remove("BarrackTraining")
							return
						end
						if msg.code == 0 then
							--FloatText.Show(TextMgr:GetText(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierName).."  LV."..BarrackState.CurGrade.."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
							ClearTraningTag()
							SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)		
						end
					end)
				
				
				CountDown.Instance:Remove("BarrackTraining")
			end			
		end))
	else
		BarrackUI.SoldierTrain.Schedule.Root:SetActive(true)
		BarrackUI.SoldierTrain.Training.Root:SetActive(false)	

		--BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = num / BarrackState.TrainTotalNum
		--BarrackUI.SoldierTrain.Schedule.TrainScheduleText.text = string.format("%d/%d",num,BarrackState.TrainTotalNum)
	
	    BarrackUI.SoldierTrain.Schedule.TrainScheduleText.text = num
	    BarrackUI.SoldierTrain.Schedule.TrainScheduleText_Denom.text = "/"..BarrackState.TrainTotalNum

		local time = math.floor(num*BarrackInfos[tab][grade].TrainTime*BarrackInfos[tab][grade].TeamCount)
		time = GetTrainTime(time,BarrackInfos[tab][grade].SoldierId)
		--print("XXXXXXXX  SetupTrain NUM"..num.." Time "..BarrackInfos[tab][grade].TrainTime.." team "..BarrackInfos[tab][grade].TeamCount.." result "..time.."    "..GameTime.realTime)
		BarrackUI.SoldierTrain.Schedule.TrainTime.text = GameTime.SecondToString3(time)
		local ResFood = (BarrackInfos[tab][grade].Res[3] == nil and 0 or BarrackInfos[tab][grade].Res[3])*num*BarrackInfos[tab][grade].TeamCount
		local ResIron = (BarrackInfos[tab][grade].Res[4] == nil and 0 or BarrackInfos[tab][grade].Res[4])*num*BarrackInfos[tab][grade].TeamCount
		local ResOil = (BarrackInfos[tab][grade].Res[5] == nil and 0 or BarrackInfos[tab][grade].Res[5])*num*BarrackInfos[tab][grade].TeamCount
		local ResElectric = (BarrackInfos[tab][grade].Res[6] == nil and 0 or BarrackInfos[tab][grade].Res[6])*num*BarrackInfos[tab][grade].TeamCount

        --ResFood = math.floor(GetTrainCost(ResFood,BarrackInfos[tab][grade].SoldierId,grade))
        --ResIron = math.floor(GetTrainCost(ResIron,BarrackInfos[tab][grade].SoldierId,grade))
        --ResOil = math.floor(GetTrainCost(ResOil,BarrackInfos[tab][grade].SoldierId,grade))
        --ResElectric = math.floor(GetTrainCost(ResElectric,BarrackInfos[tab][grade].SoldierId,grade))

		--print("food "..MoneyListData.GetFood().." ResIron "..MoneyListData.GetSteel().." ResOil "..MoneyListData.GetOil().." ResElectric "..MoneyListData.GetElec())

		local spliter = " / ";
        ResFood = math.floor(GetTrainCost(ResFood,BarrackInfos[tab][grade].SoldierId,grade))
		BarrackUI.SoldierTrain.Schedule.ResFood.text = MoneyListData.GetFood() >= ResFood and Global.ExchangeValue(MoneyListData.GetFood())..spliter..Global.ExchangeValue(ResFood) or "[ff0000]"..Global.ExchangeValue(MoneyListData.GetFood()).."[-]"..spliter..Global.ExchangeValue(ResFood)
		--BarrackUI.SoldierTrain.Schedule.ResFood.color = MoneyListData.GetFood() >= ResFood and Color.white or Color.red
		BarrackUI.SoldierTrain.Schedule.ResFoodGet:SetActive(MoneyListData.GetFood() < ResFood)
        ResFood = ResFood - MoneyListData.GetFood() < 0 and 0 or ResFood - MoneyListData.GetFood()
        ResIron = math.floor(GetTrainCost(ResIron,BarrackInfos[tab][grade].SoldierId,grade))
		BarrackUI.SoldierTrain.Schedule.ResIron.text = MoneyListData.GetSteel() >=ResIron and Global.ExchangeValue(MoneyListData.GetSteel())..spliter..Global.ExchangeValue(ResIron) or "[ff0000]"..Global.ExchangeValue(MoneyListData.GetSteel()).."[-]"..spliter..Global.ExchangeValue(ResIron)
		--BarrackUI.SoldierTrain.Schedule.ResIron.color = MoneyListData.GetSteel() >=ResIron and Color.white or Color.red    
		BarrackUI.SoldierTrain.Schedule.ResIronGet:SetActive(MoneyListData.GetSteel() < ResIron)    
        ResIron = ResIron - MoneyListData.GetSteel() < 0 and 0 or ResIron - MoneyListData.GetSteel()
        ResOil = math.floor(GetTrainCost(ResOil,BarrackInfos[tab][grade].SoldierId,grade))
		BarrackUI.SoldierTrain.Schedule.ResOil.text = MoneyListData.GetOil() >=ResOil and Global.ExchangeValue(MoneyListData.GetOil())..spliter..Global.ExchangeValue(ResOil) or "[ff0000]"..Global.ExchangeValue(MoneyListData.GetOil()).."[-]"..spliter..Global.ExchangeValue(ResOil)
		--BarrackUI.SoldierTrain.Schedule.ResOil.color = MoneyListData.GetOil() >= ResOil and Color.white or Color.red     
		BarrackUI.SoldierTrain.Schedule.ResOilGet:SetActive(MoneyListData.GetOil() < ResOil)   
        ResOil = ResOil - MoneyListData.GetOil() < 0 and 0 or ResOil - MoneyListData.GetOil()
        ResElectric = math.floor(GetTrainCost(ResElectric,BarrackInfos[tab][grade].SoldierId,grade))
		BarrackUI.SoldierTrain.Schedule.ResElectric.text = MoneyListData.GetElec() >=ResElectric and Global.ExchangeValue(MoneyListData.GetElec())..spliter..Global.ExchangeValue(ResElectric) or "[ff0000]"..Global.ExchangeValue(MoneyListData.GetElec()).."[-]"..spliter..Global.ExchangeValue(ResElectric)
		--BarrackUI.SoldierTrain.Schedule.ResElectric.color = MoneyListData.GetElec() >= ResElectric and Color.white or Color.red    
		BarrackUI.SoldierTrain.Schedule.ResElectricGet:SetActive(MoneyListData.GetElec() < ResElectric)    
        ResElectric = ResElectric - MoneyListData.GetElec() < 0 and 0 or ResElectric - MoneyListData.GetElec()        
        
        local gold = 0

		gold = gold + maincity.CaculateGoldForRes(3, ResFood)

		gold = gold + maincity.CaculateGoldForRes(4, ResIron)

		gold = gold + maincity.CaculateGoldForRes(5, ResOil)

		gold = gold + maincity.CaculateGoldForRes(6, ResElectric)
        
        gold = math.floor(gold+0.5) + math.floor(SpeedUpprice.GetPrice(2,time)+0.5)        
        --[[
        if MoneyListData.GetFood() < ResFood or MoneyListData.GetSteel() < ResIron or MoneyListData.GetOil() < ResOil or MoneyListData.GetFood() < ResElectric then
            print("Res:",gold,"time", SpeedUpprice.GetPrice(2,time))
            gold = math.floor(gold+0.5) + math.floor(SpeedUpprice.GetPrice(2,time)+0.5)
        else
            gold = math.floor(SpeedUpprice.GetPrice(2,time)+0.5)
        end
        print("total:",gold)
        --]]
		BarrackUI.SoldierTrain.Schedule.UogradeGoldBtnNum.text = num == 0 and 0 or math.max(1, gold)   --num*BarrackInfos[tab][grade].TrainCost*BarrackInfos[tab][grade].TeamCount
    end
end

local function OnSoldierRootClick(grade)
	if BarrackUI == nil then
		return
	end	
    if BarrackUI.SoldierShow[grade].soldierAnim == nil then
        return
    end
	if BarrackUI.SoldierShow[grade].soldierAnim:get_Item("show") ~= nil and grade == BarrackState.CurGrade then
	    if not BarrackUI.SoldierShow[grade].soldierAnim:IsPlaying("show") then
	        BarrackUI.SoldierShow[grade].soldierAnim:PlayQueued("show",UnityEngine.QueueMode.PlayNow)
            BarrackUI.SoldierShow[grade].soldierAnim:PlayQueued("idle",UnityEngine.QueueMode.CompleteOthers)
        end
	else
	    if not BarrackUI.SoldierShow[grade].soldierAnim:IsPlaying("idle") then
	        BarrackUI.SoldierShow[grade].soldierAnim:Play("idle")
        end
    end
end

local function ChangeSoldierLight(grade)
	if BarrackUI == nil then
		return
	end	
	local tab = BarrackState.CurTab
	if grade > BarrackInfos[tab].MinGrade then
		for i = 0, BarrackUI.SoldierShow[grade].soldierMat.Length - 1 do
			local v = BarrackUI.SoldierShow[grade].soldierMat[i]
			v.material:SetFloat("_Brightness", 1)
		    v.material:SetColor("_Color", Color(0.3,0.3,0.3,1))
		end
	    BarrackUI.SoldierShow[grade].Title.color = Color(0.5,0.5,0.5,1)
	elseif grade ~= BarrackState.CurGrade then
		for i = 0, BarrackUI.SoldierShow[grade].soldierMat.Length - 1 do
			local v = BarrackUI.SoldierShow[grade].soldierMat[i]
			v.material:SetFloat("_Brightness", 0.7)
		    v.material:SetColor("_Color", Color.white)
		end
	    BarrackUI.SoldierShow[grade].Title.color = Color(0.5,0.5,0.5,1)
	else
		for i = 0, BarrackUI.SoldierShow[grade].soldierMat.Length - 1 do
			local v = BarrackUI.SoldierShow[grade].soldierMat[i]
			v.material:SetFloat("_Brightness", 1.7)
		    v.material:SetColor("_Color", Color.white)
		end
	    BarrackUI.SoldierShow[grade].Title.color = Color.white
	end
end

local function ChangeAllSoldierLight()
	for i = 1, 4 do
		ChangeSoldierLight(i)
	end
end

SetupOneSoldierAttribute = function(grade)
	local tab = BarrackState.CurTab
	if BarrackInfos[tab] == nil then
		return
	end
	if BarrackUI == nil then
		return
	end	
	local barrack_bonus 
    local food = BarrackInfos[tab][grade].Food
    local bonusfood = GetFoodCost(food,BarrackInfos[tab][grade].SoldierId)
	if  BarrackBuildData[BarrackState.BarrackID][BarrackState.BarrackLevel].BuildID ~= 27 then
        barrack_bonus = AttributeBonus.CalBarrackBonus(BarrackInfos[tab][grade])
	    if barrack_bonus == nil then
		    barrack_bonus = {}
		    barrack_bonus.Attack = BarrackInfos[tab][grade].Attack
		    barrack_bonus.Hp = BarrackInfos[tab][grade].Hp
		    barrack_bonus.Defend  = BarrackInfos[tab][grade].Defend
			barrack_bonus.Penetration = BarrackInfos[tab][grade].Penetration 
			barrack_bonus.ExtraCarry = 0
			barrack_bonus.ExtraMoveSpeed = 0
        end

		BarrackState.TrainSelNum = BarrackState.TrainTotalNum
        BarrackUI.SoldierAttributs.Root:SetActive(true)
        BarrackUI.SoldierAttributs2.Root:SetActive(false)
		BarrackUI.SoldierAttributs.BattlePointNum.text = math.floor(BarrackInfos[tab][grade].fight*10+0.5)*0.1 --math.floor( AttributeBonus.CalBattlePoint(barrack_bonus,BarrackInfos[tab][grade].TeamCount)*10)*0.1
		local fight = AttributeBonus.CalBattlePointSLGPVPArmy(BarrackInfos[tab][grade])
		--print(fight, BarrackInfos[tab][grade].fight)
		BarrackUI.SoldierAttributs.BattlePointExtra.text = (fight - BarrackInfos[tab][grade].fight ) < 0.1 and "" or  ("(+"..(math.floor((fight - BarrackInfos[tab][grade].fight)*10 +0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleFoodNum.text=  math.floor(food*100+0.5)*0.01
		--print(bonusfood,food)
		BarrackUI.SoldierAttributs.BattleFoodExtra.text =(bonusfood - food ) < 0.1 and "" or  ("("..(math.floor((bonusfood - food)*100 +0.5))*0.01 ..")")

		BarrackUI.SoldierAttributs.BattleAttackNum.text = math.floor(BarrackInfos[tab][grade].Attack*10)*0.1
		--print(barrack_bonus.Attack,BarrackInfos[tab][grade].Attack)
		BarrackUI.SoldierAttributs.BattleAttackExtra.text = (barrack_bonus.Attack - BarrackInfos[tab][grade].Attack ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Attack - BarrackInfos[tab][grade].Attack)*10+0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleWeightNum.text = math.floor(BarrackInfos[tab][grade].Weight*10)*0.1
		local w = GetWeightCost(BarrackInfos[tab][grade].Weight + barrack_bonus.ExtraCarry,BarrackInfos[tab][grade].SoldierId)
		BarrackUI.SoldierAttributs.BattleWeightExtra.text = (w - BarrackInfos[tab][grade].Weight) < 0.1 and "" or  ("(+"..(math.floor((w - BarrackInfos[tab][grade].Weight)*10 +0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleHpNum.text = math.floor(BarrackInfos[tab][grade].Hp*10)*0.1
		BarrackUI.SoldierAttributs.BattleHpExtra.text = (barrack_bonus.Hp - BarrackInfos[tab][grade].Hp ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Hp - BarrackInfos[tab][grade].Hp)*10+0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleSoldiernuNum.text = System.String.Format("{0:P1}", GetTrainSpeed(CurBuild.data.type))--math.floor(BarrackInfos[tab][grade].TeamCount*10)*0.1
		BarrackUI.SoldierAttributs.BattleSoldiernuExtra.text = ""

		BarrackUI.SoldierAttributs.BattleDefendNum.text = math.floor(BarrackInfos[tab][grade].fakeArmo*10)*0.1
		BarrackUI.SoldierAttributs.BattleDefendExtra.text = (barrack_bonus.Defend ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Defend )*10+0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattlePentNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrain)--math.floor(BarrackInfos[tab][grade].Penetration*10)*0.1
		BarrackUI.SoldierAttributs.BattlePentNum.color = Color.green
		BarrackUI.SoldierAttributs.BattlePentExtra.text = ""--(barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration)*10+0.5))*0.1 ..")")
		
		BarrackUI.SoldierAttributs.BattleDisadNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrained)
		BarrackUI.SoldierAttributs.BattleDisadNum.color = Color.red
		BarrackUI.SoldierAttributs.BattleDisadExtra.text = ""
		
		BarrackUI.SoldierAttributs.BattleAttackSpeedNum.text = math.floor(BarrackInfos[tab][grade].Speed*10)*0.1
		BarrackUI.SoldierAttributs.BattleAttackSpeedExtra.text = barrack_bonus.ExtraMoveSpeed < 0.1 and "" or ("(+" .. barrack_bonus.ExtraMoveSpeed .. ")")

		--print(tab.." "..grade.." "..BarrackInfos[tab][grade].Num)
		BarrackUI.SoldierAttributs.BattleArmyNumdNum.text = BarrackInfos[tab][grade].Num
		BarrackUI.SoldierAttributs.BattleArmyNumdExtra.text = ""
    else
        barrack_bonus =  AttributeBonus.CalBarrackBonus27(BarrackInfos[tab][grade])
	    if barrack_bonus == nil then
		    barrack_bonus = {}
		    barrack_bonus.Attack = BarrackInfos[tab][grade].Attack
		    barrack_bonus.Hp = BarrackInfos[tab][grade].Hp
		    barrack_bonus.Defend  = BarrackInfos[tab][grade].Defend
		    barrack_bonus.Penetration = BarrackInfos[tab][grade].Penetration 
	    end  
        BarrackUI.SoldierAttributs.Root:SetActive(false)
        BarrackUI.SoldierAttributs2.Root:SetActive(true)        

	    BarrackUI.SoldierAttributs2.BattlePointNum.text = math.floor(BarrackInfos[tab][grade].fight*10+0.5)*0.1 --math.floor( AttributeBonus.CalBattlePoint(barrack_bonus,BarrackInfos[tab][grade].TeamCount)*10)*0.1
	    local fight = AttributeBonus.CalBattlePointSLGPVPArmyEx(BarrackInfos[tab][grade])
	    print(fight, BarrackInfos[tab][grade].fight)
	    BarrackUI.SoldierAttributs2.BattlePointExtra.text = (fight - BarrackInfos[tab][grade].fight ) == 0 and "" or  ("(+"..(math.floor((fight - BarrackInfos[tab][grade].fight)*10 +0.5))*0.1 ..")")

	    BarrackUI.SoldierAttributs2.BattleAttackNum.text = math.floor(BarrackInfos[tab][grade].Attack*10)*0.1
	    BarrackUI.SoldierAttributs2.BattleAttackExtra.text = (barrack_bonus.Attack - BarrackInfos[tab][grade].Attack ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Attack - BarrackInfos[tab][grade].Attack)*10+0.5))*0.1 ..")")
        
	    BarrackUI.SoldierAttributs2.BattleHpNum.text = math.floor(BarrackInfos[tab][grade].Hp*10)*0.1
	    BarrackUI.SoldierAttributs2.BattleHpExtra.text = (barrack_bonus.Hp - BarrackInfos[tab][grade].Hp ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Hp - BarrackInfos[tab][grade].Hp)*10+0.5))*0.1 ..")")        

	    BarrackUI.SoldierAttributs2.BattleDefendNum.text = math.floor(BarrackInfos[tab][grade].fakeArmo*10)*0.1
	    BarrackUI.SoldierAttributs2.BattleDefendExtra.text = (barrack_bonus.Defend ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Defend )*10+0.5))*0.1 ..")")

	    BarrackUI.SoldierAttributs2.BattlePentNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrain)--math.floor(BarrackInfos[tab][grade].Penetration*10)*0.1
	    BarrackUI.SoldierAttributs2.BattlePentNum.color = Color.green
	    BarrackUI.SoldierAttributs2.BattlePentExtra.text = ""--(barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration)*10+0.5))*0.1 ..")")        

    	BarrackUI.SoldierAttributs2.BattleAttackSpeedNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrained)--math.floor(BarrackInfos[tab][grade].AttackSpeed*10)*0.1
    	BarrackUI.SoldierAttributs2.BattleAttackSpeedNum.color = Color.red
	    BarrackUI.SoldierAttributs2.BattleAttackSpeedExtra.text = ""
	    --BarrackUI.SoldierAttributs2.BattleArmyNumdNum.text = BarrackInfos[tab][grade].Num
	    --BarrackUI.SoldierAttributs2.BattleArmyNumdExtra.text = ""	
	    
		
		local wallBuilding = maincity.GetBuildingByID(26)--城墙
		local limitNum = wallBuilding == nil and 0 or TableMgr:GetWallData(wallBuilding.data.level).maxDefNumber
		limitNum = limitNum + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseDefenceMaxNum).value)
		BarrackUI.SoldierAttributs2.DefendArmyNum.text = GetDefTotalNum() .. "/" .. limitNum
	end
	BarrackUI.SoldierAttributs.Title.text = TextMgr:GetText(BarrackInfos[tab][grade].SoldierName)
end

SetupSoldierAttributes = function(tab,grade)
    --print(BarrackState.TrainTotalNum)
	if BarrackInfos[tab] == nil  then
		return
	end
	if  BarrackUI == nil then
		return
	end
	BarrackState.CurGrade = grade
	--BarrackUI.SoldierShow.Title.text = TextMgr:GetText(BarrackInfos[tab][grade].SoldierName)
--[[
	local barrack_bonus 
	
    local food = BarrackInfos[tab][grade].Food
    local bonusfood = GetFoodCost(food,BarrackInfos[tab][grade].SoldierId)
--]]
	if  BarrackBuildData[BarrackState.BarrackID][BarrackState.BarrackLevel].BuildID ~= 27 then
		--[[
        barrack_bonus = AttributeBonus.CalBarrackBonus(BarrackInfos[tab][grade])
	    if barrack_bonus == nil then
		    barrack_bonus = {}
		    barrack_bonus.Attack = BarrackInfos[tab][grade].Attack
		    barrack_bonus.Hp = BarrackInfos[tab][grade].Hp
		    barrack_bonus.Defend  = BarrackInfos[tab][grade].Defend
		    barrack_bonus.Penetration = BarrackInfos[tab][grade].Penetration 
        end
		--]]
		BarrackState.TrainSelNum = BarrackState.TrainTotalNum
		--[[
	    BarrackUI.DownInfo.Title.text = TextMgr:GetText("ui_barrack_title2")
        BarrackUI.SoldierAttributs.Root:SetActive(true)
        BarrackUI.SoldierAttributs2.Root:SetActive(false)
		BarrackUI.SoldierAttributs.BattlePointNum.text = math.floor(BarrackInfos[tab][grade].fight*10+0.5)*0.1 --math.floor( AttributeBonus.CalBattlePoint(barrack_bonus,BarrackInfos[tab][grade].TeamCount)*10)*0.1
		local fight = AttributeBonus.CalBattlePointSLGPVPArmy(BarrackInfos[tab][grade])
		--print(fight, BarrackInfos[tab][grade].fight)
		BarrackUI.SoldierAttributs.BattlePointExtra.text = (fight - BarrackInfos[tab][grade].fight ) < 0.1 and "" or  ("(+"..(math.floor((fight - BarrackInfos[tab][grade].fight)*10 +0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleFoodNum.text=  math.floor(food*100+0.5)*0.01
		--print(bonusfood,food)
		BarrackUI.SoldierAttributs.BattleFoodExtra.text =(bonusfood - food ) < 0.1 and "" or  ("("..(math.floor((bonusfood - food)*100 +0.5))*0.01 ..")")

		BarrackUI.SoldierAttributs.BattleAttackNum.text = math.floor(BarrackInfos[tab][grade].Attack*10)*0.1
		--print(barrack_bonus.Attack,BarrackInfos[tab][grade].Attack)
		BarrackUI.SoldierAttributs.BattleAttackExtra.text = (barrack_bonus.Attack - BarrackInfos[tab][grade].Attack ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Attack - BarrackInfos[tab][grade].Attack)*10+0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleWeightNum.text = math.floor(BarrackInfos[tab][grade].Weight*10)*0.1
		local w = GetWeightCost(BarrackInfos[tab][grade].Weight,BarrackInfos[tab][grade].SoldierId)
		BarrackUI.SoldierAttributs.BattleWeightExtra.text = (w - BarrackInfos[tab][grade].Weight ) < 0.1 and "" or  ("(+"..(math.floor((w - BarrackInfos[tab][grade].Weight)*10 +0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleHpNum.text = math.floor(BarrackInfos[tab][grade].Hp*10)*0.1
		BarrackUI.SoldierAttributs.BattleHpExtra.text = (barrack_bonus.Hp - BarrackInfos[tab][grade].Hp ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Hp - BarrackInfos[tab][grade].Hp)*10+0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattleSoldiernuNum.text = System.String.Format("{0:P1}", GetTrainSpeed(CurBuild.data.type))--math.floor(BarrackInfos[tab][grade].TeamCount*10)*0.1
		BarrackUI.SoldierAttributs.BattleSoldiernuExtra.text = ""

		BarrackUI.SoldierAttributs.BattleDefendNum.text = math.floor(BarrackInfos[tab][grade].fakeArmo*10)*0.1
		BarrackUI.SoldierAttributs.BattleDefendExtra.text = (barrack_bonus.Defend ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Defend )*10+0.5))*0.1 ..")")

		BarrackUI.SoldierAttributs.BattlePentNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrain)--math.floor(BarrackInfos[tab][grade].Penetration*10)*0.1
		BarrackUI.SoldierAttributs.BattlePentNum.color = Color.green
		BarrackUI.SoldierAttributs.BattlePentExtra.text = ""--(barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration ) < 0.1 and "" or  ("(+"..(math.floor((barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration)*10+0.5))*0.1 ..")")
		
		BarrackUI.SoldierAttributs.BattleDisadNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrained)
		BarrackUI.SoldierAttributs.BattleDisadNum.color = Color.red
		BarrackUI.SoldierAttributs.BattleDisadExtra.text = ""
		
		BarrackUI.SoldierAttributs.BattleAttackSpeedNum.text = math.floor(BarrackInfos[tab][grade].Speed*10)*0.1
		BarrackUI.SoldierAttributs.BattleAttackSpeedExtra.text = ""

		--print(tab.." "..grade.." "..BarrackInfos[tab][grade].Num)
		BarrackUI.SoldierAttributs.BattleArmyNumdNum.text = BarrackInfos[tab][grade].Num
		BarrackUI.SoldierAttributs.BattleArmyNumdExtra.text = ""
		--]]
		
		--local canTrain = ParadeGround.GetArmyMaxNum() - ParadeGround.GetTotalArmyNum() - GetTrainningArmyNum()
		local canTrain = ParadeGround.GetArmyMaxNum()
		canTrain = canTrain/BarrackState.TrainTotalNum >= 1 and 1 or canTrain/BarrackState.TrainTotalNum
		BarrackState.TrainSelNum = roundOff( BarrackState.TrainTotalNum * BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value,1)
		BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = canTrain
		
		--BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = 1
		BarrackUI.soldierNum.text = System.String.Format(TextMgr:GetText("army_max_ui1") , ParadeGround.GetTotalArmyNum() + GetTrainningArmyNum(), ParadeGround.GetArmyMaxNum())
		BarrackUI.soldierNum.gameObject:SetActive(true)
    else
    	--[[
        barrack_bonus =  AttributeBonus.CalBarrackBonus27(BarrackInfos[tab][grade])
	    if barrack_bonus == nil then
		    barrack_bonus = {}
		    barrack_bonus.Attack = BarrackInfos[tab][grade].Attack
		    barrack_bonus.Hp = BarrackInfos[tab][grade].Hp
		    barrack_bonus.Defend  = BarrackInfos[tab][grade].Defend
		    barrack_bonus.Penetration = BarrackInfos[tab][grade].Penetration 
	    end  
	    
        BarrackUI.DownInfo.Title.text = TextMgr:GetText("ui_barrack_title3")
        
        BarrackUI.SoldierAttributs.Root:SetActive(false)
        BarrackUI.SoldierAttributs2.Root:SetActive(true)        

	    BarrackUI.SoldierAttributs2.BattlePointNum.text = math.floor(BarrackInfos[tab][grade].fight*10+0.5)*0.1 --math.floor( AttributeBonus.CalBattlePoint(barrack_bonus,BarrackInfos[tab][grade].TeamCount)*10)*0.1
	    local fight = AttributeBonus.CalBattlePointSLGPVPArmyEx(BarrackInfos[tab][grade])
	    print(fight, BarrackInfos[tab][grade].fight)
	    BarrackUI.SoldierAttributs2.BattlePointExtra.text = (fight - BarrackInfos[tab][grade].fight ) == 0 and "" or  ("(+"..(math.floor((fight - BarrackInfos[tab][grade].fight)*10 +0.5))*0.1 ..")")

	    BarrackUI.SoldierAttributs2.BattleAttackNum.text = math.floor(BarrackInfos[tab][grade].Attack*10)*0.1
	    BarrackUI.SoldierAttributs2.BattleAttackExtra.text = (barrack_bonus.Attack - BarrackInfos[tab][grade].Attack ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Attack - BarrackInfos[tab][grade].Attack)*10+0.5))*0.1 ..")")
        
	    BarrackUI.SoldierAttributs2.BattleHpNum.text = math.floor(BarrackInfos[tab][grade].Hp*10)*0.1
	    BarrackUI.SoldierAttributs2.BattleHpExtra.text = (barrack_bonus.Hp - BarrackInfos[tab][grade].Hp ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Hp - BarrackInfos[tab][grade].Hp)*10+0.5))*0.1 ..")")        

	    BarrackUI.SoldierAttributs2.BattleDefendNum.text = math.floor(BarrackInfos[tab][grade].fakeArmo*10)*0.1
	    BarrackUI.SoldierAttributs2.BattleDefendExtra.text = (barrack_bonus.Defend ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Defend )*10+0.5))*0.1 ..")")

	    BarrackUI.SoldierAttributs2.BattlePentNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrain)--math.floor(BarrackInfos[tab][grade].Penetration*10)*0.1
	    BarrackUI.SoldierAttributs2.BattlePentNum.color = Color.green
	    BarrackUI.SoldierAttributs2.BattlePentExtra.text = ""--(barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration ) == 0 and "" or  ("(+"..(math.floor((barrack_bonus.Penetration - BarrackInfos[tab][grade].Penetration)*10+0.5))*0.1 ..")")        

    	BarrackUI.SoldierAttributs2.BattleAttackSpeedNum.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrained)--math.floor(BarrackInfos[tab][grade].AttackSpeed*10)*0.1
    	BarrackUI.SoldierAttributs2.BattleAttackSpeedNum.color = Color.red
	    BarrackUI.SoldierAttributs2.BattleAttackSpeedExtra.text = ""
	    BarrackUI.SoldierAttributs2.BattleArmyNumdNum.text = BarrackInfos[tab][grade].Num
	    BarrackUI.SoldierAttributs2.BattleArmyNumdExtra.text = ""	
	    
		--]]
		local wallBuilding = maincity.GetBuildingByID(26)--城墙
		local limitNum = wallBuilding == nil and 0 or TableMgr:GetWallData(wallBuilding.data.level).maxDefNumber
		limitNum = limitNum + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BaseDefenceMaxNum).value)

		--BarrackState.TrainSelNum = BarrackState.TrainTotalNum
		--label
		defMaxNum = limitNum
		--BarrackUI.SoldierAttributs2.DefendArmyNum.text = GetDefTotalNum() .. "/" .. limitNum
		--slider
		local canTrain = limitNum - GetDefTotalNum()
		defMaxNum = canTrain
		canTrain = canTrain/BarrackState.TrainTotalNum >= 1 and 1 or canTrain/BarrackState.TrainTotalNum
		BarrackState.TrainSelNum = roundOff( BarrackState.TrainTotalNum * BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value,1)
		BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = canTrain
		needFloatText = false
		
		BarrackUI.soldierNum.gameObject:SetActive(false)
	end
	
	for i = 1, 4 do
		BarrackUI.SoldierShow[i].Title.text = TextMgr:GetText(BarrackInfos[tab][i].SoldierName)
		BarrackUI.SoldierShow[i].armynum.text = BarrackInfos[tab][i].Num
		BarrackUI.SoldierShow[i].battlepoint.text = math.floor(BarrackInfos[tab][i].fight*10+0.5)*0.1
	end
    
	BarrackUI.DownInfo.AddSpeed.text = System.String.Format("{0:P1}", GetTrainSpeed(CurBuild.data.type))
	BarrackUI.DownInfo.pent.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrain)
	BarrackUI.DownInfo.disad.text = TextMgr:GetText(BarrackInfos[tab][grade].Restrained)

	--SetupSoldierMode(BarrackInfos[tab][grade].UnitID,BarrackInfos[tab][grade].SoldierId)
	
	SetupTrain(tab,grade)
	if BarrackState.LastTab ~= tab then
		local scale = 1
		if BarrackInfos[tab][grade].SoldierId == 1004 then
			scale = 0.45
		elseif BarrackInfos[tab][grade].SoldierId == 101 then
			scale = 0.4
		elseif BarrackInfos[tab][grade].SoldierId == 102 then
			scale = 0.7
		end
		showmodelcoroutine = coroutine.start(function()
			for i = 1, 4 do
				if BarrackUI == nil then
					return
				end
				if BarrackUI.SoldierShow[i].soldierModle ~= nil then
					GameObject.DestroyImmediate(BarrackUI.SoldierShow[i].soldierModle)
				end
				local unit_data = TableMgr:GetUnitData(BarrackInfos[tab][i].UnitID)
				BarrackUI.SoldierShow[i].soldierModle = ResourceLibrary:GetUnitInstance4UI(unit_data._unitPrefab)
				BarrackUI.SoldierShow[i].soldierModle.transform:SetParent(BarrackUI.SoldierShow[i].soldierRoot.transform, false)
				BarrackUI.SoldierShow[i].soldierModle.transform.localPosition = Vector3.zero
				BarrackUI.SoldierShow[i].soldierModle.transform.localRotation = Quaternion.identity
				BarrackUI.SoldierShow[i].soldierModle.transform.localScale = Vector3.one * scale
				NGUITools.SetChildLayer(BarrackUI.SoldierShow[i].soldierModle.transform, 29)
				BarrackUI.SoldierShow[i].soldierAnim = BarrackUI.SoldierShow[i].soldierModle:GetComponent("Animation")
				BarrackUI.SoldierShow[i].soldierMat = BarrackUI.SoldierShow[i].soldierModle:GetComponentsInChildren(typeof(UnityEngine.Renderer))
				OnSoldierRootClick(i)
				BarrackUI.SoldierShow[i].lock:SetActive(i > BarrackInfos[tab].MinGrade)
				if BarrackInfos[tab][grade].SoldierId == 1003 then
					local pivot = GameObject()
					pivot.transform:SetParent(BarrackUI.SoldierShow[i].soldierRoot.transform, false)
					BarrackUI.SoldierShow[i].soldierModle.transform:SetParent(pivot.transform, false)
					BarrackUI.SoldierShow[i].soldierModle.transform.localPosition = Vector3(0,0,-0.42)
					BarrackUI.SoldierShow[i].soldierModle = pivot
				end
				ChangeSoldierLight(i)
				coroutine.step()
			end
			if BarrackState ~= nil then
				BarrackState.LastTab = tab
			end
		end)
	else
		ChangeAllSoldierLight()
	end
	--ShowParadeGroundArmy()
end


local function UpdateTrainResult(msg,isbuy,callback)	
	--print("UpdateTrainResult ")
	if msg.code == 0 then
		--成功	
		if isbuy then
			--send data report-----------------------------------
			if BarrackState ~= nil then
				GUIMgr:SendDataReport("purchase", "costgold", "AccelArmyTrain::" ..BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].UnitID, "1", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
			end
				-----------------------------------------------------
			RefreshArmNum(msg)
			if BarrackUI ~= nil and BarrackState ~= nil then
				SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)
			end
		else
			local tab = msg.train.army.baseid
			local grade = msg.train.army.level
			BarrackInfosMap[tab][grade].TimeSec = msg.train.endtime
			--print(tab,grade,msg.train.originaltime)
            BarrackInfosMap[tab][grade].TotalTime = msg.train.originaltime
			BarrackInfosMap[tab][grade].Training = true;
			BarrackInfosMap[tab][grade].TmpTrainNum = msg.train.army.num															
			BarrackInfosMap[tab][grade].Training = true		
			if BarrackUI ~= nil then
				BarrackState.CurTrainingTab = BarrackInfosMap[tab][grade].SoldierTab
				BarrackState.CurTrainingGrade = BarrackInfosMap[tab][grade].Grade	
				BarrackState.Training = true	
				SetupTrain(BarrackState.CurTrainingTab,BarrackState.CurTrainingGrade)	
			end
		end
		MainCityUI.UpdateRewardData(msg.fresh)
	else
		Global.ShowError(msg.code)
		--print("UpdateTrainResult Error  "..msg.code)
		--失败
    end
	
	if callback ~= nil then
		callback(msg)
	end

end

local function RequestTrain(tab,grade,num,buy,callback)
	RequestState = {}
	RequestState.State = "RequestTrain"
	RequestState.Params = {}
	RequestState.Params.isBuy = buy
	RequestState.CallBack = callback
	local req = HeroMsg_pb.MsgArmyTrainRequest()
	req.buildUid = BarrackState.BarrackUID	
	req.armyId = tab;
	req.level = grade;
	req.num = num;
	req.buy = buy;		
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmyTrainRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgArmyTrainResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmyTrainRequest, req,HeroMsg_pb.MsgArmyTrainResponse,function(msg)	
		UpdateTrainResult(msg,buy,callback)
		
        --print(BarrackState.CurTab,BarrackState.CurGrade,BarrackInfosMap[BarrackState.CurTab][BarrackState.CurGrade].TotalTime)
		--MainData.UpdateData(msg.fresh.maindata)
		MainCityQueue.UpdateQueue()
		if not FunctionListData.IsUnlocked(144) then
			if tab == 1001 then
				Event.Resume(5)
			end
			Hide()
		end
	end, true)	
end

local function InitBarrackState(barrack_id,barrack_uid)
	BarrackState = {}
	BarrackState.BarrackID = barrack_id
	BarrackState.BarrackUID = barrack_uid
	BarrackState.TrainSelNum = 0
	BarrackState.CurTab = 1
	BarrackState.CurGrade = 1
	BarrackState.Training = false
	BarrackState.TrainEndTime = 0
	BarrackState.CurTrainingTab = 0
	BarrackState.CurTrainingGrade = 0	
	BarrackState.TrainTotalNum = 0
	BarrackState.BarrackLevel = 0
	BarrackState.ScienceInfos= {}		
	
	if BarrackBuildData == nil then
		BarrackBuildData = {}
		local barrack_build_table = TableMgr:GetBarrackBuildDataTable()
		for _ , v in pairs(barrack_build_table) do
			local data = v
			if BarrackBuildData[data.BuildID] == nil then
				BarrackBuildData[data.BuildID] = {}
			end
			if BarrackBuildData[data.BuildID][data.BuildLevel] == nil then 
				BarrackBuildData[data.BuildID][data.BuildLevel] = {}
			end
			BarrackBuildData[data.BuildID][data.BuildLevel] = data
		end
		
		--[[local iter = barrack_build_table:GetEnumerator()
		while iter:MoveNext() do
			local data = iter.Current.Value
			if BarrackBuildData[data.BuildID] == nil then
				BarrackBuildData[data.BuildID] = {}
			end
			if BarrackBuildData[data.BuildID][data.BuildLevel] == nil then 
				BarrackBuildData[data.BuildID][data.BuildLevel] = {}
			end
			BarrackBuildData[data.BuildID][data.BuildLevel] = data
		end]]
	end
end

function RequestBarrackInfo()
    InitCfgInfo()
	RequestArmNum()  
    RequestTrainInfo(0,UpdateTrainInfo)
end

function EnterBarrack()
	isDestroy = false
	CurBuild = maincity.GetCurrentBuildingData()
	InitBarrackState(CurBuild.data.type,CurBuild.data.uid)
	BarrackState.BarrackLevel = CurBuild.data.level
    AttributeBonus.CollectBonusInfo(nil, 1)
    local bonus = AttributeBonus.GetBonusInfos()
	local basebonus = bonus[1099] ~= nil and bonus[1099] or 0
	BarrackState.TrainTotalNum = BarrackBuildData[BarrackState.BarrackID][BarrackState.BarrackLevel].MaxNum * (1 + basebonus * 0.01) + (bonus[1091] ~= nil and bonus[1091] or 0)
	if  BarrackBuildData[BarrackState.BarrackID][BarrackState.BarrackLevel].BuildID ~= 27 then
        BarrackState.TrainTotalNum = BarrackState.TrainTotalNum +  ResView.GetTotalYield(5)
    end
	InitCfgInfo()
	-- net work	
	RequestTrainInfo(BarrackState.BarrackUID,function(msg)
		if isDestroy then
			return
		end
		UpdateTrainInfo(msg)
		BarrackUI = nil
		GUIMgr:CreateMenu("Barrack",false)			
	end)
	--RequestArmNum(function(msg)
	--	if msg.code == 0 then
	--		BarrackUI = nil
	--		GUIMgr:CreateMenu("Barrack",false)			
	--	end
    --end)
end

function GetTrainNum(buildid)
	local build = maincity.GetBuildingByID(buildid)
	if build == nil then
		print("there is no barrack building. id :" .. buildid)
		return 0
	end
	
	--print("id:" .. buildid .. " level " .. build.data.level .. " uid:" .. build.data.uid)
	InitBarrackState(buildid , build.data.uid)
	AttributeBonus.CollectBonusInfo(nil, 1)
	local bonus = AttributeBonus.GetBonusInfos()
	local basebonus = bonus[1099] ~= nil and bonus[1099] or 0
	local barracknum = BarrackBuildData[buildid][build.data.level].MaxNum * (1 + basebonus * 0.01)
	if  buildid ~= 27 then
        barracknum = barracknum +  ResView.GetTotalYield(5)
    end
    local add = bonus[1091]
	return barracknum + (add ~= nil and add or 0)
end


local function InitSoldier3DArea()
	if BarrackUI == nil then
		return
	end
	BarrackUI.Soldier3DArea = {}
	BarrackUI.Soldier3DArea.RootObj = ResourceLibrary.GetUIInstance("Barrack/Barrack3DAreaCam")

	BarrackUI.Soldier3DArea.Viewport = BarrackUI.Soldier3DArea.RootObj:GetComponent("UIViewport")
	--BarrackUI.Soldier3DArea.S3DNode = BarrackUI.Soldier3DArea.RootObj.transform:Find("Node")
	BarrackUI.Soldier3DArea.Viewport.sourceCamera = BarrackUI.UICamera
	BarrackUI.Soldier3DArea.Viewport.topLeft = BarrackUI.SoldierShow.ShowTLNode
	BarrackUI.Soldier3DArea.Viewport.bottomRight = BarrackUI.SoldierShow.ShowBRNode
	for i=1,8,1 do
		BarrackUI.Soldier3DArea[i] = BarrackUI.Soldier3DArea.RootObj.transform:Find(i)
    end
    for i = 1001, 1004, 1 do
    	BarrackUI.Soldier3DArea[i] = BarrackUI.Soldier3DArea.RootObj.transform:Find(i)
    end
    BarrackUI.Soldier3DArea[101] = BarrackUI.Soldier3DArea.RootObj.transform:Find(101)
    BarrackUI.Soldier3DArea[102] = BarrackUI.Soldier3DArea.RootObj.transform:Find(102)
end	

local function InputTextClickCallback(go)
	NumberInput.Show(math.floor(BarrackState.TrainSelNum), 0, BarrackState.TrainTotalNum, function(number)
        BarrackState.TrainSelNum = number
        BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = number/BarrackState.TrainTotalNum
		needFloatText = true
    end)
end

local function OnClickCloseBtn()
    Hide()
	--GUIMgr:CloseMenu("Barrack")
	--ShowParadeGroundArmy()
end

local function GetResource(id)
	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
	local noitem = Global.BagIsNoItem(maincity.GetItemResList(id))
	if noitem then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("player_ui18"), Color.white)
		return
	end
	CommonItemBag.SetTittle(TextMgr:GetText("get_resource" .. (tonumber(id) - 2)))
	CommonItemBag.NotUseAutoClose()
	CommonItemBag.SetResType(id)
	CommonItemBag.SetItemList(maincity.GetItemResList(id), 0)
	CommonItemBag.SetUseFunc(maincity.UseResItemFunc)
	GUIMgr:CreateMenu("CommonItemBag" , false)
	--[[
	CommonItemBag.OnOpenCB = function() 
        BarrackUI.Soldier3DArea.RootObj:SetActive(false) 
    end
    CommonItemBag.OnCloseCB = function() 
        BarrackUI.Soldier3DArea.RootObj:SetActive(true) 
  	    if not BarrackUI.Soldier3DArea.ShowObj.Anim:IsPlaying("idle") then
	        BarrackUI.Soldier3DArea.ShowObj.Anim:Play("idle")
        end              
    end
    --]]
end

local function InitBarrackUI()

	BarrackUI = {}
	BarrackUI.UICamera = GUIMgr.UIRoot.transform:Find("Camera"):GetComponent("Camera")
	
	BarrackUI.CloseBtn = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(transform:Find("Container").gameObject,OnClickCloseBtn)
	BarrackUI.SoldierTitle = {}
	BarrackUI.SoldierTitle.LeftBtn = transform:Find("Container/bg_frane/btn_tab_1"):GetComponent("UIButton")
	local toggle = transform:Find("Container/bg_frane/btn_tab_1"):GetComponent("UIToggle")
    if not BarrackInfos[1].Unlock then
        toggle:Set(false)
        toggle.enabled = false
    else
        toggle.enabled = true
    end


	BarrackUI.SoldierTitle.LeftBtnTxt = transform:Find("Container/bg_frane/btn_tab_1/Animation/btn_tab_down_1/tab_title_down1"):GetComponent("UILabel")
	BarrackUI.SoldierTitle.LeftBtnTxt2 = transform:Find("Container/bg_frane/btn_tab_1/tab_title1"):GetComponent("UILabel")
	BarrackUI.SoldierTitle.RightBtn = transform:Find("Container/bg_frane/btn_tab_2"):GetComponent("UIButton")
	toggle = transform:Find("Container/bg_frane/btn_tab_2"):GetComponent("UIToggle")
	unlock = transform:Find("Container/bg_frane/btn_tab_2/icon_lock").gameObject
    if BarrackInfos[2] == nil or not BarrackInfos[2].Unlock then
        toggle:Set(false)
        toggle.enabled = false
        unlock:SetActive(true)
    else
        toggle.enabled = true
        unlock:SetActive(false)
    end

	BarrackUI.Soldier3D = transform:Find("Container/bg_frane")

	BarrackUI.SoldierTitle.RightBtnTxt = transform:Find("Container/bg_frane/btn_tab_2/Animation/btn_tab_down_2/tab_title_down2"):GetComponent("UILabel")
	BarrackUI.SoldierTitle.RightBtnTxt2 = transform:Find("Container/bg_frane/btn_tab_2/tab_title2"):GetComponent("UILabel")

	BarrackUI.AttributsRoot = transform:Find("soldier_tips").gameObject
	SetClickCallback(BarrackUI.AttributsRoot, function() BarrackUI.AttributsRoot:SetActive(false) end)
	
	BarrackUI.SoldierAttributs = {}
	BarrackUI.SoldierAttributs.Title = transform:Find("soldier_tips/bg_title/bg_title_text"):GetComponent("UILabel")

    BarrackUI.SoldierAttributs.Root = transform:Find("soldier_tips/bg_attributs").gameObject
    
    BarrackUI.SoldierAttributs.BattlePoint = transform:Find("soldier_tips/bg_attributs/attributs (1)/battlepoint"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattlePointNum = transform:Find("soldier_tips/bg_attributs/attributs (1)/battlepoint/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattlePointExtra = transform:Find("soldier_tips/bg_attributs/attributs (1)/battlepoint/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleFood = transform:Find("soldier_tips/bg_attributs/attributs (1)/food"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleFoodNum = transform:Find("soldier_tips/bg_attributs/attributs (1)/food/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleFoodExtra = transform:Find("soldier_tips/bg_attributs/attributs (1)/food/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleAttack = transform:Find("soldier_tips/bg_attributs/attributs (2)/attack"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleAttackNum = transform:Find("soldier_tips/bg_attributs/attributs (2)/attack/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleAttackExtra = transform:Find("soldier_tips/bg_attributs/attributs (2)/attack/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleWeight = transform:Find("soldier_tips/bg_attributs/attributs (2)/weight"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleWeightNum = transform:Find("soldier_tips/bg_attributs/attributs (2)/weight/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleWeightExtra = transform:Find("soldier_tips/bg_attributs/attributs (2)/weight/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleHp = transform:Find("soldier_tips/bg_attributs/attributs (3)/hp"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleHpNum = transform:Find("soldier_tips/bg_attributs/attributs (3)/hp/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleHpExtra = transform:Find("soldier_tips/bg_attributs/attributs (3)/hp/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleSoldiernum = transform:Find("soldier_tips/bg_attributs/attributs (3)/soldiernum"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleSoldiernuNum = transform:Find("soldier_tips/bg_attributs/attributs (3)/soldiernum/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleSoldiernuExtra = transform:Find("soldier_tips/bg_attributs/attributs (3)/soldiernum/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleDefend = transform:Find("soldier_tips/bg_attributs/attributs (4)/defend"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleDefendNum = transform:Find("soldier_tips/bg_attributs/attributs (4)/defend/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleDefendExtra = transform:Find("soldier_tips/bg_attributs/attributs (4)/defend/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattlePent = transform:Find("soldier_tips/bg_attributs/attributs (5)/pent"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattlePentNum = transform:Find("soldier_tips/bg_attributs/attributs (5)/pent/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattlePentExtra = transform:Find("soldier_tips/bg_attributs/attributs (5)/pent/text_num_green"):GetComponent("UILabel")
	
	BarrackUI.SoldierAttributs.BattleDisad = transform:Find("soldier_tips/bg_attributs/attributs (5)/disad"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleDisadNum = transform:Find("soldier_tips/bg_attributs/attributs (5)/disad/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleDisadExtra = transform:Find("soldier_tips/bg_attributs/attributs (5)/disad/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleAttackSpeed = transform:Find("soldier_tips/bg_attributs/attributs (4)/attackspeed"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleAttackSpeedNum = transform:Find("soldier_tips/bg_attributs/attributs (4)/attackspeed/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleAttackSpeedExtra = transform:Find("soldier_tips/bg_attributs/attributs (4)/attackspeed/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs.BattleArmyNumd = transform:Find("soldier_tips/bg_attributs/attributs (5)/armynum"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleArmyNumdNum = transform:Find("soldier_tips/bg_attributs/attributs (5)/armynum/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs.BattleArmyNumdExtra = transform:Find("soldier_tips/bg_attributs/attributs (5)/armynum/text_num_green"):GetComponent("UILabel")

    BarrackUI.SoldierAttributs2 = {}
	BarrackUI.SoldierAttributs2.Root = transform:Find("soldier_tips/bg_attributs (1)").gameObject

    BarrackUI.SoldierAttributs2.BattlePoint = transform:Find("soldier_tips/bg_attributs (1)/attributs (1)/battlepoint"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattlePointNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (1)/battlepoint/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattlePointExtra = transform:Find("soldier_tips/bg_attributs (1)/attributs (1)/battlepoint/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs2.BattleAttack = transform:Find("soldier_tips/bg_attributs (1)/attributs (2)/attack"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleAttackNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (2)/attack/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleAttackExtra = transform:Find("soldier_tips/bg_attributs (1)/attributs (2)/attack/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs2.BattleHp = transform:Find("soldier_tips/bg_attributs (1)/attributs (3)/hp"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleHpNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (3)/hp/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleHpExtra = transform:Find("soldier_tips/bg_attributs (1)/attributs (3)/hp/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs2.BattleDefend = transform:Find("soldier_tips/bg_attributs (1)/attributs (4)/defend"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleDefendNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (4)/defend/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleDefendExtra = transform:Find("soldier_tips/bg_attributs (1)/attributs (4)/defend/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs2.BattlePent = transform:Find("soldier_tips/bg_attributs (1)/attributs (5)/pent"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattlePentNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (5)/pent/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattlePentExtra = transform:Find("soldier_tips/bg_attributs (1)/attributs (5)/pent/text_num_green"):GetComponent("UILabel")

	BarrackUI.SoldierAttributs2.BattleAttackSpeed = transform:Find("soldier_tips/bg_attributs (1)/attributs (4)/attackspeed"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleAttackSpeedNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (4)/attackspeed/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleAttackSpeedExtra = transform:Find("soldier_tips/bg_attributs (1)/attributs (4)/attackspeed/text_num_green"):GetComponent("UILabel")

--[[
	BarrackUI.SoldierAttributs2.BattleArmyNumd = transform:Find("soldier_tips/bg_attributs (1)/attributs (5)/armynum"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleArmyNumdNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (5)/armynum/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierAttributs2.BattleArmyNumdExtra = transform:Find("soldier_tips/bg_attributs (1)/attributs (5)/armynum/text_num_green"):GetComponent("UILabel")
--]]	
	BarrackUI.SoldierAttributs2.DefendArmyNum = transform:Find("soldier_tips/bg_attributs (1)/attributs (6)/hp/text_num"):GetComponent("UILabel")

	BarrackUI.SoldierTrain = {}
	BarrackUI.SoldierTrain.Schedule = {}
	BarrackUI.SoldierTrain.Schedule.Root = transform:Find("Container/bg_frane/bg_bottom/bg_train").gameObject

	BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	
	transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/bg_schedule/text_num").gameObject:SetActive(false)
    local inputText = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/frame_input")
    inputText.gameObject:SetActive(true)
    SetClickCallback(inputText.gameObject , InputTextClickCallback)
    BarrackUI.SoldierTrain.Schedule.TrainScheduleText = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/frame_input/title"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Schedule.TrainScheduleText_Denom = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/frame_input/text_num"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Schedule.TrainAddBtn = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/btn_add"):GetComponent("UIButton")
	BarrackUI.SoldierTrain.Schedule.TrainDelBtn = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/btn_minus"):GetComponent("UIButton")
	BarrackUI.SoldierTrain.Schedule.TrainTime = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_train_time/icon_time/txt_time"):GetComponent("UILabel")

	BarrackUI.SoldierTrain.Schedule.ResFood = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_food/txt_food"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Schedule.ResIron = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_iron/txt_iron"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Schedule.ResOil = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_oil/txt_oil"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Schedule.ResElectric = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_electric/txt_electric"):GetComponent("UILabel")
	
	BarrackUI.SoldierTrain.Schedule.ResFoodGet = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_food/get btn").gameObject
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.ResFoodGet, function() GetResource(3) end)
	BarrackUI.SoldierTrain.Schedule.ResIronGet = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_iron/get btn").gameObject
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.ResIronGet, function() GetResource(4) end)
	BarrackUI.SoldierTrain.Schedule.ResOilGet = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_oil/get btn").gameObject
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.ResOilGet, function() GetResource(5) end)
	BarrackUI.SoldierTrain.Schedule.ResElectricGet = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_electric/get btn").gameObject
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.ResElectricGet, function() GetResource(6) end)

	BarrackUI.SoldierTrain.Schedule.UogradeGoldBtn = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_upgrade_gold"):GetComponent("UIButton")
	BarrackUI.SoldierTrain.Schedule.UogradeGoldBtnTxt = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_upgrade_gold/text"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Schedule.UogradeGoldBtnNum = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_upgrade_gold/num"):GetComponent("UILabel")

	BarrackUI.SoldierTrain.Schedule.UogradeBtn = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_upgrade"):GetComponent("UIButton")
	BarrackUI.SoldierTrain.Schedule.UogradeBtnTxt = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_upgrade/text"):GetComponent("UILabel")

	BarrackUI.SoldierTrain.Training = {}
	BarrackUI.SoldierTrain.Training.Root = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing").gameObject

	BarrackUI.SoldierTrain.Training.SpeedUpBtn = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/btn_speedup"):GetComponent("UIButton")
	BarrackUI.SoldierTrain.Training.SpeedUpCancelBtn = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/btn_delete"):GetComponent("UIButton")
	BarrackUI.SoldierTrain.Training.Time = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/bg_time/txt_time"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Training.TimeSlider = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/bg_time"):GetComponent("UISlider")
	BarrackUI.SoldierTrain.Training.Describe = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/txt_describe"):GetComponent("UILabel")

	BarrackUI.SoldierTrain.Training.UogradeGoldBtn = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/btn_upgrade_gold"):GetComponent("UIButton")
	BarrackUI.SoldierTrain.Training.UogradeGoldBtnTxt = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/btn_upgrade_gold/text"):GetComponent("UILabel")
	BarrackUI.SoldierTrain.Training.UogradeGoldBtnNum = transform:Find("Container/bg_frane/bg_bottom/bg_train_doing/btn_upgrade_gold/num"):GetComponent("UILabel")
--[[
	BarrackUI.SoldierShow = {}
	BarrackUI.SoldierShow.Title = transform:Find("Container/bg_frane/bg_right/bg_right_title/bg_right_text"):GetComponent("UILabel")
	BarrackUI.SoldierShow.DeleteBtn = transform:Find("Container/bg_frane/bg_right/btn_delete"):GetComponent("UIButton")
	BarrackUI.SoldierShow.DeleteBtn.gameObject:SetActive(false)
	FunctionListData.IsFunctionUnlocked(113, function(isactive)
	    BarrackUI.SoldierShow.DeleteBtn.gameObject:SetActive(isactive)
	end)

	BarrackUI.SoldierShow[1] = {}
	BarrackUI.SoldierShow[1].LvBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv1"):GetComponent("UIButton")
	BarrackUI.SoldierShow[1].LvBtnToggle = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv1"):GetComponent("UIToggle")
	BarrackUI.SoldierShow[1].LvDisableBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv1_hui"):GetComponent("UIButton")
	BarrackUI.SoldierShow[2] = {}
	BarrackUI.SoldierShow[2].LvBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv2"):GetComponent("UIButton")
	BarrackUI.SoldierShow[2].LvBtnToggle = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv2"):GetComponent("UIToggle")
	BarrackUI.SoldierShow[2].LvDisableBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv2_hui"):GetComponent("UIButton")
	BarrackUI.SoldierShow[3] = {}
	BarrackUI.SoldierShow[3].LvBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv3"):GetComponent("UIButton")
	BarrackUI.SoldierShow[3].LvBtnToggle = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv3"):GetComponent("UIToggle")
	BarrackUI.SoldierShow[3].LvDisableBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv3_hui"):GetComponent("UIButton")
	BarrackUI.SoldierShow[4] = {}
	BarrackUI.SoldierShow[4].LvBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv4"):GetComponent("UIButton")
	BarrackUI.SoldierShow[4].LvBtnToggle = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv4"):GetComponent("UIToggle")
	BarrackUI.SoldierShow[4].LvDisableBtn = transform:Find("Container/bg_frane/bg_right/bg_bottom/btn_lv4_hui"):GetComponent("UIButton")

	BarrackUI.SoldierShow.ShowNode = transform:Find("Container/bg_frane/bg_right/3Darea")
	BarrackUI.SoldierShow.ShowTLNode = transform:Find("Container/bg_frane/bg_right/3Darea/topleft")
	BarrackUI.SoldierShow.ShowBRNode = transform:Find("Container/bg_frane/bg_right/3Darea/bottomright")

	InitSoldier3DArea()
	--]]
	
	BarrackUI.SoldierShow = {}
	for i = 1, 4 do
		BarrackUI.SoldierShow[i] = {}
		BarrackUI.SoldierShow[i].Title = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/bg_right_title/bg_right_text", i)):GetComponent("UILabel")
		BarrackUI.SoldierShow[i].armynum = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/armynum/text_num", i)):GetComponent("UILabel")
		BarrackUI.SoldierShow[i].btn_tips = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/tips", i)).gameObject
		BarrackUI.SoldierShow[i].selected = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/selected", i)).gameObject
		BarrackUI.SoldierShow[i].btn_delete = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/selected/btn_delete", i)).gameObject
		BarrackUI.SoldierShow[i].btn_delete:SetActive(false)
		BarrackUI.SoldierShow[i].battlepoint = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/battlepoint/text_num", i)):GetComponent("UILabel")
		BarrackUI.SoldierShow[i].chassis = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/chassis", i)).gameObject
		BarrackUI.SoldierShow[i].lock = transform:Find(string.format("Container/bg_frane/Container/bg_right_%d/lock", i)).gameObject
		BarrackUI.SoldierShow[i].soldierRoot = transform:Find(string.format("Container/bg_frane/Container/Soldiers/Camera/Povit/%d", i)).gameObject
	end
	
	FunctionListData.IsFunctionUnlocked(113, function(isactive)
		for i = 1, 4 do
			if BarrackUI ~= nil then
				BarrackUI.SoldierShow[i].btn_delete:SetActive(isactive)
			end
	    end
	end)
	
	BarrackUI.DownInfo = {}
	BarrackUI.DownInfo.Title = transform:Find("Container/bg_frane/down/bg_right_title/bg_right_text"):GetComponent("UILabel")
	BarrackUI.DownInfo.AddSpeed = transform:Find("Container/bg_frane/down/soldiernum/text_num"):GetComponent("UILabel")
	BarrackUI.DownInfo.pent = transform:Find("Container/bg_frane/down/pent/text_num"):GetComponent("UILabel")
	BarrackUI.DownInfo.disad = transform:Find("Container/bg_frane/down/disad/text_num"):GetComponent("UILabel")
	
	BarrackUI.soldierNum = transform:Find("Container/bg_frane/Container/text_num"):GetComponent("UILabel")
end
local OnClickSoldierShow
SetupSoldierMode = function(teable_id,type_id)
	if BarrackUI == nil then
		return
	end	
	local unit_data = TableMgr:GetUnitData(teable_id)
	if BarrackUI.Soldier3DArea.ShowObj ~= nil then
		GameObject.Destroy(BarrackUI.Soldier3DArea.ShowObj)
		BarrackUI.Soldier3DArea.ShowObj = nil
	end
	BarrackUI.Soldier3DArea.ShowObj = ResourceLibrary:GetUnitInstance4UI(unit_data._unitPrefab)
	BarrackUI.Soldier3DArea.ShowObj.transform.parent = 	BarrackUI.Soldier3DArea[type_id]--BarrackUI.Soldier3DArea.S3DNode
	BarrackUI.Soldier3DArea.ShowObj.transform.localPosition = Vector3.zero
	BarrackUI.Soldier3DArea.ShowObj.transform.localRotation = Quaternion.identity
	NGUITools.SetChildLayer(BarrackUI.Soldier3DArea.ShowObj.transform,BarrackUI.Soldier3DArea.RootObj.layer)
	BarrackUI.Soldier3DArea.ShowObj.Anim = BarrackUI.Soldier3DArea.ShowObj:GetComponent("Animation")
    OnClickSoldierShow()
	
end

local function SetupGradeList(tab)
	if BarrackUI == nil then
		return
	end	
	for i=1,4,1 do
		--print(BarrackInfos[tab].MinGrade)
		if i > BarrackInfos[tab].MinGrade then
			BarrackUI.SoldierShow[i].LvBtn.gameObject:SetActive(false)
			BarrackUI.SoldierShow[i].LvDisableBtn.gameObject:SetActive(true)
		else
			BarrackUI.SoldierShow[i].LvBtn.gameObject:SetActive(true)
			BarrackUI.SoldierShow[i].LvDisableBtn.gameObject:SetActive(false)	
		end
		BarrackUI.SoldierShow[i].LvBtnToggle:Set(false)
	end
	BarrackUI.SoldierShow[BarrackInfos[tab].MinGrade].LvBtnToggle:Set(true)
end

local function SetupTab(tab)
	if BarrackUI == nil then
		return
	end
	if BarrackInfos[tab][BarrackInfos[tab].MinGrade].Training then 
		if BarrackInfos[tab][BarrackInfos[tab].MinGrade].TimeSec - GameTime.GetSecTime() > 0 then
			SetupSoldierAttributes(tab,BarrackInfos[tab].MinGrade)
			BarrackUI.SoldierShow[BarrackInfos[tab].MinGrade].chassis:GetComponent("UIToggle"):Set(true)
		else
			--RequestArmNum(function(msg) 
			--	if msg.code == 0 then
			--		ClearTraningTag()
			--		SetupSoldierAttributes(tab,BarrackInfos[tab].MinGrade)	
					BarrackUI.SoldierShow[BarrackInfos[tab].MinGrade].chassis:GetComponent("UIToggle"):Set(true)	
			--	end
			--end)
		end
	else
		SetupSoldierAttributes(tab,BarrackInfos[tab].MinGrade)
		BarrackUI.SoldierShow[BarrackInfos[tab].MinGrade].chassis:GetComponent("UIToggle"):Set(true)
	end
end

local function OnClickSoldierAttTitleLeftBtn()
	if BarrackUI == nil then
		return
	end	
	BarrackState.CurTab = 1
	if BarrackInfos[BarrackState.CurTab].Unlock then
	    SetupTab(BarrackState.CurTab)
	else
	   	if BarrackInfos[BarrackState.CurTab][1].BattleId ~= 0 then
	        local des = String.Format(TextMgr:GetText("common_ui15"),TextMgr:GetText(TableMgr:GetBattleData(BarrackInfos[BarrackState.CurTab][1].BattleId).nameLabel))
	        FloatText.ShowOn(BarrackUI.SoldierTitle.LeftBtn,des,Color.white) 
		    AudioMgr:PlayUISfx("SFX_ui02", 1, false)
	   	end
   end
end

local function OnClickSoldierAttTitleRightBtn()
	if BarrackUI == nil then
		return
	end	
	if BarrackInfos[2].Unlock then
	    BarrackState.CurTab = 2
	    SetupTab(BarrackState.CurTab)
	else
	    if BarrackInfos[2][1].BattleId ~= 0 then
		    local des = String.Format(TextMgr:GetText("common_ui15"),TextMgr:GetText(TableMgr:GetBattleData(BarrackInfos[2][1].BattleId).nameLabel))
		    FloatText.ShowOn(BarrackUI.SoldierTitle.RightBtn,des,Color.white)
			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
	    end
    end
end

local function OnClickSoldierShowTab(obj)
	local grade = tonumber( string.split(obj.name,"btn_lv")[2])
	local tab = BarrackState.CurTab
	if BarrackInfos[tab][grade].Training then 
		if BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime() > 0 then
			SetupSoldierAttributes(tab,grade)
		else
			--[[
			RequestArmNum(function(msg) 
				if msg.code == 0 then
					ClearTraningTag()
					SetupSoldierAttributes(tab,grade)		
				end
			end)
			--]]
		end
	else
		SetupSoldierAttributes(tab,grade)
	end		
end

roundOff = function(num, n)
    if n > 0 then
    	local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
    	local scale = math.pow(10, n)
    	return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end 

local function OnSliderChange()
	if BarrackUI == nil then
		return
	end	
	if  BarrackBuildData[BarrackState.BarrackID][BarrackState.BarrackLevel].BuildID ~= 27 then
		BarrackState.TrainSelNum = roundOff( BarrackState.TrainTotalNum * BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value,1)
	else
		local train = roundOff( BarrackState.TrainTotalNum * BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value,1)
		if train >= defMaxNum then
			BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = defMaxNum / BarrackState.TrainTotalNum
			if needFloatText then
				FloatText.Show(TextMgr:GetText("ui_barrack_chengfang3"))
				needFloatText = false
			end
		else
			needFloatText = true
		end
		--print(roundOff( BarrackState.TrainTotalNum * BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value,1))
		
		BarrackState.TrainSelNum = roundOff( BarrackState.TrainTotalNum * BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value,1)
	end
	
	SetupTrain(BarrackState.CurTab,BarrackState.CurGrade)
end

local function OnClickTrainAddBtn()
	if BarrackUI == nil then
		return
	end	
	BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = math.min( BarrackState.TrainSelNum + 1,BarrackState.TrainTotalNum)/BarrackState.TrainTotalNum
	needFloatText = true
end

local function OnClickTrainDelBtn()
	if BarrackUI == nil then
		return
	end	
	BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = math.max( BarrackState.TrainSelNum - 1,0)/BarrackState.TrainTotalNum
end

local function OnHoldClickTrainAddBtn(go)
	OnClickTrainAddBtn()
end

local function OnHoldClickTrainDelBtn(go)
	OnClickTrainDelBtn()
end

ClearTraningTag = function()
	if BarrackState == nil then
		return
	end
	if BarrackState.CurTrainingTab == 0 or BarrackState.CurTrainingGrade == 0 then
		return
	end
	BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TimeSec = 0
	BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TmpTrainNum = 0
	BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].Training = false
	BarrackState.Training = false
	BarrackState.CurTrainingTab = 0
	BarrackState.CurTrainingGrade = 0
end

local function ShowAccUI()      
    CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
    CommonItemBag.NotUseAutoClose()
    CommonItemBag.NotUseFreeFinish()
    CommonItemBag.SetItemList(maincity.GetItemExchangeList(47), 4)
	CommonItemBag.NeedItemMaxValue(true)
	local finish = function()
		RequestAccelArmyTrain(function(msg)
			if msg.code == 0 then
				if BarrackState ~= nil then
					SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)
					--FloatText.Show(TextMgr:GetText(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierName).."  LV."..BarrackState.CurGrade.."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
					MainCityQueue.UpdateQueue()
					BuildingShowInfoUI.MakeTransition(CurBuild)
					AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
				end
			else
				Global.FloatError(msg.code, Color.white)
			end
		end)
		CommonItemBag.SetInitFunc(nil)
		GUIMgr:CloseMenu("CommonItemBag")
    end

    local cancel = function()
		MessageBox.Show(TextMgr:GetText("ui_barrack_warning3"),
		function()
			RequestCancelArmyTrain(function(msg)
				if msg.code == 0 then
					if BarrackState ~= nil then
						SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)
						BuildingShowInfoUI.MakeTransition(CurBuild)
						MainCityQueue.UpdateQueue()
					end
                end
			end)
			CommonItemBag.SetInitFunc(nil)
			GUIMgr:CloseMenu("CommonItemBag")
        end,
		function()
		end,
		TextMgr:GetText("common_hint1"),
		TextMgr:GetText("common_hint2"))
    end

    CommonItemBag.SetInitFunc(function()
    	local _text = "[" .. TextMgr:GetText(BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].SoldierName) .. "] x" .. math.floor(BarrackState.TrainSelNum .. " ")
    	local _time = BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TimeSec
    	local _totalTime = BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TotalTime -- math.floor(BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TmpTrainNum*
    	--BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TrainTime*
    	--BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TeamCount)
    	--[[
    	print("TrainSelNum",BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TmpTrainNum,"TrainTime",BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TrainTime,
    	"TeamCount",BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TeamCount,"_totalTime",
    	_totalTime,"time ",BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TimeSec - GameTime.GetSecTime())
    	--]]
		--_totalTime = GetTrainTime(_totalTime,BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].SoldierId)
    	return _text, _time, _totalTime, finish, cancel, finish, 2
    end)
			--使用加速道具 減時間
	CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
	    print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	    local itemTBData = TableMgr:GetItemData(useItemId)
	    local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	    local req = ItemMsg_pb.MsgUseItemSubTimeRequest()
	    if itemdata ~= nil then
	        req.uid = itemdata.uniqueid
	    else
	        req.exchangeId = exItemid
	    end
	    req.num = count
	    req.buildId = CurBuild.data.uid
	    req.subTimeType = 3
	    Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
	        print("use item code:" .. msg.code)
			if msg.code == 0 then
				if isDestroy then
					return
				end
				local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
				if price == 0 then
					GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
				else
					GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
				end
	            useItemReward = msg.reward
	            AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
				local nameColor = Global.GetLabelColorNew(itemTBData.quality)
				local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
				FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
	            --執行減時間
                if msg.armyTrain ~= nil  and msg.armyTrain.buildUid ~= 0 then
                    BarrackInfosMap[msg.armyTrain.army.baseid][msg.armyTrain.army.level].TimeSec = msg.armyTrain.endtime
                    BarrackInfosMap[msg.armyTrain.army.baseid][msg.armyTrain.army.level].TotalTime = msg.armyTrain.originaltime
                    --BarrackInfosMap[msg.armyTrain.army.baseid][msg.armyTrain.army.level].Num = msg.armyTrain.army.num
                    --RefrushSetout4ArmyNum(msg.armyTrain.army)
                    CountDown.Instance:Remove("BarrackTraining")
					CountDown.Instance:Add("BarrackTraining",BarrackInfosMap[msg.armyTrain.army.baseid][msg.armyTrain.army.level].TimeSec,CountDown.CountDownCallBack(function(t)
						if BarrackUI == nil then
							CountDown.Instance:Remove("BarrackTraining")
							return
						end
						if BarrackUI ~= nil then
							BarrackUI.SoldierTrain.Training.Time.text  = t
						end
	                    if BarrackInfosMap[msg.armyTrain.army.baseid][msg.armyTrain.army.level].TimeSec+1 - GameTime.GetSecTime() <= 0 then
	                        RefreshArmNum(msg)
		                    --[[
		                    --RequestArmNum(function(msg) 
				                if msg.code == 0 then
					            ClearTraningTag()
					            SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)		
                                end
			                end)
			                --]]
		                CountDown.Instance:Remove("BarrackTraining")
	                    end			
	                end))
                else
                    FloatText.Show(TextMgr:GetText(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierName).."  LV."..BarrackState.CurGrade.."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
	                RefreshArmNum(msg)
	                --[[
	                for i = 1,#(msg.fresh.arms) do
	                    if BarrackInfosMap[msg.fresh.arms[i].baseid] ~= nil and BarrackInfosMap[msg.fresh.arms[i].baseid][msg.fresh.arms[i].level] ~= nil then
		                    BarrackInfosMap[msg.fresh.arms[i].baseid][msg.fresh.arms[i].level].Num = msg.fresh.arms[i].num
		                    RefrushSetout4ArmyNum(msg.fresh.arms[i])
                        end
                    end
                    ]]--
	                maincity.RemoveBuildCountDown(CurBuild)
                    ClearTraningTag()
	                SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)
			        CommonItemBag.SetInitFunc(nil)
	            	GUIMgr:CloseMenu("CommonItemBag") 
	            	MainCityQueue.UpdateQueue()
					AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
                end
	            MainCityUI.UpdateRewardData(msg.fresh)
	            CommonItemBag.UpdateTopProgress()
	            SetupTab(BarrackState.CurTab, BarrackState.CurGrade)
            else
                Global.FloatError(msg.code, Color.white)
            end
        end, true)
	end)
	--[[
	CommonItemBag.OnOpenCB = function() 
        BarrackUI.Soldier3DArea.RootObj:SetActive(false) 
    end
    CommonItemBag.OnCloseCB = function() 
        BarrackUI.Soldier3DArea.RootObj:SetActive(true) 
  	    if not BarrackUI.Soldier3DArea.ShowObj.Anim:IsPlaying("idle") then
	        BarrackUI.Soldier3DArea.ShowObj.Anim:Play("idle")
        end              
    end
	--]]
	CommonItemBag.SetMsgText("purchase_confirmation3", "s_today")
	local obj = GUIMgr:CreateMenu("CommonItemBag" , false)
	--NGUITools.SetLayer(obj.gameObject,obj.gameObject.layer)
end

local function CheckBarrackTrain()
	--print(BarrackState.CurTrainingTab,BarrackState.CurTrainingGrade,BarrackState.Training)
	if BarrackState.Training then
		if BarrackInfos[BarrackState.CurTrainingTab] == nil or BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade] == nil then
			return BarrackState.Training
		end 
		local t = BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TimeSec - GameTime.GetSecTime()
		if t <= 0 then
			BarrackState.Training = false
			return BarrackState.Training
        end

		MessageBox.Show(String.Format(TextMgr:GetText("ui_barrack_warning4"),
						math.max(1, math.floor(SpeedUpprice.GetPrice(2,BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].TimeSec - GameTime.GetSecTime())+0.5))
		),function()
			ShowAccUI()
		end,
		function()
		
		end,
		TextMgr:GetText("common_hint1"),
		TextMgr:GetText("common_hint2"))

		
		return BarrackState.Training
	end
	return BarrackState.Training
end

local function CheckBarrackTrainForRes(tab,grade,num)
	local ResFood = (BarrackInfos[tab][grade].Res[3] == nil and 0 or BarrackInfos[tab][grade].Res[3])*num*BarrackInfos[tab][grade].TeamCount
	local ResIron = (BarrackInfos[tab][grade].Res[4] == nil and 0 or BarrackInfos[tab][grade].Res[4])*num*BarrackInfos[tab][grade].TeamCount
	local ResOil = (BarrackInfos[tab][grade].Res[5] == nil and 0 or BarrackInfos[tab][grade].Res[5])*num*BarrackInfos[tab][grade].TeamCount
	local ResElectric = (BarrackInfos[tab][grade].Res[6] == nil and 0 or BarrackInfos[tab][grade].Res[6])*num*BarrackInfos[tab][grade].TeamCount

    ResFood = math.floor(GetTrainCost(ResFood,BarrackInfos[tab][grade].SoldierId,grade))
    ResIron = math.floor(GetTrainCost(ResIron,BarrackInfos[tab][grade].SoldierId,grade))
    ResOil = math.floor(GetTrainCost(ResOil,BarrackInfos[tab][grade].SoldierId,grade))
    ResElectric = math.floor(GetTrainCost(ResElectric,BarrackInfos[tab][grade].SoldierId,grade))

	--print("food "..MoneyListData.GetFood().." ResIron "..MoneyListData.GetSteel().." ResOil "..MoneyListData.GetOil().." ResElectric "..MoneyListData.GetElec())
	if MoneyListData.GetFood() >= ResFood and MoneyListData.GetElec() >= ResElectric and MoneyListData.GetSteel()>=ResIron and MoneyListData.GetOil() >= ResOil then
		return true
	else
		return false
	end
end

local function OnClickScheduleUpGradeBtn()
	if CheckBarrackTrain() then
		return
	end
	if BarrackState.TrainSelNum == 0 then
		MessageBox.Show(TextMgr:GetText("ui_barrack_warning7"))
		return
	end
	ParadeGround.GetArmyMaxNum()

    --[[
	if  CurBuild.data.type ~= 27 and ParadeGround.GetTotalArmyNum() + GetTrainningArmyNum() + BarrackState.TrainSelNum > ParadeGround.GetArmyMaxNum() then
		FloatText.Show(TextMgr:GetText("army_max_ui4"), Color.red)--"已超过造兵上限，请升级校场以提升造兵上限" 
		return
	end
	--]]
	
	if CheckBarrackTrainForRes(BarrackState.CurTab,BarrackState.CurGrade,BarrackState.TrainSelNum) then
		
		--print("BarrackState.TrainSelNum "..BarrackState.TrainSelNum,BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierId,BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Grade)
		local requestFunc = function()
            RequestTrain(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierId,
            BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Grade,BarrackState.TrainSelNum,false,function(msg)
                if msg.code ~= 0 then
                    --Global.ShowError(msg.code)
                else
                    AudioMgr:PlayUISfx("SFX_UI_countdown_start", 1, false)
                    if BarrackState ~= nil then
                        if msg.train ~= nil and msg.train.buildUid == BarrackState.BarrackUID then
                            BarrackState.Training = true
                        end
                    end
                end
            end)
        end

        local status, args = Barrack.GetArmyStatus()
        if  status > 2 then
            if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("army_status_today") then
                MessageBox.SetOkNow()
            else
                MessageBox.SetRemberFunction(function(ishide)
                    if ishide then
                        UnityEngine.PlayerPrefs.SetInt("army_status_today",tonumber(os.date("%d")))
                        UnityEngine.PlayerPrefs.Save()
                    end
                end)
            end
			MessageBox.Show(System.String.Format(TextMgr:GetText("Review_70001"),TextMgr:GetText("Review_status_" .. status), math.floor(args[2] * 100),math.floor(args[4] * 100)), requestFunc, function() end)
        else
            requestFunc()
        end
	else
		MessageBox.Show(TextMgr:GetText("ui_barrack_warning1"))
		return
	end
end

local function OnClickScheduleUpgradeGoldBtn()
	if BarrackState.TrainSelNum == 0 then
		MessageBox.Show(TextMgr:GetText("ui_barrack_warning7"))
		return
	end	

    --[[
	if  CurBuild.data.type ~= 27 and ParadeGround.GetTotalArmyNum() + GetTrainningArmyNum()+ BarrackState.TrainSelNum > ParadeGround.GetArmyMaxNum() then
		FloatText.Show(TextMgr:GetText("army_max_ui4"), Color.red)
		return
	end
	--]]
	
	-- local goldNeeded = tonumber(BarrackUI.SoldierTrain.Schedule.UogradeGoldBtnNum.text)
 --    MessageBox.ShowConfirmation(goldNeeded <= MoneyListData.GetDiamond() and goldNeeded ~= 0, System.String.Format(TextMgr:GetText("purchase_confirmation3"), goldNeeded, "[" .. TextMgr:GetText(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierName) .. "] x" .. BarrackState.TrainSelNum), function()
		--if CheckBarrackTrainForRes(BarrackState.CurTab,BarrackState.CurGrade,BarrackState.TrainSelNum) then
		local time = math.floor(BarrackState.TrainSelNum*BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TrainTime*BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TeamCount)
		time = GetTrainTime(time,BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierId)
	    --print(BarrackState.TrainSelNum)
		local tab = BarrackState.CurTab
		local grade = BarrackState.CurGrade
		local num = BarrackState.TrainSelNum
		local ResFood = (BarrackInfos[tab][grade].Res[3] == nil and 0 or BarrackInfos[tab][grade].Res[3])*num*BarrackInfos[tab][grade].TeamCount
		local ResIron = (BarrackInfos[tab][grade].Res[4] == nil and 0 or BarrackInfos[tab][grade].Res[4])*num*BarrackInfos[tab][grade].TeamCount
		local ResOil = (BarrackInfos[tab][grade].Res[5] == nil and 0 or BarrackInfos[tab][grade].Res[5])*num*BarrackInfos[tab][grade].TeamCount
		local ResElectric = (BarrackInfos[tab][grade].Res[6] == nil and 0 or BarrackInfos[tab][grade].Res[6])*num*BarrackInfos[tab][grade].TeamCount

	    ResFood = math.floor(GetTrainCost(ResFood,BarrackInfos[tab][grade].SoldierId,grade))
	    ResFood = ResFood - MoneyListData.GetFood() < 0 and 0 or ResFood - MoneyListData.GetFood()
	    ResIron = math.floor(GetTrainCost(ResIron,BarrackInfos[tab][grade].SoldierId,grade))
	    ResIron = ResIron - MoneyListData.GetSteel() < 0 and 0 or ResIron - MoneyListData.GetSteel()
	    ResOil = math.floor(GetTrainCost(ResOil,BarrackInfos[tab][grade].SoldierId,grade))
	    ResOil = ResOil - MoneyListData.GetOil() < 0 and 0 or ResOil - MoneyListData.GetOil()
	    ResElectric = math.floor(GetTrainCost(ResElectric,BarrackInfos[tab][grade].SoldierId,grade))
	    ResElectric = ResElectric - MoneyListData.GetElec() < 0 and 0 or ResElectric - MoneyListData.GetElec()
	    local gold = 0
		gold = gold + maincity.CaculateGoldForRes(3, ResFood)
		gold = gold + maincity.CaculateGoldForRes(4, ResIron)
		gold = gold + maincity.CaculateGoldForRes(5, ResOil)
		gold = gold + maincity.CaculateGoldForRes(6, ResElectric)
	    
	    gold = math.floor(gold+0.5) + math.floor(SpeedUpprice.GetPrice(2,time)+0.5)

	    --[[
	    if MoneyListData.GetFood() < ResFood or MoneyListData.GetSteel() < ResIron or MoneyListData.GetOil() < ResOil or MoneyListData.GetElec() < ResElectric then
	        gold = math.floor(gold+0.5) + math.floor(SpeedUpprice.GetPrice(2,time)+0.5)
	    else
	        gold = math.floor(SpeedUpprice.GetPrice(2,time)+0.5)
	    end	
	    --]]
		--MessageBox.Show(String.Format(TextMgr:GetText("ui_barrack_warning2"),math.max(1, gold)),
		--	function()
			local beginrequest = function()
				RequestTrain(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierId,
						     BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Grade,BarrackState.TrainSelNum,true,function(msg)
					if msg.code == 0 then
						--FloatText.Show(TextMgr:GetText(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierName).."  LV."..BarrackState.CurGrade.."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
					    ClearTraningTag()
					    MainCityQueue.UpdateQueue();
					    AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
					end						
				end)
			end
			if gold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
				Global.ShowNoEnoughMoney()
				return
			end
			if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
				if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("s_today") then
					MessageBox.SetOkNow()
				else
					MessageBox.SetRemberFunction(function(ishide)
						if ishide then
							UnityEngine.PlayerPrefs.SetInt("s_today",tonumber(os.date("%d")))
							UnityEngine.PlayerPrefs.Save()
						end
					end)
				end
				MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation3"), gold, TextMgr:GetText(BarrackInfos[tab][grade].SoldierName)), beginrequest, function() canClick_gold = true end)
			else
				beginrequest()
			end
		--	end,
		--	function()
		--		BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TmpTrainNum = 0
		--		BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TimeSec = 0
		--		BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Training = false
		--		BarrackState.Training = false
		--		BarrackState.CurTrainingTab = 0
		--		BarrackState.CurTrainingGrade = 0
		--	end,
		--	TextMgr:GetText("common_hint1"),
		--	TextMgr:GetText("common_hint2"))
		--else
		--	MessageBox.Show(TextMgr:GetText("ui_barrack_warning1"))
		--return	
		--end
	-- end)
end

local function OnClickTrainingUpgradeGoldBtn()
	if BarrackInfos[BarrackState.CurTrainingTab] == nil then
		return
	end
	if BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade] == nil then
		return
	end
	if BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].Training then
		--local time = math.floor(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TmpTrainNum*BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TrainTime*BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TeamCount)
		--[[
		local tab = BarrackState.CurTab
		local grade = BarrackState.CurGrade
		local time = math.max(0, BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TimeSec - GameTime.GetSecTime())
		local ResFood = (BarrackInfos[tab][grade].Res[3] == nil and 0 or BarrackInfos[tab][grade].Res[3])*num*BarrackInfos[tab][grade].TeamCount
		local ResIron = (BarrackInfos[tab][grade].Res[4] == nil and 0 or BarrackInfos[tab][grade].Res[4])*num*BarrackInfos[tab][grade].TeamCount
		local ResOil = (BarrackInfos[tab][grade].Res[5] == nil and 0 or BarrackInfos[tab][grade].Res[5])*num*BarrackInfos[tab][grade].TeamCount
		local ResElectric = (BarrackInfos[tab][grade].Res[6] == nil and 0 or BarrackInfos[tab][grade].Res[6])*num*BarrackInfos[tab][grade].TeamCount

        ResFood = math.floor(GetTrainCost(ResFood,BarrackInfos[tab][grade].SoldierId,grade))
        ResIron = math.floor(GetTrainCost(ResIron,BarrackInfos[tab][grade].SoldierId,grade))
        ResOil = math.floor(GetTrainCost(ResOil,BarrackInfos[tab][grade].SoldierId,grade))
        ResElectric = math.floor(GetTrainCost(ResElectric,BarrackInfos[tab][grade].SoldierId,grade))		
        local gold = 0
		gold = gold + maincity.CaculateGoldForRes(3, ResFood)
		gold = gold + maincity.CaculateGoldForRes(4, ResIron)
		gold = gold + maincity.CaculateGoldForRes(5, ResOil)
		gold = gold + maincity.CaculateGoldForRes(6, ResElectric)
        
        if MoneyListData.GetFood() < ResFood or MoneyListData.GetSteel() < ResIron or MoneyListData.GetOil() < ResOil or MoneyListData.GetFood() < ResElectric then
            gold = gold + SpeedUpprice.GetPrice(2,time)
        else
            gold = SpeedUpprice.GetPrice(2,time)
        end		
	    --]]
	    -- local goldNeeded = tonumber(BarrackUI.SoldierTrain.Training.UogradeGoldBtnNum.text)
	    -- MessageBox.ShowConfirmation(goldNeeded <= MoneyListData.GetDiamond() and goldNeeded ~= 0, System.String.Format(TextMgr:GetText("purchase_confirmation3"), goldNeeded, "[" .. TextMgr:GetText(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].SoldierName) .. "] x" .. BarrackState.TrainSelNum), function()
		    local time = math.max(0, BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TimeSec - GameTime.GetSecTime())
	        local gold = math.floor(0.5 + SpeedUpprice.GetPrice(2,time))
			--MessageBox.Show(String.Format(TextMgr:GetText("ui_barrack_warning2"),math.max(1, math.floor(gold+0.5))),
			--function()
			local beginrequest = function()
				RequestAccelArmyTrain(function(msg)
					if msg.code == 0 then
						if BarrackState ~= nil then
					    	ClearTraningTag()
							SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)
							MainCityQueue.UpdateQueue();
							AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
							MainCityUI.UpdateArmyStatus()
						end
					end
				end)
			end
			if gold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
				Global.ShowNoEnoughMoney()
				return
			end
			if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
				if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("s_today") then
					MessageBox.SetOkNow()
				else
					MessageBox.SetRemberFunction(function(ishide)
						if ishide then
							UnityEngine.PlayerPrefs.SetInt("s_today",tonumber(os.date("%d")))
							UnityEngine.PlayerPrefs.Save()
						end
					end)
				end
				MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation3"), gold, TextMgr:GetText(BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].SoldierName)), beginrequest, function() canClick_gold = true end)
			else
				beginrequest()
			end
			--end,
			--function()
			    --ShowAccUI()
			--end,
			--TextMgr:GetText("common_hint1"),
			--TextMgr:GetText("common_hint2"))
			return
			
			--
			--ShowAccUI()
		-- end)
    end
end

local function OnClickDissolutionSoldier()
    if BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Num == 0 then
        FloatText.Show(TextMgr:GetText("ui_barrack_dissolution4"), Color.red)
    else
	    Dissolution.OpenDissolution(BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade],0)
    end
end

local function OnDragSoldierShow(obj,delta)
	if BarrackUI == nil then
		return
	end
	if BarrackUI.Soldier3DArea.ShowObj == nil then
		return
    end
	BarrackUI.Soldier3DArea.ShowObj.transform.localRotation = BarrackUI.Soldier3DArea.ShowObj.transform.localRotation*Quaternion.AngleAxis(-1*delta.x*0.5, Vector3.up)
end

local function OnSoldierRootDrag(grade, delta)
	if BarrackUI == nil then
		return
	end	
	for i = 1, 4 do
		if BarrackUI.SoldierShow[i].soldierModle ~= nil then
			if grade == i then
					BarrackUI.SoldierShow[i].soldierModle.transform.localEulerAngles = Vector3(0, BarrackUI.SoldierShow[i].soldierModle.transform.localEulerAngles.y - delta.x, 0)
			else
				BarrackUI.SoldierShow[i].soldierModle.transform.localEulerAngles = Vector3.zero
			end
		end
	end
end

OnClickSoldierShow = function()
	if BarrackUI == nil then
		return
	end	
    if BarrackUI.Soldier3DArea.ShowObj.Anim == nil then
        return
    end
	if BarrackUI.Soldier3DArea.ShowObj.Anim:get_Item("show") ~= nil then
	    if not BarrackUI.Soldier3DArea.ShowObj.Anim:IsPlaying("show") then
	        BarrackUI.Soldier3DArea.ShowObj.Anim:PlayQueued("show",UnityEngine.QueueMode.PlayNow)
            BarrackUI.Soldier3DArea.ShowObj.Anim:PlayQueued("idle",UnityEngine.QueueMode.CompleteOthers)
        end
	else
	    if not BarrackUI.Soldier3DArea.ShowObj.Anim:IsPlaying("idle") then
	        BarrackUI.Soldier3DArea.ShowObj.Anim:Play("idle")
        end
    end
end

local function OnClickTrainingSpeedUpBtn()
	if BarrackInfos[BarrackState.CurTrainingTab] == nil then
		return
	end
	if BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade] == nil then
		return
	end	
	if BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].Training then
	    ShowAccUI()
    end
end

local function OnClickTrainingSpeedUpCancelBtn()
	--if BarrackState.Training ~= true then
	--	return
	--end
	MessageBox.Show(TextMgr:GetText("ui_barrack_warning3"),
	function()
		RequestCancelArmyTrain(function(msg)
			if msg.code == 0 then
				SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)
			end
		end)
    end,
	function()
	end,
	TextMgr:GetText("common_hint1"),
	TextMgr:GetText("common_hint2"))	
	
	--BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Num = BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Num + 
	--	BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TmpTrainNum 
	--BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].TmpTrainNum = 0
	--BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Training = false
	--BarrackState.Training = false
	--BarrackState.TrainSelNum = 0
	--BarrackState.CurTrainingTab = 0
	--BarrackState.CurTrainingGrade = 0
	--BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.value = 0
	--SetupTrain(BarrackState.CurTab,BarrackState.CurGrade)
end
local function OnClickSoldierShowTab(obj)
	local grade = tonumber( string.split(obj.name,"btn_lv")[2])
	local tab = BarrackState.CurTab
	if BarrackInfos[tab][grade].Training then 
		if BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime() > 0 then
			SetupSoldierAttributes(tab,grade)
		else
		    --[[
			RequestArmNum(function(msg) 
				if msg.code == 0 then
					ClearTraningTag()
					SetupSoldierAttributes(tab,grade)		
				end
			end)
			--]]
		end
	else
		SetupSoldierAttributes(tab,grade)
	end		
end
local function OnClickSoldierShowTabUnlock(obj)
	FloatText.ShowOn(obj,TextMgr:GetText("ui_barrack_warning8"),Color.white)
	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
end

local function OnGradeClick(grade)
	local tab = BarrackState.CurTab
	if grade > BarrackInfos[tab].MinGrade then
		FloatText.Show(TextMgr:GetText("ui_barrack_warning8"),Color.white)
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		BarrackUI.SoldierShow[BarrackState.CurGrade].chassis:GetComponent("UIToggle"):Set(true)
	else
		if BarrackInfos[tab][grade].Training then 
			if BarrackInfos[tab][grade].TimeSec - GameTime.GetSecTime() > 0 then
				SetupSoldierAttributes(tab,grade)
			else
			    --[[
				RequestArmNum(function(msg) 
					if msg.code == 0 then
						ClearTraningTag()
						SetupSoldierAttributes(tab,grade)
						OnSoldierRootClick(grade)
					end
				end)
				--]]
			end
		else
			SetupSoldierAttributes(tab,grade)
			OnSoldierRootClick(grade)
		end
	end
end

local function SetupBarrackUI()
	if BarrackUI == nil then
		return
	end	
	BarrackUI.SoldierTitle.LeftBtnTxt.text = TextMgr:GetText(BarrackInfos[1][1].TabName)
	BarrackUI.SoldierTitle.LeftBtnTxt2.text = TextMgr:GetText(BarrackInfos[1][1].TabName)
	if BarrackInfos[2] ~= nil then
		BarrackUI.SoldierTitle.RightBtnTxt.text = TextMgr:GetText(BarrackInfos[2][1].TabName)
		BarrackUI.SoldierTitle.RightBtnTxt2.text = TextMgr:GetText(BarrackInfos[2][1].TabName)
	end
	
	SetClickCallback(BarrackUI.SoldierTitle.LeftBtn.gameObject,OnClickSoldierAttTitleLeftBtn)
	SetClickCallback(BarrackUI.SoldierTitle.RightBtn.gameObject,OnClickSoldierAttTitleRightBtn)
	--[[
	for i=1,4,1 do
		SetClickCallback(BarrackUI.SoldierShow[i].LvBtn.gameObject,OnClickSoldierShowTab)
		SetClickCallback(BarrackUI.SoldierShow[i].LvDisableBtn.gameObject,OnClickSoldierShowTabUnlock)
	end
	--]]
	
	for i = 1, 4 do
		SetClickCallback(BarrackUI.SoldierShow[i].chassis, function() OnGradeClick(i) end)
		SetDragCallback(BarrackUI.SoldierShow[i].chassis, function(obj,delta) OnSoldierRootDrag(i, delta) end)
		SetClickCallback(BarrackUI.SoldierShow[i].btn_tips, function() SetupOneSoldierAttribute(i) BarrackUI.AttributsRoot:SetActive(true) end)
		SetClickCallback(BarrackUI.SoldierShow[i].btn_delete, OnClickDissolutionSoldier)
	end
	BarrackState.LastTab = 0
	EventDelegate.Set(BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder.onChange,EventDelegate.Callback(OnSliderChange))
	--BarrackUI.SoldierTrain.Schedule.TrainScheduleSilder:GetComponent("UISliderOnChangeEvent").OnChange = OnSliderChange
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.TrainAddBtn.gameObject,OnClickTrainAddBtn)
	BarrackUI.SoldierTrain.Schedule.TrainAddBtn.gameObject:GetComponent("UIHoldClick").OnHoldClick = OnHoldClickTrainAddBtn
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.TrainDelBtn.gameObject,OnClickTrainDelBtn)
	BarrackUI.SoldierTrain.Schedule.TrainDelBtn.gameObject:GetComponent("UIHoldClick").OnHoldClick = OnHoldClickTrainDelBtn
	SetClickCallback(BarrackUI.CloseBtn.gameObject,OnClickCloseBtn)
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.UogradeBtn.gameObject,OnClickScheduleUpGradeBtn)
	SetClickCallback(BarrackUI.SoldierTrain.Schedule.UogradeGoldBtn.gameObject,OnClickScheduleUpgradeGoldBtn)
	SetClickCallback(BarrackUI.SoldierTrain.Training.UogradeGoldBtn.gameObject,OnClickTrainingUpgradeGoldBtn)
	--SetClickCallback(BarrackUI.SoldierShow.DeleteBtn.gameObject,OnClickDissolutionSoldier)
	
	SetClickCallback(BarrackUI.SoldierTrain.Training.SpeedUpBtn.gameObject,OnClickTrainingSpeedUpBtn)
	SetClickCallback(BarrackUI.SoldierTrain.Training.SpeedUpCancelBtn.gameObject,OnClickTrainingSpeedUpCancelBtn)
	
	
	
	--SetDragCallback(BarrackUI.SoldierShow.ShowNode.gameObject,OnDragSoldierShow)
	--SetClickCallback(BarrackUI.SoldierShow.ShowNode.gameObject,OnClickSoldierShow)
	
	--local ignore = {"SelectArmy"}
	AttributeBonus.SubCollectBonusInfo("SelectArmy")
	--AttributeBonus.CollectBonusInfo(ignore, true)
	
	SetupTab(BarrackState.CurTab)
end
	
function RefrushCurAttributeUI()
	SetupSoldierAttributes(BarrackState.CurTab,BarrackState.CurGrade)
end
	
function RefrushCurTrainTab()
    --priBarrackState.CurTrainingTab,BarrackState.CurTrainingGradint(BarrackState.CurTab,BarrackState.CurGrade)
    SetupTrain(BarrackState.CurTab,BarrackState.CurGrade)
end

function Awake()
	if isDestroy then
		if showmodelcoroutine ~= nil then
			coroutine.stop(showmodelcoroutine)
		end
		Global.CloseUI(_M)
		return
	end
	InitBarrackUI()
	MoneyListData.AddListener(RefrushCurTrainTab)	
	isOpen = true
	transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel").text = TextMgr:GetText(CurBuild.buildingData.name)
	--BarrackUI.SoldierTitle.LeftBtn.gameObject:SetActive(CurBuild.data.type == 27)
	transform:Find("Container/bg_frane/btn_tab_1/tezhong").gameObject:SetActive(CurBuild.data.type == 22)
	transform:Find("Container/bg_frane/btn_tab_1/zhongzhuang").gameObject:SetActive(CurBuild.data.type == 23)
	transform:Find("Container/bg_frane/btn_tab_1/bubing").gameObject:SetActive(CurBuild.data.type == 21)
	transform:Find("Container/bg_frane/btn_tab_1/tank").gameObject:SetActive(CurBuild.data.type == 24)
	transform:Find("Container/bg_frane/btn_tab_1/jiqiangbao").gameObject:SetActive(CurBuild.data.type == 27)
	transform:Find("Container/bg_frane/soldier_icon").gameObject:SetActive(CurBuild.data.type ~= 27)
	BarrackUI.SoldierTitle.RightBtn.gameObject:SetActive(CurBuild.data.type == 27)
	SetupBarrackUI()
	BarrackUI.SoldierShowCamera = transform:Find("Container/bg_frane/Container/Soldiers/Camera"):GetComponent("Camera")
	BarrackUI.SoldierShowCameraOriginalSize = BarrackUI.SoldierShowCamera.orthographicSize
	BarrackUI.ContainerWidget = transform:Find("Container"):GetComponent("UIWidget")	
	UpdateArmyStatus()
end

function Update()
	if isDestroy or BarrackUI == nil then
		Global.CloseUI(_M)
		return
	end	
	if BarrackInfosMap == nil then
		print("111111")
	end
	if BarrackUI then
		if BarrackUI.ContainerWidget.height ~= 640 then
			if BarrackUI.SoldierShowCameraOriginalSize == BarrackUI.SoldierShowCamera.orthographicSize and BarrackUI.ContainerWidget.width ~= 1280 then
				BarrackUI.SoldierShowCamera.orthographicSize = BarrackUI.SoldierShowCameraOriginalSize / 1280 * BarrackUI.ContainerWidget.width
			end
		end
	end
end

--[[
function Start()
	if isDestroy or BarrackUI == nil  then
		Global.CloseUI(_M)
		return
	end	

end
--]]

function Open3DArea()
	--[[
    if BarrackUI == nil then
        return 
    end
    BarrackUI.Soldier3DArea.RootObj:SetActive(true)
    if not BarrackUI.Soldier3DArea.ShowObj.Anim:IsPlaying("idle") then
	    BarrackUI.Soldier3DArea.ShowObj.Anim:Play("idle")
    end
    --]]
end

function Close3DArea()
	--[[
    if BarrackUI == nil then
        return 
    end
    BarrackUI.Soldier3DArea.RootObj:SetActive(false)
    -]]
end

function Show(id)
	isDestroy = false
	isOpen = true
	CurBuild = maincity.GetBuildingByID(id)
	InitBarrackState(CurBuild.data.type,CurBuild.data.uid)
	BarrackState.BarrackLevel = CurBuild.data.level
	local bonus = AttributeBonus.GetBonusInfos()
	local basebonus = bonus[1099] ~= nil and bonus[1099] or 0
	BarrackState.TrainTotalNum = BarrackBuildData[BarrackState.BarrackID][BarrackState.BarrackLevel].MaxNum * (1 + basebonus * 0.01) + (bonus[1091] ~= nil and bonus[1091] or 0)
	if  BarrackBuildData[BarrackState.BarrackID][BarrackState.BarrackLevel].BuildID ~= 27 then
        BarrackState.TrainTotalNum = BarrackState.TrainTotalNum +  ResView.GetTotalYield(5)
    end
	InitCfgInfo()
	-- net work	
	RequestTrainInfo(BarrackState.BarrackUID,function(msg)
		if isDestroy then
			return
		end				
		UpdateTrainInfo(msg)
		BarrackUI = nil
		Global.OpenUI(_M)
	end)
    --RequestArmNum(function(msg)
	--	if msg.code == 0 then
	--		BarrackUI = nil
	--		Global.OpenUI(_M)			
	--	end
    --end)    
    
end
--[[
function OnDestroy()
	Hide()
end
]]
function Hide()
	isDestroy = true
	coroutine.stop(showmodelcoroutine)
	showmodelcoroutine = nil
	isOpen = false
    for i=1,2,1 do--tab页
        for j =1,4,1 do
        	if BarrackInfos[i] ~= nil then
            	BarrackInfos[i][j].Training = false
            end
        end
    end
    if RequestState ~= nil then
        RequestState.CallBack = nil 
    end
    MoneyListData.RemoveListener(RefrushCurTrainTab)
	BuildingShowInfoUI.MakeTransition(CurBuild)
	--[[
	if BarrackUI ~= nil then
		if BarrackUI.Soldier3DArea.RootObj ~= nil then
			GameObject.Destroy(BarrackUI.Soldier3DArea.RootObj)
		end
	end
	--]]
	BarrackUI = nil
	BarrackState = nil
	CountDown.Instance:Remove("BarrackTraining")
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end 

    Global.CloseUI(_M)
    ShowParadeGroundArmy()
	
end

local _showPrefabs
local _showRootPrefab
local soldiers
local _showArmys
function ShowParadeGroundArmy()
	RebelSurroundNewData.NotifySoldierChangeListener()
	local _paradeground = maincity.GetBuildingByID(4)
	if _paradeground ~= nil then
		if _paradeground.land == nil or _paradeground.land:Equals(nil) then
			return
		end
		_showRootPrefab = _paradeground.land.transform:Find("PosPivot")
		if _showRootPrefab == nil then
			_showRootPrefab = NGUITools.AddChild(_paradeground.land.gameObject, ResourceLibrary.GetUIPrefab("ParadeGround/PosPivot")).transform
			_showRootPrefab.name = "PosPivot"
		end
		if _showArmys ~= nil then
			local ischange = false
			for itype = 1001, 1004 do
				if _showArmys[iType] ~= nil then
					for ilevel = 1, 4 do
						local soldier = GetAramInfo(iType , iLevel)
						if _showArmys[iType].levels[iLevel] ~= soldier then
							ischange = ischang or true
						end
					end
				else
					ischange = ischang or true
				end
			end
			if not ischange then
				return
			end
		else
			_showArmys = {}
		end
		if soldiers ~= nil then
			for i, v in ipairs(soldiers) do
				if v ~= nil and not v:Equals(nil) then
					GameObject.Destroy(v)
				end
			end
		end
		soldiers = {}
		local maxnum = 0
		
		for iType = 1001 , 1004 do
			local _showData = TableMgr:GetSoldierShowRule(iType)
			if _showData ~= nil then
				_showArmys[iType] = {}
				_showArmys[iType].totalnum = 0
				_showArmys[iType].levels = {}
				_showArmys[iType].singleNum = _showData.num
				_showArmys[iType].prefab = ResourceLibrary.GetUIPrefab("ParadeGround/" .. _showData.prefab)
				_showArmys[iType].childCount = _showArmys[iType].prefab.transform.childCount
				for iLevel = 1 , 4 do
					local soldier = GetAramInfo(iType , iLevel)
					if soldier ~= nil and soldier.Num > 0 then
						_showArmys[iType].levels[iLevel] = soldier
						_showArmys[iType].totalnum = _showArmys[iType].totalnum + soldier.Num
					end
				end
				if maxnum < _showArmys[iType].totalnum then
					maxnum = _showArmys[iType].totalnum
				end
			end
		end
		local index = 1000
		for i = 1001, 1004 do
			if _showRootPrefab:Find(i).childCount > 0 then
				for j = 0, _showRootPrefab:Find(i).childCount - 1 do
					GameObject.Destroy(_showRootPrefab:Find(i):GetChild(j).gameObject)
				end
			end
			if _showArmys[i] ~= nil and _showArmys[i].totalnum > 0 then
				index = index + 1
				local tempTrans
				local positions = {}
				tempTrans = NGUITools.AddChild(_showRootPrefab:Find(index).gameObject, _showArmys[i].prefab).transform
				for j = 1, _showArmys[i].childCount do
					positions[j] = tempTrans:Find(tostring(j)).gameObject
				end
				local index2 = 0
				local s_prefabs = {}
				for iLevel = 4, 1, -1 do
					local soldier = _showArmys[i].levels[iLevel]
					if soldier ~= nil and soldier.Num > 0 then
						local _item = {}
						local maxPos = Mathf.Ceil(soldier.Num / maxnum * _showArmys[i].childCount)
						local temppos = Mathf.Ceil(soldier.Num / _showArmys[i].singleNum)
						_item.num = Mathf.Min(maxPos, temppos)
						_item.prefab = ResourceLibrary:GetUnitPrefabLow(TableMgr:GetUnitData(soldier.UnitID)._unitPrefab)--ResourceLibrary.GetUIPrefab("units_2d/" .. TableMgr:GetUnitData(soldier.UnitID)._unitPrefab)
						for k = 1, _item.num do
							index2 = index2 + 1
							if positions[index2] ~= nil then
								soldiers[#soldiers + 1] = NGUITools.AddChild(positions[index2], _item.prefab)
								--soldiers[#soldiers].transform.localEulerAngles = Vector3(45, 135, 0)
								soldiers[#soldiers].transform.localScale = Vector3(15, 15, 15)
								s_prefabs[index2] = soldiers[#soldiers]:GetComponent("Animation")--GetComponent("UIAtlasAnim")
								s_prefabs[index2]:Play("idle")
							end
						end
					end
				end
				SetClickCallback(tempTrans.gameObject, function(go)
					BuildingShowInfoUI.ShowParadeGroundNum()
					for _, v in ipairs(s_prefabs) do
						--v:Play("show")
						if not v:IsPlaying("show") then
							v:Play("show")
						end     
					end
				end)
				BuildingShowInfoUI.SetParadeGroundGroup(i, _showArmys[i].totalnum, tempTrans)
			else
				BuildingShowInfoUI.RemoveParadeGroundGroup(i)
			end
		end
	end
end

function HideParadeGroundArmy()
	if soldiers ~= nil then
		for i, v in ipairs(soldiers) do
			GameObject.Destroy(v)
		end
	end
	soldiers = nil
	_showRootPrefab = nil
	_showPrefabs = nil
end
