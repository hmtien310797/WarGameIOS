using UnityEngine;
using System.Collections;

[RequireComponent(typeof(UIEventListener))]
public class UIHoldClick : MonoBehaviour
{
    public float Interval = 1;

    public float DelayTime = 0;

    public delegate void HoldClickCallBack(GameObject go);

    public HoldClickCallBack OnHoldClick = null;

    private float mTime = 0;

    private float mDelay = 0;

    private bool mState = false;

    private GameObject mTarget = null;

    void Awake()
    {
        UIEventListener e = GetComponent<UIEventListener>();
        if (e != null)
        {
            e.onPress = HoverCallBack;
        }
        mTime = 0;
    }

    void HoverCallBack(GameObject go,bool state)
    {
        mState = state;
        mTarget = go;
    }

    void Update()
    {
        if (!mState)
        {
            mTime = 0;
            mDelay = 0;
            return;
        }

        if (mDelay >= DelayTime)
        {
            mTime += Serclimax.GameTime.deltaTime;
            if (mTime >= Interval)
            {
                mTime = 0;
                if (OnHoldClick != null)
                    OnHoldClick(mTarget);
            }
        }
        else
            mDelay += Serclimax.GameTime.deltaTime;

    }

}
