using UnityEngine;
using System.Collections;

namespace Clishow
{
    public class CsSlotTag : MonoBehaviour
    {
        public Serclimax.Unit.ScSlotNode ToSlotNode()
        {
            Serclimax.Unit.ScSlotNode node = new Serclimax.Unit.ScSlotNode();
            node.Pos = this.transform.position;
            node.Forward = this.transform.forward;
            return node;
        }
    }
}

