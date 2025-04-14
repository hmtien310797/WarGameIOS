using System;
using UnityEngine;
using System.Collections.Generic;
using DigitalOpus.MB.Core;

namespace Clishow
{
    public class CsUnitMBMgr : CsSingletonBehaviour<CsUnitMBMgr>
    {
        public override bool IsGlobal()
        {
            return false;
        }

        public override bool IsAutoInit()
        {
            return true;
        }
        private List<GameObject> mSkinRendererObjs = new List<GameObject>();


        public class MBUnit
        {
            public string Name;
            public MB2_TextureBakeResults BResults = null;
            public MB3_MultiMeshBaker MeshBaker;
            private int mCount = 0;
            public MBUnit(SkinnedMeshRenderer renderer)
            {
                Name = renderer.sharedMaterial.name;
                Name = Name.Replace("(Source)", "");
                BResults = MB2_TextureBakeResults.CreateForMaterialsOnRenderer(renderer);
                GameObject obj = new GameObject(Name);
                obj.transform.parent = CsUnitMBMgr.Instance.transform;
                obj.transform.localPosition = Vector3.zero;
                obj.transform.localRotation = Quaternion.identity;


                MeshBaker = obj.AddComponent<MB3_MultiMeshBaker>();
                MeshBaker.textureBakeResults = BResults;
                MeshBaker.meshCombiner.doTan = false;
                MeshBaker.meshCombiner.renderType = MB_RenderType.skinnedMeshRenderer;
 
            }

            public void AddUnit(CsUnit unit)
            {
                GameObject[] gos = new GameObject[1];
                gos[0] = unit.SMRenderer.gameObject;
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

            public void DeleteUnit(CsUnit unit)
            {
                GameObject[] dels = new GameObject[1];
                dels[0] = unit.GetComponentInChildren<SkinnedMeshRenderer>().gameObject;
                MeshBaker.AddDeleteGameObjects(null, dels, true);
                MeshBaker.Apply();
            }

            private float updateTime = 0;
            public void UpdateBounds()
            {
                updateTime += Time.deltaTime;
                if (updateTime >= 1)
                {
                    updateTime = 0;
                    MeshBaker.UpdateSkinnedMeshApproximateBounds();
                }                
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


        private Dictionary<string, int> mMBUnitMaps = new Dictionary<string, int>();

        private List<MBUnit> mMBUnits = new List<MBUnit>();

        public override void Initialize(object param = null)
        {
            if (mInitialized)
                return;
            mValid = true;
            mInitialized = true;
        }
        public void RegisterUnit(GameObject unit)
        {
            if (unit == null)
            {
                return;
            }
            SkinnedMeshRenderer renderer = unit.GetComponentInChildren<SkinnedMeshRenderer>();
            if (renderer == null)
                return;
            string name = unit.name;
            int index = -1;
            if (mMBUnitMaps.TryGetValue(name, out index))
            {
                return;
            }
            else
            {
                MBUnit mbunit = new MBUnit(renderer);
                mMBUnitMaps.Add(name, mMBUnits.Count);
                mMBUnits.Add(mbunit);
                
            }
        }

        public void AddUnit(CsUnit unit)            
        {
            string name = "";
            if(unit._lowModelPrefab != null)
            {
                name = unit._lowModelPrefab.name;
            }
            else
            {
                name = unit._modelPrefab.name;
            }
            
            name = name.Replace("(Clone)", "");
            int index = -1;
            if (mMBUnitMaps.TryGetValue(name, out index))
            {
                mMBUnits[index].AddUnit(unit);
            }
        }

        public void DeleteUnit(CsUnit unit)
        {
            string name = "";
            if(unit._lowModelPrefab != null)
            {
                name = unit._lowModelPrefab.name;
            }
            else
            {
                name = unit._modelPrefab.name;
            }
            name = name.Replace("(Clone)", "");
            int index = -1;
            if (mMBUnitMaps.TryGetValue(name, out index))
            {
                mMBUnits[index].DeleteUnit(unit);
            }
        }


        public override void OnDestroy()
        {
            base.OnDestroy();
            for (int i = 0, imax = mMBUnits.Count; i < imax; i++)
            {
                mMBUnits[i].Destroy();
            }
        }
    }
}
