module("ReconSaveData", package.seeall)
local recondata
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return recondata
end

function SetData(data)
    recondata = data
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end



function UpdateData(data , playerid)
	if recondata == nil then
		recondata = {}
	end
	
	recondata[playerid] = data
end

function GetDataById(playerid)
	if recondata ~= nil then
		return recondata[playerid]
	end
	
	return nil
end

function RequestData(callback, lockScreen)
   
end

function Format(value)
	local v = string.split(value , ',')
	if v == nil then
		print("ReconSaveData 数据错误。:" , value)
		return nil
	end
	
	local _log = ""
	local usrid = v[1]
	
	_log = "ReconSaveData Format Log: usrid->" .. usrid
	local pos = {x = v[2] , y = v[3]}
	_log = _log .. " posX->" .. v[2] .. " posY->" .. v[3] .. " form:"
	local form = {}
	for i=4 , 11 do
		if i > #v then
			_log = _log .. "[" .. i-3 .. "]->" .. 0 .. " , "
			table.insert(form , tonumber(v[i]))
		else
			_log = _log .. "[" .. i-3 .. "]->" .. v[i] .. " , "
			table.insert(form , tonumber(v[i]))
		end
		
	end
	
	print(_log)
	return usrid , pos , form
end

function Save(value)
	if recondata == nil then
		recondata = {}
	end
	local usrid , pos , form = Format(value)
	
	if usrid == nil or pos == nil or form == nil then
		return 
	end	
	
	
	local k = tonumber(usrid) > 0 and string.format("uid:%s" , usrid) or string.format("pos:%s_%s" , pos.x , pos.y)
	recondata[k] = form
end


function GetSavedForm(k)
	if recondata ~= nil then
		return recondata[k]
	end
	
	return nil
end
