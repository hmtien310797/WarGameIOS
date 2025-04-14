using UnityEngine;
using System.Collections;

public class CsSLGPVPMap : MonoBehaviour {

    [Range(1, 2048)]
    public int width;
    [Range(1, 2048)]
    public int height;

    [Range(0.001f, 100)]
    public float unit_size;

    public TextAsset MapData;

    private Serclimax.SLGPVP.ScGridMap mMap;
    public Serclimax.SLGPVP.ScGridMap map
    {
        get
        {
            return mMap;
        }
    }
    public void EditorInitMap()
    {
        mMap = new Serclimax.SLGPVP.ScGridMap();
        if (MapData == null)
        {
            Vector2 pos = transform.position;
            pos.y = transform.position.z;
            map.Init(width, height, unit_size, pos);
        }
        else
        {
            map.Init(MapData.text);
        }
    }
}
