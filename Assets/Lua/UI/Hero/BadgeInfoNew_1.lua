module("BadgeInfoNew_1", package.seeall)

local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback

local MATERIAL_CONFIG = { [1] = {4},
                          [2] = {1, 4},
                          [3] = {1, 3, 5},
                          [4] = {2, 3, 5, 6},
                          [5] = {2, 3, 4, 5, 6},
                          [6] = {1, 2, 3, 4, 5, 6}, }

local itemsToMake
local isMethodAvailable
local numMethodsAvailable

local ui

function IsInViewport()
    return ui ~= nil
end

local function UpdateRight()
    local material = ui.rightmaterial
    if material then
        --[[local isbuy = false
        local isdrop = false
        for _, methodType in ipairs(table.map(string.split(material.itemData.gather2, ";"), tonumber)) do
            if methodType == 4 then
                isbuy = true
            end
            if methodType == 3 then
                isdrop = true
            end
        end
        ui.right.block1.go:SetActive(not isbuy and isdrop)
        ui.right.block2.go:SetActive(isbuy and not isdrop)
        ui.right.block3.go:SetActive(isbuy and isdrop)]]
        ui.right.block1.go:SetActive(true)
        local numHas = ItemListData.GetItemCountByBaseId(material.itemData.id)
        local numNeeded = material.numNeeded
        local hasEnoughMaterials = numHas >= numNeeded
        local numstr = string.make_fraction(hasEnoughMaterials and numHas or string.format("[ff0000]%d[-]", numHas), numNeeded)

        ui.right.block1.name.text = System.String.Format(TextMgr:GetText(material.itemData.name), material.itemData.itemlevel)
        ui.right.block1.icon.mainTexture = ResourceLibrary:GetIcon("Item/", material.itemData.icon)
        ui.right.block1.quality.spriteName = "bg_item" .. material.itemData.quality
        ui.right.block1.num.text = numstr
        ui.right.block1.label.gameObject:SetActive(false)
        ui.right.block1.btn:SetActive(false)
        if material.itemData.gather ~= "NA" then
            local sourceInfos = string.msplit(material.itemData.gather, ":", ";")
            Global.PrintAll(sourceInfos)
            local sLevels = sourceInfos[1]
            local targetLevels = sourceInfos[2]
            if type(targetLevels) == "string" then
                local temp = targetLevels
                targetLevels = {}
                targetLevels[1] = temp
            end
            
            local baseLevel = maincity.GetBuildingByID(1).data.level
            local playerLevel = MainData.GetLevel()
            local index = 0
            for i, v in ipairs(targetLevels) do
                local chapterItem
                if i <= ui.right.block1.grid.transform.childCount then
                    chapterItem = ui.right.block1.grid.transform:GetChild(i - 1)
                else
                    chapterItem = NGUITools.AddChild(ui.right.block1.grid.transform.gameObject , ui.right.block1.cgroup).transform
                end
                chapterItem.gameObject:SetActive(true)
                local nameLabel = chapterItem:Find("Label"):GetComponent("UILabel")
                local goButton = chapterItem:Find("Go Button")
                local battleId = tonumber(v)
                local battleData = TableMgr:GetBattleData(battleId)
                nameLabel.text = TextMgr:GetText("maincity_ui1") .. TextMgr:GetText(battleData.nameLabel)
                nameLabel.color = playerLevel >= battleData.requiredLevel and baseLevel >= battleData.requiredBaseLevel and (FunctionListData.IsUnlocked(135) and ChapterListData.CanExplore(battleId)) and Color.green or Color.red
                
                SetClickCallback(goButton.gameObject, function(go)
                    local reasonText = ChapterInfoUI.CheckShow(battleId , {itemid = material.itemData.id , itemcount = numNeeded , gaterCount = 0})
                    if reasonText ~= nil then
                        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        FloatText.Show(reasonText, Color.white)
                    end
                end)
                index = i
            end
            for i = index + 1, ui.right.block1.grid.transform.childCount do
                ui.right.block1.grid.transform:GetChild(i - 1).gameObject:SetActive(false)
            end
            ui.right.block1.grid:Reposition()
            ui.right.block1.scroll:ResetPosition()
        end

        --[[ui.right.block2.name.text = System.String.Format(TextMgr:GetText(material.itemData.name), material.itemData.itemlevel)
        ui.right.block2.icon.mainTexture = ResourceLibrary:GetIcon("Item/", material.itemData.icon)
        ui.right.block2.quality.spriteName = "bg_item" .. material.itemData.quality
        ui.right.block2.num.text = numstr
        ui.right.block3.name.text = System.String.Format(TextMgr:GetText(material.itemData.name), material.itemData.itemlevel)
        ui.right.block3.icon.mainTexture = ResourceLibrary:GetIcon("Item/", material.itemData.icon)
        ui.right.block3.quality.spriteName = "bg_item" .. material.itemData.quality
        ui.right.block3.num.text = numstr
        print("item table id :", material.itemData.id)
        if isbuy and isdrop then
            ui.exData = TableMgr:GetItemExchangeDataByItemID(material.itemData.id)
            ui.right.block3.gold.text = ui.exData.price
            UIUtil.SetClickCallback(ui.right.block3.btn2, function()
                if ui.buynum > 0 then
                    local shopItemInfo = {}
                    shopItemInfo.exchangeId = ui.exData.id
                    shopItemInfo.price = ui.exData.price
                    ShopItemData.BuyItem(shopItemInfo, ui.buynum)
                end
            end)
            if material.itemData.gather ~= "NA" then
                local sourceInfos = string.msplit(material.itemData.gather, ",", ":", "-")
                local sLevels = sourceInfos[1][2]
                local targetLevel = tonumber(sourceInfos[2][2])
                ui.right.block3.label.text = System.String.Format(TextMgr:GetText("heronew_21"), sLevels[1], sLevels[2])
                UIUtil.SetClickCallback(ui.right.block3.btn1, function()
                    MapSearch.Show(1, math.min(RebelWantedData.GetUnlockedLevel(), targetLevel), HideAll)
                end)
            end
        elseif isbuy then
            ui.exData = TableMgr:GetItemExchangeDataByItemID(material.itemData.id)
            ui.right.block2.gold.text = ui.exData.price
            UIUtil.SetClickCallback(ui.right.block2.btn, function()
                if ui.buynum > 0 then
                    local shopItemInfo = {}
                    shopItemInfo.exchangeId = ui.exData.id
                    shopItemInfo.price = ui.exData.price
                    ShopItemData.BuyItem(shopItemInfo, ui.buynum)
                end
            end)
        elseif isdrop then
            if material.itemData.gather ~= "NA" then
                ui.right.block1.label.gameObject:SetActive(true)
                ui.right.block1.btn:SetActive(true)
                local sourceInfos = string.msplit(material.itemData.gather, ",", ":", "-")
                local sLevels = sourceInfos[1][2]
                local targetLevel = tonumber(sourceInfos[2][2])
                ui.right.block1.label.text = System.String.Format(TextMgr:GetText("heronew_21"), sLevels[1], sLevels[2])
                UIUtil.SetClickCallback(ui.right.block1.btn, function()
                    MapSearch.Show(1, math.min(RebelWantedData.GetUnlockedLevel(), targetLevel), HideAll)
                end)
            else
                ui.right.block1.label.gameObject:SetActive(false)
                ui.right.block1.btn:SetActive(false)
            end
        end]]
    end
