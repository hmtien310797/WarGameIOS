using UnityEngine;
using System.Collections;
using Serclimax;
using System.Collections.Generic;

public class SpringPanelController : MonoBehaviour
{
    UIScrollView sv;
    UIGrid sgrid;
    UIPanel panel;
    public GameObject juhua;
    public GameObject itemPrefab;
    public Vector3 juhuaOffset = new Vector3(0, 50, 0);
    public float svCurrentPosy = 0;
    public float svMoveOffset = 150;

    public delegate void UpdateContent();
    public UpdateContent OnUpdateContent;
    // Use this for initialization
    void Awake()
    {
        sv = transform.GetComponent<UIScrollView>();
        sgrid = sv.transform.Find("Grid").GetComponent<UIGrid>();

        panel = sv.panel;
        svCurrentPosy = 0;

        sv.onDragFinished = ScrollViewDragFinished;
        sv.onDragMove = UpdateJuhua;
    }

    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {

    }
    void SetSpringPanelMove(Vector3 move)
    {
        if (panel == null) panel = sv.panel;
        Bounds b = sv.bounds;
        Vector3 constraint = panel.CalculateConstrainOffset(b.min, b.max);

        constraint.x = 0f;
        //constraint.y = 0f;

        if (constraint.sqrMagnitude > 0.1f)
        {
            // if (!instant && dragEffect == DragEffect.MomentumAndSpring)
            {
                // Spring back into place
                Vector3 pos = sv.transform.localPosition + constraint + move;
                pos.x = Mathf.Round(pos.x);
                pos.y = Mathf.Round(pos.y);
                SpringPanel sp = SpringPanel.Begin(panel.gameObject, pos, 13f);
                sp.strength = 8f;
                sp.onFinished = ScrollViewStopMoving;
                if (move != Vector3.zero && OnUpdateContent != null)
                    OnUpdateContent();
                    //StartCoroutine(GetMsg());
            }
        }
    }
    void ScrollViewDragFinished()
    {
        if (Mathf.Abs(svCurrentPosy) > svMoveOffset)
        {
            sv.enabled = false;
            SetSpringPanelMove(juhuaOffset);
        }
        else
        {
            SetSpringPanelMove(Vector3.zero);
        }
    }
    public void OnFreshContent()
    {
        svCurrentPosy = 0;
        SpringPanel.Stop(panel.gameObject);
        juhua.SetActive(false);
    }
    public void RestrictBounds()
    {
        if (panel == null) panel = sv.panel;
        Bounds b = sv.bounds;
        Vector3 constraint = panel.CalculateConstrainOffset(b.min, b.max);

        constraint.x = 0f;
        //constraint.y = 0f;

        if (constraint.sqrMagnitude > 0.1f)
        {
            // if (!instant && dragEffect == DragEffect.MomentumAndSpring)
            {
                // Spring back into place
                Vector3 pos = sv.transform.localPosition + constraint;
                pos.x = Mathf.Round(pos.x);
                pos.y = Mathf.Round(pos.y);
                SpringPanel sp = SpringPanel.Begin(panel.gameObject, pos, 13f);
                sp.strength = 8f;
                sp.onFinished = () => { svCurrentPosy = 0; juhua.SetActive(false); ScrollViewStopMoving(); };
                //StartCoroutine(GetMsg());
            }
        }
    }
    IEnumerator GetMsg()
    {
        //yield return new WaitForSeconds(1);
        //UIGrid infoGrid = sv.transform.Find("Grid").GetComponent<UIGrid>();
        /*for (int i = 1; i < 4; i++)
        {
            Transform item = NGUITools.AddChild(sgrid.gameObject, itemPrefab).transform;
            item.SetParent(sgrid.transform, false);


        }
        sgrid.Reposition();
        */
        if (OnUpdateContent != null)
            yield return OnUpdateContent;
            //OnUpdateContent();

        yield return new WaitForEndOfFrame();
        SpringPanel.Stop(panel.gameObject);
        juhua.SetActive(false);
    }

    void UpdateJuhua()
    {
        /*
        if (juhua == null) return;
        if (sv.transform.localPosition.y - svCurrentPosy > svMoveOffset)
        {
            juhua.SetActive(true);
            int childcount = sgrid.transform.childCount;
            Transform lastChildTrf = sgrid.transform.GetChild(childcount - 1);
            Vector3 transPos = lastChildTrf.localPosition + lastChildTrf.parent.localPosition;
            juhua.transform.localPosition = transPos - juhuaOffset;
        }*/
        if (panel == null) panel = sv.panel;
        Bounds b = sv.bounds;
        Vector3 constraint = panel.CalculateConstrainOffset(b.min, b.max);
        
        Vector3 pos = sv.transform.localPosition + constraint;
        //Debug.Log(pos.y - sv.transform.localPosition.y + "             "+ constraint.y + "         " + Mathf.Abs(constraint.y));
        if(Mathf.Abs(constraint.y) > svMoveOffset)
        {
            juhua.SetActive(true);
            int childcount = sgrid.transform.childCount;
            Transform lastChildTrf = sgrid.transform.GetChild(childcount - 1);
            Vector3 transPos = lastChildTrf.localPosition + lastChildTrf.parent.localPosition;
            juhua.transform.localPosition = transPos - juhuaOffset;

            svCurrentPosy = constraint.y;
        }
    }

    void ScrollViewStopMoving()
    {
        svCurrentPosy = 0;
        sv.enabled = true;
    }
}


