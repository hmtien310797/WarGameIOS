using UnityEngine;
using System.Collections;

public class WorldHUDBar : WorldHUDWidget
{
    private float currentPercentage = -1;

    public override float percentage
    {
        set
        {
            if (currentPercentage != value)
            {
                if (value < 0 || value >= 1)
                    Hide();
                else
                {
                    Show();

                    value = Mathf.Max(0, Mathf.Min(value, 1));
                    transform.GetChild(0).GetComponent<RectTransform>().sizeDelta = new Vector2(100 * value + 8, 8);
                }
            }
        }
    }
}
