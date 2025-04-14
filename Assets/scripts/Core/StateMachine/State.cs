using UnityEngine;
using System.Collections;

public abstract class State<T>
{
    protected StateMachine<T> stateMachine;

    public abstract void OnEnter(string _param,System.Action done);

    public abstract void OnUpdate();

    public abstract void OnLeave();

    public abstract void OnFixedUpdate();

    public void SetStateMachine(StateMachine<T> stateMachine)
    {
        this.stateMachine = stateMachine;
    }

    public StateMachine<T> GetStateMachine()
    {
        return stateMachine;
    }
}
