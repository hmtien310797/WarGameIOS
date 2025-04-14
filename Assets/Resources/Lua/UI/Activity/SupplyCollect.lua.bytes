module("SupplyCollect", package.seeall)
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

local _ui, UpdateUI, UpdateList
UpdateRank = nil
local listeventListener = EventListener()
rankeventListener = EventListener()
local supplycollectdata, ranklist, myrank

local function GetSupplyNumByType(type)
	if supplycollectdata ~= nil then
		for i, v in ipairs(supplycollectdata) do
			if v.type == type then
				return v.value
			end
		end
	end
	return 0
end

local function RequestSupplyCollect()
	local req = ActivityMsg_pb.MsgSupplyCollectRequest()
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSupplyCollectRequest, req, ActivityMsg_pb.MsgSupplyCollectResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            supplycollectdata = msg.infos
            listeventListener:NotifyListener()
        end
    end, true)
end

local function GetRankDataByIndex(index)
	if ranklist ~= nil then
		for i, v in ipairs(ranklist) do
			if v.rank == index then
				return v
			end
		end
	end
	return nil
end

local function GetMyRank()
	if myrank == nil or System.String.IsNullOrEmpty(myrank.name) then
		local data = {}
		data.rank = "---"
		data.score = 0
		data.charId = MainData.GetCharId()
		data.name = MainData.GetCharName()
		if UnionInfoData.HasUnion() then
			data.guildId = UnionInfoData.GetGuildId()
			data.guildBanner = UnionInfoData.GetData().guildInfo.banner
		end
		return data
	end
	return myrank
end

function RequestSupplyCollectRankList()
	local req = ActivityMsg_pb.MsgSupplyCollectRankListRequest()
	req.rankCount = 10
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSupplyCollectRankListRequest, req, ActivityMsg_pb.MsgSupplyCollectRankListResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			ranklist = msg.rankList
			myrank = msg.myRank
            rankeventListener:NotifyListener()
        end
    end, true)
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
	Global.CloseUI(_M)
end

function CloseAll()
	CloseSelf()
	DailyActivity.CloseSelf()
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	listeventListener:RemoveListener(UpdateList)
	--rankeventListener:RemoveListener(UpdateRank)
	CountDown.Instance:Remove("supplycollect")
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
	else
		_ui.activity = activity
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
	
	_ui.page1_text = transform:Find("Container/bg_top/page1 (1)/text"):GetComponent("UILabel")
	_ui.page1_select_text = transform:Find("Container/bg_top/page1 (1)/selected effect/text (1)"):GetComponent("UILabel")

	_ui.page2_text = transform:Find("Container/bg_top/page2 (1)/text"):GetComponent("UILabel")
	_ui.page2_select_text = transform:Find("Container/bg_top/page2 (1)/selected effect/text (1)"):GetComponent("UILabel")

	_ui.time_text = transform:Find("Container/bg_top/timer"):GetComponent("UILabel")
	_ui.number_text = transform:Find("Container/bg_top/timer/number"):GetComponent("UILabel")

	_ui.help_text = transform:Find("Container/bg_top/Tittle"):GetComponent("UILabel")
	_ui.help_btn = transform:Find("Container/bg_top/Tittle/button_ins").gameObject
	_ui.help_tips = transform:Find("Container/bg_top/Tittle/tips"):GetComponent("UILabel")

	_ui.activity_scroll = transform:Find("Container/content_activity/Scroll View"):GetComponent("UIScrollView")
	_ui.activity_grid = transform:Find("Container/content_activity/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.activity_item = transform:Find("Container/content_activity/Scroll View/Grid/listitem_activity")

	_ui.rank_scroll = transform:Find("Container/content_rank/Scroll View"):GetComponent("UIScrollView")
	_ui.rank_grid = transform:Find("Container/content_rank/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.rank_item = transform:Find("Container/content_rank/Scroll View/Grid/listitem_supplyrank")
	_ui.rank_my = transform:Find("Container/content_rank/Myrank/myranklist")
	_ui.rank_rule_text = transform:Find("Container/content_rank/Myrank/rule"):GetComponent("UILabel")
	_ui.rank_rule_btn = transform:Find("Container/content_rank/Myrank/rule/info").gameObject

	_ui.button_rewards_btn = transform:Find("Container/bg_bottom/button_rewards")
	_ui.button_ranking_btn = transform:Find("Container/bg_bottom/button_ranking")

	AddDelegate(UICamera, "onPress", OnUICameraPress)
	local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
	listeventListener:AddListener(UpdateList)
	--rankeventListener:AddListener(UpdateRank)
	Start()
end

function Start()
	RequestSupplyCollect()
	--RequestSupplyCollectRankList()
	SetClickCallback(_ui.container, CloseAll)
	SetClickCallback(_ui.mask, CloseAll)
	if _ui.configs["HelpTitle"] == nil then
		_ui.help_btn:SetActive(false)
	end
	SetClickCallback(_ui.help_btn, function()
		DailyActivityHelp.Show(_ui.configs["HelpTitle"], _ui.configs["HelpContent"])
	end)
	SetClickCallback(_ui.rank_rule_btn, function()
		SupplyCollectRewards.Show(_ui.activity.activityId)
	end)
	_ui.showlist = TableMgr:GetSupplyCollectListByActivity(_ui.activity.activityId)
	table.sort(_ui.showlist, function(a, b) return a.type < b.type end)
	CountDown.Instance:Add("supplycollect", _ui.activity.endTime + 2, CountDown.CountDownCallBack(function(t)
		if t == "00:00:00" then
			CountDown.Instance:Remove("supplycollect")
			ActivityData.RequestListData(function()
				CloseAll()
				DailyActivity.Show()
			end)
		else
			_ui.number_text.text = t
		end
	end))

	SetClickCallback(_ui.button_rewards_btn.gameObject, function()
		SupplyCollectRewards.Show(_ui.activity.activityId)
	end)

	SetClickCallback(_ui.button_ranking_btn.gameObject, function()
		SupplyCollectRanking.Show()
	end)

	UpdateUI()
	DailyActivityData.NotifyUIOpened(_ui.activity.activityId)
end

UpdateUI = function()
	UpdateList()
	--UpdateRank()
end

local function JumpFunc(type)
	if type == 4 then
		ChapterSelectUI.ShowExploringChapter()
	elseif type == 2 then
		local basePos = MapInfoData.GetData().mypos
		MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
			MapSearch.Show()
		end)
	elseif type == 3 then
		ActivityAll.Show(102)
	else
		local basePos = MapInfoData.GetData().mypos
		MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
		end)
	end
