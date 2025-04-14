module("Marchlist", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
OnCloseCB = nil

local container
local btn_close
local scroll_view
local scroll_table
local noitem
local _building

local iteminfo_prefab
local base_height = 131
local oldData
local march_type = {"ui_worldmap_30","ui_worldmap_4","ui_worldmap_28","ui_worldmap_63","ui_worldmap_29" , "Union_Support_ui7"}

local function CloseSelf()
	local childCount = scroll_table.transform.childCount
	for i = 0, childCount - 1 do
		CountDown.Instance:Remove("RadarMove_" .. i)
	end
	RadarData.RemoveListener(RefreshRadar)
	Global.CloseUI(_M)
end

local function RefreshList(_data)
	local _type
    local typeicon = ""
    local pathInfo = _data.se
    if pathInfo.pathType == nil then
    	return
    end
    if pathInfo.pathType == 1 or pathInfo.pathType == 5 or pathInfo.pathType == 8 or pathInfo.pathType == 11 or pathInfo.pathType == 12 or pathInfo.pathType == 15 then
    	_type = 1
    	typeicon = "icon_plane_attack"
    elseif pathInfo.pathType == 4 then
    	_type = 2
    	typeicon = "icon_plane_garrison"
	elseif pathInfo.pathType == 6 then
		_type = 3
		typeicon = "icon_plane_mass"
	elseif pathInfo.pathType == 13 then
		_type = 4
		typeicon = "icon_plane_trade"
	elseif pathInfo.pathType == 9 then
		_type = 5
		typeicon = "icon_plane_recon"
	elseif pathInfo.pathType == 22 then
		_type = 6
    	typeicon = "icon_plane_support"
	else 
		return
	end
	if pathInfo.pathType == 15 and tonumber(pathInfo.charname) ~= nil then
		pathInfo.charname = TextMgr:GetText("SiegeMonster_" .. pathInfo.charname)
	end
    local info = {}
    info.go = GameObject.Instantiate(iteminfo_prefab)
    info.go.transform:SetParent(scroll_table.transform, false)
    
    local paraController = info.go:GetComponent("ParadeTableItemController")
    info.bg_list = info.go.transform:Find("bg_list"):GetComponent("TweenHeight")
    info.btn_open = info.go.transform:Find("bg_list/btn_open"):GetComponent("UIPlayTween")
    info.bg_icon = info.go.transform:Find("bg_list/bg_icon/Sprite"):GetComponent("UITexture")
    info.bg_icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/" ,typeicon )--typeicon
    info.text_name = info.go.transform:Find("bg_list/bg_icon/bg_text/text_type/text_name"):GetComponent("UILabel")
    info.text_name.text = TextMgr:GetText(march_type[_type])
    info.target_text = info.go.transform:Find("bg_list/foodstuff/coordinate"):GetComponent("UILabel")
    info.target_text.text = System.String.Format("#:{0}  X:{1}  Y:{2}", 1, pathInfo.targetPos.x, pathInfo.targetPos.y)
    SetClickCallback(info.target_text.gameObject, function()
    	CloseSelf()
    	MainCityUI.ShowWorldMap(pathInfo.targetPos.x, pathInfo.targetPos.y)
    end)
	
	if _type == 6 then
		info.btn_open.gameObject:SetActive(false)
	end
	
    info.from_name_text = info.go.transform:Find("bg_list/from/Label"):GetComponent("UILabel")
    info.from_name_text.text = pathInfo.charname
    info.time_slider = info.go.transform:Find("bg_list/bg_exp/bg/bar"):GetComponent("UISlider")
    info.time_text = info.go.transform:Find("bg_list/bg_exp/bg/text"):GetComponent("UILabel")
    local commander_label = info.go.transform:Find("bg_list/commander/coordinate"):GetComponent("UILabel")
    commander_label.text = System.String.Format("#:{0}  X:{1}  Y:{2}", 1, pathInfo.sourcePos.x, pathInfo.sourcePos.y)
    SetClickCallback(commander_label.gameObject, function()
    	CloseSelf()
    	MainCityUI.ShowWorldMap(pathInfo.sourcePos.x, pathInfo.sourcePos.y)
    end)
    commander_label = info.go.transform:Find("bg_list/commander_01/coordinate"):GetComponent("UILabel")
    commander_label.text = System.String.Format("#:{0}  X:{1}  Y:{2}", 1, pathInfo.sourcePos.x, pathInfo.sourcePos.y)
    SetClickCallback(commander_label.gameObject, function()
    	CloseSelf()
    	MainCityUI.ShowWorldMap(pathInfo.sourcePos.x, pathInfo.sourcePos.y)
    end)
    if _type == 2 or _type == 3 or _type == 4 or _type == 5 then
    	_data.radarrecon.waringRecon = false
    end
    if _data.radarrecon.waringRecon then
    	info.go.transform:Find("bg_list/commander").gameObject:SetActive(false)
    	local commandersprite = info.go.transform:Find("bg_list/commander_01"):GetComponent("UISprite")
    	commandersprite.gameObject:SetActive(true)
    	commandersprite.spriteName = "commander_unknow"
    elseif _data.army.userwaring then
    	if _data.radarrecon.waringface ~= nil then
    		info.go.transform:Find("bg_list/commander/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/head/", _data.radarrecon.waringface)
    	end
    else
    	info.go.transform:Find("bg_list/commander").gameObject:SetActive(false)
    	local commandersprite = info.go.transform:Find("bg_list/commander_01"):GetComponent("UISprite")
    	commandersprite.gameObject:SetActive(true)
    	commandersprite.spriteName = "commander_none"
    end
    info.timeslider = info.go.transform:Find("bg_list/bg_exp/bg/bar"):GetComponent("UISlider")
    info.timetext = info.go.transform:Find("bg_list/bg_exp/bg/text"):GetComponent("UILabel")
    if _data.radarrecon.timeRecon then
    	info.time_text.text = "?? : ?? : ??"
    	info.time_slider.value = 1
    else
    	local _time = pathInfo.starttime + pathInfo.time
    	local _totalTime = pathInfo.time
    	CountDown.Instance:Add("RadarMove_" .. _data.se.pathId,_time,CountDown.CountDownCallBack(function(t)
	        leftTime = _time - Serclimax.GameTime.GetSecTime()
	        if leftTime > 0 then
		        local totalTime = tonumber(_totalTime)
		        if info.time_text == nil or info.time_text:Equals(nil) or info.time_slider == nil or info.time_slider:Equals(nil) then
		        	return
		        end
		        info.time_text.text = t
		        info.time_slider.value = 1 - (leftTime / totalTime)
		    end
		end))
    end
    if _type == 1 or _type == 2 or _type == 3 then
    	local tweenTarget = info.go.transform:Find("Item_open01").gameObject
    	info.btn_open.tweenTarget = tweenTarget
    	info.bg_list.to = 427--base_height + tweenTarget:GetComponent("UIWidget").height
    	info.hero_scroll = tweenTarget.transform:Find("bg_hero/frame/Scroll View"):GetComponent("UIScrollView")
    	info.hero_grid = info.hero_scroll.transform:Find("Grid"):GetComponent("UIGrid")
    	local count = 0
    	for j, v in ipairs(_data.army.hero.heros) do
    		count = j
    		local _hero
    		local _herodata = TableMgr:GetHeroData(v.baseid)
    		_hero = ResourceLibrary.GetUIInstance("WorldMap/listitem_herocard_small0.6")
    		_hero.transform:SetParent(info.hero_grid.transform, false)
    		_hero.transform:Find("icon_wenhao").gameObject:SetActive(false)
    		_hero.transform:Find("head icon").gameObject:SetActive(true)
    		_hero.transform:Find("icon_plus").gameObject:SetActive(false)
    		_hero.transform:Find("level text").gameObject:SetActive(not _data.radarrecon.herodetail)
    		_hero.transform:Find("star").gameObject:SetActive(not _data.radarrecon.herodetail)
    		_hero.transform:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", _herodata.icon)
	    	_hero.transform:Find("head icon/outline1"):GetComponent("UISprite").spriteName = "head" .. _herodata.quality
	    	_hero.transform:Find("level text"):GetComponent("UILabel").text = v.level == nil and "0" or v.level
	    	local star = _hero.transform:Find("star")
	    	local star_count = star.transform.childCount
	    	v.star = v.star == nil and 0 or v.star
	    	for n = 1, star_count do
	    		if n == v.star then
	    			star.transform:GetChild(n - 1).gameObject:SetActive(true)
	    		else
	    			star.transform:GetChild(n - 1).gameObject:SetActive(false)
	    		end
	    	end
	    	_hero.transform:Find("select").gameObject:SetActive(false)
    	end
    	if _data.radarrecon.heroRecon then
    		for j = count + 1, 5 do
    			local _hero
	    		_hero = ResourceLibrary.GetUIInstance("WorldMap/listitem_herocard_small0.6")
	    		_hero.transform:SetParent(info.hero_grid.transform, false)
	    		_hero.transform:Find("icon_wenhao").gameObject:SetActive(true)
    			_hero.transform:Find("head icon").gameObject:SetActive(false)
    			_hero.transform:Find("level text").gameObject:SetActive(false)
    			_hero.transform:Find("icon_plus").gameObject:SetActive(false)
    			_hero.transform:Find("star").gameObject:SetActive(false)
    			_hero.transform:Find("select").gameObject:SetActive(false)
    		end
    	end
    	if info.hero_grid.transform.childCount == 0 then
    		tweenTarget.transform:Find("bg_hero/frame/bg_noitem").gameObject:SetActive(true)
    	else
    		tweenTarget.transform:Find("bg_hero/frame/bg_noitem").gameObject:SetActive(false)
    	end
    	info.hero_grid:Reposition()
    	info.hero_scroll:ResetPosition()
    	info.soldier_scroll = tweenTarget.transform:Find("bg_soldier/frame/Sprite/Scroll View"):GetComponent("UIScrollView")
    	info.soldier_grid = info.soldier_scroll.transform:Find("Grid"):GetComponent("UIGrid")
    	info.soldier_total = tweenTarget.transform:Find("bg_soldier/frame/text/total/number"):GetComponent("UILabel")
    	if _data.radarrecon.armyRecon then
    		for j = 1, 8 do
    			local _soldier
    			_soldier = GameObject.Instantiate(tweenTarget.transform:Find("soilder_list").gameObject)
	    		_soldier.gameObject:SetActive(true)
	    		_soldier.transform:SetParent(info.soldier_grid.transform, false)
    			for k = 1, 4 do
	    			_soldier.transform:Find(System.String.Format("Grid/show_{0}", k)).gameObject:SetActive(true)
	    			_soldier.transform:Find(System.String.Format("Grid/show_{0}/Sprite{0}", k)).gameObject:SetActive(false)
	    			_soldier.transform:Find(System.String.Format("Grid/show_{0}/wenhao", k)).gameObject:SetActive(true)
	    		end    
	    		_soldier.transform:Find("Label_01"):GetComponent("UILabel").text = "?"
	    		if j % 2 ~= 0 then
	    			_soldier.transform:Find("Sprite").gameObject:SetActive(false)
	    		else
	    			_soldier.transform:Find("Sprite").gameObject:SetActive(true)
	    		end
	    		_soldier.transform:Find("Grid"):GetComponent("UIGrid"):Reposition()
    		end
    	else
	    	local armyList = {}
	    	for j, v in ipairs(_data.army.army.army) do
	    		if armyList[v.armyId] == nil then
	    			armyList[v.armyId] = {}
	    		end
	    		armyList[v.armyId][v.armyLevel] = v.num
	    	end
	    	local index = 0
	    	for j, v in pairs(armyList) do
	    		index = index + 1
	    		local _soldier
	    		_soldier = GameObject.Instantiate(tweenTarget.transform:Find("soilder_list").gameObject)
	    		_soldier.gameObject:SetActive(true)
	    		_soldier.transform:SetParent(info.soldier_grid.transform, false)
	    		for k = 1, 4 do
	    			if _data.radarrecon.armynum == 0 then
	    				_soldier.transform:Find(System.String.Format("Grid/show_{0}", k)).gameObject:SetActive(true)
		    			_soldier.transform:Find(System.String.Format("Grid/show_{0}/Sprite{0}", k)).gameObject:SetActive(false)
		    			_soldier.transform:Find(System.String.Format("Grid/show_{0}/wenhao", k)).gameObject:SetActive(true)
	    			else
			    		if v[k] ~= nil then
			    			local n
			    			if _data.radarrecon.armynum == 1 then
			    				n = "~" .. Global.ExchangeValue(v[k])
			    			elseif _data.radarrecon.armynum == 2 then
			    				n = Global.ExchangeValue(v[k])
			    			end
			    			_soldier.transform:Find(System.String.Format("Grid/show_{0}/Sprite{0}/number", k)):GetComponent("UILabel").text = n
			    			_soldier.transform:Find(System.String.Format("Grid/show_{0}", k)).gameObject:SetActive(true)
			    			_soldier.transform:Find(System.String.Format("Grid/show_{0}/Sprite{0}", k)).gameObject:SetActive(true)
			    			_soldier.transform:Find(System.String.Format("Grid/show_{0}/wenhao", k)).gameObject:SetActive(false)
			    		else
			    			_soldier.transform:Find(System.String.Format("Grid/show_{0}", k)).gameObject:SetActive(false)
			    		end
			    	end
		    	end
	    		_soldier.transform:Find("Label_01"):GetComponent("UILabel").text = TextMgr:GetText(Barrack.GetAramInfo(j,1).TabName)
	    		if index % 2 ~= 0 then
	    			_soldier.transform:Find("Sprite").gameObject:SetActive(false)
	    		else
	    			_soldier.transform:Find("Sprite").gameObject:SetActive(true)
	    		end
	    		_soldier.transform:Find("Grid"):GetComponent("UIGrid"):Reposition()
	    	end
	    end
	    local totalsoldier = ""
	    if _data.radarrecon.armytotolnum:find("?") ~= nil then
	    	totalsoldier = "?"
	    else
	    	if _data.radarrecon.armytotolnum:find("~") ~= nil then
	    		totalsoldier = "~" .. Global.ExchangeValue(tonumber(string.sub(_data.radarrecon.armytotolnum,2)))
		    else
		    	totalsoldier = Global.ExchangeValue(tonumber(_data.radarrecon.armytotolnum))
		    end
	    end
	    if _building.data.level == _building.buildingData.levelMax then
	    	tweenTarget.transform:Find("bg_soldier/frame/special"):GetComponent("UILabel").text = TextMgr:GetText("radar_effect_13")
	    else
	    	tweenTarget.transform:Find("bg_soldier/frame/special"):GetComponent("UILabel").text = TextMgr:GetText("radar_hint")
	    end
    	info.soldier_total.text = totalsoldier
    	info.soldier_grid:Reposition()
    	info.soldier_scroll:ResetPosition()
    	formationSmall = BMFormation(tweenTarget.transform:Find("Container/Embattle"))
	    formationSmall:SetLeftFormation(_data.army.formation.form)
	    formationSmall:SetRightFormation(RadarData.GetDefendForm())
	    formationSmall:Awake()
    elseif _type == 4 then
    	local tweenTarget = info.go.transform:Find("Item_open02").gameObject
    	info.btn_open.tweenTarget = tweenTarget
    	info.bg_list.to = 280--base_height + tweenTarget:GetComponent("UIWidget").height
    	local reslist = {}
    	for _, v in ipairs(_data.restrans.res) do
    		reslist[v.id - 2] = v.num
    	end
    	tweenTarget.transform:Find("food/frame/Sprite/number"):GetComponent("UILabel").text = Global.ExchangeValue(reslist[1] ~= nil and reslist[1] or 0)
    	tweenTarget.transform:Find("food/frame/Sprite (1)/number"):GetComponent("UILabel").text = Global.ExchangeValue(reslist[2] ~= nil and reslist[2] or 0)
    	tweenTarget.transform:Find("food/frame/Sprite (2)/number"):GetComponent("UILabel").text = Global.ExchangeValue(reslist[3] ~= nil and reslist[3] or 0)
    	tweenTarget.transform:Find("food/frame/Sprite (3)/number"):GetComponent("UILabel").text = Global.ExchangeValue(reslist[4] ~= nil and reslist[4] or 0)
    elseif _type == 5 then
    	local tweenTarget = info.go.transform:Find("Item_open03").gameObject
    	info.btn_open.tweenTarget = tweenTarget
    	info.bg_list.to = 285--base_height + tweenTarget:GetComponent("UIWidget").height
    	tweenTarget.transform:Find("place/frame/space_icon"):GetComponent("UITexture").mainTexture =  ResourceLibrary:GetIcon("Icon/WorldMap/" ,"spyon_" .. (_data.tarentrytype == 8 and 7 or _data.tarentrytype) ) --"spyon_" .. (_data.tarentrytype == 8 and 7 or _data.tarentrytype)
    	tweenTarget.transform:Find("place/frame/text").gameObject:SetActive(true)
    	tweenTarget.transform:Find("place/frame/text (1)").gameObject:SetActive(false)
    	local pos_label = tweenTarget.transform:Find("place/frame/text/Label"):GetComponent("UILabel")
    	pos_label.text = TextMgr:GetText("ui_worldmap_spy" .. (_data.tarentrytype == 8 and 7 or _data.tarentrytype))
    end
    paraController:SetItemOpenHeight(info.bg_list.to)
    return info
end

function Awake()
	container = transform:Find("Marchlist/Container").gameObject
	btn_close = transform:Find("Marchlist/Container/bg_frane/bg_top/btn_close").gameObject
	scroll_view = transform:Find("Marchlist/Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	scroll_table = transform:Find("Marchlist/Container/bg_frane/Scroll View/Table"):GetComponent("UITable")
	iteminfo_prefab = transform:Find("Marchlist/ItemInfo").gameObject
	noitem = transform:Find("Marchlist/Container/bg_frane/bg_mid/bg_noitem").gameObject
	RadarData.AddListener(RefreshRadar)
end

local function CheckIsContain(item, datas)
	for i, v in ipairs(datas) do
		if item.se.pathId == v.se.pathId then
			return true
		end
	end
	return false
end

function RefreshUnionHelpInfo()
	local data = UnionHelpData.GetMemberHelpData()
	local otherMemHelpListMsg = unionMemHelpMsg.compensateInfos
	if unionMemHelpMsg.compensateInfos ~= nil then
		for i=1 , #unionMemHelpMsg.compensateInfos do
			if unionMemHelpMsg.compensateInfos[i].charId == MainData.GetCharId() then
				local msgInfo = unionMemHelpMsg.compensateInfos[i]
				local info = {}
				info.go = GameObject.Instantiate(iteminfo_prefab)
				info.go.transform:SetParent(scroll_table.transform, false)
				
				info.go.transform:Find("bg_list/foodstuff").gameObject:SetActive(false)
				info.go.transform:Find("bg_list/from").gameObject:SetActive(false)
				
				info.bg_icon = info.go.transform:Find("bg_list/bg_icon/Sprite"):GetComponent("UITexture")
				info.bg_icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/" ,"icon_plane_garrison" )--typeicon
				info.text_name = info.go.transform:Find("bg_list/bg_icon/bg_text/text_type/text_name"):GetComponent("UILabel")
				info.text_name.text = TextMgr:GetText(march_type[6])
				info.timeslider = info.go.transform:Find("bg_list/bg_exp/bg/bar"):GetComponent("UISlider")
				info.timetext = info.go.transform:Find("bg_list/bg_exp/bg/text"):GetComponent("UILabel")
				local _time = msgInfo.endTime -- pathInfo.starttime + pathInfo.time
				local _totalTime = msgInfo.endTime - msgInfo.triggerTime --pathInfo.time
				
				CountDown.Instance:Add(string.format("compensateInfos_%d_%d_%d", msgInfo.charId , msgInfo.triggerTime ,msgInfo.endTime)  , _time , CountDown.CountDownCallBack(function(t)
					leftTime = _time - Serclimax.GameTime.GetSecTime()
					if leftTime > 0 then
						local totalTime = tonumber(_totalTime)
						if info.time_text == nil or info.time_text:Equals(nil) or info.time_slider == nil or info.time_slider:Equals(nil) then
							return
						end
						info.time_text.text = t
						info.time_slider.value = 1 - (leftTime / totalTime)
					else
						GameObject.Destroy(oldData.items[v.se.pathId].go)
					end
				end))
			end
		end
	end
end

function RefreshRadar()
	local data = RadarData.GetData()
	noitem:SetActive(false)
	for i, v in ipairs(data) do
		if not CheckIsContain(v, oldData.datas) then
			oldData.items[v.se.pathId] = RefreshList(v)
		end
	end
	for i, v in ipairs(oldData.datas) do
		if not CheckIsContain(v, data) then
			if oldData.items[v.se.pathId] ~= nil and oldData.items[v.se.pathId].go ~= nil and not oldData.items[v.se.pathId].go:Equals(nil) then
				GameObject.Destroy(oldData.items[v.se.pathId].go)
			end
			CountDown.Instance:Remove("RadarMove_" .. v.se.pathId)
			oldData.items[v.se.pathId] = nil
		end
	end
	oldData.datas = data
	coroutine.start(function()
        coroutine.step()
		scroll_table:Reposition()
		scroll_view:ResetPosition()
		local childCount = scroll_table.transform.childCount
		if childCount == 0 then
			noitem:SetActive(true)
		end
	end)
end

function Start()
	MainCityUI.RadarSoundOff()
	SetClickCallback(container, CloseSelf)
	SetClickCallback(btn_close, CloseSelf)
	oldData = {}
	oldData.datas = {}
	oldData.items = {}
	_building = maincity.GetBuildingByID(40)
	RefreshRadar()
end

function Update()
	
end

function LateUpdate()
	
end

function Close()
    if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
	container = nil
	btn_close = nil
	scroll_view = nil
	scroll_table = nil
	noitem = nil
	_building = nil
	iteminfo_prefab = nil
	oldData = nil
end
