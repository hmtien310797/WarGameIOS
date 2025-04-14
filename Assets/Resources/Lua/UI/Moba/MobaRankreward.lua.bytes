module("MobaRankreward", package.seeall)
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
local _ui, LoadUI

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function CloseSelf()
    Global.CloseUI(_M)
end

function Hide()
	Global.CloseUI(_M)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui = nil
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.mask = transform:Find("mask").gameObject
    _ui.grid = transform:Find("Container/bg_frane/mid/bg/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.list_item = transform:Find("Container/bg_frane/mid/bg/list_mobarankreward")
    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.mask, CloseSelf)
    LoadUI()
end

local function IsGeted(index)
    for i, v in ipairs(_ui.info.reward.rewards) do
        if index == v then
            return true
        end
    end
    return false
end

local function UpdateItem(prefab, data)
    local stars = {}
    for i = 1, 5 do
        stars[i] = prefab:Find(string.format("right/stars/bg (%d)", i))
    end
    local rank_icon = prefab:Find("right/now"):GetComponent("UITexture")
    local rank_name = prefab:Find("right/rankname"):GetComponent("UILabel")
    local rank_bg = prefab:Find("bg/decorate"):GetComponent("UITexture")
    local btn = prefab:Find("claim").gameObject
    local conplete = prefab:Find("complete").gameObject
    
    btn:SetActive(data.id <= _ui.info.level and not IsGeted(data.id))
    SetClickCallback(btn, function()
        MobaData.RequestMobaGetReward(data.id, function()
            btn:SetActive(false)
            conplete:SetActive(true)
        end)
    end)
    conplete:SetActive(IsGeted(data.id))
    rank_bg.mainTexture = ResourceLibrary:GetIcon("Background/", data.Rankbg)
    local grid = prefab:Find("Label/Grid"):GetComponent("UIGrid")
    rank_icon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", data.RankIcon)
    rank_name.text = TextMgr:GetText(data.RankName)
    for i = 1, data.RankStar <= 5 and data.RankStar or 0 do
        stars[i].gameObject:SetActive(true)
        UIUtil.SetStarPos(rank_icon, stars[i], data.RankStar, i, 41, 33)
        stars[i].localScale = Vector3.one * 0.4
    end
    for i = (data.RankStar <= 5 and data.RankStar or 0) + 1, 5 do
        stars[i].gameObject:SetActive(false)
    end

    local reward = Global.MakeAward(data.RankReward)
    for i, v in ipairs(reward.heros) do
        local heroData = TableMgr:GetHeroData(v.id)
        local hero = NGUITools.AddChild(grid.gameObject, _ui.hero.gameObject).transform
        hero.localScale = Vector3(0.6, 0.6, 1) * 0.9
        hero:Find("level text").gameObject:SetActive(false)
        hero:Find("name text").gameObject:SetActive(false)
        hero:Find("bg_skill").gameObject:SetActive(false)
        hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
        hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
        local star = hero:Find("star"):GetComponent("UISprite")
        if star ~= nil then
            star.width = v.star * star.height
        end
        SetClickCallback(hero:Find("head icon").gameObject,function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)}) 
            end
        end)
    end
    for _, item in ipairs(reward.items) do
        local obj = UIUtil.AddItemToGrid(grid.gameObject, item)
        SetClickCallback(obj.gameObject,function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                local itemData = TableMgr:GetItemData(item.id)
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
            end
        end)
    end
    for ii, vv in ipairs(reward.armys) do
        local reward = vv
        local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
        local itemprefab = NGUITools.AddChild(grid.gameObject, _ui.item.gameObject).transform
        itemprefab.gameObject:SetActive(true)
        itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + reward.level)
        itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
        itemprefab:Find("have"):GetComponent("UILabel").text = reward.num
        itemprefab:Find("num").gameObject:SetActive(false)
        SetClickCallback(itemprefab.gameObject,function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)}) 
            end
        end)
    end
    grid:Reposition()
end

LoadUI = function()
    _ui.info = MobaData.GetMobaMatchInfo().info
    local rankData = TableMgr:GetMobaRankData()
    for i, v in ipairs(rankData) do
        local itemprefab = NGUITools.AddChild(_ui.grid.gameObject, _ui.list_item.gameObject).transform
        UpdateItem(itemprefab, v)
    end
    _ui.grid:Reposition()
end

function Show()
    Global.OpenUI(_M)
end