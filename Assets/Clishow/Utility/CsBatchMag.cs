using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using DigitalOpus.MB.Core;

namespace Clishow
{
    public class CsBatchUnit
    {
        public string Name;
        public MB2_TextureBakeResults BResults = null;
        public MB3_MultiMeshBaker MeshBaker;
        private int mCount = 0;
        public CsBatchUnit(Renderer renderer,CsBatchMgr mgr )
        {
            Name = renderer.sharedMaterial.name;
            Name = Name.Replace("(Source)", "");
            BResults = MB2_TextureBakeResults.CreateForMaterialsOnRenderer(renderer);
            GameObject obj = new GameObject(Name);
            obj.transform.parent = mgr.transform;
            obj.transform.localPosition = Vector3.zero;
            obj.transform.localRotation = Quaternion.identity;


            MeshBaker = obj.AddComponent<MB3_MultiMeshBaker>();
            MeshBaker.textureBakeResults = BResults;
            MeshBaker.meshCombiner.renderType = MB_RenderType.skinnedMeshRenderer;

        }

        public void Push(GameObject obj)
        {
            GameObject[] gos = new GameObject[1];
            gos[0] = obj.GetComponentInChildren<Renderer>().gameObject;
            MeshBaker.AddDeleteGameObjects(gos, null, true);
            MeshBaker.Apply();
            {
                MB3_MultiMeshCombiner multi = MeshBaker.meshCombiner as MB3_MultiMeshCombiner;
                if (multi != null)
                {
                    if (mCount != multi.meshCombiners.Count)
                    {
                        mCount = multi.meshCombiners.Count;
                        for (int i = 0, imax = mCount; i < imax; i++)
                        {
                            if (multi.meshCombiners[i].combinedMesh.targetRenderer != null)
                            {
                                SkinnedMeshRenderer sm = (SkinnedMeshRenderer)multi.meshCombiners[i].combinedMesh.targetRenderer;
                                if (sm != null)
                                {
                                    sm.updateWhenOffscreen = true;
                                }
                            }
                        }
                    }
                }
            }
        }

        public void Pop(GameObject obj)
        {
            GameObject[] dels = new GameObject[1];
            dels[0] = obj.GetComponentInChildren<Renderer>().gameObject;
            MeshBaker.AddDeleteGameObjects(null, dels, true);
            MeshBaker.Apply();
        }

        public void Destroy()
        {
            MB3_MultiMeshCombiner multi = MeshBaker.meshCombiner as MB3_MultiMeshCombiner;
            if (multi != null)
            {
                for (int i = 0, imax = multi.meshCombiners.Count; i < imax; i++)
                {
                    GameObject.Destroy(multi.meshCombiners[i].combinedMesh.resultSceneObject);
                }
            }
        }
    }

    public class CsBatchMgr : MonoBehaviour
    {

        private bool mIsDestroy = false;

        public bool IsDestroy
        {
            get
            {
                return mIsDestroy;
            }
        }

        private List<GameObject> mBatchRendererObjs = new List<GameObject>();

        private Dictionary<string, int> mMBUnitMaps = new Dictionary<string, int>();

        private List<CsBatchUnit> mMBUnits = new List<CsBatchUnit>();

        public bool Register(GameObject obj)
        {
            if (obj == null)
            {
                return false;
            }
            Renderer renderer = obj.GetComponentInChildren<Renderer>(true);
            if (renderer == null)
                return false;
            string name = obj.name;
            name = name.Replace(" ","");
            int t = name.IndexOf('(');
            if(t > 0)
            {
                name = name.Substring(0,t);
            }
            
            int index = -1;
            if (mMBUnitMaps.TryGetValue(name, out index))
            {
                return true;
            }
            else
            {
                CsBatchUnit mbunit = new CsBatchUnit(renderer,this);
                mMBUnitMaps.Add(name, mMBUnits.Count);
                mMBUnits.Add(mbunit);
                return true;
            }
        }

        public void Add(GameObject obj)
        {
            string name = obj.name;
            name = name.Replace(" ","");
            int t = name.IndexOf('(');
            if(t > 0)
            {
                name = name.Substring(0,t);
            }
            int index = -1;
            if (mMBUnitMaps.TryGetValue(name, out index))
            {
                mMBUnits[index].Push(obj);
            }
        }

        public void Delete(GameObject obj)
        {
            string name = obj.name;
            name = name.Replace(" ","");
            int t = name.IndexOf('(');
            if(t > 0)
            {
                name = name.Substring(0,t);
            }
            int index = -1;
            if (mMBUnitMaps.TryGetValue(name, out index))
            {
                mMBUnits[index].Pop(obj);
            }
        }

        void OnDestroy()
        {
            mIsDestroy = true;
            for (int i = 0, imax = mMBUnits.Count; i < imax; i++)
            {
                mMBUnits[i].Destroy();
            }
        }
    }
}