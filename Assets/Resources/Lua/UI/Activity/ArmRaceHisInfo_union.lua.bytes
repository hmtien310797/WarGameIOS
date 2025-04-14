module("ArmRaceHisInfo_union", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local _ui
local unionRaceId
local unionRaceBaseListData

local function CloseClickCallback(go)
    Hide()
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

local function LoadItem(rewarditem , reward)
	local itemData = TableMgr:GetItemData(reward.contentId)
	local item = {}
	UIUtil.LoadItemObject(item, rewarditem.transform)
	UIUtil.LoadItem(item, itemData, reward.contentNumber)
    UIUtil.SetClickCallback(item.transform.gameObject, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
        end
    end)
end

local function LoadBriefRewardHero(grid , dropdata)
	local info = NGUITools.AddChild(grid.gameObject ,_ui.briefRewardHero.gameObject)
	info.transform:SetParent(grid.transform , false)
	info.gameObject:SetActive(true)
	info.transform.localScale = Vector3(0.63 , 0.63 , 0.63)
	info.gameObject.name = "2_" .. dropdata.contentId
	
	local heroData = TableMgr:GetHeroData(dropdata.contentId)
	local heroicon = info.transform:Find("head icon"):GetComponent("UITexture")
	heroicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
	
	local herolv = info.transform:Find("level text"):GetComponent("UILabel")
	herolv.text = dropdata.level
	
	local herostar = info.transform:Find(System.String.Format("star/star{0}" , dropdata.star))
	herostar.gameObject:SetActive(true)
	
	--local heroQuality = info.transform:Find(System.String.Format("head icon/outline{0}" , heroData.quality))
	--heroQuality.gameObject:SetActive(true)
	table.insert(itemtipslist , info)
end

local function LoadRankRewardItem(dropId , rank)
	local rewardTerm = NGUITools.AddChild(_ui.rewardRankScrollGrid.gameObject , _ui.rewardRankItem.gameObject)
	rewardTerm.transform:SetParent(_ui.rewardRankScrollGrid.transform , false)
	
	local originRank = rank
	--title
	if rank == 4 then
		rank = "4—10"
	elseif rank == 5 then
		rank = "11—20"
	elseif rank == 6 then
		rank = "21—50"
	
	end
	local title = rewardTerm.transform:Find(System.String.Format("title/no.{0}" , rank))
	local title = rewardTerm.transform:Find("title/no.1"):GetComponent("UILabel")
	title.text = rank
	
	local chest = rewardTerm.transform:Find("title/chest")
	chest.gameObject:SetActive(rank == 1)
	--detail
	local rewardgrid = rewardTerm.transform:Find("mid/Grid"):GetComponent("UIGrid")
	local showlist = TableMgr:GetDropShowData(dropId)
	local rewardDepth = rewardTerm:GetComponent("UIWidget").depth
	if #showlist > 0 then
        NGUITools.NormalizeWidgetDepths(rewardTerm.gameObject)
		for i , v in pairs(showlist) do
			local listItem = NGUITools.AddChild(rewardgrid.gameObject , _ui.rewardListItem)
			listItem.transform.localScale = Vector3(0.7 , 0.7 , 1)
		
			local dropdata = showlist[i]
			if dropdata.contentType == 1 then
				LoadItem(listItem , dropdata)
			elseif dropdata.contentType == 2 then
				
			end
		end
		rewardgrid:Reposition()
	
	end
	--[[if showlist.Length > 0 then
		for i = 0, showlist.Length - 1 do
			local listItem = NGUITools.AddChild(rewardgrid.gameObject , _ui.rewardListItem.gameObject)
			listItem.transform:SetParent(rewardgrid.transform , false)
			listItem.transform.localScale = Vector3(0.7 , 0.7 , 1)
		
			local dropdata = showlist[i]
			if dropdata.contentType == 1 then
				LoadItem(listItem , dropdata)
			elseif dropdata.contentType == 2 then
				
			end
		end
		rewardgrid:Reposition()
	end]]

    NGUITools.NormalizeWidgetDepths(rewardTerm.gameObject)
	local leaderRewardGrid = rewardTerm.transform:Find("champions/Grid"):GetComponent("UIGrid")
    ShareCommon.LoadRewardList(_ui, leaderRewardGrid.transform, unionRaceBaseListData["ExtraShow" .. originRank], Vector3(0.7, 0.7, 1))
    leaderRewardGrid.repositionNow = true
end
local function LoadHistoryTableItem(hisMsg)
	local info = NGUITools.AddChild(_ui.rewardHistoryItemTable.gameObject , _ui.rewardHistoryItem.gameObject)
	info.transform:SetParent(_ui.rewardHistoryItemTable.transform , false)
	info.gameObject:SetActive(true)
	
	local paraController = info:GetComponent("ParadeTableItemController")
	local activeListData = TableMgr:GetActivityStaticsListData(hisMsg.actId)

	--race time
	local raceName = info.transform:Find("bg_list/Sprite/Label"):GetComponent("UILabel")
	raceName.text = TextMgr:GetText(activeListData.name)
	local raceTime = info.transform:Find("bg_list/Sprite/time"):GetComponent("UILabel")
	raceTime.text = Global.SecondToStringFormat(hisMsg.startTime , "yyyy/MM/dd")
	
	local grid = info.transform:Find("Item_open01/Grid"):GetComponent("UIGrid")
	local gridItem = info.transform:Find("Item_open01/info")
	local openHeight = info:GetComponent("UIWidget").height
	for i=1 , #hisMsg.data , 1 do
		local item = NGUITools.AddChild(grid.gameObject , gridItem.gameObject)
		item.transform:SetParent(grid.transform , false)
		item.gameObject:SetActive(true)
		
		local msgdata = hisMsg.data[i]
		local charName = item.transform:Find("name"):GetComponent("UILabel")
		 
		local guilBaner = ""
		if msgdata.guildBanner ~= nil or msgdata.guildBanner == "" then
			guilBaner = "[" ..msgdata.guildBanner .. "]"
		end
		
		charName.text = --[["#"..msgdata.zoneId .. --]] guilBaner .. msgdata.charName
		local charPoint = item.transform:Find("points"):GetComponent("UILabel")
		charPoint.text = msgdata.score
		local charRank = item.transform:Find("no.1"):GetComponent("UILabel")
		charRank.text = i
		openHeight = openHeight + item:GetComponent("UIWidget").height
	end
	grid:Reposition()
	
	--print(openHeight)
	paraController:SetItemOpenHeight(openHeight) --+ container.Table.iteminfo:GetComponent("UIWidget").height - rowdis)
