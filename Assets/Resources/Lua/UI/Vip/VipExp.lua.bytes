module("VipExp", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local UIAnimMgr = Global.GUIAnimMgr

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetDragCallback = UIUtil.SetDragCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui, logininfo

local closeCallback
function SetCloseCallback(callback)
    closeCallback = callback
end

local function CloseSelf()
	local itemData = TableMgr:GetItemData(15)
    local itemIcon = ResourceLibrary:GetIcon("Item/", itemData.icon)
    FloatText.Show(TextUtil.GetItemName(itemData) .. "x" .. logininfo.todayObtain, Color.green, itemIcon)

	Global.CloseUI(_M)
	if closeCallback ~= nil then
        closeCallback()
        closeCallback = nil
    end
end

function Close()
	_ui = nil
	logininfo = nil
end

function Show(_closeCallback)
	logininfo = VipData.GetLoginInfo()

	-- if not logininfo.pop then
	-- 	if closeCallback ~= nil then
	--         closeCallback()
	--         closeCallback = nil
	--     end
	-- 	return
	-- end

	if logininfo.pop then
		FunctionListData.IsFunctionUnlocked(5, function(isactive)
			if isactive then
				closeCallback = _closeCallback
		 		Global.OpenUI(_M)
			end
		end)
	end
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/btn_close").gameObject
	_ui.level = transform:Find("Container/bg_frane/bg_vip/frame"):GetComponent("UITexture")
	_ui.get = transform:Find("Container/bg_frane/bg_mid/text"):GetComponent("UILabel")
	_ui.login = transform:Find("Container/bg_frane/bg_mid/text (1)"):GetComponent("UILabel")
	_ui.nextday = transform:Find("Container/bg_frane/bg_mid/text (2)"):GetComponent("UILabel")
	_ui.btn_ok = transform:Find("Container/bg_frane/btn_pay").gameObject
end

function Start()
	logininfo.pop = false
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.btn_ok, CloseSelf)
	SetClickCallback(_ui.mask, CloseSelf)
	_ui.level.mainTexture = ResourceLibrary:GetIcon("pay/" ,"icon_vip" .. MainData.GetVipLevel())
	_ui.get.text = String.Format(TextMgr:GetText("VIP_ui108"), logininfo.todayObtain)
	_ui.login.text = String.Format(TextMgr:GetText("VIP_ui103"), logininfo.continuousDays)
	_ui.nextday.text = String.Format(TextMgr:GetText("VIP_ui102"), logininfo.tomorrowObtain)
end
