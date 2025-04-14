module("Christmas", package.seeall)

local GUIMgr = Global.GGUIMgr
GGUIMgr = GUIMgr.Instance
local GameTime = Serclimax.GameTime
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local welfare

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

local _ui, UpdateUI, UpdateTop, isInView
local ChristmasInfo 

------ Constants ------
local WELFARE_ID = 3001
-----------------------
local function OnUICameraPress(go, pressed)
	if not pressed then
		return
    end
    if go.name == "BigCollider(Clone)" then
        if UICamera.lastEventPosition.x > 254 and UICamera.lastEventPosition.x < 616 and UICamera.lastEventPosition.y > 134 and UICamera.lastEventPosition.y < 304 then
         --   finishDraw()
            return
        end
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

function GetDegreByType(t,score)
	score = tonumber(score)
	local min_ 
	local max_ 
	local degre = 1
	local need = 1;
	local cur = 0;
	print("GetDegreByType gg ",t,score)
	
	for i=1,#tableData_tChristmasActivity.data,1 do
		local v = tableData_tChristmasActivity.data[i]
		if v.RewardType == t then 

			local n = tableData_tChristmasActivity.data[v.id+1]
			if n ~= nil and n.RewardType ~= t then 
				 n = nil;
			end 
			if n ~= nil then 
				if score >=v.PointsRequired and score< n.PointsRequired then 
					need = n.PointsRequired -  v.PointsRequired
					cur = score - v.PointsRequired
					print("GetDegreByType ",t,score, degre,n.PointsRequired,v.PointsRequired)
					break
				elseif score< v.PointsRequired	and degre == 1  then 
					need = v.PointsRequired
					cur = score
					degre = 0
					break
				end 
				need = n.PointsRequired -  v.PointsRequired
				cur = n.PointsRequired -score 
				
				if cur < 0 then 
					cur = need;
				end 
			end 

			degre = degre +1
		end
	end

	local info = {};
	info.need = need;
	info.cur = cur;
	info.degre = degre;
	
	return info
end 

function GetDegre()
	return GetDegreByType(2,tonumber(ChristmasInfo.treeScore))
end 

function GetSelfDegre()
	return GetDegreByType(1,tonumber(ChristmasInfo.selfScore))
end 

function IsGetTreeReward(item)
	local info = GetDegreByType(2,item.PointsRequired)
	
	if ChristmasInfo.getTreeReward ~= nil then 
		for _, v in pairs(ChristmasInfo.getTreeReward) do
			if v == item.id then -- == info.degre then 
				return true
			end
		end
	end 
	
	return false
end 

function IsCanGetTreeReward(item)
	local score = ChristmasInfo.treeScore

	if score >= item.PointsRequired then 
		return true;
	elseif score < item.PointsRequired then 
		return false
	else 
		return true;
	end 
end 

function IsGetSelfReward(item)
	local info = GetDegreByType(1,item.PointsRequired)
	
	if ChristmasInfo.getScoreReward ~= nil then 
		for _, v in pairs(ChristmasInfo.getScoreReward) do
			if v == item.id then -- info.degre then 
				return true
			end
		end
	end 
	
	return false
end 

function IsCanGetSelfReward(item)
	local score = ChristmasInfo.selfScore
	-- print("IsCanGetSelfReward ", score , item.PointsRequired)
	if score >= item.PointsRequired then 
		return true;
	elseif score < item.PointsRequired then 
		return false
	else 
		return true;
	end 
end 


