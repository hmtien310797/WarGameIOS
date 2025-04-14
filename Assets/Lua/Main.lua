

package.path = package.path .. ';protobuf.?.lua'
package.cpath = package.cpath .. ';protobuf.?.so'

require("class")
require("MenuList")

--require protobuf
require("Category_pb")
require("ClientMsg_pb")
require("BuildMsg_pb")
require("Common_pb")
require("ItemMsg_pb")
require("HeroMsg_pb")
require("PvPMsg_pb")
require("MailMsg_pb")
require("ChatMsg_pb")
require("ActivityMsg_pb")
require("LoginMsg_pb")
require("MapMsg_pb")
require("MobaMsg_pb")
require("GuildMsg_pb")
require("VipMsg_pb")
require("MobaMsg_pb")
require("GuildMobaMsg_pb")
require("GuildMobaData_pb")

-- require common
require("Common.EventListener")
require("Common.LuaTableMgr")
require("Common.TextDefine")
require("Common.EventDispatcher")
require("Common.Global") -- 请让我在EventDispatcher下面
require("Common.UIUtil")
require("Common.StringExtention")
require("Common.BitExtention")
require("Common.TableExtention")
require("Common.ToLuaExtension")
cjson = require("cjson")
cjson.encode_sparse_array(true)  
cjsonSafe = require("cjson.safe")
UIAnim = require("Common.UIAnim")
require("Common.Tooltip")
require("Common.SceneUtil")
require("Common.MessageBox")
require("Common.FloatText")
require("Common.CityCamera")
require("Common.BattleCamera")
require("Common.PowerUp")
require("Common.SpeedUpprice")
require("Common.MemoryTool")
require("Common.MapPool")
require("Common.PriorityQueue")
require("Common.DataStack")
require("Common.SortedList")

-- require data
require("Data.tableData.tableData_Main")
require("Common.TextUtil")

require("Data.ServerListData")
require("Data.MainData")
require("Data.ChapterListData")
require("Data.MoneyListData")
require("Data.ItemListData")
require("Data.CountListData")
require("Data.GeneralData")
require("Data.ArmyListData")
require("Data.ActiveHeroData")
require("Data.UnlockArmyData")
require("Data.ArmySetoutData")
require("Data.TeamData")
require("Data.BuffData")
require("Data.MailListData")
require("Data.ChestListData")
require("Data.MissionListData")
require("Data.ChatData")
require("Data.ActivityData")
require("Data.ConfigData")
require("Data.SevenDayData")
require("Data.ThirtyDayData")
require("Data.Welfare_Template1Data")
require("Data.FunctionListData")
require("Data.MonthCardData")
require("Data.WelfareData")
require("Data.Welfare_Template1Data")
require("Data.ShopItemData")
require("Data.GiftPackData")
require("Data.HeroCardData")
require("Data.UnionCardData")
require("Data.OnlineRewardData")
require("Data.NewbieCardData")
require("Data.WarCardData")

require("Data.MapInfoData")
require("Data.PathListData")
require("Data.ActionListData")
require("Data.WorldMapData")
require("Data.WorldBorderData")
require("Data.MapPreviewData")

require("Data.MobaActionListData")

require("Data.BuildingData")
require("Data.RadarData")
require("Data.BattleMoveData")
require("Data.MobaBattleMoveData")
require("Data.MobaRadarData")

require("Data.WorldCupData")

require("Data.SetoutData")

require("Data.UnionInfoData")
require("Data.UnionResourceRequestData")
require("Data.UnionHelpData")
require("Data.UnionCityData")
require("Data.SelfApplyData")
require("Data.UnionApplyData")
require("Data.UnionBuildingData")
require("Data.UnionOfficialData")
require("Data.UnionDonateData")

require("Data.NoticeData")
require("Data.RebelData")
require("Data.UnionRadarData")
require("Data.PveMonsterData")
require("Data.RebelWantedData")
require("Data.NotifySettingData")


require("Data.MilitaryActionData")

require("Data.QQData")
require("Data.TragetViewData")
require("Data.NotifyInfoData")
require("Data.TalentInfoData")
require("Data.UnionTechData")

require("Data.EquipData")
require("Data.RuneData")
require("Data.HeroEquipData")

require("Data.ActiveStaticsData")
require("Data.DailyActivityData")
require("Data.VipData")
require("Data.RebelArmyAttackData")

require("Data.RaceData")
require("Data.ActivityTreasureData")
require("Data.ActivityLevelRaceData")

require("Data.RebelSurroundData")

require("Data.GovernmentData")
require("Data.StrongholdData")
require("Data.FortressData")
require("Data.RebelSurroundNewData")
require("Data.AllianceInvitesData")

require("Data.UnionMessageData")
require("Data.GroupChatData")

require("Data.OfflinerepoData")
require("Data.GameFunctionSwitchData")

require("Data.JailInfoData")
require("Data.ExistTestData")
require("UI.Fort.FortsData")

require("Data.ActiveSlaughterData")
require("Data.ClimbData")
require("Data.ContinueRechargeData")
require("Data.Welfare_HerogetData")
require("Data.LuckyRotaryData")
require("Data.ExchangeTableData")
require("Data.ActivityExchangeData")
require("Data.WarLossData")
require("Data.ReconSaveData")
require("Data.Barrack_SoldierEquipData")
require("Data.DefenseData")
require("Data.NewRaceData")
require("Data.WorldCityData")
require("Data.MobaData")

require("Data.MobaHeroListData")
require("Data.MobaTeamData")
require("Data.MobaBarrackData")
require("Data.MobaItemData")
require("Data.MobaBuffData")
require("Data.MobaArmyListData")
require("Data.MobaSetoutData")
require("Data.MobaArmySetoutData")
require("Data.MobaMainData")
require("Data.MobaZoneBuildingData")
require("Data.MobaTechData")
require("Data.MobaPackageItemData")
require("Data.UnionMobaActivityData")
require("Data.ArenaInfoData")
require("Data.MilitaryRankData")
require("Data.FaceDrawData")
require("Data.PowerRankData")

require("UI.Moba.MobaPersonalInfo")

-- require ui
--
--
require("UI.Common.ResBar")
require("UI.Common.NumberInput")
require("UI.Common.ChangeName")
require("UI.Common.FirstChangeName")
require("UI.Common.CoordInput")
require("UI.Common.GatherItem")
require("UI.Common.GatherItemUI")
require("UI.Common.QuickUseItem")

require("UI.Activity.ActivityAll")
require("UI.Activity.GrowRewards")
require("UI.Activity.GrowGuide")
require("UI.Activity.GrowFemale")
require("UI.Activity.ActivityStage")
require("UI.Activity.ActivityEntrance")
require("UI.Activity.ActivityArmy")
require("UI.Activity.SevenDay")
require("UI.Activity.ThirtyDay")
require("UI.Activity.ArmRaceInfo")
require("UI.Activity.ActivityRace")
require("UI.Activity.IntegrationSource")
require("UI.Activity.ActivityTreasure")
require("UI.Activity.RebelGoldInstru")
require("UI.Activity.ActivityAll_empty")
require("UI.Activity.WelfareAll")
require("UI.Activity.ActivityBulletin")
require("UI.Activity.ActivityForecast")
require("UI.Activity.CD_Key")
require("UI.Activity.PVP_ATK_Activity")
require("UI.Activity.PVP_ATK_DisRank")
require("UI.Activity.PAP_ATK_Banner")
require("UI.Activity.PVP_LuckyRotary")
require("UI.Activity.PVP_LuckyRotary_Select")
require("UI.Activity.PVP_LuckyRotary_Sure")
require("UI.Activity.PVP_LuckyRotaryReward")
require("UI.Activity.PVP_LuckyRotary_Help")
require("UI.Activity.TenHero")

require("UI.Activity.DailyActivity_WorldcupGuss")
require("UI.Activity.DailyActivity_Worldcup")
require("UI.Activity.PowerRank")

require("UI.GM.GM")
require("UI.GM.GMCommand")
require("UI.GM.GMLog")
       
require("UI.InGame.QuestList")
require("UI.InGame.InGameUI")
require("UI.InGame.WinLose")
require("UI.InGame.pause")
require("UI.InGame.loading")

require("UI.Loading.LoadingMap")
       
require("UI.Login.login")
require("UI.Login.UpdateVersion")
require("UI.Login.ChooseZone")
       
require("UI.ChapterSelect.ChapterSelectUI")
require("UI.ChapterSelect.SandSelect")
require("UI.ChapterInfo.ChapterInfoUI")
require("UI.ChapterInfo.ChapterPVPInfo")
require("UI.ChapterSelect.SectionRewards")

require("UI.MainCity.MainCityUI")
require("UI.MainCity.maincity")
require("UI.MainCity.Offlinerepo")
require("UI.MainCity.DefenceNumber")

require("UI.Bag.UseItem")
require("UI.Bag.TemporaryBag")
require("UI.Bag.SlgBag")
require("UI.Bag.ItemListShowNew")
require("UI.Bag.BoxShow")
require("UI.Bag.UseSelectBox")
require("UI.Bag.BoxDetails")

