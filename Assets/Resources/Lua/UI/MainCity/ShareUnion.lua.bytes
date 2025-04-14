module("ShareUnion", package.seeall)
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

local _ui, closeCallback

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    _ui = {}
    _ui.mask = transform:Find("mask").gameObject
    _ui.cancel = transform:Find("Container/bg_frane/button1").gameObject
    _ui.share = transform:Find("Container/bg_frane/button2").gameObject
    _ui.share2 = transform:Find("Container/bg_frane/button3").gameObject
    _ui.label = transform:Find("Container/bg_frane/Label"):GetComponent("UILabel")
end

function Start()
    SetClickCallback(_ui.mask, Hide)
    SetClickCallback(_ui.cancel, Hide)
    SetClickCallback(_ui.share, function()
        if UnityEngine.Application.isEditor then
            _ui.shared = true
        end
        if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_tw_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_tw_digiSky then
            UnityEngine.Application.OpenURL("https://www.facebook.com/WWar.game/")
        elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_kr_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_onestore then
            UnityEngine.Application.OpenURL("http://cafe.naver.com/wgww2")
        else
            GUIMgr:SendMessageToSocial(2, 1, "", "", "http://122.152.199.213/gameupdate/Notice_Test/pic/2017082215test.png", "https://www.facebook.com/War-in-Pocket-337868993310806/")
        end
    end)
    SetClickCallback(_ui.share2, function()
        if UnityEngine.Application.isEditor then
            _ui.shared = true
        end
        if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_tw_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_tw_digiSky then
            UnityEngine.Application.OpenURL("https://www.facebook.com/WWar.game/")
        elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_kr_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_onestore then
            UnityEngine.Application.OpenURL("http://cafe.naver.com/wgww2")
        else
            GUIMgr:SendMessageToSocial(2, 1, "", "", "http://122.152.199.213/gameupdate/Notice_Test/pic/2017082215test.png", "https://www.facebook.com/War-in-Pocket-337868993310806/")
        end
    end)
    if closeCallback == nil then
        _ui.label.text = TextMgr:GetText("UnionShare_1")
    else
        _ui.label.text = TextMgr:GetText("gameShare_1")
    end
end

function Show(callback)
    if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_ios or 
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_adr or 
        Global.IsIosMuzhi() or 
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or 
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame or 
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_mango or
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch or
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_quick or
        GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_qihu then
        return
    end
    closeCallback = callback
	Global.OpenUI(_M)
end

function Close()
    if _ui.shared then
        if closeCallback ~= nil then
            closeCallback()
            closeCallback = nil
        end
    end
    if UnionInfoData.IsUnionLeader() then
        Event.Check(47)
    end
    _ui = nil
end

function SocialCallback()
    if _ui ~= nil then
        _ui.shared = true
    end
end
