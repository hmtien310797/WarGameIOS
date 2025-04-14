using UnityEngine;
using System.Collections;
using Serclimax.QuadSpace;
public enum ChunkUpdateState
{
    CUS_NIL,
    CUS_CHUNK_MESH,
    CHS_CHUNK_SPRITE,
    CHS_CHANGE,
}

[System.Serializable]
public class Chunk
{
    private WorldData mWorld;
    private Vector3[] mSVertices;
    private Vector3[] mTVertices;
    private Color[] mColors;
    private Vector2 mLocalPos;
    private Vector3 mWorldPos;
    private QuadRect mChunkCenterRect;
    private QuadRect mChunkRect;
    private QuadRect mChunkMeshRect;
    private int mIndex;
    private int mVertexCount;
    private ChunkUpdateState mState;
    private TerrainSpriteChunk mSprite;
    private LogicBlockSet mlBlockSet;
    public int Index
    {
        get { return mIndex; }
    }

    public int VCount
    {
        get { return mVertexCount; }
    }

    public ChunkUpdateState State
    {
        get
        {
            return mState;
        }
    }

    public LogicBlockSet LBlockSet { get { return mlBlockSet;} }

    public Vector2 localPos
    {
        get
        {
            return mLocalPos;
        }
    }

    public Vector3 WorldPos
    {
        get
        {
            return mWorldPos;
        }
    }

    public Vector3[] Result_Vertices
    {
        get
        {
            return mTVertices;
        }
    }

    public Color[] Result_Color
    {
        get
        {
            return mColors;
        }
    }

    public QuadRect MeshRect
    {
        get
        {
            return mChunkMeshRect;
        }
    }

    public WorldData worldData
    {
        get
        {
            return mWorld;
        }
    }

    public TerrainSpriteChunk SpriteChunk
    {
        get
        {
            return mSprite;
        }
    }

    public Chunk(int index, WorldData world)
    {
        mIndex = index;
        mWorld = world;
        float csize = mWorld.ChunkSize;
        float size = mWorld.ChunkSize * 1.01f;
        mChunkCenterRect = new QuadRect(0, 0, size, size);
        mChunkRect = new QuadRect(0, 0, csize, csize);
        mChunkMeshRect = new QuadRect(0, 0, mWorld.ChunkSize, mWorld.ChunkSize);
        mSVertices = mWorld.ChunkMesh.vertices;
        mVertexCount = mSVertices.Length;
        mTVertices = new Vector3[mVertexCount];
        System.Array.Copy(mSVertices, mTVertices, mVertexCount);
        mVertexCount = mSVertices.Length;
        mColors = mWorld.ChunkMesh.colors;
        if (mColors.Length != mVertexCount)
        {
            mColors = new Color[mVertexCount];
        }
        mSprite = new TerrainSpriteChunk(mWorld);

        mlBlockSet = new LogicBlockSet(this,mWorld);
        mState = ChunkUpdateState.CUS_NIL;
    }

    void UpdateMesh()
    {
        HMMeshTool.HeighMap2MeshSimple(mSVertices, mTVertices, mWorldPos, mWorld);
    }

    private void UpdateWorldPos()
    {
        Vector2 pos = mLocalPos * mWorld.ChunkSize;
        mWorldPos.x = pos.x;
        mWorldPos.z = pos.y;
        mChunkCenterRect.SetPos(pos.x, pos.y);
        mChunkRect.SetPos(pos.x, pos.y);
        mChunkMeshRect.SetPos(pos.x, pos.y);
    }

    public void UpdateLocalPos(Vector2 pos)
    {
        mLocalPos = pos;
        UpdateWorldPos();
        mState = ChunkUpdateState.CUS_CHUNK_MESH;
        //UpdateMesh();
    }

    public bool UpdateChunkMesh()
    {
        if(ChunkUpdateState.CUS_CHUNK_MESH != mState)
            return false;
        
        UpdateMesh();
        mState = ChunkUpdateState.CHS_CHUNK_SPRITE;
        return true;
    }

    public void ClearSprite()
    {
        mSprite.Reset();
    }

    public void ForceUpdateSprite()
    {
         mState = ChunkUpdateState.CHS_CHUNK_SPRITE;
    }

    public void UpdateSprite()
    {
        switch(mState)
        {
            case ChunkUpdateState.CHS_CHUNK_SPRITE:
                mSprite.Reset();
                mlBlockSet.Update();
                mState = ChunkUpdateState.CHS_CHANGE;
                break;
            case ChunkUpdateState.CHS_CHANGE:
                mSprite.FillSprite(this);
                mState = ChunkUpdateState.CUS_NIL;
                break;
            case ChunkUpdateState.CUS_NIL:
                break;
        }
    }

    public bool isinCenter(Vector3 pos)
    {
        return WorldData.RectContains(mChunkCenterRect,pos.x,pos.z);
        //return mChunkCenterRect.Contains(pos.x, pos.z);
    }

    public bool isInChunk(Vector3 pos)
    {
        return WorldData.RectContains(mChunkRect,pos.x,pos.z);
        //return mChunkRect.Contains(pos.x, pos.z);
    }

    public Color GetColor(int index)
    {
        return mColors[index];
    }

    public void Destroy()
    {

        mIndex = -1;
        mWorld = null;
        mSVertices =null;
        mTVertices = null;
        mColors = null;
        mSprite.Destroy();
        mSprite = null;

        mlBlockSet.Destroy();
        mlBlockSet = null;
        mState = ChunkUpdateState.CUS_NIL;
    }

}
