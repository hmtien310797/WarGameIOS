class "LuaTableMgr"
{
}

function LuaTableMgr:__init__()
	
end

function LuaTableMgr:GetChapterData(id)
	return tableData_tChapters.data[tonumber(id)]
end

function LuaTableMgr:GetChapterTable()
	return tableData_tChapters.data
end

function LuaTableMgr:GetGlobalData(id)--tableData_tGlobal 
	return tableData_tGlobal.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetTimeToShowRecommendedAlliance()
	for s in string.gsplit(tableData_tGlobal.data[113].value, ";") do
		return tonumber(s)
	end
end

function LuaTableMgr:GetMobaTeamData(id)--tableData_tMobaTeam 

	return tableData_tMobaTeam.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetChapterData(id)--tableData_tChapters 

	return tableData_tChapters.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetChapterTable()--tableData_tChapters 

	return tableData_tChapters.data----------------table
end

function LuaTableMgr:GetBattleData(id)--tableData_tBattles

	return tableData_tBattles.data[tonumber(id)]----------------id
end


function LuaTableMgr:GetFormation(id)--tableData_tBattles

	local fd = tableData_tFormation.data[tonumber(id)]
	if fd == nil then
		return nil
	end
	local f = {}
	f[1] = fd.pos1
	f[2] = fd.pos2
	f[3] = fd.pos3
	f[4] = fd.pos4
	f[5] = fd.pos5
	f[6] = fd.pos6
	return f
end

function LuaTableMgr:GetTeamSlotTable()--tableData_tTeamSlot 

	return tableData_tTeamSlot.data----------------table
end

function LuaTableMgr:GetStarConditionData(id)--tableData_tStarCondition 

	return tableData_tStarCondition.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetGroupData(id)--tableData_tGroupInfo 

	return tableData_tGroupInfo.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnitData(id)--tableData_tUnitInfo 

	return tableData_tUnitInfo.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetWeaponData(id)--tableData_tWeapons 

	return tableData_tWeapons.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetGodSkillData(id)--tableData_tGodSkill 

	return tableData_tGodSkill.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetAttributeExchangeData(attributeID) -- tableData_tAttributeExchange
	return tableData_tAttributeExchange.data[attributeID]
end

function LuaTableMgr:GetDropData(id)--tableData_tDrop 

	return tableData_tDrop.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetDropTable()--tableData_tDrop 

	return tableData_tDrop.data----------------table
end

function LuaTableMgr:GetItemData(id)--tableData_tItem 
	return tableData_tItem.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetItemConvertData(id) -- tableData_tItemConvert
	local data = tableData_tItemConvert.data[id]

	if not data then
		print(string.format("[Item/Convert] 找不到表数据   id = %d", id))
	end

	return data
end

function LuaTableMgr:GetBuildingData(id)--tableData_tBuilding 
	return tableData_tBuilding.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnitDefenseData(id)--tableData_tDefense 
	return tableData_tDefense.data[tonumber(id)];
end

function LuaTableMgr:GetBuildUpdateDataById(id)--tableData_tBuildingUpdate 
	return tableData_tBuildingUpdate.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetNationalityData(id)
	return id and tableData_tNationalityDefine.data[tonumber(id)] or tableData_tNationalityDefine.data
end

function LuaTableMgr:GetLandListData(id)--tableData_tLandList 

	return tableData_tLandList.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetBuildCoreData(id)--tableData_tCore 

	return tableData_tCore.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetGuideInfoData(id)--tableData_tGuide 

	return tableData_tGuide.data[tonumber(id)]----------------id
end
function LuaTableMgr:GetBuildResourceData(id)--tableData_tBuildingRes 

	return tableData_tBuildingRes.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetGmTable()--tableData_tGm 

	return tableData_tGm.data----------------table
end

function LuaTableMgr:GetBarrackTable()--tableData_tSoldier 

	return tableData_tSoldier.data----------------table
end

function LuaTableMgr:GetBuffShowList()--tableData_tBufflist 

	return tableData_tBufflist.data----------------table
end

function LuaTableMgr:GetUnionLogData(id)--tableData_tUnionLog 

	return tableData_tUnionLog.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetStaminaPriceData(id)--tableData_tStaminaPrice 

	return tableData_tStaminaPrice.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetWareDataTable()--tableData_tWareData 

	return tableData_tWareData.data----------------table
end

function LuaTableMgr:GetWareData(level)--tableData_tWareData 
	return tableData_tWareData.data[tonumber(level)]----------------id
end

function LuaTableMgr:GetWallDataTable()--tableData_tWallData 

	return tableData_tWallData.data----------------table
end

function LuaTableMgr:GetWallData(level)--tableData_tWallData 
	return tableData_tWallData.data[tonumber(level)]----------------id
end

function LuaTableMgr:GetCallUpTable()--tableData_tCallUp 

	return tableData_tCallUp.data----------------table
end

function LuaTableMgr:GetJailTable()--tableData_tJail
	return tableData_tJail.data----------------table
end

function LuaTableMgr:GetJailDataByLevel(level)
    for k, v in pairs(tableData_tJail.data) do
        if v.buildlevel == level then
            return v
        end
    end
end

function LuaTableMgr:GetJailInfoDataByLevel(level)
    for k, v in ipairs(tableData_tJailInfo.data) do
        if level >= v.playerlvllower and level <=  v.playerlvlupper then
            return v
        end
    end
end

function LuaTableMgr:GetChristmasRankConfigData()

	return tableData_tChristmasActivityRank.data;
end

function LuaTableMgr:GetChristmasRankConfigDataByID(id)

	return tableData_tChristmasActivityRank.data[id];
end

function LuaTableMgr:GetCallUpData(level)--tableData_tCallUp 
	return tableData_tCallUp.data[tonumber(level)]----------------id
end

function LuaTableMgr:GetClinicTable()--tableData_tClinicData 

	return tableData_tClinicData.data----------------table
end
function LuaTableMgr:GetClinicData(level)--tableData_tClinicData 
	return tableData_tClinicData.data[tonumber(level)]----------------id
end

function LuaTableMgr:GetParadeGroundData(level)--tableData_tParadeGround 
	return tableData_tParadeGround.data[tonumber(level)]----------------id
end
function LuaTableMgr:GetParadeGroundTable()--tableData_tParadeGround 
	return tableData_tParadeGround.data----------------table
end

function LuaTableMgr:GetRadarTable()--tableData_tRadar 

	return tableData_tRadar.data----------------table
end

function LuaTableMgr:GetGoldStoreTabConfig(id)
	if id then
		return tableData_tGoldStoreTabConfig.data[id]
	end

	return tableData_tGoldStoreTabConfig.data
end

function LuaTableMgr:GetGiftpackTabConfig(id)
	if id then
		return tableData_tGiftpackTabConfig.data[id]
	end

	return tableData_tGiftpackTabConfig.data
end

function LuaTableMgr:GetGiftpackPopupConfig(id)
	if id then
		return tableData_tGiftpackPopupConfig.data[id]
	end
end

function LuaTableMgr:GetSpeedUppriceTable()--tableData_tSpeedupprice 

	return tableData_tSpeedupprice.data----------------table
end

function LuaTableMgr:GetStaminaPriceTable()--tableData_tStaminaPrice 

	return tableData_tStaminaPrice.data----------------table
end

function LuaTableMgr:GetBarrackBuildDataTable()--tableData_tBarrack 

	return tableData_tBarrack.data----------------table
end
function LuaTableMgr:GetPlayerExpData(id)--tableData_tPlayerExp 

	return tableData_tPlayerExp.data[tonumber(id)]----------------id
end

