module("RebelSurround_TileInfo",package.seeall)

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


function Awake()
    _ui = {}
    _ui.Mask = transform:Find("mask")
    if _ui.Mask ~= nil then
        SetClickCallback(_ui.Mask.gameObject,function()
            Hide()
        end)        
    end
    _ui.Reconnaissance = transform:Find("MonsterInfo/bg_info/btn_1")
    SetClickCallback(_ui.Reconnaissance.gameObject,function()
        local data = RebelSurroundData.GetData()
        local attack = data.levelInfo.waveInfos[data.curWave].type == 2
        RebelSurround_spy.Show(attack,data.levelInfo.waveInfos[data.curWave].army,function()
            Hide()
        end)
        
    end)     
    _ui.Attack = transform:Find("MonsterInfo/bg_info/btn_2")
    SetClickCallback(_ui.Attack.gameObject,function(go)
        RebelSurround.FightBack(go,function() Hide() end)
        --Hide()
    end)      
    _ui.Name = transform:Find("MonsterInfo/bg_info/txt_name"):GetComponent("UILabel")
    local data = RebelSurroundData.GetData()
    _ui.Name.text = TextMgr:GetText("RebelSurroundname_"..data.curLevel)
    local md = RebelSurround.GetMonsterIdsData()
    if md ~= nil then
        local artSettingData = TableMgr:GetArtSettingData(md[data.curLevel])
        _ui.icon = transform:Find("MonsterInfo/bg_info/icon_castle"):GetComponent("UITexture")  
        _ui.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", artSettingData.icon)      
    end

end

function Start()
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
	_ui = nil
end

function Show()
	Global.OpenUI(_M)	
end
