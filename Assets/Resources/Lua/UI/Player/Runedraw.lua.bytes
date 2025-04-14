module("Runedraw", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local _ui, UpdateBtns, ShowReward

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function CloseSelf()
    Global.CloseUI(_M)
end

function Hide()
	Global.CloseUI(_M)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    for i = 1, 2 do
        CountDown.Instance:Remove("Runedraw" .. i)
    end
    _ui = nil
end

ShowReward = function(rewardMsg)
    _ui.runeGetAnim.enabled = true
    if #rewardMsg.item.item == 1 then
        coroutine.start(function()
            local itemData = TableMgr:GetItemData(rewardMsg.item.item[1].baseid)
            local itemIcon = ResourceLibrary:GetIcon("Item/", itemData.icon)
            _ui.runeGet1.transform.gameObject:SetActive(true)
            _ui.runeGet1.anim:SetTrigger("play")
            _ui.runeGetAnim:SetTrigger("play1")
            _ui.runeGet1.texture.mainTexture = itemIcon
            _ui.runeGet1.texture.color = Color(1,1,1,0.0039)
            _ui.runeGet1.label.text = TextUtil.GetItemName(itemData)
            coroutine.wait(2)
            _ui.runeGet1.transform.gameObject:SetActive(false)
            Getnewrune.Show(itemData)
        end)
    else
        SetClickCallback(_ui.runeGet10.mask, function() end)
        _ui.runeGet10.masksprite.color = Color(1,1,1,0.0039)
        _ui.runeGetAnim:SetTrigger("play10")
        for i, v in ipairs(_ui.runeGet10.runelist) do
            v.texture.gameObject:SetActive(false)
            v.tweena:PlayForward(true)
            v.tweens:PlayForward(true)
            v.collider.enabled = false
        end
        _ui.runeGet10.transform.gameObject:SetActive(true)
        local waitTime = 0.2
        coroutine.start(function()
            coroutine.wait(1.5)
            _ui.runeGet10.masksprite.color = Color(1,1,1,1)
            for i, v in ipairs(rewardMsg.item.item) do
                local itemData = TableMgr:GetItemData(v.baseid)
                local itemIcon = ResourceLibrary:GetIcon("Item/", itemData.icon)
                _ui.runeGet10.runelist[i].texture.gameObject:SetActive(true)
                _ui.runeGet10.runelist[i].texture.mainTexture = itemIcon
                _ui.runeGet10.runelist[i].label.text = TextUtil.GetItemName(itemData)
                SetClickCallback(_ui.runeGet10.runelist[i].texture.gameObject, function()
                    Getnewrune.Show(itemData)
                end)
                if RuneData.GetRuneTableData(v.baseid).Level > 3 then
                    local stop = true
                    Getnewrune.Show(itemData, function() stop = false end)
                    while stop do
                        coroutine.step()
                    end
                end
                coroutine.wait(waitTime)
            end
            for i, v in ipairs(_ui.runeGet10.runelist) do
                v.collider.enabled = true
            end
            SetClickCallback(_ui.runeGet10.mask, function()
                _ui.runeGet10.transform.gameObject:SetActive(false)
            end)
        end)
    end
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.btns = {}
    _ui.btns[1] = {}
    _ui.btns[2] = {}
    for i = 1, 4 do
        local btn = {}
        btn.transform = transform:Find(string.format("Container/bg_frane/bg/button/button%d",i))
        btn.label = btn.transform:Find("Label"):GetComponent("UILabel")
        btn.gold_sprite = btn.transform:Find("gold"):GetComponent("UISprite")
        btn.gold_label = btn.transform:Find("gold/Label"):GetComponent("UILabel")
        if i == 1 then
            btn.time = btn.transform:Find("time"):GetComponent("UILabel")
            btn.times = btn.transform:Find("times"):GetComponent("UILabel")
            btn.red = btn.transform:Find("red").gameObject
            btn.freelabel = btn.transform:Find("Label (1)").gameObject
            btn.type = 1
            btn.mod = 1
            btn.runename = "rune_normal"
            _ui.btns[1][1] = btn
        elseif i == 2 then
            btn.type = 1
            btn.mod = 2
            btn.runename = "rune_normal"
            _ui.btns[1][2] = btn
        elseif i == 3 then
            btn.time = btn.transform:Find("time"):GetComponent("UILabel")
            btn.times = transform:Find("Container/bg_frane/bg/timesleft"):GetComponent("UILabel")
            btn.red = btn.transform:Find("red").gameObject
            btn.freelabel = btn.transform:Find("Label (1)").gameObject
            btn.type = 2
            btn.mod = 1
            btn.runename = "rune_advance"
            _ui.btns[2][1] = btn
        else
            btn.type = 2
            btn.mod = 2
            btn.runename = "rune_advance"
            _ui.btns[2][2] = btn
        end
        btn.free = 0
        btn.buy = 0
        SetClickCallback(btn.transform.gameObject, function()
            if Global.IsOutSea() then
                RuneData.RequestRuneEnterChest(btn.type, btn.mod, btn.free, btn.buy, function(msg)
                    ShowReward(msg.reward)
                    for _, v in ipairs(_ui.msg.panels) do
                        if v.type == msg.panel.type then
                            v:MergeFrom(msg.panel)
                        end
                    end
                    UpdateBtns()
                end)
            else
                if btn.free == 0 and btn.buy == 1 then
                    MessageBox.Show(String.Format(TextMgr:GetText("purchase_confirmation"), btn.gnum, btn.inum), function()
                        RuneData.RequestRuneEnterChest(btn.type, btn.mod, btn.free, btn.buy, function(msg)
                            ShowReward(msg.reward)
                            for _, v in ipairs(_ui.msg.panels) do
                                if v.type == msg.panel.type then
                                    v:MergeFrom(msg.panel)
                                end
                            end
                            UpdateBtns()
                        end)
                    end, function() end)
                else
                    RuneData.RequestRuneEnterChest(btn.type, btn.mod, btn.free, btn.buy, function(msg)
                        ShowReward(msg.reward)
                        for _, v in ipairs(_ui.msg.panels) do
                            if v.type == msg.panel.type then
                                v:MergeFrom(msg.panel)
                            end
                        end
                        UpdateBtns()
                    end)
                end
            end
        end)
    end

    _ui.costItem1 = transform:Find("Container/bg_frane/fragment_icon/Label"):GetComponent("UILabel")
    _ui.costItem2 = transform:Find("Container/bg_frane/fragment_icon (1)/Label"):GetComponent("UILabel")
    _ui.costItem1_icon = transform:Find("Container/bg_frane/fragment_icon/Sprite").gameObject
    _ui.costItem2_icon = transform:Find("Container/bg_frane/fragment_icon (1)/Sprite").gameObject

    UIUtil.SetClickCallback(_ui.costItem1_icon, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            local itemData = TableMgr:GetItemData(310001)
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
        end
    end)
    UIUtil.SetClickCallback(_ui.costItem2_icon, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            local itemData = TableMgr:GetItemData(310002)
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
        end
    end)

    _ui.runeGetAnim = transform:Find("Container/bg_frane/bg/bgdraw"):GetComponent("Animator")

    _ui.runeGet1 = {}
    _ui.runeGet1.transform = transform:Find("Container/bg_frane/newrune/get1")
    _ui.runeGet1.anim = _ui.runeGet1.transform:GetComponent("Animator")
    _ui.runeGet1.texture = _ui.runeGet1.transform:Find("rune"):GetComponent("UITexture")
    _ui.runeGet1.label = _ui.runeGet1.transform:Find("rune/Label"):GetComponent("UILabel")

    _ui.runeGet10 = {}
    _ui.runeGet10.transform = transform:Find("Container/bg_frane/newrune/get10")
    _ui.runeGet10.mask = transform:Find("Container/bg_frane/newrune/get10/mask").gameObject
    _ui.runeGet10.masksprite = _ui.runeGet10.mask:GetComponent("UISprite")
    _ui.runeGet10.runelist = {}
    for i = 1, 10 do
        local runeitem = {}
        runeitem.texture = _ui.runeGet10.transform:Find(string.format("rune%d", i % 10)):GetComponent("UITexture")
        runeitem.collider = runeitem.texture.transform:GetComponent("BoxCollider")
        runeitem.label = runeitem.texture.transform:Find("Label"):GetComponent("UILabel")
        runeitem.tweena = runeitem.texture.transform:GetComponent("TweenAlpha")
        runeitem.tweens = runeitem.texture.transform:GetComponent("TweenScale")
        _ui.runeGet10.runelist[i] = runeitem
    end

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

local function SetBtnFunction(btn, costitem, costmoney)
    if Global.IsOutSea() then
        if costitem.num > ItemListData.GetItemCountByBaseId(costitem.id) then
            btn.buy = 1
            btn.gold_sprite.spriteName = "icon_gold"
            btn.gold_label.text = costmoney.num
        else
            btn.buy = 0
            btn.gold_sprite.spriteName = btn.runename
            btn.gold_label.text = costitem.num
        end
    else
        if costitem.num > ItemListData.GetItemCountByBaseId(costitem.id) then
            btn.buy = 1
            btn.gnum = costmoney.num
            btn.inum = TextMgr:GetText(TableMgr:GetItemData(costitem.id).name) .. "*" .. costitem.num
        else
            btn.buy = 0
        end
        btn.gold_sprite.spriteName = btn.runename
        btn.gold_label.text = costitem.num
    end
end

UpdateBtns = function()
    local curTime = Serclimax.GameTime.GetSecTime()
    for i, v in ipairs(_ui.msg.panels) do
        local isfree = curTime >= v.nextFreeTime
        if i == 1 then
            _ui.btns[i][1].times.text = (v.maxFreeCount - v.usedFreeCount) .. "/" .. v.maxFreeCount
            _ui.btns[i][1].times.gameObject:SetActive(isfree)
			if Global.IsOutSea() then
				 _ui.btns[i][2].transform.gameObject:SetActive(false)
			end
        else
            _ui.btns[i][1].times.text = String.Format(TextMgr:GetText("ui_rune_27"), (v.loopGood - v.totalCount % v.loopGood))
        end
        _ui.btns[i][1].free = isfree and 1 or 0
        _ui.btns[i][1].freelabel:SetActive(isfree)
        _ui.btns[i][1].red:SetActive(isfree)
        _ui.btns[i][1].gold_sprite.gameObject:SetActive(not isfree)
        _ui.btns[i][1].label.text = isfree and TextMgr:GetText("ui_rune_24") or TextMgr:GetText("ui_rune_26")
		if Global.IsOutSea() and i == 2 then
            _ui.btns[i][1].time.gameObject:SetActive(false)
            _ui.btns[i][1].freelabel:SetActive(false)
            _ui.btns[i][1].red:SetActive(false)
            _ui.btns[i][1].gold_sprite.gameObject:SetActive(true)
            _ui.btns[i][1].free = 0
		else
			_ui.btns[i][1].time.gameObject:SetActive((not isfree))
		end
        
        if not isfree then
            CountDown.Instance:Add("Runedraw" .. i, v.nextFreeTime, function(t)
                _ui.btns[i][1].time.text = t
                if v.nextFreeTime <= Serclimax.GameTime.GetSecTime() then
                    CountDown.Instance:Remove("Runedraw" .. i)
                    UpdateBtns()
                end
            end)
        end
        SetBtnFunction(_ui.btns[i][1], v.costItem, v.costMoney)
        SetBtnFunction(_ui.btns[i][2], v.multiCostItem, v.multiCostMoney)
    end
    _ui.costItem1.text = ItemListData.GetItemCountByBaseId(_ui.msg.panels[1].costItem.id)
    _ui.costItem2.text = ItemListData.GetItemCountByBaseId(_ui.msg.panels[2].costItem.id)
end

function Start()
    _ui.msg = RuneData.GetRuneChestPanel()
    SetClickCallback(_ui.btn_close, CloseSelf)
    UpdateBtns()
end

function Show()
    Global.OpenUI(_M)
end