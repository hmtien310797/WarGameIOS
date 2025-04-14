module("update",package.seeall)

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
local btn_cancel
local btn_confirm
local btn_stop
local bg_schedule
local bg_slider
local bg_txt

local isCancel = false

function Awake()
	main_text = transform:Find("bg_update/bg/text"):GetComponent("UILabel")
	btn_cancel = transform:Find("bg_update/bg/btn_cancel").gameObject
	btn_confirm = transform:Find("bg_update/bg/btn_confirm").gameObject
	btn_stop = transform:Find("bg_update/bg/btn_stop").gameObject
	bg_schedule = transform:Find("bg_update/bg/bg_schedule").gameObject
	bg_slider = transform:Find("bg_update/bg/bg_schedule/bg_slider"):GetComponent("UISlider")
	bg_txt = transform:Find("bg_update/bg/bg_schedule/bg_txt"):GetComponent("UILabel")
end

local function OnCheckPercent(value)
	bg_slider.value = value
end

local function OnBundleLoad(value)
	bg_txt.text = value
end

local function IsChecking(value)
	if isCancel then
		bg_schedule:SetActive(false)
		btn_cancel:SetActive(true)
		btn_confirm:SetActive(true)
		main_text.text = System.String.Format(TextMgr:GetText("ui_update1"), AssetBundleManager.Instance:GetNeedLoadSize())
		MessageBox.Show(TextMgr:GetText("ui_update3"))
		isCancel = false
		return
	end
	if not value then
		MessageBox.Show(TextMgr:GetText("ui_update2"))
		UnityEngine.PlayerPrefs.DeleteKey("NeedRemote")
        UnityEngine.PlayerPrefs.Save()
		MainCityUI.HideUpdateBtn()
		GUIMgr:CloseMenu("update")
	end
end

function Start()
	SetClickCallback(btn_cancel,function(go)
		GUIMgr:CloseMenu("update")
	end)
	main_text.text = System.String.Format(TextMgr:GetText("ui_update1"), AssetBundleManager.Instance:GetNeedLoadSize())
	
	SetClickCallback(btn_confirm,function(go)
		bg_schedule:SetActive(true)
		btn_stop:SetActive(true)
		btn_cancel:SetActive(false)
		btn_confirm:SetActive(false)
		AssetBundleManager.Instance:DownLoadRemote()
	end)
	
	SetClickCallback(btn_stop, function(go)
		btn_stop:SetActive(false)
		AssetBundleManager.Instance:StopDownLoad()
		isCancel = true
	end)
	bg_slider.value = 0
	bg_txt.text = "0%"
	AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent + OnCheckPercent
	AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad + OnBundleLoad
	AssetBundleManager.Instance.isChecking = AssetBundleManager.Instance.isChecking + IsChecking
end

function Close()
	AssetBundleManager.Instance.onCheckPercent = AssetBundleManager.Instance.onCheckPercent - OnCheckPercent
	AssetBundleManager.Instance.onBundleLoad = AssetBundleManager.Instance.onBundleLoad - OnBundleLoad
	AssetBundleManager.Instance.isChecking = AssetBundleManager.Instance.isChecking - IsChecking
end