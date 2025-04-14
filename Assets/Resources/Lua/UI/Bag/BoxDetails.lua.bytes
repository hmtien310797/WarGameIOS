module("BoxDetails", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
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

local SetDragCallback = UIUtil.SetDragCallback
local RewardStr


local selItem 
local itemList = {}
local _ui

local function getList(str)
	local reward = Global.MakeAward(str)
	for i, v in ipairs(reward.heros) do
        local heroData = TableMgr:GetHeroData(v.id)
		local it ={}
		it.name = TextMgr:GetText(heroData.nameLabel)
		it.icon = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
		it.num = 1
		it.quality = heroData.quality
		it.havePiece = false
		
		table.insert(itemList,it)
    end
    for _, item in ipairs(reward.items) do
        local itemData = TableMgr:GetItemData(item.id or item.baseid)
		local it ={}
		it.name = TextUtil.GetItemName(itemData)
		
		if itemData.type == 61 then
			it.icon = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
		else
			it.icon = ResourceLibrary:GetIcon("Item/", itemData.icon)
		end

		it.num = item.num

		it.quality  = itemData.quality
		
		if itemData.type == 54 then 
			it.havePiece = true
		else
			it.havePiece = false
		end 
		
		table.insert(itemList,it)

    end
    for ii, vv in ipairs(reward.armys) do
        local reward = vv
        local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
        
		local it ={}
		it.name = TextMgr:GetText(soldierData.SoldierName)
		it.icon = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
		it.num = reward.num
		it.quality = (1 + vv.level)
		it.havePiece = false
		table.insert(itemList,it)
		
    end

end 

local function ShowList()

	for i=1 , _ui.Grid.transform.childCount , 1 do
		local item = _ui.Grid.transform:GetChild(i-1)
		item.gameObject:SetActive(false)
	end
	
	itemList = {}
	
	local str = RewardStr:split(";")
	for i=1 , #str do
		getList(str[i])
	end
	

    for i=1 , #itemList do
        local v = itemList[i]
		local obj = nil
		if i<= _ui.Grid.transform.childCount then 
			obj = _ui.Grid.transform:GetChild(i-1).gameObject
		else
			obj = NGUITools.AddChild(_ui.Grid.gameObject, _ui.GirdItem)
		end 
        obj.name = i
        obj:SetActive(true)

		local nameLabel = obj.transform:Find("name"):GetComponent("UILabel")
        nameLabel.text = v.name
	    
		local icon = obj.transform:Find("Texture"):GetComponent("UITexture")
	    icon.mainTexture = v.icon
	   
		local numLabel = obj.transform:Find("num"):GetComponent("UILabel")
        numLabel.text = "x"..v.num

		local pieceTransform = obj.transform:Find("Texture/piece")
		local pieceSprite = pieceTransform:GetComponent("UISprite")
		pieceTransform.gameObject:SetActive(v.havePiece)
		local frame = obj:GetComponent("UISprite")

		pieceSprite.spriteName = "piece" .. v.quality
		
		frame.spriteName = "bg_item" .. v.quality
    end
    _ui.Grid:Reposition()
    _ui.ScrollView:SetDragAmount(0, 0, false)   
end


function Hide()
    selItem = nil 
	Global.CloseUI(_M)
end

function LoadUI()
   
    _ui = {}

	_ui.ScrollView = transform:Find("Container/New Gift Pack/Scroll View"):GetComponent("UIScrollView")
    _ui.Grid = transform:Find("Container/New Gift Pack/Scroll View/Grid"):GetComponent("UIGrid")

	_ui.GirdItem = transform:Find("Container/New Item").gameObject
    _ui.GirdItem.gameObject:SetActive(false)
	
	SetClickCallback(transform:Find("top/btn_close").gameObject, function()
		Hide()
	end)
	
	SetClickCallback(transform:Find("bottom/Confim Button").gameObject, CloseAll)
end

function CloseAll()
    Hide()
end


function Awake()
	
end
	
function Close()
    _ui = nil
	selItem = nil
end


function Show(str)
	RewardStr = str
	Global.OpenUI(_M)
    LoadUI()
	ShowList();	
end
