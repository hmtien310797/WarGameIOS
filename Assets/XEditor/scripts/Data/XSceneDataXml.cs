using UnityEngine;
using System.Collections;
using Serclimax;

#if UNITY_EDITOR
using System.Xml;
public class XSceneDataXml
{
    public GameObject[] prefabs;
    public GameObject effectPrefab;
    public GameObject lightPrefab;
    //public Texture2D[] lightmapFar;
    //public Texture2D[] lightmapNear;
    //public Texture2D[] lightmapFar_2;
    public Vector3 senceRotate = Vector3.zero;
    private Transform effectTransform;
    private Transform[] models;

    public string[] lightmapFarPath;
    public string[] lightmapNearPath;
    public string[] lightmapFarPath_2;
    public string mSceneName;
    private LightmapData[] lightmapArray;

    public bool combineModel1 = true;

    void Awake()
    {
        LoadPrefabs();
    }

    void LoadPrefabs()
    {
        /*
        Transform t = transform;

        models = new Transform[prefabs.Length];
        for (int i = 0; i < prefabs.Length; i++)
        {
            if (prefabs[i] && !t.FindChild(prefabs[i].name) && !GameObject.Find(prefabs[i].name))
            {
                GameObject obj = GameObject.Instantiate(prefabs[i]) as GameObject;
                obj.transform.parent = t;
                obj.transform.localRotation = Quaternion.Euler(senceRotate);
                obj.name = prefabs[i].name;
                obj.SetActive(true);
                if (i == 0 && combineModel1)
                {
                    StaticBatchingUtility.Combine(obj);
                }
                models[i] = obj.transform;

            }
            else if (prefabs[i])
            {
                if (t.FindChild(prefabs[i].name))
                {
                    models[i] = t.FindChild(prefabs[i].name);
                }
                else if (GameObject.Find(prefabs[i].name))
                {
                    models[i] = GameObject.Find(prefabs[i].name).transform;
                }
            }
        }
        if (effectPrefab && !t.FindChild(effectPrefab.name) && !GameObject.Find(effectPrefab.name))
        {
            GameObject obj = GameObject.Instantiate(effectPrefab) as GameObject;
            obj.transform.parent = t;
            obj.transform.localRotation = Quaternion.Euler(senceRotate);
            obj.name = effectPrefab.name;
            obj.SetActive(true);
            effectTransform = obj.transform;
        }
        if (lightPrefab && !t.FindChild(lightPrefab.name) && !GameObject.Find(lightPrefab.name))
        {
            GameObject obj = GameObject.Instantiate(lightPrefab) as GameObject;
            obj.transform.parent = t;
            obj.transform.localRotation = Quaternion.Euler(senceRotate);
            obj.name = lightPrefab.name;
            obj.SetActive(true);
        }

        if (effectPrefab)
        {
            if (effectTransform == null)
            {
                effectTransform = t.FindChild(effectPrefab.name);
                if (effectTransform == null)
                {
                    GameObject e = GameObject.Find(effectPrefab.name);
                    if (e)
                    {
                        effectTransform = e.transform;
                    }
                }
            }
            if (effectTransform)
                QualityManager.instance.FilterEffect(effectTransform.gameObject);
        }
        */
    }

