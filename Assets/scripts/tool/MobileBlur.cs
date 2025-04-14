using UnityEngine;
using System.Collections;

//[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/Mobile Blur") ]
public class MobileBlur : MonoBehaviour 
{
    public int downSample = 128;
    public bool onlyDownSample = true;
	public Shader blurShader;
	private Material apply = null;
	private RenderTextureFormat rtFormat = RenderTextureFormat.Default;
	
	void Start () 
	{
		FindShaders ();
		CheckSupport ();
		CreateMaterials ();	
	}
	
	void FindShaders () 
	{	
		if (!blurShader)
			blurShader = Shader.Find("Hidden/MobileBlur");
	}
	
	void CreateMaterials () 
	{		
		if (!apply) {
			apply = new Material (blurShader);	
			apply.hideFlags = HideFlags.DontSave;
		}           
	}

	bool Supported () 
	{
		return (SystemInfo.supportsImageEffects && SystemInfo.supportsRenderTextures && blurShader.isSupported);
	}
	
	bool CheckSupport ()
	{
		if (!Supported ()) 
		{
			enabled = false;
			return false;
		}	
		rtFormat = SystemInfo.SupportsRenderTextureFormat (RenderTextureFormat.RGB565) ? RenderTextureFormat.RGB565 : RenderTextureFormat.Default;
		return true;
	}
	
	void OnDestroy ()
	{
		if (apply) 
		{
			DestroyImmediate (apply);
			apply = null;	
		}
	}
	
	void OnRenderImage ( RenderTexture source , RenderTexture destination ) 
	{		
	#if UNITY_EDITOR
		FindShaders ();
		CheckSupport ();
		CreateMaterials ();
#endif
        int count = 0;
        int tempWidth = source.width;
        int tempHeight = source.height;
        while (downSample < tempWidth)
        {
            tempWidth >>= 1;
            count++;
        }
		tempHeight = tempHeight >> count;

	    if (onlyDownSample)
        {
            RenderTexture tempRtLowA = RenderTexture.GetTemporary(tempWidth, tempHeight, 0, rtFormat);

            // downsample
            Graphics.Blit(source, tempRtLowA);
            Graphics.Blit(tempRtLowA, destination, apply, 1);

            RenderTexture.ReleaseTemporary(tempRtLowA);
        }
        else
        {
            RenderTexture tempRtLowA = RenderTexture.GetTemporary(tempWidth, tempHeight, 0, rtFormat);
            RenderTexture tempRtLowB = RenderTexture.GetTemporary(tempWidth, tempHeight, 0, rtFormat);

            // downsample & blur
            Graphics.Blit(source, tempRtLowA);
            Graphics.Blit(tempRtLowA, tempRtLowB, apply, 0);
            Graphics.Blit(tempRtLowB, destination, apply, 1);

            RenderTexture.ReleaseTemporary(tempRtLowA);
            RenderTexture.ReleaseTemporary(tempRtLowB);
        }
	}

}
