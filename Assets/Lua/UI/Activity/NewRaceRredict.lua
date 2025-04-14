module("NewRaceRredict", package.seeall)

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
    local childCount = _ui.grid.transform.childCount   --grid下的子集类
    for i, v in ipairs(data.topDrop.items) do
        local itemTransform 
        if i - 1 < childCount then  --池中存放item的数据
            itemTransform = _ui.grid.transform:GetChild(i - 1)
        else
            itemTransform = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
        end
		local itemId = v.id
		local itemCount = v.num
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
    end
    for i = #data.topDrop.items, childCount - 1 do     --超出长度后进行销毁
        GameObject.Destroy(_ui.grid.transform:GetChild(i).gameObject)
    end
    CountDown.Instance:Add("NewRaceRredict", data.dayRace[1].startTime, function(t)
        if data.dayRace[1].startTime >= Serclimax.GameTime.GetSecTime() then
            _ui.time.text = t
        else
            NewRaceData.RequestData()
        end
    end)
end

function Awake()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui = {}
    _ui.time = transform:Find("Container/bg_frane/right/time"):GetComponent("UILabel")
    _ui.grid = transform:Find("Container/bg_frane/right/reward/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item = transform:Find("Container/bg_frane/right/reward/Scroll View/Grid/Item_CommonNew")
    _ui.help = transform:Find("Container/bg_frane/right/rule_icon").gameObject

    NewRaceData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    NewRaceData.NotifyUIOpened()
    SetClickCallback(_ui.help, NewRaceHelp.Show)
end

function Close()
    CountDown.Instance:Remove("NewRaceRredict")
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    NewRaceData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show()
    NewRaceData.RequestData(false)
    Global.OpenUI(_M)
end
