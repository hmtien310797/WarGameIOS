using UnityEngine;
using System.Collections;

public class CheckUpdateAnchor : MonoBehaviour
{

    // Use this for initialization
    void Start()
    {

        UIRect t = gameObject.GetComponent<UIRect>();
        string log = "";
        if (t != null)
        {
            if (t.updateAnchors == UIRect.AnchorUpdate.OnUpdate)
            {
                log += NGUITools.GetHierarchy(t.gameObject) + '\n';
            }
        }
        UIRect[] ts = gameObject.GetComponentsInChildren<UIRect>(true);
        if (ts != null)
        {
            for (int i = 0; i < ts.Length; i++)
            {
                if (ts[i].updateAnchors == UIRect.AnchorUpdate.OnUpdate)
                {
                    log += NGUITools.GetHierarchy(ts[i].gameObject) + '\n';
                }
            }
        }
        Debug.Log(log);
    }

    // Update is called once per frame
    void Update()
    {

    }
}
