using System;
using System.Collections.Generic;
using UnityEngine;

namespace Clishow
{
    public class CsUnitPosSyncer : CsSynchronizer<Serclimax.Unit.ScUnitMsg>
    {
        private Transform mTrf = null;

        private Vector3 mTargetPos;
        private Vector3 mTargetDir;
        private Vector3 mFireDir;
        private bool mStart = false;
        private float mScale;
        private CsUnit mUnit;
        private bool mNeedUpdate = false;
        private bool mNeedCalFire = false;
        public CsUnitPosSyncer(Transform trf, CsUnit unit, bool need_update = true)
        {
            mNeedUpdate = need_update;
            mTrf = trf;
            mUnit = unit;
            mTargetDir = Vector3.zero;
        }
        public override void Sync(Serclimax.Unit.ScUnitMsg msg)
        {

            mTargetPos = msg.Pos;
            mTargetDir = msg.Dir;
            mFireDir = msg.TargetDir;
            mScale = msg.Scale;
            mUnit.MoveSpeed = msg.Speed / mUnit.Step;


            if (msg.isImmediately)
            {
                mNeedCalFire = mUnit.BakeObj != null &&
                    mUnit.BakeObj.TagBones != null &&
                    mUnit.BakeObj.TagBones.MixingTagBones != null &&
                    mUnit.BakeObj.TagBones.MixingTagBones.Length != 0;
                mTrf.position = msg.Pos;
                mUnit.mUnitAudio.transform.position = msg.Pos;
                if (mTargetDir != Vector3.zero)
                    mTrf.forward = mTargetDir;

            }

            //mTrf.position = msg.Pos;
            //if (mTargetDir != Vector3.zero)
            //    mTrf.forward = mTargetDir;

            if (mNeedCalFire && mFireDir != Vector3.zero)
                mUnit.TargetAngle = (Vector3.Dot(mFireDir, mTrf.right) > 0 ? -1 : 1) * Vector3.Angle(mTrf.forward, mFireDir.normalized);
            if (mUnit.LandingInfo.Enabled)
            {
                mUnit.LandingInfo.Active(msg.Pos, msg.Dir);
            }
        }
        Vector3 tmp;
        public override void Update(float _dt)
        {
            if (mNeedUpdate)
            {
                if (mUnit.LandingInfo.Update(_dt))
                    return;

                mTrf.position = Vector3.Lerp(mTrf.position, mTargetPos, 0.5f);
                mUnit.mUnitAudio.transform.position = mTrf.position;
                //mUnit.mUnitAudio.transform.position.Set(-(mTrf.position.x), mTrf.position.y, mTrf.position.z);
                if (mTargetDir != Vector3.zero)
                {
                    tmp = mTrf.forward;
                    mTrf.forward = Vector3.Lerp(mTrf.forward, mTargetDir, 0.25f);
                }
                if (mNeedCalFire && mFireDir != Vector3.zero)
                    mUnit.TargetAngle = (Vector3.Dot(mFireDir, mTrf.right) > 0 ? -1 : 1) * Vector3.Angle(mTrf.forward, mFireDir);
            }
        }
        public void Reset()
        {
            mTrf.position = mTargetPos;
            mUnit.mUnitAudio.transform.position = mTargetPos;
            //mUnit.mUnitAudio.transform.position.Set(-(mTargetPos.x) , mTargetPos.y, mTargetPos.z);
        }
    }


    public class CsBulletPosSyncer : CsSynchronizer<Serclimax.Skill.ScSKillMsg>
    {
        private CsBullteSkillIns mIns = null;

        private Vector3 mTargetPos;
        private Vector3 mTargetDir;
        Vector3 dir = Vector3.zero;
        private Vector3 mEndPos;
        private Vector3 mStartPos;
        private Vector3 mDir;
        private Vector3 mPerPos;
        private bool mIsBinding = false;
        private float mActiveTime;
        private float lenght = 0;
        public CsBulletPosSyncer(CsBullteSkillIns ins)
        {
            mIns = ins;
        }

        public override void Sync(Serclimax.Skill.ScSKillMsg msg)
        {
            mIns.Bullet.Dir = msg.Dir;
            mTargetPos = msg.Pos;
            mTargetDir = msg.Dir;
            mIns.BulletHitting = msg.Hitting;
            mEndPos = msg.TargetPos;
            mIns.Speed = msg.Speed;
            if (!mIsBinding)
            {

                if (msg.BindUnitID >= 0)
                {
                    CsUnit unit = CsUnitMgr.Instance.GetUnit(msg.BindUnitID);
                    if (unit != null && unit.BakeObj != null && unit.BakeObj.TagBones != null && unit.BakeObj.TagBones.TagBones != null)
                    {
                        for (int i = 0; i < 2; i++)
                        {
                            if (unit.BindBullteSkillInses[i] == null)
                            {
                                unit.BindBullteSkillInses[i] = mIns;
                                mIsBinding = true;
                                break;
                            }
                        }
                    }
                }
                if (!mIsBinding)
                {
                    mIsBinding = true;

                    if (!mIns.IsActived)
                    {
                        mIns.IsActived = true;
                        mIns.Bullet.Pos = mTargetPos;
                        mActiveTime = 0;
                    }
                }
            }
        }

