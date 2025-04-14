module("PVP_Rewards_Skip", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local String = System.String
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local GetParameter = UIUtil.GetParameter
local SetParameter = UIUtil.SetParameter
local ResourceLibrary = Global.GResourceLibrary
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
local playbackInfo
local exit_callback

function GetWinLose()
	local winlose = 1
	print("wwwwwwwwwwwwwwwwwwww",playbackInfo.result.winteam)
	if playbackInfo.result.winteam == 1 then
	else
		winlose = 0 
	end
	return winlose
end

function LoadUI()
	local WinLose = GetWinLose()
    _ui.PVP_Rewards = _ui.transform:Find("PVP_Rewards").gameObject
	_ui.PVP_Defend = _ui.transform:Find("PVP_Defend").gameObject
	_ui.PVP_Defend:SetActive(false)
	_ui.win = _ui.transform:Find("PVP_Rewards/bg_win").gameObject
	_ui.lose = _ui.transform:Find("PVP_Rewards/bg_lose").gameObject
	_ui.strong = _ui.transform:Find("PVP_Rewards/bg_lose/btn_strong").gameObject
	SetClickCallback(_ui.strong, function()
		Hide()
		GetStrong.Show()
	end)
	if WinLose == 1 then 
		_ui.btn_playback = _ui.transform:Find("PVP_Rewards/bg_win/btn_playback").gameObject
		_ui.win:SetActive(true)
		_ui.lose:SetActive(false)
		_ui.strong:SetActive(false)
	else
		_ui.btn_playback = _ui.transform:Find("PVP_Rewards/bg_lose/btn_playback").gameObject
		_ui.win:SetActive(false)
		_ui.lose:SetActive(true)
		_ui.strong:SetActive(true)
	end
	_ui.btn_playback:SetActive(true)
	SetClickCallback(_ui.btn_playback, function(go) 
		Global.CheckBattleReportEx(playbackInfo.msg ,playbackInfo.mail_report_type,playbackInfo.reportBackFunction)
		Hide()
	end)	
end

function Awake()
    _ui.mask = transform:Find("mask").gameObject
    _ui.transform = transform
    SetClickCallback(_ui.mask, function(go) Hide() end)
    LoadUI()
end

function Show(msg,mail_report_type,result,reportBackFunction,_exit_callback)    
	_ui = {}
	playbackInfo={}
	playbackInfo.msg = msg;
	playbackInfo.mail_report_type = mail_report_type;
	playbackInfo.result =result
	playbackInfo.reportBackFunction = reportBackFunction
	exit_callback = _exit_callback
    Global.OpenUI(_M)
end

function Hide()    
	if exit_callback ~= nil then
		exit_callback()
	end
    Global.CloseUI(_M)
end

function Close()
	Global.ClearSupportPlayBack()
	exit_callback = nil
	playbackInfo = nil
    _ui = nil
end
