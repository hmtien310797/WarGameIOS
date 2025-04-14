using UnityEngine;

public class WorldHUDLabel : WorldHUDWidget
{
    public bool UseNGUI = true;
    [SerializeField]
    private bool BackgroundAdaptation = true;
    [SerializeField]
    private Vector2 AdaptationFactor = new Vector2(1.5f, 1.3f);

    private Color currentColor;
    private string currentText;

    private RectTransform _uiBackground;
    private UnityEngine.UI.Text _UGuiText;
    private UILabel _uiText;

    private void Awake()
    {
        switch (transform.childCount)
        {
            case 1:
                _uiBackground = null;
                if (!UseNGUI)
                {
                    _UGuiText = transform.GetChild(0).GetComponent<UnityEngine.UI.Text>();
                }
                else
                {
                    _uiText = transform.GetChild(0).GetComponent<UILabel>();
                }
                break;
            case 2:
                _uiBackground = transform.GetChild(0).GetComponent<RectTransform>();

                if (!UseNGUI)
                {
                    _UGuiText = transform.GetChild(1).GetComponent<UnityEngine.UI.Text>();
                }
                else
                {
                    _uiText = transform.GetChild(1).GetComponent<UILabel>();
                }
                break;
            default:
                return;
        }
    }

    public override float width
    {
        get
        {
            if (UseNGUI)
                return _uiText.width * defaultSize.x;
            else
                return _UGuiText.preferredWidth * defaultSize.x;
        }
    }

    public override Color color
    {
        get
        {
            return currentColor;
        }

        set
        {
            if (currentColor == null || currentColor != value)
            {
                if (UseNGUI)
                    _uiText.color = currentColor = value;
                else
                    _UGuiText.color = currentColor = value;
            }

        }
    }

    public override string text
    {
        get
        {
            return currentText;
        }

        set
        {
            if (currentText == null || currentText != value)
            {
                if (UseNGUI)
                    _uiText.text = currentText = value;
                else
                    _UGuiText.text = currentText = value;

                if (BackgroundAdaptation)
                    DoBackgroundAdaptation();
            }
        }
    }

    public void DoBackgroundAdaptation()
    {
        if (_uiBackground != null)
            _uiBackground.sizeDelta = new Vector2(AdaptationFactor.x * _uiText.width, AdaptationFactor.y * _uiText.height);
    }
    public void SetFontSize(int fontsize)
    {
        _uiText.fontSize = fontsize;
    }

}
