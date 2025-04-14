using UnityEngine;
using System.Collections;

public class CsGridObj
{
    public Serclimax.SLGPVP.ScGridObj griObj;
    public GameObject gameObj;
    public CsGridMap GMap;
    public float speed = 1;
    public int arriveRange = -1;
    private bool mInited = false;

    private void ForceSet(int x, int y)
    {
        if (needMoved)
            return;
        if (GMap.map.Occupying(x, y, griObj, false))
        {
            {
                mShowTargetPos = GetCenterPos();
                mNeedUpdateObj = true;
                if (x != griObj.lb_x && y != griObj.lb_y)
                {
                    AdjustStartPos();
                }
                else
                    mStartPos = nextPoint;
            }
        }
    }

    private bool EnableForceSet()
    {
        return !needMoved;
    }

    public CsGridObj(CsGridMap gmap, int size)
    {
        GMap = gmap;
        griObj = GMap.map.CreateObj(size);
        griObj.customObj = this;
        griObj.ForceeOccupiedAreaCB = ForceSet;
        griObj.EnableForceOccupiedAreaCB = EnableForceSet;
        gameObj = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        gameObj.transform.parent = GMap.transform;
        gameObj.transform.localScale = Vector3.one * size;
        mInited = false;
    }

    public void Destroy()
    {
        GameObject.Destroy(gameObj);
        GMap.map.DestroyObj(griObj);
        gameObj = null;
        griObj = null;
        GMap = null;
        mInited = false;
    }

    Vector2 pos2 = Vector2.zero;
    Vector2 pos2extra = Vector2.zero;
    Vector3 pos3 = Vector3.zero;
    public Vector3 GetCenterPos()
    {
        if (griObj.size == 1)
        {
            GMap.map.GridToWorldPos(griObj.lb_x, griObj.lb_y, ref pos2);
            pos3.x = pos2.x;
            pos3.z = pos2.y;
            return pos3;
        }
        else
        {
            GMap.map.GridToWorldPos(griObj.lb_x, griObj.lb_y, ref pos2);
            GMap.map.GridToWorldPos(griObj.lb_x + griObj.size - 1, griObj.lb_y + griObj.size - 1, ref pos2extra);
            pos3.x = (pos2.x + pos2extra.x) * 0.5f;
            pos3.z = (pos2.y + pos2extra.y) * 0.5f;

            return pos3;
        }
    }

    private void AdjustStartPos()
    {
        GMap.map.GridToWorldPos(griObj.lb_x, griObj.lb_y, ref pos2);
        pos3.x = pos2.x;
        pos3.z = pos2.y;
        mStartPos = pos3;
    }

    public bool init(int x, int y)
    {
        if (GMap.map.Occupying(x, y, griObj))
        {
            gameObj.transform.localPosition = GetCenterPos();
            AdjustStartPos();
            mOffset = gameObj.transform.localPosition - mStartPos;
            mInited = true;
        }
        return mInited;
    }

    private int mTargetX;
    private int mTargetY;
    private Vector3 mTargetPos;
    private Vector3 mStartPos;
    private Vector3 mOffset;
    private Vector3 mDir;
    private bool mNeedMoved = false;

    public bool needMoved
    {
        get
        {
            return mNeedMoved;
        }
    }
    private bool mNeedUpdateObj = false;
    private Vector3 mShowTargetPos;
    private Vector3 mNextTargetPos;
    private bool mHadNextPos = false;

    private int mTargetRange = 5;

    public bool SetTargetPoint(int x, int y)
    {
        if (!mInited)
            return false;
        mNeedMoved = false;
        griObj.influence = 0;
        if (GMap.map.ContainGrid(griObj, x, y))
            return true;
        mTargetX = x;
        mTargetY = y;
        GMap.map.GridToWorldPos(x, y, ref pos2);
        mTargetPos.x = pos2.x;
        mTargetPos.z = pos2.y;
        mAdjustCount = 0;
        mAdjustTime = 0;
        if (arriveRange < 0)
            arriveRange = griObj.size;
        //AdjustStartPos();
        griObj.influence = 1;
        mExtraForceTime = 0;
        mExtraForce = Vector3.zero;
        mNeedMoved = true;
        return false;
    }