        public override void OnDestroy()
        {
            mIsBinding = false;
        }
        Vector3 tmp;
        public override void Update(float _dt)
        {
            if (mIns.Bullet != null && mIns.IsActived)
            {
                mActiveTime += _dt;
                float dis = mIns.Speed * 0.018f * Serclimax.GameTime.deltaTime;
                tmp = mIns.Bullet.Pos + mIns.Bullet.Dir.normalized * dis;

                //if(Vector3.Dot( tmp - mIns.Bullet.Pos,mEndPos - tmp) < 0)
                //{
                //    tmp = mEndPos;
                //    dis = (mEndPos - mIns.Bullet.Pos).magnitude;
                //}


                lenght += dis;

                mIns.Bullet.Pos = tmp;//mIns.Bullet.Pos + mIns.Bullet.Dir.normalized * dis;
                if (mIns.Bullet.Pos.y > 0)
                {
                    //if(CsSkillMgr.Instance.ButtleSmokeEmitter != null)
                    //{
                    //    CsSkillMgr.Instance.ButtleSmokeEmitter.ShowTrailSmoke(mIns.Bullet.Pos);
                    //}

                    if (mIns.TrailObj != null)
                    {
                        mIns.TrailObj.Update(lenght);
                    }
                    if (CsSkillMgr.Instance.TrailCanvas != null && mIns.TrailObj == null)
                    {
                        mIns.TrailObj = CsSkillMgr.Instance.TrailCanvas.CreateTrail();
                        if (mIns.TrailObj != null)
                            mIns.TrailObj.Active(mIns.Bullet.Dir.normalized, mIns.Bullet.Pos, lenght);
                    }
                }
            }
        }
    }

    public class CsSkillPosSyncer : CsSynchronizer<Serclimax.Skill.ScSKillMsg>
    {
        private CsSkillIns mIns = null;

        private Vector3 mTargetPos;
        private Vector3 mTargetDir;
        private Vector3 mEndPos;
        private Vector3 mOldPos;
        private float mOffset = 1.5f;
        private GameObject mObj = null;
        private Vector3 mStartPos;
        private float mSprDis = -1;
        private float mHight = 0;
        private Vector3 mPerPos;
        private float mParabolaDis = 0;
        public CsSkillPosSyncer(CsSkillIns ins)
        {
            mIns = ins;
            mTargetDir = Vector3.zero;
            mObj = ins.gameObject;

        }

        public override void Sync(Serclimax.Skill.ScSKillMsg msg)
        {

            mTargetPos = msg.Pos;
            mTargetDir = msg.Dir;
            mIns.Speed = msg.Speed;

            if (mObj != null)
            {
                if (!mObj.activeSelf)
                {
                    mPerPos = msg.TargetPos;
                    mEndPos = msg.TargetPos;
                    mEndPos.y = 0;
                    mHight = mTargetPos.y;
                    mIns.transform.position = mTargetPos;
                    mOldPos = mIns.transform.position;
                    mParabolaDis = 0;
                    if (mTargetDir != Vector3.zero)
                        mIns.transform.forward = mTargetDir;
                    mObj.SetActive(true);
                    mStartPos = mTargetPos;
                    mStartPos.y = 0;
                    mSprDis = (mEndPos - mStartPos).magnitude;

                    if (mIns.SupportFlamethrower)
                    {
                        if (msg.BindUnitID >= 0)
                        {
                            CsUnit unit = CsUnitMgr.Instance.GetUnit(msg.BindUnitID);
                            if (unit != null && unit.Flamethrower != null)
                            {
                                unit.Flamethrower.transform.position = msg.Pos;
                                unit.Flamethrower.Active(mEndPos + Vector3.up * mHight, msg.Speed * 0.01f);
                            }
                        }
                    }

                    if (mIns.DisplayBoomResidual)
                        CsSkillMgr.Instance.BoomResidualEmitter.ShowBoom(mStartPos, mIns.BoomResidualSize);

                    if (mIns.mUnitAudio != null)
                        mIns.mUnitAudio.transform.position = mIns.transform.position;
                    if (mIns.SkillAsset != null)
                        mIns.SkillAsset.Show();
                    //mIns.mUnitAudio.transform.position.Set(-( mIns.transform.position.x) , mIns.transform.position.y, mIns.transform.position.z);
                }
            }
            if (mIns.SfxData != null && mIns.mUnitAudio != null)
            {
                if (!mIns.mUnitAudio.isPlaying)
                {
                    mIns.PlaySfx(mIns.SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_RUN));
                    //AudioManager.Instance.PlaySfx(mIns.mUnitAudio, mIns.SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_RUN));
                }
            }

