using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public interface IWorldData
{
    void SetCamera(Vector3 pos);
    int FollowId();
    //void ChunkUpdateNotify(Vec2Int center);
    Vector2 GetInitPos();
}


[System.Serializable]
public class WorldData : ScriptableObject
{
    public bool isDebugMode = false;
    public Vector3 MobaServerMinPoint;
    public GameObject MobaWall;
    public Vector2 MobaSize;


    public Mesh ChunkMesh;
    public float ChunkSize;
    public Vector3 CamOffset;
    public Vector3 CamRotate;
    public float CamFieldOfView;
    public float FogMaxDis;
    public Color FogColor;
    public int PixelOffset;
    public float TerrainMaxHeight;
    public float GroundHeight;
    public int MaxSpriteNumInChunk;
    public float LogicBlockSize;
    public int LogicWCount;
    public int LogicHCount;
    public int LogicServerSizeX;
    public int LogicServerSizeY;

    public Material ChunkMat;

    public Texture2D BorderMarkerTex;
    public int MarkerTypeCount;
    public Rect heighRange;

    public TerrainSpriteFactory SpriteFactory;

    public int MaxLineNum;
    public TLineSetting TerrainLineSetting;

    public Material MarkerBoxMat;

    public Vector4 CoreAreaSetting;

    public WorldHUD[] worldMapHUD = new WorldHUD[(int)(WorldHUDType.DEFAULT)];
    public Sprite[] playerTitleBadge = new Sprite[6];
    public Sprite[] OfficialTitleBadge = new Sprite[11];
    public string[] OfficialTitleStrID = new string[11];
    public string[] GuildOfficialTitleStrID = new string[32];
    public Sprite[] GuildOfficialTitleBadge = new Sprite[32];
    public Sprite[] rebelIcon = new Sprite[2];
    public Sprite[] prisonIcon = new Sprite[2];

    public Material[] nationalFlags = new Material[30];

    private int mHeightMapWidth;
    public int HeightMapWidth
    {
        get
        {
            return mHeightMapWidth;
        }
    }

    private int mHeightMapHeight;
    public int HeightMapHeight
    {
        get
        {
            return mHeightMapHeight;
        }
    }

    private Chunk[] mChunks = null;

    public Chunk this[int i]
    {
        get
        {
            if (mChunks == null)
                return null;
            return mChunks[i];
        }
    }

    public Chunk[] Chunks
    {
        get
        {
            return mChunks;
        }
    }

    private Chunk mCenter = null;

    private int mChunkUpdateCount = 0;

    private int mLand;

    public int LandLayer
    {
        get
        {
            return mLand;
        }
    }

    private int mSprite;

    public int SpriteLayer
    {
        get
        {
            return mSprite;
        }
    }

    private Vector3[] mVertices;
    private Color[] mColors;
    private Vector3[] mNormals;
    private Vector2[] mUVs;
    private int[] mTriangles;
    private Mesh mCMesh;
    private Vector4 mHRValue;
    public Vector4 HRValue
    {
        get
        {
            return mHRValue;
        }
    }
    private Vector2 mHRValue1_5;
    public Vector4 HRValue1_5
    {
        get
        {
            return mHRValue1_5;
        }
    }
    private float mFWValue;
    public float FWValue
    {
        get
        {
            return mFWValue;
        }
    }
    private Vector2 mBlendRange;
    public Vector2 BlendRange
    {
        get
        {
            return mBlendRange;
        }
    }

    public Mesh WorldMesh
    {
        get
        {
            return mCMesh;
        }
    }

    public Vector3 CenterPos
    {
        get
        {
            if (mCenter == null)
            {
                return Vector3.zero;
            }
            return mCenter.WorldPos;
        }
    }

    public Chunk CenterChunk
    {
        get
        {
            return mCenter;
        }
    }

    public static Vector2[] ChunkMatrix = new Vector2[] {
        new Vector2(-1,1),new Vector2(0,1),new Vector2(1,1),
        new Vector2(-1,0),new Vector2(0,0),new Vector2(1,0),
        new Vector2(-1,-1),new Vector2(0,-1),new Vector2(1,-1),
    };

