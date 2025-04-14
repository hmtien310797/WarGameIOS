module("Mail", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String
local GameObject = UnityEngine.GameObject
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local mailContent
local mailDataList

local curSubTabSelect = 1
local curTabSelect = 3 -- report
local mailUI = {}
local mailNew = {}
local MainMailNotify
local newTab = false
local curRealIndex = 0

local jumpMailMenu = nil 
local svPos

local _ui
local interface={
	["Category_pb"] = Category_pb.Mail,
	["MailReadRequest"] = MailMsg_pb.MsgUserMailReadRequest,
    ["MailReadResponse"] = MailMsg_pb.MsgUserMailReadResponse,
	["MailReadRequestTypeID"] = MailMsg_pb.MailTypeId.MsgUserMailReadRequest,
	["UpdateNotice"] = MobaMain.UpdateNotice,
	["MailDeleteRequest"] = MailMsg_pb.MsgUserMailDelRequest,
	["MailDeleteRequestTypeID"] = MailMsg_pb.MailTypeId.MsgUserMailDelRequest,
	["MailDeleteResponse"] = MailMsg_pb.MsgUserMailDelResponse,
}

local interface_guild={
	["Category_pb"] = Category_pb.GuildMoba,
    ["MailReadRequest"] = GuildMobaMsg_pb.GuildMobaMailReadRequest,
    ["MailReadResponse"] = GuildMobaMsg_pb.GuildMobaMailReadResponse,
	["MailReadRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaMailReadRequest,
	["UpdateNotice"] = GuildWarMain.UpdateNotice,
	["MailDeleteRequest"] = GuildMobaMsg_pb.GuildMobaMailDelRequest,
	["MailDeleteRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaMailDelRequest,
	["MailDeleteResponse"] = GuildMobaMsg_pb.GuildMobaMailDelResponse,
}


local function GetInterface(interface_name)
    if Global.GetMobaMode() == 2 then
        return interface_guild[interface_name]
    else
        return interface[interface_name]
    end
    
end

MailReportType = 
{
	"MailReport_monster=1",					--打怪
	"MailReport_player=2",					--攻击玩家
	"MailReport_takeres=3",					--采集
	"MailReport_robres=4",					--采集抢夺战斗@
	"MailReport_robclamp=5",				--扎营抢夺战斗
	"MailReport_recon = 6",					--侦查
	"MailReport_defence = 7",					--玩家防御
	"MailReport_robresdefence = 8",			--抢夺采集防御
	"MailReport_robcampdefence = 9",			--抢夺扎营防御
	"MailReport_reconmonster = 10",			--侦查怪物
	"MailReport_recontakeres = 11",			--侦查采集
	"MailReport_berecon = 12",				--被侦查
	"MailReport_traderes = 13",				--资源运输
	"MailReport_shieldRecon = 14",			--侦察护盾玩家
	"MailReport_shieldBeRecon= 15",			--护盾玩家被侦察
	"MailReport_shieldAttack = 16",			--攻击护盾玩家
	"MailReport_shieldDefence = 17",			--护盾玩家防御
	"MailReport_shieldGatherAttack = 18",		--集结攻击护盾玩家
	"MailReport_shieldGatherDefence = 19",	--护盾玩家防御集结
	"MailReport_actmonster = 20",				--活动野怪，需要看战报
	"MailReport_GuildWareHouse = 21",			--联盟仓库邮件
	"MailReport_GuildMine = 22",				--联盟超极矿邮件
	"MailReport_GuildTrain=23",				--联盟训练场邮件

	"MailReport_monsterdrop=100",			--打怪掉落
	"MailReport_actmonsterfinder=101",		--活动野怪发现奖励
	"MailReport_actmonsterdrop=102",		--活动野怪掉落
	
	"MailReport_guildmonsterRepoty=217",    --雇佣兵营地

	"MailReport_atkGovt = 250",			--进攻政府
	"MailReport_gatherGovt = 251",		--集结政府
	"MailReport_reconGovt = 252",		--侦查政府
	"MailReport_defGovt = 253",			--防守政府

	"MailReport_atkTurret = 254",			--进攻炮塔
	"MailReport_gatherTurret = 255",		--集结炮塔
	"MailReport_reconTurret = 256",			--侦查炮塔
	"MailReport_defTurret = 257",			--防守炮塔
	
	"MailReport_siegeReward=200",				--叛军攻城奖励
	"MailReport_siegeAttack=201",				--叛军攻城战报
	"MailReport_siegeHelp=202",					--叛军攻城驻防战报

	"MailReport_fort=240",						--叛军要塞战报
	"MailReport_fortmonster=241",                --叛军要塞侦察战报
	"MailReport_fortAll=242",	
	"MailReport_activityTrailer=300",
	"MailReport_atkEliter=400"	,				--攻击精英野怪
	"MailReport_reconElite=401",					--侦查精英野怪
	
	"MailReport_atkStronghold=410",				--攻击据点
	"MailReport_gathStronghold=411",			--集结据点
	"MailReport_reconStronghold=412",			--侦查据点
	"MailReport_defStronghold=413",				--防守据点
	
	
	"MailReport_atkFortress=420",				--攻击要塞
	"MailReport_gathFortress=421",			--集结要塞
	"MailReport_reconFortress=422",			--侦查要塞
	"MailReport_defFortress=423",				--防守要塞


	"MailReport_prisonerRewardSet=430",				--俘虏收到赎金要求
	"MailReport_prisonerRewardOpt=431",			--监禁者收到赎金/被拒
	"MailReport_prisonerFlee=432",			--监禁者俘虏逃走
	
	"MailReort_atkWorldCity=103" , 			--进攻城市
	"MailReort_occupyWorldCity=104" , 			--占领城市
	
	--Moba
	"MobaMailReport_monster=10001",			--moba攻击野怪
	"MobaMailReport_player=10010",			--moba攻击玩家
	"MobaMailReport_defence=10011",			--moba防守玩家
	"MobaMailReport_atkBuild=10002",			--moba进攻建筑
	"MobaMailReport_defBuild=10006",			--moba防守建筑
	"MobaMailReport_recon=10003",			--moba侦查
	"MobaMailReport_berecon=10004",			--moba被侦查
	"MobaMailReport_gatherTarget=10005",	--moba集结
	"MobaMailReport_SceneOver=500",			--moba单场战斗结束
}
MailReportType = Global.CreatEnumTable(MailReportType , 1)

OnCloseCB = nil

local function SubTypeRed(selTab)
	if _ui == nil or _ui.reportPage1Red == nil or _ui.systemPage1Red == nil then
		return
	end
	if selTab == 3 then
		_ui.reportPage1Red:SetActive(MailListData.GetNewMailTypeCount(3, 1))
		_ui.reportPage2Red:SetActive(MailListData.GetNewMailTypeCount(3, 2))
		_ui.reportPage3Red:SetActive(MailListData.GetNewMailTypeCount(3, 3))
		_ui.reportPage4Red:SetActive(MailListData.GetNewMailTypeCount(3, 4))
	elseif selTab == 1 then
		_ui.systemPage1Red:SetActive(MailListData.GetNewMailTypeCount(1, 1))
		_ui.systemPage2Red:SetActive(MailListData.GetNewMailTypeCount(1, 2))
	end
end

function NotifyMail()
	--print("MailNotify")
	for _ , v in pairs(mailUI) do
		if v.NotifyPush ~= nil then
			v.NotifyPush()
		end
	end
	SubTypeRed(curTabSelect)
end

function SetJumMenu(mailmenu)
	jumpMailMenu = mailmenu
end

function JumpNewTab(sel)
	newTab = sel
end

function GetTabSelect()
	return curTabSelect
end

function SetTabSelect(tab)
	curTabSelect = tab
end

local function OnUICameraPress(go, pressed)
	--print(go.name)
	if not pressed then
		return
	end
	
	Tooltip.HideMobaBuffTips()
	Tooltip.HideItemTip()
end

function ParsrGMContent(str , lancode)
	local startF , startE = string.find(str , lancode.."=")
	local endF , endE = string.find(str , "="..lancode)
	local found = false
	if startF ~= nil and startE ~= nil and endF ~= nil and endE ~= nil then
		found = true
	end
	
	if found then
		--return string.format("%q" , string.sub(str, startE+1, endF-1))
		return string.sub(str, startE+1, endF-1)
	else
		local startF , startE = string.find(str , "default=")
		local endF , endE = string.find(str , "=default")
		if startF ~= nil or startF ~= nil or endF ~= nil or endE ~= nil then
			--return string.format("%q" , string.sub(str, startE+1, endF-1))
			return string.sub(str, startE+1, endF-1)
		else
			return str
		end
	end
	
end

function GetMailContent(mailData)
	local param = {}
	local contentText = ""
	if mailData.category == MailMsg_pb.MailType_User then
			return mailData.content
	elseif mailData.webgm then
		local curlan = TableMgr:GetLanguageSettingData(TextMgr:GetCurrentLanguageID())
		contCfg =  ParsrGMContent(mailData.content , curlan.Icon)
		return contCfg
	end
	
	--配置的参数个数
	local conText = TextMgr:GetText(mailData.content)
	local conParams = {}
	for w in string.gmatch(conText , "{%d}") do
		conParams[#conParams + 1] = w
	end
		
	if mailData.contentparams ~= nil and #(mailData.contentparams)>0 then
		--实际的参数个数
		for _ , vv in ipairs(mailData.contentparams) do
			local str = vv.value
			if vv.isTextName then
				str = TextMgr:GetText(vv.value)
			end
			table.insert(param , str)
		end
		
		--补足缺少的参数
		for i=#param , #conParams , 1 do
			table.insert(param , "xxx")
		end
		
		contentText = GUIMgr:StringFomat(conText, param)
	else
		if mailData.subtype == 10001 or mailData.subtype == 10002 then
			for i=1 , #conParams , 1 do
				table.insert(param , "0")
			end
			contentText = GUIMgr:StringFomat(conText, param)
		else
			contentText = TextMgr:GetText(mailData.content)
		end
		
	end
	
	return contentText
end

function GetMailTittle(mailData)
	local titleparam = {}
	local titlecontentText = ""
	if mailData.category == MailMsg_pb.MailType_User --[[or mailData.webgm]] then
		return mailData.fromGuildBanner ~= nil and mailData.fromGuildBanner ~= "" and (string.format("【%s】%s" , mailData.fromGuildBanner, mailData.fromname)) or mailData.fromname
	elseif mailData.webgm then
		local curlan = TableMgr:GetLanguageSettingData(TextMgr:GetCurrentLanguageID())
		contCfg =  ParsrGMContent(mailData.title , curlan.Icon)
		return contCfg
		--return mailData.title
	end
	
	
	if mailData.titleparams ~=nil and #(mailData.titleparams) > 0 then
		--配置的参数个数
		local titleText = TextMgr:GetText(mailData.title)
		local params = {}
		for w in string.gmatch(titleText , "{%d}") do
			params[#params + 1] = w
		end
	
		--实际的参数个数
		for _ , vv in ipairs(mailData.titleparams) do
			local str = vv.value
			if vv.isTextName then
				str = TextMgr:GetText(vv.value)
			end
			table.insert(titleparam , str)
		end
		
		--补足缺少的参数
		for i=#titleparam , #params , 1 do
			table.insert(titleparam , "xxx")
		end
		
		titlecontentText = GUIMgr:StringFomat(titleText, titleparam)
	else
		titlecontentText = TextMgr:GetText(mailData.title)
	end
	return titlecontentText
end

function CancalSaveMail(mailid)
	local req = MailMsg_pb.MsgUserMailSetSaveRequest()
	req.maillist:append(mailid)
	
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSetSaveRequest, req, MailMsg_pb.MsgUserMailSetSaveResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
			FloatText.Show(TextMgr:GetText("mail_ui35") , Color.white)
			MailListData.CancelSaveMails(msg.maillist)
		end
	end)
end

function SaveMail(mailid)
	local mailData = MailListData.GetMailDataById(mailid)
	if mailData.saved then
		AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
		FloatText.Show(TextMgr:GetText("mail_ui34")  , Color.green)
		return
	end
	
	local req = MailMsg_pb.MsgUserMailSetSaveRequest()
	--for _, v in pairs(mailid) do
	--	print("---------" .. v)
	req.maillist:append(mailid)
	--end
	
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSetSaveRequest, req, MailMsg_pb.MsgUserMailSetSaveResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
			FloatText.Show(TextMgr:GetText("mail_ui40") , Color.green)
			MailListData.SaveMails(msg.maillist)
		end
	end)
end

function GetAllAttachItem()
	local maillist 
	if curTabSelect == 4 then
		maillist = MailListData.GetAllSavedAttachItems()
	else
		if curTabSelect == 3 or curTabSelect == 1 then
			maillist = MailListData.GetAllAttachItems(curTabSelect, curSubTabSelect)
		else
			maillist = MailListData.GetAllAttachItems(curTabSelect, 0)
		end
	end
	
	local req = MailMsg_pb.MsgUserMailTakeAttachmentRequest()
	for _, v in pairs(maillist) do
		req.mailid:append(v.id)
	end

	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailTakeAttachmentRequest, req, MailMsg_pb.MsgUserMailTakeAttachmentResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			GUIMgr:SendDataReport("reward", "MailTakeAttachment", "".. MoneyListData.ComputeDiamond(msg.fresh.money.money))
			
			MainCityUI.UpdateRewardData(msg.fresh)
			MailListData.GetMailAttachItem(msg.mailid)

			local getItemList = {}
			for _ , v in ipairs(msg.reward.item.item) do
				local getItem = {baseid = v.baseid , num = v.num , itype = 0}
				table.insert(getItemList , getItem)
			end
			
			ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
			ItemListShowNew.SetItemShow(msg)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
			
		end
	end)
	--MainMailNotify()
end

function ReadMail(maildata , msg , dirShow)
	if maildata.category == MailMsg_pb.MailType_Report and 
		(maildata.subtype == MailReportType.MailReport_recon  or
		maildata.subtype == MailReportType.MailReport_reconmonster or
		maildata.subtype == MailReportType.MailReport_berecon or 
		maildata.subtype == MailReportType.MailReport_recontakeres or
		maildata.subtype == MailReportType.MailReport_shieldRecon or
		maildata.subtype == MailReportType.MailReport_shieldBeRecon or
		maildata.subtype == MailReportType.MailReport_shieldAttack or
		maildata.subtype == MailReportType.MailReport_shieldDefence or
		maildata.subtype == MailReportType.MailReport_shieldGatherAttack or
		maildata.subtype == MailReportType.MailReport_shieldGatherDefence or
		maildata.subtype == MailReportType.MailReport_reconGovt or
		maildata.subtype == MailReportType.MailReport_reconTurret or
		maildata.subtype == MailReportType.MailReport_fortmonster or
		maildata.subtype == MailReportType.MailReport_reconElite or
		maildata.subtype == MailReportType.MailReport_reconStronghold or
		maildata.subtype == MailReportType.MailReport_reconFortress) then 
			MailReportSpyonDoc.Show(maildata.id , msg.mail , dirShow)					--侦查模版
	elseif maildata.category == MailMsg_pb.MailType_Report and 
		(maildata.subtype == MailReportType.MailReport_actmonster or 
		maildata.subtype == MailReportType.MailReport_monster or
		maildata.subtype ==  MailReportType.MailReport_actmonsterfinder or
		maildata.subtype == MailReportType.MailReport_player or 
		maildata.subtype == MailReportType.MailReport_defence or
		maildata.subtype == MailReportType.MailReport_siegeAttack or
		maildata.subtype == MailReportType.MailReport_siegeHelp or
		maildata.subtype == MailReportType.MailReport_robres or 
		maildata.subtype == MailReportType.MailReport_robclamp or 
		maildata.subtype == MailReportType.MailReport_robresdefence or 
		maildata.subtype == MailReportType.MailReport_robcampdefence or
		maildata.subtype == MailReportType.MailReport_guildmonsterRepoty or
		maildata.subtype == MailReportType.MailReport_fort or 
		maildata.subtype == MailReportType.MailReport_fortAll or
		maildata.subtype == MailReportType.MailReport_defGovt or 
		maildata.subtype == MailReportType.MailReport_atkGovt or
		maildata.subtype == MailReportType.MailReport_defTurret or 
		maildata.subtype == MailReportType.MailReport_atkTurret or		
		maildata.subtype == MailReportType.MailReport_gatherGovt or
		maildata.subtype == MailReportType.MailReport_gatherTurret or
		maildata.subtype == MailReportType.MailReport_atkEliter or
		maildata.subtype == MailReportType.MailReport_atkStronghold or
		maildata.subtype == MailReportType.MailReport_gathStronghold or
		maildata.subtype == MailReportType.MailReport_defStronghold or
		maildata.subtype == MailReportType.MailReport_atkFortress or
		maildata.subtype == MailReportType.MailReport_gathFortress or
		maildata.subtype == MailReportType.MailReport_defFortress or
		maildata.subtype == MailReportType.MailReport_prisonerRewardSet or 
		maildata.subtype == MailReportType.MailReport_prisonerRewardOpt or
		maildata.subtype == MailReportType.MailReport_prisonerFlee or
		maildata.subtype == MailReportType.MailReort_atkWorldCity) then 
			MailReportDocNew.Show(maildata.id , msg.mail , dirShow)
	elseif maildata.category == MailMsg_pb.MailType_Moba and 
		(maildata.subtype == MailReportType.MobaMailReport_monster or 
		maildata.subtype == MailReportType.MobaMailReport_player or
		maildata.subtype == MailReportType.MobaMailReport_defence or
		maildata.subtype == MailReportType.MobaMailReport_gatherTarget or
		maildata.subtype == MailReportType.MobaMailReport_atkBuild or
		maildata.subtype == MailReportType.MobaMailReport_defBuild) then 
			MailReportDocNew.Show(maildata.id , msg.mail , dirShow)
	elseif maildata.category == MailMsg_pb.MailType_GuildMoba and 
		(maildata.subtype == MailReportType.MobaMailReport_monster or 
		maildata.subtype == MailReportType.MobaMailReport_player or
		maildata.subtype == MailReportType.MobaMailReport_defence or
		maildata.subtype == MailReportType.MobaMailReport_gatherTarget or
		maildata.subtype == MailReportType.MobaMailReport_atkBuild or
		maildata.subtype == MailReportType.MobaMailReport_defBuild) then 
			MailReportDocNew.Show(maildata.id , msg.mail , dirShow)
	elseif maildata.category == MailMsg_pb.MailType_Moba and 
		(maildata.subtype == MailReportType.MobaMailReport_recon or 
		maildata.subtype == MailReportType.MobaMailReport_berecon) then 
			MailReportSpyonDoc.Show(maildata.id , msg.mail , dirShow)
	elseif maildata.category == MailMsg_pb.MailType_GuildMoba and 
		(maildata.subtype == MailReportType.MobaMailReport_recon or 
		maildata.subtype == MailReportType.MobaMailReport_berecon) then 
			MailReportSpyonDoc.Show(maildata.id , msg.mail , dirShow)
			
	else
			MailDoc.Show(maildata.id , msg.mail , dirShow)
	end
end

function RequestReadMail(maildata , requestCallBack , dirShow)
	local req = GetInterface("MailReadRequest")()
	req.mailid = maildata.id
	req.isRead = true
	Global.Request(GetInterface("Category_pb"), GetInterface("MailReadRequestTypeID"), req, GetInterface("MailReadResponse"), function(msg)
		Global.DumpMessage(msg ,"d:/d.lua")
		if msg.code == 0 then
			MailListData.UpdateMailStatus(maildata.id , MailMsg_pb.MailStatus_Readed)
			MainMailNotify()
			MainCityUI.UpdateNotice()
			GetInterface("UpdateNotice")()
			SubTypeRed(curTabSelect)
			
			local mailCfg = TableMgr:GetMailCfgData(msg.mail.id)
			ReadMail(maildata , msg ,dirShow )
			if requestCallBack ~= nil then
				requestCallBack()
			end
		else
			print(msg.code)
		end
	end, true)
end

function RequestReadMailDirect(mailid , requestCallBack ,dirShow)
	local req = GetInterface("MailReadRequest")()
	req.mailid = mailid
	req.isRead = true
	Global.Request(GetInterface("Category_pb"), GetInterface("MailReadRequestTypeID"), req, GetInterface("MailReadResponse"), function(msg)
		if msg.code == 0 then
			MailListData.UpdateMailStatus(msg.mail.id , MailMsg_pb.MailStatus_Readed)
			MainCityUI.UpdateNotice()
			GetInterface("UpdateNotice")()
			SubTypeRed(curTabSelect)
			if requestCallBack ~= nil then
				requestCallBack(msg)
			end
		else
			print(msg.code)
		end
	end, true)
end


function DeleteMail(dlist , callback)
	local showFBIWarning_unget = false
	local showFBIWarning_unread = false
	local req = GetInterface("MailDeleteRequest")()
	local boxtext = ""
	local dellist = dlist or nil
	if dellist == nil then
		for i=1 , #mailDataList , 1 do
			if mailDataList[i].flag == true then
				req.maillist:append(mailDataList[i].data.id)
				local mail = MailListData.GetMailDataById(mailDataList[i].data.id)
				if not mail.taked and mail.hasattach then
					showFBIWarning_unget = true
					boxtext = "mail_ui41"
				elseif mail.status == 1 and not showFBIWarning_unget--[[MailStatus_New]] then
					showFBIWarning_unread = true
					boxtext = "mail_ui70"
				end
			end
		end
	else
		for _ , v in pairs(dellist) do
			req.maillist:append(v.id)
			local mail = MailListData.GetMailDataById(v.id)
			if not mail.taked and mail.hasattach then
				showFBIWarning_unget = true
				boxtext = "mail_ui41"
			elseif mail.status == 1 and not showFBIWarning_unget--[[MailStatus_New]] then
				showFBIWarning_unread = true
				boxtext = "mail_ui70"
			end
		end
	end
	
	
	local sureFunc = function(reqMsg ,boxText)
		local okCallback = function()
			Global.Request(GetInterface("Category_pb"), GetInterface("MailDeleteRequestTypeID"), reqMsg, GetInterface("MailDeleteResponse"), function(msg)
				MailListData.DeleteMailList(msg.maillist)
				AudioMgr:PlayUISfx("SFX_ui02", 1, false)
				FloatText.Show(TextMgr:GetText("mail_ui37") , Color.white)
				if callback ~= nil then
					callback()
				end
			end)
			
			MessageBox.Clear()
		end
		
		local cancelCallback = function()
			MessageBox.Clear()
		end
		MessageBox.Show(TextMgr:GetText(boxText), okCallback, cancelCallback)
	end
	
	if showFBIWarning_unget or showFBIWarning_unread then
		sureFunc(req , boxtext)
	else
		Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailDelRequest, req, MailMsg_pb.MsgUserMailDelResponse, function(msg)
			MailListData.DeleteMailList(msg.maillist)
			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
			FloatText.Show(TextMgr:GetText("mail_ui37") , Color.white)
			if callback ~= nil then
				callback()
			end
		end)
	end
	
	
end

function MarkMail()
	local req = MailMsg_pb.MsgUserMailSetReadRequest()
	for i=1 , #mailDataList , 1 do
		if mailDataList[i].flag == true then
			req.maillist:append(mailDataList[i].data.id)
		end
	end
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSetReadRequest, req, MailMsg_pb.MsgUserMailSetReadResponse, function(msg)
		MailListData.MarkMailList(msg.maillist)
    end)
