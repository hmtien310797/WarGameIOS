module("Mobahistory", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local NGUITools = NGUITools
local AudioMgr = Global.GAudioMgr
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _ui

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function CloseSelf()
    Global.CloseUI(_M)
end

function Hide()
	Global.CloseUI(_M)
end

function Close()
    _ui = nil
end

function Awake()
    _ui = {}
    _ui.mask = transform:Find("mask").gameObject
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject

    _ui.grid = transform:Find("Container/bg_frane/bg/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item = transform:Find("Container/bg_frane/bg/Scroll View/Grid/list_myhistory")
end

function Start()
    SetClickCallback(_ui.mask, CloseSelf)
    SetClickCallback(_ui.btn_close, CloseSelf)
    _ui.item.gameObject:SetActive(false)
    _ui.grid.hideInactive = true
end

local function UpdateUI(msg)
    table.sort(msg.records.records, function(a,b)
        return a.time > b.time
    end)
    for i, v in ipairs(msg.records.records) do
        local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
        item.gameObject:SetActive(true)
        item:Find("Label"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("Armrace_29"), v.rank)
        local icon = item:Find("Label/icon"):GetComponent("UISprite")
        icon.gameObject:SetActive(v.rank <= 3)
        icon.spriteName = "icon_" .. v.rank
        item:Find("Label (1)/win").gameObject:SetActive(v.result == 1)
        item:Find("Label (1)/lose").gameObject:SetActive(v.result == -1)
        item:Find("Label (1)/draw").gameObject:SetActive(v.result == 0)
        item:Find("Label (2)"):GetComponent("UILabel").text = Global.SecondToStringFormat(v.time , "yyyy-MM-dd HH:mm:ss")
        item:Find("Label (3)"):GetComponent("UILabel").text = v.totalscore
        item:Find("Label (4)"):GetComponent("UILabel").text = v.totalkill
        item:Find("Label (5)"):GetComponent("UILabel").text = v.totaldead
    end
    _ui.grid:Reposition()
end

function Show(charid)
    local req = MobaMsg_pb.MsgMobaGetRecordRequest()
    req.charid = charid
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGetRecordRequest, req, MobaMsg_pb.MsgMobaGetRecordResponse, function(msg)
        Global.DumpMessage(msg, "D:/ddddd.lua")
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateUI(msg)
        else
            Global.ShowError(msg.code)
        end
    end, true)
    Global.OpenUI(_M)
end