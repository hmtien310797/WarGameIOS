module("rebel_reward", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local rewards

local ui
local tooltipTarget

local isInViewport = false

Show = nil
Hide = nil

Start = nil
Close = nil

local Draw = nil
local LoadUI = nil
local SetUI = nil

local SetTooltipTarget = nil
local ShowTooltip = nil
local HideTooltip = nil

local OnMouseClick = nil

Show = function()
	if not isInViewport then
		RebelData.RequestStepReward(function(_rewards)
			rewards = _rewards

			Global.OpenUI(_M)
		end)
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

	UIUtil.RemoveDelegate(UICamera, "onClick", OnMouseClick)
	UIUtil.RemoveDelegate(UICamera, "onDragStart", HideTooltip)
    HideTooltip()

	ui = nil
end

Draw = function()
	LoadUI()
	SetUI()
end

LoadUI = function()
	if ui == nil then
		ui = {}

		ui.mask = transform:Find("reward/mask").gameObject

		UIUtil.AddDelegate(UICamera, "onClick", OnMouseClick)
		UIUtil.AddDelegate(UICamera, "onDragStart", HideTooltip)

		UIUtil.SetClickCallback(transform:Find("reward/bg_top/btn_close").gameObject, Hide)

		ui.rewardList = {}
		ui.rewardList.gameObject = transform:Find("reward/mid/Scroll View/Grid").gameObject
		ui.rewardList.grid = ui.rewardList.gameObject.transform:GetComponent("UIGrid")
		ui.rewardList.rewards = {}

		ui.newReward = {}
		ui.newReward.gameObject = transform:Find("stage_reward").gameObject
		ui.newReward.level = ui.newReward.gameObject.transform:Find("Label/lv"):GetComponent("UILabel")

		ui.newHero = {}
		ui.newHero.gameObject = NGUITools.AddChild(gameObject, ResourceLibrary.GetUIPrefab("Hero/listitem_hero"))
		ui.newHero.transform = ui.newHero.gameObject.transform
		ui.newHero.icon = ui.newHero.transform:Find("head icon"):GetComponent("UITexture")
		ui.newHero.frame = ui.newHero.transform:Find("head icon/outline"):GetComponent("UISprite")
		ui.newHero.level = ui.newHero.transform:Find("level text"):GetComponent("UILabel")
		ui.newHero.stars = ui.newHero.transform:Find("star"):GetComponent("UISprite")
	end
end

SetUI = function()
	if ui ~= nil then
		ui.newHero.gameObject:SetActive(true)

		for level, reward in ipairs(rewards) do
			ui.newReward.level.text = reward.level

			local newReward = {}
			newReward.transform = NGUITools.AddChild(ui.rewardList.gameObject, ui.newReward.gameObject).transform

			newReward.itemList = {}
			newReward.itemList.gameObject = newReward.transform:Find("Grid").gameObject
			newReward.itemList.grid = newReward.itemList.gameObject.transform:GetComponent("UIGrid")

			for _, item in ipairs(reward.rewardInfo.items) do
				UIUtil.AddItemToGrid(newReward.itemList.gameObject, item, function(objectClicked)
		            ShowTooltip(TableMgr:GetItemData(item.id), 0, objectClicked)
		        end)
			end

			for _, hero in ipairs(reward.rewardInfo.heros) do
				local heroData = TableMgr:GetHeroData(hero.id)

				ui.newHero.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", heroData.icon)
				ui.newHero.frame.spriteName = string.format("head%d", heroData.quality)
				ui.newHero.level.text = hero.level == nil and "0" or tostring(hero.level)
				ui.newHero.stars.width = (hero.star or 0) * star.height

				UIUtil.SetClickCallback(NGUITools.AddChild(newReward.itemList.gameObject, ui.newHero.gameObject), function(objectClicked)
					ShowTooltip(itemData, 1, objectClicked)
				end)
			end

			newReward.itemList.grid:Reposition()

			ui.rewardList.rewards[level] = newReward
		end

		ui.rewardList.grid:Reposition()

		ui.newHero.gameObject:SetActive(false)
	end
end

SetTooltipTarget = function(gameObject)
	tooltipTarget = gameObject
end

ShowTooltip = function(itemData, itemType, objectClicked)
	if isInViewport then
		local previousTooltipTarget = tooltipTarget
		
		if Tooltip.IsItemTipActive() then
			HideTooltip()
		end

		if objectClicked ~= previousTooltipTarget then
			SetTooltipTarget(objectClicked)
			Tooltip.ShowItemTip({name = itemType == 0 and TextUtil.GetItemName(itemData) or TextMgr:GetText(itemData.nameLabel), text = TextUtil.GetItemDescription(itemData)})
		end
	end
end

HideTooltip = function()
	Tooltip.HideItemTip()
	SetTooltipTarget(nil)
end

OnMouseClick = function(objectClicked)
	if Tooltip.IsItemTipActive() and objectClicked ~= tooltipTarget then
		HideTooltip()
	elseif objectClicked == ui.mask then
		Hide()
	end
end
