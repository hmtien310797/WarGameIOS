module("SoldierProduction", package.seeall)
local _ui

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("container/bg_frane/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
end

function Show()
    Global.OpenUI(_M)
end
