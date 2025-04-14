using UnityEngine;
using UnityEngine.Rendering;
using System.Collections.Generic;

#if UNITY_EDITOR
using System.Xml;
#endif

public class PostEffectTypeParam
{
    public float Bloom_Threshold;
    public float Bloom_Intensity;
    public float Color_Brightness;
    public float Color_Contrast;
    public float Color_Saturate;
}


public class SceneEntity : MonoBehaviour
{
    // Linked Prefab
    public GameObject combinePrefab;
    public GameObject[] prefabs;
    public string AstarFile;
    // Render Setting
    public Color ambientLight = Color.grey;
    public float ambientIntensity = 1.0f;
    public bool enableFog = false;
    public Color fogColor = Color.grey;
    public FogMode fogMode = FogMode.Linear;
    public float fogDesity = 0.01f;
    public float fogStart = 20;
    public float fogEnd = 40;
    public AmbientMode ambientMode;
    public Material skybox;
    public float minCameraX;
    public float maxCameraX;
    public float minCameraZ;
    public float maxCameraZ;
    public float minCameraY;
    public float maxCameraY;

    // Light Map
    public LightmapsMode lightmapMode = LightmapsMode.NonDirectional;
    public Texture2D[] lightmapFar;
    public Texture2D[] lightmapNear;

    //CurvedWorld
    //public bool EnableCurvedWorld = true;
    //public float CurvedWorld_Bend_X = -2;
    //public float CurvedWorld_Bias_X = 2;
    //public float CurvedWorld_Bend_Z = -3f;
    //public float CurvedWorld_Bias_Z = 1;


    public GameObject[] MaskObjs = null;

    //BeautifyEffect
    public bool ActiveBeautifyEffect = false;

    //Shadow 
    public bool EnableShadow = true;
    public bool SupportYIgnore = true;
    public Vector3 LightDir = new Vector3(50, -30, 0);
    public float ShadowStrength = 0.0218f;

    // private variables
    protected Transform combinedModel;
    Transform[] models;
    bool penableFog = false;
    Color pfogColor = Color.grey;
    FogMode pfogMode = FogMode.Linear;
    float pfogDesity = 0.01f;
    float pfogStart = 20;
    float pfogEnd = 40;
    Color pambientLight = Color.grey;
    float pambientIntensity = 1.0f;
    AmbientMode pAmbientMode;
    Material pSkybox;
    LightmapsMode pLightmapMode;

    //private VacuumShaders.CurvedWorld.CurvedWorld_Controller mCW = null;

    private Clishow.CsProjShadowMap mProjShadow = null;

    public Clishow.CsProjShadowMap ProjShadow
    {
        get
        {
            return mProjShadow;
        }
    }

    private Clishow.CsPostEffect mPostEffect = null;

    public Clishow.CsPostEffect PostEffect
    {
        get
        {
            return mPostEffect;
        }
    }

    private PostEffectTypeParam[] PostEffectParams = new PostEffectTypeParam[] {
        new PostEffectTypeParam {Bloom_Threshold = 0.7f,Bloom_Intensity = 0.2f, Color_Brightness=1,Color_Contrast = 1.1f,Color_Saturate = 0.5f},
        new PostEffectTypeParam {Bloom_Threshold = 0.7f,Bloom_Intensity = 0.2f, Color_Brightness=1.1f,Color_Contrast = 1.05f,Color_Saturate = 0.5f },
    };

    public void OnEnable()
    {
        ResetRenderSettings();
    }
    public void ResetRenderSettings()
    {
        penableFog = RenderSettings.fog;
        pfogColor = RenderSettings.fogColor;
        pfogMode = RenderSettings.fogMode;
        pfogDesity = RenderSettings.fogDensity;
        pfogStart = RenderSettings.fogStartDistance;
        pfogEnd = RenderSettings.fogEndDistance;
        pambientLight = RenderSettings.ambientLight;
        pambientIntensity = RenderSettings.ambientIntensity;
        pAmbientMode = RenderSettings.ambientMode;
        pSkybox = RenderSettings.skybox;

        SetRenderSetting();

        pLightmapMode = LightmapSettings.lightmapsMode;
        LightmapSettings.lightmapsMode = lightmapMode;
        OnEnableLightmap();
    }
    void OnDisable()
    {
        // Reset render setting
        RenderSettings.ambientLight = pambientLight;
        RenderSettings.ambientIntensity = pambientIntensity;
        RenderSettings.fog = penableFog;
        RenderSettings.fogColor = pfogColor;
        RenderSettings.fogMode = pfogMode;
        RenderSettings.fogDensity = pfogDesity;
        RenderSettings.fogStartDistance = pfogStart;
        RenderSettings.fogEndDistance = pfogEnd;
        RenderSettings.ambientMode = pAmbientMode;
        RenderSettings.skybox = pSkybox;

        OnDisableLightmap();

        LightmapSettings.lightmapsMode = pLightmapMode;
    }

