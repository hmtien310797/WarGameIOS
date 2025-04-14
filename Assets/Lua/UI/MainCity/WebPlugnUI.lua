module("WebPlugnUI",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local SetClickCallback = UIUtil.SetClickCallback
local SetPressCallback = UIUtil.SetPressCallback
local SetDragCallback = UIUtil.SetDragCallback

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui, _url

function Hide()
    _ui.plugn:Hide(function() Global.CloseUI(_M) end)
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/btn_close").gameObject
    _ui.btn_go = transform:Find("Container/btn_go").gameObject
    _ui.label_url = transform:Find("Container/Sprite/Label"):GetComponent("UILabel")
    _ui.label_url_input = transform:Find("Container/Sprite/Label"):GetComponent("UIInput")
    _ui.plugn = transform:Find("Container"):GetComponent("WebMediator")
end

local function OpenUrl()
    _ui.plugn:SetMargin(0, transform:Find("Container/Sprite"):GetComponent("UISprite").height * UnityEngine.Screen.height / 640, 0, 0)
    _ui.plugn:Show(_ui.label_url.text)
end

function Start()
    SetClickCallback(_ui.btn_close, Hide)
    SetClickCallback(_ui.btn_go, OpenUrl)
    if _url ~= nil then
        _ui.label_url.text = _url
        _ui.label_url_input.value = _url
    end
    OpenUrl()
end

function Close()
    _ui = nil
    _url = nil
end

function Show(url)
    _url = url
    Global.OpenTopUI(_M)
end