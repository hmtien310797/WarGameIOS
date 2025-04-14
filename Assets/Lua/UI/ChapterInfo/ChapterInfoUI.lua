module("ChapterInfoUI", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local labelTitle
local labelDescription
local labelEnergyCost

local starList
local labelMission
local enemyList
local rewardTitle
local rewardList
local missionTip
local tweenGroupChapter
local tweenGroupMaterial
local chapterCount

local btnMissionTip
local btnBack
local btnAttack

local battleId
local itemTipTarget
local chapterPower
local uiMask

local gatherParam 

local _uiControl

class "Enemy"
{
}

function SetActive(active)
	gameObject:SetActive(active)
end

function Hide()
	if GUIMgr:FindMenu("ChapterSelectUI") ~= nil then
		ChapterSelectUI.ShowControledMenu(true)
	end
    Global.CloseUI(_M)
end

local function BackClickCallBack(go)
	GUIMgr:CloseMenu("ChapterInfoUI")
end

local function AttackClickCallback(go)
	local battleData = TableMgr:GetBattleData(battleId)
	local chapData = TableMgr:GetChapterData(battleData.chapterId)
	local levelMsg = ChapterListData.GetLevelData(battleId)
	if levelMsg ~= nil then
		Global.DumpMessage(levelMsg , "d:/MsgFreshBattleCountRequest.lua")
	end
	
	if levelMsg ~= nil and chapData.type == 5 and  levelMsg.leftcount <= 0 then
		FloatText.Show(TextMgr:GetText("EliteChapter_ui7"))--FloatText.Show("精英关卡挑战次数不足")
		return
	end
	
	GUIMgr:CloseMenu("ChapterInfoUI")
	if GeneralData.HasBattleHero() --[[HeroListData.HasBattleHero()]] and FunctionListData.IsUnlocked(136) then
		SelectHero.SetCurBattleId(battleId)
		SelectHero.Show(Common_pb.BattleTeamType_Main)
	else
		SelectArmy.SetCurBattleId(battleId)
		SelectArmy.Show(Common_pb.BattleTeamType_Main)
	end
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	for i, v in ipairs(enemyList) do
		if go == v.btn.gameObject then
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = v.name, text = v.description})
            else
                if itemTipTarget == go then
                    Tooltip.HideItemTip()
                else
                    itemTipTarget = go
                    Tooltip.ShowItemTip({name = v.name, text = v.description})
                end
            end
			return
		end
	end

	for i, v in ipairs(rewardList) do
		if go == v.item.gameObject or go == v.hero.btn.gameObject then
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = v.name, text = v.description})
            else
                if itemTipTarget == go then
                    Tooltip.HideItemTip()
                else
                    itemTipTarget = go
                    Tooltip.ShowItemTip({name = v.name, text = v.description})
                end
            end
			return
		end
	end

	Tooltip.HideItemTip()
end

local towerIconList = 
{
	{"mtowerNumber", "icon_machinegun"},
	{"stwoerNumber", "icon_snipe"},
	{"barNumber", "icon_camp"},
}

local function SetTextColor()
	local battleData = TableMgr:GetBattleData(battleId)
	local btnSweepOneLabel = sweepBg.transform:Find("btn_sweep1/num"):GetComponent("UILabel")
	local btnSweepTenLabel = sweepBg.transform:Find("btn_sweep10/num"):GetComponent("UILabel")
	if battleData.energyCost > MainData.GetEnergy() then
		btnSweepOneLabel.color = Color.red
	else
		btnSweepOneLabel.color = Color.white
	end
	if battleData.energyCost * 10 > MainData.GetEnergy() then
		btnSweepTenLabel.color = Color.red
	else
		btnSweepTenLabel.color = Color.white
	end
end

