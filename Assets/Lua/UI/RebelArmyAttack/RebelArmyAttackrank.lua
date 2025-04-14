module("RebelArmyAttackrank", package.seeall)
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
local String = System.String

local _ui, UpdateUI, UpdateUserRank, UpdateUnionRank, UpdateInfoItem, UpdateItem,UpdateUserATKRank
local isATKMODE
local isClimbData
local ScoreTextID

function SetScoreTextID(text_id)
	ScoreTextID = text_id
end

local function AddDepth(go, add)
	local widgets = go:GetComponentsInChildren(typeof(UIWidget))
	for i = 0, widgets.Length - 1 do
		widgets[i].depth = widgets[i].depth + add
	end
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end
--[[
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
]]
local function CloseSelf()
	Global.CloseUI(_M)
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_top/btn_close").gameObject
	
	_ui.content1 = transform:Find("Container/mid01/content 1")
	_ui.content2 = transform:Find("Container/mid01/content 2")
	_ui.info = transform:Find("info")
	
	_ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	
	_ui.page1_text = transform:Find("Container/mid01/page1/text"):GetComponent("UILabel")
	_ui.page2_text = transform:Find("Container/mid01/page2/text"):GetComponent("UILabel")
	_ui.page1_e_text = transform:Find("Container/mid01/page1/selected effect/text (1)"):GetComponent("UILabel")
	_ui.page2_e_text = transform:Find("Container/mid01/page2/selected effect/text (1)"):GetComponent("UILabel")	
	_ui.page1_text.text = TextMgr:GetText("RebelArmyAttack_ui25")
	_ui.page2_text.text = TextMgr:GetText("RebelArmyAttack_ui26")
	_ui.page1_e_text.text = TextMgr:GetText("RebelArmyAttack_ui25")
	_ui.page2_e_text.text = TextMgr:GetText("RebelArmyAttack_ui26")
	if isATKMODE then
		transform:Find("Container/mid01/page1").gameObject:SetActive(false)
		transform:Find("Container/mid01/page2").gameObject:SetActive(false)
		if isClimbData then
			_ui.page1_text.text = TextMgr:GetText("union_tec34")
			_ui.page2_text.text = TextMgr:GetText("union_tec35")	
			_ui.page1_e_text.text = TextMgr:GetText("union_tec34")
			_ui.page2_e_text.text = TextMgr:GetText("union_tec35")					
			transform:Find("Container/mid01/page1").gameObject:SetActive(true)
			if Global.IsOutSea() then
				transform:Find("Container/mid01/page2").gameObject:SetActive(false)
			else
				transform:Find("Container/mid01/page2").gameObject:SetActive(true)
			end
		end
	end
	
	

	--AddDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)		
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	UpdateUI()
end

function Close()
	_ui = nil
	ScoreTextID = nil
	CountDown.Instance:Remove("tempclimb_rank_refresh_day")
	CountDown.Instance:Remove("tempclimb_rank_refresh_week")
	--RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()		
end

function ShowATK()
	if _ui == nil then
		_ui = {}
	end
	isATKMODE = true
	isClimbData = false
	ActiveSlaughterData.UserRankListRequest(function(msg)
		_ui.userrank = msg
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		end
		Global.OpenUI(_M)
	end)
end

function ShowClimb()
	if _ui == nil then
		_ui = {}
	end
	isATKMODE = true
	isClimbData = true
	
	ClimbData.ClimbRankListRequest(true,function(msg)
		_ui.userrank = msg
		ClimbData.ClimbRankListRequest(false,function(msg)
			_ui.unionrank = msg
			Global.OpenUI(_M)
			_ui.climb_help = transform:Find("btn_help")
			_ui.climb_help.gameObject:SetActive(true)
			SetClickCallback(_ui.climb_help.gameObject,function()
				GOV_Help.Show(GOV_Help.HelpModeType.ClimpRankHelp)
			end)
			_ui.climb_time_day = transform:Find("Container/mid01/page1/selected effect/Label"):GetComponent("UILabel")
			_ui.climb_time_day.gameObject:SetActive(true)
			_ui.climb_time_day.text = System.String.Format(TextMgr:GetText("Climb_ui14"), Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown()))
			CountDown.Instance:Add("tempclimb_rank_refresh_day", Global.GetFiveOclockCooldown() + 2, CountDown.CountDownCallBack(function(t)
				_ui.climb_time_day.text = System.String.Format(TextMgr:GetText("Climb_ui14"), t)
				if t == "00:00:00" then
					CountDown.Instance:Remove("tempclimb_rank_refresh_day")
				end
			end))	


			_ui.climb_time_week = transform:Find("Container/mid01/page2/selected effect/Label"):GetComponent("UILabel") 
			_ui.climb_time_week.gameObject:SetActive(true)
			_ui.climb_time_week.text = System.String.Format(TextMgr:GetText("Climb_ui14"), Global.GetLeftCooldownTextLong(Global.GetWeekFiveOclockCooldown()))
			CountDown.Instance:Add("tempclimb_rank_refresh_week", Global.GetWeekFiveOclockCooldown() + 2, CountDown.CountDownCallBack(function(t)
				_ui.climb_time_week.text = System.String.Format(TextMgr:GetText("Climb_ui14"), t)
				if t == "00:00:00" then
					CountDown.Instance:Remove("tempclimb_rank_refresh_week")
				end
			end))		
		end)
	end)
