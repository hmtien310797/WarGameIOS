using UnityEngine;
using System.Collections;
using UnityEditor;
namespace Clishow
{
    [UnityEditor.CustomEditor(typeof(EEventMgrShell))]
    public class EEventMgrEdt : Editor
    {
        private EEventMgrShell mMgr = null;
        private EBaseShell mCurEvent = null;

        public override void OnInspectorGUI()
        {
            mMgr = (EEventMgrShell)target;
            base.OnInspectorGUI();


            if (mCurEvent != null)
            {
                EEventEditorHelper.EventInspectorGUI(mCurEvent);
                Repaint();
            }            
        }
        
        private void OnSceneGUI()
        {
            mMgr = (EEventMgrShell)target;
            EETrfEdt.DrawTrfs(mMgr.transform);
            Scene2DUI();


            mMgr.events.Clear();
            EBaseShell e = null;
            for (int i = 0,imax = mMgr.transform.childCount;i < imax; i++)
            {
                e = mMgr.transform.GetChild(i).GetComponent<EBaseShell>();
                if (e != null && !e.isDestroy)
                {
                    //e.id = i;
                    e.RefreshData();
                    mMgr.events.Add(e);
                    //DrawNormalEvent(e as ENormalShell);

                }
            }

            if (EETrfEdt.CurTrf == null)
                return;
            EBaseShell ent = EETrfEdt.CurTrf.GetComponent<EBaseShell>();
            if (ent != mCurEvent)
            {
                mCurEvent = ent;
                Repaint();
            }
        }

        void SaveEvents()
        {
            mMgr.events.Clear();
            EBaseShell e = null;
            for (int i = 0, imax = mMgr.transform.childCount; i < imax; i++)
            {
                e = mMgr.transform.GetChild(i).GetComponent<EBaseShell>();
                if (e != null)
                {
                    e.index = i;
                }
            }
            for (int i = 0, imax = mMgr.transform.childCount; i < imax; i++)
            {
                e = mMgr.transform.GetChild(i).GetComponent<EBaseShell>();
                if (e != null)
                {
                    e.RefreshData();
                    mMgr.events.Add(e);
                }
            }

            string fileAbsPath = Application.dataPath + XLevelDefine.RESOURCE_PATH + XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + "/dat/" + XLevelDefine.Chapter_Scene;
            //string path = EditorUtility.OpenFolderPanel("SAVE TO EVENT FILE", "", "new event.txt");
            string path = fileAbsPath;
            if (!string.IsNullOrEmpty(path))
            {
                CsFileHelper.WriteJsonFile(mMgr.toNodes(), path + mMgr.name + ".txt");
            }
            AssetDatabase.Refresh();
        }

        void LoadEvents()
        {
            
            string path = EditorUtility.OpenFilePanel("LOAD TO EVENT FILE", "Assests", "txt");
            if (string.IsNullOrEmpty(path))
                return;
            string data = CsFileHelper.ReadTxtFile(path);
            Serclimax.Event.ScEventDataset set = Serclimax.Event.ScEventDataset.Deserialize(data);
            mMgr.events.Clear();
            Transform trf = null;
            for (int i = 0; i < mMgr.transform.childCount;)
            {
                trf = mMgr.transform.GetChild(i);
                trf.parent = null;
                DestroyImmediate(trf.gameObject);
            }


            EBaseShell ebase = null;
            GameObject obj = null;
            for (int i = 0, imax = set.mSet.Count; i < imax; i++)
            {
                Serclimax.Event.ScDefineEventAITypes.SEAType type = (Serclimax.Event.ScDefineEventAITypes.SEAType)set.mSet[i].TypeID;
                obj = EEventFactory.CreateEvent(type);
                if (obj != null)
                {
                    ebase = obj.GetComponent<EBaseShell>();
                    if(ebase != null)
                    {
                        ebase.transform.parent = mMgr.transform;
                        ebase.transform.localPosition = Vector3.zero;
                        ebase.transform.localRotation = Quaternion.identity;
                        ebase.Mgr = mMgr;
                        ebase.index = (int)set.mSet[i].id;
                        IDataGet d = (IDataGet)ebase.Data;
                        d.SetData(set.mSet[i]);
                        mMgr.events.Add(ebase);
                    }
                }
            }
            for (int i = 0, imax = set.mSet.Count; i < imax; i++)
            {
                ebase = mMgr.events[i];
                ebase.FillData();
            }

        }

        //void DrawNormalEvent(ENormalShell n)
        //{
        //    if (n == null)
        //        return;
        //    Handles.color = Color.green;
        //    if (n.NextEvents != null)
        //    {
        //        for (int j = 0, jmax = n.NextEvents.Count; j < jmax; j++)
        //        {
        //            Handles.DrawLine(n.transform.position, n.NextEvents[j].transform.position);
        //            Quaternion q = Quaternion.FromToRotation(n.transform.forward, n.NextEvents[j].transform.position - n.transform.position) * n.transform.rotation;
        //            Handles.ArrowCap(0, n.transform.position, q, 2);
        //        }
        //    }
        //    Handles.color = Color.white;
        //}


        private Serclimax.Event.ScDefineEventAITypes.SEAType mCType;//= Serclimax.Event.ScDefineEventAITypes.SEAType.SEAT_NODE;

        void Scene2DUI()
        {
            Handles.BeginGUI();
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Clear Selected", GUILayout.MaxWidth(200)))
            {
                mCurEvent = null;
                EETrfEdt.CurTrf = null;
            }
            EditorGUILayout.BeginVertical(GUILayout.MaxWidth(200));
            mCType = (Serclimax.Event.ScDefineEventAITypes.SEAType)EditorGUILayout.EnumPopup(mCType);
            if (GUILayout.Button("Create New Event"))
            {
                GameObject obj = EEventFactory.CreateEvent(mCType);
                EBaseShell ebase = obj.GetComponent<EBaseShell>();
                ebase.Mgr = mMgr;
                obj.transform.parent = mMgr.transform;
                obj.transform.localPosition = Vector3.zero;
                obj.transform.localRotation = Quaternion.identity;
                obj.transform.localScale = new Vector3(1, 1, 1);
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.BeginVertical(GUILayout.MaxWidth(200));
            if (GUILayout.Button("Save...", GUILayout.MaxWidth(200)))
            {
                SaveEvents();
            }
            if (GUILayout.Button("Load...", GUILayout.MaxWidth(200)))
            {
                LoadEvents();
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndHorizontal();
            Handles.EndGUI();
        }
    }

}


