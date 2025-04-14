module("MilitaryRank", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local NGUITools = NGUITools
local curMilitaryRankLv 
local curMilitaryRankGrade 

local isLevelNew = false
local isShortItem1 = false
local isShortItem2 = false


local _ui
local timer = 0


local MilitaryRankUI = {}
	
function HideAll()
	Hide()
    GUIMgr:CloseMenu("MainInformation")
end

function Hide(closeMe)
    Global.CloseUI(_M)
	if closeMe ~= false then
		GUIMgr:CloseMenu("MainInformation")
	end
end


local function BuyExpFunc(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)

	local req = ShopMsg_pb.MsgCommonShopBuyRequest()
	req.exchangeId = exItemid
	req.num = count
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopBuyRequest, req, ShopMsg_pb.MsgCommonShopBuyResponse, function(msg)
        if msg.code == 0 then
            MainCityUI.UpdateRewardData(msg.fresh)
            -- UpdateexchangeItems(exchangeId, msg.currentBuyNum)
            -- ProcessActivity()
            Global.ShowReward(msg.reward)
            Global.GAudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
			ShopItemData.RequestData(1, function(msg)
				CommonItemBag.SetLimitCount(true)
				CommonItemBag.UpdateItem()
			end)
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, true)
end


local function UseExpFunc1(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	local req = ItemMsg_pb.MsgUseItemRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
	end
	req.num = count
	
	
	local lastLevel = MainData.GetLevel()
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
		--print("use item code:" .. msg.code)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.FloatError(msg.code, Color.white)
			
		else
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end		
			useItemReward = msg.reward
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
				
			MainCityUI.UpdateRewardData(msg.fresh)

			ShopItemData.RequestData(2, function(msg)
				CommonItemBag.SetLimitCount(true)
				CommonItemBag.UpdateItem()
			end)
		end
	end, true)
end

local function AddExpCallBack(go)
	
	local items = {}
	items = maincity.GetItemExchangeListNoCommon(10)
	
	local noirtem = Global.BagIsNoItem(items)
	local noItemHint = TextMgr:GetText("player_ui18")
	if noirtem == true then
		FloatText.Show(noItemHint)
		return
	end
	
	local maxLevel = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PlayerMaxLevel).value
	local maxHint = TextMgr:GetText("build_ui33")
	local myLevel = MainData.GetLevel()
	if myLevel >= tonumber(maxLevel) then
		AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
		FloatText.Show(maxHint , Color.green)
		return
	end
	
	CommonItemBag.SetTittle(TextMgr:GetText("player_ui16"))
	CommonItemBag.SetResType(Common_pb.MoneyType_None)
	CommonItemBag.SetItemList(items, 0)
	CommonItemBag.SetUseFunc(UseExpFunc)
	CommonItemBag.OnOpenCB = function()
	end
	GUIMgr:CreateMenu("CommonItemBag" , false)
	
end


function Start()
	
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function LoadConditionObject(conditionTransform)
    local condition = {}
    condition.gameObject = conditionTransform.gameObject
    condition.descriptionLabel = conditionTransform:Find("title"):GetComponent("UILabel")
    condition.numberLabel = conditionTransform:Find("title/num"):GetComponent("UILabel")
    condition.starSprite = conditionTransform:Find("star"):GetComponent("UISprite")
    condition.goButton = conditionTransform:Find("btn_go"):GetComponent("UIButton")
    return condition
end

