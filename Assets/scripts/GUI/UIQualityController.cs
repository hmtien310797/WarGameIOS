using UnityEngine;
using System.Collections;

public class UIQualityController : MonoBehaviour {
    void Awake()
    {
        if(GameSetting.instance.option.mQualityLevel <= 0)
            return;
        UIWidget widget = GetComponent<UIWidget>();
        if(widget != null)
        {
            widget.alpha = 0.1f;
        }
    }
}
