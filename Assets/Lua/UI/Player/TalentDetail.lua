module("TalentDetail", package.seeall)
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

local function CloseSelf()
	Global.CloseUI(_M)
end

function Awake()
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.title = transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
	_ui.text_miaosu = transform:Find("Container/bg_frane/text_miaosu"):GetComponent("UILabel")
	_ui.text_miaosu3 = transform:Find("Container/bg_frane/bg_mid/bg_title/text (3)"):GetComponent("UILabel")
	_ui.scroll = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.infoitem = transform:Find("Detailsinfo")
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	UpdateUI()
end

local function NormalizeValue(value)
	local s = tostring(value)
	local index = string.find(s, '.')
	if index ~= nil then
		s = string.sub(s, 0, index + 3)
		if string.find(s, "0", #s) then
			s = string.sub(s, 0, index + 2)
		end
	end
	return s .. "%"
end

UpdateUI = function()
	local data = TalentInfo.GetTalentByID(_ui.id)
	local level = TalentInfoData.GetTalentLevelById(_ui.id)
	_ui.title.text = TextMgr:GetText(data.BaseData.Name)
	local curvalue = level == 0 and 0 or (data[level].ArmyType == 0 and data[level].Value or NormalizeValue(data[level].Value))
	_ui.text_miaosu.text = TextMgr:GetText(data.BaseData.Dese) .. curvalue
	_ui.text_miaosu3.text = TextMgr:GetText(data.BaseData.Dese)
	for i = 1, data.BaseData.MaxLevel do
		local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.infoitem.gameObject).transform
		item:Find("text (1)"):GetComponent("UILabel").text = i
		item:Find("text (2)"):GetComponent("UILabel").text = data[i].AddFight
		local curvalue = data[i].ArmyType == 0 and data[i].Value or NormalizeValue(data[i].Value)
		item:Find("text (3)"):GetComponent("UILabel").text = curvalue
		if i % 2 == 0 then
			item:Find("bg_list").gameObject:SetActive(false)
		end
		item:Find("bg_select").gameObject:SetActive(i == level)
		if i== level then 
			item:Find("text (1)"):GetComponent("UILabel").color = Color.white
			item:Find("text (2)"):GetComponent("UILabel").color = Color.white
			item:Find("text (3)"):GetComponent("UILabel").color = Color.white
		end 
		
	end
	_ui.grid:Reposition()
	_ui.scroll:MoveRelative(Vector3.New(0, _ui.grid.cellHeight * math.max((level - 1), 0), 0))
	_ui.scroll:RestrictWithinBounds(true)
end

function Close()
	_ui = nil
end

function Show(id)
	_ui = {}
	_ui.id = id
	Global.OpenUI(_M)
end