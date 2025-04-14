module("MailReportDoc", package.seeall)

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

local curMailId
local mailSubtype
local curReadMailMsg
local mailDocContent = {}

local reportMsg

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
	end

    --fort
    if army.fort ~= nil and army.fort.subType > 0 then        
        return 666 --叛军头像
    end

    if army.centerBuild ~= nil and army.centerBuild.uid ~= 0 then        
        return 777 --中央集团头像
    end	

    if army.mobabuild ~= nil and army.mobabuild.buildingid ~= 0 then        
        return 666 
    end	

	if army.user ~= nil and army.user.face ~= nil then
		return army.user.face
	end
	
	return ""
end

function GetReportShareTitle(reportMsg)
	local title = ""
	local lenLimit = 15
	local vsStr = "  [ff0000]VS[-]  "
	
	local player1Guile = ""
	local strIndex = 1
	if reportMsg.misc.source.guildBanner ~= "" then
		player1Guile = "[f1cf63][" .. reportMsg.misc.source.guildBanner .. "][-]"
		strIndex = 13 + Global.utfstrlen(reportMsg.misc.source.guildBanner)
	end
	
	--local player1Guile = "[" .. 111 .. "]"
	local player1 = reportMsg.misc.result.input.user.team1[1].user.name
	local play1Len = Global.utfstrlen(player1)

	local player1Str = ""
	if play1Len > 10 then
		player1Str = Global.GetSubString(player1,0, 10) .. ".."--string.sub(player1 , 1 , 10) .. ".."
	else
		player1Str = player1
	end
	player1Str = player1Guile .. player1Str
	
	--print(player1Str , play1Len , string.len(player1) )
	
	
	local player2Guile = ""
	if reportMsg.misc.target.guildBanner ~= "" then
		player2Guile = "[f1cf63][" .. reportMsg.misc.target.guildBanner .. "][-]"
	end
	
	--local player1Guile = "[" .. 111 .. "]"
	local player2 = reportMsg.misc.result.input.user.team2[1].user.name
	if reportMsg.misc.result.input.user.team2[1].monster ~= nil and reportMsg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_ActMonster then--攻击炮车
		player2 = TextMgr:GetText(reportMsg.misc.target.name)
    end

    --fort 
	if reportMsg.misc.result.input.user.team2[1].fort ~= nil and reportMsg.misc.result.input.user.team2[1].fort.subType > 0 then--攻击炮车
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

	if reportMsg.misc.result.input.user.team2[1].mobabuild ~= nil then
		local build_data = TableMgr:GetMobaMapBuildingDataByID(reportMsg.misc.result.input.user.team2[1].mobabuild.buildingid)
		if build_data then
			player2 = TextMgr:GetText(build_data.Name)
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
	
	--print(player2Str , play2Len)
	return player1Str , vsStr , player2Str
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
		print(army.baseid , army.level)
		local solider = Barrack.GetAramInfo(army.baseid , army.level)
		print(solider.BarrackId)
	
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
	Global.CheckBattleReportEx(curReadMailMsg ,mailSubtype , function()
		print("report end function")
		
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


function ShowContent(msg , retortUI , mailData , formPrefab)
	reportMsg = msg
	curReadMailMsg = reportMsg
	--local mainMailDocUI = Mail.GetMailUI("MailReportDoc")
	
	local readMailData = mailData--MailListData.GetMailDataById(curMailId)
	mailSubtype = readMailData.subtype
	print("SSSSSSSSSSSSSSSSS ",curMailId)
	--资源掠夺
	local resFood = retortUI:Find("bg_mid/bg_left/bg_resource/bg_food/txt_food"):GetComponent("UILabel")
	resFood.text = 0
	
	local resOil = retortUI:Find("bg_mid/bg_left/bg_resource/bg_oil/txt_oil"):GetComponent("UILabel")
	resOil.text = 0
	
	local resIron = retortUI:Find("bg_mid/bg_left/bg_resource/bg_iron/txt_iron"):GetComponent("UILabel")
	resIron.text = 0
	
	local resElec = retortUI:Find("bg_mid/bg_left/bg_resource/bg_electric/txt_electric"):GetComponent("UILabel")
	resElec.text = 0
	
	--双方阵形
	selfFormationData = reportMsg.misc.result.input.user.team1[1]
	targatFormationData = reportMsg.misc.result.input.user.team2[1]
	local formTrf = retortUI:Find("bg_mid/bg_left/bg_formation")
	if formTrf.childCount == 0 then
		local battleFormation = NGUITools.AddChild(formTrf.gameObject, formPrefab).transform
	end
	
	formationSmall = BMFormation(retortUI:Find("bg_mid/bg_left/bg_formation/battle_formation(Clone)/Embattle"))
    formationSmall:SetPVPMailLeftFormationData(selfFormationData)
    formationSmall:SetPVPMailRightFormationData(targatFormationData)
    formationSmall:Awake()

	local coordBtn = retortUI:Find("bg_mid/bg_title/btn_coord"):GetComponent("UIButton")
	SetClickCallback(coordBtn.gameObject , function()
		--ShowEmbattle(reportMsg)
		if reportMsg.misc.result.input.mobaSceneId ~= nil and reportMsg.misc.result.input.mobaSceneId > 0 and reportMsg.misc.result.input.battleType ~= 4 then
			MobaChat.GoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
		else
			Chat.GoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
			--MainCityUI.ShowWorldMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y, true)
			--Mail_share.Hide()
			--Mail.Hide()
			
			--GUIMgr:CloseMenu("Chat")
		
		end
    end)    

	--战斗简报
	local winlose = 1
	local midTitle = retortUI:Find("bg_mid/bg_title/txt_title"):GetComponent("UILabel")
	if cunstomTitleFunc ~= nil then
		midTitle.text,winlose = cunstomTitleFunc("Title")
	else
        midTitle.text , winlose = MailReportDocNew.GetWinLose(readMailData , reportMsg)
    end
	
	if winlose == 1 then
		midTitle.gradientTop = NGUIMath.HexToColor(0xB8F992FF)
		midTitle.gradientBottom = NGUIMath.HexToColor(0x2FB017FF)
	else
		midTitle.gradientTop = NGUIMath.HexToColor(0xFF7676FF)
		midTitle.gradientBottom = NGUIMath.HexToColor(0xFF0000FF)
	end
	
	
	--资源得失
	local robMoney = reportMsg.misc.robres.res
	for i=1 , #robMoney do
		if robMoney[i].id == 3 then
			resFood.text = Global.ExchangeValue(robMoney[i].num)
		elseif robMoney[i].id == 4 then
			resOil.text = Global.ExchangeValue(robMoney[i].num)
		elseif robMoney[i].id == 5 then
			resIron.text = Global.ExchangeValue(robMoney[i].num)
		elseif robMoney[i].id == 6 then
			resElec.text = Global.ExchangeValue(robMoney[i].num)
		end
	end
	if winlose == 0 then
		if resFood.text ~= "0" then
			resFood.text = "[ff0000]-" .. resFood.text .. "[-]"
		end
		if resOil.text ~= "0" then
			resOil.text = "[ff0000]-" .. resOil.text .. "[-]"
		end
		if resIron.text ~= "0" then
			resIron.text = "[ff0000]-" .. resIron.text .. "[-]"
		end
		if resElec.text ~= "0" then
			resElec.text = "[ff0000]-" .. resElec.text .. "[-]"
		end
	end
	
	
	
	--
	local midTime = retortUI:Find("bg_mid/bg_title/text_time"):GetComponent("UILabel")
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss")--timeText[1] .. "     " .. timeText[2]
	midTime.text = showTime
	
	--[[local team1Guild = ""
	if msg.misc.source.guildBanner ~= nil and  msg.misc.source.guildBanner ~= "" then
		team1Guild = "[" .. msg.misc.source.guildBanner .. "]"
	end
	local team2Guild = ""
	if msg.misc.target.guildBanner ~= nil and msg.misc.target.guildBanner ~= "" then
		team2Guild = "[" .. msg.misc.target.guildBanner .. "]"
	end]]
	local player1 , vsStr , player2 = MailReportDocNew.GetReportShareTitle(reportMsg , readMailData.subtype)
	
	
	
	local playerSelfHead =  retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_attack/icon_head_attack"):GetComponent("UITexture")
	playerSelfHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", GetArmyFace(reportMsg.misc.result.input.user.team1 , 1 ))--reportMsg.misc.result.input.user.team1[1].user.face)
	local playerSelfName =  retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_attack/name_attack"):GetComponent("UILabel")
	playerSelfName.text = player1--team1Guild .. msg.misc.result.input.user.team1[1].user.name
	local playerSelfCoord =  retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_attack/coordinate_attack"):GetComponent("UILabel")
	playerSelfCoord.text = System.String.Format("#1 X:{0} Y:{1}" ,  reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y)
	SetClickCallback(playerSelfCoord.gameObject , function(go)
		if reportMsg.misc.result.input.mobaSceneId ~= nil and reportMsg.misc.result.input.mobaSceneId > 0 and reportMsg.misc.result.input.battleType ~= 4 then
			MobaChat.GoMap(reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y)
		else
			Chat.GoMap(reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y)
		end
		--MainCityUI.ShowWorldMap(reportMsg.misc.source.pos.x , reportMsg.misc.source.pos.y, true)
		--Mail.Hide()
		--Mail_share.Hide()
		--GUIMgr:CloseMenu("Chat")		
	end)
	local selgHeadBtn = retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_attack")
	SetClickCallback(selgHeadBtn.gameObject , function(go)
		if reportMsg.misc.result.input.mobaSceneId ~= nil and reportMsg.misc.result.input.mobaSceneId > 0 and reportMsg.misc.result.input.battleType ~= 4 then
			local charid = 0 
			if readMailData.subtype == Mail.MailReportType.MailReport_player or 
				readMailData.subtype == Mail.MailReportType.MailReport_defence or 
				readMailData.subtype == Mail.MailReportType.MobaMailReport_player then
				charid = reportMsg.misc.source.uid
			end
			MobaPersonalInfo.Show(charid)
			return
		end
		
		
		if readMailData.subtype == Mail.MailReportType.MailReport_player or 
		   readMailData.subtype == Mail.MailReportType.MailReport_defence then
			OtherInfo.RequestShow(reportMsg.misc.source.uid)
		end
	end)
	
	--[[if msg.misc.result.input.user.team1[2].actMonster ~= nil
	--if readMailData.subtype == MailMsg_pb.MailReport_actmonster then
		playerSelfHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", msg.misc.source.face)
		playerSelfName.text = msg.misc.source.name
	end]]
	
	--local targetHead = retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_defence/icon_head_defence"):GetComponent("UITexture")
	--targetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/",GetArmyFace(reportMsg.misc.result.input.user.team2 , 1 ))--reportMsg.misc.result.input.user.team2[1].user.face)
	local targetHead = retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_defence/icon_head_defence"):GetComponent("UITexture")
	targetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/",
	cunstomTitleFunc == nil and MailReportDocNew.GetArmyFace(reportMsg.misc.result.input.user.team2 , 1 ) or cunstomTitleFunc("player2face"))
	
	
	local targetName =  retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_defence/name_defence"):GetComponent("UILabel")
	targetName.text = player2--team2Guild .. msg.misc.result.input.user.team2[1].user.name
	local targetCoord =  retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_defence/coordinate_defence"):GetComponent("UILabel")
	targetCoord.text = System.String.Format("#1 X:{0} Y:{1}" , reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
	SetClickCallback(targetCoord.gameObject , function(go)
		if reportMsg.misc.result.input.mobaSceneId ~= nil and reportMsg.misc.result.input.mobaSceneId > 0 and reportMsg.misc.result.input.battleType ~= 4 then
			MobaChat.GoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
		else
			Chat.GoMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y)
		end
		
		--MainCityUI.ShowWorldMap(reportMsg.misc.target.pos.x , reportMsg.misc.target.pos.y, true)
		--Mail.Hide()
		--Mail_share.Hide()
		--GUIMgr:CloseMenu("Chat")		
	end)
	local tagetHeadBtn = retortUI:Find("bg_mid/bg_right/bg_head_top/bg_head_defence")
	SetClickCallback(tagetHeadBtn.gameObject , function(go)
		if reportMsg.misc.result.input.mobaSceneId ~= nil and reportMsg.misc.result.input.mobaSceneId > 0 and reportMsg.misc.result.input.battleType ~= 4 then
			local charid = 0 
			if readMailData.subtype == Mail.MailReportType.MailReport_player or 
				readMailData.subtype == Mail.MailReportType.MailReport_defence or
				readMailData.subtype == Mail.MailReportType.MobaMailReport_player then
				charid = reportMsg.misc.result.DCampPlayers[1].uid
			end
			MobaPersonalInfo.Show(charid)
			return
		end
		
		OtherInfo.RequestShow(reportMsg.misc.result.DCampPlayers[1].uid)
		if readMailData.subtype == Mail.MailReportType.MailReport_player or 
		   readMailData.subtype == Mail.MailReportType.MailReport_defence then
			local charid = 0
			if reportMsg.misc.result.DCampPlayers ~= nil and #reportMsg.misc.result.DCampPlayers > 0 then
				charid = reportMsg.misc.result.DCampPlayers[1].uid
			end
			if charid > 0 then
				OtherInfo.RequestShow(reportMsg.misc.result.DCampPlayers[1].uid)
			end
		end
	end)
	--if readMailData.subtype == MailMsg_pb.MailReport_actmonster then
	--[[if reportMsg.misc.result.input.user.team2[1].actMonster ~= nil and  msg.misc.result.input.user.team2[1].actMonster > 0 then
		targetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", reportMsg.misc.target.face)
		targetName.text = TextMgr:GetText(reportMsg.misc.target.name)
	end]]
	
	local property = retortUI:Find("bg_mid/bg_right/bg_property")
	ResetContent(property)
	
	local resultShow = reportMsg.misc.result
	--如果对方没有部队，屏蔽战报按钮
	local battleReport = retortUI:Find("bg_mid/bg_right/bg_information/btn_report"):GetComponent("UIButton")
	SetClickCallback(battleReport.gameObject , CheckBattleReport)
	battleReport.gameObject:SetActive(false)
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
		if resultShow.ArmyTotalNum[1] == resultShow.ArmyDeadNum[1] and winlose == 0 then
			for i=1 , 6 ,1 do
				result[i].right = "?????"
			end
			battleReport.gameObject:SetActive(false)
		end
		
		--set show value
		for i=1 , 6 , 1 do
			local pro1_attr = property:Find(System.String.Format( "info_property ({0})/txt_attack" , i)):GetComponent("UILabel")
			pro1_attr.text = result[i].left
			local pro1_def = property:Find(System.String.Format("info_property ({0})/txt_defence" , i)):GetComponent("UILabel")
			pro1_def.text = result[i].right
		end
	end
	
	--[[if reportMsg.misc.result.input.user.team2[1].army == nil or (#reportMsg.misc.result.input.user.team2[1].army) <= 0 then
		battleReport.gameObject:SetActive(false)
	else
		battleReport.gameObject:SetActive(true)
	end]]
	
	return BattleResult
end

local function ShareReport(chanel)
	local mainMailDocUI = Mail.GetMailUI("MailReportDoc")
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	local shareContent = mainMailDocUI.go:Find("share")
	shareContent.gameObject:SetActive(false)
	
	FloatText.Show(TextMgr:GetText("ui_worldmap_83"), Color.green)
	
	local reportId = curReadMailMsg.misc.reportid
	local playerName = curReadMailMsg.misc.result.input.user.team1[1].user.name
	local targetName = curReadMailMsg.misc.result.input.user.team2[1].user.name
	if curReadMailMsg.misc.result.input.user.team2[1].monster ~= nil and curReadMailMsg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_ActMonster then--攻击炮车
		targetName = TextMgr:GetText(curReadMailMsg.misc.target.name)
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
					.. targetGuild
					
	send.content = playerGuild .. playerName .. "    vs    " .. targetGuild .. targetName--Global.GetReportShareTitle(curReadMailMsg)
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 3
	send.senderguildname = ""
	if UnionInfoData.HasUnion() then
		send.senderguildname = UnionInfoData.GetData().guildInfo.banner
	end
	Chat.SendContent(send)
end

local function ShowShare()
	local mainMailDocUI = Mail.GetMailUI("MailReportDoc")
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	local shareContent = mainMailDocUI.go:Find("share")
	shareContent.gameObject:SetActive(true)
	
	--[[local playerSelfName = shareContent:Find("Container/bg_frane/mid/text"):GetComponent("UILabel")
	playerSelfName.text = curReadMailMsg.misc.result.input.user.team1[1].user.name
	
	local playerTeargetName = shareContent:Find("Container/bg_frane/mid/text01"):GetComponent("UILabel")
	playerTeargetName.text = curReadMailMsg.misc.result.input.user.team2[1].user.name]]
	local shareTitle = shareContent:Find("Container/bg_frane/mid/text"):GetComponent("UILabel")
	local player1 , vsStr , player2 = GetReportShareTitle(curReadMailMsg)
	shareTitle.text = player1 .. vsStr .. player2
	
	local share2PublicBtn = shareContent:Find("Container/bg_frane/war zone"):GetComponent("UIButton")
	SetClickCallback(share2PublicBtn.gameObject , function(go)
		ShareReport(ChatMsg_pb.chanel_world)
		
	end)
	
	local share2unionBtn = shareContent:Find("Container/bg_frane/union"):GetComponent("UIButton")
	SetClickCallback(share2unionBtn.gameObject , function(go)
		if not UnionInfoData.HasUnion() then
			FloatText.Show(TextMgr:GetText("mail_ui63") , Color.white)
			return
		end
		local contentInput = shareContent:Find("Container/bg_frane/frame_input"):GetComponent("UIInput").value
		ShareReport(ChatMsg_pb.chanel_guild)
	end)
	
	local closeBtn = shareContent:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		shareContent.gameObject:SetActive(false)
	end)
