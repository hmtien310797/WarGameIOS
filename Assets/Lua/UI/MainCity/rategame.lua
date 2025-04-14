module("rategame", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("container/bg_frane/btn_close").gameObject
    _ui.btn_share = transform:Find("container/go").gameObject
    _ui.gold_num = transform:Find("container/bg_frane/gold/Label"):GetComponent("UILabel")
end

function Start()
    SetClickCallback(_ui.btn_close, Hide)
    SetClickCallback(_ui.btn_share, function()
        UnityEngine.PlayerPrefs.SetInt("rategame" .. MainData.GetCharId(), 2)
        UnityEngine.PlayerPrefs.Save()
        local platformType = GUIMgr:GetPlatformType()
        if platformType == LoginMsg_pb.AccType_adr_efun then
            UnityEngine.Application.OpenURL("https://play.google.com/store/apps/details?id=com.weywell.wgame.efunkoudai.se")
        elseif platformType == LoginMsg_pb.AccType_ios_efun or platformType == LoginMsg_pb.AccType_ios_india then
            UnityEngine.Application.OpenURL("https://itunes.apple.com/app/war-in-pocket/id1358222570")
        end
        local request = ActivityMsg_pb.MsgEvaluateRequest()
        Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgEvaluateRequest, request, ActivityMsg_pb.MsgEvaluateResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.ShowError(msg.code)
            end
        end, true)
        Hide()
    end)

    UnityEngine.PlayerPrefs.SetInt("rategame" .. MainData.GetCharId(), 1)
    UnityEngine.PlayerPrefs.Save()
end

function Show()
    local platformType = GUIMgr:GetPlatformType()
    if not Global.IsOutSea() or
        platformType == LoginMsg_pb.AccType_adr_opgame or
        platformType == LoginMsg_pb.AccType_adr_official or
        platformType == LoginMsg_pb.AccType_ios_official or
        platformType == LoginMsg_pb.AccType_adr_official_branch or
        platformType == LoginMsg_pb.AccType_adr_quick or 
        platformType == LoginMsg_pb.AccType_adr_qihu then
        return
    end
    coroutine.start(function()
        local topMenu = GUIMgr:GetTopMenuOnRoot()
        local isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
		while topMenu == nil or topMenu.name ~= "MainCityUI" or isInGuide do
			coroutine.wait(0.5)
            topMenu = GUIMgr:GetTopMenuOnRoot()
            isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
			if topMenu == nil or topMenu.name == "rategame" then
				return
			end
		end
        Global.OpenUI(_M)
    end)
end

function Close()
    MainCityUI.UpdateRategame()
    _ui = nil
end