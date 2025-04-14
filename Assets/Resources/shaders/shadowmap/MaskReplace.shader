// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MaskReplace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_AlphaCutoff ("Cutoff", float) = 0.5
		_Color("Base Color", Color) = (1,1,1,1)
		_MaskForce("Mask Force", Range(0,1)) = 1
	}
		
	CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _TintColor;
		float4 _Color;
		fixed _MaskForce;

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
			return fixed4(0,0,0,1);
		}

		fixed4 frag_t(v2f_t i) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, i.texcoord);// *_Color;
			return fixed4(0,0,0,c.a);
		}

			struct v2f_ml
		{
			float4 pos : SV_POSITION;
			float4 color : TEXCOORD1;
			half2 texcoord : TEXCOORD0;
		};

		struct appdata_ml
		{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float4 color : COLOR;
			float4 texcoord : TEXCOORD0;
		};

		v2f_ml vert_m(appdata_ml v)
		{
			float4 vt = v.vertex;
			float2 localxz = vt.xz;
			float4 lp = v.tangent;
			vt.xz = vt.xz - ((1 - lp.w)*lp.xz);
			v2f_ml o;
			o.color = v.color;
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.pos = UnityObjectToClipPos(vt);
			return o;
		}

		fixed4 frag_m(v2f_ml i) :COLOR
		{
			fixed c = (1 - tex2D(_MainTex, i.texcoord).r);
		return fixed4(i.color.rgb, 1) *(c) * i.color.a;
		}
	ENDCG

	Subshader 
	{
		Tags { "RenderType"="Opaque"}
			LOD 200
		Pass {
			CGPROGRAM
				#pragma vertex vert_t  
				#pragma fragment frag_t
			ENDCG
		}    
	}

		//Subshader
		//{
		//	Tags{ "RenderType" = "Transparent"}
		//	Blend SrcAlpha OneMinusSrcAlpha
		//		Pass{
		//		Lighting Off Fog{ Mode off }
		//		CGPROGRAM
		//			#pragma vertex vert_t  
		//			#pragma fragment frag_t
		//		ENDCG
		//	}
		//}

		Subshader
		{
			Tags{ "RenderType" = "PostMask" "Queue" = "Transparent" }
				Blend SrcAlpha One
				Cull Off Lighting Off ZWrite Off
				Pass{
				Fog{ Mode off }
				CGPROGRAM
				#pragma vertex vert_m  
				#pragma fragment frag_m
				ENDCG
			}
		}
}
