using UnityEngine;
using System.Collections;

using System;
using System.Collections.Generic;
using System.Xml;
using System.IO;
using UnityEngine.SceneManagement;
using Clishow;
using ProtoMsg;


public class HeroBuffShowInfo
{
    public int[] HeroBuffIds = new int[120];
}

public class CsSLGPVPHudPoolMgr
{
    public static string HudPath = "UnitHud";
    public static float hudPosHeight = 2;
    public static int hudWidth = 120;
    public static int hudHeight = 8;
    public static string[] EffectPath = { "PVPRed", "PVPBlue", "PVPYellow" };

    private Queue<UnitHud> mRedHudList = new Queue<UnitHud>();

    private Queue<UnitHud> mBlueHudList = new Queue<UnitHud>();

    public void Clear()
    {
        while (mRedHudList.Count != 0)
        {
            UnitHud hud = mRedHudList.Dequeue();
            GameObject.Destroy(hud.gameObject);
        }
        while (mBlueHudList.Count != 0)
        {
            UnitHud hud = mBlueHudList.Dequeue();
            GameObject.Destroy(hud.gameObject);
        }
    }

    public UnitHud CreateHud(Vector3 pos, float hp, bool red)
    {
        UnitHud hud = CreateHud(red);
        UIPBAnimController pb = hud.GetComponentInChildren<UIPBAnimController>();
        if (pb != null)
        {
            GameObject.Destroy(pb);
        }
        hud.gameObject.SetActive(true);

        LuaBehaviour ui = GUIMgr.Instance.FindMenu("PVP_SLG");
        if (ui != null)
        {
            ui.CallFunc("AddHud", hud.gameObject);
        }
        hud.SetTarget(Camera.main, pos + Vector3.up * hudPosHeight);
        hud.AlwaysShow = true;
        hud.Show();
        hud.InitHp(hp);
        return hud;
    }

    public void RecoverHud(bool red, UnitHud hud)
    {
        if (hud == null)
            return;
        hud.transform.parent = null;
        hud.Hide(true);
        hud.gameObject.SetActive(false);
        if (red)
        {
            mRedHudList.Enqueue(hud);
        }
        else
        {
            mBlueHudList.Enqueue(hud);
        }
    }

    public UnitHud CreateHud(bool red)
    {
        UnitHud hud = null;
        if (red)
        {
            if (mRedHudList.Count != 0)
                hud = mRedHudList.Dequeue();
        }
        else
        {
            if (mBlueHudList.Count != 0)
                hud = mBlueHudList.Dequeue();
        }
        if (hud != null)
        {

            return hud;
        }

        string path = HudPath;
        if (red)
        {
            path += "Red";
        }
        GameObject obj = ResourceLibrary.GetUnitHudInstanceFromPool(path);
        if (obj != null)
        {
            hud = obj.GetComponent<UnitHud>();
            obj.name = obj.name + "_" + path;
            if (hud == null)
            {
                hud = obj.AddComponent<UnitHud>();
            }
            hud.SetSize(hudWidth, hudHeight);
        }
        return hud;
    }
}

public class CsSLGPVPBattleController
{
    public static string[] RestraintEffects = { "jiagong", "dunbuff", "jiaxue" };

    private GameObject mSObj;

    private Camera mCamera;

    private Camera mUICamera;

    private Animation mCamAnim;

    private Vector3 mCamStartPos;

    private Quaternion mCamStartRotate;

    private Serclimax.SLGPVP.ScBattCamp mACamp;

    private Serclimax.SLGPVP.ScBattCamp mDCamp;

    private bool mNeedUpdateCamAnim = false;

    private bool mStartBattle = false;

    public bool IsStartBattle
    {
        get
        {
            return mStartBattle;
        }
    }

    private Serclimax.ScRoot mScRoot;

    private float mMoveTotalTime = 0;

    private float mMoveTime = 0;

    private float mDelayStartTime = 0;

    private bool mNeedUpdateMove = false;

    private UnitHud[] mHud = new UnitHud[3];
    private GameObject[] mHudEffect = new GameObject[3];
    private bool[] mHudRed = new bool[3];
    private float[] mShowTimes = new float[6];
    private int mCurShowIndex = 0;
    private float mCurShowTime = 0;

    private float mDelayRecoverHud = 0;

    private Serclimax.SLGPVP.ScSLGPVPBattle mBattle;

    public Serclimax.SLGPVP.ScSLGPVPBattle Battle
    {
        get
        {
            return mBattle;
        }
    }

    private CsSLGPVPHudPoolMgr mHudPool;

    public CsSLGPVPHudPoolMgr HudPool
    {
        get
        {
            return mHudPool;
        }
    }

    public bool isBattleEnd()
    {
        if (mBattle == null)
            return false;
        if (mNeedUpdateCamAnim)
            return false;
        return mBattle.IsBattleEnd;
    }

    public void BattleEnd()
    {
        if (mBattle == null)
            return;
        mBattle.BattleEnd();
    }

    public CsSLGPVPBattleController(GameObject obj, Serclimax.ScRoot root, Serclimax.SLGPVP.ScSLGPVPInfo info)
    {
        mSObj = obj;
        mUICamera = UICamera.mainCamera;
        mCamera = mSObj.GetComponentInChildren<Camera>();
        mCamera.fieldOfView = 42;
        mScRoot = root;
        mBattle = new Serclimax.SLGPVP.ScSLGPVPBattle(info, mScRoot);
        mHudPool = new CsSLGPVPHudPoolMgr();
    }

