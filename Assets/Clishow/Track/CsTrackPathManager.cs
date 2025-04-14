using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Clishow
{
    [System.Serializable]
    public class CsTrackerInfo
    {
        [System.Serializable]
        public class PathInfo
        {
            public CsTrackPath Path = null;
        }
        [System.Serializable]
        public class TrackAssetInfo
        {
            public bool EnableAvoid = true;
            public bool IsTeam = false;
            public float TeamSpace = 1;
            public string AssetName;
            public float Speed;
            public Vector3 ColliderSize;
            public float Size = 1;
            public float WaitTime = 1;
            public int Priority = 0;
            public LayerMask CheckLayer;
            public string LayerName;
            public string[] Anims;
            public bool EnableFadeInOut;
            public float Start2FadeInPercent;
            public float FadeOutPercent2End;

            public Vector3 colliderSize
            {
                get
                {
                    return ColliderSize*Size;
                }
            }
        }

        [System.Serializable]
        public class TrackActionInfo
        {
            public AnimationCurve Curve = new AnimationCurve();
            public bool Loop = false;
            public PathInfo Sequence;
            public Vector3[] PointPaths = null;
            public float PathLength = 0;
            public Vector3[] PointReversedPaths = null;
            public float ReversedPathLength = 0;
            public void GeneratePath()
            {
                List<Vector3> vs = new List<Vector3>();
                vs.AddRange(Sequence.Path.nodes);
                PointPaths = CsTrackPathManager.PathControlPointGenerator(vs.ToArray());
                PathLength = iTween.PathLength(PointPaths);
                vs.Reverse();
                PointReversedPaths = CsTrackPathManager.PathControlPointGenerator(vs.ToArray());
                ReversedPathLength = iTween.PathLength(PointReversedPaths);
            }
        }
        public float MinStartTime;
        public float MaxStartTime;
        public string TrackType;
        public TrackAssetInfo[] AssetInfos;
        public TrackActionInfo[] ActionInfos;
    }

    public class CsTrackAvoidController
    {
        public enum AvoidState
        {
            AS_NIL,
            AS_FIND_POS,
            AS_ENTER,
            AS_EXIT,
        }
        private bool mIsAvoid = false;
        private CsTracker mTracker = null;
        private RaycastHit mHitInfo;
        private float mWaitTime = 0;
        private AvoidState mState;
        private Vector3 mAvoidPos;
        private int mAvoidStep = 0;
        private float mStopWaitTime = 0;
        private uint mWaitCount = 0;
        private Collider mTarget = null;

        public CsTrackAvoidController(CsTracker tracker)
        {
            mTracker = tracker;
        }

        public bool CheckStop()
        {
            //if (Physics.BoxCast(mTracker.Trf.position + mTracker.Trf.forward * mTracker.AssetInfo.ColliderSize.z * 0.5f,
            //    new Vector3(mTracker.AssetInfo.ColliderSize.x * 0.5f, mTracker.AssetInfo.ColliderSize.y * 0.5f, 0.5f),
            //    mTracker.Trf.forward, out mHitInfo, mTracker.Trf.localRotation, 1, mTracker.AssetInfo.CheckLayer.value))
            if (Physics.BoxCast(mTracker.Trf.position,//+ mTracker.Trf.forward * mTracker.AssetInfo.ColliderSize.z*0.5f
                new Vector3(mTracker.AssetInfo.colliderSize.x, mTracker.AssetInfo.colliderSize.y, 0.5f),
                mTracker.Trf.forward, out mHitInfo, mTracker.Trf.localRotation, mTracker.AssetInfo.colliderSize.z * 2, mTracker.AssetInfo.CheckLayer.value))
            {
                if (!mIsAvoid && (Vector3.Dot(mTracker.Trf.forward, mHitInfo.collider.transform.forward) < 0.5f))
                {
                    mTarget = mHitInfo.collider;
                    if(!mTarget.name.Contains("&"))
                    {
                            mStopWaitTime = 0.5f;
                            mState = AvoidState.AS_FIND_POS;
                            mIsAvoid = true;
                        return true;
                    }
                    //if (mTarget == mHitInfo.collider)
                    //    return true;
                    
                    string[] t = mTarget.name.Split('&');
                    int tl = t.Length;
                    uint score = 0;
                    string[] tt = mTracker.Obj.name.Split('&');
                    int sl = tt.Length;
                    uint s = 0;
                    int p = int.Parse(t[0]);
                    uint id = uint.Parse(t[1]);

                    if (tl != 3)
                    {
                        if ((sl != 3) && ((mTracker.AssetInfo.Priority < p) || (mTracker.AssetInfo.Priority == p && mTracker.UID < id)))
                        {
                            s = ++CsTracker.sScore;
                            mStopWaitTime = 0.5f;
                            mTarget.name = p.ToString() + "&" + id.ToString() + "&" + s.ToString();
                            mState = AvoidState.AS_FIND_POS;
                            mIsAvoid = true;
                        }
                    }
                    else
                    {
                        s = uint.Parse(t[2]);

                        if (sl == 3)
                        {
                            score = uint.Parse(tt[2]);
                        }
                        if (s == score)
                        {
                            if ((mTracker.AssetInfo.Priority < p) || (mTracker.AssetInfo.Priority == p && mTracker.UID < id))
                            {
                                s = ++CsTracker.sScore;
                                mStopWaitTime = 0.5f;
                                mTarget.name = p.ToString() + "&" + id.ToString() + "&" + s.ToString();
                                mState = AvoidState.AS_FIND_POS;
                                mIsAvoid = true;
                            }
                        }
                        else if (s > score)
                        {
                            s = ++CsTracker.sScore;
                            mStopWaitTime = 1;
                            mTarget.name = p.ToString() + "&" + id.ToString() + "&" + s.ToString();
                            mState = AvoidState.AS_FIND_POS;
                            mIsAvoid = true;
                        }
                    }
                }
                return true;
            }
            else
            {
                mTarget = null;
                return false;
            }
        }

        private void UpdateFindPos()
        {
            if (mState != AvoidState.AS_FIND_POS)
                return;
            //(UnityEngine.Random.Range(0, 100) % 2 == 0 ? 1 : -1) *
            mAvoidPos = mTracker.Trf.right * mTracker.AssetInfo.colliderSize.z * 0.5f + mTracker.Trf.position;
            mAvoidPos = mTracker.Trf.InverseTransformPoint(mAvoidPos);
            mState = AvoidState.AS_ENTER;
            mAvoidStep = 0;
            mRunDis = 0;
            mTargetDis = mTracker.AssetInfo.colliderSize.z * 0.5f;
            mRunDir = Vector3.back;
            mRunDir = mRunDir.normalized;
            mSourcePos = Vector3.zero;
            mSourcelist.Clear();
            mDirlist.Clear();
            if (mTracker.mTeam != null && mTracker.mTeam.Count > 0)
            {
                for (int i = 0, imax = mTracker.mTeam.Count; i < imax; i++)
                {
                    mSourcelist.Add(mTracker.mTeam[i].Obj.transform.localPosition);
                    mDirlist.Add(mTracker.mTeam[i].Obj.transform.right);
                }
            }
        }

        private float mRunDis = 0;
        private float mTargetDis = 0;
        private Vector3 mRunDir;
        private Vector3 mSourcePos;
        private List<Vector3> mSourcelist = new List<Vector3>();
        private List<Vector3> mDirlist = new List<Vector3>();

        private void UpdateTeamEnter()
        {
            if (mState != AvoidState.AS_ENTER)
                return;
            if (mTracker.ModelObj != null)
                return;
            float d = 0;
            switch (mAvoidStep)
            {
                case 0:
                    mTracker.PlayAnim(1);
                    d = Time.deltaTime * 1.5f + mRunDis;
                    for (int i = 0, imax = mTracker.mTeam.Count; i < imax; i++)
                    {
                        if (d >= mTargetDis)
                        {
                            mTracker.mTeam[i].Obj.transform.localPosition = mDirlist[i] * mTargetDis + mSourcelist[i];
                            mTracker.mTeam[i].Obj.transform.forward = mDirlist[i];
                            mAvoidStep = 3;
                            mRunDis = 0;
                            mTracker.Box.enabled = false;
                        }
                        else
                        {
                            mRunDis = d;
                            mTracker.mTeam[i].Obj.transform.localPosition = mDirlist[i] * mRunDis + mSourcelist[i];
                            mTracker.mTeam[i].Obj.transform.forward = mDirlist[i];
                        }
                    }
                    break;
                case 3:
                    {
                        mTracker.PlayAnim(0);
                        if (mWaitTime >= mTracker.AssetInfo.WaitTime)
                        {
                            if (!Physics.BoxCast(mTracker.Trf.position + mTracker.Trf.forward * -2 * mTracker.AssetInfo.colliderSize.z,
                                new Vector3(mTracker.AssetInfo.colliderSize.x * 2, mTracker.AssetInfo.colliderSize.y * 2, 0.5f),
                                mTracker.Trf.forward, out mHitInfo, mTracker.Trf.localRotation, mTracker.AssetInfo.colliderSize.z * 4, mTracker.AssetInfo.CheckLayer.value))
                            {
                                mState = AvoidState.AS_EXIT;
                            }
                            mWaitTime = 0;
                        }
                        else
                        {
                            mWaitTime += Time.deltaTime;
                        }
                    }
                    break;
            }
        }

        private void UpdateTeamExit()
        {
            if (mState != AvoidState.AS_EXIT)
                return;
            if (mTracker.ModelObj != null)
                return;
            float d = 0;
            switch (mAvoidStep)
            {
                case 3:
                    mTracker.Box.enabled = true;
                    mAvoidStep = 0;
                    mRunDis = 0;
                    mTargetDis = mTracker.AssetInfo.colliderSize.z * 0.5f;
                    break;
                case 0:
                    mTracker.PlayAnim(1);
                    d = Time.deltaTime * 1.5f + mRunDis;
                    for (int i = 0, imax = mTracker.mTeam.Count; i < imax; i++)
                    {
                        if (d >= mTargetDis)
                        {
                            mTracker.mTeam[i].Obj.transform.localPosition = mSourcelist[i];
                            mTracker.mTeam[i].Obj.transform.localRotation = Quaternion.identity;
                            mAvoidStep = -1;
                            mRunDis = 0;
                            mState = AvoidState.AS_NIL;
                            mIsAvoid = false;
                        }
                        else
                        {
                            mRunDis = d;
                            mTracker.mTeam[i].Obj.transform.localPosition = -1 * mDirlist[i] * mRunDis + mSourcelist[i] + mDirlist[i] * mTargetDis;
                            mTracker.mTeam[i].Obj.transform.forward = -1 * mDirlist[i];
                        }
                    }
                    break;
            }
        }


        private void UpdateEnter()
        {
            if (mState != AvoidState.AS_ENTER)
                return;
            if (mTracker.ModelObj == null)
                return;
            float d = 0;
            switch (mAvoidStep)
            {
                case 0:
                    //if (mStopWaitTime > 0)
                    //{
                    //    mStopWaitTime -= Time.deltaTime;
                    //}
                    //else
                    {
                        d = Time.deltaTime * 1.5f + mRunDis;
                        if (d >= mTargetDis)
                        {
                            mTracker.ModelObj.transform.localPosition = mRunDir * mTargetDis + mSourcePos;
                            mAvoidStep = 1;
                            mRunDis = 0;
                            mSourcePos = mRunDir * mTargetDis;
                            mRunDir = mAvoidPos - mSourcePos;
                            mTargetDis = mRunDir.magnitude;
                            mRunDir = mRunDir.normalized;
                        }
                        else
                        {
                            mRunDis = d;
                            mTracker.ModelObj.transform.localPosition = mRunDir * mRunDis + mSourcePos;
                        }
                    }

                    break;
                case 1:
                    Vector3 dir = mTracker.ModelObj.transform.localRotation * Vector3.forward;
                    if (Vector3.Dot(mRunDir, dir) >= 0.995f)
                    {
                        mTracker.ModelObj.transform.localRotation = Quaternion.LookRotation(mRunDir, Vector3.up);
                        mAvoidStep = 2;
                    }
                    else
                    {
                        mTracker.ModelObj.transform.localRotation = Quaternion.RotateTowards(mTracker.ModelObj.transform.localRotation, Quaternion.LookRotation(mRunDir, Vector3.up), 1f);
                    }
                    break;
                case 2:
                    d = Time.deltaTime * 1.5f + mRunDis;
                    if (d >= mTargetDis)
                    {
                        mTracker.ModelObj.transform.localPosition = mRunDir * mTargetDis + mSourcePos;
                        mAvoidStep = 3;
                        mTracker.Box.enabled = false;
                    }
                    else
                    {
                        mRunDis = d;
                        mTracker.ModelObj.transform.localPosition = mRunDir * mRunDis + mSourcePos;
                    }
                    break;
                case 3:
                    //if (mStopWaitTime > 0)
                    //{
                    //    mStopWaitTime -= Time.deltaTime;
                    //}
                    //else
                    {
                        if (mWaitTime >= mTracker.AssetInfo.WaitTime)
                        {
                            if (!Physics.BoxCast(mTracker.Trf.position + mTracker.Trf.forward * -2 * mTracker.AssetInfo.colliderSize.z,
                                new Vector3(mTracker.AssetInfo.colliderSize.x * 2, mTracker.AssetInfo.colliderSize.y * 2, 0.5f),
                                mTracker.Trf.forward, out mHitInfo, mTracker.Trf.localRotation, mTracker.AssetInfo.colliderSize.z * 4, mTracker.AssetInfo.CheckLayer.value))
                            {
                                mState = AvoidState.AS_EXIT;
                            }
                            mWaitTime = 0;
                        }
                        else
                        {
                            mWaitTime += Time.deltaTime;
                        }
                    }

                    break;
            }
        }

        private void UpdateExit()
        {
            if (mState != AvoidState.AS_EXIT)
                return;
            if (mTracker.ModelObj == null)
                return;
            float d = 0;
            switch (mAvoidStep)
            {
                case 0:
                    d = Time.deltaTime * 1.5f + mRunDis;
                    if (d >= mTargetDis)
                    {
                        mTracker.ModelObj.transform.localPosition = Vector3.zero;
                        mTracker.ModelObj.transform.localRotation = Quaternion.identity;
                        mAvoidStep = -1;
                        mRunDis = 0;
                        mState = AvoidState.AS_NIL;
                        mIsAvoid = false;

                    }
                    else
                    {
                        mRunDis = d;
                        mTracker.ModelObj.transform.localPosition = mRunDir * mRunDis + mSourcePos;
                    }
                    break;
                case 1:
                    Vector3 dir = mTracker.ModelObj.transform.localRotation * Vector3.forward;
                    if (Vector3.Dot(mRunDir, dir) >= 0.995f)
                    {
                        mTracker.ModelObj.transform.localRotation = Quaternion.LookRotation(mRunDir, Vector3.up);
                        mAvoidStep = 0;
                    }
                    else
                    {
                        mTracker.ModelObj.transform.localRotation = Quaternion.RotateTowards(mTracker.ModelObj.transform.localRotation, Quaternion.LookRotation(mRunDir, Vector3.up), 1f);
                    }
                    break;
                case 2:
                    d = Time.deltaTime * 1.5f + mRunDis;
                    if (d >= mTargetDis)
                    {
                        mTracker.ModelObj.transform.localPosition = mRunDir * mTargetDis + mSourcePos;
                        mAvoidStep = 1;
                        mRunDis = 0;
                        mRunDir = Vector3.forward;
                        mTargetDis = mTracker.AssetInfo.colliderSize.z * 0.5f;
                        mSourcePos = -1 * mRunDir * mTargetDis;
                    }
                    else
                    {
                        mRunDis = d;
                        mTracker.ModelObj.transform.localPosition = mRunDir * mRunDis + mSourcePos;
                    }
                    break;
                case 3:
                    mTracker.Box.enabled = true;
                    mAvoidStep = 2;
                    mRunDis = 0;
                    mSourcePos = mTracker.ModelObj.transform.localPosition;
                    mRunDir = Vector3.back * mTracker.AssetInfo.colliderSize.z * 0.5f - mSourcePos;
                    mTargetDis = mRunDir.magnitude;
                    mRunDir = mRunDir.normalized;
                    break;
            }
        }

        public bool UpdateAvoid()
        {
            if (!mIsAvoid)
                return false;
            if (!mTracker.isStop)
                return true;
            UpdateFindPos();
            UpdateEnter();
            UpdateExit();
            UpdateTeamEnter();
            UpdateTeamExit();
            return true;
        }
    }

    public class CsTracker
    {
        public class TrackTeam
        {
            public GameObject Obj;
            public Vector3 PerPos;
            public Vector3 PerDir;
            public Animation Anim;
            public Bounds bounds;
            public Renderer renderer;
        }

        private CsTrackPathManager mMgr;
        private CsTrackerInfo mInfo;
        private float mStartTime = 0;
        private CsTrackerInfo.TrackAssetInfo mAssetInfo;
        private CsTrackerInfo.TrackActionInfo mActionInfo;
        private bool mReversed;
        private int mPathIndex;
        private bool mIsDestroy = false;
        private float mRunDis = 0;
        private Vector3 mTargetDir;

        private Transform mRoot = null;
        private Animation mAnim = null;
        private GameObject mObj = null;
        private GameObject mModelObj = null;
        private Renderer mRenderer = null;
        private BoxCollider mBox = null;
        public List<TrackTeam> mTeam = null;
        private float mFadeValue = -1;
        private float mFadeTime = -1;


        public Vector3 ForwardPos;
        private float mSpeedFactor = 1;
        private float mTargetFactor = 1;
        private bool mIsStop = false;
        private int mAnimState = 0;
        private int mTeamNum = 1;

        private CsTrackAvoidController mAvoidController = null;
        public static uint sUID = 0;
        public static uint sScore = 0;
        public static uint sWaitCount = 0;
        private uint mUID;

        public bool IsDestroy
        {
            get
            {
                return mIsDestroy;
            }
        }

        public Transform Trf
        {
            get
            {
                return mRoot;
            }
        }

        public CsTrackerInfo.TrackAssetInfo AssetInfo
        {
            get
            {
                return mAssetInfo;
            }
        }

        public uint UID
        {
            get
            {
                return mUID;
            }
        }

        public GameObject Obj
        {
            get
            {
                return mObj;
            }
        }

        public GameObject ModelObj
        {
            get
            {
                return mModelObj;
            }
        }

        public BoxCollider Box
        {
            get
            {
                return mBox;
            }
        }

        public bool isStop
        {
            get
            {
                return mIsStop;
            }
        }


        public CsTracker(CsTrackPathManager mgr, CsTrackerInfo info)
        {
            sUID++;
            mUID = sUID;
            mMgr = mgr;
            mInfo = info;
            mStartTime = Random.Range(mInfo.MinStartTime, mInfo.MaxStartTime);
            mAssetInfo = mInfo.AssetInfos[Random.Range(0, mInfo.AssetInfos.Length)];
            mActionInfo = mInfo.ActionInfos[Random.Range(0, mInfo.ActionInfos.Length)];
            mReversed = Random.Range(0, 100) % 2 == 0;

            mIsDestroy = false;
            mAvoidController = new CsTrackAvoidController(this);
            mTeamNum = Random.Range(1, 6);
            LoadAsset();
        }

        public CsTracker(CsTrackPathManager mgr, CsTrackerInfo info, float startTime, int AssetIndex, int ActionIndex, int teamNum)
        {
            sUID++;
            mUID = sUID;
            mMgr = mgr;
            mInfo = info;
            mStartTime = startTime;
            mAssetInfo = mInfo.AssetInfos[AssetIndex];
            mActionInfo = mInfo.ActionInfos[ActionIndex];
            mReversed = false;

            mIsDestroy = false;
            mAvoidController = new CsTrackAvoidController(this);
            mTeamNum = teamNum;
            LoadAsset();
        }

        private void ResetPos()
        {
            if (mReversed)
            {
                mRoot.position = mActionInfo.PointReversedPaths[1];
                mRoot.forward = mActionInfo.PointReversedPaths[2] - mActionInfo.PointReversedPaths[1];
            }
            else
            {
                mRoot.position = mActionInfo.PointPaths[1];
                mRoot.forward = mActionInfo.PointPaths[2] - mActionInfo.PointPaths[1];
            }

        }

        private void LoadAsset()
        {
            mObj = new GameObject(mAssetInfo.Priority.ToString() + "&" + mUID.ToString());
            mObj.gameObject.layer = LayerMask.NameToLayer(mAssetInfo.LayerName);
            mBox = mObj.AddComponent<BoxCollider>();
            mBox.isTrigger = true;
            mBox.size = mAssetInfo.colliderSize*mAssetInfo.Size;
            mBox.center = new Vector3(0, mAssetInfo.colliderSize.y * 0.5f, 0);
            Rigidbody rb = mObj.AddComponent<Rigidbody>();
            rb.isKinematic = true;
            mRoot = mObj.transform;
            mRoot.parent = mMgr.transform;
            mRoot.localPosition = Vector3.zero;
            mRoot.localRotation = Quaternion.identity;
            ResetPos();

            GameObject perfab = ResourceLibrary.instance.GetLevelUnitPrefab(mAssetInfo.AssetName);
            CsUnit unit = perfab.GetComponent<CsUnit>();
            if (unit != null)
            {
                if (mAssetInfo.IsTeam)
                {
                    mTeam = new List<TrackTeam>();
                    for (int i = 0, imax = mTeamNum; i < imax; i++)
                    {
                        TrackTeam t = new TrackTeam();
                        t.Obj = GameObject.Instantiate(unit._lowModelPrefab != null ? unit._lowModelPrefab:unit._modelPrefab);
                        t.Obj.transform.parent = mRoot;
                        t.Obj.transform.localPosition = -1 * Vector3.forward * i * mAssetInfo.TeamSpace*mAssetInfo.Size;
                        t.Obj.transform.localRotation = Quaternion.identity;
                        t.Obj.transform.localScale = Vector3.one*mAssetInfo.Size;
                        t.Anim = t.Obj.gameObject.GetComponent<Animation>();
                        t.renderer = t.Obj.gameObject.GetComponentInChildren<Renderer>();
                        if (t.renderer != null)
                        {
                            t.bounds = t.renderer.bounds;
                            t.renderer.material.shader = Shader.Find("wgame/Obj/Transparent Toon Base VL");
                            if (mAssetInfo.EnableFadeInOut)
                            {
                                t.renderer.material.SetColor("_Color", new Color(1, 1, 1, 0));
                            }
                            else
                            {
                                t.renderer.material.SetColor("_Color", Color.white);
                            }
                                
                        }

                        t.PerPos = t.Obj.transform.localPosition;
                        t.PerDir = mRoot.forward;
                        mTeam.Add(t);
                    }
                }
                else
                {
                    mModelObj = GameObject.Instantiate(unit._lowModelPrefab != null ? unit._lowModelPrefab:unit._modelPrefab);
                    mModelObj.transform.parent = mRoot;
                    mModelObj.transform.localPosition = Vector3.zero;
                    mModelObj.transform.localRotation = Quaternion.identity;
                    mModelObj.transform.localScale = Vector3.one*mAssetInfo.Size;
                    mAnim = mModelObj.gameObject.GetComponent<Animation>();
                    mRenderer = mModelObj.GetComponentInChildren<Renderer>();
                    mRenderer.material.shader = Shader.Find("wgame/Obj/Transparent Toon Base VL");
                    if (mAssetInfo.EnableFadeInOut)
                    {
                        mRenderer.material.SetColor("_Color", new Color(1, 1, 1, 0));
                    }
                    else
                    {
                        mRenderer.material.SetColor("_Color", Color.white);
                    }
                        
                }
            }

            PlayAnim(0);
            mObj.SetActive(false);
        }

        public void PlayAnim(int index)
        {
            if (mAnimState == index)
            {
                return;
            }
            if (index < 0 || index >= mAssetInfo.Anims.Length)
                return;
            mAnimState = index;
            if (mAnim != null && !string.IsNullOrEmpty(mAssetInfo.Anims[mAnimState]))
            {
                mAnim.Play(mAssetInfo.Anims[mAnimState]);
            }
            if (mTeam != null)
            {
                for (int i = 0, imax = mTeam.Count; i < imax; i++)
                {
                    if (mTeam[i].Anim != null && !string.IsNullOrEmpty(mAssetInfo.Anims[mAnimState]))
                    {
                        AnimationState state = mTeam[i].Anim[mAssetInfo.Anims[mAnimState]];
                        if (state != null)
                        {
                            state.time = Random.Range(0, state.length - 0.1f);
                        }
                        mTeam[i].Anim.CrossFade(mAssetInfo.Anims[mAnimState]);
                    }
                }
            }
        }

        public void Destroy()
        {
            mIsDestroy = true;
            GameObject.Destroy(mRoot.gameObject);
        }

        public float BackMove()
        {
            if (mRunDis == 0)
                return -1;
            float target = mActionInfo.PathLength;
            if (mReversed)
            {
                target = mActionInfo.ReversedPathLength;
            }
            float p = mRunDis / target;

            float f = mActionInfo.Curve.Evaluate(p);
            if (f == 0)
                f = 1;
            float d = mAssetInfo.Speed * f * Time.deltaTime;
            float dd = mRunDis - d;
            if (dd <= 0)
            {
                mRunDis = 0;
                if (mReversed)
                {
                    mRoot.position = CsTrackPathManager.Interp(mActionInfo.PointReversedPaths, 0);
                }
                else
                {
                    mRoot.position = CsTrackPathManager.Interp(mActionInfo.PointPaths, 0);
                }
                return -1;
            }
            else
            {
                mRunDis = dd;
                p = mRunDis / target;
                Vector3 pos;
                if (mReversed)
                {
                    pos = CsTrackPathManager.Interp(mActionInfo.PointReversedPaths, p);
                }
                else
                {
                    pos = CsTrackPathManager.Interp(mActionInfo.PointPaths, p);
                }
                Vector3 dir = -(pos - mRoot.position);
                mRoot.forward = Quaternion.Lerp(Quaternion.identity, Quaternion.FromToRotation(mRoot.forward, dir), 0.7f) * dir;
                mRoot.position = pos;
                return d;
            }
        }

        private void UpdateFade(float p)
        {
            if(!mAssetInfo.EnableFadeInOut)
                return;
            float pp = Mathf.Max(0.001f,mAssetInfo.Start2FadeInPercent);
            float fade = -1;
            if(p<=pp && p >= 0)
            {
                fade = Mathf.Min(1,p/ pp);

            }
            else
            {
                pp =  Mathf.Max(0.001f,mAssetInfo.FadeOutPercent2End);
                if(p>=pp && p<=1)
                {
                    fade =1- Mathf.Min(1,(p-pp)/(1- pp));
                }
            }

            if(fade >= 0)
            {
                if (mAssetInfo.IsTeam)
                {
                    for (int i = 0, imax = mTeamNum; i < imax; i++)
                    {
                        if(mTeam[i].renderer != null)
                        {
                            mTeam[i].renderer.material.SetColor("_Color",new Color(1,1,1,fade));
                        }
                    }
                }
                else
                {
                    if(mRenderer != null)
                    {
                        mRenderer.material.SetColor("_Color",new Color(1,1,1,fade));
                    }
                }
            }
        }

        public void UpdateTeamMove()
        {
            if (!mAssetInfo.IsTeam)
                return;
            if (mTeamNum == 1)
                return;

            for (int i = 1, imax = mTeam.Count; i < imax; i++)
            {
                MoveTeamMember(mRunDis - (i * mAssetInfo.TeamSpace), mTeam[i].Obj.transform);

            }
        }

        public float MoveTeamMember(float dis, Transform trf)
        {
            float target = mActionInfo.PathLength;
            if (mReversed)
            {
                target = mActionInfo.ReversedPathLength;
            }
            if (dis < 0 || dis > target)
                return dis;
            if (mSpeedFactor <= 0.01f)
            {
                return dis;
            }

            float p = dis / target;
            {
                Vector3 pos;
                if (mReversed)
                {
                    pos = CsTrackPathManager.Interp(mActionInfo.PointReversedPaths, p);
                }
                else
                {
                    pos = CsTrackPathManager.Interp(mActionInfo.PointPaths, p);
                }
                trf.position = pos;
            }
            return dis;
        }

        public float Move(float dis, Transform trf)
        {
            float target = mActionInfo.PathLength;
            if (mReversed)
            {
                target = mActionInfo.ReversedPathLength;
            }
            if (dis < 0 || dis > target)
                return dis;
            if (mSpeedFactor != mTargetFactor)
            {
                if (mTargetFactor == 1)
                {
                    mSpeedFactor = Mathf.Lerp(mSpeedFactor, mTargetFactor, Time.deltaTime);
                }
                else
                {
                    mSpeedFactor = Mathf.Lerp(mSpeedFactor, mTargetFactor, 0.15f);
                }
            }

            if (mSpeedFactor <= 0.01f)
            {
                mSpeedFactor = 0;
                mIsStop = true;
                return dis;
            }
            mIsStop = false;

            float p = dis / target;
            UpdateFade(p);
            if (mReversed)
            {
                p = 1 - p;
            }

            

            float f = mActionInfo.Curve.Evaluate(p);
            if (f == 0)
                f = 1;

            float d = mAssetInfo.Speed * f * Time.deltaTime * mSpeedFactor + dis;
            if (d >= target)
            {
                if (mActionInfo.Loop)
                {
                    mReversed = !mReversed;
                    mRunDis = 0;
                    ResetPos();
                }
                else
                {
                    Destroy();
                    return dis;
                }
            }
            else
            {
                dis = d;
                p = dis / target;
                Vector3 pos;
                if (mReversed)
                {
                    pos = CsTrackPathManager.Interp(mActionInfo.PointReversedPaths, p);
                }
                else
                {
                    pos = CsTrackPathManager.Interp(mActionInfo.PointPaths, p);
                }
                Vector3 dir = pos - trf.position;
                //if (!local)
                {
                    dir = Quaternion.Lerp(Quaternion.identity, Quaternion.FromToRotation(trf.forward, dir), 0.5f) * dir;
                    if (dir == Vector3.zero)
                    {
                        //Debug.Log(mRoot.name);
                    }
                    else
                        trf.forward = dir;
                }
                //else
                //{

                //}
                trf.position = pos;
            }
            return dis;

        }
        public void UpdateShadow()
        {
            if (mModelObj != null)
            {

                if (mMgr.Entity.ProjShadow != null)
                {
                    Vector3 view_max = Camera.main.WorldToViewportPoint(mRenderer.bounds.max);
                    Vector3 view_min = Camera.main.WorldToViewportPoint(mRenderer.bounds.min);
                    if (Camera.main.rect.Contains(view_max) || Camera.main.rect.Contains(view_min))
                    {
                        mMgr.Entity.ProjShadow.Adjust(mModelObj.transform.position);
                    }
                }
            }
            if (mTeam != null && mMgr.Entity.ProjShadow != null)
            {
                Bounds bounds = new Bounds();
                Vector3 pos = Vector3.zero;

                for (int i = 0, imax = mTeam.Count; i < imax; i++)
                {
                    if (i == 0)
                        pos = mTeam[i].Obj.transform.position;
                    bounds.Encapsulate(mTeam[i].bounds);
                }
                Vector3 view_max = Camera.main.WorldToViewportPoint(bounds.max);
                Vector3 view_min = Camera.main.WorldToViewportPoint(bounds.min);
                if (Camera.main.rect.Contains(view_max) || Camera.main.rect.Contains(view_min))
                {
                    mMgr.Entity.ProjShadow.Adjust(pos);
                }
            }
        }

        public void Update()
        {
            if (mIsDestroy)
                return;
            if (mStartTime > 0)
            {
                mStartTime -= Time.deltaTime;
                return;
            }
            if (!mObj.activeSelf)
            {
                RaycastHit hitInfo;
                if (!Physics.BoxCast(Trf.position + Trf.forward * -2 * AssetInfo.colliderSize.z,
                    new Vector3(AssetInfo.colliderSize.x * 2, AssetInfo.colliderSize.y * 2, 0.5f),
                    Trf.forward, out hitInfo, Trf.localRotation, AssetInfo.colliderSize.z * 4, AssetInfo.CheckLayer.value))
                {
                    mObj.SetActive(true);

                }
                else
                    return;
            }
            if (AssetInfo.EnableAvoid)
            {
                if (!mAvoidController.UpdateAvoid())
                {
                    if (!mAvoidController.CheckStop())
                    {
                        mTargetFactor = 1;
                    }
                    else
                    {
                        PlayAnim(0);
                        mTargetFactor = 0;
                    }

                }
                else
                    mTargetFactor = 0;
            }
            
            mRunDis = Move(mRunDis, mRoot);
            UpdateTeamMove();
            UpdateShadow();
            if (mTargetFactor == 0)
                return;
            if (isStop)
            {
                PlayAnim(0);
            }
            else
            {
                PlayAnim(1);
            }
        }
    }

    public class CsTrackPathManager : MonoBehaviour
    {
        [System.Serializable]
        public struct AutoTrackInfo
        {
            public int MaxAutoTimes;
            public int MinAutoTimes;
            public string type;
            public int num;
            public int check_count;
        }

        public AutoTrackInfo[] AutoInfo;

        private Dictionary<string, CsTrackerInfo> mTrackerMap = new Dictionary<string, CsTrackerInfo>();

        private List<List<CsTracker>> mTrackerList = new List<List<CsTracker>>();

        private List<string> mTrackTypes = new List<string>();

        private List<int> mTrackAutoTimes = new List<int>();

        private SceneEntity mEntity = null;

        public SceneEntity Entity
        {
            get
            {
                return mEntity;
            }
        }

        public static Vector3[] PathControlPointGenerator(Vector3[] path)
        {
            Vector3[] suppliedPath;
            Vector3[] vector3s;

            //create and store path points:
            suppliedPath = path;

            //populate calculate path;
            int offset = 2;
            vector3s = new Vector3[suppliedPath.Length + offset];
            System.Array.Copy(suppliedPath, 0, vector3s, 1, suppliedPath.Length);

            //populate start and end control points:
            //vector3s[0] = vector3s[1] - vector3s[2];

            vector3s[0] = vector3s[1] + (vector3s[1] - vector3s[2]);
            vector3s[vector3s.Length - 1] = vector3s[vector3s.Length - 2] + (vector3s[vector3s.Length - 2] - vector3s[vector3s.Length - 3]);

            //is this a closed, continuous loop? yes? well then so let's make a continuous Catmull-Rom spline!
            if (vector3s[1] == vector3s[vector3s.Length - 2])
            {
                Vector3[] tmpLoopSpline = new Vector3[vector3s.Length];
                System.Array.Copy(vector3s, tmpLoopSpline, vector3s.Length);
                tmpLoopSpline[0] = tmpLoopSpline[tmpLoopSpline.Length - 3];
                tmpLoopSpline[tmpLoopSpline.Length - 1] = tmpLoopSpline[2];
                vector3s = new Vector3[tmpLoopSpline.Length];
                System.Array.Copy(tmpLoopSpline, vector3s, tmpLoopSpline.Length);
            }

            return (vector3s);
        }

        public static Vector3 Interp(Vector3[] pts, float t)
        {
            int numSections = pts.Length - 3;
            int currPt = Mathf.Min(Mathf.FloorToInt(t * (float)numSections), numSections - 1);
            float u = t * (float)numSections - (float)currPt;

            Vector3 a = pts[currPt];
            Vector3 b = pts[currPt + 1];
            Vector3 c = pts[currPt + 2];
            Vector3 d = pts[currPt + 3];

            return .5f * (
                (-a + 3f * b - 3f * c + d) * (u * u * u)
                + (2f * a - 5f * b + 4f * c - d) * (u * u)
                + (-a + c) * u
                + 2f * b
            );
        }

        void Awake()
        {
            Init();
        }

        public void Init()
        {
            CsTracker.sUID = 0;
            CsTracker.sScore = 0;
            CsTracker.sWaitCount = 0;
            CsTrackerData[] datas = this.gameObject.GetComponentsInChildren<CsTrackerData>();
            if (this.transform.parent != null)
            {
                SceneEntity se = this.transform.parent.GetComponent<SceneEntity>();
                if (se != null)
                {
                    mEntity = se;
                }
            }

            for (int i = 0, imax = datas.Length; i < imax; i++)
            {
                mTrackerMap.Add(datas[i].Info.TrackType, datas[i].Info);
            }

            for (int i = 0, imax = AutoInfo.Length; i < imax; i++)
            {
                int index = GetTrackIndex(AutoInfo[i].type);
                if (index < 0)
                    continue;
                mTrackAutoTimes[index] = UnityEngine.Random.Range(AutoInfo[i].MinAutoTimes, AutoInfo[i].MaxAutoTimes);
            }
        }

        public void CreateMultiTracker(string type, int num)
        {
            CsTrackerInfo info = null;
            if (mTrackerMap.TryGetValue(type, out info))
            {
                CsTracker tracker = null;

                for (int i = 0, imax = num; i < imax; i++)
                {
                    tracker = new CsTracker(this, info);
                    int index = mTrackTypes.IndexOf(type);
                    if (index < 0)
                    {
                        mTrackTypes.Add(type);
                        mTrackAutoTimes.Add(0);
                        mTrackerList.Add(new List<CsTracker>());
                        index = mTrackTypes.Count - 1;
                    }
                    mTrackerList[index].Add(tracker);
                }
            }
        }

        public int GetTrackIndex(string type)
        {
            int index = mTrackTypes.IndexOf(type);
            if (index < 0)
            {
                if (mTrackerMap.ContainsKey(type))
                {
                    mTrackTypes.Add(type);
                    mTrackAutoTimes.Add(0);
                    mTrackerList.Add(new List<CsTracker>());
                    return mTrackTypes.Count - 1;
                }
                return -1;
            }
            return index;
        }

        public void CreateTracker(string type, float startTime = -1, int AssetIndex = -1, int ActionIndex = -1, int teamNum = 1)
        {
            CsTrackerInfo info = null;
            if (mTrackerMap.TryGetValue(type, out info))
            {
                CsTracker tracker = null;
                if (startTime < 0 || AssetIndex < 0 || ActionIndex < 0)
                {
                    tracker = new CsTracker(this, info);
                }
                else
                {
                    tracker = new CsTracker(this, info, startTime, AssetIndex, ActionIndex, teamNum);
                }
                int index = mTrackTypes.IndexOf(type);
                if (index < 0)
                {
                    mTrackTypes.Add(type);
                    mTrackAutoTimes.Add(0);
                    mTrackerList.Add(new List<CsTracker>());
                    index = mTrackTypes.Count - 1;
                }
                mTrackerList[index].Add(tracker);
            }
        }

        public void RemoveUpdateQueue(string type)
        {
            int index = mTrackTypes.IndexOf(type);
            if (index >= 0)
            {
                for (int i = 0, imax = mTrackerList[index].Count; i < imax; i++)
                {
                    if (!mTrackerList[index][i].IsDestroy)
                    {
                        mTrackerList[index][i].Destroy();
                    }
                }
                mTrackerList[index].Clear();
            }
        }

        public void UpdateTracker()
        {
            if (mTrackerList.Count == 0)
                return;

            List<CsTracker> trackers = null;
            for (int i = 0, imax = mTrackerList.Count; i < imax; i++)
            {
                trackers = mTrackerList[i];
                if (trackers.Count == 0)
                    continue;
                for (int j = 0; j < trackers.Count;)
                {
                    if (!trackers[j].IsDestroy)
                    {
                        trackers[j].Update();
                        j++;
                    }
                    else
                    {
                        trackers.RemoveAt(j);
                    }
                }
            }
        }

        void Update()
        {

            //if (Input.GetKeyDown(KeyCode.A))
            //{
            //    CreateTracker("soldier");
            //}
            for (int i = 0, imax = AutoInfo.Length; i < imax; i++)
            {
                int index = GetTrackIndex(AutoInfo[i].type);
                if (index < 0)
                    continue;
                if (AutoInfo[i].MinAutoTimes > 0 && AutoInfo[i].MaxAutoTimes > 0)
                {
                    if (mTrackAutoTimes[index] <= 0)
                        continue;
                }
                int count = mTrackerList[index].Count;
                if (count >= 0 && count < AutoInfo[i].check_count)
                {
                    if (mTrackAutoTimes[index] > 0)
                    {
                        mTrackAutoTimes[index]--;
                    }

                    CreateMultiTracker(AutoInfo[i].type, AutoInfo[i].num);
                }
            }
            UpdateTracker();
        }

        /*void OnDrawGizmos()
        {
            CsTrackPath[] datas = gameObject.GetComponentsInChildren<CsTrackPath>();
            for (int i = 0, imax = datas.Length; i < imax; i++)
            {
                iTween.DrawPath(datas[i].nodeTrf.ToArray(), datas[i].PathColor);
            }
        }*/
    }

}

