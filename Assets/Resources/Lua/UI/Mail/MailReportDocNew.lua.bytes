module("MailReportDocNew", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String
local GameObject = UnityEngine.GameObject
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local AudioMgr = Global.GAudioMgr
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local formationPrefab
local formationSmall
local targatFormationData
local selfFormationData
local bgStartPos

local directShow = false
local curMailId
local curReadMailMsg
local mailContent

local reportWinLose


--local reportMsg


local interface={
    ["Chat"] = Chat,
    ["Share_btn"] = "btn_slg",
    ["Channel_world"] = ChatMsg_pb.chanel_world,
    ["Channel_team"] = ChatMsg_pb.chanel_guild,
    ["Channel_private"] = ChatMsg_pb.chanel_private,
}

local interface_moba={
    ["Chat"] = MobaChat,
    ["Share_btn"] = "btn_moba",
    ["Channel_world"] = ChatMsg_pb.chanel_MobaWorld,
    ["Channel_team"] = ChatMsg_pb.chanel_MobaTeam,
    ["Channel_private"] = ChatMsg_pb.chanel_MobaPrivate,
    
}

local interface_guildmoba={
    ["Chat"] = GuildMobaChat,
    ["Share_btn"] = "btn_moba",
    ["Channel_world"] = ChatMsg_pb.chanel_GuildMobaWorld,
    ["Channel_team"] = ChatMsg_pb.chanel_GuildMobaTeam,
    ["Channel_private"] = 0,
    
}

local function GetInterface(interface_name , category)
    if category == MailMsg_pb.MailType_Moba then
        return interface_moba[interface_name]
    elseif category == MailMsg_pb.MailType_GuildMoba then
        return interface_guildmoba[interface_name]
	else
		return interface[interface_name]
    end
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	
	Tooltip.HideItemTip()
end


function GetBattleResult(mailid)
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	
end

function GetReadMailData()
	return MailListData.GetMailDataById(curMailId)
end

function GetReadMailDataByid(id)
    return MailListData.GetMailDataById(curMailId)
end


function MailReportGoMap(posx , posy , mailCategory)
	if mailCategory == MailMsg_pb.MailType_Moba then
		MobaChat.GoMap(posx , posy)
		--[[Mail.Hide()
		local offx , offy = MobaMain.MobaMinPos()
		
		MobaMain.LookAt(posx+ offx , posy+offy)
		MobaMain.SelectTile(posx+ offx , posy+offy)]]
	elseif mailCategory == MailMsg_pb.MailType_GuildMoba then
		GuildMobaChat.GoMap(posx , posy)
	else
		Chat.GoMap(posx , posy)
	end
end

function GetWinLose(readMailData , reportMsg)
	local text = ""
	local winlose = 1
	if readMailData.subtype == Mail.MailReportType.MailReport_player then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_player_win_Title")--"攻击胜利"
		else
			text = TextMgr:GetText("Mail_attack_player_fail_Title")--"攻击失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_defence then
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_player_win_Title")--"防守成功"
		else
			text = TextMgr:GetText("Mail_defence_player_fail_Title")--"防守失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robres then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_robres_win_Title")--"采集抢夺成功"
		else
			text = TextMgr:GetText("Mail_robres_fail_Title")--"采集抢夺失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robresdefence then --"抢夺采集防御"
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_takerers_win_Title")--"采集防御成功"
		else
			text = TextMgr:GetText("Mail_defence_takerers_fail_Title")--"采集防御失败"
			winlose = 0 
		end
	
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robclamp then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_robcamp_win_Title")--"抢夺扎营成功"
		else
			text = TextMgr:GetText("Mail_robcamp_fail_Title")--"抢夺扎营失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robcampdefence then 
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_robcamp_win_Title")--"扎营防御成功"
		else
			text = TextMgr:GetText("Mail_defence_robcamp_fail_Title")--"扎营防御失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_actmonster then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_ActMonster_win_Title")--进攻跑车成功
		else
			text = TextMgr:GetText("Mail_ActMonster_fail_Title")--进攻跑车失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_guildmonsterRepoty then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_union_GVE_Monster_win_Title")--进攻联盟野怪成功
		else
			text = TextMgr:GetText("Mail_union_GVE_Monster_fail_Title")--进攻联盟野怪失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_siegeAttack then
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("RebelArmyAttack_ui43"), reportMsg.misc.siegeShow.wave)--叛军攻城防御成功
		else
			text = String.Format(TextMgr:GetText("RebelArmyAttack_ui48"), reportMsg.misc.siegeShow.wave)--叛军攻城防御失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_siegeHelp then
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("RebelArmyAttack_ui56"), reportMsg.misc.siegeShow.wave, reportMsg.contentparams[2].value)--叛军攻城防御成功
		else
			text = String.Format(TextMgr:GetText("RebelArmyAttack_ui55"), reportMsg.misc.siegeShow.wave, reportMsg.contentparams[2].value)--叛军攻城防御失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_monster then
		if reportMsg.misc.result.winteam == 2 then
			if reportMsg.misc.result.input.user.team2[1].seType == Common_pb.SceneEntryType_WorldMonster then
				text = TextMgr:GetText("Mail_attack_actmonster1_fail_Title")
			else
				text = TextMgr:GetText("Mail_attack_monster_fail_Title")
			end
			winlose = 0
		else
			if reportMsg.misc.result.input.user.team2[1].seType == Common_pb.SceneEntryType_WorldMonster then
				text = TextMgr:GetText("Mail_attack_actmonster1_win_Title")
			else
				text = TextMgr:GetText("Mail_attack_monster_win_Title")
			end
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_fort then
		text = TextMgr:GetText("Mail_attack_fort_win_Title")
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_defGovt then 
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_GOV_win_Title")--防守政府成功
		else
			text = TextMgr:GetText("Mail_defence_GOV_fail_Title")--防守政府失败
			winlose = 0
		end
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_atkGovt then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_GOV_win_Title")--攻击政府成功
		else
			text = TextMgr:GetText("Mail_attack_GOV_fail_Title")--攻击政府失败
			winlose = 0
		end
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_defTurret then 
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_GOV_win_Title1")--防守炮台成功
		else
			text = TextMgr:GetText("Mail_defence_GOV_fail_Title1")--防守炮台失败
			winlose = 0
		end
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_atkTurret then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_GOV_win_Title1")--攻击炮台成功
		else
			text = TextMgr:GetText("Mail_attack_GOV_fail_Title1")--攻击炮台失败
			winlose = 0
		end		
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_gatherGovt then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_assemble_GOV_win_Title")--集结政府成功
		else
			text = TextMgr:GetText("Mail_assemble_GOV_fail_Title")--集结政府失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_gatherTurret then	
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_assemble_GOV_win_Title1")--集结炮台成功
		else
			text = TextMgr:GetText("Mail_assemble_GOV_fail_Title1")--集结炮台失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_atkEliter then	
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_EliteRebel_win_Title1")--集结精英野怪成功
		else
			text = TextMgr:GetText("Mail_attack_EliteRebel_fail_Title1")--集结精英野怪失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_atkStronghold then --进攻据点
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_Stronghold_win_Title")
		else
			text = TextMgr:GetText("Mail_attack_Stronghold_fail_Title")--
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_gathStronghold then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_assemble_Stronghold_win_Title")--集结据点成功
		else
			text = TextMgr:GetText("Mail_assemble_Stronghold_fail_Title")--集结据点失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_defStronghold then
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_Stronghold_win_Title")--防守据点成功
		else
			text = TextMgr:GetText("Mail_defence_Stronghold_fail_Title")--防守据点失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_atkFortress then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_fortress_win_Title")--进攻要塞成功
		else
			text = TextMgr:GetText("Mail_attack_fortress_fail_Title")--进攻要塞失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_gathFortress then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_assemble_fortress_win_Title")--集结要塞成功
		else
			text = TextMgr:GetText("Mail_assemble_fortress_fail_Title")--集结要塞失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_defFortress then
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_fortress_win_Title")--防守要塞成功
		else
			text = TextMgr:GetText("Mail_defence_fortress_fail_Title")--防守要塞失败
			winlose = 0
		end

	elseif readMailData.subtype == Mail.MailReportType.MobaMailReport_player then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_player_win_Title")--"moba攻击玩家胜利"
		else
			text = TextMgr:GetText("Mail_attack_player_fail_Title")--"moba攻击玩家失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MobaMailReport_defence then
		if reportMsg.misc.result.winteam == 2 then
			text = TextMgr:GetText("Mail_defence_player_win_Title")--"moba防守成功"
		else
			text = TextMgr:GetText("Mail_defence_player_fail_Title")--"moba防守失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MobaMailReport_defBuild then
		local mailcfg = TableMgr:GetMailCfgData(readMailData.baseid)
		text = TextMgr:GetText(mailcfg.title)
		if reportMsg.misc.result.winteam == 2 then
			--text = TextMgr:GetText("Mail_defence_player_win_Title")--"moba防守成功"
		else
			--text = TextMgr:GetText("Mail_defence_player_fail_Title")--"moba防守失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MobaMailReport_atkBuild then
		local mailcfg = TableMgr:GetMailCfgData(readMailData.baseid)
		text = TextMgr:GetText(mailcfg.title)
		if reportMsg.misc.result.winteam == 1 then
			--text = TextMgr:GetText("Mail_defence_player_win_Title")--"moba进攻成功"
		else
			--text = TextMgr:GetText("Mail_defence_player_fail_Title")--"moba进攻失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReort_atkWorldCity then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_city_win_Title")	--"城市进攻成功"
		else
			text = TextMgr:GetText("Mail_attack_city_fail_Title")--"城市进攻失败"
			winlose = 0 
		end
	else
		local mailcfg = TableMgr:GetMailCfgData(readMailData.baseid)
		text = TextMgr:GetText(mailcfg.title)
		if reportMsg.misc.result.winteam == 2 then
			winlose = 0 
		end
    end
	
	return text , winlose
end

function GetArmyFace(team , armyIndex)
	if armyIndex < 1 or armyIndex > #team then
		return ""
	end
	
	local army = team[armyIndex]
	if army.monster ~= nil then
		if army.monster.monsterType == Common_pb.SceneEntryType_ActMonster then
			local acMonsterData = TableMgr:GetActMonsterRuleData(army.monster.monsterLevel)
			if acMonsterData ~= nil then
				return 200
				--return acMonsterData.picture
			end
        end
		
		if army.monster.monsterType == Common_pb.SceneEntryType_Monster or army.monster.monsterType == Common_pb.SceneEntryType_WorldMonster then
			return 888
		end
    end
	
    --fort
	if army.elite ~= nil and army.elite.eliteId ~= nil and army.elite.eliteId > 0 then
		local eliteid = army.elite.eliteId
		local eliteData = Global.GTableMgr:GetEliteRebelDataById(eliteid)
		if eliteData ~= nil then
			return eliteData.icon
		end
	end	
    if army.fort ~= nil and army.fort.subType ~= nil and army.fort.subType > 0 then        
        return 666 --叛军头像
	end
	
	if army.centerBuild ~= nil and army.centerBuild.uid ~= 0 then    
		if army.centerBuild.strongholdSubType > 0 then 
			return 888
		elseif army.centerBuild.fortressSubType > 0 then 
			return 888
		else
			return 777 --中央集团头像
		end
        
    end	

	if army.mobabuild ~= nil and army.mobabuild.uid > 0 then
		return 666
	end
	
	if army.worldCity ~= nil and army.worldCity.cityId > 0 then
		return 666
	end
	
	
	
	if army.user ~= nil and army.user.face ~= nil then
		return army.user.face
	end
	
	return ""
end

