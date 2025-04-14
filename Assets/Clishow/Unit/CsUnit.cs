using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using System.IO;
namespace Clishow
{
    [System.Serializable]
    public class CsUnitLandingInfo
    {
        public float landingDis;
        public float landingHeight;
        public float landingSpeed;
        public float landingTime;
        public float TouchLandTime;

        public enum LandState
        {
            LS_LANDING,
            LS_TOUCH,
            LS_NIL,
        }

        private LandState mLandingState = LandState.LS_NIL;
        private float mLandingTime = 0;
        private float mTouchLandTime = 0;
        private Vector3 mTargetPos;
        private Vector3 mStartPos;
        private Vector3 mOldPos;
        private CsUnit mUnit;
        private Transform mUnitTrf;
        private Animation mParachute = null;
        public bool Enabled = false;
        public void Init(CsUnit unit)
        {
            mUnit = unit;
        }

        public void Reset()
        {
            Enabled = false;
            mTouchLandTime = 0;
            mLandingTime = 0;
            mLandingState = LandState.LS_NIL;
            if (mParachute != null)
            {
                CsObjPoolMgr.Instance.Destroy(mParachute.gameObject);
            }
        }

        public void Active(Vector3 pos, Vector3 dir)
        {
            if (mLandingState != LandState.LS_NIL && Enabled)
                return;
            mTouchLandTime = 0;
            mLandingTime = 0;
            mTargetPos = pos;
            mLandingState = LandState.LS_LANDING;
            mUnitTrf = mUnit.transform;
            GameObject obj = ResourceLibrary.instance.GetLevelUnitInstanceFromPool("parachute_01", XLevelDefine.ElementType.Unit, Vector3.zero, Quaternion.identity);
            mParachute = obj.GetComponent<Animation>();
            if (mParachute == null)
            {
                CsObjPoolMgr.Instance.Destroy(obj);
            }
            else
            {
                mParachute.transform.parent = mUnitTrf;
                mParachute.transform.localPosition = Vector3.zero;
                mParachute.transform.localRotation = Quaternion.identity;
                mParachute.Play("landing01");
            }
            if (mUnit.Anim != null)
                mUnit.Anim.Play("landing01");
            Vector3 _dir = (dir);//(Quaternion.AngleAxis(UnityEngine.Random.Range(0, 175), Vector3.up) * ).normalized;
            _dir.y = 0;
            mStartPos = _dir * landingDis + mTargetPos;
            mUnitTrf.transform.position = mStartPos + Vector3.up * landingHeight;
            mOldPos = mUnitTrf.transform.position;
        }

        public bool Update(float _dt)
        {
            if (!Enabled)
                return false;
            switch (mLandingState)
            {
                case LandState.LS_LANDING:
                    float ff = mLandingTime / landingTime;
                    float f = (ff) * 0.5f + 0.5f;
                    float yy = (float)UnityEngine.Mathf.Sin(Mathf.PI * (1 - f));
                    Vector3 pos = Vector3.Lerp(mStartPos, mTargetPos, ff);
                    pos.y = landingHeight * yy;
                    mUnitTrf.transform.position = pos;

                    Vector3 dir = mUnitTrf.transform.position - mOldPos;
                    dir.y = 0;
                    mUnitTrf.transform.forward = dir;

                    mLandingTime += _dt;
                    if (ff >= 1)
                    {
                        mUnitTrf.transform.position = mTargetPos;
                        mLandingState = LandState.LS_TOUCH;
                        if (mParachute != null)
                            mParachute.CrossFade("landing02");
                        if (mUnit.Anim != null)
                            mUnit.Anim.CrossFade("landing02");
                    }
                    return true;
                case LandState.LS_TOUCH:
                    if (mTouchLandTime >= TouchLandTime)
                    {
                        Reset();
                    }
                    else
                        mTouchLandTime += _dt;
                    return true;
            }
            return false;
        }
    }

