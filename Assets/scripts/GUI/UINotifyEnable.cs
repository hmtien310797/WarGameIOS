using UnityEngine;
using System.Collections;

public class UINotifyEnable : MonoBehaviour
{
    public MonoBehaviour behaviour;

    public void Notify()
    {
        if(behaviour != null)
        {
            behaviour.enabled = true;
        }
    }
}
