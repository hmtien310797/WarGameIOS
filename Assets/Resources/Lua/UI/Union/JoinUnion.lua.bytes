module("JoinUnion", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local callback
local itemlist = {}
local _ui

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	for i, v in ipairs(itemlist) do
		if go == v then
			local itemdata = TableMgr:GetItemData(tonumber(go.name))
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
		    return
		end
	end
	Tooltip.HideItemTip()
end

function Hide()
    Global.CloseUI(_M)
    if callback ~= nil then
        callback()
        callback = nil
    end
end

function CloseAll()
    UnionList.CloseAll()
    Hide()
end

function GetCreateCost()
    local dataId
    local baseLevel = BuildingData.GetCommandCenterData().level
    if Global.DistributeInHome() then
        if baseLevel < tableData_tUnionNum.data[27].num then
            dataId = 26
        else
            dataId = 25
        end
    else
        if baseLevel < tableData_tUnionNum.data[28].num then
            dataId = 29
        else
            dataId = 22
        end
    end

    return tableData_tUnionNum.data[dataId].num
end

function LoadUI()
	UIUtil.SetBtnEnable(_ui.foundButton ,"btn_3", "btn_4", MoneyListData.GetDiamond() >= GetCreateCost())
end

function Awake()
    _ui = {}
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	itemlist = {}
    local closeButton = transform:Find("widget/close btn"):GetComponent("UIButton")
    local mask = transform:Find("mask")
    local rewardobj = transform:Find("widget/Sprite")
    local rewardgrid = transform:Find("widget/Sprite/Grid"):GetComponent("UIGrid")
	local itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    if MissionListData.GetMissionData(10311) == nil then
    	rewardobj.localScale = Vector3(1,0,1)
    else
    	local missionData = TableMgr:GetMissionData(10311)
    	for v in string.gsplit(missionData.item, ";") do
            local itemTable = string.split(v, ":")
            local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
            local itemData = TableMgr:GetItemData(itemId)
            local itemTransform = NGUITools.AddChild(rewardgrid.gameObject, itemPrefab.gameObject).transform
            itemTransform.name = itemId
            local item = {}
            UIUtil.LoadItemObject(item, itemTransform)
            UIUtil.LoadItem(item, itemData, itemCount)
			table.insert(itemlist, itemTransform.gameObject)
        end
        rewardgrid:Reposition()
    end
    
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(mask.gameObject, Hide)

    local joinButton = transform:Find("widget/join btn"):GetComponent("UIButton")
    SetClickCallback(joinButton.gameObject, function()
        UnionList.Show(true)
    end)

    local foundButton = transform:Find("widget/found btn"):GetComponent("UIButton")
    local foundLabel = transform:Find("widget/found btn/number"):GetComponent("UILabel")
    foundLabel.text = GetCreateCost()
    _ui.foundButton = foundButton
    SetClickCallback(foundButton.gameObject, function()
        if MoneyListData.GetDiamond() < GetCreateCost() then
            Global.ShowNoEnoughMoney()
        else
            UnionList.Show(false)
        end
    end)
    MoneyListData.AddListener(LoadUI)
end

function Show(_callback)
    Global.OpenUI(_M)
    callback = _callback
    LoadUI()
end

function Close()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	MoneyListData.RemoveListener(LoadUI)
	_ui = nil
end
