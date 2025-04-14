using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public struct SMCConfig
{
    public int index;
    public string smc_asset_name;
}

public static class SMCHelper
{
    public static void ReadCfgFile(World world,string file_name)
    {
        if (world == null || world.SMC == null)
            return;
        if (string.IsNullOrEmpty(file_name))
            return;

        Transform node = world.transform.Find("Canvas");
        TextAsset cfg_file = ResourceLibrary.instance.GetWorldTerrainAsset<TextAsset>(file_name);
        if (cfg_file == null)
            return;
        if (string.IsNullOrEmpty(cfg_file.text))
            return;

        string[] lines = cfg_file.text.Split('\n');
        string[] param;
        List<SMCConfig> smcc = new List<SMCConfig>();
        Dictionary<int, SkinMeshCombine> smc_map = new Dictionary<int, SkinMeshCombine>();
        int index;
        for (int i = 0, imax = lines.Length; i < imax; i++)
        {
            param = lines[i].Split(',');
            if (param.Length == 2)
            {
                if (!int.TryParse(param[0], out index))
                    continue;
                SMCConfig cfg = new SMCConfig();
                cfg.index = index;
                cfg.smc_asset_name =  param[1].Replace("\r","");
                smcc.Add(cfg);
            }
        }
        if (smcc.Count == 0)
            return;
        GameObject obj;
        int target_max = world.SMC.Length;
        for (int i = 0, imax = smcc.Count; i < imax; i++)
        {
            if (smcc[i].index < 0)
                continue;
            target_max = Mathf.Max(target_max, smcc[i].index+1);
            smc_map.Add(smcc[i].index,null);
            obj = ResourceLibrary.instance.GetWorldTerrainAsset<GameObject>(smcc[i].smc_asset_name);
            if (obj != null)
            {
                SkinMeshCombine smc_s = obj.GetComponent<SkinMeshCombine>();
                if (smc_s != null)
                {
                    smc_s = GameObject.Instantiate<SkinMeshCombine>(smc_s);
                    smc_s.transform.parent = node;
                    smc_s.transform.localPosition = Vector3.zero;
                    smc_s.transform.localRotation = Quaternion.identity;
                    smc_s.transform.localScale = Vector3.one;
                    smc_map[smcc[i].index] = smc_s;
                }
            }
        }
        List<SkinMeshCombine> new_smc = new List<SkinMeshCombine>();
        SkinMeshCombine smc = null;
        for (int i = 0; i < target_max; i++)
        {
            if (smc_map.TryGetValue(i, out smc))
            {
                new_smc.Add(smc);
            }
            else
            {
                new_smc.Add(null);
                if (i < world.SMC.Length)
                {
                    new_smc[i] = world.SMC[i];
                }
            }
        }
        world.SMC = new_smc.ToArray();
    }
}
    

public class SMSource
{
    private Mesh mMesh;
    private string name;
    private Vector3[] mVs;
    private int[] mTs;
    private Vector3[] mNs;
    private Vector2[] mUs;

    private BoneWeight[] mBs;
    private Matrix4x4[] mBps;

    private int mVCount;
    private int mTCount;
    private int mBCount;

    public string Name { get { return name; } }
    public int VCount { get { return mVCount; } }
    public int TCount { get { return mTCount; } }
    public int BCount { get { return mBCount; } }
    public Vector3[] Vs
    {
        get
        {
            if (mVs == null)
            {
                mVs = mMesh.vertices;
            }

            return mVs;
        }
    }
    public int[] Ts
    {
        get
        {
            if (mTs == null)
            {
                mTs = mMesh.triangles;
            }

            return mTs;
        }
    }
    public Vector3[] Ns
    {
        get
        {
            if (mNs == null)
            {
                mNs = mMesh.normals;
            }

            return mNs;
        }
    }
    public Vector2[] Us
    {
        get
        {
            if (mUs == null)
            {
                mUs = mMesh.uv;
            }

            return mUs;
        }
    }
    public BoneWeight[] Bs
    {
        get
        {
            if (mBs == null)
            {
                mBs = mMesh.boneWeights;
            }
            return mBs;
        }
    }
    public Matrix4x4[] Bps
    {
        get
        {
            if (mBps == null)
            {
                mBps = mMesh.bindposes;
            }
            return mBps;
        }
    }

