module("SellHeroItem", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local itemMsg
local itemData
local sellCount
local sellPrice
local currencyData

local _ui

function Hide()
    Global.CloseUI(_M)
end

local LoadSetUI
local function LoadItemUI()
    local item = _ui.item
    UIUtil.LoadHeroItem(item, itemData, itemMsg.number)
    item.countLabel2.text = itemMsg.number
    item.totalCountLabel.text = "/"..itemMsg.number
    item.descriptionLabel.text = TextUtil.GetItemDescription(itemData)
    _ui.setUI.slider.numberOfSteps = itemMsg.number + 1
end

LoadSetUI = function(setSlider)
    _ui.setUI.countLabel.text = sellCount
    if itemData.price ~= "NA" then
        _ui.setUI.priceLabel.text = sellCount * sellPrice
        _ui.setUI.sellLabel.text = TextMgr:GetText(Text.item_sell)
        _ui.setUI.currencyTexture.gameObject:SetActive(true)
        _ui.setUI.currencyTexture.mainTexture = ResourceLibrary:GetIcon("Item/", currencyData.icon)
    else
        _ui.setUI.priceLabel.text = "-"
        _ui.setUI.sellLabel.text = TextMgr:GetText(Text.item_cantsell)
        _ui.setUI.currencyTexture.gameObject:SetActive(false)
    end
    if setSlider then
        _ui.setUI.slider.value = sellCount / itemMsg.number
        _ui.setUI.slider:ForceUpdate()
    end
    _ui.setUI.btnSell.isEnabled = sellCount > 0 and itemData.price ~= "NA"
end

local function LoadUI()
    LoadItemUI()
    LoadSetUI(true)
end

local function RequestSell()
    local req = ItemMsg_pb.MsgSellItemRequest()
    req.uid = itemMsg.uniqueid
    req.num = sellCount
    Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgSellItemRequest, req, ItemMsg_pb.MsgSellItemResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            Global.ShowReward(msg.rewardInfo)
            MainCityUI.UpdateRewardData(msg.reward)
            Hide()
        end
    end)
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local item = {}
    local itemTransform = transform:Find("Container/item widget/listitem_hero_item")
    UIUtil.LoadHeroItemObject(item, itemTransform)
    _ui.item = item

    item.nameLabel = transform:Find("Container/item widget/item name"):GetComponent("UILabel")
    item.countLabel2 = transform:Find("Container/item widget/num"):GetComponent("UILabel")
    item.totalCountLabel = transform:Find("Container/bg2/frame_input/text_num"):GetComponent("UILabel")
    item.descriptionLabel = transform:Find("Container/item widget/des"):GetComponent("UILabel")
    local btnInput = transform:Find("Container/bg2/frame_input"):GetComponent("UIButton")
    SetClickCallback(btnInput.gameObject, function(go)
        NumberInput.Show(sellCount, 0, itemMsg.number, function(number)
            sellCount = number
            LoadSetUI(true)
        end)
    end)

    _ui.setUI = {}
    _ui.setUI.countLabel = transform:Find("Container/bg2/frame_input/title"):GetComponent("UILabel")
    _ui.setUI.slider = transform:Find("Container/bg2/bg_dissolution_time/bg_schedule/bg_slider"):GetComponent("UISlider")
    local btnMinus = transform:Find("Container/bg2/bg_dissolution_time/btn_minus"):GetComponent("UIButton")
    local btnAdd = transform:Find("Container/bg2/bg_dissolution_time/btn_add"):GetComponent("UIButton")
    _ui.setUI.priceLabel = transform:Find("Container/bg2/text_total/text_num"):GetComponent("UILabel")
    _ui.setUI.currencyTexture = transform:Find("Container/bg2/text_total/Texture"):GetComponent("UITexture")

    _ui.setUI.btnSell = transform:Find("Container/btn"):GetComponent("UIButton")
    _ui.setUI.sellLabel = transform:Find("Container/btn/text"):GetComponent("UILabel")

    SetClickCallback(btnMinus.gameObject, function(go)
        if sellCount > 0 then
            sellCount = sellCount - 1
            LoadSetUI(true)
        end
    end)

    SetClickCallback(btnAdd.gameObject, function(go)
        if sellCount < itemMsg.number then
            sellCount = sellCount + 1
            LoadSetUI(true)
        end
    end)

    SetClickCallback(mask.gameObject, function(go)
        Hide()
    end)
    EventDelegate.Set(_ui.setUI.slider.onChange, EventDelegate.Callback(function(go, value)
        sellCount = Mathf.Round(itemMsg.number * _ui.setUI.slider.value)
        LoadSetUI(false)
    end))
    SetClickCallback(_ui.setUI.btnSell.gameObject, function(go)
        if itemData.quality < 4 then
            RequestSell()
        else
            MessageBox.Show(TextMgr:GetText(Text.sell_item_confirm), function()
                RequestSell()
            end,
            function()
            end)
        end
    end)
end

function Close()
    _ui = nil
end

function Show(msg)
    print("item uid:", msg.uniqueid, "item table id:", msg.baseid)
    itemMsg = msg
    itemData = TableMgr:GetItemData(itemMsg.baseid)
    local priceList = string.split(itemData.price, ",")
    sellPrice = tonumber(priceList[2])
    currencyData = tableData_tItem.data[tonumber(priceList[1])]
    sellCount = 1
    Global.OpenUI(_M)
    LoadUI()
end