    void UpdateLogicPos(float _dt)
    {
        if (!mNeedMoved)
        {
            return;
        }
        if (mHadNextPos)
            return;
        //UpdateExtraForce(_dt);
        int tcenterX = mTargetX - mTargetRange / 2;
        int tcenterY = mTargetY - mTargetRange / 2;
        if (GMap.map.ContainGrid(tcenterX, tcenterY, mTargetRange, griObj.lb_x, griObj.lb_y))
        {
            Stop();
            return;
        }
        GMap.map.GridToWorldPos(griObj.lb_x, griObj.lb_y, ref pos2);
        pos3.x = pos2.x;
        pos3.z = pos2.y;
        mDir = (mTargetPos - pos3).normalized + mExtraForce;
        offset = mDir * GMap.unit_size;//speed * _dt;
        nextPoint = mStartPos + offset;

        pos2.x = nextPoint.x;
        pos2.y = nextPoint.z;
        int nextx = 0, nexty = 0;
        GMap.map.WorldToGridPos(pos2, ref nextx, ref nexty);
        if (GMap.map.Occupying(nextx, nexty, griObj, false))
        {
            if (offset.sqrMagnitude <= 0)
            {
                Stop();
                return;
            }
            else
            {
                mNextTargetPos = GetCenterPos();
                mHadNextPos = true;
                if (nextx != griObj.lb_x && nexty != griObj.lb_y)
                {
                    AdjustStartPos();
                }
                else
                    mStartPos = nextPoint;
            }
        }
        else
        {
            mAdjustTime += _dt;
            if (mAdjustTime > 0.25f)
            {
                mAdjustTime = 0;
                mAdjustCount++;
                if (mAdjustCount >= 3)
                {
                    if (!GMap.map.TryForceOccupiedArea(nextx, nexty, griObj))
                    {

                        Stop();
                        return;
                    }
                    else
                    {
                        mAdjustCount = 0;
                    }
                }
                if (GMap.map.Occupying(nextx, nexty, griObj, true))
                {
                    mNextTargetPos = GetCenterPos();
                    mHadNextPos = true;
                    if (nextx != griObj.lb_x && nexty != griObj.lb_y)
                    {
                        AdjustStartPos();
                    }
                    else
                        mStartPos = nextPoint;
                }
            }
        }
    }

    void UpdateObj(float _dt)
    {
        if (!mNeedUpdateObj)
        {
            if (mHadNextPos)
            {
                mShowTargetPos = mNextTargetPos;
                mHadNextPos = false;
                mNeedUpdateObj = true;
            }
            return;
        }

        Vector3 dir = (mShowTargetPos - gameObj.transform.localPosition);
        if (dir.sqrMagnitude < speed * 0.01f)
        {
            mNeedUpdateObj = false;
            if (mNeedMoved)
            {
                if (mHadNextPos)
                {
                    mShowTargetPos = mNextTargetPos;
                    mHadNextPos = false;
                    mNeedUpdateObj = true;
                }
            }
            else
                gameObj.transform.localPosition = mShowTargetPos;
            return;
        }
        temp = gameObj.transform.localPosition + dir.normalized * speed * _dt;

        if (Vector3.Dot(temp - gameObj.transform.localPosition, mShowTargetPos - gameObj.transform.localPosition) > 0)
        {
            gameObj.transform.localPosition = Vector3.Lerp(gameObj.transform.localPosition, temp, 0.25f);
        }
        else
        {
            mNeedUpdateObj = false;
            if (mNeedMoved)
            {
                if (mHadNextPos)
                {
                    mShowTargetPos = mNextTargetPos;
                    mHadNextPos = false;
                    mNeedUpdateObj = true;
                }
            }
            else
                gameObj.transform.localPosition = mShowTargetPos;
        }
    }

    Vector3 nextPoint = Vector3.zero;
    Vector3 temp = Vector3.zero;
    Vector3 offset;

