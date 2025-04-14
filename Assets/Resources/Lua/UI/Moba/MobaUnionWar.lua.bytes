module("MobaUnionWar", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui
local timer = 0
local index

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    if _ui ~= nil then
        if _ui.massTroopTab.cur_select_index >= 10 then
            _ui.massTroopTab:CloseDetail()
        else
            Hide()
        end
    end
end

function GetMassTroopTab()
    if _ui ~= nil then
        return _ui.massTroopTab
    end
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/background widget/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui.massTroopTrf = transform:Find("Container/bg2/content 2")
    _ui.massTroopTab = MobaMassTroops(_ui.massTroopTrf)
    _ui.massTroopTab:Open(index)        
end

function TestChat()
	 local send = {}
	send.curChanel = ChatMsg_pb.chanel_MobaTeam
	send.content = Global.GTextMgr:GetText("ui_rally_msg")   
	send.spectext = "11"..",".."defunionname"..",".."defname"..",".."endtime"..",".."startime"..",".."19"..",".."42"..",".."35792"..",".."playerunionname"..",".."你爸爸"
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.type = ChatMsg_pb.ChatInfoConditionType_MobaGather
	send.chatType = 6
	send.tarUid = HeroMsg_GatheSummaryInfo.defHomeuid
	send.senderguildname =  ""
	MobaChat.SendConditionContent(send, function()
		FloatText.Show(Global.GTextMgr:GetText("union_invite_text7"), Color.green)
	end)      
end

function Close()
    index = nil
    _ui.massTroopTab:Close()
    _ui = nil
end

function Show(_index)
    index = _index
    Global.OpenUI(_M)
end