local NUM_GENERAL_BASIC_ATTRIBUTES
function LuaTableMgr:GetNumGeneralBasicAttributes()
	if not NUM_GENERAL_BASIC_ATTRIBUTES then
		local data = table.first(tableData_tHero.data)

		local count = 0
		while data["additionArmy" .. (count + 1)] do
			count = count + 1
		end

		NUM_GENERAL_BASIC_ATTRIBUTES = count

		return count
	end

	return NUM_GENERAL_BASIC_ATTRIBUTES
end

function LuaTableMgr:GetMilitaryRankTable()--tableData_tMilitaryRank

	return tableData_tMilitaryRank.data----------------table
end

function LuaTableMgr:GetGuildMobaRankRewardTable()

	return tableData_tGuildMobaRankReward.data
end

function LuaTableMgr:GetGuildRewardTable()

	return tableData_tGuildReward.data
end


function LuaTableMgr:GetMobaShopItemTable()

	return tableData_tMobaShop.data
end

function LuaTableMgr:GetMobaShopHeroTable()

	return tableData_tMobaHero.data
end

function LuaTableMgr:GetMobaRoleTable()

	return tableData_tMobaRole.data
end

function LuaTableMgr:GetMobaRoleTablebyID(id)

	return tableData_tMobaRole.data[tonumber(id)]
end

function LuaTableMgr:GetMobaShopItemByBaseID(id)
	for k, it in pairs(TableMgr:GetMobaShopHeroTable()) do
		if it.ItemID ==id then 
			return it
		end 
	end 
	return nil
end


function LuaTableMgr:GetMobaShopTechTable()

	return tableData_tMobaTech.data
end

function LuaTableMgr:GetMobaUnitInfoTable()

	return tableData_tMobaUnitInfo.data
end

function LuaTableMgr:GetMilitaryRankData(lv,grade)--tableData_tMilitaryRank

	for _, rankData in pairs(tableData_tMilitaryRank.data) do
	
		if tonumber(rankData.RankLevel) == tonumber(lv) and tonumber(rankData.RankGrade) == tonumber(grade) then
			return rankData
		end 
	end 
	
	return nil
end



function LuaTableMgr:GetRankConditionTable()--tableData_tRankCondition

	return tableData_tRankCondition.data----------------table
end

function LuaTableMgr:GetRankConditionData(id)--tableData_tHero 

	return tableData_tRankCondition.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetMilitaryRuleTable()--tableData_tMilitaryRule

	return tableData_tMilitaryRule.data----------------table
end

function LuaTableMgr:GetHeroData(id)--tableData_tHero 

	return tableData_tHero.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetMobaHeroData(id)--tableData_tMobaHero 

	return tableData_tMobaHero.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetHeroTable()--tableData_tHero 

	return tableData_tHero.data----------------table
end

function LuaTableMgr:GetHeroExpData(id)--tableData_tHeroExp 

	return tableData_tHeroExp.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetHeroStarUpData(id)--tableData_tHeroStarUp 

	return tableData_tHeroStarUp.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetHeroGradeUpData(id)--tableData_tHeroGradeUp 

	return tableData_tHeroGradeUp.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetBadgeData(id)--tableData_tBadge 

	return tableData_tBadge.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetRulesData(id)--tableData_tRules 

	return tableData_tRules.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetNeedTextData(id)--tableData_tNeedText
	return tableData_tNeedText.data[tonumber(id)]
end

function LuaTableMgr:GetFightData(id)--tableData_tFight 
	return tableData_tFight.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetResourcePriceData()--tableData_tResourcePrise 

	return tableData_tResourcePrise.data----------------table
end

function LuaTableMgr:GetTechDetailTable()--tableData_tTechDetail 

	return tableData_tTechDetail.data----------------table
end

function LuaTableMgr:GetTechCategoryTable()--tableData_tTechCategory 

	return tableData_tTechCategory.data----------------table
end

function LuaTableMgr:GetBuildLaboratoryTable()--tableData_tLaboratory 

	return tableData_tLaboratory.data----------------table
end

function LuaTableMgr:GetSlgBuffData(id)--tableData_tSlgBuff 
	return tableData_tSlgBuff.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetSlgBuffTable()--tableData_tSlgBuff 

	return tableData_tSlgBuff.data----------------table
end

function LuaTableMgr:GetItemExchangeData(id)--tableData_tExItem 

	return tableData_tExItem.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetItemExchangeDataByItemID(id)--tableData_tExItem 
	for i, v in pairs(tableData_tExItem.data) do
		if v.item == id then
			return v
		end
	end
	return nil
end

function LuaTableMgr:GetUnionMonsterData(id)--tableData_tUnionMonster 

	return tableData_tUnionMonster.data[tonumber(id)]----------------id
end


function LuaTableMgr:GetUnionMonsterTable()--tableData_tUnionMonster 

	return tableData_tUnionMonster.data----------------table
end
function LuaTableMgr:GetPveMonsterData(id)--tableData_tPVEMonster 

	return tableData_tPVEMonster.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetItemExchangeListData(id)--tableData_tExList 

	return tableData_tExList.data[tonumber(id)]----------------id
end


function LuaTableMgr:GetBonusFunction(id)--tableData_tBounsfunction LuaTableMgr:

	return tableData_tBounsFunction.data[tonumber(id)]----------------id
end


function LuaTableMgr:GetSettingTable()--tableData_tSetting 

	return tableData_tSetting.data----------------table
end

function LuaTableMgr:GetMissionData(id)--tableData_tMission 

	return tableData_tMission.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetMilitarytActionData(id)--tableData_tMilitary 

	return tableData_tMilitary.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetTutorialData(id)--tableData_tTutorial 

	return tableData_tTutorial.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetResourceRuleData(id)--tableData_tResourceRule 

	return tableData_tResourceRule.data[tonumber(id)]----------------id
end
function LuaTableMgr:GetMonsterRuleData(id)--tableData_tMonsterRule 

	return tableData_tMonsterRule.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetActiveConditionData(id) --tableData_tActivityCondition 

	return tableData_tActivityCondition.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetActivityData() --tableData_tActivityCondition
	return tableData_tActivityCondition.data
end

function LuaTableMgr:GetWelfareConfigs() --tableData_tActivityCondition
	local count = 0
	local sortedConfigs = {}

	for id, config in pairs(tableData_tActivityCondition.data) do
		local templeteId = config.Templet
		if templeteId >= 300 and templeteId < 400 then
			table.insert(sortedConfigs, config)
			count = count + 1
		end
	end

	table.sort(sortedConfigs, function(config1, config2)
		return config1.order > config2.order
	end)

    local now = Serclimax.GameTime.GetSecTime()

	local configs = {}
	for tab, config in ipairs(sortedConfigs) do
		config.endTime = now + 60 * 60
		config.isAvailable = true
		config.tab = tab
		configs[config.id] = config
	end

	return configs, count
end

function LuaTableMgr:GetBattleFieldActivities() --tableData_tActivityCondition
	local count = 0
	local sortedConfigs = {}

	for id, config in pairs(tableData_tActivityCondition.data) do
		local templeteId = config.Templet
		if templeteId >= 200 and templeteId < 300 then
			local isUnlocked = true
			if id == 2001 then
                FunctionListData.IsFunctionUnlocked(116, function(isactive)
					isUnlocked = isactive
                end)
            elseif id == 2002 then
                FunctionListData.IsFunctionUnlocked(111, function(isactive)
                	isUnlocked = isactive
                end)
            elseif id == 103 then
                FunctionListData.IsFunctionUnlocked(110, function(isactive)
                	isUnlocked = isactive
                end)
            end

            local _config = config
            _config.isUnlocked = isUnlocked

            if isUnlocked then
				table.insert(sortedConfigs, config)
				count = count + 1
			end
		end
	end

	table.sort(sortedConfigs, function(config1, config2)
		return config1.order > config2.order
	end)

	local now = Serclimax.GameTime.GetSecTime()

	local configs = {}

	for tab, config in ipairs(sortedConfigs) do
		config.endTime = now + 60 * 60
		config.isAvailable = true
		config.tab = tab
		configs[config.id] = config
	end

	return configs, count