function Awake()
    
	_ui = {}

	SetClickCallback(transform:Find("Container/MilitaryRank/btn_close").gameObject, function(go)
		Hide()
	end)
	
    MilitaryRankUI = {}

    MilitaryRankUI.transform = transform:Find("Container/MilitaryRank")
    MilitaryRankUI.gameObject = MilitaryRankUI.transform.gameObject
	
    MilitaryRankUI.grid = transform:Find("Container/MilitaryRank/mid/Scroll View/Grid"):GetComponent("UIGrid")
	MilitaryRankUI.scrool = transform:Find("Container/MilitaryRank/mid/Scroll View"):GetComponent("UIScrollView")


	MilitaryRankUI.ranks = {}

	for i = 1, 5 do
        table.insert(MilitaryRankUI.ranks,transform:Find(string.format("Container/MilitaryRank/rankinfo/rank%d", i)).gameObject)
    end
	
	
	MilitaryRankUI.rate  = transform:Find("Container/MilitaryRank/rankinfo/upgrade/condition/rate"):GetComponent("UILabel")
	MilitaryRankUI.rate.transform:GetComponent("LocalizeEx").enabled = false
	MilitaryRankUI.gradeButton = transform:Find("Container/MilitaryRank/rankinfo/button"):GetComponent("UIButton")
	MilitaryRankUI.tipButton = transform:Find("Container/MilitaryRank/item/detail"):GetComponent("UIButton")

	MilitaryRankUI.gradeLabelButton = transform:Find("Container/MilitaryRank/rankinfo/button/Label"):GetComponent("UILabel")
	
	MilitaryRankUI.effectScrool = transform:Find("Container/MilitaryRank/rankinfo/effect/bg/Scroll View")
	MilitaryRankUI.effectGrid = transform:Find("Container/MilitaryRank/rankinfo/effect/bg/Scroll View/Grid")
	MilitaryRankUI.effectItem = MilitaryRankUI.effectGrid:Find("1")
	MilitaryRankUI.effectItem.parent = MilitaryRankUI.effectScrool
	MilitaryRankUI.effectItem.gameObject:SetActive(false)
	
	MilitaryRankUI.condition1 = LoadConditionObject(transform:Find("Container/MilitaryRank/rankinfo/upgrade/bg_mission"))
	MilitaryRankUI.condition2 = LoadConditionObject(transform:Find("Container/MilitaryRank/rankinfo/bg_mission"))
	
	MilitaryRankUI.item1Button = transform:Find("Container/MilitaryRank/item/1/add"):GetComponent("UIButton")
	MilitaryRankUI.item2Button = transform:Find("Container/MilitaryRank/item/2/add"):GetComponent("UIButton")
	MilitaryRankUI.item3Texture = transform:Find("Container/MilitaryRank/item/3"):GetComponent("UITexture")
	MilitaryRankUI.item3Button = transform:Find("Container/MilitaryRank/item/3/add"):GetComponent("UIButton")
	MilitaryRankUI.item3Label = transform:Find("Container/MilitaryRank/item/3/num"):GetComponent("UILabel")
	

    MilitaryRankUI.itemGrid = transform:Find("Container/MilitaryRank/rankinfo/upgrade/condition/rate/bg_item/Grid"):GetComponent("UIGrid")
    MilitaryRankUI.itemPrefab = MilitaryRankUI.itemGrid.transform:GetChild(0).gameObject

	MilitaryRankUI.item1Icon  = transform:Find("Container/MilitaryRank/item/1"):GetComponent("UITexture")
	MilitaryRankUI.item1Num  = transform:Find("Container/MilitaryRank/item/1/num"):GetComponent("UILabel")
	MilitaryRankUI.item2Icon  = transform:Find("Container/MilitaryRank/item/2"):GetComponent("UITexture")
	MilitaryRankUI.item2Num  = transform:Find("Container/MilitaryRank/item/2/num"):GetComponent("UILabel")
	
	MilitaryRankUI.upgradeUI  = transform:Find("Container/MilitaryRank/rankinfo/upgrade").gameObject
	
	SetClickCallback(MilitaryRankUI.item1Button.gameObject, function()
        CheckResourceInfo(43)
    end)
	
	SetClickCallback(MilitaryRankUI.item2Button.gameObject, function()
        CheckResourceInfo(44)
    end)

	if Global.IsOutSea() then
		transform:Find("Container/MilitaryRank/item/2/add"):GetComponent("UISprite").spriteName = ""

		SetClickCallback(MilitaryRankUI.item2Button.gameObject, function()
		  MessageBox.Show(TextMgr:GetText("tips_PrestigeBook"))
		end)
	end
	
    SetClickCallback(MilitaryRankUI.gradeButton.gameObject, function()
        RequestMilitaryRank()
    end)
	
	SetClickCallback(MilitaryRankUI.tipButton.gameObject, function()
        Statistic.Show(curMilitaryRankLv,curMilitaryRankGrade);
    end)
	
	UpdateCurMilitaryRankInfo()
	UpdateMilitaryRankUI(false)
	MoneyListData.AddListener(UpdateMoney)
	ItemListData.AddListener(UpdateMoney)
	
	local items = ShopItemData.GetShopItems()
	
	if items[1] == nil then 
		ShopItemData.RequestData(1, function(msg)

		end)
		ShopItemData.RequestData(2, function(msg)

		end)
	end
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end



function Close()
	_ui = nil
	MoneyListData.RemoveListener(UpdateMoney)
	ItemListData.RemoveListener(UpdateMoney)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
end

function Show()
    Global.OpenUI(_M)
end

-- 升级，升阶
function RequestMilitaryRank()
	
	local req = ClientMsg_pb.MsgMilitaryRankLevelUpRequest()
		
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgMilitaryRankLevelUpRequest, req, ClientMsg_pb.MsgMilitaryRankLevelUpResponse, function(msg)
		
		local isLevel = false;
		for _, ruleData in pairs(TableMgr:GetMilitaryRuleTable()) do
			if tonumber(ruleData.RankLevel) == tonumber(curMilitaryRankLv) and tonumber(ruleData.RankGrade) == tonumber(curMilitaryRankGrade) then
				isLevel = true
			end 
		end 

		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
		    MilitaryRankData.UpdateCondition(msg.conds)
			if tonumber(msg.militaryRankId) == tonumber(MainData.GetMilitaryRankID()) then
				if isLevel == true then
					FloatText.Show(TextMgr:GetText("militaryrank_18"), Color.red )
				else
					FloatText.Show(TextMgr:GetText("militaryrank_21"), Color.red )
				end 
				MainData.SetMilitaryRankUpFail(msg.militaryRankLevelUpFailCnt)
				UpdateCurMilitaryRankInfo()
				UpdateMilitaryRankUI(false)
				MainCityUI.UpdateRewardData(msg.fresh)
				--MainData.RequestData()
				--ItemListData.RequestData(function()
				--end)
			else
				if isLevel == true then
					FloatText.Show(TextMgr:GetText("militaryrank_19"), Color.green )
				else
					FloatText.Show(TextMgr:GetText("militaryrank_20"), Color.green )
				end 
				
				MainCityUI.UpdateRewardData(msg.fresh)
				-- Moneylist
				--PowerUp.Show(MainData.GetPkValue() , lastpk  , Color.green)

				MainData.SetMilitaryRankID(msg.militaryRankId)
				MainData.SetMilitaryRankUpFail(msg.militaryRankLevelUpFailCnt)
				UpdateCurMilitaryRankInfo()
				UpdateMilitaryRankUI(true)
			--	MainData.RequestData()
			--	ItemListData.RequestData(function()
			--	end)
			end 
		end
	end)
