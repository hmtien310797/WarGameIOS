// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Terrain/Transparent Union Preivew Box"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

	CGINCLUDE

	#include"UnityCG.cginc"
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _Color;

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		fixed4 color : COLOR;
		float4 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR;
		float2 uv : TEXCOORD;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.color = v.color;
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		fixed4 texcol = tex2D(_MainTex, i.uv);
		fixed4 c = (texcol*i.color);
		return c;
	}
	
	ENDCG


	SubShader
	{
		Tags{ "Queue" = "Transparent"  "RenderType" = "Transparent" }
			LOD 100
			Fog{ Mode Off }
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Off
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}
}
