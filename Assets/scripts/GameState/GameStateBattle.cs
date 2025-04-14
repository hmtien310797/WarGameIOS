using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Clishow;
using System;
using ProtoMsg;
using System.Text;

public class GameStateBattle : GameState
{
    static readonly int MAX_LOAD_STEP = 10;

    private bool requestingData;
    MsgBattleStartResponse battleStartResponse;

    private int battleId;
    private int charaUid;
    private uint pvpTeam;
    private string levelConfig;


    public uint activeId;
    public uint missionId;
    public uint pveMonsterUid;

    private bool mIsLoading;
    private bool mIsLoadingScene;

    private List<int> selectedArmyList = new List<int>();
    public List<byte[]> heroInfoDataList = new List<byte[]>();
    private Serclimax.Battle.ScBattleBonus battleBonus = new Serclimax.Battle.ScBattleBonus();

    private int mLoadStep;

    private bool battleInited;

    private bool mShowLoading = false;
    private LuaBehaviour loadScreen = null;

    private static GameStateBattle instance;
    private bool isPvpBattle;

    private bool isRandomBattle;
    private bool isGuildMonsterBattle;
    private int mPvpLoadReportStep;
    private bool isPveMonsterBattle;

    private Clishow.CsLockStepSynchronizer mLockStep = new Clishow.CsLockStepSynchronizer();

    private List<int> mActiveEventIDs = new List<int>();

    private GameStateBattle()
    {
        mLockStep.Stop();
    }

