module("SlgBag", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local AudioMgr = Global.GAudioMgr
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local unionShopInfoMsg

local bagDefaultDisplay = 0 
local useItemReward

local box
local useItemUid = 0

local usebtn

local _ui = nil

local ClimbMode
local RefrushClimbShop = nil

function OnUICameraClick(go)
	if _ui == nil then
		return
	end
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	print(go.name)
end

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("SlgBag")
	end
end

local function OnGridReposition()
	if _ui.bgScrollViewGrid.childCount <= 4 then
		_ui.ubgScrollView.enabled = false
	else
		_ui.ubgScrollView.enabled = true
	end
end

local function RefresgBagInfo()
	if ClimbMode then
		_ui.shopGold.text = Global.ExchangeValue(MoneyListData.GetDiamond())
		_ui.UnionShopGold.text =  Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_ClimbCoin))
		_ui.ArenaShopGold.text =  Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_ArenaCoin))
		--[[
		if unionShopInfoMsg ~= nil then
			_ui.UnionFreshNum.gameObject:SetActive(true)
			_ui.UnionFreshNum.text = unionShopInfoMsg.shopInfo.refreshCost
		end		
		--]]
		return  
	end

	if _ui ~= nil then
		_ui.shopGold.text = Global.ExchangeValue(MoneyListData.GetDiamond())
		_ui.UnionShopGold.text =  Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_GuildCoin))
		_ui.ArenaShopGold.text =  Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_ArenaCoin))
		if unionShopInfoMsg ~= nil then
			_ui.UnionFreshNum.gameObject:SetActive(unionShopInfoMsg.shopRefreshInfo.maxFreeCount > unionShopInfoMsg.shopRefreshInfo.usedFreeCount)
			_ui.UnionFreshNum.text = unionShopInfoMsg.shopRefreshInfo.maxFreeCount - unionShopInfoMsg.shopRefreshInfo.usedFreeCount
		end
		
		if ArenaShop.GetShopInfo() ~= nil then
			_ui.ArenaFreshNum.gameObject:SetActive(ArenaShop.GetShopInfo().shopRefreshInfo.maxFreeCount > ArenaShop.GetShopInfo().shopRefreshInfo.usedFreeCount)
			_ui.ArenaFreshNum.text = ArenaShop.GetShopInfo().shopRefreshInfo.maxFreeCount - ArenaShop.GetShopInfo().shopRefreshInfo.usedFreeCount
		end
	end
end

local function BoxCloseClickCallback(go)
	ResetBoxShowDisplay()
	_ui.bagContainer.gameObject:SetActive(true)
	_ui.boxInfoContainer.gameObject:SetActive(false)
end

local function ChangeDisplay(go, isPressed)
	if not isPressed then
		local displayParams = go.gameObject.name:split("_")
		local displayId = displayParams[3]
		
		print("change display : " .. displayId)
		ChangeBagDisplay(tonumber(displayId))
	end
end

