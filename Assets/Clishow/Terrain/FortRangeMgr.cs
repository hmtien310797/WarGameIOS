using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class FortRangeMgr : MonoBehaviour
{
    public FortRangeEffect effectPrefab;
    public World world;
    public int[] fortBasicSurfaceIds;
    private int mMaxFortBuildId = 1306;
    private Transform _selfTrf;
    public Transform selfTrf
    {
        get
        {
            if (_selfTrf == null)
            {
                _selfTrf = this.transform;
            }
            return _selfTrf;
        }
    }

    private Dictionary<int,FortRangeEffect> mEffects = new Dictionary<int, FortRangeEffect>(); 
    void Start()
    {
        //Vector3 pos = Vector3.zero;
        //FortRangeEffect effect = null;
        for (int i = 0; i < fortBasicSurfaceIds.Length; i++)
        {
            Serclimax.ScBasicSurfaceData data = Main.Instance.TableMgr.GetTable<Serclimax.ScBasicSurfaceData>().GetData(fortBasicSurfaceIds[i]);
            if (data == null)
                continue;
            SetRange(data.coordX,data.coordY,data.width,data.height);
            //world.WorldInfo.LBlockMap.WLogicPos2WorldPos(ref pos, Mathf.FloorToInt(data.coordX),//+ data.width*0.5f-1
            //    Mathf.FloorToInt(data.coordY), world.WorldInfo);//+ data.height*0.5f-1
            //pos.x += data.width % 2 == 0 ? world.WorldInfo.LogicBlockSize * 0.5f : 0;
            //pos.y = 1;
            //pos.z += data.height % 2 == 0 ? world.WorldInfo.LogicBlockSize * 0.5f : 0;
            //effect = GameObject.Instantiate<FortRangeEffect>(effectPrefab);
            //effect.transform.parent = this.transform;
            //effect.transform.rotation = Quaternion.identity;
            ////effect.transform.position = pos;
            //effect.Init(data.width, data.height, world.WorldInfo.LogicBlockSize);
        }


    }

    public void SetRange(int x, int y, int w, int h)
    {
        int index = x*world.WorldInfo.LogicServerSizeX +y;
        if(mEffects.ContainsKey(index))
            return;

        Vector3 pos = Vector3.zero;
        FortRangeEffect effect = null;
        world.WorldInfo.LBlockMap.WLogicPos2WorldPos(ref pos, x,//+ data.width*0.5f-1
            y, world.WorldInfo);//+ data.height*0.5f-1
        pos.x += w % 2 == 0 ? world.WorldInfo.LogicBlockSize * 0.5f : 0;
        pos.y = 1;
        pos.z += h % 2 == 0 ? world.WorldInfo.LogicBlockSize * 0.5f : 0;
        effect = GameObject.Instantiate<FortRangeEffect>(effectPrefab);
        effect.transform.parent = this.transform;
        effect.transform.rotation = Quaternion.identity;
        effect.transform.position = pos;
        effect.Init(w, h, world.WorldInfo.LogicBlockSize);
        mEffects.Add(index,effect);
    }
}
