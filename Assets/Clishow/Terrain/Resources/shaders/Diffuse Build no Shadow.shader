// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/Terrain/Diffuse Build no Shadow"
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
			float4 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 lightColor : TEXCOORD1;
		};

		float3 ShadeVertexLight (float4 vertex, float3 normal)
		{
			float3 viewN = normalize (mul ((float3x3)UNITY_MATRIX_IT_MV, normal));

			float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

			float3 toLight = unity_LightPosition[0].xyz;// - viewpos.xyz * unity_LightPosition[0].w;
			float lengthSq = dot(toLight, toLight);
			toLight *= rsqrt(lengthSq);

			float atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[0].z);

			float diff = max (0, dot (viewN, toLight));
			lightColor += unity_LightColor[0].rgb * (diff * atten);
			return lightColor;
		}

		v2f vert(appdata v)
		{
			v2f o;
			o.lightColor = ShadeVertexLight(v.vertex, v.normal);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			fixed4 texcol = tex2D(_MainTex, i.uv);
			fixed4 c = (texcol * float4(i.lightColor, 1) * _Color) * 2;
			return c;
		}
		ENDCG


		SubShader
		{
			Tags{ "Queue" = "Background+10" "RenderType" = "Opaque" }

				LOD 200
				Fog{ Mode Off }
				Pass
			{
				Tags{ "LightMode" = "Vertex" }
				CGPROGRAM
				#pragma vertex vert  
				#pragma fragment frag
				ENDCG
			}
		}
		//Fallback "Diffuse"
}
