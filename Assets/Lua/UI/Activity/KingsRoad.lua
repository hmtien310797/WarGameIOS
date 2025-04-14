module("KingsRoad", package.seeall)
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

local _ui, UpdateUI, UpdateDays, UpdateCenter, UpdateExchange, UpdateTab, UpdateMission, UpdateMoney, UpdateRedPoint, UpdateExchangeCoroutine, UpdateMissionCoroutine
local needresetposition = false
local cannotifymission = false
local cannotifyexchange = false
local cannotifymoney = false
local cannotifyredpoint = false

local function NotifyMission()
	if cannotifymission then
		UpdateMission()
	end
end

local function NotifyExchange()
	if cannotifyexchange then
		UpdateExchange()
	end
end

local function NotifyMoney()
	if cannotifymoney then
		UpdateMoney()
	end
end

local function NotifyRedPoint()
	if cannotifyredpoint then
		UpdateRedPoint()
	end
end

local function AddDepth(go, add)
	local widgets = go:GetComponentsInChildren(typeof(UIWidget))
	for i = 0, widgets.Length - 1 do
		widgets[i].depth = widgets[i].depth + add
	end
end

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
	cannotifymission = false
	cannotifyexchange = false
	cannotifymoney = false
	cannotifyredpoint = false
	Global.CloseUI(_M)
end

function CloseAll()
	CloseSelf()
	DailyActivity.CloseSelf()
end

local function InitData()
	local basedata = DailyActivityData.GetKingsRoadBaseData()
	_ui.missions = basedata.missions
	_ui.missiontable = basedata.missiontable
	_ui.redpoints = basedata.redpoints
	_ui.curday = basedata.curday
	_ui.totalday = basedata.totalday
	_ui.totalmissions = basedata.totalmissions
	_ui.exchangeItems = DailyActivityData.GetExchangeItems()
	_ui.exchangered = basedata.exchangered
	local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
	if _ui.redpointDayList == nil then
		_ui.redpointDayList = {}
	end
end

