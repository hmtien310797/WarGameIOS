// Unlit shader. Vetex color shader.
// - no lighting
// - no lightmap support
// - no per-material color
// only render vetex color

Shader "Custom/Vetex Color" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	LOD 100
	
	ZWrite Off
	Lighting Off
	Offset -1, -1
	Blend SrcAlpha OneMinusSrcAlpha 
	
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	Pass {
		SetTexture [_MainTex] { combine texture * primary } 
	}
}
}
