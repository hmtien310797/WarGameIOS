module("SoldierLevel", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate


local _ui
local autoCount = 0
local closeCallback
--local _commandTableData

function Hide(closeMe)
	if closeCallback ~= nil then
		closeCallback()
	end
    Global.CloseUI(_M)
	if closeMe ~= false then
		GUIMgr:CloseMenu("MainInformation")
	end
end


function CloseAll()
    Hide()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
end

function SetAutoCount(count)
	autoCount = count
end

function CheckLevelUpdate()
	local curLv = MainData.GetData().commanderLeadLevel
	local nextLv = curLv >= TableMgr:GetCommandDataCount() and curLv or curLv + 1
	nextLv = nextLv >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) and tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) or nextLv
	
	local data = TableMgr:GetCommandData(curLv)
	local nextdata = TableMgr:GetCommandData(nextLv)
	local items = nextdata.ItemConsume:split(":")
	local itemData = TableMgr:GetItemData(items[1])
	
	return curLv < TableMgr:GetCommandDataCount() and 
		   curLv < MainData.GetLevel() and
		   ItemListData.GetItemCountByBaseId(tonumber(items[1])) >= tonumber(items[2])
end

function LoadUI()
	if _ui == nil then
		return
	end
	local curLv = MainData.GetData().commanderLeadLevel
	local nextLv = curLv >= TableMgr:GetCommandDataCount() and curLv or curLv + 1
	nextLv = nextLv >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) and tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) or nextLv
	
	local data = TableMgr:GetCommandData(curLv)
	local nextdata = TableMgr:GetCommandData(nextLv)
	local items = nextdata.ItemConsume:split(":")
	local itemData = TableMgr:GetItemData(items[1])
	
	_ui.commanderLevel1.text = curLv
	_ui.commanderLevel2.text = nextLv
	
	_ui.soldierNum1.text = data.SoldierNum
	_ui.soldierNum2.text = nextdata.SoldierNum
	
	_ui.itemBack.spriteName = "bg_item" .. itemData.quality
	_ui.itemIcon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
	_ui.itemHave.text = System.String.Format(TextMgr:GetText("command_ui_command_txt10") , ItemListData.GetItemCountByBaseId(tonumber(items[1])))  
	_ui.itemName.text = TextMgr:GetText(itemData.name)
	_ui.itemNeed.text = System.String.Format(TextMgr:GetText("command_ui_command_txt02") , items[2]) 
	_ui.levelRate.text = System.String.Format(TextMgr:GetText("command_ui_command_txt01") , nextdata.LevelupRate/100) --nextdata.LevelupRate/100 .. "%"
	_ui.levelText.text = ItemListData.GetItemCountByBaseId(tonumber(items[1])).."/"..items[2]
	_ui.levelSlider.value = ItemListData.GetItemCountByBaseId(tonumber(items[1]))/items[2]
	
	_ui.buttonGoldLabel.text = nextdata.GoldConsume
	_ui.buttonItemRedPoint.gameObject:SetActive(CheckLevelUpdate())
	
	SetClickCallback(_ui.itemBack.gameObject , function()
		Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
	end)
	
	
end

function LevelUpCallBack(_type)
	local req = ClientMsg_pb.MsgCommanderLeadLevelUpRequest()
    req.usegold = _type
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCommanderLeadLevelUpRequest, req, ClientMsg_pb.MsgCommanderLeadLevelUpResponse, function(msg)
		--Global.DumpMessage(msg , "d:/MsgCommanderLeadLevelUpRequest.lua")
		if msg.code == ReturnCode_pb.Code_OK then
			if msg.result == 1 then
				MainData.SetCommanderLevel(msg.newlevel)
				MainCityUI.UpdateRewardData(msg.fresh)
				FloatText.Show(TextMgr:GetText("command_ui_command_txt12") ,Color.green)
				autoCount = 0
				LoadUI()
			else
				MainCityUI.UpdateRewardData(msg.fresh)
				LoadUI()
				FloatText.Show(TextMgr:GetText("command_ui_command_txt13") , Color.red)
				autoCount = autoCount + 1
				if autoCount >= 5 then
					autoCount = 0
					SoldierLevelSure.Show(TextMgr:GetText("command_ui_window_txt03") , "" , LoadUI)
				end
			end
		else
			Global.ShowError(msg.code)
        end
	end , true)
