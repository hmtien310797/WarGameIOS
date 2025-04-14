module("SevenDay", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local checkClose = false

local _ui

local selectedDay
local loginShow = false

local closeCallback
function SetCloseCallback(callback)
    closeCallback = callback
end

function Hide()
    Global.CloseUI(_M)
    if closeCallback ~= nil then
        closeCallback()
        closeCallback = nil
    end
end

function HideAll()
    DailyActivity.CloseSelf()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function CloseSelf()
    Hide()
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function LoadReward(listGrid, rewardMsg)
    Global.LogDebug(_M, "LoadReward", listGrid, rewardMsg)

    NGUITools.DestroyChildren(listGrid.transform)
    local heroList = rewardMsg.rewardInfo.heros
    for i, v in ipairs(heroList) do
        local oldScale = _ui.heroPrefab.transform.localScale
        local heroTransform = NGUITools.AddChild(listGrid.gameObject, _ui.heroPrefab).transform
        heroTransform.gameObject.name = _ui.heroPrefab.name .. i
        heroTransform.localScale = Vector3(0.6,0.6,1)
        local hero = {}

        HeroList.LoadHeroObject(hero, heroTransform)
        local heroData = TableMgr:GetHeroData(v.id)
        local heroMsg = Common_pb.HeroInfo() 
        heroMsg.star = v.star
        heroMsg.level = v.level
        heroMsg.num = v.num
        HeroList.LoadHero(hero, heroMsg, heroData)
        hero.nameLabel.gameObject:SetActive(false)

        SetClickCallback(hero.btn.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
            end
        end)
    end
    for i, v in ipairs(rewardMsg.rewardInfo.armys) do
        local reward = v
        local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
        local itemprefab = NGUITools.AddChild(listGrid.gameObject, _ui.itemPrefab).transform
        itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + reward.level)
        itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
        itemprefab:Find("have"):GetComponent("UILabel").text = reward.num
        itemprefab:Find("num").gameObject:SetActive(false)
        SetClickCallback(itemprefab.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
            end
        end)
    end
    local itemList = rewardMsg.rewardInfo.items
    for i, v in ipairs(itemList) do
        local itemTransform = NGUITools.AddChild(listGrid.gameObject, _ui.itemPrefab).transform
        itemTransform.gameObject.name = _ui.itemPrefab.name .. i
        local itemData = TableMgr:GetItemData(v.id)
        local item = {}
        UIUtil.LoadItemObject(item, itemTransform)
        UIUtil.LoadItem(item, itemData, v.num)

        SetClickCallback(item.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
            end
        end)
    end
    listGrid:Reposition()
end

function IsSevenDayOver()
	local sevenDayData = SevenDayData.GetData()
	local day = SevenDayData.GetUnTakenDay() or math.min(7, SevenDayData.GetLastTakenDay() + 1)
	--print("________________"..day)
	if tonumber(day)  == 7 then 
		for _, v in ipairs(sevenDayData) do
			if tonumber(v.day) == 7 and tonumber(v.status)==3 then 
				return true
			end 
			--print("_______"..v.day.." "..v.status)
		end
	end 
	return false
end 

