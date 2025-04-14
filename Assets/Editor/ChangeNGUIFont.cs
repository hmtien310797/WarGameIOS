using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class ChangeNGUIFont : EditorWindow
{
    private Font[] availableFonts;
    private string[] fontNames;
    private int selectedFontIndex = 0;
    private string uiPrefabPath = "Assets/UI/Resources/Prefabs";
    private string hudPrefabPath = "Assets";

    [MenuItem("Tools/Private Tools/Change All NGUI Font in Prefabs")]
    static void OpenWindow()
    {
        GetWindow<ChangeNGUIFont>("Change NGUI Font");
    }

    private void OnEnable()
    {
        LoadAvailableFonts();
    }

    void LoadAvailableFonts()
    {
        string[] fontGUIDs = AssetDatabase.FindAssets("t:Font"); // Tìm tất cả font .ttf và .otf
        availableFonts = fontGUIDs
            .Select(guid => AssetDatabase.LoadAssetAtPath<Font>(AssetDatabase.GUIDToAssetPath(guid)))
            .Where(font => font != null)
            .ToArray();

        fontNames = availableFonts.Select(font => font.name).ToArray();
    }

    void OnGUI()
    {
        GUILayout.Label("Select New Font for NGUI Labels", EditorStyles.boldLabel);

        if (availableFonts.Length == 0)
        {
            EditorGUILayout.HelpBox("No NGUI Fonts found in the project!", MessageType.Warning);
            return;
        }

        selectedFontIndex = EditorGUILayout.Popup("Select Font:", selectedFontIndex, fontNames);

        if (GUILayout.Button("Change Font in All UI Prefabs"))
        {
            ChangeFontInAllUIPrefabs();
        }
        
        if (GUILayout.Button("Change Font in All HUD Prefabs"))
        {
            ChangeFontInAllHUDPrefabs();
        }
    }

    void ChangeFontInAllUIPrefabs()
    {
        if (availableFonts.Length == 0 || selectedFontIndex >= availableFonts.Length)
        {
            Debug.LogError("Invalid font selection.");
            return;
        }

        Font newFont = availableFonts[selectedFontIndex];

        string[] prefabPaths = Directory.GetFiles(uiPrefabPath, "*.prefab", SearchOption.AllDirectories);

        foreach (string path in prefabPaths)
        {
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab != null)
            {
                UILabel[] labels = prefab.GetComponentsInChildren<UILabel>(true);
                bool changed = false;

                foreach (UILabel label in labels)
                {
                    if (label.bitmapFont != newFont)
                    {
                        label.bitmapFont = null;
                        label.trueTypeFont = newFont;
                        label.ambigiousFont = newFont;
                        changed = true;
                    }
                }

                if (changed)
                {
                    EditorUtility.SetDirty(prefab);
                    Debug.Log($"Updated font in: {path}");
                }
            }
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    void ChangeFontInAllHUDPrefabs()
    {
        if (availableFonts.Length == 0 || selectedFontIndex >= availableFonts.Length)
        {
            Debug.LogError("Invalid font selection.");
            return;
        }

        Font newFont = availableFonts[selectedFontIndex];

        string[] prefabPaths = Directory.GetFiles(hudPrefabPath, "*.prefab", SearchOption.AllDirectories);

        foreach (string path in prefabPaths)
        {
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab != null)
            {
                UnityEngine.UI.Text[] labels = prefab.GetComponentsInChildren<UnityEngine.UI.Text>(true);
                bool changed = false;

                foreach (UnityEngine.UI.Text label in labels)
                {
                    label.font = newFont;
                    changed = true;
                }

                if (changed)
                {
                    EditorUtility.SetDirty(prefab);
                    Debug.Log($"Updated font in: {path}");
                }
            }
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}