local function LoadUI()
    local levelMsg = ChapterListData.GetLevelData(battleId)
	local levelStar = {}
	local starCount = 0
	if levelMsg ~= nil then
		for _, v in ipairs(levelMsg.star) do
			if v then
				starCount = starCount + 1
			end
		end
		levelStar = levelMsg.star
	end

	local battleData = TableMgr:GetBattleData(battleId)
	labelTitle.text = TextMgr:GetText(battleData.nameLabel)
	labelDescription.text = TextMgr:GetText(battleData.desLabel)
	labelEnergyCost.text = battleData.energyCost
	chapterPower.text = battleData.fight
	for i, v in ipairs(starList) do
		local light = i <= starCount
		v.light.gameObject:SetActive(light)
		v.dark.gameObject:SetActive(not light)
	end
	local enemyIndex = 1
	for v in string.gsplit(battleData.enemyId, ";") do
		local enemy = enemyList[enemyIndex]
		local first = true 
		for vv in string.gsplit(v, "-") do
			if first then
				enemy.unitId = tonumber(vv)
				first = false
			else
				enemy[vv] = true
			end
		end
		enemyIndex = enemyIndex + 1
	end
	for i = enemyIndex, 5 do
		enemyList[i].unitId = 0
	end

	for _, v in ipairs(enemyList) do
		if v.unitId == 0 then
			v.btn.gameObject:SetActive(false)
		else
			v.btn.gameObject:SetActive(true)
			local unitData = TableMgr:GetUnitData(v.unitId)
			v.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", unitData._unitSoldierIcon)
			v.newIcon.gameObject:SetActive(v.new and starCount == 0)

			v.unitData = unitData
			v.name = TextUtil.GetUnitName(unitData)
			v.description = TextUtil.GetUnitDescription(unitData)
		end
	end

	local dropId
	if starCount == 0 then
	    rewardTitle.text = TextMgr:GetText(Text.chapterinfo_ui5)
		dropId = battleData.firstShowDropId
	else
		dropId = battleData.normalShowDropId
	    rewardTitle.text = TextMgr:GetText(Text.chapterinfo_ui2)
	end
	local dropShowList = TableMgr:GetDropShowData(dropId)
	local length = #dropShowList
	for i, v in ipairs(rewardList) do
		if i > length then
			v.item.gameObject:SetActive(false)
			v.hero.transform.gameObject:SetActive(false)
        else
            local dropShowData = dropShowList[i]
            local contentType = dropShowData.contentType
            local contentId = dropShowData.contentId
            local item = v.item
            local hero = v.hero
            item.gameObject:SetActive(contentType == 1 or contentType == 4)
            hero.transform.gameObject:SetActive(contentType == 3)
            if contentType == 1 then
                local itemData = TableMgr:GetItemData(contentId)
                UIUtil.LoadItem(item, itemData, dropShowData.contentNumber)
                v.name = TextUtil.GetItemName(itemData)
                v.description = TextUtil.GetItemDescription(itemData)
            elseif contentType == 4 then
				local soldierData = TableMgr:GetBarrackData(contentId, dropShowData.level)
				UIUtil.LoadSoldier(item , soldierData , dropShowData.contentNumber)
            else
                local heroData = TableMgr:GetHeroData(contentId)
                local heroMsg = Common_pb.HeroInfo() 
                heroMsg.star = dropShowData.star
                heroMsg.level = dropShowData.level
				heroMsg.num = dropShowData.contentNumber
                HeroList.LoadHero(hero, heroMsg, heroData)
                v.name = TextMgr:GetText(heroData.nameLabel)
                v.description = TextMgr:GetText(heroData.description)
            end
        end
	end
	
	for i, v in ipairs(missionTip.list) do
	    local starConditionId = battleData["starCondition"..i]
	    local starConditionData = TableMgr:GetStarConditionData(starConditionId)

		local missionDesc = starConditionData.description
		v.description.text = TextMgr:GetText(missionDesc)
		local light = i <= starCount
		v.lightStar.gameObject:SetActive(levelStar[i])
		v.darkStar.gameObject:SetActive(not levelStar[i])
	end
	labelMission.text = missionTip.list[1].description.text
	--sweepBg.gameObject:SetActive(starCount > 0)
	local chapData = TableMgr:GetChapterData(battleData.chapterId)
	local levelMsg = ChapterListData.GetLevelData(battleId)
	chapterCount.trf.gameObject:SetActive(chapData.type == 5)
	chapterCount.label.text = System.String.Format(TextMgr:GetText("EliteChapter_ui2") , levelMsg == nil and battleData.EliteNum or levelMsg.leftcount , battleData.EliteNum) 

	sweepBg:Find("btn_sweep1").gameObject:SetActive(starCount == 3)
	sweepBg:Find("btn_sweep10").gameObject:SetActive(starCount == 3 and chapData.type ~= 5)
	sweepBg:Find("Text_star").gameObject:SetActive(starCount < 3)
	SetTextColor()

