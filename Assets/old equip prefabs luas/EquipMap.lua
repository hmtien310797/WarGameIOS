module("EquipMap", package.seeall)
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

local _ui, UpdateUI
local endlesslist
local curpos,curqua,curbonus,curatt
local onesize = 28
local totlesize = 286
local liney = -282

OnCloseCB = nil

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	endlesslist = nil
	if OnCloseCB ~= nil then
		OnCloseCB()
		OnCloseCB = nil
	end
	curpos = nil
	EquipData.RemoveListener(UpdateUI)
end

function Hide()
	CloseSelf()
end

function Show(_pos)
	curpos = _pos
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.left_scroll = transform:Find("Container/bg_frane/bg2/Container/left"):GetComponent("UIScrollView")
	_ui.left_grid = transform:Find("Container/bg_frane/bg2/Container/left/Grid"):GetComponent("UIGrid")
	_ui.left_table = transform:Find("Container/bg_frane/bg2/Container/left/Table"):GetComponent("UITable")
	_ui.pos = {}
	for i = 1, 7 do
		_ui.pos[i] = transform:Find(String.Format("Container/bg_frane/bg2/Container/right/{0}", i))
	end
	_ui.quality = {}
	_ui.quality[1] = transform:Find("Container/bg_frane/bg2/Container/right/white")
	_ui.quality[2] = transform:Find("Container/bg_frane/bg2/Container/right/green")
	_ui.quality[3] = transform:Find("Container/bg_frane/bg2/Container/right/blue")
	_ui.quality[4] = transform:Find("Container/bg_frane/bg2/Container/right/purple")
	_ui.quality[5] = transform:Find("Container/bg_frane/bg2/Container/right/orange")
	_ui.select = transform:Find("Container/bg_frane/bg2/Container/right/select")
	_ui.selectlabel = transform:Find("Container/bg_frane/bg2/Container/right/select/Label"):GetComponent("UILabel")
	
	_ui.kuang1 = transform:Find("Container/bg_frane/bg2/Container/right/kuang1")
	_ui.kuang2 = transform:Find("Container/bg_frane/bg2/Container/right/kuang2")
	
	_ui.item = transform:Find("part")
	EquipData.AddListener(UpdateUI)
end

function Start()
	if curpos == nil then
		curpos = 1
	end
	curqua = 5
	curbonus = 0
	curatt = 0
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	for i, v in ipairs(_ui.pos) do
		SetClickCallback(v.gameObject, function()
			curpos = i
			UpdateUI()
		end)
	end
	for i, v in ipairs(_ui.quality) do
		SetClickCallback(v.gameObject, function()
			curqua = i
			UpdateUI()
		end)
	end
	SetClickCallback(_ui.select:Find("Sprite").gameObject, function()
		EquipSelect.Show(2, function(_selected, _selected2)
			curbonus = _selected
			curatt = _selected2
			UpdateUI()
		end, curbonus, curatt)
	end)
	UpdateUI()
end

