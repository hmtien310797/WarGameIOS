module("BoxShow", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local rewardInfo
local title = TextMgr:GetText("SectionRewards_ui3")

local ui

local isInViewport = false

Show = nil
Hide = nil

Start = nil
Close = nil

local Draw = nil
local LoadUI = nil
local SetUI = nil

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= ui.tipObject then
        ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

Show = function(itemKeyInfoVec, _title)
	if not isInViewport then
		rewardInfo = itemKeyInfoVec
		title = _title

		Global.OpenUI(_M)
	end
end

Hide = function()
	if isInViewport then
		Global.CloseUI(_M)
	end
end

Start = function()
	isInViewport = true

	Draw()
end

Close = function()
	isInViewport = false

	rewardInfo = nil
	title = TextMgr:GetText("SectionRewards_ui3")

    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    
	ui = nil
end

Draw = function()
	LoadUI()
	SetUI()
end

LoadUI = function()
	if ui == nil then
		ui = {}

		UIUtil.SetClickCallback(transform:Find("mask").gameObject, Hide)
		UIUtil.SetClickCallback(transform:Find("Container/bg_frane/btn_close").gameObject, Hide)

		transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel").text = title

		ui.itemList = {}
		ui.itemList.transform = transform:Find("Container/bg_frane/Scroll View/Grid")
		ui.itemList.gameObject = ui.itemList.transform.gameObject
		ui.itemList.grid = ui.itemList.transform:GetComponent("UIGrid")

	    ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
		ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
		--[[ui.newHero = {}
		ui.newHero.transform = transform:Find("Container/herocard_rebel01")
		ui.newHero.gameObject = ui.newHero.transform.gameObject
		ui.newHero.icon = ui.newHero.transform:Find("head icon"):GetComponent("UITexture")
		ui.newHero.frame = ui.newHero.transform:Find("head icon/outline1"):GetComponent("UISprite")
		ui.newHero.level = ui.newHero.transform:Find("level text"):GetComponent("UILabel")

		ui.newHero.stars = {}
		ui.newHero.stars.transform = ui.newHero.transform:Find("star")
		ui.newHero.stars.max = ui.newHero.stars.transform.childCount]]

	    AddDelegate(UICamera, "onClick", OnUICameraClick)
	    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	end
end

SetUI = function()
	for _, hero in ipairs(rewardInfo.heros) do
		local heroData = TableMgr:GetHeroData(hero.id)
		local hero = NGUITools.AddChild(ui.itemList.gameObject, ui.hero.gameObject).transform
		hero.localScale = Vector3(0.6, 0.6, 1)
		hero:Find("level text").gameObject:SetActive(false)
		hero:Find("name text").gameObject:SetActive(false)
		hero:Find("bg_skill").gameObject:SetActive(false)
		hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
		hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
		local star = hero:Find("star"):GetComponent("UISprite")
		if star ~= nil then
			star.width = 1 * star.height
		end
		UIUtil.SetClickCallback(hero:Find("head icon").gameObject, function(go)
            if go == ui.tipObject then
                ui.tipObject = nil
            else
                ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
            end
        end)
		--[[ui.newHero.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", heroData.icon)
		ui.newHero.frame.spriteName = string.format("head%d", heroData.quality)
		ui.newHero.level.text = hero.level == nil and "0" or tostring(hero.level)

		local numStars = hero.star == nil and 0 or hero.star
		for n = 1, ui.newHero.stars.max do
			ui.newHero.stars.transform:GetChild(n - 1).gameObject:SetActive(n == numStars)
		end

		NGUITools.AddChild(ui.itemList.gameObject, ui.newHero.gameObject)]]
	end
	for _, v in ipairs(rewardInfo.items) do
		local itemData = TableMgr:GetItemData(v.id)
		local itemTransform = NGUITools.AddChild(ui.itemList.gameObject, ui.itemPrefab).transform
		local item = {}
		local number = v.num
		UIUtil.LoadItemObject(item, itemTransform)
		UIUtil.LoadItem(item, itemData, number)
        UIUtil.SetClickCallback(item.gameObject, function(go)
            if go == ui.tipObject then
                ui.tipObject = nil
            else
                ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
            end
        end)
	end
	ui.itemList.grid:Reposition()
end
