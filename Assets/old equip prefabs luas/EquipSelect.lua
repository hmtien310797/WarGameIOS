module("EquipSelect", package.seeall)
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

local _ui, selected, selected2, param1, param2
local _type, _callback

local UpdateUI, UpdatePos, UpdateAttr

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	selected = 0
	selected2 = 0
end

function Show(type, callback, _param1, _param2)
	_type = type
	_callback = callback
	param1 = _param1 ~= nil and _param1 or 0
	param2 = _param2 ~= nil and _param2 or 0
	print( _type , param1 , param2)
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/close btn").gameObject
	_ui.title = transform:Find("Container/title/text"):GetComponent("UILabel")
	_ui.scrollview = transform:Find("bg2/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("bg2/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("bg2/Scroll View/Grid/listitem_authority")
	_ui.item:Find("Sprite"):GetComponent("UIToggle").group = 99
	_ui.btn_ok = transform:Find("btn ok").gameObject
end

function Start()
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	selected = 0
	UpdateUI()
	SetClickCallback(_ui.btn_ok, function()
		if _callback ~= nil then
			_callback(selected, selected2)
			_callback = nil
		end
		CloseSelf()
	end)
end

UpdateUI = function()
	if _type == 1 then
		UpdatePos()
	else
		UpdateAttr()
	end
end

UpdatePos = function()
	_ui.title.text = TextMgr:GetText("equip_ui21")
	for i = 0 , 7 do
		local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
		item.gameObject:SetActive(true)
		item:Find("text"):GetComponent("UILabel").text = i == 0 and TextMgr:GetText("Target_ui7") or TextMgr:GetText("equip_ui" .. (3 + i))
		item:Find("bg").gameObject:SetActive(i % 2 == 1)
		if param1 == i then
			item:Find("Sprite"):GetComponent("UIToggle"):Set(true)
		end
		local toggle = item:Find("Sprite"):GetComponent("UIToggle")
		EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
			if toggle.value then
            	selected = i
            end
        end))
	end
	_ui.grid:Reposition()
	_ui.scrollview:ResetPosition()
end

UpdateAttr = function()
	_ui.title.text = TextMgr:GetText("equip_ui39")
	local data = EquipData.GetEquipAddTable()
	local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
	item.gameObject:SetActive(true)
	item:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("Target_ui7")
	item:Find("bg").gameObject:SetActive(true)
	if param1 == 0 then
		item:Find("Sprite"):GetComponent("UIToggle"):Set(true)
	end
	local toggle = item:Find("Sprite"):GetComponent("UIToggle")
	EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
		if toggle.value then
	    	selected = 0
	    end
	end))
	local index = 1
	for i, v in pairs(data) do
		for ii, vv in pairs(v) do
			if not (tonumber(i) == 0 and tonumber(ii) == 0) then
				index = index + 1
				local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
				item.gameObject:SetActive(true)
				item:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(i, ii))
				item:Find("bg").gameObject:SetActive(index % 2 == 1)
				if param1 == i and param2 == ii then
					item:Find("Sprite"):GetComponent("UIToggle"):Set(true)
				end
				local toggle = item:Find("Sprite"):GetComponent("UIToggle")
				EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
					if toggle.value then
		            	selected = i
		            	selected2 = ii
		            end
		        end))
		    end
	    end
	end
	_ui.grid:Reposition()
	_ui.scrollview:ResetPosition()
end
