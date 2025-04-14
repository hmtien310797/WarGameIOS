// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Terrain/Transparent Line"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Direction("Direction",Vector) = (1,0,0,0)
	}

	CGINCLUDE
		#include"UnityCG.cginc"
		#include "Assets/Clishow/Terrain/Resources/shaders/CurvedWorld_Base.cginc"
		#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _Color;
		fixed4 _Direction;
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
			float3 uv : TEXCOORD0;
			float fog : TEXCOORD2;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.fog = CalculateFogFactor(v.vertex, _FogLineMax-20);
			V_CW_TransformPoint(v.vertex);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uv.z = v.normal.x;
			//o.uv.x -= _Time.y*v.normal.x*0.25f;
			//o.uv.x -= _Time.x*320;//v.normal.x;
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			clip(i.color.a - 0.5);
			i.uv.x -= _Time.y * i.uv.z;
			fixed4 texcol = tex2D(_MainTex, i.uv.xy);
			texcol *= fixed4(i.color.r, i.color.g, i.color.b, 1);
			//texcol.rgb *= _Color.rgb;
			fixed4 c = (texcol*_Color) * 2;
			ApplyFog(c, _FogColor.rgb, i.fog);
			return c;
		}
	ENDCG

	SubShader
	{
		Tags{ "Queue" = "Transparent-2"  "RenderType" = "Transparent" }
		LOD 100
		Cull Off
		ZTest Off
		Fog{ Mode Off }
		Blend SrcAlpha One
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
