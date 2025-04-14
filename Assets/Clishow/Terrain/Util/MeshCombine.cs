using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public interface IFastPool
{
    int poolIndex { get;set;}
    void OnReset();
}

public class FastStack<T> : IFastPool
{
    private const int DefaultCapacity = 8;
    public T[] innerArray;
    public int Count = 0;
    public int Capacity;
    public FastStack()
    {
        Capacity = DefaultCapacity;
        Initialize();
    }

    private void Initialize()
    {
        innerArray = new T[Capacity];
    }

    public void Add(T item)
    {
        EnsureCapacity();
        innerArray[Count++] = item;
    }

    public T Pop()
    {
        return (innerArray[--Count]);
    }

    public T Peek()
    {
        return innerArray[Count - 1];
    }

    private void EnsureCapacity()
    {
        EnsureCapacity(Count + 1);
    }

    public void EnsureCapacity(int min)
    {
        if (Capacity < min)
        {
            Capacity *= 2;
            if (Capacity < min)
                Capacity = min;
            T[] newItems = new T[Capacity];
            System.Array.Copy(innerArray, 0, newItems, 0, Count);
            innerArray = newItems;
        }
    }

    public void Clear()
    {
        innerArray = new T[Capacity];
    }

    public void FastClear()
    {
        Count = 0;
    }

    public int poolIndex { get;set;}

    public void OnReset()
    {
        FastClear();
    }
}

public class FastPool<T> where T:class, IFastPool, new()
{
    public T[] innerArray;

    public bool[] arrayAllocation;

    private int Capacity = 8;

    public int Count { get; private set; }

    public int PeakCount;

    private FastStack<int> OpenSlots = new FastStack<int>();

    public FastPool()
    {
        Initialize();
    }
    public FastPool(int capacity)
    {
        this.Capacity = capacity;
        Initialize();
    }

    private void Initialize()
    {
        innerArray = new T[Capacity];
        arrayAllocation = new bool[Capacity];
        Count = 0;
        PeakCount = 0;
    }


    public T Claim()
    {
        int index = OpenSlots.Count > 0 ? OpenSlots.Pop() : PeakCount++;
        return this._ClaimAt(index);
    }

    public T _ClaimAt(int index)
    {
        CheckCapacity(index + 1);
        arrayAllocation[index] = true;
        if(innerArray[index] == null)
        {
            innerArray[index] = new T ();
            innerArray[index].poolIndex = index;
            
        }
        Count++;
        innerArray[index].OnReset();
        return innerArray[index];
        
    }

    private void CheckCapacity(int min)
    {
        if (min >= Capacity)
        {
            Capacity *= 2;
            if (Capacity < min)
                Capacity = min;
            System.Array.Resize(ref innerArray, Capacity);
            System.Array.Resize(ref arrayAllocation, Capacity);
        }
    }

    public bool Release(T item)
    {
        int index = item.poolIndex;
        if (index >= 0 && arrayAllocation[index])
        {
            ReleaseAt(index);
            return true;
        }
        return false;
    }

    public void ReleaseAt(int index)
    {
        OpenSlots.Add(index);
        arrayAllocation[index] = false;
        Count--;
    }


    public void Destroy()
    {
        innerArray = null;
        FastClear();
    }


    public void FastClear()
    {
        System.Array.Clear(arrayAllocation, 0, Capacity);
        OpenSlots.FastClear();
        PeakCount = 0;
        Count = 0;
    }
}

public class StackCombineInt
{
    private int mMax;
    private int mNow;
    private int[] mValue;

    public int Max { get { return mMax; } }

    public int this[int i] { get { return mValue[i]; } }

    public StackCombineInt(int max)
    {
        mMax = max;
        mValue = new int[max];
        mNow = -1;
    }

    public void Push(int value)
    {
        if (mNow >= mMax)
            return;
        if (mNow != mMax - 1)
            mNow++;
        mValue[mNow] = value;
    }

