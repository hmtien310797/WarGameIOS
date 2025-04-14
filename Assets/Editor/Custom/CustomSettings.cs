using UnityEngine;
using System;
using System.Collections.Generic;
using LuaInterface;

using BindType = ToLuaMenu.BindType;
using System.Reflection;

public static class CustomSettings
{
    public static string saveDir = Application.dataPath + "/Source/Generate/";
    public static string luaDir = Application.dataPath + "/Lua/";
    public static string toluaBaseType = Application.dataPath + "/ToLua/BaseType/";
    public static string toluaLuaDir = Application.dataPath + "/ToLua/Lua";

    //导出时强制做为静态类的类型(注意customTypeList 还要添加这个类型才能导出)
    //unity 有些类作为sealed class, 其实完全等价于静态类
    public static List<Type> staticClassTypes = new List<Type>
    {
        typeof(UnityEngine.Application),
        typeof(UnityEngine.Time),
        typeof(UnityEngine.Screen),
        typeof(UnityEngine.SleepTimeout),
        typeof(UnityEngine.Input),
        typeof(UnityEngine.Resources),
        typeof(UnityEngine.Physics),
        typeof(UnityEngine.RenderSettings),
        typeof(UnityEngine.QualitySettings),
        typeof(UnityEngine.GL),
        //typeof(UnityEngine.SystemInfo),
    };

    //附加导出委托类型(在导出委托时, customTypeList 中牵扯的委托类型都会导出， 无需写在这里)
    public static DelegateType[] customDelegateList =
    {
        _DT(typeof(Action)),
        _DT(typeof(UnityEngine.Events.UnityAction)),
    };

