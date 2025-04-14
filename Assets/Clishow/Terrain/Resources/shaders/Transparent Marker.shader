// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Terrain/Transparent Marker"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

	CGINCLUDE
		#include"UnityCG.cginc"
		#include "Assets/Clishow/Terrain/Resources/shaders/CurvedWorld_Base.cginc"
		#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
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
			float2 uv : TEXCOORD0;
			float fog : TEXCOORD2;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.fog = CalculateFogFactor(v.vertex, _FogLineMax-20);
			v.vertex.y =1;
			V_CW_TransformPoint(v.vertex);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			clip(i.color.a - 0.5);
			fixed4 texcol = tex2D(_MainTex, i.uv);
			texcol *= fixed4(i.color.r, i.color.g, i.color.b, 1);
			fixed4 c = (texcol*_Color) * 2;
			ApplyFog(c, _FogColor.rgb, i.fog);
			return c;
		}
	ENDCG

	SubShader
	{
		Tags{ "Queue" = "Background+5"  "RenderType" = "Transparent" }
		LOD 100
		//Cull Off
		Fog{ Mode Off }
			ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			Tags{ "LightMode" = "Vertex" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