end


function CheckResourceInfo(index)
	
	local items = {}
	items = maincity.GetItemExchangeListNoCommon(index)
	
	local noirtem = Global.BagIsNoItem(items)
	local noItemHint = TextMgr:GetText("player_ui18")
	if noirtem == true then
		FloatText.Show(noItemHint)
		return
	end
	
	local maxLevel = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PlayerMaxLevel).value
	local maxHint = TextMgr:GetText("build_ui33")
	local myLevel = MainData.GetLevel()
	if myLevel >= tonumber(maxLevel) then
		--AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
		--FloatText.Show(maxHint , Color.green)
		--return
	end
	
	if index ==43 then 
		CommonItemBag.SetTittle(TextMgr:GetText("item_19_name"))
		CommonItemBag.SetItemList(items, 0)
	else 
		CommonItemBag.SetTittle(TextMgr:GetText("item_15009_name"))
		CommonItemBag.SetItemList(items, 5)
	end 
	
	CommonItemBag.SetResType(Common_pb.MoneyType_None)
	
	if index == 43 then
		CommonItemBag.SetUseFunc(UseExpFunc1)
	else
		CommonItemBag.SetUseFunc(BuyExpFunc)
	end
	CommonItemBag.NotUseAutoClose()
	CommonItemBag.SetLimitCount(true)
	CommonItemBag.OnOpenCB = function()
	end
	GUIMgr:CreateMenu("CommonItemBag" , false)
	if index == 43 then 
		ShopItemData.RequestData(2, function(msg)
			CommonItemBag.SetLimitCount(true)
			CommonItemBag.UpdateItem()
		end)
	else 
		ShopItemData.RequestData(1, function(msg)
			CommonItemBag.SetLimitCount(true)
			CommonItemBag.UpdateItem()
		end)
	end 
end

local function ShowMilitaryRankInfo(lv,grade,updateMoney)
	
	-- 升级消耗
	if updateMoney == nil then
		UpdateMoney()
	end 
	MilitaryRankUI.rate.text = ""
	--MilitaryRankUI.condition1:SetActive(false)
	--MilitaryRankUI.condition2:SetActive(false)
	--MilitaryRankUI.gradeButton.gameObject:SetActive(false)
	
    local itemGrid = MilitaryRankUI.itemGrid
    local itemPrefab = MilitaryRankUI.itemPrefab
    local nextRankData = tableData_tMilitaryRank.data[MainData.GetMilitaryRankID() + 1]
	 for _, rankData in pairs(TableMgr:GetMilitaryRankTable()) do
	
		if tonumber(rankData.RankLevel) == tonumber(lv) and tonumber(rankData.RankGrade) == tonumber(grade) then
			if tonumber(rankData.LevelupRate)>=10000 then 
				MilitaryRankUI.rate.text =""
			else 
				
				local rate = rankData.LevelupRate
				if rankData.RateAdd ~= nil then 
					rate = rate + tonumber(rankData.RateAdd) * MainData.GetMilitaryRankUpFail() 
					if rate > rankData.RateMaxshow then 
						rate  =  tonumber(rankData.RateMaxshow)
					end
				end 
				
				MilitaryRankUI.rate.text =  System.String.Format(TextMgr:GetText("command_ui_command_txt01"),rate /100)
			end 
			--MilitaryRankUI.gradeButton.gameObject:SetActive(true)
			--MilitaryRankUI.cost.text =  tonumber(rankData.LevelupConsume:split(":")[2])
			local itemList = string.split(nextRankData.LevelupConsume, ";")
			
            local imprintData
            local imprintCount
            for i, v in ipairs(itemList) do
                local itemIdList = string.split(v, ":")
                local itemId = tonumber(itemIdList[1])
                local itemCount = tonumber(itemIdList[2])

                local itemData = TableMgr:GetItemData(itemId)
                local hasCount = 0
                if itemData.type == 1 then
                    hasCount = MoneyListData.GetMoneyByType(itemData.id)
                else
                    hasCount = ItemListData.GetItemCountByBaseId(itemId)
                end
                if itemId >= 15025 and itemId <= 15028 then
                    imprintData = itemData
                    imprintCount = hasCount
                end
                local itemTransform
                if i > itemGrid.transform.childCount then
                    itemTransform = NGUITools.AddChild(itemGrid.gameObject, itemPrefab).transform
                else
                    itemTransform = itemGrid.transform:GetChild(i - 1)
                end
                
                itemTransform:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
                itemTransform:Find("num"):GetComponent("UILabel").text = hasCount < itemCount and "[ff0000]" .. itemCount or itemCount
                itemTransform.gameObject:SetActive(true)
            end
            for i = #itemList + 1, itemGrid.transform.childCount do
                itemGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
            end
            itemGrid.repositionNow = true

            MilitaryRankUI.item3Texture.gameObject:SetActive(imprintData ~= nil)
            if imprintData ~= nil then
                MilitaryRankUI.item3Texture.mainTexture = ResourceLibrary:GetIcon("Item/", imprintData.icon)
                MilitaryRankUI.item3Label.text = imprintCount
                SetClickCallback(MilitaryRankUI.item3Button.gameObject, function(go)
                    if go == _ui.tipObject then
                        _ui.tipObject = nil
                    else
                        _ui.tipObject = go
                        Tooltip.ShowItemTip({name = TextUtil.GetItemName(imprintData), text = TextUtil.GetItemDescription(imprintData)})
                    end
                end)
            end
		end 
	end 
    if nextRankData == nil then
        MilitaryRankUI.item3Texture.gameObject:SetActive(false)
    end