end

local function SortHistoryMsg(hisMsg)
	local sortTable = {}
	for i=1 , #hisMsg.data , 1 do
		table.insert(sortTable , hisMsg.data[i])
	end
	
	table.sort(sortTable , function (v1,v2)
		return v1.startTime > v2.startTime
	end)
	return sortTable
end


local function LoadRankHistory()
	ActiveStaticsData.RequActiveStaticsRankHistory(ActiveStaticsData.ActiveStaticType.AST_UNION , function(msg)
		
		--[[local msg1 = 
		{
			actId = 1 ,
			startTime = 1,
			endTime = 1 , 
			data =
			{
				[1] = 
				{
					zoneId = 1 ,
					score = 1,
					charName = "蛇皮",
					guildBanner = "2323",
				},
				[2] = 
				{
					zoneId = 1 ,
					score = 2,
					charName = "蛇皮2",
					guildBanner = "2323",
				},
				[3] = 
				{
					zoneId = 1 ,
					score = 3,
					charName = "蛇皮3",
					guildBanner = "2323",
				},
			}
			
		}
		
		LoadHistoryTableItem(msg1)
		]]
		while _ui.rewardHistoryItemTable.transform.childCount > 0 do
			GameObject.DestroyImmediate(_ui.rewardHistoryItemTable.transform:GetChild(0).gameObject)
		end
	
		local hisTable = SortHistoryMsg(msg)
		for i=1 , #hisTable , 1 do
			LoadHistoryTableItem(hisTable[i])
		end
		_ui.rewardHistoryItemTable:Reposition()
	end)
end

local function LoadRankReward()
	--local activeListData = TableMgr:GetActivityStaticsListData(actId)
	local totalRankRewards = {}
	
	table.insert(totalRankRewards , unionRaceBaseListData.show1)
	table.insert(totalRankRewards , unionRaceBaseListData.show2)
	table.insert(totalRankRewards , unionRaceBaseListData.show3)
	table.insert(totalRankRewards , unionRaceBaseListData.show4)
	table.insert(totalRankRewards , unionRaceBaseListData.show5)
	table.insert(totalRankRewards , unionRaceBaseListData.show6)
	
	while _ui.rewardRankScrollGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.rewardRankScrollGrid.transform:GetChild(0).gameObject)
	end
	
	for i=1 , 4 , 1 do
		LoadRankRewardItem(totalRankRewards[i] , i)
	end
	_ui.rewardRankScrollGrid:Reposition()
