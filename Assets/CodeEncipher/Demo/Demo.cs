using UnityEngine;
using System.Collections;

public class Demo : MonoBehaviour 
{
	// Use this for initialization
	void Awake()
	{
#if UNITY_ANDROID
        Screen.SetResolution(480,854,true);
#else
        Screen.SetResolution(800, 600, false);
#endif
    }
	void Update()
	{
		transform.Rotate(new Vector3(0,0,Time.deltaTime*90f));
	}

    private void OnGUI()
    {
        GUI.Label(new Rect(5,5,300,50), "UnityVersion:"+Application.unityVersion);
    }
}
