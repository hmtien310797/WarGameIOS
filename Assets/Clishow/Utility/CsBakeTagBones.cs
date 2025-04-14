using UnityEngine;
using System.Collections;

namespace Clishow
{
    public class CsBakeTagBones : MonoBehaviour
    {
        public string Anim_Tag = "";

        public float Anim_Frame = 0;

        public Transform[] TagBones = null;

        public Transform[] MixingTagBones = null;

        public Transform[] DeadMixingTagBones = null;

        private Transform mSelfTrf = null;

        public Transform _SelfTrf
        {
            get
            {
                if (mSelfTrf == null)
                {
                    mSelfTrf = this.transform;
                }
                return mSelfTrf;
            }
        }
        private Transform tmpTrf;

        private int mTagBoneLength = -1;

        private Quaternion[] mMixingTagBoneQuas;

        public Quaternion[] MixingTagBoneQua
        {
            get
            {
                return initMix();
            }
        }


        Quaternion[] initMix()
        {
                if(MixingTagBones == null || MixingTagBones.Length == 0)
                    return null;
                if(mMixingTagBoneQuas != null)
                    return mMixingTagBoneQuas;
                mMixingTagBoneQuas = new Quaternion[MixingTagBones.Length];
                for(int i =0;i<MixingTagBones.Length;i++)
                {
                    mMixingTagBoneQuas[i] = MixingTagBones[i].localRotation;
                }
                return mMixingTagBoneQuas;
        }

        void Awake()
        {
            initMix();
        }

        public int TagBoneLength
        {
            get
            {
                if (mTagBoneLength < 0)
                {
                    mTagBoneLength = TagBones.Length;
                }
                return mTagBoneLength;
            }
        }

        public Vector3 GetBonesPos(int index)
        {
            if (TagBones == null || index >= TagBoneLength || index < 0)
            {
                return Vector3.zero;
            }
            tmpTrf = TagBones[index];
            if (tmpTrf == null)
                return Vector3.zero;
#if BakeMesh
            return _SelfTrf.InverseTransformPoint(tmpTrf.position);
#else
            return tmpTrf.position;
#endif
        }

        public Quaternion GetBonesRotate(int index)
        {
            if (TagBones == null || index >= TagBoneLength || index < 0)
            {
                return Quaternion.identity;
            }
            tmpTrf = TagBones[index];
            if (tmpTrf == null)
                return Quaternion.identity;
#if BakeMesh
            return tmpTrf.rotation * Quaternion.Inverse(_SelfTrf.localRotation);
#else
            return tmpTrf.rotation;
#endif
        }
    }
}
