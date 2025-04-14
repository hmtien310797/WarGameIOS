using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ScrollItemEx : MonoBehaviour
{
    Vector3 dirMove = Vector3.zero;
    bool isScrollItem = false;
    public UIScrollView scrollView;
    public float origPosX = 0;
    public float offsetMaxPosX = 0;
    public bool IsScroll
    {
        get { return isScrollItem; }
    }

    void Awake()
    {
        //scrollView = transform.parent.parent.parent.GetComponent<UIScrollView>();
        if (scrollView)
        {
            scrollView.onItemReset.Add(Reset);
        }
        origPosX = transform.localPosition.x;
        offsetMaxPosX = origPosX - 100;
    }

    void Start()
    {

    }
    void OnDestroy()
    {
        
    }

    void Update()
    {
        
    }
    public void Reset()
    {
        SpringPosition sp = SpringPosition.Begin(transform.gameObject, new Vector3(origPosX, transform.localPosition.y, 0), 13f);
        sp.onFinished = SpringFinish;
    }
    public void Drag(float delt)
    {
        dirMove.x += delt*0.1f;
       // Debug.Log("ScrollItemEx delt:" + dirMove);
        if (Mathf.Abs(dirMove.x) >= 5)
        {
            isScrollItem = true;
            transform.localPosition = new Vector3(Mathf.Min(transform.localPosition.x + delt * 0.3f, origPosX) , transform.localPosition.y, 0);// new Vector3(delt * 0.3f, 0, 0);
        }
        //Debug.Log("ScrollItemEx delt:" + dirMove);
        
    }
    public void SpringFinish()
    {
        isScrollItem = false;
        dirMove.x = 0;
    }
     
    public void Press(bool press)
    {
        if(!press)
        {
            if (transform.localPosition.x < offsetMaxPosX)
            {
                SpringPosition sp = SpringPosition.Begin(transform.gameObject, new Vector3(offsetMaxPosX, transform.localPosition.y, 0), 13f);
                sp.onFinished = SpringFinish;
            }
            else if (transform.localPosition.x < origPosX)
            {
                SpringPosition sp = SpringPosition.Begin(transform.gameObject, new Vector3(origPosX, transform.localPosition.y, 0), 13f);
                sp.onFinished = SpringFinish;
            }
        }
        else
        {
            if (scrollView)
                scrollView.ResetScrollItemEx();
        }
    }

}
