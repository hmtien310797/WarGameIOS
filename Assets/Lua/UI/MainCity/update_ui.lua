module("update_ui",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local main_text
local bg_slider
local bg_txt

local isCancel = false

function Awake()
	main_text = transform:Find("bg_update/bg/text"):GetComponent("UILabel")
	bg_slider = transform:Find("bg_update/bg/bg_schedule/bg_slider"):GetComponent("UISlider")
	bg_txt = transform:Find("bg_update/bg/bg_schedule/bg_txt"):GetComponent("UILabel")
end

function OnCheckPercent(value)
	bg_slider.value = value
end

function OnBundleLoad(value)
	bg_txt.text = value
end

function Start()
	main_text.text = System.String.Format(TextMgr:GetText("ui_update_dec1"), AssetBundleManager.Instance:GetNeedLoadSize())
	bg_slider.value = 0
	bg_txt.text = "0%"
end

function Close()
	main_text = nil
	bg_slider = nil
	bg_txt = nil
end