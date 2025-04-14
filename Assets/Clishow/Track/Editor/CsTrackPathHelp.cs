using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Clishow
{
    [CustomEditor(typeof(CsTrackPathManager))]
    public class CsTrackPathHelp : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            CsTrackPathManager mgr = target as CsTrackPathManager;
            if (GUILayout.Button("Generate..."))
            {
                CsTrackerData[] datas = mgr.gameObject.GetComponentsInChildren<CsTrackerData>();
                for (int i = 0, imax = datas.Length; i < imax; i++)
                {
                    for (int j = 0, jmax = datas[i].Info.ActionInfos.Length; j < jmax; j++)
                    {
                        datas[i].Info.ActionInfos[j].GeneratePath();
                    }
                }
            }
        }
    }
}