    private MeshCombine[] mSpriteCombines;

    private MeshCombine[] mFixedSpriteCombines;

    private LogicBlockMap mLBlockMap;

    private LogicBlockWorldMap mWBlockMap;

    public LogicBlockMap LBlockMap { get { return mLBlockMap; } }

    public LogicBlockWorldMap WBlockMap { get { return mWBlockMap; } }

    private Vector4 mTerrainWorldSetting;

    public Vector4 TerrainWorldSetting
    {
        get
        {
            return mTerrainWorldSetting;
        }
    }

    private TerrainBorderMarker mBorderMarker;



    public TerrainBorderMarker BorderMarker { get { return mBorderMarker; } }

    private World mWorld;

    public World world { get { return mWorld; } }

    private TLineManager mLineMgr;

    public TLineManager LineMgr { get { return mLineMgr; } }

    private TerrainMarkerBoxDrawer mBoxDrawer;

    private bool mNeedShowMarkerBox = false;

    public bool NeedShowMarkerBox { get { return mNeedShowMarkerBox; } set { mNeedShowMarkerBox = value; } }

    public TerrainMarkerBoxDrawer BoxDrawer { get { return mBoxDrawer; } }

    public IWorldData mDataInterface;


    public bool IsUpdateBuild = false;

    private int mLogicServerSize;

    public int LogicServerSize { get { return mLogicServerSize; } }

    private List<string> mHadShadowNames = new List<string> { "wgame/Terrain/Diffuse", "wgame/Terrain/Diffuse Build", "wgame/Terrain/Aircraft", "wgame/Terrain/Transparent" };
    public List<string> HadShadowNames { get { return mHadShadowNames; } }
    private void InitSpriteCombines()
    {
        int maxcout = Mathf.Max(1, Mathf.RoundToInt(MaxSpriteNumInChunk * world.MeshQuality));
        int vMaxCount = Mathf.RoundToInt(world.MeshCombMaxVCount * world.MeshQuality);

        mSpriteCombines = new MeshCombine[SpriteFactory.SpriteMeshs.Length];
        Material mat = null;
        for (int i = 0; i < SpriteFactory.SpriteMeshs.Length; i++)
        {
            mat = SpriteFactory.SpriteMeshs[i].mat;
            if (!world.SupportShadow && mHadShadowNames.Contains(mat.shader.name))
            {
                mat = new Material(mat);
                mat.shader = Shader.Find(mat.shader.name + " no Shadow");
            }
            mSpriteCombines[i] = new MeshCombine(SpriteFactory.SpriteMeshs[i].mesh,
                mat,
                SpriteFactory.SpriteMeshs[i].size,
                SpriteFactory.SpriteMeshs[i].castShadow ? SpriteLayer : 0,
                SpriteFactory.SpriteMeshs[i].maxNumInChunk < 0 ? maxcout : Mathf.Max(1, Mathf.RoundToInt(SpriteFactory.SpriteMeshs[i].maxNumInChunk * world.MeshQuality)),
                SpriteFactory.SpriteMeshs[i].maxVCount < 0 ? vMaxCount : Mathf.RoundToInt(SpriteFactory.SpriteMeshs[i].maxVCount * world.MeshQuality));
        }
        if (SpriteFactory.FixedSpriteMeshs == null)
        {
            mFixedSpriteCombines = new MeshCombine[0];
            return;
        }

        mFixedSpriteCombines = new MeshCombine[SpriteFactory.FixedSpriteMeshs.Length];
        for (int i = 0; i < SpriteFactory.FixedSpriteMeshs.Length; i++)
        {
            mat = SpriteFactory.FixedSpriteMeshs[i].mat;
            if (!world.SupportShadow && mHadShadowNames.Contains(mat.shader.name))
            {
                mat = new Material(mat);
                mat.shader = Shader.Find(mat.shader.name + " no Shadow");
            }
            mFixedSpriteCombines[i] = new MeshCombine(SpriteFactory.FixedSpriteMeshs[i].mesh,
                mat,
                SpriteFactory.FixedSpriteMeshs[i].size,
                SpriteFactory.FixedSpriteMeshs[i].castShadow ? SpriteLayer : 0,
                SpriteFactory.FixedSpriteMeshs[i].maxNumInChunk < 0 ? MaxSpriteNumInChunk : SpriteFactory.FixedSpriteMeshs[i].maxNumInChunk,
                SpriteFactory.FixedSpriteMeshs[i].maxVCount < 0 ? world.MeshCombMaxVCount : SpriteFactory.FixedSpriteMeshs[i].maxVCount);
        }

    }

