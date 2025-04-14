using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

[CustomEditor(typeof(XLevelSettingEditor))]
public class XLevelSettingInspector : Editor {
	
	XLevelSettingEditor editor;
	string[] allSceneNames;

	void OnEnable()
	{
		editor = (XLevelSettingEditor)target;  


		if (Application.isPlaying)
		{
			return;
		}

        string scenePath = XLevelDefine.ASSET_RESOURCE_PATH + XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + XLevelDefine.SCENE_PATH;
		DirectoryInfo dir = new DirectoryInfo(scenePath);
		FileInfo[] info = dir.GetFiles("*.prefab");
		  allSceneNames = new string[info.Length];
		for (int i=0; i<info.Length; i++)
		{ 
			allSceneNames[i] = info[i].Name.Substring(0, info[i].Name.Length - 7);
		}
	}
	
	public override void OnInspectorGUI() 
	{
		GUI.changed = false;
        /*
		editor.data.ambientLight = EditorGUILayout.ColorField("Ambient Light:", editor.data.ambientLight);
		editor.data.enableFog = EditorGUILayout.Toggle("Enable Fog:", editor.data.enableFog);
		editor.data.fogColor = EditorGUILayout.ColorField("Fog Color:", editor.data.fogColor);
		editor.data.fogMode = (FogMode)EditorGUILayout.EnumPopup("Fog Mode:", editor.data.fogMode);
		editor.data.fogDesity = EditorGUILayout.FloatField("Fog Destiny:", editor.data.fogDesity);
		editor.data.fogStart = EditorGUILayout.FloatField("Linear Fog Start:", editor.data.fogStart);
		editor.data.fogEnd = EditorGUILayout.FloatField("Linear Fog End:", editor.data.fogEnd);  
		*/
		if (GUI.changed)
		{
			GUI.changed = false;
			editor.ResetRenderSetting();
		}

		if (Application.isPlaying)
		{
			return;
		}

		EditorGUILayout.BeginVertical();
		
		int prevSel = 0;
		for (int i=0; i<allSceneNames.Length; i++)
		{
			if (allSceneNames[i] == editor.levelScene)
			{
				prevSel = i;
				break;
			}
		}

		GUI.color = Color.green;
		int curSel = EditorGUILayout.Popup("Scene:", prevSel, allSceneNames);
		editor.levelScene = allSceneNames[curSel];
		GUI.color = Color.white;

		EditorGUILayout.EndVertical();
	}

	void OnSceneGUI()
	{
		if (Application.isPlaying)
		{
			return;
		}

		ShowSavePanel(editor.name);
	}

	public static void ShowSavePanel(string _name)
	{
		/*Handles.BeginGUI();
		
		GUILayout.BeginArea(new Rect(Screen.width - 100, Screen.height - 100, 100, 100));
		GUI.Box(new Rect(0, 0, 100, 100), string.Empty);
		GUI.color = new Color32(255,198,112,255);
		if (GUI.Button(new Rect(10,10,80,40), "Save"))
		{
			XGroupInspector.Save();
		}
		GUI.color = Color.white;
		GUILayout.EndArea();
		
		Handles.EndGUI();*/

		GUI.Window(0, new Rect(Screen.width - 200, Screen.height - 200, 200, 200), DrawWindow, _name);
	}

	static void DrawWindow(int _id)
	{
		GUI.color = new Color32(255,198,112,255);
		if (GUI.Button(new Rect(10, 140, 80, 30), "Save"))
		{
			//XGroupInspector.Save();
            XEditorManager.Save();
            XEditorManager.instance.SaveLevelToXml();
		}
		GUI.color = Color.white;
	}

}

