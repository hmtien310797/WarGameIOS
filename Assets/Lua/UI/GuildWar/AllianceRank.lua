module("AllianceRank", package.seeall)
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

local guildrank 
local userrank 

local matchInfo

local zoneid =0
local guildid =0

local _ui

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("AllianceRank")
	end
end


function Show()
	--zoneid = zone
	--guildid = guild
	Global.OpenUI(_M)
end

function Start()
	_ui = {}
	local btnQuit = transform:Find("Container/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	local bg = transform:Find("Container")
	SetPressCallback(bg.gameObject, QuitPressCallback)
	
	_ui.list_ui = {}
	_ui.cur_select_index =-1
	_ui.list_item = transform:Find("list_player/Grid/Item_CommonNew").gameObject
	
    local RootTrf = transform:Find("Container")

    for i = 1,2,1 do
        _ui.list_ui[i] = {}
        _ui.list_ui[i].count = 0
        _ui.list_ui[i].msg = nil
        _ui.list_ui[i].list = {}
        _ui.list_ui[i].grid = RootTrf:Find("mid01/content "..i.."/Scroll View/Grid"):GetComponent("UIGrid")
        _ui.list_ui[i].scroll_view = RootTrf:Find("mid01/content "..i.."/Scroll View"):GetComponent("UIScrollView")
		if i==1 then
			_ui.list_ui[i].item = transform:Find("list_union").gameObject
			_ui.list_ui[i].item:SetActive(false)
		elseif i==2 then
			_ui.list_ui[i].item = transform:Find("list_player").gameObject
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
	
	AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
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
			LoadUnionList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
			GetDataWithCallBack(function()
				if _ui ==nil then 
					return 
				end 
				LoadUnionList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
			end)
		else
			LoadUnionList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
		end 
	elseif index ==2 then 
		if reload == true then 
			LoadPlayerList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
			GetDataWithCallBack(function()
				if _ui ==nil then 
					return 
				end 
				LoadPlayerList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
			end)
		else
			LoadPlayerList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
		end 
	end

end

function GetDataWithCallBack(cb)
	local req = GuildMobaMsg_pb.GuildMobaRankRequest()
	Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaRankRequest, req, GuildMobaMsg_pb.GuildMobaRankResponse, function(msg)
		print("GetDataWithCallBack end ")
		Global.DumpMessage(msg , "d:/GuildMobaRankResponse.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			userrank = msg.userrank
			guildrank = msg.guildrank
			if cb ~= nil then
				cb()
			end
		end
	end, true)
end 

function ItemSortFunction(v1, v2)
    return v1.itemId > v2.itemId
end

function LoadUI()
	LoadPlayerList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
end

function LoadPlayerList(_grid,objitem)
    
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	
	local total =0
	local tableData = TableMgr:GetGuildMobaRankRewardTable()
	-- table.sort(tableData, ItemSortFunction)
	for i=1,10 do

		local item = tableData[i]
		
		if item == nil then 
			item = tableData[4]
		end 
		
		local obj = nil 
		local childCount = _grid.transform.childCount
		if childCount > tonumber(total)  then
			obj = _grid.transform:GetChild(tonumber(total)).gameObject
		else
			obj = NGUITools.AddChild( _grid.gameObject,objitem)
		end 

		obj:SetActive(true)

		local uiItem = {}
		uiItem.name = obj.transform:Find("name"):GetComponent("UILabel")
		uiItem.text = obj.transform:Find("text"):GetComponent("UILabel")
		uiItem.icon_rank = obj.transform:Find("icon_rank"):GetComponent("UISprite")
		uiItem.grid = obj.transform:Find("Grid"):GetComponent("UIGrid")

		uiItem.mil = obj.transform:Find("Military"):GetComponent("UITexture")
		uiItem.flag = obj.transform:Find("flag"):GetComponent("UITexture")
		uiItem.num = obj.transform:Find("number"):GetComponent("UILabel")
		uiItem.btnGet = obj.transform:Find("btn"):GetComponent("UIButton")
		
		
		local user = GuildMobaData_pb.GuildMobaUser()
		
		if userrank ~= nil and userrank.users ~=nil and i<=#userrank.users  then 
			user = userrank.users[i]
			
			local militaryrankid =user.military
			local nation = user.nationality
			
			uiItem.mil.gameObject:SetActive(militaryrankid > 0)
			local militaryRankData = tableData_tMilitaryRank.data[militaryrankid]
			if militaryRankData then
				uiItem.mil.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)
			end
			uiItem.flag.mainTexture = UIUtil.GetNationalFlagTexture(nation)
			
			uiItem.name.text = user.charName
			uiItem.text.text = System.String.Format(TextMgr:GetText("Armrace_29"), i)
			
			uiItem.num.text = user.totalscore
			
			uiItem.icon_rank.spriteName = "rank_"..i
			ShowRewardItems(uiItem.grid,item.reward,_ui.list_item) -- "1:3482:1;1:3:200000;1:4:200000;1:5:140000"

			SetClickCallback(uiItem.btnGet.gameObject, function(go)
				
				local req = GuildMobaMsg_pb.GuildMobaGetScoreRewardRequest();
				Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetScoreRewardRequest, req, GuildMobaMsg_pb.GuildMobaGetScoreRewardResponse, function(msg)
					if msg.code ~= ReturnCode_pb.Code_OK then
						Global.FloatError(msg.code)
					else
						MainCityUI.UpdateRewardData(msg.fresh)
						Global.ShowReward(msg.reward)
					--	UpdateReward(lv)
						Global.DumpMessage(msg , "d:/activity.lua")
						if cb then
							cb(msg)
						end
						UnionMobaActivityData.RequestData(false)
						
						LoadPlayerList(_ui.list_ui[2].grid,_ui.list_ui[2].item)
					end
				end, true)
				
			end)
			uiItem.flag.gameObject:SetActive(true)
			
			if user.charid == MainData.GetCharId() then 
				uiItem.btnGet.gameObject:SetActive(IsCanGetReward(i))	
			else
				uiItem.btnGet.gameObject:SetActive(false)	
			end 
		else
			uiItem.mil.gameObject:SetActive(false)
			
			uiItem.flag.gameObject:SetActive(false)
			
			uiItem.name.text = TextMgr:GetText("GovernmentWar_10")
			uiItem.text.text = System.String.Format(TextMgr:GetText("Armrace_29"), i)
			
			uiItem.num.text = user.totalscore
			
			uiItem.icon_rank.spriteName = "rank_"..i

			ShowRewardItems(uiItem.grid,item.reward,_ui.list_item) -- "1:3482:1;1:3:200000;1:4:200000;1:5:140000"

			SetClickCallback(uiItem.btnGet.gameObject, function(go)

			end)
			
			uiItem.btnGet.gameObject:SetActive(false)	
		end 
		total = total +1
	end
	
	local count = _grid.transform.childCount

	while (count>total) do
		GameObject.Destroy(_grid.transform:GetChild(count-1).gameObject)
		count = count-1
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