    public void DrawSprites()
    {
        for (int i = 0; i < mSpriteCombines.Length; i++)
        {
            mSpriteCombines[i].DrawMesh();
        }
        for (int i = 0; i < mFixedSpriteCombines.Length; i++)
        {
            mFixedSpriteCombines[i].DrawMesh();
        }
        mLineMgr.DrawLine();
        mBoxDrawer.DrawMesh(mCenter.WorldPos, ChunkSize * 1.5f);
    }

    public void DrawSpritesNow()
    {
        for (int i = 0; i < mSpriteCombines.Length; i++)
        {
            mSpriteCombines[i].DrawMeshNow();
        }
        for (int i = 0; i < mFixedSpriteCombines.Length; i++)
        {
            mFixedSpriteCombines[i].DrawMeshNow();
        }
    }

    public int PushSpriteMeshInfo(TerrainSpriteData data, Vec2Int offset)
    {
        int index = mSpriteCombines[data.prototypeIndex].PushObjPoint(data);
        float offset_x = offset.x * HRValue.x;
        float offset_y = offset.y * HRValue.y;
        mSpriteCombines[data.prototypeIndex].Combine(data, index, offset_x, offset_y);
        return index;
    }

    public int GetFixedBorder(int sx, int sy, WorldData world)
    {
        if (sx == 0 && sy == 0)
            return 0;
        if (sx == 0 && sy == world.LogicServerSizeY - 1)
            return 1;
        if (sx == world.LogicServerSizeX - 1 && sy == world.LogicServerSizeY - 1)
            return 2;
        if (sx == world.LogicServerSizeX - 1 && sy == 0)
            return 3;
        if (sx > 0 && sx < world.LogicServerSizeX && (sy == 0 || sy == world.LogicServerSizeY - 1))
            return 4;
        if (sy > 0 && sy < world.LogicServerSizeX && (sx == 0 || sx == world.LogicServerSizeY - 1))
            return 5;
        return -1;
    }

    public int PushFixedSpriteMeshInfo(int fixed_type, Vec2Int wpos)
    {
        if (mFixedSpriteCombines.Length == 0)
            return -1;
        if (fixed_type >= mFixedSpriteCombines.Length)
        {
            return -1;
        }
        float x = Mathf.FloorToInt(wpos.x * LogicBlockSize) - HRValue.z;
        float z = Mathf.FloorToInt(wpos.y * LogicBlockSize) - HRValue.w;
        float y = mWorld.Build_Offset_Height;
        x += LogicBlockSize * 0.5f;
        z += LogicBlockSize * 0.5f;
        int index = mFixedSpriteCombines[fixed_type].PushObjPoint();
        mFixedSpriteCombines[fixed_type].Combine(index, x, y, z);
        return index;
    }

    public int PushFixedSpriteMeshInfo(int fixed_type, float x, float y, float z)
    {
        if (mFixedSpriteCombines.Length == 0)
            return -1;
        //x += LogicBlockSize * 0.5f;
        //z += LogicBlockSize * 0.5f;
        if (fixed_type >= mFixedSpriteCombines.Length)
        {
            return -1;
        }
        int index = mFixedSpriteCombines[fixed_type].PushObjPoint();
        mFixedSpriteCombines[fixed_type].Combine(index, x, y, z);
        return index;
    }

    public void PopSpriteMeshInfo(int prototypeIndex, int index)
    {
        mSpriteCombines[prototypeIndex].PopObjPoint(index);
    }