end

function LuaTableMgr:GetMailCfgData(id)--tableData_tMailCfg 

	return tableData_tMailCfg.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetArtSettingData(id)--tableData_tArtSetting 

	return tableData_tArtSetting.data[tonumber(id)]----------------id
end


function LuaTableMgr:GetObjectShapeData(id)--tableData_tObjectSharp 

	return tableData_tObjectSharp.data[tonumber(id)]----------------id
end


function LuaTableMgr:GetSoldierShowRule(id)--tableData_tShowRule 

	return tableData_tShowRule.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnionBadgeColorData(id)--tableData_tUnionBadgeColor 

	return tableData_tUnionBadgeColor.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnionBadgeBorderData(id)--tableData_tUnionBadgeBorder 

	return tableData_tUnionBadgeBorder.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnionItemData(id)--tableData_tGiftItem 

	return tableData_tGiftItem.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnionBuildingData(id)--tableData_tUnionBuilding 

	return tableData_tUnionBuilding.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnionBadgeTotemData(id)--tableData_tUnionBadgeTotem 

	return tableData_tUnionBadgeTotem.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnionLanguageData(id)--tableData_tUnionLanguage 

	return tableData_tUnionLanguage.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetUnionGiftExpData(id)--tableData_tGiftExp 

	return tableData_tGiftExp.data[tonumber(id)]-------------id;
end


function LuaTableMgr:GetTradingPostTable()--tableData_tTradingPost 

	return tableData_tTradingPost.data----------------table
end

function LuaTableMgr:GetEmbassyTable()--tableData_tEmbassy 

	return tableData_tEmbassy.data----------------table
end

function LuaTableMgr:GetAssembledTable()--tableData_tAssembled 

	return tableData_tAssembled.data----------------table
end

function LuaTableMgr:GetActMonsterData(id)--tableData_tActMonster 

	return tableData_tActMonster.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetActMonsterRuleData(id)--tableData_tActMonsterRule 

	return tableData_tActMonsterRule.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetTalentTable()--tableData_tTalentDetail 

	return tableData_tTalentDetail.data----------------table
end

function LuaTableMgr:GetTalentCategoryTable()--tableData_tTalentCategory 

	return tableData_tTalentCategory.data----------------table
end

function LuaTableMgr:GetUnionTechDetailTable()--tableData_tUnionTech 

	return tableData_tUnionTech.data----------------table
end
function LuaTableMgr:GetActiveStaticsRule()--tableData_tStatisticsRule 

	return tableData_tStatisticsRule.data----------------table
end
function LuaTableMgr:GetActiveStaticsRuleData(id)--tableData_tStatisticsRule 

	return tableData_tStatisticsRule.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetActiveStaticsList()--tableData_tStatisticsList 

	return tableData_tStatisticsList.data----------------table
end
function LuaTableMgr:GetActivityStaticsListData(id)--tableData_tStatisticsList 

	return tableData_tStatisticsList.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetActivityStaticsRewardDataById(id)--tableData_tStatisticsReward 

	return tableData_tStatisticsReward.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetEquipTable()--tableData_tEquip 

	return tableData_tEquip.data----------------table
end

function LuaTableMgr:GetMaterialTable()--tableData_tMaterial 

	return tableData_tMaterial.data----------------table
end

function LuaTableMgr:GetArmouryData()--tableData_tArmoury 
	return tableData_tArmoury.data----------------table
end

function LuaTableMgr:GetPassiveSkillData(id)--tableData_tPassiveSkill
	local data = tableData_tPassiveSkill.data[tonumber(id)]

	if not data then
		print(string.format("[Hero/PassiveSkill]找不到表数据   id = %d", id))
	end

	return data
end

function LuaTableMgr:GetMapBuildingDataByID(id)--tableData_tMapBuilding 

	return tableData_tMapBuilding.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetMobaUnitInfoByID(id)--tableData_tMapBuilding 

	return tableData_tMobaUnitInfo.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetMobaMapBuildingDataByID(id)--tableData_tMapBuilding 
	if Global.GetMobaMode() == 1 then
		return tableData_tMobaBuildingRule.data[tonumber(id)]----------------id
	elseif Global.GetMobaMode() == 2 then
		return tableData_tGuildMobaBuilding.data[tonumber(id)]
	end
end

function LuaTableMgr:GetGuildWarMapBuildingDataByID(id)--tableData_tMapBuilding 
	return tableData_tGuildMobaBuilding.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetWorldCityDataByID(id)--tableData_tMapBuilding 
	return tableData_tWorldCity.data[tonumber(id)]----------------id
end


function LuaTableMgr:GetGuildWarShopDataByID(id)--tableData_tMapBuilding 
	
	for i, v in pairs(tableData_tGuildMobaShop.data) do
		if v.ItemID == id then
			return v
		end
	end
	return nil
end

function LuaTableMgr:GetStrongholdRuleByID(id)--tableData_tMapBuilding 
	return tableData_tStrongholdRule.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetFortressRuleByID(id)--tableData_tMapBuilding 
	return tableData_tFortressRule.data[tonumber(id)]----------------id
end

function LuaTableMgr:GetFortRuleData(id)
	return tableData_tFortRule.data[tonumber(id)]
end


function LuaTableMgr:GetCommandData(id)
	return tableData_tCommander.data[tonumber(id)]
end

function LuaTableMgr:GetCommandDataCount(id)
	return tableData_tCommander.Count
end

function LuaTableMgr:GetFortRuleTable()
	return tableData_tFortRule.data
end

function LuaTableMgr:GetHeroSuggestionRule(id) -- tableData_tHeroRecommendation
	if id == 0 then
		return { id = 0, sortingConfig = "2:100", }
	end

	local rule = tableData_tHeroRecommendation.data[tonumber(id)]

	print(string.format("[LuaTableMgr][GetHeroSuggestionRule] %s id: %d", rule and "Existed" or "Non-existed", id))

	return rule
end

function LuaTableMgr:GetHeroSuggestionRuleID(teamMoveType, sEntryData)
    if sEntryData == nil or sEntryData.data.entryType == 0 then
        return 0
    elseif teamMoveType == Common_pb.TeamMoveType_ResTake and sEntryData.res.owner ~= 0 and sEntryData.res.owner ~= MainData.GetCharId() and (UnionInfoData.GetGuildId() == 0 or sEntryData.ownerguild.guildid ~= UnionInfoData.GetGuildId()) then -- 攻击别人正在采集的资源田
        return teamMoveType * 100 + 10 + sEntryData.data.entryType
    elseif teamMoveType == Common_pb.TeamMoveType_MineTake then -- 采集联盟矿
        return teamMoveType * 100 + self:GetUnionBuildingData(sEntryData.guildbuild.baseid).resourceType
    end

    return teamMoveType * 100 + sEntryData.data.entryType
end

function LuaTableMgr:GetExpediationSuggestionRule(teamMoveType, sEntryData)
	return self:GetHeroSuggestionRule(self:GetHeroSuggestionRuleID(teamMoveType, sEntryData))
end

