using System;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct TLineSetting
{
    public int point_num;
    public float line_width;
    public float min_dis;
    public float tile_length;
    public float offset_height;
    public float faraway_target_height;
    public Material mat;
}

public class TTrail
{
    private Vector3[] mPoints;
    private float[] mPointDis;
    private int mPointNum;
    private int mVaildCount;
    private float mMinUnitDis;
    private float mMinLength;
    private Vector3 mForward;
    public Vector3 Forward { get { return mForward; } }
    public Vector3[] Points { get { return mPoints; } }
    public float[] PointDis { get { return mPointDis; } }
    public int VaildCount { get { return mVaildCount; } }
    public int PointNum { get { return mPointNum; } }
    private WorldData mWorld;
    public SMCInfo mVIns;
    public SMCInfo VIns { get { return mVIns; } }
    private Vector3 mStart;
    private Vector3 mEnd;
    private Vector3 mDir;
    private Vector3 mTmp;
    private Vector3 mOldTmp;
    private float mCurTime;
    public float mTotalTime;
    private TLine mLine;

    public int AircraftId;

    public Transform tf;
    bool isArrived = false;
    private bool mValidT = false;
    public bool VaildT { get { return mValidT; } }
    Vec2Int mTargetPos;
    int mType;
    int mEntryType;
    public int mStatus;
    bool mIsEffect;
    public TTrail(WorldData world, TLine line, int point_num, float min_dis)
    {
        mLine = line;
        mWorld = world;
        mMinUnitDis = min_dis;
        mPointNum = point_num;
        mMinLength = mMinUnitDis * mPointNum;

        mPoints = new Vector3[point_num];
        mPointDis = new float[point_num];
        mVaildCount = 0;
    }

    public void Reset()
    {
        isArrived = false;
        mVaildCount = 0;
    }
    public void ClearVehice()
    {
        if (mVIns != null)
        {
            mWorld.world.VehiceSMC.Pop(mVIns);
            mVIns = null;
        }
    }

    public void UpdateVehiceTime(Vector3 time)
    {
        mCurTime = time.x - time.y;
        mTotalTime = time.z;
    }

    public void SetVehice(int id, Vec2Int targetPos, int plane_type, int type, int status, int entryType, int cur_time, int start_time, int total_time, bool isEffect) // time.x = cur time.y = start time.z = total
    {
        if (mVaildCount == 0)
            return;
        mValidT = true;
        mCurTime = cur_time - start_time;
        mTotalTime = total_time;
        mTargetPos = targetPos;
        mType = type;
        mEntryType = entryType;
        mStatus = status;
        mIsEffect = isEffect;
        AircraftId = id;
        mVIns = mWorld.world.VehiceSMC.Push(plane_type, mStart, WorldHUDType.EXPEDITION, id);
        if (mVIns != null)
        {
            mVIns.smc_id = id;
            UpdateVehice(0, false);
            mOldTmp = mVIns.trf.position;
        }
    }

    private static Vector3 Interp(Vector3[] pts, float t)
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


    private float easeInSine(float start, float end, float value)
    {
        end -= start;
        return -end * Mathf.Cos(value * (Mathf.PI * 0.5f)) + end + start;
    }

    private float easeOutSine(float start, float end, float value)
    {
        end -= start;
        return end * Mathf.Sin(value * (Mathf.PI * 0.5f)) + start;
    }

