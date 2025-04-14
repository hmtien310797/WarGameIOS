module("ReturnRewards", package.seeall)
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

local _ui, UpdateUI, UpdateDown, _data

function RequestData()
    local req = ActivityMsg_pb.MsgComebackGetInfoRequest()
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgComebackGetInfoRequest, req, ActivityMsg_pb.MsgComebackGetInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.FloatError(msg.code)
        else
			_data = msg
			if _ui ~= nil then
				UpdateDown()
			end
			MainCityUI.UpdateReturnActivity()
        end
    end, true)
end

function HasUnclaimedAward(id)
	local missionMsgList = MissionListData.GetData()
	for i,v in pairs(missionMsgList) do
		local mdata = TableMgr:GetMissionData(v.id)
		if mdata ~= nil and mdata.ActivityID == id then
			if not v.rewarded and v.status == 2 then
				return true
			end
		end
	end
	return false
end

function IsInTime()
	if not ActivityData.IsActivityAvailable(33001) then
		return false
	end
	if _data == nil then
		return false
	end
	return _data.time > Serclimax.GameTime.GetSecTime()
end

local function HasNotice(page)
	if _ui.missionlist == nil then
		return false
	end
	for i,v in pairs(_ui.missionlist) do
		if v.data ~= nil and v.data.ActivityID == _ui.activity.activityId and v.data.type2 == page then
			if not v.mission.rewarded and v.mission.status == 2 then
				return true
			end
		end
	end
	if page == 102 then
		if _data.charge < _ui.goldnum then
			return true
		end
	end
	return false
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

function Hide()
	Global.CloseUI(_M)
end

function HideAll()
	WelfareAll.Hide()
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	MissionListData.RemoveListener(UpdateUI)
	CountDown.Instance:Remove("returnrewards")
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
        Global.OpenUI(_M)
	else
		if _ui.activity.activityId == activityId and _ui.activity.templet == templet then
			return
		end
	end
	_ui.activity.activityId = activityId
	_ui.activity.templet = templet
	print(_ui.activity.activityId, _ui.activity.templet)
end

local function doSelect(index, isclick)
	if isclick and _ui.lastpage == index + 100 then
		return
	end
	for i = 1, #_ui.pageList do
		_ui.pageList[i].select:SetActive(index == i)
	end
	_ui.page = 100 + index
	_ui.lastpage = _ui.page
	UpdateDown()
end

function Refresh()
	UpdateDown()
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.goldnum = tonumber(tableData_tGlobal.data[100280].value)
	_ui.page = 101
	_ui.lastpage = 0
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	
	_ui.text_line = transform:Find("Container/content/banner/tips01"):GetComponent("UILabel")
	_ui.time_text = transform:Find("Container/content/banner/time"):GetComponent("UILabel")
	
	_ui.scroll = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("Container/content/listitem_GrowGold")

	_ui.rewarditem = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.rewardhero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

	_ui.pageList = {}
	for i = 1, 2 do
		_ui.pageList[i] = {}
		_ui.pageList[i].go = transform:Find(string.format("Container/content/left/Scroll View/Grid/btn_left_%d", i)).gameObject
		_ui.pageList[i].select = _ui.pageList[i].go.transform:Find("btn_xuanzhong").gameObject
		_ui.pageList[i].red = _ui.pageList[i].go.transform:Find("redpoint").gameObject
		SetClickCallback(_ui.pageList[i].go, function()
			doSelect(i, true)
		end)
	end
	CountDown.Instance:Add("returnrewards", _data.time, function(t)
		_ui.time_text.text = t
	end)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	MissionListData.AddListener(UpdateUI)
end

function Start()
	SetClickCallback(_ui.container, HideAll)
	SetClickCallback(_ui.mask, HideAll)
	UpdateUI()
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
		if a.mission.status == 2 and b.mission.status == 1 then
			return true
		elseif a.mission.status == 1 and b.mission.status == 2 then
			return false
		end
		return a.data.id < b.data.id
	end)
    doSelect(_ui.page - 100)
end