function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.mask = transform:Find("mask").gameObject
	_ui.rewardshow = ResourceLibrary.GetUIPrefab("ActivityStage/GrowRewards")
	_ui.starSlider = transform:Find("Container/content/right/bg_star/bg_schedule/bg_slider"):GetComponent("UISlider")
    _ui.starLabel = transform:Find("Container/content/right/bg_star/icon_star/num"):GetComponent("UILabel")
	_ui.treeLabel = transform:Find("Container/content/banner/bg_jindu/bg_progress/Label"):GetComponent("UILabel")
	_ui.treeSlider = transform:Find("Container/content/banner/bg_jindu/bg_progress/icon_progress"):GetComponent("UISlider")
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.degreLabel = transform:Find("Container/content/banner/name"):GetComponent("UILabel")
	
	_ui.time_line1 = transform:Find("Container/content/banner/time"):GetComponent("UILabel")

	local rewardList = {}
    for i = 1, 6 do
        local reward = {}
        local rewardTransform = transform:Find("Container/content/right/bg_star/icon_item" .. i)
        reward.transform = rewardTransform
        reward.gameObject = rewardTransform.gameObject
        reward.iconSprite = rewardTransform:GetComponent("UISprite")
        reward.numberLabel = rewardTransform:Find("num"):GetComponent("UILabel")
        reward.shineObject = rewardTransform:Find("ShineItem").gameObject
        rewardList[i] = reward
    end

    _ui.rewardList = rewardList
	
	_ui.help = transform:Find("Container/content/banner/button_ins").gameObject
	
	_ui.grid = transform:Find("Container/content/right/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("Container/content/right/item_bg")
	
	_ui.missionlist = {15033,15034,15035,15036};

	--AddDelegate(UICamera, "onPress", OnUICameraPress)
	
	SetClickCallback(_ui.help, function()
		ChristmasHelp.Show()
	end)
	
	_ui.rewardShineItem = transform:Find("Container/content/banner/reward_icon/ShineItem").gameObject
	
	UIUtil.SetClickCallback(transform:Find("Container/content/banner/reward_icon").gameObject, function()
         ChristmasRewards.Show()
	
    end)
	

	UIUtil.SetClickCallback(transform:Find("Container/content/banner/rank_icon").gameObject, function()
         ChristmasRank.Show()
    end)
	
end

UpdateDown = function()
	local childcount = _ui.grid.transform.childCount
	local index = 0
	for i =1,#_ui.missionlist,1 do
		index = i
		local id = _ui.missionlist[i]
		local missionitem
		if i - 1 < childcount then
			missionitem = _ui.grid.transform:GetChild(i - 1)
		else
			missionitem = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
		end
		missionitem.gameObject:SetActive(true)
		
		local num = ItemListData.GetItemCountByBaseId(id)

		missionitem:Find("text"):GetComponent("UILabel").text = Format(TextMgr:GetText("Christmas_ui4"),num)
		local itemdata = TableMgr:GetItemData(id)
		if itemdata ~=nil then

			missionitem:Find("item/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
		else 
			missionitem:Find("item/Texture"):GetComponent("UITexture").mainTexture = nil
		end 
		local btn_dis = missionitem:Find("sign_btn/btn_disabled").gameObject
		btn_dis:SetActive(num== 0)
		
		missionitem:Find("sign_btn/btn_reward").gameObject:SetActive(num>0)
		

        UIUtil.SetClickCallback(missionitem:Find("item").gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
            end
        end)
		
		
		
		SetClickCallback(missionitem:Find("sign_btn/btn_reward").gameObject, function()
	        local req = ActivityMsg_pb.MsgChristmasDonateRequest();
			req.id =id 
			req.num = num
			
			Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgChristmasDonateRequest,req, ActivityMsg_pb.MsgChristmasDonateResponse, function(msg)
	             Global.DumpMessage(msg, "d:/MsgChristmasDonateResponse.lua")
				if msg.code ~= ReturnCode_pb.Code_OK then
	                Global.FloatError(msg.code)
	            else
	                AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
					ReqMsgChristmasInfoRequest();
	             -- GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
	                MainCityUI.UpdateRewardData(msg.fresh)
					FloatText.Show(Format(TextMgr:GetText("Christmas_ui9"),msg.selfScore - ChristmasInfo.selfScore), Color.green, nil)
					ChristmasInfo.selfScore = msg.selfScore;
					ChristmasInfo.treeScore = msg.treeScore;
					UpdateDegre();

	            end
	        end, true)
	    end)
	end
	for i = index + 1, childcount do
		_ui.grid.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
	_ui.grid:Reposition()
end

function ItemSortFunction(v1, v2)
    return v1.PointsRequired < v2.PointsRequired
end

UpdateUI = function()
	if ChristmasInfo == nil then 
		ChristmasInfo = {};
		ChristmasInfo.selfScore = 0
		ChristmasInfo.treeScore = 0
	end 
	
	coroutine.stop(_ui.countdowncoroutine)
		_ui.countdowncoroutine = coroutine.start(function()

			while true do
				
				if _ui == nil then 
					break;
				end
				ReqMsgChristmasInfoRequest();

				coroutine.wait(60)
			end
		end)
	
	UpdateTop()
	UpdateDown();
	UpdateDegre();
	
	ReqMsgChristmasInfoRequest();
end

ShowMissionReward = function(showReward,score)
	local showgo = NGUITools.AddChild(GUIMgr.UIRoot.gameObject, _ui.rewardshow)
	local showtrans = showgo.transform
	local _show = {}
	_show.bg = showtrans:Find("Container")
	_show.listGrid = showtrans:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_show.getButton = showtrans:Find("Container/bg_frane/button"):GetComponent("UIButton")
	_show.getLabel = showtrans:Find("Container/bg_frane/button/Label"):GetComponent("UILabel")
	_show.growHint = showtrans:Find("Container/bg_frane/bg_hint").gameObject
	_show.dailyHint = showtrans:Find("Container/bg_frane/bg_dailymission").gameObject
	_show.dailyHintLabel = showtrans:Find("Container/bg_frane/bg_dailymission/text"):GetComponent("UILabel")
    _show.dailyHintLabel.text = ""
    _show.getLabel.text = TextMgr:GetText("common_hint1")
    _show.getButton.gameObject:SetActive(true)
	_show.dailyHintLabel.text = Format(TextMgr:GetText("PVP_ATK_Activity_ui18"),score)
	

	
	local rewardIndex = 1
	for v in string.gsplit(showReward.Reward, ";") do
		local itemTable = string.split(v, ":")
		local itemId, itemCount = tonumber(itemTable[2]), tonumber(itemTable[3])
		local itemdata = TableMgr:GetItemData(itemId)
        local item = NGUITools.AddChild(_show.listGrid.gameObject, _ui.itemPrefab).transform
        local reward = {}
        UIUtil.LoadItemObject(reward, item)
        UIUtil.LoadItem(reward, itemdata, itemCount)
        UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
            end
        end)
		
	end 

	_show.listGrid:Reposition()
	SetClickCallback(_show.bg.gameObject, function()
		GameObject.Destroy(showgo)
		_show = nil
	end)
	SetClickCallback(_show.getButton.gameObject, function()
		GameObject.Destroy(showgo)
		_show = nil
	end)
	showgo:SetActive(true)
	GUIMgr:BringForward(showgo)
