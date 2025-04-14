using UnityEngine;
using System.Collections;

public class TutorialTrigger : MonoBehaviour {

	// Use this for initialization
	void Start () {
        if (GUIMgr.Instance.onTutorialTriggered != null)
        {
            LuaBehaviour menu = gameObject.GetComponentInParent<LuaBehaviour>();
            if (menu != null)
            {
                GUIMgr.Instance.onTutorialTriggered(menu.name);
            }
        }
    }
	
	// Update is called once per frame
	void Update () {
	
	}
}
