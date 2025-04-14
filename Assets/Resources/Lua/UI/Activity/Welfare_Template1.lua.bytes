module("Welfare_Template1", package.seeall)
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
	-- Global.CloseUI(_M)
	Close()
	GameObject.Destroy(transform.gameObject)
end

function HideAll()
    WelfareAll.Hide()
end

function Close()
	_ui = nil
	tramsform = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	CountDown.Instance:Remove("welfare_template1")
	CountDown.Instance:Remove("templet1_refresh")
	Welfare_Template1Data.RemoveListener(UpdateUI)
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
		transform = NGUITools.AddChild(GUIMgr.UIRoot.gameObject, ResourceLibrary.GetUIPrefab("ActivityStage/Welfare_Template2")).transform
		NGUITools.BringForward(transform.gameObject)		
	
	else
		if _ui.activity.activityId == activityId and _ui.activity.templet == templet then
			return
		end
	end
	_ui.activity.activityId = activityId
	_ui.activity.templet = templet
	if _ui.showList == nil then
		_ui.showList = {}
	end
	-- Global.OpenUI(_M)
	print(_ui.activity.activityId, _ui.activity.templet)
	Awake()
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.content = transform:Find("Container/content").gameObject
	_ui.banner = transform:Find("Container/content/banner"):GetComponent("UITexture")
	_ui.text_line1 = transform:Find("Container/content/banner/Label"):GetComponent("UILabel")
	_ui.text_line2 = transform:Find("Container/content/banner/tips01"):GetComponent("UILabel")
	_ui.time_line1 = transform:Find("Container/content/banner/time"):GetComponent("UILabel")
	_ui.time_line2 = transform:Find("Container/content/banner/time (1)"):GetComponent("UILabel")

	_ui.time_sprite1 = transform:Find("Container/content/banner/Sprite")
	_ui.time_bg1 = transform:Find("Container/content/banner/bg")
	_ui.time_text1 = transform:Find("Container/content/banner/timer")

	_ui.time_sprite2 = transform:Find("Container/content/banner/Sprite (2)")
	_ui.time_bg2 = transform:Find("Container/content/banner/bg (1)")
	_ui.time_text2 = transform:Find("Container/content/banner/timer (1)")	


	_ui.help = transform:Find("Container/content/banner/button_ins").gameObject	
	_ui.scroll = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("Container/content/Scroll View/Grid/listitem_GrowGold")
	_ui.item.gameObject:SetActive(false)
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	_ui.scroll:ResetPosition()
	_ui.content:SetActive(false)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
	Welfare_Template1Data.AddListener(UpdateUI)
	Start()
end

function DisplayBannerTime1(show)
	if _ui == nil then
		return
	end
	if show then
		_ui.time_line1.gameObject:SetActive(true);
		_ui.time_sprite1.gameObject:SetActive(true);
		_ui.time_bg1.gameObject:SetActive(true);
		_ui.time_text1.gameObject:SetActive(true);
	else
		_ui.time_line1.gameObject:SetActive(false);
		_ui.time_sprite1.gameObject:SetActive(false);
		_ui.time_bg1.gameObject:SetActive(false);
		_ui.time_text1.gameObject:SetActive(false);
	end
end

function DisplayBannerTime2(show)
	if _ui == nil then
		return
	end
	if show then
		_ui.time_line2.gameObject:SetActive(true);
		_ui.time_sprite2.gameObject:SetActive(true);
		_ui.time_bg2.gameObject:SetActive(true);
		_ui.time_text2.gameObject:SetActive(true);
	else
		_ui.time_line2.gameObject:SetActive(false);
		_ui.time_sprite2.gameObject:SetActive(false);
		_ui.time_bg2.gameObject:SetActive(false);
		_ui.time_text2.gameObject:SetActive(false);
	end
end

