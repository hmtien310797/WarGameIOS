using UnityEngine;
using System.Collections;

namespace Clishow
{
    public interface ICsSkillInterface
    {
        void SyncMsg(Serclimax.Skill.ScSKillMsg msg);

        void RemoveDestroy();

        void PlayDeadSfx();
    }

    public class CsNoneSkillIns : ICsSkillInterface
    {
        public void SyncMsg(Serclimax.Skill.ScSKillMsg msg)
        {

        }

        public void RemoveDestroy()
        {

        }

        public void PlayDeadSfx()
        {

        }
    }

    public class CsBullteSkillIns : ICsSkillInterface
    {
        public CsBullet Bullet = null;

        public CsTrailImageObj TrailObj = null;

        public bool ShortTrail = false;

        public bool BulletHitting = false;

        public float Speed = 0;

        public bool IsActived = true;

        public float DelayDestroy = 0;

        private bool isDestroy = false;

        private float mDestroyTime = 0;

        public bool _isDestroy
        {
            get
            {
                return isDestroy;
            }
        }

        private CsSyncontroller<Serclimax.Skill.ScSKillMsg> mUnitSyncer = null;

        public CsSyncontroller<Serclimax.Skill.ScSKillMsg> Syncer
        {
            get
            {
                StructureSyncCon();
                return mUnitSyncer;
            }
        }

        void StructureSyncCon()
        {
            if (mUnitSyncer != null)
            {
                return;
            }

            mUnitSyncer = new CsSyncontroller<Serclimax.Skill.ScSKillMsg>();
            mUnitSyncer.AddSyncer(new CsBulletPosSyncer(this));
        }

        public void SyncMsg(Serclimax.Skill.ScSKillMsg msg)
        {
            Syncer.SyncMsg(msg);
        }

        public void RemoveDestroy()
        {
            Destroy();
        }

        public void PlayDeadSfx()
        {

        }

        public void Destroy()
        {
            isDestroy = true;
            mDestroyTime = 0;

            if (DelayDestroy <= 0)
            {
                if (Bullet != null)
                {
                    Bullet.isALive = false;
                    if (CsSkillMgr.Instance.ButtleBeatenEmitter != null)
                    {
                        CsSkillMgr.Instance.ButtleBeatenEmitter.ShowBeaten(Bullet.Pos + Bullet.Dir * Bullet.Size.y * 2);
                    }
                    if (CsSkillMgr.Instance.BulletEmitter != null)
                    {
                        CsSkillMgr.Instance.BulletEmitter.DestroyBullet(Bullet);

                    }

                    Bullet = null;
                }
                if (CsSkillMgr.Instance.TrailCanvas != null)
                    CsSkillMgr.Instance.TrailCanvas.RemoveTrail(TrailObj);
                TrailObj = null;
                mDestroyTime = -1;
                Syncer.OnDestroy();
                IsActived = false;
            }
        }

        public void Update()
        {
            if (isDestroy)
            {
                if (mDestroyTime < 0)
                    return;

                if (Bullet != null && Bullet.isALive)
                {
                    if (BulletHitting)
                    {
                        if (CsSkillMgr.Instance.ButtleBeatenEmitter != null)
                        {
                            CsSkillMgr.Instance.ButtleBeatenEmitter.ShowBeaten(Bullet.Pos + Bullet.Dir * Bullet.Size.y * 2);
                        }
                        Bullet.isALive = false;
                        CsSkillMgr.Instance.BulletEmitter.DestroyBullet(Bullet);
                        Bullet = null;

                    }
                    else
                    {
                        if (CsSkillMgr.Instance.ButtleBeatenEmitter != null)
                        {
                            CsSkillMgr.Instance.ButtleBeatenEmitter.ShowBeaten(Bullet.Pos + Bullet.Dir * Bullet.Size.y * 2);
                        }
                        Bullet.isALive = false;
                        CsSkillMgr.Instance.BulletEmitter.DestroyBullet(Bullet);
                        Bullet = null;
                    }
                }


                mDestroyTime += Serclimax.GameTime.deltaTime;
                if (mDestroyTime >= DelayDestroy)
                {
                    if (CsSkillMgr.Instance.TrailCanvas != null && TrailObj != null)
                        CsSkillMgr.Instance.TrailCanvas.RemoveTrail(TrailObj);
                    TrailObj = null;
                    mDestroyTime = -1;
                    Syncer.OnDestroy();
                    IsActived = false;
                    return;
                }


                if (CsSkillMgr.Instance.TrailCanvas != null && TrailObj != null)
                {
                    float f = Mathf.Lerp(1, 0, mDestroyTime / DelayDestroy);//((DelayDestroy > 0.5f ? 0.5f : DelayDestroy)));
                    TrailObj.UpdateColor(f);
                    if (f <= 0)
                    {
                        if (CsSkillMgr.Instance.TrailCanvas != null)
                            CsSkillMgr.Instance.TrailCanvas.RemoveTrail(TrailObj);
                        TrailObj = null;
                    }
                    return;
                }
            }
            Syncer.UpdateSync(Time.deltaTime);
        }

