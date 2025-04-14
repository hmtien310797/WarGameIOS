module("CommonItemBag",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local String = System.String
local Format = System.String.Format
local GameTime = Serclimax.GameTime

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local BuildMsg_pb = require("BuildMsg_pb")

local btnQuit
local buildid
local buildlevel

local build
local buildingData
local UseItemId = 0
local ExItemId = 0

local itemlist
local itemInfoList
local UseItemFunction
local InitFunction
local _pathRoot = "ResView"
local _pathRootClose = "Accelerate"

local bagTittle = "speedup"
local useClose = true
local itemMax = false

local leftTime
local actualTime -- leftTime - freeTime

local needReposition
local freefinish = true
local itemType

local resType
local resName
local resourceNeeded
local resourceStored
local resourceShortage
local messageText, timestring
local showLimitCount = false

local entryFlag = -1

OnCloseCB = nil

OnOpenCB = nil

local btnClickWait = false

local _ui
local timer = 0

function GetResourceNeeded()
	return resourceNeeded
end

--设置点击后按钮的等待，不能和useClose = true(自用后自动关闭)公用。需要在使用回调函数中自行设置按钮的状态
function SetBtnClickWait(wait)
	btnClickWait = wait
end

function SetTittle(title)
	bagTittle = title
end

--_type 0、资源
--		1、建筑、科研加速道具 (有免费时间)
--		2、行军队列加速道具 （不能连续使用）
--		3、普通道具
--		4、训练、伤兵、锻造治疗、行动加速道具（无免费时间）
--		5、不能使用只能购买的道具
--		6、行动力
function SetItemList(list, _type) 
	itemlist = list
	itemInfoList = {}
	
	itemType = _type
	if _type == 0 or _type == 3 or _type == 5 or _type == 6 then
		_pathRoot = "ResView"
		_pathRootClose = "Accelerate"
	elseif _type == 1 or _type == 2 or _type == 4 then
		_pathRoot = "Accelerate"
		_pathRootClose = "ResView"
	end
end

function SetResType(id)
	resType = tonumber(id)
end

function SetEntryFlag(id)
	entryFlag = id
end

function SetUseFunc(func)
	UseItemFunction = func
end

function NotUseFreeFinish() --禁用免费完成
	freefinish = false
end

function NotUseAutoClose() --禁用使用道具自动关闭
	useClose = false
end

function NeedItemMaxValue(ismax) --开启道具最大值限制
	if ismax == nil and ismax ~= false then
		itemMax = true
	else
		itemMax = ismax
	end
end

function SetInitFunc(func) --需要返回 _text（名字+LV等级）, _time（结束时间donetime）, _totalTime（总时间类似workercdtime）, _finishFuc（立即完成回调方法）, _cancelFuc（取消建造/研究/造兵回调方法）, _goldFuc（金币立即完成的方法）, _goldtype（金币加速的类型 1建造 2科技 3造兵）, _helpFunc(联盟帮助回调方法), _createtime(开始建造时间)
	InitFunction = func
end

function SetMsgText(_text, _timestring)
	messageText = _text
	timestring = _timestring
end

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("CommonItemBag")
	end
end

local function BuyPressCallback(go, isPressed)
	if not isPressed then
		print("buybuybuy")
	end
end

local function UseMultiPressCallback(UseItemId , ExItemId, btn)
	local itemdata = ItemListData.GetItemDataByBaseId(UseItemId)
	if itemdata ~= nil then
		local itemTable = TableMgr:GetItemData(UseItemId)
		if itemMax then
			if actualTime == 0 then
				FloatText.ShowOn(btn, TextMgr:GetText("CommonItemBag_ui12"), Color.white)
				return
			end
			UseItem.SetLeftTime(leftTime)
			UseItem.SetActualTime(actualTime)
			UseItem.SetMaxNum(Mathf.Ceil(actualTime / tonumber(itemTable.param1)))
			UseItem.SetDefaultUseNum(Mathf.Ceil(actualTime / tonumber(itemTable.param1)))
		else
			if resourceShortage ~= nil and resourceShortage > 0 then
				UseItem.SetDefaultUseNum(math.ceil(resourceShortage / tonumber(itemTable.param1)))
			end
		end
		UseItem.SetResourceInfo(resourceNeeded)
		UseItem.InitItem(tonumber(itemdata.uniqueid))
		print("mutiuse item id: " .. UseItemId .. "uid:" .. itemdata.uniqueid)
		UseItem.SetUseCallBack(function(useNum)
			MultiuseCallBack(UseItemId , ExItemId ,useNum)
		end)
		GUIMgr:CreateMenu("UseItem" , false)
	end
end

local function UsePressCallback(UseItemId , ExItemId, btn)
	if btnClickWait then
		if go.transform:GetComponent("UIButton").enabled then
			go.transform:GetComponent("UIButton").enabled = false
			UseItemFunc(UseItemId , ExItemId , 1 , go)
		end
	else
		local itemTable  = TableMgr:GetItemData(UseItemId)
		if leftTime ~= nil and itemTable.showType ~= 3 then
			if actualTime == 0 then
				FloatText.ShowOn(btn, TextMgr:GetText("CommonItemBag_ui12"), Color.white)
			elseif leftTime < tonumber(itemTable.param1) * 0.9 then
				MessageBox.Show(TextMgr:GetText("common_ui21"), function() UseItemFunc(UseItemId , ExItemId , 1 , nil) end, function() end)
			else
				UseItemFunc(UseItemId , ExItemId , 1 , nil)
			end
		else
			UseItemFunc(UseItemId , ExItemId , 1 , nil)
		end
	end
end

function MultiuseCallBack(UseItemId , ExItemId , useNum)
	UseItemFunc(UseItemId , ExItemId , useNum , nil)
end

function UseItemFunc(useItemId , exItemid , count , go)
	showLimitCount = false
	if UseItemFunction ~= nil then
		UseItemFunction(useItemId , exItemid , count , go)
		--UpdateItem()
		if useClose then
			GUIMgr:CloseMenu("CommonItemBag")
		end
	end
end

function SetLimitCount(v)
	showLimitCount = v
end

local function CaculateAutoList()
	itemInfoList = {}
	for i ,v in pairs(itemlist) do
		local item = {}
		item.ori = v
		item.itemid = v.itemid
		item.itemExId = v.exid
		item.itemData = TableMgr:GetItemData(item.itemid)
		if GUIMgr:IsMenuOpen("MobaMain") then
			item.itemBagData =	MobaPackageItemData.GetItemDataByUid(item.itemid)
			
			item.itemExchangeData = {
				id = 1,
				item = v.itemid,
				number = 1,
				moneyType = 2,
				price = 100,
				MaxBuyTime = 0,
			}
			
			
			local itemData = MobaItemData.GetItemDataByBaseId(item.itemid)
			if  itemData~= nil then 
				item.id = itemData.exchangeId
				item.itemExchangeData.price = itemData.needScore
			end 
		elseif GUIMgr:IsMenuOpen("GuildWarMain") then
			item.itemBagData =	MobaPackageItemData.GetItemDataByUid(item.itemid)
			
			item.itemExchangeData = {
				id = 1,
				item = v.itemid,
				number = 1,
				moneyType = 2,
				price = 100,
				MaxBuyTime = 0,
			}

			local itemData = TableMgr:GetGuildWarShopDataByID(item.itemid)
			if  itemData~= nil then 
				item.itemExchangeData.price = tonumber(itemData.NeedGold)
			else
				item.itemBagData = ItemListData.GetItemDataByBaseId(item.itemid)
				item.itemExchangeData = TableMgr:GetItemExchangeData(item.itemExId)
			end 
		else
			item.itemBagData = ItemListData.GetItemDataByBaseId(item.itemid)
			item.itemExchangeData = TableMgr:GetItemExchangeData(item.itemExId)
		end 
		
		table.insert(itemInfoList, item)
	end
	if itemType == 1 or itemType == 4 then
		if actualTime == nil then
			return itemInfoList, 0, 0
		end
		table.sort(itemInfoList, function(a, b)
			if a.itemData.param1 <= actualTime and b.itemData.param1 <= actualTime then
				if a.itemData.param1 == b.itemData.param1 then
					return a.itemData.subtype > b.itemData.subtype
				else
					return a.itemData.param1 > b.itemData.param1
				end
			elseif a.itemData.param1 > actualTime and b.itemData.param1 > actualTime then
				if a.itemData.param1 == b.itemData.param1 then
					return a.itemData.subtype > b.itemData.subtype
				else
					return a.itemData.param1 < b.itemData.param1
				end
			else
				if a.itemData.param1 == b.itemData.param1 then
					return a.itemData.subtype > b.itemData.subtype
				else
					return a.itemData.param1 < b.itemData.param1
				end
			end
		end)
		local temptime = actualTime
		local autolist = {}
		local totalnum = 0
		local totaltime = 0
		local nearestbuy = true
		for i, v in ipairs(itemInfoList) do
			if temptime > 0 then
				if v.itemBagData ~= nil then
					if v.itemData.param1 <= 60 then
						temptime = temptime + 20
					end
					v.needuse = math.min(math.floor(temptime / v.itemData.param1), v.itemBagData.number)
					temptime = temptime - (v.needuse * v.itemData.param1)
					totaltime = totaltime + (v.needuse * v.itemData.param1)
					totalnum = totalnum + v.needuse
					if v.itemData.param1 > actualTime then
						temptime = 0
					end
					table.insert(autolist, v)
				else
					if nearestbuy then
						table.insert(autolist, v)
					end
					if v.itemExId > 0 and v.itemData.param1 > actualTime then
						nearestbuy = false
					end
				end
			end
		end
		table.sort(autolist, function(a, b)
			if (a.itemBagData ~= nil and b.itemBagData ~= nil) or (a.itemBagData == nil and b.itemBagData == nil) then
				if a.itemData.param1 == b.itemData.param1 then
					--[[if a.itemData.id < 27200 and b.itemData.id >= 27200 then
						return false
					elseif a.itemData.id >= 27200 and b.itemData.id < 27200 then
						return true
					else
						return a.itemData.id < b.itemData.id
					end]]
					return a.itemData.subtype > b.itemData.subtype
				else
					return a.itemData.param1 < b.itemData.param1
				end
			else
				if a.itemBagData ~= nil and b.itemBagData == nil then
					return true
				elseif a.itemBagData == nil and b.itemBagData ~= nil then
					return false
				end
			end
		end)
		return autolist, totalnum, totaltime
	else
		return itemInfoList, 0, 0
	end
end

function UpdateAutoSpeedup()
	local childCount = _ui.itemGrid.childCount
	if childCount > 0 then
		_ui.auto_speedup = _ui.itemGrid:GetChild(0)
	else
		_ui.auto_speedup = NGUITools.AddChild(_ui.itemGrid.gameObject , _ui.auto_speedup_prefab.gameObject)
		_ui.auto_speedup.transform:SetParent(_ui.itemGrid , false)
		_ui.auto_speedup:SetActive(false)
		SetClickCallback(_ui.auto_speedup.transform:Find("bg_list/btn_use").gameObject, function()
			_ui.auto_speedup_use = NGUITools.AddChild(transform.gameObject , _ui.auto_speedup_use_prefab.gameObject)
			NGUITools.BringForward(_ui.auto_speedup_use)
			SetClickCallback(_ui.auto_speedup_use.transform:Find("Container/bg_frane/btn_close").gameObject, function() GameObject.Destroy(_ui.auto_speedup_use) end)
			_ui.auto_speedup_use.transform:Find("Container/bg_frane/bg_top/name"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("CommonItemBag_ui14"), Serclimax.GameTime.SecondToString3(_ui.temptotaltime))
			local grid = _ui.auto_speedup_use.transform:Find("Container/bg_frane/bg/Scroll View/Grid"):GetComponent("UIGrid")
			local itemprefab = _ui.auto_speedup_use.transform:Find("Container/bg_frane/Item_CommonNew").gameObject
			for i, v in ipairs(_ui.templist) do
				if v.needuse ~= nil and v.needuse > 0 then
					local itemobj = NGUITools.AddChild(grid.gameObject , itemprefab)
					local item = {}
					UIUtil.LoadItemObject(item, itemobj.transform)
					item.nameLabel = itemobj.transform:Find("name"):GetComponent("UILabel")
					UIUtil.LoadItem(item, v.itemData, v.needuse)
				end
			end
			SetClickCallback(_ui.auto_speedup_use.transform:Find("Container/bg_frane/btn_ok").gameObject, function()
				for i, v in ipairs(_ui.templist) do
					if v.needuse ~= nil and v.needuse > 0 then
						UseItemFunc(v.ori.itemid , v.ori.exid , v.needuse , nil)
					end
				end
				GameObject.Destroy(_ui.auto_speedup_use)
			end)
		end)
	end
	_ui.templist, _ui.totalnum, _ui.temptotaltime = CaculateAutoList()
	_ui.auto_speedup.gameObject:SetActive(_ui.totalnum > 1)
	_ui.auto_speedup.transform:Find("bg_list/text_name"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("CommonItemBag_ui14"), Serclimax.GameTime.SecondToString3(_ui.temptotaltime))
	
	if #_ui.templist ~= _ui.lastlistlength then
		_ui.lastlistlength = #_ui.templist
		UpdateItemList()
	end
end

function UpdateItemList ()
	local scrollView = transform:Find(String.Format("{0}/bg_frane/Scroll View", _pathRoot)):GetComponent("UIScrollView")
	local itemContent = transform:Find(String.Format("{0}info", _pathRoot))

	local childCount = _ui.itemGrid.childCount
	local noitemhint = transform:Find(String.Format("{0}/bg_frane/bg_mid/bg_noitem", _pathRoot))
	local noitem = Global.BagIsNoItem(itemlist)
	if noitem then
		noitemhint.gameObject:SetActive(true)
	else
		noitemhint.gameObject:SetActive(false)
	end
	
	local childIndex = 1
	for i ,v in pairs(_ui.templist) do
		
		local itemid = v.itemid
		local itemExId = v.itemExId
		local itemData = v.itemData
		local itemBagData = v.itemBagData
		local itemExchangeData = v.itemExchangeData
		
		if itemExId > 0 or itemBagData ~= nil then
		--print(_ui.itemGrid.childCount , i , v.itemid)
			local itemTransform
			if childIndex < childCount then
				itemTransform = _ui.itemGrid:GetChild(childIndex)
			else
				itemTransform = NGUITools.AddChild(_ui.itemGrid.gameObject , _ui.detailItem.gameObject)
				itemTransform.transform:SetParent(_ui.itemGrid , false)
			end
			
			if not itemTransform.gameObject.activeSelf then
				itemTransform.gameObject:SetActive(true)
			end
			itemTransform.gameObject.name = itemid .. "_" .. itemExId
			local itemBox = itemTransform.transform:Find("bg_list/Item_CommonNew")
			local item = {}
			UIUtil.LoadItemObject(item, itemBox)
			UIUtil.LoadItem(item, itemData)
			
			--name
			local name = itemTransform.transform:Find("bg_list/text_name"):GetComponent("UILabel")
			local textColor
			if itemBagData ~= nil then
				textColor = Global.GetLabelColorNew(itemData.quality)
			elseif itemExchangeData ~= nil then
				local exTBdata = TableMgr:GetItemData(itemExchangeData.item)
				textColor = Global.GetLabelColorNew(exTBdata.quality)
			end
			local numstr = ""
			local buyEnable = true
			if itemExchangeData ~= nil then
				numstr = (itemExchangeData.number > 1 and (" x" .. itemExchangeData.number) or "")
				if showLimitCount and tonumber(itemExchangeData.MaxBuyTime) >0 then 
					local limitcount = itemTransform.transform:Find("bg_list/text_available"):GetComponent("UILabel")
					local num =0
					local items = ShopItemData.GetShopItems()
				
					if items[1] ~= nil then 
						
						local itemlist = items[1]
						for m =1 ,#itemlist do
							--print("_______________fff "..itemlist[m].baseId.."  "..itemExId.." "..itemid)
							if tonumber(itemlist[m].baseId) == tonumber(itemid) then 
								num = itemlist[m].currentBuyNum
								-- print("_______________fff "..num)
							end
						end
					end 
					
					if items[2] ~= nil then 
						
						local itemlist = items[2]
						for m =1 ,#itemlist do
							--print("_______________fff2 "..itemlist[m].baseId.."  "..itemExId.." "..itemid)
							if tonumber(itemlist[m].baseId) == tonumber(itemid) then 
								num = itemlist[m].currentBuyNum
								-- print("_______________fff2 "..num)
							end
						end
					end 
					
					limitcount.text = System.String.Format(TextMgr:GetText("pay_ui14") ,num ,itemExchangeData.MaxBuyTime)
					limitcount.gameObject:SetActive(true)

					if tonumber(num) >= tonumber(itemExchangeData.MaxBuyTime) then
						buyEnable = false
					end
				end
			end
			if itemExchangeData ~= nil then
			name.text = textColor[0] .. TextUtil.GetItemName(itemData) .. "[-]" .. numstr
			else
			name.text = TextUtil.GetItemName(itemData) .. numstr
			end
			--des
			local des = itemTransform.transform:Find("bg_list/text_name/text_des"):GetComponent("UILabel")
			des.text = TextUtil.GetItemDescription(itemData)
			
			--use button
			local useBtn = itemTransform.transform:Find("bg_list/btn_use")
			SetClickCallback(useBtn.gameObject, function()
				UsePressCallback(v.ori.itemid , v.ori.exid, useBtn.gameObject)
			end)
			local mutiUseBtn = itemTransform.transform:Find("bg_list/btn_use_continue")
			SetClickCallback(mutiUseBtn.gameObject, function()
				UseMultiPressCallback(v.ori.itemid , v.ori.exid, mutiUseBtn.gameObject)
			end)
			--buy button
			
			local buyBtn  = itemTransform.transform:Find("bg_list/btn_use_gold")
			
			if buyEnable then 
				SetClickCallback(buyBtn.gameObject, function()
					UsePressCallback(v.ori.itemid , v.ori.exid, buyBtn.gameObject)
				end)
			else
				UIUtil.SetBtnEnable(buyBtn, "btn_7", "btn_4", false)
				buyBtn:GetComponent("UIButton").enabled = false
				buyBtn:GetComponent("UISprite").spriteName = "btn_4"
				buyBtn.normalSprite = "btn_4"
				SetClickCallback(buyBtn.gameObject, function()
					UsePressCallback(v.ori.itemid , v.ori.exid, buyBtn.gameObject)
				end)
			end 
		
			--num
			local num = itemTransform.transform:Find("bg_list/txt_num/num"):GetComponent("UILabel")
			if itemType ~= 5 then
				if itemBagData ~= nil then
					useBtn.gameObject:SetActive(true)
					if itemBagData.number >= 2 and itemData.quickUse == 1 then
						mutiUseBtn.gameObject:SetActive(true)
					else
						mutiUseBtn.gameObject:SetActive(false)
					end
					buyBtn.gameObject:SetActive(false)
					
					num.text = itemBagData.number
				else
					useBtn.gameObject:SetActive(false)
					mutiUseBtn.gameObject:SetActive(false)
					buyBtn.gameObject:SetActive(true)
					
					num.text = "0"--"[ff0000]0[-]"
					local money = itemTransform.transform:Find("bg_list/btn_use_gold/num"):GetComponent("UILabel")
					money.text = itemExchangeData.price
					
					-- print("__________",v.itemid,v.itemExId,itemExchangeData.price)
				end
			else
				if itemBagData ~= nil then
					num.text = itemBagData.number
				else
					num.text = "0"--"[ff0000]0[-]"
				end
				useBtn.gameObject:SetActive(false)
				mutiUseBtn.gameObject:SetActive(false)
				buyBtn.gameObject:SetActive(true)
				local money = itemTransform.transform:Find("bg_list/btn_use_gold/num"):GetComponent("UILabel")
				if itemExchangeData ~= nil then 
					money.text = itemExchangeData.price
				end
			end
			
			if showLimitCount and itemExchangeData~=nil and tonumber(itemExchangeData.MaxBuyTime) <=0 then 
				local buyBtn  = itemTransform.transform:Find("bg_list/btn_use_gold")
				-- buyBtn.gameObject:SetActive(false)
			end
			if GUIMgr:IsMenuOpen("MobaMain") then 
				itemTransform.transform:Find("bg_list/btn_use_gold/icon_gold"):GetComponent("UISprite").spriteName = "mobastore_1"
			
			else
				itemTransform.transform:Find("bg_list/btn_use_gold/icon_gold"):GetComponent("UISprite").spriteName = "icon_gold"
			
			end 
			
			childIndex = childIndex + 1
		end
	end
	
	for i=childIndex , (childCount-1) ,1 do
		_ui.itemGrid:GetChild(i).gameObject:SetActive(false)
	end
	
	local gridCom = _ui.itemGrid:GetComponent("UIGrid")
	gridCom.hideInactive = true
	gridCom:Reposition()
	if needReposition then
		scrollView:ResetPosition()
		needReposition = false
	end
	scrollView:RestrictWithinBounds(true)
end

function UpdateTopProgress()
	if _ui == nil or transform == nil or transform:Equals(nil) then
		return
	end
	local loading = transform:Find(String.Format("{0}/bg_frane/bg_loading", _pathRoot))
	if _ui.itemGrid == nil then
		_ui.itemGrid = transform:Find(String.Format("{0}/bg_frane/Scroll View/Grid", _pathRoot))
	end
	local tittle = transform:Find(String.Format("{0}/bg_frane/bg_top/title" , _pathRoot)):GetComponent("UILabel")
	tittle.text = bagTittle
	
	local loadProgress = {}
	
	if loading ~= nil then
	
		loadProgress.loading = loading:Find("loading"):GetComponent("UISlider")
		loadProgress.text = loading:Find("Text"):GetComponent("UILabel")
		loadProgress.time = loading:Find("time"):GetComponent("UILabel")
		loadProgress.time_free = loading:Find("text_free"):GetComponent("UILabel")
		loadProgress.btn_finish = loading:Find("btn_finish")
		loadProgress.btn_cancel = loading:Find("btn_cancel")
		loadProgress.btn_help = loading:Find("btn_help")
		loadProgress.btn_finish_gold = loading:Find("btn_finish_gold")
		loadProgress.btn_finish_gold_num = loadProgress.btn_finish_gold:Find("num"):GetComponent("UILabel")
		local _text, _time, _totalTime, _finishFuc, _cancelFuc, _goldFuc, _goldtype, _helpFunc, _createtime , upBuildId
		if InitFunction ~= nil then
			_text, _time, _totalTime, _finishFuc, _cancelFuc, _goldFuc, _goldtype, _helpFunc, _createtime ,upBuildId = InitFunction()
        end
        if _disableFinishbtn ~= nil and _disableFinishbtn then
			loadProgress.btn_finish.gameObject:SetActive(false)
			loadProgress.btn_finish_gold.gameObject:SetActive(false)
        end

		if itemType == 3 then
			loadProgress.btn_finish.gameObject:SetActive(false)
			loadProgress.btn_finish_gold.gameObject:SetActive(false)
			loadProgress.btn_cancel.gameObject:SetActive(false)
			loadProgress.btn_help.gameObject:SetActive(false)
		else
		    if _finishFuc == nil then
		        loadProgress.btn_finish.gameObject:SetActive(false)
		    else
			    SetClickCallback(loadProgress.btn_finish.gameObject, _finishFuc)
			end

			if _cancelFuc == nil then
			    loadProgress.btn_cancel.gameObject:SetActive(false)
			else
			    SetClickCallback(loadProgress.btn_cancel.gameObject, _cancelFuc)
            end
			
			if _goldFuc == nil then
			    loadProgress.btn_finish_gold.gameObject:SetActive(false)
			else
				SetClickCallback(loadProgress.btn_finish_gold.gameObject, function()
					if messageText == nil then
						_goldFuc()
						return
					end
					local gold = tonumber(loadProgress.btn_finish_gold_num.text)
					if gold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
						Global.ShowNoEnoughMoney()
						return
					end
					if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
						if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt(timestring) then
							MessageBox.SetOkNow()
						else
							MessageBox.SetRemberFunction(function(ishide)
								if ishide then
									UnityEngine.PlayerPrefs.SetInt(timestring,tonumber(os.date("%d")))
									UnityEngine.PlayerPrefs.Save()
								end
							end)
						end
						MessageBox.Show(System.String.Format(TextMgr:GetText(messageText), gold, _text), _goldFuc, function() end)
					else
						_goldFuc()
					end
				end)
            end

			if _helpFunc == nil then
			    loadProgress.btn_help.gameObject:SetActive(false)
			else
			    SetClickCallback(loadProgress.btn_help.gameObject, _helpFunc)
			end
		end
		loadProgress.text.text = _text

		if _time ~= nil then
			CountDown.Instance:Add("Accel", _time, CountDown.CountDownCallBack(function(t)
	            leftTime = _time - Serclimax.GameTime.GetSecTime()

	            if itemType == 1 then --有免费时间
		            if LaboratoryUpgrade.IsOpen() or entryFlag == 1 then
						actualTime = math.max(0, leftTime - maincity.techFreeTime())
		            	loadProgress.time_free.text = String.Format(TextMgr:GetText("CommonItemBag_ui13"), Serclimax.GameTime.SecondToString3(actualTime), maincity.techFreeTime() / 60)
					else
						actualTime = math.max(0, leftTime - maincity.freetime())
		            	loadProgress.time_free.text = String.Format(TextMgr:GetText("CommonItemBag_ui13"), Serclimax.GameTime.SecondToString3(actualTime), maincity.freetime() / 60)
		            end
		            loadProgress.time_free.gameObject:SetActive(true)
	        	elseif itemType == 2 or itemType == 4 then --没有免费时间
	        		actualTime = leftTime
	        	end
				UpdateAutoSpeedup()
	            if leftTime > 0 then
		            local totalTime = tonumber(_totalTime)
		            loadProgress.time.text = t
			        loadProgress.loading.value = 1 - (leftTime / totalTime)
			        if itemType == 3 then
			            if _finishFuc ~= nil then
						    loadProgress.btn_finish.gameObject:SetActive(false)
                        end
                        if _goldFuc ~= nil then
						    loadProgress.btn_finish_gold.gameObject:SetActive(false)
                        end
                        if _cancelFuc ~= nil then
						    loadProgress.btn_cancel.gameObject:SetActive(false)
                        end
                    elseif itemType == 2 or itemType == 4 then --没有免费时间、可金钱加速
                    	if _goldFuc ~= nil then
				            loadProgress.btn_finish_gold.gameObject:SetActive(true)
				            loadProgress.btn_finish_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(_goldtype, leftTime))
                        end
				        if _finishFuc ~= nil then
				            loadProgress.btn_finish.gameObject:SetActive(false)
                        end
				        if _helpFunc ~= nil then
				            loadProgress.btn_help.gameObject:SetActive(false)
                        end       	
					else --有免费时间
						if freefinish and leftTime <= maincity.freetime() then
						    if _goldFuc ~= nil then
				        	    loadProgress.btn_finish_gold.gameObject:SetActive(false)
                            end
                            if _finishFuc ~= nil then
				        	    loadProgress.btn_finish.gameObject:SetActive(true)
                            end
                            if _helpFunc ~= nil then
				        	    loadProgress.btn_help.gameObject:SetActive(false)
				        	end
				        elseif (_goldtype == 1 and UnionHelpData.HasBuildHelp(upBuildId)) or (_goldtype == 3 and UnionHelpData.HasTechHelp()) then
				        	if _createtime ~= nil and _createtime >= UnionInfoData.GetJoinTime() then
				        	    if _goldFuc ~= nil then
								    loadProgress.btn_finish_gold.gameObject:SetActive(false)
                                end
                                if _finishFuc ~= nil then
					        	    loadProgress.btn_finish.gameObject:SetActive(false)
					        	end
					        	if _helpFunc ~= nil then
					        	    loadProgress.btn_help.gameObject:SetActive(true)
					        	end
					        else
					            if _goldFuc ~= nil then
					        	    loadProgress.btn_finish_gold.gameObject:SetActive(true)
					        	    loadProgress.btn_finish_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(_goldtype, leftTime - maincity.freetime()))
                                end
					        	if _finishFuc ~= nil then
					        	    loadProgress.btn_finish.gameObject:SetActive(false)
                                end
					        	if _helpFunc ~= nil then
					        	    loadProgress.btn_help.gameObject:SetActive(false)
                                end
					        end
				        else
				            if _goldFuc ~= nil then
				        	    loadProgress.btn_finish_gold.gameObject:SetActive(true)
				        	    if _goldtype == 1 or _goldtype == 3 then
				        	    	loadProgress.btn_finish_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(_goldtype, leftTime - maincity.freetime()))
				        	    else
				        	    	loadProgress.btn_finish_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(_goldtype, leftTime))
				        	    end
                            end
				        	if _finishFuc ~= nil then
				        	    loadProgress.btn_finish.gameObject:SetActive(false)
                            end
				        	if _helpFunc ~= nil then
				        	    loadProgress.btn_help.gameObject:SetActive(false)
                            end       	
				        end
				    end
			        if t == "00:00:00" then
			            CountDown.Instance:Remove("Accel")
			            InitFunction = nil
			            GUIMgr:CloseMenu("CommonItemBag")
			        end
			    else
			        CountDown.Instance:Remove("Accel")
			        InitFunction = nil
			        GUIMgr:CloseMenu("CommonItemBag")
			    end
		    end))
		end
	end
	UpdateAutoSpeedup()
