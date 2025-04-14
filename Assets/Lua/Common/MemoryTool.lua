module("MemoryTool", package.seeall)

local leakList = {}
local function TraceUpvalue(moduleTable, func)
    local weakTable = {}
    setmetatable(weakTable, {__mode = "kv"})
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then
            break
        end
        weakTable[n] = v
    end
    moduleTable[func] = weakTable
end

local function TraceModule(mk, mv)
    local moduleTable = {}
    leakList[mk] = moduleTable
    for k, v in pairs(mv) do
        if type(v) == "function" then
            TraceUpvalue(moduleTable, v)
        end
    end
end

local function TraceAllModule()
    for k, v in pairs(_G) do
        if type(v) == "table" then
            TraceModule(k, v)
        end
    end
end

function DumpLeakList()
    TraceAllModule()
    collectgarbage("collect")
    local file = io.open("d:/leak_list.txt", "w")
    if file ~= nil then
        for k, v in pairs(leakList) do
            file:write(tostring(k), '\n')
            for kk, vv in pairs(v) do
                if next(vv) then
                    local info = debug.getinfo(kk, "S")
                    file:write('\t', info.linedefined, '\n')
                    for kkk, vvv in pairs(vv) do
                        if type(vvv) ~= "function" then
                            if type(vvv) == "table" then
                                file:write('\t\t', kkk, '\t', "table" or "nil", "\tlength:", #vvv, '\n')
                            else
                                file:write('\t\t', kkk, '\t', tostring(vvv) or "nil", '\n')
                            end
                        end
                    end
                end
            end
        end
        file:close()
    end
end