function GetReportShareTitle(reportMsg, readMailData_subtype)
	local title = ""
	local lenLimit = 15
	local vsStr = "  [ff0000]VS[-]  "
	
	local player1Guile = ""
	local strIndex = 1
	if reportMsg.misc.source.guildBanner ~= "" then
		player1Guile = "[f1cf63]【" .. reportMsg.misc.source.guildBanner .. "】[-]"
		strIndex = 13 + Global.utfstrlen(reportMsg.misc.source.guildBanner)
	end
	
	--local player1Guile = "[" .. 111 .. "]"
	local player1 = reportMsg.misc.result.input.user.team1[1].user.name
	if readMailData_subtype == Mail.MailReportType.MailReport_siegeAttack or readMailData_subtype == Mail.MailReportType.MailReport_siegeHelp then
		player1 = TextMgr:GetText("SiegeMonster_" .. reportMsg.misc.siegeShow.wave)
	end
	local play1Len = Global.utfstrlen(player1)

	local player1Str = ""
	if play1Len > 10 then
		player1Str = Global.GetSubString(player1,0, 10) .. ".."--string.sub(player1 , 1 , 10) .. ".."
	else
		player1Str = player1
	end
	player1Str = player1Guile .. player1Str
	
	--print(player1Str , play1Len , string.len(player1) )
	
	print("reportMsg.misc.target.guildBanner",reportMsg.misc.target.guildBanner)
	--Global.DumpMessage(reportMsg)
	local player2Guile = ""
	if reportMsg.misc.target.guildBanner ~= "" then
		player2Guile = "[f1cf63]【" .. reportMsg.misc.target.guildBanner .. "】[-]"
	end
	
	--local player1Guile = "[" .. 111 .. "]"
	local player2 = reportMsg.misc.result.input.user.team2[1].user.name
	if reportMsg.misc.result.input.user.team2[1].monster ~= nil and reportMsg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_ActMonster then--攻击炮车
		player2 = TextMgr:GetText(reportMsg.misc.target.name)
	end
	if reportMsg.misc.result.input.user.team2[1].monster ~= nil and (reportMsg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_Monster or
		reportMsg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_WorldMonster)then--攻击野怪
		local monBaseId = reportMsg.misc.result.input.user.team2[1].monster.monsterLevel
		local monsterData = Global.GTableMgr:GetMonsterRuleData(monBaseId)
		player2 = ""
		if monsterData ~= nil then
			player2 = Global.GTextMgr:GetText(monsterData.name)
		end
		print(player2 , monsterData.name)
	end

    --精英
	if reportMsg.misc.result.input.user.team2[1].elite ~= nil and reportMsg.misc.result.input.user.team2[1].elite.eliteId ~= nil and reportMsg.misc.result.input.user.team2[1].elite.eliteId > 0 then
		local eliteid = reportMsg.misc.result.input.user.team2[1].elite.eliteId
		local eliteData = Global.GTableMgr:GetEliteRebelDataById(eliteid)
		if eliteData ~= nil then
			player2 = TextMgr:GetText(eliteData.name)
		end
	end
	
	--fort rel
	if reportMsg.misc.result.input.user.team2[1].fort ~= nil and 
		reportMsg.misc.result.input.user.team2[1].fort.subType ~= nil and 
		reportMsg.misc.result.input.user.team2[1].fort.subType > 0 then--攻击要塞
        player2 = TextMgr:GetText("FortArmyName_"..reportMsg.misc.result.input.user.team2[1].fort.subType)
    end

	
	if reportMsg.misc.result.input.user.team2[1].centerBuild ~= nil then
		if reportMsg.misc.result.input.user.team2[1].user == nil or reportMsg.misc.result.input.user.team2[1].user.name == nil or
		reportMsg.misc.result.input.user.team2[1].user.name == "" then
			if reportMsg.misc.result.input.user.team2[1].centerBuild.strongholdSubType > 0 then -- 据点
				local strongHod = TableMgr:GetStrongholdRuleByID(reportMsg.misc.result.input.user.team2[1].centerBuild.strongholdSubType)
				player2 = strongHod and TextMgr:GetText(strongHod.name) or ""
			elseif reportMsg.misc.result.input.user.team2[1].centerBuild.fortressSubType > 0 then -- 要塞
				local fortress = TableMgr:GetFortressRuleByID(reportMsg.misc.result.input.user.team2[1].centerBuild.fortressSubType)
				player2 = fortress and TextMgr:GetText(fortress.name) or ""
			else
				if reportMsg.misc.result.input.user.team2[1].centerBuild.subType > 0 
					and reportMsg.misc.result.input.user.team2[1].seType ==  Common_pb.SceneEntryType_Turret then ---- 攻击炮台	
					player2 = TextMgr:GetText(TableMgr:GetTurretDataByid(reportMsg.misc.result.input.user.team2[1].centerBuild.subType).name)
				elseif reportMsg.misc.result.input.user.team2[1].seType ==  Common_pb.SceneEntryType_Govt then		--攻击政府
					player2 = TextMgr:GetText("GOV_ui7")
				end
			end
		end
	end
	--[[if reportMsg.misc.result.input.user.team2[1].centerBuild ~= nil and 
		reportMsg.misc.result.input.user.team2[1].centerBuild.uid ~= 0 then
			if  reportMsg.misc.result.input.user.team2[1].centerBuild.subType == 0 then -- 攻击政府			
				player2 = TextMgr:GetText("GOV_ui7")
			else -- 攻击炮台
				player2 = TextMgr:GetText(TableMgr:GetTurretDataByid(reportMsg.misc.result.input.user.team2[1].centerBuild.subType).name)
			end
	end]]
	
	if reportMsg.misc.result.input.user.team2[1].mobabuild ~= nil then
		if reportMsg.misc.result.input.user.team2[1].mobabuild.buildingid > 0 then
			player2 = TextMgr:GetText(TableMgr:GetMobaMapBuildingDataByID(reportMsg.misc.result.input.user.team2[1].mobabuild.buildingid).Name)
		end
	end
	
	if reportMsg.misc.result.input.user.team2[1].worldCity ~= nil then
		if reportMsg.misc.result.input.user.team2[1].worldCity.cityId > 0 then
			local cityName = TextMgr:GetText(TableMgr:GetWorldCityDataByID(reportMsg.misc.result.input.user.team2[1].worldCity.cityId).Name)
			player2 = System.String.Format(TextMgr:GetText("ui_citybattle_20") , cityName)
		end
	end

	local play2Len = Global.utfstrlen(player2)
	
	local player2Str = ""
	if play2Len > 10 then
		player2Str = Global.GetSubString(player2,0, 10) .. ".."--string.sub(player2 , 1 , 10) .. ".."
	else
		player2Str = player2
	end
	player2Str = player2Guile .. player2Str
	
	
	title = player1Str .. vsStr .. player2Str
	
	local OfficialId1 = 0
	local OfficialId2 = 0

	OfficialId1 = reportMsg.misc.result.input.user.team1[1].user.officialId
	if OfficialId1 == nil then
		OfficialId1 = 0
	end
	OfficialId2 = reportMsg.misc.result.input.user.team2[1].user.officialId
	if OfficialId2 == nil then
		OfficialId2 = 0
	end

	local guildOfficialId1 = 0
	local guildOfficialId2 = 0

	guildOfficialId1 = reportMsg.misc.result.input.user.team1[1].user.guildOfficialId
	if guildOfficialId1 == nil then
		guildOfficialId1 = 0
	end
	guildOfficialId2 = reportMsg.misc.result.input.user.team2[1].user.guildOfficialId
	if guildOfficialId2 == nil then
		guildOfficialId2 = 0
	end
	--print(player2Str , play2Len)
	return player1Str , vsStr , player2Str,OfficialId1,OfficialId2,guildOfficialId1,guildOfficialId2
end

function GetResportShowTeam(team)
	if team == nil or #team == 0 then
		return nil 
	end
	
	for i=1 , #team ,  1 do
		if team[i].main then
			return team[i]
		end
	end
	return team[1]
end

function BattleReportDebug(msg,s)
    local lf = BMFormation(nil)
	local sfd = msg.misc.result.input.user.team1[1]
	local tfd = msg.misc.result.input.user.team2[1]

	--进攻方
	local player1 = {}
	player1.Formation = {}
	player1.Armys = {}

	local myFormation = lf:PvPData2Formation(sfd)
	
	for i =1,8,1 do 
		--print(myFormation[i])
		if myFormation[i] ~= nil then
			player1.Formation[i] = BattleMove.Army2PhalanxType(myFormation[i])
		else
			player1.Formation[i] = 0
		end
    end
	
	for i=1 , #msg.misc.result.input.user.team1[1].army do
		local army = msg.misc.result.input.user.team1[1].army[i].army
		local attr = msg.misc.result.input.user.team1[1].army[i].attr
		local solider = Barrack.GetAramInfo(army.baseid , army.level)
	
		player1.Armys[i] = {}
		player1.Armys[i].ID = solider.UnitID
		player1.Armys[i].Count = army.num
		player1.Armys[i].Level = army.level
		player1.Armys[i].ArmyType = army.baseid
		player1.Armys[i].PhalanxType = BattleMove.Army2PhalanxType(solider.BarrackId)
		player1.Armys[i].HP = attr.hp
        player1.Armys[i].Exp = attr.exp
		player1.Armys[i].Attack = attr.atk
		player1.Armys[i].Armor = attr.def
		player1.Armys[i].Penetrate =0
	end


	local player2 = {}
	player2.Formation = {}
	player2.Armys = {}
	
	local defFormation = lf:PvPData2Formation(tfd)
	for i =1,8,1 do 
		if defFormation[i] ~= nil then
			player2.Formation[i] = BattleMove.Army2PhalanxType(defFormation[i])
		else
			player2.Formation[i] = 0
		end
    end
	
	for i=1 , #msg.misc.result.input.user.team2[1].army do
		local army = msg.misc.result.input.user.team2[1].army[i].army
		local attr = msg.misc.result.input.user.team2[1].army[i].attr
		local solider = Barrack.GetAramInfo(army.baseid , army.level)
		
		player2.Armys[i] = {}
		player2.Armys[i].ID = solider.UnitID
		player2.Armys[i].Count = army.num
		player2.Armys[i].Level = army.level
		player2.Armys[i].ArmyType = army.baseid
		player2.Armys[i].PhalanxType = BattleMove.Army2PhalanxType(solider.BarrackId)
		player2.Armys[i].Exp = attr.exp
		player2.Armys[i].HP = attr.hp
		player2.Armys[i].Attack = attr.atk
		player2.Armys[i].Armor = attr.def
		player2.Armys[i].Penetrate =0
    end

	
	for _,v in pairs(player1.Armys) do
		print(v.ID , v.Count)
	
    end
	
    if msg.misc.result.input.user.team2[1].recover == nil then
        msg.misc.result.input.user.team2[1].recover = false
    end
    if msg.misc.result.input.user.team1[1].recover == nil then
        msg.misc.result.input.user.team1[1].recover = false
    end

	local players = {}
	players[1] = Global.LuaToSLGPlayer(player1.Formation,player1.Armys,
	(msg.misc.result.input.user.team1[1].main and 1 or 0),
	(msg.misc.result.input.user.team1[1].recover and 1 or 0),
	(msg.misc.result.input.user.team1[1].userwar and 1 or 0),
	0,msg.misc.result.input.user.team1[1].injureLeftMax) 
	players[2] = Global.LuaToSLGPlayer(player2.Formation,player2.Armys,
	(msg.misc.result.input.user.team2[1].main and 1 or 0),
	(msg.misc.result.input.user.team2[1].recover and 1 or 0),
	(msg.misc.result.input.user.team2[1].userwar and 1 or 0),
	1,msg.misc.result.input.user.team2[1].injureLeftMax) 
	
    local pinfo = {}
    pinfo[1] = {}
    pinfo[1].name = msg.misc.result.input.user.team1[1].user.name
    pinfo[1].face = msg.misc.result.input.user.team1[1].user.face
    pinfo[2] = {}
    pinfo[2].name = msg.misc.result.input.user.team2[1].user.name
    pinfo[2].face = msg.misc.result.input.user.team2[1].user.face
	local hero = LuaToHeroBuffs(msg.misc.result)

	local strAConfig = Global.GetResaultConfigPer(msg.misc.result.input , 0)
	local strDConfig = Global.GetResaultConfigPer(msg.misc.result.input , 1)
	local strPhalanxConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvePhalanxConfig).value  
    if s == nil then
	    Global.StartSLGPVP_Debug(players,pinfo,hero,msg.misc.result.input.user.seed , nil ,nil , strAConfig , strDConfig , strPhalanxConfig)    
	else
	    Global.StartSLGPVPSimple_Debug(players,pinfo,hero,msg.misc.result.input.user.seed , msg.misc.result.input) 
	end
end


function ShowEmbattle(reportMsg)
	selfFormationData = reportMsg.misc.result.input.user.team1[1]
	targatFormationData = reportMsg.misc.result.input.user.team2[1]
	Embattle.ShowForMailReport(0,selfFormationData,targatFormationData,function(new_form)
	end , nil)
end

local function CheckBattleReport(go)
	local transformParams = {}
	transformParams.selfFormationData = nil
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
	Global.SetBattleReportBack(mainui , "Mail" , posx , posy)
	
	--启动战报播放
	Global.CheckBattleReportEx(curReadMailMsg ,MailListData.GetMailDataById(curMailId).subtype , function()
		print("report end function")
		
		local battleBack = Global.GetBattleReportBack()
		if battleBack.MainUI == "WorldMap" then
            MainCityUI.ShowWorldMap(battleBack.PosX , battleBack.PosY, true , function()
				if battleBack.Menu ~= nil then
			if battleBack.Menu == "Mail" then
						Mail.SetTabSelect(3)
						Mail.Show()
					end
				end
			end)
		else
			if battleBack.Menu ~= nil then
				if battleBack.Menu == "Mail" then
					Mail.SetTabSelect(3)
					Mail.Show()
				end
			end
		end
		
		
		
	end)
end

local function ResetContent(property)
	local pro1_attr = property:Find("info_property (1)/txt_attack"):GetComponent("UILabel")
	pro1_attr.text = 0
	local pro1_def = property:Find("info_property (1)/txt_defence"):GetComponent("UILabel")
	pro1_def.text = 0
	--部队死亡
	local pro2_attr = property:Find("info_property (2)/txt_attack"):GetComponent("UILabel")
	pro2_attr.text = 0
	local pro2_def = property:Find("info_property (2)/txt_defence"):GetComponent("UILabel")
	pro2_def.text = 0
	--部队损伤
	local pro3_attr = property:Find("info_property (3)/txt_attack"):GetComponent("UILabel")
	pro3_attr.text = 0
	local pro3_def = property:Find("info_property (3)/txt_defence"):GetComponent("UILabel")
	pro3_def.text = 0
	--战力损失
	local pro4_attr = property:Find("info_property (4)/txt_attack"):GetComponent("UILabel")
	pro4_attr.text = 0
	local pro4_def = property:Find("info_property (4)/txt_defence"):GetComponent("UILabel")
	pro4_def.text = 0
	--部队存活
	local pro5_attr = property:Find("info_property (5)/txt_attack"):GetComponent("UILabel")
	pro5_attr.text = 0
	local pro5_def = property:Find("info_property (5)/txt_defence"):GetComponent("UILabel")
	pro5_def.text = 0
	--指挥官经验
	local pro6_attr = property:Find("info_property (6)/txt_attack"):GetComponent("UILabel")
	pro6_attr.text = 0
	local pro6_def = property:Find("info_property (6)/txt_defence"):GetComponent("UILabel")
	pro6_def.text = 0