require("UI.Hero.HeroUnlock")
require("UI.Hero.HeroList")
require("UI.Hero.HeroListNew")
require("UI.Hero.UniversalPiece")
require("UI.Hero.HeroInfo")
require("UI.Hero.HeroUpgrade")
require("UI.Hero.BadgeInfo") 
require("UI.Hero.HeroLevelUp")
require("UI.Hero.HeroStarUp")
require("UI.Hero.SelectHero")
require("UI.Hero.SellHeroItem")
require("UI.Hero.HeroAppointUI")
require("UI.Hero.HeroAppoint")
require("UI.Hero.AppointSuccess")
require("UI.Hero.HeroInfoNew")
require("UI.Hero.HeroStarUpNew")
require("UI.Hero.HeroSkillUpNew")
require("UI.Hero.HeroSkillLevelup")
require("UI.Hero.BadgeInfoNew_1")
require("UI.Hero.BasicParameters")

require("UI.MilitarySchool.MilitarySchool")
require("UI.MilitarySchool.OneCardDisplay")
require("UI.MilitarySchool.TenCardDisplay")

require("UI.MissionUI.MissionUI")

require("UI.Army.SelectArmy")
require("UI.Army.SoldierUnlock")

require("UI.Buildings.BuildingUpgrade")
require("UI.Buildings.BuildingDetails")

require("UI.Buildings.CommandCenter")
require("UI.MainCity.ResView")
require("UI.MainCity.ResViewDetails")
require("UI.MainCity.Speedup")
require("UI.MainCity.CommonItemBagHelp")
require("UI.MainCity.CommonItemBag")
require("UI.MainCity.update")
require("UI.MainCity.BuildingShowInfoUI")
require("UI.MainCity.BuffView")

require("UI.Notice_Tips.Notice_Tips")

require("UI.AttributeBonus.AttributeBonus")
require("UI.Buildings.BuildingLevelup")
require("UI.Buildings.BuildingLocked")
require("UI.Buildings.Hospital")
require("UI.Buildings.WallInfo")
require("UI.Buildings.WallHero")

require("UI.Buildings.Barrack")
require("UI.Buildings.Dissolution")
require("UI.Review.BuildReview")
require("UI.Review.WareHouse")
require("UI.ParadeGround.ParadeGround")


require("UI.Buildings.LaboratoryUpgrade")
require("UI.Buildings.Laboratory")
require("UI.Buildings.LaboratoryDetails")
require("UI.Buildings.BuildTransition")

require("UI.Player.MainInformation")
require("UI.Player.Levelup")
require("UI.Player.PlayerLevelup")
require("UI.Player.OtherInfo")
require("UI.Player.OtherView")
require("UI.Player.ChooseFlag")
require("UI.Player.WantedPrice")
require("UI.Player.RansomPay")
require("UI.Player.SoldierLevel")
require("UI.Player.SoldierLevelSure")
require("UI.Player.Statistic")
require("UI.Player.MilitaryRank")

require("UI.PVP.PVPUI")
require("UI.PVP.PVP_Rewards")
require("UI.PVP.PVP_Rewards_Skip")

require("UI.Pay.VipWidget")
require("UI.Shop.Shop")
require("UI.Shop.Goldstore")
require("UI.Shop.Goldstore_template1")
require("UI.Shop.Goldstore_template2")
require("UI.Shop.Goldstore_template3")
require("UI.Activity.HeroCard_reward")
require("UI.Activity.GrowGold")
require("UI.Activity.Welfare_Template1")
require("UI.Pay.Pay")
require("UI.Pay.MonthCard_reward")
require("UI.Pay.store_template2")
require("UI.Pay.TimedBag")
require("UI.Pay.TimedBag_Gold")
require("UI.Pay.TimedBag_common")
require("UI.Pay.TimedBag_VIP")
require("UI.Pay.TimedBag_notime")
require("UI.Pay.ZeroYuanGift")
require("UI.Vip.VIP")
require("UI.Vip.VIPLevelup")
require("UI.Vip.GetVipCoin")
require("UI.Vip.VipExp")

require("UI.Chat.Chat")
require("UI.Chat.UnionMessage")
require("UI.Chat.GroupSetting")
require("UI.Chat.GroupSelectList")
require("UI.Chat.PanelBox")

require("UI.MainCity.setting")
require("UI.Account.account")
require("UI.Account.options")
require("UI.Account.feedback")

require("UI.Tutorial.Tutorial")
require("UI.Tutorial.Event")
require("UI.Tutorial.Starwars")
require("UI.Tutorial.StoryPicture")
require("UI.Tutorial.ChapterPicture")
require("UI.Tutorial.SceneStory")
require("UI.Tutorial.Strategy")

require("UI.MainCity.MainCityQueue")
require("UI.ItemUse.Item_11101")
require("UI.MainCity.online")
require("UI.MainCity.HotTime")
require("UI.MainCity.UnionGuide")

require("UI.WorldMap.MapMask")
require("UI.WorldMap.WorldMap")
require("UI.WorldMap.MapHelp")
require("UI.WorldMap.TileInfo")
require("UI.WorldMap.PathInfo")
require("UI.WorldMap.ActionList")
require("UI.WorldMap.WarZoneUI")
require("UI.WorldMap.WorldMapZoneUI")

require("UI.WarZoneMap.WarZoneMap")
require("UI.WarZoneMap.TerritoryFilter")

require("UI.WorldMap.BattleMove")
require("UI.WorldMap.BMLayoutArchive")
require("UI.WorldMap.BMLocalHeroData")
require("UI.WorldMap.BMSelectHero")
require("UI.WorldMap.MobaBMSelectHero")
require("UI.WorldMap.BMFormation")
require("UI.WorldMap.Embattle")
require("UI.WorldMap.SelectHero_PVP")
require("UI.WorldMap.MobaSelectHero_PVP")

require("UI.WorldMap.RebelArmyWanted")
require("UI.WorldMap.StrongholdRule")
require("UI.WorldMap.WorldMapNet")


require("UI.Moba.MobaMsg")
require("UI.Moba.MobaMain")
require("UI.Moba.MobaTileInfo")
require("UI.Moba.MobaWallHero")
require("UI.Moba.Entrance")
require("UI.Moba.MobaWarZoneMap")
require("UI.Moba.MobaRankreward")
require("UI.Moba.MobaParadeGround")

require("UI.Moba.MobaUnionWar")
require("UI.Moba.MobaMassTroops")
require("UI.Moba.MobaEmbassy")
require("UI.Moba.MobaEmbattle")
require("UI.WorldMap.MobaActionList")
require("UI.Moba.MobaStore")
require("UI.Moba.MobaStoreBuy")
require("UI.Moba.MobaPoint")
require("UI.Moba.MobaBuffView")
require("UI.Moba.Moba_winlose")
require("UI.Moba.Mobaconclusion")
require("UI.Moba.MobaRank")
require("UI.Moba.Mobaroleselect")
require("UI.Moba.MobaChat")
require("UI.Moba.GuildMobaChat")
require("UI.Moba.MobaTraget_Share")
require("UI.Moba.mobafile")
require("UI.Moba.Mobahistory")
require("UI.Moba.MobaResBar")
require("UI.Moba.MobaMarchlist")

require("UI.GuildWar.AllianceMatch")
require("UI.GuildWar.AllianceRank")
require("UI.GuildWar.GuildWarMain")
require("UI.GuildWar.AllianceLogin")
require("UI.GuildWar.AllianceUnionSelect")
require("UI.GuildWar.BattleTime")
require("UI.GuildWar.UnionMoba_Winlose")
require("UI.GuildWar.AllianceHistory")

require("UI.Mail.Mail")
require("UI.Mail.MailNew")
require("UI.Mail.MailDoc")
require("UI.Mail.MailReportDoc")
require("UI.Mail.MailReportSpyonDoc")
require("UI.Mail.Mail_share")
require("UI.Mail.MailReportDocNew")

require("Data.MobaChatData")
require("Data.GuildMobaChatData")

require("UI.Skin.Skin")
require("UI.Skin.Skin_check")
require("UI.Skin.Skin_other")

require("UI.Union.UnionInfo")
require("UI.Union.UnionBuff")
require("UI.Union.UnionWar")
require("UI.Union.UnionBuilding")
require("UI.Union.UnionCity")
require("UI.Union.UnionMemberRank")
require("UI.Union.UnionMemberLevel")
require("UI.Union.UnionApprove")
require("UI.Union.UnionHelp")
require("UI.Union.UnionGift")
require("UI.Union.UnionFunction")
require("UI.Union.UnionWareHouse")
require("UI.Union.UnionWareHouseHis")
require("UI.Union.UnionShop")
require("UI.Union.UnionRadar")
require("UI.Union.UnionRadarHis")
require("UI.Union.UnionLog")
require("UI.Union.RebelArmy")
require("UI.Union.UnionManagement")
require("UI.Union.UnionAuthority")
require("UI.Union.UnionSetLevel")
require("UI.Union.JoinUnion")
require("UI.Union.UnionList")
require("UI.Union.UnionPubinfo")
require("UI.Union.UnionBadge")
require("UI.Union.UnionName")
require("UI.Union.UnionCode")
require("UI.Union.UnionLanguage")
require("UI.Union.UnionSuperOre")
require("UI.Union.UnionTrain")
require("UI.Union.Union_donate")
require("UI.Union.UnionEdit")
require("UI.Union.SectionRewards_union")

