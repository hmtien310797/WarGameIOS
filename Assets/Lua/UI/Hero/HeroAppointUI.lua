module("HeroAppointUI", package.seeall)

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

OnCloseCB = nil

local _ui
local loaduicoroutine

local appointBuildingList
local function GetAppointBuildingList()
    if appointBuildingList == nil then
        appointBuildingList = {}
        local allBuildingData = TableMgr:GetAllBuildingData()
        for i, v in pairs(allBuildingData) do
            local buildingData = allBuildingData[i]
            local appointType = buildingData.appointType
            if appointType ~= 0 then
                if appointBuildingList[appointType] == nil then
                    appointBuildingList[appointType] = {}
                end
                table.insert(appointBuildingList[appointType], buildingData)
            end
        end

        for _, v in ipairs(appointBuildingList) do
            table.sort(v, function(v1, v2)
                return v1.appointOrder < v2.appointOrder
            end)
        end
    end

    return appointBuildingList
end

local unlockDataList = {}
function GetUnlockData(buildingData)
    if buildingData.appointType ~= 0 and unlockDataList[buildingData.id] == nil and buildingData.appointUnlock ~= "NA" then
        local appointUnlockList = {}
        for v in string.gsplit(buildingData.appointUnlock, ";") do
            local unlockList = string.split(v, ":")
            appointUnlockList[tonumber(unlockList[3])] = {tonumber(unlockList[1]), tonumber(unlockList[2])}
        end
        unlockDataList[buildingData.id] = appointUnlockList
    end

    return unlockDataList[buildingData.id]
end

function IsUnlockByBuildingData(buildingData, index)
    local unlockData = GetUnlockData(buildingData)
    if unlockData == nil then
        return true
    end

    local appointUnlock
    appointUnlock = unlockData[index]
    return appointUnlock == nil or BuildingData.HasLevelGreaterBuildingDataById(appointUnlock[1], appointUnlock[2])
end

function GetSkill(heroInfo, heroData, buildingID)
    -- local passiveSkillData = HeroListData.GetAppointSkillDataByBuildingId(heroData, buildingId)

    -- if passiveSkillData ~= nil then
    --     return TextMgr:GetText(passiveSkillData.AttriText), Global.GetHeroAttrValueString(passiveSkillData.AttrType1, HeroListData.GetPassiveSkillShowValue(passiveSkillData, heroMsg.level))
    -- end

    -- return nil

    local skillData = GeneralData.GetAppointmentSkillForBuilding(heroInfo, heroData, buildingID)[1]
    if skillData then
        return TextMgr:GetText(skillData.AttriText), Global.GetHeroAttrValueString(skillData.AttrType1, (1 - 2 * skillData.sign) * GeneralData.GetAttributes(heroInfo, skillData.ArmyType1, skillData.AttrType1)[1])
    end

    return nil
end