        public void Clear()
        {
            Bullet = null;
            if (mUnitSyncer != null)
            {
                mUnitSyncer.Clear();
                mUnitSyncer = null;
            }
        }
    }

    public class CsSkillIns : MonoBehaviour, ICsSkillInterface
    {
        [Tooltip("调整爆炸弹坑的大小比例")]
        public float BoomResidualSize = 1;

        [Tooltip("是否开启爆炸后遗留弹坑效果")]
        public bool DisplayBoomResidual = false;

        [Tooltip("如果是子弹类型技能需要开启否可选择关闭")]
        public bool EnableSyncPos = true;

        [Tooltip("调整子弹类技能的外观比例大小")]
        public Vector3 BulletSize = Vector3.one;

        [Tooltip("调整子弹类技能的外观颜色")]
        public Color BulletColor = Color.white;

        [Tooltip("针对火焰兵的火焰喷射，火焰兵必须开启")]
        public bool SupportFlamethrower = false;

        [System.NonSerialized]
        public bool ShortTrail = false;

        [System.NonSerialized]
        public bool BulletHitting = false;

        [Tooltip("针对子弹类，是否开启抛物线")]
        public bool IsParabola = false;

        [Tooltip("针对子弹类抛物线的最大高度")]
        public float ParabolaHight = 2;

        [Tooltip("针对buff类，是否开启buff外观偏移")]
        public bool EnableNormalOffset = false;

        [Tooltip("针对buff类，偏移量")]
        public Vector3 NormalOffset = Vector3.zero;

        public enum NormalOffsetMode
        {
            NOM_Bottom,
            NOM_Middle,
            NOM_TOP,
        }

        [Tooltip("针对buff类，偏移基准点类型")]
        public NormalOffsetMode NOffMode = NormalOffsetMode.NOM_TOP;

        [System.NonSerialized]
        public PigeonCoopToolkit.Effects.Trails.Trail trail = null;

        [Tooltip("针对需要残留表现的技能 配合动画调整改时间")]
        public float DelayDestroy = 0;

        [Tooltip("针对技能效果在处理残留表现时可以关闭一些其他效果\n 如RGP的炮弹")]
        public Object[] ImmHideWhenDestroys = null;

        [Header("必须填充")]
        [Tooltip("在Art目录下 寻找属于该技能的技能源 \n 如包含了CsSkillAsset组件的脚本")]
        public CsSkillAsset SkillAssetPerfab = null;

        private CsSkillAsset mSkillAsset = null;

        public CsSkillAsset SkillAsset
        {
            get
            {
                return mSkillAsset;
            }
        }

        [System.NonSerialized]
        public float Speed = 0;

        [Tooltip("触发该技能时是否激活摄像机震动")]
        public bool IsShake = false;

        [Tooltip("摄像机震动激活延时")]
        public float ShakeDelay = 0;

        [Tooltip("摄像机震动峰值位置 \n 与原点进行震荡插值")]
        public Vector3 ShakeMagnitude = Vector3.one;

        [Tooltip("摄像机震动总时间")]
        public float ShakeTime = 0.5f;

        [Tooltip("摄像机震动频率")]
        public float ShakeFreq = 0.05f;
        private bool mIsShake = false;


        public AttackRangeTip RangeTip = new AttackRangeTip();

        private CsAttackRangeTip mRangeTipEx = null;

        private bool isDestroy = false;

        public bool _isDestroy
        {
            get
            {
                return isDestroy;
            }
        }

        private float mDestroyTime = 0;
        private float mShakeTime = 0;
        #region Audios
        public AudioSource mUnitAudio = null;
        private AudioClip mLastSfx;
        private string mLastSfxName = string.Empty;
        private float mLastSfxTime = 0;
        public int SfxTableId = 0;

        private Serclimax.Unit.ScUnitSfxData mSfxData = null;
        public Serclimax.Unit.ScUnitSfxData SfxData
        {
            get { return mSfxData; }
            set { mSfxData = value; }
        }

        #endregion

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

        private CsSyncontroller<Serclimax.Skill.ScSKillMsg> mUnitSyncer = null;

