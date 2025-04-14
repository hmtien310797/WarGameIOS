using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using ProtoMsg;
using Serclimax;

public class BorderData
{
    public Dictionary<int, Dictionary<int, MapGuildBlock>> MapGuildBlock = new Dictionary<int, Dictionary<int, MapGuildBlock>>();
    World world;
    ScUnionBadgeColorData[] scUnionBadgeColorData;
    
    public void Init(World w)
    {
        world = w;
        scUnionBadgeColorData = Main.Instance.TableMgr.GetUnionBadgeColorList();
    }
    public void ClearCache(int index)
    {
        if (MapGuildBlock.ContainsKey(index))
            MapGuildBlock[index].Clear();
    }

    public void ClearAllCache()
    {
        MapGuildBlock.Clear();
    }

    public void SetBorderData(int x, int y, MapGuildBlock mapGuildBlock)
    {
        int lindex = (world.WorldInfo.LogicServerSizeX - x - 1) * world.WorldInfo.LogicServerSizeX + y;
        world.WorldInfo.WBlockMap.SetTerritory(lindex, (int)Mathf.Clamp(Mathf.Floor((int)mapGuildBlock.guildbadge % 10000 / 100), 1, scUnionBadgeColorData.Length) + (int)(mapGuildBlock.guildid << 8));
    }

    public MapGuildBlock GetBorderDataByXY(int x, int y)
    {
        MapGuildBlock mapBlock = null;
        //int dataIndex = y * world.WorldInfo.LogicServerSizeY + x;
        //MapGuildBlock.TryGetValue(dataIndex, out mapBlock);
        int xScreen = x / (WorldMapNet.ServerBlockSize/2);
        int yScreen = y / (WorldMapNet.ServerBlockSize/2);
        int posi = yScreen * (WorldMapNet.ServerBlockTotalCount * 2) + xScreen;
        int lindex = y * world.WorldInfo.LogicServerSizeY + x;
        if (MapGuildBlock.ContainsKey(posi))
        {
            //for (int i = 0; i < MapGuildBlock[posi].Count; i++)
            //{
            //    MapGuildBlock mapGuildBlock = MapGuildBlock[posi][i];
            //    if (mapGuildBlock.pos[0].x == x && mapGuildBlock.pos[0].y == y) {
            //        return MapGuildBlock[posi][i];
            //    }
            //}
            if (MapGuildBlock[posi].ContainsKey(lindex)) {
                return MapGuildBlock[posi][lindex];
            }

        }
        
        //for (int i = 0; i < world.worldMapNet.msgSceneMapGuildFieldResponse.fields.Count; i++)
        //{
        //    for (int q = 0; q < world.worldMapNet.msgSceneMapGuildFieldResponse.fields[i].pos.Count; q++)
        //        if (world.worldMapNet.msgSceneMapGuildFieldResponse.fields[i].pos[q].x == x && world.worldMapNet.msgSceneMapGuildFieldResponse.fields[i].pos[q].y == y)
        //        {
        //            uint a = world.worldMapNet.msgSceneMapGuildFieldResponse.fields[i].posindex;
        //        }

        //}

        return mapBlock;
    }

    public uint GetGuildIdByXY(int x,int y)
    {
        MapGuildBlock borderData = GetBorderDataByXY(x,y);
        if(borderData == null)
            return 0;
        return borderData.guildid;
    }

    public bool IsEnemyBorder(int x,int y,uint slet_guildId)
    {
        uint guild_id = GetGuildIdByXY(x,y);
        return guild_id != 0 && guild_id != slet_guildId;
    }

    public bool IsSelfBorder(int x,int y,uint slef_guildId)
    {
        uint guild_id = GetGuildIdByXY(x,y);
        return guild_id != 0 && guild_id == slef_guildId;
    }

    public bool IsSelfNeighboringBorder(int x,int y,uint slef_guildId)
    {
        if(x>0 && IsSelfBorder(x-1,y,slef_guildId))
            return true;
        if(y>0 && IsSelfBorder(x,y-1,slef_guildId))
            return true;
        if(x<(world.WorldInfo.LogicServerSizeX -1) && IsSelfBorder(x+1,y,slef_guildId))
            return true;
        if(y<(world.WorldInfo.LogicServerSizeY - 1) && IsSelfBorder(x,y+1,slef_guildId))
            return true;
        return false;
    }
}

//public class MapBlock {
//    public Position pos;
//    public int guildid;
//    public string guildname;
//    public string guildbanner;
//    public int guildbadge; 
//}