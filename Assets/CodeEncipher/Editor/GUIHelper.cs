using UnityEngine;
using UnityEditor;
using System.Collections;

public class GUIHelper
{
    private static Texture2D _gradientTexture;
    private static GUIStyle _foldOutStyle;
    private static Texture2D _texture;
    public static bool DrawTitleFoldOut(bool foldOut, string text)
    {
        if (_foldOutStyle == null)
        {
            _foldOutStyle = new GUIStyle(EditorStyles.foldout);
            _foldOutStyle.fontStyle = FontStyle.Bold;

            Color foldTextColor = Color.black;
            if (EditorGUIUtility.isProSkin)
            {
                foldTextColor = new Color(200f/255f, 200f/255f, 200f/255f);
            }

            _foldOutStyle.onActive.textColor = foldTextColor;
            _foldOutStyle.onFocused.textColor = foldTextColor;
            _foldOutStyle.onHover.textColor = foldTextColor;
            _foldOutStyle.onNormal.textColor = foldTextColor;
            _foldOutStyle.active.textColor = foldTextColor;
            _foldOutStyle.focused.textColor = foldTextColor;
            _foldOutStyle.hover.textColor = foldTextColor;
            _foldOutStyle.normal.textColor = foldTextColor;
        }
        Rect lastRect = DrawTitleGradient();
        GUI.color = Color.white;
        bool value = EditorGUI.Foldout(new Rect(lastRect.x + 10, lastRect.y + 1, lastRect.width - 5, lastRect.height), foldOut, text, _foldOutStyle);
        GUI.color = Color.white;

        return value;
    }

    public static Rect DrawTitleGradient()
    {
        GUILayout.Space(30);
        Rect lastRect = GUILayoutUtility.GetLastRect();
        lastRect.yMin = lastRect.yMin + 5;
        lastRect.yMax = lastRect.yMax - 5;
        lastRect.width = Screen.width;


        GUI.DrawTexture(new Rect(5, lastRect.yMin, Screen.width-10, lastRect.yMax - lastRect.yMin), GetGradientTexture());
        GUI.color = new Color(0.2f, 0.2f, 0.2f);
        GUI.DrawTexture(new Rect(5, lastRect.yMin, Screen.width-10, 1f), EditorGUIUtility.whiteTexture);
        GUI.DrawTexture(new Rect(5, lastRect.yMax - 1f, Screen.width-10, 1f), EditorGUIUtility.whiteTexture);

        return lastRect;
    }

    private static Texture2D GetGradientTexture()
    {

        if (_gradientTexture == null)
        {
            _gradientTexture = CreateGradientTexture();
        }
        return _gradientTexture;
    }

    private static Texture2D CreateGradientTexture()
    {
        if (_texture == null)
        {
            _texture = new Texture2D(1, 16);
            _texture.hideFlags = HideFlags.HideInInspector;
            _texture.filterMode = FilterMode.Trilinear;
            _texture.hideFlags = HideFlags.DontSave;
            float start = 0.3f;
            float end = 0.6f;
            float step = (end - start)/16;
            Color color = new Color(start, start, start);

            Color pixColor = color;
            for (int i = 0; i < 16; i++)
            {
                pixColor = new Color(pixColor.r + step, pixColor.b + step, pixColor.b + step, 0.5f);
                _texture.SetPixel(0, i, pixColor);
            }
            _texture.Apply();
        }
        return _texture;
    }
}
