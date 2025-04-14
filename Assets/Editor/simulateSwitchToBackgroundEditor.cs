
//simulateSwitchToBackgroundEditor.cs
using UnityEngine;
using System.Collections;
using UnityEditor;
[CustomEditor(typeof(simulateSwitchToBackground))]
public class simulateSwitchToBackgroundEditor : Editor
{

    void OnEnable()
    {
    }
    public override void OnInspectorGUI()
    {

        DrawDefaultInspector();
        serializedObject.Update();
        serializedObject.ApplyModifiedProperties();//now varibles in script have been updated

        if (GUILayout.Button("send enter background message"))
        {
            if (Application.isPlaying)
            {
                ((simulateSwitchToBackground)target).sendEnterBackgroundMessage();
            }
        }
        if (GUILayout.Button("send enter foeground message"))
        {
            if (Application.isPlaying)
            {
                ((simulateSwitchToBackground)target).sendEnterFoegroundMessage();
            }
        }
    }

}