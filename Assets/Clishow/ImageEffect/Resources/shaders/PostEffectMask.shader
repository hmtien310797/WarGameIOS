// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Post/Transparent Mask" {
	Properties{
		_MainTex("Particle Texture", 2D) = "white" {}
		_MaskForce("Mask Force", Range(0,1)) = 1
		_Color("Main Color", Color) = (1,1,1,1)
	}

		Category{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "PostMask" }
		Blend SrcAlpha One
		//ColorMask RGB//ZWrite Off
		Cull Off Lighting Off  Fog{ Color(0,0,0,0) }

		SubShader{
		Pass{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_particles

		#include "UnityCG.cginc"
		sampler2D _MainTex;
		fixed _MaskForce;
		float4 _Color;

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
		//float4 wpos = mul(unity_ObjectToWorld, v.vertex);
		//wpos.y = 0.5f;
		//wpos = mul(unity_WorldToObject, wpos);
		o.vertex = UnityObjectToClipPos(v.vertex);//wpos);//
		o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed c = (1-tex2D(_MainTex, i.texcoord).r);
		//clip(c - 0.25);
		return fixed4(_Color.rgb,1)*(c)*4* _MaskForce;
	}
		ENDCG
	}
	}
	}
}