end



function ReadMail(mailid , mailMsg)
	curMailId = mailid
	curReadMailMsg = mailMsg
	local readMailData = MailListData.GetMailDataById(curMailId)
	if readMailData == nil then
		--print("readmail" .. curMailId)
		return
	end
	local mainMailDocUI = Mail.GetMailUI("MailReportDoc")
	Mail.OpenMailUI("MailReportDoc")
	if mainMailDocUI == nil then
		return
	end
	local reportUI = mainMailDocUI.go:Find("bg_frane")
	reportUI.gameObject:SetActive(true)
	
	local readMailData = MailListData.GetMailDataById(curMailId)
	ShowContent(curReadMailMsg , reportUI , readMailData , formationPrefab)
	--标记是否已读
	--[[if readMailData.status == MailMsg_pb.MailStatus_New then
	local req = MailMsg_pb.MsgUserMailReadRequest()
	req.mailid = curMailId
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailReadRequest, req, MailMsg_pb.MsgUserMailReadResponse, function(msg)
		if msg.code == 0 then
			MailListData.UpdateMailStatus(curMailId , MailMsg_pb.MailStatus_Readed)
			Mail.OpenMailUI("MailReportDoc")
			ShowContent(msg)
		else
			print(msg.code)
		end
        end)
	--end]]
	
	
	
