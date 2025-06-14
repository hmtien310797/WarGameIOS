using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using System.IO;
using DigitalOpus.MB.Core;

public class MB_TextureCombinerRenderTexture{
	public MB2_LogLevel LOG_LEVEL = MB2_LogLevel.info;
	Material mat;
	RenderTexture _destinationTexture;
	Camera myCamera;
	int _padding;
	bool _isNormalMap;

	//only want to render once, not every frame
	bool _doRenderAtlas = false;

	Rect[] rs;
	List<MB3_TextureCombiner.MB_TexSet> textureSets;
	int indexOfTexSetToRender;
	Texture2D targTex;
	MB3_TextureCombiner combiner;
	
	public Texture2D DoRenderAtlas(GameObject gameObject, int width, int height, int padding, Rect[] rss, List<MB3_TextureCombiner.MB_TexSet> textureSetss, int indexOfTexSetToRenders, bool isNormalMap, MB3_TextureCombiner texCombiner, MB2_LogLevel LOG_LEV){
		LOG_LEVEL = LOG_LEV;
		textureSets = textureSetss;
		indexOfTexSetToRender = indexOfTexSetToRenders;
		_padding = padding;
		_isNormalMap = isNormalMap;
		combiner = texCombiner;
		rs = rss;
		Shader s;
		if (_isNormalMap){
			s = Shader.Find ("MeshBaker/NormalMapShader");
		} else {
			s = Shader.Find ("MeshBaker/AlbedoShader");
		}
		if (s == null){
			Debug.LogError ("Could not find shader for RenderTexture. Try reimporting mesh baker");
			return null;
		}
		mat = new Material(s);
		_destinationTexture = new RenderTexture(width,height,24);
		_destinationTexture.filterMode = FilterMode.Point;
		
		myCamera = gameObject.GetComponent<Camera>();
		myCamera.orthographic = true;
		myCamera.orthographicSize = height >> 1;
		myCamera.aspect = width / height;
		myCamera.targetTexture = _destinationTexture;
		myCamera.clearFlags = CameraClearFlags.Color;
		
		Transform camTransform = myCamera.GetComponent<Transform>();
		camTransform.localPosition = new Vector3(width >> 1, height >> 1, 3);
		camTransform.localRotation = Quaternion.Euler(0, 180, 180);
		
		_doRenderAtlas = true;
		if (LOG_LEVEL >= MB2_LogLevel.debug) Debug.Log ("Begin Camera.Render");
		myCamera.Render();
		_doRenderAtlas = false;
		
		MB_Utility.Destroy(mat);
		MB_Utility.Destroy(_destinationTexture);
		
		if (LOG_LEVEL >= MB2_LogLevel.debug) Debug.Log ("Finished Camera.Render ");

		Texture2D tempTex = targTex;
		targTex = null;
		return tempTex;
	}
	