    public SMSource(Mesh mesh)
    {
        mMesh = mesh;
        name = mMesh.name;
        //mVs = mesh.vertices;
        //mTs = mesh.triangles;
        //mNs = mesh.normals;
        //mUs = mesh.uv;
        //mBs = mesh.boneWeights;
        //mBps = mesh.bindposes;
        mVCount = mMesh.vertexCount;// mVs.Length;
        mTCount = mMesh.triangles.Length;
        mBCount = mMesh.bindposes.Length;
        //Resources.UnloadAsset(mesh);
    }

    public void ClearCache()
    {
        mVs = null;
        mTs = null;
        mNs = null;
        mUs = null;
        mBs = null;
        mBps = null;
    }
}
[System.Serializable]
public class SMSourceMgr
{
    public SMCInfo[] SMPerfabs;
    public Mesh[] Meshs;
    public Material Mat;
    private SMSource[] mSource;

    public void Init()
    {
        mSource = new SMSource[Meshs.Length];
        for (int i = 0; i < mSource.Length; i++)
        {
            if (Meshs[i] == null)
            {
                Debug.LogError("Misss " + i + "  " + Mat.name);
                Debug.LogError("Misss " + SMPerfabs[i].name);
            }
            LoadSource(i);
        }
    }

    private void LoadSource(int i)
    {
        mSource[i] = new SMSource(Meshs[i]);
    }

    public SMSource this[int i]
    {
        get
        {
            if (mSource[i] == null)
            {
                LoadSource(i);
            }
            return mSource[i];
        }
    }

    public void ClearSourceCache()
    {
        for (int i = 0; i < mSource.Length; i++)
        {
            mSource[i].ClearCache();
        }
    }
}

public enum InsState
{
    IS_ADD,
    IS_UPDATA,
    IS_NIL,
}

public class SMIns
{
    private SMSource mSource;
    private Vector3 mWpos;
    private Vector3 mSize;
    private int mVIndex;
    private int mTIndex;
    private int mBIndex;
    private bool mVaild;
    private int mIndex;
    private InsState mState = InsState.IS_NIL;
    private Transform[] mBones;

    public Vector3 Wpos { get { return mWpos; } }
    public Vector3 Size { get { return mSize; } }
    public int VIndex { get { return mVIndex; } }
    public int TIndex { get { return mTIndex; } }
    public int BIndex { get { return mBIndex; } }
    public bool Vaild { get { return mVaild; } }
    public int Index { get { return mIndex; } }
    public InsState State { get { return mState; } set { mState = value; } }
    public SMSource Source { get { return mSource; } }
    public Transform[] Bones { get { return mBones; } }

    public void SetIndex(int vindex, int tindex, out int new_vindex, out int new_tindex)
    {
        if (mVIndex != vindex || mTIndex != tindex)
            mState = InsState.IS_UPDATA;
        mVIndex = vindex;
        mTIndex = tindex;
        mBIndex = -1;
        new_vindex = mVIndex + mSource.VCount;
        new_tindex = mTIndex + mSource.TCount;
    }

    public void SetIndex(int vindex, int tindex, int bindex, out int new_vindex, out int new_tindex, out int new_bindex)
    {
        if (mVIndex != vindex || mTIndex != tindex || mBIndex != bindex)
            mState = InsState.IS_UPDATA;
        mVIndex = vindex;
        mTIndex = tindex;
        mBIndex = bindex;
        new_vindex = mVIndex + mSource.VCount;
        new_tindex = mTIndex + mSource.TCount;
        new_bindex = mBIndex + mSource.BCount;
    }

    public void ResetState()
    {
        mState = InsState.IS_NIL;
    }

    public void Init(int index, SMSource source, SkinnedMeshRenderer smr)
    {
        mIndex = index;
        mSource = source;
        mState = InsState.IS_ADD;
        mVaild = true;
        if (smr != null && mSource.BCount == smr.bones.Length)
        {
            mBones = smr.bones;
        }
    }

