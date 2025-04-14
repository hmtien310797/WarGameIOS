class "BMLocalHeroData"
{
}

function BMLocalHeroData:__init__()
    self.memHero = {}
end

function BMLocalHeroData:IsHeroSelectedByUid(uid)
    for i = 1, #(self.memHero), 1 do
        if self.memHero[i] == uid then
            return true
        end
    end 
    return false
end

function BMLocalHeroData:IsHeroSelectedByBaseId( baseId)
    for __, vv in ipairs(self.memHero) do
        local heroMsg = GeneralData.GetGeneralByUID(vv) -- HeroListData.GetHeroDataByUid(vv)
        if heroMsg ~= nil and heroMsg.baseid == baseId then
            return true
        end
    end
    return false
end

function BMLocalHeroData:GetSelectedHeroCount()
    return table.getn(self.memHero)
end

function BMLocalHeroData:SelectHero(heroUid)
    --print("SelectHero")
    if self:IsHeroSelectedByUid(heroUid) then
        return false
    end
    table.insert(self.memHero, heroUid)
    
    return true
end

function BMLocalHeroData:UnselectHero(heroUid)
    for ii, vv in ipairs(self.memHero) do
        if vv == heroUid then
            table.remove(self.memHero, ii)
            break
        end
    end    
end

function BMLocalHeroData:UnselectAllHero()
    for i = self:GetSelectedHeroCount(), 1, -1 do
        table.remove(self.memHero, i)
    end   
end


function BMLocalHeroData:NormalizeData()
    for i = self:GetSelectedHeroCount(), 1, -1 do
        local heroMsg = GeneralData.GetGeneralByUID(self.memHero[i]) -- HeroListData.GetHeroDataByUid(self.memHero[i])
        if heroMsg == nil then
            table.remove(self.memHero,i)
        else
            local heroData = Global.GTableMgr:GetHeroData(heroMsg.baseid) 
            if heroData.expCard then
                table.remove(self.memHero,i)
            end
        end
    end

    for i = self:GetSelectedHeroCount(), 1, -1 do
        for j = i - 1, 1, -1 do
            if self.memHero[i] == self.memHero[j] then
                table.remove(self.memHero,i)
                break
            end
        end
    end
end

