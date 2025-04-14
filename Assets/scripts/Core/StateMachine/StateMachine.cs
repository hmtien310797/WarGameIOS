using UnityEngine;
using System.Collections;

public class StateMachine<T>
{
    private State<T> currentState;
    private State<T> previousState;

    private string currStateParam;
    private string prevStateParam;

    public State<T> CurrentState
    {
        get
        {
            return currentState;
        }
    }

    public State<T> PreviousState
    {
        get
        {
            return previousState;
        }
    }

    public StateMachine(State<T> initialState)
    {
        ChangeState(initialState, "",null);
    }

    public void UpdateState()
    {
        if (currentState != null)
        {
            currentState.OnUpdate();
        }
    }

    public void FixedUpdateState()
    {
        if (currentState != null)
        {
            currentState.OnFixedUpdate();
        }
    }

    public void ChangeState(State<T> newState, string _param,System.Action done)
    {
        previousState = currentState;
        prevStateParam = currStateParam;
        currStateParam = _param;

        if (currentState != null)
        {
            currentState.OnLeave();
        }

        currentState = newState;

        currentState.SetStateMachine(this);

        currentState.OnEnter(currStateParam,done);
    }

    public void GoBack()
    {
        if (previousState != null)
        {
            ChangeState(previousState, prevStateParam,null);
        }
    }

    public bool IsInState<S>() where S : State<T>
    {
        if (currentState == null)
        {
            return false;
        }

        return currentState.GetType() == typeof(S);
    }

    public void OnDestory()
    {
        if (currentState != null)
        {
            currentState.OnLeave();
        }
        previousState = null;
        currentState = null;
    }
}
