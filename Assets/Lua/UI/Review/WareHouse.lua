module("WareHouse",package.seeall)

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

local moneyLabelList
local container
local wareInfo

local ShowContent
local GetWareData

OnCloseCB = nil

local function UseItemFunc(useItemId , exItemid , count)
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
            Global.ShowError(msg.code)
		else
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end		
			useItemReward = msg.reward
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			FloatText.Show(TextMgr:GetText("item_ui1")..TextMgr:GetText("ui_hero_exp") .. itemTBData.param1 * count , Color.green ,ResourceLibrary:GetIcon("Item/", itemTBData.icon))
			
			MainCityUI.UpdateRewardData(msg.fresh)
		end
	end, true)
end

function GetProtectedResNum(parambase)
	local params = {}
    params.base = parambase
	return AttributeBonus.CallBonusFunc(45 , params)
end

GetWareData = function()
	local build = maincity.GetCurrentBuildingData()
	local level = build.data.level
	local wareTableData = TableMgr:GetWareData(level)
	local protect = 0
	
	AttributeBonus.CollectBonusInfo()
	moneyLabelList = {}
	moneyLabelList[Common_pb.MoneyType_Food] = {}
	protect = GetProtectedResNum(wareTableData.pvFood)
	moneyLabelList[Common_pb.MoneyType_Food].value = MoneyListData.GetMoneyByType(Common_pb.MoneyType_Food)
	moneyLabelList[Common_pb.MoneyType_Food].name = System.String.Format(TextMgr:GetText("warehouse_ui1") , Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_Food)))
	moneyLabelList[Common_pb.MoneyType_Food].active = maincity.IsBuildingUnlockByID(11)
	moneyLabelList[Common_pb.MoneyType_Food].pvalue = protect
	moneyLabelList[Common_pb.MoneyType_Food].upvalue = math.max(0,MoneyListData.GetMoneyByType(Common_pb.MoneyType_Food) - protect)
	moneyLabelList[Common_pb.MoneyType_Food].exid = 5

	moneyLabelList[Common_pb.MoneyType_Iron] = {}
	protect = GetProtectedResNum(wareTableData.pvIron)
	moneyLabelList[Common_pb.MoneyType_Iron].value = MoneyListData.GetMoneyByType(Common_pb.MoneyType_Iron)
	moneyLabelList[Common_pb.MoneyType_Iron].name = System.String.Format(TextMgr:GetText("warehouse_ui2") , Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_Iron)))
	moneyLabelList[Common_pb.MoneyType_Iron].active = maincity.IsBuildingUnlockByID(12)
	moneyLabelList[Common_pb.MoneyType_Iron].pvalue = protect
	moneyLabelList[Common_pb.MoneyType_Iron].upvalue = math.max(0,MoneyListData.GetMoneyByType(Common_pb.MoneyType_Iron) - protect)
	moneyLabelList[Common_pb.MoneyType_Iron].exid = 6
	
	
	moneyLabelList[Common_pb.MoneyType_Oil] = {}
	protect = GetProtectedResNum(wareTableData.pvOil)
	moneyLabelList[Common_pb.MoneyType_Oil].value = MoneyListData.GetMoneyByType(Common_pb.MoneyType_Oil)
	moneyLabelList[Common_pb.MoneyType_Oil].name = System.String.Format(TextMgr:GetText("warehouse_ui3") , Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_Oil)))
	moneyLabelList[Common_pb.MoneyType_Oil].active = maincity.IsBuildingUnlockByID(13)
	moneyLabelList[Common_pb.MoneyType_Oil].pvalue = protect
	moneyLabelList[Common_pb.MoneyType_Oil].upvalue = math.max(0,MoneyListData.GetMoneyByType(Common_pb.MoneyType_Oil) - protect)
	moneyLabelList[Common_pb.MoneyType_Oil].exid = 7
	
	moneyLabelList[Common_pb.MoneyType_Elec] = {}
	protect = GetProtectedResNum(wareTableData.pvElectric)
	moneyLabelList[Common_pb.MoneyType_Elec].value = MoneyListData.GetMoneyByType(Common_pb.MoneyType_Elec)
	moneyLabelList[Common_pb.MoneyType_Elec].name = System.String.Format(TextMgr:GetText("warehouse_ui4") , Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_Elec)))
	moneyLabelList[Common_pb.MoneyType_Elec].active = maincity.IsBuildingUnlockByID(14)
	moneyLabelList[Common_pb.MoneyType_Elec].pvalue = protect
	moneyLabelList[Common_pb.MoneyType_Elec].upvalue = math.max(0,MoneyListData.GetMoneyByType(Common_pb.MoneyType_Elec) - protect)
	moneyLabelList[Common_pb.MoneyType_Elec].exid = 8
	
