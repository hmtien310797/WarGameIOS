using UnityEngine;
using System.Collections;

namespace Clishow
{
	[RequireComponent(typeof(MeshRenderer))]
	[RequireComponent(typeof(MeshFilter))]
	public class CsBakeObject : MonoBehaviour
	{
        public class BakeAnimInfo
		{
            private CsBakeTagBones TagBones = null;
            public float Speed = 1;
			private Animation mAnim = null;
			private AnimationState mAnimState = null;
			private float mAnimTime = 0;
			private bool mValid = false;
			private BakeAnimInfo mCurPlayingInfo = null;
			private float mFadeTime = 0.5f;
			private float mFadeStartTime = 0;

            private float mNormalizeTime = 0;
            private CsBakeObject.NoticeAnimProgressHandle mHandle = null;
            private CsBakeObject.UnitSfxPlayHandle mSfxHandle = null;
            private float mDeadEndLength = -1;
            public bool isValid
			{
				get
				{
					return mValid;
				}
			}

			public string AnimName
			{
				get
				{ 
					if(mAnimState != null)
						return mAnimState.name;
					return string.Empty;
				}
			}

			public AnimationState AnimState
			{
				get
				{
					if(mAnimState != null)
						return mAnimState;
					return null;
				}
			}

            public float NormalizeTime
            {
                get
                {
                    return mNormalizeTime;
                }
            }

            public void setAnimProgressHandle1(CsBakeObject.NoticeAnimProgressHandle handle)
            {
                mHandle += handle;
            }
            public void setUnitSfxHandle(CsBakeObject.UnitSfxPlayHandle sfxHanle)
            {
                mSfxHandle = sfxHanle;
            }
            public void Destroy()
            {
                if (mHandle != null)
                {
                    mHandle(-1);
                }
                mHandle = null;
                if (mSfxHandle != null)
                {
                    mSfxHandle(-1);
                }
                mSfxHandle = null;
            }

            public BakeAnimInfo (string anim_name,Animation anim,CsBakeTagBones bones,BakeAnimInfo playing_info,bool enable_fade = true,bool blend =false,float weight = 1,float fadeTime = 0.3f, bool Queued = false)
			{
				mAnim = anim;
                TagBones = bones;
				mCurPlayingInfo = playing_info;
				mAnimState = mAnim[anim_name];

                if (mAnimState != null)
					mValid = true;
                
                mAnimTime = 0;
				mFadeStartTime = 0;
                mNormalizeTime = 0;
                if (!enable_fade)
                {
                    mFadeTime = -1;
                    mCurPlayingInfo = null;
                }
                else
                {
                    mFadeTime = fadeTime;
                }
#if BakeMesh == false
                if (!mValid)
                    return;
                if (blend)
                {         
                    mAnim.Blend(anim_name, weight, fadeTime);
                    return;
                }
                if (enable_fade)
                {
                    mAnim.CrossFade(anim_name, fadeTime);
                }
                else
                {
                    if (Queued) {
                        mAnim.PlayQueued(anim_name);
                    }
                    else
                    {
                        mAnim.Play(anim_name, PlayMode.StopAll);
                    }
                }
#endif
            }

            public void _UpdateFade(float time,float fadeTime,float speed)
			{
#if BakeMesh
				mAnimState.enabled = true;
				mAnimState.blendMode = AnimationBlendMode.Blend;
				mAnimState.weight = Mathf.Lerp(1,0,Mathf.Max(1-(mFadeStartTime)/fadeTime,0));
				mAnimState.time = mAnimTime;
                mAnimTime += time*speed;
				mFadeStartTime += time * speed;
                switch (mAnimState.wrapMode)
				{
				default:
					if (mAnimTime >= mAnimState.length)
					{
						mAnimTime = mAnimState.length;
					}
					break;
				}
#endif
			}

            public void BlendTimeRest()
            {
#if BakeMesh
                if (!mValid)
                    return;
                mAnimTime = 0;
                mNormalizeTime = 0;
#else
                mAnimState.time = 0;
#endif
            }

            public void _UpdateBlendStart(float weight)
            {
#if BakeMesh
                if (!mValid)
                    return;
                mAnimState.enabled = true;
                mAnimState.layer = 1;
                mAnimState.blendMode = AnimationBlendMode.Additive;
                mAnimState.weight = weight*(1- mNormalizeTime);
                mAnimState.time = mAnimTime;
#else
                if (!mValid)
                    return;
                mAnimState.blendMode = AnimationBlendMode.Additive;
                mAnimState.weight = weight * (1 - mNormalizeTime);
#endif
            }

