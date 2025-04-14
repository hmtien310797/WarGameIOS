module("SupplyCollectRewards", package.seeall)
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
local Format = System.String.Format

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

function CloseSelf()
    _ui = nil
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	Global.CloseUI(_M)
end

function Awake()
	_ui.container = transform:Find("Container").gameObject
    _ui.btn_close = transform:Find("Container/close btn").gameObject
    _ui.scroll = transform:Find("Container/bg/bg_mid/Scroll View"):GetComponent("UIScrollView")
    _ui.grid = transform:Find("Container/bg/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.prefab = ResourceLibrary.GetUIPrefab("ActivityStage/listitem_Supplyrewards")

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
    SetClickCallback(_ui.btn_close, CloseSelf)
    local showdata = TableMgr:GetSupplyCollectRankShowByActivity(_ui.activityid)
    for i, v in ipairs(showdata) do
        local prefab = NGUITools.AddChild(_ui.grid.gameObject, _ui.prefab.gameObject).transform
        prefab:Find("bg/name"):GetComponent("UILabel").text = Format(TextMgr:GetText("Armrace_29"), v.range)
        local award = TableMgr:GetDropShowData(v.award)
        local grid = prefab:Find("reward/Grid"):GetComponent("UIGrid")
        for ii, vv in ipairs(award) do
            if vv.contentType == 1 then
                local itemtrans = NGUITools.AddChild(grid.gameObject, _ui.item.gameObject).transform
                local itemData = TableMgr:GetItemData(vv.contentId)
                local item = {}
                UIUtil.LoadItemObject(item, itemtrans)
                UIUtil.LoadItem(item, itemData, vv.contentNumber)
                SetParameter(itemtrans.gameObject, "item_" .. vv.contentId)
            elseif vv.contentType == 3 then
                local herotrans = NGUITools.AddChild(grid.gameObject, _ui.hero.gameObject).transform
                herotrans.localScale = Vector3(0.6,0.6,1)
                local heroData = TableMgr:GetHeroData(vv.contentId)
                herotrans:Find("level text").gameObject:SetActive(false)
				herotrans:Find("name text").gameObject:SetActive(false)
				herotrans:Find("bg_skill").gameObject:SetActive(false)
				herotrans:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
				herotrans:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
				local star =herotrans:Find("star"):GetComponent("UISprite")
				if star ~= nil then
			        star.width = vv.star * star.height
			    end
			    local num = herotrans:Find("num"):GetComponent("UILabel")
			    num.gameObject:SetActive(true)
			    num.text = vv.contentNumber
				SetParameter(herotrans:Find("head icon").gameObject, "hero_" .. vv.contentId)
            end
        end
        grid:Reposition()
    end
    _ui.grid:Reposition()
end

function Show(activityid)
	_ui = {}
	_ui.activityid = activityid
	Global.OpenUI(_M)
end
