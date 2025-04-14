// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/Transparent Texture Ext" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,0.5)   	
	_MainTex ("Base (RGBA)", 2D) = "white" {}
}

SubShader {

    Tags {"Queue"="Transparent-1" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 200

    Lighting Off
    ZWrite Off
    Offset -1, -1
    Blend SrcAlpha OneMinusSrcAlpha 
    
    Pass {
		SetTexture [_MainTex] 
		{
			constantcolor [_Color]
			combine texture * constant
		}
	}
}

}
