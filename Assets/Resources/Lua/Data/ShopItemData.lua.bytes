module("ShopItemData", package.seeall)

local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local GUIMgr = Global.GGUIMgr
local ShopItems = {}


function RequestData(index, callback)
    local request = ShopMsg_pb.MsgCommonShopInfoRequest()
    request.index = index

    Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopInfoRequest, request, ShopMsg_pb.MsgCommonShopInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			table.sort(msg.item, function(itemA, itemB)
				return itemA.orderId < itemB.orderId
			end)
			ShopItems[msg.index] = msg.item
		end
		if callback then
            callback(msg)
        end
    end, true)
end

function GetShopItems()
	return ShopItems
end 

function BuyItem(shopItemInfo, num, callback)
    local request = ShopMsg_pb.MsgCommonShopBuyRequest()
    request.exchangeId = shopItemInfo.exchangeId
    request.num = num

    Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopBuyRequest, request, ShopMsg_pb.MsgCommonShopBuyResponse, function(msg)
        if msg.code == 0 then
            MainCityUI.UpdateRewardData(msg.fresh)
            SlgBag.UpdateBagItem(msg.fresh.item.items)

            FloatText.Show(TextMgr:GetText("login_ui_pay1"), Color.green)

            GUIMgr:SendDataReport("purchase", "buyitem", "" .. TableMgr:GetItemExchangeData(shopItemInfo.exchangeId).item, "" .. num, "" .. shopItemInfo.price)
        elseif msg.code == ReturnCode_pb.Code_DiamondNotEnough then
            Global.ShowNoEnoughMoney()
        else
            Global.FloatError(msg.code, Color.white)
        end

        if callback then
            callback(msg)
        end
    end, true)
end
