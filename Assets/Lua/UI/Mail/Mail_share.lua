module("Mail_share", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local UIAnimMgr = Global.GUIAnimMgr

local formationSmall
local targatFormationData
local selfFormationData
local formationPrefab

local curReportMsg = nil


local interface={
    ["Category_pb_M"] = Category_pb.Mail,
    ["MailShareFightRequest"]=MailMsg_pb.MsgUserMailShareFightRequest,
    ["MailShareFightRequestTypeID"] = MailMsg_pb.MailTypeId.MsgUserMailShareFightRequest,
    ["MailShareFightResponse"] = MailMsg_pb.MsgUserMailShareFightResponse,
}

local interface_guildmoba={
    ["Category_pb_M"] = Category_pb.GuildMoba,
    ["MailShareFightRequest"]=GuildMobaMsg_pb.GuildMobaMailShareFightRequest,
    ["MailShareFightRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaMailShareFightRequest,
    ["MailShareFightResponse"] = GuildMobaMsg_pb.GuildMobaMailShareFightResponse,
}

local GetInterface=function(interface_name)
    if Global.GetMobaMode() == 2 then
        return interface_guildmoba[interface_name]
    else
        return interface[interface_name]
    end
end

local function ViewReportResult(go)
	print("view report")
	
	local transformParams = {}
	transformParams.formationSmall = formationSmall
	
	
	--设置战斗返回时的界面显示：
	local mainui = "MainCityUI"
	local posx = 0
	local posy = 0
	if GUIMgr:FindMenu("WorldMap") ~= nil then
		mainui = "WorldMap"
		local curpos = WorldMap.GetCenterMapCoord()
		posx , posy = WorldMap.GetCenterMapCoord()
    end
	Global.SetBattleReportBack(mainui , "Chat" , posx , posy)
	Global.CheckBattleReportEx(curReportMsg  , function()
		print("report end function")
		
		local battleBack = Global.GetBattleReportBack()
		if battleBack.MainUI == "WorldMap" then
            MainCityUI.ShowWorldMap(battleBack.PosX , battleBack.PosY, false)
		end
		
		if battleBack.Menu ~= nil then
			if battleBack.Menu == "Mail" then
				Mail.SetTabSelect(3)
				--GUIMgr:CreateMenu("Mail", false)
				Mail.Show()
			else
				if battleBack.Menu == "Chat" then
					--GUIMgr:CreateMenu("Chat", false)
				end
			end
		end
		
	end)
	
end

local function LoadUI(reportMsg , maildata , isMoba)
	curReportMsg = reportMsg
	local shareContent = transform:Find("Mail_share")
	
	local battleResult = MailReportDoc.ShowContent(curReportMsg ,shareContent ,maildata,formationPrefab)
	transform:Find("Mail_share/bg_mid/bg_right/bg_information/btn_report").gameObject:SetActive((not isMoba) and battleResult)
	transform:Find("Mail_share/bg_mid/bg_left/bg_resource").gameObject:SetActive(not isMoba)
	transform:Find("Mail_share/bg_mid/bg_left/Texture").gameObject:SetActive(isMoba)
	transform:Find("Mail_share/bg_mid/bg_right/bg_property/info_property (3)").gameObject:SetActive(not isMoba)
	transform:Find("Mail_share/bg_mid/bg_right/bg_property/info_property (6)").gameObject:SetActive(not isMoba)
	
	if Global.GetMobaMode() == 2 then
		local playerSelfCoord =  shareContent:Find("bg_mid/bg_right/bg_head_top/bg_head_attack/coordinate_attack")
		SetClickCallback(playerSelfCoord.gameObject , function(go)
			GuildMobaChat.GoMap(reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y)
		end)
		local selgHeadBtn = shareContent:Find("bg_mid/bg_right/bg_head_top/bg_head_attack")
		SetClickCallback(selgHeadBtn.gameObject , function(go) end)
	
		local targetCoord =  shareContent:Find("bg_mid/bg_right/bg_head_top/bg_head_defence/coordinate_defence"):GetComponent("UILabel")
		SetClickCallback(targetCoord.gameObject , function(go)
			GuildMobaChat.GoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
		end)
		local tagetHeadBtn = shareContent:Find("bg_mid/bg_right/bg_head_top/bg_head_defence")
		SetClickCallback(tagetHeadBtn.gameObject , function(go) end)
	
		local coordBtn = shareContent:Find("bg_mid/bg_title/btn_coord"):GetComponent("UIButton")
		SetClickCallback(coordBtn.gameObject , function()
			GuildMobaChat.GoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
		end)    
	end
end

function Show(reportMailData , isMoba)	
	--请求战报数据
	local req = GetInterface("MailShareFightRequest")()
	req.fightreportid = reportMailData.reportId
	
	Global.Request(GetInterface("Category_pb_M"), GetInterface("MailShareFightRequestTypeID"), req,GetInterface("MailShareFightResponse"), function(msg)
		if msg.code == 0 then
			Global.OpenUI(_M)
			LoadUI(msg,reportMailData , isMoba)
		else
			print(msg.code)
		end
	end)
	
end

function CheckShow()
    
end

function Hide()
    Global.CloseUI(_M)
    CheckShow()
end

function Awake()
    local btnClose = transform:Find("Mail_share/bg_top/btn_close")
    SetClickCallback(btnClose.gameObject, Hide)
	
	local bg = transform:Find("mask")
	SetClickCallback(bg.gameObject, Hide)
	
	local btnViewReport = transform:Find("Mail_share/bg_mid/bg_right/bg_information/btn_report"):GetComponent("UIButton")
    SetClickCallback(btnViewReport.gameObject , ViewReportResult)
	
	formationPrefab = ResourceLibrary.GetUIPrefab("CommonItem/battle_formation")
    --LoadUI()
end

function Close()
    curReportMsg = nil
	selfFormationData = nil
    targatFormationData = nil
	formationPrefab = nil
end
