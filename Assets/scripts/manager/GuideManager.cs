using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.IO;
using UnityEngine.SceneManagement;
using UnityEngine;
using Clishow;
using Serclimax;
using LuaInterface;

public class GuideManager
{
    public enum eIngameUiButtonType
    {
        BType_Solider = 1,
        BType_Skill = 2,
    }
    static GuideManager mInstance;
    public static GuideManager instance
    {
        get
        {
            if (mInstance == null)
            {
                mInstance = new GuideManager();
            }
            return mInstance;
        }
    }
    private Serclimax.ScTableData<Serclimax.GuideInfoData> mGuideInfo;
    public Serclimax.ScTableData<Serclimax.GuideInfoData> GuideIngo
    {
        get
        {
            if (mGuideInfo == null)
            {
                mGuideInfo = Main.Instance.TableMgr.GetTable<Serclimax.GuideInfoData>();
            }
            return mGuideInfo;
        }
    }
    private Serclimax.ScTableData<Serclimax.GuideIngameUiData> mGuideIngameUiData;
    public Serclimax.ScTableData<Serclimax.GuideIngameUiData> GuideIngameUiData
    {
        get
        {
            if (mGuideIngameUiData == null)
            {
                mGuideIngameUiData = Main.Instance.TableMgr.GetTable<Serclimax.GuideIngameUiData>();
            }
            return mGuideIngameUiData;
        }
    }

    public Dictionary<int, GuideGroup> mGuideGroups = new Dictionary<int, GuideGroup>();
    public List<Serclimax.GuideIngameUiData> mGuideIngameData = new List<Serclimax.GuideIngameUiData>();
    public GuideGroup mCurGroup;
    public GuideStepBase mCurGuideStep;
    public bool mPlayTittle = false;
    [LuaInterface.LuaByteBufferAttribute]
    public delegate void FinishCallbackFunc();

    private bool mInited = false;

    public void Init()
    {
        //if(mInited)
        //    return;
        mInited = true;
        mPlayTittle = false;
        if (GuideIngo != null)
        {
            List<int> gKeys = new List<int>(GuideIngo.Data.Keys);
            for (int i = 0; i < gKeys.Count; ++i)
            {
                Serclimax.GuideInfoData guideInfo = GuideIngo.GetData(gKeys[i]);
                AddGuide(guideInfo);
            }
        }

        if (GuideIngameUiData != null)
        {
            foreach (KeyValuePair<int, Serclimax.GuideIngameUiData> iData in GuideIngameUiData.Data)
            {
                if (iData.Value._battle == GameStateBattle.Instance.BattleId)
                {
                    mGuideIngameData.Add(iData.Value);
                }
            }
        }
    }

