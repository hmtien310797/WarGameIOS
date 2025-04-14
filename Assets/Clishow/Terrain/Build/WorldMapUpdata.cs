using UnityEngine;
using System.Collections;

public class WorldMapUpdata
{
    
    public WorldMapBuild worldMapBuild = new WorldMapBuild();
    public WorldMapAircraft worldMapAircraft = new WorldMapAircraft();
    public WorldMapTerritory worldMapTerritory = new WorldMapTerritory();
    public WorldMapObstacle worldMapObstacle = new WorldMapObstacle();
    public WorldMapEffect worldMapEffect;


    public QuadRect CurRect;
    //WorldUpdateState updateState;

    public void Init(World w) {
        worldMapBuild.Init(w);
        worldMapAircraft.Init(w);
        worldMapTerritory.Init(worldMapBuild.width, worldMapBuild.height, worldMapBuild.size, w);
        worldMapEffect = w.worldMapEffect;
        worldMapObstacle.init(w);
    }


    public void UpdateBuild(QuadRect curRect) {
        //if(curRect.Width == 0 && curRect.Height == 0)
        //    return;
        //if (worldMapBuild.buildState == BuildState.Normal)
        //    worldMapBuild.buildState = BuildState.Start;
        //else
        //    return;
        CurRect = curRect;
        worldMapBuild.buildState = BuildState.Start;
    }

    public void UpdateAircraft(QuadRect curRect) {
        CurRect = curRect;
        //worldMapAircraft.buildState = BuildState.Start;
        worldMapAircraft.Aircraft();
    }

    public void UpdateTerritory(QuadRect curRect) {
        //if (worldMapTerritory.buildState == BuildState.Normal)
        //    worldMapTerritory.buildState = BuildState.Start;
        //else
        //    return;
        CurRect = curRect;
        worldMapTerritory.buildState = BuildState.Start;
    }

    public void UpdateObstacle() {
        worldMapObstacle.RefrushObstacle();
    }



    public void MapUpdate() {
        worldMapBuild.UpdateBuild();
        worldMapAircraft.UpdateAircraft();
        worldMapEffect.UpdateEffects();
        worldMapTerritory.UpdateTerritory();


    }

    public int GetNumberPos(int num, int count)
    {
        if (count == 0)
        {
            return num % 10;
        }
        else
        {
            return num / (int)Mathf.Pow(10, count) % 10;
        }
    }

}
//public enum WorldUpdateState {
//    Normal,
//    Start,
//    Build
//}

public enum BuildState
{
    Normal,
    Start,
    Build,
    End

}