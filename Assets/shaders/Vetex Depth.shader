// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Vertex Depth" {
Properties {
}

Category {

Tags { "RenderType"="Opaque" }

	SubShader {
		Pass {
			Fog { Mode off }
			Lighting Off
				
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

struct v2f {
	float4 pos		: SV_POSITION;
	float2 depth : TEXCOORD0;
}; 
v2f vert (appdata_img v)
{
	v2f o;
	o.pos = UnityObjectToClipPos (v.vertex);
	 UNITY_TRANSFER_DEPTH(o.depth);
	return o;
}

fixed4 frag (v2f i) : SV_Target
{
	UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG

		}
	}
}

Fallback off

}