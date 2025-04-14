using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(TerrainObstacle))]
public class TerrainObstacleInspector : Editor
{
    Vector3 pos;
    int windex;
    Vec2Int wmin;
    Vec2Int wmax;
    // Use this for initialization
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

    }

    // Update is called once per frame
    void OnSceneGUI() {
        Vector3 min = new Vector3(WorldMapMgr.Instance.world.WorldInfo.CenterPos.x - WorldMapMgr.Instance.world.WorldInfo.ChunkSize * 1.5f, 0, WorldMapMgr.Instance.world.WorldInfo.CenterPos.z - WorldMapMgr.Instance.world.WorldInfo.ChunkSize * 1.5f);
        Vector3 max = new Vector3(WorldMapMgr.Instance.world.WorldInfo.CenterPos.x + WorldMapMgr.Instance.world.WorldInfo.ChunkSize * 1.5f, 0, WorldMapMgr.Instance.world.WorldInfo.CenterPos.z + WorldMapMgr.Instance.world.WorldInfo.ChunkSize * 1.5f);

        wmin = WorldMapMgr.Instance.world.WorldInfo.LBlockMap.WorldPos2WLogicPos(min + Vector3.one * WorldMapMgr.Instance.world.WorldInfo.LBlockMap.BlockSize * 0.5f, WorldMapMgr.Instance.world.WorldInfo);
        wmax = WorldMapMgr.Instance.world.WorldInfo.LBlockMap.WorldPos2WLogicPos(max + Vector3.one * WorldMapMgr.Instance.world.WorldInfo.LBlockMap.BlockSize * 0.5f, WorldMapMgr.Instance.world.WorldInfo);

        for (int x = 0; x < wmax.x - wmin.x; x++)
        {
            for (int y = 0; y < wmax.y - wmin.y; y++)
            {
                pos = WorldMapMgr.Instance.GetCurPosToWorldPos(wmin.x + x, wmin.y + y, 0.5f);
                int wx = (wmin.x + x) % 512;
                if (wx < 0)
                    wx = 512 + wx;
                int wy = (wmin.y + y) % 512;
                if (wy < 0)
                    wy = 512 + wy;
                windex = (511 - wx) * 512 + (511 - wy);
                if (!Main.Instance.isOccupied(WorldObjectType.ALL, wx, wy))
                {
                    Handles.color = Color.white;
                    Handles.CubeHandleCap(
                        0, 
                        pos, 
                        Quaternion.AngleAxis(90, Vector3.right), 
                        WorldMapMgr.Instance.world.WorldInfo.LBlockMap.BlockSize * 0.25f, 
                        EventType.Repaint
                    );
                    Handles.RectangleHandleCap(
                        0, 
                        pos, 
                        Quaternion.AngleAxis(90, Vector3.right), 
                        WorldMapMgr.Instance.world.WorldInfo.LBlockMap.BlockSize * 0.5f, 
                        EventType.Repaint
                    );
                }
                else {
                    Handles.color = Color.red;
                    Handles.CubeHandleCap(
                        0, 
                        pos, 
                        Quaternion.AngleAxis(90, Vector3.right), 
                        WorldMapMgr.Instance.world.WorldInfo.LBlockMap.BlockSize * 0.25f, 
                        EventType.Repaint
                    );
                    Handles.RectangleHandleCap(
                        0, 
                        pos, 
                        Quaternion.AngleAxis(90, Vector3.right), 
                        WorldMapMgr.Instance.world.WorldInfo.LBlockMap.BlockSize * 0.5f, 
                        EventType.Repaint
                    );
                }
                    
            }
        }
    }
}
