module("EquipCompound", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui, UpdateUI, UpdateItem
local data

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	data = nil
end

function Show(_data)
	data = _data
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/content 1/bg_frane/top/btn_close").gameObject
	_ui.title = transform:Find("Container/content 1/bg_frane/top/Label"):GetComponent("UILabel")
	_ui.page1 = transform:Find("Container/page1").gameObject
	_ui.page2 = transform:Find("Container/page2").gameObject
	_ui.item = transform:Find("Container/content 1/bg_frane/item_equip")
	_ui.desc = transform:Find("Container/content 1/bg_frane/text"):GetComponent("UILabel")
	_ui.grid = transform:Find("Container/content 1/bg_frane/mid/Grid"):GetComponent("UIGrid")
	_ui.title2 = transform:Find("Container/content 1/bg_frane/mid/title/Label"):GetComponent("UILabel")
	_ui.btn1 = transform:Find("Container/content 1/bg_frane/button01").gameObject
	_ui.btn1:GetComponent("UIButton").enabled = false
	_ui.btn2 = transform:Find("Container/content 1/bg_frane/button02").gameObject
	_ui.btn2:GetComponent("UIButton").enabled = false
	_ui.btn3 = transform:Find("Container/content 1/bg_frane/button03").gameObject
	_ui.btn3:GetComponent("UIButton").enabled = false
	_ui.btn3.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("equip_ui24")
	_ui.targeter = transform:Find("Container/content 1/bg_frane/mid/Container")
	_ui.smallitem = ResourceLibrary.GetUIPrefab("equip/item_equipsmall")
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.page1, function() UpdateUI(1) end)
	SetClickCallback(_ui.page2, function() UpdateUI(2) end)
	
	UpdateUI(1)
end

local function SetBtnEnable(enabled)
	if enabled then
		_ui.btn1:GetComponent("UISprite").spriteName = "btn_1"
	else
		_ui.btn1:GetComponent("UISprite").spriteName = "btn_4"
	end
	_ui.btn1:GetComponent("BoxCollider").enabled = enabled
end

local function UpdateSmallItem(page, index)
	local previous
	if page == 1 then
		index = math.max(index, 2)
		previous = index - 1
		_ui.targeter.localEulerAngles = Vector3.zero
		local canUpgrade = _ui.datalist[previous].num / _ui.datalist[index].data.data.Num
		if canUpgrade >= 2 then
			_ui.btn1:SetActive(false)
			_ui.btn2:SetActive(true)
			_ui.btn3:SetActive(true)
		else
			_ui.btn1:SetActive(true)
			_ui.btn2:SetActive(false)
			_ui.btn3:SetActive(false)
		end
		_ui.btn1.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("equip_ui24")
		SetClickCallback(_ui.btn1, function()
			EquipData.RequestComposeMaterial(_ui.datalist[index].data.BaseData.id, 1, function()
				UpdateUI(page, index)
			end)
		end)
		SetClickCallback(_ui.btn2, function()
			EquipData.RequestComposeMaterial(_ui.datalist[index].data.BaseData.id, canUpgrade, function()
				UpdateUI(page, index)
			end)
		end)
		SetClickCallback(_ui.btn3, function()
			EquipData.RequestComposeMaterial(_ui.datalist[index].data.BaseData.id, 1, function()
				UpdateUI(page, index)
			end)
		end)
		SetBtnEnable(canUpgrade >= 1)
		local need = _ui.datalist[index].data.data.Num
		for i, v in ipairs(_ui.numlist) do
			if i == previous then
				v.text = (_ui.datalist[i].num / need >= 1 and "[ffffff]" or "[ff0000]") .. _ui.datalist[i].num .. "[-]/" .. need
			else
				v.text = _ui.datalist[i].num
			end
		end
	else
		index = math.min(index, 4)
		previous = index + 1
		_ui.targeter.localEulerAngles = Vector3(0, 180, 0)
		_ui.btn1:SetActive(true)
		_ui.btn2:SetActive(false)
		_ui.btn3:SetActive(false)
		_ui.btn1.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("equip_ui20")
		SetClickCallback(_ui.btn1, function()
			EquipData.RequestDecomposeMaterial(_ui.datalist[previous].serverdata.data.uniqueid, function()
				UpdateUI(page, index)
			end)
		end)
		SetBtnEnable(_ui.datalist[previous].num >= 1)
		for i, v in ipairs(_ui.numlist) do
			if i == previous then
				v.text = (_ui.datalist[i].num >= 1 and "[ffffff]" or "[ff0000]") .. _ui.datalist[i].num .. "/" .. 1
			else
				v.text = _ui.datalist[i].num
			end
		end
	end
	_ui.targeter.position = _ui.itemlist[index].position
	
end

UpdateUI = function(page, i)
	local childCount = _ui.grid.transform.childCount
	local nameColor = Global.GetLabelColorNew(data.BaseData.quality)
	_ui.title.text = nameColor[0] .. TextMgr:GetText(data.BaseData.name) .. nameColor[1]
	_ui.item:GetComponent("UISprite").spriteName = "bg_item" .. data.BaseData.quality
	_ui.item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", data.BaseData.icon)
	_ui.desc.text = TextMgr:GetText(data.BaseData.description)
	local list, index = EquipData.GetMaterialSeries(data.BaseData.id)
	if i ~= nil then
		index = i
	end
	_ui.datalist = {}
	_ui.itemlist = {}
	_ui.numlist = {}
	local materiallist = EquipData.GetMaterialList()
	for i, v in ipairs(list) do
		local mdata = EquipData.GetMaterialByID(v)
		local item
		if i <= childCount then
			item = _ui.grid.transform:GetChild(i - 1).transform
		else
			item = NGUITools.AddChild(_ui.grid.gameObject, _ui.smallitem.gameObject).transform
		end
		item.name = i
		_ui.itemlist[i] = item
		item:GetComponent("UISprite").spriteName = "bg_item" .. mdata.BaseData.quality
		item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", mdata.BaseData.icon)
		item:Find("kuang").gameObject:SetActive(false)
		local itemnum = item:Find("Label"):GetComponent("UILabel")
		itemnum.gameObject:SetActive(true)
		local serverdata = EquipData.GetMaterialServerDataByID(v)
		itemnum.text = serverdata ~= nil and serverdata.data.number or 0
		_ui.numlist[i] = itemnum
		SetClickCallback(item.gameObject, function(go)
			local targetnum = tonumber(go.name)
			UpdateSmallItem(page, targetnum)
		end)
		local _data = {}
		_data.data = mdata
		_data.num = serverdata ~= nil and serverdata.data.number or 0
		_data.serverdata = serverdata
		_ui.datalist[i] = _data
	end
	_ui.grid:Reposition()
	UpdateSmallItem(page, index)
	
	if page == 1 then
		_ui.title2.text = TextMgr:GetText("equip_ui22")
	else
		_ui.title2.text = TextMgr:GetText("equip_ui23")
	end
end