    //public void Init(int index, SMSource source, Vector3 wpos, Vector3 size)
    //{
    //    mIndex = index;
    //    mSource = source;
    //    mWpos = wpos;
    //    mSize = size;
    //    mState = InsState.IS_ADD;
    //    mVaild = true;
    //    mBones = null;
    //}

    public void Clear()
    {
        mBones = null;
        ResetState();
        mIndex = -1;
        mVaild = false;
        mSource = null;
    }

    public SMIns()
    {
        Clear();
    }
}
[System.Serializable]
public struct CacheDetails
{
    public int ComSize;
    public int PoolSize;
    public int CacheSize;
    public int VCount;
    public int TCount;
    public int BCount;
}

public class SMCombiner
{
    private SMSourceMgr mSMgr;
    private SMIns[] mInsPool;
    private int mCacheSize;
    private int mVTotalCount;
    private int mTTotalCount;
    private int mBTotalCount;
    private SMIns[] mCurInses;
    private Material mMat;
    private SkinnedMeshRenderer mSmr;
    private string mName;
    private Mesh mMesh;
    private Vector3[] mVs;
    private int[] mTs;
    private Vector3[] mNs;
    private Vector2[] mUs;

    private BoneWeight[] mBs;
    private Matrix4x4[] mBps;
    private Transform[] mBones;

    private StackCombineInt mValidFlags;
    private bool mNeedApply;
    private bool mNeedUpdateMesh;
    private Vector3 tmp;

    public Mesh Mesh { get { return mMesh; } }
    private bool mCached = true;

    public SMCombiner(SMSourceMgr mgr, Transform root, CacheDetails details, int layer, WorldData world, bool cached = true)
    {

        mSMgr = mgr;
        mName = mSMgr.Mat.name;
        mMat = mSMgr.Mat;
        if (!world.world.SupportShadow && world.HadShadowNames.Contains(mMat.shader.name))
        {
            mMat = new Material(mMat);
            mMat.shader = Shader.Find(mMat.shader.name + " no Shadow");
        }
        mCacheSize = details.CacheSize;
        mVTotalCount = mCacheSize * details.VCount;
        mTTotalCount = mCacheSize * details.TCount;
        mBTotalCount = mCacheSize * details.BCount;
        mInsPool = new SMIns[mCacheSize];
        mCurInses = new SMIns[mCacheSize];
        mValidFlags = new StackCombineInt(mCacheSize);
        for (int j = 0; j < mCacheSize; j++)
        {
            mValidFlags.Push(j);
        }
        if (mCached)
        {
            mVs = new Vector3[mVTotalCount];
            mNs = new Vector3[mVTotalCount];
            mTs = new int[mTTotalCount];
            mUs = new Vector2[mVTotalCount];
            mBs = new BoneWeight[mVTotalCount];
            mBps = new Matrix4x4[mBTotalCount];
            mBones = new Transform[mBTotalCount];
        }


        mMesh = new Mesh();
        mMesh.name = "[3DT]" + mName + "_SM_Mesh";
        mNeedApply = false;
        mNeedUpdateMesh = false;




        GameObject obj = new GameObject("SMC_" + mName);
        obj.layer = layer;
        obj.transform.parent = root;
        obj.transform.localPosition = Vector3.zero;
        obj.transform.localScale = Vector3.one;
        mSmr = obj.AddComponent<SkinnedMeshRenderer>();
        mSmr.material = mMat;

        mSmr.updateWhenOffscreen = true;

        if (!mCached)
        {
            mMesh.vertices = new Vector3[mVTotalCount];
            mMesh.normals = new Vector3[mVTotalCount];
            mMesh.triangles = new int[mTTotalCount];
            mMesh.uv = new Vector2[mVTotalCount];
            mMesh.boneWeights = new BoneWeight[mVTotalCount];
            mMesh.bindposes = new Matrix4x4[mBTotalCount];
            mSmr.bones = new Transform[mBTotalCount];
        }

    }

    public int Push(int source_index, SkinnedMeshRenderer smr)
    {
        int index = mValidFlags.Pop();
        if (index < 0)
            return -1;
        if (mInsPool[index] == null)
        {
            mInsPool[index] = new SMIns();
        }
        mInsPool[index].Init(index, mSMgr[source_index], smr);
        mNeedApply = true;
        return index;
    }