function LoadUI(loadReward)
    Global.LogDebug(_M, "LoadUI", loadReward, selectedDay)

    local sevenDayData = SevenDayData.GetData()

    local untakenDay = SevenDayData.GetUnTakenDay()
    local lastTakenDay = SevenDayData.GetLastTakenDay() or 0
    local isFirstWeek = SevenDayData.IsFirst()
	
	if IsSevenDayOver()== true and checkClose then 
		checkClose = false
		-- WelfareAll.Hide()
		--WelfareAll.DelTab("ActivityName_2")
		Global.CloseUI(_M)
		return 
	end 

    if isFirstWeek then
        _ui.tips_firstWeek:SetActive(true)

        if untakenDay and selectedDay <= untakenDay then
            _ui.tips_first7Days.gameObject:SetActive(false)
        else
            _ui.tips_first7Days.gameObject:SetActive(true)
            _ui.tips_first7Days.text = TextMgr:GetText(string.format("SevenDay_day%d", math.max(lastTakenDay + 1, selectedDay)))
        end
    else
        _ui.tips_firstWeek:SetActive(false)
        _ui.tips_first7Days.gameObject:SetActive(false)
    end

    if selectedDay <= lastTakenDay then
        _ui.btnGet.gameObject:SetActive(false)
        _ui.tips_taken:SetActive(true)
    else
        _ui.btnGet.gameObject:SetActive(true)
        _ui.tips_taken:SetActive(false)

        if selectedDay == untakenDay then
            _ui.btnGet:GetComponent("UIButton").isEnabled = true
            _ui.btnLabel.text = TextMgr:GetText("mail_ui12")
        else
            _ui.btnGet:GetComponent("UIButton").isEnabled = false
            _ui.btnLabel.text = selectedDay - lastTakenDay == 1 and TextMgr:GetText("tomorrow_reward") or TextMgr:GetText("Fort_ui1")
        end
    end

    for _, v in ipairs(sevenDayData) do
        local rewardIndex = v.day
        local reward = _ui.rewardList[rewardIndex]
        for ii, vv in pairs(reward.statusList) do
            vv.gameObject:SetActive(ii == v.status)
        end
        reward.selected.gameObject:SetActive(selectedDay == rewardIndex)


        if reward.slot0 then
            reward.slotSprite.gameObject:SetActive(not isFirstWeek)
            reward.slot0:SetActive(isFirstWeek)
        end
        
        if loadReward and selectedDay == rewardIndex then
			local listTransform = _ui.grid:GetChild(v.day - 1)
			local listGrid = listTransform:Find("Grid"):GetComponent("UIGrid")
			LoadReward(listGrid, v)
        end
		
		-- if selectedDay == rewardIndex then
		-- 	 _ui.btnGet.gameObject:SetActive(v.status == ActivityMsg_pb.SevenRewardStatus_UnTaken)
		-- end
    end
	
	if IsSevenDayOver()== true then 
		_ui.tips_first7Days.gameObject:SetActive(false)
	end 
	
	if loadReward then
		coroutine.start(function()
			for _, v in ipairs(sevenDayData) do
				if _ui ~= nil then
					local rewardIndex = v.day
					local listTransform = _ui.grid:GetChild(v.day - 1)
					local listGrid = listTransform:Find("Grid"):GetComponent("UIGrid")
					if selectedDay ~= rewardIndex then
						LoadReward(listGrid, v)
					end
				end
				coroutine.step()
			end
		end)
	end
	
	_ui.rewardList[7].slotSprite.spriteName = SevenDayData.IsFirst() and "icon_reward_08" or "icon_reward_07"
end

function LoadUIOld(loadReward)
    local sevenDayData = SevenDayData.GetData()
    for _, v in ipairs(sevenDayData) do
        local rewardIndex = v.day
        local reward = _ui.rewardList[rewardIndex]
        for ii, vv in pairs(reward.statusList) do
            vv.gameObject:SetActive(ii == v.status)
        end
        reward.selected.gameObject:SetActive(selectedDay == rewardIndex)
		local listTransform = _ui.grid:GetChild(v.day - 1)
		local listGrid = listTransform:Find("Grid"):GetComponent("UIGrid")
        if loadReward then
			LoadReward(listGrid, v)
		end
		
        if selectedDay == rewardIndex then
            _ui.btnGet.gameObject:SetActive(v.status == ActivityMsg_pb.SevenRewardStatus_UnTaken)
        end
    end
end

