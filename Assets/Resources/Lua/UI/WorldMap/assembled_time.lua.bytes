module("assembled_time", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local AssembledTimeUI = nil
local TimeLevel
local CurSelectLevel
local CloseCallBack

local _mobaMode
local _need_help =false
local _help = nil
local function AddCheckLevel(leveltime,trf)
    local level = {}
    level.time = leveltime
    level.Timetext = trf:Find("text"):GetComponent("UILabel")
    local textid = "ui_minutes"
    local showTime = leveltime
    if leveltime > 60 then
        textid = "ui_hours"
        showTime = math.floor((leveltime / 60)*10)/10
    end
    --print(showTime,textid,TextMgr:GetText(textid))
    if _mobaMode then
        level.Timetext.text = leveltime..TextMgr:GetText("ui_second")
    else
        level.Timetext.text = showTime..TextMgr:GetText(textid)
    end
    --level.Timetext.text = showTime..TextMgr:GetText(textid)
    level.btnobj = trf:Find("Sprite").gameObject
    level.allow = trf:Find("Sprite/Sprite").gameObject
    level.allow:SetActive(false)
    SetClickCallback(level.btnobj,function()
        if CurSelectLevel ~= nil and CurSelectLevel ~= level then
            CurSelectLevel.allow:SetActive(false)
        end
        CurSelectLevel = level
        level.allow:SetActive(true)
    end)
    return level
end

function OnUICameraClick(go)
    _help.des_root.gameObject:SetActive(false)
end

function OnUICameraDragStart(go, delta)
    _help.des_root.gameObject:SetActive(false)
end


local function LoadUI()
	--title content
    transform:Find("bg_mid/text"):GetComponent("UILabel").text = _mobaMode and TextMgr:GetText("ui_moba_129") or TextMgr:GetText("union_assembled_15")
    _help = {}
    _help.btn = transform:Find("bg_mid/info")
    _help.des_root =transform:Find("bg_mid/assemblebg")
    if _need_help then
        _help.btn.gameObject:SetActive(true);
        _help.des_root.gameObject:SetActive(false)
        SetClickCallback(_help.btn.gameObject,function()
            _help.des_root.gameObject:SetActive(true)
        end)     
    else
        _help.btn.gameObject:SetActive(false);
        _help.des_root.gameObject:SetActive(false)
    end
    

    local leveldata = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.AssembledTimeLevel).value
	if _mobaMode then
		leveldata = TableMgr:GetMobaUnitInfoByID(122).Value
	end
    local t = string.split(leveldata,';')
    TimeLevel = {}
	for i = 1,#(t) do
	    TimeLevel[i] = tonumber(t[i])
    end
    AssembledTimeUI = {}
    AssembledTimeUI.level = {}
    for i =1,5,1 do
        AssembledTimeUI.level[i] =AddCheckLevel( TimeLevel[i],transform:Find("bg_mid/Scroll View/Grid/listitem_authority"..i))
    end
    CurSelectLevel = AssembledTimeUI.level[1]
    CurSelectLevel.allow:SetActive(true)

    SetClickCallback(transform:Find("bg_top/close btn").gameObject,function()
        if CloseCallBack ~= nil then
            CloseCallBack(0)
        end
        Hide()
    end)
    SetClickCallback(transform:Find("mask").gameObject,function()
        if CloseCallBack ~= nil then
            CloseCallBack(0)
        end
        Hide()
    end)
    SetClickCallback(transform:Find("btn ok").gameObject,function()
        if CloseCallBack ~= nil then
            local t = 0
            if CurSelectLevel ~= nil then
                t = CurSelectLevel.time
            end
            CloseCallBack(t)
        end
        Hide()
    end)
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()
    LoadUI()
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)	
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart) 
	_mobaMode = nil
    CurSelectLevel= nil
    AssembledTimeUI = nil
    CloseCallBack = nil
    _need_help =false
    _help = nil
end



function Show(callback , mobaMode,need_help)
	_mobaMode = mobaMode
    CloseCallBack = callback
    _need_help = need_help~=nil and true or false
    Global.OpenUI(_M)    
end