end


function UpdateDegre()
	if _ui ==nil then 
		return 
	end 
	
	local show  = false;
	for _, v in pairs(tableData_tChristmasActivity.data) do

		if v.RewardType == 2 then 
			if Christmas.IsGetTreeReward(v)== false  and Christmas.IsCanGetTreeReward(v) then 
				show = true
			end 
		end
		
	end
	
	_ui.rewardShineItem:SetActive(show)
	
	
	UpdateDown();
	local info = GetSelfDegre()
	_ui.starLabel.text = Format(TextMgr:GetText("Christmas_ui7"),ChristmasInfo.selfScore)
	local f = info.cur / info.need
	print("_________________",info.degre,info.cur,info.need)
	if info.degre == 0 then 
		f = f * 0.29
	else 
		f = f * 0.145 + info.degre*0.145 + 0.145 
	end 
	
	_ui.starSlider.value = f
	
	info = GetDegre()
	_ui.degreLabel.text = Format(TextMgr:GetText("Christmas_ui5"),info.degre)
	_ui.treeLabel.text = string.format("%d/%d", info.cur, info.need)
	_ui.treeSlider.value = info.cur / info.need
	local dataList = {}
	for _, v in pairs(tableData_tChristmasActivity.data) do
		if v.RewardType == 1 then 
			table.insert(dataList, v)
		end
	end
	
	table.sort(dataList,ItemSortFunction)

	local typeList = {"s" , "m" , "b"}
    for i, v in ipairs(_ui.rewardList) do
        local starCount = tonumber(dataList[i].PointsRequired)
		
		if v.shineObject == nil then 
			break;
		end 

		local status = "_null"
		-- print("__ IsGetSelfReward ",Christmas.IsGetSelfReward(dataList[i]),Christmas.IsCanGetSelfReward(dataList[i]))
		if Christmas.IsGetSelfReward(dataList[i]) then 
			if i ==1 then 
				s = "icon_starbox_s_open_dm";
			elseif i ==2 then 
				s = "icon_starbox_s_open";
			elseif i ==3 then 
				s = "icon_starbox_m_open_dm";
			elseif i ==4 then 
				s = "icon_starbox_m_open";
			elseif i ==5 then 
				s = "icon_starbox_b_open_dm";
			elseif i ==6 then 
				s = "icon_starbox_b_open";
			end
			v.shineObject:SetActive(false)
		else
			if Christmas.IsCanGetSelfReward(dataList[i]) then 
				if i ==1 then 
					s = "icon_starbox_s_done_dm";
				elseif i ==2 then 
					s = "icon_starbox_s_done";
				elseif i ==3 then 
					s = "icon_starbox_m_done_dm";
				elseif i ==4 then 
					s = "icon_starbox_m_done";
				elseif i ==5 then 
					s = "icon_starbox_b_done_dm";
				elseif i ==6 then 
					s = "icon_starbox_b_done";
				end
				v.shineObject:SetActive(true)
			else
				if i ==1 then 
					s = "icon_starbox_s_null_dm";
				elseif i ==2 then 
					s = "icon_starbox_s_null";
				elseif i ==3 then 
					s = "icon_starbox_m_null_dm";
				elseif i ==4 then 
					s = "icon_starbox_m_null";
				elseif i ==5 then 
					s = "icon_starbox_b_null_dm";
				elseif i ==6 then 
					s = "icon_starbox_b_null";
				end
				v.shineObject:SetActive(false)
			end 
		end
		
		
		
		
		v.iconSprite.spriteName = s
        
        v.numberLabel.text = starCount
		if v.shineObject.activeSelf ==false then 
			SetClickCallback(v.gameObject, function(go)
				ShowMissionReward(dataList[i],dataList[i].PointsRequired)
			end)
			
		else 
			SetClickCallback(v.gameObject, function(go)
				local inf = GetDegreByType(1,dataList[i].PointsRequired)
				local req = ActivityMsg_pb.MsgChristmasGetScoreRewardRequest();
				req.index = dataList[i].id --inf.degre -- dataList[i].id
				print("MsgChristmasGetScoreRewardRequest ",i,dataList[i].PointsRequired, req.index)
				Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgChristmasGetScoreRewardRequest,req, ActivityMsg_pb.MsgChristmasGetScoreRewardResponse, function(msg)
					Global.DumpMessage(msg)
					if msg.code ~= ReturnCode_pb.Code_OK then
						Global.ShowError(msg.code)
					else
						ReqMsgChristmasInfoRequest();
						AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
						MainCityUI.UpdateRewardData(msg.fresh)
						Global.ShowReward(msg.reward)
					end
				end, true)
			end)
		end 
    end