end
--check box
local function MailOperatorBox()
	local mainMailUI = GetMailUI("Container")
	local count = 0
	if mailDataList ~= nil then
		for i=1 , #mailDataList , 1 do
			if mailDataList[i].flag == true then
				count = count + 1
			end
		end
	end
	mainMailUI.btnGroup.go.gameObject:SetActive(count > 0)
	if count <= 0 then
		local readedMails
		if curTabSelect == 4 then
			readedMails = MailListData.GetMailSavedList(2)
		else
			if curTabSelect == 3 or curTabSelect == 1 then
				readedMails = MailListData.GetMailListByStatus(2, curTabSelect, curSubTabSelect)
			else
				readedMails = MailListData.GetMailListByStatus(2, curTabSelect, 0)
			end
		end
		mainMailUI.delReadBtn.gameObject:SetActive(#readedMails > 0)
	else
		mainMailUI.delReadBtn.gameObject:SetActive(false)
	end
end

local function SelectAllBtnClick(go)
	local contentOptGrid = mailContent:Find("Scroll View/OptGrid")
	local count = 0
	for i=1 , #mailDataList , 1 do
		if mailDataList[i].flag == true then
			count = count + 1
		end
	end
	
	local allCheck = count < #mailDataList
	for i=1 , #mailDataList , 1 do
		mailDataList[i].flag = allCheck
	end
	
	for i = 0, contentOptGrid.childCount - 1 do
		--GameObject.Destroy(_ui.mailListGrid.transform:GetChild(i).gameObject)
		local gouxuan = contentOptGrid.transform:GetChild(i):Find("bg_list/checkbox"):GetComponent("UIToggle")
		gouxuan.value = allCheck
	end
	MailOperatorBox()
end

local function UpdateTabNewNumber()
	local mailmainUI = GetMailUI("Container")
	local systemNewNum = MailListData.GetNewMailCount(1)
	local reportNewNum = MailListData.GetNewMailCount(3)
	local playerNewNum = MailListData.GetNewMailCount(2)
	local favNewNum = MailListData.GetNewSavedMailCount()
	
	if systemNewNum > 0 then
		mailmainUI.Notify.sysNew.gameObject:SetActive(true)
		mailmainUI.Notify.sysNew:Find("num"):GetComponent("UILabel").text = systemNewNum
	else
		mailmainUI.Notify.sysNew.gameObject:SetActive(false)
	end
	
	if reportNewNum > 0 then
		mailmainUI.Notify.reportNew.gameObject:SetActive(true)
		mailmainUI.Notify.reportNew:Find("num"):GetComponent("UILabel").text = reportNewNum
	else
		mailmainUI.Notify.reportNew.gameObject:SetActive(false)
	end
	
	if playerNewNum > 0 then
		mailmainUI.Notify.userNew.gameObject:SetActive(true)
		mailmainUI.Notify.userNew:Find("num"):GetComponent("UILabel").text = playerNewNum
	else
		mailmainUI.Notify.userNew.gameObject:SetActive(false)
	end
	
	if favNewNum > 0 then
		mailmainUI.Notify.favNew.gameObject:SetActive(true)
		mailmainUI.Notify.favNew:Find("num"):GetComponent("UILabel").text = favNewNum
	else
		mailmainUI.Notify.favNew.gameObject:SetActive(false)
	end
	
end

local function MailListItemReaded(item)
	local str = item.name:split("_")
	local curRealIndex = tonumber(str[2])
	
	
	local v = mailDataList[curRealIndex].data
	local flag = mailDataList[curRealIndex].flag
	
	if v.status ~= 2 then
		return
	end
	
	local midShow = "bg_common"
	local midUnShow = "bg_war"
	if v.category == 3 then--MailMsg_pb.MailTypeId.MailType_Report
		midShow = "bg_war"
		midUnShow = "bg_common"
	end

	local itemMidInfoShow = item.transform:Find(System.String.Format("bg_list/{0}" , midShow))
	local itemMidInfoUnShow = item.transform:Find(System.String.Format("bg_list/{0}" , midUnShow))
	local des = itemMidInfoShow:Find("text_des"):GetComponent("UILabel")
	des.text = System.String.Format("[b2b2b2ff]{0}[-]" , des.text)
	
	local tittle = itemMidInfoShow:Find("text_name"):GetComponent("UILabel")
	tittle.gradientTop = Color(1,1,1,1)
	tittle.gradientBottom = Color(0.3608 , 0.3843 , 0.3960 , 1)
	local mtime = itemMidInfoShow:Find("text_time"):GetComponent("UILabel")
	mtime.text = System.String.Format("[b2b2b2ff]{0}[-]" , mtime.text)
	
	local backG = item.transform:Find("bg_list/background")
	backG.gameObject:SetActive(true)
	local readed = item.transform:Find("bg_list/bg_text/icon_unread")
	readed.gameObject:SetActive(false)
	
	UpdateTabNewNumber()
end

function UpdateMailListItem(item , index , realInde)
	local dataIndex = math.abs(realInde) + 1
	
	--print("====" , index , realInde , dataIndex , #mailDataList)
	if dataIndex > #mailDataList then
		--item.gameObject:SetActive(false)
		return
	end

	--item.gameObject:SetActive(true)
	curRealIndex = realInde
	local v = mailDataList[dataIndex].data
	local flag = mailDataList[dataIndex].flag
	local mailCfgData = TableMgr:GetMailCfgData(v.baseid)
	
	item.gameObject.name = "mail_" .. dataIndex
	--print("inde:" .. index .. "   realindex:" .. realInde .. "   dataIndex:" .. dataIndex)
	--mid info
	local midShow = "bg_common"
	local midUnShow = "bg_war"
	if mailCfgData.type == 3 then--MailMsg_pb.MailTypeId.MailType_Report
		midShow = "bg_war"
		midUnShow = "bg_common"
		--report icon
		local mailIcon = item.transform:Find("bg_list/bg_war/bg_icon/Texture"):GetComponent("UITexture")
		mailIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Mail/" , mailCfgData.icon)

	end
	
	
	
	
	local itemMidInfoShow = item.transform:Find(System.String.Format("bg_list/{0}" , midShow))
	itemMidInfoShow.gameObject:SetActive(true)
	local itemMidInfoUnShow = item.transform:Find(System.String.Format("bg_list/{0}" , midUnShow))
	itemMidInfoUnShow.gameObject:SetActive(false)
	
	local des = itemMidInfoShow:Find("text_des"):GetComponent("UILabel")
	local backG = item.transform:Find("bg_list/background")
	local readed = item.transform:Find("bg_list/bg_text/icon_unread")
	local tittle = itemMidInfoShow:Find("text_name"):GetComponent("UILabel")
	local mtime = itemMidInfoShow:Find("text_time"):GetComponent("UILabel")
	
	if v.category == MailMsg_pb.MailType_Moba or v.category == MailMsg_pb.MailType_GuildMoba then
		local mailIcon = itemMidInfoShow.transform:Find("bg_icon/Texture"):GetComponent("UITexture")
		mailIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Mail/" , mailCfgData.icon)
	end
	
	--list content
	local contentText = GetMailContent(v)

	--list title
	Global.DumpMessage(v , "d:/mobaMail.lua")
	local titlecontentText = GetMailTittle(v)
	-- list time
	local timeText = Global.SecondToStringFormat(v.createtime , "yyyy-MM-dd HH:mm:ss")  --Serclimax.GameTime.SecondToStringYMDLocal(v.createtime)
	if v.status == 2 then
		contentText = System.String.Format("[b2b2b2ff]{0}[-]" , contentText)
		titlecontentText = System.String.Format("[b2b2b2ff]{0}[-]" , titlecontentText)
		timeText = System.String.Format("[b2b2b2ff]{0}[-]" , timeText)
		
		tittle.gradientTop = Color(1,1,1,1)
		tittle.gradientBottom = Color(0.3608 , 0.3843 , 0.3960 , 1)
		readed.gameObject:SetActive(false)
		backG.gameObject:SetActive(true)
	else
		tittle.gradientTop = NGUIMath.HexToColor(0x9DFBFFFF)
		tittle.gradientBottom = NGUIMath.HexToColor(0x5DC2CAFF)
		
		readed.gameObject:SetActive(true)
		backG.gameObject:SetActive(false)
	end
	
	des.text = contentText
	tittle.text = titlecontentText
	if v.category == MailMsg_pb.MailType_User then
		local gov = itemMidInfoShow:Find("bg_gov")
		local baseTitle = itemMidInfoShow:Find("bg_gov/text (1)")
		--[[
			bug：【领主邮件】抬头错误  ID： 1003120
			baseid 为1002的邮件，不应该带有[战区邮件]的title
		]]
		if v.baseid == 1002 then
			baseTitle.localScale = Vector3(1,1,1)
		else
			baseTitle.localScale = Vector3(0,1,1)
		end
			
		if gov ~= nil then
			GOV_Util.SetGovNameUI(gov,v.fromOfficialId,v.fromGuildOfficialId,true,v.militaryRankId)
		end
		
	end

	mtime.text = timeText
	
	local attchItem = item.transform:Find("bg_list/icon_attachment")
	if not v.taked and v.hasattach then
		attchItem.gameObject:SetActive(true)
	else
		attchItem.gameObject:SetActive(false)
	end
	
	SetClickCallback(item.gameObject , function(go)
		RequestReadMail(v)
	end)
	
	
	local checkbox = item.transform:Find("bg_list/checkbox"):GetComponent("UIToggle")
	checkbox.value = flag
	SetClickCallback(checkbox.gameObject , function(go)
		mailDataList[dataIndex].flag = checkbox.value
		MailOperatorBox()
	end)
	--[[EventDelegate.Set(checkbox.onChange , EventDelegate.Callback(function(go , value)
		mailDataList[dataIndex].flag = checkbox.value
		MailOperatorBox()
	end))]]
	
	--save 
	local saveFlag = item.transform:Find("bg_list/bg_star"):GetComponent("UIButton")
	local flag = item.transform:Find("bg_list/bg_star/star")
	if v.saved then
		flag.gameObject:SetActive(true)
		SetClickCallback(saveFlag.gameObject , function(go)
			CancalSaveMail(v.id)
			flag.gameObject:SetActive(false)
		end)
	else
		flag.gameObject:SetActive(false)
		SetClickCallback(saveFlag.gameObject , function(go)
			SaveMail(v.id)
			flag.gameObject:SetActive(true)
		end)
	end
	
end

local mobaConfig = 
{
	[MailMsg_pb.MailType_Moba] = {tab = "btn_tabtype_5" , content = "content_moba"},
	[MailMsg_pb.MailType_GuildMoba] = {tab = "btn_tabtype_6" , content = "content_guildmoba"},
}
local function ShowMobaTypeContent()
	_ui.Title.text = TextMgr:GetText("maincity_ui5")
	local mailmainUI = GetMailUI("Container")
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_3").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_1").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_2").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_4").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_5").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_6").gameObject:SetActive(false)
	mailmainUI.go:Find(string.format("bg_frane/bg_tab/%s" ,mobaConfig[curTabSelect].tab)).gameObject:SetActive(true)
	
	--curTabSelect = MailMsg_pb.MailType_Moba
	curSubTabSelect = 1
	mailDataList = MailListData.GetMailDataByTypeWithFlag(curTabSelect, 0)
	local datalength = mailDataList == nil and 0 or #mailDataList
	
	local noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	noitem.gameObject:SetActive(datalength <= 0)
	
	mailContent = mailmainUI.go:Find(string.format("bg_frane/bg_mid/%s" , mobaConfig[curTabSelect].content))
	mailContent.gameObject:SetActive(true)
	local contentScrollview = mailContent:Find("Scroll View"):GetComponent("UIScrollView")
	local optGridTransform = mailContent:Find("Scroll View/OptGrid"):GetComponent("UIGrid")
	
	while optGridTransform.transform.childCount > 0 do
	    GameObject.DestroyImmediate(optGridTransform.transform:GetChild(0).gameObject)
    end
	
	for i=1 , datalength ,1 do
		local item = NGUITools.AddChild(optGridTransform.gameObject, _ui.moba_mailInfoItem.gameObject).transform
		UpdateMailListItem(item , 0 , i-1)
		item:Find("bg_list/bg_star").gameObject:SetActive(false)
		
		--buff
		local v = mailDataList[i].data
		local mailCfgData = TableMgr:GetMailCfgData(v.baseid)
		local buffGrid = item:Find("bg_list/Grid"):GetComponent("UIGrid")
		local buffItem = buffGrid.transform:GetChild(0)
		buffGrid.gameObject:SetActive(mailCfgData.buff == 1 and v.contentparams ~= nil and v.contentparams[4] ~= nil and v.contentparams[4].value ~= "")
		if mailCfgData.buff == 1 and v.contentparams ~= nil and v.contentparams[4] ~= nil and v.contentparams[4].value ~= "" then
			local buffChildCount = buffGrid.transform.childCount
			local buffStr = string.split(v.contentparams[4].value , ";")
			for i = 1,#(buffStr) do
				local buff = nil
				if i > buffChildCount then
					buff = NGUITools.AddChild(buffGrid.gameObject , buffItem.gameObject).transform
				else
					buff = buffGrid.transform:GetChild(i-1).transform
				end
				
				local buffCfg = TableMgr:GetSlgBuffData(tonumber(buffStr[i]))
				buff:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", buffCfg.icon)
				SetClickCallback(buff.gameObject  , function()
					Tooltip.ShowMobaBuffTips(buffCfg.id)
				end)
			end
			buffGrid:Reposition()
		end
	end
	optGridTransform:Reposition()
	
	_ui.giftGrid = optGridTransform.transform
	--function UpdateMailListItem(item , index , realInde)
	----update bottom button
	MailOperatorBox()
	
	local getAllItemBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_get"):GetComponent("UIButton")
	local items = MailListData.GetAllAttachItems(curTabSelect, 0)
	if items ~= nil and (#items) > 0 then
		getAllItemBtn.gameObject:SetActive(true)
	else
		getAllItemBtn.gameObject:SetActive(false)
	end
	
	local delReadBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_delread"):GetComponent("UIButton")
	local readedMails = MailListData.GetMailListByStatus(2, curTabSelect, 0)
	if readedMails ~= nil and (#readedMails) > 0 then
		delReadBtn.gameObject:SetActive(true)
	else
		delReadBtn.gameObject:SetActive(false)
	end

	local SelectAllBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_selectall"):GetComponent("UIButton")
	SelectAllBtn.gameObject:SetActive(datalength > 0)
	
	mailmainUI.go:Find("bg_frane/bg_bottom/btn_newmail").gameObject:SetActive(false)
end

local function ShowTypeContent(forceFresh , selTab, subSeltab)
	local mailmainUI = GetMailUI("Container")
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_3").gameObject:SetActive(true)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_1").gameObject:SetActive(true)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_2").gameObject:SetActive(true)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_4").gameObject:SetActive(true)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_5").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_tab/btn_tabtype_6").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_mid/content_moba").gameObject:SetActive(false)
	mailmainUI.go:Find("bg_frane/bg_mid/content_guildmoba").gameObject:SetActive(false)
	
	print(forceFresh , selTab , curTabSelect , subSeltab , curSubTabSelect)
	if not forceFresh and selTab == curTabSelect and subSeltab == curSubTabSelect then
		return
	end
	
	if curTabSelect == MailMsg_pb.MailType_Moba or curTabSelect == MailMsg_pb.MailType_GuildMoba then
		ShowMobaTypeContent()
		return
	end
	
	if selTab == 3 then
		_ui.Title.text = TextMgr:GetText("mail_ui3")
	elseif selTab == 1 then
		_ui.Title.text = TextMgr:GetText("mail_ui2")
	elseif selTab == 2 then		
		_ui.Title.text = TextMgr:GetText("mail_ui4")
	elseif selTab == 4 then
		_ui.Title.text = TextMgr:GetText("mail_ui5")
	end
	--页签下子页签
	if selTab == 3 then
		SubTypeRed(3)
		_ui.reportPage1Bg:SetActive(false)
		_ui.reportPage2Bg:SetActive(false)
		_ui.reportPage3Bg:SetActive(false)
		_ui.reportPage4Bg:SetActive(false)
		if subSeltab == 1 then
			_ui.reportPage1Bg:SetActive(true)
		end
		if subSeltab == 2 then
			_ui.reportPage2Bg:SetActive(true)
		end
		if subSeltab == 3 then
			_ui.reportPage3Bg:SetActive(true)
		end
		if subSeltab == 4 then
			_ui.reportPage4Bg:SetActive(true)
		end
		SetClickCallback(_ui.reportPage1, function(go)
			ShowTypeContent(false, 3, 1)
		end)
		SetClickCallback(_ui.reportPage2, function(go)
			ShowTypeContent(false, 3, 2)
		end)
		SetClickCallback(_ui.reportPage3, function(go)
			ShowTypeContent(false, 3, 3)
		end)
		SetClickCallback(_ui.reportPage4, function(go)
			ShowTypeContent(false, 3, 4)
		end)
	end
	if selTab == 1 then
		SubTypeRed(1)
		_ui.systemPage1Bg:SetActive(false)
		_ui.systemPage2Bg:SetActive(false)
		if subSeltab == 1 then
			_ui.systemPage1Bg:SetActive(true)
		end
		if subSeltab == 2 then
			_ui.systemPage2Bg:SetActive(true)
		end
		SetClickCallback(_ui.systemPage1, function(go)
			ShowTypeContent(false, 1, 1)
		end)
		SetClickCallback(_ui.systemPage2, function(go)
			ShowTypeContent(false, 1, 2)
		end)
	end

	--local mailmainUI = GetMailUI("Container")
	curTabSelect = selTab
	curSubTabSelect = subSeltab
	if curTabSelect == 4 then --save tab
		mailDataList = MailListData.GetSavedMailByDefaultFlag()
	else
		if curTabSelect == 3 or curTabSelect == 1 then
			mailDataList = MailListData.GetMailDataByTypeWithFlag(curTabSelect, curSubTabSelect)
		else
			mailDataList = MailListData.GetMailDataByTypeWithFlag(curTabSelect, 0)
		end
	end
	local datalength = mailDataList == nil and 0 or #mailDataList
	
	local noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	noitem.gameObject:SetActive(datalength <= 0)
	
	local tabName = "bg_frane/bg_tab/btn_tabtype_" .. selTab
	mailContent = mailmainUI.go:Find(tabName):GetComponent("UIToggledObjects").activate:get_Item(0).transform
	local contentScrollview = mailContent:Find("Scroll View"):GetComponent("UIScrollView")
	local optGridTransform = mailContent:Find("Scroll View/OptGrid")
	if optGridTransform ~= nil then
		GameObject.DestroyImmediate(optGridTransform.gameObject)
	end
	
	local wrapParam = {}
	wrapParam.OnInitFunc = UpdateMailListItem
	wrapParam.itemSize = 87
	wrapParam.minIndex = -(datalength-1)
	wrapParam.maxIndex = 0
	wrapParam.itemCount = datalength < 5 and datalength or 5-- 预设项数量。 -1为实际显示项数量
	wrapParam.cellPrefab = _ui.mailInfoItem
	wrapParam.localPos = Vector3(0 , 114 , 0)
	wrapParam.cullContent = false
	wrapParam.moveDir = 1--horizal
	UIUtil.CreateWrapContent(contentScrollview	, wrapParam , function(optGridTrf)
		_ui.giftGrid = optGridTrf
		--optGridTrf:GetComponent("UIWrapContent"):SortBasedOnScrollMovement()
	end)
	contentScrollview:ResetPosition()
	
	--[[
	if optGridTransform ~= nil then
		GameObject.DestroyImmediate(optGridTransform.gameObject)
	end
	
	if optGridTransform == nil then
		local wrapParam = {}
		wrapParam.OnInitFunc = UpdateMailListItem
		wrapParam.itemSize = 97
		wrapParam.minIndex = -(datalength-1)
		wrapParam.maxIndex = 0
		wrapParam.itemCount = datalength < 5 and datalength or 5-- 预设项数量。 -1为实际显示项数量
		wrapParam.cellPrefab = _ui.mailInfoItem
		wrapParam.localPos = Vector3(0 , 114 , 0)
		wrapParam.cullContent = false
		wrapParam.moveDir = 1--horizal
		UIUtil.CreateWrapContent(contentScrollview	, wrapParam , function(optGridTrf)
			_ui.giftGrid = optGridTrf
			--optGridTrf:GetComponent("UIWrapContent"):SortBasedOnScrollMovement()
			contentScrollview:ResetPosition()
		end)
	else
		_ui.giftGrid = optGridTransform
		local wrap = optGridTransform:GetComponent("UIWrapContent")
		wrap.minIndex = -(datalength-1)
		wrap.maxIndex = 0
		wrap:SortBasedOnScrollMovement()
		contentScrollview:ResetPosition()
	end
	]]
	----update bottom button
	MailOperatorBox()
	
	local getAllItemBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_get"):GetComponent("UIButton")
	local items-- = MailListData.GetAllAttachItems(curTabSelect)
	if curTabSelect == 4 then
		items = MailListData.GetAllSavedAttachItems()
	else
		if curTabSelect == 3 or curTabSelect == 1 then
			items = MailListData.GetAllAttachItems(curTabSelect, curSubTabSelect)
		else
			items = MailListData.GetAllAttachItems(curTabSelect, 0)
		end
	end
	
	if items ~= nil and (#items) > 0 then
		getAllItemBtn.gameObject:SetActive(true)
	else
		getAllItemBtn.gameObject:SetActive(false)
	end
	
	local delReadBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_delread"):GetComponent("UIButton")
	local readedMails
	if curTabSelect == 4 then
		readedMails = MailListData.GetMailSavedList(2)
	else
		if curTabSelect == 3 or curTabSelect == 1 then
			readedMails = MailListData.GetMailListByStatus(2, curTabSelect, curSubTabSelect)
		else
			readedMails = MailListData.GetMailListByStatus(2, curTabSelect, 0)
		end
	end
	if readedMails ~= nil and (#readedMails) > 0 then
		delReadBtn.gameObject:SetActive(true)
	else
		delReadBtn.gameObject:SetActive(false)
	end

	local SelectAllBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_selectall"):GetComponent("UIButton")
	SelectAllBtn.gameObject:SetActive(datalength > 0)
	
	mailmainUI.go:Find("bg_frane/bg_bottom/btn_newmail").gameObject:SetActive(true)
end

--刷新邮件主界面各页签状态和当前页内容
MainMailNotify =  function()
	--print("main mail noti push")
	local mailmainUI = GetMailUI("Container")
	UpdateTabNewNumber()
	
	if mailmainUI.Tab[curTabSelect] then
		mailmainUI.Tab[curTabSelect]:Set(true)
	end
	if mailmainUI.Notify.updateContent ~= nil then
		
		mailmainUI.Notify.updateContent(true , curTabSelect, curSubTabSelect)
	end
end

local function InitUI()
	--邮件主界面
	local uiContainer = {}
	uiContainer.go = transform:Find("Container")
	uiContainer.name = "Container"
	uiContainer.NotifyPush = MainMailNotify
	uiContainer.Notify = {}
	uiContainer.Notify.sysNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_1/Animation/bg_num")--mailmainUI:Find("bg_frane/bg_tab/btn_tabtype_5/bg_num/num"):GetComponent("UILabel")
	uiContainer.Notify.reportNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_3/Animation/bg_num")
	uiContainer.Notify.userNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_2/Animation/bg_num")
	uiContainer.Notify.favNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4/Animation/bg_num")
	uiContainer.Notify.updateContent = ShowTypeContent
	uiContainer.script = Mail
	uiContainer.Tab = {}
	uiContainer.Tab[1] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_1"):GetComponent("UIToggle")
	uiContainer.Tab[3] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_3"):GetComponent("UIToggle")
	uiContainer.Tab[2] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_2"):GetComponent("UIToggle")
	uiContainer.Tab[4] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4"):GetComponent("UIToggle")
	uiContainer.Tab[5] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_5"):GetComponent("UIToggle")
	uiContainer.panelBox = {}
	uiContainer.panelBox.tweenScale = transform:Find("Container/bg_frane/Panel_box/bg_box"):GetComponent("TweenScale")
	uiContainer.panelBox.tweenPos = transform:Find("Container/bg_frane/Panel_box/bg_box"):GetComponent("TweenPosition")
	uiContainer.panelBox.tweenAlpha = transform:Find("Container/bg_frane/Panel_box/bg_box"):GetComponent("TweenAlpha")
	uiContainer.btnGroup = {}
	uiContainer.btnGroup.go = transform:Find("Container/bg_frane/bg_bottom/operatorBtn")
	uiContainer.btnGroup.delBtn = transform:Find("Container/bg_frane/bg_bottom/operatorBtn/btn_del"):GetComponent("UIButton")
	uiContainer.btnGroup.markBtn = transform:Find("Container/bg_frane/bg_bottom/operatorBtn/btn_mark"):GetComponent("UIButton")
	uiContainer.delReadBtn = transform:Find("Container/bg_frane/bg_bottom/btn_delread"):GetComponent("UIButton")
	table.insert(mailUI , uiContainer)
	
	--邮件阅读界面
	local uiMailDoc = {}
	uiMailDoc.go = transform:Find("MailDoc")
	uiMailDoc.name = "MailDoc"
	uiMailDoc.NotifyPush = nil
	uiMailDoc.Notify = nil
	uiMailDoc.script = MailDoc
	--table.insert(mailUI , uiMailDoc)
	
	--写邮件界面
	local uiMailNew = {}
	uiMailNew.go = transform:Find("MailNew")
	uiMailNew.name = "MailNew"
	uiMailNew.NotifyPush = nil
	uiMailNew.Notify = nil
	uiMailNew.script = MailNew
	--table.insert(mailUI , uiMailNew)
	
	--侦查报告界面
	local uiMailReportSpyonDoc = {}
	uiMailReportSpyonDoc.go = transform:Find("Mail-spyon")
	uiMailReportSpyonDoc.name = "MailReportSpyonDoc"
	uiMailReportSpyonDoc.NotifyPush = nil
	uiMailReportSpyonDoc.Notify = nil
	uiMailReportSpyonDoc.script = MailReportSpyonDoc
	--table.insert(mailUI , uiMailReportSpyonDoc)
	
	--新战报
	local uiMailReportDocNew = {}
	uiMailReportDocNew.go = transform:Find("MailPve")
	uiMailReportDocNew.name = "MailReportDocNew"
	uiMailReportDocNew.NotifyPush = nil
	uiMailReportDocNew.Notify = nil
	uiMailReportDocNew.script = MailReportDocNew
	--table.insert(mailUI , uiMailReportDocNew)

	_ui.Title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
	_ui.reportPage1 = transform:Find("Container/bg_frane/bg_mid/content_report/page1").gameObject
	_ui.reportPage2 = transform:Find("Container/bg_frane/bg_mid/content_report/page2").gameObject
	_ui.reportPage3 = transform:Find("Container/bg_frane/bg_mid/content_report/page3").gameObject
	_ui.reportPage4 = transform:Find("Container/bg_frane/bg_mid/content_report/page4").gameObject
	_ui.reportPage1Bg = transform:Find("Container/bg_frane/bg_mid/content_report/page1/selected effect").gameObject
	_ui.reportPage2Bg = transform:Find("Container/bg_frane/bg_mid/content_report/page2/selected effect").gameObject
	_ui.reportPage3Bg = transform:Find("Container/bg_frane/bg_mid/content_report/page3/selected effect").gameObject
	_ui.reportPage4Bg = transform:Find("Container/bg_frane/bg_mid/content_report/page4/selected effect").gameObject
	_ui.reportPage1Red = transform:Find("Container/bg_frane/bg_mid/content_report/page1/red dot").gameObject
	_ui.reportPage2Red = transform:Find("Container/bg_frane/bg_mid/content_report/page2/red dot").gameObject
	_ui.reportPage3Red = transform:Find("Container/bg_frane/bg_mid/content_report/page3/red dot").gameObject
	_ui.reportPage4Red = transform:Find("Container/bg_frane/bg_mid/content_report/page4/red dot").gameObject

	_ui.systemPage1 = transform:Find("Container/bg_frane/bg_mid/content_system/page1").gameObject
	_ui.systemPage2 = transform:Find("Container/bg_frane/bg_mid/content_system/page2").gameObject
	_ui.systemPage1Bg = transform:Find("Container/bg_frane/bg_mid/content_system/page1/selected effect").gameObject
	_ui.systemPage2Bg = transform:Find("Container/bg_frane/bg_mid/content_system/page2/selected effect").gameObject
	_ui.systemPage1Red = transform:Find("Container/bg_frane/bg_mid/content_system/page1/red dot").gameObject
	_ui.systemPage2Red = transform:Find("Container/bg_frane/bg_mid/content_system/page2/red dot").gameObject
end

function OpenMailUI(uiName)
	if mailUI then
		for _ , v in pairs(mailUI) do
			if v.name == uiName then
				v.go.gameObject:SetActive(true)
				v.script.OpenUI()
			else
				v.script.CloseUI()
				v.go.gameObject:SetActive(false)
			end
		end
	end
end

function GetMailUI(uiName)
	if mailUI then
		for _ , v in pairs(mailUI) do
			if v.name == uiName then
				return v
			end
		end
	end
	return nil
end



function Init(mailTransform)
	curRealIndex = 0
	local mainMailUI = GetMailUI("Container")
	--_ui.mailListGrid = mainMailUI.go:Find("bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	--_ui.mailListScrollView = mainMailUI.go:Find("bg_frane/Scroll View"):GetComponent("UIScrollView")
	--_ui.mailListGrid = mainMailUI.go:Find("bg_frane/Scroll View/OptGrid"):GetComponent("UIWrapContent")
	--_ui.mailListGrid.onInitializeItem = UpdateMailListItem
	--svPos = _ui.mailListScrollView.transform.localPosition

	
	local closeBtn = mainMailUI.go:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		--GUIMgr:CloseMenu("Mail")
		Hide()
	end)
	SetClickCallback(mainMailUI.go.gameObject , function(go)
		--GUIMgr:CloseMenu("Mail")
		Hide()
	end)
	
	--tab btn
	local tabBtnSys = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_1"):GetComponent("UIButton")
	SetClickCallback(tabBtnSys.gameObject , function(go)
		--UpdateTabContent(false , 1)--MailMsg_pb.MailTypeId.MailType_System)
		ShowTypeContent(false , 1, 1)
	end)
	local tabBtnReport = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_3"):GetComponent("UIButton")
	SetClickCallback(tabBtnReport.gameObject , function(go)
		--UpdateTabContent(false , 3)--MailMsg_pb.MailTypeId.MailType_Report
		ShowTypeContent(false , 3, 1)
	end)
	local tabBtnPlayer = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_2"):GetComponent("UIButton")
	SetClickCallback(tabBtnPlayer.gameObject , function(go)
		--UpdateTabContent(false , 2)--MailMsg_pb.MailTypeId.MailType_User
		ShowTypeContent(false , 2, 0)
	end)
	local tabBtnfavorate = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_4"):GetComponent("UIButton")
	SetClickCallback(tabBtnfavorate.gameObject , function(go)
		--UpdateTabContent(false , 4)--MailMsg_pb.MailTypeId.MailType_Save)
		ShowTypeContent(false , 4, 0)
	end)
	
	--selecet all btn
	local SelectAllBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_selectall"):GetComponent("UIButton")
	SetClickCallback(SelectAllBtn.gameObject , SelectAllBtnClick)
	
	--write mail btn
	local newMailBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_newmail"):GetComponent("UIButton")
	SetClickCallback(newMailBtn.gameObject , function(go)
		MailNew.Show()
	end)
	--del btn
	local delReadBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_delread"):GetComponent("UIButton")
	SetClickCallback(delReadBtn.gameObject , function(go)
		print("btn_delread : " .. curTabSelect)
		local readedMails
		if curTabSelect == 4 then
			readedMails = MailListData.GetMailSavedList(2)
		else
			if curTabSelect == 3 or curTabSelect == 1 then
				readedMails = MailListData.GetMailListByStatus(2, curTabSelect, curSubTabSelect)
			else
				readedMails = MailListData.GetMailListByStatus(2, curTabSelect, 0)
			end
		end
		DeleteMail(readedMails)
	end)
	--getall btn
	local getAllItemBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_get"):GetComponent("UIButton")
	SetClickCallback(getAllItemBtn.gameObject , function(go)
		print("btn_getall")
		GetAllAttachItem()
	end)
	
	--operatorbox
	local opbox = mainMailUI.go:Find("bg_frane/Panel_box")
	local opBox_del = opbox:Find("bg_box/btn_del"):GetComponent("UIButton")
	SetClickCallback(opBox_del.gameObject , function(go)
		DeleteMail()
	end)
	
	local opBox_mark = opbox:Find("bg_box/btn_mark"):GetComponent("UIButton")
	SetClickCallback(opBox_mark.gameObject , function(go)
		MarkMail()
	end)
	
	--operatorbox1 邮件UI优化  ID：1000237
	SetClickCallback(mainMailUI.btnGroup.delBtn.gameObject , function(go)
		DeleteMail()
	end)
	SetClickCallback(mainMailUI.btnGroup.markBtn.gameObject , function(go)
		MarkMail()
	end)
	
