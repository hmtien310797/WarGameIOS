module("rebel_history", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local data

local ui

local isInViewport = false

--- APIs ---
Show = nil
Hide = nil

Start = nil
Close = nil
------------

local Draw = nil
local LoadData = nil
local LoadUI = nil
local SetUI = nil

Show = function()
	if not isInViewport then
		RebelData.RequestData(function()
			data = RebelData.GetData()
			Global.OpenUI(_M)
		end)
	end
end

Hide = function()
	if isInViewport then
		Global.CloseUI(_M)
	end
end

Start = function()
	isInViewport = true

	Draw()
end

Close = function()
	isInViewport = false

	data = nil

	ui = nil
end

Draw = function()
	LoadUI()
	SetUI()
end

LoadUI = function()
	if ui == nil then
		ui = {}

		UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
			Hide()
		end)

		ui.record = {}
		ui.record.gameObject = transform:Find("Container/bg/Sprite_level").gameObject
		ui.record.level = ui.record.gameObject.transform:Find("number"):GetComponent("UILabel")

		ui.date = {}
		ui.date.gameObject = transform:Find("Container/bg/Sprite_des/Label").gameObject
		ui.date.display = ui.date.gameObject.transform:GetComponent("UILabel")

		ui.label_none = {}
		ui.label_none.gameObject = transform:Find("Container/bg/Sprite_des/none").gameObject
		ui.label_none.display = ui.label_none.gameObject.transform:GetComponent("UILabel")
	end
end

SetUI = function()
	local bestLevel = data.historyLevel
	if bestLevel == 0 then
		ui.label_none.gameObject:SetActive(true)
		ui.date.gameObject:SetActive(false)
	else
		ui.label_none.gameObject:SetActive(false)
		ui.date.gameObject:SetActive(true)

		ui.date.display.text = Global.SecondToStringFormat(data.historyTime , "yyyy-MM-dd HH:mm:ss")
		
	end

	ui.record.level.text = tostring(bestLevel)
end
