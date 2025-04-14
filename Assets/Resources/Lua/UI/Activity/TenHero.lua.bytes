module("TenHero", package.seeall)
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
local Format = System.String.Format

local _ui 
function Hide()
    Global.CloseUI(_M)
end

function HideAll()
    WelfareAll.Hide()
end

local function UpdateTime()
    _ui.timerLabel.text, _ui.leftSecond = Global.GetLeftCooldownTextLong(ActivityData.GetActivityConfig(_ui.activityId).endTime)
    if _ui.leftSecond <= 0 then
        HideAll()
    end
end

local function LoadUI()
    UpdateTime()
end

function Refresh()
    LoadUI()
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    local goObject = transform:Find("Container/bg_frane/mid/record").gameObject
    SetClickCallback(goObject, function(go)
        HideAll()
        MilitarySchool.Show()
    end)
    _ui.timerLabel = transform:Find("Container/bg_frane/mid/Sprite_time/time"):GetComponent("UILabel")
    _ui.timer = Timer.New(UpdateTime, 1, -1)
    _ui.timer:Start()
    _ui.mask = transform:Find("mask").gameObject
    SetClickCallback(_ui.mask, HideAll)
end

function Close()
    _ui.timer:Stop()
    _ui = nil
end

function Show(activityId)
    Global.OpenUI(_M)
    _ui.activityId = activityId
    LoadUI()
end
