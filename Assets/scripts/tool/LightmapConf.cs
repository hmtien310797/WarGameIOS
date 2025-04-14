using UnityEngine;

public class LightmapConf : MonoBehaviour
{
    public Renderer lightmapRenderer;
    public int lightmapIndex;
    public Vector4 lightmapScaleOffset;

    void Awake()
    {
        if (lightmapRenderer)
        {
            lightmapRenderer.lightmapIndex = lightmapIndex;
            lightmapRenderer.lightmapScaleOffset = lightmapScaleOffset;
        }
    }
}

