using UnityEngine;
using System.Collections;
[RequireComponent(typeof(UISlider))]
public class UISliderOnChangeEvent : MonoBehaviour
{
    public delegate void FloatDelegate(GameObject go, float delta);

    public FloatDelegate OnChange;

    public void OnSliderChange()
    {
        if (OnChange != null)
        {
            OnChange(this.gameObject, mSlider.value);
        }
    }

    private UISlider mSlider = null;
    void Awake()
    {
        mSlider = this.gameObject.GetComponent<UISlider>();
    }
}
