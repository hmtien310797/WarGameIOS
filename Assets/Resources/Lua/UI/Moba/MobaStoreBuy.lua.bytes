module("MobaStoreBuy", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local SetDragCallback = UIUtil.SetDragCallback

local bagDefaultDisplay = 5 
local btnQuit
local btnDisplayLv1
local btnDisplayLv2
local btnDisplayLv3
local btnDisplayLv4

local useItemReward
local useItem
local useItemNumber = 1
local defaultUseNum = 1

local resNum
local resourceNeeded

local useCallBack

local totalEffectNum
local itemTBData

local maxNum
local leftTime
local actualTime
local isshop = false

local _ui

function SetMaxNum(_num)
	maxNum = _num
end

function SetLeftTime(_time)
	leftTime = _time
end

function SetActualTime(_time)
	actualTime = _time
end

function SetDefaultUseNum(num)
	defaultUseNum = num
end

function SetResourceInfo(numNeeded)
	resourceNeeded = numNeeded
end

function SetUseCallBack(callback)
	useCallBack = callback
end

function InitItem(_item,_itemTb)
	useItem = MobaItemData.GetItemDataByUid(_item)
	itemTBData = _itemTb
end


local function ResourceString(resNum)
	if resNum == nil then
		return ""
	end

	local resName = TextMgr:GetText(table.concat({"item_", tonumber(itemTBData.subtype + 2), "_name"}))

	if resourceNeeded ~= nil and resourceNeeded > 0 then
		if resNum < resourceNeeded then
			return System.String.Format(TextMgr:GetText("CommonItemBag_ui7"), resName, System.String.Format("[ff0000]{0}[-] / {1}", Global.ExchangeValue(resNum), Global.ExchangeValue(resourceNeeded)))
		else
			return System.String.Format(TextMgr:GetText("CommonItemBag_ui7"), resName, System.String.Format("{0} / {1}", Global.ExchangeValue(resNum), Global.ExchangeValue(resourceNeeded)))
		end
	else
		return System.String.Format(TextMgr:GetText("CommonItemBag_ui7"), resName, Global.ExchangeValue(resNum))
	end
end

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("MobaStoreBuy")
	end
end

local function updateText()
	if isshop then --商店
		--_ui.totalText.text = useItem.price * useItemNumber
	else
		print(itemTBData.type)
		local gain = itemTBData.param3 * useItemNumber
		if itemTBData.type == 27 then --加速
			if leftTime == nil or actualTime == nil then
				return
			end

			local timeAfterAccel = leftTime - gain

			if gain >= actualTime then
				--_ui.resNum.text = System.String.Format(TextMgr:GetText("CommonItemBag_ui9"), table.concat({"[00ff00]", Global.SecondToTimeLong(math.max(0, timeAfterAccel))}))
			else
				--_ui.resNum.text = System.String.Format(TextMgr:GetText("CommonItemBag_ui9"), Global.SecondToTimeLong(math.max(0, timeAfterAccel)))
			end
		elseif itemTBData.type == 19 then --资源
			--_ui.resNum.text = itemTBData.subtype == 5 and "" or ResourceString(MoneyListData.GetMoneyByType(itemTBData.subtype + 2) + gain)
		elseif itemTBData.type == 5 or itemTBData.type == 7 then --体力、经验
			--_ui.totalText.text = itemTBData.param3 * useItemNumber
		else
			--_ui.totalText.text = ""
		end
	end
	
	_ui.totalText.text = useItemNumber * actualTime
	
	local name = TextUtil.GetItemName(itemTBData)
	local n = string.match(name, "%d+")
	
	local num =0
	if n== nil then 
		num = GetTotalArmyNum()+useItemNumber * actualTime 
	else
	    num = GetTotalArmyNum()+useItemNumber * tonumber(n)
	end 

	if num > Global.MobaArmyNumUpLimit() then 
		_ui.numArmy.text = '[FF0000]'..num.. "[-]/" .. Global.MobaArmyNumUpLimit()
	else
		_ui.numArmy.text = num.. "/" .. Global.MobaArmyNumUpLimit()
	end 
end


function GetTotalArmyNum()
	--return --[[Barrack.GetArmyNum() +]] MobaActionListData.GetActionArmyTotalNum()
	return MobaBarrackData.GetArmyNum() + MobaActionListData.GetActionArmyTotalNum()
end

local function OkClickCallback(go)
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

local function ItemUseMinus(go, isPressed)
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

local function ItemUseAdd(go, isPressed)
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

local function OnDragSlider(obj,delta)
	if _ui ~= nil then
		_ui.numSlider.value = _ui.numSlider.value + delta.x * 0.005
		useItemNumber = Mathf.Floor(_ui.numSlider.value * maxNum + 0.5)
		useItemNumber = math.min(useItemNumber, maxNum)
		_ui.useNum.text = useItemNumber

		updateText()
	end
end

local function OnValueChange()
	if _ui ~= nil then
		useItemNumber = Mathf.Floor(_ui.numSlider.value * maxNum + 0.5)
		useItemNumber = math.min(useItemNumber, maxNum)
		_ui.useNum.text = useItemNumber
		updateText()
	end
end

local function CaculateSlider(go, isPressed)
	if not isPressed then
		_ui.numSlider.value = useItemNumber/maxNum --useItem.number
	end
end

local function ItemUseMuti(go, isPressed)
	if not isPressed then
		--SlgBag.ItemUseCount(useItem.uniqueid , useItemNumber)
		
		if useItemNumber == 0 then
			return
		end
		
		if useCallBack ~= nil then
			if maxNum ~= nil and leftTime ~= nil then
			--	if tonumber(itemTBData.param1) * useItemNumber * 0.9 > leftTime then
			--		MessageBox.Show(TextMgr:GetText("common_ui21"), function() useCallBack(useItemNumber) end, function() end)
			--	else
					useCallBack(useItemNumber)
			--	end
			else
				useCallBack(useItemNumber)
			end
		end
		local cor = coroutine.start(function ()
			coroutine.step()
			if _ui ~= nil then
				GUIMgr:CloseMenu("MobaStoreBuy")
			end
		end)
	end
end

function Start()
	_ui = {}
	-- if maxNum ~= nil then
	-- 	useItemNumber = math.min(maxNum , useItem.number)
	-- else
	-- 	useItemNumber = math.min(1 , useItem.number)
	-- end
	
	useItemNumber = math.min(defaultUseNum , maxNum)
	local btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	local bg = transform:Find("Container")
	SetPressCallback(bg.gameObject, QuitPressCallback)
	
	-- itemTBData = TableMgr:GetItemData(useItem.exchangeId)
	local itemName = transform:Find("Container/bg_frane/txt_name"):GetComponent("UILabel")
	itemName.text = TextUtil.GetItemName(itemTBData)

	local itemDescription = transform:Find("Container/bg_frane/text_des"):GetComponent("UILabel")
	itemDescription.text = TextUtil.GetItemDescription(itemTBData)

	_ui.numArmy = transform:Find("Container/bg_frane/bg_num_1/num"):GetComponent("UILabel")
	
	local item = {}
	local itemTransform = transform:Find("Container/bg_frane/Item_CommonNew")
	UIUtil.LoadItemObject(item, itemTransform)
	UIUtil.LoadItem(item, itemTBData)
	local numbottom = transform:Find("Container/bg_frane/bg_bottom/frame_input/text_num"):GetComponent("UILabel")
	numbottom.text = "/" .. maxNum --useItem.number
	_ui.useNum = transform:Find("Container/bg_frane/bg_bottom/frame_input/title"):GetComponent("UILabel")
	_ui.useNum.text = useItemNumber
	--_ui.useNum.text = useItemNumber .. "/" .. useItem.number
	_ui.totalTextObj = transform:Find("Container/bg_frane/bg_bottom/text_total").gameObject
	_ui.totalText = transform:Find("Container/bg_frane/bg_bottom/text_total/text_num"):GetComponent("UILabel")
	_ui.resNum = transform:Find("Container/bg_frane/bg_bottom/text_resnum"):GetComponent("UILabel")
	_ui.resNum.text = ""
	if isshop or itemTBData.type == 5 or itemTBData.type == 7 then
	 	_ui.totalTextObj:SetActive(true)
	elseif itemTBData.type == 19 or itemTBData.type == 27 then
		_ui.resNum.gameObject:SetActive(true)
	end
	_ui.totalTextObj:SetActive(true)
	-- local tNum, resNum
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

	--input
	_ui.inputText = transform:Find("Container/bg_frane/bg_bottom/frame_input"):GetComponent("UIInput")
	SetClickCallback(_ui.inputText.gameObject , OkClickCallback)
	
   -- EventDelegate.Set(_ui.inputText.onSubmit, EventDelegate.Callback(OkClickCallback))
    --EventDelegate.Set(_ui.inputText.onChange, EventDelegate.Callback(changeClickCallback))
	
	--slider
	_ui.numSlider = transform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	_ui.numSlider.value = useItemNumber/maxNum --useItem.number
	EventDelegate.Set(_ui.numSlider.onChange,EventDelegate.Callback(function(obj,delta)
		OnValueChange()
	end))
	--SetPressCallback(_ui.numSlider.gameObject, CaculateSlider)
	local listener = UIEventListener.Get(_ui.numSlider.gameObject)
	listener.onPress = listener.onPress + CaculateSlider
	--use btn
	local btnSlider = transform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/bg_schedule/btn_slider"):GetComponent("UIButton")
	SetDragCallback(btnSlider.gameObject , OnDragSlider)
	SetPressCallback(btnSlider.gameObject, CaculateSlider)
	
	local btnUse = transform:Find("Container/bg_frane/btn_use")
	local btnUseText = btnUse:Find("text"):GetComponent("UILabel")
	btnUseText.text = TextMgr:GetText("shop_buy_text")

	SetPressCallback(btnUse.gameObject, ItemUseMuti)
	
	local btnMinus = transform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_minus"):GetComponent("UIButton")
	SetPressCallback(btnMinus.gameObject, ItemUseMinus)
	local btnAdd = transform:Find("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_add"):GetComponent("UIButton")
	SetPressCallback(btnAdd.gameObject, ItemUseAdd)
	
	
	if itemTBData.type == 19 and (itemTBData.subtype ==1001 or itemTBData.subtype ==1002 or
	itemTBData.subtype ==1003 or itemTBData.subtype ==1004) then 
		transform:Find("Container/bg_frane/bg_num_1").gameObject:SetActive(true)
	else
		transform:Find("Container/bg_frane/bg_num_1").gameObject:SetActive(false)
	end 
	
end

function Close()
	_ui = nil
    isshop = false
    maxNum = nil
    leftTime = nil
    actualTime = nil
	defaultUseNum = 1
end
