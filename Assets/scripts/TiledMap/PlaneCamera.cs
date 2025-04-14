using UnityEngine;
using System.Collections;

public class PlaneCamera : MonoBehaviour
{
    private static PlaneCamera instance;
    public static PlaneCamera Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameObject("PlaneCamera").AddComponent<PlaneCamera>();
            }
            return instance;
        }
    }
    
    private Camera cam;
    private int layer;
    private RenderTexture rTexture;
    private Transform PlaneRoot;
    private float scaleX;
    private float scaleY;
    private Vector2 renderSize;
    private UITexture sTexture;

    // Use this for initialization
    void Start()
    {
        renderSize = new Vector2(1500, 1500);
        scaleX = 1280 / renderSize.x;
        scaleY = 640 / renderSize.y;
        layer = LayerMask.NameToLayer("UI");
        GameObject tempgo = new GameObject("Camera");
        tempgo.transform.SetParent(transform, false);
        cam = tempgo.AddComponent<Camera>();
        cam.cullingMask = 1 << layer;
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.orthographic = true;
        rTexture = new RenderTexture((int)renderSize.x, (int)renderSize.y, 24);
        cam.targetTexture = rTexture;
        PlaneRoot = NGUITools.AddChild(gameObject).transform;
        PlaneRoot.localPosition = Vector3.forward * 8;
        //Light _light = new GameObject("Light").AddComponent<Light>();
        //_light.transform.SetParent(transform, false);
        //_light.type = LightType.Directional;
        //_light.intensity = 2.5f;
        //_light.transform.localEulerAngles = new Vector3(45, 0, 0);
        NGUITools.SetLayer(gameObject, layer);
        InitShowTexture();
    }

    private void InitShowTexture()
    {
        if (rTexture == null)
        {
            return;
        }
        UIWidget widget = GameObject.Find("WorldMap/Container").GetComponent<UIWidget>();
        scaleX = widget.width / renderSize.x;
        scaleY = widget.height / renderSize.y;
        GameObject tempgo = GameObject.Find("WorldMap/Container/path_bg");
        UITexture texture = NGUITools.AddChild<UITexture>(tempgo);
        texture.mainTexture = rTexture;
        texture.width = rTexture.width;
        texture.height = rTexture.height;
        texture.depth = 2;
        sTexture = texture;
        texture = NGUITools.AddChild<UITexture>(texture.gameObject);
        texture.mainTexture = rTexture;
        texture.width = rTexture.width - Mathf.RoundToInt(50 * scaleX);
        texture.height = rTexture.height - Mathf.RoundToInt(50 * scaleY);
        texture.depth = 1;
        texture.material = new Material(Shader.Find("Unlit/Transparent Colored Shadow"));
        texture.transform.localPosition = new Vector3(30 * scaleX, -35 * scaleY, 0);
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void SetPos(GameObject plane, Vector3 position)
    {
        if (sTexture == null)
        {
            InitShowTexture();
        }
        if (plane.transform.parent != PlaneRoot)
        {
            plane.transform.SetParent(PlaneRoot);
        }
        if (plane.layer != layer)
        {
            NGUITools.SetLayer(plane, layer);
        }
        if (cam != null)
        {
            plane.transform.localScale = Vector3.one;
            position.z = 8;
            position = cam.ViewportToWorldPoint(position);
            position.z = 0;
            position.x *= scaleX;
            position.y *= scaleY;
            plane.transform.localPosition = position;
        }
    }

    public void Close()
    {
        Destroy(instance.gameObject);
        instance = null;
    }
}
