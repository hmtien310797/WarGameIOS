module("Item_4301", package.seeall)


ITEM_BASEID = 4301 
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
local buybutton
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
	local itemExchangeData = TableMgr:GetItemExchangeData(itemBaseData.param1)
	local noEnoughEnergyText = TextMgr:GetText(Text.common_ui9)
	local coin = MoneyListData.GetDiamond()
    if coin < itemExchangeData.price then
		local msgText = TextMgr:GetText(Text.common_ui8)
		local okText = TextMgr:GetText(Text.common_ui10)
		if showNoEnoughEnergy then
			msgText = noEnoughEnergyText..msgText
		end
		MessageBox.Show(msgText, function() store.Show(7) end, function() end, okText)
		
		return
	end
	
	if useCallBack ~= nil then
		useCallBack()
	end
	Hide()
end

function Use()
	--coroutine.start(function()
		Init()
	--	coroutine.step()
		
		Show()
	--end)
end 


function Show()
	usebutton = transform:Find("Container/bg_frane/btn_use"):GetComponent("UIButton")
	SetClickCallback(usebutton.gameObject , OnUseClickCallback)
	
	local closeBtn = transform:Find("Container/bg_frane/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		print("close")
		Hide()
	end)
	
	buybutton = transform:Find("Container/bg_frane/btn_use_gold"):GetComponent("UIButton")
	SetClickCallback(buybutton.gameObject , OnUseClickCallback)
	
	itemBaseData = TableMgr:GetItemData(ITEM_BASEID)
	
	local itemName = transform:Find("Container/bg_frane/name"):GetComponent("UILabel")
	itemName.text = TextUtil.GetItemName(itemBaseData)
	
	local itemBoxIcon = transform:Find("Container/bg_frane/bg_icon"):GetComponent("UISprite")
	itemBoxIcon.spriteName = "bg_item" .. itemBaseData.quality
	
	local itemTexture = transform:Find("Container/bg_frane/bg_icon/Texture"):GetComponent("UITexture")
	itemTexture.mainTexture = ResourceLibrary:GetIcon("Item/" , itemBaseData.icon)
	
	local des = transform:Find("Container/bg_frane/text"):GetComponent("UILabel")
	des.text = TextMgr:GetText("transfer_ui1")
	
	itemData = ItemListData.GetItemDataByBaseId(ITEM_BASEID)
	local itemNum = transform:Find("Container/bg_frane/bg_icon/num"):GetComponent("UILabel")
	local itemHad = transform:Find("Container/bg_frane/num"):GetComponent("UILabel")
	
	if itemData ~= nil and itemData.number > 0 then
		itemNum.text = itemData.number
		itemHad.text = String.Format(TextMgr:GetText(Text.ui_worldmap_70), itemData.number)--TextMgr:GetText("speedup_ui9") .. ":" .. itemData.number
		usebutton.gameObject:SetActive(true)
		buybutton.gameObject:SetActive(false)
	else
		itemNum.text = 0
		itemHad.text = String.Format(TextMgr:GetText(Text.ui_worldmap_70), 0)--TextMgr:GetText("speedup_ui9") .. ":" .. 0
		usebutton.gameObject:SetActive(false)
		buybutton.gameObject:SetActive(true)
		local cost = transform:Find("Container/bg_frane/btn_use_gold/num"):GetComponent("UILabel")
		local itemExchangeData = TableMgr:GetItemExchangeData(itemBaseData.param1)
		cost.text =  itemExchangeData.price
	end
end

function Init()
	uiPrefab = ResourceLibrary.GetUIInstance("BuildingCommon/QuickUseItem")
	transform = uiPrefab.transform
    transform:SetParent(uiRoot, false)
	NGUITools.BringForward(uiPrefab)

	ItemListData.AddListener(Show)
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