    public void PopFixedSpriteMeshInfo(int fixed_type, int index)
    {
        if (mFixedSpriteCombines.Length == 0)
            return;
        if (fixed_type >= mFixedSpriteCombines.Length)
        {
            return;
        }
        mFixedSpriteCombines[fixed_type].PopObjPointNoData(index);
    }


    public void ClearAllSprites()
    {
        for (int i = 0; i < 9; i++)
        {
            mChunks[i].ClearSprite();
        }
    }

    public void UpdateAllSpritesMesh()
    {
        //for (int i = 0; i < mSpriteCombines.Length; i++)
        //{
        //    if(mSpriteCombines[i].NeedUpdateMesh)
        //    {
        //        mSpriteCombines[i].UpdateMesh(mCenter.WorldPos, ChunkSize * 1.5f, true);
        //        mSpriteCombines[i].DontNeedUpdateMesh();
        //    }
        //}

        //for (int i = 0; i < mFixedSpriteCombines.Length; i++)
        //{
        //    if(mFixedSpriteCombines[i].NeedUpdateMesh)
        //    {
        //        mFixedSpriteCombines[i].UpdateMesh(mCenter.WorldPos, ChunkSize * 1.5f, true);
        //        mFixedSpriteCombines[i].DontNeedUpdateMesh();
        //    }
        //}
    }

    public void HideAllSpriteForBuild(ref QuadRect rect)
    {
        for (int i = 0; i < 9; i++)
        {
            if (mChunks[i].MeshRect.Intersects(ref rect))
            {
                mChunks[i].LBlockSet.HideSpriteForBuild();
            }
        }
    }

    private int mSpriteUpdateState = 0;
    private int mFixedSpriteUpdateState = 0;

    public void UpdateSprites(Vector3 center, float size)
    {
        if (mSpriteUpdateState >= mSpriteCombines.Length)
        {
            mSpriteUpdateState = 0;
        }
        if (mSpriteCombines.Length != 0)
        {
            if (mSpriteCombines[mSpriteUpdateState].NeedUpdateMesh)
            {
                mSpriteCombines[mSpriteUpdateState].UpdateMesh(center, size);
                mSpriteCombines[mSpriteUpdateState].DontNeedUpdateMesh();
            }
        }
        mSpriteUpdateState++;

        if (mFixedSpriteCombines.Length == 0)
            return;
        if (mFixedSpriteUpdateState >= mFixedSpriteCombines.Length)
        {
            mFixedSpriteUpdateState = 0;
        }
        if (mFixedSpriteCombines.Length != 0)
        {
            if (mFixedSpriteCombines[mFixedSpriteUpdateState].NeedUpdateMesh)
            {
                mFixedSpriteCombines[mFixedSpriteUpdateState].UpdateMesh(center, size * 4);
                mFixedSpriteCombines[mFixedSpriteUpdateState].DontNeedUpdateMesh();
            }
        }
        mFixedSpriteUpdateState++;
    }

    public void InitMeshInfo()
    {
        int vcount = ChunkMesh.vertices.Length;
        int count = vcount * ChunkMatrix.Length;
        mVertices = new Vector3[count];
        mColors = new Color[count];
        mNormals = new Vector3[count];
        mUVs = new Vector2[count];
        mCMesh = new Mesh();
        mCMesh.name = "[3DT]WorldData_Mesh";
        Vector3[] normals = ChunkMesh.normals;
        Vector2[] uvs = ChunkMesh.uv;
        int[] triangles = ChunkMesh.triangles;
        int triangles_count = triangles.Length;
        mTriangles = new int[triangles_count * ChunkMatrix.Length];
        for (int i = 0; i < ChunkMatrix.Length; i++)
        {
            System.Array.Copy(normals, 0, mNormals, i * vcount, vcount);
            System.Array.Copy(uvs, 0, mUVs, i * vcount, vcount);

            int start = i * triangles_count;
            for (int j = 0; j < triangles_count; j++)
            {
                mTriangles[start + j] = triangles[j] + i * vcount;
            }
        }
        mCMesh.vertices = mVertices;
        mCMesh.colors = mColors;
        mCMesh.uv = mUVs;
        mCMesh.triangles = mTriangles;
        mCMesh.normals = mNormals;
        mCMesh.MarkDynamic();
    }

