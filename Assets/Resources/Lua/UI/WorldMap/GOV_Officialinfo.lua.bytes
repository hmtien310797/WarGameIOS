module("GOV_Officialinfo", package.seeall)

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

local EnableOperation
local Official_id
local Official_msg
local LoadUI = nil
local setfinishColseCallback
function Hide()
    Global.CloseUI(_M)
end

local function DisposeGovRulingPush()
    FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
    Hide()
end

local btnCallBack = {
    OKCB=function()
        Hide()
    end,
    RecallCB = function()
        if Official_msg == nil then
            return
        end
        GovernmentData.ReqDeposeOfficial(Official_msg.charId,
        function() 
            Hide() 
            if setfinishColseCallback ~= nil then
                setfinishColseCallback(0)
            end
        end)
    end,
    PrivilegeCB = function()
        
        if _ui == nil then
            return
        end      
        if Official_msg == nil then
            return
        end
        local isedit = false
        local selfCharid = MainData.GetCharId()
        local union = UnionInfoData.GetData()
        local gov_msg = GovernmentData.GetGovernmentData()
        if union.guildInfo.guildId == gov_msg.archonInfo.guildId  and 
        selfCharid ==  union.guildInfo.leaderCharId and
        Official_msg.charId ~= selfCharid then
            isedit = true
        end
        GOV_Authority.Show(isedit,Official_msg )
    end
}

LoadUI = function()
    _ui.title.text = EnableOperation and TextMgr:GetText("GOV_ui10") or TextMgr:GetText("Union_Radar_ui9")
    local officialData = TableMgr:GetGoveOfficialData()
    _ui.item.data = officialData[Official_id]
    if _ui.item.data ~= nil then
        GOV_Main.InitOfficialItem(_ui.item,_ui.buffPrefab)
        if Official_msg~= nil then
            _ui.item.player_name.text = "["..Official_msg.guildBanner.."] "..Official_msg .charName
        end

        if _ui.item.data.grade >= 100 or not EnableOperation then
            _ui.btn_main.gameObject:SetActive(true)
            _ui.btn_recall.gameObject:SetActive(false)
            _ui.btn_privilege.gameObject:SetActive(false)
            if EnableOperation then
                _ui.btn_main_label.text = TextMgr:GetText("GOV_ui45")
                SetClickCallback(_ui.btn_main.gameObject,btnCallBack.RecallCB)
            else
                _ui.btn_main_label.text = TextMgr:GetText("common_hint1")
                SetClickCallback(_ui.btn_main.gameObject,btnCallBack.OKCB)
            end
        else
            _ui.btn_main.gameObject:SetActive(false)
            _ui.btn_recall.gameObject:SetActive(true)
            _ui.btn_privilege.gameObject:SetActive(true)
            _ui.btn_recall_label.text = TextMgr:GetText("GOV_ui46")
            _ui.btn_privilege_label.text = TextMgr:GetText("union_anagement2")
            SetClickCallback(_ui.btn_recall.gameObject,btnCallBack.RecallCB)
            SetClickCallback(_ui.btn_privilege.gameObject,btnCallBack.PrivilegeCB)

        end
    end
end



function  Awake()
    _ui = {}
    _ui.buffPrefab = transform:Find("Container/buff (1)").gameObject
    _ui.item = {}
    _ui.item.obj = transform:Find("Container/bg_frane/bg_mid").gameObject
    _ui.btn_main = transform:Find("Container/bg_frane/bg_bottom/button")
    _ui.btn_main_label = transform:Find("Container/bg_frane/bg_bottom/button/text"):GetComponent("UILabel")
    _ui.btn_recall = transform:Find("Container/bg_frane/bg_bottom/button (1)")
    _ui.btn_recall_label = transform:Find("Container/bg_frane/bg_bottom/button (1)/text"):GetComponent("UILabel")
    _ui.btn_privilege = transform:Find("Container/bg_frane/bg_bottom/button (2)")
    _ui.btn_privilege_label = transform:Find("Container/bg_frane/bg_bottom/button (2)/text"):GetComponent("UILabel")
    _ui.title = transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
    _ui.btn_main.gameObject:SetActive(false)
    _ui.btn_recall.gameObject:SetActive(false)
    _ui.btn_privilege.gameObject:SetActive(false)
    SetClickCallback(transform:Find("mask").gameObject,function() Hide() end)
    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,function() Hide() end)
    SetClickCallback(_ui.btn_main.gameObject,nil)
    SetClickCallback(_ui.btn_recall.gameObject,nil)
    SetClickCallback(_ui.btn_privilege.gameObject,nil)
    GovernmentData.AddGovRulingListener(DisposeGovRulingPush)
    LoadUI()
end

function Show(enableOperation,official_id,official_msg,_setfinishColseCallback)    
    setfinishColseCallback = _setfinishColseCallback
    EnableOperation = enableOperation
    Official_id = official_id
    Official_msg = official_msg
    if EnableOperation ~= nil and Official_id ~= nil and Official_msg ~= nil then
        Global.OpenUI(_M)
    end
end

function Close()   
    --setfinishColseCallback = nil
    GovernmentData.RemoveGovRulingListener(DisposeGovRulingPush)
    _ui = nil
end