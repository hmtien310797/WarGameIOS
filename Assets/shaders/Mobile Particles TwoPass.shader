// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Particles/Alpha TwoPass" {
Properties {
	_MainTexBack ("Blend Texture", 2D) = "white" {}
	_TintBackColor ("Tint Blend Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTexFront ("Add Texture", 2D) = "white" {}
	_TintFrontColor ("Tint Additive Color", Color) = (0.5,0.5,0.5,0.5)
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	
	//AlphaTest Greater .01
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	// ---- Dual texture cards
	SubShader {

		Pass {
			Blend SrcAlpha OneMinusSrcAlpha
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			sampler2D _MainTexBack;
			fixed4 _TintBackColor;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			
			float4 _MainTexBack_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTexBack);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				return i.color * _TintBackColor * tex2D(_MainTexBack, i.texcoord);
			}
			ENDCG 
		}
		Pass {
			Blend SrcAlpha One
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			sampler2D _MainTexFront;
			fixed4 _TintFrontColor;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			
			float4 _MainTexFront_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTexFront);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				return 2.0f * i.color * _TintFrontColor * tex2D(_MainTexFront, i.texcoord);
			}
			ENDCG 
		}
		
    } 	

}
}
