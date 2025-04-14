module("UnionRadar", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui
local LoadUI
local LoadItem
local FreshInfoItem
local unionMonsterMsg
local briefRewardItemPrefab
local ItemUpdateList

local itemtipslist


local helpdata = 
{
	title = "Union_Radar_ui30",
	icon = "Background/loading1",
	iconbg = "Background/loading2",
	text = "Union_Radar_ui31",
	infos = {"Union_Radar_ui32","Union_Radar_ui33","Union_Radar_ui34","Union_Radar_ui35","Union_Radar_ui36","Union_Radar_ui37","Union_Radar_ui38" , "Union_Radar_ui48" , "Union_Radar_ui49"}
}


local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	if itemtipslist == nil then
		return
	end
	for i, v in pairs(itemtipslist) do
		if go == v then
			local str = go.name:split("_")
			local itemName , itemDes
			if str[1] == "1" then
				local item = TableMgr:GetItemData(tonumber(str[2]))
				itemName = item.name
				itemDes = item.description
			elseif str[1] == "2" then
				local item = TableMgr:GetHeroData(tonumber(str[2]))
				itemName = item.nameLabel
				itemDes = item.description
			end
			
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemName), text = TextMgr:GetText(itemDes)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(itemName), text = TextMgr:GetText(itemDes)})
		        end
		    end
		    return
		end
	end
	Tooltip.HideItemTip()
end


function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function LoadBriefRewardItem(grid , dropdata)
	local itemTransform = NGUITools.AddChild(grid.gameObject ,_ui.briefRewardItem).transform
	--info.transform:SetParent(grid.transform , false)
	--info.gameObject:SetActive(true)
	itemTransform.localScale = Vector3(0.66 , 0.66 , 0.66)
	itemTransform.gameObject.name = "1_" .. dropdata.contentId
	
	local itemTBData = TableMgr:GetItemData(dropdata.contentId)
	local item = {}
	UIUtil.LoadItemObject(item, itemTransform)
	UIUtil.LoadItem(item, itemTBData, nil)
	
	
	table.insert(itemtipslist , itemTransform.gameObject)
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


local function LoadRewardListItem(grid , showlist , titleText)
	if #showlist > 0 then
		local listItem = NGUITools.AddChild(grid.gameObject ,_ui.rewardInfo_list.gameObject)
		listItem.transform:SetParent(grid.transform , false)
		listItem.gameObject:SetActive(true)
		--title
		local title = listItem.transform:Find("bg_title/title_chapter"):GetComponent("UILabel")
		title.text = titleText
		--detail
		local rewardgrid = listItem.transform:Find("Scroll View/Grid"):GetComponent("UIGrid")
		for i,v in pairs(showlist) do
			local dropdata = showlist[i]
			if dropdata.contentType == 1 then
				LoadBriefRewardItem(rewardgrid , showlist[i])
			elseif dropdata.contentType == 3 then
				LoadBriefRewardHero(rewardgrid , showlist[i])
			end
		end
		rewardgrid:Reposition()
	end
end

local function CheckRewardDetail(msg)
	local unionMonsterData = TableMgr:GetUnionMonsterData(msg.id)
	_ui.rewardInfo.gameObject:SetActive(true)
	while _ui.rewardInfo_listGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.rewardInfo_listGrid.transform:GetChild(0).gameObject)
	end 
	
	--gate reward
	local gateShowList = TableMgr:GetDropShowData(unionMonsterData.gateRewardsShow)
	LoadRewardListItem(_ui.rewardInfo_listGrid , gateShowList , TextMgr:GetText("Union_Radar_ui26"))
	
	--moster reward
	local monsterShowList = TableMgr:GetDropShowData(unionMonsterData.bossRewardsShow)
	LoadRewardListItem(_ui.rewardInfo_listGrid , monsterShowList , TextMgr:GetText("Union_Radar_ui27"))
	
	--person reward
	local perShowList = TableMgr:GetDropShowData(unionMonsterData.personRewardsShow)
	LoadRewardListItem(_ui.rewardInfo_listGrid , perShowList, TextMgr:GetText("Union_Radar_ui28"))
	
	--union reward
	local unioShowList = TableMgr:GetDropShowData(unionMonsterData.unionRewardsShow)
	LoadRewardListItem(_ui.rewardInfo_listGrid , unioShowList, TextMgr:GetText("Union_Radar_ui29"))
	
	_ui.rewardInfo_listGrid:Reposition()
