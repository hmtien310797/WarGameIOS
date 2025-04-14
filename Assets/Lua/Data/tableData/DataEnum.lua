module("DataEnum", package.seeall)

ScActMonsterId = 
{
	ActMonsterFleeTime = 1,
	ActMonsterSearchSta = 2,
	ActMonsterActSta = 3,
	ActMonsterActFriend = 4,
	ActMonsterMassSta = 5,

	ActMonsterHeadIcon = 7,
}


ScGlobalDataId =
{
	SkillSlowMotionRatio = 2,
	SkillSlowMotionDuration = 3,
	FireLineOffset = 4,
	FireLineRetractSpeed = 5,
	DefenseFactor = 6,
	GodSkillGroupCooldown = 7,
	MaxCameraAheadOfFireLine = 9,
	CameraFollowFireLineDelay = 10,
	TriggerCameraFollowFireLineOffset = 11,
	CameraFollowFireLineOffset = 12,
	FireLineRetractAcceleration = 13,
	FireAreaRadius = 14,
	TipsTotalNum = 15,
	EachBuyEnergyAmount = 16,
	HeroAdditionBaseList = 17,
	HeroExpDiscountFactor = 18,
	PlayerExpItems = 19,
	RequestArmyCost = 20,
	PlayerMaxLevel = 100010,
	RequestChatRat = 21,
	ChatUnlock = 22,
	BuildFree = 23,
	TechFree = 24,
	PveArmyPowerFactor = 25,
	WorldMapBarrackPicture = 26,

	ExtralAttackForce = 50,
	AssistForce = 51,
	RestraintForce = 52,
	WeakForce = 53,
	DefenseForce = 54,
	CriticalChance = 55,
	CriticalFactor = 56,
	BlockChance = 57,
	BlockFactor = 58,
	WinLoseRoundCount = 59,
	WinRevertPercent = 60,
	LoseRevertPercent = 61,

	RestraintRelation1 = 62,
	RestraintRelation2 = 63,
	RestraintRelation3 = 64,
	RestraintRelation4 = 65,
	RestraintRelation5 = 66,
	RestraintRelation6 = 67,

	ExtralAttack = 68,
	ReturnLevel = 69,

	SLGPVPAttackTime = 70,
	SLGPVPAttackRoundWaitTime = 71,
	SLGPVPMoveAnimTime = 72,
	SLGPVPBattleEndWaitTime = 73,

	UnlockUnionMissionId = 74,

	PVPBatatleFightRange = 80,
	NoticeMoveSpeed = 81,

	AssembledTimeLevel = 90,

	MagicHurtFactor6 = 91,

	MagicHurtFactor14 = 92,
	PveMonsterHpCoef = 93,
	PveMonsterAttackCoef = 94,

	PayActivity = 97,
	PayFirstShow = 98,
	IngroResBar = 99,
	MilitarySchoolPreviewHigh = 100,
	MilitarySchoolPreviewNormal = 101,
    RebelSurroundPos = 102,
	RebelSurroundCenter = 103,
	RebelSurroundMonster = 104,	

	AdviceList = 105,
	AdviceTimer = 106,
	AdviceLimit = 107,
	BuildQueueUnlock = 108,
	RallyShareTime = 110,

	pveMonsterDR = 120,        	--打野怪额外恢复比例和伤兵比例
    pvePanzerDR = 121,			--打炮车额外恢复比例和伤兵比例
    pveEliteDR = 122,			--打精英叛军额外恢复比例和伤兵比例
    pveLansquenetDR = 123,		--打雇佣兵营地额外恢复比例和伤兵比例
    pveSiegeDR = 124,			--防守叛军攻城额外恢复比例和伤兵比例
    pveNormalDR = 125,			--其他大地图pve行为额外恢复比例和伤兵比例
    pvpAQuarterDR = 126,		--打驻扎额外恢复比例和伤兵比例
    pvpDQuarterDR = 127,		--防守驻扎额外恢复比例和伤兵比例
    pvpAOccupyDR = 128,			--打占领额外恢复比例和伤兵比例
    pvpDOccupyDR = 129,			--防守占领额外恢复比例和伤兵比例
    pvpAResourceDR = 130,		--打采集额外恢复比例和伤兵比例
    pvpDResourceDR = 131,		--防守采集额外恢复比例和伤兵比例
    pvpAGovDR = 132,			--打政府/炮台额外恢复比例和伤兵比例
    pvpDGovDR = 133,			--防守政府/炮台额外恢复比例和伤兵比例
    pvpAFortDR = 134,			--打要塞额外恢复比例和伤兵比例
    pvpDFortDR = 135,			--防守要塞额外恢复比例和伤兵比例
    pvpAPointDR = 136,			--打据点额外恢复比例和伤兵比例
    pvpDPointDR = 137,			--防守据点额外恢复比例和伤兵比例
    pvpAPlayerDR = 138,			--打玩家基地额外恢复比例和伤兵比例
    pvpDPlayerDR = 139,			--防守玩家基地额外恢复比例和伤兵比例
	pveDMonsterDefaultDR = 140,			--防守玩家基地额外恢复比例和伤兵比例
	pvePhalanxConfig = 141,			--pvp战斗中方阵中士兵实际数量和显示数量的对应关系配置
	UnionMessageUnLock = 150,		
	OfflinerepoOrder = 151,			
	OfflinerepoResShow = 152,	
	SlgBagRed = 154,
	PvPBattleCameraMove = 202,
	GoldLimitWarning = 204,		--建筑升级、科技升级、造兵、打造装备黄金限额提示
	 
	MaxLevel = 100010,
	WorldMapMonsterRebirthInterval = 100024,
	WorldMapMaxSceneEnergy = 100026,
	WorldMapMonsterOnceEnergy = 100028,
	WorldMapDistanceFactor = 100030,
	TradeBaseSpeed = 100032,
	BaseSoliderNum = 100033,
	OccupyEnemyTimeFactor = 100035,
	OccupyMinTime = 100036,
	OccupyMaxTime = 100037,
	OccupyTimeFactor = 100038,
	MassMinLevel = 100039,
	MilitaryRefrushTime = 100040,
	MilitaryRefrushCount1 = 100041,
	MilitaryRefrushCount2 = 100042,
	MilitaryRefrushCost1 = 100044,
	MilitaryRefrushCost2 = 100045,

	NewbieShieldLevel = 100043,
	NewbieShieldId = 100046,


	RestrictAreaSpeedFactor = 100047,
	BaseDefenceMaxNum = 100050,
	TrainFieldRewardInterval = 100066,
	TalentPageOpenLevel = 100069,
	ResourceBaseCapacity = 100070,
	MonsterMaxLevel = 100073,
	UnionInvitationCost = 100077,
	RebelArmyAttackDuration = 100078,
	RebelArmyAttackCD = 100082,


    RebelArmyFortressWarningTime = 100096,
    RebelArmyFortressBattleTime = 100097,
	RebelArmyFortressCaptureTime = 100098,
	
	EliteRebelCostEnergy = 100126,
	
	WorldZoneMapGuildlMember = 100111,
	
	EliteBattleFreshCost = 100143,
	ArmyBaseCount = 100201,
	SoldierEquipUnlockLevel = 100212,
	RateGame = 100223,
	BaseRobRes = 100225,
	ResWeightCfg = 100238, 
	AtkMoveTimeMin = 100240, 
	WorldMapPVPDistanceFactor = 100241,
	
	ChatUnlockInHome = 100242,
	SendMailUnlock = 100243,
	SendMailUnlockInHome = 100244,
	--聊天间隔
	ChatIntvContinusTime = 100245,
	ChatIntvContinusTimeHigh = 100246,
	ChatIntvContinusCount = 100247,
	ChatIntvContinusCD = 100248,
	--邮件间隔
	MailIntvContinusTime = 100253,
	MailIntvContinusTimeHigh = 100254,
	MailIntvContinusCount = 100255,
	MailIntvContinusCD = 100256,
	
	--聊天/邮件 屏蔽广告配置
	ChatFilterUrl = 100274 , 
	ChatFilterHeader = 100275 , 
	ChatFilterProduct = 100276 , 
	ChatFilterADJust = 100277 , 
	ChatFilterSNSJust = 100278 , 
}
