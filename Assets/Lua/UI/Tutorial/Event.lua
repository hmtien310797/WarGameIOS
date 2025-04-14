module("Event", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local SetPressCallback = UIUtil.SetPressCallback
local GameTime = Serclimax.GameTime
local DebugPrint = Global.DebugPrint

local eventList = {}

function HasEvent(eventId)
    local eventConfig = ConfigData.GetEventConfig()
    for k, v in pairs(eventConfig) do
        if v == eventId then
            return true
        end
    end

    return false
end

function IsActive(eventId)
    return eventList[eventId] ~= nil and eventList[eventId].co ~= nil and coroutine.status(eventList[eventId].co) ~= "dead"
end

function HasAnyEvent()
    return next(ConfigData.GetEventConfig()) ~= nil
end

function Remove(eventId)
    local eventConfig = ConfigData.GetEventConfig()
    for k, v in pairs(eventConfig) do
        if v == eventId then
            eventConfig[k] = nil
            ConfigData.SetEventConfig(eventConfig)
            break
        end
    end
end

function Add(eventId)
    local eventConfig = ConfigData.GetEventConfig()
    table.insert(eventConfig, eventId)
    ConfigData.SetEventConfig(table.unique(eventConfig))
end

function AddAll()
    for k, v in pairs(eventList) do
        Add(k)
    end
end

function GetEvent(eventId)
    return eventList[eventId]
end

function PrintAll()
    local eventConfig = ConfigData.GetEventConfig()
    for k, v in pairs(eventConfig) do
        DebugPrint(k, v)
    end
end

function Check(eventId, restart)
    DebugPrint("Check event:", eventId)
    local eventConfig = ConfigData.GetEventConfig()
    for _, v in pairs(eventConfig) do
        if v == eventId then
            if eventList[v].co == nil or restart then
                eventList[v].co = coroutine.start(function()
                    DebugPrint("开始事件:", v)
                    eventList[v].func()
                    DebugPrint("结束事件:", v)
                    Remove(eventId)
                end)
            end
            return true
        end
    end

    return false
end

function CheckAll()
    local success = false
    for k, v in pairs(eventList) do
        if k < 12 then
            if Check(k, k == 6 or k == 8) then
                success = true
                break
            end
        end
    end

    return success
end

function Resume(eventId)
    local event = eventList[eventId]
    if event ~= nil and event.co ~= nil then
        DebugPrint("继续事件", eventId)
        coroutine.resume(event.co)
    end
end

--造农田
eventList[2] =
{
    func = function()
        Tutorial.TriggerModule(10100)
        coroutine.yield()
        Global.ShowTopMask(1.5)
        coroutine.wait(1)
        maincity.SetTargetBuild(11, true, 1, false, true, true)
        Global.ShowTopMask(2)
        coroutine.wait(2)
        Tutorial.TriggerModule(10101)
        coroutine.yield()
        Event.Check(3)
    end,
    finish = function()
        return maincity.HasBuildingByID(11)
    end
}

--造炼铁厂
eventList[3] =
{
    func = function()
        Tutorial.TriggerModule(10200)
        coroutine.yield()
        Global.ShowTopMask(2)
        maincity.SetTargetBuild(12, true, 1, false, true, true)
        coroutine.wait(1.5)
        Tutorial.TriggerModule(10201)
        coroutine.yield()
        Event.Check(4)
    end,
    finish = function()
        return maincity.HasBuildingByID(12)
    end,
}

--造步兵营
eventList[4] =
{
    func = function()
        Tutorial.TriggerModule(10300)
        coroutine.yield()
        Global.ShowTopMask(2)
        maincity.SetTargetBuild(21, true, 1, true, true, true)
        coroutine.wait(1.5)
        coroutine.yield()
        Event.Check(5)
    end,
    finish = function()
        return maincity.HasBuildingByID(21)
    end,
}

--训练步兵
eventList[5] =
{
    func = function()
        Tutorial.TriggerModule(10400)
        coroutine.yield()
        local soldierId = 1001
        local soldierData = Barrack.GetAramInfo(soldierId, 1)
        local buildingId = soldierData.BarrackId
        --步兵营-点击
        Tutorial.TriggerModule(10401)
        coroutine.yield()
        Event.Check(6)
    end
}

--攻击关卡1
eventList[6] =
{
    func = function()
        Tutorial.TriggerModule(10500)
        coroutine.yield()
        local battleId = 90014
        local reasonText = ChapterInfoUI.CheckShow(battleId)
        if reasonText ~= nil then
            ChapterSelectUI.ShowExploringChapter()
        end
        Tutorial.TriggerModule(10501)
        coroutine.yield()
        Event.Check(7)
    end,
    finish = function()
        return ChapterListData.HasLevelExplored(90014)
    end
}

--抽卡
eventList[7] =
{
    func = function()
        Tutorial.TriggerModule(10600)
        coroutine.yield()
        Global.ShowTopMask(2)
        maincity.SetTargetBuild(7, true, 1, true, true, true)
        coroutine.wait(1.5)
        --点击档案馆 开始抽卡引导
        Tutorial.TriggerModule(10601)
        coroutine.yield()
    end
}

--攻击关卡2
eventList[8] =
{
    func = function()
        Tutorial.TriggerModule(10700)
        coroutine.yield()
        local battleId = 90015
        local reasonText = ChapterInfoUI.CheckShow(battleId)
        if reasonText ~= nil then
            ChapterSelectUI.ShowExploringChapter()
        end
        Tutorial.TriggerModule(10701)
        coroutine.yield()
    end,
    finish = function()
        return ChapterListData.HasLevelExplored(90015)
    end
}

--军阀来袭
eventList[9] =
{
    func = function()
        Tutorial.TriggerModule(10800)
        coroutine.yield()
        StoryPicture.Show(2)
        coroutine.yield()
        MainCityUI.ShowWorldMapPreView(171, 167, 2, nil)
        coroutine.yield()
        StoryPicture.Show(3)
        coroutine.yield()
        maincity.SetWast(true)
        Tutorial.TriggerModule(10803)
        coroutine.yield()
        ChapterPicture.Show(1, function()
            Resume(9)
        end)
        coroutine.yield()
        Check(10)
    end
}

--第一章节
eventList[10] =
{
    func = function()
        maincity.SetWast(false)
        ActivityGrow.Show(1)
        Tutorial.TriggerModule(10901)
        coroutine.yield()
        Global.ShowTopMask(1)
        coroutine.wait(1)
        Tutorial.TriggerModule(10902)
        coroutine.yield()
    end,
}

eventList[12] =
{
    func = function()
        Tutorial.TriggerModule(10905)
        coroutine.yield()
    end
}

--[[
eventList[13] =
{
    func = function()
        Tutorial.TriggerModule(10906)
    end
}
--]]

eventList[14] =
{
    func = function()
        Tutorial.TriggerModule(10907)
        coroutine.yield()
    end
}

eventList[15] =
{
    func = function()
        Tutorial.TriggerModule(10908)
        coroutine.yield()
    end
}

eventList[16] =
{
    func = function()
        Tutorial.TriggerModule(10909)
        coroutine.yield()
    end
}

eventList[17] =
{
    func = function()
        Tutorial.TriggerModule(10910)
        coroutine.yield()
    end
}

eventList[18] =
{
    func = function()
        Tutorial.TriggerModule(10911)
        coroutine.yield()
        Barrack.Hide()
        coroutine.wait(0.1)
        maincity.SetEmptyZiyuantianTarget(true)
        Global.ShowTopMask(1.0)
        coroutine.wait(1.0)
        Check(19)
    end
}

eventList[19] =
{
    func = function()
        if not maincity.HasBuildingByID(3) then
            maincity.SetEmptyZiyuantianTarget(true)
            Global.ShowTopMask(1.5)
            Tutorial.TriggerModule(10912)
            coroutine.yield()
        end
    end
}

eventList[20] =
{
    func = function()
        Tutorial.TriggerModule(10914)
        coroutine.yield()
    end
}

eventList[21] =
{
    func = function()
        Tutorial.TriggerModule(10915)
        coroutine.yield()
    end
}

eventList[22] =
{
    func = function()
        Tutorial.TriggerModule(10916)
        coroutine.yield()
    end
}

eventList[23] =
{
    func = function()
        Tutorial.TriggerModule(10917)
        coroutine.yield()
    end
}

eventList[24] =
{
    func = function()
        Tutorial.TriggerModule(10918)
        coroutine.yield()
    end
}

eventList[25] =
{
    func = function()
        Tutorial.TriggerModule(10919)
        coroutine.yield()
        Global.ShowTopMask(1)
        maincity.SetTargetBuild(6, true, 1, false, true, false)
        coroutine.wait(0.9)
        Check(26)
    end
}

eventList[26] =
{
    func = function()
        Tutorial.TriggerModule(10920)
        coroutine.yield()
    end
}

eventList[27] =
{
    func = function()
        Tutorial.TriggerModule(10921)
        coroutine.yield()
    end
}

eventList[28] =
{
    func = function()
        Tutorial.TriggerModule(10922)
        coroutine.yield()
    end
}

eventList[29] =
{
    func = function()
        if ChapterListData.HasLevelExplored(2000001) then
            Tutorial.TriggerModule(11923)
        else
            Tutorial.TriggerModule(10923)
        end
        coroutine.yield()
    end
}

eventList[30] =
{
    func = function()
        Tutorial.TriggerModule(10924)
        coroutine.yield()
    end
}

eventList[31] =
{
    func = function()
        Tutorial.TriggerModule(10925)
        coroutine.yield()
    end
}

eventList[32] =
{
    func = function()
        Tutorial.TriggerModule(10926)
        coroutine.yield()
    end
}

eventList[33] =
{
    func = function()
        local itemMsg = ItemListData.GetItemDataByBaseId(9101)
        if itemMsg == nil then
            return
        end

        Tutorial.TriggerModule(10927)
        local rewardMsg
        local req = ItemMsg_pb.MsgUseItemRequest()
        req.uid = itemMsg.uniqueid
        req.num = 1
        Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)								
            rewardMsg = msg
        end)		
        coroutine.yield()
        if rewardMsg ~= nil then
            local itemData = TableMgr:GetItemData(itemMsg.baseid)
            MessageBox.Show(TextMgr:GetText(Text.Vip_Experience_card_tips), function()
                MainCityUI.UpdateRewardData(rewardMsg.fresh)
                if MainData.GetVipValue().viplevel < tonumber(itemData.param1) then
                    VIPLevelup.Show(MainData.GetVipValue().viplevel, itemData.param1, 1, itemData.param2)								
                    MainData.UpdateVip(rewardMsg.fresh.maindata.vip)
                    ConfigData.SetVipExperienceCard(false)
                    MainCityUI.RefreshVipExperienceCard()
                    MainCityUI.RefreshVipEffect()
                    VipData.RequestVipPanel()
                end
            end)
        end
    end
}

