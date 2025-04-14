module("DailyActivity_Template1", package.seeall)
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

function CloseSelf()
	Global.CloseUI(_M)
end

function Hide()
	GUIMgr:FindMenu("DailyActivity_Template1").gameObject:SetActive(false)
end

function CloseAll()
	CloseSelf()
	DailyActivity.CloseSelf()
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	MissionListData.RemoveListener(UpdateUI)
	CountDown.Instance:Remove("templet1")
	CountDown.Instance:Remove("templet1_refresh")
end

function Show(activity , updateTemplet)
	if activity == nil then
		print("############### Activity is null ###############")
		return
	end
	
	if updateTemplet == nil or not updateTemplet then
		if _ui == nil then
			_ui = {}
		end
		_ui.activity = activity
		Global.OpenUI(_M)
		if _ui.missionlist == nil then
			UpdateUI()
		end
	else
		_ui.activity = activity
		local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
		if configid == nil or configid == "" or configid == 0 then
			configid = _ui.activity.activityId
		end
		_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
		if _ui.configs["banner"] ~= nil then
			_ui.banner.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", _ui.configs["banner"])
		end
		
		UpdateUI()
		DailyActivityData.NotifyUIOpened(_ui.activity.activityId)
	end
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	
	_ui.title = transform:Find("Container/background/title/Label"):GetComponent("UILabel")
	_ui.title.text = TextMgr:GetText("activity_btn_text")
	_ui.banner = transform:Find("Container/content/banner"):GetComponent("UITexture")
	_ui.text_line1 = transform:Find("Container/content/banner/Label"):GetComponent("UILabel")
	_ui.text_line2 = transform:Find("Container/content/banner/tips01"):GetComponent("UILabel")
	_ui.time_line1 = transform:Find("Container/content/banner/time"):GetComponent("UILabel")
	_ui.time_line2 = transform:Find("Container/content/banner/time (1)"):GetComponent("UILabel")

	_ui.time_sprite1 = transform:Find("Container/content/banner/Sprite")
	_ui.time_bg1 = transform:Find("Container/content/banner/bg")
	_ui.time_text1 = transform:Find("Container/content/banner/timer")

	_ui.time_sprite2 = transform:Find("Container/content/banner/Sprite (1)")
	_ui.time_bg2 = transform:Find("Container/content/banner/bg (1)")
	_ui.time_text2 = transform:Find("Container/content/banner/timer (1)")	

	_ui.help = transform:Find("Container/content/banner/button_ins").gameObject
	
	_ui.scroll = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("Container/listitem_GrowGold")
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
	MissionListData.AddListener(UpdateUI)
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
	SetClickCallback(_ui.container, CloseAll)
	SetClickCallback(_ui.mask, CloseAll)
	if _ui.configs["HelpTitle"] == nil then
		_ui.help:SetActive(false)
	else
		_ui.help:SetActive(true)
	end
	SetClickCallback(_ui.help, function()
		DailyActivityHelp.Show(_ui.configs["HelpTitle"], _ui.configs["HelpContent"])
	end)
	if _ui.configs["banner"] ~= nil then
		_ui.banner.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", _ui.configs["banner"])
	end
	--UpdateUI()
	DailyActivityData.NotifyUIOpened(_ui.activity.activityId)
end

local function OnMisstionNotify()
	MissionListData.Sort2()
	local missionMsgList = MissionListData.GetData()
	for k , v in pairs(missionMsgList) do
		for i, vv in ipairs(_ui.missionlist) do
			if v.id == vv.data.id then
				if not vv.mission.rewarded and vv.data.conditionType ~= 71 and 
				vv.data.conditionType ~= 72 and vv.data.conditionType ~= 73 and 
				vv.data.conditionType ~= 78 and vv.data.conditionType ~= 80 and 
				vv.data.conditionType ~= 46 and --[[vv.data.conditionType ~= 45 and ]]
				vv.data.conditionType ~= 63 and vv.data.conditionType ~= 87 then
					
				end
				break
			end
		end
	end
end

UpdateUI = function()
	_ui.missionlist = {}
	MissionListData.Sort2()
	local missionMsgList = MissionListData.GetData()
	for i,v in pairs(missionMsgList) do
		local mdata = TableMgr:GetMissionData(v.id)
		if mdata ~= nil and mdata.ActivityID == _ui.activity.activityId then
			local m = {}
			m.mission = v
			m.data = mdata
			table.insert(_ui.missionlist, m)
		end
	end
	table.sort(_ui.missionlist, function(a, b)
		if a.mission.rewarded and not b.mission.rewarded then
			return false
		elseif b.mission.rewarded and not a.mission.rewarded then
			return true
		end
		if a.mission.status == 2 and b.mission.status == 1--[[a.mission.value >= a.data.number and b.mission.value < b.data.number]] then
			return true
		elseif a.mission.status == 1 and b.mission.status == 2--[[a.mission.value < a.data.number and b.mission.value >= b.data.number]] then
			return false
		end
		return a.data.id < b.data.id
	end)
	UpdateTop()
	UpdateDown()
end

