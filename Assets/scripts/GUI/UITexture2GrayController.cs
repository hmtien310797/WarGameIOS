using UnityEngine;
using System.Collections;

[RequireComponent(typeof(UITexture))]
public class UITexture2GrayController : MonoBehaviour
{
    public Shader GrayShader = null;

    private UITexture mTexture = null;

    private string mSourceShaderName = string.Empty;

    public UITexture UITex
    {
        get
        {
            if (mTexture == null)
            {
                mTexture = this.GetComponent<UITexture>();
            }
            return mTexture;
        }
    }

    public bool IsGray
    {
        get
        {
            return UITex.shader.name.Contains("Unlit/Transparent Colored Gray");
        }
        set
        {
            string sn = UITex.shader.name;
            if (value)
            {
                if (sn.Contains("Unlit/Transparent Colored Gray"))
                {
                    if (UITex.color != Color.black)
                    {
                        UITex.color = Color.black;
                    }
                    return;
                }
                    
                mSourceShaderName = sn;
                if (GrayShader == null)
                    GrayShader = Shader.Find("Unlit/Transparent Colored Gray");
                UITex.shader = GrayShader;
                UITex.color = Color.black;
            }
            else
            {
                if (!sn.Contains("Unlit/Transparent Colored Gray"))
                {
                    return;
                }
                    
                if (string.IsNullOrEmpty(mSourceShaderName))
                {
                    UITex.shader = Shader.Find("Unlit/Transparent Colored");
                }
                else
                {
                    UITex.shader = Shader.Find(mSourceShaderName);
                }
                UITex.color = Color.white;
            }
        }
    }
}