function Start()
	SetClickCallback(_ui.mask, HideAll)
	SetClickCallback(_ui.help, function()
		DailyActivityHelp.Show(_ui.configs["HelpTitle"], _ui.configs["HelpContent"])
	end)
	-- UpdateUI()
	if _ui.activity.templet == 305 then
		Welfare_Template1Data.RequestAccumulateRecharge()
	elseif _ui.activity.templet == 306 then
		Welfare_Template1Data.RequestDailyConsume()
	elseif _ui.activity.templet == 307 then
		Welfare_Template1Data.RequestDailyRecharge()
	elseif _ui.activity.templet == 309 then
		Welfare_Template1Data.RequestAccumulateConsume()
	end
	if _ui.configs["banner"] ~= nil then
		_ui.banner.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", _ui.configs["banner"])
	end
end

local function UpdateTop()
	if _ui.configs["HelpTitle"] == nil then
		_ui.help:SetActive(false)
	end
	_ui.text_line1.text = _ui.configs["title"] ~= nil and TextMgr:GetText(_ui.configs["title"]) or ""
	_ui.text_line2.text = _ui.configs["des"] ~= nil and TextMgr:GetText(_ui.configs["des"]) or ""
	if _ui.configs["lefttime"] ~= nil then
		DisplayBannerTime1(true)
		print(_ui.activity.activityId, ActivityData.GetActivityConfig(_ui.activity.activityId))
		CountDown.Instance:Add("welfare_template1", ActivityData.GetActivityConfig(_ui.activity.activityId).endTime, CountDown.CountDownCallBack(function(t)
		if t == "00:00:00" then
			CountDown.Instance:Remove("welfare_template1")	
			HideAll()
			Hide()
		else
			if _ui ~= nil then
				_ui.time_line1.text = t --Format(TextMgr:GetText(_ui.configs["lefttime"]),t)
			else
				CountDown.Instance:Remove("welfare_template1")	
			end
		end
	end))
	else
		DisplayBannerTime1(false)
		_ui.time_line1.text = ""
	end
	if _ui == nil then
		return
	end
	if _ui.configs["refreshtime"] == nil then
		DisplayBannerTime2(false)
		_ui.time_line2.text = ""
	else
		DisplayBannerTime2(true)
		_ui.time_line2.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown()) --Format(TextMgr:GetText(_ui.configs["refreshtime"]), Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown()))
		CountDown.Instance:Add("templet1_refresh", Global.GetFiveOclockCooldown(), CountDown.CountDownCallBack(function(t)
			if t == "00:00:00" then
				HideAll()
				Hide()
			else
				_ui.time_line2.text = t --Format(TextMgr:GetText(_ui.configs["refreshtime"]), t)
			end
		end))
	end
end

