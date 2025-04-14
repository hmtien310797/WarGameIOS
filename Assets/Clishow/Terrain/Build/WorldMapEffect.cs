using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class WorldMapEffect : MonoBehaviour {

    public GameObject[] Objects;
    public World world;

    List<EffectCache> effectCaches = new List<EffectCache>();
    Vector3 tmpVec3;


    public void ShowEffect(int x, int y, int id, float time)
    {
        tmpVec3.x = Mathf.FloorToInt(x * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.y = 0;
        tmpVec3.z = Mathf.FloorToInt(y * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        //tmpVec3 = world.WorldInfo.world.World2TerrainPos(tmpVec3);
        tmpVec3.x += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        tmpVec3.z += world.WorldInfo.LBlockMap.BlockSize * 0.5f;

        EffectCache effectCache = null;
        for (int i = 0; i < effectCaches.Count; i++)
        {
            if (effectCaches[i].IsUse == false && effectCaches[i].Id == id)
            {
                effectCache = effectCaches[i];
                break;
            }
        }
        if (effectCache != null)
            effectCache.Show(tmpVec3, x, y, time);
        else
            CreateEffect(tmpVec3, id, time);
    }

    public void ClearView(QuadRect CurRect)
    {
        for (int i = 0; i < effectCaches.Count; i++)
        {
            if (effectCaches[i].IsUse)
            {
                if (!WorldData.RectContains(CurRect, effectCaches[i].wPosX, effectCaches[i].wPosY))
                {
                    effectCaches[i].Hide();
                }
            }
        }
    }

    public void UpdateEffects()
    {
        for (int i = 0; i < effectCaches.Count; i++)
        {
            if (effectCaches[i].IsUse) {
                effectCaches[i].UpdateEffect();
            }
        }
    }


    public void CreateEffect(Vector3 wPos, int id, float time)
    {
        EffectCache effectCache = new EffectCache();
        effectCache.Id = id;
        effectCache.IsUse = true;
        effectCache.time = time;
        GameObject go = GameObject.Instantiate(Objects[id]);
        go.transform.SetParent(transform, false);
        go.transform.localPosition = wPos;
        go.SetActive(true);
        effectCache.Go = go;
        if(time>100)
        {
            effectCache.timer =(-1* time%100)*0.1f;
            effectCache.time = (time/100)*0.1f;
            effectCache.isShow = false;
            effectCache.Go.SetActive(false);
        }
        else
        {
            effectCache.isShow = true;
            effectCache.Go.SetActive(true);
        }

        effectCaches.Add(effectCache);
    }
}

public class EffectCache
{

    public int Id;
    public bool IsUse;
    public GameObject Go;
    public int wPosX;
    public int wPosY;

    public float time = 5;
    public float timer = 0;
    public bool isShow = false;
   

    public void Show(Vector3 wPos, int x, int y, float t)
    {
        IsUse = true;
        wPosX = x;
        wPosY = y;
        time = t;
        Go.transform.localPosition = wPos;
        if(t>100)
        {
            timer =(-1* t%100)*0.1f;
            time = (t/100)*0.1f;
            isShow = false;
            Go.SetActive(false);
        }
        else
        {
            isShow = true;
            Go.SetActive(true);
        }

    }

    public void UpdateEffect() {
        timer += Time.deltaTime;
        if(timer>0)
        {
            if(!isShow)
            {
                isShow = true;
                Go.SetActive(true);
            }
        }
        if (timer >= time){
            Hide();
        }
    }

    public void Hide()
    {
         isShow = false;
        IsUse = false;
        wPosX = 0;
        wPosY = 0;
        timer = 0;
        time = 0;
        Go.SetActive(false);
    }
}