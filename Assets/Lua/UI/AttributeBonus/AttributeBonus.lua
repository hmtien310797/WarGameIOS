module("AttributeBonus",package.seeall)

local TableMgr = Global.GTableMgr

local AttBonusType = {
	ABT_Player = 0,
	ABT_Riflerman = 1,
	ABT_Assault = 2,
	ABT_Sniper = 3,
	ABT_RPG = 4,
	ABT_MachineGunner = 5,
	ABT_Firebat = 6,
	ABT_MidTank = 7,
	ABT_HeavyTank = 8,
	ABT_ALL = 10000
}

local AttType = {
	AT_AttackValue = 1,				--兵种攻击数值加成 1
	AT_AttackPercent = 2,			--兵种攻击百分比加成 2
	AT_MoraleValue = 3,				--兵种士气加成 3
	AT_HPValue = 4,					--兵种生命数值加成 4
	AT_HPPercent = 5,				--兵种生命百分比加成 5
	AT_Physique = 6,				--兵种体质加成 6
	AT_PierceValue = 7,				--兵种穿透数值加成 7
	AT_PiercePercent = 8,			--兵种穿透百分比加成 8
	AT_ArmorValue = 9,				--兵种护甲数值加成 9
	AT_ArmorPercent = 10,			--兵种护甲百分比加成 10
	AT_Dodge = 11,					--兵种闪避 11
	AT_Critical = 12,				--兵种暴击 12
	AT_WeaponCD = 13,				--兵种攻击间隔缩减 13
	AT_WeaponReload = 14,			--兵种换弹时间缩减 14
	AT_WeaponTotalCD = 15,			--兵种总攻击间隔缩减 15
	AT_GroupSummonCD = 16,			--兵种召唤CD缩减 16
	AT_GroupNeedBullet = 17,		--兵种召唤弹药缩减 17
	AT_WeaponAttackRange = 18,		--兵种射程 18
	AT_WeaponButtleCilp = 19,		--兵种弹夹子弹数 19
	AT_UnitMoveSpeed = 20,			--兵种移动速度 20
	AT_AttackPercent_A_PassiveSkill = 27,
	AT_HPPercent_A_PassiveSkill = 28,
    AT_ArmorValue_A_PassiveSkill = 29,
	AT_AttackPercent_D_PassiveSkill = 30,
	AT_HPPercent_D_PassiveSkill = 31,
	AT_ArmorValue_D_PassiveSkill = 32,
	AT_Carry = 33,
	AT_MoveSpeed = 34,
	AT_TenacityBonusFactor = 35,

	AT_BattleSummonEnergy = 1000,	--初始弹药加成 1000
	AT_BattleSkillEnergy = 1001,	--初始能量加成 1001
	AT_BattleSummonEnergyRecovery = 1002-- 每秒弹药恢复加成 1002
}

local MoraleBonusFactor = {
	0.14,	-- ABT_Riflerman
	0.21,	-- ABT_Assault
	0.56,	-- ABT_Sniper
	0.35,	-- ABT_RPG
	0.21,	-- ABT_MachineGunner
	0.35,	-- ABT_Firebat
	0.35,	-- ABT_MidTank
	0.97	-- ABT_HeavyTank
}

local PhysiqueBonusFactor = {
	0.28,	-- ABT_Riflerman
	0.42,	-- ABT_Assault
	0.56,	-- ABT_Sniper
	0.42,	-- ABT_RPG
	0.69,	-- ABT_MachineGunner
	0.42,	-- ABT_Firebat
	0.97,	-- ABT_MidTank
	1.40	-- ABT_HeavyTank
}

local BattlePointFactor = {
	AttackFactor = 0.002,
	HpFactor = 0.001,
	ArmorFactor = 0.01,
	PierceFactor = 0.01,
}

local RegisteredModule = {}

local RegisteredModuleNames = {}

local BonusInfos
local BonusInfosCommander

GetValueSGL = nil
local GetValueGlobal

function RegisterAttBonusModule (module)	
	if RegisteredModuleNames[ module._NAME] ~= nil then
	    return 
	end

	if module.CalAttributeBonus ~= nil then
		table.insert (RegisteredModule, module)
        RegisteredModuleNames[ module._NAME] = 1
		print ("############# RegisterAttBonusModule Succeed " .. module._NAME)
	else
		print ("############# RegisterAttBonusModule Failled " .. module._NAME)
		--table.foreach (module, function(i,v) print(i,v) end)
	end
end

function RemoveAttBonusModule(ModuleName)
	for i=1 , #RegisteredModule do
		if RegisteredModule[i] and ModuleName == RegisteredModule[i]._NAME then
			print("removeModule:" .. RegisteredModule[i]._NAME)
			table.remove(RegisteredModule , i)
			if RegisteredModuleNames[ModuleName] then
				
				print("removeModuleName:" .. ModuleName .. " value:" .. RegisteredModuleNames[ModuleName])
				RegisteredModuleNames[ModuleName] = nil
			end
		end
	end
