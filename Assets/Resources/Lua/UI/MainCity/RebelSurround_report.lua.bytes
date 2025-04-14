module("RebelSurround_report",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local msg
local curLevel
local curWave
local winlose
local title
local curWaveType

local _ui
local _closeCallBack
local resultWinLose
function MonsterToPlayerName(level)
    print("MonsterToPlayerName",TextMgr:GetText("RebelSurroundname_"..level),level)
    return TextMgr:GetText("RebelSurroundname_"..level)
end

function UserToPlayerName(user)
    print("UserToPlayerName",user.name)
	local vsStr = "  [ff0000]VS[-]  "
	
	local player1Guile = ""
	local strIndex = 1
	if user.guildBanner ~= "" then
		player1Guile = "[f1cf63][" .. user.guildBanner .. "][-]"
		strIndex = 13 + Global.utfstrlen(user.guildBanner)
	end
	
	--local player1Guile = "[" .. 111 .. "]"
	local player1 = user.name
	local play1Len = Global.utfstrlen(player1)

	local player1Str = ""
	if play1Len > 10 then
		player1Str = Global.GetSubString(player1,0, 10) .. ".."--string.sub(player1 , 1 , 10) .. ".."
	else
		player1Str = player1
	end
    player1Str = player1Guile .. player1Str
    return player1Str
end

function UserToPlayerFace(user)
    print("UserToPlayerFace",user.face)
    return user.face
end

function MonsterToPlayerFace()
    print("MonsterToPlayerFace")
    return 666
end


function RebelSurroundFunc(state)
    --local result = RebelSurroundData.GetBattleResult()
    local data = RebelSurroundData.GetData()
    if state == "Title" then
        _ui.loseTip.gameObject:SetActive(not resultWinLose)
        
        return title,winlose
    elseif state == "Hero" then
        local nhero1 = _ui.retortUI.transform:Find("bg_right/none_hero01"):GetComponent("UILabel")
        local gridleft = _ui.retortUI.transform:Find("bg_right/Grid_left")
        local gridright = _ui.retortUI.transform:Find("bg_right/Grid_right")
        gridleft.gameObject:SetActive(true)
        gridright.gameObject:SetActive(true)
        nhero1.gameObject:SetActive(false)
        local nhero2 = _ui.retortUI.transform:Find("bg_right/none_hero02"):GetComponent("UILabel")
        nhero2.gameObject:SetActive(false)
        if curWaveType == 1 then
            if #msg.misc.result.input.user.team1[1].hero.heros == 0 then
                gridleft.gameObject:SetActive(false)
                nhero1.gameObject:SetActive(true)
                nhero1.text = TextMgr:GetText("RebelSurround_41")                
            end                
            if #msg.misc.result.input.user.team2[1].hero.heros == 0 then
                nhero2.gameObject:SetActive(true)
                nhero2.text = TextMgr:GetText("RebelSurround_29")
                gridright.gameObject:SetActive(false)
            end
        else
            if #msg.misc.result.input.user.team1[1].hero.heros == 0 then
                nhero1.gameObject:SetActive(true)
                nhero1.text = TextMgr:GetText("RebelSurround_29")
                gridleft.gameObject:SetActive(false)
            end
            if #msg.misc.result.input.user.team2[1].hero.heros == 0 then
                gridright.gameObject:SetActive(false)
                nhero2.gameObject:SetActive(true)
                nhero2.text = TextMgr:GetText("RebelSurround_41")                    
            end
        end            
    elseif state == "player1" then
        if curWaveType == 1 then
            return MonsterToPlayerName(curLevel)
        else
            if msg.misc.result.input.user.team1[1].user ~= nil and msg.misc.result.input.user.team1[1].user.name ~= nil then
                return UserToPlayerName(msg.misc.result.input.user.team1[1].user)
            end
        end                      
    elseif state == "player1face" then
        if curWaveType == 1 then
            return MonsterToPlayerFace()
        else
            if msg.misc.result.input.user.team1[1].user ~= nil and msg.misc.result.input.user.team1[1].user.face ~= nil then
                return UserToPlayerFace(msg.misc.result.input.user.team1[1].user)
            end 
        end
          
    elseif state == "player2" then
        if curWaveType == 2 then
            return MonsterToPlayerName(curLevel)
        else
            if msg.misc.result.input.user.team2[1].user ~= nil and msg.misc.result.input.user.team2[1].user.name ~= nil then
                return UserToPlayerName(msg.misc.result.input.user.team2[1].user)
            end
        end   
    elseif state == "player2face" then
        if curWaveType == 2 then
            return MonsterToPlayerFace()
        else
            if msg.misc.result.input.user.team2[1].user ~= nil and msg.misc.result.input.user.team2[1].user.face ~= nil then
                return UserToPlayerFace(msg.misc.result.input.user.team2[1].user)
            end 
        end
    elseif state == "battleReport" then
        Global.CheckBattleReportEx(msg ,Mail.MailReportType.MailReport_player , function()
        local battleBack = Global.GetBattleReportBack()
        if battleBack.MainUI == "WorldMap" then
            MainCityUI.ShowWorldMap(battleBack.PosX , battleBack.PosY, false)
        end
        
        if battleBack.Menu ~= nil then
            if battleBack.Menu == "Mail" then
                Mail.SetTabSelect(3)
                Mail.Show()
            end
        end
        
    end,RebelSurround_report.RebelSurroundFunc)
    elseif state == "ClickFace1" then
        if curWaveType == 1 then
            return false
        else
            return true
        end
    elseif state == "ClickFace2" then
        if curWaveType == 1 then
            return true
        else
            return false
        end        
    end
end

function Awake()
    _ui = {}
    _ui.Mask = transform:Find("mask")
    if _ui.Mask ~= nil then
        SetClickCallback(_ui.Mask.gameObject,function()
            Hide()
        end)        
    end
    _ui.Close = transform:Find("Container/bg_collection/close btn")
    SetClickCallback(_ui.Close.gameObject,function()
        Hide()
    end)     

    _ui.retortUI = transform:Find("Container/bg_collection/bg_mid")

    _ui.loseTip = transform:Find("Container/top_text02")
    _ui.loseTip.gameObject:SetActive(false)
    local mailData = {}
    mailData.subtype = Mail.MailReportType.MailReport_player
    mailData.createtime = 0

    msg ={
        content = "Mail_attack_actmonster_win_Desc",
        misc =
        {
            recon ={},
            robres ={},
            traderes ={},
            heros ={},
            train ={},
            attachShow ={},
            siegeShow ={},
            reportid = 8602,
            source ={},
            target ={},
            fortOccupy ={},
            result ={},
        }        
    }
    local result = RebelSurroundData.GetBattleResult()
    local data = RebelSurroundData.GetData()
    curLevel = result.level
    curWave = result.wave
    winlose,title = RebelSurroundData.GetWinLose(result)
    resultWinLose = winlose == 1    
    curWaveType = data.levelInfo.waveInfos[result.wave].type
    msg.misc.result = result.battleResult 
    if msg.misc.result.input.user.team1[1].user ~= nil then
        msg.misc.source = msg.misc.result.input.user.team1[1].user
    else
        msg.misc.source = MonsterToPlayer(result.level)
    end
    if msg.misc.result.input.user.team2[1].user ~= nil then
        msg.misc.target = msg.misc.result.input.user.team2[1].user
    else
        msg.misc.target = MonsterToPlayer(result.level)
    end
    if msg.misc.result.input.user.team1[1].hero == nil then
        msg.misc.result.input.user.team1[1].hero = {heros={}}
    end
    if msg.misc.result.input.user.team2[1].hero == nil then
        msg.misc.result.input.user.team2[1].hero = {heros={}}
    end    
    
    MailReportDocNew.ShowReportContent(215,msg,_ui.retortUI,mailData , nil,RebelSurroundFunc)
end

function Start()
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
    _ui = nil
    if _closeCallBack ~= nil then
        _closeCallBack(resultWinLose)
    end    
    RebelSurroundData.ClearBattleResult()

    _closeCallBack = nil
end

function Show(callback)
    _closeCallBack = callback
	Global.OpenUI(_M)	
end
