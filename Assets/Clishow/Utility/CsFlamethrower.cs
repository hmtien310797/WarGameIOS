using UnityEngine;
using System.Collections;

public class CsFlamethrower : MonoBehaviour
{
    public float DisUnit = 0.25f;

    public int DisRate = 100;

    public int Rate = 10;

    private ParticleSystem mPsystem = null;

    private bool mNeedUpdateEmitting = false;

    private int mCurPCount = 0;

    private float mEmitTime = 0;

    private int mCurp = 0;

    private int mCurRate = 0;

    private int mTotalCount = 0;

    private ParticleSystem.EmitParams mEmitParams = new ParticleSystem.EmitParams();

    private ParticleSystem _Psystem
    {

        get
        {
            if (mPsystem == null)
            {
                mPsystem = this.gameObject.GetComponent<ParticleSystem>();
            }
            return mPsystem;
        }
    }

    public void init()
    {
        _Psystem.loop = false;
        ParticleSystem.EmissionModule emission = _Psystem.emission;
        emission.enabled = false;

        mEmitParams.startColor = _Psystem.startColor;
        mEmitParams.startSize = _Psystem.startSize;
        
    }

    public void Active(Vector3 target,float speed)
    {
        mCurPCount = 0;
        mNeedUpdateEmitting = true;
        mEmitTime = 0;
        mCurp = 0;
        mCurRate = Rate;
        Vector3 dir = target - this.transform.position;
        float dis = dir.magnitude;
        mEmitParams.velocity = dir.normalized * speed;
        mEmitParams.startLifetime = (dis  / speed);
        mEmitParams.position = this.transform.position;
        ParticleSystem.TextureSheetAnimationModule anim_module = _Psystem.textureSheetAnimation;
        anim_module.cycleCount = (int)mEmitParams.startLifetime;
        this.transform.forward = dir.normalized;
        mTotalCount = (int)(dis / DisUnit) * DisRate;
    }

    public void StopEmit()
    {
        mNeedUpdateEmitting = false;
    }

    private void UpdateEmit(float _dt)
    {
        if (!mNeedUpdateEmitting || _Psystem == null)
            return;
        mEmitTime += _dt;

        int count = (int)((mEmitTime>=1?1:mEmitTime)* (float)mCurRate);
        _Psystem.Emit(mEmitParams, count - mCurp);
        mCurp = count;


        if (mEmitTime >= 1)
        {
            if (mCurPCount == mTotalCount)
            {
                mNeedUpdateEmitting = false;
                return;
            }
            mEmitTime = 0;

            count = mCurPCount + mCurp;
            if (count < mTotalCount)
            {
                mCurRate = Rate;
                mCurPCount = count;
            }
            else
            {
                mCurRate = mTotalCount - mCurPCount;
                mCurPCount = mTotalCount;
            }
            mCurp = 0;
        }
    }
	
	// Update is called once per frame
	void Update ()
    {
        UpdateEmit(Time.deltaTime);
    }
}