end

function Show()
	if _ui == nil then
		_ui = {}
	end
	isATKMODE = false
	isClimbData = false
	RebelArmyAttackData.RequestSiegeMonsterRankList(1, function(msg)
		_ui.userrank = msg
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		end
		RebelArmyAttackData.RequestSiegeMonsterRankList(2, function(msg)
			_ui.unionrank = msg
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			end
			Global.OpenUI(_M)
		end)
	end)
end

UpdateUI = function()
	local scroll, userinfo

	if _ui.userrank ~= nil and _ui.userrank.myRank ~= nil and _ui.userrank.myRank.rank > 0 then
		transform:Find("Container/mid01/content 1/Scroll View").gameObject:SetActive(false)
		transform:Find("Container/mid01/content 1/Scroll View (1)").gameObject:SetActive(true)
		transform:Find("Container/mid01/content 1/myrank").gameObject:SetActive(true)
		scroll = transform:Find("Container/mid01/content 1/Scroll View (1)"):GetComponent("UIScrollView")
		userinfo = transform:Find("Container/mid01/content 1/myrank/info")
	else
		transform:Find("Container/mid01/content 1/Scroll View").gameObject:SetActive(true)
		transform:Find("Container/mid01/content 1/Scroll View (1)").gameObject:SetActive(false)
		transform:Find("Container/mid01/content 1/myrank").gameObject:SetActive(false)
		scroll = transform:Find("Container/mid01/content 1/Scroll View"):GetComponent("UIScrollView")
		userinfo = nil
	end
	if isATKMODE then
		_ui.content1.mid02_scroll_pos = scroll.transform.localPosition
		UpdateUserATKRank(scroll, userinfo)
	else
		UpdateUserRank(scroll, userinfo)
	end
	if isATKMODE then
		if not isClimbData then
			return
		end
	end	
	if _ui.unionrank ~= nil and _ui.unionrank.myGuildRank ~= nil and _ui.unionrank.myGuildRank.rank > 0 then
		transform:Find("Container/mid01/content 2/Scroll View").gameObject:SetActive(false)
		transform:Find("Container/mid01/content 2/Scroll View (1)").gameObject:SetActive(true)
		transform:Find("Container/mid01/content 2/myrank").gameObject:SetActive(true)
		scroll = transform:Find("Container/mid01/content 2/Scroll View (1)"):GetComponent("UIScrollView")
		userinfo = transform:Find("Container/mid01/content 2/myrank/info")
	else
		transform:Find("Container/mid01/content 2/Scroll View").gameObject:SetActive(true)
		transform:Find("Container/mid01/content 2/Scroll View (1)").gameObject:SetActive(false)
		transform:Find("Container/mid01/content 2/myrank").gameObject:SetActive(false)
		scroll = transform:Find("Container/mid01/content 2/Scroll View"):GetComponent("UIScrollView")
		userinfo = nil
	end
	if isClimbData then
		if _ui.unionrank ~= nil and _ui.unionrank.myRank ~= nil and _ui.unionrank.myRank.rank > 0 then
			transform:Find("Container/mid01/content 2/Scroll View").gameObject:SetActive(false)
			transform:Find("Container/mid01/content 2/Scroll View (1)").gameObject:SetActive(true)
			transform:Find("Container/mid01/content 2/myrank").gameObject:SetActive(true)
			scroll = transform:Find("Container/mid01/content 2/Scroll View (1)"):GetComponent("UIScrollView")
			userinfo = transform:Find("Container/mid01/content 2/myrank/info")
		else
			transform:Find("Container/mid01/content 2/Scroll View").gameObject:SetActive(true)
			transform:Find("Container/mid01/content 2/Scroll View (1)").gameObject:SetActive(false)
			transform:Find("Container/mid01/content 2/myrank").gameObject:SetActive(false)
			scroll = transform:Find("Container/mid01/content 2/Scroll View"):GetComponent("UIScrollView")
			userinfo = nil
		end
		UpdateWeekClimbRank(scroll, userinfo)
	else
		UpdateUnionRank(scroll, userinfo)
	end	
