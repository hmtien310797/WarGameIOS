using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;

public class CheckUIAtlas : EditorWindow 
{
	private static CheckUIAtlas window = null;

	private bool 			mIsChecking = false;

    private Dictionary<string, List<string>> mAtlas = new Dictionary<string, List<string>>();
    private Vector2 mScroll2;
	private Vector2			mScroll;

	[MenuItem ("Tools/Check UI Atlas")]
	static void CreateWindow()
	{
		if (window != null)
		{
			window.Close();
		}
		else
		{
			window = (CheckUIAtlas)EditorWindow.GetWindow (typeof (CheckUIAtlas));
			window.titleContent.text = "Check";
			window.minSize = new Vector2(800, 600);
			window.Init();
			window.Show();
			window.ShowUtility();	
		}
	}

	void Init()
	{

	}

	void OnInspectorUpdate()
	{
		this.Repaint ();
	}

	void OnGUI()
	{
		GUILayout.BeginArea (new Rect (0, 0, 800, 600));

		GUILayout.Space (10);

		GUILayout.BeginHorizontal();

		if (Selection.activeGameObject == null) 
		{
			GUILayout.Label ("Select Object!", GUILayout.Width (80));
		}
		else
		{
			if (mIsChecking) 
			{
				GUILayout.Label ("Checking...", GUILayout.Width (80));
			}
			else
			{
				if (GUILayout.Button("Scan: " + Selection.activeGameObject.name, GUILayout.Width(200)))
				{
					StartScan();
				}
			}
		}

		GUILayout.EndHorizontal ();

		GUILayout.Space (20);

		mScroll = GUILayout.BeginScrollView (mScroll, GUILayout.Height(600));

        foreach (string name in mAtlas.Keys)
        {
            mScroll2 = Vector2.zero;

            GUILayout.Label(name, GUILayout.Width(100));

            GUILayout.BeginHorizontal();
            for (int i = 0; i < mAtlas[name].Count; i++)
            {
                EditorGUILayout.SelectableLabel(mAtlas[name][i], GUILayout.Width(100));
            }    
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
        }

        GUILayout.EndScrollView ();

		GUILayout.EndArea ();
	}

	void StartScan()
	{
		mIsChecking = true;

        foreach (string name in mAtlas.Keys)
        {
            mAtlas[name].Clear();
        }
        mAtlas.Clear ();
		mScroll = Vector2.zero;
	}

	void checkRecursive(string parentName, GameObject parentObject)
	{
		if (parentObject == null)
			return;

		string path = parentName + "/" + parentObject.name;

		foreach (Transform child in parentObject.transform) 
		{
            UISprite sprite = child.GetComponent<UISprite>();
            if (sprite != null)
            {
                if (!mAtlas.ContainsKey(sprite.atlas.name))
                {
                    List<string> atlasSprites = new List<string>();
                    mAtlas.Add(sprite.atlas.name, atlasSprites);
                }
                mAtlas[sprite.atlas.name].Add(path + "/" + sprite.name);
            }

			checkRecursive(path, child.gameObject);
		}
	}

	void Update()
	{
		if (!mIsChecking)
			return;

		checkRecursive ("", Selection.activeGameObject);
		mIsChecking = false;
	}
}