    private void UpdateChunk2Mesh(Chunk chunk)
    {
        int start = chunk.Index * chunk.VCount;
        System.Array.Copy(chunk.Result_Vertices, 0, mVertices, start, chunk.VCount);
        System.Array.Copy(chunk.Result_Color, 0, mColors, start, chunk.VCount);
    }

    private void UpdateMesh(Vector3 center)
    {

        mCMesh.vertices = mVertices;
        mCMesh.colors = mColors;
        MeshCombine.UpdateMeshBounds(mCMesh, center, ChunkSize * 1.5f);
        //mCMesh.RecalculateBounds();
    }

    private void InitLogicBlock()
    {
        mLBlockMap = new LogicBlockMap(LogicBlockSize, LogicWCount, LogicHCount);
        mWBlockMap = new LogicBlockWorldMap(LogicServerSizeX, LogicServerSizeY);
    }

    public void InitBorderMarker()
    {
        //mBorderMarker = new TerrainBorderMarker(this);
        mBoxDrawer = new TerrainMarkerBoxDrawer(this);
    }

    private void InitChunks()
    {

        mCurChunkIndex = 0;
        mHeightMapWidth = (int)heighRange.width;
        mHeightMapHeight = (int)heighRange.height;

        mHRValue = new Vector4(heighRange.width, heighRange.height, heighRange.width * 0.5f, heighRange.height * 0.5f);
        mHRValue1_5 = new Vector2(mHRValue.z + mHRValue.x, mHRValue.w + mHRValue.y);
        mLogicServerSize = LogicServerSizeX / LogicWCount;
        mTerrainWorldSetting = new Vector4(HRValue.x, mLogicServerSize, 0, 0);
        mFWValue = 1 / heighRange.width;
        mBlendRange.x = 5.0f / mHeightMapWidth;
        mBlendRange.y = 5.0f / mHeightMapHeight;

        Vector2 lpos = Vector2.zero;
        if (mDataInterface != null)
            lpos = mDataInterface.GetInitPos();

        mChunks = new Chunk[ChunkMatrix.Length];
        Chunk chunk = null;
        for (int i = 0, imax = ChunkMatrix.Length; i < imax; i++)
        {
            chunk = new Chunk(i, this);
            chunk.UpdateLocalPos(ChunkMatrix[i] + lpos);
            //UpdateChunk2Mesh(chunk);
            mChunks[i] = chunk;
            if (ChunkMatrix[i].x == 0 && ChunkMatrix[i].y == 0)
            {
                mCenter = chunk;
            }
        }

        InitSpriteCombines();
        Shader.SetGlobalVector("_TerrainWorldSettings", TerrainWorldSetting);
        Shader.SetGlobalVector("_CoreAreaSettings", CoreAreaSetting);
        //UpdateMesh(mCenter.WorldPos);
    }

    private Chunk FindCenterChunk(Vector3 pos)
    {
        for (int i = 0, imax = mChunks.Length; i < imax; i++)
        {
            if (mChunks[i].isInChunk(pos))
                return mChunks[i];
        }
        return null;
    }

    private Chunk UpdateChunksPos(Vector3 pos)
    {
        Chunk center = null;
        Vector2 lpos = new Vector2(Mathf.RoundToInt(pos.x / ChunkSize), Mathf.RoundToInt(pos.z / ChunkSize));

        for (int i = 0, imax = ChunkMatrix.Length; i < imax; i++)
        {
            mChunks[i].UpdateLocalPos(ChunkMatrix[i] + lpos);
            //UpdateChunk2Mesh(mChunks[i]);
            if (ChunkMatrix[i].x == 0 && ChunkMatrix[i].y == 0)
            {
                center = mChunks[i];
            }
        }


        //UpdateMesh(center.WorldPos);
        mChunkUpdateCount = ChunkMatrix.Length;
        return center;
    }