    float mAdjustTime = 0;
    int mAdjustCount = 0;
    Vector3 mExtraForce = Vector3.zero;
    float mExtraForceTime = 0;
    int mExtraForceX = 0;
    int mExtraForceY = 0;
    public void UpdateExtraForce(float _dt)
    {
        if (mExtraForceTime <= 0)
        {
            int force = 0;
            if (GMap.map.CalRepellingForceInRound(griObj, mTargetX - griObj.lb_x, mTargetY - griObj.lb_y, ref force, ref mExtraForceX, ref mExtraForceY))
            {
                mExtraForce.x = mExtraForceX;
                mExtraForce.z = mExtraForceY;
                mExtraForce = mExtraForce.normalized;
                mExtraForceTime = force * 0.5f;
            }
            else
            {
                mExtraForceTime = 0;
                mExtraForce.x = 0;
                mExtraForce.z = 0;
            }
        }
        else
        {
            mExtraForceTime -= _dt;
        }
    }

    public void Update(float _dt)
    {
        if (!mInited)
            return;
        UpdateObj(_dt);
        UpdateExtraForce(_dt);
        UpdateLogicPos(_dt);
    }

    //public void UpdateMove(float _dt)
    //{
    //    if (!mInited)
    //        return;
    //    UpdateObj(_dt);
    //    if (!mNeedMoved)
    //    {
    //        return;
    //    }
    //    if(mNeedUpdateObj)
    //        return;
    //    UpdateExtraForce(_dt);


    //    int tcenterX = mTargetX - mTargetRange/2;
    //    int tcenterY = mTargetY - mTargetRange/2;
    //    if (GMap.map.ContainGrid(tcenterX, tcenterY, mTargetRange, griObj.lb_x, griObj.lb_y))
    //    {
    //        Stop();
    //        return;
    //    }
    //    //if (GMap.map.Contain(griObj.lb_x, griObj.lb_y, griObj.size, mTargetX, mTargetY))
    //    //{
    //    //    Stop();
    //    //    return;
    //    //}
    //    GMap.map.GridToWorldPos(griObj.lb_x, griObj.lb_y, ref pos2);
    //    pos3.x = pos2.x;
    //    pos3.z = pos2.y;
    //    mDir = (mTargetPos - pos3).normalized + mExtraForce;
    //    offset = mDir * speed * _dt;
    //    nextPoint = mStartPos + offset;

    //    pos2.x = nextPoint.x;
    //    pos2.y = nextPoint.z;
    //    int nextx = 0, nexty = 0;
    //    GMap.map.WorldToGridPos(pos2, ref nextx, ref nexty);
    //    if (GMap.map.Occupying(nextx, nexty, griObj, false))
    //    {
    //        if (offset.sqrMagnitude <= 0)
    //        {
    //            Stop();
    //            return;
    //        }
    //        else
    //        {
    //            mShowTargetPos = GetCenterPos();
    //            mNeedUpdateObj = true;
    //            if (nextx != griObj.lb_x && nexty != griObj.lb_y)
    //            {
    //                AdjustStartPos();
    //            }
    //            else
    //                mStartPos = nextPoint;
    //        }
    //    }
    //    else
    //    {

    //        //mAdjustTime += _dt;
    //        //if (mAdjustTime > 1)
    //        //{
    //        //    mAdjustTime = 0;
    //        //    mAdjustCount++;
    //        //    if (!GMap.map.ClearRange(nextx, nexty, griObj))
    //        //    {
    //        //        if (mAdjustCount > 10)
    //        //        {
    //        //            Stop();
    //        //            return;
    //        //        }

    //        //    }
    //        //}

    //        //else
    //        //{
    //        //    if (offset.sqrMagnitude <= 0)
    //        //    {
    //        //        Stop();
    //        //        return;
    //        //    }
    //        //    else
    //        //    {
    //        //        mShowTargetPos = GetCenterPos();
    //        //        mNeedUpdateObj = true;
    //        //        if (nextx != griObj.lb_x && nexty != griObj.lb_y)
    //        //        {
    //        //            AdjustStartPos();
    //        //        }
    //        //        else
    //        //            mStartPos = nextPoint;
    //        //    }
    //        //}
    //        //Serclimax.SLGPVP.GridObj girdObj = GMap.map.GetMapObj(failed_guid);
    //        //if (griObj != null)
    //        //{
    //        //    CsGridObj gobj = griObj.customObj as CsGridObj;
    //        //    if (gobj != null)
    //        //    {
    //        //        if (!gobj.needMoved)
    //        //        {
    //        //            Stop();
    //        //            return;
    //        //        }
    //        //    }
    //        //}