eventList[34] =
{
    func = function()
        Tutorial.TriggerModule(10928)
        coroutine.yield()
    end
}

eventList[35] =
{
    func = function()
        Tutorial.TriggerModule(10929)
        coroutine.yield()
    end
}

eventList[36] =
{
    func = function()
        Tutorial.TriggerModule(10930)
        coroutine.yield()
    end
}

eventList[37] =
{
    func = function()
        Tutorial.TriggerModule(10931)
        coroutine.yield()
    end
}

eventList[38] =
{
    func = function()
        Tutorial.TriggerModule(10932)
        coroutine.yield()
    end
}

eventList[39] =
{
    func = function()
        Tutorial.TriggerModule(10933)
        coroutine.yield()
    end
}

eventList[40] =
{
    func = function()
        Tutorial.TriggerModule(10934)
        coroutine.yield()
    end
}

eventList[41] =
{
    func = function()
        Tutorial.TriggerModule(10935)
        coroutine.yield()
    end
}

eventList[42] =
{
    func = function()
        Tutorial.TriggerModule(10936)
        coroutine.yield()
    end
}

eventList[43] =
{
    func = function()
        Tutorial.TriggerModule(10937)
        coroutine.yield()
    end
}

eventList[44] =
{
    func = function()
        Tutorial.TriggerModule(10938)
        coroutine.yield()
    end
}

