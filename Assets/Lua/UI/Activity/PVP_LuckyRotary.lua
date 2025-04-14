module("PVP_LuckyRotary", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local minFrame = 1
local maxFrame = 10
local frameStep = 1

local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    JailTreat.Hide()
    Hide()
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

local function SecondUpdate()
    if _ui then
        _ui.cooldownLabel.text = Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown())
    end
end

function LoadUI()
    if _ui == nil then
        return
    end

    local warLossData = WarLossData.GetData()
    _ui.scoreLabel.text = Format(TextMgr:GetText(Text.PVP_LuckyRotary9), warLossData.score)

    local itemCount = 0
    local hasEnoughItem = true
    local itemData
    if _ui.priceIndex ~= 0 then
        local price = tableData_tWarCoinDrop.data[_ui.priceIndex].Price
        local itemIdList = string.split(price, ":")
        local itemId = tonumber(itemIdList[1])
        itemCount = tonumber(itemIdList[2])
        itemData = TableMgr:GetItemData(itemId)
        local hasCount = 0
        if itemData.type == 1 then
            hasCount = MoneyListData.GetMoneyByType(itemData.id)
        else
            hasCount = ItemListData.GetItemCountByBaseId(itemId)
        end
        hasEnoughItem = hasCount >= itemCount
    else
        local price = tableData_tWarCoinDrop.data[1].Price
        local itemIdList = string.split(price, ":")
        local itemId = tonumber(itemIdList[1])
        itemData = TableMgr:GetItemData(itemId)
    end

    _ui.priceTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
    _ui.priceLabel.text = itemCount
    SetClickCallback(_ui.priceButton.gameObject, function(go)
        PVP_LuckyRotary_Select.Show(_ui.priceIndex, function(priceIndex)
            _ui.priceIndex = priceIndex
            LoadUI()
        end) 
    end)

    _ui.priceIndexList = {}
    for i, v in ipairs(_ui.packageList) do
        local warCoinData = tableData_tWarCoinDrop.data[i] 
        v.iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", warCoinData.icon)
        SetClickCallback(v.iconTexture.gameObject, function(go)
            PVP_LuckyRotaryReward.Show(warLossData.rewards[i].items)
        end)
        if i <= _ui.priceIndex then
            v.deleteObject:SetActive(true)
        else
            v.deleteObject:SetActive(false)
            table.insert(_ui.priceIndexList, i)
        end
    end

    _ui.costLabel.text = warLossData.cost
    _ui.costLabel.color = warLossData.score >= warLossData.cost and Color.white or Color.red
    SetClickCallback(_ui.rewardButton.gameObject, function(go)
        local req = ActivityMsg_pb.MsgWarLossDrawRequest()
        req.drawType = _ui.priceIndex
        Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgWarLossDrawRequest, req, ActivityMsg_pb.MsgWarLossDrawResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.FloatError(msg.code)
            else
                if _ui ~= nil then
                    MainCityUI.UpdateRewardData(msg.fresh)
                    Global.DisableUI()
                    _ui.rewardCoroutine = coroutine.start(function()
                        local priceListIndex = 1
                        local frame = minFrame
                        repeat
                            local priceIndex = _ui.priceIndexList[priceListIndex % #_ui.priceIndexList + 1]
                            for i, v in ipairs(_ui.packageList) do
                                v.selectObject:SetActive(i == priceIndex)
                            end
                            coroutine.step(frame)
                            priceListIndex = priceListIndex + 1
                            frame = frame + frameStep
                        until frame >= maxFrame and priceIndex == msg.drawResult
                        _ui.packageList[msg.drawResult].animator.enabled = true
                        _ui.packageList[msg.drawResult].animator:Play("zhansunbaoxiang", -1, 0)
                        coroutine.wait(0.5)
                        WarLossData.RequestData()
                        ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                        ItemListShowNew.SetItemShow(msg)
                        GUIMgr:CreateMenu("ItemListShowNew" , false)
                        Global.EnableUI()
                    end)
                end
            end
        end)
        --[[PVP_LuckyRotary_Sure.Show(_ui.priceIndex, itemData, itemCount, warLossData.cost, function(msg)
            MainCityUI.UpdateRewardData(msg.fresh)
            Global.DisableUI()
            _ui.rewardCoroutine = coroutine.start(function()
                local priceListIndex = 1
                local frame = minFrame
                repeat
                    local priceIndex = _ui.priceIndexList[priceListIndex % #_ui.priceIndexList + 1]
                    for i, v in ipairs(_ui.packageList) do
                        v.selectObject:SetActive(i == priceIndex)
                    end
                    coroutine.step(frame)
                    priceListIndex = priceListIndex + 1
                    frame = frame + frameStep
                until frame >= maxFrame and priceIndex == msg.drawResult
                _ui.packageList[msg.drawResult].animator.enabled = true
                _ui.packageList[msg.drawResult].animator:Play("zhansunbaoxiang", -1, 0)
                coroutine.wait(0.5)
                WarLossData.RequestData()
                ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                ItemListShowNew.SetItemShow(msg)
                GUIMgr:CreateMenu("ItemListShowNew" , false)
                Global.EnableUI()
            end)
        end)]]
    end)

    _ui.countLabel.text = Format(TextMgr:GetText(Text.LuckyRotary_11), warLossData.drawCount)
    for i, v in ipairs(warLossData.extraRewards) do
        local chestTransform
        if i > _ui.chestGrid.transform.childCount then
            chestTransform = NGUITools.AddChild(_ui.chestGrid.gameObject, _ui.chestPrefab).transform
        else
            chestTransform = _ui.chestGrid.transform:GetChild(i - 1)
        end
        chestTransform:Find("icon"):GetComponent("UISprite").spriteName = "Rotary_box" .. v.status
        chestTransform:Find("icon/fulibao").gameObject:SetActive(v.status == 2)
        chestTransform:Find("Label1").gameObject:SetActive(v.status < 3)
        chestTransform:Find("Label2").gameObject:SetActive(v.status == 3)
        chestTransform:Find("Label1"):GetComponent("UILabel").text = Format(TextMgr:GetText(Text.LuckyRotary_9), v.count)
        SetClickCallback(chestTransform.gameObject, function(go)
            PVP_LuckyRotaryReward.Show(v.rewardInfo.items, function()
            end,
            v.status, v.count)
        end)
    end
    _ui.chestGrid.repositionNow = true
    SecondUpdate()
end

function Refresh()
    LoadUI()
end

function Awake()
    table.sort(tableData_tWarCoinDrop.data, function(v1, v2)
        if v1.Gear ~= 0 and v2.Gear ~= 0 then
            return v1.Gear < v2.Gear
        else
            return v1.Gear ~= 0 and v2.Gear == 0
        end
    end)
    _ui = {}
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, CloseAll)
    transform:Find("Container/bg_frane/text").gameObject:SetActive(false) --屏蔽黄金选择
    _ui.scoreLabel = transform:Find("Container/bg_frane/mynumber"):GetComponent("UILabel")
    _ui.costLabel = transform:Find("Container/bg_frane/rotary/mid_button/Label2"):GetComponent("UILabel")
    _ui.countLabel = transform:Find("Container/bg_frane/right/top/number"):GetComponent("UILabel")
    _ui.priceTexture = transform:Find("Container/bg_frane/text/icon"):GetComponent("UITexture")
    _ui.priceLabel = transform:Find("Container/bg_frane/text/back/Label"):GetComponent("UILabel")
    _ui.priceButton = transform:Find("Container/bg_frane/text/button"):GetComponent("UIButton")

    local packageList = {}
    for i = 1, 5 do
        local package = {}
        package.iconTexture = transform:Find(string.format("Container/bg_frane/rotary/Texture%d/Textureclosed", i)):GetComponent("UITexture")
        package.animator = transform:Find("Container/bg_frane/rotary/Texture" .. i):GetComponent("Animator")
        package.animator.enabled = false
        package.deleteObject = transform:Find(string.format("Container/bg_frane/rotary/Texture%d/delete", i)).gameObject
        package.selectObject = transform:Find("Container/bg_frane/rotary/select" .. i).gameObject
        packageList[i] = package
    end
    _ui.packageList = packageList

    _ui.rewardButton = transform:Find("Container/bg_frane/rotary/mid_button"):GetComponent("UIButton")

    _ui.helpButton = transform:Find("Container/bg_frane/right/top/wenhao"):GetComponent("UIButton")
    SetClickCallback(_ui.helpButton.gameObject, function(go)
        PVP_LuckyRotary_Help.Show()
    end)
    _ui.chestScrollView = transform:Find("Container/bg_frane/right/back/base/Scroll View"):GetComponent("UIScrollView")
    _ui.chestGrid = transform:Find("Container/bg_frane/right/back/base/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.chestPrefab = _ui.chestGrid.transform:GetChild(0).gameObject

    _ui.cooldownLabel = transform:Find("Container/bg_frane/right/time"):GetComponent("UILabel")
    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    WarLossData.AddListener(LoadUI)
end

function Start()
    LoadUI()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    WarLossData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui.timer:Stop()
    coroutine.stop(_ui.rewardCoroutine)
    Global.EnableUI()
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
    _ui.priceIndex = 0
end
