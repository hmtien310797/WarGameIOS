using UnityEngine;
using System.Collections;

public class FortRangeEffect : MonoBehaviour
{
    public UITexture maxRange;
    public TweenHeight effectHeight;
    public TweenWidth effectWidht;
    public float Offset;

    private Transform mSelfTrf;
    public Transform _selfTrf
    {
        get
        {
            if (mSelfTrf == null)
                mSelfTrf = this.transform;
            return mSelfTrf;
        }
    }
    private int mMaxWidth;
    private int mMaxHeight;
    public void Init(int width, int height, float size)
    {
        float panlesize = 1 / _selfTrf.localScale.x;
        mMaxWidth = Mathf.RoundToInt((width * size + Offset) * panlesize) ;
        mMaxHeight = Mathf.RoundToInt((height * size +Offset) * panlesize);
        if (maxRange != null)
        {
            maxRange.width = mMaxWidth;
            maxRange.height = mMaxHeight;
        }
        if (effectWidht != null)
        {
            effectWidht.to = mMaxWidth;
        }
        if (effectHeight != null)
        {
            effectHeight.to = mMaxHeight;
        }
    }

}
