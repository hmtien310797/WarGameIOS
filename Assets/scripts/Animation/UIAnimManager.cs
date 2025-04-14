using UnityEngine;
using System.Collections;

public class UIAnimManager
{
	private static UIAnimManager sInstance;
	
	public static UIAnimManager instance
	{
		get
		{
			if (sInstance == null)
				sInstance = new UIAnimManager();
			return sInstance;
		}
	}

    public void IncreaseUILabelTextAnim(UILabel label, long nFromNum, long nToNum)
    {
        AddUILabelTextAnim(label, nFromNum, nToNum,1);
    }
	public UILabelAnimController AddUILabelTextAnim(UILabel label, long nFromNum, long nToNum, float fAnimTime = 0.5f, string sPrefix = "", string sSuffix = "")
	{
		if (label && label.gameObject)
		{
			if (nFromNum != nToNum)
			{
				UILabelAnimController controller = label.gameObject.GetComponent<UILabelAnimController>();
				if (controller == null)
				{
					controller = label.gameObject.AddComponent<UILabelAnimController>();
				}
				controller.Initialize(label, nFromNum, nToNum, fAnimTime, sPrefix, sSuffix);
				return controller;
			}
			else
			{
				UILabelAnimController controller = label.gameObject.GetComponent<UILabelAnimController>();
				if (controller != null)
				{
					GameObject.DestroyImmediate(controller);
				}
				label.text = sPrefix + nFromNum + sSuffix;
			}
		}
		return null;
	}

	public UIPBAnimController AddUIProgressBarAnim(UIProgressBar pbar, float nFromValue, float nToValue, float fAnimTime = 0.5f, float fDelay = 0)
	{
		if (pbar && pbar.gameObject)
		{
			if (nFromValue == nToValue && fDelay == 0)
			{
				pbar.value = nFromValue;
			}
			else
			{
				UIPBAnimController controller = pbar.gameObject.GetComponent<UIPBAnimController>();
				if (controller == null)
				{
					controller = pbar.gameObject.AddComponent<UIPBAnimController>();
				}
				controller.Initialize(pbar, nFromValue, nToValue, fAnimTime, fDelay);
				return controller;
			}
		}
		return null;
	}
}
