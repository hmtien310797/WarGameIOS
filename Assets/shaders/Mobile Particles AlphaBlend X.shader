// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Particles/Alpha Blend X" {
Properties {
	_Color ("Main Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Main Texture", 2D) = "white" {}
	_TilingX ("Tiling X", Float) = 1
	_TilingY ("Tiling Y", Float) = 1
	_OffsetX ("Offset X", Float) = 0
	_OffsetY ("Offset Y", Float) = 0
	_ParticleFactor ("Soft Particles Factor", Range(0.1,3)) = 1

}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off Fog { Mode Off }
	Blend SrcAlpha OneMinusSrcAlpha

	// ---- Dual texture cards
	SubShader {
		Pass {

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#define TRANSFORM_TEX2(tex,tiling,offset) (tex.xy * tiling.xy + offset.xy)
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4  pos : POSITION;
				fixed4 color : COLOR;
				float2  uv : TEXCOORD0;
			};

			half 	_ParticleFactor;
			half _TilingX;
			half _TilingY;
			half _OffsetX;
			half _OffsetY;
			fixed4 _Color;
			sampler2D _MainTex;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.color = v.color;
				o.uv = TRANSFORM_TEX2 (v.texcoord, half2(_TilingX,_TilingY),half2(_OffsetX,_OffsetY));
				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				//fixed4 texcol = tex2D (_MainTex, i.uv) * _ParticleFactor;
				return 2.0f * i.color * _Color * tex2D(_MainTex, i.uv) * _ParticleFactor;
			}
			ENDCG
		}
    } 	

}
}