end

local function UpdateItemQuantityInLeftUI()
    local itemToMake = itemsToMake:Top()
    ui.left.top.quantity.text = System.String.Format(TextMgr:GetText("heronew_38"), string.make_fraction(ItemListData.GetItemCountByBaseId(itemToMake.itemData.id), itemToMake.numNeeded))
end

local function UpdateTopUI()
    local itemData = itemsToMake:Top().itemData

    ui.left.top.name.text = TextUtil.GetItemName(itemData)
    ui.left.top.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
    ui.left.top.frame.spriteName = "medal_level_" .. itemData.quality

    -- ui.left.tips:SetActive(numMethodsAvailable < 2)

    UpdateItemQuantityInLeftUI()
end

local function UpdateMaterialQuantityInLeftUI()
    local uiTab = ui.left.tabs[9]

    local canMake = true
    for _, uiMaterial in ipairs(uiTab.materialList.materials) do
        local material = uiMaterial.material
        if material then
            local numHas = ItemListData.GetItemCountByBaseId(material.itemData.id)
            local numNeeded = material.numNeeded
            local hasEnoughMaterials = numHas >= numNeeded

            uiMaterial.num.text = string.make_fraction(hasEnoughMaterials and numHas or string.format("[ff0000]%d[-]", numHas), numNeeded)

            canMake = canMake and hasEnoughMaterials
            if not ui.first then
                ui.first = true
                ui.rightmaterial = material
                UpdateRight()
            end
        end
    end

    uiTab.canMake = canMake