end

function SetSweepItem(itemObj , index , itemid , count)
	if gatherParam ~= nil and gatherParam.auto then
		itemObj:SetActive(true)
		local itemLabel = itemObj.transform:Find("text"):GetComponent("UILabel")
		local itemBase = TableMgr:GetItemData(gatherParam.itemid)
		local nameColor = Global.GetLabelColorNew(itemBase.quality)
		local itemName = nameColor[0] .. TextUtil.GetItemName(itemBase) .. nameColor[1]
		
		if itemid == gatherParam.itemid then
			gatherParam.gaterCount = gatherParam.gaterCount + count
		end
		
		if gatherParam.needGater > gatherParam.gaterCount then
			itemLabel.text = System.String.Format(TextMgr:GetText("sweep_ui5") , index , itemName.."X" .. gatherParam.gaterCount , 
							 System.String.Format(TextMgr:GetText("sweep_ui6") , gatherParam.needGater - gatherParam.gaterCount)
							 )
		else
			itemLabel.text = System.String.Format(TextMgr:GetText("sweep_ui5") , index , itemName.."X" .. gatherParam.gaterCount , 
							 TextMgr:GetText("sweep_ui7")
							 )
		end
	else
		itemObj:SetActive(false)
	end
end

function GetSweepRequest(sweep10, costdiamond)
	local battleData = TableMgr:GetBattleData(battleId)
	local chapData = TableMgr:GetChapterData(battleData.chapterId)
	local levelMsg = ChapterListData.GetLevelData(battleId)
	if levelMsg ~= nil and chapData.type == 5 and levelMsg.leftcount <= 0 then
		EliteBattleBuy(battleData , chapData , levelMsg)
		return
	end


    local req = BattleMsg_pb.MsgBattleSweepRequest();
    req.chapterlevel = battleId
    req.sweep10 = sweep10
    req.costdiamond = costdiamond
	
	if gatherParam ~= nil then
		local itemMsg = ItemListData.GetItemDataByBaseId(gatherParam.itemid)
		local haveCount = itemMsg ~= nil and itemMsg.number or 0
		if gatherParam.itemcount > haveCount then
			req.needItem.id = gatherParam.itemid
			req.needItem.num = gatherParam.itemcount - haveCount
			gatherParam.needGater = gatherParam.itemcount - haveCount
			gatherParam.gaterCount = 0
			gatherParam.auto = true
		else
			gatherParam.needGater = 0
			gatherParam.gaterCount = 0
			gatherParam.auto = false
		end
	end
	
    local lastlevel = MainData.GetLevel()
    local lastexp = MainData.GetExp()
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleSweepRequest, req, BattleMsg_pb.MsgBattleSweepResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            if msg.code == ReturnCode_pb.Code_EnergyNotEnough then
            	MainCityUI.CheckAndBuyEnergy(function()
					SetActive(true)
				end)
            end
        else
        	local mData = msg.fresh.maindata
        	Sweep.Show(msg.reward, msg.sweep, TableMgr:GetPlayerLvupExp(mData.level , mData.exp , lastlevel, lastexp), sweep10, msg.fresh)
        	SetActive(false)
            ChapterListData.UpdateChapterData(msg.chapter)
			LoadUI()
        end
    end)
end

function EliteBattleBuy(_battleData , _chapData , _lvMsg)
	local battleData = _battleData == nil and TableMgr:GetBattleData(battleId) or _battleData
	local chapData = _chapData == nil and TableMgr:GetChapterData(battleData.chapterId) or _chapData
	local levelMsg = _lvMsg == nil and ChapterListData.GetLevelData(battleId) or _lvMsg

	if levelMsg == nil or levelMsg.leftcount == battleData.EliteNum then
		FloatText.Show(TextMgr:GetText("EliteChapter_ui10") , Color.green)--("无需刷新")
		return
	end
	
	local buyStrCfg = string.split(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.EliteBattleFreshCost).value, ",")
	local costLevel = levelMsg.freshcount >= #(buyStrCfg) and #(buyStrCfg) or levelMsg.freshcount + 1
	local cost = tonumber(buyStrCfg[costLevel])
