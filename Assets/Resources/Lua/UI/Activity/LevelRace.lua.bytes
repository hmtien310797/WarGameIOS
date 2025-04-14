module("LevelRace", package.seeall)
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
		elseif param[1] == "hero" then
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
		else
			local soldierData = TableMgr:GetBarrackData(tonumber(param[2]), tonumber(param[3]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
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
	GUIMgr:FindMenu("LevelRace").gameObject:SetActive(false)
end

function CloseAll()
	CloseSelf()
	DailyActivity.CloseSelf()
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	ActivityLevelRaceData.RemoveListener(UpdateUI)
	--ActivityLevelRaceData.AddListener(UpdateUI)
	--ActivityLevelRaceData.RemoveListener(DailyActivityData.ProcessActivity)
	CountDown.Instance:Remove("templet1")
	CountDown.Instance:Remove("templet1_refresh")
end

function MyRankRewardActive(rankData)
	if rankData.myrank == 0 then
		return myrank
	end
	
end

function Show(activity , updateTemplet)
print("level race------------" , activity , updateTemplet)
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
			UpdateUI(true)
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
	_ui.rankStepLabel = transform:Find("Container/content/banner/new_label3"):GetComponent("UILabel")

	_ui.help = transform:Find("Container/content/banner/button_ins").gameObject
	_ui.tipsRank = transform:Find("Container/tips_rank")
	_ui.tipsRankMask = transform:Find("Container/tips_rank/mask")
	_ui.tipsRankItem = transform:Find("Container/tips_rank/mid/bg")
	_ui.tipsRankGrid = transform:Find("Container/tips_rank/mid/Grid"):GetComponent("UIGrid")
	
	_ui.scroll = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
	_ui.listTable = transform:Find("Container/content/Scroll View/Table"):GetComponent("UITable")
	_ui.item = transform:Find("Container/levelup_list")
	_ui.detailitem = transform:Find("Container/detail_list")
	_ui.rewardItem = transform:Find("Container/levelup_list/open_list/open_mid/reward/Grid/Item_CommonNew")--ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.rewardHeroItem = ResourceLibrary.GetUIPrefab("Hero/listitem_hero_item")
	_ui.rankUIList = {}
	
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	local configid = ActivityData.GetActivityConfig(_ui.activity.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activity.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activity.templet)
	ActivityLevelRaceData.AddListener(UpdateUI)
	--ActivityLevelRaceData.AddListener(DailyActivityData.ProcessActivity)
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
				vv.data.conditionType ~= 46 and vv.data.conditionType ~= 45 and 
				vv.data.conditionType ~= 63 and vv.data.conditionType ~= 87 then
					
				end
				break
			end
		end
	end
end

UpdateUI = function(forceLocation)
	ActivityLevelRaceData.RequestData(true , function()
		_ui.levelList = ActivityLevelRaceData.GetData()
		UpdateTop()
		UpdateDown()
		
		if forceLocation then
			local locationIndex = ActivityLevelRaceData.GetLocationRank()
			_ui.scroll:MoveRelative(Vector3(0 , 100 * (locationIndex - 1) , 0))
			
			local locationItem = _ui.listTable.transform:GetChild(locationIndex - 1).transform
			if locationItem then
				local detailBtn = locationItem:Find("icon_btn").gameObject
				detailBtn:SendMessage("OnClick")
			end
		end
	end)
end

UpdateTop = function()
	_ui.text_line1.text = _ui.configs["title"] ~= nil and TextMgr:GetText(_ui.configs["title"]) or ""
	_ui.text_line2.text = _ui.configs["des"] ~= nil and TextMgr:GetText(_ui.configs["des"]) or ""
	_ui.rankStepLabel.text = _ui.activity.activityId == 1401 and TextMgr:GetText("levelrank_3") or TextMgr:GetText("levelrank_4")
	
	
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

function BuildRankDetail(detailInfo , rankmin , rankmax)
	_ui.tipsRank.gameObject:SetActive(true)
	NGUITools.BringForward(_ui.tipsRank.gameObject)
	local closeBtn = _ui.tipsRank:Find("tittle/close_btn")
	SetClickCallback(closeBtn.gameObject , function()
		_ui.tipsRank.gameObject:SetActive(false)
	end)
	SetClickCallback(_ui.tipsRankMask.gameObject , function()
		_ui.tipsRank.gameObject:SetActive(false)
	end)
	
	while _ui.tipsRankGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.tipsRankGrid.transform:GetChild(0).gameObject)
	end
	
	for i=1 , #detailInfo.ranklist do
		local info = detailInfo.ranklist[i]
		if info.rank >= rankmin and info.rank <= rankmax then
			local item = NGUITools.AddChild(_ui.tipsRankGrid.gameObject, _ui.tipsRankItem.gameObject).transform
			local rankIcon = item:Find("Sprite"):GetComponent("UISprite")
			--rankIcon.gameObject:SetActive(i <= 3)
			--rankIcon.spriteName = "rank_" .. i
			rankIcon.gameObject:SetActive(false)
			
			
			local rankLabel = item:Find("rankNo"):GetComponent("UILabel")
			rankLabel.text = System.String.Format(TextMgr:GetText("Armrace_29") , info.rank)
			
			local name = item:Find("name"):GetComponent("UILabel")
			local banner = info.guildbanner == nil or info.guildbanner == "" and "" or string.format("【%s】" , info.guildbanner)
			name.text = string.format("%s%s" , banner , info.name)
			
			local nation = item:Find("flag"):GetComponent("UITexture")
			nation.mainTexture = UIUtil.GetNationalFlagTexture(info.nation)
			
			local military = item:Find("Military"):GetComponent("UITexture")
			military.gameObject:SetActive(info.militaryrankid > 0)
			local militaryRankData = tableData_tMilitaryRank.data[info.militaryrankid]
			if militaryRankData then
				military.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)
			end
		end
		
	end
	_ui.tipsRankGrid:Reposition()
	--_ui.tipsRankItem = transform:Find("Container/tips_rank/mid/bg")
	--_ui.tipsRankGrid = transform:Find("Container/tips_rank/mid/Grid"):GetComponent("UIGrid")
