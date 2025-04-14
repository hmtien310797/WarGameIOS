using UnityEngine;
using System.Collections;

public enum WorldMode
{
    Normal = 0,
    Moba = 1,
    GuildMoba = 2,
}

public class World : MonoBehaviour
{
    public bool DebugMode = false;
    public Camera WCamera;
    public Camera PCamera;
    public Camera UCamera;
    public float BaseTerrainHeight;
    public int MeshCombMaxVCount = 10000;

    /// <summary>
    /// 3D大地图数据文件
    /// </summary>
    public World3D World3D;
    /// <summary>
    /// 3D大地图选择框
    /// </summary>
    public UIPanel SelectionBox;
    public WorldHUDMgr TerritoryHUD;
    public WorldHUDCache TerritoryHUDBuffer;

    public WorldData WorldInfo;
    public Transform WorldNode;
    public string LandLayerName;
    public string SpriteLayerName;
    public float CurvedWorld_Bend_X = -2;
    public float CurvedWorld_Bias_X = 2;
    public float CurvedWorld_Bend_Z = -3f;
    public float CurvedWorld_Bias_Z = 1;

    public Clishow.CsProjShadowMap.ProjCfg mProjCfg;
    public bool Debug_shadow = false;
    public float Shadow_Deepness;
    public float Shadow_Hight;
    public float Build_Offset_Height;
    public Vector3 Shadow_Light_Dir;

    public string smc_extend_cfg;
    public SkinMeshCombine[] SMC;
    public SkinMeshCombine VehiceSMC;
    public LayerMask ShadowObjMask;
    public LayerMask CastShadowMask;

    public WorldMapNet worldMapNet = new WorldMapNet();
    public WorldMapUpdata worldMapUpdata = new WorldMapUpdata();
    public WorldMapBuildEffect worldMapBuildEffect;
    public WorldMapEffect worldMapEffect;

    public TerrainUnionBuildPreview UnionBuildPreview;

    private int mLandLayer;
    private int mSpriteLayer;
    private CurvedWorld_Controller mCW;
    private Clishow.CsProjShadowMap mProjShadow = null;
    private Vector3 mPos;
    private Quaternion mQuat;
    private float mMeshQuality = 1;
    private bool mSupportShadow = true;
    private float mBuildRangeQuality = 1;
    private bool mVaild = false;

    public bool Vaild { get { return mVaild; } }

    private WorldMode mMobaMode = WorldMode.Normal;

    public WorldMode MobaMode
    {
        get
        {
            return mMobaMode;
        }
    }

    public Clishow.CsProjShadowMap ProjShadow
    {
        get
        {
            return mProjShadow;
        }
    }

    public CurvedWorld_Controller CW
    {
        get
        {
            return mCW;
        }
    }

    public float MeshQuality
    {
        get
        {
            return mMeshQuality;
        }
    }

    public bool SupportShadow
    {
        get
        {
            return mSupportShadow;
        }
    }

    public float BuildRangeQuality
    {
        get
        {
            return mBuildRangeQuality;
        }
    }

    private void InitCurvedWorld()
    {
        if (CurvedWorld_Controller.get != null)
        {
            mCW = CurvedWorld_Controller.get;
        }
        if (mCW == null)
            mCW = this.gameObject.GetComponent<CurvedWorld_Controller>();
        if (mCW == null)
            mCW = this.gameObject.AddComponent<CurvedWorld_Controller>();

        mCW.pivotPoint = Camera.main.transform;
        mCW._V_CW_Bend_X = CurvedWorld_Bend_X;
        mCW._V_CW_Bias_X = CurvedWorld_Bias_X;

        mCW._V_CW_Bend_Z = CurvedWorld_Bend_Z;
        mCW._V_CW_Bias_Z = CurvedWorld_Bias_Z;
    }

    private void InitShadow(Color fogcolor, float fogmax)
    {
        GameObject obj = new GameObject("ShadowMap");
        obj.transform.position = Vector3.zero;
        mProjShadow = obj.AddComponent<Clishow.CsProjShadowMap>();
        mProjShadow.world = this;
        if (!mProjShadow.Initialize(mProjCfg, fogcolor, fogmax, true))
        {
            mProjShadow = null;
            GameObject.Destroy(obj);
        }
    }

