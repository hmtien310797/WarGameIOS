module("Preview", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local SetNumber = Global.SetNumber

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local HeroPreviewList
local ItemPreviewList
local _ui, curType

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

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function Hide()
	coroutine.stop(_ui.loadcoroutine)
	coroutine.stop(_ui.itemcoroutine)
    Global.CloseUI(_M)
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

local function CloseClickCallback(go)
    Hide()
end

local function LoadPreviewList()
	if HeroPreviewList ~= nil then
		return
	end
	local high = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MilitarySchoolPreviewHigh).value:split(";")
	local normal = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MilitarySchoolPreviewNormal).value:split(";")
	HeroPreviewList = {}
	ItemPreviewList = {}
	HeroPreviewList[2] = {}
	for i, v in ipairs(TableMgr:GetDropShowData(tonumber(high[1]))) do
		local hero = {}
        hero.data = TableMgr:GetHeroData(v.contentId)
        hero.msg = GeneralData.GetDefaultHeroData(hero.data) -- HeroListData.GetDefaultHeroData(hero.data)
        table.insert(HeroPreviewList[2], hero)
	end
	HeroPreviewList[1] = {}
	for i, v in ipairs(TableMgr:GetDropShowData(tonumber(normal[1]))) do
		local hero = {}
        hero.data = TableMgr:GetHeroData(v.contentId)
        hero.msg = GeneralData.GetDefaultHeroData(hero.data) -- HeroListData.GetDefaultHeroData(hero.data)
        table.insert(HeroPreviewList[1], hero)
	end
	ItemPreviewList[2] = {}
	for i, v in ipairs(TableMgr:GetDropShowData(tonumber(high[2]))) do
		local item = {}
		item.data = TableMgr:GetItemData(v.contentId)
		table.insert(ItemPreviewList[2], item)
	end
	ItemPreviewList[1] = {}
	for i, v in ipairs(TableMgr:GetDropShowData(tonumber(normal[2]))) do
		local item = {}
		item.data = TableMgr:GetItemData(v.contentId)
		table.insert(ItemPreviewList[1], item)
	end
end

local function LoadHeroPreview()
	local list = HeroPreviewList[curType]
	_ui.loadcoroutine = coroutine.start(function()
		for i, v in ipairs(list) do
	        local heroTransform = _ui.illustrateListGrid:GetChild(i - 1)
	        if heroTransform == nil then
	            heroTransform = NGUITools.AddChild(_ui.illustrateListGrid.gameObject, _ui.heroPrefab).transform
	            heroTransform.gameObject.name = _ui.heroPrefab.name..i
	            if i % 4 == 0 then
	                _ui.illustrateListGrid.repositionNow = true
	                coroutine.step()
	            end
	        end

	        local hero = {} 
	        HeroList.LoadHeroObject(hero, heroTransform)
	        HeroList.LoadHero(hero, v.msg, v.data, true)
	        SetClickCallback(hero.btn.gameObject, function(go)
	            -- Hide()
	            HeroInfoNew.Show(v.msg)
	        end)
	        hero.levelLabel.gameObject:SetActive(false)
	        hero.lock.gameObject:SetActive(false)
	        hero.nameLabel.gameObject:SetActive(true)
	    end
	    _ui.illustrateListGrid.repositionNow = true
	end)
end

function GetIllustrateHero(heroId)
    for i, v in ipairs(HeroPreviewList[curType]) do
        if v.data.id == heroId then
            return v, i, i == #HeroPreviewList[curType]
        end
    end
end

local function LoadItemList()
	_ui.itemcoroutine = coroutine.start(function()
	    for i, v in ipairs(ItemPreviewList[curType]) do
	        local itemdata = v.data
	        local itemTransform = NGUITools.AddChild(_ui.itemListGrid.gameObject, _ui.itemPrefab).transform
	        itemTransform.gameObject.name = _ui.itemPrefab.name..i
	        if i % 6 == 0 then
	            _ui.itemListGrid.repositionNow = true
	            coroutine.step()
	        end
	        itemTransform.localScale = Vector3(1.2,1.2,1)
            local item = {}
            UIUtil.LoadItemObject(item, itemTransform)
            UIUtil.LoadItem(item, itemdata)
			SetParameter(itemTransform.gameObject, "item_" .. v.data.id)
	    end
	    _ui.itemListGrid.repositionNow = true
	end)
end

function GetPreviousIllustrateHero(heroId)
    local _, i = GetIllustrateHero(heroId)
    return HeroPreviewList[curType][i - 1]
end

function GetNextIllustrateHero(heroId)
    local _, i = GetIllustrateHero(heroId)
    return HeroPreviewList[curType][i + 1]
end

function Awake()
	LoadPreviewList()
	_ui = {}
	local btnClose = transform:Find("background widget/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(btnClose.gameObject, CloseClickCallback)
    SetClickCallback(mask.gameObject, CloseClickCallback)
    
    _ui.title = transform:Find("background widget/background/title/text"):GetComponent("UILabel")
    _ui.tab1 = transform:Find("background widget/bg2/page2").gameObject
    _ui.tab2 = transform:Find("background widget/bg2/page3").gameObject
    
    _ui.illustrateListGrid = transform:Find("background widget/bg2/content 2/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    
    _ui.itemListGrid = transform:Find("background widget/bg2/content 3/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
	LoadHeroPreview()
	LoadItemList()
	SetClickCallback(_ui.tab1, function()
		_ui.title.text = curType == 1 and TextMgr:GetText("Preview_title_normal") or TextMgr:GetText("Preview_title_high")
	end)
	SetClickCallback(_ui.tab2, function()
		_ui.title.text = curType == 1 and TextMgr:GetText("Preview_title_normal_item") or TextMgr:GetText("Preview_title_high_item")
	end)
	_ui.title.text = curType == 1 and TextMgr:GetText("Preview_title_normal") or TextMgr:GetText("Preview_title_high")
end

function Close()
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Show(showtype)
	if showtype ~= nil then
		curType = showtype
	end
	if curType == nil then
		curType = 1
	end
    Global.OpenUI(_M)
end

function CloseAll()
    Hide()
end
