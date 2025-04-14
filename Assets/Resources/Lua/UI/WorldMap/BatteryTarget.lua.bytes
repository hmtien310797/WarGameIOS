module("BatteryTarget", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
local subType
local reset
local enableOper = false
local TurretStrategyBtn = {
    "Container/bg_frane/bg_bottom/bg/text",
    "Container/bg_frane/bg_bottom/bg/text (1)",
    "Container/bg_frane/bg_bottom/bg/text (2)",
}

TurretStrategyState = {
    "GOV_ui31",--	关闭炮台
    "GOV_ui33",--	正常状态
    "GOV_ui32",--	一级警戒
}

function Hide()
    Global.CloseUI(_M)
end

local function DisposeTurretRulingPush()
    if GovernmentData.CheckTurretInRuling(subType) then
        FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
        Hide()
    end
end

function OnUICameraClick(go)
    if _ui == nil or _ui.tipObject == nil then
        return
    end
    UICamera.Notify(_ui.ts.gameObject, "OnClick", nil)
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    if _ui == nil or _ui.tipObject == nil then
        return
    end    
    UICamera.Notify(_ui.ts.gameObject, "OnClick", nil)
end

LoadUI = function()
    local turret_msg = GovernmentData.GetTurretData(subType)
    
	local union = UnionInfoData.GetData()
    local self_guildid = union.guildInfo.guildId
    
    if turret_msg.rulingInfo ~= nil and turret_msg.rulingInfo.guildId ~= nil and turret_msg.rulingInfo.guildId ~= 0 then
        --炮塔有执政盟
        if turret_msg.archonInfo ~= nil and turret_msg.archonInfo.guildId ~= 0 then
            --政府有执政盟
            if turret_msg.archonInfo.guildId == turret_msg.rulingInfo.guildId then
                --政府跟炮塔是一个盟
                if self_guildid ~= 0 and turret_msg.rulingInfo.guildId == self_guildid then
                    print(MapData_pb.GovernmentPrivilege_ManageTurretStrategy,MainData.GetGOVPrivilege)
                    enableOper = GovernmentData.IsPrivilegeValid(MapData_pb.GovernmentPrivilege_ManageTurretStrategy,MainData.GetGOVPrivilege())
                else
                    enableOper = false
                end

            else
                 --是不是盟主
                if MainData.GetCharId() == turret_msg.rulingInfo.charId then
                    enableOper = true
                end
            end
        else
            --是不是盟主
            if MainData.GetCharId() == turret_msg.rulingInfo.charId then
                enableOper = true
            end
        end
    end
    if enableOper then
        _ui.tsCollider.enabled = true
        _ui.addCollider.enabled = true
        --_ui.ts_play.enabled = true
        _ui.addBtn.normalSprite = "btn_1"
        _ui.tsBtn.normalSprite = "btn_5"
    else
        --_ui.ts_play.enabled = false
        _ui.tsCollider.enabled = false
        _ui.addCollider.enabled = false   
        _ui.addBtn.normalSprite = "btn_4" 
        _ui.tsBtn.normalSprite = "btn_4"             
    end

    _ui.ts_state.text = TextMgr:GetText(TurretStrategyState[turret_msg.strategy]) 

    SetClickCallback(_ui.ts.gameObject,function(go)
        _ui.tipObject = go
    end)  
    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end) 
    SetClickCallback(_ui.add.gameObject,function()
        UICamera.Notify(_ui.ts.gameObject, "OnClick", nil)
        BatteryTarget_add.Show(subType)
    end)   
    for i =1,3 do
        SetClickCallback(_ui.ts_btn[i].gameObject,function()
            GovernmentData.ReqTurretEditStrategy(subType,i,function(success)
                if success then
                    local turret_msg = GovernmentData.GetTurretData(subType)
                    _ui.ts_state.text = TextMgr:GetText(TurretStrategyState[turret_msg.strategy]) 
                else
                    _ui.ts_btn[i].value = false
                    _ui.ts_btn[turret_msg.strategy].value = true
                end
            end)
        end)    
    end

            
end