function CheckSureItemUse(itemUid, number , UseFunc)
	--check buff
	local itemMsg = ItemListData.GetItemDataByUid(itemUid)
	if itemMsg ~= nil then
		local itemData = TableMgr:GetItemData(itemMsg.baseid)
		local buffdata = BuffData.HaveSameBuff(0 , itemData.param1)
		local curTime = Serclimax.GameTime.GetSecTime()
		
		if buffdata ~= nil then
			print(buffdata.time , curTime , #BuffData.GetData() , buffdata.time > curTime)
		end
		
		if itemData.type == 31 and itemData.subtype == 1 and JailInfoData.HasPrisoner() then
            MessageBox.Show(TextMgr:GetText(Text.jial_release_notice), function()
                if UseFunc ~= nil then
                    UseFunc(tonumber(itemUid) , number)
                end
            end,
            function()
				if usebtn ~= nil and not usebtn:Equals(nil) then
					usebtn.transform:GetComponent("UIButton").enabled = true
				end
            end)
		elseif buffdata ~= nil and (buffdata.time > curTime)then
			local buffTableData = TableMgr:GetSlgBuffData(buffdata.buffId)
			print("========== buff data :" .. buffdata.uid .. " time :".. buffdata.time .. "build :" .. buffdata.buffMasterId)
			
			local okCallback = function()
				if UseFunc ~= nil then
					UseFunc(tonumber(itemUid) , number)
				end
				CountDown.Instance:Remove("BuffCountDown")
				MessageBox.Clear()
			end
			local cancelCallback = function()
				if usebtn ~= nil and not usebtn:Equals(nil) then
					usebtn.transform:GetComponent("UIButton").enabled = true
				end
				CountDown.Instance:Remove("BuffCountDown")
				MessageBox.Clear()
			end
    print("CheckSureItemUse################", msg)
			
			MessageBox.Show(msg, okCallback, cancelCallback)
			local mbox = MessageBox.GetMessageBox()
			if mbox ~= nil then
				CountDown.Instance:Add("BuffCountDown",buffdata.time, function(t)
					mbox.msg.text = System.String.Format(TextMgr:GetText("speedup_ui5") , TextUtil.GetSlgBuffTitle(buffTableData) , t)
					if t == "00:00:00" then
						CountDown.Instance:Remove("BuffCountDown")
					end
				end)
			end
		else
			if UseFunc ~= nil then
				UseFunc(tonumber(itemUid) , number)
			end
		end		
	end
end

function ReportData(useItemId , useCount , useGold ,msg)
	local itemData = ItemListData.GetItemDataByUid(useItemId)
	if useGold then
		GUIMgr:SendDataReport("purchase", "costgold", "item:" .. itemData.baseid, "" .. useCount, "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
	else
		GUIMgr:SendDataReport("purchase", "useitem", "" .. itemData.baseid, "" .. useCount)
	end
end

local function CheckIsBox(uid,itemTBData,maxnum,num)
	
	if itemTBData.type==3 and itemTBData.subtype==5  then 
		UseSelectBox.Show(uid,tableData_tOptionalPack.data[itemTBData.param1].RewardItem,maxnum,num,ItemUseCount)
		return true
	end 
	-- UseSelectBox.Show(uid,tableData_tOptionalPack.data[1].RewardItem,maxnum,num,ItemUseCount)
	return false
end 

local function ItemUse(go, isPressed)
	if not isPressed then
		local params = go.gameObject.name:split("_")
		useItemUid = tonumber(params[3])
		--MsgUseItemRequest
		--MsgUseItemResponse
		--print("use item req : " .. useItemUid)
		local itemData = ItemListData.GetItemDataByUid(useItemUid)
		local itemTBData = TableMgr:GetItemData(itemData.baseid)
		
		if CheckIsBox(useItemUid,itemTBData,itemData.number,1)== true then 
			return 
		end 
		
		if itemTBData.itemuse ~= nil and itemTBData.itemuse ~= "" then
			local funstr = System.String.Format("{0}.Use()" , "Item_" .. itemData.baseid--[[itemTBData.itemuse]])
			print("funstr:" .. funstr)
			Global.GetTableFunction(funstr)()
			return
		end
	
	
		if go.transform:GetComponent("UIButton").enabled then
			go.transform:GetComponent("UIButton").enabled = false
			usebtn = go
			CheckSureItemUse(useItemUid , 1 , ItemUseCount)
		end
		--ItemUseCount(useItemUid , 1)
	end
end

local function ItemUseMuti(go, isPressed)
	if not isPressed then
		local params = go.gameObject.name:split("_")
		useItemUid= tonumber(params[4])
		
		local itemData = ItemListData.GetItemDataByUid(useItemUid)
		local itemTBData = TableMgr:GetItemData(itemData.baseid)
	
		if CheckIsBox(useItemUid,itemTBData,itemData.number,itemData.number) == true then 
			return 
		end 
		
		UseItem.InitItem(useItemUid)
		UseItem.SetUseCallBack(MutiUseItemCallBack)
		print("mutiuse item id: " .. useItemUid)
		
		GUIMgr:CreateMenu("UseItem" , false)
	end
end


function MutiUseItemCallBack(useCount)
	--CheckSureItemUse(useItemUid , useCount)
	ItemUseCount(useItemUid , useCount)
end

function ItemUseCount(useItemId , useCount, selIndex)
--    print("id" .. useItemId .. "num:" .. useCount)
	local req = ItemMsg_pb.MsgUseItemRequest()
	req.uid = useItemId
	req.num = useCount
	
	if selIndex ~= nil then 
		req.chestSelect:append(selIndex)
	end 
	
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
--		print("use item code:" .. msg.code)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			ReportData(useItemId , useCount , false , msg)
		
			local item = ItemListData.GetItemDataByUid(useItemId)
			local itData = TableMgr:GetItemData(item.baseid)
			--print(item.baseid , itData.type , #msg.reward.item.item)
			if itData.type == 3 then
				local rewardnum = #msg.reward.item.item + #msg.reward.hero.hero+ #msg.reward.army.army
				
				if rewardnum >= 1 then
					local getItemList = {}
					for _ , v in ipairs(msg.reward.item.item) do
						local getItem = {baseid = v.baseid , num = v.num}
						table.insert(getItemList , getItem)
					end
					ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
					ItemListShowNew.SetItemShow(msg)
					GUIMgr:CreateMenu("ItemListShowNew" , false)
				elseif rewardnum == 1 then
					if #msg.reward.item.item == 1 then
						local getitem = TableMgr:GetItemData(msg.reward.item.item[1].baseid)
						local nameColor = Global.GetLabelColorNew(getitem.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui1") ,nameColor[0]..TextUtil.GetItemName(getitem)..nameColor[1])
						FloatText.Show(showText , Color.white)
					end
					
					if #msg.reward.hero.hero == 1 then
						local heroData = TableMgr:GetHeroData(msg.reward.hero.hero[1].baseid)
						local nameColor = Global.GetLabelColorNew(heroData.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui1") ,nameColor[0]..TextMgr:GetText(heroData.nameLabel)..nameColor[1])
						FloatText.Show(showText , Color.white)
					end
					
					
					-- 不播放get音效 bug ID： 1001337
					--AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
				end
			elseif itData.type == 9 and itData.subtype == 1 then
				if MainData.GetVipValue().viplevel < tonumber(itData.param1) then
					VIPLevelup.Show(MainData.GetVipValue().viplevel, itData.param1, 1, itData.param2)								
					MainData.UpdateVip(msg.fresh.maindata.vip)
					ConfigData.SetVipExperienceCard(false)
					MainCityUI.RefreshVipExperienceCard()
					MainCityUI.RefreshVipEffect()
					VipData.RequestVipPanel()
				end
			elseif itData.type == 5 or itData.type == 31 then
				local nameColor = Global.GetLabelColorNew(itData.quality)
				local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
				FloatText.Show(showText , Color.white,ResourceLibrary:GetIcon("Item/", itData.icon))
			elseif itData.type == 33 then
				MainData.UpdateRentBuildQueueExpire(msg.fresh.maindata)
				MainCityQueue.UpdateQueue()
			else
			
				--不播放get音效 bug ID： 1001337
				--AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
				
				--[[统一道具使用获得表现
				local nameColor = Global.GetLabelColorNew(itData.quality)
				local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
				FloatText.Show(showText , Color.white)]]

				for i=1 , #msg.reward.item.item , 1 do
					local item_data = TableMgr:GetItemData(msg.reward.item.item[i].baseid)
					FloatText.Show(TextUtil.GetItemName(item_data).."x"..msg.reward.item.item[i].num , Color.green,ResourceLibrary:GetIcon("Item/", item_data.icon))
				end
			end
			ItemListData.SetExpireTime(msg.fresh.item.expiretime)
			--先更新背包再刷新显示
			MainCityUI.UpdateRewardData(msg.fresh)
			UpdateBagItem(msg.fresh.item.items)
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			
		end
		
		if usebtn ~= nil and not usebtn:Equals(nil) then
			usebtn.transform:GetComponent("UIButton").enabled = true
		end
	end , true)
end

local function	ShowSlgBag()
end

local function	ShowShop(index)
	-- local param = {}
	-- param.scroll_view = _ui.shopScroll_view
	-- param.grid = _ui.shopGrid
	-- param.item = _ui.detailItem
	-- Shop.ShowShopIndex(index , param)
	
	-- RefresgBagInfo()
	Goldstore.Show(31, index)
end


function ShowArenaShop()

	print("ShowArenaShop")
	local param = {}
	param.scroll_view = _ui.arenaShopScroll_view
	param.grid = _ui.arenaShopGrid
	param.item = _ui.detailItem
	
	ArenaShop.RequestShopData(param , function(msg)
		RefresgBagInfo()
		if ArenaShop.GetShopInfo() == nil or ArenaShop.GetShopInfo().shopRefreshInfo == nil then
			return
		end 

		coroutine.stop(_ui.arenacountdowncoroutine)
		_ui.arenacountdowncoroutine = coroutine.start(function()

			while true do
				local left_time = ArenaShop.GetShopInfo().shopRefreshInfo.nextRefreshTime-Serclimax.GameTime.GetSecTime() 
				if _ui == nil then 
					break;
				end
				if left_time <= 0 then
					_ui.arenaShopTime.text = ""
					ArenaShop.GetShopInfo().shopRefreshInfo.nextRefreshTime =0 
					FreshArenaShop(true)
					break
				end
				_ui.arenaShopTime.text = Global.SecondToTimeLong(left_time)

				coroutine.wait(1)
			end
		end)
	end)
	
end

local function ShowUnionShop()
	print("ShowUnionShop")
	if not UnionInfoData.HasUnion() then
		FloatText.Show(TextMgr:GetText("union_join_no"), Color.white)
		return
	end
	
	
	
	local param = {}
	param.scroll_view = _ui.unionShopScroll_view
	param.grid = _ui.unionShopGrid
	param.item = _ui.detailItem
	
	UnionShop.RequestUnionShopData(param , function(msg)
		unionShopInfoMsg = msg
		RefresgBagInfo()
	end)
	
end

local function FreshUnionShop()

	if ClimbMode then
		RefrushClimbShop()
		return
	end
	local param = {}
	param.scroll_view = _ui.unionShopScroll_view
	param.grid = _ui.unionShopGrid
	param.item = _ui.detailItem
	param.freshType = 1
	

	
	-- if unionShopInfoMsg.shopRefreshInfo.maxFreeCount <= unionShopInfoMsg.shopRefreshInfo.usedFreeCount then
	-- 	param.freshType = 2
	-- 	MessageBox.Show(System.String.Format(TextMgr:GetText("Union_Shop_ui5"),unionShopInfoMsg.shopRefreshInfo.nextCostDiamond) , function() UnionShop.RequestFreshShop(param , function(msg)
	-- 		unionShopInfoMsg = msg
	-- 		RefresgBagInfo()
	-- 	end) end, function() end)
	-- else
	-- 	UnionShop.RequestFreshShop(param , function(msg)
	-- 		unionShopInfoMsg = msg
	-- 		RefresgBagInfo()
	-- 	end)
	-- end
end

function FreshArenaShop(force)
	local param = {}
	param.scroll_view = _ui.arenaShopScroll_view
	param.grid = _ui.arenaShopGrid
	param.item = _ui.detailItem
	param.force = force
	
	ArenaShop.FreshInfoCallback(param,function(msg)
		ShowArenaShop()
	end )
	
end

function LateUpdate()
	if unionShopInfoMsg == nil then
		return
	end
	local clientRefreshTime = 0
	clientRefreshTime = Global.GetFiveOclockCooldown() + 2
	if ClimbMode then
		if clientRefreshTime > 0 then -- 刷新时间延迟5s
			_ui.Climb_shop_freshTime.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown())
		else
			unionShopInfoMsg = nil
			FreshUnionShop()
		end
		return 
	end

	if clientRefreshTime > 0 then -- 刷新时间延迟5s
		_ui.unionShopTime.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown())
	else
		unionShopInfoMsg = nil
		FreshUnionShop()
	end
	
	--[[clientRefreshTime = unionShopInfoMsg.shopRefreshInfo.nextRefreshTime + 1
	local leftTimeSec = clientRefreshTime - Serclimax.GameTime.GetSecTime()
	
	if leftTimeSec > 0 then -- 刷新时间延迟5s
		local countDown = Global.GetLeftCooldownTextLong(unionShopInfoMsg.shopRefreshInfo.nextRefreshTime)
		_ui.unionShopTime.text = countDown
	else
		unionShopInfoMsg = nil
		FreshUnionShop()
	end
	]]
	
end

local function GetTypeList(n)
	local typelist;
	if n == 5 then
		typelist = {5,7,11,3,15,8,4,10,9,33,16}
	elseif n == 4 then
		typelist = {19,23}
	elseif n == 6 then
		typelist = {27}
	elseif n == 7 then
		typelist = {31}
	end
	
	return typelist
end 

function Awake()
	_ui = {}
	_ui.bagContainer = transform:Find("Container")
	_ui.boxInfoContainer = transform:Find("Box")
	_ui.pageItem = transform:Find("Container/bg_frane/page1")
	_ui.pageShop = transform:Find("Container/bg_frane/page2")
	_ui.pageUnionShop = transform:Find("Container/bg_frane/page3")
	_ui.pageArenaShop = transform:Find("Container/bg_frane/page4")
	
	
	SetClickCallback(_ui.pageItem.gameObject , function()
		_ui.btnSlagBagDisplayLv1:GetComponent("UIToggle").value = true
		--ShowSlgBag()
		ChangeBagDisplay(5)
	end)
	SetClickCallback(_ui.pageShop.gameObject , function()
		_ui.btn_tabs[1].transform:GetComponent("UIToggle").value = true
		ShowShop(1)
	end)
	SetClickCallback(_ui.pageUnionShop.gameObject , ShowUnionShop)
	
	SetClickCallback(_ui.pageArenaShop.gameObject , ShowArenaShop)
	
	SetClickCallback(_ui.bagContainer.gameObject, Hide)
	
	_ui.btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetClickCallback(_ui.btnQuit.gameObject, Hide)
	
	--slgbg
	_ui.slgBagContainer = transform:Find("Container/bg_frane/Container1")
	_ui.btnSlagBagDisplayLv1 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_5")
	SetPressCallback(_ui.btnSlagBagDisplayLv1.gameObject, ChangeDisplay)
	_ui.btnSlagBagDisplayLv2 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_4")
	SetPressCallback(_ui.btnSlagBagDisplayLv2.gameObject, ChangeDisplay)
	_ui.btnSlagBagDisplayLv3 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_6")
	SetPressCallback(_ui.btnSlagBagDisplayLv3.gameObject, ChangeDisplay)
	_ui.btnSlagBagDisplayLv4 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_7")
	SetPressCallback(_ui.btnSlagBagDisplayLv4.gameObject, ChangeDisplay)
	
	--_ui.tempBagHint = transform:Find("Container/bg_frane/bg_mid/txt_hint")
	_ui.bgScrollViewGrid = transform:Find("Container/bg_frane/Container1/Scroll View/Grid")
	_ui.ubgScrollView = transform:Find("Container/bg_frane/Container1/Scroll View"):GetComponent("UIScrollView")
	_ui.detailItem = ResourceLibrary.GetUIPrefab("Bag/SlgBagInfo")--transform:Find("SlgBagInfo")--
	_ui.detailItemInfo = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")

	_ui.boxScrollViewGrid = _ui.boxInfoContainer.transform:Find("bg_frane/Scroll View/Grid")
	_ui.boxitem = transform:Find("BoxInfo")
	_ui.boxScrollView = _ui.boxInfoContainer.transform:Find("bg_frane/Scroll View")
	_ui.bScrollViewCom = _ui.boxScrollView:GetComponent("UIScrollView")
	
	--shopbg
	_ui.shopContainer = transform:Find("Container/bg_frane/Container2")
	_ui.btnShopDisplayLv1 = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_5")
	SetPressCallback(_ui.btnShopDisplayLv1.gameObject, ChangeDisplay)
	_ui.btnShopDisplayLv2 = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_4")
	SetPressCallback(_ui.btnShopDisplayLv2.gameObject, ChangeDisplay)
	_ui.btnShopDisplayLv3 = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_6")
	SetPressCallback(_ui.btnShopDisplayLv3.gameObject, ChangeDisplay)
	_ui.btnShopDisplayLv4 = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_7")
	SetPressCallback(_ui.btnShopDisplayLv4.gameObject, ChangeDisplay)
	
	
	_ui.btn_tabs = {}
	_ui.btn_tabs[1] = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_5").gameObject
	_ui.btn_tabs[2] = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_4").gameObject
	_ui.btn_tabs[3] = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_6").gameObject
	_ui.btn_tabs[4] = transform:Find("Container/bg_frane/Container2/bg_left/btn_itemtype_7").gameObject
	for i, v in ipairs(_ui.btn_tabs) do
		SetClickCallback(v, function(go)
			ShowShop(i)
		end)
	end
	
	_ui.shopScroll_view = transform:Find("Container/bg_frane/Container2/Scroll View"):GetComponent("UIScrollView")
	_ui.shopGrid = transform:Find("Container/bg_frane/Container2/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.shopGold = transform:Find("Container/bg_frane/Container2/add/Label"):GetComponent("UILabel")
	_ui.shopAddBtn = transform:Find("Container/bg_frane/Container2/add/button"):GetComponent("UIButton")
	SetClickCallback(_ui.shopAddBtn.gameObject , function()
		--CloseAll()
		store.Show(7)
	end)
	
	_ui.unionShopScroll_view = transform:Find("Container/bg_frane/Container3/Scroll View"):GetComponent("UIScrollView")
	_ui.unionShopGrid = transform:Find("Container/bg_frane/Container3/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.unionShopTime = transform:Find("Container/bg_frane/Container3/bg titel/time"):GetComponent("UILabel")
	_ui.unionShopFreshBtn = transform:Find("Container/bg_frane/Container3/bg titel/btn refurbish"):GetComponent("UIButton")
	_ui.UnionShopGold = transform:Find("Container/bg_frane/Container3/add/Label"):GetComponent("UILabel")
	_ui.UnionFreshNum = transform:Find("Container/bg_frane/Container3/bg titel/btn refurbish/num"):GetComponent("UILabel")
	_ui.UnionShopTitle = transform:Find("Container/bg_frane/Container3/bg_top (1)/bg_title_left/title"):GetComponent("UILabel")
	_ui.UnionShopMoneyIcon = transform:Find("Container/bg_frane/Container3/add/union_coin"):GetComponent("UISprite")
	SetClickCallback(_ui.unionShopFreshBtn.gameObject, FreshUnionShop)
	if not UnionInfoData.HasUnion() then
		local tog = _ui.pageUnionShop:GetComponent("UIToggle")
		tog:Set(false)
		tog.enabled = false
	end

	_ui.UnionShopMoney = transform:Find("Container/bg_frane/Container3/add")
	if ClimbMode then
		_ui.UnionShopMoneyIcon.spriteName = "icon_climbcoin"
		_ui.UnionShopTitle.text = TextMgr:GetText("Climb_ui3")
		SetClickCallback(_ui.UnionShopMoney.gameObject,  function(go)
			if go == _ui.tipObject then
				_ui.tipObject = nil
			else
				_ui.tipObject = go
				Tooltip.ShowItemTip({name = TextMgr:GetText("item_17_name"), text = TextMgr:GetText("item_17_des")})
			end
		end)

	else
		_ui.UnionShopMoneyIcon.spriteName = "union_coin"
		_ui.UnionShopTitle.text = TextMgr:GetText("union_shop")
		SetClickCallback(_ui.UnionShopMoney.gameObject,  function(go)
			if go == _ui.tipObject then
				_ui.tipObject = nil
			else
				_ui.tipObject = go
				Tooltip.ShowItemTip({name = TextMgr:GetText("item_9_name"), text = TextMgr:GetText("item_9_des")})
			end
		end)		
	end

	
	MoneyListData.AddListener(RefresgBagInfo)
	
	
	---------ArenaShop ---------------
	_ui.arenaShopScroll_view = transform:Find("Container/bg_frane/Container4/Scroll View"):GetComponent("UIScrollView")
	_ui.arenaShopGrid = transform:Find("Container/bg_frane/Container4/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.arenaShopTime = transform:Find("Container/bg_frane/Container4/bg titel/Arena_shop/Label/time"):GetComponent("UILabel")
	_ui.arenaShopFreshBtn = transform:Find("Container/bg_frane/Container4/bg titel/Arena_shop/btn refurbish"):GetComponent("UIButton")
	_ui.ArenaShopGold = transform:Find("Container/bg_frane/Container4/add/Label"):GetComponent("UILabel")
	_ui.ArenaFreshNum = transform:Find("Container/bg_frane/Container4/bg titel/btn refurbish/num"):GetComponent("UILabel")
	_ui.ArenaShopTitle = transform:Find("Container/bg_frane/Container4/bg_top (1)/bg_title_left/title"):GetComponent("UILabel")
	_ui.ArenaShopMoneyIcon = transform:Find("Container/bg_frane/Container4/add/union_coin"):GetComponent("UISprite")
	SetClickCallback(_ui.arenaShopFreshBtn.gameObject, FreshArenaShop)
	
	_ui.ArenaShopMoney = transform:Find("Container/bg_frane/Container4/add")
	_ui.ArenaShopMoneyIcon.spriteName = "union_Arenascore"
	_ui.ArenaShopTitle.text = TextMgr:GetText("ui_Arena_title")
	SetClickCallback(_ui.ArenaShopMoney.gameObject,  function(go)
		if go == _ui.tipObject then
			_ui.tipObject = nil
		else
			_ui.tipObject = go
			Tooltip.ShowItemTip({name = TextMgr:GetText("item_21_name"), text = TextMgr:GetText("item_21_des")})
		end
	end)	
	ArenaShop.SetMoneyIcon("union_Arenascore")
	_ui.arenaShopTime.text =""
	--判断页签红点
	_ui.pageRed5 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_5/red dot")
	_ui.pageRed4 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_4/red dot")
	_ui.pageRed6 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_6/red dot")
	_ui.pageRed7 = transform:Find("Container/bg_frane/Container1/bg_left/btn_itemtype_7/red dot")
	
	local ispage4 = false
	local ispage6 = false
	local ispage7 = false
	local redData = ItemListData.GetBagRedData()

	for i,v in pairs(redData) do
		if ispage4 == false then
			for _i,_v in ipairs(GetTypeList(4)) do
				if v == _v then
					ispage4 = true
				end
			end		
		end
		if ispage6 == false then
			for _i,_v in ipairs(GetTypeList(6)) do
				if v == _v then
					ispage6 = true
				end
			end		
		end
		if ispage7 == false then
			for _i,_v in ipairs(GetTypeList(7)) do
				if v == _v then
					ispage7 = true
				end
			end		
		end

	end
	if ispage4 then 
		_ui.pageRed4.gameObject:SetActive(true)
	end
	if ispage6 then 
		_ui.pageRed6.gameObject:SetActive(true)
	end
	if ispage7 then 
		_ui.pageRed7.gameObject:SetActive(true)
	end

	ArenaShop.SetBuyShopItemCallBack(function()
		ShowArenaShop()
	end );
	-- RefreshRed(5)
end

function RefreshRed(n)
	if n == 0 then
		return
	end
	
	if _ui ~= nil then
		if n == 4 then 
			_ui.pageRed4.gameObject:SetActive(false)
		end
		if n == 6 then 
			_ui.pageRed6.gameObject:SetActive(false)
		end
		if n == 7 then 
			_ui.pageRed7.gameObject:SetActive(false)
		end
	end
	
	local redData = ItemListData.GetBagRedData()
	local newRedData = {}
	for i,v in pairs(redData) do
		local isContains = false
		for _i,_v in ipairs(GetTypeList(n)) do
			if v == _v then
				isContains = true
			end
		end
		if isContains == false then
			newRedData[i] = v
		end
	end
	ItemListData.SetBagRedData(newRedData)
	MainCityUI.BagNotice()
end

function Start()
	bagDefaultDisplay = 0
	ChangeBagDisplay(5)
end

function ResetBagDisplay()
	local childCount = _ui.bgScrollViewGrid.childCount
	while _ui.bgScrollViewGrid.childCount > 0 do
		GameObject.DestroyImmediate(_ui.bgScrollViewGrid:GetChild(0).gameObject);
	end

end

function ResetBoxShowDisplay()
	local childCount = _ui.boxScrollViewGrid.childCount
	while _ui.boxScrollViewGrid.childCount > 0 do
		GameObject.DestroyImmediate(_ui.boxScrollViewGrid:GetChild(0).gameObject);
	end
end

function ShowBoxInfo(itemBaseid)
	_ui.bagContainer.gameObject:SetActive(false)
	_ui.boxInfoContainer.gameObject:SetActive(true)
	local itemTBData = TableMgr:GetItemData(itemBaseid)
	
	
	
	local btnClose = _ui.boxInfoContainer.transform:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(btnClose.gameObject , BoxCloseClickCallback)
	SetClickCallback(_ui.boxInfoContainer.gameObject , BoxCloseClickCallback)
	
	local box = _ui.boxInfoContainer.transform:Find("bg_frane/bg_box"):GetComponent("UISprite")
	box.spriteName = "bg_item" .. itemTBData.quality
	--icon
	local icon = _ui.boxInfoContainer.transform:Find("bg_frane/bg_box/Texture"):GetComponent("UITexture")
	icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
	--number
	--local num = _ui.boxInfoContainer.transform:Find("bg_frane/bg_box/num"):GetComponent("UILabel")
	--num.text = item.number
	
	local hint = _ui.boxInfoContainer.transform:Find("bg_frane/bg_mid/txt_hint"):GetComponent("UILabel")
	if itemTBData.subtype == 1 then
		hint.text = TextMgr:GetText("chest_ui01")
	else
		hint.text = TextMgr:GetText("chest_ui02")
	end
	
	local showList = TableMgr:GetDropShowData(itemTBData.param2)
	if #showList > 0 then
		for i , v in pairs(showList) do
			--print("=====" .. showList[i].contentId)
			local boxitem = NGUITools.AddChild(_ui.boxScrollViewGrid.gameObject , _ui.boxitem.gameObject)
			boxitem.gameObject:SetActive(true)
			boxitem.transform:SetParent(_ui.boxScrollViewGrid , false)
			
			if i%2 == 0 then
				local itembg =  boxitem.transform:Find("bg_list/background")
				itembg.gameObject:SetActive(false)
			end
			
			local itemTBData = TableMgr:GetItemData(showList[i].contentId)
			--icon
			local icon = boxitem.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
			icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
			--number
			local num = boxitem.transform:Find("bg_list/bg_icon/num"):GetComponent("UILabel")
			num.text = showList[i].contentNumber
			--quality
			local quabox = boxitem.transform:Find("bg_list/bg_icon"):GetComponent("UISprite")
			quabox.spriteName = "bg_item" .. itemTBData.quality
			
			--description
			local des = boxitem.transform:Find("bg_list/text_des"):GetComponent("UILabel")
			des.text = TextUtil.GetItemDescription(itemTBData)
			
			local name = boxitem.transform:Find("bg_list/text_name"):GetComponent("UILabel")
			local textColor = Global.GetLabelColorNew(itemTBData.quality)
			name.text = textColor[0] .. TextUtil.GetItemName(itemTBData) .. textColor[1]
				
		end
	end
	--[[for i = 0, showList.Length - 1 do
		--print("=====" .. showList[i].contentId)
		local boxitem = NGUITools.AddChild(_ui.boxScrollViewGrid.gameObject , _ui.boxitem.gameObject)
		boxitem.gameObject:SetActive(true)
		boxitem.transform:SetParent(_ui.boxScrollViewGrid , false)
		
		if i%2 == 0 then
			local itembg =  boxitem.transform:Find("bg_list/background")
			itembg.gameObject:SetActive(false)
		end
		
		local itemTBData = TableMgr:GetItemData(showList[i].contentId)
		--icon
		local icon = boxitem.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
		icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
		--number
		local num = boxitem.transform:Find("bg_list/bg_icon/num"):GetComponent("UILabel")
		num.text = showList[i].contentNumber
		--quality
		local quabox = boxitem.transform:Find("bg_list/bg_icon"):GetComponent("UISprite")
		quabox.spriteName = "bg_item" .. itemTBData.quality
		
		--description
		local des = boxitem.transform:Find("bg_list/text_des"):GetComponent("UILabel")
		des.text = TextUtil.GetItemDescription(itemTBData)
		
		local name = boxitem.transform:Find("bg_list/text_name"):GetComponent("UILabel")
		local textColor = Global.GetLabelColorNew(itemTBData.quality)
		name.text = textColor[0] .. TextUtil.GetItemName(itemTBData) .. textColor[1]
	end]]
	
	local grid = _ui.boxScrollViewGrid:GetComponent("UIGrid")
	grid:Reposition()
	_ui.bScrollViewCom:ResetPosition()

end

--local itemParam = {baseid = v.item.baseid , uid = v.item.uniqueid , count = v.item.number }
local function LoadSlgBagItem(slgbagItemParam)
	local itemData = TableMgr:GetItemData(slgbagItemParam.baseid)
	local itemObject = NGUITools.AddChild(_ui.bgScrollViewGrid.gameObject , _ui.detailItem.gameObject)
	itemObject.gameObject:SetActive(true)
	itemObject.gameObject.name = itemObject.gameObject.name .. "_".. slgbagItemParam.uid
	itemObject.transform:SetParent(_ui.bgScrollViewGrid , false)
	
	local itemTransform = itemObject.transform:Find("bg_list/Item_CommonNew")
	local itemRed = itemObject.transform:Find("bg_list/Item_CommonNew/new")
	if ItemListData.GetBagRedData()[slgbagItemParam.baseid] ~= nil then
		itemRed.gameObject:SetActive(true)
	end
	local item = {}
	UIUtil.LoadItemObject(item, itemTransform)
	UIUtil.LoadItem(item, itemData, nil)
	local show = false
	if itemData.type == 3 then 
		if itemData.subtype ==1 or itemData.subtype ==2 then 
			show = true
		end 
	end 
	item.viewObject:SetActive(show)
	SetClickCallback(item.viewObject, function()
		print(slgbagItemParam.baseid)
		ShowBoxInfo(slgbagItemParam.baseid)
    end)
	
	--name
	local name = itemObject.transform:Find("bg_list/text_name"):GetComponent("UILabel")
	local textColor = Global.GetLabelColorNew(itemData.quality)
	name.text = textColor[0] .. TextUtil.GetItemName(itemData) .. "[-]"

	--des
	local des = itemObject.transform:Find("bg_list/text_name/text_des"):GetComponent("UILabel")
	des.text = TextUtil.GetItemDescription(itemData)
	
	
	--number
	local num = itemObject.transform:Find("bg_list/txt_num/num"):GetComponent("UILabel")
	local showNum = math.min(slgbagItemParam.count , itemData.itemsize)
	if slgbagItemParam.count > itemData.itemsize then
		num.text = "[ff0000]" .. showNum .. "[-]"
	else 
		num.text = showNum
	end

	--use btn
	local usebtnObj = itemObject.transform:Find("bg_list/btn_use")
	local useMutibtnObj = itemObject.transform:Find("bg_list/btn_use_continue")
	if itemData.canUse == 0 then
		usebtnObj.gameObject:SetActive(false)
		useMutibtnObj.gameObject:SetActive(false)
	elseif itemData.canUse == 1 then
		useMutibtnObj.gameObject:SetActive(false)
		
		local usebtn = usebtnObj:GetComponent("UIButton")
		SetPressCallback(usebtn.gameObject, ItemUse)
		usebtnObj.gameObject.name = usebtnObj.gameObject.name .. "_" .. slgbagItemParam.uid
	elseif itemData.canUse == 2 then
		local usebtn = usebtnObj:GetComponent("UIButton")
		SetPressCallback(usebtn.gameObject, ItemUse)
		usebtnObj.gameObject.name = usebtnObj.gameObject.name .. "_" .. slgbagItemParam.uid
		
		if showNum > 1 then
			local usebtnmu = useMutibtnObj:GetComponent("UIButton")
			SetPressCallback(useMutibtnObj.gameObject, ItemUseMuti)
			useMutibtnObj.gameObject.name = useMutibtnObj.gameObject.name .. "_" .. slgbagItemParam.uid
		else
			useMutibtnObj.gameObject:SetActive(false)
		end
	end
	local need_level =0
	local gifts = TableMgr:GetItemDataByType(3 , 4)
	for i , v in pairs(gifts) do
		if slgbagItemParam.baseid==gifts[i].id then 
			need_level = tonumber(gifts[i].param3)
			item.viewObject:SetActive(false)
			SetClickCallback(itemTransform.gameObject, function()
			   -- GrowRewards.Show(missionMsg, missionData)
			   GrowRewards.ShowGradeUp(gifts[i].param1,gifts[i].param3)
			end)
			break;
		end 
	end


	if need_level >0 and  need_level<=maincity.GetBuildingByID(1).data.level then 
		local usebtn = usebtnObj:GetComponent("UIButton")
		usebtn.normalSprite = "btn_1"
	elseif need_level >0 and need_level>maincity.GetBuildingByID(1).data.level then 
		local usebtn = usebtnObj:GetComponent("UIButton")
		usebtn.normalSprite = "btn_4"
		SetPressCallback(usebtn.gameObject, function(go, isPressed)
			if not isPressed then
				FloatText.Show(System.String.Format(TextMgr:GetText(Text.growreward_claim), need_level) , Color.red)
			end 
		end)
	end 

end

function UpdateBagItem(items)
	local needRepos = false
	if _ui == nil then
		return
	end
	for _,v in ipairs(items) do
		local optype = v.optype
		local uid = v.data.uniqueid 
		local itemObj = nil
		local itemObjName = _ui.detailItem.gameObject.name .. "(Clone)_" .. uid
		itemObj = _ui.bgScrollViewGrid.transform:Find(itemObjName)
		
		if optype == Common_pb.FreshDataType_Fresh then 
			local item = ItemListData.GetItemDataByUid(uid)
			local itemTBData = TableMgr:GetItemData(item.baseid)
			if itemObj ~= nil and item ~= nil then
				--number
				local num = itemObj.transform:Find("bg_list/txt_num/num"):GetComponent("UILabel")
				local usebtnObj = itemObj.transform:Find("bg_list/btn_use_" .. uid)
				local useMutibtnObj = itemObj.transform:Find("bg_list/btn_use_continue_" .. uid)
			
				local showNum = math.min(item.number , itemTBData.itemsize)
				if item.number > 1 then
					if item.number > itemTBData.itemsize then
						num.text = "[ff0000]" .. showNum .. "[-]"
					else 
						num.text = showNum
					end
					
					if usebtnObj ~= nil then
						usebtnObj.gameObject:SetActive(true)
					end
					if useMutibtnObj ~= nil then
						useMutibtnObj.gameObject:SetActive(true)
					end
				elseif item.number == 1 then
					num.text = showNum
					--itemObj.transform:Find("bg_list/txt_num/num").gameObject:SetActive(false)

					if usebtnObj ~= nil then
						usebtnObj.gameObject:SetActive(true)
					end
					if useMutibtnObj ~= nil then
						useMutibtnObj.gameObject:SetActive(false)
					end
					
				end
			end
		elseif optype == Common_pb.FreshDataType_Add then
			local itemParam = {baseid = v.data.baseid , uid = v.data.uniqueid , count = v.data.number }
			local itemTBData = TableMgr:GetItemData(itemParam.baseid)
			local typelist = GetTypeList(bagDefaultDisplay)
			
			for _, k in pairs(typelist) do
				--print("typrList : " .. k .. "itemType : " .. itemTBData.type)
				if itemTBData.type == k then
					--table.insert(disItems , v)
					LoadSlgBagItem(itemParam)
					needRepos = true
				end
			end
			
		elseif optype == Common_pb.FreshDataType_Delete then
			if itemObj ~= nil then
				GameObject.Destroy(itemObj.gameObject)
			end
			local coroutine = coroutine.start(function()
				coroutine.step()
				if _ui ~= nil then
					local uiInfoGrid = _ui.bgScrollViewGrid:GetComponent("UIGrid")
					uiInfoGrid:Reposition()
					_ui.ubgScrollView:InvalidateBounds()
					_ui.ubgScrollView:RestrictWithinBounds(true)
				end
				--[[
				if _ui.bgScrollViewGrid.childCount <= 4 then 
					_ui.ubgScrollView.enabled = false
				else
					_ui.ubgScrollView.enabled = true
				end
				]]
			end)
		end
	end
	
	if needRepos then
		local uiInfoGrid = _ui.bgScrollViewGrid:GetComponent("UIGrid")
		uiInfoGrid:Reposition()
	end
end

function ChangeBagDisplay(n)

	if bagDefaultDisplay == n then
		return
	end
	--刷新页签红点
	RefreshRed(bagDefaultDisplay)
	ResetBagDisplay()
	bagDefaultDisplay = n
	local disItems = {}
	local itemList = ItemListData.GetItemListSort()
	for _, v in pairs(itemList) do
		if v ~= nil then
			local itemTbid = tonumber(v.item.baseid)
			local itemTBData = TableMgr:GetItemData(itemTbid)
			local typelist = GetTypeList(bagDefaultDisplay)
			
			for _, k in pairs(typelist) do
				--print("typrList : " .. k .. "itemType : " .. itemTBData.type)
				if itemTBData.type == k then
					v.isNew = 0
					if ItemListData.GetBagRedData()[v.item.baseid] ~= nil then
						v.isNew = 1
					end
					table.insert(disItems , v)
				end
			end
		end
	end

	table.sort(disItems, function(a,b) return tonumber(a.isNew) > tonumber(b.isNew) end)
	
	--display
	local noitemHint = transform:Find("Container/bg_frane/Container1/bg_mid/bg_noitem")
	if #disItems == 0 then
		noitemHint.gameObject:SetActive(true)
	else
		noitemHint.gameObject:SetActive(false)
	end
	
	for _, v in pairs(disItems) do
		--print("+++++++++:" .. tonumber(v.quality))
		local itemParam = {baseid = v.item.baseid , uid = v.item.uniqueid , count = v.item.number }
		LoadSlgBagItem(itemParam)
		
	end
	

	local uiInfoGrid = _ui.bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	_ui.ubgScrollView:ResetPosition()
	if _ui.bgScrollViewGrid.childCount <= 4 then 
		_ui.ubgScrollView.enabled = false
	else
		_ui.ubgScrollView.enabled = true
	end
	
	--if ItemListData.GetExpireTime() > 0 then
	--	_ui.tempBagHint.gameObject:SetActive(true)
	--else
	--	_ui.tempBagHint.gameObject:SetActive(false)
	--end
	
end

RefrushClimbShop =  function()	
	local param = {}
	param.scroll_view = _ui.unionShopScroll_view
	param.grid = _ui.unionShopGrid
	param.item = _ui.detailItem
	
	ClimbData.RefreshClimbShop(param,function(msg)
		unionShopInfoMsg = msg
		RefresgBagInfo()
	end)
end

function LoadClimbShop()
	local param = {}
	param.scroll_view = _ui.unionShopScroll_view
	param.grid = _ui.unionShopGrid
	param.item = _ui.detailItem
	
	ClimbData.RequestClimbShopData(param,function(msg)
		unionShopInfoMsg = msg
		RefresgBagInfo()
		UnionShop.SetMoneyIcon("icon_climbcoin")
		UnionShop.SetBuyShopItemClickCallBack(function(go , itemmsg , status)
			if status == false then
				FloatText.Show(TextMgr:GetText("Union_Shop_ui6"), Color.white)
				return
			end
		
			local itemParm = {}
			itemParm.baseId = itemmsg.baseId
			itemParm.number = itemmsg.maxBuyNum - itemmsg.currentBuyNum
			itemParm.price = itemmsg.price
			UseItem.InitItemByParams(itemParm)
			UseItem.SetUseCallBack(function(buyNumber)
				local cost = buyNumber * itemmsg.price
				local myGuildCoin = MoneyListData.GetMoneyByType(Common_pb.MoneyType_ClimbCoin)
				if cost > myGuildCoin then
					MessageBox.Show(TextMgr:GetText("Climb_ui21") , function() end)
					return
				end
			
				local req = BattleMsg_pb.MsgClimbShopBuyRequest()
				req.num = buyNumber
				req.exchangeId = itemmsg.exchangeId
				Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgClimbShopBuyRequest, req, BattleMsg_pb.MsgClimbShopBuyResponse, function(msg)
					if msg.code ~= ReturnCode_pb.Code_OK then
						Global.ShowError(msg.code)
					else
						FloatText.Show(TextMgr:GetText("login_ui_pay1") , Color.green)
						MainCityUI.UpdateRewardData(msg.fresh)
						SlgBag.UpdateBagItem(msg.fresh.item.items)
						--LoadShopItem(_ui.shopItems[msg.itemInfo.baseId] , msg.itemInfo)
						UnionShop.LoadShopItemBag(go.transform.parent.transform.parent.gameObject.transform , msg.itemInfo)
					end
				end)
			end)
			GUIMgr:CreateMenu("UseItem" , false)
			
		end)
		SetClickCallback(_ui.Climb_shop_freshBtn.gameObject,function()
			MessageBox.Show(System.String.Format(TextMgr:GetText("Climb_ui33"), unionShopInfoMsg.shopInfo.refreshCost), 
			function() 
				RefrushClimbShop()
			end,
			 function() end)
		end)
	end)
	
end

function ShowClimb()
	ClimbMode = true
	Global.OpenUI(_M)
	_ui.pageUnionShop:GetComponent("UIToggle").value = true
	_ui.pageItem.gameObject:SetActive(false)
	_ui.pageShop.gameObject:SetActive(false)
	_ui.pageUnionShop.gameObject:SetActive(false)
	_ui.pageArenaShop.gameObject:SetActive(false)
	
	_ui.Climb_shop_root= transform:Find("Container/bg_frane/Container3/bg titel/climb_shop")
	_ui.Climb_shop_freshBtn = transform:Find("Container/bg_frane/Container3/bg titel/climb_shop/btn refurbish")
	_ui.Climb_shop_freshTime = transform:Find("Container/bg_frane/Container3/bg titel/climb_shop/Label/time"):GetComponent("UILabel")
	_ui.Climb_shop_root.gameObject:SetActive(true)
	transform:Find("Container/bg_frane/Container4").gameObject:SetActive(false)
	transform:Find("Container/bg_frane/Container3").gameObject:SetActive(true)
	transform:Find("Container/bg_frane/Container3/bg titel/time").gameObject:SetActive(false)
	transform:Find("Container/bg_frane/Container3/bg titel/Label").gameObject:SetActive(false)


	LoadClimbShop()	
    AddDelegate(UICamera, "onClick", OnUICameraClick)
	AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)		
end

function Show(showPage)
	ClimbMode = false
	if showPage == 1 then
		Global.OpenUI(_M)

		_ui.pageItem:GetComponent("UIToggle").value = true
		
		bagDefaultDisplay = 0

		ChangeBagDisplay(5)
	elseif showPage == 2 then
		-- local tog = _ui.pageShop:GetComponent("UIToggle")
		-- tog.value =true
		ShowShop(1)
	elseif showPage == 3 then
		Global.OpenUI(_M)
		_ui.pageUnionShop:GetComponent("UIToggle").value = true
		ShowUnionShop()
	elseif showPage == 4 then
		Global.OpenUI(_M)
		_ui.pageArenaShop:GetComponent("UIToggle").value = true
		ShowArenaShop()
	end
    AddDelegate(UICamera, "onClick", OnUICameraClick)
	AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)		
end

function Hide()
	if not GUIMgr.Instance:IsMenuOpen("UnionInfo") then
	end
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Close()
	if ClimbMode then
		UnionShop.SetMoneyIcon(nil)
		UnionShop.SetBuyShopItemClickCallBack(nil)	
	end
	ClimbMode = false
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)	
	coroutine.stop(_ui.arenacountdowncoroutine)
	--刷新页签红点
	RefreshRed(bagDefaultDisplay)
	_ui = nil
	Shop.Close()
	unionShopInfoMsg = nil
	MoneyListData.RemoveListener(RefresgBagInfo)

end

