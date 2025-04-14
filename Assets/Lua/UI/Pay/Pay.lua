module("Pay", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local ShopMsg_pb = require("ShopMsg_pb")
local LoginMsg_pb = require("LoginMsg_pb")

local _btn_close
local _container
local _scroll_view
local _grid
CloseCallBack = nil
local allReadys

local productList

local cardlist
local _UICenterOnChild
local centertargettype
local platformType
local centerTarget
local cardTransList
local InventortList
local oldList

function SetCenterByType(ct)
	centertargettype = ct
end

local function DeleteOldList()
	if oldList ~= nil then
		for i, v in ipairs(oldList) do
			GameObject.Destroy(v)
		end
		oldList = nil
	end
end

local function MakeChildItem(grid, childtype)
	local item = {}
    item.go = GameObject.Instantiate(transform:Find("ItemInfo"))
    item.go.transform:SetParent(grid.transform, false)
    item.bg = item.go.transform:Find("bg_list/background")
    item.bg:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "bg_list_" .. childtype)
    item.name = item.go.transform:Find("bg_list/text_name"):GetComponent("UILabel")
    item.num = item.go.transform:Find("bg_list/num"):GetComponent("UILabel")
    item.icon = item.go.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
    item.quality = item.go.transform:Find("bg_list/bg_icon"):GetComponent("UISprite")
    return item
end

local function CloseSelf()
	GUIMgr:CloseMenu("Pay") 
end

local function SetCloseClickCallback()
	SetClickCallback(_btn_close, CloseSelf)
	--SetClickCallback(_container, CloseSelf)  
end

local function RefreshSomething(_go, _data, childtype, childicontype, msg)
	_go:GetComponent("UISprite").spriteName = "bg_act_" .. childtype
	_go.transform:Find("bg_top"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "bg_title_act_" .. childtype)
	_go.transform:Find("bg_decorate/icon_decorate (1)"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "icon_act_" .. childicontype)
	_go.transform:Find("bg_decorate/Panel/icon_decorate"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "icon_act_" .. childicontype)
	_go.transform:Find("bg_decorate/Panel/watermark"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "watermark_" ..childicontype)
	_go.transform:Find("bg_decorate/Panel/watermark (1)"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "watermark_" .. childicontype)
	_go.transform:Find("bg_decorate/Panel/watermark (2)"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "watermark_" .. childicontype)
	
	local desc = TextMgr:GetText(_data.desc)
	if _data.endTime == nil or _data.endTime == 0 then
		if msg ~= nil then
			_go.transform:Find("bg_time/time"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(_data.subDesc), _data.day)
		else
			_go.transform:Find("bg_time/time"):GetComponent("UILabel").text = TextMgr:GetText(_data.subDesc)
		end
	else
		CountDown.Instance:Add("PaY" .. _data.id, _data.endTime,CountDown.CountDownCallBack(function (t)
        	if _go ~= nil and not _go:Equals(nil) then
        		_go.transform:Find("bg_time/time"):GetComponent("UILabel").text = "[ff0000]" .. t .. "[-]"
        	else
        		CountDown.Instance:Remove("PaY" .. _data.id)
        	end
        end))
	end
	if msg ~= nil then
		_go.transform:Find("bg_time/text"):GetComponent("UILabel").text = System.String.Format(desc, _data.itemBuy.item.item[1].num , _data.day, msg.item.item.item[1].num)
	else
		_go.transform:Find("bg_time/text"):GetComponent("UILabel").text = desc
	end
	if _data.count == nil or _data.count.countmax == 0 then
		_go.transform:Find("bg_top/icon_left").gameObject:SetActive(false)
		_go.transform:Find("bg_top/text").gameObject:SetActive(false)
	else
		local str = ""
		if _data.count.refreshType == Common_pb.LimitRefreshType_Day then
			str = "pay_ui14"
		elseif _data.count.refreshType == Common_pb.LimitRefreshType_Week then
			str = "pay_ui15"
		elseif _data.count.refreshType == Common_pb.LimitRefreshType_Month then
			str = "pay_ui16"
		elseif _data.count.refreshType == Common_pb.LimitRefreshType_Year then
			str = "pay_ui17"
		elseif _data.count.refreshType == Common_pb.LimitRefreshType_Forever then
			str = "pay_ui3"
		end
		_go.transform:Find("bg_top/text"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(str), _data.count.count, _data.count.countmax)
		if(_data.count.count < 0) then
			_go.gameObject:SetActive(false)
		end
	end
