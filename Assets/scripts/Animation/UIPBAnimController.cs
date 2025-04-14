using UnityEngine;
using System.Collections;

using Serclimax;
public class UIPBAnimController : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}

	bool bFinish = true;
	UIProgressBar mProgressbar;
	float	mFromValue, mToValue;
	float 	mCurrentValue;
	float	fAnimTime, fStepTime;
	float	fDelayTime, fDelayStepTime;

    public void Stop()
    {
        bFinish = false;
        mProgressbar = null;
    }

	public void Initialize(UIProgressBar _pbar, float _fromValue, float toValue, float fTime = 0.5f, float fDelay = 0)
	{
		if (!bFinish) 
		{
			mToValue = toValue;	
		}
		else
		{
			mProgressbar = _pbar;
			mFromValue = _fromValue;
			mToValue = toValue;
			fAnimTime = fTime;
			fStepTime = 0;
			fDelayTime = fDelay;
			fDelayStepTime = 0;
			bFinish = false;
			if (mProgressbar)
				mProgressbar.value = mFromValue;
		}
	}

	// Update is called once per frame
	void Update () 
	{
		if (!bFinish)
		{
			fDelayStepTime += GameTime.realDeltaTime;
			if (fDelayStepTime < fDelayTime)
			{
				return;
			}

			fStepTime += GameTime.realDeltaTime;
			if (fStepTime > fAnimTime) 
			{
				fStepTime = fAnimTime;
				bFinish = true;
			}
			float step = fStepTime / fAnimTime;
			mCurrentValue = Mathf.Lerp (mFromValue, mToValue, step);
			if (mProgressbar)
				mProgressbar.value = mCurrentValue;
		}
		else
		{
			if (mProgressbar)
				mProgressbar.value = mToValue;
			Destroy(this);
		}
	}
}
