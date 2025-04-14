// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/Scene/Transparent"
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

		struct appdata_lm
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			fixed4 color : COLOR;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
			float2 uv : TEXCOORD0;
			float3 lightColor : TEXCOORD1;
			UNITY_FOG_COORDS(2)
		};

		struct v2f_lm
		{
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
			float2 uv : TEXCOORD0;
			half2 lm : TEXCOORD1;
			UNITY_FOG_COORDS(2)
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.lightColor = ShadeVertexLights(v.vertex, v.normal);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			UNITY_TRANSFER_FOG(o, o.pos);
			return o;
		}

		v2f_lm vert_lm(appdata_lm v)
		{
			v2f_lm o;
			o.lm = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			UNITY_TRANSFER_FOG(o, o.pos);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			fixed4 texcol = tex2D(_MainTex, i.uv) * _Color;
			texcol *= float4(i.lightColor, 1);
			UNITY_APPLY_FOG(i.fogCoord, texcol);
			return texcol;
		}

		fixed4 frag_lm(v2f_lm i) :SV_Target
		{
			fixed4 texcol = tex2D(_MainTex, i.uv)* _Color;
			fixed4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lm);
			half3 lm = DecodeLightmap(bakedColorTex);
			texcol.rgb *= lm.rgb;
			UNITY_APPLY_FOG(i.fogCoord, texcol);
			return texcol;
		}
	ENDCG


		SubShader
		{
			Tags{ "Queue" = "Transparent"  "RenderType" = "Transparent" }

			LOD 100
			Fog{ Mode Off }
			//Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Pass
			{
				Tags { "LightMode" = "Vertex" }
				CGPROGRAM
				#pragma vertex vert  
				#pragma fragment frag
				#pragma multi_compile_fog
				ENDCG
			}
			
			// Lightmapped
			Pass
			{
				Tags{ "LightMode" = "VertexLM" }
				CGPROGRAM
				#pragma vertex vert_lm
				#pragma fragment frag_lm
				#pragma multi_compile_fog
				ENDCG
			}

			// Lightmapped, encoded as RGBM
			Pass
			{
				Tags{ "LightMode" = "VertexLMRGBM" }
				CGPROGRAM
				#pragma vertex vert_lm
				#pragma fragment frag_lm
				#pragma multi_compile_fog
				ENDCG
			}
		}
		//Fallback "Diffuse"
}