end

function ShowRobResource(height , msg , retortUI , mailData , formPrefab)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0,height,0)
	
	local resLabel = {}
	resLabel[3] = retortUI:Find("bg_food/txt_food"):GetComponent("UILabel")
	resLabel[3].text = 0
	resLabel[4] = retortUI:Find("bg_iron/txt_iron"):GetComponent("UILabel")
	resLabel[4].text = 0
	resLabel[5] = retortUI:Find("bg_oil/txt_oil"):GetComponent("UILabel")
	resLabel[5].text = 0
	resLabel[6] = retortUI:Find("bg_electric/txt_electric"):GetComponent("UILabel")
	resLabel[6].text = 0
	resLabel.limitObject = retortUI:Find("txt_limit").gameObject
	local robMsg = reportMsg.misc.robres.res
	if readMailData.subtype ==  Mail.MailReportType.MailReport_defence and reportWinLose == 0 and
		reportMsg.misc.subRobres ~= nil and reportMsg.misc.subRobres.res ~= nil then
		robMsg = reportMsg.misc.subRobres.res
	end
	
	for i=1 , #robMsg , 1 do
		local res = robMsg[i]
		resLabel[res.id].text = Global.ExchangeValue(res.num)
	end
	if readMailData.subtype ==  Mail.MailReportType.MailReport_player then
	resLabel.limitObject:SetActive(reportWinLose == 1 and reportMsg.misc.robres.dayRobRes >= reportMsg.misc.robres.dayRobResMax)
	end
	print(reportMsg.misc.robres.dayRobRes,reportMsg.misc.robres.dayRobResMax)
	print(reportWinLose)
	local title = retortUI:Find("title_resource/txt_title"):GetComponent("UILabel")
	if readMailData.subtype ==  Mail.MailReportType.MailReport_player or 
		readMailData.subtype ==  Mail.MailReportType.MailReport_robres or 
		readMailData.subtype ==  Mail.MailReportType.MailReport_robclamp then
		title.text = TextMgr:GetText("mail_ui50")
	else
		title.text = TextMgr:GetText("ui_worldmap_91")
	end
	
	local resHint = retortUI:Find("hint")
	local ACampMsg =reportMsg.misc.result.ACampPlayers
	local disResHint = false
	--只有在集结玩家时，攻击方显示该文本，其他时候不显示 -- xiaowendi
	if readMailData.subtype ==  Mail.MailReportType.MailReport_player then
		if ACampMsg ~= nil and #ACampMsg > 1 then
			for i=1 , #ACampMsg do
				if ACampMsg[i].uid == MainData.GetCharId() then
					disResHint = true
					break
				end
			end
		end
	end
	resHint.gameObject:SetActive(disResHint)
	
	return retortUI:GetComponent("UIWidget").height
end

function ShowCommander(height, msg, reportUI, mailData, formPrefab)
    --Global.DumpMessage(msg, "d:/e.lua")
	local reportMsg = msg
	local readMailData = mailData
	reportUI.gameObject:SetActive(true)
	reportUI.localPosition = Vector3(0, height, 0)
	local titleLabel = reportUI:Find("bg_reward/bg_title/text_reward"):GetComponent("UILabel")
	local subtype = mailData.subtype
	local titleText
	local prisonerMsgList
    if subtype == Mail.MailReportType.MailReport_player then
        if reportWinLose == 1 then
			titleText = Text.Mail_prisoner_Sub1
        else
            titleText = Text.Mail_prisoner_Sub2
        end
        prisonerMsgList = reportMsg.misc.prisoner.prisonerInfo
    elseif subtype == Mail.MailReportType.MailReport_defence then
        if reportWinLose == 1 then
            titleText = Text.Mail_prisoner_Sub1
        else
            titleText = Text.Mail_prisoner_Sub2
        end
        prisonerMsgList = reportMsg.misc.prisoner.prisonerInfo
    elseif subtype == Mail.MailReportType.MailReport_prisonerFlee then
        titleText = Text.Mail_prisoner_Sub5
        prisonerMsgList = reportMsg.misc.prisoner.prisonerInfo
    end
	titleLabel.text = TextMgr:GetText(titleText)
	local checkButton = reportUI:Find("bg_reward/btn_check"):GetComponent("UIButton")
	local baseid = mailData.baseid
	local prisonerCharId = prisonerMsgList[1].id
	local charIdrelated = false
	local charId = MainData.GetCharId()
	for i = 1, 2 do
	    local team = msg.misc.result.input.user["team" .. i]
        if team ~= nil then
            if team[1] ~= nil and team[1].user.charid == charId then
                charIdrelated = true
            end
        end
    end
	checkButton.gameObject:SetActive(charIdrelated and (baseid == 3 or baseid == 4 or baseid == 12 or baseid == 13))
	SetClickCallback(checkButton.gameObject, function(go)
        if #prisonerMsgList > 0 then
            if prisonerCharId == MainData.GetCharId() then
                MainInformation.Show()
            else
                Mail.Hide()
                MainCityUI.HideWorldMap(true, function()
                    if maincity.HasBuildingByID(10) then
                        JailInfo.Show()
                    else
                        maincity.SetTargetBuild(10, true, nil, true)
                    end
                end, true)
            end
        end
    end)
	local grid = reportUI:Find("bg_reward/Grid"):GetComponent("UIGrid")
	while grid.transform.childCount > 1 do
	    GameObject.DestroyImmediate(grid.transform:GetChild(1).gameObject)
    end
	local prefab = grid.transform:GetChild(0).gameObject

    for i, v in ipairs(prisonerMsgList) do
        local prisonerTransform
        if i > grid.transform.childCount then
            prisonerTransform = NGUITools.AddChild(grid.gameObject, prefab).transform
        else
            prisonerTransform = grid.transform:GetChild(i - 1)
        end
        local nameLabel = prisonerTransform:Find("name"):GetComponent("UILabel")
        local levelLabel = prisonerTransform:Find("Sprite/Lv"):GetComponent("UILabel")
        local faceTexture = prisonerTransform:Find("bg/Texture"):GetComponent("UITexture")

        local guildBanner = v.guildBanner
        if guildBanner == "" then
            guildBanner = "---"
        end
        nameLabel.text = string.format("[F1CF63][%s][-]%s", guildBanner, v.name)
        levelLabel.text = "Lv." .. v.level 
        faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", v.face)
        prisonerTransform.gameObject:SetActive(true)
    end

    grid:Reposition()

	return reportUI:GetComponent("UIWidget").height
end

local moneyList =
{
    food = Common_pb.MoneyType_Food,
    iron = Common_pb.MoneyType_Iron,
    oil = Common_pb.MoneyType_Oil,
    electric = Common_pb.MoneyType_Elec,
}

function ShowPrisonerReward(height, msg, reportUI, mailData, formPrefab)
	local reportMsg = msg
	local readMailData = mailData
	reportUI.gameObject:SetActive(true)
	reportUI.localPosition = Vector3(0, height, 0)
	local titleLabel = reportUI:Find("title_resource/txt_title"):GetComponent("UILabel")
	local checkButton = reportUI:Find("btn_check"):GetComponent("UIButton")
	local baseid = mailData.baseid
	checkButton.gameObject:SetActive((baseid == 310 and MainData.HasPendingRansom()) or baseid == 311)
	SetClickCallback(checkButton.gameObject, function(go)
        if baseid == 311 then
            Mail.Hide()
            MainCityUI.HideWorldMap(true, function()
                if maincity.HasBuildingByID(10) then
                    JailInfo.Show()
                    local prisonerMsg = JailInfoData.GetJailInfoDataByCharName(mailData.contentparams[1].value)
                    if prisonerMsg ~= nil then
                        local prisonLevel = maincity.GetBuildingLevelByID(10)
                        local prisonerData = TableMgr:GetJailDataByLevel(prisonLevel)
                        JailTreat.Show(prisonerMsg, prisonerData)
                    end
                else
                    maincity.SetTargetBuild(10, true, nil, true)
                end
            end, true)
        else
            Mail.Hide()
            MainInformation.Show()
            local commanderMsg = MainData.GetCommanderInfo()
            RansomPay.Show(commanderMsg)
        end
    end)
	local titleText
	local subtype = mailData.subtype
    if subtype == Mail.MailReportType.MailReport_player then
        titleText = Text.Mail_prisoner_Sub3
    elseif subtype == Mail.MailReportType.MailReport_prisonerRewardSet or subtype == Mail.MailReportType.MailReport_prisonerRewardOpt then
        titleText = Text.Mail_prisoner_Sub6
    end
	titleLabel.text = TextMgr:GetText(titleText)
	for k, v in pairs(moneyList) do
	    local moneyLabel = reportUI:Find(string.format("bg_%s/txt_%s", k, k)):GetComponent("UILabel")
	    local moneyValue = 0
	    for __, vv in ipairs(reportMsg.misc.prisoner.rewardMoney.money) do
	        if vv.type == v then
	            moneyValue = vv.value 
	            break
            end
        end
        moneyLabel.text = moneyValue
    end

	return reportUI:GetComponent("UIWidget").height
end

function ShowRebelAttack(height , msg , retortUI , mailData , formPrefab)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0,height,0)
	
	local defeatRate = retortUI:Find("title_reward/txt_title"):GetComponent("UILabel")
	local getScorll = retortUI:Find("title_reward/txt_title (1)"):GetComponent("UILabel")
	local tips = retortUI:Find("bg1/text (1)"):GetComponent("UILabel")
	retortUI:Find("bg1/text"):GetComponent("UILabel").text = TextMgr:GetText("RebelArmyAttack_ui30")
	local defeatRateNum = 0
	if reportMsg.misc.result ~= nil and reportMsg.misc.result.ArmyDeadNum[1] ~= nil and reportMsg.misc.result.ArmyTotalNum[1] ~= nil then
		defeatRateNum = reportMsg.misc.result.ArmyDeadNum[1] / reportMsg.misc.result.ArmyTotalNum[1]
	end
	defeatRate.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui28"), String.Format("{0:p}", defeatRateNum))
	getScorll.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui29"), reportMsg.misc.siegeShow.waveScore)
	tips.gameObject:SetActive(reportMsg.misc.siegeShow.failCnt > 0)
	tips.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui31"), reportMsg.misc.siegeShow.failCnt)
	
	
	return retortUI:GetComponent("UIWidget").height
end

function ShowRebelHelp(height , msg , retortUI , mailData , formPrefab)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0,height,0)
	
	local defeatRate = retortUI:Find("title_reward/txt_title"):GetComponent("UILabel")
	local getScorll = retortUI:Find("title_reward/txt_title (1)"):GetComponent("UILabel")
	retortUI:Find("bg1/text").gameObject:SetActive(false)
	retortUI:Find("bg1/text (1)").gameObject:SetActive(false)
	local defeatRateNum = 0
	if reportMsg.misc.result ~= nil and reportMsg.misc.result.ArmyDeadNum[1] ~= nil and reportMsg.misc.result.ArmyTotalNum[1] ~= nil then
		defeatRateNum = reportMsg.misc.result.ArmyDeadNum[1] / reportMsg.misc.result.ArmyTotalNum[1]
	end
	defeatRate.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui28"), String.Format("{0:p}", defeatRateNum))
	getScorll.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui29"), reportMsg.misc.siegeShow.waveScore)
	
	return retortUI:GetComponent("UIWidget").height
end


function GetShowItemList(itemListData)
	local itemList = {}
	for i=1 , #itemListData.data.item.items , 1 do
		local itemData = itemListData.data.item.items[i]
		if itemList[itemData.data.baseid] ~= nil then
			itemList[itemData.data.baseid].itemCount = itemList[itemData.data.baseid].itemCount + itemData.data.number
		else
			itemList[itemData.data.baseid] = {baseid = itemData.data.baseid , itemCount = itemData.data.number}
		end
	end
	for i=1 , #itemListData.data.money.money , 1 do
		local itemData = itemListData.data.money.money[i]
		if itemList[itemData.type] ~= nil then
			itemList[itemData.type].itemCount = itemList[itemData.data.baseid].itemCount + itemData.value
		else
			itemList[itemData.type] = {baseid = itemData.type , itemCount = itemData.value , charid = itemListData.charid}
		end
	end
	
	local sortList = {}
	for _, v in pairs(itemList) do
		if v then
			table.insert(sortList , v)
		end
	end
	return sortList
	
end