    public void StartGuide(int guideid, object param = null, FinishCallbackFunc finishcb = null)
    {
        //if (GuideProcess(guideid))
        //{
        //    //FinishPreBattle();
        //    CsBattle.Instance.NotifyTitleFinished();
        //    return;
        //}




        if (mGuideGroups.ContainsKey(guideid))
        {
            //检查是否还有未结束的其他引导，如果有先将其设置为完成
            foreach(var v in mGuideGroups)
            {
                GuideGroup group = v.Value as GuideGroup;
                if(group != null && group.IsProcessing && v.Key != guideid)
                {
                    group.Finish();
                }
            }


            mCurGroup = mGuideGroups[guideid];
            LuaFunction luaFunc = LuaClient.GetMainState().GetFunction("ChapterListData.HasLevelExplored");
            var ret = luaFunc.Call(mCurGroup.mGuideStepData[0]._guide_chapter);
            luaFunc.Dispose();
            bool finished = (bool)ret[0];
            mCurGroup.mParams = param;


            if (!mCurGroup.IsFinish && !mCurGroup.IsProcessing && !finished)
            {
                mCurGroup.Start(finishcb);
            }
            else
            {
                mCurGroup = null;
            }
        }
    }
    public void OnIngameUI(int buttomType, int selectIndex)
    {
        foreach (Serclimax.GuideIngameUiData ingameGuide in mGuideIngameData)
        {
            if (buttomType == ingameGuide._button && selectIndex == ingameGuide._select)
            {
                StartGuide(ingameGuide._guide);
            }
        }
    }
    public void update(float _dt)
    {
        if (mCurGroup != null)
        {
            mCurGroup.Update(_dt);
            if (mCurGroup.IsFinish)
            {
                mCurGroup = null;
            }
        }
    }
    public void AddGuide(Serclimax.GuideInfoData gdata)
    {
        if (!mGuideGroups.ContainsKey(gdata._guide_type))
        {
            mGuideGroups[gdata._guide_type] = new GuideGroup(gdata._guide_type);
        }
        mGuideGroups[gdata._guide_type].mGuideStepData.Add(gdata);
    }
    public void Clear()
    {
        mGuideGroups.Clear();
        mGuideIngameData.Clear();
        mCurGroup = null;
    }
    public void Finish()
    {
        if (mCurGroup != null)
        {
            mCurGroup.Finish();
        }
        Clear();
    }
    public void SaveGuideProcess()
    {
        string guideSaveData = GameSetting.instance.GetSavingData(GameSetting.ESavingType.eGuide);
        foreach (KeyValuePair<int, GuideGroup> group in mGuideGroups)
        {
            if (group.Value.mGuideChain == null || group.Value.mGuideChain.Count == 0)
                continue;

            if (group.Value.IsFinish && group.Value.mGuideChain[0].Data._guide_issave == 1)
            {
                guideSaveData += "" + group.Key + ",";
                ///PlayerPrefs.SetInt(saveKey, 1);
            }
        }
        GameSetting.instance.SetSavingData(GameSetting.ESavingType.eGuide, guideSaveData);
    }
    public bool GuideProcess(int groupid)
    {
        string saveKey = GameSetting.instance.GetSavingData(GameSetting.ESavingType.eGuide);
        if (saveKey == string.Empty)
            return false;

        string[] guiderec = saveKey.Split(',');
        for (int i = 0; i < guiderec.Length; ++i)
        {
            if (guiderec[i] == null || guiderec[i] == string.Empty)
                continue;

            int guide = int.Parse(guiderec[i]);
            if (guide == groupid)
            {
                return true;
            }
        }
        return false;
    }
    public void FinishPreBattle()
    {
        int battleid = GameStateBattle.Instance.BattleId;
        var battelData = Main.Instance.GetTableMgr().GetBattleData(battleid);
        if (battelData != null)
        {
            if (battelData.preBattle == 1 && !mPlayTittle)
            {
                LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
                if (inGame != null)
                {
                    inGame.CallFunc("PlayTitle", null);
                    mPlayTittle = true;
                }
            }
        }
    }
    public void InPause()
    {
        if (mCurGroup != null)
        {
            if (mCurGroup.mCurGuideStep != null && !mCurGroup.IsFinish)
            {
                if (mCurGroup.mCurGuideStep.StepUI != null)
                    mCurGroup.mCurGuideStep.StepUI.gameObject.SetActive(false);
            }
        }
    }
    public void Resume()
    {
        if (mCurGroup != null)
        {
            if (mCurGroup.mCurGuideStep != null && !mCurGroup.IsFinish)
            {
                if (mCurGroup.mCurGuideStep.StepUI != null)
                    mCurGroup.mCurGuideStep.StepUI.gameObject.SetActive(true);
            }
        }
    }
}
public class GuideGroup
{
    public List<Serclimax.GuideInfoData> mGuideStepData = new List<Serclimax.GuideInfoData>();
    public List<GuideStepBase> mGuideChain = new List<GuideStepBase>();
    public GuideStepBase mCurGuideStep = null;
    public int mCurStepIndex = -1;
    private int mGroupId;
    private Transform GuideUi = null;
    private bool mIsProcessing = false;
    private GuideManager.FinishCallbackFunc mFinishCB = null;
    public object mParams = null;

