module("WorldMapZoneUI", package.seeall)
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
local math = math
local isEditor = UnityEngine.Application.isEditor
local Raycast = UnityEngine.Physics.Raycast

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

local MapPool = MapPool

local _ui

function Hide()
    Global.CloseUI(_M)
end

local function OnUICameraDrag(go, delta)
    if UICamera.isOverUI then
        return
    end
    local topMenu = GUIMgr:GetTopMenuOnRoot()
    if topMenu ~= this then
        return
    end
    if Global.GController:GetTouches().Count > 1 then
        return
    end

    local deltaX = delta.x
    local deltaY = delta.y
    local dragSpeed = 0.02
    _ui.battleCamera:Move(deltaX * dragSpeed, deltaY * dragSpeed)
end

local function LoadZoneObject(zone, zoneTransform)
    zone.transform = zoneTransform
    zone.gameObject = zoneTransform.gameObject
    zone.bgSprite = zoneTransform:Find("bg_list/background")
    zone.languageIcon = zoneTransform:Find("bg_list/background/icon_country"):GetComponent("UITexture")
    zone.zoneLabel = zoneTransform:Find("bg_list/background/text_zoneID"):GetComponent("UILabel")
    zone.unionLabel = zoneTransform:Find("bg_list/background/text_name"):GetComponent("UILabel")
    --zone.leaderLabel = zoneTransform:Find("bg_list/background/text_consul/text_name"):GetComponent("UILabel")
    --zone.protectLabel = zoneTransform:Find("bg_list/background/text_protect/text_name"):GetComponent("UILabel")
    --zone.recommendObject = zoneTransform:Find("bg_list/background/icon_new").gameObject
    --zone.recommendObject = zoneTransform:Find("background/icon_person").gameObject
    --zone.statusLabel = zoneTransform:Find("bg_list/background/text_state"):GetComponent("UILabel")
    zone.selfObject = zoneTransform:Find("bg_list/background/icon_person").gameObject
end

local function LoadZone(zone, countryMsg, zoneGameMsg, zoneMsg)
    zone.gameObject:SetActive(true)
    zone.selfObject:SetActive(false)
    --zone.zoneLabel.text = String.Format(TextMgr:GetText(Text.ui_zone14), TextMgr:GetText(countryMsg.name), zoneMsg.name)
    zone.zoneLabel.text = zoneMsg.name
    if zoneGameMsg.guildid == 0 then
        zone.languageIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", "999")
        zone.unionLabel.text = TextMgr:GetText(Text.ui_zone12)
        --zone.leaderLabel.text = TextMgr:GetText(Text.ui_zone12)
    else
        --zone.languageIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", zoneGameMsg.guildlang)
        zone.languageIcon.mainTexture = UIUtil.GetNationalFlagTexture(zoneGameMsg.guildlang)
        zone.unionLabel.text = string.format("[%s]%s", zoneGameMsg.guildbanner, zoneGameMsg.guildname)
        --zone.leaderLabel.text = zoneGameMsg.officer
    end
    if zoneGameMsg.time > 0 then
    else
        --zone.protectLabel.text = TextMgr:GetText(Text.ui_zone13)
    end
    --zone.recommendObject:SetActive(zoneMsg.isNew)
    --zone.statusLabel.gameObject:SetActive(false)

    SetClickCallback(zone.gameObject, function()
        --[[
        CloseAll()
        login.SetZoneInfo(countryMsg.name, zoneMsg.isNew, zoneMsg.status, zoneMsg.zoneId, zoneMsg.zoneName)
        --]]
        MessageBox.Show(TextMgr:GetText(Text.ui_earth1))
    end)
end

function LoadUI()
    _ui.mainland:Load(_ui.mainlandIndex - 1)
    local currentZoneId = ServerListData.GetCurrentZoneId()
    local groupListMsg = ServerListData.GetCountryData(_ui.mainlandIndex)
    local myZoneId = ServerListData.GetMyZoneIdAtCountry(groupListMsg)
    for i, v in ipairs(_ui.groupList) do
        local middleVisible = false
        for ii, vv in ipairs(v.zoneList) do
            local zoneMsg
            if groupListMsg ~= nil then
                local groupMsg = groupListMsg.data[i]
                if groupMsg ~= nil then
                    zoneMsg = groupMsg.data[ii]
                end
            end

            if zoneMsg ~= nil then
                local countryMsg, _, zoneGameMsg = ServerListData.GetCountryZoneData(zoneMsg.zone)
                LoadZone(vv, countryMsg, zoneGameMsg, zoneMsg)
                local cameraRay = Ray(-_ui.cameraTransform.forward, vv.transform.position)
                local _, cameraDistance = _ui.cameraPlane:Raycast(cameraRay)
                local position = vv.transform.position
                local cameraPosition = vv.transform.position - _ui.cameraTransform.forward * cameraDistance

                if zoneMsg.zone == myZoneId then
                    _ui.defaultCameraPosition = cameraPosition
                end
                middleVisible = true
            else
                vv.gameObject:SetActive(false)
            end
        end
        v.middleObject:SetActive(middleVisible)
    end
