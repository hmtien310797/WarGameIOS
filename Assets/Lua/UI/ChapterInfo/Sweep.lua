module("Sweep", package.seeall)
local GUIMgr = Global.GGUIMgr.Instance
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local ResourceLibrary = Global.GResourceLibrary
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local scrollview
local grid
local listprefab
local okprefab
local itemprefab
local heroprefab
local _reward
local _sweep
local _sweepheros
local _changedexp
local _sweep10
local _maindata
local _fresh

local scrollheight
local listheight
local changetime = 0.5
local lefttime
local changespeed
local leftlength
local index
local count
local makeitem
local box
local bottom
local itemObj
local autoGatherParam

local itemlist
local herolist

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	for i, v in ipairs(itemlist) do
		if go == v then
			local itemData = TableMgr:GetItemData(tonumber(go.name))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
		        end
		    end
		    return
		end
	end
	go = go.transform.parent.gameObject
	for i, v in ipairs(herolist) do
		if go == v then
			local itemData = TableMgr:GetHeroData(tonumber(go.name))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemData.nameLabel), text = TextMgr:GetText(itemData.description)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(itemData.nameLabel), text = TextMgr:GetText(itemData.description)})
		        end
		    end
		    return
		end
	end
	Tooltip.HideItemTip()
end

function Awake()
	--SetClickCallback(transform:Find("Container").gameObject, function() Global.CloseUI(_M) end)
	SetClickCallback(transform:Find("Container/bg_frane/bg_bottom/btn_ok").gameObject, function() Global.CloseUI(_M) ChapterInfoUI.SetActive(true) end)
	box = transform:Find("Container/bg_frane/boxpanel/box").gameObject
	SetClickCallback(box, function()
		changetime = 0.15
		changespeed = listheight / changetime
	end)
	bottom = transform:Find("Container/bg_frane/bg_bottom").gameObject
	scrollview = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	itemObj = transform:Find("Container/bg_frane/bg_mid/bg_itemmsg").gameObject
	
	listprefab = transform:Find("bg_list").gameObject
	okprefab = transform:Find("bg_list_ok").gameObject
	itemprefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    heroprefab = ResourceLibrary.GetUIPrefab("Hero/listitem_herocard")
	scrollheight = scrollview:GetComponent("UIPanel"):GetViewSize().y
	listheight = grid.cellHeight
end

function Start()
	changetime = 0.5
	_sweepheros = {}
	for i, v in ipairs(_sweep.item.item) do
		table.insert(_sweepheros, v)
	end
	index = 1
	count = #_reward
	lefttime = 0
	leftlength = 0
	changespeed = listheight / changetime
	makeitem = true
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	itemlist = {}
	herolist = {}
	local again = transform:Find("Container/bg_frane/bg_bottom/btn_again").gameObject
	again.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(_sweep10 and "sweep_ui4" or "sweep_ui3")
	SetClickCallback(again, function()
		Global.CloseUI(_M)
		ChapterInfoUI.GetSweepRequest(_sweep10, false)
	end)
	if _maindata ~= nil then
		MainData.CheckPkValue(_maindata)
		_maindata = nil
	end
	if _fresh ~= nil then
		MainCityUI.UpdateRewardData(_fresh)
		_fresh = nil
	end
end

