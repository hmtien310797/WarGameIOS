using System;
using System.Collections.Generic;
using UnityEngine;

namespace Clishow
{
    public class CsUnitAnimSyncer : CsSynchronizer<Serclimax.Unit.ScUnitMsg>
    {
        private CsBakeObject mBakeObj = null;

        private int mCurAnimState = -1;

        private CsBakeObject.BakeAnimInfo mAdvancedAnimInfo = null;
        private CsBakeObject.BakeAnimInfo mAnimInfo = null;

        private CsBakeObject.BakeAnimInfo mRunAnimInfo = null;

        private int mPreAnimState;

        private CsUnit mUnit = null;

        private CsSkillAsset[] mRifleFire = new CsSkillAsset[CsUnit.MaxCastSkillNum];
        private CsSkillAsset mBornEffect = null;
        private CsSkillAsset mDeadEffect = null;
        private float BornEffectTime = 0;
        private bool mIsDead = false;

        private string sfxFile = string.Empty;
        private float sfxStart = -1;
        private int sfxLastState = -1;
        private int sfxLastAdvanceState = -1;
        CsBakeTagBones mGunsFireNodes = null;
        public CsUnitAnimSyncer(CsBakeObject obj, CsUnit unit)
        {
            mBakeObj = obj;
            mUnit = unit;
            mCurAnimState = -1;

            if (mUnit.BakeObj == null)
                mGunsFireNodes = mUnit.GetComponentInChildren<CsBakeTagBones>();
            else
                mGunsFireNodes = mUnit.BakeObj.TagBones;
            if (mGunsFireNodes != null)
            {
                int max = mGunsFireNodes.TagBoneLength;
                for (int i = 0, imax = Mathf.Min(max, CsUnit.MaxCastSkillNum); i < imax; i++)
                {
                    GameObject _obj = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.RifleFireName);
                    if (_obj != null)
                    {
                        mRifleFire[i] = _obj.GetComponent<CsSkillAsset>();
                        if (mRifleFire[i] != null)
                        {
                            mRifleFire[i].transform.parent = mUnit.transform;
                            mRifleFire[i].transform.localPosition = Vector3.zero;
                            mRifleFire[i].transform.localRotation = Quaternion.identity;
                            mRifleFire[i].gameObject.SetActive(false);
                        }
                    }
                }
            }


