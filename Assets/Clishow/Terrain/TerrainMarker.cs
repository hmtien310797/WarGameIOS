using System;
using System.Collections.Generic;
using UnityEngine;

public class TerrainBorderMarker
{
    private float mMarkerTypeCount = 64;
    private Texture2D mTexAtlas;
    private Texture2D mMarkerTex;
    private Color32[] mMarkerColors;
    private Vector4 mMarkerSetting;
    private bool mNeedApply;
    private WorldData mWorld;
    private int mMarkerWidth;
    public TerrainBorderMarker(WorldData world)
    {
        mWorld = world;
        mMarkerTypeCount = world.MarkerTypeCount;
        mTexAtlas = world.BorderMarkerTex;
        mMarkerWidth = (mWorld.LogicWCount) * 3;
        mMarkerTex = new Texture2D(mMarkerWidth, mMarkerWidth, TextureFormat.ARGB32, false, false);
        mMarkerTex.filterMode = FilterMode.Point;

        mMarkerColors = new Color32[mMarkerWidth * mMarkerWidth];
        mMarkerTex.SetPixels32(mMarkerColors);
        mMarkerTex.Apply();
        mMarkerSetting = new Vector4(4, 4, mMarkerWidth, mWorld.LogicBlockSize / 3);
        mNeedApply = false;
        InitShaderParam();
        UpdateShaderParam();
    }

    private void InitShaderParam()
    {
        Shader.SetGlobalVector("_BorderMarkerSettings", mMarkerSetting);
        Shader.SetGlobalTexture("_BorderMarkersGraphic", mTexAtlas);
    }

    private void UpdateShaderParam()
    {
        Shader.SetGlobalTexture("_BorderMarkersPositionData", mMarkerTex);
    }

    public void ClearAllMarkers()
    {
        mMarkerTex.SetPixels32(mMarkerColors);
        mNeedApply = true;
    }

    public void SetMarkerType(Vec2Int logic_lpos)
    {
        int lx, ly;
        Color c;
        for (int y = -1; y < 2; y++)
        {
            for (int x = -1; x < 2; x++)
            {
                lx = logic_lpos.x * 3 + x + 1;
                ly = logic_lpos.y * 3 + y + 1;
                c.r = 0;
                c.g = 0;
                c.b = 0;
                c.a = 0;
                mMarkerTex.SetPixel(lx, ly, c);
            }
        }
        mNeedApply = true;
    }

    public void SetMarkerType(Vec2Int logic_lpos, int[] itypes, Color b_color)
    {
        int lx, ly, index;
        Color c;
        for (int y = -1; y < 2; y++)
        {
            for (int x = -1; x < 2; x++)
            {
                lx = logic_lpos.x * 3 + x + 1;
                ly = logic_lpos.y * 3 + y + 1;
                c.r = b_color.r;
                c.g = b_color.g;
                c.b = b_color.b;
                c.a = itypes[(y + 1) * 3 + (x + 1)] / mMarkerTypeCount;
                mMarkerTex.SetPixel(lx, ly, c);
            }
        }
        mNeedApply = true;
    }

    public void Update()
    {
        if (!mNeedApply)
            return;
        mMarkerTex.Apply();
        UpdateShaderParam();
        mNeedApply = false;
    }

    public void Destroy()
    {
        mWorld = null;
        mTexAtlas = null;
        mMarkerColors = null;
        if (mMarkerTex != null)
            GameObject.Destroy(mMarkerTex);
        mMarkerTex = null;
    }
}