    //在这里添加你要导出注册到lua的类型列表
    public static BindType[] customTypeList =
    {                
        //------------------------为例子导出--------------------------------
        //_GT(typeof(TestEventListener)),
        //_GT(typeof(TestAccount)),
        //_GT(typeof(Dictionary<int, TestAccount>)).SetLibName("AccountMap"),
        //_GT(typeof(KeyValuePair<int, TestAccount>)),    
        //_GT(typeof(TestExport)),
        //_GT(typeof(TestExport.Space)),
        //-------------------------------------------------------------------        
        _GT(typeof(Debugger)),                      

        /*_GT(typeof(DG.Tweening.DOTween)),
        _GT(typeof(DG.Tweening.Tween)).SetBaseType(typeof(System.Object)),
        _GT(typeof(DG.Tweening.Sequence)).AddExtendType(typeof(DG.Tweening.TweenSettingsExtensions)),
        _GT(typeof(DG.Tweening.Tweener)),
        _GT(typeof(DG.Tweening.LoopType)),
        _GT(typeof(DG.Tweening.PathMode)),
        _GT(typeof(DG.Tweening.PathType)),
        _GT(typeof(Component)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Transform)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Light)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Material)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Rigidbody)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Camera)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(AudioSource)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),        
        _GT(typeof(LineRenderer)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(TrailRenderer)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),  */ 
                                    
        _GT(typeof(Component)),
        _GT(typeof(Transform)),
        _GT(typeof(Material)),
        _GT(typeof(Light)),
        _GT(typeof(Rigidbody)),
        _GT(typeof(Camera)),
        _GT(typeof(AudioSource)),

        _GT(typeof(Behaviour)),
        _GT(typeof(MonoBehaviour)),
        _GT(typeof(GameObject)),
        //_GT(typeof(TrackedReference)),
        _GT(typeof(Application)),
        _GT(typeof(Physics)),
        _GT(typeof(Collider)),
        _GT(typeof(Time)),
        _GT(typeof(Texture)),
        _GT(typeof(Texture2D)),
        _GT(typeof(Shader)),
        _GT(typeof(Renderer)),
        _GT(typeof(WWW)),
        _GT(typeof(Screen)),
        _GT(typeof(CameraClearFlags)),
        _GT(typeof(AudioClip)),
        _GT(typeof(AssetBundle)),
        _GT(typeof(ParticleSystem)),
        _GT(typeof(AsyncOperation)).SetBaseType(typeof(System.Object)),
        _GT(typeof(LightType)),
        _GT(typeof(SleepTimeout)),
        _GT(typeof(Animator)),
        _GT(typeof(Input)),
        _GT(typeof(KeyCode)),
       // _GT(typeof(SkinnedMeshRenderer)),
        _GT(typeof(Space)),

        //_GT(typeof(MeshRenderer)),
        //_GT(typeof(ParticleEmitter)),
        //_GT(typeof(ParticleRenderer)),
        //_GT(typeof(ParticleAnimator)),

        _GT(typeof(BoxCollider)),
        //_GT(typeof(MeshCollider)),
        _GT(typeof(SphereCollider)),
       // _GT(typeof(CharacterController)),
       // _GT(typeof(CapsuleCollider)),

        _GT(typeof(Animation)),
        _GT(typeof(AnimationClip)).SetBaseType(typeof(UnityEngine.Object)),
        _GT(typeof(AnimationState)),
        _GT(typeof(AnimationBlendMode)),
        _GT(typeof(QueueMode)),
        _GT(typeof(PlayMode)),
        _GT(typeof(WrapMode)),

        _GT(typeof(QualitySettings)),
        _GT(typeof(RenderSettings)),
        _GT(typeof(SkinWeights)),
        _GT(typeof(RenderTexture)),

        _GT(typeof(Dictionary<string, string>)),
        _GT(typeof(KeyValuePair<string, string>)),

        _GT(typeof(System.Text.Encoding)),
        //unity
        _GT(typeof(PrimitiveType)),
        _GT(typeof(Debug)),
        _GT(typeof(UnityEngine.Random)),
        _GT(typeof(List<Vector3>)),
        _GT(typeof(PlayerPrefs)),
        _GT(typeof(List<EventDelegate>)),
        _GT(typeof(AnimatorOverrideController)),
        _GT(typeof(AnimationClipPair)),
        _GT(typeof(AnimationCullingType)),
        _GT(typeof(AnimatorUpdateMode)),
        _GT(typeof(AnimatorStateInfo)),
       // _GT(typeof(UISpriteAnimation)),
        _GT(typeof(TextMesh)),
        //_GT(typeof( UnityEngine.SystemInfo)),

        //itween
        _GT(typeof(iTween)),

        //单例
        _GT(typeof(GameVersion)),
        _GT(typeof(Main)),
        _GT(typeof(GameStateLogin)),
        _GT(typeof(GameStateLogin.EInitState)),
        _GT(typeof(GameStateBattle)),
        _GT(typeof(GameStateMain)),
        _GT(typeof(GameStateTutorial)),        
        _GT(typeof(GameStateSLGBattle)),
        _GT(typeof(GameStateNull)),
        _GT(typeof(ResourceUnload)),

        _GT(typeof(GuideManager)),
        _GT(typeof(GUIMgr)),
        _GT(typeof(SceneManager)),
        _GT(typeof(Controller)),
        _GT(typeof(Dictionary<int, Controller.MouseOrTouch>)),
        _GT(typeof(ResourceLibrary)),
        _GT(typeof(TextManager)),
        _GT(typeof(WorldMapMgr)),
          _GT(typeof(PreViewAnimation)),

        _GT(typeof(TextManager.LANGUAGE)),

        _GT(typeof(GameSetting)),
        _GT(typeof(GameSetting.ESavingType)),
        _GT(typeof(GameSetting.OptionData)),
        _GT(typeof(LuaNetwork)),
        _GT(typeof(CountDown)),
        _GT(typeof(AudioManager)),
        _GT(typeof(Serclimax.Utils)),
        _GT(typeof(UIAnimManager)),
        //_GT(typeof(Follow)),
        _GT(typeof(AssetBundleManager)),
        //_GT(typeof(HudManager)),
       // _GT(typeof(PlatformUtils)),
        _GT(typeof(List<UIAtlas>)),
        _GT(typeof(TiledMap)),
        _GT(typeof(Clishow.CsBatchMgr)),
        _GT(typeof(Mainland)),
        _GT(typeof(WebMediator)),
        _GT(typeof(PPGameLoginTool)),

        //sdk
        _GT(typeof(BuglyAgent)),
        
        //NGUI
        _GT(typeof(LuaBehaviour)),
        _GT(typeof(UICamera)),
        _GT(typeof(UICamera.MouseOrTouch)),
        _GT(typeof(UIRect)),
        _GT(typeof(UIRoot)),
        _GT(typeof(UIPanel)),
        _GT(typeof(UIWidget)),
        _GT(typeof(UIButton)),
        _GT(typeof(UIButton.State)),
        _GT(typeof(UILabel)),
        _GT(typeof(UITextList)),
        _GT(typeof(UISprite)),
        _GT(typeof(UITexture)),
        _GT(typeof(UISlider)),
        _GT(typeof(UIGrid)),
        _GT(typeof(UIScrollView)),
        _GT(typeof(UIScrollView.Movement)),
        _GT(typeof(UIScrollBar)),
        _GT(typeof(UIInput)),
        _GT(typeof(UIViewport)),
        _GT(typeof(UIToggle)),
        _GT(typeof(UIToggledObjects)),
        _GT(typeof(UICenterOnChild)),
        _GT(typeof(UICenterOnClick)),
        _GT(typeof(UITable)),
        _GT(typeof(UIWrapContent)),
        _GT(typeof(UIWidget.Pivot)),
        _GT(typeof(UIEventListener)),
        _GT(typeof(EventDelegate)),
        _GT(typeof(UITweener)),
        _GT(typeof(TweenScale)),
        _GT(typeof(TweenAlpha)),
        _GT(typeof(TweenColor)),
        _GT(typeof(TweenPosition)),
        _GT(typeof(TweenRotation)),
        _GT(typeof(TweenTransform)),
        _GT(typeof(TweenHeight)),
        _GT(typeof(UIPlayTween)),
        _GT(typeof(UIPlayAnimation)),
        _GT(typeof(NGUITools)),
        _GT(typeof(NGUIMath)),
        _GT(typeof(List<GameObject>)),
        _GT(typeof(List<Transform>)),

        _GT(typeof(UISliderOnChangeEvent)),
        _GT(typeof(UIHoldClick)),

        _GT(typeof(UITexture2GrayController)),
        _GT(typeof(UILabel2GrayController)),
        _GT(typeof(CustomSortUIGrid)),
        _GT(typeof(UISound)),
        _GT(typeof(TextEditor)),
        _GT(typeof(ParadeTableItemController)),
        _GT(typeof(AnimColltroller)),
        _GT(typeof(UIPressSelected)),
        _GT(typeof(Particle2D)),
        _GT(typeof(UIDragScrollView)),
        _GT(typeof(TypewriterEffect)),
        _GT(typeof(SpringPanelController)),
        _GT(typeof(UISpringPanel)),
        //_GT(typeof(UILimitClickTime)),
        

        
        //表格
        _GT(typeof(Serclimax.ScData)),
        _GT(typeof(Serclimax.ScTableMgr)),
        _GT(typeof(Serclimax.ScGlobalDataId)),
        _GT(typeof(Serclimax.ScGlobalData)),

        /*
        _GT(typeof(Serclimax.ScStaminaPriceData)),
        _GT(typeof(Serclimax.ScResourcePriceData)),
        _GT(typeof(Dictionary<int, Serclimax.ScResourcePriceData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScResourcePriceData>)),
        _GT(typeof(Serclimax.ScChapterData)),
        _GT(typeof(Dictionary<int, Serclimax.ScChapterData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScChapterData>)),
        _GT(typeof(Serclimax.ScBattleData)),
        _GT(typeof(Serclimax.ScTeamSlotData)),
        _GT(typeof(Dictionary<int, Serclimax.ScTeamSlotData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScTeamSlotData>)),
        _GT(typeof(Serclimax.ScStarConditionData)),
        _GT(typeof(Serclimax.Unit.ScUnitData)),
        _GT(typeof(Serclimax.Unit.ScUnitGroupData)),
        _GT(typeof(Serclimax.ScGodSkillData)),
        _GT(typeof(Serclimax.ScDropData)),
        _GT(typeof(Serclimax.ScDropShowData)),
        _GT(typeof(Dictionary<int, Serclimax.ScDropData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScDropData>)),
        _GT(typeof(Serclimax.ScItemData)),
        _GT(typeof(Serclimax.ScSlgBuffData)),
        _GT(typeof(Dictionary<int, Serclimax.ScSlgBuffData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScSlgBuffData>)),

        _GT(typeof(Serclimax.ScSlgBuffListData)),
        _GT(typeof(Dictionary<int, Serclimax.ScSlgBuffListData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScSlgBuffListData>)),

        _GT(typeof(Serclimax.ScVipData)),
        _GT(typeof(Serclimax.ScVipGiftData)),
        _GT(typeof(Serclimax.ScVipPrivilege)),
        _GT(typeof(Serclimax.ScFunctionData)),
        _GT(typeof(Serclimax.ScItemExchangeData)),
        _GT(typeof(Serclimax.Constants)),
        _GT(typeof(Serclimax.ScBuildingData)),
        _GT(typeof(Serclimax.ScBuildingUpdateData)),
        _GT(typeof(Serclimax.ScBuildingCoreData)),
        _GT(typeof(Serclimax.ScBuildingResourceData)),
        _GT(typeof(Serclimax.ScLandListData)),
        _GT(typeof(Serclimax.GuideInfoData)),
        _GT(typeof(Serclimax.ScGmData)),
        _GT(typeof(Dictionary<int, Serclimax.ScGmData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScGmData>)),
        _GT(typeof(Dictionary<string, string>)),
        _GT(typeof(KeyValuePair<string, string>)),

        _GT(typeof(Serclimax.Skill.ScSkillWeaponData)),
        _GT(typeof(Serclimax.ScBarrackData)),
        _GT(typeof(Dictionary<int, Serclimax.ScBarrackData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScBarrackData>)),

        _GT(typeof(Serclimax.ScSpeedUppriceData)),
        _GT(typeof(Dictionary<int, Serclimax.ScSpeedUppriceData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScSpeedUppriceData>)),


        _GT(typeof(Serclimax.ScBarrackBuildData)),
        _GT(typeof(Dictionary<int, Serclimax.ScBarrackBuildData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScBarrackBuildData>)),

        _GT(typeof(Serclimax.ScPlayerExpData)),

        _GT(typeof(Serclimax.ScHeroData)),
        _GT(typeof(Dictionary<int, Serclimax.ScHeroData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScHeroData>)),
        _GT(typeof(Serclimax.ScHeroExpData)),
        _GT(typeof(Serclimax.ScHeroStarUpData)),
        _GT(typeof(Serclimax.ScHeroGradeUpData)),
        _GT(typeof(Serclimax.ScBadgeData)),
        _GT(typeof(Serclimax.ScRulesData)),
        _GT(typeof(Serclimax.ScNeedTextData)),
        _GT(typeof(Serclimax.ScFightData)),
        _GT(typeof(Serclimax.ScCoefRuleData)),

        _GT(typeof(Serclimax.ScTechnologyDetailData)),
        _GT(typeof(Dictionary<int, Serclimax.ScTechnologyDetailData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScTechnologyDetailData>)),


        _GT(typeof(Serclimax.ScTechnologyCategoryData)),
        _GT(typeof(Dictionary<int, Serclimax.ScTechnologyCategoryData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScTechnologyCategoryData>)),

        _GT(typeof(Serclimax.ScBuildLaboratoryData)),
        _GT(typeof(Dictionary<int, Serclimax.ScBuildLaboratoryData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScBuildLaboratoryData>)),
        _GT(typeof(Serclimax.ScItemExchangeListData)),

        _GT(typeof(Serclimax.ScBonusFuncData)),


        _GT(typeof(Serclimax.ScSettingData)),
        _GT(typeof(Dictionary<int, Serclimax.ScSettingData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScSettingData>)),

        _GT(typeof(Serclimax.ScMissionData)),
        _GT(typeof(Serclimax.ScMissionTutorialData)),
        _GT(typeof(Serclimax.ScMailCfgData)),


        _GT(typeof(Serclimax.ScWareData)),
        _GT(typeof(Dictionary<int, Serclimax.ScWareData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScWareData>)),


        _GT(typeof(Serclimax.ScClinicData)),
        _GT(typeof(Dictionary<int, Serclimax.ScClinicData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScClinicData>)),


        _GT(typeof(Serclimax.ScWallData)),
        _GT(typeof(Dictionary<int, Serclimax.ScWallData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScWallData>)),

        _GT(typeof(Serclimax.ScCallUpData)),
        _GT(typeof(Dictionary<int, Serclimax.ScCallUpData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScCallUpData>)),

        _GT(typeof(Serclimax.ScParadeGroundData)),
        _GT(typeof(Dictionary<int, Serclimax.ScParadeGroundData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScParadeGroundData>)),

        _GT(typeof(Serclimax.ScRadarData)),
        _GT(typeof(Dictionary<int, Serclimax.ScRadarData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScRadarData>)),

        _GT(typeof(Serclimax.ScTradingPostData)),
        _GT(typeof(Dictionary<int,Serclimax.ScTradingPostData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScTradingPostData>)),

        _GT(typeof(Serclimax.ScResourceRuleData)),
        _GT(typeof(Serclimax.ScMonsterRuleData)),
        _GT(typeof(Serclimax.ScBasicSurfaceData)),
        _GT(typeof(Serclimax.ScArtSettingData)),
        _GT(typeof(Serclimax.ScObjectShapeData)),
        _GT(typeof(Serclimax.ScLoginData)),
        _GT(typeof(Serclimax.ScShowRule)),
        _GT(typeof(Serclimax.ScUnionBadgeColorData)),
        _GT(typeof(Serclimax.ScUnionBadgeBorderData)),
        _GT(typeof(Serclimax.ScUnionBadgeTotemData)),
        _GT(typeof(Serclimax.ScUnionGiftExpData)),
        _GT(typeof(Serclimax.ScUnionItemData)),
        _GT(typeof(Serclimax.ScUnionBuildingData)),
        _GT(typeof(Serclimax.ScUnionLanguageData)),
        _GT(typeof(Serclimax.ScEmbassyData)),
        _GT(typeof(Dictionary<int,Serclimax.ScEmbassyData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScEmbassyData>)),
        _GT(typeof(Serclimax.ScAssembledData)),
        _GT(typeof(Dictionary<int,Serclimax.ScAssembledData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScAssembledData>)),
        _GT(typeof(Serclimax.ScMilitarytActionData)),
        _GT(typeof(Serclimax.ScActMonster)),
        _GT(typeof(Serclimax.ScActMonsterId)),
        _GT(typeof(Serclimax.ScActMonsterRule)),
        _GT(typeof(Serclimax.ScActivityConditionData)),

        _GT(typeof(Serclimax.ScTalentCategoryData)),
        _GT(typeof(Dictionary<int,Serclimax.ScTalentCategoryData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScTalentCategoryData>)),
        _GT(typeof(Serclimax.ScTalentData)),
        _GT(typeof(Dictionary<int,Serclimax.ScTalentData>)),
        _GT(typeof(KeyValuePair<int,Serclimax.ScTalentData>)),
        _GT(typeof(Serclimax.ScUnionTechData)),
        _GT(typeof(Dictionary<int,Serclimax.ScUnionTechData>)),
        _GT(typeof(KeyValuePair<int,Serclimax.ScUnionTechData>)),
        _GT(typeof(Serclimax.ScEquipData)),
        _GT(typeof(Dictionary<int,Serclimax.ScEquipData>)),
        _GT(typeof(KeyValuePair<int,Serclimax.ScEquipData>)),
        _GT(typeof(Serclimax.ScMaterialData)),
        _GT(typeof(Dictionary<int,Serclimax.ScMaterialData>)),
        _GT(typeof(KeyValuePair<int,Serclimax.ScMaterialData>)),
        _GT(typeof(Serclimax.ScArmouryData)),
        _GT(typeof(Dictionary<int,Serclimax.ScArmouryData>)),
        _GT(typeof(KeyValuePair<int,Serclimax.ScArmouryData>)),

        _GT(typeof(Serclimax.ScUnionMonster)),
        _GT(typeof(Dictionary<int, Serclimax.ScUnionMonster>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScUnionMonster>)),

        _GT(typeof(Serclimax.ScActivityStaticsRuleData)),
        _GT(typeof(Dictionary<int, Serclimax.ScActivityStaticsRuleData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScActivityStaticsRuleData>)),

        _GT(typeof(Serclimax.ScActivityStaticsListData)),
        _GT(typeof(Dictionary<int, Serclimax.ScActivityStaticsListData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScActivityStaticsListData>)),

        _GT(typeof(Serclimax.ScActivityStaticsRewardData)),
        _GT(typeof(Serclimax.ScActivityNoticeData)),
        
        _GT(typeof(Serclimax.ScPveMonsterData)),
        _GT(typeof(Serclimax.ScUnionLogData)),

        _GT(typeof(Serclimax.ScPassiveSkillData)),
        _GT(typeof(Dictionary<int, Serclimax.ScPassiveSkillData>)),
        _GT(typeof(KeyValuePair<int, Serclimax.ScPassiveSkillData>)),
        
        _GT(typeof(Serclimax.ScActivitySiegeMonsterNumberList)),
        _GT(typeof(Serclimax.ScActivitySiegeMonsterRankReward)),
        _GT(typeof(Serclimax.ScActivitySiegeMonsterReward)),

        _GT(typeof(Serclimax.ScMapBuildingData)),

        */
        _GT(typeof(Serclimax.Constants)),
        //战斗
        _GT(typeof(Serclimax.GameTime)),
        _GT(typeof(Clishow.CsUnitMgr)),
        _GT(typeof(Clishow.CsUnitAttr)),
        _GT(typeof(Clishow.CsUnit)),
        _GT(typeof(Clishow.CsBattle)),
        _GT(typeof(Serclimax.Level.ScLevelData)),
        _GT(typeof(Serclimax.ScRoot)),
        _GT(typeof(Serclimax.Unit.ScUnitMgr)),
        _GT(typeof(Serclimax.Unit.ScUnit)),
        _GT(typeof(Serclimax.Unit.ScUnitAttribute)),
        _GT(typeof(Serclimax.Unit.ScSoldierAttribute)),
        _GT(typeof(Serclimax.Unit.ScBulidAttribute)),
        _GT(typeof(Serclimax.Player.ScPlayer)),

        _GT(typeof(Serclimax.Battle.ScBattle)),
        _GT(typeof(Serclimax.Battle.ScBattleStatus)),
        _GT(typeof(Serclimax.Battle.ScBattleStatusMsg)),
        _GT(typeof(Serclimax.Battle.ScBattleInfoMsg)),

        _GT(typeof(Serclimax.Battle.ScBattleUpdateMsg)),

        _GT(typeof(Serclimax.Battle.ScBattleDropMsg)),
        _GT(typeof(Serclimax.Battle.ScBattleDropMsg.DropItem)),
        _GT(typeof(List<Serclimax.Battle.ScBattleDropMsg.DropItem>)),

        _GT(typeof(Serclimax.Player.ScPlayerInfoMsg)),
        _GT(typeof(Serclimax.Player.ScPlayerInfoMsg.ArmyInfo)),
        _GT(typeof(List<Serclimax.Player.ScPlayerInfoMsg.ArmyInfo>)),
        _GT(typeof(Serclimax.Player.ScPlayerInfoMsg.SkillInfo)),
        _GT(typeof(List<Serclimax.Player.ScPlayerInfoMsg.SkillInfo>)),
        _GT(typeof(Serclimax.Player.ScPlayerUpdateMsg)),
        _GT(typeof(Serclimax.Player.ScDropUpdateMsg)),
        _GT(typeof(Serclimax.Player.ScCastSkillMsg)),
        _GT(typeof(Serclimax.Player.ScCastSkillMsg.SkillUpdateInfo)),
        _GT(typeof(List<Serclimax.Player.ScCastSkillMsg.SkillUpdateInfo>)),
        _GT(typeof(List<byte[]>)),

        _GT(typeof(GameEnviroment)),
        _GT(typeof(GameEnviroment.EEnviroment)),

        _GT(typeof(Serclimax.Unit.ScUnitBonus)),
        _GT(typeof(Serclimax.Unit.ScUnitDefenseCoef)),
        _GT(typeof(Serclimax.Unit.ScUnitDefenseData)),

        _GT(typeof(Serclimax.ScBuildingReviewData)),

        _GT(typeof(Serclimax.SLGPVP.ScArmy)),
        _GT(typeof(Serclimax.SLGPVP.ScSLGPlayer)),
        _GT(typeof(Serclimax.SLGPVP.ScSLGPVPHero)),
        _GT(typeof(Serclimax.SLGPVP.ScSLGPvP)),
        _GT(typeof(Serclimax.SLGPVP.ScSLGCamp)),
        _GT(typeof(Serclimax.SLGPVP.ScSLGPVPResult)),

        _GT(typeof(HeroBuffShowInfo)),

        _GT(typeof(BeatTextController)),
        
		_GT(typeof(PlaneShadow)),
        _GT(typeof(UIAtlasAnim)),

        _GT(typeof(ProtoMsg.SEntryData)),
        _GT(typeof(ProtoMsg.SEntryBaseData)),
        _GT(typeof(ProtoMsg.SEntryHome)),
        _GT(typeof(ProtoMsg.Position)),
        _GT(typeof(ProtoMsg.SEntryMonster)),
        _GT(typeof(ProtoMsg.SEntryResource)),
        _GT(typeof(ProtoMsg.SEntryGuildBuild)),
        _GT(typeof(ProtoMsg.SEntryEliteMonster)),
        _GT(typeof(ProtoMsg.OwnerGuildInfo)),
        _GT(typeof(ProtoMsg.ActGuildMonsterInfo)),

        _GT(typeof(ProtoMsg.MapGuildBlock)),
        _GT(typeof(BorderData)),
        _GT(typeof(TerrainUnionBuildPreview)),
        _GT(typeof(WorldHUDMgr)),
    };

    public static List<Type> dynamicList = new List<Type>()
    {
        /*typeof(MeshRenderer),
        typeof(ParticleEmitter),
        typeof(ParticleRenderer),
        typeof(ParticleAnimator),

        typeof(BoxCollider),
        typeof(MeshCollider),
        typeof(SphereCollider),
        typeof(CharacterController),
        typeof(CapsuleCollider),

        typeof(Animation),
        typeof(AnimationClip),
        typeof(AnimationState),        

        typeof(BlendWeights),
        typeof(RenderTexture),
        typeof(Rigidbody),*/
    };

    //重载函数，相同参数个数，相同位置out参数匹配出问题时, 需要强制匹配解决
    //使用方法参见例子14
    public static List<Type> outList = new List<Type>()
    {

    };

    static BindType _GT(Type t)
    {
        return new BindType(t);
    }

    static DelegateType _DT(Type t)
    {
        return new DelegateType(t);
    }
}
