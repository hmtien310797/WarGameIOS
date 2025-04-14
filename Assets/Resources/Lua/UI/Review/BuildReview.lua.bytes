module("BuildReview",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local BonusInfos, BonusInfosCommander, selfActionStatInfo

local container
OnCloseCB = nil

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

    AT_BattleSummonEnergy = 1000,	--初始弹药加成 1000
    AT_BattleSkillEnergy = 1001,	--初始能量加成 1001
    AT_BattleSummonEnergyRecovery = 1002-- 每秒弹药恢复加成 1002
}

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

function ConstructTime()
    local params = {}
    params.base = 1
    local  result = 1 / AttributeBonus.CallBonusFunc(3 , params) - 1
    return result
end

function ResurechTime()
    local LabInfos = {}
    local lab_table = TableMgr:GetBuildLaboratoryTable()
    for _ , v in pairs(lab_table) do
        local data = v
        if LabInfos[data.BuildLevel] == nil then
            LabInfos[data.BuildLevel] = {}
        end
        LabInfos[data.BuildLevel] = data
    end

    local researchBuild = maincity.GetBuildingByID(6)
    if researchBuild == nil then
        print("there is no research builing")
        return 0
    end

    local params = {}
    params.base = 1
    params.labbuild = LabInfos[researchBuild.data.level].TechAccl
    local result = 1 / AttributeBonus.CallBonusFunc(13 , params) - 1
    return result
end

function GetProtectedResNum() --仓库保护数量
    local building = maincity.GetBuildingByID(2)
    if building == nil or building.data == nil then
        return 0
    else
        local params = {}
        params.base = TableMgr:GetWareData(building.data.level).pvFood
        return AttributeBonus.CallBonusFunc(45 , params)
    end
end

function GetUnionHelpNum()
    local building = maincity.GetBuildingByID(1)
    if building == nil or building.data == nil then
        return 0
    end
    local addnum = BonusInfos[1095] == nil and 0 or BonusInfos[1095]
    return addnum + TableMgr:GetBuildCoreDataByLevel(building.data.level).helpTime
end

function GetUnionHelpTime()
    return BonusInfos[1087] == nil and 1 or (BonusInfos[1087]/60 + 1)
end

function GetEmbassyTotal()
    local building = maincity.GetBuildingByID(42)
    if building == nil then
        return 0
    end
    local curEmbassyData = TableMgr:GetEmbassyData(building.data.level)
    return curEmbassyData.armynum * (1 + 0.01 * (BonusInfos[1097] ~= nil and BonusInfos[1097] or 0)) + (BonusInfos[1093] ~= nil and BonusInfos[1093] or 0)
end

function GetWarHallTotal()
    local building = maincity.GetBuildingByID(43)
    if building == nil then
        return 0
    end
    local AssembledData = TableMgr:GetAssembledData(building.data.level)
    return AssembledData.armynum
end

function GetTradeNum()
    local building = maincity.GetBuildingByID(41)
    if building == nil then
        return 0
    end
    tradedata = TableMgr:GetTradingPostData(building.data.level)
    return tradedata.resNum
end

function GetTradeRate()
    local building = maincity.GetBuildingByID(41)
    if building == nil then
        return 0
    end
    tradedata = TableMgr:GetTradingPostData(building.data.level)
    return (tradedata.rate - (BonusInfos[1089] ~= nil and BonusInfos[1089] or 0)) * 0.01
end

function GetResRate(functionid)
    local params = {}
    params.base = 1
    return AttributeBonus.CallBonusFunc(functionid , params) - 1
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
        (1 + (GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) 
    end
--[[	print(type,GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPValue),
	GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) ,
	GetValue (bonus_info, type, AttType.AT_HPValue),
	GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent),
	GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent),
	GetValue (bonus_info, type, AttType.AT_HPPercent),
    GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Physique),
	GetValue (bonus_info, barrackAdd, AttType.AT_Physique),GetValue (bonus_info, type, AttType.AT_Physique),
	TableMgr:GetPVEPhysiqueBonusFactor(type),(1 +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPValue) +GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) +GetValue (bonus_info, type, AttType.AT_HPValue)) *
    (1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01) +
    (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_Physique) +GetValue (bonus_info, barrackAdd, AttType.AT_Physique) +GetValue (bonus_info, type, AttType.AT_Physique)) * TableMgr:GetPVEPhysiqueBonusFactor(type))
	]]--
    return (1 +GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPValue) +GetValue (bonus_info, barrackAdd, AttType.AT_HPValue) +GetValue (bonus_info, type, AttType.AT_HPValue)) *
    (1 + (GetValue (bonus_info, AttBonusType.ABT_ALL, AttType.AT_HPPercent) + GetValue (bonus_info, barrackAdd, AttType.AT_HPPercent) + GetValue (bonus_info, type, AttType.AT_HPPercent))*0.01)
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

function GetBonus(bonus,attr,percent,global)
    local value
    if global == nil or global == 1 then
        value = BonusInfos[bonus * 10000 + attr]
    else
        value = BonusInfosCommander[bonus * 10000 + attr]
    end
    if value == nil then
        return 0
    else
        if percent == 1 then
            return value * 0.01
        else
            return value
        end
    end
end

function GetJailBonus()
    local s, v = JailInfoData.GetBuffNameValue()
    return v / 100