public class TerrainBorderMarkerBox
{
    private readonly static float BS_R = (1.0f) / 6.0f;
    //
    // --1--4--6--
    // --2-- --7--
    // --3--5--8--
    //
    private readonly static Vector3[] BS_Vs = new Vector3[] {
                                                           //-------1--------------
                                                           new Vector3(BS_R*-3,0,BS_R),
                                                           new Vector3(BS_R*-1,0,BS_R),
                                                           new Vector3(BS_R*-1,0,BS_R*3),
                                                           new Vector3(BS_R*-3,0,BS_R*3),
                                                           //-------2--------------
                                                           new Vector3(BS_R*-3,0,BS_R*-1),
                                                           new Vector3(BS_R*-1,0,BS_R*-1),
                                                           new Vector3(BS_R*-1,0,BS_R*1),
                                                           new Vector3(BS_R*-3,0,BS_R*1),
                                                           //-------3--------------
                                                           new Vector3(BS_R*-3,0,BS_R*-3),
                                                           new Vector3(BS_R*-1,0,BS_R*-3),
                                                           new Vector3(BS_R*-1,0,BS_R*-1),
                                                           new Vector3(BS_R*-3,0,BS_R*-1),
                                                           //-------4--------------
                                                           new Vector3(BS_R*-1,0,BS_R),
                                                           new Vector3(BS_R,0,BS_R),
                                                           new Vector3(BS_R,0,BS_R*3),
                                                           new Vector3(BS_R*-1,0,BS_R*3),
                                                           //-------5--------------
                                                           new Vector3(BS_R*-1,0,BS_R*-3),
                                                           new Vector3(BS_R,0,BS_R*-3),
                                                           new Vector3(BS_R,0,BS_R*-1),
                                                           new Vector3(BS_R*-1,0,BS_R*-1),
                                                           //-------6--------------
                                                           new Vector3(BS_R,0,BS_R),
                                                           new Vector3(BS_R*3,0,BS_R),
                                                           new Vector3(BS_R*3,0,BS_R*3),
                                                           new Vector3(BS_R,0,BS_R*3),
                                                           //-------7--------------
                                                           new Vector3(BS_R,0,BS_R*-1),
                                                           new Vector3(BS_R*3,0,BS_R*-1),
                                                           new Vector3(BS_R*3,0,BS_R),
                                                           new Vector3(BS_R,0,BS_R),
                                                           //-------8--------------
                                                           new Vector3(BS_R,0,BS_R*-3),
                                                           new Vector3(BS_R*3,0,BS_R*-3),
                                                           new Vector3(BS_R*3,0,BS_R*-1),
                                                           new Vector3(BS_R,0,BS_R*-1),
    };

    private readonly static int[] BS_Ts = new int[] {
                                                    //---1-----
                                                    0,3,1,
                                                    3,2,1,
                                                    //---2-----
                                                    4,7,5,
                                                    7,6,5,
                                                    //---3-----
                                                    8,11,9,
                                                    11,10,9,
                                                    //---4-----
                                                    12,15,13,
                                                    15,14,13,
                                                    //---5-----
                                                    16,19,17,
                                                    19,18,17,
                                                    //---6-----
                                                    20,23,21,
                                                    23,22,21,
                                                    //---7-----
                                                    24,27,25,
                                                    27,26,25,
                                                    //---8-----
                                                    28,31,29,
                                                    31,30,29,
    };

    private readonly static Vector2[] BS_Us = new Vector2[] {
                                                            //----1--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
                                                            //----2--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
                                                            //----3--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
                                                            //----4--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
                                                            //----5--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
                                                            //----6--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
                                                            //----7--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
                                                            //----8--------
                                                            new Vector2(0,0),
                                                            new Vector3(0,1),
                                                            new Vector2(1,1),
                                                            new Vector2(1,0),
    };

    //
    // --1--2--3--4--
    // --5--6--7--8--
    // --9-10-11-12--
    // -13-14-15-16--
    //