end

local function CheckName(Ignore_name, ModuleName)
	local t = type(Ignore_name)
	if t == "table" then
		local notcontains = true
		for i, v in ipairs(Ignore_name) do
			--print(v, ModuleName)
			if v == ModuleName then
				notcontains = false
			end
		end
		return notcontains
	else
		return Ignore_name ~= ModuleName
	end
end

local function CheckNameOK(names, ModuleName)
	local t = type(names)
	if t == "table" then
		local notcontains = false
		for i, v in ipairs(names) do
			--print(v, ModuleName)
			if v == ModuleName then
				notcontains = true
			end
		end
		return notcontains
	else
		return names == ModuleName
	end
end

function GetBonusInfos()
    return BonusInfos
end

function AddCollectBounsInfo(AddModules)
    if AddModules == nil then
        return
    end
	for i = 1,#(RegisteredModule) do
	    if CheckNameOK(AddModules, RegisteredModule[i]._NAME) then
	        --print("ADDDDDDD               ",RegisteredModule[i]._NAME)
			local bonus = RegisteredModule[i]:CalAttributeBonus ()
			for j=1, #(bonus) do
				local index = bonus[j].BonusType * 10000 + bonus[j].Attype
				if BonusInfos[index] == nil then
					BonusInfos[index] = 0
				end		
				if BonusInfosCommander[index] == nil then
					BonusInfosCommander[index] = 0
				end
				if global == nil then		
					BonusInfos[index] = BonusInfos[index]+ bonus[j].Value
				else
					if bonus[j].Global == nil then
						BonusInfos[index] = BonusInfos[index]+ bonus[j].Value
					else
						if bonus[j].Global == 1 then
							BonusInfos[index] = BonusInfos[index]+ bonus[j].Value
						else
							BonusInfosCommander[index] = BonusInfosCommander[index] + bonus[j].Value
						end
                    end
				end
            end
        end
    end
end

function SubCollectBonusInfo(SubModules)
    if SubModules == nil then
        return
    end
	for i = 1,#(RegisteredModule) do
	    if CheckNameOK(AddModules, RegisteredModule[i]._NAME) then
			local bonus = RegisteredModule[i]:CalAttributeBonus ()
			for j=1, #(bonus) do
				local index = bonus[j].BonusType * 10000 + bonus[j].Attype
				if BonusInfos[index] == nil then
					BonusInfos[index] = 0
				end		
				if BonusInfosCommander[index] == nil then
					BonusInfosCommander[index] = 0
                end
				if global == nil then		
					BonusInfos[index] =math.max(0,  BonusInfos[index] - bonus[j].Value)
				else
					if bonus[j].Global == nil then
						BonusInfos[index] =math.max(0,  BonusInfos[index] - bonus[j].Value)
					else
						if bonus[j].Global == 1 then
							BonusInfos[index] =math.max(0,  BonusInfos[index]- bonus[j].Value)
						else
							BonusInfosCommander[index] =math.max(0,  BonusInfosCommander[index] - bonus[j].Value)
						end
                    end
				end
            end
        end
    end
end

function CollectBonusInfo (Ignore_name, global,only_col_name)
    local timecost = os.clock()
    local timecost1 = os.clock()
	BonusInfos = nil
	BonusInfosCommander = nil
	if next (RegisteredModule) == nil then
		return
    end
	BonusInfos = {}
	BonusInfosCommander = {}
	--local info = debug.getinfo(2,"S")
	--print("CCCCCCCCCCCCCCCCC   CollectBonusInfo ",info.source,info.linedefined)
	for i = 1,#(RegisteredModule) do
	    
		if Ignore_name == nil or CheckName(Ignore_name, RegisteredModule[i]._NAME) then
			if only_col_name == nil or( only_col_name ~= nil and CheckNameOK(only_col_name, RegisteredModule[i]._NAME) ) then

			local bonus = RegisteredModule[i]:CalAttributeBonus ()

            --print("^^^^^^^^^^^^^^^^^^^^ CalAttributeBonus ",(os.clock() - timecost)*1000, RegisteredModule[i]._NAME)
            timecost = os.clock()
			for j=1, #(bonus) do
				local index = bonus[j].BonusType * 10000 + bonus[j].Attype
				if BonusInfos[index] == nil then
					BonusInfos[index] = 0
				end		
				if BonusInfosCommander[index] == nil then
					BonusInfosCommander[index] = 0
				end
				if global == nil then		
					BonusInfos[index] = BonusInfos[index]+ bonus[j].Value
				else
					if bonus[j].Global == nil then
						BonusInfos[index] = BonusInfos[index]+ bonus[j].Value
					else
						if bonus[j].Global == 1 then
							BonusInfos[index] = BonusInfos[index]+ bonus[j].Value
						else
							BonusInfosCommander[index] = BonusInfosCommander[index] + bonus[j].Value
						end
                    end
				end
			end
			end
            --print("^^^^^^^^^^^^^^^^^^^^ Dis Bonus ",(os.clock() - timecost)*1000, RegisteredModule[i]._NAME)
        end
	end
	--table.foreach (BonusInfos, function (i, v) print (i, v) end)
	--table.foreach (BonusInfosCommander, function (i, v) print (i, v) end)
	return BonusInfos, BonusInfosCommander