end 

local function WorldMapJump(jumpFunc)
    if GUIMgr:IsMenuOpen("WorldMap") then
        MainCityUI.HideWorldMap(true, function()
            jumpFunc()
        end, true)
    else
        jumpFunc()
    end
end

local function GetJumpFunc(conditionData, conditionMsg)
    local conditionType = conditionData.type
    if conditionType == 1 then
        return function()
            WorldMapJump(function()
                maincity.SetTargetBuild(conditionData.arg1, true, nil, true)
            end)
        end
    elseif conditionType == 2 or conditionType == 4 then
        return function()
            local basePos = MapInfoData.GetData().mypos
            MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
                if conditionType == 2 then
                    MapSearch.Show(1)
                elseif conditionType == 4 then
                    MapSearch.Show(2)
                end
            end)
        end
    elseif conditionType == 3 then
        return function()
            local cityData = tableData_tWorldCity.data[conditionMsg.need]
            local cityPos = WorldCityData.GetCityInfo(cityData.id).pos
            MainCityUI.ShowWorldMap(cityPos.x, cityPos.y, true)
        end
    elseif conditionType == 5 or conditionType == 6 or conditionType == 7 then
        return function()
            local basePos = MapInfoData.GetData().mypos
            MainCityUI.ShowWorldMap(basePos.x, basePos.y, true, function()
            end)
        end
    end
end

local function LoadCondition(condition, rankData)
    if rankData ~= nil and rankData.Condition2 ~= 0 then
        condition.gameObject:SetActive(true)
        local conditionData = tableData_tRankCondition.data[rankData.Condition2]
        local conditionType = conditionData.type
        local conditionMsg = MilitaryRankData.GetConditionMsg(rankData.id)
        if conditionType == 3 then
            local cityData = tableData_tWorldCity.data[conditionMsg.need]
            condition.descriptionLabel.text = System.String.Format(TextMgr:GetText(conditionData.description), TextMgr:GetText(cityData.Name))
            condition.numberLabel.text = TextMgr:GetText(conditionMsg.value >= conditionMsg.need and Text.union_train5 or Text.ui_activity_des10)
        else
            condition.descriptionLabel.text = System.String.Format(TextMgr:GetText(conditionData.description), conditionMsg.need)
            condition.numberLabel.text = string.format("(%d/%d)", conditionMsg.value, conditionMsg.need)
        end
        condition.starSprite.spriteName = conditionMsg.value >= conditionMsg.need and "icon_star" or "icon_star_hui"
		condition.goButton.gameObject:SetActive(conditionMsg.value < conditionMsg.need)
		if Global.GetMobaMode() == 2 then 
			condition.goButton.gameObject:SetActive(false)
		end 
        if conditionMsg.value < conditionMsg.need then
            SetClickCallback(condition.goButton.gameObject, function(go)
                print("conditionType:", conditionType)
                local jumpFunc = GetJumpFunc(conditionData, conditionMsg)
                if jumpFunc ~= nil then
                    Hide()
                    GUIMgr:CloseMenu("MainInformation")
                    jumpFunc()
                end
            end)
        end
    else
        condition.gameObject:SetActive(false)
    end
end

function UpdateCurMilitaryRankInfo()
	local rankData = TableMgr:GetMilitaryRankTable()[tonumber(MainData.GetMilitaryRankID())]
	print("military rank id:", MainData.GetMilitaryRankID())

	if rankData ~= nil then 
		curMilitaryRankLv = rankData.RankLevel
		curMilitaryRankGrade = rankData.RankGrade
	end 
	
	local needMilitaryRankGrade =5;
	for _, ruleData in pairs(TableMgr:GetMilitaryRuleTable()) do
		if ruleData.RankLevel == curMilitaryRankLv then
			needMilitaryRankGrade = ruleData.RankGrade
		end 
	end 
	if transform~= nil then 
		if tonumber(needMilitaryRankGrade) == tonumber(curMilitaryRankGrade)  then 
			MilitaryRankUI.gradeLabelButton.text = TextMgr:GetText("ui_militaryrank_6") 
		else
			MilitaryRankUI.gradeLabelButton.text = TextMgr:GetText("build_ui8") 
		end
        local nextRankData = tableData_tMilitaryRank.data[MainData.GetMilitaryRankID() + 1]
        LoadCondition(MilitaryRankUI.condition1, nextRankData)
	end 
	
	--CheckNeedUpdate()
