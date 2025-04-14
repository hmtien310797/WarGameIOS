module("NewRaceRank", package.seeall)

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

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function LoadStepRank(data)
    for i, v in ipairs(data.ranklist) do
        if v.actid > 0 then
            local info = NGUITools.AddChild(_ui.container1.table.gameObject , _ui.container1.item.gameObject)
            local paraController = info:GetComponent("ParadeTableItemController")
            info.transform:Find("bg_list/Sprite/Label"):GetComponent("UILabel").text = TextMgr:GetText(NewRaceData.GetRaceDataByActId(v.actid).actname)
            info.transform:Find("bg_list/Sprite/time"):GetComponent("UILabel").text = TextMgr:GetText("NewRace_8") .. v.actid

            local grid = info.transform:Find("Item_open01/Grid"):GetComponent("UIGrid")
            local gridItem = info.transform:Find("Item_open01/info")
            local openHeight = info:GetComponent("UIWidget").height
            info.transform:Find("bg_list/btn_open").gameObject:SetActive(#v.ranklist > 0)
            for ii, vv in ipairs(v.ranklist) do
                local item = NGUITools.AddChild(grid.gameObject , gridItem.gameObject)
                item.gameObject:SetActive(true)
                local guilBaner = ""
                if vv.guildBanner ~= nil and vv.guildBanner ~= "" then
                    guilBaner = "[" ..vv.guildBanner .. "]"
                end
                item.transform:Find("name"):GetComponent("UILabel").text = guilBaner .. vv.charName
                item.transform:Find("points"):GetComponent("UILabel").text = vv.score
                item.transform:Find("no.1"):GetComponent("UILabel").text = ii
                openHeight = openHeight + item:GetComponent("UIWidget").height
            end
            grid:Reposition()
            paraController:SetItemOpenHeight(openHeight)
        end
    end
    _ui.container1.table:Reposition()
end

local function LoadTotalRank(data)
    for i, v in ipairs(data.ranklist) do
        if v.actid == 0 then
            for ii, vv in ipairs(v.ranklist) do
                local info = NGUITools.AddChild(_ui.container2.grid.gameObject , _ui.container2.item.gameObject)
                local guilBaner = ""
                if vv.guildBanner ~= nil and vv.guildBanner ~= "" then
                    guilBaner = "[" ..vv.guildBanner .. "]"
                end
                info.transform:Find("name"):GetComponent("UILabel").text = guilBaner .. vv.charName
                info.transform:Find("number"):GetComponent("UILabel").text = vv.score == 0 and "" or vv.score
                info.transform:Find("title/no.1"):GetComponent("UILabel").text = ii
                info.transform:Find("title/chest").gameObject:SetActive(ii == 1)

                local grid = info.transform:Find("Grid"):GetComponent("UIGrid")
                for iii, vvv in ipairs(vv.rankdrop.items) do
                    if iii <= 6 then
                        local item = grid.transform:GetChild(iii - 1)
                        local itemdata = TableMgr:GetItemData(vvv.id)
                        local reward = {}
                        UIUtil.LoadItemObject(reward, item)
                        UIUtil.LoadItem(reward, itemdata, vvv.num)
                        UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
                            if go == _ui.tipObject then
                                _ui.tipObject = nil
                            else
                                _ui.tipObject = go
                                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
                            end
                        end)
                    end
                end
                for x = #vv.rankdrop.items, 5 do
                    grid.transform:GetChild(x).gameObject:SetActive(false)
                end
                grid:Reposition()
            end
        end
    end
end

function Awake()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, Hide)
    _ui = {}
    _ui.btn_close = transform:Find("background/close btn").gameObject

    _ui.container1 = {}
    _ui.container1.scrollview = transform:Find("widget/Container01/base/Scroll View"):GetComponent("UIScrollView")
    _ui.container1.table = transform:Find("widget/Container01/base/Scroll View/Table"):GetComponent("UITable")
    _ui.container1.item = transform:Find("widget/Container01/ItemInfo01")

    _ui.container2 = {}
    _ui.container2.scrollview = transform:Find("widget/Container02/base/Scroll View"):GetComponent("UIScrollView")
    _ui.container2.grid = transform:Find("widget/Container02/base/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.container2.item = transform:Find("widget/Container02/base/term01")

    transform:Find("widget/text"):GetComponent("UILabel").text = TableMgr:GetGlobalData(100239).value == 0 and "" or String.Format(TextMgr:GetText("ui_RaceRank_hint"), TableMgr:GetGlobalData(100239).value)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    SetClickCallback(_ui.btn_close, Hide)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
    NewRaceData.RequestGetMilitaryRaceRank(LoadStepRank)
    NewRaceData.RequestGetMilitaryRaceTotRank(LoadTotalRank)
end