function Awake()
    _ui = {}
    _ui.listPrefab = transform:Find("listinfo_reward").gameObject
	_ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    _ui.bigGrid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.btnGet = transform:Find("Container/bg_frane/btn_get")
    _ui.btnLabel = transform:Find("Container/bg_frane/btn_get/txt_get"):GetComponent("UILabel")
    _ui.tips_firstWeek = transform:Find("Container/bg_frane/des").gameObject
    _ui.tips_first7Days = transform:Find("Container/bg_frane/daily/day des"):GetComponent("UILabel")
    _ui.tips_taken = transform:Find("Container/bg_frane/has been").gameObject

    local scrollView = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
    local panel = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIPanel")
    local rewardWidth = panel.finalClipRegion.z - panel.clipSoftness.x - panel.clipSoftness.y
    UIUtil.AddDelegate(scrollView, "onMomentumMove", function()
        selectedDay = Mathf.Round(panel.clipOffset.x / rewardWidth) + 1
        selectedDay = Mathf.Clamp(selectedDay, 1, 7)
        LoadUI(false)
    end)

    SetClickCallback(_ui.btnGet.gameObject, function()
        local req = ActivityMsg_pb.MsgTakeSevenRewardRequest()
        Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeSevenRewardRequest, req, ActivityMsg_pb.MsgTakeSevenRewardResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.ShowError(msg.code)
            else
                AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
                GUIMgr:SendDataReport("reward", "TakeSevenReward:" ..msg.day, "".. MoneyListData.ComputeDiamond(msg.freshInfo.money.money))
                MainCityUI.UpdateRewardData(msg.freshInfo)
                SevenDayData.SetRewardTaken(msg.day)

				checkClose = true
                selectedDay = Mathf.Clamp(selectedDay + 1, 1, 7)

                scrollView:SetDragAmount((selectedDay - 1) / 6, 0.5, false)
				if _ui ~= nil then 
					Global.ShowReward(msg.rewardInfo, _ui.btnGet.gameObject)
				end 
				LoadUI(false)
				
                ActivityData.RequestRedList(ActivityData.GetListData())
                --MainCityUI.UpdateWelfareNotice(3002)
                DailyActivityData.ProcessActivity()
            end
        end)
    end)

    local btnClose = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(btnClose.gameObject, function() HideAll() end)
    _ui.rewardList = {}
    for i = 1, 7 do
        local reward = {}
        reward.transform = transform:Find(string.format("Container/bg_frane/daily/day%d", i))
        reward.selected = transform:Find(string.format("Container/bg_frane/daily/day%d/selected", i))
        local statusList = {}
        statusList[ActivityMsg_pb.SevenRewardStatus_Cannot] = transform:Find(string.format("Container/bg_frane/daily/day%d/content/can not collect", i))
        statusList[ActivityMsg_pb.SevenRewardStatus_UnTaken] = transform:Find(string.format("Container/bg_frane/daily/day%d/content/can collect", i))
        statusList[ActivityMsg_pb.SevenRewardStatus_Taken] = transform:Find(string.format("Container/bg_frane/daily/day%d/content/collected", i))
        reward.statusList = statusList
        reward.slotSprite = transform:Find(string.format("Container/bg_frane/daily/day%d/content/slot", i)):GetComponent("UISprite")

        if i > 1 and i < 7 then
            reward.slot0 = transform:Find(string.format("Container/bg_frane/daily/day%d/content/slot0", i)).gameObject
        end

        _ui.rewardList[i] = reward
        local listGameObject = NGUITools.AddChild(_ui.grid.gameObject, _ui.listPrefab)
        listGameObject.name = _ui.listPrefab.name .. i
        SetClickCallback(reward.transform.gameObject, function()
            selectedDay = i
            scrollView:SetDragAmount((selectedDay - 1) / 6, 0.5, false)
            LoadUI(false)
        end)
    end
    _ui.grid:Reposition()
    _ui.mask = transform:Find("mask").gameObject
    SetClickCallback(_ui.mask, function()
        HideAll()
    end)
    scrollView:SetDragAmount((selectedDay - 1) / 6, 0.5, false)
    LoadUI(true)
    SevenDayData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Close()
    SevenDayData.RemoveListener(LoadUI)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show()
    selectedDay = SevenDayData.GetUnTakenDay() or math.min(7, SevenDayData.GetLastTakenDay() + 1)
    if selectedDay == nil then
        print("error:无法获取当前领奖天数!!!!!!!!")
        return
    end
    Global.OpenUI(_M)
    SevenDayData.RequestData()
end

function CheckLoginShow()
	FunctionListData.IsFunctionUnlocked(1, function(isactive)
		if isactive then
			if ActivityData.HasActivity(_M) and not SevenDayData.HasTakenReward() then
		        Show()
		        return true
		    else
		    	if closeCallback ~= nil then
					closeCallback()
					closeCallback = nil
				end
		    end
		else
			if closeCallback ~= nil then
				closeCallback()
				closeCallback = nil
			end
			return false
		end
	end)
end

function Refresh()
    LoadUI(true)
end