--[[	if MoneyListData.GetDiamond() < cost then
		local text1 = TextMgr:GetText(Text.tili_ui2)
		local text2 = TextMgr:GetText(Text.tili_ui4)
		local msgText = Global.GetErrorText(ReturnCode_pb.Code_LimitNumNotEnough) -- String.Format(text1, price, EachBuyEnergyAmount)..String.Format(text2, leftBuyCount)
		local okText = TextMgr:GetText(Text.common_ui10)
		MessageBox.Show(msgText, function() end, function() end, okText)
		--Global.ShowNoEnoughMoney()
	else ]]--
		
		MessageBox.Show(TextMgr:GetText("EliteChapter_ui3"), function()
			if levelMsg.freshcount >= levelMsg.maxfreshcount then
				FloatText.Show(TextMgr:GetText("EliteChapter_ui5"))--("已达到最大刷新次数")
				SetActive(true)
				return
			end
		
			local req = BattleMsg_pb.MsgFreshBattleCountRequest();
			req.chapterlevel = battleId
			print(battleId)
			Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgFreshBattleCountRequest, req, BattleMsg_pb.MsgFreshBattleCountResponse, function(msg)
			--Global.DumpMessage(req , "d:/MsgFreshBattleCountRequest.lua")
			--		Global.DumpMessage(msg , "d:/MsgFreshBattleCountRequest.lua")
				if msg.code ~= ReturnCode_pb.Code_OK then
					Global.ShowError(msg.code)
				else
					FloatText.Show(TextMgr:GetText("EliteChapter_ui9") , Color.green)
					MainCityUI.UpdateRewardData(msg.fresh)
					ChapterListData.UpdateChapterData(msg.chapter)
					LoadUI()
					SetActive(true)
				end
			end)
		end,
		function()
			SetActive(true)
		end,
		nil--"刷新次数"
		,nil,nil,nil,nil,System.String.Format(TextMgr:GetText("tili_ui4"),levelMsg.maxfreshcount - levelMsg.freshcount ),cost
		)
--	end
	
	
end

function Awake()
	uiMask = transform:Find("Container/mask")
	labelTitle = transform:Find("Container/Container/bg_frane/bg_top/title_chapter"):GetComponent("UILabel")
	labelDescription = transform:Find("Container/Container/bg_frane/Text_miaosu"):GetComponent("UILabel")
	labelEnergyCost = transform:Find("Container/Container/bg_sweep/bg_tili/num_tili"):GetComponent("UILabel")
	chapterPower = transform:Find("Container/Container/bg_power_enemy/icon_power/Text_item"):GetComponent("UILabel")
	chapterCount = {}
	chapterCount.trf = transform:Find("Container/Container/bg_sweep/bg_cishu")
	chapterCount.label = transform:Find("Container/Container/bg_sweep/bg_cishu/text"):GetComponent("UILabel")
	chapterCount.buyBtn = transform:Find("Container/Container/bg_sweep/bg_cishu/btn_buy")
	SetClickCallback(chapterCount.buyBtn.gameObject , function()
		EliteBattleBuy()
	end)
	
	starList = {}
	for i = 1, 3 do
		starList[i] = {}
		starList[i].light = transform:Find(string.format("Container/Container/bg_frane/bg_star/icon_star%d", i))
		starList[i].dark = transform:Find(string.format("Container/Container/bg_frane/bg_star/icon_star%d_hui", i))
	end
	labelMission = transform:Find("Container/Container/bg_mission/bg_mission/Text_mission"):GetComponent("UILabel")
	btnMissionTip = transform:Find("Container/Container/bg_mission/bg_mission/btn_info"):GetComponent("UIButton")
	btnBack = transform:Find("Container/btn_close"):GetComponent("UIButton")
	btnAttack = transform:Find("Container/Container/btn_attack"):GetComponent("UIButton")
	
	enemyList = {}
	for i = 1, 5 do
		local enemy = Enemy()
		enemy.btn = transform:Find(string.format("Container/Container/bg_enemy/bg_enemy/btn_enemy (%d)", i)):GetComponent("UIButton")
		enemy.icon = transform:Find(string.format("Container/Container/bg_enemy/bg_enemy/btn_enemy (%d)/enemy", i)):GetComponent("UITexture")
		enemy.newIcon = transform:Find(string.format("Container/Container/bg_enemy/bg_enemy/btn_enemy (%d)/new", i)):GetComponent("UISprite")
		enemyList[i] = enemy
	end

    rewardTitle = transform:Find("Container/Container/bg_item/title_item/Text_item"):GetComponent("UILabel")
	rewardList = {}
	for i = 1, 5 do
		local reward = {}
		local item = {}
		local itemTransform = transform:Find(string.format("Container/Container/bg_item/bg_item/Item_CommonNew (%d)", i))
		UIUtil.LoadItemObject(item, itemTransform)

        local heroTransform = transform:Find(string.format("Container/Container/bg_item/bg_item/hero (%d)", i))
		local hero = {}
		HeroList.LoadHeroObject(hero, heroTransform)

		reward.item = item
		reward.hero = hero
		rewardList[i] = reward
	end

	missionTip = {}
	missionTip.bg = transform:Find("Container/Container/bg_mission_msg")
	missionTip.list = {}
	for i = 1, 3 do
		missionTip.list[i] = {}
		missionTip.list[i].lightStar = transform:Find(string.format("Container/Container/bg_mission_msg/bg_mission_msg (%d)/small_star", i))
		missionTip.list[i].darkStar = transform:Find(string.format("Container/Container/bg_mission_msg/bg_mission_msg (%d)/small_star_hui", i))
		missionTip.list[i].description = transform:Find(string.format("Container/Container/bg_mission_msg/bg_mission_msg (%d)/Label", i)):GetComponent("UILabel")
	end

    sweepBg = transform:Find("Container/Container/bg_sweep")
    local btnSweepOne = transform:Find("Container/Container/bg_sweep/btn_sweep1"):GetComponent("UIButton")
    local btnSweepTen = transform:Find("Container/Container/bg_sweep/btn_sweep10")
    SetClickCallback(btnSweepOne.gameObject, function() GetSweepRequest(false, false) end)
    SetClickCallback(btnSweepTen.gameObject, function() GetSweepRequest(true, false) end)
	SetClickCallback(btnBack.gameObject, Hide)
	SetClickCallback(btnAttack.gameObject, AttackClickCallback)
	SetClickCallback(transform:Find("Container").gameObject, Hide)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	MainData.AddListener(SetTextColor)
	
	tweenGroupChapter = transform:Find("Container/Container"):GetComponents(typeof(UIPlayTween))
	