end

local function ProcessHuawei(_data, _go)
	local map = {}
	map["amount"] = _data.price
	map["applicationID"] = "10790059"
	map["country"] = "SG"
	map["currency"] = "SGD"
	map["productName"] = _go.transform:Find("bg_top/title"):GetComponent("UILabel").text
	map["productDesc"] = map["productName"]
    map["requestId"] = "?"
    map["sdkChannel"] = "4"
    map["siteId"] = "3"
    map["url"] = "http://47.88.84.160:7501/pay/huawei/deliver"
    map["urlver"] = "2"
    map["userID"] = "890086000102036723"
    local key_table = {}
    for key,_ in pairs(map) do
    	table.insert(key_table, key)
    end
    table.sort(key_table)
    local n = 1
    local str = ""
    for _, key in pairs(key_table) do
    	if n ~= 1 then
    		str = str .. "&"
    	end
    	str = str .. key .. "=" .. map[key]
    	n = n + 1
    end
    return str, map
end

local function StartPay(_data, _go)
	local chargeChanelType = 0
	local chargeParam = ""
	local mapParam = ""
	if platformType == LoginMsg_pb.AccType_adr_googleplay then
		chargeChanelType = ShopMsg_pb.CCT_google
	elseif platformType == LoginMsg_pb.AccType_adr_huawei then
		chargeChanelType = ShopMsg_pb.CCT_huawei
		chargeParam, mapParam = ProcessHuawei(_data, _go)
	elseif platformType == LoginMsg_pb.AccType_adr_efun then
		chargeChanelType = ShopMsg_pb.CCT_efun
	end
	local req = ShopMsg_pb.MsgIAPOrderIdRequest()
	req.id = _data.id
	req.param = chargeParam
	req.chanel = chargeChanelType
	LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPOrderIdRequest, req:SerializeToString(), function (typeId, data)
        local msg = ShopMsg_pb.MsgIAPOrderIdResponse()
        msg:ParseFromString(data)
        if msg.code == 0 then
        	local sendparam = {}
        	if platformType == LoginMsg_pb.AccType_adr_googleplay then
        		if InventortList ~= nil then
					sendparam["currency"] = InventortList[_data.productId]["price_amount_micros"]
					sendparam["currencytype"] = InventortList[_data.productId]["price_currency_code"]
				else
					sendparam["currency"] = "" .. _data.price
					sendparam["currencytype"] = "USD"
				end
			elseif platformType == LoginMsg_pb.AccType_adr_huawei then
				mapParam["userName"] = "weywell"
				mapParam["serviceCatalog"] = "X6"
				mapParam["extReserved"] = msg.orderId
				mapParam["requestId"] = msg.requestId
				mapParam["sign"] = msg.generalSign
				sendparam["huawei"] = cjson.encode(mapParam)
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "SGD"
			elseif platformType == LoginMsg_pb.AccType_adr_tmgp then
				if GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug or GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease then
					sendparam["zoneid"] = "1"
				else
					sendparam["zoneid"] = msg.zoneid
				end
				sendparam["isCanChange"] = "0"
				sendparam["currency"] = "" .. (_data.price * 10)
				sendparam["currencytype"] = "RMB"
			elseif platformType == LoginMsg_pb.AccType_adr_efun then
				sendparam["zoneid"] = "" .. msg.zoneid
				sendparam["roleid"] = "" .. MainData.GetCharId()
				sendparam["roleName"] = "" .. MainData.GetCharName()
				sendparam["roleLevel"] = "" .. MainData.GetLevel()
				sendparam["currency"] = "" .. _data.price
				sendparam["currencytype"] = "USD"
			end
			sendparam["orderid"] = msg.orderId
			sendparam["productid"] = _data.productId
			sendparam["virtualcurrency"] = tonumber(_data.itemBuy.item.item[1].num)
			print(cjson.encode(sendparam))
			GUIMgr:Recharge(cjson.encode(sendparam), msg.orderId, sendparam["currency"])
		else
			Global.ShowError(msg.code)
		end
    end, true)