            public void _UpdateBlendEnd(float time)
            {
#if BakeMesh
                if (!mValid)
                    return;
                mAnimState.enabled = false;
                mAnimTime += time;
                mNormalizeTime = mAnimTime / mAnimState.length;

                switch (mAnimState.wrapMode)
                {
                    case WrapMode.Loop:
                        if (mAnimTime >= mAnimState.length)
                            mAnimTime = 0;
                        break;
                    default:
                        if (mAnimTime >= mAnimState.length)
                        {
                            mAnimTime = mAnimState.length;
                            mValid = false;
                        }
                        break;
                }
#endif
            }

            public void _UpdateEndFrame(bool isDead = false)
            {
#if BakeMesh
                if (isValid || mAnimState == null)
                    return;
                mAnimState.enabled = true;
                mAnimState.time = mAnimState.length;
                mAnim.Sample();
                mAnimState.enabled = false;
#endif
            }

			public void _Update(float time, bool isDead = false,bool isVisble = true)
			{
				if (!mValid)
					return;
#if BakeMesh
                if (isVisble)
                {


                    if (mCurPlayingInfo != null && mFadeStartTime <= mFadeTime && mCurPlayingInfo.AnimState != null)
                    {
                        mAnimState.enabled = true;
                        mAnimState.blendMode = AnimationBlendMode.Blend;
                        mAnimState.weight = Mathf.Lerp(0, 1, (mFadeStartTime) / mFadeTime);
                        mAnimState.layer =  mCurPlayingInfo.AnimState.layer + 1;
                        mCurPlayingInfo._UpdateFade(time, mFadeTime, 1);
                        mFadeStartTime += time;
                    }
                    else
                    {
                        mAnimState.enabled = true;
                        mAnimState.layer = 1;
                        mAnimState.weight = 1;
                    }
                    mAnimState.time = mAnimTime;
                    {
                        mAnim.Sample();
                    }
                    if (mCurPlayingInfo != null)
                    {
                        mCurPlayingInfo.AnimState.enabled = false;
                    }
                    mAnimState.enabled = false;
                }


                mAnimTime += time*Speed;
                mNormalizeTime = mAnimTime / mAnimState.length;
                if (mHandle != null)
                {
                    if (mHandle(mNormalizeTime))
                    {
                        mHandle = null;
                    }
                }
                if (mSfxHandle != null)
                {
                    if (mSfxHandle(mNormalizeTime))
                    {
                        mSfxHandle = null;
                    }
                }
                switch (mAnimState.wrapMode)
				{
				case WrapMode.Loop:
					if (mAnimTime >= mAnimState.length)
						mAnimTime = 0;
					break;
				default:
					if (mAnimTime >= mAnimState.length)
					{
                        mAnimTime = mAnimState.length;
						mValid = false;
                        mHandle = null;
                        mSfxHandle = null;
                    }
					break;
				}
#else

                if (mAnimState.enabled)
                {
                    mAnimState.speed = Speed;
                    mNormalizeTime = mAnimState.normalizedTime;
                    if (mHandle != null)
                    {
                        if (mHandle(mNormalizeTime))
                        {
                            mHandle = null;
                        }
                    }
                    if (mSfxHandle != null)
                    {
                        if (mSfxHandle(mNormalizeTime))
                        {
                            mSfxHandle = null;
                        }
                    }
                }
                else
                {
                    if (isDead)
                    {
                        mAnim.Stop();
                    }
                    mValid = false;
                    mAnimState.layer = 1;
                }
#endif
            }
        }

		public bool AlwaysUpdateAnim = true;

        public delegate void SyncBonesHandle(CsBakeTagBones bones);

        public delegate bool NoticeAnimProgressHandle(float progress);
        public delegate bool UnitSfxPlayHandle(float progress);

        private Animation mParentAnim = null;

        private SkinnedMeshRenderer mParentMesh;

		private MeshRenderer mRenderer = null;

        public MeshRenderer Renderer
        {
            get
            {
                return mRenderer;
            }
        }

		private MeshFilter mFiter = null;

		private Mesh mBakeMesh = null;

        public Mesh BakeMesh
        {
            get
            {
                return mBakeMesh;
            }
        }

		private BakeAnimInfo mCurAnimInfo = null;

        private BakeAnimInfo mBlendAnimInfo = null;