function ShowRewardContent(height, msg, retortUI, mailData, formPrefab)
	local numRewards = #curReadMailMsg.misc.attachShow.data
	if numRewards == 0 then
		return 0
	end

	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	
	
	local bgTitleHeight = retortUI:Find("title_reward"):GetComponent("UISprite").height
	local bgContentHeight = numRewards *  mailContent.rewardTypeGridItem:GetComponent("UIWidget").height
	local rewardTypeGrid = retortUI:Find("Grid"):GetComponent("UIGrid")
	
	while rewardTypeGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(rewardTypeGrid.transform:GetChild(0).gameObject)
	end
	
	for i = numRewards, 1, -1 do
		local itemListData = curReadMailMsg.misc.attachShow.data[i]
		local bgItem = NGUITools.AddChild(rewardTypeGrid.gameObject, mailContent.rewardTypeGridItem.gameObject).transform
		bgItem:SetParent(rewardTypeGrid.transform , false)
		local scrollview = bgItem:Find("Scroll View"):GetComponent("UIScrollView")
		
		local itemTypeName = bgItem:Find("Label"):GetComponent("UILabel")
		if reportMsg.misc.result.input.sweepCount > 0 then
			itemTypeName.text = System.String.Format(TextMgr:GetText("sweep_ui_2") , reportMsg.misc.result.input.sweepCount) -- 扫荡
		else
			itemTypeName.text = TextMgr:GetText(itemListData.infoid)
		end
		
		local itemListGrid = bgItem:Find("Scroll View/Grid1"):GetComponent("UIGrid")
		--[[local showItemList = GetShowItemList(curReadMailMsg.misc)
		for i=1 , #showItemList , 1 do
			local itemData = showItemList[i]
			MailDoc.LoadSingleItem(itemData.baseid , itemData.itemCount , itemListGrid ,mailContent.rewardListGridItem )
		end]]
		local showItemList = GetShowItemList(itemListData)
		for i=1 , #showItemList , 1 do
			local itemData = showItemList[i]
			MailDoc.LoadSingleItem(itemData.baseid , itemData.itemCount , itemListGrid ,mailContent.rewardListGridItem )
		end
		
		if itemListData.buff ~= nil and itemListData.buff ~= "" then
			local buffstr = string.split(itemListData.buff , ";")
			for i=1 , #buffstr do
				local info = NGUITools.AddChild(itemListGrid.gameObject , mailContent.rewardListGridItem)
				info.gameObject:SetActive(true)
				local buff = TableMgr:GetSlgBuffData(buffstr[i])
				local rewardicon = info.transform:Find("Texture"):GetComponent("UITexture")
				rewardicon.mainTexture = ResourceLibrary:GetIcon("Item/", buff.icon)
				info.transform:GetComponent("UISprite").spriteName = "bg_item_hui"
				info.transform:Find("num").gameObject:SetActive(false)
				info.transform:Find("have").gameObject:SetActive(false)
				SetClickCallback(info.gameObject,function()
					
				end)
			end
		end

		--[[for i=1 , #itemListData.data.item.items , 1 do
			local itemData = itemListData.data.item.items[i]
			MailDoc.LoadSingleItem(itemData.data.baseid , itemData.data.number , itemListGrid ,mailContent.rewardListGridItem )
		end
		for i=1 , #itemListData.data.money.money , 1 do
			local itemData = itemListData.data.money.money[i]
			MailDoc.LoadSingleItem(itemData.type , itemData.value , itemListGrid ,mailContent.rewardListGridItem )
		end]]
		
		itemListGrid:Reposition()
	end
	rewardTypeGrid:Reposition()
	
	retortUI:GetComponent("UIWidget").height = bgTitleHeight + bgContentHeight
	retortUI.localPosition = Vector3(0, height, 0)
	
	return bgTitleHeight + bgContentHeight
end

function ShowMobaRewardContent(height, msg, retortUI, mailData, formPrefab)
	--local bgContentHeight = retortUI:GetComponent("UIWidget").height
	local reportMsg = msg
	local readMailData = mailData
	local mailCfgData = TableMgr:GetMailCfgData(reportMsg.baseid)
	local buffGrid = retortUI:Find("Grid"):GetComponent("UIGrid")
	local buffItem = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	while buffGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(buffGrid.transform:GetChild(0).gameObject)
	end
	
	if mailCfgData.buff == 1 and reportMsg.contentparams ~= nil and reportMsg.contentparams[4] ~= nil and reportMsg.contentparams[4].value ~= "" then
		retortUI.gameObject:SetActive(true)
		local buffStr = string.split(reportMsg.contentparams[4].value , ";")
		for i = 1,#(buffStr) do
			local buff = NGUITools.AddChild(buffGrid.gameObject , buffItem.gameObject).transform
			local buffCfg = TableMgr:GetSlgBuffData(tonumber(buffStr[i]))
			if buffCfg then
				buff:Find("num").gameObject:SetActive(false)
				buff:Find("have").gameObject:SetActive(false)
				buff:GetComponent("UISprite").spriteName = "bg_item"
				buff:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", buffCfg.icon)
				SetClickCallback(buff.gameObject  , function()
					Tooltip.ShowMobaBuffTips(buffCfg.id)
				end)
			end
		end
		buffGrid:Reposition()
		
		retortUI:GetComponent("UIWidget").height = 150
		retortUI.localPosition = Vector3(0, height, 0)
		return retortUI:GetComponent("UIWidget").height
	else
		retortUI.gameObject:SetActive(false)
		return 0
	end
	
end

function ShowEliteRewardContent(height, msg, retortUI, mailData, formPrefab)
	local numRewards = #curReadMailMsg.misc.attachShow.data
	if numRewards == 0 then
		return 0
	end

	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	
	local bgTitleHeight = retortUI:Find("title_reward"):GetComponent("UISprite").height
	local bgContentHeight = numRewards * mailContent.rewardTypeGridItem:GetComponent("UIWidget").height
	local rewardTypeGrid = retortUI:Find("Grid"):GetComponent("UIGrid")
	
	while rewardTypeGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(rewardTypeGrid.transform:GetChild(0).gameObject)
	end
	
	for i = numRewards, 1, -1 do
		local itemListData = curReadMailMsg.misc.attachShow.data[i]
		local bgItem = NGUITools.AddChild(rewardTypeGrid.gameObject, mailContent.rewardTypeGridItem.gameObject).transform
		bgItem:SetParent(rewardTypeGrid.transform , false)
		
		local itemTypeName = bgItem:Find("Label"):GetComponent("UILabel")
		itemTypeName.text = itemListData.charname
		
		local itemListGrid = bgItem:Find("Scroll View/Grid1"):GetComponent("UIGrid")
		for i=1 , #itemListData.data.item.items , 1 do
			local itemData = itemListData.data.item.items[i]
			MailDoc.LoadSingleItem(itemData.data.baseid , itemData.data.number , itemListGrid ,mailContent.rewardListGridItem )
		end
		for i=1 , #itemListData.data.money.money , 1 do
			local itemData = itemListData.data.money.money[i]
			MailDoc.LoadSingleItem(itemData.type , itemData.value , itemListGrid ,mailContent.rewardListGridItem )
		end
		
		itemListGrid:Reposition()
	end
	rewardTypeGrid:Reposition()
	
	retortUI:GetComponent("UIWidget").height = bgTitleHeight + bgContentHeight
	retortUI.localPosition = Vector3(0, height, 0)
	
	return bgTitleHeight + bgContentHeight
end

function ShowParticipantContent(height , msg , retortUI , mailData , finder)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	
	local resultInfo = msg.misc.result
	local targetInfo = msg.misc.target
	local sourceInfo = msg.misc.source
	
	local partakeGrid = retortUI:Find("bg1/Grid1"):GetComponent("UIGrid")
	local partakeItem = mailContent.mainMailDocUI:Find("info_partake")
	
	local bgTitleHeight = retortUI:Find("title_reward"):GetComponent("UISprite").height
	local bgHurtMineHeight = retortUI:Find("bg1/info_partakemine"):GetComponent("UIWidget").height + 30
	local partItemHeight = partakeItem:GetComponent("UIWidget").height
	local bgContentHeight = 0
	

	while partakeGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(partakeGrid.transform:GetChild(0).gameObject)
	end
	
	--my hurt
	local monsterTotalNum = 0
	if msg.misc.target.monsterNumMax ~= nil then
		monsterTotalNum = math.max(1 , msg.misc.target.monsterNumMax)
	end
	
	local myHurtLabel = retortUI:Find("bg1/info_partakemine/title_hurt"):GetComponent("UILabel")
	local myDestroy = 0
	for i=1 , #resultInfo.ACampPlayers , 1 do
		if resultInfo.ACampPlayers[i].uid == MainData.GetCharId() then
			myDestroy = resultInfo.ACampPlayers[i].Destroy
		end
	end
	
	local desPerc = finder and 0 or myDestroy / monsterTotalNum * 100
	local fmt = string.format("%.2f" , desPerc)
	--myHurtLabel.text = "[FFFEA9FF]" .. fmt .. "%" .. "[-]"
	myHurtLabel.text =fmt .. "%"
	
	--particiant
	if curReadMailMsg.misc.attachShow ~= nil and curReadMailMsg.misc.attachShow.intruder ~= nil then
		--sort
		local partSet = {}
		for i=1 , #(curReadMailMsg.misc.attachShow.intruder.intruder) do
			table.insert(partSet , curReadMailMsg.misc.attachShow.intruder.intruder[i])
		end
		
		table.sort(partSet , function(v1 , v2)
			return v1.hurt > v2.hurt
		end)
		
		for i=1 , #(partSet) do
			if i < 6 then
				local partItem = NGUITools.AddChild(partakeGrid.gameObject, partakeItem.gameObject).transform
				partItem:SetParent(partakeGrid.transform , false)
				
				local pardata = partSet[i]
				local id = partItem:Find("txt_id"):GetComponent("UILabel")
				--id.text = "[FFFEA9FF]" .. i .. "[-]"
				id.text = i
				
				local name = partItem:Find("txt_name"):GetComponent("UILabel")
				--name.text = "[FFFEA9FF]" .. pardata.charname .. "[-]"
				name.text = pardata.charname
				
				local union = partItem:Find("title_unio"):GetComponent("UILabel")
				--union.text = "[FFFEA9FF]" .. union.text .. "[-]"
				union.text = union.text
				
				local league = partItem:Find("title_unio/txt_unio"):GetComponent("UILabel")
				--league.text = "[FFFEA9FF]" .. pardata.guild .. "[-]"
				league.text = (pardata.guild == nil or pardata.guild == "") and "--" or pardata.guild
				
				local hurtName = partItem:Find("title_hurt"):GetComponent("UILabel")
				--hurtName.text = "[FFFEA9FF]" .. hurtName.text .. "[-]"
				hurtName.text = hurtName.text
				
				local hurt = partItem:Find("title_hurt/txt_hurt"):GetComponent("UILabel")
				local fmt = string.format("%.2f" , pardata.hurt*100)
				--hurt.text = "[FFFEA9FF]" .. fmt .. "%" .. "[-]"
				hurt.text =  fmt .. "%"
			end
		end
		partakeGrid:Reposition()
	
		bgContentHeight = math.min(#partSet , 5) * partItemHeight
	end
	retortUI:GetComponent("UIWidget").height =  bgTitleHeight + bgHurtMineHeight + bgContentHeight
	retortUI:Find("bg1"):GetComponent("UIWidget").height =  bgHurtMineHeight + bgContentHeight
	retortUI.localPosition = Vector3(0,height,0)

	return retortUI:GetComponent("UIWidget").height
end

function ShowEliteParticipantContent(height , msg , retortUI , mailData , finder)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	
	local resultInfo = msg.misc.result
	local targetInfo = msg.misc.target
	local sourceInfo = msg.misc.source
	
	local partakeGrid = retortUI:Find("bg1/Grid1"):GetComponent("UIGrid")
	local partakeItem = mailContent.mainMailDocUI:Find("info_partake")
	
	local bgTitleHeight = retortUI:Find("title_reward"):GetComponent("UISprite").height
	local bgHurtMineHeight = retortUI:Find("bg1/info_partakemine"):GetComponent("UIWidget").height + 30
	local partItemHeight = partakeItem:GetComponent("UIWidget").height
	local bgContentHeight = 0
	

	while partakeGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(partakeGrid.transform:GetChild(0).gameObject)
	end
	
	--my hurt
	local monsterTotalNum = 0
	if msg.misc.target.monsterNumMax ~= nil then
		monsterTotalNum = math.max(1 , msg.misc.target.monsterNumMax)
	end
	
	local totalDam = 0;
	--particiant
	if curReadMailMsg.misc.attachShow ~= nil and curReadMailMsg.misc.attachShow.intruder ~= nil then
		--sort
		local partSet = {}
		for i=1 , #(curReadMailMsg.misc.attachShow.intruder.intruder) do
			totalDam = totalDam + curReadMailMsg.misc.attachShow.intruder.intruder[i].hurt
			table.insert(partSet , curReadMailMsg.misc.attachShow.intruder.intruder[i])
		end
		
		table.sort(partSet , function(v1 , v2)
			return v1.hurt > v2.hurt
		end)
		
		for i=1 , #(partSet) do
			if i < 6 then
				local partItem = NGUITools.AddChild(partakeGrid.gameObject, partakeItem.gameObject).transform
				partItem:SetParent(partakeGrid.transform , false)
				
				local pardata = partSet[i]
				local id = partItem:Find("txt_id"):GetComponent("UILabel")
				--id.text = "[FFFEA9FF]" .. i .. "[-]"
				id.text = i
				
				local name = partItem:Find("txt_name"):GetComponent("UILabel")
				--name.text = "[FFFEA9FF]" .. pardata.charname .. "[-]"
				name.text = pardata.charname
				
				local union = partItem:Find("title_unio"):GetComponent("UILabel")
				--union.text = "[FFFEA9FF]" .. union.text .. "[-]"
				union.text = union.text
				
				local league = partItem:Find("title_unio/txt_unio"):GetComponent("UILabel")
				--league.text = "[FFFEA9FF]" .. pardata.guild .. "[-]"
				league.text = (pardata.guild == nil or pardata.guild == "") and "--" or pardata.guild
				
				local hurtName = partItem:Find("title_hurt"):GetComponent("UILabel")
				--hurtName.text = "[FFFEA9FF]" .. hurtName.text .. "[-]"
				hurtName.text = hurtName.text
				
				local hurt = partItem:Find("title_hurt/txt_hurt"):GetComponent("UILabel")
				local fmt = string.format("%.2f" , pardata.hurt*100)
				--hurt.text = "[FFFEA9FF]" .. fmt .. "%" .. "[-]"
				hurt.text =  fmt .. "%"
			end
		end
		partakeGrid:Reposition()
	
		bgContentHeight = math.min(#partSet , 5) * partItemHeight
	end
	
	local myHurtLabel = retortUI:Find("bg1/info_partakemine/title_hurt"):GetComponent("UILabel")
	local fmt = string.format("%.2f" , totalDam*100)
	myHurtLabel.text =fmt .. "%"
	
	
	retortUI:GetComponent("UIWidget").height =  bgTitleHeight + bgHurtMineHeight + bgContentHeight
	retortUI:Find("bg1"):GetComponent("UIWidget").height =  bgHurtMineHeight + bgContentHeight
	retortUI.localPosition = Vector3(0,height,0)

	return retortUI:GetComponent("UIWidget").height
end

function ShowHerosContent(height , msg , retortUI , mailData , formPrefab)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0,height,0)
	--height = height + retortUI:GetComponent("UIWidget").height
	--print("heros bg height is :" .. height)
	
	local grid = retortUI:Find("bg1/Grid1"):GetComponent("UIGrid")
	MailDoc.LoadActionHero(msg.misc , grid)
	
	if grid.transform.childCount == 0 then--攻击炮车
		retortUI.gameObject:SetActive(false)
		return 0
	end
	
	return retortUI:GetComponent("UIWidget").height
end

function ShowTitleContent(height , msg , retortUI , mailData , formPrefab)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0,height,0)
	
	local name = retortUI:Find("title_name/text_name"):GetComponent("UILabel")
	name.text = TextMgr:GetText("mail_ui43")
	
	local mailTime = retortUI:Find("title_time/text_time"):GetComponent("UILabel")
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss") --timeText[1] .. "     " .. timeText[2]
	mailTime.text = showTime
	
	local targetInfo = msg.misc.target
	local textContetnt = retortUI:Find("text_title"):GetComponent("UILabel")
	textContetnt.text = ""
	if targetInfo ~= nil then
		local maildata = {}
		maildata.category = MailMsg_pb.MailType_Report
		maildata.webgm = false
		maildata.contentparams = reportMsg.contentparams
		maildata.content = reportMsg.content
		textContetnt.text = Mail.GetMailContent(maildata)
	end
	
	return retortUI:GetComponent("UIWidget").height
