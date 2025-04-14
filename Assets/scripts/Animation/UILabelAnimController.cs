using UnityEngine;
using System.Collections;

using Serclimax;

public class UILabelAnimController : MonoBehaviour {

	bool bFinish =false;
	// Use this for initialization
	void Start () {

	}

	UILabel mLabel;
    long mFromNum, mToNum;
	float 	mCurrentNum;
	float	fAnimTime, fStepTime;
	string  mPrefix;
	string	mSuffix;

	public void Initialize(UILabel label, long fromNum, long toNum, float fTime = 0.5f, string sPrefix = "", string sSuffix = "")
	{
		mLabel = label;
		mFromNum = fromNum;
		mToNum = toNum;
		fAnimTime = fTime;
		mPrefix = sPrefix;
		mSuffix = sSuffix;
		fStepTime = 0;
		bFinish = false;
		if (mLabel)
			mLabel.text = mPrefix + mFromNum.ToString () + mSuffix;
	}

	// Update is called once per frame
	void Update () 
	{
		if (!bFinish)
		{
			fStepTime += GameTime.realDeltaTime;
			if (fStepTime > fAnimTime) 
			{
				fStepTime = fAnimTime;
				bFinish = true;
			}
			float step = fStepTime / fAnimTime;
			mCurrentNum = Mathf.Lerp (mFromNum, mToNum, step);
            long nNum = (long)mCurrentNum;
			if (bFinish)
			{
				nNum = mToNum;
			}
			if (mLabel)
				mLabel.text = mPrefix + nNum.ToString () + mSuffix;
		}
		else
		{
			Destroy(this);
		}
	}
}
