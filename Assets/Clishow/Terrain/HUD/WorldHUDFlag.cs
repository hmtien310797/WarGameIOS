using UnityEngine;
using System;

public class WorldHUDFlag : WorldHUDWidget
{
    [SerializeField] Transform[] flags;
    [SerializeField] Material[] _presetedPatterns;

    private int _type = -1;

    private Renderer[] uiRenderers;
    private ParticleSystem.TextureSheetAnimationModule[] uiAnimationModules;

    private void Awake()
    {
        int numFlags = flags.Length;
        uiRenderers = new Renderer[numFlags];
        uiAnimationModules = new ParticleSystem.TextureSheetAnimationModule[numFlags];

        for (int i = 0; i < numFlags; i++)
        {
            uiRenderers[i] = flags[i].GetComponent<Renderer>();
            uiAnimationModules[i] = flags[i].GetComponent<ParticleSystem>().textureSheetAnimation;
        }
    }

    public override int type
    {
        get
        {
            return _type;
        }

        set
        {
            UsePresetedPatterns(value);
        }
    }

    public override Material material
    {
        set
        {
            SetRendererMaterial(value);
            _type = -2;
        }
    }

    public override void EnableAnimation()
    {
        for (int i = 0; i < uiAnimationModules.Length; i++)
            uiAnimationModules[i].enabled = true;
    }

    public override void DisableAnimation()
    {
        for (int i = 0; i < uiAnimationModules.Length; i++)
            uiAnimationModules[i].enabled = false;
    }

    public void UsePresetedPatterns(int index)
    {
        if (_presetedPatterns.Length == 0)
            Debug.LogWarning("[WorldHUDFlag] There are no preseted patterns");
        else if (index >= 0 && index != _type)
        {
            SetRendererMaterial(_presetedPatterns[index]);
            _type = index;

            for (int i = 0; i < flags.Length; i++)
                flags[i].localScale = Vector3.one;
        }
        else if (type < 0 && _type >= 0)
        {
            SetRendererMaterial(null);
            _type = -1;

            for (int i = 0; i < flags.Length; i++)
                flags[i].localScale = Vector3.zero;
        }
    }

    private void SetRendererMaterial(Material material)
    {
        if (material == null)
            Hide();
        else
        {
            Show();

            for (int i = 0; i < uiRenderers.Length; i++)
                uiRenderers[i].sharedMaterial = material;
        }
    }
}
