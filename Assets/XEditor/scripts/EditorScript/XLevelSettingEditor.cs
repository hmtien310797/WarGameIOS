using UnityEngine;
using System.Collections;


#if UNITY_EDITOR
[ExecuteInEditMode]
public class XLevelSettingEditor : MonoBehaviour
{
    private XLevelDataXML mDataXml;

    public void Init(XLevelDataXML _data)
	{
        mDataXml = _data;
	}

    public XLevelDataXML data
	{
		get
		{
            return mDataXml;
		}
	}

	void OnValidate()  
	{
        
		if (!Application.isPlaying)
		{
#if UNITY_EDITOR
			XLevelGenerator lg = GameObject.FindObjectOfType<XLevelGenerator>();
			if (lg)
			{
				lg.Validate();
                mDataXml = XEditorManager.instance.CurLevelDataXml;
			}
#endif

			XEditorManager.instance.Validate();
		}
        
	}

	void OnDestroy()
	{
		if (!Application.isPlaying)
		{
			XEditorManager.instance.Destroy();
		}
	}

	  // cannot move
	void Update()
	{
		if (Application.isPlaying)
			return;

		Transform t = transform;
		if (t.hasChanged)
		{
			t.position = Vector3.zero;
			t.rotation = Quaternion.identity;
			t.localScale = Vector3.one;
			t.hasChanged = false;
		}
	}

	// Construct groups, elements, pathes by Hierarchy
	public void Reconstruct()
	{
		// locate the level data
        if (mDataXml == null)
		{
            mDataXml = XEditorManager.instance.CurLevelDataXml;
		}
		
		if (XEditorManager.instance.elementRoot)
		{
			XElementEditor[] elements = XEditorManager.instance.elementRoot.GetComponentsInChildren<XElementEditor>();
			for (int i=0; i<elements.Length; i++)
			{
				 //elements[i].Reconstruct();
			}
		}
        if(XEditorManager.instance.pathRoot)
        {
            XPathEditor[] paths = XEditorManager.instance.pathRoot.GetComponentsInChildren<XPathEditor>();
            for (int i = 0; i < paths.Length; i++)
            {
                paths[i].Reconstruct();
            }
        }

	}

	public string levelScene
	{
		get
		{
            return mDataXml.levelSceneName;
		}
		set
		{
            if (mDataXml.levelSceneName != value)
			{
                string lastname = mDataXml.levelSceneName;
                mDataXml.levelSceneName = value;
				XEditorManager.instance.EditorSwitchScene(lastname);
			}
		}
	}

	public void ResetRenderSetting()
	{
        mDataXml.ResetRender();
	}

}
#endif