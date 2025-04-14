module("HolidayActivity", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local Format = System.String.Format
local PlayerPrefs = UnityEngine.PlayerPrefs

local _ui = nil
local dataTableList = {}

function CloseSelf()
    Global.CloseUI(_M)
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    CloseSelf()
    DailyActivity.CloseSelf()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function LoadContent(exchangeData, itemTransform, heroTransform, nameLabel, descriptionLabel)
        local contentType = exchangeData.contentType
        local contentId = exchangeData.item
        itemTransform.gameObject:SetActive(contentType == 1)
        heroTransform.gameObject:SetActive(contentType == 3)
        if contentType == 1 then
            local item = {}
            UIUtil.LoadItemObject(item, itemTransform)
            local itemData = TableMgr:GetItemData(contentId)
            local itemCount = exchangeData.number
            UIUtil.LoadItem(item, itemData, itemCount)
            UIUtil.SetClickCallback(item.transform.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                end
            end)
            if nameLabel ~= nil then
                nameLabel.text = TextUtil.GetItemName(itemData)
            end
            if descriptionLabel ~= nil then
                descriptionLabel.text = TextUtil.GetItemDescription(itemData)
            end
        elseif contentType == 3 then
            local hero = {}
            HeroList.LoadHeroObject(hero, heroTransform)
            local heroData = TableMgr:GetHeroData(contentId)
            local heroMsg = Common_pb.HeroInfo() 
            heroMsg.star = exchangeData.Star
            heroMsg.level = exchangeData.Level
            heroMsg.num = exchangeData.number
            HeroList.LoadHero(hero, heroMsg, heroData)
            hero.nameLabel.gameObject:SetActive(false)

            SetClickCallback(hero.btn.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
                end
            end)
            if nameLabel ~= nil then
                nameLabel.text = TextMgr:GetText(heroData.nameLabel)
            end
            if descriptionLabel ~= nil then
                descriptionLabel.text = TextMgr:GetText(heroData.description)
            end
        end
end

local function RequestExchange(exchangeId, exchangeCount)
    local req = ActivityMsg_pb.MsgExchangeRequest()
    req.exchangeId = exchangeId
    req.exchangeCount = exchangeCount
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgExchangeRequest, req, ActivityMsg_pb.MsgExchangeResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.FloatError(msg.code)
        else
            _ui.exchange.gameObject:SetActive(false)
            Global.ShowReward(msg.reward)
            MainCityUI.UpdateRewardData(msg.fresh)
            ActivityExchangeData.UpdateExchangeCount(msg.exchangeId, msg.exchangeCount)
        end
    end, false)
end

local function UpdateTime()
    _ui.timerLabel.text = Format(TextMgr:GetText(Text.activity_content_35), Global.GetLeftCooldownTextLong(_ui.activityMsg.endTime))
end

