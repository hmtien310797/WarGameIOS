using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Clishow
{
    public class CsLevelQuadSpace : MonoBehaviour
    {
        public Serclimax.Level.ScLevelSpace RootSpace;
        public float SplitDis = 1;
        public float Width = -1;
        public float Height = -1;
        public List<Serclimax.Level.ScLevelSpace> SubSpaces = new List<Serclimax.Level.ScLevelSpace>();
        public LayerMask Mask;
        public void GetAllRect(ref List<Serclimax.QuadSpace.ScQuadRect> rect)
        {
            rect.Add(RootSpace.RootRect);
            for (int i = 0, imax = SubSpaces.Count; i < imax; i++)
            {
                rect.Add(SubSpaces[i].RootRect);
            }
        }
#if UNITY_EDITOR

        public static Collider[] GetColliderInChildren(GameObject obj)
        {
            List<Collider> colliders = new List<Collider>();
            Collider[] cols = null;
            for (int i = 0; i < obj.transform.childCount; i++)
            {
                cols = null;
                cols = obj.transform.GetChild(i).GetComponents<Collider>();
                if (cols != null && cols.Length != 0)
                {
                    colliders.AddRange(cols);
                }
                if (obj.transform.GetChild(i).childCount != 0)
                {
                    cols = GetColliderInChildren(obj.transform.GetChild(i).gameObject);
                    if (cols != null && cols.Length != 0)
                    {
                        colliders.AddRange(cols);
                    }
                }
            }
            return colliders.ToArray();

        }

        public static Bounds GetColliderBounds(GameObject obj)
        {
            bool start = false;
            Bounds bounds = new Bounds();
            Bounds b;

            Collider[] colliders = obj.GetComponentsInChildren<Collider>(true);
            for (int i = 0, imax = colliders.Length; i < imax; i++)
            {
                b = colliders[i].bounds;
                if (!start)
                {
                    bounds = b;
                    start = true;
                }
                else
                    bounds.Encapsulate(b);
            }
            return bounds;
        }

        public static Serclimax.QuadSpace.ScQuadRect ToRect(Bounds bound)
        {
            return new Serclimax.QuadSpace.ScQuadRect(bound.center.x, bound.center.z, bound.size.x, bound.size.z);
        }


        public static List<Serclimax.Level.ScLevelSpace> ToSplit(Bounds boud, GameObject obj, int uid, float split_Dis, int mask)
        {
            List<Serclimax.Level.ScLevelSpace> rects = new List<Serclimax.Level.ScLevelSpace>();
            BoxCollider[] colliders = obj.GetComponentsInChildren<BoxCollider>(true);

            int x_split = (int)((boud.max.x - boud.min.x) / split_Dis);
            int z_split = (int)((boud.max.z - boud.min.z) / split_Dis);
            List<Serclimax.Level.ScLevelSpace> xbounds = new List<Serclimax.Level.ScLevelSpace>();
            for (int i = 0, imax = x_split == 0 ? 1 : x_split; i < imax; i++)
            {
                List<Serclimax.Level.ScLevelSpace> bounds = new List<Serclimax.Level.ScLevelSpace>();
                for (int j = 0, jmax = z_split == 0 ? 1 : z_split; j < jmax; j++)
                {
                    Vector3 point = new Vector3(split_Dis * i + split_Dis * 0.5f, 20, split_Dis * j + split_Dis * 0.5f) + boud.min;
                    RaycastHit hitinfo;
                    int index = -1;
                    if (Physics.Raycast(point, Vector3.down, out hitinfo, 50, mask))
                    {
                        index = -1;
                        for (int l = 0, lmax = colliders.Length; l < lmax; l++)
                        {
                            if (colliders[l] == hitinfo.collider)
                            {
                                index = l;
                                break;
                            }
                        }
                        if (index >= 0)
                        {
                            Serclimax.Level.ScLevelSpace space = new Serclimax.Level.ScLevelSpace();
                            space.RootRect = new Serclimax.QuadSpace.ScQuadRect(point.x, point.z, split_Dis, split_Dis);
                            space.Height = colliders[index].size.y;
                            space.UID = uid;
                            bounds.Add(space);
                            //rects.Add(space);
                        }
                    }
                }
                List<Serclimax.Level.ScLevelSpace> needRemoves = new List<Serclimax.Level.ScLevelSpace>();
                float cur_z = -1;
                int gIndex = -1;
                for (int g = 0; g < bounds.Count; g++)
                {
                    if (gIndex < 0)
                    {
                        cur_z = (float)bounds[g].RootRect.Y;
                        gIndex = g;
                    }
                    else
                    {
                        float z =Mathf.Abs( (float)bounds[g].RootRect.Y - cur_z);
                        if (z == split_Dis)//((z>=(split_Dis - split_Dis*0.1f)) || (z <= (split_Dis + split_Dis * 0.1f)))
                        {
                            Serclimax.QuadSpace.ScQuadRect rect = bounds[g].RootRect;
                            Serclimax.Level.ScLevelSpace space1 = bounds[gIndex];
                            Serclimax.QuadSpace.ScQuadRect rect1 = space1.RootRect;
                            rect1.Combine(ref rect);
                            space1.RootRect = rect1;
                            bounds[gIndex] = space1;
                            cur_z = (float)bounds[g].RootRect.Y;
                            needRemoves.Add(bounds[g]);
                        }
                        else
                        {
                            cur_z = (float)bounds[g].RootRect.Y;
                            gIndex = g;
                        }                       
                    }
                }

                for (int g = 0; g < needRemoves.Count; g++)
                {
                    bounds.Remove(needRemoves[g]);
                }

                for (int g = 0; g < bounds.Count; g++)
                {
                    xbounds.Add(bounds[g]);
                }
                bounds.Clear();
            }


            List<Serclimax.Level.ScLevelSpace> xneedRemoves = new List<Serclimax.Level.ScLevelSpace>();
            float cur_x = -1;
            float xcur_z = -1 ;
            float cur_h = -1;
            int xgIndex = -1;
            for (int g = 0; g < xbounds.Count; g++)
            {
                if (xgIndex < 0)
                {
                    cur_x = (float)xbounds[g].RootRect.X;
                    xcur_z = (float)xbounds[g].RootRect.Y;
                    cur_h = (float)xbounds[g].RootRect.Height;
                    xgIndex = g;
                }
                else
                {
                    float z = Mathf.Abs((float)xbounds[g].RootRect.X - cur_x);
                    if (Mathf.Abs(xcur_z - (float)xbounds[g].RootRect.Y)< split_Dis)//(Mathf.Abs( cur_x - xbounds[g].RootRect.X)< split_Dis*0.5f) &&
                    {
                        Serclimax.QuadSpace.ScQuadRect rect = xbounds[g].RootRect;
                        Serclimax.Level.ScLevelSpace space1 = xbounds[xgIndex];
                        Serclimax.QuadSpace.ScQuadRect rect1 = space1.RootRect;
                        rect1.Combine(ref rect);
                        space1.RootRect = rect1;
                        xbounds[xgIndex] = space1;
                        cur_x = (float)xbounds[g].RootRect.X;
                        xcur_z = (float)xbounds[g].RootRect.Y;
                        cur_h = (float)xbounds[g].RootRect.Height;
                        xneedRemoves.Add(xbounds[g]);
                    }
                    else
                    {
                        cur_x = (float)xbounds[g].RootRect.X;
                        xcur_z = (float)xbounds[g].RootRect.Y;
                        cur_h = (float)xbounds[g].RootRect.Height;
                        xgIndex = g;
                    }
                }
            }

            for (int g = 0; g < xneedRemoves.Count; g++)
            {
                xbounds.Remove(xneedRemoves[g]);
            }

            for (int g = 0; g < xbounds.Count; g++)
            {
                rects.Add(xbounds[g]);
            }
            xbounds.Clear();
            //for (float x = boud.min.x; x <= boud.max.x; x += split_Dis)
            //{
            //    for (float z = boud.min.z; z <= boud.max.z; z += split_Dis)
            //    {
            //        Vector3 point = new Vector3(x, 20, z);
            //        RaycastHit hitinfo;
            //        int index = -1;
            //        //if (Physics.Raycast(point, Vector3.down, out hitinfo, 50, mask))
            //        {
            //            //index = -1;
            //            //for (int i = 0, imax = colliders.Length; i < imax; i++)
            //            //{
            //            //    if (colliders[i] == hitinfo.collider)
            //            //    {
            //            //        index = i;
            //            //        break;
            //            //    }
            //            //}
            //            //if (index >= 0)
            //            {
            //                Serclimax.Level.ScLevelSpace space = new Serclimax.Level.ScLevelSpace();
            //                space.RootRect = new Serclimax.QuadSpace.ScQuadRect(x, z, split_Dis, split_Dis);
            //                space.Height = 0;// colliders[index].bounds.max.y;
            //                space.UID = uid;
            //                rects.Add(space);
            //            }

            //        }
            //    }
            //}
            return rects;
        }

        public static void FillLevelSpace(CsLevelQuadSpace root)
        {
            if (root == null)
                return;
            Bounds rootbound = new Bounds();
            Bounds bound;
            bool start = false;
            root.SubSpaces.Clear();
            List<XElementEditor> allelements = XEditorManager.instance.GetAllElements();

            for (int i = 0, imax = allelements.Count; i < imax; i++)
            {
                bound = GetColliderBounds(allelements[i].gameObject);
                List<Serclimax.Level.ScLevelSpace> rects = ToSplit(bound, allelements[i].gameObject, allelements[i].mElementUID, root.SplitDis, root.Mask);
                root.SubSpaces.AddRange(rects.ToArray());
                if (!start)
                {
                    rootbound = bound;
                    start = true;
                }
                else
                    rootbound.Encapsulate(bound);
            }
            root.RootSpace = new Serclimax.Level.ScLevelSpace();
            Serclimax.QuadSpace.ScQuadRect rect = ToRect(rootbound);
            rect.SetScale(Mathf.Max(root.Width ,(float)rect.Width),Mathf.Max(root.Height,(float)rect.Height));
            root.RootSpace.RootRect = rect;
            root.RootSpace.Height = 0;
            root.RootSpace.UID = -1;
            Debug.Log(" space count : " + root.SubSpaces.Count);
        }
#endif
    }
}