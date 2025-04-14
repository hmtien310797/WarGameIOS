using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Clishow
{

    public class CsBullet
    {
        public bool isALive = true;
        public Vector3 Pos;
        public Vector3 Dir;
        public Vector3 Size;
        public float alpha;
        public CsBulletEmitter Emitter = null;
        public Vector3 StartSize;
        public float StartAlpha;
        public Color color;
        public CsBullet()
        { }

        public CsBullet(Vector3 pos,Vector3 dir, Vector3 _size,Color _color)
        {
            Pos = pos;
            Dir = dir;
            StartSize = _size;
            Size = StartSize;
            StartAlpha = _color.a;
            alpha = StartAlpha;
            color = _color;
        }

        public void Update(ref ParticleSystem.Particle particle)
        {
            particle.velocity = Vector3.zero;
            particle.remainingLifetime = isALive ? 1 : -1;
            particle.position = Emitter.transform.InverseTransformPoint(Pos);
            //particle.rotation =( Vector3.Dot(Vector3.left, Dir) > 0 ? 1 : -1) * Vector3.Angle(Vector3.forward, Dir);
            float y = (Vector3.Dot(Vector3.left, Dir) > 0 ? 1 : -1) * Vector3.Angle(Vector3.forward, Dir);
            particle.rotation3D = new Vector3(90, 0, y);
            color.a = (alpha / StartAlpha);
            particle.startColor = color;
            particle.startSize3D = Size;
            //particle.startSize = size;
        }

        public void UpdateShadow(ref ParticleSystem.Particle particle,Transform parent)
        {
            particle.velocity = Vector3.zero;
            particle.remainingLifetime = isALive ? 1 : -1;
            Vector3 p = Pos;
            if(p.y > 0)
               p.y = 0.5f;
            particle.position = parent.InverseTransformPoint(p); 
            //particle.rotation =( Vector3.Dot(Vector3.left, Dir) > 0 ? 1 : -1) * Vector3.Angle(Vector3.forward, Dir);
            //float y = (Vector3.Dot(Vector3.left, Dir) > 0 ? 1 : -1) * Vector3.Angle(Vector3.forward, Dir);
            //particle.rotation3D = new Vector3(90, 0, y);
            color.a = (alpha / StartAlpha)*0.1f;
            particle.startColor = color;
            particle.startSize3D = Vector3.one*7;
            //particle.startSize = size;
        }
    }

    public class CsBulletEmitter : MonoBehaviour
    {
        public CsBulletShadowEmitter BulletShadowEmitter = null;
        public ParticleSystem PSystem = null;
        private ParticleSystem.Particle[] mParticle = null;
        private List<CsBullet> mBullets = new List<CsBullet>();
        private bool mEnableBulletShadow = false;

        void OnDestroy()
        {
            PSystem = null;
            mParticle = null;
            for (int i = 0; i < mBullets.Count; i++)
            {
                mBullets[i] = null;
            }
            mBullets.Clear();
        }

        void Awake()
        {
            Init();
        }

        void Init()
        {
            mEnableBulletShadow = GameSetting.instance.option.mQualityLevel > 1;
            if (mParticle == null)
                mParticle = new ParticleSystem.Particle[PSystem.maxParticles];
        }

        public CsBullet Emit(Vector3 pos, Vector3 dir,Vector3 size)
        {
            if (PSystem == null)
                return null;
            CsBullet bullet = new CsBullet(pos, dir, size, PSystem.startColor);
            mBullets.Add(bullet);
            return bullet;
        }

        public CsBullet Emit(Vector3 size,Color color)
        {
            if (PSystem == null)
                return null;
            CsBullet bullet = new CsBullet(new Vector3(0,-100,0),Vector3.forward, size, color);
            bullet.Emitter = this;
            mBullets.Add(bullet);
            return bullet;
        }

        public void DestroyBullet(CsBullet bullet)
        {
            mBullets.Remove(bullet);
        }

        public void UpdateBullets()
        {
            if (PSystem == null)
                return;
            int particleCount = PSystem.particleCount;
            int bulcount = mBullets.Count;
            if (particleCount < bulcount)
            {
                PSystem.Emit(bulcount - particleCount);
            }
            
            int numParticlesAlive = PSystem.GetParticles(mParticle);
            if (numParticlesAlive == 0)
                return;
            for (int i = 0; i < numParticlesAlive;i++ )
            {
                if (i >= bulcount)
                {
                    mParticle[i].remainingLifetime = -1;
                }
                else
                {
                    mBullets[i].Update(ref mParticle[i]);
                }
            }
            PSystem.SetParticles(mParticle, numParticlesAlive);

        }
        
        public void LateUpdate()
        {
#if PROFILER
            Profiler.BeginSample("CsBulletEmitter_LateUpdate");
#endif        
            // if(BulletShadowEmitter != null && mEnableBulletShadow)
            //{
            //    BulletShadowEmitter.UpdateBulletsShadow(mBullets);
            //}               
            UpdateBullets();

#if PROFILER
            Profiler.EndSample();
#endif
        }
    }
}