end

function Awake()
	_ui = {}
	ItemUpdateList = {}
	itemtipslist = {}
	local closeBtn = transform:Find("Container/close btn"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject, Hide)
	
	SetClickCallback(transform:Find("mask").gameObject , Hide)
	
	_ui.radarInfo = transform:Find("RadarInfo")
	_ui.briefRewardItem = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")--transform:Find("list_item")
	_ui.briefRewardHero = transform:Find("list_hero")
	_ui.scrollview = transform:Find("Container/bg_mid/Scroll View"):GetComponent("UIScrollView")
	
	--_ui.grid = transform:Find("Container/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.rewardInfo = transform:Find("RewardInfo")
	_ui.rewardInfo_list = transform:Find("RewardInfo/bg_list")
	_ui.rewardInfo_listScrollview = transform:Find("RewardInfo/Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_ui.rewardInfo_listGrid = transform:Find("RewardInfo/Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	SetClickCallback(transform:Find("RewardInfo/Container").gameObject , function()
		_ui.rewardInfo.gameObject:SetActive(false)
	end)
	SetClickCallback(transform:Find("RewardInfo/Container/bg_frane/close btn").gameObject , function()
		_ui.rewardInfo.gameObject:SetActive(false)
	end)
	SetClickCallback(transform:Find("Container/title/detail").gameObject , function()
		instructions.Show(helpdata)
	end)
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	UnionRadarData.AddListener(FreshUnionMonsterData)
end

function FreshUnionMonsterData(monsterMsg)
	unionMonsterMsg = UnionRadarData.GetData()
end

local function LocationMonster(monsterMsg)
	local req = BattleMsg_pb.MsgBattleGuildMonsterFoundRequest()
	req.id = monsterMsg.id
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleGuildMonsterFoundRequest, req, BattleMsg_pb.MsgBattleGuildMonsterFoundResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			UnionRadarData.UpdateUnionRadarData(msg.monster)
			if FreshInfoItem ~= nil then
				LoadItem(FreshInfoItem , msg.monster)
			end
		end
	end)
end

local function GoToMonster(monsterMsg)
	
end

local function BattleHistory(monsterMsg)
	UnionRadarHis.Show()
end

local function GetMonsterState(msg)
	local isLocated = false
	local monsterState = 0
	
	local isLocated = msg.uid > 0
	local monsterState = 0
	if isLocated and msg.hp > 0 and not msg.mapMonsterDead then
		monsterState = 1 --城门阶段
	end
	if isLocated and msg.hp == 0 and not msg.mapMonsterDead then
		monsterState = 2 --叛军阶段
		local startTimeLeft = msg.pvpStartTime - Serclimax.GameTime.GetSecTime()
		if startTimeLeft > 0 then
			monsterState = 3 --叛军等待阶段
		end
	end
	return isLocated , monsterState
end

LoadItem = function(info , msg)
	local unionMonsterData = TableMgr:GetUnionMonsterData(msg.id)
	--name
	local name = info.transform:Find("bg_frane/bg_name/name"):GetComponent("UILabel")
	name.text = TextMgr:GetText(unionMonsterData.name)
	--icon
	local icon = info.transform:Find("bg_frane/bg_texture/texture"):GetComponent("UITexture")
	icon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/" , unionMonsterData.icon)
	
	
	local btnGo = info.transform:Find("bg_frane/btn_go"):GetComponent("UIButton")
	local btnHis = info.transform:Find("bg_frane/btn_history"):GetComponent("UIButton")
	local btnLoc   = info.transform:Find("bg_frane/btn_location"):GetComponent("UIButton")
	if unionMonsterMsg.unlockBattle >= msg.id then --已解锁
		info.transform:Find("bg_frane/unlock").gameObject:SetActive(false)
		info.transform:Find("bg_frane/bg_des").gameObject:SetActive(true)
		info.transform:Find("bg_frane/bg_reward").gameObject:SetActive(true)
		info.transform:Find("bg_frane/btn_location").gameObject:SetActive(true)
		
		local title1 = info.transform:Find("bg_frane/bg_des/txt_title1"):GetComponent("UILabel")
		local titledes1 = info.transform:Find("bg_frane/bg_des/txt_title1/txt_desc"):GetComponent("UILabel")
		local title2 = info.transform:Find("bg_frane/bg_des/txt_title2"):GetComponent("UILabel")
		local titledes2 = info.transform:Find("bg_frane/bg_des/txt_title2/txt_desc"):GetComponent("UILabel")
		local title3 = info.transform:Find("bg_frane/bg_des/txt_title3"):GetComponent("UILabel")
		local titledes3 = info.transform:Find("bg_frane/bg_des/txt_title3/txt_desc"):GetComponent("UILabel")
		local title4 = info.transform:Find("bg_frane/bg_des/txt_title4"):GetComponent("UILabel")
		local titledes4 = info.transform:Find("bg_frane/bg_des/txt_title4/txt_desc"):GetComponent("UILabel")
		
		--complet
		local finish = msg.uid > 0 and msg.hp == 0 and msg.mapMonsterDead
		info.transform:Find("bg_frane/bg_texture/icon_finish").gameObject:SetActive(finish)
		
		--monster state
		local isLocated ,monsterState = GetMonsterState(msg)
		--des
		btnGo.gameObject:SetActive(isLocated)
		btnHis.gameObject:SetActive(isLocated)
		btnLoc.gameObject:SetActive(not isLocated)
		
		titledes1.text = isLocated and msg.hp .. "/"..unionMonsterData.hp or unionMonsterData.minHp .. " - " .. unionMonsterData.maxHp
		titledes2.text = isLocated and unionMonsterData.fight or unionMonsterData.minFight .. " - " .. unionMonsterData.maxFight
		titledes4.text = isLocated and System.String.Format("X:{0} , Y:{1}" , msg.pos.x , msg.pos.y) or "----"

		if monsterState == 2 then
			title1.text = TextMgr:GetText("Union_Radar_ui44")
			titledes1.text = TextMgr:GetText("Union_Radar_ui45")
		elseif monsterState == 3 then
			title1.text = TextMgr:GetText("Union_Radar_ui44")
		else
			title1.text = TextMgr:GetText("Union_Radar_ui14")
		end
		
		SetClickCallback(btnLoc.gameObject , function()
			if unionMonsterMsg.findCount.count >=  unionMonsterMsg.findCount.countmax then
				FloatText.Show(TextMgr:GetText("Union_Radar_ui41") , Color.white)
			else
				if not UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_GuildMonster) then
					FloatText.Show(TextMgr:GetText("Union_Radar_ui46"))
					return
				end
				
				FreshInfoItem = info
				LocationMonster(msg)
			end
		end)
		
		SetClickCallback(btnGo.gameObject , function()
			if finish then
				FloatText.Show(TextMgr:GetText("Union_Radar_ui43") , Color.white)
				return
			end
			
			Hide()
			if GUIMgr:FindMenu("UnionInfo") ~= nil then
				UnionInfo.Hide()
			end
			MainCityUI.ShowWorldMap(msg.pos.x, msg.pos.y, true)
		end)
		
		SetClickCallback(info.transform:Find("bg_frane/btn_history").gameObject , function()
			BattleHistory(msg)
		end)
		
		SetClickCallback(info.transform:Find("bg_frane/bg_reward/btn_check").gameObject , function()
			CheckRewardDetail(msg)
		end)
		
		
		--reward1
		local dropShowList = TableMgr:GetDropShowData(unionMonsterData.unionRewardsbrifShow)
		local rewardgrid = info.transform:Find("bg_frane/bg_reward/Scroll View/Grid"):GetComponent("UIGrid")
		while rewardgrid.transform.childCount > 0 do
			GameObject.DestroyImmediate(rewardgrid.transform:GetChild(0).gameObject)
		end
		for i, v in pairs(dropShowList) do
			if i < 3 then
				local dropdata = dropShowList[i]
				if dropdata.contentType == 1 then
					LoadBriefRewardItem(rewardgrid , dropShowList[i])
				elseif dropdata.contentType == 3 then
					LoadBriefRewardHero(rewardgrid , dropShowList[i])
				end
			end
		end
		--[[for i = 0, dropShowList.Length - 1 do
			if i < 3 then
				local dropdata = dropShowList[i]
				if dropdata.contentType == 1 then
					LoadBriefRewardItem(rewardgrid , dropShowList[i])
				elseif dropdata.contentType == 3 then
					LoadBriefRewardHero(rewardgrid , dropShowList[i])
				end
			end
		end]]
		rewardgrid:Reposition()
		
		--reward detail
		
		
	else
		info.transform:Find("bg_frane/unlock").gameObject:SetActive(true)
		info.transform:Find("bg_frane/unlock/lock/unlock"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("Union_Radar_ui39"), math.max(1 , msg.id - 1))
		info.transform:Find("bg_frane/bg_des").gameObject:SetActive(false)
		info.transform:Find("bg_frane/bg_reward").gameObject:SetActive(false)
		
		btnGo.gameObject:SetActive(false)
		btnHis.gameObject:SetActive(false)
		btnLoc.gameObject:SetActive(false)

		info.transform:Find("bg_frane/bg_texture/icon_finish").gameObject:SetActive(msg.uid > 0 and msg.hp == 0)
	end
