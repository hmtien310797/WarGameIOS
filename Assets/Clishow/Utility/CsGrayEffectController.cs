using UnityEngine;
using System.Collections;

public class CsGrayEffectController : MonoBehaviour
{
    private float grayScaleAmount = 0.0f;

    private Shader mShader;    
    private Material mMaterial;

    private float mTotalTime;
    private float mTime;

    private bool mNeedUpdate = false;

    private float mTargetGrayScaleAmount = 0;

    public Material GrayMaterial
    {
        get
        {
            if (mMaterial == null)
            {
                mMaterial = new Material(mShader);
                mMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return mMaterial;
        }
    }

    void Start ()
    {
        if (SystemInfo.supportsImageEffects == false)
        {
            enabled = false;
            return;
        }
        mShader = Shader.Find("wgame/ImageEffect/Gray");
        if (mShader != null && mShader.isSupported == false)
        {
            enabled = false;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (mShader != null)
        {
            GrayMaterial.SetFloat("_LuminosityAmount", grayScaleAmount);

            Graphics.Blit(sourceTexture, destTexture, GrayMaterial);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }

    }

    void OnDisable()
    {
        if (GrayMaterial != null)
        {
            DestroyImmediate(GrayMaterial);
        }
    }

    public void ToGary(bool enable, float time)
    {
        if (enable)
        {
            grayScaleAmount = 0;
            mTargetGrayScaleAmount = 1;
        }
        else
        {
            grayScaleAmount = 1;
            mTargetGrayScaleAmount = 0;
        }
        this.enabled = true;
        this.gameObject.SetActive(true);
        mTime = Time.realtimeSinceStartup;
        mTotalTime = time;
        mNeedUpdate = true;
    }

    private float easeInQuad(float start, float end, float value)
    {
        end -= start;
        return end * value * value + start;
    }

    void Update()
    {
        if (!mNeedUpdate)
            return;
        float t = Time.realtimeSinceStartup - mTime;
        if (t >= mTotalTime)
        {
            mNeedUpdate = false;
            grayScaleAmount = mTargetGrayScaleAmount;
        }
        else
        {
            grayScaleAmount = easeInQuad(grayScaleAmount, mTargetGrayScaleAmount, t / mTotalTime);
        }


    }
}
