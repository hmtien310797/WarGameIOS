// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Particles/FadeWave Particles Additive" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
}

Category {
	Tags { "Queue"="Transparent+20" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off ZTest Off Fog { Color (0,0,0,0) }
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles

			#include "UnityCG.cginc"
			sampler2D _MainTex;
			fixed4 _TintColor;
			float4 _FadeOffset;
			float _FadeRate;
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
			};
			
			float4 _MainTex_ST;

			void FadeWave(inout float4 vertex, in float3 normal,in float fade)
			{
				float l = length(vertex*_Time.x*25);// _Time.x
				float sin_ff = sin(l);
				vertex.xyz = vertex.xyz + normal*(sin_ff)*(1)*0.25;
			}

			v2f vert (appdata_t v)
			{
				v2f o;
				//FadeWave(v.vertex, v.normal, v.color.a);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = 2.0f * v.color * _TintColor;
				float2 uv = v.texcoord;
				uv.y += sin(v.vertex.x*v.vertex.z*_Time.y*3)*0.15;
				o.texcoord = TRANSFORM_TEX(uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = i.color * tex2D(_MainTex, i.texcoord);
				return c;
			}
			ENDCG 
		}
	}	
}
}
