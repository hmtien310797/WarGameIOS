module("HeroUnlock", package.seeall)

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function LoadUI()
    OneCardDisplay.LoadReward(_ui.reward, _ui.heroMsg)
end

function Awake()
    _ui = {}
    _ui.reward = {}
    local rewardTransform = transform:Find("NewHeroShow")
    OneCardDisplay.LoadRewardObject(_ui.reward, rewardTransform)
    UIUtil.SetClickCallback(_ui.reward.maskTransform.gameObject, CloseAll)
end

function Close()
    _ui = nil
end

function Show(heroMsg)
    Global.OpenUI(_M)
    _ui.heroMsg = heroMsg
    LoadUI()
end
