// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/Scene/Diffuse Bake"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_LMTex("light mapping",2D) = "white" {}
	}

	CGINCLUDE
		#include"UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _LMTex;
		float4 _LMTex_ST;
		float4 _Color;

		struct appdata_lm
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			fixed4 color : COLOR;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
		};

		struct v2f_lm
		{
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
			float2 uv : TEXCOORD0;
			half2 lm : TEXCOORD1;
			UNITY_FOG_COORDS(2)
		};

		v2f_lm vert_lm(appdata_lm v)
		{
			v2f_lm o;
			o.lm = v.texcoord1 *_LMTex_ST.xy + _LMTex_ST.zw;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			UNITY_TRANSFER_FOG(o, o.pos);
			return o;
		}

		fixed4 frag_lm(v2f_lm i) :SV_Target
		{
			fixed4 texcol = tex2D(_MainTex, i.uv);

			fixed4 bakedColorTex = tex2D(_LMTex, i.lm);
			half3 lm = DecodeLightmap(bakedColorTex);
			texcol.rgb = bakedColorTex.rgb*texcol.rgb + texcol.rgb;
			fixed4 c = (texcol*_Color);
			UNITY_APPLY_FOG(i.fogCoord, c);
			return c;
		}
	ENDCG


		SubShader
		{
			Tags{ "RenderType" = "Opaque" }

			LOD 200
			Fog{ Mode Off }
			Pass
			{
				Tags { "LightMode" = "Vertex" }
				CGPROGRAM
				#pragma vertex vert_lm  
				#pragma fragment frag_lm
				//#pragma multi_compile _CW_EFFECT_OFF _CW_EFFECT_ON
				#pragma multi_compile_fog
				ENDCG
			}
		}
		//Fallback "Diffuse"
}