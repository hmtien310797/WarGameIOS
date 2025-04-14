module("ThirtyDay", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local Format = System.String.Format
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _ui

local loginShowed = false

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

function CloseSelf()
    Hide()
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

local function LoadReward(reward, rewardMsg)
    local itemList = rewardMsg.rewardInfo.items
    local heroList = rewardMsg.rewardInfo.heros
    local item = reward.item
    local hero =reward.hero
    if #itemList > 0 then
        local itemMsg = itemList[1]
        local itemData = TableMgr:GetItemData(itemMsg.id)
        UIUtil.LoadItem(item, itemData, itemMsg.num)

        item.gameObject:SetActive(true)
        hero.transform.gameObject:SetActive(false)

        UIUtil.SetClickCallback(item.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
            end
        end)
    elseif #heroList > 0 then
        local heroMsg = heroList[1]
        local heroData = TableMgr:GetHeroData(heroMsg.id)
        local msg = Common_pb.HeroInfo() 
        msg.star = heroMsg.star
        msg.level = heroMsg.level
        HeroList.LoadHero(hero, msg, heroData)

        item.gameObject:SetActive(false)
        hero.transform.gameObject:SetActive(true)

        UIUtil.SetClickCallback(hero.btn.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
            end
        end)
    end
    if rewardMsg.vipLevel > 0 then
        reward.vipBg.gameObject:SetActive(true)
        reward.vipLabel.text = Format(TextMgr:GetText(Text.ui_activity_des5), rewardMsg.vipLevel, rewardMsg.vipMulti)
    else
        reward.vipBg.gameObject:SetActive(false)
    end
end

function LoadThirtData()
    local thirtyDayData = ThirtyDayData.GetData()
   
    local startday = ThirtyDayData.GetStartDay()
    local day = ThirtyDayData.GetNdays()--ThirtyDayData.GetDay()
    local taken = ThirtyDayData.GetTaken()
    local resetDay = ThirtyDayData.GetResetDay()
    _ui.resetLabel.text = Format(TextMgr:GetText("VIP_ui103"), ThirtyDayData.GetTakenDays())
	_ui.selectedShine.gameObject:SetActive(false)
    local maxDay = 0
    local today = day--taken and day or day + 1
    local takenDate = ThirtyDayData.GetTakenDate()
    for _, v in ipairs(thirtyDayData) do
        if v.day > maxDay then
            maxDay = v.day
        end
        local rewardIndex = v.day
        local reward = _ui.rewardList[rewardIndex]
		if reward ~= nil then
			local listTransform = _ui.grid:GetChild(v.day - 1)
			LoadReward(reward, v)
			--reward.selected.gameObject:SetActive(today == rewardIndex)
            reward.check.gameObject:SetActive(takenDate[rewardIndex])
            reward.dayLabel.gameObject:SetActive(not takenDate[rewardIndex])
            reward.geted.root.gameObject:SetActive(takenDate[rewardIndex])
            reward.buqian.gameObject:SetActive(not takenDate[rewardIndex] and rewardIndex < day and rewardIndex >= startday)
            reward.transform.gameObject:SetActive(true)
            reward.fulibao.gameObject:SetActive(v.effect == 1 and not takenDate[rewardIndex])
            if not takenDate[rewardIndex] and rewardIndex < day and rewardIndex >= startday then
                SetClickCallback(reward.transform.gameObject, function()
                    MessageBox.Show(TextMgr:GetText("ui_buqian_1"), function()
                        ThirtyDayData.RequestBuqian(rewardIndex)
                    end, function() end,nil,nil,nil,nil,nil,"",ThirtyDayData.GetRetakeCose())
                end)
            else
                SetClickCallback(reward.transform.gameObject, function() end)
            end
			
			if today == rewardIndex then
				_ui.selectedShine.gameObject:SetActive(true)
				_ui.selectedShine.localPosition = reward.transform.localPosition + _ui.grid.transform.localPosition + Vector3(0,5,0)
			end
		end
    end
    for i = #thirtyDayData + 1, #_ui.rewardList do
        _ui.rewardList[i].transform.gameObject:SetActive(false)
    end
    local canTake = today <= maxDay
    _ui.todayUI.btnGet.gameObject:SetActive(not taken)
    _ui.todayUI.takenLabel.gameObject:SetActive(taken)
    _ui.todayUI.btnGet.normalSprite = canTake and "btn_2" or "btn_4"
    SetClickCallback(_ui.todayUI.btnGet.gameObject, function()
        if canTake then
            local req = ActivityMsg_pb.MsgTakeMonthRewardRequest()
            req.nonseries = 1
            Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTakeMonthRewardRequest, req, ActivityMsg_pb.MsgTakeMonthRewardResponse, function(msg)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.ShowError(msg.code)
                else
                    local count = _ui.grid.transform.childCount
                    for i = 1, count do
                        if i== today then
                            _ui.grid.transform:GetChild(i-1):Find("bg_geted/icon_mask"):GetComponent("TweenScale").enabled = true                  
                        end
                    end
                    AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
                    GUIMgr:SendDataReport("reward", "TakeMonthReward:" ..msg.day, "".. MoneyListData.ComputeDiamond(msg.freshInfo.money.money))
                    MainCityUI.UpdateRewardData(msg.freshInfo)
                    ThirtyDayData.SetTakenDate(msg.rewardDate)
                    ThirtyDayData.SetDay(msg.day)
                    ThirtyDayData.SetTaken(msg.taken)
                    Global.ShowReward(msg.rewardInfo, _ui.todayUI.btnGet.gameObject)
                    ActivityData.RequestRedList(ActivityData.GetListData())
                    --MainCityUI.UpdateWelfareNotice(3003)
                    DailyActivityData.ProcessActivity()
                end
            end)
        else
            FloatText.Show(TextMgr:GetText(Text.login_hint16))
        end
    end)
    _ui.leiji_slider.value = ThirtyDayData.GetTakenDays() / maxDay
    for i, v in ipairs(ThirtyDayData.GetAccuReward()) do
        _ui.leiji_baoxiang[i].transform.gameObject:SetActive(true)
        _ui.leiji_baoxiang[i].icon.spriteName = v.data.icon .. (v.taked and "open" or "done")
        _ui.leiji_baoxiang[i].sfx.gameObject:SetActive(ThirtyDayData.GetTakenDays() >= v.data.accdays and not v.taked)
        _ui.leiji_baoxiang[i].num.text = v.data.accdays
        _ui.leiji_baoxiang[i].transform.localPosition = Vector3(v.data.accdays / maxDay * 585, 12, 0)
        SetClickCallback(_ui.leiji_baoxiang[i].icon.gameObject, function()
            RechargeRewards.Show(v.data.rewardInfo, function()
                ThirtyDayData.RequestAccuReward(v.data.accdays)
            end, (ThirtyDayData.GetTakenDays() >= v.data.accdays and not v.taked) and 2 or (v.taked and 3 or 1))
        end)
    end
    return today
