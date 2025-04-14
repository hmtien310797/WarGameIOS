module("City_lord", package.seeall)
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

local _ui
local myGuildId
local timer = 0
local fortressDataList

function Hide()
    Global.CloseUI(_M)
end

local function UpdateOfficialTime(official, serverTime)
    local infoMsg = official.infoMsg
    local cooling = official.msg ~= nil and serverTime < official.msg.appointTime + official.data.CdTime
    if cooling then
        official.timeLabel.gameObject:SetActive(true)
        official.timeLabel.text = Format(TextMgr:GetText(Text.Officia_cd_time), Global.GetLeftCooldownTextLong(official.msg.appointTime + official.data.CdTime))
    else
        official.timeLabel.gameObject:SetActive(false)
    end
    local guildId = infoMsg.rulingInfo.guildId
    if guildId ~= 0 and guildId == myGuildId then
        local startTime = infoMsg.contendStartTime
        local endTime = infoMsg.contendEndTime
        local defense = serverTime > startTime and serverTime < endTime
        official.defenseObject:SetActive(defense)
        official.defenseLabelObject:SetActive(official.data.type ~= 2)
        official.myObject:SetActive(not defense)
    end
    local hasOfficial = official.msg ~= nil and official.msg.charId ~= 0
    local normalSprite = hasOfficial and "btn_3" or "btn_1"
    UIUtil.SetBtnEnable(official.appointButton, normalSprite, "btn_4", not cooling) 
end

local function UpdateTime()
    local serverTime = GameTime.GetSecTime()
    for i, v in ipairs(_ui.strongholdList) do
        UpdateOfficialTime(v.official, serverTime)
    end

    for i, v in ipairs(_ui.fortressMsgList) do
        local fortress = _ui.fortressList[i]
        for ii, vv in ipairs(fortress.officialList) do
            UpdateOfficialTime(vv, serverTime)
        end
        local infoMsg = v
        local guildId = infoMsg.rulingInfo.guildId
        if myGuildId ~=0 and guildId == myGuildId then
            local startTime = infoMsg.contendStartTime
            local endTime = infoMsg.contendEndTime
            local defense = serverTime > startTime and serverTime < endTime
            fortress.stateLabel.text = TextMgr:GetText(defense and Text.FortressLord_18 or Text.FortressLord_17)
        end
    end
end

local function DeposeOfficial(charId)
    MessageBox.Show(TextMgr:GetText(Text.official_recall_tips), function()
        local req = GuildMsg_pb.MsgGuildDeposeOfficialRequest()
        req.charId = charId
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildDeposeOfficialRequest, req, GuildMsg_pb.MsgGuildDeposeOfficialResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                UnionOfficialData.UpdateData(msg.officialList)
                TileInfo.Hide()
            else
                Global.ShowError(msg.code)
            end
        end, false) 
    end,
    function()
    end)
end

local function LoadOfficialObject(official, officialTransform)
    official.icon = officialTransform:Find("Container/official_icon"):GetComponent("UITexture")
    official.nameLabel = officialTransform:Find("Container/official_icon/official_name"):GetComponent("UILabel") 
    official.playerLabel = officialTransform:Find("Container/official_icon/player_name"):GetComponent("UILabel")
    official.buffGrid = officialTransform:Find("Container/bg_buff/Grid"):GetComponent("UIGrid")
    official.buffPrefab = officialTransform:Find("Container/bg_buff/Grid/buff (1)").gameObject
    official.appointButton = officialTransform:Find("Container/bg_my/button"):GetComponent("UIButton")
    official.appointLabel = officialTransform:Find("Container/bg_my/button/text"):GetComponent("UILabel")
    official.timeLabel = officialTransform:Find("Container/bg_my/cd_time"):GetComponent("UILabel")
    official.myObject = officialTransform:Find("Container/bg_my").gameObject
    official.otherObject = officialTransform:Find("Container/bg_other").gameObject
    official.otherLabelObject = officialTransform:Find("Container/bg_other/other").gameObject
    official.defenseObject = officialTransform:Find("Container/bg_defense").gameObject
    official.defenseLabelObject = officialTransform:Find("Container/bg_defense/defense").gameObject
end

function LoadOfficialBuff(buffId, buffGrid, buffPrefab)
    local buffIndex = 1
    local buffData = tableData_tSlgBuff.data[buffId]
    if buffData ~= nil then
        for v in string.gsplit(buffData.Effect, ";") do
            local buffTransform
            if buffIndex > buffGrid.transform.childCount then
                buffTransform = NGUITools.AddChild(buffGrid.gameObject, buffPrefab)
            else
                buffTransform = buffGrid.transform:GetChild(buffIndex - 1)
            end
            local effectList = string.split(v, ",")
            local buffName = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(effectList[2], tonumber(effectList[3])))
            local buffValue = tonumber(effectList[4])
            if buffValue >= 0 then
                buffValue = " +" .. buffValue
            end
            buffTransform:GetComponent("UILabel").text = string.format("%s%s%s%%%s", GovernmentData.ColorStr.OfficialAtt, buffName, buffValue, GovernmentData.ColorStr.End)
            buffIndex = buffIndex + 1
            buffTransform.gameObject:SetActive(true)
        end
    end

    for i = buffIndex, buffGrid.transform.childCount do
        buffGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    buffGrid.repositionNow = true