UpdateRedPoint = function()
	_ui.title1_redpoint1:SetActive(_ui.redpoints[_ui.selectday] ~= nil and _ui.redpoints[_ui.selectday][1] or false)
	_ui.title1_redpoint2:SetActive(_ui.redpoints[_ui.selectday] ~= nil and _ui.redpoints[_ui.selectday][2] or false)
	_ui.title1_redpoint3:SetActive(_ui.redpoints[_ui.selectday] ~= nil and _ui.redpoints[_ui.selectday][3] or false)
	_ui.redpointDayList[0]:SetActive(_ui.activity.state == 2 and _ui.exchangered or false)
	for i = 1, _ui.totalday do
		_ui.redpointDayList[i]:SetActive(false)
		if _ui.redpoints[i] ~= nil then
			for ii, vv in ipairs(_ui.redpoints[i]) do
				if vv then
					_ui.redpointDayList[i]:SetActive(true)
				end
			end
		end
	end
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	InitData()
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	
	_ui.title = transform:Find("Container/background/title/Label"):GetComponent("UILabel")
	_ui.title.text = TextMgr:GetText("activity_btn_text")
	
	_ui.title1 = transform:Find("Container/content/bg_right/bg_title").gameObject
	_ui.title1_btn1 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype").gameObject
	_ui.title1_btn1_toggle = _ui.title1_btn1:GetComponent("UIToggle")
	_ui.title1_text1 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype/text1"):GetComponent("UILabel")
	_ui.title1_downtext1 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype/Animation/btn_lv1_down/tab_title_down1"):GetComponent("UILabel")
	_ui.title1_redpoint1 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype/redpoint").gameObject
	_ui.title1_btn2 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (1)").gameObject
	_ui.title1_text2 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (1)/text1"):GetComponent("UILabel")
	_ui.title1_downtext2 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (1)/Animation/btn_lv1_down/tab_title_down1"):GetComponent("UILabel")
	_ui.title1_redpoint2 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (1)/redpoint").gameObject
	_ui.title1_btn3 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (2)").gameObject
	_ui.title1_text3 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (2)/text1"):GetComponent("UILabel")
	_ui.title1_downtext3 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (2)/Animation/btn_lv1_down/tab_title_down1"):GetComponent("UILabel")
	_ui.title1_redpoint3 = transform:Find("Container/content/bg_right/bg_title/btn_itemtype (2)/redpoint").gameObject
	_ui.title1_icon = transform:Find("Container/content/bg_right/bg_title/bg_right/icon_item"):GetComponent("UITexture")
	_ui.title1_text_time = transform:Find("Container/content/bg_right/bg_title/bg_right/text_time"):GetComponent("UILabel")
	_ui.title1_slider = transform:Find("Container/content/bg_right/bg_title/bg_right/addexp"):GetComponent("UISlider")
	_ui.title1_slider_text = transform:Find("Container/content/bg_right/bg_title/bg_right/addexp/jindu/Label"):GetComponent("UILabel")
	_ui.title1_help = transform:Find("Container/content/bg_right/bg_title/bg_right/btn_help").gameObject
	
	_ui.title2 = transform:Find("Container/content/bg_right/bg_title (1)").gameObject
	_ui.title2_itemnum = transform:Find("Container/content/bg_right/bg_title (1)/icon_item/Label"):GetComponent("UILabel")
	_ui.title2_text_time = transform:Find("Container/content/bg_right/bg_title (1)/bg_right/text_time"):GetComponent("UILabel")
	_ui.title2_help = transform:Find("Container/content/bg_right/bg_title (1)/bg_right/btn_help").gameObject
	_ui.title2_text_hint = transform:Find("Container/content/bg_right/bg_title (1)/bg_right/hint"):GetComponent("UILabel")
	
	_ui.left_scroll = transform:Find("Container/content/bg_left/Scroll View"):GetComponent("UIScrollView")
	_ui.left_grid = transform:Find("Container/content/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.left_item = transform:Find("Container/content/bg_left/Scroll View/Grid/btn_left_1")
	
	_ui.center_scroll = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
	_ui.center_mission_grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.center_mission_item = transform:Find("Container/listitem_GrowGold")
	_ui.center_exchange_grid = transform:Find("Container/content/Scroll View (1)/Grid (1)"):GetComponent("UIGrid")
	_ui.center_exchange_item = transform:Find("Container/SlgBagInfo")
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	SetClickCallback(_ui.container, CloseAll)
	SetClickCallback(_ui.mask, CloseAll)
	UpdateUI()
	
	CountDown.Instance:Add("KingsRoad", _ui.activity.endTime + 2, CountDown.CountDownCallBack(function(t)
		_ui.cur_time = t
		if t == "00:00:00" then
			CountDown.Instance:Remove("KingsRoad")
			ActivityData.RequestListData(function()
				CloseAll()
				DailyActivity.Show()
			end)
		else

			if _ui.activity.state == 1 then
				_ui.title1_text_time.text = Format(TextMgr:GetText(_ui.configs["lefttime"]), t)
				_ui.title2_text_time.text = Format(TextMgr:GetText(_ui.configs["lefttime"]), t)
			elseif _ui.activity.state == 2 then
				_ui.title1_text_time.text = Format(TextMgr:GetText(_ui.configs["elefttime"]), t)
				_ui.title2_text_time.text = Format(TextMgr:GetText(_ui.configs["elefttime"]), t)
			end
		end
	end))
	_ui.title2_text_hint.text = TextMgr:GetText(_ui.configs["title"])
	SetClickCallback(_ui.title1_help, function()
		DailyActivityHelp.Show(_ui.configs["HelpTitle"], _ui.configs["HelpContent"])
	end)
	SetClickCallback(_ui.title2_help, function()
		DailyActivityHelp.Show(_ui.configs["HelpTitle"], _ui.configs["HelpContent"])
	end)

	MoneyListData.AddListener(NotifyMoney)
	--ItemListData.AddListener(UpdateExchange)

	DailyActivityData.AddListener(InitData)
	--DailyActivityData.AddListener(UpdateMission)
	DailyActivityData.AddListener(NotifyRedPoint)

	DailyActivityData.NotifyUIOpened(_ui.activity.activityId)
end

function Close()
	CountDown.Instance:Remove("KingsRoad")
	coroutine.stop(UpdateExchangeCoroutine)
	coroutine.stop(UpdateMissionCoroutine)
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	MoneyListData.RemoveListener(NotifyMoney)
	ItemListData.RemoveListener(NotifyExchange)
	DailyActivityData.RemoveListener(InitData)
	DailyActivityData.RemoveListener(NotifyMission)
	DailyActivityData.RemoveListener(NotifyRedPoint)
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
		UpdateUI()
		DailyActivityData.NotifyUIOpened(_ui.activity.activityId)
	end
end

UpdateUI = function()
	_ui.selectday = _ui.curday
	if _ui.activity.state == 2 then
		_ui.selectday = 0
	end
	coroutine.start(function()
		coroutine.wait(1)
		cannotifymission = true
		cannotifyexchange = true
		cannotifymoney = true
		cannotifyredpoint = true
	end)
	UpdateDays()
	UpdateMoney()
	UpdateRedPoint()
end


UpdateDays = function()
	_ui.left_scroll:ResetPosition()
	local childcount = _ui.left_grid.transform.childCount
	local btnList = {}
	local changeSelect = function()
		for i = 0, #btnList do
			btnList[i].transform:Find("btn_xuanzhong").gameObject:SetActive(i == _ui.selectday)
			btnList[i]:GetComponent("UISprite").enabled = (i ~= _ui.selectday)
			btnList[i].transform:Find("txt_get").gameObject:SetActive(i ~= _ui.selectday)
		end
	end
	for i = 0, _ui.totalday do
		local btn
		if i < childcount then
			btn = _ui.left_grid.transform:GetChild(i).gameObject
		else
			btn = NGUITools.AddChild(_ui.left_grid.gameObject, _ui.left_item.gameObject)
		end
		btn:SetActive(true)
		if i == 0 then
			btn.transform:Find("txt_get"):GetComponent("UILabel").text = TextMgr:GetText(_ui.configs["exchange"])
			btn.transform:Find("btn_xuanzhong/txt_get (1)"):GetComponent("UILabel").text = TextMgr:GetText(_ui.configs["exchange"])
		else
			btn.transform:Find("txt_get"):GetComponent("UILabel").text = TextMgr:GetText(_ui.configs["day" .. i])
			btn.transform:Find("btn_xuanzhong/txt_get (1)"):GetComponent("UILabel").text = TextMgr:GetText(_ui.configs["day" .. i])
		end
		btn:GetComponent("UISprite").spriteName = "btn_kr2"
		btn:GetComponent("UIButton").normalSprite = "btn_kr2"
		if i > _ui.curday then
			btn.transform:Find("Sprite").gameObject:SetActive(true)
		else
			btn.transform:Find("Sprite").gameObject:SetActive(false)
		end
		if _ui.redpointDayList[i] == nil then
			_ui.redpointDayList[i] = btn.transform:Find("redpoint").gameObject
		end
		SetClickCallback(btn, function()
			if i > _ui.curday then
				local r = i
				if _ui.cur_time ~= nil then
					d = string.match(_ui.cur_time, "%d+:%d+:%d+")  
					r = ((i-1) == 0 and "" or ((i-1) .."d "))..d;
				end
				FloatText.Show(Format(TextMgr:GetText(_ui.configs["error1"]), r), Color.white)
				return
			end
			_ui.selectday = i
			_ui.selecttab = 1
			_ui.title1_btn1_toggle:Set(true)
			if _ui.selectday == 0 then
				_ui.exchangered = false
			end
			changeSelect()
			UpdateCenter()
			UpdateRedPoint()
		end)
		btnList[i] = btn
	end
	for i = _ui.totalday + 2, childcount do
		_ui.left_grid.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
	if _ui.activity.state == 1 and _ui.selectday > 4 then
		_ui.left_scroll:MoveRelative(Vector3(0, 80, 0))
	elseif _ui.activity.state == 2 then
		_ui.left_scroll:ResetPosition()
	end
	changeSelect()
	UpdateCenter()
end

UpdateCenter = function()
	if _ui.selectday == 0 then
		coroutine.stop(UpdateMissionCoroutine)
		_ui.title1:SetActive(false)
		_ui.title2:SetActive(true)
		_ui.center_exchange_grid.gameObject:SetActive(true)
		_ui.center_mission_grid.gameObject:SetActive(false)
		needresetposition = true
		UpdateExchange()
		DailyActivityData.RemoveListener(NotifyMission)
		ItemListData.AddListener(NotifyExchange)
	else
		coroutine.stop(UpdateExchangeCoroutine)
		_ui.title1:SetActive(true)
		_ui.title2:SetActive(false)
		_ui.center_exchange_grid.gameObject:SetActive(false)
		_ui.center_mission_grid.gameObject:SetActive(true)
		UpdateTab()
		UpdateMission()
		DailyActivityData.AddListener(NotifyMission)
		ItemListData.RemoveListener(NotifyExchange)
	end
	_ui.title1_icon.gameObject:SetActive(_ui.activity.state == 1)
	_ui.title1_slider.gameObject:SetActive(_ui.activity.state == 1)
	_ui.title1_text_time.gameObject:SetActive(_ui.activity.state == 1)
end

UpdateMoney = function()
	local money = MoneyListData.GetKingActive()
	_ui.title2_itemnum.text = "x" .. (money ~= nil and money or 0)
	_ui.title1_slider.value = (money ~= nil and money or 0) / _ui.totalmissions
	_ui.title1_slider_text.text = (money ~= nil and money or 0) .. "/" .. _ui.totalmissions
end

UpdateExchange = function()
	coroutine.stop(UpdateExchangeCoroutine)
	UpdateExchangeCoroutine = coroutine.start(function()
		local childcount = _ui.center_exchange_grid.transform.childCount
		--for i = 1, childcount do
		--	_ui.center_exchange_grid.transform:GetChild(i - 1).gameObject:SetActive(false)
		--end
		while _ui.exchangeItems == nil do
			coroutine.step()
		end
		for i = 1, #_ui.exchangeItems do
			local v = _ui.exchangeItems[i]
			local item
			if i <= childcount then
				item = _ui.center_exchange_grid.transform:GetChild(i - 1)
			else
				item = NGUITools.AddChild(_ui.center_exchange_grid.gameObject, _ui.center_exchange_item.gameObject).transform
			end
			item.gameObject:SetActive(true)
			local itemid = v.baseId
			local itemExId = v.exchangeId
			local itemData = TableMgr:GetItemData(itemid)
			local itemtrans = item.transform:Find("bg_list/bg_icon/Item_CommonNew")
			--name
			local name = item.transform:Find("bg_list/text_name"):GetComponent("UILabel")
			local textColor
			textColor = Global.GetLabelColorNew(itemData.quality)
			name.text = textColor[0] .. TextUtil.GetItemName(itemData) .. (v.num > 1 and ("x" .. v.num) or "") .. "[-]"
			--des
			local des = item.transform:Find("bg_list/text_name/text_des"):GetComponent("UILabel")
			des.text = TextUtil.GetItemDescription(itemData)
			
			local buyBtn  = item.transform:Find("bg_list/btn_use_gold")
			if v.maxBuyNum - v.currentBuyNum > 0 then
				buyBtn:GetComponent("UISprite").spriteName = "btn_1"
				buyBtn:GetComponent("UIButton").normalSprite = "btn_1"
			else
				buyBtn:GetComponent("UISprite").spriteName = "btn_4"
				buyBtn:GetComponent("UIButton").normalSprite = "btn_4"
			end
			SetClickCallback(buyBtn.gameObject, function()
				cannotifyexchange = true
				cannotifymoney = true
				cannotifyredpoint = true
				DailyActivityData.ShopBuyRequest(itemExId, 1)
			end)
			--num
			local num = item.transform:Find("bg_list/txt_num/num"):GetComponent("UILabel")
			num.text = v.maxBuyNum - v.currentBuyNum
			buyBtn.gameObject:SetActive(true)
			local money = item.transform:Find("bg_list/btn_use_gold/num"):GetComponent("UILabel")
			money.text = v.price
			
			local _item = {}
			UIUtil.LoadItemObject(_item, itemtrans)
			UIUtil.LoadItem(_item, itemData, v.contentNumber)
			coroutine.step()
			_ui.center_exchange_grid:Reposition()
		end
		for i = #_ui.exchangeItems + 1, childcount do
			_ui.center_exchange_grid.transform:GetChild(i - 1).gameObject:SetActive(false)
		end
		_ui.center_exchange_grid:Reposition()
		if needresetposition then
			_ui.center_scroll:ResetPosition()
			needresetposition = false
		end
	end)
end

UpdateTab = function()
	if _ui.selecttab == nil then
		_ui.selecttab = 1
	end
	_ui.title1_text1.text = TextMgr:GetText(_ui.configs["day" .. _ui.selectday .. "tab1"])
	_ui.title1_downtext1.text = _ui.title1_text1.text
	SetClickCallback(_ui.title1_btn1, function()
		_ui.selecttab = 1
		UpdateMission()
	end)
	_ui.title1_text2.text = TextMgr:GetText(_ui.configs["day" .. _ui.selectday .. "tab2"])
	_ui.title1_downtext2.text = _ui.title1_text2.text
	SetClickCallback(_ui.title1_btn2, function()
		_ui.selecttab = 2
		UpdateMission()
	end)
	_ui.title1_text3.text = TextMgr:GetText(_ui.configs["day" .. _ui.selectday .. "tab3"])
	_ui.title1_downtext3.text = _ui.title1_text3.text
	SetClickCallback(_ui.title1_btn3, function()
		_ui.selecttab = 3
		UpdateMission()
	end)
end

UpdateMission = function()
	coroutine.stop(UpdateMissionCoroutine)
	local childcount = _ui.center_mission_grid.transform.childCount
	local index = 0
	if _ui.selectday > 0 then
		table.sort(_ui.missions[_ui.selectday][_ui.selecttab], function(a, b)
			if _ui.missiontable[a].mission.rewarded and not _ui.missiontable[b].mission.rewarded then
				return false
			elseif _ui.missiontable[b].mission.rewarded and not _ui.missiontable[a].mission.rewarded then
				return true
			end
			if _ui.missiontable[a].mission.status == 2 and _ui.missiontable[b].mission == 1--[[_ui.missiontable[a].mission.value >= _ui.missiontable[a].data.number and _ui.missiontable[b].mission.value < _ui.missiontable[b].data.number]] then
				return true
			elseif _ui.missiontable[a].mission.status == 1 and _ui.missiontable[b].mission == 2--[[_ui.missiontable[a].mission.value < _ui.missiontable[a].data.number and _ui.missiontable[b].mission.value >= _ui.missiontable[b].data.number]] then
				return false
			end
			return a < b
		end)
		UpdateMissionCoroutine = coroutine.start(function()
			for i, v in ipairs(_ui.missions[_ui.selectday][_ui.selecttab]) do
				index = i
				local missionData = _ui.missiontable[v]
				local missionitem
				if i - 1 < childcount then
					missionitem = _ui.center_mission_grid.transform:GetChild(i - 1)
				else
					missionitem = NGUITools.AddChild(_ui.center_mission_grid.gameObject, _ui.center_mission_item.gameObject).transform
				end
				missionitem.gameObject:SetActive(true)
				local btn_go = missionitem:Find("btn_go"):GetComponent("UIButton")
				if not missionData.mission.rewarded and missionData.data.conditionType ~= 71 and missionData.data.conditionType ~= 72 and missionData.data.conditionType ~= 73 and missionData.data.conditionType ~= 78 and missionData.data.conditionType ~= 80 and missionData.data.conditionType ~= 46 and missionData.data.conditionType ~= 45 and missionData.data.conditionType ~= 63 and missionData.data.conditionType ~= 87 and missionData.data.conditionType ~= 96 then
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
					cannotifymission = true
					cannotifymoney = true
					cannotifyredpoint = true
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
					local itemData = TableMgr:GetItemData(reward[1])
					local item = {}
					UIUtil.LoadItemObject(item, itemprefab)
					UIUtil.LoadItem(item, itemData, tonumber(reward[2]))
					SetParameter(itemprefab.gameObject, "item_" .. reward[1])
				end
				for ii = itemcount + 1, 4 do
					itemgrid:GetChild(ii - 1).gameObject:SetActive(false)
				end
				_ui.center_mission_grid:Reposition()
				coroutine.step()
			end
			for i = index + 1, childcount do
				_ui.center_mission_grid.transform:GetChild(i - 1).gameObject:SetActive(false)
			end
		end)
	end
	_ui.center_mission_grid:Reposition()
	_ui.center_scroll:ResetPosition()
end

function Test()
	local activitys = DailyActivityData.GetActivitys()
	for i, v in ipairs(activitys) do
		if v.activityId == 1001 then
			Show(v)
		end
	end
end
