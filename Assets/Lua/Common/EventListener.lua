class "EventListener"
{
}

function EventListener:__init__()
    self.listenerList = {}
end

function EventListener:NotifyListener(...)
	local dumpFile = nil
	if LuaNetwork.EnableLog() then
		--Log2FileContent
		dumpFile = io.open("d:/dumpCS.lua", "a")
	end
    for k, v in pairs(self.listenerList) do
		if LuaNetwork.EnableLog() then
			if dumpFile ~= nil then
				--print(v.name , v.linedefined , v.short_src)
				--Global.Log2FileContent(dumpFile , string.format("%s|%s|%s " , v.name , v.linedefined , v.short_src))
			end
		end
        k(...)
    end
	if LuaNetwork.EnableLog() then
		--Log2FileContent
		if dumpFile ~= nil then
			dumpFile:close()
		end
	end
end

function EventListener:AddListener(listener)
    --[[
	local info = debug.getinfo(listener)
	local func = debug.getinfo(3, "f").func
	for i = 1, math.huge do
		local name, value = debug.getupvalue(func, i)
		
		if name == nil then
			break
		end
		
		if value == listener then
			info.name = name
			break
		end
	end
	
	if info.name == nil then
		local env = getfenv(func)
		for k, v in pairs(env) do
			if v == listener then
				info.name = k
				break
			end
		end
	end
	--]]
    self.listenerList[listener] = true
end

function EventListener:RemoveListener(listener)
    self.listenerList[listener] = nil
end
