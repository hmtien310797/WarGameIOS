module("store_template2", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

----- Event ----------------------------------------------------
local eventOnNoticeStatusChange = EventDispatcher.CreateEvent()

function OnNoticeStatusChange()
    return eventOnNoticeStatusChange
end

local function BroadcastEventOnNoticeStatusChange(...)
    EventDispatcher.Broadcast(eventOnNoticeStatusChange, ...)
end
----------------------------------------------------------------

----- Data --------
local items
local platformType
-------------------

----- UI ------------------
local ui
local isInViewport = false
---------------------------

function IsInViewport()
    return isInViewport
end

local function LoadUI()
    if ui == nil then
        ui = {}

        ui.itemList = {}
        ui.itemList.items = {}
        ui.itemList.transform = transform:Find("Container/itemList/grid")
        ui.itemList.gameObject = ui.itemList.transform.gameObject
        ui.itemList.grid = ui.itemList.transform:GetComponent("UIGrid")

        ui.newItem = transform:Find("Container/newItem").gameObject

        ui.vip = VipWidget(transform:Find("Container/bg_vip"))
    end
end

local function UpdateVip()
    ui.vip:Update()
    ui.vip.gameObject:SetActive(true)
    print("***** IS Click !!! ******")
end

local function UpdateUI(id)
    if id == nil then
        for id, _ in pairs(items) do
            UpdateUI(id)
        end
        ui.itemList.grid:Reposition()
    else
        local item = items[id]

        local uiItem = ui.itemList.items[id]
        if uiItem == nil then
            uiItem = {}
            uiItem.gameObject = NGUITools.AddChild(ui.itemList.gameObject, ui.newItem)
            uiItem.transform = uiItem.gameObject.transform

            uiItem.bonus = {}
            uiItem.bonus.transform = uiItem.transform:Find("1stBonus")
            uiItem.bonus.gameObject = uiItem.bonus.transform.gameObject
            uiItem.bonus.label = uiItem.bonus.transform:Find("Label"):GetComponent("UILabel")

            uiItem.icon = uiItem.transform:Find("icon"):GetComponent("UITexture")
            
            uiItem.name = uiItem.transform:Find("name"):GetComponent("UILabel")
            uiItem.num_gold = uiItem.transform:Find("gold/num"):GetComponent("UILabel")

            uiItem.num_bonusGold = {}
            uiItem.num_bonusGold.transform = uiItem.transform:Find("gold/num_bonus")
            uiItem.num_bonusGold.gameObject = uiItem.num_bonusGold.transform.gameObject
            uiItem.num_bonusGold.label = uiItem.num_bonusGold.transform:GetComponent("UILabel")

            uiItem.price = uiItem.transform:Find("btn_purchase/price"):GetComponent("UILabel")
            uiItem.vipExp = uiItem.transform:Find("vipExp"):GetComponent("UILabel")
        
            UIUtil.SetClickCallback(uiItem.transform:Find("btn_purchase").gameObject, function()
                store.StartPay(item, TextMgr:GetText(item.name))
            end)
            ui.vip.gameObject:SetActive(true)
            print("***** IS Click !!! ******")

            uiItem.gameObject.name = 10000 + item.order

            ui.itemList.items[id] = uiItem

            uiItem.icon.mainTexture = ResourceLibrary:GetIcon("pay/", item.icon)
            uiItem.name.text = TextMgr:GetText(item.name)

            if platformType == LoginMsg_pb.AccType_adr_huawei then
                uiItem.price.text = "SGD$" .. item.price
            elseif platformType == LoginMsg_pb.AccType_adr_tmgp or
            Global.IsIosMuzhi() or
            platformType == LoginMsg_pb.AccType_adr_muzhi or
            platformType == LoginMsg_pb.AccType_adr_opgame or
            platformType == LoginMsg_pb.AccType_adr_mango or
            platformType == LoginMsg_pb.AccType_adr_official or
            platformType == LoginMsg_pb.AccType_ios_official or
            platformType == LoginMsg_pb.AccType_adr_official_branch or
            platformType == LoginMsg_pb.AccType_adr_quick or
            platformType == LoginMsg_pb.AccType_adr_qihu then
                uiItem.price.text = "RMB￥" .. item.price
            else
                uiItem.price.text = "US$" .. item.price
            end
        end

        uiItem.num_gold.text = Global.FormatNumber(item.itemBuy.item.item[1].num)

        if not item.hasBuy then
            uiItem.bonus.gameObject:SetActive(true)
            uiItem.num_bonusGold.gameObject:SetActive(true)

            uiItem.num_bonusGold.label.text = TextMgr:GetText("FirstPurchaseText4") .. "+" .. Global.FormatNumber(item.itemBuy.item.item[1].num)
        else
            local bonusGold = item.itemExtra.item.item[1]
            if bonusGold then
                uiItem.bonus.gameObject:SetActive(false)
                uiItem.num_bonusGold.gameObject:SetActive(true)

                uiItem.num_bonusGold.label.text = TextMgr:GetText("FirstPurchaseText5") .. "+" .. bonusGold.num
            else
                uiItem.bonus.gameObject:SetActive(false)
                uiItem.num_bonusGold.gameObject:SetActive(false)
            end
        end

        uiItem.vipExp.text = System.String.Format(TextMgr:GetText("recharge_ui3"), Global.FormatNumber(item.itemGift.item.item[1].num))
    end

    UpdateVip()
end

function SuccessfullyPurchase(id)
    if isInViewport and items[id] then
        items[id].hasBuy = true
        UpdateUI(id)
    end
end

function Show()
    if not isInViewport then
        local request = ShopMsg_pb.MsgIAPGoodInfoRequest()
        request.type = 1
        
        Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPGoodInfoRequest, request, ShopMsg_pb.MsgIAPGoodInfoResponse, function(msg)
            if isInViewport then
                items = {}

                for _, iapGoodInfo in ipairs(msg.goodInfos) do
                    GiftPackData.ExchangePrice(iapGoodInfo)
                    items[iapGoodInfo.id] = iapGoodInfo
                end

                UpdateUI()
            end
        end)

        platformType = GUIMgr:GetPlatformType()

        Global.OpenUI(_M)
    end
end

function HideAll()
    Goldstore.Hide()
end

function Hide()
    if isInViewport then
        Global.CloseUI(_M)
    end
end

function Start()
    isInViewport = true

    LoadUI()

    MainData.AddListener(UpdateVip)
end

function Close()
    isInViewport = false

    MainData.RemoveListener(UpdateVip)

    items = nil
    platformType = nil

    ui = nil
end

----- Template:Goldstore -------------------------------
function HasNotice(config)
    return VipData.GetLoginInfo().pop
end

VipData.AddListener(BroadcastEventOnNoticeStatusChange)

Goldstore.RegisterAsTemplate(5, _M)
--------------------------------------------------------