UpdateDown = function()
	_ui.pageList[1].red:SetActive(HasNotice(101))
	_ui.pageList[2].red:SetActive(HasNotice(102))
	local childcount = _ui.grid.transform.childCount
	local index = 0
	for i = index + 1, childcount do
		_ui.grid.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
	local requestreward = function(missionData)
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
				WelfareAll.UpdateNotice(_ui.activity.activityId)
				MainCityUI.UpdateReturnActivity()
			end
		end, true)
	end
	_ui.text_line.text = _ui.page == 101 and TextMgr:GetText("activity_content_126") or Format(TextMgr:GetText("activity_content_127"), _ui.goldnum)
	local isfinish = false
	for i, v in ipairs(_ui.missionlist) do
		if v.data.type2 == _ui.page then
			index = index + 1
			local missionData = v
			local missionitem
			if index - 1 < childcount then
				missionitem = _ui.grid.transform:GetChild(index - 1)
			else
				missionitem = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
			end
			missionitem.gameObject:SetActive(true)

			local pay_trans = missionitem:Find("Pay_btn ")
			local sign_trans = missionitem:Find("sign_btn")
			local sign_reward = sign_trans:Find("btn_reward").gameObject
			local sign_disabled = sign_trans:Find("btn_disabled").gameObject
			local pay_reward = pay_trans:Find("btn_reward").gameObject
			local pay_go = pay_trans:Find("btn_go").gameObject
			
			pay_trans.gameObject:SetActive(_ui.page == 102 and not missionData.mission.rewarded)
			sign_trans.gameObject:SetActive(_ui.page == 101 and not missionData.mission.rewarded)
			sign_reward:SetActive(_ui.page == 101 and not missionData.mission.rewarded and missionData.mission.status == 2)
			sign_disabled:SetActive(_ui.page == 101 and not missionData.mission.rewarded and missionData.mission.status == 1)
			pay_reward:SetActive(_ui.page == 102 and not missionData.mission.rewarded and missionData.mission.status == 2)
			pay_go:SetActive(_ui.page == 102 and not missionData.mission.rewarded and missionData.mission.status == 1)

			local progress = missionitem:Find("bg/text"):GetComponent("UILabel")
			progress.text = Format(TextMgr:GetText("activity_content_5"), missionData.mission.value, missionData.data.number)

			SetClickCallback(sign_reward, function()
				requestreward(missionData)
			end)
			SetClickCallback(pay_reward, function()
				requestreward(missionData)
			end)
			SetClickCallback(pay_go, function()
				Goldstore.Show()
			end)

			if _ui.page == 102 then
				local num1 = pay_trans:Find("jindu/number1"):GetComponent("UILabel")
				local num2 = pay_trans:Find("jindu/number2"):GetComponent("UILabel")
				num2.text = _ui.goldnum
				num1.text = (_data.charge >= _ui.goldnum and "[00ff00]" or "[ff0000]") .. (_data.charge >= _ui.goldnum and _ui.goldnum or _data.charge) .. "[-]/"
				if not isfinish and missionData.mission.status == 1 and _data.charge < _ui.goldnum then
					pay_trans:Find("jindu").gameObject:SetActive(true)
					isfinish = true
				else
					pay_trans:Find("jindu").gameObject:SetActive(false)
				end
			end

			missionitem:Find("bg/name"):GetComponent("UILabel").text = Format(TextUtil.GetMissionTitle(missionData.data), missionData.mission.value, missionData.data.number)
			missionitem:Find("complete").gameObject:SetActive(missionData.mission.rewarded)

			local itemgrid = missionitem:Find("reward/Grid"):GetComponent("UIGrid")

			while itemgrid.transform.childCount > 0 do
				GameObject.DestroyImmediate(itemgrid.transform:GetChild(0).gameObject)
			end
			if missionData.data.hero ~= "" then
				local heroData = TableMgr:GetHeroData(tonumber(missionData.data.hero))
				local hero = NGUITools.AddChild(itemgrid.gameObject, _ui.rewardhero.gameObject).transform
				hero.localScale = Vector3.one * 0.6
				hero:Find("level text").gameObject:SetActive(false)
				hero:Find("name text").gameObject:SetActive(false)
				hero:Find("bg_skill").gameObject:SetActive(false)
				hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
				hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
				local star = hero:Find("star"):GetComponent("UISprite")
				if star ~= nil then
					star.width = v.star * star.height
				end
				local number = hero:Find("num"):GetComponent("UILabel")
				number.text = v.num
				number.transform.localScale = Vector3.one / 0.6
				if v.num > 1 then
					number.gameObject:SetActive(true)
				else
					number.gameObject:SetActive(false)
				end
				SetParameter(hero:Find("head icon").gameObject, "hero_" .. missionData.data.hero)
			end
			
			for ii, vv in ipairs(missionData.data.item:split(";")) do
				local reward = vv:split(":")
				local itemprefab = NGUITools.AddChild(itemgrid.gameObject, _ui.rewarditem.gameObject).transform
				itemprefab.gameObject:SetActive(true)
				local itemData = TableMgr:GetItemData(tonumber(reward[1]))
				local item = {}
				UIUtil.LoadItemObject(item, itemprefab)
				UIUtil.LoadItem(item, itemData, tonumber(reward[2]))
				SetParameter(itemprefab.gameObject, "item_" .. reward[1])
			end

			itemgrid:Reposition()
		end
	end
	_ui.grid:Reposition()
	_ui.scroll:ResetPosition()
end
