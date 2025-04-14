using UnityEngine;
using System.Collections;
using Serclimax;
using System.Collections.Generic;

public class UISpringPanel : MonoBehaviour
{
    UIScrollView sv;
    UIGrid sgrid;
    UIPanel panel;
   

    public delegate void UpdateContent();
    public UpdateContent OnUpdateContent;
    // Use this for initialization
    void Awake()
    {
        sv = transform.GetComponent<UIScrollView>();

        panel = sv.panel;
    }

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }
   public void SetSpringPanelMove(Vector3 move)
    {
        if (panel == null) panel = sv.panel;
        SpringPanel sp = transform.GetComponent<SpringPanel>();
        if(sp != null && sp.enabled)
        {
            sp.target += move;
        }
        else
        {
            Vector3 pos = transform.localPosition + move;
            pos.x = Mathf.Round(pos.x);
            pos.y = Mathf.Round(pos.y);
            SpringPanel.Begin(panel.gameObject, pos, 13f).strength = 30f;
        }
    }

    public void SetPringPanelMoveRelative(Vector3 move)
    {
        if (panel == null) panel = sv.panel;
        SpringPanel sp = transform.GetComponent<SpringPanel>();
        if (sp != null && sp.enabled)
        {
            sp.target += move;
        }
        else
        {
            Vector3 pos = transform.localPosition + move;
            Vector2 cr = panel.clipOffset;
            cr.x -= move.x;
            cr.y -= move.y;
            panel.clipOffset = cr;
        }
    }
}