end

function Awake()
    MainCityUI.gameObject:SetActive(false)
    WorldMap.gameObject:SetActive(false)
    _ui = {}
    _ui.terrain = GameObject.Find("3DTerrain(Clone)")
    if _ui.terrain ~= nil then
        _ui.terrain:SetActive(false)
    end
    _ui.bgObject = transform:Find("Container").gameObject
    _ui.mainlandObject = ResourceLibrary:GetGlobeSceneInstance("Mainland")
    _ui.mainlandTransform = _ui.mainlandObject.transform
    _ui.mainland = _ui.mainlandTransform:GetComponent("Mainland")
    local cameraLeftTop = _ui.mainland.cameraLeftTop
    local cameraRightBottom = _ui.mainland.cameraRightBottom

    _ui.worldCamera = _ui.mainlandTransform:Find("Scene/Main Camera"):GetComponent("Camera")
    _ui.cameraTransform = _ui.mainlandTransform:Find("Scene/Main Camera")
    _ui.defaultCameraY = _ui.cameraTransform.localPosition.y
    _ui.groupListTransform = _ui.mainlandTransform:Find("UI/Container")

    _ui.closeButton = transform:Find("Container/btn_close")

    UIUtil.SetClickCallback(_ui.closeButton.gameObject, function()
        Hide()
        WarZoneUI.Show()
    end)
    UIUtil.AddDelegate(UICamera, "onDrag", OnUICameraDrag)

    local groupList = {}
    for i = 1, 16 do
        local group = {}
        local groupTransform = _ui.groupListTransform:Find(string.format("Grid (%d)", i))
        group.transform = groupTransform
        group.gameObject = groupTransform.gameObject

        local zoneList = {}
        for j = 1, 8 do
            local zone = {}
            local zoneTransform = groupTransform.transform:Find(string.format("MapZoneInfo (%d)", j))
            LoadZoneObject(zone, zoneTransform)
            zoneList[j] = zone
        end
        group.middleObject = groupTransform.transform:Find("MapZoneInfo (m)").gameObject
        group.zoneList = zoneList
        groupList[i] = group
    end
    _ui.groupList = groupList
    _ui.cameraPlane = Plane.New(Vector3.down, _ui.defaultCameraY)
end

function LateUpdate()
    local deltaTime = Time.deltaTime
    if _ui.battleCamera ~= nil then
        --镜头缩放速度
        local zoomSpeed = 0.1
        if Controller:IsPinch() then
            local pinchDelta = Controller:GetPinchDelta()
            _ui.battleCamera:Zoom(pinchDelta * zoomSpeed)
        end
    end
    _ui.battleCamera:Update()
end

function Close()
    UIUtil.RemoveDelegate(UICamera, "onDrag", OnUICameraDrag)
    GameObject.Destroy(_ui.mainlandObject)
    MainCityUI.gameObject:SetActive(true)
    WorldMap.gameObject:SetActive(true)
    if _ui.terrain ~= nil then
        _ui.terrain:SetActive(true)
    end
    _ui = nil
end

function Show(mainlandIndex)
    Global.OpenUI(_M)
    _ui.mainlandIndex = mainlandIndex
    LoadUI()
    if _ui.defaultCameraPosition ~= nil then
        _ui.cameraTransform.position = _ui.defaultCameraPosition
    end
    _ui.defaultCameraPosition = _ui.cameraTransform.position
    local minX = _ui.defaultCameraPosition.x
    local maxX = minX
    local minZ = _ui.defaultCameraPosition.z
    local maxZ = minZ

    for i, v in ipairs(_ui.groupList) do
        for ii, vv in ipairs(v.zoneList) do
            if vv.gameObject.activeSelf then
                local cameraRay = Ray(-_ui.cameraTransform.forward, vv.transform.position)
                local _, cameraDistance = _ui.cameraPlane:Raycast(cameraRay)
                local position = vv.transform.position
                local cameraPosition = vv.transform.position - _ui.cameraTransform.forward * cameraDistance

                minX = math.min(minX, cameraPosition.x)
                maxX = math.max(maxX, cameraPosition.x)
                minZ = math.min(minZ, cameraPosition.z)
                maxZ = math.max(maxZ, cameraPosition.z)
            end
        end
    end
    _ui.battleCamera = BattleCamera(_ui.worldCamera, minX, maxX, 38, 64, minZ, maxZ)
end