    public void UpdateVehice(float _time, bool enable_pop = true)
    {
        if (mVaildCount == 0)
            return;
        if (mVIns == null)
            return;
        mCurTime += _time;
        if (mCurTime < 0 || (mEnd - mStart).sqrMagnitude < 0.01f)
        {
            if (mValidT)
            {
                mValidT = false;
                mLine.ForceHide();
                mWorld.LineMgr.ForceApply();
                mTmp.x = 0;
                mTmp.y = -1000;
                mTmp.z = 0;
                mVIns.trf.position = mTmp;
            }
            return;
        }
        else
        {
            if (!mValidT)
            {
                mValidT = true;
                mLine.UpdateLine();
                mWorld.LineMgr.ForceApply();
            }

        }
        if (mCurTime >= mTotalTime - 0.5f)
        {
            mTmp = mEnd;
            mTmp.y = -1000;
            mVIns.trf.position = mTmp;
            //mVIns.trf.position = mPoints[];
            if (!isArrived)
            {
                mLine.ForceHide();
                mWorld.LineMgr.ForceApply();


                isArrived = true;
                Success();
            }
            //else
            //{

            //    if (enable_pop || mLine.Vaild)
            //        mWorld.LineMgr.Pop(mLine);
            //}
            return;
        }
        float p = mCurTime / mTotalTime;
        mTmp = Vector3.Lerp(mStart, mEnd, p); //Interp(mPoints, p);
        mVIns.trf.position = mTmp;
        mOldTmp = mTmp - mOldTmp;
        mVIns.trf.forward = mForward;// Vector3.Lerp(mVIns.trf.forward, mOldTmp,0.5f);
        mOldTmp = mTmp;
        mVIns.HUD.ParallelToScreen();

        //NGUIMath.OverlayPosition(tf, mTmp, Camera.main);
        //mTmp = tf.localPosition;
        //mTmp.z = 0;
        //tf.localPosition = mTmp;

        if (mVIns.trf.position.y != -1000)
            if (AircraftId == mWorld.mDataInterface.FollowId())
            {
                mWorld.mDataInterface.SetCamera(mVIns.trf.position);
            }
    }

    public void Set(Vector3 start, Vector3 end)
    {
        mStart = start;
        mEnd = end;
        mForward = mEnd - mStart;
        float dis = mForward.magnitude;
        mForward = mForward.normalized;
        mVaildCount = mPointNum;
        for (int i = 0; i < mVaildCount; i++)
        {
            mPointDis[i] = ((float)i / (float)mVaildCount) * dis;
            mPoints[i] = mForward * mPointDis[i] + start;
            mPoints[i].y = mWorld.TerrainLineSetting.offset_height;
        }

        mPoints[mVaildCount - 1] = end;
        mPoints[mVaildCount - 1].y = mWorld.TerrainLineSetting.offset_height;
        mStart.y = mWorld.TerrainLineSetting.offset_height;
        mEnd.y = mWorld.TerrainLineSetting.offset_height;
    }

    void Success()
    {
        if (mWorld == null)
            return;
        if ((mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackMonster
           || mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_GatherCall
           || mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackPlayer)
            && mStatus == 1)
        {
            ProtoMsg.SEntryData tileMsg = WorldMapMgr.Instance.ShowTileInfo((uint)mTargetPos.x, (uint)mTargetPos.y);
            if (tileMsg == null)
                return;
            if (mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackPlayer
               || mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_GatherCall
               || mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_GatherRespond)
            {
                if (tileMsg.home != null && tileMsg.home.hasShield)
                {
                    return;
                }
            }
            if (mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackMonster)
            {
                WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 0, 5);
            }
            else
            {
                if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_Fort)
                {
                    if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                        WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 1, 5);
                }
                else
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 0, 5);
                }
            }
        }
        if (mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
        {
            if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 0, 5);
        }

        if (mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_GarrisonCenterBuild
            || mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_MobaGarrisonBuild)
        {
            if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
            {
                if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_Stronghold)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 9, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_Fortress)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 8, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaGate)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 10, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaCenter)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 11, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaArsenal)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 10, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaFort)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 12, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaInstitute)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 10, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaTransPlat)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 10, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaSmallBuild)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 10, 5);
                }
                else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_WorldCity)
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 10, 5);
                }
                else
                {
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 5, 5);
                }
            }

        }

        if (mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackCenterBuild 
            || mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_MobaAtkBuild
            || mType == (int)ProtoMsg.TeamMoveType.TeamMoveType_AttackWorldCity)
        {
            ProtoMsg.SEntryData tileMsg = WorldMapMgr.Instance.ShowTileInfo((uint)mTargetPos.x, (uint)mTargetPos.y);
            if (tileMsg == null)
                return;
            if (tileMsg.centerBuild != null && tileMsg.centerBuild.hasShield)
            {
                return;
            }
            if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_Govt)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 3, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_Turret)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 4, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaGate)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y,7, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaCenter)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 14, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaArsenal)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 7, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaFort)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 14, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaInstitute)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 7, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaTransPlat)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 7, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_MobaSmallBuild)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 7, 5);
            }
            else if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_WorldCity)
            {
                if (mStatus == (int)ProtoMsg.PathMoveStatus.PathMoveStatus_Go)
                    WorldMapMgr.Instance.PlayEffect((int)mTargetPos.x, (int)mTargetPos.y, 7, 5);
            }
        }
        if (mEntryType == (int)ProtoMsg.SceneEntryType.SceneEntryType_EliteMonster)
        {
            SMCInfo smcinfo = mWorld.world.worldMapUpdata.worldMapBuild.GetCacheBuildSMCInfo((int)mTargetPos.x, (int)mTargetPos.y);
            if (smcinfo != null)
            {
                if (smcinfo.isActive)
                    smcinfo.ResetActive();
            }
        }
        if (mIsEffect)
        {
            LuaClient.GetMainState().GetFunction("WorldMap.DrawPathEffect").Call(mEntryType, mStatus, (int)mTargetPos.x, (int)mTargetPos.y);
        }
    }


    public void Destroy()
    {
        mPoints = null;
        mPointNum = -1;
    }
}

