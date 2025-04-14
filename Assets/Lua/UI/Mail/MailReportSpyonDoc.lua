module("MailReportSpyonDoc", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
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

local mainMailDocUI

local directShow = false
local curMailId
local curReadMailMsg
local mailDocContent = {}
local container = {}
local spHeros
local spArmys
local spReses
local spGarrisonArmys
local spGatherArmys

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	
	Tooltip.HideItemTip()
end

local function MailSpyGoMap(posx , posy , mailCategory)
	if mailCategory == MailMsg_pb.MailType_Moba then
		Hide()
		Mail.Hide()
		MobaMain.LookAt(posx , posy , true)
	else
		Chat.GoMap(posx , posy)
	end
end

function GetShowContentInfo(mailmsg)
	local formRecon = mailmsg.misc.recon.recon.formRecon
	local armyRecon = mailmsg.misc.recon.recon.armyRecon
	local armytotolnum = mailmsg.misc.recon.recon.armytotolnum
	local heroRecon = mailmsg.misc.recon.recon.heroRecon
	local waringRecon = mailmsg.misc.recon.recon.waringRecon
	local herodetail = mailmsg.misc.recon.recon.herodetail
	--target player
	local targetPlayer = {}
	local spyUserFace = curReadMailMsg.misc.recon.user.face
	local playerTargetHead =  mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head/Texture"):GetComponent("UITexture")
	local playerTargetHead01 =  mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head01")
	if spyWarning then
		targetPlayer.show = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head01")
		targetPlayer.unshow = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head")
		targetPlayer.value = "commander_unknow"
	elseif spyuserWarning then
		if spyUserFace ~= nil then
			targetPlayer.show = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head")
			targetPlayer.unshow = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head01")
			
			playerTargetHead01.gameObject:SetActive(false)
			playerTargetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", spyUserFace)
		end
	else
		playerTargetHead01.gameObject:SetActive(true)
		playerTargetHead01:GetComponent("UISprite").spriteName = "commander_none"
		playerTargetHead.transform.parent.gameObject:SetActive(false)
	end 
end

function GetShowInfo(mailmsg)
	local reses = {}
	local heros = {}
	local armys = {}
	local garrarmy = {}
	local gatherarmy = {}
	
	local formRecon = mailmsg.misc.recon.recon.formRecon
	local armyRecon = mailmsg.misc.recon.recon.armyRecon
	local armytotolnum = mailmsg.misc.recon.recon.armytotolnum
	local heroRecon = mailmsg.misc.recon.recon.heroRecon
	
	--hero
	local heromsg = mailmsg.misc.recon.army.hero.heros
	--[[for i=1 , 5 do
		if i <= #heromsg then
			table.insert(heros , heromsg[i])
		else
			if heroRecon then
				local hero = {}
				table.insert(heros , hero)
			end
		end
	end]]
	for i=1 , #heromsg , 1 do
		table.insert(heros , heromsg[i])
	end
	
	--armys
	--[[local armymsg = mailmsg.misc.recon.army.army.army
	for i=1 , #armymsg , 1 do
		if armyRecon then
			local army = {}
			table.insert(armys , army)
		else
			table.insert(armys , armymsg[i])
		end
		
	end]]
	local armymsg = mailmsg.misc.recon.army.army.army
	for i=1 , #armymsg , 1 do
		table.insert(armys , armymsg[i])
	end

	local gararmymsg = mailmsg.misc.recon.garrisonarmy
	if gararmymsg ~= nil then
		for i=1 , #gararmymsg , 1 do
			local msg = gararmymsg[i].army.army
			for i=1 , #msg , 1 do
				table.insert(garrarmy , msg[i])
			end
		end
		
		--侦查驻防建筑时，将军信息取garrisonarmy[1]中的heros
		
		if #heromsg == 0 and #gararmymsg > 0 then
			local firstGarrisonInfo = gararmymsg[1]
			for i=1 , #firstGarrisonInfo.hero.heros do
				table.insert(heros , firstGarrisonInfo.hero.heros[i])
			end
		end
	end
	
	local gatherarmymsg = mailmsg.misc.recon.gatherarmy
	if gatherarmymsg ~= nil then
		local msg = gatherarmymsg.army.army
		for i=1 , #msg , 1 do
			table.insert(gatherarmy , msg[i])
		end
	end
	
	return reses, heros, armys , garrarmy , gatherarmy
end

function GetBattleResult(mailid)
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	
end



local function GetArmy(atype , army , armynum)
	local spyArmyRecon = curReadMailMsg.misc.recon.recon.armyRecon
	local typeArmy = {}
	local totalnum = 0
	--print(#army)
	
	for i=1 , #army do 
		--if spyArmyRecon then
		--	local army = {}--未侦查到，填充空结构
		--	table.insert(typeArmy , army)
		--else
			local soldier = TableMgr:GetBarrackData(army[i].armyId , army[i].armyLevel)
			if atype > 1 then  -- type 2 :驻防  3：集结
				if typeArmy[soldier.SoldierId] == nil then
					typeArmy[soldier.SoldierId] = {}
					typeArmy[soldier.SoldierId].Grades = {}
					typeArmy[soldier.SoldierId].Solider = soldier
				end
				typeArmy[soldier.SoldierId].Grades[soldier.Grade] = army[i]
				totalnum = totalnum + army[i].num
			else
				if soldier.Defence == atype then
					--print(soldier.SoldierId , soldier.Grade , soldier.Defence)
					if typeArmy[soldier.SoldierId] == nil then
						typeArmy[soldier.SoldierId] = {}
						typeArmy[soldier.SoldierId].Grades = {}
						typeArmy[soldier.SoldierId].Solider = soldier
					end
					typeArmy[soldier.SoldierId].Grades[soldier.Grade] = army[i]
					totalnum = totalnum + army[i].num
				end
			end
		--end
	end
	armynum.value = totalnum
	return typeArmy
end

local function ShowHero(spHero , heroitem)
	local heroData = TableMgr:GetHeroData(spHero.baseid)
	local heroicon = heroitem.transform:Find("info/head icon"):GetComponent("UITexture")
	heroicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
	
	local herolv = heroitem.transform:Find("info/level text"):GetComponent("UILabel")
	if spHero.level ~= nil and spHero.level > 0 then
		herolv.text = spHero.level
	else
		herolv.gameObject:SetActive(false)
	end
	
	print(spHero.star)
	if spHero.star ~= nil and spHero.star > 0 then
		local herostar = heroitem.transform:Find(System.String.Format("info/star/star{0}" , spHero.star))
		herostar.gameObject:SetActive(true)
	end
	
	local heroQuality = heroitem.transform:Find(System.String.Format("info/head icon/outline{0}" , heroData.quality))
	heroQuality.gameObject:SetActive(true)
	
	local heroName = heroitem.transform:Find("info/bg_name")
	if heroName ~= nil then
		heroName.gameObject:SetActive(true)
		local nametext = heroitem.transform:Find("info/bg_name/txt_num"):GetComponent("UILabel")
		nametext.text = TextMgr:GetText(heroData.nameLabel)
	end
	
	--local heroCount = heroitem.transform:Find("num_item"):GetComponent("UILabel")
	--heroCount.text = 1
end

local function LoadContent(iteminfo , spyDefenseArmy ,reconNum, readmailMsg)
	
	local spyDefenseArmyCount = readmailMsg.misc.recon.recon.armytotolnum
	local spyArmyRecon = readmailMsg.misc.recon.recon.armyRecon
	local spyArmyNum = readmailMsg.misc.recon.recon.armynum
	
	local paraController = iteminfo:GetComponent("ParadeTableItemController")
	local armyGrid = iteminfo:Find("Item_open01/zhankai/Grid"):GetComponent("UIGrid")
	local armyZhankai = iteminfo:Find("Item_open01/zhankai"):GetComponent("UIWidget")
	local armyCount = 0
	local openCount = 0
	local tableItemHeight = 0
	local zhankaiItemHeight = 0
	local disTop = 10
	local disBottom = 50
	
	while armyGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(armyGrid.transform:GetChild(0).gameObject)
	end
	
	if spyArmyRecon then	--未解锁到兵种,
		local item = NGUITools.AddChild(armyGrid.gameObject , container.Table.soilderlistUnlock.gameObject).transform
		item.gameObject:SetActive(true)
		openCount = 1
		zhankaiItemHeight = container.Table.soilderlistUnlock:GetComponent("UIWidget").height
		disTop = 32
	else
		zhankaiItemHeight = container.Table.soilderlist:GetComponent("UIWidget").height
		disTop = 0
		for _ , v in pairs(spyDefenseArmy) do
			--print(v.Solider.Defence)
			openCount = openCount + 1
			local item = NGUITools.AddChild(armyGrid.gameObject , container.Table.soilderlist.gameObject).transform
			item.gameObject:SetActive(true)
			item:SetParent(armyGrid.transform , false)
			
			--local soldier = TableMgr:GetBarrackData(spyDefenseArmy[i].Solider.SoldierId , spyDefenseArmy[i].Soldier.Grade)
			--local soldierUnit = TableMgr:GetUnitData(soldier.UnitID)
			
			local soldierName = item:Find("Label"):GetComponent("UILabel")
			soldierName.text = TextMgr:GetText(v.Solider.TabName)
			
			local solderSpr = item:Find("Sprite"):GetComponent("UISprite")
			if openCount%2 == 0 then
				solderSpr.enabled = false
			end
			
			local levelGrid = item:Find("Grid"):GetComponent("UIGrid")
			local levelItem = item:Find("armydetail")
			while levelGrid.transform.childCount > 0 do
				GameObject.DestroyImmediate(levelGrid.transform:GetChild(0).gameObject)
			end
			
			if spyArmyNum == 0 then
				for i=1, 4 do
					local spriteItem = NGUITools.AddChild(levelGrid.gameObject , levelItem.gameObject).transform
					spriteItem.gameObject:SetActive(true)
					spriteItem:SetParent(levelGrid.transform , false)
					spriteItem:Find("SpriteLevel").gameObject:SetActive(false)
					spriteItem:Find("Label").gameObject:SetActive(true)
				end
			else
				for _, vv in pairs(v.Grades) do
					local spriteItem = NGUITools.AddChild(levelGrid.gameObject , levelItem.gameObject).transform
					spriteItem.gameObject:SetActive(true)
					spriteItem:SetParent(levelGrid.transform , false)
					
					--default label
					local defaultLabel = spriteItem:Find("Label"):GetComponent("UILabel")
					defaultLabel.gameObject:SetActive(false)
					
					local sprIcon = spriteItem:Find("SpriteLevel"):GetComponent("UISprite")
					sprIcon.gameObject:SetActive(true)
					sprIcon.spriteName = "level_" .. vv.armyLevel
					
					local sprNum = spriteItem:Find("SpriteLevel/number"):GetComponent("UILabel")
					if spyArmyNum == 0 then
						sprNum.text = "?"
					elseif spyArmyNum == 1 then
						sprNum.text = "~" .. Global.ExchangeValue(vv.num)
					else
						sprNum.text = Global.ExchangeValue(vv.num)
					end
					
					armyCount = armyCount + vv.num
				end
			end
			levelGrid:Reposition()
		end
	end
	
	armyGrid:Reposition()
	--print(zhankaiItemHeight)
	armyZhankai.height = openCount * zhankaiItemHeight + disTop 
	tableItemHeight = armyZhankai.height
	
	
	--print(tableItemHeight + disBottom)
	paraController:SetItemOpenHeight(tableItemHeight + disBottom)
	
	--total num
	local totalNum = iteminfo:Find("bg_list/number"):GetComponent("UILabel")
	local msgTotalNum = readmailMsg.misc.recon.recon.armytotolnum
	local totalsoldier = ""
	if msgTotalNum:find("?") ~= nil then
		totalsoldier = "?"
	else
		if msgTotalNum:find("~") ~= nil then
			--totalsoldier = "~" .. Global.ExchangeValue(tonumber(string.sub(msgTotalNum,2)))
			totalsoldier = "~" .. Global.ExchangeValue(reconNum.value)
		else
			totalsoldier = Global.ExchangeValue(reconNum.value)
		end
	end
	totalNum.text = totalsoldier

	--table btn
	local tabelBtn = iteminfo:Find("bg_list/btn_open"):GetComponent("UIButton")
	SetClickCallback(tabelBtn.gameObject , function(go)
		print(totalsoldier)
		if totalsoldier == "?" then
			FloatText.ShowOn(tabelBtn.gameObject, TextMgr:GetText("Mail_spyon8"))
			return
		elseif tonumber(totalsoldier) == 0 then
			return
		elseif tonumber(totalsoldier) > 0 and spyArmyRecon then
			FloatText.ShowOn(tabelBtn.gameObject, TextMgr:GetText("Mail_spyon8"))
			return
		end
		
	end)

end

local function SetDefenseArmyInfo(iteminfo)
	local reconNum = {value = 0}
	local spyDefenseArmy = GetArmy(0,spArmys , reconNum)
	LoadContent(iteminfo ,spyDefenseArmy ,reconNum, curReadMailMsg)
end


local function SetCityDefenseArmyInfo(iteminfo)
	local reconNum = {value = 0}
	local spyDefenseArmy = GetArmy(1,spArmys , reconNum)
	LoadContent(iteminfo ,spyDefenseArmy ,reconNum, curReadMailMsg)
end	

local function SetResidentArmyInfo(iteminfo)
	local reconNum = {value = 0}
	local spyGariArmy = GetArmy(2,spGarrisonArmys , reconNum)
	LoadContent(iteminfo ,spyGariArmy ,reconNum, curReadMailMsg)
	
end

local function SetAssemblyArmyInfo(iteminfo)
	local reconNum = {value = 0}
	local spyJijieArmy = GetArmy(3,spGatherArmys , reconNum)
	LoadContent(iteminfo ,spyJijieArmy ,reconNum, curReadMailMsg)
end


local function ShowBereconContent()
	--local mainMailDocUI = Mail.GetMailUI("MailReportSpyonDoc")
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	local bg_suceedFrane = mainMailDocUI.go:Find("bg_frane/bg_mid")
	local bg_failFrane = mainMailDocUI.go:Find("bg_frane/bg_midfail")
	
	bg_suceedFrane.gameObject:SetActive(false)
	bg_failFrane.gameObject:SetActive(true)
	
	--title
	local midTime = bg_failFrane:Find("bg_title/text_time"):GetComponent("UILabel")
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss") --timeText[1] .. "     " .. timeText[2]
	midTime.text = showTime
	local reportTitl = bg_failFrane:Find("bg_title/txt_title"):GetComponent("UILabel")
	reportTitl.text = TextMgr:GetText("Mail_recon_myself_win_Title")
	
	
	--发起侦查的目标
	local playicon = bg_failFrane:Find("bg_righttop/head/Texture"):GetComponent("UITexture")
	playicon.transform.parent.gameObject:SetActive(true)
	playicon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", curReadMailMsg.misc.source.face) --curReadMailMsg.misc.target.face
	local playerTargetHead01 =  bg_failFrane:Find("bg_righttop/head01")
	playerTargetHead01.gameObject:SetActive(false)
	
	local playCoord = bg_failFrane:Find("bg_righttop/head/coordinate"):GetComponent("UILabel")
	playCoord.gameObject:SetActive(true)
	playCoord.text = System.String.Format("#1 X:{0} Y:{1}" ,  curReadMailMsg.misc.source.pos.x , curReadMailMsg.misc.source.pos.y)
	SetClickCallback(playCoord.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(curReadMailMsg.misc.source.pos.x) ,tonumber(curReadMailMsg.misc.source.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(curReadMailMsg.misc.source.pos.x) ,tonumber(curReadMailMsg.misc.source.pos.y))
		end)
		Mail.Hide()]]
		--Chat.GoMap(tonumber(curReadMailMsg.misc.source.pos.x) ,tonumber(curReadMailMsg.misc.source.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(curReadMailMsg.misc.source.pos.x) ,tonumber(curReadMailMsg.misc.source.pos.y) , readMailData.category)
	end)
	
	
	--被侦查目标
	local bereconTargetCoord = bg_failFrane:Find("bg_righttop/location/Label"):GetComponent("UILabel")
	bereconTargetCoord.text = System.String.Format("#1 X:{0} Y:{1}" ,  curReadMailMsg.misc.target.pos.x , curReadMailMsg.misc.target.pos.y)
	local bereconTargetName = bg_failFrane:Find("bg_righttop/name/Label"):GetComponent("UILabel")
	bereconTargetName.text = TextMgr:GetText("ui_worldmap_spygoal" .. curReadMailMsg.misc.target.entrytype)
	
	local bereconCoord = bg_failFrane:Find("bg_righttop/location/Label"):GetComponent("BoxCollider")
	SetClickCallback(bereconCoord.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		
		--Chat.GoMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) , readMailData.category)
	end)
	
	local playerTargetCoordBtn =  bg_failFrane:Find("bg_title/btn_coord"):GetComponent("UIButton")
	SetClickCallback(playerTargetCoordBtn.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		
		--Chat.GoMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y), readMailData.category)
	end)
	
	local radarDes = bg_failFrane:Find("txt_radar"):GetComponent("UILabel")
	local targetName = "ui_worldmap_spygoal"..curReadMailMsg.misc.target.entrytype
	radarDes.text = System.String.Format(TextMgr:GetText("ui_worldmap_spy12") ,TextMgr:GetText(targetName) )
	--radarDes.txt = "111111"--TextMgr:GetText("ui_worldmap_spy10")
	
	local spyIcon = bg_failFrane:Find("icon"):GetComponent("UITexture")
	spyIcon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/" ,"spyon_" .. curReadMailMsg.misc.target.entrytype )--"spyon_" .. curReadMailMsg.misc.target.entrytype
