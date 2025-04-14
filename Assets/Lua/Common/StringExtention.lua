local string = string

--http://lua-users.org/wiki/SplitJoin
function string.split(str, delim, maxNb)
	-- Eliminate bad cases...
	if string.find(str, delim) == nil then
		return { str }
	end
	if maxNb == nil or maxNb < 1 then
		maxNb = 0    -- No limit
	end
	local result = {}
	local pat = "(.-)" .. delim .. "()"
	local nb = 0
	local lastPos
	for part, pos in string.gfind(str, pat) do
		nb = nb + 1
		result[nb] = part
		lastPos = pos
		if nb == maxNb then break end
	end
	-- Handle the last field
	if nb ~= maxNb then
		result[nb + 1] = string.sub(str, lastPos)
	end
	return result
end

function string.gsplit(s, sep, plain)
	local start = 1
	local done = false
	local function pass(i, j, ...)
		if i then
			local seg = string.sub(s, start, i - 1)
			start = j + 1
			return seg, ...
		else
			done = true
			return string.sub(s, start)
		end
	end
	return function()
		if done then return end
		if sep == '' then done = true return s end
		return pass(string.find(s, sep, start, plain))
	end
end

--http://lua-users.org/wiki/StringRecipes
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

-- SerapH
function string.make_fraction(numerator, denominator)
	return table.concat({numerator, "/", denominator})
end

function string.make_percent(num, numDecimalPlaces)
	local format = "%." .. (numDecimalPlaces or 1) .. "f%%"
	return string.format(format, num)
end

local PLATFORM = Global.GGUIMgr:GetPlatformType()
function string.make_price(price)
	if PLATFORM == LoginMsg_pb.AccType_adr_huawei then
		return "SGD$" .. price
	elseif PLATFORM == LoginMsg_pb.AccType_adr_tmgp or
	Global.IsIosMuzhi() or
	PLATFORM == LoginMsg_pb.AccType_adr_muzhi or
	PLATFORM == LoginMsg_pb.AccType_adr_opgame or 
	PLATFORM == LoginMsg_pb.AccType_adr_mango or
	PLATFORM == LoginMsg_pb.AccType_adr_official or
	PLATFORM == LoginMsg_pb.AccType_ios_official or
	PLATFORM == LoginMsg_pb.AccType_adr_official_branch or
	PLATFORM == LoginMsg_pb.AccType_adr_quick or
	PLATFORM == LoginMsg_pb.AccType_adr_qihu then
		return "RMB￥" .. price
	end
	
	return "US$" .. price
end

function string.msplit(s, ...)
	if s == "" then
		return {}
	end

	local seperators = { ... }

	local splittedStrings = string.split(s, seperators[1])
	
	table.remove(seperators, 1)
	
	if #seperators == 0 or splittedStrings == 1 then
		return splittedStrings
	else
		local result = {}
		for _, ss in ipairs(splittedStrings) do
			local recursiveResult = string.msplit(ss, unpack(seperators))
			if #recursiveResult > 0 then
				table.insert(result, #recursiveResult == 1 and recursiveResult[1] or recursiveResult)
			end
		end

		return result
	end
end
