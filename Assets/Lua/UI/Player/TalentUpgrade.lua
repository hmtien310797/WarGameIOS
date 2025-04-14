module("TalentUpgrade", package.seeall)
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

local function SetBtnEnable(_btn, _isEnable)
	local _sprite_name
	local _color
	if _isEnable then
		_sprite_name = "btn_1"
		_color = Color.white * 1
	else
		_sprite_name = "btn_4"
		_color = Color.white * 0.7
	end
	_btn:GetComponent("UISprite").spriteName = _sprite_name
	_btn:GetComponent("UIButton").normalSprite = _sprite_name
	_btn.normalSprite = _sprite_name
	local _text = _btn.transform:Find("text")
	if _text ~= nil then
		_text:GetComponent("UILabel").gradientTop = _color
		_text:GetComponent("UILabel").gradientBottom = _color
	end
end

local function MakeRightItem(_text, _curnum, _nextnum)
	local item = NGUITools.AddChild(_ui.normal.grid_right.gameObject, _ui.rightinfoitem.gameObject).transform
	item:Find("bg_meijiantou").gameObject:SetActive(false)
	item:Find("bg_title/text"):GetComponent("UILabel").text = _text
	item:Find("bg_daijiantou/num_left"):GetComponent("UILabel").text = _curnum
	item:Find("bg_daijiantou/num_right"):GetComponent("UILabel").text = _nextnum
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

local function UpdateNormal(data)
	_ui.normal.title.text = TextMgr:GetText(data.Name)
	_ui.normal.texture_right.mainTexture = ResourceLibrary:GetIcon("Icon/Talent/", data.Icon)
	local childCount = _ui.normal.grid_right.transform.childCount
	for i = 0, childCount - 1 do
		GameObject.Destroy(_ui.normal.grid_right.transform:GetChild(i).gameObject)
	end
	coroutine.start(function()
		coroutine.step()
		MakeRightItem(TextMgr:GetText("build_ui5"), data.level, data.level + 1)
		local nextdata = TalentInfo.GetTalentByID(_ui.data.BaseData.TechId)[data.level + 1]
		local curvalue = data.level == 0 and 0 or (data.ArmyType == 0 and data.Value or NormalizeValue(data.Value))
		local nextvalue = nextdata.ArmyType == 0 and nextdata.Value or NormalizeValue(nextdata.Value)
		MakeRightItem(TextMgr:GetText(data.Dese), curvalue, nextvalue)
		_ui.normal.grid_right:Reposition()
	end)
	SetClickCallback(_ui.normal.btn_upgrade, function()
		TalentInfoData.RequestLevelUp(data.TechId, 1)
	end)
	SetClickCallback(_ui.normal.btn_max, function()
		local num = math.max(math.min(TalentInfoData.GetCurrentIndexRemainderPoint(), data.MaxLevel - data.level), 1)
		TalentInfoData.RequestLevelUp(data.TechId, num)
	end)
	local enough = true
	for i, v in ipairs(data.Condition) do
		enough = enough and (v.value <= TalentInfoData.GetTalentLevelByIndexId(TalentInfo.GetCurrentIndex(),v.id))
	end
	enough = enough and (TalentInfoData.GetCurrentIndexRemainderPoint() > 0)
	SetBtnEnable(_ui.normal.btn_upgrade, enough)
	SetBtnEnable(_ui.normal.btn_max, enough)
	SetClickCallback(_ui.normal.btn_info, function()
		TalentDetail.Show(data.TechId)
	end)
end

local function MakeTopItem(_text, _num)
	local item = NGUITools.AddChild(_ui.top.grid_right.gameObject, _ui.rightinfoitem.gameObject).transform
	item:Find("bg_daijiantou").gameObject:SetActive(false)
	item:Find("bg_title/text"):GetComponent("UILabel").text = _text
	item:Find("bg_meijiantou/text"):GetComponent("UILabel").text = _num
end

local function UpdateTop(data)
	_ui.top.title.text = TextMgr:GetText(data.Name)
	_ui.top.texture_right.mainTexture = ResourceLibrary:GetIcon("Icon/Talent/", data.Icon)
	local childCount = _ui.top.grid_right.transform.childCount
	for i = 0, childCount - 1 do
		GameObject.Destroy(_ui.top.grid_right.transform:GetChild(i).gameObject)
	end
	coroutine.start(function()
		coroutine.step()
		MakeTopItem(TextMgr:GetText("build_ui5"), data.level)
		local curvalue = data.level == 0 and 0 or (data.ArmyType == 0 and data.Value or NormalizeValue(data.Value))
		MakeTopItem(TextMgr:GetText(data.Dese), curvalue)
		_ui.top.grid_right:Reposition()
	end)
	SetClickCallback(_ui.top.btn_info, function()
		TalentDetail.Show(data.TechId)
	end)
end

UpdateUI = function()
	local level = TalentInfoData.GetTalentLevelByIndexId(TalentInfo.GetCurrentIndex(), _ui.data.BaseData.TechId)
	local _data = TalentInfo.GetTalentByID(_ui.data.BaseData.TechId)[level]
	if _data == nil then
		_data = _ui.data.BaseData
	end
	_data.level = level
	if level < _data.MaxLevel then
		_ui.normal.go:SetActive(true)
		_ui.top.go:SetActive(false)
		UpdateNormal(_data)
	else
		_ui.normal.go:SetActive(false)
		_ui.top.go:SetActive(true)
		UpdateTop(_data)
	end
end

function Awake()
	_ui.normal = {}
	_ui.normal.go = transform:Find("LaboratoryUpgrade_normal").gameObject
	_ui.normal.container = transform:Find("LaboratoryUpgrade_normal/Container").gameObject
	_ui.normal.btn_close = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_top/btn_close").gameObject
	_ui.normal.title = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_top/title"):GetComponent("UILabel")
	_ui.normal.texture_right = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_right/Texture"):GetComponent("UITexture")
	_ui.normal.btn_info = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_right/btn_info").gameObject
	_ui.normal.grid_right = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_right/Grid"):GetComponent("UIGrid")
	_ui.normal.btn_upgrade = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade").gameObject
	_ui.normal.btn_max = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_MAX").gameObject
	_ui.rightinfoitem = transform:Find("LaboratoryUpgrade_normal/BuildingUpgradeRightinfo")
	_ui.top = {}
	_ui.top.go = transform:Find("LaboratoryUpgrade_top").gameObject
	_ui.top.container = transform:Find("LaboratoryUpgrade_top/Container").gameObject
	_ui.top.btn_close = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_top/btn_close").gameObject
	_ui.top.title = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_top/title"):GetComponent("UILabel")
	_ui.top.texture_right = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_right/Texture"):GetComponent("UITexture")
	_ui.top.btn_info = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_right/btn_info").gameObject
	_ui.top.grid_right = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_right/Grid"):GetComponent("UIGrid")
end

function Start()
	SetClickCallback(_ui.normal.container, CloseSelf)
	SetClickCallback(_ui.normal.btn_close, CloseSelf)
	SetClickCallback(_ui.top.container, CloseSelf)
	SetClickCallback(_ui.top.btn_close, CloseSelf)
	UpdateUI()
	TalentInfoData.AddListener(UpdateUI)
end

function Close()
	_ui = nil
	TalentInfoData.RemoveListener(UpdateUI)
end

function Show(data)
	_ui = {}
	_ui.data = data
	Global.OpenUI(_M)
end