end


local function LoadUI(loadIndex , loadNum , grid)
	for i = loadIndex, loadNum do
        local rewardTransform = NGUITools.AddChild(grid.gameObject, _ui.rewardPrefab).transform
        local reward = {}
        reward.transform = rewardTransform
        reward.vipBg = rewardTransform:Find("bg_vip")
        reward.vipLabel = rewardTransform:Find("bg_vip/txt_vip"):GetComponent("UILabel")
        --reward.selected = rewardTransform:Find("bg_shine")
        reward.check = rewardTransform:Find("bg_geted")
        reward.dayLabel = rewardTransform:Find("txt_day"):GetComponent("UILabel")
        reward.geted = {}
        reward.geted.root = rewardTransform:Find("bg_geted")
        reward.geted.dayLabel = rewardTransform:Find("bg_geted/txt_day (1)"):GetComponent("UILabel")
        
        reward.geted.root.gameObject:SetActive(false)

        reward.geted.dayLabel.text = i
        reward.dayLabel.text = i

        reward.buqian = rewardTransform:Find("bg_buqian")
        reward.fulibao = rewardTransform:Find("Item_CommonNew/Texture/fulibao")
        local item = {}
        local itemTransform = rewardTransform:Find("Item_CommonNew")
        UIUtil.LoadItemObject(item, itemTransform)

        local heroTransform = rewardTransform:Find("listhero")
        local hero = {}
        HeroList.LoadHeroObject(hero, heroTransform)

        reward.item = item
        reward.hero = hero
        _ui.rewardList[i] = reward
    end
    grid:Reposition()
