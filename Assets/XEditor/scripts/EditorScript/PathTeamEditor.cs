using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections.Generic;


class PathTeamEditor : MonoBehaviour
{
    public int teamId = 0;
    public string pathTag = string.Empty;
    void Update()
    {
        if (Application.isPlaying)
            return;

        Transform t = transform;
        if (t.hasChanged)
        {
            t.position = Vector3.zero;
            t.rotation = Quaternion.identity;
            t.localScale = Vector3.one;
            t.hasChanged = false;
        }
    }
    public void Init(XPathTeamData tdata)
    {
        teamId = tdata.teamId;
        pathTag = tdata.unitTag;
    }
}