    public void LoadPrefabsInEditor()
    {
        //Transform t = transform;
        for (int i = 0; i < prefabs.Length; i++)
        {
            if (prefabs[i] && !GameObject.Find(prefabs[i].name))
            {
                GameObject obj = GameObject.Instantiate(prefabs[i]) as GameObject;
                obj.name = prefabs[i].name;
                obj.SetActive(true);
                if (i == 0 && combineModel1)
                    StaticBatchingUtility.Combine(obj);
            }
        }
        if (effectPrefab && !GameObject.Find(effectPrefab.name))
        {
            GameObject obj = GameObject.Instantiate(effectPrefab) as GameObject;
            obj.name = effectPrefab.name;
            obj.SetActive(true);
        }
        if (lightPrefab && !GameObject.Find(lightPrefab.name))
        {
            GameObject obj = GameObject.Instantiate(lightPrefab) as GameObject;
            obj.name = lightPrefab.name;
            obj.SetActive(true);
        }
        /*int nLightmapSize = lightmapFar.Length;
        if (nLightmapSize > 0) 
        {
            lightmapArray = new LightmapData[nLightmapSize];
            for (int i = 0; i < nLightmapSize; i++) 
            {
                LightmapData lightmapData = new LightmapData ();
                lightmapData.lightmapFar = lightmapFar [i];
                if (i < lightmapNear.Length && null != lightmapNear [i]) 
                {
                        lightmapData.lightmapNear = lightmapNear [i];
                }
                lightmapArray [i] = lightmapData;
            }
            LightmapSettings.lightmaps = lightmapArray;
        }*/

        int nLightmapSize = lightmapFarPath.Length;
        if (nLightmapSize > 0)
        {
            lightmapArray = new LightmapData[nLightmapSize];
            for (int i = 0; i < nLightmapSize; i++)
            {
                LightmapData lightmapData = new LightmapData();
                //lightmapData.lightmapFar = ResourceLibrary.instance.GetLightmapTexture(lightmapFarPath[i]);
                if (i < lightmapNearPath.Length && null != lightmapNearPath[i])
                {
                    //lightmapData.lightmapNear = ResourceLibrary.instance.GetLightmapTexture(lightmapNearPath[i]);
                }
                lightmapArray[i] = lightmapData;
            }
            LightmapSettings.lightmaps = lightmapArray;
        }
    }

    public Transform FindModel(string _modelName, int _index = 0)
    {
        if (models.Length > _index)
        {
            if (models[_index])
            {
                Transform t = models[_index].transform.Find(_modelName);
                if (t)
                    return t;
            }
        }
        return null;
    }

   
    public GameObject FindEffect(string _effectName)
    {
        if (effectTransform)
        {
            Transform t = effectTransform.Find(_effectName);
            if (t)
                return t.gameObject;
        }
        return null;
    }

    

    public void VisibleAll(bool _visible)
    {
        if (models != null && models.Length > 0)
        {
            for (int i = 0; i < models.Length; i++)
            {
                if (models[i])
                    models[i].gameObject.SetActive(_visible);
            }
        }
        if (effectTransform)
        {
            effectTransform.gameObject.SetActive(_visible);
        }
        //enabled = _visible;
    }

    public void ChangeLightMapTo(int _index)
    {
        

        string[] lightMapTexture = lightmapFarPath;
        if (_index == 2 && lightmapFarPath_2.Length > 0)
            lightMapTexture = lightmapFarPath_2;

        int nLightmapSize = lightMapTexture.Length;
        if (nLightmapSize > 0)
        {
            lightmapArray = new LightmapData[nLightmapSize];
            for (int i = 0; i < nLightmapSize; i++)
            {
                LightmapData lightmapData = new LightmapData();
                //lightmapData.lightmapFar = ResourceLibrary.instance.GetLightmapTexture(lightMapTexture[i]);
                if (i < lightmapNearPath.Length && null != lightmapNearPath[i])
                {
                    //lightmapData.lightmapNear = ResourceLibrary.instance.GetLightmapTexture(lightmapNearPath[i]);
                }
                lightmapArray[i] = lightmapData;
            }
            LightmapSettings.lightmaps = lightmapArray;
        }
    }