end

UpdateList = function()
	_ui.showlist = TableMgr:GetSupplyCollectListByActivity(_ui.activity.activityId)
	local childcount = _ui.activity_grid.transform.childCount
	for i, v in ipairs(_ui.showlist) do
		local activityitem
		if i - 1 < childcount then
			activityitem = _ui.activity_grid.transform:GetChild(i - 1)
		else
			activityitem = NGUITools.AddChild(_ui.activity_grid.gameObject, _ui.activity_item.gameObject).transform
		end
		activityitem:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(v.name)
		activityitem:Find("des"):GetComponent("UILabel").text = TextMgr:GetText(v.des)
		SetParameter(activityitem:Find("reward/box").gameObject, "item_3419")
		activityitem:Find("reward/box/number"):GetComponent("UILabel").text = GetSupplyNumByType(v.type)
		SetClickCallback(activityitem:Find("button").gameObject, function()
			JumpFunc(v.type)
			CloseAll()
		end)
	end
	_ui.activity_grid:Reposition()
	_ui.activity_scroll:ResetPosition()
end

local function MakeRankItem(prefab, rankdata, index)
	prefab.transform:Find("Rank/rank1").gameObject:SetActive(rankdata ~= nil and (rankdata.rank == 1) or (index == 1))
	prefab.transform:Find("Rank/crown").gameObject:SetActive(rankdata ~= nil and (rankdata.rank == 1) or (index == 1))
	prefab.transform:Find("Rank/rank2").gameObject:SetActive(rankdata ~= nil and (rankdata.rank == 2) or (index == 2))
	prefab.transform:Find("Rank/rank3").gameObject:SetActive(rankdata ~= nil and (rankdata.rank == 3) or (index == 3))
	local rankother
	if rankdata == nil then
		if index == nil or index >= 4 then
			rankother = true
		else
			rankother = false
		end
	else
		if type(rankdata.rank) ~= "number" or rankdata.rank >= 4 then
			rankother = true
		else
			rankother = false
		end
	end
	prefab.transform:Find("Rank/rankother").gameObject:SetActive(rankother)
	prefab.transform:Find("Rank/rankother"):GetComponent("UILabel").text = rankdata ~= nil and rankdata.rank or (index ~= nil and index or "---")
	if rankdata ~= nil then
		prefab.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61]" .. (System.String.IsNullOrEmpty(rankdata.guildBanner) and "[---]" or ("[" .. rankdata.guildBanner .. "]")) .. "[-]" .. rankdata.name
		prefab.transform:Find("reward/box/number"):GetComponent("UILabel").text = rankdata.score
	else
		prefab.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61][---][-]---"
		prefab.transform:Find("reward/box/number"):GetComponent("UILabel").text = 0
	end
end

UpdateRank = function(rank_info)
	if rank_info == nil then
		rank_info = {}
		rank_info.rank_grid = _ui.rank_grid
		rank_info.rank_item = _ui.rank_item
		rank_info.rank_scroll = _ui.rank_scroll
		rank_info.rank_my = _ui.rank_my
	end
	local childcount = rank_info.rank_grid.transform.childCount
	for i = 1, 10 do
		local rankitem
		if i - 1 < childcount then
			rankitem = rank_info.rank_grid.transform:GetChild(i - 1)
		else
			rankitem = NGUITools.AddChild(rank_info.rank_grid.gameObject, rank_info.rank_item.gameObject).transform
		end
		local rankdata = GetRankDataByIndex(i)
		if rankdata ~= nil then
			SetClickCallback(rankitem.gameObject, function()
				OtherInfo.RequestShow(rankdata.charId)
			end)
		end
		MakeRankItem(rankitem, rankdata, i)
	end
	rank_info.rank_grid:Reposition()
	rank_info.rank_scroll:ResetPosition()
	MakeRankItem(rank_info.rank_my, GetMyRank())
end
