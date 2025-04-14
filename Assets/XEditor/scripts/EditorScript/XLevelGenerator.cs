using UnityEngine;
using System.Collections;
using System.Collections.Generic;
//using System.IO;

#if UNITY_EDITOR

public class XLevelGenerator : MonoBehaviour 
{
	public string chapterName;
	public string chapterId;

    public string leveId;
    public string levelName;
	public string levelSceneName;
	private GameObject levelObj;
   
	public void Validate()
	{
        XLevelDefine.Chapter_Path = chapterName;   
        XLevelDefine.Chapter_Scene = levelSceneName;
        XEditorManager.instance.Destroy();  

        string fileName = XLevelDefine.ASSET_RESOURCE_PATH + XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + "/dat/" + XLevelDefine.Chapter_Scene + ".xml";
        if (ResourceLibrary.IsExistFile(fileName))
        {
            XEditorManager.instance.LoadLevelFromXml(XLevelDefine.Chapter_Scene, false);
            XEditorManager.instance.InitRoot();
        }
        else
        {
            XEditorManager.instance.GenerateLevel(XLevelDefine.Chapter_Path, XLevelDefine.Chapter_Scene);
            return;
        }

		

	}

	void SwitchLevel()
	{
		levelObj = XResourceManager.GetLevelObject(levelSceneName);
		if (levelObj)
		{
			XEditorManager.instance.LoadLevel(levelObj.GetComponent<XLevelData>());
		}
	}
    public void GenerateLevel(string _scene)
    {
        levelSceneName = _scene;

        // clear all useless elements when launching editor
        if (GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME))
        {
            DestroyImmediate(GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME));
        }

        levelObj = XEditorManager.instance.GenerateLevel(chapterName, levelSceneName);
    }
	public void LoadLevel(string _scene)
	{
		XLevelDefine.Chapter_Path = chapterId;

		levelSceneName = _scene;

		// clear all useless elements when launching editor
		if (GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME))
		{
			DestroyImmediate(GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME));
		}

		if (GameObject.FindObjectOfType<XLevelData>())
		{
			DestroyImmediate(GameObject.FindObjectOfType<XLevelData>().gameObject);
		}

     

		SwitchLevel();
	}

	public void ReloadExcel(string _scene)
	{



		if (levelSceneName != _scene 
		    || !GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME)
		    || !GameObject.FindObjectOfType<XLevelData>())
		{
			levelSceneName = _scene;

			// clear all useless elements when launching editor
			if (GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME))
			{
				DestroyImmediate(GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME));
			}
			
			if (GameObject.FindObjectOfType<XLevelData>())
			{
				DestroyImmediate(GameObject.FindObjectOfType<XLevelData>().gameObject);
			}

			SwitchLevel();
		}
	}

	
}

#endif
