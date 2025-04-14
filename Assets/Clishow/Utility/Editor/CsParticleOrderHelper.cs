using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;

namespace Clishow
{


    public class CsParticleOrderWindow : EditorWindow
    {
        private string mTargetFile = "";
        private List<Clishow.CsParticleBase> mParticles = new List<Clishow.CsParticleBase>();
        private List<Clishow.CsParticleBase> mSourceParticles = new List<Clishow.CsParticleBase>();
        private List<Clishow.CsParticleBase> mTargetParticles = new List<Clishow.CsParticleBase>();
        private int mIndex = 0;

        private List<Clishow.CsParticleBase> mNeedClear = new List<Clishow.CsParticleBase>();
        private List<Clishow.CsParticleBase> mNeedTargetClear = new List<Clishow.CsParticleBase>();

        [MenuItem("Tools/Particle Order Manager ...")]
        static void Init()
        {
            // Get existing open window or if none, make a new one:
            CsParticleOrderWindow window = (CsParticleOrderWindow)EditorWindow.GetWindow<CsParticleOrderWindow>("粒子順序管理");
            window.Show();
        }

        void RefrushParticles(string target)
        {
            if (string.IsNullOrEmpty(target))
            {
                return;
            }
            DirectoryInfo folder = new DirectoryInfo(target);
            if (folder == null)
            {
                return;
            }
            foreach (FileInfo file in folder.GetFiles("*.prefab"))
            {
                string path = file.FullName;
                path = path.Replace("\\", "/");
                int index = path.IndexOf("Assets/");
                path = path.Substring(index);
                Clishow.CsParticleBase pb = AssetDatabase.LoadAssetAtPath<Clishow.CsParticleBase>(path);
                
                if (pb != null)
                {
                    //Debug.Log(path + "  OK");
                    mParticles.Add(pb);
                }
                else
                {
                    //Debug.Log(path+"   Error");
                }
            }
            foreach (DirectoryInfo dir in folder.GetDirectories())
            {
                RefrushParticles(dir.FullName);
            }
        }

        void Refrush()
        {
            mIndex = 0;
            mNeedClear.Clear();
            mParticles.Clear();
            mSourceParticles.Clear();
            mTargetParticles.Clear();
            RefrushParticles(mTargetFile);

            for (int i = 0, imax = mParticles.Count; i < imax; i++)
            {
                if (mParticles[i].RenderOrderStart != 0 && mParticles[i].RenderOrderEnd != 0)
                {
                    mTargetParticles.Add(mParticles[i]);
                }
                else
                {
                    mSourceParticles.Add(mParticles[i]);
                }
            }

            if (mTargetParticles.Count != 0)
            {
                mTargetParticles.Sort(SortParticles2Compare);
                mIndex = mTargetParticles[mTargetParticles.Count - 1].RenderOrderEnd + 1;
            }

            Repaint();
        }

        void RefrushTarget()
        {
            mIndex = 1;
            for (int i = 0, imax = mTargetParticles.Count; i < imax; i++)
            {
                mTargetParticles[i].RenderOrderStart = mIndex;
                ParticleSystem[] ps = mTargetParticles[i].GetComponentsInChildren<ParticleSystem>(true);
                for (int j = 0, jmax = ps.Length; j < jmax; j++)
                {
                    ParticleSystemRenderer psr = ps[j].GetComponent< ParticleSystemRenderer > ();
                    psr.sortingOrder = mIndex;
                    mIndex++;
                }
                mTargetParticles[i].RenderOrderEnd = mIndex;
                GameObject checkPrefab = PrefabUtility.InstantiatePrefab(mTargetParticles[i].gameObject) as GameObject;
                PrefabUtility.ReplacePrefab(checkPrefab, mTargetParticles[i], ReplacePrefabOptions.ConnectToPrefab);
                GameObject.DestroyImmediate(checkPrefab);
            }
            
            AssetDatabase.SaveAssets();
        }

        void Reset(Clishow.CsParticleBase target)
        {
            target.RenderOrderStart = 0;
            ParticleSystem[] ps = target.GetComponentsInChildren<ParticleSystem>(true);
            for (int j = 0, jmax = ps.Length; j < jmax; j++)
            {
                ParticleSystemRenderer psr = ps[j].GetComponent<ParticleSystemRenderer>();
                psr.sortingOrder = 0;
            }
            target.RenderOrderEnd = 0;
        }

