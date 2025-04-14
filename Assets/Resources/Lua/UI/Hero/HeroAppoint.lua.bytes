module("HeroAppoint", package.seeall)

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

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function LoadAppointmentObject(appointment, heroTransform)
    appointment.gameObject = heroTransform.gameObject
    appointment.hero = {}
    appointment.bgTransform = heroTransform:Find("hero1")
    HeroList.LoadHeroObject(appointment.hero, heroTransform:Find("listitem_hero1"))
    appointment.attrList = {}
    appointment.attrList.gameObject = heroTransform:Find("property widget").gameObject
    appointment.attrList.gameObject:SetActive(false)
    for i = 1, 3 do
        local attr = {}
        local attrTransform = heroTransform:Find("property widget/property" .. i)
        attr.gameObject = attrTransform.gameObject
        attr.nameLabel = attrTransform:Find("property"):GetComponent("UILabel")
        attr.valueLabel = attrTransform:Find("num"):GetComponent("UILabel")
        appointment.attrList[i] = attr
    end
end

local function LoadAppointment(appointment, heroMsg, heroData)
    HeroList.LoadHero(appointment.hero, heroMsg, heroData)
    if appointment.bgTransform ~= nil then
        appointment.bgTransform.gameObject:SetActive(false)
    end
    appointment.hero.gameObject:SetActive(true)
    appointment.attrList.gameObject:SetActive(true)
    local attrList = appointment.attrList

    -- local heroPower = HeroListData.GetPower(heroMsg, heroData)
    -- attrList[1].valueLabel.text = heroPower 
    -- attrList[2].nameLabel.text = TextMgr:GetText(_ui.buildingData.appointText)
    -- local attrValue = HeroListData.GetPowerCoef(heroPower) * _ui.buildingData.value1
    -- attrList[2].valueLabel.text = Global.GetHeroAttrValueString(_ui.buildingData.attrType1, attrValue)

    local attribute = GeneralData.GetAttributes(heroMsg, 10000, _ui.buildingData.appointattr)[1]

    local attrValue = attribute * _ui.buildingData.value1

    local heroPower = math.floor(attribute)

    attrList[1].valueLabel.text = heroPower
    attrList[2].nameLabel.text = TextMgr:GetText(_ui.buildingData.appointText)
    attrList[2].valueLabel.text = Global.GetHeroAttrValueString(_ui.buildingData.attrType1, attrValue)

    if _ui.oldHeroMsg == nil or heroMsg.uid ~= _ui.oldHeroMsg.uid then
        if heroPower == _ui.oldHeroPower then
            attrList[1].valueLabel.color = NGUIMath.HexToColor(0xFFFFFFFFF)
        elseif heroPower > _ui.oldHeroPower then
            attrList[1].valueLabel.color = NGUIMath.HexToColor(0x00FF1EFF)
        else
            attrList[1].valueLabel.color = NGUIMath.HexToColor(0xFF0000FF)
        end

        if attrValue == _ui.oldAttrValue then
            attrList[2].valueLabel.color = NGUIMath.HexToColor(0xFFFFFFFFF)
        elseif attrValue > _ui.oldAttrValue then
            attrList[2].valueLabel.color = NGUIMath.HexToColor(0x00FF1EFF)
        else
            attrList[2].valueLabel.color = NGUIMath.HexToColor(0xFF0000FF)
        end
    end

    local nameText, valueText = HeroAppointUI.GetSkill(heroMsg, heroData, _ui.buildingData.id)
    if nameText ~= nil then
        attrList[3].gameObject:SetActive(true)
        attrList[3].nameLabel.text = nameText
        attrList[3].valueLabel.text = valueText
    else
        attrList[3].gameObject:SetActive(false)
    end
end

function LoadUI()
    if _ui.oldHeroMsg ~= nil then
        _ui.appointmentOne.gameObject:SetActive(false)
        _ui.appointmentTwo.gameObject:SetActive(true)
        LoadAppointment(_ui.appointmentTwo[1], _ui.oldHeroMsg, _ui.oldHeroData)
        if _ui.appointedHeroMsg ~= nil then
            LoadAppointment(_ui.appointmentTwo[2], _ui.appointedHeroMsg, _ui.appointedHeroData)
        end
    else
        _ui.appointmentOne.gameObject:SetActive(true)
        _ui.appointmentTwo.gameObject:SetActive(false)
        if _ui.appointedHeroMsg ~= nil then
            LoadAppointment(_ui.appointmentOne, _ui.appointedHeroMsg, _ui.appointedHeroData)
        end
    end

end

