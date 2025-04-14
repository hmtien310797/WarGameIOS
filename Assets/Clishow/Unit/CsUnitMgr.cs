using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using System.IO;

namespace Clishow
{
    public class CsUnitMgr : CsSingletonBehaviour<CsUnitMgr>
    {
        public bool IgnoreDisposeMsg = false;

        private List<CsUnit> mUnits = new List<CsUnit>();
        private Dictionary<string, CsUnit> mGuideTargetUnits = new Dictionary<string, CsUnit>();

        public static readonly string SuccessGroupName = "BaseUs";
        public List<CsUnit> mSuccessGroupUnits = new List<CsUnit>();

        public static readonly string FailedGroupName = "BaseEnemy";
        public List<CsUnit> mFailedGroupUnits = new List<CsUnit>();

        public Serclimax.ScTableData<Serclimax.Unit.ScUnitData> UnitTable = null;
        public Serclimax.ScTableData<Serclimax.Unit.ScUnitDefenseData> BuildTable = null;
        public Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxData> UnitSfxData = null;

        private Dictionary<string, GameObject> mSourcePrefabs = new Dictionary<string, GameObject>();
        private GameObject mSfxPrefab = null;
        public GameObject UnitSfxPrefab
        {
            get
            {
                if (mSfxPrefab == null)
                {
                    mSfxPrefab = ResourceLibrary.instance.GetUnitSfxPrefab("unit_sfx");
                }
                return mSfxPrefab;
            }
        }
        public delegate void OnUnitCreated(CsUnit unit);

        public OnUnitCreated onUnitCreated;

        public delegate void OnUnitRemoved(CsUnit unit);

        public OnUnitRemoved onUnitRemoved;

        public override bool IsAutoInit()
        {
            return true;
        }

        public override bool IsGlobal()
        {
            return false;
        }

        public override void Initialize(object param = null)
        {
            base.Initialize(param);
            Serclimax.ScTableMgr gtable = param as Serclimax.ScTableMgr;
            if (gtable != null)
            {
                UnitTable = gtable.GetTable<Serclimax.Unit.ScUnitData>();
                BuildTable = gtable.GetTable<Serclimax.Unit.ScUnitDefenseData>();
                UnitSfxData = gtable.GetTable<Serclimax.Unit.ScUnitSfxData>();
            }
        }

        public override void OnDestroy()
        {
            base.OnDestroy();
            for (int i = 0; i < mUnits.Count; i++)
            {
                if (mUnits[i] != null)
                {
                    mUnits[i].DestroyUnitImmediate();
                    mUnits[i] = null;
                }
            }
            mUnits.Clear();
            onUnitRemoved = null;
            onUnitCreated = null;
        }

        public void DisposeUnitMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
        {
            if (IgnoreDisposeMsg)
                return;
            if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_UNIT_MSG)
                return;
            Serclimax.Unit.ScUnitMsg um = msg as Serclimax.Unit.ScUnitMsg;
            if (um == null)
                return;
            int i = um.GetEntityUID();
            if (i < 0 || i >= mUnits.Count)
                return;
            mUnits[i].Syncer.SyncMsg(um);
        }

        public int UnitCount
        {
            get
            {
                return mUnits.Count;
            }
        }
        public CsUnit GetGuideTargetUnit(string tag)
        {
            if (mGuideTargetUnits.ContainsKey(tag))
                return mGuideTargetUnits[tag];
            return null;
        }
        public CsUnit GetUnit(int id)
        {
            if (id < 0 || id >= mUnits.Count)
                return null;
            return mUnits[id];
        }

        public void DisposeCreateUnitMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
        {
            if (IgnoreDisposeMsg)
                return;
            if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_UNIT_MSG)
                return;
            Serclimax.Unit.ScCreateUnitMsg um = msg as Serclimax.Unit.ScCreateUnitMsg;
            if (um == null)
                return;
            if (um.SubCommands.Count != 0)
            {
                for (int i = 0, imax = um.SubCommands.Count; i < imax; i++)
                {
                    RemoveUnit4Command(um.SubCommands[i].InsID);
                }
                for (int i = 0; i < mUnits.Count;)
                {
                    if (mUnits[i] == null)
                    {
                        mUnits.RemoveAt(i);
                    }
                    else
                        i++;
                }
            }

