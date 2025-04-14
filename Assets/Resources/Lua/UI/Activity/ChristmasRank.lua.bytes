module("ChristmasRank", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local SetDragCallback = UIUtil.SetDragCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter

local MsgChristmasRankList

local _ui

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("ChristmasRank")
	end
end


function Show()
	--zoneid = zone
	--guildid = guild
	Global.OpenUI(_M)
end

function Start()
	_ui = {}
	local btnQuit = transform:Find("Container_1/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	local bg = transform:Find("Container_1")
	SetPressCallback(bg.gameObject, QuitPressCallback)
	
	_ui.list_ui = {}
	_ui.cur_select_index =-1
	_ui.list_item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.list_hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero_item")

    local RootTrf = transform:Find("Container_1")
	_ui.selfRank = RootTrf:Find("mid01/content 1/myrank/text"):GetComponent("UILabel")
	_ui.selfScore = RootTrf:Find("mid01/content 1/myrank/text1"):GetComponent("UILabel")
	
    for i = 1,2,1 do
        _ui.list_ui[i] = {}
        _ui.list_ui[i].count = 0
        _ui.list_ui[i].msg = nil
        _ui.list_ui[i].list = {}
        _ui.list_ui[i].grid = RootTrf:Find("mid01/content "..i.."/Scroll View/Grid"):GetComponent("UIGrid")
        _ui.list_ui[i].scroll_view = RootTrf:Find("mid01/content "..i.."/Scroll View"):GetComponent("UIScrollView")
		if i==1 then
			_ui.list_ui[i].item = transform:Find("rank").gameObject
			_ui.list_ui[i].item:SetActive(false)
		elseif i==2 then
			_ui.list_ui[i].item = transform:Find("reward_list").gameObject
			_ui.list_ui[i].item:SetActive(false)

		end

        _ui.list_ui[i].root = RootTrf:Find("mid01/content "..i).gameObject
        _ui.list_ui[i].page = RootTrf:Find("mid01/page"..i):GetComponent("UIToggle")
        _ui.list_ui[i].root:SetActive(i==1 and true or false)

		 RootTrf:Find("mid01/page"..i):GetComponent("UIToggledObjects").enabled = false

		_ui.list_ui[i].pageLabel = RootTrf:Find("mid01/page"..i.."/selected effect/text (1)"):GetComponent("UILabel")
		
        UIUtil.SetClickCallback(_ui.list_ui[i].page.gameObject,function()
            OpenList(i,false)
        end)
    end 
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
    --AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	UnionMobaActivityData.AddListener(LoadUI)
	OpenList(1,true)
end

function CloseCurList()
    if _ui.cur_select_index >= 1  and _ui.list_ui[_ui.cur_select_index] ~= nil then
        --_ui:StopListCountDown(_ui.cur_select_index)   
        _ui.list_ui[_ui.cur_select_index].root:SetActive(false)
    end
end


function OpenList(index,reload) 
	if _ui ==nil then 
		return 
	end 
	
	if _ui.cur_select_index ~= index then
        CloseCurList()
        _ui.cur_select_index = index
    end

    _ui.list_ui[_ui.cur_select_index].root:SetActive(true)
	
	if index ==1 then 
		if reload == true then 
			GetRankWithCallBack(function()
				if _ui ==nil then 
					return 
				end 
				--LoadUnionList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
				LoadRankList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
			end)
		else
			LoadRankList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
		end 
	elseif index ==2 then 
		if reload == true then 
			--LoadRewardList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
			GetRewardWithCallBack(function()
				if _ui ==nil then 
					return 
				end 
				LoadRewardList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
			end)
		else
			LoadRewardList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
		end 
	end

end

function GetRankWithCallBack(cb)
	local req = ActivityMsg_pb.MsgChristmasRankListRequest();
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgChristmasRankListRequest,req, ActivityMsg_pb.MsgChristmasRankListResponse, function(msg)
		Global.DumpMessage(msg , "d:/christmasList.lua")
		MsgChristmasRankList = msg
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if cb ~= nil then
                cb()
            end
        end
    end, true)
end 

function GetRewardWithCallBack(cb)
	if cb ~= nil then
		cb()
	end
end 

function ItemSortFunction(v1, v2)
    return v1.itemId > v2.itemId
end

function LoadUI()
	LoadPlayerList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
end

local function AddRankRewardItem(_grid , objitem , data)
	local trf = NGUITools.AddChild( _grid.gameObject,objitem).transform
	trf.gameObject:SetActive(true)
	
	local rank = (data.OrderMin == data.OrderMax) and data.OrderMin  or string.format("%s-%s" , data.OrderMin , data.OrderMax)
	trf:Find("open_mid/title"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("Arena_Help_reward1") , rank)
	local rewardGrid = trf:Find("open_mid/reward/Grid"):GetComponent("UIGrid")
	
	local reward = string.msplit(data.Reward , ';' , ':')
	for k , v in pairs(reward) do
		if tonumber(v[1]) == 1 then
			local rwdT = NGUITools.AddChild( rewardGrid.gameObject,_ui.list_item).transform
			local item = {}
			local itemId = tonumber(v[2])
			local itemData = TableMgr:GetItemData(itemId)
			local itemCount = tonumber(v[3])
			UIUtil.LoadItemObject(item , rwdT)
			UIUtil.LoadItem(item , itemData ,itemCount )
			SetParameter(rwdT.gameObject, "item_" .. itemId)
			
		elseif tonumber(v[1]) == 3 then
			local rwdT = NGUITools.AddChild( rewardGrid.gameObject,_ui.list_hero).transform
			rwdT.localScale = Vector3(0.85,0.85,1)
			local heroId = tonumber(v[2])
			local heroData = TableMgr:GetHeroData(heroId)
			local heroCount = tonumber(v[3])
			local item = {}
			UIUtil.LoadHeroItemObject(item, rwdT)
			UIUtil.LoadHeroItem(item, heroData, heroCount)
			SetParameter(rwdT:Find("item1").gameObject, "hero_" .. heroId)
			
		elseif tonumber(v[1]) == 4 then
			local rwdT = NGUITools.AddChild( rewardGrid.gameObject,_ui.list_item).transform
			local soldierId = tonumber(v[2])
			local soldoerLv = tonumber(v[5])
			local soldierData = TableMgr:GetBarrackData(soldierId, soldoerLv)
			local soliderNum = tonumber(v[3])
			local item = {}
			UIUtil.LoadItemObject(item , rwdT)
			UIUtil.LoadSoldier(item, soldierData, soliderNum)
			
			SetParameter(rwdT.gameObject, "army_" .. soldierId .. "_" ..soldoerLv )
		end

	end
	rewardGrid:Reposition()
end

function LoadRewardList(_grid,objitem)
	while _grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_grid.transform:GetChild(0).gameObject)
	end
	
	local total =0
	local tableData = TableMgr:GetChristmasRankConfigData()
	for i=1 , tableData_tChristmasActivityRank.Count do
		--print(tableData[i].id , tableData[i].OrderMin , tableData[i].OrderMax)
		AddRankRewardItem(_grid,objitem , tableData[i])
	end
	
	_grid:Reposition()
