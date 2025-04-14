using UnityEngine;
using System.Collections;

[System.Serializable]
public class TerrainUnionBuildPreview
{
    [System.Serializable]
    public class UnionBuildInfo
    {
        public Mesh mesh;
        public Material mat;
        public Vector3 size;
        public Vector3 rotate;
        [Range(1, 3)]
        public int xSize;
        [Range(1, 3)]
        public int ySize;
    }
    public Vector3 Offset;
    public UIPanel PreviewBox;
    public UITexture PreviewBoxUnit;
    public Texture2D RedTex;
    public Texture2D GreenTex;
    public string LayerName;
    public bool IsDebug = false;

    public UnionBuildInfo[] unionBuilds;
    private UITexture[] mBoxUnits;
    private int mDisPlayPreviewID;
    private UnionBuildInfo mDisplayPreview;
    private Matrix4x4 mPreview4x4;
    private WorldData mWorld;
    private Transform mRoot;
    private bool mVaild = false;
    private Vector4 mwPos = Vector4.zero;
    private Vector3 mTmp = Vector3.zero;
    private Vec2Int mNLpos = new Vec2Int();
    private Vec2Int mCLpos = new Vec2Int();
    private Camera mUBPCam;
    private int mLayer;
    private uint mGuildId;
    private bool mCanBuild;
    public void Init(WorldData world)
    {
        mVaild = false;
        mWorld = world;
        if (mWorld.world.WCamera == null)
        {
            return;
        }
            
        if (PreviewBoxUnit != null && PreviewBox != null)
        {
            PreviewBoxUnit.alpha = 0;
            mBoxUnits = new UITexture[9];
            for (int i = 0; i < 9; i++)
            {
                mBoxUnits[i] = GameObject.Instantiate<UITexture>(PreviewBoxUnit);
                mBoxUnits[i].transform.parent = PreviewBox.transform;
                mBoxUnits[i].transform.localPosition = Vector3.zero;
                mBoxUnits[i].transform.localRotation = Quaternion.identity;
                mBoxUnits[i].transform.localScale = Vector3.one;
            }
        }
        else
            return;


        GameObject obj = new GameObject("UnionPreview");
        mRoot = obj.transform;
        mRoot.parent = mWorld.world.WCamera.transform.parent;
        mRoot.localPosition = mWorld.CamOffset;
        mRoot.localEulerAngles = mWorld.CamRotate;
        mRoot.localScale = Vector3.one;
        mUBPCam = obj.AddComponent<Camera>();
        mUBPCam.fieldOfView = mWorld.CamFieldOfView;
        mUBPCam.backgroundColor = mWorld.FogColor;
        mLayer = LayerMask.NameToLayer(LayerName);
        mUBPCam.cullingMask = 1 << mLayer;
        mUBPCam.clearFlags = CameraClearFlags.Depth;
        mUBPCam.depth = -2;

        mVaild = true;
        mCanBuild = false;
    }

    public void Reset()
    {
        if (!mVaild)
            return;
        HideAllBox();
        mCLpos.x = int.MinValue;
        mCLpos.y = int.MinValue;
        mDisplayPreview = null;
        mCanBuild = false;
    }

    public bool CanBuild()
    {
        if (!mVaild)
            return false;
        return mCanBuild;
    }

