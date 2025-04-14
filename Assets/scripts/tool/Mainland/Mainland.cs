using UnityEngine;
using System.Collections;
using System;

public class Mainland : MonoBehaviour
{
    [System.Serializable]
    public class PositionList
    {
        public Vector3[] list = new Vector3[16];
    }

    [SerializeField]
    public PositionList[] positionList = new PositionList[13];

    [SerializeField]
    public Vector3 cameraLeftTop;

    [SerializeField]
    public Vector3 cameraRightBottom;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    public void LoadPositionList(int index)
    {
        for (int i = 0; i < 16; i++)
        {
            var gridTransform = transform.Find(string.Format("UI/Container/Grid ({0})", i + 1));
            gridTransform.localPosition = positionList[index].list[i];
        }
    }

    public void SavePositionList(int index)
    {
        for (int i = 0; i < 16; i++)
        {
            var gridTransform = transform.Find(string.Format("UI/Container/Grid ({0})", i + 1));
            positionList[index].list[i] = gridTransform.localPosition;
        }
    }

    public void LoadCameraLeftTop()
    {
        transform.Find("Scene/Main Camera").localPosition = cameraLeftTop;
    }

    public void SaveCameraLeftTop()
    {
        cameraLeftTop = transform.Find("Scene/Main Camera").localPosition;
    }

    public void LoadCameraRightBottom()
    {
        transform.Find("Scene/Main Camera").localPosition = cameraRightBottom;
    }

    public void SaveCameraRightBottom()
    {
        cameraRightBottom = transform.Find("Scene/Main Camera").localPosition;
    }

    public void Load(int index)
    {
        LoadPositionList(index);
    }
}
