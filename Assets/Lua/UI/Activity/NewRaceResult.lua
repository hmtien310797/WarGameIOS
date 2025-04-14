module("NewRaceResult", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local GameObject = UnityEngine.GameObject

local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
    ActivityAll.Hide()
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

function LoadUI()
    local data = NewRaceData.GetData()
    local step = #data.dayRace
    for i, v in ipairs(data.dayRace) do
        _ui.steps[i].num.text = i
        _ui.steps[i].name.text = TextMgr:GetText(v.actname)
    end
    for i = step + 1, 5 do
        _ui.steps[i].gameObject:SetActive(false)
    end
    _ui.stepGrid.cellWidth = math.floor(760 / (step - 1))
    _ui.stepGrid:Reposition()
end

local function LoadTotalRank(data)
    local maxId = NewRaceData.GetData().maxId
    print(maxId)
    for i, v in ipairs(data.strongestinfo) do
        if maxId == v.id then
            local guilBaner = ""
            if v.guildBanner ~= nil and v.guildBanner ~= "" then
                guilBaner = "[" ..v.guildBanner .. "]"
            end
            _ui.left.name.text = guilBaner .. v.charName
            _ui.left.head.mainTexture = ResourceLibrary:GetIcon("Icon/head/", v.face)
            local count = 0
            for ii, vv in ipairs(NewRaceData.GetData().topDrop.items) do
                local itemTransform 
                if ii <= 6 then
                    itemTransform = _ui.left.grid.transform:GetChild(ii - 1)
                    local itemId = vv.id
                    local itemCount = vv.num
                    local itemData = TableMgr:GetItemData(itemId)
                    local reward = {}
                    UIUtil.LoadItemObject(reward, itemTransform)
                    UIUtil.LoadItem(reward, itemData, itemCount)
                    UIUtil.SetClickCallback(itemTransform.gameObject, function(go)
                        if go == _ui.tipObject then
                            _ui.tipObject = nil
                        else
                            _ui.tipObject = go
                            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                        end
                    end)
                    count = ii
                end
            end
            for ii = count, 5 do
                _ui.left.grid.transform:GetChild(ii).gameObject:SetActive(false)
            end
            SetClickCallback(_ui.left.headgo, function()
                OtherInfo.RequestShow(v.charid)
            end)
        end
        local info = NGUITools.AddChild(_ui.right.grid.gameObject , _ui.right.item.gameObject)
        local guilBaner = ""
        if v.guildBanner ~= nil and v.guildBanner ~= "" then
            guilBaner = "[" ..v.guildBanner .. "]"
        end
        info.transform:Find("name"):GetComponent("UILabel").text = guilBaner .. v.charName
        info.transform:Find("ranknumber"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("LuckyRotary_3"), v.score)
        info.transform:Find("head/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/head/", v.face)
        info.transform:Find("text"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("PVP_ATK_Activity_ui19"), v.id)
        SetClickCallback(info.transform:Find("head").gameObject, function()
            OtherInfo.RequestShow(v.charid)
        end)
    end
    _ui.left.grid:Reposition()
    _ui.right.grid:Reposition()
    _ui.right.none:SetActive(_ui.right.grid.transform.childCount == 0)
end

function Awake()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui = {}
    _ui.stepGrid = transform:Find("Container/background/top/Grid"):GetComponent("UIGrid")
    _ui.steps = {}
    for i = 1, 5 do
        _ui.steps[i] = {}
        _ui.steps[i].gameObject = transform:Find(string.format("Container/background/top/Grid/flag%d", i)).gameObject
        _ui.steps[i].num = transform:Find(string.format("Container/background/top/Grid/flag%d/number", i)):GetComponent("UILabel")
        _ui.steps[i].name = transform:Find(string.format("Container/background/top/Grid/flag%d/name", i)):GetComponent("UILabel")
    end
    _ui.left = {}
    _ui.left.headgo = transform:Find("Container/background/mid/left/head").gameObject
    _ui.left.head = transform:Find("Container/background/mid/left/head/Texture"):GetComponent("UITexture")
    _ui.left.name = transform:Find("Container/background/mid/left/name"):GetComponent("UILabel")
    _ui.left.grid = transform:Find("Container/background/mid/left/Grid"):GetComponent("UIGrid")

    _ui.right = {}
    _ui.right.grid = transform:Find("Container/background/mid/right/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.right.item = transform:Find("Container/background/mid/right/list")
    _ui.right.none = transform:Find("Container/background/mid/right/none").gameObject

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show()
    if _ui == nil then
        Global.OpenUI(_M)
        NewRaceData.RequestGetMilitaryStrongest(LoadTotalRank)
    end
end