end

local function AddClickCallback(go)
	local exItemid = tonumber(go.name)
	local items = {}
	local itemdata = TableMgr:GetItemExchangeListData(exItemid).itemID
	local str = {}
	local isNoitem = false
	str = itemdata:split(";")
	for i,v in ipairs(str) do
		local itemPar = {}
		itemPar = v:split(":")
		
		local item = {}
		item.itemid = tonumber(itemPar[1])
		item.exid = tonumber(itemPar[2])
		table.insert(items , item)
	end
	
	local noirtem = Global.BagIsNoItem(items)
	local noItemHint = TextMgr:GetText("player_ui18")
	if noirtem == true then
		FloatText.Show(noItemHint)
		return
	end
	
	CommonItemBag.SetTittle(TextMgr:GetText("get_resource1"))
	CommonItemBag.SetResType(Common_pb.MoneyType_None)
	CommonItemBag.SetItemList(items, 0)
	CommonItemBag.SetUseFunc(UseItemFunc)
	GUIMgr:CreateMenu("CommonItemBag" , false)
	CommonItemBag.OnOpenCB = function()
	end
end

ShowContent = function()
	while container.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(container.grid.transform:GetChild(0).gameObject);
	end

	for k, v in pairs(moneyLabelList) do
		if v ~= nil and v.active then
			local info = NGUITools.AddChild(container.grid.gameObject , wareInfo.gameObject)
			info.transform:SetParent(container.grid.transform , false)
			info.gameObject:SetActive(true)
			
			local icon = info.transform:Find("bg_icon/icon"):GetComponent("UITexture")
			icon.mainTexture = ResourceLibrary:GetIcon("Item/", k)
			
			local tValue = info.transform:Find("name"):GetComponent("UILabel")
			tValue.text = moneyLabelList[k].name
			
			local pValue = info.transform:Find("bg_array_left/Text"):GetComponent("UILabel")
			
			pValue.text = Global.ExchangeValue(moneyLabelList[k].pvalue)
			--pValue.text = Global.ExchangeValue(math.min(moneyLabelList[k].value , moneyLabelList[k].pvalue))

			local upValueIcon = info.transform:Find("bg_array_right/icon_unprotect")
			local upValue = info.transform:Find("bg_array_right/Text"):GetComponent("UILabel")
			upValue.text = Global.ExchangeValue(moneyLabelList[k].upvalue)
	
			
			local pValueSider = info.transform:Find("bg_array_left/array"):GetComponent("UISlider")
			pValueSider.value = math.min( 1,  moneyLabelList[k].value/moneyLabelList[k].pvalue)
			
			local upValueSider = info.transform:Find("bg_array_right/array"):GetComponent("UISlider")
			upValueSider.value = math.min( 1,  moneyLabelList[k].upvalue/moneyLabelList[k].pvalue)
			
			local addBtn = info.transform:Find("btn_get"):GetComponent("UIButton")
			addBtn.gameObject.name = tostring(moneyLabelList[k].exid)
			SetClickCallback(addBtn.gameObject , AddClickCallback)
		end
	end
	container.grid:Reposition()
end

local function UpdateContent()
	--AttributeBonus.CollectBonusInfo()
	GetWareData()
	ShowContent()
end

function Awake()
    container = {}
    container.go = transform:Find("Container").gameObject
    container.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    container.grid = transform:Find("Container/bg_frane/bg_mid/Grid"):GetComponent("UIGrid")
	container.tittle = transform:Find("Container/bg_frane/text_miaosu"):GetComponent("UILabel")
	
	wareInfo = transform:Find("wareinfo")
	GetWareData()
	
	MoneyListData.AddListener(UpdateContent)
	
end

function Start()
    SetClickCallback(container.go, function()
    	GUIMgr:CloseMenu("WareHouse")
    end)
 
    SetClickCallback(container.btn_close.gameObject, function()
    	GUIMgr:CloseMenu("WareHouse")
    end)
	
	ShowContent()


end

function Close()
	MoneyListData.RemoveListener(UpdateContent)
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
	
	container = nil
	wareInfo = nil
end
