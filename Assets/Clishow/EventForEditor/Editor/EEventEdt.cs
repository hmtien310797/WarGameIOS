using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Clishow
{
    public class EEventEditorHelper
    {
        public static void EventInspectorGUI(EBaseShell ent)
        {
            if (ent.Data == null)
            {
                return;
            }
            EditorGUILayout.LabelField("--->Event  UID: "+ent.index.ToString());
            //gameoverEvent
            EGameOverDataShell godata = ent.Data as EGameOverDataShell;
            if(godata == null)
            {

            }
            else
            {
                GameOverEventGUI(godata);
            }

            //conditionEvent 
            EConAcDataShell data = ent.Data as EConAcDataShell;
            if (data == null)
            {
                SerializedObject sobj = new SerializedObject(ent.Data);
                EditorGUILayout.BeginVertical();
                if (sobj.FindProperty("Data") == null)
                {
                    EditorGUILayout.LabelField("===" + ent.name + "  Base Event");
                }
                else
                {
                    EditorGUILayout.LabelField("===" + ent.name + "  EVENT");
                    EditorGUILayout.PropertyField(sobj.FindProperty("Data"), true);
                }

                sobj.ApplyModifiedProperties();
                EditorGUILayout.EndVertical();
            }
            else
            {
                ActionGUI(data);
            }            
        }



        private static void ActionGUI(EConAcDataShell data)
        {
            EditorGUILayout.BeginVertical();
            EditorGUILayout.LabelField("-------------Conditions----------------");

            if (data.Data.Conditions == null)
                data.Data.Conditions = new System.Collections.Generic.List<Serclimax.Event.ScEAConditionBase>();
            for (int i = 0; i < data.Data.Conditions.Count;)
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(20)))
                {
                    data.Data.Conditions.RemoveAt(i);
                }
                else
                {
                    OnActionGUI(data.Data.Conditions[i], Serclimax.Event.ScDefineEventAITypes.CANameTypes[data.Data.Conditions[i].ActionID]);
                    i++;
                }                 
                EditorGUILayout.EndHorizontal();
            }

            Cindex = EditorGUILayout.IntPopup(Cindex, Serclimax.Event.ScDefineEventAITypes.CANameTypes, _cindexs);

            if (GUILayout.Button("+", GUILayout.Width(20), GUILayout.Height(20)))
            {
                System.Type type = Serclimax.Event.ScDefineEventAITypes.CAType[Cindex];
                Serclimax.Event.ScEAConditionBase c = (Serclimax.Event.ScEAConditionBase)System.Activator.CreateInstance(type);
                c.ActionID = Cindex;
                data.Data.Conditions.Add(c);
            }

            EditorGUILayout.LabelField("-------------Succeed------------------");
            if (data.Data.Succeed == null)
                data.Data.Succeed = new System.Collections.Generic.List<Serclimax.Event.ScEActionBase>();
            for (int i = 0; i < data.Data.Succeed.Count;)
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(20)))
                {
                    data.Data.Succeed.RemoveAt(i);
                }
                else
                {
                    OnActionGUI(data.Data.Succeed[i], Serclimax.Event.ScDefineEventAITypes.ANameTypes[data.Data.Succeed[i].ActionID]);
                    i++;
                }
                EditorGUILayout.EndHorizontal();
            }

            Cindex = EditorGUILayout.IntPopup(Cindex, Serclimax.Event.ScDefineEventAITypes.ANameTypes, _aindexs);

            if (GUILayout.Button("+", GUILayout.Width(20), GUILayout.Height(20)))
            {
                System.Type type = Serclimax.Event.ScDefineEventAITypes.AType[Cindex];
                Serclimax.Event.ScEActionBase c = (Serclimax.Event.ScEActionBase)System.Activator.CreateInstance(type);
                c.ActionID = Cindex;
                data.Data.Succeed.Add(c);
            }

            EditorGUILayout.EndVertical();
        }

        private static int[] Cindexs = null;
        private static int[] _cindexs
        {
            get
            {
                if (Cindexs == null)
                {
                    Cindexs = new int[Serclimax.Event.ScDefineEventAITypes.CANameTypes.Length];
                    for (int i = 0; i < Cindexs.Length; i++)
                    {
                        Cindexs[i] = i;
                    }
                }
                return Cindexs;
            }
        }

        private static int[] Aindexs = null;
        private static int[] _aindexs
        {
            get
            {
                if (Aindexs == null)
                {
                    Aindexs = new int[Serclimax.Event.ScDefineEventAITypes.ANameTypes.Length];
                    for (int i = 0; i < Aindexs.Length; i++)
                    {
                        Aindexs[i] = i;
                    }
                }
                return Aindexs;
            }
        }

        private static int Cindex = 0;

        private static string[] Dependencies = new string[] { "or", "and", "!" ,"!^"};
        private static int[] DependencieIndexs = new int[] { 0, 1, 2 ,3};

        private static void OnActionGUI(Serclimax.Event.ScEActionBase action,string display_name)
        {
            System.Type type =  action.GetType();
            System.Reflection.FieldInfo[] infos = type.GetFields();
            EditorGUILayout.BeginVertical();
            EditorGUILayout.LabelField(display_name+":");
            for (int i = 0, imax = infos.Length; i < imax; i++)
            {
                if (!infos[i].IsPublic)
                {
                    continue;
                }
                System.Type ft = infos[i].FieldType;
                if (!infos[i].Name.Contains("ActionID")) 
                {
                    if (infos[i].Name.Contains("Dependencies"))
                    {
                        int d = (int)(long)infos[i].GetValue(action);
                        d = EditorGUILayout.IntPopup(d, Dependencies, DependencieIndexs,GUILayout.Width(50));
                        infos[i].SetValue(action, (object)(long)d);
                        continue;
                    }

                    if (ft == typeof(bool))
                    {
                        infos[i].SetValue(action, EditorGUILayout.Toggle(infos[i].Name, (bool)infos[i].GetValue(action)));
                    }
                    else
                    if (ft == typeof(double))
                    {
                        infos[i].SetValue(action, (object)(double)EditorGUILayout.FloatField(infos[i].Name, (float)(double)infos[i].GetValue(action)));
                    }
                    else
                    if (ft == typeof(long))
                    {
                        infos[i].SetValue(action, (object)(long)EditorGUILayout.IntField(infos[i].Name, (int)(long)infos[i].GetValue(action)));
                    }
                    else
                    if (ft == typeof(string))
                    {
                        infos[i].SetValue(action, EditorGUILayout.TextField(infos[i].Name, (string)infos[i].GetValue(action)));
                    }
                }
            }
            EditorGUILayout.EndVertical();
        }


        #region GameOverEvent
        private static int winType = 0;
        private static int loseType = 0;
        private static int[] _goeindexs = null;
        private static int[] GOEIndexs
        {
            get
            {
                if (_goeindexs == null)
                {
                    _goeindexs = new int[Serclimax.Event.ScDefineEventAITypes.sGOEType.Length];
                    for (int i = 0; i < Aindexs.Length; i++)
                    {
                        _goeindexs[i] = i;
                    }
                }
                return _goeindexs;
            }
        } 
        private static void GameOverEventGUI(EGameOverDataShell data)
        {
            EditorGUILayout.BeginVertical();
            EditorGUILayout.LabelField("-------------Game Win----------------");

            winType = EditorGUILayout.IntPopup(winType, Serclimax.Event.ScDefineEventAITypes.sGOEType, null);
            if (GUILayout.Button("+", GUILayout.Width(20), GUILayout.Height(20)))
            {
                System.Type type = Serclimax.Event.ScDefineEventAITypes.sGOETypeValue[winType];
                Serclimax.Event.ScGOEBase goe = (Serclimax.Event.ScGOEBase)System.Activator.CreateInstance(type);
                data.Data.winEvents.Add(goe);
            }
            for (int i = 0; i < data.Data.winEvents.Count; )
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(20)))
                {
                    data.Data.winEvents.RemoveAt(i);
                }
                else
                {
                    OnGameOverEventGUI(data.Data.winEvents[i], "GameOverWinEvent:" + Serclimax.Event.ScDefineEventAITypes.sGOEType[winType]);
                    i++;
                }
                EditorGUILayout.EndHorizontal();
            }


            EditorGUILayout.LabelField("-------------Game lose----------------");

            loseType = EditorGUILayout.IntPopup(loseType, Serclimax.Event.ScDefineEventAITypes.sGOEType, null);
            if (GUILayout.Button("+", GUILayout.Width(20), GUILayout.Height(20)))
            {
                System.Type type = Serclimax.Event.ScDefineEventAITypes.sGOETypeValue[loseType];
                Serclimax.Event.ScGOEBase goe = (Serclimax.Event.ScGOEBase)System.Activator.CreateInstance(type);
                data.Data.loseEvents.Add(goe);
                
            }
            for (int i = 0; i < data.Data.loseEvents.Count; )
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(20)))
                {
                    data.Data.loseEvents.RemoveAt(i);
                }
                else
                {
                    OnGameOverEventGUI(data.Data.loseEvents[i], "GameOverLoseEvent:" + Serclimax.Event.ScDefineEventAITypes.sGOEType[loseType]);
                    i++;
                }
                EditorGUILayout.EndHorizontal();
            }

            EditorGUILayout.EndHorizontal();
        }
        private static void OnGameOverEventGUI(Serclimax.Event.ScGOEBase goeBase, string display_name)
        {
            System.Type type = goeBase.GetType();
            System.Reflection.FieldInfo[] infos = type.GetFields();
            EditorGUILayout.BeginVertical();
            EditorGUILayout.LabelField(display_name + ":");
            for (int i = 0, imax = infos.Length; i < imax; i++)
            {
                EditorGUILayout.BeginVertical(); 
                if (!infos[i].IsPublic)
                {
                    continue;
                }
                System.Type ft = infos[i].FieldType;
                if (ft == typeof(bool))
                {
                    infos[i].SetValue(goeBase, EditorGUILayout.Toggle(infos[i].Name, (bool)infos[i].GetValue(goeBase)));
                }
                else if (ft == typeof(double))
                {
                    infos[i].SetValue(goeBase, (object)(double)EditorGUILayout.FloatField(infos[i].Name, (float)(double)infos[i].GetValue(goeBase)));
                }
                else if (ft == typeof(long))
                {
                    infos[i].SetValue(goeBase, (object)(long)EditorGUILayout.IntField(infos[i].Name, (int)(long)infos[i].GetValue(goeBase)));
                }
                else if (ft == typeof(string))
                {
                    infos[i].SetValue(goeBase, EditorGUILayout.TextField(infos[i].Name, (string)infos[i].GetValue(goeBase)));
                }
                EditorGUILayout.EndHorizontal();
            }
            
            EditorGUILayout.EndVertical();
        }
        #endregion
    }



    [UnityEditor.CustomEditor(typeof(ENormalShell))]
    public class EEventEdt : Editor
    {
        private ENormalShell mEvent = null;
        private void OnSceneGUI()
        {
            mEvent = (ENormalShell)target;
            EETrfEdt.DrawTrfTag(mEvent);
        }
        public override void OnInspectorGUI()
        {
            mEvent = (ENormalShell)target;
            base.OnInspectorGUI();
            EEventEditorHelper.EventInspectorGUI(mEvent);
            Repaint();
        }
    }

    [UnityEditor.CustomEditor(typeof(EBaseShell))]
    public class EBaseEdt : Editor
    {
        private EBaseShell mEvent = null;
        private void OnSceneGUI()
        {
            mEvent = (EBaseShell)target;
            EETrfEdt.DrawTrfTag(mEvent);
        }
        public override void OnInspectorGUI()
        {
            mEvent = (EBaseShell)target;
            base.OnInspectorGUI();
            EEventEditorHelper.EventInspectorGUI(mEvent);
            Repaint();
        }
    }

    [UnityEditor.CustomEditor(typeof(EGameOverShell))]
    public class EEventGameOverEdt : Editor
    {
        private EGameOverShell mEvent = null;
        private void OnSceneGUI()
        {
            mEvent = (EGameOverShell)target;
            EETrfEdt.DrawTrfTag(mEvent);
        }
        public override void OnInspectorGUI()
        {
            mEvent = (EGameOverShell)target;
            base.OnInspectorGUI();
            EEventEditorHelper.EventInspectorGUI(mEvent);
            Repaint();
        }
    }
    [UnityEditor.CustomEditor(typeof(ECreateBuildShell))]
    public class EEventCreateBuildEdt : Editor
    {
        private ECreateBuildShell mEvent = null;
        private void OnSceneGUI()
        {
            mEvent = (ECreateBuildShell)target;
            EETrfEdt.DrawTrfTag(mEvent);
        }
        public override void OnInspectorGUI()
        {
            mEvent = (ECreateBuildShell)target;
            base.OnInspectorGUI();
            EEventEditorHelper.EventInspectorGUI(mEvent);
            Repaint();
        }
    }
}
