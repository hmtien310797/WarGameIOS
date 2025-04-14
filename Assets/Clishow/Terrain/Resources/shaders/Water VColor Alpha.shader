// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/Terrain/Water VColor Alpha"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_Detal_G("Detal (G)", 2D) = "white" {}
		_Detal_B("Detal (B)", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_WaterSetting("WaterSetting",Vector) = (0.1,0.1,0.1,0)
	}

	CGINCLUDE
		#include"UnityCG.cginc"
		#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
		sampler2D _Detal_G;
		sampler2D _Detal_B;
		sampler2D _NoiseTex;
		float4 _Detal_G_ST;
		float4 _Detal_B_ST;
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
			float4 uv : TEXCOORD0;
			float3 lightColor : TEXCOORD1;
			float fog : TEXCOORD2;
			float4 wpos : TEXCOORD3;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.wpos = mul(unity_ObjectToWorld, v.vertex);
			o.fog = CalculateFogFactor(v.vertex, _FogLineMax);
			V_CW_TransformPoint(v.vertex);
			//v.vertex.xz += v.color.r* (sin(_Time.y)) * frac(v.vertex.xz)*0.5;
			o.lightColor = ShadeVertexLights(v.vertex, v.normal);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv.xy = TRANSFORM_TEX(v.texcoord, _Detal_G);
			o.uv.zw = TRANSFORM_TEX(v.texcoord, _Detal_B);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			clip(i.color.a - 0.5);
			fixed3 waveOffset =
			(tex2D(_NoiseTex, i.uv.xy + fixed2(0, _Time.y * _WaterSetting.w)).rgb +
				tex2D(_NoiseTex, i.uv.xy + fixed2(_Time.y * _WaterSetting.z, 0)).rgb) - 1;
			fixed2 ruv = float2(i.uv.x, 1 - i.uv.y) + waveOffset.xy * _WaterSetting.y;

			fixed4 c1 = tex2D(_Detal_G, ruv);
			fixed4 c2 = tex2D(_Detal_B, i.uv.zw);
			//return  c1*(i.color.g) + c2*(1 - i.color.g);
			fixed4 texcol = c1*(i.color.g) + c2*(1- i.color.g);
			texcol *= float4(i.lightColor, 1);
			fixed4 c = (texcol*_Color)*2;
			ConvertMainServerColor(i.wpos, c);
			ApplyFog(c, _FogColor.rgb, i.fog);
			c.a = i.color.r;
			return c;
		}
	ENDCG


		SubShader
		{
			Tags{ "Queue" = "Background+2" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
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
			//UsePass "wgame/Terrain/Diffuse Shadow Base/SHADOW"
		}
		Fallback "Diffuse"
}