local function UpdateDown()
	local index = 0
	for i, v in ipairs(_ui.table) do
		index = i
		local data = v
		local showItem = _ui.showList[i]
		if showItem == nil then
			showItem = {}
			showItem.transform = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
			showItem.grid = showItem.transform:Find("reward/Grid")
			GameObject.Destroy(showItem.grid:GetComponent("UIGrid"))
			showItem.itemprefab = showItem.grid:GetChild(0)
			showItem.itemprefab.gameObject:SetActive(false)
			for x = 1, 5 do
				GameObject.Destroy(showItem.grid:GetChild(x).gameObject)
			end
			showItem.children = {}
			_ui.showList[i] = showItem
		end
		local item = showItem.transform
		item.gameObject:SetActive(true)
		local go = item:Find("btn_go")
		local reward = item:Find("btn_reward")
		local complete = item:Find("complete")
		local disabled = item:Find("btn_disabled")
		go.gameObject:SetActive(false)
		reward.gameObject:SetActive(false)
		complete.gameObject:SetActive(false)
		disabled.gameObject:SetActive(false)
		item.gameObject:SetActive(true)
		item:Find("Original Price/Gold/Num"):GetComponent("UILabel").text = data.displayPrice .. " " .. TextUtil.GetItemName(TableMgr:GetItemData(2))
		item:Find("jindu").gameObject:SetActive(data.status == ActivityMsg_pb.RewardStatus_CanNotTake)

		if data.status == ActivityMsg_pb.RewardStatus_CanNotTake then
			item:Find("jindu/number1"):GetComponent("UILabel").text = _ui.currentnum
			item:Find("jindu/number2"):GetComponent("UILabel").text = "/" .. data.needAmt

			if _ui.datago == true then
				local btn_go = go:GetComponent("UIButton")
				btn_go.gameObject:SetActive(true)
				SetClickCallback(btn_go.gameObject, function()
                    if _ui.activity.templet == 309 or _ui.activity.templet == 306 then
                        MilitarySchool.Show()
                    else
                        Goldstore.ShowRechargeTab()
                    end
				end)
			else
				disabled.gameObject:SetActive(true)
			end
		elseif data.status == ActivityMsg_pb.RewardStatus_CanTake then
			item:Find("jindu/number1"):GetComponent("UILabel").text = ""
			item:Find("jindu/number2"):GetComponent("UILabel").text = ""

			reward.gameObject:SetActive(true)
			SetClickCallback(reward.gameObject, function()
				if _ui.rewardcallback ~= nil then
					_ui.rewardcallback(v.index)
				end
			end)
		else
			item:Find("jindu/number1"):GetComponent("UILabel").text = ""
			item:Find("jindu/number2"):GetComponent("UILabel").text = ""

			complete.gameObject:SetActive(true)
		end

		item:Find("bg/name").gameObject:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(_ui.configs["task_name"]), data.needAmt) 
		item:Find("bg/Gold/Num"):GetComponent("UILabel").text = Global.FormatNumber(data.needAmt)
		local initChildren = function(index)
			if showItem.children[index] == nil then
				showItem.children[index] = {}
				showItem.children[index].hero = NGUITools.AddChild(showItem.grid.gameObject, _ui.hero.gameObject).transform
				showItem.children[index].hero.gameObject:SetActive(false)
				showItem.children[index].item = NGUITools.AddChild(showItem.grid.gameObject, showItem.itemprefab.gameObject).transform
			end
			showItem.children[index].hero.gameObject:SetActive(false)
			showItem.children[index].item.gameObject:SetActive(false)
			return showItem.children[index]
		end
		local itemcount = 0
		for ii, vv in ipairs(data.rewardInfo.heros) do
			itemcount = itemcount + 1
			local heroData = TableMgr:GetHeroData(vv.id)
			local hero = initChildren(itemcount).hero
			hero.gameObject:SetActive(true)
			hero.localScale = Vector3(0.6, 0.6, 1) * 0.9
			hero.localPosition = Vector3(-200 + 80 * (itemcount - 1), 0, 0)
			hero:Find("level text").gameObject:SetActive(false)
			hero:Find("name text").gameObject:SetActive(false)
			hero:Find("bg_skill").gameObject:SetActive(false)
			hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
			hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
			local star = hero:Find("star"):GetComponent("UISprite")
			if star ~= nil then
				star.width = vv.star * star.height
			end
			SetParameter(hero:Find("head icon").gameObject, "hero_" .. vv.id)
		end
		for ii, vv in ipairs(data.rewardInfo.items) do
			itemcount = itemcount + 1
			local reward = vv
			local itemData = TableMgr:GetItemData(reward.id)
			local itemprefab = initChildren(itemcount).item
			itemprefab.localPosition = Vector3(-200 + 80 * (itemcount - 1), 0, 0)
			itemprefab.gameObject:SetActive(true)
			local item = {}
			UIUtil.LoadItemObject(item, itemprefab)
			UIUtil.LoadItem(item, itemData, vv.num)
			SetParameter(itemprefab.gameObject, "item_" .. reward.id)
		end
		for ii, vv in ipairs(data.rewardInfo.armys) do
			itemcount = itemcount + 1
			local reward = vv
			local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
			local itemprefab = initChildren(itemcount).item
			itemprefab.localPosition = Vector3(-200 + 80 * (itemcount - 1), 0, 0)
			itemprefab.gameObject:SetActive(true)
			itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + reward.level)
			itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
			itemprefab:Find("have"):GetComponent("UILabel").text = reward.num
			itemprefab:Find("num").gameObject:SetActive(false)
			SetParameter(itemprefab.gameObject, soldierData)
		end
		for x = itemcount + 1, #showItem.children do
			showItem.children[x].hero.gameObject:SetActive(false)
			showItem.children[x].item.gameObject:SetActive(false)
		end
	end
	for i = index + 1, #_ui.showList do
		_ui.showList[i].transform.gameObject:SetActive(false)
	end
	_ui.grid:Reposition()
	_ui.scroll:ResetPosition()
	_ui.content:SetActive(true)