require("UI.Arena.ArenaShop")
require("UI.Arena.BattleHistory")

require("UI.Radar.Marchlist")
require("UI.Radar.CompensateList")

require("UI.ItemUse.Item_4201")
require("UI.ItemUse.Item_4301")


require("UI.WorldMap.PVP_SLG")
require("Common.BeatText")

require("UI.WorldMap.BattlefieldReport")
require("UI.ChapterInfo.Sweep")
require("UI.Login.Notice")

require("UI.TradeHall.TradeHall")
require("UI.TradeHall.Trade")

require("UI.Embassy.Embassy")

require("UI.WorldMap.MassTroopsCondition")
require("UI.WorldMap.MassTroops")
require("UI.WorldMap.assembled_time")

require("UI.WorldMap.rebel_history")
require("UI.WorldMap.rebel_predict")
require("UI.WorldMap.rebel_reward")
require("UI.WorldMap.rebel")
require("UI.WorldMap.City_lord")
require("UI.WorldMap.Union_Officialinfo")
require("UI.Activity.ArmRaceHisInfo")
require("UI.Activity.ArmRaceHisInfo_union")

require("UI.CityBattle.CityMap")

require("UI.MainCity.rank")
require("UI.Common.EndlessList")
require("UI.Common.FileRecorder")

require("UI.WorldMap.Traget_Set")
require("UI.WorldMap.Traget_View")

require("UI.WorldMap.TileInfoMore")
require("UI.WorldMap.WorldMapHUD")

require("UI.Common.instructions")
require("UI.WorldMap.Traget_Share")

require("UI.Activity.ActivityNotice")
require("UI.Activity.ActivityPveMonsterInfo")
require("UI.Activity.DailyActivity_Share")

require("UI.Player.TalentInfo")
require("UI.Player.TalentDetail")
require("UI.Player.TalentUpgrade")
require("UI.Player.RuneBag")
require("UI.Player.Sellmultiplerunes")
require("UI.Player.sellitem")
require("UI.Player.Sellrune")
require("UI.Player.Rune")
require("UI.Player.Selectrunes")
require("UI.Player.Runedraw")
require("UI.Player.Getnewrune")
require("UI.Player.Buyrunes")

require("UI.CityBattle.CityList")

require("UI.Union.UnionTec")
require("UI.Union.UnionRank")

require("UI.Login.Update_Repair")

require("UI.Equip.Equip")
--require("UI.Equip.EquipBuild")
--require("UI.Equip.EquipChange")
--require("UI.Equip.EquipCompound")
--require("UI.Equip.EquipInfo")
--require("UI.Equip.EquipMap")
require("UI.Equip.EquipSelect")

--装备改版
require("UI.Equip.EquipSelectNew")
require("UI.Equip.EquipBuildNew")
require("UI.Equip.EquipMainNew")

require("UI.Hero.HeroEquipBuildNew")

require("UI.Equip.HeroEquipSelectNew")

require("UI.Buildings.Barrack_Soldier")

require("UI.Pay.FirstPurchase")
require("UI.MainCity.update_ui")

require("UI.RebelArmyAttack.RebelArmyAttack")
require("UI.RebelArmyAttack.RebelArmyAttackHelp")
require("UI.RebelArmyAttack.RebelArmyAttackrank")
require("UI.RebelArmyAttack.RebelArmyAttackRewards")
require("UI.Activity.ActivityBanner")

require("UI.MissionUI.Story")

require("UI.Fort.FortOccuRule")
require("UI.Fort.FortRule")
require("UI.Fort.FortHistory")
require("UI.Fort.FortInfo")
require("UI.Fort.FortInfoall")
require("UI.Fort.Fort_predict")

require("UI.Pay.store")
require("UI.MilitarySchool.Preview")

require("UI.Activity.KingsRoad")
require("UI.Activity.DailyActivity_Template1")
require("UI.Activity.SupplyCollect")
require("UI.Activity.SupplyCollectRewards")
require("UI.Activity.SupplyCollectRanking")
require("UI.Activity.HolidayActivity")
require("UI.Activity.LevelRace")
require("UI.Activity.DailyActivity")
require("UI.activity.DailyActivityHelp")
require("UI.MainCity.RebelSurround")
require("UI.MainCity.RebelSurrounddefenceshow")
require("UI.MainCity.RebelSurround_ins")
require("UI.MainCity.RebelSurround_report")
require("UI.MainCity.RebelSurround_spy")
require("UI.MainCity.RebelSurround_TileInfo")
require("UI.MainCity.RebelSurroundrewardList")
require("UI.Setting.SettingNotice")
require("UI.Setting.SettingBlackList")

require("UI.WorldMap.GOV_Util")
require("UI.WorldMap.GOV_Help")
require("UI.WorldMap.GOV_Main")
require("UI.WorldMap.GOV_Tax")
require("UI.WorldMap.GOV_Officialinfo")
require("UI.WorldMap.GOV_Authority")
require("UI.WorldMap.BatteryTarget")
require("UI.WorldMap.BatteryTarget_add")
require("UI.WorldMap.GOVWarinfo")
require("UI.WorldMap.GOV_predict")
require("UI.WorldMap.FortressInfoall")
require("UI.WorldMap.StrongholdInfoall")
require("UI.WorldMap.GOVBanner")
require("UI.WorldMap.BatteryAttackinfo")
require("UI.EliteRebel.EliteRebel")
require("UI.EliteRebel.EliteRebelHelp")
require("UI.MainCity.RebelSurroundNew")
require("UI.MainCity.RebelSurroundNew_advance")
require("UI.MainCity.ShareUnion")
require("UI.MainCity.ShareCommon")
require("UI.WorldMap.StrongholdWarinfo")
require("UI.WorldMap.FortressWarinfo")
require("UI.WorldMap.MapSearch")
require("UI.WorldMap.UnitCounters")

require("UI.WorldMap.MobaBattleMove")

require("UI.Jail.JailInfo")
require("UI.Jail.JailTreat")
require("UI.Jail.Prisonerhelp")

require("UI.Arena.BattleRank")
require("UI.Arena.BattleFormation")
require("UI.Arena.SelectHero_Arena")
require("UI.Arena.RankList")
require("UI.Arena.ArenaRewards")
require("UI.Arena.Arena_Help")
require("UI.Arena.Npcinfo")

require("UI.MainCity.WebPlugnUI")
require("UI.Activity.Welfare_Timebag")
require("UI.Login.PPGameLogin")
require("UI.Activity.ExistTest")
require("UI.Activity.ExistTestHelp")
require("UI.Activity.ExistTestNotice")
require("UI.Activity.ChapComplete")

require("UI.MainCity.rategame")
require("UI.MainCity.SoldierProduction")
require("UI.Activity.DailyActivity_ContinueRecharge")
require("UI.Activity.Welfare_heroget")
require("UI.Activity.RechargeRewards")
require("UI.Activity.LuckyRotary")
require("UI.Activity.LuckyRotaryReward")
require("UI.Activity.Christmas")
require("UI.Activity.Christmas")
require("UI.Activity.ChristmasRank")
require("UI.Activity.ChristmasHelp")
require("UI.Activity.ChristmasRewards")
require("UI.Climb.Climb")
require("UI.Climb.ClimbInfo")
require("UI.Climb.ClimbReward")
require("UI.Buildings.Barrack_SoldierEquip")
require("UI.Buildings.SoliderUpgrade")
require("UI.Buildings.SoldierEquipBanner")
require("UI.Activity.NewRace")
require("UI.Activity.NewRaceRredict")
require("UI.Activity.NewRaceResult")
require("UI.Activity.NewRaceBanner")
require("UI.Activity.NewRaceReward")
require("UI.Activity.NewRaceSource")
require("UI.Activity.NewRaceRank")
require("UI.Activity.NewRaceHelp")
require("UI.Activity.NewActivityBanner")
require("UI.Activity.GetStrong")
require("UI.Vip.QueueLease")
require("UI.WorldMap.Reinforcement")
require("UI.Activity.Rebate_LuckyRotary")
require("UI.Activity.ReturnRewards")

require("UI.Activity.ActivityGrow") --请让我保持在最后一个!!!!!!!!!!!!!!!!!!!!

local TextMgr = Global.GTextMgr
local GUIMgr = Global.GGUIMgr

--主入口函数。从这里开始lua逻辑
function main()
	--Serclimax.Constants.ENABLE_FAKE_DATA = true
	Serclimax.Constants.USE_LOCAL_LEVEL_DATA = true
end