local function UpdateHeroList(go, wrapIndex, realIndex)
    -- local heroListData = HeroListData.GetData()
    local heroListData = GeneralData.GetGenerals()
    if _ui.listData == nil then
        local listData = {}
        for _, v in ipairs(heroListData) do
            local heroData = TableMgr:GetHeroData(v.baseid) 
            if not heroData.expCard and not (_ui.oldHeroMsg ~= nil and _ui.oldHeroMsg.uid == v.uid) then
                table.insert(listData, { v, heroData, GeneralData.GetAttributes(v)[1] })
            end
        end

        local buildingData = _ui.buildingData
        local buildingID = buildingData.id
        local effectiveAttributeID = Global.GetAttributeLongID(10000, buildingData.appointattr)

        table.sort(listData, function(v1, v2)
            local isFree1 = v1[1].appointInfo.buildType == 0
            local isFree2 = v2[1].appointInfo.buildType == 0

            if isFree1 ~= isFree2 then
                return isFree1
            else
                local heroInfo1 = v1[1]
                local heroInfo2 = v2[1]

                local hasEffectiveSkill1 = GeneralData.HasAppointmentSkillForBuilding(heroInfo1, v1[2], buildingID)
                local hasEffectiveSkill2 = GeneralData.HasAppointmentSkillForBuilding(heroInfo2, v2[2], buildingID)

                if hasEffectiveSkill1 ~= hasEffectiveSkill2 then
                    return hasEffectiveSkill1
                else
                    local effectiveAttribute1 = v1[3][effectiveAttributeID]
                    local effectiveAttribute2 = v2[3][effectiveAttributeID]
                    
                    if effectiveAttribute1 ~= effectiveAttribute2 then
                        return effectiveAttribute1 > effectiveAttribute2
                    else
                        return heroInfo1.baseid < heroInfo2.baseid
                    end
                end
            end

            -- if appointed1 == appointed2 then
            --     local recommend1 = HeroListData.HasAppointSkillDataByBuildingId(v1[2], _ui.buildingMsg.type)
            --     local recommend2 = HeroListData.HasAppointSkillDataByBuildingId(v2[2], _ui.buildingMsg.type)
            --     if recommend1 == recommend2 then
            --         local power1 = HeroListData.GetPower(v1[1], v1[2])
            --         local power2 = HeroListData.GetPower(v2[1], v2[2])
            --         if power1 == power2 then
            --             return v1[1].uid < v2[1].uid
            --         end
            --         return power1 > power2
            --     end

            --     return recommend1 and not recommend2
            -- end
            -- return not appointed1 and appointed2
        end)

        _ui.listData = listData
    end

    for i = 1, _ui.heroCol do
        local hero = {}
        local heroTransform = go.transform:GetChild(i - 1)
        HeroList.LoadHeroObject(hero, heroTransform)
        local heroIndex = -realIndex * _ui.heroCol + i
        local heroMsg
        local heroData
        local data = _ui.listData[heroIndex]
        if data ~= nil then
            heroMsg, heroData = data[1], data[2]
        end
        if heroMsg ~= nil then
            HeroList.LoadHero(hero, heroMsg, heroData)
            if _ui.appointedHeroMsg ~= nil and heroMsg.uid == _ui.appointedHeroMsg.uid then
                _ui.selectedHeroTransform = hero.transform
                _ui.selectedHeroTransform:Find("select").gameObject:SetActive(true)
            else
                hero.transform:Find("select").gameObject:SetActive(false)
            end

            local appointedObject = hero.transform:Find("inAppoint").gameObject
            appointedObject:SetActive(heroMsg.appointInfo.buildType ~= 0)
            local recommendObject = hero.transform:Find("recommend").gameObject
            --recommendObject:SetActive(HeroListData.HasAppointSkillDataByBuildingId(heroData, _ui.buildingMsg.type))
            recommendObject:SetActive(GeneralData.HasAppointmentSkillForBuilding(heroMsg, heroData, _ui.buildingMsg.type))
            heroTransform.gameObject.name = _ui.defaultHeroName .. heroMsg.baseid
            SetClickCallback(hero.btn.gameObject, function(go)
                _ui.appointedHeroMsg = heroMsg
                _ui.appointedHeroData = heroData
                if _ui.selectedHeroTransform ~= nil then
                    _ui.selectedHeroTransform:Find("select").gameObject:SetActive(false)
                end
                _ui.selectedHeroTransform = hero.transform
                _ui.selectedHeroTransform:Find("select").gameObject:SetActive(true)
                LoadUI()
            end)
            heroTransform.gameObject:SetActive(true)
        else
            heroTransform.gameObject:SetActive(false)
        end
    end
