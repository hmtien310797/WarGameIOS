module("EquipChange", package.seeall)
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

local _ui
local UpdateUI
local UpdateItem, UpdateAttr, UpdateSelected
local pos

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	EquipData.RemoveListener(UpdateUI)
end

function Show(_pos)
	pos = _pos
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
	_ui.left_scroll = transform:Find("Container/bg_frane/bg_mid/left/Scroll View"):GetComponent("UIScrollView")
	_ui.left_grid = transform:Find("Container/bg_frane/bg_mid/left/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.left_item = ResourceLibrary.GetUIPrefab("equip/item_equip")
	_ui.right_name = transform:Find("Container/bg_frane/bg_mid/right/name/Label"):GetComponent("UILabel")
	_ui.right_item = transform:Find("Container/bg_frane/bg_mid/right/item_equip")
	_ui.right_pos = transform:Find("Container/bg_frane/bg_mid/right/position/Label"):GetComponent("UILabel")
	_ui.right_lv = transform:Find("Container/bg_frane/bg_mid/right/needlevel/Label"):GetComponent("UILabel")
	_ui.right_combat = transform:Find("Container/bg_frane/bg_mid/right/combat/Label"):GetComponent("UILabel")
	_ui.right_scroll = transform:Find("Container/bg_frane/bg_mid/right/mid/Scroll View"):GetComponent("UIScrollView")
	_ui.right_grid = transform:Find("Container/bg_frane/bg_mid/right/mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.right_attr = transform:Find("Container/item_attribute")
	_ui.btn_upgrade = transform:Find("Container/bg_frane/bg_mid/right/button01").gameObject
	_ui.btn_equip = transform:Find("Container/bg_frane/bg_mid/right/button02").gameObject
	_ui.left = transform:Find("Container/bg_frane/bg_mid/left").gameObject
	_ui.right = transform:Find("Container/bg_frane/bg_mid/right").gameObject
	_ui.none = transform:Find("Container/bg_frane/bg_mid/none").gameObject
	_ui.none_btn = transform:Find("Container/bg_frane/bg_mid/none/btn").gameObject
	EquipData.AddListener(UpdateUI)
end

function Start()
	_ui.title.text = TextMgr:GetText("equip_ui" .. (3 + (pos > 7 and 7 or pos)))
	_ui.btn_upgrade:GetComponent("UIButton").enabled = false
	_ui.btn_equip:GetComponent("UIButton").enabled = false
	_ui.btn_upgrade.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("equip_ui13")
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	UpdateUI()
end

UpdateUI = function()
	local childCount = _ui.left_grid.transform.childCount
	local curData = EquipData.GetCurEquipByPos(pos)
	local equiplist = EquipData.GetEquipListByPos(pos)
	if #equiplist > 0 then
		_ui.right:SetActive(true)
		_ui.left:SetActive(true)
		_ui.none:SetActive(false)
		local index = 0
		for i, v in ipairs(equiplist) do
			local item
			if i <= childCount then
				item = _ui.left_grid.transform:GetChild(i - 1).transform
			else
				item = NGUITools.AddChild(_ui.left_grid.gameObject, _ui.left_item.gameObject).transform
			end
			UpdateItem(item, v)
			SetClickCallback(item.gameObject, function()
				UpdateAttr(curData, v)
				UpdateSelected(equiplist, v)
			end)
			index = i
		end
		for i = index, childCount - 1 do
	        GameObject.Destroy(_ui.left_grid.transform:GetChild(i).gameObject)
	    end
		_ui.left_grid:Reposition()
		_ui.left_scroll:ResetPosition()
		UpdateAttr(curData, curData == nil and equiplist[1] or curData)
		UpdateSelected(equiplist, curData)
	else
		_ui.right:SetActive(false)
		_ui.left:SetActive(false)
		_ui.none:SetActive(true)
		SetClickCallback(_ui.none_btn, function()
			if maincity.GetBuildingByID(44) ~= nil then
				EquipMap.Show(pos > 7 and 7 or pos)
			else
				maincity.SetTargetBuild(44)
				CloseSelf()
				GUIMgr:CloseMenu("MainInformation")
			end
		end)
	end
end

UpdateSelected = function(equiplist ,targetdata)
	for i, v in ipairs(equiplist) do
		local item = _ui.left_grid.transform:GetChild(i - 1).transform
		if targetdata == nil then
			item:Find("selected").gameObject:SetActive(i == 1)
		else
			item:Find("selected").gameObject:SetActive(v == targetdata)
		end
	end
end

UpdateItem = function(item, data)
	if data ~= nil then
		item:GetComponent("UISprite").spriteName = "bg_item" .. data.data.quality
		item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", data.BaseData.icon)
		item:Find("Sprite01").gameObject:SetActive(data.data.parent.pos ~= 0)
		item:Find("Sprite02").gameObject:SetActive(data.data.status > 0)
		local hasequip, materials, isMax = EquipData.CheckMaterials(data.data.baseid, true)
		local canUpgrade = isMax == nil
		for i, v in ipairs(materials) do
			if v.has < v.need then
				canUpgrade = false
			end
		end
		item:Find("Sprite").gameObject:SetActive(canUpgrade and data.data.status == 0)
	else
		item:GetComponent("UISprite").spriteName = "bg_item1"
		item:Find("Texture"):GetComponent("UITexture").mainTexture = nil
		item:Find("Sprite01").gameObject:SetActive(false)
		item:Find("Sprite02").gameObject:SetActive(false)
		item:Find("Sprite").gameObject:SetActive(false)
	end
end

UpdateAttr = function(curData, targetData)
	UpdateItem(_ui.right_item, targetData)
	local childCount = _ui.right_grid.transform.childCount
	local index = 0
	if targetData ~= nil then
		local nameColor = Global.GetLabelColorNew(targetData.BaseData.quality)
		_ui.right_name.text = nameColor[0] .. TextMgr:GetText(targetData.BaseData.name) .. nameColor[1]
		_ui.right_pos.text = TextMgr:GetText("equip_ui" .. (3 + targetData.BaseData.subtype))
		_ui.right_lv.text = targetData.BaseData.charLevel
		EquipData.SetLevelColor(_ui.right_lv, targetData.BaseData.charLevel)
		local hasequip, materials, isMax = EquipData.CheckMaterials(targetData.data.baseid, true)
		local canUpgrade = isMax == nil
		EquipData.SetBtnEnable(_ui.btn_upgrade, canUpgrade, "btn_2")
		for i, v in ipairs(materials) do
			if v.has < v.need then
				canUpgrade = false
			end
		end
		_ui.btn_upgrade.transform:Find("ret").gameObject:SetActive(canUpgrade and targetData.data.status == 0)
		local attrs = EquipData.GetEquipDataByID(targetData.BaseData.id)
		SetClickCallback(_ui.btn_upgrade, function()
			EquipBuild.Show(EquipData.GetEquipDataByID(attrs.Next), targetData)
		end)
		EquipData.SetBtnEnable(_ui.btn_equip, targetData.data.status == 0 and MainData.GetLevel() >= targetData.BaseData.charLevel and (targetData.data.parent.pos == 0 or targetData.data.parent.pos == pos), "btn_1")
		if curData == targetData then
			_ui.btn_equip.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("equip_ui14")
			SetClickCallback(_ui.btn_equip, function()
				EquipData.RequestTakeoffEquip(targetData.data.uniqueid, UpdateUI)
			end)
		else
			_ui.btn_equip.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("equip_ui15")
			SetClickCallback(_ui.btn_equip, function()
				EquipData.RequestWearEquip(targetData.data.uniqueid, pos, UpdateUI)
			end)
		end
		
		if curData == nil then
			curData = targetData
		end
		local list = EquipData.GetDeffent(curData.BaseData.id, targetData.BaseData.id)
		for i, v in ipairs(list) do
			if tonumber(v.BonusType) == nil or tonumber(v.BonusType) > 0 or v.Attype > 0 then
				local item
				if i <= childCount then
					item = _ui.right_grid.transform:GetChild(i - 1).transform
				else
					item = NGUITools.AddChild(_ui.right_grid.gameObject, _ui.right_attr.gameObject).transform
				end
				item:GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(v.BonusType, v.Attype))
				item:Find("Label"):GetComponent("UILabel").text = (curData.BaseData.id == targetData.BaseData.id and "[ffffff]" or (v.Value >= 0 and "[00ff00]+" or "[ff0000]")) .. EquipInfo.NormalizeValue(v.Value) .. (Global.IsHeroPercentAttrAddition(v.Attype) and "%" or "") .. "[-]"
				
				index = i
			end
		end
		_ui.right_combat.text = attrs.EquipData.Fight
	else
		_ui.right_name.text = ""
		_ui.right_pos.text = ""
		_ui.right_lv.text = ""
		_ui.right_combat.text = ""
		EquipData.SetBtnEnable(_ui.btn_equip, false, "btn_1")
		_ui.btn_equip.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("equip_ui15")
		EquipData.SetBtnEnable(_ui.btn_upgrade, false, "btn_2")
	end
	
	for i = index, childCount - 1 do
        GameObject.Destroy(_ui.right_grid.transform:GetChild(i).gameObject)
    end
    _ui.right_grid:Reposition()
end