    public void InitBattle(bool enable_log)
    {
        mBattle.EnableLog = enable_log;
        mBattle.OnDisposeMsg = OnDisposeMsg;
        //Serclimax.SLGPVP.ScSLGPVPBattle.AttackTime = float.Parse(mScRoot.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.SLGPVPAttackTime).value);
        //Serclimax.SLGPVP.ScSLGPVPBattle.AttackRoundWaitTime = float.Parse(mScRoot.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.SLGPVPAttackRoundWaitTime).value);
        mBattle.InitBattle();
        mMoveTotalTime = float.Parse(mScRoot.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.SLGPVPMoveAnimTime).value);
        mMoveTime = 0;

        mACamp = mBattle.GetCamp4Slg(mBattle.ACamp);
        mDCamp = mBattle.GetCamp4Slg(mBattle.DCamp);
        //mACamp.SetPVPUnitMovedTarget(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[2], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[3]);
        //mDCamp.SetPVPUnitMovedTarget(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[0], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[1]);
        //mACamp.UpdateMove(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[2], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[3], 0);
        //mDCamp.UpdateMove(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[0], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[1], 0);
        mStartBattle = false;
        mDelayStartTime = 5;
        mShowTimes[0] = 1;
        mShowTimes[1] = 1;
        mShowTimes[2] = 1;
        mShowTimes[3] = 1;
        mShowTimes[4] = 0.5f;
        mShowTimes[5] = 2.5f;
        mCurShowIndex = 0;
        mCurShowTime = 0;
    }

    public void ClearEffect()
    {
        mBattle.Destroy();
        mHudPool.Clear();
    }

    public void StartCamAnim(string anim_name)
    {
        if (mCamera == null)
            return;

        AnimationClip clip = Resources.Load<AnimationClip>("SLGPVP/" + anim_name);
        if (clip == null)
        {
            Vector3 pos = mCamera.transform.position;
            pos.x = 0;
            mCamera.transform.position = pos;
            return;
        }
        mNeedUpdateCamAnim = true;
        mNeedUpdateMove = true;

        mCamAnim = mCamera.gameObject.AddComponent<Animation>();
        mCamAnim.AddClip(clip, anim_name);
        mCamAnim.Play(anim_name);
    }

    public void SkipCamAnim()
    {
        if (mCamAnim == null || !mNeedUpdateCamAnim)
        {
            if (mCurShowIndex <= 4)
            {
                if (GameStateSLGBattle.Instance.onSkipShowHeroFinish != null)
                {
                    GameStateSLGBattle.Instance.onSkipShowHeroFinish();
                }
                mDelayStartTime = 1f;
                mCurShowIndex = 5;
                //DisposeHeroBuff(CsSLGPVPMgr.instance.HeroBuffs, mCurShowIndex);
                //DisposeHeroBuff(CsSLGPVPMgr.instance.HeroBuffs, mCurShowIndex + 5);
                mCurShowTime = 0;
                mCurShowIndex++;
            }
            return;
        }

        if (GameStateSLGBattle.Instance.onAnimFinish != null)
        {
            GameStateSLGBattle.Instance.onAnimFinish();
        }
        mStartBattle = true;
        mNeedUpdateCamAnim = false;
        Transform trf = mCamera.transform;
        AnimationState anims = mCamAnim["SLGPVPCAM"];
        anims.time = anims.length;
        anims.enabled = true;
        mCamAnim.Sample();
        anims.enabled = false;
        mCamStartPos = trf.position;
        mCamStartRotate = trf.localRotation;
        //mACamp.ResetToBattleState();
        //mDCamp.ResetToBattleState();
        mNeedUpdateMove = true;

        mDelayStartTime = 1.25f;
        //mNeedUpdateMove = true;
    }

    public bool UpdateStartCamAnim(float dt)
    {
        if (mStartBattle)
            return false;
        if (mDelayStartTime > 0)
        {
            mDelayStartTime -= dt;
            return true;
        }
        //if (mCamAnim == null || !mNeedUpdateCamAnim)
        //    return false;
        //if (mCamAnim.isPlaying)
        //    return true;
        //else
        {
            SkipCamAnim();
            return false;
        }
    }

    private void DisposeHUD(Vector3 pos, Vector3 dir, Serclimax.SLGPVP.ScSLGPVPHpInfo hinfo)
    {
        int s = hinfo.type;
        if (s >= 1 && s <= 3)
        {
            if (s == 1)
            {
                mDelayRecoverHud = 0;
                UpdateDelayRecoverHud(0);
            }

            int index = hinfo.type - 1;
            if (mHud[index] != null)
            {
                mHudPool.RecoverHud(mHudRed[index], mHud[index]);
                mHud[index] = null;
                if (mHudEffect[index] != null)
                {
                    if (CsObjPoolMgr.isValid)
                        CsObjPoolMgr.Instance.Destroy(mHudEffect[index]);
                }
            }
            mHudRed[index] = !hinfo.IsDefend;
            mHud[index] = mHudPool.CreateHud(pos, hinfo.CurHp, mHudRed[index]);
            mHudEffect[index] = ResourceLibrary.instance.GetEffectInstanceFromPool(CsSLGPVPHudPoolMgr.EffectPath[index]);

            CsParticleController pc = mHudEffect[index].GetComponentInChildren<CsParticleController>();
            if (pc != null)
            {
                float scale = 1;
                if (hinfo.IsTank)
                {
                    scale = 2.5f;
                }
                else
                    scale = 1.5f;
                pc.transform.localScale = Vector3.one * scale;
                pc.ScaleShurikenSystems(scale);
            }
            mHudEffect[index].transform.position = pos;
            mHudEffect[index].transform.forward = dir;
        }
        else
        if (s >= 4 && s <= 6)
        {
            int index = hinfo.type % 3;
            if (index == 0)
            {
                index = 3;
            }
            index = index - 1;
            if (mHud[index] != null)
            {
                mHud[index].SetHp(hinfo.CurHp);
            }
        }
        else
        {
            mDelayRecoverHud = 1;
            //int index = hinfo.type%3;
            //if(index  == 0)
            //{
            //    index = 3;
            //}
            //index = index -1;
            //if(mHud[index] != null)
            //{
            //    mHudPool.RecoverHud(mHudRed[index], mHud[index]);
            //    mHud[index] = null;
            //}
        }
    }

    private void DisposeRestraint(Vector3 pos, Vector3 forward, int r)
    {
        string path = r > 0 ? RestraintEffects[1] : RestraintEffects[0];
        GameObject obj = ResourceLibrary.instance.GetEffectInstanceFromPool(path);
        obj.transform.position = pos;
        obj.transform.forward = forward;
        float scale = Mathf.Abs(r) != 4 ? 1 : (r > 0 ? 2 : 1.5f);
        CsSkillAsset pc = obj.GetComponentInChildren<CsSkillAsset>();
        if (pc != null)
        {
            pc.Particle.ScaleFactor = scale;
            pc.Particle.transform.localScale = Vector3.one * scale;
            pc.Particle.DestroyWhenInvalid = true;
            pc.Particle.Active();
        }
    }

    private bool DisposeHeroBuff(HeroBuffShowInfo info, int hero_index)
    {
        int index = hero_index * 12;
        if (info.HeroBuffIds[index] == -100)
        {
            return false;
        }
        int k = 0;
        int dc = 0;
        for (int i = index; i < (index + 12); i++)
        {
            int buff = info.HeroBuffIds[i];
            if (buff != 0)
            {
                int ptype = k / 3 + 1;
                int buffId = k % 3;
                Serclimax.SLGPVP.ScBattCamp camp = buff > 0 ? mACamp : mDCamp;
                Serclimax.SLGPVP.ScBattPhalanx bp = camp.GetBattPhalanxType(ptype);
                if (bp != null && bp.Phalanx.AccountMaps != null)
                {
                    Debug.Log("Add buf " + RestraintEffects[buffId]);
                    GameObject obj = ResourceLibrary.instance.GetEffectInstanceFromPool(RestraintEffects[buffId]);

                    obj.transform.position = bp.BuffPos;
                    obj.transform.forward = bp.Forward;
                    float scale = Mathf.Abs(ptype) != 4 ? 1 : 1.3f;
                    CsSkillAsset pc = obj.GetComponentInChildren<CsSkillAsset>();
                    if (pc != null)
                    {
                        pc.Particle.ScaleFactor = scale;
                        pc.Particle.transform.localScale = Vector3.one * scale;
                        pc.Particle.DestroyWhenInvalid = true;
                        pc.DelayActive(dc * 0.25f);
                        dc++;
                    }
                }
            }
            k++;
        }
        return true;
    }

    private void UpdateDelayRecoverHud(float dt)
    {
        if (mDelayRecoverHud < 0)
            return;
        mDelayRecoverHud -= dt;
        if (mDelayRecoverHud <= 0)
        {
            mDelayRecoverHud = -1;
        }
        else
            return;

        for (int i = 0; i < 3; i++)
        {
            if (mHud[i] != null)
            {
                mHudPool.RecoverHud(mHudRed[i], mHud[i]);
                mHud[i] = null;
                if (mHudEffect[i] != null)
                {
                    if (CsObjPoolMgr.isValid)
                        CsObjPoolMgr.Instance.Destroy(mHudEffect[i]);
                }
            }
        }
    }

    private Vector3 ToUIwPos(Vector3 wpos)
    {
        Vector3 pos = mCamera.WorldToScreenPoint(wpos);

        if (mUICamera != null)
        {
            pos = mUICamera.ScreenToWorldPoint(pos);
            pos.z = 0;
        }
        return pos;
    }

    private bool mNeedUpdateTimeStop;
    public float WaitSkillTime = 1f;
    private float mWaitTimeStop = 1;
    private bool UpdateTimeStop()
    {
        if (!mNeedUpdateTimeStop)
            return false;
        if (Time.realtimeSinceStartup >= mWaitTimeStop)
        {
            mWaitTimeStop = 0;
            Serclimax.GameTime.timeScale = 1;
            mNeedUpdateTimeStop = false;
        }
        return true;
    }

    private void OnDisposeMsg(Serclimax.SLGPVP.ScSLGPVPMsg msg)
    {
        switch (msg.type)
        {
            //case (int)Serclimax.SLGPVP.ScSPMsgType.SMT_SCORE:
            //    Serclimax.SLGPVP.ScSLGPVPHurtInfo info = msg.param as Serclimax.SLGPVP.ScSLGPVPHurtInfo;
            //    if (info != null)
            //    {
            //        GameStateSLGBattle.Instance.ShowHurt(ToUIwPos(msg.pos), info.restraint, info.hurt);
            //    }
            //    break;
            //case (int)Serclimax.SLGPVP.ScSPMsgType.SMT_HP:
            //    Serclimax.SLGPVP.ScSLGPVPHpInfo hinfo = msg.param as Serclimax.SLGPVP.ScSLGPVPHpInfo;
            //    if (hinfo != null)
            //    {
            //        DisposeHUD(msg.pos, msg.forward, hinfo);
            //    }
            //    break;
            //case (int)Serclimax.SLGPVP.ScSPMsgType.SMT_RESTRAINT:
            //    int r = (int)msg.param;
            //    if (r != 0)
            //    {
            //        DisposeRestraint(msg.pos, msg.forward, r);
            //    }
            //    break;
            case (int)Serclimax.SLGPVP.ScSPMsgType.SMT_SKILL_ACTIVE:
                Serclimax.SLGPVP.ScSLGPVPSkillActived actives = msg.param as Serclimax.SLGPVP.ScSLGPVPSkillActived;
                if (actives != null)
                {
                    if (GameStateSLGBattle.Instance.onShowHeroSkillEffect != null)
                    {
                        GameStateSLGBattle.Instance.onShowHeroSkillEffect(actives.hero_base_ids, WaitSkillTime);
                    }
                    mWaitTimeStop = actives.max_count * WaitSkillTime + Time.realtimeSinceStartup;
                }
                if (mWaitTimeStop > 0)
                {
                    Serclimax.GameTime.timeScale = 0.2f;
                    mNeedUpdateTimeStop = true;
                }

                break;
            case (int)Serclimax.SLGPVP.ScSPMsgType.SMT_TITLE:
                Serclimax.SLGPVP.ScSLGPVPState sstate = msg.param as Serclimax.SLGPVP.ScSLGPVPState;
                if (sstate != null)
                {
                    if (GameStateSLGBattle.Instance.onShowBattleState != null)
                    {
                        GameStateSLGBattle.Instance.onShowBattleState(sstate.Round, sstate.CampHps);
                    }
                }
                break;
        }
    }

    public bool LoadSLGEffect()
    {

        return true;
    }

    //private void UpdateCampMoveAnim(float _dt)
    //{
    //    if (!mNeedUpdateMove)
    //        return;
    //    mMoveTime += _dt;
    //    float p = mMoveTime / mMoveTotalTime;
    //    if (p >= 1)
    //    {
    //        mACamp.ResetToBattleState();
    //        mDCamp.ResetToBattleState();
    //        mNeedUpdateMove = false;
    //    }
    //    else
    //    {
    //        mACamp.UpdateMove(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[2], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[3], p);
    //        mDCamp.UpdateMove(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[0], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[1], p);
    //    }
    //}

    public void Update(float dt)
    {

        if (UpdateStartCamAnim(dt))
        {
            //UpdateCampMoveAnim(dt);
            return;
        }

        //if (mDelayStartTime > 0)
        //{
        //    mDelayStartTime -= dt;
        //    return;
        //}
        if (!mStartBattle)
            return;
        bool success = false;
        if (CsSLGPVPMgr.instance.HeroBuffs != null)
        {
            if (mCurShowIndex < mShowTimes.Length)
            {
                mCurShowTime += dt;
                if (mCurShowTime > mShowTimes[mCurShowIndex])
                {
                    if (mCurShowIndex <= 4)
                    {
                        {
                            while (!success)
                            {
                                if (mCurShowIndex > 4)
                                {
                                    if (GameStateSLGBattle.Instance.onShowHeroFinish != null)
                                    {
                                        GameStateSLGBattle.Instance.onShowHeroFinish();
                                    }
                                    mDelayStartTime = 1f;
                                    success = true;
                                    mCurShowTime = mCurShowTime - mShowTimes[mCurShowIndex];
                                    mCurShowIndex++;
                                }
                                else
                                {
                                    bool hero1 = DisposeHeroBuff(CsSLGPVPMgr.instance.HeroBuffs, mCurShowIndex);
                                    if (hero1 && GameStateSLGBattle.Instance.onShowHero != null)
                                    {
                                        GameStateSLGBattle.Instance.onShowHero(mCurShowIndex);
                                    }
                                    bool hero2 = DisposeHeroBuff(CsSLGPVPMgr.instance.HeroBuffs, mCurShowIndex + 5);
                                    if (hero2 && GameStateSLGBattle.Instance.onShowHero != null)
                                    {
                                        GameStateSLGBattle.Instance.onShowHero(mCurShowIndex + 5);
                                    }
                                    if (hero1 || hero2)
                                        success = true;

                                    mCurShowTime = mCurShowTime - mShowTimes[mCurShowIndex];
                                    mCurShowIndex++;
                                }
                            }
                        }
                    }
                    else
                    {
                        if (GameStateSLGBattle.Instance.onShowHeroFinish != null)
                        {
                            GameStateSLGBattle.Instance.onShowHeroFinish();
                        }
                        mDelayStartTime = 1f;
                        success = true;
                        mCurShowTime = mCurShowTime - mShowTimes[mCurShowIndex];
                        mCurShowIndex++;
                    }

                    if (mCurShowIndex >= mShowTimes.Length)
                    {
                        return;
                    }
                }
                return;
            }
        }

        if (mDelayStartTime > 0)
        {
            mDelayStartTime -= dt;
            return;
        }

        if (mNeedUpdateMove)
        {
            //mACamp.ResetToBattleState();
            //mDCamp.ResetToBattleState();
            mACamp.RemovePVPUnit2Free();
            mDCamp.RemovePVPUnit2Free();
            mACamp.SetPVPUnitMovedTarget(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[2], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[3]);
            mDCamp.SetPVPUnitMovedTarget(CsSLGPVPMgr.instance.mBattleMoveAnimPoints[0], CsSLGPVPMgr.instance.mBattleMoveAnimPoints[1]);
            mNeedUpdateMove = false;
            mDelayStartTime = 1.5f;
            return;
        }

        if (mDelayStartTime > 0)
        {
            mDelayStartTime -= dt;
            return;
        }

        if (!UpdateTimeStop())
        {
            mBattle.UpdateBattleUnitMove(dt);
            mBattle.UpdateBattle(dt);
        }

        UpdateDelayRecoverHud(dt);
    }
}

