module("QuickUseItem", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
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

local exchangeDataList
local itemData
local useCallback
local CheckBuy = true

local _ui

function Hide()
    Global.CloseUI(_M)
end


local function LoadUI()
    UIUtil.LoadItem(_ui.item, itemData)
    _ui.descriptionLabel.text = TextUtil.GetItemDescription(itemData)
    local itemId = itemData.id
    local itemMsg = ItemListData.GetItemDataByBaseId(itemId)
	
	if Global.GetMobaMode() == 1 then
		itemMsg = MobaPackageItemData.GetItemDataByUid(itemId)
		local itemCount = itemMsg ~= nil and itemMsg.number or 0
		_ui.countLabel.text = String.Format(TextMgr:GetText(Text.ui_worldmap_70), itemCount)
		local itemdata = MobaItemData.GetItemDataByBaseId(itemId)
		local canBuy = false
		if itemMsg == nil and itemdata~= nil then 
			_ui.priceLabel.text = itemdata.needScore
			canBuy = true
		end 

		_ui.useButton.gameObject:SetActive(itemCount > 0)
		_ui.buyButton.gameObject:SetActive(itemCount == 0 and canBuy)

		SetClickCallback(_ui.useButton.gameObject, function()
			Hide()
			useCallback(false)
		end)

		SetClickCallback(_ui.buyButton.gameObject, function()
			if CheckBuy == true then
				if MobaMainData.GetData().data.mobaScore >= itemdata.needScore  then 
					Hide()
					useCallback(true)
				else
					local tip = System.String.Format(TextMgr:GetText(Text.ui_moba_45), itemdata.needGold)
					MessageBox.Show(tip, function() 
						Hide()
						useCallback(true)
					end, function() end)
				end
			else
				Hide()
				useCallback(true)
			end 
		end)
		_ui.buyButtonBg.spriteName ="mobastore_1"
	elseif Global.GetMobaMode() == 2 then
		
		local price = 0
		local shopItem = TableMgr:GetGuildWarShopDataByID(itemId)
		
		if shopItem == nil then 
			local itemCount = itemMsg ~= nil and itemMsg.number or 0
			_ui.countLabel.text = String.Format(TextMgr:GetText(Text.ui_worldmap_70), itemCount)
			
			if exchangeDataList == nil then
				exchangeDataList = TableMgr:GetItemExchangeList()
			end

			local canBuy = false
			local price = 0
			for i, v in pairs(exchangeDataList) do
				local exchangeData = exchangeDataList[i]
				if exchangeData.item == itemId and exchangeData.number == 1 and exchangeData.moneyType == 2 then
					canBuy = true
					_ui.priceLabel.text = exchangeData.price
					price = exchangeData.price
					break
				end
			end
			
			_ui.useButton.gameObject:SetActive(itemCount > 0)
			_ui.buyButton.gameObject:SetActive(itemCount == 0 and canBuy)

			SetClickCallback(_ui.useButton.gameObject, function()
				Hide()
				useCallback(false)
			end)

			SetClickCallback(_ui.buyButton.gameObject, function()
				if MoneyListData.GetDiamond() < price then
					Global.ShowNoEnoughMoney()
				else
					Hide()
					useCallback(true)
				end
			end)
			_ui.buyButtonBg.spriteName ="icon_gold"
		
		else
		
			itemMsg = MobaPackageItemData.GetItemDataByUid(itemId)
			local itemCount = itemMsg ~= nil and itemMsg.number or 0
			_ui.countLabel.text = String.Format(TextMgr:GetText(Text.ui_worldmap_70), itemCount)
			local itemdata = MobaItemData.GetItemDataByBaseId(itemId)
			local canBuy = true
			if itemMsg == nil and itemdata~= nil then 
				_ui.priceLabel.text = itemdata.needScore
				canBuy = true
			end 
			
			_ui.useButton.gameObject:SetActive(itemCount > 0)
			_ui.buyButton.gameObject:SetActive(itemCount == 0 and canBuy)

			SetClickCallback(_ui.useButton.gameObject, function()
				Hide()
				useCallback(false)
			end)
			
			if exchangeDataList == nil then
				exchangeDataList = TableMgr:GetItemExchangeList()
			end

			local cost = tonumber(shopItem.NeedGold)
			_ui.priceLabel.text = cost

			SetClickCallback(_ui.buyButton.gameObject, function()
				if CheckBuy == true then
					if MoneyListData.GetDiamond() < cost then
						Global.ShowNoEnoughMoney()
					else
						Hide()
						useCallback(true)
					end 
				else
					Hide()
					useCallback(true)
				end 
			end)
			_ui.buyButtonBg.spriteName ="icon_gold"
		end 
	else
		local itemCount = itemMsg ~= nil and itemMsg.number or 0
		_ui.countLabel.text = String.Format(TextMgr:GetText(Text.ui_worldmap_70), itemCount)
		
		if exchangeDataList == nil then
			exchangeDataList = TableMgr:GetItemExchangeList()
		end

		local canBuy = false
		local price = 0
		for i, v in pairs(exchangeDataList) do
			local exchangeData = exchangeDataList[i]
			if exchangeData.item == itemId and exchangeData.number == 1 and exchangeData.moneyType == 2 then
				canBuy = true
				_ui.priceLabel.text = exchangeData.price
				price = exchangeData.price
				break
			end
		end
		
		_ui.useButton.gameObject:SetActive(itemCount > 0)
		_ui.buyButton.gameObject:SetActive(itemCount == 0 and canBuy)

		SetClickCallback(_ui.useButton.gameObject, function()
			Hide()
			useCallback(false)
		end)

		SetClickCallback(_ui.buyButton.gameObject, function()
			if MoneyListData.GetDiamond() < price then
				Global.ShowNoEnoughMoney()
			else
				Hide()
				useCallback(true)
			end
		end)
		_ui.buyButtonBg.spriteName ="icon_gold"
	end
	
    
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/bg_frane/btn_close"):GetComponent("UIButton")
    SetClickCallback(closeButton.gameObject, Hide)
	local bg = transform:Find("Container")
	SetClickCallback(bg.gameObject, Hide)
	
	local item = {}
    local itemTransform = transform:Find("Container/bg_frane/Item_CommonNew")
    UIUtil.LoadItemObject(item, itemTransform)
    item.nameLabel = transform:Find("Container/bg_frane/name"):GetComponent("UILabel")
    _ui.item = item

    _ui.descriptionLabel = transform:Find("Container/bg_frane/text"):GetComponent("UILabel")
    _ui.countLabel = transform:Find("Container/bg_frane/num"):GetComponent("UILabel")
    _ui.priceLabel = transform:Find("Container/bg_frane/btn_use_gold/num"):GetComponent("UILabel")
	
	
    _ui.useButton = transform:Find("Container/bg_frane/btn_use"):GetComponent("UIButton")
    _ui.buyButton = transform:Find("Container/bg_frane/btn_use_gold"):GetComponent("UIButton")
	_ui.buyButtonBg = transform:Find("Container/bg_frane/btn_use_gold/icon_gold"):GetComponent("UISprite")
end

function Close()
    _ui = nil
end

function Show(item, callback ,check)
    if type(item) == "number" then
        itemData = TableMgr:GetItemData(item)
    else
        itemData = item
    end
	if check== false then
		CheckBuy = false
	else
		CheckBuy = true
	end 
    useCallback = callback
    Global.OpenUI(_M)
    LoadUI()
end
