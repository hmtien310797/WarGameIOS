using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;

[CustomEditor(typeof(XPathRootHelper))]
public class XpathRootInspector : Editor {
	
	XPathRootHelper editor;
	GUIStyle style = new GUIStyle();

	void OnEnable()
	{
		editor = (XPathRootHelper)target;

		style.fontStyle = FontStyle.Bold;
		style.normal.textColor = Color.magenta;
	}
	
	public override void OnInspectorGUI() 
	{
		if (Application.isPlaying)
		{
			base.OnInspectorGUI();
			return;
		}

        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;
        XPathPointData[] pathes = levelData.pathesData;

		EditorGUILayout.BeginVertical();

		GUI.color = Color.yellow;
		
		GUILayout.Label("CANNOT create path, remove path from Unity3D control.");
		GUILayout.Label("Only do these behaviors from buttons below.");
		
		GUI.color = Color.white;

		GUILayout.Space(10);

		if (GUILayout.Button("Creat New Path"))
		{
			editor.InsertNewPathAt(pathes.Length);
		}
        GUILayout.Space(10);

        if (GUILayout.Button("Apply Path Point"))
        {
            editor.BuildPathEditor();
            //XEditorManager.instance.InitPathes();
        }
		GUILayout.Space(10);
				
		for (int i=0; i<pathes.Length; i++)
		{
			if (i % 2 == 0)
				GUI.color = new Color32(114,255,197,255);
			else
				GUI.color = Color.white;

			EditorGUILayout.BeginHorizontal();
			
			EditorGUILayout.LabelField(pathes[i].uniqueId + XLevelDefine.LEVEL_PATH_NAME, GUILayout.MaxWidth(120));
			
			if (GUILayout.Button("Add New", GUILayout.MaxWidth(120)))
			{
				editor.InsertNewPathAt(i+1);
			}
			
			if (GUILayout.Button("Clone", GUILayout.MaxWidth(120)))
			{
				editor.ClonePath(i);
			}
			
			if (GUILayout.Button("Remove", GUILayout.MaxWidth(120)))
			{
				editor.RemovePath(i);
			}
			
			EditorGUILayout.EndHorizontal();
			
			EditorGUILayout.Separator();
		}
		
		EditorGUILayout.EndVertical();
	}
	
	void OnSceneGUI()
	{
		if (Application.isPlaying)
		{
			return;
		}

        /*
		List<XPathEditor> allpathes = XEditorManager.instance.GetAllPathes();
		
		for (int i=0; i<allpathes.Count; i++)
		{
			Handles.Label(allpathes[i].data.pathPoints[0], allpathes[i].data.uniqueId + XLevelDefine.LEVEL_PATH_NAME, style);
		}

		XLevelSettingInspector.ShowSavePanel(editor.name);
         * */
	}
}




