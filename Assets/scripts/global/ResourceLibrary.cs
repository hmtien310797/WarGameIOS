using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using LuaInterface;

public class ResourceLibrary
{
    public static readonly string PREFAB_SUFFIX = ".prefab";
    public static readonly string DAT_SUFFIX = ".bytes";

    public static readonly string ASSET_PATH_UNIT_MODEL = "Assets/Art/Prefabs/Unit/";
    public static readonly string ASSET_PATH_HERO_MODEL = "Assets/Art/Prefabs/Unit/";

    public static readonly string ASSET_PATH_LEVEL = "level/";
    public static readonly string ASSET_PATH_LEVEL_SCENES = "/scene/";
    public static readonly string ASSET_PATH_LEVEL_DATA = "/dat/";
    public static readonly string ASSET_PATH_LEVEL_ANIMATOR = "animator/";
    public static readonly string ASSET_PATH_LEVEL_ANIMATION = "/animation/";
    public static readonly string ASSET_PATH_SOUND_PREFAB = "sound/prefab/";

    public static readonly string ASSET_PATH_SLGPVP_REPORT = "SLGPVP/";

    public static readonly string ASSET_PATH_EFFECT = "effect/";

    public static readonly string ASSET_LEVELOBJECT_PATH = "obj/";
    public static readonly string ASSET_LEVELOBJECT_UNITS_PATH = "units/";
    public static readonly string ASSET_LEVELOBJECT_CONSTRUCTS_PATH = "constructs/";
    public static readonly string ASSET_LEVELOBJECT_DEFENSES_PATH = "defense/";

    public static readonly string ASSET_PATH_MAIN_CITY = "maincity/";

    public static readonly string ASSET_PATH_GLOBE_SCENE = "GlobeScene/";

    public static readonly string ASSET_PATH_MAIN_CITY_ANIMATION = "animation/";

    public static readonly string ASSET_PATH_MAP = "map/";

    public static readonly string ASSET_PATH_LOGIN = "loginscene/";

    public static readonly string ASSET_PATH_CONSTRUCTION = "construction/";

    public static readonly string ASSET_PATH_WorldTerrain = "WorldTerrain/";

    public static readonly string ASSET_PATH_CONSTRUCTIONSHOW = "constructionshow/";

    static ResourceLibrary sInstance;

    public static ResourceLibrary instance
    {
        get
        {
            if (sInstance == null)
                sInstance = new ResourceLibrary();
            return sInstance;
        }
    }

    public void Clear()
    {

    }
    public static bool IsExistFile(string file)
    {
        if (!File.Exists(file))
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    public byte[] GetLevelSceneAstarData(string _chapter, string data)
    {
        TextAsset text = null;
        string nameWithPath = ASSET_PATH_LEVEL + _chapter + ASSET_PATH_LEVEL_SCENES + data;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            text = AssetBundleManager.Instance.LoadAsset<TextAsset>(nameWithPath);
        }
        if (text == null)
        {
            text = Resources.Load(nameWithPath) as TextAsset;
        }
        if (text != null)
        {
            return text.bytes;
        }
        return null;
    }

    public TextAsset GetEventData(string _chapterName, string _eventName)
    {
        TextAsset text = null;
        string path = ASSET_PATH_LEVEL + _chapterName + ASSET_PATH_LEVEL_DATA + _eventName;
        //RecordUsed(path);
        if (AssetBundleManager.Instance)
        {
            text = AssetBundleManager.Instance.LoadAsset<TextAsset>(path);
        }
        if (text == null)
        {
            text = Resources.Load(path) as TextAsset;
        }
        return text;
    }

    public TextAsset GetLevelData(string _chapterName, string _levelName)
    {
        TextAsset text = null;
        string levelPath = ASSET_PATH_LEVEL + _chapterName + ASSET_PATH_LEVEL_DATA + _levelName;
        //RecordUsed(levelPath);
        if (AssetBundleManager.Instance)
        {
            text = AssetBundleManager.Instance.LoadAsset<TextAsset>(levelPath);
        }
        if (text == null)
        {
            text = Resources.Load(levelPath) as TextAsset;
        }
        return text;
    }

