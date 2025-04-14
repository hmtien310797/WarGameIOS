module("GOVBanner", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameTime = Serclimax.GameTime
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui

local closeCallback
function SetCloseCallback(callback)
    closeCallback = callback
end

local function CloseSelf()
	Global.CloseUI(_M)
	if closeCallback ~= nil then
        closeCallback()
        closeCallback = nil
    end
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	
	_ui.title = transform:Find("Container/bg_frane/bg_top/title/text (1)"):GetComponent("UILabel")
	_ui.texture = transform:Find("Container/bg_frane/Texture"):GetComponent("UITexture")
	_ui.title_time = transform:Find("Container/bg_frane/bg_desc/title_time"):GetComponent("UILabel")
	_ui.text_time = transform:Find("Container/bg_frane/bg_desc/text_time"):GetComponent("UILabel")
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	_ui.title.text = TextMgr:GetText("GovernmentWar_1")
	local govstate = GovernmentData.GetGOVState()
	local govActInfo = GovernmentData.GetGOVActInfo()
    local endTime = 0
	_ui.title_time.text = govstate == 2 and TextMgr:GetText("RebelArmyAttack_ui3") or TextMgr:GetText("RebelArmyAttack_ui2")
    local endTime = 0
	
		if govstate == 1 then        
			endTime = govActInfo.contendStartTime
		elseif govstate == 2 then
			endTime = govActInfo.contendEndTime
		end
		if GameTime.GetSecTime() > endTime then
			endTime = GameTime.GetSecTime() + 7200
			print("Error：Server active time error！！！！！！！！！！！！！！！！"..endTime)
		end    
	CountDown.Instance:Add("GOVBanner",endTime,CountDown.CountDownCallBack(function(t)
        _ui.text_time.text = t
        if endTime <= Serclimax.GameTime.GetSecTime() then
        	CloseSelf()
        end
    end))
end

function Close()
	_ui = nil
	CountDown.Instance:Remove("GOVBanner")
end

function Show(msg)
	if _ui == nil then
		_ui = {}
	end
	_ui.msg = msg
	Global.OpenUI(_M)
end