    public void Pop(int index)
    {
        if (index < 0)
            return;
        if (mInsPool[index] != null && mInsPool[index].Vaild)
        {
            mInsPool[index].Clear();
            mValidFlags.Push(index);
            mNeedApply = true;
        }
    }

    public void Apply()
    {
        if (!mNeedApply)
            return;
        System.Array.Clear(mCurInses, 0, mCacheSize);
        int vi = 0;
        int iv = 0, it = 0, ib = 0;
        for (int i = 0; i < mCacheSize; i++)
        {
            if (mInsPool[i] != null && mInsPool[i].Vaild)
            {
                mCurInses[vi] = mInsPool[i];
                mCurInses[vi].SetIndex(iv, it, ib, out iv, out it, out ib);
                vi++;
            }
        }
        mNeedApply = false;
        mNeedUpdateMesh = true;
    }

    public bool UpdateMesh(Vector3 bcenter, float bsize)
    {
        if (!mNeedUpdateMesh)
            return false;
        bool UpdateMesh = false;
        for (int i = 0; i < mCacheSize; i++)
        {
            if (mCurInses[i] != null && mCurInses[i].Source != null && mCurInses[i].State != InsState.IS_NIL)
            {
                UpdateMesh = true;
                break;
            }
        }
        if (!UpdateMesh)
        {
            Debug.LogError("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ");
            return false;
        }

        int vindex = 0, tindex = 0, bindex = 0;
        int vcount = 0, tcount = 0, bcount = 0, vi = 0, ti = 0, bi = 0;
        SMSource tmps;
        SMIns tmpi;
        //Vector3 wpos, size;
        BoneWeight bw;
        Vector3[] vs;
        int[] ts;
        BoneWeight[] bws;

        if (mVs == null)
            mVs = mMesh.vertices;
        if (mNs == null)
            mNs = mMesh.normals;
        if (mTs == null)
            mTs = mMesh.triangles;
        if (mUs == null)
            mUs = mMesh.uv;
        if (mBs == null)
            mBs = mMesh.boneWeights;
        if (mBps == null)
            mBps = mMesh.bindposes;
        if (mBones == null)
            mBones = mSmr.bones;




        for (int i = 0; i < mCacheSize; i++)
        {
            if (mCurInses[i] == null || mCurInses[i].Source == null)
                break;
            try
            {
                tmpi = mCurInses[i];
                tmps = tmpi.Source;
                vcount = tmps.VCount;
                tcount = tmps.TCount;
                bcount = tmps.BCount;
                vi = tmpi.VIndex;
                ti = tmpi.TIndex;
                bi = tmpi.BIndex;
                vs = tmps.Vs;
                ts = tmps.Ts;
                bws = tmps.Bs;
                switch (tmpi.State)
                {
                    case InsState.IS_ADD:
                    case InsState.IS_UPDATA:
                        System.Array.Copy(tmps.Vs, 0, mVs, vi, vcount);
                        for (int j = 0; j < vcount; j++)
                        {
                            bw = bws[j];
                            bw.boneIndex0 = bw.boneIndex0 + bi;
                            //if (tmps.mMesh.name.Contains("panjun"))
                            //{
                            bw.boneIndex1 = bw.boneIndex1 + bi;
                            //bw.boneIndex2 = bw.boneIndex2 + bi;
                            //bw.boneIndex3 = bw.boneIndex3 + bi;
                            //}
                            mBs[vi + j] = bw;
                        }
                        System.Array.Copy(tmps.Bps, 0, mBps, bi, bcount);
                        System.Array.Copy(tmpi.Bones, 0, mBones, bi, bcount);
                        System.Array.Copy(tmps.Us, 0, mUs, vi, vcount);
                        System.Array.Copy(tmps.Ns, 0, mNs, vi, vcount);
                        for (int j = 0; j < tcount; j++)
                        {
                            mTs[ti + j] = ts[j] + vi;
                        }
                        break;
                }
                vindex += vcount;
                tindex += tcount;
                bindex += bcount;
                mCurInses[i].ResetState();
            }
            catch (System.Exception e)
            {
                Debug.LogError("WWWWWWWWWWWWWWWWWWWWorld 緩存出錯 " + mCurInses[i].Source.Name);
            }
        }
        int vl = mVTotalCount - vindex;
        if (vl > 0)
        {
            System.Array.Clear(mVs, vindex, vl);
            System.Array.Clear(mNs, vindex, vl);
            System.Array.Clear(mUs, vindex, vl);
            System.Array.Clear(mBs, vindex, vl);
        }
        int tl = mTTotalCount - tindex;
        if (tl > 0)
        {
            System.Array.Clear(mTs, tindex, tl);
        }
        int bl = mBTotalCount - bindex;
        if (bl > 0)
        {
            System.Array.Clear(mBps, bindex, bl);
            System.Array.Clear(mBones, bindex, bl);
        }

        mMesh.vertices = mVs;
        mMesh.normals = mNs;
        mMesh.triangles = mTs;
        mMesh.uv = mUs;

        mMesh.boneWeights = mBs;
        mMesh.bindposes = mBps;
        mSmr.bones = mBones;

        MeshCombine.UpdateMeshBounds(mMesh, bcenter, bsize);
        if (mSmr.sharedMesh == null)
            mSmr.sharedMesh = mMesh;
        if (vindex > 0)
        {
            Bounds b = new Bounds(mMesh.bounds.center, mMesh.bounds.size);
            mSmr.localBounds = b;
        }



        mNeedUpdateMesh = false;
        return true;
    }