end

local function ShowSpyFailContent()
	--local mainMailDocUI = Mail.GetMailUI("MailReportSpyonDoc")
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	local bg_suceedFrane = mainMailDocUI.go:Find("bg_frane/bg_mid")
	local bg_failFrane = mainMailDocUI.go:Find("bg_frane/bg_midfail")
	
	bg_suceedFrane.gameObject:SetActive(false)
	bg_failFrane.gameObject:SetActive(true)
	
	--title
	local midTime = bg_failFrane:Find("bg_title/text_time"):GetComponent("UILabel")
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss") --timeText[1] .. "     " .. timeText[2]
	midTime.text = showTime
	
	local reportTitl = bg_failFrane:Find("bg_title/txt_title"):GetComponent("UILabel")
	reportTitl.text = TextMgr:GetText("Mail_recon_fail_Title")
	
	local playerTargetName =  bg_failFrane:Find("bg_righttop/name/Label"):GetComponent("UILabel")
	local targetType = curReadMailMsg.misc.target.entrytype
	
	
	if curReadMailMsg.misc.target.uid ~= 0 then
		if curReadMailMsg.misc.target.nameText then
			playerTargetName.text = TextMgr:GetText(curReadMailMsg.misc.target.name)
		else
			playerTargetName.text = curReadMailMsg.misc.target.name
		end
	else
		if targetType == 0 then
			playerTargetName.text = TextMgr:GetText("ui_worldmap_spy15")
		end
	end
	
	local playerTargetCoordLabel =  bg_failFrane:Find("bg_righttop/location/Label"):GetComponent("UILabel")
	playerTargetCoordLabel.text = System.String.Format("#1 X:{0} Y:{1}" ,  curReadMailMsg.misc.target.pos.x , curReadMailMsg.misc.target.pos.y)
	SetClickCallback(playerTargetCoordLabel.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		--Chat.GoMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) )
		MailReportDocNew.MailReportGoMap(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y), readMailData.category)
	end)
	
	local playerTargetCoordBtn =  bg_failFrane:Find("bg_title/btn_coord"):GetComponent("UIButton")
	SetClickCallback(playerTargetCoordBtn.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		
		--Chat.GoMap(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y), readMailData.category)
	end)
	
	local playerTargetHead =  bg_failFrane:Find("bg_righttop/head/Texture"):GetComponent("UITexture")
	playerTargetHead.transform.parent.gameObject:SetActive(true)
	playerTargetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", curReadMailMsg.misc.source.face)
	local playerTargetHead01 =  bg_failFrane:Find("bg_righttop/head01")
	playerTargetHead01.gameObject:SetActive(false)
	
	
	local radarDes = bg_failFrane:Find("txt_radar"):GetComponent("UILabel")
	radarDes.text = System.String.Format(TextMgr:GetText("ui_worldmap_spy10") ,curReadMailMsg.misc.target.pos.x ..",".. curReadMailMsg.misc.target.pos.y )
	--radarDes.txt = "111111"--TextMgr:GetText("ui_worldmap_spy10")
	
	--local spyIcon = bg_failFrane:Find("icon"):GetComponent("UISprite")
	--spyIcon.spriteName = "spyon_" .. curReadMailMsg.misc.target.entrytype
	
	local spyIcon = bg_failFrane:Find("icon"):GetComponent("UITexture")
	spyIcon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/" ,"spyon_" .. curReadMailMsg.misc.target.entrytype )--"spyon_" .. curReadMailMsg.misc.target.entrytype
