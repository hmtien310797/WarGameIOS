using UnityEngine;
using System.Collections;
using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;
#endif


namespace Clishow.Simulate
{
#if UNITY_EDITOR
    [System.Serializable]
    public class SMUnit : ScriptableObject
    {
        public Serclimax.Unit.ScUnit Unit = null;

        public Serclimax.Unit.ScUnitData UnitData = null;
        public Serclimax.Unit.ScUnitDefenseData UBuildData = null;
        public Serclimax.Unit.ScUnitType uType = Serclimax.Unit.ScUnitType.SUT_NIL;

        public Serclimax.Unit.ScUnitDefenseData BuildData = null;

        public List<Serclimax.Skill.ScSkillWeaponOperator> Skills = new List<Serclimax.Skill.ScSkillWeaponOperator>();

        public void init(Serclimax.Unit.ScUnit unit)
        {
            Unit = unit;
            if(unit.UnitType == Serclimax.Unit.ScUnitType.SUT_SOLDIER || unit.UnitType == Serclimax.Unit.ScUnitType.SUT_CARRIER)
                UnitData = unit.SoldierAttribute.UnitData;
            else
            if (unit.UnitType == Serclimax.Unit.ScUnitType.SUT_BUILD)
                BuildData = unit.BuildAttribulte.DefenseData;
            for (int i = 0; i < Unit.UnitAttribute.SkillOperators.Count; i++)
            {
                Skills.Add((Serclimax.Skill.ScSkillWeaponOperator)Unit.UnitAttribute.SkillOperators[i]);
            }
        }
    }

    public class SimulateEditorRoot : MonoBehaviour
    {
        public LayerMask RootMask;
        private int CreateUnitID;
        private int TeamID;

        private int CureateUnitIDIndex = 0;
        private int TeamIDindex = 0;
        private int CreateBuildIDIndex = 0;
        private int CreateUnitType = 0;

        private int[] TeamGroups = new int[] { 1, 2, 200 };
        private string[] TeamGroupNames = new string[] { "RED", "BULE", "GREEN" };
        private string[] UnitTypesName = new string[] { "Unit", "Defense", "Explode" };

        private int[] UnitIDs = null;
        private string[] UnitNames = null;
        private int[] UnitBuildIDs = null;
        private string[] UnitBuildNames = null;

        private int[] ExplodeIDs = null;
        private string[] ExplodeNames = null;


        public Serclimax.ScTableMgr gScTableData = null;

        public TextAsset Astar = null;
        public GameObject Tag = null;

        private Serclimax.NiceAstarPath mAstar;

        public Serclimax.ScRoot mScRoot = null;

        bool isDelete = false;

        bool isSelect = false;

        private SimulateWindow mWindow = null;

        private bool mEnableOnGui = true;

