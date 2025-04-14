module("TimedBag_Gold", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local iapGoodInfo

local ui

------- CONSTANTS -------
local MAX_ITEM_SHOW = 6
-------------------------

function IsInViewport()
    return ui ~= nil
end

function UpdateCountdown()
    ui.countdown.text = Global.SecondToTimeLong(iapGoodInfo.endTime - ui.lastUpdateTime)
end

function Redraw(notwait)
    if iapGoodInfo.endTime > ui.lastUpdateTime then
        UpdateCountdown()
    else
        Hide()
    end

    ui.name.text = TextMgr:GetText(iapGoodInfo.name)
    ui.icon.mainTexture = ResourceLibrary:GetIcon("pay/", iapGoodInfo.icon)
    ui.description.text = TextMgr:GetText(iapGoodInfo.desc)
    
    ui.discount.text = System.String.Format(TextMgr:GetText("ui_discount"), iapGoodInfo.discount)
    ui.originalPrice.text = Global.FormatNumber(iapGoodInfo.showPrice)

    ui.cashPrice.gameObject:SetActive(iapGoodInfo.priceType == 0)
    ui.actualGold.gameObject:SetActive(iapGoodInfo.priceType ~= 0)
    ui.actualPrice.gameObject:SetActive(iapGoodInfo.priceType ~= 0)
    if iapGoodInfo.priceType == 0 then
        ui.cashPrice.text = string.make_price(iapGoodInfo.price)
    else
        ui.actualPrice.text = iapGoodInfo.price
    end

    local items = iapGoodInfo.itemGift.item.item
    local numItems = #items
    local uiItems = ui.itemList.items
    for i = 1, math.max(numItems, #uiItems) do
        if i > numItems then
            uiItems[i].gameObject:SetActive(false)
        else
            if i > #uiItems then
                local uiItem = UIUtil.AddItemToGrid(ui.itemList.gameObject, items[i])

                UIUtil.SetClickCallback(uiItem.gameObject, function(go)
                    if go ~= ui.tooltip then
                        local itemData = uiItem.data
                        Tooltip.ShowItemTip({ name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData) })
                        ui.tooltip = uiItem.gameObject
                    else
                        Tooltip.HideItemTip()
                        ui.tooltip = nil
                    end
                end)

                table.insert(uiItems, uiItem)
            else
                uiItems[i].gameObject:SetActive(true)

                local item = items[i]
                UIUtil.LoadItem(uiItems[i], TableMgr:GetItemData(item.baseid), item.num)
            end
        end
    end

    ui.itemList.grid:Reposition()
    --ui.itemList.transform.localScale = Vector3(0.9, 0.9, 1) - Vector3(0.15, 0.15, 0) * math.max(0, numItems - 5)
end

function Show(_iapGoodInfo)
    GiftPackData.ExchangePrice(_iapGoodInfo)
    coroutine.start(function()
        local topMenu = GUIMgr:GetTopMenuOnRoot()
        local isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
		while topMenu == nil or topMenu.name ~= "MainCityUI" or isInGuide do
			coroutine.wait(0.5)
            topMenu = GUIMgr:GetTopMenuOnRoot()
            isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
		end
        if IsInViewport() then
            if _iapGoodInfo.id ~= iapGoodInfo.id then
                iapGoodInfo = _iapGoodInfo
                Redraw()
            end
        else
            iapGoodInfo = _iapGoodInfo
            Global.OpenUI(_M)
        end
    end)
end

function Hide()
    Global.CloseUI(_M)
end

local function OnUICameraClick(go)
    if go ~= ui.tooltip then
        Tooltip.HideItemTip()
        ui.tooltip = nil
    end
end

function Awake()
    ui = {}

    ui.name = transform:Find("container/name"):GetComponent("UILabel")
    ui.icon = transform:Find("container/icon"):GetComponent("UITexture")
    ui.description = transform:Find("container/description"):GetComponent("UILabel")

    ui.discount = transform:Find("container/discount/text"):GetComponent("UILabel")
    ui.originalPrice = transform:Find("container/bg_yuanjia/num"):GetComponent("UILabel")
    ui.actualPrice = transform:Find("container/btn_purchase/price"):GetComponent("UILabel")
    ui.actualGold = transform:Find("container/btn_purchase/Gold").gameObject
    ui.cashPrice = transform:Find("container/btn_purchase/price_cash"):GetComponent("UILabel")

    ui.countdown = transform:Find("container/countdown"):GetComponent("UILabel")

    ui.itemList = {}
    ui.itemList.transform = transform:Find("container/items/Scroll View/grid")
    ui.itemList.gameObject = ui.itemList.transform.gameObject
    ui.itemList.grid = ui.itemList.transform:GetComponent("UIGrid")
    ui.itemList.items = {}
    ui.discount = NGUITools.AddChild(ui.originalPrice.transform.parent.gameObject, ResourceLibrary.GetUIPrefab("Pay/Discount/Discount")).transform:Find("Num"):GetComponent("UILabel")
	ui.discount.transform.parent.localPosition = Vector3(55, 20, 0)
	ui.discount.transform.parent.localScale = Vector3(0.8, 0.6, 1)
    ui.discount.text = System.String.Format(TextMgr:GetText("ui_discount"), iapGoodInfo.discount)
    UIUtil.SetClickCallback(transform:Find("container/btn_close").gameObject, Hide)

    UIUtil.SetClickCallback(transform:Find("container/btn_purchase").gameObject, function()
        GiftPackData.BuyGiftPack(iapGoodInfo)
    end)

    EventDispatcher.Bind(GiftPackData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(_iapGoodInfo, change)
        if change < 0 and _iapGoodInfo.id == iapGoodInfo.id then
            Hide()
        end
    end)

    UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)
end

function Start()
    ui.lastUpdateTime = Serclimax.GameTime.GetSecTime()

    Redraw()
end

function Update()
    local now = Serclimax.GameTime.GetSecTime()

    if now ~= ui.lastUpdateTime then
        ui.lastUpdateTime = now
        UpdateCountdown()
    end
end

function Close()
    EventDispatcher.UnbindAll(_M)

    UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)

    iapGoodInfo = nil

    ui = nil
end

GiftPackData.RegisterPopupWindow(1, _M)
