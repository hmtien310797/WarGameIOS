module("ActivityNotice", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local GameObject = UnityEngine.GameObject
local String = System.String

local _ui

local function CloseSelf()
	Global.CloseUI(_M)
end

local rechargeData, consumeData, updateRecharge, updateConsume, updateNormal

local activityData, check1, check2

local function MakeDataTable(_data)
	check1 = false
	check2 = false
	activityData = {}
	for i, v in ipairs(_data) do
		local adata = {}
		adata.name = v.pageName
		adata.type = v.pageType
		if v.pageType == 2 then
			check1 = true
		elseif v.pageType == 3 then
			check2 = true
		end
		adata.texture = v.pageTexture
		adata.showtime = v.showTime
		adata.beginTime = v.beginTime
		adata.endTime = v.endTime
		if v.context ~= "" then
			adata.context = {}
			local contexts = v.context:split(";")
			for ii, vv in ipairs(contexts) do
				local c = {}
				local temp = vv:split(",")
				for iii, vvv in ipairs(temp) do
					local tempstr = vvv:split(":")
					c[tempstr[1]] = tempstr[2]
				end
				table.insert(adata.context, c)
			end
		end
		table.insert(activityData, adata)
	end
end

local function RequestTableList(callback)
	local req = ActivityMsg_pb.MsgActivityNoticeListRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgActivityNoticeListRequest, req, ActivityMsg_pb.MsgActivityNoticeListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	MakeDataTable(msg.infos)
        	if callback ~= nil then
        		callback()
        	end
        end
    end, true)
end

local function OnUICameraDrag(go, delta)
	Tooltip.HideItemTip()
end

local function OnUICameraClick(go)
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

function GoToPay()
	store.Show()
	CloseSelf()
end

function GoToSevenDay()
	FunctionListData.IsFunctionUnlocked(1, function(isactive)
		if isactive then
			SevenDay.Show()
		else
			FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(1)), Color.white)
		end
	end)
end

function GoToMonthCard()
	MainCityUI.ShowCards()
end

function GoToOnline()
	online.Show()
end

local function UpdateData(data, index)
	if data ~= nil then
		for i, v in ipairs(data.accumRewardInfos) do
			if v.index == index then
				v.status = ActivityMsg_pb.RewardStatus_HasTaken
			end
		end
	end
end

local function HasReward(data)
	if data ~= nil then
		for i, v in ipairs(data.accumRewardInfos) do
			if v.status == ActivityMsg_pb.RewardStatus_CanTake then
				return true
			end
		end
	end
	return false
end

local function RequestRechargeInfo(callback)
	local req = ActivityMsg_pb.MsgAccumulateRechargeInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgAccumulateRechargeInfoRequest, req, ActivityMsg_pb.MsgAccumulateRechargeInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	rechargeData = msg
        	if callback ~= nil then
        		callback()
        	end
        end
    end, true)
end

local function RequestConsumeInfo(callback)
	local req = ActivityMsg_pb.MsgAccumulateConsumeInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgAccumulateConsumeInfoRequest, req, ActivityMsg_pb.MsgAccumulateConsumeInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	consumeData = msg
        	if callback ~= nil then
        		callback()
        	end
        end
    end, true)
end

local function TakeRechargeReward(index, callback)
	local req = ActivityMsg_pb.MsgTakeAccumulateRechargeRewardRequest()
	req.index = index
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeAccumulateRechargeRewardRequest, req, ActivityMsg_pb.MsgTakeAccumulateRechargeRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	UpdateData(rechargeData, msg.index)
        	MainCityUI.UpdateRewardData(msg.fresh)
        	ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
			ItemListShowNew.SetItemShow(msg)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
        	if callback ~= nil then
        		callback()
        	end
        end
    end, false)
end

local function TakeConsumeReward(index, callback)
	local req = ActivityMsg_pb.MsgTakeAccumulateConsumeRewardRequest()
	req.index = index
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeAccumulateConsumeRewardRequest, req, ActivityMsg_pb.MsgTakeAccumulateConsumeRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	UpdateData(consumeData, msg.index)
        	MainCityUI.UpdateRewardData(msg.fresh)
        	ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
			ItemListShowNew.SetItemShow(msg)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
        	if callback ~= nil then
        		callback()
        	end
        end
    end, false)