end

function LoadReportHeroMsg(hero, heroMsg, heroData )
	if heroMsg == nil then
		hero.empty.gameObject:SetActive(true)
		hero.levelLabel.gameObject:SetActive(false)
		hero.starSprite.gameObject:SetActive(false)
		hero.expBg.gameObject:SetActive(false)
	else	
		local expWithLevel = 0
		local expWithOldLevel = 0
		--将军exp
		local heroExp = (heroMsg.exp ~= nil and heroMsg.oldexp ~= nil)
		hero.expBg.gameObject:SetActive(heroExp)
		if heroExp then 
			expWithLevel = TableMgr:GetHeroLevelByExp(heroMsg.exp)
			expWithOldLevel = TableMgr:GetHeroLevelByExp(heroMsg.oldexp)
			hero.expLabel.text = "+" .. (heroMsg.exp - heroMsg.oldexp)
			--将军expbar
			hero.expSlider.value = expWithLevel - math.floor(expWithLevel)
			
			hero.levelUp.gameObject:SetActive(math.floor(expWithLevel) > math.floor(expWithOldLevel))
			hero.lvUpEff.gameObject:SetActive(math.floor(expWithLevel) > math.floor(expWithOldLevel))
		else
			expWithLevel = heroMsg.level
		end
		
		--将军等级
		hero.levelLabel.text = math.floor(expWithLevel)
		--将军icon
		hero.head.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
		--将军品质
		hero.qualitySprite.spriteName = "head"..heroData.quality
		--将军星级
		hero.starSprite.width = heroMsg.star * hero.starHeight
		
		
	end
end

function LoadReportHero(heroMsgs , grid)
	--show hero
	local listitem = ResourceLibrary.GetUIPrefab("CommonItem/listitem_hero_maildoc")
	while grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
	end
	
	for i=1 , 5 , 1 do
		local heroitem = NGUITools.AddChild(grid.gameObject, listitem.gameObject).transform
		heroitem:SetParent(grid.transform , false)
		heroitem.localScale = Vector3(0.6,0.6,1)
		local heroObj = {}
		UIUtil.LoadMailHeroObj(heroObj ,heroitem)
		if heroMsgs ~= nil and i<= #heroMsgs then
			
			local heroData = TableMgr:GetHeroData(heroMsgs[i].baseid)
			LoadReportHeroMsg(heroObj , heroMsgs[i] , heroData)
		else
			LoadReportHeroMsg(heroObj , nil , nil)
		end
	end
	grid:Reposition()
end

