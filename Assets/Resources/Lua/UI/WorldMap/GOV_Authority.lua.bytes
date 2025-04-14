module("GOV_Authority", package.seeall)

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
local Official_msg
local LoadUI = nil

function Hide()
    Global.CloseUI(_M)
end

local function DisposeGovRulingPush()
    FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
    Hide()
end

LoadUI = function()
    _ui.Privileges ={}
    for i=1, #GovernmentData.GovernmentPrivilegeList do 
        local item = {}
        item.obj = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.authortyPrefab)
        item.text = item.obj.transform:Find("text"):GetComponent("UILabel")
        item.btn = item.obj.transform:Find("Sprite")
        item.btn_Box_Sprite = item.obj.transform:Find("Sprite"):GetComponent("UISprite")
        item.btn_Sprite = item.obj.transform:Find("Sprite/Sprite"):GetComponent("UISprite")

        
        item.text.text = TextMgr:GetText(GovernmentData.GovernmentPrivilegeTxt[GovernmentData.GovernmentPrivilegeList[i]])
        print("YYYY",GovernmentData.GovernmentPrivilegeList[i],Official_msg.privilege,GovernmentData.IsPrivilegeValid(GovernmentData.GovernmentPrivilegeList[i],Official_msg.privilege))
        _ui.Privileges[i] = GovernmentData.IsPrivilegeValid(GovernmentData.GovernmentPrivilegeList[i],Official_msg.privilege)
        if _ui.Privileges[i] then
            item.btn_Sprite.gameObject:SetActive(true)
        else
            item.btn_Sprite.gameObject:SetActive(false)
        end
        if EnableOperation then
            item.btn_Box_Sprite.enabled = true
            SetClickCallback(item.btn.gameObject,function()
                _ui.Privileges[i] = not _ui.Privileges[i]
                item.btn_Sprite.gameObject:SetActive(_ui.Privileges[i])
            end)                
        else
            item.btn_Box_Sprite.enabled = false
        end
    end

    _ui.listGrid.repositionNow = true
    if EnableOperation then
        _ui.btn_ok.gameObject:SetActive(true)
        SetClickCallback(_ui.btn_ok.gameObject,function()
            GovernmentData.ReqEditOfficialPrivilege(Official_msg.charId,_ui.Privileges,function(privilege)
                Official_msg.privilege = privilege
                Hide()
            end)
        end)  
    else
        _ui.btn_ok.gameObject:SetActive(false)
    end

    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end)      
end

function  Awake()
    _ui = {}
    _ui.authortyPrefab = transform:Find("Container/listitem_authority1").gameObject
    _ui.listSV = transform:Find("bg2/Scroll View")
    _ui.listGrid = transform:Find("bg2/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.mask = transform:Find("mask")
    _ui.btn_ok = transform:Find("btn ok")
    _ui.close = transform:Find("Container/close btn")
    GovernmentData.AddGovRulingListener(DisposeGovRulingPush)
    LoadUI()
end

function Show(enableOperation,official_msg)    
    EnableOperation = enableOperation
    Official_msg = official_msg
    if EnableOperation ~= nil and Official_msg ~= nil then
        Global.OpenUI(_M)
    end    
end

function Close()  
    GovernmentData.RemoveGovRulingListener(DisposeGovRulingPush) 
    _ui = nil
end