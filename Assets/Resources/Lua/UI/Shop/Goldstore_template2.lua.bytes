module("Goldstore_template2", package.seeall)

local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local GUIMgr = Global.GGUIMgr

local items = {}
local lastRequest = {}

local ui
local currentIndex

local BUFFERED_DATA_TIMEOUT = 60

function IsInViewport()
    return ui ~= nil
end

local function OnUICameraClick(go)
    Tooltip.HideItemTip()
end

local function SetCurrentIndex(index)
    currentIndex = index
end

local function UpdateItemQuantity(uiItem)
    uiItem.quantity.text = ItemListData.GetItemCountByBaseId(uiItem.shopItemInfo.baseId)
end

local function UpdateItem(uiItem, shopItemInfo)
    local itemData = TableMgr:GetItemData(shopItemInfo.baseId)
    local exchangeData = TableMgr:GetItemExchangeData(shopItemInfo.exchangeId)

    uiItem.shopItemInfo = shopItemInfo
    uiItem.itemData = itemData
    uiItem.exchangeData = exchangeData

    uiItem.gameObject.name = 10000 + shopItemInfo.orderId

    local name = TextUtil.GetItemName(itemData)
    if exchangeData and exchangeData.number > 1 then
        name = name .. " x" .. exchangeData.number
    end

    uiItem.name.text = name
    uiItem.price.text = shopItemInfo.price

    UpdateItemQuantity(uiItem)

    UIUtil.LoadItem(uiItem.icon, itemData)

    if not ui.showcase.itemList.itemsByBaseID[shopItemInfo.baseId] then
        ui.showcase.itemList.itemsByBaseID[shopItemInfo.baseId] = {}
    end

    table.insert(ui.showcase.itemList.itemsByBaseID[shopItemInfo.baseId], uiItem)
end

local function AddItem(shopItemInfo)
    local uiItem = {}

    uiItem.gameObject = NGUITools.AddChild(ui.showcase.itemList.gameObject, ui.showcase.itemList.newItem)
    uiItem.transform = uiItem.gameObject.transform

    uiItem.name = uiItem.transform:Find("Name"):GetComponent("UILabel")
    uiItem.quantity = uiItem.transform:Find("Quantity/Num"):GetComponent("UILabel")
    uiItem.price = uiItem.transform:Find("Purchase Button/Price/Num"):GetComponent("UILabel")
    uiItem.icon = UIUtil.LoadItemObject({}, uiItem.transform:Find("Icon"))

    UpdateItem(uiItem, shopItemInfo)
    
    table.insert(ui.showcase.itemList.itemsByOrder, uiItem)

    UIUtil.SetClickCallback(uiItem.transform:Find("Purchase Button").gameObject, function()
        UseItem.InitShop(uiItem.shopItemInfo)
        UseItem.SetUseCallBack(function(num)
            ShopItemData.BuyItem(uiItem.shopItemInfo, num, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    if IsInViewport() then
                        for _, uiItem in ipairs(ui.showcase.itemList.itemsByBaseID[uiItem.shopItemInfo.baseId]) do
                            UpdateItemQuantity(uiItem)
                        end
                    end
                end
            end)
        end)

        GUIMgr:CreateMenu("UseItem" , false)
    end)

    UIUtil.SetClickCallback(uiItem.icon.gameObject, function()
        if ui.tooltip ~= uiItem then
            ui.tooltip = uiItem
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(uiItem.itemData), text = TextUtil.GetItemDescription(uiItem.itemData)})
        else
            ui.tooltip = nil
        end
    end)
end

local function LocateItem(baseID)
    local uiItem = ui.showcase.itemList.itemsByBaseID[baseID][1]
    if uiItem then
        ui.showcase.itemList.scrollView:ResetPosition()

        local row = -uiItem.transform.localPosition.y / ui.showcase.itemList.cellHeight
        local numRow = math.ceil(ui.showcase.itemList.numShopItemInfos / 3)

        if numRow - row < 2 then
            ui.showcase.itemList.scrollView:MoveRelative(Vector3(0, numRow * ui.showcase.itemList.cellHeight - ui.showcase.height + ui.showcase.padding, 0))
        elseif row > 2 then
            ui.showcase.itemList.scrollView:MoveRelative(Vector3(0, (row - 1.5) * ui.showcase.itemList.cellHeight, 0))
        end
    end
end

