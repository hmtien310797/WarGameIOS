module("ItemListShow", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local SetClickCallback = UIUtil.SetClickCallback
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local bgScrollViewGrid
local bgScrollView
local AudioMgr = Global.GAudioMgr

local title
local itemShow

local function OnCloseCallback()
	GUIMgr:CloseMenu("ItemListShow")
end

function SetTittle(strTittle)
	title = strTittle
end

function SetItemShow(showlist)
	itemShow = showlist
end

function Awake()
end

function Start()
	local Title = transform:Find("ItemList/bg_frane/bg_top/title"):GetComponent("UILabel")
	Title.text = title--TextMgr:GetText(strTittle)

	local btnClose = transform:Find("ItemList/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(btnClose.gameObject , OnCloseCallback)
	
	local ItemInfo = transform:Find("ItemInfo")
	local ItemGrid = transform:Find("ItemList/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	
	while ItemGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(ItemGrid.transform:GetChild(0).gameObject)
	end
	
	for i, v in pairs(itemShow) do
		local item = NGUITools.AddChild(ItemGrid.gameObject , ItemInfo.gameObject)
		item.gameObject:SetActive(true)
		item.transform:SetParent(ItemGrid.transform , false)
		
		local itembg = item.transform:Find("bg_list/background")
		if i%2 == 0 then
			itembg.gameObject:SetActive(true)
		else
			itembg.gameObject:SetActive(false)
		end
		
		local itemTbData = TableMgr:GetItemData(v.baseid)
		local item_box = item.transform:Find("bg_list/bg_icon"):GetComponent("UISprite")
		item_box.spriteName = "bg_item" .. itemTbData.quality
		
		local item_num = item.transform:Find("bg_list/bg_icon/num"):GetComponent("UILabel")
		item_num.text = v.num 
		
		local item_icon = item.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
		item_icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTbData.icon)

		local item_name = item.transform:Find("bg_list/text_name"):GetComponent("UILabel")
		local textColor = Global.GetLabelColorNew(itemTbData.quality)
		item_name.text = textColor[0] .. TextUtil.GetItemName(itemTbData) .. "[-]"
		
		local item_des = item.transform:Find("bg_list/text_des"):GetComponent("UILabel")
		item_des.text = TextUtil.GetItemDescription(itemTbData.description)
	end
	ItemGrid:Reposition()
	
	
	AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
end