function LuaTableMgr:GetMobaHeroSuggestionRuleID(teamMoveType, sEntryData)
    --[[
    if sEntryData == nil or sEntryData.data.entryType == 0 then
        return 0
    elseif teamMoveType == Common_pb.TeamMoveType_ResTake and sEntryData.res.owner ~= 0 and sEntryData.res.owner ~= MainData.GetCharId() and (UnionInfoData.GetGuildId() == 0 or sEntryData.ownerguild.guildid ~= UnionInfoData.GetGuildId()) then -- 攻击别人正在采集的资源田
        return teamMoveType * 100 + 10 + sEntryData.data.entryType
    elseif teamMoveType == Common_pb.TeamMoveType_MineTake then -- 采集联盟矿
        return teamMoveType * 100 + self:GetUnionBuildingData(sEntryData.guildbuild.baseid).resourceType
    end

    return teamMoveType * 100 + sEntryData.data.entryType
    --]]
    return 9999
end

function LuaTableMgr:GetMobaExpediationSuggestionRule(teamMoveType, sEntryData)
	return self:GetHeroSuggestionRule(self:GetHeroSuggestionRuleID(teamMoveType, sEntryData))
end

local rankRewardTableCache1 = {}

function LuaTableMgr:GetActivitySiegeMonsterRankRewardByType(type)--tableData_tSiegeMonsterRankReward 
	local reward = rankRewardTableCache1[type]
	if reward == nil then
	    reward = {}
        for _ , v in kpairs(tableData_tSiegeMonsterRankReward.data) do
            if v.rewardType == type then
                table.insert(reward , v)
            end
        end

        rankRewardTableCache1[type] = reward
    end

	return reward
end

local godSkillTableCache1 = {}
function LuaTableMgr:GetGodSkillDataByIdLevel(skillId, level)--tableData_tGodSkill
    if level >= 100 then
        error("level must < 100")
    end
    local cacheId = skillId * 100 + level
	local skData = godSkillTableCache1[cacheId]
    if skData == nil then
        for _ , v in pairs(tableData_tGodSkill.data) do
            if v.skillId == skillId and v.level == level then
                skData = v
                godSkillTableCache1[cacheId] = skData
                break
            end
        end
    end

	return skData
end


function LuaTableMgr:GetGeneralPvpSkillData(heroInfo)
	local skillInfo = heroInfo.skill.pvpSkill

	local data = self:GetPvpSkillDataByIdLevel(skillInfo.id, skillInfo.level)

	if not data then
		print(string.format("[Skill/SLGSkill]找不到表数据   heroID = %d   SLGskillId = %d   level = %d", heroInfo.baseid, skillInfo.id, skillInfo.level))
	end

	return data
end

function LuaTableMgr:GetPvpSkillDataByIdLevel(skillID, level) -- tableData_tSLGSkill
	return tableData_tSLGSkill.data[skillID * 100 + level]
end

function LuaTableMgr:GetPvpSkillDataByIdLevelEx(skillID, level) -- tableData_tSLGSkill
	return tableData_tSLGSkill.data[skillID]
end

function LuaTableMgr:GetAllBuildingData()--tableData_tBuilding
	return tableData_tBuilding.data
end

local dropShowTableCache1 = {}
function LuaTableMgr:GetDropShowData(id)--tableData_tDropShow 
	local showData = dropShowTableCache1[id]
    if showData == nil then
        showData = {}
        for _ ,v  in kpairs(tableData_tDropShow.data) do
            if v.dropShowId == id then
                table.insert(showData , v)
            end
        end

        dropShowTableCache1[id] = showData
    end
	
	return showData
end

local itemTableCache1 = {}
function LuaTableMgr:GetItemDataByType(iType, iSubType)--tableData_tItem 
    if iSubType >= 1000 then
        error("iSubType must < 1000")
    end
    local cacheId = iType * 1000 + iSubType

	local items = itemTableCache1[cacheId]
	if items == nil then
	    items = {}
        for _ ,v in pairs(tableData_tItem.data) do
            if v.type == iType and v.subtype == iSubType then
                table.insert(items , v)
            end
        end

        itemTableCache1[cacheId] = items
    end
	return items
end

local itemTableCache2 = {}
function LuaTableMgr:GetItemDataListByTypeQuality(type, quality)
    if type >= 1000 then
        error("type must < 1000")
    end

    local cacheId = type * 1000 + quality

    local dataList = itemTableCache2[cacheId]
    if dataList == nil then
        dataList = {}
        for _, v in pairs(tableData_tItem.data) do
            if v.type == type and v.quality == quality then
                table.insert(dataList, v)
            end
        end
        itemTableCache2[cacheId] = dataList
    end

    return dataList
end

local buildUpdateTableCache1 = {}
function LuaTableMgr:GetBuildUpdateData( buildId,  buildLevel)--tableData_tBuildingUpdate 
    if buildLevel >= 100 then
        error("buildLevel must < 100")
    end
    local cacheId = buildId * 100 + buildLevel
    local data = buildUpdateTableCache1[cacheId]
    if data == nil then
        for _ ,v in pairs(tableData_tBuildingUpdate.data) do
            if v.buildId == buildId and v.buildLevel == buildLevel then
                data = v
                buildUpdateTableCache1[cacheId] = data
                break
            end
        end
    end

	return data
end

local buildCoreTableCache1 = {}
function LuaTableMgr:GetBuildCoreDataByLevel(level)--tableData_tCore 
	local coreData = buildCoreTableCache1[level]
    if coreData == nil then
        for _ ,v in pairs(tableData_tCore.data) do
            if v.buildLevel == level then
                coreData = v
                buildCoreTableCache1[level] = coreData
                break
            end
        end
    end

	return coreData
end

function LuaTableMgr:GetAllBuildCoreData()--tableData_tCore 
	return tableData_tCore.data;
end

function LuaTableMgr:GetBuildReviewData()--tableData_tBuildingReview 
	return tableData_tBuildingReview.data
end

local buildResourceTableCache1 = {}
function LuaTableMgr:GetBuildingResourceInfo(id)--tableData_tBuildingRes 
	local budatas = {}
	for _ ,v in pairs(tableData_tBuildingRes.data) do
		if v.resource_BId == tonumber(id) then
			table.insert(budatas , v)
		end
	end
	
	table.sort(budatas , function(a ,b)
		return a.resource_BLevel < b.resource_BLevel
	end)
	return budatas
end

local buildResourceTableCache2 = {}
function LuaTableMgr:GetBuildingResourceData(id, level)--tableData_tBuildingRes 
    if level >= 100 then
        error("level must < 100")
    end

    local cacheId = id * 100 + level
	local data = buildResourceTableCache2[cacheId]
    if data == nil then
        for _ , v in pairs(tableData_tBuildingRes.data) do
            if v.resource_BId == id and v.resource_BLevel == level then
                data = v
                buildResourceTableCache2 = data
                break
            end
        end
    end
	return data
	
end

function LuaTableMgr:GetBuildingResourceYield(id, level) 
	local _yield = 0
	local data = self:GetBuildingResourceData(id, level)
	if data ~= nil then
	    _yield = data.resource_BYield
    end
	return _yield
end

local barrackTableCache1 = {}
function LuaTableMgr:GetBarrackData(soldier, grade)--tableData_tSoldier 
    if grade >= 100 then
        error("grade must < 100")
    end

    local cacheId = soldier * 100 + grade
	local data = barrackTableCache1[cacheId]
    if data == nil then
        for _ , v in pairs(tableData_tSoldier.data) do
            if v.SoldierId == soldier and v.Grade == grade then
                data = v
                barrackTableCache1[cacheId] = data
                break
            end
        end
    end
	return data
end

function LuaTableMgr:GetBarrackDataByUnitId(unitId)--tableData_tSoldier 
	local data = nil
	for _ , v in pairs(tableData_tSoldier.data) do
		if v.UnitID == unitId then
			data = v
			break
		end
	end
	return data
