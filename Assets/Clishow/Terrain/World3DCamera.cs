using UnityEngine;
using System.Collections;

public class World3DCamera : MonoBehaviour
{
    //public Transform target;
    public World world;
    
    //public WorldUI worldUI;
    public float speed = 1f;
    // Use this for initialization

    //相机视口区域数据
    public int width = 30;
    public int height = 30;
    public int offetHeight = 0;
    public int offetWidth = 0;
    public Vec2Int CenterPos;
    public Vector3 TCenterPos;
    public Vec2Int SelectPos;
    QuadRect CheckRect;
    public QuadRect CurdRect;
    public QuadRect OldCurdRect;
    public QuadRect WCurdRect;
    

    public bool isFollow = false;
    public Transform FollowTransfrom;
    Vector3 tmpFollow;
    
    public int ViewWidth
    {
        get
        {
            //return Mathf.RoundToInt(world.BuildRangeQuality*width);
            return width;
        }
    }
    public int ViewHeight
    {
        get
        {
            //return Mathf.RoundToInt(world.BuildRangeQuality*height);
            return height;
        }
    }

    void Start()
    {
        //worldUI.world = world;
        CheckRect = new QuadRect(0, 0, ViewWidth * 0.25f, ViewHeight * 0.25f);
        CurdRect = new QuadRect(0, 0, ViewWidth, ViewHeight);
        WCurdRect = new QuadRect(0,0,ViewWidth*world.WorldInfo.LogicBlockSize,ViewHeight*world.WorldInfo.LogicBlockSize);
    }

    // Update is called once per frame
    void Update()
    {
        if (world != null && world.Vaild)
        {
            world.UpdateWorld(this.transform.position);

            CheckUpdate();
        }

        //if (world.worldMapNet.pathData.SEntryPathInfo.Count > 0) {
        //    if (Input.GetMouseButtonUp(0))
        //    {
        //        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);               
        //        RaycastHit hit;
        //        if (Physics.Raycast(ray, out hit))
        //        {
        //            Debug.DrawLine(ray.origin, hit.point, Color.red);
        //            Debug.Log(hit.collider.transform.parent.name);
        //        }
        //    }
        //}
    
    }
    
    public void CameraMove(Vector3 delta) {
        Vector3 s = delta * speed * Time.deltaTime * 0.2f;
        if (world.WCamera.transform.localEulerAngles.y != 0) {
            Matrix4x4 m = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(0, world.WCamera.transform.localEulerAngles.y, 0), new Vector3(1, 1, 1));
            s = m.MultiplyPoint(s);
        }
        this.transform.position += s * -1;
        //world.worldMapUpdata.worldMapBuild.UpdateBuildUIOnMove();
    }

    void CheckUpdate() {
        CurdRect = ViewRect(false);
        //if (!WorldData.RectContains(CheckRect, CenterPos.x + offetWidth, CenterPos.y + offetHeight))
        //{

        //CheckRect.SetPos(CenterPos.x + offetWidth, CenterPos.y + offetHeight);
        //更新
       
        if (CurdRect.X == OldCurdRect.X && CurdRect.Y == OldCurdRect.Y)
            return;
        world.worldMapUpdata.UpdateBuild(CurdRect);
        world.worldMapUpdata.UpdateTerritory(CurdRect);
        OldCurdRect = CurdRect;
        //}
    }
    
    

    public QuadRect ViewRect(bool isFrist) {
        
        CenterPos = world.WorldInfo.LBlockMap.WorldPos2WLogicPos(transform.localPosition, world.WorldInfo);

        //WorldMapMgr.Instance.CenterX = CenterPos.x;
        //WorldMapMgr.Instance.CenterY = CenterPos.y;
        CurdRect.SetPos(CenterPos.x + offetWidth, CenterPos.y + offetHeight);
        Vector3 wpos = Vector3.zero;
        world.WorldInfo.LBlockMap.WLogicPos2WorldPos(ref wpos,ref CenterPos,world.WorldInfo);
        WCurdRect.SetPos(wpos.x + offetWidth, wpos.z + offetHeight);
        //if(isFrist)
        //    CheckRect.SetPos(CenterPos.x + offetWidth, CenterPos.y + offetHeight);

        return CurdRect;
    }

    public Vector3 Intersect(Ray ray, Vector3 plane_normal, out float t)
    {
        t = -1 * (Vector3.Dot(plane_normal, ray.origin)) / Vector3.Dot(plane_normal, ray.direction);
        return ray.origin + ray.direction * (t - world.BaseTerrainHeight);
    }
}