local function UpdateShowcase(index, baseID)
    coroutine.stop(ui.coroutine)
    ui.coroutine = coroutine.start(function()
        if index == currentIndex then
            ui.showcase.itemList.scrollView.enabled = false
            
            for i = 1, #ui.showcase.itemList.itemsByOrder do
                ui.showcase.itemList.itemsByOrder[i].gameObject:SetActive(false)
            end

            local shopItemInfos = items[index]
            local uiItems = ui.showcase.itemList.itemsByOrder
            local numShopItemInfos = #shopItemInfos

            ui.showcase.itemList.itemsByBaseID = {}
            ui.showcase.itemList.numShopItemInfos = numShopItemInfos

            local hasResetedPosition = false

            for i = 1, math.max(numShopItemInfos, #uiItems) do
                if i > numShopItemInfos then
                    uiItems[i].gameObject:SetActive(false)
                else
                    if i > #uiItems then
                        AddItem(shopItemInfos[i])
                    else
                        uiItems[i].gameObject:SetActive(true)
                        UpdateItem(uiItems[i], shopItemInfos[i])
                    end
                end

                if i >= 9 and i % 3 == 0 then
                    ui.showcase.itemList.grid.repositionNow = true

                    if not hasResetedPosition then
                        ui.showcase.itemList.scrollView.enabled = true
                        ui.showcase.itemList.scrollView:ResetPosition()
                        ui.showcase.itemList.scrollView.enabled = false

                        hasResetedPosition = true
                    end

                    coroutine.step()
                end
            end
            ui.showcase.itemList.grid:Reposition()

            if numShopItemInfos > 6 then
                ui.showcase.itemList.scrollView.enabled = true
                
                if baseID then
                    LocateItem(baseID)
                elseif not hasResetedPosition then
                    ui.showcase.itemList.scrollView:ResetPosition()
                end
            else
                ui.showcase.itemList.scrollView.enabled = true
                ui.showcase.itemList.scrollView:ResetPosition()
                ui.showcase.itemList.scrollView.enabled = false
            end
        end
    end)
end

local function ShowTab(index, baseID)
    if index and index ~= currentIndex then
        SetCurrentIndex(index)

        ui.tabList.tabs[index].toggle.value = true

        local now = Serclimax.GameTime.GetSecTime()
        if not lastRequest[index] or lastRequest[index] - now > BUFFERED_DATA_TIMEOUT then
            local uiBeforeRequest = ui
            ShopItemData.RequestData(index, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    table.sort(msg.item, function(itemA, itemB)
                        return itemA.orderId < itemB.orderId
                    end)

                    items[msg.index] = msg.item
                    lastRequest[index] = now

                    if ui == uiBeforeRequest then
                        UpdateShowcase(index, baseID)
                    end
                end
            end)
        else
            UpdateShowcase(index, baseID)
        end        
    elseif baseID then
        LocateItem(baseID)
    end
end

function Show(_, index, baseID)
    if not IsInViewport() then
        Global.OpenUI(_M)
        
        if not index then
            index = 1
        end
    end

    ShowTab(index, baseID)
end

function HideAll()
    Goldstore.Hide()
end

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    local tabList = {}
    tabList.tabs = {}
    for i = 1, 4 do
        local tab = {}

        tab.transform = transform:Find("Container/Top Bar"):GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.toggle = tab.transform:GetComponent("UIToggle")

        tabList.tabs[i] = tab

        UIUtil.SetClickCallback(tab.gameObject, function()
            ShowTab(i)
        end)
    end

    local showcase = {}

    showcase.itemList = UIUtil.LoadList(transform:Find("Container/Showcase"))
    showcase.itemList.newItem = transform:Find("Container/New Item").gameObject
    showcase.itemList.cellHeight = showcase.itemList.grid.cellHeight
    showcase.itemList.itemsByBaseID = {}
    showcase.itemList.itemsByOrder = {}

    showcase.height = showcase.itemList.panel.height
    showcase.padding = showcase.itemList.panel.clipSoftness.y

    showcase.itemList.panel:Update()

    ui = {}
    
    ui.tabList = tabList
    ui.showcase = showcase

    UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)
end

function Start()
end

function Close()
    coroutine.stop(ui.coroutine)

    UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)

    -- EventDispatcher.UnbindAll(_M)

    ui = nil
    currentIndex = nil
end

----- Template:Goldstore -----------
Goldstore.RegisterAsTemplate(2, _M)
------------------------------------