end 

local function ShowSelMilitaryRankInfo(lv,grade,isUp)
	-- 获得收益
	local childCount = MilitaryRankUI.effectGrid.childCount
	for i = 1, childCount  do
	--  UnityEngine.GameObject.Destroy(MilitaryRankUI.effectGrid:GetChild(i-1).gameObject)
		MilitaryRankUI.effectGrid:GetChild(i-1).gameObject:SetActive(false)
	end
	
	local rank1 = TableMgr:GetMilitaryRankData(lv,grade)
	local rank2 = TableMgr:GetMilitaryRankData(lv,grade+1)
	
	transform:Find("Container/MilitaryRank/rankinfo/info/name"):GetComponent("UILabel").text = ''
	local icon = transform:Find("Container/MilitaryRank/rankinfo/info/Texture"):GetComponent("UITexture")
	icon.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRankL/",'')
		
	
	for m = 1, 5 do
		transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)).gameObject:SetActive(false)
	end
	if rank1 == nil then 
		print("error ____ShowSelMilitaryRankInfo "..lv.." "..grade)
		return 
	end
	local seq =1
--[[
	for _, ruleData in pairs(TableMgr:GetMilitaryRuleTable()) do
		if tonumber(ruleData.RankLevel) == tonumber(lv) then
		
			local ruleData2 = nil 
			for _, ruleData1 in pairs(TableMgr:GetMilitaryRuleTable()) do
				if tonumber(ruleData1.RankLevel) == tonumber(lv)+1 then
					ruleData2 = ruleData1
				end 
			end 
			
			local showLevel = false;
			for _, ruleData in pairs(TableMgr:GetMilitaryRuleTable()) do
				if tonumber(ruleData.RankLevel) == tonumber(lv) and tonumber(ruleData.RankGrade) == tonumber(grade) then
					showLevel = true
				end 
			end 
			
			if tonumber(lv) ~= tonumber(curMilitaryRankLv) or ruleData2 == nil then 
				showLevel = false
			end 
			
			local obj = nil 
			local childCount = MilitaryRankUI.effectGrid.transform.childCount
			if childCount > tonumber(seq-1)  then
				obj = MilitaryRankUI.effectGrid.transform:GetChild(tonumber(seq-1)).gameObject
			else
				obj = NGUITools.AddChild( MilitaryRankUI.effectGrid.gameObject,MilitaryRankUI.effectItem.gameObject)
			end 
			
			seq = seq +1
			if showLevel == false then 
				
				obj:SetActive(true)
				obj.transform:Find("1").gameObject:SetActive(false)
				obj.transform:Find("2").gameObject:SetActive(true)
				obj.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("militaryrank_17")
				obj.transform:Find("2/before"):GetComponent("UILabel").text = ruleData.PlaylvlMax
				
			else 
				
				obj:SetActive(true)
				obj.transform:Find("1").gameObject:SetActive(true)
				obj.transform:Find("2").gameObject:SetActive(false)
				obj.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("militaryrank_17")
				obj.transform:Find("1/before"):GetComponent("UILabel").text = ruleData.PlaylvlMax
				obj.transform:Find("1/after"):GetComponent("UILabel").text = ruleData2.PlaylvlMax
			end 
		end 
	end 
	]]--
	
	if rank2 ~= nil then 
		local buff_values = GetEffectDataToBuffValues(rank1.RankEffectShow)
		local buff_values1 = GetEffectDataToBuffValues(rank2.RankEffectShow)
		print("ShowSelMilitaryRankInfo "..lv.." eff1 "..rank1.RankEffectShow.." eff2 "..rank2.RankEffectShow)
		
		if buff_values ~= nil then
			for i =1,#buff_values do
				local str = buff_values[i].value
				
				local str1 = buff_values1[i].value
				
				local obj = nil 
				local childCount = MilitaryRankUI.effectGrid.transform.childCount
				if childCount > tonumber(seq-1)  then
					obj = MilitaryRankUI.effectGrid.transform:GetChild(tonumber(seq-1)).gameObject
				else
					obj = NGUITools.AddChild( MilitaryRankUI.effectGrid.gameObject,MilitaryRankUI.effectItem.gameObject)
				end 
				
				seq = seq +1

				-- local obj = NGUITools.AddChild( MilitaryRankUI.effectGrid.gameObject,MilitaryRankUI.effectItem.gameObject)
				obj:SetActive(true)
				obj.transform:Find("1").gameObject:SetActive(true)
				obj.transform:Find("2").gameObject:SetActive(false)
				obj.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText(buff_values[i].buff_str) 
				obj.transform:Find("1/before"):GetComponent("UILabel").text = str 
				obj.transform:Find("1/after"):GetComponent("UILabel").text = str1
			end
		end
	
	else
		local buff_values = GetEffectDataToBuffValues(rank1.RankEffectShow)
		print("ShowSelMilitaryRankInfo "..lv.." eff1 "..rank1.RankEffectShow)
		
		if buff_values ~= nil then
			for i =1,#buff_values do
				
				local str = buff_values[i].value
				
				local obj = nil 
				local childCount = MilitaryRankUI.effectGrid.transform.childCount
				if childCount > tonumber(seq-1)  then
					obj = MilitaryRankUI.effectGrid.transform:GetChild(tonumber(seq-1)).gameObject
				else
					obj = NGUITools.AddChild( MilitaryRankUI.effectGrid.gameObject,MilitaryRankUI.effectItem.gameObject)
				end 
				
				seq = seq +1

				-- local obj = NGUITools.AddChild( MilitaryRankUI.effectGrid.gameObject,MilitaryRankUI.effectItem.gameObject)
				obj:SetActive(true)
				obj.transform:Find("2").gameObject:SetActive(true)
				obj.transform:Find("1").gameObject:SetActive(false)
				obj.transform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText(buff_values[i].buff_str) 
				obj.transform:Find("2/before"):GetComponent("UILabel").text = str 
			end
		end
	end 

	_ui.coroutines = coroutine.start(function()

	 coroutine.step()
	if transform ~= nil then 
		MilitaryRankUI.effectGrid:GetComponent("UIGrid"):Reposition()
    end
	end)

	local rankData = TableMgr:GetMilitaryRankData(lv,5)

	transform:Find("Container/MilitaryRank/rankinfo/info/name"):GetComponent("UILabel").text = TextMgr:GetText(rankData.Name)
	icon.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRankL/",rankData.Icon)
		
	print("ShowSelMilitaryRankInfo "..lv.." grade "..grade)

	for m = 1, 5 do
	
		transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)):GetComponent("TweenAlpha").enabled = false
		transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)):GetComponent("TweenScale").enabled = false

		if tonumber(grade) <= m-1 then
			transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)).gameObject:SetActive(false)
			transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite/vfx", m)).gameObject:SetActive(false)
		else
			
			transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)).gameObject:SetActive(true)
			if isUp == true and tonumber(grade)== m then 
				
				transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)):GetComponent("TweenAlpha").enabled = true
				transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)):GetComponent("TweenScale").enabled = true
				transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite/vfx", m)).gameObject:SetActive(true)
			else
				transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite/vfx", m)).gameObject:SetActive(false)
			end
		end 
	end
