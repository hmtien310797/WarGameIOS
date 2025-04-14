using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.IO;
using UnityEngine.SceneManagement;
using UnityEngine;
using Clishow;


public class SceneManager
{
    public static readonly float GameOverMinTimeScale = 0.5f;

    public static readonly float GameOverAnimTotalTime = 3;


    static SceneManager mInstance;
    public Serclimax.ScTableMgr gScTableData = null;
    public Serclimax.ScRoot gScRoots = null;

    public delegate void OnSceneLoadFinished();

    public OnSceneLoadFinished onSceneLoadFinished;

    public delegate void OnGameOver();

    public OnGameOver onGameOver;

    public bool isScreenLock = false;

    public SceneEntity Entity = null;


    private GameObject mGroupObj = null;

    public GameObject GroupObj
    {
        get
        {
            if (mGroupObj == null)
            {
                string prefabName = "GroupStyle_5";
                mGroupObj = ResourceLibrary.instance.GetLevelUnitInstanceFromPool(prefabName, XLevelDefine.ElementType.Unit, Vector3.zero, Quaternion.identity);
            }
            return mGroupObj;
        }
    }

    public static SceneManager instance
    {
        get
        {
            if (mInstance == null)
            {
                mInstance = new SceneManager();
            }
            return mInstance;
        }
    }
    #region Variables
    private XLevelDataXML mLevelData;
    public XLevelDataXML CurLevelData
    {
        get
        {
            return mLevelData;
        }
        set { mLevelData = value; }
    }

    private GameObject mSceneObj;

    #region
    private FirelineController mFireline;
    public GameObject GetFireline()
    {
        if (mFireline == null)
            return null;
        else
            return mFireline.gameObject;
    }
    public void MoveFirelineTo(Vector3 _target, bool _immediate)
    {
        if (mFireline != null)
        {
            mFireline.MoveTo(_target, _immediate);
        }
    }
    #endregion

    // Root Object for all generated objects
    private Transform mLevelRoot;

    public Transform LevelRoot
    {
        get
        {
            return mLevelRoot;
        }
    }

    // Root of Elements
    private Transform mElementRoot;

    // Root of Pathes
    private Transform mPathRoot;

    //AStar Data
    private Serclimax.NiceAstarPath mAstar;
    public Serclimax.NiceAstarPath Astar
    {
        get
        {
            if (mAstar == null)
            {
                mAstar = new Serclimax.NiceAstarPath();
            }
            return mAstar;
        }
        set
        {
            mAstar = value;
        }
    }

    private Serclimax.Event.ScEventDataset mEDataSet = null;

    //
    private int mMaxElementUid;
    private int mMaxPathUid;

    private string mCurChapterName = string.Empty;
    public string CurChapterName
    {
        get
        {
            return mCurChapterName;
        }
        set
        {
            mCurChapterName = value;
        }
    }
    private string mCurLevelName = string.Empty;
    public string CurLevelName
    {
        get
        {
            return mCurLevelName;
        }
        set
        {
            mCurLevelName = value;
        }
    }

    private CsBulletEmitter mBulletEmitter = null;

    private CsBloodEmitter mBloodEmitter = null;

    private CsBloodEmitter mBoomResidualEmitter = null;

    private CsTrailCanvas mTrailRenderer = null;

    private CsBloodEmitter mButtleBeatenglow = null;

    private bool gameWin = false;

    public bool GameWin
    {
        get { return gameWin; }
        set
        {
            gameWin = value;
        }
    }

    #endregion



