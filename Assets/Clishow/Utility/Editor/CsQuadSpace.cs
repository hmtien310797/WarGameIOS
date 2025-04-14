using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
namespace Clishow
{
    public class CsQuadSpaceEditor 
    {
        public static void DrawQuadRect(Serclimax.QuadSpace.ScQuadRect rect,float hight)
        {
            Vector3 pos1 = new Vector3((float)rect.MinX,0,(float)rect.MinY);
            Vector3 pos2 = new Vector3((float)rect.MaxX, 0, (float)rect.MinY);
            Vector3 pos3 = new Vector3((float)rect.MaxX, 0, (float)rect.MaxY);
            Vector3 pos4 = new Vector3((float)rect.MinX, 0, (float)rect.MaxY);

            Vector3 pos11 = new Vector3((float)rect.MinX, hight, (float)rect.MinY);
            Vector3 pos12 = new Vector3((float)rect.MaxX, hight, (float)rect.MinY);
            Vector3 pos13 = new Vector3((float)rect.MaxX, hight, (float)rect.MaxY);
            Vector3 pos14 = new Vector3((float)rect.MinX, hight, (float)rect.MaxY);

            List<Vector3> lines = new List<Vector3>();

            lines.Add(pos1);
            lines.Add(pos2);

            lines.Add(pos2);
            lines.Add(pos3);

            lines.Add(pos3);
            lines.Add(pos4);

            lines.Add(pos4);
            lines.Add(pos1);
//
            lines.Add(pos1);
            lines.Add(pos2);

            lines.Add(pos2);
            lines.Add(pos12);

            lines.Add(pos12);
            lines.Add(pos11);

            lines.Add(pos11);
            lines.Add(pos1);
            //

            //
            lines.Add(pos2);
            lines.Add(pos3);

            lines.Add(pos3);
            lines.Add(pos13);

            lines.Add(pos13);
            lines.Add(pos12);

            lines.Add(pos12);
            lines.Add(pos2);
            //
            //
            lines.Add(pos13);
            lines.Add(pos3);

            lines.Add(pos3);
            lines.Add(pos4);

            lines.Add(pos4);
            lines.Add(pos14);

            lines.Add(pos14);
            lines.Add(pos13);
            //
            //
            lines.Add(pos14);
            lines.Add(pos11);

            lines.Add(pos11);
            lines.Add(pos1);

            lines.Add(pos1);
            lines.Add(pos4);

            lines.Add(pos4);
            lines.Add(pos14);
            //
            lines.Add(pos11);
            lines.Add(pos12);

            lines.Add(pos12);
            lines.Add(pos13);

            lines.Add(pos13);
            lines.Add(pos14);

            lines.Add(pos14);
            lines.Add(pos11);
            Handles.DrawDottedLines(lines.ToArray(), 1);
        }

        public static void DrawSpace(List<Serclimax.QuadSpace.ScQuadRect> rects)
        {
            for (int i = 0,imax = rects.Count; i < imax;i++)
            {
                DrawQuadRect(rects[i],1);
            }
        }

        public static void DrawLevelSpace(CsLevelQuadSpace space)
        {
            DrawQuadRect(space.RootSpace.RootRect, space.RootSpace.Height);
            for (int i = 0, imax = space.SubSpaces.Count; i < imax; i++)
            {


                DrawQuadRect(space.SubSpaces[i].RootRect, space.SubSpaces[i].Height);
            }

        }



    }

    //[CustomEditor(typeof(CsRoot))]
    //public class CsRootEditor : Editor
    //{
    //    List<Serclimax.QuadSpace.ScQuadRect> rects = new List<Serclimax.QuadSpace.ScQuadRect>();
    //    private void OnSceneGUI()
    //    {
    //        CsRoot root = target as CsRoot;
    //        if (root.Root == null)
    //            return;
    ////        if (root.Root.Space == null)
    //            return;
    //        rects.Clear();
    //        root.Root.Space.AllRect(rects);
    //        CsQuadSpaceEditor.DrawSpace(rects);
    //    }
    //}

    [CustomEditor(typeof(Clishow.Simulate.SimulateEditorRoot))]
    public class SimulateEditorRootEditor : Editor
    {
        List<Serclimax.QuadSpace.ScQuadRect> rects = new List<Serclimax.QuadSpace.ScQuadRect>();
        private void OnSceneGUI()
        {
            Clishow.Simulate.SimulateEditorRoot show = target as Clishow.Simulate.SimulateEditorRoot;
            Serclimax.ScRoot root = show.mScRoot;

            if (root == null ||root.SpaceList.BarrierSpace == null)
                return;
            rects.Clear();
            root.SpaceList.BarrierSpace.AllRect(rects);
            CsQuadSpaceEditor.DrawSpace(rects);
        }
    }


    [CustomEditor(typeof(CsLevelQuadSpace))]
    public class CsLevelQuadSpaceEditor : Editor
    {

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            //CsLevelQuadSpace level = target as CsLevelQuadSpace;
            //EditorGUILayout.BeginVertical();
            //if (GUILayout.Button("Refresh"))
            //{
            //    FillLevelSpace(level);
            //    this.Repaint();
            //}
            //EditorGUILayout.EndVertical();
        }


        List<Serclimax.QuadSpace.ScQuadRect> rects = new List<Serclimax.QuadSpace.ScQuadRect>();
        private void OnSceneGUI()
        {
            CsLevelQuadSpace level = target as CsLevelQuadSpace;
            //FillLevelSpace(level);
            //rects.Clear();
            //level.GetAllRect(ref rects);
            //CsQuadSpaceEditor.DrawSpace(rects);
            CsQuadSpaceEditor.DrawLevelSpace(level);
        }

    }
}

