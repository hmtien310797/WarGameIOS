using UnityEditor;
using UnityEngine;
using System.Text;

[CustomEditor(typeof(Mainland))]
[ExecuteInEditMode]
public class MainlandEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        Mainland mainland = (Mainland)target;
        GUILayout.BeginHorizontal();
        GUILayout.Label("设置布局");
        GUILayout.EndHorizontal();
        for (int i = 0; i < 13; i++)
        {
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("加载布局" + (i + 1), GUILayout.MinWidth(46f)))
            {
                mainland.LoadPositionList(i);
            }
            GUILayout.Space(40f);
            if (GUILayout.Button("保存布局" + (i + 1), GUILayout.MinWidth(60f)))
            {
                mainland.SavePositionList(i);
            }
            GUILayout.EndHorizontal();
        }
        GUILayout.BeginHorizontal();
        GUILayout.Label("设置相机");
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("加载相机左上角", GUILayout.MinWidth(46f)))
        {
            mainland.LoadCameraLeftTop();
        }
        GUILayout.Space(40f);
        if (GUILayout.Button("保存相机左上角", GUILayout.MinWidth(60f)))
        {
            mainland.SaveCameraLeftTop();
        }
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("加载相机右下角", GUILayout.MinWidth(46f)))
        {
            mainland.LoadCameraRightBottom();
        }
        GUILayout.Space(40f);
        if (GUILayout.Button("保存相机右下角", GUILayout.MinWidth(60f)))
        {
            mainland.SaveCameraRightBottom();
        }
        GUILayout.EndHorizontal();
    }
}