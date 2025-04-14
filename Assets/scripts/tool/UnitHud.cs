using System;
using System.Collections.Generic;
using UnityEngine;


public class UnitHud : MonoBehaviour
{
#if SHOW_HUD_VALUE
    UILabel HudTxt;
#endif
    private bool mFastLastTime = false;
    public bool FastLastTime
    {
        get
        {
            return mFastLastTime;
        }
        set
        {
            mFastLastTime = value;
        }
    }
    const float SHOW_LAST_TIME = 3.0f;
    const float SHOW_FAST_LAST_TIME = 0.3f;

    //VacuumShaders.CurvedWorld.CurvedWorld_Controller mCW = null;
    Vector3 lastCameraPosition;
    Vector3 lastHudPosition;

    UISprite hpFrame;
    UISlider hpSlider;
    UISlider hpSubSlider;

    Camera uiMainCamera;
    Camera targetCamera;
    Transform targetCameraTransform;
    GameObject targetUnit;
    Transform hudTransform;

    float mShowTime = -1;
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
#if SHOW_HUD_VALUE
        if (HudTxt == null)
        {
            HudTxt = this.gameObject.GetComponent<UILabel>();
        }
#endif
        if (mShowTime == -1)
        {
            NGUITools.SetActive(gameObject, true);
            TweenAlpha anim = transform.Find("hud frame").GetComponent<TweenAlpha>();
            bool isPlaying = anim.isActiveAndEnabled;
            //if (isPlaying)
            {
                anim.ClearOnFinished();
            }
            anim.PlayForward(!isPlaying);
        }
        mShowTime = 0;
        mIsShow = true;
        FollowTarget();
    }

    void animation_on_finished()
    {
        NGUITools.SetActive(gameObject, false);
        mIsShow = false;
    }

    public void Hide(bool _now = false)
    {
        mShowTime = -1;
        if (_now)
        {
            animation_on_finished();
        }
        else
        {
            TweenAlpha anim = transform.Find("hud frame").GetComponent<TweenAlpha>();
            anim.PlayReverse(!anim.isActiveAndEnabled);
            anim.SetOnFinished(animation_on_finished);
        }
    }

    public void SetSize(int _width, int _height)
    {
        if (_width != 0 && _height != 0)
        {
            hpFrame.width = _width;
            hpFrame.height = _height;

            hpSlider.foregroundWidget.width = _width;
            hpSlider.foregroundWidget.height = _height;

            hpSubSlider.foregroundWidget.width = _width;
            hpSubSlider.foregroundWidget.height = _height;
        }
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
            hudTransform = targetUnit.transform.Find("hp");
        }
    }

    public void SetTarget(Camera _targetCamera, Vector3 pos)
    {
        targetCamera = _targetCamera;
        if (targetCamera != null)
        {
            targetCameraTransform = targetCamera.transform;
        }
        Vector3 screenPos = targetCamera.WorldToScreenPoint(pos);

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
#if SHOW_HUD_VALUE
    public void SetHpNum(int value)
    {
        if (HudTxt == null)
        {
            HudTxt = this.gameObject.GetComponent<UILabel>();
            if (HudTxt == null)
            {
                HudTxt = this.gameObject.AddComponent<UILabel>();
                HudTxt.ambigiousFont = GameObject.Find("InGameUI/Container/Time").GetComponent<UILabel>().ambigiousFont;
            }
        }
        HudTxt.text = value.ToString();
    }
#endif
    public void SetHp(float _percent)
    {
        if (hpSlider != null)
        {
            hpSlider.value = _percent;
        }

        if (hpSubSlider != null)
        {
            UIAnimManager.instance.AddUIProgressBarAnim(hpSubSlider, hpSubSlider.value, _percent, 0.5f, 0.5f);
        }
    }

    public void StopAnim()
    {
        if (hpSubSlider == null)
            return;
        UIPBAnimController controller = hpSubSlider.gameObject.GetComponent<UIPBAnimController>();
        if (controller != null)
        {
            controller.Stop();
        }
    }

    public void InitHp(float _percent)
    {
        if (hpSlider != null)
        {
            hpSlider.value = _percent;
        }
        if (hpSubSlider != null)
        {
            hpSubSlider.value = _percent;
        }
    }

    void Awake()
    {
        lastCameraPosition = Vector3.zero;
        lastHudPosition = Vector3.zero;

        uiMainCamera = UICamera.mainCamera;

        hpFrame = transform.Find("hud frame").GetComponent<UISprite>();
        hpSlider = transform.Find("hud frame/hp slider").GetComponent<UISlider>();
        hpSubSlider = transform.Find("hud frame/hp sub slider").GetComponent<UISlider>();

        NGUITools.SetActive(hpSlider.gameObject, true);
        NGUITools.SetActive(hpSubSlider.gameObject, true);
    }

    void LateUpdate()
    {
#if PROFILER
        Profiler.BeginSample("UnitHUD_LateUpdate");
#endif
        if (!mAlwaysShow)
        {
            if (mShowTime != -1)
            {
                mShowTime += Serclimax.GameTime.deltaTime;
                if (FastLastTime)
                {
                    if (mShowTime >= SHOW_FAST_LAST_TIME)
                    {
                        Hide();
                    }
                }
                else
                {
                    if (mShowTime >= SHOW_LAST_TIME)
                    {
                        Hide();
                    }
                }
            }
        }

        if (mIsShow)
        {
            FollowTarget();
        }
#if PROFILER
        Profiler.EndSample();
#endif
    }

    void FollowTarget()
    {
        if (hudTransform != null && targetCameraTransform != null)
        {
            if (lastCameraPosition != targetCameraTransform.position ||
                lastHudPosition != hudTransform.position)
            {
                lastCameraPosition = targetCameraTransform.position;
                lastHudPosition = hudTransform.position;

                //if (mCW == null)
                //    mCW = SceneManager.instance.Entity.GetComponent<VacuumShaders.CurvedWorld.CurvedWorld_Controller>();
                //if (mCW != null)
                //{
                //    lastHudPosition = mCW.TransformPoint(lastHudPosition, VacuumShaders.CurvedWorld.BEND_TYPE.Universal);
                //}

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