end

function CollectTopHeroBonusInfo(topHeroCount)
	BonusInfos = nil
	BonusInfos = {}
	 --HeroListData.GetHeroTopPower(5)
	local bonus , heroPower = SelectHero.CalAttributeBonus (topHeroCount)
	for j=1, #(bonus) do
		local index = bonus[j].BonusType * 10000 + bonus[j].Attype
		if BonusInfos[index] == nil then
			BonusInfos[index] = 0
		end				
		BonusInfos[index] = BonusInfos[index]+ bonus[j].Value
	end
	return BonusInfos , heroPower
end

local function GetValue (bonus_info,bonustype,attype)
    if PVPUI.IsPVP() then 
        return 0
    end
	if bonus_info == nil then
		return 0
	end
	local index = bonustype*10000 + attype
	if bonus_info[index] ~= nil then
		return bonus_info[index]
	end
	return 0
end

local function GetValue4SGL(bonus_info,id)
	if bonus_info == nil then
		return 0
    end
	if bonus_info[id] ~= nil then
		return bonus_info[id]
	end
	return 0
end

GetValueSGL  = function (id)
    --print("BonusInfos ",id, GetValueGlobal)
    if GetValueGlobal == nil or GetValueGlobal == 1 then
		if BonusInfos == nil then
			return 0
	    end
		if BonusInfos[id] ~= nil then
			return BonusInfos[id]
		end
	else
		if BonusInfosCommander == nil then
			return 0
		end
		if BonusInfosCommander[id] ~= nil then
			return BonusInfosCommander[id]
		end
	end
	return 0
end

local function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
		if not nFindLastIndex then
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
			break
		end
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)
		nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

local function GetWeaponInfo(weapon_id_strs)
	local weapon_id_sub_strs = Split(weapon_id_strs,";")
	local weapon_id = tonumber(weapon_id_sub_strs[1])
	return TableMgr:GetWeaponData(weapon_id);
end


local function toUnitBonus (bonus_info)
	local bonus = Serclimax.Unit.ScUnitBonus ()
	bonus.WeaponDamageBonus = bonus_info.WeaponDamage
	bonus.WeaponCDBonus = bonus_info.WeaponCD
	bonus.WeaponAntiDefBonus = bonus_info.WeaponAntiDef
	bonus.WeaponReloadBonus = bonus_info.WeaponReload
	bonus.WeaponRangeBonus = bonus_info.WeaponRange
	bonus.WeaponMaxRangeBonus = bonus_info.WeaponMaxRange
	bonus.WeaponClipBonus = bonus_info.WeaponClip
	bonus.UnitHPBonus = bonus_info.UnitHP
	bonus.UnitDefBonus = bonus_info.UnitDef
	bonus.UnitDodgeBonus = bonus_info.UnitDodge
	bonus.UnitCriticalBonus = bonus_info.UnitCritical
	bonus.UnitVisionBonus = bonus_info.UnitVision
	bonus.UnitSpeedBonus = bonus_info.UnitSpeed
	bonus.UnitGroupNeedBulletBonus = bonus_info.GroupNeedBullet
	return bonus
end


function CalBattlePoint(barrack_bonus,team_count)
	if barrack_bonus == nil then
		return 0
	end
	
	return barrack_bonus.Attack * team_count * BattlePointFactor.AttackFactor +
	barrack_bonus.Hp * team_count * BattlePointFactor.HpFactor +
	barrack_bonus.Penetration * BattlePointFactor.PierceFactor + 
	barrack_bonus.Defend * BattlePointFactor.ArmorFactor
end

