module("GrowRewards", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local Format = System.String.Format
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _ui

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

function LoadUI()
    local missionMsg = _ui.missionMsg
    local missionData = _ui.missionData

    _ui.growHint:SetActive(missionData.type == 100)
    _ui.dailyHint:SetActive(missionData.type == 2)
    _ui.dailyHintLabel.text = Format(TextMgr:GetText(Text.DailyMission_reward), missionData.number)
    local itemIndex = 1
    for v in string.gsplit(missionData.item, ";") do
        local itemTable = string.split(v, ":")
        local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
        local itemData = TableMgr:GetItemData(itemId)
        local itemTransform
        if itemIndex > _ui.listGrid.transform.childCount then
            itemTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.itemPrefab).transform
        else
            itemTransform = _ui.listGrid:GetChild(itemIndex - 1)
        end
        local reward = {}
        UIUtil.LoadItemObject(reward, itemTransform)
        UIUtil.LoadItem(reward, itemData, itemCount)
        UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
            end
        end)
        itemTransform.gameObject:SetActive(true)
        itemIndex = itemIndex + 1
    end

    for i = itemIndex, _ui.listGrid.transform.childCount do
        _ui.listGrid:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.listGrid.repositionNow = true

    local completed = missionMsg.value >= missionData.number
	UIUtil.SetBtnEnable(_ui.getButton ,"btn_2", "btn_4", completed and not missionMsg.rewarded)

    if missionMsg.rewarded then
        _ui.getLabel.text = TextMgr:GetText(Text.SectionRewards_ui5)
    else
        _ui.getLabel.text = TextMgr:GetText(Text.mail_ui12)
    end
    SetClickCallback(_ui.getButton.gameObject , function()
        if completed and not missionMsg.rewarded then
            local req = ClientMsg_pb.MsgUserMissionRewardRequest();
            req.taskid = missionMsg.id
            Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.FloatError(msg.code)
                else
                    AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
                    GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
                    MainCityUI.UpdateRewardData(msg.fresh)
                    Hide()
                    Global.ShowReward(msg.reward)
                    MissionListData.SetRewarded(msg.taskid)
                    MissionListData.UpdateList(msg.quest)
                    -- send data report-----------
                    GUIMgr:SendDataReport("umission", "" .. msg.taskid, "completed", "0")
                    if msg.taskid >= 28 and msg.taskid <= 33 then
                        local missionData = TableMgr:GetMissionData(msg.taskid)
                        GUIMgr:SendDataReport("efun", "daily" .. missionData.number)
                    end
                    ------------------------------
                end
            end, true)
        elseif not missionMsg.rewarded then
            FloatText.Show(TextMgr:GetText(Text.SectionRewards_ui4))
        end
    end)
end

function Awake()
    _ui = {}
	_ui.bg = transform:Find("Container")
	_ui.listGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.getButton = transform:Find("Container/bg_frane/button"):GetComponent("UIButton")
	_ui.getLabel = transform:Find("Container/bg_frane/button/Label"):GetComponent("UILabel")
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.growHint = transform:Find("Container/bg_frane/bg_hint").gameObject
	_ui.dailyHint = transform:Find("Container/bg_frane/bg_dailymission").gameObject
	_ui.dailyHintLabel = transform:Find("Container/bg_frane/bg_dailymission/text"):GetComponent("UILabel")
	
	SetClickCallback(_ui.bg.gameObject , Hide)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show(missionMsg, missionData)
    Global.OpenUI(_M)
    _ui.missionMsg = missionMsg
    _ui.missionData = missionData
    LoadUI()
end

function ShowGradeUp(itemid,level)
    Global.OpenUI(_M)
    _ui.missionMsg = missionMsg
    _ui.missionData = missionData
   --  LoadUI()
	_ui.dailyHintLabel.text = Format(TextMgr:GetText(Text.growreward_claim), level)
	
	local itemIndex = 1
	local showList = TableMgr:GetDropShowData(itemid)
	if #showList > 0 then
		for i , v in pairs(showList) do
			--print("=====" .. showList[i].contentId)
			local itemId = tonumber(showList[i].contentId)
			local itemCount = tonumber(showList[i].contentNumber)

			local itemData = TableMgr:GetItemData(itemId)
			local itemTransform
			if itemIndex > _ui.listGrid.transform.childCount then
				itemTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.itemPrefab).transform
			else
				itemTransform = _ui.listGrid:GetChild(itemIndex - 1)
			end
			local reward = {}
			UIUtil.LoadItemObject(reward, itemTransform)
			UIUtil.LoadItem(reward, itemData, itemCount)
			UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
				if go == _ui.tipObject then
					_ui.tipObject = nil
				else
					_ui.tipObject = go
					Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
				end
			end)
			itemTransform.gameObject:SetActive(true)
			itemIndex = itemIndex + 1
				
		end
	end
	

    for i = itemIndex, _ui.listGrid.transform.childCount do
        _ui.listGrid:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.listGrid.repositionNow = true
	
	
end
