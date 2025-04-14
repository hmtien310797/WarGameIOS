local function BinarySearch(list, data, compare)
    if #list == 0 then
        return 1, false
    end

    local min = 1
    local max = #list

    while min ~= max do
        local mid = math.floor((min + max) / 2)
        local pivot = list[mid]

        local flag = compare(data, pivot)
        if flag == 0 then
            return mid, true
        elseif flag < 0 then
            max = mid
        else
            min = mid + 1
        end
    end

    local flag = compare(data, list[min])
    if flag == 0 then
        return min, true
    elseif flag > 0 then
        return min + 1, false
    else
        return min, false
    end
end

local function compareNumber(a, b)
    if a < b then
        return -1
    elseif a == b then
        return 0
    else
        return 1
    end
end

class "SortedList"
{
}

function SortedList:__init__(capacity, compare)
    self.data = {}
    self.capacity = capacity and capacity > 0 and capacity or nil

    self.compare = compare or compareNumber
end

function SortedList:Count()
    return #self.data
end

function SortedList:IsFull()
    return self.capacity and #self.data == self.capacity
end

function SortedList:IsEmpty()
    return #self.data == 0
end

function SortedList:Search(data)
    local i, flag = BinarySearch(self.data, data, self.compare)

    return flag and i or nil
end

function SortedList:First()
    return self.data[1]
end

function SortedList:Insert(data)
    if not self:IsFull() then
        table.insert(self.data, BinarySearch(self.data, data, self.compare), data)
    end
end

function SortedList:RemoveAt(i)
    local data = self.data[i]

    if data then
        table.remove(self.data, i)

        return data
    end
end

function SortedList:RemoveFirst(f)
    if not f then
        return self:RemoveAt(1)
    end

    for i, data in ipairs(self.data) do
        if f(data) then
            return self:RemoveAt(i)
        end
    end
end

function SortedList:RemoveAll(f)
    local dataRemoved = {}
    local numRemoved = 0

    if f == nil then
        dataRemoved = self.data
        numRemoved = #self.data

        self.data = {}
    else
        for i = #self.data, 1, -1 do
            if f(self.data[i]) then
                dataRemoved[i] = self:RemoveAt(i)
                numRemoved = numRemoved + 1
            end
        end
    end

    return dataRemoved, numRemoved
end

function SortedList:Iterate(f)
    if f then
        for i, data in ipairs(self.data) do
            f(i, data)
        end
    end
end

function SortedList:Print(toString)
    print(string.format("COUNT: %d", #self.data))

    for _, data in ipairs(self.data) do
        print(data)
    end
end

function SortedList:Test()
    local function TestIsSorted(list, compare)
        for i = 1, #list - 1 do
            assert(compare(list[i], list[i + 1]) <= 0)
        end
    end

    self.compare = compareNumber

    math.randomseed(os.time())
    
    for i = 1, 100 do
        self:Insert(math.random(1, 100000))
        TestIsSorted(self.data, self.compare)
    end

    self:Print()
end