local function LoadUI(reset)
	_ui.titleLabel.text = _ui.configs["title"] ~= nil and TextMgr:GetText(_ui.configs["title"]) or ""
    if _ui.configs["banner"] ~= nil then
        _ui.banner.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", _ui.configs["banner"])
    end
    local exchange = _ui.exchange
    local activityId = _ui.activityMsg.activityId
    if dataTableList[activityId] == nil then
        local dataTable = {}
        for _, v in pairs(ExchangeTableData.GetData().dataTable) do
            if v.ActivityID == activityId then
                table.insert(dataTable, v)
            end
        end

        table.sort(dataTable, function(v1, v2)
            return v1.Order < v2.Order
        end)
        dataTableList[activityId] = dataTable
    end

    local dataTable = dataTableList[activityId]
    for i, v in ipairs(dataTable) do
        local exchangeTransform
        if i > _ui.listGrid.transform.childCount then
            exchangeTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.exchangePrefab).transform
        else
            exchangeTransform = _ui.listGrid.transform:GetChild(i - 1)
        end
        exchangeTransform.gameObject:SetActive(true)

        local itemGrid = exchangeTransform:Find("bg/exchange/5"):GetComponent("UIGrid")
        local itemList = string.split(v.ExchangeItemID, ";")
        local hasEnoughItem = true
        for ii, vv in ipairs(itemList) do
            local itemIdList = string.split(vv, ":")
            local itemId = tonumber(itemIdList[1])
            local itemCount = tonumber(itemIdList[2])
            local itemData = TableMgr:GetItemData(itemId)
            local hasCount = 0
            if itemData.type == 1 then
                hasCount = MoneyListData.GetMoneyByType(itemData.id)
            else
                hasCount = ItemListData.GetItemCountByBaseId(itemId)
            end
            local hasCountText
            if hasCount >= itemCount then
                hasCountText = string.format("%d/%d", hasCount, itemCount)
            else
                hasCountText = string.format("[ff0000]%d[-]/%d", hasCount, itemCount)
                hasEnoughItem = false
            end
            local item = {}
            local itemTransform = itemGrid.transform:Find(string.format("Item_CommonNew (%d)", ii))
            UIUtil.LoadItemObject(item, itemTransform)
            UIUtil.LoadItem(item, itemData, itemCount)
            item.transform:Find("have (1)"):GetComponent("UILabel").text = hasCountText
            UIUtil.SetClickCallback(item.transform.gameObject, function(go)
                print("item id:", itemData.id)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                end
            end)
            itemTransform.gameObject:SetActive(true)
        end

        for ii = #itemList + 1, 4 do
            local itemTransform = itemGrid.transform:Find(string.format("Item_CommonNew (%d)", ii))
            itemTransform.gameObject:SetActive(false)
        end

        local itemTransform = itemGrid.transform:Find(string.format("Item_CommonNew (%d)", 5))
        local heroTransform = itemGrid.transform:Find("listitem_hero")
        LoadContent(v, itemTransform, heroTransform)
        itemGrid.repositionNow = true

        local exchangeMsg = ActivityExchangeData.GetExchangeMsg(activityId, v.id) 
        local exchangeButton = exchangeTransform:Find("button"):GetComponent("UIButton")
        local maxCount = exchangeMsg.maxCount
        local leftCount = maxCount - exchangeMsg.currentCount
        local vipLevel = MainData.GetVipLevel()
        UIUtil.SetBtnEnable(exchangeButton, "btn_1", "btn_4", hasEnoughItem and vipLevel >= v.VIP and leftCount > 0)
        SetClickCallback(exchangeButton.gameObject, function(go)
            if leftCount <= 0 then
                FloatText.Show(TextMgr:GetText(Text.holidayactivity_code3))
                return
            end

            if vipLevel < v.VIP then
                FloatText.Show(TextMgr:GetText(Text.holidayactivity_code2))
                return
            end

            if not hasEnoughItem then
                FloatText.Show(TextMgr:GetText(Text.holidayactivity_code1))
                return
            end

            exchange.gameObject:SetActive(true)
            NGUITools.BringForward(exchange.gameObject)
            LoadContent(v, exchange.itemTransform, exchange.heroTransform, exchange.nameLabel, exchange.descriptionLabel)
            UIUtil.LoadButtonSlider(exchange.slider, exchange.minusButton, exchange.addButton, 1, 1, leftCount, function(currentValue)
                exchange.countLabel.text = string.format("%d/%d", currentValue, leftCount)
            end)
            exchange.countLabel.text = string.format("%d/%d", 1, leftCount)
            SetClickCallback(exchange.exchangeButton.gameObject, function(go)
                local currentValue = Mathf.Round((leftCount - 1) * exchange.slider.value) + 1
                RequestExchange(v.id, currentValue)
            end)
        end)
        local limitLabel = exchangeTransform:Find("limit"):GetComponent("UILabel")
        local vipLabel = exchangeTransform:Find("VIP"):GetComponent("UILabel")
        local noticeToggle = exchangeTransform:Find("Alert/checkbox"):GetComponent("UIToggle")
        if reset then
            EventDelegate.Set(noticeToggle.onChange, EventDelegate.Callback(function()
                if _ui ~= nil then
                    PlayerPrefs.SetInt(string.format("ExchangeNotice_%d_%d", activityId, v.id), noticeToggle.value and 1 or 0)
                    DailyActivityData.ProcessActivity()
                end
            end))
        end
        noticeToggle.value = PlayerPrefs.GetInt(string.format("ExchangeNotice_%d_%d", activityId,  v.id), 1) == 1
        limitLabel.text = Format(TextMgr:GetText(Text.activity_content_77), exchangeMsg.currentCount, exchangeMsg.maxCount)
        vipLabel.gameObject:SetActive(v.VIP > 0)
        if v.VIP > 0 then
            vipLabel.text = Format(TextMgr:GetText(Text.activity_content_78), v.VIP)
        end
    end

    for i = #dataTable + 1, _ui.listGrid.transform.childCount do
        _ui.listGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.listGrid.repositionNow = true

    if reset then
        _ui.listScrollView:ResetPosition()
    end

    UpdateTime()
