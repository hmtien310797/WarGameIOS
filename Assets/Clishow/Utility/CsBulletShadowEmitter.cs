using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Clishow
{
    public class CsBulletShadowEmitter : MonoBehaviour
    {
        public ParticleSystem PSystem = null;
        private ParticleSystem.Particle[] mParticle = null;
        private Transform mSelfTrf;
        private Transform _selfTrf
        {
            get
            {
                if(mSelfTrf == null)
                {
                    mSelfTrf = this.transform;
                }
                return mSelfTrf;
            }
        }

        void OnDestroy()
        {
            PSystem = null;
            mParticle = null;
        }

        void Awake()
        {
            Init();
        }

        void Init()
        {
            if (mParticle == null)
                mParticle = new ParticleSystem.Particle[PSystem.maxParticles];
        }

        public void UpdateBulletsShadow(List<CsBullet> bullets)
        {
            if (PSystem == null)
                return;
            int particleCount = PSystem.particleCount;
            int bulcount = bullets.Count;
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
                    bullets[i].UpdateShadow(ref mParticle[i],_selfTrf);
                }
            }
            PSystem.SetParticles(mParticle, numParticlesAlive);
        }
    }
}