end

function ShowModel(mod)
	if GUIMgr:FindMenu("ChapterSelectUI") ~= nil then
		ChapterSelectUI.ShowControledMenu(false)
		tweenGroupChapter[1]:Play(true)
		uiMask.gameObject:SetActive(false)
	else
		tweenGroupChapter[0]:Play(true)
		uiMask.gameObject:SetActive(true)
	end

end


function Start()
	missionTip.bg.gameObject:SetActive(true)
	Tooltip.HideItemTip()
	itemTipTarget = nil
end

function Close()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	MainData.RemoveListener(SetTextColor)
	labelEnergyCost = nil
	labelTitle = nil
	labelDescription = nil
	chapterPower = nil
	btnMissionTip = nil
	btnBack = nil
	rewardTitle = nil
	labelMission = nil
	btnAttack = nil
	tweenGroupChapter = nil
	chapterCount = nil
end

function Show(id)
	if id ~= nil then
    	battleId = id
    end
    Global.OpenUI(_M)
	LoadUI()
	ShowModel()
end

function CheckShow(battleId , param)
    if battleId == 90014 or battleId == 90015 then
        Show(battleId)
        return nil
    end

    local battleData = TableMgr:GetBattleData(battleId)
    local baseLevel = maincity.GetBuildingByID(1).data.level
    if baseLevel < battleData.requiredBaseLevel then
        local lockText = TextMgr:GetText(Text.chat_hint2)
        return System.String.Format(lockText, battleData.requiredBaseLevel)
    else
        local playerLevel = MainData.GetLevel()
        local lockText = TextMgr:GetText(Text.battle_ui1)
        if playerLevel < battleData.requiredLevel then
            return System.String.Format(lockText, battleData.requiredLevel)
        end
    end

    if not FunctionListData.IsUnlocked(135) then
        return TextMgr:GetText(TableMgr:GetFunctionUnlockText(135))
    end

    local canExplore, reasonText = ChapterListData.CheckExplore(battleId)
    if canExplore then
        gatherParam = param
        Show(battleId)
        return nil
    else
        return reasonText
    end
end

function GetBattleId()
    return battleId
end
