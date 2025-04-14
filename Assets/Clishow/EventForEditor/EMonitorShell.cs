//using UnityEngine;
//using System.Collections;
//using System.Collections.Generic;
//using Serclimax.Event;

//namespace Clishow
//{
//    public class EMonitorShell : EBaseShell
//    {
//        public List<EBaseShell> Monitors = new List<EBaseShell>();
//        public List<EBaseShell> Results = new List<EBaseShell>();

//        public override void RefreshData()
//        {
//            base.RefreshData();
//            IDataGet ed = Data as IDataGet;
//            if (ed != null)
//            {
//                Serclimax.Event.ScEMata data = ed.GetData() as Serclimax.Event.ScEMata;
//                if (data.Monitors == null)
//                {
//                    data.Monitors = new List<long>();
//                }
//                else
//                    data.Monitors.Clear();

//                for (int i = 0; i < this.Monitors.Count;)
//                {
//                    if (this.Monitors[i] != null)
//                    {
//                        data.Monitors.Add((long)this.Monitors[i].index);
//                        i++;
//                    }
//                    else
//                    {
//                        Monitors.RemoveAt(i);
//                    }
//                }

//                if (data.Results == null)
//                {
//                    data.Results = new List<long>();
//                }
//                else
//                    data.Results.Clear();

//                for (int i = 0; i < this.Results.Count;)
//                {
//                    if (this.Results[i] != null)
//                    {
//                        data.Results.Add((long)this.Results[i].index);
//                        i++;
//                    }
//                    else
//                    {
//                        this.Results.RemoveAt(i);
//                    }
//                }

//            }
//        }

//        public override void FillData()
//        {
//            base.FillData();
//            IDataGet ed = Data as IDataGet;
//            if (ed != null)
//            {
//                Serclimax.Event.ScEMata edata = ed.GetData() as Serclimax.Event.ScEMata;
//                if (edata.Monitors != null && edata.Monitors.Count != 0)
//                {
//                    Monitors.Clear();
//                    for (int i = 0, imax = edata.Monitors.Count; i < imax; i++)
//                    {
//                        Monitors.Add( Mgr.events[(int)edata.Monitors[i]]);
//                    }
//                }
//                if (edata.Results != null && edata.Results.Count != 0)
//                {
//                    Results.Clear();
//                    for (int i = 0, imax = edata.Results.Count; i < imax; i++)
//                    {
//                        Results.Add(Mgr.events[(int)edata.Results[i]]);
//                    }
//                }
//            }
//        }
//    }

//}


