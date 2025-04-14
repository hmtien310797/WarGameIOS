module("Welfare_Timebag", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local Format = System.String.Format

local _ui, UpdateUI, UpdateTop, UpdateDown
local timer = 0
local transform

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		local param = param:split("_")
		if param[1] == "item" then
			local itemdata = TableMgr:GetItemData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			else
			    if itemTipTarget == go then
			        Tooltip.HideItemTip()
			    else
			        itemTipTarget = go
			        Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			    end
			end
		else
			local itemdata = TableMgr:GetHeroData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		        end
		    end
		end
	else
		Tooltip.HideItemTip()
	end
end

function Hide()
	Close()
	GameObject.Destroy(transform.gameObject)
end

function HideAll()
    Hide()
    WelfareAll.Hide()
end

local function listenerCallback()
    WelfareAll.UpdateConfigs(function()
        Show(_ui.activity.id, _ui.activity.Templet)
    end)
end

function Close()
    CountDown.Instance:Remove("Welfare_Timebag")
	_ui = nil
	tramsform = nil
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    WelfareData.RemoveTriggerBagListener(listenerCallback)
end

function Show(activityId, templet)
	if activityId == nil or templet == nil then
		print("############### Activity is null ###############")
		return
	end
	if _ui == nil then
		_ui = {}
    end
	if _ui.activity == nil then
        transform = NGUITools.AddChild(GUIMgr.UIRoot.gameObject, ResourceLibrary.GetUIPrefab("ActivityStage/Welfare_Timebag")).transform
        NGUITools.BringForward(transform.gameObject)
        WelfareData.AddTriggerBagListener(listenerCallback)
	end
	_ui.activity = WelfareData.GetWelfareConfig(activityId)
	Awake()
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.Templet)
	Start()
end

function Start()
	SetClickCallback(_ui.container, function() HideAll() end)
	SetClickCallback(_ui.mask, function() HideAll() end)
	_ui.name = transform:Find("Container/bg_timebag/name"):GetComponent("UILabel")
    _ui.countdown = transform:Find("Container/bg_timebag/bg_bag/countdown"):GetComponent("UILabel")
    _ui.grid = transform:Find("Container/bg_timebag/bg_bag/items/grid"):GetComponent("UIGrid")
    _ui.totalPrice = transform:Find("Container/bg_timebag/bg_bag/bg_price/bg/num"):GetComponent("UILabel")
    _ui.needPrice = transform:Find("Container/bg_timebag/bg_bag/bg_bottom/bg_xianjia/num"):GetComponent("UILabel")
    _ui.btn_go = transform:Find("Container/bg_timebag/bg_bag/bg_bottom/btn_purchase").gameObject
    _ui.btn_label = transform:Find("Container/bg_timebag/bg_bag/bg_bottom/btn_purchase/price"):GetComponent("UILabel")
    _ui.desc = transform:Find("Container/bg_timebag/bg_bag/bg_bottom/description"):GetComponent("UILabel")
    UpdateUI()
end

local function UpdateTop()
    if _ui.activity.data.canTake then
        _ui.countdown.gameObject:SetActive(false)
        CountDown.Instance:Remove("Welfare_Timebag")
    else
        _ui.countdown.gameObject:SetActive(true)
        CountDown.Instance:Add("Welfare_Timebag", _ui.activity.endTime, CountDown.CountDownCallBack(function(t)
            if t == "00:00:00" then
				CountDown.Instance:Remove("Welfare_Timebag")
				HideAll()	
            else
                _ui.countdown.text = t
            end
        end))
	end
	_ui.name.text = TextMgr:GetText(_ui.activity.data.name)
    _ui.desc.text = TextMgr:GetText(_ui.activity.data.desc)
    _ui.totalPrice.text = _ui.activity.data.bagPrice
    _ui.needPrice.text = _ui.activity.data.needPay
end

local function UpdateDown()
    while _ui.grid.transform.childCount > 0 do
        GameObject.DestroyImmediate(_ui.grid.transform:GetChild(0).gameObject)
    end
    for _, item in ipairs(_ui.activity.data.rewardInfo.items) do
        if item.id ~= 15 then
            local itemobj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
            SetParameter(itemobj.gameObject, "item_" .. item.id)
        end
    end
    _ui.grid:Reposition()
    if _ui.activity.data.canTake then
        _ui.btn_label.text = TextMgr:GetText("mail_ui12")
		UIUtil.SetClickCallback(_ui.btn_go, function()
            WelfareData.RequestTakeTriggerBagReward(_ui.activity.data.type, _ui.activity.data.param, function()
                TimedBag.Show()
				HideAll()
			end)
		end)
    else
        _ui.btn_label.text = TextMgr:GetText("recharge_ui1")
		UIUtil.SetClickCallback(_ui.btn_go, function()
			store.Show()
			HideAll()
		end)
    end
end


UpdateUI = function()
	_ui.welfare_template1Data = {}
	-- MissionListData.Sort2()
	UpdateTop()
	UpdateDown()
end

function Refresh()
    UpdateUI()
end
