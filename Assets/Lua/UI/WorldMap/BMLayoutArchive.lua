class "BMLayoutArchive"
{
}

function BMLayoutArchive:__init__(id)
    self.id = id
    self.generals = {}
    self.armys = {}
end

function BMLayoutArchive:AddArmyRecord(army_id,num)
    if self.armys == nil then
        self.armys = {}
    end
    self.armys[army_id] = num    
end

function BMLayoutArchive:AddGenerals(generals)
    for _, uid in ipairs(generals) do
        table.insert(self.generals, uid)
    end
end

function BMLayoutArchive:Clone()
    local a = BMLayoutArchive(self.id)
    table.foreach(self.armys,function (i,v)
     a:AddArmyRecord(i,v)
    end)
    return a
end

function BMLayoutArchive:AddHeroRecord(hero_base_id)
    if self.heros == nil then
        self.heros = {}
    end
    table.insert(self.heros,hero_base_id)
end

function BMLayoutArchive:ToString()
    local s = "archive:\nGenerals:"

    for _, uid in ipairs(self.generals) do
        s = s .. uid .." | "
    end

    s = s .. "\nTroop:"
    
    table.foreach(self.armys,function(id, num)
        s = s .. id .." x ".. num .." | "
    end)
    
    return s
end