end

function BuildRankItem(rankdata , dataIndex ,  rankItem , isPreview , isOpen)
	local onRank = false
	local showRewardBtn = false
	local showCompleteIcon = false
	local rangRank = false
	local showRewardName = false
	local detail_data = rankdata.ranklist[dataIndex]
	
	local onRank = rankdata.myrank >= detail_data.min
	if detail_data.max > 0 then
		onRank = onRank and rankdata.myrank <= detail_data.max
	end
	
	local showRewardBtn = (not rankdata.got) and onRank
	local showCompleteIcon = (rankdata.got) and onRank
	local rangRank = detail_data.min ~= detail_data.max
	local showRewardName = (not rangRank) and  (not showRewardBtn)	
	local isOnlyForShow =  detail_data.isReceive == 0
	
	
	if isPreview then
		local topTitle = rankItem:Find("open_list/bg_top/title"):GetComponent("UILabel")
		topTitle.text = System.String.Format(TextMgr:GetText("activity_content_89") , rankdata.level)
		--topTitle.text = string.format("指挥中心%d级排名奖励" , rankdata.level)
		
		local midTitle = rankItem:Find("open_list/open_mid/title"):GetComponent("UILabel")
		midTitle.text = System.String.Format(TextMgr:GetText("activity_content_90") , 1)
		--midTitle.text = string.format("第%d名奖励" , 1)
		
		--reward show
		local rewardPrevGrid = rankItem:Find("open_list/open_mid/reward/Grid"):GetComponent("UIGrid")
		local rewardPreview = detail_data.rewardInfo
		RewardItem(rewardPrevGrid , detail_data.rewardInfo)
		
		-- status show
		--local showRewardBtn = (not rankdata.got) and rankdata.myrank > 0
		--local showCompleteIcon = not showRewardBtn
		--local rangRank = detail_data.min ~= detail_data.max
		--local showRewardName = (not rangRank) and (not showRewardBtn)

		if isOpen then
			local onRank = rankdata.myrank >= detail_data.min and rankdata.myrank <= detail_data.max
			showRewardBtn = (not rankdata.got) and onRank
			showCompleteIcon = (rankdata.got) and onRank
			rangRank = detail_data.min ~= detail_data.max
			showRewardName = (not rangRank) and  (not showRewardBtn)
		end
		rankItem:Find("open_list/open_mid/btn_reward").gameObject:SetActive(showRewardBtn and (not isOnlyForShow))
		rankItem:Find("open_list/open_mid/complete_icon").gameObject:SetActive(showCompleteIcon and (not isOnlyForShow))
		
		local sprReward = rankItem:Find("open_list/bg_top/icon_reward").gameObject:GetComponent("UITexture2GrayController")
		sprReward.gameObject:SetActive(rankdata.myrank > 0 and (not isOnlyForShow))
		sprReward.IsGray = rankdata.got
		--rankItem:Find("open_list/bg_top/icon_reward").gameObject:SetActive((not rankdata.got) and rankdata.myrank > 0)
		
		local rank_1 = rankItem:Find("open_list/open_mid/complete_name")
		rank_1.gameObject:SetActive(showRewardName and (not isOnlyForShow))
		rank_1:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("activity_content_93") , detail_data.name or "") 
		
		rankItem:Find("open_list/bg_top/new_label1").gameObject:SetActive(isOnlyForShow)
		rankItem:Find("open_list/open_mid/new_label2").gameObject:SetActive(isOnlyForShow)
		
		
		local btnRank = rankItem:Find("open_list/open_mid/btn_new")
		btnRank.gameObject:SetActive(not isOnlyForShow)
		--btn_new
		SetClickCallback(btnRank.gameObject , function()
			ActivityLevelRaceData.RequestRankDetail(rankdata.level , function(msg)
				--Global.DumpMessage(msg , "d:/levelList.lua")
				BuildRankDetail(msg , 1 , 1 )
			end)
		end)
		
	else
		--reward show
		local rewardPrevGrid = rankItem:Find("open_mid/reward/Grid"):GetComponent("UIGrid")
		local rewardPreview = rankdata.ranklist[dataIndex].rewardInfo
		RewardItem(rewardPrevGrid , rankdata.ranklist[dataIndex].rewardInfo)
		
		rankItem:Find("open_mid/btn_reward").gameObject:SetActive(showRewardBtn and (not isOnlyForShow))
		rankItem:Find("open_mid/complete_icon").gameObject:SetActive(showCompleteIcon and (not isOnlyForShow))
	
		
		local rank_1 = rankItem:Find("open_mid/complete_name")
		rank_1.gameObject:SetActive(showRewardName and (not isOnlyForShow))
		rank_1:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("activity_content_93") , detail_data.name or "") 
		
		local btnRank = rankItem:Find("open_mid/btn_new")
		btnRank.gameObject:SetActive(not isOnlyForShow)
		local midTitle = rankItem:Find("open_mid/title"):GetComponent("UILabel")
		if rangRank then
			if detail_data.max == 0 then
				--midTitle.text = string.format("第%d名以后奖励" , detail_data.min)
				btnRank.gameObject:SetActive(false)
				midTitle.text = System.String.Format(TextMgr:GetText("activity_content_91") , detail_data.min)
			else
				--midTitle.text = string.format("第%d-%d名奖励" , detail_data.min , detail_data.max)
				midTitle.text = System.String.Format(TextMgr:GetText("activity_content_92") , detail_data.min , detail_data.max)
				
				btnRank.gameObject:SetActive(not isOnlyForShow)
				--btn_new
				SetClickCallback(btnRank.gameObject , function()
					ActivityLevelRaceData.RequestRankDetail(rankdata.level , function(msg)
						BuildRankDetail(msg , detail_data.min , detail_data.max)
					end)
				end)
			end
		else
			--midTitle.text = string.format("第%d名奖励" , detail_data.min)
			midTitle.text = System.String.Format(TextMgr:GetText("activity_content_90") , detail_data.min)
		end
		
	end

