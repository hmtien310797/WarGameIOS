using UnityEngine;
using System.Collections;

public class PlaneShadow : MonoBehaviour
{
    [SerializeField]
    private Vector4 offset =  new Vector4(0,0,0,0);
    private Transform mTrf;
    
    public Vector4 Offset
    {
        get { return offset; }
        set
        {
            offset = value;
            Shader.SetGlobalVector("_ShadowOffset", Offset);
        }
    }
    void Awake()
    {
        mTrf = this.transform;
        Shader.SetGlobalVector("_ShadowOffset", Offset);
    }
    
	void Update ()
    {
        if(mTrf != null)
        {
            Shader.SetGlobalMatrix("_World2PShadow", mTrf.worldToLocalMatrix);
            Shader.SetGlobalMatrix("_PShadow2World",mTrf.localToWorldMatrix);
        }	
	}
}
