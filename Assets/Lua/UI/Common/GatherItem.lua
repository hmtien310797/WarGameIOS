local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

class "GatherItem" 
{
}

local gather2TextList = 
{
}

gather2TextList[1] = Text.avenue_level
gather2TextList[2] = Text.avenue_school
gather2TextList[3] = Text.avenue_rebel_army
gather2TextList[4] = Text.avenue_level_shop
gather2TextList[5] = Text.avenue_recharge
gather2TextList[6] = Text.avenue_daily
gather2TextList[7] = Text.avenue_vipgift
gather2TextList[8] = Text.avenue_vipgift
gather2TextList[10] = Text.RechargeRebate_ui6
gather2TextList[11] = Text.RechargeRebate_ui5
gather2TextList[12] = Text.Hero_WeekCard_ui1
gather2TextList[13] = Text.ui_hero511

function GatherItem:UpdateItem(itemObject, itemIndex)
    local itemTransform = itemObject.transform
    local bgObject = itemTransform:Find("bg2").gameObject
    local nameLabel = itemTransform:Find("bg2/level name"):GetComponent("UILabel")
    local goButton = itemTransform:Find("bg2/level btn"):GetComponent("UIButton")

    local gatherInfo = self.gather2List[itemIndex]
    if gatherInfo then
        local gatherId = gatherInfo[1]

        bgObject:SetActive(true)

        if gatherInfo[2] then
            if gatherId == 1 then
                local battleId = gatherInfo[2]
                local battleData = TableMgr:GetBattleData(battleId)
                local baseLevel = maincity.GetBuildingByID(1).data.level
                local playerLevel = MainData.GetLevel()
                nameLabel.text = TextMgr:GetText(battleData.nameLabel)
                nameLabel.color = playerLevel >= battleData.requiredLevel and baseLevel >= battleData.requiredBaseLevel and (FunctionListData.IsUnlocked(135) and ChapterListData.CanExplore(battleId)) and Color.green or Color.red
                bgObject:SetActive(true)
                SetClickCallback(goButton.gameObject, function(go)
                    local reasonText = ChapterInfoUI.CheckShow(battleId , {itemid = self.itemId , itemcount = self.needCount , gaterCount = 0})
                    if reasonText ~= nil then
                        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        FloatText.Show(reasonText, Color.white)
                    end
                end)
            elseif gatherId == 5 then
                for _, id in ipairs(gatherInfo[2]) do
                    local iapGoodInfo = GiftPackData.GetAvailableGoodsByID(id)

                    if iapGoodInfo then
                        nameLabel.text = TextMgr:GetText(iapGoodInfo.name)
                        
                        goButton.gameObject:SetActive(true)
                        SetClickCallback(goButton.gameObject, function()
                            Goldstore.ShowGiftPack(iapGoodInfo)
                        end)

                        return
                    end
                end

                nameLabel.text = TextMgr:GetText(Text.avenue_recharge)

                goButton.gameObject:SetActive(false)
                SetClickCallback(goButton.gameObject, function()
                    Goldstore.Show(0)
                end)
            end
        else
            nameLabel.text = TextMgr:GetText(gather2TextList[gatherId])

            if gatherId == 10 then
                goButton.gameObject:SetActive(ActivityData.IsActivityAvailable(ActivityData.GetActivityIdByTemplete(307)))
            elseif gatherId == 11 then
                goButton.gameObject:SetActive(ActivityData.IsActivityAvailable(ActivityData.GetActivityIdByTemplete(305)))
            elseif gatherId == 12 then
                goButton.gameObject:SetActive(ActivityData.IsActivityAvailable(7000))
            end

            SetClickCallback(goButton.gameObject, function(go)
                if gatherId == 1 then
                    if FunctionListData.IsUnlocked(135)then
                        ChapterSelectUI.ShowExploringChapter()
                    else
                        FloatText.ShowAt(goButton.transform.position, TextMgr:GetText(TableMgr:GetFunctionUnlockText(135)))
                    end
                elseif gatherId == 2 then
                    local building = maincity.GetBuildingByID(7)
                    if building ~= nil and building.data ~= nil then
                        MilitarySchool.Show()
                    else
                        FloatText.ShowAt(goButton.transform.position, TextMgr:GetText(Text.build_ui41))
                    end
                elseif gatherId == 3 then
                    if not FunctionListData.IsFunctionUnlocked(101) then
                        FloatText.ShowAt(goButton.transform.position, TextMgr:GetText(TableMgr:GetFunctionUnlockText(101)))
                    else
                        MainCityUI.ShowWorldMap(nil, nil, true, function()
                            GatherItemUI.Hide()
                            HeroInfoNew.Hide()
                            HeroListNew.Hide()
                            MapSearch.Show()
                        end)
                    end
                elseif gatherId == 4 then
                    SlgBag.Show(2)
                elseif gatherId == 5 then
                    -- store.ShowByIDArray({200, 204, 205, 206, 207, 208, 209})
                    Goldstore.Show(0)
                elseif gatherId == 6 then
                    MissionUI.Show(2)
                elseif gatherId == 7 then
                    VIP.Show(2)
                elseif gatherId == 8 then
                    VIP.Show(7)
                elseif gatherId == 10 then -- 每日返利
                    -- WelfareAll.Show(3007)
                    Goldstore.Show(7)
                elseif gatherId == 11 then -- 新兵返利
                    -- WelfareAll.Show(3005)
                    Goldstore.Show(5)
                elseif gatherId == 12 then -- 将军周卡
                    -- WelfareAll.Show(7000)
                    Goldstore.Show(2, 2)
                elseif gatherId == 13 then -- 联合行动
                    Entrance.Show()
                end
            end)
        end
    else
        bgObject:SetActive(false)
    end
    -- end