public class TLine
{
    private Vector3[] mVs;
    private Vector2[] mUs;
    private Color[] mCs;
    private int[] mTs;
    private Vector3[] mNs;

    private int mVCount;
    private int mTCount;

    private TTrail mTrail;
    public TTrail Trail { get { return mTrail; } }
    private float mWidth;
    private float mMaterialTileLength;
    public Color LineColor { get { return mLineColor; } }
    private Color mLineColor;
    private float mLineSpeed;
    private int mVIndex;
    private int mTIndex;
    private bool mNeedUpdate;
    private bool mNeedUpdateLine;
    private bool mVaild;
    private int mIndex;
    public bool NeedUpdate { get { return mNeedUpdate; } }
    public bool NeedUpdateLine { get { return mNeedUpdateLine; } }
    public int Index { get { return mIndex; } }
    public bool Vaild { get { return mVaild; } }
    public Vector3[] Vs { get { return mVs; } }
    public Vector2[] Us { get { return mUs; } }
    public Color[] Cs { get { return mCs; } }
    public int[] Ts { get { return mTs; } }
    public Vector3[] Ns { get { return mNs; } }
    public int VCount { get { return mVCount; } }
    public int TCount { get { return mTCount; } }
    public int VIndex { get { return mVIndex; } }
    public int TIndex { get { return mTIndex; } }


    public TLine(int index, WorldData world)
    {
        mIndex = index;
        mWidth = world.TerrainLineSetting.line_width;
        mLineColor = Color.white;
        mMaterialTileLength = world.TerrainLineSetting.tile_length;
        mTrail = new TTrail(world, this, world.TerrainLineSetting.point_num, world.TerrainLineSetting.min_dis);
        mVCount = mTrail.PointNum * 2;
        mTCount = mVCount * 3;
        mVIndex = mIndex * mVCount;
        mTIndex = mIndex * mTCount;
        mVs = new Vector3[mVCount];
        mUs = new Vector2[mVCount];
        mCs = new Color[mVCount];
        mTs = new int[mTCount];
        mNs = new Vector3[mVCount];
        mNeedUpdate = false;
        mNeedUpdateLine = false;
        mVaild = false;
    }

    public void Reset()
    {
        mNeedUpdateLine = false;
        mNeedUpdate = false;
    }
    public void Hide()
    {

        mTrail.ClearVehice();
        if (!mVaild)
            return;
        System.Array.Clear(mCs, 0, mVCount);
        mNeedUpdate = true;
        mVaild = false;

    }

    public void ForceHide()
    {
        System.Array.Clear(mCs, 0, mVCount);
        mNeedUpdate = true;
    }

    public void Set(int id, Vector3 start, Vector3 end, Vec2Int targetPos, Color color, float speed, int plane_type, int type, int status, int entryType, int cur_time, int start_time, int total_time, bool isEffect)
    {
        mLineColor = color;
        mLineSpeed = speed;
        mTrail.Reset();
        mTrail.Set(start, end);
        mTrail.SetVehice(id, targetPos, plane_type, type, status, entryType, cur_time, start_time, total_time, isEffect);
        //if (!mVaild && mTrail.VaildCount == 0)
        //{
        //    Debug.LogError("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
        //    return;
        //}
        mVaild = true;
        if (mTrail.VaildT)
        {
            UpdateLine();
        }
    }

