using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class WorldMapObstacle {
    World world;

    WorldObject[] objects = new WorldObject[50];

    int[] indexs = new int[100];

    WorldObject[] worldObjects;
    List<ChunkObstacle> ChunkObstacles = new List<ChunkObstacle>();
    ChunkObstacle hideChunkObstacle;
    int windex;
    bool haveSprite;

    public void init(World w) {
        world = w;
    }

    public void RefrushObstacle() {
        Vector3 min = new Vector3(world.WorldInfo.CenterPos.x - world.WorldInfo.ChunkSize * 1.5f, 0, world.WorldInfo.CenterPos.z - world.WorldInfo.ChunkSize * 1.5f);
        Vector3 max = new Vector3(world.WorldInfo.CenterPos.x + world.WorldInfo.ChunkSize * 1.5f, 0, world.WorldInfo.CenterPos.z + world.WorldInfo.ChunkSize * 1.5f);

        int count = world.World3D.GetObjects((int)(min.x + world.WorldInfo.HRValue.z), (int)(min.z + world.WorldInfo.HRValue.z), (int)(max.x + world.WorldInfo.HRValue.z), (int)(max.z + world.WorldInfo.HRValue.z), objects);

        for (int o = ChunkObstacles.Count - 1; o >= 0; o--)
        {
            haveSprite = false;
            for (int i = 0; i < count; i++) 
                if (objects[i].worldX == ChunkObstacles[o].wPosx && objects[i].worldZ == ChunkObstacles[o].wPosy && objects[i].id == ChunkObstacles[o].typeId)
                {
                    haveSprite = true;
                    break;
                }

            if (!haveSprite)
                HideSpriteObstacle(ChunkObstacles[o]);
        }

        for (int i = 0; i < count; i++)
        {
            haveSprite = false;
            for (int o = 0; o < ChunkObstacles.Count; o++)
                if (objects[i].worldX == ChunkObstacles[o].wPosx && objects[i].worldZ == ChunkObstacles[o].wPosy && objects[i].id == ChunkObstacles[o].typeId)
                {
                    haveSprite = true;
                    break;
                }

            if (!haveSprite)
                AddSpriteObstacle(objects[i].id, objects[i].worldX, 0.3f, objects[i].worldZ, min, max);
        }    
    }

    void AddSpriteObstacle(int id, float x, float y, float z, Vector3 min, Vector3 max)
    {
        float worldMapSize = world.WorldInfo.LogicServerSizeX * WorldMapNet.ServerBlockSize;

        float actualX = x;
        if (actualX > max.x)
            actualX -= Mathf.Floor((actualX - min.x) / worldMapSize) * worldMapSize;
        else if (actualX < min.x)
            actualX += Mathf.Floor((max.x - actualX) / worldMapSize) * worldMapSize;

        float actualZ = z;
        if (actualZ > max.z)
            actualZ -= Mathf.Floor((actualZ - min.z) / worldMapSize) * worldMapSize;
        else if (actualZ < min.z)
            actualZ += Mathf.Floor((max.z - actualZ) / worldMapSize) * worldMapSize;

        int spriteid = world.WorldInfo.PushFixedSpriteMeshInfo(id, actualX - world.WorldInfo.HRValue.z, y, actualZ - world.WorldInfo.HRValue.z);

        ChunkObstacle chunkObstacle = new ChunkObstacle();
        chunkObstacle.spriteid = spriteid;
        chunkObstacle.typeId = id;
        chunkObstacle.wPosx = x;
        chunkObstacle.wPosy = z;
        ChunkObstacles.Add(chunkObstacle);
    }

    void HideSpriteObstacle(ChunkObstacle co) {
        if (co != null)
        {
            world.WorldInfo.PopFixedSpriteMeshInfo(co.typeId, co.spriteid);
            ChunkObstacles.Remove(co);
        }
    }


}

public class ChunkObstacle
{
    public int spriteid;
    public int typeId;
    public float wPosx;
    public float wPosy;
}
