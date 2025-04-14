using UnityEngine;
using System.Collections;

namespace Clishow
{
    public class CsMissileController : MonoBehaviour
    {
        public bool BombEffect = false;
        [System.NonSerialized]
        public float SubjoinTime = 0;
        public float FlyHight;
        public float FlyDis;
        public float FlyTime;
        public float ExtraSpeed = 1;
        public string BoomName;
        public string MissileName;


        private float mSubjoinTime = 0;
        private GameObject mBoom = null;
        private GameObject mMissile = null;
        private float mFlyTime = 0;
        private bool mUpdateMissileMoving = false;
        private Vector3 mStart = Vector3.zero;
        private Vector3 mOldPos = Vector3.zero;
        public void Init(Vector3 dir)
        {
            mBoom = ResourceLibrary.instance.GetEffectInstanceFromPool(BoomName);
            mBoom.SetActive(false);
            mBoom.transform.parent = this.transform;
            mBoom.transform.localPosition = Vector3.zero;
            mBoom.transform.localRotation = Quaternion.identity;
            mMissile = ResourceLibrary.instance.GetEffectInstanceFromPool(MissileName);
            mMissile.SetActive(false);
            mMissile.transform.parent = this.transform;
            if(BombEffect)
            {
                mMissile.transform.localPosition =  Vector3.up * FlyHight* ExtraSpeed+ Vector3.up*2;
                mMissile.transform.forward = Vector3.down;
            }
            else
            {
                mStart = dir  * FlyDis * ExtraSpeed ;
                mMissile.transform.localPosition = mStart + Vector3.up * FlyHight;
            }

            mMissile.SetActive(true);
            mFlyTime = 0;
            mSubjoinTime = 0;
            mUpdateMissileMoving = true;
        }

        public void ReclaimReset()
        {
            if (mBoom != null)
            {
                Clishow.CsObjPoolMgr.Instance.Destroy(mBoom.gameObject);
            }
            mBoom = null;
            if (mMissile != null)
            {
                CsSkillIns ins = mMissile.GetComponent<CsSkillIns>();
                if (ins != null)
                {
                    ins.ReclaimReset();
                }
                Clishow.CsObjPoolMgr.Instance.Destroy(mMissile.gameObject);
            }
            mMissile = null;
            mFlyTime = 0;
            mSubjoinTime = 0;
            mUpdateMissileMoving = false;
            mStart = Vector3.zero;
            mOldPos = Vector3.zero;
    }

        public void UpdateMissile(float _dt)
        {
            if (!mUpdateMissileMoving)
                return;

            if (mSubjoinTime < SubjoinTime)
            {
                mSubjoinTime += _dt;
                return;
            }

            mFlyTime   += _dt;
            if (mFlyTime >= FlyTime)
            {
                mUpdateMissileMoving = false;
                //mMissile.SetActive(false);
                CsSkillIns ins = mMissile.GetComponent<CsSkillIns>();

                if (ins != null)
                {
                    if (ins.DisplayBoomResidual)
                        CsSkillMgr.Instance.BoomResidualEmitter.ShowBoom(ins.transform.position, ins.BoomResidualSize);
                    ins.SubjoinTime = SubjoinTime;
                    ins.Destroy();
                }
                    

                mBoom.SetActive(true);
                return;
            }
            float ff = mFlyTime / FlyTime;
            if(BombEffect)
            {
                Vector3 pos = mMissile.transform.localPosition;
                pos.y = FlyHight*(1-ff)* ExtraSpeed;
                mMissile.transform.localPosition = pos;
            }
            else
            {
                mOldPos = mMissile.transform.localPosition;
            
                float f = (ff) *0.5f+0.5f;
                float yy = (float)UnityEngine.Mathf.Sin(Mathf.PI * (1 - f));
                Vector3 pos = Vector3.Lerp(mStart, Vector3.zero, ff);
                pos.y = FlyHight* ExtraSpeed * yy;
                mMissile.transform.localPosition = pos;
                Vector3 forward = pos - mOldPos;
                mMissile.transform.forward = forward;
            }

        }
    }
}