    private void UpdateChunksPos(Chunk center, Vector3 pos, Vector2 dir, Vector2 source_Center)
    {
        if (dir.x != 0 && dir.y != 0)
        {
            mCenter = UpdateChunksPos(pos);
            mChunkUpdateCount = 0;
            return;
        }
        Vector2 cpos = center.localPos;
        Vector2 lpos;
        bool needUpdate = false;
        //Chunk[] needChunks = new Chunk[9];
        for (int i = 0, imax = mChunks.Length; i < imax; i++)
        {
            needUpdate = Vector2.Dot(dir, source_Center - mChunks[i].localPos) > 0;
            if (needUpdate)
            {
                lpos = dir * 3 + mChunks[i].localPos;
                mChunks[i].UpdateLocalPos(lpos);
                //UpdateChunk2Mesh(mChunks[i]);
                mChunkUpdateCount++;
                //needChunks[i] = mChunks[i];
            }
        }
        //if (mDataInterface != null)
        //    mDataInterface.ChunkUpdateNotify(LBlockMap.WorldPos2WLogicPos(center.WorldPos + Vector3.one * LogicBlockSize * 0.5f, this));
        //UpdateMesh(center.WorldPos);
    }

    public void CheckChunks(Vector3 pos)
    {
        if (mCenter.isinCenter(pos))
        {
            return;
        }
        mCenter.ForceUpdateSprite();
        mChunkUpdateCount = 0;
        Vector2 scenter = mCenter.localPos;
        mCenter = FindCenterChunk(pos);
        if (mCenter == null)
        {
            mCenter = UpdateChunksPos(pos);
            mChunkUpdateCount = 0;
            //if (mDataInterface != null)
            //    mDataInterface.ChunkUpdateNotify(LBlockMap.WorldPos2WLogicPos(mCenter.WorldPos + Vector3.one * LogicBlockSize * 0.5f, this));
        }
        else
        {
            Vector2 dir = (mCenter.localPos - scenter).normalized;
            UpdateChunksPos(mCenter, pos, dir, scenter);
            mChunkUpdateCount = 0;
        }
        if (mCenter.State != ChunkUpdateState.CUS_CHUNK_MESH)
        {
            mCenter.ForceUpdateSprite();
        }
        world.worldMapUpdata.UpdateObstacle();
    }

    private int mSpriteCacheCount = 0;
    public void UpdateChunkMesh()
    {
        bool need_update = false;
        for (int i = 0, imax = mChunks.Length; i < imax; i++)
        {
            if (mChunks[i].UpdateChunkMesh())
            {
                UpdateChunk2Mesh(mChunks[i]);
                need_update = true;
            }
        }
        if (need_update)
        {
            UpdateMesh(mCenter.WorldPos);
            mLineMgr.UpdateBound(mCenter.WorldPos, ChunkSize * 3f);
        }

        if (Time.frameCount % 10 == 0)
        {
            int sl = mSpriteCombines.Length;
            int fsl = mFixedSpriteCombines.Length;
            if (mSpriteCacheCount >= (sl + mFixedSpriteCombines.Length))
            {
                mSpriteCacheCount = 0;
            }
            if (mSpriteCacheCount >= sl)
            {
                if (fsl != 0)
                {
                    mFixedSpriteCombines[mSpriteCacheCount - sl].ClearCached();
                    mSpriteCacheCount++;
                }
            }
            else
            {
                if (sl != 0)
                {
                    mSpriteCombines[mSpriteCacheCount].ClearCached();
                    mSpriteCacheCount++;
                }

            }
        }
    }
    private int mCurChunkIndex = 0;
    private void UpdateChunkSprite()
    {
        bool updateSprites = true;
        if (mCurChunkIndex >= 9)
            mCurChunkIndex = 0;
        mChunks[mCurChunkIndex].UpdateSprite();
        for (int i = 0, imax = mChunks.Length; i < imax; i++)
        {
            if (mChunks[i].State != ChunkUpdateState.CUS_NIL)
                updateSprites = false;
        }
        mCurChunkIndex++;
        if (updateSprites)
        {
            //UpdateAllSpritesMesh();
            UpdateSprites(mCenter.WorldPos, ChunkSize * 1.5f);
            //mBorderMarker.Update();
            //mBoxDrawer.Apply();
            //world.ApplySMC();
        }
    }