function Hide()
    coroutine.stop(loaduicoroutine)
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    local hasNotAppointedHero = GeneralData.HasNonAppointedGeneral()
    local buildingList = GetAppointBuildingList()
    --loaduicoroutine = coroutine.start(function()
        for i, v in ipairs(buildingList) do
            local table = _ui.pageList[i].table
            table.repositionNow = true
            for ii, vv in ipairs(v) do
                local appointTransform
                if ii > table.transform.childCount then
                    appointTransform = NGUITools.AddChild(table.gameObject, _ui.appointPrefab).transform
                else
                    appointTransform = table.transform:GetChild(ii - 1)
                end
                local nameLabel = appointTransform:Find("Texture/Label"):GetComponent("UILabel")
                local icon = appointTransform:Find("Texture"):GetComponent("UITexture")
                local powerLabel = appointTransform:Find("hero widget/num"):GetComponent("UILabel")
                icon.mainTexture = ResourceLibrary:GetIcon("Icon/building/", vv.appointIcon)
                nameLabel.text = TextMgr:GetText(vv.appointName)

                local attrList = {}
                attrList.emptyLabel = appointTransform:Find("property widget/no one"):GetComponent("UILabel")
                attrList.emptyLabel.gameObject:SetActive(true)
                attrList.emptyLabel.text = TextMgr:GetText(vv.attrText)
                for j = 1, 3 do
                    local attr = {}
                    local attrTransform = appointTransform:Find("property widget/property" .. j)
                    attr.gameObject = attrTransform.gameObject
                    attr.nameLabel = attrTransform:GetComponent("UILabel")
                    attr.valueLabel = attrTransform:Find("Label"):GetComponent("UILabel")
                    attrList[j] = attr
                    attr.gameObject:SetActive(false)
                end

                local unlockData = GetUnlockData(vv)
                local buildingMsg = BuildingData.GetBuildingDataById(vv.id)
                if buildingMsg ~= nil and buildingMsg.type == _ui.buildingId then
                    local page = _ui.pageList[i]
                    page.toggle.value = true
                    page.content:SetActive(true)
                    _ui.pageList[3 - i].toggle.value = false
                    _ui.pageList[3 - i].content:SetActive(false)
                    local moveY = page.itemHeight * (ii - 1)
                    local rowCount = #v
                    moveY = math.min(moveY, page.itemHeight * rowCount - page.clipHeight) 
                    coroutine.start(function()
                        coroutine.step()
                        coroutine.step()
                        if _ui ~= nil then
                            page.scrollView:MoveRelative(Vector3(0, moveY, 0))
                            page.scrollView:Scroll(0.01)
                        end
                    end)
                    _ui.buildingId = nil
                end

                local attrValue = 0
                local totalPower = 0
                local attrIndex = 2
                for j = 1, 2 do
                    local hero = {}
                    local heroTransform = appointTransform:Find("hero widget/listitem_hero" .. j)
                    HeroList.LoadHeroObject(hero, heroTransform)
                    local appointButton = appointTransform:Find(string.format("hero widget/hero%d", j)):GetComponent("UIButton")
                    local addTransform = appointTransform:Find(string.format("hero widget/hero%d/add", j))
                    local addObject = addTransform.gameObject
                    local addEffectObject = addTransform:Find("effect").gameObject
                    local lockObject = appointTransform:Find(string.format("hero widget/hero%d/lock", j)).gameObject
                    local unlockLabel = appointTransform:Find(string.format("hero widget/hero%d/lock/Label", j)):GetComponent("UILabel")

                    local appointUnlock
                    if unlockData ~= nil then
                        appointUnlock = unlockData[j]
                    end
                    if appointUnlock ~= nil and not BuildingData.HasLevelGreaterBuildingDataById(appointUnlock[1], appointUnlock[2]) then
                        addObject:SetActive(false)
                        lockObject:SetActive(true)
                        local buildingName = TextMgr:GetText(TableMgr:GetBuildingData(appointUnlock[1]).name)
                        unlockLabel.text = String.Format(TextMgr:GetText(Text.HeroAppoint_lock), buildingName, appointUnlock[2])
                        SetClickCallback(appointButton.gameObject, function()
                            FloatText.Show(String.Format(TextMgr:GetText(Text.HeroAppoint_lock), buildingName, appointUnlock[2]))
                        end)
                    else
                        lockObject:SetActive(false)
                        local heroMsg = BuildingData.GetAppointedHeroMsg(vv.id, j)
                        if heroMsg ~= nil then
                            attrList.emptyLabel.gameObject:SetActive(false)
                            attrList[1].gameObject:SetActive(true)
                            local heroData = TableMgr:GetHeroData(heroMsg.baseid)

                            -- local heroPower = HeroListData.GetPower(heroMsg, heroData)
                            -- attrValue = attrValue + HeroListData.GetPowerCoef(heroPower) * vv.value1
                            -- totalPower = totalPower + heroPower

                            local attributes = GeneralData.GetAttributes(heroMsg)[1]
                            attrValue = attrValue + attributes[Global.GetAttributeLongID(10000, vv.appointattr)] * vv.value1
                            totalPower = totalPower + attributes[100]

                            HeroList.LoadHero(hero, heroMsg, heroData)
                            hero.gameObject:SetActive(true)
                            addObject:SetActive(false)
                            
                            local deleteObject = hero.transform:Find("delete").gameObject
                            SetClickCallback(deleteObject, function()
                                local req = HeroMsg_pb.MsgCancelAppointHeroRequest()
                                req.heroUid = heroMsg.uid
                                Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgCancelAppointHeroRequest, req, HeroMsg_pb.MsgCancelAppointHeroResponse, function(msg)
                                    if msg.code ~= ReturnCode_pb.Code_OK then
                                        Global.ShowError(msg.code)
                                    else
                                        GeneralData.UpdateData(msg.heroFresh) -- HeroListData.UpdateData(msg.heroFresh)
                                    end
                                end)
                            end)

                            local nameText, valueText = GetSkill(heroMsg, heroData, vv.id)
                            if nameText ~= nil then
                                local attr = attrList[attrIndex]
                                attr.gameObject:SetActive(true)
                                attr.nameLabel.text = nameText
                                attr.valueLabel.text = valueText
                                attrIndex = attrIndex + 1
                            end

                            SetClickCallback(hero.btn.gameObject, function()
                                HeroAppoint.Show(buildingMsg, vv, j, heroMsg, heroData)
                            end)
                        else
                            hero.gameObject:SetActive(false)
                            addObject:SetActive(true)
                            addEffectObject:SetActive(hasNotAppointedHero)
                            SetClickCallback(appointButton.gameObject, function()
                                HeroAppoint.Show(buildingMsg, vv, j, nil, nil)
                            end)
                        end
                    end
                end

                attrList[1].nameLabel.text = TextMgr:GetText(vv.appointText)
                attrList[1].valueLabel.text = Global.GetHeroAttrValueString(vv.attrType1, attrValue)

                for i = attrIndex, 3 do
                    attrList[i].gameObject:SetActive(false)
                end

                powerLabel.text = String.Format(TextMgr:GetText(Text.HeroAppoint_combat), math.floor(totalPower))
            end
            --coroutine.step()
        end
    --end)
