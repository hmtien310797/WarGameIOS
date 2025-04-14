module("WarZoneMap", package.seeall)
local GUIMgr = Global.GGUIMgr
local Controller = Global.GController
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local UIAnimMgr = Global.GUIAnimMgr
local String = System.String
local WorldToLocalPoint = NGUIMath.WorldToLocalPoint
local Screen = UnityEngine.Screen
local abs = math.abs
local isEditor = UnityEngine.Application.isEditor

local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local math = math
local Mathf = Mathf
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local PosToDataIndex = MapPreviewData.PosToDataIndex
local XYToDataIndex = MapPreviewData.XYToDataIndex
local IsUnionField = MapPreviewData.IsUnionField
local IsNeighboringCoord = Global.IsNeighboringCoord
local MapPool = MapPool

local halfScreenWidth = UnityEngine.Screen.width * 0.5
local halfScreenHeight = UnityEngine.Screen.height * 0.5

local mapSize
local tileWidth
local tileHeight

local selectedMapX
local selectedMapY

local uiRoot
local screenWidth
local screenHeight

local filterIndex = 1
local showSelf = true
local restrictStartX
local restrictStartY
local restrictEndX
local restrictEndY

local poolConfigList =
{
    markInfo = {"Traget_icon", 50},
    nameInfo = {"unionname", 20},
    unionBorder = {"border", 100},
    fortInfo = {"Fort_icon",100},
}

local oldMapX
local oldMapY
local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

local function InRestrict(mapX, mapY)
    return mapX >= restrictStartX and mapX <= restrictEndX and mapY >= restrictStartY and mapY <= restrictEndY
end

local function GetBorderSpriteName(guildId, mapX, mapY)
    local spriteName = 0
    if mapX == 0 or MapPreviewData.GetGuildIdByXY(mapX - 1, mapY) ~= guildId then
        spriteName = bit.bor(spriteName, 8)
    end

    if mapY == 0 or MapPreviewData.GetGuildIdByXY(mapX, mapY - 1) ~= guildId then
        spriteName = bit.bor(spriteName, 4)
    end

    if mapX == mapSize - 1 or MapPreviewData.GetGuildIdByXY(mapX + 1, mapY) ~= guildId then
        spriteName = bit.bor(spriteName, 2)
    end

    if mapY == mapSize - 1 or MapPreviewData.GetGuildIdByXY(mapX, mapY + 1) ~= guildId then
        spriteName = bit.bor(spriteName, 1)
    end

    return spriteName
end

local function MapPositionToMapCoord(mapPos)
    local x = mapPos.x / tileWidth
    local y = mapPos.y / tileHeight
    return Mathf.Round(y + x), Mathf.Round(y - x)
end

local function MapCoordToMapPosition(mapX, mapY)
    return Vector3((mapX - mapY) * tileWidth * 0.5, (mapX + mapY) * tileHeight * 0.5)
end

local function ScreenPositionToMapCoord(screenPosition)
    local mapPos = NGUIMath.ScreenToPixels(screenPosition, _ui.mapTransform)
    return MapPositionToMapCoord(mapPos)
end

local function MapToZoneCoord(coord)
    return math.floor(coord / 8)
end

function SelectTile(mapX, mapY)
    selectedMapX, selectedMapY = mapX, mapY
    _ui.tileSelectedWidget.gameObject:SetActive(true)
    _ui.tileSelectedWidget.transform.localPosition = MapCoordToMapPosition(mapX, mapY)
    UITweener.PlayAllTweener(_ui.tileSelectedWidget.gameObject, true, true, false)
    _ui.tileSelectedWidget:GetComponent("UITweener"):SetOnFinished(EventDelegate.Callback(function()
        Hide()
        local worldMapX, worldMapY
        if mapX == 22 and mapY == 22 then
            worldMapX = 161
            worldMapY = 161
        else
            worldMapX = mapX * 8 + 3
            worldMapY = mapY * 8 + 3
        end
        WorldMap.LookAt(worldMapX, worldMapY)
        WorldMap.SelectTile(worldMapX, worldMapY)
    end))
end

