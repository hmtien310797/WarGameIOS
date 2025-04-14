module("Rune", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local _ui

local FreshEquipedRunes = nil
local FreshRunePosInfo = nil
local LoadRightRuneInfo = nil
local LoadEquipedRunes = nil
local LoadMainInfo = nil
local LoadUI = nil

local RuneType = 
{
	[1] = "blue" ,[2] = "green" ,[3] = "yellow" ,
}
local RunePos = 
{
	pos_1 = 1 ,
	pos_2 = 2 ,
	pos_3 = 3 , 
	pos_4 = 4 ,
	pos_5 = 5 ,
	pos_6 = 6 , 
	pos_7 = 7 ,
	pos_8 = 8 ,
	pos_9 = 9 , 
	pos_10 = 10 , 
}

local RuneStatus = 
{
	status_equiped = 1, --已装备
	status_unequip = 2, --未装备
	status_buy = 3,  --可购买开启
	status_active = 4,  --下一个被急活位置
	status_locked  = 5,  --锁定
}



local function Hide()
    Global.CloseUI(_M)
end

local function CloseAll()
    Hide()
	Runebag.Hide()
	Runedraw.Hide()
end


function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if _ui.tipObject then
        _ui.tipObject = nil
    end
end

local function ShowRune()
	_ui.bg_frane.gameObject:SetActive(true)
	
	_ui.runLeftChange.trf.gameObject:SetActive(false)
	_ui.runeTree.trf.gameObject:SetActive(true)
end

local function HideRune()
	_ui.bg_frane.gameObject:SetActive(false)
end

local function ToggleContent(index)
	if _ui == nil or _ui.contentToggle[index] == nil then
		return
	end
	
	if _ui.contentToggle[index].gameObject.activeSelf then
		return
	end
	
	for k , v in pairs(_ui.contentToggle) do
		v.gameObject:SetActive(k == index)
		if k == index then
			UITweener.PlayAllTweener(_ui.contentTweener[k].gameObject , true , true , false)
		end
	end
end

--查找下一个空位
local function UpdateNextAvailablePos(rtype)
	rtype = rtype > 0 and rtype or 1
	
	for j=1 , 10 do
		local node = _ui.runeTree[rtype][j]
		if node and node.status == RuneStatus.status_unequip then
			return rtype , j
		end
	end
	
	for i=1, 3 do
		if i ~= rtype then
			for j=1 , 10 do
				local node = _ui.runeTree[i][j]
				if node and node.status == RuneStatus.status_unequip then
					return i , j
				end
			end
		end
	end
	return 0,0
end

local function GetNextTargetPos_Local(ids , rtype)
	local myLvel = MainData.GetLevel()
	if ids and #ids > 0 then
		return #ids < 10 and ids[#ids] + 1 or 0
	else
		for j=1 , 10 do
			local node = _ui.runeTree[rtype][j]
			if myLvel < node.runePosData.NeedPlayerlvl then
				return rtype * 100 + j
			end
		end
	end	
	
	return 0
end

--跟新下一个可被急活的位置
local function UpdateNextTargetPos()
	local runePosInfo = RuneData.GetRuneUnlockData()
	local nextPos = {}
	local lastPos = {}
	local Ids = {[1] = runePosInfo.unlockBlue.ids , [2] = runePosInfo.unlockGreen.ids , [3] = runePosInfo.unlockRed.ids}
	
	for i=1 , 3 do
		local actPos = GetNextTargetPos_Local(Ids[i] , i)
		if actPos > 0 then
			table.insert(lastPos , actPos)
		end
	end
	--lastPos[1] = --[[blueIds > 0 and runePosInfo.unlockBlue.ids[#runePosInfo.unlockBlue.ids] or]] GetNextTargetPos_Local(runePosInfo.unlockBlue.ids , 1)
	--lastPos[2] = --[[greenIds > 0 and runePosInfo.unlockGreen.ids[#runePosInfo.unlockGreen.ids] or]] GetNextTargetPos_Local(runePosInfo.unlockGreen.ids , 2)
	--lastPos[3] = --[[redIds > 0 and runePosInfo.unlockRed.ids[#runePosInfo.unlockRed.ids] or ]]GetNextTargetPos_Local(runePosInfo.unlockRed.ids , 3)
	table.sort(lastPos , function(v1 , v2)
		local node1 = _ui.runeTree[math.floor(v1/100)][math.floor(v1%100)]
		local node2 = _ui.runeTree[math.floor(v2/100)][math.floor(v2%100)]
		return  node1.runePosData.NeedPlayerlvl < node2.runePosData.NeedPlayerlvl
	end)
	
	
	for i=1 , #lastPos do
		if lastPos[i] > 0 then
			local rtype = math.floor(lastPos[i]/100)
			local pos = math.floor(lastPos[i]%100)
			if pos <= 10 then
				if i == 1 then
					local node = _ui.runeTree[rtype][pos]
					_ui.runeTree[rtype][pos].status = RuneStatus.status_active
					_ui.runeTree[rtype][pos].buy.gameObject:SetActive(false)
					_ui.runeTree[rtype][pos].lock.gameObject:SetActive(false)
					_ui.runeTree[rtype][pos].activate.gameObject:SetActive(true)
					_ui.runeTree[rtype][pos].activate.text = System.String.Format(TextMgr:GetText("ui_rune_29") , _ui.runeTree[rtype][pos].runePosData.NeedPlayerlvl)
					
				else
					_ui.runeTree[rtype][pos].status = RuneStatus.status_buy
					_ui.runeTree[rtype][pos].buy.gameObject:SetActive(true)
					_ui.runeTree[rtype][pos].lock.gameObject:SetActive(false)
					_ui.runeTree[rtype][pos].activate.gameObject:SetActive(false)
				end
				nextPos[rtype] = pos
			end
		end
	end
	
	return nextPos
end

local function SetupLeftRuneInfo(infoTrf , data)
	if infoTrf == nil then
		return
	end
	
	infoTrf.gameObject:SetActive(data ~= nil)
	_ui.runLeftChange.afterTip.gameObject:SetActive(data == nil)
	
	if data then
		infoTrf:Find("Texture"):GetComponent("UISprite").spriteName = data.RuneData.RuneType
		infoTrf:Find("Texture/name"):GetComponent("UILabel").text = TextMgr:GetText(data.BaseData.name)
		infoTrf:Find("Texture/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/" , data.BaseData.icon)
	
		RuneData.SetAttributeList(data.data.baseid , infoTrf:Find("info/Label/Grid"):GetComponent("UIGrid") , _ui.runLeftChange.textItem)
	end
end

local function UpdateTreeNode(rtype , pos , status , equipRune)
	if status < RuneStatus.status_equiped or status > RuneStatus.status_locked then
		print("更新节点状态枚举错误! status = " , status )
		return
	end
	
	if _ui.runeTree[rtype] == nil or  _ui.runeTree[rtype][pos] == nil then
		print("更新节点类型或位置错误！type = " , rtype , "  pos = " , pos)
		return 
	end

	_ui.runeTree[rtype][pos].status = status
	local node = _ui.runeTree[rtype][pos]
	if node.status == RuneStatus.status_equiped then
		 
	elseif node.status == RuneStatus.status_unequip then
		node.buy.gameObject:SetActive(false)
		node.lock.gameObject:SetActive(false)
		node.activate.gameObject:SetActive(false)
		node.item_texture.mainTexture = nil
		
	elseif node.status == RuneStatus.status_buy then
		
	elseif node.status == RuneStatus.status_active then
		
	elseif node.status == RuneStatus.status_locked then
		node.buy.gameObject:SetActive(false)
		node.lock.gameObject:SetActive(true)
		node.activate.gameObject:SetActive(false)
	end
end

local function BuildAttributeData(addArmy , attrid , value , attrList)
	if not attrList then
		attrList = {}
	end
	
	if addArmy > 0 and not attrList[addArmy] then
		attrList[addArmy] = {}
	end	
	
	if attrList[addArmy] then
		local v = attrList[addArmy][attrid] and attrList[addArmy][attrid] or 0
		attrList[addArmy][attrid] = v + value
	end
	
	return attrList
end

local function BuyRunePos(runeNode ,  callback)
	local needlv = runeNode.runePosData.NeedPlayerlvl - MainData.GetLevel()
	local needGold = 0
	if needlv > 0 then
		needGold = LuaTableMgr:GetRuneUnlockData(needlv).NeedGold
		if needGold > MoneyListData.GetDiamond() then
			Global.ShowNoEnoughMoney()
		end
	end
	
	MessageBox.Show(System.String.Format(TextMgr:GetText("ui_rune_30") , needGold),  function()
		local req = ItemMsg_pb.MsgUnlockRuneGridRequest();
		req.gridId = runeNode.runePosData.id
		Global.DumpMessage(req , "d:/rune.lua")
		Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUnlockRuneGridRequest, req, ItemMsg_pb.MsgUnlockRuneGridResponse, function(msg)
			if msg.code == ReturnCode_pb.Code_OK then
				Global.DumpMessage(msg , "d:/rune.lua")
				MainCityUI.UpdateRewardData(msg.fresh)
				RuneData.UpdateRunePos(runeNode.runePosData.RuneType ,runeNode.runePosData.id )
				if callback ~= nil then
					callback()
				end
			else
				Global.ShowError(msg.code)
			end
		end, true)
	
	end , function () end)
end

local function WearRune(uid , pos , callback)
	local req = ItemMsg_pb.MsgWearRuneRequest();
	req.uid = uid
	req.gridId = pos
	
	Global.DumpMessage(req , "d:/wearrune.lua")
    Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgWearRuneRequest, req, ItemMsg_pb.MsgWearRuneResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			Global.DumpMessage(msg , "d:/wearrune.lua")
			MainCityUI.UpdateRewardData(msg.fresh)
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)
		end
    end, false)
end

local function TeardownRune(uid , all , callback)
	local req = ItemMsg_pb.MsgTeardownRuneRequest();
	req.uid = uid
	req.all = all and all or 1
	Global.DumpMessage(req , "d:/teardownrune.lua")
    Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgTeardownRuneRequest, req, ItemMsg_pb.MsgTeardownRuneResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			Global.DumpMessage(msg , "d:/teardownrune.lua")
			MainCityUI.UpdateRewardData(msg.fresh)
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)
		end
    end, true)
end


local function LoadUnwearedRunes(rtype , showBtn)
	--_ui.runInfo.trf.gameObject:SetActive(true)
	--_ui.runInfo.content2.gameObject:SetActive(true)
	--_ui.runInfo.content1.gameObject:SetActive(false)
	ToggleContent(2)
	local afterUid = 0
	if showBtn then
		_ui.runInfo.content2Btn.localScale = Vector3(1,1,1)
		SetClickCallback(_ui.runInfo.content2Btn2.gameObject , function()
			_ui.runLeftChange.trf.gameObject:SetActive(false)
			_ui.runeTree.trf.gameObject:SetActive(true)
			LoadRightRuneInfo(_ui.selectPos.rtype  , _ui.selectPos.pos)
		end)
		
		SetClickCallback(_ui.runInfo.content2Btn1.gameObject , function()
			if afterUid == 0 then
				return
			end
			
			WearRune(afterUid , _ui.selectPos.rtype*100 + _ui.selectPos.pos , function()
				_ui.runLeftChange.trf.gameObject:SetActive(false)
				_ui.runeTree.trf.gameObject:SetActive(true)
				LoadEquipedRunes()
				LoadRightRuneInfo(_ui.selectPos.rtype  , _ui.selectPos.pos)
			end)
		end)
		
		
	else
		_ui.runInfo.content2Btn.localScale = Vector3(1,0,1)
	end
	
	local unwearLisrt = RuneData.GetUnwearedRunes(rtype)
	local attrIndex = 1
	----------------------------
	_ui.runInfo.content2None.gameObject:SetActive(unwearLisrt == nil)
	if unwearLisrt then
		for _ , v in pairs(unwearLisrt) do
			local attrTransform
			if attrIndex > _ui.runInfo.content2Grid.transform.childCount then
				attrTransform = NGUITools.AddChild(_ui.runInfo.content2Grid.gameObject, _ui.runInfo.contentRuneItem.gameObject).transform
			else
				attrTransform = _ui.runInfo.content2Grid.transform:GetChild(attrIndex - 1)
			end
			attrTransform.gameObject:SetActive(true)
			attrTransform:Find("select").gameObject:SetActive(false)
			local attrData = RuneData.GetRuneTableData(v.data.baseid).RuneAttribute
			attrTransform:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(v.BaseData.name)
			attrTransform:Find("Texture"):GetComponent("UISprite").spriteName = "item_rune" .. v.RuneData.RuneType
			attrTransform:Find("Texture/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/" , v.BaseData.icon)
			attrTransform:Find("Texture/number"):GetComponent("UILabel").text = "x" .. RuneData.GetUnwearedRuneCount(v.data.baseid)
			
			for i=1 , 3 do
				local attrItem = attrTransform:Find(string.format("text (%d)" , i))
				if i <= #attrData then
					local attrItem = attrTransform:Find(string.format("text (%d)" , i))
					attrItem.gameObject:SetActive(true)
					RuneData.SetContentItemData(attrItem, attrData[i])
				else
					attrItem.gameObject:SetActive(false)
				end
			end
			--[[for i, v in ipairs(attrData) do
				if i <= 3 then
					local attrItem = attrTransform:Find(string.format("text (%d)" , i))
					attrItem.gameObject:SetActive(true)
					RuneData.SetContentItemData(attrItem, v)
				end
			end]]
			
			if not showBtn then
				SetClickCallback(attrTransform.gameObject , function()
					WearRune(v.data.uniqueid , _ui.selectPos.rtype*100 + _ui.selectPos.pos , function()
						LoadEquipedRunes()
						local nType , nPos = UpdateNextAvailablePos(_ui.selectPos.rtype)
						if nType > 0 and nPos > 0 then
							local runeNode = _ui.runeTree[nType][nPos]
							if _ui.selectPos.rtype > 0 and _ui.selectPos.pos > 0 then
								local lastSelect = _ui.runeTree[_ui.selectPos.rtype][_ui.selectPos.pos]
								lastSelect.selectTrf.gameObject:SetActive(false)
								lastSelect.item_sfx.gameObject:SetActive(false)
								lastSelect.item_sfx.gameObject:SetActive(true)
							end
							_ui.selectPos.rtype = nType
							_ui.selectPos.pos = nPos
							
							runeNode.selectTrf.gameObject:SetActive(true)
							LoadUnwearedRunes(nType , false)
							--LoadRightRuneInfo(_ui.selectPos.rtype  , _ui.selectPos.pos)
						else
							if _ui.selectPos.rtype > 0 and _ui.selectPos.pos > 0 then
								local lastSelect = _ui.runeTree[_ui.selectPos.rtype][_ui.selectPos.pos]
								lastSelect.selectTrf.gameObject:SetActive(false)
								lastSelect.item_sfx.gameObject:SetActive(false)
								lastSelect.item_sfx.gameObject:SetActive(true)
							end
							
							_ui.selectPos.rtype = 0
							_ui.selectPos.pos = 0
							LoadMainInfo()
						end
					end)
				end)
			else
				SetClickCallback(attrTransform.gameObject , function()
					afterUid = v.data.uniqueid
					SetupLeftRuneInfo(_ui.runLeftChange.after , v)
					for i = 1, _ui.runInfo.content2Grid.transform.childCount do
						_ui.runInfo.content2Grid.transform:GetChild(i - 1):Find("select").gameObject:SetActive( false)
					end
					attrTransform:Find("select").gameObject:SetActive(true)
				end)
			end
		
			attrIndex = attrIndex + 1
		end
	end
	
	for i = attrIndex, _ui.runInfo.content2Grid.transform.childCount do
		_ui.runInfo.content2Grid.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
	
	_ui.runInfo.content2Grid:Reposition()
	_ui.runInfo.content2ScrollView:ResetPosition()
end

LoadEquipedRunes = function()
	local equipList = RuneData.GetRuneEquipedListData()
	for _ , v in ipairs(equipList) do
		local runedata = RuneData.GetRuneDataByUid(v)
		if runedata ~= nil then
			local runeType = runedata.RuneData.RuneType
			local pos = runedata.data.parent.pos % 100
			_ui.runeTree[runeType][pos].status = RuneStatus.status_equiped
			_ui.runeTree[runeType][pos].item_texture.mainTexture = ResourceLibrary:GetIcon("Item/" , runedata.BaseData.icon)
		end
	end
end

local function FreshFragment()
	_ui.runLeftChange.fragment.text = MoneyListData.GetRuneChip()
end

LoadMainInfo = function()
	--local testAttrs = {10001 , 10002 , 10003 , 10004 , 10005 , 10006 , 10007,10008,10009 , 10010 , 10011 , 10012, 10013}
	--local attrList = GetAttributeList(testAttrs , _ui.runeDetail.DetailGrid ,_ui.runInfo.contentItem )
	print("LoadMainInfo")
	ToggleContent(3)
	local equipList = RuneData.GetRuneEquipedListData()
	local ids = {}
	local totalLevel = 0
	for _ , v in ipairs(equipList) do
		local data = RuneData.GetRuneDataByUid(v)
		if data then
			totalLevel = totalLevel + data.RuneData.Level
			table.insert(ids , data.data.baseid)
		end
	end
	
	FreshFragment()
	_ui.runeDetail.level.text = totalLevel
	RuneData.SetAttributeList(ids , _ui.runeDetail.DetailGrid ,_ui.runInfo.content3Item)
	for i=1, 3 do
		for j=1 , 10 do
			_ui.runeTree[i][j].item_sfx.gameObject:SetActive(false)
		end
	end
	
	SetClickCallback(_ui.runeDetail.button1.gameObject , function()
		_ui.pageToggle[3]:Set(true)
		--Runebag.Show()
		Runedraw.Show()
	end)
	SetClickCallback(_ui.runeDetail.button2.gameObject , function()
		MessageBox.Show(TextMgr:GetText("ui_rune_31") , function() 
			TeardownRune(0 , 1 , function()
				--UpdateTreeNode(rtype , pos , RuneStatus.status_unequip)
				--LoadUnwearedRunes(rtype , false)
				FreshRunePosInfo()
				LoadMainInfo()
			end)
		end , function() end)
	end)
end

local function ChangeRune(beforeData , close_callback)
	_ui.runLeftChange.trf.gameObject:SetActive(true)
	_ui.runeTree.trf.gameObject:SetActive(false)
	
	
	SetupLeftRuneInfo(_ui.runLeftChange.befor , beforeData)
	SetupLeftRuneInfo(_ui.runLeftChange.after , nil)
	
	for i=1 , 3 do
		for j=1 , 10 do
			_ui.runeTree[i][j].item_sfx.gameObject:SetActive(false)
		end
	end
	
	LoadUnwearedRunes(beforeData.RuneData.RuneType , true)
end

LoadRightRuneInfo = function(rtype , pos)
	local equipedRune = RuneData.GetEquipRuneByPos(rtype* 100 + pos)
	if equipedRune then
		--_ui.runInfo.trf.gameObject:SetActive(true)
		--_ui.runInfo.content1.gameObject:SetActive(true)
		--_ui.runInfo.content2.gameObject:SetActive(false)
		
		print("LoadRightRuneInfo")
		ToggleContent(1)
		RuneData.SetAttributeList(equipedRune.data.baseid , _ui.runInfo.content1Grid , _ui.runInfo.contentItem)
		_ui.runInfo.content1:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/" , equipedRune.BaseData.icon)
		_ui.runInfo.content1:Find("Texture/name"):GetComponent("UILabel").text = TextMgr:GetText(equipedRune.BaseData.name)
		--
		SetClickCallback( _ui.runInfo.content1Btn1.gameObject , function()
			TeardownRune(equipedRune.data.uniqueid , 0 , function()
				UpdateTreeNode(rtype , pos , RuneStatus.status_unequip)
				LoadUnwearedRunes(rtype , false)
			end)
		end)
		
		SetClickCallback( _ui.runInfo.content1Btn2.gameObject , function()
			ChangeRune(equipedRune , nil)
		end)
	end
end

FreshEquipedRunes = function()
	LoadUnwearedRunes()
	LoadEquipedRunes()
end

local function ClickRunePos(i , j)
	if i == _ui.selectPos.rtype and _ui.selectPos.pos == j then
		--return
	end

	local runeNode = _ui.runeTree[i][j]
	if runeNode.status ~= RuneStatus.status_locked then
		if _ui.selectPos.rtype > 0 and _ui.selectPos.pos > 0 then
			local lastSelect = _ui.runeTree[_ui.selectPos.rtype][_ui.selectPos.pos]
			lastSelect.selectTrf.gameObject:SetActive(false)
		end
		
		runeNode.selectTrf.gameObject:SetActive(true)
		_ui.selectPos.rtype = i
		_ui.selectPos.pos = j
	end
	
	if runeNode.status == RuneStatus.status_equiped then
		LoadRightRuneInfo(i , j)
	elseif runeNode.status == RuneStatus.status_unequip then
		LoadUnwearedRunes(runeNode.runePosData.RuneType)
	elseif runeNode.status == RuneStatus.status_buy then
		BuyRunePos(runeNode , function()
			--UpdateTreeNode(i , j , RuneStatus.status_unequip)
			--UpdateNextTargetPos()
			--LoadUnwearedRunes(runeNode.runePosData.RuneType)
			ShowRune()
			LoadUI()
		end)
	elseif runeNode.status == RuneStatus.status_active then
		BuyRunePos(runeNode , function()
			--UpdateTreeNode(i , j , RuneStatus.status_unequip)
			--UpdateNextTargetPos()
			--LoadUnwearedRunes(runeNode.runePosData.RuneType)
			ShowRune()
			LoadUI()
		end)
	elseif runeNode.status == RuneStatus.status_locked then
		local nextPos = UpdateNextTargetPos()[i]
		if nextPos ~= nil then
			BuyRunePos(_ui.runeTree[i][nextPos] , function()
				--UpdateTreeNode(i , nextPos , RuneStatus.status_unequip)
				--UpdateNextTargetPos()
				--LoadUnwearedRunes(runeNode.runePosData.RuneType)
				ShowRune()
				LoadUI()
				
				_ui.selectPos.rtype = 0
				_ui.selectPos.pos = 0
			end)
		end
	end
end

--function LuaTableMgr:GetEquipTextDataByAddition(additionArmy, additionAttr)--tableData_tEquipText 
local function LoadAttributeList(runelist , grid  , item)
	local attrList = {}
	for _ , v in pairs(runelist) do
		local runedata = TableMgr:GetRuneDataById(v)
		if runedata then
			BuildAttributeData(runedata.AdditionArmy1 , runedata.AdditionAttr1 , runedata.Value1 , attrList)
			BuildAttributeData(runedata.AdditionArmy2 , runedata.AdditionAttr2 , runedata.Value2 , attrList)
			BuildAttributeData(runedata.AdditionArmy3 , runedata.AdditionAttr3 , runedata.Value3 , attrList)
		end
	end
	
	local attrIndex = 1
	for k_army , v_army in pairs(attrList) do
		for k_attr , v_attr in pairs(v_army) do
			local attrTransform
			if attrIndex > grid.transform.childCount then
				attrTransform = NGUITools.AddChild(grid.gameObject, item.gameObject).transform
			else
				attrTransform = grid.transform:GetChild(attrIndex - 1)
			end
			attrTransform:GetComponent("UILabel").text = TextMgr:GetText(TableMgr.GetEquipTextDataByAddition(k_army, k_attr))
			attrTransform:Find("number"):GetComponent("UILabel").text = Global.IsHeroPercentAttrAddition(k_attr) and v_attr .. "%" or v_attr  
			attrIndex = attrIndex + 1
		end
	end
	
	for i = attrIndex, grid.transform.childCount do
        grid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end 
	
	grid:Reposition()
	
	return attrList
end

local function LoadRuneDetailInfo()
	local testAttrs = {10001}
	--local attrList = GetAttributeList(testAttrs , _ui.runInfo.content1Grid ,_ui.runInfo.contentItem )
end

LoadRunePosInfo = function()
	---
	
	local myLvel = MainData.GetLevel()
	for i=1, 3 do
		for j=1 , 10 do
			local node = _ui.runeTree[i][j]
			if myLvel < node.runePosData.NeedPlayerlvl then
				_ui.runeTree[i][j].status = RuneStatus.status_locked
				_ui.runeTree[i][j].buy.gameObject:SetActive(false)
				_ui.runeTree[i][j].lock.gameObject:SetActive(true)
				_ui.runeTree[i][j].activate.gameObject:SetActive(false)
			else
				_ui.runeTree[i][j].status = RuneStatus.status_unequip
				_ui.runeTree[i][j].buy.gameObject:SetActive(false)
				_ui.runeTree[i][j].lock.gameObject:SetActive(false)
				_ui.runeTree[i][j].activate.gameObject:SetActive(false)
			end
		end
	end
	
	---
	local runePosInfo = RuneData.GetRuneUnlockData()
	for i=1 , #runePosInfo.unlockBlue.ids do
		local id = runePosInfo.unlockBlue.ids[i]
		local rtype = math.floor(id/100)
		local pos = math.floor(id%100)
		_ui.runeTree[rtype][pos].status = RuneStatus.status_unequip
		_ui.runeTree[rtype][pos].buy.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].lock.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].activate.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].item_texture.mainTexture = nil
	end
	
	for i=1 , #runePosInfo.unlockGreen.ids do
		local id = runePosInfo.unlockGreen.ids[i]
		local rtype = math.floor(id/100)
		local pos = math.floor(id%100)
		_ui.runeTree[rtype][pos].status = RuneStatus.status_unequip
		_ui.runeTree[rtype][pos].buy.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].lock.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].activate.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].item_texture.mainTexture = nil
	end
	
	for i=1 , #runePosInfo.unlockRed.ids do
		local id = runePosInfo.unlockRed.ids[i]
		local rtype = math.floor(id/100)
		local pos = math.floor(id%100)
		_ui.runeTree[rtype][pos].status = RuneStatus.status_unequip
		_ui.runeTree[rtype][pos].buy.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].lock.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].activate.gameObject:SetActive(false)
		_ui.runeTree[rtype][pos].item_texture.mainTexture = nil
	end
	
	
	--
	UpdateNextTargetPos()
