// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShadowReplace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_AlphaCutoff ("Cutoff", float) = 0.5
		_Color("Base Color", Color) = (1,1,1,1)
	}
		
	CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _TintColor;
		float4 _Color;

		struct appdata
		{
			float4 vertex : POSITION;
			fixed4 color : COLOR;
		};

		struct appdata_t
		{
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			half2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
		};

		struct v2f_t
		{
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
			half2 texcoord : TEXCOORD0;
		};

		struct v2f_i
		{
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
			float ignore : TEXCOORD0;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.color = v.color;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		v2f_t vert_t(appdata_t v)
		{
			v2f_t o;
			o.color = v.color;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			clip(i.color.a - 0.5);
			return fixed4(1,1,1,1);
		}

		fixed4 frag_Transparent(v2f i) : SV_Target
		{
			clip(i.color.a - 0.5);
			return fixed4(_Color.a,1,1,1);
		}

		fixed4 frag_t(v2f_t i) : SV_Target
		{
			clip(i.color.a - 0.5);
			fixed4 c = tex2D(_MainTex, i.texcoord);
			return _TintColor*c.a;
		}
	ENDCG

	Subshader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		Pass {
    		Lighting Off Fog { Mode off } 
			CGPROGRAM
				#pragma vertex vert  
				#pragma fragment frag
			ENDCG
		}    
	}

		Subshader
		{
			Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
				Pass{
				Lighting Off Fog{ Mode off }
				CGPROGRAM
					#pragma vertex vert  
					#pragma fragment frag_Transparent
				ENDCG
			}
		}
}