	public void OnRenderObject(){
		if (_doRenderAtlas){
			//assett rs must be same length as textureSets;
			System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
			sw.Start ();
			for (int i = 0; i < rs.Length; i++){
				MB3_TextureCombiner.MeshBakerMaterialTexture texInfo = textureSets[i].ts[indexOfTexSetToRender];
				if (LOG_LEVEL >= MB2_LogLevel.trace && texInfo.t != null) Debug.Log ("Added " + texInfo.t + " to atlas w=" + texInfo.t.width + " h=" + texInfo.t.height + " offset=" + texInfo.offset + " scale=" + texInfo.scale + " rect=" + rs[i] + " padding=" + _padding);
				CopyScaledAndTiledToAtlas(texInfo,rs[i],_padding,false,_destinationTexture.width,false);
			}
			sw.Stop();
			sw.Start();
			if (LOG_LEVEL >= MB2_LogLevel.debug) Debug.Log ("Total time for Graphics.DrawTexture calls " + (sw.ElapsedMilliseconds).ToString("f5"));
			if (LOG_LEVEL >= MB2_LogLevel.debug) Debug.Log ("Copying RenderTexture to Texture2D.");
			//Convert the render texture to a Texture2D
			Texture2D tempTexture;
			tempTexture = new Texture2D(_destinationTexture.width, _destinationTexture.height, TextureFormat.ARGB32, true);
			
			int xblocks = _destinationTexture.width / 512;
			int yblocks = _destinationTexture.height / 512;
			if (xblocks == 0 || yblocks == 0)
			{
				if (LOG_LEVEL >= MB2_LogLevel.trace) Debug.Log ("Copying all in one shot"); 
				RenderTexture.active = _destinationTexture;
				tempTexture.ReadPixels(new Rect(0, 0, _destinationTexture.width, _destinationTexture.height), 0, 0, true);
				RenderTexture.active = null;
			} else {
				if (IsOpenGL()){
					if (LOG_LEVEL >= MB2_LogLevel.trace) Debug.Log ("OpenGL copying blocks");
					for (int x = 0; x < xblocks; x++){
						for (int y = 0; y < yblocks; y++)
						{
							RenderTexture.active = _destinationTexture;
							tempTexture.ReadPixels(new Rect(x * 512, y * 512, 512, 512), x * 512, y * 512, true);
							RenderTexture.active = null;
						}
					}
				} else {
					if (LOG_LEVEL >= MB2_LogLevel.trace) Debug.Log ("Not OpenGL copying blocks");
					for (int x = 0; x < xblocks; x++){
						for (int y = 0; y < yblocks; y++){
							RenderTexture.active = _destinationTexture;
							tempTexture.ReadPixels(new Rect(x * 512, _destinationTexture.height - 512 - y * 512, 512, 512), x * 512, y * 512, true);
							RenderTexture.active = null;
						}
					}
				}
			}
			tempTexture.Apply ();
			myCamera.targetTexture = null;
			RenderTexture.active = null;
			
			targTex = tempTexture;	
			if (LOG_LEVEL >= MB2_LogLevel.debug) Debug.Log ("Total time to copy RenderTexture to Texture2D " + (sw.ElapsedMilliseconds).ToString("f5"));
		}
	}
	
	private bool IsOpenGL(){
		var graphicsDeviceVersion = SystemInfo.graphicsDeviceVersion;
		return graphicsDeviceVersion.StartsWith("OpenGL");
	}
	
	private void CopyScaledAndTiledToAtlas(MB3_TextureCombiner.MeshBakerMaterialTexture source, Rect rec, int _padding, bool _fixOutOfBoundsUVs, int maxSize, bool isNormalMap){			
		Rect r = rec;

		myCamera.backgroundColor = source.colorIfNoTexture;

		if (source.t == null){
			source.t = combiner._createTemporaryTexture(16,16,TextureFormat.ARGB32, true);
			MB_Utility.setSolidColor(source.t,source.colorIfNoTexture);
		}

		r.y = 1f - (r.y + r.height); // DrawTexture uses topLeft 0,0, Texture2D uses bottomLeft 0,0 
		r.x *= _destinationTexture.width;
		r.y *= _destinationTexture.height;
		r.width *= _destinationTexture.width;
		r.height *= _destinationTexture.height;

		Rect rPadded = r;
		rPadded.x -= _padding;
		rPadded.y -= _padding;
		rPadded.width += _padding * 2;
		rPadded.height += _padding * 2;

		Rect srcPrTex = new Rect();
		Rect targPr = new Rect();
		
		srcPrTex.width = source.scale.x;        
		srcPrTex.height = source.scale.y;
		srcPrTex.x = source.offset.x;
		srcPrTex.y = source.offset.y;
		if (_fixOutOfBoundsUVs){
			srcPrTex.width *= source.obUVscale.x;
			srcPrTex.height *= source.obUVscale.y;
			srcPrTex.x += source.obUVoffset.x;
			srcPrTex.y += source.obUVoffset.y;
			if (LOG_LEVEL >= MB2_LogLevel.trace) Debug.Log ("Fixing out of bounds UVs for tex " + source.t);
		}
		Texture tex = source.t;
		
		//main texture
		TextureWrapMode oldTexWrapMode = tex.wrapMode;
		if (srcPrTex.width == 1f && srcPrTex.height == 1f && srcPrTex.x == 0f && srcPrTex.y == 0f){
			//fixes bug where there is a dark line at the edge of the texture
			tex.wrapMode = TextureWrapMode.Clamp;
		} else {
			tex.wrapMode = TextureWrapMode.Repeat;
		}


		if (LOG_LEVEL >= MB2_LogLevel.trace) Debug.Log ("DrawTexture tex=" + tex.name + " destRect=" + r + " srcRect=" + srcPrTex + " Mat=" + mat);


		//fill the padding first
		Rect srcPr = new Rect();

		//top margin
		srcPr.x = srcPrTex.x;
		srcPr.y = srcPrTex.y + 1 - 1f / tex.height;
		srcPr.width = srcPrTex.width;
		srcPr.height = 1f / tex.height;
		targPr.x = r.x;
		targPr.y = rPadded.y;
		targPr.width = r.width;
		targPr.height = _padding;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);