end


local function InitMailUI()
	for _ , v in pairs(mailUI) do
		if v.script ~= nil then
			--print(v.name)
			v.script.Init(transform)
		end
	end 
end

function OpenUI()
print("open contatiner")
	if _ui.giftGrid == nil then
		return
	end

	local childCount = _ui.giftGrid.childCount
	for i=0 , childCount - 1 , 1 do
		local item = _ui.giftGrid.transform:GetChild(i)
		MailListItemReaded(item)
	end
	
	local mainMailUI = GetMailUI("Container")
	mainMainUI.go.gameObject:SetActive(true)
	--update btn status
	MailOperatorBox()
end

function CloseUI()
	
end

function Awake()
	
end

function OpenMenu()
	if jumpMailMenu ~= nil and jumpMailMenu ~= "" then
		
	print("=----"..jumpMailMenu)
		OpenMailUI(jumpMailMenu)
	else
	
	print("-----Container")
		OpenMailUI("Container")
	end
end

function Start()
print("mail start")
end

function Hide()
	Global.CloseUI(_M)
	ResBar.OnMenuClose("Mail")
end

function Close()
	local mainMailUI = GetMailUI("Container")
	if mainMailUI ~= nil then
		for i=1 , 5 , 1 do
			mainMailUI.Tab[i]:Set(false)
		end
	end
	for _ , v in pairs(mailUI) do
		v.script.CloseUI()
		v.go.gameObject:SetActive(false)

	end
	mailUI = nil
    _ui = nil
	MainCityUI.UpdateMailIcon(false)
	curTabSelect = 3--MailMsg_pb.MailTypeId.MailType_Report
	newTab = false
	jumpMailMenu = nil
	curRealIndex = 0
	mailDataList = nil
	MailListData.RemoveListener(NotifyMail)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
