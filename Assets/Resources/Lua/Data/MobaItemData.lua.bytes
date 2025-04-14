module("MobaItemData", package.seeall)

local eventListener = EventListener()
local TableMgr = Global.GTableMgr
local itemListData
local expireTime

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
    return itemListData
end

function UpdateData(data)
	local updateRune = false
	
    expireTime = data.expiretime
    for _, v in ipairs(data.items) do
        if v.optype == Common_pb.FreshDataType_Add then

           -- itemListData:add()
           -- itemListData[#itemListData] = v.data
		   -- print("MobaItem add ",v.data.baseid,v.data.number)
            for ii, vv in ipairs(itemListData) do
                if vv.itemId == v.data.baseid then
                    itemListData[ii].curBuyNum = v.data.number
                end
            end

            --BroadcastEventOnDataChange(v.data, 1)
        elseif v.optype == Common_pb.FreshDataType_Fresh then
            local is_new = false
			-- print("MobaItem fresh ",v.data.baseid,v.data.number)
            for ii, vv in ipairs(itemListData) do
                if vv.itemId == v.data.baseid then
                    itemListData[ii].curBuyNum = v.data.number
                end
            end

           -- BroadcastEventOnDataChange(v.data, 0)
        elseif v.optype == Common_pb.FreshDataType_Delete then
             RemoveItemDataByUid(v.data.baseid)
           -- BroadcastEventOnDataChange(v.data, -1)
        elseif v.optype == Common_pb.FreshDataType_FlagAdd then
        end
    end
	
	if #data.items > 0 then
	--	RuneData.RefreshList()
        NotifyListener()
    end
end

function RemoveItemDataByUid(uid)
    for i, v in ipairs(itemListData) do
        if v.itemId == uid then
            itemListData:remove(i)
            return
        end
    end
end

function GetItemDataByUid(uid)
    for _, v in ipairs(itemListData) do
        if tonumber(v.exchangeId) == tonumber(uid) then
			--print("get uid:" .. v.uniqueid)
            return v
        end
    end
    return nil
end

function GetItemDataByBaseId(uid)
    for _, v in ipairs(itemListData) do
        if tonumber(v.itemId) == tonumber(uid) then
			--print("get uid:" .. v.uniqueid)
            return v
        end
    end
    return nil
end

function SetData(data)
    itemListData = data
    NotifyListener()
end

function GetDataWithCallBack(cb)
	if Global.GetMobaMode() == 1 then
		local req = MobaMsg_pb.MsgMobaShopItemListRequest()
		Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaShopItemListRequest, req, MobaMsg_pb.MsgMobaShopItemListResponse, function(msg)
			Global.DumpMessage(msg , "d:/MsgMobaShopItemListRequest.lua")
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				SetData(msg.info)
				if cb ~= nil then
					cb()
				end
			end
		end, true)
	elseif Global.GetMobaMode() == 2 then
		local req = GuildMobaMsg_pb.GuildMobaShopItemListRequest()
		Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaShopItemListRequest, req, GuildMobaMsg_pb.GuildMobaShopItemListResponse, function(msg)
			Global.DumpMessage(msg , "d:/GuildMobaShopItemListRequest.lua")
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
            else
                print("@@@@@@@@@@@@@@@@@@@@@@@ GuildMobaShopItemListRequest     ",msg.info)
				SetData(msg.info)
				if cb ~= nil then
					cb()
				end
			end
		end, true)
	end 
end