function CalBattlePointNew(barrack_info)
	if barrack_info == nil then
	    print("barrack_bonus == nil")
		return 0
	end
    local bonus_info = BonusInfos
    if bonus_info == nil then
        print("bonus_info == nil")
        return 0
    end
    local type = barrack_info.SoldierId
    local barrackAdd = barrack_info.barrackAdd
	local attack_bonus = (barrack_info.Attack + GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackValue) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackValue) + GetValue (bonus_info, type, AttType.AT_AttackValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent) + GetValue (bonus_info, type, AttType.AT_AttackPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_MoraleValue) + GetValue (bonus_info, barrackAdd, AttType.AT_MoraleValue) + GetValue (bonus_info, type, AttType.AT_MoraleValue)) * TableMgr:GetPVEMoraleBonusFactor(type);
	
	local hp_bonus = (barrack_info.Hp +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPValue)+ GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) +GetValue (bonus_info, type, AttType.AT_HPValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Physique) + GetValue (bonus_info, barrackAdd, AttType.AT_Physique) +GetValue (bonus_info, type, AttType.AT_Physique)) * TableMgr:GetPVEPhysiqueBonusFactor(type);

    local ex_bonus = 0

    for i = 11,20,1 do
        ex_bonus = ex_bonus + (GetValue(bonus_info,9,i)) + (GetValue(bonus_info,type,i))
       -- ex_bonus = ex_bonus + (GetValue(bonus_info,type,i))
    end
    --print(barrack_info.fight,attack_bonus/barrack_info.Attack,hp_bonus/barrack_info.Hp,1+(GetValue(bonus_info,9,9)+GetValue(bonus_info,type,9))/100,1+ex_bonus/100)
	--兵种战力=兵种查表战力*（该兵种当前攻击/兵种查表攻击）*（该兵种当前生命/兵种查表生命）*（1+兵种当前防御/100）*（1+兵种其他加成之和/100）
    --return barrack_info.fight*(attack_bonus/barrack_info.Attack)*(hp_bonus/barrack_info.Hp)*(1+(GetValue(bonus_info,9,9)+GetValue(bonus_info,type,9))/100)*(1+ex_bonus/100)
	
	
	--兵种战力=兵种1阶查表战力*（该兵种当前攻击/兵种1阶查表攻击+该兵种当前生命/兵种1阶查表生命+兵种当前防御/100）*（1+兵种其他加成之和/100） ---- 2017/4/21
    --return barrack_info.fight*(attack_bonus/barrack_info.Attack + hp_bonus/barrack_info.Hp + (GetValue(bonus_info,9,9)+GetValue(bonus_info,type,9))/100)*(1+ex_bonus/100)
	
	--兵种战力=兵种1阶查表战力*（该兵种当前攻击/兵种1阶查表攻击+该兵种当前生命/兵种1阶查表生命+兵种当前防御/100）/2 ---- 2017/9/6
	--print(attack_bonus , hp_bonus ,(GetValue(bonus_info,AttBonusType.ABT_ALL,AttType.AT_ArmorValue)+GetValue(bonus_info,barrackAdd,AttType.AT_ArmorValue)),type )
	--GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorValue) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue) +GetValue (bonus_info, type, AttType.AT_ArmorValue)
	local baseBarrack = Barrack.GetAramInfo(barrack_info.SoldierId , 1)
	local leveBaseFight = baseBarrack.fight
	local leveBaseHp = baseBarrack.Hp
	local leveBaseAtk = baseBarrack.Attack
	
	--print(attack_bonus , hp_bonus)
	return leveBaseFight*(attack_bonus/leveBaseAtk + hp_bonus/leveBaseHp + (GetValue(bonus_info,AttBonusType.ABT_ALL,AttType.AT_ArmorValue)+
	GetValue(bonus_info,type,AttType.AT_ArmorValue)+GetValue(bonus_info,barrackAdd,AttType.AT_ArmorValue))/100)/2
	--return barrack_info.fight*(attack_bonus/barrack_info.Attack + hp_bonus/barrack_info.Hp + (GetValue(bonus_info,AttBonusType.ABT_ALL,AttType.AT_ArmorValue)+
	--GetValue(bonus_info,type,AttType.AT_ArmorValue)+GetValue(bonus_info,barrackAdd,AttType.AT_ArmorValue))/100)/2
end

function CalBattlePointNewEx(barrack_info)
	if barrack_info == nil then
	    print("barrack_bonus == nil")
		return 0
	end
    local bonus_info = BonusInfos
    if bonus_info == nil then
        print("bonus_info == nil")
        return 0
    end
    local type = barrack_info.SoldierId
	local attack_bonus = (barrack_info.Attack  + GetValue (bonus_info, type, AttType.AT_AttackValue)) *
	(1 + ( GetValue (bonus_info, type, AttType.AT_AttackPercent))*0.01) 
	
	local hp_bonus = (barrack_info.Hp  +GetValue (bonus_info, type, AttType.AT_HPValue)) *
	(1 + ( GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01)

    local ex_bonus = 0

    return barrack_info.fight*(attack_bonus/barrack_info.Attack)*(hp_bonus/barrack_info.Hp)
end

function CalBattlePointSLGPVPArmy(barrack_info)
    if barrack_info == nil then
        return 0
    end
	local type = barrack_info.SoldierId
	local bonus_info = BonusInfos    
	local barrackAdd = barrack_info.barrackAdd

    --print("SSSSSSSSSSSSSSSSSSSS")
    --[[
    print(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackPercent) , GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent) , GetValue (bonus_info, type, AttType.AT_AttackPercent),
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) ,GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) , GetValue (bonus_info, type, AttType.AT_HPPercent),
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorValue) ,GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue) ,GetValue (bonus_info, type, AttType.AT_ArmorValue))
    --]]

    return barrack_info.fight*(1+(
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent) + GetValue (bonus_info, type, AttType.AT_AttackPercent)+
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) +GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent)+
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorValue) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue) +GetValue (bonus_info, type, AttType.AT_ArmorValue)+
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackPercent_A_PassiveSkill) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent_A_PassiveSkill) + GetValue (bonus_info, type, AttType.AT_AttackPercent_A_PassiveSkill)+
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent_A_PassiveSkill) +GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent_A_PassiveSkill) + GetValue (bonus_info, type, AttType.AT_HPPercent_A_PassiveSkill)+
       GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorValue_A_PassiveSkill) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue_A_PassiveSkill) +GetValue (bonus_info, type, AttType.AT_ArmorValue_A_PassiveSkill)
       )*0.01)
   end

