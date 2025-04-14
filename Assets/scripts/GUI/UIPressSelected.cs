using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class UIPressSelected : MonoBehaviour
{
    public GameObject[] Targets;
    public GameObject PressObj;
    public bool Sender;
    public string Normal;
    public string PressSelected;
    public bool NormalState;
    public GameObject PressActiveObj;
    private UISprite mSprite;
    private Dictionary<int, GameObject> mTargetMaps;
    private GameObject mTouchCurrent;
    public delegate void OnPressSelectedEnd(GameObject obj);
    public OnPressSelectedEnd OnPSelectedEndCallBack;
    private List<UIPressSelected> mChildPS = null;
    public void Reset()
    {
        mPrePressState = false;
        if (mSprite != null)
        {
            mSprite.spriteName = Normal;
        }
        if (PressActiveObj != null)
        {
            PressActiveObj.SetActive(NormalState);
        }
        if (Sender)
        {
            if (mChildPS == null)
            {
                mChildPS = new List<UIPressSelected>();
                for (int i = 0; i < Targets.Length; i++)
                {
                    mChildPS.Add(Targets[i].GetComponent<UIPressSelected>());
                }
            }
            for (int i = 0; i < mChildPS.Count; i++)
            {
                mChildPS[i].Reset();
            }
        }
    }

    void Awake()
    {
        mSprite = GetComponent<UISprite>();
        mTargetMaps = new Dictionary<int, GameObject>();
        for (int i = 0; i < Targets.Length; i++)
        {
            mTargetMaps.Add(Targets[i].GetInstanceID(), Targets[i]);
        }
        if (PressActiveObj != null)
        {
            PressActiveObj.SetActive(NormalState);
        }
        mPrePressState = false;
        if (Sender)
            UICamera.onPress += OnPressSelected;
    }

    private void NotifyPressSelected(GameObject obj, bool isPress)
    {
        if (obj == null)
            return;
        int id = obj.GetInstanceID();
        if (mTargetMaps.ContainsKey(id))
        {
            UICamera.Notify(mTargetMaps[id], "OnPressSelected", isPress);
        }
    }

    bool mEnabled = true;
    private bool mWillEnable;

    public bool Enable
    {
        get
        {
            return mEnabled;
        }
        set
        {
            mEnabled = value; 
            if(mEnabled)
                enabled = true;
        }
    }

    private void OnPressSelected(bool ispress)
    {
        if (mSprite == null)
            return;
        if (!ispress)
        {
            if (PressActiveObj != null)
            {
                PressActiveObj.SetActive(NormalState);
            }
            mSprite.spriteName = Normal;
        }
        else
        {
            if (PressActiveObj != null)
            {
                PressActiveObj.SetActive(!NormalState);
            }
            mSprite.spriteName = PressSelected;
        }

    }

    void OnDestroy()
    {
        if (Sender)
            UICamera.onPress -= OnPressSelected;
    }


    void Update()
    {
        if (!Sender)
            return;
        bool wasPressed = Input.GetMouseButton(0);
        if (PressObj != null)
        {
            if (!mPrePressState)
            {
                PressObj.SetActive(false);
            }
        }
        if (UICamera.controller == null)
            return;
        if (PressObj != null)
        {
            PressObj.transform.position = UICamera.lastWorldPosition;
            if (mPrePressState)//!PressObj.activeSelf && 
            {
                PressObj.SetActive(true);
            }
        }
        if (mPrePressState)
        {
            if (mTouchCurrent != UICamera.lastHit.collider.gameObject)
            {
                NotifyPressSelected(mTouchCurrent, false);
                mTouchCurrent = UICamera.lastHit.collider.gameObject;
                NotifyPressSelected(mTouchCurrent, true);
            }
        }
        if(!mEnabled)
            enabled = false;
    }
    private bool mPrePressState;
    void OnPressSelected(GameObject obj, bool wasPressed)
    {
        mPrePressState = wasPressed;
        if (!mPrePressState)
        {
            if (OnPSelectedEndCallBack != null)
            {
                OnPSelectedEndCallBack(UICamera.lastHit.collider.gameObject);
            }
        }
    }
}
