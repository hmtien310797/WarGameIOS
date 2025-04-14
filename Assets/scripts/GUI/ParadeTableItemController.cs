using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax;

public class ParadeTableItemController : MonoBehaviour
{
    public Transform AutoHightRoot = null;
    public int RootUnitHight = 0;
    public UIWidget[] AutoAdjustHightWidgets;
    public int[] AutoAdjustWidgetOffsets;
    public int AutoHightRootOffset = 0;
    public bool isActive = false;
    private int[] mAutoAdjustBeforeHightWidgets;
    private int[] mAutoAdjustAfterHightWidgets;

    public delegate void FinishCallback();
    public FinishCallback finishCallback;

    private TweenHeight mTwHeight = null;
    private int TwidgetHeight = 0;
    private UIButton mButtomOpen = null;
    private UITable mParentTable = null;
    private bool mOpen = false;
    private bool mTableActive = false;
    private float mTwStartHeight = 0;

    void Awake()
    {
        mTwHeight = transform.Find("bg_list").GetComponent<TweenHeight>();

        if (mTwHeight != null)
        {
            UIWidget w = mTwHeight.GetComponent<UIWidget>();
            TwidgetHeight = w.height;
        }
        mButtomOpen = transform.Find("bg_list/btn_open").GetComponent<UIButton>();
        mTwStartHeight = transform.Find("bg_list").GetComponent<UIWidget>().height;
        //mParentTable = transform.parent.GetComponent<UITable>();

        //mTwHeight.onFinished += TableOpenFinish;
        EventDelegate.Add(mTwHeight.onFinished, TableOpenFinish, false);
        EventDelegate.Add(mButtomOpen.onClick, OnClickOpen, false);
        if (AutoAdjustHightWidgets != null && AutoAdjustHightWidgets.Length != 0)
        {
            if(AutoAdjustWidgetOffsets == null)
            {
                AutoAdjustWidgetOffsets = new int[AutoAdjustHightWidgets.Length]; 
            }
            else
            {
                if(AutoAdjustWidgetOffsets.Length < AutoAdjustHightWidgets.Length)
                {
                    int[] nhws = new int[AutoAdjustHightWidgets.Length]; 
                    for(int i =0;i<AutoAdjustHightWidgets.Length;i++)
                    {
                        if(i<AutoAdjustWidgetOffsets.Length)
                            nhws[i] = AutoAdjustWidgetOffsets[i];
                        else
                            break;
                    }
                    AutoAdjustWidgetOffsets = nhws;
                }
            }
            mAutoAdjustBeforeHightWidgets = new int[AutoAdjustHightWidgets.Length];
            mAutoAdjustAfterHightWidgets = new int[AutoAdjustHightWidgets.Length];
            for (int i = 0, imax = AutoAdjustHightWidgets.Length; i < imax; i++)
            {
                if (AutoAdjustHightWidgets[i] != null)
                {
                    mAutoAdjustBeforeHightWidgets[i] = AutoAdjustHightWidgets[i].height;
                    mAutoAdjustAfterHightWidgets[i] = mAutoAdjustBeforeHightWidgets[i];
                }
            }
        }
    }

    void Start()
    {

    }
    public void Reset()
    {
        if (mTwHeight != null)
            mTwHeight.Toggle();
    }

    public void SetItemOpenHeight(int height)
    {
        if (mTwHeight != null)
        {
            mTwHeight.to = height;
        }
    }

    public void CalAutoHight()
    {
        if (AutoHightRoot == null || mTwHeight == null)
        {
            return;
        }
        UIWidget widget = null;
        int hight = 0;
        Bounds bound = new Bounds();
        for (int i = 0, imax = AutoHightRoot.childCount; i < imax; i++)
        {
            widget = AutoHightRoot.GetChild(i).GetComponent<UIWidget>();
            Bounds b = widget.CalculateBounds();
            float h = b.size.y;
            b.center = widget.transform.localPosition;
            bound.Encapsulate(b);
            if(isActive)
            hight += widget.height;
        }
        if(!isActive)
        hight = Mathf.RoundToInt( bound.size.y);

        //Debug.Log(bound.size + "  " + hight);
        if (mAutoAdjustAfterHightWidgets != null)
        {
            for (int i = 0, imax = mAutoAdjustAfterHightWidgets.Length; i < imax; i++)
            {
                if (!AutoAdjustHightWidgets[i].name.Contains("#AutoHeight"))
                {
                    if(!isActive)
                    mAutoAdjustAfterHightWidgets[i] = mAutoAdjustBeforeHightWidgets[i] + hight + AutoAdjustWidgetOffsets[i];                    
                }
                else
                {
                    mAutoAdjustAfterHightWidgets[i] = hight + AutoAdjustWidgetOffsets[i];
                }
                AutoAdjustHightWidgets[i].height = mAutoAdjustAfterHightWidgets[i];
                NGUITools.UpdateWidgetCollider(AutoAdjustHightWidgets[i].gameObject);
            }
        }


        mTwHeight.to = hight + TwidgetHeight + AutoHightRootOffset + AutoHightRoot.childCount*RootUnitHight;
    }

    private void AutoAdjustWidget(bool isopen)
    {
        if (AutoAdjustHightWidgets == null || AutoAdjustHightWidgets.Length == 0)
            return;
        for (int i = 0, imax = AutoAdjustHightWidgets.Length; i < imax; i++)
        {
            if (AutoAdjustHightWidgets[i] == null)
                continue;
            if (isopen)
            {
                AutoAdjustHightWidgets[i].height = mAutoAdjustAfterHightWidgets[i];
            }
            else
            {
                AutoAdjustHightWidgets[i].height = mAutoAdjustBeforeHightWidgets[i];
            }

        }
    }

    public void OnClickOpen()
    {

        if (mTableActive) return;
        mButtomOpen.transform.GetComponent<BoxCollider>().enabled = false;
        //Debug.Log("buttom click :" + mTableActive);

        mTableActive = true;
        mOpen = !mOpen;

        //CalAutoHight();
        if(mOpen)
        {
            AutoAdjustWidget(mOpen);
        }
        
        if (mTwHeight != null)
        {
            if (mOpen)
            {
                mTwHeight.Play(true, true);
            }
            else
            {
                mTwHeight.Toggle();
            }
        }
    }

    public void TableOpenFinish()
    {
        //Debug.Log("Table Open Finish :" + mTableActive);
        mTableActive = false;
        mButtomOpen.transform.GetComponent<BoxCollider>().enabled = true;
        //mParentTable.Reposition();
    }

    public bool IsTableActive()
    {
        return mTableActive;
    }

    void OnDestroy()
    {
        //Debug.Log("destroy");
        EventDelegate.Remove(mTwHeight.onFinished, TableOpenFinish);
        EventDelegate.Remove(mButtomOpen.onClick, OnClickOpen);
    }

    void Update()
    {
        if (mTableActive)
        {
            var tableList = GetComponentsInChildren<UITable>();
            for (int i = 0; i < tableList.Length; i++)
            {
                tableList[i].repositionNow = true;
            }
        }
    }
}