function CalBattlePointSLGPVPArmyEx(barrack_info)
    if barrack_info == nil then
        return 0
    end
	local type = barrack_info.SoldierId
	local bonus_info = BonusInfos    
    return barrack_info.fight*(1+(GetValue (bonus_info, type, AttType.AT_AttackPercent)+ GetValue (bonus_info, type, AttType.AT_HPPercent)+GetValue (bonus_info, type, AttType.AT_ArmorValue))*0.003)
end   

function CalBarrackBonus (barrack_info)
	local barrack_bonus = {}
	if BonusInfos == nil then 
		return nil
	end
	local type = barrack_info.SoldierId
	local bonus_info = BonusInfos  --CollectBonusInfo()
	local barrackAdd = barrack_info.barrackAdd
	
	barrack_bonus.Attack = (barrack_info.Attack + GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackValue)+ GetValue (bonus_info, barrackAdd, AttType.AT_AttackValue) + GetValue (bonus_info, type, AttType.AT_AttackValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent) + GetValue (bonus_info, type, AttType.AT_AttackPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_MoraleValue) + GetValue (bonus_info, barrackAdd, AttType.AT_MoraleValue) + GetValue (bonus_info, type, AttType.AT_MoraleValue)) * TableMgr:GetPVEMoraleBonusFactor(type);

	barrack_bonus.Penetration = (barrack_info.Penetration +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_PierceValue) +GetValue (bonus_info, barrackAdd, AttType.AT_PierceValue) +GetValue (bonus_info, type, AttType.AT_PierceValue)) * (1 +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_PiercePercent) + GetValue (bonus_info, barrackAdd, AttType.AT_PiercePercent) + GetValue (bonus_info, type, AttType.AT_PiercePercent))*0.01)
	
	barrack_bonus.Hp = (barrack_info.Hp +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPValue) +GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) +GetValue (bonus_info, type, AttType.AT_HPValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Physique) + GetValue (bonus_info, barrackAdd, AttType.AT_Physique) + GetValue (bonus_info, type, AttType.AT_Physique)) * TableMgr:GetPVEPhysiqueBonusFactor(type);
	
	barrack_bonus.Defend = (barrack_info.Defend +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorValue) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue) +GetValue (bonus_info, type, AttType.AT_ArmorValue)) * (1 +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_ArmorPercent) + GetValue (bonus_info, type, AttType.AT_ArmorPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_TenacityBonusFactor) + GetValue (bonus_info, barrackAdd, AttType.AT_TenacityBonusFactor) + GetValue (bonus_info, type, AttType.AT_TenacityBonusFactor)) * TableMgr:GetPVETenacityBonusFactor(type);

	barrack_bonus.AttackSpeed = barrack_info.AttackSpeed * (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponCD) +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponTotalCD) +
	GetValue (bonus_info, barrackAdd, AttType.AT_WeaponCD) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponTotalCD) +
	GetValue (bonus_info, type, AttType.AT_WeaponCD) +GetValue (bonus_info, type, AttType.AT_WeaponTotalCD))*0.01)

	barrack_bonus.ExtraCarry = GetValue(bonus_info, type, AttType.AT_Carry)

	barrack_bonus.ExtraMoveSpeed = GetValue(bonus_info, type, AttType.AT_MoveSpeed)

	return barrack_bonus
end

function GetAttribute(SoldierId, AttType)
	if BonusInfos == nil then 
		return 0
	end
	return GetValue(BonusInfos, SoldierId, AttType)
end

