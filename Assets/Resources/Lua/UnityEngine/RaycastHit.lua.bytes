--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
local rawget = rawget
local setmetatable = setmetatable

RaycastBits = 
{
    BarycentricCoordinate = 1,
	Collider = 2,
    Normal = 4,
    Point = 8,
    Rigidbody = 16,
    TextureCoord = 32,
    TextureCoord2 = 64,
    Transform = 128,
    ALL = 255,
}
	
local RaycastBits = RaycastBits
local RaycastHit = {}
local get = tolua.initget(RaycastHit)

RaycastHit.__index = function(t,k)
	local var = rawget(RaycastHit, k)
		
	if var == nil then							
		var = rawget(get, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

--c# 创建
function RaycastHit.New(barycentricCoordinate, collider, distance, normal, point, rigidbody, textureCoord, textureCoord2, transform, triangleIndex)
	local hit = {barycentricCoordinate = barycentricCoordinate, collider = collider, distance = distance, normal = normal, point = point, rigidbody = rigidbody, textureCoord = textureCoord, textureCoord2 = textureCoord2, transform = transform, triangleIndex = triangleIndex}
	setmetatable(hit, RaycastHit)
	return hit
end

function RaycastHit:Init(barycentricCoordinate, collider, distance, normal, point, rigidbody, textureCoord, textureCoord2, transform, triangleIndex)
    self.barycentricCoordinate = barycentricCoordinate
	self.collider 	= collider
	self.distance 	= distance
	self.normal 	= normal
	self.point 		= point
	self.rigidbody 	= rigidbody
	self.textureCoord = textureCoord
	sefl.textureCoord2 = textureCoord2
	self.transform 	= transform
	sefl.triangleIndex = triangleIndex
end

function RaycastHit:Get()
	return self.barycentricCoordinate, self.collider, self.distance, self.normal, self.point, self.rigidbody, self.textureCoord, self.textureCoord2, self.transform, self.triangleIndex
end

function RaycastHit:Destroy()				
	self.collider 	= nil			
	self.rigidbody 	= nil					
	self.transform 	= nil		
end

function RaycastHit.GetMask(...)
	local arg = {...}
	local value = 0	

	for i = 1, #arg do		
		local n = RaycastBits[arg[i]] or 0
		
		if n ~= 0 then
			value = value + n				
		end
	end	
		
	if value == 0 then value = RaycastBits["all"] end
	return value
end

UnityEngine.RaycastHit = RaycastHit
setmetatable(RaycastHit, RaycastHit)
return RaycastHit
