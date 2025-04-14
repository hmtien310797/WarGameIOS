// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/Tree Cutoff" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)   	
	_MainTex ("Base (RGBA)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range (0,1)) = 0.3
}

SubShader {

    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="TreeLeaf"}
    LOD 200

	Lighting Off
	Blend SrcAlpha OneMinusSrcAlpha 
	
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	Pass {
		// Use the Cutoff parameter defined above to determine
		// what to render.
		AlphaTest Greater [_Cutoff]

		SetTexture [_MainTex] { combine texture * primary, texture } 
	}
}

}