    public void Update()
    {
        UpdateChunkMesh();
        if (WorldMapMgr.instance.NoUpdateWorld)
            UpdateChunkSprite();
        UpdateSelectRect();
        mLineMgr.Apply();
        mLineMgr.Update(Time.deltaTime);
        //UpdateServerData();
    }

    public void Init(int land, int sprite, World _world, IWorldData dataInterface)
    {
        Shader.SetGlobalFloat("_FogLineMax", FogMaxDis);
        Shader.SetGlobalColor("_FogColor", FogColor);
        mDataInterface = dataInterface;
        mWorld = _world;
        InitMeshInfo();
        mLand = land;
        mSprite = sprite;
        InitLogicBlock();
        InitChunks();
        //InitBorderMarker();
        if (SpriteFactory != null)
        {
            SpriteFactory.InitEx(this);
        }
        mLineMgr = new TLineManager(this, MaxLineNum, TerrainLineSetting, 17);
    }

    private Vector4 mSelectSetting = new Vector4();
    private float mShowSelectTime = -1;
    private Vec2Int mSelectv2i = new Vec2Int();
    public Vec2Int SelectV2i
    {
        get
        {
            return mSelectv2i;
        }
    }
    private void SetSelectShader()
    {
        Shader.SetGlobalVector("_SelectSetting", mSelectSetting);
    }

    //public void ShowSelectRect(Vector3 wpos, float show_time,int wsize = 1,int hsize = 1)
    //{
    //    wpos.x += LogicBlockSize*0.5f;
    //    wpos.z += LogicBlockSize*0.5f;
    //    mLBlockMap.WorldPos2WLogicPos(wpos, this, ref mSelectv2i);
    //    mLBlockMap.WLogicPos2WorldPos(ref wpos, ref mSelectv2i, this);
    //    mSelectSetting.x = wpos.x;
    //    mSelectSetting.y = wpos.z;
    //    Shader.EnableKeyword("_SELECT_ON");
    //    mSelectSetting.z = LogicBlockSize * 0.5f * wsize;
    //    mSelectSetting.w = LogicBlockSize * 0.5f * hsize;
    //    mShowSelectTime = Time.realtimeSinceStartup + show_time;
    //    SetSelectShader();
    //}

    //public void ShowSelectMultiRect(Vec2Int v, float show_time, int wsize = 1, int hsize = 1)
    //{
    //    Vector3 wpos = new Vector3();
    //    wpos.x = Mathf.FloorToInt(v.x * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
    //    wpos.z = Mathf.FloorToInt(v.y * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
    //    wpos.x += world.WorldInfo.LBlockMap.BlockSize * (0.5f + 0.5f * (wsize - 1)); ;
    //    wpos.z += world.WorldInfo.LBlockMap.BlockSize * (0.5f + 0.5f * (hsize - 1)); ;
    //    mSelectSetting.x = wpos.x;
    //    mSelectSetting.y = wpos.z;
    //    Shader.EnableKeyword("_SELECT_ON");
    //    mSelectSetting.z = LogicBlockSize * 0.5f * wsize;
    //    mSelectSetting.w = LogicBlockSize * 0.5f * hsize;
    //    mShowSelectTime = Time.realtimeSinceStartup + show_time;
    //    SetSelectShader();
    //}

    //public void ShowSelectRect(Vec2Int v, float show_time)
    //{
    //    Vector3 wpos = new Vector3();
    //    mLBlockMap.WLogicPos2WorldPos(ref wpos, ref v, this);
    //    mSelectSetting.x = wpos.x;
    //    mSelectSetting.y = wpos.z;
    //    Shader.EnableKeyword("_SELECT_ON");
    //    mSelectSetting.z = LogicBlockSize * 0.5f;
    //    mSelectSetting.w = LogicBlockSize * 0.5f;
    //    mShowSelectTime = Time.realtimeSinceStartup + show_time;
    //    SetSelectShader();
    //}

