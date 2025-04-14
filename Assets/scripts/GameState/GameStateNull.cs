using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Clishow;
using System;

public class GameStateNull : GameState
{
    private static GameStateNull instance;

    private GameStateNull()
    {

    }

    public static GameStateNull Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameStateNull();
            }

            return instance;
        }
    }


    public override void OnEnter(string _param, System.Action done)
    {
#if SUPPORT_CHANGE_SCENE
        Main.Instance.StartCoroutine(ChangeSceneUtility.ChangeNewScene(() =>
        {
            if (done != null)
                done();
        }));

#else
        if(done != null)
            done();
#endif

    }

    public override void OnLeave()
    {

    }

    public override void OnUpdate()
    {
    }

    public override void OnFixedUpdate()
    {
    }
}