end

FreshRunePosInfo = function()
	LoadRunePosInfo()
end


local function LoadPageInfo()
	_ui.pageToggle[3].transform:Find("red").gameObject:SetActive(RuneData.IsFreeDraw() > 0)
end

LoadUI = function()
	--load page infp
	LoadPageInfo()
	
	--total info
	LoadMainInfo()

	--runeListInfo
	LoadRunePosInfo()
	LoadEquipedRunes()
	--reset status
	print(_ui.selectPos.rtype , _ui.selectPos.pos)
	if _ui.selectPos.rtype >0 and _ui.selectPos.pos > 0 then
	_ui.runeTree[_ui.selectPos.rtype][_ui.selectPos.pos].selectTrf.gameObject:SetActive(false)
	_ui.selectPos = {rtype = 0, pos = 0}
	end
end


function Awake()
    local closeButton = transform:Find("Container/bg_top/btn_close")
    local mask = transform:Find("Container/mask")
	SetClickCallback(closeButton.gameObject, function()
		CloseAll()
	end)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
	_ui.tipObject = nil
	_ui.selectPos = {rtype = 0, pos = 0}
	local _runeTree = {}
	for i=1 , 3 do
		_runeTree[i] = {}
		for j=1 , 10 do
			_runeTree[i][j] = {}
			local trf = transform:Find(string.format("%s%s/%d" , "Container/bg_frane/left/equip/" , RuneType[i] , j))
			local node = {}
			node.trf = trf
			node.item_texture = trf:Find("Texture"):GetComponent("UITexture")
			node.item_sfx = trf:Find("Texture/sfx_b")
			--node.item_texture = trf:Find("Texture/Texture"):GetComponent("UITexture")
			node.selectTrf = trf:Find("select")
			node.lock = trf:Find("lock")
			node.buy = trf:Find("buy")
			node.activate = trf:Find("activate"):GetComponent("UILabel")
			node.runePosData = TableMgr:GetRunePosData(i*100 + j)
			node.status = RuneStatus.status_locked
			SetClickCallback(node.trf.gameObject , function()
				ClickRunePos(i , j)
			end)
			_runeTree[i][j] = node
		end
	end
	_runeTree.trf = transform:Find("Container/bg_frane/left/equip")
	_ui.runeTree = _runeTree
	_ui.bg_frane = transform:Find("Container/bg_frane")
	
	local _runInfo = {}
	_runInfo.trf = transform:Find("Container/bg_frane/right")
	_runInfo.bg = transform:Find("Container/bg_frane/right/bg")
	_runInfo.content1Close = transform:Find("Container/bg_frane/right/content1/bg/close")
	_runInfo.content1 = transform:Find("Container/bg_frane/right/content1")
	_runInfo.content1ScrollView = transform:Find("Container/bg_frane/right/content1/info/Scroll View"):GetComponent("UIScrollView")
	_runInfo.content1Grid = transform:Find("Container/bg_frane/right/content1/info/Scroll View/Grid"):GetComponent("UIGrid")
	_runInfo.content1Btn1 = transform:Find("Container/bg_frane/right/content1/button1")
	_runInfo.content1Btn2 = transform:Find("Container/bg_frane/right/content1/button2")
	_runInfo.content2 = transform:Find("Container/bg_frane/right/content2")
	_runInfo.content2Close = transform:Find("Container/bg_frane/right/content2/bg/close")
	_runInfo.content2ScrollView = transform:Find("Container/bg_frane/right/content2/info/Scroll View"):GetComponent("UIScrollView")
	_runInfo.content2Grid = transform:Find("Container/bg_frane/right/content2/info/Scroll View/Grid"):GetComponent("UIGrid")
	_runInfo.contentRuneItem = transform:Find("Container/bg_frane/right/content2/info/own")
	_runInfo.content2Btn = transform:Find("Container/bg_frane/right/content2/info/button")
	_runInfo.content2Btn1 = transform:Find("Container/bg_frane/right/content2/info/button/button1")
	_runInfo.content2Btn2 = transform:Find("Container/bg_frane/right/content2/info/button/button2")
	_runInfo.content2None = transform:Find("Container/bg_frane/right/content2/info/none")
	_runInfo.content2GoDrawBtn = transform:Find("Container/bg_frane/right/content2/info/none/button3")
	_runInfo.contentItem = transform:Find("Container/bg_frane/right/content1/info/text")
	_runInfo.content3 = transform:Find("Container/bg_frane/right/content3")
	_runInfo.content3Item = transform:Find("Container/bg_frane/right/content3/text1")
	_ui.runInfo = _runInfo
	
	SetClickCallback(_ui.runInfo.content2GoDrawBtn.gameObject , function()
		_ui.pageToggle[3]:Set(true)
		--Runebag.Show()
		Runedraw.Show()
	end)
	SetClickCallback(_ui.runInfo.content1Close.gameObject , function()
		ShowRune()
		LoadUI()
	end)
	SetClickCallback(_ui.runInfo.content2Close.gameObject , function()
		ShowRune()
		LoadUI()
	end)
	
	local _runeDetail = {}
	_runeDetail.trf = transform:Find("Container/bg_frane/right/content3/info")
	_runeDetail.levelbg = transform:Find("Container/bg_frane/right/content3/info/levelbg")
	_runeDetail.DetailScrollView = transform:Find("Container/bg_frane/right/content3/Scroll View"):GetComponent("UIScrollView")
	_runeDetail.DetailGrid = transform:Find("Container/bg_frane/right/content3/Scroll View/Grid"):GetComponent("UIGrid")
	_runeDetail.levelTotal = transform:Find("Container/bg_frane/right/content3/info/levelbg/Totallevel"):GetComponent("UILabel")
	_runeDetail.level = transform:Find("Container/bg_frane/right/content3/info/levelbg/level"):GetComponent("UILabel")
	_runeDetail.button1 = transform:Find("Container/bg_frane/right/content3/info/button1")
	_runeDetail.button2 = transform:Find("Container/bg_frane/right/content3/info/button2")
	_ui.runeDetail = _runeDetail
	
	local _runLeftChange = {}
	_runLeftChange.trf = transform:Find("Container/bg_frane/left/change")
	_runLeftChange.beforeTextureBox = transform:Find("Container/bg_frane/left/change/before/Texture"):GetComponent("UISprite")
	_runLeftChange.beforeTexture = transform:Find("Container/bg_frane/left/change/before/Texture/Texture"):GetComponent("UITexture")
	_runLeftChange.beforeInfoGrid = transform:Find("Container/bg_frane/left/change/before/info/Label/Grid"):GetComponent("UIGrid")
	_runLeftChange.afterTextureBox = transform:Find("Container/bg_frane/left/change/after/Texture"):GetComponent("UISprite")
	_runLeftChange.afterTexture = transform:Find("Container/bg_frane/left/change/after/Texture/Texture"):GetComponent("UITexture")
	_runLeftChange.afterInfoGrid = transform:Find("Container/bg_frane/left/change/after/info/Label/Grid"):GetComponent("UIGrid")
	_runLeftChange.after = transform:Find("Container/bg_frane/left/change/after")
	_runLeftChange.befor = transform:Find("Container/bg_frane/left/change/before")
	_runLeftChange.afterTip = transform:Find("Container/bg_frane/left/change/Label")
	_runLeftChange.textItem = transform:Find("Container/bg_frane/left/change/before/info/text2")
	_runLeftChange.fragment = transform:Find("Container/bg_frane/left/fragment_icon/Label"):GetComponent("UILabel")
	_runLeftChange.fragmentBox = transform:Find("Container/bg_frane/left/fragment_icon/Sprite")
	_ui.runLeftChange = _runLeftChange
	SetClickCallback(_ui.runLeftChange.fragmentBox.gameObject , function()
		 if _ui.tipObject == nil then
			_ui.tipObject = _ui.runLeftChange.fragmentBox.gameObject
			local itemData = TableMgr:GetItemData(20)
			Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
		end
	end)
	
	
	local _contentToggle = {}
	_contentToggle[1] = transform:Find("Container/bg_frane/right/content1")
	_contentToggle[2] = transform:Find("Container/bg_frane/right/content2")
	_contentToggle[3] = transform:Find("Container/bg_frane/right/content3")
	_ui.contentToggle = _contentToggle
	
	local _contentTweener = {}
	_contentTweener[1] = transform:Find("Container/bg_frane/right/content1")
	_contentTweener[2] = transform:Find("Container/bg_frane/right/content2")
	_contentTweener[3] = transform:Find("Container/bg_frane/right/content3")
	_ui.contentTweener = _contentTweener
	
	
	local _pageToggle = {}
	_pageToggle[1] = transform:Find("Container/page/info1"):GetComponent("UIToggle")
	_pageToggle[2] = transform:Find("Container/page/info2"):GetComponent("UIToggle")
	_pageToggle[3] = transform:Find("Container/page/info3"):GetComponent("UIToggle")
	_ui.pageToggle = _pageToggle
	
	
	EventDelegate.Add(_ui.pageToggle[1].onChange, EventDelegate.Callback(function(go)
		if _ui.pageToggle[1].value then
			ShowRune()
			LoadUI()
		else
			HideRune()
		end
	end))
		
	EventDelegate.Add(_ui.pageToggle[2].onChange, EventDelegate.Callback(function(go)
		if _ui.pageToggle[2].value then
			Runebag.Show()
		else	
			Runebag.Hide()
		end
	end))
	
	EventDelegate.Add(_ui.pageToggle[3].onChange, EventDelegate.Callback(function(go)
		if _ui.pageToggle[3].value then
			Runedraw.Show()
		else	
			Runedraw.Hide()
		end
	end))
	
	AddDelegate(UICamera, "onClick", OnUICameraClick)
	
end

function Start()
	MoneyListData.AddListener(FreshFragment)
	RuneData.AddListener(LoadPageInfo)
	
	PlayerLevelup.AddListener(function()
        RuneData.RequestRuneInfoData()
    end)
end

function Close()
	RemoveDelegate(UICamera, "onClick", OnUICameraClick)
	MoneyListData.RemoveListener(FreshFragment)
	RuneData.RemoveListener(LoadPageInfo)
    _ui = nil
end

function Show(tab)
	--RuneData.RefreshList()
    Global.OpenUI(_M)
    LoadUI()

	local nType , nPos = UpdateNextAvailablePos(_ui.selectPos.rtype)
	if tab and _ui.pageToggle[tab] then
		_ui.pageToggle[tab].value = true
	else
		local unwearLisrt = RuneData.GetUnwearedRunes(nType)
		_ui.pageToggle[1].value = true
		if unwearLisrt and #unwearLisrt > 0 and nType > 0 and nPos > 0 then
			local runeNode = _ui.runeTree[nType][nPos]
			if not ActivityGrow.IsInGuide() then
				GrowGuide.Show(runeNode.trf)
			end
		end
	end
end
