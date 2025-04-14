module("WarZoneUI", package.seeall)
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

function ResetMainlandRotation()
    for i, v in ipairs(_ui.mainlandList) do
        v.transform.rotation = Quaternion.identity
        local alpha = (_ui.globePositionZ - v.transform.position.z) / _ui.globeRadius
        v.nameText.color = Color(1, 1, 1, alpha)
    end
end

local function MapBgDragCallback(go, delta)
    local touchPos = UICamera.currentTouch.pos
    local dir = _ui.globeTransform.position - _ui.worldCamera.transform.position

    local z = _ui.globeTransform.position.z
    local worldPos = _ui.worldCamera:ScreenToWorldPoint(Vector3(touchPos.x, touchPos.y, dir.z))
    worldPos.z = z + _ui.globeRadius
    local lastWorldPos = _ui.worldCamera:ScreenToWorldPoint(Vector3(touchPos.x + delta.x, touchPos.y + delta.y, dir.z))
    lastWorldPos.z = z + _ui.globeRadius
    --UnityEngine.Debug.DrawLine(_ui.globeTransform.position, worldPos)
    --UnityEngine.Debug.DrawLine(_ui.globeTransform.position, lastWorldPos)
    local fromDirection = (lastWorldPos - _ui.globeTransform.position)
    local toDirection = (worldPos - _ui.globeTransform.position)
    _ui.globeTransform.rotation = Quaternion.FromToRotation(fromDirection, toDirection) * _ui.globeTransform.rotation
    ResetMainlandRotation()
end

local function MapBgPressCallback(go)
    local touchPos = UICamera.currentTouch.pos
end

local function MapBgClickCallback(go)
    local touchPos = UICamera.currentTouch.pos
    local groundMask = LayerMask.GetMask("Land")
    local ray = _ui.worldCamera:ScreenPointToRay(touchPos)
    local distance = _ui.worldCamera.farClipPlane - _ui.worldCamera.nearClipPlane
    local ret, hit = Raycast(ray, nil, distance, groundMask)
    if ret then
        local textureCoord = hit.textureCoord
        local color = _ui.maskTexture:GetPixelBilinear(textureCoord.x, textureCoord.y)
        print("pick color:", tostring(color * 255))

        local redIndex = math.floor(color.r * 25.5 + 0.5)
        local greenIndex = math.floor(color.g * 25.5 + 0.5)
        if redIndex == greenIndex then
            local mainlandIndex = redIndex
            print("mainlandIndex:", mainlandIndex)
            if mainlandIndex ~= 0 and mainlandIndex ~= 25 then
                if ServerListData.GetCountryData(mainlandIndex) ~= nil then
                    Hide()
                    WorldMapZoneUI.Show(mainlandIndex)
                end
            end
        end
    end
end

local function SetLookAtCoord(mapX, mapY)
    local x = mapX - math.floor(mapRow / 2) + 1
    local y = mapY

    SetOffset((0.5 * (y - x) + 0.25) * tileWidth, (y + x) * tileHeight * 0.5)
end

function Awake()
    MainCityUI.gameObject:SetActive(false)
    WorldMap.gameObject:SetActive(false)
    _ui = {}
    _ui.globeScene = ResourceLibrary:GetGlobeSceneInstance("GlobeScene")
    _ui.globeObject = _ui.globeScene.transform:Find("globe").gameObject
    _ui.globeTransform = _ui.globeObject.transform
    _ui.globePosition = _ui.globeTransform.position
    _ui.globePositionZ = _ui.globePosition.z
    local posListTransform = _ui.globeTransform:Find("mainland_pos_list")
    _ui.mainlandList = {}
    for i = 1, posListTransform.childCount do
        local mainlandTransform = posListTransform:GetChild(i - 1):Find("mainland")
        local mainland = {}
        mainland.transform = mainlandTransform
        mainland.nameText = mainlandTransform:Find("name"):GetComponent("TextMesh")
        _ui.mainlandList[i] = mainland
        local countryMsg = ServerListData.GetCountryData(i)
        if countryMsg ~= nil then
            mainlandTransform.gameObject:SetActive(true)
            mainland.nameText.text = TextMgr:GetText(countryMsg.name)
        else
            mainlandTransform.gameObject:SetActive(false)
        end
    end
    local sphereCollider = _ui.globeObject:AddComponent(typeof(UnityEngine.SphereCollider))
    _ui.globeRadius = sphereCollider.radius
    sphereCollider.enabled = false
    _ui.worldCamera = _ui.globeScene.transform:Find("Main Camera"):GetComponent("Camera")
    _ui.maskTexture = _ui.globeTransform:GetComponent("Renderer").sharedMaterial:GetTexture("_MaskTex")
    _ui.maskTextureWidth = _ui.maskTexture.width
    _ui.maskTextureHeight = _ui.maskTexture.height
    --_ui.wordMaterial = _ui.globeTransform:Find("word"):GetComponent("MeshRenderer").sharedMaterial
    --local wordTexture = ResourceLibrary:GetTexture("GlobeScene/", "word_" .. tostring(TextMgr:GetCurrentLanguage()))
    --_ui.wordMaterial:SetTexture("_MainTex", wordTexture)
    _ui.globePixels = _ui.maskTexture:GetPixels32()

    _ui.closeButton = transform:Find("Container/btn_close")
    uiCamera = GUIMgr.UIRoot.transform:Find("Camera"):GetComponent("Camera")
    ResetMainlandRotation()

    UIUtil.SetClickCallback(_ui.closeButton.gameObject, function()
        Hide()
        WarZoneMap.Show()
    end)
    UIUtil.SetDragCallback(gameObject, MapBgDragCallback)
    UIUtil.SetPressCallback(gameObject, MapBgPressCallback)
    UIUtil.SetClickCallback(gameObject, MapBgClickCallback)
end

function Close()
    GameObject.Destroy(_ui.globeScene)
    MainCityUI.gameObject:SetActive(true)
    WorldMap.gameObject:SetActive(true)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end