end

function RewardItem(listGrid , rewarddata)
	while listGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(listGrid.transform:GetChild(0).gameObject)
	end
	
	if rewarddata.items then
		for k=1 , #rewarddata.items do
			local reward_item = NGUITools.AddChild(listGrid.gameObject, _ui.rewardItem.gameObject).transform
			reward_item.localScale = Vector3(0.6,0.6,1)
			local itemData = TableMgr:GetItemData(rewarddata.items[k].id)
			local reward = {}
			UIUtil.LoadItemObject(reward, reward_item)
			UIUtil.LoadItem(reward, itemData, rewarddata.items[k].num)
			SetParameter(reward_item.gameObject, "item_" .. rewarddata.items[k].id)
		end
		
	end
	if rewarddata.armys then
		for k=1 , #rewarddata.armys do
			local reward_item = NGUITools.AddChild(listGrid.gameObject, _ui.rewardItem.gameObject).transform
			reward_item.localScale = Vector3(0.6,0.6,1)
			local soldierData = TableMgr:GetBarrackData(rewarddata.armys[k].id, rewarddata.armys[k].level)
			local reward = {}
			UIUtil.LoadItemObject(reward, reward_item)
			UIUtil.LoadSoldier(reward, soldierData, rewarddata.armys[k].num)
			SetParameter(reward_item.gameObject, "army_" .. rewarddata.armys[k].id .. "_" ..rewarddata.armys[k].level )
		end
		
	end
	if rewarddata.heros then
		for k=1 , #rewarddata.heros do
			local reward_item = NGUITools.AddChild(listGrid.gameObject, _ui.rewardHeroItem.gameObject).transform
			reward_item.localScale = Vector3(0.5,0.5,1)
			local heroData = TableMgr:GetHeroData(rewarddata.heros[k].id)
			local heroCount = rewarddata.heros[k].num
			
			local item = {}
			UIUtil.LoadHeroItemObject(item, reward_item.transform)
			UIUtil.LoadHeroItem(item, heroData, heroCount)
			SetParameter(reward_item:Find("item1").gameObject, "hero_" .. rewarddata.heros[k].id)
		end
		
	end
	listGrid:Reposition()
