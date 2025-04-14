module("ChestListData", package.seeall)
local chestListData

function GetData()
    return chestListData
end

function SetData(data)
    chestListData = data
end

function RequestData(callback)
    local req = ItemMsg_pb.MsgChestPanelRequest();
    Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgChestPanelRequest, req, ItemMsg_pb.MsgChestPanelResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetData(msg.panelinfo)
            if callback ~= nil then
            	callback()
            end
        end
    end)
end

function GetChestDataByType(chestType)
    for _, v in ipairs(chestListData) do
        if v.type == chestType then
            return v
        end
    end
end

function SetChestDataByType(chestType, data)
    for i, v in ipairs(chestListData) do
        if v.type == chestType then
            chestListData[i] = data
            break
        end
    end
end

function GetNormalChestData()
    return GetChestDataByType(ItemMsg_pb.ect_normal)
end

function GetSeniorChestData()
    return GetChestDataByType(ItemMsg_pb.ect_senior)
end

function GetActiveChestData()
    return GetChestDataByType(ItemMsg_pb.ect_active)
end

function HasFreeChest(chestType)
    local chestMsg = GetChestDataByType(chestType)
    local leftSecond = Global.GetLeftCooldownSecond(chestMsg.freecdtime)
    if leftSecond == 0 and chestMsg.freecount > 0 then
        return true
    end
    return false
end

function HasNormalFreeChest()
    return HasFreeChest(ItemMsg_pb.ect_normal)
end

function HasSeniorFreeChest()
    return HasFreeChest(ItemMsg_pb.ect_senior)
end

function HasNotice()
    return HasNormalFreeChest() or HasSeniorFreeChest()
end