    public void SetOnlyLine(Vector3 start, Vector3 end, Color color, float speed)
    {
        mLineColor = color;
        mLineSpeed = speed;
        mTrail.Reset();
        mTrail.Set(start, end);
        mVaild = true;
        //if (mTrail.VaildT)
        {
            UpdateLine();
        }
    }

    public void UpdateSpeedTime(float speed, Vector3 time)
    {
        if (!mVaild && mTrail.VaildCount == 0)
            return;

        mLineSpeed = speed;
        mTrail.UpdateVehiceTime(time);

        UpdateLineSpeed();

    }


    public void Update(float d)
    {
        if (!mVaild)
            return;
        mTrail.UpdateVehice(d);
    }

    private void UpdateLineSpeed()
    {
        int vc = mTrail.VaildCount;
        if (vc == 0)
            return;
        int vi = 0;
        for (int i = 0; i < vc; i++)
        {
            mNs[vi].x = mLineSpeed;
            vi++;
            mNs[vi].x = mLineSpeed;
            vi++;
        }
        Vector2 finalPosition = mVs[vi - 1];
        for (int i = vi; i < mVCount; i++)
        {
            mNs[vi].x = 0;
        }
        mNeedUpdate = true;
        mNeedUpdateLine = true;
    }

    public void UpdateLine()
    {
        System.Array.Clear(mCs, 0, mVCount);
        int vc = mTrail.VaildCount;

        if (vc == 0)
            return;
        Vector3[] points = mTrail.Points;
        float[] pointDis = mTrail.PointDis;
        Vector3 cross = Vector3.Cross(mTrail.Forward, Vector3.down).normalized;
        int vi = 0;
        for (int i = 0; i < vc; i++)
        {
            mVs[vi] = points[i] + cross * mWidth;
            mUs[vi] = new Vector2((pointDis[i] / mMaterialTileLength), 0);
            mCs[vi] = mLineColor;
            mNs[vi].x = mLineSpeed;
            vi++;
            mVs[vi] = points[i] - cross * mWidth;
            mUs[vi] = new Vector2((pointDis[i] / mMaterialTileLength), 1);
            mCs[vi] = mLineColor;
            mNs[vi].x = mLineSpeed;
            vi++;
        }
        Vector2 finalPosition = mVs[vi - 1];
        for (int i = vi; i < mVCount; i++)
        {
            mNs[vi].x = 0;
            mVs[i] = finalPosition;
        }

        int ti = 0;
        for (int pointIndex = 0; pointIndex < 2 * (vc - 1); pointIndex++)
        {
            if (pointIndex % 2 == 0)
            {
                mTs[ti] = pointIndex + mVIndex;
                ti++;
                mTs[ti] = pointIndex + 1 + mVIndex;
                ti++;
                mTs[ti] = pointIndex + 2 + mVIndex;
            }
            else
            {
                mTs[ti] = pointIndex + 2 + mVIndex;
                ti++;
                mTs[ti] = pointIndex + 1 + mVIndex;
                ti++;
                mTs[ti] = pointIndex + mVIndex;
            }
            ti++;
        }

        int finalIndex = mTs[ti - 1];
        for (int i = ti; i < mTCount; i++)
        {
            mTs[i] = finalIndex;
        }

        mNeedUpdate = true;
    }

    public void Destroy()
    {
        mTrail.Destroy();
        mTrail = null;
        mVCount = -1;
        mTCount = -1;
        mVs = null;
        mUs = null;
        mCs = null;
        mTs = null;
    }
}

public class TLineManager
{
    private int mCacheNum;
    private TLine[] mLines;
    public TLine[] Lines { get { return mLines; } }
    private StackCombineInt mValidFlags;

    private Vector3[] mVs;
    private Vector2[] mUs;
    private Color[] mCs;
    private int[] mTs;
    private Vector3[] mNs;

    private int mVCount;
    private int mTCount;

    private TLineSetting mSetting;