end

function LuaTableMgr:GetBarrackRestrainInfo(barrackId)
	local data = nil
	for _ , v in pairs(tableData_tSoldier.data) do
		if v.BarrackId == barrackId and v.armyType == 1 then
			data = v
			break
		end
	end
	return data
end

function LuaTableMgr:GetRadarData(level)--tableData_tRadar 
	local data = nil
	for _ , v in pairs(tableData_tRadar.data) do
		if v.buildLevel == level then
			data = v
			break
		end
	end
	return data
end

function LuaTableMgr:GetPlayerExp(level)--tableData_tPlayerExp 
	local data = nil
	for _ , v in pairs(tableData_tPlayerExp.data) do
		if v.id == level then
			data = v
			break
		end
	end
	return data
end

function LuaTableMgr:GetPlayerLvupExp(newlv, newexp, oldlv, oldexp) 

	if oldlv < 1 or newlv < oldlv then
		return 0
	end
	
	if oldlv == newlv then
		return newexp - oldexp
	end
	
	local result = 0
	for i=oldlv , newlv - 1 , 1 do
		local data = self:GetPlayerExp(i)
		result = result + data.playerExp
	end
	return result + newexp - oldexp
end

local heroTableCache1 = {}
function LuaTableMgr:GetHeroStarUpDataByHeroIdStarGrade(heroId, star, grade)--tableData_tHeroStarUp
	if star >= 100 then
        error("star must < 100")
    end
    
    if grade >= 100 then
        error("grade must < 100")
    end

    local cacheId = heroId * 10000 + star * 100 + grade
	local data = heroTableCache1[cacheId]
    if data == nil then
        for _ , v in pairs(tableData_tHeroStarUp.data) do
            if v.heroId == heroId and v.star == star and v.grade == grade then
                data = v
                heroTableCache1[cacheId] = data
                break
            end
        end
    end

	return data
end

local heroTableCache2 = {}
function LuaTableMgr:GetHeroGradeUpDataByHeroIdGrade(heroId, grade)--tableData_tHeroGradeUp 
    if grade >= 100 then
        error("grade must < 100")
    end

    local cacheId = heroId * 100 + grade
	local data = heroTableCache2[cacheId]
    if data == nil then
        for _ , v in pairs(tableData_tHeroGradeUp.data) do
            if v.heroId == heroId and v.grade == grade then
                data = v
                heroTableCache2[cacheId] = data
                break
            end
        end
    end
	return data
end

local badgeTableCache1 = {}
function LuaTableMgr:GetBadgeDataByIdQuality(badgeId, quality)--tableData_tBadge 
    if quality >= 100 then
        error("quality must < 100")
    end
    local cacheId = badgeId * 100 + quality
	local data = badgeTableCache1[cacheId]
	if data == nil then
        for _, v in pairs(tableData_tBadge.data) do
            if v.badgeId == badgeId and v.quality == quality then
                data = v
                badgeTableCache1[cacheId] =data
                break
            end
        end
    end
	return data
end

local rulesTableCache1 = {}
function LuaTableMgr:GetRulesDataByStarGrade(star, grade)--tableData_tRules 
    if grade >= 100 then
        error("grade must < 100")
    end

    local cacheId = star * 100 + grade

	local data = rulesTableCache1[cacheId]
    if data == nil then
        for _, v in pairs(tableData_tRules.data) do
            if v.star == star and v.grade == grade then
                data = v
                rulesTableCache1[cacheId] = data
                break
            end
        end
    end

	return data
end

local needTextTableCache1 = {}
function LuaTableMgr:GetNeedTextDataByAddition(additionArmy, additionAttr)--tableData_tNeedText 
    if additionAttr >= 10000 then
        error("additionAttr must < 10000")
    end
    local cacheId = additionArmy * 10000 + additionAttr
	local data = needTextTableCache1[cacheId]
    if data == nil then
        for _, v in pairs(tableData_tNeedText.data) do
            if v.additionArmy == additionArmy and v.additionAttr == additionAttr then
                data = v
                needTextTableCache1[cacheId] = data
                break
            end
        end
    end

	return data
end

local techDetailTableCache1 = {}
function LuaTableMgr:GetTechDetailDataByIdLevel(techId, level)--tableData_tTechDetail 
    if level >= 1000 then
        error("level must < 1000")
    end
    local cacheId = techId * 1000 + level
	local data = techDetailTableCache1[cacheId]
    if data == nil then
        for _, v in pairs(tableData_tTechDetail.data) do
            if v.TechId == techId and v.Level == level then
                data = v
                techDetailTableCache1 = data
                break
            end
        end
    end
	return data
end

function LuaTableMgr:GetItemExchangeList()--tableData_tExItem 
	return tableData_tExItem.data
end

function LuaTableMgr:GetMissionTutorialList()--tableData_tMissionTutorial 
	return tableData_tMissionTutorial.data
end

function LuaTableMgr:GetTutorialDataList()--tableData_tTutorial 
	return tableData_tTutorial.data
end

function LuaTableMgr:GetFunctionUnlockText(id)--tableData_tfunction LuaTableMgr:
	local ptxt = nil
	local data = tableData_tFunction.data[tonumber(id)]
	if data ~= nil then
		ptxt = data.promptText
	end
	return ptxt
end

function LuaTableMgr:GetFunctionUnlockLevel(id) 
	local nCh = nil
	local data = tableData_tFunction.data[tonumber(id)]
	if data ~= nil then
		nCh = data.needChapter
	end
	return nCh
end

function LuaTableMgr:GetResourceRuleDataByTypeLevel(type, level)--tableData_tResourceRule 
	local data = nil
	for _ , v in pairs(tableData_tResourceRule.data) do
		if v.type == type and v.level == level then
			data = v
			break
		end
	end

	return data
end


function LuaTableMgr:GetArtSettingList()--tableData_tArtSetting 
	return tableData_tArtSetting.data
end

function LuaTableMgr:GetBasicSurfaceDataByType(type)--tableData_tBasicSurface 
	local data = nil
	for _ , v in pairs(tableData_tBasicSurface.data) do
		if v.type == type then
			data = v
			break
		end
	end

	return data
end




local BasicSurfaceTypeMap 

function LuaTableMgr:GetBasicSurfaceListByType(type)--tableData_tBasicSurface 
	if BasicSurfaceTypeMap == nil then
		BasicSurfaceTypeMap = {}
		for _ , v in pairs(tableData_tBasicSurface.data) do
			if BasicSurfaceTypeMap[v.type] == nil then
				BasicSurfaceTypeMap[v.type] = {}
			end
			table.insert(BasicSurfaceTypeMap[v.type],v)
		end
	end
	return BasicSurfaceTypeMap[type]
end

function LuaTableMgr:IsInBasicSurfaceDataRect(basicSurfaceData,x,y)
	local minx = basicSurfaceData.coordX
	local miny = basicSurfaceData.coordY
	local maxx = basicSurfaceData.coordX + basicSurfaceData.width
	local maxy = basicSurfaceData.coordY + basicSurfaceData.height
	return x > minx and y > miny and x < maxx and y < maxy
end

function LuaTableMgr:GetBasicSurfaceBuffId(types,x,y,extra_condition_func)
	if types == nil  or #types == 0 then
		return nil
	end
	for i=1,#types do
		local bsl = self:GetBasicSurfaceListByType(types[i])
		if bsl ~= nil then
			for j=1,#bsl do
				
				if extra_condition_func == nil then
					if (self:IsInBasicSurfaceDataRect(bsl[j],x,y)) then
						return bsl[j].buffidShow
					end					
				else
					if (self:IsInBasicSurfaceDataRect(bsl[j],x,y)) then
						if extra_condition_func(bsl[j]) then
							return bsl[j].buffidShow
						end
					end					
				end

			end
		end
	end
	return nil