public class CsSLGPVPMgr
{
    public class CsSLGPVPLoader
    {
        static readonly int MAX_LOAD_STEP = 11;
        MsgBattleStartResponse battleStartResponse;
        private bool requestingData;

        private string levelConfig;

        private bool mIsLoading;

        private int mLoadStep;

        private bool mShowLoading = false;

        private bool mIsLoadingScene = false;

        private LuaBehaviour loadScreen = null;

        private List<int> selectedArmyList = new List<int>();

        private CsSLGPVPMgr mSlgPvpMgr;

        private bool mDone = false;

        private int mBattleId;

        public bool isDone
        {
            get
            {
                return mDone;
            }
        }

        public CsSLGPVPLoader(CsSLGPVPMgr slgpvpmgr)
        {
            mSlgPvpMgr = slgpvpmgr;
        }

        public void Enter(int BattleId, Serclimax.SLGPVP.ScSLGPlayer[] players,System.Action done)
        {
            selectedArmyList.Clear();
            mIsLoading = true;
            mLoadStep = -15;
            mBattleId = BattleId;
            mShowLoading = true;
            for (int i = 0; i < players.Length; i++)
            {
                for (int j = 0; j < players[i].Armys.Length; j++)
                {
                    int id = players[i].Armys[j].ID;
                    if (!selectedArmyList.Contains(id))
                        selectedArmyList.Add(id);
                }

            }
            if (mShowLoading)
            {
                loadScreen = GUIMgr.Instance.CreateMenu("loading", true);
                AssetBundleManager.Instance.onCheckPercent += OnCheckPrecent;
                AssetBundleManager.Instance.onBundleLoad += OnBundleLoad;
            }
#if SUPPORT_CHANGE_SCENE
        mIsLoadingScene = true; 
        Main.Instance.StartCoroutine(ChangeSceneUtility.ChangeNewScene(() =>
        {
            {
                battleStartResponse = new MsgBattleStartResponse();
                battleStartResponse.chapterlevel = (uint)mBattleId;
                BattleMonsterDropInfo dropInfo = null;
                var textAsset = Resources.Load(@"level\Chapter_Demo\drop\BattleDrops_" + mBattleId) as TextAsset;
                if (textAsset != null)
                {
                    dropInfo = NetworkManager.instance.Decode<ProtoMsg.BattleMonsterDropInfo>(textAsset.bytes);
                }
                battleStartResponse.monsterDrop = dropInfo;

                battleStartResponse.config = new BattleSceneConfig();
                var battelData = Main.Instance.GetTableMgr().GetBattleData(mBattleId);
                string levelName = battelData.sceneData;
                var chapterData = Main.Instance.GetTableMgr().GetChapterData(battelData.chapterId);
                string chapterName = chapterData.stringId;

                TextAsset text = ResourceLibrary.instance.GetLevelData(chapterName, levelName);
                if (text != null)
                {
                    levelConfig = text.text;
                }
                mIsLoadingScene = false;
                if(done != null)
                    done();
            }
        }));
#else
            {
                battleStartResponse = new MsgBattleStartResponse();
                battleStartResponse.chapterlevel = (uint)mBattleId;
                BattleMonsterDropInfo dropInfo = null;
                var textAsset = Resources.Load(@"level\Chapter_Demo\drop\BattleDrops_" + mBattleId) as TextAsset;
                if (textAsset != null)
                {
                    dropInfo = NetworkManager.instance.Decode<ProtoMsg.BattleMonsterDropInfo>(textAsset.bytes);
                }
                battleStartResponse.monsterDrop = dropInfo;

                battleStartResponse.config = new BattleSceneConfig();
                var battelData = Main.Instance.GetTableMgr().GetBattleData(mBattleId);
                string levelName = battelData.sceneData;
                var chapterData = Main.Instance.GetTableMgr().GetChapterData(battelData.chapterId);
                string chapterName = chapterData.stringId;

                TextAsset text = ResourceLibrary.instance.GetLevelData(chapterName, levelName);
                if (text != null)
                {
                    levelConfig = text.text;
                }
                mIsLoadingScene = false;
                if(done != null)
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

        private bool ispreloaded = false;
        bool UpdateLoad()
        {
            //EffectPrefab
            ResourceLibrary.instance.CacheEffectObject("bullet", 1);
            ResourceLibrary.instance.CacheEffectObject("PVP_MGbullet", 1);
            //EffectInstanceFromPool
            ResourceLibrary.instance.CacheEffectObject("jiagong", 1);
            ResourceLibrary.instance.CacheEffectObject("dunbuff", 1);
            ResourceLibrary.instance.CacheEffectObject("jiaxue", 1);
            ResourceLibrary.instance.CacheEffectObject("PVPcannon", 1);
            ResourceLibrary.instance.CacheEffectObject("G_TankBullet", 1);
            ResourceLibrary.instance.CacheEffectObject("TankBoom", 1);
            ResourceLibrary.instance.CacheEffectObject("BloodBeaten", 1);
            ResourceLibrary.instance.CacheEffectObject("rpg", 1);
            ResourceLibrary.instance.CacheEffectObject("snipe", 1);
            ResourceLibrary.instance.CacheEffectObject("TankBeaten", 1);
            ResourceLibrary.instance.CacheEffectObject("rpgboom", 1);

            if (loadScreen != null)
            {
                float value = (float)mLoadStep / (float)(MAX_LOAD_STEP - 1);
                loadScreen.CallFunc("SetProgress", value);
            }

            bool bWaiting = false;
            if (mLoadStep == 0)
            {
                if (ResourceUnload.instance.IsDone())
                {
                    System.GC.Collect();
                    bWaiting = false;
                }
                else
                {
                    bWaiting = true;
                }
            }
            else if (mLoadStep == 1)
            {
                mSlgPvpMgr.LoadLevelData((int)battleStartResponse.chapterlevel, levelConfig);
            }
            else if (mLoadStep == 2)
            {
                if (!AssetBundleManager.Instance.ischecking)
                {
                    ispreloaded = true;
                }
                if (!ispreloaded)
                {
                    return false;
                }
            }
            else if (mLoadStep == 3)
            {
                if (!AssetBundleManager.Instance.ischecking)
                {
                    ispreloaded = true;
                }
                if (!ispreloaded)
                {
                    return false;
                }
            }
            else if (mLoadStep == 4)
            {
                if (!AssetBundleManager.Instance.ischecking)
                {
                    ispreloaded = mSlgPvpMgr.LoadEffectAsset();
                }
                if (!ispreloaded)
                {
                    return false;
                }
            }
            else if (mLoadStep == 5)
            {
                mSlgPvpMgr.InitScRoots(null, null);
            }
            else if (mLoadStep == 6)
            {
                if (!AssetBundleManager.Instance.ischecking)
                {
                    ispreloaded = mSlgPvpMgr.LoadLevel();
                }
                if (!ispreloaded)
                {
                    return false;
                }
            }
            else if (mLoadStep == 7)
            {
                if (!AssetBundleManager.Instance.ischecking)
                {
                    ispreloaded = mSlgPvpMgr.preloadUnit(selectedArmyList);
                }
                if (!ispreloaded)
                {
                    return false;
                }
            }
            else if (mLoadStep == 8)
            {
                if (!AssetBundleManager.Instance.ischecking)
                {
                    ispreloaded = mSlgPvpMgr.LoadAndPlayBgMusic(mBattleId);
                }
                if (!ispreloaded)
                {
                    return false;
                }
            }
            else if (mLoadStep == 9)
            {
                mSlgPvpMgr.InitBattle();
            }
            else if (mLoadStep == 10)
            {
                GUIMgr.Instance.CreateMenu("PVP_SLG");
                mSlgPvpMgr.OnLoadFinished();
            }

            if (!bWaiting)
                mLoadStep++;
            if (mLoadStep == MAX_LOAD_STEP)
            {
                mIsLoading = false;
                return true;
            }
            else
                return false;

        }

        public void Update()
        {
            if (mDone)
                return;
            if(mIsLoadingScene)
                return;
            if (mIsLoading)
            {
                UpdateLoad();
                return;
            }
            if (mShowLoading)
            {
                GUIMgr.Instance.CloseMenu("loading");
                AssetBundleManager.Instance.onCheckPercent -= OnCheckPrecent;
                AssetBundleManager.Instance.onBundleLoad -= OnBundleLoad;
            }
            mDone = true;
        }
    }

    public Vector3[] mBattleMoveAnimPoints;

    static CsSLGPVPMgr mInstance;

    public Serclimax.ScTableMgr gScTableData = null;

    public delegate void OnSceneLoadFinished();

    public OnSceneLoadFinished onSceneLoadFinished;

    public SceneEntity Entity = null;

    public CsSLGPVPLoader mLoader = null;

    public string mStrAConfig = "";
    public string mStrDConfig = "";
    public string mStrPhalanxConfig = "";

    public static CsSLGPVPMgr instance
    {
        get
        {
            if (mInstance == null)
            {
                mInstance = new CsSLGPVPMgr();
            }
            return mInstance;
        }
    }

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

    private float mBattleEndWaitTime = 0;

    private float mBattleEndWaitTotalTime;

    public bool mIsGameOver = false;

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

    public Serclimax.ScRoot gScRoots = null;

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

    private CsBulletEmitter mBulletEmitter = null;

    private CsBloodEmitter mBloodEmitter = null;

    private CsBloodEmitter mBoomResidualEmitter = null;

    private CsTrailCanvas mTrailRenderer = null;

    private CsBloodEmitter mButtleBeatenglow = null;

    private Serclimax.SLGPVP.ScSLGPlayer[] mSlgPvpPlayers;

    private HeroBuffShowInfo mHeroBuffs;

    public HeroBuffShowInfo HeroBuffs
    {
        get
        {
            return mHeroBuffs;
        }
    }

    private uint mSlgRandomSeed;

    private bool mEnbaleLog;

    private CsSLGPVPBattleController mBattleController = null;

    public CsSLGPVPBattleController BattleController
    {
        get
        {
            return mBattleController;
        }
    }

    public CsSLGPVPLoader StartPVP(int battleId, 
        Serclimax.SLGPVP.ScSLGPlayer[] players, 
        HeroBuffShowInfo buffs, uint random_seed, 
        bool enable_log, 
        string strAConfig, 
        string strDConfig, 
        string strPhalanxConfig,
        System.Action done)
    {
        mSlgPvpPlayers = players;
        mHeroBuffs = buffs;
        mSlgRandomSeed = random_seed;
        mEnbaleLog = enable_log;
        mStrAConfig = strAConfig;
        mStrDConfig = strDConfig;
        mStrPhalanxConfig = strPhalanxConfig;
        mLoader = new CsSLGPVPLoader(this);
        mLoader.Enter(battleId, mSlgPvpPlayers,done);
        return mLoader;
    }

    #region Members
    public void ClearLevel()
    {
        mSlgPvpPlayers = null;
        mSlgRandomSeed = 0;
        mLoader = null;
        if (mBattleController != null)
            mBattleController.ClearEffect();
        mBattleController = null;
        //QualitySettings.masterTextureLimit = 0;
        gScTableData = null;
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
        GameObject.Destroy(CsDisDaCenter.Instance.gameObject);
        GameObject.Destroy(CsUnitMgr.Instance.gameObject);
        GameObject.Destroy(CsSkillMgr.Instance.gameObject);
        GameObject.Destroy(CsBakeBatchesMgr.Instance.gameObject);
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

        if (mTrailRenderer != null)
        {
            mTrailRenderer.Clear();
            GameObject.Destroy(mTrailRenderer.gameObject);
        }

        if (mButtleBeatenglow != null)
        {
            GameObject.Destroy(mButtleBeatenglow.gameObject);
        }
        mLevelData = null;

        AudioManager.instance.StopMusic();
        //GameObject.Destroy(mBgMusic);

        ResourceUnload.instance.ReleaseUnusedResource();
    }

    public void InitScRoots(int[] expActiveEvent = null, System.Action init_cb = null)
    {
        //QualitySettings.masterTextureLimit = 3;
        //test load table data
        gScTableData = Main.Instance.GetTableMgr();
        //gScTableData.
        //creat scRoot
        gScRoots = new Serclimax.ScRoot(CsDisDaCenter.Instance.DisCenter, gScTableData, 0, 0, 300, 300);
        if (gScRoots != null)
        {
            //gScRoots.GetMgr<Serclimax.ScRecordMgr>().Setup(Serclimax.ScRecordMgr.RecordState.RS_PLAY);
            gScRoots.Astar = Astar;

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
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_SKILL_MSG, CsSkillMgr.Instance.DisposeSkillMsg);
        CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_SKILL_MSG, CsSkillMgr.Instance.DisposeCreateSkillMsg);
        CsSkillMgr.Instance.BulletEmitter = mBulletEmitter;
        CsSkillMgr.Instance.BoolEmitter = mBloodEmitter;
        CsSkillMgr.Instance.BoomResidualEmitter = mBoomResidualEmitter;
        CsSkillMgr.Instance.TrailCanvas = mTrailRenderer;
        CsSkillMgr.Instance.ButtleBeatenEmitter = mButtleBeatenglow;
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
            //FirelineController mFireline = mSceneObj.transform.FindChild("FireLine").GetComponent<FirelineController>();
            //if (mFireline != null)
            //    mFireline.gameObject.SetActive(false);
            Entity = mSceneObj.GetComponent<SceneEntity>();
            if (Entity != null)
            {
                Entity.LoadPrefabs();
            }
            return true;
        }
        return false;
    }