end
 
local function InitUI()
	local loadNumStep = 15
	local loadNumMax = 31
	coroutine.start(function()
		LoadUI(1 , loadNumStep , _ui.grid)
		LoadThirtData()
		coroutine.step()
		if _ui ~= nil then
			LoadUI(loadNumStep + 1, loadNumMax , _ui.grid)
            _ui.scrollview:MoveRelative(Vector3(0, math.floor(LoadThirtData() / 7) * _ui.grid.cellHeight, 0))
            _ui.scrollview:Scroll(0.01)
		end
	end)
end

function Awake()
    _ui = {}
    _ui.rewardPrefab = ResourceLibrary.GetUIPrefab("ActivityStage/list_reward")
    _ui.resetLabel = transform:Find("Container/bg_frane/bg_right/txt_refresh"):GetComponent("UILabel")
    local mask = transform:Find("mask").gameObject
    SetClickCallback(mask, function()
        HideAll()
    end)

    _ui.scrollview = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
    _ui.grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.selectedShine = transform:Find("Container/bg_frane/bg_mid/Scroll View/bg_shine")
    _ui.rewardList = {}
    

    do
        _ui.todayUI = {}
        _ui.todayUI.btnGet = transform:Find("Container/bg_frane/bg_right/btn_get"):GetComponent("UIButton")
        _ui.todayUI.takenLabel = transform:Find("Container/bg_frane/bg_right/txt_geted"):GetComponent("UILabel")
    end

    _ui.leiji_slider = transform:Find("Container/bg_frane/bar"):GetComponent("UISlider")
    _ui.leiji_foreground = transform:Find("Container/bg_frane/bar/foreground")
    _ui.leiji_box = transform:Find("Container/bg_frane/bar/box")
    _ui.leiji_box.localPosition = Vector3(_ui.leiji_box.localPosition.x, _ui.leiji_box.localPosition.y, _ui.leiji_box.localPosition.z)
    _ui.leiji_baoxiang = {}
    for i = 1, 5 do
        _ui.leiji_baoxiang[i] = {}
        _ui.leiji_baoxiang[i].transform = transform:Find(string.format("Container/bg_frane/bar/box/%d", i))
        _ui.leiji_baoxiang[i].icon = _ui.leiji_baoxiang[i].transform:Find("icon"):GetComponent("UISprite")
        _ui.leiji_baoxiang[i].transform:Find("icon"):GetComponent("UIButton").enabled = false
        _ui.leiji_baoxiang[i].sfx = _ui.leiji_baoxiang[i].transform:Find("icon/ShineItem")
        _ui.leiji_baoxiang[i].num = _ui.leiji_baoxiang[i].transform:Find("num"):GetComponent("UILabel")
    end

    local btnClose = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(btnClose.gameObject, function() HideAll() end)
    --LoadUI()
	InitUI()
    ThirtyDayData.AddListener(LoadThirtData)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Close()
    ThirtyDayData.RemoveListener(LoadThirtData)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui = nil
end

function Show()
    ThirtyDayData.RequestData()
    Global.OpenUI(_M)
end

function CheckLoginShow()
	FunctionListData.IsFunctionUnlocked(2, function(isactive)
		if isactive then
			if ActivityData.HasActivity(_M) and not ThirtyDayData.HasTakenReward() then
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
    LoadThirtData()
end
