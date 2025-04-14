module("SoldierEquipBanner", package.seeall)
local GUIMgr = Global.GGUIMgr
local SetClickCallback = UIUtil.SetClickCallback
local ResourceLibrary = Global.GResourceLibrary

local _ui

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
    _ui = nil
end

function Show(title, texture, description, guideId)
    coroutine.start(function()
        local topMenu = GUIMgr:GetTopMenuOnRoot()
		local isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial() or MainCityUI.isSurroundAdvanceActive
		while topMenu == nil or topMenu.name ~= "MainCityUI" or isInGuide do
			coroutine.wait(0.5)
            topMenu = GUIMgr:GetTopMenuOnRoot()
            isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial() or MainCityUI.isSurroundAdvanceActive
        end
        if title ~= nil then
            Global.OpenUI(_M)
            _ui.titleLabel.text = title
            _ui.texture.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", texture)
            _ui.descriptionLabel.text = description
        end
        if guideId ~= nil then
            ActivityGrow.ExtraGuide(guideId)
        end
    end)
	
end

function Awake()
    _ui = {}
    _ui.btn = transform:Find("Container/bg_frane/button").gameObject
    _ui.texture = transform:Find("Container/bg_frane/Texture"):GetComponent("UITexture")
    _ui.titleLabel = transform:Find("Container/bg_frane/bg_top/title/text (1)"):GetComponent("UILabel")
    _ui.descriptionLabel = transform:Find("Container/bg_frane/text_desc"):GetComponent("UILabel")
    SetClickCallback(_ui.btn, CloseSelf)
end