end

local function MakeItem(grid, _data, n)
	local _go 
	local childtype = tonumber(_data.backgroud)
	local childicontype = tonumber(_data.icon)
	if _data.type == 1 then
		if childtype == nil then
			childtype = 1
		end
		if childicontype == nil then
			childicontype = 1
		end
		if _go == nil then
			_go = GameObject.Instantiate(transform:Find("bg_normal"))
		end
		_go:GetComponent("UISprite").spriteName = "bg_act_" .. childtype
		_go.transform:Find("bg_top"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Pay/", "bg_title_act_" .. childtype)
        if allReadys > 0 then
            allReadys = allReadys -1
            if allReadys <= 0 then
                SetCloseClickCallback()
                DeleteOldList()
                
				coroutine.start(function()
					coroutine.step()
					_grid:Reposition()
					if centertargettype ~= nil and cardlist ~= nil and cardlist[centertargettype] ~= nil then
						_UICenterOnChild:CenterOn(cardlist[centertargettype])
						centertargettype = nil
					else
						if centerTarget ~= nil and cardTransList ~= nil and cardTransList[centerTarget] ~= nil then
							_UICenterOnChild:CenterOn(cardTransList[centerTarget])
						else
							_scroll_view:ResetPosition()
						end
					end
				end)
            end
        end		
	else
		if _go == nil then
			_go = GameObject.Instantiate(transform:Find("bg_bigger"))
		end
		if _data.type == 2 then
			if childtype == nil then
				childtype = 1
			end
			if childicontype == nil then
				childicontype = 1
            end
            if allReadys > 0 then
                allReadys = allReadys -1
                if allReadys <= 0 then
                    SetCloseClickCallback()
                    DeleteOldList()
                    
					coroutine.start(function()
						coroutine.step()
						_grid:Reposition()
						if centertargettype ~= nil and cardlist ~= nil and cardlist[centertargettype] ~= nil then
							_UICenterOnChild:CenterOn(cardlist[centertargettype])
							centertargettype = nil
						else
							if centerTarget ~= nil and cardTransList ~= nil and cardTransList[centerTarget] ~= nil then
								_UICenterOnChild:CenterOn(cardTransList[centerTarget])
							else
								_scroll_view:ResetPosition()
							end
						end
					end)
                end
            end            
		else
			if childtype == nil then
				childtype = 2
			end
			if childicontype == nil then
				childicontype = 2
			end
			cardlist[_data.type] = _go.transform
			local req = ShopMsg_pb.MsgIAPTakeCardInfoRequest()
			req.id = _data.type
			LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeCardInfoRequest, req:SerializeToString(), function (typeId, data)
		        local msg = ShopMsg_pb.MsgIAPTakeCardInfoResponse()
		        msg:ParseFromString(data)
		        if msg.code == 0 then
		        	RefreshSomething(_go, _data, childtype, childicontype, msg)
                end
                if allReadys > 0 then
                allReadys = allReadys -1
                if allReadys <= 0 then
                    SetCloseClickCallback()
                    DeleteOldList()
                    
                    coroutine.start(function()
                    	coroutine.step()
                    	grid:Reposition()
	                    if centertargettype ~= nil and cardlist ~= nil and cardlist[centertargettype] ~= nil then
							_UICenterOnChild:CenterOn(cardlist[centertargettype])
							centertargettype = nil
						else
							if centerTarget ~= nil and cardTransList ~= nil and cardTransList[centerTarget] ~= nil then
								_UICenterOnChild:CenterOn(cardTransList[centerTarget])
							else
								_scroll_view:ResetPosition()
							end
						end
					end)
                end
            end
		    end, true)
		end
		RefreshSomething(_go, _data, childtype, childicontype)
	end
	_go.transform:SetParent(grid.transform, false)
	_go.transform:Find("bg_gold/icon"):GetComponent("UISprite").spriteName = _data.priceIcon
	_go.transform:Find("bg_top/title"):GetComponent("UILabel").text = TextMgr:GetText(_data.name)
	_go.transform:Find("bg_gold/text"):GetComponent("UILabel").text = _data.itemBuy.item.item[1].num
	local sp = _data.showPrice - 1
	if sp > 0 then
		_go.transform:Find("bg_gold/text_sale"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("pay_ui10"),math.floor(sp * 100)) .. "%"
	else
		_go.transform:Find("bg_gold/text_sale"):GetComponent("UILabel").text = ""
	end
	
	local __grid = _go.transform:Find("bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	local count = 0
	local gold = 0
	for i, v in ipairs(_data.itemGift.item.item) do
		if v.baseid == 2 then
			gold = v.num
		else
			count = count + 1
			local _item = MakeChildItem(__grid, childtype)
			local itData = TableMgr:GetItemData(v.baseid)
			local textColor = Global.GetLabelColorNew(itData.quality)
			_item.name.text = textColor[0] .. TextUtil.GetItemName(itData) .. "[-]"
			_item.num.text = v.num
			_item.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itData.icon)
			_item.quality.spriteName = "bg_item" .. itData.quality
			if count % 2 == 0 then
				_item.bg.gameObject:SetActive(false)
			end
		end
	end
	_go.transform:Find("bg_gold/text (1)"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("pay_ui18"), gold)
	if _data.guildChestId ~= nil and _data.guildChestId > 0 then
		local _item = MakeChildItem(__grid, childtype)
		itData = TableMgr:GetUnionItemData(_data.guildChestId)
		local textColor = Global.GetLabelColorNew(itData.quality)
		_item.name.text = textColor[0] .. TextUtil.GetItemName(itData) .. "[-]"
		_item.num.text = "1"
		_item.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itData.icon)
		_item.quality.spriteName = "bg_item" .. itData.quality
		if (count + 1) % 2 == 0 then
			_item.bg.gameObject:SetActive(false)
		end
	end
	__grid:Reposition()
	local buybtn = _go.transform:Find("btn_buy").gameObject
	SetClickCallback(buybtn, function()
		StartPay(_data, _go)
		centerTarget = n
	end)
	if InventortList ~= nil then
		_go.transform:Find("btn_buy/num"):GetComponent("UILabel").text = InventortList[_data.productId]["price"]
	else
		if platformType == LoginMsg_pb.AccType_adr_huawei then
			_go.transform:Find("btn_buy/num"):GetComponent("UILabel").text = "SGD$" .. _data.price
		elseif platformType == LoginMsg_pb.AccType_adr_tmgp or
		Global.IsIosMuzhi() or
		platformType == LoginMsg_pb.AccType_adr_muzhi or
		platformType == LoginMsg_pb.AccType_adr_opgame or
		platformType == LoginMsg_pb.AccType_adr_mango or
		platformType == LoginMsg_pb.AccType_adr_official or
		platformType == LoginMsg_pb.AccType_ios_official or
		platformType == LoginMsg_pb.AccType_adr_official_branch or
		platformType == LoginMsg_pb.AccType_adr_quick or
		platformType == LoginMsg_pb.AccType_adr_qihu then
			_go.transform:Find("btn_buy/num"):GetComponent("UILabel").text = "RMB￥" .. _data.price
		else
			_go.transform:Find("btn_buy/num"):GetComponent("UILabel").text = "US$" .. _data.price
		end
	end
	cardTransList[n] = _go.transform
	return _go
