#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEditor;
using System.IO;
using System.Text;
using UnityEngine;

public class LanguageFileCreator : EditorWindow
{
    public string NewLanguageCode { get; set; } = "VN"; // For creating new language files
    public string ReadLanguageCode { get; set; } = "VN"; // For decoding existing language files
    public string ModifyLanguage { get; set; } = "VN"; // For applying changes
    
    public TextAsset inputTextAsset;
    public bool UseTextAsset { get; set; } = false;

    [MenuItem("Tools/Private Tools/Create Language File")]
    static void Init()
    {
        var window = GetWindow<LanguageFileCreator>();
        window.Show();
    }

    void OnGUI()
    {
        // GUILayout.Label("Language File Tool", EditorStyles.boldLabel);
        //
        // NewLanguageCode = EditorGUILayout.TextField("New Language Code", NewLanguageCode);
        // if (GUILayout.Button("Create Language File"))
        // {
        //     CreateLanguageFile(NewLanguageCode);
        // }
        ReadLanguageCode = EditorGUILayout.TextField("Read Language Code", ReadLanguageCode);
        if (GUILayout.Button("Decode and Export to .txt"))
        {
            DecodeLanguageFile(ReadLanguageCode);
        }
        
        UseTextAsset = EditorGUILayout.Toggle("Use Text Asset To Encode", UseTextAsset);

        if (!UseTextAsset)
        {
            ModifyLanguage = EditorGUILayout.TextField("Apply Change To Root File", ModifyLanguage);
            if (GUILayout.Button("Apply changes to .bytes file"))
            {
                ApplyChangesToBytes(ModifyLanguage);
            }
        }
        else
        {
            ModifyLanguage = EditorGUILayout.TextField("Language To Encode", ModifyLanguage);
            inputTextAsset = (TextAsset)EditorGUILayout.ObjectField("Text Asset", inputTextAsset, typeof(TextAsset), false);
            if (GUILayout.Button("Apply changes to .bytes file using text asset"))
            {
                ApplyChangesToBytesUseTextAsset(ModifyLanguage);
            }
        }
        
    }

    void CreateLanguageFile(string languageCode)
    {
        string[] keys = File.ReadAllLines("Assets/Resources/dat/TEXT_HEAD.bytes");

        using (FileStream fs = new FileStream($"Assets/Resources/dat/{languageCode}.bytes", FileMode.Create))
        using (BinaryWriter bw = new BinaryWriter(fs, Encoding.Unicode))
        {
            bw.Write(keys.Length);

            foreach (string key in keys)
            {
                bw.Write("");
            }
        }

        AssetDatabase.Refresh();
        Debug.Log($"Created {languageCode}.bytes");
    }

    void DecodeLanguageFile(string languageCode)
    {
        string inputPath = $"Assets/Resources/dat/{languageCode}.bytes";
        string outputPath = $"Assets/Resources/{languageCode}_Decoded.txt";

        if (!File.Exists(inputPath))
        {
            Debug.LogError($"{inputPath} not found!");
            return;
        }

        try
        {
            List<string> decodedLines = new List<string>();
            TextAsset textAsset = Resources.Load<TextAsset>( $"dat/{languageCode}");
            MemoryStream ms = new MemoryStream(textAsset.bytes);
            using (BinaryReader br = new BinaryReader(ms, Encoding.Unicode))
            {
                int rowCount = br.ReadInt32();
                for (int i = 0; i < rowCount; i++)
                {
                    string line = br.ReadString();
                    decodedLines.Add(NormalizeLineEndings(line));
                }
            }

            File.WriteAllText(outputPath, string.Join("\n", decodedLines), Encoding.Unicode);

            AssetDatabase.Refresh();
            Debug.Log($"Successfully decoded to: {outputPath}");
        }
        catch (Exception e)
        {
            Debug.LogError($"Decoding failed: {e.Message}");
        }
    }

    void ApplyChangesToBytes(string languageCode)
    {
        string inputTxtPath = $"Assets/Resources/{languageCode}_Decoded.txt";
        string outputBytesPath = $"Assets/Resources/dat/{languageCode}.bytes";

        if (!File.Exists(inputTxtPath))
        {
            Debug.LogError($"{inputTxtPath} not found!");
            return;
        }

        try
        {
            string[] texts = File.ReadAllLines(inputTxtPath, Encoding.Unicode);

            using (FileStream fs = new FileStream(outputBytesPath, FileMode.Create))
            using (BinaryWriter bw = new BinaryWriter(fs, Encoding.Unicode))
            {
                bw.Write(texts.Length);
                foreach (string text in texts)
                {
                    bw.Write(text);
                }
            }

            AssetDatabase.Refresh();
            Debug.Log($"Applied changes to: {outputBytesPath}");
        }
        catch (Exception e)
        {
            Debug.LogError($"Applying changes failed: {e.Message}");
        }
    }
    
    void ApplyChangesToBytesUseTextAsset(string languageCode)
    {
        string outputBytesPath = $"Assets/Resources/dat/{languageCode}.bytes";

        if (inputTextAsset == null)
        {
            Debug.LogError("No TextAsset assigned! Drag a .txt file into the Text Asset field.");
            return;
        }

        try
        {
            string[] texts = inputTextAsset.text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None);

            using (FileStream fs = new FileStream(outputBytesPath, FileMode.Create))
            using (BinaryWriter bw = new BinaryWriter(fs, Encoding.Unicode))
            {
                bw.Write(texts.Length);
                foreach (string text in texts)
                {
                    bw.Write(text);
                }
            }

            AssetDatabase.Refresh();
            Debug.Log($"Applied changes to: {outputBytesPath}");
        }
        catch (Exception e)
        {
            Debug.LogError($"Applying changes failed: {e.Message}");
        }
    }

    string NormalizeLineEndings(string input)
    {
        return input.Replace("\r\n", " ").Replace("\n", " ").Replace("\r", " ");
    }
}
#endif
