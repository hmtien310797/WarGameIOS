module("UnionBadge", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local borderDataCount
local colorDataCount
local totemDataCount

local _ui

local badgeInfo
local change
local callback

local colorTable

local function LoadColorTable()
    if colorTable == nil then
        colorTable = {}
        local badgeColorList = TableMgr:GetUnionBadgeColorList()
		colorDataCount = #badgeColorList
		for i ,  v in pairs(badgeColorList) do
			local colorData = badgeColorList[i]
            local color = NGUIMath.HexToColor(tonumber("0x"..colorData.color.."ff"))
            local color2 = NGUIMath.HexToColor(tonumber("0x"..colorData.color2.."ff"))
            colorTable[i] = {color, color2}
		end
		
        --[[colorDataCount = badgeColorList.Length
        for i = 1, colorDataCount do
            local colorData = badgeColorList[i - 1]
            local color = NGUIMath.HexToColor(tonumber("0x"..colorData.color.."ff"))
            local color2 = NGUIMath.HexToColor(tonumber("0x"..colorData.color2.."ff"))
            colorTable[i] = {color, color2}
        end]]
    end
end

function GetBadgeColorIndex(badgeId)
    LoadColorTable()
    return Mathf.Clamp(math.floor(badgeId % 10000 / 100), 1, colorDataCount)
end

function GetBadgeColorById(badgeId)
    local colorIndex = GetBadgeColorIndex(badgeId)
    return colorTable[colorIndex][1]
end

function GetBorderColorById(badgeId)
    local colorIndex = GetBadgeColorIndex(badgeId)
    return colorTable[colorIndex][2]
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function LoadBadgeData()
    if borderDataCount == nil then
		local border = TableMgr:GetUnionBadgeBorderList()
		borderDataCount = #border
        --borderDataCount = TableMgr:GetUnionBadgeBorderList().Length
    end
    if colorDataCount == nil then
		local color = TableMgr:GetUnionBadgeColorList()
		colorDataCount = #color
		
        --colorDataCount = TableMgr:GetUnionBadgeColorList().Length
    end
    if totemDataCount == nil then
		local totem = TableMgr:GetUnionBadgeTotemList()
		totemDataCount = #totem
        --totemDataCount = TableMgr:GetUnionBadgeTotemList().Length
    end
end

function LoadBadgeObject(badge, badgeTransform)
    badge.borderTexture = badgeTransform:Find("outline icon"):GetComponent("UITexture")
    badge.totemTexture = badgeTransform:Find("totem icon"):GetComponent("UITexture")
    badge.colorTexture = badgeTransform:Find("outline icon/color"):GetComponent("UITexture")
end

function BadgeIdToInfo(badgeId)
    local badgeInfo = {}
    LoadBadgeData()
    badgeInfo.border = Mathf.Clamp(math.floor(badgeId / 10000), 1, borderDataCount)
    badgeInfo.color = Mathf.Clamp(math.floor(badgeId % 10000 / 100), 1, colorDataCount)
    badgeInfo.totem = Mathf.Clamp(badgeId % 100, 1, totemDataCount)

    return badgeInfo
end

function BadgeInfoToId(badgeInfo)
    return badgeInfo.border * 10000 + badgeInfo.color * 100 + badgeInfo.totem
end

function LoadBadgeByInfo(badge, badgeInfo)
	if badge == nil or badgeInfo == nil then
		return
	end
    local borderData = TableMgr:GetUnionBadgeBorderData(badgeInfo.border)
    local colorData = TableMgr:GetUnionBadgeColorData(badgeInfo.color)
    local color = NGUIMath.HexToColor(tonumber("0x"..colorData.color.."ff"))
    local totemData = TableMgr:GetUnionBadgeTotemData(badgeInfo.totem)

    badge.borderTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", borderData.icon)
    badge.colorTexture.color = color
    badge.totemTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", totemData.icon)
end

function LoadBadgeById(badge, badgeId)
    LoadBadgeByInfo(badge, BadgeIdToInfo(badgeId))
end

function LoadUI()
    for i, v in ipairs(_ui.colorList) do
        v.selectedObject:SetActive(badgeInfo.color == i)
    end

    local selectedColorData = TableMgr:GetUnionBadgeColorData(badgeInfo.color)
    local selectedColor = NGUIMath.HexToColor(tonumber("0x"..selectedColorData.color.."ff"))
    for i = 1, borderDataCount do
        local borderData = TableMgr:GetUnionBadgeBorderData(i)
        local borderTransform = _ui.borderGrid:GetChild(i - 1)
        if borderTransform == nil then
            borderTransform = NGUITools.AddChild(_ui.borderGrid.gameObject, _ui.borderPrefab).transform
        end
        borderTransform.name = _ui.borderPrefab.name..i
        borderTransform:Find("icon/Sprite").gameObject:SetActive(badgeInfo.border == i)
        local iconTexture = borderTransform:Find("icon"):GetComponent("UITexture")
        iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", borderData.icon)
        SetClickCallback(iconTexture.gameObject, function()
            badgeInfo.border = i
            LoadUI()
        end)
        local colorTexture = borderTransform:Find("colour"):GetComponent("UITexture")
        colorTexture.color = selectedColor
    end
    _ui.borderGrid:Reposition()
    for i = 1, totemDataCount do
        local totemData = TableMgr:GetUnionBadgeTotemData(i)
        local totemTransform = _ui.totemGrid:GetChild(i - 1)
        if totemTransform == nil then
            totemTransform = NGUITools.AddChild(_ui.totemGrid.gameObject, _ui.totemPrefab).transform
        end
        totemTransform.name = _ui.totemPrefab.name..i
        totemTransform:Find("icon/Sprite").gameObject:SetActive(badgeInfo.totem == i)
        local iconTexture = totemTransform:Find("icon"):GetComponent("UITexture")
        iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", totemData.icon)
        SetClickCallback(iconTexture.gameObject, function()
            badgeInfo.totem = i
            LoadUI()
        end)
    end
    _ui.totemGrid:Reposition()

    LoadBadgeByInfo(_ui.badge, badgeInfo)
    _ui.priceLabel.gameObject:SetActive(change)
    if change then
        _ui.priceLabel.text = UnionInfo.GetChangeBadgePrice()
    end
end

local function CreateRandomBadgeInfo()
    LoadBadgeData()
    local badgeInfo = {}
    badgeInfo.border = math.random(1, borderDataCount)
    badgeInfo.color = math.random(1, colorDataCount)
    badgeInfo.totem = math.random(1, totemDataCount)
    return badgeInfo
end

function CreateRandomBadgeId()
    return BadgeInfoToId(CreateRandomBadgeInfo())
end

function Awake()
    _ui = {}
    _ui.badge = {}
    if _ui.borderPrefab == nil then
        _ui.borderPrefab = ResourceLibrary.GetUIPrefab("Union/lisitem_outline")
    end
    if _ui.totemPrefab == nil then
        _ui.totemPrefab = ResourceLibrary.GetUIPrefab("Union/lisitem_totem")
    end
    local closeButton = transform:Find("Container/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(mask.gameObject, Hide)

    _ui.borderGrid = transform:Find("bg left up/Scroll View/Grid"):GetComponent("UIGrid")

    _ui.colorList = {}
    for i = 1, 7 do
        local color = {}
        color.transform = transform:Find(string.format("bg left up/colour widget/colour %d", i))
        color.selectedObject = color.transform:GetChild(0).gameObject
        SetClickCallback(color.transform.gameObject, function()
            badgeInfo.color = i
            LoadUI()
        end)
        _ui.colorList[i] = color
    end

    _ui.totemGrid = transform:Find("bg left down/Scroll View/Grid"):GetComponent("UIGrid")

    _ui.badge = {}
    local badgeTransform = transform:Find("bg right/badge bg")
    LoadBadgeObject(_ui.badge, badgeTransform)

    local randomButton = transform:Find("bg right/random btn"):GetComponent("UIButton")
    SetClickCallback(randomButton.gameObject, function()
        badgeInfo = CreateRandomBadgeInfo()
        LoadUI()
    end)
    _ui.priceLabel = transform:Find("bg right/btn ok/Label"):GetComponent("UILabel")
    local acceptButton = transform:Find("bg right/btn ok"):GetComponent("UIButton")
    SetClickCallback(acceptButton.gameObject, function()
        Hide()
        callback(badgeInfo)
    end)
end

function Close()
    _ui = nil
end

function Show(badgeId, _change, cb)
    badgeInfo = BadgeIdToInfo(badgeId)
    change = _change
    callback = cb
    Global.OpenUI(_M)
    LoadUI()
end
