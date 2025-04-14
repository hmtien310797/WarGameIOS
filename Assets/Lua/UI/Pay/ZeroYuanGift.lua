module("ZeroYuanGift", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local GameObject = UnityEngine.GameObject

local _ui

function Hide()
    Global.CloseUI(_M)
end

local function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

local function OnUICameraDrag(go, delta)
	Tooltip.HideItemTip()
end

local ShowRewards = function(hero, item, army, grid)
    while grid.transform.childCount > 0 do
        UnityEngine.GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
    end
    if hero then
        for i, v in ipairs(hero) do
            local heroData = TableMgr:GetHeroData(v.baseid)
            local hero = NGUITools.AddChild(grid.gameObject, _ui.hero.gameObject).transform
            hero:Find("level text").gameObject:SetActive(false)
            hero:Find("name text").gameObject:SetActive(false)
            hero:Find("bg_skill").gameObject:SetActive(false)
            hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
            hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
            local star = hero:Find("star"):GetComponent("UISprite")
            if star ~= nil then
                star.width = v.star * star.height
            end
            UIUtil.SetClickCallback(hero:Find("head icon").gameObject,function(go)
                if go ~= _ui.tooltip then
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)}) 
                    _ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    _ui.tooltip = nil
                end
            end)
        end
    end
    if item then
        for _, item in ipairs(item) do
            local obj = UIUtil.AddItemToGrid(grid.gameObject, item)
            obj.transform.localScale = Vector3(1.75, 1.75, 1)
            UIUtil.SetClickCallback(obj.gameObject,function(go)
                if go ~= _ui.tooltip then
                    local itemData = TableMgr:GetItemData(item.baseid)
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
                    _ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    _ui.tooltip = nil
                end
            end)
        end
    end
    if army then
        for i, v in ipairs(army) do
            local soldierData = TableMgr:GetBarrackData(v.baseid, v.level)
            local itemprefab = NGUITools.AddChild(grid.gameObject, _ui.item.gameObject).transform
            itemprefab.gameObject:SetActive(true)
            itemprefab.localScale = Vector3(1.75, 1.75, 1)
            itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + v.level)
            itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
            itemprefab:Find("have"):GetComponent("UILabel").text = v.num
            itemprefab:Find("num").gameObject:SetActive(false)
            UIUtil.SetClickCallback(itemprefab.gameObject,function(go)
                if go ~= _ui.tooltip then
                    Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)}) 
                    _ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    _ui.tooltip = nil
                end
            end)
        end
    end
    grid.repositionNow = true
end

local function UpdateUI()
    _ui.countdown = {}
    local childcount = _ui.grid.transform.childCount
    for i, v in ipairs(GiftPackData.GetZeroGift()) do
        GiftPackData.ExchangePrice(v)
        local giftItem
        if i - 1 < childcount then
			giftItem = _ui.grid.transform:GetChild(i - 1)
		else
            giftItem = NGUITools.AddChild(_ui.grid.gameObject, _ui.giftItem.gameObject).transform
        end
        giftItem.gameObject:SetActive(true)
        giftItem:Find("Top/Name"):GetComponent("UILabel").text = TextMgr:GetText(v.topName)

        giftItem:Find("Original Price/Gold/Num"):GetComponent("UILabel").text = v.showPrice
        giftItem:Find("Buy Button/Gold/Num"):GetComponent("UILabel").text = v.price
        giftItem:Find("GoldBack/Gold/Num"):GetComponent("UILabel").text = v.itemGift.item.item[1].num
        giftItem:Find("GoldBack/title"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_Gift_0yuan_2"), v.day)
        local countdown = {}
        countdown.go = giftItem:Find("Countdown").gameObject
        countdown.label = giftItem:Find("Countdown/Time"):GetComponent("UILabel")
        countdown.time = v.endTime
        countdown.go:SetActive(countdown.time > 0)
        table.insert(_ui.countdown, countdown)
        local btn_buy = giftItem:Find("Buy Button").gameObject
        giftItem:Find("Sold Out Mask").gameObject:SetActive(countdown.time <= 0 or v.hasBuy)
        SetClickCallback(btn_buy, function()
            GiftPackData.BuyGiftPack(v)
        end)
        ShowRewards(v.itemOther.hero.hero, v.itemOther.item.item, v.itemOther.army.army, giftItem:Find("GiftItem/Scroll View/Grid"):GetComponent("UIGrid"))
    end
    for i = #GiftPackData.GetZeroGift(), childcount - 1 do
        UnityEngine.GameObject.DestroyImmediate(_ui.grid.transform:GetChild(i).gameObject)
    end
    _ui.timer = 1
    _ui.grid.repositionNow = true
end

function Update()
    _ui.timer = _ui.timer == nil and 0 or _ui.timer + Time.deltaTime
    if _ui.timer < 1 then
        return
    else
        _ui.timer = _ui.timer - 1
    end
    local lefttime
    for i, v in ipairs(_ui.countdown) do
        v.label.text, lefttime = Global.GetLeftCooldownTextLong(v.time)
        v.go:SetActive(lefttime > 0)
    end
end

function Awake()
    _ui = {}
    _ui.countdown = {}
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.mask = transform:Find("Container").gameObject
    _ui.grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.giftItem = transform:Find("New Gift Pack")
    _ui.giftItem.gameObject:SetActive(false)

    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDrag", OnUICameraDrag)
    EventDispatcher.Bind(GiftPackData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(iapGoodInfo, change) UpdateUI() end)
end

function Start()
    SetClickCallback(_ui.btn_close, Hide)
    SetClickCallback(_ui.mask, Hide)
    UpdateUI()
end

function Close()
    EventDispatcher.UnbindAll(_M)
    Tooltip.HideItemTip()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
	RemoveDelegate(UICamera, "onDrag", OnUICameraDrag)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end