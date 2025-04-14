using UnityEngine;
using System.Collections;

namespace Clishow
{

    public class ECreateDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScEDCreateUnit Data = new Serclimax.Event.ScEDCreateUnit();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScEDCreateUnit)data;
        }
    }

    public class ENormalDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScEData Data = new Serclimax.Event.ScEData();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScEData)data;
        }
    }

    public class ENodeDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScENode Data = new Serclimax.Event.ScENode();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScENode)data;
        }
    }

    public class ENatureProductionDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScEDNatureProduction Data = new Serclimax.Event.ScEDNatureProduction();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScEDNatureProduction)data;
        }
    }

    public class EConAcDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScEConAcData Data = new Serclimax.Event.ScEConAcData();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScEConAcData)data;
        }
    }

    public class EGameOverDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScGameOverEvent Data = new Serclimax.Event.ScGameOverEvent();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScGameOverEvent)data;
        }
    }
    public class ECreatBuildDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScCreatBuildEvent Data = new Serclimax.Event.ScCreatBuildEvent();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScCreatBuildEvent)data;
        }
    }
    public class ECreatUnitDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScEDCreateUnit Data = new Serclimax.Event.ScEDCreateUnit();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScEDCreateUnit)data;
        }
    }
    public class ECreatExplodeDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScCreatExplodeEvent Data = new Serclimax.Event.ScCreatExplodeEvent();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScCreatExplodeEvent)data;
        }
    }

    public class EAddBuffDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScAddBuffEvent Data = new Serclimax.Event.ScAddBuffEvent();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScAddBuffEvent)data;
        }
    }

    public class EAddPlayerInfoDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScAddPlayerInfoEvent Data = new Serclimax.Event.ScAddPlayerInfoEvent();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScAddPlayerInfoEvent)data;
        }
    }

    public class EScreenLockDataShell : ScriptableObject, IDataGet
    {
        public Serclimax.Event.ScScreenLockEvent Data = new Serclimax.Event.ScScreenLockEvent();
        public Serclimax.Event.ScENode GetData()
        {
            return Data;
        }
        public void SetData(Serclimax.Event.ScENode data)
        {
            Data = (Serclimax.Event.ScScreenLockEvent)data;
        }
    }
    public interface IDataGet
    {
        Serclimax.Event.ScENode GetData();
        void SetData(Serclimax.Event.ScENode data);
    }

    public class EEventFactory 
    {
        public static ScriptableObject CreateData(Serclimax.Event.ScDefineEventAITypes.SEAType type)
        {
            switch (type)
            {
                //case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_NODE:
                //    return ScriptableObject.CreateInstance(typeof(ENodeDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_Nature_Production:
                    return ScriptableObject.CreateInstance(typeof(ENatureProductionDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_GameOver:
                    return ScriptableObject.CreateInstance(typeof(EGameOverDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_CreateBuild:
                    return ScriptableObject.CreateInstance(typeof(ECreatBuildDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_ConditionAction:
                    return ScriptableObject.CreateInstance(typeof(EConAcDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_CreateUnit:
                    return ScriptableObject.CreateInstance(typeof(ECreatUnitDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_CreateExplode:
                    return ScriptableObject.CreateInstance(typeof(ECreatExplodeDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_AddBuff:
                    return ScriptableObject.CreateInstance(typeof(EAddBuffDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_AddPlayerInfo:
                    return ScriptableObject.CreateInstance(typeof(EAddPlayerInfoDataShell));
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_ScreenLock:
                    return ScriptableObject.CreateInstance(typeof(EScreenLockDataShell));
            }
            return null;
        }



        public static GameObject CreateEvent(Serclimax.Event.ScDefineEventAITypes.SEAType type)
        {
            GameObject obj = new GameObject();
            EBaseShell e = null;
            switch (type)
            {
                //case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_NODE:
                //    e = obj.AddComponent<EBaseShell>();
                //    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_Nature_Production:
                    e = obj.AddComponent<ENormalShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_GameOver:
                    e = obj.AddComponent<EGameOverShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_CreateBuild:
                    e = obj.AddComponent<ECreateBuildShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_ConditionAction:
                    e = obj.AddComponent<ENormalShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_CreateUnit:
                    e = obj.AddComponent<ENormalShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_CreateExplode:
                    e = obj.AddComponent<ENormalShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_AddBuff:
                    e = obj.AddComponent<ENormalShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_AddPlayerInfo:
                    e = obj.AddComponent<ENormalShell>();
                    break;
                case Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_ScreenLock:
                    e = obj.AddComponent<ENormalShell>();
                    break;
            }
            if (e != null)
            {
                e.Type = type;
                e.Data = CreateData(type);
                return obj;
            }
            else
                return null;
        }
    }
}
