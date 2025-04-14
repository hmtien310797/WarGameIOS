module("NewActivityBanner", package.seeall)
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

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function SecondUpdate()
    local serverTime = GameTime.GetSecTime()
    local faceDrawListMsg = FaceDrawData.GetData().fdlist
    local faceDrawMsg = faceDrawListMsg[_ui.selectedIndex]
    local timeText
    local cooldownText
    if serverTime >= faceDrawMsg.noticetime and serverTime < faceDrawMsg.begintime then
        timeText = TextMgr:GetText(Text.ui_activitybanner_start)
        cooldownText = Global.GetLeftCooldownTextLong(faceDrawMsg.begintime)
    elseif serverTime >= faceDrawMsg.begintime and serverTime < faceDrawMsg.endtime then
        if faceDrawMsg.endtime - serverTime <= 24*3600*7 then
            timeText = TextMgr:GetText(Text.ui_activitybanner_end)
            cooldownText = Global.GetLeftCooldownTextLong(faceDrawMsg.endtime)
        end
    end
    _ui.timeLabel.gameObject:SetActive(timeText ~= nil)
    if timeText ~= nil then
        _ui.timeLabel.text = timeText
        _ui.cooldownLabel.text = cooldownText
    end
end

function LoadUI()
    local faceDrawListMsg = FaceDrawData.GetData().fdlist
    _ui.leftButton.gameObject:SetActive(_ui.selectedIndex > 1)
    _ui.rightButton.gameObject:SetActive(_ui.selectedIndex < #faceDrawListMsg)
    local faceDrawMsg = faceDrawListMsg[_ui.selectedIndex]
    FaceDrawData.GetTexture(faceDrawMsg.bannerpic, function(texture)
        if _ui == nil then
            return
        end
        _ui.activityTexture.mainTexture = texture
    end)
    _ui.nameLabel.text = faceDrawMsg.text1
    _ui.descriptionLabel.text = faceDrawMsg.text2
    SetClickCallback(_ui.descriptionObject, function(go)
        print("jump str:", faceDrawMsg.pageforward)
        Hide()
        
        local jumpFunc = Global.GetTableFunction(faceDrawMsg.pageforward)
        if jumpFunc ~= nil then
            jumpFunc()
        end
    end)

    for i, v in ipairs(faceDrawListMsg) do
        local pointerTransform
        if i > _ui.pointerGrid.transform.childCount then
            pointerTransform = NGUITools.AddChild(_ui.pointerGrid.gameObject, _ui.pointerPrefab).transform
        else
            pointerTransform = _ui.pointerGrid.transform:GetChild(i - 1)
        end
        pointerTransform:GetChild(0).gameObject:SetActive(i == _ui.selectedIndex)
    end
    SecondUpdate()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)

    _ui.activityTexture = transform:Find("Container/bg_frane/Texture"):GetComponent("UITexture")
    _ui.nameLabel = transform:Find("Container/bg_frane/bg_desc/activity_name"):GetComponent("UILabel")
    _ui.descriptionObject = transform:Find("Container/bg_frane/bg_desc").gameObject
    _ui.descriptionLabel = transform:Find("Container/bg_frane/bg_desc/text_desc"):GetComponent("UILabel")
    _ui.leftButton = transform:Find("Container/bg_frane/arrow_left"):GetComponent("UIButton")
    _ui.rightButton = transform:Find("Container/bg_frane/arrow_right"):GetComponent("UIButton")
    _ui.timeLabel = transform:Find("Container/bg_frane/bg_desc/title_time"):GetComponent("UILabel")
    _ui.cooldownLabel = transform:Find("Container/bg_frane/bg_desc/title_time/text_time"):GetComponent("UILabel")
    SetClickCallback(_ui.leftButton.gameObject, function(go)
        _ui.selectedIndex = _ui.selectedIndex - 1
        LoadUI()
    end)

    SetClickCallback(_ui.rightButton.gameObject, function(go)
        _ui.selectedIndex = _ui.selectedIndex + 1
        LoadUI()
    end)

    _ui.pointerGrid = transform:Find("Container/bg_frane/pointbar/Grid"):GetComponent("UIGrid")
    _ui.pointerPrefab = _ui.pointerGrid.transform:GetChild(0).gameObject
    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui.timer:Stop()
    if _ui.closecallback ~= nil then
        _ui.closecallback()
    end
    _ui = nil
end

function Show(closecallback)
    if FaceDrawData.GetData() == nil or #FaceDrawData.GetData().fdlist == 0 then
        if closecallback ~= nil then
            closecallback()
        end
        return
    end
    Global.OpenUI(_M)
    _ui.closecallback = closecallback
    _ui.selectedIndex = 1
    LoadUI()
end