function LoadSearchPage()
    local unionList = _ui.unionList
    local ts_msg = GovernmentData.GetTurretSanctionData(subType)
    local k = 1
    if ts_msg ~= nil then
        for i, v in pairs(ts_msg) do
            print(i,v)
            if v ~= nil then
                local unionMsg = v
                local union = unionList[k]
                union.gameObject:SetActive(true)
                local hasApplied = SelfApplyData.HasApplied(v.guildId)
                UnionList.LoadUnion(union, unionMsg, hasApplied)
                if enableOper then
                    union.joinButton.gameObject:SetActive(false)
                    union.applyButton.gameObject:SetActive(true)
                    union.cancelButton.gameObject:SetActive(false)
                    SetClickCallback(union.applyButton.gameObject, function()
                        GovernmentData.ReqTurretSanctionGuild(subType,unionMsg,2)
                    end)
                    SetClickCallback(union.cancelButton.gameObject, nil)
                    SetClickCallback(union.joinButton.gameObject, nil)
                else
                    union.joinButton.gameObject:SetActive(false)
                    union.applyButton.gameObject:SetActive(false)
                    union.cancelButton.gameObject:SetActive(false)
                    SetClickCallback(union.applyButton.gameObject, nil)
                    SetClickCallback(union.cancelButton.gameObject, nil)
                    SetClickCallback(union.joinButton.gameObject, nil)
                end
                k = k+1
            end
        end
    end

    for i = k, _ui.pageSize do
        unionList[i].gameObject:SetActive(false)
    end
    if k==1 then
        _ui.noitem.gameObject:SetActive(true)
    else
        _ui.noitem.gameObject:SetActive(false)
    end
    _ui.listGrid:Reposition()
    if reset then
        _ui.scrollView:ResetPosition()
        reset = false
    end
end

function  Awake()
    _ui = {}
    _ui.mask = transform:Find("Container")
    _ui.close = transform:Find("Container/bg_frane/bg_top/btn_close")
    _ui.add = transform:Find("Container/bg_frane/bg_bottom/button (1)")
    _ui.noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
    _ui.addCollider = _ui.add:GetComponent("BoxCollider")
    _ui.addBtn = _ui.add:GetComponent("UIButton")
    _ui.ts = transform:Find("Container/bg_frane/bg_bottom/button")
    _ui.ts_play = _ui.ts:GetComponent("UIPlayTween")
    _ui.tsCollider = _ui.ts:GetComponent("BoxCollider")
    _ui.tsBtn = _ui.ts:GetComponent("UIButton")
    _ui.ts_btn = {}
    _ui.ts_btn_text = {}
    for i =1,3 do
        _ui.ts_btn[i] = transform:Find(TurretStrategyBtn[i]):GetComponent("UIToggle")
        _ui.ts_btn_text[i] = _ui.ts_btn[i].gameObject:GetComponent("UILabel")
        _ui.ts_btn_text[i].text = TextMgr:GetText(TurretStrategyState[i]) 
        _ui.ts_btn[i].value = false
    end
    _ui.ts_state = transform:Find("Container/bg_frane/bg_bottom/button/text"):GetComponent("UILabel")
    --_ui.ts_state_sprite = transform:Find("Container/bg_frane/bg_bottom/button/text/Sprite"):GetComponent("UISprite")
    _ui.scrollView = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
    local listGridTransform = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid")
    _ui.listGrid = listGridTransform:GetComponent("UIGrid")
    _ui.unionList = {}
    _ui.pageSize = listGridTransform.childCount
    _ui.clipHeight = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIPanel").baseClipRegion.w
    for i = 1, _ui.pageSize do
        local union = {}
        local unionTransform = listGridTransform:GetChild(i - 1)
        UnionList.LoadUnionObject(union, unionTransform)
        _ui.unionList[i] = union
        _ui.unionList[i].gameObject:SetActive(false)
    end    
    GovernmentData.AddTurretSanctionListener(LoadSearchPage)
    GovernmentData.ReqTurretSanctionList(subType)    
    GovernmentData.AddTurretRulingListener(DisposeTurretRulingPush)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)

    LoadUI()
end

function Show(_subType)    
    subType = _subType
    reset = true
    Global.OpenUI(_M)
end

function Close()   
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    GovernmentData.RemoveTurretRulingListener(DisposeTurretRulingPush)
    GovernmentData.RemoveTurretSanctionListener(LoadSearchPage)
    enableOper = false
    _ui = nil
end