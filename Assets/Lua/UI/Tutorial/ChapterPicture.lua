module("ChapterPicture", package.seeall)

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
end

function CloseAll()
    if _closeCallback ~= nil then
        _closeCallback()
        _closeCallback = nil
    end
    Hide()
end

function LoadUI()
    for i, v in ipairs(_ui.chapterList) do
        v.nameLabel.gameObject:SetActive(i == _ui.chapterIndex)
    end
end

function Awake()
    local mask = transform:Find("Container/mask")
    _ui = {}
    local chapterList = {}
    for i = 1, 99 do
        if transform:Find("Container/text" .. i) ~= nil then
            local chapter = {}
            chapter.nameLabel = transform:Find("Container/text" .. i):GetComponent("UILabel")
            chapterList[i] = chapter
        end
    end
    _ui.chapterList = chapterList
    _ui.tweenAlpla = transform:Find("Container"):GetComponent("TweenAlpha")
    _ui.tweenAlpla:SetOnFinished(EventDelegate.Callback(CloseAll))
end


function Close()
    _ui = nil
end

function Show(chapterIndex, closeCallback)
    Global.OpenUI(_M)
    _ui.chapterIndex = chapterIndex
    _closeCallback = closeCallback
    LoadUI()
end