end


function LuaTableMgr:GetObjectShapeList()--tableData_tObjectSharp 
	return tableData_tObjectSharp.data
end

function LuaTableMgr:GetSpyPrice(target, param)--tableData_tSpyPrice 
	local price = ""
	for _ , v in pairs(tableData_tSpyPrice.data) do
		if v.target == target and v.param == param then
			price = v.price
			break
		end
	end

	return price
end

function LuaTableMgr:GetLoginData(platform)--tableData_tLogin 
	local datas = {}
	for _ ,v in kpairs(tableData_tLogin.data) do
		if v.platformId == platform then
			table.insert(datas , v)
		end
	end
	return datas
	
end

function LuaTableMgr:GetUnionBadgeColorList()--tableData_tUnionBadgeColor 
	return tableData_tUnionBadgeColor.data
end

function LuaTableMgr:GetUnionBadgeBorderList()--tableData_tUnionBadgeBorder 
	return tableData_tUnionBadgeColor.data
end

function LuaTableMgr:GetUnionBuildingList()--tableData_tUnionBuilding 
	return tableData_tUnionBuilding.data
end

function LuaTableMgr:GetUnionMineByResourceType(resourceType)--tableData_tUnionBuilding 
	local data = nil
	for _ , v in pairs(tableData_tUnionBuilding.data) do
		if v.type == MapMsg_pb.GuildBuildTypeGuildMine and v.resourceType == resourceType then
			data = v
			break
		end
	end
	return data
end

function LuaTableMgr:GetUnionLanguageList()--tableData_tUnionLanguage 
	return tableData_tUnionLanguage.data
end

local tradingPostTableCache1 = {}
function LuaTableMgr:GetTradingPostData(level)--tableData_tTradingPost 
	local data = tradingPostTableCache1[level]
    if data == nil then
        for _ , v in pairs(tableData_tTradingPost.data) do
            if v.buildLevel == level then
                data = v
                tradingPostTableCache1 = data
                break
            end
        end
    end

	return data
end

local embassyTableCache1 = {}
function LuaTableMgr:GetEmbassyData(level)--tableData_tEmbassy 
	local data = embassyTableCache1[level]
    if data == nil then
        for _ , v in pairs(tableData_tEmbassy.data) do
            if v.buildlevel == tonumber(level) then
                data = v
                embassyTableCache1[level] = data
                break
            end
        end
    end

	return data
end

local assembledTableCache1 = {}
function LuaTableMgr:GetAssembledData(level)--tableData_tAssembled 
	local data = assembledTableCache1[level]
	if data == nil then
        for _ , v in pairs(tableData_tAssembled.data) do
            if v.buildlevel == level then
                data = v
                assembledTableCache1[level] = v
                break
            end
        end
    end

	return data
end

local talentTableCache1 = {}
function LuaTableMgr:GetTalentDataByIdLevel(techId, level)--tableData_tTalentDetail 
    if level >= 1000 then
        error("level must < 1000")
    end

    local cacheId = techId * 1000 + level
	local data = talentTableCache1[cacheId]
    if data == nil then
        for _ , v in pairs(tableData_tTalentDetail.data) do
            if v.TechId == techId and v.Level == level then
                data = v
                talentTableCache1[cacheId] = data
                break
            end
        end
    end

	return data
end


function LuaTableMgr:GetActivityStaticsRewardData(reward, rewardValue)--tableData_tStatisticsReward 
	local data = nil
	for _ , v in pairs(tableData_tStatisticsReward.data) do
		if v.rewardId == reward then
			if rewardValue >= v.minFight and rewardValue <= v.maxFight then
				data = v
				break
			end
		end
	end

	return data
end

function LuaTableMgr:GetUnionTechDetailDataByIdLevel(techId, level)--tableData_tUnionTech 
	local data = nil
	for _ , v in pairs(tableData_tUnionTech.data) do
		if v.TechId == techId and v.Level == level then
			data = v
			break
		end
	end

	return data
end

function LuaTableMgr:GetUnionBadgeTotemList()--tableData_tUnionBadgeTotem 
	return tableData_tUnionBadgeTotem.data
end

function LuaTableMgr:GetUnionNumByType(_type)--tableData_tUnionNum 
	local num = 0
	for _ , v in pairs(tableData_tUnionNum.data) do
		if v.type == _type then
			num = v.num
			break
		end
	end

	return num
end

function LuaTableMgr:GetEquipTextDataByAddition(additionArmy, additionAttr)--tableData_tEquipText 
	local addtxt = ""
	for _ , v in pairs(tableData_tEquipText.data) do
		if v.AdditionArmy == additionArmy and v.AdditionAttr == additionAttr then
			addtxt = v.AdditionText
			break
		end
	end

	return addtxt
end

function LuaTableMgr:GetPVEMoraleBonusFactor(id)--tableData_tAddcoef 
	local data = tableData_tAddcoef.data[tonumber(id)]
	local factor = data == nil and 1 or data.MoraleBonusFactor
	return factor
end

function LuaTableMgr:GetPVEPhysiqueBonusFactor(id)--tableData_tAddcoef 
	local data = tableData_tAddcoef.data[tonumber(id)]
	local factor = data == nil and 1 or data.PhysiqueBonusFactor
	return factor
end

function LuaTableMgr:GetPVETenacityBonusFactor(id)--tableData_tAddcoef 
	local data = tableData_tAddcoef.data[tonumber(id)]
	local factor = data == nil and 1 or data.TenacityBonusFactor
	return factor
end

function LuaTableMgr:GetActivityNoticeList()--tableData_tActivityNotice 
	return tableData_tActivityNotice.data
end

function LuaTableMgr:GetVipDataList()--tableData_tVip 
	return tableData_tVip.data
end

function LuaTableMgr:GetVipData(id)
	return tableData_tVip.data[tonumber(id)]
end

function LuaTableMgr:GetVipGiftDataList() 
	return tableData_tVipGift.data
end

function LuaTableMgr:GetVipPrivilegeDataList()--tableData_tVipPrivilege 
	return tableData_tVipPrivilege.data
end

function LuaTableMgr:GetVipPrivilegeData(viplevel , param1)
	for _ , v in pairs(tableData_tVipPrivilege.data) do
		if v.level == viplevel and tonumber(v.param1) == param1 then
			return v
		end
	end
end

function LuaTableMgr:GetAllBuildingData()--tableData_tBuilding 
	return tableData_tBuilding.data
end

function LuaTableMgr:GetMaxHeroLevel() 
	return tableData_tHeroExp.Count
end

function LuaTableMgr:GetStaminaPriceDataCount() 
	return tableData_tStaminaPrice.Count
end

