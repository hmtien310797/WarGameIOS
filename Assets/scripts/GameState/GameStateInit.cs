using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

public class GameStateInit : GameState
{
    private static GameStateInit instance;
    private bool mInit;

    private GameStateInit()
    {

    }

    public static GameStateInit Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameStateInit();
            }

            return instance;
        }
    }

    public override void OnEnter(string _param, System.Action done)
    {
        mInit = false;

        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDist)
        {
            Serclimax.Constants.ENABLE_FAKE_DATA = false;
            Serclimax.Constants.ENABLE_CHEAT = false;

            Serclimax.Constants.LOG_ENABLE = false;
            Serclimax.Constants.LOG_NETWORK_ENABLE = false;
        }
        else if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug)
        {
            GameVersion.EXE = "1.0";
        }
        if (done != null)
        {
            done();
        }
    }

    public override void OnUpdate()
    {
        if (!mInit)
        {
            WSdkManager.instance.InitPlatform();

            GameSetting.instance.Init();

            if (!TextManager.Instance.LoadLanguage4Prefs())
                TextManager.Instance.LoadLanguage(WSdkManager.instance.GetSystemLanguage());

            ResourceLibrary.instance.Clear();
            Serclimax.GameTime.timeScale = 1.0f;
            Serclimax.GameTime.gameSpeed = 1.0f;

            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            mInit = true;
        }
        else
        {
            if (WSdkManager.instance.ResultCode == WSdkManager.ERetCode.eCode_Succ)
            {
                if (Serclimax.Constants.ENABLE_FAKE_DATA)
                {
                    GetStateMachine().ChangeState(GameStateMain.Instance, null, null);
                }
                else
                {
                    GetStateMachine().ChangeState(GameStateLogin.Instance, null, null);
                }
            }
        }
    }

    public override void OnFixedUpdate()
    {
    }

    public override void OnLeave()
    {
    }
}
