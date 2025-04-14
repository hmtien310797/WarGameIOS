// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no projector support

Shader "Custom/Transparent Lightmap(no light)" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)   	
		_MainTex ("Base (RGBA)", 2D) = "white" {}
		_LighMap ("LightMap (RGB)", 2D) = "white" {}
	}
	SubShader {

	    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	    LOD 200
	
	    Lighting Off
	    ZWrite Off
	    Blend SrcAlpha OneMinusSrcAlpha 
	    	    
	    BindChannels {
		   Bind "Vertex", vertex
		   Bind "texcoord", texcoord0
		   Bind "texcoord1", texcoord1
		}
		
	    Pass {
			SetTexture [_MainTex] 
			{
				constantcolor [_Color]
				combine texture * constant
			}
			
			SetTexture [_LighMap] 
			{
				combine texture * previous, previous
			}
		}
	}
}
