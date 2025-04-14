class "EndlessList"
{	
}

function EndlessList:__init__(trans, x, y)
	self.transform = trans.transform
	self.scrollview = trans.transform:GetComponent("UIScrollView")
	self.scrollview:ResetPosition()
	self.grid = trans.transform:Find("Grid"):GetComponent("UIGrid")
	self.grid.enabled = false
	self.viewsize = trans.transform:GetComponent("UIPanel"):GetViewSize()
	self.movetype = self.scrollview.movement
	self.index = 0
	self.lastindex = 0
	if self.movetype == UIScrollView.Movement.Horizontal then
		self.shownums = math.ceil(self.viewsize.x / self.grid.cellWidth)
		self.prefabnums = math.ceil(self.viewsize.x / self.grid.cellWidth) + 5
		if self.startpos == nil then
			if x == nil then
				self.startpos = trans.transform.localPosition.x
			else
				self.startpos = x
			end
		end
		self.halfstep = self.grid.cellWidth / 2
	elseif self.movetype == UIScrollView.Movement.Vertical then
		self.shownums = math.ceil(self.viewsize.y / self.grid.cellHeight)
		self.prefabnums = math.ceil(self.viewsize.y / self.grid.cellHeight) + 5
		if self.startpos == nil then
			if y == nil then
				self.startpos = trans.transform.localPosition.y
			else
				self.startpos = y
			end
		end
		self.halfstep = self.grid.cellHeight / 2
	end
	UIUtil.SetClickCallback(self.grid.gameObject, nil)
end

function EndlessList:SetItem(prefab, totalnum, callback, notreposition)
	local collider = self.grid.transform:GetComponent("BoxCollider")
	if collider == nil then
		collider = self.grid.gameObject:AddComponent(typeof(UnityEngine.BoxCollider))
	end
	coroutine.start(function()
		coroutine.step()
		if collider == nil then
			return
		end
		if self.movetype == UIScrollView.Movement.Horizontal then
			collider.size = Vector3(self.grid.cellWidth * totalnum, self.viewsize.y, 0)
			collider.center = Vector3(collider.size.x / 2 - self.grid.cellHeight, 0, 0)
		elseif self.movetype == UIScrollView.Movement.Vertical then
			collider.size = Vector3(self.viewsize.x, self.grid.cellHeight * totalnum, 0)
			collider.center = Vector3(0, -collider.size.y / 2 + self.grid.cellHeight, 0)
		end
	end)
	if self.grid.transform:GetComponent("UIDragScrollView") == nil then
		self.grid.gameObject:AddComponent(typeof(UIDragScrollView))
	end
	prefab.transform:GetComponent("BoxCollider").enabled = false
	prefab.transform:GetComponent("UIDragScrollView").enabled = false
	self.totalnum = totalnum
	self.callback = callback
	if self.prefabs == nil then
		self.prefabs = {}
		if self.prefabnums > totalnum then
			self.prefabnum = totalnum
		else
			self.prefabnum = self.prefabnums
		end
		for i = 1, self.prefabnum do
			self.prefabs[i] = NGUITools.AddChild(self.grid.gameObject, prefab.gameObject)
			if self.movetype == UIScrollView.Movement.Horizontal then
				self.prefabs[i].transform.localPosition = Vector3(self.grid.cellWidth * (i - 2) + self.halfstep, 0, 0)
			elseif self.movetype == UIScrollView.Movement.Vertical then
				self.prefabs[i].transform.localPosition = Vector3(0, - self.grid.cellHeight * (i - 2) - self.halfstep, 0)
			end
			if self.callback ~= nil then
				self.callback(self.prefabs[i].transform, i)
			end
		end
	end
	
	--self.grid:Reposition()
	if not notreposition then
		self.scrollview:ResetPosition()
	end
	self.updateItems = function()
		if self.movetype == UIScrollView.Movement.Horizontal then
			self.index = math.floor((self.startpos - self.transform.localPosition.x) / self.grid.cellWidth)
			self.index = math.min(math.max(0, self.index), self.totalnum - self.prefabnum)
			if self.index ~= self.lastindex then
				self.lastindex = self.index
				local beginpos = self.grid.cellWidth * self.index
				for i, v in ipairs(self.prefabs) do
					v.transform.localPosition = Vector3(self.grid.cellWidth * (i - 2) + beginpos + self.halfstep, 0, 0)
					if self.callback ~= nil then
						self.callback(self.prefabs[i].transform, self.index + i)
					end
				end
			end
		elseif self.movetype == UIScrollView.Movement.Vertical then
			self.index = math.floor((self.transform.localPosition.y - self.startpos) / self.grid.cellHeight)
			self.index = math.min(math.max(0, self.index), self.totalnum - self.prefabnum)
			if self.index ~= self.lastindex then
				self.lastindex = self.index
				local beginpos = - self.grid.cellHeight * self.index
				for i, v in ipairs(self.prefabs) do
					v.transform.localPosition = Vector3(0, - self.grid.cellHeight * (i - 2) + beginpos - self.halfstep, 0)
					if self.callback ~= nil then
						self.callback(self.prefabs[i].transform, self.index + i)
					end
				end
			end
		end
	end
	self.scrollview.onMomentumMove = self.updateItems
	self.scrollview.onDragMove = self.updateItems
end

function EndlessList:Refresh()
	if self.updateItems ~= nil then
		self.lastindex = -1
		self.updateItems()
	end
end

function EndlessList:SetClickCallback(callback)
	UIUtil.SetClickCallback(self.grid.gameObject, function()
		local campos = Vector3(UICamera.lastEventPosition.x, UICamera.lastEventPosition.y, 0)
		local plane = Plane.New(self.grid.transform.rotation * Vector3.back, 0)
		local ray = UICamera.mainCamera:ScreenPointToRay(campos)
		local _, distance = plane:Raycast(ray)
		local pos = self.grid.transform:InverseTransformPoint(ray:GetPoint(distance))
		local index = 1
		if self.movetype == UIScrollView.Movement.Horizontal then
			
		elseif self.movetype == UIScrollView.Movement.Vertical then
			index = math.floor(-pos.y / self.grid.cellHeight) + 2
		end
		if callback ~= nil then
			callback(index)
		end
	end)
end

function EndlessList:MoveTo(index)
	index = math.ceil( index - self.prefabnum * 0.5 + 2 )
	index = math.max(-1, index)
	if self.prefabnum ~= self.shownums then
		if self.movetype == UIScrollView.Movement.Horizontal then
			self.scrollview:MoveRelative(Vector3((self.startpos - self.transform.localPosition.x), 0, 0))
			self.scrollview:MoveRelative(Vector3(self.grid.cellWidth * index, 0, 0))
		elseif self.movetype == UIScrollView.Movement.Vertical then
			self.scrollview:MoveRelative(Vector3(0, self.startpos - self.transform.localPosition.y, 0))
			self.scrollview:MoveRelative(Vector3(0, self.grid.cellHeight * index, 0))
		end
	end
	coroutine.start(function()
		coroutine.step()
		if self.scrollview == nil or self.scrollview:Equals(nil) or self.grid == nil or self.grid:Equals(nil) then
			return
		end
		self.updateItems()
		coroutine.step()
		if self.scrollview == nil or self.scrollview:Equals(nil) or self.grid == nil or self.grid:Equals(nil) then
			return
		end
		self.scrollview:RestrictWithinBounds(true, self.grid.transform)
	end)
end

function EndlessList:GetMiddleIndex()
	return math.floor(self.index + self.prefabnum * 0.5 - 2)
end