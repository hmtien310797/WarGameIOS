module("MobaBarrackData", package.seeall)


local BarrackInfosMap;
local setoutNum;

--Barrack.GetArmyRealNum
function GetArmyRealNum(soldierId,grade)
	if BarrackInfosMap[soldierId] == nil or BarrackInfosMap[baseid][grade] == nil then
		return 0
	end
	if setoutNum ~= nil and setoutNum[soldierId]~= nil and setoutNum[soldierId][grade] ~= nil then
		return BarrackInfosMap[soldierId][grade].Num + setoutNum[soldierId][grade]
	else
		return BarrackInfosMap[soldierId][grade].Num
	end
end
--Barrack.GetAramInfo
function GetAramInfo(armyId,armyLevel)
	if BarrackInfosMap[armyId] == nil or BarrackInfosMap[armyId][armyLevel] == nil then
		return nil
	end
    return BarrackInfosMap[armyId][armyLevel]
end
--Barrack.GetArmy
function GetArmy()
	local allArmy = {}
	local totalnum = 0
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			local soldier = GetAramInfo(iType , iLevel)
            if soldier ~= nil and soldier.Num > 0 then
                print("EEEEEEEEEEEEEEE",iType , iLevel,soldier.Num)
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

function GetRealArmyNum()
	local totalnum = 0
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			totalnum = totalnum + GetArmyRealNum(iType,iLevel)
		end
	end
	return totalnum
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

function FillBrrackInfo(iType,iLevel)
    local info = {}
    local soldier_data = Barrack.GetAramInfo(iType,iLevel)				
    info.UnitID = soldier_data.UnitID
    info.SoldierId = soldier_data.SoldierId
    info.Grade = soldier_data.Grade
    info.SoldierName = soldier_data.SoldierName
    info.SoldierIcon = soldier_data.SoldierIcon
    info.fight = soldier_data.fight
    info.Weight = soldier_data.Weight
    info.TeamCount = soldier_data.TeamCount
    info.Speed = soldier_data.Speed
    info.Attack = soldier_data.Attack
    info.Hp = soldier_data.Hp
    info.Defend  = soldier_data.Defend
    info.Penetration = soldier_data.Penetration 
    info.barrackAdd = soldier_data.Penetration 
	info.barrack_bonus = AttributeBonus.CalBarrackBonus(soldier_data)
    return info
end

--Barrack.UpdateArmNumEx
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
		MobaSetoutData.SetData(setoutlist)
    end
    BarrackInfosMap = {}
    for i = 1,#(msg.arms) do
        local arm =	msg.arms[i]
        if arm.level ~= 0 then
            if BarrackInfosMap == nil then
                BarrackInfosMap = {}
            end
            if BarrackInfosMap[arm.baseid] == nil then
                BarrackInfosMap[arm.baseid] = {}
            end
            if BarrackInfosMap[arm.baseid][arm.level] == nil then
                BarrackInfosMap[arm.baseid][arm.level] = FillBrrackInfo(arm.baseid,arm.level)
                
            end                
            BarrackInfosMap[msg.arms[i].baseid][msg.arms[i].level].Num = msg.arms[i].num            
            RefrushSetout4ArmyNum(msg.arms[i]) 
        end
    end
end

function RefreshArmNum(msg)
	if msg.code == 0 then
		if msg.fresh.arms ~= nil then
			for i=1,#(msg.fresh.arms.data) do
                local arm =	msg.fresh.arms.data[i].data
                if BarrackInfosMap == nil then
                    BarrackInfosMap = {}
                end  
                if BarrackInfosMap[arm.baseid] == nil then
                    BarrackInfosMap[arm.baseid] = {}
                end
                if BarrackInfosMap[arm.baseid][arm.level] == nil then
                    BarrackInfosMap[arm.baseid][arm.level] = FillBrrackInfo(arm.baseid,arm.level)
                    
                end                    
                BarrackInfosMap[arm.baseid][arm.level].Num = arm.num   
                RefrushSetout4ArmyNum(arm)
            end
        end
    end
end

--ArmySetoutData.UpdateData(msg.freshArmyNum)
function UpdateData(freshArmyNum)
end