    public TextAsset GetSLGPVPReportData(string _reportName)
    {
        TextAsset text = null;
        string path = ASSET_PATH_SLGPVP_REPORT + _reportName;
        //RecordUsed(path);
        if (AssetBundleManager.Instance)
        {
            text = AssetBundleManager.Instance.LoadAsset<TextAsset>(path);
        }
        if (text == null)
        {
            text = Resources.Load(path) as TextAsset;
        }
        return text;
    }

    [LuaByteBufferAttribute]
    public byte[] GetSLGPVPReportBytes(string _reportName)
    {
        var reportData = GetSLGPVPReportData(_reportName);
        if (reportData != null)
        {
            return reportData.bytes;
        }
        return null;
    }

    public AnimationClip GetLevelAnimationClipInstance(string _chapterName, string _clipName)
    {
        AnimationClip clip = null;
        string path = ASSET_PATH_LEVEL + _chapterName + ASSET_PATH_LEVEL_ANIMATION + _clipName;
        //RecordUsed(path);
        if (AssetBundleManager.Instance)
        {
            clip = AssetBundleManager.Instance.LoadAsset<AnimationClip>(path);
        }
        if (clip == null)
        {
            clip = Resources.Load<AnimationClip>(path);
        }
        return clip;
    }
    public RuntimeAnimatorController GetLevelAnimatorControllerInstance(string _controllerName)
    {
        Object controller = null;
        string path = ASSET_PATH_LEVEL + ASSET_PATH_LEVEL_ANIMATOR + _controllerName;
        //RecordUsed(path);
        if (AssetBundleManager.Instance)
        {
            controller = AssetBundleManager.Instance.LoadAsset<Object>(path);
        }
        if (controller == null)
        {
            controller = Resources.Load<Object>(path);
        }
        return controller as RuntimeAnimatorController;
    }

    public GameObject GetUnitSfxPrefab(string prefile)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_SOUND_PREFAB + prefile;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetLevelSceneInstanse(string _chapter, string _scene)
    {
        GameObject result = null;
        GameObject prefab = GetLevelScenePrefab(_chapter, _scene);
        if (prefab != null)
        {
            result = Object.Instantiate(prefab) as GameObject;
            result.name = _scene;
        }
        return result;
    }

    public GameObject GetLevelScenePrefab(string _chapter, string _scene)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_LEVEL + _chapter + ASSET_PATH_LEVEL_SCENES + _scene;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetLevelUnitInstance(string _name, XLevelDefine.ElementType uType, Vector3 _pos, Quaternion _rotation)
    {
        GameObject prefab = GetLevelUnitPrefab(_name);
        if (prefab != null)
        {
            return Object.Instantiate(prefab) as GameObject;
        }
        else
        {
            return null;
        }
    }

    public GameObject GetLevelUnitInstanceFromPool(string _name, XLevelDefine.ElementType uType, Vector3 _pos, Quaternion _rotation)
    {
        string nameWithPath = ASSET_LEVELOBJECT_PATH + ASSET_LEVELOBJECT_UNITS_PATH + _name;
        //RecordUsed(nameWithPath);
        GameObject obj = null;
        if (!Clishow.CsObjPoolMgr.Instance.IsContainPool(nameWithPath))
        {
            if (AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
            }
            if (obj == null)
            {
                obj = Resources.Load(nameWithPath) as GameObject;
            }
            Clishow.CsObjPoolMgr.Instance.NewPool(obj, nameWithPath);
        }
        obj = Clishow.CsObjPoolMgr.Instance.Instantiate(nameWithPath);
        return obj;
    }

    public GameObject GetLevelUnitInstanceFromPool(string _name, int uType)
    {

        return GetLevelUnitInstanceFromPool(_name, (XLevelDefine.ElementType)uType, Vector3.zero, Quaternion.identity);
    }

