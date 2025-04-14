// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/Solid Color" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)   	
	//_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
	Tags { "Queue"="Transparent" "RenderType"="Transparent" }
	LOD 100
	
	//ZWrite Off
	//Offset -1, -1
	//Blend SrcAlpha OneMinusSrcAlpha 
	
	Pass {
		Lighting Off
		Color [_Color]
		//SetTexture [_MainTex] { combine primary } 
	}
}
}
