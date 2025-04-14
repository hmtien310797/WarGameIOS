using UnityEngine;
using System.Collections;

public class FirelineController : MonoBehaviour
{
    Projector mProjector = null;
    Vector3 mOriginPos;

    Vector3 mStart;
    Vector3 mEnd;
    Vector3 mDirection;

    Material mMaterial;
    float mFlashTime1;
    float mFlashTime2;
    float mFlashDuring;
    float mFlashProgress;
    bool mStartFlash;
    Color mOriginColor;
    Color mFlashColor1;
    Color mFlashColor2;

    float mOffset;

    public void Init(Vector3 _start, Vector3 _init, Vector3 _end)
    {
        if (mProjector == null)
            return;

        mStart = _start;
        mEnd = _end;

        float fDistance = Vector2.Distance(new Vector2(mStart.x, mStart.z), new Vector2(mOriginPos.x, mOriginPos.z));
        mOffset = mProjector.orthographicSize * mProjector.aspectRatio + fDistance;

        mDirection = Vector3.Normalize(mEnd - mStart);

        mProjector.transform.position = mOriginPos - mOffset * mDirection;
        mOriginPos = mProjector.transform.position;

        mMaterial = new Material(mProjector.material);
        mOriginColor = mMaterial.GetColor("_Color");
        mFlashColor1 = new Color(mOriginColor.r, mOriginColor.g, mOriginColor.b, 0.3f);
        mFlashColor2 = new Color(mOriginColor.r, mOriginColor.g, mOriginColor.b, 0f);

        mProjector.material = mMaterial;

        //Flash(0.5f, 0.5f);
    }

    public void MoveTo(Vector3 _point, bool _immediate)
    {
        float fDistance = Vector3.Distance(_point, mStart);
        mProjector.transform.position = mOriginPos + fDistance * mDirection;
    }

    public void Flash(float _flashTime1, float _flashTime2)
    {
        mFlashTime1 = _flashTime1;
        mFlashTime2 = _flashTime2;
        mFlashProgress = 0;
        mStartFlash = true;
    }

    public void StopFlash()
    {
        mFlashTime1 = 0;
        mFlashTime2 = 0;
        mFlashProgress = 0;
        mStartFlash = false;

        if (mMaterial != null)
        {
            mMaterial.SetColor("_Color", mOriginColor);
        }
    }


    void Awake()
    {
        mProjector = GetComponent<Projector>();
        mOriginPos = mProjector.transform.position;
    }

    void OnDestroy()
    {
        if (mMaterial != null)
        {
            DestroyImmediate(mMaterial, true);
        }
    }

    void Update()
    {
        if (mStartFlash)
        {
            mFlashDuring = Mathf.Lerp(mFlashTime1, mFlashTime2, Serclimax.GameTime.deltaTime);
            mFlashProgress += Serclimax.GameTime.deltaTime / mFlashDuring;

            while (mFlashProgress > 2)
                mFlashProgress -= 2;

            Color color = mFlashColor1;
            if (mFlashProgress <= 1)
            {
                color = Color.Lerp(mFlashColor1, mFlashColor2, mFlashProgress);
            }
            else if (mFlashProgress <= 2)
            {
                color = Color.Lerp(mFlashColor2, mFlashColor1, mFlashProgress - 1);
            }

            mMaterial.SetColor("_Color", color);
        }
    }
}
