module("BattleTime", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local _ui
local Indexes = {[1] = 1, [2] = 2, [3] = 4}
local serverTimeMsg
local serverTimeSec

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Close()
    _ui = nil
    serverTimeMsg = nil
	serverTimeSec = 0
end

function Awake()
    _ui.Result = 0
    _ui.times = {}
    local times = string.split(tableData_tGuildMobaGlobal.data[9].Value, ";")
    local lasttime = tableData_tGuildMobaGlobal.data[5].Value / 60
    for i = 1, 3 do
        _ui.times[i] = {}
        _ui.times[i].select = transform:Find(string.format("bg/mid/time%d/select", i)).gameObject
        _ui.times[i].sprite = transform:Find(string.format("bg/mid/time%d/Sprite", i)).gameObject
        _ui.times[i].label = transform:Find(string.format("bg/mid/time%d/text", i)):GetComponent("UILabel")
        _ui.times[i].label.text = String.Format(TextMgr:GetText("ui_unionwar_4"), times[i] .. ":00~" .. times[i] .. ":" .. lasttime)
        SetClickCallback(_ui.times[i].select, function()
            if (_ui.Result == 3 or _ui.Result == 5 or _ui.Result == 6) and not _ui.selectlist[i] then
                return
            end
            _ui.selectlist[i] = not _ui.selectlist[i]
            _ui.Result = _ui.Result + (_ui.selectlist[i] and Indexes[i] or (- Indexes[i]))
            _ui.times[i].sprite:SetActive(_ui.selectlist[i])
        end)
        _ui.times[i].sprite:SetActive(_ui.selectlist[i])
    end
    _ui.btn = transform:Find("bg/mid/btn").gameObject
    SetClickCallback(_ui.btn, function()
        if _ui.Result == 3 or _ui.Result == 5 or _ui.Result == 6 then
            if _ui.callback ~= nil then
                _ui.callback(_ui.Result)
            end
            Hide()
        else
            MessageBox.Show(TextMgr:GetText("ui_unionwar_3"))
        end
    end)
    _ui.btn_close = transform:Find("bg/top_bg_left/btn_close").gameObject
    SetClickCallback(_ui.btn_close, function()
        Hide()
    end)
    _ui.servertime = transform:Find("bg/mid/time_text"):GetComponent("UILabel")
    _ui.servertime.text = ""
end

function Start()

end

function LateUpdate()
	if serverTimeMsg ~= nil and serverTimeSec > 0 then
		local passSec = Serclimax.GameTime.GetSecTime() - serverTimeSec
		_ui.servertime.text = 	--[[System.String.Format(TextMgr:GetText("WorldTime_title") , ]]
									Global.SecondToStringFormat(serverTimeSec + passSec , "yyyy-MM-dd HH:mm:ss")--)
    end
end

function Show(callback)
    _ui = {}
    _ui.callback = callback
    _ui.selectlist = {}
    Global.OpenUI(_M)
    local req = LoginMsg_pb.MsgServerGameTimeRequest()
	Global.Request(Category_pb.Login, LoginMsg_pb.LoginTypeId.MsgServerGameTimeRequest, req, LoginMsg_pb.MsgServerGameTimeResponse, function(msg)
		serverTimeMsg = msg
		if serverTimeMsg ~= nil then
			serverTimeSec = serverTimeMsg.serverTime/1000
		end
	end)
end