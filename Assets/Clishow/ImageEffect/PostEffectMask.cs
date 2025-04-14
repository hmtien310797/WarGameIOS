using UnityEngine;
using System.Collections;
[RequireComponent(typeof(Renderer))]
public class PostEffectMask : MonoBehaviour
{
    public float ShowTime = 1;
    public bool BloomEffect = true;
    private float mShowTime = 0;
    private float mSize =1;
    private Renderer mRender =null;
    private Transform mSelfTrf;
    private Vector3 mStartSize;
    private PostEffectMaskLight mLight;
    public Transform SelfTrf
    {
        get
        {
            if(mSelfTrf == null)
                mSelfTrf = this.transform;
            return mSelfTrf;
        }
    }
    void Awake()
    {
        this.gameObject.layer = LayerMask.NameToLayer(Clishow.CsPostEffect.PostMaskLayerName);
        mLight = GetComponent<PostEffectMaskLight>();
        if(mLight == null)
        {
            mLight = this.gameObject.AddComponent<PostEffectMaskLight>();
            mLight.LightColor = Color.white;
            mLight.LightDir = Vector3.up;
            mLight.LightRange = 5;
        }
            


        mRender = this.gameObject.GetComponent<Renderer>();
        mStartSize = SelfTrf.localScale;
    }
    void OnEnable()
    {
                SceneEntity entity = SceneManager.instance.Entity;
                if (entity == null)
                    entity = CsSLGPVPMgr.instance.Entity;
        if(entity != null && entity.PostEffect != null && GameSetting.instance.option.mQualityLevel == 2)
        {
            entity.PostEffect.AddMask();
            mRender.enabled = true;
            mShowTime = 0;
            mSize =1;
        }
        else
        {
            this.gameObject.SetActive(false);
        }
    }

    void OnDisable()
    {
                SceneEntity entity = SceneManager.instance.Entity;
                if (entity == null)
                    entity = CsSLGPVPMgr.instance.Entity;
        if(entity != null && entity.PostEffect != null && GameSetting.instance.option.mQualityLevel == 2)
            entity.PostEffect.RemoveMask();
    }

    void UpdateMask()
    {
        if(ShowTime < 0)
            return;
        mShowTime += Time.deltaTime;
        if(mShowTime >= ShowTime)
        {
            mRender.enabled = false;
        }
        else
        {
            mSize = mShowTime/ShowTime;
            if(!BloomEffect)
            {
                SelfTrf.localScale = mStartSize*(1-mSize);
            }
            else
            {
                if(mLight != null)
                    mLight.LightForce  = easeInExpo(1.0f,0f,mSize);
                //SelfTrf.localScale = mStartSize*easeInExpo(1.0f,0.5f,mSize);
            }

        }
    }
	private float easeInExpo(float start, float end, float value){
		end -= start;
		return end * Mathf.Pow(2, 10 * (value - 1)) + start;
	}

    void Update()
    {
        UpdateMask();
    }
}
