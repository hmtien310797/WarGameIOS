module("MailDoc", package.seeall)

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
local String = System.String

local directShow = false
local curMailId
local curReadMailMsg
local mailDocContent = {}

local _ui
local mainMailDocUI
local itemtipslist
local translateCoroutine = nil

local MailBaseId = 
{
	RebelReadyStart=114,
	RebelStart=115,
	RebelArmyAttackReadyStart=116,
	RebelArmyAttackStart=117,
	FortReadyStart=118,
	FortStart=119	
}

function TranslateMail(trinfo)
	local req = ChatMsg_pb.MsgUserTranslateTextRequest()
	req.clientLang = GUIMgr:GetSystemLanguage()
	req.text:append(trinfo.content.text)
	
	local reqCount = 0
	local getResult = false
	translateCoroutine = coroutine.start(function()
		for i=1 , 10 , 1 do
			if not waitResult then
				waitResult = true
				Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgUserTranslateTextRequest, req, ChatMsg_pb.MsgUserTranslateTextResponse, function(msg)
					--print(string.format("======TranslateResponse==== reqCount:%d , SRC:%s" , i , trinfo.content.text))
					waitResult = false
					local transData = msg.data[1]
					if trinfo ~= nil and transData ~= nil and transData.text ~= nil and transData.text ~= "" and not transData.waitTranslate then
						--print(string.format("======GET Result==== reqCount:%d , SRC:%s , TRANS" , i , trinfo.content.text , transData.text))
						--trinfo.srcContent = trinfo.content.text
						trinfo.content.text = transData.text
						getResult = true
						if _ui ~= nil then
							trinfo.btn.gameObject:SetActive(true)
							trinfo.transText.gameObject:SetActive(true)
							trinfo.transText.text = TextMgr:GetText("chat_hint11")
							_ui.transing.gameObject:SetActive(false)
							SetClickCallback(_ui.transBtn.gameObject , function()
								CheckSourceText(trinfo)
							end)
						end
					end
					
					if i==10 then
						_ui.transBg.gameObject:SetActive(true)
						_ui.transBtn.gameObject:SetActive(true)
						_ui.transText.gameObject:SetActive(true)
						_ui.transText.text = TextMgr:GetText("chat_hint10")
						_ui.transing.gameObject:SetActive(false)
					end
				end,true)
			end
			
			if getResult then
				break
			end
			
			if waitResult then
				coroutine.wait(2)
			end
		end
	end)
end

function TranslateMailOld(trinfo)	
	--请求翻译文本
	local mainMailDocUI = transform:Find("MailDoc")--Mail.GetMailUI("MailDoc")
	local req = ClientMsg_pb.MsgTranslateTextRequest()
	req.id = 1
	req.text = trinfo.content.text
	req.languageCode = Global.GTextMgr:GetCurrentLanguageID()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgTranslateTextRequest, req, ClientMsg_pb.MsgTranslateTextResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			--防止在翻译结果回来之前关掉界面
			if mainMailDocUI.gameObject ~= nil and mainMailDocUI.gameObject.activeSelf then
				trinfo.srcContent = trinfo.content.text
				trinfo.content.text = msg.text
				trinfo.transText.text = TextMgr:GetText("chat_hint11")
				
				SetClickCallback(trinfo.btn.gameObject , function()
					CheckSourceText(trinfo)
				end)
			end
		end 
    end)
	
end

function CheckSourceText(trinfo)
	trinfo.transText.text = TextMgr:GetText("chat_hint10")
	trinfo.content.text = trinfo.srcContent
	SetClickCallback(_ui.transBtn.gameObject , function()
		TranslateMail(trinfo)
	end)
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	if itemtipslist == nil then
		return
	end
	print(go.name)
	for i, v in pairs(itemtipslist) do
		if go == v.go then
			local itemdata = TableMgr:GetItemData(tonumber(go.name))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
		        end
		    end
		    return
		end
	end
	Tooltip.HideItemTip()
end


