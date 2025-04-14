using UnityEngine;
using System.Collections;
using LuaInterface;

public class GameStateTutorial : GameState
{
    private static GameStateTutorial instance;

    public static GameStateTutorial Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameStateTutorial();
            }

            return instance;
        }
    }

    public override void OnEnter(string _param,System.Action done)
    {
        if (GUIMgr.Instance.FindMenu("Starwars") == null)
        {
            GUIMgr.Instance.CreateMenu("Starwars");
        }
        if(done != null)
            done();
    }

    public override void OnLeave()
    {
        //LuaClient.GetMainState().GetFunction("MainData.GetCharId").Call();
    }

    public override void OnUpdate()
    {
    }

    public override void OnFixedUpdate()
    {
    }
}