    public int Pop()
    {
        if (mNow < 0)
            return -1;
        int v = mValue[mNow];
        mValue[mNow] = -1;
        mNow--;
        return v;
    }

    public void Clear()
    {
        mNow = -1;
    }

    public int Count
    {
        get
        {
            return mNow + 1;
        }
    }

    public void Destroy()
    {
        mMax = -1;
        mValue = null;
        mNow = -1;
    }

}

public class MeshCombine
{
    //private Mesh mSMesh;
    private Material mSMat;
    private Material mShadowMat;

    private Vector3[] mSVertexs;
    private Vector3[] mSNormals;
    private Vector2[] mSUVs;
    private int[] mSIndexs;
    private Color[] mSColors;
    private int mVCount;
    private int mICount;

    private Vector3[] mVertexs;
    private Vector3[] mNormals;
    private Vector2[] mUVs;
    private int[] mIndexs;
    private Color[] mColors;

    private Mesh mResultMesh;
    private bool mNeedUpdateMesh = false;

    public bool NeedUpdateMesh
    {
        get
        {
            return mNeedUpdateMesh;
        }
    }
    private TerrainSpriteData[] mPushObjPoints = null;
    private int[] mPushObjMeshIndex;
    private StackCombineInt mValidFlags;
    private float mDSize;
    private int mLayer;
    private Vector3 mPos;
    private Quaternion mQuat;
    private int mMaxCount;
    private int mValidCount;


    public Mesh ResultMesh
    {
        get
        {
            return mResultMesh;
        }
    }

    public Material Mat
    {
        get
        {
            return mSMat;
        }
    }

    public int VCount
    {
        get
        {
            return mVCount;
        }
    }

    public MeshCombine(Mesh mesh, Material mat, float size, int layer, int max_count, int max_v)
    {
        mPos = Vector3.zero;
        mQuat = Quaternion.identity;
        mLayer = layer;
        mDSize = size;
        //mSMesh = mesh;
        mSMat = mat;
        mShadowMat = new Material(Shader.Find("ShadowReplace"));
        mSVertexs = mesh.vertices;
        mVCount = mSVertexs.Length;
        mSNormals = mesh.normals;
        mSUVs = mesh.uv;
        mSIndexs = mesh.triangles;
        mICount = mSIndexs.Length;
        mSColors = mesh.colors;
        mMaxCount = max_count;

        int v = mMaxCount * mVCount;
        if (v >= max_v)
        {
            mMaxCount = Mathf.Max(max_v, mVCount) / mVCount;
            v = mMaxCount * mVCount;
        }
        mPushObjPoints = new TerrainSpriteData[mMaxCount];
        mPushObjMeshIndex = new int[mMaxCount];
        mValidFlags = new StackCombineInt(mMaxCount);
        for (int j = 0; j < mMaxCount; j++)
        {
            mValidFlags.Push(j);
        }
        if (mSColors == null || mSColors.Length != mVCount)
            mSColors = new Color[mVCount];
        mResultMesh = new Mesh();
        mResultMesh.name = "[3DT]" + mesh.name + "_CM_Mesh";

        int i = mMaxCount * mICount;

        mVertexs = new Vector3[v];
        mNormals = new Vector3[v];
        mUVs = new Vector2[v];
        mIndexs = new int[i];
        mColors = new Color[v];

        for (int j = 0; j < mMaxCount; j++)
        {
            System.Array.Copy(mSNormals, 0, mNormals, j * mVCount, mVCount);
            System.Array.Copy(mSUVs, 0, mUVs, j * mVCount, mVCount);
            int start = j * mICount;
            for (int k = 0; k < mICount; k++)
            {
                mIndexs[start + k] = mSIndexs[k] + j * mVCount;
            }
        }
        mResultMesh.vertices = mVertexs;
        mResultMesh.normals = mNormals;
        mResultMesh.uv = mUVs;
        mResultMesh.triangles = mIndexs;
        mResultMesh.colors = mColors;
        //mResultMesh.MarkDynamic();

        //Resources.UnloadAsset(mesh);
        //mVertexs = null;
        //mIndexs = null;
        mUVs = null;
        mNormals = null;
        mColors = null;
        mValidCount = 0;
        mNeedUpdateMesh = false;
    }

