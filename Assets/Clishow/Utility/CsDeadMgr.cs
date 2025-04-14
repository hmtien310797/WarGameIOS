using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Clishow
{
    public class CsDeadMgr : CsSingletonBehaviour<CsDeadMgr>
    {
        public CsCorpseEffect CorpseEffect = null;

        public override bool IsGlobal()
        {
            return false;
        }

        public override bool IsAutoInit()
        {
            return true;
        }

        public class Corpse
        {
            public Vector3 Pos;
            public Mesh mesh;
            public Matrix4x4 transform;
            public CorpseGroup group;

            public void clear()
            {
                if (mesh != null)
                {
                    mesh.Clear();
                }
                mesh = null;
                group = null;
            }
            public void UpdateBoold(ref ParticleSystem.Particle particle)
            {
                particle.remainingLifetime =  1;
                particle.position = Pos;
            }
        }

        public class CorpseGroup
        {
            public Mesh BatcheMesh = null;
            public GameObject BatchObj = null;
            public MeshFilter Filter;
            public MeshRenderer Renderer;
            public Material ShareMat;
            public List<Corpse> Corpses = new List<Corpse>();
            private bool mNeedBatching = false;

            public void Init(string name,Material shareMat , CsBakeObject obj,Transform parent)
            {
                if (BatchObj != null)
                    return;
                BatchObj = new GameObject(name);
                ShareMat = new Material(shareMat);
                ShareMat.SetTexture("_MainTex", obj.Renderer.material.GetTexture("_MainTex"));
                BatchObj.layer = obj.gameObject.layer;
                BatchObj.transform.parent = parent;
                BatchObj.transform.localPosition = Vector3.zero;
                BatchObj.transform.localRotation = Quaternion.identity;
                Filter = BatchObj.AddComponent<MeshFilter>();
                Renderer = BatchObj.AddComponent<MeshRenderer>();
                Renderer.material = ShareMat;
                BatcheMesh = new Mesh();
            }

            public Corpse AddCorpse(CsBakeObject obj)
            {
                if (obj == null)
                    return null;
                Corpse cp = new Corpse();
                cp.mesh = obj.BakeMesh;
                cp.transform = obj.transform.localToWorldMatrix;
                cp.group = this;
                cp.Pos = obj.transform.position;
                cp.Pos.x += Random.Range(-0.3f, 0.3f);
                cp.Pos.z += Random.Range(-0.3f, 0.3f);
                mNeedBatching = true;
                Corpses.Add(cp);
                return cp;
            }

            public void RemoveCorpse(Corpse cp)
            {
                if (Corpses.Remove(cp))
                {
                    cp.clear();
                    mNeedBatching = true;
                }
            }

            public void Bathing()
            {
                if (!mNeedBatching)
                    return;
                BatcheMesh.Clear();
                if (Corpses.Count == 0)
                    return;
                CombineInstance[] ins = new CombineInstance[Corpses.Count];
                for (int i = 0, imax = Corpses.Count; i < imax; i++)
                {
                    ins[i] = new CombineInstance();
                    ins[i].mesh = Corpses[i].mesh;
                    ins[i].transform = Corpses[i].transform;
                }
                BatcheMesh.CombineMeshes(ins);
                Filter.mesh = BatcheMesh;
            }

            public void Clear()
            {
                for (int i = 0, imax = Corpses.Count; i < imax; i++)
                {
                    Corpses[i].clear();
                }
                Corpses.Clear();
                BatcheMesh.Clear();
                BatcheMesh = null;
            }
        }

        private List<Corpse> mCorpsesList = new List<Corpse>();

        private Dictionary<string, int> mGroupMaps = new Dictionary<string, int>();

        private List<CorpseGroup> mGroups = new List<CorpseGroup>();

        public int MaxCount = 40;

        private Transform mTrf = null;

        public Transform _Trf
        {
            get
            {
                if (mTrf == null)
                    mTrf = this.transform;
                return mTrf;
            }
        }

        private ParticleSystem.Particle[] mParticle = null;

        public override void Initialize(object param = null)
        {
            base.Initialize(param);

        }

        public override void OnDestroy()
        {
            for (int i = 0, imax = mGroups.Count; i < imax; i++)
            {
                mGroups[i].Clear();
            }
            mGroups.Clear();
            mCorpsesList.Clear();
        }

        public void MakeCorpse(CsBakeObject source)
        {
            if (source == null)
            {
                return;
            }
            string name = source.Renderer.material.name;
            int index = -1;
            CorpseGroup group = null;
            Corpse cp = null;
            if (mCorpsesList.Count > MaxCount)
            {
                cp = mCorpsesList[0];
                mCorpsesList.RemoveAt(0);
                cp.group.RemoveCorpse(cp);
            }
            if (!mGroupMaps.TryGetValue(name, out index))
            {
                group = new CorpseGroup();
                group.Init(name, CorpseEffect.CorpseMaterial, source, _Trf);
                mGroups.Add(group);
                index = mGroups.Count - 1;
                mGroupMaps.Add(name, index);
            }
            cp = mGroups[index].AddCorpse(source);
            mCorpsesList.Add(cp);
            ShowBlood(cp.Pos);
        }
        public void ShowBlood(Vector3 pos)
        {
            if (CorpseEffect.Psystem != null)
            {
                pos.y = 0.25f;
                ParticleSystem.EmitParams ps = new ParticleSystem.EmitParams();
                ps.position = pos;
                ps.startLifetime = 4;
                CorpseEffect.Psystem.Emit(ps, 1);
            }
        }

        float mTime = 0;
        private void UpdateBoold(float _dt)
        {
            mTime += _dt;
            if (mTime < 3)
                return;
            mTime = 0;
            for (int i = 0, imax= mCorpsesList.Count; i < imax;i++)
            {
                ShowBlood(mCorpsesList[i].Pos);
            }
        }

        public void UpdateBullets()
        {
            if (CorpseEffect.Psystem == null)
                return;
            if (mParticle == null)
                mParticle = new ParticleSystem.Particle[CorpseEffect.Psystem.maxParticles];
            int particleCount = CorpseEffect.Psystem.particleCount;
            int bulcount = mCorpsesList.Count;
            if (particleCount < bulcount)
            {
                CorpseEffect.Psystem.Emit(bulcount - particleCount);
            }

            int numParticlesAlive = CorpseEffect.Psystem.GetParticles(mParticle);
            if (numParticlesAlive == 0)
                return;
            for (int i = 0; i < numParticlesAlive; i++)
            {
                if (i >= bulcount)
                {
                    mParticle[i].remainingLifetime = -1;
                }
                else
                {
                    mCorpsesList[i].UpdateBoold(ref mParticle[i]);
                }
            }
            CorpseEffect.Psystem.SetParticles(mParticle, numParticlesAlive);

        }

        void LateUpdate()
        {
            for (int i = 0, imax = mGroups.Count; i < imax; i++)
            {
                mGroups[i].Bathing();
            }
            //UpdateBullets();
            UpdateBoold(Time.deltaTime);
        }



    }
}