end

local function UpdateUnionMonstListItem(info , index , realInde)
	local realIndex = realInde+1
	local v = unionMonsterMsg.battle[realIndex]
	if v ~= nil then
		--local unionMonsterData = TableMgr:GetUnionMonsterData(v.id)
		ItemUpdateList[index] = realIndex
		LoadItem(info , v)
		
	end
end

LoadUI = function()
	if unionMonsterMsg == nil then
		return
	end
	
	--获取权限
	local unionInfoMsg = UnionInfoData.GetData()
	local memberMsg = unionInfoMsg.memberInfo
	
	
	local datalength = #unionMonsterMsg.battle
	print(datalength)

	local optGridTransform = _ui.scrollview.transform:Find("OptGrid")
	if optGridTransform ~= nil then
		GameObject.DestroyImmediate(optGridTransform.gameObject)
	end
		
	local wrapParam = {}
	wrapParam.OnInitFunc = UpdateUnionMonstListItem
	wrapParam.itemSize = 400
	wrapParam.minIndex = 0
	wrapParam.maxIndex = (datalength-1)
	wrapParam.itemCount = datalength < 3 and datalength or 3-- 预设项数量。 -1为实际显示项数量
	wrapParam.cellPrefab = _ui.radarInfo
	wrapParam.localPos = Vector3(-75,-93 , 0)
	wrapParam.cullContent = false
	wrapParam.moveDir = 2--horizal
	UIUtil.CreateWrapContent(_ui.scrollview , wrapParam , function(optGridTrf)
		--[[while _ui.giftGrid.transform.childCount > 0 do
			GameObject.DestroyImmediate(_ui.giftGrid.transform:GetChild(0).gameObject)
		end]]
		_ui.grid = optGridTrf
	end)
	_ui.scrollview:ResetPosition()
	
