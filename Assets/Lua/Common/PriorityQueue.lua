class "PriorityQueue"
{
}

local function Parent(i)
	return math.floor(i / 2)
end

local function LeftChild(i)
	return 2 * i
end

local function RightChild(i)
	return LeftChild(i) + 1
end

function PriorityQueue:__init__(capacity, compare)
	self.data = {}
	self.capacity = capacity and capacity > 0 and capacity or nil

	self.compare = compare
end

function PriorityQueue:Count()
	return #self.data
end

function PriorityQueue:IsFull()
	return self.capacity and #self.data == self.capacity
end

function PriorityQueue:IsEmpty()
	return #self.data == 0
end

function PriorityQueue:Swap(i, j)
	if self.data[i] == nil or self.data[j] == nil then
		return
	end

	self.data[i], self.data[j] = self.data[j], self.data[i]
end

function PriorityQueue:HeapifyUp(i)
	if i == 1 then
		return
	end

	local j = Parent(i)

	if self.compare(self.data[i], self.data[j]) then
		self:Swap(i, j)
		self:HeapifyUp(j)
	end
end

function PriorityQueue:HeapifyDown(i)
	local j = LeftChild(i)

	if j > #self.data then
		return
	end

	if j < #self.data and self.compare(self.data[j + 1], self.data[j]) then
		j = j + 1
	end

	if self.compare(self.data[j], self.data[i]) then
		self:Swap(i, j)
		self:HeapifyDown(j)
	end
end

function PriorityQueue:Push(data)
	if self:IsFull() then
		return
	end

	table.insert(self.data, data)
	self:HeapifyUp(#self.data)
end

function PriorityQueue:Peak()
	return self.data[1]
end

function PriorityQueue:Pop()
	return self:RemoveAt(1)
end

function PriorityQueue:FindFirstN(n, judge)
	local dataFound = {}

	for i, data in ipairs(self.data) do
		if judge == nil or judge(data) then
			dataFound[#dataFound + 1] = data

			if #dataFound == n then
				break
			end
		end
	end

	return dataFound
end

function PriorityQueue:RemoveAt(i)
	local data = self.data[i]

	if data then
		local lastIndex = #self.data

		self:Swap(i, lastIndex)
		table.remove(self.data, lastIndex)
		
		self:HeapifyDown(i)

		return data
	end
end

function PriorityQueue:RemoveFirst(f)
	if not f then
		return self:RemoveAt(1)
	end

	for i, data in ipairs(self.data) do
		if f(data) then
			return self:RemoveAt(i)
		end
	end

	return nil
end

function PriorityQueue:RemoveAll(f)
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

function PriorityQueue:Iterate(f)
	if f ~= nil then
		for i, data in ipairs(self.data) do
			f(i, data)
		end
	end
end

function PriorityQueue:Print(toString)
	local output = string.format("COUNT: %d", #self.data)
	for i, data in ipairs(self.data) do
		if bit.band(i , i - 1) == 0 then
			output = output .. "\n|"
		end

		output = output .. string.format(" %s |", toString and toString(data) or tostring(data))
	end

	print(output)
end

function PriorityQueue:Test()
	for i = 1, 10 do
		self:Push(i)
	end

	self:Print()

	self:RemoveAll(function(data)
		return data % 2 == 0
	end)

	self:Print()
end

