using UnityEngine;
using System.Collections;
[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class PostEffectMaskLight : MonoBehaviour
{
    private static float _R = 1;
    private static float _DR = _R * 0.5f;
    private static Vector3[] _DVS = new Vector3[]{
                                                           new Vector3(-1*_DR,0,_DR),
                                                           new Vector3(_DR,0,_DR),
                                                           new Vector3(_DR,0,-1*_DR),
                                                           new Vector3(-1*_DR,0,-1*_DR),

    };

    private static int[] _DTS = new int[] {
                                                    0,1,2,
                                                    0,2,3,
    };

    private static Vector2[] _DUS = new Vector2[] {
                                                            new Vector2(0,1),
                                                            new Vector3(1,1),
                                                            new Vector2(1,0),
                                                            new Vector2(0,0),
    };

    private Vector4[] mNs;
    private Color[] mCs;

    private int mVCount;
    private int mTCount;

    public Color LightColor;
    public Vector3 LightDir;
    public float LightRange;
    public float LightForce;

    private Color mLightColor;
    private Vector3 mLightDir;
    private float mLightRange;
    private float mLightForce;
    private bool mNeedUpdate = false;


    private Mesh mSource;
    private Mesh mResult;
    private Color mRColor;
    private Vector3 mLight;
    private float mMaxRange;
    private MeshFilter mFilter;
    private Transform mTrf;
    private Vector3[] mVS;
    private Vector3[] mSVS;
    void Init()
    {
        if (mFilter == null)
            mFilter = GetComponent<MeshFilter>();
        if (mFilter != null)
            mResult = mFilter.mesh;
        mSource = null;
        if (mResult != null && mResult.vertices.Length != 0)
        {
            mSource = mFilter.sharedMesh;
        }
        mResult = new Mesh();
        mFilter.mesh = mResult;
        mTrf = this.transform;
        if (mSource == null)
        {
            mVCount = _DVS.Length;
            mTCount = _DTS.Length;
        }
        else
        {
            mVCount = mSource.vertices.Length;
            mTCount = mSource.triangles.Length;
        }

        mNs = new Vector4[mVCount];
        mSVS = new Vector3[mVCount];
        mVS = new Vector3[mVCount];
        mCs = new Color[mVCount];

        if (mSource == null)
        {
            System.Array.Clear(mCs, 0, mVCount);
            mSVS = _DVS;
            System.Array.Copy(mSVS,mVS,mVCount);
            mResult.vertices = mVS;
            mResult.triangles = _DTS;
            mResult.uv = _DUS;
        }
        else
        {
            System.Array.Clear(mCs, 0, mVCount);
            mSVS = mSource.vertices;
            System.Array.Copy(mSVS,mVS,mVCount);
            mResult.vertices = mVS;
            mResult.triangles = mSource.triangles;
            mResult.uv = mSource.uv;
        }

        mResult.RecalculateBounds();
        UpdateMesh();

    }
    Vector2 tmp1 = Vector2.zero;
    Vector2 tmp2 = Vector2.zero;
    Vector4 tmp3 = Vector4.zero;
    public void UpdateMesh()
    {
        tmp2.Set(mLight.x,mLight.z);
        tmp2 = tmp2.normalized;
        for (int i = 0; i < mVCount; i++)
        {
            mVS[i] = mSVS[i]*mLight.y;
            tmp3 = mLight;
            tmp1.Set(mVS[i].x,mVS[i].z);
            tmp3.w = Vector2.Dot(tmp1.normalized,tmp2);
            mNs[i] = tmp3;
            mCs[i] = mRColor;
        }
        mResult.vertices = mVS;
        mResult.tangents = mNs;
        mResult.colors = mCs;
    }

    private void CheckLight()
    {
        bool need_update = false;
        if (LightRange != mLightRange || mLightForce != LightForce || LightDir != mLightDir)
        {
            mLightRange = LightRange;
            mLightForce = LightForce;
            mLightDir = LightDir;
            mLight = mLightDir;
            mRColor.a = mLightForce * Mathf.Lerp(1, 0, mLight.y / Mathf.Max(0.01f, mLightRange));
            need_update = true;
        }

        if (LightColor != mLightColor)
        {
            mLightColor = LightColor;
            mRColor.r = mLightColor.r;
            mRColor.g = mLightColor.g;
            mRColor.b = mLightColor.b;
            need_update = true;
        }


        if (need_update)
        {
            UpdateMesh();
        }
    }

    void Awake()
    {
        Init();
    }

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        CheckLight();
    }
}
