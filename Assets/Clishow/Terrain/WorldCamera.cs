//using UnityEngine;
//using System.Collections;

//public class WorldCamera : MonoBehaviour
//{
//    public Transform target;
//    public World world;
//    public WorldUI worldUI;
//    public float speed = 1;
//    // Use this for initialization
//    void Start()
//    {
//        worldUI.world = world;
//    }
//    private Vector3 oldpos;
//    Vector3 pos = Vector3.zero;
//    // Update is called once per frame

//    Vector3[] line_pos = new Vector3[2];
//    int lineIndex = 0;
//    void Update()
//    {
//        Vector3 s = Vector3.zero;
//        Vector3 delta = Vector3.zero;
//        if (Input.GetMouseButtonDown(0))
//        {
//            pos = Input.mousePosition;
//        }

//        if (Input.GetMouseButton(0))
//        {
//            target.gameObject.SetActive(false);
//            oldpos = pos;
//            pos = Input.mousePosition;
//            delta = pos - oldpos;
//            delta.x = -1 * delta.x;
//            delta.z = -1 * delta.y;
//            delta.y = 0;
//            s = delta * speed * Time.deltaTime * 0.2f;
//            this.transform.position += s;
//        }
//        if (Input.GetKey(KeyCode.W))
//        {
//            s = Vector3.forward * speed * Time.deltaTime;
//            this.transform.position += s;
//        }
//        if (Input.GetKey(KeyCode.S))
//        {
//            s = Vector3.back * speed * Time.deltaTime;
//            this.transform.position += s;
//        }
//        if (Input.GetKey(KeyCode.A))
//        {
//            s = Vector3.left * speed * Time.deltaTime;
//            this.transform.position += s;
//        }
//        if (Input.GetKey(KeyCode.D))
//        {
//            s = Vector3.right * speed * Time.deltaTime;
//            this.transform.position += s;
//        }

//        if (Input.GetKeyDown(KeyCode.X))
//        {
//            world.WorldInfo.ClearAllSprites();
//            world.WorldInfo.UpdateAllSpritesMesh();
//        }
//        if (Input.GetKeyDown(KeyCode.C))
//        {
//            world.WorldInfo.UpdateAllSpritesMesh();
//        }


//        if (target != null)
//        {
//            if (Input.GetMouseButtonUp(0))
//            {
//                if ((Input.mousePosition - pos).sqrMagnitude < 0.5)
//                {
//                    target.gameObject.SetActive(true);
//                    Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
//                    Debug.DrawLine(ray.origin, ray.origin + ray.direction * 1000, Color.white);
//                    float t = 0;
//                    Vector3 p = world.GetRay2Terrain(ray);//Intersect(ray, Vector3.up, out t);
//                    if (worldUI.DeleteSpriteTag)
//                    {
//                        world.HideSprites(p);
//                        int type = world.SetBuild(p,100+Random.Range(0,5));
//                        Debug.Log("Set Build "+type);
//                        world.ApplySMC(0);
//                        worldUI.SetTips("选择局部位置：" + LogicBlockSet.curHidePoint.x + ":" + LogicBlockSet.curHidePoint.y);
//                    }
//                    if (worldUI.Occupy)
//                    {
//                        world.SetTerritory(p, 1);
//                        worldUI.SetTips("选择局部位置：" + LogicBlockSet.curHidePoint.x + ":" + LogicBlockSet.curHidePoint.y);
//                    }
//                    p = world.World2TerrainPos(p);
//                    if(worldUI.EnableLine)
//                    {
//                        if(lineIndex >= 1)
//                        {
//                            line_pos[lineIndex] = p;
//                            line_pos[lineIndex].y = 12.5f;
//                            lineIndex = 0;
//                            //world.WorldInfo.AddLine(0,line_pos[0],line_pos[1],Random.ColorHSV(),Random.Range(2.0f,30.0f),0,0,0,Random.Range(20,60),null,null);
//                            //world.WorldInfo.ApplyLine();
//                        }
//                        else
//                        {
//                            line_pos[lineIndex] = p;
//                            line_pos[lineIndex].y = 12.5f;
//                            lineIndex ++;
//                        }
//                    }
                   
                    
//                    //world.WorldInfo.ShowSelectRect(p, 1);

//                    //p.y = world.WorldInfo.GetTerrainHeight(p);
//                    p = CurvedWorld_Controller.get.TransformPoint(p,BEND_TYPE.Universal);
//                    target.transform.position = p;
//                }
//            }
//        }

//        if (world != null)
//        {
//            world.UpdateWorld(this.transform.position);
//        }
//    }

//    Vector3 Intersect(Ray ray, Vector3 plane_normal, out float t)
//    {
//        t = -1 * (Vector3.Dot(plane_normal, ray.origin)) / Vector3.Dot(plane_normal, ray.direction);
//        return ray.origin + ray.direction * (t - world.BaseTerrainHeight);
//    }
//}
