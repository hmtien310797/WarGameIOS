using UnityEngine;
using System.Collections;
using Serclimax;

public class ShakeUtil : MonoBehaviour
{
    public float time;
    public Vector3 mag;
    public Vector3 mag2;
    public float frequency;
    public float delay = 0.25f;

    private float mTime;
    private float mFreqTime;
    private Transform mTransform;
    private Vector3 mDelta = Vector3.zero;
    private Vector3 mShakeMag;
    private bool mIsShaking;
    private bool mEnableDelay = false;
    private float mDelay = 0;

    public static void Shake(GameObject obj, float _time, Vector3 _mag, Vector3 _mag2, float _frequency)
    {
        if (obj == null || _time <= 0)
            return;
        ShakeUtil su = obj.GetComponent<ShakeUtil>();
        if (su == null) su = obj.AddComponent<ShakeUtil>();
        su.SetParams(_time, _mag, _mag2, _frequency);
    }

    public void SetParams(float _time, Vector3 _mag, Vector3 _mag2, float _frequency)
    {
        if (mIsShaking)
            return;
        if (mEnableDelay)
            return;

        enabled = true;
        time = _time;
        mag = _mag;
        mag2 = _mag2;
        frequency = _frequency;
        mTime = 0;
        mFreqTime = 0;
        mTransform = transform;
        mIsShaking = true;
    }

    void LateUpdate()
    {
        //if(mEnableDelay)
        //{
        //    mDelay += GameTime.realDeltaTime;
        //    if(mDelay >= delay)
        //    {
        //        mDelay = 0;
        //        enabled = false;
        //        mEnableDelay = false;
        //    }
        //    //return;
        //}
        mTime += GameTime.realDeltaTime;
        if (mTime >= time)
        {
            if (mTime >= time + delay)
            {
                enabled = false;
                mEnableDelay = false;
            }
            else
            {
                mTransform.localPosition -= mDelta;
                mDelta = Vector3.zero;
                //enabled = false;
                mIsShaking = false;
                mEnableDelay = true;
            }

            return;
        }

        float percentage = mTime / time;
        Vector3 preDelta = mDelta;

        Vector3 mag3 = Vector3.Lerp(mag, mag2, percentage);
        {
            if (frequency <= 0)
            {
                if (mFreqTime == 0)
                {
                    mDelta = mag3;
                    mFreqTime = 1;
                }
                else
                {
                    mDelta = -mag3;
                    mFreqTime = 0;
                }
            }
            else
            {
                mFreqTime += GameTime.realDeltaTime;
                if (mFreqTime >= frequency)
                {
                    mShakeMag = mag3;
                    mFreqTime = 0;
                    mDelta = mShakeMag;
                }
                else
                {
                    float t = mFreqTime / frequency;
                    if (t <= 0.5f) mDelta = Vector3.Lerp(mShakeMag, -mShakeMag, t * 2f);
                    else mDelta = Vector3.Lerp(-mShakeMag, mShakeMag, (t - 0.5f) * 2f);
                }
            }
        }

        mTransform.localPosition += mDelta - preDelta;
    }
}