    public class CsUnit : MonoBehaviour
    {
        public enum DeadState
        {
            DS_NIL,
            DS_DEAD_ANIM,
            DS_DEAD_FADE,
        }
        public bool DispalyCorpse = false;
        public GameObject _modelPrefab;
        public GameObject _lowModelPrefab;
        public int unitType = 0;
        public float Step = 1;
        public float SoliderHight = 1;
        public float WaitDeadAnimTime = 1;
        public float DeadFadeTime = 2;
        public bool EnableDeadFade = true;
        public string Eff_PointHurtName;
        public string Eff_DiffacHurtName;
        public string EFf_FireHurtName;
        public string Eff_DeadEffectName;
        public string Eff_BornEffectName;
        public string Eff_FlamethrowerName;
        [System.NonSerialized]
        public float MoveSpeed = 1;
        [System.NonSerialized]
        public Vector3 DeadFlyDir = Vector3.zero;
        [System.NonSerialized]
        public float DeadFlyRandTime = 0;

        public bool BuildUnitDestroyEnableFire = true;

        public bool IsDead = false;
        public bool IsLevelImportTarget = false;

        public Vector3 DeadMixAngle = Vector3.zero;
        public Vector2 DeadKLimitAngle = new Vector2(0, 10);
        public AffectTargetAix DeadAix = AffectTargetAix.ATA_X;
        public bool OppositeDeadAix = false;

        private float mDeadFadeTime = 0;
        private float mWaitTime;
        public int mUnitWeaponCount = 0;
        public float mBornStartTime = 0;
        public string unitTag = string.Empty;
        public bool isBuideTarget = false;

        #region Audios
        public int mUnitSfxTableId = 0;
        public AudioSource mUnitAudio = null;
        private AudioClip mLastSfx;
        private float mLastSfxTime = 0;
        private string mLastSfxName = string.Empty;
        private Serclimax.Unit.ScUnitSfxData mSfxData = null;
        public Serclimax.Unit.ScUnitSfxData SfxData
        {
            get { return mSfxData; }
            set { mSfxData = value; }
        }
        #endregion

        public static readonly int MaxCastSkillNum = 2;
        [System.NonSerialized]
        public CsSkillIns[] BindSkillInses = new CsSkillIns[MaxCastSkillNum];

        public CsBullteSkillIns[] BindBullteSkillInses = new CsBullteSkillIns[MaxCastSkillNum];
        private DeadState mState = DeadState.DS_NIL;
        public DeadState UDeadState
        {
            get
            {
                return mState;
            }
        }
        public float ShowRifleFireTime = 0;
        public float ButtleOffset = 0;
        public string RifleFireName = string.Empty;
        public CsParticleController RifleFire = null;
        public CsBakeObject BakeObj = null;
        [System.NonSerialized]
        public Vector3[] WPPOS = new Vector3[MaxCastSkillNum];
        [System.NonSerialized]
        public Quaternion[] WPDIR = new Quaternion[MaxCastSkillNum];
        [System.NonSerialized]
        public float TargetAngle;


        public enum AffectTargetAix
        {
            ATA_X,
            ATA_Y,
            ATA_Z,
        }

        public AffectTargetAix TargetAix = AffectTargetAix.ATA_X;
        public bool OppositeTargetAix = false;
        public bool OnlyAttack = false;

        public CsUnitLandingInfo LandingInfo = new CsUnitLandingInfo();

        public bool mIsDestroy = false;

        private UnitHud mHUD = null;
        public UnitHud HUD
        {
            get { return mHUD; }
            set { mHUD = value; }
        }

        private UnitStateEffect mStateEffect = null;

        public UnitStateEffect StateEffect
        {
            get
            {

                return mStateEffect;
            }
            set { mStateEffect = value; }
        }

        private CsUnitAttr unitAttr = new CsUnitAttr();

        public UnitDeadFlyInfo DeadFlyInfo = new UnitDeadFlyInfo();

        public CsFlamethrower Flamethrower = null;

        private GameObject ShadowPanel = null;

        private GameObject initModel()
        {
            GameObject obj = null;
            if(_lowModelPrefab != null)
            {
                obj = GameObject.Instantiate(_lowModelPrefab) as GameObject;
            }
            else
                obj = GameObject.Instantiate(_modelPrefab) as GameObject;
            Transform tt = obj.transform;

            Vector3 pos = tt.position;
            Quaternion rot = tt.rotation;
            Vector3 scale = tt.localScale;
            if (unitTag == "SLGPVP")
            {
                if (unitType == (int)Serclimax.Unit.ScUnitType.SUT_CARRIER)
                    scale = Vector3.one * 0.5f;
                else
                if (unitType == (int)Serclimax.Unit.ScUnitType.SUT_SOLDIER)
                    scale = Vector3.one * 0.5f;
            }
            if (unitTag == "SLGPVP_BIG")
            {
                scale = Vector3.one*0.5f;
            }
            tt.parent = transform;
            tt.localScale = scale;
            tt.localRotation = rot;
            tt.localPosition = pos;
            return obj;
        }