end

function IsCanGetReward(round)
	local data = UnionMobaActivityData.GetData()
    if data~= nil and data.isScoreReward == false and data.status==4 then
		--print("_________1 ",round)
		return true
	else
		--print("_________2 ",round, data.isScoreReward,data.round)
		return false
	end 
end 

local function GetMyRank()
	if MsgChristmasRankList ~= nil then
		for i =1,#MsgChristmasRankList.users,1 do
			local user = MsgChristmasRankList.users[i]
			if user.charId == MainData.GetCharId() then
				return user.rank
			end
		end
	end
	
	return 0
end

local function MakeRankData()
	local rankDetail = {}
	local rankView = {}
	local tableData = TableMgr:GetChristmasRankConfigData()
	
	--初始化排名
	for i=1 , tableData_tChristmasActivityRank.Count do
		for k=tableData[i].OrderMin , tableData[i].OrderMax , 1 do
			local data = {rank = k , charId = 0 , score = tableData[i].PointsRequired , name = TextMgr:GetText("GovernmentWar_10"), range = tableData[i].OrderMax - tableData[i].OrderMin + 1}
			table.insert(rankDetail , data)
		end
		
		if tableData[i].OrderMin ~= tableData[i].OrderMax then
			rankView[tableData[i].id] = {rankStart = tableData[i].OrderMin , rankEnd = tableData[i].OrderMax , rankCurrent = tableData[i].OrderMin}
		end
	end
	
	--插入排名
	for i =1,#MsgChristmasRankList.users,1 do
		local user = MsgChristmasRankList.users[i]
		if user.rank > 0 and user.rank <= #rankDetail then
			rankDetail[user.rank] = user
			
			for k , v in pairs(rankView) do
				if v ~= nil and user.rank >= v.rankStart and user.rank <= v.rankEnd then
					v.rankCurrent = user.rank
				end
			end
		end
	end
	
	--合并排名
	for i=1 , #rankDetail , 1 do
		if rankDetail[i].charId == 0 and rankDetail[i].range ~= nil and rankDetail[i].range > 1 then
			rankDetail[i] = nil
		end
	end
	
	return rankDetail , rankView
end

