module("LuckyRotary", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GPlayerPrefs = UnityEngine.PlayerPrefs

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local Format = System.String.Format

local _ui, UpdateUI, UpdateTop, UpdateDown, isInView, finishDraw
local timer = 0

local moveType --1普通 2加速 3高速 4减速 5停止
local moveStep
local normalSetp = 1
local maxStep = 0.001
local addStep = 0.7
local subStep = 0.15
local minStep = 0.3
local fadeout = 5
local index = 0

local drawType

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
    end
    if go.name == "BigCollider(Clone)" then
        if UICamera.lastEventPosition.x > 254 and UICamera.lastEventPosition.x < 616 and UICamera.lastEventPosition.y > 134 and UICamera.lastEventPosition.y < 304 then
            finishDraw()
            return
        end
    end
	local param = GetParameter(go)
	if param ~= nil then
		local param = param:split("_")
		if param[1] == "item" then
			local itemdata = TableMgr:GetItemData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			else
			    if itemTipTarget == go then
			        Tooltip.HideItemTip()
			    else
			        itemTipTarget = go
			        Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			    end
			end
		else
			local itemdata = TableMgr:GetHeroData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		        end
		    end
		end
	else
		Tooltip.HideItemTip()
	end
end

function Hide()
	Global.CloseUI(_M)
end

function HideAll()
    WelfareAll.Hide()
end

function Refresh()
    if isInView then
        UpdateUI()
    end
end

function Close()
    _ui = nil
    isInView = nil
    drawType = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    CountDown.Instance:Remove("LuckyRotary")
    CountDown.Instance:Remove("LuckyRotary_free")	
	LuckyRotaryData.RemoveListener(UpdateDown)
end

function Show(activityId,templet)
	--[[if activityId == nil or templet == nil then
		print("############### Activity is null ###############")
		return
	end]]
	if _ui == nil then
		_ui = {}
	end
	if _ui.activity == nil then
		_ui.activity = {}
	else
		if _ui.activity.activityId == activityId and _ui.activity.templet == templet then
			return
		end
	end
	_ui.activity.activityId = activityId
	_ui.activity.templet = templet
	
    if isInView then
        UpdateUI()
    else
        Global.OpenUI(_M)
        isInView = true
    end
	print(_ui.activity.activityId, _ui.activity.templet)
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.time = transform:Find("Container/bg_frane/bg/left/mid/activitytime"):GetComponent("UILabel")
    _ui.help = transform:Find("Container/bg_frane/bg/right/top/wenhao").gameObject	
    _ui.helpbanner = transform:Find("Container/DailyActivity_Help").gameObject
    _ui.helpbanner_container = transform:Find("Container/DailyActivity_Help/Container").gameObject
    _ui.helpbanner_close = transform:Find("Container/DailyActivity_Help/Container/bg_frane/bg_top/btn_close").gameObject
	_ui.right_scroll = transform:Find("Container/bg_frane/bg/right/back/base/Scroll View"):GetComponent("UIScrollView")
	_ui.right_grid = transform:Find("Container/bg_frane/bg/right/back/base/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.right_item = transform:Find("Container/bg_frane/bg/right/back/base/list")
    _ui.right_times = transform:Find("Container/bg_frane/bg/right/top/number"):GetComponent("UILabel")
    _ui.grade = transform:Find("Container/bg_frane/bg/left/mid/grade"):GetComponent("UILabel")
    _ui.grade.gameObject:SetActive(false)

    _ui.btn_once = transform:Find("Container/bg_frane/bg/left/mid/button1").gameObject
    _ui.once_gold = transform:Find("Container/bg_frane/bg/left/mid/button1/gold_num"):GetComponent("UILabel")
    _ui.once_label = transform:Find("Container/bg_frane/bg/left/mid/button1/text"):GetComponent("UILabel")
    _ui.once_gold_icon = transform:Find("Container/bg_frane/bg/left/mid/button1/gold")
    _ui.once_free = transform:Find("Container/bg_frane/bg/left/mid/button1/freetime"):GetComponent("UILabel")
    _ui.once_free_label = transform:Find("Container/bg_frane/bg/left/mid/button1/text_free")
    _ui.once_red = transform:Find("Container/bg_frane/bg/left/mid/button1/red")
    _ui.btn_ten = transform:Find("Container/bg_frane/bg/left/mid/button2").gameObject
    _ui.ten_gold = transform:Find("Container/bg_frane/bg/left/mid/button2/gold_num"):GetComponent("UILabel")
    _ui.ten_label = transform:Find("Container/bg_frane/bg/left/mid/button2/text"):GetComponent("UILabel")

    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    _ui.left_items = {}
    for i = 1, 14 do
        local item = {}
        item.transform = transform:Find(string.format("Container/bg_frane/bg/left/%d", i))
        item.item_obj = NGUITools.AddChild(item.transform.gameObject, _ui.item)
        item.item_obj:SetActive(false)
        item.hero_obj = NGUITools.AddChild(item.transform.gameObject, _ui.hero)
        item.hero_obj:SetActive(false)
        item.kuang = item.transform:Find("kuang"):GetComponent("UISprite")
        item.number = item.transform:Find("number"):GetComponent("UILabel")
        item.cha = item.transform:Find("x").gameObject
        item.alpha = 0
        item.kuang.color = Color(1, 1, 1, item.alpha)
        item.kuang.gameObject:SetActive(true)
        _ui.left_items[i] = item
    end

    _ui.btn_rank = transform:Find("Container/bg_frane/bg/right/back/button2").gameObject
    
	AddDelegate(UICamera, "onPress", OnUICameraPress)
    LuckyRotaryData.AddListener(UpdateDown)
    NGUITools.BringForward(_ui.helpbanner)
end

local function ResetItems()
    for i = 1, 14 do
        _ui.left_items[i].last = false
        _ui.left_items[i].num = 0
        _ui.left_items[i].cha:SetActive(false)
        _ui.left_items[i].number.gameObject:SetActive(false)
    end
end

function Start()
    SetClickCallback(_ui.mask, HideAll)
	SetClickCallback(_ui.help, function()
        _ui.helpbanner:SetActive(true)
        NGUITools.BringForward(_ui.helpbanner)
    end)
    SetClickCallback(_ui.helpbanner_container, function()
        _ui.helpbanner:SetActive(false)
    end)
    SetClickCallback(_ui.helpbanner_close, function()
        _ui.helpbanner:SetActive(false)
    end)
    SetClickCallback(_ui.btn_rank, function()
        MessageBox.Show(TextMgr:GetText("common_ui1"))
    end)
    _ui.btn_rank:GetComponent("UIButton").normalSprite = "btn_4"
    SetClickCallback(_ui.btn_once, function()
        LuckyRotaryData.DrawRequest(ActivityMsg_pb.LotteryDrawType_Once, function(response)
            moveType = 2
            drawType = ActivityMsg_pb.LotteryDrawType_Once
            ResetItems()
            _ui.left_items[response.drawResult[1]].last = true
            _ui.drawResult = response.drawResult
            _ui.ShowReward = response
            NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/BigCollider"))
        end)
    end)
    SetClickCallback(_ui.btn_ten, function()
        local beginrequest = function()
            LuckyRotaryData.DrawRequest(ActivityMsg_pb.LotteryDrawType_TenTimes, function(response)
                moveType = 2
                drawType = ActivityMsg_pb.LotteryDrawType_TenTimes
                ResetItems()
                _ui.left_items[response.drawResult[10]].last = true
                _ui.drawResult = response.drawResult
                _ui.ShowReward = response
                NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/BigCollider"))
            end)
        end
        local isfirst = false
        if tonumber(os.date("%d")) ~= GPlayerPrefs.GetInt("lucky_today") then
            isfirst = true
        end
        if isfirst then
            MessageBox.Show(Format(TextMgr:GetText("LuckyRotary_12"), _ui.data.multiCost), function()
                beginrequest()
                GPlayerPrefs.SetInt("lucky_today",tonumber(os.date("%d")))
                GPlayerPrefs.Save() 
            end, function() end)
        else
            beginrequest()
        end
    end)
    _ui.data = LuckyRotaryData.GetAvailableCard()
    UpdateUI()
    moveType = 1
    index = 1
    moveStep = normalSetp
    tenTargets = {}
end

local function ShowNext()
    _ui.left_items[index].alpha = 1
    _ui.left_items[index].kuang.color = Color(1, 1, 1, _ui.left_items[index].alpha)
    if moveType == 4 and moveStep == minStep and _ui.left_items[index].last then
        moveType = 5
        ItemListShowNew.SetTittle(TextMgr:GetText("LuckyRotary_1"))
		ItemListShowNew.SetItemShow(_ui.ShowReward)
		GUIMgr:CreateMenu("ItemListShowNew" , false)
    end
    if drawType == ActivityMsg_pb.LotteryDrawType_TenTimes then
        if _ui.left_items[index].last then
            if moveType == 5 then
                _ui.left_items[index].cha:SetActive(_ui.left_items[index].num > 1)
                _ui.left_items[index].number.text = _ui.left_items[index].num
                _ui.left_items[index].number.gameObject:SetActive(_ui.left_items[index].num > 1)
            end
        else
            if moveType == 3 then
                _ui.left_items[index].cha:SetActive(_ui.left_items[index].num > 1)
                _ui.left_items[index].number.text = _ui.left_items[index].num
                _ui.left_items[index].number.gameObject:SetActive(_ui.left_items[index].num > 1)
            end
        end
    end
end

local function IsCanFade(v)
    if drawType == ActivityMsg_pb.LotteryDrawType_Once then
        if moveType == 5 and v.last then
            return false
        end
    elseif drawType == ActivityMsg_pb.LotteryDrawType_TenTimes then
        if moveType == 5 and v.last then
            return false
        else
            if (v.last and v.num > 1) or (not v.last and v.num > 0) then
                return false
            end
        end
    end
    return true
end

local function UpdateKuang()
    for i, v in ipairs(_ui.left_items) do
        if v.alpha > 0 and IsCanFade(v) then
            v.alpha = v.alpha - Time.deltaTime * fadeout
            if v.alpha < 0 then
                v.alpha = 0
            end
            v.kuang.color = Color(1, 1, 1, v.alpha)
        end
    end
end

finishDraw = function()
    moveType = 5
    while #_ui.drawResult > 0 do
        local i = table.remove(_ui.drawResult, 1)
        _ui.left_items[i].num = _ui.left_items[i].num + 1
    end
    for i = 1, 14 do
        index = i
        ShowNext()
        _ui.left_items[index].cha:SetActive(_ui.left_items[index].num > 1)
        _ui.left_items[index].number.text = _ui.left_items[index].num
        _ui.left_items[index].number.gameObject:SetActive(_ui.left_items[index].num > 1)
    end
    while UnityEngine.GameObject.Find("BigCollider(Clone)") ~= nil do
        UnityEngine.GameObject.DestroyImmediate(UnityEngine.GameObject.Find("BigCollider(Clone)"))
    end
    ItemListShowNew.SetTittle(TextMgr:GetText("LuckyRotary_1"))
	ItemListShowNew.SetItemShow(_ui.ShowReward)
	GUIMgr:CreateMenu("ItemListShowNew" , false)
end

function Update()
    if moveType < 5 then
        timer = timer + Time.deltaTime
        if timer >= moveStep then
            timer = timer - moveStep
            index = index + 1
            if index > 14 then
                index = 1
            end
            ShowNext()
        end
    end
    if moveType == 1 then
        moveStep = normalSetp
    elseif moveType == 2 then
        if moveStep > maxStep then
            moveStep = moveStep - addStep * Time.deltaTime
        else
            moveStep = maxStep
            moveType = 3
        end
    elseif moveType == 3 then
        if drawType == ActivityMsg_pb.LotteryDrawType_Once then
            moveType = 4
        else
            if _ui.ten_timer == nil then
                _ui.ten_timer = 0
            elseif _ui.ten_timer > 0.5 then
                _ui.ten_timer = _ui.ten_timer - 0.5
                local i = table.remove(_ui.drawResult, 1)
                _ui.left_items[i].num = _ui.left_items[i].num + 1
                if #_ui.drawResult == 0 then
                    moveType = 4
                    _ui.ten_timer = 0
                end
            else
                _ui.ten_timer = _ui.ten_timer + Time.deltaTime
            end
        end
    elseif moveType == 4 then
        if moveStep < minStep then
            moveStep = moveStep + subStep * Time.deltaTime
        else
            moveStep = minStep
        end
    elseif moveType == 5 then
        while UnityEngine.GameObject.Find("BigCollider(Clone)") ~= nil do
            UnityEngine.GameObject.DestroyImmediate(UnityEngine.GameObject.Find("BigCollider(Clone)"))
        end
    end
    UpdateKuang()
end

UpdateTop = function()
	CountDown.Instance:Add("LuckyRotary", ActivityData.GetActivityConfig(_ui.activity.activityId).endTime, CountDown.CountDownCallBack(function(t)
		if t == "00:00:00" then
			CountDown.Instance:Remove("LuckyRotary")	
			HideAll()
		else
			_ui.time.text = Format(TextMgr:GetText("TotalPay_ui2"), t)
		end
    end))
end

UpdateDown = function()
    if _ui == nil then
        return
    end
    _ui.data = LuckyRotaryData.GetAvailableCard()
    _ui.once_gold.text = "x" .. _ui.data.cost
    if _ui.data.countInfo.count and _ui.data.countInfo.count > 0 then
        _ui.once_label.text = TextMgr:GetText("LuckyRotary_7")
        _ui.once_free.text = ""
        _ui.once_gold_icon.gameObject:SetActive(false)
        _ui.once_gold.gameObject:SetActive(false)
        _ui.once_label.gameObject:SetActive(false)
        _ui.once_free.gameObject:SetActive(false)
        _ui.once_free_label.gameObject:SetActive(true)
        _ui.once_red.gameObject:SetActive(true)
    else
        _ui.once_gold_icon.gameObject:SetActive(true)
        _ui.once_gold.gameObject:SetActive(true)
        _ui.once_label.gameObject:SetActive(true)
        _ui.once_free.gameObject:SetActive(true)
        _ui.once_free_label.gameObject:SetActive(false)
        _ui.once_red.gameObject:SetActive(false)  
        _ui.once_label.text = TextMgr:GetText("LuckyRotary_4")
        CountDown.Instance:Add("LuckyRotary_free", Global.GetFiveOclockCooldown(), CountDown.CountDownCallBack(function(t)
            if t == "00:00:00" then
                CountDown.Instance:Remove("LuckyRotary_free")	
                UpdateDown()
            else
                _ui.once_free.text = Format(TextMgr:GetText("LuckyRotary_6"), t)
            end
        end))
    end
    _ui.ten_gold.text = "x" .. _ui.data.multiCost
    _ui.ten_label.text = TextMgr:GetText("LuckyRotary_5")
    local updateItem = function(item, data)
        local itemdata = TableMgr:GetItemData(data.id)
		local reward = {}
		UIUtil.LoadItemObject(reward, item)
        UIUtil.LoadItem(reward, itemdata, data.num)
        SetParameter(item.gameObject, "item_" .. data.id)
    end
    local updateHero = function(hero, data)
        local heroData = TableMgr:GetHeroData(data.id)
		hero.localScale = Vector3(0.58, 0.58, 1)
		hero:Find("level text").gameObject:SetActive(false)
		hero:Find("name text").gameObject:SetActive(false)
		hero:Find("bg_skill").gameObject:SetActive(false)
		hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
		hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
		local star = hero:Find("star"):GetComponent("UISprite")
		if star ~= nil then
			star.width = data.star * star.height
		end
		SetParameter(hero:Find("head icon").gameObject, "hero_" .. data.id)
    end
    for i, v in ipairs(_ui.data.rewards) do
        if #v.items > 0 then
            _ui.left_items[i].item_obj:SetActive(true)
            updateItem(_ui.left_items[i].item_obj.transform, v.items[1])
        end
        if #v.heros > 0 then
            _ui.left_items[i].hero_obj:SetActive(true)
            updateHero(_ui.left_items[i].hero_obj.transform, v.heros[1])
        end
    end
    local childcount = _ui.right_grid.transform.childCount
    for i, v in ipairs(_ui.data.extraRewards) do
        local item
        if i <= childcount then
			item = _ui.right_grid.transform:GetChild(i - 1)
		else
			item = NGUITools.AddChild(_ui.right_grid.gameObject, _ui.right_item.gameObject).transform
        end
        item:Find("icon"):GetComponent("UISprite").spriteName = "Rotary_box" .. v.status
        item:Find("icon/fulibao").gameObject:SetActive(v.status == 2)
        item:Find("Label1"):GetComponent("UILabel").text = Format(TextMgr:GetText("LuckyRotary_9"), v.count)
        item:Find("Label1").gameObject:SetActive(v.status < 3)
        item:Find("Label2").gameObject:SetActive(v.status == 3)
        SetClickCallback(item.gameObject, function()
            LuckyRotaryReward.Show(v.rewardInfo.items, function()
                LuckyRotaryData.TakeExtraRewardRequest(v.count)
            end, v.status, v.count)
        end)
    end
    _ui.right_grid:Reposition()
    _ui.right_scroll:RestrictWithinBounds(true, _ui.right_scroll.transform)
    _ui.right_times.text = Format(TextMgr:GetText("LuckyRotary_11"), _ui.data.drawCount)
end

UpdateUI = function()
	UpdateTop()
	UpdateDown()
end