    //        mAdjustTime += _dt;
    //        if (mAdjustTime > 0.25f)
    //        {
    //            mAdjustTime = 0;
    //            //int tcenterX = mTargetX -mTargetRange/2;
    //            //int tcenterY = mTargetY -mTargetRange/2;
    //            //if (GMap.map.Contain(tcenterX, tcenterY, mTargetRange, griObj.lb_x, griObj.lb_y))
    //            //{
    //            //    mAdjustCount++;
    //            //}


    //            //if (GMap.map.Contain(mTargetX, mTargetY, 10, griObj.lb_x, griObj.lb_y))
    //            //{
    //            //    mAdjustCount++;
    //            //}
    //            //else
    //            //    mAdjustCount = 0;


    //            mAdjustCount++;
    //            if (mAdjustCount >= 3)
    //            {
    //                if (!GMap.map.TryForceOccupiedArea(nextx, nexty, griObj))
    //                {

    //                    Stop();
    //                    return;


    //                }
    //                else
    //                {
    //                    mAdjustCount = 0;
    //                }
    //            }
    //            if (GMap.map.Occupying(nextx, nexty, griObj, true))
    //            {
    //                mShowTargetPos = GetCenterPos();
    //                mNeedUpdateObj = true;
    //                if (nextx != griObj.lb_x && nexty != griObj.lb_y)
    //                {
    //                    AdjustStartPos();
    //                }
    //                else
    //                    mStartPos = nextPoint;
    //            }
    //            //else
    //            //{
    //            //    girdObj = GMap.map.GetMapObj(failed_guid);
    //            //    if (griObj != null)
    //            //    {
    //            //        CsGridObj gobj = griObj.customObj as CsGridObj;
    //            //        if (gobj != null)
    //            //        {
    //            //            if (!gobj.needMoved)
    //            //            {
    //            //                Stop();
    //            //                return;
    //            //            }
    //            //        }
    //            //    }
    //            //}
    //        }

    //    }
    //}

    public void Stop()
    {
        if (!mInited)
            return;
        if (!mNeedMoved)
        {
            return;
        }
        griObj.influence = 0;
        mNeedMoved = false;
        mNextTargetPos = GetCenterPos();
        mHadNextPos = true;
    }
}

public class CsGridMap : MonoBehaviour
{
    [Range(1, 2048)]
    public int width;
    [Range(1, 2048)]
    public int height;

    [Range(0.001f, 100)]
    public float unit_size;

    public float speed;

    public LayerMask mouseLayer;

    public TextAsset MapData;

    private Serclimax.SLGPVP.ScGridMap mMap;
    public Serclimax.SLGPVP.ScGridMap map
    {
        get
        {
            return mMap;
        }
    }

    private System.Collections.Generic.List<CsGridObj> mObjs = new System.Collections.Generic.List<CsGridObj>();

    public void Awake()
    {
        mMap = new Serclimax.SLGPVP.ScGridMap();
        if (MapData == null)
        {
            Vector2 pos = transform.position;
            pos.y = transform.position.z;
            map.Init(width, height, unit_size, pos);
        }
        else
        {
            map.Init(MapData.text);
        }
    }