UpdateUI = function()
	_ui.kuang1.gameObject:SetActive(true)
	_ui.kuang1.position = _ui.pos[curpos].position
	_ui.kuang2.gameObject:SetActive(true)
	_ui.kuang2.position = _ui.quality[curqua].position
	
	_ui.selectlabel.text = type(curbonus) == "number" and TextMgr:GetText("Target_ui7") or TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(curbonus, curatt))
	
	local data = EquipData.GetEquipMap(curpos, curqua, curbonus, curatt)
	--[[
	if endlesslist == nil then
		endlesslist = EndlessList(_ui.left_scroll)
	end
	endlesslist:SetItem(_ui.item, #data, function(prefab, index)
		local _data = EquipData.GetEquipDataByID(data[index])
		local hasPrevious = _data.Previous > 0
		local nameColor = Global.GetLabelColorNew(_data.BaseData.quality)
		prefab.transform:Find("item_equip"):GetComponent("UISprite").spriteName = "bg_item" .. _data.BaseData.quality
		prefab.transform:Find("item_equip/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", _data.BaseData.icon)
		prefab.transform:Find("name"):GetComponent("UILabel").text = nameColor[0] .. TextMgr:GetText(_data.BaseData.name) .. nameColor[1]
		local level = prefab.transform:Find("level/number"):GetComponent("UILabel")
		level.text = _data.BaseData.charLevel
		EquipData.SetLevelColor(level, _data.BaseData.charLevel)
		local hasequip, materials = EquipData.CheckMaterials(_data.BaseData.id)
		local grid = prefab.transform:Find("Grid1")
		for i = 1, 5 do
			local tipitem = grid.transform:GetChild(i - 1).transform
			if hasPrevious then
				if i == 1 then
					tipitem:Find("Sprite").gameObject:SetActive(hasequip ~= nil)
				else
					tipitem.gameObject:SetActive(materials[i - 1] ~= nil)
					if materials[i - 1] ~= nil then
						tipitem:Find("Sprite").gameObject:SetActive(materials[i - 1].has >= materials[i - 1].need)
					end
				end
			else
				tipitem.gameObject:SetActive(materials[i] ~= nil)
				if materials[i] ~= nil then
					tipitem:Find("Sprite").gameObject:SetActive(materials[i].has >= materials[i].need)
				end
			end
		end
		local grid = prefab.transform:Find("Grid2")
		for i = 1, 6 do
			local attitem = grid.transform:GetChild(i - 1).transform
			if tonumber(_data.BaseBonus[i].BonusType) == nil or tonumber(_data.BaseBonus[i].BonusType) > 0 or _data.BaseBonus[i].Attype > 0 then
				attitem.gameObject:SetActive(true)
				local attname = attitem:GetComponent("UILabel")
				attname.text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(_data.BaseBonus[i].BonusType, _data.BaseBonus[i].Attype))
				local attvalue = attitem:Find("Label"):GetComponent("UILabel")
				attvalue.text = EquipInfo.NormalizeValue(_data.BaseBonus[i].Value) .. (Global.IsHeroPercentAttrAddition(_data.BaseBonus[i].Attype) and "%" or "")
				if type(curbonus) ~= "number" then
					if curbonus == _data.BaseBonus[i].BonusType and curatt == _data.BaseBonus[i].Attype then
						attname.color = Color.yellow
						attvalue.color = Color.yellow
					else
						attname.color = Color.white
						attvalue.color = Color.white
					end
				else
					attname.color = Color.white
					attvalue.color = Color.white
				end
			else
				attitem.gameObject:SetActive(false)
			end
		end
		SetClickCallback(prefab.transform:Find("button").gameObject, function()
			EquipBuild.Show(_data)
		end)
	end)
	--]]
	
	coroutine.start(function()
		local childCount = _ui.left_table.transform.childCount
		_ui.left_scroll:ResetPosition()
		local shownum = 0
		for i, v in ipairs(data) do
			shownum = i
		    local prefab
		    if i - 1 < childCount then
		    	prefab = _ui.left_table.transform:GetChild(i - 1)
		    else
		    	prefab = NGUITools.AddChild(_ui.left_table.gameObject, _ui.item.gameObject).transform
		    end
		    local _data = EquipData.GetEquipDataByID(v)
			local hasPrevious = _data.Previous > 0
			local nameColor = Global.GetLabelColorNew(_data.BaseData.quality)
			prefab.transform:Find("item_equip"):GetComponent("UISprite").spriteName = "bg_item" .. _data.BaseData.quality
			prefab.transform:Find("item_equip/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", _data.BaseData.icon)
			prefab.transform:Find("name"):GetComponent("UILabel").text = nameColor[0] .. TextMgr:GetText(_data.BaseData.name) .. nameColor[1]
			local level = prefab.transform:Find("level/number"):GetComponent("UILabel")
			level.text = _data.BaseData.charLevel
			EquipData.SetLevelColor(level, _data.BaseData.charLevel)
			local hasequip, materials = EquipData.CheckMaterials(_data.BaseData.id)
			local grid = prefab.transform:Find("Grid1")
			for i = 1, 5 do
				local tipitem = grid.transform:GetChild(i - 1).transform
				if hasPrevious then
					if i == 1 then
						tipitem:Find("Sprite").gameObject:SetActive(hasequip ~= nil)
					else
						tipitem.gameObject:SetActive(materials[i - 1] ~= nil)
						if materials[i - 1] ~= nil then
							tipitem:Find("Sprite").gameObject:SetActive(materials[i - 1].has >= materials[i - 1].need)
						end
					end
				else
					tipitem.gameObject:SetActive(materials[i] ~= nil)
					if materials[i] ~= nil then
						tipitem:Find("Sprite").gameObject:SetActive(materials[i].has >= materials[i].need)
					end
				end
			end
			local grid = prefab.transform:Find("Grid2")
			local hidecount = 0
			for i = 1, 6 do
				local attitem = grid.transform:GetChild(i - 1).transform
				if tonumber(_data.BaseBonus[i].BonusType) == nil or tonumber(_data.BaseBonus[i].BonusType) > 0 or _data.BaseBonus[i].Attype > 0 then
					attitem.gameObject:SetActive(true)
					local attname = attitem:GetComponent("UILabel")
					attname.text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(_data.BaseBonus[i].BonusType, _data.BaseBonus[i].Attype))
					local attvalue = attitem:Find("Label"):GetComponent("UILabel")
					attvalue.text = EquipInfo.NormalizeValue(_data.BaseBonus[i].Value) .. (Global.IsHeroPercentAttrAddition(_data.BaseBonus[i].Attype) and "%" or "")
					if type(curbonus) ~= "number" then
						if curbonus == _data.BaseBonus[i].BonusType and curatt == _data.BaseBonus[i].Attype then
							attname.color = Color.yellow
							attvalue.color = Color.yellow
						else
							attname.color = Color.white
							attvalue.color = Color.white
						end
					else
						attname.color = Color.white
						attvalue.color = Color.white
					end
				else
					hidecount = hidecount + 1
					attitem.gameObject:SetActive(false)
				end
			end
			prefab:GetComponent("UIWidget").height = totlesize - onesize * hidecount
			prefab:Find("line").localPosition = Vector3(-22, liney + onesize *hidecount)
			SetClickCallback(prefab.transform:Find("button").gameObject, function()
				EquipBuild.Show(_data)
			end)
			_ui.left_table:Reposition()
			coroutine.step()
		end
		for i = shownum + 1, childCount do
			GameObject.Destroy(_ui.left_table.transform:GetChild(i - 1).gameObject)
		end
		_ui.left_table:Reposition()
	end)
end
