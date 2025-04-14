using UnityEngine;
using System.Collections;

public class WorldHUDBubble : WorldHUDWidget
{
    public int currentType = -1;

    [SerializeField] private Sprite[] _presetedSprites;

    private UnityEngine.UI.Image _uiImage;

    private void Awake()
    {
        _uiImage = transform.GetChild(0).GetComponent<UnityEngine.UI.Image>();
    }

    override public int type
    {
        set
        {
            if (currentType != value)
            {
                currentType = value;

                if (value < 0)
                    Hide();
                else
                {
                    Show();

                    _uiImage.sprite = _presetedSprites[currentType];
                }
            }
        }
    }
}
