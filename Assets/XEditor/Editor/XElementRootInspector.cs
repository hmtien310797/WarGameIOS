using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;
using System.Collections.Generic;

[CustomEditor(typeof(XElementRootHelper))]
public class XElementRootInspector : Editor {
	
	XElementRootHelper editor;
	GUIStyle style = new GUIStyle();

	void OnEnable()
	{
		editor = (XElementRootHelper)target;

		style.fontStyle = FontStyle.Bold;
		style.normal.textColor = Color.blue;
	}
	
	public override void OnInspectorGUI() 
	{
		if (Application.isPlaying)
		{
			base.OnInspectorGUI();
			return;
		}

        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;
		XElementData[] elements = levelData.elementsData;

		EditorGUILayout.BeginVertical();

		GUI.color = Color.yellow;
		
		GUILayout.Label("CANNOT create element, remove element from Unity3D control.");
		GUILayout.Label("Only do these behaviors from buttons below.");
		
		GUI.color = Color.white;
		
		GUILayout.Space(10);

		if (GUILayout.Button("Creat New Element"))
		{
			editor.InsertNewElementAt(elements.Length);
		}

		GUILayout.Space(10);
				
		for (int i=0; i<elements.Length; i++)
		{
			if (i % 2 == 0)
				GUI.color = new Color32(114,255,197,255);
			else
				GUI.color = Color.white;

			EditorGUILayout.BeginHorizontal();
			
			EditorGUILayout.LabelField(elements[i].uniqueId + "_" + elements[i].name, GUILayout.MaxWidth(120));
			
			if (GUILayout.Button("Add New", GUILayout.MaxWidth(120)))
			{
				editor.InsertNewElementAt(i+1);
			}
			
			if (GUILayout.Button("Clone", GUILayout.MaxWidth(120)))
			{
				editor.CloneElement(i);
			}
			
			if (GUILayout.Button("Remove", GUILayout.MaxWidth(120)))
			{
				if (EditorUtility.DisplayDialog("Warning!", "Are you sure to remove this element, this will influent all the groups and events using it?", "OK", "Cancel"))
				{
					editor.RemoveElement(i);
				}
			}

			EditorGUILayout.EndHorizontal();
			
			EditorGUILayout.Separator();
		}
		GUI.color = Color.white;
		
		EditorGUILayout.EndVertical();
	}
	
	void OnSceneGUI()
	{
		if (Application.isPlaying)
		{
			return;
		}

		List<XElementEditor> allelements = XEditorManager.instance.GetAllElements();
		
		for (int i=0; i<allelements.Count; i++)
		{
			Handles.Label(allelements[i].transform.position + new Vector3(0,1,0), allelements[i].name, style);
		}

		XLevelSettingInspector.ShowSavePanel(editor.name);
	}
}



