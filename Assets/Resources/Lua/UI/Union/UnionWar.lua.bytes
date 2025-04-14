module("UnionWar", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    if _ui ~= nil then
        if _ui.massTroopTab.cur_select_index >= 10 then
            _ui.massTroopTab:CloseDetail()
        else
            Hide()
        end
    end
end

function GetMassTroopTab()
    if _ui ~= nil then
        return _ui.massTroopTab
    end
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/background widget/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui.massTroopTrf = transform:Find("Container/bg2/content 2")
    _ui.massTroopTab = MassTroops(_ui.massTroopTrf)
    _ui.massTroopTab:Open()        
end

function Close()
    _ui.massTroopTab:Close()
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end
