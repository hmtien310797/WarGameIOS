module("ChapComplete", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local Format = String.Format
local _ui

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

function Awake()
    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	_ui.rewardshow = ResourceLibrary.GetUIPrefab("ActivityStage/GrowRewards")
    _ui.chapComplete = ResourceLibrary.GetUIPrefab("ActivityStage/ChapComplete")
    
    _ui.mask = transform:Find("mask")
    _ui.bg = transform:Find("Container")
	_ui.title = transform:Find("Container/bg_frane/title/text"):GetComponent("UILabel")
	_ui.listGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.title.text = Format(TextMgr:GetText("chapter_ui10"), _ui.chapter)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
    SetClickCallback(_ui.bg.gameObject, function()
		Global.CloseUI(_M)
    end)
    SetClickCallback(_ui.mask.gameObject, function()
        Global.CloseUI(_M)
    end)
    for vv in string.gsplit(_ui.missionData.item, ";") do
		local itemTable = string.split(vv, ":")
		local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
		local itemdata = TableMgr:GetItemData(itemId)
		local item = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.item.gameObject).transform
		item.localScale = Vector3(1.2,1.2,1)
		local reward = {}
		UIUtil.LoadItemObject(reward, item)
		UIUtil.LoadItem(reward, itemdata, itemCount)
		SetParameter(item.gameObject, "item_" .. itemId)
	end
	for vv in string.gsplit(_ui.missionData.hero, ";") do
		local heroTable = string.split(vv, ":")
		local heroId, heroCount = tonumber(heroTable[1]), tonumber(heroTable[2])
		if heroId ~= nil then
			local heroData = TableMgr:GetHeroData(heroId)
			local hero = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.hero.gameObject).transform
			hero.localScale = Vector3(0.72, 0.72, 1)
			hero:Find("level text").gameObject:SetActive(false)
			hero:Find("name text").gameObject:SetActive(false)
			hero:Find("bg_skill").gameObject:SetActive(false)
			hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
			hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
			local star = hero:Find("star"):GetComponent("UISprite")
			if star ~= nil then
				star.width = 1 * star.height
			end
			SetParameter(hero:Find("head icon").gameObject, "hero_" .. heroId)
			local hasHero = ActiveHeroData.HasHeroOld(heroId)
			if not hasHero and heroData.quality >= 4 then
				local heroShowData = 
					{
						baseid = heroId, 
						level = 1, 
						star = 1,
						grade = 1,
						count = 1
					}
		        OneCardDisplay.Show(nil, heroShowData, nil, false)
		    end
		end
	end
	_ui.listGrid:Reposition()
end

function Close()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    if _ui.callback ~= nil then
        _ui.callback()
    end
	_ui = nil
end

function Show(missionData, chapter, callback)
    _ui = {}
    ActiveHeroData.SetOldData()
    _ui.missionData = missionData
    _ui.chapter = chapter
    _ui.callback = callback
	Global.OpenUI(_M)
end