end

local function ShopInfoRequest(callback)
	local req = ShopMsg_pb.MsgIAPGoodInfoRequest()
	req.type = 0
	LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPGoodInfoRequest, req:SerializeToString(), function (typeId, data)
        local msg = ShopMsg_pb.MsgIAPGoodInfoResponse()
        msg:ParseFromString(data)
        callback(msg)
    end, true)
end

function Awake()
	_btn_close = transform:Find("Container/btn_close").gameObject
	_container = transform:Find("Container").gameObject
	_scroll_view = transform:Find("Container/Scroll View"):GetComponent("UIScrollView")
	_grid = transform:Find("Container/Scroll View/Grid"):GetComponent("UIGrid")
	_UICenterOnChild = _grid:GetComponent("UICenterOnChild")
	allReadys = 0
end

function Start()
	if tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PayActivity).value) ~= 1 then
		CloseSelf()
		return
	end
	platformType = GUIMgr:GetPlatformType()
	print(platformType)
	if UnityEngine.Application.isEditor then
		platformType = LoginMsg_pb.AccType_adr_tmgp
	end
	cardlist = {}
	ShowShop()
end

function ShowShop()
	if transform == nil or transform:Equals(nil) then
		return
	end
	ShopInfoRequest(function(msg)
		if msg.code == 0 then
			table.sort(msg.goodInfos, function(a, b) return a.order > b.order end)
			allReadys = #(msg.goodInfos)
			print(allReadys)
			local productIds = ""
			for i, v in ipairs(msg.goodInfos) do
				productIds = productIds .. v.productId
				if i < allReadys then
					productIds = productIds .. ","
				end
			end
			for i = 1, _grid.transform.childCount do
				if oldList == nil then
					oldList = {}
				end
				oldList[i] = _grid.transform:GetChild(i-1).gameObject
			end
			productList = {}
			local n = 0
			cardTransList = {}
			for i, v in ipairs(msg.goodInfos) do
				MakeItem(_grid, v, n)
				productList[n] = v.productId
				n = n + 1
			end
			
			if InventortList == nil then 
				GUIMgr:GetInventoryList(productIds)
			end
        end
	end)