    void OnEnable()
    {
        /*int nLightmapSize = lightmapFar.Length;
        if (nLightmapSize > 0) 
        {
            lightmapArray = new LightmapData[nLightmapSize];
            for (int i = 0; i < nLightmapSize; i++) 
            {
                LightmapData lightmapData = new LightmapData ();
                lightmapData.lightmapFar = lightmapFar [i];
                if (i < lightmapNear.Length && null != lightmapNear [i]) 
                {
                    lightmapData.lightmapNear = lightmapNear [i];
                }
                lightmapArray [i] = lightmapData;
            }
            LightmapSettings.lightmaps = lightmapArray;
        }*/

        int nLightmapSize = lightmapFarPath.Length;
        if (nLightmapSize > 0)
        {
            lightmapArray = new LightmapData[nLightmapSize];
            for (int i = 0; i < nLightmapSize; i++)
            {
                LightmapData lightmapData = new LightmapData();
                //lightmapData.lightmapFar = ResourceLibrary.instance.GetLightmapTexture(lightmapFarPath[i]);
                if (i < lightmapNearPath.Length && null != lightmapNearPath[i])
                {
                    //lightmapData.lightmapNear = ResourceLibrary.instance.GetLightmapTexture(lightmapNearPath[i]);
                }
                lightmapArray[i] = lightmapData;
            }
            LightmapSettings.lightmaps = lightmapArray;
        }
    }

    void OnDisable()
    {
        if (lightmapArray == LightmapSettings.lightmaps)
        {
            for (int i = 0; i < LightmapSettings.lightmaps.Length; i++)
            {
                LightmapSettings.lightmaps[i] = null;
            }
            LightmapSettings.lightmaps = null;
        }
    }
    public void WriteToXml(XmlDocument _doc, XmlElement _MapRoot)
    {
        XmlElement sceneElement = _doc.CreateElement("Scene");
        sceneElement.SetAttribute("name", mSceneName);
        sceneElement.SetAttribute("combineModel", combineModel1.ToString());
        sceneElement.SetAttribute("sceneRotate", senceRotate.ToString());

        if (prefabs.Length > 0)
        {
            XmlElement ClistNode = _doc.CreateElement("CollideObjectsList");
            ClistNode.SetAttribute("count", prefabs.Length.ToString());
            for (int i = 0; i < prefabs.Length; ++i)
            {
                XmlElement CObj = _doc.CreateElement("CollideObject");
                CObj.SetAttribute("name", prefabs[i].name);
                CObj.SetAttribute("World_Pos", prefabs[i].transform.position.ToString());
                ClistNode.AppendChild(CObj);
            }
            sceneElement.AppendChild(ClistNode);
        }
        _MapRoot.AppendChild(sceneElement);
    }
    public void SetData(SceneEntity _scenedata)
    {
        mSceneName = _scenedata.name;
        //combineModel1 = _scenedata.combineModel1;
        //senceRotate = _scenedata.senceRotate;
        if(_scenedata.prefabs.Length > 0)
        {
            prefabs = new GameObject[_scenedata.prefabs.Length];
            for(int i=0 ; i<prefabs.Length ; ++i)
            {
                prefabs[i] = _scenedata.prefabs[i];
            }
        }
    }
    public void ReadFromXml(XmlElement _xmlScene)//node scene
    {
        prefabs = null;
        mSceneName = _xmlScene.GetAttribute("name");
        combineModel1 = bool.Parse(_xmlScene.GetAttribute("combineModel1"));
        senceRotate = RawTable.ParseVector3(_xmlScene.GetAttribute("sceneRotate"));

        foreach (XmlNode node in _xmlScene.ChildNodes)
        {
            if (node.Name == "CollideObjectsList")
            {
                XmlElement cObjList = (XmlElement)node;
                int ObjCount = int.Parse(cObjList.GetAttribute("count"));
                prefabs = new GameObject[ObjCount];
                int i = 0;
                foreach(XmlNode obj_node in cObjList)
                {
                    GameObject obj = new GameObject();
                    XmlElement cObjEle = (XmlElement)obj_node;
                    obj.transform.position = RawTable.ParseVector3(cObjEle.GetAttribute("World_Pos"));
                    prefabs[i++] = obj;
                }
            }
        }
    }
}

#endif