    public bool AddObj(int cx, int cy, int w, int h, int size)
    {
        //int size = Random.Range(1, 4);
        CsGridObj gridObj = new CsGridObj(this, size);
        int x = cx + Random.Range(0, w - 1);
        int y = cy + Random.Range(0, h - 1);
        if (!gridObj.init(x, y))
        {
            if (mMap.FindValidityPosInRound(x, y, gridObj.griObj.size, gridObj.griObj, ref x, ref y))
            {
                gridObj.init(x, y);
            }
            else
            {
                bool find = false;
                for (int i = 0, imax = mObjs.Count; i < imax; i++)
                {
                    if (mMap.FindValidityPosInRound(mObjs[i].griObj, gridObj.griObj, ref x, ref y))
                    {
                        gridObj.init(x, y);
                        find = true;
                    }
                    if (find)
                        break;
                }
                if (!find)
                {
                    Debug.Log("ADD Obj Failed！！！！！！！！！！: " + size.ToString() + "," + x + "," + y);
                    gridObj.Destroy();
                    return false;
                }
            }
        }
        Debug.Log("ADD Obj: " + gridObj.griObj.guid + "," + size.ToString() + "," + x + "," + y);
        gridObj.speed = speed;
        gridObj.arriveRange = gridObj.griObj.size * 2 + 1;
        // gridObj.SetTargetPoint(0,0);
        mObjs.Add(gridObj);
        return true;
    }

    public void AddObjs(int cx, int cy, int w, int h, int count, int size)
    {
        int csx = cx - w / 2;
        int csy = cy - h / 2;
        int remain = count;
        for (int i = 0; i < count; i++)
        {
            if (!AddObj(csx, csy, w, h, size))
            {
                break;
            }
            else
            {
                remain--;
            }
        }
        if (remain == 0)
            return;
        AddObjs(cx, cy, w + w / 2, h + h / 2, remain, size);
    }

    // Use this for initialization
    void Start()
    {

    }

    Vector3 MouseRay()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hitInfo;
        if (Physics.Raycast(ray, out hitInfo, 1000, mouseLayer.value))
            return hitInfo.point;
        return Vector3.zero;
    }

    public void UpdateObj()
    {
        for (int i = 0, imax = mObjs.Count; i < imax; i++)
        {
            mObjs[i].Update(Time.deltaTime);
        }
    }

    public void MoveTo(int x, int y)
    {
        int s = Mathf.CeilToInt(Mathf.Sqrt(mObjs.Count)) * 2;
        int tx = x - s / 2;
        int ty = y - s / 2;
        for (int i = 0, imax = mObjs.Count; i < imax; i++)
        {

            mObjs[i].SetTargetPoint(tx + Random.Range(0, s), ty + Random.Range(0, s));
        }
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            AddObj(0, 0, width, height, Random.Range(1, 4));
        }
        if (Input.GetKeyDown(KeyCode.W))
        {
            AddObjs(15, 15, 10, 30, 9, Random.Range(1, 4));
        }

        if (Input.GetKeyDown(KeyCode.D))
        {
            for (int i = 0, imax = mObjs.Count; i < imax; i++)
            {
                mObjs[i].Stop();
            }
        }

        if (Input.GetKeyDown(KeyCode.S))
        {
            if (mObjs.Count != 0)
            {
                CsGridObj obj = mObjs[0];
                mObjs.RemoveAt(0);
                obj.Destroy();
            }
        }
        if (Input.GetMouseButtonDown(1))
        {
            int tx = 0, ty = 0;
            Vector3 pos = MouseRay();
            Vector2 pos2 = Vector2.zero;
            pos2.x = pos.x;
            pos2.y = pos.z;
            mMap.WorldToGridPos(pos2, ref tx, ref ty);
            AddObjs(tx, ty, 10, 30, 9, Random.Range(1, 4));
            //for (int i = 0, imax = mObjs.Count; i < imax; i++)
            //{
            //    mObjs[i].SetTargetPoint(tx, ty);
            //}

        }
        if (Input.GetMouseButtonDown(0))
        {
            int tx = 0, ty = 0;
            Vector3 pos = MouseRay();
            Vector2 pos2 = Vector2.zero;
            pos2.x = pos.x;
            pos2.y = pos.z;
            mMap.WorldToGridPos(pos2, ref tx, ref ty);
            //MoveTo(tx, ty);
            for (int i = 0, imax = mObjs.Count; i < imax; i++)
            {
                mObjs[i].SetTargetPoint(tx, ty);
            }

        }
        UpdateObj();
    }


}