end

function Awake()
    _ui = {}
    _ui.containerObject = transform:Find("Container").gameObject
    SetClickCallback(_ui.containerObject, CloseAll)
    _ui.timerLabel = transform:Find("Container/bg_top/timer"):GetComponent("UILabel")
    _ui.titleLabel = transform:Find("Container/bg_top/Tittle"):GetComponent("UILabel")
    _ui.helpButton = transform:Find("Container/bg_top/Tittle/button_ins"):GetComponent("UIButton")
	_ui.banner = transform:Find("Container/content/banner"):GetComponent("UITexture")
	SetClickCallback(_ui.helpButton.gameObject, function()
		DailyActivityHelp.Show(_ui.configs["HelpTitle"], _ui.configs["HelpContent"])
	end)
    _ui.listScrollView = transform:Find("Container/content_activity/Scroll View"):GetComponent("UIScrollView") 
    _ui.listGrid = transform:Find("Container/content_activity/Scroll View/Grid"):GetComponent("UIGrid") 
    _ui.exchangePrefab = _ui.listGrid.transform:GetChild(0).gameObject
    
    local exchange = {}
    local exchangeTransform = transform:Find("Container/UseItem")
    exchange.gameObject = exchangeTransform.gameObject
    exchange.maskObject = exchangeTransform:Find("mask").gameObject
    exchange.closeObject = exchangeTransform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    SetClickCallback(exchange.closeObject, function(go)
        exchange.gameObject:SetActive(false)
    end)
    SetClickCallback(exchange.maskObject, function(go)
        exchange.gameObject:SetActive(false)
    end)
    exchange.itemTransform = exchangeTransform:Find("Container/bg_frane/Item_CommonNew")
    exchange.heroTransform = exchangeTransform:Find("Container/bg_frane/listitem_hero")
    exchange.nameLabel = exchangeTransform:Find("Container/bg_frane/txt_name"):GetComponent("UILabel")
    exchange.descriptionLabel = exchangeTransform:Find("Container/bg_frane/text_des"):GetComponent("UILabel")
    exchange.slider = exchangeTransform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/bg_schedule/bg_slider"):GetComponent("UISlider")
    exchange.minusButton = exchangeTransform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_minus"):GetComponent("UIButton")
    exchange.addButton = exchangeTransform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_add"):GetComponent("UIButton")
    exchange.countLabel = exchangeTransform:Find("Container/bg_frane/bg_bottom/frame_input/label"):GetComponent("UILabel")
    exchange.exchangeButton = exchangeTransform:Find("Container/bg_frane/btn_use"):GetComponent("UIButton")

    exchange.gameObject:SetActive(false)

    _ui.exchange = exchange

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)

    ActivityExchangeData.AddListener(LoadUI)
    ActivityExchangeData.AddListener(DailyActivityData.ProcessActivity)
    ItemListData.AddListener(LoadUI)

    _ui.timer = Timer.New(UpdateTime, 1, -1)
    _ui.timer:Start()
end

function Show(activityMsg)
    Global.OpenUI(_M)
    _ui.activityMsg = activityMsg
    local configid = ActivityData.GetActivityConfig(_ui.activityMsg.activityId).configid
	if configid == nil or configid == "" or configid == 0 then
		configid = _ui.activityMsg.activityId
	end
	_ui.configs = TableMgr:GetActivityShowCongfig(configid, _ui.activityMsg.templet)
    DailyActivityData.NotifyUIOpened(activityMsg.activityId)
    LoadUI(true)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)

    ActivityExchangeData.RemoveListener(LoadUI)
    ActivityExchangeData.RemoveListener(DailyActivityData.ProcessActivity)
    ItemListData.RemoveListener(LoadUI)

    Tooltip.HideItemTip()
    _ui.timer:Stop()
    _ui = nil
end
