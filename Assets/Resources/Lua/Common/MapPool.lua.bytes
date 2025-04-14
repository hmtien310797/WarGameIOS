local Instantiate = UnityEngine.GameObject.Instantiate
local Destroy = UnityEngine.GameObject.Destroy
MapPool = 
{
}

MapPool.__index = MapPool
function MapPool:__call(prefab, keepCount)
    local objectPool = 
    {
        prefab = prefab,
        keepCount = keepCount,
        pool = {},
        activeCount = 0,
        createCount = 0,
    }
    return setmetatable(objectPool, self)
end

setmetatable(MapPool, MapPool)

function MapPool:Reset()
    self.activeCount = 0
end
local ShowActive = UnityEngine.Vector3.one
local HideActive = UnityEngine.Vector3.zero
function MapPool:Accquire()
    self.activeCount = self.activeCount + 1
    local createNew = false
    if #self.pool < self.activeCount then
        local object = {}
        local gameObject = Instantiate(self.prefab)
        object.gameObject = gameObject
        object.transform = gameObject.transform
        self.createCount = self.createCount + 1
        table.insert(self.pool, object)
        createNew = true
    else
        self.pool[self.activeCount].transform.localScale = ShowActive
    end
    return self.pool[self.activeCount], createNew
end

function MapPool:Release()
    for i = #self.pool, self.activeCount + self.keepCount + 1, -1 do
        Destroy(self.pool[i].gameObject)
        self.pool[i] = nil
    end
    --print(self.prefab.name, "object pool create count", self.createCount)
    for i = self.activeCount + 1, #self.pool do
        self.pool[i].transform.localScale = HideActive
    end
end

return MapPool