    private void Start()
    {
        if (WorldMapMgr.IsDebug)
        {
            Init();
        }
        if (WorldInfo.worldMapHUD.Length != 0)
            TerritoryHUDBuffer = new WorldHUDCache(16, 2);
    }

    private void InitMoba()
    {
        mMobaMode =  WorldMode.Normal;
        LuaInterface.LuaFunction f = LuaClient.GetMainState().GetFunction("Global.GetMobaMode");
        object mode = null;
        if (f != null)
            mode = f.Call(null)[0];
        mMobaMode = (WorldMode)((int)(double)mode);
        if (MobaMode == WorldMode.Moba)
        {
            Main.Instance.ChangeWorldBlockInfo("WorldBlockInfo_moba");
        }
        else if (MobaMode == WorldMode.GuildMoba)
        {
            Main.Instance.ChangeWorldBlockInfo("WorldBlockInfo_moba_guild");
        }
        else
        {
            Main.Instance.ChangeWorldBlockInfo("WorldBlockInfo");
        }
        Main.Instance.ReloadWorldBlockInfo();
    }
    private Vec2Int mMobaBorderMinPos;
    public Vec2Int mobaBorderMinPos
    {
        get
        {
            return mMobaBorderMinPos;
        }
    }
    private Vec2Int mMobaBorderMaxPos;

    private void InitMobaWall()
    {
        if (MobaMode == WorldMode.Normal)
            return;

        if (WorldInfo.MobaWall != null)
        {
            Vector3 wall_pos = Vector3.zero;
            WorldInfo.LBlockMap.WLogicPos2WorldPos(ref wall_pos, (int)WorldInfo.MobaServerMinPoint.x, (int)WorldInfo.MobaServerMinPoint.z, WorldInfo);
            GameObject.Instantiate(WorldInfo.MobaWall, wall_pos, Quaternion.Euler(0,-90,0), this.transform);
        }
        mMobaBorderMinPos = new Vec2Int((int)WorldInfo.MobaServerMinPoint.x, (int)WorldInfo.MobaServerMinPoint.z);
        mMobaBorderMaxPos = new Vec2Int(mMobaBorderMinPos.x + (int)WorldInfo.MobaSize.x, mMobaBorderMinPos.y + (int)WorldInfo.MobaSize.y);
    }

    public void ChangePosToMoba(ref int x,ref int y)
    {
        if (MobaMode == WorldMode.Normal)
            return;
        x -= (int)WorldInfo.MobaServerMinPoint.x;
        y -= (int)WorldInfo.MobaServerMinPoint.z;
    }

    public bool IsInMobaBorder(ref Vector3 offset)
    {
        if (MobaMode == WorldMode.Normal)
            return false;
        Vec2Int center_pos = WorldInfo.LBlockMap.WorldPos2WLogicPos(WorldMapMgr.instance.worldCamera.transform.localPosition, WorldInfo);
        Vec2Int new_center_pos = WorldInfo.LBlockMap.WorldPos2WLogicPos(WorldMapMgr.instance.worldCamera.transform.localPosition+ offset, WorldInfo);
        {
            if (!(new_center_pos.x > mMobaBorderMinPos.x && new_center_pos.x < mMobaBorderMaxPos.x))
            {
                if (Mathf.Abs(new_center_pos.x - center_pos.x) >= 2)
                {
                    offset.x = Mathf.Sign(offset.x) * WorldInfo.LBlockMap.BlockSize;
                }
            }

            if (!(new_center_pos.y > mMobaBorderMinPos.y && new_center_pos.y < mMobaBorderMaxPos.y))
            {
                if (Mathf.Abs(new_center_pos.y - center_pos.y) >= 2)
                    offset.z = Mathf.Sign(offset.z) * WorldInfo.LBlockMap.BlockSize;
            }
        }
        center_pos.x -= (int)Mathf.Sign(offset.x);
        center_pos.y -= (int)Mathf.Sign(offset.z);
        //Debug.Log("XXXXXXXXXXXXXXX     " + (center_pos.x > min_pos.x && center_pos.x < max_pos.x && center_pos.y > min_pos.y && center_pos.y < max_pos.y) + "    =="+ (int)Mathf.Sign(offset.x)+":"+ (int)Mathf.Sign(offset.z));
        return !( center_pos.x > mMobaBorderMinPos.x && center_pos.x < mMobaBorderMaxPos.x && center_pos.y > mMobaBorderMinPos.y && center_pos.y < mMobaBorderMaxPos.y);
    }

