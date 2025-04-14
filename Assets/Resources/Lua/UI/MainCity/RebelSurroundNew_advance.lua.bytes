module("RebelSurroundNew_advance", package.seeall)
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
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter

local _ui, closecallback

local function CloseSelf()
    --_ui.move:SetParent(GUIMgr.UIRoot.transform)
    --coroutine.start(function()
        --coroutine.step()
	    Global.CloseUI(_M)
    --end)
end

local function YieldClose()
    local now = Serclimax.GameTime.GetSecTime()
	local waittime = 0
	local target_btn = MainCityUI.GetRebelSurroundBtn().transform
	if target_btn ~= nil and target_btn.gameObject.activeInHierarchy and not notwait then
		waittime = 1
	end
	local targettime = waittime
	local startpos = transform.position--_ui.container.transform.position
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
    _ui = {}
    _ui.mask = transform:Find("mask").gameObject
    _ui.close = transform:Find("Container/base/close").gameObject
    _ui.container = transform:Find("Container").gameObject
    _ui.title1 = transform:Find("Container/base/title1").transform
    _ui.title2 = transform:Find("Container/base/title2").transform
    _ui.label_time = transform:Find("Container/base/title2/time"):GetComponent("UILabel")
    _ui.label_middle = transform:Find("Container/base/Label02"):GetComponent("UILabel")

    _ui.closepart = {}
	_ui.closepart.guang = transform:Find("Container/guang").gameObject
	_ui.closepart.scale = _ui.container:GetComponent("TweenScale")
	_ui.closepart.alpha = _ui.container:GetComponent("TweenAlpha")
end

function Start()
    SetClickCallback(_ui.mask, YieldClose)
    SetClickCallback(_ui.close, YieldClose)
    local data = RebelSurroundNewData.GetNemesisInfo()
    if data ~= nil then
        if data.pathArriveTime > Serclimax.GameTime.GetSecTime() then
            _ui.title1.gameObject:SetActive(false)
            _ui.title2.gameObject:SetActive(true)
            _ui.move = _ui.label_time.transform
            _ui.label_middle.text = TextMgr:GetText("RebelSurround_new_13")
            CountDown.Instance:Add("RebelSurroundNew_advance", data.pathArriveTime, CountDown.CountDownCallBack(function(t)
                if t == "00:00:00" then
                    _ui.title1.gameObject:SetActive(true)
                    _ui.title2.gameObject:SetActive(false)
                    _ui.move = _ui.title1
                    CountDown.Instance:Remove("RebelSurroundNew_advance")
                end
                _ui.label_time.text = t
            end))
        else
            _ui.label_middle.text = TextMgr:GetText("RebelSurround_new_15")
            _ui.title1.gameObject:SetActive(true)
            _ui.title2.gameObject:SetActive(false)
            _ui.move = _ui.title1
        end
    else
        _ui.title1.gameObject:SetActive(true)
        _ui.title2.gameObject:SetActive(false)
        _ui.move = _ui.title1
    end
end

function Close()
    --[[local movetime = 0
    local targettime = 1
    local startpos = _ui.move.position
    local targetpos = MainCityUI.GetRebelSurroundBtn().transform.position
    local pi = math.pi * 0.5]]
    if closecallback ~= nil then
        closecallback()
        closecallback = nil
    end
    --[[coroutine.start(function()
        while movetime < 0.5 do
            movetime = movetime + Serclimax.GameTime.deltaTime
            local caculatetime = movetime / 0.5
            if _ui.move ~= nil and not _ui.move:Equals(nil) then
                _ui.move.localScale = Vector3.one * (1 + caculatetime * 0.2)
            end
            coroutine.step()
        end
        movetime = 0
        while movetime < targettime do
            movetime = movetime + Serclimax.GameTime.deltaTime
            local caculatetime = movetime / targettime
            if _ui.move ~= nil and not _ui.move:Equals(nil) then
                _ui.move.position = Vector3(Mathf.Lerp(startpos.x, targetpos.x, caculatetime), Mathf.Lerp(startpos.y, targetpos.y, caculatetime), 0)
                _ui.move.localScale = Vector3.one * (1.2 - caculatetime * 0.7)
            end
            coroutine.step()
        end
        if _ui.move ~= nil and not _ui.move:Equals(nil) then
            GameObject.Destroy(_ui.move.gameObject)
        end
        CountDown.Instance:Remove("RebelSurroundNew_advance")
        _ui = nil
    end)]]
    CountDown.Instance:Remove("RebelSurroundNew_advance")
    _ui = nil
end

function Show(callback)
    closecallback = callback
	Global.OpenUI(_M)
end