eventList[46] =
{
    func = function()
        if UnionInfoData.IsUnionLeader() then
            return
        end
        Tutorial.TriggerModule(10942)
        coroutine.yield()
        local req = MapMsg_pb.MsgSceneGetAvailablePostionRequest()
        local pos
        req.pos.x, req.pos.y = WorldMap.GetCenterMapCoord()
        Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSceneGetAvailablePostionRequest, req, MapMsg_pb.MsgSceneGetAvailablePostionResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                pos = msg.outPos
            else
                Global.ShowError(msg.code)
            end
            Resume(46)
        end, false)
        coroutine.yield()
        if pos ~= nil then
            MapMask.MoveTo(pos.x, pos.y, function()
                local item = 4101
                QuickUseItem.Show(item, function(buy)
                    local req = MapMsg_pb.HomeTranslateRequest()
                    req.type = MapMsg_pb.TranslateType_NewBie
                    req.tarpos.x = pos.x
                    req.tarpos.y = pos.y
                    req.buy = buy

                    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.HomeTranslateRequest, req, MapMsg_pb.HomeTranslateResponse, function(msg)
                        if msg.code == ReturnCode_pb.Code_OK then
                            WorldMapData.SetMyBaseTileData(msg.homeinfo)
                            local myBasePos = MapInfoData.GetMyBasePos()
                            WorldMap.LookAt(myBasePos.x, myBasePos.y)
                            if buy then
                                GUIMgr:SendDataReport("purchase", "costgold", "item:"..item, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
                            else
                                GUIMgr:SendDataReport("purchase", "useitem", tostring(item), "1")
                            end
                            local itData = TableMgr:GetItemData(item)
                            local nameColor = Global.GetLabelColorNew(itData.quality)
                            local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
                            FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
                            Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
                            MainCityUI.UpdateRewardData(msg.fresh)
                            QuickUseItem.Hide()
                            WorldMapMgr.Instance:PlayEffect(myBasePos.x, myBasePos.y, 2, 5)
                        else
                            Global.ShowError(msg.code)
                        end
                    end, true)
                end)
            end)
        end
    end
}

