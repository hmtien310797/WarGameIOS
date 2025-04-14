module("PVP_LuckyRotary_Select", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    JailTreat.Hide()
    Hide()
end

local LoadUI

local function LoadPrice(priceTransform, itemData, price, priceIndex)
    priceTransform:GetComponent("UITexture").priceTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
    priceTransform:Find("select/gou").gameObject:SetActive(priceIndex == _ui.priceIndex)
    priceTransform:Find("number"):GetComponent("UILabel").text = price
    priceTransform:Find("Sprite").gameObject:SetActive(priceIndex % 2 == 0)
    SetClickCallback(priceTransform.gameObject, function(go)
        _ui.priceIndex = priceIndex
        LoadUI()
    end)
end

function LoadUI()
    local priceIndex = 0
    priceTransform = _ui.priceGrid.transform:GetChild(priceIndex)
    local price = tableData_tWarCoinDrop.data[1].Price
    local itemIdList = string.split(price, ":")
    local itemId = tonumber(itemIdList[1])
    local itemCount = 0
    local itemData = TableMgr:GetItemData(itemId)
    LoadPrice(priceTransform, itemData, itemCount, priceIndex)
    priceIndex = priceIndex + 1

    for i, v in ipairs(tableData_tWarCoinDrop.data) do
        if v.Gear ~= 0 then
            local priceTransform
            if priceIndex + 1 > _ui.priceGrid.transform.childCount then
                priceTransform = NGUITools.AddChild(_ui.priceGrid.gameObject, _ui.pricePrefab)
            else
                priceTransform = _ui.priceGrid.transform:GetChild(priceIndex)
            end

            local itemIdList = string.split(v.Price, ":")
            local itemId = tonumber(itemIdList[1])
            local itemCount = tonumber(itemIdList[2])
            local itemData = TableMgr:GetItemData(itemId)
            LoadPrice(priceTransform, itemData, itemCount, priceIndex)

            priceTransform.gameObject:SetActive(true)
            priceIndex = priceIndex + 1
        end
    end
    for i = priceIndex + 1, _ui.priceGrid.transform.childCount do
        _ui.priceGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.priceGrid.repositionNow = true
    --UIUtil.ScrollTo(_ui.priceScrollView, _ui.priceIndex, priceIndex, _ui.priceHeight) 
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
    local confirmButton = transform:Find("Container/bg_frane/button"):GetComponent("UIButton")
    SetClickCallback(confirmButton.gameObject, function(go)
        _ui.closeCallback(_ui.priceIndex)
        Hide()
    end)

    _ui.priceScrollView = transform:Find("Container/bg_frane/mid/Scroll View"):GetComponent("UIScrollView")
    _ui.priceGrid = transform:Find("Container/bg_frane/mid/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.pricePrefab = transform:Find("Container/bg_frane/mid/Scroll View/Grid"):GetChild(0).gameObject
    _ui.priceHeight = _ui.pricePrefab:GetComponent("UIWidget").height

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui = nil
end

function Show(priceIndex, closeCallback)
    Global.OpenUI(_M)
    _ui.priceIndex = priceIndex
    _ui.closeCallback = closeCallback
    LoadUI()
end