end


local function LoadUnionRankItem(data , grid , showCount)
	while grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
	end
	
	if data.rankList == nil then
		return
	end
	for i=1 , #data.rankList , 1 do
		if i <= showCount then 
			local item ={}
			local data = data.rankList[i]
			if data.guildId == UnionInfoData.GetGuildId() then
				item.trf = NGUITools.AddChild(grid.gameObject , _ui.unionRankItem3.gameObject).transform
				item.name = item.trf:Find("name"):GetComponent("UILabel")
				item.number = item.trf:Find("number"):GetComponent("UILabel")
				item.no = item.trf:Find("no"):GetComponent("UILabel")
			else
				item.trf = NGUITools.AddChild(grid.gameObject , _ui.unionRankItem2.gameObject).transform
				item.name = item.trf:Find("name"):GetComponent("UILabel")
				item.number = item.trf:Find("number"):GetComponent("UILabel")
				local index = data.rank < 4 and data.rank or 4
				
				item.topno = item.trf:Find(System.String.Format("no.{0}",index))
				item.no = item.topno:GetComponent("UILabel")
			end
			
			--[[if i < 5 then
				item.trf = NGUITools.AddChild(grid.gameObject , _ui.unionRankItem2.gameObject).transform
				item.name = item.trf:Find("name"):GetComponent("UILabel")
				item.number = item.trf:Find("number"):GetComponent("UILabel")
				item.topno = item.trf:Find(System.String.Format("no.{0}",i))
			else
				
				item.trf = NGUITools.AddChild(grid.gameObject , _ui.unionRankItem3.gameObject).transform
				item.name = item.trf:Find("name"):GetComponent("UILabel")
				item.number = item.trf:Find("number"):GetComponent("UILabel")
				item.no = item.trf:Find("no"):GetComponent("UILabel")
			end]]
			item.trf:SetParent(grid.transform , false)
			
			--local data = data.rankList[i]
			if item.name ~= nil then
				item.name.text = "【" .. data.guildBanner .. "】" .. data.guildName
			end
			if item.number ~= nil then
				item.number.text = data.score
			end
			if item.no ~= nil then
				item.no.text = data.rank
			end
			if item.topno ~= nil then
				item.topno.gameObject:SetActive(true)
			end
		end
	end
	grid:Reposition()
end