end

UpdateUserATKRank = function(scroll, userinfo)
	local grid = scroll.transform:Find("Grid"):GetComponent("UIGrid")
	local award = nil
	if isClimbData then
		award = ClimbData.GetPersonRankReward()
	else
		award = ActiveSlaughterData.GetPersonRankReward()
	end
	
	_ui.endlesslist = EndlessList(scroll, _ui.content1.mid02_scroll_pos.x, _ui.content1.mid02_scroll_pos.y)
	_ui.endlesslist:SetItem(_ui.info.gameObject, #award, function(prefab, index)
		UpdateInfoItem(prefab.transform,_ui.userrank ~= nil and (_ui.userrank.rankList ~= nil and _ui.userrank.rankList[index] or nil) or nil,award[index], index)
	end)
	if userinfo ~= nil then
		UpdateInfoItem(userinfo, _ui.userrank.myRank, award[_ui.userrank.myRank.rank])
	end	
end

UpdateUserRank = function(scroll, userinfo)
	local grid = scroll.transform:Find("Grid"):GetComponent("UIGrid")
	local award = RebelArmyAttackData.GetPersonRankReward()
	for i, v in ipairs(award) do
		local item = NGUITools.AddChild(grid.gameObject, _ui.info.gameObject).transform
		UpdateInfoItem(item, _ui.userrank ~= nil and (_ui.userrank.rankList ~= nil and _ui.userrank.rankList[i] or nil) or nil, award[i], i)
	end
	grid:Reposition()
	scroll:ResetPosition()
	if userinfo ~= nil then
		UpdateInfoItem(userinfo, _ui.userrank.myRank, award[_ui.userrank.myRank.rank])
	end
end

UpdateUnionRank = function(scroll, userinfo)
	local grid = scroll.transform:Find("Grid"):GetComponent("UIGrid")
	local award = RebelArmyAttackData.GetUnionRankReward()
	for i, v in ipairs(award) do
		local item = NGUITools.AddChild(grid.gameObject, _ui.info.gameObject).transform
		UpdateInfoItem(item, _ui.unionrank ~= nil and (_ui.unionrank.rankList ~= nil and _ui.unionrank.rankList[i] or nil) or nil, award[i], i)
	end
	grid:Reposition()
	scroll:ResetPosition()
	if userinfo ~= nil then
		UpdateInfoItem(userinfo, _ui.unionrank.myGuildRank, award[_ui.unionrank.myGuildRank.rank])
	end
end

UpdateWeekClimbRank = function(scroll, userinfo)
	--[[
	local grid = scroll.transform:Find("Grid"):GetComponent("UIGrid")
	local award = nil 
	if isClimbData then
		award = ClimbData.GetWeekRankReward()
	end
	if award == nil then
		return 
	end

	for i, v in ipairs(award) do
		local item = NGUITools.AddChild(grid.gameObject, _ui.info.gameObject).transform
		UpdateInfoItem(item, _ui.unionrank ~= nil and (_ui.unionrank.rankList ~= nil and _ui.unionrank.rankList[i] or nil) or nil, award[i], i)
	end
	grid:Reposition()
	scroll:ResetPosition()
	if userinfo ~= nil then
		UpdateInfoItem(userinfo, _ui.unionrank.myGuildRank, award[_ui.unionrank.myGuildRank.rank])
	end
	--]]

	local grid = scroll.transform:Find("Grid"):GetComponent("UIGrid")
	local award = nil
	if isClimbData then
		award = ClimbData.GetWeekRankReward()
	end
	if award == nil then
		return 
	end	
	
	_ui.endlesslist = EndlessList(scroll, _ui.content1.mid02_scroll_pos.x, _ui.content1.mid02_scroll_pos.y)
	_ui.endlesslist:SetItem(_ui.info.gameObject, #award, function(prefab, index)
		UpdateInfoItem(prefab.transform,_ui.unionrank ~= nil and (_ui.unionrank.rankList ~= nil and _ui.unionrank.rankList[index] or nil) or nil,award[index], index)
	end)
	grid:Reposition()
	scroll:ResetPosition()
	if userinfo ~= nil then
		UpdateInfoItem(userinfo, _ui.unionrank.myRank, award[_ui.unionrank.myRank.rank])
	end	

