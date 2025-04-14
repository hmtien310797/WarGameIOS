using UnityEngine;
using System.Collections;

public class LocalizeEx : MonoBehaviour 
{
	public string key;

	public string value
	{
		set
		{
            if (!string.IsNullOrEmpty(value))
            {
                UILabel lbl = GetComponent<UILabel>();
                UnityEngine.UI.Text txt = GetComponent<UnityEngine.UI.Text>();
                if (lbl != null)
                {
                    // If this is a label used by input, we should localize its default value instead
                    UIInput input = NGUITools.FindInParents<UIInput>(lbl.gameObject);
                    if (input != null && input.label == lbl)
                    {
                        input.defaultText = value;
                    }
                    else
                    {
                        lbl.text = value;
                    }
#if UNITY_EDITOR
                    if (!Application.isPlaying) NGUITools.SetDirty(lbl);
#endif
                }
                else if (txt != null)
                    txt.text = value;
            }
        }
	}

	bool mLocalized = false;

	void OnEnable()
	{
#if UNITY_EDITOR
		if (!Application.isPlaying) return;
#endif
		if (!mLocalized) OnLocalize();
	}

	void Start () 
	{
#if UNITY_EDITOR
		if (!Application.isPlaying) return;
#endif
		OnLocalize ();
	}
	
	void OnLocalize ()
	{
		//UILabel lbl = GetComponent<UILabel>();
		value = TextManager.Instance.GetText(key);
		mLocalized = true;
	}
}