        private float mBlendWeight = 0;

		private CsBakeTagBones mTagBones = null;

        public CsBakeTagBones TagBones
        {
            get
            {
                return mTagBones;
            }
        }

        private SyncBonesHandle mHandle = null;

        private SyncBonesHandle mMixingHandle = null;

        private SyncBonesHandle mDeadMixingHandle = null;

        public bool IsDead = false;

        public void InitObject(SkinnedMeshRenderer renderer, Animation anim, SyncBonesHandle handle,SyncBonesHandle mixing_handle, SyncBonesHandle dead_mixing_handle)
		{
            IsDead = false;
            mParentAnim = anim;
			mParentMesh = renderer;
            mHandle = handle;
            mMixingHandle = mixing_handle;
            mDeadMixingHandle = dead_mixing_handle;
            if (mParentAnim != null)
            {
                mTagBones = mParentAnim.GetComponent<CsBakeTagBones>();
            }
#if BakeMesh
            if (mRenderer == null)
			{
				mRenderer = this.gameObject.GetComponent<MeshRenderer> ();
			}

			if (mFiter == null) {
				mFiter = this.gameObject.GetComponent<MeshFilter> ();
			}

			if (mBakeMesh == null) {
				mBakeMesh = new Mesh ();
			}

			if (mRenderer != null &&mFiter != null )
            {
				mRenderer.sharedMaterials = mParentMesh.sharedMaterials;
			}
            CsBakeBatchesMgr.Instance.AddUpdateBakeObj(this);
#else
            if (mRenderer == null)
            {
                mRenderer = this.gameObject.GetComponent<MeshRenderer>();
                //mRenderer.enabled = false;
            }

            if (mFiter == null)
            {
                mFiter = this.gameObject.GetComponent<MeshFilter>();
            }
#endif
        }

		public BakeAnimInfo Play(string anim_name,bool enable_fade=true, NoticeAnimProgressHandle handle = null)
		{
            if (IsDead)
                return null;
            if (mCurAnimInfo != null && mCurAnimInfo.isValid && mCurAnimInfo.AnimName == anim_name && enable_fade)
            {
                return mCurAnimInfo;
            }
            BakeAnimInfo info  = new BakeAnimInfo (anim_name, mParentAnim,TagBones,mCurAnimInfo, true,false,1,enable_fade?0.25f:0.1f);

            if(mCurAnimInfo != null)
                mCurAnimInfo.Destroy();
			mCurAnimInfo = info;
            mCurAnimInfo.setAnimProgressHandle1(handle);
            return mCurAnimInfo;
        }

        public void Blend(string anim_name, float weight)
        {
            if (IsDead)
                return;
            if (weight == 0)
            {

                return;
            }
            if (mBlendAnimInfo != null && mBlendAnimInfo.isValid && mBlendAnimInfo.AnimName == anim_name)
            {
                mBlendAnimInfo.BlendTimeRest();
                return;
            }
            BakeAnimInfo info = new BakeAnimInfo(anim_name, mParentAnim, TagBones, null, false,true, weight);
            mBlendWeight = weight;
            if (mBlendAnimInfo != null)
                mBlendAnimInfo.Destroy();
            mBlendAnimInfo = info;
        }

        public BakeAnimInfo ForcePlay(string anim_name, NoticeAnimProgressHandle handle = null, bool Queued = false)
        {
            if (IsDead)
                return null;
            if (mCurAnimInfo != null && mCurAnimInfo.isValid && mCurAnimInfo.AnimName == anim_name)
            {
                return mCurAnimInfo;
            }
            BakeAnimInfo info = new BakeAnimInfo(anim_name, mParentAnim, TagBones, mCurAnimInfo, false, Queued);

            if (mCurAnimInfo != null)
                mCurAnimInfo.Destroy();
            mCurAnimInfo = info;
            mCurAnimInfo.setAnimProgressHandle1(handle);
            return mCurAnimInfo;
        }

        public string CurAnimName
        {
            get
            {
                if (mCurAnimInfo == null)
                    return string.Empty;
                return mCurAnimInfo.AnimName;
            }
        }

        public float CurAnimNormalizeTime
        {
            get
            {
                if (mCurAnimInfo == null)
                    return -1;
                return mCurAnimInfo.NormalizeTime;
            }
        }


        public BakeAnimInfo CurAnimInfo
        {
            get
            {
                return mCurAnimInfo;
            }
        }

