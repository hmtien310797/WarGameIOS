--随机传送道具
module("Item_4201", package.seeall)

ITEM_BASEID = 4201 

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local GameObject = UnityEngine.GameObject
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local uiRoot = GUIMgr.UIRoot
local String = System.String

local uiPrefab

local usebutton
local itemBaseData
local itemData
local transform
local useCallBack 

function SetCallBack(callback) 
    useCallBack = callback 
end 
local function Hide()
	useCallBack = nil 
	ItemListData.RemoveListener(Show)
	GameObject.Destroy(uiPrefab)
end


local function OnUseClickCallback(go)
	print("OnUseClickCallback ")
	local itemData = ItemListData.GetItemDataByBaseId(ITEM_BASEID)
		local req = MapMsg_pb.HomeTranslateRequest()
		req.type = 0
		if itemData == nil or itemData.number == 0 then
			req.buy = true
		end

		Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.HomeTranslateRequest, req, MapMsg_pb.HomeTranslateResponse, function(msg)
			print(msg.code)
			if msg.code == ReturnCode_pb.Code_OK then
				local myPos = msg.homeinfo.data.pos
				MapInfoData.SetMyBasePos(myPos)
				
				if req.buy then
					GUIMgr:SendDataReport("purchase", "costgold", "item:" .. ITEM_BASEID, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
				else
					GUIMgr:SendDataReport("purchase", "useitem", "" .. ITEM_BASEID, "1")
				end
				
				MainCityUI.UpdateRewardData(msg.fresh)
				SlgBag.UpdateBagItem(msg.fresh.item.items)
				
				--pop hint
				local nameColor = Global.GetLabelColorNew(itemBaseData.quality)
				local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemBaseData)..nameColor[1])
				FloatText.Show(showText , Color.white, ResourceLibrary:GetIcon("Item/", itemBaseData.icon))
				Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
				--close menu
				Hide()
				if GUIMgr:FindMenu("SlgBag") ~= nil then
					GUIMgr:CloseMenu("SlgBag")
				end
				--jump to worldmap
				--WorldMap.Show()
				MainCityUI.ShowWorldMap(myPos.x, myPos.y, true , function()
					-- WorldMapData.SetMyBaseTileData(msg.homeinfo)
				end)
			
            else
                Global.ShowError(msg.code)
			end
		end, true)
end

function Show()
	usebutton = transform:Find("Container/bg_frane/btn_use"):GetComponent("UIButton")
	SetClickCallback(usebutton.gameObject , OnUseClickCallback)
	SetClickCallback(transform:Find("Container").gameObject, function() Hide() end)
	local closeBtn = transform:Find("Container/bg_frane/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		print("close")
		Hide()
	end)

	itemBaseData = TableMgr:GetItemData(ITEM_BASEID)
	print(itemBaseData.name)
	itemData = ItemListData.GetItemDataByBaseId(ITEM_BASEID)
	local itemnum = 0
	if itemData ~= nil then
		itemnum = itemData.number
	end
	
	local itemName = transform:Find("Container/bg_frane/name"):GetComponent("UILabel")
	itemName.text = TextUtil.GetItemName(itemBaseData)

	local itemTransform = transform:Find("Container/bg_frane/Item_CommonNew")
	local item = {}
	UIUtil.LoadItemObject(item, itemTransform)
	UIUtil.LoadItem(item, itemBaseData, nil)
	
	local itemHad = transform:Find("Container/bg_frane/num"):GetComponent("UILabel")
	itemHad.text = String.Format(TextMgr:GetText(Text.ui_worldmap_70), itemnum)
	
	local des = transform:Find("Container/bg_frane/text"):GetComponent("UILabel")
	des.text = TextMgr:GetText("transfer_ui1")
	
	usebutton.gameObject:SetActive(true)
	transform:Find("Container/bg_frane/btn_use_gold").gameObject:SetActive(false)

	local priceLabel = transform:Find("Container/bg_frane/btn_use_gold/num"):GetComponent("UILabel")
	transform:Find("Container/bg_frane/btn_use_gold/icon_gold"):GetComponent("UISprite").spriteName = "icon_gold"
	local exchangeDataList = TableMgr:GetItemExchangeList()
	local canBuy = false
	for i, v in pairs(exchangeDataList) do
		local exchangeData = exchangeDataList[i]
		if exchangeData.item == ITEM_BASEID and exchangeData.number == 1 and exchangeData.moneyType == 2 then
			priceLabel.text = exchangeData.price
			break
		end
	end
end

function Init()
	uiPrefab = ResourceLibrary.GetUIInstance("BuildingCommon/QuickUseItem")
	transform = uiPrefab.transform
    transform:SetParent(uiRoot, false)
	NGUITools.BringForward(uiPrefab)

	ItemListData.AddListener(Show)
end




function Use()
	--coroutine.start(function()
		Init()
	--	coroutine.step()
		
		Show()
	--end)
	

end 


function Awake()
	
end 

function Start()
end 

function Close()
    useCallBack = nil 
	ItemListData.RemoveListener(Show)
	GameObject.Destroy(uiPrefab)
end 
