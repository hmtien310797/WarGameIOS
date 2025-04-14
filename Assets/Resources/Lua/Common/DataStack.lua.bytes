class "DataStack"
{
}

function DataStack:__init__()
	self.data = {}
end

function DataStack:Count()
	return #self.data
end

function DataStack:IsEmpty()
	return self:Count() == 0
end

function DataStack:Push(item)
	table.insert(self.data, item)
end

function DataStack:Pop()
	if not self:IsEmpty() then
		local i = self:Count()
		local item = self.data[i]

		table.remove(self.data, i)

		return item
	end
end

function DataStack:Top()
	return self.data[self:Count()]
end

function DataStack:Clear()
	self.data = {}
end