end

local function UpdateTab(tab)
    local uiTab = ui.left.tabs[tab]

    if tab == 3 and isMethodAvailable[3] then
        uiTab.gameObject:SetActive(true)

        local sourceInfos = string.msplit(itemsToMake:Top().itemData.gather, ",", ":", "-")

        local sLevels = sourceInfos[1][2]
        local targetLevel = tonumber(sourceInfos[2][2])

        uiTab.targetLevel = targetLevel

        uiTab.label.text = System.String.Format(TextMgr:GetText("heronew_21"), sLevels[1], sLevels[2])
        uiTab.tips.text = System.String.Format(TextMgr:GetText("heronew_43"), targetLevel)
    elseif tab == 4 then
        local isAvailable = isMethodAvailable[4]
        uiTab.tips:SetActive(isAvailable)
        uiTab.none:SetActive(not isAvailable)
    elseif tab == 9 then
        uiTab.gameObject:SetActive(true)

        local uiMaterials = uiTab.materialList.materials
        for _, uiMaterial in ipairs(uiMaterials) do
            uiMaterial.gameObject:SetActive(false)
            uiMaterial.material = nil
        end

        if isMethodAvailable[9] then
            local itemToMake = itemsToMake:Top()
            local itemData = itemToMake.itemData

            uiTab.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
            uiTab.frame.spriteName = "medal_level_" .. itemData.quality

            local materials = {}
            for _, intStrings in ipairs(string.msplit(itemToMake.itemConvertData.NeedItem, ";", ":")) do
                local material = {}
                material.itemData = TableMgr:GetItemData(tonumber(intStrings[1]))
                material.numNeeded = tonumber(intStrings[2])

                table.insert(materials, material)
            end

            local config = MATERIAL_CONFIG[#materials]
            for i, material in ipairs(materials) do
                local uiMaterial = uiMaterials[config[i]]

                uiMaterial.gameObject:SetActive(true)

                uiMaterial.material = material

                local itemData = material.itemData

                uiMaterial.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
                uiMaterial.frame.spriteName = "bg_item" .. itemData.quality
            end

            -- local numMaterials = #materials
            -- for i, uiMaterial in ipairs(uiTab.materialList.materials) do
            --     if i <= numMaterials then
            --         uiMaterial.gameObject:SetActive(true)

            --         local material = materials[i]
            --         local itemData = material.itemData

            --         uiMaterial.material = material

            --         uiMaterial.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
            --         uiMaterial.frame.spriteName = "bg_item" .. itemData.quality
            --     else
            --         uiMaterial.gameObject:SetActive(false)
            --         uiMaterial.material = nil
            --     end
            -- end
            -- uiTab.materialList.grid:Reposition()

            UpdateMaterialQuantityInLeftUI()
        else
            uiTab.icon.mainTexture = nil
            uiTab.frame.spriteName = "medal_lock"
        end
    else
        uiTab.gameObject:SetActive(false)
    end
end

local function StopFx()
    coroutine.stop(ui.fxCoroutine)
    -- ui.left.top.fx:SetActive(false)

    local uiTab9 = ui.left.tabs[9]

    for _, uiMaterial in ipairs(uiTab9.materialList.materials) do
        uiMaterial.fx:SetActive(false)
    end

    uiTab9.fx:SetActive(false)

    ui.fxCoroutine = nil
end

local function PlayFx(callback)
    StopFx()

    ui.fxCoroutine = coroutine.start(function()
        -- ui.left.top.fx:SetActive(true)

        local uiTab9 = ui.left.tabs[9]

        for _, uiMaterial in ipairs(uiTab9.materialList.materials) do
            if uiMaterial.material then
                uiMaterial.fx:SetActive(true)
            end
        end

        uiTab9.fx:SetActive(true)

        coroutine.wait(2)

        -- ui.left.top.fx:SetActive(false)

        for _, uiMaterial in ipairs(uiTab9.materialList.materials) do
            uiMaterial.fx:SetActive(false)
        end

        uiTab9.fx:SetActive(false)

        ui.fxCoroutine = nil

        if callback then
            callback()
        end
    end)
end

local function UpdateUI()
    StopFx()

    isMethodAvailable = {}
    numMethodsAvailable = 0
    for _, methodType in ipairs(table.map(string.split(itemsToMake:Top().itemData.gather2, ";"), tonumber)) do
        isMethodAvailable[methodType] = true
        numMethodsAvailable = numMethodsAvailable + 1
    end

    UpdateTopUI()

    for tab, uiTab in pairs(ui.left.tabs) do
        UpdateTab(tab)
    end
end

function Show(itemToMake)
    if not IsInViewport() then
        itemsToMake = DataStack()
        itemsToMake:Push(itemToMake)

        Global.OpenUI(_M)
    else
        itemsToMake:Push(itemToMake)
        UpdateUI()
    end
end

function Hide()
    itemsToMake:Pop()

    if itemsToMake:IsEmpty() then
        Global.CloseUI(_M)
    else
        UpdateUI()
    end
end

function HideAll()
    Global.CloseUI(_M)
    HeroInfoNew.Hide()
    HeroListNew.Hide()
end

local function OnUICameraClick(go)
    --[[if isMethodAvailable ~= nil and isMethodAvailable[9] and not Tooltip.IsItemSourceClicked(go) then
        Tooltip.HideItemSource()

        local uiTab = ui.left.tabs[9]
        if go ~= uiTab.tips then
            for i, uiMaterial in ipairs(uiTab.materialList.materials) do
                if go == uiMaterial.frame.gameObject then
                    local material = uiMaterial.material
                    Tooltip.ShowItemSource(material.itemData, material.numNeeded, HideAll)
                    uiTab.tips = go
                    return
                end
            end
        end

        uiTab.tips = nil
    end]]
    if isMethodAvailable ~= nil and isMethodAvailable[9] then
        local uiTab = ui.left.tabs[9]
        for i, uiMaterial in ipairs(uiTab.materialList.materials) do
            if go == uiMaterial.frame.gameObject then
                local material = uiMaterial.material
                ui.rightmaterial = material
                UpdateRight()
                return
            end
        end
    end
end

function Awake()
    ui = {}

    ui.left = {}

    ui.left.transform = transform:Find("Left")
    ui.left.gameObject = ui.left.transform.gameObject

    ui.left.top = {}
    ui.left.top.transform = ui.left.transform:Find("Top")
    ui.left.top.gameObject = ui.left.top.transform.gameObject
    ui.left.top.icon = ui.left.top.transform:Find("Icon"):GetComponent("UITexture")
    ui.left.top.frame = ui.left.top.transform:Find("Icon/Frame"):GetComponent("UISprite")
    ui.left.top.name = transform:Find("Left/Fabricate/Label"):GetComponent("UILabel")--ui.left.top.transform:Find("Name"):GetComponent("UILabel")
    ui.left.top.quantity = ui.left.top.transform:Find("Quantity"):GetComponent("UILabel")
    ui.left.top.fx = ui.left.top.transform:Find("Fx").gameObject

    ui.left.tips = ui.left.transform:Find("Tips").gameObject

    ui.right = {}
    ui.right.block1 = {}
    ui.right.block1.go = transform:Find("right/Background1").gameObject
    ui.right.block1.icon = transform:Find("right/Background1/Item/Icon"):GetComponent("UITexture")
    ui.right.block1.quality = transform:Find("right/Background1/Item/Frame"):GetComponent("UISprite")
    ui.right.block1.name = transform:Find("right/Background1/Item/Name"):GetComponent("UILabel")
    ui.right.block1.num = transform:Find("right/Background1/Item/Num"):GetComponent("UILabel")
    ui.right.block1.label = transform:Find("right/Background1/Label"):GetComponent("UILabel")
    ui.right.block1.btn = transform:Find("right/Background1/Go Button").gameObject
    ui.right.block1.cgroup = transform:Find("right/Background1/bg_chapter").gameObject
    ui.right.block1.scroll = transform:Find("right/Background1/Scroll View"):GetComponent("UIScrollView")
    ui.right.block1.grid = transform:Find("right/Background1/Scroll View/Grid"):GetComponent("UIGrid")

    ui.right.block2 = {}
    ui.right.block2.go = transform:Find("right/Background2").gameObject
    ui.right.block2.icon = transform:Find("right/Background2/Item/Icon"):GetComponent("UITexture")
    ui.right.block2.quality = transform:Find("right/Background2/Item/Frame"):GetComponent("UISprite")
    ui.right.block2.name = transform:Find("right/Background2/Item/Name"):GetComponent("UILabel")
    ui.right.block2.num = transform:Find("right/Background2/Item/Num"):GetComponent("UILabel")
    ui.right.block2.gold = transform:Find("right/Background2/Label_gold/Label_number"):GetComponent("UILabel")
    ui.right.block2.buynum = transform:Find("right/Background2/Label_quality/input_base/Label"):GetComponent("UILabel")
    ui.right.block2.btn = transform:Find("right/Background2/Go Button").gameObject

    ui.right.block3 = {}
    ui.right.block3.go = transform:Find("right/Background3").gameObject
    ui.right.block3.icon = transform:Find("right/Background3/Item/Icon"):GetComponent("UITexture")
    ui.right.block3.quality = transform:Find("right/Background3/Item/Frame"):GetComponent("UISprite")
    ui.right.block3.name = transform:Find("right/Background3/Item/Name"):GetComponent("UILabel")
    ui.right.block3.num = transform:Find("right/Background3/Item/Num"):GetComponent("UILabel")
    ui.right.block3.label = transform:Find("right/Background3/Label"):GetComponent("UILabel")
    ui.right.block3.btn1 = transform:Find("right/Background3/Go Button1").gameObject
    ui.right.block3.gold = transform:Find("right/Background3/Label_gold/Label_number"):GetComponent("UILabel")
    ui.right.block3.buynum = transform:Find("right/Background3/Label_quality/input_base/Label"):GetComponent("UILabel")
    ui.right.block3.btn2 = transform:Find("right/Background3/Go Button2").gameObject

    ui.buynum = 1
    UIUtil.SetClickCallback(ui.right.block2.buynum.transform.parent.gameObject, function()
        NumberInput.Show(ui.buynum, 0, 100, function(number)
            ui.buynum = number
            ui.right.block2.buynum.text = ui.buynum
        end)
    end)

    local uiTab3 = {}
    uiTab3.transform = ui.left.transform:Find("Rebel")
    uiTab3.gameObject = uiTab3.transform.gameObject
    uiTab3.label = transform:Find("right/Background1/Label"):GetComponent("UILabel")
    uiTab3.tips = transform:Find("right/Background1/Tips"):GetComponent("UILabel")
    
    UIUtil.SetClickCallback(uiTab3.transform:Find("Search Button").gameObject, function()
        MapSearch.Show(1, math.min(RebelWantedData.GetUnlockedLevel(), uiTab3.targetLevel), HideAll)
    end)

    local uiTab4 = {}
    uiTab4.transform = ui.left.transform:Find("Purchase")
    uiTab4.gameObject = uiTab4.transform.gameObject
    uiTab4.tips = uiTab4.transform:Find("Text").gameObject
    uiTab4.none = uiTab4.transform:Find("None").gameObject

    local uiTab9 = {}
    uiTab9.transform = ui.left.transform:Find("Fabricate")
    uiTab9.gameObject = uiTab9.transform.gameObject

    uiTab9.icon = uiTab9.transform:Find("Icon"):GetComponent("UITexture")
    uiTab9.frame = uiTab9.transform:Find("Icon/Frame"):GetComponent("UISprite")

    uiTab9.fx = uiTab9.transform:Find("Icon/Fx").gameObject
    
    uiTab9.materialList = {}
    uiTab9.materialList.transform = uiTab9.transform:Find("Materials")
    uiTab9.materialList.gameObject = uiTab9.materialList.transform.gameObject
    -- uiTab9.materialList.grid = uiTab9.materialList.transform:GetComponent("UIGrid")
    uiTab9.materialList.materials = {}
    for i = 1, 6 do
        local uiMaterial = {}
        
        uiMaterial.transform = uiTab9.materialList.transform:GetChild(i - 1)
        uiMaterial.gameObject = uiMaterial.transform.gameObject
        uiMaterial.icon = uiMaterial.transform:Find("Icon"):GetComponent("UITexture")
        uiMaterial.frame = uiMaterial.transform:Find("Frame"):GetComponent("UISprite")
        uiMaterial.num = uiMaterial.transform:Find("Num"):GetComponent("UILabel")
        uiMaterial.fx = uiMaterial.transform:Find("Fx").gameObject

        table.insert(uiTab9.materialList.materials, uiMaterial)
    end

    UIUtil.SetClickCallback(uiTab9.transform:Find("Make Button").gameObject, function()
        if uiTab9.canMake then
            if not ui.isRequesting then
                ui.isRequesting = true

                local request = ItemMsg_pb.MsgItemConvertItemRequest()
                request.type = ItemMsg_pb.eItemConvert_HeroBadge
                request.convertId = itemsToMake:Top().itemConvertData.id

                Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgItemConvertItemRequest, request, ItemMsg_pb.MsgItemConvertItemResponse, function(msg)
                    if msg.code == ReturnCode_pb.Code_OK then
                        MainCityUI.UpdateRewardData(msg.fresh)
                        PlayFx(Hide)
                    else
                        ui.isRequesting = false
                        Global.ShowError(msg.code)
                    end
                end)
            end
        else
            MessageBox.Show(TextMgr:GetText("common_ui12"))
        end
    end)

    ui.left.tabs = { [3] = uiTab3, [4] = uiTab4, [9] = uiTab9 }

    UIUtil.SetClickCallback(transform:Find("Mask").gameObject, Hide)
    UIUtil.SetClickCallback(transform:Find("Close Button").gameObject, Hide)

    EventDispatcher.Bind(ItemListData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, function()
        UpdateItemQuantityInLeftUI()

        if isMethodAvailable[9] then
            UpdateMaterialQuantityInLeftUI()
            UpdateRight()
        end
    end)

    UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)
end

function Start()
    UpdateUI()
end

function Close()
    Tooltip.HideItemSource()
    EventDispatcher.UnbindAll(_M)

    UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)

    StopFx()

    itemsToMake = nil
    isMethodAvailable = nil

    ui = nil
end