local function AddRankItem(_grid , objitem , data)
	local trf = NGUITools.AddChild( _grid.gameObject,objitem).transform
	local rankLabrl = trf:Find("no"):GetComponent("UILabel")
	local rankIcon = trf:Find("num_icon"):GetComponent("UISprite")
	
	rankLabrl.gameObject:SetActive(data.rank > 3)
	rankIcon.gameObject:SetActive(data.rank <= 3)
	if(data.rankLabel ~= nil) then
		rankLabrl.text = data.rankLabel
	else
		rankLabrl.text = data.rank
	end
	rankIcon.spriteName = "rank_" .. data.rank
	
	local nationIcon = trf:Find("Texture"):GetComponent("UITexture")
	if(data.nation ~= nil) then
		nationIcon.gameObject:SetActive(true)
	end
	
	local name = ""
	if (data.guildbanner ~= nil and data.guildbanner ~= "") then
		name = string.format("【%s】" , data.guildbanner)
	end
	trf:Find("name"):GetComponent("UILabel").text = name .. data.name
	trf:Find("number"):GetComponent("UILabel").text = data.score
	
	local nationFlag = trf:Find("Texture"):GetComponent("UITexture")
	if(data.nation ~= nil and data.charId ~= nil) then
		nationFlag.gameObject:SetActive(true)
		nationFlag.mainTexture = UIUtil.GetNationalFlagTexture(data.nation)
	else
		nationFlag.gameObject:SetActive(false)
	end
	
	trf:Find("back").gameObject:SetActive(data.charId ~= nil and data.charId > 0 and data.charId == MainData.GetCharId())
	
	local gov = trf:Find("bg_gov")
	if gov ~= nil then
		GOV_Util.SetGovNameUI(gov,0,0,true,data.militaryrankid)
	end
		
	trf.gameObject:SetActive(true)
end

function LoadRankList(_grid,objitem)
	_ui.selfScore.text = System.String.Format(TextMgr:GetText("Christmas_ui7") , Christmas.GetSelfScore())
	_ui.selfRank.text = System.String.Format(TextMgr:GetText("Christmas_ui8") , GetMyRank())
	
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	
	local total =0
	local tableData = TableMgr:GetGuildRewardTable()
	while _grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_grid.transform:GetChild(0).gameObject)
	end
	
	local detail , view = MakeRankData();
	for k  , v in pairs(detail) do
		if v ~= nil then
			AddRankItem(_grid,objitem , v)
			for w  , z in pairs(view) do
				if v.rank == z.rankCurrent and z.rankEnd > z.rankCurrent then
					local cfg = TableMgr:GetChristmasRankConfigDataByID(w)
					AddRankItem(_grid,objitem , {rank=z.rankCurrent+ 1 , rankLabel = string.format("%s-%s" , z.rankCurrent+ 1 , z.rankEnd) , name = TextMgr:GetText("GovernmentWar_10") , score = cfg.PointsRequired})
					z.rankCurrent = z.rankEnd
				end
			end
		end
	end
	
	for k , v in pairs(view) do
		if v ~= nil and v.rankEnd > v.rankCurrent then
			local cfg = TableMgr:GetChristmasRankConfigDataByID(k)
			AddRankItem(_grid,objitem , {rank=v.rankStart , rankLabel=string.format("%s-%s" , v.rankStart , v.rankEnd) , name = TextMgr:GetText("GovernmentWar_10") , score = cfg.PointsRequired})
		end
	end
	
	_grid:Reposition()
end

local showTimer
function OnUICameraPress(go)
	local param = GetParameter(go)
	if param ~= nil then
		local param = param:split("_")
		if param[1] == "item" then
			local itemdata = TableMgr:GetItemData(tonumber(param[2]))
            if itemdata.type==3 and itemdata.subtype==5  then 
                BoxDetails.Show(tableData_tOptionalPack.data[itemdata.param1].RewardItem)
				Tooltip.HideItemTip()
            else
				if not Tooltip.IsItemTipActive() then
					itemTipTarget = go
					Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
				else
					if itemTipTarget == go then
						if Time.time - showTimer > 0.1 then
							Tooltip.HideItemTip()
						end
					else
						itemTipTarget = go
						Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
					end
				end
            end 
		elseif param[1] == "hero" then
			local itemdata = TableMgr:GetHeroData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		    else
		        if itemTipTarget == go then
					if Time.time - showTimer > 0.1 then
						Tooltip.HideItemTip()
					end
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
					if Time.time - showTimer > 0.1 then
						Tooltip.HideItemTip()
					end
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
		        end
		    end
		end
	else
		Tooltip.HideItemTip()
		BoxDetails.Hide()
	end
	showTimer = Time.time
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function Close()
	for i = 1,2,1 do
		if _ui.list_ui[i].desc_root ~= nil then 
			_ui.list_ui[i].desc_root.gameObject:SetActive(false)
		end 
	end 
    _ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	UnionMobaActivityData.RemoveListener(LoadUI)
end