end 


function IsNotice()
	local missionlist = {15033,15034,15035,15036};
	for i =1,#missionlist,1 do
		local id = missionlist[i]
		local num = ItemListData.GetItemCountByBaseId(id)
		if num > 0 then 
			return true;
		end 
	end 
	
	for _, v in pairs(tableData_tChristmasActivity.data) do
		if v.RewardType == 1 then 
			if Christmas.IsGetSelfReward(v)== false  and Christmas.IsCanGetSelfReward(v) then 
				return true
			end 
		end
		if v.RewardType == 2 then 
			if Christmas.IsGetTreeReward(v)== false  and Christmas.IsCanGetTreeReward(v) then 
				return true
			end 
		end
		
	end
	
	return false

end 

function HasNotice(activityId)
	if ChristmasInfo == nil then 
		ReqMsgChristmasInfoRequest(function()
			DailyActivityData.GetRedpoints()[activityId] = IsNotice()
		end)
		return false
	end 
	return IsNotice()
end 


function ReqMsgChristmasInfoRequest(cb)
	print("ReqMsgChristmasInfoRequest")
	local req = ActivityMsg_pb.MsgChristmasInfoRequest();
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgChristmasInfoRequest,req, ActivityMsg_pb.MsgChristmasInfoResponse, function(msg)
		Global.DumpMessage(msg,"d:/MsgChristmasInfoResponse.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			ChristmasInfo = msg;
			-- ChristmasInfo.selfScore = 1800
			UpdateDegre()
            if cb ~= nil then
                cb(msg)
            end
        end
    end, true)