    public void DisplayPreview(int index, uint guild_id)
    {
        if (!mVaild)
            return;
        mDisPlayPreviewID = index;
        if (mDisPlayPreviewID < 0)
        {
            Reset();
            return;
        }

        if (mDisPlayPreviewID >= unionBuilds.Length)
        {
            Reset();
            return;
        }
        mDisplayPreview = unionBuilds[index];
        if (mDisplayPreview.mesh == null || mDisplayPreview.mat == null)
            Reset();
        if (mDisplayPreview != null)
        {
            mGuildId = guild_id;

            mPreview4x4.SetTRS(Vector3.zero, Quaternion.Euler(mDisplayPreview.rotate), mDisplayPreview.size);
            mWorld.LBlockMap.WorldPos2WLogicPos(mRoot.position + Offset, mWorld, ref mNLpos);
            mCLpos.x = mNLpos.x;
            mCLpos.y = mNLpos.y;
            mCanBuild = true;
            int lindex = 0;
            for (int x = 0; x < mDisplayPreview.xSize; x++)
            {
                for (int y = 0; y < mDisplayPreview.ySize; y++)
                {
                    lindex = (mDisplayPreview.xSize - x - 1) * mDisplayPreview.ySize + y;
                    mNLpos.x = mCLpos.x + x;
                    mNLpos.y = mCLpos.y + y;
                    if (WorldMapMgr.Instance.GetSprite(mCLpos.x + x, mCLpos.y + y) != 0 ||
                        mWorld.WBlockMap.GetBuild(ref mNLpos) != 0 ||
                        !mWorld.world.worldMapNet.borderData.IsSelfBorder(mCLpos.x + x, mCLpos.y + y, mGuildId))
                    {
                        mCanBuild = false;
                    }
                }
            }
            mCLpos.x = int.MinValue;
            mCLpos.y = int.MinValue;
        }
        return;
    }

    public void HideAllBox()
    {
        if (!mVaild)
            return;
        if (mBoxUnits != null)
        {
            for (int i = 0; i < 9; i++)
            {
                mBoxUnits[i].alpha = 0;
            }
        }
    }

    public int CurSelectPosX()
    {
        return mCLpos.x;
    }

    public int CurSelectPosY()
    {
        return mCLpos.y;
    }

    public void DrawPreview()
    {
        if (!mVaild)
            return;
        if (mDisplayPreview == null)
            return;
        mWorld.LBlockMap.WorldPos2WLogicPos(mRoot.position + Offset, mWorld, ref mNLpos);
        if (mNLpos.x != mCLpos.x || mNLpos.y != mCLpos.y)
        {
            mCLpos.x = mNLpos.x;
            mCLpos.y = mNLpos.y;
            mTmp.y = 0;
            mWorld.LBlockMap.WLogicPos2WorldPos(ref mTmp, ref mCLpos, mWorld);
            mwPos = mTmp;
            if (PreviewBox != null)
            {
                PreviewBox.transform.position = mwPos;
                int lindex = 0;
                HideAllBox();
                mCanBuild = true;
                for (int x = 0; x < mDisplayPreview.xSize; x++)
                {
                    for (int y = 0; y < mDisplayPreview.ySize; y++)
                    {
                        lindex = (mDisplayPreview.xSize - x - 1) * mDisplayPreview.ySize + y;
                        mTmp.x = x * mBoxUnits[lindex].width;
                        mTmp.y = y * mBoxUnits[lindex].height;
                        mTmp.z = 0;
                        mBoxUnits[lindex].transform.localPosition = mTmp;
                        mBoxUnits[lindex].alpha = 1;
                        mNLpos.x = mCLpos.x + x;
                        mNLpos.y = mCLpos.y + y;
                        if (WorldMapMgr.Instance.GetSprite(mCLpos.x + x, mCLpos.y + y) != 0 ||
                            mWorld.WBlockMap.GetBuild(ref mNLpos) != 0 ||
                            !mWorld.world.worldMapNet.borderData.IsSelfBorder(mCLpos.x + x, mCLpos.y + y, mGuildId))
                        {
                            mBoxUnits[lindex].mainTexture = RedTex;
                            mCanBuild = false;
                        }
                        else
                        {
                            mBoxUnits[lindex].mainTexture = GreenTex;
                        }
                    }
                }
            }
            mwPos.x = mDisplayPreview.xSize * 0.5f * mWorld.LogicBlockSize - mWorld.LogicBlockSize * 0.5f + mwPos.x;
            mwPos.z = mDisplayPreview.ySize * 0.5f * mWorld.LogicBlockSize - mWorld.LogicBlockSize * 0.5f + mwPos.z;
            mwPos.w = 1;
            mPreview4x4.SetColumn(3, mwPos);
        }

        if (IsDebug)
        {
            mPreview4x4.SetTRS(mwPos, Quaternion.Euler(mDisplayPreview.rotate), mDisplayPreview.size);
        }
        Graphics.DrawMesh(mDisplayPreview.mesh, mPreview4x4, mDisplayPreview.mat, mLayer);
    }
}
