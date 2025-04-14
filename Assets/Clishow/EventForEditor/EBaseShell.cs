using UnityEngine;
using System.Collections;

namespace Clishow
{
    public class EBaseShell : ETrfTag
    {
        [System.NonSerialized]
        public bool isDestroy = false;

        [System.NonSerialized]
        public int index;
        [System.NonSerialized]
        public EEventMgrShell Mgr;

        public Serclimax.Event.ScDefineEventAITypes.SEAType Type;
        public ScriptableObject Data;

        public virtual void RefreshData()
        {
            if (Data == null)
            {
                Data = EEventFactory.CreateData(Type);
            }
            IDataGet ed = Data as IDataGet;
            if (ed != null)
            {
                Serclimax.Event.ScENode data = ed.GetData() as Serclimax.Event.ScENode;
                data.id =(long) index;
                data.TypeID = (long)Type;
                data.Enabled = this.gameObject.activeSelf;
                data.Name = this.gameObject.name;
            }
        }

        public virtual void FillData()
        {
            if (Data == null)
            {
                Data = EEventFactory.CreateData(Type);
            }
            IDataGet ed = Data as IDataGet;
            if (ed != null)
            {
                Serclimax.Event.ScENode edata = ed.GetData() as Serclimax.Event.ScENode;
                index = (int)edata.id;
                Type = (Serclimax.Event.ScDefineEventAITypes.SEAType)(int)edata.TypeID;
                this.gameObject.SetActive(edata.Enabled);
                this.gameObject.name = edata.Name;
            }
        }

        protected virtual void OnDestroy()
        {
            isDestroy = true;
        }
    }
}

