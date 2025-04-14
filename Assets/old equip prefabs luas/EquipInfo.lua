module("EquipInfo", package.seeall)
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

local _ui, UpdateItem, data

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
	_ui.btn_close = transform:Find("Container/bg_frane/top/btn_close").gameObject
	_ui.item = transform:Find("Container/bg_frane/item_equip")
	_ui.name = transform:Find("Container/bg_frane/top/Label"):GetComponent("UILabel")
	_ui.pos = transform:Find("Container/bg_frane/position/Label"):GetComponent("UILabel")
	_ui.level = transform:Find("Container/bg_frane/needlevel/Label"):GetComponent("UILabel")
	_ui.combat = transform:Find("Container/bg_frane/combat/Label"):GetComponent("UILabel")
	_ui.grid = transform:Find("Container/bg_frane/mid/Grid"):GetComponent("UIGrid")
	_ui.attr = transform:Find("Container/item_attribute")
	
	_ui.btn_upgrade = transform:Find("Container/bg_frane/button01").gameObject
	_ui.btn_decomposition = transform:Find("Container/bg_frane/button02").gameObject
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	UpdateItem(_ui.item, data)
end

UpdateItem = function(item, data)
	item:GetComponent("UISprite").spriteName = "bg_item" .. data.data.quality
	item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", data.BaseData.icon)
	item:Find("Sprite01").gameObject:SetActive(data.data.parent.pos ~= nil and data.data.parent.pos > 0)
	item:Find("Sprite02").gameObject:SetActive(data.data.status > 0)
	item:Find("Sprite").gameObject:SetActive(false)
	
	local nameColor = Global.GetLabelColorNew(data.BaseData.quality)
	_ui.name.text = nameColor[0] .. TextMgr:GetText(data.BaseData.name) .. nameColor[1]
	_ui.pos.text = TextMgr:GetText("equip_ui" .. (3 + data.BaseData.subtype))
	_ui.level.text = data.BaseData.charLevel
	EquipData.SetLevelColor(_ui.level, data.BaseData.charLevel)
	local attrs = EquipData.GetEquipDataByID(data.BaseData.id)
	for i, v in ipairs(attrs.BaseBonus) do
		if tonumber(v.BonusType) == nil or tonumber(v.BonusType) > 0 or v.Attype > 0 then
			local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.attr.gameObject).transform
			item:GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(v.BonusType, v.Attype))
			item:Find("Label"):GetComponent("UILabel").text = NormalizeValue(v.Value) .. (Global.IsHeroPercentAttrAddition(v.Attype) and "%" or "")
		end
	end
	_ui.grid:Reposition()
	_ui.combat.text = attrs.EquipData.Fight
	local hasequip, materials, isMax = EquipData.CheckMaterials(data.data.baseid, true)
	local canUpgrade = isMax == nil and attrs.EquipData.NeedMaterial ~= "NA"
	EquipData.SetBtnEnable(_ui.btn_upgrade, canUpgrade, "btn_1")
	for i, v in ipairs(materials) do
		if v.has < v.need then
			canUpgrade = false
		end
	end
	_ui.btn_upgrade.transform:Find("Sprite").gameObject:SetActive(canUpgrade and data.data.status == 0)
	SetClickCallback(_ui.btn_upgrade, function()
		EquipBuild.Show(EquipData.GetEquipDataByID(attrs.Next))
	end)
	EquipData.SetBtnEnable(_ui.btn_decomposition, data.data.status == 0 and attrs.EquipData.Recycling ~= "NA", "btn_2")
	SetClickCallback(_ui.btn_decomposition, function()
		MessageBox.Show(TextMgr:GetText("equip_ui45"), function()
            EquipData.RequestDecomposeEquip(data.data.uniqueid)
            CloseSelf()
        end,
        function()
        end)
	end)
end

function NormalizeValue(value)
	--[[value = math.floor(value * 100 + 0.5) / 100
	local s = tostring(value)
	local index = string.find(s, '.')
	if index ~= nil then
		s = string.sub(s, 0, index + 3)
		if string.find(s, "0", #s) then
			s = string.sub(s, 0, index + 2)
		end
	end--]]
	return System.String.Format("{0:F}" , value)
end