module("UseSelectBox", package.seeall)

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
local useItemNumber = 1
local maxNum = 1
local itemList = {}
local funcConfirm
local _ui
local UseItemId

function SetMaxNum(_num)
	maxNum = _num
	useItemNumber = maxNum
	_ui.numSlider.value = useItemNumber/maxNum
	updateText()
end

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
	_ui.numSlider.value = useItemNumber/maxNum
	
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
		
		if selItem == obj.name then 
			obj.transform:Find("select/confirm").gameObject:SetActive(true)
		else
			obj.transform:Find("select/confirm").gameObject:SetActive(false)
		end 

		SetClickCallback(obj.transform:Find("select").gameObject , function(go)
			if selItem == go.transform.parent.name then 
				selItem = nil
			else
				selItem = go.transform.parent.name
			end 
			-- SetMaxNum(itemList[tonumber(selItem)].num)
			ShowList()
		end)

    end
    _ui.Grid:Reposition()
    _ui.ScrollView:SetDragAmount(0, 0, false)   

	UpdateBtnState()
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
	
	SetClickCallback(transform:Find("bottom/Confim Button").gameObject, BtnConfirmList)
	
	
	_ui.useNum = transform:Find("bottom/slider/frame_input/title"):GetComponent("UILabel")
	_ui.useNum.text = useItemNumber
	
	_ui.numbottom = transform:Find("bottom/slider/frame_input/text_num"):GetComponent("UILabel")
	_ui.numbottom.text = "/" .. maxNum --useItem.number
	
	_ui.inputText = transform:Find("bottom/slider/frame_input"):GetComponent("UIInput")
	SetClickCallback(_ui.inputText.gameObject , OkClickCallback)
	--slider
	_ui.numSlider = transform:Find("bottom/slider/bg_dissolution_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	_ui.numSlider.value = useItemNumber/maxNum --useItem.number
	EventDelegate.Set(_ui.numSlider.onChange,EventDelegate.Callback(function(obj,delta)
		OnValueChange()
	end))
	--SetPressCallback(_ui.numSlider.gameObject, CaculateSlider)
	local listener = UIEventListener.Get(_ui.numSlider.gameObject)
	listener.onPress = CaculateSlider
	--use btn
	local btnSlider = transform:Find("bottom/slider/bg_dissolution_time/bg_schedule/btn_slider"):GetComponent("UIButton")
	SetDragCallback(btnSlider.gameObject , OnDragSlider)
	SetPressCallback(btnSlider.gameObject, CaculateSlider)
	
	local btnMinus = transform:Find("bottom/slider/bg_dissolution_time/btn_minus"):GetComponent("UIButton")
	SetPressCallback(btnMinus.gameObject, ItemUseMinus)
	local btnAdd = transform:Find("bottom/slider/bg_dissolution_time/btn_add"):GetComponent("UIButton")
	SetPressCallback(btnAdd.gameObject, ItemUseAdd)
	
end

function OnValueChange()
	if _ui ~= nil then
		useItemNumber = Mathf.Floor(_ui.numSlider.value * maxNum + 0.5)
		useItemNumber = math.min(useItemNumber, maxNum)
		_ui.useNum.text = useItemNumber
		updateText()
	end
end


function ItemUseMinus(go, isPressed)
	if not isPressed then
		useItemNumber = math.max(useItemNumber - 1, 0)
		_ui.numSlider.value = useItemNumber/maxNum --useItem.number
		_ui.useNum.text = useItemNumber
		
		-- local tNum
		-- if isshop then
		-- 	tNum = useItem.price * useItemNumber
		-- else
		-- 	tNum = itemTBData.param1 * useItemNumber
		-- 	if itemTBData.type == 27 then
		-- 		tNum = Global.SecondToTimeLong(tNum)
		-- 	else
		-- 		resNum = resourceStored + tNum
		-- 		_ui.resNum.text = ResourceString(resNum)
		-- 		tNum = Global.FormatNumber(resNum)
		-- 	end
		-- end
		-- _ui.totalText.text = tNum
		updateText()
	end
end

function updateText()
	_ui.useNum.text = useItemNumber
	_ui.numbottom.text = "/" .. maxNum 
	UpdateBtnState()
end


function ItemUseAdd(go, isPressed)
	if not isPressed then
		-- local m = useItem.number
		-- if maxNum ~= nil and maxNum < useItem.number then
		-- 	m = maxNum
		-- end
		useItemNumber = math.min(useItemNumber + 1, maxNum)
		_ui.numSlider.value = useItemNumber/maxNum --useItem.number
		_ui.useNum.text = useItemNumber
		
		-- local tNum
		-- if isshop then
		-- 	tNum = useItem.price * useItemNumber
		-- else
		-- 	tNum = itemTBData.param1 * useItemNumber
		-- 	if itemTBData.type == 27 then
		-- 		tNum = Global.SecondToTimeLong(tNum)
		-- 	else
		-- 		resNum = resourceStored + tNum
		-- 		_ui.resNum.text = ResourceString(resNum)
		-- 		tNum = Global.FormatNumber(resNum)
		-- 	end
		-- end
		-- _ui.totalText.text = tNum
		updateText()
	end
end



function CaculateSlider(go, isPressed)
	if not isPressed then
		_ui.numSlider.value = useItemNumber/maxNum --useItem.number
	end
end

function OkClickCallback(go)
	NumberInput.Show(useItemNumber, 0, maxNum, function(number)
        useItemNumber = number
        _ui.numSlider.value = useItemNumber/maxNum --useItem.number
        _ui.useNum.text = useItemNumber
		-- local tNum, reNum
		-- if isshop then
		-- 	tNum = useItem.price * useItemNumber
		-- else
		-- 	tNum = itemTBData.param1 * useItemNumber
		-- 	if itemTBData.type == 27 then
		-- 		tNum = Global.SecondToTimeLong(tNum)
		-- 	else
		-- 		resNum = resourceStored + tNum
		-- 		_ui.resNum.text = ResourceString(resNum)
		-- 		tNum = Global.FormatNumber(resNum)
		-- 	end
		-- end
		-- _ui.totalText.text = tNum
  		updateText()
    end)
end

function BtnConfirmList()
	
	if selItem == nil then 
		
		return 
	end 
	
	if funcConfirm ~= nil then
		funcConfirm(UseItemId,useItemNumber,tonumber(selItem)-1)
	end 
	CloseAll()
end 

function UpdateBtnState()
	local btn = transform:Find("bottom/Confim Button").gameObject
	
	if selItem == nil or useItemNumber ==0 then 
		btn:GetComponent("UISprite").spriteName = "btn_4"
		btn:GetComponent("UIButton").normalSprite = "btn_4"
		btn:GetComponent("BoxCollider").enabled = false
	else
		btn:GetComponent("UISprite").spriteName = "btn_2"
		btn:GetComponent("UIButton").normalSprite = "btn_2"
		btn:GetComponent("BoxCollider").enabled = true
	end 
	
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


function Show(uid,str,maxnum,num,fun)
    UseItemId = uid
	funcConfirm = fun
	RewardStr = str
	maxNum = maxnum
	useItemNumber = num
	Global.OpenUI(_M)
    LoadUI()
	ShowList();	
end
