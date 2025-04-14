using UnityEngine;
using System.Collections;

namespace Clishow
{
    public class CsParticleController : CsParticleBase
    {
        public ParticleSystem PSystem = null;

        public ParticleSystem DisPsystem = null;

        public CsSkillAsset Asset = null;


        public float VaildTime = -1; 

        public bool DestroyWhenInvalid = false;

        public float ScaleFactor =1 ;
        
        private float mCurScale = 1;

        private float mTime = 0;

        private float mVaildTime = -1;

        public void ScaleShurikenSystems(float scaleFactor)
        {
            if(scaleFactor == 0)
                return;
            if( mCurScale == scaleFactor )
            {
                return;
            }
            float scale = mCurScale;
            mCurScale = scaleFactor;
            scaleFactor = scaleFactor/scale;
            //get all shuriken systems we need to do scaling on
            ParticleSystem[] systems = GetComponentsInChildren<ParticleSystem>();

            foreach (ParticleSystem system in systems)
            {
                system.transform.localPosition *= scaleFactor;
                system.startSpeed *= scaleFactor;
                system.startSize *= scaleFactor;
                system.gravityModifier *= scaleFactor;

                ParticleSystem.ShapeModule shm = system.shape;
                shm.radius *= scaleFactor;
                shm.scale *= scaleFactor;
                shm.angle *= scaleFactor;
                shm.length *= scaleFactor;

                ParticleSystem.VelocityOverLifetimeModule  vm =system.velocityOverLifetime;
                ParticleSystem.MinMaxCurve tmp = vm.x;
                tmp.curveMultiplier *= scaleFactor;
                vm.x = tmp;
                tmp = vm.y;
                tmp.curveMultiplier *= scaleFactor;
                vm.y = tmp;
                tmp = vm.z;
                tmp.curveMultiplier *= scaleFactor;
                vm.z = tmp;

                ParticleSystem.LimitVelocityOverLifetimeModule lm = system.limitVelocityOverLifetime;
                tmp = lm.limit;
                tmp.curveMultiplier *= scaleFactor;
                lm.limit = tmp;

                tmp = lm.limitX;
                tmp.curveMultiplier *= scaleFactor;
                lm.limitX = tmp;

                tmp = lm.limitY;
                tmp.curveMultiplier *= scaleFactor;
                lm.limitY = tmp;

                tmp = lm.limitZ;
                tmp.curveMultiplier *= scaleFactor;
                lm.limitZ = tmp;

                ParticleSystem.ForceOverLifetimeModule fm = system.forceOverLifetime;
                tmp = fm.x;
                tmp.curveMultiplier *= scaleFactor;
                fm.x = tmp;

                tmp = fm.y;
                tmp.curveMultiplier *= scaleFactor;
                fm.y = tmp;

                tmp = fm.z;
                tmp.curveMultiplier *= scaleFactor;
                fm.z = tmp;


                ParticleSystem.ColorBySpeedModule com = system.colorBySpeed;
                com.range *= scaleFactor;

                ParticleSystem.SizeBySpeedModule sm = system.sizeBySpeed;
                sm.range *= scaleFactor;

                ParticleSystem.RotationBySpeedModule rm = system.rotationBySpeed;
                rm.range *= scaleFactor;

                system.Clear();
            }
        }

        public void Active()
        {
            if (PSystem == null)
                return;
            if (Asset != null)
            {
                if (!Asset.gameObject.activeSelf)
                    Asset.gameObject.SetActive(true);
            }
            else
            if (!this.gameObject.activeSelf)
                this.gameObject.SetActive(true);
            if (PSystem.isPlaying)
                PSystem.gameObject.SetActive(false);
            PSystem.gameObject.SetActive(true);
            mTime = 0;
            if (DisPsystem != null)
            {
                if (!DisPsystem.gameObject.activeSelf)
                {
                    DisPsystem.gameObject.SetActive(true);
                }
            }
            ScaleShurikenSystems(ScaleFactor);
            mVaildTime = VaildTime;
        }

        void Update()
        {

            if(Input.GetKeyDown(KeyCode.A))
            {
                Active();
            }

#if PROFILER
            Profiler.BeginSample("CsParticleController_Update");
#endif
            if (DisPsystem != null)
            {
                if (PSystem.isStopped)
                {
                    mTime += Serclimax.GameTime.deltaTime;
                    if (DisPsystem.gameObject.activeSelf)
                        DisPsystem.gameObject.SetActive(false);
                    if (mTime >= DisPsystem.duration)
                    {
                        if (DestroyWhenInvalid)
                        {
                            ReclaimReset();
                            CsObjPoolMgr.Instance.Destroy(Asset == null ? this.gameObject : Asset.gameObject);
                            //GameObject.Destroy(this.gameObject);
                        }
                        else
                        {
                            if (Asset != null)
                            {
                                Asset.gameObject.SetActive(false);
                            }
                            else
                                this.gameObject.SetActive(false);
                        }
                    }
                }
            }

            if(mVaildTime > 0)
            {
                mVaildTime -= Serclimax.GameTime.deltaTime;
                if(mVaildTime < 0)
                    mVaildTime = 0;
            }

            if (PSystem != null)
            {
                if (PSystem.isStopped || mVaildTime == 0)
                {
                    if (DisPsystem == null)
                    {
                        if (DestroyWhenInvalid)
                        {
                            ReclaimReset();
                            CsObjPoolMgr.Instance.Destroy(Asset == null ? this.gameObject : Asset.gameObject);
                            //GameObject.Destroy(this.gameObject);
                        }
                    }
                    {
                        if (DisPsystem == null)
                        {
                            if (Asset != null)
                            {
                                Asset.gameObject.SetActive(false);
                            }
                            else
                                this.gameObject.SetActive(false);
                        }
                        else
                            PSystem.gameObject.SetActive(false);
                    }
                }
            }
#if PROFILER
            Profiler.EndSample();
#endif
        }

        public void ReclaimReset()
        {
            mVaildTime = -1;
            if (PSystem != null)
            {
                PSystem.Clear();
                PSystem.gameObject.SetActive(false);
            }
            if (DisPsystem != null)
            {
                DisPsystem.Clear();
                DisPsystem.gameObject.SetActive(false);
            }
            DestroyWhenInvalid = false;
            mTime = 0;
        }
    }
}