end

local function UpdateTime()
    if itemType == 6 then
        _ui.energyTimeLabel1.text, _ui.energyTimeLabel2.text = MainData.GetSceneEnergyCooldownText()
    end
end

function UpdateItem()
	if transform == nil or transform:Equals(nil) or transform:Find(_pathRoot) == nil then
		return
	end

	_ui.itemGrid = transform:Find(String.Format("{0}/bg_frane/Scroll View/Grid", _pathRoot))
	UpdateTopProgress()

	UpdateItemList()
	--窗口顶部资源详细显示
	if itemType == 0 and tonumber(resType) >= tonumber(Common_pb.MoneyType_Food) and tonumber(resType) <= tonumber(Common_pb.MoneyType_Elec) then
		local ui_resourceStored = transform:Find(String.Format("{0}/bg_frane/bg_mid/bg_text/res_num", _pathRoot)):GetComponent("UILabel")
		local ui_resourceCapacity = transform:Find(String.Format("{0}/bg_frane/bg_mid/bg_text/res_max", _pathRoot)):GetComponent("UILabel")
		local ui_resourceUnprotected = transform:Find(String.Format("{0}/bg_frane/bg_mid/bg_text/res_danger", _pathRoot)):GetComponent("UILabel")

		SetClickCallback(transform:Find(String.Format("{0}/bg_frane/bg_mid/bg_text/btn_help", _pathRoot)).gameObject, function()
			CommonItemBagHelp.Show()
		end)

		resName = TextMgr:GetText(table.concat({"item_", tonumber(resType), "_name"}))
		resourceStored = MoneyListData.GetMoneyByType(resType)
		
		resourceShortage = 0
		resourceNeeded = 0

		local selectedBuilding = BuildingUpgrade.GetTargetBuilding()
		local selectedTechnology = LaboratoryUpgrade.GetCurrentTechData()
		if BuildingUpgrade.IsOpen() then
			resourceNeeded = maincity.GetCurrentUpgradeResource(selectedBuilding)
			for i, v in ipairs(resourceNeeded) do
				if tonumber(v.id) == resType then
	 	       		if tonumber(v.num) > tonumber(resourceStored) then
	 	       			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("[ff0000]{0}[-] / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(tonumber(v.num))))
	 	       		else
	 	       			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("{0} / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(tonumber(v.num))))
	 	       		end
	 	       		resourceNeeded = tonumber(v.num)
	 	       		resourceShortage = resourceNeeded - resourceStored
	 	       		break
	 	       	end
	 		end
		elseif LaboratoryUpgrade.IsOpen() then
			resourceNeeded = selectedTechnology[selectedTechnology.Info.level + 1].Res
			for i, v in ipairs(resourceNeeded) do
				if tonumber(v.type) == resType then
					if tonumber(v.value) > tonumber(resourceStored) then
	 	       			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("[ff0000]{0}[-] / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(tonumber(v.value))))
	 	       		else
	 	       			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("{0} / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(tonumber(v.value))))
	 	       		end
	 	       		resourceNeeded = tonumber(v.value)
	 	       		resourceShortage = resourceNeeded - resourceStored
	 	       		break
	 	       	end
	 		end
	 	elseif Barrack.IsOpen() then
		 	if resType == Common_pb.MoneyType_Food then
				resourceNeeded = Barrack.GetResourceForTraining().ResFood
			elseif resType == Common_pb.MoneyType_Iron then
				resourceNeeded = Barrack.GetResourceForTraining().ResIron
			elseif resType == Common_pb.MoneyType_Oil then
				resourceNeeded = Barrack.GetResourceForTraining().ResOil
			elseif resType == Common_pb.MoneyType_Elec then
				resourceNeeded = Barrack.GetResourceForTraining().ResElectric
			end
			resourceShortage = resourceNeeded - resourceStored

			if resourceShortage > 0 then
	   			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("[ff0000]{0}[-] / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(resourceNeeded)))
	   		else
	   			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("{0} / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(resourceNeeded)))
	   		end
	   	elseif Hospital.IsOpen() then
	   		resourceNeeded = Hospital.GetResourceNeeded(resType)
	   		resourceShortage = resourceNeeded - resourceStored

	   		if resourceShortage > 0 then
	   			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("[ff0000]{0}[-] / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(resourceNeeded)))
	   		else
	   			ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui4"), resName, String.Format("{0} / {1}", Global.ExchangeValue(resourceStored), Global.ExchangeValue(resourceNeeded)))
	   		end
	   	else
	   		ui_resourceStored.text = String.Format(TextMgr:GetText("CommonItemBag_ui10"), resName, Global.ExchangeValue(resourceStored))
		end

		local resourceCapacity = 0;

		if resType == Common_pb.MoneyType_Food then
			resourceCapacity = maincity.GetFoodTotalCapacity()
		elseif resType == Common_pb.MoneyType_Iron then
			resourceCapacity = maincity.GetSteelTotalCapacity()
		elseif resType == Common_pb.MoneyType_Oil then
			resourceCapacity = maincity.GetOilTotalCapacity()
		elseif resType == Common_pb.MoneyType_Elec then
			resourceCapacity = maincity.GetElecTotalCapacity()
		end

		if resourceStored > resourceCapacity then
			ui_resourceCapacity.text = String.Format(TextMgr:GetText("CommonItemBag_ui5"), resName, table.concat({"[ff0000]", Global.ExchangeValue(resourceCapacity)}))
		else
			ui_resourceCapacity.text = String.Format(TextMgr:GetText("CommonItemBag_ui5"), resName, table.concat({"[00ff00]", Global.ExchangeValue(resourceCapacity)}))
		end

		local resourceProtected = 0

		local storage = maincity.GetBuildingByID(2)
		if storage ~= nil then
			local storageData = TableMgr:GetWareData(storage.data.level)
			if resType == Common_pb.MoneyType_Food then
				resourceProtected = WareHouse.GetProtectedResNum(storageData.pvFood)
			elseif resType == Common_pb.MoneyType_Iron then
				resourceProtected = WareHouse.GetProtectedResNum(storageData.pvIron)
			elseif resType == Common_pb.MoneyType_Oil then
				resourceProtected = WareHouse.GetProtectedResNum(storageData.pvOil)
			elseif resType == Common_pb.MoneyType_Elec then
				resourceProtected = WareHouse.GetProtectedResNum(storageData.pvElectric)
			end
		end


		local resourceUnprotected = math.max(resourceStored - resourceProtected, 0)
		if resourceUnprotected == 0 then
			ui_resourceUnprotected.text = String.Format(TextMgr:GetText("CommonItemBag_ui6"), table.concat({"[00ff00]", Global.ExchangeValue(resourceUnprotected)}))
		else
			ui_resourceUnprotected.text = String.Format(TextMgr:GetText("CommonItemBag_ui6"), table.concat({"[ff0000]", Global.ExchangeValue(resourceUnprotected)}))
		end

		-- local ui_resourceHelpBtn = transform:Find(String.Format("{0}/bg_frane/bg_mid/bg_text/btn_help", _pathRoot)).gameObject
		-- SetClickCallback(ui_resourceHelpBtn, function()
		-- 	GUI
		-- )

		transform:Find(String.Format("{0}/bg_frane/bg_mid/bg_text", _pathRoot)).gameObject:SetActive(true)
		transform:Find(String.Format("{0}/bg_frane/bg_mid/Label", _pathRoot)).gameObject:SetActive(false)
	end

	if itemType == 6 then
		transform:Find(String.Format("{0}/bg_frane/bg_mid/Label", _pathRoot)).gameObject:SetActive(false)
		_ui.energyLabel.text = string.format("%d/%d", MainData.GetSceneEnergy(), MainData.GetMaxSceneEnergy())
        UpdateTime()
    end
    transform:Find("ResView/bg_frane/movepoints").gameObject:SetActive(itemType == 6)
	
end

function Awake()
	_ui = {}
	_ui.detailItem = ResourceLibrary.GetUIPrefab("Bag/SlgBagInfo_big")--transform:Find("SlgBagInfo")--
	_ui.detailItemInfo = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.auto_speedup_prefab = ResourceLibrary.GetUIPrefab("BuildingCommon/auto_speedup")
	_ui.auto_speedup_use_prefab = ResourceLibrary.GetUIPrefab("BuildingCommon/auto_speedup_use")
	_ui.energyLabel = transform:Find("ResView/bg_frane/movepoints/currentpoints/Label"):GetComponent("UILabel")
	_ui.energyTimeLabel1 = transform:Find("ResView/bg_frane/movepoints/Label"):GetComponent("UILabel")
	_ui.energyTimeLabel2 = transform:Find("ResView/bg_frane/movepoints/Label (1)"):GetComponent("UILabel")
	MainCityUI.AddCommonItemBagListener(UpdateItem)
	UnionHelpData.AddListener(UpdateTopProgress)
	if itemType == 2 then
		ActionListData.AddListener(UpdateTopProgress)
		MobaActionListData.AddListener(UpdateTopProgress)
    elseif itemType == 6 then
		MainData.AddListener(UpdateItem)
	end
end

function LateUpdate()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end

function Close()
	CountDown.Instance:Remove("Accel")
    MainCityUI.RemoveCommonItemBagListener(UpdateItem)
	UnionHelpData.RemoveListener(UpdateTopProgress)
	if itemType == 2 then
		ActionListData.RemoveListener(UpdateTopProgress)
		MobaActionListData.RemoveListener(UpdateTopProgress)
    elseif itemType == 6 then
        MainData.RemoveListener(UpdateItem)
	end
    UseItemFunction = nil
	InitFunction = nil
	btnClickWait = false
	freefinish = true
	useClose = true
	itemMax = false
	leftTime = nil
	actualTime = nil
	resType = nil
	resName = nil
	resourceNeeded = nil
	resourceStored = nil
	resourceShortage = nil
	entryFlag = -1
	messageText = nil
	timestring = nil
	local close =OnCloseCB
	OnCloseCB = nil
	if close ~= nil and type(close) == "function" then
	    close()
    end
end

function Start()
	local open =OnOpenCB
	OnOpenCB = nil
	if open ~= nil then 
	    open()
    end  
    needReposition = true  
	transform:Find(_pathRoot).gameObject:SetActive(true)
	SetClickCallback(transform:Find(String.Format("{0}/bg_frane/bg_top/btn_close", _pathRoot)).gameObject, QuitPressCallback)
	SetClickCallback(transform:Find(_pathRoot).gameObject, QuitPressCallback)
	SetClickCallback(transform:Find(String.Format("{0}/bg_frane/bg_top/btn_close", _pathRootClose)).gameObject, QuitPressCallback)
	SetClickCallback(transform:Find(_pathRootClose).gameObject, QuitPressCallback)
	UpdateItem()
end

