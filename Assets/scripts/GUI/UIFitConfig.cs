using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax;

public class UIFitConfig : MonoBehaviour
{
    public string deviceKey = string.Empty;
    public int leftOffset = 0;
    public int rightOffset = 0;
    private UIWidget uiwidget = null;

    void Awake()
    {
        float realW = (float)Screen.currentResolution.width;
        float realH = (float)Screen.currentResolution.height;
        Debug.Log("currentResolution width:" + realW + " height:" + realH);
        uiwidget = transform.GetComponent<UIWidget>();
        string sysInfo = GUIMgr.Instance.GetSystemInfo();
        if (uiwidget != null && deviceKey != string.Empty && sysInfo.Contains(deviceKey))
        {
            uiwidget.leftAnchor.Set(0, leftOffset);
            uiwidget.rightAnchor.Set(1, rightOffset);
            uiwidget.ResetAnchors();
        }
    }

    void Start()
    {

    }
}

