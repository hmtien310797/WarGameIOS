module("Welfare_heroget", package.seeall)
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
        if type(param) == "string" then
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
            if not Tooltip.IsItemTipActive() then
                itemTipTarget = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(param.SoldierName), text = TextMgr:GetText(param.SoldierDes)})
            else
                if itemTipTarget == go then
                    Tooltip.HideItemTip()
                else
                    itemTipTarget = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(param.SoldierName), text = TextMgr:GetText(param.SoldierDes)})
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
	CountDown.Instance:Remove("Welfare_heroget")
	Welfare_HerogetData.RemoveListener(UpdateDown)
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
    _ui.scroll = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item = transform:Find("Container/content/Scroll View/Grid/listitem_GrowGold")
    _ui.scroll:ResetPosition()
    _ui.timeLabel = transform:Find("Container/content/banner/time"):GetComponent("UILabel")
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
    Welfare_HerogetData.AddListener(UpdateDown)
end

function Start()
    SetClickCallback(_ui.mask, HideAll)
    _ui.data = Welfare_HerogetData.GetAvailableCard(_ui.activity.activityId)
    UpdateUI()
end

UpdateTop = function()
    if not _ui then
        HideAll()
        return
    end
	CountDown.Instance:Add("Welfare_heroget", ActivityData.GetActivityConfig(_ui.activity.activityId).endTime, CountDown.CountDownCallBack(function(t)
		if t == "00:00:00" then
			CountDown.Instance:Remove("Welfare_heroget")	
            HideAll()
        else
            _ui.timeLabel.text = t
		end
    end))
    if not _ui.data then
        _ui.data = Welfare_HerogetData.GetAvailableCard(_ui.activity.activityId)
        if not _ui.data then
            HideAll()
            return
        end
    end
end

UpdateDown = function()
    if not _ui then
        HideAll()
        return
    end
    table.sort(_ui.data, function(a,b)
        if a.status == ActivityMsg_pb.RewardStatus_CanTake and b.status ~= ActivityMsg_pb.RewardStatus_CanTake then
            return true
        elseif a.status ~= ActivityMsg_pb.RewardStatus_CanTake and b.status == ActivityMsg_pb.RewardStatus_CanTake then
            return false
        elseif a.status == ActivityMsg_pb.RewardStatus_CanNotTake and b.status == ActivityMsg_pb.RewardStatus_HasTaken then
            return true
        elseif a.status == ActivityMsg_pb.RewardStatus_HasTaken and b.status == ActivityMsg_pb.RewardStatus_CanNotTake then
            return false
        else
            return a.index > b.index
        end
    end)
    local childCount = _ui.grid.transform.childCount
    for i, v in ipairs(_ui.data) do
        local listItem
        if i <= childCount then
            listItem = _ui.grid.transform:GetChild(i - 1)
        else
            listItem = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
        end
        local heroData = TableMgr:GetHeroData(v.heroId)
        listItem:Find("hero/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
        listItem:Find("hero"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
        listItem:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(heroData.nameLabel)
        listItem:Find("desc"):GetComponent("UILabel").text = TextMgr:GetText(v.desc)
        listItem:Find("desc_1"):GetComponent("UILabel").text = TextMgr:GetText(v.desc2)

        local itemgrid = listItem:Find("reward/Grid")
		local itemcount = 0
		for ii, vv in ipairs(v.rewardInfo.items) do
			local reward = vv
			local itemData = TableMgr:GetItemData(reward.id)
			local itemprefab = itemgrid:GetChild(itemcount)
			itemcount = itemcount + 1
			itemprefab.gameObject:SetActive(true)
			local item = {}
			
			UIUtil.LoadItemObject(item, itemprefab)
			UIUtil.LoadItem(item, itemData, vv.num)
			SetParameter(itemprefab.gameObject, "item_" .. reward.id)
        end
        for ii, vv in ipairs(v.rewardInfo.armys) do
			local reward = vv
			local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
			local itemprefab = itemgrid:GetChild(itemcount)
			itemcount = itemcount + 1
            itemprefab.gameObject:SetActive(true)
            itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + reward.level)
            itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
            itemprefab:Find("have"):GetComponent("UILabel").text = reward.num
            itemprefab:Find("num").gameObject:SetActive(false)
			SetParameter(itemprefab.gameObject, soldierData)
		end
		for ii = itemcount + 1, 4 do
			itemgrid:GetChild(ii - 1).gameObject:SetActive(false)
        end
        local btn_reward = listItem:Find("btn_reward"):GetComponent("UIButton")
        local complete = listItem:Find("complete").gameObject
        if v.status == ActivityMsg_pb.RewardStatus_CanNotTake then
            btn_reward.gameObject:SetActive(true)
            complete:SetActive(false)
            UIUtil.SetBtnEnable(btn_reward, "btn_2", "btn_4", false)
            SetClickCallback(btn_reward.gameObject, function() end)
        elseif v.status == ActivityMsg_pb.RewardStatus_CanTake then
            btn_reward.gameObject:SetActive(true)
            complete:SetActive(false)
            UIUtil.SetBtnEnable(btn_reward, "btn_2", "btn_4", true)
            SetClickCallback(btn_reward.gameObject, function()
                Welfare_HerogetData.ClaimAward(_ui.activity.activityId, v.index)
            end)
        else
            btn_reward.gameObject:SetActive(false)
            complete:SetActive(true)
        end
    end
    _ui.grid:Reposition()
end

UpdateUI = function()
	UpdateTop()
	UpdateDown()
end