    public void SetRenderSetting()
    {
        RenderSettings.ambientLight = ambientLight;
        RenderSettings.ambientIntensity = ambientIntensity;
        RenderSettings.fog = enableFog;
        RenderSettings.fogColor = fogColor;
        RenderSettings.fogMode = fogMode;
        RenderSettings.fogDensity = fogDesity;
        RenderSettings.fogStartDistance = fogStart;
        RenderSettings.fogEndDistance = fogEnd;
        RenderSettings.ambientMode = ambientMode;
        RenderSettings.skybox = skybox;

        //if (VacuumShaders.CurvedWorld.CurvedWorld_Controller.get != null)
        //{
        //    mCW = VacuumShaders.CurvedWorld.CurvedWorld_Controller.get;
        //}
        //if (mCW == null)
        //    mCW = this.gameObject.GetComponent<VacuumShaders.CurvedWorld.CurvedWorld_Controller>();
        //if (mCW == null)
        //    mCW = this.gameObject.AddComponent<VacuumShaders.CurvedWorld.CurvedWorld_Controller>();
        //mCW.enabled = EnableCurvedWorld;
        //if (EnableCurvedWorld)
        //{
        //    mCW.pivotPoint = Camera.main.transform;
        //    mCW._V_CW_Bend_X = CurvedWorld_Bend_X;
        //    mCW._V_CW_Bias_X = CurvedWorld_Bias_X;

        //    //mCW._V_CW_Bend_Z = CurvedWorld_Bend_Z;
        //    //mCW._V_CW_Bias_Z = CurvedWorld_Bias_Z;
        //}
        mPostEffect = this.gameObject.GetComponentInChildren<Clishow.CsPostEffect>();
        Camera cam = null;
        if(mPostEffect == null)
        {
            cam = this.gameObject.GetComponentInChildren<Camera>();
            if(cam == null)
            {
                cam = Camera.main;
            }
            if(cam != null)
            {
                mPostEffect = cam.gameObject.AddComponent<Clishow.CsPostEffect>();
                PostEffectTypeParam param = PostEffectParams[1];
                mPostEffect.Bloom_Threshold = param.Bloom_Threshold;
                mPostEffect.Bloom_Intensity = param.Bloom_Intensity;
                mPostEffect.Color_Brightness = param.Color_Brightness;
                mPostEffect.Color_Contrast = param.Color_Contrast;
                mPostEffect.Color_Saturate = param.Color_Saturate;
                mPostEffect.Blur_DownSample = 2;
            }
        }

        if(cam == null)
        {
            cam = this.gameObject.GetComponentInChildren<Camera>();
            if(cam == null)
            {
                cam = Camera.main;
            }
            if(cam != null)
            {
                cam.backgroundColor = fogColor;
            }
        }

        
    }

    void OnEnableLightmap()
    {
        int nLightmapSize = lightmapFar.Length;
        if (nLightmapSize > 0)
        {
            LightmapData[] lightmapArray = new LightmapData[nLightmapSize];
            for (int i = 0; i < nLightmapSize; i++)
            {
                LightmapData lightmapData = new LightmapData();
                lightmapData.lightmapColor = lightmapFar[i];
                if (lightmapNear != null && lightmapNear.Length > i)
                    lightmapData.lightmapDir = lightmapNear[i];
                else
                    lightmapData.lightmapDir = null;
                lightmapArray[i] = lightmapData;
            }
            LightmapSettings.lightmaps = lightmapArray;
        }
    }

    void OnDisableLightmap()
    {
        if (lightmapFar.Length > 0)
        {
            for (int i = 0; i < LightmapSettings.lightmaps.Length; i++)
            {
                LightmapSettings.lightmaps[i] = null;
            }
            LightmapSettings.lightmaps = null;
        }
    }

    void OnDestroy()
    {
        if (mProjShadow != null)
        {
            GameObject.Destroy(mProjShadow.gameObject);
            mProjShadow = null;
        }

    }