    public void ClearCache()
    {
        if (!mCached)
        {
            mVs = null;
            mNs = null;
            mTs = null;
            mUs = null;
            mBs = null;
            mBps = null;
            mBones = null;
        }
    }
}

public class SMCInfoPool
{
    private SMCInfo[] mPool;
    private int mSize;
    private SMCInfo mPerfab;
    private SMCInfo mTmpIns;
    private StackCombineInt mValidFlags;
    private int mIndex;
    private Transform mRoot;
    public SMCInfoPool(int index, SMCInfo perfab, int size, Transform trf)
    {
        mRoot = trf;
        mIndex = index;
        mValidFlags = new StackCombineInt(size);
        for (int i = 0; i < size; i++)
        {
            mValidFlags.Push(i);
        }
        mPerfab = perfab;
        mSize = size;
        mPool = new SMCInfo[mSize];
    }

    public SMCInfo Claim(WorldHUDType hudType, int dataIndex)
    {
        int index = mValidFlags.Pop();
        if (index < 0)
            return null;

        mTmpIns = mPool[index];

        if (mTmpIns == null)
        {
            mTmpIns = GameObject.Instantiate<SMCInfo>(mPerfab);
            mTmpIns.Clear();
            mTmpIns.trf.parent = mRoot;
            mTmpIns.indexPool = index;
            mTmpIns.poolID = mIndex;
            if (mTmpIns.LowShadow != null)
            {
                if (GameSetting.instance.option.mQualityLevel >= 1)
                    mTmpIns.LowShadow.gameObject.SetActive(false);
                else
                    mTmpIns.LowShadow.gameObject.SetActive(true);
            }

            GameObject go = new GameObject("HUD");

            go.transform.parent = mTmpIns.transform;
            go.transform.localPosition = Vector3.zero;
            go.transform.rotation = Quaternion.Euler(0, 0, 0);

            mTmpIns.HUD = go.AddComponent<WorldHUDMgr>();
            mTmpIns.HUD.InitializeHUD(hudType, dataIndex);

            mTmpIns.Reset();

            mPool[index] = mTmpIns;
        }
        else
        {
            mTmpIns.HUD.Show(); // 触发 Awake()
            mTmpIns.HUD.RefreshHUD(hudType, dataIndex);
            mTmpIns.HUD.Hide();
        }

        return mTmpIns;
    }

    public void Release(SMCInfo info)
    {
        if (info.indexPool < 0)
            return;
        mValidFlags.Push(info.indexPool);
        mPool[info.indexPool].Reset();
    }

    public int CountInPool
    {
        get
        {
            return mValidFlags.Count;
        }
    }

