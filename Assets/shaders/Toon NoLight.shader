// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Toon/No Light" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline width", Range (.002, 0.03)) = .002
		_MainTex ("Base (RGB)", 2D) = "white" { }
		_IlluminCol ("Half-Illumination color (RGB)", Color) = (0.5,0.5,0.5,1)
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f {
		float4 pos : POSITION;
		fixed4 color : COLOR;
	};
	
	uniform float _Outline;
	uniform fixed4 _OutlineColor;
	
	v2f vert(appdata v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		float2 offset = TransformViewToProjection(norm.xy);

		o.pos.xy += offset * o.pos.z * _Outline;
		o.color = _OutlineColor;
		return o;
	}
	ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" }
		
		Pass {
			Name "BASE"
			Lighting Off
			SetTexture [_MainTex] {
				constantColor [_Color]
				Combine texture * constant
			}
			SetTexture [_] {
				constantColor [_IlluminCol]
            	Combine previous * constant DOUBLE, previous
            }
		}
				
		Pass {
			Name "OUTLINE"
			Tags { "LightMode" = "Always" }
			Cull Front
			ZWrite On
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			fixed4 frag(v2f i) :COLOR { return i.color; }
			ENDCG
		}
	}
	
	Fallback "Diffuse"
}
