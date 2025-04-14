module("UnionTrain", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime

local _ui
function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    UnionSuperOre.CloseAll()
    Hide()
end

local function UpdateTime()
    local buildingMsg = _ui.buildingMsg
    local buildingData = _ui.buildingData
    local totalTime = #_ui.msg.drops * _ui.rewardInterval
    local startTime = _ui.msg.startTime
    local endTime = startTime + totalTime
    local serverTime = GameTime.GetSecTime()
    local leftCooldownSecond = Global.GetLeftCooldownSecond(endTime)
    if leftCooldownSecond >= 0 then
        _ui.timeSlider.value = Global.GetLeftCooldownMillisecond(endTime) / (totalTime * 1000)
        _ui.timeLabel.text = Global.SecondToTimeLong(leftCooldownSecond)
    end
    for i, v in ipairs(_ui.rewardList) do
        local rewardEndTime = startTime + i * _ui.rewardInterval
        local rewardStartTime = rewardEndTime - _ui.rewardInterval

        v.takenTransform.gameObject:SetActive(serverTime >= rewardEndTime)
        v.inactiveTransform.gameObject:SetActive(serverTime < rewardStartTime)
        v.activeTransform.gameObject:SetActive(serverTime >= rewardStartTime and serverTime < rewardEndTime)
        v.itemTransform.gameObject:SetActive(serverTime >= rewardStartTime)
        v.unknownTransform.gameObject:SetActive(serverTime < rewardStartTime)
        if serverTime >= rewardStartTime and serverTime < rewardEndTime then
            v.timeSprite.fillAmount = Global.GetLeftCooldownMillisecond(rewardEndTime) / (_ui.rewardInterval * 1000)
            v.timeLabel.text = Global.GetLeftCooldownTextLong(rewardEndTime) 
        end
    end
end

function LoadUI()
    _ui.buildingMsg = UnionBuildingData.GetDataByBaseId(_ui.buildingDataId)
    if _ui.buildingMsg == nil then
        CloseAll()
        FloatText.Show(TextMgr:GetText(Text.union_ore25))
        return
    end
    for i, v in ipairs(_ui.msg.drops) do
        local rewardTransform
        if i > _ui.rewardTable.transform.childCount then
            rewardTransform = NGUITools.AddChild(_ui.rewardTable.transform.gameObject, _ui.rewardPrefab).transform
        else
            rewardTransform = _ui.rewardTable.transform:GetChild(i - 1)
        end
        local reward = {}
        reward.transform = rewardTransform
        reward.bgSprite = rewardTransform:Find("base")
        reward.nameLabel = rewardTransform:Find("Label"):GetComponent("UILabel")
        reward.takenTransform = rewardTransform:Find("gou")
        reward.inactiveTransform = rewardTransform:Find("gou02")
        reward.activeTransform = rewardTransform:Find("gou01")
        reward.timeSprite = rewardTransform:Find("gou01/Sprite"):GetComponent("UISprite")
        reward.timeLabel = rewardTransform:Find("gou01/Label"):GetComponent("UILabel")
        reward.itemTransform = rewardTransform:Find("listinfo_item0.6")
        reward.qualitySprite = rewardTransform:Find("listinfo_item0.6"):GetComponent("UISprite")
        reward.itemIcon = rewardTransform:Find("listinfo_item0.6/icon_item"):GetComponent("UITexture")
        reward.countLabel = rewardTransform:Find("listinfo_item0.6/num_item"):GetComponent("UILabel")
        reward.numberLabel = rewardTransform:Find("listinfo_item0.6/bg_num/txt_num"):GetComponent("UILabel")
        reward.numberBg = rewardTransform:Find("listinfo_item0.6/bg_num")
        reward.unknownTransform = rewardTransform:Find("Sprite")

        reward.bgSprite.gameObject:SetActive(i % 2 == 0)
        reward.nameLabel.text = String.Format(TextMgr:GetText(Text.union_train4), i)

        local itemMsg = v.items[1]
        local itemData = TableMgr:GetItemData(itemMsg.id)
        reward.qualitySprite.spriteName = "bg_item"..itemData.quality
        reward.itemIcon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
        reward.countLabel.text = itemMsg.num
        reward.countLabel.gameObject:SetActive(itemMsg.num > 1)
        reward.numberBg.gameObject:SetActive(itemData.param1 > 1)
        local levelText = Global.GetItemLevelText(itemData)
        if levelText ~= nil then
            reward.numberBg.gameObject:SetActive(true)
            reward.numberLabel.text = levelText
        else
            reward.numberBg.gameObject:SetActive(false)
        end

        _ui.rewardList[i] = reward
    end
    _ui.rewardTable.repositionNow = true
    UpdateTime()
end

function Awake()
    _ui = {}
    _ui.rewardList = {}
    _ui.rewardInterval = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.TrainFieldRewardInterval).value)
    local mask = transform:Find("mask")
    local container = transform:Find("Container")
    local closeButton = transform:Find("Container/base/top/close btn"):GetComponent("UIButton")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(container.gameObject, Hide)

    _ui.rewardPrefab = transform:Find("Container/base/mid/Subject").gameObject
    _ui.timeSlider = transform:Find("Container/base/bg"):GetComponent("UISlider")
    _ui.timeLabel = transform:Find("Container/base/bg/Label"):GetComponent("UILabel")
    _ui.rewardScrollView = transform:Find("Container/base/mid/Scroll View"):GetComponent("UIScrollView")
    _ui.rewardTable = transform:Find("Container/base/mid/Scroll View/Table"):GetComponent("UITable")
    _ui.retreatButton = transform:Find("Container/base/button"):GetComponent("UIButton")
    SetClickCallback(_ui.retreatButton.gameObject, function()
        local req = MapMsg_pb.CancelPathRequest()
        req.taruid = _ui.buildingMsg.uid
        Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                CloseAll()
                if _ui ~= nil then
                    local pos = _ui.buildingMsg.pos
                    UnionInfo.CloseAll()
                    MainCityUI.ShowWorldMap(pos.x, pos.y, true, nil)
                end
            else
                Global.ShowError(msg.code)
            end
        end)
    end)
end

function Update()
    UpdateTime()
end

function Close()
    _ui = nil
    if not GUIMgr.Instance:IsMenuOpen("UnionInfo") then
	end
end

function Show(buildingDataId)
    local req = GuildMsg_pb.MsgGuildTrainFieldInfoRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildTrainFieldInfoRequest, req, GuildMsg_pb.MsgGuildTrainFieldInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            Global.OpenUI(_M)
            _ui.msg = msg
            _ui.buildingDataId = buildingDataId
            LoadUI()
        else
            Global.ShowError(msg.code)
        end
    end, false)
end
