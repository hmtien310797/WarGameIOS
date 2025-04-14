module("GetVipCoin", package.seeall)
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

local _ui, UpdateUI, UseMultiPressCallback, UsePressCallback, MultiuseCallBack, UseItemFunc
local UseItemId = 0
local ExItemId = 0
local needReposition
local callback

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	callback = nil
	MainCityUI.RemoveCommonItemBagListener(UpdateUI)
end

function Show(_callback)
	callback = _callback
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Accelerate").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Accelerate/bg_frane/bg_top/btn_close").gameObject
	_ui.vipsprite = transform:Find("Accelerate/bg_frane/bg_exp/bg_vip/frame"):GetComponent("UITexture")
	_ui.slider = transform:Find("Accelerate/bg_frane/bg_exp/bg/bar"):GetComponent("UISlider")
	_ui.text = transform:Find("Accelerate/bg_frane/bg_exp/bg/text"):GetComponent("UILabel")
	_ui.scroll = transform:Find("Accelerate/bg_frane/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Accelerate/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = ResourceLibrary.GetUIPrefab("Bag/SlgBagInfo_big")
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.mask, CloseSelf)
	MainCityUI.AddCommonItemBagListener(UpdateUI)
	needReposition = true
	_ui.itemlist = maincity.GetItemExchangeListNoCommon(22)
	UpdateUI()
end

UseMultiPressCallback = function(go)
	local strParams = go.transform.parent.parent.gameObject.name:split("_")
	UseItemId = tonumber(strParams[1])
	ExItemId = tonumber(strParams[2])
	
	local itemdata = ItemListData.GetItemDataByBaseId(UseItemId)
	if itemdata ~= nil then
		UseItem.InitItem(tonumber(itemdata.uniqueid))
		--print("mutiuse item id: " .. UseItemId .. "uid:" .. itemdata.uniqueid)
		UseItem.SetUseCallBack(MultiuseCallBack)
		GUIMgr:CreateMenu("UseItem" , false)
	end
end

UsePressCallback = function(go)
	local strParams = go.transform.parent.parent.gameObject.name:split("_")
	UseItemId = tonumber(strParams[1])
	ExItemId = tonumber(strParams[2])

	if btnClickWait then
		if go.transform:GetComponent("UIButton").enabled then
			go.transform:GetComponent("UIButton").enabled = false
			UseItemFunc(UseItemId , ExItemId , 1 , go)
		end
	else
		UseItemFunc(UseItemId , ExItemId , 1 , nil)
	end
end

MultiuseCallBack = function(useNum)
	UseItemFunc(UseItemId , ExItemId , useNum , nil)
end

UseItemFunc = function(useItemId , exItemid , count , go)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	local req = ItemMsg_pb.MsgUseItemRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
	end
	req.num = count
	
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			useItemReward = msg.reward
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white ,ResourceLibrary:GetIcon("Item/", itemTBData.icon))
			
			--MainData.UpdateData(msg.fresh.maindata)
			--ItemListData.UpdateData(msg.fresh.item)
			--MoneyListData.UpdateData(msg.fresh.money.money)
			MainCityUI.UpdateRewardData(msg.fresh)
			if callback ~= nil then
				callback()
			end
		else
			if msg.code == ReturnCode_pb.Code_DiamondNotEnough then
				local msgText = TextMgr:GetText(Text.common_ui8)
	            local okText = TextMgr:GetText(Text.common_ui10)
	            MessageBox.Show(msgText, function() store.Show(7) end, function() end, okText)
	        else
	        	Global.FloatError(msg.code, Color.white)
			end
		end
	end, true)
end

