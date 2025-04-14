using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Reflection;
using System;

[CanEditMultipleObjects]
[CustomEditor(typeof(LocalizeEx), true)]
public class LocalizeExEditor : Editor 
{
	private TextManager.LANGUAGE mLanguage;
	private Dictionary<string, int> mLocalize;

	//private bool mInited = false;

	void OnEnable ()
	{
		mLanguage = TextManager.LANGUAGE.VN;
		//TextManager.Instance.LoadLanguage (mLanguage);
		mLocalize = TextManager.Instance.GetTextHeader ();
	}

	public override void OnInspectorGUI ()
	{

//		if (!mInited) 
//		{
//			OnInit();
//			mInited = true;		
//		}

		serializedObject.Update();

		GUILayout.Space(6f);
		NGUIEditorTools.SetLabelWidth(80f);

		GUILayout.BeginHorizontal();

		SerializedProperty sp = serializedObject.FindProperty("key");
		if (sp != null) 
		{
			EditorGUILayout.PropertyField(sp, new GUIContent("Key"));
			string myKey = sp.stringValue;
			bool isPresent = (mLocalize != null) && mLocalize.ContainsKey(myKey);

			GUILayout.BeginVertical(GUILayout.Width(22f));
			GUI.color = isPresent ? Color.green : Color.red;

			GUILayout.Space(2f);
#if UNITY_3_5
			GUILayout.Label(isPresent? "ok" : "!!", GUILayout.Height(20f));
#else
			GUILayout.Label(isPresent? "\u2714" : "\u2718", "TL SelectionButtonNew", GUILayout.Height(20f));
#endif
			GUI.color = Color.white;
			GUILayout.EndVertical();

			if (!isPresent)
			{
				GUILayout.BeginHorizontal();
				GUILayout.Space(80f);
				GUILayout.BeginVertical();
				GUI.backgroundColor = new Color(1f, 1f, 1f, 0.35f);

				int matches = 0;

				foreach(string key in mLocalize.Keys)
				{
					if (key.StartsWith(myKey, System.StringComparison.OrdinalIgnoreCase) || key.Contains(myKey))
					{
					#if UNITY_3_5
						if (GUILayout.Button(key + " \u25B2"))
					#else
						if (GUILayout.Button(key + " \u25B2", "CN CountBadge"))
					#endif
						{
							sp.stringValue = key;
							GUIUtility.hotControl = 0;
							GUIUtility.keyboardControl = 0;
						}
						
						if (++matches == 8)
						{
							GUILayout.Label("...and more");
							break;
						}
					}
				}
				GUI.backgroundColor = Color.white;
				GUILayout.EndVertical();
				GUILayout.Space(22f);
				GUILayout.EndHorizontal();
			}
		}

		GUILayout.EndHorizontal();


		serializedObject.ApplyModifiedProperties();
	}
}
