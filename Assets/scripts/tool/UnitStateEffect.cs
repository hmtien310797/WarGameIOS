using System;
using System.Collections.Generic;
using UnityEngine;


public class UnitStateEffect : MonoBehaviour
{
    Vector3 lastCameraPosition;
    Vector3 lastHudPosition;
    float stateDuration = 0;
    float stateCurTime = 0;

    UISprite mStateEffect = null;

    public UISprite StateEffect
    {
        get 
        { 
            if(mStateEffect == null)
            {
                mStateEffect = transform.Find("cd frame/cd_time").GetComponent<UISprite>();
            }
            return mStateEffect; 
        }
        set { mStateEffect = value; }
    }

    Camera uiMainCamera;
    Camera targetCamera;
    Transform targetCameraTransform;
    GameObject targetUnit;
    Transform EffectTransform;

    bool mIsShow = false;

    bool mAlwaysShow = false;
    public bool AlwaysShow
    {
        set 
        {
            mAlwaysShow = value;
        }
        get
        {
            return mAlwaysShow;
        }
    }

    public void Show()
    {
        mIsShow = true; 
        NGUITools.SetActive(gameObject, true);
        FollowTarget();
    }

    void animation_on_finished()
    {
        NGUITools.SetActive(gameObject, false);
        mIsShow = false;
        StateEffect.fillAmount = 0;
        stateCurTime = 0;
        stateDuration = 0;
    }

    public void Hide(bool _now = false)
    {
        animation_on_finished();
    }


    public void SetTarget(Camera _targetCamera, GameObject _targetUnit)
    {
        targetCamera = _targetCamera;
        if (targetCamera != null)
        {
            targetCameraTransform = targetCamera.transform;
        }
        targetUnit = _targetUnit;
        if (targetUnit != null)
        {
            EffectTransform = targetUnit.transform.Find("unit_cd");
        }
    }

    public void SetProgress(float _percent , float duration)
    {
        if (stateDuration <= 0)
            stateDuration = duration;
        StateEffect.fillAmount = _percent;
    }

    void Awake()
    { 
        lastCameraPosition = Vector3.zero;
        lastHudPosition = Vector3.zero;

        uiMainCamera = UICamera.mainCamera;

    }

    void LateUpdate()
    {
        if (stateDuration > 0)
        {
            if (stateCurTime >= stateDuration)
            {
                Hide();
            }

            stateCurTime += Serclimax.GameTime.deltaTime;
        }

        if (mIsShow)
        {
            FollowTarget();
        }
    }

    void FollowTarget()
    {
        if (EffectTransform != null && targetCameraTransform != null)
        {
            if (lastCameraPosition != targetCameraTransform.position ||
                lastHudPosition != EffectTransform.position)
            {
                lastCameraPosition = targetCameraTransform.position;
                lastHudPosition = EffectTransform.position;

                Vector3 screenPos = targetCamera.WorldToScreenPoint(lastHudPosition);

                if (uiMainCamera != null)
                {
                    Vector3 worldPos = uiMainCamera.ScreenToWorldPoint(screenPos);
                    worldPos.z = 0;
                    transform.position = worldPos;

                    Vector3 lp = transform.localPosition;
                    lp.x = Mathf.RoundToInt(lp.x);
                    lp.y = Mathf.RoundToInt(lp.y);
                    transform.localPosition = lp;
                }
            }
        }
    }
}