            if (mEndPos != msg.TargetPos)
            {
                mEndPos = msg.TargetPos;
                mSprDis = (mEndPos - mStartPos).magnitude;
            }
            //                 if (!AudioManager.instance.SfxIsPlaying())
            //                     AudioManager.instance.PlaySfx(mIns.SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_RUN));
        }

        private bool UpdateParabola(float _dt)
        {
            if (!mIns.IsParabola)
            {
                return false;
            }
            mTargetPos.y = 0;
            Vector3 pos = mIns.transform.position;
            pos.y = 0;
            mOldPos.y = 0;
            mParabolaDis += (mTargetPos - mOldPos).magnitude;
            mOldPos = mTargetPos;
            //if(mParabolaDis >= mSprDis)
            //    mParabolaDis = mSprDis;
            float y = mParabolaDis / mSprDis;

            float yy = (float)Math.Sin(Mathf.PI * y);//- y)
            mTargetPos.y = yy * mIns.ParabolaHight + mHight * (y <= 0.5f ? 1 : Mathf.Max(1 - (y - 0.5f), 0));//Mathf.Lerp(mIns.transform.position.y,  ,0.5f);



            Vector3 forward = mTargetPos - mIns.transform.position;
            mIns.transform.position = mTargetPos;
            if (forward != Vector3.zero)
                mIns.transform.forward = Quaternion.RotateTowards(Quaternion.identity, Quaternion.FromToRotation(mIns.transform.forward, forward),
                            10) * mIns.transform.forward;//Vector3.Slerp(mIns.transform.forward, forward,0.8f);
            return true;
        }

        private void UpdateNormal(float _dt)
        {
            if (mIns.EnableNormalOffset)
            {
                Vector3 pos = mTargetPos;
                switch (mIns.NOffMode)
                {
                    case CsSkillIns.NormalOffsetMode.NOM_TOP:
                        pos.y = mTargetPos.y;
                        break;
                    case CsSkillIns.NormalOffsetMode.NOM_Middle:
                        pos.y = mTargetPos.y * 0.5f;
                        break;
                    case CsSkillIns.NormalOffsetMode.NOM_Bottom:
                        pos.y = 0;
                        break;
                }
                pos += mIns.NormalOffset;
                mIns.transform.position = pos;
            }
            else
            {
                mIns.transform.position = mTargetPos;
            }

            if (mTargetDir != Vector3.zero)
                mIns.transform.forward = mTargetDir;
        }

        public override void Update(float _dt)
        {
            if (!mIns.EnableSyncPos)
                return;
            if (!UpdateParabola(_dt))
            {
                UpdateNormal(_dt);
            }
        }

        public void Reset()
        {
            mIns.transform.position = mTargetPos;

        }
    }

    public class CsSkillMissileSync : CsSynchronizer<Serclimax.Skill.ScSKillMsg>
    {
        private CsSkillIns mIns = null;
        private CsMissileController mMissile = null;
        private Vector3 mTargetPos;
        private Vector3 mTargetDir;
        private float mOffset = 1.5f;
        private GameObject mObj = null;
        private float mSprDis = -1;
        private float mHight = 0;
        private bool mStart = false;

        public CsSkillMissileSync(CsSkillIns ins, CsMissileController missile)
        {
            mIns = ins;
            mMissile = missile;
            mTargetDir = Vector3.zero;
            mObj = ins.gameObject;
            mStart = false;
        }

        public override void Sync(Serclimax.Skill.ScSKillMsg msg)
        {
            if (mStart)
            {
                return;
            }
            mStart = true;
            if (mIns.mUnitAudio != null)
                mIns.mUnitAudio.transform.position = mTargetPos;
            //mIns.mUnitAudio.transform.position.Set(-(mTargetPos.x) , mTargetPos.y , mTargetPos.z) ;

            if (mIns.RangeTip != null)
            {
                mIns.RangeTip.SetSize(msg.size);
            }
            //mIns.RangeTip.SetSize(msg.size);
            mTargetPos = msg.Pos;
            mTargetDir = msg.Dir;
            mIns.transform.position = mTargetPos;
            mObj.SetActive(true);
            mMissile.Init(mTargetDir);

            if (mIns.SfxData != null)
            {
                mIns.PlaySfx(mIns.SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_RUN));
                //AudioManager.Instance.PlaySfx(mIns.mUnitAudio, mIns.SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_RUN));
            }
        }

        public override void Update(float _dt)
        {
            base.Update(_dt);
            mMissile.UpdateMissile(_dt);
        }

        public override void OnDestroy()
        {
            mStart = false;
            mMissile.ReclaimReset();
        }
    }
}


