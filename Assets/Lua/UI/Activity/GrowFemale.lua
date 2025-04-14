module("GrowFemale", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local Format = System.String.Format
local GameTime = Serclimax.GameTime

local textList
local callback
local _ui

function Hide()
    Global.CloseUI(_M)
    callback = nil
end

local function Talk()
    for i, v in ipairs(textList) do
        _ui.talkLabel.text = v
        _ui.talkEffect:ResetToBeginning()
        coroutine.yield()
        if callback ~= nil then
            callback(i)
        end
    end

    Hide()
end

function Awake()
    _ui = {}
    local mask = transform:Find("Container/mask").gameObject
    SetClickCallback(mask, function()
        coroutine.resume(_ui.talkCoroutine)
    end)

    _ui.talkLabel = transform:Find("Container/bg_left person/bg/text_guide"):GetComponent("UILabel")
    _ui.talkEffect = transform:Find("Container/bg_left person/bg/text_guide"):GetComponent("TypewriterEffect")
end

function Close()
    _ui = nil
end

function Show(_textList, _callback)
    textList = _textList
    callback = _callback
    Global.OpenTopUI(_M)
    _ui.talkCoroutine = coroutine.create(Talk)
    coroutine.resume(_ui.talkCoroutine)
end
