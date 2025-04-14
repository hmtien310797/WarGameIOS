module("MilitarySchool", package.seeall)
local String = System.String
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local normalUI
local activeUI
local seniorUI
local cooldownCoroutine

local nextGuarantee
local guaranteeReset

OnCloseCB = nil

function Hide()
    Global.CloseUI(_M)
end

local function LoadCooldownUI(ui, chestMsg)
    local leftSecond = Global.GetLeftCooldownSecond(chestMsg.freecdtime)
    local haveCooldown = leftSecond > 0
    if haveCooldown  then
        ui.cooldownLabel.text = Global.SecondToTimeLong(leftSecond)
    end
    ui.cooldownLabel.gameObject:SetActive(haveCooldown)
    if ui.leftCountLabel ~= nil then
        ui.leftCountLabel.gameObject:SetActive(not haveCooldown)
    end
    local free = not haveCooldown and chestMsg.freecount > 0
    ui.oneCost.countLabel.gameObject:SetActive(not free)
    ui.free.gameObject:SetActive(free)
end

function HaveFreeCount(chestType)
    local msg = nil
    local free = false
    local itemCount = 0
    if chestType == "normal" then
        msg = ChestListData.GetNormalChestData()
    elseif chestType == "senior" then
        msg = ChestListData.GetSeniorChestData()
    end

    local itemId = msg.costitem.id
    local itemCount = ItemListData.GetItemCountByBaseId(itemId) 
    local leftSecond = Global.GetLeftCooldownSecond(msg.freecdtime)
    local haveCooldown = leftSecond > 0
    free = not haveCooldown and msg.freecount > 0

    return free , itemCount , itemId
end

local function HaveSeniorFreeCount()
    local seniorMsg = ChestListData.GetSeniorChestData()
    local itemId = seniorMsg.costitem.id
    local itemCount = ItemListData.GetItemCountByBaseId(itemId)
    local leftSecond = Global.GetLeftCooldownSecond(seniorMsg.freecdtime)
    local haveCooldown = leftSecond > 0
    local free = not haveCooldown and seniorMsg.freecount > 0

    return free , itemCount
end

local _platformType

function GetPlatformType()
    if _platformType == nil then
        _platformType = GUIMgr:GetPlatformType()
    end

    return _platformType
end

function SetPlatformType(platformType)
    _platformType = platformType
end

function PlatformUseItem()
    local platformType = GetPlatformType()
    return Global.IsIosMuzhi() or platformType == LoginMsg_pb.AccType_adr_muzhi
end

local function LoadCostUI(costUI, costMsg, muticostdiccount)
    costUI.countLabel.text = costMsg.num
    local itemData = TableMgr:GetItemData(costMsg.id)
    costUI.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
end

function LoadOneCostUI(ui, chestMsg)
    if PlatformUseItem() then
        chestMsg.costmoney.id = 0
    end
    local costUI = ui.oneCost
    local itemCount = ItemListData.GetItemCountByBaseId(chestMsg.costitem.id)
    if itemCount >= chestMsg.costitem.num or chestMsg.costmoney.id == 0 then
        LoadCostUI(costUI, chestMsg.costitem)
    else
        LoadCostUI(costUI, chestMsg.costmoney)
    end
end

function LoadTenCostUI(ui, chestMsg)
    if PlatformUseItem() then
        chestMsg.muticostmoney.id = 0
    end
    local costUI = ui.tenCost
    local itemCount = ItemListData.GetItemCountByBaseId(chestMsg.muticostitem.id)
	if chestMsg.muticostitem.num == 0 and chestMsg.muticostitem.id == 0 then
		LoadCostUI(costUI, chestMsg.muticostmoney, chestMsg.muticostdiccount)
    elseif itemCount >= chestMsg.muticostitem.num or chestMsg.muticostmoney.id == 0 then
        LoadCostUI(costUI, chestMsg.muticostitem, chestMsg.muticostdiccount)
    else
        LoadCostUI(costUI, chestMsg.muticostmoney, chestMsg.muticostdiccount)
    end
end

