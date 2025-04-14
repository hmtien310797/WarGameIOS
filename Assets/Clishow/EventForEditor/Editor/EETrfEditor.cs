using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Clishow
{
    public class EETrfEdt
    {
        public static ETrfTag CurTrf = null;

        public static void DrawTrfs(Transform root)
        {
            ETrfTag trf = null;
             
            for (int i = 0, imax = root.childCount; i < imax; i++)
            {
                trf = root.GetChild(i).GetComponent<ETrfTag>();
                if (trf == null)
                    continue;
                DrawTrfTag(trf);
            }
            DrawTrfOp();
        }

        public static void DrawTrfTag(ETrfTag trf)
        {
            Handles.Label(trf.transform.position + Vector3.up*3, trf.name);
            if (trf.TagRange > 0)
            {
                Handles.CircleHandleCap(
                    0, 
                    trf.transform.position, 
                    Quaternion.AngleAxis(90, Vector3.right) * trf.transform.rotation, 
                    trf.TagRange, 
                    EventType.Repaint
                );
            }
            Handles.color = trf.gameObject.activeSelf ? Color.blue : Color.gray;
            if (Handles.Button(trf.transform.position, trf.transform.rotation, 1, 1, Handles.ConeHandleCap
                ))
            {
                CurTrf = trf;
            }
            Handles.color = Color.white;
        }

        private static void DrawTrfOp()
        {
            if (CurTrf == null)
                return;
            Vector3 pos = Handles.PositionHandle(CurTrf.transform.position, CurTrf.transform.rotation);
            pos.y = 0;
            CurTrf.transform.position = pos;
            CurTrf.transform.rotation = Handles.RotationHandle(CurTrf.transform.rotation, CurTrf.transform.position);
        }
    }
}