            GameObject _Bornobj = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.Eff_BornEffectName);
            if (_Bornobj == null)
            {
                _Bornobj = ResourceLibrary.instance.GetEffectInstanceFromPool("Bornsmoke");
            }
            mBornEffect = _Bornobj.GetComponent<CsSkillAsset>();
            if (mBornEffect != null)
            {
                mBornEffect.transform.parent = mUnit.transform;
                mBornEffect.transform.localPosition = Vector3.zero;
                mBornEffect.transform.localRotation = Quaternion.identity;
                mBornEffect.gameObject.SetActive(false);
            }
        }

        public override void Update(float _dt)
        {
            if (mRunAnimInfo != null)
            {
                mRunAnimInfo.Speed = mUnit.MoveSpeed;
            }

            if (mCurAnimState == (int)Serclimax.Unit.ScUnitAnimState.SUAS_BORN)
            {
                if ((mUnit.mBornStartTime <= BornEffectTime) && mBornEffect != null)
                {
                    if (!mBornEffect.gameObject.activeSelf)
                    {
                        mBornEffect.transform.position = mUnit.transform.position;
                        //mBornEffect.transform.localRotation = Quaternion.identity;
                        //mBornEffect.gameObject.SetActive(true);
                        if (mBornEffect.Particle != null)
                            mBornEffect.Particle.Active();
                        BornEffectTime = -1;
                    }

                }
                if (BornEffectTime >= 0)
                    BornEffectTime += _dt;
            }
        }

        private bool AttackAnimProgress(float progress)
        {
            if (mRifleFire == null)
                return true;
            if (progress >= mUnit.ShowRifleFireTime || progress < 0)
            {
                {
                    int max = mGunsFireNodes.TagBoneLength;
                    {
                        for (int i = 0, imax = Mathf.Min(max, CsUnit.MaxCastSkillNum); i < imax; i++)
                        {
                            if (mRifleFire[i] != null)
                            {
#if BakeMesh
                                mRifleFire[i].transform.localPosition = mUnit.WPPOS[i];
                                mRifleFire[i].transform.localRotation = mUnit.WPDIR[i];
#else
                                mRifleFire[i].transform.position = mUnit.WPPOS[i];
                                mRifleFire[i].transform.rotation = mUnit.WPDIR[i];
#endif
                                CsBullteSkillIns ins = mUnit.BindBullteSkillInses[i];
                                if (ins != null && !ins._isDestroy && ins.Bullet != null)
                                {
#if BakeMesh
                                    ins.Bullet.Pos = mUnit.transform.TransformPoint(mUnit.WPPOS[i]) + mRifleFire[i].transform.forward * mUnit.ButtleOffset;
#else
                                    ins.Bullet.Pos = mUnit.WPPOS[i] + mRifleFire[i].transform.forward * mUnit.ButtleOffset;
#endif
                                    //ins.transform.position = mUnit.BindSkillInses[i].Bullet.Pos;
                                    //ins.gameObject.SetActive(true);
                                    ins.IsActived = true;
                                }
                                mUnit.BindBullteSkillInses[i] = null;
                                if (mRifleFire[i].Particle != null)
                                    mRifleFire[i].Particle.Active();
                            }
                        }
                    }


                }
                return true;
            }
            return false;
        }
        private bool PlayUnitSfx(float progress)
        {
            if (mUnit.mUnitAudio == null)
                return true;
            if (mUnit.SfxData == null)
                return true;

            if (mCurAnimState != sfxLastState)
            {
                sfxLastState = mCurAnimState;
                sfxFile = mUnit.SfxData.GetStateSfx((Serclimax.Unit.ScUnitAnimState)mCurAnimState);
                if (sfxFile == null || sfxFile == string.Empty || sfxFile.Equals("NA"))
                {
                    if (mCurAnimState != (int)Serclimax.Unit.ScUnitAnimState.SUAS_STANDBY)
                        // if (mUnit.mUnitAudio.isPlaying)
                        mUnit.mUnitAudio.Stop();
                    return true;
                }

                string[] sfxInfo = sfxFile.Split(';');
                if (sfxInfo.Length == 2)
                {
                    sfxStart = float.Parse(sfxInfo[1]);
                }
                else if (sfxInfo.Length == 1)
                {
                    sfxStart = 0;
                }
                else
                {
                    return true;
                }
            }

            if (sfxStart >= 0 && progress >= sfxStart)
            {
                mUnit.PlaySfx(sfxFile);
                //AudioManager.Instance.PlaySfx(mUnit.mUnitAudio , sfxFile);
                sfxStart = -1;
                sfxLastState = -1;
                return true;
            }
            return false;

            /*
            if(mUnit.SfxData == null)
                return true;

            if (mCurAnimState != sfxLastState)
            {
                sfxLastState = mCurAnimState;
                string sfxConfig = mUnit.SfxData.GetStateSfx((Serclimax.Unit.ScUnitAnimState)mCurAnimState);
                if (sfxConfig == null || sfxConfig == string.Empty)
                    return true;

                string[] sfxInfo = sfxConfig.Split(';');
                if (sfxInfo.Length == 2)
                {
                    sfxFile = sfxInfo[0];
                    sfxStart = float.Parse(sfxInfo[1]);
                }
                else if (sfxInfo.Length == 1)
                {
                    sfxFile = sfxInfo[0];
                    sfxStart = 0;
                }
                else
                {
                    return true;
                }

                

            }
            if (sfxStart >= 0 && progress >= sfxStart)
            {
                if (sfxFile == string.Empty || sfxFile == "0")
                    return true;
                mUnit.PlaySfx(sfxFile);
                
                sfxStart = 0;
                sfxLastState = -1;
                return true;
            }
            
            return false;
            */
        }
        private bool PlayUnitAdvanceSfx(float progress)
        {
            if (mUnit.mUnitAudio == null)
                return true;
            if (mUnit.SfxData == null)
                return true;


            if (mPreAnimState != sfxLastState)
            {
                sfxLastState = mPreAnimState;
                sfxFile = mUnit.SfxData.GetStateSfx((Serclimax.Unit.ScUnitAnimState)mPreAnimState);
                if (sfxFile == null || sfxFile == string.Empty || sfxFile.Equals("NA"))
                    return true;

                string[] sfxInfo = sfxFile.Split(';');
                if (sfxInfo.Length == 2)
                {
                    sfxStart = float.Parse(sfxInfo[1]);
                }
                else if (sfxInfo.Length == 1)
                {
                    sfxStart = 0;
                }
                else
                {
                    return true;
                }
            }

            if (sfxStart >= 0 && progress >= sfxStart)
            {
                mUnit.PlaySfx(sfxFile);
                //AudioManager.Instance.PlaySfx(mUnit.mUnitAudio, sfxFile);
                sfxStart = -1;
                sfxLastState = -1;
                return true;
            }
            return false;
            /*
            if (mUnit.SfxData == null)
                return true;

            if (mPreAnimState != sfxLastState)
            {
                sfxLastState = mPreAnimState;
                string sfxConfig = mUnit.SfxData.GetStateSfx((Serclimax.Unit.ScUnitAnimState)mPreAnimState);
                if (sfxConfig == null || sfxConfig == string.Empty)
                    return true;

                string[] sfxInfo = sfxConfig.Split(';');
                if (sfxInfo.Length == 2)
                {
                    sfxFile = sfxInfo[0];
                    sfxStart = float.Parse(sfxInfo[1]);
                }
                else if (sfxInfo.Length == 1)
                {
                    sfxFile = sfxInfo[0];
                    sfxStart = 0;
                }
                else
                {
                    return true;
                }
            }
            if (sfxStart >= 0 && progress >= sfxStart)
            {
                if (sfxFile == string.Empty || sfxFile == "0")
                    return true;
                mUnit.PlaySfx(sfxFile);
                //AudioManager.instance.PlaySfx(sfxFile);
                sfxStart = 0;
                sfxLastState = -1;
                return true;
            }

            return false;
            */
        }
        public override void OnDestroy()
        {
            mBornEffect = null;
            if (mRifleFire != null)
            {
                for (int i = 0; i < mRifleFire.Length; i++)
                {
                    if (mRifleFire[i] != null)
                    {
                        if (mRifleFire[i].Particle != null)
                        {
                            mRifleFire[i].Particle.ReclaimReset();
                        }
                        if (CsObjPoolMgr.isValid)
                            CsObjPoolMgr.Instance.Destroy(mRifleFire[i].gameObject);
                        mRifleFire[i] = null;
                    }
                }

            }
            //if(mDeadEffect != null)
            // {
            //     if (mDeadEffect.Particle != null)
            //     {
            //         mDeadEffect.Particle.ReclaimReset();
            //     }

            //     CsObjPoolMgr.Instance.Destroy(mDeadEffect.gameObject);
            //     mDeadEffect = null;
            // }
        }

        int RecordImportTargetAnimState = -1;
        Vector3 RecordImprotTargetDir = Vector3.zero;

        private bool DisAdvanceAnimState(int state, Vector3 dir)
        {
            if (mIsDead)
                return false;
            if (state >= 0)
            {
                CsBakeObject.NoticeAnimProgressHandle handle = null;
                if (state == (int)Serclimax.Unit.ScUnitAnimState.SUAS_ATTACK)
                {
                    handle = AttackAnimProgress;
                }
                else
                if (state == (int)Serclimax.Unit.ScUnitAnimState.SUAS_DEAD_FLY)
                {
                    if (!string.IsNullOrEmpty(mUnit.Eff_DeadEffectName))
                    {
                        GameObject boomObj = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.Eff_DeadEffectName);
                        if (boomObj != null)
                        {
                            CsSkillAsset deadEffect = boomObj.GetComponent<CsSkillAsset>();
                            deadEffect.gameObject.transform.parent = CsSkillMgr.Instance.transform;
                            deadEffect.gameObject.transform.position = mUnit.transform.position;
                            //deadEffect.transform.forward = mUnit.transform.forward;
                            deadEffect.gameObject.SetActive(false);
                            if (deadEffect.Particle != null)
                            {
                                deadEffect.Particle.Active();
                            }
                        }
                    }
                    if (mUnit.DeadFlyInfo.Enable)
                    {
                        mUnit.DeadFlyDir = dir;
                        handle = mUnit.OnDeadFly;
                        mUnit.DeadFlyDir.y = 0;
                        if (mUnit.DeadFlyDir.sqrMagnitude < mUnit.DeadFlyInfo.SqrMinFlySpeed)
                        {
                            mUnit.DeadFlyDir = mUnit.DeadFlyDir.normalized * mUnit.DeadFlyInfo.SqrMinFlySpeed;
                        }
                        else
                        if (mUnit.DeadFlyDir.sqrMagnitude > mUnit.DeadFlyInfo.SqrMaxFlySpeed)
                        {
                            mUnit.DeadFlyDir = mUnit.DeadFlyDir.normalized * mUnit.DeadFlyInfo.SqrMaxFlySpeed;
                        }
                        mUnit.DeadFlyDir *= 0.02f;
                        mUnit.DeadFlyRandTime = UnityEngine.Random.Range(0.0f, 1f);
                    }
                    mIsDead = true;
                }
                else
                if (state == (int)Serclimax.Unit.ScUnitAnimState.SUAS_DEAD)
                {
                    if (!string.IsNullOrEmpty(mUnit.Eff_DeadEffectName))
                    {
                        GameObject boomObj = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.Eff_DeadEffectName);
                        if (boomObj != null)
                        {
                            CsSkillAsset deadEffect = boomObj.GetComponent<CsSkillAsset>();
                            deadEffect.gameObject.transform.parent = CsSkillMgr.Instance.transform;
                            deadEffect.gameObject.transform.position = mUnit.transform.position;
                            //deadEffect.transform.forward = mUnit.transform.forward;
                            deadEffect.gameObject.SetActive(false);
                            if (deadEffect.Particle != null)
                            {
                                deadEffect.Particle.Active();
                            }
                        }
                    }
                    mIsDead = true;
                }



                if (mIsDead)
                {
                    if (mUnit.Flamethrower != null)
                    {
                        mUnit.Flamethrower.StopEmit();
                    }
                    mUnit.DeadMixAngle = new Vector3(UnityEngine.Random.Range(mUnit.DeadKLimitAngle.x, mUnit.DeadKLimitAngle.y) * (UnityEngine.Random.Range(0, 10) % 2 == 0 ? 1 : -1),
                        UnityEngine.Random.Range(mUnit.DeadKLimitAngle.x, mUnit.DeadKLimitAngle.y) * (UnityEngine.Random.Range(0, 10) % 2 == 0 ? 1 : -1),
                        UnityEngine.Random.Range(mUnit.DeadKLimitAngle.x, mUnit.DeadKLimitAngle.y) * (UnityEngine.Random.Range(0, 10) % 2 == 0 ? 1 : -1));

                }
                if (mUnit.unitType == (int)Serclimax.Unit.ScUnitType.SUT_CARRIER)
                {
                    mAdvancedAnimInfo = mBakeObj.ForcePlay(CsConst.UnitState2Names[state], handle);
                }
                else
                {
                    if (mIsDead || state == (int)Serclimax.Unit.ScUnitAnimState.SUAS_BORN)
                        mAdvancedAnimInfo = mBakeObj.ForcePlay(CsConst.UnitState2Names[state], handle);
                    else
                        mAdvancedAnimInfo = mBakeObj.Play(CsConst.UnitState2Names[state], state != (int)Serclimax.Unit.ScUnitAnimState.SUAS_ATTACK, handle);
                }


                if (mIsDead)
                {
                    if (mUnit.BakeObj != null)
                    {
                        mUnit.BakeObj.IsDead = true;
                    }
                }

                mAdvancedAnimInfo.setUnitSfxHandle(PlayUnitAdvanceSfx);
                mPreAnimState = state;
                return true;
            }
            else
            {
                if (mAdvancedAnimInfo != null)
                {
                    if (mAdvancedAnimInfo.isValid)
                        return true;
                    else
                    {
                        mCurAnimState = -1;
                        mAdvancedAnimInfo = null;
                    }
                }
            }
            return false;
        }


        public override void Command(string cmd)
        {
            base.Command(cmd);
            if (cmd == "dead")
            {
                DisAdvanceAnimState(RecordImportTargetAnimState, RecordImprotTargetDir);
            }
        }

        public override void Sync(Serclimax.Unit.ScUnitMsg msg)
        {
            if (mUnit.IsLevelImportTarget && (msg.AdvancedAnimState == (int)Serclimax.Unit.ScUnitAnimState.SUAS_DEAD_FLY || msg.AdvancedAnimState == (int)Serclimax.Unit.ScUnitAnimState.SUAS_DEAD))
            {
                RecordImportTargetAnimState = msg.AdvancedAnimState;
                RecordImprotTargetDir = msg.Dir;
                return;
            }

            if (!mUnit.LandingInfo.Enabled && DisAdvanceAnimState(msg.AdvancedAnimState, msg.Dir))
                return;
            if (mIsDead)
                return;
            if (mCurAnimState != msg.AnimState)
            {
                if (mIsDead)
                {

                    Debug.LogError("XXXXXXXXXXXXXXXXXXXXXXXX " + CsConst.UnitState2Names[mCurAnimState]);
                    return;
                }

                if (mUnit.LandingInfo.Enabled)
                    return;
                mCurAnimState = msg.AnimState;
                if (mBakeObj != null && mCurAnimState >= 0 && mCurAnimState < CsConst.UnitState2Names.Length)
                {
                    if (mUnit.Flamethrower != null)
                    {
                        mUnit.Flamethrower.StopEmit();
                    }

                    if (mCurAnimState == 1)
                    {
                        if (mUnit.unitType == (int)Serclimax.Unit.ScUnitType.SUT_CARRIER)
                        {
                            mRunAnimInfo = mBakeObj.ForcePlay(CsConst.UnitState2Names[mCurAnimState]);
                        }
                        else
                            mRunAnimInfo = mBakeObj.Play(CsConst.UnitState2Names[mCurAnimState]);

                        mAnimInfo = mRunAnimInfo;
                    }
                    else if (mCurAnimState == 10)//collection
                    {
                        if (mUnit.StateEffect == null)
                        {
                            GameObject obj = ResourceLibrary.GetUnitHudInstance("UnitCD");
                            if (obj != null)
                            {
                                mUnit.StateEffect = obj.GetComponent<UnitStateEffect>();
                                if (mUnit.StateEffect == null)
                                {
                                    mUnit.StateEffect = obj.AddComponent<UnitStateEffect>();
                                }
                            }
                        }
                        mUnit.StateEffect.name = mUnit.StateEffect.name + "_" + mUnit.name;
                        mUnit.StateEffect.Show();
                        mUnit.StateEffect.SetTarget(Camera.main, mUnit.gameObject);
                        mAnimInfo = mBakeObj.ForcePlay(CsConst.UnitState2Names[mCurAnimState]);
                    }
                    else
                    if (mCurAnimState == (int)Serclimax.Unit.ScUnitAnimState.SUAS_LANDING)
                    {
                        mUnit.LandingInfo.Enabled = true;
                    }
                    else
                    {
                        if (mUnit.unitType == (int)Serclimax.Unit.ScUnitType.SUT_CARRIER)
                        {
                            mRunAnimInfo = mBakeObj.ForcePlay(CsConst.UnitState2Names[mCurAnimState]);
                            mAnimInfo = mRunAnimInfo;
                        }
                        else
                        {
                            mAnimInfo = mBakeObj.Play(CsConst.UnitState2Names[mCurAnimState], true);
                        }
                        mRunAnimInfo = null;

                    }
                    if (mAnimInfo != null)
                        mAnimInfo.setUnitSfxHandle(PlayUnitSfx);
                    mPreAnimState = mCurAnimState;
                }
            }
            else
            {
                if (mAnimInfo != null)
                {
                    if (!mAnimInfo.isValid)
                    {
                        mAnimInfo = null;
                    }
                    else
                    {
                        if (mUnit.unitType == (int)Serclimax.Unit.ScUnitType.SUT_CARRIER)
                        {
                            if (!AudioManager.instance.SfxIsPlaying())
                                PlayUnitSfx(1);
                        }
                    }
                }
            }
        }
    }

    public class CsUnitBuidAnimSyner : CsSynchronizer<Serclimax.Unit.ScUnitMsg>
    {

        private CsUnit mUnit;
        private Animation mAnimation;
        CsSkillAsset BuilBoom = null;
        CsSkillAsset BuilBoomFire = null;
        private int mCurAnimState = -1;

        private CsBakeTagBones mGunsFireNodes = null;
        private CsSkillAsset[] mGunsFires = new CsSkillAsset[CsUnit.MaxCastSkillNum];
        private CsBakeObject.BakeAnimInfo mAnimInfo = null;

        private string sfxDead = string.Empty;
        private string sfxAttack = string.Empty;

        private CsSkillAsset mBornEffect = null;
        private float BornEffectTime = 0;

        public CsUnitBuidAnimSyner(CsUnit unit)
        {
            mUnit = unit;
            mAnimation = mUnit.GetComponentInChildren<Animation>();
            if (mUnit.BakeObj == null)
                mGunsFireNodes = mUnit.GetComponentInChildren<CsBakeTagBones>();
            else
                mGunsFireNodes = mUnit.BakeObj.TagBones;
            if (mGunsFireNodes != null)
            {
                GameObject obj = null;
                int max = mGunsFireNodes.TagBoneLength;
                for (int i = 0, imax = Mathf.Min(max, CsUnit.MaxCastSkillNum); i < imax; i++)
                {
                    obj = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.RifleFireName);
                    if (obj == null)
                        break;
                    CsSkillAsset gf = obj.GetComponent<CsSkillAsset>();
                    if (gf == null)
                        break;
                    gf.gameObject.SetActive(false);
                    gf.transform.parent = mUnit.transform;
                    gf.transform.localPosition = Vector3.zero;
                    gf.transform.localRotation = Quaternion.identity;
                    mGunsFires[i] = gf;
                }
            }


            if (BuilBoom == null)
            {
                GameObject boomObj = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.Eff_DeadEffectName);
                if (boomObj == null)
                {
                    boomObj = ResourceLibrary.instance.GetEffectInstanceFromPool("BuildBoom");

                }

                BuilBoom = boomObj.GetComponent<CsSkillAsset>();
                BuilBoom.gameObject.transform.parent = mUnit.transform;
                // Vector3 pos = mUnit.transform.position;
                //pos.y = 0;
                BuilBoom.gameObject.transform.position = mUnit.transform.position;
                BuilBoom.transform.forward = mUnit.transform.forward;
                BuilBoom.gameObject.SetActive(false);
            }
            if (mUnit.BuildUnitDestroyEnableFire)
            {
                if (BuilBoomFire == null)
                {
                    BuilBoomFire = ResourceLibrary.instance.GetEffectInstanceFromPool("Fire").GetComponent<CsSkillAsset>();
                    if (BuilBoomFire == null)
                        return;
                    BuilBoomFire.gameObject.transform.parent = mUnit.transform;
                    BuilBoomFire.gameObject.transform.position = mUnit.transform.position;
                    BuilBoomFire.transform.forward = mUnit.transform.forward;
                    BuilBoomFire.gameObject.SetActive(false);
                }
            }


            //born
            GameObject _Bornobj = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.Eff_BornEffectName);
            if (_Bornobj != null)
            {
                mBornEffect = _Bornobj.GetComponent<CsSkillAsset>();
                if (mBornEffect != null)
                {
                    mBornEffect.transform.parent = mUnit.transform;
                    mBornEffect.transform.localPosition = Vector3.zero;
                    mBornEffect.transform.localRotation = Quaternion.identity;
                    mBornEffect.gameObject.SetActive(false);
                }
            }


            //sfx
            if (mUnit.SfxData != null)
            {
                sfxDead = mUnit.SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_DEAD);
                sfxAttack = mUnit.SfxData.GetStateSfx(Serclimax.Unit.ScUnitAnimState.SUAS_ATTACK);
            }
        }

        public override void OnDestroy()
        {
            {
                for (int i = 0, imax = CsUnit.MaxCastSkillNum; i < imax; i++)
                {
                    if (mGunsFires[i] != null)
                    {
                        if (mGunsFires[i].Particle != null)
                        {
                            mGunsFires[i].Particle.ReclaimReset();
                        }
                        if (CsObjPoolMgr.isValid)
                            CsObjPoolMgr.Instance.Destroy(mGunsFires[i].gameObject);
                        mGunsFires[i] = null;
                    }
                }
            }
            if (BuilBoom != null)
            {
                if (BuilBoom.Particle != null)
                {
                    BuilBoom.Particle.ReclaimReset();
                }

                CsObjPoolMgr.Instance.Destroy(BuilBoom.gameObject);
                BuilBoom = null;
            }
            if (BuilBoomFire != null)
            {
                if (BuilBoomFire.Particle != null)
                {
                    BuilBoomFire.Particle.ReclaimReset();
                }
                CsObjPoolMgr.Instance.Destroy(BuilBoomFire.gameObject);
                BuilBoomFire = null;
            }
        }

        public override void Command(string cmd)
        {
            base.Command(cmd);
            if (cmd == "dead")
            {
                mUnit.PlaySfx(sfxDead);
                //AudioManager.Instance.PlaySfx(mUnit.mUnitAudio, sfxDead);
                //AudioManager.instance.PlaySfx(sfxDead);

                if (mUnit.BakeObj != null)
                {
                    mUnit.BakeObj.ForcePlay("die");
                }
                else
                if (mAnimation != null)
                    mAnimation.Play("die");

                //load
                if (BuilBoom != null)
                    BuilBoom.gameObject.SetActive(true);
                if (BuilBoomFire != null)
                    BuilBoomFire.gameObject.SetActive(true);
            }
        }

        public override void Sync(Serclimax.Unit.ScUnitMsg msg)
        {
            if (mUnit.IsLevelImportTarget)
            {
                if (mCurAnimState != msg.AnimState)
                {
                    if (msg.AnimState == 0)
                    {
                        if (mUnit.BakeObj != null)
                        {
                            mUnit.BakeObj.ForcePlay("idle");
                        }
                        else if (mAnimation != null)
                        {
                            mAnimation.Play("idle");
                        }
                    }
                    mCurAnimState = msg.AnimState;
                }
                return;
            }

            if (msg.AnimState == (int)Serclimax.Unit.ScUnitAnimState.SUAS_DEAD)
            {
                Command("dead");
            }
            else
            if (msg.SkillLuanchInfos.Count > 0)
            {
                mUnit.PlaySfx(sfxAttack);
                //AudioManager.instance.PlaySfx(sfxAttack);
                //AudioManager.Instance.PlaySfx(mUnit.mUnitAudio, sfxAttack);

                if (mUnit.BakeObj != null)
                {
                    mUnit.BakeObj.ForcePlay("attack_loop");
                }
                else
                    if (mAnimation != null && mAnimation["attack_loop"] != null)
                    mAnimation.Play("attack_loop");
                int max = msg.SkillLuanchInfos.Count;
                for (int i = 0, imax = Mathf.Min(max, CsUnit.MaxCastSkillNum); i < imax; i++)
                {
                    int index = msg.SkillLuanchInfos[i];
                    if (mUnit.BakeObj != null)
                    {
                        CsSkillAsset gf = mGunsFires[i];
                        if (gf != null)
                        {
#if BakeMesh
                            gf.transform.localPosition = mUnit.WPPOS[i];
                            gf.transform.localRotation = mUnit.WPDIR[i];
#else
                            gf.transform.position = mUnit.WPPOS[i];
                            gf.transform.rotation = mUnit.WPDIR[i];
#endif
                            {
                                //for (int j = 0, jmax = mUnit.BindSkillInses.Count; j < jmax; j++)
                                {
                                    CsBullteSkillIns ins = mUnit.BindBullteSkillInses[i];
                                    if (ins != null && !ins._isDestroy && ins.Bullet != null)
                                    {

#if BakeMesh
                                        ins.Bullet.Pos = gf.transform.position + gf.transform.forward * mUnit.ButtleOffset;
#else
                                        ins.Bullet.Pos = mUnit.WPPOS[i] + gf.transform.forward * mUnit.ButtleOffset;
#endif
                                        //ins.transform.position = ins.Bullet.Pos;
                                        //ins.gameObject.SetActive(true);
                                        ins.IsActived = true;

                                    }
                                    mUnit.BindBullteSkillInses[i] = null;
                                    ins = null;
                                }

                            }
                            if (gf.Particle != null)
                                gf.Particle.Active();
                        }
                    }
                }
            }
            else
            {
                if (mUnit.BakeObj != null)
                {
                    //if (mAnimation != null && mAnimation["attack_loop"] != null)
                    //    mAnimation.PlayQueued("idle");
                    mUnit.BakeObj.ForcePlay("idle", null, true);
                }
            }
            mCurAnimState = msg.AnimState;

        }
        public override void Update(float _dt)
        {
            if (mCurAnimState == (int)Serclimax.Unit.ScUnitAnimState.SUAS_BORN)
            {
                if ((mUnit.mBornStartTime <= BornEffectTime) && mBornEffect != null)
                {
                    if (!mBornEffect.gameObject.activeSelf)
                    {
                        mBornEffect.transform.position = mUnit.transform.position;
                        //mBornEffect.transform.localRotation = Quaternion.identity;
                        //mBornEffect.gameObject.SetActive(true);
                        if (!mBornEffect.gameObject.activeSelf)
                            mBornEffect.gameObject.SetActive(true);
                        BornEffectTime = -1;
                    }

                }
                if (BornEffectTime >= 0)
                    BornEffectTime += _dt;
            }
            else if (mCurAnimState == (int)Serclimax.Unit.ScUnitAnimState.SUAS_IDLE)
            {
                if (mBornEffect != null)
                    mBornEffect.gameObject.SetActive(false);
            }
        }
        public void Reset()
        {


        }
    }
}
