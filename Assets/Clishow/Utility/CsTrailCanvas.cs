using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
namespace Clishow
{
    public interface IPooledObject
    {
        void OnEnterPool();
    }

    public static class CsObjectPool<T> where T : class, IPooledObject, new()
    {
        static List<T> pool;

        static CsObjectPool()
        {
            pool = new List<T>();
        }

        public static T Claim()
        {
            if (pool.Count > 0)
            {
                T ls = pool[pool.Count - 1];
                pool.RemoveAt(pool.Count - 1);
                return ls;
            }
            else
            {
                return new T();
            }
        }

        public static void Warmup(int count)
        {
            T[] tmp = new T[count];
            for (int i = 0; i < count; i++) tmp[i] = Claim();
            for (int i = 0; i < count; i++) Release(tmp[i]);
        }

        public static void Release(T obj)
        {
            if (pool.Contains(obj))
                return;
            obj.OnEnterPool();
            pool.Add(obj);
        }
        public static void Clear()
        {
            pool.Clear();
        }
        public static int GetSize()
        {
            return pool.Count;
        }
    }


    public class CsTrailImageObj : IPooledObject
    {
        private Image trailImage = null;
        private RectTransform trailTrf = null;
        private Quaternion sourceQuater;
        private GameObject trailObj = null;
        private Vector2 sourceSize;
        private Vector2 trailRectSize;
        private bool mInited = false;
        private Color mSourceColor;

        public void Init(CsTrailCanvas canvas)
        {
            if (mInited)
                return;
            trailImage = GameObject.Instantiate(canvas.TrainPrefab);
            mSourceColor = trailImage.color;
            trailObj = trailImage.gameObject;
            trailTrf = trailImage.rectTransform;
            sourceQuater = trailTrf.localRotation;
            trailTrf.SetParent(canvas.Trf);
            sourceSize = trailTrf.sizeDelta;
            mInited = true;
            trailObj.SetActive(true);
            OnEnterPool();
        }

        public void Active(Vector3 dir, Vector3 pos, float length)
        {
            float angle = Vector3.Angle(Vector3.forward, dir);
            trailImage.color = mSourceColor;
            int factor = (Vector3.Dot(Vector3.right, dir) < 0 ? 1 : -1);
            angle *= factor;
            trailTrf.localRotation = Quaternion.Euler(0, 0, angle);
            pos -= Vector3.Cross(dir, Vector3.up) * sourceSize.y * 0.5f;
            trailTrf.position = pos;
            Update(length);
            trailTrf.localScale = Vector3.one;
        }

        public void UpdateColor(float force)
        {
            trailImage.color = mSourceColor*force;
        }

        public void Update(float length)
        {
            trailRectSize.x = length * 0.65f;
            trailTrf.sizeDelta = trailRectSize;
        }

        public void OnEnterPool()
        {
            trailRectSize = sourceSize;
            trailTrf.localPosition = Vector3.zero;
            trailTrf.localScale = Vector3.zero;
        }
    }

    public class CsTrailCanvas : MonoBehaviour
    {
        public Image TrainPrefab = null;

        private Transform _trf = null;


        private bool isvalid = false;
        public Transform Trf
        {
            get
            {
                if (_trf == null)
                {
                    _trf = this.transform;
                }
                return _trf;
            }
        }

        void Awake()
        {
            CheckQualityLevel();
        }

        public CsTrailImageObj CreateTrail()
        {
            if (!isvalid)
                return null;
            CsTrailImageObj trail = CsObjectPool<CsTrailImageObj>.Claim();
            trail.Init(this);
            return trail;
        }

        public void RemoveTrail(CsTrailImageObj trail)
        {
            if (!isvalid)
                return;
            if (trail == null)
                return;
            CsObjectPool<CsTrailImageObj>.Release(trail);
        }

        public void Clear()
        {
            if (!isvalid)
                return;
            CsObjectPool<CsTrailImageObj>.Clear();
        }

        bool CheckQualityLevel()
        {
            bool enable = GameSetting.instance.option.mQualityLevel >= 1;
            if (enable != this.gameObject.activeSelf)
                this.gameObject.SetActive(enable);
            isvalid = enabled;
            return enable;
        }
    }
}