end

local function NormalizeShieldReportData(readMailData , readMailMsg)
--report.source.pos.x
	local showData = {}
	if readMailData.subtype == Mail.MailReportType.MailReport_shieldRecon then
		showData.content = System.String.Format(TextMgr:GetText("shied_mail_3") ,  readMailMsg.misc.target.name , readMailMsg.misc.target.pos.x ..",".. readMailMsg.misc.target.pos.y )
		showData.title = TextMgr:GetText("maincity_ui11")
		showData.icon = "spyon_1"
	elseif readMailData.subtype == Mail.MailReportType.MailReport_shieldBeRecon then
		showData.content = System.String.Format(TextMgr:GetText("shied_mail_6") , readMailMsg.misc.source.name , readMailMsg.misc.source.pos.x ..",".. readMailMsg.misc.source.pos.y )
		showData.title = TextMgr:GetText("maincity_ui11")
		showData.icon = "spyon_1"
	elseif readMailData.subtype == Mail.MailReportType.MailReport_shieldAttack then
		showData.content = System.String.Format(TextMgr:GetText("shied_mail_1") , readMailMsg.misc.target.name , readMailMsg.misc.target.pos.x ..",".. readMailMsg.misc.target.pos.y )
		showData.title = TextMgr:GetText("common_ui19")
		showData.icon = "spyon_8"
	elseif readMailData.subtype == Mail.MailReportType.MailReport_shieldDefence then
		showData.content = System.String.Format(TextMgr:GetText("shied_mail_4") , readMailMsg.misc.source.name , readMailMsg.misc.source.pos.x ..",".. readMailMsg.misc.source.pos.y )
		showData.title = TextMgr:GetText("common_ui18")
		showData.icon = "spyon_8"
	elseif readMailData.subtype == Mail.MailReportType.MailReport_shieldGatherAttack then
		showData.content = System.String.Format(TextMgr:GetText("shied_mail_2") , readMailMsg.misc.target.name , readMailMsg.misc.target.pos.x ..",".. readMailMsg.misc.target.pos.y )
		showData.title = TextMgr:GetText("common_ui19")
		showData.icon = "spyon_8"
	elseif readMailData.subtype == Mail.MailReportType.MailReport_shieldGatherDefence then
		showData.content = System.String.Format(TextMgr:GetText("shied_mail_5") , readMailMsg.misc.source.name , readMailMsg.misc.source.pos.x ..",".. readMailMsg.misc.source.pos.y )
		showData.title = TextMgr:GetText("common_ui18")
		showData.icon = "spyon_8"
	end
	return showData