end

function GetMaxRobRes()
    local building = maincity.GetBuildingByID(43)
    if building ~= nil then
        return tableData_tAssembled.data[building.data.level].ResourceMax
    else
        return tonumber(tableData_tGlobal.data[100225].value)
    end
end

function Awake()
    container = {}
    container.mask = transform:Find("mask").gameObject
    container.btn_close = transform:Find("Container/review_frane/review_top/btn_close"):GetComponent("UIButton")
    container.grid = transform:Find("Container/review_frane/Scroll View/Grid"):GetComponent("UIGrid")
    container.scrollview = transform:Find("Container/review_frane/Scroll View"):GetComponent("UIScrollView")
    container.heading = transform:Find("message_list")
    container.tittle = transform:Find("heading_list")
end

function TestFunc()
    local str = ""
    return 0
end

function formatValue(_format  , value)
    if type(value) == "string" then
        return value
    end
    if value == nil then
        return 0
    end
    local result = 0 
    if _format == 1 then
        if value > 0 then
            result = "+" .. System.String.Format("{0:P1}" , value)
        elseif value < 0 then
            result = System.String.Format("{0:P1}" , value)
        else

        end
    elseif _format == 2 then
        if value > 0 then
            result = System.String.Format("{0:P1}" , value)
        elseif value < 0 then
            result = System.String.Format("{0:P1}" , value)
        else

        end
    else
        result = Global.FormatNumber(math.floor(value))
    end
    return result
end

function Start()
    local ignore = {"SelectArmy", "BattleMove"}
    BonusInfos, BonusInfosCommander = AttributeBonus.CollectBonusInfo(ignore, true)

    SetClickCallback(container.mask, function()
        GUIMgr:CloseMenu("BuildReview")
    end)

    SetClickCallback(container.btn_close.gameObject, function()
        GUIMgr:CloseMenu("BuildReview")
    end)

    local reviewData = TableMgr:GetBuildReviewData()
    --print(reviewData.Length)
    local bodyIndex = 0
    for i , v in kpairs(reviewData) do
        local v = reviewData[i]
        if v.otherInfo ~= "" then
            if v.otherInfo == "Title" then
                local titleTransform = NGUITools.AddChild(container.grid.gameObject , container.tittle.gameObject).transform
                titleTransform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(v.revtext)
                bodyIndex = 0
            else
                local bodyTransform = NGUITools.AddChild(container.grid.gameObject , container.heading.gameObject).transform
                bodyTransform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(v.revtext)
                local otherValue = selfActionStatInfo[v.otherInfo] or 0
                bodyTransform:Find("number"):GetComponent("UILabel").text = BuildReview.formatValue(v.valueShow, otherValue)
                bodyTransform:Find("bg_list").gameObject:SetActive(bodyIndex % 2 ~= 0)
                bodyIndex = bodyIndex  + 1
            end
        elseif v.revtype == 1 then --tittle
            local titleItem = NGUITools.AddChild(container.grid.gameObject , container.tittle.gameObject)
            titleItem.transform:SetParent(container.grid.transform , false)
            titleItem.gameObject:SetActive(true)

            local title1 = titleItem.transform:Find("text"):GetComponent("UILabel")
            title1.text = TextMgr:GetText(v.revtext)

            if v.value1 ~= nil and v.value1 ~= "" then
                local title2 = titleItem.transform:Find("hero_effect"):GetComponent("UILabel")
                title2.gameObject:SetActive(true)
                title2.text = TextMgr:GetText(v.value1)
            end
            bodyIndex = 0
        else
            local reviewItem = NGUITools.AddChild(container.grid.gameObject , container.heading.gameObject)
            reviewItem.transform:SetParent(container.grid.transform , false)
            reviewItem.gameObject:SetActive(true)

            local title = reviewItem.transform:Find("text"):GetComponent("UILabel")
            title.text = TextMgr:GetText(v.revtext)

            local value1 = reviewItem.transform:Find("number"):GetComponent("UILabel")
            local func = "return " .. v.value1
            value1.text = formatValue( v.valueShow,  Global.GetTableFunction(func)())

            --print(title.text .. ":" .. Global.GetTableFunction(func)() .. " format:" .. value1.text)
            if v.value2 ~= nil and  v.value2 ~= "" then
                local value2 = reviewItem.transform:Find("hero_effect"):GetComponent("UILabel")
                value2.gameObject:SetActive(true)
                local func = "return " .. v.value2
                value2.text = formatValue( v.valueShow, Global.GetTableFunction(func)())
            end

            local bglisrt = reviewItem.transform:Find("bg_list")
            bglisrt.gameObject:SetActive(bodyIndex % 2 ~= 0)
            bodyIndex = bodyIndex  + 1
        end
    end
    container.grid:Reposition()

end

function Close()
    if OnCloseCB ~= nil then
        OnCloseCB()
        OnCloseCB = nil
    end
end

function Show()
    local req = ClientMsg_pb.MsgGetUserActionStatInfoRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetUserActionStatInfoRequest, req, ClientMsg_pb.MsgGetUserActionStatInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            selfActionStatInfo = msg.statInfo
            Global.OpenUI(_M)
        else
            Global.ShowError(msg.code)
        end
    end)
end
