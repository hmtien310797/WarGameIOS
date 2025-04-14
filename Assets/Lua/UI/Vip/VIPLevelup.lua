module("VIPLevelup", package.seeall)
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
local String = System.String

local _ui, UpdateUI
local before, now, isExperience, time
local efunlevel = {1,2,3,5}
local showTimedBag_VIP

local closeCallback
function SetCloseCallback(callback)
    closeCallback = callback
end

local function CloseSelf()
	Global.CloseUI(_M)
	if showTimedBag_VIP then
		showTimedBag_VIP = nil
		TimedBag_VIP.Show()
	end
	if closeCallback ~= nil then
        closeCallback()
        closeCallback = nil
    end
end

function Close()
	_ui = nil
	CountDown.Instance:Remove("viplevelup")
end

--_isExperience 不传为正常VIP升级 1表示VIP体验前 2表示VIP体验后
--time 体验时间
function Show(_before, _now, _isExperience, _time)
	isExperience = _isExperience
	time =_time
	before = _before
	now = _now
	-- if now == 0 then
	-- 	return
	-- end
	for i,v in ipairs(efunlevel) do
		if before < v and now >= v then
			GUIMgr:SendDataReport("efun", "v"..v)
		end
	end
	Global.OpenUI(_M)
	AttributeBonus.CollectBonusInfo()
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Levelup").gameObject
	_ui.btn_close = transform:Find("Levelup/bg_frane/bg_top/btn_close").gameObject
	_ui.vipleft = transform:Find("Levelup/bg_frane/bg_vip/bg_vip_left/frame"):GetComponent("UITexture")
	_ui.vipright = transform:Find("Levelup/bg_frane/bg_vip/bg_vip_right/frame"):GetComponent("UITexture")
	_ui.scroll = transform:Find("Levelup/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_ui.title = transform:Find("Levelup/bg_frane/bg_top/title"):GetComponent("UILabel")
	_ui.oldtitle = transform:Find("Levelup/bg_frane/bg_mid/title/num"):GetComponent("UILabel")
	_ui.beforeqtitle = transform:Find("Levelup/bg_frane/bg_mid/title/num (1)"):GetComponent("UILabel")
	_ui.time = transform:Find("Levelup/bg_frane/bg_vip/text"):GetComponent("UILabel")
	_ui.grid = transform:Find("Levelup/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.listinfo = transform:Find("Levelup/listinfo")
	
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)	
	UpdateUI()
end

UpdateUI = function()
	_ui.vipleft.mainTexture = ResourceLibrary:GetIcon("pay/" ,"icon_vip" .. before)
	_ui.vipright.mainTexture = ResourceLibrary:GetIcon("pay/" ,"icon_vip" .. now)
	if isExperience == nil then
		_ui.oldtitle.text = TextMgr:GetText("vip_ui5")
		_ui.beforeqtitle.text = TextMgr:GetText("vip_ui4")
		_ui.title.text = TextMgr:GetText("VIP_ui106")
	else
		if time ~= nil then
			if time ~= 0 then
				_ui.time.gameObject:SetActive(true)
				CountDown.Instance:Add("viplevelup", Serclimax.GameTime.GetSecTime() + time, CountDown.CountDownCallBack(function(t)
					_ui.time.text = String.Format(TextMgr:GetText("vip_ui6"), t) 
				end))
			end
		end
		
		if isExperience == 2 then
			_ui.oldtitle.text = TextMgr:GetText("vip_ui8")
			_ui.beforeqtitle.text = TextMgr:GetText("vip_ui7")
			_ui.title.text = TextMgr:GetText("vip_ui15")
		else
			_ui.oldtitle.text = TextMgr:GetText("vip_ui13")
			_ui.beforeqtitle.text = TextMgr:GetText("vip_ui12")
			_ui.title.text = TextMgr:GetText("VIP_ui106")
		end
	end
	
	local beforedata = VipData.GetVipList()[before]
	local nowdata = VipData.GetVipList()[now]
	--vip降级
	if isExperience == 2 then
		local getbeforenum = function(_data)
			if beforedata == nil then
				return ""
			end
			for i, v in ipairs(nowdata) do
				if v.type == _data.type and v.param1 == _data.param1 and v.param2 == _data.param2 then
					local st
					if string.find(v.showvalue, ';') ~= nil then
						local p = string.split(v.showvalue, ';')
						st = String.Format(TextMgr:GetText(p[2]), p[1])
					else
						st = v.showvalue
					end
					return st
				end
			end
			return ""
		end
		coroutine.start(function()
			for i, v in ipairs(beforedata) do
				local item = NGUITools.AddChild(_ui.grid.gameObject , _ui.listinfo.gameObject)
				item.transform:Find("bg_list").gameObject:SetActive(i % 2 == 0)
				item.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(v.text)
				
				local st
				if string.find(v.showvalue, ';') ~= nil then
					local p = string.split(v.showvalue, ';')
					st = String.Format(TextMgr:GetText(p[2]), p[1])
				else
					st = v.showvalue
				end
				
				local beforetext = getbeforenum(v)
				item.transform:Find("num"):GetComponent("UILabel").text = st == "" and TextMgr:GetText("vip_ui14") or beforetext				
				item.transform:Find("num (1)"):GetComponent("UILabel").text = st
				if v.param1 == "5" and beforetext == "" then
					MilitaryActionData.RequestData()
				end
				_ui.grid:Reposition()
				_ui.scroll:ResetPosition()
				NGUITools.BringForward(transform.gameObject)
				coroutine.wait(0.1)
				if _ui == nil then
					return
				end
			end
			showTimedBag_VIP = true
			--UnionGuide.Show(nil, UnionGuide.ShowPage.VipPage)
		end)
	else
		local getbeforenum = function(_data)
			if beforedata == nil then
				return ""
			end
			for i, v in ipairs(beforedata) do
				if v.type == _data.type and v.param1 == _data.param1 and v.param2 == _data.param2 then
					local st
					if string.find(v.showvalue, ';') ~= nil then
						local p = string.split(v.showvalue, ';')
						st = String.Format(TextMgr:GetText(p[2]), p[1])
					else
						st = v.showvalue
					end
					return st
				end
			end
			return ""
		end
		coroutine.start(function()
			for i, v in ipairs(nowdata) do
				local item = NGUITools.AddChild(_ui.grid.gameObject , _ui.listinfo.gameObject)
				item.transform:Find("bg_list").gameObject:SetActive(i % 2 == 0)
				item.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(v.text)
				
				local st
				if string.find(v.showvalue, ';') ~= nil then
					local p = string.split(v.showvalue, ';')
					st = String.Format(TextMgr:GetText(p[2]), p[1])
				else
					st = v.showvalue
				end
				item.transform:Find("num"):GetComponent("UILabel").text = st == "" and TextMgr:GetText("buffsys_ui1") or st
				local beforetext = getbeforenum(v)
				item.transform:Find("num (1)"):GetComponent("UILabel").text = beforetext
				if v.param1 == "5" and beforetext == "" then
					MilitaryActionData.RequestData()
				end
				_ui.grid:Reposition()
				_ui.scroll:ResetPosition()
				NGUITools.BringForward(transform.gameObject)
				coroutine.wait(0.1)
				if _ui == nil then
					return
				end
			end
		end)
	end
	
end