        public void InitUnit(int uType)
        {
            LandingInfo.Init(this);
            mIsDestroy = false;
            if (ShadowPanel == null)
            {
                Transform trf = this.transform.Find("shadow");
                if (trf != null)
                {
                    ShadowPanel = trf.gameObject;
                }
            }

            if (ShadowPanel != null)
            {
                SceneEntity entity = SceneManager.instance.Entity;
                if (entity == null)
                    entity = CsSLGPVPMgr.instance.Entity;
                if (entity != null && entity.ProjShadow != null && GameSetting.instance.option.mQualityLevel >= 1)
                {
                    ShadowPanel.SetActive(false);
                }
                else
                    ShadowPanel.SetActive(true);
            }
            unitType = uType;
            if (SMRenderer == null)
            {
                if (unitType == (int)Serclimax.Unit.ScUnitType.SUT_BUILD)
                {
                    if (_modelPrefab != null)
                    {
                        if (BakeObj == null)
                        {
                            GameObject insBuild = initModel();

                            CsBakeTagBones cBone = insBuild.GetComponent<CsBakeTagBones>();
                            if (cBone != null)
                            {
                                mUnitWeaponCount = cBone.TagBoneLength;
                            }

                            CsBuild build = insBuild.GetComponent<CsBuild>();
                            if (build != null)
                            {
                                SceneEntity entity = SceneManager.instance.Entity;
                                if (entity == null)
                                    entity = CsSLGPVPMgr.instance.Entity;
                                if (entity != null && entity.ProjShadow != null && GameSetting.instance.option.mQualityLevel == 2)
                                {
                                    build.Active();
                                }
                                else
                                    build.Unactive();
                            }
                        }
                        else
                        {
#if BakeMesh
                        Anim = _modelPrefab.GetComponent<Animation>();
                        SMRenderer = _modelPrefab.GetComponentInChildren<SkinnedMeshRenderer>();
#else
                            GameObject obj = initModel();
                            obj.SetActive(true);
                            mAnim = obj.GetComponent<Animation>();
                            SMRenderer = obj.GetComponentInChildren<SkinnedMeshRenderer>();
                            CsBuild build = obj.GetComponent<CsBuild>();
                            if (build != null)
                            {
                                SceneEntity entity = SceneManager.instance.Entity;
                                if (entity == null)
                                    entity = CsSLGPVPMgr.instance.Entity;
                                if (entity != null && entity.ProjShadow != null && GameSetting.instance.option.mQualityLevel == 2)
                                {
                                    build.Active();
                                }
                                else
                                    build.Unactive();
                            }
#endif
                        }
                    }
                }
                else if (unitType == (int)Serclimax.Unit.ScUnitType.SUT_SOLDIER || unitType == (int)Serclimax.Unit.ScUnitType.SUT_CARRIER)
                {
#if BakeMesh
                Anim = _modelPrefab.GetComponent<Animation>();
                if (Anim == null)
                {
                    Serclimax.DebugUtils.LogError("unit without Animation!");
                }

                SMRenderer = _modelPrefab.GetComponentInChildren<SkinnedMeshRenderer>();
                if (SMRenderer == null)
                {
                    Serclimax.DebugUtils.LogError("unit without SkinnedMeshRenderer!");
                }
#else
                    GameObject obj = initModel();
                    obj.SetActive(true);
                    mAnim = obj.GetComponent<Animation>();
                    if (mAnim == null)
                    {
                        Serclimax.DebugUtils.LogError("unit without Animation!");
                    }

                    SMRenderer = obj.GetComponentInChildren<SkinnedMeshRenderer>();
                    if (SMRenderer == null)
                    {
                        Serclimax.DebugUtils.LogError("unit without SkinnedMeshRenderer!");
                    }
#endif
                }
            }

            if (Flamethrower == null)
            {
                if (Eff_FlamethrowerName != null)
                {
                    GameObject obj = ResourceLibrary.instance.GetEffectInstanceFromPool(Eff_FlamethrowerName);
                    if (obj != null)
                    {
                        CsSkillAsset flamethrowerObj = obj.GetComponent<CsSkillAsset>();
                        flamethrowerObj.transform.parent = this.transform;
                        flamethrowerObj.transform.localPosition = Vector3.zero;
                        flamethrowerObj.transform.localRotation = Quaternion.identity;

                        Flamethrower = flamethrowerObj.GetComponentInChildren<CsFlamethrower>();
                        Flamethrower.init();
                    }
                }
            }

            if (SMRenderer != null)
            {
                //SMRenderer.material = _modelPrefab.GetComponentInChildren<SkinnedMeshRenderer>().material;
                if (mAnim != null)
                    mAnim.cullingType = AnimationCullingType.AlwaysAnimate;
                CsUnitMBMgr.Instance.AddUnit(this);
            }
        }