end


function Moba_GetEffectDataToBuffValues(Effect)
	local result ={}
	local t = string.split(Effect,';')
	for i = 1,#(t) do
		local tt = string.split(t[i],',')
		result[i] ={}
		result[i].buff_str = TableMgr:GetEquipTextDataByAddition(tt[2],tonumber(tt[3]))
		
		if Global.IsHeroPercentAttrAddition(tonumber(tt[3])) then
			if tonumber(tt[4]) >= 0 then
				result[i].value = " +"..tonumber(tt[4]).."%"
			else
				result[i].value = tonumber(tt[4]).."%"
			end
		else
			if tonumber(tt[4]) >= 0 then
				result[i].value = " +"..tonumber(tt[4])
			else
				result[i].value = tonumber(tt[4])
			end     
			
		end
		-- result[i].value = tonumber(tt[3])
		print("GetEffectDataToBuffValues "..tt[2].." "..tt[3].." "..result[i].buff_str.."==> "..TextMgr:GetText(result[i].buff_str).." "..tt[4])
	end
	return result
end

function GetEffectDataToBuffValues(Effect)
	local result ={}
	local t = string.split(Effect,';')
	for i = 1,#(t) do
		local tt = string.split(t[i],',')
		result[i] ={}
		result[i].buff_str = TableMgr:GetEquipTextDataByAddition(tt[1],tonumber(tt[2]))
		
		if Global.IsHeroPercentAttrAddition(tonumber(tt[2])) then
			if tonumber(tt[3]) >= 0 then
				result[i].value = " +"..tonumber(tt[3]).."%"
			else
				result[i].value = tonumber(tt[3]).."%"
			end
		else
			if tonumber(tt[3]) >= 0 then
				result[i].value = " +"..tonumber(tt[3])
			else
				result[i].value = tonumber(tt[3])
			end     
			
		end
		-- result[i].value = tonumber(tt[3])
		print("GetEffectDataToBuffValues "..tt[1].." "..tt[2].." "..result[i].buff_str.."==> "..TextMgr:GetText(result[i].buff_str).." "..tt[3])
	end
	return result
end


