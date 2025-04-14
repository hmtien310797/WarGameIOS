using UnityEngine;
using System.Collections;

public class CheckPanelCPU : MonoBehaviour
{

    // Use this for initialization
    void Start()
    {
        //GameObject ui_root_obj = GameObject.Find("UI Root");
        //GameObject ui_top_root_obj = GameObject.Find("UI Top Root");
        string log = "";
        log += CloseComponent<Animation>(this.gameObject);
        log += CloseComponent<Animator>(this.gameObject);
        log += CloseComponent<TweenAlpha>(this.gameObject);
        log += CloseComponent<TweenColor>(this.gameObject);
        log += CloseComponent<TweenFOV>(this.gameObject);
        log += CloseComponent<TweenHeight>(this.gameObject);
        log += CloseComponent<TweenOrthoSize>(this.gameObject);
        log += CloseComponent<TweenPosition>(this.gameObject);
        log += CloseComponent<TweenRotation>(this.gameObject);
        log += CloseComponent<TweenScale>(this.gameObject);
        log += CloseComponent<TweenTransform>(this.gameObject);
        log += CloseComponent<TweenVolume>(this.gameObject);
        log += CloseComponent<TweenWidth>(this.gameObject);
        log += CloseComponent<Particle2D>(this.gameObject);
        Debug.Log(log);
    }

    string CloseComponent<T>(GameObject obj) where T : Behaviour
    {
        if (obj == null)
            return "";
        string log = "################Component:" + typeof(T).ToString() + '\n';
        T t = obj.GetComponent<T>();
        UIPanel panel = null;
        if (t != null)
        {
            ///t.enabled = false;
            log += NGUITools.GetHierarchy(t.gameObject) + '\n';
            panel = NGUITools.FindInParents<UIPanel>(t.gameObject);
            if (panel == null)
            {
                log += NGUITools.GetHierarchy(t.gameObject) + '\n';
            }
            else
            {

                log += NGUITools.GetHierarchy(t.gameObject) + "  Panel:" + NGUITools.GetHierarchy(panel.gameObject) + '\n';
            }
        }
        T[] ts = obj.GetComponentsInChildren<T>(true);
        if (ts != null)
        {
            for (int i = 0; i < ts.Length; i++)
            {
                //ts[i].enabled = false;
                panel = NGUITools.FindInParents<UIPanel>(ts[i].gameObject);
                if (panel == null)
                {
                    log += NGUITools.GetHierarchy(ts[i].gameObject) + '\n';
                }
                else
                {

                    log += NGUITools.GetHierarchy(ts[i].gameObject) + "  Panel:" + NGUITools.GetHierarchy(panel.gameObject) + '\n';
                }
            }
        }
        return log;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