end

local function UpdateChangeAttrList(changeAttrList, oldAttr)
    local buildingList = GetAppointBuildingList()
    for _, v in ipairs(buildingList) do
        for __, buildingData in ipairs(v) do
            local buildingMsg = BuildingData.GetBuildingDataById(buildingData.id)
            if buildingMsg ~= nil then
                local changeAttr
                local attrValue = 0
                for j = 1, 2 do
                    if IsUnlockByBuildingData(buildingData, j) then
                        for ___, vvv in ipairs(changeAttrList) do
                            if vvv.data == buildingData then
                                changeAttr = vvv
                                break
                            end
                        end

                        if changeAttr == nil then
                            table.insert(changeAttrList, {data = buildingData, typeList = {}, oldValueList = {0, 0, 0}, newValueList = {}})
                            changeAttr = changeAttrList[#changeAttrList]
                        end
                        local heroMsg = BuildingData.GetAppointedHeroMsg(buildingData.id, j)
                        if heroMsg ~= nil then
                            -- local heroData = TableMgr:GetHeroData(heroMsg.baseid)
                            -- local heroPower = HeroListData.GetPower(heroMsg, heroData)
                            -- attrValue = attrValue + HeroListData.GetPowerCoef(heroPower) * buildingData.value1
                            -- local passiveSkillData = HeroListData.GetAppointSkillDataByBuildingId(heroData, buildingData.id)
                            -- if passiveSkillData ~= nil then
                            --     changeAttr.typeList[j + 1] = {text = TextMgr:GetText(passiveSkillData.AttriText), type = passiveSkillData.AttrType1}
                            --     if oldAttr then
                            --         changeAttr.oldValueList[j + 1] = HeroListData.GetPassiveSkillShowValue(passiveSkillData, heroMsg.level)
                            --     else
                            --         changeAttr.newValueList[j + 1] = HeroListData.GetPassiveSkillShowValue(passiveSkillData, heroMsg.level)
                            --     end
                            -- end

                            local attributes = GeneralData.GetAttributes(heroMsg)[1]
                            attrValue = attrValue + attributes[Global.GetAttributeLongID(10000, buildingData.appointattr)] * buildingData.value1
                            attrValue = attrValue + (attributes[Global.GetAttributeLongID(buildingData.armyType1, buildingData.attrType1)] or 0)
                        end
                    end
                end

                if changeAttr ~= nil then
                    changeAttr.typeList[1] = {text = TextMgr:GetText(buildingData.appointText), type = buildingData.attrType1} 
                    if oldAttr then
                        changeAttr.oldValueList[1] = attrValue
                    else
                        changeAttr.newValueList[1] = attrValue
                    end
                end
            end
        end
    end
end

local function AutoAppointCallback()
    local heroListData = GeneralData.GetGenerals() -- HeroListData.GetData()
    local listData = {}

    local priorityQueues = {}
    local priorityQueues_passiveSkill = {}
    for _, heroInfo in ipairs(heroListData) do
        local heroData = TableMgr:GetHeroData(heroInfo.baseid) 
        if not heroData.expCard then
            -- table.insert(listData, {heroInfo, heroData})
            local attributes = GeneralData.GetAttributes(heroInfo)[1]

            local general = {}
            general.heroInfo = heroInfo
            general.heroData = heroData
            general.attributes = attributes

            for attributeID, _ in pairs(attributes) do
                if not priorityQueues[attributeID] then
                    priorityQueues[attributeID] = PriorityQueue(nil, function(general1, general2)
                        local attribute1 = math.abs(general1.attributes[attributeID] or 0)
                        local attribute2 = math.abs(general2.attributes[attributeID] or 0)

                        if attribute1 ~= attribute2 then
                            return attribute1 > attribute2
                        else
                            return general1.heroInfo.baseid < general2.heroInfo.baseid
                        end
                    end)
                end

                priorityQueues[attributeID]:Push(general)
            end

            for i, stringIDs in ipairs(string.split(heroData.passiveskill, ";")) do
                if i <= heroInfo.star then
                    for stringID in string.gsplit(stringIDs, ",") do
                        if tonumber(stringID) ~= 0 then
                            local skillData = TableMgr:GetPassiveSkillData(tonumber(stringID))

                            if skillData.ActiveCondition == 1 then
                                local buildType = skillData.Coef

                                for j = 1, 10 do
                                    local attributeID = Global.GetAttributeLongID(skillData["ArmyType" .. j], skillData["AttrType" .. j])
                                    if attributeID ~= 0 then

                                        if not priorityQueues_passiveSkill[buildType] then
                                            local effectiveAttributeID = Global.GetAttributeLongID(10000, TableMgr:GetBuildingData(buildType).appointattr)
                                            priorityQueues_passiveSkill[buildType] = PriorityQueue(nil, function(general1, general2)
                                                local attribute1 = general1.attributes[effectiveAttributeID]
                                                local attribute2 = general2.attributes[effectiveAttributeID]

                                                if attribute1 ~= attribute2 then
                                                    return attribute1 > attribute2
                                                else
                                                    return general1.heroInfo.baseid < general2.heroInfo.baseid
                                                end
                                            end)
                                        end

                                        priorityQueues_passiveSkill[buildType]:Push(general)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- table.sort(listData, function(v1, v2)
    --     local power1 = HeroListData.GetPower(v1[1], v1[2])
    --     local power2 = HeroListData.GetPower(v2[1], v2[2])
    --     if power1 == power2 then
    --         return v1[1].uid < v2[1].uid
    --     end

    --     return power1 > power2
    -- end)

    local sameAsOld = true

    local appointList = {}
    local req = HeroMsg_pb.MsgAppointHeroBatchRequest()

    local isAppointed = {}
    for appointType, buildingDatas in ipairs(GetAppointBuildingList()) do
        for _, buildingData in ipairs(buildingDatas) do
            local buildingMsg = BuildingData.GetBuildingDataById(buildingData.id)
            if buildingMsg ~= nil then
                for index = 1, 2 do
                    if IsUnlockByBuildingData(buildingData, index) then
                        if appointList[buildingData.id] == nil then
                            appointList[buildingData.id] = { id = buildingData.id, appointattr = buildingData.appointattr }
                        end

                        appointList[buildingData.id][index] = 0

                        local priorityQueue = priorityQueues_passiveSkill[buildingData.id]
                        if priorityQueue then
                            while not priorityQueue:IsEmpty() do
                                local uid = priorityQueue:Pop().heroInfo.uid
                                if not isAppointed[uid] then
                                    local heroAppoint = req.appoints:add()
                                    heroAppoint.buildType = buildingData.id
                                    heroAppoint.index = index
                                    heroAppoint.heroUid = uid

                                    appointList[buildingData.id][index] = uid
                                    isAppointed[uid] = true
                                    
                                    if sameAsOld then
                                        local heroInfo = BuildingData.GetAppointedHeroMsg(buildingData.id, index)
                                        if not heroInfo or heroInfo.uid ~= uid then
                                            sameAsOld = false
                                        end
                                    end

                                    break
                                end
                            end
                        end

                        -- for iii, vvv in ipairs(listData) do
                        --     if HeroListData.HasAppointSkillDataByBuildingId(vvv[2], buildingData.id) then
                        --         local heroUid = vvv[1].uid
                        --         local heroAppoint = req.appoints:add()
                        --         heroAppoint.buildType = buildingData.id
                        --         heroAppoint.index = index
                        --         heroAppoint.heroUid = heroUid
                        --         appointList[buildingData.id][index] = heroUid
                        --         table.remove(listData, iii)

                        --         if sameAsOld then
                        --             local heroMsg = BuildingData.GetAppointedHeroMsg(buildingData.id, index)
                        --             if heroMsg == nil or heroMsg.uid ~= heroUid then
                        --                 sameAsOld = false
                        --             end
                        --         end

                        --         break
                        --     end
                        -- end
                    end
                end
            end
        end
    end

    for _, v in pairs(appointList) do
        for index, vv in ipairs(v) do
            if vv == 0 then
                local priorityQueue = priorityQueues[Global.GetAttributeLongID(10000, v.appointattr)]
                if priorityQueue then
                    while not priorityQueue:IsEmpty() do
                        local uid = priorityQueue:Pop().heroInfo.uid

                        if not isAppointed[uid] then
                            local heroAppoint = req.appoints:add()
                            heroAppoint.buildType = v.id
                            heroAppoint.index = index
                            heroAppoint.heroUid = uid

                            isAppointed[uid] = true

                            if sameAsOld then
                                local heroInfo = BuildingData.GetAppointedHeroMsg(v.id, index)
                                if not heroInfo or heroInfo.uid ~= uid then
                                    sameAsOld = false
                                end
                            end

                            break
                        end
                    end
                end
            end
        end
    end

    if #req.appoints > 0 then
        if sameAsOld then
            FloatText.Show(TextMgr:GetText(Text.HeroAppoint_optimal))
        else
            Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgAppointHeroBatchRequest, req, HeroMsg_pb.MsgAppointHeroBatchResponse, function(msg)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.ShowError(msg.code)
                else
                    local changeAttrList = {}
                    UpdateChangeAttrList(changeAttrList, true)
                    -- HeroListData.UpdateData(msg.heroFresh)
                    GeneralData.UpdateData(msg.heroFresh)
                    UpdateChangeAttrList(changeAttrList, false)
                    AppointSuccess.Show(changeAttrList)
                end
            end)
        end
    end
