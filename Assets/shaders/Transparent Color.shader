// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/Transparent Color" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)   	
	//_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 200

    Lighting Off
    ZWrite Off
    Offset -1, -1
    Blend SrcAlpha OneMinusSrcAlpha
    
    Pass {
		Color [_Color]
	}
}

}
