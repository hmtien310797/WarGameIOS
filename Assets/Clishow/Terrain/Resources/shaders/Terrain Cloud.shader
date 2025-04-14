// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Terrain/Terrain Cloud"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_WaveX("WaveX",FLOAT) = 1
		_WaveY("WaveY",FLOAT) = 1
	}

	CGINCLUDE
		#include"UnityCG.cginc"
		#include "Assets/Clishow/Terrain/Resources/shaders/CurvedWorld_Base.cginc"
		#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _Color;
		float _WaveX;
		float _WaveY;
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
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uv.xy += _Time.x*float2(_WaveX, _WaveY);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			//return fixed4(i.color.g,0,0,1);
			fixed4 texcol = tex2D(_MainTex, i.uv);
			fixed4 c =  _Color * texcol;
			c.a*=i.color.g;
			return c;
		}
	ENDCG

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			ColorMask RGB
		LOD 100
		Fog{ Mode Off }
			ZWrite Off
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Tags{ "LightMode" = "Vertex" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		//UsePass "wgame/Terrain/Diffuse Shadow Base/SHADOW"
	}
}