function LoadUnionList(_grid,objitem)
    
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	
	local total =0
	local tableData = TableMgr:GetGuildRewardTable()
	-- table.sort(tableData, ItemSortFunction)

	for i=1,6 do

		local guild = GuildMobaData_pb.GuildMobaGuildInfo()
		local item = tableData[1]
		local items = item.Win 
		local title = ""
		if i == 6 then 
			item = tableData[1]
			items = item.LoseSpecial..";"..item.Lose
			title = System.String.Format(TextMgr:GetText("ui_unionwar_36"), 16)
		elseif  i == 5 then 
			item = tableData[2]
			items = item.LoseSpecial..";"..item.Lose
			
			title = System.String.Format(TextMgr:GetText("ui_unionwar_36"), 8)
			
		elseif  i == 4 then
			item = tableData[4]
			items = item.LoseSpecial..";"..item.Lose
			if guildrank ~= nil and guildrank.guilds ~=nil and  13<=#guildrank.guilds  then 
				guild = guildrank.guilds[13]
			end 
			title = System.String.Format(TextMgr:GetText("Armrace_29"), i)
			
		elseif  i == 3 then
			item = tableData[4]
			items = item.WinSpecial..";"..item.Win

			if guildrank ~= nil and guildrank.guilds ~=nil and  14<=#guildrank.guilds  then 
				guild = guildrank.guilds[14]
			end
			title = System.String.Format(TextMgr:GetText("Armrace_29"), i)
		elseif  i == 2 then
			item = tableData[5]
			items = item.LoseSpecial..";"..item.Lose
			title = System.String.Format(TextMgr:GetText("Armrace_29"), i)
			if guildrank ~= nil and guildrank.guilds ~=nil and  15<=#guildrank.guilds  then 
				guild = guildrank.guilds[15]
			end 
		elseif  i == 1 then
			item = tableData[5]
			items = item.WinSpecial..";"..item.Win
			title = System.String.Format(TextMgr:GetText("Armrace_29"), i)
			if guildrank ~= nil and guildrank.guilds ~=nil and  16<=#guildrank.guilds  then 
				guild = guildrank.guilds[16]
			end 
		end 

		local obj = nil 
		local childCount = _grid.transform.childCount
		if childCount > tonumber(total)  then
			obj = _grid.transform:GetChild(tonumber(total)).gameObject
		else
			obj = NGUITools.AddChild( _grid.gameObject,objitem)
		end 

		obj:SetActive(true)
		
		local uiItem = {}
		uiItem.union_name = obj.transform:Find("union_name"):GetComponent("UILabel")
		uiItem.text = obj.transform:Find("text"):GetComponent("UILabel")
		uiItem.icon_rank = obj.transform:Find("icon_rank"):GetComponent("UISprite")
		uiItem.grid = obj.transform:Find("Grid"):GetComponent("UIGrid")
	
		total = total +1
		if tonumber(guild.guildid) > 0 then 
			ShowRewardItems(uiItem.grid,items,_ui.list_item)
			
			uiItem.union_name.text = guild.guildname
			uiItem.text.text = title
			
			uiItem.icon_rank.spriteName = "rank_"..i
		else
			ShowRewardItems(uiItem.grid,items,_ui.list_item)
			
			uiItem.union_name.text = TextMgr:GetText("GovernmentWar_10")
			uiItem.text.text = title
			
			uiItem.icon_rank.spriteName = "rank_"..i
		
		end 

		
	end
	
	local count = _grid.transform.childCount

	while (count>total) do
		GameObject.Destroy(_grid.transform:GetChild(count-1).gameObject)
		count = count-1
	end

	_grid:Reposition()
	