        private static int SortParticles2Compare(Clishow.CsParticleBase obj1, Clishow.CsParticleBase obj2)
        {
            int res = 0;
            if ((obj1 == null) && (obj2 == null))
            {
                return 0;
            }
            else if ((obj1 != null) && (obj2 == null))
            {
                return 1;
            }
            else if ((obj1 == null) && (obj2 != null))
            {
                return -1;
            }
            if (obj1.RenderOrderStart > obj2.RenderOrderStart)
            {
                res = 1;
            }
            else if (obj1.RenderOrderStart < obj2.RenderOrderStart)
            {
                res = -1;
            }
            return res;
        }

        private Vector2 _SscrollPosition;
        private Vector2 _TscrollPosition;

        void OnGUI()
        {
            EditorGUILayout.BeginHorizontal();
            string target = string.Empty;
            target = EditorGUILayout.TextField(mTargetFile);
            if (GUILayout.Button("Select..."))
            {
                target = EditorUtility.OpenFolderPanel("選擇目標文件夾", "", "");
            }
            if (GUILayout.Button("Refrush..."))
            {
                Refrush();
            }

            if (target != mTargetFile)
            {
                mTargetFile = target;
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal(GUILayout.Width(800));
            
            _SscrollPosition = GUILayout.BeginScrollView(_SscrollPosition, GUILayout.Width(400));

            Rotorz.ReorderableList.ReorderableListGUI.Title("粒子庫");
            Rotorz.ReorderableList.ReorderableListGUI.ListField(mSourceParticles, SourcedItemDrawer, DrawEmpty, 
                Rotorz.ReorderableList.ReorderableListFlags.HideAddButton | Rotorz.ReorderableList.ReorderableListFlags.DisableReordering);

            GUILayout.EndScrollView();
            
            _TscrollPosition = GUILayout.BeginScrollView(_TscrollPosition, GUILayout.Width(400));

            Rotorz.ReorderableList.ReorderableListGUI.Title("優化過的粒子");
            Rotorz.ReorderableList.ReorderableListGUI.ListField(mTargetParticles, TargetItemDrawer, DrawEmpty,
                Rotorz.ReorderableList.ReorderableListFlags.HideAddButton | Rotorz.ReorderableList.ReorderableListFlags.HideRemoveButtons);

            GUILayout.EndScrollView();

            if (GUILayout.Button("Apply"))
            {
                RefrushTarget();
            }

            EditorGUILayout.EndHorizontal();

            if (mNeedClear.Count != 0)
            {
                for (int i = 0, imax = mNeedClear.Count; i < imax; i++)
                {
                    mSourceParticles.Remove(mNeedClear[i]);
                }
                mNeedClear.Clear();
            }
            if (mNeedTargetClear.Count != 0)
            {
                for (int i = 0, imax = mNeedTargetClear.Count; i < imax; i++)
                {
                    mTargetParticles.Remove(mNeedTargetClear[i]);
                }
                mNeedTargetClear.Clear();
            }

        }


        private Clishow.CsParticleBase SourcedItemDrawer(Rect position, Clishow.CsParticleBase itemValue)
        {
            position.width -= 50;
            GUI.Label(position, itemValue.name);

            position.x = position.xMax + 5;
            position.width = 45;
            if (GUI.Button(position, "Enter"))
            {
                mTargetParticles.Add(itemValue);
                mNeedClear.Add(itemValue);
                Repaint();
            }

            return itemValue;
        }

        private Clishow.CsParticleBase TargetItemDrawer(Rect position, Clishow.CsParticleBase itemValue)
        {
            if (itemValue == null)
                return itemValue;
            position.width -= 50;
            GUI.Label(position, itemValue.name);

            position.x = position.xMax/2 ;
            GUI.Label(position, itemValue.RenderOrderStart.ToString());

            position.x += (position.xMax/4);
            GUI.Label(position, itemValue.RenderOrderEnd.ToString());

            position.x += 45;
            position.width = 45;
            if (GUI.Button(position, "Exit"))
            {
                Reset(itemValue);
                mSourceParticles.Add(itemValue);
                mNeedTargetClear.Add(itemValue);
                Repaint();
            }
            return itemValue;
        }

        private void DrawEmpty()
        {
            GUILayout.Label("No items in list.", EditorStyles.miniLabel);
        }
    }
}