        protected int mTableid;
        public int tableid
        {
            get
            {
                return mTableid;
            }
            set
            {
                mTableid = value;
            }
        }

        protected int mUid;
        public int uid
        {
            get
            {
                return mUid;
            }
            set
            {
                mUid = value;
            }
        }

        private Animation mAnim;
        public Animation Anim
        {
            get
            {
                return mAnim;
            }
        }

        public SkinnedMeshRenderer SMRenderer;
        private CsSyncontroller<Serclimax.Unit.ScUnitMsg> mUnitSyncer = null;

        public CsSyncontroller<Serclimax.Unit.ScUnitMsg> Syncer
        {
            get
            {
                StructureSyncCon();
                return mUnitSyncer;
            }
        }

        public CsUnitAttr UnitAttr
        {
            get
            {
                return unitAttr;
            }
        }

        void SyncBones(CsBakeTagBones bones)
        {
            for (int i = 0, imax = Mathf.Min(bones.TagBones.Length, CsUnit.MaxCastSkillNum); i < imax; i++)
            {
                WPPOS[i] = bones.GetBonesPos(i);
                WPDIR[i] = bones.GetBonesRotate(i);
            }
        }

        void SyncMixBones(CsBakeTagBones bones)
        {
            if (OnlyAttack && BakeObj.CurAnimName != "attack_loop" && BakeObj.CurAnimName != "reload")
            {
                return;
            }
            {
                if (bones != null && bones.MixingTagBones != null && bones.MixingTagBones.Length != 0)
                {

                    for (int i = 0, imax = bones.MixingTagBones.Length; i < imax; i++)
                    {
                        //Vector3 ea = bones.MixingTagBones[i].localEulerAngles;
                        ////Quaternion q = Quaternion.identity;
                        //switch (TargetAix)
                        //{
                        //    case AffectTargetAix.ATA_X:
                        //        //q = Quaternion.AngleAxis(TargetAngle, Vector3.right);
                        //        ea.x = (OppositeTargetAix ? -1 : 1) * TargetAngle;
                        //        break;
                        //    case AffectTargetAix.ATA_Y:
                        //        //q = Quaternion.AngleAxis(TargetAngle, Vector3.up);
                        //        ea.y = (OppositeTargetAix ? -1 : 1) * TargetAngle;
                        //        break;
                        //    case AffectTargetAix.ATA_Z:
                        //        //q = Quaternion.AngleAxis(TargetAngle, Vector3.forward);
                        //        ea.z = (OppositeTargetAix ? -1 : 1) * TargetAngle;
                        //        break;

                        //}
                        //bones.MixingTagBones[i].localEulerAngles = ea;
                        Quaternion q = Quaternion.identity;
                        switch (TargetAix)
                        {
                            case AffectTargetAix.ATA_X:
                                q = Quaternion.AngleAxis((OppositeTargetAix ? -1 : 1) * TargetAngle, Vector3.right);
                                break;
                            case AffectTargetAix.ATA_Y:
                                q = Quaternion.AngleAxis((OppositeTargetAix ? -1 : 1) * TargetAngle, Vector3.up);
                                break;
                            case AffectTargetAix.ATA_Z:
                                q = Quaternion.AngleAxis((OppositeTargetAix ? -1 : 1) * TargetAngle, Vector3.forward);
                                break;
                        }
                        bones.MixingTagBones[i].localRotation = bones.MixingTagBoneQua[i] * q;
                    }
                }
            }

        }

