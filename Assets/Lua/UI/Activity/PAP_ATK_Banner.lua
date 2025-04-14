module("PAP_ATK_Banner", package.seeall)
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

local function YieldClose()
    local now = Serclimax.GameTime.GetSecTime()
	local waittime = 0
	local target_btn = MainCityUI.transform:Find("Container/bg_activity/Grid/RebelArmyWanted")
	print(target_btn.gameObject.activeInHierarchy)
	if target_btn ~= nil and target_btn.gameObject.activeInHierarchy and not notwait then
		waittime = 1
	end
	local targettime = waittime
	local startpos = transform.position--_ui.container.transform.position
	print(waittime)
	if waittime > 0 then
		local bigcollider = NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/BigCollider"))
		local closestar = NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/closed"))
		_ui.mask:SetActive(false)
		_ui.closepart.guang:SetActive(true)
		_ui.closepart.scale.enabled = true
		_ui.closepart.alpha.enabled = true
		coroutine.start(function()
			while waittime > 0 do
				waittime = waittime - Serclimax.GameTime.deltaTime
				--[[local caculatetime = (targettime - waittime) / targettime
				if _ui.container ~= nil and not _ui.container:Equals(nil) then
					_ui.container.transform.position = Vector3(Mathf.Lerp(startpos.x, target_btn.position.x, caculatetime), Mathf.Lerp(startpos.y, target_btn.position.y, caculatetime), 0)
					_ui.container.transform.localScale = Vector3.one * (1 - caculatetime * 0.9)
				end]]
				coroutine.step()
			end
			CloseSelf()
			while waittime < 0.5 do
				waittime = waittime + Serclimax.GameTime.deltaTime
				closestar.transform.position = Vector3(Mathf.Lerp(startpos.x, target_btn.position.x, waittime * 2), Mathf.Lerp(startpos.y, target_btn.position.y, waittime * 2), 0)
				coroutine.step()
			end
			GameObject.DestroyImmediate(closestar)
			GameObject.DestroyImmediate(bigcollider)
		end)
	else
		CloseSelf()
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

	_ui.closepart = {}
	_ui.closepart.guang = transform:Find("Container/guang").gameObject
	_ui.closepart.scale = _ui.container:GetComponent("TweenScale")
	_ui.closepart.alpha = _ui.container:GetComponent("TweenAlpha")
end

function Start()
	SetClickCallback(_ui.container, YieldClose)
	SetClickCallback(_ui.mask, YieldClose)
	SetClickCallback(_ui.btn_close, YieldClose)
	_ui.title.text = TextMgr:GetText("PVP_ATK_Activity_ui9")
	_ui.slaughter_data = ActiveSlaughterData.GetData()
	_ui.title_time.text = _ui.slaughter_data.isOpen and TextMgr:GetText("RebelArmyAttack_ui3") or TextMgr:GetText("RebelArmyAttack_ui2")
    local endTime = 0
	
		if _ui.slaughter_data.isOpen then        
			endTime = _ui.slaughter_data.endTime
		else
			endTime = _ui.slaughter_data.startTime
		end
		if GameTime.GetSecTime() > endTime then
			endTime = GameTime.GetSecTime() + 7200
			print("Error：Server active time error！！！！！！！！！！！！！！！！"..endTime)
		end    
	CountDown.Instance:Add("ATKBanner",endTime,CountDown.CountDownCallBack(function(t)
        _ui.text_time.text = t
        if endTime <= Serclimax.GameTime.GetSecTime() then
        	CloseSelf()
        end
    end))
end

function Close()
	_ui = nil
	CountDown.Instance:Remove("ATKBanner")
end

function Show()
	if _ui == nil then
		_ui = {}
	end
	Global.OpenUI(_M)
end