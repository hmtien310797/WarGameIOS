using System;
using System.Collections.Generic;
using UnityEngine;

namespace Clishow
{
    public class CsBuild : MonoBehaviour
    {
        public GameObject ShadowPlane;

        public Renderer mesh;

        private bool mNeedUpdateShadow = false;

        private float mUpdateTime;

        public void Unactive()
        {
            if(ShadowPlane != null)
            {
                ShadowPlane.SetActive(true);
            }
            this.enabled = false;
        }

        public void Active()
        {
            if(ShadowPlane != null)
            {
                ShadowPlane.SetActive(false);
            }
            this.enabled = true;
        }

        void OnBecameVisible()
        {
            mNeedUpdateShadow = true;
        }

        void OnBecameInvisible()
        {
            mNeedUpdateShadow = false;
        }

        void UpdateShadow()
        {
            //if(!mNeedUpdateShadow)
            //    return;
            //if(mUpdateTime != 0)
            //{
            //    mUpdateTime -= Time.deltaTime;
            //    if(mUpdateTime > 0)
            //    {
            //        return;
            //    }
            //}
            //mUpdateTime = 5;
                SceneEntity entity = SceneManager.instance.Entity;
                if (entity == null)
                    entity = CsSLGPVPMgr.instance.Entity;
            if(mesh == null || entity == null || entity.ProjShadow == null)
                return;
            Bounds bounds = mesh.bounds;
            Vector3 view_max = Camera.main.WorldToViewportPoint(bounds.max);
            Vector3 view_min = Camera.main.WorldToViewportPoint(bounds.min);
            if(Camera.main.rect.Contains(view_max) || Camera.main.rect.Contains(view_min))
            {
                entity.ProjShadow.Adjust(this.transform.position);
            }
        }

        void Update()
        {
            UpdateShadow();
        }
    }
}