local function UpdateUnionName()
    _ui.poolList.nameInfo:Reset()
    local mapPosition = _ui.mapTransform.localPosition
    local nameAreaList = {}
    for mapY = 0, mapSize - 1 do
        for mapX = 0, mapSize - 1 do
            local tileLocalPosition = MapCoordToMapPosition(mapX, mapY)
            local tilePosition = tileLocalPosition + mapPosition
            local dataIndex = XYToDataIndex(mapX, mapY)
            local fieldData = MapPreviewData.GetFieldDataByIndex(dataIndex)

            local guildId = 0
            if fieldData ~= nil then
                guildId = fieldData.data.guildid
                local unionIndex = fieldData.index
                if math.ceil(unionIndex * 0.1) == filterIndex or (showSelf and guildId == UnionInfoData.GetGuildId()) then
                    if abs(tilePosition.x) < halfScreenWidth and abs(tilePosition.y) < halfScreenHeight then
                        local findNameArea = false
                        for _, v in ipairs(nameAreaList) do
                            for __, vv in ipairs(v) do
                                if IsUnionField(guildId, vv[1], vv[2]) and IsNeighboringCoord(mapX, mapY, vv[1], vv[2]) then
                                    table.insert(v, {mapX, mapY, tileLocalPosition.x, tileLocalPosition.y, fieldData})
                                    findNameArea = true
                                    break
                                end
                            end
                            if findNameArea then
                                break
                            end
                        end

                        if not findNameArea then
                            table.insert(nameAreaList, {{mapX, mapY, tileLocalPosition.x, tileLocalPosition.y, fieldData}})
                        end
                    end
                end
            end
        end
    end

    for i, v in ipairs(nameAreaList) do
        if #v > 1 then
            local centerX = (v[1][1] + v[#v][1]) * 0.5
            local nameAreaIndex = 1
            local centerY = (v[1][2] + v[#v][2]) * 0.5

            local centerSqrMagnitude = math.huge 
            for ii, vv in ipairs(v) do
                local diffX = vv[1] - centerX
                local diffY = vv[2] - centerY

                local sqrMagnitude = diffX * diffX + diffY * diffY
                if sqrMagnitude < centerSqrMagnitude then
                    centerSqrMagnitude = sqrMagnitude
                    nameAreaIndex = ii
                end
            end


            local nameArea = v[nameAreaIndex]
            local info, createNew = _ui.poolList.nameInfo:Accquire()
            local infoTransform = info.transform
            if createNew then
                infoTransform:SetParent(_ui.infoBgTransform, false)
            end
            local fieldData = nameArea[5]
            local unionIndex = fieldData.index
            local unionBanner = fieldData.data.guildbanner
            local mapX = nameArea[1]
            local mapY = nameArea[2]
            if mapX < centerX then
                mapX = mapX + 0.5
            elseif mapX > centerX then
                mapX = mapX - 0.5
            end
            if mapY < centerY then
                mapY = mapY + 0.5
            elseif mapY > centerY then
                mapY = mapY - 0.5
            end
            infoTransform.localPosition = MapCoordToMapPosition(mapX, mapY)
            local unionNameLabel = infoTransform:Find("text"):GetComponent("UILabel")
            if isEditor then
                infoTransform.name = unionBanner
            end
            unionNameLabel.text = string.format("%d.%s", unionIndex, unionBanner)
            local fieldCount = #v
            local fontSize = 16
            if fieldCount >= 4 and fieldCount <= 8 then
                fontSize = 18
            elseif fieldCount >= 9 and fieldCount <= 16 then
                fontSize = 20
            elseif fieldCount >= 16 then
                fontSize = 22
            end
            unionNameLabel.fontSize = fontSize
        end
    end
    _ui.poolList.nameInfo:Release()
end

local function UpdateMap()
    _ui.filterLabel.text = TextMgr:GetText("Warzonemap_union_"..filterIndex)
    local basePos = MapInfoData.GetData().mypos

    local baseMapX = MapToZoneCoord(basePos.x)
    local baseMapY = MapToZoneCoord(basePos.y)

    for _, v in pairs(_ui.poolList) do
        v:Reset()
    end

    local tiledMap = _ui.tiledMap
    local fieldMap = _ui.fieldMap
    fieldMap:HideAllTile()
    for mapY = 0, mapSize - 1 do
        for mapX = 0, mapSize - 1 do
            local dataIndex = XYToDataIndex(mapX, mapY)
            local fieldData = MapPreviewData.GetFieldDataByIndex(dataIndex)

            local borderSpriteName = 0
            local showField = false

            local guildId = 0
            if fieldData ~= nil then
                guildId = fieldData.data.guildid
                local unionIndex = fieldData.index
                if math.ceil(unionIndex * 0.1) == filterIndex or (showSelf and guildId == UnionInfoData.GetGuildId()) then
                    showField = true
                end
            end
            if showField then
                local badgeColor = UnionBadge.GetBadgeColorById(fieldData.data.guildbadge)
                tiledMap:SetTile(mapX, mapY, "gezi", badgeColor, true)
                borderSpriteName = GetBorderSpriteName(guildId, mapX, mapY)
            else
                tiledMap:SetTile(mapX, mapY, "gezidian", Color.white, true)
            end

            if borderSpriteName ~= 0 then
                fieldMap:SetTile(mapX, mapY, borderSpriteName, Color.white, true)
            end

            local index = 0
            local infoTransform = nil
            local markInfoData = _ui.markInfoDataList[dataIndex]
            local pveMonsterInfoData = _ui.pveMonsterSign[dataIndex]
            local guildlLaderPos = _ui.guildlLaderPos[dataIndex]
            local guildlMemberPos = _ui.guildlMemberPos[dataIndex]            

            if markInfoData ~= nil or pveMonsterInfoData ~= nil or guildlMemberPos ~= nil then
                local info, createNew = _ui.poolList.markInfo:Accquire()
                infoTransform = info.transform
                if createNew then
                    infoTransform:SetParent(_ui.infoBgTransform, false)
                end
                infoTransform.localPosition = MapCoordToMapPosition(mapX, mapY)
            end
            if markInfoData ~= nil then
                index = index + 1
                local type
                for _, v in ipairs(markInfoData) do
                    type = v.data.msg.type
                end
                local info = infoTransform:Find("selected"..index)
                info.gameObject:SetActive(true)
                info:GetComponent("UISprite").spriteName = Traget_View.GetTargetIcon(type)
            end
            if pveMonsterInfoData ~= nil then
                index = index + 1
                local info = infoTransform:Find("selected"..index)
                info.gameObject:SetActive(true)
                info:GetComponent("UISprite").spriteName = "icon_pvemonster"
            end
            if guildlMemberPos ~= nil then
                if #guildlMemberPos >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.WorldZoneMapGuildlMember).value) then
                    index = index + 1
                    local info = infoTransform:Find("selected"..index)
                    info.gameObject:SetActive(true)
                    if guildlLaderPos ~= nil then
                        --盟主
                        info:GetComponent("UISprite").spriteName = "GuildlLader"
                    else
                        info:GetComponent("UISprite").spriteName = "GuildlMember"
                    end
                end
            end                


            local fortInfoData = _ui.fortSign[dataIndex]
            if fortInfoData ~= nil then
                for _, v in pairs(fortInfoData) do
                    local info, createNew = _ui.poolList.fortInfo:Accquire()
                    local infoTransform = info.transform
                    if createNew then
                        infoTransform:SetParent(_ui.infoBgTransform, false)
                    end
                    local mx = v.x % 8
                    local my = v.y % 8
                    local sx = mx - my
                    local sy = mx + my 
                    infoTransform.localPosition = MapCoordToMapPosition(mapX, mapY)
                    infoTransform.localPosition = infoTransform.localPosition + Vector3(sx, sy, 0)

                    local fortdata = FortsData.GetFortData(v.id)
                    if fortdata ~= nil then
                        infoTransform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText(v.name)
                        local fortOwnerName = infoTransform:Find("Label (1)"):GetComponent("UILabel")
                        local rebelIcon = infoTransform:Find("rebelIcon")
                        local derelictIcon = infoTransform:Find("derelictIcon")
                        local badgetrf = infoTransform:Find("badge bg")
                        badgetrf.gameObject:SetActive(false)
                        derelictIcon.gameObject:SetActive(false)
                        rebelIcon.gameObject:SetActive(false)
                        local status = FortsData.GetFortStatus()
                        if status == 4 then
                            if table.getn(fortdata.occupyInfo.rankList) == 0 then
                                fortOwnerName.text = TextMgr:GetText("Fort_ui5")
                                fortOwnerName.color = Color.red
                                rebelIcon.gameObject:SetActive(true)
                            else
                                if fortdata.occupyInfo.ownerInfo ~= nil and fortdata.occupyInfo.ownerInfo.guildId ~= 0 then
                                    fortOwnerName.text = string.format("[%s]%s", fortdata.occupyInfo.ownerInfo.guildBanner, fortdata.occupyInfo.ownerInfo.guildName)
                                    local badge = {}
                                    UnionBadge.LoadBadgeObject(badge,badgetrf)
                                    UnionBadge.LoadBadgeById(badge, fortdata.occupyInfo.ownerInfo.guildBadge )   
                                    badgetrf.gameObject:SetActive(true)
                                    fortOwnerName.color = Color(86/255,192/255,1,1)
                                else
                                    fortOwnerName.text = TextMgr:GetText("Duke_83") -- 无城主
                                    derelictIcon.gameObject:SetActive(true)
                                    fortOwnerName.color = Color.white
                                end
                            end
                        else
                            fortOwnerName.text = TextMgr:GetText("Fort_ui5")
                            rebelIcon.gameObject:SetActive(true)
                            fortOwnerName.color = Color.red
                            --fortOwnerName.color = Color(86/255,192/255,1,1)
                        end

                        local fortOwnerState = infoTransform:Find("Label (2)"):GetComponent("UILabel")
                        local now = Serclimax.GameTime.GetSecTime()
                        if not fortdata.available then
                            fortOwnerState.text = TextMgr:GetText("Fort_ui6")
                        else
                            local cfg =  FortsData.GetFortActConfig()
                            --if now < cfg.forecastStartTime or now >= cfg.occupyEndTime then
                            --    fortOwnerState.text = TextMgr:GetText("Fort_ui1")
                            --else
                            CountDown.Instance:Add("FortInfo_ZoneMap"..v.id,cfg.occupyEndTime,CountDown.CountDownCallBack(function(t)
                                local endtime = cfg.occupyEndTime
                                now = Serclimax.GameTime.GetSecTime()
                                if now < cfg.forecastStartTime then
                                    fortOwnerState.text = TextMgr:GetText("Fort_ui1")
                                    if now >= cfg.occupyEndTime then
                                        fortOwnerName.text = TextMgr:GetText("Fort_ui5")
                                        fortOwnerName.color = Color.red
                                        rebelIcon.gameObject:SetActive(true)                                       
                                        badgetrf.gameObject:SetActive(false)
                                        derelictIcon.gameObject:SetActive(false)
                                        CountDown.Instance:Remove("FortInfo_ZoneMap"..v.id)
                                    end
                                    return
                                end

                                if now >= cfg.forecastStartTime and now < cfg.contendStartTime then
                                    endtime = cfg.contendStartTime
                                    local lefttime = Global.GetLeftCooldownSecond(endtime)
                                    fortOwnerState.text = String.Format( TextMgr:GetText("Fort_ui2"),Global.SecondToTimeLong(lefttime))
                                elseif now >= cfg.contendStartTime and now < cfg.contendEndTime then
                                    endtime = cfg.contendEndTime
                                    local lefttime = Global.GetLeftCooldownSecond(endtime)
                                    fortOwnerState.text = String.Format( TextMgr:GetText("Fort_ui4"),Global.SecondToTimeLong(lefttime))
                                elseif now >= cfg.contendEndTime and now < cfg.occupyEndTime  then
                                    endtime = cfg.occupyEndTime
                                    local lefttime = Global.GetLeftCooldownSecond(endtime)
                                    fortOwnerState.text = String.Format( TextMgr:GetText("Fort_ui3"),Global.SecondToTimeLong(lefttime))
                                end
                            end))
                        end
                        --infoTransform:Find("selected"):GetComponent("UISprite").spriteName = "icon_pvemonster"

                    end
                end
            end
        end
    end

    for _, v in pairs(_ui.poolList) do
        v:Release()
    end

    tiledMap:MarkAsChanged()
    fieldMap:MarkAsChanged()
    UpdateUnionName()

    for i, v in ipairs(_ui.turretList) do
        local turretData = tableData_tTurret.data[i]
        local turretMsg = GovernmentData.GetTurretData(turretData.id)
        local mapX = MapToZoneCoord(turretData.Xcoord)
        local mapY = MapToZoneCoord(turretData.Ycoord)
        v.transform.localPosition = MapCoordToMapPosition(mapX, mapY)
        v.nameLabel.text = TextMgr:GetText(turretData.name)
        if turretMsg.rulingInfo.guildId == 0 then
            v.ownerLabel.text = TextMgr:GetText("Fort_ui5")
            v.ownerLabel.color = Color.white
            v.derelictObject:SetActive(true)
        else
            v.ownerLabel.text = string.format("[%s]%s", turretMsg.rulingInfo.guildBanner, turretMsg.rulingInfo.guildName)
            v.derelictObject:SetActive(false)
            local badge = {}
            UnionBadge.LoadBadgeObject(badge, v.badgeTransform)
            UnionBadge.LoadBadgeById(badge, turretMsg.rulingInfo.guildBadge )   

            v.ownerLabel.color = Color(86/255, 192/255, 1)
            if turretMsg.rulingInfo.guildId ~= UnionInfoData.GetGuildId() then
                v.ownerLabel.color = Color(1, 0, 0)
            end
        end
    end
    table.foreach(_ui.strongholdList,function(i,v)
        local strongholdMsg = v.msg
        if strongholdMsg.available then
            v.gameObject:SetActive(true)
            local strongholdData = tableData_tStrongholdRule.data[strongholdMsg.subtype]
            local mapX = MapToZoneCoord(strongholdData.Xcoord)
            local mapY = MapToZoneCoord(strongholdData.Ycoord)
            v.transform.localPosition = MapCoordToMapPosition(mapX, mapY)
            v.nameLabel.text = TextMgr:GetText(strongholdData.name)
            if strongholdMsg.rulingInfo.guildId == 0 then
                v.ownerLabel.text = TextMgr:GetText("Fort_ui5")
                v.ownerLabel.color = Color.white
                v.derelictObject:SetActive(true)
            else
                v.ownerLabel.text = string.format("[%s]%s", strongholdMsg.rulingInfo.guildBanner, strongholdMsg.rulingInfo.guildName)
                v.derelictObject:SetActive(false)
                local badge = {}
                UnionBadge.LoadBadgeObject(badge, v.badgeTransform)
                UnionBadge.LoadBadgeById(badge, strongholdMsg.rulingInfo.guildBadge )

                v.ownerLabel.color = Color(86/255, 192/255, 1)
                if strongholdMsg.rulingInfo.guildId ~= UnionInfoData.GetGuildId() then
                    v.ownerLabel.color = Color(1, 0, 0)
                end
            end
        else
            v.gameObject:SetActive(false)
        end
    end)

    for i, v in ipairs(_ui.fortressList) do
        local fortressMsg = v.msg
        if fortressMsg.available then
            v.gameObject:SetActive(true)
            local fortressData = TableMgr:GetFortressRuleByID(fortressMsg.subtype)-- tableData_tStrongholdRule.data[strongholdMsg.subtype]
            local mapX = MapToZoneCoord(fortressData.Xcoord)
            local mapY = MapToZoneCoord(fortressData.Ycoord)
            v.transform.localPosition = MapCoordToMapPosition(mapX, mapY)
            v.nameLabel.text = TextMgr:GetText(fortressData.name)

            if fortressMsg.rulingInfo.guildId == 0 then
                v.ownerLabel.text = TextMgr:GetText("Fort_ui5")
                v.ownerLabel.color = Color.white
                v.derelictObject:SetActive(true)
            else
                v.ownerLabel.text = string.format("[%s]%s", fortressMsg.rulingInfo.guildBanner, fortressMsg.rulingInfo.guildName)
                v.derelictObject:SetActive(false)
                local badge = {}
                UnionBadge.LoadBadgeObject(badge, v.badgeTransform)
                UnionBadge.LoadBadgeById(badge, fortressMsg.rulingInfo.guildBadge )   

                v.ownerLabel.color = Color(86/255, 192/255, 1)
                if fortressMsg.rulingInfo.guildId ~= UnionInfoData.GetGuildId() then
                    v.ownerLabel.color = Color(1, 0, 0)
                end
            end
        else
            v.gameObject:SetActive(false)
        end
    end


    _ui.baseTransform.localPosition = MapCoordToMapPosition(baseMapX, baseMapY)

    local govdata = GovernmentData.GetGovernmentData()
    _ui.governmentTransform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText("GOV_ui7")
    local govOwnerName = _ui.governmentTransform:Find("Label (1)"):GetComponent("UILabel")
    local rebelIcon = _ui.governmentTransform:Find("rebelIcon")
    local derelictIcon = _ui.governmentTransform:Find("derelictIcon")
    local badgetrf = _ui.governmentTransform:Find("badge bg")
    badgetrf.gameObject:SetActive(false)
    derelictIcon.gameObject:SetActive(false)
    rebelIcon.gameObject:SetActive(false)
    local status = GovernmentData.GetGOVState()
    if govdata.archonInfo.guildId == 0  then
        govOwnerName.text = TextMgr:GetText("Fort_ui5")
        govOwnerName.color = Color.white
        derelictIcon.gameObject:SetActive(true)
    else
        govOwnerName.text = string.format("[%s]%s", govdata.archonInfo.guildBanner, govdata.archonInfo.guildName)
        local badge = {}
        UnionBadge.LoadBadgeObject(badge,badgetrf)
        UnionBadge.LoadBadgeById(badge, govdata.archonInfo.guildBadge )   
        badgetrf.gameObject:SetActive(true)
        local myguid =  UnionInfoData.GetGuildId()
        local govGuildId = GovernmentData.GetGOVRulerGuildID()
        if (govGuildId ~= myguid) then
            govOwnerName.color = Color(1, 0, 0,1)
        else
            govOwnerName.color = Color(86/255,192/255,1,1)
        end
        
    end
    local govOwnerState = _ui.governmentTransform:Find("Label (2)"):GetComponent("UILabel")

    if status == 1 then
        govOwnerState.text =TextMgr:GetText("GOV_ui5")
    elseif status == 2 then
        govOwnerState.text = TextMgr:GetText("GOV_ui6")
    end
end

local function SetMapPosition(x, y)
    x = Mathf.Clamp(x, -(mapSize * tileWidth * 0.5 - screenWidth * 0.5), mapSize * tileWidth * 0.5 - screenWidth * 0.5)
    y = Mathf.Clamp(y, -(mapSize + mapSize - 1) * tileHeight * 0.5 + screenHeight * 0.5, tileHeight * 0.5 -screenHeight * 0.5)
    _ui.mapTransform.localPosition = Vector3(x, y, 0)
end

local function MapBgDragCallback(go, delta)
    delta = delta * uiRoot.pixelSizeAdjustment

    local mapPosition = _ui.mapTransform.localPosition

    SetMapPosition(mapPosition.x + delta.x, mapPosition.y + delta.y)
    UpdateUnionName()
end

local function DisposeTurretRulingPush()
    UpdateMap()
end

local function DisposeGovRulingPush()
    UpdateMap()
end

local function MapBgClickCallback(go)
    local touchPos = UICamera.currentTouch.pos
    local mapX, mapY = ScreenPositionToMapCoord(touchPos)
    SelectTile(mapX, mapY)
end

local function SetLookAtCoord(mapX, mapY)
    local localPosition = MapCoordToMapPosition(mapX, mapY)
    SetMapPosition(-localPosition.x, -localPosition.y)
end

local function UpdateTime()
    local serverTime = GameTime.GetSecTime()

    table.foreach(_ui.strongholdList,function(i,v)
        local strongholdMsg = v.msg
        local startTime = strongholdMsg.contendStartTime
        local endTime = strongholdMsg.contendEndTime
        if serverTime < startTime then
            v.timeLabel.text = ""--String.Format(TextMgr:GetText(Text.GOV_ui78), Global.GetLeftCooldownTextLong(startTime))
        elseif serverTime < endTime then
            v.timeLabel.text = String.Format(TextMgr:GetText(Text.GOV_ui79), Global.GetLeftCooldownTextLong(endTime))
        else
            v.timeLabel.text = TextMgr:GetText(Text.war_over)
        end
    end)

    for _, v in ipairs(_ui.fortressList) do
        local fortressMsg = v.msg
        local serverTime = GameTime.GetSecTime()
        local startTime = fortressMsg.contendStartTime
        local endTime = fortressMsg.contendEndTime
        if serverTime < startTime then
            v.timeLabel.text = ""--String.Format(TextMgr:GetText(Text.GOV_ui78), Global.GetLeftCooldownTextLong(startTime))
        elseif serverTime < endTime then
            v.timeLabel.text = String.Format(TextMgr:GetText(Text.GOV_ui79), Global.GetLeftCooldownTextLong(endTime))
        else
            v.timeLabel.text = TextMgr:GetText(Text.war_over)
        end
    end
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

function Awake()
    _ui = {}
    uiRoot = GUIMgr.UIRoot:GetComponent("UIRoot")
    screenWidth = UnityEngine.Screen.width * uiRoot.pixelSizeAdjustment
    screenHeight = UnityEngine.Screen.height * uiRoot.pixelSizeAdjustment
    _ui.infoBgTransform = transform:Find("Container/map_bg/map/info_bg")

    _ui.baseTransform = _ui.infoBgTransform:Find("mypos")
    _ui.governmentTransform = _ui.infoBgTransform:Find("icon_gov")

    local mapBg = transform:Find("Container/map_bg")
    _ui.mapTransform = mapBg:Find("map")
    _ui.fieldTransform = _ui.mapTransform:Find("fields")
    _ui.tiledMap = _ui.mapTransform:GetComponent("TiledMap")
    _ui.fieldMap = _ui.fieldTransform:GetComponent("TiledMap")
    local bgMap = _ui.mapTransform:Find("bg"):GetComponent("TiledMap")
    local bgMapSize = bgMap.mapSize
    for x = 0, bgMapSize - 1 do
        for y = 0, bgMapSize - 1 do
            local sprite
            if x == 2 and y == 2 then
                sprite = "3"
            else
                sprite = tostring((x + y) % 2 + 1)
            end
            bgMap:SetTile(x, y, sprite, Color.white, true)
        end
    end
    bgMap:MarkAsChanged()

    _ui.markInfoDataList = {}
    local targetData = TragetViewData.GetTragetMap()
    if targetData ~= nil then
        for k, v in pairs(targetData) do
            local posList = string.split(k, ":")
            if posList ~= nil then
                local x = tonumber(posList[1])
                local y = tonumber(posList[2])
                if x ~= nil and y ~= nil then
                    local mapX = MapToZoneCoord(x)
                    local mapY = MapToZoneCoord(y)
                    local dataIndex = XYToDataIndex(mapX, mapY)
                    if _ui.markInfoDataList[dataIndex] == nil then
                        _ui.markInfoDataList[dataIndex] = {}
                    end
                    table.insert(_ui.markInfoDataList[dataIndex], {x = x, y = y, data = v})
                end
            end
        end
    end

    --活动怪标记
    _ui.pveMonsterSign = {}
    local pveMonsterList = MapPreviewData.GetPveMonsterPos()

    if pveMonsterList ~= nil then
        for _ ,v in ipairs(pveMonsterList) do
            if v.x ~= nil and v.y ~= nil then
                local mapX = MapToZoneCoord(v.x)
                local mapY = MapToZoneCoord(v.y)
                local dataIndex = XYToDataIndex(mapX, mapY)
                if _ui.pveMonsterSign[dataIndex] == nil then
                    _ui.pveMonsterSign[dataIndex] = {}
                end
                table.insert(_ui.pveMonsterSign[dataIndex], {x = v.x, y = v.y})
            end
        end
    end
    --联盟标记
    _ui.guildlMemberPos = {}
    local guildlMemberPos = MapPreviewData.GetGuildlMemberPos()
    if guildlMemberPos ~= nil then
        for _ ,v in ipairs(guildlMemberPos) do
            if v.x ~= nil and v.y ~= nil then
                local mapX = MapToZoneCoord(v.x)
                local mapY = MapToZoneCoord(v.y)
                local dataIndex = XYToDataIndex(mapX, mapY)
                if _ui.guildlMemberPos[dataIndex] == nil then
                    _ui.guildlMemberPos[dataIndex] = {}
                end
                table.insert(_ui.guildlMemberPos[dataIndex], {x = v.x, y = v.y})
            end
        end
    end
    --盟主标记
    _ui.guildlLaderPos = {}
    local guildlLaderPos  = MapPreviewData.GetGuildlLaderPos()
    if guildlLaderPos  ~= nil then
        if guildlLaderPos.x ~= nil and guildlLaderPos.y ~= nil then
            local mapX = MapToZoneCoord(guildlLaderPos.x)
            local mapY = MapToZoneCoord(guildlLaderPos.y)
            local dataIndex = XYToDataIndex(mapX, mapY)
            if _ui.guildlLaderPos [dataIndex] == nil then
                _ui.guildlLaderPos [dataIndex] = {}
            end
            table.insert(_ui.guildlLaderPos [dataIndex], {x = guildlLaderPos.x, y = guildlLaderPos.y})
        end
    end


    _ui.fortSign = {}
    local fortlist = {}
    for k, v in pairs(tableData_tFortRule.data) do
        fortlist[k] = {x = v.Xcoord, y = v.Ycoord, name = "Duke_" .. 14 + k, id = v.id}
    end
    if fortlist ~= nil then
        for _ ,v in ipairs(fortlist) do
            if v.x ~= nil and v.y ~= nil then
                local mapX = MapToZoneCoord(v.x)
                local mapY = MapToZoneCoord(v.y)
                local dataIndex = XYToDataIndex(mapX, mapY)
                if _ui.fortSign[dataIndex] == nil then
                    _ui.fortSign[dataIndex] = {}
                end
                --table.insert(_ui.fortSign[dataIndex], {x = v.x, y = v.y,name = v.name,id = v.id})
            end
        end
    end

    local turretList = {}
    for i = 1, 4 do
        local turret = {}
        local turretTransform = transform:Find(string.format("Container/map_bg/map/info_bg/turretBg/Battery_icon (%d)", i))
        turret.transform = turretTransform
        turret.gameObject = turretTransform.gameObject
        turret.nameLabel = turretTransform:Find("Label"):GetComponent("UILabel")
        turret.ownerLabel = turretTransform:Find("Label (1)"):GetComponent("UILabel")
        turret.badgeTransform = turretTransform:Find("badge bg")
        turret.derelictObject = turretTransform:Find("derelictIcon").gameObject
        turretList[i] = turret
    end
    _ui.turretList = turretList

    --++============fortress
    local fortressList = {}
    local fortressPrefab = ResourceLibrary.GetUIPrefab("WarZoneMap/Fort_icon")
    for i, v in ipairs(FortressData.GetAllFortressData()) do
        local fortress = {}
        fortress.msg = v
        fortress.gameObject = GameObject.Instantiate(fortressPrefab)
        fortress.gameObject = fortress.gameObject

        local fortressTransform = fortress.gameObject.transform
        fortressTransform:SetParent(_ui.infoBgTransform, false)
        fortress.transform = fortressTransform

        fortress.gameObject = fortressTransform.gameObject
        fortress.nameLabel = fortressTransform:Find("Label"):GetComponent("UILabel")
        fortress.ownerLabel = fortressTransform:Find("Label (1)"):GetComponent("UILabel")
        fortress.timeLabel = fortressTransform:Find("Label (2)"):GetComponent("UILabel")
        fortress.badgeTransform = fortressTransform:Find("badge bg")
        fortress.derelictObject = fortressTransform:Find("derelictIcon").gameObject
        fortressList[i] = fortress
    end
    _ui.fortressList = fortressList
    ----============fortress


    local strongholdList = {}
    local strongholdPrefab = ResourceLibrary.GetUIPrefab("WarZoneMap/StrongHold")
    table.foreach(StrongholdData.GetAllStrongholdData(),function(i,v)
    --for i, v in ipairs(StrongholdData.GetAllStrongholdData()) do
        local stronghold = {}
        stronghold.msg = v
        stronghold.gameObject = GameObject.Instantiate(strongholdPrefab)
        stronghold.gameObject = stronghold.gameObject
        local strongholdTransform = stronghold.gameObject.transform
        strongholdTransform:SetParent(_ui.infoBgTransform, false)
        stronghold.transform = strongholdTransform
        stronghold.gameObject = strongholdTransform.gameObject
        stronghold.nameLabel = strongholdTransform:Find("Label"):GetComponent("UILabel")
        stronghold.ownerLabel = strongholdTransform:Find("Label (1)"):GetComponent("UILabel")
        stronghold.timeLabel = strongholdTransform:Find("Label (2)"):GetComponent("UILabel")
        stronghold.badgeTransform = strongholdTransform:Find("badge bg")
        stronghold.derelictObject = strongholdTransform:Find("derelictIcon").gameObject
        strongholdList[i] = stronghold
    end)
    _ui.strongholdList = strongholdList

    _ui.poolList = {}
    for k, v in pairs(poolConfigList) do
        local prefab = ResourceLibrary.GetUIPrefab("WarZoneMap/"..v[1])
        _ui.poolList[k] = MapPool(prefab, v[2])
    end

    if restrictStartX == nil then
        local restrictData = WorldMap.GetRestrictData()
        restrictStartX = math.ceil(restrictData.coordX / 8)
        restrictStartY = math.ceil(restrictData.coordY / 8)
        restrictEndX = math.floor((restrictData.coordX + restrictData.width - 1) / 8) - 1
        restrictEndY = math.floor((restrictData.coordY + restrictData.height - 1) / 8) - 1
    end

    local resButton = transform:Find("Container/btn_resmap"):GetComponent("UIButton")
    local resObject = transform:Find("Container/map_bg/map/resmap").gameObject
    local limitBgObject = transform:Find("Container/map_bg/map/info_bg/bg_delivery").gameObject
    SetClickCallback(resButton.gameObject, function()
        resObject:SetActive(not resObject.activeSelf)
        limitBgObject:SetActive(not limitBgObject.activeSelf)
    end)
    local gradeTable = tableData_tMapGrade.data
    local baseLevel = BuildingData.GetCommandCenterData().level
    for i = 1, 3 do
        local limitObject = transform:Find("Container/map_bg/map/info_bg/bg_delivery/" .. i).gameObject
        local requiredLevel = gradeTable[i + 1].baseLevel
        limitObject:SetActive(baseLevel < requiredLevel)
        for j = 1, 8 do
            local lockedTransform = limitObject.transform:Find(string.format("locked (%d)", j))
            if lockedTransform ~= nil then
                lockedTransform:Find("text"):GetComponent("UILabel").text = String.Format(TextMgr:GetText(Text.Level_ui), requiredLevel)
            end
        end
    end

    local filterButton = transform:Find("Container/bg_Territory_Filter/btn_Filter"):GetComponent("UIButton")
    SetClickCallback(filterButton.gameObject, function()
        if not _ui.tileSelectedWidget.gameObject.activeSelf or not  _ui.tileSelectedWidget:GetComponent("UITweener").enabled then
            TerritoryFilter.Show(filterIndex, showSelf, function(index, self)
                if filterIndex ~= index or showSelf ~= self then
                    filterIndex = index
                    showSelf = self
                    UpdateMap()
                end
            end)
        end
    end)
    _ui.filterLabel = transform:Find("Container/bg_Territory_Filter/text"):GetComponent("UILabel")

    local backButton = transform:Find("Container/btn_back")
    SetClickCallback(backButton.gameObject, function()
        Hide()
    end)

    UIUtil.SetDragCallback(mapBg.gameObject, MapBgDragCallback)
    UIUtil.SetPressCallback(mapBg.gameObject, MapBgPressCallback)
    UIUtil.SetClickCallback(mapBg.gameObject, MapBgClickCallback)

    mapSize = _ui.tiledMap.mapSize
    tileWidth = _ui.tiledMap.tileWidth
    tileHeight = _ui.tiledMap.tileHeight

    _ui.tileSelectedWidget = ResourceLibrary.GetUIInstance("WarZoneMap/WarZoneMap_Selected").transform:GetComponent("UIWidget")
    _ui.tileSelectedWidget.gameObject:SetActive(false)
    _ui.tileSelectedWidget.transform:SetParent(_ui.infoBgTransform, false)
    _ui.buttonGlobe = transform:Find("Container/btn_servermap"):GetComponent("UIButton")
    SetClickCallback(_ui.buttonGlobe.gameObject, function()
        Hide()
        WarZoneUI.Show()
    end)

    _ui.help = transform:Find("Container/btn_help")
    SetClickCallback(_ui.help.gameObject, function() 
        MapHelp.OpenMulti(700)
    end)
    UpdateTime()
    local cityPrefab = ResourceLibrary.GetUIPrefab("WarZoneMap/city_icon")
    local cityListMsg = WorldCityData.GetData()
	if cityListMsg then
		for _, v in ipairs(cityListMsg) do
			local cityPos = v.pos
			local cityTransform = NGUITools.AddChild(_ui.infoBgTransform.gameObject, cityPrefab).transform
			local mapX = MapToZoneCoord(cityPos.x)
			local mapY = MapToZoneCoord(cityPos.y)
			cityTransform.localPosition = MapCoordToMapPosition(mapX, mapY)
			cityTransform.localScale = Vector3(0.6, 0.6, 0.6)
			local cityData = tableData_tWorldCity.data[v.cityId]
			cityTransform:Find("selected"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", cityData.ZoneMapIcon)
			cityTransform:Find("Label"):GetComponent("UILabel").text = TextMgr:GetText(cityData.Name)
			cityTransform:Find("Label/icon").gameObject:SetActive(v.occupied)
		end
	end

    GovernmentData.AddTurretRulingListener(DisposeTurretRulingPush)
    GovernmentData.AddGovRulingListener(DisposeGovRulingPush)
end

function Close()
    _ui = nil
    GovernmentData.RemoveTurretRulingListener(DisposeTurretRulingPush)
    GovernmentData.RemoveGovRulingListener(DisposeGovRulingPush)
    for i=1,6 do
        CountDown.Instance:Remove("FortInfo_ZoneMap"..i)
    end
end

function Show(mapX, mapY)
    mapX = mapX or oldMapX
    mapY = mapY or oldMapY
    oldMapX = mapX
    oldMapY = mapY
    Global.OpenUI(_M)
    SetLookAtCoord(mapX, mapY)
    UpdateMap()
end