end

UpdateInfoItem = function(infoitem, data, award, index)
	local name = infoitem:Find("name"):GetComponent("UILabel")
	local points = infoitem:Find("points"):GetComponent("UILabel")
	local nos = {}
	nos[1] = infoitem:Find("no.1"):GetComponent("UILabel")
	nos[2] = infoitem:Find("no.2"):GetComponent("UILabel")
	nos[3] = infoitem:Find("no.3"):GetComponent("UILabel")
	nos[4] = infoitem:Find("no.4"):GetComponent("UILabel")
	
	for i, v in ipairs(nos) do
		v.gameObject:SetActive(false)
	end
	if data == nil then
		data = {}
		data.rank = index
		data.score = "--"
		data.charId = 0
		data.name = "--"
		data.guildId = 0
	end
	infoitem:Find("base").gameObject:SetActive(data.rank % 2 == 1)
	name.text = (data.guildBanner ~= nil and ("[".. data.guildBanner.."]") or "") .. (data.name == nil and data.guildName or data.name)
	points.text = (ScoreTextID == nil or data.charId == 0) and data.score or System.String.Format(TextMgr:GetText(ScoreTextID), data.score) 
	if data.rank >= 4 then
		nos[4].gameObject:SetActive(true)
		nos[4].text = data.rank
	else
		nos[data.rank].gameObject:SetActive(true)
	end

	if award ~= nil then
		grid = infoitem:Find("Grid"):GetComponent("UIGrid")
		local num = 1
		local child_count = grid.transform.childCount
		for i, v in ipairs(award.awardlist) do
			if v.contentType == 1 then
				local itemdata = TableMgr:GetItemData(v.contentId)
				local item = nil
				if child_count < num then
					item = NGUITools.AddChild(grid.gameObject, _ui.item.gameObject).transform
				else
					item = grid.transform:GetChild(num -1)
					item.gameObject:SetActive(true)
				end
				local ShowTooltip = function(go)
					print("EEEEEEEEEEEEEEEEEEEEEEEEEEEEE",go.name)
					if go == _ui.tipObject then
						_ui.tipObject = nil
					else
						_ui.tipObject = go
						Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
					end
				end
				SetClickCallback(item.gameObject, ShowTooltip)
				num  = num +1
				item.localScale = Vector3.one
				item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
				local num_item = item:Find("have")
				if v.contentNumber ~= nil and v.contentNumber > 1 then
					num_item.gameObject:SetActive(true)
					num_item:GetComponent("UILabel").text = v.contentNumber
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
				SetParameter(item.gameObject, "item_" .. v.contentId)
				AddDepth(item.gameObject, 100)	
		    elseif v.contentType == 3 then
		    	local heroData = TableMgr:GetHeroData(v.contentId)
				local hero = NGUITools.AddChild(grid.gameObject, _ui.hero.gameObject).transform
				hero.localScale = Vector3(0.6, 0.6, 1)
				hero:Find("level text").gameObject:SetActive(false)
				hero:Find("name text").gameObject:SetActive(false)
				hero:Find("bg_skill").gameObject:SetActive(false)
				hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
				hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
				local star = hero:Find("star"):GetComponent("UISprite")
				if star ~= nil then
			        star.width = v.star * star.height
			    end
				SetParameter(hero:Find("head icon").gameObject, "hero_" .. v.contentId)
				AddDepth(hero.gameObject, 100)	
				local ShowTooltip = function(go)
					if go == _ui.tipObject then
						_ui.tipObject = nil
					else
						_ui.tipObject = go
						Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
					end
				end
				SetClickCallback(hero.gameObject, ShowTooltip)				
		    end
		end
		child_count = grid.transform.childCount
		--if num <= child_count then
			for i=num,child_count do
				local it = grid.transform:GetChild(num -1)
				it.gameObject:SetActive(false)
			end
		--end
		grid:Reposition()
	end
	local notice = infoitem:Find("text")
	if notice ~= nil then
		notice.gameObject:SetActive(award == nil)
	end
end