function LuaTableMgr:GetRandomName() --tableData_tName 
	local data1 = {}
	for i, v in pairs(tableData_tName.data) do
		table.insert(data1, v.id)
	end

	local data2 = {}
	for i, v in pairs(tableData_tSurName.data) do
		table.insert(data2, v.id)
	end

	math.randomseed(os.time())
	return tableData_tName.data[data1[math.random(1, #data1)]].name .. tableData_tSurName.data[data2[math.random(1, #data2)]].name
end

function LuaTableMgr:GetActivitySiegeMonsterReward(times)--tableData_tSiegeMonsterReward 
	local list = {}
	if times > tableData_tSiegeMonsterNumberList.Count then
		times = tableData_tSiegeMonsterNumberList.Count
	end

	local numlist = tableData_tSiegeMonsterNumberList.data[times].activeReward:split(";")
	for i = 1, #numlist do
		table.insert(list, tableData_tSiegeMonsterReward.data[tonumber(numlist[i])])
	end

	return list
end

function LuaTableMgr:GetActivitySiegeMonsterMaxWave(times)
	if times > tableData_tSiegeMonsterNumberList.Count then
		times = tableData_tSiegeMonsterNumberList.Count
	end
	return tableData_tSiegeMonsterNumberList.data[times].maxWave
end

function LuaTableMgr:GetActivitySiegeMonsterRankRewardByType(_type)
    list = {}
	for i, v in ipairs(tableData_tSiegeMonsterRankReward.data) do
        if v.rewardType == _type then
            table.insert(list, v)
        end
    end
	return list
end

function LuaTableMgr:GetHeroLevelByExp(exp) 
    for i, v in ipairs(tableData_tHeroExp.data) do
        if exp < v.exp then
            local prevExp = 0
            local prevData = tableData_tHeroExp.data[i - 1]
            if prevData ~= nil then
                prevExp = prevData.exp
            end
            
            if exp >= prevExp then
                return i + (exp - prevExp) / (v.exp - prevExp)
            end
        end
    end

    return #tableData_tHeroExp
end

function LuaTableMgr:GetSiegeMonsterFightByWave(wave)
	return tableData_tSiegeMonsterRule.data[wave].fight
end

function LuaTableMgr:GetStoryById(id)
	return tableData_tStory.data[id]
end

function LuaTableMgr:GetStoryDataByType2(type2)
	for i, v in pairs(tableData_tMission.data) do
		if tonumber(v.type) == 200 and tonumber(v.type2) == tonumber(type2) then
			return v
		end
	end
	return nil
end

function LuaTableMgr:GetActivityShowCongfig(activityid, templetid)
	local configs = {}
	for i, v in kpairs(tableData_tActivityShowCongfig.data) do
		if tonumber(v.ActivityID) == activityid and tonumber(v.TempletID) == templetid then
			configs[v.ConfigName] = v.Content
		end
	end
	return configs
end

function LuaTableMgr:GetMissionListByActivity(activityid)
	local list = {}
	for i, v in pairs(tableData_tMission.data) do
		if tonumber(v.ActivityID) == activityid then
			table.insert(list, v)
		end
	end
	return list
end

function LuaTableMgr:GetSettingNoticeData()
	local notice = {}
	for i , v in pairs(tableData_tSettingNotice.data) do
		if notice[v.nType] == nil then
			notice[v.nType] = {}
		end

		table.insert(notice[v.nType] , v)
	end
	
	local TypeKey = {}
	for _ ,  v in pairs(notice) do
		table.sort(v , function(v1 , v2)
			return v1.subtype < v2.subtype
		end)
		table.insert(TypeKey , v)
	end
	
	table.sort(TypeKey , function(v1 , v2)
		return v1[1].nType < v2[1].nType
	end)
	
	return TypeKey
end

function LuaTableMgr:GetSupplyCollectListByActivity(activityid)
	local list = {}
	for i, v in pairs(tableData_tSupplyCollect.data) do
		if tonumber(v.activityID) == activityid then
			table.insert(list, v)
		end
	end
	return list
end

function LuaTableMgr:GetSupplyCollectRankShowByActivity(activityid)
	local list = {}
	local rangebegin = 0
	local rangeaward = 0
	local index = 0
	for i, v in kpairs(tableData_tSupplyCollectRank.data) do
		index = index + 1
		if v.ActivityID == activityid then
			if rangebegin == 0 then
				rangebegin = v.order
				rangeaward = v.awardShow
			else
				if rangeaward ~= v.awardShow then
					local d = {}
					if rangebegin ~= v.order - 1 then
						d.range = rangebegin .. "-" .. v.order - 1
					else
						d.range = rangebegin
					end
					d.award = rangeaward
					table.insert( list, d )
					rangebegin = v.order
					rangeaward = v.awardShow
				end
			end
		end
	end
	local d = {}
	if rangebegin ~= index then
		d.range = rangebegin .. "-" .. index
	else
		d.range = rangebegin
	end
	d.award = rangeaward
	table.insert( list, d )
	return list
end

function LuaTableMgr:GetGoveOfficialData()--tableData_tOfficial 
	return tableData_tOfficial.data
end

function LuaTableMgr:GetGoveOfficialDataByid(id)--tableData_tOfficial 
	return tableData_tOfficial.data[id]
end

function LuaTableMgr:GetSlgBuffDataToBuffValues(id)
	local data = self:GetSlgBuffData(id)
	if data == nil then
		return nil
	end
	local result ={}
	local t = string.split(data.Effect,';')
	for i = 1,#(t) do
		local tt = string.split(t[i],',')
		result[i] ={}
		result[i].buff_str = self:GetEquipTextDataByAddition(tt[2],tonumber(tt[3]))
		result[i].value = tonumber(tt[4])
	end
	return result
end

function LuaTableMgr:GetTurretData(id)
	return tableData_tTurret.data
end

function LuaTableMgr:GetTurretDataByid(id)
	return tableData_tTurret.data[id]
end

function LuaTableMgr:GetGovWarLogByid(id)
	return tableData_tGovWarLog.data[id]
end

function LuaTableMgr:GetTurretLogByid(id)
	return tableData_tTurretLog.data[id]
end

function LuaTableMgr:GetEliteRebelData(type , level)
	for k , v in pairs(tableData_tEliteMonsterRule.data) do
		if v.type == type and v.level == level then
			return v
		end
	end
end

function LuaTableMgr:GetEliteRebelDataById(id)
	return tableData_tEliteMonsterRule.data[tonumber(id)]
end

function LuaTableMgr:GetMaxEliteMonsterLevelByBaseLevel(baseLevel)
    local monsterList = {}
    for i, v in pairs(tableData_tEliteMonsterRule.data) do
        if v.type == 1 then
            table.insert(monsterList, v)
        end
    end
    table.sort(monsterList, function(v1, v2)
        return v1.baselevel > v2.baselevel
    end)

    for _, v in ipairs(monsterList) do
        if baseLevel >= v.baselevel then
            return v.level
        end
    end

    return 0
end

function LuaTableMgr:GetCurrency(languagecode)
	for k , v in pairs(tableData_tSetting.data) do
		if v.LanguageCode == languagecode and v.ParentID == 2 then
			return v.Currency
		end
	end
	return 0
end

function LuaTableMgr:GetLanguageSettingData(lanCode)
	for k , v in pairs(tableData_tSetting.data) do
		if v.LanguageCode == lanCode and v.ParentID == 2 then
			return v
		end
	end
	return nil
end

function LuaTableMgr:GetPVPATK(id)
	return tableData_tPVPATK.data[id]
end

function LuaTableMgr:GetUnionPrivilege(id)
	for i, v in pairs(tableData_tUnionPrivilege.data) do
		if v.id == id then
			return v
		end
	end
end

local ClimpChapterData = nil
local ClimpChapterDataOrder = nil
local ClimpChapterLayerCount = 0;
local ClimpChapterLevelTotalCount = 0;
local ClimpLayerOrder = nil
local ClimpLayerMap = nil
local ClimpLayerStartLevelCount = nil
local function CreateClimbChapterData()
	for i, v in pairs(tableData_tClimbChapter.data) do
		if ClimpChapterData == nil then
			ClimpChapterData= {}
		end
		if ClimpChapterData[v.ClimbChapterId] == nil then
			ClimpChapterData[v.ClimbChapterId] = {}
			ClimpChapterLayerCount = ClimpChapterLayerCount + 1
			if ClimpLayerOrder == nil then
				ClimpLayerOrder = {}
			end
			table.insert(ClimpLayerOrder,v.ClimbChapterId)
		end	
		table.insert(ClimpChapterData[v.ClimbChapterId],v)
		ClimpChapterLevelTotalCount = ClimpChapterLevelTotalCount +1
	end
	local comps = function(a,b)
		return a.id < b.id
	end

	local compslayer = function(a,b)
		return a < b
	end
	
	table.sort(ClimpLayerOrder,compslayer)

	for i, v in pairs(ClimpLayerOrder) do
		if ClimpLayerMap == nul then
			ClimpLayerMap = {}
		end
		ClimpLayerMap[v] = i
		if ClimpLayerStartLevelCount == nil then
			ClimpLayerStartLevelCount = {}
		end
		ClimpLayerStartLevelCount[i] = 0
		for j=2,i do
			ClimpLayerStartLevelCount[i] = ClimpLayerStartLevelCount[i] + #ClimpChapterData[ClimpLayerOrder[j-1]]
		end
	end
	for i, v in pairs(ClimpChapterData) do
		table.sort(v,comps)
		local index = 1
		for j,k in pairs(v) do
			if ClimpChapterDataOrder == nil then
				ClimpChapterDataOrder = {}
			end
			if ClimpChapterDataOrder[k.ClimbChapterId] == nil then
				ClimpChapterDataOrder[k.ClimbChapterId] = {}
			end	
			ClimpChapterDataOrder[k.ClimbChapterId][k.id] = index
			index = index + 1
		end
	end
end

function LuaTableMgr:GetClimbLayerStartLevelCount(index)
	if ClimpChapterData == nil then
		CreateClimbChapterData()
	end
	return ClimpLayerStartLevelCount[index]
end

function LuaTableMgr:GetClimbLayerTotalCount()
	if ClimpChapterData == nil then
		CreateClimbChapterData()
	end
	return ClimpChapterLayerCount;
end

function LuaTableMgr:ClimbLayerIdToIndex(layer_id)
	return ClimpLayerMap[layer_id]
end

function LuaTableMgr:ClimbLayerIndexToId(index)
	if ClimpLayerOrder == nil then
		CreateClimbChapterData()
	end	
	return ClimpLayerOrder[index]
end


function LuaTableMgr:GetClimpChapterLevelTotalCount()
	if ClimpChapterData == nil then
		CreateClimbChapterData()
	end	
	return ClimpChapterLevelTotalCount;
end

function LuaTableMgr:GetClimbChapter(chapter)
	if ClimpChapterData == nil then
		CreateClimbChapterData()
	end
	if ClimpChapterData ~= nil then
		return ClimpChapterData[chapter]
	end
	return nil
end

function  LuaTableMgr:GetClimbDataOrder(chapter,id)
	if ClimpChapterDataOrder == nil then
		CreateClimbChapterData()
	end	
	if ClimpChapterData ~= nil then
		return ClimpChapterDataOrder[chapter][id]
	else
		return nil
	end
end

function LuaTableMgr:GetClimbLevel(chapter,order)
	if ClimpChapterDataOrder == nil then
		CreateClimbChapterData()
	end	
	if ClimpChapterData ~= nil then
		return ClimpChapterData[chapter][order]
	else
		return nil
	end
end

function LuaTableMgr:GetClimbLevel4Id(id)
	return tableData_tClimbChapter.data[id]
end

function LuaTableMgr:GetClimbRank(id)
	return tableData_tClimbRank.data[id]
end

function LuaTableMgr:GetClimbReward(id)
	return tableData_tClimbReward.data[id]
end

function LuaTableMgr:GetClimbCondition(id)
	return tableData_tClimbCondition.data[id]
end

function LuaTableMgr:GetActivityFlagTable()
	return tableData_tActivityFlag.data
end

function LuaTableMgr:GetActivityVoteTimeTable()
	return tableData_tActivityVoteTime.data
end

function LuaTableMgr:GetSoldierStrength()
	return tableData_tSoldierStrength.data
end

function LuaTableMgr:GetSoldierStrengthLevelById(id)
	return tableData_tStrengthLevel.data[id]
end

function LuaTableMgr:GetSoldierStrengthAttrById(id)
	return tableData_tStrengthAttribute.data[id]
end

function LuaTableMgr:GetSoldierBaptizeById(id)
	return tableData_tSoldierBaptize.data[id]
end

function LuaTableMgr:GetRuneDataById(id)
	return tableData_tRune.data[tonumber(id)]
end

function LuaTableMgr:GetRuneData()
	return tableData_tRune.data
end

function LuaTableMgr:GetRunePosData(id)
	return tableData_tRunePos.data[id]
end

function LuaTableMgr:GetRuneUnlockData(id)
	return tableData_tRuneUnlock.data[id]
end

function LuaTableMgr:GetMobaRankData()
	return tableData_tMobaRank.data
end

function LuaTableMgr:GetMobaRankDataByID(id)
	return tableData_tMobaRank.data[id]
end

function LuaTableMgr:GetMobaTech()
	return tableData_tMobaTech.data
end

function LuaTableMgr:GetMobaMonsterByID(id)
	return tableData_tMobaMonster.data[id]
end

function LuaTableMgr:GetBattleFieldData(id)
	return tableData_tBattleField.data[tonumber(id)]
end

function LuaTableMgr:GetGuildMobaGlobal(id)
	return tableData_tGuildMobaGlobal.data[id]
end

local SuitData = nil

local function MakeSuitBaseBonus(_data, ArmyType, AttrType, Value)
	if _data.BaseBonus == nil then
		_data.BaseBonus = {}
	end
	local b = {}
	b.BonusType = ArmyType
	b.Attype =  AttrType
	b.Value = Value
	table.insert(_data.BaseBonus, b)
end

local function MakeSuitBonus(_data, ArmyType, AttrType, Value, Global)
	if _data.Bonus == nil then
		_data.Bonus = {}
	end
	MakeSuitBaseBonus(_data, ArmyType, AttrType, Value)
	if ArmyType == "" and AttrType == 0 then
		return
	end
	local t = string.split(ArmyType,';')  
	for j=1,#(t) do
	    if t[j] ~= nil then
	    	if tonumber(t[j]) ~= 0 or AttrType ~= 0 then
		        local b = {}
		        b.BonusType =tonumber(t[j])
		        b.Attype =  AttrType
		        b.Value =  Value
		        b.Global = Global
		        table.insert(_data.Bonus, b)
		    end
	    end
	end
end

local function MakeSuitData()
	if SuitData ~= nil then
		return 
	end
	SuitData = {}
	for i, v in pairs(tableData_tSuitEuip.data) do
		if SuitData[v.SuitId] == nil then
			SuitData[v.SuitId] = {}
		end
		SuitData[v.SuitId][v.Num] = {}
		MakeSuitBonus(SuitData[v.SuitId][v.Num], v.AdditionArmy1, v.AdditionAttr1, v.Value1, v.Global1)
		MakeSuitBonus(SuitData[v.SuitId][v.Num], v.AdditionArmy2, v.AdditionAttr2, v.Value2, v.Global2)
		MakeSuitBonus(SuitData[v.SuitId][v.Num], v.AdditionArmy3, v.AdditionAttr3, v.Value3, v.Global3)
	end	
end

function LuaTableMgr:GetSuitData(suit_id)
	MakeSuitData()
	return SuitData[suit_id];
end

function LuaTableMgr:GetSoliderLevelupData(solider_id,level)
	for i, v in pairs(tableData_tSoldierLevelup.data) do
		if v.SoldierId == solider_id and v.SoldierRank == level then
			return v;
		end
	end
end