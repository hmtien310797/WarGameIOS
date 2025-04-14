module("FortressWarinfo", package.seeall)

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

local function UpdateWarInfoItem(CenterBuildWarLog_msg, index)
    if CenterBuildWarLog_msg == nil then
        return
    end
    
    local data = TableMgr:GetGovWarLogByid(CenterBuildWarLog_msg.logId)
    if data == nil then
        print("ERRORRRRRRRRRRRRRRRRRRRRRRRRRRR",CenterBuildWarLog_msg.logId)
        _ui.warInfos[index].text.gameObject:SetActive(false)
        _ui.warInfos[index].no_one_occupied.gameObject:SetActive(true)
        return
    end
    _ui.warInfos[index].go_pos = CenterBuildWarLog_msg.pos
    if CenterBuildWarLog_msg.logId == 40040 then
        _ui.warInfos[index].text.gameObject:SetActive(false)
        _ui.warInfos[index].no_one_occupied.gameObject:SetActive(true)
        --_ui.warInfos[index].text.text = GetContentText(CenterBuildWarLog_msg,TextMgr:GetText(data.Content))
    else
        _ui.warInfos[index].text.gameObject:SetActive(true)
        _ui.warInfos[index].no_one_occupied.gameObject:SetActive(false)
        --_ui.warInfos[index].text.text = "[" .. CenterBuildWarLog_msg.noticeParams[1].value .. "]" .. CenterBuildWarLog_msg.noticeParams[2].value
        _ui.warInfos[index].over_text.text = "[" .. CenterBuildWarLog_msg.noticeParams[1].value .. "]" .. CenterBuildWarLog_msg.noticeParams[2].value
        if FortressData.GetContendEndTime(CenterBuildWarLog_msg.subType) > Serclimax.GameTime.GetSecTime() then
            _ui.warInfos[index].text.transform.parent.gameObject:SetActive(true)
            _ui.warInfos[index].over_text.transform.parent.gameObject:SetActive(false)
            _ui.warInfos[index].go_btn_sprite = "btn_2"
            CountDown.Instance:Add("FortressWarinfo" .. index, FortressData.GetContendEndTime(CenterBuildWarLog_msg.subType), CountDown.CountDownCallBack(function(t)
                local endtime = FortressData.GetContendEndTime(CenterBuildWarLog_msg.subType)
                _ui.warInfos[index].time.text = t
                local time_value =  TableMgr:GetGlobalData(100141)
                local time = time_value ~= nil and tonumber(time_value.value) or 8*3600 
                _ui.warInfos[index].time_progress.value = 1 - (endtime - Serclimax.GameTime.GetSecTime()) / time
                if endtime - Serclimax.GameTime.GetSecTime() <= 0 then
                    CountDown.Instance:Remove("FortressWarinfo" .. index)
                    _ui.warInfos[index].text.transform.parent.gameObject:SetActive(false)
                    _ui.warInfos[index].over_text.transform.parent.gameObject:SetActive(true)
                    _ui.warInfos[index].go_btn_sprite = "btn_1"
                end
            end)) 
        else
            _ui.warInfos[index].text.transform.parent.gameObject:SetActive(false)
            _ui.warInfos[index].over_text.transform.parent.gameObject:SetActive(true)
            _ui.warInfos[index].go_btn_sprite = "btn_1"
        end
        _ui.warInfos[index].text.text =  GetContentText(CenterBuildWarLog_msg,TextMgr:GetText(data.Content))
    end
    _ui.warInfos[index].name.text = TextMgr:GetText(TableMgr:GetFortressRuleByID(CenterBuildWarLog_msg.subType).name)
end

local function InitWarInfo(i)
    _ui.warInfos[i].text = _ui.warInfos[i].trf:Find("bg/playername"):GetComponent("UILabel")
    _ui.warInfos[i].time = _ui.warInfos[i].trf:Find("bg/playername/time"):GetComponent("UILabel")
    _ui.warInfos[i].time_progress = _ui.warInfos[i].trf:Find("bg/playername/background"):GetComponent("UIProgressBar")
    _ui.warInfos[i].no_one_occupied = _ui.warInfos[i].trf:Find("bg/no_one_occupied")
    _ui.warInfos[i].go_btn = _ui.warInfos[i].trf:Find("button")
    _ui.warInfos[i].go_btn_sprite = _ui.warInfos[i].go_btn:GetComponent("UISprite")
    _ui.warInfos[i].go_pos = nil
    _ui.warInfos[i].over_text = _ui.warInfos[i].trf:Find("bg over/playername"):GetComponent("UILabel")
    _ui.warInfos[i].name = _ui.warInfos[i].trf:Find("buildname"):GetComponent("UILabel")
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
    for i=1,#_ui.log.warLogs do
        print(i,_ui.log.warLogs[i].logId)
        UpdateWarInfoItem(_ui.log.warLogs[i], i)
    end
end

LoadUI = function()
    _ui.log = FortressData.GetFortressWarLogInfoMsg()
    for i=2,#_ui.log.warLogs do
        if _ui.warInfos[i] == nil then
            _ui.warInfos[i] = {}
            _ui.warInfos[i].trf = NGUITools.AddChild(_ui.grid.gameObject , _ui.itemprefab.gameObject).transform
        end
    end
    for i=1,#_ui.log.warLogs do
        InitWarInfo(i)
    end
    UpdateWarInfo()
    --[[    
    _ui.warInfos[1] = {}
    _ui.warInfos[1].trf = transform:Find("Container/bg_frane/bg_warinfo")
    InitWarInfo(1)
    UpdateWarInfoItem(_ui.log.warLogs[1], 1)
    ]]

    CountDown.Instance:Add("FortressWarinfo0", FortressData.GetAllEndTime(), CountDown.CountDownCallBack(function(t)
        _ui.totleTime.text = t
        if FortressData.GetAllEndTime() - Serclimax.GameTime.GetSecTime() <= 0 then
            CountDown.Instance:Remove("FortressWarinfo0")
			if _ui ~= nil and transform ~= nil then
				_ui.totleTime.transform.parent.gameObject:SetActive(false)
			end
        end
    end)) 
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
    _ui.grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.itemprefab = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid/bg_warinfo")
    _ui.warInfos[1] = {}
    _ui.warInfos[1].trf = _ui.itemprefab
    _ui.totleTime = transform:Find("Container/bg_frane/bg_top/time/num"):GetComponent("UILabel")
    SetClickCallback(transform:Find("Container/bg_frane/bg_top/help btn").gameObject, function()
        GOV_Help.Show(GOV_Help.HelpModeType.FORTRESS)
    end)
    LoadUI()
    FortressData.AddStateListener(LoadUI)
end

function Show()    
    FortressData.ReqFortressWarLogInfo(function()
        Global.OpenUI(_M)
    end)
end

function Close()   
    for i = 0, #_ui.log.warLogs do
        CountDown.Instance:Remove("FortressWarinfo" .. i)
    end
    FortressData.RemoveStateListener(LoadUI)
    _ui = nil
end
