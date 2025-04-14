// Simplified Multiply Particle shader. Differences from regular Multiply Particle one:
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "FX/Multiply Early" {
Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
}

Category {
	Tags { "Queue"="Geometry+1" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend Zero SrcColor
	Cull Off Lighting Off ZWrite Off Fog { Mode Off }
	
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	SubShader {
		Pass {
			SetTexture [_MainTex] {
				combine texture * primary
			}
			SetTexture [_MainTex] {
				constantColor (1,1,1,1)
				combine previous lerp (previous) constant
			}
		}
	}
}
}
