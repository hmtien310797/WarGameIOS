// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Particles/Additive Ngui" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles

			#include "UnityCG.cginc"
			sampler2D _MainTex;
			fixed4 _TintColor;
			fixed2 _ClipSharpness = fixed2(20, 20);
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = TRANSFORM_TEX(v.vertex.xy, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f IN) : SV_Target
			{
				// Softness factor
				float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipSharpness;

				// Sample the texture
				half4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
				col.a *= clamp(min(factor.x, factor.y), 0.0, 1.0);
				return col;
			}
			ENDCG 
		}
	}	
}
}