        private bool mIsVisble = false;
        private bool mBecameVisble = true;
        public bool BecameVisbie
        {
            get
            {
                return mBecameVisble;
            }
        }

        private bool mNeedRefrushMesh = false;

        public void ForceUpdateAnim()
        {
            mBecameVisble = true;
        }

		void OnBecameVisible()
		{
            mBecameVisble = true;
            mIsVisble = true;
            mNeedRefrushMesh = true;

        }

		void OnBecameInvisible()
		{
            mBecameVisble = false;
    //        if (!AlwaysUpdateAnim)
				//mIsVisble = false;
		}

        private int mCurFrameCount = -1;
		public void UpdateBakeObj(bool sample = false)
		{
			//if(!mIsVisble)
			//	return;
#if BakeMesh
            if (mCurAnimInfo == null || !mCurAnimInfo.isValid) {
                if (mNeedRefrushMesh)
                {
                    mCurAnimInfo._UpdateEndFrame(IsDead);
                    mParentMesh.BakeMesh(mBakeMesh);
                    mFiter.mesh = mBakeMesh;
                    mNeedRefrushMesh = false;
                }
                return;
			}
            {
                sample = mBecameVisble&& sample;
            }

            if (mBlendAnimInfo != null && mBlendAnimInfo.isValid)
            {
                mBlendAnimInfo._UpdateBlendStart(mBlendWeight);
            }

            mCurAnimInfo._Update(Time.deltaTime, IsDead, sample);

            if (mBlendAnimInfo != null && mBlendAnimInfo.isValid)
            {
                mBlendAnimInfo._UpdateBlendEnd(Time.deltaTime);
            }
            if (!sample)
            {
                return;
            }
            if (mTagBones != null && mTagBones.MixingTagBones != null && mTagBones.MixingTagBones.Length != 0)
            {
                if (mMixingHandle != null)
                {
                    mMixingHandle(mTagBones);
                }
            }
            if (mTagBones != null && mHandle != null)
            {
                mHandle(mTagBones);
            }
            mParentMesh.BakeMesh(mBakeMesh);
            mFiter.mesh = mBakeMesh;
#else
            if (mCurAnimInfo == null || !mCurAnimInfo.isValid)
            {
                return;
            }


            if (mBlendAnimInfo != null && mBlendAnimInfo.isValid)
            {
                mBlendAnimInfo._UpdateBlendStart(mBlendWeight);
            }

            mCurAnimInfo._Update(Time.deltaTime, IsDead, sample);
            if (mTagBones != null && mHandle != null)
            {
                mHandle(mTagBones);
            }
#endif
        }

        void UpdateShadow()
        {
            SceneEntity entity = SceneManager.instance.Entity;
            if(entity == null)
                entity = CsSLGPVPMgr.instance.Entity;
            if(mParentMesh == null || entity == null || entity.ProjShadow == null)
                return;
            Bounds bounds = mParentMesh.bounds;
            Vector3 view_max = Camera.main.WorldToViewportPoint(bounds.max);
            Vector3 view_min = Camera.main.WorldToViewportPoint(bounds.min);
            if(Camera.main.rect.Contains(view_max) || Camera.main.rect.Contains(view_min))
            {
                entity.ProjShadow.Adjust(this.transform.position);
            }
        }

#if BakeMesh == false
        void Update()
        {
            //if (!mIsVisble)
            //    return;
            UpdateBakeObj();
            UpdateShadow();
        }

        void LateUpdate()
        {
            if (IsDead)
                return;
            //if (!mIsVisble)
            //    return;
            if (mTagBones != null && mTagBones.MixingTagBones != null && mTagBones.MixingTagBones.Length != 0)
            {
                if (mMixingHandle != null)
                {
                    mMixingHandle(mTagBones);
                }
            }
        }
#endif

        public void ClearBlendAnimInifo()
        {
            if (mBlendAnimInfo != null)
            {
                mBlendAnimInfo.Destroy();
            }
            mBlendAnimInfo = null;
        }


        public void Reset()
        {
            IsDead = false;
            if (mCurAnimInfo != null)
            {
                mCurAnimInfo.Destroy();
            }
            mCurAnimInfo = null;
            ClearBlendAnimInifo();
        }
        void OnDestroy()
        {
            //if(CsBakeBatchesMgr.isValid)
            //    CsBakeBatchesMgr.Instance.RemoveUpdateBakeObj(this);
            mBakeMesh = null;
            if(mFiter != null)
                mFiter.mesh = null;
        }
    }
}
