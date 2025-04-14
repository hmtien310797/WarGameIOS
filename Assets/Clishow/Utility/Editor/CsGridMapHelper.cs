using UnityEditor;
using UnityEngine;
using System.Collections;

public class CsGridMapDrawer
{
    public static void DrawMap(Serclimax.SLGPVP.ScGridMap map)
    {
        if (map == null)
            return;
        Vector2 pos2 = Vector2.zero;
        Vector3 pos3 = Vector3.zero;
        Quaternion quat = Quaternion.identity;
        int w = map.Width;
        int h = map.Height;
        for (int i = 0; i < w; i++)
        {
            for (int j = 0; j < h; j++)
            {
                map.GridToWorldPos(i, j, ref pos2);
                pos3.x = pos2.x;
                pos3.z = pos2.y;
                if (map.GetGuid(i, j) != 0)
                {
                    Handles.color = Color.red;
                    Serclimax.SLGPVP.ScGridObj gobj = map.FindObj(i, j);
                    if (gobj != null)
                    {
                        if (gobj.customObj != null)
                        {
                            CsGridObj csobj = gobj.customObj as CsGridObj;
                            if (csobj != null)
                            {
                                if (csobj.needMoved)
                                    Handles.color = Color.blue;
                            }

                        }
                    }

                }
                else
                    Handles.color = Color.white;
                Handles.CubeHandleCap(
                    0, 
                    pos3, 
                    quat, 
                    map.DUnitSize * 0.5f, 
                    EventType.Repaint
                );

            }
        }
    }
}

public class CsGridMapRoot
{
    private Serclimax.SLGPVP.ScGridMap mMap;
    public CsGridMapRoot(Serclimax.SLGPVP.ScGridMap map)
    {
        mMap = map;
        Init();
    }

    private GameObject mRoot;
    private GameObject[,] mCubes;
    public void Init()
    {
        mCubes = new GameObject[mMap.Width, mMap.Height];
        mRoot = new GameObject("grid_root");
        Vector2 pos2 = Vector2.zero;
        Vector3 pos3 = Vector3.zero;
        Quaternion quat = Quaternion.identity;
        int w = mMap.Width;
        int h = mMap.Height;
        GameObject cube = null;
        for (int i = 0; i < w; i++)
        {
            for (int j = 0; j < h; j++)
            {
                mMap.GridToWorldPos(i, j, ref pos2);
                pos3.x = pos2.x;
                pos3.z = pos2.y;
                cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                cube.transform.parent = mRoot.transform;
                cube.transform.localPosition = pos3;
                cube.transform.localScale = Vector3.one * (mMap.DUnitSize * 0.5f);
                mCubes[i, j] = cube;
            }
        }
    }

    public void Clear()
    {
        GameObject.DestroyImmediate(mRoot);
        mCubes = null;
    }
}


//[CustomEditor(typeof(CsGridMap))]
//public class CsGridMapHelper : Editor
//{
//    private CsGridMapRoot mMapRoot = null;
//    public override void OnInspectorGUI()
//    {
//        base.OnInspectorGUI();
//        CsGridMap map = target as CsGridMap;

//        EditorGUILayout.BeginVertical();
//        if (GUILayout.Button("Reset"))
//        {
//            if (map.map == null)
//            {
//                map.Awake();
//                Repaint();
//            }
//            else
//            {
//                map.map.Clear();
//                Vector2 pos = Vector2.zero;
//                pos.x = map.transform.position.x;
//                pos.y = map.transform.position.z;
//                map.map.Init(map.width, map.height, map.unit_size, pos);
//                int count = map.transform.childCount;
//                if (count != 0)
//                {
//                    uint guid = map.map.NextValidGuid();
//                    for (int i = 0; i < count; i++)
//                    {
//                        Transform trf = map.transform.GetChild(i);
//                        if (trf != null)
//                        {
//                            int w = Mathf.CeilToInt(trf.localScale.x / map.unit_size);
//                            int h = Mathf.CeilToInt(trf.localScale.z / map.unit_size);
//                            Vector3 pos3 = trf.position;
//                            Vector2 pos2 = Vector2.zero;
//                            pos2.x = pos3.x - ((int)(w / 2)) * map.unit_size;
//                            pos2.y = pos3.z - ((int)(h / 2)) * map.unit_size;
//                            int nextx = 0, nexty = 0;
//                            map.map.WorldToGridPos(pos2, ref nextx, ref nexty);
//                            map.map.ForceStation(nextx, nexty, w, h, guid);
//                        }
//                    }
//                }
//                Repaint();

//            }

//            //if(mMapRoot == null)
//            //{
//            //    mMapRoot = new CsGridMapRoot(map.map);

//            //}
//            //else
//            //{

//            //}

//            //mMapRoot.Init();

//        }
//        if (GUILayout.Button("Save"))
//        {
//            if (map.map != null)
//            {
//                string path = Application.dataPath +"/"+map.name+".txt";
//                Clishow.CsFileHelper.WriteTxtFile(map.map.Save(), path);
//            }
//        }
//        EditorGUILayout.EndVertical();
//    }


//    private void OnSceneGUI()
//    {
//        CsGridMap map = target as CsGridMap;
//        CsGridMapDrawer.DrawMap(map.map);


//    }

//}
