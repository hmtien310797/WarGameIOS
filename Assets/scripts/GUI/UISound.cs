using UnityEngine;
using System.Collections;

public class UISound : MonoBehaviour
{
    public string EnterSound ="";
    public string ExitSound = "";
    public string[] ClickSfxNames;
    public int State;
	// Use this for initialization
	void Start () {

	}
	
    void OnEnable()
    {
        if(!string.IsNullOrEmpty(EnterSound))
        {
            if(AudioManager.instance != null)
            {
                if(AudioManager.instance.enableLog)
                    Debug.Log("=======================" + EnterSound + "===========" + transform.name);
                AudioManager.instance.PlayUISfx(EnterSound);
            }
               
        }
    }

    void OnDisable()
    {
	    if(!string.IsNullOrEmpty(ExitSound))
        {
            if(AudioManager.instance != null)
            {
                if (AudioManager.instance.enableLog)
                    Debug.Log("=======================" + EnterSound + "===========" + transform.name);
                AudioManager.instance.PlayUISfx(ExitSound);
            }
                
        }
    }

	// Update is called once per frame
	void Update () {
	
	}

    void OnClick ()
    {
        if(!enabled)
            return;
        if(ClickSfxNames == null)
            return;
        if(State>=0&&State<ClickSfxNames.Length)
        {
            AudioManager.instance.PlayUISfx(ClickSfxNames[State]);
        }
        
    }
}