end

local function LoadOfficial(official, msg, data, infoMsg)
    local guildId = infoMsg.rulingInfo.guildId
    official.msg = msg
    official.data = data
    official.infoMsg = infoMsg
    official.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Government/", data.icon)
    official.nameLabel.text = TextMgr:GetText(data.name)

    LoadOfficialBuff(data.buffid, official.buffGrid, official.buffPrefab)
    local charId = msg ~= nil and msg.charId or 0
    SetClickCallback(official.playerLabel.gameObject, function(go)
        if charId ~= 0 then
            OtherInfo.RequestShow(charId)
        end
    end)
    if guildId == 0 then
        official.playerLabel.text = TextMgr:GetText(Text.union_nounion)
        official.otherObject:SetActive(true)
        official.otherLabelObject:SetActive(data.type ~= 2)
        official.myObject:SetActive(false)
        official.defenseObject:SetActive(false)
    else
        official.appointButton.gameObject:SetActive(false)
        if msg ~= nil and charId ~= 0 then
            official.playerLabel.text = string.format("[%s]%s", msg.guildBanner, msg.charName) 
        else
            official.playerLabel.text = TextMgr:GetText(Text.union_nounion)
        end
        if guildId == myGuildId then
            if UnionInfoData.IsUnionLeader() then
                official.appointButton.gameObject:SetActive(true)
                local startTime = infoMsg.contendStartTime
                local endTime = infoMsg.contendEndTime
                if charId ~= 0 then
                    official.appointLabel.text = TextMgr:GetText(Text.GOV_ui46)
                else
                    official.appointLabel.text = TextMgr:GetText(Text.GOV_ui44)
                end

                SetClickCallback(official.appointButton.gameObject, function(go)
                    local serverTime = GameTime.GetSecTime()
                    if serverTime > startTime and serverTime < endTime then
                        MessageBox.Show(TextMgr:GetText(Text.war_time_limit))
                        return
                    end

                    local cooling = msg ~= nil and serverTime < msg.appointTime + data.CdTime
                    if cooling then
                        FloatText.Show(TextMgr:GetText(Text.Officia_cd_time2))
                        return
                    end

                    if charId ~= 0 then
                        DeposeOfficial(msg.charId)
                    else
                        UnionMemberLevel.Show(myGuildId, false, true, data.id, _ui.charId)
                    end
                end)
            end
        else
            official.myObject:SetActive(false)
            official.otherObject:SetActive(data.type ~= 2)
            official.defenseObject:SetActive(false)
        end
    end
end

local function LoadStronghold()
    local strongholdList = {}
    for _, v in pairs(tableData_tUnionOfficial.data) do
        if v.type == 1 then
            local strongholdMsg = StrongholdData.GetStrongholdData(v.cityid)
            if strongholdMsg ~= nil and strongholdMsg.available then
                table.insert(strongholdList, {data = v, infoMsg = strongholdMsg, msg = UnionOfficialData.GetDataById(v.id)})
            end
        end
    end

    table.sort(strongholdList, function(v1, v2)
        local guildId1 = v1.infoMsg.rulingInfo.guildId
        local guildId2 = v2.infoMsg.rulingInfo.guildId
        local isMyGuild1 = guildId1 == myGuildId
        local isMyGuild2 = guildId2 == myGuildId
        if isMyGuild1 == isMyGuild2 then
            return v1.data.order < v2.data.order
        else
            return isMyGuild1 and not isMyGuild2
        end
    end)

    for i, v in ipairs(strongholdList) do
        local officialTransform
        if i > _ui.strongholdGrid.transform.childCount then
            officialTransform = NGUITools.AddChild(_ui.strongholdGrid.gameObject, _ui.strongholdPrefab).transform
        else
            officialTransform = _ui.strongholdGrid.transform:GetChild(i - 1)
        end
        officialTransform.gameObject:SetActive(true)
        local official = {}
        LoadOfficialObject(official, officialTransform)
        v.official = official
        local msg = v.msg
        local data = v.data
        local infoMsg = v.infoMsg
        LoadOfficial(official, msg, data, infoMsg)
        officialTransform.name = i
    end

    for i = #strongholdList + 1, _ui.strongholdGrid.transform.childCount do
        officialTransform = _ui.strongholdGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.strongholdList = strongholdList
end