end

function GatherItem:LoadObject(transform)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.closeButton = transform:Find("close btn")
    self.emptyObject = transform:Find("no one").gameObject
    local item = {}
    local itemTransform = transform:Find("listitem_hero_item")
    self.countLabel = transform:Find("num"):GetComponent("UILabel")
    UIUtil.LoadHeroItemObject(item, itemTransform)
    item.nameLabel = transform:Find("name"):GetComponent("UILabel")
    self.item = item

    self.listScrollView = transform:Find("Scroll View"):GetComponent("UIScrollView")
    self.listWrapContent = transform:Find("Scroll View/Wrap Content"):GetComponent("UIWrapContent")
    self.listRow = self.listWrapContent.transform.childCount
    self.listWrapContent.onInitializeItem = function(go, wrapIndex, realIndex)
        local itemIndex = -realIndex + 1
        self.itemList[wrapIndex + 1] = {itemIndex, go}
        self:UpdateItem(go, itemIndex)
    end
    self.itemList = {}
end

function GatherItem:LoadUI(itemId, needCount)
    self._NAME = "GatherItem " .. itemId
    self.itemId = itemId
    self.needCount = needCount
    local item = self.item
    local itemList = self.itemList
    local itemData = TableMgr:GetItemData(itemId)
    local itemMsg = ItemListData.GetItemDataByBaseId(itemId)
    local haveCount = itemMsg ~= nil and itemMsg.number or 0
    UIUtil.LoadHeroItem(item, itemData)
    self.countLabel.text = haveCount .. "/" .. needCount
    self.countLabel.color = haveCount >= needCount and Color.white or Color.red

    self.gatherList = {}
    if itemData.gather ~= "NA" and itemData.gather ~= "" then
        for _, sourceInfo in ipairs(string.msplit(itemData.gather, ",", ":", ";")) do
            self.gatherList[tonumber(sourceInfo[1])] = table.map(sourceInfo[2], tonumber)
        end
    end

    self.gather2List = {}

    for v in string.gsplit(itemData.gather2, ";") do
        local gatherId = tonumber(v)

        if self.gatherList[gatherId] then
            if gatherId == 5 then
                table.insert(self.gather2List, { gatherId, self.gatherList[gatherId] })
            else
                for _, id in ipairs(self.gatherList[gatherId]) do
                    table.insert(self.gather2List, { gatherId, id })
                end
            end
        else
            table.insert(self.gather2List, { gatherId })
        end
    end
    self.listWrapContent.minIndex = math.max(-#self.gather2List + 1, self.listRow - 1)
    self.listScrollView.disableDragIfFits = #self.gather2List < self.listRow

    self.emptyObject:SetActive(self.battleIdList == nil and (self.gather2List == nil or #self.gather2List == 0))
    for _, v in pairs(self.itemList) do
        self:UpdateItem(v[2], v[1])
    end
    coroutine.start(function()
        coroutine.step()
        if self.listScrollView ~= nil then
            self.listScrollView:ResetPosition()
        end
    end)
    self.listWrapContent:ResetToStart()

    EventDispatcher.Bind(GiftPackData.OnDataChange(), self, EventDispatcher.HANDLER_TYPE.INSTANT, function(iapGoodInfo, change)
        for _, v in pairs(self.itemList) do
            self:UpdateItem(v[2], v[1])
        end
    end)
end

function GatherItem:Close()
    EventDispatcher.UnbindAll(self)
    self.listWrapContent.onInitializeItem = nil
end
