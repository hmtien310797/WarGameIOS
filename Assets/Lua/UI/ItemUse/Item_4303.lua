module("Item_4303", package.seeall)


ITEM_BASEID = 4303 
local useCallBack 

function SetCallBack(callback) 
    useCallBack = callback 
end 

function Use()
end 

function Awake()
end 

function Start()
end 

function OnDestroy()
    useCallBack = nil 
end 