function InitPush()
    LuaNetwork.RegisterPush(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgFreshItemsPush, function(typeId, data)
        local msg = ItemMsg_pb.MsgFreshItemsPush()
        msg:ParseFromString(data)
        MainCityUI.UpdateRewardData(msg.reward)
    end)
    LuaNetwork.RegisterPush(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPTickPush, function(typeId, data)
        local msg = PvPMsg_pb.MsgBattlePvPTickPush()
        msg:ParseFromString(data)
        PVPUI.PVPBattlePVPTickPush(msg)
    end)
   LuaNetwork.RegisterPush(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPBattleStatePush, function(typeId, data)
        local msg = PvPMsg_pb.MsgBattlePvPBattleStatePush()
        msg:ParseFromString(data)
        PVPUI.PvPBattleStatePush(msg)
    end)
	
	
	LuaNetwork.RegisterPush(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailNotifyPush, function(typeId, data)		
        local msg = MailMsg_pb.MsgUserMailNotifyPush()
		print("mail push")
		msg:ParseFromString(data)
        MainCityUI.OnMailNotify(msg)
    end)
	
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaMailNotifyPush, function(typeId, data)		
        local msg = GuildMobaMsg_pb.GuildMobaMailNotifyPush()
		print("guild war mail push")
        --MainCityUI.OnMailNotify(msg)
		if GUIMgr:FindMenu("GuildWarMain") ~= nil then
			msg:ParseFromString(data)
			GuildWarMain.OnMailNotify(msg)
		end
    end)
	
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaChatFreshPush, function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaChatFreshPush()
    	msg:ParseFromString(data) 
		if GUIMgr:FindMenu("GuildWarMain") ~= nil then
			msg:ParseFromString(data)
			print("moba guildwar chat push " , msg.channel)
			GuildMobaChatData.RequestChat(msg.channel)
		end
    end)

	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionFreshPush, function(typeId, data)
        local msg = ClientMsg_pb.MsgUserMissionFreshPush()
		msg:ParseFromString(data)
        MissionListData.UpdatePush(msg)
    end)

	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgServerDailyZoreTimePush, function(typeId, data)
        local msg = ClientMsg_pb.MsgServerDailyZoreTimePush()
		msg:ParseFromString(data)
		
        MainData.RequestData()
        MissionListData.RequestData()
		ActivityTreasureData.RequestData(false)
		LuckyRotaryData.RequestData()
		-- VIP相关刷新
		VipData.RequestVipPanel(function()
			-- VIP界面刷新
			VIP.UpdateVipGiftData()
			VIP.RefreshLootBox()

            MainCityUI.UpdateVipNotice()
			MainCityUI.UpdateCashShopNotice()
		end)
		ChestListData.RequestData()
		OnlineRewardData.RequestData()		
		SevenDayData.RequestData()
		ThirtyDayData.RequestData()
		-- MonthCardData.RequestData()
		NewbieCardData.RequestData(ShopMsg_pb.IAPGoodType_DevelopCard)
		WarCardData.RequestData(ShopMsg_pb.IAPGoodType_WarCard)
		Welfare_Template1Data.RequestData()
		ContinueRechargeData.UpdateRechargeStatus()
		WelfareAll.UpdateConfigs(function()
			WelfareAll.RefreshTab()
			MainCityUI.UpdateWelfareNotice()
		end)
		UnionTechData.SetNormalDonateNotice()
		ExistTestData.RequestSendFlowerData()
		CountListData.RequestData()
		WarLossData.RequestData()
		ActivityExchangeData.RequestData()
		NewRaceData.RequestData(false)
        if Global.ACTIVE_GUILD_MOBA then
            UnionMobaActivityData.RequestData(false)
        end
    end)
	
	LuaNetwork.RegisterPush(Category_pb.Login, LoginMsg_pb.LoginTypeId.MsgOfflineByDuplicateLoginPush, function(typeId, data)
        local msg = LoginMsg_pb.MsgOfflineByDuplicateLoginPush()
        msg:ParseFromString(data)
		GUIMgr.Instance.kickOff = true
    end)
	
	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgClientMainDataPush, function(typeId, data)
        local msg = ClientMsg_pb.MsgClientMainDataPush()
        msg:ParseFromString(data)
		--print("Maindata push")
        if GUIMgr.Instance:IsMenuOpen("ChapterSelectUI") then
        	Sweep.SetMainData(msg)
		end
		MainData.CheckPkValue(msg)
		--MainData.UpdateGov(msg.data)--合入到MainData.CheckPkValue(msg)中
    end)
	
	LuaNetwork.RegisterPush(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPDeliverPush, function(typeId, data)
		local msg = ShopMsg_pb.MsgIAPDeliverPush()
		msg:ParseFromString(data)
		
		VipData.SetGiftData(msg.pkgInfos, msg.vipInfo.viplevel)
		MainData.UpdateVip(msg.vipInfo)
		
        MainCityUI.UpdateRewardData(msg.fresh)
		if #msg.reward.item.item == 0 and #msg.reward.hero.hero == 0 then
			return
		end

		store.SuccessfullyPurchase(msg.goodId)
        GiftPackData.RequestData(nil, nil, msg.goodId)
		MonthCardData.SuccessfullyPurchase(msg.goodId)
		HeroCardData.SuccessfullyPurchase(msg.goodId)
		UnionCardData.SuccessfullyPurchase(msg.goodId)
		NewbieCardData.SuccessfullyPurchase(msg.goodId)
		WarCardData.SuccessfullyPurchase(msg.goodId)
		Goldstore_template3.SuccessfullyPurchase(msg.goodId)

		if msg.goodId >= 616 and msg.goodId <= 622 then -- 首充后续礼包
			ItemListShowNew.SetCloseMenuCallback(function()
				TimedBag_notime.CloseSelf()
				MainData.RequestFirstRechargeInfo(function()
					coroutine.start(function()
						local topMenu = GUIMgr:GetTopMenuOnRoot()
						while topMenu == nil or topMenu.name ~= "MainCityUI" do
							coroutine.step()
							topMenu = GUIMgr:GetTopMenuOnRoot()
							if topMenu.name == "TimedBag_notime" then
								return
							end
						end
						TimedBag_notime.Show()
					end)
				end)
			end)
		end
		ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
		ItemListShowNew.SetItemShow(msg)
		GUIMgr:CreateMenu("ItemListShowNew" , false)
		
		-- 福利相关刷新
		if msg.goodId == 300 then
			MonthCardData.RequestCard(3, function() MainCityUI.UpdateWelfareNotice(3004) end)
		elseif msg.goodId == 400 then
			MonthCardData.RequestCard(4, function() MainCityUI.UpdateWelfareNotice(3004) end)
		elseif msg.goodId == 500 then
			CountDown.Instance:Remove("GrowGold")
			WelfareData.SuccessfullyPurchase(3001)
			WelfareAll.RefreshTab()
		end

		-- 商城相关刷新
		if msg.goodId > 100 and msg.goodId < 107 then -- 黄金礼包
			store_template2.SuccessfullyPurchase(msg.goodId)
			MainData.SetRecharged()
		end
		
		if msg.goodId == 200 then -- 首充礼包
			FirstPurchase.CloseSelf()
			MainCityUI.UpdateFirstpurchase()
		end

		if msg.goodId >= 700 and msg.goodId < 800 then -- 限时礼包
			--TimedBag.SuccessfullyPurchase(msg.goodId)
		end
		GUIMgr:UnlockScreen()
		Rebate_LuckyRotary.RequestData()
		ReturnRewards.RequestData()
	end)

	--  LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapEventPush, function(typeId, data)
	--  	print("SSSSSSSSSSSSSSSSSSSSSSSS MapMsg_pb.MapTypeId.SceneMapEventPush")
	--  	local msg = MapMsg_pb.SceneMapEventPush()
	--  	msg:ParseFromString(data)
    --      if GUIMgr.Instance:IsMenuOpen("WorldMap") then
    --          WorldMap.RequestMapData(false)
    --      end
	--  end)

	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.ActionPush, function(typeId, data)
		ActionListData.RequestData()
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaActionPush, function(typeId, data)
		MobaActionListData.RequestData()
	end)
	
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaActionPush, function(typeId, data)
		MobaActionListData.RequestData()
	end)

	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaMatchPush, function(typeId, data)
        if Global.ACTIVE_GUILD_MOBA then
            UnionMobaActivityData.RequestData(false)
        end
	end)
	
	
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaClientMainDataPush, function(typeId, data)
		MobaMainData.RequestData()
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.RadarPush, function(typeId, data)
		local msg = MapMsg_pb.RadarPush()
		msg:ParseFromString(data)
		--RadarData.UpdateData(msg.info)
		print("RadarPush synctype:", msg.synctype)
		RadarData.RequestData()
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaRadarPush , function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaRadarPush ()
		msg:ParseFromString(data)
		--RadarData.UpdateData(msg.info)
		print("MsgMobaRadarPush  synctype:", msg.synctype)
		MobaRadarData.RequestData()
	end)
	
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaRadarPush , function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaRadarPush ()
		msg:ParseFromString(data)
		--RadarData.UpdateData(msg.info)
		print("GuildMobaRadarPush  synctype:", msg.synctype)
		MobaRadarData.RequestData()
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgFreshMoneyPush, function(typeId, data)
		local msg = ItemMsg_pb.MsgFreshMoneyPush()
		msg:ParseFromString(data)
		MainCityUI.UpdateMoneyData(msg)
    end)
	
	LuaNetwork.RegisterPush(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgUserArmyUnitsPush, function(typeId, data)
		local msg = HeroMsg_pb.MsgUserArmyUnitsPush()
		msg:ParseFromString(data)

		TeamData.OnPushSetData(msg)
		Barrack.UpdateArmNumEx(msg)
    end)
	
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaUserArmyUnitsPush, function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaUserArmyUnitsPush()
		msg:ParseFromString(data)

		MobaTeamData.OnPushSetData(msg)
		MobaBarrackData.UpdateArmNumEx(msg)
    end)

    --申请被批准通知
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgApplyBePassedPush, function(typeId, data)
        if GUIMgr:IsMenuOpen(JoinUnion._NAME) then
            JoinUnion.CloseAll()
            UnionInfoData.RequestData(function()
                UnionInfo.Show()
            end)
        else
            UnionInfoData.RequestData()
        end
		
		UnionCardData.RequestData(0)
    end)
    --申请被拒绝通知
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgApplyBeRejectedPush, function(typeId, data)
		SelfApplyData.RequestData()
    end)

    --新玩家申请通知
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgNewApplyPush, function(typeId, data)
		FloatText.Show(TextMgr:GetText(Text.union_new_apply))
		UnionApplyData.RequestData()
    end)
    --玩家取消申请通知
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCancelApplyPush, function(typeId, data)
		FloatText.Show(TextMgr:GetText(Text.union_apply_cancel))
		UnionApplyData.RequestData()
    end)
    --被开除联盟通知
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgBeFiredPush, function(typeId, data)
		FloatText.Show(TextMgr:GetText(Text.union_expel))
		UnionInfoData.RequestData()
		SelfApplyData.RequestData()
    end)
    --盟友加速帮助后的push消息
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgAccelAssistRefreshPush, function(typeId, data)
		local msg = GuildMsg_pb.MsgAccelAssistRefreshPush()
		msg:ParseFromString(data)
		if msg.tech ~= nil and msg.tech.techid > 0 then
			Laboratory.RefreshTech(msg.tech)
		end
		if msg.build ~= nil and msg.build.uid > 0 then
			maincity.UpdateBuildInMsg(msg.build)
		end
    end)
    --职位变动push
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgPositionChangedPush, function(typeId, data)
		FloatText.Show(TextMgr:GetText(Text.union_level_change))
		UnionInfoData.RequestData()
    end)
    --权限变动push
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgPrivilegeChangedPush, function(typeId, data)
		FloatText.Show(TextMgr:GetText(Text.union_power_change))
		UnionInfoData.RequestData()
    end)
    --盟友新发起加速帮助时向其他盟友push
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgNewAccelAssistPush, function(typeId, data)
		UnionHelpData.RequestData()
    end)
	--联盟礼包数量push
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgNewGuildChestPush, function(typeId, data)
		--FloatText.Show(TextMgr:GetText(Text.union_power_change))
		local msg = GuildMsg_pb.MsgNewGuildChestPush()
		msg:ParseFromString(data)
		UnionInfoData.UpdateUnionGiftCountData(msg.num)
    end)
    --联盟解散push
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildDissolvePush, function(typeId, data)
        if UnionInfoData.HasUnion() then
            UnionInfoData.RequestData()
        else
            UnionApplyData.RequestData()
        end
    end)
    --联盟解散告警push
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildDissolveWarningPush, function(typeId, data)
		UnionInfoData.RequestData()
    end)
    --联盟解散取消push
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildDissolveCancelPush, function(typeId, data)
		UnionInfoData.RequestData()
    end)
    --联盟矿同步
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildMineRefreshPush, function(typeId, data)
		UnionBuildingData.RequestData(nil, true)
    end)

	-----------------------------------Moba------------------------------------------
	--Moba:集结创建Push
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGatheStartPush, function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaGatheStartPush()
		msg:ParseFromString(data)	    
        local tab = MobaUnionWar.GetMassTroopTab()
        if tab ~= nil then
            tab:AddItem4Push(msg.guild,msg.gather)
        end
        local index = msg.guild == MobaMainData.GetTeamID() and 1 or 2
		MobaMain.MassTotlaNum[index] = MobaMain.MassTotlaNum[index] + 1
		MobaMain.UpdateMassBtn()
        print(index,MobaMain.MassTotlaNum[index],MobaMain.GetPreMassTotalNum()[index])
    end)
    --Moba:集结取消push
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGatheEndPush, function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaGatheEndPush()
		msg:ParseFromString(data)	    
        local tab = MobaUnionWar.GetMassTroopTab()
        if tab ~= nil then
            print(msg.guild,msg.charid)
            tab:RemoveItem4Push(msg.guild,msg.charid)
        end
        local index = msg.guild ==  MobaMainData.GetTeamID() and 1 or 2
		MobaMain.MassTotlaNum[index] = MobaMain.MassTotlaNum[index] - 1
		MobaMain.UpdateMassBtn()
        print(index,MobaMain.MassTotlaNum[index],MobaMain.GetPreMassTotalNum()[index])
    end)   
 
	 --Moba:集结遣散push
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGatherCancelJoinPush, function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaGatherCancelJoinPush()
		msg:ParseFromString(data)	    
        local tab = MobaUnionWar.GetMassTroopTab()
        if tab ~= nil then
            tab:UpdateDetail(msg.charid)
        end
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaBuildStatusPush, function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaBuildStatusPush()
		msg:ParseFromString(data)	 
		MobaTileInfo.DisposeMobaBuildStatusPush(msg)
		if GUIMgr:IsMenuOpen("MobaWarZoneMap") then
		    MobaWarZoneMap.Refresh()
        end
	end)

	
	------------------------------------------------------------
	
	----------------------------------Guild-Moba------------------------------------------
	--Moba:集结创建Push
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGatheStartPush, function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaGatheStartPush()
		msg:ParseFromString(data)	    
        local tab = MobaUnionWar.GetMassTroopTab()
        if tab ~= nil then
            tab:AddItem4Push(msg.guild,msg.gather)
        end
        local index = msg.guild == MobaMainData.GetTeamID() and 1 or 2
		GuildWarMain.MassTotlaNum[index] = GuildWarMain.MassTotlaNum[index] + 1
		GuildWarMain.UpdateMassBtn()
        print(index,GuildWarMain.MassTotlaNum[index],GuildWarMain.GetPreMassTotalNum()[index])
    end)
    --Moba:集结取消push
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGatheEndPush, function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaGatheEndPush()
		msg:ParseFromString(data)	    
        local tab = MobaUnionWar.GetMassTroopTab()
        if tab ~= nil then
            print(msg.guild,msg.charid)
            tab:RemoveItem4Push(msg.guild,msg.charid)
        end
        local index = msg.guild ==  MobaMainData.GetTeamID() and 1 or 2
		GuildWarMain.MassTotlaNum[index] = GuildWarMain.MassTotlaNum[index] - 1
		GuildWarMain.UpdateMassBtn()
        print(index,GuildWarMain.MassTotlaNum[index],GuildWarMain.GetPreMassTotalNum()[index])
    end)   
 
	 --Moba:集结遣散push
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGatherCancelJoinPush, function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaGatherCancelJoinPush()
		msg:ParseFromString(data)	    
        local tab = MobaUnionWar.GetMassTroopTab()
        if tab ~= nil then
            tab:UpdateDetail(msg.charid)
        end
	end)

	--打飞
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaBeatAwayPush, function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaBeatAwayPush()
		msg:ParseFromString(data)	    
		local myBasePos = msg.homeinfo.data.pos
		GuildWarMain.LookAt(myBasePos.x, myBasePos.y,true)
		MobaMainData.GetData().pos.x = myBasePos.x
		MobaMainData.GetData().pos.y = myBasePos.y
		MobaMainData.RequestData()
	end)	
	------------------------------------------------------------

    --集结创建Push
	LuaNetwork.RegisterPush(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGatheStartPush, function(typeId, data)
		local msg = HeroMsg_pb.MsgGatheStartPush()
		msg:ParseFromString(data)	    
        local tab = UnionWar.GetMassTroopTab()
        if tab ~= nil then
            tab:AddItem4Push(msg.guild,msg.gather)
        end
        local index = msg.guild == UnionInfoData.GetData().guildInfo.guildId and 1 or 2
		MainCityUI.MassTotlaNum[index] = MainCityUI.MassTotlaNum[index] + 1
		MainCityUI.UpdateMassBtn()
        print(index,MainCityUI.MassTotlaNum[index],MainCityUI.GetPreMassTotalNum()[index])
    end)
    --集结取消push
	LuaNetwork.RegisterPush(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGatheEndPush, function(typeId, data)
		local msg = HeroMsg_pb.MsgGatheEndPush()
		msg:ParseFromString(data)	    
        local tab = UnionWar.GetMassTroopTab()
        if tab ~= nil then
            print(msg.guild,msg.charid)
            tab:RemoveItem4Push(msg.guild,msg.charid)
        end
        local index = msg.guild == UnionInfoData.GetData().guildInfo.guildId and 1 or 2
		MainCityUI.MassTotlaNum[index] = MainCityUI.MassTotlaNum[index] - 1
		MainCityUI.UpdateMassBtn()
        print(index,MainCityUI.MassTotlaNum[index],MainCityUI.GetPreMassTotalNum()[index])
    end)   
    --集结遣散push
	LuaNetwork.RegisterPush(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGatherCancelJoinPush, function(typeId, data)
		local msg = HeroMsg_pb.MsgGatherCancelJoinPush()
		msg:ParseFromString(data)	    
        local tab = UnionWar.GetMassTroopTab()
        if tab ~= nil then
            tab:UpdateDetail(msg.charid)
        end
    end)   
    --Bufff
    LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgFreshBuffPush, function(typeId, data)
        local msg = ClientMsg_pb.MsgFreshBuffPush()
        msg:ParseFromString(data)
		print("buff push" )
		BuffData.UpdateData(msg.buffs.data)
		MobaBuffData.UpdateData(msg.buffs.mobaData)
		MobaBuffData.UpdateData(msg.buffs.guildMobaData)
		--guildMobaData
		MainCityUI.CheckHotTime()
    end)
    --TipsPush
    LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgNoticeTipsPush, function(typeId, data)
    	local msg = ClientMsg_pb.MsgNoticeTipsPush()
    	msg:ParseFromString(data)
		print("tip push" ,msg.tipId, msg.format,msg.content,msg.moba,GUIMgr:IsMenuOpen("MobaMain"))
		
		Global.DumpMessage(msg , "d:/noticeTips.lua")
		if msg.moba then
			if GUIMgr:IsMenuOpen("MobaMain") or GUIMgr:IsMenuOpen("GuildWarMain") then
				Notice_Tips.ShowTips(msg)
			end 
		else
			if not (GUIMgr:IsMenuOpen("MobaMain") or GUIMgr:IsMenuOpen("GuildWarMain")) then
				Notice_Tips.ShowTips(msg)
			end 
		end 
    end)
	--NoticePush
    LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgNoticeScrollPush, function(typeId, data)
    	local msg = ClientMsg_pb.MsgNoticeScrollPush()
    	msg:ParseFromString(data)
		print("tip push1 " , msg.format,msg.content)
		if msg.moba then
			if GUIMgr:IsMenuOpen("MobaMain") or GUIMgr:IsMenuOpen("GuildWarMain") then
				Notice_Tips.ShowNotice(msg)
			end 
		else
			if not (GUIMgr:IsMenuOpen("MobaMain") or GUIMgr:IsMenuOpen("GuildWarMain")) then
				Notice_Tips.ShowNotice(msg)
			end 
		end 
    end)
    --挂机任务红点
    LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgOnlineTaskCompletePush, function(typeId, data)
    	local msg = ClientMsg_pb.MsgOnlineTaskCompletePush()
    	msg:ParseFromString(data)
        MilitaryActionData.RequestData()
    end)    
	
	--联盟资源申请列表变化push;
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildResApplyChangedPush, function(typeId, data)
		local msg = GuildMsg_pb.MsgGuildResApplyChangedPush()
    	msg:ParseFromString(data)
		UnionResourceRequestData.RequestData()
    end)
    --管制区被打了通知Push
	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgClientNotifyInfoPush, function(typeId, data)
    	local msg = ClientMsg_pb.MsgClientNotifyInfoPush()
    	msg:ParseFromString(data)	  
    	if msg.notify == ClientMsg_pb.ClientNotifyType_ThrowoutCtrZone then
            if GUIMgr.Instance:IsMenuOpen("WorldMap") then
                print("MsgClientNotifyInfoPush",msg.notify)
                Global.DisposeRestrictAreaNotify()
            elseif maincity.isInMainCity() then
                Global.DisposeRestrictAreaNotify()--RestrictAreaNotify()
            else
                return
            end
		elseif msg.notify == ClientMsg_pb.ClientNotifyType_HomeSeBurn then
			--MainCityUI.RequestNotifyInfoRequest()
			--NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_HomeSeBurn)
			NotifyInfoData.OnNotifyPush(msg.notify)
			MainCityUI.MainCityUIActiveNotify()
		elseif  msg.notify == ClientMsg_pb.ClientNotifyType_JoinGuild then
			NotifyInfoData.OnNotifyPush(msg.notify)
			print("on push")
			MainCityUI.CheckAndRequestNotfy()
			
			
			
			
			--[[MainCityUI.MainCityUIJoinUnionNotify(function(leaderInfo)
				print("request notu")
				NotifyInfoData.RequestNotifyInfo(ClientMsg_pb.ClientNotifyType_JoinGuild , function()
					print("nionGuide.Show(")
					UnionGuide.Show(leaderInfo , true)
				end)
			end)]]
		elseif msg.notify == ClientMsg_pb.ClientNotifyType_GuildLog then
			print("on ClientNotifyType_GuildLog")
			NotifyInfoData.OnNotifyPush(msg.notify)
		elseif msg.notify == ClientMsg_pb.ClientNotifyType_OccupyContest then
			print("on ClientNotifyType_OccupyContest")
			NotifyInfoData.OnNotifyPush(msg.notify)
		elseif msg.notify == ClientMsg_pb.ClientNotifyType_TimedGiftPack then
			NotifyInfoData.OnNotifyPush(msg.notify)
    	elseif msg.notify == ClientMsg_pb.ClientNotifyType_HomeAtkTrans then
    	    MessageBox.Show(TextMgr:GetText(Text.DefenceNumber_7))
        end
		
    end)                
	
	--主城受攻击推送
	LuaNetwork.RegisterPush(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgFreshBuildPush, function(typeId, data)
		local msg = BuildMsg_pb.MsgFreshBuildPush()
    	msg:ParseFromString(data)
		maincity.RefreshBuild(msg.build.buildList)
		BuildingData.UpdateHomeFailTime(msg)
    end)
	--监狱刷新推送
	LuaNetwork.RegisterPush(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonFreshPush, function(typeId, data)
	    JailInfoData.RequestData()
    end)
	LuaNetwork.RegisterPush(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonCommanderFreshPush, function(typeId, data)
	    MainData.RequestCommanderInfo()
    end)
	--主城位置被转移推送
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.HomeTranslatePush, function(typeId, data)
		local msg = MapMsg_pb.HomeTranslatePush()
    	msg:ParseFromString(data)
    	local tileMsg = msg.homeinfo
        WorldMapData.SetMyBaseTileData(tileMsg)
    	if GUIMgr.Instance:IsMenuOpen("WorldMap") then
            WorldMapMgr.Instance:SetSEntryData(tileMsg:SerializeToString(), tileMsg.data.pos.x, tileMsg.data.pos.y)
            local myBasePos = MapInfoData.GetMyBasePos()
            WorldMap.LookAt(myBasePos.x, myBasePos.y)
        end
    end)	
    
   	--击杀叛军刷新
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MonsterKillFreshPush, function(typeId, data)
		local msg = MapMsg_pb.MonsterKillFreshPush()
    	msg:ParseFromString(data)
        if not RebelWantedData.HasRebelData(msg.level) then
            RebelWantedData.RequestData()
        end
    end)
    
    LuaNetwork.RegisterPush(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgUserArmyChangePush, function(typeId, data)
    	if GUIMgr.Instance:IsMenuOpen("MainCityUI") and not GUIMgr.Instance:IsMenuOpen("Barrack") then
    		Barrack.RequestArmNum()
    	end
    end)
    
    LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildTechRefreshPush, function(typeId, data)
    	UnionTechData.RequestData()
    end)
    
    LuaNetwork.RegisterPush(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgEquipRefreshPush, function(typeId, data)
    	local msg = ItemMsg_pb.MsgEquipRefreshPush()
    	msg:ParseFromString(data)
    	FloatText.Show(TextMgr:GetText("equip_forge_complete") , Color.white)
    	ItemListData.UpdateEquip(msg.equipInfo)
    end)
    
	--掠夺资源push
	LuaNetwork.RegisterPush(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgFreshDayRobResPush, function(typeId, data)
    	local msg = ItemMsg_pb.MsgFreshDayRobResPush()
    	msg:ParseFromString(data)
		--Global.DumpMessage(msg , "d:/dailyrob.lua")
		print(msg.value)
    	MainData.UpdateDailyRob(msg.value)
    end)
	
    LuaNetwork.RegisterPush(Category_pb.Vip, VipMsg_pb.VipTypeId.MsgVipLevelChangedPush, function(typeId, data)
    	local msg = VipMsg_pb.MsgVipLevelChangedPush()
    	msg:ParseFromString(data)
    	VipData.SetLevelUpMsg(msg)
    end)
	
	
	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgFreshRaceValuePush, function(typeId, data)
    	local msg = ClientMsg_pb.MsgFreshRaceValuePush()
    	msg:ParseFromString(data)	  
		RaceData.UpdateRaceValue(msg.actId, msg.value)
    end)     
	
	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgRedNoticePush, function(typeId, data)
    	local msg = ClientMsg_pb.MsgRedNoticePush()
    	msg:ParseFromString(data) 
    	RaceData.RequestData(true)
    end)
	
	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgDailyConsumeRewardPush, function(typeId, data)
		--MainCityUI.SetActivityRedPoint()
		Welfare_Template1Data.RequestDailyConsume(function() WelfareData.UpdateUncollectedRewards(ActivityData.GetActivityIdByTemplete(306)) end)
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgDailyRechargeRewardPush, function(typeId, data)
		--MainCityUI.SetActivityRedPoint()
		Welfare_Template1Data.RequestDailyRecharge(function() WelfareData.UpdateUncollectedRewards(ActivityData.GetActivityIdByTemplete(307)) end)
    end)
    
    LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgAccumulateRechargeRewardPush, function(typeId, data)
		--MainCityUI.SetActivityRedPoint()
		Welfare_Template1Data.RequestAccumulateRecharge(function() WelfareData.UpdateUncollectedRewards(ActivityData.GetActivityIdByTemplete(305)) end)
    end)
	
    LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgAccumulateConsumeRewardPush , function(typeId, data)
		--MainCityUI.SetActivityRedPoint()
		Welfare_Template1Data.RequestAccumulateConsume()
    end)
	
	LuaNetwork.RegisterPush(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatFreshFlagNotify, function(typeId, data)
		local msg = ChatMsg_pb.MsgChatFreshFlagNotify()
    	msg:ParseFromString(data) 
		print("chat push")
		MainCityUI.RequestChat(nil)
		UnionMessageData.RequestUnionMessageChat()
		Chat.CheckGroupChatData()
		
		--[[for i=1, #msg.channel.chanel , 1 do
			if msg.channel.chanel[i] == ChatMsg_pb.chanel_private then
				MainCityUI.RequestChat(ChatMsg_pb.chanel_private)
			else
				MainCityUI.RequestChat(nil)
				
			end
		end]]
		
		--[[if msg.channel.chanel == ChatMsg_pb.chanel_private then
			MainCityUI.RequestChat(ChatMsg_pb.chanel_private)
		else
			MainCityUI.RequestChat(nil)
		end]]
		--先处理为拉取全部频道
		--for i=1 , #data.channel.chanel , 1 do
			
		--end
    end)
	
	--聊天讨论组推送
	LuaNetwork.RegisterPush(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatDiscNeedFreshPush, function(typeId, data)
		local msg = ChatMsg_pb.MsgChatDiscNeedFreshPush()
    	msg:ParseFromString(data) 
		print("chat group push")
		Chat.OnChatGroupPush()
    end)
	
	
	--联盟领地概况推送
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGuildOccupyContestPush, function(typeId, data)
		local msg = MapMsg_pb.MsgGuildOccupyContestPush()
    	msg:ParseFromString(data)
		UnionInfoData.RequestOccupyFieldInfo(1 , true)
    end)	
	
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgSiegeMonsterPush, function(typeId, data)
		RebelArmyAttackData.RequestSiegeMonsterInfo(function(msg)
			--[[
	    	if (msg.isOpen == false and msg.lastStartTime - (48*3600) <= Serclimax.GameTime.GetSecTime()) or msg.isOpen == true then
	    		MainCityUI.SetActivityBtn(true)
	    	else
	    		MainCityUI.SetActivityBtn(false)
	    	end
	    	--]]
		end)		
	end)
	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgMonsterSurroundBattleResultPush, function(typeId, data)
		local msg = BattleMsg_pb.MsgMonsterSurroundBattleResultPush()
		msg:ParseFromString(data)
		RebelSurroundData.DisposeBattlePush(msg)
	end)
	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgNemesisBattleResultPush, function(typeId, data)
		local msg = BattleMsg_pb.MsgNemesisBattleResultPush()
		msg:ParseFromString(data)
		RebelSurroundNew.ShowBattle(msg)
	end)

	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgChapterPvPStartBattleResultPush, function(typeId, data)
		local msg = BattleMsg_pb.MsgChapterPvPStartBattleResultPush()
		msg:ParseFromString(data)
		BattleMove.ShowPVPBattle4PVE(msg,flase,nil,function()
			MainCityUI.SetJumpMenu("ChapterSelectUI")
		end)
	end)



	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgNemesisPathStartPush, function(typeId, data)
		local msg = BattleMsg_pb.MsgNemesisPathStartPush()
		msg:ParseFromString(data)
		RebelSurroundNewData.RequestNemesisInfo()
	end)

	-- 要塞状态更新
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortActStatusPush, FortsData.OnFortStatusUpdate)

	-- 限时礼包
	LuaNetwork.RegisterPush(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgFreshGiftTimeLimitPush, function()
        --store.UpdateTimedGiftPack
        NotifyInfoData.OnNotifyPush(ClientMsg_pb.ClientNotifyType_TimedGiftPack)
		GiftPackData.RequestData(ShopMsg_pb.IAPGoodType_GiftTimeLimit,function()
			MainCityUI.UpdateLimitedTime();
		end)
    end)

	-- 政府被占领
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentRulingPush, GovernmentData.OnGovernmentRulingPush)
		
	-- 炮台被占领
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretRulingPush, GovernmentData.OnTurretRulingPush)

	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretLogPush, function(typeId, data)
		MainCityUI.OnTurretHurtNorify()
	end)

	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgTurretAtkPush, function(typeId, data)
		local msg = MapMsg_pb.MsgTurretAtkPush()
		msg:ParseFromString(data)
		WorldMap.OnTurretAttackPush(msg)
	end)

	-- 联盟邀请
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildInviteMemberPush, function()
		AllianceInvitesData.RequestInvites()
	end)

	-- 联盟救援
	LuaNetwork.RegisterPush(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCompensateRefreshPush, function()
		print("-----MsgCompensateRefreshPush------")
		UnionHelpData.RequestGuildMemHelp()
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgStrongholdRulingPush, StrongholdData.OnStrongholdRulingPush)
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortressRulingPush, FortressData.OnFortressRulingPush)
	
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgStrongholdContendStartPush, function()
		StrongholdData.ReqAllStrongholdInfoData()
		MainCityUI.UpdateStrongholdIcon(true)
	end)
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortressContendStartPush, function()
		FortressData.ReqAllFortressInfoData()
		MainCityUI.UpdateFortIcon(true)
	end)
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgStrongholdContendEndPush, function()
		StrongholdData.ReqAllStrongholdInfoData()
		MainCityUI.UpdateStrongholdIcon(false)
	end)
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortressContendEndPush, function()
		FortressData.ReqAllFortressInfoData()
		MainCityUI.UpdateFortIcon(false)
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgWorldCityNotifyPush, function()
		WorldCityData.RequestData()
	end)
	
	
	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgTriggerBagPush, function(typeId, data)
		local msg = ActivityMsg_pb.MsgTriggerBagPush()
		msg:ParseFromString(data)
		WelfareData.UpdateTriggerBag(msg)
	end)

	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgUserUpRankRewardPush, function(typeId, data)
		ActivityLevelRaceData.RequestData(true , function()
			if GUIMgr:FindMenu("UpdateUI") ~= nil then
				LevelRace.UpdateUI()
			end
		end)
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgSlaughterFreshPush, function(typeId, data)
		local msg = ActivityMsg_pb.MsgSlaughterFreshPush()
		msg:ParseFromString(data)
		ActiveSlaughterData.OnMsgSlaughterFreshPush(msg)
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaBeChallenged, function(typeId, data)
		if GUIMgr.Instance:IsMenuOpen("BattleRank") then
			BattleRank.ShowHistoryListRed(true)
		end 
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgClimbBattleResultPush, function(typeId, data)
		local msg = BattleMsg_pb.MsgClimbBattleResultPush()
		
		msg:ParseFromString(data)


		ClimbData.RefrushCurServerLevelID(msg.stage)
		ClimbData.RefrushQuestData(msg.quest)
		ClimbData.RefrushClimbScore(msg.climbScore)
		--print("WEEEEEEEEEEEEEEEEEE",msg.stage)
		--Global.DumpMessage(msg)
		MainCityUI.UpdateRewardData(msg.fresh)
		if msg.battleResult ~= nil then
			if msg.battleResult.winteam ~= 1 then
				Climb.HadReward = math.max(0,Climb.HadReward -1) 
			end	
			local br_msg = {}
			br_msg.code = 0
			br_msg.battleResult = msg.battleResult
			BattleMove.ShowPVPBattle4PVE(br_msg,true,function()
				local mainui = "MainCityUI"
				local posx = 0
				local posy = 0
				if GUIMgr:FindMenu("WorldMap") ~= nil then
					mainui = "WorldMap"
					local curpos = WorldMap.GetCenterMapCoord()
					posx , posy = WorldMap.GetCenterMapCoord()
				end
				Global.SetBattleReportBack(mainui , "Climb" , posx , posy)	
			end,function() 
				print("report end function")
				local battleBack = Global.GetBattleReportBack()
				if battleBack.MainUI == "WorldMap" then
					MainCityUI.ShowWorldMap(battleBack.PosX , battleBack.PosY, true , function()
						if battleBack.Menu ~= nil then
							if battleBack.Menu == "Climb" then
								Climb.Show()
							end
						end
					end)
				else
					if battleBack.Menu ~= nil then
						if battleBack.Menu == "Climb" then
							Climb.Show()
						end
					end
				end	
			end,function()
				if GUIMgr:IsMenuOpen("Climb") then
					Climb.RefrushHadReward()
					Climb.RefrushMap(nil,function()
						Climb.RefrushHadReward()
					end)
				end
            end)
		end
	end)	

	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaBattleResultPush, function(typeId, data)
		local resultMsg = BattleMsg_pb.MsgArenaBattleResultPush()
		resultMsg:ParseFromString(data)
		local battleResult = resultMsg.battleResult
		if battleResult ~= nil then
		    local userMsg = battleResult.input.user.team2[1].user
		    if userMsg.charid == 0 then
                userMsg.name = TextMgr:GetText(Text.Arena_robot_name)
                userMsg.face = 666
            end
            local msg ={
                content = "Mail_attack_actmonster_win_Desc",
                misc =
                {
                    recon ={},
                    robres ={},
                    traderes ={},
                    heros ={},
                    train ={},
                    attachShow ={},
                    siegeShow ={},
                    reportid = 8602,
                    source ={},
                    target ={},
                    fortOccupy ={},
                    result ={},
                }        
            }
            msg.misc.source.guildBanner = ""
            msg.misc.target.guildBanner = ""
            msg.misc.result = battleResult


            --设置战斗返回时的界面显示：
            local mainui = "MainCityUI"
            local posx = 0
            local posy = 0
            if GUIMgr:FindMenu("WorldMap") ~= nil then
                mainui = "WorldMap"
                local curpos = WorldMap.GetCenterMapCoord()
                posx , posy = WorldMap.GetCenterMapCoord()
            end
            Global.SetBattleReportBack(mainui , "BattleRank" , posx , posy)

			local callback =  function()
                print("report end function")
                local battleBack = Global.GetBattleReportBack()
                if battleBack.MainUI == "WorldMap" then
                    MainCityUI.ShowWorldMap(battleBack.PosX , battleBack.PosY, false)
                end

                if battleBack.Menu ~= nil then
                    if battleBack.Menu == "BattleRank" then
                        BattleRank.Show(battleResult.winteam == 1)
                    end
                end
            end
            --启动战报播放
			
		    if Global.GetSupportPlayBack() then
				PVP_Rewards_Skip.Show(msg,mailSubtype,battleResult,callback,function()
					if GUIMgr:IsMenuOpen("BattleRank") then
						BattleRank.ForceSetWin(battleResult.winteam == 1)
						BattleRank.Start()
					end
				end)
			else
				Global.CheckBattleReportEx(msg ,mailSubtype ,callback)
			end	

        end
    end)

	LuaNetwork.RegisterPush(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaFreshEnemyPush, function(typeId, data)
	    ArenaInfoData.RequestData(true)
    end)

	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgContinuousRechargeRewardPush, function(typeId, data)
		local msg = ActivityMsg_pb.MsgContinuousRechargeRewardPush()
		msg:ParseFromString(data)
		ContinueRechargeData.RequestData(msg.activityId, function()
			WelfareAll.RefreshTab()
		end)
	end)

	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgWarLossScorePush, function(typeId, data)
		local msg = ActivityMsg_pb.MsgWarLossScorePush()
		msg:ParseFromString(data)
		WarLossData.UpdateScore(msg.score)
	end)

	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterEnergyPush, function(typeId, data)
		local msg = ClientMsg_pb.MsgCharacterEnergyPush()
		msg:ParseFromString(data)
		MainData.UpdateEnergyPush(msg)
	end)

	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCityGuardPush, function(typeId, data)
	    DefenseData.RequestData()
	end)

	--回收据点
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgStrongholdRecyclingPush, function(typeId, data)
		StrongholdData.ReqAllStrongholdInfoData()
	end)

	--回收要塞
	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgFortressRecyclingPush, function(typeId, data)
		FortressData.ReqAllFortressInfoData()
	end)	


	LuaNetwork.RegisterPush(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentRecyclingPush, function(typeId, data)
		GovernmentData.ReqGoveInfoData()
		for i=1,4 do
			GovernmentData.ReqTurretInfoData(i)
		end			
	end)

	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgMilitaryRacePush, function(typeId, data)
		NewRaceData.RequestData()
	end)
	LuaNetwork.RegisterPush(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgMilitaryCouldLvUpPush, function(typeId, data)
		MilitaryRankData.RequestData()
	end)

	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaBookStartPush, function(typeId, data)
		MobaData.RequestMobaMatchInfo()
	end)
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaApplyStartPush, function(typeId, data)
		MobaData.RequestMobaMatchInfo()
	end)
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaRaidStartPush, function(typeId, data)
		MobaData.RequestMobaMatchInfo()
	end)
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaCancelPush, function(typeId, data)
		MessageBox.Show(TextMgr:GetText("ui_moba_148"))
		MobaData.RequestMobaMatchInfo()
	end)
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaResultPush, function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaResultPush()
		msg:ParseFromString(data)
		MobaData.SetMobaUserResult(msg)
		MainCityUI.UpdateRewardData(msg.fresh)
	end)
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaPickRoleDonePush, function(typeId, data)
		local msg = MobaMsg_pb.MsgMobaPickRoleDonePush()
		msg:ParseFromString(data)
		Mobaroleselect.UpdateInfo(msg)
		MobaData.UpdateRole(msg)
	end)
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaBuildBeAttackingPush, function(typeId, data)
		MobaMain.CheckHouseAndDoor()
	end)
	LuaNetwork.RegisterPush(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaBeatAwayPush, function(typeId, data)
        if Global.IsSlgMobaMode() then
            local msg = MobaMsg_pb.MsgMobaBeatAwayPush()
            msg:ParseFromString(data)
            local myBasePos = msg.homeinfo.data.pos
            MobaMain.LookAt(myBasePos.x, myBasePos.y,true)
            MobaMainData.GetData().pos.x = myBasePos.x
            MobaMainData.GetData().pos.y = myBasePos.y
            MobaMainData.RequestData()
        end
	end)
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaUserInitPush, function(typeId, data)
		print("--------------GuildMobaUserInitPushGuildMobaUserInitPush")
		if Global.GetMobaMode() == 2 then
            local msg = GuildMobaMsg_pb.GuildMobaUserInitPush()
			msg:ParseFromString(data)
			Global.ExeInitMap()
        end
	end)
	
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMsgMobaTeamScorePush, function(typeId, data)
		if Global.GetMobaMode() == 2 then
			
            local msg = GuildMobaMsg_pb.GuildMsgMobaTeamScorePush()
			msg:ParseFromString(data)
			if GUIMgr:IsMenuOpen("GuildWarMain") then
				GuildWarMain.UpdateScore(msg)
			end 
        end
	end)
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaResultPush, function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaResultPush()
		msg:ParseFromString(data)
		UnionMobaActivityData.SetMobaUserResult(msg)
		MainCityUI.UpdateRewardData(msg.fresh)
	end)
	
	LuaNetwork.RegisterPush(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaResultPush, function(typeId, data)
		local msg = GuildMobaMsg_pb.GuildMobaResultPush()
		msg:ParseFromString(data)
		UnionMobaActivityData.SetMobaUserResult(msg)
		MainCityUI.UpdateRewardData(msg.fresh)
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgFaceDrawListPush, function(typeId, data)
		print("------------MsgFaceDrawListPush----------")
		local msg = ActivityMsg_pb.MsgFaceDrawListPush()
		msg:ParseFromString(data)
		if msg.actid > 0 then
			FaceDrawData.RequestData(function()
				if GUIMgr.Instance:IsMenuOpen("MainCityUI") then
					NewActivityBanner.Show()
				end
			end)
		end
	end)
	
	LuaNetwork.RegisterPush(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgGoldLotteryRechargePush, function(typeId, data)
		
	end)

	GUIMgr:SendDataReport("efun", "app_opened")
