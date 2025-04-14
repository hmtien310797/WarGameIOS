using UnityEngine;
using System.Collections;

public class CsRefrushProjShadow : MonoBehaviour
{
    public Bounds bound;
    public Clishow.CsTrackPathManager mgr = null;
    void Awake()
    {
    }
	
    private Transform mSelfTrf;
    public Transform _selftrf
    {
        get
        {
            if(mSelfTrf == null)
                mSelfTrf = this.transform;
            return mSelfTrf;
        }
    }

	// Update is called once per frame
	void Update () {
            if (mgr != null)
            {

                if (mgr.Entity.ProjShadow != null)
                {
                    Vector3 view_max = Camera.main.WorldToViewportPoint(bound.max+_selftrf.position);
                    Vector3 view_min = Camera.main.WorldToViewportPoint(bound.min+_selftrf.position);
                    if (Camera.main.rect.Contains(view_max) || Camera.main.rect.Contains(view_min))
                    {
                        mgr.Entity.ProjShadow.Adjust(_selftrf.position);
                    }
                }
            }
	}
}
