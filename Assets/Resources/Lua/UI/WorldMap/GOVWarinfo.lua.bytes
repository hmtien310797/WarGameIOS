module("GOVWarinfo", package.seeall)

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

local warInfoNames = {
    "Container/bg_frane/bg_mid/Scroll View/Grid/bg_warinfo",
    "Container/bg_frane/bg_mid/Scroll View/Grid/bg_warinfo (4)",
    "Container/bg_frane/bg_mid/Scroll View/Grid/bg_warinfo (1)",
    "Container/bg_frane/bg_mid/Scroll View/Grid/bg_warinfo (2)",
    "Container/bg_frane/bg_mid/Scroll View/Grid/bg_warinfo (3)",
    
}

function Hide()
    Global.CloseUI(_M)
end


local function GetContentText(logmsg , text)
    if logmsg == nil or logmsg.noticeParams == nil then
        return text
    end
	local text_param = {}
	local need_params = {}
	--配置的参数个数
	for w in string.gmatch(text , "{%d}") do
		need_params[#need_params + 1] = w
    end
	--实际的参数个数
	for _ , vv in ipairs(logmsg.noticeParams) do
		Notice_Tips.DecodeString(text_param , vv , function() end)
	end
	for i=#text_param , #need_params , 1 do
		table.insert(text_param , "xxx")
    end
	return GUIMgr:StringFomat(text, text_param)
end

local function UpdateWarInfoItem(CenterBuildWarLog_msg)
    if CenterBuildWarLog_msg == nil then
        return
    end
    
    local data = TableMgr:GetGovWarLogByid(CenterBuildWarLog_msg.logId)
    if data == nil then
        print("ERRORRRRRRRRRRRRRRRRRRRRRRRRRRR",CenterBuildWarLog_msg.logId)
        return
    end
    _ui.warInfos[CenterBuildWarLog_msg.subType + 1].go_pos = CenterBuildWarLog_msg.pos
    if CenterBuildWarLog_msg.logId == 10040 then
        _ui.warInfos[CenterBuildWarLog_msg.subType + 1].text.text = GetContentText(CenterBuildWarLog_msg,TextMgr:GetText(data.Content))
    else
        _ui.warInfos[CenterBuildWarLog_msg.subType + 1].text.text =  Global.SecondToStringFormat(CenterBuildWarLog_msg.time , "HH:mm:ss").." " .. GetContentText(CenterBuildWarLog_msg,TextMgr:GetText(data.Content))
    end
    
end

local function InitWarInfo(i)
    _ui.warInfos[i].text = _ui.warInfos[i].trf:Find("text"):GetComponent("UILabel")
    _ui.warInfos[i].go_btn = _ui.warInfos[i].trf:Find("button")
    _ui.warInfos[i].go_pos = nil
    SetClickCallback(_ui.warInfos[i].go_btn.gameObject,function()
        if _ui.warInfos[i].go_pos == nil then
            return
        end
        
        MainCityUI.ShowWorldMap(_ui.warInfos[i].go_pos.x, _ui.warInfos[i].go_pos.y, true)
        Hide() 
        ActivityAll.CloseAll();
    end)
end

function UpdateWarInfo()
    local log = GovernmentData.GetWarLogInfoMsg()
    for i=1,#log.warLogs do
        print(i,log.warLogs[i].logId)
        UpdateWarInfoItem(log.warLogs[i])
    end
end

LoadUI = function()
    for i=1,5 do
        InitWarInfo(i)
    end
    UpdateWarInfo()

    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end)      
end



function  Awake()
    _ui = {}
    _ui.mask = transform:Find("mask")
    _ui.close = transform:Find("Container/bg_frane/bg_top/btn_close")
    _ui.warInfos = {}
    for i=1,5 do
        _ui.warInfos[i] = {}
        _ui.warInfos[i].trf = transform:Find(warInfoNames[i])
    end
    LoadUI()
end

function Show()    
    GovernmentData.ReqWarLogInfo(function()
        Global.OpenUI(_M)
    end)
end

function Close()   
    _ui = nil
end
