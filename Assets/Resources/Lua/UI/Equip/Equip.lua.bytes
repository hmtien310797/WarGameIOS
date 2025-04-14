module("Equip", package.seeall)
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

local _ui, UpdateUI1, UpdateUI2, UpdateItem1, UpdateItem2, selected, UpdateCallBack
local curpage = 1

OnCloseCB = nil

local itemtipslist , itemTipTarget

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	if itemtipslist == nil then
		return
	end
	print(go.name)
	for i, v in pairs(itemtipslist) do
		if go == v.gameObject then
			--local itemdata = TableMgr:GetItemData(tonumber(go.name))
			go:SendMessage("OnClick")
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({BaseData = v.BaseData} , "equipTips")
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
					Tooltip.ShowItemTip({BaseData = v.BaseData} , "equipTips")
		        end
		    end
		    return
		end
	end
	Tooltip.HideItemTip()
end

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	Tooltip.HideItemTip()
	itemtipslist = nil
	_ui = nil
	if OnCloseCB ~= nil then
		OnCloseCB()
		OnCloseCB = nil
	end
	EquipData.RemoveListener(UpdateCallBack)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Show()
	Global.OpenUI(_M)
end

function Awake()
	itemtipslist = {}
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.page1 = transform:Find("Container/bg_frane/bg2/page1"):GetComponent("UIToggle")
	_ui.page2 = transform:Find("Container/bg_frane/bg2/page2"):GetComponent("UIToggle")
	_ui.scroll1 = transform:Find("Container/bg_frane/bg2/content 1/Scroll View"):GetComponent("UIScrollView")
	_ui.grid1 = transform:Find("Container/bg_frane/bg2/content 1/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.noone = transform:Find("Container/bg_frane/bg2/content 1/no one"):GetComponent("UILabel")
	_ui.select = transform:Find("Container/bg_frane/bg2/select")
	_ui.selectlabel = transform:Find("Container/bg_frane/bg2/select/Label"):GetComponent("UILabel")
	_ui.item = transform:Find("item_equip")
	
	EquipData.AddListener(UpdateCallBack)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	selected = 0
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.page1.gameObject, UpdateUI1)
	SetClickCallback(_ui.page2.gameObject, UpdateUI2)
	SetClickCallback(_ui.select:Find("button").gameObject, function()
		EquipSelect.Show(1, function(_selected)
			selected = _selected
			_ui.selectlabel.text = selected == 0 and TextMgr:GetText("Target_ui7") or TextMgr:GetText("equip_ui" .. (3 + selected))
			UpdateUI1()
		end, selected)
	end)
	_ui.page1:Set(true)
	UpdateUI1()
	_ui.selectlabel.text = TextMgr:GetText("Target_ui7")
end

UpdateCallBack = function()
	if curpage == 1 then
		UpdateUI1()
	else
		UpdateUI2()
	end
end

local function UpdateUI(data, page)
	local childCount = _ui.grid1.transform.childCount
	local index = 0
	for i, v in ipairs(data) do
		local item
		if i <= childCount then
			item = _ui.grid1.transform:GetChild(i - 1).transform
		else
			item = NGUITools.AddChild(_ui.grid1.gameObject, _ui.item.gameObject).transform
		end
		UpdateItem(item, v)
		if page == 2 then
			local temp = {}
			temp.gameObject = item.gameObject
			temp.BaseData = v.BaseData
			table.insert(itemtipslist, temp)
		end
		SetClickCallback(item.gameObject, function()
			if page == 1 then
				local attrs = EquipData.GetEquipDataByID(v.BaseData.id)
				local hasnext = EquipData.GetEquipDataByID(attrs.Next) ~= nil
				if hasnext then
					EquipBuildNew.Show(EquipData.GetEquipDataByID(attrs.Next))
				else
					FloatText.ShowAt(item.gameObject.transform.position, TextMgr:GetText("equip_ui54"), Color.white)
				end
				--EquipInfo.Show(v)
			else
				--EquipCompound.Show(v)
			end
		end)
		index = i
	end
	for i = index, childCount - 1 do
        GameObject.Destroy(_ui.grid1.transform:GetChild(i).gameObject)
    end
	_ui.grid1:Reposition()
	_ui.scroll1:ResetPosition()
	_ui.noone.gameObject:SetActive(#data == 0)
	_ui.noone.text = TextMgr:GetText("equip_ui4" .. (2 + page))
end

UpdateUI1 = function()
	curpage = 1
	local equiplist = {}
	if selected == 0 then
		equiplist = EquipData.GetEquipList()
	else
		equiplist = EquipData.GetEquipListByPos(selected)
	end
	itemtipslist = {}
	UpdateUI(equiplist, 1)
	_ui.select.gameObject:SetActive(true)
end

UpdateUI2 = function()
	curpage = 2
	local materiallist = EquipData.GetMaterialList()
	UpdateUI(materiallist, 2)
	_ui.select.gameObject:SetActive(false)
end

UpdateItem = function(item, data)
	item:GetComponent("UISprite").spriteName = "bg_item" .. data.data.quality
	item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", data.BaseData.icon)
	item:Find("Sprite01").gameObject:SetActive(data.data.parent.pos ~= nil and data.data.parent.pos > 0)
	item:Find("Sprite02").gameObject:SetActive(data.data.status > 0)
	local level = item:Find("level/num"):GetComponent("UILabel")
	if data.BaseData.type == 200 then
		local hasequip, materials, isMax = EquipData.CheckMaterials(data.data.baseid, true)
		local canUpgrade = isMax == nil
		for i, v in ipairs(materials) do
			if v.has < v.need then
				canUpgrade = false
			end
		end
		item:Find("Sprite").gameObject:SetActive(canUpgrade and data.data.status == 0)
		level.text = data.BaseData.itemlevel
		level.transform.parent.gameObject:SetActive(data.BaseData.itemlevel > 0)
	else
		item:Find("Sprite").gameObject:SetActive(false)
		level.transform.parent.gameObject:SetActive(false)
	end
	local num = item:Find("num_item"):GetComponent("UILabel")
	num.text = data.data.number
	num.gameObject:SetActive(data.data.number > 1)
end