function ShowReportContent(height , msg , retortUI , mailData , formPrefab,cunstomTitleFunc)
	--local reportBgHeight = 0
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0,height,0)
	--review
	local battleReport = retortUI:Find("bg_right/bg_information/btn_report"):GetComponent("UIButton")
	SetClickCallback(battleReport.gameObject , cunstomTitleFunc == nil and CheckBattleReport or function(go) cunstomTitleFunc("battleReport") end)
	
	--zhenxing
	local reportEmbattle = retortUI:Find("bg_right/bg_information/btn_infor"):GetComponent("UIButton")
	SetClickCallback(reportEmbattle.gameObject , function()
		ShowEmbattle(reportMsg)
	end)
	
	local coordBtn = retortUI:Find("bg_title/btn_coord"):GetComponent("UIButton")
	SetClickCallback(coordBtn.gameObject , function()
		--ShowEmbattle(reportMsg)
		if readMailData.category ~= MailMsg_pb.MailType_Moba then
			MainCityUI.ShowWorldMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y, true)
			Mail.Hide()
		else
			Mail.Hide()
			MobaMain.LookAt(posx , posy , true)
		end
	end)
	
	--战斗简报
	reportWinLose = 1
	local midTitle = retortUI:Find("bg_title/txt_title"):GetComponent("UILabel")
	local winloseTex = retortUI:Find("kuang/result"):GetComponent("UITexture")
	if cunstomTitleFunc ~= nil then
		midTitle.text,reportWinLose = cunstomTitleFunc("Title")
	else
        midTitle.text , reportWinLose = GetWinLose(readMailData , reportMsg)
    end
	
	if reportWinLose == 1 then
		midTitle.gradientTop = NGUIMath.HexToColor(0xB8F992FF)
		midTitle.gradientBottom = NGUIMath.HexToColor(0x2FB017FF)
		winloseTex.mainTexture = ResourceLibrary:GetIcon("Background/" , "mailpve_victory")
	else
		midTitle.gradientTop = NGUIMath.HexToColor(0xFF7676FF)
		midTitle.gradientBottom = NGUIMath.HexToColor(0xFF0000FF)
		winloseTex.mainTexture = ResourceLibrary:GetIcon("Background/" , "mailpve_fail")
	end

	--
	local midTime = retortUI:Find("bg_title/text_time"):GetComponent("UILabel")
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss")--timeText[1] .. "     " .. timeText[2]
	midTime.text = showTime
	
	local player1 , vsStr , player2,OfficialId1,OfficialId2,guildOfficialId1,guildOfficialId2 = GetReportShareTitle(reportMsg, readMailData.subtype)

	print(player1 , player2)
	local playerSelfHead =  retortUI:Find("bg_right/bg_head_top/bg_head_attack/icon_head_attack"):GetComponent("UITexture")
	playerSelfHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", 
	cunstomTitleFunc == nil and GetArmyFace(reportMsg.misc.result.input.user.team1 , 1 ) or cunstomTitleFunc("player1face"))--reportMsg.misc.result.input.user.team1[1].user.face)	
	GOV_Util.SetFaceUI(retortUI:Find("bg_right/bg_head_top/bg_head_attack/MilitaryRank"),
	(reportMsg.misc.result.input.user.team1[1].user ~= nil and
	 reportMsg.misc.result.input.user.team1[1].user.face ~= nil and 
	 reportMsg.misc.result.input.user.team1[1].user.face ~= 0) and reportMsg.misc.result.input.user.team1[1].user.militaryRankId or 0)

	local playerSelfName =  retortUI:Find("bg_right/bg_head_top/bg_head_attack/name_attack"):GetComponent("UILabel")
	playerSelfName.text = cunstomTitleFunc == nil and player1 or cunstomTitleFunc("player1")--team1Guild .. msg.misc.result.input.user.team1[1].user.name
	local gov = retortUI:Find("bg_right/bg_head_top/bg_head_attack/bg_gov")
	if gov ~= nil then
		GOV_Util.SetGovNameUI(gov,OfficialId1,guildOfficialId1,true)
	end	
	local playerSelfCoord =  retortUI:Find("bg_right/bg_head_top/bg_head_attack/coordinate_attack"):GetComponent("UILabel")
	if reportMsg.misc.source.pos == nil then
		playerSelfCoord.gameObject:SetActive(false)
	else
		playerSelfCoord.text = System.String.Format("#1 X:{0} Y:{1}" ,  reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y)
		SetClickCallback(playerSelfCoord.gameObject , function(go)
			--Chat.GoMap(reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y)
			MailReportGoMap(reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y , readMailData.category)
		end)
	end
	if readMailData.subtype == Mail.MailReportType.MailReport_siegeAttack or readMailData.subtype == Mail.MailReportType.MailReport_siegeHelp then
		playerSelfHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", "201")
		playerSelfName.text = TextMgr:GetText("SiegeMonster_" .. reportMsg.misc.siegeShow.wave)
	end
	
	local targetHead = retortUI:Find("bg_right/bg_head_top/bg_head_defence/icon_head_defence"):GetComponent("UITexture")
	targetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/",
	cunstomTitleFunc == nil and GetArmyFace(reportMsg.misc.result.input.user.team2 , 1) or cunstomTitleFunc("player2face"))
	GOV_Util.SetFaceUI(retortUI:Find("bg_right/bg_head_top/bg_head_defence/MilitaryRank"),
	(reportMsg.misc.result.input.user.team2[1].user ~= nil and
	 reportMsg.misc.result.input.user.team2[1].user.face ~= nil and 
	 reportMsg.misc.result.input.user.team2[1].user.face ~= 0) and reportMsg.misc.result.input.user.team2[1].user.militaryRankId or 0)

	--GetArmyFace(reportMsg.misc.result.input.user.team2 , 1 ))--reportMsg.misc.result.input.user.team2[1].user.face)
	local targetName =  retortUI:Find("bg_right/bg_head_top/bg_head_defence/name_defence"):GetComponent("UILabel")
	targetName.text = cunstomTitleFunc == nil and player2 or cunstomTitleFunc("player2")--team2Guild .. msg.misc.result.input.user.team2[1].user.name

	local gov = retortUI:Find("bg_right/bg_head_top/bg_head_defence/bg_gov")
	if gov ~= nil then
		GOV_Util.SetGovNameUI(gov,OfficialId2,guildOfficialId2,true)
	end
	
	local targetCoord =  retortUI:Find("bg_right/bg_head_top/bg_head_defence/coordinate_defence"):GetComponent("UILabel")

	if reportMsg.misc.target.pos == nil then
		targetCoord.gameObject:SetActive(false)
	else
		targetCoord.text = System.String.Format("#1 X:{0} Y:{1}" , reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
		SetClickCallback(targetCoord.gameObject , function(go)
			--Chat.GoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
			MailReportGoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y , readMailData.category)
		end)
	end
	
	local property = retortUI:Find("bg_right/bg_property")
	ResetContent(property)
	
	local resultShow = reportMsg.misc.result
	--如果对方没有部队，屏蔽战报按钮
	local BattleResult = false
	local armyTotalNum = 0
	if reportMsg.misc.result.input.user ~= nil then
		if reportMsg.misc.result.input.user.team2 ~= nil and (#reportMsg.misc.result.input.user.team2) > 0  then
			for i=1 , #reportMsg.misc.result.input.user.team2 , 1 do
				if reportMsg.misc.result.input.user.team2[i].army ~= nil and (#reportMsg.misc.result.input.user.team2[i].army) > 0 then
					--battleReport.gameObject:SetActive(true)
					BattleResult = true
				end
			end
		end
	end
	
	if not BattleResult then
		for j=1 , #reportMsg.misc.result.input.user.team1 , 1 do
			for i=1 , #reportMsg.misc.result.input.user.team1[j].army , 1 do
				armyTotalNum = armyTotalNum + reportMsg.misc.result.input.user.team1[j].army[i].army.num 
			end
		end
		
		battleReport.gameObject:SetActive(false)
		--参战部队
		local pro1_attr = property:Find("info_property (1)/txt_attack"):GetComponent("UILabel")
		pro1_attr.text = armyTotalNum
		local pro1_def = property:Find("info_property (1)/txt_defence"):GetComponent("UILabel")
		pro1_def.text = 0
		
		--部队存活
		local pro5_attr = property:Find("info_property (5)/txt_attack"):GetComponent("UILabel")
		pro5_attr.text = armyTotalNum
		local pro5_def = property:Find("info_property (5)/txt_defence"):GetComponent("UILabel")
		pro5_def.text = 0
	else
		battleReport.gameObject:SetActive(true)
		
		local ShowTargetArmyInfo = true
		local result = {}
		result[1] = {}
		result[1].left = resultShow.ArmyTotalNum[1]
		result[1].right = resultShow.ArmyTotalNum[2]
		result[2] = {}
		result[2].left = resultShow.ArmyDeadNum[1]
		result[2].right = resultShow.ArmyDeadNum[2]
		result[3] = {}
		result[3].left = resultShow.ArmyInjuredNum[1]
		result[3].right = resultShow.ArmyInjuredNum[2]
		result[4] = {}
		result[4].left = math.floor(resultShow.ArmyLossFighting[1] + 0.5)
		result[4].right = math.floor(resultShow.ArmyLossFighting[2] + 0.5)
		result[5] = {}
		result[5].left = resultShow.ArmyLivedNum[1]
		result[5].right = resultShow.ArmyLivedNum[2]
		result[6] = {}
		result[6].left = resultShow.Exp[1]
		result[6].right = resultShow.Exp[2]
		
		--如果进攻方部队全部阵亡，则进攻方收到的邮件不显示战斗结果和战报按钮
		if (resultShow.ArmyLivedNum[1] == 0) and reportWinLose == 0 and cunstomTitleFunc == nil then
			for i=1 , 6 ,1 do
				result[i].right = "?????"
			end
			battleReport.gameObject:SetActive(false)
			BattleResult = false
		end
		
		--set show value
		for i=1 , 6 , 1 do
			local pro1_attr = property:Find(System.String.Format( "info_property ({0})/txt_attack" , i)):GetComponent("UILabel")
			pro1_attr.text = result[i].left
			local pro1_def = property:Find(System.String.Format("info_property ({0})/txt_defence" , i)):GetComponent("UILabel")
			pro1_def.text = result[i].right
		end
	end
	
	
	--显示将军
	local gridleft = retortUI:Find("bg_right/Grid_left"):GetComponent("UIGrid")
	local gridright = retortUI:Find("bg_right/Grid_right"):GetComponent("UIGrid")
	local showTeamInfo1 = GetResportShowTeam(resultShow.input.user.team1)
	local showTeamInfo2 = GetResportShowTeam(resultShow.input.user.team2)
	
	if readMailData.subtype == Mail.MailReportType.MailReport_actmonster
		or readMailData.subtype == Mail.MailReportType.MailReport_monster then
		if reportWinLose == 1 then
			LoadReportHero(reportMsg.misc.heros , gridleft)
		else
			LoadReportHero(showTeamInfo1.hero.heros , gridleft)
		end
		LoadReportHero(showTeamInfo2.hero.heros , gridright)
	else
		LoadReportHero(showTeamInfo1.hero.heros , gridleft)
		LoadReportHero(showTeamInfo2.hero.heros , gridright)
	end
	
	if cunstomTitleFunc ~= nil then
		cunstomTitleFunc("Hero")
	end
	--MailDoc.LoadActionHero(msg , grid)
	local heroAddLeft = retortUI:Find("bg_right/text_left/text"):GetComponent("UILabel")
	heroAddLeft.text = showTeamInfo1.heroAddPkValue == nil and 0 or showTeamInfo1.heroAddPkValue
	local heroAddRight = retortUI:Find("bg_right/text_right/text"):GetComponent("UILabel")
	heroAddRight.text = showTeamInfo2.heroAddPkValue == nil and 0 or showTeamInfo2.heroAddPkValue
	
	return retortUI:GetComponent("UISprite").height , BattleResult
end


function MobaShowReportContent(height , msg , retortUI , mailData , formPrefab,cunstomTitleFunc)
	local reportMsg = msg
	local bgheight , BattleResult = ShowReportContent(height , msg , retortUI , mailData , formPrefab,cunstomTitleFunc)
print("________________2")
	local battleReport = retortUI:Find("btn_report"):GetComponent("UIButton")
	SetClickCallback(battleReport.gameObject , function()
		Global.CheckMobaBattleReportEx(msg)
		BattlefieldReport.SetBattleResult(msg.misc.result,nil)
		BattlefieldReport.Show()
	end)
	
	
	local roleLeft = retortUI:Find("bg_right/bg_head_top/bg_head_attack/bg_mobaRole/Sprite"):GetComponent("UISprite")
	local roleRight = retortUI:Find("bg_right/bg_head_top/bg_head_defence/bg_mobaRole/Sprite"):GetComponent("UISprite")
	roleLeft.spriteName = msg.misc.source.role ~= nil and "Mobaroleselect_" .. msg.misc.source.role or ""
	roleRight.spriteName = msg.misc.target.role ~= nil and "Mobaroleselect_" .. msg.misc.target.role or ""
	retortUI:Find("bg_right/jifen_sp/Label"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("RebelArmyAttack_ui29") , msg.misc.mobaInfo.mobaScore and msg.misc.mobaInfo.mobaScore or 0)
	battleReport.gameObject:SetActive(BattleResult)
	
	return bgheight
end

local function ShareReport(chanel)
	local mainMailDocUI = mailContent.mainMailDocUI
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	local playerName , vsStr , targetName,OfficialId1,OfficialId2 = GetReportShareTitle(curReadMailMsg, readMailData.subtype)
	local shareContent = mainMailDocUI:Find("share")
	shareContent.gameObject:SetActive(false)
	
	
	
	local reportId = curReadMailMsg.misc.reportid
	--playerName = curReadMailMsg.misc.result.input.user.team1[1].user.name
	if readMailData.subtype == Mail.MailReportType.MailReport_siegeAttack or readMailData.subtype == Mail.MailReportType.MailReport_siegeHelp then
		playerName = TextMgr:GetText("SiegeMonster_" .. curReadMailMsg.misc.siegeShow.wave)
	end
	--[[local targetName = curReadMailMsg.misc.result.input.user.team2[1].user.name
	if curReadMailMsg.misc.result.input.user.team2[1].monster ~= nil and curReadMailMsg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_ActMonster then--攻击炮车
		targetName = TextMgr:GetText(curReadMailMsg.misc.target.name)
    end]]
	local fort = 0
	if curReadMailMsg.misc.result.input.user.team2[1].fort ~= nil and curReadMailMsg.misc.result.input.user.team2[1].fort.subType > 0 then
		fort = curReadMailMsg.misc.result.input.user.team2[1].fort.subType
	end
	local govSubType = 5
	if curReadMailMsg.misc.result.input.user.team2[1].centerBuild.uid ~= nil and curReadMailMsg.misc.result.input.user.team2[1].centerBuild.uid > 0 then
		govSubType = curReadMailMsg.misc.result.input.user.team2[1].centerBuild.subType
	end

	local targetGuild = ""
	if curReadMailMsg.misc.target.guildBanner ~= "" then
		targetGuild = "【" .. curReadMailMsg.misc.target.guildBanner .. "】"
	end
	local playerGuild = ""
	if curReadMailMsg.misc.source.guildBanner ~= "" then
		playerGuild = "【" .. curReadMailMsg.misc.source.guildBanner .. "】"
	end
	
	local send = {}
	send.curChanel = chanel
	send.spectext = reportId .. "," 
					.. playerName .. "," 
					.. targetName .. "," 
					.. shareContent:Find("Container/bg_frane/frame_input"):GetComponent("UIInput").value .. "," 
					.. readMailData.createtime .. "," 
					.. playerGuild .. "," 
					.. targetGuild .. "," 
					.. fort .. ","
					.. readMailData.subtype..","
					.. govSubType .. ","
					.. readMailData.baseid
	send.content =   playerName .. "    vs    "  .. targetName--Global.GetReportShareTitle(curReadMailMsg)
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 3
	send.senderguildname = ""
	
	if UnionInfoData.HasUnion() then
		send.senderguildname = UnionInfoData.GetData().guildInfo.banner
	end
	
	local category = readMailData.category
	if chanel == GetInterface("Channel_private" , category) then
		GetInterface("Chat" , category).SetPrivateShare(send)
		GUIMgr:CreateMenu(GetInterface("Chat" , category)._NAME, false)
	else
		GetInterface("Chat" , category).SendContent(send)
		FloatText.Show(TextMgr:GetText("ui_worldmap_83"), Color.green)
	end
	
	--[[if readMailData.category == MailMsg_pb.MailType_Moba then
		if chanel == ChatMsg_pb.chanel_MobaPrivate then
			MobaChat.SetPrivateShare(send)
			GUIMgr:CreateMenu("MobaChat", false)
		else
			MobaChat.SendContent(send)
			FloatText.Show(TextMgr:GetText("ui_worldmap_83"), Color.green)
		end
	else
		if chanel == ChatMsg_pb.chanel_private then
			Chat.SetPrivateShare(send)
			GUIMgr:CreateMenu("Chat", false)
		else
			Chat.SendContent(send)
			FloatText.Show(TextMgr:GetText("ui_worldmap_83"), Color.green)
		end
	end]]
end

local function ShowShare()
	local mainMailDocUI = mailContent.mainMailDocUI
	local readMailData = MailListData.GetMailDataById(curMailId)
	local category = readMailData.category
	
	local shareContent = mainMailDocUI:Find("share")
	shareContent.gameObject:SetActive(true)
	shareContent:Find(string.format("Container/bg_frane/%s" , GetInterface("Share_btn" , category))).gameObject:SetActive(true)
	
	local shareTitle = shareContent:Find("Container/bg_frane/mid/text"):GetComponent("UILabel")
	local player1 , vsStr , player2 = GetReportShareTitle(curReadMailMsg, readMailData.subtype)
	shareTitle.text = player1 .. vsStr .. player2
	
	local share2PublicBtn = shareContent:Find("Container/bg_frane/btn_slg/war zone"):GetComponent("UIButton")
	SetClickCallback(share2PublicBtn.gameObject , function(go)
		ShareReport(ChatMsg_pb.chanel_world)
	end)
	
	local share2unionBtn = shareContent:Find("Container/bg_frane/btn_slg/union"):GetComponent("UIButton")
	SetClickCallback(share2unionBtn.gameObject , function(go)
		if not UnionInfoData.HasUnion() then
			FloatText.Show(TextMgr:GetText("mail_ui63") , Color.white)
			return
		end
		--local contentInput = shareContent:Find("Container/bg_frane/frame_input"):GetComponent("UIInput").value
		ShareReport(ChatMsg_pb.chanel_guild)
	end)
	
	local share2private = shareContent:Find("Container/bg_frane/btn_slg/btn_private"):GetComponent("UIButton")
	SetClickCallback(share2private.gameObject , function(go)
		ShareReport(ChatMsg_pb.chanel_private)
	end)
	
	local share2PublicBtn_moba = shareContent:Find("Container/bg_frane/btn_moba/war zone"):GetComponent("UIButton")
	SetClickCallback(share2PublicBtn_moba.gameObject , function(go)
		ShareReport(GetInterface("Channel_team", category))
	end)
	local share2unionBtn_moba = shareContent:Find("Container/bg_frane/btn_moba/union"):GetComponent("UIButton")
	SetClickCallback(share2unionBtn_moba.gameObject , function(go)
		ShareReport(GetInterface("Channel_world", category))
	end)
	
	local share2private_moba = shareContent:Find("Container/bg_frane/btn_moba/btn_private"):GetComponent("UIButton")
	SetClickCallback(share2private_moba.gameObject , function(go)
		ShareReport(GetInterface("Channel_private" , category))
	end)
	
	local closeBtn = shareContent:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		shareContent.gameObject:SetActive(false)
	end)
end


local function ShowBanner(height , msg , retortUI , mailData , formPrefab)
	--mailContent.bgBanner
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0,height,0)
	
	local winTexture = retortUI:Find("Texture"):GetComponent("UITexture")
	local text , winlose = GetWinLose(readMailData , reportMsg)
	if winlose == 1 then --胜利
		winTexture.mainTexture = ResourceLibrary:GetIcon("Background/", "mailpve_victory")
	else 
		winTexture.mainTexture = ResourceLibrary:GetIcon("Background/", "mailpve_fail")
	end
	
	return retortUI:GetComponent("UIWidget").height
end