end

function LateUpdate()
	for i , v in pairs(ItemUpdateList) do
		if v ~= nil and v > 0 then
			if _ui.grid ~= nil then
				local updateItem = _ui.grid:GetChild(i)
				local msg = unionMonsterMsg.battle[v]
				if updateItem ~= nil and msg ~= nil then
					--逃跑时间
					local timeLabel = updateItem:Find("bg_frane/bg_des/txt_title3/txt_desc"):GetComponent("UILabel")
					local leftTimeSec = msg.escapeTime - Serclimax.GameTime.GetSecTime()
					if leftTimeSec > 0 then
						local countDown = Global.GetLeftCooldownTextLong(msg.escapeTime)
						timeLabel.text = countDown
					else
						timeLabel.text = "--:--:--"
					end
					
					--pvp开启时间
					local isLocated ,monsterState = GetMonsterState(msg)
					if monsterState == 3 then
						local pvpStartTimeLabel = updateItem:Find("bg_frane/bg_des/txt_title1/txt_desc"):GetComponent("UILabel")
						local leftStarTimeSec = msg.pvpStartTime - Serclimax.GameTime.GetSecTime()

						if leftStarTimeSec > 0 then
							local countDown = Global.GetLeftCooldownTextLong(msg.pvpStartTime)
							pvpStartTimeLabel.text = countDown
						else
							pvpStartTimeLabel.text = TextMgr:GetText("Union_Radar_ui45")
						end
					end
				end
			end
		end
	end
end

function Show()
	Global.OpenUI(_M)
	UnionRadarData.GetDataWithCallBack(function(radarData)
		unionMonsterMsg = radarData
		LoadUI()
	end)
end


function Close()
	_ui = nil
	ItemUpdateList = nil
	itemtipslist = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	UnionRadarData.RemoveListener(FreshUnionMonsterData)
	if not GUIMgr.Instance:IsMenuOpen("UnionInfo") then
	end
end