    public void Clear()
    {
        mResultMesh.Clear();
        if (mValidFlags.Count != mMaxCount)
        {
            for (int i = 0; i < mValidCount; i++)
            {
                if (mPushObjPoints[i] != null)
                    mPushObjPoints[i] = null;
            }
        }
        mPushObjPoints = null;
        mNeedUpdateMesh = false;

    }

    public static void UpdateMeshBounds(Mesh mesh, Vector3 center, float size)
    {
        Bounds bounds = mesh.bounds;
        Vector3 tmp = Vector3.zero;
        tmp.x = size * 2;
        tmp.z = size * 2;
        bounds.size = tmp;
        tmp.x = size * -1 + center.x;
        tmp.z = size * -1 + center.z;
        bounds.min = tmp;
        tmp.x = size + center.x;
        tmp.z = size + center.z;
        bounds.max = tmp;
        mesh.bounds = bounds;
    }

    public int PushObjPoint(TerrainSpriteData data)
    {
        int index = mValidFlags.Pop();
        if (index < 0)
            return -1;
        mPushObjPoints[index] = data;
        mNeedUpdateMesh = true;
        return index;
    }

    public int PushObjPoint()
    {
        int index = mValidFlags.Pop();
        if (index < 0)
            return -1;
        mNeedUpdateMesh = true;
        return index;
    }

    public void PopObjPoint(int index)
    {
        if (index < 0)
            return;
        if (mPushObjPoints[index] != null)
        {
            HideObj(index);
            if (mPushObjPoints[index] != null)
                mPushObjPoints[index].ChunkIndex = -1;
            mPushObjPoints[index] = null;
            mValidFlags.Push(index);
            mNeedUpdateMesh = true;
        }
    }

    public void PopObjPointNoData(int index)
    {
        if (index < 0)
            return;
        HideObj(index);
        mValidFlags.Push(index);
        mNeedUpdateMesh = true;
    }

    public void HideObj(int index)
    {
        if (mColors == null)
            mColors = mResultMesh.colors;
        int start_v = index * mVCount;
        for (int j = 0; j < mVCount; j++)
        {
            ctmp = mColors[start_v + j];
            ctmp.a = 0;
            mColors[start_v + j] = ctmp;
        }
    }

    public void Combine(int index, float offsetx, float offsety, float offsetz)
    {
        int i = index;
        if (i < 0)
            return;
        if (mVertexs == null)
            mVertexs = mResultMesh.vertices;
        if (mColors == null)
            mColors = mResultMesh.colors;

        int start_v = i * mVCount;
        int start_i = i * mICount;
        for (int j = 0; j < mVCount; j++)
        {
            tmp.x = mSVertexs[j].x * mDSize + offsetx;
            tmp.y = mSVertexs[j].y * mDSize + offsety;
            tmp.z = mSVertexs[j].z * mDSize + offsetz;
            mVertexs[start_v + j] = tmp;
            ctmp.r = mSColors[j].r;
            ctmp.g = mSColors[j].g;
            ctmp.b = mSColors[j].b;
            ctmp.a = 1;
            mColors[start_v + j] = ctmp;
        }
    }