end

local function ShowShieldMailReport()
	--local mainMailDocUI = Mail.GetMailUI("MailReportSpyonDoc")
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	local bg_suceedFrane = mainMailDocUI.go:Find("bg_frane/bg_mid")
	local bg_failFrane = mainMailDocUI.go:Find("bg_frane/bg_midfail")
	
	bg_suceedFrane.gameObject:SetActive(false)
	bg_failFrane.gameObject:SetActive(true)
	
	--title
	local midTime = bg_failFrane:Find("bg_title/text_time"):GetComponent("UILabel")
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss") --timeText[1] .. "     " .. timeText[2]
	midTime.text = showTime
	
	local playerTargetName =  bg_failFrane:Find("bg_righttop/name/Label"):GetComponent("UILabel")
	playerTargetName.text = curReadMailMsg.misc.target.name
	
	local playerTargetCoordLabel =  bg_failFrane:Find("bg_righttop/location/Label"):GetComponent("UILabel")
	playerTargetCoordLabel.text = System.String.Format("#1 X:{0} Y:{1}" ,  curReadMailMsg.misc.target.pos.x , curReadMailMsg.misc.target.pos.y)
	SetClickCallback(playerTargetCoordLabel.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		--Chat.GoMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y), readMailData.category)
	end)
	
	local playerTargetCoordBtn =  bg_failFrane:Find("bg_title/btn_coord"):GetComponent("UIButton")
	SetClickCallback(playerTargetCoordBtn.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		--Chat.GoMap( tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(curReadMailMsg.misc.target.pos.x) ,tonumber(curReadMailMsg.misc.target.pos.y), readMailData.category)
	end)
	
	local playerTargetHead =  bg_failFrane:Find("bg_righttop/head/Texture"):GetComponent("UITexture")
	playerTargetHead.transform.parent.gameObject:SetActive(true)
	playerTargetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", curReadMailMsg.misc.source.face)
	local playerTargetHead01 =  bg_failFrane:Find("bg_righttop/head01")
	playerTargetHead01.gameObject:SetActive(false)
	
	
	
	local showData = NormalizeShieldReportData(readMailData , curReadMailMsg)
	
	local reportTitl = bg_failFrane:Find("bg_title/txt_title"):GetComponent("UILabel")
	reportTitl.text = showData.title
	local showDes = bg_failFrane:Find("txt_radar"):GetComponent("UILabel")
	showDes.text = showData.content
	
	--local spyIcon = bg_failFrane:Find("icon"):GetComponent("UISprite")
	--spyIcon.spriteName = showData.icon
	local spyIcon = bg_failFrane:Find("icon"):GetComponent("UITexture")
	spyIcon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/" ,showData.icon )