    #region Members
    public void ClearLevel()
    {
        //QualitySettings.masterTextureLimit = 0;
        gScTableData = null;
        mEDataSet = null;
        if (gScRoots == null)
        {
            return;
        }
        gScRoots.Restart();
        gScRoots = null;
        CsBakeBatchesMgr.Instance.NeedUPdateBakeObj = true;
        CsUnitMgr.Instance.IgnoreDisposeMsg = false;
        CsSkillMgr.Instance.IgnoreDisposeMsg = false;

        CsObjPoolMgr.Instance.DestroyAllObjCache();


        GameObject.Destroy(CsObjPoolMgr.Instance.gameObject);
        GameObject.Destroy(CsUnitMgr.Instance.gameObject);
        GameObject.Destroy(CsDisDaCenter.Instance.gameObject);
        GameObject.Destroy(CsSkillMgr.Instance.gameObject);
        GameObject.Destroy(CsBakeBatchesMgr.Instance.gameObject);
        GameObject.Destroy(CsBattle.Instance.gameObject);
        if (CsUnitMBMgr.isValid)
            GameObject.Destroy(CsUnitMBMgr.Instance.gameObject);
        if (CsDeadMgr.isValid)
        {
            GameObject.Destroy(CsDeadMgr.Instance.gameObject);
        }

        if (mLevelRoot != null)
        {
            GameObject.Destroy(mLevelRoot.gameObject);
            mLevelRoot = null;
        }

        if (mBulletEmitter != null)
        {
            GameObject.Destroy(mBulletEmitter.gameObject);
        }
        mBulletEmitter = null;

        if (mTrailRenderer != null)
        {
            mTrailRenderer.Clear();
            GameObject.Destroy(mTrailRenderer.gameObject);
        }
        if (mButtleBeatenglow != null)
        {
            GameObject.Destroy(mButtleBeatenglow.gameObject);
        }
        mPathRoot = null;
        mElementRoot = null;
        mSceneObj = null;
        mBoomResidualEmitter = null;
        mBloodEmitter = null;
        mFireline = null;
        mTrailRenderer = null;
        Entity = null;
        mLevelData = null;
        Astar.OnApplicationQuit();
        Astar = null;
        mButtleBeatenglow = null;

        AudioManager.instance.StopMusic();
        //GameObject.Destroy(mBgMusic);

        ResourceUnload.instance.ReleaseUnusedResource();

        //Clear UICamera Static Delegate
        UICamera.onClick = null;
        UICamera.onDoubleClick = null;
        UICamera.onHover = null;
        UICamera.onPress = null;
        UICamera.onSelect = null;
        UICamera.onScroll = null;
        UICamera.onDrag = null;
        UICamera.onDragStart = null;
        UICamera.onDragOver = null;
        UICamera.onDragOut = null;
        UICamera.onDragEnd = null;
        UICamera.onDrop = null;
        UICamera.onKey = null;
        UICamera.onNavigate = null;
        UICamera.onPan = null;
        UICamera.onTooltip = null;
        UICamera.onMouseMove = null;
        mGameState = GameOverStateType.GOST_NIL;
        mTarget = null;
    }