    public bool IsProcessing
    {
        get
        {
            return mCurStepIndex > 0 && mCurStepIndex < mGuideChain.Count;
        }
    }
    private bool mIsFinish = false;
    public bool IsFinish
    {
        get
        {
            return mIsFinish;
        }
    }

    public GuideGroup(int groupid)
    {
        mGroupId = groupid;
        mFinishCB = null;
    }

    public GuideStepBase BuildStep(Serclimax.GuideInfoData guInfo, Transform target_ui, GuideGroup group)
    {
        GuideStepBase gsBase = new GuideStepBase(guInfo, target_ui, group);
        return gsBase;
    }

    public void Start(GuideManager.FinishCallbackFunc finishcb = null)
    {
        mCurStepIndex = 0;
        mGuideChain.Clear();
        mFinishCB = finishcb;
        if (mGuideStepData.Count == 0)
        {
            mIsFinish = true;
            if (mFinishCB != null)
                mFinishCB();
            mFinishCB = null;
            return;
        }

        LoadUI(mGuideStepData[0]);
        for (int i = 0; i < mGuideStepData.Count; ++i)
        {
            GuideStepBase gsb = BuildStep(mGuideStepData[i], GuideUi, this);
            mGuideChain.Add(gsb);
        }

        mCurGuideStep = mGuideChain[mCurStepIndex];
        if (mCurGuideStep != null)
        {
            mCurGuideStep.Init();
        }
    }
    public void LoadUI(Serclimax.GuideInfoData guInfo)
    {
        string uiPrefab = guInfo._guide_prefab;
        if (uiPrefab != string.Empty)
        {
            GameObject Ui = GameObject.Find(uiPrefab);
            if (Ui == null)
            {
                GUIMgr.Instance.CreateMenu(uiPrefab, true);
            }
            GuideUi = GameObject.Find(uiPrefab).transform;
        }
    }
    public void Update(float _dt)
    {
        if (!mCurGuideStep.OnStart(_dt))
            return;

        if (!mCurGuideStep.IsFinish(_dt))
            mCurGuideStep.OnUpdate(_dt);
        else
        {
            mCurGuideStep.OnFinish();
            NextStep();
        }

    }
    public void NextStep()
    {
        mCurStepIndex += 1;
        if (mCurStepIndex < mGuideChain.Count)
        {
            mCurGuideStep = mGuideChain[mCurStepIndex];
            mCurGuideStep.Init();
        }
        else
        {
            mIsFinish = true;
            mCurStepIndex = 0;
            if (mFinishCB != null)
                mFinishCB();
            mFinishCB = null;
            //如果引导在战斗前置状态触发，则引导完成后要设置战斗状态跳转为正式战斗状态
            GuideManager.instance.FinishPreBattle();
        }
    }
    public void Finish()
    {
        if (mCurGuideStep != null)
            mCurGuideStep.OnFinish();
        mCurStepIndex = 0;
        mGuideChain.Clear();
        mIsFinish = true;
        if (mFinishCB != null)
            mFinishCB();
        mFinishCB = null;
    }
}

public class GuideStepBase
{
    public enum ePauseType
    {

        _NOPAUSE,
        _PAUSE,
        _NOPAUSE_WHENOVER,
    }

    private Transform GuideUi = null;
    public Transform StepUI
    {
        get { return GuideUi; }

    }
    public Transform DisplayPart = null;
    private float responseTime = 0;
    private float passTime = 0;
    public GuideStepBase.ePauseType pauseType;

    public GuideGroup mGroup;
    private List<string> mStepOverParams = new List<string>();


    public Serclimax.GuideInfoData Data;

    private GuideStart guiStart = null;
    private GuideOver guiOver = null;
    private GuideUpdate guiUpdate = null;

