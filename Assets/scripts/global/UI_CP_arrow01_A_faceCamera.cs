using UnityEngine;
using System.Collections;

public class UI_CP_arrow01_A_faceCamera : MonoBehaviour
{
    private Transform arrowTransform;
    private Transform faceCamera;
    private Renderer childRender;

    void Awake()
    {
        arrowTransform = this.transform;
        childRender = arrowTransform.GetChild(0).GetComponent<Renderer>();
        if (childRender)
        { childRender.material.renderQueue = 4000; }
    }

    void OnEnable()
    {
        if (Camera.main)
        { faceCamera = Camera.main.transform; }
    }

    void Update()
    {
        if (faceCamera)
        {
            arrowTransform.rotation = Quaternion.Slerp(arrowTransform.rotation,
Quaternion.LookRotation(arrowTransform.position - new Vector3(faceCamera.position.x, arrowTransform.position.y, faceCamera.position.z)), 1);
        }
        else
        {
            if (Camera.main)
            { faceCamera = Camera.main.transform; }
        }
    }
}
