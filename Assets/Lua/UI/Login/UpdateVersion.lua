module("UpdateVersion", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime

local updateText
local updateUrl
local exeUpdate

function Hide()
    Global.CloseUI(_M)
    Global.GGameStateLogin:CancelUpdateVersion()
end

function Awake()
    local updateLabel = transform:Find("Update/bg_frane/bg_mid/Scroll View/doc"):GetComponent("UILabel")
    updateLabel.text = updateText
    local cancelButton = transform:Find("Update/bg_frane/btn_cancel")
    local closeButton = transform:Find("Update/bg_frane/bg_top/btn_close")
    local confirmButton = transform:Find("Update/bg_frane/btn_confirm")
    local okButton = transform:Find("Update/bg_frane/btn_ok")

    cancelButton.gameObject:SetActive(not exeUpdate)
    confirmButton.gameObject:SetActive(not exeUpdate)
    okButton.gameObject:SetActive(exeUpdate)
	
	local btnokLabel = transform:Find("Update/bg_frane/btn_ok/text_confirm"):GetComponent("UILabel")
	local btncancelLabel = transform:Find("Update/bg_frane/btn_cancel/text_cancel"):GetComponent("UILabel")
	local btnconfirmLabel = transform:Find("Update/bg_frane/btn_confirm/text_confirm"):GetComponent("UILabel")
	
	if not exeUpdate then 
		btnconfirmLabel:GetComponent("LocalizeEx").enabled = false
		btnconfirmLabel.text = TextMgr:GetText("ui_update_hint5")
		btncancelLabel:GetComponent("LocalizeEx").enabled = false
		btncancelLabel.text = TextMgr:GetText("ui_update_hint3")
	end 
	

    SetClickCallback(cancelButton.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(confirmButton.gameObject, function()
        UnityEngine.Application.OpenURL(updateUrl)
    end)
    SetClickCallback(okButton.gameObject, function()
        UnityEngine.Application.OpenURL(updateUrl)
    end)
end

function Show(text, url, isExeUpdate)
    updateText = text
    updateUrl = url
    exeUpdate = isExeUpdate

    Global.OpenTopUI(_M)
end
