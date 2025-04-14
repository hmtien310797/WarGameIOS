module("StoryPicture", package.seeall)

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
local AudioMgr = Global.GAudioMgr

local _closeCallback
local _ui

function Hide()
    Global.CloseUI(_M)
    Global.GAudioMgr:PlayMusic("MUSIC_maincity_background", 0.2, true, 1)
    if Notice_Tips.gameObject ~= nil and not Notice_Tips.gameObject:Equals(nil) then
        Notice_Tips.gameObject:SetActive(true)
    end
end

function CloseAll()
    if _ui == nil then
        return
    end
    
    if _ui.id == 1 then
        if Tutorial.TriggerModule(10003) then
        --    return
        end
    end
    if _ui.id == 2 then
        if Tutorial.TriggerModule(10801) then
            return
        end
    end
    if _ui.id == 3 then
        if Tutorial.TriggerModule(10802) then
            return
        end
    end

    _ui.clickCount = _ui.clickCount + 1

    if _ui.clickCount == 1 and _ui.typewriterEffect.isActive then
        _ui.typewriterEffect:Finish()
        return
    end

    if _closeCallback ~= nil then
        _closeCallback()
        _closeCallback = nil
    end
    Hide()
end

function LoadUI()
    _ui.data = tableData_tStoryPicture.data[_ui.id]
    _ui.storyPicture.mainTexture = ResourceLibrary:GetIcon("Icon/Bg/", _ui.data.pic)
    _ui.storyLabel.text = TextMgr:GetText(_ui.data.textID)
    _ui.typewriterEffect:ResetToBeginning()
	Global.GAudioMgr:PlayMusic(_ui.data.music, 0.2, false, 1)
end

function Awake()
    local mask = transform:Find("Container/mask")
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    _ui.storyPicture = transform:Find("Container/Texture"):GetComponent("UITexture")
    _ui.storyLabel = transform:Find("Container/text"):GetComponent("UILabel")
    _ui.typewriterEffect = _ui.storyLabel:GetComponent("TypewriterEffect")
    _ui.clickCount = 0
end

function Start()
    LoadUI()
end

function Close()
    if _ui.id == 1 or id == 2 then
        if _closeCallback ~= nil then
            _closeCallback()
            _closeCallback = nil
        end
    end
    _ui = nil
end

function Show(id, closeCallback)
    print("展示插画:", id)
    Global.OpenUI(_M)
    _ui.id = id
    _closeCallback = closeCallback
    if Notice_Tips.gameObject ~= nil and not Notice_Tips.gameObject:Equals(nil) then
        Notice_Tips.gameObject:SetActive(false)
    end
end