eventList[47] =
{
    func = function()
        Tutorial.TriggerModule(30000)
    end
}

eventList[50] =
{
    func = function()
        SoldierEquipBanner.Show(TextMgr:GetText(Text.equip_ui18), "Equip_banner", TextMgr:GetText(Text.Equip_des), true)
        Tutorial.TriggerModule(40300)
        coroutine.yield()
        BuildingUpgrade.Hide()
        Tutorial.TriggerModule(40000)
    end
}

eventList[51] =
{
    func = function()
        SoldierEquipBanner.Show(TextMgr:GetText(Text.ui_militaryrank_1), "MilitaryRank_banner", TextMgr:GetText(Text.MilitaryRank_des), true)
        Tutorial.TriggerModule(40300)
        coroutine.yield()
        BuildingUpgrade.Hide()
        Tutorial.TriggerModule(40100)
    end
}

eventList[52] =
{
    func = function()
        SoldierEquipBanner.Show(TextMgr:GetText(Text.command_ui_command_txt08), "SoldierLevel_banner", TextMgr:GetText(Text.SoldierLevel_des), true)
        Tutorial.TriggerModule(40300)
        coroutine.yield()
        BuildingUpgrade.Hide()
        Tutorial.TriggerModule(40200)
    end
}

eventList[101] =
{
    func = function()
        Global.ShowTopMask(1)
        maincity.SetTargetBuild(23, true, 1, false, true, false)
        coroutine.wait(0.9)
        Tutorial.TriggerModule(20000)
        coroutine.wait(1)
        coroutine.yield()
    end
}

eventList[102] =
{
    func = function()
        Global.ShowTopMask(1)
        maincity.SetTargetBuild(6, true, 1, false, true, false)
        coroutine.wait(0.9)
        Tutorial.TriggerModule(20001)
        coroutine.wait(1)
        coroutine.yield()
    end
}

eventList[103] =
{
    func = function()
        Global.ShowTopMask(1)
        maincity.SetTargetBuild(4, true, 1, false, true, false)
        coroutine.wait(0.9)
        Tutorial.TriggerModule(20002)
        coroutine.wait(1)
        coroutine.yield()
    end
}

eventList[104] =
{
    func = function()
        Global.ShowTopMask(1)
        maincity.SetTargetBuild(2, true, 1, false, true, false)
        coroutine.wait(0.9)
        Tutorial.TriggerModule(20003)
        coroutine.wait(1)
        coroutine.yield()
    end
}

eventList[105] =
{
    func = function()
        Global.ShowTopMask(2)
        maincity.SetTargetBuild(1, true, 1, false, true, false)
        coroutine.wait(1)
        Tutorial.TriggerModule(20004)
        coroutine.wait(1)
        coroutine.yield()
    end
}

eventList[106] =
{
    func = function()
        Global.ShowTopMask(2)
        maincity.SetTargetBuild(1, true, 1, false, true, false)
        coroutine.wait(1)
        Tutorial.TriggerModule(20005)
        coroutine.wait(1)
        coroutine.yield()
    end
}

eventList[107] =
{
    func = function()
        Global.ShowTopMask(2)
        maincity.SetTargetBuild(1, true, 1, false, true, false)
        coroutine.wait(1)
        Tutorial.TriggerModule(20006)
        coroutine.wait(1)
        coroutine.yield()
    end
}

eventList[108] =
{
    func = function()
        Tutorial.TriggerModule(970)
    end
}

eventList[109] =
{
    func = function()
        Tutorial.TriggerModule(20007)
    end
}

eventList[110] =
{
    func = function()
        Global.ShowTopMask(2)
        maincity.SetTargetBuild(1, true, 1, false, true, false)
        coroutine.wait(1)
        Tutorial.TriggerModule(20008)
        coroutine.wait(1)
        coroutine.yield()
    end
}

function Init()
    local needSave = false
    local eventConfig = ConfigData.GetEventConfig()
    for k, v in pairs(eventConfig) do
        if eventList[v] ~= nil and eventList[v].finish ~= nil and eventList[v].finish() then
            eventConfig[k] = nil
            needSave = true
        end

    end
    if needSave then
        ConfigData.SetEventConfig(eventConfig)
    end
end