    void InitElements()
    {
        XElementData[] elementsData = mLevelData.elementsData;


        for (int i = 0; i < elementsData.Length; i++)
        {
            XElementData elementData = elementsData[i];

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

    public bool preloadUnit(List<int> selectArmlist)
    {
        if (selectArmlist == null)
            return true;
        List<string> preloadNames = new List<string>();

        for (int i = 0, imax = selectArmlist.Count; i < imax; i++)
        {
            Serclimax.Unit.ScUnitData ud = gScTableData.GetUnitData(selectArmlist[i]);
            if (ud != null)
            {
                if (!preloadNames.Contains(ud._unitPrefab))
                {
                    preloadNames.Add(ud._unitPrefab);
                }
            }
        }
        //for(int i =0;i<CsSLGPVPHudPoolMgr.EffectPath.Length;i++)
        //{
        //    preloadNames.Add(CsSLGPVPHudPoolMgr.EffectPath[i]);
        //}
        //for(int i =0;i<CsSLGPVPBattleController.RestraintEffects.Length;i++)
        //{
        //    preloadNames.Add(CsSLGPVPBattleController.RestraintEffects[i]);
        //}

        bool hasRes = true;
        for (int i = 0, imax = preloadNames.Count; i < imax; i++)
        {
            hasRes &= ResourceLibrary.instance.CacheLevelObject(preloadNames[i]);
        }

        return hasRes;
    }

    public bool LoadEffectAsset()
    {
        GameObject BullteEmitter = ResourceLibrary.instance.GetEffectInstance("BullteEmitter");
        GameObject BloodcEmitter = ResourceLibrary.instance.GetEffectInstance("BloodcEmitter");
        GameObject BoomResidualEmitter = ResourceLibrary.instance.GetEffectInstance("BoomResidualEmitter_SLG");
        GameObject CorpseEffect = ResourceLibrary.instance.GetEffectInstance("CorpseEffect");
        GameObject TrailRender = ResourceLibrary.instance.GetEffectInstance("TrailCanvas");
        GameObject ButtleBeatenglow = ResourceLibrary.instance.GetEffectInstance("ButtleBeatenglow");
        if (BullteEmitter != null && BloodcEmitter != null && BoomResidualEmitter != null && CorpseEffect != null)
        {
            mBulletEmitter = BullteEmitter.GetComponent<CsBulletEmitter>();
            mBloodEmitter = BloodcEmitter.GetComponent<CsBloodEmitter>();
            if (mBloodEmitter != null)
            {
                //ParticleSystem ps = mBloodEmitter.GetComponent<ParticleSystem>();
                //ps.startLifetime = 300;
            }
            mBoomResidualEmitter = BoomResidualEmitter.GetComponent<CsBloodEmitter>();
            CsDeadMgr.Instance.CorpseEffect = CorpseEffect.GetComponent<CsCorpseEffect>();
            CsDeadMgr.Instance.CorpseEffect.transform.parent = CsDeadMgr.Instance.transform;
            mButtleBeatenglow = ButtleBeatenglow.GetComponent<CsBloodEmitter>();
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

    public void InitBattle()
    {
        mBattleMoveAnimPoints = new Vector3[4];
        mBattleEndWaitTotalTime = float.Parse(gScRoots.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.SLGPVPBattleEndWaitTime).value);
        mBattleEndWaitTime = 0;
        mIsGameOver = false;
        GameObject blayout = Resources.Load<GameObject>("SLGPVP/BattleLayout");
        TextAsset mapdata = Resources.Load<TextAsset>("SLGPVP/Ch_PVP_GRIDMAP");
        Serclimax.SLGPVP.ScSLGPVPInfo info = new Serclimax.SLGPVP.ScSLGPVPInfo();
        info.RandomSeed = mSlgRandomSeed;
        info.Players = mSlgPvpPlayers;
        info.strAConfig = mStrAConfig;
        info.strDConfig = mStrDConfig;
        info.strPhalanxConfig = mStrPhalanxConfig;
        Transform btf = blayout.transform;
        // left
        Transform node = btf.Find("left");
        mBattleMoveAnimPoints[1] = Vector3.zero;
        Transform tmp = null;
        info.LeftPhalanxLayout = new Vector3[node.childCount];
        for (int i = 0, imax = node.childCount; i < imax; i++)
        {
            tmp = node.Find((i + 1).ToString());
            if (tmp != null)
            {
                info.LeftPhalanxLayout[i] = tmp.position;
                info.LeftDir = tmp.forward;
            }
        }
        // right
        node = btf.Find("right");
        mBattleMoveAnimPoints[3] = Vector3.zero;
        info.RightPhalanxLayout = new Vector3[node.childCount];
        for (int i = 0, imax = node.childCount; i < imax; i++)
        {
            tmp = node.Find((i + 1).ToString());
            if (tmp != null)
            {
                info.RightPhalanxLayout[i] = tmp.position;
                info.RightDir = tmp.forward;
            }
        }
        //solider
        node = btf.Find("SoliderNode");
        info.SoliderLayout = new Vector3[node.childCount];
        for (int i = 0, imax = node.childCount; i < imax; i++)
        {
            tmp = node.Find((i + 1).ToString());
            if (tmp != null)
            {
                info.SoliderLayout[i] = tmp.position;
            }
        }
        //tank
        node = btf.Find("TankNode");
        info.TankLayout = new Vector3[node.childCount];
        for (int i = 0, imax = node.childCount; i < imax; i++)
        {
            tmp = node.Find((i + 1).ToString());
            if (tmp != null)
            {
                info.TankLayout[i] = tmp.position;
            }
        }
        node = btf.Find("defence/G");
        info.MGLayout = new Vector3[node.childCount];
        for (int i = 0, imax = node.childCount; i < imax; i++)
        {
            tmp = node.Find((i + 1).ToString());
            if (tmp != null)
            {
                info.MGLayout[i] = tmp.position;
            }
        }
        node = btf.Find("defence/P");
        info.PLayout = new Vector3[node.childCount];
        for (int i = 0, imax = node.childCount; i < imax; i++)
        {
            tmp = node.Find((i + 1).ToString());
            if (tmp != null)
            {
                info.PLayout[i] = tmp.position;
            }
        }



        info.MapData = mapdata.text;

        GameObject bmalayout = Resources.Load<GameObject>("SLGPVP/BattleMoveAnimLayout");
        if (bmalayout != null)
        {
            btf = bmalayout.transform;
            node = btf.Find("AS");
            mBattleMoveAnimPoints[2] = node.position;
            mBattleMoveAnimPoints[2].z = 0;
            //node = btf.FindChild("AE");
            //mBattleMoveAnimPoints[3] = node.position;


            node = btf.Find("DS");
            mBattleMoveAnimPoints[0] = node.position;
            mBattleMoveAnimPoints[0].z = 0;
            //node = btf.FindChild("DE");
            //mBattleMoveAnimPoints[1] = node.position;
        }

        mBattleController = new CsSLGPVPBattleController(mSceneObj, gScRoots, info);
        mBattleController.InitBattle(mEnbaleLog);
    }

    public void Update(float dt = -1)
    {
        if (mBattleController != null)
        {
            if (!mBattleController.isBattleEnd())
            {
                mBattleController.Update(dt < 0 ? Time.deltaTime : dt);
                if (gScRoots != null)
                {
                    gScRoots.Update(dt < 0 ? Time.deltaTime : dt);
                }
            }
            else
            {
                if (mBattleEndWaitTime <= mBattleEndWaitTotalTime)
                {
                    mBattleEndWaitTime += dt < 0 ? Time.deltaTime : dt;
                    return;
                }
                else
                if (!mIsGameOver)
                {
                    mIsGameOver = true;
                    GameStateSLGBattle.Instance.SlgPlayers = null;
                    if (GameStateSLGBattle.Instance.onGameOver != null)
                    {
                        if (mBattleController.Battle.DebugResult != null)
                        {
                            GameStateSLGBattle.Instance.onGameOver_Debug(Encode<ProtoMsg.SceneBattleResult>(mBattleController.Battle.DebugResult));
                        }
                        else
                            GameStateSLGBattle.Instance.onGameOver();
                    }

                }
            }
        }

        //if (Astar != null)
        //{
        //    Astar.Update();
        //}
    }

    static byte[] Encode<T>(T cmd) where T : ProtoBuf.IExtensible
    {
        MemoryStream stream = new MemoryStream();
        ProtoBuf.Serializer.Serialize(stream, cmd);
        return stream.ToArray();
    }

    static T Decode<T>(byte[] data) where T : ProtoBuf.IExtensible
    {
        MemoryStream stream = new MemoryStream(data);
        return ProtoBuf.Serializer.Deserialize<T>(stream);
    }
    public void BattleEnd()
    {
        mBattleController.BattleEnd();
    }

    public void SkipCamAnim()
    {
        mBattleController.SkipCamAnim();
    }

    #endregion

    #region Msgercl
    public void OnLoadFinished()
    {
        if (onSceneLoadFinished != null)
        {
            onSceneLoadFinished();
        }

        if (mBattleController != null)
        {
            mBattleController.StartCamAnim("SLGPVPCAM");
        }
    }
    #endregion
}