		//bot margin
		srcPr.x = srcPrTex.x;
		srcPr.y = srcPrTex.y;
		srcPr.width = srcPrTex.width;
		srcPr.height = 1f / tex.height;
		targPr.x = r.x;
		targPr.y = r.y + r.height;
		targPr.width = r.width;
		targPr.height = _padding;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);


		//left margin
		srcPr.x = srcPrTex.x;
		srcPr.y = srcPrTex.y;
		srcPr.width = 1f / tex.width;
		srcPr.height = srcPrTex.height;
		targPr.x = rPadded.x;
		targPr.y = r.y;
		targPr.width = _padding;
		targPr.height = r.height;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);
		
		//right margin
		srcPr.x = srcPrTex.x + 1f - 1f / tex.width;
		srcPr.y = srcPrTex.y;
		srcPr.width = 1f / tex.width;
		srcPr.height = srcPrTex.height;
		targPr.x = r.x + r.width;
		targPr.y = r.y;
		targPr.width = _padding;
		targPr.height = r.height;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);


		//top left corner
		srcPr.x = srcPrTex.x;
		srcPr.y = srcPrTex.y + 1 - 1f / tex.height ;
		srcPr.width = 1f / tex.width;
		srcPr.height = 1f / tex.height;
		targPr.x = rPadded.x; 
		targPr.y = rPadded.y;
		targPr.width = _padding;
		targPr.height = _padding;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);

		//top right corner
		srcPr.x = srcPrTex.x + 1f - 1f / tex.width;
		srcPr.y = srcPrTex.y + 1 - 1f / tex.height ;
		srcPr.width = 1f / tex.width;
		srcPr.height = 1f / tex.height;
		targPr.x = r.x + r.width; 
		targPr.y = rPadded.y;
		targPr.width = _padding;
		targPr.height = _padding;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);

		//bot left corner
		srcPr.x = srcPrTex.x;
		srcPr.y = srcPrTex.y;
		srcPr.width = 1f / tex.width;
		srcPr.height = 1f / tex.height;
		targPr.x = rPadded.x; 
		targPr.y = r.y + r.height;
		targPr.width = _padding;
		targPr.height = _padding;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);
		
		//bot right corner
		srcPr.x = srcPrTex.x + 1f - 1f / tex.width;
		srcPr.y = srcPrTex.y ;
		srcPr.width = 1f / tex.width;
		srcPr.height = 1f / tex.height;
		targPr.x = r.x + r.width; 
		targPr.y = r.y + r.height;
		targPr.width = _padding;
		targPr.height = _padding;
		Graphics.DrawTexture(targPr, tex, srcPr, 0, 0, 0, 0, mat);

		//now the texture
		Graphics.DrawTexture(r, tex, srcPrTex, 0, 0, 0, 0, mat);

		tex.wrapMode = oldTexWrapMode;
	}
}

[ExecuteInEditMode]
public class MB3_AtlasPackerRenderTexture : MonoBehaviour {
	MB_TextureCombinerRenderTexture fastRenderer;
	bool _doRenderAtlas = false;

	public int width;
	public int height;
	public int padding;
	public bool isNormalMap;
	public Rect[] rects;
	public Texture2D tex1;
	public List<MB3_TextureCombiner.MB_TexSet> textureSets;
	public int indexOfTexSetToRender;
	public MB2_LogLevel LOG_LEVEL = MB2_LogLevel.info;

	public Texture2D testTex;
	public Material testMat;

	public Texture2D OnRenderAtlas(MB3_TextureCombiner combiner){
		fastRenderer = new MB_TextureCombinerRenderTexture();
		_doRenderAtlas = true;
		Texture2D atlas = fastRenderer.DoRenderAtlas(this.gameObject,width,height,padding,rects,textureSets,indexOfTexSetToRender, isNormalMap, combiner, LOG_LEVEL);
		_doRenderAtlas = false;
		return atlas;
	}
	
	void OnRenderObject(){
		if (_doRenderAtlas){
			fastRenderer.OnRenderObject();
			_doRenderAtlas = false;
		}
	}
}