end


UpdateUI = function()
	_ui.welfare_template1Data = {}
	-- MissionListData.Sort2()
	UpdateTop()
	if _ui.activity.templet == 305 then	
		_ui.welfare_template1Data = Welfare_Template1Data.GetData().AccumulateRecharge		
		_ui.table = _ui.welfare_template1Data.accumRewardInfos
		_ui.datago = true
		_ui.currentnum = _ui.welfare_template1Data.rechargeAmt
		_ui.rewardcallback = function(index)
				Welfare_Template1Data.TakeAccumulateRechargeReward(index, function()
				-- MainCityUI.UpdateWelfareNotice(3005)
			end)
		end		
	elseif _ui.activity.templet == 306 then
		_ui.welfare_template1Data = Welfare_Template1Data.GetData().DailyConsume
		_ui.currentnum = _ui.welfare_template1Data.consumeAmt
		_ui.table = _ui.welfare_template1Data.dailyRewardInfos
		_ui.datago = true
		_ui.rewardcallback = function(index)
				Welfare_Template1Data.TakeDailyConsumeReward(index, function()
				-- MainCityUI.UpdateWelfareNotice(3006)
			end)
		end
	elseif _ui.activity.templet == 307 then
		_ui.welfare_template1Data = Welfare_Template1Data.GetData().DailyRecharge
		_ui.table = _ui.welfare_template1Data.dailyRewardInfos
		_ui.datago = true
		_ui.currentnum = _ui.welfare_template1Data.rechargeAmt
		_ui.rewardcallback = function(index)
				Welfare_Template1Data.TakeDailyRechargeReward(index, function()
				-- MainCityUI.UpdateWelfareNotice(3007)
			end)
		end
	elseif _ui.activity.templet == 309 then
		_ui.welfare_template1Data = Welfare_Template1Data.GetData().AccumulateConsume
		_ui.table = _ui.welfare_template1Data.accumRewardInfos
		_ui.datago = true
		_ui.currentnum = _ui.welfare_template1Data.consumeAmt
		_ui.rewardcallback = function(index)
				Welfare_Template1Data.TakeAccumulateConsumeReward(index, function()
				-- MainCityUI.UpdateWelfareNotice(3007)
			end)
		end
	end
	if _ui.table ~= nil then
		table.sort(_ui.table, function(v1, v2)
			local canTake1 = v1.status == ActivityMsg_pb.RewardStatus_CanTake 
			local canTake2 = v2.status == ActivityMsg_pb.RewardStatus_CanTake 
			if canTake1 == canTake2 then
				if canTake1 then
					return v1.needAmt < v2.needAmt
				else
					if tonumber(v1.status) == tonumber(v2.status) then
						return v1.needAmt < v2.needAmt
					end
					return tonumber(v1.status) < tonumber(v2.status)
				end
			else
				return canTake1 and not canTake2
			end
		end)
	end
	UpdateDown()
end

function Refresh()
    UpdateUI()
end

----- Template:Goldstore --------------------------------------------------------
function OnNoticeStatusChange(config)
    return Welfare_Template1Data.OnDataChange()
end

function OnAvailabilityChange(config)
    return ActivityData.OnAvailabilityChange()
end

function HasNotice(config)
    local tabID = config.id
    if tabID == 5 then
    	return Welfare_Template1Data.HasTakeAccumulateRechargeReward()
    elseif tabID == 6 then
    	return Welfare_Template1Data.HasTakeDailyConsumeReward()
    elseif tabID == 7 then
    	return Welfare_Template1Data.HasTakeDailyRechargeReward()
    end
end

function IsAvailable(config)
	return ActivityData.IsActivityAvailable(3000 + config.id)
end

--Goldstore.RegisterAsTemplate(6, _M)
---------------------------------------------------------------------------------