end

function LoadUI()
	_ui = {}
	_ui.mailInfoItem = transform:Find("MailInfo")
	_ui.moba_mailInfoItem = transform:Find("MailInfo_moba")
	--_ui.moba_mailInfoItemBuff = transform:Find("MailInfo_moba/buff_icon")
	
	mailUI = {}
	InitUI()
	InitMailUI()
	
	if newTab then
		curTabSelect = MailListData.GetFirstNewMail()
		if curTabSelect == 0 then
			curTabSelect = 3
		end
	end
	
	MainCityUI.UpdateMailIcon(false)
	if MailListData.IsNeedUpdate() then
		local req = MailMsg_pb.MsgUserMailListRequest()
		Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailListRequest, req, MailMsg_pb.MsgUserMailListResponse, function(msg)
			MailListData.UpdateData(msg.maillist)
			--OpenMailUI("Container")
			OpenMenu()
			MainMailNotify()
			MailListData.NeedUpdate(false)
		end)
	else
		--OpenMailUI("Container")
		OpenMenu()
		MainMailNotify()
	end
	
	MailListData.AddListener(NotifyMail)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	
end

function ShowMoba()
	SetTabSelect(MailMsg_pb.MailType_Moba)
	Show()
end

function ShowGuildMoba()
	SetTabSelect(MailMsg_pb.MailType_GuildMoba)
	Show()