function CalBarrackBonus27 (barrack_info)
	local barrack_bonus = {}
	if BonusInfos == nil then 
		return nil
	end
	local type = barrack_info.SoldierId
	local bonus_info = BonusInfos  --CollectBonusInfo()

	barrack_bonus.Attack = (barrack_info.Attack + GetValue (bonus_info, type, AttType.AT_AttackValue)) *(1 + ( GetValue (bonus_info, type, AttType.AT_AttackPercent))*0.01)
	
	barrack_bonus.Penetration = (barrack_info.Penetration +GetValue (bonus_info, type, AttType.AT_PierceValue)) * (1 +(GetValue (bonus_info, type, AttType.AT_PiercePercent))*0.01)
	
	barrack_bonus.Hp = (barrack_info.Hp +GetValue (bonus_info, type, AttType.AT_HPValue)) *(1 + ( GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) 
	
	barrack_bonus.Defend = (barrack_info.Defend +GetValue (bonus_info, type, AttType.AT_ArmorValue)) * (1 +(GetValue (bonus_info, type, AttType.AT_ArmorPercent))*0.01)
	return barrack_bonus  
end

function CalBarrackBonus_Normal (barrack_info)
	local barrack_bonus = {}
	if BonusInfos == nil then 
		return nil
	end
	local type = barrack_info.SoldierId

	barrack_bonus.Attack = barrack_info.Attack;

	barrack_bonus.Penetration = barrack_info.Penetration
	
	barrack_bonus.Hp = barrack_info.Hp
	
	barrack_bonus.Defend = barrack_info.Defend 
	return barrack_bonus
end


function CalUnitBonus (table_id)
	local unit_bonus = {}
	if BonusInfos == nil then 
		return nil
	end
	
	print (table_id)
	local unit_data = TableMgr:GetUnitData (table_id)

	local weapon_data = GetWeaponInfo (unit_data._unitWeapons)
	local type = unit_data._unitArmyType
	local barrackAdd = Barrack.GetAramInfo(unit_data._unitArmyType, unit_data._unitArmyLevel).barrackAdd
	if	type == 0 then
		return nil
    end

	local bonus_info = BonusInfos  --CollectBonusInfo()

	unit_bonus.WeaponDamage = (weapon_data._wDamage + GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackValue) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackValue) + GetValue (bonus_info, type, AttType.AT_AttackValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent) + GetValue (bonus_info, type, AttType.AT_AttackPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_MoraleValue) + GetValue (bonus_info, barrackAdd, AttType.AT_MoraleValue) + GetValue (bonus_info, type, AttType.AT_MoraleValue)) * TableMgr:GetPVEMoraleBonusFactor(type);

	unit_bonus.WeaponCD = weapon_data._wShootCD / (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponCD) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponCD) +
	GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponTotalCD) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponTotalCD) +
	GetValue (bonus_info, type, AttType.AT_WeaponCD) +GetValue (bonus_info, type, AttType.AT_WeaponTotalCD))*0.01)
	
	unit_bonus.WeaponAntiDef = (weapon_data._wAntiDefense +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_PierceValue) +GetValue (bonus_info, barrackAdd, AttType.AT_PierceValue) +GetValue (bonus_info, type, AttType.AT_PierceValue)) * (1 +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_PiercePercent) +GetValue (bonus_info, barrackAdd, AttType.AT_PiercePercent) +GetValue (bonus_info, type, AttType.AT_PiercePercent))*0.01)
	
	unit_bonus.WeaponReload = weapon_data._wReload / (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponReload) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponReload) +GetValue (bonus_info, type, AttType.AT_WeaponTotalCD) +
	GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponReload) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponReload) +GetValue (bonus_info, type, AttType.AT_WeaponTotalCD))*0.01)
	
	unit_bonus.WeaponRange = weapon_data._wAttackRange * (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponAttackRange) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponAttackRange) +
	GetValue (bonus_info, type, AttType.AT_WeaponAttackRange))*0.01)
	
	unit_bonus.WeaponMaxRange = weapon_data._wMaxDistance * (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponAttackRange) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponAttackRange) +
	GetValue (bonus_info, type, AttType.AT_WeaponAttackRange))*0.01)
	
	unit_bonus.WeaponClip = weapon_data._wClip +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponButtleCilp) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponButtleCilp) +GetValue (bonus_info, type, AttType.AT_WeaponButtleCilp)

	unit_bonus.UnitHP = (unit_data._unitMaxHp +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPValue) +GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) +GetValue (bonus_info, type, AttType.AT_HPValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Physique) +GetValue (bonus_info, barrackAdd, AttType.AT_Physique) +GetValue (bonus_info, type, AttType.AT_Physique)) * TableMgr:GetPVEPhysiqueBonusFactor(type);
	
	unit_bonus.UnitDef = (unit_data._unitDefense +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorValue) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue) +GetValue (bonus_info, type, AttType.AT_ArmorValue)) * (1 +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorPercent) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorPercent) +GetValue (bonus_info, type, AttType.AT_ArmorPercent))*0.01)
	
	unit_bonus.UnitDodge =(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Dodge) + GetValue (bonus_info, barrackAdd, AttType.AT_Dodge) +GetValue (bonus_info, type, AttType.AT_Dodge))*0.01
	
	unit_bonus.UnitCritical =(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Critical) +GetValue (bonus_info, barrackAdd, AttType.AT_Critical) +GetValue (bonus_info, type, AttType.AT_Critical))*0.01
	
	unit_bonus.UnitVision = unit_data._unitVisionRadius * (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_WeaponAttackRange) +GetValue (bonus_info, barrackAdd, AttType.AT_WeaponAttackRange) +GetValue (bonus_info, type, AttType.AT_WeaponAttackRange))*0.01)
	
	unit_bonus.UnitSpeed = unit_data._unitSpeed * (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_UnitMoveSpeed) +GetValue (bonus_info, barrackAdd, AttType.AT_UnitMoveSpeed) +GetValue (bonus_info, type, AttType.AT_UnitMoveSpeed))*0.01)

	unit_bonus.GroupNeedBullet = unit_data._unitNeedBullet / (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_GroupNeedBullet) +GetValue (bonus_info, barrackAdd, AttType.AT_GroupNeedBullet) +GetValue (bonus_info, type, AttType.AT_GroupNeedBullet))*0.01)
	return toUnitBonus (unit_bonus)