            if (mUnits.Count < um.UnitCount)
            {
                for (int i = 0, imax = um.UnitCount - mUnits.Count; i < imax; i++)
                {
                    mUnits.Add(null);
                }
            }

            if (um.AddCommands.Count != 0)
            {
                for (int i = 0, imax = um.AddCommands.Count; i < imax; i++)
                {
                    CreateUnit4Command(um.AddCommands[i].InsID, um.AddCommands[i].TableID, um.AddCommands[i].TeamID, um.AddCommands[i].unitType, um.AddCommands[i].unitTag, um.AddCommands[i].guideTarget);
                }
            }
        }

        private void RemoveUnit4Command(int id)
        {
            CsUnit unit = mUnits[id];
            unit.DestroyUnit();
            if (onUnitRemoved != null)
            {
                onUnitRemoved(unit);
            }
            //GameObject.Destroy(unit.gameObject);
            mUnits[id] = null;
        }

        public CsUnit CreateUnit4SLG(int tableid, Serclimax.Unit.ScUnitType utype)
        {
            string name = "";
            GameObject unitObj = null;
            if (utype == Serclimax.Unit.ScUnitType.SUT_SOLDIER || utype == Serclimax.Unit.ScUnitType.SUT_CARRIER)
            {
                Serclimax.Unit.ScUnitData uInfo = UnitTable.GetData(tableid);
                if (uInfo == null)
                {
                    Debug.LogError("create unit with wrong id");
                    return null;
                }
                name = uInfo._unitPrefab;
                unitObj = ResourceLibrary.instance.GetLevelUnitInstanceFromPool(uInfo._unitPrefab, (XLevelDefine.ElementType)uInfo._unitType, Vector3.zero, Quaternion.identity);
            }
            else if ((Serclimax.Unit.ScUnitType)utype == Serclimax.Unit.ScUnitType.SUT_BUILD)
            {
                Serclimax.Unit.ScUnitDefenseData uInfo = BuildTable.GetData(tableid);
                if (uInfo == null)
                {
                    Debug.LogError("create unit with wrong id");
                    return null;
                }
                name = uInfo._unitDefensePrefab;
                if (uInfo._unitDefensePrefab.Contains("SceneObstacle"))
                {
                    unitObj = new GameObject(uInfo._unitDefensePrefab);
                    unitObj.AddComponent<CsUnit>();
                }
                else
                {
                    unitObj = ResourceLibrary.instance.GetLevelObjectInstanceFromPool(uInfo._unitDefensePrefab, (XLevelDefine.ElementType)uInfo._unitDefenseType, Vector3.zero, Quaternion.identity);
                }
            }
            CsUnit unit = unitObj.GetComponent<CsUnit>();
            if (unit == null)
            {
                Debug.LogError("Create Unit have not the 'CsUnit' Component");
                return null;
            }
            if(unit._lowModelPrefab != null)
            {
                CsBakeTagBones bones = unit._lowModelPrefab.GetComponent<CsBakeTagBones>();
                if (bones != null)
                {
                    GameObject source = null;
                    if (!mSourcePrefabs.TryGetValue(name, out source))
                    {
                        source = GameObject.Instantiate(unit._lowModelPrefab);
                        source.name = source.name.Replace("Clone", "Source");
                        source.transform.parent = this.transform;
                        source.SetActive(false);
                        mSourcePrefabs.Add(name, source);
                        CsUnitMBMgr.Instance.RegisterUnit(source);
                    }

                    unit._lowModelPrefab = source;
                }
            }
            else
            if (unit._modelPrefab != null)
            {
                CsBakeTagBones bones = unit._modelPrefab.GetComponent<CsBakeTagBones>();
                if (bones != null)
                {
                    GameObject source = null;
                    if (!mSourcePrefabs.TryGetValue(name, out source))
                    {
                        source = GameObject.Instantiate(unit._modelPrefab);
                        source.name = source.name.Replace("Clone", "Source");
                        source.transform.parent = this.transform;
                        source.SetActive(false);
                        mSourcePrefabs.Add(name, source);
                        CsUnitMBMgr.Instance.RegisterUnit(source);
                    }

                    unit._modelPrefab = source;
                }
            }

            unit.transform.parent = gameObject.transform;

            unit.InitUnit((int)utype);
            unitObj.SetActive(true);
            unit.uid = 0;
            unit.tableid = tableid;
            unit.SfxData = UnitSfxData.GetData(unit.mUnitSfxTableId);
            unit.unitTag = tag;
            unit.isBuideTarget = false;
            if (unit.mUnitAudio == null)
            {
                if (UnitSfxPrefab != null)
                {
                    GameObject sfxObj = UnityEngine.Object.Instantiate(UnitSfxPrefab) as GameObject;
                    unit.mUnitAudio = sfxObj.GetComponent<AudioSource>();
                    sfxObj.transform.parent = unit.transform;
                    sfxObj.transform.position = Vector3.zero;
                }
            }
            return unit;
        }

        private void CreateUnit4Command(int id, int tableid, int teamid, int uType, string tag, bool istarget)
        {
            string hudPath = "";
            int hudWidth = 0;
            int hudHeight = 0;
            string name = "";
            GameObject unitObj = null;
            bool mine = false;
            if ((Serclimax.Unit.ScUnitType)uType == Serclimax.Unit.ScUnitType.SUT_SOLDIER || (Serclimax.Unit.ScUnitType)uType == Serclimax.Unit.ScUnitType.SUT_CARRIER)
            {
                Serclimax.Unit.ScUnitData uInfo = UnitTable.GetData(tableid);
                if (uInfo == null)
                {
                    Debug.LogError("create unit with wrong id");
                    return;
                }
                mine = uInfo._unitType == 300;
                name = uInfo._unitPrefab;
                hudPath = uInfo._unitHpPath;
                string[] param = uInfo._unitHpSize.Split(';');
                if (param.Length == 2)
                {
                    hudWidth = int.Parse(param[0]);
                    hudHeight = int.Parse(param[1]);
                }

                unitObj = ResourceLibrary.instance.GetLevelUnitInstanceFromPool(uInfo._unitPrefab, (XLevelDefine.ElementType)uInfo._unitType, Vector3.zero, Quaternion.identity);


            }
            else if ((Serclimax.Unit.ScUnitType)uType == Serclimax.Unit.ScUnitType.SUT_BUILD)
            {
                Serclimax.Unit.ScUnitDefenseData uInfo = BuildTable.GetData(tableid);
                if (uInfo == null)
                {
                    Debug.LogError("create unit with wrong id");
                    return;
                }
                name = uInfo._unitDefensePrefab;
                if (uInfo._unitDefensePrefab.Contains("SceneObstacle"))
                {
                    unitObj = new GameObject(uInfo._unitDefensePrefab);
                    unitObj.AddComponent<CsUnit>();
                }
                else
                {
                    unitObj = ResourceLibrary.instance.GetLevelObjectInstanceFromPool(uInfo._unitDefensePrefab, (XLevelDefine.ElementType)uInfo._unitDefenseType, Vector3.zero, Quaternion.identity);
                }

                hudPath = uInfo._unitDefenseHpPath;
                string[] param = uInfo._unitDefenseHpSize.Split(';');
                if (param.Length == 2)
                {
                    hudWidth = int.Parse(param[0]);
                    hudHeight = int.Parse(param[1]);
                }
            }
            CsUnit unit = unitObj.GetComponent<CsUnit>();
            if (unit == null)
            {
                Debug.LogError("Create Unit have not the 'CsUnit' Component");
                return;
            }
            if(unit._lowModelPrefab != null)
            {
                CsBakeTagBones bones = unit._lowModelPrefab.GetComponent<CsBakeTagBones>();
                if (bones != null)
                {
                    GameObject source = null;
                    if (!mSourcePrefabs.TryGetValue(name, out source))
                    {
                        source = GameObject.Instantiate(unit._lowModelPrefab);
                        source.name = source.name.Replace("Clone", "Source");
                        source.transform.parent = this.transform;
                        source.SetActive(false);
                        mSourcePrefabs.Add(name, source);
                        CsUnitMBMgr.Instance.RegisterUnit(source);
                    }

                    unit._lowModelPrefab = source;
                }
            }
            else
            if (unit._modelPrefab != null)
            {
                CsBakeTagBones bones = unit._modelPrefab.GetComponent<CsBakeTagBones>();
                if (bones != null)
                {
                    GameObject source = null;
                    if (!mSourcePrefabs.TryGetValue(name, out source))
                    {
                        source = GameObject.Instantiate(unit._modelPrefab);
                        source.name = source.name.Replace("Clone", "Source");
                        source.transform.parent = this.transform;
                        source.SetActive(false);
                        mSourcePrefabs.Add(name, source);
                        CsUnitMBMgr.Instance.RegisterUnit(source);
                    }
                    unit._modelPrefab = source;
                }
            }

            unit.transform.parent = gameObject.transform;
            unit.unitTag = tag;
            unit.InitUnit(uType);
            unitObj.SetActive(true);
            unit.uid = id;
            unit.tableid = tableid;
            unit.SfxData = UnitSfxData.GetData(unit.mUnitSfxTableId);

            unit.isBuideTarget = istarget;
            if (unit.mUnitAudio == null)
            {
                if (UnitSfxPrefab != null)
                {
                    GameObject sfxObj = UnityEngine.Object.Instantiate(UnitSfxPrefab) as GameObject;
                    unit.mUnitAudio = sfxObj.GetComponent<AudioSource>();
                    sfxObj.transform.parent = unit.transform;
                    sfxObj.transform.position = Vector3.zero;
                }
            }


            mUnits[unit.uid] = unit;
            if (unit.isBuideTarget)
            {
                mGuideTargetUnits[unit.unitTag] = unit;
            }

            if (tag.Contains(SuccessGroupName))
            {
                unit.IsLevelImportTarget = true;
                mSuccessGroupUnits.Add(unit);
            }
            if (tag.Contains(FailedGroupName))
            {
                unit.IsLevelImportTarget = true;
                mFailedGroupUnits.Add(unit);
            }

            if (onUnitCreated != null)
            {
                onUnitCreated(unit);
            }

            if (Serclimax.Constants.SHOW_UNIT_HUD && GUIMgr.Instance != null && !tag.Contains("SLGPVP"))
            {
                if (teamid == 0 || teamid == 100)
                {
                    //no hud
                }
                else
                {
                    if (teamid % 10 != 1)
                    {
                        hudPath += "Red";
                    }

                    GameObject obj = ResourceLibrary.GetUnitHudInstanceFromPool(hudPath);
                    if (obj != null)
                    {
                        unit.HUD = obj.GetComponent<UnitHud>();
                        if (unit.HUD == null)
                        {
                            unit.HUD = obj.AddComponent<UnitHud>();
                        }
                        unit.HUD.FastLastTime = false;
                        unit.HUD.InitHp(1);
                        unit.HUD.StopAnim();
                        if (mine)
                        {
                            unit.HUD.FastLastTime = true;
                            unit.HUD.InitHp(0);
                        }
                        unit.HUD.name = unit.HUD.name + "_" + name;
                        unit.HUD.SetSize(hudWidth, hudHeight);
                        unit.HUD.SetTarget(Camera.main, unit.gameObject);

                        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
                        if (inGame != null)
                        {
                            inGame.CallFunc("AddHud", obj);
                        }

                        if (uType == (int)Serclimax.Unit.ScUnitType.SUT_BUILD)
                        {
                            unit.HUD.AlwaysShow = true;
                            unit.HUD.Show();
                        }
                        else
                        {
                            unit.HUD.AlwaysShow = false;
                            unit.HUD.Hide(true);
                        }
                    }
                }
            }
            mNeedUpdateUnits.Add(unit);
        }

        private List<CsUnit> mNeedUpdateUnits = new List<CsUnit>();

        private void UpdateUnit()
        {
#if PROFILER
            Profiler.BeginSample("CSUnit_ Update");
#endif
            for (int i = 0; i < mNeedUpdateUnits.Count;)
            {
                if (mNeedUpdateUnits[i].UpdateFromMgr())
                {
                    i++;
                }
                else
                {
                    mNeedUpdateUnits.RemoveAt(i);
                }
            }
#if PROFILER
            Profiler.EndSample();
#endif
        }

        void Update()
        {
            UpdateUnit();
        }

    }
}