    private readonly static float BB_U_Offset = (1.0f / 512.0f) * 4;
    private readonly static Vector2[] BB_Us = new Vector2[] {
                                                            //----1--------
                                                            new Vector2(0+BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector3(0.25f-BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector2(0.25f-BB_U_Offset,1-BB_U_Offset),
                                                            new Vector2(0+BB_U_Offset,1-BB_U_Offset),
                                                            //----2--------
                                                            new Vector2(0.25f+BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector3(0.5f-BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector2(0.5f-BB_U_Offset,1-BB_U_Offset),
                                                            new Vector2(0.25f+BB_U_Offset,1-BB_U_Offset),
                                                            //----3--------
                                                            new Vector2(0.5f+BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector3(0.75f-BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector2(0.75f-BB_U_Offset,1-BB_U_Offset),
                                                            new Vector2(0.5f+BB_U_Offset,1-BB_U_Offset),
                                                            //----4--------
                                                            new Vector2(0.75f+BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector3(1-BB_U_Offset,0.75f+BB_U_Offset),
                                                            new Vector2(1-BB_U_Offset,1-BB_U_Offset),
                                                            new Vector2(0.75f+BB_U_Offset,1-BB_U_Offset),
                                                            //----5--------
                                                            new Vector2(0+BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector3(0.25f-BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector2(0.25f-BB_U_Offset,0.75f-BB_U_Offset),
                                                            new Vector2(0+BB_U_Offset,0.75f-BB_U_Offset),
                                                            //----6--------
                                                            new Vector2(0.25f+BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector3(0.5f-BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector2(0.5f-BB_U_Offset,0.75f-BB_U_Offset),
                                                            new Vector2(0.25f+BB_U_Offset,0.75f-BB_U_Offset),
                                                            //----7--------
                                                            new Vector2(0.5f+BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector3(0.75f-BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector2(0.75f-BB_U_Offset,0.75f-BB_U_Offset),
                                                            new Vector2(0.5f+BB_U_Offset,0.75f-BB_U_Offset),
                                                            //----8--------
                                                            new Vector2(0.75f+BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector3(1-BB_U_Offset,0.5f+BB_U_Offset),
                                                            new Vector2(1-BB_U_Offset,0.75f-BB_U_Offset),
                                                            new Vector2(0.75f+BB_U_Offset,0.75f-BB_U_Offset),
                                                            //----9--------
                                                            new Vector2(0+BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector3(0.25f-BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector2(0.25f-BB_U_Offset,0.5f-BB_U_Offset),
                                                            new Vector2(0+BB_U_Offset,0.5f-BB_U_Offset),
                                                            //----10--------
                                                            new Vector2(0.25f+BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector3(0.5f-BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector2(0.5f-BB_U_Offset,0.5f-BB_U_Offset),
                                                            new Vector2(0.25f+BB_U_Offset,0.5f-BB_U_Offset),
                                                            //----11--------
                                                            new Vector2(0.5f+BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector3(0.75f-BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector2(0.75f-BB_U_Offset,0.5f-BB_U_Offset),
                                                            new Vector2(0.5f+BB_U_Offset,0.5f-BB_U_Offset),
                                                            //----12--------
                                                            new Vector2(0.75f+BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector3(1-BB_U_Offset,0.25f+BB_U_Offset),
                                                            new Vector2(1-BB_U_Offset,0.5f-BB_U_Offset),
                                                            new Vector2(0.75f+BB_U_Offset,0.5f-BB_U_Offset),
                                                            //----13--------
                                                            new Vector2(0+BB_U_Offset,0+BB_U_Offset),
                                                            new Vector3(0.25f-BB_U_Offset,0+BB_U_Offset),
                                                            new Vector2(0.25f-BB_U_Offset,0.25f-BB_U_Offset),
                                                            new Vector2(0+BB_U_Offset,0.25f-BB_U_Offset),
                                                            //----14--------
                                                            new Vector2(0.25f+BB_U_Offset,0+BB_U_Offset),
                                                            new Vector3(0.5f-BB_U_Offset,0+BB_U_Offset),
                                                            new Vector2(0.5f-BB_U_Offset,0.25f-BB_U_Offset),
                                                            new Vector2(0.25f+BB_U_Offset,0.25f-BB_U_Offset),
                                                            //----15--------
                                                            new Vector2(0.5f+BB_U_Offset,0+BB_U_Offset),
                                                            new Vector3(0.75f-BB_U_Offset,0+BB_U_Offset),
                                                            new Vector2(0.75f-BB_U_Offset,0.25f-BB_U_Offset),
                                                            new Vector2(0.5f+BB_U_Offset,0.25f-BB_U_Offset),
                                                            //----16--------
                                                            new Vector2(0.75f+BB_U_Offset,0+BB_U_Offset),
                                                            new Vector3(1-BB_U_Offset,0+BB_U_Offset),
                                                            new Vector2(1-BB_U_Offset,0.25f-BB_U_Offset),
                                                            new Vector2(0.75f+BB_U_Offset,0.25f-BB_U_Offset),

    };

    private static Color EmptyColor = new Color(0, 0, 0, 0);
    private Vector3[] mVs;
    private Vector2[] mUs;
    private int[] mTs;
    private Color[] mCs;

    private int mWidth;
    private int mHeight;
    private float mBoxSize;
    private float mHalfBoxSize;
    private int mBoxCount;
    private int mOBVCount;
    private int mOBTCount;
    private int mVCount;
    private int mTCount;


    public Vector3[] Vs { get { return mVs; } }
    public Vector2[] Us { get { return mUs; } }
    public int[] Ts { get { return mTs; } }
    public Color[] Cs { get { return mCs; } }

    private Vector3 mTmp = Vector3.zero;

    public enum UpdateState
    {
        US_ALL,
        US_COL,
        US_NIL,
    }
    private UpdateState mState;
    public UpdateState State { get { return mState; } }
    public TerrainBorderMarkerBox(int width, int height, float box_size)
    {
        mState = UpdateState.US_NIL;
        mWidth = width;
        mHeight = height;
        mBoxSize = box_size;
        mHalfBoxSize = mBoxSize * mWidth * 0.5f - mBoxSize * 0.5f;
        mBoxCount = Mathf.Min(65000 / BS_Vs.Length, width * height);

        mOBVCount = BS_Vs.Length;
        mOBTCount = BS_Ts.Length;
        mVCount = mBoxCount * mOBVCount;
        mTCount = mBoxCount * mOBTCount;
        mVs = new Vector3[mVCount];
        mUs = new Vector2[mVCount];
        mCs = new Color[mVCount];
        mTs = new int[mTCount];

        InitMesh();
    }

    private void InitMesh()
    {
        int tindex = 0;
        for (int i = 0; i < mBoxCount; i++)
        {
            tindex = i * mOBTCount;
            for (int j = 0; j < mOBTCount; j++)
            {
                mTs[tindex + j] = BS_Ts[j] + i * mOBVCount;
            }
        }
    }

    public void Set(int x, int y, Vector3 offset, int[] types, Color color)
    {
        int boxindex = (mWidth - x - 1) * mHeight + y;
        int vindex = boxindex * mOBVCount;
        if (types[0] == 0)
        {
            System.Array.Clear(mCs, vindex, mOBVCount);
            if (mState == UpdateState.US_NIL)
                mState = UpdateState.US_COL;
            return;
        }

        int typeindex;
        for (int i = 0; i < mOBVCount; i++)
        {
            mTmp.x = x * mBoxSize - mHalfBoxSize + offset.x;
            mTmp.z = y * mBoxSize - mHalfBoxSize + offset.z;
            mVs[vindex + i] = BS_Vs[i] * mBoxSize + mTmp;
            typeindex = (types[i / 4] - 1) * 4 + i % 4;
            mUs[vindex + i] = BB_Us[typeindex] * 1.0002f;
            mCs[vindex + i] = color;
        }
        mState = UpdateState.US_ALL;
    }

    public void Clear()
    {
        System.Array.Clear(mCs, 0, mVCount);
        if (mState == UpdateState.US_NIL)
            mState = UpdateState.US_COL;
    }

    public void Set(Vec2Int lpos, Vector3 offset, int[] types, Color color)
    {
        if(lpos.x < 0 || lpos.y < 0)
            return;
        int boxindex = (mWidth - lpos.x - 1) * mHeight + lpos.y;
        int vindex = boxindex * mOBVCount;

        int typeindex;
        for (int i = 0; i < mOBVCount; i++)
        {
            mTmp.x = lpos.x * mBoxSize + offset.x;
            mTmp.z = lpos.y * mBoxSize + offset.z;

            mVs[vindex + i] = BS_Vs[i] * mBoxSize + mTmp;
            typeindex = (types[i / 4] - 1) * 4 + i % 4;
            if (typeindex < 0)
            {
                Color old = mCs[vindex + i];
                mCs[vindex + i] = EmptyColor;
                continue;
            }
            if (typeindex >= BB_Us.Length || vindex + i >= mUs.Length || typeindex < 0 || vindex + i < 0)
            {
                Debug.Log("SSSSSSSSSSSSSSSSSS");
            }
            mUs[vindex + i] = BB_Us[typeindex] * 1.0002f;
            mCs[vindex + i] = color;
        }
        mState = UpdateState.US_ALL;
    }

    public void ResetState()
    {
        mState = UpdateState.US_NIL;
    }

}

public class TerrainMarkerBoxDrawer
{
    private Mesh mMesh;
    private WorldData mWorld;
    private int mMBVCount;
    private int mMBTCount;
    private int mVCount;
    private int mTCount;
    private TerrainBorderMarkerBox.UpdateState mState;
    private Vector3 mPos;
    private Quaternion mRot;
    private TerrainBorderMarkerBox mMarkerBox;
    public TerrainMarkerBoxDrawer(WorldData world)
    {
        mPos = Vector3.zero;
        mRot = Quaternion.identity;
        mState = TerrainBorderMarkerBox.UpdateState.US_NIL;
        mWorld = world;
        mMesh = new Mesh();
        mMesh.name = "[3DT]TerrainMarkerBoxDrawer_Mesh";
        mMarkerBox = mWorld.world.worldMapUpdata.worldMapTerritory.MarkerBox;

        mMesh.vertices = mMarkerBox.Vs;
        mMesh.uv = mMarkerBox.Us;
        mMesh.triangles = mMarkerBox.Ts;
        mMesh.colors = mMarkerBox.Cs;
    }

    public void Apply()
    {
        mState = TerrainBorderMarkerBox.UpdateState.US_NIL;
        switch (mMarkerBox.State)
        {
            case TerrainBorderMarkerBox.UpdateState.US_ALL:
                mMarkerBox.ResetState();
                mState = TerrainBorderMarkerBox.UpdateState.US_ALL;
                break;
            case TerrainBorderMarkerBox.UpdateState.US_COL:
                mMarkerBox.ResetState();
                if (mState == TerrainBorderMarkerBox.UpdateState.US_NIL)
                    mState = TerrainBorderMarkerBox.UpdateState.US_COL;
                break;
        }
    }


    private bool UpdateMesh()
    {
        if (mState == TerrainBorderMarkerBox.UpdateState.US_NIL)
            return false;
        bool update = false;
        switch (mState)
        {
            case TerrainBorderMarkerBox.UpdateState.US_ALL:
                mMesh.vertices = mMarkerBox.Vs;
                mMesh.uv = mMarkerBox.Us;
                mMesh.colors = mMarkerBox.Cs;
                update = true;
                break;
            case TerrainBorderMarkerBox.UpdateState.US_COL:
                mMesh.colors = mMarkerBox.Cs;
                update = true;
                break;
        }
        mState = TerrainBorderMarkerBox.UpdateState.US_NIL;
        return update;
    }

    public void DrawMesh(Vector3 bcenter, float bsize)
    {
        if (!mWorld.NeedShowMarkerBox)
            return;
        if (UpdateMesh())
        {
            UpdateBound(bcenter, bsize);
        }
        Graphics.DrawMesh(mMesh, mPos, mRot, mWorld.MarkerBoxMat, 0);
    }

    private void UpdateBound(Vector3 bcenter, float bsize)
    {
        MeshCombine.UpdateMeshBounds(mMesh, bcenter, bsize);
    }
}