end

local function ShowContent(msg)
	--local mainMailDocUI = Mail.GetMailUI("MailReportSpyonDoc")
	local readMailData = MailListData.GetMailDataById(curMailId)
	
	if readMailData.subtype == Mail.MailReportType.MailReport_berecon or
		readMailData.subtype ==  Mail.MailReportType.MobaMailReport_berecon then--被侦查报告
		ShowBereconContent()
		return
	end
	
	-- 开启防护盾时的邮件\
	--print(readMailData.subtype)
	if (readMailData.subtype == Mail.MailReportType.MailReport_shieldRecon or
			readMailData.subtype == Mail.MailReportType.MailReport_shieldBeRecon or
			readMailData.subtype == Mail.MailReportType.MailReport_shieldAttack or
			readMailData.subtype == Mail.MailReportType.MailReport_shieldDefence or
			readMailData.subtype == Mail.MailReportType.MailReport_shieldGatherAttack or
			readMailData.subtype == Mail.MailReportType.MailReport_shieldGatherDefence) then
			
			ShowShieldMailReport()
		return
	end
	
	local spySucced = curReadMailMsg.misc.recon.succeed
	if not spySucced then
		ShowSpyFailContent()--侦查失败报告
		return
	end
	
	
	
	--侦查成功报告
	local bg_suceedFrane = mainMailDocUI.go:Find("bg_frane/bg_mid")
	local bg_failFrane = mainMailDocUI.go:Find("bg_frane/bg_midfail")
	
	bg_suceedFrane.gameObject:SetActive(true)
	bg_failFrane.gameObject:SetActive(false)
	
	spReses,spHeros,spArmys,spGarrisonArmys,spGatherArmys = GetShowInfo(curReadMailMsg)
	
	--资源掠夺
	local resFood = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_resource/bg_food/txt_food"):GetComponent("UILabel")
	resFood.text = 0
	local resOil = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_resource/bg_oil/txt_oil"):GetComponent("UILabel")
	resOil.text = 0
	local resIron = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_resource/bg_iron/txt_iron"):GetComponent("UILabel")
	resIron.text = 0
	local resElec = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_resource/bg_electric/txt_electric"):GetComponent("UILabel")
	resElec.text = 0
	
	local spyMoney = curReadMailMsg.misc.recon.res.money
	for i=1 , #spyMoney do
		if spyMoney[i].type == 3 then
			resFood.text = Global.ExchangeValue(spyMoney[i].value)
		elseif spyMoney[i].type == 4 then
			resIron.text = Global.ExchangeValue(spyMoney[i].value)
		elseif spyMoney[i].type == 5 then
			resOil.text = Global.ExchangeValue(spyMoney[i].value)
		elseif spyMoney[i].type == 6 then
			resElec.text = Global.ExchangeValue(spyMoney[i].value)
		end
	end
	
	mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_resource").gameObject:SetActive(readMailData.category ~= MailMsg_pb.MailType_Moba)
	mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/Texture").gameObject:SetActive(readMailData.category == MailMsg_pb.MailType_Moba)
	--阵形
	--selfFormationData = msg.misc.result.info.team1[1]
	--targatFormationData = msg.misc.result.info.team2[1]
	
	local selfAttackForm = {}
	--formationSmall = BMFormation(mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_formation/Embattle"))
	
	local formTrf = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_formation")
	if formTrf.childCount == 0 then
		local battleFormation = NGUITools.AddChild(formTrf.gameObject, formationPrefab).transform
		--formationTransform.name = "battle_formation"
	end
	
	--formationSmall = BMFormation(battleFormation:Find("Embattle"))
	formationSmall = BMFormation(mainMailDocUI.go:Find("bg_frane/bg_mid/bg_left/bg_formation/battle_formation(Clone)/Embattle"))
    formationSmall:SetLeftFormation(BattleMoveData.GetUserAttackFormation())
    formationSmall:SetRightFormation(curReadMailMsg.misc.recon.army.formation.form)
    formationSmall:Awake()
	
	
	
	
	--侦查信息
	
	--title
	local midTime = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_title/text_time"):GetComponent("UILabel")
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss") --timeText[1] .. "     " .. timeText[2]
	midTime.text = showTime
	
	local title = bg_suceedFrane:Find("bg_title/txt_title"):GetComponent("UILabel")
	title.text = TextMgr:GetText("Mail_recon_win_Title")

	local spyWarning = curReadMailMsg.misc.recon.recon.waringRecon
	local spyuserWarning = curReadMailMsg.misc.recon.army.userwaring
	local spyUserFace = curReadMailMsg.misc.recon.recon.waringface
	local playerTargetHead =  mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head/Texture"):GetComponent("UITexture")
	local playerTargetHead01 =  mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/head01")
	
	if spyWarning then
		playerTargetHead01.gameObject:SetActive(true)
		playerTargetHead01:GetComponent("UISprite").spriteName = "commander_unknow"
		playerTargetHead.transform.parent.gameObject:SetActive(false)
	elseif spyuserWarning then
		if spyUserFace ~= nil then
			playerTargetHead01.gameObject:SetActive(false)
			playerTargetHead.transform.parent.gameObject:SetActive(true)
			playerTargetHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", spyUserFace)
		end
	else
		playerTargetHead01.gameObject:SetActive(true)
		playerTargetHead01:GetComponent("UISprite").spriteName = "commander_none"
		playerTargetHead.transform.parent.gameObject:SetActive(false)
	end 
	--
	
	local playerTargetName =  mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/name/Label"):GetComponent("UILabel")
	playerTargetName.text = msg.misc.target.name
	if msg.misc.target.nameText ~= nil and msg.misc.target.nameText then
		playerTargetName.text = TextMgr:GetText(msg.misc.target.name)
	end
	--[[local namePar = msg.misc.param[3]
	if tonumber(namePar) == 1 then
		playerTargetName.text = TextMgr:GetText(msg.misc.param[1])
	else
		playerTargetName.text = msg.misc.param[1]
	end]]
	
	local playerTargetCoordLabel =  mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/location/Label"):GetComponent("UILabel")
	playerTargetCoordLabel.text = System.String.Format("#1 X:{0} Y:{1}" ,  msg.misc.target.pos.x , msg.misc.target.pos.y)
	SetClickCallback(playerTargetCoordLabel.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y) , true , function()
			--WorldMap.SelectTile(tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		--Chat.GoMap( tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y), readMailData.category)
	end)
	
	local playerTargetCoordBtn =  mainMailDocUI.go:Find("bg_frane/bg_mid/bg_title/btn_coord"):GetComponent("UIButton")
	SetClickCallback(playerTargetCoordBtn.gameObject , function(go)
		--[[MainCityUI.ShowWorldMap( tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y), true , function()
			--WorldMap.SelectTile(tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y))
		end)
		Mail.Hide()]]
		
		--Chat.GoMap( tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y))
		MailReportDocNew.MailReportGoMap(tonumber(msg.misc.target.pos.x) ,tonumber(msg.misc.target.pos.y), readMailData.category)
	end)
	
	
	--hero
	--local spHeros = curReadMailMsg.misc.recon.army.hero.heros
	local heroScrollView = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/Scroll View"):GetComponent("UIScrollView")
	local heroGrid = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/Scroll View/Grid"):GetComponent("UIGrid")
	local heroItem = ResourceLibrary.GetUIPrefab("CommonItem/listitem_herocard_small0.6_spy")--mainMailDocUI.go:Find("listitem_herocard_small0.6_spy")
	
	local heroRecon = curReadMailMsg.misc.recon.recon.heroRecon
	while heroGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(heroGrid.transform:GetChild(0).gameObject)
	end

	local heroCount  = 0
	for i=1 , 5,1 do
		if heroRecon and msg.misc.target.entrytype ~= Common_pb.SceneEntryType_Monster then
			local item = NGUITools.AddChild(heroGrid.gameObject , heroItem.gameObject)
			item.gameObject:SetActive(true)
			--item.gameObject.name = v.uniqueid .. "_" .. (v.number - itemTbData.itemsize)
			item.transform:SetParent(heroGrid.transform , false)
			
			item.transform:Find("icon_wenhao").gameObject:SetActive(true)
			item.transform:Find("icon_plus").gameObject:SetActive(false)
			item.transform:Find("info").gameObject:SetActive(false)
		else
			
			if i<= #spHeros then
				heroCount = heroCount + 1
				local item = NGUITools.AddChild(heroGrid.gameObject , heroItem.gameObject)
				item.gameObject:SetActive(true)
				--item.gameObject.name = v.uniqueid .. "_" .. (v.number - itemTbData.itemsize)
				item.transform:SetParent(heroGrid.transform , false)
				
				item.transform:Find("info").gameObject:SetActive(true)
				item.transform:Find("icon_wenhao").gameObject:SetActive(false)
				item.transform:Find("icon_plus").gameObject:SetActive(false)
				ShowHero(spHeros[i] , item)
			end
		end
	end
	heroGrid:Reposition()
	
	--no hero hint
	local hint = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/tishi")
	if not heroRecon then
		if #spHeros > 0 then
			hint.gameObject:SetActive(false)
		else
			hint.gameObject:SetActive(true)
		end
	else
		if msg.misc.target.entrytype == Common_pb.SceneEntryType_Monster then
			hint.gameObject:SetActive(true)
		else
			hint.gameObject:SetActive(false)
		end
	end
	--soldier
	SetDefenseArmyInfo(container.Table.table.transform:GetChild(0))
	SetCityDefenseArmyInfo(container.Table.table.transform:GetChild(1))
	SetResidentArmyInfo(container.Table.table.transform:GetChild(2))
	SetAssemblyArmyInfo(container.Table.table.transform:GetChild(3))
	
	local defenseLabel = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/defencenumber/Label"):GetComponent("UILabel")
	local defense = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_righttop/defencenumber")
	if readMailData.category == MailMsg_pb.MailType_Moba then
		defenseLabel.text = curReadMailMsg.misc.recon.cityguard
		defense.gameObject:SetActive(curReadMailMsg.misc.recon.cityguard > 0)
	else
		defenseLabel.text = curReadMailMsg.misc.recon.cityguard 
	end
	container.Table.table:Reposition()