        void SyncDeadMixBones(CsBakeTagBones bones)
        {
            if (bones != null && bones.DeadMixingTagBones != null && bones.DeadMixingTagBones.Length != 0)
            {
                for (int i = 0, imax = bones.DeadMixingTagBones.Length; i < imax; i++)
                {
                    bones.DeadMixingTagBones[i].localEulerAngles = DeadMixAngle;
                }
            }
        }

        public Vector3 GetFirePosForBuilding(int weaponid)
        {

            Vector3 result = Vector3.zero;
            if (_modelPrefab != null)
            {
                CsBakeTagBones cBone = _modelPrefab.GetComponent<CsBakeTagBones>();
                if (cBone == null)
                    return result;
                if (weaponid >= 0 && weaponid < cBone.TagBoneLength)
                    result = cBone.TagBones[weaponid].position;
            }
            return result;

        }

        CsUnitPosSyncer mPosSyncer = null;
        CsUnitAnimSyncer mAnimSyncer = null;
        void StructureSyncCon()
        {
            if (mUnitSyncer != null)
            {
                return;
            }

            mUnitSyncer = new CsSyncontroller<Serclimax.Unit.ScUnitMsg>();

            if (BakeObj != null && SMRenderer != null && mAnim != null)
            {
                BakeObj.InitObject(SMRenderer, mAnim, SyncBones, SyncMixBones, SyncDeadMixBones);
            }

            if (unitType == (int)Serclimax.Unit.ScUnitType.SUT_BUILD)
            {
                mUnitSyncer.AddSyncer(new CsHurtSyncer(this));
                mUnitSyncer.AddSyncer(new CsUnitBuidAnimSyner(this));
                mUnitSyncer.AddSyncer(new CsUnitPosSyncer(this.transform, this, false));
                mUnitSyncer.AddSyncer(new CsUnitAttrSyncer(UnitAttr, this));
            }
            else if (unitType == (int)Serclimax.Unit.ScUnitType.SUT_SOLDIER || unitType == (int)Serclimax.Unit.ScUnitType.SUT_CARRIER)
            {
                mUnitSyncer.AddSyncer(new CsUnitAnimSyncer(BakeObj, this));
                mUnitSyncer.AddSyncer(new CsHurtSyncer(this));
                mUnitSyncer.AddSyncer(new CsUnitPosSyncer(this.transform, this));
                mUnitSyncer.AddSyncer(new CsUnitAttrSyncer(UnitAttr, this));
                mUnitSyncer.AddSyncer(new CsStateEffectSyncer(this));
            }


        }

        public void DestroyUnitImmediate()
        {
            mIsDestroy = true;
            mState = DeadState.DS_NIL;
            if (SMRenderer != null)
            {
                if (CsUnitMBMgr.isValid)
                    CsUnitMBMgr.Instance.DeleteUnit(this);
            }
            GameObject.Destroy(this.gameObject);
            if (mHUD != null)
            {
                //if (CsObjPoolMgr.isValid)
                //    CsObjPoolMgr.Instance.Destroy(mHUD.gameObject);
                GameObject.Destroy(mHUD.gameObject);
                mHUD = null;
            }
            //if (mUnitAudio != null)
            //{
            //    mUnitAudio = null;
            //}
            //Syncer.OnDestroy();
            //ReclaimSelf();
        }