end


function Start()
	LoadUI()
end


function Awake()
	_ui = {}
	_ui.mask = transform:Find("mask")
	_ui.mask.gameObject:SetActive(false)
	
	_ui.btn_close = transform:Find("Container/back/close").gameObject
	
	_ui.commanderLevel1 = transform:Find("Container/back/left/back/top1/number1"):GetComponent("UILabel")
	_ui.commanderLevel2 = transform:Find("Container/back/left/back/top1/number2"):GetComponent("UILabel")
	_ui.soldierNum1 = transform:Find("Container/back/left/back/top2/number1"):GetComponent("UILabel")
	_ui.soldierNum2 = transform:Find("Container/back/left/back/top2/number2"):GetComponent("UILabel")
	
	_ui.itemBack = transform:Find("Container/back/right/back/daoju"):GetComponent("UISprite")
	_ui.itemIcon = transform:Find("Container/back/right/back/daoju/Texture"):GetComponent("UITexture")
	_ui.itemHave = transform:Find("Container/back/right/back/have"):GetComponent("UILabel")
	_ui.itemName = transform:Find("Container/back/right/back/name"):GetComponent("UILabel")
	_ui.itemNeed = transform:Find("Container/back/right/back/need"):GetComponent("UILabel")
	_ui.levelSlider = transform:Find("Container/back/right/back/jindu"):GetComponent("UISlider")
	_ui.levelText = transform:Find("Container/back/right/back/jindu_text"):GetComponent("UILabel")
	_ui.levelRate = transform:Find("Container/back/right/back/rate"):GetComponent("UILabel")
	
	_ui.buttonGold = transform:Find("Container/back/right/button1")
	_ui.buttonItem = transform:Find("Container/back/right/button2")
	_ui.buttonGoldLabel = transform:Find("Container/back/right/button1/gold_number"):GetComponent("UILabel")
	_ui.buttonItemRedPoint = transform:Find("Container/back/right/button2/red dot")
	
	SetClickCallback(_ui.mask.gameObject , Hide)
	SetClickCallback(_ui.btn_close.gameObject , Hide)
	
	if Global.IsOutSea() then
		local btnTransGold = UnityEngine.GameObject.Instantiate(_ui.buttonItem.gameObject).transform
		btnTransGold:SetParent(_ui.buttonItem.parent, false)
		btnTransGold.position = _ui.buttonGold.position
		_ui.buttonGold.gameObject:SetActive(false)
		local label = btnTransGold:Find("Label") 
		label:GetComponent("LocalizeEx").enabled = false
		label:GetComponent("UILabel").text = TextMgr:GetText("speedup_ui3")
		_ui.buttonGold = btnTransGold
		btnTransGold:Find("red dot").gameObject:SetActive(false)
		SetClickCallback(_ui.buttonGold.gameObject , function() 
			CheckResourceInfo(47)
		end) 
	else
		SetClickCallback(_ui.buttonGold.gameObject , function() 
			LevelUpCallBack(1)
			--SoldierLevelSure.Show(TextMgr:GetText("command_ui_window_txt03") , "123123123" , LoadUI)
		end) -- 黄金升级
	end 
	SetClickCallback(_ui.buttonItem.gameObject , function() LevelUpCallBack(2) end) -- 道具升级
	autoCount = 0
	
	AddDelegate(UICamera, "onClick", OnUICameraClick)
end

local function BuyExpFunc(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)

	local req = ShopMsg_pb.MsgCommonShopBuyRequest()
	req.exchangeId = exItemid
	req.num = count
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopBuyRequest, req, ShopMsg_pb.MsgCommonShopBuyResponse, function(msg)
        if msg.code == 0 then
            MainCityUI.UpdateRewardData(msg.fresh)
            -- UpdateexchangeItems(exchangeId, msg.currentBuyNum)
            -- ProcessActivity()
            Global.ShowReward(msg.reward)
            Global.GAudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
			ShopItemData.RequestData(1, function(msg)
				CommonItemBag.SetLimitCount(true)
				CommonItemBag.UpdateItem()
				SoldierLevel.UpdateText()
			end)
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, true)
end