    public void ClearMeshCombineInPool(ref SMCombiner[] combiners)
    {
        for (int i = 0; i < mPool.Length; i++)
        {
            mTmpIns = mPool[i];
            if (mTmpIns != null && mTmpIns.indexCombiner >= 0 && !mTmpIns.isValid)
            {
                int index = mTmpIns.indexCombiner;
                combiners[index].Pop(mTmpIns.index);
                mTmpIns.ClearRenderInfo();
            }
        }
    }

    public void Clear()
    {
        for (int i = 0; i < mSize; i++)
        {
            mPool[i] = null;
        }
        mPool = null;
    }
}

public class SkinMeshCombine : MonoBehaviour
{
    public string LayerName;
    public bool Cached = true;
    public CacheDetails Details;
    public SMSourceMgr SourceMap;
    private SMCombiner[] mCombiners;
    private SMCInfoPool[] mPool;
    private Transform mTrf;
    public Transform trf
    {
        get
        {
            if (mTrf == null)
                mTrf = this.transform;
            return mTrf;
        }
    }
    private SMCInfo mTmp;
    private WorldData mWorld;
    private int mLayer;

    public void Init(WorldData world)
    {
        mLayer = LayerMask.NameToLayer(LayerName);
        mWorld = world;
        SourceMap.Init();
        mPool = new SMCInfoPool[SourceMap.SMPerfabs.Length];
        for (int i = 0; i < SourceMap.SMPerfabs.Length; i++)
        {
            mPool[i] = new SMCInfoPool(i, SourceMap.SMPerfabs[i], Details.PoolSize, trf);
        }
        mCombiners = new SMCombiner[Details.ComSize];
    }

    public SMCInfo Push(int source_index, Vector3 wpos, WorldHUDType hudType, int dataIndex, bool auto_clear = true)
    {
        mTmp = mPool[source_index].Claim(hudType, dataIndex);
        if (mTmp == null)
            return null;
        if (mTmp.indexCombiner >= 0)
        {
            mTmp.trf.position = wpos;
            mTmp.Active();
            mTmp.isValid = true;
            return mTmp;
        }

        int index = -1;
        for (int i = 0; i < Details.ComSize; i++)
        {
            if (mCombiners[i] == null)
            {
                mCombiners[i] = new SMCombiner(SourceMap, mTrf, Details, mLayer, mWorld, Cached);
            }
            index = mCombiners[i].Push(source_index, mTmp.smr);
            if (index >= 0)
            {
                mTmp.index = index;
                mTmp.indexCombiner = i;
                //wpos.y += mWorld.world.Build_Offset_Height;
                mTmp.trf.position = wpos;
                mTmp.Active();
                mTmp.isValid = true;
                break;
            }
        }
        if (index >= 0)
            return mTmp;
        mPool[source_index].Release(mTmp);
        mTmp = null;
        if (auto_clear)
        {
            AutoClearMeshCombinerCache();
            mTmp = Push(source_index, wpos, hudType, dataIndex, false);
        }
        return mTmp;
    }


    public void AutoClearMeshCombinerCache()
    {
        for (int i = 0; i < mPool.Length; i++)
        {
            mPool[i].ClearMeshCombineInPool(ref mCombiners);
        }
    }

    public void Pop(SMCInfo info)
    {
        try
        {
            mPool[info.poolID].Release(info);
        }
        catch (System.Exception e)
        {
            Debug.LogError(e.ToString());
        }
    }

    public void Apply()
    {
        for (int i = 0; i < Details.ComSize; i++)
        {
            if (mCombiners[i] != null)
            {
                mCombiners[i].Apply();
            }
        }
    }

    public void UpdateSMC(Vector3 bcenter, float bsize)
    {
        for (int i = 0; i < Details.ComSize; i++)
        {

            if (mCombiners[i] != null)
            {
                if (mCombiners[i].UpdateMesh(bcenter, bsize))
                    break;
            }

        }

    }

    public void ClearCache()
    {
        for (int i = 0; i < Details.ComSize; i++)
        {
            if (mCombiners[i] != null)
            {
                mCombiners[i].ClearCache();
            }
        }
        SourceMap.ClearSourceCache();
    }


}