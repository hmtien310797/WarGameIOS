module("TemporaryBag", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local bgScrollViewGrid
local bgScrollView
local targetTime = 0

local itemList
local itemDel = {}

function SetTargetTime(n)
	targetTime = n
end

local function OnCloseCallback()
	CountDown.Instance:Remove("TemprotyBagCountDown1")
	GUIMgr:CloseMenu("TemporaryBag")
end

local function OnDeleteItem(go)

--[[
	local req = ItemMsg_pb.MsgClearTempItemRequest()
	for _ , v in pairs(itemDel) do
		if v ~= nil then
			req.itemids:append(v.item_baseid)
			--print(v.item_baseid)
		end
	end
	
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgClearTempItemRequest, req, ItemMsg_pb.MsgClearTempItemResponse, function(msg)	
		ItemListData.UpdateData(msg.fresh.item)
		for _ , v in pairs(itemDel) do
			if v ~= nil then
				local baseid = v.item_baseid
				local uid = v.item_uid
				local num = v.item_num
				
				local delItemName = v.item_uid .. "_" .. v.item_num
				print("del name " .. delItemName)
				local delGridItem = bgScrollViewGrid.transform:Find(delItemName)
				if delGridItem ~= nil then
					print("del name1 " .. delItemName)
					--bgScrollViewGrid:GetComponent("UIGrid"):RemoveChild(delGridItem)
					GameObject.Destroy(delGridItem.gameObject)
					
					local coroutine = coroutine.start(function()
						coroutine.step()
						local gridC = bgScrollViewGrid:GetComponent("UIGrid")
						gridC:Reposition()
						if bgScrollViewGrid.transform.childCount == 0 then
							MainCityUI.UpdateTemprotyBagIcon(false,0)
						end
					end)
				end
			end
		end
		
		--local gridC = bgScrollViewGrid:GetComponent("UIGrid")
		--gridC:Reposition()	
		
		--if bgScrollViewGrid.transform.childCount == 0 then
		--	print("update temNumber")
		--end
	end)
	]]
	local params = go.gameObject.name:split("_")
	local baseid = tonumber(params[1])
	local uid = tonumber(params[2])
	local number = tonumber(params[3])
	
	local req = ItemMsg_pb.MsgClearTempItemRequest()
	req.itemids:append(baseid)
	
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgClearTempItemRequest, req, ItemMsg_pb.MsgClearTempItemResponse, function(msg)
		if msg.code == 0 then
			MainCityUI.UpdateRewardData(msg.fresh)
			local delItemName = uid .. "_" .. number
			print("del name " .. delItemName)
			local delGridItem = bgScrollViewGrid.transform:Find(delItemName)
			if delGridItem ~= nil then
				print("del name1 " .. delItemName)
				GameObject.Destroy(delGridItem.gameObject)
				
				local coroutine = coroutine.start(function()
					coroutine.step()
					local gridC = bgScrollViewGrid:GetComponent("UIGrid")
					gridC:Reposition()
					if bgScrollViewGrid.transform.childCount == 0 then
						MainCityUI.UpdateTemprotyBagIcon(false,0)
					end
				end)
			end
		end
	end)
	
end

local function OnSelectDelete(go)
	local params = go.gameObject.name:split("_")
	local baseid = params[1]
	local uid = params[2]
	local number = params[3]
	
	local togle = go.gameObject:GetComponent("UIToggle")
	if togle.value then
		itemDel[baseid] = {}
		itemDel[baseid].item_baseid = tonumber(baseid)
		itemDel[baseid].item_uid = tonumber(uid)
		itemDel[baseid].item_num = tonumber(number)
	else
		itemDel[baseid] = nil
	end
	print("baseid " .. baseid .. "itemBaseid " .. itemDel[baseid].item_baseid)
end

function Awake()
	itemList = ItemListData.GetData()
end

function Start()
	itemDel = {}
	local btnClose = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(btnClose.gameObject , OnCloseCallback)
	
	local deleteItemBtn = transform:Find("Container/bg_frane/btn_delete"):GetComponent("UIButton")
	SetClickCallback(deleteItemBtn.gameObject , OnDeleteItem)
	
	local detailItem = transform:Find("TemporaryBagInfo")
	bgScrollViewGrid = transform:Find("Container/bg_frane/Scroll View/Grid")
	bgScrollView = transform:Find("Container/bg_frane/Scroll View")
	
	
		
	local hint = transform:Find("Container/bg_frane/bg_mid/txt_hint"):GetComponent("UILabel")
	CountDown.Instance:Add("TemprotyBagCountDown1",targetTime, function(t)
		hint.text = System.String.Format(TextMgr:GetText("ui_bag_hint1") , "[ff0000]"..t.."[-]")
		if t == "00:00:00" then
			CountDown.Instance:Remove("TemprotyBagCountDown1")
		end
	end)
	
	
	--local items = itemList.fresh.items
	for _, v in ipairs(itemList) do
		
		local itemTbData = TableMgr:GetItemData(v.baseid)
		print("----------- " .. v.baseid .. "---------" .. v.number .. "-------" .. itemTbData.itemsize)
		if v.number > itemTbData.itemsize then--FreshDataType_Add
			print("------+++----- " .. v.baseid .. "---------" .. v.number)
			local item = NGUITools.AddChild(bgScrollViewGrid.gameObject , detailItem.gameObject)
			item.gameObject:SetActive(true)
			item.gameObject.name = v.uniqueid .. "_" .. (v.number - itemTbData.itemsize)
			item.transform:SetParent(bgScrollViewGrid , false)
			
			--icon
			local itemicon = item.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
			itemicon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTbData.icon)
			
			--number
			local temNumber = v.number - itemTbData.itemsize
			local itemNum = item.transform:Find("bg_list/bg_icon/num"):GetComponent("UILabel")
			itemNum.text = temNumber
			
			--name
			local itemName = item.transform:Find("bg_list/text_name"):GetComponent("UILabel")
			local textColor = Global.GetLabelColorNew(itemTbData.quality)
			itemName.text = textColor[0] .. TextUtil.GetItemName(itemTbData) .. "[-]"
			
			--des
			local itemdes = item.transform:Find("bg_list/text_name/text_des"):GetComponent("UILabel")
			itemdes.text = TextUtil.GetItemDescription(itemTbData)
			
			--select btn
			local btnSelect = item.transform:Find("bg_list/btn_delete"):GetComponent("UIButton")
			btnSelect.gameObject.name = v.baseid .. "_" .. v.uniqueid .. "_" .. temNumber
			--SetClickCallback(btnSelect.gameObject , OnSelectDelete)
			SetClickCallback(btnSelect.gameObject , OnDeleteItem)
		end
	end
	
	local uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	local scrollv = bgScrollView:GetComponent("UIScrollView")
	scrollv:ResetPosition()
end