end

function GetSelfScore()
	return ChristmasInfo and ChristmasInfo.selfScore or 0
end

function Show(activityMsg)
	--[[if activityId == nil or templet == nil then
		print("############### Activity is null ###############")
		return
	end]]
	if _ui == nil then
		_ui = {}
	end
	
	
    if isInView then
        UpdateUI()
    else
		_ui.activityMsg = activityMsg
        Global.OpenUI(_M)
        isInView = true
		
    end

end

UpdateTop = function()
	if _ui == nil or _ui.activityMsg == nil then 
		return 
	end 
--	if _ui.configs["lefttime"] ~= nil then
	--	DisplayBannerTime1(true)
		CountDown.Instance:Add("Christmas", ActivityData.GetActivityConfig(_ui.activityMsg.activityId).endTime, CountDown.CountDownCallBack(function(t)
			if t == "00:00:00" then
				ActivityData.RequestListData(function()
					-- CloseAll()
				end)
			else
				_ui.time_line1.text = t --Format(TextMgr:GetText(_ui.configs["lefttime"]),t)
			end
		end))
end


function GetCooldown(onlyCooldownSecond)
    local utcOffset = 0
    local platformType = GGUIMgr:GetPlatformType()
    if Global.IsIosMuzhi() or
        platformType == LoginMsg_pb.AccType_adr_muzhi or
        platformType == LoginMsg_pb.AccType_adr_opgame or
        platformType == LoginMsg_pb.AccType_self_adr or
        platformType == LoginMsg_pb.AccType_adr_mango or 
        platformType == LoginMsg_pb.AccType_adr_official or
        platformType == LoginMsg_pb.AccType_ios_official or
        platformType == LoginMsg_pb.AccType_adr_official_branch or
        platformType == LoginMsg_pb.AccType_adr_quick then
        utcOffset = 3600 * 8
    end

    local serverTime = GameTime.GetSecTime()
    local todaySecond = (serverTime % (3600 * 24))
    local cooldownSecond = (3600 * 60 - utcOffset) % (3600 * 24)
    
    if onlyCooldownSecond then
        return cooldownSecond
    end
    if todaySecond < cooldownSecond then
        return serverTime - todaySecond + cooldownSecond
    else
        return serverTime - todaySecond + cooldownSecond + 3600 * 24
    end
end

function Start()
	SetClickCallback(_ui.mask, HideAll)
	UpdateUI()
end

function Hide()
	Global.CloseUI(_M)
end

function HideAll()
    WelfareAll.Hide()
end

function Refresh()
    if isInView then
        UpdateUI()
    end
end

function Close()
	if _ui ~= nil and _ui.countdowncoroutine ~= nil then 
		coroutine.stop(_ui.countdowncoroutine)
	end 
	ui = nil
	isInView = nil

	CountDown.Instance:Remove(_M._NAME)
	--RemoveDelegate(UICamera, "onPress", OnUICameraPress)

end

function CloseSelf()
    Hide()
end
