module("Skin", package.seeall)
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

local defaultSkinId = tonumber(tableData_tGlobal.data[100232].value)
local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local skinItemDataList = {}
function GetItemDataList(skinId)
    if skinItemDataList[skinId] == nil then
        local dataList = {}
        for _, v in pairs(tableData_tItem.data) do
            if v.type == 61 and v.param1 == skinId then 
                table.insert(dataList, v)
            end
        end
        skinItemDataList[skinId] = dataList
    end

    return skinItemDataList[skinId]
end

function GetSkinGid(skinId)
    if skinId == 0 then
        UnityEngine.Debug.LogError("invalid skin id:" .. skinId)
        return 102
    end
    return tableData_tSkin.data[skinId] and tableData_tSkin.data[skinId].MapArt or 0 
end

function IsDefaultSkin(skinId)
    return skinId == defaultSkinId
end

function GetDefaultSkinTextureName()
    local baseLevel = BuildingData.GetCommandCenterData().level
    local gid = TableMgr:GetBuildCoreDataByLevel(baseLevel).picture
    local artSettingData = tableData_tArtSetting.data[gid]
    return artSettingData.icon
end

function GetDefaultSkinTexture()
    return ResourceLibrary:GetIcon("Icon/WorldMap/", GetDefaultSkinTextureName())
end

function GetSkinTextureNamePath(skinId)
    if skinId == defaultSkinId then
        return GetDefaultSkinTextureName(), "Icon/WorldMap/"
    else
        local itemDataList = GetItemDataList(skinId)
        return itemDataList[1].icon, "Icon/WorldMap/"
    end
end

local function SecondUpdate()
    local toggleIndex = _ui.toggleIndex
    if toggleIndex ~= 1 then
        return
    end

    local skinList = _ui.skinsList[toggleIndex]
    if #skinList > 0 then
        local skin = skinList[_ui.indexList[toggleIndex]]
        local skinInfoMsg = MainData.GetData().skin
        if tonumber(skin.itemDataList[1].param2) == 0 then
            return
        end
        
        local leftText, leftTime = Global.GetLeftCooldownTextLong(skin.msg.expird)
        if leftTime > 0 then
            _ui.timeLabel.text = Format(TextMgr:GetText(Text.skin_21), leftText)
        else
            if not _ui.requesting then
                MainData.RequestData()
                _ui.requesting = true
            end
        end
    end
end

