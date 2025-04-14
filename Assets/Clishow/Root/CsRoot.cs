//using System;
//using System.Collections.Generic;
//using UnityEngine;
//using Assets.scripts.manager;

//namespace Clishow
//{
//    public class CsRoot : CsSingletonBehaviour<CsRoot>
//    {
//        private Serclimax.ScRoot mScRoot = null;

//        //test
//        private Serclimax.NiceAstarPath mAstar;
//        private Serclimax.Event.ScEventDataset mEDataSet = null;
//        public Transform point1;
//        public Transform point2;
//        //test end

//        public bool Local = true;

//        public override bool IsAutoInit()
//        {
//            return false;
//        }

//        public override bool IsGlobal()
//        {
//            return false;
//        }

//        public Serclimax.ScRoot Root
//        {
//            get
//            {
//                return mScRoot;
//            }
//        }

//        public override void Initialize( object param = null)
//        {
//            if (mInitialized)
//                return;
//            if (Local)
//            {
//                //test
//                mAstar = new Serclimax.NiceAstarPath();
//                mAstar.Awake(GetMapPath());
//                mEDataSet = Serclimax.Event.ScEventDataset.Deserialize(GetEventDataPath());
//                //test end
//                CsTableSingleton.Instance.Initialize();
//                mScRoot = new Serclimax.ScRoot(CsDisDaCenter.Instance,CsTableSingleton.Instance.Tables);
//                //test
//                mScRoot.EventDataset = mEDataSet;
//                mScRoot.Astar = mAstar;
//                //mScRoot.point1 = point1;
//                //mScRoot.point2 = point2;
//                //test end
//                mScRoot.Initialize();
//            }
//            CsUnitMgr.Instance.Initialize();
//            CsDisDaCenter.Instance.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_UNIT_MSG,CsUnitMgr.Instance.DisposeUnitMsg);
//            CsDisDaCenter.Instance.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_UNIT_MSG, CsUnitMgr.Instance.DisposeCreateUnitMsg);
//            CsDisDaCenter.Instance.AddDisposeHandle(Serclimax.ScDefineDisMsgEnum.SDDM_GAMEOVER_MSG, SceneManager.instance.DisposeLevelGlobelMsg);
//            mValid = true;
//            mInitialized = true;

  
//        }

//        void Start()
//        {
//            Initialize();
//        }

//        void Update()
//        {
//            if (!mInitialized)
//                return;
//            if (mAstar != null)
//                mAstar.Update();
//            if (mScRoot != null)
//                mScRoot.Update(UnityEngine.Time.deltaTime);
//        }
//        //test
//        public byte[] GetMapPath()
//        {
//            string path = "level/Chapter_Demo/scene/demo_path";
//            TextAsset text = null;
//            text = Resources.Load(path) as TextAsset;
//            if (text != null)
//            {
//                return text.bytes;
//            }
//            return null;
//        }

//        public string GetEventDataPath()
//        {
//            string path = "TestEvent";
//            TextAsset text = null;
//            text = Resources.Load(path) as TextAsset;
//            if (text != null)
//            {
//                return text.text;
//            }
//            return null;
//        }
//        //test end

//    }
//}
