module("MobaPackageItemData", package.seeall)
local TextMgr = Global.GTextMgr

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

           itemListData:add()
           itemListData[#itemListData] = v.data
		   print("MobaItem add ",v.data.baseid,v.data.number)
            for ii, vv in ipairs(itemListData) do
                if vv.baseid == v.data.baseid then
                    itemListData[ii].number = v.data.number
                end
            end

            --BroadcastEventOnDataChange(v.data, 1)
        elseif v.optype == Common_pb.FreshDataType_Fresh then
            local is_new = false
			-- print("MobaItem fresh ",v.data.baseid,v.data.number)
            for ii, vv in ipairs(itemListData) do
                if vv.baseid == v.data.baseid then
                    itemListData[ii].number = v.data.number
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

function GetItemDataByUid(uid)
	if itemListData == nil then 
		return nil 
	end
    for _, v in ipairs(itemListData) do
        if tonumber(v.baseid) == tonumber(uid) then
			--print("get uid:" .. v.baseid)
            return v
        end
    end
    return nil
end


function RemoveItemDataByUid(uid)
    for i, v in ipairs(itemListData) do
        if v.baseid == uid then
            itemListData:remove(i)
            return
        end
    end
end

function SetData(data)
    itemListData = data
    NotifyListener()
end

function GetDataWithCallBack(cb)
	if Global.GetMobaMode() == 1 then
		local req = MobaMsg_pb.MsgMobaPackageItemRequest()
		Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaPackageItemRequest, req, MobaMsg_pb.MsgMobaPackageItemResponse, function(msg)
			Global.DumpMessage(msg , "d:/MsgMobaPackageItemRequest.lua")
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				SetData(msg.items)
				if cb ~= nil then
					cb()
				end
			end
		end, true)
	elseif Global.GetMobaMode() == 2 then
		local req = GuildMobaMsg_pb.GuildMobaPackageItemRequest()
		Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaPackageItemRequest, req, GuildMobaMsg_pb.GuildMobaPackageItemResponse, function(msg)
			Global.DumpMessage(msg , "d:/GuildMobaPackageItemRequest.lua")
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				SetData(msg.items)
				if cb ~= nil then
					cb()
				end
			end
		end, true)
	end
end

function BuyWithCheck(itemID,num,cb)

	local itemBagData =	GetItemDataByUid(itemID)
	if itemBagData~=nil then 
		cb(true,false)
		return
	end 
	
	if Global.GetMobaMode() == 1 then
		local itemdata = MobaItemData.GetItemDataByBaseId(itemID)
		if MobaMainData.GetData().data.mobaScore >= itemdata.needScore * num then 
			if cb ~= nil then
				cb(false,false)
			end
			return 
		else
			local tip = System.String.Format(TextMgr:GetText(Text.ui_moba_45), itemdata.needGold*num)
			MessageBox.Show(tip, function() 
				if cb ~= nil then
					cb(false,true)
				end
			end, function() end)
		end
	else
		if cb ~= nil then
			cb(false,true)
		end
	end 
end

