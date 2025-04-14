module("SpeedUpprice", package.seeall)

local GUIMgr = Global.GGUIMgr.Instance
local TableMgr = Global.GTableMgr

local UppriceData

local function InitUppriceData()
	UppriceData = {} 
	local upprice_table = TableMgr:GetSpeedUppriceTable()
	for _ , v in ipairs(upprice_table) do
		local type = v.Type
		if UppriceData[type] == nil then
		   UppriceData[type] = {}
		end
		table.insert(UppriceData[type],v)
	end
	
	--[[local iter = upprice_table:GetEnumerator()
	while iter:MoveNext() do
		local type = iter.Current.Value.Type
		if UppriceData[type] == nil then
		   UppriceData[type] = {}
		end
		table.insert(UppriceData[type],iter.Current.Value)
	end]]
end

function GetPrice(type,second)
	if UppriceData == nil then
	   InitUppriceData()
	end
	if UppriceData[type] == nil then
	   return
	end
	local price = 0
	for i = 1,#(UppriceData[type]) do
		local unit = UppriceData[type][i]
		if second > unit.Min then
			if second >= unit.Max then
			        price = price + (unit.Max - unit.Min)*unit.Price
			else
			    if i == 1 then
			        price = price + (second - unit.Min)*unit.Price
			    else
				    price = price + (second - UppriceData[type][i-1].Max)*unit.Price
                end
			end
        end
	end
	return price
end
	
