module("GOV_Help", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
local mode
local closeCallback

HelpModeType={
    GOVMODE = 1,
    TURRETMODE = 2,
    OFFICEMODE = 3,
    PREDICTMODE=4,
    STRONGHOLDMODE= 5,
    FORTRESS = 6,
    ATK = 7,
    CLIMB = 8,
    WorldCup = 9,
    BattleFieldReport = 10,
    ClimpRankHelp = 11,
    SoldierEquipHelp = 12,
    MobaPoint = 13,
    ArenaHelpDesc = 14,
}

local HelpMode ={
    [1]={title="GOV_ui72",des="Gov_Help_text2"},--GOVMODE
    [2]={title="GOV_ui73",des="Gov_Help_text4"},--TURRETMODE
    [3]={title="GOV_ui74",des="Gov_Help_text5"},--OFFICEMODE
    [4]={title="GOV_ui71",des="Gov_Help_text3"},--PREDICTMODE
    [5]={title="StrongholdRule_help",des="StrongholdRule_help_des"},--STRONGHOLD
    [6]={title="FortressRule_help",des="FortressRule_help_des"},--FORTRESS
    [7] ={title="PVP_ATK_Activity_ui9",des="Mail_PVPATK_Help"},
    [8] ={title="Building_15_name",des="Climb_Help"},
    [9] ={title="ActivityAll_20",des="worldcup_001"},
    [10] = {title="ExistTest_24",des="battle_help"},
    [11] = {title="rank_ui7",des="Climb_Rank_Help"},
    [12] = {title="ExistTest_24",des="SoldierEquip_01"},
    [13] = {title="ui_moba_pointtitle",des="ui_moba_pointrule"},
    [14] = {title="Arena_Help_Title",des="Arena_Help_Desc"}
}

function Hide()
    Global.CloseUI(_M)
end

LoadUI = function()
    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end)    
    local m = HelpMode[mode]
    if m ~= nil then
        _ui.title.text = TextMgr:GetText(m.title)
        _ui.des.text = TextMgr:GetText(m.des)
    end
end

function  Awake()
    _ui = {}
    _ui.mask = transform:Find("Container")
    _ui.close = transform:Find("Container/bg_frane/bg_top/btn_close")
    _ui.title =transform:Find("Container/bg_frane/bg_top/title/text (1)"):GetComponent("UILabel")
    _ui.des =transform:Find("Container/bg_frane/Scroll View/text"):GetComponent("UILabel")
    LoadUI()
end

function Show(_mode, _closeCallback)
    mode = _mode    
    closeCallback = _closeCallback
    Global.OpenUI(_M)
end

function Close()   
    _ui = nil
    if closeCallback ~= nil then
        closeCallback()
        closeCallback = nil
    end
end