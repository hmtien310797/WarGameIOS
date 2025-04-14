module("rebel", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
-- local PlayerPrefs = UnityEngine.PlayerPrefs
local FloatText = FloatText
local AudioMgr = Global.GAudioMgr
local Format = System.String.Format
local GameTime = Serclimax.GameTime

local _container
local _reward
local _itemPrefabs
local data
local timelist
local initstepreward = false
local refreshcoroutine
local itemlist = {}
local herolist = {}
local timer = 0

local isNew = false

local ACTIVITY_ID = ActivityAll.GetActivityIdByName("Panzer")

local isInViewport = false

local helpdata = 
{
	title = "rebel_22",
	icon = "Background/loading1",
	iconbg = "Background/loading2",
	text = "rebel_24",
	infos = {"rebel_1","rebel_2","rebel_3","rebel_4","rebel_5","rebel_6"}
}

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	for i, v in ipairs(itemlist) do
		if go == v then
			local itemdata = TableMgr:GetItemData(tonumber(go.name))
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
		    return
		end
	end
	if go.transform.parent ~= nil then
		go = go.transform.parent.gameObject
	end
	for i, v in ipairs(herolist) do
		if go == v then
			local itemdata = TableMgr:GetHeroData(tonumber(go.name))
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
		    return
		end
	end
	Tooltip.HideItemTip()
end

local function UpdateNotice()
	MainCityUI.UpdateActivityAllNotice(ACTIVITY_ID)
end

function OnUICameraClick(go)
    _container.energyTipObject:SetActive(false)
    if go ~= _container.tipObject then
        _container.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    _container.energyTipObject:SetActive(false)
end

function HasNotice()
	return isNew
end

function NotifyAvailable()
	isNew = true
	UpdateNotice()
end

function CloseSelf()
	Global.CloseUI(_M)
end

local function OpenReward()
	_reward.container:SetActive(true)
	NGUITools.BringForward(_reward.container)
end

local function CloseReward()
	_reward.container:SetActive(false)
end

local function ShowHelp()
	-- instructions.Show(helpdata)
	MapHelp.OpenMulti(300)
end

local function AddTimeCountdown(_label, _target)
	for i, v in pairs(timelist) do
		if v.label == _label then
			v.target = _target
		end
	end
	local timeitem = {}
	timeitem.target = _target
	timeitem.label = _label
	table.insert(timelist, timeitem)
end

function Awake()
    SetClickCallback(transform:Find("mask").gameObject, function()
        CloseSelf()
        ActivityAll.Hide()
    end)
	_container = {}
	_container.container = transform:Find("Container").gameObject
	_container.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_container.btn_help = transform:Find("Container/bg_left/top/detail").gameObject
	_container.time = transform:Find("Container/bg_left/top/time"):GetComponent("UILabel")
	_container.saomiao = transform:Find("Container/bg_left/mid/rebel_icon/Saomiao").gameObject
	_container.rebel_icon = transform:Find("Container/bg_left/mid/rebel_icon"):GetComponent("UITexture")
	_container.rebel_level_bg = transform:Find("Container/bg_left/mid/rebel_icon/lv").gameObject
	_container.rebel_level = transform:Find("Container/bg_left/mid/rebel_icon/lv/number"):GetComponent("UILabel")
	_container.rebel_hp_bg = transform:Find("Container/bg_left/mid/rebel_icon/kuang").gameObject
	_container.rebel_hp_slider = transform:Find("Container/bg_left/mid/rebel_icon/kuang/red"):GetComponent("UISlider")
	_container.rebel_hp_text = transform:Find("Container/bg_left/mid/rebel_icon/kuang/text"):GetComponent("UILabel")
	_container.kill_all = transform:Find("Container/bg_left/mid/text01").gameObject
	_container.kill_level = transform:Find("Container/bg_left/mid/text02/lv"):GetComponent("UILabel")
	_container.btn_go = transform:Find("Container/bg_left/mid/button_go").gameObject
	_container.btn_search = transform:Find("Container/bg_left/mid/button_search").gameObject
	_container.tili_slider = transform:Find("Container/bg_left/mid/bg_jindu/bg_progress/icon_progress"):GetComponent("UISlider")
	_container.tili_text = transform:Find("Container/bg_left/mid/bg_jindu/bg_progress/Label"):GetComponent("UILabel")
	_container.tili_add = transform:Find("Container/bg_left/mid/bg_jindu/btn_add").gameObject
	_container.owner_name = transform:Find("Container/bg_left/mid/bg_follow/text01/name"):GetComponent("UILabel")
	_container.owner_time = transform:Find("Container/bg_left/mid/bg_follow/text02/time"):GetComponent("UILabel")
	_container.owner_coordinates = transform:Find("Container/bg_left/mid/bg_follow/text03/coordinates"):GetComponent("UILabel")
	_container.reward_grid = transform:Find("Container/bg_left/mid/bg_follow/reward/Grid"):GetComponent("UIGrid")
	_container.reward_check = transform:Find("Container/bg_left/mid/bg_follow/reward/check").gameObject
	_container.none = transform:Find("Container/bg_right/none").gameObject
	_container.union_scroll = transform:Find("Container/bg_right/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_container.union_grid = transform:Find("Container/bg_right/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_container.union_item = transform:Find("bg_rebel").gameObject
	_container.energySprite = transform:Find("Container/bg_left/mid/bg_jindu/bg_progress/Sprite"):GetComponent("UISprite")
	_container.energyTipObject = transform:Find("Container/bg_left/mid/bg_jindu/bg").gameObject
	_container.energyLabel1 = transform:Find("Container/bg_left/mid/bg_jindu/bg/Label (1)"):GetComponent("UILabel")
	_container.energyLabel2 = transform:Find("Container/bg_left/mid/bg_jindu/bg/Label"):GetComponent("UILabel")
	_reward = {}
	_reward.container = transform:Find("reward").gameObject
	_reward.btn_close = transform:Find("reward/bg_top/btn_close").gameObject
	_reward.monster_texture = transform:Find("reward/Texture"):GetComponent("UITexture")
	_reward.kill_level = transform:Find("reward/right/bg_1/icon/number"):GetComponent("UILabel")
	_reward.kill_need = transform:Find("reward/right/bg_2/icon/number"):GetComponent("UILabel")
	_reward.next_item = transform:Find("reward/mid/listinfo_item0.75")
	_reward.next_hero = transform:Find("reward/mid/herocard_rebel01")
	_reward.scroll = transform:Find("reward/mid/Scroll View"):GetComponent("UIScrollView")
	_reward.grid = transform:Find("reward/mid/Scroll View/Grid"):GetComponent("UIGrid")
	_reward.item = transform:Find("stage_reward").gameObject
	_itemPrefabs = {}
	_itemPrefabs.item = transform:Find("listinfo_item0.75").gameObject
	_itemPrefabs.hero = transform:Find("herocard_rebel01").gameObject
    SetClickCallback(_container.energySprite.gameObject, function(go)
        if go == _container.tipObject then
            _container.tipObject = nil
        else
            _container.tipObject = go
            _container.energyTipObject:SetActive(true)
        end
    end)
end

local function MakeItem(_item, _data)
	_item.name = _data.id
	local itemdata = TableMgr:GetItemData(_data.id)
	_item:Find("icon_item"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
	if _data.num ~= nil and _data.num > 1 then
		local num_item = _item:Find("num_item")
		num_item.gameObject:SetActive(true)
		num_item:GetComponent("UILabel").text = _data.num
		num_item = nil
	else
		local num_item = _item:Find("num_item")
		num_item.gameObject:SetActive(false)
	end
	_item:GetComponent("UISprite").spriteName = "bg_item" .. itemdata.quality
	local itemlvTrf = _item.transform:Find("bg_num")
	local itemlv = itemlvTrf:Find("txt_num"):GetComponent("UILabel")
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
	table.insert(itemlist, _item.gameObject)
	itemlvTrf = nil
	itemlv = nil
	itemdata = nil
end

local function MakeHero(_item, _data)
	_item.name = _data.id
	local heroData = TableMgr:GetHeroData(_data.id)
	_item:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
	_item:Find("head icon/outline1"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
	_item:Find("level text"):GetComponent("UILabel").text = _data.level == nil and "0" or _data.level
	local star = _item:Find("star")
	local star_count = star.transform.childCount
	_data.star = _data.star == nil and 0 or _data.star
	for n = 1, star_count do
		if n == _data.star then
			star.transform:GetChild(n - 1).gameObject:SetActive(true)
		else
			star.transform:GetChild(n - 1).gameObject:SetActive(false)
		end
	end
	table.insert(herolist, _item.gameObject)
	heroData = nil
	star = nil
	star_count = nil
end

local function MakeRewardItem(_grid, _reward)
	local childCount = _grid.transform.childCount
	for i = 0, childCount - 1 do
		GameObject.Destroy(_grid.transform:GetChild(i).gameObject)
	end
	for i, v in ipairs(_reward.items) do
		local item = NGUITools.AddChild(_grid.gameObject, _itemPrefabs.item).transform
		item.localScale = _itemPrefabs.item.transform.localScale
		MakeItem(item, v)
		item = nil
	end
	for i, v in ipairs(_reward.heros) do
		local item = NGUITools.AddChild(_grid.gameObject, _itemPrefabs.hero).transform
		item.localScale = _itemPrefabs.hero.transform.localScale
		MakeHero(item, v)
		item = nil
	end
end

local function MakeNeedLevel(stepRewards)
	for i, v in ipairs(stepRewards) do
		if v.level > data.finishLevel then
			return v.level - data.finishLevel, v.rewardInfo
		end
	end
	return 0, nil
end

local function ShowStepReward()
	RebelData.RequestStepReward(function(stepRewards)
		if _container == nil then
			return
		end
		_reward.kill_level.text = data.finishLevel
		local nextreward
		_reward.kill_need.text, nextreward = MakeNeedLevel(stepRewards)
		local showed = false
		if nextreward ~= nil then
			for i, v in ipairs(nextreward.items) do
				if not showed then
					showed = true
					_reward.next_item.gameObject:SetActive(true)
					MakeItem(_reward.next_item, v)
				end
			end
			for i, v in ipairs(nextreward.heros) do
				if not showed then
					showed = true
					_reward.next_hero.gameObject:SetActive(true)
					MakeHero(_reward.next_hero, v)
				end
			end
		else
			_reward.next_item.gameObject:SetActive(true)
			_reward.next_item:GetComponent("UISprite").spriteName = "bg_item_hui"
			_reward.next_item:Find("bg_num").gameObject:SetActive(false)
			_reward.next_item:Find("num_item").gameObject:SetActive(false)
		end
		if initstepreward then
			initstepreward = false
			for i, v in ipairs(stepRewards) do
				local step = NGUITools.AddChild(_reward.grid.gameObject, _reward.item).transform
				step:Find("Label/lv"):GetComponent("UILabel").text = v.level
				local item = step:Find("Grid/listinfo_item0.5")
				item.gameObject:SetActive(false)
				local hero = step:Find("Grid/herocard_rebel02")
				hero.gameObject:SetActive(false)
				showed = false
				--if i % 2 == 0 then
				--	step:Find("back").gameObject:SetActive(false)
				--end
				if v.rewardInfo.items ~= nil and #v.rewardInfo.items > 0 then
					if not showed then
						showed = true
						item.gameObject:SetActive(true)
						MakeItem(item, v.rewardInfo.items[1])
					end
				end
				if v.rewardInfo.heros ~= nil and #v.rewardInfo.heros > 0 then
					if not showed then
						showed = true
						hero.gameObject:SetActive(true)
						MakeHero(hero, v.rewardInfo.heros[1])
					end
				end
				step = nil
				item = nil
				hero = nil
			end
		end
	end)
end

local function UpdateMonster(monsDetail, dontneesaomiao)
	_container.btn_search:SetActive(false)
	if dontneesaomiao == nil then
		_container.saomiao:SetActive(true)
	end
	local monster = TableMgr:GetActMonsterRuleData(monsDetail.level)
	refreshcoroutine = coroutine.start(function()
		if dontneesaomiao == nil then
    		WaitForRealSeconds(1)
    	end
    	local monster = TableMgr:GetActMonsterRuleData(monsDetail.level)
    	_container.rebel_icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", TableMgr:GetArtSettingData(monster.picture).icon)
    	_container.rebel_icon.color = Color.white
    	_container.rebel_level_bg:SetActive(true)
    	_container.rebel_hp_bg:SetActive(true)
		_container.rebel_level.text = monsDetail.level
		_container.rebel_hp_slider.value = (monsDetail.numMax - monsDetail.numDead) / monsDetail.numMax
		_container.rebel_hp_text.text =	"" .. math.floor(_container.rebel_hp_slider.value * 100 + 0.5) .. "%"
		_container.kill_all:SetActive(data.finishLevel == data.maxLevel)
		_container.kill_level.text = data.finishLevel
		local mapX = monsDetail.entrypos.x
		local mapY = monsDetail.entrypos.y
        SetClickCallback(_container.btn_go, function()
            CloseSelf()
            ActivityAll.Hide()
            MainCityUI.ShowWorldMap(mapX, mapY, true)
        end)
		_container.owner_name.text = monsDetail.finderName
		AddTimeCountdown(_container.owner_time, monsDetail.escapeTime)
		_container.owner_coordinates.text = System.String.Format("#1.X:{0} Y:{1}", mapX, mapY)
		MakeRewardItem(_container.reward_grid, monsDetail.rewardInfo)
		_container.reward_grid:Reposition()
		if dontneesaomiao == nil then
			WaitForRealSeconds(1)
		end
		_container.btn_go:SetActive(true)
		_container.saomiao:SetActive(false)
	end)
end

local function UpdateTime()
    _container.energyLabel1.text, _container.energyLabel2.text = MainData.GetSceneEnergyCooldownText()
end

local function UpdateUI()
	timelist = {}
	data = RebelData.GetData()
	-- if not PlayerPrefs.HasKey("rebelhelp") then
	-- 	ShowHelp()
	-- 	PlayerPrefs.SetInt("rebelhelp",tonumber(os.date("%d")))
	--     PlayerPrefs.Save()
	-- end
	if data.monsDetail ~= nil and data.monsDetail.level > 0 then
		UpdateMonster(data.monsDetail, true)
	else
		_container.btn_go:SetActive(false)
		_container.btn_search:SetActive(true)
	end
	if data.allianceMonsDetails ~= nil and #data.allianceMonsDetails > 0 then
		table.sort(data.allianceMonsDetails, function(a, b) return a.escapeTime < b.escapeTime end)
		local childcount = _container.union_grid.transform.childCount
		local index = 0
		for i, v in ipairs(data.allianceMonsDetails) do
			index = i
			local item
			if i < childcount then
				item = _container.union_grid.transform:GetChild(i - 1)
			else
				item = NGUITools.AddChild(_container.union_grid.gameObject, _container.union_item).transform
			end
			local monster = TableMgr:GetActMonsterRuleData(v.level)
    		item:Find("rebel_icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", TableMgr:GetArtSettingData(monster.picture).icon)
			item:Find("rebel_icon/lv/number"):GetComponent("UILabel").text = v.level
			item:Find("rebel_icon/kuang/red"):GetComponent("UISlider").value = (v.numMax - v.numDead) / v.numMax
			item:Find("rebel_icon/kuang/text"):GetComponent("UILabel").text = "" .. math.floor((v.numMax - v.numDead) / v.numMax * 100 + 0.5) .. "%"
			item:Find("finder/kuang/time"):GetComponent("UILabel").text = v.finderName
			AddTimeCountdown(item:Find("time/kuang/time"):GetComponent("UILabel"), v.escapeTime)
            SetClickCallback(item:Find("go").gameObject, function()
                CloseSelf()
                ActivityAll.Hide()
                MainCityUI.ShowWorldMap(v.entrypos.x, v.entrypos.y)
            end)
		end
		for i = index, childcount - 1 do
			GameObject.Destroy(_container.union_grid.transform:GetChild(i).gameObject)
		end
		_container.union_grid:Reposition()
		_container.union_scroll:ResetPosition()
		_container.none:SetActive(false)
	else
		_container.none:SetActive(true)
	end
	_container.kill_all:SetActive(data.finishLevel == data.maxLevel)
	_container.kill_level.text = data.finishLevel
	if data.finishLevel >= data.maxLevel then
		_container.btn_search:SetActive(false)
	end
	ShowStepReward()
	UpdateTime()
end

function Start()
	isInViewport = true

	if isNew then
		isNew = false
		UpdateNotice()
	end

	SetClickCallback(_container.btn_close, CloseSelf)
	SetClickCallback(_container.btn_help, ShowHelp)
	SetClickCallback(_container.reward_check, OpenReward)
	SetClickCallback(_container.btn_search, function()
		if MainData.GetSceneEnergy() < RebelData.GetActivityInfo().searchSta then
			Global.ShowNoEnoughSceneEnergy(RebelData.GetActivityInfo().searchSta - MainData.GetSceneEnergy() +1)
        	return
		end
		RebelData.RequestSearch(UpdateMonster)
	end)
	SetClickCallback(_container.tili_add, function() Global.ShowNoEnoughSceneEnergy(0) end)
	SetClickCallback(_reward.container, CloseReward)
	SetClickCallback(_reward.btn_close, CloseReward)
	RebelData.AddListener(UpdateUI)
	RebelData.RequestData()
	initstepreward = true

	CountDown.Instance:Add(_M._NAME, ActivityData.GetBattleFieldActivityConfigs(2002).endTime, CountDown.CountDownCallBack(function(text)
		_container.time.text = System.String.Format(TextMgr:GetText("ActivityAll_09"), text)

		if text == "00:00:00" then
			CountDown.Instance:Remove(_M._NAME)
		end
	end))
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	itemlist = {}
	herolist = {}
	_container.rebel_icon.color = Color.black
	local monster = TableMgr:GetActMonsterRuleData(1)
    _container.rebel_icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", TableMgr:GetArtSettingData(monster.picture).icon)
end

function Update()
	if timelist ~= nil then
		local curtime = Serclimax.GameTime.GetSecTime()
		for i, v in pairs(timelist) do
			if v.target > curtime then
				v.label.text = Serclimax.GameTime.SecondToString3(v.target - curtime)
			else
				table.remove(timelist, i)
			end
		end
	end
	_container.tili_text.text = string.format("%d/%d", MainData.GetSceneEnergy(), MainData.GetMaxSceneEnergy())
	_container.tili_slider.value = MainData.GetSceneEnergy() / MainData.GetMaxSceneEnergy()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end

function Close()
	isInViewport = false

	CountDown.Instance:Remove(_M._NAME)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	RebelData.RemoveListener(UpdateUI)
	coroutine.stop(refreshcoroutine)
	data = nil
	timelist = nil
	_container = nil
	_reward = nil
end

function Show()
	Global.OpenUI(_M)
end