end

function ReadMail(mailid , mailMsg , dirShow)
	directShow = dirShow
	curMailId = mailid
	local readMailData = MailListData.GetMailDataById(curMailId)
	if readMailData == nil then
		--print("readmail" .. curMailId)
		return
	end
	--local mainMailDocUI = Mail.GetMailUI("MailReportSpyonDoc")
	--Mail.OpenMailUI("MailReportSpyonDoc")
	if mainMailDocUI == nil then
		return
	end
	print("readmail Spyon:" .. curMailId)
	BattleMoveData.GetOrReqUserAttackFormaion(function(form)
		curReadMailMsg = mailMsg
		ShowContent(curReadMailMsg)
	end)
end


function OpenUI()
	Tooltip.HideItemTip()

	--local mainMailDocUI = Mail.GetMailUI("MailReportSpyonDoc")
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
	nextBtn.gameObject:SetActive(nextMail ~= nil and not directShow)
	SetClickCallback(nextBtn.gameObject , function(go)
		local nextMailData = MailListData.GetMailDataById(nextMail.id)
		print("next" .. nextMail.id)
		Mail.RequestReadMail(nextMail, nil , directShow)
	end)
	
	local previousBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/btn_previous"):GetComponent("UIButton")
	previousBtn.gameObject:SetActive(preMail ~= nil and not directShow)
	SetClickCallback(previousBtn.gameObject , function(go)
		local preMailData = MailListData.GetMailDataById(preMail.id)
		Mail.RequestReadMail(preMailData, nil , directShow)
	end)
	
	local closeBtn = mainMailDocUI.go:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		Hide()
	end)
	SetClickCallback(mainMailDocUI.go.gameObject , function(go)
		Hide()
	end)
	
	
	local readMailData = MailListData.GetMailDataById(curMailId)
	local saveBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/Grid/btn_ save"):GetComponent("UIButton")
	saveBtn.gameObject:SetActive((not readMailData.saved) and readMailData.category ~= MailMsg_pb.MailType_Moba and readMailData.category ~= MailMsg_pb.MailType_GuildMoba)
	SetClickCallback(saveBtn.gameObject , function(go)
		print("saveBtn")
		Mail.SaveMail(curMailId)
		Hide()
	end)
	
	local delBtn = mainMailDocUI.go:Find("bg_frane/bg_bottom/Grid/btn_del"):GetComponent("UIButton")
	SetClickCallback(delBtn.gameObject , function(go)
		print("delBtn")
		local delist = {}
		delist[1] = {}
		delist[1].id = curMailId
		Mail.DeleteMail(delist)
		Hide()
	end)
	
	if container.Table.table.transform.childCount == 0 then 
		for i=1 , 4 do
			local tableItem = NGUITools.AddChild(container.Table.table.gameObject , container.Table.tableItem.gameObject).transform
			tableItem:SetParent(container.Table.table.transform , false)
			tableItem.gameObject:SetActive(true)
			
			local itemTitle = tableItem:Find("bg_list/Sprite/Label"):GetComponent("UILabel")
			--print("Mail_spyon" .. i)
			itemTitle.text = TextMgr:GetText("Mail_spyon" .. i)
		end
	end
	container.Table.table:Reposition()
