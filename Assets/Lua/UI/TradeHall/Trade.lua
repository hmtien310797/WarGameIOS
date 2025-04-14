module("Trade", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local SetDragCallback = UIUtil.SetDragCallback
local SetPressCallback = UIUtil.SetPressCallback
local GameObject = UnityEngine.GameObject

local _data
local _container
local _btn_close
local _scrollview
local _grid
local _ratetext
local _numtext
local _timetext
local _btn_trade
local _infoitem

local tradedata
local maxtotal
local totalnum
local numlist
local rate

local canchange
local building
local needFloatText

local _weights
local maxweight
local totalweight

local function CloseSelf()
	Global.CloseUI(_M)
end

function Awake()
	_container = transform:Find("Container").gameObject
	_btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_scrollview = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ratetext = transform:Find("Container/bg_frane/bg_bottom/text"):GetComponent("UILabel")
	_numtext = transform:Find("Container/bg_frane/bg_bottom/text (1)"):GetComponent("UILabel")
	_timetext = transform:Find("Container/bg_frane/bg_btn/time/num"):GetComponent("UILabel")
	_btn_trade = transform:Find("Container/bg_frane/bg_btn/btn_trade").gameObject
	_infoitem = transform:Find("Tradeinfo")
	SetClickCallback(_container, CloseSelf)
	SetClickCallback(_btn_close, CloseSelf)
	_weights = {}
	for i = 3, 6 do
		_weights[i] = Global.GetResWeight(i)
	end
end

local function GetMaxLeftNum(index, num)
	local left = maxtotal
	local leftweight = maxweight
	for i = 3, 6 do
		if i ~= index then
			left = left - numlist[i]
			leftweight = leftweight - numlist[i] * _weights[i]
		end
	end
	left = left < num and left or num
	local weight = num * _weights[index]
	leftweight = leftweight < weight and leftweight or weight
	return math.floor(left), math.floor(leftweight)
end

local function CaculateTotalNum()
	totalnum = 0
	totalweight = 0
	for i = 3, 6 do
		totalnum = totalnum + numlist[i]
		totalweight = totalweight + numlist[i] * _weights[i]
	end
	return math.floor(totalnum), math.ceil(totalweight)
end

local function CaculateItem(item, i, _type, name)
	local leftitemnum = item.slidermax
	local oldvalue = numlist[i]
	if _type == 1 then
		numlist[i] = Mathf.Ceil(item.slider.value * leftitemnum)
		local leftnum, leftweight = GetMaxLeftNum(i, leftitemnum)
		numlist[i] = math.min(numlist[i], leftnum)
		numlist[i] = math.floor(math.min(numlist[i] * _weights[i], leftweight) / _weights[i])
	elseif _type == 2 then
		numlist[i] = numlist[i] - 1
		numlist[i] = math.max(numlist[i], 0)
	elseif _type == 3 then
		numlist[i] = numlist[i] + 1
		local leftnum, leftweight = GetMaxLeftNum(i, leftitemnum)
		numlist[i] = math.min(numlist[i], GetMaxLeftNum(i, leftitemnum))
		numlist[i] = math.floor(math.min(numlist[i] * _weights[i], leftweight) / _weights[i])
		needFloatText = true
	end
	local tn, tw = CaculateTotalNum()
	if tn > maxtotal or tw > maxweight - _weights[i] then
		if canchange and needFloatText then
			canchange = false
			needFloatText = false
			local leftnum, leftweight = GetMaxLeftNum(i, leftitemnum)
			if item.slidermax == 0 then
				FloatText.Show(System.String.Format(TextMgr:GetText("TradeHall_ui17"), name), Color.white)
			else
				FloatText.Show(TextMgr:GetText("TradeHall_ui16"), Color.white)
			end
		end
	else
		needFloatText = true
	end
	item.numtext.text = numlist[i]
	if leftitemnum == 0 then
		item.slider.value = 0
	else
		item.slider.value = numlist[i] / item.slidermax
	end
	local tn, tw = CaculateTotalNum()
	_numtext.text = System.String.Format(TextMgr:GetText("TradeHall_ui3"), tw, maxtotal)
	_ratetext.text = System.String.Format(TextMgr:GetText("TradeHall_ui2"), rate .. "%", math.floor(tn * rate / 100))
end

local function MakeItem(i)
	local item = {}
	item.go = NGUITools.AddChild(_grid.gameObject, _infoitem.gameObject).transform
	item.icon = item.go:Find("bg_icon/icon"):GetComponent("UITexture")
	item.name = item.go:Find("name"):GetComponent("UILabel")
	item.numinput = item.go:Find("text/frame_input").gameObject
	item.numtext = item.go:Find("text/frame_input/title"):GetComponent("UILabel")
	item.num = item.go:Find("text/num"):GetComponent("UILabel")
	item.slider = item.go:Find("bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	item.sliderbtn = item.go:Find("bg_train_time/bg_schedule/bg_btn_slider").gameObject
	item.btn_minus = item.go:Find("bg_train_time/btn_minus").gameObject
	item.btn_add = item.go:Find("bg_train_time/btn_add").gameObject
	item.itemdata = TableMgr:GetItemData(i)
	item.itemnum = MoneyListData.GetMoneyByType(i)
	item.itemnum = math.floor(item.itemnum / (100 + rate) * 100)
	numlist[i] = 0
	item.slider.value = 0
	item.icon.mainTexture = ResourceLibrary:GetIcon("Item/", item.itemdata.icon)
	item.name.text = TextUtil.GetItemName(item.itemdata)
	local max = math.floor(maxtotal / _weights[i])
	item.slidermax = item.itemnum < max and item.itemnum or max
	item.num.text = "/" ..item.slidermax
	item.num.gameObject:SetActive(false)
	item.numtext.text = "0"
	
	SetClickCallback(item.numinput, function()
		NumberInput.Show(numlist[i], 0, item.slidermax, function(number)
	        numlist[i] = number
	        numlist[i] = math.min(numlist[i], GetMaxLeftNum(i, item.slidermax))
	        item.slider.value = numlist[i] / item.slidermax
			item.numtext.text = numlist[i]
			local tn, tw = CaculateTotalNum()
	        _numtext.text = System.String.Format(TextMgr:GetText("TradeHall_ui3"), tw, maxtotal)
			_ratetext.text = System.String.Format(TextMgr:GetText("TradeHall_ui2"), rate .. "%", math.floor(tn * rate / 100))
	    end)
	end)
	item.slider.onDragFinished = function()
		canchange = true
		CaculateItem(item, i, 1, item.name.text)
	end
	SetClickCallback(item.btn_minus, function()
		canchange = true
		CaculateItem(item, i, 2, item.name.text)
	end)
	SetClickCallback(item.btn_add, function()
		canchange = true
		CaculateItem(item, i, 3, item.name.text)
	end)
	SetDragCallback(item.sliderbtn, function()
		canchange = true
	end)
	SetDragCallback(item.slider.gameObject, function()
		canchange = true
	end)
	SetPressCallback(item.slider.gameObject, function(go, isPressed)
		if isPressed then
			EventDelegate.Set(item.slider.onChange,EventDelegate.Callback(function(obj,delta)
				CaculateItem(item, i, 1, item.name.text)
			end))
		else
			EventDelegate.Set(item.slider.onChange,EventDelegate.Callback(function(obj,delta)
				
			end))
		end
		canchange = true
		CaculateItem(item, i, 1, item.name.text)
	end)
end

function GetDistance(mapX1, mapY1, mapX2, mapY2)
    return WorldMap.GetDistance(mapX1, mapY1, mapX2, mapY2)
end

function Start()
	numlist = {}
	totalnum = 0
	needFloatText = true
	tradedata = TableMgr:GetTradingPostData(building.data.level)
	rate = tradedata.rate - (AttributeBonus.CollectBonusInfo()[1089] ~= nil and AttributeBonus.CollectBonusInfo()[1089] or 0)
	maxtotal = tradedata.resNum
	maxweight = maxtotal
	_numtext.text = System.String.Format(TextMgr:GetText("TradeHall_ui3"), 0, maxtotal)
	_ratetext.text = System.String.Format(TextMgr:GetText("TradeHall_ui2"), rate .. "%", 0)
	local WorldMapDistanceFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.WorldMapDistanceFactor).value)
	local TradeBaseSpeed = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.TradeBaseSpeed).value)
	local diffX = _data.x - _data.myx
    local diffY = _data.y - _data.myy
    local params = {}
    params.base = TradeBaseSpeed
    params.speedup = tradedata.speedUp
    local speed = AttributeBonus.CallBonusFunc(44,params)
    local needtime = math.ceil(GetDistance(_data.x , _data.y , _data.myx , _data.myy) / speed)
    
    _timetext.text = Global.SecToDataFormat(needtime)
	for i = 3, 6 do
		MakeItem(i)
	end
	_grid:Reposition()
	SetClickCallback(_btn_trade, function()
		if totalnum == 0 then
			FloatText.ShowAt(_btn_trade.transform.position, TextMgr:GetText("TradeHall_ui14"), Color.white)
			return
		end
		local req = HeroMsg_pb.MsgArmySetoutStarRequest()
        req.seUid = _data.uid
        req.pos.x = _data.x
        req.pos.y = _data.y
        for i = 3, 6 do
        	local res = req.restrans.res:add()
        	res.id = i
        	res.num = numlist[i]
        end
        req.pathType = 13
        LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
            local msg = HeroMsg_pb.MsgArmySetoutStarResponse()
            msg:ParseFromString(data)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.ShowError(msg.code)
                CloseSelf()
            else
                MainCityUI.UpdateRewardData(msg.fresh)
                CloseSelf()
            end
        end, false)
	end)
end

function Close()
	if GameObject.Find("TradeHall") == nil then
    end
    _data = nil
	_container = nil
	_btn_close = nil
	_scrollview = nil
	_grid = nil
	_ratetext = nil
	_numtext = nil
	_timetext = nil
	_btn_trade = nil
	_infoitem = nil
	tradedata = nil
	maxtotal = nil
	totalnum = nil
	numlist = nil
	canchange = nil
	building = nil
	needFloatText = nil
end

function Show(uid, mapx, mapy, myx, myy)
	if uid == 0 and mapx == 0 and mapy == 0 then
		MessageBox.Show(TextMgr:GetText("ui_worldmap62"))
		return
	end
	building = maincity.GetBuildingByID(41)
	if building == nil then
		MessageBox.Show(TextMgr:GetText("TradeHall_ui13"))
		return
	end
	_data = {}
	_data.uid = uid
	_data.x = mapx
	_data.y = mapy
	_data.myx = myx
	_data.myy = myy
	Global.OpenUI(_M)
end
