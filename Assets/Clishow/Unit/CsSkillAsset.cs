using UnityEngine;
using System.Collections;


namespace Clishow
{
    public class CsSkillAsset : CsParticleBase
    {
        public string TargetTag;
        public LayerMask mMask;

        public Object[] ImmHideWhenDestroys = null;

        public GameObject ExtraLinkPerfab = null;

        public CsParticleController Particle = null;

        private bool mNeedInit = true;

        //private float mCurShowTime = -1;

        RaycastHit hitInfo;

        private BoxCollider mBox = null;

        //private float GetCurShowTime
        //{
        //    get
        //    {
        //        return mCurShowTime;
        //    }
        //}

        public void Show()
        {
            //mCurShowTime = Time.realtimeSinceStartup;
            this.gameObject.SetActive(true);
            CheckBox();
        }

        void CheckBox()
        {
            if (string.IsNullOrEmpty(TargetTag))
            {
                return;
            }
            BoxCollider box = this.gameObject.GetComponent<BoxCollider>();
            if (box != null)
                box.enabled = false;
            if (Physics.Raycast(this.transform.position + Vector3.up * 10, Vector3.down, out hitInfo, 15, mMask.value))
            {
                if (hitInfo.collider.CompareTag(TargetTag))
                    this.gameObject.SetActive(false);
            }
            if (this.gameObject.activeSelf)
            {
                if (box != null)
                    box.enabled = true;
            }
        }

        public void Init()
        {
            if (!mNeedInit)
                return;
            mNeedInit = false;
            if (ExtraLinkPerfab != null)
            {
                GameObject obj = GameObject.Instantiate(ExtraLinkPerfab);
                obj.transform.parent = this.transform;
                obj.transform.localPosition = Vector3.zero;
                obj.transform.localRotation = Quaternion.identity;
                obj.transform.localScale = Vector3.one;

                Particle = obj.GetComponentInChildren<CsParticleController>();
                if (Particle != null)
                {
                    Particle.Asset = this;
                }
            }
        }

        private float mDelayActiveTime = -1;
        private bool mDelayActive = false;
        private void UpdateDelayActive()
        {
            if (!mDelayActive)
                return;
            if (mDelayActiveTime > 0)
            {
                mDelayActiveTime -= Time.deltaTime;

            }
            else
            {
                mDelayActiveTime = -1;
                mDelayActive = false;
                Particle.gameObject.SetActive(true);
                Particle.Active();
            }
        }

        public void DelayActive(float time)
        {
            mDelayActiveTime = time;
            mDelayActive = true;
            Particle.gameObject.SetActive(false);
            if(mDelayActiveTime <= 0)
            {
                mDelayActiveTime = -1;
                mDelayActive = false;
                Particle.gameObject.SetActive(true);
                Particle.Active();
            }
        }

        void Update()
        {
            UpdateDelayActive();
        }

        //void OnTriggerEnter(Collider other)
        //{

        //    if(other.CompareTag(this.gameObject.tag))
        //    {
        //        CsSkillAsset asset = other.gameObject.GetComponent<CsSkillAsset>();
        //        if(asset != null)
        //        {
        //            if(asset.GetCurShowTime < GetCurShowTime)
        //            {

        //            }
        //        }

        //    }

        //}
    }
}