UpdateUI = function()
	_ui.vipsprite.mainTexture = ResourceLibrary:GetIcon("pay/" ,"icon_vip" .. MainData.GetVipLevel() )
	_ui.slider.value = MainData.GetVipExp() / MainData.GetVipNextExp()
	_ui.text.text = MainData.GetVipExp() .. "/" .. MainData.GetVipNextExp()
	
	local childCount = _ui.grid.transform.childCount
	while _ui.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.grid.transform:GetChild(0).gameObject)
	end
	
	for i ,v in pairs(_ui.itemlist) do
		
		local itemid = v.itemid
		local itemExId = v.exid
		local itemData = TableMgr:GetItemData(itemid)
		local itemBagData = ItemListData.GetItemDataByBaseId(itemid)
		local itemExchangeData = TableMgr:GetItemExchangeData(itemExId)
		
		
		if itemExId > 0 or itemBagData ~= nil then
			local item = NGUITools.AddChild(_ui.grid.gameObject , _ui.item.gameObject)
			item.gameObject:SetActive(true)
			item.gameObject.name = itemid .. "_" .. itemExId
			item.transform:SetParent(_ui.grid.transform , false)
			--bg_list
			local bgList = item.transform:Find("bg_list/background")
			if i%2 == 0 then
				bgList.gameObject:SetActive(true)
			else
				bgList.gameObject:SetActive(true)
			end
			
			--icon
			local icon = item.transform:Find("bg_list/bg_icon/Item_CommonNew/Texture"):GetComponent("UITexture")
			icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
			--name
			local name = item.transform:Find("bg_list/text_name"):GetComponent("UILabel")
			local textColor
			if itemBagData ~= nil then
				textColor = Global.GetLabelColorNew(itemData.quality)
			else
				local exTBdata = TableMgr:GetItemData(itemExchangeData.item)
				textColor = Global.GetLabelColorNew(exTBdata.quality)
			end
			name.text = textColor[0] .. TextUtil.GetItemName(itemData) .. "[-]"
			--des
			local des = item.transform:Find("bg_list/text_name/text_des"):GetComponent("UILabel")
			des.text = TextUtil.GetItemDescription(itemData)
			--quality
			local quabox = item.transform:Find("bg_list/bg_icon/Item_CommonNew"):GetComponent("UISprite")
			quabox.spriteName = "bg_item" .. itemData.quality
			
			--use button
			local useBtn = item.transform:Find("bg_list/btn_use")
			SetClickCallback(useBtn.gameObject, UsePressCallback)
			local mutiUseBtn = item.transform:Find("bg_list/btn_use_continue")
			SetClickCallback(mutiUseBtn.gameObject, UseMultiPressCallback)
			--buy button
			local buyBtn  = item.transform:Find("bg_list/btn_use_gold")
			SetClickCallback(buyBtn.gameObject, UsePressCallback)
			--num
			local num = item.transform:Find("bg_list/txt_num/num"):GetComponent("UILabel")
			if itemBagData ~= nil then
				useBtn.gameObject:SetActive(true)
				if itemBagData.number >= 2 and itemData.quickUse == 1 then
					mutiUseBtn.gameObject:SetActive(true)
				else
					mutiUseBtn.gameObject:SetActive(false)
				end
				buyBtn.gameObject:SetActive(false)
				
				num.text = itemBagData.number
			else
				useBtn.gameObject:SetActive(false)
				mutiUseBtn.gameObject:SetActive(false)
				buyBtn.gameObject:SetActive(true)
				
				num.text = "0"
				local money = item.transform:Find("bg_list/btn_use_gold/num"):GetComponent("UILabel")
				money.text = itemExchangeData.price
			end
			
			--level
			local itemlvTrf = item.transform:Find("bg_list/bg_icon/Item_CommonNew/num")
			local itemlv = itemlvTrf:GetComponent("UILabel")
			if itemData.showType == 1 then
				itemlv.text = Global.ExchangeValue2(itemData.itemlevel)
			elseif itemData.showType == 2 then
				itemlv.text = Global.ExchangeValue1(itemData.itemlevel)
			elseif itemData.showType == 3 then
				itemlv.text = Global.ExchangeValue3(itemData.itemlevel)
			else 
				itemlvTrf.gameObject:SetActive(false)
			end
		end
	end
	_ui.grid:Reposition()
	if needReposition then
		_ui.scroll:ResetPosition()
		needReposition = false
	end
	_ui.scroll:RestrictWithinBounds(true)
end