    public void Init()
    {

        InitMoba();

        switch (GameSetting.instance.option.mQualityLevel)
        {
            case 0:
                mMeshQuality = 0.25f;
                mSupportShadow = false;
                mBuildRangeQuality = 1f;
                break;
            case 1:
                mMeshQuality = 0.35f;
                mSupportShadow = true;
                mBuildRangeQuality = 1f;
                break;
            case 2:
                mMeshQuality = 1;
                mSupportShadow = true;
                mBuildRangeQuality = 1;
                break;
        }

        if (WCamera != null)
        {
            WCamera.transform.localPosition = WorldInfo.CamOffset;
            WCamera.transform.localEulerAngles = WorldInfo.CamRotate;
            WCamera.fieldOfView = WorldInfo.CamFieldOfView;
            WCamera.backgroundColor = WorldInfo.FogColor;
        }
        if (PCamera != null)
        {
            PCamera.transform.localPosition = WorldInfo.CamOffset;
            PCamera.transform.localEulerAngles = WorldInfo.CamRotate;
            PCamera.fieldOfView = WorldInfo.CamFieldOfView;
            PCamera.backgroundColor = WorldInfo.FogColor;
        }
        if (UCamera != null)
        {
            UCamera.transform.localPosition = WorldInfo.CamOffset;
            UCamera.transform.localEulerAngles = WorldInfo.CamRotate;
            UCamera.fieldOfView = WorldInfo.CamFieldOfView;
            UCamera.backgroundColor = WorldInfo.FogColor;
        }

        mPos = Vector3.zero;
        mQuat = Quaternion.identity;
        mLandLayer = LayerMask.NameToLayer(LandLayerName);
        mSpriteLayer = LayerMask.NameToLayer(SpriteLayerName);
        InitCurvedWorld();
        WorldInfo.isDebugMode = DebugMode;
        WorldInfo.Init(mLandLayer, mSpriteLayer, this, WorldMapMgr.Instance);
        InitMobaWall();
        //InitShadow(WorldInfo.FogColor, WorldInfo.FogMaxDis);
        worldMapUpdata.Init(this);
        worldMapNet.Init(this);
        WorldInfo.InitBorderMarker();
        worldMapBuildEffect.Init();
        Shader.SetGlobalFloat("_Deepness", Shadow_Deepness);
        Shader.SetGlobalFloat("_ShadowHight", Shadow_Hight);
        Shader.SetGlobalVector("_ShadowLightDir", Shadow_Light_Dir);

        if (SMC != null)
        {
            SMCHelper.ReadCfgFile(this, smc_extend_cfg);
            for (int i = 0; i < SMC.Length; i++)
            {
                if(SMC[i] != null)
                    SMC[i].Init(WorldInfo);
            }
        }
        if (VehiceSMC != null)
        {
            VehiceSMC.Init(WorldInfo);
        }
        if (UnionBuildPreview != null && WorldInfo != null)
            UnionBuildPreview.Init(WorldInfo);
        mVaild = true;
    }

    //public Vector3 World2TerrainPos(Vector3 wpos)
    //{
    //    wpos.y = WorldInfo.GetTerrainHeight(wpos);
    //    return wpos;
    //}

    public void UpdateWorld(Vector3 pos)
    {
        if (!mVaild)
            return;
        WorldInfo.CheckChunks(pos);
        WorldInfo.Update();
        worldMapUpdata.MapUpdate();
        worldMapNet.UpdataNet();
        if (WorldNode != null)
        {
            WorldNode.localPosition = WorldInfo.CenterPos;
        }
    }

    public void DrawWorld()
    {
        Graphics.DrawMesh(WorldInfo.WorldMesh, mPos, mQuat, WorldInfo.ChunkMat, mLandLayer);
        WorldInfo.DrawSprites();
        if (UnionBuildPreview != null)
            UnionBuildPreview.DrawPreview();
    }