    private Mesh mMesh;
    private Vector3 mPos;
    private Quaternion mQua;
    private Material mMat;
    private int mLayer;
    private bool mNeedApply = false;
    private WorldData mWorld;
    public TLineManager(WorldData world, int cache_num, TLineSetting setting, int layer)
    {
        mWorld = world;
        mPos = Vector3.zero;
        mQua = Quaternion.identity;
        mSetting = setting;
        mMat = mSetting.mat;
        mLayer = layer;
        mCacheNum = cache_num;
        mLines = new TLine[mCacheNum];
        mValidFlags = new StackCombineInt(mCacheNum);
        for (int i = 0; i < mCacheNum; i++)
        {
            mValidFlags.Push(i);
        }
        int lv = mSetting.point_num * 2;
        int tv = lv * 3;
        mVCount = mCacheNum * lv;
        mTCount = mCacheNum * tv;
        mVs = new Vector3[mVCount];
        mUs = new Vector2[mVCount];
        mCs = new Color[mVCount];
        mTs = new int[mTCount];
        mNs = new Vector3[mVCount];
        mMesh = new Mesh();
        mMesh.name = "[3DT]TLineManager_Mesh";
        mNeedApply = false;
    }

    public TLine Push(int id, Vector3 start, Vector3 end, Vec2Int targetPos, Color color, float speed, int plane_type, int type, int status, int entryType, int cur_time, int start_time, int total_time, bool isEffect)
    {
        int index = mValidFlags.Pop();
        if (index < 0)
            return null;
        if (mLines[index] == null)
        {
            mLines[index] = new TLine(index, mWorld);
        }
        mLines[index].Set(id, start, end, targetPos, color, speed, plane_type, type, status, entryType, cur_time, start_time, total_time, isEffect);
        mNeedApply = true;
        return mLines[index];
    }

    public TLine Push4OnlyLine(Vector3 start, Vector3 end, Color color, float speed)
    {
        int index = mValidFlags.Pop();
        if (index < 0)
            return null;
        if (mLines[index] == null)
        {
            mLines[index] = new TLine(index, mWorld);
        }
        mLines[index].SetOnlyLine(start, end, color, speed);
        mNeedApply = true;
        return mLines[index];
    }

    public void Pop(TLine line)
    {
        if (line.Index < 0)
            return;
        line.Hide();
        mValidFlags.Push(line.Index);
        mNeedApply = true;
    }

    public void ForceApply()
    {
        mNeedApply = true;
    }

    public void Apply()
    {
        if (!mNeedApply)
            return;
        TLine tmpline = null;
        for (int i = 0; i < mCacheNum; i++)
        {
            if (mLines[i] == null)
                continue;
            tmpline = mLines[i];
            if (tmpline.NeedUpdate)
            {
                if (tmpline.NeedUpdateLine)
                {
                    System.Array.Copy(tmpline.Ns, 0, mNs, tmpline.VIndex, tmpline.VCount);
                }
                else
                {
                    System.Array.Copy(tmpline.Vs, 0, mVs, tmpline.VIndex, tmpline.VCount);
                    System.Array.Copy(tmpline.Ns, 0, mNs, tmpline.VIndex, tmpline.VCount);
                    System.Array.Copy(tmpline.Us, 0, mUs, tmpline.VIndex, tmpline.VCount);
                    System.Array.Copy(tmpline.Cs, 0, mCs, tmpline.VIndex, tmpline.VCount);
                    System.Array.Copy(tmpline.Ts, 0, mTs, tmpline.TIndex, tmpline.TCount);
                }
                tmpline.Reset();
            }
        }

        mMesh.vertices = mVs;
        mMesh.colors = mCs;
        mMesh.triangles = mTs;
        mMesh.uv = mUs;
        mMesh.normals = mNs;

        UpdateBound(mWorld.CenterPos, mWorld.ChunkSize * 3f);
        mWorld.world.VehiceSMC.Apply();
        mNeedApply = false;
    }

    public void UpdateBound(Vector3 bcenter, float bsize)
    {
        MeshCombine.UpdateMeshBounds(mMesh, bcenter, bsize);
    }

    public void Update(float _dt)
    {
        TLine tmpline = null;
        for (int i = 0; i < mCacheNum; i++)
        {
            if (mLines[i] == null)
                continue;
            tmpline = mLines[i];
            tmpline.Update(_dt);
        }
    }

    public void DrawLine()
    {
        Graphics.DrawMesh(mMesh, mPos, mQua, mMat, mLayer);
    }
}

