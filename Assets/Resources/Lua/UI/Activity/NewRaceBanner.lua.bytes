module("NewRaceBanner", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local GameObject = UnityEngine.GameObject

local _ui
local timer = 0
local closeCallback

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function Awake()
    local mask = transform:Find("Container")
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    local btn_close = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(btn_close.gameObject, CloseAll)
    _ui = {}

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()

end

function Close()
    if closeCallback ~= nil then
        closeCallback()
        closeCallback = nil
    end
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show(callback)
    local data = NewRaceData.GetData()
    if data == nil or data.actId ==0 or data.actId > 5 or data.maxId == UnityEngine.PlayerPrefs.GetInt("NewRace" .. MainData.GetCharId()) then
        if callback ~= nil then
            callback()
        end
        return
    else
        coroutine.start(function()
            local topMenu = GUIMgr:GetTopMenuOnRoot()
            local isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
            while topMenu == nil or topMenu.name ~= "MainCityUI" or isInGuide do
                coroutine.wait(0.5)
                topMenu = GUIMgr:GetTopMenuOnRoot()
                isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
            end
            closeCallback = callback
            Global.OpenUI(_M)
            UnityEngine.PlayerPrefs.SetInt("NewRace" .. MainData.GetCharId(), data.maxId)
            UnityEngine.PlayerPrefs.Save()
        end)
    end
end