end

function OnGetInventortList(param)
	if transform == nil or transform:Equals(nil) then
		return
	end
	if param ~= nil then
		InventortList = {}
		local tmp = cjsonSafe.decode(param)
		for key, value in pairs(tmp) do
			print(value)
			InventortList[key] = cjsonSafe.decode(value)
			print(InventortList[key])
		end
		local childCount = _grid.transform.childCount
		for i = 0, childCount - 1 do
			local _go = _grid.transform:GetChild(i)
			_go.transform:Find("btn_buy/num"):GetComponent("UILabel").text = InventortList[productList[i]]["price"]
		end
	end
end

function Deliver(orderId, receipt, channel, productId, signature, platorderid)
	local req = ShopMsg_pb.MsgIAPChargeDeliverRequest()
	req.chanel = channel
    req.orderId = orderId
    req.receipt = receipt
    req.productid = productId
    req.sign = signature
    req.platorderid = platorderid
    LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPChargeDeliverRequest, req:SerializeToString(), function (typeId, data)
        local msg = ShopMsg_pb.MsgIAPChargeDeliverResponse()
        msg:ParseFromString(data)
        if msg.code == 0 then
			GUIMgr:RechargeSucc()
			--[[
			if MainData.HadRecharged() then
				GUIMgr:SendDataReport("efun", "fr")
			end]]
        	--MessageBox.Show(TextMgr:GetText("login_ui_pay1"))
        	ShowShop()
        	MainData.SetRecharged()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function Close()
	centertargettype = nil
	cardlist = nil
	centerTarget = nil
	_btn_close = nil
	_container = nil
	_scroll_view = nil
	_grid = nil
	
	local cb = CloseCallBack
	CloseCallBack = nil
	if cb ~= nil then 
	    cb()
    end
	allReadys = nil
	productList = nil
	cardlist = nil
	_UICenterOnChild = nil
	platformType = nil
	InventortList = nil
	oldList = nil
end

function Show()
    Global.OpenUI(_M)
end