    public GuideStepBase(Serclimax.GuideInfoData data, Transform target_ui, GuideGroup group)
    {
        mGroup = group;
        Data = data;
        GuideUi = target_ui;
        pauseType = (GuideStepBase.ePauseType)Data._guide_ispause;
        //start
        switch (data._guide_start)
        {
            case 0:
                guiStart = new GuideStartWaitTime(this, data, GuideUi);
                break;
            case 1:
                guiStart = new GuideStartWaitCall(this, data, GuideUi);
                break;
            case 2:
                guiStart = new GuideStartCheckSpecialArmy(this, data, GuideUi);
                break;
            default:
                break;
        }

        //over
        switch (data._guide_restype)
        {
            case 1:
                guiOver = new GuideOverPress(this, data, GuideUi);
                break;
            case 2:
                guiOver = new GuideOverMoveCamera(this, data, GuideUi);
                break;
            case 3:
                guiOver = new GuideOverAutoMoveCamera(this, data, GuideUi);
                break;
            case 4:
                guiOver = new GuideOverWaitTime(this, data, GuideUi);
                break;
            case 5:
                guiOver = new GuideOverPressWithOneParam(this, data, GuideUi);
                break;
            default:
                break;
        }

        //update
        switch (data._guide_update)
        {
            case 0:
                guiUpdate = new GuideUpdate(this, data, GuideUi);
                break;
            case 1://建筑闪烁
                guiUpdate = new GuideUpdateBuildFlash(this, data, GuideUi);
                break;
            case 2://区域闪烁
                guiUpdate = new GuideUpdateRegionFlash(this, data, GuideUi);
                break;
            //             case 4://单位闪烁
            //                 guiUpdate = new GuideUpdateUnitFlash(this, data, GuideUi);
            //                 break;
            case 4:
                guiUpdate = new GuideUpdateActiveMenuObj(this, data, GuideUi);
                break;
            case 5:
                guiUpdate = new GuideUpdateUnlockSoldier(this, data, GuideUi);

                break;
            case 6:
                guiUpdate = new GuideUpdateUnlockHero(this, data, GuideUi);
                break;

            case 7:
                guiUpdate = new GuideUpdateActiveUIPoint(this, data, GuideUi);
                break;
            case 8:
                guiUpdate = new GuideUpdateOpenUI(this, data, GuideUi);
                break;

            default:
                break;
        }

    }
    public void Init()
    {

        //display
        /*
        DisplayPart = GuideUi.transform.FindChild(Data._guide_display);
        if (DisplayPart != null)
        {
            if (!DisplayPart.gameObject.activeSelf)
                DisplayPart.gameObject.SetActive(true);
        }
        //text
        string textp = Data._guide_display + "/bg/text_guide";
        Transform textTrf = GuideUi.transform.FindChild(textp);
        if(textTrf != null)
        {
            textTrf.GetComponent<UILabel>().text = TextManager.Instance.GetText( Data._guide_text);
            textTrf.GetComponent<TypewriterEffect>().ResetToBeginning();
        }
        */
        //response time
        responseTime = Data._guide_updateparam1;
        passTime = 0;
        guiStart.Init();
        guiOver.Init();
        guiUpdate.Init();
    }
    public virtual bool OnStart(float dt)
    {
        return guiStart.Start(dt);
    }

    public virtual void OnUpdate(float _dt)
    {
        guiUpdate.Update(_dt);
    }
    public virtual void OnFinish()
    {
        if (SceneManager.instance.gScRoots != null)
            SceneManager.instance.gScRoots.GamePaused = false;
        if (DisplayPart != null)
        {
            DisplayPart.gameObject.SetActive(false);
        }
        guiUpdate.Finish();
        guiOver.Finished();
        //GUIMgr.Instance.CloseMenu(Data._guide_prefab);
    }
    public bool IsFinish(float dt)
    {
        passTime += dt;
        if (passTime < responseTime)
        {
            return false;
        }
        return guiOver.IsFinish(dt);
    }

    public void SetGui(Transform ui)
    {
        GuideUi = ui;
    }
    public void AddStepOverParam(string param)
    {
        mStepOverParams.Add(param);
    }
    public List<string> GetStepParam()
    {
        return mStepOverParams;
    }
    public bool GetStepStartStatus()
    {
        return guiStart.GetStarStatus();
    }
}