UpdateTop = function()
	_ui.text_line1.text = _ui.configs["title"] ~= nil and TextMgr:GetText(_ui.configs["title"]) or ""
	_ui.text_line2.text = _ui.configs["des"] ~= nil and TextMgr:GetText(_ui.configs["des"]) or ""
	if _ui.configs["lefttime"] ~= nil then
		DisplayBannerTime1(true)
		CountDown.Instance:Add("templet1", _ui.activity.endTime + 2, CountDown.CountDownCallBack(function(t)
			if t == "00:00:00" then
				ActivityData.RequestListData(function()
					CloseAll()
					DailyActivity.Show()
				end)
			else
				_ui.time_line1.text = t --Format(TextMgr:GetText(_ui.configs["lefttime"]),t)
			end
		end))
	else
		DisplayBannerTime1(false)
		_ui.time_line1.text = ""
	end
	if _ui.configs["refreshtime"] == nil then
		DisplayBannerTime2(false)
		_ui.time_line2.text = ""
	else
		DisplayBannerTime2(true)
		_ui.time_line2.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown())--Format(TextMgr:GetText(_ui.configs["refreshtime"]), Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown()))
		CountDown.Instance:Add("templet1_refresh", Global.GetFiveOclockCooldown() + 2, CountDown.CountDownCallBack(function(t)
			if t == "00:00:00" then
				MissionListData.RequestData()
			else
				_ui.time_line2.text = t --Format(TextMgr:GetText(_ui.configs["refreshtime"]), t)
			end
		end))
	end
end

UpdateDown = function()
	local childcount = _ui.grid.transform.childCount
	local index = 0
	for i, v in ipairs(_ui.missionlist) do
		index = i
		local missionData = v
		local missionitem
		if i - 1 < childcount then
			missionitem = _ui.grid.transform:GetChild(i - 1)
		else
			missionitem = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
		end
		missionitem.gameObject:SetActive(true)
		local btn_go = missionitem:Find("btn_go"):GetComponent("UIButton")
		if not missionData.mission.rewarded and missionData.data.conditionType ~= 71 and missionData.data.conditionType ~= 72 and missionData.data.conditionType ~= 73 and missionData.data.conditionType ~= 78 and missionData.data.conditionType ~= 80 and missionData.data.conditionType ~= 46 and --[[missionData.data.conditionType ~= 45 and]] missionData.data.conditionType ~= 63 and missionData.data.conditionType ~= 87 then
			--MissionUI.LoadMissionJump(btn_go, missionData.mission, missionData.data)
			local completed = --[[missionData.mission.value >= missionData.data.number]] missionData.mission.status == 2
		    if completed then
		        btn_go.gameObject:SetActive(false)
		    else
		        local missionJumpFunc = MissionUI.GetMissionJumpFunction(missionData.mission, missionData.data)
		        if missionJumpFunc ~= nil then
		            btn_go.gameObject:SetActive(true)
		            SetClickCallback(btn_go.gameObject, function()
		                CloseAll()
		                local conditionType = missionData.data.conditionType
		                print(string.format("任务跳转,表格Id:%d, 条件类型:%d", missionData.data.id, conditionType))
		                missionJumpFunc()
		            end)
		        else
		            btn_go.gameObject:SetActive(false)
		        end
		    end
		else
			btn_go.gameObject:SetActive(false)
		end
		local showcolor = ""
		if --[[missionData.mission.value >= missionData.data.number]] missionData.mission.status == 2 then
			showcolor = "[4ABC1EFF]"
		else
			showcolor = "[ff0000]"
		end
		missionitem:Find("bg/name"):GetComponent("UILabel").text = Format(TextUtil.GetMissionTitle(missionData.data), missionData.mission.value, missionData.data.number)
		missionitem:Find("jindu"):GetComponent("UILabel").text = Format(TextMgr:GetText(_ui.configs["progress3"]), showcolor .. math.floor(missionData.mission.value / (missionData.data.conditionType == 78 and 60 or 1)) .. "[-]", math.floor(missionData.data.number / (missionData.data.conditionType == 78 and 60 or 1)))
		local btn_dis = missionitem:Find("btn_disabled").gameObject
		btn_dis:SetActive(missionData.mission.status == 1--[[missionData.mission.value < missionData.data.number]])
		if btn_go.gameObject.activeInHierarchy then
			btn_dis:SetActive(false)
		end
		missionitem:Find("btn_reward").gameObject:SetActive(not missionData.mission.rewarded and missionData.mission.status == 2--[[missionData.mission.value >= missionData.data.number]])
		missionitem:Find("complete").gameObject:SetActive(missionData.mission.rewarded)
		
		SetClickCallback(missionitem:Find("btn_reward").gameObject, function()
	        local req = ClientMsg_pb.MsgUserMissionRewardRequest();
	        req.taskid = missionData.mission.id
	        Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
	            if msg.code ~= ReturnCode_pb.Code_OK then
	                Global.FloatError(msg.code)
	            else
	                AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)

	                GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
	                MainCityUI.UpdateRewardData(msg.fresh)
	                Global.ShowReward(msg.reward)
	                MissionListData.SetRewarded(msg.taskid)
	                MissionListData.UpdateList(msg.quest)
	                -- send data report-----------
	                GUIMgr:SendDataReport("umission", "" .. msg.taskid, "completed", "0")
	                ------------------------------
	            end
	        end, true)
	    end)
		local itemgrid = missionitem:Find("reward/Grid")
		local itemcount = 0
		for ii, vv in ipairs(missionData.data.item:split(";")) do
			itemcount = ii
			local reward = vv:split(":")
			local itemprefab = itemgrid:GetChild(ii - 1)
			itemprefab.gameObject:SetActive(true)
			local itemData = TableMgr:GetItemData(tonumber(reward[1]))
			local item = {}
			UIUtil.LoadItemObject(item, itemprefab)
			UIUtil.LoadItem(item, itemData, tonumber(reward[2]))
			SetParameter(itemprefab.gameObject, "item_" .. reward[1])
		end
		for ii = itemcount + 1, 4 do
			itemgrid:GetChild(ii - 1).gameObject:SetActive(false)
		end
	end
	for i = index + 1, childcount do
		_ui.grid.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
	_ui.grid:Reposition()
	_ui.scroll:ResetPosition()
end
