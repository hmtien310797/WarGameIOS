module("ChristmasRewards", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local Format = System.String.Format

local _ui = nil

function Hide()
    Global.CloseUI(_M)
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function ItemSortFunction(v1, v2)
    return v1.id < v2.id
end


local function LoadUI()
	if _ui == nil then 
		return 
	end 
  
	_ui.rewardlist = {}
	local dataList = {}
	for _, v in pairs(tableData_tChristmasActivity.data) do
		if v.RewardType == 2 then 
			table.insert(_ui.rewardlist, v)
		end
	end
	
	table.sort(_ui.rewardlist,ItemSortFunction)
  
	_ui.mypoints.text = Format(TextMgr:GetText("Christmas_ui5"),Christmas.GetDegre().degre)

  --  ShareCommon.LoadRewardList(_ui, _ui.gridTransform, _ui.dropId)
	local childcount = _ui.grid.transform.childCount
	local index = 0
	for i, v in ipairs(_ui.rewardlist) do
		index = i
		local item
		if i - 1 < childcount then
			item = _ui.grid.transform:GetChild(i - 1)
		else
			item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
		end
		item.gameObject:SetActive(true)
		
		local completeObject = item:Find("complete").gameObject
		
		local gridTransform = item:Find("reward/Grid"):GetComponent("UIGrid")
		
		local childcount1 = gridTransform.transform.childCount

		item:Find("bg/name"):GetComponent("UILabel").text =  Format(TextMgr:GetText("Christmas_ui10"),i)
		local rewardIndex = 1
		local j = 1
		for v in string.gsplit(_ui.rewardlist[i].Reward, ";") do
			local itemTable = string.split(v, ":")
			local itemId, itemCount = tonumber(itemTable[2]), tonumber(itemTable[3])
			local itemData = TableMgr:GetItemData(itemId)

			if itemData ~= nil then 
				local itemTransform
				if j - 1 < childcount1 then
					itemTransform = gridTransform.transform:GetChild(j - 1)
				else
					itemTransform = NGUITools.AddChild(gridTransform.gameObject, _ui.rewardItem).transform
				end
				itemTransform.gameObject:SetActive(true)

				local reward = {}
				UIUtil.LoadItemObject(reward, itemTransform)
				UIUtil.LoadItem(reward, itemData, itemCount)
				UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
					if go == _ui.tipObject then
						_ui.tipObject = nil
					else
						_ui.tipObject = go
						Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
					end
				end)
				rewardIndex = rewardIndex + 1
			else 
				print("______________",itemTable[1])
			
			end 
			j = j+1
		end
		for i = rewardIndex + 1, childcount1 do
			gridTransform.transform:GetChild(i - 1).gameObject:SetActive(false)
		end
		gridTransform:Reposition()
		if Christmas.IsGetTreeReward(v) then 
			item:Find("btn_go").gameObject:SetActive(false)
			completeObject:SetActive(true)
		else
			if Christmas.IsCanGetTreeReward(v) then 
				item:Find("btn_go").gameObject:SetActive(true)
				completeObject:SetActive(false)
			else
				item:Find("btn_go").gameObject:SetActive(false)
				completeObject:SetActive(false)
			end 
		end 
		
		
		SetClickCallback(item:Find("btn_go").gameObject, function()
	        GetRewardWithCallBack(_ui.rewardlist[i].id,function()
				LoadUI()
			end )
	    end)
	end
	for i = index + 1, childcount do
		_ui.grid.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
	_ui.grid:Reposition()
	-- _ui.scroll:ResetPosition()
end
    

function Awake()
    _ui = {}
    _ui.containerObject = transform:Find("Container").gameObject
	UIUtil.SetClickCallback(transform:Find("Container/close btn").gameObject, Hide)
    _ui.gridTransform = transform:Find("Container/bg/bg_mid/Scroll View/Grid")
    _ui.grid = _ui.gridTransform:GetComponent("UIGrid")
    _ui.item = transform:Find("listitem_RebelArmyWanted").gameObject
	_ui.rewardlist = {}
	_ui.rewardItem =  transform:Find("listitem_RebelArmyWanted/reward/Grid/Item_CommonNew").gameObject
  
	_ui.mypoints =  transform:Find("Container/bg/bg_mid/mypoints"):GetComponent("UILabel")
  
  
	_ui.rewardItem.transform.parent = _ui.containerObject.transform
	_ui.rewardItem:SetActive(false)
	
    SetClickCallback(_ui.containerObject, Hide)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end


function GetRewardWithCallBack(index,cb)
	local req = ActivityMsg_pb.MsgChristmasGetTreesRewardRequest();
	req.index = index
	print("MsgChristmasGetTreesRewardRequest ", req.index)
	Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgChristmasGetTreesRewardRequest,req, ActivityMsg_pb.MsgChristmasGetTreesRewardResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
	        MainCityUI.UpdateRewardData(msg.fresh)
	        Global.ShowReward(msg.reward)
			Christmas.ReqMsgChristmasInfoRequest(cb)
        end
    end, true)
end 

function Show(sandId, rewardIndex, dropId, starCount, status)
    Global.OpenUI(_M)
    _ui.sandId = sandId
    _ui.rewardIndex = rewardIndex
    _ui.dropId = dropId
    _ui.starCount = starCount
    _ui.status = status
    
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