end

function ShowRewardItems(_grid,items,objitem)
	local item = _ui.list_item
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end

	
	local total =0

	-- table.sort(tableData, ItemSortFunction)
	for vv in string.gsplit(items, ";") do
		
		local itemTable = string.split(vv, ":")
		if #itemTable > 2 then
			local itemId, itemCount = tonumber(itemTable[2]), tonumber(itemTable[3])
			local itemdata = TableMgr:GetItemData(itemId)
			
			if itemdata ~=nil then 
				local obj = nil 
				local childCount = _grid.transform.childCount
				if childCount > tonumber(total)  then
					obj = _grid.transform:GetChild(tonumber(total)).gameObject
				else
					obj =  NGUITools.AddChild( _grid.gameObject,objitem)
				end 

				obj:SetActive(true)
				
				-- print("________",itemId)
				
				local reward = {}
				UIUtil.LoadItemObject(reward, obj.transform)
				UIUtil.LoadItem(reward, itemdata, itemCount)
				UIUtil.SetParameter(obj, "item_" .. itemId)
				UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
					if go == _ui.tipObject then
						_ui.tipObject = nil
					else
						_ui.tipObject = go
						Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
					end
				end)

				total = total +1
			end
		end 

	end
	
	local count = _grid.transform.childCount

	while (count>total) do
		GameObject.Destroy(_grid.transform:GetChild(count-1).gameObject)
		count = count-1
	end

	_grid:Reposition()
end 


function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if _ui~=nil and go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
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
	UnionMobaActivityData.RemoveListener(LoadUI)
end