local function LoadAllCostUI(ui, chestMsg)
    LoadOneCostUI(ui, chestMsg)
    LoadTenCostUI(ui, chestMsg)
    local itemId = chestMsg.costitem.id
    local itemCount = ItemListData.GetItemCountByBaseId(itemId) 
    ui.itemLabel.text = String.Format(TextMgr:GetText(Text.Military_num), itemCount)
end

local function LoadNormalUI()
    local chestMsg = ChestListData.GetNormalChestData()
    local ui = normalUI
    ui.leftCountLabel.text = string.format("%d/%d", chestMsg.freecount, chestMsg.maxfreecount)

    LoadAllCostUI(ui, chestMsg)
    LoadCooldownUI(ui, chestMsg)
end

local function LoadActiveUI()
    local chestMsg = ChestListData.GetActiveChestData()
    local ui = activeUI
    local hasActive = chestMsg ~= nil
    if hasActive then
        LoadAllCostUI(ui, chestMsg)
    end
    activeUI.bg.localScale = Vector3(hasActive and 1 or 0, 1, 1)
    if hasActive then
        local leftSecond = Global.GetLeftCooldownSecond(chestMsg.freecdtime)
        ui.cooldownLabel.text = math.ceil(leftSecond / 3600)
        ui.cooldownBg.gameObject:SetActive(chestMsg.freecdtime ~= 0)
    end
end

local function LoadSeniorUI()
    local chestMsg = ChestListData.GetSeniorChestData()
    local ui = seniorUI
    ui.cooldownLabel.text = Global.GetLeftCooldownTextLong(chestMsg.freecdtime)

    nextGuarantee = chestMsg.nextSenior
    guaranteeReset = chestMsg.loopSenior
    ui.guarantee.text = String.Format(TextMgr:GetText(Text.Military_get1), nextGuarantee)
    ui.saleOffObject:SetActive(chestMsg.muticostdiccount ~= 100)
    if PlatformUseItem() then
        ui.saleDescriptionLabel.text = TextMgr:GetText(chestMsg.activecdtime > 0 and Text.chest_ui05 or Text.chest_ui04)
    else
        ui.saleDescriptionLabel.text = TextMgr:GetText(Text.chest_ui03)
    end
    ui.saleOffLabel.text = string.format("%d%%", 100 - chestMsg.muticostdiccount)

    LoadAllCostUI(ui, chestMsg)
    LoadCooldownUI(ui, chestMsg)
end

local function LoadUI()
    LoadNormalUI()
    LoadActiveUI()
    LoadSeniorUI()
end

function GetRequestFunction(chestType, multi)
    local function RequestBuy(chestMsg)
        if multi then
            TenCardDisplay.Hide()
        else
            OneCardDisplay.Hide()
        end
        local req = ItemMsg_pb.MsgChestEnterRequest()
        req.type = chestType
        req.buycount = multi and 2 or 1
        req.discount = chestMsg.muticostdiccount
        Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgChestEnterRequest, req, ItemMsg_pb.MsgChestEnterResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.ShowError(msg.code)
            else
                ChestListData.SetChestDataByType(msg.panelinfo.type, msg.panelinfo)
                MainCityUI.UpdateRewardData(msg.fresh)
                local type = msg.panelinfo.type
                if type == ItemMsg_pb.ect_normal then
                    LoadNormalUI()
                elseif type == ItemMsg_pb.ect_active then
                    LoadActiveUI()
                elseif type == ItemMsg_pb.ect_senior then
                    LoadSeniorUI()
                end
                if multi then
                    TenCardDisplay.Show(msg.panelinfo, msg.reward)
                else
                    OneCardDisplay.Show(msg.panelinfo, msg.reward.hero.hero[1], msg.reward.item.item[1], true)
                end
                if type == ItemMsg_pb.ect_senior and multi then
                    GUIMgr:SendDataReport("efun", "10cards") --统计高级10连抽
                end
                GUIMgr:SendDataReport("purchase", "costgold", "Collect Hero", "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
                if not multi then
                    nextGuarantee = nextGuarantee - 1
                    if nextGuarantee == 0 then
                        nextGuarantee = guaranteeReset
                    end
                end
            end
        end)
    end

    return function()
        local chestMsg = ChestListData.GetChestDataByType(chestType)
        local itemData
        local itemCount
        local needBuy
        local costMoney
        local costItem
        local free = false
        if multi then
            itemData = TableMgr:GetItemData(chestMsg.muticostitem.id)
            itemCount = ItemListData.GetItemCountByBaseId(chestMsg.muticostitem.id)
            needBuy = chestMsg.muticostitem.num > itemCount
            costMoney = chestMsg.muticostmoney
            costItem = chestMsg.muticostitem
        else
            itemData = TableMgr:GetItemData(chestMsg.costitem.id)
            itemCount = ItemListData.GetItemCountByBaseId(chestMsg.costitem.id)
            needBuy = chestMsg.costitem.num > itemCount
            costMoney = chestMsg.costmoney
            costItem = chestMsg.costitem
            local leftSecond = Global.GetLeftCooldownSecond(chestMsg.freecdtime)
            local haveCooldown = leftSecond > 0
            free = not haveCooldown and chestMsg.freecount > 0
        end
        if PlatformUseItem() and needBuy and not free then
            local itemName = TextUtil.GetItemName(itemData)
            local showText = String.Format(TextMgr:GetText(Text.purchase_confirmation_1), costMoney.num, itemName, costItem.num)
            MessageBox.Show(showText, function()
                RequestBuy(chestMsg)
            end,
            function()
            end)
        else
            RequestBuy(chestMsg)
        end
    end
