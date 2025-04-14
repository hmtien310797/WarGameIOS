using UnityEngine;
using System.Collections;

public class CsMatShaderHelper : MonoBehaviour
{
    private float mValue = 0;

    private Renderer mRenderer = null;

    public float value
    {
        get {
            return mValue;
        }

        set
        {
            if (value != mValue)
            {
                mValue = value;
                if (mRenderer == null)
                    mRenderer = gameObject.GetComponent<Renderer>();
                if (mRenderer != null)
                {
                    mRenderer.material.SetFloat(PropertieName, mValue);
                }
            }
            
        }
    }

    public string PropertieName;


    public float TargetValue = 0;

    void Awake()
    {
        value = TargetValue;
    }

    public void Update()
    {
        value = TargetValue;
    }
}