    public void Combine(TerrainSpriteData data, int index, float offsetx, float offsety)
    {
        if (data == null) return;
        int i = index;
        if (i < 0)
            return;
        if (mVertexs == null)
            mVertexs = mResultMesh.vertices;
        if (mColors == null)
            mColors = mResultMesh.colors;
        int start_v = i * mVCount;
        int start_i = i * mICount;
        for (int j = 0; j < mVCount; j++)
        {
            tmp.x = mSVertexs[j].x * mDSize * data.scale + data.wPos.x + offsetx;
            tmp.y = mSVertexs[j].y * mDSize * data.scale;//+ data.wPos.y;
            tmp.z = mSVertexs[j].z * mDSize * data.scale + data.wPos.z + offsety;
            mVertexs[start_v + j] = tmp;
            ctmp.r = mSColors[j].r + data.Color.r;
            ctmp.g = mSColors[j].g + data.Color.g;
            ctmp.b = mSColors[j].b + data.Color.b;
            ctmp.a = 1;
            mColors[start_v + j] = ctmp;
        }
    }

    static Vector3 tmp = Vector3.zero;
    static Color ctmp = Color.white;
    public void Combine()
    {

        if (mValidFlags.Count == mMaxCount)
            return;
        if (mVertexs == null)
            mVertexs = mResultMesh.vertices;
        if (mColors == null)
            mColors = mResultMesh.colors;
        TerrainSpriteData data;
        for (int i = 0; i < mMaxCount; i++)
        {
            if (mPushObjPoints[i] == null)
            {
                continue;
            }
            int start_v = i * mVCount;
            int start_i = i * mICount;
            data = mPushObjPoints[i];
            for (int j = 0; j < mVCount; j++)
            {
                tmp.x = mSVertexs[j].x * mDSize * data.scale + data.wPos.x;
                tmp.y = mSVertexs[j].y * mDSize * data.scale;//+ data.wPos.y;
                tmp.z = mSVertexs[j].z * mDSize * data.scale + data.wPos.z;
                mVertexs[start_v + j] = tmp;
                ctmp.r = mSColors[j].r + data.Color.r;
                ctmp.g = mSColors[j].g + data.Color.g;
                ctmp.b = mSColors[j].b + data.Color.b;
                ctmp.a = mSColors[j].a + data.Color.a;
                mColors[start_v + j] = ctmp;
            }
        }
    }

    public void UpdateMesh(Vector3 center, float bsize, bool fast = false)
    {
        if (mValidFlags.Count == mMaxCount)
            return;
        if (fast)
        {
            mResultMesh.colors = mColors;
            return;
        }

        if (mVertexs != null)
            mResultMesh.vertices = mVertexs;
        //mResultMesh.normals = mNormals;
        //mResultMesh.uv = mUVs;
        if (mColors != null)
            mResultMesh.colors = mColors;
        //mResultMesh.triangles = mIndexs;
        if (mVertexs != null || mColors != null)
            UpdateMeshBounds(mResultMesh, center, bsize);
    }

    public void ClearCached()
    {
        mVertexs = null;
        mColors = null;
    }

    public void DontNeedUpdateMesh()
    {

        mNeedUpdateMesh = false;
    }

    public void DrawMesh()
    {
        if (mValidFlags.Count == mMaxCount)
        {
            return;
        }
        Graphics.DrawMesh(mResultMesh, mPos, mQuat, Mat, mLayer);
    }

    public void DrawMeshNow()
    {
        if (mValidFlags.Count == mMaxCount || mLayer == 0)
        {
            return;
        }
        mShadowMat.SetPass(0);
        Graphics.DrawMeshNow(mResultMesh, mPos, mQuat);
    }

    public void Destroy()
    {
        mPos = Vector3.zero;
        mQuat = Quaternion.identity;
        //mSMesh = null;
        mSMat = null;
        GameObject.Destroy(mShadowMat);
        mSVertexs = null;
        mSNormals = null;
        mSUVs = null;
        mSIndexs = null;
        mSColors = null;
        mPushObjPoints = null;
        mPushObjMeshIndex = null;
        mValidFlags.Destroy();
        mValidFlags = null;
        mVertexs = null;
        mNormals = null;
        mUVs = null;
        mIndexs = null;
        mColors = null;

        mValidCount = 0;
        mNeedUpdateMesh = false;
    }
}
