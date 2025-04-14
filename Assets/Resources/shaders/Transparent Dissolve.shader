// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/Particles/Transparent CutOut Dissolve"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_DissolveBaseTex("溶解贴图",2D) = "white" {}
		_DissolveColorTex("溶解叠色图",2D) = "white" {}
		_Amount("溶解值", Range(0, 1)) = 0.5
		_Cutoff("  Alpha cutoff", Range(0,1)) = 0.5
	}

	CGINCLUDE

		#include"UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _DissolveBaseTex;
		float4 _DissolveBaseTex_ST;
		sampler2D _DissolveColorTex;
		float4 _DissolveColorTex_ST;
		float _Amount;
		float _Cutoff;

		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		v2f vert(appdata v) 
		{
			v2f o = (v2f)0;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		fixed4 frag(v2f i) : COLOR
		{
			fixed4 disBase = tex2D(_DissolveBaseTex,i.uv);
			fixed amount = (((1.0 - _Amount)*1.4 + -0.7) + disBase.r);
			clip(amount - 0.5);

			fixed4 texCol = tex2D(_MainTex,i.uv);
			clip(texCol.a - _Cutoff);
			fixed3 diffuseColor = texCol.rgb;
			fixed3 diffuse = diffuseColor;
			////// Emissive:
			fixed2 coluv = fixed2((1.0 - saturate((amount*3.5 + -1.0))),0.0);
			fixed4 _emissive = tex2D(_DissolveColorTex,TRANSFORM_TEX(coluv, _DissolveColorTex));
			fixed3 emissive = _emissive.rgb;
			/// Final Color:
			fixed3 finalColor = diffuse + emissive;
			fixed4 finalRGBA = fixed4(finalColor, texCol.a);
			return finalRGBA;
		}



	ENDCG


		SubShader
		{
			Tags
			{ 
				"RenderType" = "Transparent"
			}

			LOD 200
			Fog{ Mode Off }
			ZWrite Off
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				ENDCG
			}


		}
		//Fallback "Diffuse"
}