    public void Awake()
    {
        LoadPrefabs();
    }

    
    protected System.Collections.IEnumerator InitShadow(bool apply_constructs = true)
    {
        yield return new WaitForEndOfFrame();
        if (EnableShadow)
        {
            Clishow.CsProjShadowMap.ProjCfg cfg = new Clishow.CsProjShadowMap.ProjCfg();
            cfg.LightDir = LightDir;
            cfg.ShadowStrength = ShadowStrength;
            cfg.SupportYIgnore = SupportYIgnore;
            cfg.ShadowLayer = new LayerMask();
            if(GameSetting.instance.option.mQualityLevel == 2 && apply_constructs)
                cfg.ShadowLayer.value = (1 << LayerMask.NameToLayer("units"))|(1 << LayerMask.NameToLayer("constructs"));
            else
                cfg.ShadowLayer.value = (1 << LayerMask.NameToLayer("units"));
            cfg.GroundLayer.value = ~(1 << LayerMask.NameToLayer("ground"));
            GameObject obj = new GameObject("ShadowMap");
            obj.transform.parent = this.transform;
            obj.transform.position = Vector3.zero;
            mProjShadow = obj.AddComponent<Clishow.CsProjShadowMap>();
            if (!mProjShadow.Initialize(cfg,Color.white,150))
            {
                mProjShadow = null;
                GameObject.Destroy(obj);
            }
        }
        else
            mProjShadow = null;
    }
    void Start()
    {
        if (combinedModel)
        {
            StaticBatchingUtility.Combine(combinedModel.gameObject);
        }
        StartCoroutine(InitShadow());

    }

    public void LoadPrefabs()
    {
        Transform t = transform;

        if (combinePrefab && !t.Find(combinePrefab.name) && !GameObject.Find(combinePrefab.name))
        {
            GameObject obj = GameObject.Instantiate(combinePrefab) as GameObject;
            obj.transform.parent = t;
            obj.name = combinePrefab.name;
            obj.SetActive(true);
            combinedModel = obj.transform;
            combinedModel.localPosition = Vector3.zero;
        }

        models = new Transform[prefabs.Length];
        for (int i = 0; i < prefabs.Length; i++)
        {
            if (prefabs[i] && !t.Find(prefabs[i].name) && !GameObject.Find(prefabs[i].name))
            {
                GameObject obj = GameObject.Instantiate(prefabs[i]) as GameObject;
                obj.transform.parent = t;
                obj.name = prefabs[i].name;
                obj.SetActive(true);
                models[i] = obj.transform;
                models[i].localPosition = Vector3.zero;
            }
        }
    }

    public Transform FindChild(string _name)
    {
        Transform result = null;
        if (combinedModel)
        {
            result = combinedModel.Find(_name);
        }
        if (result == null)
        {
            for (int i = 0; i < models.Length; i++)
            {
                if (models[i])
                {
                    result = models[i].Find(_name);
                    if (result)
                        break;
                }
            }
        }
        return result;
    }

#if UNITY_EDITOR
    public void WriteToXml(XmlDocument _doc, XmlElement _MapRoot)
    {
        XmlElement sceneElement = _doc.CreateElement("Scene");
        BoxCollider[] CollideBox = GetComponentsInChildren<BoxCollider>();

        sceneElement.SetAttribute("name", "sceneName");
        sceneElement.SetAttribute("AStar", AstarFile);
        sceneElement.SetAttribute("count", CollideBox.Length.ToString());
        sceneElement.SetAttribute("minCameraX", minCameraX.ToString());
        sceneElement.SetAttribute("maxCameraX", maxCameraX.ToString());
        sceneElement.SetAttribute("minCameraZ", minCameraZ.ToString());
        sceneElement.SetAttribute("maxCameraZ", maxCameraZ.ToString());
        sceneElement.SetAttribute("minCameraY", minCameraY.ToString());
        sceneElement.SetAttribute("maxCameraY", maxCameraY.ToString());

        for (int i = 0; i < CollideBox.Length; ++i)
        {
            BoxCollider m = CollideBox[i];
            string name = m.name;
            XmlElement CObj = _doc.CreateElement("CollideObject");
            CObj.SetAttribute("name", name);
            CObj.SetAttribute("position", m.transform.position.ToString());
            CObj.SetAttribute("scale", m.transform.localScale.ToString());
            //避免精度丢失，应记录欧拉角(面板值)。读取后再用于构建四元数:Quatertion.Eular(Vector3 eular);
            //CObj.SetAttribute("rotate", m.transform.rotation.ToString());
            CObj.SetAttribute("rotate", m.transform.localEulerAngles.ToString());
            CObj.SetAttribute("center", m.center.ToString());
            CObj.SetAttribute("size", m.size.ToString());
            sceneElement.AppendChild(CObj);
        }
        _MapRoot.AppendChild(sceneElement);
    }
#endif
}