end

function OpenUI()
	Tooltip.HideItemTip()

	local mainMailDocUI = Mail.GetMailUI("MailReportDoc")
	local nextMail
	local preMail
	if Mail.GetTabSelect() == 4 then 
		nextMail = MailListData.GetSavedNextMail(curMailId)
		preMail = MailListData.GetSavedPreMail(curMailId)
	else
		nextMail = MailListData.GetNextMail(curMailId)
		preMail = MailListData.GetPreMail(curMailId)
	end

	local nextBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/btn_next"):GetComponent("UIButton")
	if nextMail ~= nil then
		nextBtn.gameObject:SetActive(true)
	else
		nextBtn.gameObject:SetActive(false)
	end
	
	local previousBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/btn_previous"):GetComponent("UIButton")
	if preMail ~= nil then
		previousBtn.gameObject:SetActive(true)
	else
		previousBtn.gameObject:SetActive(false)
	end
	
	local readMailData = MailListData.GetMailDataById(curMailId)
	local saveBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/Grid/btn_ save"):GetComponent("UIButton")
	if readMailData.saved then
		saveBtn.gameObject:SetActive(false)
	else
		saveBtn.gameObject:SetActive(true)
	end
end

function Init(mailTransform)
	local mainMailDocUI = Mail.GetMailUI("MailReportDoc")
	formationPrefab = ResourceLibrary.GetUIPrefab("CommonItem/battle_formation")
	
	local closeBtn = mainMailDocUI.go:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		Mail.OpenMailUI("Container")
	end)
	SetClickCallback(mainMailDocUI.go.gameObject , function(go)
		Mail.OpenMailUI("Container")
	end)
	
	local delBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/Grid/btn_del"):GetComponent("UIButton")
	SetClickCallback(delBtn.gameObject , function(go)
		print("delBtn")
		Mail.OpenMailUI("Container")
		--local delist = {curMailId}
		local delist = {}
		delist[1] = {}
		delist[1].id = curMailId
		Mail.DeleteMail(delist)
	end)
	
	local saveBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/Grid/btn_ save"):GetComponent("UIButton")
	SetClickCallback(saveBtn.gameObject , function(go)
		print("saveBtn")
		Mail.SaveMail(curMailId)
		Mail.OpenMailUI("Container")
	end)
	
	local shareBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/Grid/btn_share"):GetComponent("UIButton")
	shareBtn.gameObject:SetActive(true)
	SetClickCallback(shareBtn.gameObject , function(go)
		ShowShare()
	end)
	
	local previousBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/btn_previous"):GetComponent("UIButton")
	SetClickCallback(previousBtn.gameObject , function(go)
		print("previousBtn")
		local preMail 
		if Mail.GetTabSelect() == 4 then
			preMail = MailListData.GetSavedPreMail(curMailId)
		else
			preMail = MailListData.GetPreMail(curMailId)
		end
		
		local preMailData = MailListData.GetMailDataById(preMail.id)
		print("pre" .. preMailData.id)
		Mail.RequestReadMail(preMailData, nil , directShow)
		
	end)
	

	local nextBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/btn_next"):GetComponent("UIButton")
	SetClickCallback(nextBtn.gameObject , function(go)
		print("btn_next")
		local nextMail 
		if Mail.GetTabSelect() == 4 then
			nextMail = MailListData.GetSavedNextMail(curMailId)
		else
			nextMail = MailListData.GetNextMail(curMailId)
		end
		
		local nextMailData = MailListData.GetMailDataById(nextMail.id)
		print("next" .. nextMail.id)
		Mail.RequestReadMail(nextMail, nil , directShow)
	end)
	
	local battleReport = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_right/bg_information/btn_report"):GetComponent("UIButton")
	SetClickCallback(battleReport.gameObject , CheckBattleReport)

end



function CloseUI()
	Tooltip.HideItemTip()
	curReadMailMsg = nil
end

function Awake()
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Close()
	curReadMailMsg = nil
	selfFormationData = nil
    targatFormationData = nil
	formationPrefab = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	
end