        public void DestroyUnit()
        {
            IsDead = true;
            if (ShadowPanel != null)
            {
                ShadowPanel.SetActive(false);
            }
            if (IsLevelImportTarget)
            {
                if (BakeObj != null)
                    BakeObj.ClearBlendAnimInifo();
                if (mHUD != null)
                {
                    if (CsObjPoolMgr.isValid)
                        CsObjPoolMgr.Instance.Destroy(mHUD.gameObject);
                    //GameObject.Destroy(mHUD.gameObject);
                    mHUD = null;
                }
                return;
            }

            mIsDestroy = true;
            mState = DeadState.DS_DEAD_ANIM;
            mDeadFadeTime = 0;
            if (BakeObj != null)
                BakeObj.ClearBlendAnimInifo();
            if (mHUD != null)
            {
                if (CsObjPoolMgr.isValid)
                    CsObjPoolMgr.Instance.Destroy(mHUD.gameObject);
                //GameObject.Destroy(mHUD.gameObject);
                mHUD = null;
            }
            //if(mUnitAudio != null)
            //{
            //    mUnitAudio = null;
            //}
        }

        bool UpdateDeadEffect()
        {
            if (!mIsDestroy)
            {
                return false;
            }

            if (unitType == (int)Serclimax.Unit.ScUnitType.SUT_BUILD || !EnableDeadFade)
                return mIsDestroy;

            if (mState == DeadState.DS_NIL)
                return true;
            switch (mState)
            {
                case DeadState.DS_DEAD_ANIM:
                    mWaitTime = WaitDeadAnimTime;
                    break;
                case DeadState.DS_DEAD_FADE:
                    mWaitTime = DeadFadeTime;
                    break;
            }
            mDeadFadeTime += Serclimax.GameTime.deltaTime;
            if (mDeadFadeTime <= mWaitTime)
            {
                if (mState == DeadState.DS_DEAD_FADE)
                {
                    this.transform.position += Vector3.down * 1 * Serclimax.GameTime.deltaTime;
                }
                else
                if (mState == DeadState.DS_DEAD_ANIM)
                {

                }
                return true;
            }
            else
            if (mState == DeadState.DS_DEAD_ANIM)
            {
                mState = DeadState.DS_DEAD_FADE;
                //if (DispalyCorpse)
                //{
                //    if(UnityEngine.Random.Range(0,100)<=50)
                //        CsDeadMgr.Instance.MakeCorpse(BakeObj);
                //}

                mDeadFadeTime = 0;
                return true;
            }
            mState = DeadState.DS_NIL;
            //Syncer.OnDestroy();
            if (SMRenderer != null)
            {
                if (CsUnitMBMgr.isValid)
                    CsUnitMBMgr.Instance.DeleteUnit(this);
            }
            //GameObject.Destroy(this.gameObject);
            if (mUnitSyncer != null)
            {
                mUnitSyncer.OnDestroy();
                mUnitSyncer.Clear();
                mUnitSyncer = null;
            }
            ReclaimSelf();
            return true;
        }
        public void PlaySfx(string sfxFile)
        {
            string[] sfxParams = sfxFile.Split(';');
            if (sfxParams.Length == 0 || sfxParams.Length > 2)
            {
                Debug.LogError("wrong sfx config : unit : " + name + "sfxCfg:" + sfxFile);
                return;
            }

            string sfxName = sfxParams[0];
            if (mUnitAudio.clip != null && mLastSfxName.Equals(sfxName) &&
                /*Serclimax.GameTime.realTime - mLastSfxTime < 0.05 && */
                mUnitAudio.isPlaying)
                return;

            if (AudioManager.Instance.PlaySfx(mUnitAudio, sfxName))
            {
                mLastSfxName = sfxName;
                mLastSfxTime = Serclimax.GameTime.realTime;
                mLastSfx = mUnitAudio.clip;
            }
        }
        //void Update()
        //{
        //    Profiler.BeginSample("CSUnit_ Update");
        //    if (UpdateDeadEffect())
        //        return;
        //    //if (mAnimSyncer != null)
        //    //{
        //    //    mAnimSyncer.Update(Serclimax.GameTime.deltaTime);
        //    //}
        //    //if (mPosSyncer != null)
        //    //{
        //    //    mPosSyncer.Update(Serclimax.GameTime.deltaTime);
        //    //}
        //    Syncer.UpdateSync(Serclimax.GameTime.deltaTime);
        //    Profiler.EndSample();
        //}

