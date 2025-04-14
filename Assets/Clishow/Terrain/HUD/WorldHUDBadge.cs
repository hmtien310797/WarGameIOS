using UnityEngine;

public class WorldHUDBadge : WorldHUDWidget
{
    [SerializeField] private Sprite[] _presetedBackgrounds;
    [SerializeField] private Sprite[] _presetedFrames;
    [SerializeField] private Sprite[] _presetedIcons;
    [SerializeField] private Sprite[] _presetedMasks;

    private UnityEngine.UI.Image _uiBackground;
    private UnityEngine.UI.Image _uiFrame;
    private UnityEngine.UI.Image _uiIcon;
    private UnityEngine.UI.Image _uiMask;

    private Color _color;
    private int _backgroundType = -1;
    private int _frameType = -1;
    private int _iconType = -1;
    private int _maskType = -1;

    private void Awake()
    {
        _uiBackground = transform.GetChild(0).GetChild(0).GetComponent<UnityEngine.UI.Image>();
        _uiFrame = transform.GetChild(1).GetComponent<UnityEngine.UI.Image>();
        _uiIcon = transform.GetChild(2).GetComponent<UnityEngine.UI.Image>();
        _uiMask = transform.GetChild(0).GetComponent<UnityEngine.UI.Image>();
    }

    public override Sprite background
    {
        get
        {
            return _uiBackground.sprite;
        }

        set
        {
            SetBackgroundSprite(value);
            _backgroundType = -1;
        }
    }

    public override int backgroundType
    {
        get
        {
            return _backgroundType;
        }

        set
        {
            UsePresetedBackground(value);
        }
    }

    public override Color color
    {
        set
        {
            if (_color == null || _color != value)
            {
                transform.GetChild(0).GetChild(0).GetComponent<UnityEngine.UI.Image>().color = value;
                _color = value;
                transform.GetChild(0).localScale = _color == null ? Vector3.zero : Vector3.one;
            }
        }
    }

    public override Sprite frame
    {
        get
        {
            return _uiFrame.sprite;
        }

        set
        {
            SetFrameSprite(value);
            _frameType = -2;
        }
    }

    public override int frameType
    {
        get
        {
            return _frameType;
        }

        set
        {
            UsePresetedFrames(value);
        }
    }

    public override Sprite icon
    {
        get
        {
            return transform.GetChild(2).GetComponent<UnityEngine.UI.Image>().sprite;
        }

        set
        {
            SetIconSprite(value);
            _iconType = -1;
        }
    }

    public override int iconType
    {
        get
        {
            return _iconType;
        }

        set
        {
            UsePresetedIcons(value);
        }
    }

    public override Sprite mask
    {
        get
        {
            return _uiMask.sprite;
        }

        set
        {
            _maskType = -1;
            SetMaskSprite(value);
        }
    }

    public override int maskType
    {
        get
        {
            return _maskType;
        }

        set
        {
            UsePresetedMasks(value);
        }
    }

    public override float width
    {
        get
        {
            return _uiFrame.GetComponent<RectTransform>().sizeDelta.x * defaultSize.x;
        }
    }

    public void UsePresetedBackground(int index)
    {
        if (_presetedBackgrounds.Length == 0)
            Debug.LogWarning("[WorldHUDBadge] There is no preseted backgrounds");
        else if (index >= 0 && index != _backgroundType)
        {
            SetFrameSprite(_presetedBackgrounds[index]);
            _backgroundType = index;
        }
        else if (type < 0 && _backgroundType >= 0)
        {
            SetFrameSprite(null);
            _backgroundType = -1;
        }
    }

    public void UsePresetedFrames(int index)
    {
        if (_presetedFrames.Length == 0)
            Debug.LogWarning("[WorldHUDBadge] There is no preseted frames");
        else if (index >= 0 && index != _frameType)
        {
            SetFrameSprite(_presetedFrames[index]);
            _frameType = index;
        }
        else if (type < 0 && _frameType >= 0)
        {
            SetFrameSprite(null);
            _frameType = -1;
        }
    }

    public void UsePresetedIcons(int index)
    {
        if (_presetedIcons.Length == 0)
            Debug.LogWarning("[WorldHUDBadge] There is no preseted icons");
        else if (index >= 0 && index != _iconType)
        {
            SetIconSprite(_presetedIcons[index]);
            _iconType = index;
        }
        else if (type < 0 && _iconType >= 0)
        {
            SetIconSprite(null);
            _iconType = -1;
        }
    }

    public void UsePresetedMasks(int index)
    {
        if (_presetedMasks.Length == 0)
            Debug.LogWarning("[WorldHUDBadge] There is no preseted masks");
        else if (index >= 0 && index != _maskType)
        {
            SetMaskSprite(_presetedMasks[index]);
            _maskType = index;
        }
        else if (type < 0 && _iconType >= 0)
        {
            SetMaskSprite(null);
            _maskType = -1;
        }
    }

    private void SetBackgroundSprite(Sprite sprite)
    {
        _uiBackground.sprite = sprite;
        _uiMask.transform.localScale = sprite ? Vector3.one : Vector3.zero;
    }

    private void SetFrameSprite(Sprite sprite)
    {
        _uiFrame.sprite = sprite;
        _uiFrame.transform.localScale = sprite ? Vector3.one : Vector3.zero;
    }

    private void SetIconSprite(Sprite sprite)
    {
        _uiIcon.sprite = sprite;
        _uiIcon.transform.localScale = sprite ? Vector3.one : Vector3.zero;
    }

    private void SetMaskSprite(Sprite sprite)
    {
        _uiMask.sprite = sprite;
    }
}