    public GameObject GetLevelUnitPrefab(string _name)
    {
        GameObject go = null;
        string nameWithPath = ASSET_LEVELOBJECT_PATH + ASSET_LEVELOBJECT_UNITS_PATH + _name;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetLevelObjectInstance(string _name)
    {
        GameObject result = null;
        GameObject prefab = null;

        prefab = GetLevelObjectPrefab(_name);
        if (prefab != null)
            result = Object.Instantiate(prefab) as GameObject;
        return result;
    }

    public GameObject GetLevelObjectInstanceFromPool(string _name, XLevelDefine.ElementType uType, Vector3 _pos, Quaternion _rotation)
    {
        string subpath = string.Empty;

        subpath = ASSET_LEVELOBJECT_DEFENSES_PATH;
        string nameWithPath = ASSET_LEVELOBJECT_PATH + subpath + _name;
        //RecordUsed(nameWithPath);
        GameObject obj = null;
        if (!Clishow.CsObjPoolMgr.Instance.IsContainPool(nameWithPath))
        {
            if (AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
            }
            if (obj == null)
            {
                obj = Resources.Load(nameWithPath) as GameObject;
            }
            Clishow.CsObjPoolMgr.Instance.NewPool(obj, nameWithPath);
        }
        obj = Clishow.CsObjPoolMgr.Instance.Instantiate(nameWithPath);
        return obj;
    }

    public bool CacheLevelObject(string _name, int count = 0)
    {
        string subpath = string.Empty;

        subpath = ASSET_LEVELOBJECT_UNITS_PATH;
        string nameWithPath = ASSET_LEVELOBJECT_PATH + subpath + _name;
        //RecordUsed(nameWithPath);
        GameObject obj = null;
        if (!Clishow.CsObjPoolMgr.Instance.IsContainPool(nameWithPath))
        {
            if (AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
            }
            if (obj == null)
            {
                obj = Resources.Load(nameWithPath) as GameObject;
            }
            if (obj == null)
            {
                return false;
            }
            Clishow.CsUnit unit = obj.GetComponent<Clishow.CsUnit>();
            if (unit != null)
            {
                if (!string.IsNullOrEmpty(unit.Eff_BornEffectName))
                    CacheEffectObject(unit.Eff_BornEffectName, 3);
                if (!string.IsNullOrEmpty(unit.Eff_DeadEffectName))
                    CacheEffectObject(unit.Eff_DeadEffectName, 3);
                if (!string.IsNullOrEmpty(unit.Eff_DiffacHurtName))
                    CacheEffectObject(unit.Eff_DiffacHurtName, 3);
                if (!string.IsNullOrEmpty(unit.EFf_FireHurtName))
                    CacheEffectObject(unit.EFf_FireHurtName, 3);
                if (!string.IsNullOrEmpty(unit.Eff_FlamethrowerName))
                    CacheEffectObject(unit.Eff_FlamethrowerName, 3);
                if (string.IsNullOrEmpty(unit.Eff_PointHurtName))
                    CacheEffectObject(unit.Eff_PointHurtName, 3);
                if (!string.IsNullOrEmpty(unit.RifleFireName))
                    CacheEffectObject(unit.RifleFireName, 3);
            }
            Clishow.CsObjPoolMgr.Instance.NewPool(obj, nameWithPath, count);
        }
        return true;
    }


    public GameObject GetLevelObjectPrefab(string _name)
    {
        GameObject prefab = null;
        string subpath = string.Empty;

        subpath = ASSET_LEVELOBJECT_DEFENSES_PATH;
        string nameWithPath = ASSET_LEVELOBJECT_PATH + subpath + _name;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            prefab = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);

        }
        if (prefab == null)
        {
            prefab = Resources.Load(nameWithPath) as GameObject;
        }
        return prefab;
    }

    public GameObject GetUnitInstance4UI(string _name)
    {
        GameObject prefab = GetLevelUnitPrefab(_name);
        if (prefab != null)
        {
            Clishow.CsUnit unit = prefab.GetComponent<Clishow.CsUnit>();
            if (unit != null)
            {
                return Object.Instantiate(unit._modelPrefab) as GameObject;
            }
            return null;
        }
        else
        {
            return null;
        }
    }

    public GameObject GetUnitPrefabLow(string _name)
    {
        GameObject prefab = GetLevelUnitPrefab(_name);
        if (prefab != null)
        {
            Clishow.CsUnit unit = prefab.GetComponent<Clishow.CsUnit>();
            if (unit != null)
            {
                return unit._lowModelPrefab;
            }
            return null;
        }
        else
        {
            return null;
        }
    }

    public GameObject GetDefenceInstance4UI(string _name)
    {
        GameObject prefab = GetLevelObjectPrefab(_name);
        if (prefab != null)
        {
            Clishow.CsUnit unit = prefab.GetComponent<Clishow.CsUnit>();
            if (unit != null)
            {
                return Object.Instantiate(unit._modelPrefab) as GameObject;
            }
            return null;
        }
        else
        {
            return null;
        }
    }
    public GameObject GetConstructionShow(string show)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_CONSTRUCTIONSHOW + show;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;

    }
    public GameObject GetLoginPrefab(string Login)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_LOGIN + Login;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetWorldTerrainPrefab(string Login)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_WorldTerrain + Login;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public T GetWorldTerrainAsset<T>(string asset_name) where T:Object
    {
        T go = default(T);
        string nameWithPath = ASSET_PATH_WorldTerrain + asset_name;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<T>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as T;
        }
        return go;
    }

    public GameObject GetLoginInstance(string Login)
    {
        GameObject prefab = GetLoginPrefab(Login);
        if (prefab != null)
        {
            return Object.Instantiate(prefab) as GameObject;
        }
        else
        {
            return null;
        }
    }

    public GameObject GetMainCityPrefab(string mainCity)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_MAIN_CITY + mainCity;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetMainCityInstance(string mainCity)
    {
        GameObject prefab = GetMainCityPrefab(mainCity);
        if (prefab != null)
        {
            return Object.Instantiate(prefab) as GameObject;
        }
        else
        {
            return null;
        }
    }

    public GameObject GetGlobeScenePrefab(string prefaName)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_GLOBE_SCENE + prefaName;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetGlobeSceneInstance(string prefaName)
    {
        GameObject prefab = GetGlobeScenePrefab(prefaName);
        if (prefab != null)
        {
            return Object.Instantiate(prefab) as GameObject;
        }
        else
        {
            return null;
        }
    }


    public AnimationClip GetMainCityAnimationClipInstance(string _clipName)
    {
        AnimationClip clip = null;
        string path = ASSET_PATH_MAIN_CITY + ASSET_PATH_MAIN_CITY_ANIMATION + _clipName;
        //RecordUsed(path);
        if (AssetBundleManager.Instance)
        {
            clip = AssetBundleManager.Instance.LoadAsset<AnimationClip>(path);
        }
        if (clip == null)
        {
            clip = Resources.Load<AnimationClip>(path);
        }
        return clip;
    }


    public GameObject GetConstruactionPrefab(string construction)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_CONSTRUCTION + construction;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetConstructionInstance(string construction)
    {
        GameObject prefab = GetConstruactionPrefab(construction);
        if (prefab != null)
        {
            return Object.Instantiate(prefab) as GameObject;
        }
        else
        {
            return null;
        }
    }

    #region effect
    public GameObject GetEffectInstance(string _name)
    {
        GameObject prefab = GetEffectPrefab(_name);
        if (prefab != null)
        {
            return Object.Instantiate(prefab) as GameObject;
        }
        else
        {
            return null;
        }
    }

    public GameObject GetEffectPrefab(string _name)
    {
        GameObject go = null;
        string nameWithPath = ASSET_PATH_EFFECT + _name;
        //RecordUsed(nameWithPath);
        if (AssetBundleManager.Instance)
        {
            go = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
        }
        if (go == null)
        {
            go = Resources.Load(nameWithPath) as GameObject;
        }
        return go;
    }

    public GameObject GetEffectInstanceFromPool(string _name)
    {
        GameObject obj = null;
        string nameWithPath = ASSET_PATH_EFFECT + _name;
        //RecordUsed(nameWithPath);
        if (!Clishow.CsObjPoolMgr.Instance.IsContainPool(nameWithPath))
        {
            if (!string.IsNullOrEmpty(_name) && AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
            }
            if (obj == null)
            {
                obj = Resources.Load(nameWithPath) as GameObject;
            }
            Clishow.CsObjPoolMgr.Instance.NewPool(obj, nameWithPath);
        }
        obj = Clishow.CsObjPoolMgr.Instance.Instantiate(nameWithPath);
        if (obj != null)
        {
            Clishow.CsSkillIns ins = obj.GetComponent<Clishow.CsSkillIns>();
            if (ins != null)
            {
                ins.Init();
            }
            else
            {
                Clishow.CsSkillAsset sAsset = obj.GetComponent<Clishow.CsSkillAsset>();
                if (sAsset != null)
                {
                    sAsset.Init();
                }
            }
            obj.SetActive(true);
        }
        return obj;
    }

    public Clishow.CsPoolUnit GetEffectPool(string _name)
    {
        string nameWithPath = ASSET_PATH_EFFECT + _name;
        //RecordUsed(nameWithPath);
        GameObject obj = null;
        if (!Clishow.CsObjPoolMgr.Instance.IsContainPool(nameWithPath))
        {
            if (AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
            }
            if (obj == null)
            {
                obj = Resources.Load(nameWithPath) as GameObject;
            }
            Clishow.CsObjPoolMgr.Instance.NewPool(obj, nameWithPath);
        }
        return Clishow.CsObjPoolMgr.Instance.GetPool(nameWithPath);
    }

    public bool CacheEffectObject(string _name, int count = 0)
    {
        GameObject obj = null;
        string nameWithPath = ASSET_PATH_EFFECT + _name;
        //RecordUsed(nameWithPath);
        if (!Clishow.CsObjPoolMgr.Instance.IsContainPool(nameWithPath))
        {
            if (!string.IsNullOrEmpty(_name) && AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
            }
            if (obj == null)
            {
                obj = Resources.Load(nameWithPath) as GameObject;
            }
            Clishow.CsObjPoolMgr.Instance.NewPool(obj, nameWithPath, count);
        }
        return true;
    }

    #endregion

    #region HUD

    public static GameObject GetUnitHudPrefab(string _path)
    {
        //RecordUsed(_path);
        GameObject prefab = null;
        if (AssetBundleManager.Instance)
        {
            prefab = AssetBundleManager.Instance.LoadAsset<GameObject>("prefabs/hud", _path);
        }
        if (prefab == null)
        {
            prefab = Resources.Load("Prefabs/Hud/" + _path) as GameObject;
        }
        return prefab;
    }

    public static GameObject GetUnitHudInstance(string _path)
    {
        GameObject result = null;
        GameObject prefab = GetUnitHudPrefab(_path);
        if (prefab != null)
        {
            result = Object.Instantiate(prefab) as GameObject;
            result.name = prefab.name;
        }
        return result;
    }

    public static GameObject GetUnitHudInstanceFromPool(string _name)
    {
        string nameWithPath = "Prefabs/Hud/" + _name;
        //RecordUsed(nameWithPath);
        GameObject obj = null;
        string name = string.Empty;
        if (!Clishow.CsObjPoolMgr.Instance.IsContainPool(nameWithPath))
        {
            if (!string.IsNullOrEmpty(_name) && AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<GameObject>(nameWithPath);
            }
            if (obj == null)
            {
                obj = Resources.Load(nameWithPath) as GameObject;
            }
            name = obj.name;
            Clishow.CsObjPoolMgr.Instance.NewPool(obj, nameWithPath);
        }
        obj = Clishow.CsObjPoolMgr.Instance.Instantiate(nameWithPath);
        if (obj != null)
        {
            obj.name = name;
            obj.SetActive(true);
        }
        return obj;
    }

    public static GameObject GetInGamePrefab(string _path)
    {
        //RecordUsed(_path);
        GameObject prefab = null;
        if (AssetBundleManager.Instance)
        {
            prefab = AssetBundleManager.Instance.LoadAsset<GameObject>("prefabs/ingame", _path);
        }
        if (prefab == null)
        {
            prefab = Resources.Load("Prefabs/InGame/" + _path) as GameObject;
        }
        return prefab;
    }

    public static GameObject GetInGameInstance(string _path)
    {
        GameObject result = null;
        GameObject prefab = GetInGamePrefab(_path);
        if (prefab != null)
        {
            result = Object.Instantiate(prefab) as GameObject;
            result.name = prefab.name;
        }
        return result;
    }

    private static Dictionary<string,GameObject> mUIPrefabCacheMap = new Dictionary<string, GameObject>();

    public static void CacheUIPrefab(string _path)
    {
        if(mUIPrefabCacheMap.ContainsKey(_path))
            return;
        GameObject prefab = GetUIPrefab(_path);
        if(prefab != null)
        {
            mUIPrefabCacheMap.Add(_path,prefab);
        }
    }

    public static void ClearCacheUIPrefab(string _path = "")
    {
        if(string.IsNullOrEmpty(_path))
        {
            mUIPrefabCacheMap.Clear();
            return;
        }
            
        if(mUIPrefabCacheMap.ContainsKey(_path))
        {
            mUIPrefabCacheMap[_path] = null;
            mUIPrefabCacheMap.Remove(_path);
        }
    }

    public static GameObject GetUIPrefab(string _path)
    {
        GameObject prefab = null;
        string path = "prefabs/" + _path;
        //RecordUsed(path);
        if (mUIPrefabCacheMap.TryGetValue(_path,out prefab))
        {
            return prefab;
        }
        if (AssetBundleManager.Instance)
        {
            prefab = AssetBundleManager.Instance.LoadAsset<GameObject>(path);
        }
        if (prefab == null)
        {
            prefab = Resources.Load(path) as GameObject;
        }
        return prefab;
    }

    public static GameObject GetUIInstance(string _path)
    {
        GameObject result = null;
        GameObject prefab = GetUIPrefab(_path);
        if (prefab != null)
        {
            result = Object.Instantiate(prefab) as GameObject;
            result.name = prefab.name;
        }
        return result;
    }

    #endregion

    #region Icon&BG Resources load
    public static readonly string PATH_ICON = "Icon/";
    public static readonly string PATH_BG = "Background/";

    public Texture GetBg(string _bgName)
    {
        Texture result = null;
        string filename = PATH_BG + _bgName;
        Texture obj = null;
        //RecordUsed(filename);
        if (AssetBundleManager.Instance)
        {
            obj = AssetBundleManager.Instance.LoadAsset<Texture>(filename);
        }
        if (obj == null)
        {
            obj = Resources.Load(filename) as Texture;
        }
        if (obj != null)
        {
            result = obj;
        }

        return result;
    }

    public Texture GetIcon(string _pathName, string _iconName)
    {
        Texture result = null;
        string filename = _pathName + _iconName;
        Texture obj = null;
        //RecordUsed(filename);
        if (AssetBundleManager.Instance)
        {
            obj = AssetBundleManager.Instance.LoadAsset<Texture>(filename);
        }
        if (obj == null)
        {
            obj = Resources.Load(filename) as Texture;
        }
        if (obj != null)
        {
            result = obj;
        }

        return result;
    }

    public Texture2D GetTexture(string _pathName, string _textureName)
    {
        Texture2D result = null;
        string filename = _pathName + _textureName;
        Texture2D obj = null;
        //RecordUsed(filename);
        if (AssetBundleManager.Instance)
        {
            obj = AssetBundleManager.Instance.LoadAsset<Texture2D>(filename);
        }
        if (obj == null)
        {
            obj = Resources.Load(filename) as Texture2D;
        }
        if (obj != null)
        {
            result = obj;
        }

        return result;
    }

    public Sprite GetSprite(string _pathName, string _textureName)
    {
        Sprite result = null;
        string filename = _pathName + _textureName;
        Sprite obj = null;
        //RecordUsed(filename);
        if (AssetBundleManager.Instance)
        {
            obj = AssetBundleManager.Instance.LoadAsset<Sprite>(filename);
        }
        if (obj == null)
        {
            obj = Resources.Load<Sprite>(filename);
        }
        if (obj != null)
        {
            result = obj;
        }

        return result;
    }

    #endregion

    #region Lightmap Resource load
    public static readonly string PATH_LIGHTMAP = "Assets/Art/Models/LevelScene/lightmap/";

    public Texture2D GetLightmapTexture(string filename)
    {
        Texture2D result = null;

        Texture obj = null;
        /*
		if (AssetBundleConfig.Instance.IsAssetbundleFile (filename)) 
		{
			obj = ResourceLibrary.instance.Load(filename) as Texture;	
		}
		else*/
        {
            if (AssetBundleManager.Instance)
            {
                obj = AssetBundleManager.Instance.LoadAsset<Texture>(filename);
            }
            if (obj == null)
            {
#if UNITY_EDITOR
                //RecordUsed(PATH_LIGHTMAP + filename);
                obj = UnityEditor.AssetDatabase.LoadAssetAtPath(PATH_LIGHTMAP + filename + ".exr", typeof(Texture)) as Texture;
#else
                if (AssetBundleManager.Instance)
                {
                    obj = AssetBundleManager.Instance.LoadAsset<Texture>(filename);
                }
                if (obj == null)
                {
                    obj = Resources.Load(filename) as Texture;
                }
#endif
            }
        }

        if (obj != null)
        {
            result = obj as Texture2D;
        }

        return result;
    }

    #endregion

    #region Sound load
    public static readonly string SFX_SUFFIX = ".mp3";
    public static readonly string SFX_RES_PATH_PREFIX = "Assets/Resources/";
    public static readonly string PATH_SFX = "sound/sfx/unit/";
    public static readonly string PATH_COMMON_SFX = "sound/sfx/common/";
    public static readonly string PATH_MUSIC = "sound/music/";
    public static readonly string PATH_UI_SFX = "sound/sfx2/";

    public AudioClip GetSound(string _path, string _name)
    {
        AudioClip ac = null;
        string path = _path + _name;
        //RecordUsed(path);
        if (AssetBundleManager.Instance)
        {
            ac = AssetBundleManager.Instance.LoadAsset<AudioClip>(_path);
        }
        if (ac == null)
        {
            ac = Resources.Load(path) as AudioClip;
        }
        return ac;
    }

    public AudioClip GetCommonSound(string _name)
    {
        return GetSound(PATH_COMMON_SFX, _name);
    }
    public AudioClip GetSfxSound(string _name)
    {
        return GetSound(PATH_SFX, _name);
    }
    public AudioClip GetMusic(string _name)
    {
        return GetSound(PATH_MUSIC, _name);
    }

    public AudioClip GetUISfxSound(string _name)
    {
        return GetSound(PATH_UI_SFX, _name);
    }
    #endregion

    #region Text load
    public static readonly string PATH_TEXT = "dat/";

    public TextAsset GetTextAsset(string _filename)
    {
        string nameWithPath = PATH_TEXT + _filename;
        //RecordUsed(nameWithPath);
        TextAsset binaryStream = null;
        if (AssetBundleManager.Instance)
        {
            binaryStream = AssetBundleManager.Instance.LoadAsset<TextAsset>(nameWithPath);
        }
        if (binaryStream == null)
        {
            binaryStream = Resources.Load(nameWithPath) as TextAsset;
        }
        return binaryStream;
    }
    #endregion
    /*
#if UNITY_EDITOR && !UNITY_IOS
    private class Record
    {
        public string path;
        public int usetimes;
    }

    private static Dictionary<string, Record> records;

    private static void InitRecord()
    {
        string filepath = "D:/ResourceUsedRecord.csv";
        records = new Dictionary<string, Record>();
        if(!File.Exists(filepath))
        {
            File.Create(filepath);
        }
        else
        {
            string[] alllines = File.ReadAllLines(filepath);
            foreach (var item in alllines)
            {
                string[] strs = item.Split(',');
                records.Add(strs[0], new Record() { path = strs[0], usetimes = int.Parse(strs[1]) });
            }
        }
    }

    private static void SaveRecord()
    {
        string filepath = "D:/ResourceUsedRecord.csv";
        if (!File.Exists(filepath))
        {
            File.Create(filepath);
        }
        List<string> alllines = new List<string>();
        foreach (var item in records)
        {
            alllines.Add(item.Value.path + ',' + item.Value.usetimes);
        }
        File.WriteAllLines(filepath, alllines.ToArray());
    }

    static Coroutine savecoroutine;
    static IEnumerator DoSaveRecord()
    {
        yield return new WaitForSeconds(1);
        SaveRecord();
    }
#endif

    private static void RecordUsed(string _path)
    {
#if UNITY_EDITOR && !UNITY_IOS
        if (!Application.isPlaying)
        {
            return;
        }
        if (records == null)
        {
            InitRecord();
        }
        if (records.ContainsKey(_path))
        {
            records[_path].usetimes += 1;
        }
        else
        {
            records.Add(_path, new Record() { path = _path, usetimes = 1 });
        }
        if (savecoroutine != null)
        {
            Main.Instance.StopCoroutine(savecoroutine); 
        }
        savecoroutine = Main.Instance.StartCoroutine(DoSaveRecord());
#endif
    }*/
}