local function LoadFortress()
    local fortressMsgList = {}
    for _, v in ipairs(FortressData.GetAllFortressData()) do
        if v.available then
            table.insert(fortressMsgList, v)
        end
    end

    table.sort(fortressMsgList, function(v1, v2)
        local guildId1 = v1.rulingInfo.guildId
        local guildId2 = v2.rulingInfo.guildId
        local isMyGuild1 = guildId1 == myGuildId
        local isMyGuild2 = guildId2 == myGuildId
        if isMyGuild1 == isMyGuild2 then
            return v1.subtype < v2.subtype
        else
            return isMyGuild1 and not isMyGuild2
        end
    end)

    for i, v in ipairs(fortressMsgList) do
        local fortress = _ui.fortressList[i]
        fortress.officialList = {}
        for ii, vv in ipairs(fortressDataList[v.subtype]) do
            local officialTransform
            if ii > fortress.grid.transform.childCount then
                officialTransform = NGUITools.AddChild(fortress.grid.gameObject, _ui.strongholdPrefab).transform
            else
                officialTransform = fortress.grid.transform:GetChild(ii - 1)
            end
            local official = {}
            fortress.officialList[ii] = official
            LoadOfficialObject(official, officialTransform)
            local msg = UnionOfficialData.GetDataById(vv.id)
            local data = vv
            local infoMsg = v
            LoadOfficial(official, msg, data, infoMsg)
            local fortressRuleData = tableData_tFortressRule.data[vv.cityid]
            fortress.nameLabel.text = TextMgr:GetText(fortressRuleData.name)
            local guildId = infoMsg.rulingInfo.guildId
            local isMine = myGuildId ~= 0 and guildId == myGuildId;
            fortress.stateLabel.text = TextMgr:GetText(isMine and Text.FortressLord_17 or Text.FortressLord_16)
            fortress.bgSprite.spriteName = isMine and "title_bg3" or "separate_bg2"
        end
        fortress.gameObject:SetActive(true)
    end
    _ui.fortressMsgList = fortressMsgList

    for i = #fortressMsgList + 1, 4 do
        local fortress = _ui.fortressList[i]
        fortress.gameObject:SetActive(false)
    end

    _ui.fortressTable.repositionNow = true
end

function LoadUI(enType)
    myGuildId = UnionInfoData.GetGuildId()
    LoadStronghold()
    LoadFortress()
    UpdateTime()

    local lord_coroutine =  coroutine.start(function()
        coroutine.step()
        if _ui ~= nil then
            if enType == Common_pb.SceneEntryType_Stronghold then
                transform:Find("Container/page1"):GetComponent("UIToggle"):Set(true)
            elseif enType == Common_pb.SceneEntryType_Fortress then
                transform:Find("Container/page2"):GetComponent("UIToggle"):Set(true)
            end
        end
    end)

end

local function LoadFortressDataList()
    if fortressDataList == nil then
        fortressDataList = {{}, {}, {}, {}}
        for _, v in ipairs(tableData_tUnionOfficial.data) do
            if v.type == 2 then
                table.insert(fortressDataList[v.cityid], v)
            end
        end
    end
end

function Awake()
    LoadFortressDataList()

    _ui = {}
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    local mask = transform:Find("mask")
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    _ui.strongholdPrefab = ResourceLibrary.GetUIPrefab("Government/listitem_city")
    _ui.strongholdGrid = transform:Find("Container/Container1/Scroll View/Grid"):GetComponent("UIGrid")

    local fortressTableTransform = transform:Find("Container/Container2/bg_mid/Scroll View/Table")
    _ui.fortressTable = fortressTableTransform:GetComponent("UITable")
    local fortressList = {}
    for i = 1, 4 do
        local fortress = {}
        fortress.transform = fortressTableTransform:Find(string.format("bg_official (%d)", i))
        fortress.gameObject = fortress.transform.gameObject
        fortress.bgSprite = fortress.transform:Find("bg_title"):GetComponent("UISprite")
        fortress.nameLabel = fortress.transform:Find("bg_title/title"):GetComponent("UILabel")
        fortress.stateLabel = fortress.transform:Find("bg_title/title (1)"):GetComponent("UILabel")
        fortress.grid = fortress.transform:Find("Grid"):GetComponent("UIGrid")
        fortressList[i] = fortress
    end
    _ui.fortressList = fortressList

    _ui.toggleList = {}
    for i = 1, 2 do
        local uiToggle = transform:Find(string.format("Container/page%d", i)):GetComponent("UIToggle")
        EventDelegate.Add(uiToggle.onChange, EventDelegate.Callback(function()
            if _ui ~= nil then
                if uiToggle.value then
                    if i == 2 then
                        _ui.fortressTable.repositionNow = true
                    end
                end
            end
        end))
    end

    UnionOfficialData.AddListener(LoadUI)
end

function LateUpdate()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end


function Close()
    UnionOfficialData.RemoveListener(LoadUI)
    if lord_coroutine ~= nil then
        coroutine.stop(lord_coroutine)
        lord_coroutine = nil
    end
    _ui = nil
end

function Show(enType, charId)
    UnionOfficialData.RequestData(function()
        Global.OpenUI(_M)
        _ui.charId = charId
        LoadUI(enType)
    end)
end
