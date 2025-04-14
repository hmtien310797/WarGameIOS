module("ItemListData", package.seeall)
local itemListData = {}
local eventListener = EventListener()
local expireTime
local TableMgr = Global.GTableMgr
local BagRedData = {}

----- Events -------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

local function BroadcastEventOnDataChange(...)
    EventDispatcher.Broadcast(eventOnDataChange, ...)
end
---------------------------------------------------------

function GetData()
    return itemListData
end

function SetExpireTime(time)
    expireTime = time
end

function GetExpireTime()
	return expireTime
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function SetData(data)
    itemListData = data.items
	expireTime = data.expiretime
	NotifyListener()
end

function RequestData(callback)
    local req = ItemMsg_pb.MsgPackageItemRequest();
    Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgPackageItemRequest, req, ItemMsg_pb.MsgPackageItemResponse, function(msg)
        SetData(msg)
        GeneralData.UpdateNoticeStatus()
        --ItemListData.SetExpireTime(msg.expiretime)
        --ItemListData.UpdateData(msg)
        -- for _,v in ipairs(msg.items) do
        --     print("====== " .. v.baseid .. "=====" .. v.uniqueid .. "=====" .. v.number )
        -- end
        --[[
        if msg.expiretime > 0 then
        UpdateTemprotyBagIcon(true , msg.expiretime)
        else
        UpdateTemprotyBagIcon(false , 0)
        end
        ]]
		if callback ~= nil then
			callback()
		end 
    end, true)
end

function SetBagRedData(data)
    BagRedData = data
end

function GetBagRedData()
    return BagRedData
end

function ClearBagRedData()
    BagRedData = {}
end

function GetItemDataByBaseId(baseId)
    for _, v in ipairs(itemListData) do
        if v.baseid == baseId then
            return v
        end
    end
    return nil
end

function GetItemCountByBaseId(baseId)
    local itemData = GetItemDataByBaseId(baseId)
    return itemData ~= nil and itemData.number or 0
end

function GetItemDataByUid(uid)
    for _, v in ipairs(itemListData) do
        if v.uniqueid == uid then
			--print("get uid:" .. v.uniqueid)
            return v
        end
    end
    return nil
end

function GetItemCountByUid(uid)
    local itemData = GetItemDataByUid(uid)
    return itemData ~= nil and itemData.number or 0
end

function RemoveItemDataByUid(uid)
    for i, v in ipairs(itemListData) do
        if v.uniqueid == uid then
            itemListData:remove(i)
            return
        end
    end
end

function UpdateData(data)
	local updateRune = false
	
    expireTime = data.expiretime
    for _, v in ipairs(data.items) do
        if v.optype == Common_pb.FreshDataType_Add then
            local is_new = GetItemDataByBaseId(v.data.baseid) == nil
            itemListData:add()
            itemListData[#itemListData] = v.data
            local itemDatas = TableMgr:GetItemData(v.data.baseid)
            local redDatas = string.split(tostring(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.SlgBagRed).value),";")   
            for i,v in ipairs(redDatas) do
                local redData = string.split(tostring(v),":")
                if itemDatas.type == tonumber(redData[1]) and itemDatas.quality >= tonumber(redData[2]) then
                    BagRedData[itemDatas.id] = itemDatas.type
                    if is_new then
                        MainCityUI.BagNotice()
                    end
                    -- table.insert( BagRedData, bagred)
                end
            end

            BroadcastEventOnDataChange(v.data, 1)
        elseif v.optype == Common_pb.FreshDataType_Fresh then
            local increase = false
            local is_new = false
            for ii, vv in ipairs(itemListData) do
                if vv.uniqueid == v.data.uniqueid then
                    increase = v.data.number > vv.number
                    if increase then
                        is_new = GetItemDataByBaseId(v.data.baseid) == nil
                    end
                    itemListData[ii] = v.data
                end
            end
            
            if increase then
                local itemDatas = TableMgr:GetItemData(v.data.baseid)
                local redDatas = string.split(tostring(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.SlgBagRed).value),";")
                for i,v in ipairs(redDatas) do
                    local redData = string.split(tostring(v),":")
                    if itemDatas.type == tonumber(redData[1]) and itemDatas.quality >= tonumber(redData[2]) then
                        BagRedData[itemDatas.id] = itemDatas.type
                        if is_new then
                            MainCityUI.BagNotice()
                        end
                    end
                end
            end
            BroadcastEventOnDataChange(v.data, 0)
        elseif v.optype == Common_pb.FreshDataType_Delete then
            RemoveItemDataByUid(v.data.uniqueid)
            BroadcastEventOnDataChange(v.data, -1)
        elseif v.optype == Common_pb.FreshDataType_FlagAdd then
        end
    end
	
	if #data.items > 0 then
		RuneData.RefreshList()
        NotifyListener()
    end
end

function HaveEnoughBadgeItem(badgeData)
    for i = 1, 6 do
        local itemId = badgeData["itemId"..i]
        if itemId ~= 0 then
            local itemCount = badgeData["itemCount"..i]
            local itemMsg = GetItemDataByBaseId(itemId)
            if itemMsg == nil or itemMsg.number < itemCount then
                return false
            end
        end
    end
    return true
end

function GetItemListSort()
	local itemTable = {}
	for _ ,v in ipairs(itemListData) do
		--print("iten: " .. v.uniqueid)
		local sitem = {}
		sitem.item = v
		sitem.tbData = TableMgr:GetItemData(v.baseid)
		table.insert(itemTable , sitem)
		--print("iten: " .. v.baseid)
	end
	
	table.sort(itemTable, function(t1, t2)
		--if t1.tbData.quality == t2.tbData.quality then
			if t1.tbData.type == t2.tbData.type then
				if t1.tbData.subtype == t2.tbData.subtype then
					return t1.tbData.itemlevel < t2.tbData.itemlevel
				end
				return t1.tbData.subtype < t2.tbData.subtype
			end
			return t1.tbData.type < t2.tbData.type
		--end
		--return t1.tbData.quality < t2.tbData.quality
	end)

	--print(string.rep('-', 80))
	for _, v in pairs(itemTable) do
		--print(v.item.baseid ,v.tbData.quality , v.tbData.type , v.tbData.subtype , v.tbData.itemlevel)
	end
	--return itemTable

	return itemTable
end

function UpdateEquip(data)
	for i, v in ipairs(itemListData) do
        if v.uniqueid == data.uniqueid then
            itemListData[i] = data
        end
    end
    NotifyListener()
end