function UpdateMilitaryRankUI(isUp)

	local curLv =curMilitaryRankLv
	local curGrade =curMilitaryRankGrade 
	
	isLevelNew = false
	if curMilitaryRankGrade == 0 then 
		isLevelNew = true
	end 

   for i =1,#TableMgr:GetMilitaryRuleTable() do
		local rankData  = TableMgr:GetMilitaryRuleTable()[i]
		local index = 1
		if rankData.RankLevel == 1 or rankData.RankLevel == 2 then
			index =1
		elseif rankData.RankLevel == 3 or rankData.RankLevel == 4 or rankData.RankLevel == 5  or rankData.RankLevel == 6 then
			index =2
		elseif rankData.RankLevel == 7 or rankData.RankLevel == 8 or rankData.RankLevel == 9   then
			index =3
		elseif rankData.RankLevel == 10 or rankData.RankLevel == 11 or rankData.RankLevel == 12  or rankData.RankLevel == 13 then
			index =4
		elseif rankData.RankLevel == 14 or rankData.RankLevel == 15 or rankData.RankLevel == 16  then
			index =5
		end 
		AddRankItem(index,rankData.RankLevel,isUp,i)
		
		if i % 4 == 0 and i >= 8 then
			--MilitaryRankUI.grid:Reposition()
			--coroutine.step()
		end
	end 
   

	MilitaryRankUI.grid:Reposition()
	
	local rankData = TableMgr:GetMilitaryRankData(curLv,curGrade)
	rankData = TableMgr:GetMilitaryRankTable()[rankData.id +1]

	if rankData ~= nil then 
		ShowMilitaryRankInfo(rankData.RankLevel,rankData.RankGrade)
	else
		ShowMilitaryRankInfo(1000,1000)
	end 

	
	SelRankItem(curMilitaryRankLv,isUp)

	
	local id = tonumber(MainData.GetMilitaryRankID());

	local panel = MilitaryRankUI.scrool:GetComponent("UIPanel");
	local pos = panel.transform.localPosition
	MilitaryRankUI.scrool:MoveRelative(Vector3.New(-100 * tonumber(curLv)- pos.x+80, 0, 0))
	MilitaryRankUI.scrool:RestrictWithinBounds(true)

end
 


function AddRankItem(i,lv,isUp,seq)

    local uiGeneral = {}

	local childCount = MilitaryRankUI.grid.transform.childCount
	if childCount > tonumber(seq-1)  then
		uiGeneral.gameObject =MilitaryRankUI.grid.transform:GetChild(seq-1).gameObject
	else
		uiGeneral.gameObject = NGUITools.AddChild(MilitaryRankUI.grid.gameObject,MilitaryRankUI.ranks[i])
	end 

    
    uiGeneral.transform = uiGeneral.gameObject.transform
	
	-- print("AddRankItem "..i.." "..MilitaryRankUI.ranks[i].name.." "..uiGeneral.gameObject.name )
 
    uiGeneral.name = uiGeneral.transform:Find("name"):GetComponent("UILabel")
    uiGeneral.stars = {} 
	uiGeneral.gameObject.name = lv
	
	uiGeneral.name.text = TextMgr:GetText(TableMgr:GetMilitaryRankData(lv,5).Name)
	
	for m = 1, 5 do
		uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenAlpha").enabled = false
		uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenScale").enabled = false
	end
	
	if lv <= curMilitaryRankLv then 
		uiGeneral.transform:Find("loked").gameObject:SetActive(false)
	else 
		uiGeneral.transform:Find("loked").gameObject:SetActive(true)
	end 

	if tonumber(curMilitaryRankLv) == tonumber(lv) then 
		for m = 1, 5 do
			if tonumber(curMilitaryRankGrade) <= m-1 then
				uiGeneral.transform:Find(string.format("star/%d/Sprite", m)).gameObject:SetActive(false)
				uiGeneral.transform:Find(string.format("star/%d/Sprite/vfx", m)).gameObject:SetActive(false)
				uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenAlpha").enabled = false
				uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenScale").enabled = false
			else
				uiGeneral.transform:Find(string.format("star/%d/Sprite", m)).gameObject:SetActive(true)
				if isUp == true and tonumber(curMilitaryRankGrade) == m then
					uiGeneral.transform:Find(string.format("star/%d/Sprite/vfx", m)).gameObject:SetActive(true)
					
					uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenAlpha").enabled = true
					uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenScale").enabled = true
				else
					uiGeneral.transform:Find(string.format("star/%d/Sprite/vfx", m)).gameObject:SetActive(false)
					uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenAlpha").enabled = false
					uiGeneral.transform:Find(string.format("star/%d/Sprite", m)):GetComponent("TweenScale").enabled = false
				end 
			end 
		end

	elseif tonumber(curMilitaryRankLv) > tonumber(lv) then 
		for m = 1, 5 do
			uiGeneral.transform:Find(string.format("star/%d/Sprite", m)).gameObject:SetActive(true)
			uiGeneral.transform:Find(string.format("star/%d/Sprite/vfx", m)).gameObject:SetActive(false)
		end
	else
		for m = 1, 5 do
			uiGeneral.transform:Find(string.format("star/%d/Sprite", m)).gameObject:SetActive(false)
			uiGeneral.transform:Find(string.format("star/%d/Sprite/vfx", m)).gameObject:SetActive(false)
		end
	end 
	
	if isUp == true and  tonumber(curMilitaryRankLv) == tonumber(lv) then
		if isLevelNew then 
			uiGeneral.transform:Find("frame/Texture/vfx").gameObject:SetActive(true)
			uiGeneral.transform:Find("frame/Texture/glow").gameObject:SetActive(false)
			uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("TweenAlpha").enabled = false
			uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("UITexture").alpha = 0
		else 
			uiGeneral.transform:Find("frame/Texture/vfx").gameObject:SetActive(false)
			uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("UITexture").alpha = 1
			uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("TweenAlpha").enabled = true
			uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("TweenAlpha").duration = 0.6
			uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("TweenAlpha"):PlayForward(true)
			uiGeneral.transform:Find("frame/Texture/glow").gameObject:SetActive(true)
		end 
	else
		uiGeneral.transform:Find("frame/Texture/glow").gameObject:SetActive(false)
		uiGeneral.transform:Find("frame/Texture/vfx").gameObject:SetActive(false)
		uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("TweenAlpha").enabled = false
		uiGeneral.transform:Find("frame/Texture/glow"):GetComponent("UITexture").alpha = 0
	end 

	local icon = uiGeneral.transform:Find("frame/Texture"):GetComponent("UITexture")
	icon.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRankL/",'')
		
	for _, ruleData in pairs(TableMgr:GetMilitaryRuleTable()) do
		if tonumber(ruleData.RankLevel) == tonumber(lv) then
			for _, rankData in pairs(TableMgr:GetMilitaryRankTable()) do
				if tonumber(rankData.RankLevel) == tonumber(ruleData.RankLevel) and tonumber(rankData.RankGrade) == tonumber(ruleData.RankGrade) then
					icon.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRankL/",rankData.Icon)
				end
			end
		end
	end
				   
    UIUtil.SetClickCallback(uiGeneral.gameObject, function()
        SelRankItem(uiGeneral.gameObject.name,false)
    end)

