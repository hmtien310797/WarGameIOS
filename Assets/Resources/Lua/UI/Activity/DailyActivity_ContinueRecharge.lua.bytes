module("DailyActivity_ContinueRecharge", package.seeall)
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

local _ui, UpdateUI, UpdateTop, UpdateDown, isInView
local timer = 0

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
	Global.CloseUI(_M)
end

function HideAll()
    WelfareAll.Hide()
end

function Refresh()
    UpdateUI()
end

function Close()
    _ui = nil
    isInView = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	CountDown.Instance:Remove("DailyActivity_ContinueRecharge")
	ContinueRechargeData.RemoveListener(UpdateDown)
end

function Show(activityId,templet)
	if activityId == nil or templet == nil then
		print("############### Activity is null ###############")
		return
	end
	if _ui == nil then
		_ui = {}
	end
	if _ui.activity == nil then
		_ui.activity = {}
	else
		if _ui.activity.activityId == activityId and _ui.activity.templet == templet then
			return
		end
	end
	_ui.activity.activityId = activityId
	_ui.activity.templet = templet
	
    if isInView then
        UpdateUI()
    else
        Global.OpenUI(_M)
        isInView = true
    end
	print(_ui.activity.activityId, _ui.activity.templet)
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.content = transform:Find("Container/content").gameObject
	_ui.time = transform:Find("Container/content/top/Label"):GetComponent("UILabel")
    _ui.help = transform:Find("Container/content/button_ins").gameObject	
    _ui.helpbanner = transform:Find("DailyActivity_Help").gameObject
    _ui.helpbanner_container = transform:Find("DailyActivity_Help/Container").gameObject
    _ui.helpbanner_close = transform:Find("DailyActivity_Help/Container/bg_frane/bg_top/btn_close").gameObject
	_ui.scroll = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item = transform:Find("Container/content/list")
    _ui.hint = transform:Find("Container/content/back/Label"):GetComponent("UILabel")
	_ui.scroll:ResetPosition()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
    ContinueRechargeData.AddListener(UpdateDown)
end

function Start()
    SetClickCallback(_ui.mask, HideAll)
	SetClickCallback(_ui.help, function()
        _ui.helpbanner:SetActive(true)
        NGUITools.BringForward(_ui.helpbanner)
    end)
    SetClickCallback(_ui.helpbanner_container, function()
        _ui.helpbanner:SetActive(false)
    end)
    SetClickCallback(_ui.helpbanner_close, function()
        _ui.helpbanner:SetActive(false)
    end)
    _ui.data = ContinueRechargeData.GetAvailableCard(_ui.activity.activityId)
    UpdateUI()
end

UpdateTop = function()
    if not _ui then
        HideAll()
        return
    end
	CountDown.Instance:Add("DailyActivity_ContinueRecharge", ActivityData.GetActivityConfig(_ui.activity.activityId).endTime, CountDown.CountDownCallBack(function(t)
		if t == "00:00:00" then
			CountDown.Instance:Remove("DailyActivity_ContinueRecharge")	
			HideAll()
		else
			_ui.time.text = Format(TextMgr:GetText("TotalPay_ui2"), t)
		end
    end))
    if not _ui.data then
        _ui.data = ContinueRechargeData.GetAvailableCard(_ui.activity.activityId)
        if not _ui.data then
            HideAll()
            return
        end
    end
    local biger = 0
    for i, v in kpairs(_ui.data) do
        if v.needMoney > biger then
            biger = v.needMoney
        end
    end
    _ui.hint.text = Format(TextMgr:GetText("TotalPay_ui5"), string.make_price(biger))
end

UpdateDown = function()
    if not _ui then
        HideAll()
        return
    end
    _ui.data = ContinueRechargeData.GetAvailableCard(_ui.activity.activityId)
    local updateItem = function(item, data, money, day)
        item:Find("Label"):GetComponent("UILabel").text = Format(TextMgr:GetText("TotalPay_ui4"), day)
        local texture = item:GetComponent("UITexture")
        local finish = item:Find("finish").gameObject
        local sfx = item:Find("fulibao").gameObject
        if day == 3 then
            texture.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", "icon_recharge2")
        elseif day == 5 then
            texture.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", "icon_recharge3")
            local showtexture = item:Find("qipao/Texture"):GetComponent("UITexture")
            showtexture.mainTexture = ResourceLibrary:GetIcon("Item/", TableMgr:GetItemData(data.rewardInfo.items[1].id).icon)
            item:Find("qipao/Label (1)"):GetComponent("UILabel").text = data.rewardInfo.items[1].num
        else
            texture.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", "icon_recharge1")
        end
        texture.color = data.status == ActivityMsg_pb.RewardStatus_HasTaken and Color.black or Color.white
        finish:SetActive(data.status == ActivityMsg_pb.RewardStatus_HasTaken)
        sfx:SetActive(data.status == ActivityMsg_pb.RewardStatus_CanTake)

        SetClickCallback(item.gameObject, function()
            RechargeRewards.Show(data.rewardInfo, function()
                ContinueRechargeData.ClaimAward(_ui.activity.activityId, money, day)
            end, data.status)
        end)
    end
    local updateList = function(listitem, data)
        listitem.transform:Find("base/top_label"):GetComponent("UILabel").text = Format(TextMgr:GetText("TotalPay_ui3"), string.make_price(data.needMoney))
        listitem.transform:Find("base/progressbar"):GetComponent("UISlider").value = (data.continueDays - 1) / 4
        listitem.transform:Find("base/tishi").gameObject:SetActive(data.hasRecharged)
        for i, v in ipairs(data) do
            local item = listitem.transform:Find(i)
            updateItem(item, v, data.needMoney,i)
        end
    end
    local index = 0
    for i, v in kpairs(_ui.data) do
        index = index + 1
        local listitem
        if index <= _ui.grid.transform.childCount then
            listitem = _ui.grid.transform:GetChild(index - 1).gameObject
        else
            listitem = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject)
        end
        listitem:SetActive(true)
        updateList(listitem, v)
    end
    for i = _ui.grid.transform.childCount, index + 1, -1 do
        GameObject.Destroy(_ui.grid.transform:GetChild(i - 1).gameObject)
    end
    _ui.grid:Reposition()
    _ui.scroll:RestrictWithinBounds(true, _ui.scroll.transform)
end

UpdateUI = function()
	UpdateTop()
	UpdateDown()
end