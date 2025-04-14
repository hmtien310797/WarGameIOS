using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax.Event;

namespace Clishow
{

    public class ENormalShell : EBaseShell
    {

        public override void RefreshData()
        {
            base.RefreshData();
            IDataGet ed = Data as IDataGet;
            if (ed != null)
            {
                Serclimax.Event.ScEData data = ed.GetData() as Serclimax.Event.ScEData;
                data.Pos = new Serclimax.Event.ScVector3(this.transform.position);

                data.Dir = new Serclimax.Event.ScVector3(this.transform.forward);
            }
        }

        public override void FillData()
        {
            base.FillData();
            IDataGet ed = Data as IDataGet;
            if (ed != null)
            {
                Serclimax.Event.ScEData edata = ed.GetData() as Serclimax.Event.ScEData;
                
                this.transform.localPosition = this.transform.parent.InverseTransformPoint(edata.Pos.ToUVe3());
                this.transform.forward = this.transform.parent.InverseTransformDirection(edata.Dir.ToUVe3());
            }
        }
    }
}
