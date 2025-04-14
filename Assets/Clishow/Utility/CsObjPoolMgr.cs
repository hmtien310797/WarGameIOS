using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Clishow
{
    public class CsInsUnit
    {
        public bool Activated = false;
        public string TempTag = string.Empty;
        public GameObject Cache = null;
        public bool Manual_Destroy = false;

        public void init(GameObject cache, bool activated, Transform bind_node, bool manual = false)
        {
            Activated = activated;
            Cache = cache;
            //            Cache.name = Cache.name.Replace("(Clone)","");
            if(!Activated)
                CsPoolUnit.Binding(Cache, bind_node);
            else
            {
                CsPoolUnit.ResetTransform(cache.transform);
            }
            Manual_Destroy = manual;

        }
    }

    public class CsPoolUnit
    {
        private GameObject mSource = null;

        public GameObject UnitSource
        {
            get
            {
                return mSource;
            }
        }

        public bool IsValid
        {
            get
            {
                return mSource != null;
            }
        }

        private List<CsInsUnit> mCaches = null;

        private string mTag = string.Empty;

        public string PoolTag
        {
            get
            {
                return mTag;
            }
        }

        public CsPoolUnit(GameObject source, string pool_name = null)
        {
            mSource = source;
            mTag = pool_name;
        }

        public CsPoolUnit(string pool_name)
        {
            mSource = null;
            mTag = pool_name;
        }

        public void SetUnitSource(GameObject source)
        {
            mSource = source;
        }

        public GameObject Pop()
        {
            return GetFreeCache();
        }

        private GameObject GetFreeCache()
        {
            GameObject result = null;
            if (mCaches == null || mCaches.Count == 0)
            {
                result = AddInsUnit();
            }
            else
            {
                int index = mCaches.FindIndex(i => !i.Activated);
                if (index >= 0)
                {
                    mCaches[index].Activated = true;
                    result = mCaches[index].Cache;
                }
                else
                {
                    if (result == null)
                    {
                        result = AddInsUnit();
                    }
                }
            }
            if (result != null)
            {
                result.transform.parent = null;
                result.SetActive(true);
                //result.transform.parent = null;
                ResetTransform(result.transform);
            }
            else
            {
                Debugger.LogError("CsPoolUnit "+ mSource.name + "  spawn failed !!!!");
            }

            return result;
        }

        public void Warmup(int count)
        {
            if(count<=0)
                return;
            for (int i=0;i<count;i++) AddInsUnit(false);
        }

        private GameObject AddInsUnit(bool active = true)
        {
            if (mCaches == null)
            {
                mCaches = new List<CsInsUnit>();
            }
            GameObject target = (GameObject)GameObject.Instantiate(UnitSource);
            CsPoolTag tag = target.AddComponent<CsPoolTag>();
            tag.PoolName = PoolTag;
            CsInsUnit unit = new CsInsUnit();
            unit.init(target, active, CsObjPoolMgr.Instance._MyTransform);
            _AddCaches(unit);
            
            //			unit.Activated = true;
            return unit.Cache;
        }

        public void _AddCaches(CsInsUnit unit)
        {
            if (unit != null)
                mCaches.Add(unit);
        }

        public int CacheCount
        {
            get
            {
                if (mCaches == null)
                    return 0;
                return mCaches.Count;
            }
        }

        public bool Push(GameObject target)
        {
            if (mCaches == null)
                return false;

            int index = mCaches.FindIndex(i => i.Cache == target);
            if (index >= 0)
            {
                if (mCaches[index].Activated)
                {
                    ResetInsUnit(mCaches[index], CsObjPoolMgr.Instance._MyTransform);
                    return true;
                }
            }
            return false;
        }

        private void ResetInsUnit(CsInsUnit unit, Transform bind_node)
        {
            if (unit == null)
                return;
            unit.Activated = false;
            unit.TempTag = string.Empty;
            Binding(unit.Cache, bind_node);
        }

        public void DestroyInsUnit(GameObject target)
        {
            if (target == null)
                return;
            CsInsUnit unit = null;
            int index = mCaches.FindIndex(i => i.Cache == target);
            if (index >= 0)
            {
                unit = mCaches[index];
                unit.Activated = false;
                unit.TempTag = string.Empty;
                unit.Cache.SetActive(false);
                unit.Cache.transform.parent = null;
                GameObject.Destroy(unit.Cache);
                unit.Cache = null;
                mCaches.RemoveAt(index);
            }
        }

        public static void Binding(GameObject target, Transform bind_node)
        {
            target.SetActive(false);
            target.transform.parent = bind_node;
            ResetTransform(target.transform);
        }

        public void ClearPool()
        {
            if (mCaches == null)
                return;

            for (int i = 0; i < mCaches.Count; i++)
            {
                if (mCaches[i].Cache != null)
                {
                    mCaches[i].Cache.transform.parent = null;
                    GameObject.Destroy(mCaches[i].Cache);
                }
                mCaches[i].Cache = null;
            }
            mCaches.Clear();
        }

        public void ClearPool4Destroy()
        {
            mSource = null;
            if(mCaches !=null)
            {
                for (int i = 0; i < mCaches.Count; i++)
                {
                    mCaches[i].Cache = null;
                }
                mCaches.Clear();
            }

            mCaches = null;
        }

        public void DestroyPool()
        {
            ClearPool();
            mSource = null;
        }

        public static void ResetTransform(Transform trf)
        {
            trf.localPosition = Vector3.zero;
            trf.localRotation = Quaternion.identity;
            trf.localScale = new Vector3(1, 1, 1);
        }
    }

    public class CsObjPoolMgr : CsSingletonBehaviour<CsObjPoolMgr>
    {
        public readonly static float InsTime = 0.1f;

        public readonly static Vector3 InsPosValue = new Vector3(1000, 0, 1000);

        private Transform mTransform = null;

        private List<int> mInsIDs = new List<int>();

        public override bool IsAutoInit()
        {
            return true;
        }

        public override void Initialize(object param = null)
        {
            m_Instance.transform.position = InsPosValue;
            base.Initialize(param);
        }

        public Transform _MyTransform
        {
            get
            {
                if (mTransform == null)
                    mTransform = this.transform;
                return mTransform;
            }
        }

        private Dictionary<string, CsPoolUnit> mPools = new Dictionary<string, CsPoolUnit>();

        public GameObject Instantiate(string name)
        {
            CsPoolUnit pool = null;

            if (mPools.TryGetValue(name, out pool))
            {
                return pool.Pop();
            }
            else
            {
                return null;
            }
        }

        public CsPoolUnit GetPool(string name)
        {
            CsPoolUnit pool = null;

            if (mPools.TryGetValue(name, out pool))
            {
                return pool;
            }
            else
            {
                return null;
            }
        }

        public GameObject InstantiateNoCache(string name)
        {
            CsPoolUnit pool = null;
            if (mPools.TryGetValue(name, out pool))
            {
                return GameObject.Instantiate(pool.UnitSource) as GameObject;
            }
            else
            {
                return null;
            }
        }

        public void Destroy(GameObject obj)
        {
            if (obj == null)
                return;
            CsPoolTag tag = obj.GetComponent<CsPoolTag>();
            if (tag == null)
                return;
            if (mPools.Count == 0)
            {
                obj = null;
                return;
            }
            CsPoolUnit pool = null;
            if (mPools.TryGetValue(tag.PoolName, out pool))
            {
                pool.Push(obj);
            }
        }

        public void RealDestroy(GameObject obj)
        {
            if (obj == null)
                return;
            CsPoolTag tag = obj.GetComponent<CsPoolTag>();
            if (tag == null)
                return;
            if (mPools.Count == 0)
            {
                obj = null;
                return;
            }
            CsPoolUnit pool = null;
            if (mPools.TryGetValue(tag.PoolName, out pool))
            {
                pool.DestroyInsUnit(obj);
            }
        }

        public void NewPool(GameObject prefab, string pool_name = null,int pool_count = 0)
        {
            if (prefab == null)
                return;
            CsPoolUnit pool = null;
            string pname = string.IsNullOrEmpty(pool_name) ? prefab.name : pool_name;
            if (!mPools.TryGetValue(pname, out pool))
            {
                pool = new CsPoolUnit(prefab, pname);
                pool.Warmup(pool_count);
                mPools.Add(pool.PoolTag, pool);
            }
            else
            {
                if (prefab != pool.UnitSource)
                    Debugger.LogWarning("CsPoolUnit Warning:[Failed] Cannt Add New Pool,cause this's prefab " + pool_name + " is Exist!");
            }
        }

        public bool IsContainPool(string pool_name)
        {
            return mPools.ContainsKey(pool_name);
        }

        public void ClearPool(string pool_name)
        {
            CsPoolUnit pool = null;
            if (mPools.TryGetValue(pool_name, out pool))
            {
                pool.ClearPool();
            }
        }

        public void DeletePool(string pool_name)
        {
            CsPoolUnit pool = null;
            if (mPools.TryGetValue(pool_name, out pool))
            {
                pool.DestroyPool();
                mPools.Remove(pool_name);
            }
        }

        public void ClearAllObjCache()
        {
            foreach (CsPoolUnit pool in mPools.Values)
            {
                pool.ClearPool();
            }
        }

        public void DestroyAllObjCache()
        {
            foreach (CsPoolUnit pool in mPools.Values)
            {
                pool.DestroyPool();
            }
            mPools.Clear();
        }

        private void ClearPool4Destroy()
        {
            mTransform = null;
            mInsIDs.Clear();
            mInsIDs = null;
            foreach (CsPoolUnit pool in mPools.Values)
            {
                pool.ClearPool4Destroy();
            }
            mPools.Clear();
            mPools = null;
        }

        public override void OnDestroy()
        {
            ClearPool4Destroy();
            //DestroyAllObjCache();
        }
    }
}