end

function CalUnitMoveSpeedBonus(type, global)
	local barrackAdd = Barrack.GetAramInfo(type, 1).barrackAdd
    local bonus_info = (global == nil or global == 1) and BonusInfos or BonusInfosCommander
    return (1 +(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_UnitMoveSpeed) +GetValue (bonus_info, barrackAdd, AttType.AT_UnitMoveSpeed) +GetValue (bonus_info, type, AttType.AT_UnitMoveSpeed))*0.01)
end

function CalUnitAttackBonus(type, global)
	local barrackAdd = Barrack.GetAramInfo(type, 1).barrackAdd
    local bonus_info = (global == nil or global == 1) and BonusInfos or BonusInfosCommander
    if type == 101 or type == 102 then
    	return (1 + GetValue (bonus_info, barrackAdd, AttType.AT_AttackValue) + GetValue (bonus_info, type, AttType.AT_AttackValue)) *
		(1 + (GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent) + GetValue (bonus_info, type, AttType.AT_AttackPercent))*0.01)
    end
	return (1 + GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackValue) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackValue) + GetValue (bonus_info, type, AttType.AT_AttackValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_AttackPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_AttackPercent) + GetValue (bonus_info, type, AttType.AT_AttackPercent))*0.01)--+
	--(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_MoraleValue) + GetValue (bonus_info, barrackAdd, AttType.AT_MoraleValue) + GetValue (bonus_info, type, AttType.AT_MoraleValue)) * TableMgr:GetPVEMoraleBonusFactor(type);
end

function CalUnitHPBonus(type, global)
	local barrackAdd = Barrack.GetAramInfo(type, 1).barrackAdd
    local bonus_info = (global == nil or global == 1) and BonusInfos or BonusInfosCommander
    if type == 101 or type == 102 then
    	return (1 +GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) +GetValue (bonus_info, type, AttType.AT_HPValue)) *
		(1 + (GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) +
		(GetValue (bonus_info, barrackAdd, AttType.AT_Physique) +GetValue (bonus_info, type, AttType.AT_Physique)) * TableMgr:GetPVEPhysiqueBonusFactor(type);
    end
	return (1 +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPValue) +GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) +GetValue (bonus_info, type, AttType.AT_HPValue)) *
	(1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Physique) +GetValue (bonus_info, barrackAdd, AttType.AT_Physique) +GetValue (bonus_info, type, AttType.AT_Physique)) * TableMgr:GetPVEPhysiqueBonusFactor(type);
end

function CalUnitPenetrationBonus(type, global)
	local barrackAdd = Barrack.GetAramInfo(type, 1).barrackAdd
    local bonus_info = (global == nil or global == 1) and BonusInfos or BonusInfosCommander
	return (0 +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_PierceValue) +GetValue (bonus_info, barrackAdd, AttType.AT_PierceValue) +GetValue (bonus_info, type, AttType.AT_PierceValue)) * (1 +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_PiercePercent) +GetValue (bonus_info, barrackAdd, AttType.AT_PiercePercent) +GetValue (bonus_info, type, AttType.AT_PiercePercent))*0.01)
end

function CalUnitDefendBonus(type, global)
	local barrackAdd = Barrack.GetAramInfo(type, 1).barrackAdd
    local bonus_info = (global == nil or global == 1) and BonusInfos or BonusInfosCommander
    if type == 101 or type == 102 then
    	return (0 +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue) +GetValue (bonus_info, type, AttType.AT_ArmorValue)) * (1 +
		(GetValue (bonus_info, barrackAdd, AttType.AT_ArmorPercent) +GetValue (bonus_info, type, AttType.AT_ArmorPercent))*0.01) * 0.01
    end
	return (0 +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorValue) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorValue) +GetValue (bonus_info, type, AttType.AT_ArmorValue)) * (1 +
	(GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_ArmorPercent) +GetValue (bonus_info, barrackAdd, AttType.AT_ArmorPercent) +GetValue (bonus_info, type, AttType.AT_ArmorPercent))*0.01) * 0.01
end

function CalGroupBonus (bonus_info, type)
	local groub_bonus = {}
	if BonusInfos == nil then
		return groub_bonus
	end
	local groub_info = TableMgr:GetGroupData (type)
	local bonus_info = BonusInfos  -- CollectBonusInfo ()
	groub_bonus.GroupSummonCD = groub_info._UnitGroupCD * (1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_GroupSummonCD) + GetValue (bonus_info, type,AttType.AT_GroupSummonCD))*0.01)
	return groub_bonus