function UpdateText()
	if _ui == nil then 
		return 
	end 
	print("___________")
	local curLv = MainData.GetData().commanderLeadLevel
	local nextLv = curLv >= TableMgr:GetCommandDataCount() and curLv or curLv + 1
	nextLv = nextLv >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) and tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) or nextLv
	
	local data = TableMgr:GetCommandData(curLv)
	local nextdata = TableMgr:GetCommandData(nextLv)
	local items = nextdata.ItemConsume:split(":")
	local itemData = TableMgr:GetItemData(items[1])
	

	_ui.soldierNum1.text = data.SoldierNum
	_ui.soldierNum2.text = nextdata.SoldierNum

	_ui.itemHave.text = System.String.Format(TextMgr:GetText("command_ui_command_txt10") , ItemListData.GetItemCountByBaseId(tonumber(items[1])))  
	_ui.itemName.text = TextMgr:GetText(itemData.name)
	_ui.itemNeed.text = System.String.Format(TextMgr:GetText("command_ui_command_txt02") , items[2]) 
	_ui.levelRate.text = System.String.Format(TextMgr:GetText("command_ui_command_txt01") , nextdata.LevelupRate/100) --nextdata.LevelupRate/100 .. "%"
	_ui.levelText.text = ItemListData.GetItemCountByBaseId(tonumber(items[1])).."/"..items[2]
	_ui.levelSlider.value = ItemListData.GetItemCountByBaseId(tonumber(items[1]))/items[2]
	
end 

local function UseExpFunc1(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	local req = ItemMsg_pb.MsgUseItemRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
	end
	req.num = count
	
	
	local lastLevel = MainData.GetLevel()
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
		--print("use item code:" .. msg.code)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.FloatError(msg.code, Color.white)
			
		else
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end		
			useItemReward = msg.reward
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
				
			MainCityUI.UpdateRewardData(msg.fresh)

			ShopItemData.RequestData(2, function(msg)
				CommonItemBag.SetLimitCount(true)
				CommonItemBag.UpdateItem()
				SoldierLevel.UpdateText()
			end)
		end
	end, true)
end

function CheckResourceInfo(index)
	
	local items = {}
	items = maincity.GetItemExchangeListNoCommon(index)
	
	local noirtem = Global.BagIsNoItem(items)
	local noItemHint = TextMgr:GetText("player_ui18")
	if noirtem == true then
		FloatText.Show(noItemHint)
		return
	end
	
	local maxLevel = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PlayerMaxLevel).value
	local maxHint = TextMgr:GetText("build_ui33")
	local myLevel = MainData.GetLevel()
	if myLevel >= tonumber(maxLevel) then
		--AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
		--FloatText.Show(maxHint , Color.green)
		--return
	end
	
	if index ==43 then 
		CommonItemBag.SetTittle(TextMgr:GetText("item_19_name"))
		CommonItemBag.SetItemList(items, 0)
	else 
		CommonItemBag.SetTittle(TextMgr:GetText("item_15008_name"))
		CommonItemBag.SetItemList(items, 5)
	end 
	
	CommonItemBag.SetResType(Common_pb.MoneyType_None)
	
	if index == 43 then
		CommonItemBag.SetUseFunc(UseExpFunc1)
	else
		CommonItemBag.SetUseFunc(BuyExpFunc)
	end
	CommonItemBag.NotUseAutoClose()
	CommonItemBag.SetLimitCount(true)
	CommonItemBag.OnOpenCB = function()
	end
	GUIMgr:CreateMenu("CommonItemBag" , false)
	if index == 43 then 
		ShopItemData.RequestData(2, function(msg)
			CommonItemBag.SetLimitCount(true)
			CommonItemBag.UpdateItem()
		end)
	else 
		ShopItemData.RequestData(1, function(msg)
			CommonItemBag.SetLimitCount(true)
			CommonItemBag.UpdateItem()
		end)
	end 
end


function Update()
   
end

function Close()
	_ui = nil
	closeCallback = nil
	RemoveDelegate(UICamera, "onClick", OnUICameraClick)
end

function Show(closeCB)
	closeCallback = closeCB
    Global.OpenUI(_M)
end

function Test()
	--Global.Request
end