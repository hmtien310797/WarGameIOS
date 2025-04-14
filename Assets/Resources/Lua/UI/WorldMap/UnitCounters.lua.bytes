module("UnitCounters", package.seeall)

local SetClickCallback = UIUtil.SetClickCallback

local ui


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
	Global.OpenUI(_M)
end

Hide = function()
	Global.CloseUI(_M)
end

Start = function()
	Draw()
end

Close = function()
	ui = nil
end

Draw = function()
	LoadUI()
	SetUI()
end

LoadUI = function()
	if ui == nil then
		ui = {}
		local container = transform:Find("Container")
		SetClickCallback(container.gameObject , Hide)
		
	end
end

SetUI = function()
	
end
