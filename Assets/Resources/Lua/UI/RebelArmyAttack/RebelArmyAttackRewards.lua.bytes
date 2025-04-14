module("RebelArmyAttackRewards", package.seeall)
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

local _ui

local function AddDepth(go, add)
	local widgets = go:GetComponentsInChildren(typeof(UIWidget))
	for i = 0, widgets.Length - 1 do
		widgets[i].depth = widgets[i].depth + add
	end
end

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

local function CloseSelf()
	Global.CloseUI(_M)
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/close btn").gameObject
	
	_ui.mypoints = transform:Find("Container/bg/bg_mid/mypoints"):GetComponent("UILabel")
	_ui.unionpoints = transform:Find("Container/bg/bg_mid/unionpoints"):GetComponent("UILabel")
	_ui.scrollview = transform:Find("Container/bg/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/bg/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.listitem = transform:Find("listitem_RebelArmyWanted")
	_ui.tips = transform:Find("Container/bg/tips").gameObject
	
	_ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	
	local num_item = _ui.item.transform:Find("have"):GetComponent("UILabel")
	local num_hero = _ui.hero.transform:Find("num"):GetComponent("UILabel")
	num_hero.trueTypeFont = num_item.trueTypeFont
	num_hero.fontSize = num_item.fontSize
	num_hero.applyGradient = num_item.applyGradient
	num_hero.gradientTop = num_item.gradientTop
	num_hero.gradientBottom = num_item.gradientBottom
	num_hero.spacingX = num_item.spacingX
	num_hero.transform.localScale = Vector3(1.6, 1.6, 1)
	num_hero.transform.localPosition = Vector3(50, -46, 0)
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	
	_ui.mypoints.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui21"), _ui.msg.score)
	_ui.unionpoints.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui22"), _ui.msg.guildScore)
	local rewards = RebelArmyAttackData.GetRewardData(_ui.siegeNumber)
	local complete = 0
	for i, v in ipairs(rewards) do
		local prefab = NGUITools.AddChild(_ui.grid.gameObject, _ui.listitem.gameObject).transform
		prefab.transform:Find("bg/name"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("RebelArmyAttack_ui20"), i)
		prefab.transform:Find("bg/text"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("RebelArmyAttack_ui21"), "[" .. (_ui.msg.score >= v.personalScore and "00FF00" or "FF0000") .. "]" .. v.personalScore .. "[-]")
		prefab.transform:Find("bg/text (1)"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("RebelArmyAttack_ui22"), "[" .. (_ui.msg.guildScore >= v.unionScore and "00FF00" or "FF0000") .. "]" .. v.unionScore .. "[-]")
		prefab.transform:Find("complete").gameObject:SetActive(false)
		if _ui.msg.score >= v.personalScore and _ui.msg.guildScore >= v.unionScore then
			complete = i
		end
		prefab.transform:Find("bg"):GetComponent("UISprite").enabled = (i % 2 == 1)
		local grid = prefab.transform:Find("reward/Grid"):GetComponent("UIGrid")
		local childCount = grid.transform.childCount
		for ii = 0, childCount - 1 do
	        GameObject.Destroy(grid.transform:GetChild(ii).gameObject)
	    end
		for ii, vv in ipairs(v.awardlist) do
			if vv.contentType == 1 then
		    	local itemdata = TableMgr:GetItemData(vv.contentId)
				local item = NGUITools.AddChild(grid.gameObject, _ui.item.gameObject).transform
				item.localScale = Vector3.one
				item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
				local num_item = item:Find("have")
				if vv.contentNumber ~= nil and vv.contentNumber > 1 then
					num_item.gameObject:SetActive(true)
					num_item:GetComponent("UILabel").text = vv.contentNumber
				else
					num_item.gameObject:SetActive(false)
				end
				item:GetComponent("UISprite").spriteName = "bg_item" .. itemdata.quality
				local itemlvTrf = item.transform:Find("num")
				local itemlv = itemlvTrf:GetComponent("UILabel")
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
				SetParameter(item.gameObject, "item_" .. vv.contentId)
				AddDepth(item.gameObject, 100)	
		    elseif vv.contentType == 3 then
		    	local heroData = TableMgr:GetHeroData(vv.contentId)
				local hero = NGUITools.AddChild(grid.gameObject, _ui.hero.gameObject).transform
				hero.localScale = Vector3(0.6, 0.6, 1)
				hero:Find("level text").gameObject:SetActive(false)
				hero:Find("name text").gameObject:SetActive(false)
				hero:Find("bg_skill").gameObject:SetActive(false)
				hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
				hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
				local star = hero:Find("star"):GetComponent("UISprite")
				if star ~= nil then
			        star.width = vv.star * star.height
			    end
			    local num = hero:Find("num"):GetComponent("UILabel")
			    num.gameObject:SetActive(true)
			    num.text = vv.contentNumber
				SetParameter(hero:Find("head icon").gameObject, "hero_" .. vv.contentId)
				AddDepth(hero.gameObject, 100)	
		    end
		end
		grid:Reposition()
	end
	_ui.grid:Reposition()
	_ui.scrollview:ResetPosition()
	if complete > 0 then
		_ui.grid.transform:GetChild(complete - 1):Find("complete").gameObject:SetActive(true)
	end
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Show(siegeNumber)
	RebelArmyAttackData.RequestSiegeMonsterScoreInfo(function(msg)
		if _ui == nil then
			_ui = {}
		end
		_ui.siegeNumber = siegeNumber
		_ui.msg = msg
		if msg.code == ReturnCode_pb.Code_OK then
			Global.OpenUI(_M)
		else
			Global.ShowError(msg.code)
		end
	end)
end