end

function Init(mailTransform)
	
end





function Awake()
	mainMailDocUI = {go = transform:Find("Mail-spyon")}
	formationPrefab = ResourceLibrary.GetUIPrefab("CommonItem/battle_formation")
	
	container.Table = {}
	container.Table.table = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_soilder/Table"):GetComponent("UITable")
	container.Table.soilderlist = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_soilder/soilder_list")
	container.Table.soilderlistUnlock = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_soilder/soilder_list_unlock")
	container.Table.tableItem = mainMailDocUI.go:Find("bg_frane/bg_mid/bg_soilder/ItemInfo01")
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Close()
	Tooltip.HideItemTip()
	curReadMailMsg = nil
	directShow = false
	mainMailDocUI = nil
	while container.Table.table.transform.childCount > 0 do
		GameObject.DestroyImmediate(container.Table.table.transform:GetChild(0).gameObject)
	end
	
	
	selfFormationData = nil
    targatFormationData = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	
end

	
function Hide()
	Global.CloseUI(_M)
end

function CloseUI()
	--[[Tooltip.HideItemTip()
	curReadMailMsg = nil
	directShow = false
	while container.Table.table.transform.childCount > 0 do
		GameObject.DestroyImmediate(container.Table.table.transform:GetChild(0).gameObject)
	end]]
	Hide()
end

function Show(mailid , mailMsg , dirShow)
	Global.OpenUI(_M)
	
	directShow = dirShow
	curMailId = mailid
	local readMailData = MailListData.GetMailDataById(curMailId)
	if readMailData == nil then
		--print("readmail" .. curMailId)
		return
	end
	
	OpenUI()
	ReadMail(mailid , mailMsg , dirShow)
end