    public void InitScRoots(int[] expActiveEvent = null, System.Action init_cb = null)
    {
        //QualitySettings.masterTextureLimit = 3;
        //test load table data
        gScTableData = Main.Instance.GetTableMgr();
        //gScTableData.
        //creat scRoot
        Serclimax.Level.ScLevelSpace rootspace = mLevelData.LevelSpaces[0];
        gScRoots = new Serclimax.ScRoot(CsDisDaCenter.Instance.DisCenter, gScTableData, (float)rootspace.RootRect.X, (float)rootspace.RootRect.Y, (float)rootspace.RootRect.Width, (float)rootspace.RootRect.Height);
        if (gScRoots != null)
        {
            //gScRoots.GetMgr<Serclimax.ScRecordMgr>().Setup(Serclimax.ScRecordMgr.RecordState.RS_PLAY);
            gScRoots.Astar = Astar;
            gScRoots.InitActiveEventUIDs = expActiveEvent;
            gScRoots.EventDataset = mEDataSet;
            gScRoots.LevelData = mLevelData.CreateScLevelData();

            if (init_cb != null)
            {
                init_cb();
            }

            gScRoots.Initialize();
        }
        CsUnitMgr.Instance.Initialize(gScTableData);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_UNIT_MSG, CsUnitMgr.Instance.DisposeUnitMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_UNIT_MSG, CsUnitMgr.Instance.DisposeCreateUnitMsg);
        CsSkillMgr.Instance.Initialize();
        CsSkillMgr.Instance.BulletEmitter = mBulletEmitter;
        CsSkillMgr.Instance.BoolEmitter = mBloodEmitter;
        CsSkillMgr.Instance.BoomResidualEmitter = mBoomResidualEmitter;
        CsSkillMgr.Instance.TrailCanvas = mTrailRenderer;
        CsSkillMgr.Instance.ButtleBeatenEmitter = mButtleBeatenglow;
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_SKILL_MSG, CsSkillMgr.Instance.DisposeSkillMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_SKILL_MSG, CsSkillMgr.Instance.DisposeCreateSkillMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_GAMEOVER_MSG, SceneManager.instance.DisposeLevelGlobelMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_ACTIVE_GUIDE_MSG, SceneManager.instance.DisposeActiveGuideMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_RAGION_UPDATE_MSG, SceneManager.instance.DisposeRagionUpdateMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_ACTIVE_BATTLEHINT_MSG, SceneManager.instance.DisposeActiveLevelHintMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_PRODUCTION_START_MSG, SceneManager.instance.DisposeProductionStartMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_SCREENLOCAK_MSG, SceneManager.instance.DisposeScreenLockMsg);

        CsBattle.Instance.Initialize();
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_BATTLE_INFO_MSG, CsBattle.Instance.DisposeBattleInfoMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_BATTLE_STATUS_MSG, CsBattle.Instance.DisposeBattleStatusMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_BATTLE_UPDATE_MSG, CsBattle.Instance.DisposeBattleUpdateMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_PLAYER_INFO_MSG, CsBattle.Instance.DisposePlayerInfoMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_BATTLE_INIT_MSG, CsBattle.Instance.DisposeBattleInitMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_BATTLE_DROP_MSG, CsBattle.Instance.DisposeBattleDropMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_PLAYER_UPDATE_MSG, CsBattle.Instance.DisposePlayerUpdateMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_DROP_UPDATE_MSG, CsBattle.Instance.DisposeDropUpdateMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_CAST_SKILL_MSG, CsBattle.Instance.DisposeCastSkillMsg);


    }

    public bool LoadLevel()
    {
        bool isOK = false;
        if (CurLevelData != null)
        {
            //mCurLevelDataXml = _levelData;
            InitRoot();
            isOK = InitSceneXml();
            if (isOK == false)
            {
                return isOK;
            }
            //InitElements();
            InitPathes();
            return true;
        }
        return isOK;
    }

    void InitRoot()
    {
        if (GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME))
        {
            mLevelRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME).transform;
        }
        else
        {
            GameObject obj = new GameObject(XLevelDefine.LEVEL_ROOT_NAME);
            mLevelRoot = obj.transform;

            // Editor Component

            //element root
            obj = new GameObject(XLevelDefine.ELEMENT_ROOT_NAME);
            //obj.AddComponent<XElementRootHelper>();
            mElementRoot = obj.transform;
            mElementRoot.parent = mLevelRoot;
            //path root


            obj = new GameObject(XLevelDefine.PATH_ROOT_NAME);
            //obj.AddComponent<XPathRootHelper>();
            mPathRoot = obj.transform;
            mPathRoot.parent = mLevelRoot;


        }
    }

    bool InitSceneXml()
    {
        //scene
        mSceneObj = ResourceLibrary.instance.GetLevelSceneInstanse(CurChapterName, CurLevelData.levelSceneName);
        if (mSceneObj)
        {
            mSceneObj.transform.SetParent(mLevelRoot);
            Entity = mSceneObj.GetComponent<SceneEntity>();
            if (Entity != null)
            {
                Entity.LoadPrefabs();
            }

            mFireline = mSceneObj.transform.Find("FireLine").GetComponent<FirelineController>();
            if (mFireline != null)
            {
                Vector3 attdir = gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().GetAttackDirection(0);
                if (attdir.x > 0)
                {
                    mFireline.Init(CurLevelData.LevelBattleLine[Serclimax.Constants.BATTLELINE_END_ID],
                               CurLevelData.LevelBattleLine[Serclimax.Constants.BATTLELINE_INIT_ID],
                               CurLevelData.LevelBattleLine[Serclimax.Constants.BATTLELINE_START_ID]);
                }
                else
                {
                    mFireline.Init(CurLevelData.LevelBattleLine[Serclimax.Constants.BATTLELINE_START_ID],
                               CurLevelData.LevelBattleLine[Serclimax.Constants.BATTLELINE_INIT_ID],
                               CurLevelData.LevelBattleLine[Serclimax.Constants.BATTLELINE_END_ID]);
                }

            }
            return true;
        }
        return false;
    }
    void InitElements()
    {
        XElementData[] elementsData = mLevelData.elementsData;
        mMaxElementUid = 0;

        for (int i = 0; i < elementsData.Length; i++)
        {
            XElementData elementData = elementsData[i];

            if (elementData.uniqueId > mMaxElementUid)
            {
                mMaxElementUid = elementData.uniqueId;
            }

            XLevelElement element = elementData.Instantiate();
            if (element)
            {
                element.transform.parent = mElementRoot;
                element.transform.position = elementData.position;
                element.transform.forward = elementData.forward;
                element.transform.localScale = elementData.scale;

            }
        }
    }
    void InitPathes()
    {
        XPathPointData[] pathesData = mLevelData.pathesData;
        mMaxPathUid = 0;
        for (int i = 0; i < pathesData.Length; i++)
        {
            XPathPointData pathData = pathesData[i];

            if (pathData.uniqueId > mMaxPathUid)
            {
                mMaxPathUid = pathData.uniqueId;
            }

            GameObject obj = new GameObject(pathData.uniqueId + XLevelDefine.LEVEL_PATHPOINT_NAME + "_" + pathData.pathGroup);
            if (obj)
            {
                obj.transform.parent = mPathRoot;
                obj.transform.position = pathData.worldPosition;

                //Add Editor Component
                //XPathEditor pathEditor = obj.AddComponent<XPathEditor>();
                //pathEditor.Init(pathData);
            }
        }
    }

    public bool LoadLevelData(int _battleId, string config = null)
    {
        var battelData = Main.Instance.GetTableMgr().GetBattleData(_battleId);
        CurLevelName = battelData.sceneData;
        var chapterData = Main.Instance.GetTableMgr().GetChapterData(battelData.chapterId);
        CurChapterName = chapterData.stringId;

        //read xmldata
        XmlDocument levelDataXml = new XmlDocument();
        if (config == null)
        {
            return false;
        }

        levelDataXml.LoadXml(config);

        mLevelData = new XLevelDataXML();
        foreach (XmlNode objNode in levelDataXml.DocumentElement.ChildNodes)
        {
            if (objNode.Name == "Map")
            {
                mLevelData.ReadFromXml((XmlElement)objNode);
                mLevelData.Init();
                break;
            }
        }
        return true;
    }
    public bool LoadAStarData()
    {
        if (CurLevelData == null)
            return false;

        byte[] astardata = ResourceLibrary.instance.GetLevelSceneAstarData(CurChapterName, CurLevelData.AstarFile);
        if (astardata == null)
        {
            Debug.LogWarning("Load AStar data failed! . chapterName:" + CurChapterName + "astarFile:" + CurLevelData.AstarFile);
            return false;
        }
        Astar.Awake(astardata);
        return true;
    }

    public bool LoadEventsData()
    {
        if (CurLevelData == null)
            return false;

        TextAsset text = ResourceLibrary.instance.GetEventData(CurChapterName, CurLevelData.EventsFile);
        if (text == null)
        {
            Debug.LogWarning("Load Events Data failed!");
            return false;
        }

        mEDataSet = Serclimax.Event.ScEventDataset.Deserialize(text.text);
        if (mEDataSet == null)
        {
            Debug.LogWarning("Load Events Data failed!");
            return false;
        }
        return true;
    }


    public bool preloadUnit(List<int> selectArmlist)
    {
        if (mEDataSet == null)
            return true;
        mEDataSet.GeneratePreload(gScRoots);
        if (mEDataSet.mPreloadNames.Count == 0)
            return true;
        for (int i = 0, imax = selectArmlist.Count; i < imax; i++)
        {
            Serclimax.Unit.ScUnitData ud = gScRoots.TableMgr.GetUnitData(selectArmlist[i]);
            if (ud != null)
            {
                if (!mEDataSet.mPreloadNames.Contains(ud._unitPrefab))
                {
                    mEDataSet.mPreloadNames.Add(ud._unitPrefab);
                }
            }
        }
        bool hasRes = true;
        for (int i = 0, imax = mEDataSet.mPreloadNames.Count; i < imax; i++)
        {
            hasRes &= ResourceLibrary.instance.CacheLevelObject(mEDataSet.mPreloadNames[i], 3);
        }
        for (int i = 0, imax = mEDataSet.mPreloadSkillNames.Count; i < imax; i++)
        {
            hasRes &= ResourceLibrary.instance.CacheEffectObject(mEDataSet.mPreloadSkillNames[i], 3);
        }
        ResourceLibrary.instance.CacheEffectObject("Bornsmoke", 3);
        ResourceLibrary.instance.CacheEffectObject("BuildBoom", 3);
        ResourceLibrary.instance.CacheEffectObject("Fire", 3);
        return hasRes;
    }

    public bool LoadEffectAsset()
    {
        GameObject BullteEmitter = ResourceLibrary.instance.GetEffectInstance("BullteEmitter");
        GameObject BloodcEmitter = ResourceLibrary.instance.GetEffectInstance("BloodcEmitter");
        GameObject BoomResidualEmitter = ResourceLibrary.instance.GetEffectInstance("BoomResidualEmitter");
        GameObject CorpseEffect = ResourceLibrary.instance.GetEffectInstance("CorpseEffect");
        GameObject TrailRender = ResourceLibrary.instance.GetEffectInstance("TrailCanvas");
        GameObject ButtleBeatenglow = ResourceLibrary.instance.GetEffectInstance("ButtleBeatenglow");
        if (BullteEmitter != null && BloodcEmitter != null && BoomResidualEmitter != null && CorpseEffect != null)
        {
            mBulletEmitter = BullteEmitter.GetComponent<CsBulletEmitter>();
            mBloodEmitter = BloodcEmitter.GetComponent<CsBloodEmitter>();
            mBoomResidualEmitter = BoomResidualEmitter.GetComponent<CsBloodEmitter>();
            mButtleBeatenglow = ButtleBeatenglow.GetComponent<CsBloodEmitter>();
            CsDeadMgr.Instance.CorpseEffect = CorpseEffect.GetComponent<CsCorpseEffect>();
            CsDeadMgr.Instance.CorpseEffect.transform.parent = CsDeadMgr.Instance.transform;

            if (TrailRender != null)
            {
                mTrailRenderer = TrailRender.GetComponent<CsTrailCanvas>();
            }
            return true;
        }
        else
        {
            return false;
        }
    }

    public bool LoadAndPlayBgMusic(int battleid)
    {
        if (CurLevelData == null)
            return false;
        var battelData = Main.Instance.GetTableMgr().GetBattleData(battleid);
        AudioClip ac = ResourceLibrary.instance.GetMusic(battelData.bgm);
        if (ac)
        {
            AudioManager.instance.PlayMusic(ac, 0.2f, true);
            return true;
        }
        else
        {
            return false;
        }
    }

    public void Update(float dt = -1)
    {
        UnityEngine.Profiling.Profiler.BeginSample("SCROOT");
        if (gScRoots != null)
        {
            gScRoots.Update(dt < 0 ? Time.deltaTime : dt);
        }
        UnityEngine.Profiling.Profiler.EndSample();
        if (Astar != null)
        {
            Astar.Update();
        }
        UpdateGameOverState();

    }
    public bool CanCreateUnit(int tableId, Vector3 pos)
    {
        if (pos.y > 0.01)
            return false;

        if (gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().IsCrossFireLine(tableId, pos, 0))
        {
            return false;
        }

        return HasValidUnitPos(tableId, pos);
    }

    public bool HasValidUnitPos(int tableId, Vector3 pos)
    {
        var validPosList = GetValidUnitPos(tableId, pos);
        return validPosList != null && validPosList.Count > 0;
    }

    public List<Vector3> GetValidUnitPos(int talbeid, Vector3 pos)
    {
        GroupObj.transform.position = pos;
        Vector3[] _posV = new Vector3[GroupObj.transform.childCount];
        for (int i = 0; i < _posV.Length; ++i)
        {
            _posV[i] = GroupObj.transform.GetChild(i).localPosition;
        }

        return gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().GetGroupUnitPosition(talbeid, pos, _posV);
    }

    public void SetTeamCoef(int teamid, Serclimax.Unit.ScUnitDefenseCoef coef)
    {
        Serclimax.Unit.ScUnitDefenseCoef c = gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().GetCoef(teamid);
        c.DamageBonuses1013 = coef.DamageBonuses1013;
        c.DamageBonuses1022 = coef.DamageBonuses1022;
        c.DamageReduction1021 = coef.DamageReduction1021;
        c.DamageReduction1023 = coef.DamageReduction1023;
    }

    public string CreateUnit2RedCmd(int unit_id, int tableid, Vector3 pos, Serclimax.Unit.ScUnitBonus bonus = null)
    {
        if (pos.y > 0.01)
            return null;

        if (gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().IsCrossFireLine(tableid, pos, 0))
        {
            return null;
        }
        if (GroupObj == null)
            return null;

        GroupObj.transform.position = pos;
        Vector3[] _posV = new Vector3[GroupObj.transform.childCount];
        for (int i = 0; i < _posV.Length; ++i)
        {
            _posV[i] = GroupObj.transform.GetChild(i).localPosition;
        }

        Serclimax.ScRecordMgr.RedCommand[] cmds = gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().CreateGroupUnit2RedCmd(unit_id, tableid, pos, _posV, bonus);
        return gScRoots.GetMgr<Serclimax.ScRecordMgr>().RedCmd2Str(cmds);
    }

    public void CreateUnit4RedCmd(string str)
    {
        gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().CreateGroupUnit4RedCmd(gScRoots.GetMgr<Serclimax.ScRecordMgr>().Str2RedCmd(str));
    }

    public bool CreateUnit(int unit_id, int tableid, Vector3 pos, Serclimax.Unit.ScUnitBonus bonus = null)
    {
        if (pos.y > 0.01)
            return false;

        if (gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().IsCrossFireLine(tableid, pos, 0))
        {
            return false;
        }
        if (GroupObj == null)
            return false;

        GroupObj.transform.position = pos;
        Vector3[] _posV = new Vector3[GroupObj.transform.childCount];
        for (int i = 0; i < _posV.Length; ++i)
        {
            _posV[i] = GroupObj.transform.GetChild(i).localPosition;
        }


        return gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().CreateGroupUnit(unit_id, tableid, pos, _posV, bonus);

        /*
        Serclimax.Unit.ScUnitGroupData group = gScTableData.GetTable<Serclimax.Unit.ScUnitGroupData>().GetData(tableid);
        //BattleGroupInfo.Data group = ClientTableDataManager.Instance.FindGroupData(tableid);
        if (group == null)
        {
            Debug.LogError("wrong group id");
            return;
        }
        for (int i = 0; i < group._UnitGroupNum; ++i)
        {
            Serclimax.Unit.ScUnit unit = gScRoots.GetMgr<Serclimax.Unit.ScUnitMgr>().CreateSoldier(group._UnitGroupUnitId, pos, Vector3.zero, 1) as Serclimax.Unit.ScUnit;
            unit.Active();
        }
         * */
    }

    public bool PointIsWalkable(Vector3 Pos)
    {
        return true;
        //return Astar.astarData.gridGraph.PointOnGraphIsWalkable(Pos);
    }
    #endregion

    #region Msgercl
    public void DisposeLevelGlobelMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
    {
        if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_GAMEOVER_MSG)
            return;

        Serclimax.Level.ScGlobalLevelMsg slmsg = msg as Serclimax.Level.ScGlobalLevelMsg;
        gameWin = slmsg.mCommand.cmdGameOver == Serclimax.Level.ScGlobalLevelMsg.GameResoult.GOERESULT_WIN ? true : false;
        GameStateBattle stateBattle = Main.Instance.CurrentGameState as GameStateBattle;
        if (stateBattle != null)
        {
            int ws = slmsg.mCommand.cmdGOType == Serclimax.Level.ScGlobalLevelMsg.GameOver_Type.GOTYPE_TIMESOUT ? 0 : (gameWin ? 1 : -1);
            stateBattle.RequsetPVPBattleEnd(ws);
        }
        StartGameOverState();


        return;
    }
    public void DisposeActiveGuideMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
    {
        if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_ACTIVE_GUIDE_MSG)
            return;
        Serclimax.Level.ScLevelGuideMsg slmsg = msg as Serclimax.Level.ScLevelGuideMsg;
        Vector3 posParam = new Vector3(slmsg.mCommand.tartPosX, slmsg.mCommand.tartPosY, slmsg.mCommand.tartPosZ);

        GuideManager.instance.StartGuide(slmsg.mCommand.guideGroupId, posParam);
        return;
    }
    public void DisposeActiveLevelHintMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
    {
        if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_ACTIVE_BATTLEHINT_MSG)
            return;
        Serclimax.Level.ScLevelHintMsg hintMsg = msg as Serclimax.Level.ScLevelHintMsg;
        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
        if (inGame != null)
        {
            inGame.CallFunc("ShowIngameHint", hintMsg.mCommand.battleHint);
        }


        return;
    }

    public void DisposeProductionStartMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
    {
        if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_PRODUCTION_START_MSG)
            return;

        Serclimax.Level.ScProductionStartMsg startMsg = msg as Serclimax.Level.ScProductionStartMsg;
        Camera uiMainCamera = UICamera.mainCamera;
        Vector3 targetPos = new Vector3(startMsg.mCommand.tartPosX, startMsg.mCommand.tartPosY, startMsg.mCommand.tartPosZ);
        Vector3 uipos = Camera.main.WorldToScreenPoint(targetPos + Vector3.up * 4);

        if (uiMainCamera != null)
        {
            Vector3 worldPos = uiMainCamera.ScreenToWorldPoint(uipos);
            worldPos.z = 0;
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null && startMsg.mCommand.teamId != 1)
            {
                object[] param = new object[6];
                param[0] = startMsg.mCommand.id;
                param[1] = startMsg.mCommand.active;
                param[2] = startMsg.mCommand.timeSpan;
                param[3] = startMsg.mCommand.tartPosX;
                param[4] = startMsg.mCommand.tartPosY;
                param[5] = startMsg.mCommand.tartPosZ;
                inGame.CallFunc("AddEventCD", param);
            }


            //Vector3 lp = GuideUi.localPosition;
            //lp.x = Mathf.RoundToInt(lp.x);
            //lp.y = Mathf.RoundToInt(lp.y);
        }


        return;
    }
    public void DisposeRagionUpdateMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
    {
        if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_RAGION_UPDATE_MSG)
            return;
        Serclimax.Level.ScRagionUpdateMsg slmsg = msg as Serclimax.Level.ScRagionUpdateMsg;
        GameObject rUpdateObj = GameObject.Find(slmsg.mCommand.RagionUpdateName);
        if (rUpdateObj != null)
        {
            rUpdateObj.SetActive(slmsg.mCommand.RagionUpdateFlag);
        }
        //GuideManager.instance.StartGuide(slmsg.mCommand.RagionUpdateName);
        return;
    }

    public void DisposeScreenLockMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
    {
        if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_SCREENLOCAK_MSG)
            return;
        Serclimax.Event.ScLockStatusMsg scLockStatusMsg = msg as Serclimax.Event.ScLockStatusMsg;
        if (scLockStatusMsg.status == Serclimax.Event.ScLockStatus.Lock)
        {
            isScreenLock = true;
        }
        else
        {
            isScreenLock = false;
        }
        return;
    }
    public void OnLoadFinished()
    {
        if (onSceneLoadFinished != null)
        {
            onSceneLoadFinished();
        }
    }
    #endregion

    #region GameOverState
    private GameOverStateType mGameState = GameOverStateType.GOST_NIL;

    public GameOverStateType gameOverState
    {
        get
        {
            return mGameState;
        }
    }
    public enum GameOverStateType
    {
        GOST_NIL,
        GOST_INIT,
        GOST_MOVE_CAM,
        GOST_ANIM,
        GOST_SHOW_UI,
    }
    private void StartGameOverState()
    {
        mGameState = GameOverStateType.GOST_INIT;
    }


    private void UpdateGameOverState()
    {
        if (mGameState == GameOverStateType.GOST_NIL)
            return;
        switch (mGameState)
        {
            case GameOverStateType.GOST_INIT:
                GameOverInit(Serclimax.GameTime.deltaTime);
                break;
            case GameOverStateType.GOST_MOVE_CAM:
                GameOverMoveGam(Serclimax.GameTime.deltaTime);
                break;
            case GameOverStateType.GOST_ANIM:
                GameOverAnim(Serclimax.GameTime.deltaTime);
                break;
            case GameOverStateType.GOST_SHOW_UI:
                GameOverEnd(Serclimax.GameTime.deltaTime);
                break;
        }
    }

    private void GameOverInit(float time)
    {
        if (mGameState != GameOverStateType.GOST_INIT)
            return;
        GameObject obj = GetFireline();
        if (obj != null)
            obj.SetActive(false);
        GuideManager.instance.Finish();

        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
        if (inGame != null)
        {
            inGame.CallFunc("FadeOutUI", null);
        }
        if (gameWin)
        {
            int count = CsUnitMgr.Instance.mFailedGroupUnits.Count;
            if (count <= 0)
            {
                mWaitTimeScale = -1;
                mGameState = GameOverStateType.GOST_ANIM;
            }
            else
            {
                for (int i = 0; i < count; i++)
                {
                    if (CsUnitMgr.Instance.mFailedGroupUnits[i].IsDead)
                    {
                        mTarget = CsUnitMgr.Instance.mFailedGroupUnits[i];
                        break;
                    }
                }

                mGameState = GameOverStateType.GOST_MOVE_CAM;
            }
        }
        else
        {
            //Camera cam = Camera.main;
            //if (cam != null)
            //{
            //    CsGrayEffectController ge =  cam.gameObject.AddComponent<CsGrayEffectController>();
            //    ge.ToGary(true, 1);
            //}

            if (Entity.PostEffect != null)
            {
                Entity.PostEffect.TweenGary(true, 1);
            }

            int count = CsUnitMgr.Instance.mSuccessGroupUnits.Count;
            if (count <= 0)
            {
                mWaitTimeScale = -1;
                mGameState = GameOverStateType.GOST_ANIM;
            }
            else
            {
                for (int i = 0; i < count; i++)
                {
                    if (CsUnitMgr.Instance.mSuccessGroupUnits[i].IsDead)
                    {
                        mTarget = CsUnitMgr.Instance.mSuccessGroupUnits[i];
                        break;
                    }
                }

                mGameState = GameOverStateType.GOST_MOVE_CAM;
            }
        }


        mWaitMoveCam = -1;
    }
    private CsUnit mTarget = null;
    float mWaitMoveCam = -1;
    private void GameOverMoveGam(float time)
    {
        if (mGameState != GameOverStateType.GOST_MOVE_CAM)
            return;
        if (mTarget == null)
        {
            mGameState = GameOverStateType.GOST_ANIM;
            return;
        }
        if (mWaitMoveCam < 0)
        {
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {
                inGame.CallFunc("SetCameraFollowPosition", mTarget.transform.position);
            }
            mWaitMoveCam = 0;
        }
        if (mWaitMoveCam < 0.5f)
        {
            mWaitMoveCam += time;
        }
        else
        {
            mWaitTimeScale = -1;
            mGameState = GameOverStateType.GOST_ANIM;
        }
    }



    private float mWaitTimeScale = -1;
    private void GameOverAnim(float time)
    {
        if (mGameState != GameOverStateType.GOST_ANIM)
            return;
        if (mWaitTimeScale < 0)
        {
            if (mTarget != null)
            {
                mTarget.Syncer.Command("dead");
            }
            mTarget = null;
            mWaitTimeScale = Time.realtimeSinceStartup;
        }
        if (Time.realtimeSinceStartup - mWaitTimeScale < GameOverAnimTotalTime)
        {
            Serclimax.GameTime.timeScale = easeOutCubic(1, GameOverMinTimeScale, (Time.realtimeSinceStartup - mWaitTimeScale) / GameOverAnimTotalTime);
        }
        else
        {
            Serclimax.GameTime.timeScale = 1;
            CsBakeBatchesMgr.Instance.NeedUPdateBakeObj = false;
            CsUnitMgr.Instance.IgnoreDisposeMsg = true;
            CsSkillMgr.Instance.IgnoreDisposeMsg = true;
            mGameState = GameOverStateType.GOST_SHOW_UI;
        }

    }
    private float easeOutCubic(float start, float end, float value)
    {
        value--;
        end -= start;
        return end * (value * value * value + 1) + start;
    }
    private void GameOverEnd(float time)
    {
        if (mGameState != GameOverStateType.GOST_SHOW_UI)
            return;

        AudioManager.Instance.StopMusic();
        if (GameWin)
            AudioManager.Instance.PlayCommonSfx("victory");

        if (onGameOver != null)
        {
            onGameOver();
        }
        mGameState = GameOverStateType.GOST_NIL;
    }
    #endregion

    public void DebugTest(Vector3 pos)
    {
        Debug.LogError("pos : " + pos);
    }
    public void TouchTest()
    {
        Vector3 tPos = UICamera.currentTouch.pos;
        Ray ray = Camera.main.ScreenPointToRay(tPos);
        float distance = Camera.main.farClipPlane - Camera.main.nearClipPlane;
        RaycastHit hitInfo;
        if (Physics.Raycast(ray, out hitInfo, distance, LayerMask.GetMask("masklayer")))
        {
            Debug.LogError("hitpoint : " + hitInfo.point);
        }
        else
        {
            Debug.LogError("cast nothing");
        }
    }
    public void GCManual()
    {
        Debug.Log("gc with manual");
        GC.Collect();
    }

    public void AddUnlockMaxAmryID(int base_id, int max_id)
    {
        if (gScRoots == null)
            return;
        gScRoots.Battle.SetAmryMaxID(base_id, max_id);
    }

    public GameObject[] GetMaskObjs()
    {
        if (Entity == null)
            return null;
        return Entity.MaskObjs;
    }

    [LuaInterface.LuaByteBufferAttribute]
    public delegate void CallbackFunc(uint _seq_id, byte[] _data);

    public bool RequestEscapeBattle(uint id, bool escape, bool win, int star, uint battleTime, CallbackFunc _callback)
    {
        if (gScRoots != null)
        {
            ProtoMsg.MsgBattleEndRequest req = new ProtoMsg.MsgBattleEndRequest();
            req.chapterlevel = id;
            req.escape = escape;
            req.win = win;
            req.battleTime = battleTime;
            req.star.Add(star/100 >= 1);
            req.star.Add((star%100)/10 >= 1);
            req.star.Add((star%100)%10 >= 1);
            
            req.verifyData = gScRoots.GetMgr<Serclimax.ScCollectorMgr>().ToProtoMsg();
            NetworkManager.instance.Request<ProtoMsg.MsgBattleEndRequest>((uint)ProtoMsg.MsgCategory.Battle,
                (uint)ProtoMsg.BattleTypeId.Battle.MsgBattleEndRequest, req, (data) =>
            {
                if (_callback != null)
                {
                    _callback((uint)ProtoMsg.BattleTypeId.Battle.MsgBattleEndRequest, data);
                }
            });
            return true;
        }
        else
        {
            return false;
        }
    }
}