        public CsSyncontroller<Serclimax.Skill.ScSKillMsg> Syncer
        {
            get
            {
                StructureSyncCon();
                return mUnitSyncer;
            }
        }

        [System.Serializable]
        public class AttackRangeTip
        {
            public float ShowTime;
            public Color RangeColor;
            public float RangeFactor = 2;
            private MeshRenderer RangeRenderer = null;
            public void Init(MeshRenderer renderer)
            {
                RangeRenderer = renderer;
                if (RangeRenderer == null)
                {
                    return;
                }
                RangeRenderer.material.SetColor("_Color", RangeColor);
            }

            public void SetSize(float size)
            {
                if (RangeRenderer == null)
                    return;
                RangeRenderer.transform.parent.localScale = Vector3.one * size * RangeFactor;
            }

            private float mShowTime = 0;

            public void Update(float _dt)
            {
                if (RangeRenderer == null)
                    return;
                mShowTime += _dt;
                if (mShowTime >= ShowTime)
                {
                    RangeRenderer.gameObject.SetActive(false);
                }
            }

            public void Reset()
            {
                mShowTime = 0;
                if (RangeRenderer != null)
                    RangeRenderer.gameObject.SetActive(true);
            }
        }

        [System.NonSerialized]
        public float SubjoinTime = 0;

        void StructureSyncCon()
        {
            if (mUnitSyncer != null)
            {
                CsMissileController misslie = this.GetComponent<CsMissileController>();
                if (misslie != null)
                {
                    misslie.SubjoinTime = SubjoinTime;
                }
                return;
            }
            if (RangeTip != null)
            {
                if (mRangeTipEx != null)
                {
                    RangeTip.Init(mRangeTipEx.RangeRenderer);
                }
            }
            //RangeTip.Init();
            mUnitSyncer = new CsSyncontroller<Serclimax.Skill.ScSKillMsg>();
            {
                CsMissileController misslie = this.GetComponent<CsMissileController>();
                if (misslie != null)
                {
                    misslie.SubjoinTime = SubjoinTime;
                    mUnitSyncer.AddSyncer(new CsSkillMissileSync(this, misslie));
                }
                else
                    mUnitSyncer.AddSyncer(new CsSkillPosSyncer(this));
            }

        }

        private bool mNeedInit = true;

        public void Init()
        {
            if (!mNeedInit)
                return;
            mNeedInit = false;
            if (SkillAssetPerfab != null)
            {
                mSkillAsset = GameObject.Instantiate<CsSkillAsset>(SkillAssetPerfab);
                mSkillAsset.transform.parent = this.transform;
                mSkillAsset.transform.localPosition = Vector3.zero;
                mSkillAsset.transform.localRotation = Quaternion.identity;
                mSkillAsset.transform.localScale = Vector3.one;
                mSkillAsset.Init();
                mRangeTipEx = this.gameObject.GetComponentInChildren<CsAttackRangeTip>(true);
            }
        }

        void OnEnable()
        {
            isDestroy = false;
            mDestroyTime = 0;
            mIsShake = IsShake;
        }

        public void Destroy()
        {
            if (!this.gameObject.activeSelf)
            {
                this.gameObject.SetActive(true);
            }
            if (trail != null)
                trail.Emit = false;

            isDestroy = true;
            mDestroyTime = 0;
            if (mSkillAsset != null)
            {
                if (mSkillAsset.ImmHideWhenDestroys != null && mSkillAsset.ImmHideWhenDestroys.Length > 0)
                {
                    GameObject obj = null;
                    Behaviour beh = null;
                    Renderer ren = null;
                    ParticleSystem ps = null;
                    for (int i = 0, imax = mSkillAsset.ImmHideWhenDestroys.Length; i < imax; i++)
                    {
                        obj = mSkillAsset.ImmHideWhenDestroys[i] as GameObject;
                        if (obj != null)
                        {
                            obj.SetActive(false);
                        }
                        else
                        {
                            beh = mSkillAsset.ImmHideWhenDestroys[i] as Behaviour;
                            if (beh != null)
                            {
                                beh.enabled = false;
                            }
                            else
                            {
                                ren = mSkillAsset.ImmHideWhenDestroys[i] as Renderer;
                                if (ren != null)
                                {
                                    ren.enabled = false;
                                }
                                else
                                {
                                    ps = mSkillAsset.ImmHideWhenDestroys[i] as ParticleSystem;
                                    if (ps != null)
                                    {
                                        if (ps.loop)
                                        {
                                            ps.loop = false;
                                        }
                                    }
                                }
                            }

                        }

                    }
                }
            }

            //if (BulletHitting && Bullet != null)
            //{
            //    Bullet.isALive = false;
            //    if (CsSkillMgr.Instance.BulletEmitter != null)
            //        CsSkillMgr.Instance.BulletEmitter.DestroyBullet(Bullet);
            //    Bullet = null;
            //}

            if (DelayDestroy <= 0)
            {
                //GameObject.Destroy(this.gameObject);
                mDestroyTime = -1;
                //if (immediately)
                //{
                //    GameObject.Destroy(this.gameObject);
                //}
                //else
                {
                    Syncer.OnDestroy();
                    ReclaimReset();
                    if (CsObjPoolMgr.isValid)
                        CsObjPoolMgr.Instance.Destroy(this.gameObject);
                }
            }
        }

