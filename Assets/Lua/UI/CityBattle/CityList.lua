module("CityList", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local SetDragCallback = UIUtil.SetDragCallback

local matchInfo

local zoneid =0
local guildid =0

local _ui

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("CityList")
	end
end


function Show()
	--zoneid = zone
	--guildid = guild
	Global.OpenUI(_M)
end

function Start()
	_ui = {}
	local btnQuit = transform:Find("Container/background/close btn")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	local bg = transform:Find("Container")
	SetPressCallback(bg.gameObject, QuitPressCallback)
	_ui.grid = transform:Find("Container/background/mid/bg/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.scroll_view = transform:Find("Container/background/mid/bg/Scroll View"):GetComponent("UIScrollView")
	_ui.item = transform:Find("Container/background/list").gameObject
	_ui.item:SetActive(false)

	_ui.btnAll = transform:Find("Container/background/bottom/button"):GetComponent("UIButton")
	LoadCityList(_ui.grid,_ui.item)
	
	SetClickCallback(_ui.btnAll.gameObject, function(go)
		ReqReward(true,0)
	end)
	WorldCityData.AddListener(UpdateData)
end

function ItemSortFunction(v1, v2)
    return v1.FrontCity < v2.FrontCity
end

function UpdateData()
	print("updatedata")
	LoadCityList(_ui.grid,_ui.item)
end 

function LoadCityList(_grid,objitem)
    
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	
	local tableData = {}
	for _, cityData in pairs(tableData_tWorldCity.data) do
		table.insert(tableData,cityData)
	end 
	
	table.sort(tableData,ItemSortFunction)
	
	local total =0
	
	local get_count =0
	
	_ui.refresh_items = {}
	for j, cityData in pairs(tableData) do
		local obj = nil 
		local childCount = _grid.transform.childCount
		if childCount > tonumber(total)  then
			obj = _grid.transform:GetChild(tonumber(total)).gameObject
		else
			obj = NGUITools.AddChild( _grid.gameObject,objitem)
		end 

		obj:SetActive(true)
		
		local uiItem = {}

		uiItem.name = obj.transform:Find("icon_city/name"):GetComponent("UILabel")
		uiItem.city = obj.transform:Find("icon_city"):GetComponent("UITexture")
		
		uiItem.attr = obj.transform:Find("text_Attributes"):GetComponent("UILabel")
		uiItem.pres = obj.transform:Find("text_prestige"):GetComponent("UILabel")
		
		uiItem.slider = obj.transform:Find("exp bar"):GetComponent("UISlider")
		uiItem.exp_num = obj.transform:Find("exp bar/num"):GetComponent("UILabel")
		uiItem.slider_fg =  obj.transform:Find("exp bar/foreground"):GetComponent("UISprite")
		
		uiItem.btnGet = obj.transform:Find("btn_ receive"):GetComponent("UIButton")
		uiItem.btnGo = obj.transform:Find("btn_ go"):GetComponent("UIButton")

		uiItem.unopened = obj.transform:Find("text_Unopened"):GetComponent("UILabel")
		
		uiItem.name.text = TextMgr:GetText(cityData.Name)
		uiItem.city.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", cityData.Icon)
		
		local info = WorldCityData.GetCityInfo(cityData.id)
		
		local effect = ''
		local active = WorldCityData.IsUnlock(cityData.id)
		
		if info.occupyBuff~= nil and info.occupyBuff ~= "" then 
			local bufData = tableData_tSlgBuff.data[tonumber(cityData.SeizeBuff)] --info.occupyBuff)
			effect = TextUtil.GetSlgBuffDescription(bufData)
		end 

		if effect == nil or effect =="" then 
			effect = ""--TextMgr:GetText("ui_citybattle_19")
		end 
		
		if active.unlock and info.occupied then 
			uiItem.attr.text = System.String.Format(TextMgr:GetText("ui_citybattle_11"),effect)
		else
			uiItem.attr.text = System.String.Format(TextMgr:GetText("ui_citybattle_12"),effect)
		end 
		
		
		if effect == nil or effect =="" then 
			uiItem.attr.text =TextMgr:GetText("ui_citybattle_19")
		end 

		uiItem.pres.text =  System.String.Format(TextMgr:GetText("ui_citybattle_13"),cityData.HonorYield)

		local tip = ""--info.reputationNum.."/"..cityData.Capacity;
		local serverTime = GameTime.GetSecTime()
		local todaySecond = (serverTime % (3600 * 24))
		local leftSecond =  3600*24 - todaySecond

		tip = Global.SecondToTimeLong(leftSecond)

		uiItem.slider.value = todaySecond/(3600*24) --info.reputationNum / cityData.Capacity
		uiItem.exp_num.text  = System.String.Format(TextMgr:GetText("ui_citybattle_14"),tip)
		
		local occupied = false
		if j > 1 then
			local info1 = WorldCityData.GetCityInfo(cityData.FrontCity)
			occupied = info1.occupied 
		end 

		if info.occupied == true then 
			uiItem.slider.gameObject:SetActive(true)
			if info.reputationNum > 0 then 
				get_count = get_count + 1
				uiItem.btnGet.gameObject:SetActive(true)
				uiItem.unopened.text = ""
				uiItem.slider_fg.spriteName = "union_proceed2"
				uiItem.slider_fg.color =  NGUIMath.HexToColor(0xFFFFFFFF)
				uiItem.slider.value = 1
				uiItem.exp_num.text  = TextMgr:GetText("ui_citybattle_27")
			else
				uiItem.btnGet.gameObject:SetActive(false)
				uiItem.unopened.text = TextMgr:GetText("ui_citybattle_15")
				uiItem.slider_fg.spriteName = "union_button3_un"
				--uiItem.slider_fg.color =  NGUIMath.HexToColor(0xE4D5D5FF)
				table.insert(_ui.refresh_items,uiItem)
			end
			uiItem.btnGo.gameObject:SetActive(false)
		else
			uiItem.slider_fg.color =  NGUIMath.HexToColor(0xFFFFFFFF)
			uiItem.slider_fg.spriteName = "union_proceed2"
			uiItem.btnGet.gameObject:SetActive(false)
			if active.unlock or occupied then 
				uiItem.slider.gameObject:SetActive(false)
				uiItem.btnGo.gameObject:SetActive(true)
				uiItem.unopened.text = TextMgr:GetText("ui_citybattle_16")
				if occupied then 
					-- uiItem.attr.text = effect
				end 
			else
				uiItem.slider.gameObject:SetActive(false)
				uiItem.btnGo.gameObject:SetActive(false)
				local item = tableData_tWorldCity.data[cityData.FrontCity]
				if item ~= nil then 
					uiItem.unopened.text = System.String.Format(TextMgr:GetText("ui_citybattle_5"),TextMgr:GetText(item.Name))
				else
					uiItem.unopened.text = ""
				end 
				uiItem.attr.text = System.String.Format(TextMgr:GetText("ui_citybattle_21"),"????") 
				uiItem.pres.text = System.String.Format(TextMgr:GetText("ui_citybattle_22"),"??")
			end 
		end 
		--table.insert(_ui.refresh_items,uiItem)
		SetClickCallback(uiItem.btnGet.gameObject, function(go)
			ReqReward(false,cityData.id)
		end)
		
		SetClickCallback(uiItem.btnGo.gameObject, function(go)
			GUIMgr:CloseMenu("CityList")
			GUIMgr:CloseMenu("CityMap")
            MainCityUI.ShowWorldMap(info.pos.x, info.pos.y, true)
		end)

		total = total +1
		
	end
	
	_ui.btnAll:GetComponent("BoxCollider").enabled =get_count > 0
	_ui.btnAll.enabled = get_count > 0
	
	if get_count > 0 then 
		_ui.btnAll:GetComponent("UISprite").spriteName =  "btn_2"
	
	else
		_ui.btnAll:GetComponent("UISprite").spriteName =  "btn_4"
	end 
	
	local count = _grid.transform.childCount

	while (count>total) do
		GameObject.Destroy(_grid.transform:GetChild(count-1).gameObject)
		count = count-1
	end

	_grid:Reposition()
	coroutine.stop(_ui.countdowncoroutine)
	_ui.countdowncoroutine = coroutine.start(function()
			while true do
				if _ui == nil then 
					break 
				end
				for i=1, #_ui.refresh_items do
					local uiItem = _ui.refresh_items[i]

					if uiItem.btnGet.gameObject.activeSelf == false then 
						local serverTime = GameTime.GetSecTime()
						local todaySecond = (serverTime % (3600 * 24))
						local leftSecond =  3600*24 - todaySecond

						tip = Global.SecondToTimeLong(leftSecond)
						uiItem.exp_num.text  = System.String.Format(TextMgr:GetText("ui_citybattle_14"),tip)
						-- print(todaySecond,3600*24,todaySecond/(3600*24))
						uiItem.slider.value = todaySecond/(3600*24)
						if leftSecond < 2 then 
		
							uiItem.btnGet.gameObject:SetActive(true)
							
							uiItem.unopened.text = ""
							uiItem.slider_fg.spriteName = "union_proceed2"
							uiItem.slider_fg.color =  NGUIMath.HexToColor(0xFFFFFFFF)
							uiItem.slider.value = 1
							uiItem.exp_num.text  = TextMgr:GetText("ui_citybattle_27")
							
							_ui.btnAll.enabled = true
							_ui.btnAll:GetComponent("UISprite").spriteName =  "btn_2"
						end
					else
						uiItem.unopened.text = ""
						uiItem.slider_fg.spriteName = "union_proceed2"
						uiItem.slider_fg.color =  NGUIMath.HexToColor(0xFFFFFFFF)
						uiItem.slider.value = 1
						uiItem.exp_num.text  = TextMgr:GetText("ui_citybattle_27")
						
						_ui.btnAll.enabled = true
						_ui.btnAll:GetComponent("UISprite").spriteName =  "btn_2"

					end 
				end
				
				coroutine.wait(1)
			end
		end)	
	
end

function ReqReward(all,id)
	local req = MapMsg_pb.MsgWorldCityCollectReputationRequest()
	req.all = all
	req.cityId = id
	Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgWorldCityCollectReputationRequest, req, MapMsg_pb.MsgWorldCityCollectReputationResponse, function(msg)
		Global.DumpMessage(msg, "D:/MsgWorldCityCollectReputationResponse.lua")
		if msg.code == ReturnCode_pb.Code_OK then
			MainCityUI.UpdateRewardData(msg.fresh)
			Global.ShowReward(msg.reward)
			WorldCityData.RequestData(nil,false)
		else
			Global.ShowError(msg.code)
		end
	end, true)

end 

function Close()
	coroutine.stop(_ui.countdowncoroutine)
	WorldCityData.RemoveListener(UpdateData)
    _ui = nil
end