end

local function OnPageChange(pagedata)
	_ui.banner.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", pagedata.texture)
	_ui.banner:MakePixelPerfect()
	if pagedata.showtime == "" then
		_ui.banner_time.gameObject:SetActive(false)
	else
		_ui.banner_time.gameObject:SetActive(true)
		_ui.banner_time.text = pagedata.showtime
	end
	if pagedata.type == 1 then
		updateNormal(pagedata.context, pagedata.showtime)
	elseif pagedata.type == 2 then
		updateRecharge()
	elseif pagedata.type == 3 then
		updateConsume()
	end
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	
	_ui.banner = transform:Find("Container/bg_frane/bg_right/act_right_pic"):GetComponent("UITexture")
	_ui.banner_time = transform:Find("Container/bg_frane/bg_right/act_right_pic/text_time"):GetComponent("UILabel")
	_ui.scorllview = transform:Find("Container/bg_frane/bg_right/bg_bottom/Scroll View"):GetComponent("UIScrollView")
	_ui.uitable = transform:Find("Container/bg_frane/bg_right/bg_bottom/Scroll View/Table"):GetComponent("UITable")
	
	_ui.btn_prefab = ResourceLibrary.GetUIPrefab("ActivityStage/act_left_btn")
	_ui.right_time_prefab = ResourceLibrary.GetUIPrefab("ActivityStage/act_right_time")
	_ui.right_disc_prefab = ResourceLibrary.GetUIPrefab("ActivityStage/act_right_disc")
	
	_ui.rechargeinfo = ResourceLibrary.GetUIPrefab("ActivityStage/ActivityRechargeInfo")
	_ui.rechargeitem = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.rechargehero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	
	local num_item = _ui.rechargeitem.transform:Find("have"):GetComponent("UILabel")
	local num_hero = _ui.rechargehero.transform:Find("num"):GetComponent("UILabel")
	num_hero.trueTypeFont = num_item.trueTypeFont
	num_hero.fontSize = num_item.fontSize
	num_hero.applyGradient = num_item.applyGradient
	num_hero.gradientTop = num_item.gradientTop
	num_hero.gradientBottom = num_item.gradientBottom
	num_hero.spacingX = num_item.spacingX
	
	_ui.btn_grid = transform:Find("Container/bg_frane/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
	
	AddDelegate(UICamera, "onClick", OnUICameraClick)
	AddDelegate(UICamera, "onDrag", OnUICameraDrag)
end

local updateInfos = function(infos, data, depth)
	local grid = infos:Find("bg_list/Grid"):GetComponent("UIGrid")
	local panel = grid.transform:GetComponent("UIPanel")
	panel.depth = depth + 1
	for i = 0, grid.transform.childCount - 1 do
		GameObject.Destroy(grid.transform:GetChild(i).gameObject)
	end
	for i, v in ipairs(data.heros) do
		local heroData = TableMgr:GetHeroData(v.id)
		local hero = NGUITools.AddChild(grid.gameObject, _ui.rechargehero.gameObject).transform
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
		SetParameter(hero:Find("head icon").gameObject, "hero_" .. v.id)
	end
	for i, v in ipairs(data.items) do
		local itemdata = TableMgr:GetItemData(v.id)
		local item = NGUITools.AddChild(grid.gameObject, _ui.rechargeitem.gameObject).transform
		item.localScale = Vector3.one
		item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
		local num_item = item:Find("have")
		if v.num ~= nil and v.num > 1 then
			num_item.gameObject:SetActive(true)
			num_item:GetComponent("UILabel").text = v.num
		else
			num_item.gameObject:SetActive(false)
		end
		item:GetComponent("UISprite").spriteName = "bg_item" .. itemdata.quality
		local itemlvTrf = item.transform:Find("num")
		local itemlv = itemlvTrf:GetComponent("UILabel")
		itemlvTrf.gameObject:SetActive(true)
		if itemdata.showType == 1 then
			itemlv.text = Global.ExchangeValue2(itemdata.itemlevel)
		elseif itemdata.showType == 2 then
			itemlv.text = Global.ExchangeValue1(itemdata.itemlevel)
		elseif itemdata.showType == 3 then
			itemlv.text = Global.ExchangeValue3(itemdata.itemlevel)
		else 
			itemlvTrf.gameObject:SetActive(false)
		end
		SetParameter(item.gameObject, "item_" .. v.id)
	end
	coroutine.start(function()
		coroutine.step()
		grid:Reposition()
	end)
end

updateRecharge = function()
	local scroll = _ui.scorllview.transform:GetComponent("UIPanel")
	local grid = _ui.uitable
	for i = 0, grid.transform.childCount - 1 do
		GameObject.Destroy(grid.transform:GetChild(i).gameObject)
	end
	for i, v in ipairs(rechargeData.accumRewardInfos) do
		local infos = NGUITools.AddChild(grid.gameObject, _ui.rechargeinfo.gameObject).transform
		updateInfos(infos, v.rewardInfo, scroll.depth)
		infos:Find("bg_list/text_recharge"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_activity_des8"), v.needAmt)
		infos:Find("bg_list/txt_num"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_activity_des9"), (rechargeData.rechargeAmt >= v.needAmt and "[00ff1e]" or "[ff0000]") .. rechargeData.rechargeAmt .. "[-]", v.needAmt)
		local btn = infos:Find("bg_list/btn_use").gameObject
		local btntext = infos:Find("bg_list/btn_use/text"):GetComponent("UILabel")
		btn:GetComponent("UIButton").enabled = false
		if v.status == ActivityMsg_pb.RewardStatus_CanNotTake then
			btn:GetComponent("UISprite").spriteName = "btn_1"
			btn:GetComponent("BoxCollider").enabled = true
			btntext.text = TextMgr:GetText("mission_go")
			SetClickCallback(btn, function()
				--Pay.CloseCallBack = Show
				store.Show()
				CloseSelf()
			end)
		elseif v.status == ActivityMsg_pb.RewardStatus_CanTake then
			btn:GetComponent("UISprite").spriteName = "btn_2"
			btn:GetComponent("BoxCollider").enabled = true
			btntext.text = TextMgr:GetText("mail_ui12")
			SetClickCallback(btn, function()
				TakeRechargeReward(v.index, function() updateRecharge() end)
			end)
		elseif v.status == ActivityMsg_pb.RewardStatus_HasTaken then
			btn:GetComponent("UISprite").spriteName = "btn_4"
			btn:GetComponent("BoxCollider").enabled = false
			btntext.text = TextMgr:GetText("SectionRewards_ui5")
		end
	end
	coroutine.start(function()
		_ui.scorllview:MoveRelative(Vector3(0,10,0))
		coroutine.step()
		grid:Reposition()
		_ui.scorllview:ResetPosition()
	end)
end

updateConsume = function()
	local scroll = _ui.scorllview.transform:GetComponent("UIPanel")
	local grid = _ui.uitable
	for i = 0, grid.transform.childCount - 1 do
		GameObject.Destroy(grid.transform:GetChild(i).gameObject)
	end
	for i, v in ipairs(consumeData.accumRewardInfos) do
		local infos = NGUITools.AddChild(grid.gameObject, _ui.rechargeinfo.gameObject).transform
		updateInfos(infos, v.rewardInfo, scroll.depth)
		infos:Find("bg_list/text_recharge"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_activity_des11"), v.needAmt)
		infos:Find("bg_list/txt_num"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_activity_des9"), (consumeData.consumeAmt >= v.needAmt and "[00ff1e]" or "[ff0000]") .. consumeData.consumeAmt .. "[-]", v.needAmt)
		local btn = infos:Find("bg_list/btn_use").gameObject
		local btntext = infos:Find("bg_list/btn_use/text"):GetComponent("UILabel")
		btn:GetComponent("UIButton").enabled = false
		if v.status == ActivityMsg_pb.RewardStatus_CanNotTake then
			btn:GetComponent("UISprite").spriteName = "btn_4"
			btn:GetComponent("BoxCollider").enabled = false
			btntext.text = TextMgr:GetText("ui_activity_des10")
		elseif v.status == ActivityMsg_pb.RewardStatus_CanTake then
			btn:GetComponent("UISprite").spriteName = "btn_2"
			btn:GetComponent("BoxCollider").enabled = true
			btntext.text = TextMgr:GetText("mail_ui12")
			SetClickCallback(btn, function()
				TakeConsumeReward(v.index, function() updateConsume() end)
			end)
		elseif v.status == ActivityMsg_pb.RewardStatus_HasTaken then
			btn:GetComponent("UISprite").spriteName = "btn_4"
			btn:GetComponent("BoxCollider").enabled = false
			btntext.text = TextMgr:GetText("SectionRewards_ui5")
		end
	end
	coroutine.start(function()
		_ui.scorllview:MoveRelative(Vector3(0,10,0))
		coroutine.step()
		grid:Reposition()
		_ui.scorllview:ResetPosition()
	end)
end

updateNormal = function(context, showtime)
	local grid = _ui.uitable
	for i = 0, grid.transform.childCount - 1 do
		GameObject.Destroy(grid.transform:GetChild(i).gameObject)
	end
	for i, v in ipairs(context) do
		if v.module == "1" then
			local infos = NGUITools.AddChild(grid.gameObject, _ui.right_time_prefab.gameObject).transform
			infos:Find("title"):GetComponent("UILabel").text = TextMgr:GetText(v.title)
			infos:Find("title/text_time"):GetComponent("UILabel").text = showtime
			SetClickCallback(infos:Find("title/btn_go").gameObject, function()
				Global.GetTableFunction("ActivityNotice."..v.btn.."()")()
			end)
			coroutine.start(function()
				coroutine.step()
				NGUITools.UpdateWidgetCollider(infos.gameObject)
			end)
		elseif v.module == "2" then
			local infos = NGUITools.AddChild(grid.gameObject, _ui.right_disc_prefab.gameObject).transform
			infos:Find("title"):GetComponent("UILabel").text = TextMgr:GetText(v.title)
			infos:Find("title/text"):GetComponent("UILabel").text = TextMgr:GetText(v.text)
			coroutine.start(function()
				coroutine.step()
				NGUITools.UpdateWidgetCollider(infos.gameObject)
			end)
		end
	end
	coroutine.start(function()
		_ui.scorllview:MoveRelative(Vector3(0,10,0))
		coroutine.step()
		grid:Reposition()
		_ui.scorllview:ResetPosition()
	end)
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	
	local first = 0
	for i, v in ipairs(activityData) do
		if v.beginTime <= Serclimax.GameTime.GetSecTime() and v.endTime > Serclimax.GameTime.GetSecTime() then
			if first == 0 then
				first = i
			end
			local btn = NGUITools.AddChild(_ui.btn_grid.gameObject, _ui.btn_prefab.gameObject).transform
			btn:Find("txt_get"):GetComponent("UILabel").text = TextMgr:GetText(v.name)
			local redpoint = btn:Find("redpoint").gameObject
			if v.type == 2 then
				redpoint:SetActive(HasReward(rechargeData))
			elseif v.type == 3 then
				redpoint:SetActive(HasReward(consumeData))
			else
				redpoint:SetActive(false)
			end
			SetClickCallback(btn.gameObject, function()
				redpoint:SetActive(false)
				OnPageChange(v)
			end)
		end
	end
	_ui.btn_grid:Reposition()
	
	if #activityData > 0 then
		OnPageChange(activityData[first])
	end
end

function Show()
	GUIMgr:LockScreen()
	CheckRedPoint(function()
		GUIMgr:UnlockScreen()
		Global.OpenUI(_M)
	end)
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onClick", OnUICameraClick)
	RemoveDelegate(UICamera, "onDrag", OnUICameraDrag)
end

function CheckRedPoint(callback)
	RequestTableList(function()
		if check1 then
			RequestRechargeInfo(function()
				if check2 then
					RequestConsumeInfo(function()
						local showred = HasReward(consumeData)
						showred = showred or HasReward(rechargeData)
						if callback ~= nil then
							callback(showred)
						end
					end)
				else
					local showred = HasReward(rechargeData)
					if callback ~= nil then
						callback(showred)
					end
				end
			end)
		elseif check2 then
			RequestConsumeInfo(function()
				local showred = HasReward(consumeData)
				if callback ~= nil then
					callback(showred)
				end
			end)
		else
			if callback ~= nil then
				callback(false)
			end
		end
	end)
end

function Test()
	--Global.GetTableFunction("ActivityNotice.".."GoToMonthCard".."()")()
	_ui.banner.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", "20170717shouchong")
	_ui.banner:MakePixelPerfect()
end