        public void Awake()
        {
            //creat scRoot
            gScTableData = new Serclimax.ScTableMgr();
            gScTableData.Init();
            mScRoot = new Serclimax.ScRoot(CsDisDaCenter.Instance.DisCenter, gScTableData, 0,0,100, 100);
            if (mScRoot != null)
            {
                mAstar = new Serclimax.NiceAstarPath();
                mAstar.Awake(GetMapPath());
                mScRoot.Astar = mAstar;
                mScRoot.EventDataset = null;
                mScRoot.LevelData = null;
                mScRoot.Initialize();
            }
            CsUnitMgr.Instance.Initialize(gScTableData);
            CsUnitMgr.Instance.UnitTable = gScTableData.GetTable<Serclimax.Unit.ScUnitData>();
            CsUnitMgr.Instance.BuildTable = gScTableData.GetTable<Serclimax.Unit.ScUnitDefenseData>();
            CsUnitMgr.Instance.UnitSfxData = gScTableData.GetTable<Serclimax.Unit.ScUnitSfxData>();
            AudioManager.Instance.mUnitSfxCountData = gScTableData.GetTable<Serclimax.Unit.ScUnitSfxCountData>();
            CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_UNIT_MSG, CsUnitMgr.Instance.DisposeUnitMsg);
            CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_UNIT_MSG, CsUnitMgr.Instance.DisposeCreateUnitMsg);
            CsSkillMgr.Instance.Initialize();
            CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_SKILL_MSG, CsSkillMgr.Instance.DisposeSkillMsg);
            CsDisDaCenter.Instance.DisCenter.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_SKILL_MSG, CsSkillMgr.Instance.DisposeCreateSkillMsg);
            CsDeadMgr.Instance.CorpseEffect = ResourceLibrary.instance.GetEffectInstance("CorpseEffect").GetComponent<CsCorpseEffect>();

            List<int> ids = new List<int>();
            List<string> names = new List<string>();
            foreach (KeyValuePair<int, Serclimax.Unit.ScUnitData> unit in gScTableData.GetTable<Serclimax.Unit.ScUnitData>().Data)
            {
                ids.Add(unit.Key);
                names.Add(unit.Value._unitName);
            }
            UnitIDs = ids.ToArray();
            UnitNames = names.ToArray();

            //building
            ids.Clear();
            names.Clear();
            foreach (KeyValuePair<int, Serclimax.Unit.ScUnitDefenseData> uBuild in gScTableData.GetTable<Serclimax.Unit.ScUnitDefenseData>().Data)
            {
                ids.Add(uBuild.Key);
                names.Add(uBuild.Value._unitDefenseName);
            }
            UnitBuildIDs = ids.ToArray();
            UnitBuildNames = names.ToArray();

            ids.Clear();
            names.Clear();
            foreach (KeyValuePair<int, Serclimax.Skill.ScSkillExplodeData> skill_e in gScTableData.GetTable<Serclimax.Skill.ScSkillExplodeData>().Data)
            {
                ids.Add(skill_e.Key);
                names.Add(skill_e.Value.id.ToString());
            }
            ExplodeIDs = ids.ToArray();
            ExplodeNames = names.ToArray();

        }

        public byte[] GetMapPath()
        {
            if (Astar != null)
            {
                return Astar.bytes;
            }
            return null;
        }
        RaycastHit hitinfo;
        void LateUpdate()
        {

            if (mAstar != null)
                mAstar.Update();
            UnityEngine.Profiling.Profiler.BeginSample("SCROOT");
            if (mScRoot != null)
                mScRoot.Update(UnityEngine.Time.deltaTime);
            UnityEngine.Profiling.Profiler.EndSample();

            if ((Input.mousePosition.y / ((float)Screen.height)) < 0.7f)
            {
                if (isSelect)
                {
                    if (Input.GetMouseButtonDown(0) && Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hitinfo))
                    {
                        List<Serclimax.QuadSpace.ScCollider> collidables = new List<Serclimax.QuadSpace.ScCollider>();
                        if (!mScRoot.SpaceList.BarrierSpace.SearchPoint(hitinfo.point.x, hitinfo.point.z, ref collidables))
                            return;
                        Serclimax.Unit.ScUnit unit = collidables[0].HoldObj;
                        if (unit != null)
                        {
                            if (mWindow == null)
                                mWindow = SimulateWindow.Open();
                            SMUnit mu = ScriptableObject.CreateInstance<SMUnit>();
                            mu.init(unit);
                            mWindow.SetSMUnit(mu);
                        }
                    }
                }
                else
                if (!isDelete)
                {
                    if (Input.GetMouseButtonDown(0) && Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hitinfo))
                    {
                        if (CreateUnitType == 0)
                        {
                            CreateUnitID = UnitIDs[CureateUnitIDIndex];
                            TeamID = TeamGroups[TeamIDindex];
                            Serclimax.Unit.ScUnit unit = mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().CreateUnitParam().
                                UnitData(CreateUnitID).
                                Pos(hitinfo.point).
                                Dir(Vector3.forward).
                                Teamid(TeamID).
                                GenerateUnit();
                            unit.Active();
                        }
                        else if (CreateUnitType == 1)
                        {
                            CreateUnitID = UnitBuildIDs[CureateUnitIDIndex];
                            Vector3 pos = hitinfo.point;
                            Vector3 f = Camera.main.transform.forward;
                            f.y = 0;

                            Vector3 forward = -f; //Quaternion.AngleAxis(Random.Range(0.0f, 360.0f), Vector3.up) * Vector3.forward;
                            List<Serclimax.Level.ScLevelSpace> spaces = GetBuildSpace(mScRoot, CreateUnitID, pos, forward);
                            List<Serclimax.Unit.ScSlotNode> nodes = GetBuildSlot(mScRoot, CreateUnitID, pos, forward);
                            TeamID = TeamGroups[TeamIDindex];
                            Serclimax.Unit.ScUnit unit = mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().CreateUnitParam().BuildData(CreateUnitID).
                                Pos(pos).
                                Dir(forward).
                                Teamid(TeamID).GenerateUnit();
                            unit.BuildAttribulte.SetBoundSpaces(spaces);
                            unit.BuildAttribulte.SetSlotNode(nodes);
                            unit.Active();
                        }
                        else if (CreateUnitType == 2)
                        {
                            CreateUnitID = ExplodeIDs[CureateUnitIDIndex];
                            Vector3 forward = Quaternion.AngleAxis(Random.Range(0.0f, 360.0f), Vector3.up) * Vector3.forward;
                            TeamID = TeamGroups[TeamIDindex];
                            mScRoot.GetMgr<Serclimax.Skill.ScSkillMgr>().CreateExplode(CreateUnitID, hitinfo.point, forward, TeamID);
                        }
                    }
                }
                else
                {
                    if (Tag != null)
                    {
                        Tag.SetActive(true);
                        if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hitinfo))
                        {
                            Vector3 p = hitinfo.point;
                            p.y = 0.5f;
                            Tag.transform.position = p;
                        }
                    }
                    if (Input.GetMouseButtonDown(0) && Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hitinfo))
                    {
                        List<Serclimax.QuadSpace.ScCollider> collidables = new List<Serclimax.QuadSpace.ScCollider>();
                        Serclimax.QuadSpace.ScQuadRect rect = new Serclimax.QuadSpace.ScQuadRect(hitinfo.point.x, hitinfo.point.z, 0.5f, 0.5f);
                        if (!mScRoot.SpaceList.BarrierSpace.SearchArea(ref rect, ref collidables))
                            return;
                        Serclimax.Unit.ScUnit unit = null;
                        for (int i = 0, imax = collidables.Count; i < imax; i++)
                        {
                            unit = collidables[i].HoldObj;
                            if (unit != null)
                            {
                                mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().DestroyEntity(unit);
                            }
                        }
                    }
                }
            }
            if (mWindow != null)
                mWindow.Repaint();
            if (Input.GetKeyDown(KeyCode.Space))
            {
                mEnableOnGui = !mEnableOnGui;
            }
        }

        List<Serclimax.Level.ScLevelSpace> GetBuildSpace(Serclimax.ScRoot root, int id, Vector3 pos, Vector3 forward)
        {
            GameObject unitObj = null;
            GameObject unitObj2 = null;
            Serclimax.Unit.ScUnitDefenseData data = root.GetMgr<Serclimax.Unit.ScUnitMgr>().BuildTableData.GetData(id);
            if (data == null)
                return null;
            unitObj = ResourceLibrary.instance.GetLevelObjectInstance(data._unitDefensePrefab);
            CsUnit unit = unitObj.GetComponent<CsUnit>();
            if (unit != null)
            {

                unitObj2 = (GameObject)GameObject.Instantiate(unit._modelPrefab, pos, Quaternion.LookRotation(forward, Vector3.up));
            }
            List<Serclimax.Level.ScLevelSpace> spaces = CsLevelQuadSpace.ToSplit(CsLevelQuadSpace.GetColliderBounds(unitObj2), unitObj2, 0, 0.5f, RootMask);
            GameObject.Destroy(unitObj);
            GameObject.Destroy(unitObj2);
            return spaces;
        }

        List<Serclimax.Unit.ScSlotNode> GetBuildSlot(Serclimax.ScRoot root, int id, Vector3 pos, Vector3 forward)
        {
            GameObject unitObj = null;
            Serclimax.Unit.ScUnitDefenseData data = root.GetMgr<Serclimax.Unit.ScUnitMgr>().BuildTableData.GetData(id);
            if (data == null)
                return null;
            unitObj = ResourceLibrary.instance.GetLevelObjectInstance(data._unitDefensePrefab);
            unitObj.transform.position = pos;
            unitObj.transform.forward = forward;
            CsUnit unit = unitObj.GetComponent<CsUnit>();
            List<Serclimax.Unit.ScSlotNode> nodes = new List<Serclimax.Unit.ScSlotNode>();
            CsSlotTag[] tags = unitObj.GetComponentsInChildren<CsSlotTag>(true);
            for (int i = 0, imax = tags.Length; i < imax; i++)
            {
                nodes.Add(tags[i].ToSlotNode());
            }
            GameObject.Destroy(unitObj);
            return nodes;
        }

        Vector2 pos;
        void OnGUI()
        {
            if (!mEnableOnGui)
                return;
            int debugIndex = CureateUnitIDIndex;
            for (int i = 0, imax = mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().UnitCount; i < imax; i++)
            {
                Serclimax.Unit.ScUnit unit = mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().GetUnit(i);
                if (unit.UnitAttribute.IsDead)
                    continue;
                Vector3 p = Camera.main.WorldToScreenPoint(unit.CurPos);
                GUI.Label(new Rect(p.x-50,Screen.height- p.y-30, 150, 30), "T:"+unit.UnitAttribute.TeamID.ToString()+" HP:" + unit.UnitAttribute.HP.ToString()+" A"+unit.UnitAttribute.AnimState.ToString());
            }
            // GUILayout.BeginArea(new Rect(0, 0, 300, 500));
            GUILayout.BeginVertical();
            pos = GUILayout.BeginScrollView(pos,true,false, GUILayout.MinWidth(500), GUILayout.MaxWidth(10000));

            if(CreateUnitType == 0)
            {
                if (CureateUnitIDIndex >= UnitNames.Length)
                    CureateUnitIDIndex = UnitNames.Length - 1;

                CureateUnitIDIndex = GUILayout.Toolbar(CureateUnitIDIndex, UnitNames, GUILayout.MinHeight(60));
            }
            else if(CreateUnitType == 1)
            {
                if (CureateUnitIDIndex >= UnitBuildNames.Length)
                    CureateUnitIDIndex = UnitBuildNames.Length - 1;

                CureateUnitIDIndex = GUILayout.Toolbar(CureateUnitIDIndex, UnitBuildNames, GUILayout.MinHeight(60));
            }
            else if (CreateUnitType == 2)
            {
                if (CureateUnitIDIndex >= ExplodeNames.Length)
                    CureateUnitIDIndex = ExplodeNames.Length - 1;

                CureateUnitIDIndex = GUILayout.Toolbar(CureateUnitIDIndex, ExplodeNames, GUILayout.MinHeight(60));
            }

            //
            GUILayout.EndScrollView();
            CreateUnitType = GUILayout.Toolbar(CreateUnitType, UnitTypesName);
            TeamIDindex = GUILayout.Toolbar(TeamIDindex, TeamGroupNames);
            GUILayout.BeginHorizontal();
            isDelete = GUILayout.Toggle(isDelete, "is Delete",GUILayout.MaxWidth(100));
            if (isDelete)
            {
                isSelect = false;
            }
            if (Tag != null)
                Tag.SetActive(isDelete);
            if (GUILayout.Button("clear all", GUILayout.MaxWidth(100)))
            {
                for (int i = 0, imax = mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().UnitCount; i < imax; i++)
                {
                    mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().DestroyEntity(mScRoot.GetMgr<Serclimax.Unit.ScUnitMgr>().GetUnit(i));
                }
            }
            isSelect = GUILayout.Toggle(isSelect, "Select", GUILayout.MaxWidth(100));
            if(isSelect)
            {
                isDelete = false;
            }
            GUILayout.EndHorizontal();
            GUILayout.EndVertical();
            //  GUILayout.EndArea();

        }

        void OnApplicationQuit()
        {
            if (mWindow != null)
                mWindow.Close();
            mWindow = null;
        }
    }

    public class SimulateWindow : UnityEditor.EditorWindow
    {

        private SMUnit mUnit = null;

        public static SimulateWindow Open()
        {
            // Get existing open window or if none, make a new one:
            SimulateWindow window = (SimulateWindow)UnityEditor.EditorWindow.GetWindow(typeof(SimulateWindow));
            window.Show();
            return window;
        }

        public void SetSMUnit(SMUnit unit)
        {
            mUnit = unit;
        }

        Vector2 pos = Vector2.zero;

        public void OnGUI()
        {
            if (mUnit == null)
                return;
            pos = EditorGUILayout.BeginScrollView(pos);
            EditorGUILayout.BeginVertical(GUILayout.MaxWidth(300));
            SerializedObject sobj = new SerializedObject(mUnit);

            EditorGUILayout.BeginVertical();
            if (sobj.FindProperty("UnitData") != null)
            {
                EditorGUILayout.PropertyField(sobj.FindProperty("UnitData"), true, GUILayout.MaxWidth(300));
            }
            if (sobj.FindProperty("Skills") != null)
            {
                EditorGUILayout.PropertyField(sobj.FindProperty("Skills"), true, GUILayout.MaxWidth(300));
            }
            
            sobj.ApplyModifiedProperties();
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndScrollView();
            Repaint();
        }
    }
#endif
}