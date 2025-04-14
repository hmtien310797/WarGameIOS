module("online",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui
local rewardData = nil
local rewardMsg = nil
local canGetCurrentReward
local rewardItem

local iapGoodInfo
	
local function GetReward()
	local rewrd = {}
	local onRewards = OnlineRewardData.GetData()
	
	if onRewards.rewardInfo.items ~= nil and #onRewards.rewardInfo.items > 0 then
		rewrd.type = "item"
		rewrd.value = onRewards.rewardInfo.items[1]
		rewrd.conf = TableMgr:GetItemData(onRewards.rewardInfo.items[1].id)
	elseif onRewards.rewardInfo.heros ~= nil and #onRewards.rewardInfo.heros > 0 then
		rewrd.type = "hero"
		rewrd.value = onRewards.rewardInfo.heros[1]
		rewrd.conf = TableMgr:GetHeroData(onRewards.rewardInfo.heros[1].id)
	end
	
	return rewrd
end

function LoadUI()
	rewardMsg = OnlineRewardData.GetData()
	table.foreach(rewardItem.rewardFactor , function(i,v)
		if v ~= nil then
			v.gameObject:SetActive(false)
		end
	end)
	if rewardMsg.show then
		if rewardMsg.availableTime > Serclimax.GameTime.GetSecTime() then -- 不可领取
			rewardItem.gameObject:SetActive(false)
			_ui.rewardShine.gameObject:SetActive(false)
			_ui.rewardIcon.gameObject:SetActive(true)
			_ui.rewardbg.gameObject:SetActive(true)
			_ui.rewardNone.gameObject:SetActive(false)
			_ui.rewardBtnSprite.spriteName = "btn_4"
			canGetCurrentReward = false
			_ui.rewardTopContent.text = TextMgr:GetText("online_2")
			
			if rewardMsg.nextSenior > 0 then   	--再领取｛0｝次，可获得高级奖励
				_ui.rewardBottomContent.text = System.String.Format(TextMgr:GetText("online_3") ,"[00ff00]" .. rewardMsg.nextSenior .. "[-]"  , rewardMsg.nextSeniorFactor)
				_ui.rewardIcon.mainTexture = ResourceLibrary:GetIcon("Item/" , "item_online1")
			else								--下次可获得高级奖励
				_ui.rewardBottomContent.text = System.String.Format(TextMgr:GetText("online_4") , rewardMsg.nextSeniorFactor)
				_ui.rewardIcon.mainTexture = ResourceLibrary:GetIcon("Item/" , "item_online2")
				if rewardItem.rewardFactor[rewardMsg.nextSeniorFactor] ~= nil then
					rewardItem.rewardFactor[rewardMsg.nextSeniorFactor].gameObject:SetActive(true)
				end
			end
			
		else
			rewardItem.gameObject:SetActive(true)
			_ui.rewardShine.gameObject:SetActive(true)
			_ui.rewardIcon.gameObject:SetActive(false)
			_ui.rewardbg.gameObject:SetActive(false)
			_ui.rewardNone.gameObject:SetActive(false)
			
			_ui.rewardBtnSprite.spriteName = "btn_2"
			canGetCurrentReward = true
			--reward info
			local reward = GetReward()
			if reward.type == "item" then
				_ui.rewardTopContent.text = TextUtil.GetItemName(reward.conf)
				UIUtil.LoadItem(rewardItem, reward.conf, reward.value.num > 0 and reward.value.num or nil) 
			elseif reward.type == "hero" then
				
			end
			
			if rewardMsg.nextSenior > 0 then   	--再领取｛0｝次，可获得高级奖励
				_ui.rewardBottomContent.text = System.String.Format(TextMgr:GetText("online_3") ,"[00ff00]" .. rewardMsg.nextSenior .. "[-]" , rewardMsg.nextSeniorFactor)
			else								--高级奖励
				_ui.rewardBottomContent.text = System.String.Format(TextMgr:GetText("online_6") , rewardMsg.nextSeniorFactor)
				if rewardItem.rewardFactor[rewardMsg.nextSeniorFactor] ~= nil then
					rewardItem.rewardFactor[rewardMsg.nextSeniorFactor].gameObject:SetActive(true)
				end
			end
			
			_ui.rewardtime.text = TextMgr:GetText("online_8")
		end
	else
		rewardItem.gameObject:SetActive(false)
		_ui.rewardShine.gameObject:SetActive(false)
		_ui.rewardIcon.gameObject:SetActive(false)
		_ui.rewardbg.gameObject:SetActive(false)
		_ui.rewardNone.gameObject:SetActive(true)
	end

	-- 推荐商品
	iapGoodInfo = OnlineRewardData.GetRecommendedGood()
	_ui.recommendedGoods.name.text = TextMgr:GetText(iapGoodInfo.name)
	_ui.recommendedGoods.description.text = TextMgr:GetText(System.String.IsNullOrEmpty(iapGoodInfo.subDesc) and iapGoodInfo.desc or iapGoodInfo.subDesc)
	_ui.recommendedGoods.icon.mainTexture = ResourceLibrary:GetIcon("pay/", iapGoodInfo.icon)
	_ui.recommendedGoods.discount.text = System.String.Format(TextMgr:GetText("ui_discount"), iapGoodInfo.discount)
end

local function UpdateRewardState()
	if not canGetCurrentReward then
		local leftTimeSec = rewardMsg.availableTime - Serclimax.GameTime.GetSecTime()
		if leftTimeSec > 0 then
			local countDown = Global.GetLeftCooldownTextLong(rewardMsg.availableTime)
			_ui.rewardtime.text = countDown
		else
			_ui.rewardtime.text = "00:00:00"
			canGetCurrentReward = true
			LoadUI()
		end
	end
end

function LateUpdate()
    UpdateRewardState()
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function GetRewardCallback(go)
	if not canGetCurrentReward then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("online_7"))
		return
	end
	
	local req = ActivityMsg_pb.MsgTakeOnlineRewardRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeOnlineRewardRequest, req, ActivityMsg_pb.MsgTakeOnlineRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			GUIMgr:SendDataReport("reward", "TakeOnlineReward", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
		
			OnlineRewardData.UpdateData(msg.onlineReward)
			MainCityUI.UpdateRewardData(msg.fresh)
			
			--小丁丁说的，在线奖励一定只会领取到一个物品，所以展示只按一个道具进行处理 2017/4/20
			local rewardItemMsg = msg.reward.item.item[1]
			local itData = TableMgr:GetItemData(rewardItemMsg.baseid)
			if itData ~= nil then
				local nameColor = Global.GetLabelColorNew(itData.quality)
				local showText = System.String.Format(TextMgr:GetText("online_5") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1] )
				FloatText.Show(showText , Color.white, ResourceLibrary:GetIcon("Item/", itData.icon))
				AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
				--Hide()
			else
				print("wrong item id")
			end
			--FloatText.Show("获得道具" , Color.green)
        end
    end)
