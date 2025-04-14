// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Terrain/Height2Shadow"
{
	Properties
	{
		_HeightTex ("Height Map", 2D) = "white" {}
		_LightDir ("Light Dir",Vector) = (0,0,0,0)
		_ShadowStrenght("Shadow strenght", Float) = 0.6
		_HeightOffset1("Height Offset1", Float) = 0.02
		_HeightOffset2("Height Offset2", Float) = 0.04
	}
	
	CGINCLUDE
		#include"UnityCG.cginc"

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
			float2 uv : TEXCOORD0;
			float2 uv_offset1 :TEXCOORD1;
			float2 uv_offset2 :TEXCOORD2;
		};
		
		struct v2f_RT
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};



		sampler2D _HeightTex;
		float4 _HeightTex_ST;
		float4 _LightDir;
		float _ShadowStrenght;
		float _HeightOffset1;
		float _HeightOffset2;
		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _HeightTex);
			o.uv_offset1 = v.texcoord.xy * _HeightTex_ST.xy + normalize(_LightDir.xz)*_HeightOffset1;
			o.uv_offset2 = v.texcoord.xy * _HeightTex_ST.xy + normalize(_LightDir.xz)*_HeightOffset2;
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			float4 color = 1;

			fixed4 trueHeight = tex2D(_HeightTex, i.uv);
			color.a = trueHeight.r;
			fixed4 offHeight1 = tex2D(_HeightTex, i.uv_offset1);
			fixed4 offHeight2 = tex2D(_HeightTex, i.uv_offset2);
			fixed baseH = (trueHeight.x);
			fixed helperHeight1 = (offHeight1.x);
			fixed helperHeight2 = (offHeight2.x);
			fixed light1 = saturate(baseH - helperHeight1) * _ShadowStrenght * 0.5;
			fixed shadow1 = saturate(helperHeight1 - baseH) * _ShadowStrenght;
			light1 *= saturate(baseH - 0.5) * 3;
			fixed light2 = saturate(baseH - helperHeight2) * _ShadowStrenght * 0.5;
			fixed shadow2 = saturate(helperHeight2 - baseH) * _ShadowStrenght;
			light2 *= saturate(baseH - 0.5) * 3;
			color.r = max(light1, light2) - ((shadow1 + shadow2) * 0.5) + 0.5;
			return color;
		}

		v2f_RT vert2RT(appdata v)
		{
			v2f_RT o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _HeightTex);
			return o;
		}

		fixed4 frag2RT(v2f_RT i) :SV_Target
		{
			return tex2D(_HeightTex, i.uv);
		}

	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert2RT
			#pragma fragment frag2RT
			ENDCG
		}
	}
}
