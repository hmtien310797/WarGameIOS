// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShadowReplaceIgnore"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_Color("Base Color", Color) = (1,1,1,1)
	}
		
	CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _TintColor;
		const float _IgnoreLimitY = 0;
		float4 _Color;

		struct appdata
		{
			float4 vertex : POSITION;
		};

		struct appdata_t
		{
			float4 vertex : POSITION;
			half2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half ignore : TEXCOORD1;
		};

		struct v2f_t
		{
			float4 pos : SV_POSITION;
			half2 texcoord : TEXCOORD0;
			half ignore : TEXCOORD1;
		};


		v2f vert(appdata v)
		{
			v2f o;
			float4 pos = mul(unity_ObjectToWorld, v.vertex);
			o.ignore = min(pos.y, _IgnoreLimitY) - _IgnoreLimitY;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		v2f_t vert_t(appdata_t v)
		{
			v2f_t o;
			float4 pos = mul(unity_ObjectToWorld, v.vertex);
			o.ignore = abs(min(pos.y, _IgnoreLimitY) - _IgnoreLimitY);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			return fixed4( step(0,i.ignore),1,1,1);
		}

		fixed4 frag_Transparent(v2f i) : SV_Target
		{
			return fixed4(step(0,i.ignore)*_Color.a,1,1,1);
		}

		fixed4 frag_t(v2f_t i) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, i.texcoord);
			c.a = c.a*step(0, i.ignore);
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
