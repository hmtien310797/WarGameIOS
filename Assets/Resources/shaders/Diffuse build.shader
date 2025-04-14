// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/build/Diffuse"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_LightColor("Light Color", Color) = (1,1,1,1)
		_LightDir("Light Dir", Vector) = (0,1,0,1)
	}

		CGINCLUDE
		#include"UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _Color;
		float4 _LightColor;
		float4 _LightDir;
		float4x4 _PerspCamProj;
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
			float2 uv : TEXCOORD0;
			float3 lightColor : TEXCOORD1;
		};


		float3 CalLight(float4 vertex, float3 normal)
		{
			float3 viewpos = UnityObjectToViewPos(vertex);
			float3 viewN = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, normal));

			float3 lightColor = _LightColor.xyz;
			float3 toLight = _LightDir.xyz;

			float atten = 1.0 / (1.0 + _LightDir.w);
			float diff = max(0, dot(viewN, toLight));
			lightColor += (diff * atten);

			return lightColor;
		}


		v2f vert(appdata v)
		{
			v2f o;
			o.lightColor = CalLight(v.vertex, v.normal);
			float4 p = UnityObjectToClipPos(v.vertex);
			o.pos = mul(mul(mul(UNITY_MATRIX_P,_PerspCamProj), UNITY_MATRIX_MV), v.vertex);
			o.pos.z = p.z*o.pos.w;
			//o.pos = p;
			o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}


		fixed4 frag(v2f i) :SV_Target
		{
			fixed4 texcol = tex2D(_MainTex, i.uv);
			texcol *= float4(i.lightColor, 1);
			fixed4 c = (texcol*_Color);
			return c;
		}

			ENDCG


			SubShader
		{
			Tags{ "RenderType" = "Opaque" }

				LOD 200
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