    public void DrawSpriteNow()
    {
        WorldInfo.DrawSpritesNow();
    }

    public void ApplySMC(int index = -1)
    {
        if (SMC != null)
        {
            if (index < 0)
            {
                for (int i = 0; i < SMC.Length; i++)
                {
                    SMC[i].Apply();
                }
            }
            else
            {
                SMC[index].Apply();
            }
        }
    }
    private int mClearCacheCount = 0;
    void Update()
    {
        if (!mVaild)
            return;
        if (SMC != null)
        {
            for (int i = 0; i < SMC.Length; i++)
            {
                SMC[i].UpdateSMC(WorldInfo.CenterPos, WorldInfo.ChunkSize * 2);
            }
        }
        if (VehiceSMC != null)
        {
            VehiceSMC.UpdateSMC(WorldInfo.CenterPos, WorldInfo.ChunkSize * 2);
        }

        if (Time.frameCount % 10 == 0)
        {
            if (mClearCacheCount == SMC.Length)
            {
                if (VehiceSMC != null)
                {
                    VehiceSMC.ClearCache();
                }
                mClearCacheCount = 0;
            }
            else
            {
                if (SMC != null)
                {
                    SMC[mClearCacheCount].ClearCache();
                }
                mClearCacheCount++;
            }
            //System.GC.Collect(0,System.GCCollectionMode.Optimized);
        }


        if (Debug_shadow)
        {
            Shader.SetGlobalFloat("_Deepness", Shadow_Deepness);
            Shader.SetGlobalFloat("_ShadowHight", Shadow_Hight);
            Shader.SetGlobalVector("_ShadowLightDir", Shadow_Light_Dir);
        }

        //if(Input.GetKeyDown(KeyCode.Q))
        //{
        //    if(UnionBuildPreview != null)
        //    {
        //        UnionBuildPreview.DisplayPreview(0);
        //    }
        //}
        //if(Input.GetKeyDown(KeyCode.W))
        //{
        //    if(UnionBuildPreview != null)
        //    {
        //        UnionBuildPreview.DisplayPreview(1);
        //    }
        //}
        //if(Input.GetKeyDown(KeyCode.E))
        //{
        //    if(UnionBuildPreview != null)
        //    {
        //        UnionBuildPreview.DisplayPreview(-1);
        //    }
        //}
    }

    void LateUpdate()
    {
        if (mVaild)
            DrawWorld();
    }

    void OnDestroy()
    {
         mVaild = false;
        if (mProjShadow != null)
        {
            GameObject.Destroy(mProjShadow.gameObject);
        }
        WorldInfo.Destroy();

        for (int i = 0; i < SMC.Length; ++i)
        {
            GameObject.Destroy(SMC[i].gameObject);
            SMC[i] = null;
        }
        SMC = null;
    }

    private Vector3 mHitPos = Vector3.zero;
    public Vector3 GetRay2Terrain(Ray ray)
    {
        if(!mVaild)
            return Vector3.zero;
        float dis = 0;
        mHitPos = Intersect(ray, Vector3.up, 0, out dis);
        dis = 0;
        Vector3 offsetPos = mCW.TransformPoint(mHitPos, BEND_TYPE.Universal);
        offsetPos = offsetPos - mHitPos;
        mHitPos -= offsetPos;
        ray.direction = mHitPos - ray.origin;

        float offset = -1 * WorldInfo.LogicBlockSize;
        float terrain_h = 0;

        do
        {
            if (dis < offset)
                break;
            offset += WorldInfo.LogicBlockSize;
            mHitPos = Intersect(ray, Vector3.up, offset, out dis);
            //terrain_h = WorldInfo.GetTerrainHeight(mHitPos);
        }
        while (terrain_h > mHitPos.y);
        return mHitPos;
    }

    private Vector3 Intersect(Ray ray, Vector3 plane_normal, float offset, out float t)
    {
        t = -1 * (Vector3.Dot(plane_normal, ray.origin)) / Vector3.Dot(plane_normal, ray.direction);
        return ray.origin + ray.direction * (t - offset);
    }
}
