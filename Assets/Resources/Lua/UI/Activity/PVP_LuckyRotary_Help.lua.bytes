module("PVP_LuckyRotary_Help", package.seeall)
function Hide()
    Global.CloseUI(_M)
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
end

function Show()
    Global.OpenUI(_M)
end