end

UpdateDown = function(forceLocation)
	local childcount = _ui.listTable.transform.childCount
	local index = 0
	
	for i=1 , #_ui.levelList.lvinfo do
		index = i
		local missionData = _ui.levelList.lvinfo[i]
		local missionitem
		if i - 1 < childcount then
			missionitem = _ui.listTable.transform:GetChild(i - 1)
		else
			missionitem = NGUITools.AddChild(_ui.listTable.gameObject, _ui.item.gameObject).transform
		end
		missionitem.gameObject:SetActive(true)
		
		BuildRankItem(missionData ,1 , missionitem , true , false)
		
		local detailGrid = missionitem:Find("open_list/Grid"):GetComponent("UIGrid")
		SetClickCallback(missionitem:Find("icon_btn").gameObject, function()
			detailGrid.gameObject:SetActive(not detailGrid.gameObject.activeSelf)
			BuildRankItem(missionData ,1 , missionitem , true , detailGrid.gameObject.activeSelf)
		end)
		
		local rewardBtn = missionitem:Find("open_list/open_mid/btn_reward")
		SetClickCallback(rewardBtn.gameObject, function()
			ActivityLevelRaceData.RequestReward(missionData.level , function()
				_ui.levelList = ActivityLevelRaceData.GetData()
				UpdateDown()
				DailyActivityData.ProcessActivity()
			end)
		end)
		
		if missionData.ranklist then
			while detailGrid.transform.childCount > 0 do
				GameObject.DestroyImmediate(detailGrid.transform:GetChild(0).gameObject)
			end
			
			for j=2 , #missionData.ranklist do
				local detail_item = NGUITools.AddChild(detailGrid.gameObject, _ui.detailitem.gameObject).transform
				BuildRankItem(missionData ,j , detail_item , false)
				
				local rewardBtn = detail_item:Find("open_mid/btn_reward")
				SetClickCallback(rewardBtn.gameObject, function()
					ActivityLevelRaceData.RequestReward(missionData.level , function()
						_ui.levelList = ActivityLevelRaceData.GetData()
						missionData = _ui.levelList.lvinfo[i]
						BuildRankItem(missionData ,j , detail_item , false)
						BuildRankItem(missionData ,1 , missionitem , true , true)
						DailyActivityData.ProcessActivity()
					end)
				end)
			end
			detailGrid:Reposition()
		end
		 
		local tweenHeight = missionitem:Find("open_list"):GetComponent("TweenHeight")
		local openHeight = _ui.item:GetComponent("UIWidget").height
		openHeight = openHeight + _ui.detailitem:GetComponent("UIWidget").height * (#missionData.ranklist - 1)
		tweenHeight.to = openHeight

	end
	for i = index + 1, childcount do
		_ui.listTable.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
	
	_ui.listTable:Reposition()
	_ui.scroll:ResetPosition()
end

