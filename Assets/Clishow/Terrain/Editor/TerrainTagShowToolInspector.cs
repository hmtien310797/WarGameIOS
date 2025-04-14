using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(TerrainTagShowTool))]
public class TerrainTagShowToolInspector : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

    }

    public float GetTerrainHeight(Vector3 wpos, Terrain terrain)
    {
        Vector2 uv = Vector2.zero;
        uv.x = wpos.x / terrain.terrainData.size.x;
        uv.y = wpos.z / terrain.terrainData.size.z;
        int px = Mathf.Min((int)terrain.terrainData.size.x - 1, (int)((1 - uv.x) * terrain.terrainData.size.x));
        int py = Mathf.Min((int)terrain.terrainData.size.z - 1, (int)((1 - uv.y) * terrain.terrainData.size.z));

        return terrain.terrainData.GetHeight(px, py) * terrain.terrainData.size.y;
    }

    //void OnSceneGUI()
    //{
    //    TerrainTagShowTool t = (TerrainTagShowTool)target;
    //    if (t.terrain == null || t.data == null)
    //        return;
    //    if (!t.ShowTag)
    //        return;
    //    int wc = t.data.LogicWCount;
    //    int hc = t.data.LogicHCount;
    //    float block_size = t.data.LogicBlockSize;
    //    int index = 0;
    //    for (int x = 0; x < wc; x++)
    //    {
    //        for (int y = 0; y < hc; y++)
    //        {

    //            index = (wc - x - 1) * hc + (hc-1 -y);
    //            if(t.data.LogicTags.Length <= index)
    //                return;
    //            Vector3 cp = new Vector3((x * block_size + block_size * 0.5f), 0, (y * block_size + block_size * 0.5f));
    //            int tag = t.data.LogicTags[index];
    //            Color c;
    //            switch(tag)
    //            {
    //                case 0:
    //                    c = Color.white;
    //                    c.a = 0.5f;
    //                Handles.color = c;
    //                Handles.CubeCap(0, cp, Quaternion.AngleAxis(90, Vector3.right), block_size * 0.25f);
    //                Handles.RectangleCap(0, cp, Quaternion.AngleAxis(90, Vector3.right), block_size * 0.5f);
    //                    break;
    //                case 1:
    //                    c = Color.blue;
    //                    c.a = 0.5f;
    //                Handles.color = c;
    //                    Handles.CubeCap(0, cp, Quaternion.AngleAxis(90, Vector3.right), block_size * 0.25f);
    //                Handles.RectangleCap(0, cp, Quaternion.AngleAxis(90, Vector3.right), block_size * 0.5f);
    //                    break;
    //                case 2:
    //                    c = Color.red;
    //                    c.a = 0.5f;
    //                Handles.color = c;
    //                    Handles.CubeCap(0, cp, Quaternion.AngleAxis(90, Vector3.right), block_size * 0.25f);
    //                Handles.RectangleCap(0, cp, Quaternion.AngleAxis(90, Vector3.right), block_size * 0.5f);
    //                    break;
    //            }
    //        }
    //    }
    //}
}