end

function Show()
	Global.OpenUI(_M)
	MailListData.ClearMailPush()
	LoadUI()
	ResBar.OnMenuOpen("Mail")
end

function DirectShow(mailid)
	RequestReadMailDirect(mailid , function(mailmsg)
		ReadMail(mailmsg.mail , mailmsg ,true )
		--[[Global.OpenUI(_M)
		_ui = {}
		mailUI = {}
		
		local uiMailDoc = {}
		uiMailDoc.go = transform:Find("MailDoc")
		uiMailDoc.name = "MailDoc"
		uiMailDoc.NotifyPush = nil
		uiMailDoc.Notify = nil
		uiMailDoc.script = MailDoc
		--table.insert(mailUI , uiMailDoc)
		
		--写邮件界面
		local uiMailNew = {}
		uiMailNew.go = transform:Find("MailNew")
		uiMailNew.name = "MailNew"
		uiMailNew.NotifyPush = nil
		uiMailNew.Notify = nil
		uiMailNew.script = MailNew
		--table.insert(mailUI , uiMailNew)
		--侦查报告界面
		local uiMailReportSpyonDoc = {}
		uiMailReportSpyonDoc.go = transform:Find("Mail-spyon")
		uiMailReportSpyonDoc.name = "MailReportSpyonDoc"
		uiMailReportSpyonDoc.NotifyPush = nil
		uiMailReportSpyonDoc.Notify = nil
		uiMailReportSpyonDoc.script = MailReportSpyonDoc
		--table.insert(mailUI , uiMailReportSpyonDoc)
		--新战报
		local uiMailReportDocNew = {}
		uiMailReportDocNew.go = transform:Find("MailPve")
		uiMailReportDocNew.name = "MailReportDocNew"
		uiMailReportDocNew.NotifyPush = nil
		uiMailReportDocNew.Notify = nil
		uiMailReportDocNew.script = MailReportDocNew
		--table.insert(mailUI , uiMailReportDocNew)
		InitMailUI()
		
		--transform:Find("Container").gameObject:SetActive(false)
		MailListData.SubNotifyCount()
		ReadMail(mailmsg.mail , mailmsg ,true )]]
	end , true)
	
end

function WriteTo(to, callback,customcallback)
	--Mail.SetJumMenu("MailNew")
	local sendMailData = {}
	sendMailData.fromname = to
	MailNew.SetMailData(sendMailData)
	MailNew.SetCloseCallBack(callback)
	MailNew.SetCustomCallBack(customcallback)
	--Global.OpenUI(_M)
	--Show()
	MailNew.Show(sendMailData)
end

function SimpleWriteTo(to,customcallback)
    WriteTo(to, function()
        Global.CloseUI(_M)
    end,customcallback)
end