end

function Awake()
    local closeButton = transform:Find("Container/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    _ui.appointPrefab = ResourceLibrary.GetUIPrefab("HeroAppoint/Listitem_HeroAppoint")
    _ui.pageList = {}
    for i = 1, 2 do
        local page = {}
        page.table = transform:Find(string.format("Container/bg/mission list/content %d/Scroll View/Table", i)):GetComponent("UITable")
        page.content = transform:Find(string.format("Container/bg/mission list/content %d", i)).gameObject
        page.toggle = transform:Find(string.format("Container/bg/mission list/page%d", i)):GetComponent("UIToggle")
        page.panel = transform:Find(string.format("Container/bg/mission list/content %d/Scroll View", i)):GetComponent("UIPanel")
        page.scrollView = transform:Find(string.format("Container/bg/mission list/content %d/Scroll View", i)):GetComponent("UIScrollView")
        page.itemHeight = _ui.appointPrefab:GetComponent("UIWidget").height
        page.clipHeight = page.panel.baseClipRegion.w
        _ui.pageList[i] = page
        local autoAppointButton = transform:Find(string.format("Container/bg/mission list/content %d/btn", i)):GetComponent("UIButton")
        SetClickCallback(autoAppointButton.gameObject, AutoAppointCallback)
    end

    -- HeroListData.AddListener(LoadUI)
    EventDispatcher.Bind(GeneralData.OnGeneralAppointmentChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, LoadUI)
end

function Close()
    -- HeroListData.RemoveListener(LoadUI)
    EventDispatcher.UnbindAll(_M)

    _ui = nil
    if OnCloseCB ~= nil then
        OnCloseCB()
        OnCloseCB = nil
    end
end

function Show(buildingId)
    Global.OpenUI(_M)
    _ui.buildingId = buildingId
    if not Global.IsDistVersion() then
        print("建筑id:", buildingId)
    end
    LoadUI()
end
