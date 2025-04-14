// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/Terrain/Aircraft no Shadow"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		//_Direction("Direction",Vector) = (1,0,0,0)
	}

		CGINCLUDE
		#include"UnityCG.cginc"
//#include "Assets/Clishow/Terrain/Resources/shaders/CurvedWorld_Base.cginc"
//#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _Color;
		//fixed4 _Direction;
		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			//fixed4 color : COLOR;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			//fixed4 color : COLOR;
			float2 uv : TEXCOORD0;
			float3 lightColor : TEXCOORD1;
			//float fog : TEXCOORD2;
			//float3 wview : TexCOORD3;
			//float3 wnormal : TexCOORD4;
			//float4 wpos : TEXCOORD5;
		};
		float3 ShadeVertexLight (float4 vertex, float3 normal)
		{
			//float3 viewpos = UnityObjectToViewPos (vertex);
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
			//o.wpos = mul(unity_ObjectToWorld, v.vertex);
			//o.wnormal = normalize((mul(unity_ObjectToWorld, fixed4(v.normal,1))).xyz);
			//o.wview =  normalize(WorldSpaceViewDir(v.vertex));
			//o.fog = CalculateFogFactor(v.vertex, _FogLineMax);
			//V_CW_TransformPoint(v.vertex);
			o.lightColor = ShadeVertexLight(v.vertex, v.normal);
			o.pos = UnityObjectToClipPos(v.vertex);
			//o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			//clip(i.color.a - 0.5);
			//return fixed4(i.wnormal, 1);
			//fixed nh = saturate(dot(normalize( i.wnormal+fixed3(-0.5,0,-0.5)),i.wview));
			//fixed3 spec = i.lightColor.rgb * (pow(nh,128)) * 0.5; //
			fixed4 texcol = tex2D(_MainTex, i.uv);
			//fixed4 s_color = fixed4(i.color.g, i.color.g, i.color.g, 1);
			//texcol *= float4(i.lightColor, 1)*s_color;// *s_color;
			//texcol *= float4(i.lightColor*i.color.g, 1);
			fixed4 c = (texcol * float4(i.lightColor, 1) * _Color) * 2;
			//c.rgb += spec;
			//ConvertMainServerColor(i.wpos, c);
			//ApplyFog(c, _FogColor.rgb, i.fog);
			return c;
		}
		ENDCG


		SubShader
		{
			Tags{ "Queue" = "Transparent-1"  "RenderType" = "Transparent" }

				LOD 200
				Fog{ Mode Off }
				//ZTest Off
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
