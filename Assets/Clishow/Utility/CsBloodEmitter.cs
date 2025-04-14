using UnityEngine;
using System.Collections;
namespace Clishow
{
    [RequireComponent(typeof(ParticleSystem))]
    public class CsBloodEmitter : MonoBehaviour
    {
        private ParticleSystem mPsystem = null;
        private float mY = 0;
        void Awake()
        {
            mPsystem = this.GetComponent<ParticleSystem>();
            mY = this.transform.position.y;

        }

        public void ShowBeaten(Vector3 pos)
        {
            if (mPsystem != null)
            {
                ParticleSystem.EmitParams ps = new ParticleSystem.EmitParams();
                ps.position = pos;
                mPsystem.Emit(ps, 1);
            }
        }

        public void ShowTrailSmoke(Vector3 pos)
        {
            if (mPsystem != null)
            {
                ParticleSystem.EmitParams ps = new ParticleSystem.EmitParams();
                ps.position = pos;
                mPsystem.Emit(ps, 2);
            }
        }

        public void ShowBlood(Vector3 pos)
        {
            if (mPsystem != null)
            {
                pos.y = mY;
                pos.x += Random.Range(-1.0f, 1.0f);
                pos.z += Random.Range(-1.0f, 1.0f);
                ParticleSystem.EmitParams ps = new ParticleSystem.EmitParams();
                ps.position = pos;
                mPsystem.Emit(ps, 1);
            }
        }

        public void ShowBoom(Vector3 pos, float size)
        {
            if (mPsystem != null)
            {
                pos.y = mY;
                ParticleSystem.EmitParams ps = new ParticleSystem.EmitParams();
                ps.position = pos;
                ps.startSize = size+Random.Range(-0.25f, 0.25f);
                ps.rotation3D = new Vector3(90, UnityEngine.Random.Range(0.0f, 359.0f), 0) ;
                mPsystem.Emit(ps, 1);
            }
        }
    }
}