end

function Awake()
	_ui = {}
	local closeBtn = transform:Find("content/bg_top/close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject, Hide)
	
	SetClickCallback(transform:Find("mask").gameObject , Hide)
	
	_ui.getRewardBtn = transform:Find("content/text/button"):GetComponent("UIButton")
	SetClickCallback(_ui.getRewardBtn.gameObject, GetRewardCallback)
	
	_ui.rewardBtnSprite = transform:Find("content/text/button"):GetComponent("UISprite")
	_ui.rewardTopContent = transform:Find("content/bg_mid/text01"):GetComponent("UILabel")
	_ui.rewardBottomContent = transform:Find("content/text"):GetComponent("UILabel")
	_ui.rewardIcon = transform:Find("content/bg_mid/mid/icon"):GetComponent("UITexture")
	_ui.rewardbg = transform:Find("content/bg_mid/time")
	_ui.rewardtime = transform:Find("content/bg_mid/time/time"):GetComponent("UILabel")
	_ui.rewardShine = transform:Find("content/bg_mid/mid/ShineItem")
	_ui.rewardNone = transform:Find("content/none")
	
	rewardItem = {}
	local itemTransform = transform:Find("content/bg_mid/mid/Item_CommonNew")
	UIUtil.LoadItemObject(rewardItem, itemTransform)
	rewardItem.rewardFactor = {}
	rewardItem.rewardFactor[3] = transform:Find("content/bg_mid/mid/x3")
	rewardItem.rewardFactor[5] = transform:Find("content/bg_mid/mid/x5")
	
	OnlineRewardData.AddListener(LoadUI)

	local recommendedGoods = {}
	recommendedGoods.transform = transform:Find("content_gold")
	recommendedGoods.gameObject = recommendedGoods.transform.gameObject
	recommendedGoods.name = recommendedGoods.transform:Find("bg_top/title"):GetComponent("UILabel")
	recommendedGoods.description = recommendedGoods.transform:Find("bg_mid/text01"):GetComponent("UILabel")
	recommendedGoods.icon = recommendedGoods.transform:Find("bg_mid/mid/Texture"):GetComponent("UITexture")
	recommendedGoods.discount = recommendedGoods.transform:Find("bg_mid/mid/Texture/Discount/Num"):GetComponent("UILabel")

	SetClickCallback(recommendedGoods.transform:Find("bg_mid/mid/button").gameObject, function()
		if iapGoodInfo.type == 1 then -- 黄金
    		Goldstore.ShowRechargeTab()
    	elseif iapGoodInfo.type == 2 or iapGoodInfo.type == 6 then -- 礼包、限时礼包
    		Goldstore.ShowGiftPack(iapGoodInfo)
    	elseif iapGoodInfo.type == 3 or iapGoodInfo.type == 4 then -- 周卡、月卡
    		Goldstore.Show(2, 1)
    	elseif iapGoodInfo.type == 5 then -- 成长基金
    		WelfareAll.Show(3001)--Goldstore.Show(3)
    	elseif iapGoodInfo.type == 7 then
    		Goldstore.Show(2, 2) -- 将军周卡
    	else
    		Goldstore.Show()
    	end

    	CloseAll()
	end)

	_ui.recommendedGoods = recommendedGoods
end


function Start()
end

function Close()
	_ui = nil
	OnlineRewardData.RemoveListener(LoadUI)
	OnlineRewardData.RequestData()
end

function Show()
	Global.OpenUI(_M)
	LoadUI()
end

function TestRecommendGood(num) -- online.TestRecommendGood()
	if not num then
		num = 100
	end

	local numRecorded = 0
	local data = { limitedGiftPack = 0,
	               monthCard = 0,
	               weekCard = 0,
	               heroCard = 0,
	               goldReserve = 0,
	               growthFund = 0,
	               themePack = 0,
	               resourcePack = 0,
	               boostPack = 0,
	               other = 0,           }
	local giftPacks = {}
	local iapGoodInfos = {}

	function Test()
		if numRecorded < num then
			local req = ActivityMsg_pb.MsgOnlineRewardInfoRequest()
		    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgOnlineRewardInfoRequest, req, ActivityMsg_pb.MsgOnlineRewardInfoResponse, function(msg)
		        if msg.code == ReturnCode_pb.Code_OK then
		        	local iapGoodInfo = msg.goodInfo

		        	if iapGoodInfo.type == 6 then
		        		data.limitedGiftPack = data.limitedGiftPack + 1
		        	elseif iapGoodInfo.type == 1 then
		        		data.goldReserve = data.goldReserve + 1
		        	elseif iapGoodInfo.type == 4 then
		        		data.monthCard = data.monthCard + 1
		        	elseif iapGoodInfo.type == 3 then
		        		if iapGoodInfo.subType == 0 then
		        			data.weekCard = data.weekCard + 1
		        		else
		        			data.heroCard = data.heroCard + 1
		        		end
		        	elseif iapGoodInfo.type == 7 then
		        		data.growthFund = data.growthFund + 1
		        	elseif iapGoodInfo.type == 2 then
		        		if iapGoodInfo.priceType == 2 then
		        			if iapGoodInfo.tab == 1 then
		        				data.themePack = data.themePack + 1
		        			elseif iapGoodInfo.tab == 2 then
		        				data.resourcePack = data.resourcePack + 1
		        			elseif iapGoodInfo.tab == 3 then
		        				data.boostPack = data.boostPack + 1
		        			end
		        		end
		        	else
		        		data.other = data.other + 1
		        	end

		        	if giftPacks[iapGoodInfo.id] then
		        		giftPacks[iapGoodInfo.id] = giftPacks[iapGoodInfo.id] + 1
		        	else
		        		giftPacks[iapGoodInfo.id] = 1
		        		iapGoodInfos[iapGoodInfo.id] = iapGoodInfo
		        	end

		        	numRecorded = numRecorded + 1

		        	Global.LogDebug(_M, "TestRecommendGood", string.make_fraction(numRecorded, num))

		        	Test()
		        end
		    end, true)
		else
			local file = io.open("d:/[DEBUG]OnlineReward.txt", "w")
		    
			for goodID, counter in pairs(giftPacks) do
				file:write(string.format("[%5d]%s\t\t%d/%d\t\t[%.2f%%]\n", goodID, TextMgr:GetText(iapGoodInfos[goodID].name), counter, num, 100 * counter / num))
			end

			file:write("\n\n")

			for name, counter in pairs(data) do
				file:write(string.format("%s\t\t%d/%d\t\t[%.2f%%]\n", name, counter, num, 100 * counter / num))
			end

			file:close()

			Global.LogDebug(_M, "TestRecommendGood", "DONE OUTPUT: d:/[DEBUG]OnlineReward.txt")
		end
	end

	coroutine.start(Test)
end
