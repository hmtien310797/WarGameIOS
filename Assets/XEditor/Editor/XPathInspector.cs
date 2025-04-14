using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

[CustomEditor(typeof(XPathEditor))]
public class XPathInspector : Editor {

	XPathEditor editor;
	GUIStyle style = new GUIStyle();

	void OnEnable()
	{
		editor = (XPathEditor)target;
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

		//GUI.color = Color.magenta;
		GUI.changed = false;

         EditorGUILayout.BeginVertical();

		GUILayout.Space(10);

        EditorGUILayout.LabelField("UID: " + editor.data.uniqueId);

        GUILayout.Space(10);
        EditorGUILayout.LabelField("Team: ", GUILayout.MaxWidth(120));
        editor.data.team = EditorGUILayout.IntField(editor.data.team, GUILayout.MaxWidth(120));

        
        GUILayout.Space(10);
        EditorGUILayout.LabelField("Group: ", GUILayout.MaxWidth(120));
        editor.data.pathGroup = EditorGUILayout.IntField(editor.data.pathGroup, GUILayout.MaxWidth(120));

        EditorGUILayout.Separator();
        if (GUILayout.Button("apply", GUILayout.MaxWidth(120)))
        {
            editor.apply();
        }
       

        EditorGUILayout.EndVertical();

	}

	void OnSceneGUI()
	{
		if (Application.isPlaying)
		{
			return;
		}
	}


	
}


