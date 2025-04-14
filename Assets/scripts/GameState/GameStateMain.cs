using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Clishow;
using System;

public class GameStateMain : GameState
{
    private static GameStateMain instance;

    private GameObject mainCityGameObject;

    private GameStateMain()
    {

    }

    public static GameStateMain Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameStateMain();
            }

            return instance;
        }
    }

    public void ClearMainCity()
    {
        mainCityGameObject = null;
    }

    public override void OnEnter(string _param, System.Action done)
    {
#if SUPPORT_CHANGE_SCENE
        UnityEngine.SceneManagement.Scene scene = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
        if (scene.name == "load_middle")
        {
            Main.Instance.StartCoroutine(ChangeSceneUtility.ChangeNewScene(() =>
            {
                if (GUIMgr.Instance.FindMenu("MainCityUI") == null)
                {
                    GUIMgr.Instance.CreateMenu("MainCityUI");
                }
                if (done != null)
                    done();
            }));
        }
        else
        {
            if (GUIMgr.Instance.FindMenu("MainCityUI") == null)
            {
                GUIMgr.Instance.CreateMenu("MainCityUI");
            }
            if (done != null)
                done();
        }

#else
        if (GUIMgr.Instance.FindMenu("MainCityUI") == null)
        {
            GUIMgr.Instance.CreateMenu("MainCityUI");
        }
        if(done != null)
            done();
#endif

    }

    public override void OnLeave()
    {
        if (mainCityGameObject != null)
        {
            LuaBehaviour luaBehaviour = mainCityGameObject.GetComponentInChildren<LuaBehaviour>();
            if (luaBehaviour != null)
            {
                luaBehaviour.CallFunc("Close", null);
            }

            UnityEngine.Object.Destroy(mainCityGameObject);
        }
    }

    public override void OnUpdate()
    {
    }

    public override void OnFixedUpdate()
    {
    }

    public void LoadMainCity(string mainCity)
    {
        mainCityGameObject = ResourceLibrary.instance.GetMainCityInstance(mainCity);
    }

    public string GetVersion()
    {
        string resVersion = GameSetting.instance.option.mResVersion;
        if (string.IsNullOrEmpty(resVersion))
        {
            resVersion = GameVersion.RES;
        }
        string version = string.Format("App  v{0}.{1}  build{2}", GameVersion.EXE, resVersion, GameVersion.BUILD);
        return version;
    }
}
