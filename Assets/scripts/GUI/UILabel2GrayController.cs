using UnityEngine;
using System.Collections;

[RequireComponent(typeof(UILabel))]
public class UILabel2GrayController : MonoBehaviour
{
    private UILabel mLabel;

    public UILabel Label
    {
        get
        {
            if (mLabel == null)
            {
                mLabel = this.GetComponent<UILabel>();
                mGradientTopColor = mLabel.gradientTop;
                mGradierBottomColor = mLabel.gradientBottom;
            }
            return mLabel;
        }
    }

    private bool mIsGray = false;

    private Color mGradientTopColor;
    private Color mGradierBottomColor;


    public bool IsGray
    {
        get
        {
            return mIsGray;
        }

        set
        {
            if (mIsGray == value)
                return;
            mIsGray = value;
            if (mIsGray)
            {
                Label.gradientTop = Color.gray;
                Label.gradientBottom = Color.gray;
            }
            else
            {
                Label.gradientTop = mGradientTopColor;
                Label.gradientBottom = mGradierBottomColor;
            }
        }
    }

}