end

function Awake()
    normalUI = {}
    activeUI = {}
    seniorUI = {}

    -- normal UI
    normalUI.cooldownLabel = transform:Find("Container/normal recruit/time"):GetComponent("UILabel")
    normalUI.leftCountLabel = transform:Find("Container/normal recruit/times"):GetComponent("UILabel")

    normalUI.oneCost = {}
    normalUI.tenCost = {}

    normalUI.oneCost.countLabel = transform:Find("Container/normal recruit/one consume"):GetComponent("UILabel")
    normalUI.tenCost.countLabel = transform:Find("Container/normal recruit/ten consume"):GetComponent("UILabel")

    normalUI.oneCost.icon = transform:Find("Container/normal recruit/one consume/Texture"):GetComponent("UITexture")
    normalUI.tenCost.icon = transform:Find("Container/normal recruit/ten consume/Texture"):GetComponent("UITexture")

    normalUI.oneButton = transform:Find("Container/normal recruit/one btn"):GetComponent("UIButton")
    normalUI.tenButton = transform:Find("Container/normal recruit/ten btn"):GetComponent("UIButton")

    normalUI.free = transform:Find("Container/normal recruit/free")
    normalUI.itemLabel = transform:Find("Container/normal recruit/num"):GetComponent("UILabel")

    normalUI.preview = transform:Find("Container/normal recruit/preview btn").gameObject

    -- activeUI
    activeUI.bg = transform:Find("Container/activity recruit")

    activeUI.cooldownBg = transform:Find("Container/activity recruit/day widget")
    activeUI.cooldownLabel = transform:Find("Container/activity recruit/day widget/day"):GetComponent("UILabel")

    activeUI.oneCost = {}
    activeUI.tenCost = {}

    activeUI.oneCost.countLabel = transform:Find("Container/activity recruit/one consume"):GetComponent("UILabel")
    activeUI.tenCost.countLabel = transform:Find("Container/activity recruit/ten consume"):GetComponent("UILabel")

    activeUI.oneCost.icon = transform:Find("Container/activity recruit/one consume/Texture"):GetComponent("UITexture")
    activeUI.tenCost.icon = transform:Find("Container/activity recruit/ten consume/Texture"):GetComponent("UITexture")

    activeUI.oneButton = transform:Find("Container/activity recruit/one btn"):GetComponent("UIButton")
    activeUI.tenButton = transform:Find("Container/activity recruit/ten btn"):GetComponent("UIButton")
    activeUI.itemLabel = transform:Find("Container/activity recruit/num"):GetComponent("UILabel")

    -- seniorUI
    seniorUI.cooldownLabel = transform:Find("Container/high-grade recruit/time"):GetComponent("UILabel")

    seniorUI.oneCost = {}
    seniorUI.tenCost = {}

    seniorUI.oneCost.countLabel = transform:Find("Container/high-grade recruit/one consume"):GetComponent("UILabel")
    seniorUI.tenCost.countLabel = transform:Find("Container/high-grade recruit/ten consume"):GetComponent("UILabel")
    
    seniorUI.oneCost.icon = transform:Find("Container/high-grade recruit/one consume/Texture"):GetComponent("UITexture")
    seniorUI.tenCost.icon = transform:Find("Container/high-grade recruit/ten consume/Texture"):GetComponent("UITexture")

    seniorUI.oneButton = transform:Find("Container/high-grade recruit/one btn"):GetComponent("UIButton")
    seniorUI.tenButton = transform:Find("Container/high-grade recruit/ten btn"):GetComponent("UIButton")
    seniorUI.free = transform:Find("Container/high-grade recruit/free")
    seniorUI.itemLabel = transform:Find("Container/high-grade recruit/num"):GetComponent("UILabel")
    seniorUI.guarantee = transform:Find("Container/high-grade recruit/minimum-guarantee/count"):GetComponent("UILabel")--十连抽
    seniorUI.preview = transform:Find("Container/high-grade recruit/preview btn").gameObject
    seniorUI.saleOffObject = transform:Find("Container/high-grade recruit/hint").gameObject
    seniorUI.saleDescriptionLabel = seniorUI.saleOffObject:GetComponent("UILabel")
    seniorUI.saleOffLabel = transform:Find("Container/high-grade recruit/hint/Label"):GetComponent("UILabel")

    cooldownCoroutine = coroutine.start(function()
        while true do
            local normalMsg = ChestListData.GetNormalChestData()
            LoadCooldownUI(normalUI, normalMsg)
            local seniorMsg = ChestListData.GetSeniorChestData()
            LoadCooldownUI(seniorUI, seniorMsg)
            coroutine.wait(1)

            local activeMsg = ChestListData.GetActiveChestData()
            local hasActive = activeMsg ~= nil
            if hasActive then
                if activeMsg.freecdtime ~= 0 then
                    local leftSecond = Global.GetLeftCooldownSecond(activeMsg.freecdtime)
                    if leftSecond == 0 then
                        ChestListData.RequestData()
                    else
                        ChestListData.RequestData()
                        activeUI.cooldownLabel.text = math.ceil(leftSecond / 3600)
                    end
                end
            end
        end
    end)

    local closeButton = transform:Find("Container/close btn")

    UIUtil.SetClickCallback(normalUI.oneButton.gameObject, GetRequestFunction(ItemMsg_pb.ect_normal, false))
    UIUtil.SetClickCallback(normalUI.tenButton.gameObject, GetRequestFunction(ItemMsg_pb.ect_normal, true))

    UIUtil.SetClickCallback(activeUI.oneButton.gameObject, GetRequestFunction(ItemMsg_pb.ect_active, false))
    UIUtil.SetClickCallback(activeUI.tenButton.gameObject, GetRequestFunction(ItemMsg_pb.ect_active, true))

    UIUtil.SetClickCallback(seniorUI.oneButton.gameObject, GetRequestFunction(ItemMsg_pb.ect_senior, false))
    UIUtil.SetClickCallback(seniorUI.tenButton.gameObject, GetRequestFunction(ItemMsg_pb.ect_senior, true))

    UIUtil.SetClickCallback(closeButton.gameObject, function(go)
        Hide()
    end)
    UIUtil.SetClickCallback(transform:Find("mask").gameObject, function(go)
        Hide()
    end)   
    UIUtil.SetClickCallback(normalUI.preview, function() Preview.Show(1) end)
    UIUtil.SetClickCallback(seniorUI.preview, function() Preview.Show(2) end)
    LoadUI()
    MoneyListData.AddListener(LoadUI)
    ItemListData.AddListener(LoadUI)
end

function Close()
    coroutine.stop(cooldownCoroutine)
    MoneyListData.RemoveListener(LoadUI)
    ItemListData.RemoveListener(LoadUI)
    if OnCloseCB ~= nil then
        OnCloseCB()
        OnCloseCB = nil
    end
end

function Show()
    ChestListData.RequestData(function()
        Global.OpenUI(_M)
    end)
end