    /// <summary>
    /// 在给定位置按照给定参数显示3D大地图选中框
    /// </summary>
    /// <param name="v">选中框位置</param>
    /// <param name="width">选中框宽度（X差值）</param>
    /// <param name="height">选中框高度（Y差值）</param>
    /// <param name="showTime">选中框显示时长</param>
    public void ShowSelectionBox(Vec2Int v, int width, int height, float showTime)
    {
        float x = (v.x + width / 2f) * world.WorldInfo.LBlockMap.BlockSize - world.WorldInfo.HRValue.z + 0.75f;
        float z = (v.y + height / 2f) * world.WorldInfo.LBlockMap.BlockSize - world.WorldInfo.HRValue.z + 0.5f;
        world.SelectionBox.transform.position = new Vector3(x, 0, z);
        world.SelectionBox.GetComponentInChildren<UITexture>().SetDimensions(256 * width, 256 * height);
        world.SelectionBox.enabled = true;

        mSelectSetting.x = x;
        mSelectSetting.y = z;
        mSelectSetting.z = LogicBlockSize * 0.5f * width;
        mSelectSetting.w = LogicBlockSize * 0.5f * height;
        mShowSelectTime = Time.realtimeSinceStartup + showTime;
        Shader.EnableKeyword("_SELECT_ON");
        SetSelectShader();
    }

    public void UpdateSelectRect()
    {
        if (mShowSelectTime >= 0 && Time.realtimeSinceStartup >= mShowSelectTime)
        {
            world.SelectionBox.enabled = false;
            Shader.DisableKeyword("_SELECT_ON");
            mShowSelectTime = -1;
            SetSelectShader();
        }
    }

    public static bool RectContains(QuadRect rect, float x, float y)
    {
        return x >= rect.MinX && y >= rect.MinY && x <= rect.MaxX && y <= rect.MaxY;
    }

    public static bool RectContains(QuadRect rect, int x, int y)
    {
        return x >= rect.MinX && y >= rect.MinY && x <= rect.MaxX && y <= rect.MaxY;
    }

    public static bool RectContainsGreater(QuadRect rect, int x, int y)
    {
        return x >= rect.MinX && y >= rect.MinY && x < rect.MaxX && y < rect.MaxY;
    }

    public TLine AddLine(int id, Vector3 start, Vector3 end, Vec2Int targetPos, Color color, float speed, int plane_type, int type, int status, int entryType, int cur_time, int start_time, int total_time, bool isEffect)
    {
        return mLineMgr.Push(id, start, end, targetPos, color, speed, plane_type, type, status, entryType, cur_time, start_time, total_time, isEffect);
    }

    public TLine AddLine(Vector3 start, Vector3 end, Color color, float speed)
    {
        return mLineMgr.Push4OnlyLine(start, end, color, speed);
    }

    public void RemoveLine(TLine line)
    {
        if (line == null)
            return;
        mLineMgr.Pop(line);
    }


    public void ApplyLine()
    {
        mLineMgr.Apply();
    }

    public void Destroy()
    {
        SpriteFactory.Clear();
        for (int i = 0; i < mSpriteCombines.Length; i++)
            mSpriteCombines[i].Destroy();
        mSpriteCombines = null;
        for (int i = 0; i < mFixedSpriteCombines.Length; i++)
            mFixedSpriteCombines[i].Destroy();
        mFixedSpriteCombines = null;
        //mBorderMarker.Destroy();
        mBorderMarker = null;
        mBoxDrawer = null;
        mLBlockMap.Destroy();
        mLBlockMap = null;
        mWBlockMap.Destroy();
        mWBlockMap = null;
        for (int i = 0, imax = ChunkMatrix.Length; i < imax; i++)
        {
            mChunks[i].Destroy();
        }
        mChunks = null;

        mVertices = null;
        mColors = null;
        mNormals = null;
        mUVs = null;
        GameObject.Destroy(mCMesh);
        mTriangles = null;
        mCenter = null;

        mChunkUpdateCount = 0;
    }
}