end

function CalBattleBonus (level_id)
	local level_bonus = {}
	if BonusInfos == nil then
		return level_bonus
    end
	local level_info = TableMgr:GetBattleData (level_id)	
	local bonus_info = BonusInfos   -- CollectBonusInfo ()

	level_bonus.SummonEnergy = level_info.summonEnergy + GetValue (bonus_info, AttBonusType.ABT_Player,AttType.AT_BattleSummonEnergy);
	
	level_bonus.SkillEnergy = level_info.skillEnergy + GetValue (bonus_info, AttBonusType.ABT_Player,AttType.AT_BattleSkillEnergy);
	
	level_bonus.SummonEnergyRecovery = level_info.summonEnergyRecovery *(1+ GetValue (bonus_info, AttBonusType.ABT_Player,AttType.AT_BattleSummonEnergyRecovery)*0.01);
	
	--[[
	level_bonus.attackCoefAddjust = 1
	level_bonus.defenceAddjust = 0
	level_bonus.hpAddjust = 1]]
	return level_bonus
end

function CalCoefBonus()
	local bonus_info = BonusInfos
    local bonus = Serclimax.Unit.ScUnitDefenseCoef ()
    bonus.DamageBonuses1013 =  GetValue4SGL(bonus_info,1013)
    bonus.DamageBonuses1022 =  GetValue4SGL(bonus_info,1022)
    bonus.DamageReduction1021 = GetValue4SGL(bonus_info,1021)
    bonus.DamageReduction1023 = GetValue4SGL(bonus_info,1023)
    return bonus;
end

local TableFunctionlist
local function GetFunction(function_id)
    if TableFunctionlist == nil then
        TableFunctionlist = {}
    end
    if TableFunctionlist[function_id] ~= nil then
        return TableFunctionlist[function_id]
    end
     local func_data = TableMgr:GetBonusFunction (function_id)
     if func_data == nil then 
         return nil
     end
     local f = Global.GetTableFunction("local GV,params = ...; return "..func_data.Function)
     if f == nil then
        print("parser Function Error ===========>",function_id,func_data.Function)
        return nil
     else
        TableFunctionlist[function_id] = f
        return TableFunctionlist[function_id]
    end
end

function CallBonusFunc(function_id,params, global)
    local f =  GetFunction(function_id)
    GetValueGlobal = global
    if f == nil then
        return 0
    else
        return f(GetValueSGL,params)
    end
end



local PVEBattleFightBonusMap

function GetPveBattleFightBonus(p) --curfight/levelfight
    if PVEBattleFightBonusMap == nil then
        local f = loadstring(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PVPBatatleFightRange).value)
        if f == nil then 
            return 
        end
        PVEBattleFightBonusMap = f()
    end
        
    for _, v in ipairs(PVEBattleFightBonusMap) do
       if p>=v.min and p< v.max then
            return v.value
       end        
    end
    return 1
end

function DumpAttributeBonus(path, Ignore_name, global) -- AttributeBonus.DumpAttributeBonus()
	local file = io.open(path or "d:/[DEBUG]AttributeBonus.lua", "w")

    local priorityQueue = PriorityQueue(nil, function(attribute1, attribute2)
    	return attribute1[1] < attribute2[1]
    end)

	local attributes_total = {}
	for i = 1,#(RegisteredModule) do
	    if Ignore_name == nil or CheckName(Ignore_name, RegisteredModule[i]._NAME) then
	    	file:write(string.format("[ %s ]\n", RegisteredModule[i]._NAME))

			local bonuses = RegisteredModule[i]:CalAttributeBonus()

			local attributes = {}

			for _, bonus in pairs(bonuses) do
				local attributeID = Global.GetAttributeLongID(bonus.BonusType, bonus.Attype)

				if attributes[attributeID] then
					attributes[attributeID] = attributes[attributeID] + bonus.Value
				else
					attributes[attributeID] = bonus.Value
				end
            end

           	for attributeID, value in pairs(attributes) do
           		priorityQueue:Push({ attributeID, value })

           		if attributes_total[attributeID] then
					attributes_total[attributeID] = attributes_total[attributeID] + value
				else
					attributes_total[attributeID] = value
				end
		    end

		    while not priorityQueue:IsEmpty() do
		    	local attributeBonus = priorityQueue:Pop()
		    	file:write(string.format("[%9d]\t%.2f\n", attributeBonus[1], attributeBonus[2]))
		    end

		    file:write("\n")
        end
	end
    
    file:write("[ TOTAL ]\n")
    for attributeID, value in pairs(attributes_total) do
    	priorityQueue:Push({ attributeID, value })
    end

	while not priorityQueue:IsEmpty() do
    	local attributeBonus = priorityQueue:Pop()
    	file:write(string.format("[%9d]\t%.2f\n", attributeBonus[1], attributeBonus[2]))
    end

    file:close()
end
