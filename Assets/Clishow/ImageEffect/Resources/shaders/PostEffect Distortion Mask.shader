// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Post/Transparent Mask G" {
	Properties{
		_MainTex("Particle Texture", 2D) = "white" {}
	}

		Category{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha One
		//ColorMask RGB
		Cull Off Lighting Off ZWrite Off Fog{ Color(0,0,0,0) }

		SubShader{
		Pass{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_particles

		#include "UnityCG.cginc"
		sampler2D _MainTex;

	struct appdata_t {
		float4 vertex : POSITION;
		half2 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 vertex : SV_POSITION;
		half2 texcoord : TEXCOORD0;
	};

	float4 _MainTex_ST;

	v2f vert(appdata_t v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed c = (1-tex2D(_MainTex, i.texcoord).r);
		//clip(c - 0.25);
		return fixed4(0,1,0,1)*(c)*2;
	}
		ENDCG
	}
	}
	}
}
