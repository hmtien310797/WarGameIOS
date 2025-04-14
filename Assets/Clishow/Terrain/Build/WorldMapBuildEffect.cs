using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class WorldMapBuildEffect : MonoBehaviour
{
    public GameObject[] Objects;
    private FastPool<BuildEffectCache>[] ObjectPools;
    private FastPool<FastStack<BuildEffectCache>> CachePool;
    private Dictionary<int, FastStack<BuildEffectCache>> BuildEffectMap;
    private FastStack<int> NeedRemovedEffect;
    public World world;

    Vector3 tmpVec3;
    BuildEffectCache buildEffectCache = null;
    public FastStack<BuildEffectCache> tmpEffectList;
    BuildEffectCache[] tmpEffectListCache;
    public void Init()
    {
        if (Objects != null)
        {
            ObjectPools = new FastPool<BuildEffectCache>[Objects.Length];
            CachePool = new FastPool<FastStack<BuildEffectCache>>();
            BuildEffectMap = new Dictionary<int, FastStack<BuildEffectCache>>();
            NeedRemovedEffect = new FastStack<int>();
            tmpEffectListCache = new BuildEffectCache[Objects.Length];
        }
    }

    public FastStack<BuildEffectCache> GetEffectList(int index)
    {
        BuildEffectMap.TryGetValue(index, out tmpEffectList);
        return tmpEffectList;
    }

    public void ShowEffect(int x, int y, int lindex, FastStack<int> effect_list)
    {
        if (ObjectPools == null)
            return;
        if (!BuildEffectMap.TryGetValue(lindex, out tmpEffectList))
        {
            tmpEffectList = CachePool.Claim();
            BuildEffectMap.Add(lindex, tmpEffectList);
        }

        tmpVec3.x = Mathf.FloorToInt(x * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.y = 0.5f;
        tmpVec3.z = Mathf.FloorToInt(y * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.x += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        tmpVec3.z += world.WorldInfo.LBlockMap.BlockSize * 0.5f;

        for (int i = 0, imax = tmpEffectList.Count; i < imax; i++)
        {
            buildEffectCache = tmpEffectList.innerArray[i];
            if (buildEffectCache != null)
            {
                tmpEffectListCache[buildEffectCache.id] = buildEffectCache;
            }
        }
        tmpEffectList.FastClear();
        for (int i = 0, imax = effect_list.Count; i < imax; i++)
        {
            int id = effect_list.innerArray[i];
            if (tmpEffectListCache[id] == null)
            {
                if (ObjectPools[id] == null)
                {
                    ObjectPools[id] = new FastPool<BuildEffectCache>();
                }
                buildEffectCache = ObjectPools[id].Claim();
                if (buildEffectCache.Go == null)
                {
                    buildEffectCache.id = id;
                    GameObject go = GameObject.Instantiate(Objects[id]);
                    go.transform.SetParent(transform, false);
                    buildEffectCache.Go = go;
                }
                buildEffectCache.Show(tmpVec3);
                tmpEffectList.Add(buildEffectCache);
            }
            else
            {
                tmpEffectList.Add(tmpEffectListCache[id]);
                tmpEffectListCache[id] = null;
            }
        }
        for (int i = 0, imax = tmpEffectListCache.Length; i < imax; i++)
        {
            if (tmpEffectListCache[i] != null)
            {
                buildEffectCache = tmpEffectListCache[i];
                buildEffectCache.Hide();
                ObjectPools[buildEffectCache.id].Release(buildEffectCache);
                tmpEffectListCache[i] = null;
            }
        }

    }

    public void ShowEffect(int x, int y, int id, int lindex)
    {
        if (ObjectPools == null)
            return;
        if (!BuildEffectMap.TryGetValue(lindex, out tmpEffectList))
        {
            tmpEffectList = CachePool.Claim();
            BuildEffectMap.Add(lindex, tmpEffectList);
        }
        if (ObjectPools[id] == null)
        {
            ObjectPools[id] = new FastPool<BuildEffectCache>();
        }
        buildEffectCache = ObjectPools[id].Claim();
        if (buildEffectCache.Go == null)
        {
            buildEffectCache.id = id;
            GameObject go = GameObject.Instantiate(Objects[id]);
            go.transform.SetParent(transform, false);
            buildEffectCache.Go = go;
        }
        tmpVec3.x = Mathf.FloorToInt(x * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.y = 0.5f;
        tmpVec3.z = Mathf.FloorToInt(y * world.WorldInfo.LBlockMap.BlockSize) - world.WorldInfo.HRValue.z;
        tmpVec3.x += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        tmpVec3.z += world.WorldInfo.LBlockMap.BlockSize * 0.5f;
        buildEffectCache.Show(tmpVec3);
        tmpEffectList.Add(buildEffectCache);
    }

    private bool _HideEffect(int index)
    {
        GetEffectList(index);
        if (tmpEffectList == null)
            return false;
        for (int i = 0, imax = tmpEffectList.Count; i < imax; i++)
        {
            buildEffectCache = tmpEffectList.innerArray[i];
            buildEffectCache.Hide();
            ObjectPools[buildEffectCache.id].Release(buildEffectCache);
        }
        CachePool.Release(tmpEffectList);
        return true;
    }

    public void HideEffect(int index)
    {
        if (_HideEffect(index))
            BuildEffectMap.Remove(index);
    }

    public void ClearView(QuadRect CurRect)
    {
        if (BuildEffectMap == null || NeedRemovedEffect == null)
            return;
        NeedRemovedEffect.FastClear();
        foreach (int key in BuildEffectMap.Keys)
        {
            int index = key;
            int wx = world.WorldInfo.LogicServerSizeX - index / world.WorldInfo.LogicServerSizeX - 1;
            int wy = index % world.WorldInfo.LogicServerSizeX;
            if (!WorldData.RectContains(CurRect, wx, wy))
            {
                if (_HideEffect(key))
                    NeedRemovedEffect.Add(key);
            }
        }
        if (NeedRemovedEffect.Count != 0)
        {
            for (int i = 0, imax = NeedRemovedEffect.Count; i < imax; i++)
            {
                BuildEffectMap.Remove(NeedRemovedEffect.innerArray[i]);
            }
        }
    }
}
public class BuildEffectCache : IFastPool
{
    public int id;
    public GameObject Go;
    public void Show(Vector3 wPos)
    {
        Go.transform.localPosition = wPos;
        Go.SetActive(true);
    }

    public void Hide()
    {
        Go.SetActive(false);
    }

    public int poolIndex { get; set; }
    public void OnReset()
    {
    }
}