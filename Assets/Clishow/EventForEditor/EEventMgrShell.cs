using UnityEngine;
using System.Collections;
using System.Collections.Generic;
namespace Clishow
{

    public class EEventMgrShell : MonoBehaviour
    {
        public List<EBaseShell> events = new List<EBaseShell>();

        public Serclimax.Event.ScENode[] toNodes()
        {
            List<Serclimax.Event.ScENode> nodes = new List<Serclimax.Event.ScENode>();
            for (int i = 0, imax = events.Count; i < imax; i++)
            {
                IDataGet data = (IDataGet)events[i].Data;
                nodes.Add(data.GetData());
            }
            return nodes.ToArray();
        }


    }
}