function MakeItem(index)
	if index <= count then
		local totallength = listheight * (index + 1) - 30
		if totallength > scrollheight then
			leftlength = totallength - scrollheight - scrollview.transform.localPosition.y
		end
		local listitem = NGUITools.AddChild(grid.gameObject, listprefab)
		local namelabel = listitem.transform:Find("bg_text/name"):GetComponent("UILabel")
		local explabel = listitem.transform:Find("bg_exp/num"):GetComponent("UILabel")
		local _grid = listitem.transform:Find("Scroll View/Grid"):GetComponent("UIGrid")
		namelabel.text = System.String.Format(TextMgr:GetText("sweep_ui1") ,index)
		explabel.text = "+" .. _changedexp
		for i, v in ipairs(_reward[index].item.item) do
			local itemTransform = NGUITools.AddChild(_grid.gameObject, itemprefab).transform
			itemTransform.name = v.baseid
			itemTransform.transform.localScale = Vector3(0.8, 0.8, 1)
			table.insert(itemlist, item)
			local itemData = TableMgr:GetItemData(v.baseid)
	        local item = {}
	        UIUtil.LoadItemObject(item, itemTransform)
	        UIUtil.LoadItem(item, itemData, v.num)
			ChapterInfoUI.SetSweepItem(itemObj , index , v.baseid , v.num)
		end
		for i, v in ipairs(_reward[index].hero.hero) do
			local heroTransform = NGUITools.AddChild(_grid.gameObject, heroprefab)
			heroTransform.name = v.baseid
			heroTransform.transform.localScale = Vector3(0.75, 0.75, 1)
			table.insert(herolist, item)
			local heroData = TableMgr:GetHeroData(v.baseid)
	    	local hero = {}
	    	HeroList.LoadHeroObject(hero, heroTransform)
	    	HeroList.LoadHero(hero, v, heroData)
		end
		_grid:Reposition()
		grid:Reposition()
	elseif index == count + 1 then
		local totallength = listheight * (index + 1)
		local listitem = NGUITools.AddChild(grid.gameObject, listprefab)
		local namelabel = listitem.transform:Find("bg_text/name"):GetComponent("UILabel")
		local explabel = listitem.transform:Find("bg_exp")
		local _grid = listitem.transform:Find("Scroll View/Grid"):GetComponent("UIGrid")
		namelabel.text = TextMgr:GetText("sweep_ui2")
		explabel.gameObject:SetActive(false)
		for i, v in ipairs(_sweepheros) do
			local itemTransform = NGUITools.AddChild(_grid.gameObject, itemprefab).transform
			itemTransform.name = v.baseid
			itemTransform.transform.localScale = Vector3(0.8, 0.8, 1)
			table.insert(itemlist, item)
			local itemData = TableMgr:GetItemData(v.baseid)
	        local item = {}
	        UIUtil.LoadItemObject(item, itemTransform)
	        UIUtil.LoadItem(item, itemData, v.num)
			ChapterInfoUI.SetSweepItem(itemObj , index , v.baseid , v.num)
		end
		_grid:Reposition()
		grid:Reposition()
		box:SetActive(false)
		bottom:SetActive(true)
		SetClickCallback(transform:Find("Container").gameObject, function() Global.CloseUI(_M) ChapterInfoUI.SetActive(true) end)
	else
		local totallength = listheight * index
		local listitem = NGUITools.AddChild(grid.gameObject, okprefab)
		SetClickCallback(listitem.transform:Find("btn_ok").gameObject, function() Global.CloseUI(_M) end)
		if totallength > scrollheight then
			grid:Reposition()
		else
			listitem.transform.localPosition = Vector3(0, listheight - scrollheight + 20, 0)
			scrollview:ResetPosition()
		end
	end
end

function LateUpdate()
	if index <= count + 1 then -- ԭ��+2
		if lefttime > 0 then
			lefttime = lefttime - Time.deltaTime
		else
			MakeItem(index)
			index = index + 1
			lefttime = changetime
		end
	end
	if leftlength > 0 then
		local movey = changespeed * Time.deltaTime
		scrollview:MoveRelative(Vector3(0, movey, 0))
		leftlength = leftlength - movey
	end
end

function Show(reward, sweep, changedexp, sweep10, fresh)
	_reward = reward
	_sweep = sweep
	_sweep10 = sweep10
	_changedexp = math.floor(changedexp / #_reward)
	_fresh = fresh
	Global.OpenUI(_M)
end

function Close()
	Tooltip.HideItemTip()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	box = nil
	scrollview = nil
	grid = nil
	listprefab = nil
	okprefab = nil
	itemprefab = nil
	heroprefab = nil
	bottom = nil
	--ChapterInfoUI.Show()
end

function SetMainData(msg)
	_maindata = msg
end
