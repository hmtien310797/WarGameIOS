local GameTime = Serclimax.GameTime
local pairs = pairs
local sort = table.sort
function WaitForRealSeconds(senconds)
    local time = GameTime.realTime
    local function Wait(senconds)
        while GameTime.realTime - time < senconds do
            coroutine.step()
        end
    end
    Wait(senconds)
end

function kpairs(t, f)
    local kList = {}
    for k in pairs(t) do
        kList[#kList + 1] = k
    end
    sort(kList, f)
    local i = 0
    return function()
        i = i + 1
        return kList[i], t[kList[i]]
    end
end

function ReloadModule(moduleTable)
    local moduleName = moduleTable._NAME
    local namePattern = moduleName.."$"
    local modulePath
    for k, v in pairs(package.loaded) do
        if k == moduleName then
            package.loaded[k] = nil
        elseif string.find(k, namePattern) then
            package.loaded[k] = false
            modulePath = k
        end
    end
    _G[moduleName] = nil
    require(modulePath)
end

function ReloadUI(menuName)
    Global.GGUIMgr:CloseMenu(menuName)
    ReloadModule(_G[menuName])
end