function ShowBattleDetailContent(height, msg, retortUI, mailData, formPrefab)
	local reportMsg = msg
	local readMailData = mailData
	retortUI.gameObject:SetActive(true)
	retortUI.localPosition = Vector3(0, height, 0)

	local resultShow = reportMsg.misc.result
	local selfFormationData = GetResportShowTeam(resultShow.input.user.team1)
	local targatFormationData = GetResportShowTeam(resultShow.input.user.team2)
	retortUI.gameObject:SetActive(not( resultShow.ArmyLivedNum[1] == 0 and reportWinLose == 0 ))
	
	--btn openn
	local tween1 = retortUI:Find("btn_open"):GetComponents(typeof(UITweener))
	local tween2 = retortUI:Find("item_ReportInformation"):GetComponents(typeof(UITweener))
	for i = 1, tween1.Length do
		tween1[i-1]:ResetToBeginning()
	end
	for i = 1, tween2.Length do
		tween2[i-1]:ResetToBeginning()
	end
	--local tween2 = retortUI:Find("btn_open"):GetComponent("UITweener")
	--tween1:Play(false)
	--tween2:ResetToBeginning()
	--army formation
	local Formation = BMFormation(retortUI:Find("item_ReportInformation/bg_Formation/bg_frane"))
    Formation:SetPVPMailLeftFormationData(selfFormationData)
    Formation:SetPVPMailRightFormationData(targatFormationData)
	Formation:Awake(0)
	Formation:CheckArmyRestrict()
	local formationHelp = retortUI:Find("item_ReportInformation/bg_Formation/btn_help")
	SetClickCallback(formationHelp.gameObject, UnitCounters.Show)
	local buffHelp = retortUI:Find("item_ReportInformation/bg_Buff/btn_help")
	buffHelp.gameObject:SetActive(readMailData.category ~= MailMsg_pb.MailType_Moba)
	SetClickCallback(buffHelp.gameObject, function() 
		DailyActivityHelp.Show("UnitCounters_ui7" , "Help_MailReport")
	end)
	
	--hero buff
	local buffRoot = {}
	buffRoot[1] = {}
	buffRoot[2] = {}
	for i=1 , 6 ,1 do
		buffRoot[1][i] = {}
		buffRoot[1][i].bgTrf = retortUI:Find("item_ReportInformation/bg_Buff/bg_left/Grid/bg_item" .. i)
		buffRoot[1][i].text = retortUI:Find("item_ReportInformation/bg_Buff/bg_left/Grid/bg_item" .. i .. "/text"):GetComponent("UILabel")
		buffRoot[1][i].num = retortUI:Find("item_ReportInformation/bg_Buff/bg_left/Grid/bg_item" .. i .. "/num"):GetComponent("UILabel")
		--buffRoot[1][i].frame = retortUI:Find("item_ReportInformation/bg_Buff/bg_left/Grid/bg_item" .. i .. "/num"):GetComponent("UILabel")
		buffRoot[1][i].arrowSpr = retortUI:Find("item_ReportInformation/bg_Buff/bg_left/Grid/bg_item" .. i .. "/arrow"):GetComponent("UISprite")
		
		buffRoot[2][i] = {}
		buffRoot[2].bgTrf = retortUI:Find("item_ReportInformation/bg_Buff/bg_right/Grid/bg_item" .. i)
		buffRoot[2][i].text = retortUI:Find("item_ReportInformation/bg_Buff/bg_right/Grid/bg_item" .. i .. "/text"):GetComponent("UILabel")
		buffRoot[2][i].num = retortUI:Find("item_ReportInformation/bg_Buff/bg_right/Grid/bg_item" .. i .. "/num"):GetComponent("UILabel")
		--buffRoot[1][i].frame = retortUI:Find("item_ReportInformation/bg_Buff/bg_right/Grid/bg_item" .. i .. "/num"):GetComponent("UILabel")
		buffRoot[2][i].arrowSpr = retortUI:Find("item_ReportInformation/bg_Buff/bg_right/Grid/bg_item" .. i .. "/arrow"):GetComponent("UISprite")
	end
	
	local msgAttr1 = reportMsg.misc.result.input.user.attrAddMax1
	local msgAttr2 = reportMsg.misc.result.input.user.attrAddMax2
	
	local arrs = {}
    arrs[1] = {}
    if msgAttr1.attrs ~= nil then
        for i =1,#msgAttr1.attrs,1 do
            --print("1",i, msgAttr1.attrs[i].value,msgAttr1.attrs[i].armyType,msgAttr1.attrs[i].attrId)
			arrs[1][i] = {}
			arrs[1][i].armyType = msgAttr1.attrs[i].armyType
			arrs[1][i].attrId = msgAttr1.attrs[i].attrId
			arrs[1][i].value = msgAttr1.attrs[i].value
            --print("1",i, arrs[1][i].value,arrs[1][i].armyType,arrs[1][i].attrId)
        end
    end

    arrs[2] = {}
    if msgAttr2.attrs ~= nil then
        for i =1,#msgAttr2.attrs,1 do
           -- print("2",i, msgAttr2.attrs[i].value,msgAttr2.attrs[i].armyType,msgAttr2.attrs[i].attrId)
            arrs[2][i] = {}
            arrs[2][i].armyType = msgAttr2.attrs[i].armyType
            arrs[2][i].attrId = msgAttr2.attrs[i].attrId
            arrs[2][i].value = msgAttr2.attrs[i].value
            --print("2" , i , arrs[2][i].value , arrs[2][i].armyType , arrs[2][i].attrId)
        end
    end
	
	for i =1,2,1 do
		--if #arrs[i] ~= 0 then
			BattlefieldReport.QuickSort(arrs[i],1,#arrs[i])
			for j=1,6,1 do
				if j <= #arrs[i] then
					buffRoot[i][j].text.text = TextMgr:GetText(BattlefieldReport.GetArmyTypeID(arrs[i][j].armyType)) .. TextMgr:GetText(BattlefieldReport.GetAttrTypeID(arrs[i][j].attrId))
					buffRoot[i][j].num.text = System.String.Format("{0:N1}%",  arrs[i][j].value)
					local targetValue = 0
					if i==1 then
						targetValue = BattlefieldReport.GetAttValue(arrs[1][j].armyType , arrs[1][j].attrId , arrs[2])
					else
						targetValue = BattlefieldReport.GetAttValue(arrs[2][j].armyType , arrs[2][j].attrId , arrs[1])
					end
					--buffRoot[i][j].arrowSpr.gameObject:SetActive(targetValue ~= 0)
					--print(i , arrs[i][j].value ,targetValue)
					local stateIcon = ""
					if arrs[i][j].value > targetValue then
						stateIcon = "icon_contrast1"
					elseif arrs[i][j].value == targetValue then
						stateIcon = "icon_contrast2"
					else
						stateIcon = "icon_contrast3"
					end
					buffRoot[i][j].arrowSpr.spriteName = stateIcon
				else
					buffRoot[i][j].text.text = TextMgr:GetText("ui_worldmap_45")
					buffRoot[i][j].num.text = ""
					buffRoot[i][j].arrowSpr.gameObject:SetActive(false)
				end
           -- end    
		end
	end
	
	--bg msg
	local msgACamp = reportMsg.misc.result.ACampPlayers
	local msgDCamp = reportMsg.misc.result.DCampPlayers
	local defendBuild = reportMsg.misc.target.entrytype
	local resultInfo = {}
	local isMoba = readMailData.category == MailMsg_pb.MailType_Moba
	local isGuildMoba = readMailData.category == MailMsg_pb.MailType_GuildMoba
	resultInfo[1] = BattlefieldReport.GetCampArmyResult(msgACamp , false , isMoba or isGuildMoba)
	resultInfo[2] = BattlefieldReport.GetCampArmyResult(msgDCamp , defendBuild == Common_pb.SceneEntryType_Home , isMoba or isGuildMoba)
	local soldierInfo = retortUI:Find("item_ReportInformation/soldierinfo")
		for i=1 , 2 , 1 do
			local trfTableName = "left"
			if i ~= 1 then
				
				local trfRightTable =  retortUI:Find("item_ReportInformation/bg_msg/bg_table_right")
				local trfRightTable1 =  retortUI:Find("item_ReportInformation/bg_msg/bg_table_right1")
				
				if readMailData.category == MailMsg_pb.MailType_Moba then
					trfTableName = "right"
					trfRightTable.gameObject:SetActive(true)
					trfRightTable1.gameObject:SetActive(false)
				else
					trfTableName = defendBuild == Common_pb.SceneEntryType_Home and "right1" or "right"
					trfRightTable.gameObject:SetActive(defendBuild ~= Common_pb.SceneEntryType_Home)
					trfRightTable1.gameObject:SetActive(defendBuild == Common_pb.SceneEntryType_Home)
				end
			end
			
			local trfIndex = 1
			for k , v in pairs(resultInfo[i]) do
				if v ~= nil then
					--print(string.format("item_ReportInformation/bg_msg/bg_table_%s/soldierinfo%s" , trfTableName , trfIndex) , i)
					local armyType = TextMgr:GetText(BattlefieldReport.GetArmyTypeID(v.armyType))
					local trf = retortUI:Find(string.format("item_ReportInformation/bg_msg/bg_table_%s/soldierinfo%s" , trfTableName , trfIndex))
					--print(string.format("item_ReportInformation/bg_msg/bg_table_%s/soldierinfo%s" , trfTableName , trfIndex))
					trf.gameObject:SetActive(true)
					trf:Find("title1"):GetComponent("UILabel").text = armyType
					trf:Find("title2"):GetComponent("UILabel").text = v.total
					trf:Find("title3"):GetComponent("UILabel").text = v.lost
					trf:Find("title4"):GetComponent("UILabel").text = v.kill
				end
				trfIndex = trfIndex + 1
			end
		end
	
	local warLossScoreLabel = retortUI:Find("item_ReportInformation/bg_msg/Label"):GetComponent("UILabel")
	local warLosshelp = retortUI:Find("item_ReportInformation/bg_msg/Sprite"):GetComponent("UIButton")
	SetClickCallback(warLosshelp.gameObject,  PVP_LuckyRotary_Help.Show)
	local warLossScore = 0
	for i=1 , #msgACamp do
		if msgACamp[i].uid == MainData.GetCharId() then
			warLossScore = msgACamp[i].WarLossScore
		end
	end
	for i=1 , #msgDCamp do
		if msgDCamp[i].uid == MainData.GetCharId() then
			warLossScore = msgDCamp[i].WarLossScore
		end
	end
	warLossScoreLabel.text = System.String.Format(TextMgr:GetText("PVP_LuckyRotary19") , warLossScore)
	warLossScoreLabel.gameObject:SetActive((not isMoba) and (not isGuildMoba))
	warLosshelp.gameObject:SetActive((not isMoba) and (not isGuildMoba))
	return retortUI:Find("item_ReportInformation"):GetComponent("UIWidget").height
end

local function ResetBgContetnt()
	--reset
	mailContent.bgMid.gameObject:SetActive(false)
	mailContent.bgMsg.gameObject:SetActive(false)
	mailContent.bgReward.gameObject:SetActive(false)
	mailContent.bgHero.gameObject:SetActive(false)
	mailContent.bgHistory.gameObject:SetActive(false)
	mailContent.bgRobRes.gameObject:SetActive(false)
	mailContent.bgBanner.gameObject:SetActive(false)
	mailContent.bgBattleDetail.gameObject:SetActive(false)
	mailContent.bgHistory.gameObject:SetActive(false)
	mailContent.bgRebelArmyAttack.gameObject:SetActive(false)
	mailContent.bgCommander.gameObject:SetActive(false)
	mailContent.bgPrisonerReward.gameObject:SetActive(false)
	mailContent.bgMobaMid.gameObject:SetActive(false)
	mailContent.bgMobaReward.gameObject:SetActive(false)
	
	local resetCo = coroutine.start(function()
		coroutine.step()
		if mailContent ~= nil then
			mailContent.scrollView:ResetPosition()
		end
	end)
end
local mailConfig =
{
	[Mail.MailReportType.MailReport_actmonster] = {"ShowReportContent" , "ShowRewardContent","ShowParticipantContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_monster] = {"ShowReportContent" , "ShowRewardContent","ShowParticipantContent","ShowBattleDetailContent"},
	--[Mail.MailReportType.MailReport_monster] = { "ShowReportContent" , "ShowBattleDetailContent"},
	--[Mail.MailReportType.MailReport_monster] = {"ShowTitleContent" ,"ShowBanner" ,"ShowRewardContent" ,"ShowHerosContent","ShowParticipantContent"},
	[Mail.MailReportType.MailReport_actmonsterfinder] = {"ShowTitleContent" , "ShowRewardContent" },
	[Mail.MailReportType.MailReport_player] = {"ShowReportContent" , "ShowRobResource", "ShowCommander", "ShowPrisonerReward" , "ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_defence] = {"ShowReportContent" , "ShowRobResource", "ShowCommander","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_robres] = {"ShowReportContent" , "ShowRobResource","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_robclamp] = {"ShowReportContent" , "ShowRobResource","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_robresdefence] = {"ShowReportContent" , "ShowRobResource","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_robcampdefence] = {"ShowReportContent" , "ShowRobResource","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_guildmonsterRepoty] = {"ShowReportContent" , "ShowRewardContent","ShowParticipantContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_siegeAttack] = {"ShowReportContent", "ShowRebelAttack","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_siegeHelp] = {"ShowReportContent", "ShowRebelHelp","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_fort] = {"ShowReportContent","ShowBattleDetailContent"},

	[Mail.MailReportType.MailReport_defGovt] = {"ShowReportContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_atkGovt] = {"ShowReportContent","ShowRewardContent" , "ShowBattleDetailContent"},--
	[Mail.MailReportType.MailReport_gatherGovt] = {"ShowReportContent","ShowRewardContent" , "ShowBattleDetailContent"},

	[Mail.MailReportType.MailReport_defTurret] = {"ShowReportContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_atkTurret] = {"ShowReportContent","ShowRewardContent" , "ShowBattleDetailContent"},--
	[Mail.MailReportType.MailReport_gatherTurret] = {"ShowReportContent","ShowRewardContent" , "ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_atkEliter] = {"ShowReportContent","ShowEliteRewardContent","ShowEliteParticipantContent","ShowBattleDetailContent"},
	
	[Mail.MailReportType.MailReport_defStronghold] = {"ShowReportContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_atkStronghold] = {"ShowReportContent","ShowRewardContent" , "ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_gathStronghold] = {"ShowReportContent","ShowRewardContent" , "ShowBattleDetailContent"},
	
	[Mail.MailReportType.MailReport_defFortress] = {"ShowReportContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_atkFortress] = {"ShowReportContent","ShowRewardContent"  , "ShowBattleDetailContent"},
	[Mail.MailReportType.MailReport_gathFortress] = {"ShowReportContent","ShowRewardContent" , "ShowBattleDetailContent"},
	
	[Mail.MailReportType.MailReport_prisonerRewardSet] = {"ShowTitleContent", "ShowPrisonerReward"},
	[Mail.MailReportType.MailReport_prisonerRewardOpt] = {"ShowTitleContent", "ShowPrisonerReward"},
	[Mail.MailReportType.MailReport_prisonerFlee] = {"ShowTitleContent", "ShowCommander"},
	
	
	[Mail.MailReportType.MailReort_atkWorldCity] = {"ShowReportContent","ShowRewardContent","ShowBattleDetailContent"},
	
	
	--Moba
	[Mail.MailReportType.MobaMailReport_monster] = {"MobaShowReportContent" , "ShowMobaRewardContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MobaMailReport_player] = {"MobaShowReportContent" , "ShowMobaRewardContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MobaMailReport_defence] = {"MobaShowReportContent" , "ShowMobaRewardContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MobaMailReport_gatherTarget] = {"MobaShowReportContent" , "ShowMobaRewardContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MobaMailReport_atkBuild] = {"MobaShowReportContent" , "ShowMobaRewardContent","ShowBattleDetailContent"},
	[Mail.MailReportType.MobaMailReport_defBuild] = {"MobaShowReportContent" , "ShowMobaRewardContent","ShowBattleDetailContent"},

}
function ShowContent()
	local bgHeight = bgStartPos
	local readMailData = MailListData.GetMailDataById(curMailId)
	ResetBgContetnt()

	local cfg = mailConfig[readMailData.subtype]
	for i , v in ipairs(cfg) do
		if v == "ShowReportContent" then
			if curReadMailMsg.misc.result ~= nil and curReadMailMsg.misc.result.input ~= nil then
				mailContent.bgMsg.gameObject:SetActive(false)
				local reportBgHeight = ShowReportContent(bgHeight , curReadMailMsg , mailContent.bgMid , readMailData , nil)
				bgHeight = bgHeight - reportBgHeight
			end
		elseif v == "MobaShowReportContent" then
			if curReadMailMsg.misc.result ~= nil and curReadMailMsg.misc.result.input ~= nil then
				mailContent.bgMsg.gameObject:SetActive(false)
				local reportBgHeight = MobaShowReportContent(bgHeight , curReadMailMsg , mailContent.bgMobaMid , readMailData , nil)
				bgHeight = bgHeight - reportBgHeight
			end
		elseif v == "ShowTitleContent" then
			mailContent.bgMid.gameObject:SetActive(false)
			local reportBgHeight = ShowTitleContent(bgHeight , curReadMailMsg , mailContent.bgMsg , readMailData , nil)
			bgHeight = bgHeight - reportBgHeight
		elseif v == "ShowRewardContent" then
			if curReadMailMsg.misc.attachShow ~= nil and curReadMailMsg.misc.attachShow.data ~= nil and #curReadMailMsg.misc.attachShow.data > 0 then
				local rewardBgHeight = ShowRewardContent(bgHeight , curReadMailMsg , mailContent.bgReward , readMailData , nil)
				bgHeight = bgHeight - rewardBgHeight
			end
		elseif v == "ShowMobaRewardContent" then
			mailContent.bgMobaReward.gameObject:SetActive(false)
			local reportBgHeight = ShowMobaRewardContent(bgHeight , curReadMailMsg , mailContent.bgMobaReward , readMailData , nil)
			bgHeight = bgHeight - reportBgHeight
		elseif v == "ShowRobResource" then
			--if curReadMailMsg.misc.robres ~= nil and curReadMailMsg.misc.robres.res ~= nil and #curReadMailMsg.misc.robres.res > 0 then
				local bgRobHeight = ShowRobResource(bgHeight , curReadMailMsg , mailContent.bgRobRes , readMailData , nil)
				bgHeight = bgHeight - bgRobHeight
			--end
		elseif v == "ShowCommander" then
            if curReadMailMsg.misc:HasField("prisoner") and (curReadMailMsg.misc.prisoner:HasField("detainInfo") or #curReadMailMsg.misc.prisoner.prisonerInfo > 0) then
                local bgCommanderHeight = ShowCommander(bgHeight, curReadMailMsg, mailContent.bgCommander, readMailData, nil)
                bgHeight = bgHeight - bgCommanderHeight
            end
		elseif v == "ShowPrisonerReward" then
            if curReadMailMsg.misc:HasField("prisoner") and curReadMailMsg.misc.prisoner:HasField("rewardMoney") then
                local bgPrisonerRewardHeight = ShowPrisonerReward(bgHeight, curReadMailMsg, mailContent.bgPrisonerReward, readMailData, nil)
                bgHeight = bgHeight - bgPrisonerRewardHeight
            end
		elseif v == "ShowParticipantContent" then
			local resultInfo = curReadMailMsg.misc.result
			if resultInfo ~= nil and resultInfo.input ~= nil and resultInfo.input.user ~= nil then
				local bgPartHeight = ShowParticipantContent(bgHeight , curReadMailMsg , mailContent.bgHistory , readMailData , readMailData.subtype == Mail.MailReportType.MailReport_actmonsterfinder)
				bgHeight = bgHeight - bgPartHeight
			end
		elseif v == "ShowRebelAttack" then
			local bgRebelHeight = ShowRebelAttack(bgHeight , curReadMailMsg , mailContent.bgRebelArmyAttack , readMailData , nil)
			bgHeight = bgHeight - bgRebelHeight
		elseif v == "ShowRebelHelp" then
			local bgRebelHeight = ShowRebelHelp(bgHeight , curReadMailMsg , mailContent.bgRebelArmyAttack , readMailData , nil)
			bgHeight = bgHeight - bgRebelHeight
		elseif v == "ShowHerosContent" then
			local bgHeroHeight = ShowHerosContent(bgHeight , curReadMailMsg , mailContent.bgHero , readMailData , nil)
			bgHeight = bgHeight - bgHeroHeight
		elseif v == "ShowBanner" then
			local bgBannerHeight = ShowBanner(bgHeight , curReadMailMsg , mailContent.bgBanner , readMailData , nil)
			bgHeight = bgHeight - bgBannerHeight
		elseif v == "ShowEliteRewardContent" then
			local rewardBgHeight = ShowEliteRewardContent(bgHeight , curReadMailMsg , mailContent.bgReward , readMailData , nil)
			bgHeight = bgHeight - rewardBgHeight
		elseif v == "ShowEliteParticipantContent" then
			local resultInfo = curReadMailMsg.misc.result
			if resultInfo ~= nil and resultInfo.input ~= nil and resultInfo.input.user ~= nil then
				local bgPartHeight = ShowEliteParticipantContent(bgHeight , curReadMailMsg , mailContent.bgHistory , readMailData ,false)
				bgHeight = bgHeight - bgPartHeight
			end
		elseif v == "ShowBattleDetailContent" then
			local detailBgHeight = ShowBattleDetailContent(bgHeight , curReadMailMsg , mailContent.bgBattleDetail , readMailData , nil)
			bgHeight = bgHeight - detailBgHeight
		end
	end
	
	
end

function ReadMail(mailid , mailMsg , dirShow)
	directShow = dirShow
	curMailId = mailid
	curReadMailMsg = mailMsg
	local readMailData = MailListData.GetMailDataById(curMailId)
	if readMailData == nil then
		--print("readmail" .. curMailId)
		return
	end
	local mainMailDocUI = mailContent.mainMailDocUI
	if mainMailDocUI == nil then
		return
	end
	
 	local reportUI = mainMailDocUI:Find("bg_frane")
	reportUI.gameObject:SetActive(true)
	
	local readMailData = MailListData.GetMailDataById(curMailId)
	ShowContent()
	
	local shareBtn = mainMailDocUI:Find("bg_frane/bg_bottom/Grid/btn_share")
	if readMailData.subtype == Mail.MailReportType.MailReport_monster
		or readMailData.subtype == Mail.MailReportType.MailReport_siegeAttack
		or readMailData.subtype == Mail.MailReportType.MailReport_siegeHelp then
		--shareBtn.localScale = Vector3(0,1,1)
		shareBtn.gameObject:SetActive(false)
	else
		--shareBtn.localScale = Vector3(1,1,1)
		shareBtn.gameObject:SetActive(true)
	end
	
	local saveBtn = mainMailDocUI:Find("bg_frane/bg_bottom/Grid/btn_ save")
	saveBtn.gameObject:SetActive(readMailData.category ~= MailMsg_pb.MailType_Moba and readMailData.category ~= MailMsg_pb.MailType_GuildMoba)

end

function OpenUI()
	Tooltip.HideItemTip()
	
	
	local mainMailDocUI = mailContent.mainMailDocUI
	local nextMail
	local preMail
	if Mail.GetTabSelect() == 4 then 
		nextMail = MailListData.GetSavedNextMail(curMailId)
		preMail = MailListData.GetSavedPreMail(curMailId)
	else
		nextMail = MailListData.GetNextMail(curMailId)
		preMail = MailListData.GetPreMail(curMailId)
	end

	local nextBtn = mainMailDocUI:Find("bg_frane/bg_bottom/btn_next"):GetComponent("UIButton")
	nextBtn.gameObject:SetActive(nextMail ~= nil and not directShow)
	SetClickCallback(nextBtn.gameObject , function(go)
		local nextMailData = MailListData.GetMailDataById(nextMail.id)
		print("next" .. nextMail.id)
		Mail.RequestReadMail(nextMail, nil , directShow)
	end)
	
	local previousBtn = mainMailDocUI:Find("bg_frane/bg_bottom/btn_previous"):GetComponent("UIButton")
	previousBtn.gameObject:SetActive(preMail ~= nil and not directShow)
	SetClickCallback(previousBtn.gameObject , function(go)
		local preMailData = MailListData.GetMailDataById(preMail.id)
		print("pre" .. preMailData.id)
		Mail.RequestReadMail(preMailData, nil , directShow)
	end)
	
	local closeBtn = mailContent.mainMailDocUI:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		if directShow then
			Hide()
			Mail.Hide()
		else
			Hide()
		end
	end)
	SetClickCallback(mailContent.mainMailDocUI.gameObject , function(go)
		if directShow then
			Hide()
			Mail.Hide()
		else
			Hide()
		end
	end)
	
	
	local readMailData = MailListData.GetMailDataById(curMailId)
	local saveBtn = mainMailDocUI:Find("bg_frane/bg_bottom/Grid/btn_ save"):GetComponent("UIButton")
	saveBtn.gameObject:SetActive(not readMailData.saved)
	saveBtn.gameObject:SetActive(readMailData.category ~= MailMsg_pb.MailType_Moba and readMailData.category ~= MailMsg_pb.MailType_GuildMoba)

	SetClickCallback(saveBtn.gameObject , function(go)
		print("saveBtn")
		Mail.SaveMail(curMailId)
		if directShow then
			Hide()
			Mail.Hide()
		else
			Hide()
		end
	end)
	
	local delBtn = mailContent.mainMailDocUI:Find("bg_frane/bg_bottom/Grid/btn_del"):GetComponent("UIButton")
	SetClickCallback(delBtn.gameObject , function(go)
		print("delBtn")
		--local delist = {curMailId}
		local delist = {}
		delist[1] = {}
		delist[1].id = curMailId
		if directShow then
			Hide()
			Mail.Hide()
		else
			Hide()
		end
		Mail.DeleteMail(delist)
	end)
	
	local shareBtn = mailContent.mainMailDocUI:Find("bg_frane/bg_bottom/Grid/btn_share"):GetComponent("UIButton")
	shareBtn.gameObject:SetActive(true)
	SetClickCallback(shareBtn.gameObject , function(go)
		ShowShare()
	end)
	
end

function Init(mailTransform)
	
end

function Hide()
	Global.CloseUI(_M)
end

function CloseUI()
	--[[Tooltip.HideItemTip()
	curReadMailMsg = nil
	directShow = false
	
	curReadMailMsg = nil
	selfFormationData = nil
    targatFormationData = nil
	formationPrefab = nil
	mailContent = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)]]
	Hide()
end

function Awake()
	mailContent = {}
	mailContent.mainMailDocUI = transform:Find("MailPve")
	mailContent.bgMid = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/bg_mid")
	mailContent.bgMsg = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/bg_msg")
	mailContent.bgReward = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_reward")
	mailContent.bgHero = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_hero")
	mailContent.bgHistory = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_history")
	mailContent.bgRobRes = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_resource")
	mailContent.bgRebelArmyAttack = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_RebelArmyAttack")
	mailContent.bgBanner = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_banner")
	mailContent.bgBattleDetail = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_ReportInformation")
	mailContent.bgCommander = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_commander")
	mailContent.bgPrisonerReward = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_ransom")
	--Moba
	mailContent.bgMobaMid = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/bg_mid_1")
	mailContent.bgMobaReward = mailContent.mainMailDocUI:Find("bg_frane/Scroll View/bg_collection/item_rewardmoba")
	
	mailContent.rewardTypeGridItem = mailContent.mainMailDocUI:Find("bg1")
	mailContent.rewardListGridItem = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	mailContent.scrollView =  mailContent.mainMailDocUI:Find("bg_frane/Scroll View"):GetComponent("UIScrollView")
	
	bgStartPos = 250--mailContent.bgBanner.localPosition.y
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Close()
	Tooltip.HideItemTip()
	curReadMailMsg = nil
	directShow = false
	
	curReadMailMsg = nil
	selfFormationData = nil
    targatFormationData = nil
	formationPrefab = nil
	mailContent = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	
end


function Show(mailid , mailMsg , dirShow)
	Global.OpenUI(_M)
	
	directShow = dirShow
	curMailId = mailid
	curReadMailMsg = mailMsg
	local readMailData = MailListData.GetMailDataById(curMailId)
	if readMailData == nil then
		--print("readmail" .. curMailId)
		return
	end
	
	OpenUI()
	ReadMail(mailid , mailMsg , dirShow)
	
end