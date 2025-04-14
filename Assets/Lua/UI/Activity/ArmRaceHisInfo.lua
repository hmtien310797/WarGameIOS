module("ArmRaceHisInfo", package.seeall)

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
local peronalRaceId
local personalRaceBaseListData

local function CloseClickCallback(go)
    Hide()
end

local function LoadItem(rewarditem , reward)
	local itemTBData = TableMgr:GetItemData(reward.contentId)
	local item = {}
	UIUtil.LoadItemObject(item, rewarditem.transform)
	UIUtil.LoadItem(item, itemTBData, reward.contentNumber)
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
	if #showlist > 0 then
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
	raceTime.text = Global.SecondToStringFormat(hisMsg.startTime , "HH:mm" , false) .. "--" .. Global.SecondToStringFormat(hisMsg.endTime , "HH:mm")
	
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
	ActiveStaticsData.RequActiveStaticsRankHistory(ActiveStaticsData.ActiveStaticType.AST_PERSONAL , function(msg)
		
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
	
	table.insert(totalRankRewards , personalRaceBaseListData.show1)
	table.insert(totalRankRewards , personalRaceBaseListData.show2)
	table.insert(totalRankRewards , personalRaceBaseListData.show3)
	table.insert(totalRankRewards , personalRaceBaseListData.show4)
	table.insert(totalRankRewards , personalRaceBaseListData.show5)
	table.insert(totalRankRewards , personalRaceBaseListData.show6)
	
	while _ui.rewardRankScrollGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.rewardRankScrollGrid.transform:GetChild(0).gameObject)
	end
	
	for i=1 , 4 , 1 do
		LoadRankRewardItem(totalRankRewards[i] , i)
	end
	_ui.rewardRankScrollGrid:Reposition()
end

local function LoadUI()
	personalRaceBaseListData = TableMgr:GetActivityStaticsListData(peronalRaceId)
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
	
	_ui.rewardAllRewardBtn = transform:Find("widget/page1"):GetComponent("UIButton")
	_ui.rewardHistoryBtn = transform:Find("widget/page2"):GetComponent("UIButton")
	
	
	
	_ui.rewardListItem = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	
	SetClickCallback(_ui.rewardNHistory.gameObject , Hide)
	SetClickCallback(_ui.CloseBtn.gameObject , Hide)
	SetClickCallback(_ui.rewardAllRewardBtn.gameObject , LoadRankReward)
	SetClickCallback(_ui.rewardHistoryBtn.gameObject , LoadRankHistory)
	
	ActiveStaticsData.AddListener(UpdateUIInfo)
end

function Close()
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
	_ui = nil
	ActiveStaticsData.RemoveListener(UpdateUIInfo)
end


function LateUpdate()
end

function Show(raceId)
	peronalRaceId = raceId
    Global.OpenUI(_M)
	LoadUI()
end