--[[
	_ui.unionRankBg1 = transform:Find("widget/Container03/mid02")
	_ui.unionRankBg2 = transform:Find("widget/Container03/mid03")
	_ui.unionRankGrid = transform:Find("widget/Container03/mid02/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.unionMyRankGrid = transform:Find("widget/Container03/mid02/myrank/Grid"):GetComponent("UIGrid")
	_ui.unionRankGrid1 = transform:Find("widget/Container03/mid03/Scroll View/Grid"):GetComponent("UIGrid")
]]
local function LoadUnionRank()
	local rankShow = 10
	rank.GuildRankListRequest(5,function(msg)
		_ui.unionRankTip.gameObject:SetActive(msg.rankList == nil or #msg.rankList == 0)
		_ui.unionRankTipLabel.text = TextMgr:GetText("Armrace_28")
		
		--top rank
		local noMyRank = (msg.myRank == nil or msg.myRank.rank == 0 or msg.myRank.rank > rankShow)
		--_ui.unionRankBg1.gameObject:SetActive(noMyRank)
		if noMyRank then
			_ui.unionRankBg2.gameObject:SetActive(false)
			_ui.unionRankBg1.gameObject:SetActive(true)
			LoadUnionRankItem(msg ,_ui.unionRankGrid ,rankShow)
		
			local mymsg = {}
			mymsg.rankList = {}
			--_ui.unionMyRankTrf.gameObject:SetActive(msg.myRank == nil or msg.myRank.rank > rankShow)
			if msg.myRank == nil or msg.myRank.rank == 0 then
				_ui.unionMyRankNone.gameObject:SetActive(true)
			else
				_ui.unionMyRankNone.gameObject:SetActive(false)
				if msg.beforeRank ~= nil and msg.beforeRank.rank ~= 0 then
					table.insert(mymsg.rankList , msg.beforeRank)
				end 
				--myrank
				table.insert(mymsg.rankList , msg.myRank)
				
				--after rank
				if msg.afterRank ~= nil and msg.afterRank.rank ~= 0 then
					table.insert(mymsg.rankList , msg.afterRank)
				end 
				LoadUnionRankItem(mymsg ,_ui.unionMyRankGrid ,3)
			end
		else
			_ui.unionRankBg2.gameObject:SetActive(true)
			_ui.unionRankBg1.gameObject:SetActive(false)
			LoadUnionRankItem(msg ,_ui.unionRankGrid1 ,rankShow)
		end
		
		
		
	end)
end

local function LoadMemberContribute(datas , grid , item2 , item3)
	if datas == nil or #datas == 0 then
		return
	end
	while grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
	end
	
	for i=1 , #datas , 1 do
		local data = datas[i]
		local itemPrefab = nil
		local item = {}
		if data.charid == MainData.GetCharId() then
			item.trf = NGUITools.AddChild(grid.gameObject , item3.gameObject).transform
			item.name = item.trf:Find("name"):GetComponent("UILabel")
			item.number = item.trf:Find("number"):GetComponent("UILabel")
			item.no = item.trf:Find("no"):GetComponent("UILabel")
		else
			item.trf = NGUITools.AddChild(grid.gameObject , item2.gameObject).transform
			item.name = item.trf:Find("name"):GetComponent("UILabel")
			item.number = item.trf:Find("number"):GetComponent("UILabel")
			
			local no = i < 4 and i or 4
			local norank = item.trf:Find("no."..no)		
			item.notrf = norank
			item.no = norank:GetComponent("UILabel")

			if i == 1 then
				item.noSpr = norank:Find("Sprite"):GetComponent("UISprite")
			end

		end
		item.trf:SetParent(grid.transform , false)
		
		if item.name ~= nil then
			item.name.text = data.name
		end
		if item.number ~= nil then
			item.number.text = data.value
		end	
		if item.notrf ~= nil then
			item.notrf.gameObject:SetActive(true)
		end
		if item.no ~= nil then
			item.no.text = i
		end
		if item.noSpr ~= nil then
			item.noSpr.gameObject:SetActive(true)
		end
		
	end
	
	grid:Reposition()
end


local function SortHistoryContributeMsg(hisMsg)
	local sortTable = {}
	for i=1 , #hisMsg.data , 1 do
		table.insert(sortTable , hisMsg.data[i])
	end
	
	table.sort(sortTable , function (v1,v2)
		return v1.value > v2.value
	end)
	return sortTable
end


local function LoadUnionContribute()
	ActiveStaticsData.RequestUnionContributeRankHistory(false , function(msg)
		_ui.unionContTip.gameObject:SetActive(msg.data.data == nil or #msg.data.data == 0)
		_ui.unionContTipLabel.text = TextMgr:GetText("Armrace_28")
		
		LoadMemberContribute(SortHistoryContributeMsg(msg.data) , _ui.unionContGrid , _ui.unionContItem2 , _ui.unionContItem3)
	end)
end

local function LoadTotalContribute()
	ActiveStaticsData.RequestUnionContributeRankHistory(true , function(msg)
		_ui.unionTotalContTip.gameObject:SetActive(msg.data.data == nil or #msg.data.data == 0)
		_ui.unionTotalContTipLabel.text = TextMgr:GetText("Armrace_28")
		
		LoadMemberContribute(SortHistoryContributeMsg(msg.data) , _ui.unionTotalContGrid , _ui.unionTotalContItem2 , _ui.unionTotalContItem3)
	end)
end
	
local function LoadUI()
	unionRaceBaseListData = TableMgr:GetActivityStaticsListData(unionRaceId)
	LoadRankReward()
end


local function UpdateUIInfo()
	
end


function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Awake()
	_ui = {}
	_ui.rewardNHistory = transform:Find("mask")
	_ui.rewardRank = transform:Find("widget/Container01")
	_ui.rewardRankScrollView = transform:Find("widget/Container01/base/Scroll View"):GetComponent("UIScrollView")
	_ui.rewardRankScrollGrid = transform:Find("widget/Container01/base/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.rewardRankItem = transform:Find("widget/Container01/base/term01")
	_ui.rewardHistory = transform:Find("widget/Container02")
	_ui.rewardHistoryItemTable = transform:Find("widget/Container02/base/Scroll View/Table"):GetComponent("UITable")
	_ui.rewardHistoryItem = transform:Find("widget/Container02/ItemInfo01")
	_ui.CloseBtn = transform:Find("background/close btn")
	
	_ui.unionRankTrf = transform:Find("widget/Container03")
	_ui.unionRankBg1 = transform:Find("widget/Container03/mid02")
	_ui.unionRankBg2 = transform:Find("widget/Container03/mid03")
	_ui.unionRankGrid = transform:Find("widget/Container03/mid02/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.unionMyRankGrid = transform:Find("widget/Container03/mid02/myrank/Grid"):GetComponent("UIGrid")
	_ui.unionRankGrid1 = transform:Find("widget/Container03/mid03/Scroll View/Grid"):GetComponent("UIGrid")
	
	_ui.unionMyRankNone = transform:Find("widget/Container03/mid02/myrank/none")
	_ui.unionMyRankTrf = transform:Find("widget/Container03/mid02/myrank")
	_ui.unionMyRankNoRank = transform:Find("widget/Container03/mid02/myrank/none/Label01")
	_ui.unionMyRankNoUnion = transform:Find("widget/Container03/mid02/myrank/none/Label02")
	_ui.unionRankTip = transform:Find("widget/Container03/none")
	_ui.unionRankTipLabel = transform:Find("widget/Container03/none/Label"):GetComponent("UILabel")
	
	_ui.unionRankItem2 = transform:Find("widget/Container03/bg2")
	_ui.unionRankItem3 = transform:Find("widget/Container03/bg3")

	_ui.unionContTrf = transform:Find("widget/Container04")
	_ui.unionContGrid = transform:Find("widget/Container04/mid03/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.unionContItem2 = transform:Find("widget/Container04/bg2")
	_ui.unionContItem3 = transform:Find("widget/Container04/bg3")
	_ui.unionContTip = transform:Find("widget/Container04/none")
	_ui.unionContTipLabel = transform:Find("widget/Container04/none/Label"):GetComponent("UILabel")
	
	_ui.unionTotalContTrf = transform:Find("widget/Container05")
	_ui.unionTotalContGrid = transform:Find("widget/Container05/mid03/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.unionTotalContItem2 = transform:Find("widget/Container05/bg2")
	_ui.unionTotalContItem3 = transform:Find("widget/Container05/bg3")
	_ui.unionTotalContTip = transform:Find("widget/Container05/none")
	_ui.unionTotalContTipLabel = transform:Find("widget/Container05/none/Label"):GetComponent("UILabel")
	
	
	_ui.rewardAllRewardBtn = transform:Find("widget/page1"):GetComponent("UIButton")
	_ui.unionHistoryBtn = transform:Find("widget/page2"):GetComponent("UIButton")
	_ui.unionRankBtn = transform:Find("widget/page3"):GetComponent("UIButton")
	_ui.unionContributeBtn = transform:Find("widget/page4"):GetComponent("UIButton")
	_ui.totalContributeBtn = transform:Find("widget/page5"):GetComponent("UIButton")
	
	
	
	_ui.rewardListItem = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	
	SetClickCallback(_ui.rewardNHistory.gameObject , Hide)
	SetClickCallback(_ui.CloseBtn.gameObject , Hide)
	SetClickCallback(_ui.rewardAllRewardBtn.gameObject , LoadRankReward)
	SetClickCallback(_ui.unionHistoryBtn.gameObject , LoadRankHistory)
	SetClickCallback(_ui.unionRankBtn.gameObject , LoadUnionRank)
	SetClickCallback(_ui.unionContributeBtn.gameObject , LoadUnionContribute)
	SetClickCallback(_ui.totalContributeBtn.gameObject , LoadTotalContribute)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	
	ActiveStaticsData.AddListener(UpdateUIInfo)
end

function Close()
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
	_ui = nil
	ActiveStaticsData.RemoveListener(UpdateUIInfo)
end


function LateUpdate()
end

function Show(raceId)
	unionRaceId = raceId
    Global.OpenUI(_M)
	LoadUI()
end