end
--场景切换通知
function OnLevelWasLoaded(level)
    Time.timeSinceLevelLoad = 0
end

local isShow = false

function ShowExit()
	isShow = true
	MessageBox.Show(TextMgr:GetText("common_hint6"), function()
		isShow = false
		UnityEngine.Application.Quit()
	end,
	function()
		isShow = false
	end)
end

function ExitGame()
	local topMenu = GUIMgr:GetTopMenuOnRoot()
	local isInGuide = ActivityGrow.IsInGuide() or Tutorial.IsForcingTutorial()
	if isInGuide or (topMenu ~= nil and (topMenu.name == "WinLose" or topMenu.name == "Starwars")) or GUIMgr:IsTopMenuOpen("loading") then
		return
	end
	if topMenu == nil or topMenu.name == "MainCityUI" or topMenu.name == "WorldMap" then
		GroupChatData.SaveGroupLastChat()
		ChatData.SaveChatList()
		
		if not isShow then
			if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_quick or
			GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_qihu then
				GUIMgr:Exit()
			else
				ShowExit()
			end
		end
	elseif topMenu.name == "InGameUI" then
		local skip = topMenu:GetModuleTable().transform:Find("Btn_skip").gameObject
		if skip.activeInHierarchy then
			skip:SendMessage("OnClick")
		end
		local restart = topMenu:GetModuleTable().transform:Find("Container/Btn_retreat").gameObject
		if restart.activeInHierarchy then
			restart:SendMessage("OnPress", false)
		end
	elseif topMenu.name == "pause" then
		local continue = topMenu:GetModuleTable().transform:Find("bg_pause/bg/btn_continue").gameObject
		if continue.activeInHierarchy then
			continue:SendMessage("OnClick")
		end
	elseif topMenu.name == "PVP_SLG" then
		local skip = topMenu:GetModuleTable().transform:Find("Container/bg_frane/btn_skip").gameObject
		if skip.activeInHierarchy then
			skip:SendMessage("OnClick")
		end
	elseif topMenu.name == "BattlefieldReport" then
		local close = topMenu:GetModuleTable().transform:Find("Container/bg_frane/btn_close").gameObject
		if close.activeInHierarchy then
			close:SendMessage("OnClick")
		end
	else
		if topMenu:GetModuleTable().HideAll then
			topMenu:GetModuleTable().HideAll()
		elseif topMenu:GetModuleTable().CloseAll then
			topMenu:GetModuleTable().CloseAll()
		else
			GUIMgr:CloseMenu(topMenu.name)
		end
	end
end