end

function Awake()
    local closeButton = transform:Find("Container/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    _ui.appointmentOne = {}
    local appointmentOneTransform = transform:Find("Container/top widget one")
    LoadAppointmentObject(_ui.appointmentOne, appointmentOneTransform)
    _ui.appointmentTwo = {}
    local appointmentTwoTransform = transform:Find("Container/top widget two")
    _ui.appointmentTwo.gameObject = appointmentTwoTransform.gameObject
    for i = 1, 2 do
        _ui.appointmentTwo[i] = {}
    end
    LoadAppointmentObject(_ui.appointmentTwo[1], transform:Find("Container/top widget two/left"))
    LoadAppointmentObject(_ui.appointmentTwo[2], transform:Find("Container/top widget two/right"))

    _ui.heroListScrollView = transform:Find("Container/down widget/Scroll View"):GetComponent("UIScrollView")
    _ui.heroListWrapContent = transform:Find("Container/down widget/Scroll View/wrap"):GetComponent("UIWrapContent")
    _ui.heroRow = _ui.heroListWrapContent.transform.childCount
    _ui.heroCol = _ui.heroListWrapContent.transform:GetChild(0).childCount
    _ui.defaultHeroName = _ui.heroListWrapContent.transform:GetChild(0):GetChild(0).name
    -- HeroListData.AddListener(LoadUI)

    -- local heroListData = HeroListData.GetData()
    local heroListData = GeneralData.GetGenerals()
    local rowCount = math.floor(#heroListData / _ui.heroCol)
    _ui.heroListWrapContent.minIndex = -rowCount
    _ui.heroListScrollView.disableDragIfFits = rowCount < _ui.heroRow
    _ui.heroListScrollView:ResetPosition()
    _ui.heroListWrapContent:ResetToStart()

    _ui.confirmObject = transform:Find("Container/bg/btn").gameObject
    SetClickCallback(_ui.confirmObject, function()
        if _ui == nil then
            return
        end
        if _ui.appointedHeroMsg == nil then
            CloseAll()
        else
            local function RequestAppoint()
                local req = HeroMsg_pb.MsgAppointHeroRequest()
                req.buildType = _ui.buildingData.id
                req.index = _ui.heroIndex
                req.heroUid = _ui.appointedHeroMsg.uid
                Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgAppointHeroRequest, req, HeroMsg_pb.MsgAppointHeroResponse, function(msg)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.ShowError(msg.code)
                    else
                        if not Global.IsDistVersion() then
                            print(string.format("委任成功 建筑id:%d, 建筑id:%d, 将军uid:%d, 将军baseid:%d", _ui.buildingMsg.type,  _ui.buildingMsg.uid,  _ui.appointedHeroMsg.uid, _ui.appointedHeroMsg.baseid))
                        end
                        -- HeroListData.UpdateData(msg.heroFresh)
                        GeneralData.UpdateData(msg.heroFresh)
                        CloseAll()
                    end
                end)
            end
            if _ui.appointedHeroMsg.appointInfo.buildType ~= 0 then
                MessageBox.Show(TextMgr:GetText(Text.hero_in_appoint_confirm), RequestAppoint, function() end)
            else
                RequestAppoint()
            end
        end
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralAppointmentChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, LoadUI)
end

function Start()
    _ui.heroListWrapContent.onInitializeItem = UpdateHeroList
    _ui.heroListWrapContent:ResetToStart()
end

function Close()
    EventDispatcher.UnbindAll(_M)

    _ui.heroListWrapContent.onInitializeItem = nil
    -- HeroListData.RemoveListener(LoadUI)
    _ui = nil
end

function Show(buildingMsg, buildingData, heroIndex, oldHeroMsg, oldHeroData)
    Global.OpenUI(_M)
    _ui.buildingMsg = buildingMsg
    _ui.buildingData = buildingData
    _ui.heroIndex = heroIndex
    _ui.oldHeroMsg = oldHeroMsg
    _ui.oldHeroData = oldHeroData
    _ui.oldHeroPower = 0
    _ui.oldAttrValue = 0
    if oldHeroMsg ~= nil then
        -- _ui.oldHeroPower = HeroListData.GetPower(oldHeroMsg, oldHeroData)
        -- _ui.oldAttrValue = HeroListData.GetPowerCoef(_ui.oldHeroPower) * _ui.buildingData.value1
        local attribute = GeneralData.GetAttributes(oldHeroMsg, 10000, buildingData.appointattr)[1]

        _ui.oldHeroPower = math.floor(attribute)
        _ui.oldAttrValue = attribute * buildingData.value1
    end
    LoadUI()
end
