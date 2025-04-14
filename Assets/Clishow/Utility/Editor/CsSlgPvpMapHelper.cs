using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(CsSLGPVPMap))]
public class CsSlgPvpMapHelper : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        CsSLGPVPMap map = target as CsSLGPVPMap;

        EditorGUILayout.BeginVertical();
        if (GUILayout.Button("Reset"))
        {
            if (map.map == null)
            {
                map.EditorInitMap();
                Repaint();
            }
            else
            {
                map.map.Clear();
                Vector2 pos = Vector2.zero;
                pos.x = map.transform.position.x;
                pos.y = map.transform.position.z;
                map.map.Init(map.width, map.height, map.unit_size, pos);
                int count = map.transform.childCount;
                if (count != 0)
                {
                    uint guid = map.map.NextValidGuid();
                    for (int i = 0; i < count; i++)
                    {
                        Transform trf = map.transform.GetChild(i);
                        if (trf != null)
                        {
                            int w = Mathf.CeilToInt(trf.localScale.x / map.unit_size);
                            int h = Mathf.CeilToInt(trf.localScale.z / map.unit_size);
                            Vector3 pos3 = trf.position;
                            Vector2 pos2 = Vector2.zero;
                            pos2.x = pos3.x - ((int)(w / 2)) * map.unit_size;
                            pos2.y = pos3.z - ((int)(h / 2)) * map.unit_size;
                            int nextx = 0, nexty = 0;
                            map.map.WorldToGridPos(pos2, ref nextx, ref nexty);
                            map.map.ForceStation(nextx, nexty, w, h, guid);
                        }
                    }
                }
                Repaint();
            }
        }
        if (GUILayout.Button("Save"))
        {
            if (map.map != null)
            {
                string path = Application.dataPath + "/" + map.name + ".txt";
                Clishow.CsFileHelper.WriteTxtFile(map.map.Save(), path);
            }
        }
        EditorGUILayout.EndVertical();
    }
    private void OnSceneGUI()
    {
        if (CsSLGPVPMgr.instance.BattleController != null)
        {
            CsGridMapDrawer.DrawMap(CsSLGPVPMgr.instance.BattleController.Battle.GridMap);
        }
        else
        {
            CsSLGPVPMap map = target as CsSLGPVPMap;
            CsGridMapDrawer.DrawMap(map.map);
        }
    }
}
