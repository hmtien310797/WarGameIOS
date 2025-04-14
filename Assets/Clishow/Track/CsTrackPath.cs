using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class CsTrackPath : MonoBehaviour
{
    public Color PathColor;

    public List<Transform> nodeTrf = new List<Transform>();

    private List<Vector3> mNodes = new List<Vector3>();

    public List<Vector3> nodes
    {
        get
        {
            mNodes.Clear();
            for(int i =0,imax = nodeTrf.Count;i<imax;i++)
            {
                mNodes.Add(nodeTrf[i].position);
            }
            return mNodes;
        }
    }
}
