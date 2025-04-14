using UnityEngine;
using System.Collections;

public static class XResourceManager
{
	public static GameObject GetLevelObjectPrefab(string _name)
	{
		GameObject prefab = null;
        string nameWithPath = XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + "/" + _name;
		//if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
		//{
		//	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;	
		//}
		//else
		{
            prefab = Resources.Load(nameWithPath) as GameObject;
		}
		return prefab;
	}

	public static GameObject GetLevelObject(string _name)
	{
		GameObject result = null;
		GameObject prefab = GetLevelObjectPrefab (_name);

		if (prefab != null)
		{
			result = Object.Instantiate(prefab) as GameObject;
			result.name = _name;
            //add astar component 
            /*
            if (result.GetComponentInChildren<AstarPath>() == null)
            {
                Debug.LogError("create astart pathfinding");
                GameObject astarObj = new GameObject("A*");
                astarObj.AddComponent<AstarPath>();
                astarObj.transform.SetParent(result.transform);
            }
             * */
		}
		return result;
	}

	public static GameObject GetLevelScenePrefab(string _name)
	{
		GameObject prefab = null;
        string nameWithPath = XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + XLevelDefine.SCENE_PATH + _name;
		//if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
		//{
		//	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;	
		//}
		//else
		{
			prefab = Resources.Load(nameWithPath) as GameObject;
		}
		return prefab;
	}

	public static GameObject GetLevelScene(string _name)
	{
		GameObject result = null;
		GameObject prefab = GetLevelScenePrefab (_name);

		if (prefab != null)
		{
			result = Object.Instantiate(prefab) as GameObject;
			result.name = _name;
		}
		return result;
	}

	public static GameObject GetLevelCameraInstance(string _name, Vector3 _pos, Quaternion _rotation)
	{
		GameObject result = null;
		GameObject prefab = null;
        string nameWithPath = XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + XLevelDefine.LEVEL_CAMERA_PATH + _name;
		//if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
		//{
		//	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;		
		//}
		//else
		{
			prefab = Resources.Load(nameWithPath) as GameObject;
		}

		if (prefab != null)
			result = Object.Instantiate(prefab, _pos, _rotation) as GameObject;
		return result;
	}

	public static GameObject GetLevelSimpleObjectInstance(string _name, Vector3 _pos, Quaternion _rotation)
	{
		GameObject result = null;
		GameObject prefab = null;
        string nameWithPath = XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + XLevelDefine.LEVEL_OBJECT_PATH + _name;
		//if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
		//{
		//	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;	
		//}
		//else
		{
			prefab = Resources.Load(nameWithPath) as GameObject;
		}

		if (prefab != null)
			result = Object.Instantiate(prefab, _pos, _rotation) as GameObject;
		return result;
	}
    public static GameObject GetLevelSimpleObjectPrefab(string _name)
    {
        return null;
/*
        GameObject result = null;
        GameObject prefab = null;
        
        string nameWithPath = XLevelDefine.ART_RESOURCE_DATABASE_PATH + XLevelDefine.ART_RESOURCE_OBJS_PATH + _name;
        prefab = (GameObject)AssetDatabase.LoadAssetAtPath(nameWithPath, typeof(GameObject));

        if (prefab != null)
            result = Object.Instantiate(prefab) as GameObject;
        return result;
 */
    }
    public static GameObject GetLevelObjectInstance(string _name, XLevelDefine.ElementType objType , Vector3 _pos, Quaternion _rotation)
    {
        GameObject result = null;
        GameObject prefab = null;
        string subpath = string.Empty;

        switch(objType)
        {
            
            case XLevelDefine.ElementType.Defense:
                subpath = XLevelDefine.ASSET_LEVELOBJECT_DEFENSES_PATH;
                break;

        }


        string nameWithPath = XLevelDefine.ASSET_LEVELOBJECT_PATH + subpath + _name;
        //if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
        //{
        //	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;	
        //}
        //else
        {
            prefab = Resources.Load(nameWithPath) as GameObject;
        }

        if (prefab != null)
            result = Object.Instantiate(prefab, _pos, _rotation) as GameObject;
        return result;
    }
    public static GameObject GetLevelObjectModule(string _name)
    {
        return null;
/*
        GameObject result = null;
        GameObject prefab = null;
        string subpath = string.Empty;

        string nameWithPath = XLevelDefine.ART_RESOURCE_DATABASE_PATH + XLevelDefine.ART_RESOURCE_UNITS_PATH + _name + ".prefab";

        prefab = (GameObject)AssetDatabase.LoadAssetAtPath(nameWithPath, typeof(GameObject));
        if (prefab != null)
            result = Object.Instantiate(prefab) as GameObject;
        return result;
*/
    }
	public static GameObject GetEffectInstance(string _name, Vector3 _pos, Quaternion _rotation)
	{
		GameObject result = null;
		GameObject prefab = null;
		string nameWithPath = XLevelDefine.LEVEL_EFFECT_PATH + _name;
		//if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
		//{
		//	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;	
		//}
		//else
		{
			prefab = Resources.Load(nameWithPath) as GameObject;
		}

		if (prefab != null)
			result = Object.Instantiate(prefab, _pos, _rotation) as GameObject;
		return result;
	}

	public static AudioClip GetLevelSound(string _name)
	{
		//return ResourceLibrary.instance.GetLevelSound (_name);
        return null;
	}

	public static AudioClip GetVox(string _name)
	{
		//return ResourceLibrary.instance.GetSound (InuResources.PATH_VOX, _name);
        return null;
	}

	public static AudioClip GetLevelMusic(string _name)
	{
		//return ResourceLibrary.instance.GetSound (InuResources.PATH_BGM, _name);
        return null;
	}

	public static GameObject GetTeamInstance(string _name, Vector3 _pos, Quaternion _rotation)
	{
		GameObject result = null;
		GameObject prefab = null;
		string nameWithPath = XLevelDefine.LEVEL_TEAM_PATH + _name;
		//if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
		//{
		//	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;
		//}
		//else
		{
			prefab = Resources.Load(nameWithPath) as GameObject;
		}

		if (prefab != null)
			result = Object.Instantiate(prefab, _pos, _rotation) as GameObject;
		return result;
	}

	public static GameObject GetMonsterGroupInstance(string _name, Vector3 _pos, Quaternion _rotation)
	{
		GameObject result = null;
		GameObject prefab = null;
		string nameWithPath = XLevelDefine.LEVEL_WAVE_PATH + _name;
		//if (AssetBundleConfig.Instance.IsAssetbundleFile (nameWithPath)) 
		//{
		//	prefab = ResourceLibrary.instance.Load(nameWithPath) as GameObject;	
		//}
		//else
		{
			prefab = Resources.Load(nameWithPath) as GameObject;
		}

		if (prefab != null)
			result = Object.Instantiate(prefab, _pos, _rotation) as GameObject;
		return result;
	}

	public static Texture GetFadeTexture()
	{
		Texture tex = Resources.Load(XLevelDefine.LEVEL_TEXTURE_PATH + "COLOR_Black") as Texture;
		return tex;
	}
}
