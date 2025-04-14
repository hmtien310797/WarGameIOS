module("RebelSurround_spy",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String


local _ui
local Attack
local formation
local SetoutArmy

local ArmyCountStr ={
    "Container/bg_left/bg_resource/bg_food/txt_food",
    "Container/bg_left/bg_resource/bg_oil/txt_oil",
    "Container/bg_left/bg_resource/bg_iron/txt_iron",
    "Container/bg_left/bg_resource/bg_electric/txt_electric",
}

local ArmyId = {
    1001,
    1003,
    1002,
    1004,

}

function Awake()
    RebelSurround.Scout()
    _ui = {}
    _ui.Close = transform:Find("Container/close btn")
    SetClickCallback(_ui.Close.gameObject,function()
        Hide()
    end)  

    _ui.Mask = transform:Find("mask")
    if _ui.Mask ~= nil then
        SetClickCallback(_ui.Mask.gameObject,function()
            Hide()
        end)        
    end

    _ui.ArmyCount = {}
    
    for i=1,4 do
        _ui.ArmyCount[ArmyId[i]] = transform:Find(ArmyCountStr[i]):GetComponent("UILabel")
        _ui.ArmyCount[ArmyId[i]].text = 0
    end

    for i=1 ,#SetoutArmy.army.army do
        _ui.ArmyCount[SetoutArmy.army.army[i].armyId].text = SetoutArmy.army.army[i].num
    end
    
    
    _ui.Formation = BMFormation(transform:Find("Container/bg_left/bg_formation/Embattle"))
    local f =""
    for i=1,#formation do
        f = f..formation[i]..","
    end
    print("formation",f)
    f =""
    local targetFormation = SetoutArmy.formation.form
    for i=1,#targetFormation do
        f = f..targetFormation[i]..","
    end    
    print("targetFormation",f)

    if Attack then
        _ui.Formation:SetLeftFormation(formation)
        _ui.Formation:SetRightFormation(targetFormation)
    else
        _ui.Formation:SetLeftFormation(targetFormation)
        _ui.Formation:SetRightFormation(formation)
    end

    _ui.Formation:Awake()    
end

function Start()
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
	_ui = nil
end

function Show(attack,setoutArmy,callback)
    SetoutArmy = setoutArmy
    Attack = attack
    if Attack then
        BattleMoveData.GetOrReqUserAttackFormaion(function(_formation) 
            formation = _formation
            if callback ~= nil then
                callback()
            end
            Global.OpenUI(_M)
        end)
    else
        BattleMoveData.GetOrReqUserDefendFormaion(function(_formation) 
            formation = _formation
            if callback ~= nil then
                callback()
            end
            Global.OpenUI(_M)	
        end)
    end
end