local function ShowReportMonsterContent(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(true)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	if msg.misc == nil then
		print("readmail" .. curMailId)
		return
	end
	
	local bgTitleWid = _ui.contentMonster:Find("bg_tittle")
	local bgKillerWid = _ui.contentMonster:Find("bg_killer")
	bgKillerWid.gameObject:SetActive(false)
	local bgPartakeWid = _ui.contentMonster:Find("bg_partake")
	bgPartakeWid.gameObject:SetActive(false)
	
	local resultInfo = msg.misc.result--.info
	local killerInfo = msg.misc.killreport
	local targetInfo = msg.misc.target
	local sourceInfo = msg.misc.source
	
	local bgPos = 0 
	print(targetInfo.pos.x , targetInfo.pos.y)
	--title
	if targetInfo ~= nil then
		local monster = TableMgr:GetMonsterRuleData(targetInfo.baseid)
		local title1 = _ui.contentMonster:Find("text_title"):GetComponent("UILabel")
		title1.text = TextMgr:GetText(targetInfo.name)
		
		local title2 = _ui.contentMonster:Find("coordinate"):GetComponent("UILabel")
		local strFormat = "#:{0} X:{1} Y:{2}"
		title2.text = System.String.Format(strFormat ,  1 ,targetInfo.pos.x , targetInfo.pos.y)
		SetClickCallback(title2.gameObject , function()
			MainCityUI.ShowWorldMap(tonumber(targetInfo.pos.x) , tonumber(targetInfo.pos.y), true)
			Mail.Hide()
		end)
		
		local title3 = _ui.contentMonster:Find("text_title2"):GetComponent("UILabel")
		if resultInfo.winteam == 1 then--胜利
			title3.text = TextMgr:GetText("ui_worldmap_60")
		else						   --失败
			title3.text = TextMgr:GetText("ui_worldmap_64")
		end
		
		
		bgPos = bgTitleWid.transform.localPosition.y - bgTitleWid:GetComponent("UIWidget").height/2
	end	
	
	--击杀者
	if killerInfo ~= nil and #killerInfo.infos > 0 then
		bgKillerWid.gameObject:SetActive(true)
		local height = bgKillerWid:GetComponent("UIWidget").height
		bgKillerWid.transform.localPosition = Vector3(bgKillerWid.transform.localPosition.x , bgPos - height/2 , bgKillerWid.transform.localPosition.z)
		--击杀 --(目前没有集结，而且是打怪必胜，所以目前处理为击杀者就为玩家自己)
		local killerHead = bgKillerWid:Find("bg_head/icon_head"):GetComponent("UITexture")
		killerHead.mainTexture = ResourceLibrary:GetIcon("Icon/head/", resultInfo.input.user.team1[1].user.face)
		
		local killerName = bgKillerWid:Find("bg_head/title_name/txt_name"):GetComponent("UILabel")
		killerName.text = resultInfo.input.user.team1[1].user.name
		
		local killerLeague = bgKillerWid:Find("bg_head/title_unio/txt_unio"):GetComponent("UILabel")
		killerLeague.text = sourceInfo.guildBanner
		
		local killerHurt = bgKillerWid:Find("bg_head/title_hurt/txt_hurt"):GetComponent("UILabel")
		killerHurt.text = "100%"
	
		bgPos = bgPos - bgKillerWid:GetComponent("UIWidget").height / 2
	end
	
	--参与者
	if resultInfo ~= nil and resultInfo.input ~= nil and resultInfo.input.user ~= nil then
		bgPartakeWid.gameObject:SetActive(true)
		local height = bgPartakeWid:GetComponent("UIWidget").height
		bgPartakeWid.transform.localPosition = Vector3(bgPartakeWid.transform.localPosition.x , bgPos - height/2 , bgPartakeWid.transform.localPosition.z)
		
		local partakeGrid = bgPartakeWid:Find("Grid"):GetComponent("UIGrid")
		local partakeItem = mainMailDocUI:Find("info_partake")
		while partakeGrid.transform.childCount > 0 do
			GameObject.DestroyImmediate(partakeGrid.transform:GetChild(0).gameObject)
		end
		
		local monsterTotalNum = resultInfo.ArmyTotalNum[2]
		local userIndex = 0
		for i=1 , #(resultInfo.ACampPlayers) do
			if resultInfo.ACampPlayers[i].uid == MainData.GetCharId() then
				local partItem = NGUITools.AddChild(partakeGrid.gameObject, partakeItem.gameObject).transform
				partItem:SetParent(partakeGrid.transform , false)
				
				local id = partItem:Find("txt_id"):GetComponent("UILabel")
				id.text = "[FFFEA9FF]" .. 1 .. "[-]"
				
				local name = partItem:Find("txt_name"):GetComponent("UILabel")
				name.text = "[FFFEA9FF]" .. resultInfo.ACampPlayers[i].name .. "[-]"
				
				local union = partItem:Find("title_unio"):GetComponent("UILabel")
				union.text = "[FFFEA9FF]" .. union.text .. "[-]"
				
				local league = partItem:Find("title_unio/txt_unio"):GetComponent("UILabel")
				league.text = "[FFFEA9FF]" .. sourceInfo.guildBanner .. "[-]"
				
				local hurtName = partItem:Find("title_hurt"):GetComponent("UILabel")
				hurtName.text = "[FFFEA9FF]" .. hurtName.text .. "[-]"
				
				local hurt = partItem:Find("title_hurt/txt_hurt"):GetComponent("UILabel")
				local desPerc = resultInfo.ACampPlayers[i].Destroy / monsterTotalNum * 100
				local fmt = string.format("%.2f" , desPerc)
				hurt.text = "[FFFEA9FF]" .. fmt .. "%" .. "[-]"
				
				userIndex = i
			end
		end
		
		for i=1 ,#(resultInfo.ACampPlayers) do
			if resultInfo.ACampPlayers[i].uid ~= MainData.GetCharId() then
				local partItem = NGUITools.AddChild(partakeGrid.gameObject, partakeItem.gameObject).transform
				partItem:SetParent(partakeGrid.transform , false)
				
				local id = partItem:Find("txt_id"):GetComponent("UILabel")
				if i < userIndex then
					id.text = i + 1
				end
				
				local name = partItem:Find("txt_name"):GetComponent("UILabel")
				name.text = resultInfo.ACampPlayers[i].name
				
				local league = partItem:Find("title_unio/txt_unio"):GetComponent("UILabel")
				league.text = sourceInfo.guildBanner
				
				local hurt = partItem:Find("title_hurt/txt_hurt"):GetComponent("UILabel")
				local desPerc = resultInfo.ACampPlayers[i].Destroy / monsterTotalNum * 100
				local fmt = string.format("%.2f" , desPerc)
				hurt.text = fmt .. "%"
			end
		end
		partakeGrid:Reposition()
	end
	
	_ui.transBtn.gameObject:SetActive(false)
	_ui.transText.gameObject:SetActive(false)
	
end

local function ShowTradeRes(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(true)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	itemtipslist = {}
	--title
	local title1 = _ui.contentCollect:Find("text_title"):GetComponent("UILabel")
	title1.text = TextMgr:GetText("Mail_trade_Desc")
	
	local title2 = _ui.contentCollect:Find("coordinate"):GetComponent("UILabel")
	local strForm = TextMgr:GetText("mail_ui65")
	title2.text = System.String.Format(strForm , msg.misc.source.name, 1 , msg.misc.source.pos.x , msg.misc.source.pos.y)
	SetClickCallback(title2.gameObject , function()
		MainCityUI.ShowWorldMap(tonumber(msg.misc.source.pos.x) , tonumber(msg.misc.source.pos.y), true)
		Mail.Hide()
	end)
		
	local title3 = _ui.contentCollect:Find("text_title2"):GetComponent("UILabel")
	title3.text = TextMgr:GetText("Mail_trade_Desc2")
	
	local grid = _ui.contentCollect:Find("bg_reward/Grid"):GetComponent("UIGrid")
	local childCount = grid.transform.childCount
	for i = 0, childCount - 1 do
        GameObject.Destroy(grid.transform:GetChild(i).gameObject)
    end
	for i, v in ipairs(msg.misc.traderes.res) do
		if v.num > 0 then
			local itemTransform = NGUITools.AddChild(grid.gameObject , _ui.itemPrefab).transform
			itemTransform.name = v.id
			local itemdata = TableMgr:GetItemData(v.id)
			local item = {}
			UIUtil.LoadItemObject(item, itemTransform)
			UIUtil.LoadItem(item, itemdata, v.num)
			
			local tipsitem = {}
			tipsitem.go = itemTransform.gameObject
			table.insert(itemtipslist, tipsitem)
		end
	end
	
	local heroGrid = _ui.contentCollect:Find("bg_hero/Grid"):GetComponent("UIGrid")
	local heroBg = _ui.contentCollect:Find("bg_hero")
	if msg.misc.heros ~= nil and #msg.misc.heros > 0 then
		heroBg.gameObject:SetActive(true)
		LoadActionHero(msg.misc , heroGrid)
	else
		heroBg.gameObject:SetActive(false)
	end 
	
	
	coroutine.start(function()
		coroutine.step()
		grid:Reposition()
	end)
end

local function ShowGuildWareHouseMsg(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(true)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	
	_ui.contentCollect:Find("coordinate").gameObject:SetActive(false)
	_ui.contentCollect:Find("text_title2").gameObject:SetActive(false)
	_ui.contentCollect:Find("bg_hero").gameObject:SetActive(false)
	
	_ui.contentCollect:Find("bg_reward/bg_title/text_guildwarehouse").gameObject:SetActive(true)
	_ui.contentCollect:Find("bg_reward/bg_title/text_reward").gameObject:SetActive(false)
	
	_ui.transBtn.gameObject:SetActive(false)
	_ui.transText.gameObject:SetActive(false)
	
	--print(msg.report.param[2])
	if msg.misc.wareHouseApply.bPassed then -- 批准
		_ui.contentCollect:Find("text_title"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("UnionWareHouse_ui14") ,msg.misc.wareHouseApply.approverName )
	else				     --拒绝
		_ui.contentCollect:Find("text_title"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("UnionWareHouse_ui15") ,msg.misc.wareHouseApply.approverName )
	end
	
	local itemTbData = TableMgr:GetItemData(tonumber(msg.misc.takeres.restype))
	local resGrid = _ui.contentCollect:Find("bg_reward/Grid"):GetComponent("UIGrid")		
	--print(v.id)
	while resGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(resGrid.transform:GetChild(0).gameObject)
	end
	
	local itemTransform = NGUITools.AddChild(resGrid.gameObject, _ui.itemPrefab).transform
    local item = {}
	UIUtil.LoadItemObject(item, itemTransform)
	UIUtil.LoadItem(item, itemTbData, msg.misc.takeres.num)
	resGrid:Reposition()
end

function LoadSingleItem(itemid,itemCount, grid , mailItem)
	--print(item)
	local itemdata = TableMgr:GetItemData(itemid)
	local itemTransform = NGUITools.AddChild(grid.gameObject , mailItem).transform
	local item = {}
	UIUtil.LoadItemObject(item, itemTransform)
	UIUtil.LoadItem(item, itemdata, itemCount)
	
end

function LoadMailCollectHero(hero, heroMsg, heroData )
	if heroMsg == nil then
		hero.empty.gameObject:SetActive(true)
	else
		--将军等级
		local expWithLevel = TableMgr:GetHeroLevelByExp(heroMsg.exp)
		hero.levelLabel.text = math.floor(expWithLevel)
		--将军icon
		hero.head.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
		--将军品质
		hero.qualitySprite.spriteName = "head"..heroData.quality
		--将军星级
		hero.starSprite.width = heroMsg.star * hero.starHeight
		--将军exp
		hero.expLabel.text = "+" .. (heroMsg.exp - heroMsg.oldexp)
		--将军expbar
		hero.expSlider.value = expWithLevel - math.floor(expWithLevel)
	end
end
--local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
 --           LoadHero(hero, heroMsg, heroData)
function LoadActionHero(msg , grid)
	--show hero
	local listitem = ResourceLibrary.GetUIPrefab("CommonItem/listitem_hero_maildoc")
	--local listitem = mainMailDocUI:Find("listitem_hero")
	while grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
	end
	
	for i , v in ipairs(msg.heros) do
		local heroitem = NGUITools.AddChild(grid.gameObject, listitem.gameObject).transform
		heroitem:SetParent(grid.transform , false)
		local heroData = TableMgr:GetHeroData(v.baseid)
		local heroObj = {}
		UIUtil.LoadMailHeroObj(heroObj ,heroitem)
		LoadMailCollectHero(heroObj , v , heroData)
	end
	grid:Reposition()
end

local function ShowReportCollect(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(true)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	if msg.misc == nil then
		print("readmail" .. curMailId)
		return
	end
	
	local takeres = msg.misc.takeres
	local target = msg.misc.target
	
	--tittle
	local itemTbData = TableMgr:GetItemData(tonumber(target.entrytype))
	local title1 = _ui.contentCollect:Find("text_title"):GetComponent("UILabel")
	title1.text = TextUtil.GetItemName(itemTbData)
	
	local title2 = _ui.contentCollect:Find("coordinate"):GetComponent("UILabel")
	local strForm = title2.text
	title2.text = System.String.Format(strForm , 1 , target.pos.x , target.pos.y)
	SetClickCallback(title2.gameObject , function()
		MainCityUI.ShowWorldMap(tonumber(target.pos.x) , tonumber(target.pos.y), true)
		Mail.Hide()
	end)
		
	local title3 = _ui.contentCollect:Find("text_title2"):GetComponent("UILabel")
	title3.text = TextMgr:GetText("ui_worldmap_61")
	
	--show hero
	local heroGrid = _ui.contentCollect:Find("bg_hero/Grid"):GetComponent("UIGrid")
	local heroBg = _ui.contentCollect:Find("bg_hero")
	if msg.misc.heros ~= nil and #msg.misc.heros > 0 then
		heroBg.gameObject:SetActive(true)
		LoadActionHero(msg.misc , heroGrid)
	else
		heroBg.gameObject:SetActive(false)
	end 
	
	local resContent = _ui.contentCollect:Find("bg_reward")
	local resGrid = _ui.contentCollect:Find("bg_reward/Grid"):GetComponent("UIGrid")		
	--print(v.id)
	while resGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(resGrid.transform:GetChild(0).gameObject)
	end
	
	LoadSingleItem(takeres.restype ,takeres.num , resGrid , _ui.itemPrefab)

	local list_reward = {}
	
	
	for i, v in ipairs(takeres.dropReward.items) do
		local needadd = true
		for ii, vv in ipairs(list_reward) do
			if v.id == vv.id then
				vv.num = vv.num + v.num
				needadd = false
			end
		end
		if needadd then
			table.insert(list_reward, v)
		end
	end
	

	for i, v in ipairs(list_reward) do
		LoadSingleItem(tonumber(v.id) ,v.num , resGrid , _ui.itemPrefab)
	end
	
	resGrid:Reposition()
	
	_ui.transBtn.gameObject:SetActive(false)
	_ui.transText.gameObject:SetActive(false)
	
end

local function ShowSiege(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(true)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(true)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	_ui.contentCollect:Find("text_title2").gameObject:SetActive(false)
	_ui.contentCollect:Find("coordinate").gameObject:SetActive(false)
	_ui.contentCollect:Find("text_title").gameObject:SetActive(false)
	_ui.contentCollect:Find("bg_hero").gameObject:SetActive(false)

	local readMailData = MailListData.GetMailDataById(curMailId)
	local content = ""
	
	local grid = _ui.contentCollect:Find("bg_reward/Grid"):GetComponent("UIGrid")
    local listitem = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	while grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
	end
	
    for i=#curReadMailMsg.misc.attachShow.data , 1 , -1 do
		local itemListData = curReadMailMsg.misc.attachShow.data[i]
		for i=1 , #itemListData.data.item.items , 1 do
			local itemData = itemListData.data.item.items[i]
			LoadSingleItem(itemData.data.baseid , itemData.data.number , grid ,_ui.itemPrefab)
		end
		for i=1 , #itemListData.data.hero.data , 1 do
			local itemData = itemListData.data.hero.data[i]
			local hero = NGUITools.AddChild(grid.gameObject, listitem.gameObject).transform
			local heroData = TableMgr:GetHeroData(itemData.data.baseid)
			hero.localScale = Vector3(0.6, 0.6, 1)
			hero:Find("level text").gameObject:SetActive(false)
			hero:Find("name text").gameObject:SetActive(false)
			hero:Find("bg_skill").gameObject:SetActive(false)
			hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
			hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
			local star = hero:Find("star"):GetComponent("UISprite")
			if star ~= nil then
		        star.width = itemData.data.star * star.height
		    end
		    local num = hero:Find("num"):GetComponent("UILabel")
		    num.gameObject:SetActive(true)
		    num.text = "[8CFAFFFF]" .. itemData.data.num .. "[-]"
		end
		
		if itemListData.buff ~= nil and itemListData.buff ~= "" then
			local buffstr = string.split(itemListData.buff , ";")
			for i=1 , #buffstr do
				local info = NGUITools.AddChild(grid.gameObject , _ui.itemPrefab)
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
		
		grid:Reposition()
	end
	
	msg.webgm = maildata.webgm
	_ui.contentdoc:GetComponent("UILabel").text = Mail.GetMailContent(msg)--msg.content--
	--翻译
	_ui.transBtn.gameObject:SetActive(true)
	_ui.transText.gameObject:SetActive(true)
	_ui.transText.text = TextMgr:GetText("chat_hint10")
	SetClickCallback(_ui.transBtn.gameObject , function()
		mailDocContent = {}
		mailDocContent.btn = _ui.transBtn
		mailDocContent.transText = _ui.transText
		mailDocContent.content = _ui.contentdoc:GetComponent("UILabel")--msg.content
		TranslateMail(mailDocContent)
	end)
end

local function ShowGuildTrainMsg(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(true)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	--show hero
	local resContent = _ui.contentTrain:Find("bg_reward")
	local heroGrid = _ui.contentTrain:Find("bg_hero/Grid"):GetComponent("UIGrid")
	local heroBg = _ui.contentTrain:Find("bg_hero")
	if msg.misc.heros ~= nil and #msg.misc.heros > 0 then
		heroBg.localScale = Vector3.one
		LoadActionHero(msg.misc , heroGrid)
	else
		heroBg.localScale = Vector3(1, 0, 1)
	end 
	
	local resGrid = _ui.contentTrain:Find("bg_reward/Grid"):GetComponent("UIGrid")		
	--print(v.id)
	while resGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(resGrid.transform:GetChild(0).gameObject)
	end
	local lastItemTransform
    for _, v in ipairs(msg.misc.train.reward) do
        local itemMsg = v.items[1]
        local itemTbData = TableMgr:GetItemData(itemMsg.id)

        local itemTransform = NGUITools.AddChild(resGrid.gameObject, _ui.itemPrefab).transform
		local item = {}
		UIUtil.LoadItemObject(item, itemTransform)
		UIUtil.LoadItem(item, itemTbData, itemMsg.num)
		
        lastItemTransform = itemTransform
    end
	resGrid:Reposition()
    if lastItemTransform ~= nil then
        local lastPosition = _ui.contentTrain.parent:InverseTransformPoint(lastItemTransform.position)
        _ui.contentTrain:GetComponent("UIWidget").height = -lastPosition.y
    end
	
	
	_ui.transBtn.gameObject:SetActive(false)
	_ui.transText.gameObject:SetActive(false)
	
end

local function ShowReportMonsterDrop(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(true)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	
	--[[if tonumber(msg.report.param[3]) == 0 then --player name
		_ui.contentdoc:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(msg.content) ,msg.report.param[1], msg.report.param[2])
	else
		_ui.contentdoc:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(msg.content) ,TextMgr:GetText(msg.report.param[1]), msg.report.param[2])
	end
	]]
	_ui.contentdoc:GetComponent("UILabel").text = Mail.GetMailContent(maildata)
	--show hero
	local heroGrid = _ui.contentdoc:Find("bg_hero/Grid"):GetComponent("UIGrid")
	local heroBg = _ui.contentdoc:Find("bg_hero")
	if msg.misc.heros ~= nil and #msg.misc.heros > 0 then
		heroBg.gameObject:SetActive(true)
		LoadActionHero(msg.misc , heroGrid)
	else
		heroBg.gameObject:SetActive(false)
	end
	--翻译
	_ui.transBtn.gameObject:SetActive(true)
	_ui.transText.gameObject:SetActive(true)
	_ui.transText.text = TextMgr:GetText("chat_hint10")
	SetClickCallback(_ui.transBtn.gameObject , function()
		mailDocContent = {}
		mailDocContent.btn = _ui.transBtn
		mailDocContent.transText = _ui.transText
		mailDocContent.content = _ui.contentdoc:GetComponent("UILabel")--msg.content
		TranslateMail(mailDocContent)
	end)
	
end

local function ShowUserContent(msg, maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(true)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)

	
	_ui.contentdoc:GetComponent("UILabel").text = msg.content
	--翻译
	print("2222222")
	_ui.transBg.gameObject:SetActive(true)
	_ui.transBtn.gameObject:SetActive(true)
	_ui.transText.gameObject:SetActive(true)
	_ui.transText.text = TextMgr:GetText("chat_hint10")
	SetClickCallback(_ui.transBtn.gameObject , function()
		_ui.transBtn.gameObject:SetActive(false)
		_ui.transText.gameObject:SetActive(false)
		_ui.transing.gameObject:SetActive(true)
		mailDocContent = {}
		mailDocContent.btn = _ui.transBtn
		mailDocContent.transText = _ui.transText
		mailDocContent.content = _ui.contentdoc:GetComponent("UILabel")--msg.content
		mailDocContent.srcContent = msg.content
		TranslateMail(mailDocContent)
	end)
end

local function ShowNormalContent(msg , maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(true)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)

	local readMailData = MailListData.GetMailDataById(curMailId)
	local content = ""
	--[[if maildata.webgm then
		_ui.contentdoc:GetComponent("UILabel").text = msg.content
	else
		if readMailData.mailcfgtype == 3 or readMailData.mailcfgtype == 5 then -- 系统联盟邮件
			_ui.contentdoc:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(msg.content) , msg.report.param[1])
		elseif readMailData.mailcfgtype == 4 then
			_ui.contentdoc:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(msg.content) , TextMgr:GetText(msg.report.param[1]) , msg.report.param[2])
		else
			_ui.contentdoc:GetComponent("UILabel").text = TextMgr:GetText(msg.content)
		end
		
	end
	]]
	msg.webgm = maildata.webgm
	_ui.contentdoc:GetComponent("UILabel").text = Mail.GetMailContent(msg)--msg.content--
	--翻译
	_ui.transBtn.gameObject:SetActive(true)
	_ui.transText.gameObject:SetActive(true)
	_ui.transText.text = TextMgr:GetText("chat_hint10")
	SetClickCallback(_ui.transBtn.gameObject , function()
		mailDocContent = {}
		mailDocContent.btn = _ui.transBtn
		mailDocContent.transText = _ui.transText
		mailDocContent.content = _ui.contentdoc:GetComponent("UILabel")--msg.content
		TranslateMail(mailDocContent)
	end)
	
end


local function ShowFortAllContent(msg , maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(true)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	
	for i=1 , 6 do
		local forChild = _ui.contentFortAll:Find("Grid"):GetChild(i-1)
		local fortmsg = msg.misc.fortOccupy.data[i]
		local fortRuleData = TableMgr:GetFortRuleData(fortmsg.subType)
		
		local fortName = forChild:Find("title_reward/txt_title"):GetComponent("UILabel")
		fortName.text = TextMgr:GetText(fortRuleData.name)
		
		local fortCoord = forChild:Find("title_reward/coor"):GetComponent("UILabel")
		fortCoord.text = string.format("#1 x:%d y:%d" , fortRuleData.Xcoord , fortRuleData.Ycoord)
		SetClickCallback(fortCoord.gameObject , function()
			MainCityUI.ShowWorldMap(tonumber(fortRuleData.Xcoord) , tonumber(fortRuleData.Ycoord), true)
			Mail.Hide()
		end)
		
		local bg = forChild:Find("bg1")
		local unlock = forChild:Find("unlock")
		bg.gameObject:SetActive(fortmsg.available)
		unlock.gameObject:SetActive(not fortmsg.available)
		
		--rank
		if fortmsg.available then
			for k=1 , 3 do
				if fortmsg.rankList ~= nil and #fortmsg.rankList > 0 then
					if k <= #fortmsg.rankList then
						local rank = fortmsg.rankList[k]
						local noName = forChild:Find(string.format("bg1/no.%d/title_unio" , k)):GetComponent("UILabel")
						noName.text = string.format("[%s]%s" , rank.guildBanner , rank.guildName)
						
						local noHurt = forChild:Find(string.format("bg1/no.%d/title_hurt/txt_hurt" , k)):GetComponent("UILabel")
						noHurt.text = string.format("%.2f" , rank.percent).."%"
					end
				end
			end
			
			local headOwner = forChild:Find("bg1/head01")
			local headEmpty = forChild:Find("bg1/head02")
			headOwner.gameObject:SetActive(fortmsg.ownerInfo.leaderFace > 0)
			headEmpty.gameObject:SetActive(not (fortmsg.ownerInfo.leaderFace > 0))

			if fortmsg.ownerInfo.leaderFace > 0 then
				local icon = headOwner:Find("Texture"):GetComponent("UITexture")
				icon.mainTexture = ResourceLibrary:GetIcon("Icon/head/" , fortmsg.ownerInfo.leaderFace)
				
				local name = headOwner:Find("name"):GetComponent("UILabel")
				name.text = string.format("[%s]%s" , fortmsg.ownerInfo.guildBanner , fortmsg.ownerInfo.leaderName)
				--vip
				
			end
		end
	end
end

local function ShowMobaOverContent(msg , maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(true)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(true)
	
	_ui.contentdoc:GetComponent("UILabel").text = Mail.GetMailContent(msg)--msg.content--
	
	local BRank = TableMgr:GetMobaRankDataByID(msg.misc.mobaResult.oldlevel)
	local FRank = TableMgr:GetMobaRankDataByID(msg.misc.mobaResult.level)
	_ui.bg_moba:Find("other/right/rankname"):GetComponent("UILabel").text = TextMgr:GetText(BRank.RankName)
	_ui.bg_moba:Find("other/left/rankname"):GetComponent("UILabel").text = TextMgr:GetText(FRank.RankName)
	
	_ui.bg_moba:Find("other/right/now"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", BRank.RankIcon)
	_ui.bg_moba:Find("other/left/now"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", FRank.RankIcon)

	_ui.bg_moba:Find("other/number_1"):GetComponent("UILabel").text = msg.misc.mobaResult.oldbravepoint
	_ui.bg_moba:Find("other/number_2"):GetComponent("UILabel").text = msg.misc.mobaResult.bravepoint
	
	--[[for i=1 , 5 do
		_ui.bg_moba:Find(string.format("other/right/stars/bg (%d)/star" , i)).gameObject:SetActive(i <= msg.misc.mobaResult.oldstar)
	end
	for i=1 , 5 do
		_ui.bg_moba:Find(string.format("other/left/stars/bg (%d)/star" , i)).gameObject:SetActive(i <= msg.misc.mobaResult.star)
	end
	]]
	--reward
	local rewardGrid = _ui.bg_moba:Find("Grid"):GetComponent("UIGrid")
	while rewardGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(rewardGrid.transform:GetChild(0).gameObject)
	end
	
	for i=1 , #msg.misc.mobaResult.reward.items do
		local v = msg.misc.mobaResult.reward.items[i]
		local itemdata = TableMgr:GetItemData(v.id)
		local itemTransform = NGUITools.AddChild(rewardGrid.gameObject , _ui.itemPrefab).transform
		local item = {}
		UIUtil.LoadItemObject(item, itemTransform)
		UIUtil.LoadItem(item, itemdata, v.num)
		
		SetPressCallback(item.gameObject , function(go,pressed)
			--print("item detail : itembaseid" .. v.id)
			Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})

		end)
	end
	rewardGrid:Reposition()
	
	
	--old stars
	local rank_icon = _ui.bg_moba:Find("other/right/now"):GetComponent("UITexture")
	while rank_icon.transform.childCount > 0 do
		rank_icon.transform:GetChild(0):SetParent(_ui.bg_moba:Find("other/right/stars") , false)
	end
	
	
	 local stars = {}
    for i = 1, 6 do
        local staritem = {}
        staritem.bg = _ui.bg_moba:Find(string.format("other/right/stars/bg (%d)", i)).gameObject
        staritem.star = _ui.bg_moba:Find(string.format("other/right/stars/bg (%d)/star", i)).gameObject
        if i == 6 then
            staritem.num = _ui.bg_moba:Find(string.format("other/right/stars/bg (%d)/NUMBER", i)):GetComponent("UILabel")
        end
        stars[i] = staritem
    end
	
	if msg.misc.mobaResult.oldstar <= 5 then
        for i = 1, BRank.RankStar do
            stars[i].bg:SetActive(true)
            stars[i].star:SetActive(i <= msg.misc.mobaResult.oldstar)
            UIUtil.SetStarPos(rank_icon, stars[i].bg, BRank.RankStar, i, 103, 33)
        end
        for i = BRank.RankStar + 1, 5 do
            stars[i].bg:SetActive(false)
        end
        stars[6].bg:SetActive(false)
    else
        for i = 1, 5 do
            stars[i].bg:SetActive(false)
        end
        stars[6].bg:SetActive(true)
        stars[6].num.text = msg.misc.mobaResult.oldstar
    end
	--cur stars
	rank_icon = _ui.bg_moba:Find("other/left/now"):GetComponent("UITexture")
	while rank_icon.transform.childCount > 0 do
		rank_icon.transform:GetChild(0):SetParent(_ui.bg_moba:Find("other/left/stars") , false)
	end
	
	stars = {}
    for i = 1, 6 do
        local staritem = {}
        staritem.bg = _ui.bg_moba:Find(string.format("other/left/stars/bg (%d)", i)).gameObject
        staritem.star = _ui.bg_moba:Find(string.format("other/left/stars/bg (%d)/star", i)).gameObject
        if i == 6 then
            staritem.num = _ui.bg_moba:Find(string.format("other/left/stars/bg (%d)/NUMBER", i)):GetComponent("UILabel")
        end
        stars[i] = staritem
    end
	
	if msg.misc.mobaResult.star <= 5 then
        for i = 1, FRank.RankStar do
            stars[i].bg:SetActive(true)
            stars[i].star:SetActive(i <= msg.misc.mobaResult.star)
            UIUtil.SetStarPos(rank_icon, stars[i].bg, FRank.RankStar, i, 103, 33)
        end
        for i = FRank.RankStar + 1, 5 do
            stars[i].bg:SetActive(false)
        end
        stars[6].bg:SetActive(false)
    else
        for i = 1, 5 do
            stars[i].bg:SetActive(false)
        end
        stars[6].bg:SetActive(true)
        stars[6].num.text = msg.misc.mobaResult.star
    end
end

local function ShowDocBannerContent(msg , maildata)
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.bg_moba.gameObject.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(true)

	_ui.contentdocbanner:GetComponent("UILabel").text = Mail.GetMailContent(msg)--msg.content--	
	
	local mailCfg = TableMgr:GetMailCfgData(msg.baseid)
	if mailCfg and mailCfg.param1 ~= "" then
		local params = string.split(mailCfg.param1 , ",")
		if params and #params >= 2 then
			_ui.contentdocbanner:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(params[1].."/", params[2])
		end
	end
	
	--[[if msg.baseid == MailBaseId.RebelReadyStart or msg.baseid == MailBaseId.RebelStart then
		--炮车预告
		_ui.contentdocbanner:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", "mail_predict_rebel")
	elseif msg.baseid == MailBaseId.RebelArmyAttackReadyStart or msg.baseid == MailBaseId.RebelArmyAttackStart then
		--叛军预告
		_ui.contentdocbanner:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", "mail_predict_attack")
	elseif msg.baseid == MailBaseId.FortReadyStart or msg.baseid == MailBaseId.FortStart then
		--要塞预告
		_ui.contentdocbanner:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", "mail_predict_fort")
	end]]
end

function ReadMail(maildataid , mailMsg , dirShow)
	directShow = dirShow
	curMailId = maildataid
	curReadMailMsg = mailMsg
	local readMailData = MailListData.GetMailDataById(curMailId)
	if readMailData == nil then
		--print("readmail" .. curMailId)
		return
	end
	print("readmail" .. curMailId)
	--Mail.OpenMailUI("MailDoc")
	
	local title = mainMailDocUI:Find("bg_frane/bg_msg/title_name/text_name"):GetComponent("UILabel")
	local gov = mainMailDocUI:Find("bg_frane/bg_msg/title_name/bg_gov")
	if gov ~= nil then
		gov.localScale = Vector3(0,1,1)
		gov.gameObject:SetActive(false)
	end
		
	if readMailData.category == MailMsg_pb.MailType_System then
		title.text = TextMgr:GetText("mail_ui43")
	elseif readMailData.category == MailMsg_pb.MailType_Report then
		title.text = TextMgr:GetText(readMailData.fromname)
	elseif readMailData.category == MailMsg_pb.MailType_Moba then
		title.text = TextMgr:GetText("mail_ui43")
	else
		local gov = mainMailDocUI:Find("bg_frane/bg_msg/title_name/bg_gov")
		if gov ~= nil then
			local baseTitle = mainMailDocUI:Find("bg_frane/bg_msg/title_name/bg_gov/text (1)")
			--[[
				bug：【领主邮件】抬头错误  ID： 1003120
				baseid 为1002的邮件，不应该带有[战区邮件]的title
			]]
			if readMailData.baseid == 1002 then
				baseTitle.localScale = Vector3(1,1,1)
			else
				baseTitle.localScale = Vector3(0,1,1)
			end
			GOV_Util.SetGovNameUI(gov,readMailData.fromOfficialId,readMailData.fromGuildOfficialId,true,readMailData.militaryRankId)
		end
		title.text = "[ffffff]" .. readMailData.fromGuildBanner ~= nil and readMailData.fromGuildBanner ~= "" and (string.format("【%s】%s" ,readMailData.fromGuildBanner, readMailData.fromname)) or  readMailData.fromname.. "[-]"



		SetClickCallback(title.gameObject , function()
			local data = {}
			data.name = readMailData.fromname;
			data.text = curReadMailMsg.content;
			data.id = readMailData.fromid;
			data.kind = 2;
			PanelBox.Show(data);
			--[[if readMailData.fromid ~= nil and readMailData.fromid ~= MainData.GetCharId() then
				 OtherInfo.RequestShow(readMailData.fromid)
			end ]]--
		end)
	end
	
	local mailTime = mainMailDocUI:Find("bg_frane/bg_msg/title_time/text_time"):GetComponent("UILabel")
	--为了把日期和时间中间间隔拉大一些 = =#
	local timeText = Serclimax.GameTime.SecondToStringYMDLocal(readMailData.createtime):split(" ")
	local showTime = Global.SecondToStringFormat(readMailData.createtime , "yyyy-MM-dd HH:mm:ss")--timeText[1] .. "     " .. timeText[2]
	mailTime.text = showTime
	
	--邮件提示
	local mailHint = mainMailDocUI:Find("bg_frane/bg_hint/text"):GetComponent("UILabel")
	if readMailData.category == MailMsg_pb.MailType_System  or readMailData.category == MailMsg_pb.MailType_User then
		local hintType = ""
		if readMailData.category == MailMsg_pb.MailType_System then
			hintType = System.String.Format(TextMgr:GetText("mail_ui42") , TextMgr:GetText("mail_ui43"))
		else
			hintType = System.String.Format(TextMgr:GetText("mail_ui42") , "[00ccff]" .. TextMgr:GetText("mail_ui44") .. "[-]")
		end
		mailHint.transform.parent.gameObject:SetActive(true)
		mailHint.text = hintType
	else
		mailHint.transform.parent.gameObject:SetActive(false)
	end
	
	
	--附件
	local mailhero = ResourceLibrary.GetUIPrefab("CommonItem/hero")--mainMailDocUI:Find("hero")
	local mailItemGrid = mainMailDocUI:Find("bg_frane/bg_msg/bg_item/Grid"):GetComponent("UIGrid")
	local mail_bgItem = mainMailDocUI:Find("bg_frane/bg_msg/bg_item")
	
	while mailItemGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(mailItemGrid.transform:GetChild(0).gameObject)
	end
	
	mail_bgItem.gameObject:SetActive((not readMailData.taked) and (readMailData.hasattach))
	if not readMailData.taked and readMailData.hasattach then
		--local attachListShow = MailListData.GetAttachList(curMailId)
		local attachListShow = {}
		for _ , v in ipairs(mailMsg.misc.attachList) do
			
			local key = "0" .. v.type .. v.id
			--print(key)
			if attachListShow[key] == nil then
				attachListShow[key] = {}
				attachListShow[key].data = v
				attachListShow[key].count = (v.num > 0 and v.num or 1)
			else
				attachListShow[key].count = attachListShow[key].count + (v.num > 0 and v.num or 1)
			end
		end
		
		for _ , v in pairs(attachListShow) do
			if v ~= nil then
				if v.data.type == 1 then
					local itemdata = TableMgr:GetItemData(v.data.id)
					local itemTransform = NGUITools.AddChild(mailItemGrid.gameObject , _ui.itemPrefab).transform
					local item = {}
					UIUtil.LoadItemObject(item, itemTransform)
					UIUtil.LoadItem(item, itemdata, v.count)
			
					SetPressCallback(item.gameObject , function(go,pressed)
						--print("item detail : itembaseid" .. v.id)
						Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})

					end)
					
				else
					local heroitem = NGUITools.AddChild(mailItemGrid.gameObject , mailhero.gameObject)
					heroitem.gameObject:SetActive(true)
					heroitem.transform:SetParent(mailItemGrid.transform , false)
					heroitem.transform.localScale = heroitem.transform.localScale * 0.75
					
					local heroData = TableMgr:GetHeroData(v.data.id)
					local heroicon = heroitem.transform:Find("head icon"):GetComponent("UITexture")
					heroicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
					
					local herolv = heroitem.transform:Find("level text"):GetComponent("UILabel")
					herolv.text = v.data.level
					
					local herostar = heroitem.transform:Find(System.String.Format("star/star{0}" , v.data.star))
					herostar.gameObject:SetActive(true)
					
					local heroQuality = heroitem.transform:Find(System.String.Format("head icon/outline{0}" , heroData.quality))
					heroQuality.gameObject:SetActive(true)
					
					local heroName = heroitem.transform:Find("bg_name")
					if heroName ~= nil then
						heroName.gameObject:SetActive(true)
						local nametext = heroitem.transform:Find("bg_name/txt_num"):GetComponent("UILabel")
						nametext.text = TextMgr:GetText(heroData.nameLabel)
					end
					
					local heroCount = heroitem.transform:Find("num_item"):GetComponent("UILabel")
					heroCount.text = v.count
					
					SetClickCallback(heroicon.gameObject , function(go,pressed)
						Tooltip.ShowItemTip({name =  TextMgr:GetText(heroData.nameLabel), text = TextUtil.GetItemDescription(heroData)})

					end)
				end
			end
		end
		mailItemGrid:Reposition()
	end
	
	if not readMailData.taked and readMailData.hasattach then
		mainMailDocUI:Find("bg_frane/bg_msg/bg_item/btn_get").gameObject:SetActive(true)
	else
		mainMailDocUI:Find("bg_frane/bg_msg/bg_item/btn_get").gameObject:SetActive(false)
	end
	
	local heroBg = _ui.contentdoc:Find("bg_hero")
	heroBg.gameObject:SetActive(false)
	if readMailData.category == MailMsg_pb.MailType_Report then
		if readMailData.subtype == Mail.MailReportType.MailReport_monster then
			ShowReportMonsterContent(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReport_takeres or
				readMailData.subtype == Mail.MailReportType.MailReport_GuildMine then
			ShowReportCollect(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReport_traderes then
			ShowTradeRes(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReport_monsterdrop or 
				readMailData.subtype == Mail.MailReportType.MailReport_actmonsterfinder or 
				readMailData.subtype == Mail.MailReportType.MailReport_actmonsterdrop then
			ShowReportMonsterDrop(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReport_GuildTrain then
			ShowGuildTrainMsg(curReadMailMsg , readMailData)
		else
			ShowNormalContent(curReadMailMsg , readMailData)
		end
		
		
	elseif readMailData.category == MailMsg_pb.MailType_User then
		ShowUserContent(curReadMailMsg , readMailData)
	else
		if readMailData.subtype == Mail.MailReportType.MailReport_siegeReward then
			ShowSiege(curReadMailMsg, readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReport_GuildWareHouse then
			ShowGuildWareHouseMsg(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReport_fortAll then
			ShowFortAllContent(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReport_activityTrailer then
			ShowDocBannerContent(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MobaMailReport_SceneOver then
			ShowMobaOverContent(curReadMailMsg , readMailData)
		elseif readMailData.subtype == Mail.MailReportType.MailReort_occupyWorldCity then
			ShowSiege(curReadMailMsg, readMailData)
		else 
			ShowNormalContent(curReadMailMsg , readMailData)
		end
	end
	
	_ui.contentScrollView:ResetPosition()
end


local function GetAttachItems(go)
	print("Get all attachitems : " .. curMailId)
	local req = MailMsg_pb.MsgUserMailTakeAttachmentRequest()
	req.mailid:append(curMailId) 
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailTakeAttachmentRequest, req, MailMsg_pb.MsgUserMailTakeAttachmentResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			GUIMgr:SendDataReport("reward", "MailTakeAttachment", "".. MoneyListData.ComputeDiamond(msg.fresh.money.money))
						
			MainCityUI.UpdateRewardData(msg.fresh)
			MailListData.GetMailAttachItem(msg.mailid)
			
			local readMailData = MailListData.GetMailDataById(curMailId)
			Mail.RequestReadMail(readMailData , function()
				ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
				ItemListShowNew.SetItemShow(msg)
				GUIMgr:CreateMenu("ItemListShowNew" , false)
			end, directShow)
			--ReadMail(readMailData , curReadMailMsg , directShow)
			
		end
	end)
end

function OpenUI()
	Tooltip.HideItemTip()
	if translateCoroutine ~= nil then
		coroutine.stop(translateCoroutine)
		translateCoroutine = nil
	end
	mailDocContent = nil
	_ui.transing.gameObject:SetActive(false)
	_ui.transBg.gameObject:SetActive(false)
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
	if nextMail == nil or directShow then
		nextBtn.gameObject:SetActive(false)
	else
		nextBtn.gameObject:SetActive(true)
	end
	
	local previousBtn = mainMailDocUI:Find("bg_frane/bg_bottom/btn_previous"):GetComponent("UIButton")
	if preMail == nil or directShow then
		previousBtn.gameObject:SetActive(false)
	else
		previousBtn.gameObject:SetActive(true)
	end
	
	if directShow then
		local closeBtn = mainMailDocUI:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
		SetClickCallback(closeBtn.gameObject , function(go)
			Hide()
		end)
		SetClickCallback(mainMailDocUI.gameObject , function(go)
			Hide()
		end)
	end
	
	local mailItemGet = mainMailDocUI:Find("bg_frane/bg_msg/bg_item/btn_get"):GetComponent("UIButton") 
	SetClickCallback(mailItemGet.gameObject , GetAttachItems)
	
	local readMailData = MailListData.GetMailDataById(curMailId)
	local replyBtn = mainMailDocUI:Find("bg_frane/bg_bottom/Grid/bg_reply")
	if readMailData.category == MailMsg_pb.MailType_Report or readMailData.category == MailMsg_pb.MailType_System or  readMailData.category == MailMsg_pb.MailType_Moba or  
		readMailData.category == MailMsg_pb.MailType_GuildMoba then
		
		replyBtn.transform.localScale = Vector3(0,1,1)
	else
		replyBtn.transform.localScale = Vector3(1,1,1)
	end
	
	local saveBtn = mainMailDocUI:Find("bg_frane/bg_bottom/Grid/bg_save/btn_ save")
	SetClickCallback(saveBtn.gameObject , function(go)
		print("saveBtn")
		Mail.SaveMail(curMailId)
		Hide()
	end)
	
	if readMailData.category == MailMsg_pb.MailType_Moba or readMailData.category == MailMsg_pb.MailType_GuildMoba then
		replyBtn.transform.localScale = Vector3(0,1,1)
		saveBtn.transform.localScale = Vector3(0,1,1)
		saveBtn.gameObject:SetActive(false)
	else
		saveBtn.transform.localScale = Vector3(1,1,1)
		saveBtn.gameObject:SetActive(not readMailData.saved)
	end
	

	local delBtn = mainMailDocUI:Find("bg_frane/bg_bottom/Grid/bg_del/btn_del"):GetComponent("UIButton")
	SetClickCallback(delBtn.gameObject , function(go)
		print("delBtn")
		local delist = {}
		delist[1] = {}
		delist[1].id = curMailId
		Hide()
			
		Mail.DeleteMail(delist)
	end)
end

function Init(mailTransform)
	
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
	--Init()
end


function Hide()
	Global.CloseUI(_M)
end


function CloseUI()
	print("maildoc CloseUI()")
	--[[Tooltip.HideItemTip()
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject:SetActive(false)
	curReadMailMsg = nil
	directShow = false
	
	if translateCoroutine ~= nil then
		coroutine.stop(translateCoroutine)
		translateCoroutine = nil
	end]]
	Hide()
end

function Awake()
	_ui = {}
	mainMailDocUI = transform:Find("MailDoc")
	_ui.contentScrollView = mainMailDocUI:Find("bg_frane/Scroll View"):GetComponent("UIScrollView")
	_ui.contentCollect = mainMailDocUI:Find("bg_frane/Scroll View/bg_collection")
	_ui.contentMonster = mainMailDocUI:Find("bg_frane/Scroll View/bg_monster")
	_ui.contentdoc = mainMailDocUI:Find("bg_frane/Scroll View/doc")
	_ui.contentTrain = mainMailDocUI:Find("bg_frane/Scroll View/bg_train")
	_ui.contentFortAll = mainMailDocUI:Find("bg_frane/Scroll View/bg_fortall")
	_ui.contentdocbanner = mainMailDocUI:Find("bg_frane/Scroll View/doc_banner")
	_ui.bg_moba = mainMailDocUI:Find("bg_frane/Scroll View/bg_moba")
	
	_ui.transBg = mainMailDocUI:Find("bg_frane/bg_mid/bg_translate")
	_ui.transBtn = mainMailDocUI:Find("bg_frane/bg_mid/bg_translate/btn_translate"):GetComponent("UIButton")
	_ui.transText = mainMailDocUI:Find("bg_frane/bg_mid/bg_translate/text"):GetComponent("UILabel")
	_ui.transing = mainMailDocUI:Find("bg_frane/bg_mid/bg_translate/bg_traning")
	
	_ui.transBg.gameObject:SetActive(false)
	_ui.transBtn.gameObject:SetActive(false)
	_ui.transText.gameObject:SetActive(false)
	_ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	
	local closeBtn = mainMailDocUI:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		Hide()
	end)
	SetClickCallback(mainMailDocUI.gameObject , function(go)
		Hide()
	end)
	
	local replyBtn = mainMailDocUI:Find("bg_frane/bg_bottom/Grid/bg_reply/btn_reply"):GetComponent("UIButton")
	SetClickCallback(replyBtn.gameObject , function(go)
		print("replyBtn:" .. curMailId)
		local readMailData = MailListData.GetMailDataById(curMailId)
		
		--MailNew.SetMailData(readMailData)
		if directShow then
			MailNew.SetCloseCallBack(function()
				Mail.Hide()
			end)
		end
		MailNew.Show(readMailData)
		
	end)
	
	local previousBtn = mainMailDocUI:Find("bg_frane/bg_bottom/btn_previous"):GetComponent("UIButton")
	SetClickCallback(previousBtn.gameObject , function(go)
		print("previousBtn")
		local preMail 
		if Mail.GetTabSelect() == 4 then
			preMail = MailListData.GetSavedPreMail(curMailId)
		else
			preMail = MailListData.GetPreMail(curMailId)
		end
		
		local preMailData = MailListData.GetMailDataById(preMail.id)
		
		--print("pre" .. preMailData.id , preMailData.type , preMailData.subtype)
		Mail.RequestReadMail(preMailData, nil , directShow)
		
	end)
	

	local nextBtn = mainMailDocUI:Find("bg_frane/bg_bottom/btn_next"):GetComponent("UIButton")
	SetClickCallback(nextBtn.gameObject , function(go)
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
	
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Close()
	
	print("maildoc close()")
	Tooltip.HideItemTip()
	_ui.contentCollect.gameObject:SetActive(false)
	_ui.contentMonster.gameObject:SetActive(false)
	_ui.contentdoc.gameObject:SetActive(false)
	_ui.contentTrain.gameObject:SetActive(false)
	_ui.contentFortAll.gameObject:SetActive(false)
	_ui.contentdocbanner.gameObject:SetActive(false)
	_ui.bg_moba.gameObject:SetActive(false)
	curReadMailMsg = nil
	directShow = false
	
	if translateCoroutine ~= nil then
		coroutine.stop(translateCoroutine)
		translateCoroutine = nil
	end
	
	_ui = nil
	curReadMailMsg = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	
end
