using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Clishow
{
    public class CsBakeBatchesMgr : CsSingletonBehaviour<CsBakeBatchesMgr>
    {
        public class Batches
        {
            public string Name;
            public Material ShaderMat;
            public GameObject Obj;
            public MeshRenderer Renderer;
            public MeshFilter Filter;
            public Mesh BMesh = null;
            public List<CombineInstance> NeedCombines = new List<CombineInstance>();
        }

        private Dictionary<string, int> mBatcheMap = new Dictionary<string, int>();

        private List<Batches> mBatches = new List<Batches>();

        private List<CsBakeObject> mBakes = new List<CsBakeObject>();

        public bool NeedUPdateBakeObj = true;

        public void AddBakeObj(CsBakeObject obj)
        {
            mBakes.Add(obj);
        }

        public override bool IsGlobal()
        {
            return false;
        }

        public override bool IsAutoInit()
        {
            return true;
        }


        private void BatchingBake(CsBakeObject bo)
        {
            if (bo == null)
                return;
            int index  = -1;
            string name = bo.Renderer.material.name;
            if (!mBatcheMap.TryGetValue(name, out index))
            {
                Batches ba = new Batches();
                ba.Name = name;
                ba.ShaderMat = bo.Renderer.material;
                ba.Obj = new GameObject(name);
                ba.Obj.layer = bo.gameObject.layer;
                ba.Obj.transform.parent = this.transform;
                ba.Obj.transform.localPosition = Vector3.zero;
                ba.Obj.transform.localRotation = Quaternion.identity;
                ba.Filter = ba.Obj.AddComponent<MeshFilter>();
                ba.Renderer = ba.Obj.AddComponent<MeshRenderer>();
                ba.Renderer.material = new Material( ba.ShaderMat);
                ba.BMesh = new Mesh();
                mBatches.Add(ba);
                index = mBatches.Count - 1;
                mBatcheMap.Add(name, index);
                
            }
            CombineInstance ins = new CombineInstance();
            ins.mesh = bo.BakeMesh;
            ins.transform = bo.transform.localToWorldMatrix;
            mBatches[index].NeedCombines.Add(ins);
        }

        void Batching()
        {
            for (int i = 0, imax = mBakes.Count; i < imax; i++)
            {
                BatchingBake(mBakes[i]);
            }
            mBakes.Clear();

            for (int i = 0, imax = mBatches.Count; i < imax; i++)
            {
                mBatches[i].BMesh.Clear(false);
                if (mBatches[i].NeedCombines.Count != 0)
                {
                    mBatches[i].BMesh.CombineMeshes(mBatches[i].NeedCombines.ToArray());
                    mBatches[i].NeedCombines.Clear();
                }
                mBatches[i].Filter.mesh = mBatches[i].BMesh;
            }
        }


        //void LateUpdate()
        //{
        //    Batching();
        //}

        private List<CsBakeObject> mNeedUpdateObjs = new List<CsBakeObject>();

        public void AddUpdateBakeObj(CsBakeObject obj)
        {
            mNeedUpdateObjs.Add(obj);
        }

        public void RemoveUpdateBakeObj(CsBakeObject obj)
        {
            mNeedUpdateObjs.Remove(obj);
        }

        private void UpdateBakeObjs()
        {
            //#if PROFILER
            //            Profiler.BeginSample("CsBakeBatchesMgr_Usage");
            //#endif
            int count = 0;
            CsBakeObject obj = null;
            bool occ = Time.frameCount % 2 == 0;
            for (int i = 0, imax= mNeedUpdateObjs.Count; i < imax;i++)
            {
                obj = mNeedUpdateObjs[i];
                //if (obj.BecameVisbie)
                //{

                //    obj.UpdateBakeObj((count%2 == 0) == occ);
                //    count++;
                //}
                //else
                //    obj.UpdateBakeObj();
                obj.UpdateBakeObj(true);
            }
//#if PROFILER
//            Profiler.EndSample();
//#endif
        }

        public override void OnDestroy()
        {
            base.OnDestroy();
            mNeedUpdateObjs.Clear();
        }

        void Update()
        {
            if (!NeedUPdateBakeObj)
                return;
            UpdateBakeObjs();
        }
    }
}