        void Update()
        {
            if (RangeTip != null)
            {
                RangeTip.Update(Serclimax.GameTime.deltaTime);
            }
            //RangeTip.Update(Serclimax.GameTime.deltaTime);
            if (mIsShake)
            {
                mShakeTime += Serclimax.GameTime.deltaTime;
                if (mShakeTime >= ShakeDelay)
                {
                    ShakeUtil.Shake(Camera.main.gameObject, ShakeTime, ShakeMagnitude, Vector3.zero, ShakeFreq);
                    mIsShake = false;
                    mShakeTime = 0;
                }
            }

            if (isDestroy)
            {
                if (mDestroyTime < 0)
                    return;
                mDestroyTime += Serclimax.GameTime.deltaTime;

                if (mDestroyTime >= DelayDestroy + SubjoinTime)
                {
                    //GameObject.Destroy(this.gameObject);
                    mDestroyTime = -1;
                    Syncer.OnDestroy();
                    ReclaimReset();

                    CsObjPoolMgr.Instance.Destroy(this.gameObject);

                    this.gameObject.SetActive(false);
                    return;
                }

            }
            Syncer.UpdateSync(Time.deltaTime);
        }

        public void ReclaimReset()
        {
            Syncer.OnReset();
            if (RangeTip != null)
            {
                RangeTip.Reset();
            }
            //RangeTip.Reset();
            isDestroy = false;
            mDestroyTime = 0;
            mShakeTime = 0;
            if (mSkillAsset != null)
            {
                if (mSkillAsset.ImmHideWhenDestroys != null && mSkillAsset.ImmHideWhenDestroys.Length > 0)
                {
                    GameObject obj = null;
                    Behaviour beh = null;
                    Renderer ren = null;
                    ParticleSystem ps = null;
                    for (int i = 0, imax = mSkillAsset.ImmHideWhenDestroys.Length; i < imax; i++)
                    {
                        obj = mSkillAsset.ImmHideWhenDestroys[i] as GameObject;
                        if (obj != null)
                        {
                            obj.SetActive(true);
                        }
                        else
                        {
                            beh = mSkillAsset.ImmHideWhenDestroys[i] as Behaviour;
                            if (beh != null)
                            {
                                beh.enabled = true;
                            }
                            else
                            {
                                ren = mSkillAsset.ImmHideWhenDestroys[i] as Renderer;
                                if (ren != null)
                                {
                                    ren.enabled = true;
                                }
                                else
                                {
                                    ps = mSkillAsset.ImmHideWhenDestroys[i] as ParticleSystem;
                                    if (ps != null)
                                    {
                                        if (ps.loop)
                                        {
                                            ps.loop = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }

        public void PlaySfx(string sfxFile)
        {
            if (mUnitAudio == null)
                return;

            string[] sfxParams = sfxFile.Split(';');
            if (sfxParams.Length == 0 || sfxParams.Length > 2)
            {
                Debug.LogError("wrong sfx config : unit : " + name + "sfxCfg:" + sfxFile);
                return;
            }

            string sfxName = sfxParams[0];
            if (mUnitAudio.clip != null && mLastSfxName.Equals(sfxName) &&
                Serclimax.GameTime.realDeltaTime - mLastSfxTime < 0.05 &&
                mUnitAudio.isPlaying)
                return;

            if (AudioManager.Instance.PlaySfx(mUnitAudio, sfxName))
            {
                mLastSfxName = sfxName;
                mLastSfxTime = Serclimax.GameTime.realTime;
                mLastSfx = mUnitAudio.clip;
            }
        }

        public void SyncMsg(Serclimax.Skill.ScSKillMsg msg)
        {
            Syncer.SyncMsg(msg);
        }

        public void RemoveDestroy()
        {
            Destroy();
        }

        public void PlayDeadSfx()
        {
            if (SfxData != null)
                PlaySfx(SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_DEAD));
        }
    }
}