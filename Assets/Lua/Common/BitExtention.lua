local bit = bit

local function WriteOnes(min, max)
	return bit.lshift(max and bit.rshift(-1, 31 - max + min) or 1, min)
end

function bit.read(num, min, max)
	return bit.rshift(bit.band(num, WriteOnes(min, max)), min)
end

function bit.write(num, x, min, max)
	local mask = WriteOnes(min, max)

	if x == 0 then
		return bit.band(num, bit.bnot(mask))
	elseif x == 1 then
		return bit.bor(bit.band(num, bit.bnot(mask)), mask)
	else
		error("[BitExtention] #2 argument must be 0 or 1")
	end 
end