    public static GameStateBattle Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameStateBattle();
            }

            return instance;
        }
    }

    public int BattleId
    {
        get
        {
            return battleId;
        }
        set
        {
            battleId = value;
        }
    }

    public int CharaUid
    {
        get
        {
            return charaUid;
        }
        set
        {
            charaUid = value;
        }
    }


    public uint PvpTeam
    {
        get
        {
            return pvpTeam;
        }
        set
        {
            pvpTeam = value;
        }
    }

    public bool IsPvpBattle
    {
        get
        {
            return isPvpBattle;
        }
        set
        {
            isPvpBattle = value;
        }
    }

    public bool IsRandomBattle
    {
        get
        {
            return isRandomBattle;
        }
    }
    public bool IsGuildMonsterBattle
    {
        get
        {
            return isGuildMonsterBattle;
        }
    }

    public bool IsPveMonsterBattle
    {
        get { return isPveMonsterBattle; }
    }

    public bool IsCommonBattle
    {
        get { return !(isRandomBattle || isGuildMonsterBattle || isPveMonsterBattle); }
    }

    public List<int> SelectArmy
    {
        get { return selectedArmyList; }
    }
    public MsgBattleStartResponse BattleStartResponse
    {
        get
        {
            return battleStartResponse;
        }
    }

    public void SetPVPBattleStartResponse(uint battleStartTime, uint battle_id, Clishow.CsLockStepSynchronizer.DisposeMsgCallback frameCB, byte[] drop, byte[] cfg)
    {
        BattleId = (int)battle_id;
        battleStartResponse = new MsgBattleStartResponse();
        battleStartResponse.chapterlevel = battle_id;
        battleStartResponse.monsterDrop = NetworkManager.instance.Decode<ProtoMsg.BattleMonsterDropInfo>(drop);
        battleStartResponse.config = NetworkManager.instance.Decode<ProtoMsg.BattleSceneConfig>(cfg);
        mLockStep.Start(frameCB, PVPBattleUpdate);
    }

    public void SetPveMonsterBattleStartResponse(uint monsterUid, uint battle_id, byte[] msg)
    {
        isPveMonsterBattle = true;
        activeId = 0;
        missionId = 0;
        pveMonsterUid = monsterUid;

        BattleId = (int)battle_id;
        battleStartResponse = new MsgBattleStartResponse();
        battleStartResponse.chapterlevel = battle_id;
        MsgBattleMapDigTreasureStartResponse random = NetworkManager.instance.Decode<MsgBattleMapDigTreasureStartResponse>(msg);

        battleStartResponse.monsterDrop = random.data.monsterDrop;
        battleStartResponse.config = random.data.config;
    }

    public void SetGuildMonsterBattleStartResponse(uint activid, uint missionid, uint battle_id, byte[] msg)
    {
        isGuildMonsterBattle = true;
        activeId = activid;
        missionId = missionid;

        BattleId = (int)battle_id;
        battleStartResponse = new MsgBattleStartResponse();
        battleStartResponse.chapterlevel = battle_id;
        MsgBattleGuildMonsterStartResponse random = NetworkManager.instance.Decode<MsgBattleGuildMonsterStartResponse>(msg);


        battleStartResponse.monsterDrop = random.data.monsterDrop;
        battleStartResponse.config = random.data.config;
        for (int i = 0, imax = random.data.events.Count; i < imax; i++)
        {
            mActiveEventIDs.AddRange(random.data.events[i].@event.ToArray());
        }

        //WSdkManager.instance.SendDataReport("level", "" + battle_id, "begin", "0");
    }

    public void SetRandomBattleStartResponse(uint activeid, uint battle_id, byte[] msg)
    {
        isRandomBattle = true;

        BattleId = (int)battle_id;
        battleStartResponse = new MsgBattleStartResponse();
        battleStartResponse.chapterlevel = battle_id;
        MsgBattleRandomPVEStartResponse random = NetworkManager.instance.Decode<MsgBattleRandomPVEStartResponse>(msg);

        battleStartResponse.monsterDrop = random.monsterDrop;
        battleStartResponse.config = random.config;


        if (activeid == 1)
        {
            for (int i = 0, imax = random.events.Count; i < imax; i++)
            {
                mActiveEventIDs.AddRange(random.events[i].@event.ToArray());
            }
        }
        WSdkManager.instance.SendDataReport("level", "" + battle_id, "begin", "0");
    }

    void PVPBattleUpdate(float dt)
    {
        SceneManager.instance.Update(dt);
    }

    public void SyncTime(UInt64 pre_time, UInt64 target_time)
    {
        mLockStep.SyncTime(pre_time, target_time);
    }

    public void Restart()
    {
        RequestBattle();
        GUIMgr.Instance.CloseAllMenu();
        SceneManager.instance.ClearLevel();
        GuideManager.instance.Clear();

        mIsLoading = true;
        mIsLoadingScene = false;
        mLoadStep = 0;
        mPvpLoadReportStep = 0;
        System.GC.Collect();
        LuaClient.GetMainState().LuaGC(LuaInterface.LuaGCOptions.LUA_GCCOLLECT);
        //LuaClient.GetMainState().DoString("collectgarbage(\"collect\")");
        if (mShowLoading)
        {
            loadScreen = GUIMgr.Instance.CreateMenu("loading", true);
        }
    }

    private void RequestBattle()
    {
        requestingData = true;
        if (isPvpBattle)
        {
            if (battleStartResponse != null)
            {
                var config = battleStartResponse.config.config;
                if (battleStartResponse.config.zip)
                {
                    config = Serclimax.CompressUtils.DecompressBytes(config);
                }

                levelConfig = Serclimax.Utils.GetUtf8String(config);
                requestingData = false;
            }
        }
        else if (isRandomBattle || isGuildMonsterBattle || isPveMonsterBattle)
        {
            if (battleStartResponse != null)
            {
                var config = battleStartResponse.config.config;
                if (battleStartResponse.config.zip)
                {
                    config = Serclimax.CompressUtils.DecompressBytes(config);
                }

                levelConfig = Serclimax.Utils.GetUtf8String(config);
                requestingData = false;
            }
        }
        else
        {
            MsgBattleStartRequest req = new MsgBattleStartRequest();
            req.chapterlevel = (uint)BattleId;
            NetworkManager.instance.Request<MsgBattleStartRequest>((uint)MsgCategory.Battle, (uint)BattleTypeId.Battle.MsgBattleStartRequest, req, (data) =>
            {
                battleStartResponse = NetworkManager.instance.Decode<MsgBattleStartResponse>(data);
                if (battleStartResponse.code == (uint)RequestCode.Code_OK)
                {
                    if (Serclimax.Constants.USE_LOCAL_LEVEL_DATA)
                    {
                        var battelData = Main.Instance.GetTableMgr().GetBattleData(BattleId);
                        string levelName = battelData.sceneData;
                        var chapterData = Main.Instance.GetTableMgr().GetChapterData(battelData.chapterId);
                        string chapterName = chapterData.stringId;
                        TextAsset text = ResourceLibrary.instance.GetLevelData(chapterName, levelName);
                        if (text != null)
                        {
                            levelConfig = text.text;
                        }
                    }
                    else
                    {
                        var config = battleStartResponse.config.config;
                        if (battleStartResponse.config.zip)
                        {
                            config = Serclimax.CompressUtils.DecompressBytes(config);
                        }

                        levelConfig = Serclimax.Utils.GetUtf8String(config);
                    }
                    requestingData = false;

                    WSdkManager.instance.SendDataReport("level", "" + battleStartResponse.chapterlevel, "begin", "0");
                }
                else
                {
                    NetworkManager.instance.ErrorCodeHandler(battleStartResponse.code, () =>
                    {
                        Main.Instance.ChangeGameState(GameStateMain.Instance, null);
                    });
                }

            }, true);
        }
    }

    public override void OnEnter(string _param, System.Action done)
    {
        mIsLoadingScene = false;
        mIsLoading = true;
        mLoadStep = 0;
        mPvpLoadReportStep = 0;
        battleInited = false;

        if (_param != null)
        {
            Dictionary<string, object> param = OurMiniJSON.Json.Deserialize(_param) as Dictionary<string, object>;

            if (param.ContainsKey("loadScreen"))
            {
                mShowLoading = int.Parse((string)param["loadScreen"]) == 1;
                if (mShowLoading)
                {
                    loadScreen = GUIMgr.Instance.CreateMenu("loading", true);
                    AssetBundleManager.Instance.onCheckPercent += OnCheckPrecent;
                    AssetBundleManager.Instance.onBundleLoad += OnBundleLoad;
                }
            }
            if (param.ContainsKey("selectedArmyList"))
            {
                selectedArmyList.Clear();
                var idList = ((List<object>)param["selectedArmyList"]);
                foreach (var id in idList)
                {
                    selectedArmyList.Add(Convert.ToInt32(id));
                }
            }


            if (param.ContainsKey("battleBonus"))
            {
                var bonus = param["battleBonus"] as Dictionary<string, object>;
                battleBonus.bulletAddition = Convert.ToInt32(bonus["bulletAddition"]);
                battleBonus.energyAddition = Convert.ToInt32(bonus["energyAddition"]);
                battleBonus.bulletRecover = Convert.ToInt32(bonus["bulletRecover"]);


                if (bonus.ContainsKey("attackCoefAddjust"))
                    battleBonus.attackCoefAddjust = Convert.ToInt32(bonus["attackCoefAddjust"]);

                if (bonus.ContainsKey("defenceAddjust"))
                    battleBonus.defenceAddjust = Convert.ToInt32(bonus["defenceAddjust"]);

                if (bonus.ContainsKey("hpAddjust"))
                    battleBonus.hpAddjust = Convert.ToInt32(bonus["hpAddjust"]);

                if (bonus.ContainsKey("eliteCoefAddjust"))
                    battleBonus.eliteCoefAddjust = Convert.ToInt32(bonus["eliteCoefAddjust"]);
            }
        }
        else
        {
            Serclimax.DebugUtils.LogError("Invalid enter param!");
        }
#if SUPPORT_CHANGE_SCENE
        mIsLoadingScene = true;
        Main.Instance.StartCoroutine(ChangeSceneUtility.ChangeNewScene(() =>
        {
            if (Serclimax.Constants.ENABLE_FAKE_DATA)
            {
                battleStartResponse = new MsgBattleStartResponse();
                battleStartResponse.chapterlevel = (uint)BattleId;
                BattleMonsterDropInfo dropInfo = null;
                var textAsset = Resources.Load(@"level\Chapter_Demo\drop\BattleDrops_" + BattleId) as TextAsset;
                if (textAsset != null)
                {
                    dropInfo = NetworkManager.instance.Decode<ProtoMsg.BattleMonsterDropInfo>(textAsset.bytes);
                }
                battleStartResponse.monsterDrop = dropInfo;

                battleStartResponse.config = new BattleSceneConfig();
                var battelData = Main.Instance.GetTableMgr().GetBattleData(BattleId);
                string levelName = battelData.sceneData;
                var chapterData = Main.Instance.GetTableMgr().GetChapterData(battelData.chapterId);
                string chapterName = chapterData.stringId;

                TextAsset text = ResourceLibrary.instance.GetLevelData(chapterName, levelName);
                if (text != null)
                {
                    levelConfig = text.text;
                }

                requestingData = false;
            }
            else
            {
                RequestBattle();
            }
            mIsLoadingScene = false;
            if (done != null)
            {
                done();
            }
        }));
#else
            if (Serclimax.Constants.ENABLE_FAKE_DATA)
            {
                battleStartResponse = new MsgBattleStartResponse();
                battleStartResponse.chapterlevel = (uint)BattleId;
                BattleMonsterDropInfo dropInfo = null;
                var textAsset = Resources.Load(@"level\Chapter_Demo\drop\BattleDrops_" + BattleId) as TextAsset;
                if (textAsset != null)
                {
                    dropInfo = NetworkManager.instance.Decode<ProtoMsg.BattleMonsterDropInfo>(textAsset.bytes);
                }
                battleStartResponse.monsterDrop = dropInfo;

                battleStartResponse.config = new BattleSceneConfig();
                var battelData = Main.Instance.GetTableMgr().GetBattleData(BattleId);
                string levelName = battelData.sceneData;
                var chapterData = Main.Instance.GetTableMgr().GetChapterData(battelData.chapterId);
                string chapterName = chapterData.stringId;

                TextAsset text = ResourceLibrary.instance.GetLevelData(chapterName, levelName);
                if (text != null)
                {
                    levelConfig = text.text;
                }

                requestingData = false;
            }
            else
            {
                RequestBattle();
            }
        mIsLoadingScene = false;
        if(done != null)
        {
            done();
        }
#endif
    }

    private void OnBundleLoad(string msg)
    {
        if (loadScreen != null)
        {
            loadScreen.CallFunc("ShowTip", msg);
        }
    }

    private void OnCheckPrecent(float value)
    {
        if (loadScreen != null)
        {
            loadScreen.CallFunc("SetProgress", value);
        }
    }

    void ReprotPVPClientLoadProgress(int step, float rate)
    {
        if (!IsPvpBattle)
            return;
        if (mPvpLoadReportStep == step)
            return;
        mPvpLoadReportStep = step;
        MsgBattlePvPClientLoadProgressRequest req = new MsgBattlePvPClientLoadProgressRequest();
        req.rate = (uint)(rate * 100);
        NetworkManager.instance.Request<MsgBattlePvPClientLoadProgressRequest>((uint)MsgCategory.PvP, (uint)PvPTypeId.PvP.MsgBattlePvPClientLoadProgressRequest, req, (data) =>
        {

        }, true);
    }

    public void RequsetPVPBattleEnd(int winState)
    {
        if (!IsPvpBattle)
            return;
        MsgBattlePvPCheckEndRequest req = new MsgBattlePvPCheckEndRequest();
        if (winState == 0)
        {
            req.winTeam = 0;
        }
        else if (winState > 0)
        {
            req.winTeam = (uint)PvpTeam;
        }
        else
        {
            req.winTeam = (uint)(PvpTeam == 2 ? 1 : 2);
        }
        NetworkManager.instance.Request<MsgBattlePvPCheckEndRequest>((uint)MsgCategory.PvP, (uint)PvPTypeId.PvP.MsgBattlePvPCheckEndRequest, req, (data) =>
        {
            MsgBattlePvPCheckEndReponse cer = NetworkManager.instance.Decode<MsgBattlePvPCheckEndReponse>(data);
            if (cer.code == (uint)RequestCode.Code_OK)
            {
                Debug.Log("SSSSSSSSSSSSSSSSSSSSSS MsgBattlePvPCheckEndRequest " + cer.code.ToString());
            }
            else
            {
                Debug.LogError("SSSSSSSSSSSSSSSSSSSSSS MsgBattlePvPCheckEndRequest Error " + cer.code.ToString());
            }
        }, true);
    }

    private bool ispreloaded = false;
    void UpdateLoad()
    {
        if (loadScreen != null)
        {
            float value = (float)mLoadStep / (float)(MAX_LOAD_STEP - 1);
            loadScreen.CallFunc("SetProgress", value);
        }

        bool bWaiting = false;
        ReprotPVPClientLoadProgress(mLoadStep, (float)mLoadStep / (float)(MAX_LOAD_STEP - 1));
        if (mLoadStep == 0)
        {
            if (ResourceUnload.instance.IsDone())
            {
                System.GC.Collect();
                LuaClient.GetMainState().LuaGC(LuaInterface.LuaGCOptions.LUA_GCCOLLECT);
                bWaiting = false;
            }
            else
            {
                bWaiting = true;
            }
        }
        else if (mLoadStep == 1)
        {
            SceneManager.instance.LoadLevelData((int)battleStartResponse.chapterlevel, levelConfig);
        }
        else if (mLoadStep == 2)
        {
            if (!AssetBundleManager.Instance.ischecking)
            {
                ispreloaded = SceneManager.instance.LoadAStarData();
            }
            if (!ispreloaded)
            {
                return;
            }
        }
        else if (mLoadStep == 3)
        {
            if (!AssetBundleManager.Instance.ischecking)
            {
                ispreloaded = SceneManager.instance.LoadEventsData();
            }
            if (!ispreloaded)
            {
                return;
            }
        }
        else if (mLoadStep == 4)
        {
            if (!AssetBundleManager.Instance.ischecking)
            {
                ReprotPVPClientLoadProgress(mLoadStep, (float)mLoadStep / (float)(MAX_LOAD_STEP - 1));
                ispreloaded = SceneManager.instance.LoadEffectAsset();
            }
            if (!ispreloaded)
            {
                return;
            }
        }
        else if (mLoadStep == 5)
        {

            SceneManager.instance.InitScRoots(null, () =>
             {
                 Serclimax.Battle.ScBattleStartInfo battleStartInfo = new Serclimax.Battle.ScBattleStartInfo();
                 battleStartInfo.battleId = (int)battleStartResponse.chapterlevel;
                 battleStartInfo.charaUid = CharaUid;
                 battleStartInfo.pvpTeamID = (int)PvpTeam;
                 battleStartInfo.dropInfo = battleStartResponse.monsterDrop;
                 battleStartInfo.selectedArmyList = selectedArmyList;
                 battleStartInfo.heroInfoList = new List<HeroInfo>();
                 foreach (var data in heroInfoDataList)
                 {
                     var heroInfo = NetworkManager.instance.Decode<HeroInfo>(data);
                     battleStartInfo.heroInfoList.Add(heroInfo);
                 }
                 battleStartInfo.battleBonus = battleBonus;

                 SceneManager.instance.gScRoots.GetBattle().StartBattle(battleStartInfo);

                 if (mActiveEventIDs.Count != 0)
                 {
                     SceneManager.instance.gScRoots.InitActiveEventUIDs = mActiveEventIDs.ToArray();
                 }
             });

        }
        else if (mLoadStep == 6)
        {
            if (!AssetBundleManager.Instance.ischecking)
            {
                ispreloaded = SceneManager.instance.LoadLevel();
            }
            if (!ispreloaded)
            {
                return;
            }
        }
        else if (mLoadStep == 7)
        {
            if (!AssetBundleManager.Instance.ischecking)
            {
                ispreloaded = SceneManager.instance.preloadUnit(selectedArmyList);
            }
            if (!ispreloaded)
            {
                return;
            }


        }
        else if (mLoadStep == 8)
        {
            if (!AssetBundleManager.Instance.ischecking)
            {
                ispreloaded = SceneManager.instance.LoadAndPlayBgMusic(BattleId);
            }
            if (!ispreloaded)
            {
                Debug.LogError("Load  bg music failed");
            }
        }
        else if (mLoadStep == 9)
        {
            GUIMgr.Instance.CreateMenu("InGameUI");
            SceneManager.instance.OnLoadFinished();
            SceneManager.instance.gScRoots.GetBattle().OnSceneLoadFinished();

            GuideManager.instance.Init();
        }

        if (!bWaiting)
            mLoadStep++;
        if (mLoadStep == MAX_LOAD_STEP)
        {
            ReprotPVPClientLoadProgress(mLoadStep, 0.99f);
            mIsLoading = false;
        }
    }

    public override void OnUpdate()
    {
        if (mIsLoadingScene)
            return;
        if (requestingData)
        {
            return;
        }

        if (mIsLoading)
        {
            UpdateLoad();
            return;
        }
        if (battleInited)
        {
            GUIMgr.Instance.CloseMenu("loading");
            AssetBundleManager.Instance.onCheckPercent -= OnCheckPrecent;
            AssetBundleManager.Instance.onBundleLoad -= OnBundleLoad;
        }

        if (IsPvpBattle && SceneManager.instance.gameOverState == SceneManager.GameOverStateType.GOST_NIL)
        {
            mLockStep.Update();
            //Debug.Log("HHHHHHHHHHHHHHHHHHHH " +  (mFTurn.CurFrame).ToString()+"  "+mFTurn.TurnTime.ToString()+"  "+mFTurn.TotalTurnTime.ToString());
        }
        else
        {
            SceneManager.instance.Update();
        }

        GuideManager.instance.update(Time.deltaTime);
    }

    public override void OnFixedUpdate()
    {


    }

    public override void OnLeave()
    {
        selectedArmyList.Clear();
        loadScreen = null;
        heroInfoDataList.Clear();
        battleStartResponse = null;
        isRandomBattle = false;
        isGuildMonsterBattle = false;
        isPveMonsterBattle = false;
        mActiveEventIDs.Clear();
        mLockStep.Stop();

        GuideManager.instance.Clear();
        GUIMgr.Instance.CloseAllMenu();
        SceneManager.instance.ClearLevel();
        System.GC.Collect();
        LuaClient.GetMainState().LuaGC(LuaInterface.LuaGCOptions.LUA_GCCOLLECT);
        ResourceUnload.instance.ReleaseUnusedResource();
        Debugger.Log("leave battle state");
    }

    public void StartLevel(int chapterId, int battleId)
    {

    }

    public void OnBattleInited()
    {
        battleInited = true;
        //GuideManager.instance.StartGuide(1);
    }
}