end

function UpdateMoney()
	if MilitaryRankUI.item1Num == nil then 
		return 
	end
	MilitaryRankUI.item1Num.text  = MoneyListData.GetReputation()
	MilitaryRankUI.item2Num.text = ItemListData.GetItemCountByBaseId(15009)

	local itemdata = ItemListData.GetItemDataByBaseId(19501)
	
	if itemdata ~= nil then 
		--MilitaryRankUI.item1Icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
	end 
	
	itemdata = ItemListData.GetItemDataByBaseId(15009)
	if itemdata~= nil then
		--MilitaryRankUI.item2Icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
	end 
	-- CheckNeedUpdate()
	
	local rankData = TableMgr:GetMilitaryRankData(curMilitaryRankLv,curMilitaryRankGrade)
	rankData = TableMgr:GetMilitaryRankTable()[rankData.id +1]
	
	if rankData ~= nil then 
		ShowMilitaryRankInfo(rankData.RankLevel,rankData.RankGrade,false)
	else
		ShowMilitaryRankInfo(1000,1000,false)
	end
end 

function SelRankItem(lv,isUp)

	local childCount = MilitaryRankUI.grid.transform.childCount
		for i = 1, childCount  do
			local obj = MilitaryRankUI.grid.transform:GetChild(i-1).gameObject
			if tonumber(obj.name) == tonumber(lv) then 
				obj.transform:Find("selected").gameObject:SetActive(true)
			else
				obj.transform:Find("selected").gameObject:SetActive(false)
			end 
		end

	
	if tonumber(lv) < tonumber(curMilitaryRankLv) then 
		
		for _, ruleData in pairs(TableMgr:GetMilitaryRuleTable()) do
			if tonumber(ruleData.RankLevel) == tonumber(lv) then
				ShowSelMilitaryRankInfo(lv,ruleData.RankGrade)
			end
		end
		MilitaryRankUI.upgradeUI:SetActive(false)
		MilitaryRankUI.gradeButton.gameObject:SetActive(false)
		MilitaryRankUI.condition2.gameObject:SetActive(false)
	elseif tonumber(lv) == tonumber(curMilitaryRankLv) then
		ShowSelMilitaryRankInfo(curMilitaryRankLv,curMilitaryRankGrade,isUp)
		
		local rankData = TableMgr:GetMilitaryRankData(curMilitaryRankLv,curMilitaryRankGrade)
		rankData = TableMgr:GetMilitaryRankTable()[rankData.id +1]
		
		if rankData ~= nil then 
			ShowMilitaryRankInfo(rankData.RankLevel,rankData.RankGrade)
			MilitaryRankUI.upgradeUI:SetActive(true)
			MilitaryRankUI.gradeButton.gameObject:SetActive(true)
		
		else
			ShowMilitaryRankInfo(1000,1000)
			MilitaryRankUI.upgradeUI:SetActive(false)
			MilitaryRankUI.gradeButton.gameObject:SetActive(false)
		end
		
		MilitaryRankUI.condition2.gameObject:SetActive(false)
		--ShowMilitaryRankInfo(curMilitaryRankLv,curMilitaryRankGrade)
	else
		for _, ruleData in pairs(TableMgr:GetMilitaryRuleTable()) do
			if tonumber(ruleData.RankLevel) == tonumber(lv) then
				ShowSelMilitaryRankInfo(lv,ruleData.RankGrade)
				for m = 1, 5 do
					transform:Find(string.format("Container/MilitaryRank/rankinfo/info/star/%d/Sprite", m)).gameObject:SetActive(false)
				end
			end
		end
		MilitaryRankUI.upgradeUI:SetActive(false)
		MilitaryRankUI.gradeButton.gameObject:SetActive(false)
		-- ShowSelMilitaryRankInfo(curMilitaryRankLv,curMilitaryRankGrade)
		
		MilitaryRankUI.condition2.gameObject:SetActive(true)

		local rankData = TableMgr:GetMilitaryRankData(tonumber(lv), 0)
		LoadCondition(MilitaryRankUI.condition2, rankData)
	end 
	
end 