        public bool UpdateFromMgr()
        {
#if PROFILER
            Profiler.BeginSample("CSUnit_Sub_ Update");
#endif
            if (UpdateDeadEffect())
            {
#if PROFILER
                Profiler.EndSample();
#endif
                return mState != DeadState.DS_NIL;
            }

            //if (mAnimSyncer != null)
            //{
            //    mAnimSyncer.Update(Serclimax.GameTime.deltaTime);
            //}
            //if (mPosSyncer != null)
            //{
            //    mPosSyncer.Update(Serclimax.GameTime.deltaTime);
            //}
            Syncer.UpdateSync(Serclimax.GameTime.deltaTime);

            //             if(mUnitAudio != null)
            //             {
            //                 if (mUnitAudio.clip != null)
            //                 {
            //                     if (!mUnitAudio.isPlaying)
            //                     {
            //                         AudioManager.instance.CheckAudioClip(mUnitAudio.clip.name);
            //                     }
            //                 }
            //             }
#if PROFILER
            Profiler.EndSample();
#endif
            return true;
        }

        [System.Serializable]
        public class UnitDeadFlyInfo
        {
            public bool Enable = false;
            public float FirstStageNormalTime = 0;
            public float FirstStageAnimSpeed = 0;
            public float SecondStageNormalTime = 0;
            public float SecondStageAnimSpeed = 0;
            public float ThirdStageAnimSpeed = 0;
            public float MinFlySpeed = 0;
            public float MaxFlySpeed = 0;

            private float mSqrMinFlySpeed = -1;
            public float SqrMinFlySpeed
            {
                get
                {
                    if (mSqrMinFlySpeed < 0)
                    {
                        mSqrMinFlySpeed = MinFlySpeed * MinFlySpeed;
                    }
                    return mSqrMinFlySpeed;
                }
            }

            private float mSqrMaxFlySpeed = -1;
            public float SqrMaxFlySpeed
            {
                get
                {
                    if (mSqrMaxFlySpeed < 0)
                    {
                        mSqrMaxFlySpeed = MaxFlySpeed * MaxFlySpeed;
                    }
                    return mSqrMaxFlySpeed;
                }
            }
        }

        public bool OnDeadFly(float normal_time)
        {
            if (normal_time < DeadFlyInfo.FirstStageNormalTime)
                BakeObj.CurAnimInfo.Speed = (1 + DeadFlyRandTime) * DeadFlyInfo.FirstStageAnimSpeed;
            else
            if (normal_time >= DeadFlyInfo.FirstStageNormalTime && normal_time < DeadFlyInfo.SecondStageNormalTime)
            {

                this.transform.position += DeadFlyDir;
                BakeObj.CurAnimInfo.Speed = (1 + DeadFlyRandTime) * DeadFlyInfo.SecondStageAnimSpeed;

            }
            else
            {
                this.transform.position += Vector3.Lerp(DeadFlyDir, Vector3.zero, normal_time);
                BakeObj.CurAnimInfo.Speed = (1 + DeadFlyRandTime) * DeadFlyInfo.ThirdStageAnimSpeed;
            }
            return false;
        }

        private void ReclaimSelf()
        {
            if (Flamethrower != null)
            {
                if (CsObjPoolMgr.isValid)
                {
                    CsObjPoolMgr.Instance.Destroy(Flamethrower.gameObject);
                }

            }
            if (CsObjPoolMgr.isValid)
                CsObjPoolMgr.Instance.Destroy(this.gameObject);
            ReclaimReset();

        }

        private void ReclaimReset()
        {
            MoveSpeed = 1;
            DeadFlyDir = Vector3.zero;
            DeadFlyRandTime = 0;
            IsDead = false;
            mDeadFadeTime = 0;
            mWaitTime = 0;

            mLastSfx = null;
            mLastSfxTime = 0;
            mLastSfxName = string.Empty;
            mSfxData = null;

            for (int i = 0, imax = MaxCastSkillNum; i < imax; i++)
            {
                BindSkillInses[i] = null;
            }

            for (int i = 0, imax = MaxCastSkillNum; i < imax; i++)
            {
                BindBullteSkillInses[i] = null;
            }
            mState = DeadState.DS_NIL;
            RifleFire = null;
            mIsDestroy = false;
            mHUD = null;
            mStateEffect = null;
            Flamethrower = null;
            this.gameObject.SetActive(false);
            if (mAnim != null)
            {
                mAnim.Stop();
            }
            if (BakeObj != null)
            {
                BakeObj.Reset();
            }
        }
    }
}
