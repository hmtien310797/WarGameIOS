module("ExistTestNotice", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local String = System.String
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _ui, hasshowed

local function CloseSelf()
	Global.CloseUI(_M)
end

local function YieldClose()
    local now = Serclimax.GameTime.GetSecTime()
	local waittime = 0
	local target_btn = MainCityUI.transform:Find("Container/bg_activityleft/Grid/btn_existtest")
	print(target_btn.gameObject.activeInHierarchy)
	if target_btn ~= nil and target_btn.gameObject.activeInHierarchy and not notwait then
		waittime = 1
	end
	local targettime = waittime
	local startpos = transform.position
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

function Close()
    CountDown.Instance:Remove("ExistTestNotice")
    if _ui.closecallback ~= nil then
        _ui.closecallback()
    end
    _ui = nil
    coroutine.start(function()
        coroutine.wait(60)
        hasshowed = nil
    end)
end

function Awake()
    _ui.mask = transform:Find("mask").gameObject
    _ui.container = transform:Find("Container")
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.timelabel = transform:Find("Container/bg_frane/bg_desc/text_time"):GetComponent("UILabel")
    _ui.closepart = {}
	_ui.closepart.guang = transform:Find("Container/guang").gameObject
	_ui.closepart.scale = _ui.container:GetComponent("TweenScale")
	_ui.closepart.alpha = _ui.container:GetComponent("TweenAlpha")
end

function Start()
    SetClickCallback(_ui.container.gameObject, YieldClose)
    SetClickCallback(_ui.btn_close, YieldClose)
    ExistTestData.CheckSurvivalUserRankList()
    CountDown.Instance:Add("ExistTestNotice", _ui.data.endTime, function(t)
	    if _ui.data.endTime <= Serclimax.GameTime.GetSecTime() then
            CloseSelf()
        else
            _ui.timelabel.text = t
	    end
	end)
end

function Show(closecallback)
    if hasshowed == true then
        return
    end
    hasshowed = true
    _ui = {}
    _ui.closecallback = closecallback
    _ui.data = ActivityData.GetExistTestActivity()
    if _ui.data ~= nil and _ui.data.endTime > Serclimax.GameTime.GetSecTime() then
        Global.OpenUI(_M)
    else
        if closecallback ~= nil then
            closecallback()
        end
    end
end