function LoadUI(reset)
    local skinInfoMsg = MainData.GetData().skin
    if reset then
        _ui.skinsList[1] = {}
        local skinsMsg = skinInfoMsg.skins
        for _, v in ipairs(skinsMsg) do
            table.insert(_ui.skinsList[1], {data = tableData_tSkin.data[v.id], msg = v, itemDataList = GetItemDataList(v.id)})
        end

        if _ui.indexList[1] == 0 then
            for i, v in ipairs(_ui.skinsList[1]) do
                if v.msg.id == skinInfoMsg.select then
                    _ui.indexList[1] = i
                    break
                end
            end
        end

        _ui.skinsList[2] = {}
        for _, v in pairs(tableData_tSkin.data) do
            local have = false
            for __, vv in ipairs(skinsMsg) do
                if vv.id == v.id and vv.expird == 0 then
                    have = true
                    break
                end
                local skinData = tableData_tSkin.data[vv.id]
                if skinData.SkinType == v.SkinType and skinData.RankNeed >= v.RankNeed then
                    have = true
                    break
                end
            end
            if not have then
                table.insert(_ui.skinsList[2], {data = v, itemDataList = GetItemDataList(v.id)})
            end
        end

        _ui.skinsList[3] = {}
        for _, v in ipairs(ItemListData.GetData()) do
            local itemData = tableData_tItem.data[v.baseid]
            if itemData.type == 61 then
                local have = false
                for __, vv in ipairs(_ui.skinsList[3]) do
                    for ___, vvv in ipairs(vv.itemDataList) do
                        if vvv.id == itemData.id then
                            have = true
                            table.insert(vv.itemDataList, itemData)
                            break
                        end
                    end
                    if have then
                        break
                    end
                end
                if not have then
                    table.insert(_ui.skinsList[3], {data = tableData_tSkin.data[itemData.param1], itemDataList = {itemData}})
                end
            end
        end
        if _ui.indexList[1] > #_ui.skinsList[1] then
            _ui.indexList[1] = #_ui.skinsList[1]
        end
        for i, v in ipairs(_ui.indexList) do
            if v > #_ui.skinsList[i] then
                _ui.indexList[i] = #_ui.skinsList[i]
                break
                --[[
            elseif v == 0 then
                _ui.indexList[i] = 1
                --]]
            end
        end
        --_ui.toggleList[2].gameObject:SetActive(_ui.indexList[2] ~= 0)
        for i = 1, 3 do
            _ui.toggleList[i].gameObject:SetActive(#_ui.skinsList[i] > 0)
        end
    end
    local toggleIndex = _ui.toggleIndex
    local skinList = _ui.skinsList[toggleIndex]
    _ui.leftButton.gameObject:SetActive(_ui.indexList[toggleIndex] > 1)
    _ui.rightButton.gameObject:SetActive(#skinList > 0 and _ui.indexList[toggleIndex] < #skinList)
    SetClickCallback(_ui.leftButton.gameObject, function(go)
        _ui.indexList[toggleIndex] = _ui.indexList[toggleIndex] - 1
        _ui.skinCenterOnChild:CenterOn(_ui.skinGrid.transform:GetChild(_ui.indexList[toggleIndex] - 1))
        LoadUI(false)
    end)
    SetClickCallback(_ui.rightButton.gameObject, function(go)
        _ui.indexList[toggleIndex] = _ui.indexList[toggleIndex] + 1
        _ui.skinCenterOnChild:CenterOn(_ui.skinGrid.transform:GetChild(_ui.indexList[toggleIndex] - 1))
        LoadUI(false)
    end)

    if #skinList > 0 then
        for i, v in ipairs(skinList) do
            local skinTransform
            if i > _ui.skinGrid.transform.childCount then
                skinTransform = NGUITools.AddChild(_ui.skinGrid.gameObject, _ui.skinPrefab)
            else
                skinTransform = _ui.skinGrid.transform:GetChild(i - 1)
            end

            local skin = skinList[i]
            local itemData = skin.itemDataList[1]
            local skinTexture = skinTransform:GetComponent("UITexture")
            if skin.data.id == defaultSkinId then
                skinTexture.mainTexture = GetDefaultSkinTexture()
            else
                skinTexture.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
            end
            skinTransform.gameObject:SetActive(true)
        end
        _ui.skinGrid.repositionNow = true
        local skin = skinList[_ui.indexList[toggleIndex]]
        local itemData = skin.itemDataList[1]
        print("skin id:", skin.data.id)
        if skin.data.id == defaultSkinId then
            _ui.skinTexture.mainTexture = GetDefaultSkinTexture()
        else
            _ui.skinTexture.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
        end
        _ui.nameLabel.text = TextMgr:GetText(itemData.name)

        local attrIndex = 1
        if skin.data.SkinAttribute ~= "" then
            for v in string.gsplit(skin.data.SkinAttribute, ";") do
                local attrTransform
                if attrIndex > _ui.attrGrid.transform.childCount then
                    attrTransform = NGUITools.AddChild(_ui.attrGrid.gameObject, _ui.attrPrefab).transform
                else
                    attrTransform = _ui.attrGrid.transform:GetChild(attrIndex - 1)
                end
                local attrList = string.split(v, ",")
                local needData = TableMgr:GetNeedTextDataByAddition(tonumber(attrList[1]), tonumber(attrList[2]))
                attrTransform:GetComponent("UILabel").text = TextMgr:GetText(needData.unlockedText) .. Global.GetHeroAttrValueString(needData.additionAttr, tonumber(attrList[3]))

                attrTransform.gameObject:SetActive(true)
                attrIndex = attrIndex + 1
            end
        end
        for i = attrIndex, _ui.attrGrid.transform.childCount do
            _ui.attrGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
        end
        _ui.attrGrid.repositionNow = true
        _ui.noneAttrObject:SetActive(attrIndex == 1)

        _ui.getGrid.transform:GetChild(0):GetComponent("UILabel").text = TextMgr:GetText(skin.data.GetType)

        local selected = skinInfoMsg.select == skin.data.id
        _ui.buyButton.gameObject:SetActive(toggleIndex == 2)
        _ui.buyButton.gameObject:SetActive(false)
        _ui.selectButton.gameObject:SetActive(toggleIndex == 1 and not selected)
        _ui.selectedObject:SetActive(toggleIndex == 1 and selected)
        _ui.timeLabel.gameObject:SetActive(toggleIndex == 1 and selected and skin.msg.expird > 0)

        SetClickCallback(_ui.selectButton.gameObject, function(go)
            local req = ItemMsg_pb.MsgSkinSelectRequest()
            req.skinid = skin.data.id
            Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgSkinSelectRequest, req, ItemMsg_pb.MsgSkinSelectResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    MainData.UpdateSelectSkin(msg.select)
                else
                    Global.ShowError(msg.code)
                end
            end, true)
        end)
    end
    for i = #skinList + 1, _ui.skinGrid.transform.childCount do
        _ui.skinGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    SecondUpdate()
end

local function ReloadUI()
    _ui.requesting = false
    LoadUI(true)
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    _ui.buyButton = transform:Find("Container/bg_frane/mid/button_buy"):GetComponent("UIButton")
    _ui.selectButton = transform:Find("Container/bg_frane/mid/button_use"):GetComponent("UIButton")
    _ui.selectedObject = transform:Find("Container/bg_frane/mid/text_alreadyuse").gameObject
    transform:Find("Container/bg_frane/mid/button_tiyan").gameObject:SetActive(false)

    _ui.timeLabel = transform:Find("Container/bg_frane/mid/time_countdown"):GetComponent("UILabel")
    _ui.skinTexture = transform:Find("Container/bg_frane/mid/skin_build"):GetComponent("UITexture")
    _ui.nameLabel = transform:Find("Container/bg_frane/mid/left/top_left/Label"):GetComponent("UILabel")
    _ui.skinScrollView = transform:Find("Container/bg_frane/mid/bottom/"):GetComponent("UIScrollView")
    _ui.skinGrid = transform:Find("Container/bg_frane/mid/bottom/Grid"):GetComponent("UIGrid")
    _ui.skinCenterOnChild = transform:Find("Container/bg_frane/mid/bottom/Grid"):GetComponent("UICenterOnChild")
    _ui.skinPrefab = transform:Find("Container/bg_frane/mid/bottom/Grid/skin_list").gameObject
    _ui.defaultSpringStrength = _ui.skinCenterOnChild.springStrength

    _ui.attrGrid = transform:Find("Container/bg_frane/mid/left/buff_text/Grid"):GetComponent("UIGrid")
    _ui.attrPrefab = _ui.attrGrid.transform:GetChild(0).gameObject
    _ui.attrButton = transform:Find("Container/bg_frane/mid/left/button_all"):GetComponent("UIButton")
    SetClickCallback(_ui.attrButton.gameObject, function(go)
        Skin_check.Show()
    end)
    _ui.noneAttrObject = transform:Find("Container/bg_frane/mid/left/none").gameObject

    _ui.getGrid = transform:Find("Container/bg_frane/mid/left/get_text/Grid"):GetComponent("UIGrid")

    _ui.leftButton = transform:Find("Container/bg_frane/mid/button_left"):GetComponent("UIButton")
    _ui.rightButton = transform:Find("Container/bg_frane/mid/button_right"):GetComponent("UIButton")

    _ui.toggleList = {}
    for i = 1, 3 do
        local uiToggle = transform:Find("Container/bg_frane/page" .. i):GetComponent("UIToggle")
        _ui.toggleList[i] = uiToggle
    end

    _ui.indexList = {0, 1, 1}
    _ui.skinsList = {}
    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()
    MainData.AddListener(ReloadUI)
end

function Recenter()
    coroutine.start(function()
        if _ui == nil then
            return
        end
        coroutine.step()
        _ui.skinCenterOnChild.springStrength = 1000000
        _ui.skinCenterOnChild:CenterOn(_ui.skinGrid.transform:GetChild(_ui.indexList[_ui.toggleIndex] - 1))
        _ui.skinCenterOnChild.springStrength = _ui.defaultSpringStrength
    end)
end

function Start()
    LoadUI(true)
    for i, v in ipairs(_ui.toggleList) do
        EventDelegate.Add(v.onChange, EventDelegate.Callback(function()
            if _ui ~= nil then
                if v.value then
                    _ui.toggleIndex = i
                    LoadUI(false)
                    Recenter()
                end
            end
        end))
    end
    AddDelegate(_ui.skinCenterOnChild, "onCenter", function(centeredObject)
        local siblingIndex = centeredObject.transform:GetSiblingIndex()
        local toggleIndex = _ui.toggleIndex
        _ui.indexList[toggleIndex] = siblingIndex + 1
        LoadUI(false)
    end)
    Recenter()
end

function Close()
    TileInfo.Hide()
    Tooltip.HideItemTip()
    _ui.timer:Stop()
    MainData.RemoveListener(ReloadUI)
    _ui = nil
end

function Show(toggleIndex)
    toggleIndex = toggleIndex or 1
    Global.OpenUI(_M)
    for i, v in ipairs(_ui.toggleList) do
        v.value = i == toggleIndex
    end
    _ui.toggleIndex = toggleIndex
end
