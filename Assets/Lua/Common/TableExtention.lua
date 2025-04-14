local table = table

function table.values(t)
    local values = {}

    for _, v in pairs(t) do
        values[#values + 1] = v
    end
    
    return values
end

function table.unique(t)
    local check = {}
    local unique = {}
    for _, v in pairs(t) do
        if not check[v] then
            check[v] = true
            unique[#unique + 1] = v
        end
    end
    return unique
end

function table.map(t, f)
    if type(t) == "table" then
        for i, v in pairs(t) do
            t[i] = f(t[i])
        end

        return t
    else
        return { f(t) }
    end
end

function table.first(t)
    for i, v in pairs(t) do
        return v
    end
end

function table.count(t)
    local count = 0
    for _, v in pairs(t) do
        count = count + 1
    end

    return count
end
